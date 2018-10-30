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
    <meta name="viewport" content="width=device-width,initial-scale=1,user-scalable=0" />
    <meta charset="utf-8" />
    <title></title>
    <script type="text/javascript" src="js/jquery-1.10.0.min.js"></script>
    <script type="text/javascript" src="js/resLoader.js"></script>    
    <script type="text/javascript">
        var loader = new resLoader({
            resources: [
                'images/page12_1.png',
                'images/page12_2.png',
                'images/page12_3.png',
                'images/page12_4.png',
                'images/page12_5.png',
                'images/public_1.png',
                'images/light.png',
                'images/1.jpg',
                'images/1.png',
                'images/2.png',
                'images/3.png',
                'images/4.jpg',
                'images/5.jpg',
                'images/6.jpg',
                'images/6_1.png',
                'images/077-078-2.png',
                'images/081-082-3.png',
                'vedio/bgm.mp3',
                'vedio/22.wav',
                'http://file2.rabbitpre.com/6fcf1446-64fe-4ad4-b85f-8cd5f811d0f1-1671?imageMogr2/quality/70/auto-orient',
                'images/code.png',
                'http://file2.rabbitpre.com/788161d9-bccf-40af-b074-ece78407b08f-3819'
            ],
            onStart: function (total) {
                console.log('start:' + total);
            },
            onProgress: function (current, total) {
                //console.log(current + '/' + total);
                var pernums = parseInt(200 / total);
                var leftval = current * pernums + -200 + "px";
                $("#load2").css("left", leftval);
                console.log(leftval);
            },
            onComplete: function (total) {
                document.getElementById("bgm").play();
                $("#load2").css("left", "0px");
                $("#p1").fadeOut(1000);
                setTimeout(function () {                    
                    $("#p2").fadeIn(500);
                    document.getElementById("typebgm").play();
                    !function (t) { "use strict"; var s = function (s, e) { this.el = t(s), this.options = t.extend({}, t.fn.typed.defaults, e), this.isInput = this.el.is("input"), this.attr = this.options.attr, this.showCursor = this.isInput ? !1 : this.options.showCursor, this.elContent = this.attr ? this.el.attr(this.attr) : this.el.text(), this.contentType = this.options.contentType, this.typeSpeed = this.options.typeSpeed, this.startDelay = this.options.startDelay, this.backSpeed = this.options.backSpeed, this.backDelay = this.options.backDelay, this.stringsElement = this.options.stringsElement, this.strings = this.options.strings, this.strPos = 0, this.arrayPos = 0, this.stopNum = 0, this.loop = this.options.loop, this.loopCount = this.options.loopCount, this.curLoop = 0, this.stop = !1, this.cursorChar = this.options.cursorChar, this.shuffle = this.options.shuffle, this.sequence = [], this.build() }; s.prototype = { constructor: s, init: function () { var t = this; t.timeout = setTimeout(function () { for (var s = 0; s < t.strings.length; ++s) t.sequence[s] = s; t.shuffle && (t.sequence = t.shuffleArray(t.sequence)), t.typewrite(t.strings[t.sequence[t.arrayPos]], t.strPos) }, t.startDelay) }, build: function () { var s = this; if (this.showCursor === !0 && (this.cursor = t('<span class="typed-cursor">' + this.cursorChar + "</span>"), this.el.after(this.cursor)), this.stringsElement) { s.strings = [], this.stringsElement.hide(); var e = this.stringsElement.find("p"); t.each(e, function (e, i) { s.strings.push(t(i).html()) }) } this.init() }, typewrite: function (t, s) { if (this.stop !== !0) { var e = Math.round(70 * Math.random()) + this.typeSpeed, i = this; i.timeout = setTimeout(function () { var e = 0, r = t.substr(s); if ("^" === r.charAt(0)) { var o = 1; /^\^\d+/.test(r) && (r = /\d+/.exec(r)[0], o += r.length, e = parseInt(r)), t = t.substring(0, s) + t.substring(s + o) } if ("html" === i.contentType) { var n = t.substr(s).charAt(0); if ("<" === n || "&" === n) { var a = "", h = ""; for (h = "<" === n ? ">" : ";"; t.substr(s).charAt(0) !== h;) a += t.substr(s).charAt(0), s++; s++, a += h } } i.timeout = setTimeout(function () { if (s === t.length) { if (i.options.onStringTyped(i.arrayPos), i.arrayPos === i.strings.length - 1 && (i.options.callback(), i.curLoop++, i.loop === !1 || i.curLoop === i.loopCount)) return; i.timeout = setTimeout(function () { i.backspace(t, s) }, i.backDelay) } else { 0 === s && i.options.preStringTyped(i.arrayPos); var e = t.substr(0, s + 1); i.attr ? i.el.attr(i.attr, e) : i.isInput ? i.el.val(e) : "html" === i.contentType ? i.el.html(e) : i.el.text(e), s++, i.typewrite(t, s) } }, e) }, e) } }, backspace: function (t, s) { if (this.stop !== !0) { var e = Math.round(70 * Math.random()) + this.backSpeed, i = this; i.timeout = setTimeout(function () { if ("html" === i.contentType && ">" === t.substr(s).charAt(0)) { for (var e = ""; "<" !== t.substr(s).charAt(0) ;) e -= t.substr(s).charAt(0), s--; s--, e += "<" } var r = t.substr(0, s); i.attr ? i.el.attr(i.attr, r) : i.isInput ? i.el.val(r) : "html" === i.contentType ? i.el.html(r) : i.el.text(r), s > i.stopNum ? (s--, i.backspace(t, s)) : s <= i.stopNum && (i.arrayPos++, i.arrayPos === i.strings.length ? (i.arrayPos = 0, i.shuffle && (i.sequence = i.shuffleArray(i.sequence)), i.init()) : i.typewrite(i.strings[i.sequence[i.arrayPos]], s)) }, e) } }, shuffleArray: function (t) { var s, e, i = t.length; if (i) for (; --i;) e = Math.floor(Math.random() * (i + 1)), s = t[e], t[e] = t[i], t[i] = s; return t }, reset: function () { var t = this; clearInterval(t.timeout); var s = this.el.attr("id"); this.el.after('<span id="' + s + '"/>'), this.el.remove(), "undefined" != typeof this.cursor && this.cursor.remove(), t.options.resetCallback() } }, t.fn.typed = function (e) { return this.each(function () { var i = t(this), r = i.data("typed"), o = "object" == typeof e && e; r || i.data("typed", r = new s(this, o)), "string" == typeof e && r[e]() }) }, t.fn.typed.defaults = { strings: ["These are the default values...", "You know what you should do?", "Use your own!", "Have a great day!"], stringsElement: null, typeSpeed: 0, startDelay: 0, backSpeed: 0, shuffle: !1, backDelay: 500, loop: !1, loopCount: !1, showCursor: !0, cursorChar: "|", attr: null, contentType: "html", callback: function () { }, preStringTyped: function () { }, onStringTyped: function () { }, resetCallback: function () { } } }(window.jQuery);

                    $(function () {
                        $('#ticker').typed({
                            strings: [
                              "近日，福建晋江利郎总部上空频现神秘红光....<br />这道神秘红光究竟是什么？？？ ^1000"
                            ],
                            typeSpeed: 40,
                            showCursor: false
                        });
                    });
                }, 1000);
            }
        });

        setTimeout(function () {
            loader.start();
        }, 1000);
    </script>
    <style type="text/css">
        * {
            padding: 0;
            margin: 0;
        }

        body {
            background: #808080;
        }

        .page {
            position: fixed;
            width: 100%;
            height: 100%;            
        }

        #p1 {
            background: url('images/page12_1.png') #808080;  
            background-size: cover;
            /*display:none;*/ 
            z-index:100;
        }

        #p2 {
            background: url('images/public_1.png') #808080;  
            background-size: cover;
            z-index:99;   
            display:none;         
        }

        .bg1, .bg2 {
            position:absolute;
            top:120px;
            left:50%;
            margin-left:-100px;
        }
        .bg1 {
            width: 200px;            
        }

            .bg1 img,.bg2 img {
                width: 200px;
                height: auto;
            }
            .bg1 img {
                -webkit-animation: myrotate 2s linear infinite; 
                animation: myrotate 2s linear infinite;
            }
        .bg2 img {
            -webkit-animation: rerotate 2s linear infinite;
            animation: rerotate 2s linear infinite;
        }

        #load3, #load4 {
            position:absolute;
            top:30%;
            left:-40px;
        }
            #load3 img,#load4 img {
                width:120px;
                height:auto;
            }

            #load3 img {
                -webkit-animation: myrotate 2s linear infinite; 
                animation: myrotate 2s linear infinite;
            }

            #load4 img {
                -webkit-animation: rerotate 2s linear infinite;
                animation: rerotate 2s linear infinite;
            }

        @-webkit-keyframes myrotate {
            from {
                -webkit-transform: rotateZ(0deg);
            }

            50% {
                -webkit-transform: rotateZ(180deg);
            }

            to {
                -webkit-transform: rotateZ(360deg);
            }
        }

        @keyframes myrotate {
            from {
                transform: rotateZ(0deg);
            }

            50% {
                transform: rotateZ(180deg);
            }

            to {
                transform: rotateZ(360deg);
            }
        }

        @-webkit-keyframes rerotate {
            from {
                -webkit-transform: rotateZ(360deg);
            }

            50% {
                -webkit-transform: rotateZ(180deg);
            }

            to {
                -webkit-transform: rotateZ(0deg);
            }
        }

        @keyframes rerotate {
            from {
                transform: rotateZ(360deg);
            }

            50% {
                transform: rotateZ(180deg);
            }

            to {
                transform: rotateZ(0deg);
            }
        }

        .loading {
            position:absolute;
            color:#fff;
            top:380px;
            width:200px;
            height:20px;
            left:50%;
            margin-left:-100px; 
            overflow:hidden;           
        }

        #load2 {
            position:absolute;
            top:0;
            left:-200px;
        }

        .light {
            position:absolute;
        }

        #l1 {
            top: 0;
            left: -200px;
            -webkit-animation: moving 3s linear infinite;
            animation: moving 3s linear infinite;            
        }

        #l2 {
            top: 100px;
            left: -200px;
            -webkit-animation: moving 3s linear infinite;
            animation: moving 3s linear infinite;
            -webkit-animation-delay: 2s;
            animation-delay: 2s;
        }
        
        #l3 {
            top: 200px;
            left: -200px;            
            animation: moving 3s linear infinite;
            -webkit-animation: moving 3s linear infinite;
            animation-delay:4s;
            -webkit-animation-delay:4s;
        }

        @keyframes moving {
            from {
                transform:translate(0px, -100px);                
            }
            30% {
                transform:translate(700px, 100px);                
            }
            to {
                transform:translate(700px, 100px);                
            }
        }

        @-webkit-keyframes moving {
            from {                
                -webkit-transform: translate(0px, -100px);
            }

            30% {                
                -webkit-transform: translate(700px, 100px);
            }

            to {                
                -webkit-transform: translate(700px, 100px);
            }
        }

        #txt,#ticker {
            position:absolute;                 
            top:60px;
            left:50%;
            margin-left:-90px;                        
            padding:20px;
        }
            #txt img {
                width:240px;
                height:auto;
            }
        #ticker {            
            width:160px;
            top:60px;
            padding:0px 0 0 20px;            
            color:rgb(2,181,182);
            font-size:1.2em;
            font-weight:bold;
            text-shadow:1px 1px 2px #333;
        }
        .btn {
            position:absolute;
            left:50%;
            margin-left:-40px;
            bottom:30px;
            width:80px;
            text-align:center;            
            border:1px solid rgb(2,181,182);
            padding:10px;   
            border-radius:10px;
            -webkit-animation: zdjpop 0.8s infinite;         
        }
            .btn a {
                text-decoration: none;
                font-size: 0.8em;
                color: #fff;
            }
        .hand {
            position: absolute;
            left: 50%;
            margin-left: -20px;
            bottom: 65px;
            -webkit-animation: start 1.5s infinite ease-in-out;         
            animation: start 1.5s infinite ease-in-out;
        }
            .hand img {
                width: 50px;
                height: 60px;
            }
        @-webkit-keyframes start {
            0%,30% {
                opacity: 0;
                -webkit-transform: translate(0,-10px);
            }

            60% {
                opacity: 1;
                -webkit-transform: translate(0,0);
            }

            100% {
                opacity: 0;
                -webkit-transform: translate(0,10px);
            }
        }

        @keyframes start {
            0%,30% {
                opacity: 0;
                transform:  translate(0,-10px);
            }

            60% {
                opacity: 1;
                transform:  translate(0,0);
            }

            100% {
                opacity: 0;
                transform:  translate(0,10px);
            }
        }
        @-webkit-keyframes zdjpop {
            0% {
                opacity: 0;
                -webkit-transform: scale(1);
            }
            80% {
                opacity: 1;
                -webkit-transform: scale(1.3);
            }
            100% {
                opacity: 1;
                -webkit-transform: scale(1.3);
            }
        }
    </style>
