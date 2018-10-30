<%@ Page Language="C#" %>
<%@ Import Namespace="nrWebClass" %>
<%@ Import Namespace="System.Data" %>
<%@ Import Namespace="System.Data.SqlClient" %>
<%@ Import Namespace="System.Collections.Generic" %>
<%@ Import Namespace="System.IO" %>
<%@ Import Namespace="WebBLL.Core" %>
<!DOCTYPE html>
<script runat="server">  
    string tzid;
    protected void Page_Load(object sender, EventArgs e)
    {
        string url = Request.Url.ToString().ToLower();//转为小写,indexOf 和Replace 对大小写都是敏感的   
        tzid = "1";
          
        if (url.IndexOf("&tlbt") > 0)
        {
            //由于URL中自动加入了tlbt 标题,tlcs个人信息,导至微信JS配置出来错误 ,所以这里要去掉.
            string tlbt = Request.QueryString["tlbt"].ToString();
            string tlcs = Request.QueryString["tlcs"].ToString();
            string newUrl = url.Replace("tlbt=" + tlbt, "").Replace("tlcs=" + tlcs, "");

            Response.Clear();
            //Response.Write(tlcs);
            //Response.End();
            //Response.Write(newUrl);
            //加上用户userid
            Response.Redirect(newUrl + "&userid=" + int.Parse(tlcs.Split('|')[2]));
            Response.End();
        }
        else
        {
            getWxConfig();       
        }        
    }
    //配置参数
    public void getWxConfig()
    {
        List<string> config = clsWXHelper.GetJsApiConfig("1");        
        appIdVal.Value = config[0];
        timestampVal.Value = config[1];
        nonceStrVal.Value = config[2];
        signatureVal.Value = config[3];
        useridVal.Value = clsWXHelper.GetAuthorizedKey(1);
        ScanCtrl.Value = Request.Params["ScanCtrl"];
        
        //useridVal.Value = "33";
        //ScanCtrl.Value = "ypwgqr";       
    }    
