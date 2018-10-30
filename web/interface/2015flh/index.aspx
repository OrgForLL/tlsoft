<%@ Page Language="C#" %>
<%@ Import Namespace="WebBLL.Core" %> 
<%@ Import Namespace="nrWebClass" %>
<!DOCTYPE html>
<script runat="server">
    private const string appID = "wxc368c7744f66a3d7";	//APPID
    private const string appSecret = "74ebc70df1f964680bd3bdd2f15b4bed";	//appSecret	
    public string[] wxConfig;       //微信OPEN_JS 动态生成的调用参数
    
    protected void Page_Load(object sender, EventArgs e)
    {
        using (WxHelper wh = new WxHelper())
        {
            wxConfig = wh.GetWXJsApiConfig(appID, appSecret);            
        }
    }
</script>
<html lang="en">
<head>
    <meta charset="UTF-8" />
    <title>利郎2015岁末福利会</title>
    <meta name="viewport" content="width=device-width, initial-scale=1, maximum-scale=1, user-scalable=no">
    <meta name="apple-mobile-web-app-capable" content="yes">
    <meta name="apple-mobile-web-app-status-bar-style" content="black">
    <meta content="telephone=no,email=no" name="format-detection">
    <link rel="stylesheet" href="css/custom.css" />
    <link rel="stylesheet" href="css/animate.min.css">
    <script src="js/modernizr.custom.js"></script>
    <script src="js/jquery-1.10.0.min.js"></script>
    <!--分享朋友圈-->
    <link href="share/css/share.css" rel="stylesheet">
