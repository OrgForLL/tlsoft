<%@ Page Language="C#" %>

<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">

<script runat="server">
    public string SystemKey = "";
    
    private const int SystemID = 3;     //全渠道系统
    protected void Page_Load(object sender, EventArgs e)
    { 
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
    <link type="text/css" rel="stylesheet" href="../../res/css/StoreSaler/vipliststyle.css" />
    <style type="text/css">
        .search {            
            height:44px;
            margin-top:60px;
            position:relative;
            z-index:201;
            background-color:#f0f0f0;
            padding:0 10px;
            text-align:center;
            box-sizing:border-box;            
        }
        #searchtxt {
            position:absolute;
            outline:none;
            display:block;
            width:92%;
            left:50%;
            margin-left:-46%;
            height:31px;
            margin-top:6px;            
            -webkit-appearance:none;
            border-radius:5px;
            font-size:1.1em;
            padding:0 10px;
            box-sizing:border-box;
            border:1px solid #dedee0;
            text-align:center;
        }
        .mn {
            position:absolute;
            top:0;
            right:10px;
            height:78px;
            line-height:78px;
            float:right;
        }
        .mnums {
            color:#fff;
            font-weight:bold;
            padding:2px 6px;
            background-color:#d9534f;
            border-radius:6px;
            text-align:center;
        }
        .userinfo {
            top:0;
            z-index:2000;
            width:100%;
            height:100%;
            padding:0;
            margin:0;
        }
    </style>
</head>
<body>
    <form id="form1" runat="server">

    <div class="header">        
        <div class="logo">
            <div class="backbtn"><i class="fa fa-chevron-left"></i></div>
            <img src="../../res/img/StoreSaler/lllogo6.png" alt="" />
        </div>
        <!--<div class="tags" onclick="showtags()">打标签</div>-->
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
                            <img src="<%#Eval( "HeaderUrl")%>"/>
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
    <script type="text/javascript">
        var tagsShow = false;

        $(function () {
            FastClick.attach(document.body);
            var obj = $(".vipul").children();
            $(obj).fadeInWithDelay();
        });

        function switchMenu(order) {
            switch (order) {
                case 0:
                    window.location.href = "#";
                    break;
                case 1:
                    window.location.href = "NewVipList.aspx";
                    break;
                case 3:
                    window.location.href = "usercenter.aspx";
                    break;
                default:
                    showLoader("warn", "即将推出,敬请期待!");
                    break;
            }
        }

        function showtags() {
            if (tagsShow) {
                $(".topnav").removeClass("showtags");
                setTimeout(function () {
                    $(".header").css("border-bottom", "1px solid #cbcbcb");
                }, 400);
                $(".tags").text("打标签");
            }
            else {
                $(".header").css("border-bottom", "none");
                $(".topnav").addClass("showtags");
                $(".tags").text("关 闭");
            }
            tagsShow = !tagsShow;
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
            if (tagsShow)
                showtags();
            $(".tags").fadeOut(500);
            $(".backbtn").fadeOut(500);
            $(".userinfo").removeClass("showinfo");
            $(".vipul").removeClass("viewout");
        });

        $(".vipul li").click(function () {
            showLoader("loading", "正在加载...");
            window.location.href = "ChatDetail.aspx?wxid=" + this.id;
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
                    setTimeout(function () {
                        $(".mask").fadeOut(500);
                    }, 1000);
                    break;
                case "error":
                    $(".mask .fa").removeAttr("class").addClass("fa fa-2x fa-close (alias)");
                    $("#loadtext").text(txt);
                    $(".mask").show();
                    setTimeout(function () {
                        $(".mask").fadeOut(500);
                    }, 1500);
                    break;
                case "warn":
                    $(".mask .fa").removeAttr("class").addClass("fa fa-2x fa-warning (alias)");
                    $("#loadtext").text(txt);
                    $(".mask").show();
                    setTimeout(function () {
                        $(".mask").fadeOut(500);
                    }, 1000);
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
</body>
</html>
