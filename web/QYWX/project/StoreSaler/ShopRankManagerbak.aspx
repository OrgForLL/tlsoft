<%@ Page Title="琅琊榜_管理" Language="C#" MasterPageFile="../../WebBLL/frmQQDBase.Master" AutoEventWireup="true" %>

<%@ MasterType VirtualPath="../../WebBLL/frmQQDBase.Master" %>

<%@ Import Namespace="nrWebClass" %>
<%@ Import Namespace="System.Data" %>


<script runat="server">
    /*子页面首先运行Page_Load，再运行主页面Page_Load；因此，只需要在子页面Page_Load事件中对Master.SystemID 进行赋值；
      主页面将会在其Page_Load事件中自动鉴权获取 AppSystemKey.之后请在子页面的Page_PreRender 或 JS中进行相关处理(比如：加载页面内容等)。
      请格外注意：万万不要在子页面的Load事件中直接使用用户的Session，因为Session是在主页面中获取的顺序在后，这将会导致异常！
    
         附：母版页和内容页的触发顺序    
         * 母版页控件 Init 事件。    
         * 内容控件 Init 事件。
         * 母版页 Init 事件。    
         * 内容页 Init 事件。    
         * 内容页 Load 事件。    
         * 母版页 Load 事件。    
         * 内容控件 Load 事件。    
         * 内容页 PreRender 事件。    
         * 母版页 PreRender 事件。    
         * 母版页控件 PreRender 事件。    
         * 内容控件 PreRender 事件。
     */
    public string ryid = "0";
    public string mdid = "";
    public string RoleID = "1";
    public string khOptions = "";
    protected void Page_PreRender(object sender, EventArgs e)
    {
        clsWXHelper.CheckQQDMenuAuth(29);    //检查菜单权限

        mdid = Convert.ToString(Session["mdid"]);
        RoleID = Convert.ToString(Session["RoleID"]);

        //mdid = "0";
        //ryid = "0";
        //RoleID = "3";

        DataTable dt; 
        if (RoleID == "4")
        {
            dt = clsWXHelper.GetQQDAuth(true, false);
            CalKhlist(ref dt);
        }
        else
        {
            string strSQL = string.Concat(@"SELECT A.khid,MIN(mdid) mdid,A.khmc mdmc,A.ssid FROM yx_t_khb A 
                                                INNER JOIN t_mdb B ON A.khid = B.khid AND A.ssid = 1 AND A.yxrs = 1 AND A.ty = 0
                                                                    AND ISNULL(A.sfdm,'') <> ''
                                            GROUP BY A.khid,A.khmc,A.ssid
                                            ORDER BY A.khmc");

            string strConn = clsConfig.GetConfigValue("OAConnStr"); 
            using (LiLanzDALForXLM dal = new LiLanzDALForXLM(strConn))
            { 
                string strInfo = dal.ExecuteQuery(strSQL, out dt);

                if (strInfo == "")
                {
                    CalKhlist(ref dt);
                }
                else
                {                    
                    clsLocalLoger.WriteError("读取启用人资的贸易公司出错！错误：" + strInfo);
                    clsWXHelper.ShowError("读取启用人资的贸易公司出错！");
                }
            } 
        } 
    }

    //必须在内容页的Load中对Master.SystemID 进行赋值；
    protected void Page_Load(object sender, EventArgs e)
    {
        //this.Master.IsTestMode = true; 
    }

    private void CalKhlist(ref DataTable dt)
    {
        if (dt != null)
        {
            string optionBase = @"<option value=""{0}"">{1}</option>";
            StringBuilder sbOption = new StringBuilder();
            foreach (DataRow dr in dt.Rows)
            {
                sbOption.AppendFormat(optionBase, dr["mdid"], dr["mdmc"]);
            }

            khOptions = sbOption.ToString();
            sbOption.Length = 0;

            dt.Clear(); dt.Dispose(); dt = null;
        }
    }

</script>

<asp:Content ID="Content1" ContentPlaceHolderID="head" runat="server">
    <meta name="format-detection" content="telephone=no" />
    <title>琅琊榜_管理</title> 
    <link type="text/css" rel="stylesheet" href="../../res/css/LeePageSlider.css" />
    <link type="text/css" rel="stylesheet" href="../../res/css/font-awesome.min.css" />
    <style type="text/css">
        body {
            background-color: #f7f7f7;
            color: #31343b;
            font-size: 14px;
        }

        .header {
            background-color: #1c1b20;
            height: 46px;
            font-size: 0;
            font-weight: bold;
        }

        .page {
            top: 46px;
            background-color: #f7f7f7;
        }

        .header > a, .tab-nav > a {
            display: inline-block;
            width: 25%;
            font-size: 16px;
            height: 46px;
            line-height: 46px;
            color: #fff;
        }

        .header .current-nav {
            background-color: #f7f7f7;
            color: #31343b;
        }

        .tab-nav .current-nav {
            color: #31343b;
        }

        .tab-nav {
            background-color: #fff;
            border-radius: 3px;
            font-size: 0;
            box-shadow: 0 1px .5px #eceef1;
            -webkit-box-shadow: 0 1px .5px #eceef1;
            position: relative;
        }

            .tab-nav > a {
                font-size: 14px;
                color: #999;
                text-align: center;
                height: 40px;
                line-height: 40px;
            }

                .tab-nav > a span {
                    height: 40px;
                    display: inline-block;
                }

            .tab-nav .slider {
                display: block;
                position: absolute;
                bottom: 0;
                left: 0;
                height: 2px;
                background: #31343b;
                width: 25%;
                transition: all 0.5s;
                -webkit-transition: all 0.5s;
            }

        .list 
        {  
            width: 100%;
            margin-top: 20px;
            box-shadow: 0 1px .5px #eceef1;
            -webkit-box-shadow: 0 1px .5px #eceef1;
            background-color: #fff;
                        
            -webkit-transition: -webkit-transform .4s cubic-bezier(.4,.01,.165,.99);
            transition: transform .4s cubic-bezier(.4,.01,.165,.99);            
            transform: translate3d(-100%, 0, 0);
            -webkit-transform: translate3d(-100%, 0, 0);
            display:none;
        }

        .top3 {
            font-size: 0;
            padding: 15px 5px 5px 5px;
            border-bottom: 1px solid #f7f7f7;
        }

            .top3 .top3-item {
                display: inline-block;
                width: 33.33%;
                font-size: 16px;
                position: relative;
            }

                .top3 .top3-item:not(:last-child) {
                    border-right: 1px solid #f4f4f4;
                }

        .top3-item p {
            text-align: center;
        }

        .top3-item .headimg {
            width: 62px;
            height: 62px;
            border-radius: 50%;
            /*border: 4px solid #f0f0f0;*/
            margin: 10px auto 5px auto;
            position: relative;
            z-index: 1000;
        }

        .backimg {
            background-size: cover;
            background-position: 50% 50%;
            background-repeat: no-repeat;
        }

        .rank {
            margin-bottom: 8px;
            margin-top: -25px;
            height: 20px;
            line-height: 20px;
        }

        .money {
            font-weight: bold;
            margin-top: 5px;
        }

        .rank span {
            background-color: #31343b;
            color: #fff;
            border-radius: 2px;
            padding: 2px 5px;
            font-size: 0.9em;
            font-weight: bold;
        }

        .ranklist {
            padding: 0 5px;
        }

            .ranklist li {
                height: 58px;
                padding: 5px 0;
                position: relative;
                padding-left: 62px;
            }

                .ranklist li:not(:last-child) {
                    border-bottom: 1px solid #f7f7f7;
                }

            .ranklist .headimg {
                width: 48px;
                height: 48px;
                border-radius: 50%;
                border: 2px solid #f0f0f0;
                position: absolute;
                top: 5px;
                left: 5px;
            }

        .info-name {
            font-size: 1.1em;
            font-weight: bold;
            line-height: 26px;
            color: #555;
        }

      
        .info-quote {
            line-height: 18px;
            white-space: nowrap;
            overflow: hidden;
            text-overflow: ellipsis;
            color: #777;
        }
         
        .info-quote>img 
        {
            width:20px;
            height:20px;
            position:relative;
            top:4px;    
        }
        
        .fromstore
        {
            left:0;
            width:100%;
            text-align:center;
            vertical-align:middle;
            color:White;
            background-color:#31343b;
            line-height: 18px;
            white-space: nowrap;
            overflow: hidden;
            text-overflow: ellipsis; 
            padding-top:6px;
            font-size: 18px;            
        }
        
        .fromstore>img 
        {
            width:30px;
            height:30px;
            position:relative;
            top:6px;                
        }

        .info-grade {
            position: absolute;
            top: 5px;
            right: 5px;
            font-weight: bold;
            color: #d9534f;
            font-size: 1.1em;
        }

        .myrank {
            position: fixed;
            bottom: 10px;
            right: 10px;
            width: 86px;
            height: 86px;
            background: -webkit-gradient(linear,right top,left bottom,from(#75cd69),to(#30a91d));
            z-index: 1002;
            border-radius: 50%;
            box-shadow: 0 0 3px 1px #ddd;
            border: 4px solid #fff;
            overflow: hidden;
            box-sizing:content-box;
        }

            .myrank p {
                font-weight: bold;
                font-size: 1em;
                text-align: center;
                color: #f7f7f7;
                white-space: nowrap;
            }

        .mask {
            position: fixed;
            top: 0;
            left: 0;
            width: 100%;
            height: 100%;
            background-color: #f8f8f8;
            z-index: 2000;
            display: none;
        }

        @-webkit-keyframes breathe {
            0% {
                box-shadow: 0 0 3px 1px rgba(204,204,204,0);
            }

            100% {
                box-shadow: 0 0 3px 1px rgba(204,204,204,.8);
            }
        }

        .breath {
            -webkit-animation-timing-function: ease-in-out; /*动画时间曲线*/
            -webkit-animation-name: breathe; /*动画名称，与@keyframes搭配使用*/
            -webkit-animation-duration: 0.8s; /*动画持续时间*/
            -webkit-animation-iteration-count: infinite; /*动画要重复次数*/
            -webkit-animation-direction: alternate; /*动画执行方向，alternate 表示反复*/
        }

           .loader-ring-light {
            position: absolute;
            top: 2px;
            left: 50%;
            width: 68px;
            height: 68px;
            margin-left: -34px;
            border-radius: 50%;
            z-index: 999;
            animation: rotate-360 2s linear infinite;
            -webkit-animation: rotate-360 2s linear infinite;
            box-shadow: 0 1px 2px #e53935;
        }

        @-webkit-keyframes rotate-360 {
            from {                
                -webkit-transform: rotate(0);
                transform: rotate(0);
            }

            to {                
                -webkit-transform: rotate(360deg);
                transform: rotate(360deg);
            }
        }

        /*个人分享页样式*/
        #personal {
            top: 0;
            padding: 0;
            z-index: 2100;
        }

        .person-win {
            width: 100%;
            height: 100px;
        }

        .share {
            width: 76%;
            height: 280px;
            background-color: #fff;
            position: absolute;
            top: 60px;
            left: 50%;
            transform: translate(-50%,0);
            -webkit-transform: translate(-50%,0);
            border-radius: 4px;
            box-shadow: 0 1px .5px #eceef1;
            -webkit-box-shadow: 0 1px .5px #eceef1;
            padding: 10px 15px;
            overflow: hidden;
        }

            .share .title {
                color: #31343b;
                font-size: 1.5em;
                font-weight: bold;
                margin-bottom: 10px;
            }

            .share .content {
                color: #555;
                font-size: 1.2em;
                line-height: 25px;
                overflow-x: hidden;
                overflow-y: auto;
                width: 100%;
                height: 191px;
                -webkit-overflow-scrolling: touch;
                overflow-scrolling: touch;
                text-shadow: 0 0 1px #ccc;
            }

        .content.inputcss {
            border: none;
            border-radius: 2px;
            text-shadow: none;
        }

        .person-info {
            position: relative;
            top: 240px;
            padding-bottom: 15px;
        }

            .person-info .headimg {
                width: 70px;
                height: 70px;
                border-radius: 50%;
                border: 4px solid #ebebeb;
                margin: 15px auto 0 auto;
            }

        .share .icons {
            position: absolute;
            left: 0;
            bottom: 0;
            width: 100%;
            height: 40px;
            line-height: 40px;
            text-align: right;
            padding: 0 15px;
            font-size: 0;
        }

        .icons a {
            display: inline-block;
            width: 40%;
            text-align: center;
            font-size: 16px;
            color: #31343b;
        }

        .fa-bookmark {
            font-size: 18px;
            color: #d8d8d8;
            width: 20%;
            display: inline-block;
            margin-bottom: -4px;
        }

        .person-info .name {
            text-align: center;
            font-size: 1.2em;
            font-weight: bold;
            color: #333;
            margin-top: 5px;
        }

        .person-info .money {
            text-align: center;
            color: #ff6600;
            font-size: 1.5em;
            font-weight: bold;
        }

        .person-info .mul-btns {
            position:absolute;
            top:0;
            left:0;
            width:100%;
            height:70px;            
            color:#999;   
            font-size:0;         
        }
        .btn-item {
            width:50%;
            text-align:center;
            font-size:14px;
            display:inline-block;
            padding-top:20px;
        }
        /*提示层样式*/
        .mymask {
            color: #fff;
            position: absolute;
            top: 0;
            bottom: 0;
            left: 0;
            right: 0;
            z-index: 5000;
            font-size: 1em;
            text-align: center;
            display: none;
            background-color: rgba(0,0,0,0.3);
        }

        .loader {
            position: absolute;
            top: 50%;
            left: 50%;
            transform:translate(-50%,-50%);
            -webkit-transform:translate(-50%,-50%);
            background-color: #272b2e;
            padding:15px;
            border-radius: 5px;
            box-sizing: border-box;
            box-shadow: 0px 0px 1px #555;
        }

        #loadtext {
            margin-top: 5px;
            font-weight: bold;
        }
        
        
        .Active
        {
            -webkit-transition: -webkit-transform .4s cubic-bezier(.4,.01,.165,.99);
            transition: transform .4s cubic-bezier(.4,.01,.165,.99);
            transform: translate3d(0, 0, 0);
            -webkit-transform: translate3d(0, 0, 0); 
            display:inline-block;
        }
        .mydata
        {
            display:none;
        }
        .hide
        {
            display:none;
        }
        .Honor
        {
            width:24px;
            height:24px;
        }
        
        .Winner1
        {
            /*color:#e53935;*/
        }
        .Winner1>p>span
        {            
            background-color:#e53935;
        }
        .Winner1 .loader-ring-light
        {            
            box-shadow: 0 1px 2px #e53935;
        }
        .Winner2
        {
            /*color:#ffac13;*/
        }
        .Winner2>p>span
        {            
            background-color:#ffac13;
        }
        .Winner2 .loader-ring-light
        {            
            box-shadow: 0 1px 2px #ffac13;
        }
        .Winner3
        {
            /*color:#83c44e;*/
        }
        .Winner3>p>span
        {            
            background-color:#83c44e;
        }
        .Winner3 .loader-ring-light
        {            
            box-shadow: 0 1px 2px #83c44e;
        }
         
         
         .nav-item2
         {     
            display: inline-block;
            width: 75%;
            font-size: 16px;
            height: 46px;
            line-height: 46px;
            color: #fff; 
         }
          
         #khsel
         {
              appearance:none;
              -moz-appearance:none;
              -webkit-appearance:none;
              border:0;
              font-size:16px;
              width:80%;  
              text-align:center;            
              color:inherit;
              background-color:inherit;
         }
         
    </style>
</asp:Content>
<asp:Content ID="Content2" ContentPlaceHolderID="ContentPlaceHolder1" runat="server">

    <div class="header">
        <span class="nav-item2 current-nav" onclick="changeArea('province')" id="province">
            
            <select id="khsel">  
              <%= khOptions %>
              <%--<option value="249">晋江第一份公司</option>  
              <option value="1900">福建晋江睿智商贸有限公司</option>  
              <option value="186">河南郑州派力特贸易公司</option>  
              <option value="4898">河南郑州凯利商贸有限责任公司</option>  --%>
            </select> 
            <i class="fa fa-search fa-lg" id="selectKH"></i> 
        </span>        
        <a href="javascript:void(0)" class="nav-item" onclick="changeArea('all')" id="all">全国</a>
    </div>
    <div class="wrap-page">
        <div class="page page-not-header">
            <div class="tab-nav">
                <a href="javascript:" onclick="switchView(this,'1')" class="nav-item current-nav" order="1"><span>今 日</span></a>
                <a href="javascript:" onclick="switchView(this,'2')" class="nav-item" order="2"><span>昨 日</span></a>
                <a href="javascript:" onclick="switchView(this,'3')" class="nav-item" order="3"><span>本 月</span></a>
                <a href="javascript:" onclick="switchView(this,'4')" class="nav-item" order="4"><span>上 月</span></a>
                <span class="slider"></span>
            </div>
            <div class="list" id="shop0"></div>
            <div class="list" id="shop1"></div>
            <div class="list" id="shop2"></div>
            <div class="list" id="shop3"></div>
            <div class="list" id="area0"></div>
            <div class="list" id="area1"></div>
            <div class="list" id="area2"></div>
            <div class="list" id="area3"></div>
            <div class="list" id="province0"></div>
            <div class="list" id="province1"></div>
            <div class="list" id="province2"></div>
            <div class="list" id="province3"></div>
            <div class="list" id="all0"></div>
            <div class="list" id="all1"></div>
            <div class="list" id="all2"></div>
            <div class="list" id="all3"></div>
        </div>
        <!--个人心得页-->
        <div class="page page-top" id="personal">
            <div class="fromstore"><img alt="" src="../../res/img/StoreSaler/shop.png" /><span></span></div>
            <div class="person-win backimg" style="background-color: #31343b;"></div>
            <div class="share">
                <p class="title">我的心得体会</p> 
                <a href="#" class="info-grade">业绩详情&gt;&gt;</a>
                <p class="content">内容</p>
                <textarea class="content inputcss" placeholder="在这里说点心得体会吧..." style="display: none;"></textarea>
                <div class="icons">
                    <a href="javascript:" onclick="CloseRemark();" style="color:#d9534f; font-weight:bold;">返 回</a>
                    <a href="javascript:" onclick="SaveRemark();" >保 存</a>
                    <i class="fa fa-bookmark"></i>
                </div>
            </div>
            <div class="person-info">
                <div class="headimg backimg"></div>
                <div class="mul-btns">
                    <div class="btn-item" onclick="showLoader('warn','敬请期待...');">
                        <i class="fa fa-heart"></i>
                        <p>为TA点赞</p>
                    </div>
                    <div class="btn-item">
                        <i class="fa (alias)"><img class="Honor" alt="徽章" src="" /></i>
                        <p>个人传记</p>
                    </div>
                </div>
                <p class="name">Elilee</p>
                <p class="money">128000元</p>
            </div>
        </div>
    </div>
    <!--我的排名 以球形展示-->
    <div class="myrank hide">
        <p class="center-translate">
            <span id="MyOrder">No.?</span><br />
            <span id="MyZje">?元</span><br />
            <span style="font-size: 0.9em; color: #31343b;">我的排名</span></p>
    </div>
    <div class="mask"></div>

    <!--提示层-->
    <div class="mymask">
        <div class="loader">
            <div>
                <i class="fa fa-2x fa-warning (alias)"></i>
            </div>
            <p id="loadtext">
                正在处理...
            </p>
        </div>
    </div>

    <script type="text/javascript" src="../../res/js/jquery.js"></script>
    <script type='text/javascript' src='../../res/js/StoreSaler/fastclick.min.js'></script>
    <script type='text/javascript' src='../../res/js/StoreSaler/jsHashTable.js'></script>  
    <script type="text/javascript" src="../../res/js/StoreSaler/jquery-ui.js"></script>
    <script type="text/javascript" src="../../res/js/StoreSaler/jquery.ui.touch-punch.js"></script> 
    <script type="text/javascript">

        var NowRankID = "";
        var NowRankName = "";
        var NowMonth = "2";
        var htMyInfo = new HashTable();
                
        window.onload = function () {
            changeArea("province");
        }

        //保存并显示我的排名信息
        function SaveAndShowMyInfo(myKey, data) {
            if (SaveMyOrderInfo(myKey, data)) {
                ShowMyInfo(myKey);
            }
        }

        //保存排名信息
        function SaveMyOrderInfo(myKey, data) {
            if (data.MyOrder != undefined) {
                var myData = data.MyOrder + "|" + GetWan(data.MyZje) + "元";
                htMyInfo.add(myKey, myData);

                return true;
            } else {
                return false;
            }
        }

        //显示排名信息
        function ShowMyInfo(myKey) {
            var myInfo = htMyInfo.getValue(myKey);
            if (myInfo != null) {
                myInfo = myInfo.split("|");

                $("#MyOrder").html("№" + myInfo[0]);
                $("#MyZje").html(myInfo[1]);                
                 
                return true;
            }else{
                return false;
            }
        }
               
        function CloseRemark() {
            $('#personal').addClass('page-top');
        }


        function switchView(obj, order) {
            switch (order) {
                case "1":
                    $(".tab-nav .current-nav").removeClass("current-nav");
                    $(obj).addClass("current-nav");
                    $(".tab-nav .slider").css("left", "0");
                    getMyRank("2");
                    break;
                case "2":
                    $(".tab-nav .current-nav").removeClass("current-nav");
                    $(obj).addClass("current-nav");
                    $(".tab-nav .slider").css("left", "25%");
                    getMyRank("3");
                    break;
                case "3":
                    $(".tab-nav .current-nav").removeClass("current-nav");
                    $(obj).addClass("current-nav");
                    $(".tab-nav .slider").css("left", "50%");
                    getMyRank("0");
                    break;
                case "4":
                    $(".tab-nav .current-nav").removeClass("current-nav");
                    $(obj).addClass("current-nav");
                    $(".tab-nav .slider").css("left", "75%");
                    getMyRank("1");
                    break;
            }
        }


        function getMyRank(datamonth) {
            changeArea(NowRankID, datamonth); 
        }

        function getRank(divname, rankname, datamonth) {
            var mdid = "<%= mdid %>";
            var ryid = "<%= ryid %>";

            if (divname == "province") {    //如果是按省份（贸易公司）
                var khid = $("#khsel").val(); 
                if (typeof (khid) == undefined || khid == "") { showLoader("error", "必须选择一个贸易公司！请联系IT部。");  return; }
                else mdid = khid;
            }


            NowRankID = divname;
            NowRankName = rankname;
            NowMonth = datamonth;
            //设置显示内容 
            $("#spanRankName").html(rankname); 

            if (ShowMyInfo(divname + datamonth) == true) { //如果能成功显示我的排名，则不继续查询数据
                $("#" + divname + rankname).css("opacity", 1);
                return;   
            }

            var rankhtml = "";
            rankhtml = "";

            var timestamp = Date.parse(new Date());
                         
            showLoader("loading", "正在加载数据...");
            $.ajax({
                type: "POST",
                timeout: 15000,
                datatype: "html",
                url: "ShopRankCore.aspx",
                data: { "ctrl": "getRank", "ryid": ryid, "mdid": mdid, "datatype": divname, "datamonth": datamonth, "ref": timestamp },
                cache: false,
                contentType: "application/x-www-form-urlencoded; charset=utf-8",
                success: function (data) {
                    showLoader("successed", "加载完毕！");
                    if (data.indexOf("Error:") == 0) {
                        data = data.substring(6);
                        $("#" + divname + datamonth).html(data);
                        return;
                    }

                    data = JSON.parse(data);
                    var len = data.rows.length;

                    SaveAndShowMyInfo(divname + datamonth, data);   //保存并显示我的排名 
                    if (len > 0) {

                        var premarkClass = "";      //用于判断我的心得
                        var myyj;
                        for (var i = 0; i < len; i++) {
                            var row = data.rows[i];
                            myyj = GetWan(row.zje) + "元";

                            row.myremark = ReplaceJson(row.myremark);

                            if (i == 0) rankhtml = "<div class=\"top3\">\n";
                            if (i == 3) rankhtml += "<ul class=\"ranklist\">\n";

                            if (i < 3) {
                                rankhtml += "<div class=\"top3-item Winner" + (i + 1).toString() + "\">\n" +
                                            "    <p class=\"rank\"><span>第 " + (i + 1).toString() + " 名</span></p>\n" +
                                            "    <div class=\"headimg backimg\" style=\"background-image: url(" + row.faceimg + ");\"></div>\n" +
                                            "    <div class=\"loader-ring-light\"></div>\n" +
                                            "    <p class=\"money\">" + myyj + "</p>\n" +
                                            "    <p class=\"name\">" + row.yyy + "</p>\n" +
                                            "    <span class=\"hide myremark\">" + row.myremark + "</span>\n" +
                                            "    <span class=\"mydata\" ryid=\"" + row.ryid + "\" cname=\"" + row.yyy + "\" yj=\"" + myyj + "\" LinkTitle=\"" + row.LinkTitle + "\" IconUrl=\""
                                                                             + row.IconUrl + "\" PageUrl=\"" + row.PageUrl + "\" mdid=\"" + row.mdid + "\" mdmc=\"" + row.mdmc + "\" />\n" +                                            
                                            "</div>";
                            } else {
                                rankhtml += "<li>\n" +
                                            "   <div class=\"headimg backimg\" style=\"background-image: url(" + row.faceimg + ");\"></div>\n" +
                                            "   <p class=\"info-name\">No." + (i + 1).toString() + " " + row.yyy + "</p>\n" +
                                            "   <p class=\"hide myremark\">" + row.myremark + "</p>\n" +
                                            "   <p class=\"info-quote\"><img alt=\"\" src=\"../../res/img/StoreSaler/shop.png\" />" + row.mdmc + "</p>\n" +
                                            "   <p class=\"info-grade\">" + myyj + "</p>\n" +
                                            "   <span class=\"mydata\" ryid=\"" + row.ryid + "\" cname=\"" + row.yyy + "\" yj=\"" + myyj + "\" LinkTitle=\"" + row.LinkTitle + "\" IconUrl=\""
                                                                             + row.IconUrl + "\" PageUrl=\"" + row.PageUrl + "\" mdid=\"" + row.mdid + "\" mdmc=\"" + row.mdmc + "\" />\n" +                                            
                                            "</li>";
                            }

                            if (i == 2) rankhtml += "</div>\n";                              
                        }

                        if (len > 3) rankhtml += "</ul>\n";
                        else if (len < 3) rankhtml += "</div>\n";


                        $("#" + divname + datamonth).html(rankhtml);

                        var obj = $("#" + divname + datamonth).children();

                        //                        $(obj).fadeInWithDelay();
                         
                    } else {
                        $("#" + divname + datamonth).html("暂时没有数据");
                    }
                },
                error: function (XMLHttpRequest, textStatus, errorThrown) {
                    showLoader("error", "加载错误！");
                    if (errorThrown.toString() != "") {     //如果没有错误，则不输出（AJAX调用期间，页面被关掉，也会出此错误；但错误内容为空）
                        alert(errorThrown);
                    }
                }
            });
        }

        function ReplaceJson(data) {
            data = data.replace(/\\r/g, "\r");
            data = data.replace(/\\n/g, "\n");
            return data;
        }

        function SaveRemark() {
            var ryid = "<%= ryid %>";
            var remark = $("#personal>.share>textarea").val();
            var timestamp = Date.parse(new Date());

            alert(remark);

            showLoader("loading","设置中...");
            $.ajax({
                type: "POST",
                timeout: 15000,
                datatype: "html",
                url: "ShopRankCore.aspx",
                data: { "ctrl": "saveRemark", "ryid": ryid, "datamonth": NowMonth, "remark": remark, "ref": timestamp },
                cache: false,
                contentType: "application/x-www-form-urlencoded; charset=utf-8",
                success: function (data) {
                    if (data == "Successed") {
                        showLoader("successed", "设置成功！");
                        setTimeout(function () {
                            location.reload();
                        }, 1000);
                    } else {
                        showLoader("error", data);
                    }
                },
                error: function (XMLHttpRequest, textStatus, errorThrown) {
                    if (errorThrown.toString() != "") {     //如果没有错误，则不输出（AJAX调用期间，页面被关掉，也会出此错误；但错误内容为空）
                        showLoader("error", "网络错误！");
                        alert(errorThrown);
                    }
                }
            });
        }

        
        function GetWan(y) {
            var rt;
            if (isNaN(y)) {
                rt = y;
            }else{
                var vvv = parseInt(y) * 0.0001;
                if (vvv < 10){
                    rt = y;
                }else{
                    vvv = parseInt(vvv);
                    rt = vvv.toString() + "万";
                }
            }

            return rt;
        }

           
        $(".area-display").click(function () {
            var area = $(".header .areaSelected").attr("id"); 

        });

        function changeArea(objid, datamonth) { 
            if (datamonth == undefined) {
                datamonth = NowMonth;
            }

            $(".header .current-nav").removeClass("current-nav");
            $("#" + objid).addClass("current-nav"); 
            switch (objid) {
                case "shop":
                    $(".Active").removeClass("Active");
                    $("#" + objid + datamonth).addClass("Active"); 
                    getRank(objid, "本店", datamonth); 
                    break;
                case "area":
                    $(".Active").removeClass("Active");
                    $("#" + objid + datamonth).addClass("Active");
                    getRank(objid, "区域", datamonth); 
                    break;
                case "province":
                    $(".Active").removeClass("Active");
                    $("#" + objid + datamonth).addClass("Active");
                    getRank(objid, "全省", datamonth); 
                    break;
                case "all":
                    $(".Active").removeClass("Active");
                    $("#" + objid + datamonth).addClass("Active");
                    getRank(objid, "全国", datamonth);
                    break;
                default:
                    break;

            } 
        } 

        $(function () {
            FastClick.attach(document.body);
            var obj = $(".vipul").children();
            $(obj).fadeInWithDelay();
        });
          
        $.fn.fadeInWithDelay = function () {
            var delay = 0;
            return this.each(function () {
                $(this).delay(delay).animate({ opacity: 1 }, 200);
                delay += 100;
            });
        }; 

        $(function () {
            $(".myrank").draggable();
            FastClick.attach(document.body);
        });

        //必须使用前期的对象才能进行后期绑定
        $(".list").on("click", ".top3-item,.ranklist>li", function () {

            var $this = $(this);
            var $data = $this.find(".mydata");

            //在店长身份下该行本店人员的业绩查询入口
            var mdid = "<%= mdid %>";
            if (NowRankID != "province") {
                $("#personal>.share>a").hide();
            } else {
                var ctrl = "all";
                if (NowMonth == "2") {  //今日
                    ctrl = "today";
                }

                $("#personal>.share>a").attr("href", "../Retail/tclist.aspx?ctrl=" + ctrl + "&ryid=" + $data.attr("ryid"));
                $("#personal>.share>a").fadeIn(300);
            }

            if ("<%= ryid %>" == $data.attr("ryid")) {
                $("#personal>.share>.content").hide();
                $("#personal>.share>textarea").html($this.find(".myremark").html());
                $("#personal>.share>textarea").show();
                $("#personal>.share>.icons>a").eq(1).fadeIn();    //显示保存按钮
                showLoader("warn", "开始分享你的心得吧！"); 
                $("#personal>.share>textarea").focus();
            } else {
                $("#personal>.share>.content").show();
                $("#personal>.share>textarea").hide();
                $("#personal>.share>.content").html($this.find(".myremark").html());
                $("#personal>.share>.icons>a").eq(1).hide();    //隐藏保存按钮
            }

            $("#personal>.person-info>.name").html($data.attr("cname"));
            $("#personal>.person-info>.money").html($data.attr("yj"));
            $("#personal>.person-info>.headimg").attr("style", $this.find(".headimg").attr("style"));
            $("#personal>.fromstore>span").html($data.attr("mdmc"));   //输出门店名称

            if ($data.attr("LinkTitle") != "") {
                $("#personal>.person-info>.mul-btns>.btn-item").eq(1).css("display", "inline-block");
                $("#personal>.person-info>.mul-btns>.btn-item").eq(1).on("click", function () {
                    window.location.href = $data.attr("PageUrl");
                });
                $("#personal>.person-info>.mul-btns>.btn-item>i>.Honor").attr("src", $data.attr("IconUrl"));
                $("#personal>.person-info>.mul-btns>.btn-item").eq(1).find("p").html($data.attr("LinkTitle"));
            } else {
                $("#personal>.person-info>.mul-btns>.btn-item").eq(1).css("display", "none");
            }

            $(".mask").show();
            $("#personal").removeClass("page-top");
        });

        $("#personal").on("webkitTransitionEnd", function () {
            if ($("#personal").hasClass("page-top"))
                $(".mask").fadeOut(250);
        });

        $("#khsel").on("change", function () {
            $("#province0").html("");
            $("#province1").html("");
            $("#province2").html("");
            $("#province3").html("");

            htMyInfo.remove("province0");
            htMyInfo.remove("province1");
            htMyInfo.remove("province2");
            htMyInfo.remove("province3");
        });
          
        //提示层
        function showLoader(type, txt) {
            switch (type) {
                case "loading":
                    $(".mymask .fa").removeAttr("class").addClass("fa fa-2x fa-spinner fa-pulse");
                    $("[id$=loadtext]").text(txt);
                    $(".mymask").show();
                    setTimeout(function () {
                        $(".mymask").fadeOut(500);
                    }, 15000);
                    break;
                case "successed":
                    $(".mymask .fa").removeAttr("class").addClass("fa fa-2x fa-check");
                    $("[id$=loadtext]").text(txt);
                    $(".mymask").show();
                    setTimeout(function () {
                        $(".mymask").fadeOut(500);
                    }, 500);
                    break;
                case "error":
                    $(".mymask .fa").removeAttr("class").addClass("fa fa-2x fa-close (alias)");
                    $("[id$=loadtext]").text(txt);
                    $(".mymask").show();
                    setTimeout(function () {
                        $(".mymask").fadeOut(500);
                    }, 2000);
                    break;
                case "warn":
                    $(".mymask .fa").removeAttr("class").addClass("fa fa-2x fa-warning (alias)");
                    $("[id$=loadtext]").text(txt);
                    $(".mymask").show();
                    setTimeout(function () {
                        $(".mymask").fadeOut(500);
                    }, 1000);
                    break;
            }
        }
    </script>
</asp:Content>