</script>
<html lang="en" xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <title></title>
    <meta name="viewport" content="height=device-height,width=device-width,initial-scale=1.0,minimum-scale=1.0,maximum-scale=1.0,user-scalable=no" />
    <meta name="format-detection" content="telephone=yes" />
    <meta http-equiv="Content-Type" content="text/html; charset=UTF-8" />
    <script type="text/javascript" src="../../res/js/jquery.js"></script>
    <script type="text/javascript" src="http://res.wx.qq.com/open/js/jweixin-1.0.0.js"></script>
    <link href="../../res/css/ErpScan/jquery-impromptu.css" rel="stylesheet" type="text/css" />
    <script src="../../res/js/ErpScan/jquery-impromptu.js" type="text/javascript"></script>
    <link rel="stylesheet" href="../../res/css/weui.min.css"/>
    <link rel="stylesheet" href="../../res/css/StoreSaler/weui_example.css"/>
    <script type="text/javascript">    
        var appIdVal, timestampVal, nonceStrVal, signatureVal, userssid, userid, username, scanCtrl, xmjlid, bsid;
        var bcbs = "1",fzid="0",username="",xmjlid="0",bsid="0";
        $(document).ready(function () {
            ShowLoading("摄像头调取中..");
            //WeiXin JSSDK
            appIdVal = document.getElementById("appIdVal").value;
            timestampVal = document.getElementById("timestampVal").value;
            nonceStrVal = document.getElementById("nonceStrVal").value;
            signatureVal = document.getElementById("signatureVal").value;
            userid = document.getElementById("useridVal").value;
            scanCtrl = document.getElementById("ScanCtrl").value;
            if (userid == "" || userid == "0") {
                alert("用户未登陆,不可用"+userid+"...");
            } else {
                jsConfig();
            }
            
        });
        /********************签名**********************/
        function jsConfig() {
            wx.config({
                debug: false,
                appId: appIdVal, // 必填，公众号的唯一标识
                timestamp: timestampVal, // 必填，生成签名的时间戳
                nonceStr: nonceStrVal, // 必填，生成签名的随机串
                signature: signatureVal, // 必填，签名，见附录1
                jsApiList: ['scanQRCode'] // 必填，需要使用的JS接口列表，所有JS接口列表见附录2
            });
            wx.ready(function () {
                scan();
            });
            wx.error(function (res) {
                alert(allPrpos(res));
                alert("JS注入失败！");
            });
        }

        /*
        * 用来遍历指定对象所有的属性名称和值
        * obj 需要遍历的对象
        * author: Jet Mah
        * website: http://www.javatang.com/archives/2006/09/13/442864.html 
        */
        function allPrpos(obj) {
            // 用来保存所有的属性名称和值
            var props = "";
            // 开始遍历
            for (var p in obj) {
                // 方法
                if (typeof (obj[p]) == "function") {
                    obj[p]();
                } else {
                    // p 为属性名称，obj[p]为对应属性的值
                    props += p + "=" + obj[p] + "\t";
                }
            }
            // 最后显示所有的属性
            return props;
        }
        function scan() {
            wx.scanQRCode({
                desc: 'scanQRCode desc',
                needResult: 1, // 默认为0，扫描结果由微信处理，1则直接返回扫描结果，
                scanType: ["qrCode", "barCode"], // 可以指定扫二维码还是一维码，默认二者都有
                success: function (res) {
                    ShowLoading("信息获取中..");
                    var result = res.resultStr; // 当needResult 为 1 时，扫码返回的结果 
                    if (result.indexOf(",") > -1) {
                        result=result.split(",")[1];
                    }
                    var checkInfo = getInfo(result);
                    //console.dir(result);
                    HideLoading();
                }
            });
        };
       
        //显示加载栏目
        function ShowLoading(Info, ShowTime) {
            if (ShowTime == undefined || ShowTime == "undefined") {
                ShowTime = 15;      //默认弹出15s
            };
            $("#LoadingInfo").html(Info);
            var $loadingToast = $('#loadingToast');
            if ($loadingToast.css('display') != 'none') {
                return;
            }

            $loadingToast.show();
            setTimeout(function () {
                $loadingToast.hide();
            }, ShowTime * 1000);
        }

        function HideLoading() {
            $('#loadingToast').hide();
        }
    </script>
</head>
<body>
    <input type="hidden" runat="server" id="appIdVal" />
    <input type="hidden" runat="server" id="timestampVal" />
    <input type="hidden" runat="server" id="nonceStrVal" />
    <input type="hidden" runat="server" id="signatureVal" />
    <input type="hidden" runat="server" id="useridVal" />
    <input type="hidden" runat="server" id="ScanCtrl" />
    <!-- loading toast -->
    <div id="loadingToast" class="weui_loading_toast" style="display:none; position:fixed; z-index:99999">
        <div class="weui_mask_transparent"></div>
        <div class="weui_toast">
            <div class="weui_loading">
                <div class="weui_loading_leaf weui_loading_leaf_0"></div>
                <div class="weui_loading_leaf weui_loading_leaf_1"></div>
                <div class="weui_loading_leaf weui_loading_leaf_2"></div>
                <div class="weui_loading_leaf weui_loading_leaf_3"></div>
                <div class="weui_loading_leaf weui_loading_leaf_4"></div>
                <div class="weui_loading_leaf weui_loading_leaf_5"></div>
                <div class="weui_loading_leaf weui_loading_leaf_6"></div>
                <div class="weui_loading_leaf weui_loading_leaf_7"></div>
                <div class="weui_loading_leaf weui_loading_leaf_8"></div>
                <div class="weui_loading_leaf weui_loading_leaf_9"></div>
                <div class="weui_loading_leaf weui_loading_leaf_10"></div>
                <div class="weui_loading_leaf weui_loading_leaf_11"></div>
            </div>
            <p class="weui_toast_content" id="LoadingInfo">数据加载中</p>
        </div>
    </div>
</body>
</html>
