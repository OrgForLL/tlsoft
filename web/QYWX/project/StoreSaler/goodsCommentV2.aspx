<%@ Page Title="商品评论" Language="C#" MasterPageFile="../../WebBLL/frmQQDBase.Master" AutoEventWireup="true" %>

<%@ MasterType VirtualPath="../../WebBLL/frmQQDBase.Master" %>
<%@ Import Namespace="nrWebClass" %>
<%@ Import Namespace="System.Data" %>
<%@ Import Namespace="System.Data.SqlClient" %>
<%@ Import Namespace="System.Collections.Generic" %>
<%@ Import Namespace="System.Net" %>
<%@ Import Namespace="System.IO" %>
<script runat="server">
    string sphh = "";
    public List<string> wxConfig; //微信OPEN_JS 动态生成的调用参数
    private const string ConfigKeyValue = "1";
    //公共变量
    public string AppSystemKey = "";
    // string OAConnStr = clsConfig.GetConfigValue("OAConnStr");
    string OAConnStr = " server=192.168.35.10;uid=ABEASD14AD;pwd=+AuDkDew;database=tlsoft";

    public string strTypeList = "", quickKeyWords = "";
    public string Isay = "";

    //必须在内容页的Load中对Master.SystemID 进行赋值；
    protected void Page_Load(object sender, EventArgs e)
    {
        this.Master.SystemID = "3";

        //Session["RoleName"] = "my";
        //Session["qy_customersid"] = "587" ;
        //this.Master.IsTestMode = true;        
    }
    protected void Page_PreRender(object sender, EventArgs e)
    {
        Isay = Convert.ToString(Request.Params["Isay"]);

        sphh = Convert.ToString(Request.Params["sphh"]);
        //sphh = "6QXF011SA";
        if (String.IsNullOrEmpty(sphh))
        {
            clsWXHelper.ShowError("非法访问！缺少参数：" + sphh);
            return;
        }

        wxConfig = clsWXHelper.GetJsApiConfig(ConfigKeyValue);

        string WXConStr = System.Web.Configuration.WebConfigurationManager.ConnectionStrings["conn"].ToString();
        using (LiLanzDALForXLM dal = new LiLanzDALForXLM(WXConStr))
        {
            DataTable dt = null;
            String mysql = @"SELECT ID,TypeName FROM wx_t_EvaluationType where id<>0 ORDER BY OrderIndex";

            string strInfo = dal.ExecuteQuery(mysql, out dt);
            if (strInfo != "")
            {
                clsWXHelper.ShowError("加载关于分类出错！错误：" + strInfo);
            }

            string addBase = "<span class='class_item etype' data-id='{0}' data-value='{1}'><i class='fa fa-circle-o'></i>{1}</span>";
            StringBuilder strBuder = new StringBuilder();
            foreach (DataRow dr in dt.Rows)
            {
                strBuder.AppendFormat(addBase, dr["ID"], dr["TypeName"]);
            }

            strTypeList = strBuder.ToString();
            //查询关键词                        
            mysql = "select top 10 keywordname from kw_t_AutoCalKeyWord where isactive=1 ";
            dt.Clear();
            strInfo = dal.ExecuteQuery(mysql, out dt);
            if (strInfo != "")
            {
                clsWXHelper.ShowError("加载快速输入关键词！错误：" + strInfo);
            }
            addBase = "<div class='quick_word'>{0}</div>";
            strBuder.Length = 0;
            foreach (DataRow dr in dt.Rows)
            {
                strBuder.AppendFormat(addBase, dr["keywordname"]);
            }

            quickKeyWords = strBuder.ToString();

            strBuder.Length = 0;
            if (dt != null) { dt.Clear(); dt.Dispose(); }
        }
    }
   
