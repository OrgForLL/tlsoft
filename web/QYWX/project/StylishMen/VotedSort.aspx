<%@ Page Title="我要报名" Language="C#" AutoEventWireup="true" EnableEventValidation="false" %>

<%@ Import Namespace="nrWebClass" %>
<%@ Import Namespace="System.Data" %>
<%@ Import Namespace="System.Collections.Generic" %>
<%@ Import Namespace="System.Data.SqlClient" %>

<script runat="server">
    string AreaID = "";
    string VIPWebPath = clsConfig.GetConfigValue("VIP_WebPath"); 
    public List<string> wxConfig; //微信OPEN_JS 动态生成的调用参数

    //必须在内容页的Load中对Master.SystemID 进行赋值；
    protected void Page_Load(object sender, EventArgs e)
    {
        if (!Page.IsPostBack)
        {
            string ConfigKey = clsConfig.GetConfigValue("CurrentConfigKey");
            if (clsWXHelper.CheckUserAuth(ConfigKey, "openid"))
            {
                wxConfig = clsWXHelper.GetJsApiConfig(ConfigKey);
                AreaID = Request["AreaID"];
                if (string.IsNullOrEmpty(AreaID)) {
                    Response.Write("<span style='font-size: 50px;'>赛区不存在</span>");
                    Response.End();
                    return;
                }
                 
                //读取自数据库
                string conn = clsWXHelper.GetWxConn();
                using (LiLanzDALForXLM sqlhelper = new LiLanzDALForXLM(conn))
                {
                    List<SqlParameter> para = new List<SqlParameter>();
                    string sql = @"SELECT top 1 Area FROM xn_t_BaseArea WHERE id = @AreaID AND IsActive = 1 ";
                    para.Add(new SqlParameter("@AreaID", AreaID));
                    DataTable dt;
                    string strInfo = sqlhelper.ExecuteQuerySecurity(sql, para, out dt);
                    if (strInfo != "" || dt.Rows.Count == 0)
                    {
                        clsSharedHelper.WriteErrorInfo("赛区不存在！");
                        return;
                    } 
                    string AreaName = Convert.ToString(dt.Rows[0]["Area"]);
                    this.Title = string.Concat(AreaName, "-投票排行");
                    
                    clsSharedHelper.DisponseDataTable(ref dt);
                } 
            }
            else
            {
                clsSharedHelper.WriteInfo("鉴权失败");
                return;
            }
        }
    }

</script>

<!DOCTYPE html>
<html>
<head runat="server">
    <meta charset="utf-8" />
    <meta name="viewport" content="width=device-width,initial-scale=1,user-scalable=0,maximum-scale=1" />
    <meta name="format-detection" content="telephone=no" />
    <meta name="apple-mobile-web-app-capable" content="yes" />
    <meta name="apple-mobile-web-app-status-bar-style" content="black" />
    <title>投票排行</title>
    
    <link rel="stylesheet" href="../../res/css/sweet-alert.css"/>

    <script src="../../res/js/jquery.js" type="text/javascript"></script>
    <script type="text/javascript" src="../../res/js/template.js"></script>
    <script src="../../res/js/sweet-alert.min.js" type="text/javascript"></script>   
    <script type="text/javascript" src="http://res.wx.qq.com/open/js/jweixin-1.0.0.js"></script>

    <style type="text/css">
        * {
            padding: 0;
            margin: 0;
            box-sizing: border-box;
            -moz-box-sizing: border-box; /* Firefox */
            -webkit-box-sizing: border-box; /* Safari */
            -webkit-appearance: none;
            border-radius: 0;
        }

        input[type=submit], input[type=reset], input[type=button], input[type=text] {
            -webkit-appearance: none;
            border-radius: 0;
        }

        body {
            background: #000 url(../../res/img/StylishMen/bg.jpg) no-repeat;
            background-size: 100%;
            text-align: center;
            -webkit-overflow-scrolling: touch;
            overflow-scrolling: touch;
        }

        .titleimg {
            width: 86%; 
            left: 7%;
            line-height: 3em;
            text-align: center;
            font-size: 1em;
            font-weight: bold;
            background: #262626;
            position: relative;
            top: 0;
            left: 0;
            color: #FFF;
            overflow: hidden;
            margin: 1.5em 0 0;
        }

        
        .table-name {
            position: relative;
            width: 86%;
            left: 7%;
            vertical-align: top;
            color:#fff;
        }

        tr {
            height:30px;
        }

        th {
            border-bottom:dashed #fff 1px;
            font-size:15px;
            font-weight:bold;
            color:#b5963e;
        }
        
        td {
            border-bottom:dashed #fff 1px;
            font-size:13px;
        }

        #table-list{
            width: 100%;
            height: auto;
            font-size: inherit;
            overflow: hidden;
            position: absolute;
            top: 107px;
            bottom: 3em;
            overflow-y: scroll;
        }

         .table-nr {
            width: 86%;
            position: relative;
            left: 7%;
            vertical-align: top;
            color:#fff;
        }         

        .btnPanel {    
            position: fixed;
            bottom: 0.5em;
            padding: 0 7%;
            height: 2em;
            text-align: center;
            width: 100%;
        }

        .btnPanel > img {
            height: 1.5em;
            display: inline-block;
            margin: 0 0.5em;
        }

        .copyright {
            color: #c0c0c0;
            position: relative;
            display: inline-block;
            margin: 1rem 0;
            width: 100%;
            left: 0;
        }
    </style>
