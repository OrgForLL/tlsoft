<%@ Page Language="C#" %>

<%@ Import Namespace="System.Data" %>
<%@ Import Namespace="System.Data.SqlClient" %>
<%@ Import Namespace="System.Collections.Generic" %>
<%@ Import Namespace="nrWebClass" %>

<!DOCTYPE html>
<script runat="server">
    private string DBConnStr = clsConfig.GetConfigValue("OAConnStr");
    public string AppSystemKey = "", CustomerID = "", CustomerName = "", RoleName = "", StoreName = "", StoreID = "", SystemID = "3";
    public string khOptions = "";
    protected void Page_Load(object sender, EventArgs e) {
        if (clsWXHelper.CheckQYUserAuth(true)) {
            AppSystemKey = clsWXHelper.GetAuthorizedKey(Convert.ToInt32(SystemID));
            CustomerID = Convert.ToString(Session["qy_customersid"]);
            CustomerName = Convert.ToString(Session["qy_cname"]);
            RoleName = Convert.ToString(Session["RoleName"]);
            if (AppSystemKey == "")
                clsWXHelper.ShowError("对不起，您还未开通全渠道系统权限！");
            else if (RoleName != "kf" && RoleName != "zb" && RoleName != "my" && RoleName != "dz")
                clsWXHelper.ShowError("对不起，您无权限使用本功能模块！");
            else
            {
                clsWXHelper.WriteLog(string.Format("AppSystemKey:{0},访问功能页[{1}]", AppSystemKey, "利郎形象管理页[imaginalList.aspx]"));
                if (RoleName == "dz")
                {
                    //店长模式
                    using (LiLanzDALForXLM dal = new LiLanzDALForXLM(DBConnStr)) {
                        string str_sql = @"select top 1 mdmc from t_mdb where mdid=@mdid";
                        List<SqlParameter> paras = new List<SqlParameter>();
                        StoreID = Convert.ToString(Session["mdid"]);
                        paras.Add(new SqlParameter("@mdid", StoreID));
                        object scalar;
                        string errinfo = dal.ExecuteQueryFastSecurity(str_sql, paras, out scalar);
                        if (errinfo == "")
                            StoreName = Convert.ToString(scalar);
                    }//end using
                }
                else
                {
                    //管理模式 加载自己管理的贸易公司
                    DataTable dt;
                    if (RoleName == "my")
                    {
                        dt = clsWXHelper.GetQQDAuth();
                        dt.DefaultView.Sort = "ssid";
                        dt = dt.DefaultView.ToTable();
                        CalKhlist(ref dt);
                    }
                    else
                    {
                        string strSQL = @"select a.khid,a.khmc mdmc,a.ssid
                                          from yx_t_khb a
                                          where a.ssid=1 and a.yxrs=1 and isnull(a.ty,0)=0 and isnull(a.sfdm,'')<>''
                                          order by a.khmc";                        
                        using (LiLanzDALForXLM dal = new LiLanzDALForXLM(DBConnStr))
                        {
                            string strInfo = dal.ExecuteQuery(strSQL, out dt);

                            if (strInfo == "")
                            {
                                CalKhlist(ref dt);
                            }
                        }//end using
                    } 
                }//end 管理模式
            } 
        }        
    }

    private void CalKhlist(ref DataTable dt)
    {
        if (dt != null)
        {
            string optionBase = @"<option value=""{0}"" data-ssid=""{2}"">{1}</option>";
            StringBuilder sbOption = new StringBuilder();
            foreach (DataRow dr in dt.Rows)
            {
                sbOption.AppendFormat(optionBase, dr["khid"], dr["mdmc"], dr["ssid"]);
            }

            khOptions = sbOption.ToString();
            sbOption.Length = 0;

            dt.Clear(); dt.Dispose(); dt = null;
        }
    }    
