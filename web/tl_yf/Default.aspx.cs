using System;
using System.Collections.Generic;
using System.Web.Services;
using System.Data;
using Newtonsoft.Json;
using nrWebClass;
using LiLanzModel;

using System.Security.Cryptography;
using System.Text;
using System.Net;
using System.IO;


public partial class tl_yf_Default : System.Web.UI.Page
{

    public void Page_Loadd2()
    {
        string startDate = "2020-06-28"; string endDate = startDate; string username = "";
        string url = @"http://www.gttc.net.cn/WSInterface/Handler/GetReportData_LiLang.ashx?AccessToken=D3865E240DB0445A9245F51D85119FBA&BeginQueryDate={0}&EndQueryDate={1}";
        string rtMsg = "", jls = "0";
        url = string.Format(url, startDate, endDate);
        string JsonStr = clsNetExecute.HttpRequest(url);
        if (JsonStr != "[]") //没有数据
        {
            //List<zbInfo> data = GetAllInfo(JsonStr);

            //if (data.Count != 0)
            //{
            //    StringBuilder strSQL = new StringBuilder();
            //    strSQL.Append("declare @id int;declare @jls int;set @jls=0;");
            //    string zSQL = @"if not exists(select top 1 1 from yf_t_syjcbg where bgbh='{0}' and bs='1')
            //                            begin
            //                                insert into yf_t_syjcbg(bgbh,ypmc,yphh,syrq,czrq,jcyj,aqdj,jcjg,pdf,localpdf,tbr,tbsj,wtid,bs,isForce)
            //                                values ('{1}','{2}','{3}','{4}','{5}','{6}','{7}','{8}','{9}','','{10}','{11}','{12}','1',{13});
            //                                set @id=(select SCOPE_IDENTITY());set @jls=@jls+1; ";
            //    string mSQL = @"insert into yf_t_syjcbgmxb(id,jcxmmc,csff,jsyq,jcjg,dxpd) values (@id,'{0}','{1}','{2}','{3}','{4}');";
            //    for (int i = 0; i < data.Count; i++)
            //    {
            //        string yphh = data[i].样品货款号;
            //        strSQL.Append(string.Format(zSQL, data[i].报告编号, data[i].报告编号,
            //            data[i].样品名称, yphh, data[i].送样日期,
            //            data[i].出证日期, data[i].检测依据, data[i].安全技术等级,
            //            data[i].检验结论, data[i].下载地址, username, DateTime.Now.ToString(), data[i].委托序号, data[i].是否强标));
            //        if (data[i].itemInfos == null)
            //        {
            //            strSQL.Append("end;");
            //            continue;
            //        }
            //        List<ItemInfo> row = data[i].itemInfos;
            //        if (row.Count > 0)
            //        {
            //            for (int j = 0; j < row.Count; j++)
            //            {
            //                strSQL.Append(string.Format(mSQL, row[j].检测项目, row[j].测试方法,
            //                    row[j].技术要求, row[j].检测结果, row[j].单项判定));
            //            }
            //            strSQL.Append("end;");
            //        }
            //    }
            //    strSQL.Append("select @jls;");
            //    using (LiLanzDALForXLM dal = new LiLanzDALForXLM())
            //    {
            //        DataTable dt = null;
            //        rtMsg = dal.ExecuteQuery(strSQL.ToString(), out dt);
            //        if (rtMsg == "" && dt.Rows.Count > 0)
            //            jls = dt.Rows[0][0].ToString();
            //    }
            //    if (rtMsg == "")
            //    {
            //        rtMsg = @"{{""type"":""SUCCESS"",""msg"":""成功同步【{0}】条数据！""}}";
            //        rtMsg = string.Format(rtMsg, jls);
            //    }
            //}
        }
        
    
    }


    public void Page_Load1222()
    {
        string bdate = "2020-06-28"; string edate = bdate; string username = "test";
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
            retmp = PostFunctionV3(url, postJson);
        }
        catch (SystemException ex)
        {
            rtMsg = @"{""type"":""ERROR"",""msg"":""无法链接天津外部服务器！""}";
          //  return rtMsg;
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
                    ReqBean = JsonConvert.DeserializeObject<ReportsListResponseStructBean>(PostFunctionV3(urlDetail, postJs));
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
            //using (LiLanzDALForXLM dal = new LiLanzDALForXLM())
            //{
            //    DataTable dt = null;
            //    rtMsg = dal.ExecuteQuery(strSQL.ToString(), out dt);
            //    if (rtMsg == "" && dt.Rows.Count > 0)
            //        jls = dt.Rows[0][0].ToString();
            //}
            //if (rtMsg == "")
            //{
            //    rtMsg = @"{{""type"":""SUCCESS"",""msg"":""成功同步【{0}】条数据！""}}";
            //    rtMsg = string.Format(rtMsg, jls);
            //}
        }
        else
        {
            rtMsg = @"{""type"":""WARN"",""msg"":""Sorry,没有找到数据！""}";
        }

