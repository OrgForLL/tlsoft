﻿<%@ Page Language="C#" ContentType="text/html" ResponseEncoding="utf-8" Debug="true"
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

    protected void Page_Load(object sender, EventArgs e)
    {
      
        if (Page.IsPostBack)
        {
            if (textinput2.Value != "" && textinput3.Value != "")
            {
                IDataReader reader = (IDataReader)sqlHelp.MyDataRead(sqlHelp.GetConn(), "select * from wx_t_hyxx where zh='" + textinput2.Value + "' and secret='" + textinput3.Value + "'");
                if (reader.Read())
                {
                    Server.Transfer("wxhyxx.aspx?zh='" + textinput2.Value + "'");
                }
                else { LabelMsg.Text = "账号或密码错误！"; }
            }
            else 
            { 
                LabelMsg.Text = "请把信息维护完整！"; 
            }
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
         myform.submit();
     }
</script>
<body>
    <form id="myform" runat="server">
    <!-- Home -->
    <div id="page1" data-role="page">
               
        <div data-role="content">
            <div style="font-size:12px; padding-bottom:10px; margin-bottom:20px; border-bottom:#999 1px solid">
             用户登陆
            </div>
               <div data-role="collapsible-set">
                <ul data-role="listview" data-inset="true">
                 <li data-role="fieldcontain">
                <label for="textinput2" style="font-size:12px">
                    会员账号
                </label>
                <input name=""   id="textinput2" placeholder="" value="" type="text" runat="server" data-mini="true">
                <label for="textinput3" style="font-size:12px">
                   密 码
                </label>
                <input name=""   id="textinput3" placeholder="" value="" type="password" runat="server" data-mini="true">
            </li>
      </ul>
       <a data-role="button" id="goSubmitData" data-inline="true" href="#page1" data-icon="check"
        data-iconpos="left" onclick="button()">
            登陆
        </a>
       </div>
            <div data-role="fieldcontain">               
                
                <div>
                     <a href="wxhyxxzc.aspx" data-transition="fade">
                     立即注册
                      </a>
                </div>

            </div>
        </div>
            <div>
        <asp:Label ID="LabelMsg" runat="server" Text=""></asp:Label>
      </div>
    </div>
    </form>
</body>
</html>
