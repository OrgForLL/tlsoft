<%@ Page Language="C#" %>

<%@ Import Namespace="nrWebClass" %>
<%@ Import Namespace="System.Data.SqlClient" %>
<%@ Import Namespace="System.Data" %>
<%@ Import Namespace="System.Collections.Generic" %>
<!DOCTYPE html>
<script runat="server">

    private const string ConfigKeyValue = "1";	//微信配置信息索引值
    public List<string> wxConfig;       //微信OPEN_JS 动态生成的调用参数
    public string AppSystemKey = "", CustomerID = "", CustomerName = "", mdid = "", tzid = "";
    protected void Page_Load(object sender, EventArgs e)
    {

        //if (clsWXHelper.CheckQYUserAuth(true))
        //{
        //    AppSystemKey = clsWXHelper.GetAuthorizedKey(3);//全渠道系统
        //    mdid = Convert.ToString(Session["mdid"]);
        //    if (AppSystemKey == "")
        //        clsWXHelper.ShowError("对不起，您还未开通全渠道系统权限！");
        //    else if (mdid == "" || mdid == "0")
        //    {
        //        clsWXHelper.ShowError("对不起，您无门店信息，无法使用此功能！");
        //    }
        //    else
        //    {
        //        CustomerID = Convert.ToString(Session["qy_customersid"]);
        //        CustomerName = Convert.ToString(Session["qy_cname"]);
        //        //传入参数wx_t_ActiveToken.id[tid]
                wxConfig = clsWXHelper.GetJsApiConfig(ConfigKeyValue);
        //    }
        //}
    }
</script>

<!DOCTYPE html>
<html lang="en">

<head>
    <meta charset="utf-8" />
    <meta name="viewport" content="width=device-width,initial-scale=1,user-scalable=0,maximum-scale=1" />
    <meta name="format-detection" content="telephone=no" />
    <meta name="apple-mobile-web-app-capable" content="yes" />
    <meta name="apple-mobile-web-app-status-bar-style" content="black" />
    <title></title>
    <style>
                * {
            font-family: Helvetica Neue, Helvetica, Microsoft YaHei, PingFang SC, Hiragino Sans GB, SimSun, sans-serif;
            margin: 0;
            padding: 0;
            box-sizing: border-box;
        }

        body {
            font-size: 14px;
            color: #333;
        }

        .page {
            position: absolute;
            left: 0;
            right: 0;
            top: 0;
            bottom: 0;
            background: #f8f8f8;
            padding: 20px;
            overflow-y: auto;
            -webkit-overflow-scrolling: touch;
        }

        .title {
            font-size: 24px;
            font-weight: bold;
        }

        .record-list {
            margin-top: 20px;
        }

        .record-item {
            background-color: #fff;
            border-radius: 4px;
            margin-bottom: 16px;
            padding: 15px 10px;
            display: flex;
            justify-content: space-between;
            -webkit-box-shadow: 0 6px 10px rgba(0, 0, 0, 0.06);
            box-shadow: 0 6px 10px rgba(0, 0, 0, 0.06);
        }

        .record-item .left-con {
            display: flex;
            overflow: hidden;
        }

        .left-con .good-img {
            width: 16vw;
            height: 16vw;
            background-position: center;
            background-size: cover;
            background-image: url(../../res/img/system.jpg);
            border-radius: 4px;
        }

        .good-info {
            flex: 1;
            overflow: hidden;
            margin: 0 8px;
            height: 100%;
            display: flex;
            flex-direction: column;
            justify-content: space-around;
        }

        .good-info p {
            line-height: 1;
            white-space: nowrap;
            text-overflow: ellipsis;
            overflow: hidden;
        }

        .good-name {
            font-size: 17px;

        }

        .share-time {
            color: #929292;
            font-size: 13px;

        }

        .record-item .right-con {
            overflow: hidden;
            display: flex;
            align-items: center;
            justify-content: space-around;
            flex: 1;
        }

        .right-con .click_wrap {
            background-color: #ffede8;
            text-align: center;
            border-radius: 6px;
            min-width: 60px;
            padding: 5px 0;
        }

        .right-con .click-txt {
            background-color: #ffede8;
            color: #ff6c2f;
            font-size: 12px;
        }

        .right-con .click-num {
            color: #ff6c2f;
            font-size: 20px;
        }
        .no-data
        {
            color: #acacac;
            text-align: center;
            position: absolute;
            top: 50%;
            bottom: 0;
            left: 0;
            right: 0;
            font-size:16px;  
         }
    </style>
</head>

