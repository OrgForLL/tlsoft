﻿<%@ Page Language="C#" %>
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

    static LiLanzDAL sqlhelp = new LiLanzDAL();
    string url= "http://webt.lilang.com:9030/";

    public static class SynchronousDate
    {
        //验证调用的合法性       
        //String ctrl = "";
        //String userid = "0";
        //String username = "自动同步";

        public static string tbData(String ctrl,String userid,String username,String date,String ids)
        {
            //实验报告文件保存位置        
            String path = HttpContext.Current.Server.MapPath("../MyUpload/" + DateTime.Now.ToString("yyyyMM")+"/");
            String rtMsg = "";
            if (userid == "" || userid == null) {
                rtMsg = @"{""type"":""ERROR"",""msg"":""SESSION丢失，非法调用！""}";
            }
            else if (ctrl == "" || ctrl == null)
            {
                rtMsg = @"{""type"":""ERROR"",""msg"":""ctrl参数有误！""}";
            }
            else
            {
                switch (ctrl)
                {
                    case "syncData1":
                        string bdate = date;
                        string edate = date;
                        if (bdate == "" || bdate == null || edate == "" || edate == null)
                            rtMsg = @"{""type"":""ERROR"",""msg"":""日期参数有误！""}";
                        else
                        {
                            String fz = pullDatas(bdate, edate);  //福州
                            if (fz.IndexOf("WARN") > -1)
                            {
                                rtMsg = @"{""type"":""WARN"",""msg"":""检测数据不存在！！！""}";
                            }
                            else if (fz.IndexOf("SUCCESS") > -1 || fz.IndexOf("WARN") > -1)
                            {
                                rtMsg = @"{""type"":""SUCCESS""}";
                            }
                            else
                            {
                                rtMsg = @"{""type"":""ERROR"",""msg"":""检测数据同步失败！！！""}";
                            }
                        }
                        break;
                    case "syncData2":
                        bdate = date;
                        edate = date;
                        if (bdate == "" || bdate == null || edate == "" || edate == null)
                            rtMsg = @"{""type"":""ERROR"",""msg"":""日期参数有误！""}";
                        else
                        {
                            string gz = pullDatas1(bdate, edate); //广州
                            if (gz.IndexOf("WARN") > -1)
                            {
                                rtMsg = @"{""type"":""WARN"",""msg"":""检测数据不存在！！！""}";
                            }
                            else if (gz.IndexOf("SUCCESS") > -1 || gz.IndexOf("WARN") > -1)
                            {
                                rtMsg = @"{""type"":""SUCCESS""}";
                            }
                            else
                            {
                                rtMsg = @"{""type"":""ERROR"",""msg"":""检测数据同步失败！！！""}";
                            }
                        }
                        break;
                    case "downPDF":
                        if (ids == "" || ids == null)
                            rtMsg = @"{""type"":""ERROR"",""msg"":""参数【IDS】错误！""}";
                        else
                            rtMsg = downloadPDF(path,ids);
                        break;
                    default:
                        rtMsg = @"{""type"":""ERROR"",""msg"":""无ctrl对应操作！""}";
                        break;
                }
            }
            return rtMsg;
        }

        //调用实验室接口将报告信息存到本地数据库中
        public static string pullDatas(String bdate, String edate)
        {
            String url = @"http://www.ffib.cn/query/55a81b96c60f8918e43.php?bdate={0}&edate={1}";
            String rtMsg = "",jls="0";
            url = String.Format(url, bdate, edate);
            String JSONdate = clsNetExecute.HttpRequest(url);
            if (JSONdate != "Not+Found")
            {
                //替换掉/
                JSONdate=JSONdate.Replace("样品货/款号", "样品货款号");
                JSONdate = ToDBC(JSONdate);
                Regex rgx = new Regex(@"\\[^btnfr\\/]");
                string replacement = " ";
                JSONdate = rgx.Replace(JSONdate, replacement);
                JSONdate = JSONdate.Replace("<br/>", "");

                Root root = JsonConvert.DeserializeObject<Root>(JSONdate);

                if (root.data.Count != 0)
                {
                    String zdr = "自动同步";
                    StringBuilder strSQL = new StringBuilder();
                    strSQL.Append("declare @id int;declare @jls int;set @jls=0;");
                    String zSQL = @"if not exists(select top 1 1 from yf_t_syjcbg where bgbh='{0}')    
										begin                                  
										insert into yf_t_syjcbg(bgbh,ypmc,yphh,syrq,czrq,jcyj,aqdj,jcjg,pdf,localpdf,tbr,tbsj,wtid)
										values ('{1}','{2}','{3}','{4}','{5}','{6}','{7}','{8}','{9}','','{10}','{11}','{12}');
										set @id=(select SCOPE_IDENTITY());set @jls=@jls+1; ";
                    String mSQL = @"insert into yf_t_syjcbgmxb(id,jcxmmc,csff,jsyq,jcjg,dxpd) values (@id,'{0}','{1}','{2}','{3}','{4}');";
                    for (int i = 0; i < root.data.Count; i++)
                    {
                        String yphh = root.data[i].样品货款号;
                        if (yphh.IndexOf("(NO:") > -1)
                            yphh = yphh.Substring(0, yphh.IndexOf("(NO:"));
                        strSQL.Append(String.Format(zSQL, root.data[i].报告编号, root.data[i].报告编号,
                            root.data[i].样品名称, yphh, root.data[i].送样日期,
                            root.data[i].出证日期, root.data[i].检测依据, root.data[i].安全技术等级,
                            root.data[i].检验结论, root.data[i].下载地址, zdr, DateTime.Now.ToString(), root.data[i].委托序号));
                        List<RowItem> row = root.data[i].row;
                        if (row.Count > 0)
                        {
                            for (int j = 0; j < row.Count; j++)
                            {
                                strSQL.Append(String.Format(mSQL, row[j].检测项目, row[j].测试方法,
                                    row[j].技术要求, row[j].检测结果, row[j].单项判定));
                            }
                            strSQL.Append("end;");
                        }
                    }
                    strSQL.Append("select @jls;");
                    using (LiLanzDALForXLM dal = new LiLanzDALForXLM())
                    {
                        DataTable dt = null;
                        rtMsg = dal.ExecuteQuery(strSQL.ToString(), out dt);
                        if (rtMsg == "" && dt.Rows.Count > 0)
                            jls = dt.Rows[0][0].ToString();
                    }
                    if (rtMsg == "")
                    {
                        rtMsg = @"{{""type"":""SUCCESS"",""msg"":""成功同步【{0}】条数据！""}}";
                        rtMsg = String.Format(rtMsg, jls);
                    }
                }

            }
            else
                rtMsg = @"{""type"":""WARN"",""msg"":""Sorry,没有找到数据！""}";                
                
            return rtMsg;
        }

        /// <summary>
        /// 调用广州提供的接口获取检测数据并存储到本地数据库中
        /// </summary>
        /// <param name="startDate">开始日期</param>
        /// <param name="endDate">结束日期</param>
        /// <returns></returns>
        public static string pullDatas1(String startDate, String endDate)
        {
            String url = @"http://www.ffib.cn/query/55a81b96c60f8918e43.php?bdate={0}&edate={1}";
            String rtMsg = "",jls="0";
            url = String.Format(url, startDate, endDate);
            String JsonStr = clsNetExecute.HttpRequest(url);
            if (JsonStr != "Not+Found") //没有数据
            {
                List<zbInfo> data = GetAllInfo(JsonStr);

                if (data.Count != 0)
                {
                    String zdr = "自动同步";
                    StringBuilder strSQL = new StringBuilder();
                    strSQL.Append("declare @id int;declare @jls int;set @jls=0;");
                    String zSQL = @"if not exists(select top 1 1 from yf_t_syjcbg where bgbh='{0}')    
                                        begin                                  
                                        insert into yf_t_syjcbg(bgbh,ypmc,yphh,syrq,czrq,jcyj,aqdj,jcjg,pdf,localpdf,tbr,tbsj,wtid)
                                        values ('{1}','{2}','{3}','{4}','{5}','{6}','{7}','{8}','{9}','','{10}','{11}','{12}');
                                        set @id=(select SCOPE_IDENTITY());set @jls=@jls+1; ";
                    String mSQL = @"insert into yf_t_syjcbgmxb(id,jcxmmc,csff,jsyq,jcjg,dxpd) values (@id,'{0}','{1}','{2}','{3}','{4}');";
                    for (int i = 0; i < data.Count; i++)
                    {
                        String yphh = data[i].样品货款号;
                        strSQL.Append(String.Format(zSQL, data[i].报告编号, data[i].报告编号,
                            data[i].样品名称, yphh, data[i].送样日期,
                            data[i].出证日期, data[i].检测依据, data[i].安全技术等级,
                            data[i].检验结论, data[i].下载地址, zdr, DateTime.Now.ToString(), data[i].委托序号));
                        List<ItemInfo> itemInfos = data[i].itemInfos;
                        if (itemInfos.Count > 0)
                        {
                            for (int j = 0; j < itemInfos.Count; j++)
                            {
                                strSQL.Append(String.Format(mSQL, itemInfos[j].检测项目, itemInfos[j].测试方法,
                                    itemInfos[j].技术要求, itemInfos[j].检测结果, itemInfos[j].单项判定));
                            }
                            strSQL.Append("end;");
                        }
                    }
                    strSQL.Append("select @jls;");
                    using (LiLanzDALForXLM dal = new LiLanzDALForXLM())
                    {
                        DataTable dt = null;
                        rtMsg = dal.ExecuteQuery(strSQL.ToString(), out dt);
                        if (rtMsg == "" && dt.Rows.Count > 0)
                            jls = dt.Rows[0][0].ToString();
                    }
                    if (rtMsg == "")
                    {
                        rtMsg = @"{{""type"":""SUCCESS"",""msg"":""成功同步【{0}】条数据！""}}";
                        rtMsg = String.Format(rtMsg, jls);
                    }
                }
            }
            else
                rtMsg = @"{""type"":""WARN"",""msg"":""Sorry,没有找到数据！""}";

            return rtMsg;
        }

        //下载接口
        public static String downloadPDF(string id,string URL, String path, string filename)
        {
            String rtMsg = "";
            String strPath = Path.GetDirectoryName(path);
            String _filename = "";
            if (!Directory.Exists(strPath))
            {
                Directory.CreateDirectory(strPath);
            }
            try
            {
                System.Net.HttpWebRequest Myrq = (System.Net.HttpWebRequest)System.Net.HttpWebRequest.Create(URL);
                System.Net.HttpWebResponse myrp = (System.Net.HttpWebResponse)Myrq.GetResponse();
                long totalBytes = myrp.ContentLength;
                System.IO.Stream st = myrp.GetResponseStream();
                byte[] by = new byte[1024];
                int osize = st.Read(by, 0, (int)by.Length);
                int errSite = -1;
                //有PDF URL地址不代表文件一定存在 检测机构有可能后面才会生成文件！
                errSite = System.Text.Encoding.Default.GetString(by).IndexOf("深空Web应用防火墙");
                if (errSite < 0)
                {
                    _filename = filename;
                    filename = path + filename;
                    System.IO.Stream so = new System.IO.FileStream(filename, System.IO.FileMode.Create);
                    long totalDownloadedByte = 0;//下载的总字节数B

                    while (osize > 0)
                    {
                        totalDownloadedByte = osize + totalDownloadedByte;
                        so.Write(by, 0, osize);
                        osize = st.Read(by, 0, (int)by.Length);
                    }
                    so.Close();
                    st.Close();
                    //更新记录
                    using (LiLanzDALForXLM dal = new LiLanzDALForXLM())
                    {
                        string sql = "update yf_t_syjcbg set localpdf=@pdfadd where id=@id";
                        List<SqlParameter> paras = new List<SqlParameter>();
                        paras.Add(new SqlParameter("@pdfadd", "MyUpload/" + DateTime.Now.ToString("yyyyMM")+"/" + _filename));
                        paras.Add(new SqlParameter("@id", id));
                        rtMsg = dal.ExecuteNonQuerySecurity(sql, paras);
                    }
                }
                else
                    rtMsg = errSite.ToString();
            }
            catch (Exception ex)
            {
                rtMsg = @"{{""type"":""ERROR"",""msg"":""{0}""}}";
                rtMsg = String.Format(rtMsg, ex.Message);
            }

            return rtMsg;
        }

        public static String downloadPDF(string path ,string ids)
        {
            String rtMsg = "",URL="",filename="",ID="";
            int succCount = 0, failCount = 0;
            using (LiLanzDALForXLM dal = new LiLanzDALForXLM()) {
                DataTable dt = null;
                String strsql = "select id,bgbh,pdf from yf_t_syjcbg where id in (" + ids + ")";                

                String rt = dal.ExecuteQuery(strsql, out dt);
                if (rt == "" && dt.Rows.Count > 0)
                {
                    if (dt.Rows.Count > 0)
                    {
                        for (int i = 0; i < dt.Rows.Count; i++)
                        {
                            ID = dt.Rows[i]["id"].ToString();
                            filename = DateTime.Now.ToString("yyyyMMdd") + dt.Rows[i]["bgbh"].ToString() + ".pdf";
                            URL = dt.Rows[i]["pdf"].ToString().Replace("\\", "");
                            if (!URL.Contains("http://") || !URL.Contains("https://"))
                                URL = "http://" + URL;
                            rtMsg = downloadPDF(ID, URL, path, filename);
                            if (rtMsg == "")
                                succCount++;
                            else
                                failCount++;
                        }
                        rtMsg = @"{{""type"":""SUCCESS"",""msg"":""总共提交【{0}】条数据，成功:{1}，失败:{2}""}}";
                        rtMsg = String.Format(rtMsg, succCount + failCount, succCount, failCount);
                    }
                    else
                        rtMsg = @"{""type"":""WARN"",""msg"":""数据库中找不到对应数据！""}";
                }
                else
                {
                    rtMsg = rt;
                }
            }

            return rtMsg;
        }

        /// <summary>
        /// 广州检测json解析
        /// </summary>
        /// <param name="JsonStr">广州检测数据json串</param>
        /// <returns></returns>
        public static List<zbInfo> GetAllInfo(string JsonStr)
        {
            clsJsonHelper jsonHelp = clsJsonHelper.CreateJsonHelper(JsonStr);
            List<clsJsonHelper> testItem = jsonHelp.GetJsonNodes("data");
            List<zbInfo> data = new List<zbInfo>();
            zbInfo zbinfo;
            ItemInfo itemInfo;
            for (int i = 0; i < testItem.Count; i++)
            {
                zbinfo = new zbInfo();
                List<ItemInfo> itemInfos = new List<ItemInfo>();
                zbinfo.委托序号 = testItem[i].GetJsonValue("委托序号");
                zbinfo.下载地址 = testItem[i].GetJsonValue("下载地址");
                zbinfo.报告编号 = testItem[i].GetJsonValue("报告编号");
                zbinfo.样品名称 = testItem[i].GetJsonValue("样品名称");
                zbinfo.样品货款号 = testItem[i].GetJsonValue("样品货款号");
                zbinfo.安全技术等级 = testItem[i].GetJsonValue("安全技术等级");
                zbinfo.送样日期 = testItem[i].GetJsonValue("送样日期");
                zbinfo.出证日期 = testItem[i].GetJsonValue("出证日期");
                zbinfo.检测依据 = testItem[i].GetJsonValue("检测依据");
                zbinfo.检验结论 = testItem[i].GetJsonValue("检验结论");

                for (int j = 0; j < testItem[i].GetJsonNodes("ItemData").Count; j++)
                {
                    itemInfo = new ItemInfo();
                    itemInfo.检测项目 = testItem[i].GetJsonNodes("ItemData")[j].GetJsonValue("检测项目");
                    itemInfo.测试方法 = testItem[i].GetJsonNodes("ItemData")[j].GetJsonValue("测试方法");
                    itemInfo.技术要求 = testItem[i].GetJsonNodes("ItemData")[j].GetJsonValue("技术要求");
                    itemInfo.检测结果 = testItem[i].GetJsonNodes("ItemData")[j].GetJsonValue("检测结果");
                    itemInfo.单项判定 = testItem[i].GetJsonNodes("ItemData")[j].GetJsonValue("单项判定");
                    itemInfos.Add(itemInfo);
                }
                zbinfo.itemInfos = itemInfos;
                data.Add(zbinfo);
            }
            return data;
        }

        //转半角
        public static String ToDBC(String input)
        {
            char[] c = input.ToCharArray();
            for (int i = 0; i < c.Length; i++)
            {
                if (c[i] == 12288)
                {
                    c[i] = (char)32;
                    continue;
                }
                if (c[i] > 65280 && c[i] < 65375)
                    c[i] = (char)(c[i] - 65248);
            }
            return new String(c);
        }
    }

    public static class PDFUploadCZ
    {
        public static string Zyff(String ctrl, String userid, String ids, String mlid, String zd, String mxid)
        {
            String rtMsg = "";

            if (userid == "" || userid == null)
            {
                rtMsg = "SESSION过期，请重新登陆！";
                return rtMsg;
            }

            if (ctrl == "" || ctrl == null)
            {
                rtMsg = "缺少CTRL参数！";
                return rtMsg;
            }

            switch (ctrl)
            {
                case "upload":
                    rtMsg=UploadPDF(ids, mlid, zd);
                    break;
                case "delete":
                    rtMsg=DeletePDF(mxid, zd);
                    break;
                default:
                    rtMsg = "无CTRL对应操作！";
                    break;
            }

            return rtMsg;
        }
        //上传操作，将文件复制一份出来并写入数据库
        public static string UploadPDF(string ids, string mlid, string zd)
        {
            String[] tmp = ids.Split(',');
            DataTable dt = null;
            String errInfo = "";
            using (LiLanzDALForXLM dal = new LiLanzDALForXLM())
            {
                String sql = "select localpdf from yf_t_syjcbg where id in (" + ids + ");";
                errInfo = dal.ExecuteQuery(sql, out dt);
                if (errInfo == "" && dt.Rows.Count > 0)
                {
                    String path = "", filename = "", newfilename = "", errs = "";
                    String toPath = "../photo/sygzb_pdf/";
                    int value = 0, sucCount = 0;
                    if (zd == "sygzb_tp")
                        value = 3311;
                    else if (zd == "sygzb_sg")
                        value = 3312;
                    //生成文件名                
                    for (int i = 0; i < dt.Rows.Count; i++)
                    {
                        path = "../" + dt.Rows[i]["localpdf"].ToString();
                        filename = path.Split('/')[path.Split('/').Length - 1];
                        newfilename = "_" + i.ToString() + "@" + DateTime.Now.ToFileTime() + ".pdf";
                        if (File.Exists(HttpContext.Current.Server.MapPath(path)))
                        {
                            //检查源文件是否存在
                            sql = @"
                                SELECT * FROM ghs_t_zldamxb WHERE mlid='{0}' and text1='{1}'
                            ";
                            sql = string.Format(sql, mlid, filename);
                            using (DataTable dr = sqlhelp.ExecuteDataTable(sql))
                            {
                                if (dr.Rows.Count == 0)//则同一份mlid里面不能传相同的报告
                                {
                                    File.Copy(HttpContext.Current.Server.MapPath(path), HttpContext.Current.Server.MapPath(toPath + newfilename), true);
                                    if (File.Exists(HttpContext.Current.Server.MapPath(toPath + newfilename)))
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
                    }//end for  
                    if (errs == "")
                        errInfo = "成功复制【" + sucCount.ToString() + "】份报告！";
                    else
                        errInfo = errs;
                }
            }
            return errInfo;
        }

        //删除文件，并操作数据库
        public static string DeletePDF(String mxid, String zd)
        {
            String errInfo = "";
            String path = "../photo/sygzb_pdf/";
            using (LiLanzDALForXLM dal = new LiLanzDALForXLM())
            {
                DataTable dt = null;
                String sql = "select top 1 text from ghs_t_zldamxb where mxid=@mxid;";
                List<SqlParameter> paras = new List<SqlParameter>();
                paras.Add(new SqlParameter("@mxid", mxid));
                errInfo = dal.ExecuteQuerySecurity(sql, paras, out dt);
                if (errInfo == "" && dt.Rows.Count > 0)
                {
                    String filename = dt.Rows[0]["text"].ToString();
                    if (File.Exists(HttpContext.Current.Server.MapPath(path + filename)))
                    {
                        File.Delete(HttpContext.Current.Server.MapPath(path + filename));
                    }

                    if (!File.Exists(HttpContext.Current.Server.MapPath(path + filename)))
                    {
                        //不存在了代表删除成功
                        sql = "delete from ghs_t_zldamxb where mxid=@mxid and zd=@zd;";
                        paras.Clear();
                        paras.Add(new SqlParameter("@mxid", mxid));
                        paras.Add(new SqlParameter("@zd", zd));
                        errInfo = dal.ExecuteNonQuerySecurity(sql, paras);
                    }
                }
            }

            if (errInfo == "")
                return "删除成功！";
            return "删除失败！";
        }
    }

    protected void Page_Load(object sender, EventArgs e)
    {
        int cgNum = 0;
        //同步数据 start		
        string date = DateTime.Now.ToString("yyyy-MM-dd");
        if(Request["date"]!=null){
            date=Request["date"];
        }
        string userid = "0";

        string tbInfo = SynchronousDate.tbData("syncData1",userid,"自动同步",date,"");//福州
        //string tbInfo1 = sDate.tbData("syncData2",userid,"自动同步",date);//广州
        //string tbInfo = HttpGet(url + "/interface/getExpReportv2.aspx", "ctrl=syncData1&userid=" + userid + "&bdate=" + date + "&edate=" + date);
        if (tbInfo.IndexOf("SUCCESS") > -1)
        {
            string ids = GetTBSJIDS(date);
            //下载pdf到本地 start 
            string downPDFInfo = SynchronousDate.tbData("downPDF",userid,"自动同步","",ids);//福州
            //string downPDFInfo = HttpGet(url + "/interface/getExpReportv2.aspx", "ctrl=downPDF&userid=" + userid + "&ids=" + ids);
            if (downPDFInfo.IndexOf("SUCCESS") > -1)
            {
                DataView data = GetTBJL(date).DefaultView;
                if (data.Count > 0)
                {
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

                    //Response.Write("成功【" + cgNum + "】条");
                    Response.Write("成功");
                    Response.End();
                }
                else
                {
                    writeLog("没有对应的委托单！！！"); //创建日志
                    Response.Write("没有对应的委托单！！！");
                    Response.End();
                }
            }
            else if (downPDFInfo.IndexOf("SUCCESS") == -1 || downPDFInfo.IndexOf("WARN") == -1)
            {
                writeLog("下载pdf失败！！！  "+downPDFInfo); //创建日志
                Response.Write("下载pdf失败！！！");
                Response.End();
            }
            //下载pdf到本地 end     
        }
        else if (tbInfo.IndexOf("WARN") > -1)
        {
            writeLog(tbInfo); //创建日志
            Response.Write("检测数据不存在！！！");
            Response.End();
        }
        else
        {
            writeLog(tbInfo); //创建日志
            Response.Write("同步失败！！！");
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
            WHERE CONVERT(VARCHAR(50),czrq,112)=CONVERT(VARCHAR(50),CAST('{0}' AS DATETIME),112)
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
            SELECT b.sygzid mlid,b.djlx,a.id,a.bgbh,a.jcjg
            FROM yf_t_syjcbg a
            INNER JOIN yf_t_wtjyxy b ON a.wtid=b.id
            WHERE CONVERT(VARCHAR(50),a.czrq,112)=CONVERT(VARCHAR(50),CAST('{0}' AS DATETIME),112)
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
            //Zyff(String ctrl, String userid, String ids, String mlid, String zd, String mxid, string StartPath)
            if (PDFUploadCZ.Zyff("upload", userid, ids, dr["mlid"].ToString(), zd, "").IndexOf("成功复制") > -1)
            {
                ztsm++;
            }
        }
        //Response.Write("成分:" + ztsm + "<br/>");
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
            dv.RowFilter = "djlx='3311' and mlid=" + dr["mlid"] + " and (bgbh like '%P' or jcjg='合格') ";
            string ids = "0";
            foreach (DataRow dr1 in dv.ToTable().Select())
            {
                ids += "," + dr1["id"];
            }
            if (PDFUploadCZ.Zyff("upload", userid, ids, dr["mlid"].ToString(), zd, "").IndexOf("成功复制") > -1)
            {
                ztsm++;
            }
            //上传不合格
            dv.RowFilter = "djlx='3311' and mlid=" + dr["mlid"] + " and bgbh like '%F' ";
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
        //Response.Write("贴牌:" + ztsm + "<br/>");
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
        string str="";
        foreach (DataRow dr in mlidb.Select())
        {
            string iscg = "0";
            //上传合格
            dv.RowFilter = "djlx='3312' and mlid=" + dr["mlid"] + " and (bgbh like '%P' or jcjg='合格') ";
            string ids = "0";
            foreach (DataRow dr1 in dv.ToTable().Select())
            {
                ids += "," + dr1["id"];
            }
            if (PDFUploadCZ.Zyff("upload", userid, ids, dr["mlid"].ToString(), zd, "").IndexOf("成功复制") > -1)
            {
                ztsm++;
            }
						//str+="zzinfo:"+zzinfo+";iscg:"+iscg+";"+"mlid:"+dr["mlid"]+";"+ids+"<br/>\n";
            //上传不合格
            dv.RowFilter = "djlx='3312' and mlid=" + dr["mlid"] + " and bgbh like '%F' ";
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
        //Response.Write(str);        
        return ztsm;
    }

    /// <summary>
    /// 上传操作，将文件复制一份出来并写入数据库
    /// </summary>
    /// <param name="ids"></param>
    /// <param name="mlid">送样跟踪id</param>
    /// <param name="zd">说明单据的类型 sygzb_tp：贴牌；sygzb_sg：自制；sygzb_cfbg：成分；</param>
    /// <returns>返回值包含’成功复制‘表示成功</returns>
    public string UploadPDF(string ids,string mlid,string zd)
    {
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

    /// <summary>
    /// 写日志文件方法
    /// </summary>
    /// <param name="info"></param>
    public static void writeLog(string info)
    {
        try
        {
            clsLocalLoger.logDirectory = HttpContext.Current.Server.MapPath("ZDTBLogs/");
            if (Directory.Exists(clsLocalLoger.logDirectory) == false)
            {
                Directory.CreateDirectory(clsLocalLoger.logDirectory);
            }
            clsLocalLoger.WriteInfo(info);
        }
        catch (Exception ex)
        {

        }
    }

    public class RowItem
    {
        private string _检测项目;
        /// <summary>

        /// </summary>
        public string 检测项目
        {
            get { return this._检测项目; }
            set { this._检测项目 = value; }
        }
        private string _测试方法;
        /// <summary>
        /// 
        /// </summary>
        public string 测试方法
        {
            get { return this._测试方法; }
            set { this._测试方法 = value; }
        }
        private string _技术要求;
        /// <summary>
        /// 
        /// </summary>
        public string 技术要求
        {
            get { return this._技术要求; }
            set { this._技术要求 = value; }
        }
        private string _检测结果;
        /// <summary>

        /// </summary>
        public string 检测结果
        {
            get { return this._检测结果; }
            set { this._检测结果 = value; }
        }
        private string _单项判定;
        /// <summary>
        /// 
        /// </summary>
        public string 单项判定
        {
            get { return this._单项判定; }
            set { this._单项判定 = value; }
        }
    }

    public class DataItem
    {
        public string _委托序号;
        /// <summary>
        /// 
        /// </summary>
        public string 委托序号
        {
            get { return this._委托序号; }
            set { this._委托序号 = value; }
        }
        public string _下载地址;
        /// <summary>
        /// 
        /// </summary>
        public string 下载地址
        {
            get { return this._下载地址; }
            set { this._下载地址 = value; }
        }
        public string _报告编号;
        /// <summary>
        /// 
        /// </summary>
        public string 报告编号
        {
            get { return this._报告编号; }
            set { this._报告编号 = value; }
        }

        public string _样品名称;
        /// <summary>

        /// </summary>
        public string 样品名称
        {
            get { return this._样品名称; }
            set { this._样品名称 = value; }
        }
        public string _样品货款号;
        /// <summary>
        /// 
        /// </summary>
        public string 样品货款号
        {
            get { return this._样品货款号; }
            set { this._样品货款号 = value; }
        }
        public string _安全技术等级;
        /// <summary>
        /// 
        /// </summary>
        public string 安全技术等级
        {
            get { return this._安全技术等级; }
            set { this._安全技术等级 = value; }
        }
        public string _送样日期;
        /// <summary>
        /// 
        /// </summary>
        public string 送样日期
        {
            get { return this._送样日期; }
            set { this._送样日期 = value; }
        }
        public string _出证日期;
        /// <summary>
        /// 
        /// </summary>
        public string 出证日期
        {
            get { return this._出证日期; }
            set { this._出证日期 = value; }
        }
        public string _检测依据;
        /// <summary>
        /// 
        /// </summary>
        public string 检测依据
        {
            get { return this._检测依据; }
            set { this._检测依据 = value; }
        }
        public string _检验结论;
        /// <summary>
        /// 
        /// </summary>
        public string 检验结论
        {
            get { return this._检验结论; }
            set { this._检验结论 = value; }
        }
        public List<RowItem> _row;
        /// <summary>
        /// 
        /// </summary>
        public List<RowItem> row
        {
            get { return this._row; }
            set { this._row = value; }
        }
    }

    public class Root
    {
        private List<DataItem> _data;
        /// <summary>
        /// 
        /// </summary>
        public List<DataItem> data
        {
            get { return this._data; }
            set { this._data = value; }
        }
    }

    /// <summary>
    /// 广州检测记录主信息
    /// </summary>
    public class zbInfo
    {
        public string 委托序号;
        public string 下载地址;
        public string 报告编号;
        public string 样品名称;
        public string 样品货款号;
        public string 安全技术等级;
        public string 送样日期;
        public string 出证日期;
        public string 检测依据;
        public string 检验结论;
        public List<ItemInfo> itemInfos;
    }

    /// <summary>
    /// 广州检测记录检测项目信息
    /// </summary>
    public class ItemInfo
    {
        public string 检测项目;
        public string 测试方法;
        public string 技术要求;
        public string 检测结果;
        public string 单项判定;
    }

</script>