</script>
<html lang="zh-cn">
<head>
    <meta charset="utf-8" />
    <meta name="viewport" content="width=device-width,initial-scale=1,user-scalable=0,maximum-scale=1" />
    <meta name="format-detection" content="telephone=no" />
    <meta name="apple-mobile-web-app-capable" content="yes" />
    <meta name="apple-mobile-web-app-status-bar-style" content="black" />
    <title></title>
    <link type="text/css" rel="stylesheet" href="../../res/css/LeePageSlider.css" />
    <link type="text/css" rel="stylesheet" href="../../res/css/font-awesome.min.css" />
    <style type="text/css">
        .page {
            padding: 0;
        }

        .top {
            height: 46vh;
            background-color: #fff;
            text-align: center;
            position: relative;
        }

        .bot {
            height: 54vh;
            background-color: #222;
            position: relative;
        }

        .backimg {
            background-repeat: no-repeat;
            background-position: center center;
            background-size: cover;
        }

        .logo {
            width: 80px;
            height: 80px;
            border-radius: 50%;
            margin: 0 auto;
            background-size: 80%;
            background-color: #000;
        }

        .top .title {
            font-size: 26px;
            font-weight: bold;
            padding: 10px 0 2px 0;
        }

        .top .counts {
            color: #999;
        }

        .top .create {
            font-size: 16px;
            font-weight: bold;
            padding: 5px 0;
            width: 140px;
            border: 1px solid #222;
            color: #222;
            margin: 20px auto 0 auto;
            display: inline-block;
            border-radius: 2px;
            display: none;
        }

        .album_list {
            width: 100%;
            height: 100%;
            padding: 14% 0;
        }

            .album_list > ul {
                height: 100%;
                white-space: nowrap;
                overflow-x: auto;
                overflow-y: hidden;
                padding-right: 28px;
                -webkit-overflow-scrolling: touch;
            }

                .album_list > ul::-webkit-scrollbar {
                    display: none;
                }

            .album_list .album_item {
                width: 280px;
                height: 100%;
                background-color: #fff;
                margin-left: 28px;
                display: inline-block;
                vertical-align: top;
                padding: 10px 0;
                position: relative;
                border-bottom: 1px solid #222;
            }

        .album_item .left, .album_item .right {
            width: 50%;
            height: 100%;
            float: left;
            padding: 0 10px;
            border-right: 1px solid #eee;
            position: relative;
        }

        .album_item .right {
            display: flex;
            justify-content: center;
            flex-direction: column;
        }

        .left .thumb {
            width: 100%;
            height: 100%;
        }

        .right .title {
            color: #00ade0;
            font-weight: bold;
            font-size: 16px;
            text-align: center;
            white-space: normal;
            display: -webkit-box;
            overflow: hidden;
            text-overflow: ellipsis;
            -webkit-box-orient: vertical;
            -webkit-line-clamp: 2;
            text-decoration: underline;
        }

        .right .time {
            color: #999;
            text-align: center;
            margin-top: 20px;
            white-space: pre-wrap;
        }

        .right .fa-info-circle {
            color: #222;
            position: absolute;
            right: 6px;
            top: -4px;
        }

        .right .counts {
            text-align: center;
            color: #38c4a9;
        }

        .album_item .static_info {
            position: absolute;
            top: 0;
            left: 0;
            height: 100%;
            width: 280px;
            background-color: rgba(0,0,0,.8);
        }

        .static_info {
            padding: 10px;
            display: none;
        }

            .static_info > ul {
                height: 100%;
            }

                .static_info > ul li {
                    width: 50%;
                    height: 50%;
                    float: left;
                    color: #fff;
                    white-space: normal;
                    display: flex;
                    justify-content: center;
                    flex-direction: column;
                    text-align: center;
                }

                    .static_info > ul li:nth-child(1) {
                        border-right: 1px solid #ddd;
                    }

                    .static_info > ul li:nth-child(4) {
                        border-top: 1px solid #ddd;
                    }

                    .static_info > ul li:nth-child(3) {
                        border-top: 1px solid #ddd;
                        border-right: 1px solid #ddd;
                    }

        .static_info {
            font-size: 16px;
            font-weight: bold;
        }

            .static_info .label {
                margin-bottom: 5px;
            }

        @-webkit-keyframes bounceIn {
            0%,100%,20%,40%,60%,80% {
                -webkit-animation-timing-function: cubic-bezier(0.215,.61,.355,1);
                animation-timing-function: cubic-bezier(0.215,.61,.355,1);
            }

            0% {
                opacity: 0;
                -webkit-transform: scale3d(.3,.3,.3);
                transform: scale3d(.3,.3,.3);
            }

            20% {
                -webkit-transform: scale3d(1.1,1.1,1.1);
                transform: scale3d(1.1,1.1,1.1);
            }

            40% {
                -webkit-transform: scale3d(.9,.9,.9);
                transform: scale3d(.9,.9,.9);
            }

            60% {
                opacity: 1;
                -webkit-transform: scale3d(1.03,1.03,1.03);
                transform: scale3d(1.03,1.03,1.03);
            }

            80% {
                -webkit-transform: scale3d(.97,.97,.97);
                transform: scale3d(.97,.97,.97);
            }

            100% {
                opacity: 1;
                -webkit-transform: scale3d(1,1,1);
                transform: scale3d(1,1,1);
            }
        }

        @keyframes bounceIn {
            0%,100%,20%,40%,60%,80% {
                -webkit-animation-timing-function: cubic-bezier(0.215,.61,.355,1);
                animation-timing-function: cubic-bezier(0.215,.61,.355,1);
            }

            0% {
                opacity: 0;
                -webkit-transform: scale3d(.3,.3,.3);
                transform: scale3d(.3,.3,.3);
            }

            20% {
                -webkit-transform: scale3d(1.1,1.1,1.1);
                transform: scale3d(1.1,1.1,1.1);
            }

            40% {
                -webkit-transform: scale3d(.9,.9,.9);
                transform: scale3d(.9,.9,.9);
            }

            60% {
                opacity: 1;
                -webkit-transform: scale3d(1.03,1.03,1.03);
                transform: scale3d(1.03,1.03,1.03);
            }

            80% {
                -webkit-transform: scale3d(.97,.97,.97);
                transform: scale3d(.97,.97,.97);
            }

            100% {
                opacity: 1;
                -webkit-transform: scale3d(1,1,1);
                transform: scale3d(1,1,1);
            }
        }

        .bounceIn {
            -webkit-animation-name: bounceIn;
            animation-name: bounceIn;
        }


        .animated {
            -webkit-animation-duration: 0.5s;
            animation-duration: 0.5s;
            -webkit-animation-fill-mode: both;
            animation-fill-mode: both;
        }

        .btn_public, .btn_audit {
            position: absolute;
            left: 0;
            bottom: 0;
            color: #38c4a9;
            width: 100px;
            margin-left: 20px;
            border: 1px solid #38c4a9;
            padding: 5px 0 5px 2px;
            border-radius: 2px;
            text-align: center;
            font-weight: bold;
            letter-spacing: 2px;
        }

            .btn_public.gray, .btn_audit.gray {
                color: #999;
                border-color: #999;
            }

        #list, #static_info {
            background-color: #222;
        }

        .list_wrap {
            position: absolute;
            top: 0;
            left: 0;
            width: 100%;
            bottom: 40px;
            padding: 10px;
            padding-top: 150px;
            overflow: auto;
        }

        #static_info .list_wrap {
            padding-top: 10px;
        }

        input[type='text'] {
            -webkit-appearance: none;
            width: 100%;
            font-size: 16px;
            padding: 8px 10px;
            border-radius: 0;
            border: none;
        }
        /*filter select*/
        .sel_wrap {
            position: relative;
        }

        #sel_company {
            -webkit-appearance: none;
            width: 100%;
            border-radius: 0;
            background-color: #38c4a9;
            padding: 8px 10px;
            font-size: 16px;
            border: none;
            color: #fff;
            border-radius: 2px;
        }

        #inp_store {
            margin-top: 5px;
            border-radius: 2px;
        }

        .sel_wrap > .fa-angle-down {
            color: #fff;
            position: absolute;
            top: 50%;
            right: 10px;
            transform: translate(0,-50%);
            -webkit-transform: translate(0,-50%);
        }

        .pub_btns {
            margin-top: 5px;
            color: #fff;
        }

            .pub_btns > a {
                color: #fff;
                width: 33.33%;
                float: left;
                text-align: center;
                background-color: #fff;
                color: #333;
                padding: 7px 0;
            }

                .pub_btns > a.selected {
                    background-color: #38c4a9;
                    color: #fff;
                    font-weight: bold;
                }

        .filters {
            position: absolute;
            top: 0;
            left: 0;
            width: 100%;
            border-bottom: 1px solid #111;
            padding: 10px;
            background-color: #222;
            z-index: 100;
        }

        .btns {
            position: absolute;
            left: 0;
            bottom: 0;
            width: 100%;
            height: 40px;
            line-height: 40px;
            font-size: 0;
            background-color: #222;
        }

            .btns > a {
                text-align: center;
                color: #fff;
                display: inline-block;                
                font-size: 14px;
                width: 50%;
                border-top: 1px solid #111;
            }

                .btns > a:active {
                    background-color: #fff;
                    color: #222;
                }

        .store_list ul {
            border: 1px solid #fff;
            border-radius: 2px;
            -webkit-user-select: none;
            user-select: none;
            display: none;
        }

            .store_list ul li {
                color: #fff;
                height: 40px;
                line-height: 39px;
                padding: 0 10px;
                padding-left: 40px;
                white-space: nowrap;
                overflow: hidden;
                text-overflow: ellipsis;
                position: relative;
            }

        #static_info .store_list ul li {
            padding-left: 10px;
        }

        .store_list ul li:not(:last-child) {
            border-bottom: 1px solid #fff;
        }

        .store_list .fa-check-circle {
            position: absolute;
            top: 0;
            left: 0;
            display: inline-block;
            width: 40px;
            text-align: center;
            height: 39px;
            line-height: 39px;
            font-size: 18px;
            color: #444;
        }

        .store_list li.selected .fa-check-circle {
            color: #fff;
        }

        .store_list ul li:active {
            background-color: #fff;
            color: #222;
        }

        .no-result {
            color: #fff;
            font-weight: bold;
            font-size: 16px;
            display: none;
        }

        .static_info .nums {
            text-decoration: underline;
        }

        /*.static_info > a {
            display: inline-block;
            position: absolute;
            top: 0;
            right: 0;
            padding: 2px 10px;
            background-color: #fff;
            color: #222;
        }*/

        .static_info .close_btn {
            width: 0;
            height: 0;
            border-top: 40px solid #fff;
            border-left: 40px solid transparent;
            position:absolute;
            top:0;
            right:0;            
        }
        .close_btn .fa-times {
            color:#222;
            position:absolute;
            top:-48px;
            right:-8px;
            font-size:20px;
            display:inline-block;
            width:40px;
            text-align:center;
            line-height:40px;
        }
        #static_storename {
            margin-bottom: 10px;
            border-radius: 2px;
        }

        .top .storeName {
            font-weight: 600;
            color: #38c4a9;
            padding-top: 5px;
            display: none;
        }
    </style>
