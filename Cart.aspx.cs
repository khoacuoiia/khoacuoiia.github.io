using System;
using System.Collections.Generic;
using System.Web.UI;
using System.Web.UI.WebControls;
using Gearzone.Helpers;

namespace Gearzone
{
    public partial class Cart : Page
    {
        protected void Page_Load(object sender, EventArgs e)
        {
            if (!IsPostBack)
            {
                LoadCart();
            }
        }

        private void LoadCart()
        {
            List<CartItem> cart = CartHelper.GetCart();

            if (cart.Count == 0)
            {
                pnlCart.Visible = false;
                pnlEmptyCart.Visible = true;
            }
            else
            {
                pnlCart.Visible = true;
                pnlEmptyCart.Visible = false;
                rptCart.DataSource = cart;
                rptCart.DataBind();

                decimal total = CartHelper.GetTotal();
                lblSubtotal.Text = string.Format("{0:N0}", total);
                lblTotal.Text = string.Format("{0:N0}", total);
            }
        }

        protected void rptCart_ItemCommand(object source, RepeaterCommandEventArgs e)
        {
            int productId = Convert.ToInt32(e.CommandArgument);

            switch (e.CommandName)
            {
                case "Increase":
                    List<CartItem> cart1 = CartHelper.GetCart();
                    CartItem item1 = cart1.Find(x => x.ProductID == productId);
                    if (item1 != null)
                    {
                        CartHelper.UpdateQuantity(productId, item1.Quantity + 1);
                    }
                    break;

                case "Decrease":
                    List<CartItem> cart2 = CartHelper.GetCart();
                    CartItem item2 = cart2.Find(x => x.ProductID == productId);
                    if (item2 != null && item2.Quantity > 1)
                    {
                        CartHelper.UpdateQuantity(productId, item2.Quantity - 1);
                    }
                    break;

                case "Remove":
                    CartHelper.RemoveFromCart(productId);
                    break;
            }

            LoadCart();
        }
    }
}
