using System;
using System.Data;
using System.Text;
using System.Web.UI;
using Gearzone.Helpers;

namespace Gearzone
{
    public partial class ProductDetail : Page
    {
        private int productId = 0;

        protected void Page_Load(object sender, EventArgs e)
        {
            if (Request.QueryString["id"] != null)
            {
                int.TryParse(Request.QueryString["id"], out productId);
            }
            if (!IsPostBack)
            {
                LoadProduct();
            }
        }

        private void LoadProduct()
        {
            if (productId <= 0)
            {
                pnlProduct.Visible = false;
                pnlNotFound.Visible = true;
                return;
            }

            DataRow product = ProductData.GetProductById(productId);
            if (product == null)
            {
                pnlProduct.Visible = false;
                pnlNotFound.Visible = true;
                return;
            }

            Page.Title = product["ProductName"].ToString() + " - GearZone";
            imgProduct.ImageUrl = product["ImageURL"].ToString();
            imgProduct.AlternateText = product["ProductName"].ToString();
            lblProductName.Text = product["ProductName"].ToString();
            lblBreadcrumb.Text = product["ProductName"].ToString();
            lblCategory.Text = product["CategoryName"].ToString();
            lblPrice.Text = string.Format("{0:N0}", product["Price"]);

            // Format mô tả chi tiết thành các đoạn văn đẹp
            string rawDesc = product["Description"] != null ? product["Description"].ToString() : "";
            litDescription.Text = FormatDescription(rawDesc);

            // Format bảng thông số kỹ thuật chi tiết
            string rawSpecs = product.Table.Columns.Contains("Specifications") && product["Specifications"] != DBNull.Value
                ? product["Specifications"].ToString()
                : "";
            litSpecifications.Text = FormatSpecifications(rawSpecs);

            // Load 5 ảnh vào thumbnail gallery
            DataTable dtImages = ProductData.GetProductImages(productId);
            if (dtImages != null && dtImages.Rows.Count > 0)
            {
                rptThumbnails.DataSource = dtImages;
                rptThumbnails.DataBind();
            }

            // Tình trạng kho hàng
            int stock = Convert.ToInt32(product["Stock"]);
            if (stock > 0)
            {
                lblStock.Text = "Còn hàng (" + stock + " sản phẩm sẵn sàng giao)";
                lblStock.ForeColor = System.Drawing.ColorTranslator.FromHtml("#16a34a");
            }
            else
            {
                lblStock.Text = "Hết hàng tạm thời";
                lblStock.ForeColor = System.Drawing.ColorTranslator.FromHtml("#dc2626");
                btnAddToCart.Enabled = false;
            }

            // Sản phẩm liên quan
            int catId = Convert.ToInt32(product["CategoryID"]);
            DataTable related = ProductData.GetRelatedProducts(productId, catId);
            if (related.Rows.Count > 0)
            {
                rptRelated.DataSource = related;
                rptRelated.DataBind();
                pnlRelated.Visible = true;
            }
            else
            {
                pnlRelated.Visible = false;
            }
        }

        private string FormatDescription(string text)
        {
            if (string.IsNullOrWhiteSpace(text)) return "<p>Chưa có mô tả chi tiết cho sản phẩm này.</p>";

            string[] paragraphs = text.Split(new[] { "\r\n\r\n", "\n\n" }, StringSplitOptions.RemoveEmptyEntries);
            StringBuilder sb = new StringBuilder();
            foreach (string p in paragraphs)
            {
                string cleanP = p.Trim().Replace("\r\n", "<br/>").Replace("\n", "<br/>");
                if (!string.IsNullOrWhiteSpace(cleanP))
                {
                    sb.Append("<p>").Append(cleanP).Append("</p>");
                }
            }
            return sb.ToString();
        }

        private string FormatSpecifications(string specs)
        {
            if (string.IsNullOrWhiteSpace(specs))
            {
                return "<tr><td colspan='2' style='text-align:center;color:#64748b;'>Đang cập nhật thông số kỹ thuật...</td></tr>";
            }

            string[] lines = specs.Split(new[] { "\r\n", "\n" }, StringSplitOptions.RemoveEmptyEntries);
            StringBuilder sb = new StringBuilder();

            foreach (string line in lines)
            {
                string trimmed = line.Trim();
                if (string.IsNullOrEmpty(trimmed)) continue;

                if (trimmed.Contains(":"))
                {
                    int colonIndex = trimmed.IndexOf(':');
                    string label = trimmed.Substring(0, colonIndex).Trim();
                    string val = trimmed.Substring(colonIndex + 1).Trim();

                    // Xử lý nếu là mục con bắt đầu bằng '+'
                    if (label.StartsWith("+"))
                    {
                        label = label.TrimStart('+', ' ');
                        sb.Append("<tr class='spec-subitem'>");
                        sb.Append("<td class='spec-label' style='padding-left:24px;'>").Append(Server.HtmlEncode(label)).Append("</td>");
                        sb.Append("<td class='spec-value'>").Append(Server.HtmlEncode(val)).Append("</td>");
                        sb.Append("</tr>");
                    }
                    else
                    {
                        sb.Append("<tr>");
                        sb.Append("<td class='spec-label'>").Append(Server.HtmlEncode(label)).Append("</td>");
                        sb.Append("<td class='spec-value'>").Append(Server.HtmlEncode(val)).Append("</td>");
                        sb.Append("</tr>");
                    }
                }
                else
                {
                    sb.Append("<tr>");
                    sb.Append("<td colspan='2' class='spec-subheading'>").Append(Server.HtmlEncode(trimmed)).Append("</td>");
                    sb.Append("</tr>");
                }
            }
            return sb.ToString();
        }

        protected void btnAddToCart_Click(object sender, EventArgs e)
        {
            DataRow product = ProductData.GetProductById(productId);
            if (product != null)
            {
                int qty = 1;
                int.TryParse(hdnQuantity.Value, out qty);
                if (qty < 1) qty = 1;

                CartHelper.AddToCart(
                    productId,
                    product["ProductName"].ToString(),
                    Convert.ToDecimal(product["Price"]),
                    product["ImageURL"].ToString(),
                    qty
                );
                Response.Redirect("Cart.aspx");
            }
        }
    }
}