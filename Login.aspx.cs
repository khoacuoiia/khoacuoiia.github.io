using System;
using System.Data;
using System.Data.SqlClient;
using System.Web.UI;
using Gearzone.Helpers;

namespace Gearzone
{
    public partial class Login : Page
    {
        protected void Page_Load(object sender, EventArgs e)
        {
            if (Session["UserID"] != null)
            {
                Response.Redirect("Default.aspx");
            }
        }

        protected void btnLogin_Click(object sender, EventArgs e)
        {
            string username = txtUsername.Text.Trim();
            string password = txtPassword.Text;

            if (string.IsNullOrEmpty(username) || string.IsNullOrEmpty(password))
            {
                lblError.Text = "Vui lòng nhập đầy đủ thông tin.";
                lblError.Visible = true;
                return;
            }

            // Băm mật khẩu và so sánh với DB
            string passwordHash = DBHelper.HashPassword(password);

            string sql = @"SELECT UserID, Username, FullName, Email, Phone, Address
                           FROM Users
                           WHERE (Username = @Username OR Email = @Username)
                           AND PasswordHash = @PasswordHash";

            DataTable dt = DBHelper.ExecuteQuery(sql,
                new SqlParameter("@Username", username),
                new SqlParameter("@PasswordHash", passwordHash));

            if (dt.Rows.Count > 0)
            {
                DataRow user = dt.Rows[0];
                Session["UserID"] = user["UserID"];
                Session["Username"] = user["Username"];
                Session["FullName"] = user["FullName"];
                Session["Email"] = user["Email"];
                Session["Phone"] = user["Phone"] != DBNull.Value ? user["Phone"].ToString() : "";
                Session["Address"] = user["Address"] != DBNull.Value ? user["Address"].ToString() : "";

                string returnUrl = Request.QueryString["returnUrl"];
                if (!string.IsNullOrEmpty(returnUrl))
                {
                    Response.Redirect(returnUrl);
                }
                else
                {
                    Response.Redirect("Default.aspx");
                }
            }
            else
            {
                lblError.Text = "Tên đăng nhập hoặc mật khẩu không đúng.";
                lblError.Visible = true;
            }
        }
    }
}
