using System;
using System.Data;
using System.Web.UI;
using System.Web.UI.WebControls;
using Gearzone.Helpers;

namespace Gearzone
{
    public partial class _Default : Page
    {
        protected void Page_Load(object sender, EventArgs e)
        {
            if (!IsPostBack)
            {
                LoadFeaturedProducts();
            }
        }

        private void LoadFeaturedProducts()
        {
            DataTable dt = ProductData.GetFeaturedProducts(8);
            rptFeaturedProducts.DataSource = dt;
            rptFeaturedProducts.DataBind();
        }

        protected void btnAddCart_Command(object sender, CommandEventArgs e)
        {
            int productId = Convert.ToInt32(e.CommandArgument);
            DataRow product = ProductData.GetProductById(productId);
            if (product != null)
            {
                CartHelper.AddToCart(
                    productId,
                    product["ProductName"].ToString(),
                    Convert.ToDecimal(product["Price"]),
                    product["ImageURL"].ToString()
                );
            }
            LoadFeaturedProducts();
        }
    }
}
