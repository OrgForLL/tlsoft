<%@ Page Title="型男投票" Language="C#" AutoEventWireup="true" %>

<%@ Import Namespace="nrWebClass" %>
<%@ Import Namespace="System.Data" %>
<%@ Import Namespace="System.Collections.Generic" %>
<%@ Import Namespace="System.Data.SqlClient" %>

<script runat="server">
    string VIPWebPath = clsConfig.GetConfigValue("VIP_WebPath");
    public List<string> wxConfig; //微信OPEN_JS 动态生成的调用参数
    string tzFun = "window.history.go(-1);";
    string Cname = "";

    //必须在内容页的Load中对Master.SystemID 进行赋值；
    protected void Page_Load(object sender, EventArgs e)
    {
        string bs = Request["bs"];
        //if(bs=="0") tzFun = "window.location.href='ListAll.aspx';";
        tzFun = "window.location.href='ListAll.aspx';";    //无条件跳转回首页，不执行关闭.  By:xlm 20170615
        
        string ConfigKey = clsConfig.GetConfigValue("CurrentConfigKey");
        if (clsWXHelper.CheckUserAuth(ConfigKey, "openid"))
        {
            wxConfig = clsWXHelper.GetJsApiConfig(ConfigKey);
            string mbopenid = Request["mbopenid"];
            bool shbs = false;
            DataTable dt;
            string conn = clsWXHelper.GetWxConn();
            using (LiLanzDALForXLM sqlhelper = new LiLanzDALForXLM(conn))
            {
                List<SqlParameter> para = new List<SqlParameter>();
                string sql = @"
                    SELECT top 1 a.ID,a.MyImgURL1,a.MyImgURL2,a.ISay,b.Provinces+b.Area+a.StoreName dz,a.shbs,a.Idea,a.TokenCount,a.Cname
                    FROM dbo.xn_t_SigninUser a 
                    INNER JOIN dbo.xn_t_BaseArea b ON a.AreaID=b.ID
                    WHERE a.wxOpenID=@wxOpenID and a.IsActive=1
                ";
                para.Add(new SqlParameter("@wxOpenID", mbopenid));
                string errorInfo = sqlhelper.ExecuteQuerySecurity(sql, para, out dt);
                if (errorInfo != "")
                {
                    clsSharedHelper.DisponseDataTable(ref dt);
                    clsLocalLoger.WriteError(string.Concat("[我是型男]型男信息查询！错误：", errorInfo));
                    Response.End();
                }
                if (dt.Rows.Count > 0)
                {
                    shbs = Convert.ToBoolean(dt.Rows[0]["shbs"]) ;
                    if (shbs == false && mbopenid != Session["openid"].ToString())
                    {
                        Response.Write("<span style='font-size: 4em;'>该型男还未通过审核不能访问！！！</"+"span>");
                        Response.End();
                        return;
                    }
                    //参赛形象照
                    img.Style.Add("background-image", "url('" + dt.Rows[0]["MyImgURL1"] + "')");  
                    img.Attributes.Add("onclick", string.Concat("SetYlImg('",  VIPWebPath,dt.Rows[0]["MyImgURL1"].ToString().Replace("../../","") ,"')"));
                    //搭配师工作照
                    img1.Style.Add("background-image", "url('" + dt.Rows[0]["MyImgURL2"] + "')");  
                    img1.Attributes.Add("onclick", string.Concat("SetYlImg('", VIPWebPath, dt.Rows[0]["MyImgURL2"].ToString().Replace("../../", ""), "')"));
                    //型男宣言                                     
                    ISaysx.InnerHtml = dt.Rows[0]["ISay"].ToString(); 
                    //搭配理念                     
                    Ideasx.InnerHtml = dt.Rows[0]["Idea"].ToString(); 
                    //地址                     
                    dzsx.InnerHtml = dt.Rows[0]["dz"].ToString(); 
                    //编号
                    bh.InnerHtml = "编号:" + dt.Rows[0]["ID"].ToString();
                    //票数
                    tpNum.InnerHtml = dt.Rows[0]["TokenCount"].ToString();
                    Cname = dt.Rows[0]["Cname"].ToString();
                }
                else
                {
                    clsSharedHelper.DisponseDataTable(ref dt);        
                    Response.Write("<span style='font-size: 4em;'>[我是型男]该型男不存在！！！</"+"span>");
                    Response.End();
                }
                clsSharedHelper.DisponseDataTable(ref dt);
            }
            openid.Value = mbopenid;
            if (mbopenid == Session["openid"].ToString())
            {
                if (shbs == false) ts.InnerHtml = "（信息审核中）";                
                ts.InnerHtml += "若信息有误请联系店长!";
                tpBtn.Style.Add("display", "none");
            }
        }
        else
        {
            clsSharedHelper.WriteInfo("鉴权失败");
            return;
        }
    }
