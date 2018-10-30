<%@ Page Language="C#" %>

<%@ Import Namespace="System.Data" %>
<%@ Import Namespace="System.Data.SqlClient" %>
<%@ Import Namespace="Newtonsoft.Json" %>
<%@ Import Namespace="System.Collections.Generic" %>
<%@ Import Namespace="nrWebClass" %>
<script runat="server">
    public string jrecords = "";
    protected void Page_Load(object sender, EventArgs e)
    {
        string userid = "0";
        if (string.IsNullOrEmpty(Convert.ToString(Session["qy_customersid"])))
        {
            if (clsWXHelper.CheckQYUserAuth(true))
            {
                userid = Convert.ToString(Session["qy_customersid"]);
            }
            else
            {
                clsSharedHelper.WriteErrorInfo("鉴权失败，无法获取用户信息");
            }
        }
        userid = Convert.ToString(Session["qy_customersid"]);
        string accountNo = getAccountNo(userid);
        jrecords = getCardRecord(accountNo);
        if (jrecords == "[]") clsSharedHelper.WriteInfo("未找到任何报餐记录");
        // clsSharedHelper.WriteInfo(jrecords);
    }
    //获取最近100条消费记录
    private string getCardRecord(string accountNo)
    {
        string mysql, errInfo, rt;
        DataTable dt;
        using (LiLanzDALForXLM dal = new LiLanzDALForXLM(clsConfig.GetConfigValue("OAConnStr")))
        {
            mysql = "SELECT TOP 100  CONVERT(VARCHAR(20),ConsumeTime,20) as time,datename(weekday,ConsumeTime) as week,CAST(ConsumeMoney AS  VARCHAR(10)) as amount FROM  cy_t_consumerecords  WHERE AccountNo=@AccountNo ORDER BY ConsumeTime DESC";
            List<SqlParameter> paras = new List<SqlParameter>();
            paras.Add(new SqlParameter("@AccountNo", accountNo));
            errInfo = dal.ExecuteQuerySecurity(mysql, paras, out dt);
            if (errInfo != "") clsWXHelper.ShowError(errInfo);
            rt = JsonConvert.SerializeObject(dt);
            clsSharedHelper.DisponseDataTable(ref dt);
        }
        return rt;
    }
    //获取餐卡账号
    private string getAccountNo(string userid)
    {
        string mysql, errInfo;
        DataTable dt;
        using (LiLanzDALForXLM dal = new LiLanzDALForXLM(clsConfig.GetConfigValue("WXConnStr")))
        {
            mysql = "SELECT b.SystemKey as accountNo FROM dbo.wx_t_customers a INNER JOIN dbo.wx_t_AppAuthorized b ON a.id=b.UserID AND b.SystemID=5 WHERE a.id=@userid;";
            List<SqlParameter> paras = new List<SqlParameter>();
            paras.Add(new SqlParameter("@userid", userid));
            errInfo = dal.ExecuteQuerySecurity(mysql, paras, out dt);
            if (errInfo != "") clsWXHelper.ShowError(errInfo);
            if (dt.Rows.Count < 1) clsWXHelper.ShowError("用户信息不存在");
            string accountNo = Convert.ToString(dt.Rows[0]["accountNo"]);
            clsSharedHelper.DisponseDataTable(ref dt);
            return accountNo;
        }
    }
</script>
<!DOCTYPE html>
<html>
<head>
    <meta charset="utf-8" />
    <meta name="viewport" content="width=device-width,initial-scale=1,user-scalable=0,maximum-scale=1" />
    <meta name="format-detection" content="telephone=no" />
    <meta name="apple-mobile-web-app-capable" content="yes" />
    <meta name="apple-mobile-web-app-status-bar-style" content="black" />
    <title>食堂刷卡消费记录</title>
    <style>
        * {
            margin: 0;
            padding: 0;
            -webkit-box-sizing: border-box;
            -moz-box-sizing: border-box;
            box-sizing: border-box;
        }

        html {
            -webkit-tap-highlight-color: transparent
        }

        ul {
            list-style: none;
        }

        a {
            text-decoration: none;
        }


        body {
            font-family: Helvetica, Arial, STHeiTi, "Hiragino Sans GB", "Microsoft Yahei", "微软雅黑", STHeiti, "华文细黑", sans-serif;
            font-size: 14px;
            color: #4b4b4b;

        }

        .table-head-wrap {
            position: absolute;
            top: 0;
            left: 0;
            right: 0;
            height: 64px;
            background: #fff;
            box-shadow: 0 2px 10px #eee;
            -webkit-box-shadow: 0 2px 10px #eee;
        }

        .title {
            font-size: 12px;
            color: #5d6c88;
            text-align: center;
            font-style: italic;
            line-height: 1;
            padding-bottom: 12px;
            background: #f3f3f3;
        }

        .table-head-wrap table,
        .table-con-wrap table {
            width: 100%;

        }

        .table-head-wrap table {
            line-height: 40px;
        }

        .table-head-wrap table td {
            text-align: center;
            font-weight: 600;
            color: #8d9096;
            font-size: 15px;
            height: 40px;
        }

        table .col1 {
            width: 40%;
        }

        table .col2,
        table .col3 {
            width: 30%;
        }

        .table-con-wrap {
            position: absolute;
            top: 67px;
            bottom: 0;
            left: 0;
            right: 0;
            overflow-y: auto;
            overflow-x: hidden;
            -webkit-overflow-scrolling: touch;
        }

        .table-con-wrap table td {
            text-align: center;
            padding: 10px 0;
            border-bottom: 1px solid #f1f4f9;
            color: #606266;
        }

        .table-con-wrap table tr:nth-child(even) {
            background: #f3f5fa;
        }
    </style>
</head>

<body>
    <div class="table-head-wrap">
        <p class="title">Canteen Card Consumption Records</p>
        <table cellpadding="0" cellspacing="0">
            <thead>
                <tr>
                    <td class="col1">消费时间</td>
                    <td class="col2">星期</td>
                    <td class="col3">消费金额</td>
                </tr>
            </thead>
        </table>
    </div>
    <div class="table-con-wrap">
        <table cellpadding="0" cellspacing="0">
            <tbody>
                <tr>
                    <td class="col1">2017-08-17 18:44:45</td>
                    <td class="col2">星期四</td>
                    <td class="col3">7.00</td>
                </tr>
                
            </tbody>
        </table>
    </div>

    <script type="text/javascript" src="../../res/js/jquery.js"></script>
    <script type="text/javascript" src="../../res/js/LeeJSUtils.min.js"></script>
    <script>
        $(function () {
            LeeJSUtils.stopOutOfPage(".table-con-wrap", true);
        })
    </script>
</body>
<script>
    window.onload = function () {
        $("table tbody").html("");
        var trstr = "<tr> <td class='col1'>#time</td><td class='col2'>#week</td><td class='col3'>#amount</td></tr>";
        var jsonstr =<%=jrecords%>;
        var html = "";
        for (var i = 0; i < jsonstr.length; i++) {
            html += trstr.replace("#time", jsonstr[i].time).replace("#week", jsonstr[i].week).replace("#amount", jsonstr[i].amount);
        }
        $("table tbody").html(html);
      }
</script>
</html>
