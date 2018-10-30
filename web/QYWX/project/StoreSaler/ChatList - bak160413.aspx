<%@ Page Language="C#" %>
<%@ Import Namespace="nrWebClass" %>
<%@ Import Namespace="weChat" %>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">

<script runat="server">
    public string SystemKey = "";

    private const int SystemID = 3;     //全渠道系统
    protected void Page_Load(object sender, EventArgs e)
    {
        Session["qy_customersid"] = "354";
        if (nrWebClass.clsWXHelper.CheckQYUserAuth(true))
        {
            SystemKey = nrWebClass.clsWXHelper.GetAuthorizedKey(SystemID);

            if (SystemKey == "" || SystemKey == "0")
            {
                nrWebClass.clsWXHelper.ShowError("对不起！您还没有开通全渠道系统权限！");
            }
            else
            {
                wechat.Chat wx = new wechat.Chat();
                Repeater1.DataSource = wx.Users(Convert.ToInt32(SystemKey));
                Repeater1.DataBind();

            }
        }
    }
</script>

<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <title></title>
    <meta name="viewport" content="width=device-width,initial-scale=1,user-scalable=0" />
    <meta name="format-detection" content="telephone=no" />
    <link type="text/css" rel="stylesheet" href="../../res/css/font-awesome.min.css" />
    <link type="text/css" rel="stylesheet" href="../../res/css/StoreSaler/ChatList.css" />

    <style type="text/css">
        .search {
            height: 44px;
            margin-top: 60px;
            position: relative;
            z-index: 201;
            background-color: #f0f0f0;
            padding: 0 10px;
            text-align: center;
            box-sizing: border-box;
        }

        #searchtxt {
            position: absolute;
            outline: none;
            display: block;
            width: 92%;
            left: 50%;
            margin-left: -46%;
            height: 31px;
            margin-top: 6px;
            -webkit-appearance: none;
            border-radius: 5px;
            font-size: 1.1em;
            padding: 0 10px;
            box-sizing: border-box;
            border: 1px solid #dedee0;
            text-align: center;
        }

        .mn {
            position: absolute;
            top: 0;
            right: 10px;
            height: 78px;
            line-height: 78px;
            float: right;
        }

        .mnums {
            color: #fff;
            font-weight: bold;
            padding: 2px 6px;
            background-color: #d9534f;
            border-radius: 6px;
            text-align: center;
        }

        .backbtn {
            position: absolute;
            top: 0;
            bottom: 0;
            line-height: 60px;
            font-size: 1.4em;
            color: #b1afaf;
            left: 0;
            padding: 0 20px;
            border-right: 1px solid #161A1C;
            padding: 15px 20px;
        }

            .backbtn:hover {
                background-color: rgba(0,0,0,0.4);
            }

        .view {
            position: absolute;
            top: 0;
            left: 0;
            z-index: 99;
            display: none;
            width: 100%;
            height: 100%;
        }
        /*转场*/
        .current {
            z-index: 100;
            display: block;
        }

            .current.out {
                -webkit-transition: -webkit-transform 400ms;
                -webkit-transform: translate3d(-100%,0,0);
            }

        .next {
            display: block;
            -webkit-transform: translate3d(100%,0,0);
        }

            .next.in {
                -webkit-transition: -webkit-transform 400ms;
                -webkit-transform: translate3d(0,0,0);
            }
        /*转场 End*/
        .chat-header {
            display: block;
            position: absolute;
            top: 0;
            left: 0;
            width: 100%;
            z-index: 211;
            height: 42px;
            background-color: #272b2e;
            border-bottom: 1px solid #161A1C;
            padding: 10px 10px 0px 0px;
            box-sizing: border-box;
        }
        /*聊天页面*/
        .container {
            position: absolute;
            width: 100%;
            box-sizing: border-box;
            overflow-x: hidden;
            overflow-y: auto;
            -webkit-overflow-scrolling: touch;
            bottom: 60px;
            top: 0;
            left: 0;
            right: 0;
            z-index: -1;
        }

        .footer {
            position: absolute;
            width: 100%;
            height: 50px;
            background-color: #fff;
            border-top: 1px solid #ddd;
            padding: 7px;
            box-sizing: border-box;
            bottom: 0;
            left: 0;
            z-index: 200;
            display: block;
        }

            .footer input {
                -webkit-appearance: none;
                border: 1px solid #e0e0e0;
                height: 36px;
                line-height: 36px;
                width: 82%;
                font-size: 1.2em;
                box-sizing: border-box;
                padding: 0 5px;
                color: #505050;
                border-radius: 5px;
            }

        .sendbtn {
            width: 16%;
            float: right;
            height: 36px;
            line-height: 36px;
            font-size: 1.1em;
            box-sizing: border-box;
            text-align: center;
            cursor: pointer;
        }

            .sendbtn p {
                box-shadow: 0 0 2px #ccc;
            }

        .message img {
            width: 20%;
            float: left;
            border-radius: 50%;
            max-width: 44px;
            margin-top: 20px;
            margin-right: 10px;
        }

        .message .bubble span {
            background-color: #fff;
            padding: 12px 10px;
            border-radius: 5px;
            line-height: 22px;
            border: 1px solid #dfdfdf;
            margin-top: 20px;
            float: left;
        }

        .container div.message.right .bubble {
            /*background:#a0e759;*/
            float: right;
            /*border-color:#a0d56b;*/
        }

            .container div.message.right .bubble span {
                background: #a0e759;
                border-color: #a0d56b;
                float: right;
            }

        .container div.message.right img {
            float: right;
            margin-right: 2px;
            margin-left: 10px;
        }

        .message img {
            width: 20%;
            float: left;
            border-radius: 50%;
            max-width: 44px;
            margin-top: 20px;
            margin-right: 10px;
        }
    </style>
