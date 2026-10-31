using System;
using System.Data;
using System.Data.SqlClient;
using System.Web.UI;
using Gearzone.Helpers;

namespace Gearzone
{
    public partial class Register : Page
    {
        protected void Page_Load(object sender, EventArgs e)
        {
            if (Session["UserID"] != null)
            {
                Response.Redirect("Default.aspx");
            }
        }

        protected void btnRegister_Click(object sender, EventArgs e)
        {
            string fullName = txtFullName.Text.Trim();
            string username = txtUsername.Text.Trim();
            string email = txtEmail.Text.Trim();
            string password = txtPassword.Text;
            string confirmPassword = txtConfirmPassword.Text;
            string phone = txtPhone.Text.Trim();

            // Kiểm tra phía server
            if (string.IsNullOrEmpty(fullName) || string.IsNullOrEmpty(username) ||
                string.IsNullOrEmpty(email) || string.IsNullOrEmpty(password))
            {
                lblError.Text = "Vui lòng điền đầy đủ các trường bắt buộc.";
                lblError.Visible = true;
                return;
            }

            if (username.Length < 3)
            {
                lblError.Text = "Tên đăng nhập phải có ít nhất 3 ký tự.";
                lblError.Visible = true;
                return;
            }

            if (!System.Text.RegularExpressions.Regex.IsMatch(email, @"^[^\s@]+@[^\s@]+\.[^\s@]+$"))
            {
                lblError.Text = "Email không đúng định dạng.";
                lblError.Visible = true;
                return;
            }

            if (password.Length < 6)
            {
                lblError.Text = "Mật khẩu phải có ít nhất 6 ký tự.";
                lblError.Visible = true;
                return;
            }

            if (password != confirmPassword)
            {
                lblError.Text = "Mật khẩu xác nhận không khớp.";
                lblError.Visible = true;
                return;
            }

            // Kiểm tra trùng username
            object existUser = DBHelper.ExecuteScalar(
                "SELECT COUNT(*) FROM Users WHERE Username = @Username",
                new SqlParameter("@Username", username));
            if (Convert.ToInt32(existUser) > 0)
            {
                lblError.Text = "Tên đăng nhập đã tồn tại.";
                lblError.Visible = true;
                return;
            }

            // Kiểm tra trùng email
            object existEmail = DBHelper.ExecuteScalar(
                "SELECT COUNT(*) FROM Users WHERE Email = @Email",
                new SqlParameter("@Email", email));
            if (Convert.ToInt32(existEmail) > 0)
            {
                lblError.Text = "Email đã được sử dụng.";
                lblError.Visible = true;
                return;
            }

            // Băm mật khẩu và lưu vào DB
            string passwordHash = DBHelper.HashPassword(password);

            string sql = @"INSERT INTO Users (Username, Email, PasswordHash, FullName, Phone)
                           VALUES (@Username, @Email, @PasswordHash, @FullName, @Phone)";

            int result = DBHelper.ExecuteNonQuery(sql,
                new SqlParameter("@Username", username),
                new SqlParameter("@Email", email),
                new SqlParameter("@PasswordHash", passwordHash),
                new SqlParameter("@FullName", fullName),
                new SqlParameter("@Phone", string.IsNullOrEmpty(phone) ? (object)DBNull.Value : phone));

            if (result > 0)
            {
                lblError.Visible = false;
                lblSuccess.Text = "Đăng ký thành công! Bạn có thể đăng nhập ngay.";
                lblSuccess.Visible = true;
                txtFullName.Text = "";
                txtUsername.Text = "";
                txtEmail.Text = "";
                txtPhone.Text = "";
            }
            else
            {
                lblError.Text = "Đăng ký thất bại, vui lòng thử lại.";
                lblError.Visible = true;
            }
        }
    }
}
