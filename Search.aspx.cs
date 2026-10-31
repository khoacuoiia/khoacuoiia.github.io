using System;
using System.Data;
using System.Web.UI;
using Gearzone.Helpers;

namespace Gearzone
{
    public partial class Search : Page
    {
        protected void Page_Load(object sender, EventArgs e)
        {
            if (!IsPostBack)
            {
                string keyword = Request.QueryString["q"];
                if (!string.IsNullOrEmpty(keyword))
                {
                    keyword = keyword.Trim();
                    Page.Title = "Tìm kiếm: " + keyword;
                    DataTable results = ProductData.SearchProducts(keyword);

                    if (results.Rows.Count > 0)
                    {
                        lblSearchInfo.Text = string.Format("Tìm thấy {0} sản phẩm cho \"{1}\"", results.Rows.Count, Server.HtmlEncode(keyword));
                        rptSearchResults.DataSource = results;
                        rptSearchResults.DataBind();
                    }
                    else
                    {
                        lblSearchInfo.Text = string.Format("Không tìm thấy sản phẩm nào cho \"{0}\"", Server.HtmlEncode(keyword));
                        pnlNoResults.Visible = true;
                    }
                }
                else
                {
                    lblSearchInfo.Text = "Vui lòng nhập từ khóa tìm kiếm.";
                    pnlNoResults.Visible = true;
                }
            }
        }
    }
}