</head>
<body>
    <div id="divFill" style=" width:100%; height:100%; background-color:#000; z-index:999999;"></div>
    <!--loading-->
            <script src="js/resLoader.js"></script>
            <link rel="stylesheet" href="css/fakeLoader.css">
            <div class="fakeloader" style="position:absolute;"></div>
            <div class="progressbar" style="position:absolute;padding-top:50%;padding-left: 45%;"></div>
                <script src="js/fakeLoader.min.js"></script>
                <script>
                    $(document).ready(function(){
                        $(".fakeloader").fakeLoader({
                            timeToHide:12000000,
                            bgColor:"black"
                            //imagePath: "images/bg1.png"
                        });
                        
                        loader.start();
                    });
                </script>

            <script>
                var loader = new resLoader({
                    resources: [
                    'images/1.jpg',
                    'vedio/22.wav',
                    'images/1.png',
                    'images/2.png',
                    'images/3.png',
                    'images/mt1.jpg',
                    'images/mt2.jpg',
                    'images/6.jpg',
                    'images/mt3.jpg',
                    'images/mt4.jpg',
                    'images/mt5.jpg',
                    'images/mt6.jpg',
                    'http://file2.rabbitpre.com/6fcf1446-64fe-4ad4-b85f-8cd5f811d0f1-1671?imageMogr2/quality/70/auto-orient',
                    'images/code.png',
                    'vedio/bgm.mp3',

                ],
                    onStart: function (total) {
                        console.log('start:' + total);
                    },
                    onProgress: function (current, total) {
                        console.log(current + '/' + total);
                        var percent = parseInt(current / total * 100);  //百分比
                        //$('.progressbar').text(percent + '%');
                    },
                    onComplete: function (total) {
                        //alert('加载完毕:'+total+'个资源');
                        $(".progressbar").fakeLoader({
                            timeToHide: 1200
                        });

                        $(".fakeloader").fakeLoader({

                            timeToHide: 1200,
                            bgColor: "black"
                            // imagePath: "images/bg1.png"
                        });


                        //音乐响起
                        var myAuto = document.getElementById('myaudio');
                        var bgaudio = document.getElementById('bgaudio');
                        myAuto.play();
                        bgaudio.play();
                         
                        divFill.style.display = "none";
                    }
                });
            
            </script>

    <div class="container demo-2">
        <div id="slider" class="sl-slider-wrapper">
            <div class="sl-slider">
                <!--背景音乐-->
                <audio id="bgaudio" loop src="vedio/bgm.mp3"></audio>

                <div class="sl-slide" data-orientation="horizontal" data-slice1-rotation="-25" data-slice2-rotation="-25" data-slice1-scale="2" data-slice2-scale="2">
                    <div class="sl-slide-inner">
                        <div class="bg-img bg-img-1">
                            <audio id="myaudio" src="vedio/22.wav" hidden="true" preload="load"></audio>
                            <div style="text-align: center">
                                <img src="images/1.png" class="animated bounceInDown" style="width: 85%; margin-top: 1%;">
                            </div>
                            <%--<img src="images/2.png" class="animated bounceInRight" style="width: 60%; margin-top: 100%;">--%>
                            <img src="images/2.png" class="animated bounceInRight" style="width: 60%; max-width:200px;height:auto;position:absolute;bottom:-20px;left:0;">
                        </div>


                        <blockquote style="height: 55%; margin-top: 46%; padding: 5%;">
                            <div id="ticker">
                                <h3>
                                    <p style="text-align: center;">利郎福利会粉丝团</p>
                                    <span>利郎一年一度的购物狂欢节</span>
                                    <p>2015年12月18日开幕！！！</p>
                                    <p style="margin-top: 10px;">本次主题：狂GO联盟</p>
                                    <p>特邀：</p>
                                    <p>A、蜘蛛侠、变形金刚联盟助阵</p>
                                    <p>B、每天有举办各种演出、活动</p>
                                    <p style="margin-top: 10px;">关注微信公众号“LILANZ利郎商务男装”->点击领票登记->填写姓名、手机号码、身份证号码即可参加抽奖。</p>
                                    <!--  <p style="text-align: right;">——欢迎观赏!！</p>

								 <p>步骤一：使用微信扫描二维码；</p>
								<p>步骤二：关注微信公众号“LILANZ利郎商务男装”；</p>
								<p>步骤三：点击“领取礼品”的图文消息，填写您的身份信息；</p>
								<p style="font-size: 12px;">（姓名，手机号码，身份证号码），提交完毕后您将获取一个用于兑换礼品的二维码；
								在微信公众号“LILANZ利郎商务男装”的功能菜单“我的礼券”可以查询到您当前的礼券信息。</p>
								<p style="margin-top: 12px;">活动期间，每天8:30~9:00到现场凭二维码免费领取价值100元的礼品。</p> -->

                                </h3>

                            </div>
                            <div style="text-align: center">
                                <img src="images/3.png" class="animated fadeIn" style="width: 20%; margin-left: 5%; margin-top: 2%;">
                            </div>
                        </blockquote>

                    </div>
                </div>

 <!--               <div class="sl-slide" data-orientation="vertical" data-slice1-rotation="10" data-slice2-rotation="-15" data-slice1-scale="1.5" data-slice2-scale="1.5">
                    <div class="sl-slide-inner">
                        <img src="images/6.jpg" class="bg-img">
                        <img src="images/6_1.png" class="spin3d">
                        <img src="images/077-078-2.png" class="animated fadeInLeft" style="top: 20%; position: absolute;">
                        <img src="images/081-082-3.png" class="animated fadeInRight" style="left: 32%; top: 20%; z-index: 11111; position: absolute;">
                    </div>
                </div>           -->
 
                <div class="sl-slide" data-orientation="horizontal" data-slice1-rotation="3" data-slice2-rotation="3" data-slice1-scale="2" data-slice2-scale="1">
                        <div class="sl-slide-inner">
                            <img src="images/mt1.jpg" class="bg-img">
                        </div>
                    </div>

                    <div class="sl-slide" data-orientation="vertical" data-slice1-rotation="10" data-slice2-rotation="-15" data-slice1-scale="1.5" data-slice2-scale="1.5">
                        <div class="sl-slide-inner">
                            <img src="images/mt2.jpg" class="bg-img">                           
                        </div>
                    </div>

                  <div class="sl-slide" data-orientation="horizontal" data-slice1-rotation="-25" data-slice2-rotation="-25" data-slice1-scale="2" data-slice2-scale="2">
                    <div class="sl-slide-inner">
                      <img src="images/mt3.jpg" class="bg-img">
                </div>
            </div>

              <div class="sl-slide" data-orientation="horizontal" data-slice1-rotation="3" data-slice2-rotation="3" data-slice1-scale="2" data-slice2-scale="1">
                        <div class="sl-slide-inner">
                            <img src="images/mt4.jpg" class="bg-img">
                        </div>
                    </div>

               <div class="sl-slide" data-orientation="vertical" data-slice1-rotation="10" data-slice2-rotation="-15" data-slice1-scale="1.5" data-slice2-scale="1.5">
                        <div class="sl-slide-inner">
                            <img src="images/mt5.jpg" class="bg-img">                           
                        </div>
                    </div>

                  <div class="sl-slide" data-orientation="horizontal" data-slice1-rotation="-25" data-slice2-rotation="-25" data-slice1-scale="2" data-slice2-scale="2">
                    <div class="sl-slide-inner">
                      <img src="images/mt6.jpg" class="bg-img">
                </div>
            </div>

                <div class="sl-slide" data-orientation="vertical" data-slice1-rotation="10" data-slice2-rotation="-15" data-slice1-scale="1.5" data-slice2-scale="1.5">
                    <div class="sl-slide-inner">
                        <div class="bg-img bg-img-1">
                            <div style="text-align: center; margin-top: 5%;">
                                <a href="#" onclick="gotomap();" onmousedown="gotomap();" onmouseup="gotomap();">
                                    <img src="images/03map.jpg" width="80%" />
                                </a>
                                <p style="color: #fff;">(点击地图查看详情)</p>
                            </div>
                        </div>
                        <blockquote style="margin-top: 75%;">
                            <p><cite>时间</cite>：2015.12.18~2016.01.30</p>
                            <p><cite>地点</cite>：福建省晋江市长兴路利郎总部</p>
                            <p><cite>领票说明</cite>：</p>
                            <p>凭身份证到利郎总部领票处领票两张</p>
                            <p>或拨打客服热线进行预订</p>
                            <p><cite>电话</cite>：82039926&nbsp;&nbsp;82039930&nbsp;&nbsp;82039932</p>
                            <p style="margin-top: 8px;">为了您购物的方便与安全,请勿带大包和1.2米以下的儿童入场。（工作人员有权限制大包不得带入场）</p>
                            </p>
                        </blockquote>
                        <img class="spin2d" src="http://file2.rabbitpre.com/6fcf1446-64fe-4ad4-b85f-8cd5f811d0f1-1671?imageMogr2/quality/70/auto-orient">
                    </div>
                </div>

                <div class="sl-slide" data-orientation="horizontal" data-slice1-rotation="-25" data-slice2-rotation="-25" data-slice1-scale="2" data-slice2-scale="2">
                    <div class="sl-slide-inner">
                        <div class="bg-img bg-img-1">
                        <section class="share-panel">
                              <div id="share-coat" class="share-layer" style="display: none;">
                                <div class="share-tips-block"></div>
                              </div>                                    
                            </section>
                            <img src="images/2.png" class="animated bounceInRight" style="width: 60%; max-width:200px;height:auto;position:absolute;bottom:-20px;left:0;">
                        </div>
                        <h2 style="padding-top: 10px; padding-bottom: 0; margin: 30px auto 0; width: 90%;">订票请关注利郎福利会专用公众号</h2>
                        <blockquote style="width: 90%; margin: 0 auto;">
                            <p>方法一：您可以长按图片，识别二维码。</p>
                            <p>方法二：搜索“lilanz_2013”或搜索“LILANZ利郎商务男装”。</p>
                            <p>方法三：使用“扫一扫”功能扫描二维码。</p>
                            <div style="text-align: center; margin-top: 5%;">
                                <img src="images/code.png" style="width: 60%;"><br>
                                <a class="btn-share"><img src="images/share.png" style="width: 60%;" class="animated shake"></a>
                            </div>
                        </blockquote>
                    </div>
                </div>

