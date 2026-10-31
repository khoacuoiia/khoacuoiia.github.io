using System;
using System.Web.UI;
using Gearzone.Helpers;

namespace Gearzone
{
    public partial class Categories : Page
    {
        protected void Page_Load(object sender, EventArgs e)
        {
            if (!IsPostBack)
            {
                rptCategories.DataSource = ProductData.GetCategories();
                rptCategories.DataBind();
            }
        }
    }
}
