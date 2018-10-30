using System;
using System.Collections.Generic;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;
using Newtonsoft.Json;
using System.Data;
public partial class wx_header : System.Web.UI.UserControl
{
    protected void Page_Load(object sender, EventArgs e)
    {
        string cid = Request.QueryString["cid"].ToString();
        DAL.SqlDbHelper dbHelper = new DAL.SqlDbHelper(cid);
        int vipid = 0;
        int.TryParse(Session["vipid"].ToString(),out vipid);
        if (vipid == 0)
        {
            Response.Redirect("vipBinging.aspx");
        }
    }
   
}