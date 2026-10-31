using System;
using System.Collections.Generic;
using System.Data;
using System.Text;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;
using Gearzone.Helpers;

namespace Gearzone
{
    public partial class Products : Page
    {
        // Thuộc tính lưu trữ giá trị bộ lọc từ GET Request
        protected string CurrentKeyword = "";
        protected int CurrentCategoryId = 0;
        protected string CurrentSort = "default";
        protected string CurrentPrice = "all";

        protected void Page_Load(object sender, EventArgs e)
        {
            if (!IsPostBack)
            {
                // 1. Đọc tất cả các tham số từ phương thức HTTP GET (Request.QueryString)
                CurrentKeyword = (Request.QueryString["q"] ?? "").Trim();
                int.TryParse(Request.QueryString["cat"], out CurrentCategoryId);
                CurrentPrice = (Request.QueryString["price"] ?? "all").Trim().ToLower();
                CurrentSort = (Request.QueryString["sort"] ?? "default").Trim().ToLower();

                // 2. Nạp danh mục từ SQL Server
                LoadCategories();

                // 3. Khôi phục giá trị các bộ lọc trên giao diện
                txtSearch.Text = CurrentKeyword;

                if (ddlCategory.Items.FindByValue(CurrentCategoryId.ToString()) != null)
                {
                    ddlCategory.SelectedValue = CurrentCategoryId.ToString();
                }

                if (ddlPrice.Items.FindByValue(CurrentPrice) != null)
                {
                    ddlPrice.SelectedValue = CurrentPrice;
                }

                if (ddlSort.Items.FindByValue(CurrentSort) != null)
                {
                    ddlSort.SelectedValue = CurrentSort;
                }

                // 4. Hiển thị thông tin URL query hiện tại để minh chứng rõ ràng phương thức GET
                string rawQuery = Request.Url.Query;
                if (!string.IsNullOrEmpty(rawQuery))
                {
                    lblCurrentQuery.InnerText = rawQuery;
                }
                else
                {
                    lblCurrentQuery.InnerText = "(Không có tham số - hiển thị toàn bộ sản phẩm)";
                }

                // 5. Hiển thị huy hiệu (badges) các bộ lọc đang kích hoạt
                RenderActiveFilterBadges();

                // 6. Tải sản phẩm từ Database thông qua phương thức GET
                LoadProducts();
            }
        }

        private void LoadCategories()
        {
            DataTable categories = ProductData.GetCategories();
            foreach (DataRow row in categories.Rows)
            {
                string text = string.Format("{0} ({1})", row["CategoryName"], row["ProductCount"]);
                ddlCategory.Items.Add(new ListItem(text, row["CategoryID"].ToString()));
            }
        }

        private void LoadProducts()
        {
            DataTable products = ProductData.GetFilteredProducts(CurrentKeyword, CurrentCategoryId, CurrentSort, CurrentPrice);

            if (products.Rows.Count > 0)
            {
                rptProducts.DataSource = products;
                rptProducts.DataBind();
                lblProductCount.Text = string.Format("Tìm thấy <strong>{0}</strong> sản phẩm phù hợp", products.Rows.Count);
                pnlNoProducts.Visible = false;
            }
            else
            {
                rptProducts.DataSource = null;
                rptProducts.DataBind();
                lblProductCount.Text = "Không có sản phẩm nào khớp với bộ lọc.";
                pnlNoProducts.Visible = true;
            }
        }

