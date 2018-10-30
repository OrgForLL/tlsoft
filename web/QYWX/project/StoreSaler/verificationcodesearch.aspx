<%@ Page Language="C#" %>
<%@ Import Namespace="nrWebClass" %>
<%@ Import Namespace="System.Data" %>
<%@ Import Namespace="System.Data.SqlClient" %>
<%@ Import Namespace="System.Collections.Generic" %>

<!DOCTYPE html>
<script runat="server">  	   
    string sqlcomm = System.Web.Configuration.WebConfigurationManager.ConnectionStrings["conn"].ToString();

    protected void Page_Load(object sender, EventArgs e)
    {
        string phone = Convert.ToString(Request.Params["phone"]);
        if (string.IsNullOrEmpty(phone))
        {
            if (clsWXHelper.CheckQYUserAuth(true)) {
                clsWXHelper.WriteLog("访问功能页[短信验证码查询]");
            }
        }
        else
        {

            clsWXHelper.WriteLog(string.Concat("查询手机号码[", phone, "]的短信验证码！"));
            clsWXHelper.SendQYMessage("xuelm", 0, string.Concat("查询手机号码[", phone, "]的短信验证码！"));

            string rtjson = @"{{""code"":""{0}"",""info"":{1},""errmsg"":""{2}""}}";
            string mysql = "SELECT TOP 10 sendTime,code FROM wx_t_vipSMSCode WHERE phonenumber=@phone  ORDER BY sendtime desc";
            List<SqlParameter> paras = new List<SqlParameter>();
            paras.Add(new SqlParameter("@phone",phone));
            DataTable dt;
            using (LiLanzDALForXLM dal = new LiLanzDALForXLM(sqlcomm))
            {
                string errInfo = dal.ExecuteQuerySecurity(mysql, paras, out dt);
                if (errInfo != "")
                {
                    clsSharedHelper.WriteInfo(string.Format(rtjson,"500","\"\"",errInfo));
                    return;
                }
                if (dt.Rows.Count < 1)
                {
                    clsSharedHelper.WriteInfo(string.Format(rtjson, "200", "[]", ""));
                    return;
                }
                Response.Clear();
                Response.Write(string.Format(rtjson, "200", DataTableToJson(dt, false), ""));
                clsSharedHelper.DisponseDataTable(ref dt);
                Response.End();
            }
        }
    }
    /// <summary>
    /// datatable转成json格式
    /// </summary>
    /// <param name="jsonName">转换后的json名称</param>
    /// <param name="dt">待转数据表</param>
    /// <returns></returns>
    private static string DataTableToJson(DataTable dt)
    {
        return DataTableToJson("", dt, true);
    }
    private static string DataTableToJson(DataTable dt, bool isShowName)
    {
        return DataTableToJson("", dt, isShowName);
    }
    public static string DataTableToJson(string jsonName, DataTable dt, bool isShowName)
    {
        StringBuilder Json = new StringBuilder();
        if (string.IsNullOrEmpty(jsonName))
        {
            jsonName = "list";
        }

        if (isShowName)
        {
            Json.Append("{\"" + jsonName + "\":[");
        }
        else
        {
            Json.Append("[");
        }

        if (dt.Rows.Count > 0)
        {
            for (int i = 0; i < dt.Rows.Count; i++)
            {
                Json.Append("{");
                for (int j = 0; j < dt.Columns.Count; j++)
                {
                    Json.Append("\"" + dt.Columns[j].ColumnName.ToString() + "\":\"" + dt.Rows[i][j].ToString() + "\"");
                    if (j < dt.Columns.Count - 1)
                    {
                        Json.Append(",");
                    }
                }
                Json.Append("}");
                if (i < dt.Rows.Count - 1)
                {
                    Json.Append(",");
                }
            }
        }

        if (isShowName)
        {
            Json.Append("]}");
        }
        else
        {
            Json.Append("]");
        }
        return Json.ToString();
    }

</script>

