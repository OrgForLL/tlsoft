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
    protected void Page_Load(object sender, EventArgs e)
    {
       
        if (IsPostBack)
        {
            if (TxtVipSn.Value != "" && TxtVerify.Value != "")
            {
                string sql = "";
                string sql2 = "";
                string id = "";
                string wx = "432432";
                //string wx = Context.Request["wx"];
                if (radioVipMobile.Checked)
                    sql = "select id from yx_t_vipkh where yddh='{0}'";
                else
                    sql = "select id from yx_t_vipkh where kh='{0}'";
                sql = string.Format(sql, TxtVipSn.Value);
                IDataReader reader = (IDataReader)sqlHelp.MyDataRead(sqlHelp.GetConn(), sql);
                if (reader.Read())
                {
                    id = reader[0].ToString();
                    sql2 = "select count(1) from wx_t_wxyhxx where vipid="+id+"";
                    IDataReader reader2 = (IDataReader)sqlHelp.MyDataRead(sqlHelp.GetConn(), sql);
                    if (!reader2.Read())
                    {
                        reader.Close();
                        reader.Dispose();
                        sql = "insert into wx_t_wxyhxx (wxid,vipid) values ('" + wx + "'," + id + ")";
                        sqlHelp.MyDataTrans(sqlHelp.GetConn(), sql);
                        if (radioVipMobile.Checked)
                            LabelMsg.Text = "手机绑定成功！";
                        else
                            LabelMsg.Text = "卡号绑定成功！";
                    }
                    else 
                    {
                        LabelMsg.Text = "已经绑定了，无法重复绑定！";
                    }
                }
                else
                {
                    LabelMsg.Text = "无该VIP用户信息。";
                }
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
    <meta name="robots" content="noindex, follow">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title>会员绑定</title>
    <link rel="stylesheet"  href="css/themes/default/jquery.mobile-1.3.1.min.css">
    <link rel="stylesheet" href="http://fonts.googleapis.com/css?family=Open+Sans:300,400,700">
    <script src="js/jquery.js"></script>
    <script src="js/jquery.mobile-1.3.1.min.js"></script>
    <style type="text/css">
	body{font-size:12px}
	</style>
</head>
<script language="javascript">
     function SubmitData() {
        myform.submit();

    }
   
</script>
<body>
  <form id="myform" runat="server">
<div data-role="page" id="page">
  <div data-role="content">
   
    <div style="font-size:12px; padding-bottom:10px; margin-bottom:20px; border-bottom:#999 1px solid">
    用户绑定
    </div>
    
    <div data-role="collapsible-set">
        <ul data-role="listview" data-inset="true">
            <li data-role="fieldcontain">
             <fieldset data-role="controlgroup" data-type="horizontal" data-mini="true">
                <legend style="font-size:12px">
                    绑定方式:
                </legend>
                <input id="radioVipSn" name="radio" runat="server" value="0" data-theme="c" type="radio" checked="true" >
                <label for="radioVipSn">
                    会员号
                </label>
                <input id="radioVipMobile" name="radio"  runat="server" value="1" data-theme="c" type="radio">
                <label for="radioVipMobile">
                    手机号码
                </label>
            </fieldset>
            </li>
             <li data-role="fieldcontain">
                 <div data-role="fieldcontain">
                    <label for="TxtVipSn"  style="font-size:12px">
                       会员号/手机：
                    </label>
                    <input name="TxtVipSn" runat="server"  id="TxtVipSn" placeholder="" value="" type="text" data-mini="true">
                </div>
            </li>
             <li data-role="fieldcontain">
                <label for="TxtVerify" style="font-size:12px">校验码 </label> <input name="TxtVerify" runat="server"   id="TxtVerify" placeholder="" value="" type="text" data-mini="true">
            </li>
        </ul>
         <a data-role="button" id="SubmitData" data-inline="true" href="#page1" data-icon="check"
        data-iconpos="left" onclick="SubmitData()">
            提交
        </a>
    </div>
    <div>
        <asp:Label ID="LabelMsg" runat="server" Text=""></asp:Label>
    </div>
</div>

</form>
</body>
</html>
