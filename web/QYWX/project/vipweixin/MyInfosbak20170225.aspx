<%@ Page Language="C#" %>

<%@ Import Namespace="nrWebClass" %>
<%@ Import Namespace="System.Data" %>
<%@ Import Namespace="System.Data.SqlClient" %>
<%@ Import Namespace="System.Collections.Generic" %>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<script runat="server">
    private String ConfigKeyValue = "5"; //利郎男装
    private string ChatProConnStr = System.Configuration.ConfigurationManager.ConnectionStrings["Conn_4"].ConnectionString;
    //private string DBConnStr = "server='192.168.35.11';uid=ABEASD14AD;pwd=+AuDkDew;database=tlsoft";
    private string DBConnStr = System.Configuration.ConfigurationManager.ConnectionStrings["Conn_1"].ConnectionString;
    public Hashtable VI = new Hashtable();

    protected void Page_Load(object sender, EventArgs e)
    {
        //Session["openid"] = "oarMEt2iR-I_4gr9pu9mY35E2FKo";
        if (clsWXHelper.CheckUserAuth(ConfigKeyValue, "openid"))
        {
            //生成访问日志
            clsWXHelper.WriteLog(string.Format("openid：{0} ，vipid：{1} 。访问功能页[{2}]", Convert.ToString(Session["openid"]), Convert.ToString(Session["vipid"])
                            , "VIP信息详情"));     
                
            using (LiLanzDALForXLM dal = new LiLanzDALForXLM(ChatProConnStr))
            {
                string str_sql = @"select top 1 a.wxnick,case when a.wxsex=1 then '男' else '女' end xb,a.wxcity,a.wxprovince,a.wxheadimgurl,isnull(vip.kh,'--') vipkh,isnull(vip.yddh,'--') phone,
                                    isnull(a.vipid,0)  vipid,isnull(vi.userpoints,0) userpoints,CONVERT(varchar(10),vip.tbrq,120) jointime,isnull(vip.mdid,0) mdid
                                    from wx_t_vipbinging a 
                                    left join yx_t_vipkh vip on a.vipid=vip.id
                                    left join wx_t_vipinfo vi on vi.vipid=a.vipid
                                    where a.wxopenid=@openid";
                List<SqlParameter> paras = new List<SqlParameter>();
                paras.Add(new SqlParameter("@openid", Session["openid"].ToString()));
                DataTable dt = null;
          
                
                
                string errinfo = dal.ExecuteQuerySecurity(str_sql, paras, out dt);
                if (errinfo == "")
                {
                    if (dt.Rows.Count == 0)
                        clsWXHelper.ShowError("对不起，您还未关注利郎男装公众号。");
                    else
                    {
                        if (dt.Rows[0]["vipid"].ToString() == "0" || dt.Rows[0]["vipid"].ToString() == "")
                            clsWXHelper.ShowError("对不起，您还不是利郎会员。");
                        else
                        {
                            string mdid = dt.Rows[0]["mdid"].ToString();
                            if (mdid == "0" || mdid == "")
                                AddHT(VI, "mdmc", "");
                            else
                                AddHT(VI, "mdmc", GetMDMC(mdid));

                            AddHT(VI, "VIP_WebPath", clsConfig.GetConfigValue("VIP_WebPath").ToString());
                            AddHT(VI, "wxnick", dt.Rows[0]["wxnick"].ToString());
                            AddHT(VI, "xb", dt.Rows[0]["xb"].ToString());
                            AddHT(VI, "jointime", dt.Rows[0]["jointime"].ToString());
                            AddHT(VI, "vipkh", dt.Rows[0]["vipkh"].ToString());
                            AddHT(VI, "phone", dt.Rows[0]["phone"].ToString());
                            string headimg = dt.Rows[0]["wxheadimgurl"].ToString().Replace("\\", "");
                            if (clsWXHelper.IsWxFaceImg(headimg))
                            {
                                //是微信头像
                                headimg = clsWXHelper.GetMiniFace(headimg);
                            }
                            else
                            {
                                headimg = clsConfig.GetConfigValue("VIP_WebPath") + headimg;
                            }
                            AddHT(VI, "headimg", headimg);
                            AddHT(VI, "userpoints", dt.Rows[0]["userpoints"].ToString());
                        }
                    }
                }
                else
                    clsWXHelper.ShowError("查询微信用户信息时出错！ " + errinfo);
            }
        }
        else
            clsWXHelper.ShowError("微信鉴权失败！");
    }

    public void AddHT(Hashtable ht, string key, string value)
    {
        if (ht.ContainsKey(key))
            ht.Remove(key);
        ht.Add(key, value);
    }

    public string GetMDMC(string mdid)
    {
        string rt = "--";
        using (LiLanzDALForXLM dal = new LiLanzDALForXLM(DBConnStr))
        {
            string str_sql = "select top 1 mdmc from t_mdb where mdid=@mdid;";
            List<SqlParameter> paras = new List<SqlParameter>();
            paras.Add(new SqlParameter("@mdid", mdid));
            DataTable dt = null;
            string errinfo = dal.ExecuteQuerySecurity(str_sql, paras, out dt);
            if (errinfo == "" && dt.Rows.Count > 0)
                rt = dt.Rows[0]["mdmc"].ToString();
        }

        return rt;
    }