</script>

<!DOCTYPE html>
<html>
<head>
    <meta charset="utf-8" />
    <meta name="viewport" content="width=device-width,initial-scale=1,user-scalable=0,maximum-scale=1" />
    <meta name="format-detection" content="telephone=no" />
    <meta name="apple-mobile-web-app-capable" content="yes" />
    <meta name="apple-mobile-web-app-status-bar-style" content="black" />
    <META HTTP-EQUIV ="Pragma" CONTENT="no-cache">
    <META HTTP-EQUIV ="Cache-Control" CONTENT="no-cache">
    <META HTTP-EQUIV ="Expires" CONTENT="0">
    <title>型男投票</title>

    <link rel="stylesheet" href="../../res/css/sweet-alert.css" />
    <script src="../../res/js/jquery.js" type="text/javascript"></script>
    <script src="../../res/js/sweet-alert.min.js" type="text/javascript"></script>  
    <script type="text/javascript" src="http://res.wx.qq.com/open/js/jweixin-1.0.0.js"></script> 
    <script type="text/javascript" src="http://tm.lilanz.com/oa/api/lilanzAppWVJBridge.min.js?ver=07"></script>

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
        }

        .titleimg {
            margin: 1em 0 0.5em 0;
            height: 5em;
        }

        .item {
            position: relative;
            width: 86%;
            left: 7%;
            margin-top: 0.5em;
            vertical-align: top;
            text-align: left;
        }

            .item .first {
                margin: 0.25em 0;
                color: #bc9c41;
                display: block;
            }

        .panel {
            position: relative;
            width: 86%;
            left: 7%;
            border: 1px solid #595757;
            background-color: #1a1a1b;
        }

        .imgPanel {
            position: relative;
            width: 40%;
            margin: 0 3%;
            text-align: left;
            display: inline-block;
        }

            .imgPanel > span {
                color: #bc9c41;
                margin: 0.5em 0;
                display: inline-block;
            }

            .imgPanel > div {
                width: 100%;
                height: 10rem;
                color: #fff;
                background-color: #000;
                border: 1px solid #bc9c41;                
                background-size:100%;
                background-repeat:no-repeat;
            }

                

        .btnPanel {
            position: relative;
            margin-top: 1em;
            padding: 0 7%;
            height: 2em;
            text-align: center;
            width: 100%;
        }

            .btnPanel img {
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

        .imgPanel img {
            width: 100%;
            position: absolute;
        }

        .bh {
            position: absolute;
            /* left: 5px; */
            font-size: 10px;
            width: 100%;
            background-color: rgba(200,200,200,0.4);
            color: #666;
            padding-left: 0.25em;
            font-weight:bold;
        }
        .btnPanel > span {
            position: relative;
            height: 1.5em;
            display: inline-block;
        }

        .tpFont {
            font-weight: bold;
            position: absolute;
            color: black;    
            left: 0px;
            top: 6px;
            width: 100%;
            text-align: center;    
            font-size: 0.8em;
        }

        .nrspan{ 
            font-size:12px; 
            width:95%; 
            color:#c0c0c0;  
            
        }
        
        .hidspan
        {
            /*
            overflow:hidden;         
            white-space:nowrap;
            text-overflow:ellipsis;
            */
        }
         
    </style>
</head>
<body>
    <input type="hidden" id="openid" runat="server" />
    <img class="titleimg" alt="我要报名" src="../../res/img/StylishMen/ShowTitle.jpg" />
    <div class="panel">
        <div class="imgPanel">
            <span>参赛形象照</span>
            <div id="img" runat="server"><span class="bh" id="bh" runat="server">编号：5</span></div>
        </div>
        <div class="imgPanel">
            <span>搭配师工作照</span>
            <div id="img1" runat="server"></div>
        </div>

        <div class="item">
            <span class="first">型男宣言</span>
            <div class="nrspan hidspan"> 
                <span id="ISaysx" runat="server">我是型男，我为自己代言！！！</span>
            </div> 
            <%--<textarea rows="2" id="ISay" runat="server"></textarea>--%>
        </div>
        
        <div class="item">
            <span class="first">搭配理念</span>
            <div class="nrspan hidspan"> 
                <span id="Ideasx" runat="server">【搭配理念】</span>
            </div> 
            <%--<textarea rows="2" id="Idea" runat="server"></textarea>--%>
        </div>
        <div class="item">
            <span class="first">参赛门店地址</span>
            <div class="nrspan">
                <span id="dzsx" runat="server">【参赛门店】</span>
            </div>  
        </div>
        <div class="item">
            <span class="first" style="color: #ff0000; font-size: 0.5em;" id="ts" runat="server"></span>
        </div>
    </div>

    <div class="btnPanel">
        <span onclick="SetTp()" id="tpBtn" runat="server"><img alt="投票" src="../../res/img/StylishMen/btnSubToken.jpg" /><span class="tpFont">投票(<span id="tpNum" runat="server" style="color:red;">50</span>)</span></span>
        <img alt="关闭" src="../../res/img/StylishMen/btnClose.jpg" onclick="javascript:SetClose();" />
    </div>

    <p class="copyright">&copy;2017 利郎（中国）有限公司</p>
    <script type="text/javascript">
        var appIdVal = "<%=wxConfig[0]%>", timestampVal = "<%=wxConfig[1]%>", nonceStrVal = "<%=wxConfig[2]%>", signatureVal = "<%=wxConfig[3]%>";

        function wxConfig() {//微信js 注入
            wx.config({
                debug: false, // 开启调试模式,调用的所有api的返回值会在客户端alert出来，若要查看传入的参数，可以在pc端打开，参数信息会通过log打出，仅在pc端时才会打印。
                appId: appIdVal, // 必填，企业号的唯一标识，此处填写企业号corpid
                timestamp: timestampVal, // 必填，生成签名的时间戳
                nonceStr: nonceStrVal, // 必填，生成签名的随机串
                signature: signatureVal, // 必填，签名，见附录1
                jsApiList: ["previewImage", "onMenuShareTimeline", "onMenuShareAppMessage"] // 必填，需要使用的JS接口列表，所有JS接口列表见附录2
            });
            wx.ready(function () {
                //alert("注入成功");
                //分享给朋友
                wx.onMenuShareAppMessage({
                    title: "<%=Cname %>正在参加《我是型男》活动，就差您宝贵的一票啦 ", // 分享标题                
                    imgUrl: "<%=VIPWebPath %>res/img/StylishMen/ImgLink.jpg",
                    desc: '<%=Cname %>正在参加《我是型男》活动，就差您宝贵的一票啦',
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
                    title: "<%=Cname %>正在参加《我是型男》活动，就差您宝贵的一票啦", // 分享标题
                    imgUrl: "<%=VIPWebPath %>res/img/StylishMen/ImgLink.jpg",
                    desc: '<%=Cname %>正在参加《我是型男》活动，就差您宝贵的一票啦',
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
        });

        $(".nrspan").click(function () {
            if ($(this).hasClass("hidspan"))
        		$(this).removeClass("hidspan");
            else 
                $(this).addClass("hidspan");
            //$(this).toggle(500, function () {
            //    $(".nrspan1", this.parentNode).show(1000);
            //});
        }); 
        
        function SetClose() {
//            if (window.history.length==1) wx.closeWindow();
            <%=tzFun %>
        }
        
        function SetYlImg(url) { 
            url = url.replace("/my/", "/"); 

        	wx.previewImage({
				current: url, // 当前显示图片的http链接
				urls: [url] // 需要预览的图片http链接列表
			});
        }
        

        function SetTp() {
            $.ajax({
                type: "POST",
                url: "api.ashx?ctrl=SetToken",
                data: { wxOpenid: $("#openid").val() },
                timeout: 30000,
                error: function (XMLHttpRequest, textStatus, errorThrown) {
                    swal({title:"-投票出错-",text: "",type: "warning",html: true });
                },
                success: function (result) {
                    var obj = eval("(" + result + ")");
                    if (obj.errcode == "0") {
                    
                        swal({title:"-投票成功-",text:obj.errmsg,type: "success",html: true }, function(){                       
                            $("#tpNum").html(Number($("#tpNum").text()) + 1);

                        }); 
                    } else{
                        swal({title:"-投票失败-",text:obj.errmsg,type: "warning",html: true });
                    } 
                }
            });
        }
    </script>
</body>
</html>