</head>
<body>
    <input type="hidden" id="openid" runat="server" />
    <input type="hidden" id="MyImgUrl1" />
    <input type="hidden" id="MyImgUrl2" />
    <form name="form1" runat="server">
        <div id="header">
            <img class="titleimg" alt="投票排行" src="../../res/img/StylishMen/VotedSortTitle.jpg" />
        </div>

        <table class="table-name">
            <thead>
                <tr>
                    <th style="width:20%;">排  名</th>
                    <th style="width:35%;">姓  名</th>
                    <th style="width:45%;">票  数</th>
                </tr>
            </thead>
        </table>
        <div id="table-list">
            <table class="table-nr">
                <tbody class="list">
<%--                    <tr>
                        <td style="width:20%;"><img alt="" src="../../res/img/StylishMen/top1.jpg" style="height: 20px;" /></td>
                        <td style="width:35%;">李四</td>
                        <td style="width:45%;">550</td>
                    </tr>--%>
                </tbody>
            </table>
        </div>

        <div class="btnPanel">
            <img alt="关闭" src="../../res/img/StylishMen/btnClose.jpg" onclick="javascript:SetClose();" />
        </div>
    </form>
    
    <script id="list-temp" type="text/html">
        {{each List as mh i}}           
            <tr>
                <td style="width:20%;">{{if i<=2}}<img alt="" src="../../res/img/StylishMen/top{{i+1}}.jpg" style="height: 20px;" />{{else}} {{i+1}} {{/if}}</td>
                <td style="width:35%;">{{mh.Cname}}</td>
                <td style="width:45%;">{{mh.TokenCount}}票</td>
            </tr>
        {{/each}}
    </script>
    
    <script type="text/javascript">
        var appIdVal = "<%=wxConfig[0]%>", timestampVal = "<%=wxConfig[1]%>", nonceStrVal = "<%=wxConfig[2]%>", signatureVal = "<%=wxConfig[3]%>";

        function wxConfig() {//微信js 注入
            wx.config({
                debug: false, // 开启调试模式,调用的所有api的返回值会在客户端alert出来，若要查看传入的参数，可以在pc端打开，参数信息会通过log打出，仅在pc端时才会打印。
                appId: appIdVal, // 必填，企业号的唯一标识，此处填写企业号corpid
                timestamp: timestampVal, // 必填，生成签名的时间戳
                nonceStr: nonceStrVal, // 必填，生成签名的随机串
                signature: signatureVal, // 必填，签名，见附录1
                jsApiList: ["scanQRCode", "previewImage", "onMenuShareTimeline", "onMenuShareAppMessage", "getNetworkType"] // 必填，需要使用的JS接口列表，所有JS接口列表见附录2
            });
            wx.ready(function () {
                //alert("注入成功");
                //分享给朋友
                wx.onMenuShareAppMessage({
                    title: "《我是型男》" + $("title").html(), // 分享标题                
                    imgUrl: "<%=VIPWebPath %>res/img/StylishMen/ImgLink.jpg",
                    desc: '猜猜我是第几名？',
                    link: window.location.href, // 分享链接                    
                    type: 'link', // 分享类型,music、video或link，不填默认为link
                    dataUrl: '', // 如果type是music或video，则要提供数据链接，默认为空
                    success: function () {
                        // 用户确认分享后执行的回调函数                   
                    },
                    cancel: function () {
                        // 用户取消分享后执行的回调函数
                    }
                });
                //分享到朋友圈
                wx.onMenuShareTimeline({
                    title: "《我是型男》" + $("title").html(), // 分享标题
                    imgUrl: "<%=VIPWebPath %>res/img/StylishMen/ImgLink.jpg",
                    link: window.location.href, // 分享链接                    
                    success: function () {
                        // 用户确认分享后执行的回调函数                         
                    },
                    cancel: function () {
                        // 用户取消分享后执行的回调函数
                    }
                });
            });
            wx.error(function (res) {
                //alert("JS注入失败！");
            });
        }

        $(document).ready(function () {
            wxConfig(); //微信接口注入
            //加载选手列表
            $.ajax({
                type: "POST",
                url: "api.ashx?ctrl=LoadList",
                data: { AreaID: "<%=AreaID %>", TopCount: "100" },
                timeout: 30000,
                error: function (XMLHttpRequest, textStatus, errorThrown) {
                    swal({title:"-出错-",text: "获取投票排行信息出错",type: "warning",html: true });
                },
                success: function (result) {
                    var data = eval("(" + result + ")");
                    if (data.errcode == "0") {
                        $(".list").html(template('list-temp', data));
                    } else {
                        $(".list").html("");
                        swal({title:"-失败-",text:data.errmsg,type: "warning",html: true });
                    }
                }
            });
        });

        //关闭
        function SetClose() {
        	window.history.go(-1);
        }
    </script>
</body>
</html>
