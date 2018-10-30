<%@ Page Title="我是型男" Language="C#" AutoEventWireup="true" %>

<%@ Import Namespace="nrWebClass" %>
<%@ Import Namespace="System.Data" %>
<%@ Import Namespace="System.Collections.Generic" %>
<%@ Import Namespace="System.Data.SqlClient" %>

<script runat="server">
    string VIPWebPath = clsConfig.GetConfigValue("VIP_WebPath");
    public List<string> wxConfig; //微信OPEN_JS 动态生成的调用参数

    public string AreaID = "";
    public string AreaName = "";
    public string AreaSf = "";
    public string ClearLocal = "";   //清空AreaID
    protected void Page_Load(object sender, EventArgs e)
    {
        Response.Redirect("ListAll.aspx");
        
        AreaID = Request.Params["aid"];
        ClearLocal = Request.Params["ClearLocal"];
        if (Request.HttpMethod == "GET")
        {
            if (string.IsNullOrEmpty(AreaID) || AreaID == "null") {
                AreaID = "";
                ClearLocal = "1";
            }
            else
            {
                //读取自数据库
                string conn = clsWXHelper.GetWxConn();
                using (LiLanzDALForXLM sqlhelper = new LiLanzDALForXLM(conn))
                {
                    List<SqlParameter> para = new List<SqlParameter>();
                    string sql = @"SELECT top 1 Provinces,Area FROM xn_t_BaseArea WHERE id = @AreaID AND IsActive = 1 ";
                    para.Add(new SqlParameter("@AreaID", AreaID));
                    DataTable dt;
                    string strInfo = sqlhelper.ExecuteQuerySecurity(sql, para, out dt);
                    if (strInfo != "" || dt.Rows.Count == 0)
                    {
                        clsLocalLoger.WriteError("赛区不存在！aid=" + AreaID);
                        Response.Redirect("List.aspx?ClearLocal=1");
                        return;
                    }

                    AreaSf = Convert.ToString(dt.Rows[0]["Provinces"]);
                    AreaName = Convert.ToString(dt.Rows[0]["Area"]);

                    clsSharedHelper.DisponseDataTable(ref dt);
                }
            }
            string ConfigKey = clsConfig.GetConfigValue("CurrentConfigKey");
            if (clsWXHelper.CheckUserAuth(ConfigKey, "openid"))
            {
                wxConfig = clsWXHelper.GetJsApiConfig(ConfigKey);
                SetProBind();
            }
            else
            {
                clsSharedHelper.WriteInfo("鉴权失败");
                return;
            }
        }
        else
        {
            SetSelArea();
        }
    }


    private void SetSelArea()
    {
        string conn = clsWXHelper.GetWxConn();
        DataTable dt;
        string strInfo = "";

        string pValue = HttpUtility.UrlDecode(Request["selProvinces"].ToString());
        if (string.IsNullOrEmpty(pValue) || pValue == "") return;

        using (LiLanzDALForXLM dal = new LiLanzDALForXLM(conn))
        {
            strInfo = dal.ExecuteQuery(string.Format("SELECT DISTINCT ID,Area FROM xn_t_BaseArea WHERE tzid = 1 AND Provinces='{0}' and IsActive=1 ORDER BY Area", pValue), out dt);
            if (strInfo != "")
            {
                clsLocalLoger.WriteError(string.Concat("[我是型男]获取区域信息失败！错误：", strInfo));
                return;
            }
            string optionMb = "<option value='{0}' {2}>{1}</option>";
            string strHtml = "<option value=''>请选择</option>";
            string isSelected = "";
            foreach (DataRow dr in dt.Rows)
            {
                if (dr[0].ToString() == AreaID) isSelected = "selected";
                else isSelected = "";
                strHtml += string.Format(optionMb, dr[0].ToString(), dr[1].ToString(), isSelected);
            }
            clsSharedHelper.DisponseDataTable(ref dt);
            Response.Write(strHtml);
            Response.End();
        }
    }

    private void SetProBind()
    {
        string conn = clsWXHelper.GetWxConn();
        DataTable dt;
        string strInfo = "";
        using (LiLanzDALForXLM dal = new LiLanzDALForXLM(conn))
        {
            strInfo = dal.ExecuteQuery("SELECT DISTINCT Provinces FROM xn_t_BaseArea WHERE tzid = 1 and IsActive=1 ORDER BY Provinces", out dt);
            if (strInfo != "")
            {
                clsLocalLoger.WriteError(string.Concat("[我是型男]获取省份信息失败！错误：", strInfo));
                return;
            }

            selProvinces.Items.Clear();
            selProvinces.Items.Add(new ListItem("请选择..", ""));
            foreach (DataRow dr in dt.Rows)
            {
                selProvinces.Items.Add(new ListItem(Convert.ToString(dr[0]), Convert.ToString(dr[0])));
            }
            clsSharedHelper.DisponseDataTable(ref dt);
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
    <title>我是型男</title>

    <link rel="stylesheet" href="../../res/css/sweet-alert.css" />
    <script src="../../res/js/jquery.js" type="text/javascript"></script>
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
            width: 100%;
        }

        video {
            border: 1px solid #3d3115;
            margin-top: 0.5em;
            width:100%;
            height:13rem;           
        }


        .btnPanel {
            position: relative;
            margin-top: 0.5rem;
            padding: 0 1%;
            text-align: center;
            width: 100%;
        }

            .btnPanel > img {
                width: 25%;
                display: inline-block;
                margin: 0 1.5%;
            }

        .searchPanel {
            position: relative;
            height: 2em;
            width: 92%;
            left: 4%;
            background: #000 url(../../res/img/StylishMen/searchPanel.jpg) no-repeat;
            background-size: 100% 2em;
            display: none;
        }

            .searchPanel > span {
                font-size: 1.2rem;
                color: #000;
                font-weight: 900;
                position: absolute;
                left: 0.5rem;
                top: 0.20rem;
            }

            .searchPanel > input {
                font-size: 1rem;
                background-color: #000;
                color: #fff;
                position: absolute;
                right: 2rem;
                top: 0.40rem;
                width: 30%;
                border: 0;
            }

            .searchPanel > img {
                background-color: #000;
                position: absolute;
                right: 0.6rem;
                top: 0.5rem;
                width: 1em;
            }

        .panel {
            position: relative;
            width: 100%;
            left: 0; 
        }

        .imgPanel {
            position: relative;
            width: 8.75rem;
            height: 11.4rem;
            margin: 0.5rem 0.5rem;
            text-align: left;
            display: inline-block;
            background-size: 100%;
            background-color: #000;
            background-repeat: no-repeat;    
            overflow: hidden;
        }
        
        .imgPanel > img
        {
            width:100%;
            position:absolute;
            top:1.25rem;
        }

            .imgPanel > div {
                position: absolute;
                width: 100%;
                height: 100%;
                background: rgba(255,255,255,0) url(../../res/img/StylishMen/FaceRound.png?v20170613) no-repeat;
                background-size: 100%;
            }

                .imgPanel > div > span:nth-child(1)     
                {
                    position: absolute;
                    left: 0.25rem;
                    bottom: 2.0rem;
                    font-size: 1rem;
                    font-weight: 900;
                    color: #000;
                }

                .imgPanel > div > span:nth-child(2)     
                {
                    position: absolute;
                    right: 0.25rem;
                    bottom: 2rem;
                    font-size: 0.7rem;
                    color: #000;
                    font-weight: 600;
                }

        .SelectArea {
            position: relative;
            height: 2.5em;
            width: 96%;
            left: 2%;
            text-align: left;
            padding: 0.5em;
            background-color: rgba(100,100,100,0.2);
            display: none;
        }

            .SelectArea > span:nth-child(1) {
                font-size: 1em;
                display: inline-block;
                color: #fff;
            }

            .SelectArea > span:nth-last-child(1) {
                position: absolute;
                right: 0.5em;
                font-size: 1em;
                font-weight: 700;
                text-decoration: underline;
                color: #fff;
            }

            .SelectArea > select {
                width: 4em;
                background-color: #000;
                color: #fff;
                font-size: 1em;
            }

        .copyright {
            color: #c0c0c0;
            position: relative;
            display: inline-block;
            margin: 1rem 0;
            width: 100%;
            left: 0;
        }
        .bh {
            position: absolute;
            font-size: 0.75rem;
            z-index: 100;
            width: 100%; 
            color: #fff;
            padding-top: 0.2rem; 
            text-align: center;
            font-weight: 500;
        }
        #SelectName {
            font-size:15px;
        }
        .dqArea,.NotArea    
        {
            color: #fff;
            width: 96%;
            text-align: right;
            font-size: 1em;
            margin: 0.5em 0;
            border-bottom: 1px solid rgba(200,200,200,0.3);
            left: 2%;
            position: relative;
            padding: 0.5em;
        }
        .dqArea>span:nth-child(2), .NotArea>span
        { 
            font-weight: 900;
            text-decoration: underline;
        }
        .show_zz {
            position: absolute;
            top: 0;
            bottom: 0;
            left: 0;
            right: 0;
            background-color: rgba(0,0,0,0.6);
            z-index: 200;
            display:none;
        }
        .show {
            color: #fff; 
            position: absolute;
            left: 5%;
            right: 5%;
            top: 40%;
            background-color: rgba(0,0,0,0.9);
            padding: 10px;
            border-radius: 0.3em;
            height: 10em;
            border: 1px solid #fff;
            z-index: 99999;
        }
        
        .show > span:nth-child(1)
        {
            display:block;
            text-align: left;
            padding-left: 1em;
            margin: 0.5em;
        }
        .show > select 
        {
            background-color:#000;
            font-size:1.2em;
            margin-top:0.5em;
            color:#fff;
        }
        #selProvinces {
            width:5em;
        }

        #selArea {
            width:9em; 
            visibility: hidden;
        }

        .qrBtn {    
            padding: 0.5em;
            display: inline-block;
            width: 6em;
            background-color: #333;
            border-radius: 5px;
            color: #fff;
            border: 1px solid #606060;
            margin: 1.5em 0.5em;
        }
        
        #page {
            width: 100%;
            height: auto;
            position: absolute;
            overflow: auto;
            top: 0;
            bottom: 0;
        }

        #page_nr {
            position: absolute;
            top: 0;
            bottom: 0;
            overflow-y: scroll;
            height: 100%;
            width:100%;
            z-index:100;
        }
        #page_nr>video
        {            
            z-index:101;
            
        }
        
        .videoMain
        {
            position:relative;
            width: 94%;
            left:3%;
        }
        .videoPanel
        {
            width: 100%;
            border-bottom: 1px solid #666;
            height: 4.5rem;
            text-align: left; 
            white-space: nowrap;
            overflow: scroll;
            position: relative;
        }
        .videoPanel > div
        {
            position: relative;
            width: 4rem;
            height: 4rem;
            background-size: 100%;
            background-repeat: no-repeat;
            display: inline-block;
            border: 1px solid #333;
        }
        .videoPanel > div > span
        {
            position: absolute;
            height: 0.75rem;
            font-size: 0.5rem;
            bottom: 0.1rem;
            width: 100%;
            text-align: center;
            background-color: rgba(100,100,100,0.6);
            left: 0;
            color: #aaa;
        }
        
        .videoTitle
        {
            position: absolute;
            left: 0;
            top: 0;
            text-align: left;
            color: #aaa;
            width: 100%;
            display: inline-block;
            padding-left: 0.5rem;
            margin-top: 0.5rem;
            background-color: rgba(50,50,50,0.4);
            font-size: 0.75rem;        
            z-index:234;  
        }
    </style>
