<%@ Page Language="C#" %>

<%@ Import Namespace="nrWebClass" %>
<%@ Import Namespace="System.Data.SqlClient" %>
<%@ Import Namespace="System.Data" %>
<%@ Import Namespace="System.Collections.Generic" %>
<%@ Import Namespace="System.Web.Caching" %>

<script runat="server">
    public string ConfigKeyValue = clsConfig.GetConfigValue("CurrentConfigKey");//LILANZ利郎商务男装
    private List<string> wxConfig = new List<string>();//微信JS-SDK
    public string openid = "";
    public string vipid = "";

    protected void Page_Load(object sender, EventArgs e)
    {
        // Session.Clear();
        if (clsWXHelper.CheckUserAuth(ConfigKeyValue, "openid"))
        {
            /* Response.Write(Convert.ToString(Session["openid"]));
            Response.Write(ConfigKeyValue);
            Response.End(); */
            vipid = Convert.ToString(Session["vipid"]);
            openid = Convert.ToString(Session["openid"]);
            string dumpurl = "";
            if (ConfigKeyValue == "5"){
                dumpurl = "../vipweixin/JoinUS.aspx";
            }else{
                dumpurl = "../EasyBusiness/JoinUS.aspx";
            }

            if (vipid == "" || vipid == "0") {
                Response.Write("<script>localStorage.setItem('worldCupKey', " + ConfigKeyValue + ");alert('本活动仅限利郎会员');window.location.href='" + dumpurl + "';</scr" + "ipt>");
            }

            wxConfig = clsWXHelper.GetJsApiConfig(ConfigKeyValue);
            clsWXHelper.AddCusAction_WX(Convert.ToString(Session["openid"]),20001, "参加游戏【18年世界杯】", string.Format(@"{{ ""SourceType"":""{0}"", ""SourceOpenId"":""{1}"" }}",Convert.ToString(Request.Params["org"]), Convert.ToString(Request.Params["openid"])));
        }
        else
        {
            Response.Write("<script>alert('本活动仅限利郎会员');window.close();</scr" + "ipt>");
            wxConfig.Add("");
            wxConfig.Add("");
            wxConfig.Add("");
            wxConfig.Add("");
        }
    }
</script>

<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width,initial-scale=1.0,user-scalable=no">
    <title>摇一摇赢大奖</title>
    <script src="./js/flexible.min.js"></script>
    <script type="text/javascript" src="js/resLoader.js"></script>
    <script src="./js/zepto.min.js"></script>
    <link rel="stylesheet" href="./css/main.css">
    <style type="text/css">
        /*loading style*/
        .loading_mask, .message_mask {
            position: fixed;
            top: 0;
            left: 0;
            width: 100%;
            height: 100%;
            background-color: #2aa133;
            z-index: 5001;
            color: #fff;
            display: -webkit-flex;
            display: flex;
            -webkit-align-items: center;
            align-items: center;
        }

        .message_mask {
            background-color: rgba(0,0,0,.6);
            display: none;
        }

        .loading_mask img {
            height: 1.2rem;
            vertical-align: middle;
            padding-right: 5px;
        }

        .loading_mask span {
            vertical-align: middle;
            font-size: 0.360rem;
            font-weight: bold;
        }

        .test {
            position: absolute;
            z-index: 50;
        }
    </style>