</script>
<html>
<head runat="server">
    <meta charset="utf-8" />
    <meta name="viewport" content="width=device-width,initial-scale=1,user-scalable=0,maximum-scale=1" />
    <meta name="format-detection" content="telephone=no" />
    <meta name="apple-mobile-web-app-capable" content="yes" />
    <meta name="apple-mobile-web-app-status-bar-style" content="black" />
    <title></title>
    <link type="text/css" rel="stylesheet" href="../../res/css/LeePageSlider.css" />
    <link type="text/css" rel="stylesheet" href="../../res/css/font-awesome.min.css" />
    <style type="text/css">
        body {
            background-color: #eee;
            color: #323232;
        }

        .header {
            background-color: #f9f9f9;
            border-bottom: 1px solid #ccc;
            line-height: 50px;
            font-size: 1.3em;
        }

        .fa-angle-left {
            position: absolute;
            top: 0;
            left: 0;
            height: 100%;
            font-size: 1.4em;
            line-height: 50px;
            padding: 0 20px;
        }

            .fa-angle-left:hover {
                background-color: rgba(0,0,0,.1);
            }

        .page {
            background-color: #eee;
            padding: 0;
            z-index: 500;
        }

        .infosul {
            margin-top: 15px;
        }

            .infosul li {
                display: -webkit-box;
                display: -webkit-flex;
                display: flex;
                -webkit-box-align: center;
                padding: 10px 15px;
                font-size: 1.15em;
                color: #414244;
                background-color: #fff;
                border-bottom: 1px solid #e7e7e7;
                position: relative;
            top: 0px;
            left: 0px;
        }

                .infosul li div {
                    text-align: right;
                    -webkit-flex: 1;
                    -webkit-box-flex: 1;
                    flex: 1;
                    color: #808080;
                    white-space: nowrap;
                    overflow: hidden;
                    text-overflow: ellipsis;
                    font-size: 0.9em;
                    position: absolute;
                    width: 100%;
                    top: 50%;
                    right: 0;
                    transform: translate(0,-50%);
                    -webkit-transform: translate(0,-50%);
                    padding: 0 30px 0 45px;
                }

                .infosul li i {
                    position: absolute;
                    top: 49%;
                    right: 15px;
                    transform: translate(0,-50%);
                    -webkit-transform: translate(0,-50%);
                    font-size: 1.3em;
                    color: #808080;
                }

        .headimg {
            width: 60px;
            height: 60px;
            overflow: hidden;
            border-radius: 50%;
            display: inline-block;
            background-size: cover;
            background-position: 50% 50%;
            background-repeat: no-repeat;
            border: 3px solid #eee;
        }

            .headimg img {
                width: 100%;
                height: 100%;
            }

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
            z-index: 600;
            background-color: rgba(0,0,0,0.5);
            z-index: 906;
        }

        .loader {
            position: absolute;
            top: 50%;
            left: 50%;
            margin-top: -43px;
            margin-left: -61px;
            background-color: #272b2e;
            padding: 15px 25px;
            border-radius: 5px;
            box-sizing: border-box;
            box-shadow: 0px 0px 1px #555;
        }

        #loadtext {
            margin-top: 5px;
            font-weight: bold;
        }

        /*编辑用户useEdit*/
        .EditClose {
            position: absolute;
            right: 0;
            top: 0;
            font-size: 1.5em;
            line-height: 100px;
            vertical-align: middle;
            padding: 10px 20px;
        }

        .userEdit {
            width: 94%;
            z-index: 907;
            text-align: center;
            background-color: #fff;
            border-radius: 5px;
            padding-bottom: 10px;
            overflow: hidden;
            height: 190px;
            position: absolute;
            border: 1px solid #e7e7e7;
            top: 50%;
            left: 50%;
            margin-top: -95px;
            display: none;
            /*-webkit-transition: -webkit-transform .4s cubic-bezier(.4,.01,.165,.99);
            transition: transform .4s cubic-bezier(.4,.01,.165,.99);*/
        }

        /*.viewout
        {
            transform: translate3d(100%,0,0);
            -webkit-transform: translate3d(100%,0,0);
            -webkit-transform: translate(100%,0,0);
        }*/

        #FaceImgEdit {
            display: none;
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
            width: 104px;
            height: 104px;
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

        /*animation css*/
        .animated {
            -webkit-animation-duration: 1s;
            animation-duration: 1s;
            -webkit-animation-fill-mode: both;
            animation-fill-mode: both;
        }

        @-webkit-keyframes bounceIn {
            0%,100%,20%,40%,60%,80% {
                -webkit-transition-timing-function: cubic-bezier(0.215,.61,.355,1);
                transition-timing-function: cubic-bezier(0.215,.61,.355,1);
            }

            0% {
                opacity: 0;
                -webkit-transform: scale3d(.3,.3,.3);
                transform: scale3d(.3,.3,.3);
            }

            20% {
                -webkit-transform: scale3d(1.1,1.1,1.1);
                transform: scale3d(1.1,1.1,1.1);
            }

            40% {
                -webkit-transform: scale3d(.9,.9,.9);
                transform: scale3d(.9,.9,.9);
            }

            60% {
                opacity: 1;
                -webkit-transform: scale3d(1.03,1.03,1.03);
                transform: scale3d(1.03,1.03,1.03);
            }

            80% {
                -webkit-transform: scale3d(.97,.97,.97);
                transform: scale3d(.97,.97,.97);
            }

            100% {
                opacity: 1;
                -webkit-transform: scale3d(1,1,1);
                transform: scale3d(1,1,1);
            }
        }

        @keyframes bounceIn {
            0%,100%,20%,40%,60%,80% {
                -webkit-transition-timing-function: cubic-bezier(0.215,.61,.355,1);
                transition-timing-function: cubic-bezier(0.215,.61,.355,1);
            }

            0% {
                opacity: 0;
                -webkit-transform: scale3d(.3,.3,.3);
                -ms-transform: scale3d(.3,.3,.3);
                transform: scale3d(.3,.3,.3);
            }

            20% {
                -webkit-transform: scale3d(1.1,1.1,1.1);
                -ms-transform: scale3d(1.1,1.1,1.1);
                transform: scale3d(1.1,1.1,1.1);
            }

            40% {
                -webkit-transform: scale3d(.9,.9,.9);
                -ms-transform: scale3d(.9,.9,.9);
                transform: scale3d(.9,.9,.9);
            }

            60% {
                opacity: 1;
                -webkit-transform: scale3d(1.03,1.03,1.03);
                -ms-transform: scale3d(1.03,1.03,1.03);
                transform: scale3d(1.03,1.03,1.03);
            }

            80% {
                -webkit-transform: scale3d(.97,.97,.97);
                -ms-transform: scale3d(.97,.97,.97);
                transform: scale3d(.97,.97,.97);
            }

            100% {
                opacity: 1;
                -webkit-transform: scale3d(1,1,1);
                -ms-transform: scale3d(1,1,1);
                transform: scale3d(1,1,1);
            }
        }

        .bounceIn {
            display: block;
            -webkit-animation-name: bounceIn;
            animation-name: bounceIn;
            -webkit-animation-duration: .75s;
            animation-duration: .75s;
        }
    </style>