</head>

<body>
    <audio id="bgm" loop="loop">
        <source src="vedio/bgm.mp3" type="audio/mp3" />
        <source src="vedio/bgm.ogg" type="audio/ogg" />
    </audio>
    <audio id="typebgm">
        <source src="vedio/22.wav"/>        
    </audio>
    <div class="page" id="p1">
        <div class="bg1">
            <img src="images/page12_2.png" />
        </div>
        <div class="bg2">
            <img src="images/page12_3.png" />
        </div>
        <div class="loading">
            <div id="load1"><img src="images/page12_4.png" width="200px" height="20px" /></div>
            <div id="load2"><img src="images/page12_5.png" width="200px" height="20px" /></div>
        </div>
    </div> 
    <div class="page" id="p2">
        <div class="light" id="l1"><img src="images/light.png" /></div>    
        <div class="light" id="l2"><img src="images/light.png" /></div>
        <div class="light" id="l3"><img src="images/light.png" /></div>                  
        <div id="load3"><img src="images/page2_3.png" /></div>
        <div id="load4"><img src="images/page2_2.png" /></div>
        <div id="txt">
            <img src="images/page2_6.png" />
            <div id="ticker">
            </div>
        </div>
        <div class="hand"><img src="images/handpoint.png" /></div>
        <div class="btn"><a href="index.aspx">启动搜索装置</a></div>
    </div> 
    <script type="text/javascript" src="js/jquery.jticker.js"></script>
    <script type="text/javascript" src="http://res.wx.qq.com/open/js/jweixin-1.0.0.js"></script>
    <script type="text/javascript">
        $(function () {
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
                    link: 'http://tm.lilanz.com/2015flh/flhstart.aspx', // 分享链接
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
    </script>     
</body>
</html>
