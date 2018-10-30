<%@ Page Language="C#" %>

<%@ Import Namespace="nrWebClass" %>
<%@ Import Namespace="System.Data" %>
<%@ Import Namespace="System.Data.SqlClient" %>
<%@ Import Namespace="System.Collections.Generic" %>
<!DOCTYPE html>

<script runat="server">
    public static object lockATConfig = new object();
    public static object lockATTable = new object();
    private static DataTable _ATConfig = null;//配置信息表
    private static DataTable _ATTable = null;//AccessToken 内存表
    private const string QYATURL = "https://qyapi.weixin.qq.com/cgi-bin/gettoken?corpid={0}&corpsecret={1}";
    private const string GZHATURL = "https://api.weixin.qq.com/cgi-bin/token?grant_type=client_credential&appid={0}&secret={1}";
    private const string LegalIP = @"^192\.|^10\.";//来源访问IP限制
        
    private static DataTable ATConfig
    {
        get
        {
            if (_ATConfig == null)
            {
                lock (lockATConfig)
                {
                    using (LiLanzDALForXLM dal = new LiLanzDALForXLM())
                    {
                        string str_sql = @"select configkey,configtype,appid,appsecret from wx_t_tokenconfiginfo";
                        string errinfo = dal.ExecuteQuery(str_sql, out _ATConfig);
                        if (errinfo != "")
                        {
                            clsSharedHelper.WriteErrorInfo("生成静态_ATConfig时出错 errinfo:" + errinfo);
                            return null;
                        }
                        else if (_ATConfig.Rows.Count == 0)
                        {
                            clsSharedHelper.WriteErrorInfo("微信配置信息为空！");
                            return null;
                        }
                        else
                            _ATConfig.PrimaryKey = new DataColumn[] { _ATConfig.Columns[0] };                         
                    }
                }//end lock
            }

            return _ATConfig;
        }
    }

    private static DataTable ATTable
    {
        get
        {
            if (_ATTable == null)
            {
                _ATTable = new DataTable("ATTable");
                _ATTable.Columns.Add("configkey", typeof(Int32), "");                
                _ATTable.Columns.Add("accesstoken", typeof(String), "");
                _ATTable.Columns.Add("validtime", typeof(DateTime), "");
                _ATTable.PrimaryKey = new DataColumn[] { _ATTable.Columns[0] };

                lock (lockATConfig) {
                    for (int i = 0; i < ATConfig.Rows.Count; i++) { 
                        _ATTable.Rows.Add(new object[] { (object)ATConfig.Rows[i]["configkey"], "", (object)DateTime.Now });
                    }
                }             
            }

            return _ATTable;
        }
    }
    
    protected void Page_Load(object sender, EventArgs e)
    {
        if (!CheckIP()) {
            clsSharedHelper.WriteErrorInfo("IP受限！");
            return;
        }
        string ctrl = Convert.ToString(Request.Params["ctrl"]);                
        
        switch (ctrl)
        {
            case "GetAT":
                int key = 0;
                try
                {
                    key = Convert.ToInt32(Request.Params["key"]);
                }
                catch (Exception ex) {
                    clsSharedHelper.WriteErrorInfo("请检查传入的key是否有效！");
                    return;
                }
                
                if (key == 0 || key == null)
                    clsSharedHelper.WriteErrorInfo("请传入相应的key！");
                else
                    GetAT(key);
                break;
                
            case "ClearAT":
                try
                {
                    key = Convert.ToInt32(Request.Params["key"]);
                }
                catch (Exception ex)
                {
                    clsSharedHelper.WriteErrorInfo("请检查传入的key是否有效！");
                    return;
                }
                
                if (key == 0 || key == null)
                    clsSharedHelper.WriteErrorInfo("请传入相应的key！");
                else
                    ClearAT(key);                   
                break;
            case "GetValidTime":
                try
                {
                    key = Convert.ToInt32(Request.Params["key"]);
                }
                catch (Exception ex)
                {
                    clsSharedHelper.WriteErrorInfo("请检查传入的key是否有效！");
                    return;
                }

                if (key == 0 || key == null)
                    clsSharedHelper.WriteErrorInfo("请传入相应的key！");
                else
                    GetValidTime(key);
                break;                    
            case "InitATConfig":
                InitATConfig();
                break;
            case "printDT":
                Response.Write("----------------------------"+DateTime.Now.ToString()+" 【ATConfig】-------------------------------<br />");
                printDataTable(ATConfig);
                Response.Write("----------------------------" + DateTime.Now.ToString() + " 【ATTable】-------------------------------<br />");
                printDataTable(ATTable);                
                break;
            default:
                clsSharedHelper.WriteErrorInfo("无效的控制参数！ctrl:" + ctrl);
                break;        
        }
    }

    /// <summary>
    /// 获取对应access_token的有效期
    /// </summary>
    /// <param name="key"></param>
    private void GetValidTime(int key) {
        lock (ATTable) {
            DataRow dr = ATTable.Rows.Find((object)key);
            if (dr == null)
                clsSharedHelper.WriteErrorInfo("请传入正确的key！");
            else {
                string access_token = Convert.ToString(dr["accesstoken"]);
                string validtime = Convert.ToString(dr["validtime"] == DBNull.Value ? "" : dr["validtime"]);
                if (access_token == "" || access_token == null)
                    validtime = "";

                clsSharedHelper.WriteSuccessedInfo(validtime);
            }
        }        
    }    
    
    /// <summary>
    /// 获取微信access_token方法
    /// </summary>
    /// <param name="key"></param>
    private void GetAT(int key) {
        DataTable dt = ATTable;
        lock (lockATTable) {
            //使用此方法必须要有主键，多个主键则传入一个对象数组new object[]{object1,object2....}
            //该方法比select效率来得高
            DataRow dr = dt.Rows.Find((object)key);
            if (dr == null)
                clsSharedHelper.WriteErrorInfo("请传入正确的key！");
            else
            {
                string access_token = Convert.ToString(dr["accesstoken"]);
                DateTime validtime = Convert.ToDateTime(dr["validtime"] == DBNull.Value ? DateTime.Now.ToString() : dr["validtime"]);
                if (access_token == "" || access_token == null || validtime.Subtract(DateTime.Now).TotalSeconds < 1)
                {
                    //重新获取
                    string postURL = "", appID = "", appSecret = "";
                    int drIndex = 0;
                    lock (lockATConfig)
                    {
                        DataRow drc = ATConfig.Rows.Find((object)key);
                        if (drc != null)
                        {
                            string type = drc["configtype"].ToString().ToUpper();
                            appID = drc["appid"].ToString();
                            appSecret = drc["appsecret"].ToString();
                            postURL = type == "QY" ? QYATURL : GZHATURL;
                            postURL = string.Format(postURL, appID, appSecret);
                            drIndex = ATConfig.Rows.IndexOf(drc);
                        }
                    }//end lock atconfig

                    string content = clsNetExecute.HttpRequest(postURL);
                    clsJsonHelper json = clsJsonHelper.CreateJsonHelper(content);
                    if (json.GetJsonValue("access_token") != "")
                    {
                        dt.Rows[drIndex]["accesstoken"] = json.GetJsonValue("access_token");
                        dt.Rows[drIndex]["validtime"] = DateTime.Now.AddSeconds(Convert.ToInt32(json.GetJsonValue("expires_in")) - 100);
                        clsSharedHelper.WriteInfo(json.GetJsonValue("access_token"));
                    }
                    else
                        clsSharedHelper.WriteErrorInfo(content);
                }
                else
                {
                    clsSharedHelper.WriteInfo(access_token);
                }
            }
        }//end lock
    }

    /// <summary>
    /// 在应用中使用AccessToken，执行结果返回的错误代码中表示AccessToken无效时，应用应主动调用该接口；
    /// 该接口将会清空key对应的AccessToken内存信息，以便在下一次访问时重新获取有效的AccessToken。
    /// </summary>    
    private void ClearAT(int key)
    {
        lock (lockATTable) {
            DataRow dr = ATTable.Rows.Find((object)key);
            if (dr == null)
                clsSharedHelper.WriteErrorInfo("请传入正确的key！");
            else {
                int drIndex = ATTable.Rows.IndexOf(dr);
                ATTable.Rows[drIndex]["accesstoken"] = "";
                clsSharedHelper.WriteSuccessedInfo("");
            }
        }    
    }
    /// <summary>
    /// 清空内存中的配置信息，以便重新初始化。
    /// </summary>
    private void InitATConfig() {
        if (_ATConfig != null)
        {
            _ATConfig.Dispose();
            _ATConfig = null;
        }
        
        if (_ATTable != null) {
            _ATTable.Dispose();
            _ATTable = null;
        }
        clsSharedHelper.WriteSuccessedInfo("配置信息清除成功！");
    }

    //打印内存表
    public void printDataTable(DataTable dt)
    {        
        if (dt != null)
        {
            string printStr = "";
            if (dt.Rows.Count > 0)
            {
                for (int i = 0; i < dt.Rows.Count; i++)
                {
                    for (int j = 0; j < dt.Columns.Count; j++)
                    {
                        if (dt.Rows[i][j] == null)
                            printStr += "null&nbsp;";
                        else
                            printStr += Convert.ToString(dt.Rows[i][j]) + "&nbsp;";
                    }
                    printStr += "<br />";
                }
                Response.Write(printStr);
                //Response.End();
            }
        }
        else
            Response.Write("DataTable is null!");        
    }

    /// <summary>
    /// 检查访问的IP是否合法
    /// </summary>
    /// <returns></returns>
    private bool CheckIP() {
        bool rt = false;
        string clientIp = HttpContext.Current.Request.UserHostAddress;
        if (clientIp == "::1")  //测试时发现使用 localhost访问时输出的IP可能为该值。
        {
            clientIp = "127.0.0.1";
        }

        if (System.Text.RegularExpressions.Regex.IsMatch(clientIp, LegalIP))
            rt = true;
        else
            rt = false;
        return rt;
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