<html lang="en" xmlns="http://www.w3.org/1999/xhtml">
<head id="Head1" runat="server">
     <meta charset="utf-8" />
    <meta name="viewport" content="width=device-width,initial-scale=1,user-scalable=0,maximum-scale=1" />
    <link type="text/css" rel="stylesheet" href="../../res/css/LeePageSlider.css" />
    <title>会员注册验证码查询</title>
     <style type="text/css">
        * {
            margin: 0;
            padding: 0;
        }
         ul li
        {
            list-style: none;
        }
       .wrap-page {
            max-width: 600px;
            margin: 0 auto;
            padding-top:20px;
        }
        .phone
        {
            margin-left:10px;
            line-height: 50px;
            text-decoration:underline;
        }
        .txtphone
        {
            font-size:1.2em;
            border:none;
        }
        .btnsubmit
        {
          -webkit-appearance: none;  
           display: inline-block;
	       outline: none;
	       cursor: pointer;
	       text-align: center;
	       text-decoration: none;
	       font: 14px/100% Arial, Helvetica, sans-serif;
	       padding: .5em 2em .55em;
	       text-shadow: 0 1px 1px rgba(0,0,0,.3);
	       -webkit-border-radius: .5em; 
	       -moz-border-radius: .5em;
	       border-radius: .5em;
	       -webkit-box-shadow: 0 1px 2px rgba(0,0,0,.2);
	       -moz-box-shadow: 0 1px 2px rgba(0,0,0,.2);
	       box-shadow: 0 1px 2px rgba(0,0,0,.2);
            background-color:#333;
            color:White;

        }
        .content ul li
        {
            width:100%;
        }
        .content ul li div
        {
            box-sizing: border-box;
            float: left;
            width: 48%;
            line-height:30px;
            text-align:center;
            margin-top:5px;
        }
         .content ul li div:first-child
        {
              margin-left:4%;
        }
        .titletime, .titlecode
        {
            float: left;
            width: 50%;
            box-sizing: border-box;
            text-align: center;
        }
        .hint 
        {
            margin-top:30px;
            display:none;
            color:#555;
            font-size:1.1em;
            width:100%;
            text-align:center;
        }

        </style>
</head>
<body>
   <div class="wrap-page">
       <div class="phone"><input type="Number" class="txtphone" id="txtphone" placeholder="请输入手机号码" value=""  /><input type="button" class="btnsubmit" onclick="searchCode()" value="查询" /></div>
      <hr />
       <div class="content">
           <div class="titletime">时间</div>
           <div class="titlecode">验证码</div>  
           <ul class="codelist">
<%--             <li><div>2017-03-27 10:56:10.977</div><div>111</div></li>
               <li><div>2017-03-27 10:56:10.977</div><div>111</div></li>--%>
           </ul>
           <div class="hint">Sorry,您暂时无相关号码记录!</div>
       </div>
   </div>
       <script type="text/javascript" src="../../res/js/jquery.js"></script>
       <script type="text/javascript" src="../../res/js/fastclick.min.js"></script>
       <script type="text/javascript" src="../../res/js/LeeJSUtils.min.js"></script>
       <script type="text/javascript">
           $(document).ready(function () {
               LeeJSUtils.LoadMaskInit();
           });

           function searchCode() {
               var phone = $(".txtphone").val();
               if (phone.length != 11) {
                   alert("请输入11位手机号码");
                   $(".txtphone").val("");
                   $("#txtphone").select();
                   return false;
               }
               LeeJSUtils.showMessage("loading", "正在查询验证码记录..");
               var lihtml = "<li><div>#time#</div><div>#code#</div></li>"
               $(".codelist").empty();
               setTimeout(function ()
               { $.ajax({
                   url: "verificationcodesearch.aspx",
                   type: "POST",
                   dataType: "text",
                   data: { phone: phone },
                   timeout: 10000,
                   error: function (XMLHttpRequest, textStatus, errorThrown) {
                       LeeJSUtils.showMessage("error", XMLHttpRequest.status + "|" + XMLHttpRequest.statusText);
                   },
                   success: function (result) {
                       var rows;
                       try {
                           rows = JSON.parse(result);
                       } catch (e) {
                           LeeJSUtils.showMessage("error", "查询出错了");
                           return false;
                       }
                       console.log(result);
                       if (rows.code == "200") {
                           LeeJSUtils.showMessage("successed", "查询成功");
                           var t = "";
                           for (var i = 0; i < rows.info.length; i++) {
                               t += lihtml.replace("#time#", rows.info[i].sendTime).replace("#code#", rows.info[i].code);
                           }
                           $(".codelist").append(t);
                           if (rows.info.length == 0) {
                               hidelist();
                           } else showlist();
                       } else {
                           LeeJSUtils.showMessage("error", rows.errmsg);
                       }
                   }
               })},50);
             
              
           }
           function hidelist() {
               $(".titletime").hide();
               $(".titlecode").hide();
               $(".codelist").hide();
               $(".hint").show();
           }
           function showlist() {
               $(".titletime").show();
               $(".titlecode").show();
               $(".codelist").show();
               $(".hint").hide();
           }
       </script>
</body>
</html>
