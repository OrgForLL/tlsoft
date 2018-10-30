<%@ Page Language="C#" %>

<%@ Import Namespace="nrWebClass" %>
<%@ Import Namespace="System.Data.SqlClient" %>
<%@ Import Namespace="System.Data" %>
<%@ Import Namespace="System.Collections.Generic" %>

<!DOCTYPE html>
<script runat="server">
    private string ConfigKeyValue = "5";//利郎男装
    private string WXDBConstr = "server='192.168.35.62';uid=sa;pwd=ll=8727;database=weChatPromotion";
    private string DBConstr = "server=192.168.35.10;uid=ABEASD14AD;pwd=+AuDkDew;database=tlsoft";
    private string TestDBConstr = "server=192.168.35.23;uid=lllogin;pwd=rw1894tla;database=tlsoft";
    
    Dictionary<string, object> TokenInfos = new Dictionary<string, object>();
    public List<string> wxConfig;//微信OPEN_JS 动态生成的调用参数

    protected void Page_Load(object sender, EventArgs e)
    {
        if (clsWXHelper.CheckUserAuth(ConfigKeyValue, "openid")) {
            string openid = Convert.ToString(Session["openid"]);
            //传入参数wx_t_ActiveToken.id[tid]        
            string tid = Convert.ToString(Request.Params["tid"]);
            if (tid == "" || tid == "0" || tid == null)
                clsWXHelper.ShowError("请检查传入的参数！");
            else
            {
                using (LiLanzDALForXLM dal62 = new LiLanzDALForXLM(WXDBConstr))
                {
                    string str_sql = @"select top 1 activename,tokenname,remark from wx_t_activetoken where id=@tid and isactive=1";
                    List<SqlParameter> paras = new List<SqlParameter>();
                    paras.Add(new SqlParameter("@tid", tid));
                    DataTable dt;
                    string errinfo = dal62.ExecuteQuerySecurity(str_sql, paras, out dt);
                    if (errinfo == "")
                        if (dt.Rows.Count > 0)
                        {
                            TokenInfos.Add("openid", openid);
                            TokenInfos.Add("activename", Convert.ToString(dt.Rows[0]["activename"]));
                            TokenInfos.Add("tokenname", Convert.ToString(dt.Rows[0]["tokenname"]));
                            TokenInfos.Add("remark", Convert.ToString(dt.Rows[0]["remark"]));
                            using (LiLanzDALForXLM dal10 =new LiLanzDALForXLM(DBConstr)) {
                                str_sql = "select top 1 id from wx_t_vipbinging where wxopenid=@openid and objectid=1";
                                
                                paras.Clear();
                                paras.Add(new SqlParameter("@openid",openid));
                                object scalar;
                                errinfo = dal10.ExecuteQueryFastSecurity(str_sql, paras, out scalar);
                                TokenInfos.Add("wxid", Convert.ToString(scalar));
                            }//end using 10
                            
                            wxConfig = clsWXHelper.GetJsApiConfig(ConfigKeyValue);
                            dt.Clear(); dt.Dispose();
                        }
                        else
                            clsWXHelper.ShowError("请检查传入的参数！！");
                    else
                        clsSharedHelper.WriteErrorInfo(errinfo);
                }//end using        
            }
        }
    }
</script>
<html lang="en">
<head runat="server">
    <meta charset="utf-8" />
    <meta name="viewport" content="width=device-width,initial-scale=1,user-scalable=0,maximum-scale=1" />
    <meta name="format-detection" content="telephone=no" />
    <meta name="apple-mobile-web-app-capable" content="yes" />
    <meta name="apple-mobile-web-app-status-bar-style" content="black" />
    <title>利郎男装</title>
    <link type="text/css" rel="stylesheet" href="../../res/css/LeePageSlider.css" />
    <link type="text/css" rel="stylesheet" href="../../res/css/font-awesome.min.css" />
    <style type="text/css">
        body {
            line-height: 1;
            color: #363c44;
        }

        .page {
            background-color: #f2f2f2;
        }

        .content {
            width: 90%;
            background-color: #fff;
            padding: 10px;
            border-radius: 2px;
        }

        .fa-check-circle {
            color: #63b359;
        }

        .fa-times-circle {
            color: #cc463d;
        }

        .fa-spinner {
            color: #ccc;
        }

        .title {
            font-size: 24px;
            font-weight: 600;
            padding: 10px 0 5px 0;
            overflow: hidden;
            white-space: nowrap;
            text-overflow: ellipsis;
        }

        .remark {
            padding-top: 5px;
            color: #aaa;
        }

        .subtitle {
            font-size: 18px;
            font-weight: 600;
            padding: 5px 0;
        }

        .result {
            font-size: 14px;
            font-weight: bold;
            margin: 20px 0 20px 0;
            letter-spacing: 1px;
        }

            .result > span {
                padding: 4px 10px;
                background-color: #63b359;
                color: #fff;
                border-radius: 4px;
            }

            .result[data-status='process'] > span, .page[data-status='process'] {
                background-color: #ccc;
            }

            .result[data-status='success'] > span, .page[data-status='success'] {
                background-color: #63b359;
            }

            .result[data-status='error'] > span, .page[data-status='error'] {
                background-color: #cc463d;
            }

        .brand {
            color: #ccc;
            padding: 5px 0;
        }

        .bot {
            border-top: 1px dashed #ddd;
            padding-top: 10px;
        }

            .bot .btn {
                color: #fff;
                background-color: #e36b2f;
                display: block;
                font-size: 16px;
                height: 40px;
                line-height: 41px;
                text-align: center;
                display:none;
            }

        .failmsg {
            color: #cc463d;
            line-height: 1.6;
            padding: 0 10px;
            display: none;
        }

        .transition {
            transition: all 0.5s ease-in-out;
        }
    </style>