</script>
<asp:Content ID="Content1" ContentPlaceHolderID="head" runat="server">
    <meta name="format-detection" content="telephone=no" />
    <link type="text/css" rel="stylesheet" href="../../res/css/LeePageSlider.css" />
    <link type="text/css" rel="stylesheet" href="../../res/css/font-awesome.min.css" />
    <style type="text/css">
        body {
            background-color: #f7f7f7;
            color: #2f2f2f;
            font-family: Helvetica,Arial,STHeiTi, "Hiragino Sans GB", "Microsoft Yahei", "微软雅黑",STHeiti, "华文细黑",sans-serif;
        }

        .header {
            height: 50px;
        }

        .return-icon {
            position: absolute;
            top: 0;
            left: 0;
            padding: 0 15px;
            line-height: 50px;
            color: #ccc;
            font-size: 26px;
        }

        .panel {
            height: 50px;
            line-height: 50px;
            border-bottom: 1px solid #ddd;
        }

            .panel .item {
                font-size: 16px;
                /*font-weight: bold;*/
                display: inline-block;
                width: 45%;
                color: #a1a1a1;
                height: 50px;
            }

                .panel .item span {
                    height: 50px;
                    display: inline-block;
                    padding: 0 6px;
                }

                .panel .item .blacktxt {
                    color: #333;
                    border-bottom: 2px solid #333;
                }

        .page {
            padding: 0;
        }
        /*产品卖点页*/
        .comment-list .single-li {
            padding: 10px;
            border-bottom: 1px solid #eee;
            background-color: #fff;
        }

            .comment-list .single-li:last-child {
                border-bottom: none;
            }

        .top-item {
            height: 35px;
        }

        .user-img {
            background-image: url(../../res/img/StoreSaler/default-userimg.png);
            width: 35px;
            height: 35px;
            border-radius: 50%;
            background-size: cover;
            background-position: 50% 50%;
            float: left;
            vertical-align: middle;
        }

        .user-name {
            float: left;
            height: 35px;
            line-height: 35px;
            margin-left: 10px;
            max-width: 120px;
            overflow: hidden;
            text-overflow: ellipsis;
            white-space: nowrap;
        }

        .type-txt {
            float: right;
            height: 35px;
            line-height: 35px;
            font-size: 13px;
            color: #555;
        }

        .sort {
            color: #a1a1a1;
        }

        .bottom-item {
            margin-top: 10px;
        }

        .date {
            color: #b3b3b3;
            font-size: 13px;
            margin-top: 5px;
        }

        .upload-img-list {
            width: 100%;
            margin-top: 15px;
        }

            .upload-img-list li {
                float: left;
            }

        .upload-img {
            width: 70px;
            height: 70px;
            background-image: url(../../res/img/StoreSaler/Isdel.png);
            background-position: 50% 50%;
            background-size: cover;
            margin-right: 5px;
        }

        .moreBtn {
            width: 120px;
            height: 26px;
            line-height: 26px;
            border: 1px solid #333;
            font-size: 12px;
            /*font-weight: bold;*/
            text-align: center;
            margin: 0 auto;
        }

        .nomore-data {
            color: #bebebe;
            text-align: center;
        }

        #no-result {
            width: 100%;
            height: 100%;
            display: table;
        }

            #no-result p {
                color: #a1a1a1;
                text-align: center;
                font-size: 16px;
                display: table-cell;
                vertical-align: middle;
            }

        .tip-wrap {
            margin: 15px 0;
            display: none;
        }
        /*我要评论页*/
        #myComment_page {
            background-color: #f7f7f7;
        }

        .input-wrap {
            width: 100%;
            background-color: #fff;
            position: relative;
        }

        .input-box {
            -webkit-appearance: none;
            border: none;
            width: 100%;
            height: 120px;
            padding: 0 12px;
            margin: 15px 0;
            font-size: 14px; 
        }

        .input-func {
            width: 100%;
            padding: 15px 12px 10px 12px;
        }

        .send-photo {
            float: left;
            border: 2px solid #eee;
            width: 60px;
            height: 60px;
        }

        .photo-pre {
            width: 100%;
            height: 20%;
        }

            .photo-pre li {
                float: left;
                margin-right: 4%;
                width: 22%;
                height: 60px;
            }

                .photo-pre li:last-child {
                    margin-right: 0;
                }

        .camera-border {
            border: 2px solid #eee;
            text-align: center;
            display: table;
        }

        .camera {
            color: #9e9e9e;
            display: table-cell;
            /*vertical-align: middle;*/
            display: block;
            margin-top: 8px;
        }

        .pre-item {
            background-image: url(../../res/img/StoreSaler/Isdel.png);
            background-position: 50% 50%;
            background-size: cover;
            width: 100%;
            height: 60px;
        }

        .input-func p {
            float: left;
            height: 60px;
            line-height: 60px;
            color: #9e9e9e;
            margin-left: 8px;
        }

        .camera {
            color: #9e9e9e;
        }

        .talk {
            position: absolute;
            width: 40px;
            height: 140px;
            background-color: #eee;
            border-radius: 5px;
            top: 15px;
            right: 12px;
        }

        .voice-icon {
            background-image: url(../../res/img/StoreSaler/voice.png);
            width: 20px;
            height: 20px;
            background-size: contain;
            background-position: 50% 50%;
            background-repeat: no-repeat;
            margin: 9px auto;
        }

        .myComment-ul {
            background-color: #f7f7f7;
        }

            .myComment-ul .single-li, .input-wrap {
                margin-bottom: 15px;
                border-top: 1px solid #eee;
                box-shadow: 0 1px .5px #eceef1;
                -webkit-box-shadow: 0 1px .5px #eceef1;
            }

        .edit {
            width: 100%;
            padding: 10px 12px;
            background-color: #fff;
            position: relative;
        }

            .edit p {
                float: right;
            }

        /*footer style*/
        .footer {
            height: 50px;
            background-color: #f9f9f9;
            border-top: 1px solid #ddd;
        }

        .footer-list li {
            float: left;
            font-size: 16px;
            height: 50px;
            line-height: 50px;
        }

        .choose-sort, .issue-type {
            width: 33%;
            border-right: 1px solid #ddd;
        }

        .form-submit {
            position: relative;
            height: 40px;
        }

        .submit-btn {
            background-color: #333;
            color: #fff;
            text-align: center;
            font-weight: 600;
            height: 60px;
            width: 60px;
            display: inline-block;
            line-height: 20px;
            padding-top: 10px;
            position: absolute;
            bottom: 10px;
            right: 14px;
        }
        /*底部弹出面板*/
        .mask2 {
            width: 100%;
            height: 100%;
            background: rgba(0,0,0,0.4);
            position: absolute;
            bottom: 50px;
            z-index: 99999;
        }

        #choose-sort-mask2 {
            display: none;
        }

        #choose-sort-panel {
            position: absolute;
            bottom: 10px;
            left: 0px;
            width: 33%;
        }

            #choose-sort-panel ul, #issue-type-panel ul {
                margin: 0 auto;
            }

        #issue-type-mask2 {
            display: none;
        }

        #issue-type-panel {
            position: absolute;
            bottom: 10px;
            left: 0;
            width: 100%;
        }

        .popup-ul {
            width: 100px;
            border: 1px solid #ddd;
            background-color: #f9f9f9;
            border-radius: 5px;
            border-bottom: none;
        }

            .popup-ul li {
                height: 40px;
                line-height: 40px;
                text-align: center;
                border-bottom: 1px solid #ddd;
            }

                .popup-ul li:last-child {
                    border-bottom: none;
                }

        .triangle {
            width: 0;
            height: 0;
            border-left: 10px solid transparent;
            border-right: 10px solid transparent;
            border-top: 6px solid #f9f9f9;
            margin: 0 auto;
        }

        /*mask2 style*/
        #mask2-layer {
            width: 100%;
            height: 100%;
            position: fixed;
            top: 0;
            left: 0;
            background-color: rgba(0,0,0,0.4);
            z-index: 9999;
        }

        .blur {
            filter: blur(5px);
            -webkit-filter: blur(5px);
        }

        .loader-container {
            position: absolute;
            top: 50%;
            left: 50%;
            transform: translate(-50,-50%);
            -webkit-transform: translate(-50%,-50%);
            background-color: #f0f0f0;
            border-radius: 4px;
            font-size: 0;
            height: 50px;
            line-height: 1;
        }

        .load8 .cloader {
            font-size: 10px;
            position: relative;
            border-top: 4px solid rgba(0,0,0,0.1);
            border-right: 4px solid rgba(0,0,0,0.1);
            border-bottom: 4px solid rgba(0,0,0,0.1);
            border-left: 4px solid #555;
            -webkit-animation: load8 0.5s infinite linear;
            animation: load8 0.5s infinite linear;
            position: absolute;
            top: 10px;
            left: 10px;
        }

            .load8 .cloader,
            .load8 .cloader:after {
                border-radius: 50%;
                width: 30px;
                height: 30px;
                box-sizing: border-box;
            }

        .loader-text {
            font-weight: bold;
            font-size: 14px;
            color: #555;
            padding: 0 10px 0 50px;
            line-height: 50px;
            white-space: nowrap;
            max-width: 200px;
        }

        @-webkit-keyframes load8 {
            0% {
                -webkit-transform: rotate(0deg);
                transform: rotate(0deg);
            }

            100% {
                -webkit-transform: rotate(360deg);
                transform: rotate(360deg);
            }
        }

        @keyframes load8 {
            0% {
                -webkit-transform: rotate(0deg);
                transform: rotate(0deg);
            }

            100% {
                -webkit-transform: rotate(360deg);
                transform: rotate(360deg);
            }
        }

        .cloader {
            -webkit-transform: translateZ(0);
            -moz-transform: translateZ(0);
            -ms-transform: translateZ(0);
            -o-transform: translateZ(0);
            transform: translateZ(0);
        }

        .tip-text {
            padding: 0 20px;
        }

        .no-loader-icon {
            display: none;
        }

        .hiddleCommentID {
            display: none;
        }

        .close {
            position: absolute;
            margin-left: -12px;
            margin-top: -7px;
            padding: 3px 4px 3px 4px;
        }

        .DelImgBtn {
            position: relative;
            float: right;
            top: -70px;
            color: rgba(255, 0, 0, 0.4);
        }

        .uploading {
            -webkit-animation: twinkling 1s infinite ease-in-out;
        }


        @-webkit-keyframes twinkling { /*透明度由0到1*/
            0% {
                opacity: 0; /*透明度为0*/
                border: 1px solid #f00;
            }

            40% {
                opacity: 0.8;
            }

            100% {
                opacity: 1; /*透明度为1*/
                border: 1px solid #9e9e9e;
            }
        }

        .quick_words_wrap {
            background-color: #fff;
            padding: 0px 10px 8px 10px;
        }

        .quick_word {
            display: inline-block;
            background-color: #fbdfd1;
            padding: 4px 16px;
            margin: 8px 10px 0 0;
            border-radius: 4px;
            font-size: 12px;
        }

        .class_group {
            padding: 10px 10px 5px 10px;
            font-size: 16px;
            background-color: #fff;
            color: #666;
        }

            .class_group .title {
                font-weight: 600;
                color: #333;
            }

            .class_group .class_item {
                margin-left: 10px;
            }

        .class_item .fa {
            margin-right: 5px;
        }

        .ogroup {
            display: none;
        }

            .ogroup.active {
                display: initial;
            }
        /*打赏*/
        .red_paper_icon {
            width: 24px;
            height: 24px;
            position: absolute;
            top: 9px;
            left: 10px;
        }

        .single_red .red_paper_icon {
            left:0;
        }

        .red_paper {
            position: absolute;
            width: 80%;
            height: 40px;
            top: 0;
            left: 0;
            padding: 0 90px 0 40px;
            overflow: hidden;
            line-height: 42px;
        }
        .single_red .red_paper {
            padding-left:30px;
        }

        .red_counts {
            color: #ed4658;
            font-weight: bold;
            padding: 0 5px;            
        }

        .list-wrap .red_counts,.single_red .red_counts {
            text-decoration:underline;
        }

        /*打赏页样式*/
        #redpaper_detail {
            background-color: rgba(0,0,0,0.4);
        }

        .redpaper_container {
            width: 80vw;
            height: 60vh;
            background-color: #fff;
            border-radius: 8px;
            position: relative;
        }

        .backimg {
            background-repeat: no-repeat;
            background-size: cover;
            background-position: center center;
        }

        .headimg {
            width: 70px;
            height: 70px;
            border: 2px solid #fff;
            border-radius: 50%;
            background-color: #fff;
            margin: -35px auto 0 auto;
        }

        .redpaper_container .tips {
            text-align: center;
            font-weight: 600;
            border-bottom: 1px solid #f2f2f2;
            padding-bottom: 5px;
        }

        #close_redpaper {
            position: absolute;
            color: #ccc;
            padding: 7px;
            top: 0;
            right: 0;
            font-size: 24px;
        }

        #redpaper_ul {
            position: absolute;
            top: 65px;
            bottom: 0;
            left: 0;
            width: 100%;
            overflow-x: hidden;
            overflow-y: auto;
        }

        .redpaper_item {
            padding: 10px;
            position: relative;
            border-bottom:1px solid #f7f7f7;
        }

            .redpaper_item .headimg {
                width: 60px;
                height: 60px;
                border-radius: 0;
                margin: 0;
                border: none;
            }

        .red_infos {
            position: absolute;
            top: 0;
            left: 70px;
            right: 0;
            height: 100%;
            padding: 10px;
        }

            .red_infos .infos {
                margin-top: 12px;
                color: #888;
            }

            .red_infos .time {
                float: right;
            }

            .red_infos .username {
                font-size: 16px;
                font-weight: bold;
                color: #303030;
            }
        .single_red {
            position:relative;
            height:40px;
        }
    </style>
