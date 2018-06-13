<%@ WebHandler Language = "C#" Class="Bank_CIBBill" Debug="true" %>
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
using KPay.Qy2Bank; 
using nrWebClass;
/*
 *错误码  
 *0  成功
 *100 路由参数为空
 *101 无效路由参数
 *102 业务参数异常
 *105 业务执行失败
 */
public class Bank_CIBBill : IHttpHandler
{        
    public void ProcessRequest(HttpContext context)
    {
        string action = context.Request.Params["action"];
        
        if (action == null)
        {
            rspInfo("100", "路由参数为空", "");
        }
        //数据流格式 "partnerid=1&servicetype=XXX&bizdata=1&sign=1";        
        string reqData = readStream(context.Request.InputStream, "utf-8");
        reqData = "tzid=1&userid=33";
        if (reqData.Length == 0)
        {
            rspInfo("10201", "未接收到参数","");
        }        
        
        IDictionary<string, string> pars = getXmlParameters(reqData);
        //KPay.Common.LogHelper.Error("LLKDReciver", reqData);
         
        //执行接口逻辑
        handRout(pars, action);
    }
    private bool handRout(IDictionary<string, string> pars, string action)
    {
        //接口调用日志记录
        //KPay.Common.LogHelper.Error("LLKDReciver", action);

        switch (action.ToUpper())
        {
            case "CIBBILL_DQS":
                //根据serviceType服务类型调用不同接口实现; 返回结果如下
                CIBBill_dqs(pars);
                break;
            default:
                rspInfo("101", "无效路由参数", "");
                break;
        }       
 
        return true;
    }
    //实现待签收票据下载逻辑
    private void CIBBill_dqs(IDictionary<string, string> pars)
    {
        BankData req = null;
        string tsxx = "";
        IBank tCilent = DefaultBank.Create(pars["tzid"], pars["userid"], "CIB");
        if (tCilent.mCdpj_syncdqs(req,1 ,out tsxx) == 1)
        {
            rspInfo("0", "", "");
        }
        else
        {
            rspInfo("105", tsxx, "");
        };
    }
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
    #region 工具方法-无业务逻辑
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
    /// 返回数据
    /// </summary>
    /// <param name="code"></param>
    /// <param name="msg"></param>
    /// <param name="body"></param>
    private void rspInfo(string code, string msg, string body)
    {
        string str = "\"errcode\":\"{0}\",\"errmsg\":\"{1}\",\"body\":\"{2}\"";
        HttpContext.Current.Response.Write("{" + string.Format(str, code, msg, body) + "}");
        HttpContext.Current.Response.End();
    }
#endregion
    public bool IsReusable
    {
        get { return true; }
    }
}


