<%@ WebHandler Language="C#" Class="StoreEvaluation" %>

using System;
using System.Web;
using nrWebClass;
using System.Collections.Generic;
using System.Data;
using System.Data.SqlClient;
using Newtonsoft.Json;
using System.Reflection;
using System.IO;

public class StoreEvaluation : IHttpHandler
{
    public ResponseModel res;
    private static string OAConnStr = clsConfig.GetConfigValue("OAConnStr");
    private static string WXDBConnStr = clsConfig.GetConfigValue("WXConnStr");
    private static string CXDBconnStr = clsConfig.GetConfigValue("FXDBConStr");
    public void ProcessRequest(HttpContext context)
    {
        context.Response.ContentType = "text/html;charset=utf-8";
        context.Response.ContentEncoding = System.Text.Encoding.UTF8;
        context.Request.ContentEncoding = System.Text.Encoding.UTF8;

        if (context.Request.HttpMethod.ToUpper().Equals("POST"))
        {
            Stream stream = HttpContext.Current.Request.InputStream;
            StreamReader streamReader = new StreamReader(stream);
            string data = streamReader.ReadToEnd();

            if (string.IsNullOrEmpty(data) == false)
            {
                RequestModel req = JsonConvert.DeserializeObject<RequestModel>(data);
                MethodInfo method = this.GetType().GetMethod(req.action);

                if (method != null)
                {
                    object[] methodAttrs = method.GetCustomAttributes(typeof(MethodPropertyAttribute), false);
                    if (methodAttrs.Length > 0)
                    {
                        MethodPropertyAttribute att = methodAttrs[0] as MethodPropertyAttribute;
                        if (att.WebMethod)
                        {
                            int code = 400;
                            if (att.CheckToken && checkSession(context, out code) == false)
                            {
                                res = ResponseModel.setRes(code, "访问超时！");
                            }
                            else
                            {
                                try
                                {
                                    method.Invoke(this, req.parameter);
                                    return;
                                }
                                catch (Exception ex)
                                {
                                    res = ResponseModel.setRes(400, "Server Error!" + ex.Message);
                                }
                            }
                        }
                        else
                            res = ResponseModel.setRes(400, "无效请求！！|" + req.action);
                    }
                }
                else
                    res = ResponseModel.setRes(400, "无效操作！");
            }
            else
                res = ResponseModel.setRes(400, "无有效参数！");
        }
        else
            res = ResponseModel.setRes(400, "请求方式不正确！");
        clsSharedHelper.WriteInfo(JsonConvert.SerializeObject(res));
    }

