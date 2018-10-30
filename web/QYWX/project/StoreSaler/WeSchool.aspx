<%@ Page Title="销售内功" Language="C#" MasterPageFile="../../WebBLL/frmQQDBase.Master" AutoEventWireup="true" %>

<%@ MasterType VirtualPath="../../WebBLL/frmQQDBase.Master" %>

<%@ Import Namespace="System.Collections" %>
<%@ Import Namespace="System.Collections.Generic" %>
<%@ Import Namespace="nrWebClass" %>
<%@ Import Namespace="System.Data" %>

<script runat="server">
    public string strCname = "";
    public string strMobile = "";    
    public string strFace = "";    
    protected void Page_PreRender(object sender, EventArgs e)
    {        
        if (!this.IsPostBack)
        {
            clsWXHelper.CheckQQDMenuAuth(2);    //检查菜单权限
            
            string errinfo = "";
            string connectstring = System.Configuration.ConfigurationManager.ConnectionStrings["Conn"].ConnectionString;        //62的连接字符串
            using (LiLanzDALForXLM dal = new LiLanzDALForXLM(connectstring))
            {
                //获取店员头像            
                DataTable dt = new DataTable();
                string strSQL = string.Concat(@"SELECT TOP 1 cname,avatar,mobile,email FROM wx_t_customers WHERE id=", Session["qy_customersid"]);
                errinfo = dal.ExecuteQuery(strSQL, out dt);
                if (errinfo == "")
                {
                    if (dt.Rows.Count > 0)
                    {
                        strCname = Convert.ToString(dt.Rows[0]["cname"]);
                        strFace = Convert.ToString(dt.Rows[0]["avatar"]);
                        strMobile = Convert.ToString(dt.Rows[0]["mobile"]);
                        if (clsWXHelper.IsWxFaceImg(strFace))
                            strFace = clsWXHelper.GetMiniFace(strFace);
                        else
                            strFace = clsConfig.GetConfigValue("OA_WebPath") + strFace;
                    }
                    else
                    {
                        clsWXHelper.ShowError("获取个人信息失败！");
                    }
                    dt.Clear(); dt.Dispose(); dt = null;
                }
                else
                {
                    clsWXHelper.ShowError("获取个人信息时发生错误！错误：" + errinfo);
                }
            }
        }       
    }

    protected void Page_Load(object sender, EventArgs e)
    {
        //this.Master.IsTestMode = true;
    }
</script>

