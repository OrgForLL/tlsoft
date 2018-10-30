<%@ WebHandler Language="C#" Class="api" %>

using System;
using System.Collections.Generic;
using System.Reflection;
using System.Web;
using System.Data;
using nrWebClass;
using System.Text;
using System.Data.SqlClient;

public class api : IHttpHandler, System.Web.SessionState.IRequiresSessionState
{
        
    public void ProcessRequest(HttpContext context)
    {
        context.Response.ContentType = "text/plain";

        string act = context.Request.Params["act"];
        if (string.IsNullOrEmpty(act))
        {
            clsSharedHelper.WriteErrorInfo("缺少接口参数act！");
            return;
        }

        Type t = this.GetType();

        MethodInfo method = t.GetMethod(act);
        method.Invoke(this, null);
    }

    #region 调试模式


    #endregion

    #region 报文管理
    private const string ApiJson = @"{{ ""errcode"":""{0}"",""errmsg"":""{1}""{2} }}";

    /// <summary>
    /// 输出JSON
    /// </summary>
    /// <param name="errcode"></param>
    /// <param name="errmsg"></param>
    /// <param name="data"></param>
    private void ResponseApiJson(string errcode,string errmsg,string data)
    {
        if (string.IsNullOrEmpty(data) == false) data = data.Insert(0, ",");

        clsSharedHelper.WriteInfo(string.Format(ApiJson, errcode, errmsg, data));
    }
    /// <summary>
    /// 输出JSON
    /// </summary>
    /// <param name="errcode"></param>
    /// <param name="errmsg"></param>
    /// <param name="data"></param>
    private void ResponseApiJson(string data)
    {
        ResponseApiJson("0","ok",data);
    }
    /// <summary>
    /// 执行正确
    /// </summary> 
    private void ResponseApiOK()
    {
        ResponseApiJson("0","ok","");
    }
    /// <summary>
    /// 输出JSON，表示错误
    /// </summary>
    /// <param name="errcode"></param>
    /// <param name="errmsg"></param>
    private void ResponseApiErrorJson(string errcode, string errmsg)
    {
        if (errmsg.StartsWith(clsSharedHelper.Error_Output)) errmsg = errmsg.Remove(0, clsSharedHelper.Error_Output.Length);

        clsSharedHelper.WriteInfo(string.Format(ApiJson, errcode, errmsg, ""));
    }
    #endregion

    #region 公用逻辑



    /// <summary>
    /// 返回处理后的List Json字符串，可直接加入报文
    /// </summary>
    /// <param name="dt"></param>
    /// <param name="ListName"></param>
    /// <returns></returns>
    private string cutListJson(ref DataTable dt,string ListName)
    {
        string str = "";
        try
        {
            using (clsDBHelper dal = new clsDBHelper())
            {
                str = dal.DataTableToJson(dt, ListName, true);
                int len = str.ToString().Length;
                if (len > 2) str = str.ToString().Substring(1, len - 2);

                return str;
            }
        }
        finally
        {
            str = "";
        }
    }


    private string cutListJson(ref DataTable dt)
    {
        return cutListJson(ref dt, "List");
    }
    #endregion

    #region 接口实现


    /// <summary>
    /// 获取微信JSAPI的相关参数
    /// </summary>
    public void getJsApiConfig()
    {
        string url = HttpContext.Current.Request.Params["nowurl"];
        string KeyValue = clsConfig.GetConfigValue("CurrentConfigKey");
        List<string> lstConfig = clsWXHelper.GetJsApiConfig(KeyValue, url);
        string rtInfo =  string.Join("|", lstConfig.ToArray());

        ResponseApiJson(string.Concat("\"data\":\"",  rtInfo,"\""));
    }

    /// <summary>
    /// 发送短信
    /// </summary>
    public bool SendVipSMS(string msg, string phoneNumber,string khid)
    {
        msg = HttpUtility.UrlEncode(msg, System.Text.Encoding.UTF8);
        string sendUrl = "http://10.0.0.15:9001/tl_zmd/MSGSendBase.ashx?msgtype=gd&sysid=0&userssid={2}&userid=0&username=vipReg&phone={0}&msg={1}";
        sendUrl = string.Format(sendUrl, phoneNumber, msg,khid);
        string rt = clsNetExecute.HttpRequest(sendUrl, "", "get", "utf-8", 3000);
        if (rt.Contains("成功"))
        {
            return true;
        }

        clsLocalLoger.WriteError("发送VIP验证短信失败！错误：" + rt);

        return false;
    }