    //获取JS-API相关配置信息
    [MethodProperty(WebMethod = true)]
    public void getApiConfigInfos(string key, string url)
    {
        List<string> configs = clsWXHelper.GetJsApiConfig(key, url);
        if (configs.Count != 4)
            res = ResponseModel.setRes(400, "", "请求JS-API配置失败！");
        else
            res = ResponseModel.setRes(200, configs);
        clsSharedHelper.WriteInfo(JsonConvert.SerializeObject(res));
    }
    /// <summary>
    /// 评论信息提交
    /// </summary>
    /// <param name="jstr"></param>
    [MethodProperty(WebMethod = true)]
    public void evaluationSubmit(string jstr)
    {
        Dictionary<string, string> dic_evaluation;
        string AllPoint, ServicePoint, FacePoint, ProductPoint, Remark, djid, mdid;
        try
        {
            dic_evaluation = JsonConvert.DeserializeObject<Dictionary<string, string>>(jstr);
            AllPoint = dic_evaluation["AllPoint"];
            ServicePoint = dic_evaluation["ServicePoint"];
            FacePoint = dic_evaluation["FacePoint"];
            ProductPoint = dic_evaluation["ProductPoint"];
            Remark = dic_evaluation["Remark"];
            djid = dic_evaluation["djid"];
            mdid = dic_evaluation["mdid"];
        }
        catch (Exception e)
        {
            res = ResponseModel.setRes(400, "", "参数格式不合法：" + e.ToString());
            clsSharedHelper.WriteInfo(JsonConvert.SerializeObject(res));
            return;
        }
        DataTable dt = evaluationDT(mdid, djid);
        if (dt.Rows.Count > 0)
        {
            res = ResponseModel.setRes(400, "", "您已提交评价,请不要重复提交");
            clsSharedHelper.DisponseDataTable(ref dt);
            clsSharedHelper.WriteInfo(JsonConvert.SerializeObject(res));
            return;
        }

        string vipid = getVipid(djid,mdid);
        if (vipid == "0")
        {
            res = ResponseModel.setRes(400, "", "vip不存在");
            clsSharedHelper.WriteInfo(JsonConvert.SerializeObject(res));
            return;
        }
        string mysql = @"INSERT INTO wx_t_StoreEvaluation(djid,khid,mdid,CreateTime,wxid,wxOpenid,vipid,AllPoint,ServicePoint,FacePoint,ProductPoint,Remark,wxNick)
SELECT top 1 @djid,@khid,@mdid,GETDATE(),id,wxOpenid,vipid,@AllPoint,@ServicePoint,@FacePoint,@ProductPoint,@Remark,wxNick
FROM dbo.wx_t_vipBinging WHERE vipid=@vipid";
        List<SqlParameter> paras = new List<SqlParameter>();
        paras.Add(new SqlParameter("@djid", djid));
        paras.Add(new SqlParameter("@khid", getOrderKhid(djid)));
        paras.Add(new SqlParameter("@mdid", mdid));
        paras.Add(new SqlParameter("@AllPoint", AllPoint));
        paras.Add(new SqlParameter("@ServicePoint", ServicePoint));
        paras.Add(new SqlParameter("@FacePoint", FacePoint));
        paras.Add(new SqlParameter("@ProductPoint", ProductPoint));
        paras.Add(new SqlParameter("@Remark", Remark));
        paras.Add(new SqlParameter("@vipid", vipid));
        using (LiLanzDALForXLM dal = new LiLanzDALForXLM(WXDBConnStr))
        {
            string errInfo = dal.ExecuteNonQuerySecurity(mysql, paras);
            if (errInfo == "") res = ResponseModel.setRes(200, "成功提交", "");
            else res = ResponseModel.setRes(400, "", "出错了：" + errInfo);
        }
        clsSharedHelper.WriteInfo(JsonConvert.SerializeObject(res));
    }
    private string getVipid(string djid,string mdid)
    {
        object obj_vipid = null;
        using (LiLanzDALForXLM dal = new LiLanzDALForXLM(CXDBconnStr))
        {
            string mysql = "SELECT TOP 1 b.id FROM  dbo.zmd_v_lsdjmx a INNER JOIN dbo.YX_T_Vipkh b ON a.vip=b.kh where a.id=@djid and a.mdid=@mdid";
            List<SqlParameter> paras = new List<SqlParameter>();
            paras.Add(new SqlParameter("@djid", djid));
            paras.Add(new SqlParameter("@mdid", mdid));
            string errInfo = dal.ExecuteQueryFastSecurity(mysql, paras, out obj_vipid);
            if (errInfo != "" || obj_vipid == null)
            {
                obj_vipid = "0";
            }
            paras.Clear();
            return Convert.ToString(obj_vipid);
        }
    }

