<%@ WebHandler Language="C#" Class="StoreEvaluationAnalysis" %>

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

public class StoreEvaluationAnalysis : IHttpHandler, IReadOnlySessionState
{
    public ResponseModel res;
    private static string OAConnStr = clsConfig.GetConfigValue("OAConnStr");
    private static string WXDBConnStr = clsConfig.GetConfigValue("WXConnStr");
    private static string CXDBconnStr = clsConfig.GetConfigValue("FXDBConStr");
    string khid = "0";
    public void ProcessRequest(HttpContext context)
    {
        OAConnStr = "server=192.168.35.10;database=tlsoft;uid=ABEASD14AD;pwd=+AuDkDew";
        WXDBConnStr = "server=192.168.35.62;database=weChatPromotion;uid=sa;pwd=ll=8727";
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
    /// <summary>
    /// 评论明细列表
    /// </summary>
    /// <param name="per_page">每一页记录数</param>
    /// <param name="page">第几页</param>
    ///<param name="searchRange">查询条件“all” 查询全部</param>
    [MethodProperty(WebMethod = true, CheckToken = true)]
    public void storeDetail(string khid, string per_page, string page, string searchRange)
    {
        int limit, offset;
        DataTable dt_total = null;
        if (int.TryParse(per_page, out limit) == false)
        {
            limit = 10;
        }
        if (int.TryParse(page, out offset) == false)
        {
            offset = 0;
        }


        string offstr = "";
        if (searchRange != "all")
        {
            offstr = " and (a.allpoint+a.ServicePoint+a.FacePoint+a.ProductPoint)<20";
        }

        Dictionary<string, object> drt = new Dictionary<string, object>();
        if (offset == 0)//第一页给汇总信息，第二页开始不给这一部分数据
        {

            dt_total = totalView(khid);
            drt.Add("totalView", dt_total);
            //bool flag = Convert.ToInt32(dt_total.Rows[0]["djs"]) > (limit * (offset + 1)) ? true : false;
            //drt.Add("nextpage", flag);

        }

        string errInfo, mysql, rt;

        using (LiLanzDALForXLM dal = new LiLanzDALForXLM(WXDBConnStr))
        {
            DataTable dt = null;
            mysql = string.Format(@"SELECT * FROM (
                        SELECT a.id, a.allpoint,a.ServicePoint,a.FacePoint,a.ProductPoint,a.Remark,ROW_NUMBER()OVER (ORDER BY a.id DESC) AS xh,a.CreateTime,a.wxNick AS wxName
                        FROM  wx_t_StoreEvaluation a 
                        WHERE DATEDIFF(MONTH,CreateTime,GETDATE())<13 and a.khid=@khid {0}
                        ) t  ORDER BY xh ", offstr);
            List<SqlParameter> paras = new List<SqlParameter>();
            paras.Add(new SqlParameter("@khid", khid));
            errInfo = dal.ExecuteQuerySecurity(mysql, paras, out dt);
            if (errInfo == "")
            {
                bool nextPage = false;
                if (dt.Rows.Count > (limit * (offset + 1))) nextPage = true;
                drt.Add("nextpage", nextPage);
                DataRow[] dr = dt.Select(string.Format("xh>{0} and xh<{1}", offset * limit, limit * (offset + 1) + 1));
                DataTable mydt = ToDataTable(dr);
                if (mydt == null)
                {
                    drt.Add("detail", new string[0]);
                }
                else
                {
                    drt.Add("detail", mydt);
                }

                res = ResponseModel.setRes(200, drt, "");
                rt = JsonConvert.SerializeObject(res);
                clsSharedHelper.DisponseDataTable(ref mydt);
            }
            else
            {
                res = ResponseModel.setRes(400, "", errInfo);
                rt = rt = JsonConvert.SerializeObject(res);
            }

            clsSharedHelper.DisponseDataTable(ref dt);
            clsSharedHelper.DisponseDataTable(ref dt_total);
            // clsSharedHelper.WriteInfo(JsonConvert.SerializeObject(res));
        }
        clsSharedHelper.WriteInfo(rt);
    }
    private DataTable totalView(string khid)
    {
        DataTable dt = null;
        using (LiLanzDALForXLM dal = new LiLanzDALForXLM(WXDBConnStr))
        {
            string mysql = @"SELECT a.khid,b.khdm, b.khmc,CAST(AVG(CAST(a.allpoint  AS DECIMAL(10,1))) AS DECIMAL(5,1)) AS avgAllPoint,COUNT(1) AS djs,
                                    CAST(AVG(CAST(a.ServicePoint  AS DECIMAL(10,1))) AS DECIMAL(5,1)) AS avgServicePoint,
                                    CAST(AVG(CAST(a.FacePoint  AS DECIMAL(10,1))) AS DECIMAL(5,1)) AS avgFacePoint,
                                    CAST(AVG(CAST(a.ProductPoint  AS DECIMAL(10,1))) AS DECIMAL(5,1)) AS avgProductPoint
                                    FROM  wx_t_StoreEvaluation a INNER JOIN yx_T_khb b ON a.khid=b.khid
                                    where DATEDIFF(MONTH,CreateTime,GETDATE())<13 AND b.khid=@khid 
                                    GROUP BY a.khid,b.khmc,b.khdm";
            List<SqlParameter> paras = new List<SqlParameter>();
            paras.Add(new SqlParameter("@khid", khid));
            string errInfo = dal.ExecuteQuerySecurity(mysql, paras, out dt);
            if (errInfo != "") return null;
        }
        return dt;
    }

    /// <summary>
    /// 评论图表分析
    /// </summary>
    /// <param name="khid"></param>
    [MethodProperty(WebMethod = true, CheckToken = true)]
    public void evaluationlCahrt(string khid)
    {
        Dictionary<string, object> drt = new Dictionary<string, object>();
        DataTable dt_total = totalView(khid);
        drt.Add("totalView", dt_total);
        string errInfo, mysql, rt;
        using (LiLanzDALForXLM dal = new LiLanzDALForXLM(WXDBConnStr))
        {
            DataTable dt = null;
            mysql = @"SELECT a.id,a.Allpoint,a.ServicePoint,FacePoint,ProductPoint
                      FROM  wx_t_StoreEvaluation a 
                      WHERE a.khid=@khid AND DATEDIFF(MONTH,CreateTime,GETDATE())<13";
            List<SqlParameter> paras = new List<SqlParameter>();
            paras.Add(new SqlParameter("@khid", khid));
            errInfo = dal.ExecuteQuerySecurity(mysql, paras, out dt);
            if (errInfo != "")
            {
                res = ResponseModel.setRes(400, "", errInfo);
            }
            else if (dt.Rows.Count == 0)
            {
                res = ResponseModel.setRes(400, "", "无有效数据");
            }
            else
            {
                string[] columns = { "allpoint", "ServicePoint", "FacePoint", "ProductPoint" };
                foreach (string str in columns)
                {
                    Dictionary<string, string> dcolumn = new Dictionary<string, string>();
                    for (int i = 1; i <= 5; i++)
                    {
                        dcolumn.Add(i.ToString(), countVal(dt, str, i));
                    }
                    drt.Add(str, dcolumn);
                }
            }
            res = ResponseModel.setRes(200, drt, "");
            clsSharedHelper.DisponseDataTable(ref dt);
        }
        rt = JsonConvert.SerializeObject(res);
        clsSharedHelper.DisponseDataTable(ref dt_total);
        clsSharedHelper.WriteInfo(rt);
    }
    private string countVal(DataTable dt, string column, int val)
    {
        DataRow[] dr = dt.Select(string.Format("{0}={1}", column, val));
        double Percentage = Convert.ToDouble(dr.Length) / Convert.ToDouble(dt.Rows.Count);
        return Percentage.ToString("0.0%");
    }
    /// <summary>
    /// 门店排名
    /// </summary>
    /// <param name="pre_page">每页数据量</param>
    /// <param name="page">第几页</param>
    [MethodProperty(WebMethod = true, CheckToken = true)]
    public void storeRanking(string per_page, string page)
    {
        int limit, offset;
        if (int.TryParse(per_page, out limit) == false)
        {
            limit = 10;
        }
        if (int.TryParse(page, out offset) == false)
        {
            offset = 0;
        }

        string errInfo, mysql;
        using (LiLanzDALForXLM dal = new LiLanzDALForXLM(WXDBConnStr))
        {
            DataTable dt = null;
            string rolename = Convert.ToString(HttpContext.Current.Session["RoleName"]);
            mysql = @"SELECT ROW_NUMBER() OVER(ORDER BY avgAllPoint desc,avgServicePoint+avgFacePoint+avgProductPoint desc ,djs DESC,khid asc) AS xh,*
                                    FROM (
                                    SELECT a.khid,b.khdm, b.khmc,CAST(AVG(CAST(a.allpoint  AS DECIMAL(10,1))) AS DECIMAL(5,1)) AS avgAllPoint,COUNT(1) AS djs,
                                    CAST(AVG(CAST(a.ServicePoint  AS DECIMAL(10,1))) AS DECIMAL(5,1)) AS avgServicePoint,
                                    CAST(AVG(CAST(a.FacePoint  AS DECIMAL(10,1))) AS DECIMAL(5,1)) AS avgFacePoint,
                                    CAST(AVG(CAST(a.ProductPoint  AS DECIMAL(10,1))) AS DECIMAL(5,1)) AS avgProductPoint
                                    FROM  wx_t_StoreEvaluation a INNER JOIN yx_T_khb b ON a.khid=b.khid
                                    where DATEDIFF(MONTH,CreateTime,GETDATE())<13
                                    GROUP BY a.khid,b.khmc,b.khdm) t";

            errInfo = dal.ExecuteQuery(mysql, out dt);
            //  clsSharedHelper.WriteInfo(mysql);
            if (errInfo == "")
            {
                bool nextPage = false;
                if (dt.Rows.Count > (limit * (offset + 1))) nextPage = true;
                DataRow[] dr = dt.Select(string.Format("xh>{0} and xh<{1}", offset * limit, limit * (offset + 1) + 1));
                Dictionary<string, object> drt = new Dictionary<string, object>();
                DataTable mydt = ToDataTable(dr);
                string rt = "";
                if (mydt != null)
                {
                    mydt.Columns.Remove("xh");
                    drt.Add("rows", mydt);
                    drt.Add("nextpage", nextPage);
                    drt.Add("currentStore",getCurrentData(dt,Convert.ToString( HttpContext.Current.Session["tzid"])));
                    //查找当前用户所在门店的排名

                    rt = JsonConvert.SerializeObject(ResponseModel.setRes(200, drt, ""));
                }
                else
                {
                    rt = JsonConvert.SerializeObject(ResponseModel.setRes(200, new string[0] { }, "无更多数据了"));
                }

                clsSharedHelper.DisponseDataTable(ref dt);
                clsSharedHelper.DisponseDataTable(ref mydt);
                clsSharedHelper.WriteInfo(rt);
            }
            else
            {
                res = ResponseModel.setRes(400, "", errInfo);
            }
            clsSharedHelper.WriteInfo(JsonConvert.SerializeObject(res));
        }
    }
    private DataTable ToDataTable(DataRow[] rows)
    {
        if (rows == null || rows.Length == 0) return null;
        DataTable tmp = rows[0].Table.Clone(); // 复制DataRow的表结构
        foreach (DataRow row in rows)
        {
            tmp.ImportRow(row); // 将DataRow添加到DataTable中
        }
        return tmp;
    }
    private Dictionary<string, object> getCurrentData(DataTable dt,string khid)
    {
        Dictionary<string, object> dCurrent = new Dictionary<string, object>();
        foreach (DataRow dr in dt.Rows)
        {
            if (Convert.ToString(dr["khid"]) == Convert.ToString(HttpContext.Current.Session["tzid"]))
            {

                dCurrent.Add("avgAllPoint",Convert.ToString(dr["avgAllPoint"]));
                dCurrent.Add("avgServicePoint",Convert.ToString(dr["avgServicePoint"]));
                dCurrent.Add("avgFacePoint",Convert.ToString(dr["avgFacePoint"]));
                dCurrent.Add("avgProductPoint",Convert.ToString(dr["avgProductPoint"]));
                dCurrent.Add("djs",Convert.ToUInt32(dr["djs"]));
                dCurrent.Add("khdm",Convert.ToString(dr["khdm"]));
                dCurrent.Add("khid",Convert.ToUInt32(dr["khid"]));
                dCurrent.Add("khmc", Convert.ToString(dr["khmc"]));
                dCurrent.Add("xh", Convert.ToUInt32(dr["xh"]));
                break;
            }
        }
        return dCurrent;
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