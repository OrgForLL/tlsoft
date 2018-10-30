<%@ Page Language="C#" %>

<%@ Import Namespace="System.Data" %>
<%@ Import Namespace="Newtonsoft.Json" %>
<%@ Import Namespace="Newtonsoft.Json.Linq" %>
<%@ Import Namespace="nrWebClass" %>
<%@ Import Namespace="System.Drawing" %>
<%@ Import Namespace="System.Data.SqlClient" %>
<%@ Import Namespace="System.Collections.Generic" %>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<script runat="server">   

    public string[] wxConfig;
    public string cid = "";
    string DBConStr_tlsoft = "";
    public string wxHeadimgurl = "../../img/initial_img.png";
    public string sid = "";
    public string dgname = "";
    public string ServiceLevel = "";
    public string openid = "oarMEt8HJ9S25Y7ycIe3UVT39hv4";
    private const string ConfigKeyValue = "5";
    public string wxNick = "";
    protected void Page_Load(object sender, EventArgs e)
    {

        //sid = Request.QueryString["sid"].ToString();
        //cid = Request.QueryString["cid"].ToString();
        //DBConStr = ConfigurationManager.ConnectionStrings["Conn_4"].ConnectionString;
        //DBConStr = clsConfig.GetConfigValue("OAConnStr");
        DBConStr_tlsoft = clsConfig.GetConfigValue("OAConnStr");
        string strsql = "";
        if (clsWXHelper.CheckUserAuth(ConfigKeyValue, "openid"))
        {
            openid = Convert.ToString(Session["openid"]);
        }
        if (openid == "")
        {
            clsSharedHelper.WriteErrorInfo("鉴权出错，请重新进入");
            return;
        }
        List<SqlParameter> para = new List<SqlParameter>();
        DataTable dt;
        /*取微信头像*/

        strsql = @"IF EXISTS(select wxHeadimgurl,wxopenid,wxNick from wx_t_vipBinging  where wxopenid=@openid and vipid>0) 
                        BEGIN
	                        SELECT -1 as bs,wxHeadimgurl,wxopenid,wxNick from wx_t_vipBinging  where wxopenid=@openid and vipid>0		--您已经注册过了。不允许重复注册
                        END
                        ELSE
                        BEGIN 
	                        select 1 as bs,wxHeadimgurl,wxopenid,wxNick from wx_t_vipBinging  where wxopenid=@openid 
                        END";
        para.Add(new SqlParameter("@openid", openid));
        using (LiLanzDALForXLM dal = new LiLanzDALForXLM(DBConStr_tlsoft))
        {
            string eScal = dal.ExecuteQuerySecurity(strsql, para, out dt);
            para.Clear();
            if (eScal == "")
            {
                if (dt.Rows.Count > 0)
                {
                    if (Convert.ToInt32(dt.Rows[0]["bs"]) == -1)
                    {
                        //wxNick = Convert.ToString(dt.Rows[0]["wxNick"]);
                        //wxHeadimgurl = Convert.ToString(dt.Rows[0]["wxHeadimgurl"]);
                        Response.Redirect("vipBinging_v2.aspx?cid=3");

                    }
                    else 
                    {
                        wxNick = Convert.ToString(dt.Rows[0]["wxNick"]);
                        wxHeadimgurl = Convert.ToString(dt.Rows[0]["wxHeadimgurl"]);
                    }
                }
                //else
                //{
                //    clsSharedHelper.WriteErrorInfo("请先关注利郎男装公众号！");
                //    return;
                //}
            }
        }




    }



    ///
    /// 写日志(用于跟踪)       -- By:薛灵敏 2014-12-11
    ///
    private void WriteLog2(string strMemo)
    {
        string filename = Server.MapPath(@"./logs/vip{0}.log");
        filename = string.Format(filename, DateTime.Now.ToString("yyyyMMdd"));
        if (!System.IO.Directory.Exists(Server.MapPath(@"/logs/")))
            System.IO.Directory.CreateDirectory(@"/logs/");
        System.IO.StreamWriter sr = null;
        try
        {
            if (!System.IO.File.Exists(filename))
            {
                sr = System.IO.File.CreateText(filename);
            }
            else
            {
                sr = System.IO.File.AppendText(filename);
            }
            sr.WriteLine(DateTime.Now.ToString("[yyyy-MM-dd HH-mm-ss] "));
            sr.WriteLine(strMemo);
        }
        catch
        {
        }
        finally
        {
            if (sr != null)
                sr.Close();
        }
    }
    
