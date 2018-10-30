using System;
using System.Collections.Generic;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;

public partial class project_OfficeDaily_Default : System.Web.UI.Page
{
    protected void Page_Load(object sender, EventArgs e)
    {
        DateTime now = DateTime.Now;
        Response.Write(String.Format(@"select 1 from tb_inf where accountno={0} and consumedate>='{1:yyyy-MM-dd}' and SchNo = {2}", 111, now, 1));
    }
}