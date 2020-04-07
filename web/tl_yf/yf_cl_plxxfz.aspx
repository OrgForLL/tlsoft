<%@ Page Language="C#" %>

<%@ Import Namespace="System.Net" %>
<%@ Import Namespace="System.IO" %>
<%@ Import Namespace="System.IO.Compression" %>
<%@ Import Namespace="System.Data" %>
<%@ Import Namespace="System.Data.SqlClient" %>
<%@ Import Namespace="nrWebClass" %>
<%@ Import Namespace="System.Collections.Generic" %>
<%@ Import Namespace="Newtonsoft.Json.Linq" %>
<%@ Import Namespace="Newtonsoft.Json" %>
<script runat="server">

    LiLanzDAL sqlhelp = new LiLanzDAL();
    //string url = "http://webt.lilang.com:9030/";
    protected void Page_Load(object sender, EventArgs e)
    {
        string r = "";
        try
        {
            ////Request.ContentEncoding = Encoding.UTF8;
            //string a = Request["zlmxid"];
            //if (a == "446879")
            //{
            //    r = Request["zdr"];
            //}
            //else
            //{
            r = UploadPic(Request["zlmxid"], Request["mbzlmxid"], Request["zdr"], int.Parse(Request["tzid"]));
            // }
        }
        catch (SystemException ex)
        {
            r = ex.Message + ex.StackTrace + ex.Source;
        }
        Response.Write(r);
        Response.End();
    }


    /// <summary>
    /// 上传图片
    /// </summary>
    /// <param name="zlmxid"></param>
    /// <param name="mbzlmxid"></param>
    /// <param name="zdr"></param>
    /// <param name="tzid"></param>
    /// <returns></returns>
    public string UploadPic(string zlmxid, string mbzlmxid, string zdr, int tzid)
    {

        DataSet ds = new DataSet();
        string errInfo = "";
        string wjm = "";
        string sgtp_mypic = "";
        string sjtg_mypic = "";
        string upaddress = "";

        using (LiLanzDALForXLM dal = new LiLanzDALForXLM())
        {
            string sql = "select a.wjm from yf_t_cpkfsjtg_fj a inner join yf_t_cpkfsjtg b on b.zlmxid = '" + zlmxid + "'and b.id = a.ssid ;";
            sql += "select tplx,mypic  from yf_t_cpkfsjtg  where zlmxid='" + zlmxid + "';";
            sql += "select zb.id,zb.urladdress from t_uploadfile zb";
            sql += " inner join yf_t_cpkfsjtg j on j.zlmxid='" + zlmxid + "' and zb.tableid = j.id and j.tplx in ('sgtp','sjtg')";
            sql += " where zb.groupid in (17,18);";
            dal.ConnectionString = "server='192.168.35.10';uid=ABEASD14AD;pwd=+AuDkDew;database=tlsoft ";
            errInfo = dal.ExecuteQuery(sql, out ds);
            string toPath = "../MyUpload/" + DateTime.Now.ToString("yyyyMM") + "/";
            string filePath = Server.MapPath(toPath);

            //检查是否有该路径  没有就创建
            if (!Directory.Exists(filePath))
                Directory.CreateDirectory(filePath);

            if (errInfo == "")
            {
                if (ds.Tables.Count > 0)
                {
                    string Pathpic = "../photo/sjtg/tgfj/";
                    string tail = "";
                    //CDR
                    if (ds.Tables[0].Rows.Count == 1)
                    {
                        string path = ds.Tables[0].Rows[0]["wjm"].ToString();
                        string head = toPath;
                        tail = path.Substring(path.Length - 4, 4);
                        if (!ds.Tables[0].Rows[0]["wjm"].ToString().Contains("/"))
                        {
                            if (tail != ".cdr")
                                head = Pathpic;
                        }
                        string fileaddress = head + DateTime.Now.ToString("yyyyMMdd") + DateTime.Now.ToFileTime().ToString().Substring(6, 10) + tail;
                        try
                        {
                            if (File.Exists(HttpContext.Current.Server.MapPath(path)))
                                File.Copy(HttpContext.Current.Server.MapPath(path), HttpContext.Current.Server.MapPath(fileaddress), true);
                        }
                        catch (SystemException ex)
                        {
                            errInfo = @"{{""type"":""ERROR"",""msg"":""CDR复制失败,错误信息:""+""{0}""}}";
                            errInfo = String.Format(errInfo, ex.Message);
                        }
                        wjm = fileaddress;
                    }
                    //效果图工艺图
                    if (ds.Tables[1].Rows.Count == 2)
                    {

                        for (int i = 0; i < ds.Tables[1].Rows.Count; i++)
                        {
                            string tplx = ds.Tables[1].Rows[i]["tplx"].ToString();
                            string path = ds.Tables[1].Rows[i]["mypic"].ToString();

                            tail = path.Substring(path.Length - 4, 4);
                            string fileaddress = toPath + DateTime.Now.ToString("yyyyMMdd") + DateTime.Now.ToFileTime().ToString().Substring(6, 10) + i + tail;
                            try
                            {
                                if (File.Exists(HttpContext.Current.Server.MapPath(path)))
                                    File.Copy(HttpContext.Current.Server.MapPath(path), HttpContext.Current.Server.MapPath(fileaddress), true);
                            }
                            catch (SystemException ex)
                            {
                                errInfo = @"{{""type"":""ERROR"",""msg"":""效果图工艺图复制失败,错误信息:""+""{0}""}}";
                                errInfo = String.Format(errInfo, ex.Message);
                            }
                            if (tplx == "sgtp")
                                sgtp_mypic = fileaddress;
                            else if (tplx == "sjtg")
                                sjtg_mypic = fileaddress;

                        }

                    }
                    //图片上传显示列表
                    if (ds.Tables[2].Rows.Count > 0)
                    {

                        for (int i = 0; i < ds.Tables[2].Rows.Count; i++)
                        {
                            string path = ds.Tables[2].Rows[i]["urladdress"].ToString();
                            tail = path.Substring(path.Length - 4, 4);
                            string fileaddress = toPath + DateTime.Now.ToString("yyyyMMdd") + DateTime.Now.ToFileTime().ToString().Substring(6, 10) + i + tail;
                            try
                            {
                                if (File.Exists(HttpContext.Current.Server.MapPath(path)))
                                    File.Copy(HttpContext.Current.Server.MapPath(path), HttpContext.Current.Server.MapPath(fileaddress), true);
                            }
                            catch (SystemException ex)
                            {
                                errInfo = @"{{""type"":""ERROR"",""msg"":""图片上传显示列表复制失败,错误信息:""+""{0}""}}";
                                errInfo = String.Format(errInfo, ex.Message);
                            }
                            upaddress += ds.Tables[2].Rows[i]["id"].ToString() + "," + fileaddress + "|";
                        }

                    }
                    string sql_fz = "exec yf_cl_plxxfz @zlmxid='" + zlmxid + "',@mbzlmxid='" + mbzlmxid + "',@zdr='" + zdr + "',@tzid=" + tzid + ",@wjm='" + wjm + "',@sgtp_mypic='" + sgtp_mypic + "',@sjtg_mypic='" + sjtg_mypic + "',@upaddress='" + upaddress + "';";
                    errInfo = dal.ExecuteQuery(sql_fz, out ds);
                    if (errInfo == "")
                    {
                        errInfo = "{\"type\":\"SUCCESS\",\"msg\":\"\"}";
                        //errInfo = "SUCCESS";                  
                    }
                    else
                    {
                        errInfo = "{\"type\":\"ERROR\",\"msg\":\"执行过程失败,错误信息:{0}\"}";
                        errInfo = String.Format(errInfo, errInfo);
                        //errInfo = "执行过程失败,错误信息:" + errInfo;
                    }
                }
                else
                {
                    errInfo = "{\"type\":\"ERROR\",\"msg\":\"查询源数据出错,没有记录\"}";
                    errInfo = String.Format(errInfo, errInfo);
                    //errInfo = "查询源数据出错,没有记录";

                }
            }
            else
            {
                errInfo = "{\"type\":\"ERROR\",\"msg\":\"查询源数据出错,错误信息:{0}\"}";
                errInfo = String.Format(errInfo, errInfo);
                //errInfo = "查询源数据出错,错误信息:" + errInfo;
            }
        }
        return errInfo;
    }
</script>