</head>
<body>
    <div class="wrap-page">
        <div class="page transition" id="index" data-status="process">
            <div class="content center-translate">
                <div style="text-align: center;">
                    <div class="icon_wrap">
                        <i id="iprocess" class="fa fa-4x fa-spinner fa-spin"></i>
                        <i id="isuccess" class="fa fa-5x fa-check-circle" style="display: none;"></i>
                        <i id="ierror" class="fa fa-5x fa-times-circle" style="display: none;"></i>
                    </div>
                    <p class="brand">利郎男装</p>
                    <p class="title"><%=TokenInfos["activename"] %></p>
                    <p class="subtitle"><%=TokenInfos["tokenname"] %></p>
                    <p class="remark"><%=TokenInfos["remark"] %></p>
                    <p class="result" data-status="process"><span class="transition">正在处理，请稍候..</span></p>
                </div>
                <div class="bot">
                    <a href="javascript:scanQRCode();" class="btn">
                        <img style="height: 20px; margin-top: 10px; margin-right: 5px; display: inline-block; vertical-align: top;" src="../../res/img/vipweixin/f-scan2.png" />马上去领取礼品</a>
                    <p class="failmsg">--</p>
                </div>
            </div>
        </div>
    </div>
    <!--<a class="btn no" href="javascript:WeixinJSBridge.call('closeWindow');">否</a>-->

    <script type="text/javascript" src="../../res/js/jquery.js"></script>
    <script type="text/javascript" src="../../res/js/LeeJSUtils.min.js"></script>
    <script type="text/javascript" src="http://res.wx.qq.com/open/js/jweixin-1.0.0.js"></script>

    <script type="text/javascript">
        var appIdVal = "<%=wxConfig[0]%>", timestampVal = "<%=wxConfig[1]%>", nonceStrVal = "<%=wxConfig[2]%>", signatureVal = "<%=wxConfig[3]%>";
        var wxid = "<%=TokenInfos["wxid"]%>",openid="<%=TokenInfos["openid"]%>";

        $(document).ready(function () {
            LeeJSUtils.LoadMaskInit();
            jsConfig();
        });

        window.onload = function () {
            setTimeout(autoGetTicket, 500);
        }

        //发起兑换请求
        function autoGetTicket() {
            var tid=LeeJSUtils.GetQueryParams("tid");
            $.ajax({
                type: "POST",
                cache: false,
                timeout: 10 * 1000,
                data:{ActiveTokenID:tid, wxID:wxid},
                contentType: "application/x-www-form-urlencoded; charset=utf-8",
                url: "/OA/project/storesaler/wxActiveTokenCore.ashx?ctrl=GetActiveToken",
                success: function (msg) {
                    if (msg.indexOf("Error:") > -1) {
                        //获取失败                        
                        $(".page").attr("data-status", "error");
                        $(".icon_wrap>i").hide();
                        $("#ierror").show();
                        $(".failmsg").text(msg.replace("Error:", ""));
                        $(".failmsg").slideDown();
                        $(".result").attr("data-status", "error");
                        $(".result>span").text("领取失败!");                        
                    } else {
                        //获取成功
                        $(".page").attr("data-status", "success");
                        $(".icon_wrap>i").hide();
                        $("#isuccess").show();                        
                        $(".result").attr("data-status", "success");
                        $(".result>span").text("领取成功!");
                        $(".bot .btn").css("display","block");
                    }
                },
                error: function (XMLHttpRequest, textStatus, errorThrown) {
                    LeeJSUtils.showMessage("error", "您的网络出问题啦..");
                }
            });
        }

        //微信JS-SDK
        function jsConfig() {
            wx.config({
                debug: false,
                appId: appIdVal, // 必填，公众号的唯一标识
                timestamp: timestampVal, // 必填，生成签名的时间戳
                nonceStr: nonceStrVal, // 必填，生成签名的随机串
                signature: signatureVal, // 必填，签名，见附录1
                jsApiList: ['hideMenuItems', 'scanQRCode'] // 必填，需要使用的JS接口列表，所有JS接口列表见附录2
            });
            wx.ready(function () {
                wx.hideMenuItems({
                    menuList: ['menuItem:share:appMessage', 'menuItem:share:qq', 'menuItem:share:timeline', 'menuItem:share:weiboApp', 'menuItem:share:QZone', 'menuItem:openWithSafari', 'menuItem:openWithQQBrowser', 'menuItem:share:email', 'menuItem:copyUrl'] //menuItem:share:appMessage 要隐藏的菜单项，只能隐藏“传播类”和“保护类”按钮，所有menu项见附录3
                });                
            });

            wx.error(function (res) {
                alert(res);
            });
        }

        //扫码入口
        function scanQRCode() {
            wx.scanQRCode({
                needResult: 0, // 默认为0，扫描结果由微信处理，1则直接返回扫描结果，
                scanType: ["qrCode"], // 可以指定扫二维码还是一维码，默认二者都有
            });
        }

        //$.ajax({
        //    type: "POST",
        //    cache: false,
        //    timeout: 10 * 1000,
        //    contentType: "application/x-www-form-urlencoded; charset=utf-8",
        //    url: "turkeyPlanCoreV2.aspx?ctrl=",
        //    success: function (msg) {
        //        var data = JSON.parse(msg);
        //    },
        //    error: function (XMLHttpRequest, textStatus, errorThrown) {
        //        showMessage("您的网络出问题啦..", null);
        //    }
        //});
    </script>
</body>
</html>
