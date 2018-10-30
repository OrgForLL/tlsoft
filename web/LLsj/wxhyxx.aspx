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
    int i;
    //Request.QueryString.Get("id").ToString();
    protected void Page_Load(object sender, EventArgs e)
    {
        string zh = Context.Request["zh"];
        IDataReader reader = (IDataReader)sqlHelp.MyDataRead(sqlHelp.GetConn(), "select zh,level,jf,je,bkrq from wx_t_hyxx where zh='czxllp'");
        while (reader.Read())
        {
            STR.AppendFormat("{0},{1},{2},{3},{4}", reader[0], reader[1], reader[2], reader[3], reader[4]);
        }
        string[] value = STR.ToString().Split(',');
        //double[] value = Array.ConvertAll<string, double>(STR.ToString().Substring(0, STR.Length - 1).Split(','), delegate(string s){ return double.Parse(s); });


            textinput3.Value = value[0].ToString();
            textinput4.Value = value[1].ToString();
            textinput5.Value = value[2].ToString();
            textinput6.Value = value[3].ToString();
            textinput7.Value = value[4].ToString();
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
  
<body>
   <form id="myform" runat="server">
<!-- Home -->

<div id="page1" data-role="page">  
    <div data-role="content">

          <div>
            <img style="width: 288px; height: 100px;" src="../LLsj/img/logo_LL0.gif">

        </div>
         <div style="font-size:12px; padding-bottom:10px; margin-bottom:20px; border-bottom:#999 1px solid">
          会员信息
        </div>
                <ul data-role="listview" data-inset="true">
            <li data-role="fieldcontain">
            <label for="textinput3" style="font-size:12px">
                会员卡号
            </label>
            <input id="textinput3"  runat="server" readOnly type="text" placeholder="" value="" data-mini="true">
            <label for="textinput4" style="font-size:12px">
                会员等级
            </label>
            <input id="textinput4" runat="server" readOnly type="text" placeholder="" value="" data-mini="true">
            <label for="textinput5" style="font-size:12px">
                会员积分
            </label>
            <input id="textinput5" runat="server" readOnly  type="text" placeholder="" value="" data-mini="true">
            <label for="textinput6" style="font-size:12px">
                会员储值
            </label>
            <input id="textinput6" runat="server"  readOnly  type="text" placeholder="" value="" data-mini="true">
            <label for="textinput7" style="font-size:12px">
                办卡日期
            </label>
            <input id="textinput7" runat="server" readOnly  type="text" placeholder="" value="" data-mini="true">
              
     </li>
      </ul>
       
    </div>
</div>
</form>
</body> 
</html>

