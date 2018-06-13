<%@ WebHandler Language="C#" Class="LLWebApiRoute" Debug="true" %>
using System;
using System.Web;
using System.Data;
using System.IO;
using System.Text;
using System.Data.SqlClient;
using System.Collections.Generic;
using LLWebApi.Utils;
public class LLWebApiRoute : IHttpHandler
{
    Dictionary<string, string> partnerKeys = new Dictionary<string, string>();

    public void ProcessRequest(HttpContext context)
    {
        //rspInfo("00", "测试", CommUtil.GenerateNonceStr() + "|" + CommUtil.GenerateTimeStr("yyyyMMddHHmmss") + "|" + CommUtil.DateStrToDatetime("20170929", "yyyyMMdd").ToString());
        //初始化partnerKeys
        SetPartnerKeys();
        //数据流格式 "partnerid=1&servicetype=LLWebApi_CL_GetWTSData&bizdata=1&sign=1";            
        string reqData = readStream(context.Request.InputStream, "utf-8");
        //判断参数是否有值
        if (reqData.Length == 0)
        {
            rspInfo("203", "参数未传入", "");
        }
        //解析参数成字段格式       
        IDictionary<string, string> pars = HttpPostUtil.getURLParameters(reqData);
        //验证签名
        if (reqCheckSign(pars, pars["partnerid"]) == false)
        {
            //验签失败 逻辑
            rspInfo("202", "签名错误", "");
        }
        //执行接口逻辑
        handRout(pars["bizdata"], pars["servicetype"], pars["partnerid"]);

    }
    private void handRout(string bizData, string serviceType, string partnerID)
    {

        //验证serviceType是否有开放        
        if (!checkInterface(partnerID, serviceType))
        {
            rspInfo("200", "接口未开放", "");
        }
        //验证接口权限
        if (!checkQX(partnerID, serviceType))
        {
            rspInfo("201", "无接口权限", "");
        }
        //接口调用日志记录


        //根据serviceType服务类型调用不同接口实现; 返回结果如下
        HttpContext.Current.Server.TransferRequest(serviceType + ".ashx", true);

    }
    private void rspInfo(string code, string msg, string body)
    {
        string str = "\"errcode\":\"{0}\",\"errmsg\":\"{1}\",\"body\":\"{2}\"";
        HttpContext.Current.Response.Write("{" + string.Format(str, code, msg, body) + "}");
        HttpContext.Current.Response.End();
    }
    /// <summary>
    /// 验证接口权限
    /// </summary>
    /// <param name="serviceType"></param>
    /// <returns></returns>
    private bool checkQX(string partnerID, string serviceType)
    {
        return true;
    }

    /// <summary>
    /// 验证接口是否开放
    /// </summary>
    /// <param name="serviceType"></param>
    /// <returns></returns>
    private bool checkInterface(string partnerID, string serviceType)
    {
        return true;
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
    /// 请求验签
    /// </summary>
    /// <param name="sign"></param>
    /// <param name="bizData"></param>
    /// <param name="partnerID"></param>
    /// <returns></returns>
    private bool reqCheckSign(IDictionary<string, string> pars, string partnerid)
    {
        string partnerKeyVal = partnerKeys[partnerid];//通过partnerID数据库获取partnerKey参与验证；
        string orgin = SignUtil.sortSignData(pars) + partnerKeyVal;

        return SignUtil.CheckSign(pars["sign"], orgin);
    }

    /// <summary>
    /// 设置partnerKeys的值
    /// </summary>
    private void SetPartnerKeys()
    {
        partnerKeys.Add("18868", "93A0AC1C-C5EE-4159-B5BA-5ADED33F88A8"); //委托书。键名：yx_T_khb.khid 
        partnerKeys.Add("16434", "7a6ee705-18cc-4614-b2bb-f8b6b0095e4e"); //强兴吊牌分检
    }

    public bool IsReusable
    {
        get { return true; }
    }
}


