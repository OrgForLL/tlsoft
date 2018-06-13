<%@ WebHandler Language = "C#" Class="LLKdReceive" Debug="true" %>
using System;
using System.Web;
using System.Data;
using System.IO;
using System.Text;
using System.Data.SqlClient;
using System.Collections.Generic;
using Newtonsoft.Json;
using nrWebClass;
using LLKD.BesBase;
using LLKD.BesUtils;
using kdOrderStatusPush;

public class LLKdReceive : IHttpHandler
{
    //private string CSDBConnStr = "server='192.168.35.23';uid=lllogin;pwd=rw1894tla;database=tlsoft";
    public void ProcessRequest(HttpContext context)
    {
        //数据流格式 "partnerid=1&servicetype=XXX&bizdata=1&sign=1";        
        string reqData = readStream(context.Request.InputStream, "utf-8");
        //reqData = "bizData=<?xml version=\"1.0\" encoding=\"UTF-8\" standalone=\"yes\"?><request><txLogisticID>120170718142019551</txLogisticID><status>CREATE_FAIL</status><remark>E05IMP200010057</remark></request>&serviceType=KD_ORDER_STATUS_PUSH&partnerID=KDTESTXML&sign=d0102d626d10ccefa0a0c577be7952b3";
        //判断参数是否有值
        if (reqData.Length == 0)
        {
             rspXML("false","未接收到参数");
        }
        //记录接收数据
        KPay.Common.LogHelper.Error("LLKDReciver", reqData);
        //解析参数成字段格式       
        IDictionary<string, string> pars = getXmlParameters(reqData);

        //验证签名
        if (reqCheckSign(null) == false)
        {
            //验签失败 逻辑
            rspXML("false","验签失败");
        }
        //执行接口逻辑
        if (handRout(pars["bizData"], pars["serviceType"]) == true)
        {
            rspXML("true", "");
        }
        else
        {
            rspXML("false", "接收成功，本地处理失败");
        }

    }
    private bool handRout(string bizData,string action)
    {
        //接口调用日志记录
        //KPay.Common.LogHelper.Error("LLKDReciver", action);
        
        //根据action调用不同处理函数
        if (action == "KD_ORDER_STATUS_PUSH")
        {                   
            KdOrderStatusPushReq req = (KdOrderStatusPushReq)XmlUtils.xmlToObj(bizData, typeof(KdOrderStatusPushReq));
            if (SaveInfo(req) == false)
            {
                KPay.Common.LogHelper.Error("LLKDReciver:接收的业务参数", bizData);
            }
            req = null;
        }
        else if (action =="KD_SCAN_PUSH")
        {
        }
        return true;
    }
    #region 
    private bool SaveInfo(KdOrderStatusPushReq req)
    {
        bool bVal = false;
        string CSDBConnStr=clsConfig.GetConfigValue("OAConnStr");
        //KPay.Common.LogHelper.Error("LLKDReciver:接收的业务参数", CSDBConnStr);
        using (LiLanzDALForXLM dal = new LiLanzDALForXLM(CSDBConnStr))
        {
            string str_sql = @" insert into kd_t_traceInfo(txLogisticID,status,mailNo,acceptTime,currentCity,nextCity,facility,contactInfo,weight,trackingInfo,remark,zdr,zdrq) 
                         values( @txLogisticID,@status,@mailNo,@acceptTime,@currentCity,@nextCity,@facility,@contactInfo,@weight,@trackingInfo,@remark,'sys',getdate() ); select 1";
            List<SqlParameter> para = new List<SqlParameter>();
            para.Add(new SqlParameter("@txLogisticID", isEmpty(req.txLogisticID)));
            para.Add(new SqlParameter("@status", isEmpty(req.status)));
            para.Add(new SqlParameter("@mailNo", isEmpty(req.mailNo)));
            para.Add(new SqlParameter("@acceptTime", isEmpty(req.acceptTime)));
            para.Add(new SqlParameter("@currentCity", isEmpty(req.currentCity)));
            para.Add(new SqlParameter("@nextCity", isEmpty(req.nextCity)));
            para.Add(new SqlParameter("@facility", isEmpty(req.facility)));
            para.Add(new SqlParameter("@contactInfo", isEmpty(req.contactInfo)));
            para.Add(new SqlParameter("@weight", isEmpty(req.weight)));
            para.Add(new SqlParameter("@trackingInfo", isEmpty(req.trackingInfo)));
            para.Add(new SqlParameter("@remark", isEmpty(req.remark)));
            object scalar;
            string errinfo = dal.ExecuteQueryFastSecurity(str_sql, para, out scalar);

            if (errinfo == "")
            {
                bVal = true;
            }
            else
            {
                KPay.Common.LogHelper.Error("LLKDReciver数据保存失败", str_sql + "|" + errinfo + "|");
                bVal = false;
            }
        }
        
        return bVal;
    }
    private void rspXML(string zt,string bz)
    {
        string str="<?xml version=\"1.0\" encoding=\"UTF-8\" standalone=\"yes\"?><response><result>{0}</result><remark>{1}</remark><errorCode></errorCode><errorDescription></errorDescription></response>";
        HttpContext.Current.Response.Write(string.Format(str, zt, bz));
        HttpContext.Current.Response.End();
    }
    private string isEmpty(object str)
    {
        string bVal = "";

        if (str != null)
        {
            bVal = str.ToString();
        }
        return bVal;
    }
    /// <summary>
    /// 读取数据流
    /// </summary>
    /// <param name="iStream"></param>
    /// <param name="charset"></param>
    /// <returns></returns>
    private string readStream(Stream iStream, string charset)
    {
        StreamReader reader = new StreamReader(iStream, Encoding.GetEncoding(charset));
        return HttpContext.Current.Server.UrlDecode(reader.ReadToEnd());        
    }
    /// <summary>
    /// 解析Json参数
    /// </summary>
    /// <param name="str">格式：name=value&name1=value1</param>
    /// <returns></returns>
    private IDictionary<string, string> getJsonParameters(string jsonText)
    {
        Dictionary<string, string> parameters = JsonConvert.DeserializeObject<Dictionary<string, string>>(jsonText);         
        return parameters;
    }
    /// <summary>
    /// 解析XML参数
    /// </summary>
    /// <param name="str">格式：name=value&name1=value1</param>
    /// <returns></returns>
    private IDictionary<string, string> getXmlParameters(string str)
    {
        Dictionary<string, string> parameters = new Dictionary<string, string>();
        string[] arrParameters = str.Split('&');
        for (int i = 0; i < arrParameters.Length; i++)
        {
            string kname = arrParameters[i].Split('=')[0];
            parameters.Add(kname, arrParameters[i].Substring(kname.Length + 1));
            //KPay.Common.LogHelper.Error("LLKDReciver", kname+"|"+arrParameters[i].Substring(kname.Length + 1));
        }
        return parameters;
    }

    /// <summary>
    /// 请求验签
    /// </summary>
    /// <param name="sign"></param>
    /// <param name="bizData"></param>
    /// <param name="partnerID"></param>
    /// <returns></returns>
    private bool reqCheckSign(IDictionary<string, string> pars)
    {
        return true;
    }
#endregion
    public bool IsReusable
    {
        get { return true; }
    }
}


