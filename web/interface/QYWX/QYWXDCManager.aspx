<%@ Page Language="C#" %>

<%@ Import Namespace="nrWebClass" %>
<%@ Import Namespace="System.Data" %>
<%@ Import Namespace="System.Data.SqlClient" %>
<%@ Import Namespace="System.Collections.Generic" %>
<%@ Import Namespace="System.Net" %>
<%@ Import Namespace="System.IO" %>
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
                    if (content.IndexOf("Error:") > -1) {
                        //_QYWXAT = "��ȡAccessTokenʱ���� " + content;
                        _QYWXAT = "";
                        writeLog("���û�ȡ��ҵ��Access_Token�ӿ�ʱ����");
                    }
                    else
                        _QYWXAT = content;
                }
            }

            return _QYWXAT;
        }
    }

    /// <summary>
    /// �����Ӧ��access_token�ӿ�
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
            case "CreateDept":
                string bmid = Convert.ToString(Request.Params["bmid"]);
                string deptname = Convert.ToString(Request.Params["deptname"]);
                string parentid = Convert.ToString(Request.Params["parentid"]);
                string order = Convert.ToString(Request.Params["order"]);
                string type = Convert.ToString(Request.Params["depttype"]);
                clsSharedHelper.WriteInfo(CreateDept(bmid, deptname, parentid, order, type));
                break;
            case "GetDeptList":
                string deptid = Convert.ToString(Request.Params["deptid"]);
                clsSharedHelper.WriteInfo(GetDeptList(deptid));
                break;
            case "DelDept":
                deptid = Convert.ToString(Request.Params["deptid"]);
                if (deptid == "" || deptid == "0" || deptid == null)
                    clsSharedHelper.WriteErrorInfo("DeptID is error!");
                else
                    clsSharedHelper.WriteInfo(DelDept(deptid));
                break;
            case "UpdateDeptInfo":
                bmid = Convert.ToString(Request.Params["bmid"]);
                deptname = Convert.ToString(Request.Params["deptname"]);
                parentid = Convert.ToString(Request.Params["parentid"]);
                order = Convert.ToString(Request.Params["order"]);
                type = Convert.ToString(Request.Params["depttype"]);
                deptid = Convert.ToString(Request.Params["deptid"]);
                clsSharedHelper.WriteInfo(UpdateDept(bmid, deptname, parentid, order, type, deptid));
                break;
            case "CreateCustomer":
                string jStr = Convert.ToString(Request.Params[1]);                
                if (jStr == "" || jStr == null)
                    clsSharedHelper.WriteErrorInfo("����Ĳ�������");
                else
                    clsSharedHelper.WriteInfo(CreateCustomer(jStr));
                break;
            case "UpdateCustomerInfo":
                jStr = Convert.ToString(Request.Params[1]);                
                if (jStr == "" || jStr == null)
                    clsSharedHelper.WriteErrorInfo("����Ĳ�������");
                else
                    clsSharedHelper.WriteInfo(UpdateCustomerInfo(jStr));
                break;
            case "DelCustomer":
                string userid = Convert.ToString(Request.Params["userid"]);
                if (userid == "" || userid == "0" || userid == null)
                    clsSharedHelper.WriteErrorInfo("����Ĳ�������");
                else
                    clsSharedHelper.WriteInfo(DelCustomer(userid));
                break;
            default:
                clsSharedHelper.WriteErrorInfo("��Ч�Ŀ��Ʋ�����ctrl:" + ctrl);
                break;
        }
    }

    /*----------------------------------���Ź���wx_t_deptment------------------------------------*/
    /// <summary>
    /// ��������
    /// </summary>
    /// <returns>���سɹ�Successed+ID,ʧ��Error:+������Ϣ</returns>
    public string CreateDept(string bmid, string name, string parentid, string order, string depttype)
    {               
        string rtMsg="";        
        using (LiLanzDALForXLM dal = new LiLanzDALForXLM(DBConStr)) {
            string str_sql = @"if not exists(select id from wx_t_deptment where id=@bmid and parentid=@pid)
                                begin
                                insert into wx_t_deptment(tzid,id,name,parentid,orderval,depttype) values (1,@bmid,@name,@pid,@order,@type);
                                select SCOPE_IDENTITY();
                                end
                                else
                                select wxid from wx_t_deptment where id=@bmid and parentid=@pid;";
            List<SqlParameter> paras = new List<SqlParameter>();
            paras.Add(new SqlParameter("@bmid", bmid));
            paras.Add(new SqlParameter("@name", name));
            paras.Add(new SqlParameter("@pid", parentid));
            paras.Add(new SqlParameter("@order", order));
            paras.Add(new SqlParameter("@type", depttype));
            DataTable dt = null;
            string errinfo = dal.ExecuteQuerySecurity(str_sql,paras,out dt);
            if (errinfo == "")
            {
                if (dt.Rows.Count > 0)
                {
                    string wxid = dt.Rows[0][0].ToString();
                    //����������΢��API
                    string postURL = string.Format("https://qyapi.weixin.qq.com/cgi-bin/department/create?access_token={0}", QYAccessToken);
                    string postData = @"{{
                               ""id"": ""{0}"",
                               ""name"": ""{1}"",
                               ""parentid"": ""{2}"",
                               ""order"": ""{3}""                               
                            }}";
                    postData = string.Format(postData, wxid, name, parentid, order);
                    string content = postDataToWX(postURL, postData);
                    clsJsonHelper jh = clsJsonHelper.CreateJsonHelper(content);
                    string errcode = jh.GetJsonValue("errcode");
                    if (errcode == "40001" || errcode == "40014" || errcode == "42001")
                    {
                        ClearAT();
                        rtMsg = "Error:" + content;
                    }
                    else if (errcode != "0")
                        rtMsg = "Error:" + content;
                    else if (errcode == "0")
                        rtMsg = "Successed" + wxid;
                }
            }
            else
                rtMsg = "Error:�����������ݴ�������ʱ���� " + errinfo;

            return rtMsg;                
        }       
    }

    /// <summary>
    /// ����ָ�����ŵ���Ϣ
    /// </summary>
    /// �ȸ��±����ٵ���API
    /// ����ֵΪ�մ���ִ�гɹ������򷵻ش�����Ϣ
    public string UpdateDept(string bmid, string name, string parentid, string order, string depttype, string wxid)
    {
        string rtMsg = "";
        using (LiLanzDALForXLM dal = new LiLanzDALForXLM(DBConStr)) {
            string str_sql = @"if not exists(select wxid from wx_t_deptment where wxid=@wxid)
                                select '00';
                                else
                                begin
                                update wx_t_deptment set id=@bmid,name=@name,parentid=@pid,orderval=@order,depttype=@type where wxid=@wxid;
                                select '11';
                                end";
            List<SqlParameter> paras = new List<SqlParameter>();
            paras.Add(new SqlParameter("@wxid", wxid));
            paras.Add(new SqlParameter("@bmid", bmid));
            paras.Add(new SqlParameter("@name", name));
            paras.Add(new SqlParameter("@pid", parentid));
            paras.Add(new SqlParameter("@order", order));
            paras.Add(new SqlParameter("@type", depttype));
            DataTable dt = null;
            string errinfo = dal.ExecuteQuerySecurity(str_sql,paras,out dt);
            if (errinfo == "")
            {
                string rt=dt.Rows[0][0].ToString();
                if (rt == "00")
                    rtMsg = "Error:�������ݿ����Ҳ�����Ӧ�Ĳ��ţ� WXID=" + rt;
                else if (rt == "11") { 
                    //���ز����ɹ�
                    string postURL = string.Format("https://qyapi.weixin.qq.com/cgi-bin/department/update?access_token={0}",QYAccessToken);
                    string postData = @"{{
                               ""id"": ""{0}"",
                               ""name"": ""{1}"",
                               ""parentid"": ""{2}"",
                               ""order"": ""{3}""
                            }}";
                    postData = string.Format(postData, wxid, name, parentid, order);
                    string content = postDataToWX(postURL, postData);
                    clsJsonHelper jh = clsJsonHelper.CreateJsonHelper(content);
                    string errcode = jh.GetJsonValue("errcode");
                    if (errcode == "40001" || errcode == "40014" || errcode == "42001")
                    {
                        ClearAT();
                        rtMsg = content;
                    }
                    else if (errcode != "0")
                        rtMsg = content;                                     
                }                
            }
            else
                rtMsg = "Error:ִ��ɾ�����ز���ʱ���� " + errinfo;

            return rtMsg;
        }       
    }

    /// <summary>
    /// ��ȡ�����б�
    /// </summary>
    /// <param name="deptID"></param>
    /// ֱ�ӷ���΢�ŵ�������
    public string GetDeptList(string deptID)
    {
        string postURL = "https://qyapi.weixin.qq.com/cgi-bin/department/list?access_token={0}&id={1}";
        postURL = string.Format(postURL, QYAccessToken, deptID);
        string content = clsNetExecute.HttpRequest(postURL);
        clsJsonHelper jh = clsJsonHelper.CreateJsonHelper(content);
        string errcode = jh.GetJsonValue("errcode");
        if (errcode == "40001" || errcode == "40014" || errcode == "42001")
        {
            ClearAT();
        }
        else if (errcode == "0")
        {
            //����ִ�гɹ�
            //List<clsJsonHelper> jhList = jh.GetJsonNodes("department");
            //if (jhList == null)
            //    rtMsg = "Error:����ID��������";
        }

        return content;
    }

    /// <summary>
    /// ɾ��ָ������
    /// </summary>
    /// <param name="deptID"></param>
    /// ����ֵΪ�մ���ִ�гɹ����򷵻ش�����Ϣ
    public string DelDept(string deptID)
    {
        //�ȵ���΢��API��ɾ����������
        string rtMsg = "";
        string postURL = string.Format("https://qyapi.weixin.qq.com/cgi-bin/department/delete?access_token={0}&id={1}", QYAccessToken, deptID);
        string content = clsNetExecute.HttpRequest(postURL);
        clsJsonHelper jh = clsJsonHelper.CreateJsonHelper(content);
        string errcode = jh.GetJsonValue("errcode");
        if (errcode == "40001" || errcode == "40014" || errcode == "42001")
        {
            ClearAT();
            rtMsg = content;            
        }
        else if (errcode == "0")
        {
            //����ִ�гɹ� ������ɾ����������
            using (LiLanzDALForXLM dal = new LiLanzDALForXLM(DBConStr)) {
                string str_sql = @"delete from wx_t_deptment where wxid=@deptid";
                List<SqlParameter> paras = new List<SqlParameter>();
                paras.Add(new SqlParameter("@deptid", deptID));
                rtMsg = dal.ExecuteNonQuerySecurity(str_sql, paras);
            }
        }else
            rtMsg = content;

        return rtMsg;
    }


    /*----------------------------------��Ա����wx_t_customers------------------------------------*/
    /// <summary>
    /// �½���Ա
    /// </summary>
    /// �ȵ���API�ɹ�֮���ٲ����������ݣ��ɹ��򷵻�Successed+ID��ʧ�ܷ���Error:+������Ϣ
    public string CreateCustomer(string jStr)
    {
        string rtMsg = "";
        clsJsonHelper jh = clsJsonHelper.CreateJsonHelper(jStr);
        string userOpenId = jh.GetJsonValue("OpenId");
        jh.RemoveJsonVar("OpenId");//���Ƴ���openid���ύ΢��
        string postURL = string.Format("https://qyapi.weixin.qq.com/cgi-bin/user/create?access_token={0}", QYAccessToken);        
        string content = postDataToWX(postURL, jh.jSon);        
        clsJsonHelper wxjh = clsJsonHelper.CreateJsonHelper(content);
        string errcode = wxjh.GetJsonValue("errcode");
        if (errcode == "40001" || errcode == "40014" || errcode == "42001")
        {
            ClearAT();
            rtMsg = "Error:" + content;
        }
        else if (errcode == "0")
        {
            //����ִ�гɹ�
            using (LiLanzDALForXLM dal = new LiLanzDALForXLM(DBConStr))
            {                
                string guid = jh.GetJsonValue("userid");
                string name = jh.GetJsonValue("name");
                string dept = jh.GetJsonValue("department").Replace("[", "").Replace("]", ""); ;
                string position = jh.GetJsonValue("position");
                string mobile = jh.GetJsonValue("mobile");
                string str_sql = @"insert into wx_T_Customers(name,cname,department,position,mobile,wxopenid)
                                    values(@guid,@name,@dept,@position,@mobile,@openid);
                                    select SCOPE_IDENTITY();";
                List<SqlParameter> paras = new List<SqlParameter>();
                paras.Add(new SqlParameter("@guid", guid));
                paras.Add(new SqlParameter("@name", name));
                paras.Add(new SqlParameter("@dept", dept));
                paras.Add(new SqlParameter("@position", position));
                paras.Add(new SqlParameter("@mobile", mobile));
                paras.Add(new SqlParameter("@openid", userOpenId));
                DataTable dt = null;
                errcode = dal.ExecuteQuerySecurity(str_sql, paras, out dt);
                if (errcode == "" && dt.Rows.Count > 0)
                {
                    rtMsg = "Successed" + dt.Rows[0][0].ToString();                    
                }
                else
                    rtMsg = "Error:�������س�Ա����ʱ���� " + errcode;
            }
        }
        else
            rtMsg = "Error:����΢��API����" + content;

        return rtMsg;
    }

    /// <summary>
    /// ��ȡ��Ա
    /// </summary>
    /// <param name="userid"></param>
    public string GetCustomerInfo(string userid)
    {
        string postURL = "https://qyapi.weixin.qq.com/cgi-bin/user/get?access_token={0}&userid={1}";
        postURL = string.Format(postURL, QYAccessToken, userid);
        string content = clsNetExecute.HttpRequest(postURL);
        clsJsonHelper jh = clsJsonHelper.CreateJsonHelper(content);
        string errcode = jh.GetJsonValue("errcode");
        if (errcode == "40001" || errcode == "40014" || errcode == "42001")
        {
            ClearAT();
            clsSharedHelper.WriteErrorInfo("access_tokenʧЧ�������ԣ�");
        }
        else if (errcode == "0")
        {
            //����ִ�гɹ�
            clsSharedHelper.WriteInfo(content);
        }
        else
            clsSharedHelper.WriteErrorInfo("��ȡ��Աʧ�� " + content);

        return errcode;
    }

    /// <summary>
    /// ɾ��ָ����Ա
    /// </summary>
    /// <returns></returns>
    public string DelCustomer(string userid)
    {
        string rtMsg = "";
        string postURL = string.Format("https://qyapi.weixin.qq.com/cgi-bin/user/delete?access_token={0}&userid={1}", QYAccessToken, userid);
        string content = clsNetExecute.HttpRequest(postURL);
        clsJsonHelper jh = clsJsonHelper.CreateJsonHelper(content);
        string errcode = jh.GetJsonValue("errcode");
        if (errcode == "40001" || errcode == "40014" || errcode == "42001")
        {
            ClearAT();
            rtMsg = "Error:" + content;
        }
        else if (errcode == "0" || errcode == "60111")
        {
            //����ִ�гɹ�������΢�����Ҳ������û� ������ɾ����������
            using (LiLanzDALForXLM dal = new LiLanzDALForXLM(DBConStr)) {
                string str_sql = @"if exists (select top 1 1 from wx_t_customers where name=@userid)
                                    begin
                                    declare @uid int;
                                    select @uid=id from wx_t_customers where name=@userid;
                                    delete from wx_t_customers where name=@userid;
                                    delete from wx_t_appauthorized where userid=@uid;
                                    end";
                List<SqlParameter> para = new List<SqlParameter>();
                para.Add(new SqlParameter("@userid", userid));
                rtMsg = dal.ExecuteNonQuerySecurity(str_sql, para);
                if (rtMsg == "")
                    rtMsg = clsSharedHelper.Successed;
                else
                    rtMsg = "Error:ɾ�����س�Աʱ���� " + rtMsg;
            }            
        }
        else
            rtMsg = "Error:ɾ����Աʧ�� " + content;

        return rtMsg;
    }

    /// <summary>
    /// ���³�Ա����
    /// </summary>
    /// <param name="jStr"></param>
    /// <returns></returns>
    public string UpdateCustomerInfo(string jStr)
    {
        string rtMsg = "";
        using (LiLanzDALForXLM dal = new LiLanzDALForXLM(DBConStr))
        {
            clsJsonHelper jh = clsJsonHelper.CreateJsonHelper(jStr);
            string guid = jh.GetJsonValue("userid");
            string name = jh.GetJsonValue("name");
            string dept = jh.GetJsonValue("department").Replace("[", "").Replace("]", ""); ;
            string position = jh.GetJsonValue("position");
            string mobile = jh.GetJsonValue("mobile");
            string gender = jh.GetJsonValue("gender");
            gender = gender == "" ? "1" : "2";
            string email = jh.GetJsonValue("email");
            string weixinid = jh.GetJsonValue("weixinid");
            string enable = jh.GetJsonValue("enable");

            string str_sql = @"declare @id int;
                                if not exists (select top 1 id from wx_t_customers where name=@userid)
                                select '00','0'
                                else
                                begin
                                select @id=id from wx_t_customers where name=@userid;
                                update wx_t_customers set cname=@name,department=@dept,position=@position,mobile=@mobile,
                                email=@email,weixinid=@weixinid,isactive=@enable,gender=@gender
                                where name=@userid;
                                select '11',@id;
                                end";

            List<SqlParameter> paras = new List<SqlParameter>();
            paras.Add(new SqlParameter("@userid", guid));
            paras.Add(new SqlParameter("@name", name));
            paras.Add(new SqlParameter("@dept", dept));
            paras.Add(new SqlParameter("@position", position));
            paras.Add(new SqlParameter("@mobile", mobile));
            paras.Add(new SqlParameter("@email", email));
            paras.Add(new SqlParameter("@weixinid", weixinid));
            paras.Add(new SqlParameter("@enable", enable));
            paras.Add(new SqlParameter("@gender", gender));
            DataTable dt = null;
            string errinfo = dal.ExecuteQuerySecurity(str_sql, paras, out dt);
            if (errinfo == "" && dt.Rows.Count > 0)
            {
                if (dt.Rows[0][0].ToString() == "00")
                    rtMsg = "Error:�Բ��𣬱����Ҳ������û���Ϣ��";
                else if (dt.Rows[0][0].ToString() == "11")
                {
                    //�ύ΢�Ÿ��� 
                    string postURL = string.Format("https://qyapi.weixin.qq.com/cgi-bin/user/update?access_token={0}", QYAccessToken);
                    string content = postDataToWX(postURL, jStr);
                    jh = clsJsonHelper.CreateJsonHelper(content);
                    errinfo = jh.GetJsonValue("errcode");
                    if (errinfo == "40001" || errinfo == "40014" || errinfo == "42001")
                    {
                        ClearAT();
                        rtMsg = "Error:" + content;
                    }
                    else if (errinfo != "0")
                        rtMsg = "Error:" + content;
                    else if (errinfo == "0")
                        rtMsg = clsSharedHelper.Successed+Convert.ToString(dt.Rows[0][1]);
                }//end update in weixin
            }
            else
                rtMsg = "Error:���³�Աʱ��ѯʧ�� " + errinfo;
        }

        return rtMsg;
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

    /// <summary>
    /// POST ���ݵ�΢�ŷ�����
    /// </summary>
    /// <param name="url"></param>
    /// <param name="datas"></param>
    /// <returns></returns>
    private String postDataToWX(String url, String datas)
    {
        Encoding encoding = Encoding.UTF8;
        byte[] data = encoding.GetBytes(datas);
        HttpWebRequest myRequest = (HttpWebRequest)WebRequest.Create(url);
        myRequest.Method = "POST";
        myRequest.Timeout = 10000;
        myRequest.ContentType = "application/x-www-form-urlencoded";
        myRequest.ContentLength = data.Length;        
        Stream newStream = myRequest.GetRequestStream();
        newStream.Write(data, 0, data.Length);
        newStream.Close();
        HttpWebResponse myResponse = (HttpWebResponse)myRequest.GetResponse();
        StreamReader reader = new StreamReader(myResponse.GetResponseStream(), Encoding.Default);
        string result = reader.ReadToEnd();
        return result;
    }

    /// <summary>
    /// д��־����
    /// </summary>
    /// <param name="info"></param>
    public static void writeLog(string info)
    {
        try
        {
            clsLocalLoger.logDirectory = HttpContext.Current.Server.MapPath("logs/");
            if (System.IO.Directory.Exists(clsLocalLoger.logDirectory) == false)
            {
                System.IO.Directory.CreateDirectory(clsLocalLoger.logDirectory);
            }
            clsLocalLoger.WriteInfo(info);
        }
        catch (Exception ex)
        {

        }
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