</head>
<body>
    <div id="page">        
        <div id="page_nr">
            <img class="titleimg" alt="我要报名" src="../../res/img/StylishMen/ListTitle.jpg" />
            <div class="videoMain">
                <span class="videoTitle"></span>
                <video id="video1" width="100%" height="33%" controls="controls" poster="http://lilanz.oss-cn-fujian-a.aliyuncs.com/StylishMen/VideoFace2.jpg">
                    <source src="http://lilanz.oss-cn-fujian-a.aliyuncs.com/StylishMen/2.mp4" type="video/mp4">
                    您的浏览器不支持视频!
                </video>
                <div class="videoPanel">
                    <div data-videoid="2" data-title="我是型男"><span>我是型男</span></div> 
                    <div data-videoid="4" data-title="利郎元素——百变马戏团"><span>百变马戏团</span></div>
                    <%--<div data-videoid="5" data-title="利郎元素——绅士英伦风"><span>绅士英伦风</span></div>--%>
                    <div data-videoid="6" data-title="利郎轻商务"><span>利郎轻商务</span></div>
                    
                    <div data-videoid="n1" data-title="12种型男发型（视频来源于网络）"><span>型男发型</span></div>
                    <div data-videoid="n2" data-title="正确穿着西服的8个原则（视频来源于网络）"><span>怎么穿西服</span></div> 

                </div>
            </div>
            <div class="dqArea" onclick="SetXg()"> 
                <span>当前赛区:</span><span></span>
                <span>去看看其它赛区>></span>
            </div>
            <div class="NotArea" onclick="SetXg()">
                <span>您还未选择赛区，马上选择赛区>></span>
            </div>
            <div class="btnPanel">
                <img alt="我要报名" src="../../res/img/StylishMen/btnGotoSignin.jpg" onclick="javascript:window.location.href='Signin.aspx';" />
                <img alt="查看投票" src="../../res/img/StylishMen/btnShowTokenList.jpg" onclick="javascript:ToTpList();" />
                <img alt="活动规则" src="../../res/img/StylishMen/btnGotoRemark.jpg" onclick="javascript:window.location.href='Remark.html';" />
            </div>
            <div class="searchPanel">
                <span>我是型男投票</span>
                <input type="text" placeholder="搜索编号/名称" id="SelectName" />
                <img alt="search" src="../../res/img/stylishmen/search.jpg" onclick="SetSelect()" />
            </div>
            <div class="panel"> 
                <p style="color: #fff;">正在获取选手信息... 请稍后...</p>
            </div>

            <p class="copyright">&copy;2017 利郎（中国）有限公司</p>  
        </div> 
        <div class="show_zz">
            <div class="show"> 
                <span>请选择赛区：</span>
                <select id="selProvinces" runat="server" onchange="SetSelArea()">
                    <%--<option value="">请选择</option>
                    <option value="福建" selected>福建</option>
                    <option value="浙江">浙江</option>
                    <option value="江西">江西</option>--%>
                </select>
                <select id="selArea">
                    <%--<option value="1">泉州</option>
                    <option value="2" selected>厦门</option>
                    <option value="3">漳州</option>--%>
                </select> <br />
                <span class="qrBtn" id="qrBtn" onclick="gotoArea(1)">确定</span>
                <span class="qrBtn" onclick="$('.show_zz').toggle();">取消</span>
            </div>
        </div>
    </div>  
    <script id="panel-temp" type="text/html">
        {{each List as mh}}            
            <div class="imgPanel" openid="{{mh.openid}}">                
                <img alt="参赛者" src="{{mh.MyImgURL1}}" />
                <span class="bh">编号:{{mh.ID}}</span>
                <div><span class="name">{{mh.Cname}}</span><span>票数：{{mh.TokenCount}}</span></div>
            </div>
        {{/each}}
    </script>