<asp:Content ID="Content1" ContentPlaceHolderID="head" runat="server">
    <link type="text/css" rel="stylesheet" href="../../res/css/font-awesome.min.css" />
    <link type="text/css" rel="stylesheet" href="../../res/css/StoreSaler/flickity.css" media="screen" />
    <style type="text/css">
        * {
            padding: 0;
            margin: 0;
        }

        body {
            font-family: Helvetica,Arial,"Hiragino Sans GB","Microsoft Yahei","微软雅黑",STHeiti,"华文细黑",sans-serif;
            font-size: 1.2em;
            background-color: #f0f0f0;
            overflow:hidden;            
        }

        .container2 {
            max-width: 620px;
            margin: 0 auto;
            overflow-x: hidden;
            bottom: initial;
        }

        .top {
            width: 100%;
            height: 66px;
            background-color: #272b2e;
            position: fixed;
            top: 0;
            left: 0;
            border-bottom: 1px solid #444;
            padding: 10px 0px 10px 25px;
            box-sizing: border-box;
            color: #fff;
            overflow: hidden;
            z-index: 100;
        }

            .top div {
                float: left;
            }

        .headimg {
            width: 42px;
            height: 42px;
            border: 2px solid #fff;
            border-radius: 50%;
            -webkit-border-radius: 50%;
            background-image: url(<%=strFace%>);
            background-size: cover;
        }

        .top img {
            width: 100%;
            height: auto;
        }

        .userinfo {
            margin-left: 5px;
            height: 46px;
            font-size: 18px;
            line-height: 46px;
            padding-left: 15px;
        }

        .wxnick {
            letter-spacing: 2px;
        }

        .wxnums {
            font-size: 0.8em;
            white-space: nowrap;
            text-overflow: ellipsis;
            overflow: hidden;
            line-height: 20px;
        }

        .floatfix:after {
            content: "";
            display: table;
            clear: both;
        }

        .icons {
            position:absolute;
            width: 100%;
            top:66px;
            bottom:57px;
            left:0;
            overflow-x:hidden;
            overflow-y:auto;                    
            -webkit-overflow-scrolling: touch;
            overflow-scrolling: touch;                   
        }

        .bottomnav {
            height: 56px;
            background-color: #f8f8f8;
            width: 100%;
            position: fixed;
            bottom: 0;
            left: 0;
            border-top: 1px solid #cbcbcb;
            font-size: 16px;
        }

        .navul {
            list-style: none;
            padding: 10px 0;
            box-sizing: border-box;
        }

            .navul li {
                width: 25%;
                float: left;
                text-align: center;
                height: 40px;
                color: #989898;
                cursor: pointer;
            }

            .navul i {
                display: block;
                font-size: 1.2em;
            }

            .navul p {
                font-weight: 400;
                font-size: 0.8em;
                line-height: 24px;
            }

        #selected {
            color: #272b2e;
        }

        .rightset {
            position: absolute;
            right:0;            
            top: 0;
            font-size: 1.2em;
            line-height: 66px;
            vertical-align: middle;
            padding:0 20px;
        }

        .cube3d {
            -webkit-transform: translateZ(0);
            -moz-transform: translateZ(0);
            -ms-transform: translateZ(0);
            -o-transform: translateZ(0);
            transform: translateZ(0);
        }

        .gallery {
            max-width: 600px;
            margin: 0 auto;
        }

            .gallery img {
                height: 190px;
                width: auto;
            }

        .flickity-page-dots {
            bottom: -22px;
        }

            /* dots are lines */
            .flickity-page-dots .dot {
                height: 4px;
                width: 40px;
                margin: 0;
                border-radius: 0;
            }

        .flickity-page-dots {
            bottom: 4px;
        }

        .flickity-prev-next-button {
            border-radius: 2px;
            width: 30px;
            height: 36px;
        }

        .iconul {
            list-style: none;
            text-align: center;
            padding: 0 10px;
        }

            .iconul li {
                float: left;
                width: 33.33%;
                padding: 10px;
                box-sizing: border-box;
            }

        .circlebg {
            width: 60px;
            height: 80px;
            border-radius: 50%;
            margin: 0 auto;
        }

            .circlebg img {
                width: 60px;
                height: 60px;
            }

            .circlebg p {
                font-size: 14px;
                margin-top: -4px;
                color: #555;
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
            font-size: 1em;
            text-align: center;
            display:none;
        }

        .loader {
            position: absolute;
            top: 50%;
            left: 50%;
            width: 200px;
            height: 90px;
            margin-top: -50px;
            margin-left: -100px;
            background-color: #272b2e;
            padding: 15px 25px;
            border-radius: 5px;
            box-sizing: border-box;
            box-shadow: 0px 0px 1px #555;
        }

        #loadtext {
            margin-top: 5px;
            font-weight: bold;
            font-size:0.8em;
        }
    </style>
</asp:Content>

