<%@ WebHandler Language="C#" Class="ApplyCheckCore" %>

using System;
using System.Web;
using nrWebClass;
using System.Collections.Generic;
using System.Data;
using System.Data.SqlClient;
using Newtonsoft.Json.Linq;
using Newtonsoft.Json;
using System.Reflection;
using System.Collections.Specialized;
using System.IO;

public class ApplyCheckCore : IHttpHandler
{
    private static string ZBDBConnStr = "server='192.168.35.10';uid=ABEASD14AD;pwd=+AuDkDew;database=tlsoft";
    private static string WXDBConnStr = "server='192.168.35.62';uid=sa;pwd=ll=8727;database=weChatPromotion";
    private static string att2000ConnStr = "server='192.168.35.30';uid=lllogin;pwd=rw1894tla;database=att2000";
    public ResponseModel res;
    public int uid=0, roleid=0;
    public void ProcessRequest(HttpContext context)
    {
        context.Response.ClearHeaders();
        context.Response.AppendHeader("Access-Control-Allow-Origin", "*");
        string requestHeaders = context.Request.Headers["Access-Control-Request-Headers"];
        context.Response.AppendHeader("Access-Control-Allow-Headers", string.IsNullOrEmpty(requestHeaders) ? "*" : requestHeaders);
        context.Response.AppendHeader("Access-Control-Allow-Methods", "POST, GET");

        context.Response.ContentType = "text/html;charset=utf-8";
        context.Response.ContentEncoding = System.Text.Encoding.UTF8;
        context.Request.ContentEncoding = System.Text.Encoding.UTF8;

        if ("POST" == context.Request.HttpMethod.ToUpper())
        {
            Stream stream = HttpContext.Current.Request.InputStream;
            StreamReader streamReader = new StreamReader(stream);
            string data = streamReader.ReadToEnd();
            if (string.IsNullOrEmpty(data))
                res = ResponseModel.setRes(400, "无有效参数！");
            else
            {
                RequestModel req = JsonConvert.DeserializeObject<RequestModel>(data);
                MethodInfo method = this.GetType().GetMethod(req.action);

                if (method == null)
                    res = ResponseModel.setRes(400, "无效操作！");
                else
                {
                    object[] methodAttrs = method.GetCustomAttributes(typeof(MethodPropertyAttribute), false);
                    bool isCheckPass = true;

                    if (methodAttrs.Length > 0)
                    {
                        MethodPropertyAttribute att = methodAttrs[0] as MethodPropertyAttribute;
                        if (att.WebMethod)
                        {
                            if (att.CheckToken && checkAppToken(req.token) <= 0)
                                isCheckPass = false;

                            if (isCheckPass)
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
                            else
                                res = ResponseModel.setRes(400, "无效TOKEN！");
                        }
                        else
                            res = ResponseModel.setRes(400, "无效请求！！|" + req.action);
                    }
                    else
                        res = ResponseModel.setRes(400, "无效请求！|" + req.action);
                }
            }
        }
        else
            res = ResponseModel.setRes(400, "请求方式不正确！" + context.Request.HttpMethod.ToUpper());
        clsSharedHelper.WriteInfo(JsonConvert.SerializeObject(res));
    }