    /// <summary>
    /// 获取企业号用户信息并生成json
    /// </summary>
    /// <param name="phone"></param>
    /// <returns></returns>
    private string GetQYUserJson(string phone)
    {
        string strInfo = "";
        string OAConnStr = clsConfig.GetConfigValue("OAConnStr");
        using (LiLanzDALForXLM dal = new LiLanzDALForXLM(OAConnStr))
        {
            DataTable dt = null;
            strInfo = dal.ExecuteQuery(string.Format("SELECT TOP 1 * FROM wx_t_customers WHERE mobile = '{0}'", phone), out dt);
            if (strInfo != "")
            {
                clsLocalLoger.WriteError("查询企业号数据库失败！错误：" + strInfo);
            }

            //clsLocalLoger.WriteInfo("取得数据：" + dt.Rows.Count.ToString());

            if (dt.Rows.Count > 0)
            {
                string avatar = Convert.ToString(dt.Rows[0]["avatar"]);
                if (!avatar.Contains(":"))
                {
                    avatar = string.Concat(clsConfig.GetConfigValue("OA_WebPath"), avatar);
                    dt.Rows[0]["avatar"] = avatar;
                }
            }

            string json = dal.DataTableToJson(dt);
            clsSharedHelper.DisponseDataTable(ref dt);
            return json;
        }
    }
    // <summary>
    /// 获取VIP用户信息并生成json
    /// </summary>
    /// <param name="phone"></param>
    /// <returns></returns>
    private string GetVipUserJson(string phone)
    {
        string strInfo = "";
        string OAConnStr = clsConfig.GetConfigValue("OAConnStr");
        using (LiLanzDALForXLM dal = new LiLanzDALForXLM(OAConnStr))
        {
            DataTable dt = null;
            strInfo = dal.ExecuteQuery(string.Format(@"SELECT TOP 1 A.kh CardCode,A.xm UserName,A.xb Sex,A.yddh Phone,A.csrq Birthday,A.khid,B.wxHeadimgurl FaceImg FROM yx_t_vipkh A
                        LEFT JOIN wx_t_vipBinging B ON A.id = B.vipID AND B.ObjectID = 1
                        WHERE yddh = '{0}' AND ty = 0 ORDER BY A.ID DESC", phone), out dt);
            if (strInfo != "")
            {
                clsLocalLoger.WriteError("查询VIP数据库失败！错误：" + strInfo);
            }

            //clsLocalLoger.WriteInfo("取得数据：" + dt.Rows.Count.ToString());

            if (dt.Rows.Count > 0)
            {
                string FaceImg = Convert.ToString(dt.Rows[0]["FaceImg"]);
                if (!FaceImg.Contains(":"))
                {
                    FaceImg = string.Concat(clsConfig.GetConfigValue("VIP_WebPath"), FaceImg);
                    dt.Rows[0]["FaceImg"] = FaceImg;
                }
            }

            string json = dal.DataTableToJson(dt);
            clsSharedHelper.DisponseDataTable(ref dt);
            return json;
        }
    }


    //演示地址：http://tm.lilanz.com/qywx/project/shoes/api.ashx?act=QySendCode&phone=13055812566
    //企业号用户：发送微信验证码
    public void QySendCode()
    {
        string phone = HttpContext.Current.Request.Params["phone"];

        //首先获取用户的name        
        string jsonData = GetQYUserJson(phone);
        if (jsonData == "") {
            ResponseApiErrorJson("500", "无法获取用户");
            return;
        }

        //clsLocalLoger.WriteInfo("jsonData：" + jsonData);
        //如果获取到就调用企业号接口向name 发送随机验证码，并记录这个电话号码和随机码到Session["CheckQYSms"] = QY + | + 电话号码  + | + 随机码
        using (clsJsonHelper jh = clsJsonHelper.CreateJsonHelper(jsonData))
        {
            Random rd = new Random();
            int rndInt = rd.Next(1000, 10000);
            string MsgContent = string.Concat("您的登录验证码为【",rndInt,"】。");

            HttpContext.Current.Application["CheckQYSms"] = string.Concat("QY","|", phone,"|", rndInt);

            using (clsJsonHelper jh2 = clsWXHelper.SendQYMessage(jh.GetJsonValue("list/name"), 0, MsgContent))
            {
                if (jh2.GetJsonValue("errcode") == "0")
                {
                    ResponseApiOK();
                }else
                {
                    ResponseApiErrorJson(jh2.GetJsonValue("errcode"), jh2.GetJsonValue("errmsg"));
                }
            }
        }
    }

    //演示地址：http://tm.lilanz.com/qywx/project/shoes/api.ashx?act=QyCheckCode&phone=13055812566&code=3008
    //企业号用户：验证微信验证码
    public void QyCheckCode()
    {
        string phone = HttpContext.Current.Request.Params["phone"];
        string code = HttpContext.Current.Request.Params["code"];

        string checkValue = string.Concat("QY","|", phone,"|", code);
        if (Convert.ToString(HttpContext.Current.Application["CheckQYSms"]) == checkValue)
        {
            //读取这个 企业号用户的信息
            string jsonData = GetQYUserJson(phone);

            using(clsJsonHelper jh = clsJsonHelper.CreateJsonHelper(jsonData))
            {
                jsonData = jh.GetJsonNodes("list")[0].jSon;

                ResponseApiJson(string.Concat(@"""info"":",jh.GetJsonNodes("list")[0].jSon));
            }
        }else
        {
            ResponseApiErrorJson("5233", "验证码错误！" + Convert.ToString(HttpContext.Current.Application["CheckQYSms"]) + "|XXXX|" + checkValue);
        }
    }

    //演示地址：http://tm.lilanz.com/qywx/project/shoes/api.ashx?act=VipSendCode&phone=13055812566
    //企业号用户：发送短信验证码
    public void VipSendCode()
    {
        string phone = HttpContext.Current.Request.Params["phone"];

        Random rd = new Random();
        int rndInt = rd.Next(1000, 10000);
        string MsgContent = string.Concat("您的登录验证码为【", rndInt, "】。");

        //首先获取用户的name        
        string jsonData = GetVipUserJson(phone);
        bool isGuest = false;
        if (jsonData == "")
        {
            //ResponseApiErrorJson("500", "无法获取用户");
            //return;
            isGuest = true;
            jsonData = @"{""list"":{""khid"":""1""} }";
        }

        clsLocalLoger.WriteInfo("jsonData：" + jsonData);
        //记录这个电话号码和随机码到Session["CheckVIPSms"] = VIP + | + 电话号码  + | + 随机码 + | + 用户类型
        using (clsJsonHelper jh = clsJsonHelper.CreateJsonHelper(jsonData))
        {

            if (isGuest) HttpContext.Current.Application["CheckVipSms"] = string.Concat("VIP", "|", phone, "|", rndInt , "|Guest");
            else  HttpContext.Current.Application["CheckVipSms"] = string.Concat("VIP", "|", phone, "|", rndInt , "|VIP");
            if (SendVipSMS(MsgContent, phone, jh.GetJsonValue("list/khid"))){
                ResponseApiOK();
            }else
            {
                ResponseApiErrorJson("503", "消息发送失败！");
            }
        }
    }


    //演示地址：http://tm.lilanz.com/qywx/project/shoes/api.ashx?act=VipCheckCode&phone=13055812566&code=1234
    //企业号用户：验证微信验证码
    public void VipCheckCode()
    {
        string phone = HttpContext.Current.Request.Params["phone"];
        string code = HttpContext.Current.Request.Params["code"];

        string checkValue = string.Concat("VIP","|", phone,"|", code);
        string CheckInfoValue = Convert.ToString(HttpContext.Current.Application["CheckVipSms"]);
        if (CheckInfoValue.StartsWith(checkValue))
        {
            string[] lst = CheckInfoValue.Split('|');
            if (lst[3] == "Guest")
            {
                ResponseApiOK();
                return;
            }
            else
            {
                //读取这个 客户的信息
                string jsonData = GetVipUserJson(phone);
                if (jsonData == "")
                {
                    ResponseApiOK();
                    return;
                }

                using (clsJsonHelper jh = clsJsonHelper.CreateJsonHelper(jsonData))
                {
                    jsonData = jh.GetJsonNodes("list")[0].jSon;

                    ResponseApiJson(string.Concat(@"""info"":", jh.GetJsonNodes("list")[0].jSon));
                }
            }
        }else
        {
            ResponseApiErrorJson("5233", "验证码错误！");
        }
    }


    #endregion

    public bool IsReusable
    {
        get
        {
            return false;
        }
    }
}