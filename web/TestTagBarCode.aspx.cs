using System;
using System.Collections.Generic;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;

public partial class TestTagBarCode : System.Web.UI.Page
{
    protected void Page_Load(object sender, EventArgs e)
    {
        TTagBarCode.TagBarCode tag = new TTagBarCode.TagBarCode();
        string t=tag.GetBarCode("12Q0704");
    }
}