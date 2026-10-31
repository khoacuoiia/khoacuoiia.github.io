using System;
using System.Collections.Generic;
using System.Data;
using System.Data.SqlClient;

namespace Gearzone.Helpers
{
    /// <summary>
    /// Lớp truy vấn dữ liệu sản phẩm từ SQL Server
    /// </summary>
    public static class ProductData
    {
        // Lấy tất cả danh mục + đếm số sản phẩm
        public static DataTable GetCategories()
        {
            string sql = @"SELECT c.CategoryID, c.CategoryName, c.Description, c.ImageURL,
                           (SELECT COUNT(*) FROM Products p WHERE p.CategoryID = c.CategoryID AND p.IsActive = 1) AS ProductCount
                           FROM Categories c ORDER BY c.CategoryID";
            return DBHelper.ExecuteQuery(sql);
        }

        // Lấy tất cả sản phẩm đang bán
        public static DataTable GetAllProducts()
        {
            string sql = @"SELECT p.ProductID, p.ProductName, p.Description, p.Price, p.Stock, p.ImageURL,
                           p.CategoryID, c.CategoryName
                           FROM Products p
                           INNER JOIN Categories c ON p.CategoryID = c.CategoryID
                           WHERE p.IsActive = 1
                           ORDER BY p.CreatedDate DESC";
            return DBHelper.ExecuteQuery(sql);
        }

        // Lấy sản phẩm theo danh mục
        public static DataTable GetProductsByCategory(int categoryId)
        {
            string sql = @"SELECT p.ProductID, p.ProductName, p.Description, p.Price, p.Stock, p.ImageURL,
                           p.CategoryID, c.CategoryName
                           FROM Products p
                           INNER JOIN Categories c ON p.CategoryID = c.CategoryID
                           WHERE p.IsActive = 1 AND p.CategoryID = @CategoryID
                           ORDER BY p.CreatedDate DESC";
            return DBHelper.ExecuteQuery(sql, new SqlParameter("@CategoryID", categoryId));
        }

        // Lấy sản phẩm theo ID (kèm thông số kỹ thuật chi tiết Specifications)
        public static DataRow GetProductById(int id)
        {
            string sql = @"SELECT p.ProductID, p.ProductName, p.Description, p.Specifications, p.Price, p.Stock, p.ImageURL,
                           p.CategoryID, c.CategoryName
                           FROM Products p
                           INNER JOIN Categories c ON p.CategoryID = c.CategoryID
                           WHERE p.ProductID = @ProductID";
            DataTable dt = DBHelper.ExecuteQuery(sql, new SqlParameter("@ProductID", id));
            if (dt.Rows.Count > 0) return dt.Rows[0];
            return null;
        }

        // Lấy danh sách 5 ảnh của sản phẩm
        public static DataTable GetProductImages(int productId)
        {
            string sql = @"SELECT ImageID, ProductID, ImageURL, Caption, DisplayOrder, IsMain
                           FROM ProductImages
                           WHERE ProductID = @ProductID
                           ORDER BY DisplayOrder ASC";
            return DBHelper.ExecuteQuery(sql, new SqlParameter("@ProductID", productId));
        }

        // Tìm kiếm sản phẩm (parameterized query chống SQL Injection)
        public static DataTable SearchProducts(string keyword)
        {
            return GetFilteredProducts(keyword, 0, "default", "all");
        }

        // Lấy sản phẩm liên quan (cùng danh mục, trừ SP hiện tại)
        public static DataTable GetRelatedProducts(int productId, int categoryId, int top = 4)
        {
            string sql = @"SELECT TOP (@Top) p.ProductID, p.ProductName, p.Price, p.ImageURL,
                           p.CategoryID, c.CategoryName
                           FROM Products p
                           INNER JOIN Categories c ON p.CategoryID = c.CategoryID
                           WHERE p.IsActive = 1 AND p.CategoryID = @CategoryID AND p.ProductID <> @ProductID
                           ORDER BY NEWID()";
            return DBHelper.ExecuteQuery(sql,
                new SqlParameter("@Top", top),
                new SqlParameter("@CategoryID", categoryId),
                new SqlParameter("@ProductID", productId));
        }

