<%@ WebHandler Language="C#" Class="MettingCore" %>

using System;
using System.Web;
using nrWebClass;
using System.Collections.Generic;
using System.Data;
using System.Data.SqlClient;
using Newtonsoft.Json;
using System.Reflection;
using System.IO;
using System.Web.SessionState;

public class MettingCore : IHttpHandler, IReadOnlySessionState
{
    public ResponseModel res;
    private static string WXDBConnStr = null;
    static object iblock;
    public void ProcessRequest(HttpContext context)
    {
        if (string.IsNullOrEmpty(WXDBConnStr)) WXDBConnStr = clsConfig.GetConfigValue("WXConnStr");
        context.Response.ContentType = "text/html;charset=utf-8";
        context.Response.ContentEncoding = System.Text.Encoding.UTF8;
        context.Request.ContentEncoding = System.Text.Encoding.UTF8;
        if (iblock == null) iblock = new object();

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
    //初始化会议获取会议信息
    [MethodProperty(WebMethod = true, CheckToken = true)]
    public void initMetting(string ibeaconKey)
    {

        string mysql, errInfo, rt;
        if (string.IsNullOrEmpty(ibeaconKey))
        {
            res= ResponseModel.setRes(400, "", "非法访问");
            rt = JsonConvert.SerializeObject(res);
            clsSharedHelper.WriteInfo(rt);
        }
        DataTable dt;
        using (LiLanzDALForXLM dal = new LiLanzDALForXLM(WXDBConnStr))
        {
            mysql = @"select  a.id as MeetingID, a.Title,a.MainUser,CONVERT(VARCHAR(100),a.StartTime,120) AS  StartTime, a.MeetingHours,a.Remark,a.Address,MainUserJobs,a.AvgScore,a.AvgScore1,a.AvgScore2,convert(varchar(100), ISNULL(b.CreateTime,''),120) CreateTime,ISNULL(b.CName,'') cname,ISNULL(b.Score,0) score ,ISNULL(b.Score1,0) score1,ISNULL(b.Score2,0) score2,ISNULL(b.Remark,'') AS ERemark,CASE WHEN ISNULL(c.avatar,'')='' THEN 'http://tm.lilanz.com/QYWX/res/img/lilanzlogo1.jpg' ELSE c.avatar END AS headImg
            from wx_t_Meeting a LEFT JOIN wx_t_MeetingEvaluation b ON a.id=b.MeetingID AND b.CustomerID=@customerid LEFT JOIN dbo.wx_t_customers c ON a.MainUserID=c.ID
            where  ibeaconKey=@ibeaconKey";

            List<SqlParameter> paras = new List<SqlParameter>();
            paras.Add(new SqlParameter("@customerid", HttpContext.Current.Session["qy_customersid"]));
            paras.Add(new SqlParameter("@ibeaconKey", ibeaconKey));

            errInfo = dal.ExecuteQuerySecurity(mysql, paras, out dt);
            if (errInfo != "")
            {
                res = ResponseModel.setRes(400, "", errInfo);
            }
            else if (dt.Rows.Count >= 1)
            {
                res = ResponseModel.setRes(200, dt, "");
            }
            else
            {
                res = ResponseModel.setRes(402, "", "未找到有效会议信息");
            }
            rt = JsonConvert.SerializeObject(res);
        }
        clsSharedHelper.DisponseDataTable(ref dt);
        clsSharedHelper.WriteInfo(rt);
    }
    [MethodProperty(WebMethod = true, CheckToken = true)]
    public void putInEval(string jsonstr)
    {

        Dictionary<string, string> dEval = JsonConvert.DeserializeObject<Dictionary<string, string>>(jsonstr);
        using (LiLanzDALForXLM dal = new LiLanzDALForXLM(WXDBConnStr))
        {
            DataTable dt;
            string mysql = "SELECT id FROM wx_t_MeetingEvaluation WHERE MeetingID=@MeetingID AND CustomerID=@CustomerID";
            List<SqlParameter> paras = new List<SqlParameter>();
            paras.Add(new SqlParameter("@MeetingID", dEval["MeetingID"]));
            paras.Add(new SqlParameter("@CustomerID", HttpContext.Current.Session["qy_customersid"]));
            string errInfo = dal.ExecuteQuerySecurity(mysql, paras, out dt);
            if (dt.Rows.Count > 0) res = ResponseModel.setRes(400, "", "您已经提交了评论,不能重复提交");
            else
            {
                mysql = @"INSERT INTO wx_t_MeetingEvaluation(CreateTime,MeetingID,CustomerID,CName,Score,Score1,Score2,Remark)
VALUES(GETDATE(),@MeetingID,@CustomerID,@CName,@Score,@Score1,@Score2,@Remark)";
                paras.Clear();
                paras.Add(new SqlParameter("@MeetingID", dEval["MeetingID"]));
                paras.Add(new SqlParameter("@CustomerID", HttpContext.Current.Session["qy_customersid"]));
                paras.Add(new SqlParameter("@CName", HttpContext.Current.Session["qy_cname"]));
                paras.Add(new SqlParameter("@Score", dEval["Score"]));
                paras.Add(new SqlParameter("@Score1", dEval["Score1"]));
                paras.Add(new SqlParameter("@Score2", dEval["Score2"]));
                paras.Add(new SqlParameter("@Remark", dEval["Remark"]));
                errInfo = dal.ExecuteNonQuerySecurity(mysql, paras);
                if (errInfo == "") { res = ResponseModel.setRes(200, "提交成功", ""); avgScore(dEval["MeetingID"]); }
                else res = ResponseModel.setRes(400, "", errInfo);
            }
            clsSharedHelper.DisponseDataTable(ref dt);

        }
        clsSharedHelper.WriteInfo(JsonConvert.SerializeObject(res));
    }

    private void avgScore(string meetingID)
    {
        using (LiLanzDALForXLM dal = new LiLanzDALForXLM(WXDBConnStr))
        {
            string mysql = @"UPDATE a SET a.AvgScore=(a.AvgScore*a.EvaluationCount+b.Score)/(a.EvaluationCount+1),a.AvgScore1=(a.AvgScore1*a.EvaluationCount+b.Score1)/(a.EvaluationCount+1),a.AvgScore2=(a.AvgScore2*a.EvaluationCount+b.Score2)/(a.EvaluationCount+1),EvaluationCount=EvaluationCount+1 FROM dbo.wx_t_Meeting a INNER JOIN wx_t_MeetingEvaluation b ON a.id=b.MeetingID AND b.CustomerID=@CustomerID and a.id=@MeetingID";
            List<SqlParameter> paras = new List<SqlParameter>();
            paras.Add(new SqlParameter("@MeetingID", meetingID));
            paras.Add(new SqlParameter("@CustomerID", HttpContext.Current.Session["qy_customersid"]));
            dal.ExecuteNonQuerySecurity(mysql, paras);
        }
    }
    /// <summary>
    /// 判断session是否存在
    /// </summary>
    /// <param name="context"></param>
    /// <param name="code">输出错误码，提供上级调用判断错误类型</param>
    /// <returns></returns>
    public Boolean checkSession(HttpContext context, out int code)
    {
        if (string.IsNullOrEmpty(Convert.ToString(context.Session["qy_customersid"])))
        {
            code = 401;
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