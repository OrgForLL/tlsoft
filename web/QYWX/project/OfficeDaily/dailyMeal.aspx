<%@ Page Language="C#" %>
<%@ Import Namespace="System.Data" %>
<%@ Import Namespace="System.Data.SqlClient" %>
<%@ Import Namespace="Newtonsoft.Json" %>
<%@ Import Namespace="System.Collections.Generic" %>
<%@ Import Namespace="nrWebClass" %>
<script runat="server">
    public string jMealRecord = "";
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
        jMealRecord = getMealRecord(accountNo);
      //     clsSharedHelper.WriteInfo(jMealRecord);
    }
    //获取最近100条报餐记录
    private string getMealRecord(string accountNo)
    {
        string mysql, errInfo, rt;
        DataTable dt;
        using (LiLanzDALForXLM dal = new LiLanzDALForXLM(clsConfig.GetConfigValue("OAConnStr")))
        {
            mysql = @"SELECT TOP 100 CONVERT(VARCHAR(10),StartDate,23)+' 至 '+CONVERT(VARCHAR(10),EndDate,23) AS date,a.ClassNo,'' className
                    FROM  xz_t_ygbcb a 
                    WHERE AccountNo=@AccountNo AND del=0 AND active=1
                    ORDER BY StartDate DESC";
            List<SqlParameter> paras = new List<SqlParameter>();
            paras.Add(new SqlParameter("@AccountNo", accountNo));
            errInfo = dal.ExecuteQuerySecurity(mysql, paras, out dt);
            if (errInfo != "") clsWXHelper.ShowError(errInfo);
            Dictionary<int, string> dClassName = getMealClass();
            foreach (DataRow dr in dt.Rows)
            {
                dr["className"] = dClassName[Convert.ToInt32(dr["ClassNo"])];
            }
            dt.Columns.Remove("ClassNo");
            rt = JsonConvert.SerializeObject(dt);
           clsSharedHelper.DisponseDataTable(ref dt);
        }
        return rt;
    }
    //获取报餐类型
    private Dictionary<int, string> getMealClass()
    {
        Dictionary<int, string> Dclass = new Dictionary<int, string>();
        string mysql, errInfo, rt;
        DataTable dt;
        using (LiLanzDALForXLM dal = new LiLanzDALForXLM(clsConfig.GetConfigValue("CFSF")))
        {
            mysql = "SELECT ClassNo,ClassName FROM dbo.tb_Class WHERE ClassName IS NOT NULL";
            errInfo = dal.ExecuteQuery(mysql, out dt);
            if (errInfo != "") clsWXHelper.ShowError(errInfo);
            foreach (DataRow dr in dt.Rows)
            {
                Dclass.Add(Convert.ToInt32(dr["ClassNo"]),Convert.ToString(dr["ClassName"]));
            }
            clsSharedHelper.DisponseDataTable(ref dt);
        }
        return Dclass;
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
    <title>食堂报餐记录</title>
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
            width: 55%;
        }

        table .col2 {
            width: 45%;
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
        <p class="title">Canteen Meal Records List</p>
        <table cellpadding="0" cellspacing="0">
            <thead>
                <tr>
                    <td class="col1">报餐日期</td>
                    <td class="col2">报餐类型</td>
                </tr>
            </thead>
        </table>
    </div>
    <div class="table-con-wrap">
        <table cellpadding="0" cellspacing="0">
            <tbody>
                <tr>
                    <td class="col1">2018-06-11至2018-06-17</td>
                    <td class="col2">午(11:50) + 晚</td>
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
        var trstr = "<tr> <td class='col1'>#date</td><td class='col2'>#className</td></tr>";
        var jsonstr =<%=jMealRecord%>;
        var html = "";
        for (var i = 0; i < jsonstr.length; i++) {
            html += trstr.replace("#date", jsonstr[i].date).replace("#className", jsonstr[i].className);
        }
        $("table tbody").html(html);
      }
</script>
</html>
