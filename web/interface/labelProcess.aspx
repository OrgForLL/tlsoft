<%@ Page Language="C#" %>
<%@ Import Namespace="nrWebClass" %>
<%@ Import Namespace="System.Collections.Generic" %>
<%@ Import Namespace="System.Data" %>
<%@ Import Namespace="System.Data.SqlClient" %>

<!DOCTYPE html>
<script runat="server">
    public static string access_token = "";
    public static string access_token_time = "";
    public static string jsapi_ticket = "";
    public static string jsapi_ticket_time = "";

    //利郎零售管理公众号
    public string AppID = "wx9e66df5eaf2dd2d5";
    public string AppSecret = "4e44e3dfed925e8b2ad99aeebe512bc8";
    private string DbConnStr = "server='192.168.35.10';uid=ABEASD14AD;pwd=+AuDkDew;database=tlsoft";
    private string FXDBConnStr = "server='192.168.35.11';uid=lllogin;pwd=rw1894tla;database=FXDB";
    protected void Page_Load(object sender, EventArgs e)
    { 
            string ctrl = Convert.ToString(Request.Params["ctrl"]);
        
            switch (ctrl)
            {
                case "wxjsconfig":
                    string currentURL = HttpUtility.UrlDecode(Convert.ToString(Request.Params["myURL"]));                    
                    if (currentURL == "" || currentURL == null)
                        clsSharedHelper.WriteErrorInfo("缺少URL参数！");
                    else
                        clsSharedHelper.WriteInfo(getJSConfig(currentURL,AppID,AppSecret));
                    break;
                case "sphhInfo":
                    string tmcode = Convert.ToString(Request.Params["tmcode"]);
                    if (tmcode == "" || tmcode == null)
                        clsSharedHelper.WriteErrorInfo("请传入要查询的货号！");
                    else
                        getSPHHinfo(tmcode);
                    break;
                case "getCount":
                    string mdid = Convert.ToString(Request.Params["mdid"]);                    
                    string sphh = Convert.ToString(Request.Params["sphh"]);
                    if (mdid == "" || mdid == null)
                        clsSharedHelper.WriteErrorInfo("缺少门店参数！");
                    else if (sphh == "" || sphh == null)
                        clsSharedHelper.WriteErrorInfo("请传入要查询的货号！");
                    else
                        getCount(sphh,mdid);
                    break;
                case "getChartDatas":
                    mdid = Convert.ToString(Request.Params["mdid"]);                    
                    sphh = Convert.ToString(Request.Params["sphh"]);
                    if (mdid == "" || mdid == null)
                        clsSharedHelper.WriteErrorInfo("缺少门店参数！");
                    else if (sphh == "" || sphh == null)
                        clsSharedHelper.WriteErrorInfo("请传入要查询的货号！");
                    else
                        getChartDatas(sphh, mdid);
                    break;
                case "tmConvert":
                    tmcode = Convert.ToString(Request.Params["tmcode"]);
                    clsSharedHelper.WriteInfo(tmConvert(tmcode));
                    break;
                default:
                    clsSharedHelper.WriteErrorInfo("无【CTRL=" + ctrl + "】对应操作！");
                    break;
            }
    }

    //获取绘制图表所需的数据
    public void getChartDatas(string sphh,string mdid) {        
        using (LiLanzDALForXLM dal = new LiLanzDALForXLM(FXDBConnStr)) {            
            DataTable dt = null;
            string str_sql = @"select substring(convert(varchar(20),a.rq,112),1,6) ny,b.sphh,
                                sum(case when a.djlb in (-1,-2) then -1*b.sl else b.sl end) xssl into #zb
                                from zmd_t_lsdjb a
                                inner join zmd_t_lsdjmx b on a.id=b.id
                                inner join yx_t_spdmb c on c.sphh=@sphh 
                                inner join yx_t_spdmb sp on b.sphh=sp.sphh and sp.splbid=c.splbid and c.kfbh=sp.kfbh
                                where a.djlb in (1,-1,2,-2) and a.mdid=@mdid
                                group by substring(convert(varchar(20),a.rq,112),1,6),b.sphh;

                                select a.ny,isnull(hh.sl,0) hhxssl,isnull(pl.sl,0) plxssl
                                from (select distinct ny from #zb) a
                                left join (select ny,sum(xssl) sl from #zb where sphh=@sphh group by ny) hh on hh.ny=a.ny
                                left join (select ny,sum(xssl) sl from #zb group by ny) pl on pl.ny=a.ny;
                                drop table #zb;";
            
            List<SqlParameter> paras = new List<SqlParameter>();
            paras.Add(new SqlParameter("@sphh", sphh));
            paras.Add(new SqlParameter("@mdid", mdid));
            string errinfo = dal.ExecuteQuerySecurity(str_sql, paras, out dt);
            if (errinfo == "") {
                if (dt.Rows.Count > 0) {
                    clsSharedHelper.WriteInfo(JsonHelp.dataset2json(dt));
                }else
                    clsSharedHelper.WriteErrorInfo("计算图表数据时查询不到数据！");
            }else
                clsSharedHelper.WriteErrorInfo("统计数据时出错 info:" + errinfo); 
        }
    }
    
    //统计汇总
    public void getCount(string sphh,string mdid) {
        using (LiLanzDALForXLM dal = new LiLanzDALForXLM(FXDBConnStr)) {
            DataTable LSDataTable = null;//零售数据表
            DataTable KCDataTable = null;//库存表
            string rt = "";
            string str_sql = @"select substring(convert(varchar(20),a.rq,112),1,6) ny,b.sphh,sum(case when a.djlb in (-1,-2) then -1*b.sl else b.sl end) xssl
                                from zmd_t_lsdjb a
                                inner join zmd_t_lsdjmx b on a.id=b.id
                                inner join yx_t_spdmb c on c.sphh=@sphh 
                                inner join yx_t_spdmb sp on b.sphh=sp.sphh and sp.splbid=c.splbid and c.kfbh=sp.kfbh
                                where a.djlb in (1,-1,2,-2) and a.mdid=@mdid
                                group by substring(convert(varchar(20),a.rq,112),1,6),b.sphh";                                
            List<SqlParameter> paras = new List<SqlParameter>();
            paras.Add(new SqlParameter("@sphh", sphh));
            paras.Add(new SqlParameter("@mdid", mdid));
            string errinfo1 = dal.ExecuteQuerySecurity(str_sql, paras, out LSDataTable);
            str_sql = @"select a.ny,a.sphh,sum(a.cgrksl) cgrksl,sum(a.cgthsl) cgthsl,sum(a.dbsl) dbsl 
                        from ds_T_Spkhckcrkqkb a
                        inner join t_mdb md on md.khid=a.tzid
                        inner join yx_t_spdmb sp on sp.sphh=@sphh
                        inner join yx_t_spdmb c on a.sphh=c.sphh and c.splbid=sp.splbid and c.kfbh=sp.kfbh
                        where md.mdid=@mdid
                        group by a.ny,a.sphh";
            paras.Clear();
            paras.Add(new SqlParameter("@sphh", sphh));
            paras.Add(new SqlParameter("@mdid", mdid));
            string errinfo2 = dal.ExecuteQuerySecurity(str_sql, paras, out KCDataTable);
            if (errinfo1 == "" && errinfo2 == "")
            {
                if (LSDataTable.Rows.Count > 0 && KCDataTable.Rows.Count > 0)
                {
                    string ny = DateTime.Now.ToString("yyyyMM");
                    int hhxssl = 0, hhdysl = 0, hhcgsl = 0, hhdbsl = 0;//货号的三个数量
                    int plxssl = 0, pldysl = 0, plcgsl = 0, pldbsl = 0;//同品类的三个数量
                    //统计本货号的数据
                    Object _sl = LSDataTable.Compute("sum(xssl)", "ny='" + ny + "' and sphh='" + sphh + "'");
                    hhdysl = _sl == DBNull.Value ? 0 : Convert.ToInt32(_sl);
                    _sl = LSDataTable.Compute("sum(xssl)", "sphh='" + sphh + "'");
                    hhxssl = _sl == DBNull.Value ? 0 : Convert.ToInt32(_sl);
                    _sl = KCDataTable.Compute("sum(cgrksl)", "sphh='" + sphh + "'");
                    hhcgsl = _sl == DBNull.Value ? 0 : Convert.ToInt32(_sl);
                    _sl = KCDataTable.Compute("sum(dbsl)", "sphh='" + sphh + "'");
                    hhdbsl = _sl == DBNull.Value ? 0 : Convert.ToInt32(_sl);
                    rt = hhdysl.ToString() + "|" + hhxssl.ToString() + "|" + hhcgsl.ToString() + "|" + hhdbsl.ToString();
                    
                    //统计同品类的数据
                    _sl = LSDataTable.Compute("sum(xssl)", "ny='" + ny + "'");
                    pldysl = _sl == DBNull.Value ? 0 : Convert.ToInt32(_sl);
                    _sl = LSDataTable.Compute("sum(xssl)", "");
                    plxssl = _sl == DBNull.Value ? 0 : Convert.ToInt32(_sl);
                    _sl = KCDataTable.Compute("sum(cgrksl)", "");
                    plcgsl = _sl == DBNull.Value ? 0 : Convert.ToInt32(_sl);
                    _sl = KCDataTable.Compute("sum(dbsl)", "");
                    pldbsl = _sl == DBNull.Value ? 0 : Convert.ToInt32(_sl);
                    rt += ":" + pldysl.ToString() + "|" + plxssl.ToString() + "|" + plcgsl.ToString() + "|" + pldbsl.ToString();
                    
                    clsSharedHelper.WriteInfo(rt);
                }
                else
                    clsSharedHelper.WriteErrorInfo("统计时查询不到数据！");
            }
            else
                clsSharedHelper.WriteErrorInfo("统计数据时出错 info:" + errinfo1 + "|" + errinfo2);
        }               
    }
    
    public void getSPHHinfo(string tmcode) {
        tmcode = tmConvert(tmcode);
        if (tmcode.IndexOf("Error:") > -1) {
            clsSharedHelper.WriteErrorInfo("扫描的二维码不合法！");
            return;
        }            
        using (LiLanzDALForXLM dal = new LiLanzDALForXLM(DbConnStr)) {
            string str_sql = @"select top 1 a.sphh,cm.cm,sp.lsdj,sp.spmc 
                                from yx_t_tmb a
                                inner join yx_t_spdmb sp on a.sphh=sp.sphh
                                left join yx_t_cmzh cm on cm.tml=sp.tml and cm.cmdm=a.cmdm
                                where tm=@sphh;";
            List<SqlParameter> paras = new List<SqlParameter>();
            paras.Add(new SqlParameter("@sphh",tmcode));            
            DataTable dt = null;
            
            string errinfo = dal.ExecuteQuerySecurity(str_sql,paras,out dt) ;            
            if (errinfo == "")
            {
                if (dt.Rows.Count > 0) {
                    string rt = dt.Rows[0][0].ToString() + "|" + dt.Rows[0][1].ToString() + "|" + dt.Rows[0][2].ToString() + "|" + dt.Rows[0][3].ToString();
                    clsSharedHelper.WriteInfo(rt);
                }
                else
                    clsSharedHelper.WriteErrorInfo("查询不到该条码【" + tmcode + "】的信息！");                
            }
            else
                clsSharedHelper.WriteErrorInfo("查询货号信息时出错 info:" + errinfo);
        }
    }    
    
    //获取JSConfig配置参数
    public string getJSConfig(string URL, string appID, string appSecret)
    {
        string rtMsg = "", postURL = "", content = "";
        DateTime currentTime = DateTime.Now;
        clsJsonHelper jh = null;
        if (access_token == "" || access_token_time == "" || DateTime.Compare(currentTime.AddSeconds(-7000), Convert.ToDateTime(access_token_time)) > 0)
        {
            postURL = string.Format("https://api.weixin.qq.com/cgi-bin/token?grant_type=client_credential&appid={0}&secret={1}", appID, appSecret);
            content = clsNetExecute.HttpRequest(postURL);
            jh = clsJsonHelper.CreateJsonHelper(content);
            access_token = jh.GetJsonValue("access_token");
            access_token_time = currentTime.ToShortTimeString();
        }

        currentTime = DateTime.Now;
        if (jsapi_ticket == "" || jsapi_ticket_time == "" || DateTime.Compare(currentTime.AddSeconds(-7000), Convert.ToDateTime(jsapi_ticket_time)) > 0)
        {
            postURL = string.Format("https://api.weixin.qq.com/cgi-bin/ticket/getticket?access_token={0}&type=jsapi", access_token);
            content = clsNetExecute.HttpRequest(postURL);
            jh = clsJsonHelper.CreateJsonHelper(content);
            jsapi_ticket = jh.GetJsonValue("ticket");
            jsapi_ticket_time = currentTime.ToShortTimeString();
        }

        string[] str = callJsApiConfig(URL);
        for (int i = 0; i < str.Length; i++)
        {
            rtMsg += str[i] + "|";
        }

        return rtMsg;
    }

    public string[] callJsApiConfig(string myURL)
    {
        string[] rt = new string[4];

        //先拼接成string1
        string string1 = "jsapi_ticket={0}&noncestr={1}&timestamp={2}&url={3}";
        string noncestr = Guid.NewGuid().ToString().Replace("-", "");
        noncestr = noncestr.Substring(noncestr.Length - 16);
        string timestamp = ConvertDateTimeInt(DateTime.Now).ToString();
        if (myURL.Contains("#")) myURL = myURL.Substring(0, myURL.IndexOf('#'));

        string1 = string.Format(string1, jsapi_ticket, noncestr, timestamp, myURL);
        //使用SHA1方法，换算成 signature
        string signature = FormsAuthentication.HashPasswordForStoringInConfigFile(string1, "SHA1");
        signature = signature.ToLower();
        rt[0] = AppID;
        rt[1] = timestamp;//生成签名的时间戳
        rt[2] = noncestr;//生成签名的随机串
        rt[3] = signature;//签名

        return rt;
    }

    private string tmConvert(string tm) {
        string rt = "Error:";
        using (LiLanzDALForXLM dal = new LiLanzDALForXLM(DbConnStr)) {            
            string sql = "select dbo.f_DBpwd(@tm)";
            DataTable dt = null;
            List<SqlParameter> paras = new List<SqlParameter>();
            paras.Add(new SqlParameter("@tm", tm));

            string errinfo = dal.ExecuteQuerySecurity(sql,paras,out dt);
            if (errinfo == "" && dt.Rows.Count > 0) { 
                string str=dt.Rows[0][0].ToString();
                rt = str.Substring(0,str.Length-6);
            }            
        }

        return rt;
    }
    
    private int ConvertDateTimeInt(System.DateTime time)
    {
        System.DateTime startTime = TimeZone.CurrentTimeZone.ToLocalTime(new System.DateTime(1970, 1, 1));
        return (int)(time - startTime).TotalSeconds;
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