</script>
<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <title>您是利郎会员吗？</title>
    <meta name="viewport" content="width=device-width, initial-scale=1.0, maximum-scale=1.0, user-scalable=no" />
    <%--    <script type="text/javascript" src="../../res/js/jquery.js"></script>
    <script type="text/javascript" src="../../res/js/vipweixin/jweixin-1.0.0.js"></script>
    <link rel="stylesheet" href="../../res/css/weui.min.css" />
    <link rel="stylesheet" href="../../res/css/weui.css" />
    <link rel="stylesheet" href="src/example.css" />--%>
    <script type="text/javascript" src="../../js/jquery.js"></script>
    <script type="text/javascript" src="../../js/sAlert.js?ver=20150114_2"></script>
    <script type="text/javascript" src="../../js/jweixin-1.0.0.js"></script>
    <style type="text/css">
        html, body
        {
            width: 100%;
            height: 100%;
            background-color: #333;
            
        }
        
        #topCon
        {
            border-color: #333;
            width: 100%;
            height: 90%;

            box-shadow: 0px 0px 2px #333;
            position: relative;
            overflow: hidden;
            text-align: center;
        }
        
        #FaceImage
        {
            position: absolute;
            top: 20%;
            left: 40%;
            margin: 0 auto;
            padding-top: 35px;
            width: 100px;
            height: 100px;
            -webkit-animation: getin 1s ease-out;
            align: center;
        }
        
        #FaceImage img
        {
            border-radius: 40px;
            padding: 4px;
            border: 1px solid #999;
        }
        #bottom
        {
            border-color: #333;
            background-color: #333;
            height: 10%;
        }
        #bottom h1
        {
            color: #5F5F5F;
            background-color: #333;
            -webkit-background-size: 12px 13.5px;
            font-size: 16px;
            text-align: center;
            height: 10%;
        }
        #pos1
        {
            position: absolute;
            top: 48%;
            left: 35%;
        }
        #pos2
        {
            position: absolute;
            top: 65%;
            left: 30%;
        }
        .nicname 
        {

            margin: 0 auto;
            margin-top: 10px;
            width: 100px;
            text-align: center;
            white-space: nowrap;
            overflow: hidden;
            text-overflow: ellipsis;
            color: #fff;
            font-size: 1.4rem;
            -webkit-animation: getin2 1.5s ease-out;
        }
        .button
        {
            position: absolute;
            top: 58%;
            left: 20%;
            height: 20px;
            display: inline-block;
            outline: none;
            cursor: pointer;
            text-align: center;
            text-decoration: none;
            font: 14px/100% Arial, Helvetica, sans-serif;
            padding: .5em 2em .55em;
            text-shadow: 0 1px 1px rgba(0,0,0,.3);
            -webkit-border-radius: .5em;
            -moz-border-radius: .5em;
            border-radius: .5em;
            -webkit-box-shadow: 0 1px 2px rgba(0,0,0,.2);
            -moz-box-shadow: 0 1px 2px rgba(0,0,0,.2);
            box-shadow: 0 1px 2px rgba(0,0,0,.2);
        }
        .button:hover
        {
            text-decoration: none;
        }
        
        .orange
        {
            width: 50%;
            color: #fef4e9;
            border: solid 1px #da7c0c;
            background: #f78d1d;
            background: -webkit-gradient(linear, left top, left bottom, from(#faa51a), to(#f47a20));
            background: -moz-linear-gradient(top,  #faa51a,  #f47a20);
            filter: progid:DXImageTransform.Microsoft.gradient(startColorstr='#faa51a', endColorstr='#f47a20');
        }
        .orange:hover
        {
            background: #f47c20;
            background: -webkit-gradient(linear, left top, left bottom, from(#f88e11), to(#f06015));
            background: -moz-linear-gradient(top,  #f88e11,  #f06015);
            filter: progid:DXImageTransform.Microsoft.gradient(startColorstr='#f88e11', endColorstr='#f06015');
        }
        .orange:active
        {
            color: #fcd3a5;
            background: -webkit-gradient(linear, left top, left bottom, from(#f47a20), to(#faa51a));
            background: -moz-linear-gradient(top,  #f47a20,  #faa51a);
            filter: progid:DXImageTransform.Microsoft.gradient(startColorstr='#f47a20', endColorstr='#faa51a');
        }
        .button1
        {
            position: absolute;
            top: 70%;
            left: 20%;
            height: 20px;
            display: inline-block;
            outline: none;
            cursor: pointer;
            text-align: center;
            text-decoration: none;
            font: 14px/100% Arial, Helvetica, sans-serif;
            padding: .5em 2em .55em;
            text-shadow: 0 1px 1px rgba(0,0,0,.3);
            -webkit-border-radius: .5em;
            -moz-border-radius: .5em;
            border-radius: .5em;
            -webkit-box-shadow: 0 1px 2px rgba(0,0,0,.2);
            -moz-box-shadow: 0 1px 2px rgba(0,0,0,.2);
            box-shadow: 0 1px 2px rgba(0,0,0,.2);
        }
        .button1:hover
        {
            text-decoration: none;
        }
    </style>
    <script type="text/javascript">

        //        function registervip() {
        //            alert(1)
        //            window.location.href = "vipInfo2.aspx?cid=3"; 
        //        }
        //        function correlationvip() {
        //            window.location.href = "vipBinging_v2.aspx?cid=3";
        //        }
    </script>
</head>
<%--<body style="background-image:url('../../img/012.jpg');">--%>
<body>
    <div id="topCon">
        <div id="FaceImage" onclick="CheoosFaceImg()">
            <img width="70" height="70" src="<%=wxHeadimgurl %>" alt="" />
            <p class="nicname">
                <%=wxNick %></p>
        </div>
        <div>
            <a href="vipBinging_v2.aspx?cid=3" class="button orange">我已经是会员</a></div>
        <div>
            <a href="vipInfoReg.aspx?cid=3" class="button1 orange">我还不是会员</a></div>
    </div>
    <div id="bottom">
        <h1>
            利郎信息技术部提供技术支持</h1>
    </div>
</body>
</html>