</head>
<body style="overflow: hidden;">
    <div class="header">
        <i class="fa fa-angle-left" onclick="javascript:history.back(-1);"></i>个人资料
    </div>
    <div class="wrap-page">
        <div class="page page-not-header">
            <ul class="infosul" id="infoslist">
                <li style="height: 70px;" onclick="FaceImgEdit()">
                    <label style="line-height: 50px;">
                        头像</label>
                    <div>
                        <p class="headimg">
                        </p>
                    </div>
                    <i class="fa fa-angle-right"></i></li>
                <li onclick="NicknameEdit()">
                    <label>
                        昵称</label>
                    <div id="wxnick">
                        <%= VI["wxnick"].ToString()%>
                    </div>
                    <i class="fa fa-angle-right"></i></li>
                <li>
                    <label>
                        VIP卡号</label>
                    <div>  
                        <%=VI["vipkh"].ToString()%>                      
                    </div>
                </li>
                <li>
                    <label>
                        性别</label>
                    <div>
                        <%=VI["xb"].ToString()%>
                    </div>
                </li>
                <li>
                    <label>
                       电话</label>
                    <div> 
                        <%=VI["phone"].ToString()%>                        
                    </div>
                </li>
                <li>
                    <label>
                        加入时间</label>
                    <div>
                        <%=VI["jointime"].ToString()%>
                    </div>
                </li>
                <li>
                    <label>
                        积分</label>
                    <div>
                        <%=VI["userpoints"].ToString()%>
                    </div>
                </li>
                <li>
                    <label>
                        所属门店</label>
                    <div>
                        <%=VI["mdmc"].ToString()%>
                    </div>
                </li>
                <li onclick="javascript:window.location.href='VIPCode.aspx'">
                    <label>
                        我的二维码名片
                    </label>
                    <i class="fa fa-angle-right"></i>
                </li>
            </ul>
        </div>
    </div>
    <!-- 用户信息编辑-->
    <div id="userEdit" class="userEdit animated">
        <div>
            <p id="EditTitle" class="title textline">资料编辑</p>
            <div class="EditClose" onclick="MyClose()">
                <i class="fa fa-close"></i>
            </div>
        </div>
        <div id="FaceImgEdit">
            <div class="FaceImage" onclick="ChooseFaceImg()">
                <%--<img src="<%= VI["headimg"].ToString()%>" />--%>
            </div>
            <p class="info">
                单击头像可进行更换!
            </p>
            <div id="filebox" hidden="hidden">
                <input type="file" id="choosefile" />
            </div>
        </div>
        <div id="NicknameEdit">
            <input id="txtNickname" class="username" type="text" placeholder="昵称" value="<%= VI["wxnick"].ToString()%>" />
            <input type="button" id="subBtn" class="disabled" value="保  存" onclick="saveNickname()" />
        </div>
    </div>
    <div class="mask">
        <div class="loader">
            <div>
                <i class="fa fa-2x fa-warning (alias)"></i>
            </div>
            <p id="loadtext">
                正在处理...
            </p>
        </div>
    </div>
    <div id="mask2" onclick="MyClose()">
    </div>
    <script type="text/javascript" src="../../res/js/jquery.js"></script>
    <script type='text/javascript' src='../../res/js/StoreSaler/fastclick.min.js'></script>
    <script type="text/javascript" src="../../res/js/StoreSaler/LocalResizeIMG.js"></script>
    <script type="text/javascript" src="../../res/js/StoreSaler/mobileBUGFix.mini.js"></script>
    <script type="text/javascript" src="../../res/js/StoreSaler/binaryajax.min.js"></script>
    <script type="text/javascript" src="../../res/js/StoreSaler/exif.min.js"></script>

    <script type="text/javascript">
        $(function () {
            $(".headimg").css("background-image", "url(<%=VI["headimg"].ToString() %>)");
            $(".FaceImage").css("background-image", "url(<%=VI["headimg"].ToString() %>)");
            FastClick.attach(document.getElementById("infoslist"));
            FastClick.attach(document.getElementById("mask2"));
            $("#userEdit").css("margin-left", $("#userEdit").width() / 2 * -1 + "px");
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
                var img = new Image();
                img.width = $(".FaceImage").width();
                img.src = result.base64;
                $(".mask").hide();
                $.ajax({
                    url: "../../WebBLL/MyInfosCore.aspx?ctrl=SaveFaceImage&rotate=" + oRotate,
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
                            $(".headimg").css("background-image", image);
                            $(".FaceImage").css("background-image", image);
                            showLoader("successed", "头像更换成功");
                        }
                    }
                });
            }

        });

        /*保存昵称onclick*/
        function saveNickname() {
            var nickname = $("#txtNickname").val();
            if (nickname == "") {
                showLoader("warn", "请输入昵称!");
                setTimeout(function () {
                    $(".mask").hide();
                }, 1000);
                return;
            }
            $("#subBtn").css("background-color", "#999");
            $("#subBtn").attr("disabled", "disabled");
            $.ajax({
                url: "../../WebBLL/MyInfosCore.aspx?ctrl=SaveNickname",
                type: "POST",
                data: { nickname: escape(nickname) },
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
                        $("#wxnick").text(nickname);
                        $("#subBtn").css("background-color", "#333");
                        $("#subBtn").removeAttr("disabled");
                    }
                }
            });
        }



        function FaceImgEdit() {
            $("#mask2").show();
            $("#FaceImgEdit").show();
            $("#NicknameEdit").hide();
            $(".header i").fadeOut(500);
            $("#userEdit").addClass("bounceIn");
        }

        function NicknameEdit() {
            $("#mask2").show();
            $("#FaceImgEdit").hide();
            $("#NicknameEdit").show();
            $(".header i").fadeOut(500);
            $("#userEdit").addClass("bounceIn");
        }

        /*关闭onclick*/
        function MyClose() {
            $(".header i").fadeIn(500);
            $("#userEdit").removeClass("bounceIn");
            $("#mask2").hide();
        }

        //提示层
        function showLoader(type, txt) {
            switch (type) {
                case "loading":
                    $(".mask .fa").removeAttr("class").addClass("fa fa-2x fa-spinner fa-pulse");
                    $("[id$=loadtext]").text(txt);
                    $(".mask").show();
                    break;
                case "successed":
                    $(".mask .fa").removeAttr("class").addClass("fa fa-2x fa-check");
                    $("[id$=loadtext]").text(txt);
                    $(".mask").show();
                    setTimeout(function () {
                        $(".mask").fadeOut(800);
                    }, 1500);
                    break;
                case "error":
                    $(".mask .fa").removeAttr("class").addClass("fa fa-2x fa-close (alias)");
                    $("[id$=loadtext]").text(txt);
                    $(".mask").show();
                    break;
                case "warn":
                    $(".mask .fa").removeAttr("class").addClass("fa fa-2x fa-warning (alias)");
                    $("[id$=loadtext]").text(txt);
                    $(".mask").show();
                    break;
            }
        }
    </script>
</body>
</html>