</asp:Content>
<asp:Content ID="Content2" ContentPlaceHolderID="ContentPlaceHolder1" runat="server">
    <div id="mask2-layer">
        <div class="loader-container load8 include-loader-icon">
            <div class="cloader"></div>
            <p class="loader-text">正在加载..</p>
        </div>
        <div class="loader-container load8 no-loader-icon">
            <p class="loader-text tip-text">提交成功</p>
        </div>
    </div>
    <div class="header">
        <i class="return-icon fa fa-angle-left fa-2x" onclick="goback();"></i>
        <div class="panel">
            <div class="item" id="salePoint"><span class="cpmd blacktxt">产品卖点</span></div>
            <div class="item" id="myComment"><span class="wypl">我要评论</span></div>
        </div>
    </div>
    <div class="wrap-page">
        <!--产品卖点页-->
        <div class="page page-not-header" id="salePoint_page">
            <!-- 评论列表 -->
            <ul class="comment-list">
                <div class="tip-wrap">
                    <!--先隐藏-->
                    <div class="moreBtn">查看更多</div>
                </div>
            </ul>
            <!-- 无评论数据时 -->
            <!-- <div id="no-result">
            	<p>暂时没有评论</p>
            </div> -->
        </div>
        <!--我要评论页-->
        <div class="page page-not-header page-right" id="myComment_page">
            <!-- 发表评论 -->
            <!--评论快捷关键词-->
            <div class="quick_words_wrap">
                <%=quickKeyWords %>
                <!--<div class="quick_word">面料好</div>
                <div class="quick_word">好评</div>
                <div class="quick_word">赞一个</div>
                <div class="quick_word">待改进</div>-->
            </div>
            <!--评论类型-->
            <div class="class_group">
                <span class="title ogroup" data-id="6">产品卖点</span>
                <span class="title ogroup" data-id="5">开发建议</span>
                <span class="title ogroup" data-id="7">质量反馈</span>
                <%=strTypeList %>
                <!--<span class="class_item etype" data-id="1"><i class="fa fa-circle-o"></i>版型</span>
                <span class="class_item etype" data-id="2"><i class="fa fa-circle-o"></i>面料</span>
                <span class="class_item etype" data-id="3"><i class="fa fa-circle-o"></i>辅料</span>-->
            </div>

            <div class="input-wrap">
                <input type="hidden" id="editID" value="0" />
                <textarea class="input-box" placeholder="点击这里开始输入评论，至少10个字哦~~"></textarea>
                <div class="input-func floatfix">
                    <input type="file" style="display: none" id="choosefile" />
                    <ul class="photo-pre">
                        <li class="camera-border" onclick="chooseFile()"><i class="camera fa fa-camera fa-2x"></i>
                            <p style="font-size: 12px; text-align: center; height: auto; line-height: normal; margin: 0; float: none;">上传买家秀</p>
                        </li>
                    </ul>
                </div>
                <a class="submit-btn" onclick="submitComm()">提交<br />
                    评论</a>
                <!--打赏+评论提交-->
                <!--<div class="form-submit">
                    <img class="red_paper_icon" src="../../res/img/storesaler/redpaper.png" />
                    <div class="red_paper">共<span class="red_counts">88</span>赏金</div>                    
                </div>-->
            </div>
            <!-- 评论列表 -->
            <ul class="comment-list myComment-ul">
                <div class="tip-wrap">
                    <div class="moreBtn">查看更多</div>
                    <!-- <p class="nomore-data">没有更多数据啦...</p> -->
                </div>

            </ul>
        </div>
        <!--赏金明细页-->
        <div class="page" id="redpaper_detail" style="display: none;">
            <div class="redpaper_container center-translate">
                <i class="fa fa-times-circle-o" id="close_redpaper" onclick="javascript:$('#redpaper_detail').hide();"></i>
                <div class="headimg backimg top" style="background-image: url(../../res/img/storesaler/defaulticon2.png)"></div>
                <p class="tips">总共被打赏<span class="red_counts">--</span>元</p>
                <ul id="redpaper_ul">
                    <!--<li class="redpaper_item">
                        <div class="backimg headimg" style="background-image:url(../../res/img/storesaler/head1.jpg)"></div>
                        <div class="red_infos">
                            <p class="username">Elilee</p>
                            <div class="infos">
                                <span>打赏<span class="red_counts">40</span>元</span>
                                <span class="time">2016-09-09</span>
                            </div>
                        </div>
                    </li>-->
                </ul>
            </div>
        </div>
    </div>
    <!--<div class="footer">
        <ul class="footer-list">
            <li class="choose-sort">
                <span id="etype" value=""></span>
                <i class="fa fa-angle-up"></i>
            </li>
            <li class="issue-type">
                <span id="ogroup" value=""></span>
                <i class="fa fa-angle-up"></i>
            </li>
            <li class="submit-btn" onclick="submitComm()">提交评论</li>
        </ul>
    </div>-->
    <!-- 分类面板 -->
    <!--<div class="mask2" id="choose-sort-mask2">
        <div id="choose-sort-panel">
            <ul class="popup-ul">
                <%=strTypeList %>
            </ul>
            <div class="triangle"></div>
        </div>
    </div>-->
    <!-- 评论类型面板 -->
    <!--
    <div class="mask2" id="issue-type-mask2">
        <div id="issue-type-panel">
            <ul class="popup-ul">
                <li value="">选择类型</li>
                <li value="6">产品卖点</li>
                <li value="5">改进建议</li>
            </ul>
            <div class="triangle"></div>
        </div>
    </div>
    -->

    <script type="text/javascript" src="../../res/js/jquery.js"></script>
    <script type="text/javascript" src="../../res/js/template.js"></script>
    <script type="text/javascript" src="../../res/js/LeeJSUtils.min.js"></script>
    <script type="text/javascript" src="http://res.wx.qq.com/open/js/jweixin-1.0.0.js"></script>
    <script type="text/javascript" src="../../res/js/storesaler/fastclick.min.js"></script>
    <script type="text/javascript" src="../../res/js/StoreSaler/LocalResizeIMG.js"></script>
    <script type="text/javascript" src="../../res/js/StoreSaler/mobileBUGFix.mini.js"></script>
    <script type="text/javascript" src="../../res/js/vipweixin/jquery.touchSlider.js"></script>

    <script type="text/javascript">
        var appIdVal = "<%=wxConfig[0]%>", timestampVal = "<%=wxConfig[1]%>", nonceStrVal = "<%=wxConfig[2]%>", signatureVal = "<%=wxConfig[3]%>";
        var SalerID = "<%= AppSystemKey %>";
    </script>

    <script type="text/html" id="reward_temp">
        <li class="redpaper_item">
            <div class="backimg headimg" style="background-image: url({{senduserface}})"></div>
            <div class="red_infos">
                <p class="username">{{sendusername}}</p>
                <div class="infos">
                    <span>打赏<span class="red_counts">{{rewardmoney}}</span>元</span>
                    <span class="time">{{createtime}}</span>
                </div>
            </div>
        </li>
    </script>

    <script type="text/javascript">
        var appIdVal = "<%=wxConfig[0]%>", timestampVal = "<%=wxConfig[1]%>", nonceStrVal = "<%=wxConfig[2]%>", signatureVal = "<%=wxConfig[3]%>";
        var sphh = "<%= sphh %>";
        var imgNum = 0, oRotate = 0;
        var Isay = "<%=Isay %>";

        $(document).ready(function () {
            LeeJSUtils.LoadMaskInit();//安卓需要初始化后才能使用，否则无法使用
            LeeJSUtils.stopOutOfPage(".header", false);
            LeeJSUtils.stopOutOfPage("#salePoint_page", true);
            //LeeJSUtils.stopOutOfPage("#myComment_page", true);
            $("#mask2-layer").fadeOut(200);
            wxConfig();
        });
        function wxConfig() {//微信js 注入
            wx.config({
                debug: false, // 开启调试模式,调用的所有api的返回值会在客户端alert出来，若要查看传入的参数，可以在pc端打开，参数信息会通过log打出，仅在pc端时才会打印。
                appId: appIdVal, // 必填，企业号的唯一标识，此处填写企业号corpid
                timestamp: timestampVal, // 必填，生成签名的时间戳
                nonceStr: nonceStrVal, // 必填，生成签名的随机串
                signature: signatureVal, // 必填，签名，见附录1
                jsApiList: ["translateVoice", "startRecord", "stopRecord", "previewImage"] // 必填，需要使用的JS接口列表，所有JS接口列表见附录2
            });
            wx.ready(function () {
                // alert("注入成功");
            });
            wx.error(function (res) {
                // alert("JS注入失败！");
            });
        }
        // 切换选项卡
        $(".panel .item").on("touchend", function () {
            var type = $(this).attr("id");
            $(".panel .item .blacktxt").removeClass("blacktxt");
            if (type == "salePoint") {
                $("#salePoint_page").removeClass("page-left");
                $("#myComment_page").addClass("page-right");
                LoadEvaluation();
            } else {
                if ($(".myComment-ul").find(".list-wrap").length == 0) {
                    LoadMyComment();
                }
                $("#salePoint_page").addClass("page-left");
                $("#myComment_page").removeClass("page-right");

            }
            $(this).find("span").addClass("blacktxt");
        });

        // 显示或隐藏分类面板
        //$(".choose-sort").click(function () {
        //    if ($("#choose-sort-mask2").css("display") == "none") {
        //        $("#choose-sort-mask2").show();
        //    }
        //    else {
        //        $("#choose-sort-mask2").hide();
        //    }
        //    $("#issue-type-mask2").hide();
        //})

        // 选择分类
        //$("#choose-sort-panel .popup-ul li").click(function () {
        //    var sorttxt = $(this).text();
        //    $("#etype").attr("value", $(this).attr("value"));
        //    $(".choose-sort span").text(sorttxt);
        //    $("#choose-sort-mask2").hide();
        //})

        // 显示或隐藏评论类型面板
        //$(".issue-type").click(function () {
        //    if ($("#issue-type-mask2").css("display") == "none") {
        //        $("#issue-type-mask2").show();
        //    }
        //    else {
        //        $("#issue-type-mask2").hide();
        //    }
        //    $("#choose-sort-mask2").hide();
        //})

        //// 选择评论类型
        //$("#issue-type-panel .popup-ul li").click(function () {
        //    var typetxt = $(this).text();
        //    $("#ogroup").attr("value", $(this).attr("value"));
        //    $(".issue-type span").text(typetxt);
        //    $("#issue-type-mask2").hide();
        //})

        //提交评论
        function submitComm() {
            var content = $(".input-box").val();
            if ($(".input-box").val() == undefined || $(".input-box").val() == "") {
                LeeJSUtils.showMessage("warn", "请输入评论内容");
                return false;
            } else if (content.length > 4000) {
                LeeJSUtils.showMessage("warn", "评论最多4000个字！您当前字数：" + content.length.toString());
                return false;
            } else if (content.length < 10) {
                LeeJSUtils.showMessage("warn", "评论最少也要10个字！");
                return false;
            }
            var etypeval = $(".etype.active").attr("data-id");//版型、面料、辅料
            var ogroupval = $(".ogroup.active").attr("data-id");//开发建议、质量反馈、产品卖点

            if (ogroupval == "" || ogroupval == "0" || typeof (ogroupval) == "undefined") {
                LeeJSUtils.showMessage("warn", "请选择相应的评论类型");
                return false;
            } else if (ogroupval == "6")
                etypeval = "0";

            if (etypeval == "" || typeof (etypeval) == "undefined") {
                LeeJSUtils.showMessage("warn", "请选择【" + $(".ogroup.active").text() + "】的类型");
                return false;
            }

            var para = new Object();
            para.ID = $("#editID").val();
            para.sphh = sphh;
            para.etype = etypeval;
            para.ogroup = ogroupval;
            para.TheContent = content;
            para.IsActive = "1";
            para.IsShow = "1";
            var paraJson = JSON.stringify(para);
            SaveEvaluation(para, true);
        }

        //提交评论到后台
        function SaveEvaluation(paras, async) {
            if (async)
                LeeJSUtils.showMessage("loading", "保存中..");

            var paraJson = JSON.stringify(paras);
            $.ajax({
                url: "goodsListCoreV7.aspx?ctrl=SaveEvaluation",
                type: "post",
                dataType: "text",
                async: async,
                contentType: "application/x-www-form-urlencoded; charset=utf-8",
                data: { paraJson: paraJson },
                timeout: 15000,
                error: function (e) {
                    LeeJSUtils.showMessage("error", "评论暂存失败!" + e.toString());
                },
                success: function (res) {
                    var rtObj;
                    try {
                        rtObj = JSON.parse(res);
                    } catch (e) {
                        LeeJSUtils.showMessage("error", res);
                        return false;
                    }

                    if (rtObj.code == "200") {
                        $("#editID").val(rtObj.Info.id);

                        if (async == true) {        //如果是图片上传前的预处理，则不执行提示
                            if ($("#list_" + $("#editID").val()).length > 0) {//已存在评论列表，编辑,移除原来内容
                                $(".myComment-ul #list_" + $("#editID").val()).remove();
                            }
                            myCommentPageInit();
                            rtObj.Info.ogroupid = $(".ogroup.active").attr("data-id");
                            rtObj.Info.etypeid = $(".etype.active").attr("data-id");
                            newComment(rtObj.Info);
                            LeeJSUtils.showMessage("successed", "保存成功！");
                        }
                    } else {
                        LeeJSUtils.showMessage("error", rtObj.msg);
                    }
                }
            });
        }

        //新增一条评论
        function newComment(rtobj) {
            var commentLi0 = "<div class='list-wrap' id='list_#id#' > <input class='hiddleCommentID' value='#id#' /><div class='edit floatfix' ><p>编辑</p></div><li class='single-li floatfix'><div class='top-item floatfix'><div class='user-img'><img class='user-img' src='#userimg#'/></div>";
            commentLi0 += "<p class='user-name'>#username#</p><p class='type-txt'><span class='comtype' data-id='#etypeid#'>#type#</span><span>|</span><span class='sort' data-id='#ogroupid#'>#sort#</span></p></div>";
            commentLi0 += "<div class='bottom-item'><p class='user-view'>#commentContent#</p><p class='date'>#date#</p> <ul class='upload-img-list floatfix'>#imgs#</ul></div></li></div>";

            var commentLi = "<div class='list-wrap' id='list_#id#' > <input class='hiddleCommentID' value='#id#' /><div class='edit floatfix' ><p>编辑</p><img class='red_paper_icon' src='../../res/img/storesaler/redpaper.png' /><div class='red_paper' onclick='showRedPaper(this);'>共<span class='red_counts'>#totalreward#</span>赏金</div></div><li class='single-li floatfix'><div class='top-item floatfix'><div class='user-img'><img class='user-img' src='#userimg#'/></div>";
            commentLi += "<p class='user-name'>#username#</p><p class='type-txt'><span class='comtype' data-id='#etypeid#'>#type#</span><span>|</span><span class='sort' data-id='#ogroupid#'>#sort#</span></p></div>";
            commentLi += "<div class='bottom-item'><p class='user-view'>#commentContent#</p><p class='date'>#date#</p> <ul class='upload-img-list floatfix'>#imgs#</ul></div></li></div>";
            var imgLi = "<li class='upload-img'><img class='upload-img' src='#imgsrc#' imgid='#imgid#' /></li>";
            var LiHtml = "", srcList = "";
            if (rtobj.totalreward == "0" || rtobj.totalreward == "")
                LiHtml = commentLi0.replace("#userimg#", rtobj.userimg).replace("#username#", rtobj.username).replace("#sort#", rtobj.ogroup).replace("#type#", rtobj.etype).replace("#ogroupid#", rtobj.ogroupid).replace("#etypeid#", rtobj.etypeid);
            else
                LiHtml = commentLi.replace("#userimg#", rtobj.userimg).replace("#username#", rtobj.username).replace("#sort#", rtobj.ogroup).replace("#type#", rtobj.etype).replace("#ogroupid#", rtobj.ogroupid).replace("#etypeid#", rtobj.etypeid).replace("#totalreward#", rtobj.totalreward);
            LiHtml = LiHtml.replace("#commentContent#", rtobj.centent).replace("#date#", rtobj.date).replace(/\#id\#/g, rtobj.id);
            if (rtobj.img.length > 0) {
                srcList = "";
                for (var j = 0; j < rtobj.img.length; j++) {
                    srcList += imgLi.replace("#imgid#", rtobj.img[j].imgid).replace("#imgsrc#", rtobj.img[j].imgurl);
                }
                LiHtml = LiHtml.replace("#imgs#", srcList);
            } else {
                LiHtml = LiHtml.replace("#imgs#", "");
            }
            $(".myComment-ul").find("div").first().before(LiHtml);
            EditBtnInit(); //编辑按钮初始化

            $('#myComment_page').animate({ scrollTop: 250 }, 250);
        }
        window.onload = function () {
            var typeID = LeeJSUtils.GetQueryParams("typeId");
            $(".panel .item .blacktxt").removeClass("blacktxt");
            if (typeID == "myComment") {
                $("#salePoint_page").addClass("page-left");
                $("#myComment_page").removeClass("page-right");
                $(".wypl").addClass("blacktxt");
            } else {
                $("#salePoint_page").removeClass("page-left");
                $("#myComment_page").addClass("page-right");
                $(".cpmd").addClass("blacktxt");
            }

            var val1 = $("#choose-sort-panel .popup-ul li").eq(0);
            //$("#etype").text(val1.text());
            //$("#etype").attr("value", val1.attr("value"));
            val1.remove();

            var val2 = $("#issue-type-panel .popup-ul li").eq(0);
            $("#ogroup").text(val2.text());
            $("#ogroup").attr("value", val2.attr("value"));
            val2.remove();

            if (Isay != "") {
                $("#myComment").trigger("touchend");
            } else {
                $("#salePoint").trigger("touchend");
            }

            var sayType = LeeJSUtils.GetQueryParams("sayType");
            //console.log(sayType);
            //质量反馈：选择 版型、面料 两种之一进行反馈；
            //开发建议：选择 面料、辅料 两种之一进行反馈；
            switch (sayType) {
                case "quality":
                    $(".etype[data-value='辅料']").hide();
                    $(".ogroup[data-id=7]").addClass("active");
                    break;
                case "suggest":
                    $(".etype[data-value='版型']").hide();
                    $(".ogroup[data-id=5]").addClass("active");
                    break;
                default:
                    $(".ogroup[data-id=6]").addClass("active");
                    $(".etype").removeClass("active").hide();
                    //$(".class_group").hide();
                    break;
            }

            $(function () {
                FastClick.attach(document.body);
            });
        }
        //加载所有评论列表
        function LoadEvaluation() {
            $.ajax({
                url: "goodsListCoreV7.aspx?ctrl=LoadEvaluation",
                type: "post",
                dataType: "text",
                data: { sphh: sphh, LoadCount: "20", onlyMy: false },
                timeout: 15000,
                error: function (e) {
                    LeeJSUtils.showMessage("error", "读取评论失败！请重试...");
                },
                success: function (res) {
                    //console.log(res);
                    var rtObj;
                    try {
                        rtObj = JSON.parse(res);
                    } catch (e) {
                        // alert(res);
                        return false;
                    }
                    var evaluations = rtObj.evaluations;
                    setCommentList(rtObj.evaluations);
                }
            });
        }

        function setCommentList(evaluations) {
            var commentLi0 = "<li class='single-li floatfix'><div class='top-item floatfix'><div class='user-img'><img class='user-img' src='#userimg#'/></div><p class='user-name'>#username#</p>";
            commentLi0 += "<p class='type-txt'><span class='comtype' data-id='#etypeid#'>#type#</span><span>|</span><span class='sort' data-id='#ogroupid#'>#sort#</span></p></div>";
            commentLi0 += "<div class='bottom-item'><p>#commentContent#</p><p class='date'>#date#</p> <ul class='upload-img-list floatfix'>#imgs#</ul></div></li>";

            var commentLi = "<li class='single-li floatfix'><div class='single_red'><img class='red_paper_icon' src='../../res/img/storesaler/redpaper.png' /><div class='red_paper' onclick='showRedPaper(this,\"all\");' data-id='#dataid#'>共<span class='red_counts'>#totalreward#</span>赏金</div></div><div class='top-item floatfix'><div class='user-img'><img class='user-img' src='#userimg#'/></div><p class='user-name'>#username#</p>";
            commentLi += "<p class='type-txt'><span class='comtype' data-id='#etypeid#'>#type#</span><span>|</span><span class='sort' data-id='#ogroupid#'>#sort#</span></p></div>";
            commentLi += "<div class='bottom-item'><p>#commentContent#</p><p class='date'>#date#</p> <ul class='upload-img-list floatfix'>#imgs#</ul></div></li>";
            var imgLi = "<li class='upload-img'><img class='upload-img' src='#imgsrc#'/></li>";
            var LiHtml = "", srcList = "";

            $("#salePoint_page .comment-list").html("");
            for (var i = 0; i < evaluations.length; i++) {
                if (parseInt(evaluations[i].totalreward) == 0)
                    LiHtml = commentLi0.replace("#userimg#", evaluations[i].userimg).replace("#username#", evaluations[i].username).replace("#sort#", evaluations[i].ogroup).replace("#type#", evaluations[i].etype).replace("#ogroupid#", evaluations[i].ogroupid).replace("#etypeid#", evaluations[i].etypeid).replace("#dataid#",evaluations[i].id);
                else
                    LiHtml = commentLi.replace("#userimg#", evaluations[i].userimg).replace("#username#", evaluations[i].username).replace("#sort#", evaluations[i].ogroup).replace("#type#", evaluations[i].etype).replace("#ogroupid#", evaluations[i].ogroupid).replace("#etypeid#", evaluations[i].etypeid).replace("#totalreward#", evaluations[i].totalreward).replace("#dataid#", evaluations[i].id);
                LiHtml = LiHtml.replace("#commentContent#", evaluations[i].centent).replace("#date#", evaluations[i].date);
                if (evaluations[i].img.length > 0) {
                    srcList = "";
                    for (var j = 0; j < evaluations[i].img.length; j++) {
                        srcList += imgLi.replace("#imgsrc#", evaluations[i].img[j]);
                    }
                    LiHtml = LiHtml.replace("#imgs#", srcList);
                } else {
                    LiHtml = LiHtml.replace("#imgs#", "");
                }
                $("#salePoint_page .comment-list").append(LiHtml);
            }

            previewImageInit();
        }

        //加载我的评论列表
        function LoadMyComment() {
            $.ajax({
                url: "goodsListCoreV7.aspx?ctrl=LoadEvaluation",
                type: "post",
                dataType: "text",
                data: { sphh: sphh, LoadCount: "200", onlyMy: true },
                timeout: 15000,
                error: function (e) {
                    LeeJSUtils.showMessage("error", "读取我的评论失败！请重试...");
                },
                success: function (res) {
                    var rtObj;
                    try {
                        rtObj = JSON.parse(res);
                    } catch (e) {
                        alert(res);
                        return false;
                    }
                    var evaluations = rtObj.evaluations;
                    setMyComment(rtObj.evaluations);
                }
            });
        }
        //我的评论列表
        function setMyComment(evaluations) {
            var commentLi0 = "<div class='list-wrap' id='list_#id#' > <input class='hiddleCommentID' value='#id#' /><div class='edit floatfix' ><p>编辑</p></div><li class='single-li floatfix'><div class='top-item floatfix'><div class='user-img'><img class='user-img' src='#userimg#'/></div>";
            commentLi0 += "<p class='user-name'>#username#</p><p class='type-txt'><span class='comtype' data-id='#etypeid#'>#type#</span><span>|</span><span class='sort' data-id='#ogroupid#'>#sort#</span></p></div>";
            commentLi0 += "<div class='bottom-item'><p class='user-view'>#commentContent#</p><p class='date'>#date#</p> <ul class='upload-img-list floatfix'>#imgs#</ul></div></li></div>";

            var commentLi = "<div class='list-wrap' id='list_#id#' > <input class='hiddleCommentID' value='#id#' /><div class='edit floatfix' ><p>编辑</p><img class='red_paper_icon' src='../../res/img/storesaler/redpaper.png' /><div class='red_paper' onclick='showRedPaper(this);'>共<span class='red_counts'>#totalreward#</span>赏金</div></div><li class='single-li floatfix'><div class='top-item floatfix'><div class='user-img'><img class='user-img' src='#userimg#'/></div>";
            commentLi += "<p class='user-name'>#username#</p><p class='type-txt'><span class='comtype' data-id='#etypeid#'>#type#</span><span>|</span><span class='sort' data-id='#ogroupid#'>#sort#</span></p></div>";
            commentLi += "<div class='bottom-item'><p class='user-view'>#commentContent#</p><p class='date'>#date#</p> <ul class='upload-img-list floatfix'>#imgs#</ul></div></li></div>";
            var imgLi = "<li class='upload-img'><img class='upload-img' src='#imgsrc#' imgid='#pid#' /></li>";
            var LiHtml = "", srcList = "";
            for (var i = 0; i < evaluations.length; i++) {
                if (parseInt(evaluations[i].totalreward) == "0" || evaluations[i].totalreward == "")
                    LiHtml = commentLi0.replace("#userimg#", evaluations[i].userimg).replace("#username#", evaluations[i].username).replace("#sort#", evaluations[i].ogroup).replace("#type#", evaluations[i].etype).replace("#ogroupid#", evaluations[i].ogroupid).replace("#etypeid#", evaluations[i].etypeid);
                else
                    LiHtml = commentLi.replace("#userimg#", evaluations[i].userimg).replace("#username#", evaluations[i].username).replace("#sort#", evaluations[i].ogroup).replace("#type#", evaluations[i].etype).replace("#ogroupid#", evaluations[i].ogroupid).replace("#etypeid#", evaluations[i].etypeid).replace("#totalreward#", evaluations[i].totalreward);
                LiHtml = LiHtml.replace("#commentContent#", evaluations[i].centent).replace("#date#", evaluations[i].date).replace(/\#id\#/g, evaluations[i].id);
                if (evaluations[i].img.length > 0) {
                    srcList = "";
                    for (var j = 0; j < evaluations[i].img.length; j++) {
                        srcList += imgLi.replace("#imgsrc#", evaluations[i].img[j]).replace("#pid#", evaluations[i].imgID[j]);
                    }
                    LiHtml = LiHtml.replace("#imgs#", srcList);
                } else {
                    LiHtml = LiHtml.replace("#imgs#", "");
                }
                $(".myComment-ul .tip-wrap").before(LiHtml);
            }
            EditBtnInit();
            previewImageInit();
        }

        function delImg(Pid) {
            var rtn = false;
            $.ajax({
                url: "goodsListCoreV7.aspx?ctrl=DelImgs&Pid=" + Pid,
                type: "POST",
                dataType: "text",
                timeout: 5000,
                async: false,
                error: function (XMLHttpRequest, textStatus, errorThrown) {
                    LeeJSUtils.showMessage("error", "删除图片失败...");
                },
                success: function (result) {
                    if (result == "") {
                        imgNum--;
                        rtn = true;
                    } else {
                        LeeJSUtils.showMessage("error", result);
                    }
                }
            });

            return rtn;
        }

        //删除图片的执行过程。
        function DeleteImageInit() {
            $(".DelImgBtn").unbind("click", DeleteImage);
            $(".DelImgBtn").click("click", DeleteImage);
        }

        function DeleteImage() {
            var imgid = $(this).attr("imgid");
            if (imgid == "0" || imgid == "") {
                return;
            }

            if (confirm("是否删除这张图片？")) {
                if (delImg(imgid) == true) {
                    $(this).parent().remove();
                }
            }
        }

        function previewImage() { //微信预览图片
            var arrUrls = new Array();
            var s = this;
            var p;

            if ($(s).attr("class") == "upload-img") {
                p = $(s).parent().parent();
                $.each($(p).find("img"), function (i, val) {
                    arrUrls[i] = $(val).attr("src");
                    arrUrls[i] = arrUrls[i].replace("/my/", "/");
                });

                var nowpic = $(s).attr("src");
                nowpic = nowpic.replace("/my/", "/");

                wx.previewImage({
                    current: nowpic, // 当前显示图片的http链接
                    urls: arrUrls // 需要预览的图片http链接列表
                });
            }
        }

        function previewImageInit() {
            $(".upload-img").unbind("click", previewImage);
            $(".upload-img").bind("click", previewImage);
        }

        function EditBtnInit() {
            // 编辑按钮初始化编辑内容
            $(".edit>p").unbind("click", EditBtn);
            $(".edit>p").bind("click", EditBtn);
        }

        function EditBtn() {
            var txt = $(this).parent().parent(".list-wrap").find(".user-view").text();
            $(".input-box").val(txt);
            var id = $(this).parent().parent(".list-wrap").find(".hiddleCommentID").val();
            $("#editID").val(id);
            var ogroupid = $(this).parent().parent(".list-wrap").find(".sort").attr("data-id");
            var etypeid = $(this).parent().parent(".list-wrap").find(".comtype").attr("data-id");

            $(".class_group .ogroup").removeClass("active");
            $(".class_group .ogroup[data-id='" + ogroupid + "']").addClass("active");
            switch (ogroupid) {
                case "7"://质量反馈
                    $(".etype").show();
                    $(".etype[data-value='辅料']").hide();
                    break;
                case "5"://开发建议
                    $(".etype").show();
                    $(".etype[data-value='版型']").hide();
                    break;
                default:
                    $(".etype").hide();
                    //$(".class_group").hide();
                    break;
            }

            $(".etype.active").removeClass("active");
            $(".etype[data-id='" + etypeid + "']").addClass("active");
            $(".etype .fa-check-circle").removeClass("fa-check-circle").addClass("fa-circle-o");
            $(".etype[data-id='" + etypeid + "'] i").removeClass("fa-circle-o").addClass("fa-check-circle");
            //$(".class_group").show();

            imgNum = 0;
            //<i class="close fa fa-close fa-1x"></i>
            $(".photo-pre").html("<li  class='camera-border' onclick='chooseFile()'><i class='camera fa fa-camera fa-2x'></i><p style='font-size:12px;text-align:center;height:auto;line-height:normal;margin:0;float:none;'>上传买家秀</p></li>");
            var pLi = "<li class='pre-item'><img class='pre-item' src='#src#'/><i class='DelImgBtn fa fa-remove fa-2x' imgid='#imgid#' ></i></li>";
            var imgs = $("#list_" + id).find("li .upload-img").find("img");
            for (var i = 0; i < imgs.length; i++) {
                $(".photo-pre").append(pLi.replace("#src#", imgs[i].src).replace("#imgid#", $(imgs[i]).attr("imgid")));
                imgNum++;
            }

            DeleteImageInit();

            $('#myComment_page').animate({ scrollTop: 0 }, 100);
            return false;
        }

        function myCommentPageInit() {
            $("#editID").val("0");
            $(".input-box").val("");
            $(".photo-pre").html("<li class='camera-border' onclick='chooseFile()'><i class='camera fa fa-camera fa-2x'></i><p style='font-size:12px;text-align:center;height:auto;line-height:normal;margin:0;float:none;'>上传买家秀</p></li>");
            imgNum = 0;
        }

        //点击录音按钮
        function StartVoice() {
            console.log("录音开始");
            // wx.startRecord();
        }

        //录音结束
        function StopVoice() {

        }

        //上传图片
        function chooseFile() {
            if ($("#editID").val() == "0") {//先保存后上传图片	            
                var etypeval = $(".etype.active").attr("data-id");//版型、面料、辅料
                var ogroupval = $(".ogroup.active").attr("data-id");//开发建议、质量反馈
                if (etypeval == "" || etypeval == "0") {
                    LeeJSUtils.showMessage("warn", "请先选择评论分类");
                    return false;
                }
                if (ogroupval == "" || ogroupval == "0") {
                    LeeJSUtils.showMessage("warn", "请先选择评论类型");
                    return false;
                }

                var para = new Object();
                para.ID = $("#editID").val();
                para.sphh = sphh;
                para.etype = etypeval;
                para.ogroup = ogroupval;
                para.TheContent = $(".input-box").val();
                para.IsActive = "0";
                para.IsShow = "0";
                SaveEvaluation(para, false);
            }
            if (imgNum >= 5) {
                LeeJSUtils.showMessage("warn", "目前最多只能上传5张图片,谢谢!");
                return false;
            }
            $("#choosefile").trigger("click");
            $("#choosefile").click();
        }

        var imgItem = new Array();
        //{大对象 有方法有属性} 图片上传
        $("input:file").localResizeIMG({
            width: 500,
            quality: 0.8,
            before: function (that, blob) {
                LeeJSUtils.showMessage("loading", "图片上传中..");
                var filePath = $("#choosefile").val();
                var extStart = filePath.lastIndexOf(".");
                var ext = filePath.substring(extStart, filePath.length).toUpperCase();
                if (ext != ".BMP" && ext != ".PNG" && ext != ".GIF" && ext != ".JPG" && ext != ".JPEG") {
                    LeeJSUtils.showMessage("warn", "只能上传图片");
                    return false;
                }
                var orientation = 0;
                var imgfile = that.files[0];
                fr = new FileReader;
                fr.readAsBinaryString(imgfile);
                fr.onloadend = function () {
                    var exif = EXIF.readFromBinaryFile(new BinaryFile(this.result));
                    if (exif.Orientation == undefined)
                        oRotate = 0;
                    else
                        oRotate = exif.Orientation;
                };
                return true;
            },
            success: function (result) {
                $(".photo-pre").append("<li class='pre-item'><img class='pre-item uploading' src=" + result.base64 + " /><i class='DelImgBtn fa fa-remove fa-2x' imgid='0' ></li>");
                var $lastli = $(".photo-pre li:last");
                $.ajax({
                    url: "goodsListCoreV7.aspx?ctrl=SaveImgs&rotate=" + oRotate + "&sid=" + $("#editID").val(),
                    type: "POST",
                    data: { formFile: result.clearBase64 },
                    dataType: "text",
                    timeout: 30000,
                    error: function (XMLHttpRequest, textStatus, errorThrown) {
                        LeeJSUtils.showMessage("error", "网络出错");
                        $lastli.remove();
                    },
                    success: function (result) {
                        imgNum++;
                        if (result.indexOf("success") != 0) {
                            LeeJSUtils.showMessage("error", "上传失败");
                            $lastli.remove();
                        } else {
                            LeeJSUtils.showMessage("successed", "上传成功");
                            var info = result.split("|");
                            $lastli.find("i").attr("imgid", info[1]);
                            $lastli.find("img").attr("class", "pre-item");
                            DeleteImageInit();
                        }
                    }
                });
            }
        });

        function goback() {
            var link = "goodsListV7.aspx?sphh=" + sphh;
            window.location.href = link;
        }

        //快速关键词输入
        $(".quick_words_wrap").on("click", ".quick_word", function () {
            var keyword = $(this).text();
            $(".input-box").val($(".input-box").val() + keyword);
        })

        $(".class_group").on("click", ".etype", function () {
            var eid = $(this).attr("data-id");
            if ($(this).hasClass("active"))
                return;

            $(".etype.active").removeClass("active");
            $(".etype .fa-check-circle").removeClass("fa-check-circle").addClass("fa-circle-o");
            $("i", $(this)).removeClass("fa-circle-o").addClass("fa-check-circle");
            $(this).addClass("active");
        });

        //显示打赏明细列表
        function showRedPaper(obj, type) {
            var id = "0";
            if (type == "all")
                id = $(obj).attr("data-id");
            else
                id = $(obj).parent().parent(".list-wrap").find(".hiddleCommentID").val();
            $("#redpaper_detail .red_counts").text($(".red_counts", $(obj)).text());
            LeeJSUtils.showMessage("loading", "正在加载打赏记录，请稍候...");
            $.ajax({
                url: "goodsListCoreV7.aspx?ctrl=LoadReward",
                type: "POST",
                data: { id: id },
                dataType: "text",
                timeout: 10 * 1000,
                error: function (XMLHttpRequest, textStatus, errorThrown) {
                    LeeJSUtils.showMessage("error", "网络出错");
                },
                success: function (result) {
                    if (result != "" && result.indexOf("Error:") <= -1) {
                        var html = "";
                        var data = JSON.parse(result);
                        for (var i = 0; i < data.rows.length; i++) {
                            var row = data.rows[i];
                            html += template("reward_temp",row);
                        }//end for
                        $("#redpaper_ul").empty().html(html);
                        var headimg = "";
                        if (type == "all")
                            headimg = $(obj).parent().parent().find("img.user-img").attr("src");
                        else
                            headimg = $(obj).parent().parent(".list-wrap").find("img.user-img").attr("src");
                        $("#redpaper_detail .headimg.top").css("background-image", "url(" + headimg + ")");                        

                        $("#redpaper_detail").show();                        
                    }
                    
                    $("#leemask").hide();
                }
            });
        }
    </script>
</asp:Content>