</head>
<body>
    <div class="wrap-page">
        <div class="page" id="index">
            <div class="top">
                <div class="center-translate">
                    <div class="backimg logo" style="background-image: url(../../res/img/storesaler/lilanzlogo.jpg);"></div>
                    <p class="title">利郎形象管理</p>
                    <p class="storeName"><%=StoreName %></p>
                    <p class="counts"><span>--</span>个形象册</p>                    
                    <a href="imaginalAddv2.aspx" class="create"><i class="fa fa-plus"></i>立即创建</a>
                </div>
            </div>
            <div class="bot">
                <div class="album_list">
                    <ul></ul>
                </div>
                <p class="no-result center-translate">- 空空如也 -</p>
            </div>
        </div>

        <!--发布时的列表页面-->
        <div class="page page-right" id="list">
            <div class="filters">
                <div class="sel_wrap">
                    <i class="fa fa-2x fa-angle-down"></i>
                    <select id="sel_company">
                        <option value="" selected>- 贸易公司选择 -</option>
                        <%=khOptions %>                     
                    </select>
                </div>
                <input type="text" id="inp_store" placeholder="输入门店名称.." />
                <div class="pub_btns floatfix">
                    <a data-status="0" href="javascript:;" class="pub_item selected" style="border-right: 1px solid #ddd; border-radius: 2px 0 0 2px;">未发布</a>
                    <a data-status="1" href="javascript:;" class="pub_item" style="border-right: 1px solid #ddd;">已发布</a>
                    <!--<a data-status="-1" href="javascript:;" class="pub_item" style="border-right: 1px solid #0c111a;">全部</a>-->
                    <a href="javascript:searchStores();" style="border-radius: 0 2px 2px 0;background-color:#0c111a;color:#fff;font-weight:bold;text-decoration:underline;">搜 索</a>
                </div>
            </div>
            <div class="list_wrap">
                <div class="store_list">
                    <!--门店搜索结果列表-->
                    <ul id="search_stores">                        
                    </ul>
                </div>
            </div>

            <div class="btns">
                <a href="javascript:$('#list').addClass('page-right');" style="border-right: 1px solid #111;">关 闭</a>
                <a href="javascript:savePublic();">提 交（<span id="select_counts">0</span>）</a>
            </div>
        </div>

        <!--点击统计信息显示的门店列表-->
        <div class="page page-right" id="static_info">
            <div class="list_wrap">
                <div class="store_list">
                    <input type="text" id="static_storename" placeholder="筛选门店名称.." oninput="quickFilter()" />
                    <ul></ul>
                </div>
            </div>
            <div class="btns">
                <a href="javascript:$('#static_info').addClass('page-right');" style="border-right: 1px solid #111; width: 100%;">关 闭</a>
            </div>
        </div>
    </div>

    <!--模板-->
    <script type="text/html" id="store_list_temp">
        <li data-mdid="{{mdid}}"><i class="fa fa-check-circle"></i><span>{{mdmc}}</span></li>
    </script>

    <script type="text/html" id="static_list_stores">
        <li data-mdid="{{mdid}}"><span>{{mdmc}}</span></li>
    </script>

    <script type="text/html" id="album_temp"> 
        {{each List}}       
        <li class="album_item" data-id="{{$value.id}}" data-issend="{{$value.IsSend}}" data-issubmit="{{$value.IsSubmit}}">
            <div class="left">
                <div class="backimg thumb" style="background-image: url(../../{{$value.AddressURL.replace("/my/","/")}})"></div>
            </div>
            <div class="right">
                <p class="title">{{$value.title}}</p>
                <p class="counts">{{$value.ImgCount}}张</p>
                <p class="time">{{$value.Date}}</p>
                <i class="fa fa-2x fa-info-circle"></i>
                {{if RoleName=="my" || RoleName=="zb" || RoleName=="kf" }}
                <a href="javascript:;" class="btn_public">发布</a>
                {{else if RoleName == "dz"}}
                <a href="javascript:;" class="btn_audit {{if $value.IsSubmit == 'True'}}gray{{/if}}">{{if $value.IsSubmit == "False"}}提交审核{{else}}已提交审核{{/if}}</a>
                {{/if}}
            </div>
            <div class="static_info">
                <ul>
                    <li data-status="1">
                        <p class="label">{{STitle[0]}}</p>
                        <p class="nums">{{$value.s1}}</p>
                    </li>
                    <li data-status="2">
                        <p class="label">{{STitle[1]}}</p>
                        <p class="nums">{{$value.s2}}</p>
                    </li>
                    <li data-status="3">
                        <p class="label">{{STitle[2]}}</p>
                        <p class="nums">{{$value.s3}}</p>
                    </li>
                    <li data-status="4">
                        <p class="label">{{STitle[3]}}</p>
                        <p class="nums">{{$value.s4}}</p>
                    </li>
                </ul>
                <a class="close_btn" href="javascript:;">
                    <i class="fa fa-times"></i>
                </a>
            </div>
        </li>
        {{/each}}
    </script>

    <script type="text/javascript" src="../../res/js/jquery.js"></script>
    <script type="text/javascript" src="../../res/js/storesaler/fastclick.min.js"></script>
    <script type="text/javascript" src="../../res/js/LeeJSUtils.min.js"></script>
    <script type="text/javascript" src="../../res/js/template.js"></script>    
    <script type="text/javascript">
        //model 模式名称admin(管理模式) common(门店模式) currentPid相册的ID
        var currentPid = 0, roleName = "<%=RoleName%>", model = "common";
        var customerID = "<%=CustomerID%>", customerName = "<%=CustomerName%>", mdid = "<%=StoreID%>";

        $(document).ready(function () {
            FastClick.attach(document.body);
            BindEvents();
            loadStoreImgs();

            if (roleName == "kf" || roleName == "zb" || roleName == "my") {
                model = "admin";
                $(".top .create").css("display", "inline-block");
            } else if (roleName == "dz") {
                model = "common";
                $(".top .storeName").show();
            }
        });

        //初始加载数据方法
        function loadStoreImgs() {
            LeeJSUtils.showMessage("loading", "正在加载..");
            setTimeout(function () {
                $.ajax({
                    url: "ImageManageCore.aspx?ctrl=LoadStoreImgs",
                    type: "POST",
                    contentType: "application/x-www-form-urlencoded; charset=utf-8",
                    data: { rid: customerID, rolename: roleName , mdid: mdid },
                    dataType: "text",
                    timeout: 20 * 1000,
                    error: function (XMLHttpRequest, textStatus, errorThrown) {
                        LeeJSUtils.showMessage("error", "您的网络出问题啦..[" + XMLHttpRequest.statusText + "]");
                    },
                    success: function (msg) {
                        if (msg.indexOf("Error:") == -1) {
                            //console.log(msg);
                            var rows = JSON.parse(msg);
                            if (rows.List.length == 0)
                                $(".no-result").show();
                            else {
                                rows.STitle = rows.STitle.split(",");
                                rows.RoleName = roleName;
                                var html = template("album_temp", rows);
                                //console.log(html);
                                $(".album_list ul").append(html);
                                $(".top .counts>span").text(rows.List.length);
                                $("#leemask").hide();
                            }
                            $("#leemask").hide();
                        } else
                            LeeJSUtils.showMessage("error", "加载失败 " + msg.replace("Error:", ""));
                    }
                });
            }, 50);
        }

        function BindEvents() {
            //发布事件            
            $(".album_list ul").on("click", ".btn_public", function () {
                if ($(this).text() == "发布") {
                    var id = $(this).parent().parent().attr("data-id");
                    currentPid = id;
                    $("#list").removeClass("page-right");
                    searchStores();
                }
            });

            //门店列表选择事件
            $("#list .store_list").on("click", "li", function () {
                var counts = parseInt($("#select_counts").text());
                if ($(this).hasClass("selected")) {
                    $(this).removeClass("selected");
                    $("#select_counts").text(counts - 1);
                } else {
                    $(this).addClass("selected");
                    $("#select_counts").text(counts + 1);
                }
            });

            //进入详情页
            //管理模式下如果未发布状态点击进入编辑页反之选择一家门店来审核
            $(".album_list ul").on("click", ".right .title", function () {
                var $this = $(this).parent().parent();
                var id = $this.attr("data-id");
                var issend = $this.attr("data-issend");
                if (model == "admin") {
                    //管理模式
                    if (issend == "True") {
                        LeeJSUtils.showMessage("warn", "对不起！该形象册已经发布，不能编辑！");
                        setTimeout(function () {        //By:xlm 20170117 新增
                            $(".album_item[data-id='" + id + "'] .fa-info-circle").click();
                        }, 500);
                    }
                    else
                        window.location.href = "imaginalAdd.aspx?id=" + id;
                } else if (model == "common") {
                    //店长模式
                    window.location.href = "imaginalMana.aspx?pid=" + id + "&mdid=" + mdid;
                }
            });

            //查看统计信息
            $(".album_list ul").on("click", ".fa-info-circle", function () {
                currentPid = $(this).parent().parent().attr("data-id");
                $(".static_info", $(this).parent().parent()).show().addClass("animated bounceIn");
            });

            $(".album_list").on("click", ".static_info ul li", function () {
                if (model == "admin") {
                    //加载门店列表
                    var nums = parseInt($(".nums", $(this)).text());
                    var status = $(this).attr("data-status");
                    var pid = $(this).parent().parent().parent().attr("data-id");
                    if (nums > 0) {
                        LeeJSUtils.showMessage("loading", "正在加载..");
                        setTimeout(function () {
                            $.ajax({
                                url: "ImageManageCore.aspx?ctrl=LoadStoreListForMD",
                                type: "POST",
                                contentType: "application/x-www-form-urlencoded; charset=utf-8",
                                data: { id: pid, status: status, mdmcLike: "" },
                                dataType: "text",
                                timeout: 10 * 1000,
                                error: function (XMLHttpRequest, textStatus, errorThrown) {
                                    LeeJSUtils.showMessage("error", "您的网络出问题啦..[" + XMLHttpRequest.statusText + "]");
                                },
                                success: function (msg) {
                                    if (msg.indexOf("Error:") == -1) {
                                        //console.log(msg);
                                        var rows = JSON.parse(msg), html = "";
                                        for (var i = 0; i < rows.List.length; i++) {
                                            html += template("static_list_stores", rows.List[i]);
                                        }//end for
                                        $(".store_list ul").empty().html(html);
                                        $("#static_info .store_list ul").show();
                                        $("#static_storename").val("");//筛选门店名称
                                        $("#static_info").removeClass("page-right");
                                        $("#leemask").hide();
                                    } else
                                        LeeJSUtils.showMessage("error", "加载失败 " + msg.replace("Error:", ""));
                                }
                            });
                        }, 50);
                    }
                }
            });

            $("#static_info .store_list").on("click", "li", function () {
                var mdid = $(this).attr("data-mdid");                
                if (model == "admin") {
                    window.location.href = "imaginalMana.aspx?mdid=" + mdid + "&pid=" + currentPid;
                }
            });

            //隐藏统计信息
            $(".album_list").on("click", ".static_info .close_btn", function () {
                $(this).parent().hide();
            });

            //顶部的筛选按钮
            $(".pub_item").click(function () {
                $(".pub_item.selected").removeClass("selected");
                $(this).addClass("selected");
                $("#select_counts").text("0");
                searchStores();
            });

            //门店提交审核
            $(".album_list").on("click", ".btn_audit", function () {
                var msg = "", $this = $(this).parent().parent();
                if ($this.attr("data-issubmit") == "True")
                    return;
                var pid = $this.attr("data-id");
                var no_uploads = $(".static_info ul li:last-child .nums", $this).text();
                if (parseInt(no_uploads) > 0)
                    msg = "该形象册您还有" + no_uploads + "张未上传，确认提交审核？？";
                else
                    msg = "确认提交审核？？"
                if (confirm(msg)) {
                    LeeJSUtils.showMessage("loading", "正在提交..");
                    setTimeout(function () {
                        $.ajax({
                            url: "ImageManageCore.aspx?ctrl=SubmitStoreImg",
                            type: "POST",
                            contentType: "application/x-www-form-urlencoded; charset=utf-8",
                            data: { cid: customerID, cname: customerName, pid: pid, mdid:mdid },
                            dataType: "text",
                            timeout: 10 * 1000,
                            error: function (XMLHttpRequest, textStatus, errorThrown) {
                                LeeJSUtils.showMessage("error", "您的网络出问题啦..[" + XMLHttpRequest.statusText + "]");
                            },
                            success: function (msg) {
                                if (msg.indexOf("Successed") > -1) {
                                    LeeJSUtils.showMessage("successed", "提交成功！");
                                    $(".btn_audit", $this).text("已提交");
                                    $(".btn_audit", $this).addClass("gray");
                                } else
                                    LeeJSUtils.showMessage("error", "提交失败 " + msg.replace("Error:", ""));
                            }
                        });
                    }, 50);
                }
            });
        }

        //筛选门店列表
        $.expr[":"].Contains = function (a, i, m) {
            return (a.textContent || a.innerText || "").toUpperCase().indexOf(m[3].toUpperCase()) >= 0;
        };
        function quickFilter() {
            var obj = $("#static_info .store_list li>span");
            if (obj.length > 0) {
                var filter = $("#static_storename").val().trim();
                if (filter) {
                    $matches = $("#static_info .store_list li").find("span:Contains(" + filter + ")").parent();
                    $("li", $("#static_info .store_list")).not($matches).hide();
                    $matches.show();
                } else {
                    $("#static_info .store_list").find("li").show();
                }
            }
        }

        //发布时的搜索门店
        function searchStores() {
            var khid = $("#sel_company").val();
            var ssid = $("#sel_company option[value='" + khid + "']").attr("data-ssid");
            var mdmc = $("#inp_store").val();
            var status = $(".pub_item.selected").attr("data-status");
            if (khid == "") {
                LeeJSUtils.showMessage("warn", "请先选择贸易公司..");
                return;
            }
            LeeJSUtils.showMessage("loading", "正在搜索..");
            setTimeout(function () {
                $.ajax({
                    url: "ImageManageCore.aspx?ctrl=LoadStoreList",
                    type: "POST",
                    contentType: "application/x-www-form-urlencoded; charset=utf-8",
                    data: { khid: khid, ssid:ssid, mdmc: mdmc, status: status, pid: currentPid },
                    dataType: "text",
                    timeout: 10 * 1000,
                    error: function (XMLHttpRequest, textStatus, errorThrown) {
                        LeeJSUtils.showMessage("error", "您的网络出问题啦..[" + XMLHttpRequest.statusText + "]");
                    },
                    success: function (msg) {
                        if (msg.indexOf("Error:") == -1) {
                            var rows = JSON.parse(msg);
                            var html = "";
                            for (var i = 0; i < rows.List.length; i++) {
                                html += template("store_list_temp", rows.List[i]);
                            }//end for                            
                            if (html == "") {
                                $("#search_stores").empty();
                                $("#search_stores").hide();
                                //LeeJSUtils.showMessage("warn", "对不起，无门店信息！");
                                $("#leemask").hide();
                            }
                            else {
                                $("#search_stores").empty().html(html);
                                $("#search_stores").show();
                                $("#leemask").hide();
                            }
                            $("#select_counts").text("0");
                        } else
                            LeeJSUtils.showMessage("error", "加载失败 " + msg.replace("Error:", ""));
                    }
                });
            }, 50);
        }

        //从列表中选择门店进行发布
        function savePublic() {
            if ($(".pub_item.selected").attr("data-status") == "1") {
                LeeJSUtils.showMessage("warn", "对不起，暂不支持取消发布！");
                return;
            }
            var counts = parseInt($("#select_counts").text());
            if (counts == 0)
                LeeJSUtils.showMessage("warn", "请从列表中选择需要发布的门店！");
            else {
                if (confirm("确定将该形象册发布到选中的" + counts + "家门店？？")) {
                    LeeJSUtils.showMessage("loading", "正在提交，请稍候..");
                    var storesArr = "", sobj = $("#search_stores li.selected");
                    for (i = 0; i < sobj.length; i++) {
                        storesArr += sobj.eq(i).attr("data-mdid") + "|";
                    };
                    if (storesArr != "")
                        storesArr = storesArr.substring(0, storesArr.length - 1);
                    setTimeout(function () {
                        $.ajax({
                            url: "ImageManageCore.aspx?ctrl=SendStoreList",
                            type: "POST",
                            contentType: "application/x-www-form-urlencoded; charset=utf-8",
                            data: { pid: currentPid, mdid: storesArr, cid: customerID },
                            dataType: "text",
                            timeout: 10 * 1000,
                            error: function (XMLHttpRequest, textStatus, errorThrown) {
                                LeeJSUtils.showMessage("error", "您的网络出问题啦..[" + XMLHttpRequest.statusText + "]");
                            },
                            success: function (msg) {
                                if (msg.indexOf("Successed") > -1) {
                                    //LeeJSUtils.showMessage("successed", "发布成功！");
                                    var $that = $(".album_list .album_item[data-id=" + currentPid + "]");
                                    $that.attr("data-issend", "True");//发布后不能再编辑
                                    var _nos = $(".static_info li[data-status=1] .nums", $that);
                                    _nos.text(parseInt(_nos.text()) + counts);
                                    alert("发布成功！");
                                    searchStores();
                                } else
                                    LeeJSUtils.showMessage("error", "发布失败 " + msg.replace("Error:", ""));
                            }
                        });
                    }, 50);
                }//end confirm
            }//end else
        }
    </script>
</body>
</html>