<!--                <div class="sl-slide" data-orientation="horizontal" data-slice1-rotation="3" data-slice2-rotation="3" data-slice1-scale="2" data-slice2-scale="1">
                    <div class="sl-slide-inner">
                        <div class="bg-img bg-img-7 animated zoomIn">
                            <section class="share-panel">
                                <div id="share-coat" class="share-layer" style="display: none;">
                                    <div class="share-tips-block"></div>
                                </div>
                                <a class="btn-share">
                                     <img src="images/share.png" style="width: 60%; margin-top: 120%; margin-left: 30%;" class="animated shake"></a>
                                </a>                                   
                            </section>
                        </div>
                    </div>
                </div>   -->

                <div class="tc">
                    <img class="arrowBtn" src="images/arrowBtn.png" alt="" /></div>

            </div>
        </div>
    </div>
    <script src="js/jquery.ba-cond.min.js"></script>
    <script src="js/jquery.slitslider.js"></script>
    <script src="js/jquery.touchSwipe.min.js"></script>
    <!--打字效果-->
    <script type="text/javascript" src="js/jquery.jticker.js"></script>
    <script type="text/javascript" src="http://res.wx.qq.com/open/js/jweixin-1.0.0.js"></script>
    <script type="text/javascript">
        $(function () {
            $('.sl-slider-wrapper').height($(window).height());
            var Page = (function () {
                var $nav = $('#nav-dots > span'), slitslider = $('#slider').slitslider({
                    //interval : 2000, //自动播放时间间隔
                    //autoplay : true, //是否自动播放
                    onBeforeChange: function (slide, pos) {
                        $nav.removeClass('nav-dot-current');
                        $nav.eq(pos).addClass('nav-dot-current');
                    }
                })

                $('body').swipe({
                    swipeUp: function (event, direction, distance, duration, fingerCount) {
                        slitslider.next();
                        $('#share-coat').hide();
                    },
                    swipeDown: function (event, direction, distance, duration, fingerCount) {
                        slitslider.previous();
                        $('#share-coat').hide();
                    }
                });
            })();


            // Instantiate jTicker 
            jQuery("#ticker").ticker({
                cursorList: " ",
                rate: 42,
                delay: 4000
            }).trigger("play").trigger("stop");

            // Trigger events 
            jQuery(".stop").click(function () {
                jQuery("#ticker").trigger("stop");
                return false;
            });

            jQuery(".play").click(function () {
                jQuery("#ticker").trigger("play");
                return false;
            });

            //分享朋友圈
            $('.btn-share').click(function () {
                $('#share-coat').show();
            });
            $('#share-coat').click(function () {
                $('#share-coat').hide();
            });

            //以下是微信开发的JS
            wx.config({
                debug: false, // 开启调试模式,调用的所有api的返回值会在客户端alert出来，若要查看传入的参数，可以在pc端打开，参数信息会通过log打出，仅在pc端时才会打印。
                appId: '<%= wxConfig[0] %>', // 必填，公众号的唯一标识
                timestamp: '<%= wxConfig[1] %>', // 必填，生成签名的时间戳
                nonceStr: '<%= wxConfig[2] %>', // 必填，生成签名的随机串
                signature: '<%= wxConfig[3] %>',// 必填，签名，见附录1
                jsApiList: [
                'onMenuShareTimeline',
                'onMenuShareAppMessage'
                ] // 必填，需要使用的JS接口列表，所有JS接口列表见附录2
            });

            wx.ready(function () {
                // config信息验证后会执行ready方法，所有接口调用都必须在config接口获得结果之后，config是一个客户端的异步操作，所以如果需要在页面加载时就调用相关接口，则须把相关接口放在ready函数中调用来确保正确执行。对于用户触发时才调用的接口，则可以直接调用，不需要放在ready函数中。
                //alert("JS注入成功！");                                
                var sharelink = "http://tm.lilanz.com/2015flh/flhstart.aspx";
                //分享给朋友
                wx.onMenuShareAppMessage({
                    title: '利郎2015福利会狂GO联盟', // 分享标题
                    desc: '2015岁末利郎狂欢购物福利会12月18日开幕！！！', // 分享描述
                    link: sharelink, // 分享链接                    
                    imgUrl: 'http://tm.lilanz.com/2015flh/images/2.png', // 分享图标
                    type: '', // 分享类型,music、video或link，不填默认为link
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
                    title: '2015岁末利郎狂欢购物福利会12月18日开幕！！！', // 分享标题
                    link: 'http://tm.lilanz.com/2015flh/flhstart,aspx', // 分享链接
                    imgUrl: 'http://tm.lilanz.com/2015flh/images/2.png', // 分享图标
                    success: function () {
                        // 用户确认分享后执行的回调函数
                    },
                    cancel: function () {
                        // 用户取消分享后执行的回调函数
                    }
                });
            });
        });

        //打开地图
        function gotomap() {
            window.location.href = "https://open.weixin.qq.com/connect/oauth2/authorize?appid=wxc368c7744f66a3d7&redirect_uri=http%3a%2f%2ftm.lilanz.com%2fOathDump.aspx%3ftoUrl%3dmap.aspx&response_type=code&scope=snsapi_userinfo&state=1#wechat_redirect";
        }
    </script>
</body>
</html>