        /// <summary>
        /// Tạo các thẻ badge xóa bộ lọc đang áp dụng dạng GET
        /// </summary>
        private void RenderActiveFilterBadges()
        {
            bool hasActiveFilter = false;
            StringBuilder sb = new StringBuilder();

            // Badge từ khóa
            if (!string.IsNullOrEmpty(CurrentKeyword))
            {
                hasActiveFilter = true;
                string removeUrl = BuildUrl(removeKey: "q");
                sb.AppendFormat("<span class=\"filter-badge\">Từ khóa: <strong>\"{0}\"</strong> <a href=\"{1}\" title=\"Bỏ lọc từ khóa\">&times;</a></span>",
                    Server.HtmlEncode(CurrentKeyword), removeUrl);
            }

            // Badge danh mục
            if (CurrentCategoryId > 0 && ddlCategory.SelectedItem != null)
            {
                hasActiveFilter = true;
                string catName = ddlCategory.SelectedItem.Text;
                int parenIdx = catName.IndexOf('(');
                if (parenIdx > 0) catName = catName.Substring(0, parenIdx).Trim();

                string removeUrl = BuildUrl(removeKey: "cat");
                sb.AppendFormat("<span class=\"filter-badge\">Danh mục: <strong>{0}</strong> <a href=\"{1}\" title=\"Bỏ lọc danh mục\">&times;</a></span>",
                    Server.HtmlEncode(catName), removeUrl);
            }

            // Badge mức giá
            if (!string.IsNullOrEmpty(CurrentPrice) && CurrentPrice != "all")
            {
                hasActiveFilter = true;
                string priceLabel = ddlPrice.SelectedItem != null ? ddlPrice.SelectedItem.Text : CurrentPrice;
                string removeUrl = BuildUrl(removeKey: "price");
                sb.AppendFormat("<span class=\"filter-badge\">Mức giá: <strong>{0}</strong> <a href=\"{1}\" title=\"Bỏ lọc giá\">&times;</a></span>",
                    Server.HtmlEncode(priceLabel), removeUrl);
            }

            // Badge sắp xếp (nếu khác mặc định)
            if (!string.IsNullOrEmpty(CurrentSort) && CurrentSort != "default")
            {
                hasActiveFilter = true;
                string sortLabel = ddlSort.SelectedItem != null ? ddlSort.SelectedItem.Text : CurrentSort;
                string removeUrl = BuildUrl(removeKey: "sort");
                sb.AppendFormat("<span class=\"filter-badge\">Sắp xếp: <strong>{0}</strong> <a href=\"{1}\" title=\"Bỏ sắp xếp\">&times;</a></span>",
                    Server.HtmlEncode(sortLabel), removeUrl);
            }

            if (hasActiveFilter)
            {
                sb.Append("<a href=\"Products.aspx\" class=\"filter-clear-all\">Xóa tất cả bộ lọc</a>");
                pnlActiveFilters.Visible = true;
                litFilterTags.Text = sb.ToString();
            }
            else
            {
                pnlActiveFilters.Visible = false;
            }
        }

        /// <summary>
        /// Tạo URL GET mới khi xóa một tham số lọc cụ thể
        /// </summary>
        private string BuildUrl(string removeKey)
        {
            List<string> parts = new List<string>();

            if (removeKey != "q" && !string.IsNullOrEmpty(CurrentKeyword))
                parts.Add("q=" + HttpUtility.UrlEncode(CurrentKeyword));

            if (removeKey != "cat" && CurrentCategoryId > 0)
                parts.Add("cat=" + CurrentCategoryId);

            if (removeKey != "price" && !string.IsNullOrEmpty(CurrentPrice) && CurrentPrice != "all")
                parts.Add("price=" + HttpUtility.UrlEncode(CurrentPrice));

            if (removeKey != "sort" && !string.IsNullOrEmpty(CurrentSort) && CurrentSort != "default")
                parts.Add("sort=" + HttpUtility.UrlEncode(CurrentSort));

            if (parts.Count > 0)
                return "Products.aspx?" + string.Join("&", parts);
            return "Products.aspx";
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

            CurrentKeyword = (Request.QueryString["q"] ?? "").Trim();
            int.TryParse(Request.QueryString["cat"], out CurrentCategoryId);
            CurrentPrice = (Request.QueryString["price"] ?? "all").Trim().ToLower();
            CurrentSort = (Request.QueryString["sort"] ?? "default").Trim().ToLower();
            LoadProducts();
        }
    }
}