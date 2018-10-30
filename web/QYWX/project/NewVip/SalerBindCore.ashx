<%@ WebHandler Language="C#" Class="SalerBindCore" %>

using System;
using System.Web;
using nrWebClass;
using System.IO;
using Newtonsoft.Json;
using Newtonsoft.Json.Linq;
using System.Reflection;
using System.Text;
using System.Collections.Generic;
using System.Data;
using System.Data.SqlClient;

public class SalerBindCore : IHttpHandler
{
    //private static string DBConnStr = "server='192.168.35.10';uid=ABEASD14AD;pwd=+AuDkDew;database=tlsoft";
    public ResponseModel res;
    public Dictionary<string, object> reqParams = new Dictionary<string, object>();

    public void ProcessRequest(HttpContext context)
    {
        context.Response.ContentType = "application/json;charset=utf-8";
        context.Response.ContentEncoding = System.Text.Encoding.UTF8;
        context.Request.ContentEncoding = System.Text.Encoding.UTF8;

        if ("POST" == context.Request.HttpMethod.ToUpper())
        {
            if (!context.Request.ContentType.Contains("application/json"))
            {
                res = ResponseModel.setRes(10001, "Invoke Request ContentType!");
            }
            else
            {
                string paramStr = Encoding.UTF8.GetString(context.Request.BinaryRead(context.Request.TotalBytes));
                if (string.IsNullOrEmpty(paramStr))
                    res = ResponseModel.setRes(10002, "Empty parameters!");
                else
                {
                    try
                    {
                        reqParams = JsonConvert.DeserializeObject<Dictionary<string, object>>(paramStr);
                        string action = "";
                        bool containAction = reqParams.ContainsKey("action");
                        if (!containAction || (containAction && string.IsNullOrEmpty(Convert.ToString(reqParams["action"]))))
                            res = ResponseModel.setRes(10003, "Empty action!");
                        else
                        {
                            action = Convert.ToString(reqParams["action"]);
                            MethodInfo method = this.GetType().GetMethod(action);
                            if (method == null)
                                res = ResponseModel.setRes(10004, "Invalid action!");
                            else
                            {
                                method.Invoke(this, new object[] { });
                            }
                        }
                    }
                    catch (Exception ex)
                    {
                        res = ResponseModel.setRes(10005, "Invoke Method Error!" + ex.Message);
                    }//end try
                }
            }
        }
        else
            res = ResponseModel.setRes(10006, "请求方式不正确！" + context.Request.HttpMethod.ToUpper());

        clsSharedHelper.WriteInfo(JsonConvert.SerializeObject(res));
    }

    //粉丝扫导购二维码
    public void fansBindStore()
    {
        string openid = getParamValue("openid");
        string storeid = getParamValue("storeid");
        string opinion = getParamValue("opinion");
        string cid = getParamValue("cid");

        if (string.IsNullOrEmpty(openid))
            res = ResponseModel.setRes(10007, "Invalid params [openid]!");
        else if (string.IsNullOrEmpty(storeid))
            res = ResponseModel.setRes(10007, "Invalid params [storeid]!");
        else if (string.IsNullOrEmpty(cid))
            res = ResponseModel.setRes(10007, "Invalid params [cid]!");
        else
        {
            //string Enum.GetName(typeof(clsWXHelper.DisBindVipOpinion), -1);        
            clsWXHelper.DisBindVipOpinion opItem = clsWXHelper.DisBindVipOpinion.首次关注;

            foreach (clsWXHelper.DisBindVipOpinion op in Enum.GetValues(typeof(clsWXHelper.DisBindVipOpinion)))
            {
                if (Convert.ToString((int)op) == opinion)
                {
                    opItem = op;
                    break;
                }
            }

            string result = clsWXHelper.FansBindStore(openid, Convert.ToInt32(storeid), opItem, Convert.ToInt32(cid));
            JObject jo = JObject.Parse(result);
            if (Convert.ToString(jo["errcode"]) == "0")
                res = ResponseModel.setRes(0, "ok", "");
            else
                res = ResponseModel.setRes(10008, Convert.ToString(jo["errmsg"]));
        }

        clsSharedHelper.WriteInfo(JsonConvert.SerializeObject(res));
    }

    //获取更换导购原因
    public void getDisOpinions()
    {
        JObject jo = new JObject();
        foreach (clsWXHelper.DisBindVipOpinion op in Enum.GetValues(typeof(clsWXHelper.DisBindVipOpinion)))
        {
            string key = Convert.ToString((int)op);
            if (key == "0" || key == "-1" || key == "7") continue;
            jo[key] = op.ToString();
        }

        res = ResponseModel.setRes(0, jo);
        clsSharedHelper.WriteInfo(JsonConvert.SerializeObject(res));
    }

    public string getParamValue(string key)
    {
        if (reqParams.ContainsKey(key))
        {
            string value = Convert.ToString(reqParams[key]);
            return value;
        }
        else
        {
            res = ResponseModel.setRes(10007, "Invalid params [" + key + "]!");
            clsSharedHelper.WriteInfo(JsonConvert.SerializeObject(res));
            return "";
        }
    }

    public bool IsReusable
    {
        get
        {
            return false;
        }
    }
}

public class ResponseModel
{
    private int _errcode;
    public int errcode
    {
        set { this._errcode = value; }
        get { return this._errcode; }
    }

    private object _data;
    public object data
    {
        set { this._data = value; }
        get { return this._data == null ? string.Empty : this._data; }
    }

    private string _errmsg = "";
    public string errmsg
    {
        set { this._errmsg = value; }
        get { return this._errmsg; }
    }

    public static ResponseModel setRes(int pcode, object pdata, string pmes)
    {
        ResponseModel res = new ResponseModel();
        res.errcode = pcode;
        res.data = pdata;
        res.errmsg = pmes;
        return res;
    }

    public static ResponseModel setRes(int pcode, object pdata)
    {
        return setRes(pcode, pdata, string.Empty);
    }

    public static ResponseModel setRes(int pcode, string pmes)
    {
        return setRes(pcode, string.Empty, pmes);
    }
}