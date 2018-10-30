<%@ Page Language="C#" %>

<%@ Import Namespace="nrWebClass" %>
<%@ Import Namespace="System.Data" %>
<%@ Import Namespace="System.Data.SqlClient" %>
<%@ Import Namespace="System.Collections.Generic" %>
<!DOCTYPE html>
<script runat="server">

    private string ConnWX = ConfigurationManager.ConnectionStrings["Conn_4"].ConnectionString;
    //private string ZBDBConnStr = clsConfig.GetConfigValue("OAConnStr");
    private string ZBDBConnStr = "server='192.168.35.10';uid=lllogin;pwd=rw1894tla;database=tlsoft";
    protected void Page_Load(object sender, EventArgs e)
    {
        string ctrl = "";

        if (ctrl == null || ctrl == "")
        {
            ctrl = Convert.ToString(Request.Params["ctrl"]);
        }
        string mdid = Convert.ToString(Request.Params["mdid"]);
        string ryid = Convert.ToString(Request.Params["ryid"]);
        string saleTarget = Convert.ToString(Request.Params["saleTarget"]);
        string nMonth = Convert.ToString(Request.Params["nMonth"]);
        string nYear = Convert.ToString(Request.Params["nYear"]);
        string ny = Convert.ToString(Request.Params["ny"]);

        if (mdid == "" || mdid == null)
        {
            clsSharedHelper.WriteErrorInfo("缺少门店参数！");
            return;
        }
        if (ryid == "" || ryid == null)
        {
            clsSharedHelper.WriteErrorInfo("缺少人员参数！");
            return;
        }


        switch (ctrl)
        {
            case "getSaleTarget":
                getSaleTarget(ryid, mdid, nYear, nMonth, ny);
                break;
            case "saveSaleTarget":
                saveSaleTarget(ryid, mdid, saleTarget, nYear, nMonth);
                break;
            default:
                clsSharedHelper.WriteErrorInfo("无【CTRL=" + ctrl + "】对应操作！");
                break;
        };

    }

    public void getSaleTarget(string ryid, string mdid, string nYear, string nMonth, string ny)
    {


        using (LiLanzDALForXLM oaDal = new LiLanzDALForXLM(ZBDBConnStr))
        {
            DataTable dt1 = null;
            DataTable dt2 = null;

            string strSql = @"
                            DECLARE @mdid INT,
                                    @je INT
                                SELECT @mdid = 0,@je = 0
                                SELECT TOP 1 @mdid = mdid FROM Rs_T_Rydwzl WHERE ID = @ryid    
                                IF (@mdid = 0)  SELECT @je=0 
                                ELSE            SELECT TOP 1 @je=je FROM rs_t_yxmbje WHERE ny = @ny AND mdid=@mdid
                                SELECT @je AS je";
            List<SqlParameter> param = new List<SqlParameter>();
            param.Add(new SqlParameter("@ryid", ryid));
            param.Add(new SqlParameter("@ny", ny));
            string errInfo = oaDal.ExecuteQuerySecurity(strSql, param, out dt1);
            if (errInfo == "")
            {
                if (dt1.Rows.Count > 0)
                {
                    using (LiLanzDALForXLM wxDal = new LiLanzDALForXLM(ConnWX))
                    {
                        string strMeSql = @"select top 1 SaleTarget from wx_t_SaleTarget
                                            WHERE ryid=@ryid AND mdid=@mdid
                                            AND nYear=@nYear AND nMonth=@nMonth";
                        param.Clear();
                        param.Add(new SqlParameter("@ryid", ryid));
                        param.Add(new SqlParameter("@mdid", mdid));
                        param.Add(new SqlParameter("@nYear", nYear));
                        param.Add(new SqlParameter("@nMonth", nMonth));
                        errInfo = wxDal.ExecuteQuerySecurity(strMeSql, param, out dt2);
                        double SaleTarget = 0;
                        if (errInfo == "")
                        {
                            dt1.Columns.Add("SaleTarget", typeof(double),"");
                            
                            if (dt2.Rows.Count > 0)
                            {
                                SaleTarget = Convert.ToDouble(dt2.Rows[0]["SaleTarget"]);
                                dt1.Rows[0]["SaleTarget"] = SaleTarget;
                                
                            }
                            else
                            {
                                dt1.Rows[0]["SaleTarget"] = 0;
                            }
                            
                        }
                        dt2.Rows.Clear();
                        dt2.Dispose();
                    }
                    
                    clsSharedHelper.WriteInfo(JsonHelp.dataset2json(dt1));
                    dt1.Rows.Clear();
                    dt1.Dispose();
                }
                else
                {
                    clsSharedHelper.WriteErrorInfo("查询个人目标时出错！");
                }
            }
            else
            {
                clsSharedHelper.WriteErrorInfo("查询本店目标时出错！");
            }

        }


    }


    public void saveSaleTarget(string ryid, string mdid, string saleTarget, string nYear, string nMonth)
    {
        
        using (LiLanzDALForXLM wxDal = new LiLanzDALForXLM(ConnWX))
        {
            DataTable dt = null;
            string strSql = @"select top 1 SaleTarget from wx_t_SaleTarget
                              WHERE ryid=@ryid AND mdid=@mdid
                              AND nYear=@nYear AND nMonth=@nMonth";
            List<SqlParameter> param = new List<SqlParameter>();
            param.Add(new SqlParameter("@mdid", mdid));
            param.Add(new SqlParameter("@ryid", ryid));
            param.Add(new SqlParameter("@nYear", nYear));
            param.Add(new SqlParameter("@nMonth", nMonth));
            string errInfo = wxDal.ExecuteQuerySecurity(strSql, param, out dt);
            if (errInfo == "")
            {
                //clsSharedHelper.WriteInfo(dt.Rows[0][0]+"  "+dt.Rows.Count);

                if (dt.Rows.Count > 0)
                {
                    string strUpdSql = @"update wx_t_SaleTarget set SaleTarget=@SaleTarget 
                                                        WHERE ryid=@ryid AND mdid=@mdid
                                                        AND nYear=@nYear AND nMonth=@nMonth";
                    param.Clear();
                    param.Add(new SqlParameter("@mdid", mdid));
                    param.Add(new SqlParameter("@ryid", ryid));
                    param.Add(new SqlParameter("@nYear", nYear));
                    param.Add(new SqlParameter("@nMonth", nMonth));
                    param.Add(new SqlParameter("@SaleTarget", saleTarget));
                    //clsSharedHelper.WriteInfo(mdid + " " + ryid + " " + nYear + " " + nMonth + " " + saleTarget);
                    errInfo = wxDal.ExecuteNonQuerySecurity(strUpdSql, param);
                    if (errInfo == "")
                    {
                        clsSharedHelper.WriteInfo("success");

                    }
                    else
                    {
                        clsSharedHelper.WriteErrorInfo(errInfo);
                    }
                }


                else
                {
                    string strInsSql = @"
                                insert into wx_t_SaleTarget (mdid, ryid, nYear, nMonth, SaleTarget)
                                values (@mdid, @ryid, @nYear, @nMonth, @SaleTarget)";
                    //clsSharedHelper.WriteInfo(param.Count+"");
                    param.Clear();
                    param.Add(new SqlParameter("@mdid", mdid));
                    param.Add(new SqlParameter("@ryid", ryid));
                    param.Add(new SqlParameter("@nYear", nYear));
                    param.Add(new SqlParameter("@nMonth", nMonth));
                    param.Add(new SqlParameter("@SaleTarget", saleTarget));
                    errInfo = wxDal.ExecuteNonQuerySecurity(strInsSql, param);
                    if (errInfo == "")
                    {
                        clsSharedHelper.WriteInfo("insert success");
                    }
                    else
                    {
                        clsSharedHelper.WriteErrorInfo(errInfo);
                    }
                                       
                }
            }
            else
            {
                clsSharedHelper.WriteErrorInfo("查询数据时出错！");

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
