<%@ Page Language="C#" %>

<%@ Import Namespace="System.IO" %>
<%@ Import Namespace="nrWebClass" %>
<%@ Import Namespace="System.Data"%>
<%@ Import Namespace="System.Data.SqlClient" %>
<%@ Import Namespace="System.Collections.Generic" %>
<!DOCTYPE html>
<script runat="server">
    bool isZDSC = false;//是否是自动上传
    LiLanzDAL sqlhelp = new LiLanzDAL();

    protected void Page_Load(object sender, EventArgs e)
    {
        String ctrl = Convert.ToString(Request.Params["ctrl"]);
        String rtMsg = "";
        String userid = Convert.ToString(Session["userid"]);

        string[] AllKeys = Request.Params.AllKeys;
        for(int i=0;i<AllKeys.Length;i++)
        {
            if (AllKeys[i] == "userid")
            {
                userid = Convert.ToString(Request.Params["userid"]);
                isZDSC = true;
            }
        }

        if (userid == "" || userid == null)
            clsSharedHelper.WriteErrorInfo("SESSION过期，请重新登陆！");

        if (ctrl == "" || ctrl == null)
            clsSharedHelper.WriteErrorInfo("缺少CTRL参数！");

        switch (ctrl)
        {
            case "upload":
                String ids = Convert.ToString(Request.Params["ids"]);
                String mlid = Convert.ToString(Request.Params["mlid"]);
                String zd = Convert.ToString(Request.Params["zd"]);
                UploadPDF(ids,mlid,zd);
                break;
            case "delete":
                String mxid = Convert.ToString(Request.Params["mxid"]);
                zd = Convert.ToString(Request.Params["zd"]);
                DeletePDF(mxid,zd);
                break;
            default:
                rtMsg = "无CTRL对应操作！";
                break;
        }

        clsSharedHelper.WriteInfo(rtMsg);
    }
    //上传操作，将文件复制一份出来并写入数据库
    public void UploadPDF(string ids,string mlid,string zd) {
        String[] tmp = ids.Split(',');
        DataTable dt=null;
        String errInfo = "";
        using (LiLanzDALForXLM dal = new LiLanzDALForXLM()) {
            String sql = "select localpdf from yf_t_syjcbg where id in ("+ids+");";
            errInfo = dal.ExecuteQuery(sql,out dt);
            if (errInfo == "" && dt.Rows.Count > 0) {
                String path = "",filename="",newfilename="",errs="";
                String toPath = "../photo/sygzb_pdf/";
                int value = 0,sucCount=0;
                if (zd == "sygzb_tp")
                    value = 3311;
                else if (zd == "sygzb_sg")
                    value = 3312;
                //生成文件名                
                for (int i = 0; i < dt.Rows.Count; i++) {
                    path = "../"+dt.Rows[i]["localpdf"].ToString();
                    filename=path.Split('/')[path.Split('/').Length-1];
                    newfilename = "_" + i.ToString() + "@" + DateTime.Now.ToFileTime() + ".pdf";
                    if (File.Exists(Server.MapPath(path))) {
                        //检查源文件是否存在
                        if (isZDSC)//是自动上传
                        {
                            sql = @"
                                SELECT * FROM ghs_t_zldamxb WHERE mlid='{0}' and text1='{1}'
                            ";
                            sql = string.Format(sql, mlid, filename);
                            using (DataTable dr = sqlhelp.ExecuteDataTable(sql))
                            {
                                if (dr.Rows.Count == 0)//则同一份mlid里面不能传相同的报告
                                {
                                    File.Copy(Server.MapPath(path), Server.MapPath(toPath + newfilename), true);
                                    if (File.Exists(Server.MapPath(toPath + newfilename)))
                                    {
                                        //检查是否复制成功，成功则接着写入数据库                                                        
                                        sql = "insert into ghs_t_zldamxb(mlid,zd,value,text,text1,step) values(@mlid,@zd,@value,@text,@text1,0);";
                                        List<SqlParameter> paras = new List<SqlParameter>();
                                        paras.Add(new SqlParameter("@mlid", mlid));
                                        paras.Add(new SqlParameter("@zd", zd));
                                        paras.Add(new SqlParameter("@value", value));
                                        paras.Add(new SqlParameter("@text", newfilename));
                                        paras.Add(new SqlParameter("@text1", filename));
                                        errInfo = dal.ExecuteNonQuerySecurity(sql, paras);
                                        if (errInfo == "")
                                            sucCount++;
                                        else
                                            errs += errInfo + "|";
                                    }
                                }
                            }
                        }
                        else
                        {
                            File.Copy(Server.MapPath(path), Server.MapPath(toPath + newfilename), true);
                            if (File.Exists(Server.MapPath(toPath + newfilename)))
                            {
                                //检查是否复制成功，成功则接着写入数据库                                                        
                                sql = "insert into ghs_t_zldamxb(mlid,zd,value,text,text1,step) values(@mlid,@zd,@value,@text,@text1,0);";
                                List<SqlParameter> paras = new List<SqlParameter>();
                                paras.Add(new SqlParameter("@mlid", mlid));
                                paras.Add(new SqlParameter("@zd", zd));
                                paras.Add(new SqlParameter("@value", value));
                                paras.Add(new SqlParameter("@text", newfilename));
                                paras.Add(new SqlParameter("@text1", filename));
                                errInfo = dal.ExecuteNonQuerySecurity(sql, paras);
                                if (errInfo == "")
                                    sucCount++;
                                else
                                    errs += errInfo + "|";
                            }
                        }
                    }
                }//end for  
                if (errs == "")
                    errInfo = "成功复制【" + sucCount.ToString() + "】份报告！";
                else
                    errInfo = errs;
            }
        }
        clsSharedHelper.WriteInfo(errInfo);
    }

    //删除文件，并操作数据库
    public void DeletePDF(String mxid,String zd) {
        String errInfo = "";
        String path = "../photo/sygzb_pdf/";
        using (LiLanzDALForXLM dal = new LiLanzDALForXLM()) {
            DataTable dt = null;
            String sql = "select top 1 text from ghs_t_zldamxb where mxid=@mxid;";
            List<SqlParameter> paras = new List<SqlParameter>();
            paras.Add(new SqlParameter("@mxid",mxid));
            errInfo = dal.ExecuteQuerySecurity(sql,paras,out dt);
            if (errInfo == "" && dt.Rows.Count > 0) {
                String filename=dt.Rows[0]["text"].ToString();
                if (File.Exists(Server.MapPath(path + filename)))
                {
                    File.Delete(Server.MapPath(path + filename));
                }

                if (!File.Exists(Server.MapPath(path + filename))) {
                    //不存在了代表删除成功
                    sql = "delete from ghs_t_zldamxb where mxid=@mxid and zd=@zd;";
                    paras.Clear();
                    paras.Add(new SqlParameter("@mxid",mxid));
                    paras.Add(new SqlParameter("@zd",zd));
                    errInfo=dal.ExecuteNonQuerySecurity(sql,paras);
                }
            }
        }

        if (errInfo == "")
            clsSharedHelper.WriteSuccessedInfo("删除成功！");
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
