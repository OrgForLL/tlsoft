<%@ Page Language="C#" %>

<%@ Import Namespace="nrWebClass" %>
<%@ Import Namespace="System.Data.SqlClient" %>
<%@ Import Namespace="System.Data" %>
<%@ Import Namespace="System.Collections.Generic" %>

<!DOCTYPE html>
<script runat="server">
    private string WXDBConstr = "server='192.168.35.62';uid=sa;pwd=ll=8727;database=weChatPromotion";
    protected void Page_Load(object sender, EventArgs e){
        string ctrl = Convert.ToString(Request.Params["ctrl"]);
        switch (ctrl) {
            case "staticFlow":
                string pageid = Convert.ToString(Request.Params["pageid"]);
                DateTime ksrq = Convert.ToDateTime(Request.Params["ksrq"]);
                DateTime jsrq = Convert.ToDateTime(Request.Params["jsrq"]);
                staticFlow(pageid, ksrq, jsrq);
                break;
            case "loadFuncs":
                loadFuncs();
                break;
            case "massHandle":
                string rq = Convert.ToString(Request.Params["rq"]);
                massHandle(rq);
                break;
            default:
                clsSharedHelper.WriteErrorInfo("请检查传入的CTRL是否有效！");
                break;
        }
    }

    public void staticFlow(string pageid,DateTime ksrq,DateTime jsrq) {
        using (LiLanzDALForXLM dal62 = new LiLanzDALForXLM(WXDBConstr)) {
            string str_sql = @"select convert(varchar(10),createtime,120) rq,count(id) pv,count(distinct userid) users 
                                from wx_t_log 
                                where createtime>=@ksrq and createtime<dateadd(day,1,@jsrq) and pageid=@pageid
                                group by convert(varchar(10),createtime,120)
                                order by convert(varchar(10),createtime,120)";
            DataTable dt;
            List<SqlParameter> paras = new List<SqlParameter>();
            paras.Add(new SqlParameter("@ksrq", ksrq));
            paras.Add(new SqlParameter("@jsrq", jsrq));
            paras.Add(new SqlParameter("@pageid",pageid));
            string errinfo = dal62.ExecuteQuerySecurity(str_sql,paras,out dt);
            if (errinfo == "")
                clsSharedHelper.WriteInfo(JsonHelp.dataset2json(dt));
            else
                clsSharedHelper.WriteErrorInfo(errinfo);
        }//end using
    }

    public void loadFuncs() {
        using (LiLanzDALForXLM dal62 = new LiLanzDALForXLM(WXDBConstr)) {
            string str_sql = @"select distinct pageid,pagename from wx_t_pageIdentify";
            DataTable dt;
            string errinfo = dal62.ExecuteQuery(str_sql,out dt);
            if (errinfo == "")
                clsSharedHelper.WriteInfo(JsonHelp.dataset2json(dt));
            else
                clsSharedHelper.WriteErrorInfo(errinfo);
        }//end using
    }

    public void massHandle(string ksrq) {
        DateTime startTime = Convert.ToDateTime(ksrq);
        DateTime endTime = startTime.AddMonths(1);
        DateTime _time = startTime;
        int successCounts = 0, failCounts = 0;
        string str = "";
        using (LiLanzDALForXLM dal62 = new LiLanzDALForXLM(WXDBConstr)) {
            string str_sql = @"DECLARE @DATE0 DateTime
                                SELECT @DATE0 = '{0}'		

                                DECLARE @ID1 INT,@ID2 INT;
                                SELECT TOP 1 @ID1 = ID FROM wx_t_Log WHERE CreateTime >= @DATE0 ORDER BY ID
                                SELECT TOP 1 @ID2 = ID FROM wx_t_Log WHERE CreateTime <  DATEADD(DAY, 1, @DATE0) ORDER BY ID DESC 

                                UPDATE wx_t_Log SET PageID = ISNULL((SELECT TOP 1 B.PageID FROM wx_t_pageIdentify B WHERE A.SourcePage LIKE '%' + B.sourcePage  +'%'),0)
                                FROM wx_t_Log A WHERE A.PageID = 0 AND A.ID >= @ID1 AND A.ID <= @ID2";
            //clsSharedHelper.WriteInfo(startTime.ToString()+"|"+endTime.ToString());
            while (_time < endTime)
            {
                string _sql = str_sql;
                _sql = string.Format(_sql, _time.ToString());
                string errinfo = dal62.ExecuteNonQuery(_sql);
                if (errinfo == "")
                    successCounts++;                
                else
                    failCounts++;
                _time = _time.AddDays(1);
            }
        }//end using        
        clsSharedHelper.WriteInfo(successCounts.ToString() + "|" + failCounts.ToString());
    }
</script>
<html lang="en" xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <meta charset="utf-8" />
    <title></title>
</head>
<body>
    <form id="form1" runat="server">
    </form>
</body>
</html>
