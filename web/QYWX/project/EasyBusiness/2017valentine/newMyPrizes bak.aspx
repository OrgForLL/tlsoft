<%@ Page Language="C#" %>

<%@ Import Namespace="nrWebClass" %>
<%@ Import Namespace="System.Data.SqlClient" %>
<%@ Import Namespace="System.Data" %>
<%@ Import Namespace="System.Collections.Generic" %>

<script runat="server">
    private string ConfigKeyValue = "7", objectid = "4", openid = "", wxid = "", enOpenid = "";
    private string WXDBConstr = "server='192.168.35.62';uid=sa;pwd=ll=8727;database=weChatPromotion";
    private string OAConnStr = "server=192.168.35.10;uid=ABEASD14AD;pwd=+AuDkDew;database=tlsoft";
    private List<string> wxConfig = new List<string>();//微信JS-SDK

    protected void Page_Load(object sender, EventArgs e)
    {
        if (clsWXHelper.CheckUserAuth(ConfigKeyValue, "openid"))
        {
            openid = Convert.ToString(Session["openid"]);
            enOpenid = clsNetExecute.EncryptHex(openid);
            wxConfig = clsWXHelper.GetJsApiConfig(ConfigKeyValue);

            using (LiLanzDALForXLM dal = new LiLanzDALForXLM(WXDBConstr))
            {
                //查询是否登记过个人信息
                //string str_sql = @"select top 1 id from tm_t_userinfo where wxopenid=@openid";
                string str_sql = @"select top 1 a.id wxid from wx_t_vipbinging a
                                    where a.wxopenid=@openid and a.objectid=@objectid";
                List<SqlParameter> para = new List<SqlParameter>();
                para.Add(new SqlParameter("@openid", openid));
                para.Add(new SqlParameter("@objectid", objectid));
                DataTable dt;
                string errinfo = dal.ExecuteQuerySecurity(str_sql, para, out dt);
                if (errinfo == "")
                {
                    if (dt.Rows.Count > 0)
                    {
                        wxid = Convert.ToString(dt.Rows[0][0]);
                        dt.Clear(); dt.Dispose();
                    }
                    else
                        clsSharedHelper.WriteErrorInfo("找不到您的用户信息！");
                }
                else
                    clsSharedHelper.WriteErrorInfo(errinfo);
            }//end using
        }
    }    