<body>
    <div class="page">
        <p class="title">分享记录</p>
        <div class="record-list">
            
        </div>
        <p class="no-data">-暂无扫码记录-</p>
    </div>

    <script type="text/html" id="record_tpl">
        {{each list}}
        <div class="record-item">
            <div class="left-con">
                <div class="good-img" style="background-image: url({{$value.miniimgurl}});" data-imgurl="{{$value.imgurl}}"></div>
            </div>
            <div class="right-con" onclick="window.location.href='{{$value.linkurl}}'">
                <div class="good-info">
                    <p class="good-name">{{$value.sphh}}</p>
                    <p class="share-time">{{$value.CreateTime}}</p>
                </div>
                <div class="click_wrap">
                    <p class="click-txt">点击数</p>
                    <p class="click-num">{{formatNum($value.openCount)}}</p>
                </div>
            </div>
        </div>
        {{/each}}
    </script>

    <script type="text/javascript" src="../../res/js/jquery.js"></script>
    <script type="text/javascript" src="../../res/js/template.js"></script>
    <script type="text/javascript" src="../../res/js/jweixin-1.1.0.js"></script>
    <script type="text/javascript" src="../../res/js/LeeJSUtils.min.js"></script>
    <script type="text/javascript" src="http://tm.lilanz.com/oa/api/lilanzAppWVJBridge-0.1.6.min.js"></script>
    <script type="text/javascript">

        var appIdVal = "<%=wxConfig[0]%>", timestampVal = "<%=wxConfig[1]%>", nonceStrVal = "<%=wxConfig[2]%>", signatureVal = "<%=wxConfig[3]%>";
        var mdid = "<%=mdid%>", cid = "<%=CustomerID%>";


        $(function () {


            template.helper('formatNum', function (data, n) {
                return formatNum(data, n);
            });


            var isminiprogram = getUrlParam("isminiprogram");

            // 获取地址栏URL参数
            function getUrlParam(name) {
                var reg = new RegExp("(^|&)" + name + "=([^&]*)(&|$)"); // 构造一个含有目标参数的正则表达式对象  
                var r = window.location.search.substr(1).match(reg); // 匹配目标参数  
                if (r != null) return unescape(r[2]);
                return null; // 返回参数值  
            }


            //判断是否在微信中打开
            function is_weixn() {
                var ua = navigator.userAgent.toLowerCase();
                if (ua.match(/MicroMessenger/i) == "micromessenger") {
                    return true;
                } else {
                    return false;
                }
            }


            //判断数字是否超过1万
            function formatNum(data) {

                data > 9999 ? (data / 10000).toFixed(1) + "万" : formatMoney(data, 0);

                return data;

            }


            //格式化数字
            function formatMoney(s, n) {
                // n = n > 0 && n <= 20 ? n : 2;
                s = parseFloat((s + "").replace(/[^\d\.-]/g, "")).toFixed(n) + "";
                var l = s.split(".")[0].split("").reverse(),
                    r = s.split(".")[1];
                t = "";
                for (i = 0; i < l.length; i++) {
                    t += l[i] + ((i + 1) % 3 == 0 && (i + 1) != l.length ? "," : "");
                }
                if (n == 0) {
                    return t.split("").reverse().join("");
                } else
                    return t.split("").reverse().join("") + "." + r;
            }


            //加载记录数据
            function loadData() {
                LeeJSUtils.showMessage("loading", "正在加载..");
                $.ajax({
                    url: "../StoreSaler/TurnoversCore.aspx?ctrl=getShareHisotry&mdid=" + 249 + "&cid=" + 587 + "&isminiprogram=" + isminiprogram,
                    type: "post",
                    contentType: "application/x-www-form-urlencoded; charset=utf-8",
                    data: {},
                    cache: false,
                    timeout: 15000,
                    error: function (e) {
                        alert("网络异常,请稍后重试！");
                    },
                    success: function (res) {

                        if (res != "") {

                            var msg = JSON.parse(res);

                            if (msg.list.length != 0) {

                                $(".no-data").hide();
                                $(".record-list").html(template("record_tpl", msg));

                            }

                        } else

                            $(".no-data").show();
                        //alert(msg.errmsg);

                        $("#leemask").hide();
                    }
                });

            }


            //微信JS-SDK
            function jsConfig(currentUrl, urls) {
                wx.config({
                    debug: false,
                    appId: appIdVal, // 必填，公众号的唯一标识
                    timestamp: timestampVal, // 必填，生成签名的时间戳
                    nonceStr: nonceStrVal, // 必填，生成签名的随机串
                    signature: signatureVal, // 必填，签名，见附录1
                    jsApiList: ['previewImage'] // 必填，需要使用的JS接口列表，所有JS接口列表见附录2
                });




                wx.error(function (res) {
                    console.log("微信JS-SDK注册失败！");
                });
            }


            //预览图片
            $(".record-list").on("click", ".good-img", function () {
                var imgurl = $(this).attr("data-imgurl");

                if (is_weixn()) {

                    wx.ready(function () {
                        wx.previewImage({
                            current: imgurl,
                            urls: [imgurl]
                        });
                    });
                } else {

                    llApp.previewImage({
                        current: imgurl,
                        urls: [imgurl]
                    });

                }

            });

            jsConfig();
            loadData();

        });
    </script>
</body>

</html>