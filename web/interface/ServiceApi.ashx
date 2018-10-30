 <%@ WebHandler Language="C#" Class="PosCore" %>

using System;
using System.Web;
using nrWebClass;
using Newtonsoft.Json;
using System.Reflection;
using System.Collections.Generic;
using System.Data.SqlClient;
using System.Data;
using Class_TLtools;
using Newtonsoft.Json.Linq;
using System.IO;
using System.Net;
using System.Text;
//using MicroService;
public class PosCore : IHttpHandler, System.Web.SessionState.IRequiresSessionState
{
    int errcode = 0;
    public ResponseModel res;
    public string gateway = "";
    public string policiesurl = "";
    public string vipServerUrl = "";
    public string svrOrderUrl = "";
    public void ProcessRequest(HttpContext context)
    {

        

        gateway = clsConfig.GetConfigValue("gateway");

        policiesurl = string.Format("{0}{1}", gateway, "svr-commodity");
        vipServerUrl = string.Format("{0}{1}", gateway, "svr-vip");
        svrOrderUrl = string.Format("{0}{1}", gateway, "svr-order");

        context.Response.ContentEncoding = System.Text.Encoding.UTF8;
        context.Request.ContentEncoding = System.Text.Encoding.UTF8;
        string action = Convert.ToString(context.Request.Params["action"]);
        MethodInfo method = this.GetType().GetMethod(action);
        if (method == null)
            res = ResponseModel.setRes(201, "未找到对应的action,请核对后再试！");
        else
        {
            try
            {
                method.Invoke(this, null);
                return;
            }
            catch (Exception ex)
            {
                res = ResponseModel.setRes(201, "Server Error!!" + ex.Message);
            }
        }

        clsSharedHelper.WriteInfo(JsonConvert.SerializeObject(res));
    }

    //派车weixin
    public void sendCar()
    {
        res = new ResponseModel();
        int systemid = Convert.ToInt32(HttpContext.Current.Request.Params["systemid"]);
        string systemkeys = Convert.ToString(HttpContext.Current.Request.Params["systemkeys"]);
        string BeginTime = Convert.ToString(HttpContext.Current.Request.Params["BeginTime"]);
        string syr = Convert.ToString(HttpContext.Current.Request.Params["syr"]);
        string jsy = Convert.ToString(HttpContext.Current.Request.Params["jsy"]);
        string sxry = Convert.ToString(HttpContext.Current.Request.Params["sxry"]);
        string pccph = Convert.ToString(HttpContext.Current.Request.Params["pccph"]);
        string scdd = Convert.ToString(HttpContext.Current.Request.Params["scdd"]);
        string qx = Convert.ToString(HttpContext.Current.Request.Params["qx"]);
        int createID = Convert.ToInt32(HttpContext.Current.Request.Params["CreateID"]);
        if (sxry == "")
        {
            sxry = "无";
        }
        string content = "利郎派车提醒\r\n您好,您有一张派车单！信息如下：\r\n开始时间:" + BeginTime + "\r\n车牌号:【" + pccph + "】\r\n上车地点:【" + scdd + "】\r\n去向:【" + qx + "】\r\n随行人员:"+sxry+"\r\n通知时间:" + DateTime.Now ;
        string contentLimit = "利郎派车提醒\r\n您好,您有一张派车单还有30分钟！信息如下：\r\n开始时间:" + BeginTime + "\r\n车牌号:【" + pccph + "】\r\n上车地点:【" + scdd + "】\r\n去向:【" + qx + "】\r\n随行人员:" + sxry + "\r\n通知时间:" + DateTime.Now;

        
        DateTime date = Convert.ToDateTime(BeginTime);
        DateTime date2 = date.AddHours(-0.5);
        BeginTime = date2.ToString();
        BeginTime = BeginTime.Replace("/", "-");
        
        
        int msgTypeID = 8001;
        string RequestID = Guid.NewGuid().ToString();
        Dictionary<string, object> data = new  Dictionary<string, object>();
        Dictionary<string, object> msgjson = new  Dictionary<string, object>();

        msgjson.Add("systemid", systemid);
        msgjson.Add("systemkeys", systemkeys);
        msgjson.Add("content", content);
        msgjson.Add("agentid", 0);//企业号

        data.Add("MsgJson",msgjson);
        data.Add("MsgTypeID", msgTypeID);
        data.Add("CreateID", createID);
        data.Add("RequestID", RequestID);

        string datajson = JsonConvert.SerializeObject(data);
        string rt;
        string rtLimitTime;
        
        try
        {
            rt = clsNetExecute.HttpRequest(string.Format("{0}/base-msgservice/Create?data={1}", gateway, datajson), "", "POST", "UTF-8", 10000);

            if (rt.IndexOf("errcode") < 0 )
            {
                res.errcode = 201;
                res.errmsg = rt;    
                rt = JsonConvert.SerializeObject(res);
            }
        }   
        catch (Exception e)
        {
            clsLocalLoger.Log("【发车消息请求失败】" + e.ToString());
            res.errcode = 201;
            res.errmsg = e.ToString();
            rt = JsonConvert.SerializeObject(res);
        }

        data.Add("BeginTime", BeginTime);
        msgjson["content"] = contentLimit;
        data["RequestID"] = Guid.NewGuid().ToString();
        datajson = JsonConvert.SerializeObject(data);

        try
        {
            rtLimitTime = clsNetExecute.HttpRequest(string.Format("{0}/base-msgservice/Create?data={1}", gateway, datajson), "", "POST", "UTF-8", 10000);

            if (rtLimitTime.IndexOf("errcode") < 0)
            {
                res.errcode = 201;
                res.errmsg = rtLimitTime;
                rtLimitTime = JsonConvert.SerializeObject(res);
            }
        }
        catch (Exception e)
        {
            clsLocalLoger.Log("【延时发车消息请求失败】" + e.ToString());
            res.errcode = 201;
            res.errmsg = e.ToString();
            rtLimitTime = JsonConvert.SerializeObject(res);
        }
        
        clsSharedHelper.WriteInfo(rtLimitTime);
        clsSharedHelper.WriteInfo(rt);
    }

