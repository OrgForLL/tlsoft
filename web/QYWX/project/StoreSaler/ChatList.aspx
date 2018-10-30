<%@ Page Language="C#" %>

<%@ Import Namespace="System.Collections.Generic" %>
<!DOCTYPE html >

<script runat="server">
    public string SystemKey = "";
    private const int SystemID = 3;     //全渠道系统

    protected void Page_Load(object sender, EventArgs e)
    {
        if (nrWebClass.clsWXHelper.CheckQYUserAuth(true))
        {
            SystemKey = nrWebClass.clsWXHelper.GetAuthorizedKey(SystemID);
            List<string> wxConfig = nrWebClass.clsWXHelper.GetJsApiConfig(SystemID.ToString());

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
    <link rel="stylesheet" type="text/css" href="../../res/css/LeePageSlider.css" />
    <link type="text/css" rel="stylesheet" href="../../res/css/font-awesome.min.css" />
    <link rel="stylesheet" type="text/css" href="../../res/css/StoreSaler/chat.css" />
    <style>
        .msgRow > i {
            font-size: 1.3em;
            line-height: 25px;
            padding: 5px;
        }

        .msgRow.floatfix > i {
            float: right;
        }

        .fa-exclamation-circle {
            color: #d9534f;
        }

        .msg-text .chat-pic {
            width: 70px;
            height: auto;
        }

        .header .notice {
            position: absolute;
            top: 0;
            right: 10px;
            color: #eee;
            line-height: 50px;
            opacity:0;
        }

        .msgRow .chat-time {
            text-align: center;
            padding-bottom: 5px;
            color: #575d6a;
        }
        /*loader css*/
        .mask {
            color: #fff;
            position: absolute;
            top: 0;
            bottom: 0;
            left: 0;
            right: 0;
            z-index: 1000;
            font-size: 1.1em;
            text-align: center;
            display: none;
            background-color: rgba(0,0,0,0.3);
        }

        .loader {
            position: absolute;
            top: 50%;
            left: 50%;
            margin-top: -43px;
            margin-left: -61px;
            background-color: rgba(39, 43, 46, 0.9);
            padding: 15px 25px;
            border-radius: 5px;
        }

        #loadtext {
            margin-top: 5px;
            font-weight: bold;
        }
        /*闪烁动画*/
        @-webkit-keyframes twinkling { /*透明度由0到1*/
            0% {
                opacity: 0;
            }
            100% {
                opacity: 1;
            }
        }

        .twinkle {
            -webkit-animation: twinkling 0.6s infinite alternate-reverse;
        }

        .red-dot {
            position:absolute;
            width:12px;
            height:12px;
            border-radius:50%;
            background-color:#d9534f;
            top:-5px;
            right:-5px;
        }
        .msgRow .message-time {
            text-align: center;
            margin-top: -5px;
            padding-bottom: 10px;
            color: #999;
        }
    </style>
</head>
<body>

    <div class="header">
        <div class="backbtn" onclick="BackFunc()"><i class="fa fa-chevron-left"></i></div>
        <div class="title current-user"></div>
        <span class="notice"><i class="fa fa-commenting-o fa-lg">&nbsp;</i><i id="netstatus"></i></span>
    </div>
    <div id="main" class="wrap-page">
        <!--聊天列表主页-->
        <div class="page page-not-header-footer" id="chat-list">
            <div class="search">
                <input type="text" placeholder="请输入搜索关键字" id="searchtxt" oninput="searchFunc()" />
            </div>
            <ul class="chat-ul">
                <asp:Repeater ID="Repeater1" runat="server">
                    <ItemTemplate>
                        <li id='<%#Eval("Wxid")%>'>
                            <div class="userimg back-image" style="background-image: url(<%#Eval( "HeaderUrl")%>)"></div>
                            <div class="chat-info">
                                <p class="chat-name"><%#Eval("Nick ")%></p>
                                <p class="chat-time"><%#Eval( "lastActive")%></p>
                            </div>
                            <div class="message-nums"><%#Eval("MsgCount")%></div>
                        </li>
                    </ItemTemplate>
                </asp:Repeater>
            </ul>
        </div>
        <!--聊天详情页-->
        <div class="page page-not-header page-right" id="chat-detail">
            <div class="chat-content" id="chat-area">
            </div>
            <div class="chat-operate">
                <div class="chat-input">
                    <input type="text" placeholder="对TA说点什么吧..." id="chat-in" oninput="showSendBtn()" />
                </div>
                <div class="face-con">
                    <div class="center-translate">
                        <img src="../../res/img/storesaler/btn-face.png" id="btn-face" />
                    </div>
                </div>
                <div class="chat-btns">
                    <div class="btn add center-translate">
                        <img src="../../res/img/storesaler/btn-add.png" id="btn-add" />
                        <div id="send-btn" class="btn send center-translate hide">发 送</div>
                    </div>
                </div>
            </div>
        </div>
        <!--多媒体选择页-->
        <div id="chat-media" class="transition page-bot">
            <ul class="media-btns floatfix">
                <li>
                    <input type="file" id="uploadphoto" name="uploadfile" value="请点击上传图片" style="display: none;" />
                    <a href="javascript:void(0);" onclick="uploadphoto.click()">
                        <div class="btn-item">
                            <img src="../../res/img/storesaler/attach-img.png" notneed /><p notneed>照 片</p>
                        </div>
                    </a>
                </li>
            </ul>
        </div>

        <!--emoji表情页-->
        <div id="emoji-wrapper" class="transition page-bot floatfix">
            <div class="wrapper">
            </div>
        </div>
    </div>
    <div class="footer">
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
                <li onclick="javascript:window.location.href='AttractTools.html';">
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
    <div class="mask">
        <div class="loader">
            <div>
                <i class="fa fa-2x fa-spinner fa-pulse"></i>
            </div>
            <p id="loadtext">正在加载...</p>
        </div>
    </div>

    <form id="form1" runat="server">
        <script type="text/javascript">
            var _userid = <%=SystemKey%>
        </script>
        <script type="text/javascript" src="../../res/js/jquery.js"></script>
        <script type='text/javascript' src='../../res/js/StoreSaler/fastclick.min.js'></script>
        <script src="http://ajax.microsoft.com/ajax/jquery.templates/beta1/jquery.tmpl.min.js"></script>
        <script src="/chat/socket.io-1.3.7.js"></script>
        <script src="../../res/js/StoreSaler/LocalResizeIMG.js" type="text/javascript"></script>
        <script src="../../res/js/StoreSaler/mobileBUGFix.mini.js" type="text/javascript"></script>
        <script src="../../res/js/StoreSaler/binaryajax.min.js" type="text/javascript"></script>
        <script src="../../res/js/StoreSaler/exif.min.js" type="text/javascript"></script>
        <script src="../../res/js/jweixin-1.0.0.js" type="text/javascript"></script>
        <script type="text/javascript" src="../../res/js/StoreSaler/chat3.js?_10_"></script>

        <!--聊天详情模板-->
        <script id="tmpchat" type="text/x-jquery-tmpl">
            <div class="msgRow {{if MsgType == 1}} floatfix {{/if}}">
                {{if Order%5 == 0}} <p class="message-time">${Cdate}</p> {{/if}}
                <div class="userimg back-image {{if MsgType == 1}} mine {{/if}}" style="background-image: {{if MsgType != 1}}  url(../../res/img/storesaler/lilanzlogo.jpg) {{else}} url(../../res/img/storesaler/headimg.jpg) {{/if}}"></div>
                <div class="msg-text {{if MsgType != 1}} receive {{else}} send {{/if}}">
                    {{html Content}}
                </div>
            </div>
        </script>
        <script id="tmplist" type="text/x-jquery-tmpl">
            <div class='msgRow floatfix'>
                <div class='userimg back-image mine' style='background-image: url(../../res/img/storesaler/headimg.jpg);'>
                </div>
                <div class='msg-text send' id='msg${{sn}}'>{{html content}}</div>
            </div>
        </script>
        <script id="tmpface" type="text/x-jquery-tmpl">
            <img src='../../res/img/emoji//blank.gif' class='img' style='background: url(../../res/img/emoji//wx-face.png) #siteX#px #siteY#px no-repeat; background-size: 675px 175px;' alt='' />
        </script>
    </form>
</body>
</html>