    /// <summary>
    /// 获取单据客户
    /// </summary>
    /// <param name="mdid"></param>
    /// <param name="djid"></param>
    /// <returns>存在返回true</returns>
    private string getOrderKhid(string djid)
    {
        object obj_khid = null;
        using (LiLanzDALForXLM dal = new LiLanzDALForXLM(CXDBconnStr))
        {
            string mysql = "SELECT TOP 1 a.khid FROM dbo.zmd_v_lsdjmx a where a.id=@djid";
            List<SqlParameter> paras = new List<SqlParameter>();
            paras.Add(new SqlParameter("@djid", djid));
            string errInfo = dal.ExecuteQueryFastSecurity(mysql, paras, out obj_khid);
            if (errInfo != "")
            {
                obj_khid = "0";
            }
            paras.Clear();
            return Convert.ToString(obj_khid);
        }
    }
    /// <summary>
    /// 初始化
    /// </summary>
    /// <param name="mdid"></param>
    /// <param name="djid"></param>
    [MethodProperty(WebMethod = true)]
    public void evaluationInit(string mdid, string djid)
    {
        if (checkOrder(mdid, djid) == false) clsSharedHelper.WriteInfo(JsonConvert.SerializeObject(ResponseModel.setRes(400, "", "单据不存在")));

        DataTable dt = evaluationDT(mdid, djid);
        if (dt == null)
        {
            clsSharedHelper.WriteInfo(JsonConvert.SerializeObject(ResponseModel.setRes(400, "", "网络不佳,请稍后再试")));
            return;
        }
        string mdmc = getMdmc(mdid);
        Dictionary<string, object> dic_rt = new Dictionary<string, object>();
        dic_rt.Add("mdmc", mdmc);
        dic_rt.Add("evaluation", dt);
        string rt = JsonConvert.SerializeObject(ResponseModel.setRes(200, dic_rt, ""));
        dic_rt.Clear();
        clsSharedHelper.WriteInfo(rt);
    }
    /// <summary>
    /// 获取门店名称
    /// </summary>
    /// <param name="mdid"></param>
    /// <returns></returns>
    private string getMdmc(string mdid)
    {
        object obj_mdmc;
        using (LiLanzDALForXLM dal = new LiLanzDALForXLM(OAConnStr))
        {
            string mysql = "SELECT TOP 1 mdmc FROM t_mdb  where mdid=@mdid ";
            List<SqlParameter> paras = new List<SqlParameter>();
            paras.Add(new SqlParameter("@mdid", mdid));
            string errInfo = dal.ExecuteQueryFastSecurity(mysql, paras, out obj_mdmc);
            if (errInfo != "")
            {
                obj_mdmc = null;
            }
            paras.Clear();
        }
        return Convert.ToString(obj_mdmc);
    }
    /// <summary>
    /// 检查单据是否存在
    /// </summary>
    /// <param name="mdid"></param>
    /// <param name="djid"></param>
    /// <returns>存在返回true</returns>
    private Boolean checkOrder(string mdid, string djid)
    {
        Boolean flag = false;
        using (LiLanzDALForXLM dal = new LiLanzDALForXLM(CXDBconnStr))
        {
            string mysql = "SELECT TOP 1 a.id FROM dbo.zmd_v_lsdjmx a where a.mdid=@mdid AND a.id=@djid";
            List<SqlParameter> paras = new List<SqlParameter>();
            paras.Add(new SqlParameter("@mdid", mdid));
            paras.Add(new SqlParameter("@djid", djid));
            DataTable dt;
            string errInfo = dal.ExecuteQuerySecurity(mysql, paras, out dt);
            if (errInfo == "" && dt.Rows.Count > 0)
            {
                flag = true;
            }
            paras.Clear();
            clsSharedHelper.DisponseDataTable(ref dt);
            return flag;
        }
    }
    /// <summary>
    /// 获取评论数据
    /// </summary>
    /// <param name="mdid">门店id</param>
    /// <param name="djid">单据id</param>
    /// <returns></returns>
    private DataTable evaluationDT(string mdid, string djid)
    {
        DataTable dt = null;
        using (LiLanzDALForXLM dal = new LiLanzDALForXLM(WXDBConnStr))
        {
            string mysql = "SELECT AllPoint,ServicePoint,FacePoint,ProductPoint,Remark,CreateTime FROM  dbo.wx_t_StoreEvaluation WHERE djid=@djid AND mdid=@mdid";
            List<SqlParameter> paras = new List<SqlParameter>();
            paras.Add(new SqlParameter("@mdid", mdid));
            paras.Add(new SqlParameter("@djid", djid));
            string errInfo = dal.ExecuteQuerySecurity(mysql, paras, out dt);
            if (errInfo != "") dt = null;
            paras.Clear();
        }
        return dt;
    }
    /// <summary>
    /// 判断session是否存在
    /// </summary>
    /// <param name="context"></param>
    /// <param name="code">输出错误码，提供上级调用判断错误类型</param>
    /// <returns></returns>
    public Boolean checkSession(HttpContext context, out int code)
    {
        if (string.IsNullOrEmpty(Convert.ToString(context.Session["openid"])))
        {
            code = 400;
            return false;
        }
        else
        {
            code = 0;
            return true;
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
//请求的格式
public class RequestModel
{
    private string _action;
    public string action
    {
        get { return this._action; }
        set { this._action = value; }
    }

    private string _token;
    public string token
    {
        get { return this._token; }
        set { this._token = value; }
    }

    private Object[] _parameter;
    public Object[] parameter
    {
        get { return this._parameter; }
        set { this._parameter = value; }
    }
}
//返回格式
public class ResponseModel
{
    private int _code;
    public int code
    {
        set { this._code = value; }
        get { return this._code; }
    }

    private object _data;
    public object data
    {
        set { this._data = value; }
        get { return this._data == null ? string.Empty : this._data; }
    }

    private string _message = "";
    public string message
    {
        set { this._message = value; }
        get { return this._message; }
    }

    public static ResponseModel setRes(int pcode, object pdata, string pmes)
    {
        ResponseModel res = new ResponseModel();
        res.code = pcode;
        res.data = pdata;
        res.message = pmes;
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
[AttributeUsage(AttributeTargets.Method)]
public class MethodPropertyAttribute : Attribute
{
    private bool checkToken = false;
    private bool webMethod = false;

    public bool CheckToken
    {
        get { return this.checkToken; }
        set { this.checkToken = value; }
    }

    public bool WebMethod
    {
        get { return this.webMethod; }
        set { this.webMethod = value; }
    }

}