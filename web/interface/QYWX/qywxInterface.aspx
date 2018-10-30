<%@ Page Language="C#" Debug="true"%>
<%@ Import Namespace="nrWebClass" %>
<%@ Import Namespace="System.Security.Cryptography" %>
<%@ Import Namespace="System.Data" %>
<%@ Import Namespace="System.Data.SqlClient" %>
<%@ Import Namespace="System.Collections.Generic" %>
<%@ Import Namespace="System.Net" %>
 <%@ Import Namespace="System.IO" %>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">

<script runat="server">
    protected void Page_Load(object sender, EventArgs e)
    {
        string ctrl = Convert.ToString(Request.Params["ctrl"]);
        string cname="", phoneNo="",systemID="",rt="";
        ctrl = "test";
        switch (ctrl)
        {
            case "bandSystem":
                cname = Convert.ToString(Request.Params["cname"]);
                phoneNo = Convert.ToString(Request.Params["phoneNo"]);
                systemID = Convert.ToString(Request.Params["SystemID"]);
                string xt_name="",xt_pwd="";
                if(systemID=="1"){ //验证协同系统
                    xt_name = Convert.ToString(Request.Params["xt_user"]);
                    xt_pwd = Convert.ToString(Request.Params["xt_pwd"]);
                    rt= BandOASystem(cname, phoneNo, systemID, xt_name, xt_pwd);
                }else if(systemID=="2"){
                    string rz_sfz = Convert.ToString(Request.Params["rz_sfz"]);
                }
                else if (systemID == "3")
                {

                }
                else if (systemID == "4")
                {

                }
                break;
            case "test": rt = BandOASystem("林文印", "13799514925", "1", "linwy", "lin123456"); break;
        }
        Response.Write(rt);
        Response.End();
    }
   
    /// <summary>
    /// 绑定协同系统
    /// </summary>
    /// <param name="cname"></param>
    /// <param name="phoneNo"></param>
    /// <param name="ststemID"></param>
    /// <param name="name"></param>
    /// <param name="pwd"></param>
    /// <returns></returns>
    private string BandOASystem(string cname, string phoneNo, string ststemID, string name, string pwd)
    {
        string mySql, errInfo,rt="";
        bool flag = true;
        DataTable dt;
        mySql = "select id  from t_user where name=@name and pass=@pwd";
        List<SqlParameter> para = new List<SqlParameter>();
        para.Add(new SqlParameter("@name", name));
        para.Add(new SqlParameter("@pwd", String2MD5(pwd)));
        using (LiLanzDALForXLM dal = new LiLanzDALForXLM())
        {
            errInfo = dal.ExecuteQuerySecurity(mySql, para, out dt);
            para = null;
        }

        if (errInfo != "")
        {
            rt = errInfo;
            flag = false;
        }
        else if (dt.Rows.Count < 1)
        {
            rt = clsNetExecute.Error + ":用户名或密码有误";
            flag = false;
        }

        if (flag==false)
        {
            return rt;
        }

        if (Convert.ToUInt32(Session["qy_userid"]) > 0)//判断此人是否已有企业微信账号，有则直接授权，无则加入通讯录  Session["qy_userid"] 存放wx_T_customer的ID值
        {
            rt = AuthorizedSystem(Convert.ToString(Session["qy_userid"]),"1", Convert.ToString(dt.Rows[0]["id"]), cname);
        }
        else//加入到通讯录中
        {
            clsJsonHelper json = new clsJsonHelper();
            json.AddJsonVar("userid", System.Guid.NewGuid().ToString().ToUpper());
            json.AddJsonVar("name", cname);
            json.AddJsonVar("department", "[90]",false);
            json.AddJsonVar("position", "暂无");
            json.AddJsonVar("mobile", phoneNo);
          //调用接口添加个人信息到通讯录中  还未开发好，，，，
            string myUrl = "http://192.168.35.231/interface/qywx/QYWXDCManager.aspx?ctrl=CreateCustomer";
            string content= postDataToWX(myUrl,json.jSon);
            
            if (content.IndexOf(clsNetExecute.Successed) >= 0)
            {
                string qy_userid = content.Replace(clsNetExecute.Successed, "");
                rt = AuthorizedSystem(qy_userid, Convert.ToString(dt.Rows[0]["id"]),"1", cname);
            }
            else
            {
                rt = content;
            }
        }
        return rt;
    }
    /// <summary>
    /// 绑定人资系统
    /// </summary>
    /// <param name="cname"></param>
    /// <param name="phoneNo"></param>
    /// <param name="rz_sfz"></param>
    /// <returns></returns>
    private string BandHRSystem(string cname, string phoneNo, string rz_sfz)
    {
        string mySql, errInfo, rt = "";
        bool flag = true;
        DataTable dt;
        mySql = "select id from rs_v_ryxxb where xm=@cname and sfzh=@sfzh ";
        List<SqlParameter> para = new List<SqlParameter>();
        para.Add(new SqlParameter("@xm", cname));
        para.Add(new SqlParameter("@sfzh", rz_sfz));
        using (LiLanzDALForXLM dal = new LiLanzDALForXLM())
        {
            errInfo = dal.ExecuteQuerySecurity(mySql, para, out dt);
            para = null;
        }

        if (errInfo != "")
        {
            rt = errInfo;
            flag = false;
        }
        else if (dt.Rows.Count < 1)
        {
            rt = clsNetExecute.Error + ":姓名、身份证号码与人资信息不一致!";
            flag = false;
        }

        if (flag == false)
        {
            return rt;
        }

        if (Convert.ToUInt32(Session["qy_userid"]) > 0)//判断此人是否已有企业微信账号，有则直接授权，无则加入通讯录  Session["qy_userid"] 存放wx_T_customer的ID值
        {
            rt = AuthorizedSystem(Convert.ToString(Session["qy_userid"]), "2", Convert.ToString(dt.Rows[0]["id"]), cname);
        }
        else //添加到通讯录  首先判断
        {

        }

        return "";
    }
    /// <summary>
    /// 系统授权,将数据插入的到数据库
    /// </summary>
    /// <param name="UserID"></param>
    /// <param name="SystemKey"></param>
    /// <param name="AuthName"></param>
    /// <returns></returns>
    private string AuthorizedSystem(string UserID,string SystemID, string SystemKey, string AuthName)
    {
        string errInfo = "";
        string mySql = @"if exists (select * from wx_t_AppAuthorized where userid=@UserID and systemID=@SystemID) 
                        update wx_t_AppAuthorized set SystemKey=@SystemKey where userid=@UserID and systemID=@SystemID
                        else 
                        insert into wx_t_AppAuthorized(UserID,SystemID,SystemKey,AuthTime,AuthName) values(@UserID,@SystemID,@SystemKey,getdate(),@AuthName)";
        List<SqlParameter> para = new List<SqlParameter>();
        para.Add(new SqlParameter("@UserID", UserID));
        para.Add(new SqlParameter("@SystemID", SystemID));
        para.Add(new SqlParameter("@SystemKey", SystemKey));
        para.Add(new SqlParameter("@AuthName", AuthName));
        using (LiLanzDALForXLM dal = new LiLanzDALForXLM())
        {
            errInfo = dal.ExecuteNonQuerySecurity(mySql, para);
            para = null;
        }
        if (errInfo == "")
        {
            return clsNetExecute.Successed;
        }
        else
        {
            return errInfo;
        }
    }
   
    /// <summary>
    /// guid生成
    /// </summary>
    /// <returns></returns>
    private string getGUID()
    {
        System.Guid guid = new Guid();
        guid = Guid.NewGuid();
        string str = guid.ToString();
        return str.ToUpper();
    }
    /// <summary>
    /// 转换为MD5
    /// </summary>
    /// <param name="s"></param>
    /// <returns></returns>
    private string String2MD5(string s)
    {
        byte[] bytes = Encoding.Unicode.GetBytes(s);
        byte[] buffer2 = new MD5CryptoServiceProvider().ComputeHash(bytes);
        StringBuilder pw = new StringBuilder();
        foreach (byte _byte in buffer2)
            pw.Append(_byte.ToString("X2"));

        return pw.ToString();
    }
    /// <summary>
    /// POST 数据到微信服务器
    /// </summary>
    /// <param name="url"></param>
    /// <param name="datas"></param>
    /// <returns></returns>
    private String postDataToWX(String url, String datas)
    {
        Encoding encoding = Encoding.GetEncoding("GB2312");
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
</script>

<html xmlns="http://www.w3.org/1999/xhtml">
<head id="Head1" runat="server">
</head>
<body>

</body>
</html>
