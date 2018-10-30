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
        //同步数据 start
        TimeSpan ts = DateTime.UtcNow - new DateTime(1970, 1, 1, 0, 0, 0, 0);
        string now = Convert.ToInt64(ts.TotalSeconds).ToString();
        string date = DateTime.Now.ToString("yyyy-MM-dd");
        if (Request["date"] != null) date = DateTime.Parse(Request["date"].ToString()).ToString("yyyy-MM-dd");
        //0:：福州；1：广州,2:天津
        string bs = "0";
        if (Request["bs"] != null) bs = Request["bs"];
        SynchronousDate synchronousDate = new SynchronousDate();
        string tbInfo = synchronousDate.SyncData(bs, "自动同步" + now, date);

        int cgNum = 0;
        if (tbInfo.IndexOf("SUCCESS") > -1)
        {
            //下载pdf到本地 start
            string downPDFInfo = synchronousDate.DownPDF(GetTBSJIDS(date, bs, "自动同步" + now));

            if (downPDFInfo.IndexOf("SUCCESS") > -1)
            {
                DataView data = GetTBJL(date, bs).DefaultView;
                if (data.Count > 0)
                {
                    //上传成分的检测pdf start
                    data.RowFilter = "djlx=3313";
                    cgNum += UploadCF(data);
                    data.RowFilter = "";
                    //上传成分的检测pdf end
                    //上传自制的检测pdf start
                    data.RowFilter = "djlx=3312";
                    cgNum += UploadZZ(data);
                    data.RowFilter = "";
                    //上传自制的检测pdf end
                    //上传贴牌的检测pdf start
                    data.RowFilter = "djlx=3311";
                    cgNum += UploadTP(data);
                    data.RowFilter = "";
                    //上传贴牌的检测pdf end

                    //Response.Write("成功【" + cgNum + "】条");
                    Response.Write("成功");
                    Response.End();
                }
                else
                {
                    WriteLog("没有对应的委托单！！！"); //创建日志
                    Response.Write("没有对应的委托单！！！");
                    Response.End();
                }
            }
            else if (downPDFInfo.IndexOf("SUCCESS") == -1 || downPDFInfo.IndexOf("WARN") == -1)
            {
                WriteLog("下载pdf失败！！！  " + downPDFInfo); //创建日志
                Response.Write("下载pdf失败！！！");
                Response.End();
            }
            //下载pdf到本地 end
        }
        else if (tbInfo.IndexOf("WARN") > -1)
        {
            WriteLog(tbInfo); //创建日志
            Response.Write("检测数据不存在！！！");
            Response.End();
        }
        else
        {
            WriteLog(tbInfo); //创建日志
            Response.Write("同步失败！！！");
            Response.End();
        }
        //同步数据 end
    }

    public class SynchronousDate
    {
        /// <summary>
        /// 同步数据
        /// </summary>
        /// <param name="ctrl"></param>
        /// <param name="username"></param>
        /// <param name="date"></param>    
        /// <returns></returns>
        public string SyncData(string ctrl, string username, string date)
        {
            string rtMsg = "";
            string bdate = date;
            string edate = date;
            string fz = "";
            if (bdate == "" || bdate == null || edate == "" || edate == null)
                rtMsg = @"{""type"":""ERROR"",""msg"":""日期参数有误！""}";
            else
            {
                if (ctrl == "0")
                    fz = PullFZDatas(bdate, edate, username);  //福州
                else if (ctrl == "1")
                    fz = PullGZDatas(bdate, edate, username); //广州
                else if (ctrl == "2")
                    fz = PullTJDatas(bdate, edate, username);  //天津

                if (fz.IndexOf("WARN") > -1)
                    rtMsg = @"{""type"":""WARN"",""msg"":""检测数据不存在！！！""}";
                else if (fz.IndexOf("SUCCESS") > -1 || fz.IndexOf("WARN") > -1)
                    rtMsg = @"{""type"":""SUCCESS""}";
                else
                    rtMsg = @"{""type"":""ERROR"",""msg"":""检测数据同步失败！！！""}";
            }

            return rtMsg;
        }


        /// <summary>
        /// 下载PDF
        /// </summary>  
        /// <param name="ids"></param>
        /// <returns></returns>
        public string DownPDF(string ids)
        {

            string rtMsg = "";
            if (ids == "" || ids == null)
                rtMsg = @"{""type"":""ERROR"",""msg"":""参数【IDS】错误！""}";
            else
            {
                //实验报告文件保存位置
                rtMsg = DownloadPDF(HttpContext.Current.Server.MapPath("../MyUpload/" + DateTime.Now.ToString("yyyyMM") + "/"), ids);
            }
            return rtMsg;
        }

        //调用实验室接口将报告信息存到本地数据库中-天津
        public string PullTJDatas(string bdate, string edate, string username)
        {
            string rtMsg = "";
            string jls = "0";
            // 请求对象
            ReportsListRequestStructBean RequestBean = new ReportsListRequestStructBean();
            // 请求头对象
            RequestHeadStc Head = new RequestHeadStc();
            // 请用户名
            Head.AppKey = "lilang";
            // 请求用户密码
            Head.SecretKey = "96B94FF9-EC8A-4E73-8394-B97029C72DC8";
            // 请求方法
            Head.Method = "GetReportsList";
            // 请求唯一标识 建议用UUID 双方排查日志用
            Head.AskSerialNo = Guid.NewGuid().ToString();
            // 请求时间
            Head.SendTime = System.DateTime.Now.ToString("yyyyMMddHHmmss");
            // 请求体对象
            ReportsListInputStc Body = new ReportsListInputStc();
            Body.ProductName = "";
            Body.GoodsName = "";
            Body.EnterpriseNo = "";
            Body.TrustCustomerName = "";
            Body.MakeCustomerName = "";
            Body.TestItem = "";
            Body.FailItem = "";
            Body.ProductStandardNo = "";
            Body.MethodStandardNo = "";
            Body.TrustDateFrom = (Convert.ToDateTime(bdate)).AddDays(-30).ToString("yyyy-MM-dd");//委托日期
            Body.TrustDateTo = edate;
            Body.AuditDateFrom = bdate;//出证日期
            Body.AuditDateTo = (Convert.ToDateTime(bdate)).AddDays(1).ToString("yyyy-MM-dd");
            RequestBean.Head = Head;
            RequestBean.Body = Body;
            // 返回对象
            ReportsListResponseStructBean ResponseBean = new ReportsListResponseStructBean();
            // 请求功能URL
            string url = "http://data.cnttts.com:59600/dmz/v1/M0001";
            // 请求明细功能URL
            string urlDetail = "http://data.cnttts.com:59600/dmz/v1/M0002";
            string postJson = JsonConvert.SerializeObject(RequestBean, Newtonsoft.Json.Formatting.None);
            // 请求后台
            string retmp = "";
            try
            {
                retmp = PostFunction(url, postJson);
            }
            catch (SystemException ex)
            {
                rtMsg = @"{""type"":""ERROR"",""msg"":""无法链接天津外部服务器！""}";
                return rtMsg;
            }

            ResponseBean = JsonConvert.DeserializeObject<ReportsListResponseStructBean>(retmp);
            List<ResultContent> contentList = JsonConvert.DeserializeObject<List<ResultContent>>(ResponseBean.Body.ResultContent);
            if (contentList != null && contentList.Count > 0)
            {

                StringBuilder strSQL = new StringBuilder();
                strSQL.Append("declare @id int;declare @jls int;set @jls=0;");
                string zSQL = @"if not exists(select top 1 1 from yf_t_syjcbg where bgbh='{0}' and bs='2')
                                    begin
                                    insert into yf_t_syjcbg(bgbh,ypmc,yphh,syrq,czrq,jcyj,aqdj,jcjg,pdf,localpdf,tbr,tbsj,wtid,bs)
                                    values ('{0}','{1}','{2}','{3}','{4}','{5}','{6}','{7}','{8}','','{9}','{10}','{11}','2');
                                    set @id=(select SCOPE_IDENTITY());set @jls=@jls+1; ";
                string mSQL = @"insert into yf_t_syjcbgmxb(id,jcxmmc,csff,jsyq,jcjg,dxpd) values (@id,'{0}','{1}','{2}','{3}','{4}');";
                foreach (ResultContent r in contentList)
                {
                    if (r.urlpdf.IndexOf("http://") == 0)
                    {
                        r.urlpdf = r.urlpdf.Substring(7, r.urlpdf.Length - 7);
                    }
                    strSQL.Append(string.Format(zSQL, r.stfbreportno, r.ProductName, r.productsremark, r.AcceptDate, r.dapprovedate, "", r.SecurityCategories, (r.fails.Length == 0 ? "合格" : "不合格"), r.urlpdf, username, DateTime.Now.ToString(), r.SuperviseNoticeCode));
                    if (r.SuperviseNoticeCode.Length > 0)
                    {
                        ReportsRequestStructBean rep = new ReportsRequestStructBean();
                        ReportsInputStc body = new ReportsInputStc();
                        body.reportNO = r.SuperviseNoticeCode;
                        Head.Method = "getreportdetail";
                        rep.Head = Head; rep.Body = body;
                        // 返回对象
                        ReportsListResponseStructBean ReqBean = new ReportsListResponseStructBean();
                        string postJs = JsonConvert.SerializeObject(rep, Newtonsoft.Json.Formatting.None);
                        ReqBean = JsonConvert.DeserializeObject<ReportsListResponseStructBean>(PostFunction(urlDetail, postJs));
                        List<ResultContent> conList = JsonConvert.DeserializeObject<List<ResultContent>>(ReqBean.Body.ResultContent);
                        if (conList.Count > 0)
                        {
                            if (conList[0].detail.Count > 0)
                            {
                                foreach (Detail d in conList[0].detail)
                                {
                                    strSQL.Append(string.Format(mSQL, d.item, d.prefix, d.standvalue, d.acturevalue, d.result));
                                }
                            }
                        }
                    }
                    strSQL.Append("end;");
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
                    rtMsg = string.Format(rtMsg, jls);
                }
            }
            else
            {
                rtMsg = @"{""type"":""WARN"",""msg"":""Sorry,没有找到数据！""}";
            }

            return rtMsg;
        }

        //调用实验室接口将报告信息存到本地数据库中-福州
        public string PullFZDatas(string bdate, string edate, string username)
        {
            string url = @"http://www.ffib.cn/query/55a81b96c60f8918e43.php?bdate={0}&edate={1}";
            string rtMsg = "", jls = "0";
            url = string.Format(url, bdate, edate);
            string JSONdate = clsNetExecute.HttpRequest(url);
            if (JSONdate != "Not+Found")
            {
                //替换掉/
                JSONdate = JSONdate.Replace("样品货/款号", "样品货款号");
                //JSONdate = ToDBC(JSONdate);
                Regex rgx = new Regex(@"\\[^btnfr\\/]");
                string replacement = " ";
                JSONdate = rgx.Replace(JSONdate, replacement);
                JSONdate = JSONdate.Replace("<br />", "");

                Root root = JsonConvert.DeserializeObject<Root>(JSONdate);

                if (root.data.Count != 0)
                {
                    StringBuilder strSQL = new StringBuilder();
                    strSQL.Append("declare @id int;declare @jls int;set @jls=0;");
                    string zSQL = @"if not exists(select top 1 1 from yf_t_syjcbg where bgbh='{0}' and bs='0')
										begin
										insert into yf_t_syjcbg(bgbh,ypmc,yphh,syrq,czrq,jcyj,aqdj,jcjg,pdf,localpdf,tbr,tbsj,wtid,bs)
										values ('{1}','{2}','{3}','{4}','{5}','{6}','{7}','{8}','{9}','','{10}','{11}','{12}','0');
										set @id=(select SCOPE_IDENTITY());set @jls=@jls+1; ";
                    string mSQL = @"insert into yf_t_syjcbgmxb(id,jcxmmc,csff,jsyq,jcjg,dxpd) values (@id,'{0}','{1}','{2}','{3}','{4}');";
                    for (int i = 0; i < root.data.Count; i++)
                    {
                        string yphh = root.data[i].样品货款号;
                        if (yphh.IndexOf("(NO:") > -1)
                            yphh = yphh.Substring(0, yphh.IndexOf("(NO:"));
                        strSQL.Append(string.Format(zSQL, root.data[i].报告编号, root.data[i].报告编号,
                            root.data[i].样品名称, yphh, root.data[i].送样日期,
                            root.data[i].出证日期, root.data[i].检测依据, root.data[i].安全技术等级,
                            root.data[i].检验结论, root.data[i].下载地址, username, DateTime.Now.ToString(), root.data[i].委托序号));
                        if (root.data[i].row == null)
                        {
                            strSQL.Append("end;");
                            continue;
                        }
                        List<RowItem> row = root.data[i].row;
                        if (row.Count > 0)
                        {
                            for (int j = 0; j < row.Count; j++)
                            {
                                strSQL.Append(string.Format(mSQL, row[j].检测项目, row[j].测试方法,
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
                        rtMsg = string.Format(rtMsg, jls);
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
        public string PullGZDatas(string startDate, string endDate, string username)
        {
            string url = @"http://m.gtt.net.cn/WSInterface/Handler/GetReportData_LiLang.ashx?AccessToken=D3865E240DB0445A9245F51D85119FBA&BeginQueryDate={0}&EndQueryDate={1}";
            string rtMsg = "", jls = "0";
            url = string.Format(url, startDate, endDate);
            string JsonStr = clsNetExecute.HttpRequest(url);
            if (JsonStr != "[]") //没有数据
            {
                List<zbInfo> data = GetAllInfo(JsonStr);

                if (data.Count != 0)
                {
                    StringBuilder strSQL = new StringBuilder();
                    strSQL.Append("declare @id int;declare @jls int;set @jls=0;");
                    string zSQL = @"if not exists(select top 1 1 from yf_t_syjcbg where bgbh='{0}' and bs='1')
                                        begin
                                            insert into yf_t_syjcbg(bgbh,ypmc,yphh,syrq,czrq,jcyj,aqdj,jcjg,pdf,localpdf,tbr,tbsj,wtid,bs)
                                            values ('{1}','{2}','{3}','{4}','{5}','{6}','{7}','{8}','{9}','','{10}','{11}','{12}','1');
                                            set @id=(select SCOPE_IDENTITY());set @jls=@jls+1; ";
                    string mSQL = @"insert into yf_t_syjcbgmxb(id,jcxmmc,csff,jsyq,jcjg,dxpd) values (@id,'{0}','{1}','{2}','{3}','{4}');";
                    for (int i = 0; i < data.Count; i++)
                    {
                        string yphh = data[i].样品货款号;
                        strSQL.Append(string.Format(zSQL, data[i].报告编号, data[i].报告编号,
                            data[i].样品名称, yphh, data[i].送样日期,
                            data[i].出证日期, data[i].检测依据, data[i].安全技术等级,
                            data[i].检验结论, data[i].下载地址, username, DateTime.Now.ToString(), data[i].委托序号));
                        if (data[i].itemInfos == null)
                        {
                            strSQL.Append("end;");
                            continue;
                        }
                        List<ItemInfo> row = data[i].itemInfos;
                        if (row.Count > 0)
                        {
                            for (int j = 0; j < row.Count; j++)
                            {
                                strSQL.Append(string.Format(mSQL, row[j].检测项目, row[j].测试方法,
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
                        rtMsg = string.Format(rtMsg, jls);
                    }
                }
            }
            else
                rtMsg = @"{""type"":""WARN"",""msg"":""Sorry,没有找到数据！""}";

            return rtMsg;
        }

        /// <summary>
        /// 下载执行
        /// </summary>
        /// <param name="id"></param>
        /// <param name="URL"></param>
        /// <param name="path"></param>
        /// <param name="filename"></param>
        /// <returns></returns>
        public string DownloadPDFExecutor(string id, string URL, string path, string filename)
        {
            string rtMsg = "";
            string strPath = Path.GetDirectoryName(path);
            string _filename = "";
            if (!Directory.Exists(strPath))
                Directory.CreateDirectory(strPath);
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
                        paras.Add(new SqlParameter("@pdfadd", "MyUpload/" + DateTime.Now.ToString("yyyyMM") + "/" + _filename));
                        paras.Add(new SqlParameter("@id", id));
                        rtMsg = dal.ExecuteNonQuerySecurity(sql, paras);
                    }
                }
                else
                    rtMsg = errSite.ToString();
            }
            catch (Exception ex)
            {                
                rtMsg = string.Format(@"{{""type"":""ERROR"",""msg"":""{0}""}}", ex.Message);
            }

            return rtMsg;
        }

        /// <summary>
        /// 下载PDF
        /// </summary>
        /// <param name="path"></param>
        /// <param name="ids"></param>
        /// <returns></returns>
        public string DownloadPDF(string path, string ids)
        {
            string rtMsg = "", URL = "", filename = "", ID = "";
            int succCount = 0, failCount = 0;
            using (LiLanzDALForXLM dal = new LiLanzDALForXLM())
            {
                DataTable dt = null;
                string strsql = "select id,bgbh,pdf from yf_t_syjcbg where id in (" + ids + ")";

                string rt = dal.ExecuteQuery(strsql, out dt);
                if (rt == "" && dt.Rows.Count > 0)
                {
                    if (dt.Rows.Count > 0)
                    {
                        for (int i = 0; i < dt.Rows.Count; i++)
                        {
                            ID = dt.Rows[i]["id"].ToString();
                            URL = dt.Rows[i]["pdf"].ToString().Replace("\\", "");
                            filename = DateTime.Now.ToString("yyyyMMdd") + URL.Substring(URL.LastIndexOf("/") + 1, URL.Length - URL.LastIndexOf("/") - 1);

                            if (!URL.Contains("http://") || !URL.Contains("https://"))
                                URL = "http://" + URL;
                            rtMsg = DownloadPDFExecutor(ID, URL, path, filename);
                            if (rtMsg == "")
                                succCount++;
                            else
                                failCount++;
                        }
                        rtMsg = @"{{""type"":""SUCCESS"",""msg"":""总共提交【{0}】条数据，成功:{1}，失败:{2}""}}";
                        rtMsg = string.Format(rtMsg, succCount + failCount, succCount, failCount);
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
        public List<zbInfo> GetAllInfo(string JsonStr)
        {
            JsonStr = "{\"data\":" + JsonStr.Replace("\\", "").Replace("null", "\"\"") + "}";
            clsJsonHelper jsonHelp = clsJsonHelper.CreateJsonHelper(JsonStr);
            List<clsJsonHelper> testItem = jsonHelp.GetJsonNodes("data");
            List<clsJsonHelper> jcItem;
            List<zbInfo> data = new List<zbInfo>();
            List<ItemInfo> itemInfos;     //所有
            List<ItemInfo> itemInfoHgs;   //合格
            List<ItemInfo> itemInfoBhgs;  //不合格
            zbInfo zbinfo;
            ItemInfo mxinfo;
            string[] paths = null;
            string aqjsdj = ""; //安全技术等级
            string jcyj = "";   //检测依据

            for (int i = 0; i < testItem.Count; i++)
            {
                aqjsdj = "";
                jcyj = "";
                string sphh = "";
                if (testItem[i].GetJsonValue("ProductName") != "")
                {
                    sphh = testItem[i].GetJsonValue("ProductName");
                }
                if (testItem[i].GetJsonValue("SampleNo") != "")
                {
                    sphh = testItem[i].GetJsonValue("SampleNo") + "," + sphh;
                }

                itemInfos = new List<ItemInfo>();
                itemInfoHgs = new List<ItemInfo>();
                itemInfoBhgs = new List<ItemInfo>();
                jcItem = testItem[i].GetJsonNodes("CheckItemResult");
                for (int j = 0; j < jcItem.Count; j++)  //测试项目
                {
                    if (jcItem[j].GetJsonValue("Grade") != "" && aqjsdj.IndexOf(jcItem[j].GetJsonValue("Grade")) == -1) //安全技术等级
                    {
                        aqjsdj += jcItem[j].GetJsonValue("Grade") + ",";
                    }
                    if (aqjsdj != "") aqjsdj.Substring(0, aqjsdj.Length - 1);
                    if (jcItem[j].GetJsonValue("JudgeBasis") != "" && jcyj.IndexOf(jcItem[j].GetJsonValue("JudgeBasis")) == -1) //检测依据
                    {
                        jcyj += jcItem[j].GetJsonValue("JudgeBasis") + ",";
                    }
                    if (jcyj != "") jcyj.Substring(0, jcyj.Length - 1);

                    mxinfo = new ItemInfo();
                    mxinfo.检测项目 = jcItem[j].GetJsonValue("CheckItemName");
                    mxinfo.测试方法 = jcItem[j].GetJsonValue("CheckMethod");
                    mxinfo.检测结果 = jcItem[j].GetJsonValue("CheckResult").Replace("\r\n", "");
                    mxinfo.单项判定 = jcItem[j].GetJsonValue("SingleJudgement");
                    mxinfo.技术要求 = jcItem[j].GetJsonValue("StandardValue");
                    itemInfos.Add(mxinfo);

                    if (jcItem[j].GetJsonValue("SingleJudgement") == "不符合")
                    {
                        mxinfo = new ItemInfo();
                        mxinfo.检测项目 = jcItem[j].GetJsonValue("CheckItemName");
                        mxinfo.测试方法 = jcItem[j].GetJsonValue("CheckMethod");
                        mxinfo.检测结果 = jcItem[j].GetJsonValue("CheckResult").Replace("\r\n", "");
                        mxinfo.单项判定 = jcItem[j].GetJsonValue("SingleJudgement");
                        mxinfo.技术要求 = jcItem[j].GetJsonValue("StandardValue");
                        itemInfoBhgs.Add(mxinfo);
                    }
                    else
                    {
                        mxinfo.检测项目 = jcItem[j].GetJsonValue("CheckItemName");
                        mxinfo.测试方法 = jcItem[j].GetJsonValue("CheckMethod");
                        mxinfo.检测结果 = jcItem[j].GetJsonValue("CheckResult").Replace("\r\n", "");
                        mxinfo.单项判定 = jcItem[j].GetJsonValue("SingleJudgement");
                        mxinfo.技术要求 = jcItem[j].GetJsonValue("StandardValue");
                        itemInfoHgs.Add(mxinfo);
                    }
                }

                if (testItem[i].GetJsonValue("Judgement") == "不合格") // 不合格
                {
                    paths = testItem[i].GetJsonValue("FailReportDownPath").Split('/');
                    zbinfo = new zbInfo();
                    zbinfo.委托序号 = testItem[i].GetJsonValue("OrderNo");
                    zbinfo.报告编号 = paths[paths.Length - 1].Split('.')[0] + "F";
                    zbinfo.样品名称 = testItem[i].GetJsonValue("SampleName");
                    zbinfo.样品货款号 = sphh;
                    zbinfo.下载地址 = testItem[i].GetJsonValue("FailReportDownPath").Replace("http://", "");
                    zbinfo.检验结论 = "不合格";
                    zbinfo.安全技术等级 = aqjsdj;
                    zbinfo.检测依据 = jcyj;
                    zbinfo.出证日期 = testItem[i].GetJsonValue("ReportPrintTime");
                    zbinfo.送样日期 = testItem[i].GetJsonValue("SampleReceiveTime");
                    zbinfo.itemInfos = itemInfoBhgs;
                    data.Add(zbinfo);

                    paths = testItem[i].GetJsonValue("PassReportDownPath").Split('/');
                    zbinfo = new zbInfo();
                    zbinfo.委托序号 = testItem[i].GetJsonValue("OrderNo");
                    zbinfo.报告编号 = paths[paths.Length - 1].Split('.')[0] + "P";
                    zbinfo.样品名称 = testItem[i].GetJsonValue("SampleName");
                    zbinfo.样品货款号 = sphh;
                    zbinfo.下载地址 = testItem[i].GetJsonValue("PassReportDownPath").Replace("http://", "");
                    zbinfo.检验结论 = "合格";
                    zbinfo.安全技术等级 = aqjsdj;
                    zbinfo.检测依据 = jcyj;
                    zbinfo.出证日期 = testItem[i].GetJsonValue("ReportPrintTime");
                    zbinfo.送样日期 = testItem[i].GetJsonValue("SampleReceiveTime");
                    zbinfo.itemInfos = itemInfoHgs;
                    data.Add(zbinfo);

                    //zbinfo = new zbInfo();
                    //zbinfo.委托序号 = testItem[i].GetJsonValue("OrderNo");
                    //zbinfo.报告编号 = testItem[i].GetJsonValue("ReportNo");
                    //zbinfo.样品名称 = testItem[i].GetJsonValue("SampleName");
                    //zbinfo.样品货款号 = sphh;
                    //zbinfo.下载地址 = testItem[i].GetJsonValue("ReportDownPath").Replace("http://", "");
                    //zbinfo.检验结论 = testItem[i].GetJsonValue("Judgement");
                    //zbinfo.安全技术等级 = aqjsdj;
                    //zbinfo.检测依据 = jcyj;
                    //zbinfo.出证日期 = testItem[i].GetJsonValue("ReportPrintTime");
                    //zbinfo.送样日期 = testItem[i].GetJsonValue("SampleReceiveTime");
                    //zbinfo.itemInfos = itemInfos;
                    //data.Add(zbinfo);
                }
                else // 合格
                {
                    paths = testItem[i].GetJsonValue("ReportDownPath").Split('/');
                    zbinfo = new zbInfo();
                    zbinfo.委托序号 = testItem[i].GetJsonValue("OrderNo");
                    zbinfo.报告编号 = testItem[i].GetJsonValue("ReportNo");
                    zbinfo.样品名称 = testItem[i].GetJsonValue("SampleName");
                    zbinfo.样品货款号 = sphh;
                    zbinfo.下载地址 = testItem[i].GetJsonValue("ReportDownPath").Replace("http://", "");
                    zbinfo.检验结论 = testItem[i].GetJsonValue("Judgement");
                    zbinfo.安全技术等级 = aqjsdj;
                    zbinfo.检测依据 = jcyj;
                    zbinfo.出证日期 = testItem[i].GetJsonValue("ReportPrintTime");
                    zbinfo.送样日期 = testItem[i].GetJsonValue("SampleReceiveTime");
                    zbinfo.itemInfos = itemInfos;
                    data.Add(zbinfo);
                }
            }
            return data;
        }

        /// <summary>
        /// 转半角
        /// </summary>
        /// <param name="input"></param>
        /// <returns></returns>
        public string ToDBC(string input)
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
            return new string(c);
        }

        /// <summary>
        /// 发送POST请求
        /// </summary>
        /// <param name="url"></param>
        /// <param name="postJson"></param>
        /// <returns></returns>
        public string PostFunction(string url, string postJson)
        {
            string Result = "";
            string serviceAddress = url;
            HttpWebRequest request = (HttpWebRequest)WebRequest.Create(serviceAddress);

            request.Method = "POST";
            request.ContentType = "application/json";
            string strContent = postJson;
            using (StreamWriter dataStream = new StreamWriter(request.GetRequestStream()))
            {
                dataStream.Write(strContent);
                dataStream.Close();
            }
            HttpWebResponse response = (HttpWebResponse)request.GetResponse();
            string encoding = response.ContentEncoding;
            if (encoding == null || encoding.Length < 1)
            {
                encoding = "UTF-8"; //默认编码
            }
            // Encoding.GetEncoding(encoding)
            StreamReader reader = new StreamReader(response.GetResponseStream());
            Result = reader.ReadToEnd();
            Console.WriteLine(Result);
            return Result;

        }
    }

    public class PDFUploadCZ
    {
        LiLanzDAL sqlhelp = new LiLanzDAL();
        public string Zyff(string ctrl, string ids, string mlid, string zd, string mxid)
        {
            string rtMsg = "";

            if (ctrl == "" || ctrl == null)
            {
                rtMsg = "缺少CTRL参数！";
                return rtMsg;
            }

            switch (ctrl)
            {
                case "upload":
                    rtMsg = UploadPDF(ids, mlid, zd);
                    break;
                case "delete":
                    rtMsg = DeletePDF(mxid, zd);
                    break;
                default:
                    rtMsg = "无CTRL对应操作！";
                    break;
            }

            return rtMsg;
        }
        //上传操作，将文件复制一份出来并写入数据库
        public string UploadPDF(string ids, string mlid, string zd)
        {
            string[] tmp = ids.Split(',');
            DataTable dt = null;
            string errInfo = "";
            using (LiLanzDALForXLM dal = new LiLanzDALForXLM())
            {
                string sql = "select localpdf from yf_t_syjcbg where id in (" + ids + ");";
                errInfo = dal.ExecuteQuery(sql, out dt);
                if (errInfo == "" && dt.Rows.Count > 0)
                {
                    string path = "", filename = "", newfilename = "", errs = "";
                    string toPath = "../photo/sygzb_pdf/";
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
        public string DeletePDF(string mxid, string zd)
        {
            string errInfo = "";
            string path = "../photo/sygzb_pdf/";
            using (LiLanzDALForXLM dal = new LiLanzDALForXLM())
            {
                DataTable dt = null;
                string sql = "select top 1 text from ghs_t_zldamxb where mxid=@mxid;";
                List<SqlParameter> paras = new List<SqlParameter>();
                paras.Add(new SqlParameter("@mxid", mxid));
                errInfo = dal.ExecuteQuerySecurity(sql, paras, out dt);
                if (errInfo == "" && dt.Rows.Count > 0)
                {
                    string filename = dt.Rows[0]["text"].ToString();
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
    
    /// <summary>
    /// 获取指定同步日期数据的id串
    /// </summary>
    /// <param name="tbrq"></param>
    /// <param name="bs"></param>
    /// <param name="tbr"></param>
    /// <returns></returns>
    public string GetTBSJIDS(string tbrq, string bs, string tbr)
    {
        string sql = @"
            SELECT id
            FROM yf_t_syjcbg
            WHERE bs='{1}' and CONVERT(VARCHAR(50),czrq,112)=CONVERT(VARCHAR(50),CAST('{0}' AS DATETIME),112) and isnull(localpdf,'')='' 
            ORDER BY id DESC
        ";
        sql = string.Format(sql, tbrq, bs);
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
    /// <returns>返回指定出证日期数据记录表</returns>
    public DataTable GetTBJL(string tbrq, string bs)
    {
        string sql = @"
            SELECT b.sygzid mlid,b.djlx,a.id,a.bgbh,a.jcjg
            FROM yf_t_syjcbg a
            INNER JOIN yf_t_wtjyxy b ON a.wtid=b.id
            WHERE bs='{1}' and CONVERT(VARCHAR(50),czrq,112)=CONVERT(VARCHAR(50),CAST('{0}' AS DATETIME),112)
            ORDER BY a.id DESC
        ";
        sql = string.Format(sql, tbrq, bs);
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
    public int UploadCF(DataView dv)
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
            PDFUploadCZ pDFUploadCZ = new PDFUploadCZ();
            //Zyff(string ctrl, string userid, string ids, string mlid, string zd, string mxid, string StartPath)
            if (pDFUploadCZ.Zyff("upload", ids, dr["mlid"].ToString(), zd, "").IndexOf("成功复制") > -1)
            {
                ztsm++;
            }
        }
        //Response.Write("成分:" + ztsm + "<br />");
        return ztsm;
    }

    /// <summary>
    /// 上传贴牌pdf
    /// </summary>
    /// <param name="dv">贴牌信息记录视图</param>
    /// <returns>返回值成功条数</returns>
    public int UploadTP(DataView dv)
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
            PDFUploadCZ pDFUploadCZ = new PDFUploadCZ();
            if (pDFUploadCZ.Zyff("upload", ids, dr["mlid"].ToString(), zd, "").IndexOf("成功复制") > -1)
            {
                ztsm++;
            }
            //上传不合格
            dv.RowFilter = "djlx='3311' and mlid=" + dr["mlid"] + " jcjg <>'合格' ";
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
        //Response.Write("贴牌:" + ztsm + "<br />");
        return ztsm;
    }

    /// <summary>
    /// 上传自制pdf
    /// </summary>
    /// <param name="dv">自制信息记录视图</param>
    /// <returns>返回值成功条数</returns>
    public int UploadZZ(DataView dv)
    {
        int ztsm = 0;
        string zd = "sygzb_sg";
        DataTable mlidb = dv.ToTable(true, new string[] { "mlid" });//去重，并只有mlid列的表
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
            PDFUploadCZ pDFUploadCZ = new PDFUploadCZ();
            if (pDFUploadCZ.Zyff("upload", ids, dr["mlid"].ToString(), zd, "").IndexOf("成功复制") > -1)
            {
                ztsm++;
            }
            //str+="mlid:"+dr["mlid"]+";"+ids+"<br />\n";
            //上传不合格
            dv.RowFilter = "djlx='3312' and mlid=" + dr["mlid"] + " and jcjg <>'合格' ";
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
    public string UploadPDF(string ids, string mlid, string zd)
    {
        string[] tmp = ids.Split(',');
        DataTable dt = null;
        string errInfo = "";
        using (LiLanzDALForXLM dal = new LiLanzDALForXLM())
        {
            string sql = "select localpdf,bgbh FileName from yf_t_syjcbg where id in (" + ids + ");";
            errInfo = dal.ExecuteQuery(sql, out dt);
            if (errInfo == "" && dt.Rows.Count > 0)
            {
                string path = "", filename = "", newfilename = "", errs = "";
                string toPath = "../MyUpload/" + DateTime.Now.ToString("yyyyMM") + "/";
                string filePath = Server.MapPath(toPath);
                //检查是否有该路径  没有就创建
                if (!Directory.Exists(filePath))
                {
                    Directory.CreateDirectory(filePath);
                }
                int sucCount = 0;
                //生成文件名
                for (int i = 0; i < dt.Rows.Count; i++)
                {
                    path = "../" + dt.Rows[i]["localpdf"].ToString();
                    filename = path.Split('/')[path.Split('/').Length - 1];
                    newfilename = GetFileName() + ".pdf";
                    if (File.Exists(Server.MapPath(path)))
                    { //检查源文件是否存在
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
    public string GetFileName()
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
    public void WriteLog(string info)
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
        public string 安全技术等级;
        public string 送样日期;
        public string 检测依据;
        public string 委托序号;
        public string 报告编号;
        public string 样品名称;
        public string 样品货款号;
        public string 下载地址;
        public string 检验结论;
        public string 出证日期;
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

        //天津检测所
    //请求信息
    public class ReportsListInputStc
    {
        public ReportsListInputStc() { }
        private string trustDateFrom;
        private string trustDateTo;
        private string auditDateFrom;
        private string auditDateTo;
        private string productName;
        private string goodsName;
        private string enterpriseNo;
        private string trustCustomerName;
        private string makeCustomerName;
        private string testItem;
        private string failItem;
        private string productStandardNo;
        private string methodStandardNo;

        public string TrustDateFrom
        {
            get
            {
                return trustDateFrom;
            }

            set
            {
                trustDateFrom = value;
            }
        }

        public string TrustDateTo
        {
            get
            {
                return trustDateTo;
            }

            set
            {
                trustDateTo = value;
            }
        }

        public string AuditDateFrom
        {
            get
            {
                return auditDateFrom;
            }

            set
            {
                auditDateFrom = value;
            }
        }

        public string AuditDateTo
        {
            get
            {
                return auditDateTo;
            }

            set
            {
                auditDateTo = value;
            }
        }

        public string ProductName
        {
            get
            {
                return productName;
            }

            set
            {
                productName = value;
            }
        }

        public string GoodsName
        {
            get
            {
                return goodsName;
            }

            set
            {
                goodsName = value;
            }
        }

        public string EnterpriseNo
        {
            get
            {
                return enterpriseNo;
            }

            set
            {
                enterpriseNo = value;
            }
        }

        public string TrustCustomerName
        {
            get
            {
                return trustCustomerName;
            }

            set
            {
                trustCustomerName = value;
            }
        }

        public string MakeCustomerName
        {
            get
            {
                return makeCustomerName;
            }

            set
            {
                makeCustomerName = value;
            }
        }

        public string TestItem
        {
            get
            {
                return testItem;
            }

            set
            {
                testItem = value;
            }
        }

        public string FailItem
        {
            get
            {
                return failItem;
            }

            set
            {
                failItem = value;
            }
        }

        public string ProductStandardNo
        {
            get
            {
                return productStandardNo;
            }

            set
            {
                productStandardNo = value;
            }
        }

        public string MethodStandardNo
        {
            get
            {
                return methodStandardNo;
            }

            set
            {
                methodStandardNo = value;
            }
        }

    }
    public class RequestHeadStc
    {
        public RequestHeadStc() { }
        // 请求方法名称
        private string method;

        // 用户编码 权限判断用
        private string appKey;

        // 用户口令 权限判断用
        private string secretKey;

        // 请求流水码
        private string askSerialNo;

        // 请求时间格式 YYYYMMDDHHMMSS
        private string sendTime;

        public string Method
        {
            get
            {
                return method;
            }

            set
            {
                method = value;
            }
        }

        public string AppKey
        {
            get
            {
                return appKey;
            }

            set
            {
                appKey = value;
            }
        }

        public string SecretKey
        {
            get
            {
                return secretKey;
            }

            set
            {
                secretKey = value;
            }
        }

        public string AskSerialNo
        {
            get
            {
                return askSerialNo;
            }

            set
            {
                askSerialNo = value;
            }
        }

        public string SendTime
        {
            get
            {
                return sendTime;
            }

            set
            {
                sendTime = value;
            }
        }
    }
    public class ReportsListRequestStructBean
    {
        public ReportsListRequestStructBean() { }
        // 请求头对象
        private RequestHeadStc head;

        // 请求体对象
        private ReportsListInputStc body;

        public RequestHeadStc Head
        {
            get
            {
                return head;
            }

            set
            {
                head = value;
            }
        }

        public ReportsListInputStc Body
        {
            get
            {
                return body;
            }

            set
            {
                body = value;
            }
        }
    }
    public class ReportsRequestStructBean
    {
        public ReportsRequestStructBean() { }
        // 请求头对象
        private RequestHeadStc head;

        // 请求体对象
        private ReportsInputStc body;

        public RequestHeadStc Head
        {
            get
            {
                return head;
            }

            set
            {
                head = value;
            }
        }

        public ReportsInputStc Body
        {
            get
            {
                return body;
            }

            set
            {
                body = value;
            }
        }
    }
    public class ReportsInputStc
    {
        public ReportsInputStc() { }
        private string _reportNO;

        public string reportNO
        {
            get
            {
                return _reportNO;
            }

            set
            {
                _reportNO = value;
            }
        }
    }
    //请求信息 end

    //响兴信息
    public class MessageContentStc
    {
        public MessageContentStc() { }

        // 消息代码
        private string msgCode;

        // 消息类型 E M
        private string msgType;

        // 消息内容
        private string msgContent;

        // 消息来源
        private string msgSystem;

        public string MsgCode
        {
            get
            {
                return msgCode;
            }

            set
            {
                msgCode = value;
            }
        }

        public string MsgType
        {
            get
            {
                return msgType;
            }

            set
            {
                msgType = value;
            }
        }

        public string MsgContent
        {
            get
            {
                return msgContent;
            }

            set
            {
                msgContent = value;
            }
        }

        public string MsgSystem
        {
            get
            {
                return msgSystem;
            }

            set
            {
                msgSystem = value;
            }
        }
    }
    public class ReportsListOutStc
    {
        public ReportsListOutStc() { }

        // 返回值
        private string resultContent;

        public string ResultContent
        {
            get
            {
                return resultContent;
            }

            set
            {
                resultContent = value;
            }
        }
    }
    public class ResponseHeadStc
    {
        public ResponseHeadStc() { }
        // 请求原值返回
        private string method;

        // 操作状态 E失败  M成功
        private string responseCode;

        // 返回操作信息 中文
        private string responseInfo;

        // 返回时间
        private string responseTime;

        // 请求流水码 原值返回
        private string askSerialNo;

        // 平台交易处理流水号
        private string answerSerialNo;

        // 应用返回信息列表
        private List<MessageContentStc> msgList;

        public string Method
        {
            get
            {
                return method;
            }

            set
            {
                method = value;
            }
        }

        public string ResponseCode
        {
            get
            {
                return responseCode;
            }

            set
            {
                responseCode = value;
            }
        }

        public string ResponseInfo
        {
            get
            {
                return responseInfo;
            }

            set
            {
                responseInfo = value;
            }
        }

        public string ResponseTime
        {
            get
            {
                return responseTime;
            }

            set
            {
                responseTime = value;
            }
        }

        public string AskSerialNo
        {
            get
            {
                return askSerialNo;
            }

            set
            {
                askSerialNo = value;
            }
        }

        public string AnswerSerialNo
        {
            get
            {
                return answerSerialNo;
            }

            set
            {
                answerSerialNo = value;
            }
        }

        public List<MessageContentStc> MsgList
        {
            get
            {
                return msgList;
            }

            set
            {
                msgList = value;
            }
        }
    }
    public class ReportsListResponseStructBean
    {
        public ReportsListResponseStructBean() { }
        // 返回头
        private ResponseHeadStc head;

        // 返回体
        private ReportsListOutStc body;

        public ResponseHeadStc Head
        {
            get
            {
                return head;
            }

            set
            {
                head = value;
            }
        }

        public ReportsListOutStc Body
        {
            get
            {
                return body;
            }

            set
            {
                body = value;
            }
        }
    }
    public class ResultContent
    {
        public ResultContent() { }
        private string _stfbreportno;
        public string stfbreportno
        {
            get
            {
                return _stfbreportno;
            }

            set
            {
                _stfbreportno = value;
            }
        }


        private string acceptDate;
        private string superviseNoticeCode;
        private string makeCustomername;
        private string productName;
        private string productCount;

        private string samplespec;
        private string securityCategories;
        private string qualityRegistration;


        private string _acceptdate;
        public string acceptdate
        {
            get
            {
                return _acceptdate;
            }

            set
            {
                _acceptdate = value;
            }
        }

        private string _dapprovedate;
        public string dapprovedate
        {
            get
            {
                return _dapprovedate;
            }

            set
            {
                _dapprovedate = value;
            }
        }


        private string _productstandard;
        public string productstandard
        {
            get
            {
                return _productstandard;
            }

            set
            {
                _productstandard = value;
            }
        }

        private string _itemlist;
        public string itemlist
        {
            get
            {
                return _itemlist;
            }

            set
            {
                _itemlist = value;
            }
        }

        private string _trademark;
        public string trademark
        {
            get
            {
                return _trademark;
            }

            set
            {
                _trademark = value;
            }
        }

        private string _fails;
        public string fails
        {
            get
            {
                return _fails;
            }

            set
            {
                _fails = value;
            }
        }

        private string _urlimage;
        public string urlimage
        {
            get
            {
                return _urlimage;
            }

            set
            {
                _urlimage = value;
            }
        }

        private string _urlpdf;
        public string urlpdf
        {
            get
            {
                return _urlpdf;
            }

            set
            {
                _urlpdf = value;
            }
        }

        private string _productsremark;
        public string productsremark
        {
            get
            {
                return _productsremark;
            }

            set
            {
                _productsremark = value;
            }
        }


        private string _productsremarkFull;
        public string productsremarkFull
        {
            get
            {
                return _productsremarkFull;
            }

            set
            {
                _productsremarkFull = value;
            }
        }

        private string _trustcustomername;
        public string trustcustomername
        {
            get
            {
                return _trustcustomername;
            }

            set
            {
                _trustcustomername = value;
            }
        }

        private List<Samples> _samples;
        public List<Samples> samples
        {
            get
            {
                return _samples;
            }

            set
            {
                _samples = value;
            }
        }

        private List<Detail> _detail;
        public List<Detail> detail
        {
            get
            {
                return _detail;
            }

            set
            {
                _detail = value;
            }
        }

        public string AcceptDate
        {
            get
            {
                return acceptDate;
            }

            set
            {
                acceptDate = value;
            }
        }

        public string SuperviseNoticeCode
        {
            get
            {
                return superviseNoticeCode;
            }

            set
            {
                superviseNoticeCode = value;
            }
        }

        public string MakeCustomername
        {
            get
            {
                return makeCustomername;
            }

            set
            {
                makeCustomername = value;
            }
        }

        public string ProductName
        {
            get
            {
                return productName;
            }

            set
            {
                productName = value;
            }
        }

        public string ProductCount
        {
            get
            {
                return productCount;
            }

            set
            {
                productCount = value;
            }
        }

        public string Samplespec
        {
            get
            {
                return samplespec;
            }

            set
            {
                samplespec = value;
            }
        }

        public string SecurityCategories
        {
            get
            {
                return securityCategories;
            }

            set
            {
                securityCategories = value;
            }
        }

        public string QualityRegistration
        {
            get
            {
                return qualityRegistration;
            }

            set
            {
                qualityRegistration = value;
            }
        }
    }
    public class Samples
    {
        public Samples() { }
        private string _samplesn;
        public string samplesn
        {
            get
            {
                return _samplesn;
            }

            set
            {
                _samplesn = value;
            }
        }


        private string _sampleMark;
        public string sampleMark
        {
            get
            {
                return _sampleMark;
            }

            set
            {
                _sampleMark = value;
            }
        }

    }
    public class Detail
    {
        public Detail() { }
        private string _samplesn;
        public string samplesn
        {
            get
            {
                return _samplesn;
            }

            set
            {
                _samplesn = value;
            }
        }


        private string _item;
        public string item
        {
            get
            {
                return _item;
            }

            set
            {
                _item = value;
            }
        }

        private string _prefixA;
        public string prefixA
        {
            get
            {
                return _prefixA;
            }

            set
            {
                _prefixA = value;
            }
        }

        private string _prefix;
        public string prefix
        {
            get
            {
                return _prefix;
            }

            set
            {
                _prefix = value;
            }
        }
        private string _result;
        public string result
        {
            get
            {
                return _result;
            }

            set
            {
                _result = value;
            }
        }


        private string _standvalue;
        public string standvalue
        {
            get
            {
                return _standvalue;
            }

            set
            {
                _standvalue = value;
            }
        }
        private string _acturevalue;
        public string acturevalue
        {
            get
            {
                return _acturevalue;
            }

            set
            {
                _acturevalue = value;
            }
        }


    }
    //响兴信息end
    //天津检测所end
</script>
