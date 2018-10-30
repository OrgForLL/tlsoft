<%@ Page Language="C#" %>
<%@ Import Namespace="nrWebClass" %>
<%@ Import Namespace="System.Data" %>
<%@ Import Namespace="System.Data.SqlClient" %>
<%@ Import Namespace="System.Collections.Generic" %>
<!DOCTYPE html>
<script runat="server">
    //private string FXDBConnStr = "server='192.168.35.11';uid=ABEASD14AD;pwd=+AuDkDew;database=FXDB";
    private string ZBDBConnStr = "server='192.168.35.10';uid=lllogin;pwd=rw1894tla;database=tlsoft";
    //private string FXDBConnStr = clsConfig.GetConfigValue(FXDBConStr);

    protected void Page_Load(object sender, EventArgs e)
    {
        string ctrl = "";

        if (ctrl == null || ctrl == "")
        {
            ctrl = Convert.ToString(Request.Params["ctrl"]);
        }
        string mdid = Convert.ToString(Request.Params["mdid"]);
        if (mdid == "" || mdid == null)
        {
            clsSharedHelper.WriteErrorInfo("缺少门店参数！");
            return;
        }

        switch (ctrl)
        {
            case "getShopRank":
                getShopRank2(mdid);
                break;
            default:
                clsSharedHelper.WriteErrorInfo("无【CTRL=" + ctrl + "】对应操作！");
                break;
        };
        
    }

    public void getShopRank(string mdid)
    {
        using (LiLanzDALForXLM ADal = new LiLanzDALForXLM(ZBDBConnStr))
        {
            
            DataTable dt = null;
            string strsql = @"SELECT b.xm,SUM(a.xsje) AS zje,count(*) AS ddsl FROM zmd_t_xstcmxb a
                                INNER JOIN rs_t_ryjbzl b ON a.ryid=b.id
                                WHERE mdid=@mdid AND CONVERT(VARCHAR(6),a.rq,112)=CONVERT(VARCHAR(6),GETDATE(),112) 
                                GROUP BY b.xm,a.ryid ORDER BY zje desc;";
            List<SqlParameter> param = new List<SqlParameter>();
            param.Add(new SqlParameter("@mdid", mdid));
            string errinfo = ADal.ExecuteQuerySecurity(strsql, param, out dt);
            if (errinfo == "" && errinfo.Length == 0)
            {
                if (dt.Rows.Count > 0)
                {
                    clsSharedHelper.WriteInfo(JsonHelp.dataset2json(dt));//JsonHelp.dataset2json(dt)
                }
                else
                {
                    clsSharedHelper.WriteErrorInfo("计算图表数据时查询不到数据！");
                }
            }
            else
            {
                clsSharedHelper.WriteErrorInfo("统计数据时出错 info:" + errinfo);
            }
        };
    }
    /// <summary>
    /// getShopRank改进后的算法
    /// </summary>
    /// <param name="mdid"></param>
    public void getShopRank2(string mdid)
    {
        using (LiLanzDALForXLM ADal = new LiLanzDALForXLM(ZBDBConnStr))
        {
            
            DataTable dt = null;
            string strsql = String.Format(@"SELECT max(b.xm) xm,SUM(a.xsje) AS zje,count(1) AS ddsl FROM zmd_t_xstcmxb a
                                INNER JOIN rs_t_ryjbzl b ON a.ryid=b.id
                                WHERE mdid=@mdid AND a.rq>='{0:yyyy-MM-01}' and a.rq<'{1:yyyy-MM-01}'
                                GROUP BY a.ryid ORDER BY zje desc;", DateTime.Now, DateTime.Now.AddMonths(1));
            List<SqlParameter> param = new List<SqlParameter>();
            param.Add(new SqlParameter("@mdid", mdid));
            string errinfo = ADal.ExecuteQuerySecurity(strsql, param, out dt);
            if (errinfo == "" && errinfo.Length == 0)
            {
                if (dt.Rows.Count > 0)
                {
                    clsSharedHelper.WriteInfo(JsonHelp.dataset2json(dt));//JsonHelp.dataset2json(dt)
                }
                else
                {
                    clsSharedHelper.WriteErrorInfo("计算图表数据时查询不到数据！");
                }
            }
            else
            {
                clsSharedHelper.WriteErrorInfo("统计数据时出错 info:" + errinfo);
            }
        };
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
