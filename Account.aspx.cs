using System;
using System.Data;
using System.Data.SqlClient;
using System.Web.UI;
using Gearzone.Helpers;

namespace Gearzone
{
    public partial class Account : Page
    {
        protected void Page_Load(object sender, EventArgs e)
        {
            if (Session["UserID"] == null)
            {
                Response.Redirect("Login.aspx?returnUrl=Account.aspx");
                return;
            }

            if (!IsPostBack)
            {
                LoadUserInfo();
                LoadOrders();
            }
        }

        private void LoadUserInfo()
        {
            int userId = Convert.ToInt32(Session["UserID"]);
            string sql = "SELECT FullName, Email, Phone, Address FROM Users WHERE UserID = @UserID";
            DataTable dt = DBHelper.ExecuteQuery(sql, new SqlParameter("@UserID", userId));

            if (dt.Rows.Count > 0)
            {
                DataRow user = dt.Rows[0];
                txtFullName.Text = user["FullName"].ToString();
                txtEmail.Text = user["Email"].ToString();
                txtPhone.Text = user["Phone"] != DBNull.Value ? user["Phone"].ToString() : "";
                txtAddress.Text = user["Address"] != DBNull.Value ? user["Address"].ToString() : "";
            }
        }

        private void LoadOrders()
        {
            int userId = Convert.ToInt32(Session["UserID"]);
            string sql = @"SELECT OrderID, OrderDate, TotalAmount, Status
                           FROM Orders
                           WHERE UserID = @UserID
                           ORDER BY OrderDate DESC";
            DataTable orders = DBHelper.ExecuteQuery(sql, new SqlParameter("@UserID", userId));

            if (orders.Rows.Count > 0)
            {
                rptOrders.DataSource = orders;
                rptOrders.DataBind();
                rptOrders.Visible = true;
                pnlNoOrders.Visible = false;
            }
            else
            {
                rptOrders.Visible = false;
                pnlNoOrders.Visible = true;
            }
        }

        protected void btnUpdate_Click(object sender, EventArgs e)
        {
            int userId = Convert.ToInt32(Session["UserID"]);
            string sql = @"UPDATE Users SET FullName = @FullName, Phone = @Phone, Address = @Address
                           WHERE UserID = @UserID";

            DBHelper.ExecuteNonQuery(sql,
                new SqlParameter("@FullName", txtFullName.Text.Trim()),
                new SqlParameter("@Phone", string.IsNullOrEmpty(txtPhone.Text.Trim()) ? (object)DBNull.Value : txtPhone.Text.Trim()),
                new SqlParameter("@Address", string.IsNullOrEmpty(txtAddress.Text.Trim()) ? (object)DBNull.Value : txtAddress.Text.Trim()),
                new SqlParameter("@UserID", userId));

            Session["FullName"] = txtFullName.Text.Trim();
            Session["Phone"] = txtPhone.Text.Trim();
            Session["Address"] = txtAddress.Text.Trim();

            lblMessage.Text = "Cập nhật thông tin thành công!";
            lblMessage.Visible = true;
        }

        protected void btnLogout_Click(object sender, EventArgs e)
        {
            Session.Clear();
            Session.Abandon();
            Response.Redirect("Default.aspx");
        }
    }
}
