using System;
using System.Configuration;
using System.Data;
using System.Data.SqlClient;

namespace Gearzone.Helpers
{
    /// <summary>
    /// Lớp hỗ trợ kết nối và truy vấn SQL Server
    /// Sử dụng tham số (parameterized queries) để chống SQL Injection
    /// </summary>
    public static class DBHelper
    {
        // Lấy chuỗi kết nối từ Web.config
        private static string GetConnectionString()
        {
            return ConfigurationManager.ConnectionStrings["GearZoneDB"].ConnectionString;
        }

        /// <summary>
        /// Thực thi truy vấn SELECT, trả về DataTable
        /// </summary>
        public static DataTable ExecuteQuery(string sql, params SqlParameter[] parameters)
        {
            DataTable dt = new DataTable();
            using (SqlConnection conn = new SqlConnection(GetConnectionString()))
            {
                using (SqlCommand cmd = new SqlCommand(sql, conn))
                {
                    if (parameters != null)
                    {
                        cmd.Parameters.AddRange(parameters);
                    }
                    using (SqlDataAdapter da = new SqlDataAdapter(cmd))
                    {
                        da.Fill(dt);
                    }
                }
            }
            return dt;
        }

        /// <summary>
        /// Thực thi INSERT, UPDATE, DELETE - trả về số dòng bị ảnh hưởng
        /// </summary>
        public static int ExecuteNonQuery(string sql, params SqlParameter[] parameters)
        {
            using (SqlConnection conn = new SqlConnection(GetConnectionString()))
            {
                using (SqlCommand cmd = new SqlCommand(sql, conn))
                {
                    if (parameters != null)
                    {
                        cmd.Parameters.AddRange(parameters);
                    }
                    conn.Open();
                    return cmd.ExecuteNonQuery();
                }
            }
        }

        /// <summary>
        /// Thực thi truy vấn trả về 1 giá trị (COUNT, MAX, vv.)
        /// </summary>
        public static object ExecuteScalar(string sql, params SqlParameter[] parameters)
        {
            using (SqlConnection conn = new SqlConnection(GetConnectionString()))
            {
                using (SqlCommand cmd = new SqlCommand(sql, conn))
                {
                    if (parameters != null)
                    {
                        cmd.Parameters.AddRange(parameters);
                    }
                    conn.Open();
                    return cmd.ExecuteScalar();
                }
            }
        }

        /// <summary>
        /// Thực thi đặt hàng trong Transaction (lưu Order + OrderDetails)
        /// </summary>
        public static int ExecuteOrder(string orderSql, SqlParameter[] orderParams,
            string detailSql, SqlParameter[][] detailParamsList)
        {
            using (SqlConnection conn = new SqlConnection(GetConnectionString()))
            {
                conn.Open();
                SqlTransaction transaction = conn.BeginTransaction();

                try
                {
                    // 1. INSERT Order và lấy OrderID
                    SqlCommand cmdOrder = new SqlCommand(orderSql, conn, transaction);
                    cmdOrder.Parameters.AddRange(orderParams);
                    int orderId = Convert.ToInt32(cmdOrder.ExecuteScalar());

                    // 2. INSERT từng OrderDetail
                    foreach (SqlParameter[] detailParams in detailParamsList)
                    {
                        SqlCommand cmdDetail = new SqlCommand(detailSql, conn, transaction);
                        // Thêm OrderID vào tham số
                        cmdDetail.Parameters.Add(new SqlParameter("@OrderID", orderId));
                        cmdDetail.Parameters.AddRange(detailParams);
                        cmdDetail.ExecuteNonQuery();
                    }

                    // Commit nếu thành công
                    transaction.Commit();
                    return orderId;
                }
                catch (Exception)
                {
                    // Rollback nếu lỗi
                    transaction.Rollback();
                    throw;
                }
            }
        }

        /// <summary>
        /// Băm mật khẩu bằng SHA256
        /// </summary>
        public static string HashPassword(string password)
        {
            using (var sha256 = System.Security.Cryptography.SHA256.Create())
            {
                byte[] bytes = System.Text.Encoding.UTF8.GetBytes(password);
                byte[] hash = sha256.ComputeHash(bytes);
                var sb = new System.Text.StringBuilder();
                for (int i = 0; i < hash.Length; i++)
                {
                    sb.Append(hash[i].ToString("x2"));
                }
                return sb.ToString();
            }
        }
    }
}
