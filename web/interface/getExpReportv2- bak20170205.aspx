<%@ Page Language="C#" debug="true" %>

<%@ Import Namespace="nrWebClass" %>
<%@ Import Namespace="System.Collections.Generic" %>
<%@ Import Namespace="Newtonsoft.Json.Linq" %>
<%@ Import Namespace="Newtonsoft.Json" %>
<%@ Import Namespace="System.IO" %>
<%@ Import Namespace="System.Data" %>
<%@ Import Namespace="System.Data.SqlClient" %>
<!DOCTYPE html>
<script runat="server"> 
    string username = "";

    protected void Page_Load(object sender, EventArgs e)
    {
        //验证调用的合法性       
        String ctrl = Convert.ToString(Request.Params["ctrl"]);
        String userid = Convert.ToString(Session["userid"]);
        string[] AllKeys = Request.Params.AllKeys;
        for(int i=0;i<AllKeys.Length;i++)
        {
            if (AllKeys[i] == "userid")
            {
                userid = "0";
                username = "自动同步";
            }
        }

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
                case "syncData":
                    String bdate = Convert.ToString(Request.Params["bdate"]);
                    String edate = Convert.ToString(Request.Params["edate"]);
                    if (bdate == "" || bdate == null || edate == "" || edate == null)
                        rtMsg = @"{""type"":""ERROR"",""msg"":""日期参数有误！""}";
                    else
                        rtMsg = pullDatas(bdate,edate);
                    break;
                case "downPDF":
                    String ids = Convert.ToString(Request.Params["ids"]);
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

        Response.Write(rtMsg);
        Response.End();
    }
    //调用实验室接口将报告信息存到本地数据库中
    public string pullDatas(String bdate, String edate)
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
            JSONdate = JSONdate.Replace("<br/>", "");//.Replace("\r", "\\r").Replace("\n", "\\n");               

            //JObject jb = (JObject)JsonConvert.DeserializeObject(JSONdate);
            //JArray jr = (JArray)jb["data"];
            //            clsJsonHelper jh = clsJsonHelper.CreateJsonHelper(JSONdate);
            //            List<clsJsonHelper> jhList = jh.GetJsonNodes("data");
            //            if (jhList.Count != 0) {
            //                String zdr = Convert.ToString(Session["username"]);
            //                StringBuilder strSQL = new StringBuilder();
            //                strSQL.Append("declare @id int;declare @jls int;set @jls=0;");
            //                String zSQL = @"if not exists(select top 1 1 from yf_t_syjcbg where bgbh='{0}')    
            //                                    begin                                  
            //                                    insert into yf_t_syjcbg(bgbh,ypmc,yphh,syrq,czrq,jcyj,aqdj,jcjg,pdf,localpdf,tbr,tbsj)
            //                                    values ('{1}','{2}','{3}','{4}','{5}','{6}','{7}','{8}','{9}','','{10}','{11}');
            //                                    set @id=(select SCOPE_IDENTITY());set @jls=@jls+1; ";
            //                String mSQL = @"insert into yf_t_syjcbgmxb(id,jcxmmc,csff,jsyq,jcjg,dxpd) values (@id,'{0}','{1}','{2}','{3}','{4}');";
            //                for (int i = 0; i < jhList.Count; i++) {
            //                    String yphh = jhList[i].GetJsonValue("样品货款号");
            //                    if (yphh.IndexOf("(NO:") > -1)
            //                        yphh = yphh.Substring(0, yphh.IndexOf("(NO:"));                  
            //                    strSQL.Append(String.Format(zSQL, jhList[i].GetJsonValue("报告编号"), jhList[i].GetJsonValue("报告编号"),
            //                        jhList[i].GetJsonValue("样品名称"), yphh, jhList[i].GetJsonValue("送样日期"),
            //                        jhList[i].GetJsonValue("出证日期"), jhList[i].GetJsonValue("检测依据"), jhList[i].GetJsonValue("安全技术等级"),
            //                        jhList[i].GetJsonValue("检验结论"), jhList[i].GetJsonValue("下载地址"), zdr, DateTime.Now.ToString()));
            //                    List<clsJsonHelper> mjhList = jhList[i].GetJsonNodes("row");
            //                    if (mjhList.Count > 0) {
            //                        for (int j = 0; j < mjhList.Count; j++) {
            //                            strSQL.Append(String.Format(mSQL, mjhList[j].GetJsonValue("检测项目"), mjhList[j].GetJsonValue("测试方法"),
            //                                mjhList[j].GetJsonValue("技术要求"), mjhList[j].GetJsonValue("检测结果"), mjhList[j].GetJsonValue("单项判定")));
            //                        }
            //                        strSQL.Append("end;");                        
            //                    }
            //                }
            //                strSQL.Append("select @jls;");                
            //                using (LiLanzDALForXLM dal = new LiLanzDALForXLM()) {
            //                    DataTable dt = null;
            //                    rtMsg = dal.ExecuteQuery(strSQL.ToString(),out dt);
            //                    if(rtMsg==""&& dt.Rows.Count>0)
            //                        jls=dt.Rows[0][0].ToString();
            //                }
            //                if (rtMsg == "") {
            //                    rtMsg = @"{{""type"":""SUCCESS"",""msg"":""成功同步【{0}】条数据！""}}";
            //                    rtMsg = String.Format(rtMsg, jls);
            //                }                                                                       
            //            }
            //            jh.Dispose();


            Root root = JsonConvert.DeserializeObject<Root>(JSONdate);

            if (root.data.Count != 0)
            {
                String zdr = Convert.ToString(Session["username"]);
                if (username != "")
                {
                    zdr = username;
                }
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

    private String pdftest() {
        String URL = "http://www.ffib.cn/bgpdf/20150526/5129852114341M150040281.pdf";
        String rt = "";
        System.Net.HttpWebRequest Myrq = (System.Net.HttpWebRequest)System.Net.HttpWebRequest.Create(URL);
        System.Net.HttpWebResponse myrp = (System.Net.HttpWebResponse)Myrq.GetResponse();
        System.IO.Stream st = myrp.GetResponseStream();

        byte[] by = new byte[1024];
        int osize = st.Read(by, 0, (int)by.Length);
        rt = System.Text.Encoding.Default.GetString(by);

        return rt;
    }

    //下载接口
    public String downloadPDF(string id,string URL, String path, string filename) {
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


    public String downloadPDF(string path ,string ids)
    {
        String rtMsg = "",URL="",filename="",ID="";
        int succCount = 0, failCount = 0;
        using (LiLanzDALForXLM dal = new LiLanzDALForXLM()) {
            DataTable dt = null;
            String strsql = "select id,bgbh,pdf from yf_t_syjcbg where id in (" + ids + ")";

            String rt = dal.ExecuteQuery(strsql, out dt);
            if (rt == "" && dt.Rows.Count > 0) {
                if (dt.Rows.Count > 0) {
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
                }else
                    rtMsg = @"{""type"":""WARN"",""msg"":""数据库中找不到对应数据！""}";
            }
            else
                rtMsg = rt;
        }

        return rtMsg;
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
