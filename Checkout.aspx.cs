using System;
using System.Collections.Generic;
using System.Data.SqlClient;
using System.Web.UI;
using Gearzone.Helpers;

namespace Gearzone
{
    public partial class Checkout : Page
    {
        protected void Page_Load(object sender, EventArgs e)
        {
            if (!IsPostBack)
            {
                LoadOrderSummary();
                if (Session["FullName"] != null) txtFullName.Text = Session["FullName"].ToString();
                if (Session["Phone"] != null) txtPhone.Text = Session["Phone"].ToString();
                if (Session["Address"] != null) txtAddress.Text = Session["Address"].ToString();
            }
        }

        private void LoadOrderSummary()
        {
            List<CartItem> cart = CartHelper.GetCart();
            if (cart.Count == 0)
            {
                pnlCheckout.Visible = false;
                pnlEmptyCart.Visible = true;
                return;
            }
            rptOrderItems.DataSource = cart;
            rptOrderItems.DataBind();
            lblTotal.Text = string.Format("{0:N0}", CartHelper.GetTotal());
        }

        protected void btnPlaceOrder_Click(object sender, EventArgs e)
        {
            string fullName = txtFullName.Text.Trim();
            string phone = txtPhone.Text.Trim();
            string address = txtAddress.Text.Trim();

            // Kiểm tra phía server
            if (string.IsNullOrEmpty(fullName) || string.IsNullOrEmpty(phone) || string.IsNullOrEmpty(address))
            {
                lblError.Text = "Vui lòng điền đầy đủ thông tin bắt buộc.";
                lblError.Visible = true;
                LoadOrderSummary();
                return;
            }

            if (!System.Text.RegularExpressions.Regex.IsMatch(phone, @"^0[0-9]{9,10}$"))
            {
                lblError.Text = "Số điện thoại không hợp lệ.";
                lblError.Visible = true;
                LoadOrderSummary();
                return;
            }

            List<CartItem> cart = CartHelper.GetCart();
            if (cart.Count == 0)
            {
                lblError.Text = "Giỏ hàng trống.";
                lblError.Visible = true;
                return;
            }

            // Kiểm tra đăng nhập
            if (Session["UserID"] == null)
            {
                Response.Redirect("Login.aspx?returnUrl=Checkout.aspx");
                return;
            }

            int userId = Convert.ToInt32(Session["UserID"]);
            decimal totalAmount = CartHelper.GetTotal();

            try
            {
                // Lưu đơn hàng bằng Transaction
                string orderSql = @"INSERT INTO Orders (UserID, TotalAmount, ShippingName, ShippingPhone, ShippingAddress)
                                    VALUES (@UserID, @TotalAmount, @ShippingName, @ShippingPhone, @ShippingAddress);
                                    SELECT SCOPE_IDENTITY();";

                SqlParameter[] orderParams = new SqlParameter[]
                {
                    new SqlParameter("@UserID", userId),
                    new SqlParameter("@TotalAmount", totalAmount),
                    new SqlParameter("@ShippingName", fullName),
                    new SqlParameter("@ShippingPhone", phone),
                    new SqlParameter("@ShippingAddress", address)
                };

                string detailSql = @"INSERT INTO OrderDetails (OrderID, ProductID, Quantity, UnitPrice)
                                     VALUES (@OrderID, @ProductID, @Quantity, @UnitPrice)";

                List<SqlParameter[]> detailParamsList = new List<SqlParameter[]>();
                foreach (CartItem item in cart)
                {
                    SqlParameter[] detailParams = new SqlParameter[]
                    {
                        new SqlParameter("@ProductID", item.ProductID),
                        new SqlParameter("@Quantity", item.Quantity),
                        new SqlParameter("@UnitPrice", item.Price)
                    };
                    detailParamsList.Add(detailParams);
                }

                int orderId = DBHelper.ExecuteOrder(orderSql, orderParams, detailSql, detailParamsList.ToArray());

                // Xóa giỏ hàng
                CartHelper.ClearCart();

                // Hiển thị thành công
                pnlCheckout.Visible = false;
                pnlSuccess.Visible = true;
            }
            catch (Exception ex)
            {
                lblError.Text = "Đặt hàng thất bại: " + ex.Message;
                lblError.Visible = true;
                LoadOrderSummary();
            }
        }
    }
}
