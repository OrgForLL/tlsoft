<%@ Page Language="C#" %>
<%@ Import Namespace="System.Net" %>
<%@ Import Namespace="System.IO" %>
<%@ Import Namespace="System.IO.Compression" %>
<%@ Import Namespace="System.Data" %>
<%@ Import Namespace="System.Data.SqlClient" %>
<%@ Import Namespace="nrWebClass" %>
<%@ Import Namespace="System.Collections.Generic" %>

<script runat="server">

    LiLanzDAL sqlhelp = new LiLanzDAL();

    protected void Page_Load(object sender, EventArgs e)
    {
        int cgNum = 0;
        //同步数据 start
        string date = DateTime.Now.ToString("yyyy-MM-dd");
        string userid = "0";
        if (HttpGet("http://" + Request.Url.Authority + "/interface/getExpReportv2.aspx", "ctrl=syncData&userid=" + userid + "&bdate=" + date + "&edate=" + date).IndexOf("SUCCESS") > -1)
        {
            string ids = GetTBSJIDS(date);
            //下载pdf到本地 start 
            if (HttpGet("http://" + Request.Url.Authority + "/interface/getExpReportv2.aspx", "ctrl=downPDF&userid=" + userid + "&ids=" + ids).IndexOf("SUCCESS") > -1)
            {
                DataView data = GetTBJL(date).DefaultView;
                //上传成分的检测pdf start 
                data.RowFilter = "djlx=3313";
                cgNum += UploadCF(data, userid);
                data.RowFilter = "";
                //上传成分的检测pdf end
                //上传自制的检测pdf start 
                data.RowFilter = "djlx=3312";
                cgNum += UploadZZ(data, userid);
                data.RowFilter = "";
                //上传自制的检测pdf end
                //上传贴牌的检测pdf start 
                data.RowFilter = "djlx=3311";
                cgNum += UploadTP(data, userid);
                data.RowFilter = "";
                //上传贴牌的检测pdf end
            }
            //下载pdf到本地 end             
            Response.Write("成功【" + cgNum + "】条");
            Response.End();
        }
        else
        {
            Response.Write("成功【" + cgNum + "】条");
            Response.End();
        }
        //同步数据 end 
    }

    /// <summary>
    /// GET请求与获取结果
    /// </summary>
    /// <param name="Url">请求地址</param>
    /// <param name="postDataStr">带的数据</param>
    /// <returns>返回所请求页面的结果</returns>         
    public static string HttpGet(string Url, string postDataStr)
    {
        HttpWebRequest request = (HttpWebRequest)WebRequest.Create(Url + (postDataStr == "" ? "" : "?") + postDataStr);
        request.Method = "GET";
        request.ContentType = "text/html;charset=GB2312";

        HttpWebResponse response = (HttpWebResponse)request.GetResponse();
        Stream myResponseStream = response.GetResponseStream();
        StreamReader myStreamReader = new StreamReader(myResponseStream, Encoding.GetEncoding("GB2312"));
        string retString = myStreamReader.ReadToEnd();
        myStreamReader.Close();
        myResponseStream.Close();

        return retString;
    }

    /// <summary>
    /// 获取指定同步日期数据的id串
    /// </summary>
    /// <param name="tbrq">同步日期</param>
    /// <returns>返回指定同步日期数据的id串</returns>
    public string GetTBSJIDS(string tbrq)
    {
        string sql = @"
            SELECT id 
            FROM yf_t_syjcbg 
            WHERE czrq='{0}'
            ORDER BY id DESC
        ";
        sql = string.Format(sql, tbrq);
        string ids = "0";
        using (SqlDataReader sdr = sqlhelp.ExecuteReader(sql))
        {
            while (sdr.Read())
            {
                ids += "," + sdr["id"];
            }
        }
        return ids;
    }

    /// <summary>
    /// 获取指定同步日期数据记录
    /// </summary>
    /// <param name="tbrq">同步日期</param>
    /// <returns>返回指定同步日期数据记录表</returns>
    public DataTable GetTBJL(string tbrq)
    {
        string sql = @"
            SELECT b.sygzid mlid,b.djlx,a.id,a.bgbh
            FROM yf_t_syjcbg a
            INNER JOIN yf_t_wtjyxy b ON a.wtid=b.id
            WHERE a.czrq='{0}'
            ORDER BY a.id DESC
        ";
        sql = string.Format(sql, tbrq);
        using (DataTable dt = sqlhelp.ExecuteDataTable(sql))
        {
            return dt;
        }
    }

    /// <summary>
    /// 上传成分pdf
    /// </summary>
    /// <param name="dv">成分信息记录视图</param>
    /// <returns>返回值成功条数</returns>
    public int UploadCF(DataView dv,string userid)
    {
        int ztsm = 0;
        string zd = "sygzb_cfbg";
        DataTable mlidb = dv.ToTable(true, new string[] { "mlid" });//去重，并只有mlid列的表 
        foreach (DataRow dr in mlidb.Select())
        {
            dv.RowFilter = "djlx='3313' and mlid=" + dr["mlid"];
            string ids = "0";
            foreach (DataRow dr1 in dv.ToTable().Select())
            {
                ids += "," + dr1["id"];
            }
            if (HttpGet("http://" + Request.Url.Authority + "/interface/PDFUpload.aspx", "ctrl=upload&userid=" + userid + "&ids=" + ids + "&zd=" + zd + "&mlid=" + dr["mlid"]).IndexOf("成功复制") > -1)
            {
                ztsm++;
            }
        }
        return ztsm;
    }

    /// <summary>
    /// 上传贴牌pdf
    /// </summary>
    /// <param name="dv">贴牌信息记录视图</param>
    /// <returns>返回值成功条数</returns>
    public int UploadTP(DataView dv,string userid)
    {
        int ztsm = 0;
        string zd = "sygzb_tp";
        DataTable mlidb = dv.ToTable(true, new string[] { "mlid" });//去重，并只有mlid列的表 
        foreach (DataRow dr in mlidb.Select())
        {
            string iscg = "0";
            //上传合格
            dv.RowFilter = "djlx='3311' and mlid=" + dr["mlid"] + " and bgbh like '%P'";
            string ids = "0";
            foreach (DataRow dr1 in dv.ToTable().Select())
            {
                ids += "," + dr1["id"];
            }
            if (HttpGet("http://" + Request.Url.Authority + "/interface/PDFUpload.aspx", "ctrl=upload&userid=" + userid + "&ids=" + ids + "&zd=" + zd + "&mlid=" + dr["mlid"]).IndexOf("成功复制") > -1)
            {
                iscg = "1";
            }
            else
            {
                iscg = "0";
            }
            if (iscg == "1")
            {
                //上传不合格
                dv.RowFilter = "djlx='3311' and mlid=" + dr["mlid"] + " and bgbh like '%F'";
                ids = "0";
                foreach (DataRow dr1 in dv.ToTable().Select())
                {
                    ids += "," + dr1["id"];
                }
                if (UploadPDF(ids, dr["mlid"].ToString(), zd).IndexOf("成功复制") > -1)
                {
                    ztsm++;
                }
            }

        }
        return ztsm;
    }

    /// <summary>
    /// 上传自制pdf
    /// </summary>
    /// <param name="dv">自制信息记录视图</param>
    /// <returns>返回值成功条数</returns>
    public int UploadZZ(DataView dv,string userid)
    {
        int ztsm = 0;
        string zd = "sygzb_sg";
        DataTable mlidb = dv.ToTable(true, new string[] { "mlid" });//去重，并只有mlid列的表
        foreach (DataRow dr in mlidb.Select())
        {
            string iscg = "0";
            //上传合格
            dv.RowFilter = "djlx='3312' and mlid=" + dr["mlid"] + " and bgbh like '%P'";
            string ids = "0";
            foreach (DataRow dr1 in dv.ToTable().Select())
            {
                ids += "," + dr1["id"];
            }
            if (HttpGet("http://" + Request.Url.Authority + "/interface/PDFUpload.aspx", "ctrl=upload&userid=" + userid + "&ids=" + ids + "&zd=" + zd + "&mlid=" + dr["mlid"]).IndexOf("成功复制") > -1)
            {
                iscg = "1";
            }
            else
            {
                iscg = "0";
            }
            if (iscg == "1")
            {
                //上传不合格
                dv.RowFilter = "djlx='3312' and mlid=" + dr["mlid"] + " and bgbh like '%F'";
                ids = "0";
                foreach (DataRow dr1 in dv.ToTable().Select())
                {
                    ids += "," + dr1["id"];
                }
                if (UploadPDF(ids, dr["mlid"].ToString(), zd).IndexOf("成功复制") > -1)
                {
                    ztsm++;
                }
            }
        }
        return ztsm;
    }

    /// <summary>
    /// 上传操作，将文件复制一份出来并写入数据库
    /// </summary>
    /// <param name="ids"></param>
    /// <param name="mlid">送样跟踪id</param>
    /// <param name="zd">说明单据的类型 sygzb_tp：贴牌；sygzb_sg：自制；sygzb_cfbg：成分；</param>
    /// <returns>返回值包含’成功复制‘表示成功</returns>
    public string UploadPDF(string ids,string mlid,string zd) {
        String[] tmp = ids.Split(',');
        DataTable dt=null;
        String errInfo = "";
        using (LiLanzDALForXLM dal = new LiLanzDALForXLM()) {
            String sql = "select localpdf,bgbh FileName from yf_t_syjcbg where id in ("+ids+");";
            errInfo = dal.ExecuteQuery(sql,out dt);
            if (errInfo == "" && dt.Rows.Count > 0) {
                String path = "",filename="",newfilename="",errs="";
                String toPath = "../MyUpload/" + DateTime.Now.ToString("yyyyMM") + "/";
                string filePath = Server.MapPath(toPath);
                //检查是否有该路径  没有就创建
                if (!Directory.Exists(filePath))
                {
                    Directory.CreateDirectory(filePath);
                }
                int sucCount=0;
                //生成文件名                
                for (int i = 0; i < dt.Rows.Count; i++) {
                    path = "../"+dt.Rows[i]["localpdf"].ToString();
                    filename=path.Split('/')[path.Split('/').Length-1];
                    newfilename = GetFileName() + ".pdf";
                    if (File.Exists(Server.MapPath(path))) { //检查源文件是否存在                       
                        sql = @"
                            SELECT * from t_uploadfile where groupid=22454 AND TableID={0} AND FileName='{1}'
                        ";
                        sql = string.Format(sql, mlid, dt.Rows[i]["FileName"].ToString());
                        using (DataTable dr = sqlhelp.ExecuteDataTable(sql))
                        {
                            if (dr.Rows.Count == 0)//则同一份mlid里面不能传相同的报告
                            {
                                File.Copy(Server.MapPath(path), Server.MapPath(toPath + newfilename), true);
                                if (File.Exists(Server.MapPath(toPath + newfilename)))
                                {
                                    //检查是否复制成功，成功则接着写入数据库                                                        
                                    sql = " INSERT INTO t_uploadfile(TableID,GroupID,URLAddress,CreateDate,FileName) values(@mlid,'22454',@url,GETDATE(),@FileName); ";
                                    List<SqlParameter> paras = new List<SqlParameter>();
                                    paras.Add(new SqlParameter("@mlid", mlid));
                                    paras.Add(new SqlParameter("@url", toPath + newfilename));
                                    paras.Add(new SqlParameter("@FileName", dt.Rows[i]["FileName"].ToString()));
                                    errInfo = dal.ExecuteNonQuerySecurity(sql, paras);
                                    if (errInfo == "")
                                        sucCount++;
                                    else
                                        errs += errInfo + "|";
                                }
                            }
                        }
                    }
                }//end for  
                if (errs == "")
                    errInfo = "成功复制" + sucCount.ToString() + "份报告！";
                else
                    errInfo = errs;
            }
        }
        return errInfo;
    }

    /// <summary>
    /// 生成文件名
    /// </summary>
    /// <returns></returns>
    public static string GetFileName()
    {
        Random rd = new Random();
        StringBuilder serial = new StringBuilder();
        serial.Append(DateTime.Now.ToString("yyyyMMddHHmmssff"));
        serial.Append(rd.Next(0, 999999).ToString());
        return serial.ToString();

    }

</script>