</head>
<body>
    <form id="form1" runat="server">
        <div class="view current" id="pageList">
            <div class="header">
                <div class="logo">
                    <img src="../../res/img/StoreSaler/lllogo6.png" alt="" />
                </div>
            </div>
            <div class="container">
                <div class="viplist">
                    <div class="search">
                        <input id="searchtxt" type="text" placeholder="请输入昵称关键字" />
                    </div>
                    <ul class="vipul" id="prevent-scroll">
                        <asp:Repeater ID="Repeater1" runat="server">
                            <ItemTemplate>
                                <li id='<%#Eval("Wxid")%>'>
                                    <div class="userimg">
                                        <img src="<%#Eval( "HeaderUrl")%>" />
                                    </div>
                                    <h3><%#Eval("Nick ")%></h3>
                                    <p><%#Eval( "lastActive")%></p>
                                    <div class="mn"><span class="mnums"><%#Eval("MsgCount")%></span></div>
                                </li>
                            </ItemTemplate>
                        </asp:Repeater>
                    </ul>
                </div>
            </div>
            <div class="bottomnav">
                <ul class="navul floatfix">
                    <li onclick="switchMenu(0)" id="selected">
                        <i class="fa fa-comments"></i>
                        <p>消 息</p>
                    </li>
                    <li onclick="switchMenu(1)">
                        <i class="fa fa-users"></i>
                        <p>客 户</p>
                    </li>
                    <li onclick="switchMenu(2)">
                        <i class="fa fa-retweet"></i>
                        <p>引 流</p>
                    </li>
                    <li onclick="switchMenu(3)">
                        <i class="fa fa-user"></i>
                        <p>我 的</p>
                    </li>
                </ul>
            </div>
        </div>
        <!--聊天页面-->
        <div class="view in" id="pageChat">
            <!--<div class="chat-header">                 
            <div class="backbtn"><i class="fa fa-chevron-left"></i></div>
            姚诺维
        </div>-->

            <div class="container" id="messagebox">
            </div>
            <div class="footer">
                <input type="text" id="areatxt" placeholder="对Ta说点什么..." />
                <div class="sendbtn">
                    <p>发 送</p>
                </div>
            </div>
        </div>
        <!--聊天页面 结束-->
        <div class="mask">
            <div class="loader">
                <div>
                    <i class="fa fa-2x fa-spinner fa-pulse"></i>
                </div>
                <p id="loadtext">正在加载...</p>
            </div>
        </div>
    </form>
    <script type="text/javascript" src="../../res/js/jquery.js"></script>
    <script type='text/javascript' src='../../res/js/StoreSaler/fastclick.min.js'></script>
    <script src="http://ajax.microsoft.com/ajax/jquery.templates/beta1/jquery.tmpl.min.js"></script>
    <script src="/chat/socket.io-1.3.7.js"></script>
    <script type="text/javascript">
        var tagsShow = false;
        var socket = null;
        var currentWxid = "";
        $(function () {
            FastClick.attach(document.body);
            var obj = $(".vipul").children();
            $(obj).fadeInWithDelay();

            socket = io.connect('http://tm.lilanz.com/chat');
            socket.on('newmessage', function (data) {

                var data = { MsgType: 1, Content: data.message };
                $('#tmpchat').tmpl(data).appendTo("#messagebox");

                posttionReset();
            });
            socket.emit('send', { my: 'data' });

            $(".sendbtn").click(function () {
                var txt = $("#areatxt").val();

                if (txt == "") {
                    alert("说点东西吧....");
                    return;
                }
                else {
                    var data = { MsgType: 0, Content: txt };
                    var rel = socket.emit('sendMessage', { message: txt, touser: currentWxid });
                    $('#tmpchat').tmpl(data).appendTo("#messagebox");
                    $("#areatxt").val('');

                    posttionReset();
                }

            });
        });

        function posttionReset() {
            var obj = document.getElementById("messagebox");
            $("#messagebox").animate({ scrollTop: (obj.scrollHeight - obj.clientHeight) + 'px' }, 400);
        }

        function switchMenu(order) {
            switch (order) {
                case 0:
                    window.location.href = "#";
                    break;
                case 1:
                    window.location.href = "NewVipList.aspx";
                    break;
                case 2:
                    showLoader("warn", "正在开发中...");
                    break;
                case 3:
                    window.location.href = "usercenter.aspx";
                    break;
                default:
                    showLoader("warn", "正在开发中...");
                    setTimeout(function () {
                        $(".mask").hide();
                    }, 1000);
                    break;
            }
        }


        $(".tagitemul li").click(function (e) {
            var obj = $(e.target);
            if (obj.hasClass("tagselected"))
                obj.removeClass("tagselected");
            else
                obj.addClass("tagselected");
        });

        function showUserInfo(userid) {
            $(".tags").fadeIn(500);
            $(".vipul").addClass("viewout");
            $(".userinfo").addClass("showinfo");
        }

        $(".backbtn").click(function () {
            //$("#pageChat").addClass("out");
            $("#pageList").addClass("current");
            $("#pageChat").removeClass("current");
        });

        $(".vipul li").click(function (e) {
            $("#pageList").removeClass("current out");
            $("#pageChat").removeClass("next in").addClass("current");
            currentWxid = this.id;
            $('#messagebox').html("");
            var url = "/oa/webbll/chatdetail.ashx?wxid=" + currentWxid + "&_=" + escape(new Date());

            showLoader("loading", "正在加载...");

            $.getJSON(url, function (data) {
                $('#tmpchat').tmpl(data).appendTo("#messagebox");
                $(".mask").hide();
                posttionReset();
            });
            //$("#pageList").removeClass("current");
            //showLoader("loading", "正在加载...");
            //setTimeout(function () {
            //    $(".mask").hide();
            //    $(".tags").fadeIn(500);
            //    $(".backbtn").fadeIn(500);
            //    $(".vipul").addClass("viewout");
            //    $(".userinfo").addClass("showinfo");
            //}, 500);
            //window.location.href = "ChatDetail.aspx?wxid=" + this.id;
        });

        $("#subtags").click(function () {
            showLoader("loading", "正在提交...");
            setTimeout(function () {
                showLoader("successed", "提交成功！");
                setTimeout(function () {
                    $(".mask").hide();
                }, 1000);
            }, 1000);
        });

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
                    break;
                case "error":
                    $(".mask .fa").removeAttr("class").addClass("fa fa-2x fa-close (alias)");
                    $("#loadtext").text(txt);
                    $(".mask").show();
                    break;
                case "warn":
                    $(".mask .fa").removeAttr("class").addClass("fa fa-2x fa-warning (alias)");
                    $("#loadtext").text(txt);
                    $(".mask").show();
                    break;
            }
        }

        //搜索框实时本地检索
        $("#searchtxt").bind("input propertychange", function () {
            var obj = $(".vipul li h3");
            if (obj.length > 0) {
                var stxt = $("#searchtxt").val();
                for (var i = 0; i < obj.length; i++) {
                    if (obj.eq(i).text().indexOf(stxt) == -1)
                        $(".vipul li").eq(i).hide();
                    else
                        $(".vipul li").eq(i).show();
                }
            }
        });

        $.fn.fadeInWithDelay = function () {
            var delay = 0;
            return this.each(function () {
                $(this).delay(delay).animate({ opacity: 1 }, 200);
                delay += 100;
            });
        };
    </script>
    <script id="tmpchat" type="text/x-jquery-tmpl">
        <div class='message floatfix {{if MsgType != 1}} right {{/if}}'>
            <div class='headimg'>
                <img src='../../res/img/storesaler/lilanzlogo.jpg' />
            </div>
            <div class='bubble'>
                <span>${Content}</span>
            </div>
        </div>
    </script>
</body>
</html>
