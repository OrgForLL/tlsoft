<%@ Page Title="销售神器" Language="C#" MasterPageFile="../../WebBLL/frmQQDBase.Master" AutoEventWireup="true" %>
<%@ MasterType VirtualPath="../../WebBLL/frmQQDBase.Master" %>


<%@ Import Namespace="System.Collections" %>
<%@ Import Namespace="System.Collections.Generic" %>
<%@ Import Namespace="nrWebClass" %>  
<%@ Import Namespace="System.Data" %>  

<script runat="server">

    public string strCname = "";
    public string strMobile = "";
    public string strEmail = "";
    public string strFace = "";
    public string strGwmc = "";
    protected void Page_PreRender(object sender, EventArgs e)
    {        
        if (!this.IsPostBack)
        {            
            string strInfo = ""; 
            string connectstring = System.Configuration.ConfigurationManager.ConnectionStrings["Conn"].ConnectionString;        //62的连接字符串
            using (LiLanzDALForXLM dal = new LiLanzDALForXLM(connectstring))
            { 
                //获取店员头像
                DataTable dt = new DataTable();
                string strSQL = string.Concat(@"SELECT TOP 1 cname,avatar,mobile,email FROM wx_t_customers  WHERE id=", Session["qy_customersid"]);
                strInfo = dal.ExecuteQuery(strSQL, out dt);
                if (strInfo == "")
                {
                    if (dt.Rows.Count > 0)
                    {
                        strCname = Convert.ToString(dt.Rows[0]["cname"]);
                        strFace = Convert.ToString(dt.Rows[0]["avatar"]);
                        strMobile = Convert.ToString(dt.Rows[0]["mobile"]);
                        strEmail = Convert.ToString(dt.Rows[0]["email"]);

                        if (strFace.EndsWith("/"))
                        {
                            strFace = string.Concat(strFace, "64");
                        }
                        

                        dt.Clear(); dt.Dispose();

                        //获取岗位，以便加载菜单
                        strSQL = string.Concat(@"SELECT TOP 1 OCU.NickName cname,B.mc FROM wx_t_OmniChannelUser OCU INNER JOIN rs_t_Rydwzl A ON OCU.relateID = A.id
                                    INNER JOIN rs_t_gwdmb B ON OCU.ID=", Master.AppSystemKey, " AND A.gw = B.id "); 
                        strInfo = dal.ExecuteQuery(strSQL, out dt);
                        if (strInfo == "")
                        {
                            if (dt.Rows.Count > 0)
                            {
                                strCname = Convert.ToString(dt.Rows[0]["cname"]);
                                strGwmc = Convert.ToString(dt.Rows[0]["mc"]);
                            }
                            dt.Clear(); dt.Dispose();
                        }
                        else
                        {
                            clsSharedHelper.WriteErrorInfo("获取岗位信息时发生错误！错误：" + strInfo);
                        }
                         
                        wechat.UserMenu wx = new wechat.UserMenu();
                        Repeater1.DataSource = wx.MenuByRole(Convert.ToInt32(Session["RoleID"]));
                        Repeater1.DataBind(); 
                    }
                    else
                    {
                        clsSharedHelper.WriteErrorInfo("获取个人信息失败！");
                    }
                    dt.Clear(); dt.Dispose(); dt = null;
                }
                else
                {
                    clsSharedHelper.WriteErrorInfo("获取个人信息时发生错误！错误：" + strInfo);
                } 
            } 
        } 
    }
</script>

<asp:Content ID="Content1" ContentPlaceHolderID="head" runat="server"> 
    <title>销售神器</title>
    <meta name="format-detection" content="telephone=no" />
    <link type="text/css" rel="stylesheet" href="../../res/css/font-awesome.min.css" />
    <style type="text/css">
        * {
            padding: 0;
            margin: 0;
        }

        body {
            font-family: Helvetica,Arial,"Hiragino Sans GB","Microsoft Yahei","微软雅黑",STHeiti,"华文细黑",sans-serif;
            font-size: 14px;
            background-color: #f0f0f0;
        }

        .container {
            max-width: 620px;
            margin: 0 auto;
            overflow-x: hidden;
            bottom:initial;
        }

        .top {
            width: 100%;
            height: 90px;
            background-image: linear-gradient(90deg,#141414,#272727);
            background-image: -webkit-linear-gradient(90deg,#141414,#272727);
            position: fixed;
            top: 0;
            left: 0;
            border-bottom: 1px solid #cbcbcb;
            padding: 12px 0px 12px 20px;
            box-sizing: border-box;
            color: #fff;
            overflow: hidden;
            z-index: 100;
        }

            .top div {
                float: left;
            }

        .headimg {
            width: 60px;
            height: 60px;
            border: 2px solid #ebebeb;
            border-radius: 50%;
            -webkit-border-radius: 50%;
            background-image: url(<%= strFace %>);
            background-size: cover;
        }

        .top img {
            width: 100%;
            height: auto;
        }

        .userinfo {
            margin-left: 15px;
            height: 64px;
            line-height: 23px;
            border-left: 2px solid #fff;
            padding-left: 15px;
        }

        .wxnick {
            letter-spacing: 2px;
            font-size: 1.2em;
        }

        .wxnums {
            font-size: 1em;
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
            width: 100%;
            margin-top: 80px;
            margin-bottom: 75px;
            padding: 0 10px;
            box-sizing: border-box;
            overflow-y: auto;
            -webkit-overflow-scrolling: touch;
            overflow-scrolling: touch;
        }

        .rows {
            position: relative;
            list-style: none;
            color: #808080;
            font-size: 1.1em;            
        }

            .rows li {
                position: relative;
                width: 33.3333%;
                float: left;
                text-align: center;
                cursor: pointer;
                font-size: 0.9em;
                margin-top: 30px;
            }

                .rows li img {
                    width: 35%;
                    height: auto;
                }

        .bottomnav {
            height: 60px;
            background-color: #f8f8f8;
            width: 100%;
            position: fixed;
            bottom: 0;
            left: 0;
            border-top: 1px solid #cbcbcb;
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
                font-size: 1.5em;
            }

            .navul p {
                font-weight: 400;
                font-size: 1em;
                line-height: 24px;
            }

        #selected {
            color: #272b2e;
        }

        .rightset {
            position: absolute;
            right: 0;
            top: 0;
            font-size: 1.8em;
            line-height: 90px;
            vertical-align: middle;
            padding:0 10px;
        }

        .cube3d {
            -webkit-transform: translateZ(0);
            -moz-transform: translateZ(0);
            -ms-transform: translateZ(0);
            -o-transform: translateZ(0);
            transform: translateZ(0);
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
            display: none;
        }

        .qrmask {
            position: absolute;
            top: 0;
            left: 0;
            width: 100%;
            height: 100%;
            z-index: 999;
            background: #2d3132;
            display: none;
        }

        .loader {
            position: absolute;
            top: 50%;
            left: 50%;
            width: 200px;
            height: 80px;
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
        }

        .gray {
            -webkit-filter: grayscale(100%);
            filter: grayscale(100%);
            filter: gray;
        }

        .qrcon {
            background: #fff;
            border-radius: 4px;
            width: 80%;
            margin: 0 auto;
            position: relative;
            top: 50%;
            margin-top: -195px;
            padding: 20px;
            max-width: 480px;
            box-sizing: border-box;
            overflow: hidden;
        }

            .qrcon .headimg {
                float: left;
                border-radius: 6px;
            }

            .qrcon .wxnick {
                letter-spacing: 0px;
                font-weight: bold;
                margin-left: 74px;
                overflow: hidden;
                white-space: nowrap;
                text-overflow: ellipsis;
            }

            .qrcon img {
                width: 96%;
                height: auto;
                max-width: 240px;
            }

        .area {
            font-size: 14px;
            color: #808080;
            font-weight: normal;
            line-height: 40px;
        }

        .qrtxt {
            margin-top: 100px;
            width: 100%;
            text-align: center;
            position: absolute;
            left: 0;
            bottom: 10px;
            color: #808080;
        }
    </style>
</asp:Content>    


<asp:Content ID="Content2" ContentPlaceHolderID="ContentPlaceHolder1" runat="server">

<div class="container">
        <div class="top">
            <div class="headimg"></div>
            <div class="userinfo">
                <p class="wxnick"><%= strCname %>(<%= strGwmc%>)</p>
                <p class="wxnums">电 话：<%= strMobile %></p>
                <p class="wxnums">邮 箱：<%= strEmail %></p>
            </div>
            <div class="rightset"><i class="fa fa-edit"></i></div>
        </div>
        <div class="icons">
            <ul class="rows floatfix">
                <asp:Repeater ID="Repeater1" runat="server">
                    <ItemTemplate>
                        <li onclick="menuJump(this)" target="<%#Eval( "Url ")%>">
                            <img src="../../res/img<%#Eval( "Icon ")%>" />
                            <p><%#Eval( "Cname ")%></p>
                        </li>
                    </ItemTemplate>
                </asp:Repeater>
            </ul>
        </div>
        <div class="bottomnav">
            <ul class="navul floatfix">
                <li onclick="switchMenu(0)">
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
                <li onclick="switchMenu(3)" id="selected">
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
    <div class="qrmask">

    </div>
    <script type="text/javascript" src="../../res/js/jquery.js"></script>
    <script type='text/javascript' src='../../res/js/StoreSaler/fastclick.min.js'></script>
    <script type="text/javascript">
        $(function () {
            FastClick.attach(document.body);
        });

        function switchMenu(order) { 
            switch (order) {
//                case 0:
//                    window.location.href = "message.html";
//                    break;
                case 1:
                    window.location.href = "NewVipList.html";
                    break;
//                case 2:
//                    window.location.href = "weschool2.html";
//                    break;
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

        function menuJump(obj) { 
            if ($(obj).attr("target") != "") {                
                window.location.href = $(obj).attr("target");
            }
            else {
                showLoader("warn", "正在开发中...");
                setTimeout(function () {
                    $(".mask").hide();
                }, 1500);
            }
        }

        $(".qrmask").click(function () {
            $(".qrmask").fadeOut(200);
        });
    </script>

</asp:Content>
 