    //保存菜单选择  必须要有CheckToken 否则无法获取userid
    [MethodProperty(WebMethod = true, CheckToken = true)]
    public void saveMenuSelect(string moduleid)
    {
        string userid = uid.ToString();
        string errInfo, mysql;
        DataTable dt;
        using (LiLanzDALForXLM dal=new LiLanzDALForXLM(WXDBConnStr))
        {
            List<SqlParameter> paras = new List<SqlParameter>();
            //先查询menuid,顺便判断modulid是否合法,但未判断是否有权限才去保存
            mysql = @"SELECT a.id,ISNULL(b.userid,0) AS userid FROM  wx_T_mental_menu a LEFT JOIN wx_T_mental_select b ON a.id=b.menuid AND b.userid=@userid
                      WHERE a.isactive=1 AND a.moduleid=@moduleid";
            paras.Add(new SqlParameter("@userid",userid));
            paras.Add(new SqlParameter("@moduleid",moduleid));
            errInfo = dal.ExecuteQuerySecurity(mysql, paras, out dt);
            if(errInfo !="") clsSharedHelper.WriteInfo(JsonConvert.SerializeObject(ResponseModel.setRes(400,errInfo)));
            if (dt.Rows.Count < 1) clsSharedHelper.WriteInfo(JsonConvert.SerializeObject(ResponseModel.setRes(400,"未找到菜单,请先维护菜单")));
            if(Convert.ToInt32(dt.Rows[0]["userid"])>0)  clsSharedHelper.WriteInfo(JsonConvert.SerializeObject(ResponseModel.setRes(400,"菜单用户已选择，不需要重新选择")));
            string id = Convert.ToString(dt.Rows[0]["id"]);
            clsSharedHelper.DisponseDataTable(ref dt);

            mysql = "INSERT INTO wx_T_mental_select(menuid,moduleid,userid,createdate) VALUES(@menuid,@moduleid,@userid,GETDATE())";
            paras.Clear();
            paras.Add(new SqlParameter("@menuid",id));
            paras.Add(new SqlParameter("@moduleid",moduleid));
            paras.Add(new SqlParameter("@userid", userid));
            errInfo = dal.ExecuteNonQuerySecurity(mysql, paras);
            if (errInfo != "") clsSharedHelper.WriteInfo(JsonConvert.SerializeObject(ResponseModel.setRes(400, errInfo)));
            else clsSharedHelper.WriteInfo(JsonConvert.SerializeObject(ResponseModel.setRes(200, "保存成功", "")));
        }
    }
    //删除选中菜单  必须要有CheckToken 否则无法获取userid
    [MethodProperty(WebMethod = true, CheckToken = true)]
    public void removeMenuSelect(string moduleid)
    {
        string errInfo, mysql;
        string userid = uid.ToString();
        using (LiLanzDALForXLM dal = new LiLanzDALForXLM(WXDBConnStr))
        {
            mysql = "DELETE wx_T_mental_select WHERE moduleid=@moduleid AND userid=@userid";
            List<SqlParameter> paras = new List<SqlParameter>();
            paras.Add(new SqlParameter("@userid",userid));
            paras.Add(new SqlParameter("@moduleid", moduleid));
            errInfo = dal.ExecuteNonQuerySecurity(mysql, paras);
            if (errInfo != "") clsSharedHelper.WriteInfo(JsonConvert.SerializeObject(ResponseModel.setRes(400, errInfo)));
            else clsSharedHelper.WriteInfo(JsonConvert.SerializeObject(ResponseModel.setRes(200, "移除成功", "")));
        }
    }