        // Lấy sản phẩm nổi bật (mới nhất)
        public static DataTable GetFeaturedProducts(int top = 8)
        {
            string sql = @"SELECT TOP (@Top) p.ProductID, p.ProductName, p.Price, p.Stock, p.ImageURL,
                           p.CategoryID, c.CategoryName
                           FROM Products p
                           INNER JOIN Categories c ON p.CategoryID = c.CategoryID
                           WHERE p.IsActive = 1
                           ORDER BY p.CreatedDate DESC";
            return DBHelper.ExecuteQuery(sql, new SqlParameter("@Top", top));
        }

        // Lấy sản phẩm có sắp xếp (tương thích ngược)
        public static DataTable GetProductsSorted(int categoryId, string sortBy)
        {
            return GetFilteredProducts("", categoryId, sortBy, "all");
        }

        /// <summary>
        /// Bộ lọc và tìm kiếm sản phẩm toàn diện theo phương thức HTTP GET
        /// Hỗ trợ tìm kiếm từ khóa, lọc theo danh mục, lọc theo mức giá và sắp xếp
        /// Sử dụng 100% SqlParameter để chống SQL Injection
        /// </summary>
        public static DataTable GetFilteredProducts(string keyword, int categoryId, string sortBy, string priceRange = "all")
        {
            List<SqlParameter> parameters = new List<SqlParameter>();
            List<string> whereConditions = new List<string>();

            // Luôn lọc sản phẩm đang kích hoạt kinh doanh
            whereConditions.Add("p.IsActive = 1");

            // 1. Lọc theo Danh mục (GET param: cat)
            if (categoryId > 0)
            {
                whereConditions.Add("p.CategoryID = @CategoryID");
                parameters.Add(new SqlParameter("@CategoryID", categoryId));
            }

            // 2. Tìm kiếm theo Từ khóa (GET param: q)
            if (!string.IsNullOrWhiteSpace(keyword))
            {
                whereConditions.Add("(p.ProductName LIKE @Keyword OR p.Description LIKE @Keyword)");
                parameters.Add(new SqlParameter("@Keyword", "%" + keyword.Trim() + "%"));
            }

            // 3. Lọc theo Khoảng giá (GET param: price)
            if (!string.IsNullOrEmpty(priceRange) && priceRange != "all")
            {
                switch (priceRange)
                {
                    case "under-500k":
                        whereConditions.Add("p.Price < 500000");
                        break;
                    case "500k-1m":
                        whereConditions.Add("p.Price >= 500000 AND p.Price <= 1000000");
                        break;
                    case "1m-2m":
                        whereConditions.Add("p.Price > 1000000 AND p.Price <= 2000000");
                        break;
                    case "over-2m":
                        whereConditions.Add("p.Price > 2000000");
                        break;
                }
            }

            // 4. Sắp xếp kết quả (GET param: sort)
            string orderClause;
            switch (sortBy)
            {
                case "price-asc":
                    orderClause = "p.Price ASC";
                    break;
                case "price-desc":
                    orderClause = "p.Price DESC";
                    break;
                case "name":
                    orderClause = "p.ProductName ASC";
                    break;
                default:
                    orderClause = "p.CreatedDate DESC";
                    break;
            }

            string whereClause = string.Join(" AND ", whereConditions);

            string sql = string.Format(@"SELECT p.ProductID, p.ProductName, p.Description, p.Price, p.Stock, p.ImageURL,
                           p.CategoryID, c.CategoryName
                           FROM Products p
                           INNER JOIN Categories c ON p.CategoryID = c.CategoryID
                           WHERE {0}
                           ORDER BY {1}", whereClause, orderClause);

            return DBHelper.ExecuteQuery(sql, parameters.ToArray());
        }
    }
}