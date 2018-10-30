<%@ Page Title="销售神器" Language="C#" MasterPageFile="../../WebBLL/frmQQDBase.Master"
    AutoEventWireup="true" %>

<%@ MasterType VirtualPath="../../WebBLL/frmQQDBase.Master" %>
<%@ Import Namespace="System.Collections" %>
<%@ Import Namespace="System.Collections.Generic" %>
<%@ Import Namespace="nrWebClass" %>
<%@ Import Namespace="System.Data" %>
<script runat="server">

    public string strCname = "";
    public string strStar = "1";
    public string strFace = "";
    public string strGwmc = "";
    public string SystemKey = "";
    public string OA_WebPath = "";
    public string mdid = ""; 

    public string showAdmin = "none", managerStore = "";
    protected void Page_PreRender(object sender, EventArgs e)
    {
        if (!this.IsPostBack)
        {
            mdid = Convert.ToString(Session["mdid"]);

            string customersid = Convert.ToString(Session["qy_customersid"]);
            SystemKey = this.Master.AppSystemKey;
            string RoleID = Convert.ToString(Session["RoleID"]);
            OA_WebPath = clsConfig.GetConfigValue("OA_WebPath");
                         
            if (RoleID == null || RoleID == "")
            {
                clsWXHelper.ShowError("无法获取用户角色身份！");
                return;
            }

            string strInfo = "";
            string connectstring = clsWXHelper.GetWxConn();

            using (LiLanzDALForXLM dal = new LiLanzDALForXLM(connectstring))
            {
                //获取店员头像
                DataTable dt = new DataTable();
                string strSQL = string.Concat(@"SELECT TOP 1 cname,avatar,mobile,email FROM wx_t_customers  WHERE id=", customersid);
                strInfo = dal.ExecuteQuery(strSQL, out dt);
                if (strInfo == "")
                {
                    if (dt.Rows.Count > 0)
                    {
                        managerStore = Convert.ToString(Session["ManagerStore"]);
                        string roleName = Convert.ToString(Session["RoleName"]);
                        if (managerStore != "")
                            showAdmin = "block";
                        else if (roleName == "zb" || roleName == "my" || roleName == "kf")
                            Response.Redirect("managerNav.aspx");
                        
                        strCname = Convert.ToString(dt.Rows[0]["cname"]);
                        strFace = Convert.ToString(dt.Rows[0]["avatar"]) == "" ? "res/img/storesaler/defaulticon2.png" : Convert.ToString(dt.Rows[0]["avatar"]);
                        //strMobile = Convert.ToString(dt.Rows[0]["mobile"]);
                        //strEmail = Convert.ToString(dt.Rows[0]["email"]);

                        if (clsWXHelper.IsWxFaceImg(strFace))
                        {
                            strFace = clsWXHelper.GetMiniFace(strFace);
                        }
                        else
                        {
                            strFace = OA_WebPath + strFace;
                        }
                        dt.Clear(); dt.Dispose();

                        //获取岗位，以便加载菜单
                        strSQL = string.Concat(@"SELECT TOP 1 OCU.NickName cname,B.mc,CAST(isnull(C.dm,0) as int)+1 as star 
                                    FROM wx_t_OmniChannelUser OCU INNER JOIN rs_t_Rydwzl A ON OCU.relateID = A.id 
                                    INNER JOIN rs_t_gwdmb B ON  A.gw = B.id LEFT OUTER JOIN dm_t_xzjbb C on A.zd = C.id 
                                    where OCU.ID=", SystemKey);
                        strInfo = dal.ExecuteQuery(strSQL, out dt);
                        if (strInfo == "")
                        {
                            if (dt.Rows.Count > 0)
                            {
                                strCname = Convert.ToString(dt.Rows[0]["cname"]);
                                strGwmc = Convert.ToString(dt.Rows[0]["mc"]);
                                int intStar = Convert.ToInt32(dt.Rows[0]["star"]);
                                if (intStar < 2) intStar = 2;
                                else if (intStar > 5) intStar = 5;
                                
                                strStar = intStar.ToString();  
                            }
                            dt.Clear(); dt.Dispose();
                        }
                        else
                        {
                            clsSharedHelper.WriteErrorInfo("获取岗位信息时发生错误！错误：" + strInfo);
                        }

                        try
                        {
                            wechat.UserMenu wx = new wechat.UserMenu();
                            Repeater1.DataSource = wx.MenuByRole(Convert.ToInt32(RoleID));
                            Repeater1.DataBind();
                        }
                        catch (Exception ex)
                        {
                            clsLocalLoger.WriteError(string.Concat("菜单初始化失败！错误：", ex.Message));
                        }
                    }
                    else
                    {
                        clsSharedHelper.WriteErrorInfo("获取个人信息失败！");
                    }
                    dt.Clear(); dt.Dispose(); dt = null;
                }
                else
                {
                    clsSharedHelper.WriteErrorInfo("获取个人信息时发生错误！错误：" + strInfo);
                }
            }
        }
    }

</script>
<asp:Content ID="Content1" ContentPlaceHolderID="head" runat="server">
    <title>销售神器</title>
    <meta name="format-detection" content="telephone=no" />
    <link type="text/css" rel="stylesheet" href="../../res/css/font-awesome.min.css" />
    <style type="text/css">
        * {
            padding: 0;
            margin: 0;
        }

        body {
            font-family: Helvetica,Arial, "Hiragino Sans GB", "Microsoft Yahei", "微软雅黑",STHeiti, "华文细黑",sans-serif;
            font-size: 14px;
            background-color: #f0f0f0;
        }

        .container {
            max-width: 620px;
            margin: 0 auto;
            overflow-x: hidden;
            /*bottom: initial;*/
        }

        .top {
            width: 100%;
            height: 90px;
            background-image: linear-gradient(90deg,#141414,#272727);
            background-image: -webkit-linear-gradient(90deg,#141414,#272727);
            position: fixed;
            top: 0;
            left: 0;
            border-bottom: 1px solid #cbcbcb;
            padding: 12px 0px 12px 20px;
            box-sizing: border-box;
            color: #fff;
            overflow: hidden;
            z-index: 300;
        }

            .top div {
                float: left;
            }

        .headimg {
            width: 60px;
            height: 60px;
            border: 2px solid #ebebeb;
            border-radius: 50%;
            -webkit-border-radius: 50%;
            background-size: cover;
            background-position: 50% 50%;
            background-repeat: no-repeat;
        }

        .top img {
            width: auto;
            height: 30px;
        }

        .userinfo {
            margin-left: 15px;
            height: 64px;
            line-height: 23px;
            border-left: 2px solid #fff;
            padding-left: 15px;
        }

        .wxnick {
            font-size: 1.2em;
            line-height: 32px;
        }

        .wxnums {
            font-size: 1em;
            white-space: nowrap;
            text-overflow: ellipsis;
            overflow: hidden;
            line-height: 20px;
        }

        .floatfix:after {
            content: "";
            display: table;
            clear: both;
        }

        .icons {
            position: absolute;
            top: 80px;
            bottom: 70px;
            width: 100%;
            /*margin-top: 80px;
            margin-bottom: 75px;*/
            padding: 0 10px 50px 10px;
            box-sizing: border-box;
            overflow-y: auto;
            -webkit-overflow-scrolling: touch;
            overflow-scrolling: touch;
        }

        .rows {
            position: relative;
            list-style: none;
            color: #808080;
            font-size: 1.1em;
        }

            .rows li {
                position: relative;
                width: 33.3333%;
                float: left;
                text-align: center;
                cursor: pointer;
                font-size: 0.9em;
                margin-top: 30px;
            }

                .rows li img {
                    width: 35%;
                    height: auto;
                }

        .bottomnav {
            height: 60px;
            background-color: #f8f8f8;
            width: 100%;
            position: fixed;
            bottom: 0;
            left: 0;
            border-top: 1px solid #cbcbcb;
        }

        .navul {
            list-style: none;
            padding: 10px 0;
            box-sizing: border-box;
        }

            .navul li {
                width: 25%;
                float: left;
                text-align: center;
                height: 40px;
                color: #989898;
                cursor: pointer;
            }

            .navul i {
                display: block;
                font-size: 1.5em;
            }

            .navul p {
                font-weight: 400;
                font-size: 1em;
                line-height: 24px;
            }

        #selected {
            color: #272b2e;
        }

        .rightset {
            position: absolute;
            right: 0;
            top: 0;
            font-size: 1.8em;
            line-height: 90px;
            vertical-align: middle;
            padding: 0 10px;
        }

        .cube3d {
            -webkit-transform: translateZ(0);
            -moz-transform: translateZ(0);
            -ms-transform: translateZ(0);
            -o-transform: translateZ(0);
            transform: translateZ(0);
        }

        /*loader css*/
        .mask, #mask2 {
            color: #fff;
            position: absolute;
            top: 0;
            bottom: 0;
            left: 0;
            right: 0;
            z-index: 1000;
            font-size: 1em;
            text-align: center;
            display: none;
            background-color: rgba(0,0,0,0.3);
        }

        #mask2 {
            position: fixed;
            z-index: 200;
        }

        .qrmask {
            position: absolute;
            top: 0;
            left: 0;
            width: 100%;
            height: 100%;
            z-index: 999;
            background: #2d3132;
            display: none;
        }

        .loader {
            position: absolute;
            top: 50%;
            left: 50%;
            transform: translate(-50%,-50%);
            -webkit-transform: translate(-50%,-50%);
            background-color: #272b2e;
            padding: 15px;
            border-radius: 5px;
            box-sizing: border-box;
            box-shadow: 0px 0px 1px #555;
        }

        #loadtext {
            margin-top: 5px;
            font-weight: bold;
        }

        .gray {
            -webkit-filter: grayscale(100%);
            filter: grayscale(100%);
            filter: gray;
        }

        .qrcon {
            background: #fff;
            border-radius: 4px;
            width: 80%;
            margin: 0 auto;
            position: relative;
            top: 50%;
            margin-top: -195px;
            padding: 20px;
            max-width: 480px;
            box-sizing: border-box;
            overflow: hidden;
        }

            .qrcon .headimg {
                float: left;
                border-radius: 6px;
            }

            .qrcon .wxnick {
                letter-spacing: 0px;
                font-weight: bold;
                margin-left: 74px;
                overflow: hidden;
                white-space: nowrap;
                text-overflow: ellipsis;
            }

            .qrcon img {
                width: 96%;
                height: auto;
                max-width: 240px;
            }

        .area {
            font-size: 14px;
            color: #808080;
            font-weight: normal;
            line-height: 40px;
        }

        .qrtxt {
            margin-top: 100px;
            width: 100%;
            text-align: center;
            position: absolute;
            left: 0;
            bottom: 10px;
            color: #808080;
        }

        .wxstar {
            letter-spacing: 2px;
            overflow: hidden;
            line-height: 32px;
        }

        /*编辑用户useEdit*/
        .EditClose {
            position: absolute;
            right: 0;
            top: 0;
            font-size: 1.5em;
            line-height: 50px;
            vertical-align: middle;
            padding: 0 20px;
        }

        .userEdit {
            position: fixed;
            width: 100%;
            top: 0px;
            left: 0;
            box-sizing: border-box; /*margin: 0px;*/
            z-index: 306;
            text-align: center;
            background-color: #fff;
            border-radius: 5px;
            -webkit-transition: -webkit-transform .4s cubic-bezier(.4,.01,.165,.99);
            transition: transform .4s cubic-bezier(.4,.01,.165,.99);
        }

        .page-top {
            top: 0;
            -webkit-transform: translate3d(0, -100%, 0);
            transform: translate3d(0, -100%, 0);
        }

        .textline {
            border-bottom: 1px solid #ecf0f1;
        }

        .title {
            color: #333;
            font-size: 1.4em;
            width: 100%;
            text-align: center;
            margin: 10px auto 10px auto;
            padding-bottom: 5px;
        }

        input {
            display: block;
            -webkit-appearance: none;
            box-sizing: border-box;
            font-size: 16px;
            width: 95%;
            padding: 10px;
            min-height: 45px;
            border: 1px solid #cfd9db;
            background-color: #fff;
            border-radius: 0.25em;
            box-shadow: inset 0 1px 1px rgba(0, 0, 0, 0.08);
            margin: 15px auto;
        }

            input:focus {
                outline: none;
                border-color: #2c97de;
                box-shadow: 0 0 5px rgba(44, 151, 222, 0.2);
            }

        #subBtn {
            width: 95%;
            cursor: pointer;
            margin-top: 20px;
            color: #fff;
            font-size: 18px;
            background-color: #333;
            -webkit-appearance: none;
        }

        .FaceImage {
            margin: 0 auto;
            width: 58px;
            height: 58px;
            border-radius: 50%;
            overflow: hidden;
            border: 2px solid #fff;
            box-shadow: 0px 0px 4px #999;
            background-size: cover;
            background-position: 50% 50%;
            background-repeat: no-repeat;
        }

            .FaceImage img {
                width: 100%;
                height: 100%;
            }

        .info {
            color: #aaa;
            margin: 5px 0px 5px 0px;
            display: block;
            text-align: center;
        }

        .saveinfo {
            display: none;
            text-align: center;
            padding: 10px;
            background-color: #e94b35;
            border-radius: .25em;
            color: #fff;
            margin-top: 15px;
        }

        .starImg {
            display: inline-block;
        }

        .star {
            display: inline-block;
        }

        .admin_model {            
            height: 40px;
            background-color: rgba(0,0,0,.8);
            color: #fff;
            position: fixed;
            bottom: 60px;
            left: 0;
            right:0;
            line-height: 40px;
            font-weight: bold;
            padding: 0 15px 0 45px;
            transition: all 0.2s;
            overflow:hidden;
            white-space:nowrap;
            text-overflow:ellipsis;                   
        }
            .admin_model .fa {
                font-size:20px;  
                position:absolute;
                top:50%;
                left:15px;
                transform:translate(0,-50%);              
            }
    </style>