<asp:Content ID="Content2" ContentPlaceHolderID="ContentPlaceHolder1" runat="server">
    <div class="container2">
        <div class="top">
            <div class="headimg"></div>
            <div class="userinfo">
                <p class="wxnick">您好,<%=strCname%></p>
            </div>
            <div class="rightset"><i class="fa fa-share-alt"></i></div>
        </div>
        <div class="icons">
            <div style="width: 100%; height: 190px;">
                <div class="gallery  gallery--line-dots js-flickity"
                    data-flickity-options='{ "imagesLoaded": false, "percentPosition": false, "autoPlay":3000,"contain":true }'>
                    <img src="../../res/img/StoreSaler/slider1.jpg?t=20160419" alt="" />
                    <img src="../../res/img/StoreSaler/slider2.jpg?t=20160419" alt="" />
                    <img src="../../res/img/StoreSaler/slider3.jpg?t=20160419" alt="" />
                    <img src="../../res/img/StoreSaler/slider4.jpg?t=20160419" alt="" />
                    <img src="../../res/img/StoreSaler/slider5.jpg?t=20160419" alt="" /> 
                </div>
            </div>
            <div class="iconlist floatfix">
                <ul class="iconul floatfix">
                    <li onclick="clickgo('bktj')">
                        <div class="circlebg">
                            <img src="../../res/img/StoreSaler/bktj.png" alt="" />
                            <p>爆款推荐</p>
                        </div>
                    </li>
                    <li onclick="clickgo('cpmd')">
                        <div class="circlebg">
                            <img src="../../res/img/StoreSaler/cpmd.png" alt="" />
                            <p>产品卖点</p>
                        </div>
                    </li>
                    <li onclick="clickgo('clzc')">
                        <div class="circlebg">
                            <img src="../../res/img/StoreSaler/clzc.png" alt="" />
                            <p>陈列转场</p>
                        </div>
                    </li>
                    <li onclick="clickgo('cctg')">
                        <div class="circlebg">
                            <img src="../../res/img/StoreSaler/cctg.png" alt="" />
                            <p>橱窗推广</p>
                        </div>
                    </li>
                    <li onclick="clickgo('lxqs')">
                        <div class="circlebg">
                            <img src="../../res/img/StoreSaler/lxqs.png" alt="" />
                            <p>流行趋势</p>
                        </div>
                    </li>
                </ul>
            </div>
        </div>
        <div class="bottomnav">
            <ul class="navul floatfix">
                <li onclick="switchMenu(0)" id="selected">
                    <i class="fa fa-desktop"></i>
                    <p>首 页</p>
                </li>
                <li onclick="switchMenu(1)">
                    <i class="fa fa-tasks"></i>
                    <p>利 郎 圈</p>
                </li>
                <li onclick="switchMenu(2)">
                    <i class="fa fa-pencil"></i>
                    <p>学习笔记</p>
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
                <i class="fa fa-2x fa-warning (alias)"></i>
            </div>
            <p id="loadtext">正在开发中...</p>
        </div>
    </div>
    <script type="text/javascript" src="../../res/js/jquery.js"></script>
    <script type='text/javascript' src='../../res/js/StoreSaler/fastclick.min.js'></script>
    <script type='text/javascript' src='../../res/js/StoreSaler/flickity.pkgd.min.js'></script>
    <script type="text/javascript">
        $(function () {
            FastClick.attach(document.body);
        });

        function switchMenu(order) {
            //$(".navul li[id=selected]").removeAttr("id");
            //$(".navul li").eq(order).attr("id", "selected");

            switch (order) {
                case 0:
                    window.location.href = "WeSchool.aspx";
                    break;
                case 1:
                    window.location.href = "http://tm.lilanz.com/wxDevelopment/WebBLL/LilanzGroupProject/OauthAndRedirect.aspx?gourl=GroupLists.aspx";
                    break;
                case 2:
                    window.location.href = "note.aspx";
                    break;
                case 3:
                    window.location.href = "UserCenter.aspx";
                    break;
                default:
                    showLoader("warn", "敬请期待...");
                    setTimeout(function () {
                        $(".mask").hide();
                    }, 1500);
                    break;
            }
        }

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

        $(".rightset").click(function () {
            showLoader('warn', '正在开发中...');
            setTimeout(function () {
                $(".mask").hide();
            }, 1500);
        });

        function clickgo(mname) {
            switch (mname) {
                case "bktj":
                    //window.location.href = "http://tm.lilanz.com/retail/wxarticles/articlelist.aspx?ssid=21&autoAuth=enterprise";
                    window.location.href = "../wxarticles/ArticleLists.aspx?gid=21&gname=" + encodeURI(encodeURI("爆款推荐"));
                    break;
                case "cpmd":
                    //window.location.href = "http://tm.lilanz.com/retail/wxarticles/articlelist.aspx?ssid=22&autoAuth=enterprise";
                    window.location.href = "../wxarticles/ArticleLists.aspx?gid=22&gname=" + encodeURI(encodeURI("产品卖点"));
                    break;
                case "clzc":
                    //window.location.href = "http://tm.lilanz.com/retail/wxarticles/articlelist.aspx?ssid=23&autoAuth=enterprise";
                    window.location.href = "../wxarticles/ArticleLists.aspx?gid=23&gname=" + encodeURI(encodeURI("陈列转场"));
                    break;
                case "cctg":
                    //window.location.href = "http://tm.lilanz.com/retail/wxarticles/articlelist.aspx?ssid=24&autoAuth=enterprise";
                    window.location.href = "../wxarticles/ArticleLists.aspx?gid=24&gname=" + encodeURI(encodeURI("橱窗推广"));
                    break;                    
                case "lxqs":
                    //window.location.href = "http://tm.lilanz.com/retail/wxarticles/articlelist.aspx?ssid=25&autoAuth=enterprise";
                    window.location.href = "../wxarticles/ArticleLists.aspx?gid=25&gname=" + encodeURI(encodeURI("流行趋势"));
                    break;
                default:
                    showLoader('warn', '正在开发中...');
                    setTimeout(function () {
                        $(".mask").hide();
                    }, 1500);
            }
        }

        //圈子的链接地址：http://tm.lilanz.com/wxDevelopment/WebBLL/LilanzGroupProject/OauthAndRedirect.aspx?gourl=GroupLists.aspx
    </script>
</asp:Content>