    //加工结算表审核提醒
    public void auditProcess() {
        res = new ResponseModel();
        int systemid = Convert.ToInt32(HttpContext.Current.Request.Params["systemid"]);
        int systemkeys = Convert.ToInt32(HttpContext.Current.Request.Params["systemkeys"]);
        int createID = Convert.ToInt32(HttpContext.Current.Request.Params["CreateID"]);

        string content = Convert.ToString(HttpContext.Current.Request.Params["content"]);

        
        int msgTypeID = 8001;
        string RequestID = Guid.NewGuid().ToString();
        Dictionary<string, object> data = new Dictionary<string, object>();
        Dictionary<string, object> msgjson = new Dictionary<string, object>();

        msgjson.Add("systemid", systemid);
        msgjson.Add("systemkeys", systemkeys);
        msgjson.Add("content", content);
        msgjson.Add("agentid", 0);//企业号

        data.Add("MsgJson", msgjson);
        data.Add("MsgTypeID", msgTypeID);
        data.Add("CreateID", createID);
        data.Add("RequestID", RequestID);

        string datajson = JsonConvert.SerializeObject(data);
        string rt;

        try
        {
            rt = clsNetExecute.HttpRequest(string.Format("{0}/base-msgservice/Create?data={1}", gateway, datajson), "", "POST", "UTF-8", 10000);

            if (rt.IndexOf("errcode") < 0)
            {
                res.errcode = 201;
                res.errmsg = rt;
                rt = JsonConvert.SerializeObject(res);
            }
        }
        catch (Exception e)
        {
            clsLocalLoger.Log("【加工结算表审核消息请求失败】" + e.ToString());
            res.errcode = 201;
            res.errmsg = e.ToString();
            rt = JsonConvert.SerializeObject(res);
        }
        clsSharedHelper.WriteInfo(rt);
    }
    public bool IsReusable
    {
        get
        {
            return false;
        }
    }
}
