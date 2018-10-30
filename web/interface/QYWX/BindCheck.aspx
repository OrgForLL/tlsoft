<%@ Page Language="C#" %>

<%@ Import Namespace="nrWebClass" %>
<!DOCTYPE html>
<script runat="server"> 
    public string userid = "", openid = "";
    protected void Page_Load(object sender, EventArgs e)
    {
        string code = Convert.ToString(Request.Params["code"]);
        if (code != "" && code != null)
        {
            string postURL = string.Format("https://qyapi.weixin.qq.com/cgi-bin/user/getuserinfo?access_token={0}&code={1}", GetAccessToken, code);
            string content = clsNetExecute.HttpRequest(postURL);
            clsJsonHelper jh = clsJsonHelper.CreateJsonHelper(content);
            string errcode = jh.GetJsonValue("errcode");
            userid = jh.GetJsonValue("UserId");
            openid = jh.GetJsonValue("OpenId");
            if (errcode == "40001" || errcode == "40014" || errcode == "42001")
            {
                ClearAT();
                clsSharedHelper.WriteErrorInfo("access_token失效，请尝试重新打开！");
            }
            else if (userid != "" && userid != null)
            {
                //已经是企业号的成员
                openid = "";

            }
            else if (openid != "" && openid != null)
            {
                //还不是企业号的成员                
                userid = "";

            }
            else
                clsSharedHelper.WriteErrorInfo("出错了，请尝试重新打开 errInfo:" + content);
        }
        else
            clsSharedHelper.WriteErrorInfo("请在微信中打开！");        
    }

    public string GetAccessToken
    {
        get
        {
            string QYWXAT = "";
            string ATURL = string.Format("http://10.0.0.15/wxdevelopment/QYWX/WXAccessTokenManager.aspx?ctrl={0}&key={1}", "GetAT", "1");
            string content = clsNetExecute.HttpRequest(ATURL);
            if (content.IndexOf("Error:") > -1)
                //_QYWXAT = "获取AccessToken时出错 " + content;
                QYWXAT = "";
            else
                QYWXAT = content;

            return QYWXAT;
        }
    }

    public void ClearAT()
    {
        string ATURL = string.Format("http://10.0.0.15/wxdevelopment/QYWX/WXAccessTokenManager.aspx?ctrl={0}&key={1}", "ClearAT", "1");
        string content = clsNetExecute.HttpRequest(ATURL);
    }
</script>
<html lang="en" xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <meta charset="utf-8" />
    <meta name="viewport" content="width=device-width,initial-scale=1,user-scalable=0" />
    <title></title>
    <style type="text/css">
        * {
            padding: 0;
            margin: 0;
        }

        input {
            font-size: 1.2em;
            display: block;
            width: 96%;
            height: 40px;
            outline: none;
            margin: 10px auto;
            border-radius: 0px;
            -webkit-appearance: none;
            box-shadow: 5px 5px 5px #ccc;

        }

    </style>
</head>
<body>
    <div class="container">
        <input type="text" id="username" placeholder="请输入姓名" value="李清峰" />
        <input type="text" id="userphone" placeholder="请输入手机号码" value="15260825009" />
        <input type="text" id="erpuid" placeholder="请输入协同系统用户名" value="liqf" />
        <input type="password" id="erppwd" placeholder="请协同系统密码" value="sbigemtdh" />
        <a href="#" id="subbtn" onclick="javascript:void(0);">提 交</a>
    </div>
    <script type="text/javascript" src="js/jquery.js"></script>
    <script type="text/javascript">
        var openid = "<%=openid%>", userid = "<%=userid%>", isNewUser = false;
        window.onload = function () {
            if (openid == "" && userid != "")
                isNewUser = false;
            else if (openid != "" && userid == "")
                isNewUser = true;
        }

        $("#subbtn").click(function () {
            $.ajax({
                type: "POST",
                timeout: 5000,
                contentType: "application/x-www-form-urlencoded; charset=utf-8",
                url: "QYWXDCManager.aspx",
                data: { ctrl: "ValidBYERP", erpuid: $("#erpuid").val(), erppwd: $("#erppwd").val(), isNewUser: isNewUser },
                success: function (msg) {
                    alert(msg);
                },
                error: function (XMLHttpRequest, textStatus, errorThrown) {
                    alert("您的网络不给力,请重试！");
                }
            });
        });
    </script>
</body>
</html>
