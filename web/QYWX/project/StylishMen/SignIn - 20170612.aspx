<%@ Page Title="我要报名" Language="C#" AutoEventWireup="true" EnableEventValidation="false" %>

<%@ Import Namespace="nrWebClass" %>
<%@ Import Namespace="System.Data" %>
<%@ Import Namespace="System.Collections.Generic" %>
<%@ Import Namespace="System.Data.SqlClient" %>

<script runat="server">
    string VIPWebPath = clsConfig.GetConfigValue("VIP_WebPath"); 
    public List<string> wxConfig; //微信OPEN_JS 动态生成的调用参数

    //必须在内容页的Load中对Master.SystemID 进行赋值；
    protected void Page_Load(object sender, EventArgs e)
    {
        string ConfigKey = clsConfig.GetConfigValue("CurrentConfigKey");
        if (!Page.IsPostBack)
        {
            if (clsWXHelper.CheckUserAuth(ConfigKey, "openid"))
            {
                wxConfig = clsWXHelper.GetJsApiConfig(ConfigKey);
                DataTable dt;
                string conn = clsWXHelper.GetWxConn();
                using (LiLanzDALForXLM sqlhelper = new LiLanzDALForXLM(conn))
                {
                    List<SqlParameter> para = new List<SqlParameter>();
                    string sql = @"
                        IF EXISTS (SELECT top 1 a.ID FROM dbo.xn_t_SigninUser a WHERE a.wxOpenID=@wxOpenID and a.IsActive=1)
                            SELECT 1 bs
                        ELSE 
                        BEGIN
                            SELECT 0 bs
                        END
                    ";
                    para.Add(new SqlParameter("@wxOpenID", Session["openid"].ToString()));
                    //sql = string.Format(sql, userOpenId, Cname, DPCname, Phone, ISay, MyImgUrl0, MyImgUrl1, mdid);
                    string errorInfo = sqlhelper.ExecuteQuerySecurity(sql, para, out dt);
                    if (errorInfo != "")
                    {
                        clsLocalLoger.WriteError(string.Concat("[我是型男]查询是否已经报名！错误：", errorInfo));
                        Response.End();
                    }
                    if (dt.Rows[0]["bs"].ToString() == "1")
                    {
                        clsSharedHelper.DisponseDataTable(ref dt);
                        Response.Redirect("ShowInfo.aspx?mbopenid=" + Session["openid"].ToString());
                    }
                    clsSharedHelper.DisponseDataTable(ref dt);
                }
                openid.Value = Session["openid"].ToString();
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
            wxConfig = clsWXHelper.GetJsApiConfig(ConfigKey);
            openid.Value = Session["openid"].ToString();
        }
    }

    private void SetProBind()
    {
        string conn = clsWXHelper.GetWxConn();
        DataTable dt;
        string strInfo = "";
        using (LiLanzDALForXLM dal = new LiLanzDALForXLM(conn))
        {
            strInfo = dal.ExecuteQuery("SELECT DISTINCT Provinces FROM xn_t_BaseArea WHERE tzid = 1 ORDER BY Provinces", out dt);
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

    protected void p_onChange(object sender, EventArgs e)
    {
        string conn = clsWXHelper.GetWxConn();
        DataTable dt;
        string strInfo = "";

        string pValue = this.selProvinces.SelectedValue;
        if (string.IsNullOrEmpty(pValue)) return;

        using (LiLanzDALForXLM dal = new LiLanzDALForXLM(conn))
        {
            strInfo = dal.ExecuteQuery(string.Format("SELECT DISTINCT ID,Area FROM xn_t_BaseArea WHERE tzid = 1 AND Provinces='{0}' ORDER BY Area", pValue), out dt);
            if (strInfo != "")
            {
                clsSharedHelper.WriteInfo(clsLocalLoger.logDirectory);
                clsLocalLoger.WriteError(string.Concat("[我是型男]获取区域信息失败！错误：", strInfo));
                return;
            }            
            this.selArea.Items.Clear();
            selArea.Items.Add(new ListItem("请选择..", ""));
            foreach (DataRow dr in dt.Rows)
            {
                selArea.Items.Add(new ListItem(Convert.ToString(dr[1]), Convert.ToString(dr[0])));
            }
            clsSharedHelper.DisponseDataTable(ref dt);
        }
    }
    protected void a_onChange(object sender, EventArgs e)
    {
        string conn = clsWXHelper.GetWxConn();
        DataTable dt;
        string strInfo = "";

        string aValue = this.selArea.SelectedValue;
        if (string.IsNullOrEmpty(aValue)) return;

        using (LiLanzDALForXLM dal = new LiLanzDALForXLM(conn))
        {
            strInfo = dal.ExecuteQuery(string.Format("SELECT DISTINCT mdid,StoreName FROM xn_t_BaseAreaStore WHERE tzid = 1 AND AreaID={0} ORDER BY StoreName", aValue), out dt);
            if (strInfo != "")
            {
                clsLocalLoger.WriteError(string.Concat("[我是型男]获取区域信息失败！错误：", strInfo));
                return;
            }
            this.selStore.Items.Clear();
            selStore.Items.Add(new ListItem("请选择..", ""));
            foreach (DataRow dr in dt.Rows)
            {
                selStore.Items.Add(new ListItem(Convert.ToString(dr[1]), Convert.ToString(dr[0])));
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
    <title>我要报名</title>
    
    <link rel="stylesheet" href="../../res/css/sweet-alert.css"/>

    <script src="../../res/js/jquery.js" type="text/javascript"></script>
    <script src="../../res/js/StoreSaler/LocalResizeIMG.js" type="text/javascript"></script>
    <script src="../../res/js/StoreSaler/mobileBUGFix.mini.js" type="text/javascript"></script>
    <script src="../../res/js/sweet-alert.min.js" type="text/javascript"></script>  
    <script src="../../res/js/StoreSaler/binaryajax.min.js" type="text/javascript"></script>
    <script src="../../res/js/StoreSaler/exif.min.js" type="text/javascript"></script>
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
            margin: 1.5em 0 0.5em 0;
            width: 86%;
            left: 7%;
        }

        .item {
            position: relative;
            width: 86%;
            left: 7%;
            margin-top: 0.5em;
            vertical-align: top;
        }

            .item > span {
                color: #bc9c41;
                display: inline-block;
                width: 50%;
                float: left;
            }

            .item > input {
                border: none;
                background-color: #fff;
                font-size: 1.2em;
                display: inline-block;
                width: 50%;
                color: #fff;
                background-color: #000;
                border: 1px solid #bc9c41;
            }

            .item > textarea {
                font-size: 1.2em;
                height: 2.5em;
                display: inline-block;
                width: 50%;
                color: #fff;
                background-color: #000;
                border: 1px solid #bc9c41;
            }

            .item > select {
                font-size: 1em;
                color: #fff;
                background-color: #000;
                border: 1px solid #bc9c41;
            }

        .select50p {
            width: 50%;
        }

        .select23p {
            width: 23.55%;
        }


        .panel {
            position: relative;
            width: 86%;
            left: 7%;
        }

        .imgPanel {
            position: relative;
            width: 48%;
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
                border: 1px solid #bc9c41;
                background-color: #000; 
                background-size:100%;
                background-repeat:no-repeat;
            }

                .imgPanel > div > span {
                    margin: 0 45%;
                    color: #fff;
                    font-size: 2em;
                    font-weight: 900;
                    line-height: 10rem;
                    position: absolute;
                }

        .remark {
            color: #fff;
            padding: 0.5em 7%;
            text-align: left;
            line-height: 1.4em;
        }

        .btnPanel {
            position: relative;
            margin-top: 0.5em;
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
        .choosefile {
            visibility: hidden;
            position: absolute;
            left: 0;
        }
    </style>
</head>
<body>
    <input type="hidden" id="openid" runat="server" />
    <input type="hidden" id="MyImgUrl0" />
    <input type="hidden" id="MyImgUrl1" />
    <form name="form1" runat="server">
        <img class="titleimg" alt="我要报名" src="../../res/img/StylishMen/SigninTitle.jpg" /> 
        <div class="item">
            <span>选&nbsp;择&nbsp;赛&nbsp;区：</span>
            <asp:DropDownList CssClass="select23p" ID="selProvinces" runat="server" AutoPostBack="true" OnSelectedIndexChanged="p_onChange">
            </asp:DropDownList>
            <asp:DropDownList CssClass="select23p" ID="selArea" runat="server" AutoPostBack="true" OnSelectedIndexChanged="a_onChange">
            </asp:DropDownList>
        </div> 
        <div class="item">
            <span>选&nbsp;择&nbsp;门&nbsp;店：</span>
            <asp:DropDownList CssClass="select50p" ID="selStore" runat="server">
            </asp:DropDownList>
        </div>
        <div class="item">
            <span>参 赛 者 姓 名：</span>
            <input type="text" id="Cname" />
        </div>
        <div class="item">
            <span>搭 配 师 姓 名：</span>
            <input type="text" id="DPCname" />
        </div>
        <div class="item">
            <span>参赛者手机号码：</span>
            <input type="text" id="Phone" />
        </div>
        <div class="item">
            <span>型&nbsp;男&nbsp;宣&nbsp;言：</span>
            <textarea rows="2" id="ISay"></textarea>
        </div>
        <div class="item">
            <span>搭&nbsp;配&nbsp;理&nbsp;念：</span>
            <textarea rows="2" id="Idea"></textarea>
        </div>
                
        <div class="panel">
            <div class="imgPanel" onclick="choosefile('0')">
                <span>参赛形象照</span>
                <div id="img0"><span>+</span></div>
            </div>
            <div class="imgPanel" onclick="choosefile('1')">
                <span>搭配师工作照</span>
                <div id="img1"><span>+</span></div>
            </div>
            <input type="file" class="choosefile" id="choosefile0" />
            <input type="file" class="choosefile" id="choosefile1" />            
        </div>
        <p class="remark">注：图片清晰可见，严禁盗图行为，报名信息审核时间在1个工作日内。</p>

        <div class="btnPanel">
            <img alt="提交信息" src="../../res/img/StylishMen/btnSubmit.jpg" onclick="javascript:SetShow();" />
            <img alt="关闭" src="../../res/img/StylishMen/btnClose.jpg" onclick="javascript:SetClose();" />
        </div>
    </form>
    <p class="copyright">&copy;2017 利郎（中国）有限公司</p> 
    
    <script type="text/javascript">
        var appIdVal = "<%=wxConfig[0]%>", timestampVal = "<%=wxConfig[1]%>", nonceStrVal = "<%=wxConfig[2]%>", signatureVal = "<%=wxConfig[3]%>";

        var oRotate = 0;
        $(document).ready(function () {
            InitIMGLoad("0");
            InitIMGLoad("1");

            wxConfig(); //微信接口注入

            $("#selProvinces").change(function () {
                $("#selProvinces").submit();
            });
        });

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
                    title: "参加《我是型男》", // 分享标题                
                    imgUrl: "<%=VIPWebPath %>res/img/StylishMen/ImgLink.jpg",
                    desc: '快来报名参加利郎-《我是型男》，丰富奖品等你来挑战！',
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
                    title: "参加《我是型男》", // 分享标题
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
         
        //获取字符串的字节数
        function lenReg(str) {
            return str.replace(/[^x00-xFF]/g, '**').length;
        }

        //提交信息
        function SetShow() {
            //var mdid = "1910";
            //var Cname = "1";
            //var DPCname = "1";
            //var Phone = "11111111111";
            //var ISay = "1";
            //var MyImgUrl0 = "1";
            //var MyImgUrl1 = "1";
            var mbopenid = $("#openid").val();
            var mdid = $("#selStore").val();
            var Cname = $("#Cname").val();
            var DPCname = $("#DPCname").val();
            var Phone = $("#Phone").val();
            var ISay = $("#ISay").val();
            var Idea = $("#Idea").val();
            var MyImgUrl0 = $("#MyImgUrl0").val();
            var MyImgUrl1 = $("#MyImgUrl1").val();
            if (mdid == "" || mdid == null) { swal({title:"-失败-",text:"请选择门店！",type: "warning",html: true }); return; }
            else if (Cname == "") { swal({title:"-失败-",text:"请输入参赛者姓名！",type: "warning",html: true }); return; }
            else if (lenReg(Cname) > 50) { swal({title:"-失败-",text:"参赛者姓名不能超过50个字符，请重输！",type: "warning",html: true });  return; }
            else if (DPCname == "") { swal({title:"-失败-",text:"请输入搭配师姓名！",type: "warning",html: true }); return; }
            else if (lenReg(DPCname) > 50) { swal({title:"-失败-",text:"搭配师姓名不能超过50个字符，请重输！",type: "warning",html: true }); return; }
            else if (Phone == "") { swal({title:"-失败-",text:"请输入参赛者手机号码！",type: "warning",html: true }); return; }
            else if (lenReg(Phone) > 11) { swal({title:"-失败-",text:"参赛者手机号码不能超过11个字符，请重输！",type: "warning",html: true }); return; }
            else if (ISay == "") { swal({title:"-失败-",text:"请输入型男宣言！",type: "warning",html: true }); return; }
            else if (lenReg(ISay) > 72) { swal({title:"-失败-",text:"型男宣言不能超过72个字符，请重输！",type: "warning",html: true }); return; }
            else if (Idea == "") { swal({title:"-失败-",text:"请输入搭配理念！",type: "warning",html: true });  return; }
            else if (lenReg(Idea) > 72) { swal({title:"-失败-",text:"搭配理念不能超过72个字符，请重输！",type: "warning",html: true }); return; }
            else if (MyImgUrl0 == "") { swal({title:"-失败-",text:"请先上传参赛形象照！",type: "warning",html: true }); return; }
            else if (MyImgUrl1 == "") { swal({title:"-失败-",text:"请先上传搭配师工作照",type: "warning",html: true }); return; }

            $.ajax({
                type: "POST",
                url: "api.ashx?ctrl=Submit",
                data: { mdid: escape(mdid), Cname: escape(Cname), DPCname: escape(DPCname), Phone: escape(Phone), ISay: escape(ISay), Idea: escape(Idea), MyImgUrl0: escape(MyImgUrl0), MyImgUrl1: escape(MyImgUrl1) },
                timeout: 30000,
                error: function (XMLHttpRequest, textStatus, errorThrown) {
                    swal({title:"-出错-",text: "保存出错！",type: "warning",html: true });
                },
                success: function (result) {
                    var obj = eval("(" + result + ")");
                    if (obj.errcode == "0") {
                        //swal(obj.errmsg);
                        window.location.href = "ShowInfo.aspx?bs=0&mbopenid=" + mbopenid;
                    } else if (obj.errcode == "12") {
                        swal({ title: "-报名失败-", text: obj.errmsg, type: "warning", html: true });
                        //window.location.href = "SignIn.aspx";
                    }else {
                        swal({ title: "-报名失败-", text: obj.errmsg, type: "warning", html: true });
                    }
                }
            });
        }

        //关闭
        function SetClose() {
            if (window.history.length == 1) wx.closeWindow();
            window.history.go(-1);
        }

        function SetYlImg(url) {
            wx.previewImage({
                current: url, // 当前显示图片的http链接
                urls: [url] // 需要预览的图片http链接列表
            });
        }
        

        //关闭提示层
        function dialog_default(val) {
            $("#dialog" + val).hide();
        }

        //弹出有确定和取消的提示层
        function SetIsTs(bs) {
            event.stopPropagation();
            swal({
                title: "重新上传Or预览？",
                text: "",
                type: "warning",
                showCancelButton: true,
                confirmButtonColor: "#DD6B55",
                confirmButtonText: "重传",
                cancelButtonText: "放大",
                closeOnConfirm: true
            },
            function (isConfirm) {
                if (isConfirm) {
                    //重新上传                    
                    $("#choosefile" + bs).click();
                } else {
                    //放大
                    var url = "<%=VIPWebPath%>" + $("#img" + bs).attr("data-url");
                    url = url.replace("/my/", "/"); 
                    SetYlImg(url);
                }
            });  
        }
         
        function InitIMGLoad(objIndex) {
            //{大对象 有方法有属性} 图片上传
            $("input[id=choosefile" + objIndex + "]").localResizeIMG({
                width: 750,
                quality: 1,
                before: function (that, blob) {
                    var filePath = $("#choosefile" + objIndex).val();
                    var extStart = filePath.lastIndexOf(".");
                    var ext = filePath.substring(extStart, filePath.length).toUpperCase();
                    if (ext != ".BMP" && ext != ".PNG" && ext != ".GIF" && ext != ".JPG" && ext != ".JPEG") {
                        swal({title:"-错误-",text:"只能上传图片哦~",type: "warning",html: true });
                        return false;
                    }
                    var orientation = 0;
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
                    $.ajax({
                        type: "POST",
                        url: "api.ashx?ctrl=UploadImg&rotate=" + oRotate,
                        data: { formFile: result.clearBase64 },
                        timeout: 30000,
                        error: function (XMLHttpRequest, textStatus, errorThrown) {
                        		swal({title:"-失败-",text:"上传失败~",type: "warning",html: true });
                        },
                        success: function (result) {
                            var obj = eval("(" + result + ")");
                            if (obj.errcode == "0") {
                                var $imgobj = $("#img" + objIndex);
                                $imgobj.css("background-image", "url('../../" + obj.path + "')");
                                $imgobj.attr("data-url", obj.path); 
                                $imgobj.find("span").css("display", "none");
                                $imgobj.attr("onclick", "SetIsTs(" + objIndex + ")");
                                $("#MyImgUrl" + objIndex).val("../../" + obj.path);
                            } else {
				                        swal({title:"-上传成功-",text:result,type: "success",html: true }, function(){ 
				                        }); 
                            }
                        }
                    });
                }
            });
        }

        function choosefile(objIndex) {
            $("#choosefile" + objIndex).click();
        } 
    </script>
</body>
</html>
