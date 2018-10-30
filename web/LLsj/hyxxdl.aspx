<%@ Page Language="C#" ContentType="text/html" ResponseEncoding="utf-8" Debug="true"
    EnableViewState="false" %>

<%@ Import Namespace="System.Data" %>
<%@ Import Namespace="System.Data.SqlClient" %>
<%@ Import Namespace="System.IO" %>
<%@ Import Namespace="System.Xml" %>
<%@ Import Namespace="System.Data.Common" %>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<script runat="server">
    TLBaseData._MyData sqlHelp = new TLBaseData._MyData();
    public StringBuilder STR = new StringBuilder();
    //string textinput2, textinput3;
    string err = "";
    int a = 1;

    protected void Page_Load(object sender, EventArgs e)
    {
        //sqlHelp.GetConn(tzid.ToString());

        //IDataReader reader = (IDataReader)sqlHelp.MyDataRead(sqlHelp.GetConn(), "select TOP 5 ID from T_USER");
        // while (reader.Read())
        //  {
        //   STR.AppendFormat("<li>{0}</li>", reader[0]);
        //  }
        //DataSet ds = (DataSet)sqlHelp.MyDataSet(sqlHelp.GetConn(), "select * from ....");
        //////执行语句
        //sqlHelp.MyDataTrans(sqlHelp.GetConn(), "INSERT INTO wx_t_hyxx (zh,secret, wxid) values (1,1,1)");
        if (!Page.IsPostBack)
        {
            //Response.Write("aaa");
        }
        else
        {
            //for (int i = 0; i < Request.Form.AllKeys.Length; i++)
            //{
            //    Response.Write(Request.Form.AllKeys[i] + ":" + Request.Form[i] + "</br>");
            //}

            IDataReader reader = (IDataReader)sqlHelp.MyDataRead(sqlHelp.GetConn(), "select count(1) from wx_t_hyxx where zh='" + textinput2.Value + "' and secret='" + textinput3.Value + "'");
            if (reader.Read() != null)
            {

                Server.Transfer("hyxx.aspx?zh='" + textinput2.Value + "'");
            }
            else { err = "erro()"; }

        }
    }
      
  
   
    
</script>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
    <meta charset="utf-8">
    <!-- Need to get a proper redirect hooked up. Blech. -->
    <meta name="robots" content="noindex, follow">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title></title>
    <link rel="stylesheet" href="css/themes/default/jquery.mobile-1.3.1.min.css">
    <link rel="stylesheet" href="http://fonts.googleapis.com/css?family=Open+Sans:300,400,700">
    <script src="js/jquery.js"></script>
    <script src="js/jquery.mobile-1.3.1.min.js"></script>
    <style type="text/css">
        div .test
        {
            text-align: center;
        }
       
    </style>
</head>
<script language="javascript">
     function button() {
         //TLBaseData._MyData sqlHelp = new TLBaseData._MyData();
         // public StringBuilder STR = new StringBuilder();
         //    sqlHelp.MyDataTrans(sqlHelp.GetConn(), "INSERT INTO wx_t_hyxx (zh,secret, wxid) values (1,1,1)");
         //document.getElementById("s_textinput2").value = document.getElementById("textinput2").value;
         //document.getElementById("s_textinput3").value = document.getElementById("textinput3").value;
         myform.submit();
     }
     $(document).ready(function(){
        <%=err %>
     });   
     
     
     function erro() {
         alert("会员账号重复！");
     }
</script>
<body>
    <form id="myform" runat="server">
    <!-- Home -->
    <div id="page1" data-role="page">
        <div data-role="header" data-theme="a">
            <h3>
                利郎微信平台
            </h3>
        </div>
        <div>
              <label id="lable" type="text">
                    用户登录
                </label>
        </div>
        <div data-role="content">
            <div data-role="fieldcontain">
                
                <label for="textinput2">
                    会员账号
                </label>
                <input id="textinput2"   type="text" runat="server" placeholder="" visible="True">
                <label for="textinput3">
                    密 码
                </label>
                <input id="textinput3"  type="password" runat="server" placeholder="">
                <a href="#page1" data-role="button" data-theme="b" id="button" onclick="button()">
                    登录 </a>
                <div>
                     <a href="hyxxzc.aspx" data-transition="fade">
                     立即注册
                      </a>
                </div>

            </div>
        </div>
        <div data-role="footer" data-theme="a" data-position="fixed">
            <h3>触屏版|高清版
            </h3>
        </div>
    </div>
    </form>
</body>
</html>
