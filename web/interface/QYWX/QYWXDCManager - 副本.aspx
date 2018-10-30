<%@ Page Language="C#" %>

<%@ Import Namespace="nrWebClass" %>
<%@ Import Namespace="System.Data" %>
<%@ Import Namespace="System.Data.SqlClient" %>
<%@ Import Namespace="System.Collections.Generic" %>
<!DOCTYPE html>
<script runat="server">    
    private static string _QYWXAT = "";
    private static object _syncObj = new object();
    private static string QYWXKEY = "1";
    public string DBConStr = "server=192.168.35.23;database=tlsoft;uid=lllogin;pwd=rw1894tla";
    
    private static string QYAccessToken {
        get {
            lock (_syncObj)
            {
                if (_QYWXAT == null || _QYWXAT == "")
                {
                    string ATURL = string.Format("http://10.0.0.15/wxdevelopment/QYWX/WXAccessTokenManager.aspx?ctrl={0}&key={1}", "GetAT", QYWXKEY);
                    string content = clsNetExecute.HttpRequest(ATURL);
                    if (content.IndexOf("Error:") > -1)
                        //_QYWXAT = "获取AccessToken时出错 " + content;
                        _QYWXAT = "";
                    else
                        _QYWXAT = content;
                }
            }

            return _QYWXAT;
        }
    }

    /// <summary>
    /// 清除对应的access_token接口
    /// </summary>
    private void ClearAT() {
        string ATURL = string.Format("http://10.0.0.15/wxdevelopment/QYWX/WXAccessTokenManager.aspx?ctrl={0}&key={1}", "ClearAT", QYWXKEY);
        clsNetExecute.HttpRequest(ATURL);
        lock (_syncObj) {
            _QYWXAT = "";
        }         
    }
    
    protected void Page_Load(object sender, EventArgs e)
    {
        string ctrl = Convert.ToString(Request.Params["ctrl"]);
        switch (ctrl)
        { 
            case "GetCustomerInfo":
                string userid = Convert.ToString(Request.Params["userid"]);
                GetCustomerInfo(userid);
                break;
            case "ValidERPAccount":
                string loginname=Convert.ToString(Request.Params["erpuid"]);
                string loginpass=Convert.ToString(Request.Params["erppwd"]);
                ValidERPAccount(loginname,loginpass);
                break;
            default:
                clsSharedHelper.WriteErrorInfo("无效的控制参数！ctrl:" + ctrl);
                break;
        }
    }

    /// <summary>
    /// 创建部门
    /// </summary>
    public void CreateDept(string bmid, string name,string parentid,string order,string depttype) {
        string postURL = string.Format("https://qyapi.weixin.qq.com/cgi-bin/department/create?access_token={0}",QYAccessToken);
        string postData = @"{{
                               ""id"": ""{0}"",
                               ""name"": ""{1}"",
                               ""parentid"": ""{2}"",
                               ""order"": ""{3}""
                            }}";
        
    }

    /// <summary>
    /// 更新指定部门的信息
    /// </summary>
    public void UpdateDept(string bmid,string name,string parentid,string order,string depttype,string wxid) {
        string postURL = "https://qyapi.weixin.qq.com/cgi-bin/department/update?access_token={0}";
        string postData = @"{{
                               ""id"": ""{0}"",
                               ""name"": ""{1}"",
                               ""parentid"": ""{2}"",
                               ""order"": ""{3}""
                            }}";
    }
    
    /// <summary>
    /// 获取部门列表
    /// </summary>
    /// <param name="deptID"></param>
    public void GetDeptList(string deptID) {
        string postURL = "https://qyapi.weixin.qq.com/cgi-bin/department/list?access_token={0}&id={1}";
        postURL = string.Format(postURL,QYAccessToken,deptID);
        string content = clsNetExecute.HttpRequest(postURL);        
        clsJsonHelper jh = clsJsonHelper.CreateJsonHelper(content);
        if (jh.GetJsonValue("errcode") == "40001" || jh.GetJsonValue("errcode") == "40014" || jh.GetJsonValue("errcode") == "42001")
        {
            ClearAT();
            clsSharedHelper.WriteErrorInfo("access_token失效，请重试！");
        }
        else if (jh.GetJsonValue("errcode") == "0")
        {
            //代表执行成功
            List<clsJsonHelper> jhList = jh.GetJsonNodes("department");
            if (jhList == null)
                clsSharedHelper.WriteErrorInfo("部门ID参数有误！");
            else { 
            
            }
        }
        else
            clsSharedHelper.WriteErrorInfo("获取部门列表失败 " + content);
    }

    /// <summary>
    /// 删除指定部门
    /// </summary>
    /// <param name="deptID"></param>
    public string DelDept(string deptID) {
        string postURL = string.Format("https://qyapi.weixin.qq.com/cgi-bin/department/delete?access_token={0}&id={1}",QYAccessToken,deptID);
        string content = clsNetExecute.HttpRequest(postURL);
        clsJsonHelper jh = clsJsonHelper.CreateJsonHelper(content);
        string errcode = jh.GetJsonValue("errcode"); 
        if (errcode == "40001" || errcode == "40014" || errcode == "42001")
        {
            ClearAT();
            clsSharedHelper.WriteErrorInfo("access_token失效，请重试！");
        }
        else if (errcode == "0")
        {
            //代表执行成功
            clsSharedHelper.WriteSuccessedInfo("删除部门成功！");
        }
        else
            clsSharedHelper.WriteErrorInfo("删除指定部门失败 " + content);

        return errcode;        
    }

    /// <summary>
    /// 新建成员
    /// </summary>
    public string CreateCustomer() {
        string postURL = string.Format("https://qyapi.weixin.qq.com/cgi-bin/user/create?access_token={0}",QYAccessToken);
        string userid = System.Guid.NewGuid().ToString().ToUpper();
        string postData = @"{{
                               ""userid"": ""{0}"",
                               ""name"": ""测试2"",
                               ""department"": [90],
                               ""position"": ""产品经理"",
                               ""mobile"": ""15260825010"",
                               ""gender"": ""1"",
                               ""email"": ""fjjjczyz@gmail.com""     
                            }}";
        postData = string.Format(postData,userid);
        clsJsonHelper jh = clsNetExecute.HttpRequestToWX(postURL, postData);        
        string errcode = jh.GetJsonValue("errcode");
        if (errcode == "40001" || errcode == "40014" || errcode == "42001")
        {
            ClearAT();
            clsSharedHelper.WriteErrorInfo("access_token失效，请重试！");
        }
        else if (errcode == "0")
        {
            //代表执行成功
            clsSharedHelper.WriteInfo(errcode);
        }
        else
            clsSharedHelper.WriteErrorInfo("创建成员失败 " + jh.jSon);

        return errcode;
    }

    /// <summary>
    /// 获取成员
    /// </summary>
    /// <param name="userid"></param>
    public string GetCustomerInfo(string userid) {       
        string postURL = "https://qyapi.weixin.qq.com/cgi-bin/user/get?access_token={0}&userid={1}";
        postURL = string.Format(postURL,QYAccessToken,userid);
        string content = clsNetExecute.HttpRequest(postURL);
        clsJsonHelper jh = clsJsonHelper.CreateJsonHelper(content);
        string errcode = jh.GetJsonValue("errcode");           
        if (errcode == "40001" || errcode == "40014" || errcode == "42001")
        {            
            ClearAT();
            clsSharedHelper.WriteErrorInfo("access_token失效，请重试！");
        }
        else if (errcode == "0")
        {
            //代表执行成功
            clsSharedHelper.WriteInfo(content);
        }
        else
            clsSharedHelper.WriteErrorInfo("获取成员失败 " + content);
        
        return errcode;
    }

    /// <summary>
    /// 删除指定成员
    /// </summary>
    /// <returns></returns>
    public string DelCustomer(string userid) {
        string postURL = string.Format("https://qyapi.weixin.qq.com/cgi-bin/user/delete?access_token={0}&userid={1}", QYAccessToken, userid);
        string content = clsNetExecute.HttpRequest(postURL);
        clsJsonHelper jh = clsJsonHelper.CreateJsonHelper(content);
        string errcode = jh.GetJsonValue("errcode");
        if (errcode == "40001" || errcode == "40014" || errcode == "42001")
        {
            ClearAT();
            clsSharedHelper.WriteErrorInfo("access_token失效，请重试！");
        }
        else if (errcode == "0")
        {
            //代表执行成功
            clsSharedHelper.WriteInfo(content);
        }
        else
            clsSharedHelper.WriteErrorInfo("删除成员失败 " + content);

        return errcode;
    }

    /// <summary>
    /// 验证用户的ERP系统账号
    /// </summary>
    /// <param name="username"></param>
    /// <param name="pwd"></param>
    public void ValidERPAccount(string username, string pwd)
    {
        using (LiLanzDALForXLM dal = new LiLanzDALForXLM(DBConStr)) {
            string str_sql = "select * from wx_v_userInfo where name=@loginname and pass=@loginpass";
            List<SqlParameter> paras = new List<SqlParameter>();
            DataTable dt = null;
            paras.Add(new SqlParameter("@loginname", username));
            paras.Add(new SqlParameter("@loginpass",pwd));            
            string errinfo = dal.ExecuteQuerySecurity(str_sql, paras, out dt);
            if (errinfo == "") {
                if (dt.Rows.Count > 0) {
                    clsSharedHelper.WriteInfo("验证成功");
                }else
                    clsSharedHelper.WriteErrorInfo("用户名或密码错误！");
            }            
        }
    }

    private string String2MD5(string s)
    {
        byte[] bytes = Encoding.Unicode.GetBytes(s);
        byte[] buffer2 = new System.Security.Cryptography.MD5CryptoServiceProvider().ComputeHash(bytes);
        StringBuilder pw = new StringBuilder();
        foreach (byte _byte in buffer2)
            pw.Append(_byte.ToString("X2"));

        return pw.ToString();
    }
</script>
<html lang="en" xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <meta charset="utf-8" />
    <title></title>
</head>
<body>
    <form id="form1" runat="server">
    </form>
</body>
</html>
