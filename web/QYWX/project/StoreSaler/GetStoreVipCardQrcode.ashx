<%@ WebHandler Language="C#" Class="GetStoreVipCardQrcode" %>
using System;
using System.Web;
using nrWebClass;
using System.Data;
using System.Data.SqlClient;
using System.Collections.Generic;
using Newtonsoft.Json;

public class GetStoreVipCardQrcode : IHttpHandler, System.Web.SessionState.IRequiresSessionState
{
    public void ProcessRequest(HttpContext context)
    {
        //context.Response.ClearHeaders();
        //context.Response.AppendHeader("Access-Control-Allow-Origin", "*");
        //string requestHeaders = context.Request.Headers["Access-Control-Request-Headers"];
        //context.Response.AppendHeader("Access-Control-Allow-Headers", string.IsNullOrEmpty(requestHeaders) ? "*" : requestHeaders);
        //context.Response.AppendHeader("Access-Control-Allow-Methods", "POST, GET,OPTIONS");

        context.Response.ContentType = "text/plain";
        string ctrl = Convert.ToString(context.Request.Params["ctrl"]);
        string rt = "";
        DataSerach ds = new DataSerach();
        if (string.IsNullOrEmpty(ctrl)) ctrl = "";
        ctrl = ctrl.ToLower();
        switch (ctrl)
        {
            case "get":
                rt = ds.getQrCode();
                break;
            default:
                rt = JsonConvert.SerializeObject(new Response("无效请求"));
                break;
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
#region 逻辑处理类
public class DataSerach
{
    private const string ZppCard_id = "parMEt9NOhvN5OGsOMtORmsfseyg";   //主品牌卡包会员ID
    //private const string QswCard_id = "";
    private const string CreateQrCodeApi = "https://api.weixin.qq.com/card/qrcode/create?access_token={0}";

    public string getQrCode()
    {
        string rt = @"{{ ""errcode"":""{0}"",""errmsg"":""{1}"",""imgurl"":""{2}"",""storename"":""{3}"" }}";

        //获取传入的门店ID
        HttpContext hc = HttpContext.Current;
        if (hc == null)
        { 
            return string.Format(rt,500,"没有登录!", "" , "");
        }
        string StoreID = hc.Request.Params["storeid"];

        //判断是轻商务的店铺还是主品牌——暂时只发行一种卡,所以不用判断
        string strInfo = "";
        object objKhmc = "";
        using(LiLanzDALForXLM dal = new LiLanzDALForXLM(clsConfig.GetConfigValue("OAConnStr")))
        {
            List<SqlParameter> lst = new List<SqlParameter>();
            lst.Add(new SqlParameter("@khid", StoreID));
            strInfo = dal.ExecuteQueryFastSecurity("SELECT TOP 1 khmc FROM yx_t_khb WHERE khid=@khid",lst, out objKhmc);
            if (!string.IsNullOrEmpty(strInfo) || Convert.ToString(objKhmc) == "")
            {
                clsLocalLoger.WriteError("获取客户门店名称失败！strInfo=" + strInfo); 
                return string.Format(rt,500,"获取门店名称失败!" + strInfo, "" , objKhmc);
            }
        }


        //查询本地是否有这个mdid对应的二维码图片，如果有，直接将路径返回；
        string strdir = hc.Server.MapPath("temp/vipcard");
        string localimg = string.Concat(strdir ,"\\", StoreID, "_", ZppCard_id, ".jpg");
        string siteimg = string.Concat(clsConfig.GetConfigValue("OA_WebPath") ,"project/StoreSaler/temp/vipcard/", StoreID, "_", ZppCard_id, ".jpg");

        if (System.IO.File.Exists(localimg))
        {
            return string.Format(rt,0,"", siteimg , objKhmc);
        }

        if (!System.IO.Directory.Exists(strdir)){
            System.IO.Directory.CreateDirectory(strdir);
        }
        //如果本地没有这个图片，则调用微信的接口生成它，并且将它下载下来；
        string postData = @"{{""action_name"": ""QR_CARD"",
            ""action_info"": {{
                    ""card"": {{
                        ""card_id"": ""{0}"",
                        ""is_unique_code"": false ,
                        ""outer_id"":""{1}"",
                        ""outer_str"":""{1},{2}""
                              }}
                             }}
                            }}";
        string apiurl = string.Format(CreateQrCodeApi, clsWXHelper.GetAT("5"));
        string imgurl = "";
        using (clsJsonHelper jh = clsNetExecute.HttpRequestToWX(apiurl, string.Format(postData, ZppCard_id, StoreID,objKhmc)))
        {
            if (jh.GetJsonValue("errcode") == "0")
            {
                imgurl = jh.GetJsonValue("show_qrcode_url");
                imgurl = imgurl.Replace("\\/", "/");
            }else
            {                    
                return string.Format(rt,500,"图片生成失败" + jh.GetJsonValue("errmsg"), "" , objKhmc);
            }
        }

        strInfo = DownloadFile(imgurl, localimg);
        if (strInfo == "")
        { 
           return string.Format(rt,0,"", siteimg , objKhmc);
        }
        else
        {
            clsLocalLoger.WriteError("【下载卡包会员二维码图片失败】错误：" + strInfo); 
            return string.Format(rt,0,"图片下载失败", imgurl , objKhmc);
        }
    }


    /// <summary>
    /// 下载图片
    /// </summary>
    /// <param name="URL">目标URL</param>
    /// <param name="filename">本地的路径</param>
    /// <returns></returns>
    public string DownloadFile(string URL, string filename)
    {
        try
        {
            System.Net.HttpWebRequest Myrq = (System.Net.HttpWebRequest)System.Net.HttpWebRequest.Create(URL);
            using (System.Net.HttpWebResponse myrp = (System.Net.HttpWebResponse)Myrq.GetResponse())
            {
                long totalBytes = myrp.ContentLength;
                using (System.IO.Stream st = myrp.GetResponseStream())
                {
                    using (System.IO.Stream so = new System.IO.FileStream(filename, System.IO.FileMode.Create))
                    {
                        long totalDownloadedByte = 0;
                        byte[] by = new byte[1024];
                        int osize = st.Read(by, 0, (int)by.Length);
                        while (osize > 0)
                        {
                            totalDownloadedByte = osize + totalDownloadedByte;
                            so.Write(by, 0, osize);
                            osize = st.Read(by, 0, (int)by.Length);
                        }
                        so.Close();
                        st.Close();

                        so.Dispose();
                        st.Dispose();
                        myrp.Close();
                    }
                }
            }

            return "";
        }
        catch (Exception ex)
        {
            return string.Concat(clsSharedHelper.Error_Output, ex.Message);
        }
    }


}
#endregion

#region 基础类
public class Response
{
    public Response() { }
    public Response(object obj)
    {
        _code = "200";
        _info = obj;
    }
    public Response(string errmsg)
    {
        this._code = "201";
        this._msg = errmsg;
    }
    string _code;
    public string code
    {
        get
        {
            if (string.IsNullOrEmpty(_code)) _code = "201";
            return _code;
        }
        set
        {
            _code = value;
        }
    }
    object _info;
    public object info
    {
        get { return _info == null ? "" : _info; }
        set { _info = value; }
    }
    string _msg;
    public string msg
    {
        get
        {
            if (string.IsNullOrEmpty(_msg)) _msg = "";
            return _msg;
        }
        set
        {
            _msg = value;
        }
    }
}
#endregion