       // return rtMsg;
    }
    protected void Page_Load3322(object sender, EventArgs e)
    {
        BillData billData = new BillData();
        billData.clientuuid = "客户端uuid1";     

      

        Par p = new Par();
        p.partnerid = "16143";
        p.servicetype = "bodyInspReportSearchFabricForClient";//查询
        //p.bizdata = "{\"clientuuid\":\"客户端uuid1\"}";
        p.bizdata = "{\"djh\":\"102904\",\"rq\":\"2020-07-23\"}";
        //p.bizdata = "{\"djh\":\"102904\",\"rq\":\"2020-07-23\",\"ph\":\"\"}";
        p.timestamp = "1569053559";
        p.nonce = "15690535598";

        p.sign = GetSign2("661CFD62-CE04-49A1-A7E8-015B6E04BB69", p.partnerid, p.servicetype, p.bizdata, p.timestamp, p.nonce);
        //正式
        string url = @"http://127.0.0.1:9309/ApiRoute?action=llwebapi";
        url = @"http://api.lilanz.com:9307/ApiRoute?action=llwebapi";
        string postJson = string.Format("partnerid={0}&servicetype={1}&data={2}&timestamp={3}&nonce={4}&sign={5}", p.partnerid, p.servicetype, p.bizdata, p.timestamp, p.nonce, p.sign);
        string r = PostFunctionjson(url, postJson);
    }
 
    protected void Page_Load2231(object sender, EventArgs e)
    {
        BillData billData = new BillData();  

        Par p = new Par();
        p.partnerid = "16214";
        p.servicetype = "bodyInspReportSearchFabricListForClient";
        //p.bizdata = "{\"djh\":\"100295\",\"rq\":\"2020-03-18\"}";
        p.bizdata = "{\"userid\":\"27648\",\"startDate\":\"2020-07-31\",\"endDate\":\"2020-07-31\"}";
        p.timestamp = "1569053559";
        p.nonce = "15690535598";
        p.sign = GetSign2("B8AF8A07-4CB1-48C9-99C3-60F2D4B1C45C", p.partnerid, p.servicetype, p.bizdata, p.timestamp, p.nonce);
        //正式
        string url = @"http://127.0.0.1:9309/ApiRoute?action=llwebapi";
         url = @"http://api.lilanz.com:9307/ApiRoute?action=llwebapi";
        string postJson = string.Format("partnerid={0}&servicetype={1}&data={2}&timestamp={3}&nonce={4}&sign={5}", p.partnerid, p.servicetype, p.bizdata, p.timestamp, p.nonce, p.sign);
        string r = PostFunctionjson(url, postJson);
    }

    protected void Page_Load(object sender, EventArgs e)
    {
        BillData billData = new BillData();
        billData.clientuuid = "客户端uuid1";
        billData.djh = "100078";
        billData.rq = "2019-03-07";
        billData.lydjid = 12;
        billData.lydjlx = 13;
        billData.userid = 14;
        billData.type = "gc";
        billData.dhyjdyzx = false;
        billData.dhyjdyzxbz = "整批大货包装方法与接单要求一致性备注";
        billData.sghfgyqryzx = true;
        billData.sghfgyqryzxbz = "整批面料手感/风格与确认样一致性备注";
        billData.pypzjsgyzx = false;
        billData.pypzjsgyzxbz = "整批面料匹与匹之间色光一致性备注";
        billData.mlyqryzx = true;
        billData.mlyqryzxbz = "整批面料材料名称与确认样一致性备注";
        billData.hpl = 3;
        billData.bz = "";

        WtMemoVO v1 = new WtMemoVO();
        v1.tm = "afasdfasf";
        v1.ph = "2";
        v1.gh = "1";
        v1.ys = "黑色";
        v1.mdsl = 60;
        v1.mfk = "140";
        v1.fk = 140;
        v1.kz = "305";
        v1.jh = "a";
        v1.sphh = "";
        v1.mc = 25;
        v1.qtj = "-0.5";//"汽烫缩率经";
        v1.qtw = "-0.5";//"汽烫缩率纬";
        v1.sxj = "-0.5";//"水洗缩率经";
        v1.sxw = "-0.5";//"水洗缩率纬";
        v1.wx = 3;
        v1.sjsl = 60;
        v1.twsc = 4;
        v1.bzsc = 4;
        v1.mdbz = "（asfasdf(af)";
        v1.xhdx = "循环大小";
        v1.wh = 2;
       // v1.mdbz = "码单备注";
        v1.sjb = "松紧边，荷叶边 ";
        v1.juanb = "卷边 ";
        v1.dxm = "倒顺毛";
        v1.hpl = 3;//换片率
        FabricFault f = new FabricFault();
        f.cdmc = "破洞";
        f.cdwz = 2;
        f.cdfs = 2;
        f.url = "asfasdfaf";
        FabricFault f2 = new FabricFault();
        f2.cdmc = "粗纱";
        f2.cdwz = 1;
        f2.cdfs = 2;
        f2.url = "http";
        v1.fabricFaultList.Add(f);
        v1.fabricFaultList.Add(f2);
        billData.wtMemoVOList.Add(v1);
        List<BillData> bDlist = new List<BillData>();
        bDlist.Add(billData);

        Par p = new Par();
        p.partnerid = "18209";
        p.servicetype = "bodyInspReport";
        p.bizdata = JsonConvert.SerializeObject(bDlist);
        p.timestamp = "20200926103912";
        p.nonce = "3410f33283";
        p.bizdata = "[{\"clientuuid\":\"04cb1a41-66bc-41be-8632-bfd9ee3da439\",\"djh\":\"单据号001\",\"rq\":\"2020-09-21\",\"dhyjdyzx\":0,\"sghfgyqryzx\":0,\"pypzjsgyzx\":0,\"bgshnr\":0,\"hpl\":\"0.12\",\"bz\":null,\"wtMemoVOList\":[{\"ph\":null,\"gh\":\"缸号002\",\"ys\":null,\"mdsl\":\"1.0\",\"mfk\":\"150.0\",\"mc\":\"1.0\",\"sjsl\":\"1.0\",\"fk\":\"幅宽001\",\"kz\":null,\"jh\":null,\"sphh\":null,\"qtj\":null,\"qtw\":null,\"sxj\":null,\"sxw\":null,\"wx\":\"0.0\",\"twsc\":\"4.0\",\"bzsc\":\"4.0\",\"xhdx\":\"无\",\"wh\":\"0.0\",\"sjb\":\"无\",\"juanb\":\"无\",\"dxm\":\"无\",\"hpl\":\"0.0\",\"fabricFaultList\":[{\"cdmc\":\"油渍\",\"cdwz\":3,\"cdfs\":null},{\"cdmc\":\"污渍\",\"cdwz\":3,\"cdfs\":null},{\"cdmc\":\"分匹\",\"cdwz\":3,\"cdfs\":null}]},{\"ph\":null,\"gh\":\"缸号002\",\"ys\":null,\"mdsl\":\"1.0\",\"mfk\":\"150.0\",\"mc\":\"1.0\",\"sjsl\":\"1.0\",\"fk\":\"幅宽001\",\"kz\":null,\"jh\":null,\"sphh\":null,\"qtj\":null,\"qtw\":null,\"sxj\":null,\"sxw\":null,\"wx\":\"0.0\",\"twsc\":\"4.0\",\"bzsc\":\"4.0\",\"xhdx\":\"无\",\"wh\":\"0.0\",\"sjb\":\"无\",\"juanb\":\"无\",\"dxm\":\"无\",\"hpl\":\"200.0\",\"fabricFaultList\":[{\"cdmc\":\"油渍\",\"cdwz\":3,\"cdfs\":2},{\"cdmc\":\"分匹\",\"cdwz\":3,\"cdfs\":null},{\"cdmc\":\"接匹\",\"cdwz\":3,\"cdfs\":null},{\"cdmc\":\"横档\",\"cdwz\":3,\"cdfs\":null},{\"cdmc\":\"污渍\",\"cdwz\":3,\"cdfs\":null},{\"cdmc\":\"水渍\",\"cdwz\":3,\"cdfs\":null},{\"cdmc\":\"油渍\",\"cdwz\":3,\"cdfs\":null},{\"cdmc\":\"水渍\",\"cdwz\":3,\"cdfs\":null},{\"cdmc\":\"接匹\",\"cdwz\":3,\"cdfs\":null},{\"cdmc\":\"分匹\",\"cdwz\":3,\"cdfs\":null},{\"cdmc\":\"分匹\",\"cdwz\":3,\"cdfs\":null}]}]}]";
        
        p.sign = GetSign2("E0E64B8A-D4F1-469F-9B46-66256B42F4CC", p.partnerid, p.servicetype, p.bizdata, p.timestamp, p.nonce);
        //正式
        string url = @"http://127.0.0.1:9309/ApiRoute?action=llwebapi";
        url = @"http://api.lilanz.com:9307/ApiRoute?action=llwebapi";
        string postJson = string.Format("partnerid={0}&servicetype={1}&data={2}&timestamp={3}&nonce={4}&sign={5}", p.partnerid, p.servicetype, p.bizdata, p.timestamp, p.nonce, p.sign);
        string r = PostFunctionjson(url, postJson);
    }
    /*SELECT TOP 11  * FROM dbo.Yf_T_bjdlb WHERE lxid=517  AND id=1902399
SELECT jyid,* FROM dbo.cl_v_jhdjmxb WHERE id=168183
SELECT * FROM wl_t_dddjpmmx WHERE id=168183
 SELECT * FROM yf_t_bjdl_jhmxb WHERE id=1902400
 DELETE FROM wl_t_dddjpmmx WHERE id=168183*/
    public static string GetSign2(string partnerKey, string partnerid, string servicetype, string bizdata, string timestamp, string nonce)
    {

        List<String> lstParams = new List<string>();
        lstParams.Add("partnerid=" + partnerid);
        lstParams.Add("servicetype=" + servicetype);
        lstParams.Add("data=" + bizdata);
        lstParams.Add("timestamp=" + timestamp);
        lstParams.Add("nonce=" + nonce);
        string[] strParams = lstParams.ToArray();
        Array.Sort(strParams);     //参数名ASCII码从小到大排序（字典序）； 
        string origin = string.Join("&", strParams);
        origin = string.Concat(origin, partnerKey);
        MD5 md5 = new MD5CryptoServiceProvider();
        byte[] targetData = md5.ComputeHash(System.Text.Encoding.UTF8.GetBytes(origin));
        StringBuilder sign = new StringBuilder("");
        foreach (byte b in targetData)
        {
            sign.AppendFormat("{0:x2}", b);
        }
        return sign.ToString();
    }
    protected void Page_Load31(object sender, EventArgs e)
    {
        Par p = new Par();
        p.partnerid = "18134";
        p.servicetype = "LLWebApi_CL_GetScDdData";
        //传参待定
        p.bizdata = "{\"BeginDate\":\"2019-09-01\",\"EndDate\":\"2019-09-20\"}";
        p.timestamp = string.Format("{0:yyyyMMddHHmmss}", DateTime.Now);
        p.nonce = System.Guid.NewGuid().ToString();

        p.sign = GetSign("06156B03-194B-4266-A459-0A1AF03330DA", p.partnerid, p.servicetype, p.bizdata, p.timestamp, p.nonce);
        //正式
        string url = @"http://webt.lilang.com/LLService/ApiRoute.ashx?action=llwebapi";
       // string url = @"http://api.lilanz.com:9307/ApiRoute?action=llwebapi";
        //测试
        //string url = @"http://192.168.35.231/LLWebApi/ApiRoute.ASHX?action=llwebapi";
        string postJson = string.Format("partnerid={0}&servicetype={1}&bizdata={2}&timestamp={3}&nonce={4}&sign={5}", p.partnerid, p.servicetype, p.bizdata, p.timestamp, p.nonce, p.sign);

        string r = PostFunction(url, postJson);
    }

    public static string GetSign(string partnerKey,string partnerid,string servicetype,string bizdata,string timestamp,string nonce)
    {
        
        List<String> lstParams = new List<string>();
        lstParams.Add("partnerid="+ partnerid);
        lstParams.Add("servicetype="+ servicetype);
        lstParams.Add("bizdata=" + bizdata);
        lstParams.Add("timestamp=" + timestamp);
        lstParams.Add("nonce=" + nonce);
        string[] strParams = lstParams.ToArray();
        Array.Sort(strParams);     //参数名ASCII码从小到大排序（字典序）； 
        string origin = string.Join("&", strParams);
        origin = string.Concat(origin, partnerKey);
        MD5 md5 = new MD5CryptoServiceProvider();
        byte[] targetData = md5.ComputeHash(System.Text.Encoding.UTF8.GetBytes(origin));
        StringBuilder sign = new StringBuilder("");
        foreach (byte b in targetData)
        {
            sign.AppendFormat("{0:x2}", b);
        }
        return sign.ToString();
    }

    /// <summary>
    /// 发送POST请求
    /// </summary>
    /// <param name="url"></param>
    /// <param name="postJson"></param>
    /// <returns></returns>
    public string PostFunctionV3(string url, string postJson)
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
        request.ContentType = "application/x-www-form-urlencoded";
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
        //Console.WriteLine(Result);
        return Result;

    }
    public string PostFunctionjson(string url, string postJson)
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
        //Console.WriteLine(Result);
        return Result;

    }
    public string orderDetail(string data)
    {

        //货号1|尺码1|尺码2|,货号2|尺码1|尺码2
        //货号1,货号2,....
        //string data = Context.Request.QueryString["data"].ToString();
        string sphhSql = "";
        //构造货号范围表   //
        foreach (string item in data.Split(','))
        {
            if (item.Contains("|"))
            {
                for (int i = 1; i < item.Split('|').Length; i++)
                {
                    sphhSql = sphhSql + " select '" + item.Split('|')[0] + "' as sphh,'cm" + item.Split('|')[i] + "' as cm union ";
                }
            }
            else
            {
                sphhSql = sphhSql + " select '" + item + "' as sphh,'cm24' as cm union ";
            }
        }
        string sql = "select a.sphh,a.cm into #sphh from (" + sphhSql.Substring(0, sphhSql.Length - 6) + ") a ;";
        sql += " select distinct sphh.lydjid as xzid,sphh.sphh into #range  ";
        sql += " from yf_v_rinsing_sphh_all sphh ";
        sql += " inner join (select distinct sphh from #sphh) hh on hh.sphh=sphh.sphh where  sphh.djzt=0 ";
        //构造货号范围表 end //

        //合格证信息           
        sql += " select f.id,f.lydjid,f.dbhg,f.dbtg,f.ddh as '水洗材料',f.fk as '水洗材料下装',f.dbxx as '西服三件套马甲',pm.mc '品名',isnull(bsz.mc,'') '品名上装',isnull(bxz.mc,'') '品名下装',isnull(bmj.mc,'') as '品名西服三件套马甲' ,";
        sql += " gb.dm '版型',yp.yphh '样号',case f.dsqk when '' then '' else f.dsqk+'：' end +f.shqk '洗涤方法',case f.dekz when '' then '' else f.dekz+'：' end +f.desz '洗涤方法上装',case f.jfk when '' then '' else f.jfk+'：' end+f.ghsyj '洗涤方法下装',xt.mc '警告语',g.mc '执行标准',f.jpg '等级',h.mc '安全技术类别',sphh.sphh '货号', m.notice '注意事项',m.store '使用和贮藏',";
        sql += " sx.notice 'sx注意事项',sx.store 'sx使用和贮藏',kusx.notice 'kusx注意事项',kusx.store 'kusx使用和贮藏' ";
        sql += " into #myzb  ";
        sql += " from yf_T_bjdlb f ";
        sql += " inner join #range r on r.xzid=f.id   ";
        sql += " inner join yf_v_rinsing_sphh_all sphh on f.id=sphh.lydjid  and sphh.sphh=r.sphh ";
        sql += " inner join Yf_T_bjdbjzb pm on pm.id=f.tplx";
        sql += " left join Yf_T_bjdbjzb bsz on f.dycs=bsz.id  ";
        sql += " left join Yf_T_bjdbjzb bxz on f.wtlx=bxz.id  ";
        sql += " left join Yf_T_bjdbjzb bmj on f.sftj=bmj.id  ";
        sql += " inner join Yf_T_bjdbjzb g on g.id=f.ddid";
        sql += " inner join yx_T_spdmb sp on sp.sphh=sphh.sphh";
        sql += " inner join yx_v_ypdmb yp on yp.yphh=sp.yphh ";
        sql += " left join  Yf_T_bjdbjzb gb on gb.id=yp.bhks  ";
        sql += " inner join Yf_T_bjdbjzb h on h.lx=905 and f.sylx=h.id and h.tzid=1 ";
        sql += " left join ghs_t_xtdm xt on xt.id=isnull(f.kzx4,0) ";
        sql += " inner join yf_v_rinsingtemplate  m on m.id=f.lydjid  ";
        sql += " left join yf_v_rinsingtemplate sx on sx.id=f.dbhg ";
        sql += " left join yf_v_rinsingtemplate kusx on kusx.id=f.dbtg ";
        sql += "  where   f.lxid=903 and  f.tzid='1' ; ";
        //table0 标签信息,一个货号一条记录
        sql += "  select * from #myzb; ";
        //table1 纤维含量
        sql += " select zb.货号,  ROW_NUMBER() OVER(PARTITION BY zb.货号 order by xw.sytjid) sytjid, ";
        sql += " /*case when isnull(xw.sz,'')='/' or isnull(xw.pdjg,'')='' then xw.sz else xw.pdjg+':'+xw.sz end as mxsz*/xw.pdjg,xw.sz,xw.glz   ";
        sql += " from #myzb zb   inner join yf_T_bjdmxb xw on zb.id=xw.mxid  and xw.lxid=903 ; ";
        //table2图标
        sql += " select a.* from ( ";
        sql += "   SELECT '主模版' lx, zb.货号, b.path,b.mc,b.dm FROM yf_v_rinsingtemplateico a INNER JOIN yf_V_rinsingico b ON a.icodm=b.dm  ";
        sql += "   inner join #myzb zb on zb.lydjid=a.mxid      ";
        sql += "   union all";
        sql += "   SELECT '上装' lx ,zb.货号, b.path,b.mc,b.dm FROM yf_v_rinsingtemplateico a INNER JOIN yf_V_rinsingico b ON a.icodm=b.dm  ";
        sql += "   inner join #myzb zb on zb.dbhg=a.mxid     ";
        sql += "   union all";
        sql += "   SELECT '下装' lx,zb.货号, b.path,b.mc,b.dm FROM yf_v_rinsingtemplateico a INNER JOIN yf_V_rinsingico b ON a.icodm=b.dm  ";
        sql += "   inner join #myzb zb on zb.dbtg=a.mxid      ";
        sql += "  ) a order by a.lx, cast( a.dm as int)   ";
        //table3 各尺寸绒含量
        sql += " SELECT b.lxbs,a.货号, hjyl=(mx.hsz+mx.bzsh),gg.hx crlhx,mx.cmdm ";
        sql += " FROM #myzb a ";
        sql += " inner join yx_T_spdmb sp on sp.sphh=a.货号";
        sql += " INNER JOIN dbo.YX_T_Ypdmb yp ON sp.yphh=yp.yphh ";
        sql += " INNER JOIN YF_T_Bom b ON b.yphh=yp.yphh  AND b.cmfj=1 ";
        sql += " inner join cl_v_chdmb_all ch on ch.chdm=b.chdm ";
        sql += " inner join yf_T_bjdlb bj on bj.id=ch.bjid and bj.kzx1 =297";
        sql += " INNER JOIN YF_T_Bomcmmx mx ON b.id=mx.id ";
        sql += " inner JOIN yx_V_sphxggb gg ON 'cm'+mx.cmdm=gg.cmdm AND yp.yphh=gg.yphh";
        //table4 水洗标材料
        sql += " select b.货号,b.lx, a.* from YF_v_SXBCHDM a inner join ( select 货号, 水洗材料 chdm,'上装' lx from #myzb union select 货号, 水洗材料下装 chdm,'下装' lx from #myzb union select 货号, 西服三件套马甲 chdm,'西服三件套马甲' lx from #myzb ) b on a.chdm=b.chdm ;";
        //5号型规格
        sql += " select  a.货号, zh.cmdm,isnull(k.hx,case when lw.id is not  null then  '不打印' else '未维护' end )  as hx, ";
        sql += " isnull(k.hx2,case when lw.id is not  null then  '不打印' else '未维护' end)  as hx2,";
        sql += " hx2isExists= case isnull(k.hx2,'') when '' then 0 else 1 end , ";
        sql += " isnull(k.gg,case when lw.id is not  null then  '不打印' else '未维护' end)  as gg ";
        sql += " from #myzb a";
        sql += " inner join yx_T_spdmb sp on sp.sphh=a.货号";
        sql += " inner join yx_v_ypdmb yp on yp.yphh=sp.yphh ";
        sql += " inner join yx_t_cmzh zh on zh.tml=yp.tml ";
        sql += " inner join (select distinct sphh from #sphh) kz on kz.sphh=a.货号  ";
        sql += " left join yx_V_sphxggb k on k.yphh=yp.yphh and zh.cmdm=k.cmdm";
        sql += " left join yx_V_noneedhxgg lw on lw.id=yp.splbid ";
        //6要显示哪些尺码
        sql += " select * from #sphh;";
        sql += " drop table #myzb; drop table #sphh;drop table #range;";
        DataSet htzinfoDs = null;
        //string ConnectionString = "Server=192.168.35.10;Database=TLSOFT;Uid=ABEASD14AD;Pwd=+AuDkDew;";
        using (LiLanzDALForXLM dal = new LiLanzDALForXLM(1))
        {
            dal.ConnectionString = "server='192.168.35.10';uid=ABEASD14AD;pwd=+AuDkDew;database=tlsoft "; ;
            dal.ExecuteQuery(sql, out htzinfoDs);
        }
        DataTable htzinfo = htzinfoDs.Tables[0].Copy();//'水洗信息
        DataTable hlinfo = htzinfoDs.Tables[1].Copy(); //纤维成份'
        DataTable icoinfo = htzinfoDs.Tables[2].Copy();// '图标'
        DataTable crlinfo = htzinfoDs.Tables[3].Copy();// '各尺寸绒含量
        DataTable chdminfo = htzinfoDs.Tables[4].Copy();// '水洗标材料
        DataTable hxgginfo = htzinfoDs.Tables[5].Copy();// '尺码表
        DataTable showinfo = htzinfoDs.Tables[6].Copy();// '要显示哪些尺码
        List<SphhInfo> sphhInfoList = new List<SphhInfo>();
        foreach (DataRow sphhdr in htzinfo.Rows)
        {
            SphhInfo sphhInfo = new SphhInfo();
            if (string.Compare(sphhdr["洗涤方法"].ToString(), "/") == 0)
            {
                sphhInfo.Xdff = "";
            }
            else
            {
                sphhInfo.Xdff = sphhdr["洗涤方法"].ToString();
            }
            if (string.Compare(sphhdr["洗涤方法上装"].ToString(), "/") == 0)
            {
                sphhInfo.Xdff_sz = "";
            }
            else
            {
                sphhInfo.Xdff_sz = sphhdr["洗涤方法上装"].ToString();
            }
            if (string.Compare(sphhdr["洗涤方法下装"].ToString(), "/") == 0)
            {
                sphhInfo.Xdff_xz = "";
            }
            else
            {
                sphhInfo.Xdff_xz = sphhdr["洗涤方法下装"].ToString();
            }
            //成份
            foreach (DataRow dr in hlinfo.Select("货号='" + sphhdr["货号"].ToString() + "'   "))
            {
                MaterialInfo2 cf = new MaterialInfo2();
                cf.Glz = int.Parse(dr["Glz"].ToString());
                cf.Sytjid = int.Parse(dr["Sytjid"].ToString());
                cf.Value = dr["sz"].ToString();
                cf.Title = dr["Pdjg"].ToString();
                sphhInfo.CfList.Add(cf);
            }
            //图标        
            foreach (DataRow dr in icoinfo.Select("货号='" + sphhdr["货号"].ToString() + "'   "))
            {
                Ico ico = new Ico();
                ico.Path = dr["path"].ToString();
                ico.Mc = dr["mc"].ToString();
                ico.Lx = dr["lx"].ToString();
                sphhInfo.IcoList.Add(ico);
            }
            //水洗标材料
            foreach (DataRow dr in chdminfo.Select("货号='" + sphhdr["货号"].ToString() + "'   "))
            {
                SxChdmDataContent sx = new SxChdmDataContent();
                sx.Lx = dr["lx"].ToString();
                sx.Sm = dr["sm"].ToString();
                sphhInfo.SxChdmList.Add(sx);
            }

            foreach (DataRow cmdr in hxgginfo.Select("货号='" + sphhdr["货号"].ToString() + "'   "))
            {
                SphhCmInfo s = new SphhCmInfo();
                s.Sphh = sphhdr["货号"].ToString();
                s.Cm = cmdr["cmdm"].ToString();
                s.Gg = cmdr["gg"].ToString();
                DataRow[] clrdr = crlinfo.Select("货号='" + sphhdr["货号"].ToString() + "' and 'cm'+cmdm='" + cmdr["cmdm"].ToString() + "'");
                if (clrdr.Length >= 1)
                {
                    foreach (DataRow dr in clrdr)
                    {
                        if (Decimal.Parse(dr["hjyl"].ToString()) > 0)
                        {
                            Dictionary<string, string> g = new Dictionary<string, string>();
                            g.Add("Clr", String.Format("{0:####.#}", Math.Round(Decimal.Parse(dr["hjyl"].ToString()) * 1000, 1)) + "g");
                            g.Add("Clrgg", dr["crlhx"].ToString());
                            g.Add("lxbs", dr["lxbs"].ToString());
                            s.ClrInfo.Add(g);
                        }
                        else
                        {
                            Dictionary<string, string> g = new Dictionary<string, string>();
                            g.Add("Clr", "");
                            g.Add("Clrgg", "");
                            g.Add("lxbs", "0");
                            s.ClrInfo.Add(g);
                        }
                    }
                }
                else
                {
                    Dictionary<string, string> g = new Dictionary<string, string>();
                    g.Add("Clr", "");
                    g.Add("Clrgg", "");
                    g.Add("lxbs", "0");
                    s.ClrInfo.Add(g);
                }
                s.Hx2isExists = int.Parse(cmdr["hx2isExists"].ToString());
                s.Hx = cmdr["hx"].ToString();
                s.Hx2 = cmdr["hx2"].ToString();
                sphhInfo.SphhCmInfo.Add(s);
            }
            sphhInfo.Sphh = sphhdr["货号"].ToString();
            foreach (DataRow dr in showinfo.Select("sphh='" + sphhdr["货号"].ToString() + "'"))
            {
                sphhInfo.Cm.Add(dr["cm"].ToString(), 1);
            }
            //sphhInfo.Cm = showinfo.Select("sphh='" + sphhdr["货号"].ToString() + "'")[0]["cm"].ToString();
            sphhInfo.Pm = sphhdr["品名"].ToString();
            sphhInfo.Pm_sz = sphhdr["品名上装"].ToString();
            sphhInfo.Pm_xz = sphhdr["品名下装"].ToString();
            sphhInfo.Pm_mj3 = sphhdr["品名西服三件套马甲"].ToString();
            sphhInfo.Yphh = sphhdr["样号"].ToString();
            sphhInfo.Bx = sphhdr["版型"].ToString();
            sphhInfo.Aqjb = sphhdr["安全技术类别"].ToString();
            sphhInfo.Jgy = sphhdr["警告语"].ToString();
            sphhInfo.Zysx = sphhdr["注意事项"].ToString();
            sphhInfo.Sycc = sphhdr["使用和贮藏"].ToString();
            sphhInfo.Zysx_sx = sphhdr["sx注意事项"].ToString();
            sphhInfo.Sycc_sx = sphhdr["sx使用和贮藏"].ToString();
            sphhInfo.Zysx_kusx = sphhdr["kusx注意事项"].ToString();
            sphhInfo.Sycc_kusx = sphhdr["kusx使用和贮藏"].ToString();
            sphhInfo.Zxbz = sphhdr["执行标准"].ToString();
            sphhInfoList.Add(sphhInfo);
        }
        return JsonConvert.SerializeObject(sphhInfoList);


    }

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