</script>
<!DOCTYPE html>
<html lang="en">
<head runat="server">
    <meta charset="utf-8" />
    <meta name="viewport" content="width=device-width,initial-scale=1,user-scalable=0,maximum-scale=1" />
    <meta name="format-detection" content="telephone=no" />
    <meta name="apple-mobile-web-app-capable" content="yes" />
    <meta name="apple-mobile-web-app-status-bar-style" content="black" />
    <title></title>
    <link type="text/css" rel="stylesheet" href="css/LeePageSlider.css" />
    <style type="text/css">
        .page {
            padding: 0;
            bottom:28px;
        }

        body {
            background-color: #dc310d;
        }

        .wrap-page {
            max-width: 500px;
            margin: 0 auto;
        }

        #index {
            background-color: transparent;
        }

        .content {
            background-color: #dc310d;
            padding-top: 5px;            
        }

        .top_bg {
            margin-bottom: -4px;            
        }

            .top_bg > img {
                width: 100%;
                box-shadow: 0 0 8px #84200b;
            }

        .game_item {
            padding: 10px 15px;
        }

        .game_name {
            font-size: 16px;
            font-weight: bold;
            color: #fff;
            margin-bottom: 10px;
        }

        .prize_item {
            background-color: #b62317;
            border-radius: 4px;
            padding: 10px 15px;
            margin-bottom: 10px;
        }

        .prize_name {
            text-align: center;
            font-size: 24px;
            font-weight: 600;
            color: #fff;
            padding-bottom: 10px;
            border-bottom: 1px solid #fff;
        }

        .prize_infos {
            padding-top: 10px;
        }

        .prize_time {
            color: #fff;
        }

        .prize_status {
            float: right;
            background-color: #bbb;
            color: #fff;
            padding: 2px 10px;
            border-radius: 2px;
            margin-top: -3px;
        }

            .prize_status.noget {
                background-color: #528e2e;
            }

        .go_game {
            text-decoration: none;
            display: inline-block;
            background-color: #528e2e;
            color: #fff;
            padding: 5px 10px;
            border-radius: 4px;
            font-weight: bold;
            box-shadow: 0 4px 0 0 #3b7f0e;
        }

            .go_game:active {
                transform: translateY(4px);
                box-shadow: none !important;
            }

        .btn_wrap {
            text-align: center;
            margin-bottom: 10px;
        }

        .themelogo {
            width: 40vw;
            text-align: center;
        }

        .copyright {
            text-align: center;
            line-height:28px;
            font-size: 12px;
            color: #fff;                       
        }

        #color_page {
            background-color: #dc310d;
        }

        .yellow {
            position: absolute;
            top: 0;
            left: 0;
            width: 100%;
            height: 240px;
            background-color: #ffdf7e;
        }

        .getinfo {
            color: #fff;
            padding: 14px 15px 10px 15px;
            background-color: #dc310d;                
            display:none;     
            overflow-y:auto;
        }

            .getinfo > div > span {
                width: 100%;
                text-align: center;
                display: inline-block;
            }

        .infoqrcode {
            width: 60%;
            display: block;
            margin: 0 auto;
            padding: 10px;
            background-color: #fff;
            margin-bottom: 5px;
        }

        .lh {
            text-align: center;
        }

            .lh > span {
                line-height: 1.6;
                background-color: #fff;
                color: #000;
                padding: 4px 8px;
                border-top-left-radius: 3px;
                border-top-right-radius: 3px;
                font-weight: 600;
                width: 60%;
                display: inline-block;
                border-bottom: 1px dashed #c0c0c0;
            }

        .tips {
            color: #fff;
            font-size: 15px;
            background-color: #b62317;
            padding: 10px;
            font-weight: bold;
        }

        #register .form {
            background-color: #fff;
            padding: 10px;
            margin-top: 15px;
        }

        .form_btn {
            color: #fff;
            font-size: 15px;
            font-weight: bold;
            width: 40%;
            text-align: center;
            display: inline-block;
            padding: 7px 0;
            border-radius: 2px;
        }

            .form_btn.cancle {
                background-color: #ccc;
                margin-right: 10px;
            }

            .form_btn.submit {
                background-color: #528e2e;
            }

        .form_item {
            padding: 10px 0;
            position: relative;
            display: -webkit-box;
            display: -webkit-flex;
            display: flex;
            -webkit-box-align: center;
            -webkit-align-items: center;
            align-items: center;
            line-height: 1.41176471;
            font-size: 16px;
            overflow: hidden;
        }

            .form_item .label {
                display: block;
                width: 80px;
                word-wrap: break-word;
                word-break: break-all;
                border-right: 1px solid #ccc;
                text-align: center;
                color: #222;
            }

            .form_item .cell_input {
                -webkit-box-flex: 1;
                -webkit-flex: 1;
                flex: 1;
            }

        .form input[type='text'], .form input[type='number'] {
            width: 100%;
            border: 0;
            outline: 0;
            -webkit-appearance: none;
            background-color: transparent;
            font-size: inherit;
            color: inherit;
            height: 1.41176471em;
            line-height: 1.41176471;
            padding: 0 10px;
            width: 100%;
        }

        .form_item:not(:last-child) {
            border-bottom: 1px solid #eee;
        }

        .center-translate {
            width: 94%;
            padding: 10px;
            background-color: #dc310d;
            border-radius: 4px;
        }

        #register {
            padding: 10px 15px;
            background-color: rgba(0,0,0,.4);
            display: none;
        }

        .noresult {
            color: #fff;
            text-align: center;
            line-height: 50px;
        }

        .remark {
            margin-bottom: 10px;
        }

        .footer {
            background-color:#dc310d;
            z-index:1000;
            height:28px;
        }
        .btnStore {
            display:block;
            text-align:center;
            height:40px;
            line-height:40px;
            border-radius:4px;            
            background-color:#f0f0f0;
            color:#63b359;            
            font-weight:bold;
            letter-spacing:1px;            
        }
        .location_icon {
            width:22px;
            height:22px;
            vertical-align:middle;
        }
    </style>