</head>
<body>
    <div class="loading_mask" id="loading">
        <div style="display: inline-block; margin: 0 auto;">
            <img src="./images/title.png" />
            <span>正在加载资源（<span id="res_current">--</span> / <span id="res_total">--</span>）</span>
        </div>
    </div>
    <script type="text/javascript">
        var openid = "<%=openid%>";
        var vipid = "<%=vipid%>";
        var configKey = "<%=ConfigKeyValue%>";
        var userInfo = null;
        var isBigPrize = false;
        var url = 'gameCore.aspx'; //'gameCore.aspx';//'http://tm.lilanz.com/qywx/project/vipweixin/gameCore.aspx';

        function getUserInfo (flag) {
            var data = {
                ctrl: 'init'
            };

            if (flag === 0) {
                data.flag = 0;
            }
            $.ajax({
                url: url,
                type: 'GET',
                data: data,
                dataType: 'JSON',
                success: function(res) {
                    res = JSON.parse(res);
                    if (res.code == 200) {
                        userInfo = res.data;
                        if (userInfo) {
                            document.getElementById('lock').innerText = userInfo.counts > 0 ? userInfo.counts : 0;
                            document.querySelector('.vip-card').innerText = 'VIPCard:' + userInfo.vipkh || '';
                            document.querySelector('.vip-total').innerText = '总次数:' + userInfo.totalcounts || 0;
                            document.querySelector('.vip-used').innerText = '已用次数:' + userInfo.usedcounts || 0;
                        } else {
                            document.getElementById('lock').innerText = 0;
                        }
                        checkPersonInfo();
                    } else {
                        userInfo = {message: res.message};
                        document.getElementById('lock').innerText = 0;
                        alert(res.message);
                    }
                    document.querySelector('.loading_mask').style.display = 'none';
                },
                error: function(err) {
                    alert('网络异常，获取用户信息失败！');
                }
            });
        }

        function getPrize () {
            $.ajax({
                url: url,
                type: 'GET',
                data: {
                    ctrl: 'prizeslist'
                },
                dataType: 'JSON',
                success: function(res) {
                    res = JSON.parse(res);
                    if (res.code == 200) {
                        var html = '';
                        var list = res.data;

                        if (list.length == 0) {
                            html = '<li style="background-image: none;padding-left: 0;"><p style="width: 100%;text-align: center;">您目前还没有获得奖品哦</p></li>';
                        }

                        for (var i = 0; i < list.length; i++) {
                            if (list[i].PrizeID == 46) {
                                html = html + '<li><div class="prize-info"><img src="./images/redEnvelope.png" alt="">'
                                            + '<div class="prize-detail"><p>' + list[i].prizename + '</p><span>中奖日期: ' + list[i].createtime
                                            + '</span></div></div>'
                                            + '<div class="cost">￥' + list[i].RedPackMoney + '</div></li>';
                            } else if (list[i].PrizeID == 45) {
                                html = html + '<li><div class="prize-info"><img src="./images/ticket.png" alt="">'
                                            + '<div class="prize-detail"><p>' + list[i].prizename + '</p><span>中奖日期: ' + list[i].createtime
                                            + '</span></div></div>'
                                            + '<div class="cost">￥4999</div></li>';
                            }
                        }

                        document.querySelector('.prize-detail ul').innerHTML = html;
                    }
                }
            });
        };
    
        function checkPersonInfo() {
            if (userInfo.personInfo) {
                isBigPrize = true;
                isShake = true;
                document.querySelector('.redpack-bar').style.display = 'none';
                document.querySelector('.color-bar').style.display = 'block';
                document.querySelector('.ball').style.display = 'block';
                document.querySelector('.redpack').style.display = 'none';
                document.querySelector('.award-fail').style.display = 'none';
                document.querySelector('.award-redpack').style.display = 'none';
                document.querySelector('.award-winner').style.display = 'block';
                document.querySelector('.form').style.display = 'block';
                document.querySelector('.prompt-redpack').style.display = 'none';
                document.querySelector('.container').style.display = 'none';
                document.querySelector('.award').style.display = 'block';
            }
        }
        var loader = new resLoader({
            resources: ["images/athletes.png",
                        "images/bar.png",
                        "images/bar2.png",
                        "images/bar3.png",
                        "images/bg_tx.png",
                        "images/yyy-01.png",
                        "images/yyy-02.png",
                        "images/yyy-08.png",
                        "images/yyy-09.png",
                        "images/court.png",
                        "images/grassland.jpg",
                        "images/button.png",
                        "images/logo.png",
                        "images/title.png",
                        "images/rock-top.png",
                        "images/rock-bottom.png",
                        "images/detail2.png",
                        "images/xl.png",
                        "images/football.png",
                        "images/huodongjieshao.png",
                        "images/price.png",
                        "images/redpack.png",
                        "images/redEnvelope.png",
                        "images/ticket.png",
                        "images/award_bg.png"],
            onStart: function (total) {
                document.getElementById("res_total").textContent = total;
            },
            onProgress: function (current, total) {
                document.getElementById("res_current").textContent = current;
            },
            onComplete: function (total) {
                // 预加载完成关闭预加载页面
                getUserInfo();
                getPrize();
                // alert('内部测试页面，请勿转发！');
            }
        });

        loader.start();
    </script>
    <!-- 主页面 -->
    <div class="container">
        <div class="main">
            <div class="rules-btn">
                <p>活动细则</p>
            </div>
            <div class="vip-info">
                <p class="vip-card"></p>
                <p class="vip-total"></p>
                <p class="vip-used"></p>
            </div>
            <div class="logo">
                <img src="./images/logo.png" alt="">
            </div>
            <div class="title shake-anim">
                <img src="./images/title.png" alt="">
            </div>
            <div class="bar bar-action"></div>
            <div class="shake">
                <div class="rock">
                    <img class="rock-top" src="./images/yyy-08.png" alt="">
                    <img class="rock-bottom" src="./images/yyy-09.png" alt="">
                </div>
            </div>
            <div class="times">
                您还有 <span id="lock">0</span> 次机会
            </div>
            <div class="detail">
                <img src="./images/detail2.png" alt="">
            </div>
            <div class="footer">
                <img class="athletes action" src="./images/athletes.png" alt="">
                <img class="footerball" src="./images/football.png" alt="">
                <img class="go-bottom" src="./images/xl.png" alt="">
            </div>
        </div>
        <!-- 介绍与奖品 -->
        <div class="details">
            <div class="introduction">
                <img class="int-title" src="./images/huodongjieshao.png" alt="">
                <p class="int-time">2018年6月1日——6月30日</p>
                <p>活动期间，凡在利郎线下门店单笔实付满666元，</p>
                <p>即可参与门店【世界杯摇一摇】抽奖互动。</p>
                <p>有机会赢取俄罗斯6天5日游（价值4999元），抽奖资质可累计。</p>
                <a class="int-rules">活动细则</a>
            </div>
            <div class="myprize">
                <img src="./images/price.png" alt="">
                <div class="prize-detail">
                    <ul></ul>
                </div>
            </div>
        </div>
    </div>
    <!-- 奖品提示 -->
    <div class="award">
        <div class="bg-img">
            <div class="bg-color">
                <div class="prompt">
                    <div class="color-bar"></div>
                    <div class="redpack-bar"></div>
                    <div class="award-winner">
                        <p class="award-title">恭喜你</p>
                        <p>获得特等奖</p>
                        <p>俄罗斯6天5日游</p>
                    </div>
                    <!-- .. -->
                    <div class="award-redpack">
                        <p class="award-title">恭喜你</p>
                        <p class="award-cost">获得现金红包 x 元</p>
                    </div>
                    <div class="award-fail">
                        <p class="award-title">很遗憾</p>
                        <p>你与奖品擦肩而过</p>
                    </div>
                    <img class="redpack" src="./images/redpack.png" alt="">
                    <img class="ball" src="./images/football.png" alt="">
                </div>
                <div class="form">
                    <p class="form-title">请在下方填写相关信息</p>
                    <div class="form-items">
                        <div class="form-item">
                            <span>手机* |</span>
                            <input id="form-tel" type="number">
                        </div>
                        <div class="form-item">
                            <span>姓名* |</span>
                            <input id="form-name" type="text">
                        </div>
                        <div class="form-item">
                            <span>身份证* |</span>
                            <input id="form-idcard" type="text">
                        </div>
                    </div>
                </div>
                <div class="prompt-redpack">
                    <p>现金红包将通过公众号推送给您，</p>
                    <p>请注意领取！</p>
                    <p>领取时限: 24小时</p>
                </div>
                <a class="btn-submit">确 认</a>
            </div>
        </div>
    </div>
    <!-- 活动细则 -->
    <div class="rules">
        <div class="rules-title">
            <img src="./images/rules.png" alt="">
        </div>
        <div class="content">
            <p>1、本活动规定满18-60周岁之间可参与，获奖资格不得转让、买卖，如不能参与可兑换4999元同等价值的利郎产品；</p>
            <p>2、活动期间以内，消费金额计算以VIP收银小票为准，凭单张小票每满666可抽奖1次，小票金额不累计计算；</p>
            <p>3、需在微信公众平台【利郎男装】注册或关联微信VIP；</p>
            <p>4、如获奖者没有在规定时间内提交相应的签证资料，导致出行延误者则视为自动放弃获奖资格。</p>
            <p class="delcare">本活动最终解释权归利郎（中国）有限公司所有</p>
        </div>
        <a class="btn-back">返 回</a>
    </div>
    <!--加载提示-->
    <div class="load_toast" id="myLoading">
        <div class="load_img">
            <img src="./images/my_loading.gif" alt="">
        </div>
        <div class="load_text">正在抽取奖品，请稍候...</div>
    </div>
    <div class="sound"></div>
    <script type="text/javascript" src="http://res.wx.qq.com/open/js/jweixin-1.0.0.js"></script>
    <script type="text/javascript">
        /* eruda.init(); */
        var appIdVal = "<%=wxConfig[0]%>", timestampVal = "<%=wxConfig[1]%>", nonceStrVal = "<%=wxConfig[2]%>", signatureVal = "<%=wxConfig[3]%>";
        //微信JS-SDK
        function GetWXJSApi() {
            wx.config({
                debug: false,
                appId: appIdVal, // 必填，公众号的唯一标识
                timestamp: timestampVal, // 必填，生成签名的时间戳
                nonceStr: nonceStrVal, // 必填，生成签名的随机串
                signature: signatureVal, // 必填，签名，见附录1
                jsApiList: ['onMenuShareTimeline', 'onMenuShareQQ', 'onMenuShareAppMessage', 'onMenuShareQZone'] // 必填，需要使用的JS接口列表，所有JS接口列表见附录2
            });
            wx.ready(function () {
                var url = window.location.href, sharelink = "";
                var imgurl = "http://tm.lilanz.com/project/18worldcup/images/weixin.jpg";
                if (url.indexOf("?") > -1)
                    sharelink = url.substring(0, url.indexOf("?"));
                else
                    sharelink = url;
                var title = "摇一摇，赢取门票 、俄罗斯豪华游！";
                var desc = "游俄罗斯，看世界杯，利郎带你去现场，赶紧戳进来解锁吧~";
                //分享到朋友圈
                wx.onMenuShareTimeline({
                    title: title, // 分享标题
                    link: sharelink + "?org=shareMoments&openid=" + openid, // 分享链接
                    imgUrl: imgurl, // 分享图标
                    success: function () {
                    },
                    cancel: function () {
                    }
                });

                //分享给QQ好友
                wx.onMenuShareQQ({
                    title: title, // 分享标题   
                    desc: desc,
                    link: sharelink + "?org=shareQQFriend&openid=" + openid, // 分享链接
                    imgUrl: imgurl, // 分享图标
                    success: function () {
                    },
                    cancel: function () {
                    }
                });

                //分享给朋友
                wx.onMenuShareAppMessage({
                    title: title, // 分享标题   
                    desc: desc,
                    link: sharelink + "?org=shareFriend&openid=" + openid, // 分享链接
                    imgUrl: imgurl, // 分享图标
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
                    link: sharelink + "?org=share&openid=" + openid, // 分享链接
                    imgUrl: imgurl, // 分享图标
                    success: function () {
                    },
                    cancel: function () {
                    }
                });
            });
            wx.error(function (res) { });
        }
    </script>
    <script type="text/javascript">
        const EMPTY_VALUE = 100;
        const THREAD_HOLD = 13.8;
        var minX = EMPTY_VALUE,
            minY = EMPTY_VALUE;
        var isShake = false, isUse = false;
        var clickCounts = 0;
        var clearCounts = null;
        // 监听手机摇动
        window.ondevicemotion = function(event) {
            var gravity = event.accelerationIncludingGravity,
                x = gravity.x,
                y = gravity.y;
            if(x < minX) minX = x;
            if(y < minY) minY = y;
            if(Math.abs(x - minX) > THREAD_HOLD &&  
                    Math.abs(y - minY) > THREAD_HOLD){
                var event = new CustomEvent("shake");
                window.dispatchEvent(event);
                minX = minY = EMPTY_VALUE;
            }
        };

        document.querySelector('.bar').addEventListener('click', function() {
            if (clearCounts == null) {
                clearCounts = setTimeout(function() {
                    clickCounts = 0;
                    clearCounts = null;
                }, 1000);
            }
            clickCounts++;
            if (clickCounts >= 3) {
                clickCounts = 0;
                var event = new CustomEvent("shake");
                window.dispatchEvent(event);
            }
        });

        /* document.querySelector('.bar').addEventListener('click', function() {
            console.log('shake');
            var event = new CustomEvent("shake");
            window.dispatchEvent(event);
        }); */

        // 摇一摇事件
        window.addEventListener('shake', function() {
            if (userInfo && userInfo.message) {
                alert(userInfo.message);
                return null;
            }
            if (userInfo === undefined || userInfo.counts <= 0 || userInfo.counts === undefined) {
                if (isUse) {
                    alert('您的抽奖机会已用完');
                } else {
                    alert('您没有抽奖机会，活动期间在利郎门店消费满666元可获得抽奖机会');
                }
                return null;
            }
            if (isShake || userInfo.counts === undefined) return null;
            document.getElementById('shakeSound').play();
            document.querySelector('.rock-top').classList.add('rockup');
            document.querySelector('.rock-bottom').classList.add('rockdown');
            isShake = true;
            userInfo.counts--;
            isUse = true;
            document.getElementById('lock').innerText = userInfo.counts;

            var isSuccess = false;

            setTimeout(function() {
                if (isSuccess) {
                    showAward();
                } else {
                    document.getElementById('myLoading').style.display = 'block';
                    isSuccess = true;
                }
            }, 1300);

            $.ajax({
                url: url,
                type: 'GET',
                data: {
                    ctrl: 'consumegametoken',
                    token: userInfo.token
                },
                dataType: 'JSON',
                success: function(res) {
                    res = JSON.parse(res);
                    if (res.code == 200) {
                        if (res.data.prizeid == 46) {
                            showRedpack(res);
                        } else if (res.data.prizeid == 45) {
                            showWinner();
                        } else {
                            showFail();
                        }
                    } else {
                        showFail();
                    }

                    if (isSuccess) {
                        showAward();
                    } else {
                        isSuccess = true;
                    }
                }
            });
        });

        function showAward() {
            document.getElementById('myLoading').style.display = 'none';
            document.querySelector('.rock-top').classList.remove('rockup');
            document.querySelector('.rock-bottom').classList.remove('rockdown');
            document.querySelector('.container').style.display = 'none';
            document.querySelector('.award').style.display = 'block';
            document.getElementById('shakeSound').src = './4092.mp3';
            document.getElementById('shakeSound').play();
            userInfo.token = '';
            if (userInfo.counts > 0) {
                getUserInfo(0);
            }
            getPrize();
        }

        // 获得红包
        function showRedpack (res) {
            document.querySelector('.color-bar').style.display = 'none';
            document.querySelector('.redpack-bar').style.display = 'block';
            document.querySelector('.ball').style.display = 'none';
            document.querySelector('.redpack').style.display = 'block';
            document.querySelector('.award-fail').style.display = 'none';
            document.querySelector('.award-redpack').style.display = 'block';
            document.querySelector('.award-winner').style.display = 'none';
            document.querySelector('.award-cost').innerText = "获得" + res.data.prizename;
            document.querySelector('.form').style.display = 'none';
            document.querySelector('.prompt-redpack').style.display = 'block';
        }

        // 获得特等奖
        function showWinner() {
            isBigPrize = true;
            document.querySelector('.redpack-bar').style.display = 'none';
            document.querySelector('.color-bar').style.display = 'block';
            document.querySelector('.ball').style.display = 'block';
            document.querySelector('.redpack').style.display = 'none';
            document.querySelector('.award-fail').style.display = 'none';
            document.querySelector('.award-redpack').style.display = 'none';
            document.querySelector('.award-winner').style.display = 'block';
            document.querySelector('.form').style.display = 'block';
            document.querySelector('.prompt-redpack').style.display = 'none';
        }

        // 未中奖
        function showFail() {
            document.querySelector('.color-bar').style.display = 'none';
            document.querySelector('.redpack-bar').style.display = 'none';
            document.querySelector('.ball').style.display = 'block';
            document.querySelector('.redpack').style.display = 'none';
            document.querySelector('.award-redpack').style.display = 'none';
            document.querySelector('.award-winner').style.display = 'none';
            document.querySelector('.award-fail').style.display = 'block';
            document.querySelector('.form').style.display = 'none';
            document.querySelector('.prompt-redpack').style.display = 'none';
        }

        // 监听微信 加载音效
        document.addEventListener('WeixinJSBridgeReady', function() {
            var audio = document.createElement("audio");
            audio.id = "shakeSound";
            audio.src = "./5018.mp3";
            audio.style.display = "none";
            document.querySelector(".sound").appendChild(audio);
        });

        // 确认按钮事件
        document.querySelector('.btn-submit').addEventListener('click', function() {
            if (isBigPrize) {
                submit();
            } else {
                document.querySelector('.container').style.display = 'block';
                document.querySelector('.award').style.display = 'none';
                document.getElementById('shakeSound').src = './5018.mp3';
                isShake = false;
            }
        });

        function submit () {
            var tel = document.getElementById('form-tel').value;
            var name = document.getElementById('form-name').value;
            var idcard = document.getElementById('form-idcard').value;

            if (tel == '') {
                alert('请输入联系电话！');
                return null;
            }

            if (tel.length != 11) {
                alert('联系电话必须是11位！');
                return null;
            }

            if (name == '') {
                alert('请输入姓名！');
                return null;
            }

            if (idcard == '') {
                alert('请输入身份证号码！');
                return null;
            }

            if ( idcard.length != 18) {
                alert('身份证号码必须是18位！');
                return null;
            }

            $.ajax({
                url: url,
                data: {
                    ctrl: 'saveuser',
                    cname: encodeURIComponent(name),
                    phone: tel,
                    idcard: idcard
                },
                dataType: 'JSON',
                success: function(res) {
                    res = JSON.parse(res);
                    if (res.code == 200) {
                        alert('保存信息成功！');
                        document.querySelector('.container').style.display = 'block';
                        document.querySelector('.award').style.display = 'none';
                        document.getElementById('shakeSound').src = './5018.mp3';
                        isShake = false;
                        isBigPrize = false;

                        // 防止摇一摇触发IOS摇动撤销
                        window.location.reload();
                    } else {
                        alert(res.message);
                    }
                }
            });
        }
        document.querySelector('.rules-btn').addEventListener('click', function() {
            isShake = true;
            document.querySelector('.container').style.display = 'none';
            document.querySelector('.rules').style.display = 'block';
        });

        document.querySelector('.int-rules').addEventListener('click', function() {
            isShake = true;
            document.querySelector('.container').style.display = 'none';
            document.querySelector('.rules').style.display = 'block';
        });

        document.querySelector('.btn-back').addEventListener('click', function() {
            isShake = false;
            document.querySelector('.container').style.display = 'block';
            document.querySelector('.rules').style.display = 'none';
        })

        document.querySelector('.vip-info').addEventListener('click', function() {
            if (configKey == '5') {
                window.location.href = '../vipweixin/VIPCode.aspx';
            } else {
                window.location.href = '../EasyBusiness/VIPCode.aspx'
            }
        })
        
        GetWXJSApi();
    </script>
</body>
</html>