</asp:Content>
<asp:Content ID="Content2" ContentPlaceHolderID="ContentPlaceHolder1" runat="server">
    <div class="container">
        <div class="top">
            <div class="headimg" id="headimg">
            </div>
            <div class="userinfo">
                <p class="wxnick" id="wxnick">
                    <%= strCname %>(<%= strGwmc%>)
                </p>
                <div class="wxstar">
                    <div class="star">
                        <p style="letter-spacing: 0;">服务星级</p>
                    </div>
                    <div class="starImg">
                        <img src="../../res/img/StoreSaler/star<%= strStar %>.png" />
                    </div>
                </div>
            </div>
            <div class="rightset" onclick="MyEdit()">
                <i class="fa fa-edit"></i>
            </div>
        </div>
        <div class="icons">
            <ul class="rows floatfix">
                <asp:Repeater ID="Repeater1" runat="server">
                    <ItemTemplate>
                        <li onclick="menuJump(this)" target="<%#Eval( "Url ")%>">
                            <img src="../../res/img<%#Eval( "Icon ")%>" />
                            <p>
                                <%#Eval( "Cname ")%>
                            </p>
                        </li>
                    </ItemTemplate>
                </asp:Repeater>
            </ul>
        </div>
        <div class="userEdit page-top">
            <div>
                <p class="title textline">
                    个人信息编辑
                </p>
                <div class="EditClose" onclick="MyClose()">
                    <i class="fa fa-close"></i>
                </div>
            </div>
            <div class="FaceImage" onclick="ChooseFaceImg()">
                <%--<img width="70" height="70" src="<%= strFace %>" />--%>
            </div>
            <p class="info">
                单击头像可进行更换!
            </p>
            <input id="txtNickname" class="username" type="text" placeholder="昵称" value="<%= strCname %>" />
            <div class="saveinfo">
            </div>
            <input type="button" id="subBtn" class="disabled" value="保  存" onclick="saveNickname()" />
            <div id="filebox" hidden="hidden">
                <input type="file" id="choosefile" />
            </div>
        </div>
        <div class="bottomnav" id="bot_nav">
            <ul class="navul floatfix">
                <li onclick="switchMenu(0)"><i class="fa fa-comments"></i>
                    <p>
                        消 息
                    </p>
                </li>
                <li onclick="switchMenu(1)"><i class="fa fa-users"></i>
                    <p>
                        客 户
                    </p>
                </li>
                <li onclick="switchMenu(2)"><i class="fa fa-retweet"></i>
                    <p>
                        引 流
                    </p>
                </li>
                <li onclick="switchMenu(3)" id="selected"><i class="fa fa-user"></i>
                    <p>
                        我 的
                    </p>
                </li>
            </ul>
        </div>
    </div>
    <div class="mask">
        <div class="loader">
            <div>
                <i class="fa fa-2x fa-warning (alias)"></i>
            </div>
            <p id="loadtext">
                正在开发中...
            </p>
        </div>
    </div>
    <div id="mask2" onclick="MyClose()">
    </div>
    <div class="qrmask">
    </div>
    <!--管理模式的切换-->
    <div class="admin_model" style="display:<%=showAdmin%>"  onclick="switchAdmin()">
        <i class="fa fa-flag"></i>
        <span>|</span>
        <span style="text-decoration:underline;">当前管理：【<%=managerStore %>】</span>
    </div>
    <script type="text/javascript" src="../../res/js/jquery.js"></script>
    <script type='text/javascript' src='../../res/js/StoreSaler/fastclick.min.js'></script>
    <script type="text/javascript" src="../../res/js/StoreSaler/LocalResizeIMG.js"></script>
    <script type="text/javascript" src="../../res/js/StoreSaler/mobileBUGFix.mini.js"></script>
    <script src="../../res/js/StoreSaler/binaryajax.min.js"></script>
    <script src="../../res/js/StoreSaler/exif.min.js"></script>
    <script type="text/javascript" src="../../res/js/LeeJSUtils.min.js"></script>
    <script type="text/javascript" src="../../res/js/jweixin-1.0.0.js"></script>
    <script type="text/javascript"> 

        $(function () { 
            $(".FaceImage").css("background-image", "url(<%= strFace %>)");
            $("#headimg").css("background-image", "url(<%= strFace %>)");
            FastClick.attach(document.getElementById("bot_nav"));
            LeeJSUtils.stopOutOfPage(".icons", true);
            LeeJSUtils.stopOutOfPage(".top", false);
            LeeJSUtils.stopOutOfPage(".bottomnav", false);
        });

        /*点击头像onclick*/
        function ChooseFaceImg() {
            document.getElementById("choosefile").click();
        }
        var oRotate = 0;
        $("input:file").localResizeIMG({
            width: 500,
            quality: 1,
            before: function (that, blob) {
                showLoader("loading", "正在上传头像...");
                var filePath = $("#choosefile").val();
                var extStart = filePath.lastIndexOf(".");
                var ext = filePath.substring(extStart, filePath.length).toUpperCase();
                if (ext != ".BMP" && ext != ".PNG" && ext != ".GIF" && ext != ".JPG" && ext != ".JPEG") {
                    showLoader("warn", "只能上传图片");
                    setTimeout(function () {
                        $(".mask").hide();
                    }, 1000);
                    return false;
                }

                var imgfile = that.files[0];
                fr = new FileReader;
                fr.readAsBinaryString(imgfile);
                fr.onloadend = function () {
                    var exif = EXIF.readFromBinaryFile(new BinaryFile(this.result));
                    if (exif.Orientation == undefined)
                        oRotate = 0;
                    else
                        oRotate = exif.Orientation;
                };
                return true;
            },
            success: function (result) {
                //alert(oRotate);
                var img = new Image();
                img.width = $(".FaceImage").width();
                img.src = result.base64;
                //alert(img.src);
                //alert(result.clearBase64);
                $.ajax({
                    url: "../../WebBLL/UserCenterCore.aspx?ctrl=saveFaceImage&rotate=" + oRotate,
                    type: "POST",
                    data: { formFile: result.clearBase64 },
                    dataType: "HTML",
                    timeout: 30000,
                    error: function (XMLHttpRequest, textStatus, errorThrown) {
                        showLoader("error", "图片上传失败");
                        setTimeout(function () {
                            $(".mask").hide();
                        }, 1000);
                    },
                    success: function (result) {
                        if (result.indexOf("error:") > -1) {
                            showLoader("error", result.replace("error:", ""));
                            setTimeout(function () {
                                $(".mask").hide();
                            }, 1000);
                        } else {
                            var image = "url(../../" + result + ")";
                            //$(".FaceImage img").attr("src", img.src);
                            $(".FaceImage").css("background-image", image);
                            $("#headimg").css("background-image", image);
                            showLoader("successed", "头像更换成功");
                        }
                    }
                });
            }

        });

        /*保存昵称onclick*/
        function saveNickname() {
            var SystemKey = "<%=SystemKey %>";
            var nickname = $("#txtNickname").val();
            if (nickname == "") {
                showLoader("warn", "请输入昵称!");
                setTimeout(function () {
                    $(".mask").hide();
                }, 1000);
                return;
            }
            //alert(nickname);
            $("#subBtn").css("background-color", "#999");
            $("#subBtn").attr("disabled", "disabled");
            $.ajax({
                url: "../../WebBLL/UserCenterCore.aspx?ctrl=saveNickname",
                type: "POST",
                data: { nickname: escape(nickname), SystemKey: SystemKey },
                dataType: "HTML",
                timeout: 30000,
                error: function (XMLHttpRequest, textStatus, errorThrown) {
                    showLoader("error", "昵称保存失败");
                    setTimeout(function () {
                        $(".mask").hide();
                    }, 1000);
                },
                success: function (result) {
                    if (result.indexOf("error:") > -1) {
                        showLoader("error", result.replace("error:", ""));
                        setTimeout(function () {
                            $(".mask").hide();
                        }, 1000);
                        $("#subBtn").css("background-color", "#333");
                        $("#subBtn").removeAttr("disabled");
                    } else {
                        showLoader("successed", "保存成功");
                        $("#wxnick").text(nickname + "(<%= strGwmc%>)");
                        $("#subBtn").css("background-color", "#333");
                        $("#subBtn").removeAttr("disabled");
                    }
                }
            });
        }

        /*编辑click*/
        function MyEdit() {
            $(".userEdit").removeClass("page-top");
            $("#mask2").show();
        }
        /*关闭onclick*/
        function MyClose() {
            $(".userEdit").addClass("page-top");
            $("#mask2").hide();
        }

        function ClickScreen() {
            $(".userEdit").addClass("page-top");
            $("#mask2").hide();
        }

        function switchMenu(order) {
            var mdid = "<%= mdid %>";
            if (mdid == "" || mdid == "0") {
                alert("该功能仅提供门店使用！\n(管理者权限可以选择进入具体一家门店)");
                return;
            }

            switch (order) {
                case 0:
                    window.location.href = "ChatList.aspx";
                    break;
                case 1:
                    window.location.href = "NewVipList.aspx";
                    break;
                case 2:
                    window.location.href = "AttractTools.html";
                    break;
                case 3:
                    window.location.href = "#";
                    break;
                default:
                    showLoader("warn", "即将推出,敬请期待!");
                    break;
            }
        }

        function showLoader(type, txt) {
            switch (type) {
                case "loading":
                    $(".mask .fa").removeAttr("class").addClass("fa fa-2x fa-spinner fa-pulse");
                    $("#loadtext").text(txt);
                    $(".mask").show();
                    break;
                case "successed":
                    $(".mask .fa").removeAttr("class").addClass("fa fa-2x fa-check");
                    $("#loadtext").text(txt);
                    $(".mask").show();
                    setTimeout(function () {
                        $(".mask").fadeOut(500);
                    }, 1000);
                    break;
                case "error":
                    $(".mask .fa").removeAttr("class").addClass("fa fa-2x fa-close (alias)");
                    $("#loadtext").text(txt);
                    $(".mask").show();
                    setTimeout(function () {
                        $(".mask").fadeOut(500);
                    }, 1500);
                    break;
                case "warn":
                    $(".mask .fa").removeAttr("class").addClass("fa fa-2x fa-warning (alias)");
                    $("#loadtext").text(txt);
                    $(".mask").show();
                    setTimeout(function () {
                        $(".mask").fadeOut(500);
                    }, 1000);
                    break;
            }
        }

        function menuJump(obj) {
            if ($(obj).attr("target") != "") {
                window.location.href = $(obj).attr("target");
            }
            else {
                showLoader("warn", "即将推出,敬请期待!");
                setTimeout(function () {
                    $(".mask").hide();
                }, 1500);
            }
        }

        $(".qrmask").click(function () {
            $(".qrmask").fadeOut(200);
        });

        function switchAdmin() {
            $.ajax({
                type: "POST",
                timeout: 5000,
                contentType: "application/x-www-form-urlencoded; charset=utf-8",
                url: "managerNavCore.aspx",
                data: { ctrl: "clearSession"},
                success: function (msg) {
                    if (msg == "Successed") {
                        localStorage.removeItem("llmanagerNav_mode");
                        localStorage.removeItem("llmanagerNav_time");
                        window.location.href = "managerNav.aspx";
                    }
                },
                error: function (XMLHttpRequest, textStatus, errorThrown) {
                    LeeJSUtils.showMessage("error", "您的网络有问题..");
                }
            });//end AJAX
        }
    </script>
</asp:Content>
