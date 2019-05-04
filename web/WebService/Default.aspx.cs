using System;
using System.Collections.Generic;
 
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;
 
public partial class tl_yf_Default : System.Web.UI.Page
{

    protected void Page_Load(object sender, EventArgs e)
        {
            if (Request.Files.Count > 0)
            {
                try
                {
                    //得到客户端上传的文件
                    HttpPostedFile file = Request.Files[0];
                    //服务器端要保存的路径
                    string filePath = "G:\\Test\\" + file.FileName + ".rtf";
                    file.SaveAs(filePath);
                    //返回结果
                    Response.Write("Success");
                }
                catch
                {
                    Response.Write("Error");
                }
            }
            else
            {
                Response.Write("Error1");
            } 
        }

}