using System;
using System.Web.UI;

namespace Gearzone
{
    public partial class SiteMaster : MasterPage
    {
        protected void Page_Load(object sender, EventArgs e)
        {
            // Cập nhật tên tài khoản nếu đã đăng nhập
            if (Session["Username"] != null)
            {
                lblAccountText.Text = Session["Username"].ToString();
            }
            else
            {
                lblAccountText.Text = "Tài khoản";
            }

            // Cập nhật số lượng giỏ hàng
            if (Session["CartCount"] != null)
            {
                lblCartCount.Text = Session["CartCount"].ToString();
            }
            else
            {
                lblCartCount.Text = "0";
            }
        }
    }
}