</head>
<body>
    <div class="wrap-page">
        <div class="page" id="color_page">
            <div class="yellow"></div>
        </div>
        <div class="page" id="index">
            <div class="top_bg">
                <img src="img/myprize_top.jpg" />
            </div>
            <!--领奖信息-->
            <div class="btn_wrap" style="background-color: #dc310d; margin-bottom: 0; font-size: 18px;">
                <a href="javascript:;" class="go_game" style="background-color: #f5bf46; box-shadow: 0 4px 0 0 #c7921a; display: none;" id="btn_getprize">- 我要领奖 -</a>
            </div>
            <div style="padding:15px 15px 0 15px;background-color:#dc310d;">                
                <a href="http://tm.lilanz.com/project/easybusiness/storelists.aspx" class="btnStore">
                    <img src="img/location_icon.png" class="location_icon" />
                    <span>查看利郎轻商务门店</span>
                </a>
            </div>
            <div class="getinfo">
                <div style="width: 100%; padding: 10px 15px; border-radius: 4px; background-color: #b62317;">
                    <div class="lh"><span>领奖二维码</span></div>
                    <img src="http://tm.lilanz.com/oa/project/StoreSaler/GetQrCode.aspx?code=<%=enOpenid %>" class="infoqrcode" />                    
                    <p class="remark" style="margin-top: 15px;">1、请本人持上方二维码至离您最近的利郎轻商务门店领取，配饰品不参与活动！！</p>                           
                    <p class="remark">2、领奖二维码截图无效，工作人员有权拒绝发放奖品</p>
                </div>
            </div>

            <div class="content">
                <div class="game_item" id="valentine">
                    <p class="game_name">利郎轻商务-2017情人节活动</p>
                    <p class="noresult">对不起，您暂时还没有奖品..</p>
                </div>
            </div>            
        </div>
    </div>
    <div class="footer">
        <p class="copyright">&copy;2017 利郎（中国）有限公司</p>
    </div>
    <!--模板区-->
    <script type="text/html" id="temp_award">
        <div class="prize_item">
            <p class="prize_name">{{prizename}}</p>
            <p class="prize_infos">
                <span class="prize_time"><strong>过期时间：</strong><span>{{validtime}}</span></span>
                <span class="prize_status {{if isget == 'False'}} noget {{/if}}">{{getname}}</span>
            </p>
        </div>
    </script>

    <script type="text/javascript" src="js/jquery.js"></script>
    <script type="text/javascript" src="js/LeeJSUtils.min.js"></script>    
    <script type="text/javascript" src="js/template.js"></script>
    <script type="text/javascript" src="http://res.wx.qq.com/open/js/jweixin-1.0.0.js"></script>

    <script type="text/javascript">
        var openid = "<%=openid%>", wxid = "<%=wxid%>";
        $(document).ready(function () {
            GetWXJSApi();
            LeeJSUtils.stopOutOfPage("#index", true);            

            initData();
        });

        //加载个人中奖记录
        function initData() {
            $.ajax({
                type: "POST",
                timeout: 5 * 1000,
                contentType: "application/x-www-form-urlencoded; charset=utf-8",
                url: "myPrizeCore.aspx",
                data: { ctrl: "getMyPrizes" },
                success: function (msg) {
                    if (msg.indexOf("Error:") > -1) {
                        alert("加载个人中奖信息失败，IT程序员们正在路上了，请稍后重试。");
                    } else {
                        var rows = JSON.parse(msg).rows;
                        var html = "";
                        for (var i = 0; i < rows.length; i++) {
                            var row = rows[i];
                            row.getname = row.isget == "True" ? "已领取" : "未领取";
                            html += template("temp_award", row);
                        }//end for 
                        if (html != "") {
                            $("#valentine").append(html);
                            $("#valentine .noresult").hide();
                            $(".getinfo").show();
                        }
                    }
                },
                error: function (XMLHttpRequest, textStatus, errorThrown) {
                    alert("您的网络真不给力，请稍后重试！");
                }
            });
        }

        //微信JS-SDK
        var appIdVal = "<%=wxConfig[0]%>", timestampVal = "<%=wxConfig[1]%>", nonceStrVal = "<%=wxConfig[2]%>", signatureVal = "<%=wxConfig[3]%>";
        function GetWXJSApi() {
            wx.config({
                debug: false,
                appId: appIdVal, // 必填，公众号的唯一标识
                timestamp: timestampVal, // 必填，生成签名的时间戳
                nonceStr: nonceStrVal, // 必填，生成签名的随机串
                signature: signatureVal, // 必填，签名，见附录1
                jsApiList: ['onMenuShareTimeline', 'onMenuShareQQ', 'onMenuShareAppMessage', 'onMenuShareQZone', 'closeWindow'] // 必填，需要使用的JS接口列表，所有JS接口列表见附录2
            });
            wx.ready(function () {
                var link = window.location.href, title = "我参加了利郎轻商务的活动，还拿到了不错的奖品！你也来看看吧！", desc = "", thumb = "http://tm.lilanz.com/qywx/res/img/vipweixin/myprize_top.jpg";
                //分享到朋友圈
                wx.onMenuShareTimeline({
                    title: title, // 分享标题
                    link: link, // 分享链接                        
                    imgUrl: thumb, // 分享图标
                    success: function () {
                    },
                    cancel: function () {
                    }
                });

                //分享给QQ好友
                wx.onMenuShareQQ({
                    title: title, // 分享标题   
                    desc: desc,
                    link: link, // 分享链接
                    imgUrl: thumb, // 分享图标
                    success: function () {
                    },
                    cancel: function () {
                    }
                });

                //分享给朋友
                wx.onMenuShareAppMessage({
                    title: title, // 分享标题   
                    desc: desc,
                    link: link, // 分享链接
                    imgUrl: thumb, // 分享图标
                    type: 'link', // 分享类型,music、video或link，不填默认为link
                    dataUrl: '', // 如果type是music或video，则要提供数据链接，默认为空
                    success: function () {
                    },
                    cancel: function () {
                    }
                });
                //分享到QQ空间
                wx.onMenuShareQZone({
                    title: title, // 分享标题   
                    desc: desc,
                    link: link, // 分享链接
                    imgUrl: thumb, // 分享图标
                    success: function () {
                    },
                    cancel: function () {
                    }
                });
            });
            wx.error(function (res) { });
        }
    </script>
</body>
</html>