//WEBAPI

/// <summary>
/// POST数据
/// </summary>
public class Par
{
    public string partnerid;
    public string servicetype;
    public string bizdata;
    public string timestamp;
    public string nonce;
    public string sign;
}
/// <summary>
/// 疵点
/// </summary>
public class FabricFault
{
    public string cdmc;
    public string url;
    public float cdwz;
    public int cdfs;
}
/// <summary>
/// 码单
/// </summary>
public class WtMemoVO
{
    public string serviceuuid;
    public string ph;
    public string gh;
    public string ys;
    public float mdsl;
    public string xhdx;
    public string mfk;
    public float fk;
    public string kz;
    public string jh;
    public string sphh;
    public float mc;
    public string qtj;
    public string qtw;
    public string sxj;
    public string sxw;
    public float wx;
    public float sjsl;
    public float twsc;
    public float bzsc;
    public string tm;
    public string lltm;
    public string mdbz;
    public float wh;
    public float hpl;
    public string sjb;
    public string juanb;
    public string dxm;
    public List<FabricFault> fabricFaultList = new List<FabricFault>();

}
/// <summary>
/// 报告数据
/// </summary>
public class BillData
{
    public string clientuuid;
    public string djh;
    public string rq;
    public bool mlyqryzx;
    public string mlyqryzxbz;
    public bool dhyjdyzx;
    public string dhyjdyzxbz;
    public bool sghfgyqryzx;
    public string sghfgyqryzxbz;
    public bool pypzjsgyzx;
    public string pypzjsgyzxbz;
    public float hpl;
    public string bz;
    public string type;
    public int bgzt;
    public int lydjlx;
    public int lydjid;
    public int userid;
    public string tsrq;
    public List<WtMemoVO> wtMemoVOList = new List<WtMemoVO>();
}
//WEBAPI END


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
    public string 是否强标;
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