</body>
<script type="text/javascript" src="../../res/js/jquery.js"></script>
<script type="text/javascript" src="../../res/js/template.js"></script>
<%--<script type="text/javascript" src="../../res/js/fastclick.min.js"></script>--%>
<script>
    var AreaID = "<%= AreaID %>";
    var AreaSf = "<%= AreaSf %>";
    var AreaName = "<%= AreaName %>";
    var ClearLocal = "<%= ClearLocal %>";
    
    var appIdVal = "<%=wxConfig[0]%>", timestampVal = "<%=wxConfig[1]%>", nonceStrVal = "<%=wxConfig[2]%>", signatureVal = "<%=wxConfig[3]%>";

    function setItem(key, value) {
        localStorage.setItem(key, value);
    }
    function getItem(key) {
        return localStorage.getItem(key);
    }
    function AutoSetArea() {
        if (ClearLocal == "1") {
            setItem("AreaID", "");
            AreaID = "";
            AreaSf = "";
            AreaName = "";
            return;
        }

        if (AreaID != "") return;

        var aid = getItem("AreaID"); 

        if (aid == null || aid == "") return;

        if (AreaID == "") {
            window.location.href = "List.aspx?aid=" + aid;         
        }        
    }

    window.onload = function () {
        AutoSetArea();
    } 

    function wxConfig() {//微信js 注入
        wx.config({
            debug: false, // 开启调试模式,调用的所有api的返回值会在客户端alert出来，若要查看传入的参数，可以在pc端打开，参数信息会通过log打出，仅在pc端时才会打印。
            appId: appIdVal, // 必填，企业号的唯一标识，此处填写企业号corpid
            timestamp: timestampVal, // 必填，生成签名的时间戳
            nonceStr: nonceStrVal, // 必填，生成签名的随机串
            signature: signatureVal, // 必填，签名，见附录1
            jsApiList: ["onMenuShareTimeline", "onMenuShareAppMessage", "getNetworkType"] // 必填，需要使用的JS接口列表，所有JS接口列表见附录2
        });
        wx.ready(function () {
            //alert("注入成功");
            //分享给朋友
            var logoimg = "<%=VIPWebPath %>res/img/StylishMen/ImgLink.jpg";
            wx.onMenuShareAppMessage({
                title: "利郎《我是型男》全国海选火热开启，报名通道抢先get~", // 分享标题                
                imgUrl: logoimg,
                desc: '态度人生，为自己标榜，猛戳开启个人新舞台',
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
                title: "利郎《我是型男》全国海选火热开启，报名通道抢先get~", // 分享标题
                imgUrl: logoimg,
                desc: '态度人生，为自己标榜，猛戳开启个人新舞台',
                link: window.location.href, // 分享链接                    
                success: function () {
                    // 用户确认分享后执行的回调函数                         
                },
                cancel: function () {
                    // 用户取消分享后执行的回调函数
                }
            });
            //判断是不是wifi如果是则自动播放，否则提示            
        		
				        wx.getNetworkType({
								    success: function (res) {
								        var networkType = res.networkType; // 返回网络类型2g，3g，4g，wifi
								        if(res.networkType=="wifi"){
								            setTimeout(function () {
                                                    //不自动播放
								        			//document.getElementById("video1").play();								        		
								        	},1000);
								        	return;
								        }
						        		var isknow = getItem("isknow");
    										if(isknow == "" || isknow==null){			        	
								            swal({
								                title: "-提示-",
								                text: "您当前处于非WIFI状态，播放视频将会消耗您大量流量！",
								                type: "warning",
								                showCancelButton: true,
								                confirmButtonColor: "#DD6B55",
								                confirmButtonText: "了解！",
								                cancelButtonText: "不再提示",
								                closeOnConfirm: true
								            },
								            function (isConfirm) {
								                if (isConfirm) {
								                    //确定
								        						//document.getElementById("video1").play();
								        						setItem("isknow","");
								                }else {
								        						setItem("isknow","1");
								                }
								            });	   
								        } 
								    }
								});
        });
        wx.error(function (res) {
            //alert("JS注入失败！");
        });
    }

    $(document).ready(function () {
        $(".dqArea").find("span:nth-child(2)").html(AreaName);
        wxConfig(); //微信接口注入
        SetSelArea();

        $("#SelectName").on("keydown", function (e) {
            console.log(e);
            if (e.keyCode == 13) {
                SetSelect();
            }
        });

        $(".videoPanel").find("div").each(function () {
            $(this).css("background-image", "url(http://lilanz.oss-cn-fujian-a.aliyuncs.com/StylishMen/VideoFace" + $(this).attr("data-videoid") + ".jpg)");
        });

        $(".videoPanel").find("div").on("click", function () {
            $("#video1").attr("poster", "http://lilanz.oss-cn-fujian-a.aliyuncs.com/StylishMen/VideoFace" + $(this).attr("data-videoid") + ".jpg");
            $("#video1").find("source").attr("src", "http://lilanz.oss-cn-fujian-a.aliyuncs.com/StylishMen/" + $(this).attr("data-videoid") + ".mp4");
            $("#video1").attr("src", "http://lilanz.oss-cn-fujian-a.aliyuncs.com/StylishMen/" + $(this).attr("data-videoid") + ".mp4");
            var title = $(this).attr("data-title");
            if (title != "") title = "当前播放：" + title;
            else title = "当前播放：" + $(this).find("span").html();

            $(".videoTitle").html(title);
        });

        if (AreaID == "") {
            //$(".SelectArea").show();
            $(".dqArea").hide();
            $(".searchPanel").hide();
        } else {
            $(".NotArea").hide();
            $(".searchPanel").show();
            $("#selProvinces").val(AreaSf);
            SetSelArea();
        }

        //        $(".panel").show();

        //加载选手列表
        $.ajax({
            type: "POST",
            url: "api.ashx?ctrl=LoadList",
            data: { AreaID: AreaID },
            timeout: 30000,
            error: function (XMLHttpRequest, textStatus, errorThrown) {
                swal({ title: "-失败-", text: "获取选手列表信息出错！！！", type: "warning", html: true });
                $(".panel").html("系统繁忙...，请稍后重试！");
            },
            success: function (result) {
                var data = eval("(" + result + ")");
                if (data.errcode == "0") {
                    $(".panel").html(template('panel-temp', data));
                    //给每个选手添加点击事件
                    $(".imgPanel").on("click", SetClickImgPanel);
                } else {
                    $(".panel").html("");
                }
            }
        });
    });

    function SetXg() {
        $("#qrBtn").attr("onclick", "gotoArea(1)");
        $(".show_zz").toggle();
    }

    function gotoArea(bs) {
        //alert($("#selArea").val());
        if ($("#selProvinces").val() == "" || $("#selArea").val() == "") {
            swal({title:"-失败-",text: "请选择赛区!",type: "warning",html: true });
            return;
        }
        if (bs == 1) {
            setItem("AreaID", $("#selArea").val());
            window.location.href = "List.aspx?aid=" + $("#selArea").val();
        } else {
            var selArea = "";
            if ($("#selArea").val() != null && $("#selArea").val() != "") selArea = $("#selArea").val();
            else if (AreaID != "") selArea = AreaID;
            window.location.href = 'VotedSort.aspx?AreaID=' + selArea;
        }
    }

    function SetSelArea() {
        if ($("#selProvinces").val() == "") return;
        $.ajax({
            type: "POST",
            url: "List.aspx",
            data: { selProvinces: escape($("#selProvinces").val()), aid: AreaID },
            timeout: 30000,
            error: function (XMLHttpRequest, textStatus, errorThrown) {
                swal({ title: "-失败-", text: "获取区域出错!", type: "warning", html: true });
            },
            success: function (result) {
                $("#selArea").html(result);
                $("#selArea").css("visibility", "visible");
            }
        });
    }

    function SetClickImgPanel() {
        var openid = $(this).attr("openid");
        window.location.href = "ShowInfo.aspx?bs=1&mbopenid=" + openid;
    }

    function SetSelect() {
        var obj = $(".imgPanel");
        var dqbh = $("#SelectName").val();
        if (isNaN($("#SelectName").val()) == false) {
            for (var i = 0; i < obj.length; i++) {
                $(obj[i]).css("display", "inline-block");
                if ($(".bh", obj[i]).text().replace("编号:", "") != dqbh && dqbh != "") {
                    $(obj[i]).css("display", "none");
                }
            }
        } else {
            for (var i = 0; i < obj.length; i++) {
                $(obj[i]).css("display", "inline-block");
                if ($(".name", obj[i]).text().indexOf(dqbh) == -1 && dqbh != "") {
                    $(obj[i]).css("display", "none");
                }
            }
        }
    }

    function ToTpList() {
        var selArea = "";
        if ($("#selArea").val() != null && $("#selArea").val() != "") selArea = $("#selArea").val();
        else if (AreaID != "") selArea = AreaID;

        if (selArea == "") {
            //swal("请选择赛区！！！");
            $("#qrBtn").attr("onclick", "gotoArea(0)");
            $(".show_zz").toggle();
            return;
        }
        window.location.href = 'VotedSort.aspx?AreaID=' + selArea;
    }

</script>

</html>