    //查询菜单权限 必须要有CheckToken 否则无法获取userid
    [MethodProperty(WebMethod = true, CheckToken = true)]
    public void getMenuAuth()
    {
       
        string userid = uid.ToString();
        string errInfo, mysql,rt="";
        DataTable dt; 
        using (LiLanzDALForXLM dal = new LiLanzDALForXLM(WXDBConnStr))
        {
            //查询已有权限菜单，isselect用户选中菜单,如果wx_T_mental_select数据多时速度变慢，可把用户选中的表分开查
            mysql = @"SELECT t.name,t.moduleid,CASE WHEN ISNULL(s.id,0)>0 THEN 1 else 0 END AS isselect,ROW_NUMBER()OVER( ORDER BY t.sort) as sort FROM(
                    SELECT a.id , a.name,a.sort,a.moduleid
                    FROM  wx_T_mental_menu a INNER JOIN wx_T_mental_auth b ON a.id=b.menuid AND b.atype='role' AND b.roleid=@roleid and a.isactive=1
                    UNION 
                    SELECT a.id, a.name,a.sort,a.moduleid
                    FROM  wx_T_mental_menu a INNER JOIN wx_T_mental_auth c ON a.id=c.menuid AND c.atype='uid' AND c.userid=@userid and a.isactive=1
                    ) t LEFT JOIN wx_T_mental_select s ON t.id=s.menuid AND s.userid=@userid
                ORDER BY sort";
            List<SqlParameter> paras = new List<SqlParameter>();
            paras.Add(new SqlParameter("@userid",userid));
            paras.Add(new SqlParameter("@roleid", roleid));
            errInfo = dal.ExecuteQuerySecurity(mysql, paras,out dt);
            if (errInfo != "") clsSharedHelper.WriteInfo(JsonConvert.SerializeObject(ResponseModel.setRes(400, errInfo)));
            else
            {
                rt = JsonConvert.SerializeObject(ResponseModel.setRes(200, dt, ""));
                clsSharedHelper.DisponseDataTable(ref dt);
                clsSharedHelper.WriteInfo(rt);
            }
        }
    }
    public int checkAppToken(string token)
    {
        uid = 0;
        roleid = 0;
        if (!string.IsNullOrEmpty(token))
        {
            using (LiLanzDALForXLM dal62 = new LiLanzDALForXLM(WXDBConnStr))
            {
                //string str_sql = @"SELECT top 1 uid from wx_t_appLoginStatus where token=@token and tokenLastGet<>''";
                //检查token并把用户id及roleid查出来
                string str_sql = @"SELECT  a.uid,ISNULL(c.RoleID,0) AS roleid from wx_t_appLoginStatus a
                   LEFT JOIN dbo.wx_t_AppAuthorized b ON a.uid=b.UserID AND b.SystemID=3
                   LEFT JOIN dbo.wx_t_OmniChannelUser c ON b.SystemKey=c.ID
                   WHERE token=@token and tokenLastGet<>''";
                List<SqlParameter> para = new List<SqlParameter>();
                para.Add(new SqlParameter("@token", token));
                DataTable dt;
                string errinfo = dal62.ExecuteQuerySecurity(str_sql, para, out dt);
                if (errinfo == "" && dt.Rows.Count > 0)
                {
                    uid = Convert.ToInt32(dt.Rows[0]["uid"]);
                    roleid = Convert.ToInt32(dt.Rows[0]["roleid"]);
                }
                clsSharedHelper.DisponseDataTable(ref dt);
            }//end using
        }

        return uid;
    }

    public bool IsReusable
    {
        get
        {
            return false;
        }
    }
}

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

public class DateTimeHelper
{
    /// <summary>
    /// 获取随机时间
    /// <remarks>
    /// 由于Random 以当前系统时间做为种值,所以当快速运行多次该方法所得到的结果可能相同,
    /// 这时,您应该在外部初始化 Random 实例并调用 GetRandomTime(DateTime time1, DateTime time2, Random random)
    /// </remarks>
    /// </summary>
    public DateTime GetRandomTime(DateTime time1, DateTime time2)
    {
        Random random = new Random();
        return GetRandomTime(time1, time2, random);
    }

    /// <summary>
    /// 获取随机时间
    /// </summary>    
    public DateTime GetRandomTime(DateTime time1, DateTime time2, Random random)
    {
        DateTime minTime = new DateTime();
        DateTime maxTime = new DateTime();

        System.TimeSpan ts = new System.TimeSpan(time1.Ticks - time2.Ticks);
        // 获取两个时间相隔的秒数
        double dTotalSecontds = ts.TotalSeconds;
        int iTotalSecontds = 0;

        if (dTotalSecontds > System.Int32.MaxValue)
        {
            iTotalSecontds = System.Int32.MaxValue;
        }
        else if (dTotalSecontds < System.Int32.MinValue)
        {
            iTotalSecontds = System.Int32.MinValue;
        }
        else
        {
            iTotalSecontds = (int)dTotalSecontds;
        }

        if (iTotalSecontds > 0)
        {
            minTime = time2;
            maxTime = time1;
        }
        else if (iTotalSecontds < 0)
        {
            minTime = time1;
            maxTime = time2;
        }
        else
        {
            return time1;
        }
        int maxValue = iTotalSecontds;
        if (iTotalSecontds <= System.Int32.MinValue)
            maxValue = System.Int32.MinValue;
        int i = random.Next(System.Math.Abs(maxValue));
        return minTime.AddSeconds(i);
    }
}