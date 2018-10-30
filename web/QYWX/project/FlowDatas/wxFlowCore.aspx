<%@ Page Language="C#" Debug="true"%>
<%@ Import Namespace="nrWebClass" %>
<%@ Import Namespace="Newtonsoft.Json" %>
<%@ Import Namespace="System.Data" %>
<%@ Import Namespace="System.Data.SqlClient" %>
<%@ Import Namespace="System.Collections.Generic" %>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">

<script runat="server">
    string OAConnStr = "server=192.168.35.10;uid=ABEASD14AD;pwd=+AuDkDew;database=tlsoft";
    string WXDBConStr = "Data Source=192.168.35.62;Initial Catalog=weChatPromotion;User ID=erpUser;password=fjKL29ji.353";
    protected void Page_Load(object sender, EventArgs e)
    {
        string ksrq = Convert.ToString(Request.Params["ksrq"]);
        string jsrq = Convert.ToString(Request.Params["jsrq"]);
        string khmc = Convert.ToString(Request.Params["khmc"]);
        string parentid = Convert.ToString(Request.Params["parentid"]);
        string orderSort = Convert.ToString(Request.Params["orderSort"]);
        DateTime myksrq,myjsrq;
        if (!DateTime.TryParse(ksrq, out myksrq) || !DateTime.TryParse(jsrq, out myjsrq))
        {
            clsSharedHelper.WriteErrorInfo("请使用正确的日期！");
            return;
        }

        if (string.IsNullOrEmpty(parentid))
        {
            clsSharedHelper.WriteErrorInfo("非法访问");
            return;
        }
        string errInfo, mysql,sql_tj="";
        DataTable dt_dept,dt_wxrs,dt_logr;
        Dictionary<int,int> Duser = new Dictionary<int, int>();
        Dictionary<int, int> DKhNum = new Dictionary<int, int>();
        List<SqlParameter> para = new List<SqlParameter>();
        
        if (!string.IsNullOrEmpty(khmc))
        {
            sql_tj = " and b.khmc like '%'+ @khmc+'%'";
            para.Add(new SqlParameter("@khmc", khmc));
        }
        //加载数据
        using (LiLanzDALForXLM dal = new LiLanzDALForXLM(OAConnStr))
        {
            mysql = @"SELECT a.wxid,a.parentid,b.khid,b.khmc,COUNT(DISTINCT ISNULL( d.mdid,0)) AS mdsl,COUNT(ISNULL(e.id,0)) AS zrs,0 as sxrs,0 as syrs,0.0 syl
                    FROM dbo.wx_t_Deptment a INNER JOIN yx_T_khb b ON a.id=b.khid " + sql_tj + @"
                    INNER JOIN yx_T_khb c ON c.ccid+'-' LIKE b.ccid+'-%' AND c.ty=0
                    LEFT JOIN  t_mdb d ON c.khid=d.khid AND d.ty=0
                    LEFT JOIN rs_t_rydwzl e ON c.khid=e.tzid AND e.rzzk=1
                    WHERE a.deptType='my'  AND a.parentid=@parentid
                    GROUP BY a.wxid,a.parentid,b.khid,b.khmc,b.ssid ";
            para.Add(new SqlParameter("@parentid", parentid));
            errInfo = dal.ExecuteQuerySecurity(mysql,para, out dt_dept);
            if (errInfo != "")
            {
                clsSharedHelper.WriteErrorInfo(errInfo);
                return;
            }

            mysql =string.Format( @"SELECT a.id,CASE when b.parentid={0} OR b.wxid={0}  THEN b.id WHEN c.parentid={0} THEN c.id ELSE 0 END AS khid
                        FROM dbo.wx_t_customers a 
                        INNER JOIN dbo.wx_t_Deptment b ON a.department=b.wxid AND b.deptType='my'
                        INNER JOIN dbo.wx_t_Deptment c ON b.parentid=c.wxid
                      WHERE  b.parentid={0} OR b.wxid={0} OR c.parentid={0}",parentid);

            errInfo = dal.ExecuteQuery(mysql, out dt_wxrs);
            if (errInfo != "")
            {
                clsSharedHelper.WriteErrorInfo(errInfo);
                return;
            }

            for (int i = 0; i < dt_wxrs.Rows.Count; i++)
            {
                Duser.Add(Convert.ToInt32(dt_wxrs.Rows[i]["id"]), Convert.ToInt32(dt_wxrs.Rows[i]["khid"]));
            }
            
            mysql = string.Format(@"SELECT DISTINCT userid ,'0' AS khid
                                    FROM dbo.wx_t_Log a 
                                    WHERE CreateTime >='{0}' AND CreateTime<DATEADD(DAY,1,'{1}') AND userid >0", myksrq.ToString("yyyy-MM-dd"), myjsrq.ToString("yyyy-MM-dd"));
            dal.ConnectionString = WXDBConStr;
            errInfo = dal.ExecuteQuery(mysql, out dt_logr);
            if (errInfo != "")
            {
                clsSharedHelper.WriteErrorInfo(errInfo);
                return;
            }

            for (int i = 0; i < dt_logr.Rows.Count; i++)
            {
                if (Duser.ContainsKey(Convert.ToInt32(dt_logr.Rows[i]["UserID"])))
                {
                    dt_logr.Rows[i]["khid"] = Duser[Convert.ToInt32(dt_logr.Rows[i]["UserID"])];
                }
            }
        }
        //数据处理
        DataRow[] dr_sxrs;
        DataRow[] dr_rsyrs;
        for (int i = 0; i < dt_dept.Rows.Count; i++)
        {
            dr_sxrs = dt_wxrs.Select("khid=" + dt_dept.Rows[i]["khid"]);
            dr_rsyrs = dt_logr.Select("khid='" + dt_dept.Rows[i]["khid"]+"'" );
            dt_dept.Rows[i]["sxrs"] = dr_sxrs.Length;
            dt_dept.Rows[i]["syrs"] = dr_rsyrs.Length;
            if (dr_sxrs.Length > 0 && dr_rsyrs.Length > 0)
            {
                dt_dept.Rows[i]["syl"] = Math.Round(dr_rsyrs.Length * 1.0 / dr_sxrs.Length * 100.0,1);
            }
         //   Response.Write("上线人数=" + dt_dept.Rows[i]["sxrs"] + "  日使用人数=" + dt_dept.Rows[i]["rysrs"] + "  月使用人数=" + dt_dept.Rows[i]["ysyrs"] + "月使用率=" + dt_dept.Rows[i]["ysyl"] + "</br>");
        }
        if (!string.IsNullOrEmpty(orderSort))
        {
            dt_dept.DefaultView.Sort = orderSort;
            dt_dept = dt_dept.DefaultView.ToTable();
        }
        
        string rt = DataTableToJson("mydata",dt_dept);
        dt_dept.Clear(); dt_dept.Dispose();
        dt_wxrs.Clear();dt_wxrs.Dispose();
        dt_logr.Clear(); dt_logr.Dispose();
        Response.Write(rt);
        Response.End();
    }

    public static string DataTableToJson(string jsonName, DataTable dt)
    {
        StringBuilder Json = new StringBuilder();
        Json.Append("{\"" + jsonName + "\":[");
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
        Json.Append("]}");
        return Json.ToString();
    }
</script>

<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <title></title>
</head>
<body>
    <form id="form1" runat="server">
    <div>
    
    </div>
    </form>
</body>
</html>
