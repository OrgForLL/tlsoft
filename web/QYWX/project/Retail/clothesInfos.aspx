<%@ Page Language="C#" %>

<%@ Import Namespace="nrWebClass" %>
<%@ Import Namespace="System.Data" %>
<%@ Import Namespace="System.Data.SqlClient" %>
<%@ Import Namespace="System.Collections.Generic" %>
<!DOCTYPE html>
<script runat="server">  
    public string ryid = "0";
    public string AppSystemKey = "";
    private const string ConfigKeyValue = "1";	//微信配置信息索引值
    public List<string> wxConfig;       //微信OPEN_JS 动态生成的调用参数
    private string ChatProConnStr = System.Configuration.ConfigurationManager.ConnectionStrings["Conn"].ConnectionString;
    private string DBConstr = clsConfig.GetConfigValue("OAConnStr");

    //public string dzxm = "陈红", mdid = "1906", mdmc = "嘉善市解放路店 ";
    public string dzxm = "", mdid = "", mdmc = "";
    protected void Page_Load(object sender, EventArgs e)
    {
        if (clsWXHelper.CheckQYUserAuth(true))
        {
            string SystemID = "3";
            AppSystemKey = clsWXHelper.GetAuthorizedKey(Convert.ToInt32(SystemID));
            ryid = AppSystemKey;
            if (AppSystemKey == "")
                clsWXHelper.ShowError("对不起，您还未开通全渠道系统权限！");
            else
            {
                clsWXHelper.CheckQQDMenuAuth(15);    //检查菜单权限
                
                mdid = Session["mdid"].ToString();
                if (Session["RoleID"].ToString() != "2" && Session["RoleID"].ToString() != "99")
                    clsWXHelper.ShowError("对不起，您无权限使用此功能！");
                using (LiLanzDALForXLM dal = new LiLanzDALForXLM(ChatProConnStr))
                {
                    string sql = "select top 1 relateID,nickname from wx_t_OmniChannelUser where id='" + AppSystemKey + "'";
                    DataTable dt = null;
                    string errinfo = dal.ExecuteQuery(sql, out dt);
                    if (dt.Rows.Count == 0)
                        clsWXHelper.ShowError("");
                    else if (dt.Rows[0][0].ToString() == "0")
                        clsWXHelper.ShowError("对不起，找不到您对应的人资资料！");
                    else
                    {
                        ryid = dt.Rows[0][0].ToString();
                        dzxm = dt.Rows[0][1].ToString();
                        using (LiLanzDALForXLM dal2 = new LiLanzDALForXLM(DBConstr))
                        {
                            sql = "select top 1 mdmc from t_mdb where mdid=" + mdid;
                            errinfo = dal2.ExecuteQuery(sql, out dt);
                            if (errinfo == "" && dt.Rows.Count > 0)
                                mdmc = dt.Rows[0][0].ToString();
                        }
                    }
                }
            }
        }
        else
        {
            clsWXHelper.ShowError("鉴权失败！");
        }  

        //店长身份判断
        //String userid = Convert.ToString(Session["qy_customersid"]);              
        //if (userid == null || userid == "" || userid == "0")
        //{
        //    ////获取用户鉴权的方法:该方法要求用户必须已成功关注企业号，主要是用于获取Session["qy_customersid"] 和其他登录信息
        //    //if (!clsWXHelper.CheckQYUserAuth(true))
        //    //{
        //    //    Response.Redirect("../../WebBLL/Error.aspx?msg=请先关注利郎企业号！");
        //    //    Response.End();
        //    //} 
        //}
        //else
        //{            
        //            using (LiLanzDALForXLM dal = new LiLanzDALForXLM(clsConfig.GetConfigValue("FormalModeConnStr")))
        //            {                
        //                //准备JS脚本
        //                string str_sql = @"
        //                                    if not exists( 
        //                                     select top 1 1 
        //                                     from wx_t_customer a
        //                                     inner join wx_t_AppAuthorized b on b.userid=a.id
        //                                     inner join wx_t_AppInfomation c on b.systemid=c.id
        //                                     where a.id=@qyuserid )
        //                                    select '00';
        //                                    else
        //                                    select top 1 a.xm,m.mdid,m.mdmc,isnull(c.gw,'') gw
        //                                    from rs_t_ryjbzl a
        //                                    inner join wx_t_AppAuthorized wa on wa.userid=@qyuserid and wa.systemid=2 and a.id=wa.systemkey
        //                                    left join wx_t_vipbinging b on a.id=b.vipid and b.objectid=3
        //                                    left join rs_t_rydwzl c on a.id=c.id
        //                                    left join t_mdb m on m.mdid=c.mdid ";
        //                List<SqlParameter> paras = new List<SqlParameter>();
        //                paras.Add(new SqlParameter("@qyuserid", userid));
        //                DataTable dt = null;
        //                string errinfo = dal.ExecuteQuerySecurity(str_sql, paras, out dt);
        //                if (errinfo == "")
        //                {                             
        //                    if (dt.Rows.Count > 0 && dt.Rows[0][0].ToString() != "00")
        //                    {
        //                        if (dt.Rows[0]["gw"].ToString() == "266")
        //                        {
        //                            //店长的岗位ID为266
        //                            dzxm = dt.Rows[0]["xm"].ToString();
        //                            mdid = dt.Rows[0]["mdid"].ToString();
        //                            mdmc = dt.Rows[0]["mdmc"].ToString();
        //                        }
        //                        else
        //                            execJS("对不起，只有店长才有权限使用此功能！");
        //                    }
        //                    else
        //                        execJS("请先加入利郎企业号并通过人资系统认证！");
        //                }
        //                else
        //                    execJS("执行查询时出错！ info:" + errinfo.Replace("'",""));                             
        //            }

        //}
        wxConfig = clsWXHelper.GetJsApiConfig(ConfigKeyValue);
    }

    public void execJS(string txt)
    {
        System.Text.StringBuilder htmlPlanContent = new System.Text.StringBuilder();
        htmlPlanContent.Append("<script language='javaScript' type='text/javascript'>");
        htmlPlanContent.Append("alert('" + txt + "');");
        htmlPlanContent.Append("</");
        htmlPlanContent.Append("script>");
        Response.Write(htmlPlanContent.ToString());
        Response.Flush();
        Response.End();
    }
</script>
<html>
<head runat="server">
    <meta charset="utf-8" />
    <meta name="viewport" content="width=device-width,initial-scale=1,user-scalable=0">
    <title></title>
    <link rel="stylesheet" type="text/css" href="../../res/css/font-awesome.min.css" />
    <style type="text/css">
        * {
            margin: 0;
            padding: 0;
        }

        body {
            color: #333;
            background: #eeeeee;
            font-family: Helvetica,Arial,STHeiTi,"Hiragino Sans GB","Microsoft Yahei","微软雅黑",STHeiti,"华文细黑",sans-serif;
        }

        .container {
            width: 100%;
            max-width: 550px;
            margin: 0 auto;
            padding: 10px 15px 15px 15px;
            box-sizing: border-box;
            position: relative;
        }

        h2 {
            text-align: center;
        }

        hr {
            margin-top: 10px;
            border: 1px dashed #333;
        }

        .sum, .charts {
            margin-top: 10px;
        }

        .infoitem {
            margin-top: 10px;
            display: block;
        }

        .item, .itemval {
            text-align: center;
            word-wrap: break-word;
            word-break: break-all;
            white-space: nowrap;
            display: table-cell;
        }

        .item {
            color: #fff;
            background: #333;
            padding: 6px 15px;
            min-width: 64px;
        }

        .itemval {
            font-size: 1em;
            border-bottom: 2px solid #333;
            width: 2000px;
        }

        .sum h3 {
            margin-top: 10px;
        }

        .charts span {
            display: block;
            text-align: center;
        }

        .occupy {
            text-align: center;
            margin: 10px 0;
            padding: 6px 0;
            background: #333;
            color: #fff;
        }

        .star {
            position: absolute;
            left: 50%;
            margin-left: -40px;
            margin-top: 10px;
        }

        .scanbtn {
            position: absolute;
            text-decoration: none;
            display: block;
            text-align: center;
            margin: 30px auto 15px auto;
            padding: 10px;
            color: #fff;
            background: #333;
            box-sizing: border-box;
            width: 80px;
            height: 80px;
            border-radius: 40px;
            font-size: 1.2em;
            line-height: 60px;
            font-weight: 600;
        }

        .copyright {
            text-align: center;
            width: 100%;
            color: #808080;
            font-size: 0.8em;
            margin-top: 140px;
        }
        /*动画心跳动画*/
        .star b {
            width: 80px;
            height: 80px;
            display: block;
            border-radius: 40px;
            margin: 30px auto 15px auto;
            position: absolute;
            background-color: #808080;
            -webkit-transform: scale(2);
            opacity: .2;
            -webkit-animation: zdjpop .8s infinite;
        }

        @-webkit-keyframes zdjpop {
            0% {
                opacity: 1;
                -webkit-transform: scale(1);
            }

            100% {
                opacity: 0;
                -webkit-transform: scale(1.3);
            }
        }

        .floatfix:after {
            content: "";
            display: table;
            clear: both;
        }

        .store {
            float: left;
            height: 20px;
            line-height: 20px;
            vertical-align: middle;
            font-weight: bold;
        }

            .store img {
                width: 25px;
                height: 25px;
            }

        .exclam {
            font-weight: bold;
            border: 1px dashed #333;
            padding: 45px 8px 10px 8px;
            text-align: center;
            position: relative;
            background: #fff;
        }

        .exclamp {
            background: #333;
            position: absolute;
            left: 0;
            top: 0;
            width: 100%;
            color: #fff;
            font-size: 1.5em;
            padding: 2px 0px;
        }

        .legend {
            text-align: center;
            margin-bottom: 10px;
        }

            .legend span {
                display: inline-block;
                width: 16px;
                height: 16px;
                line-height: 16px;
                vertical-align: middle;
                margin: 0px 10px;
            }

        #hh-legend {
            background: rgb(240,173,78);
        }

        #pl-legend {
            background: rgb(51,122,183);
        }

        .fa-user {
            font-size: 1.3em;
        }

        .sphhinput {
            position: fixed;
            bottom: 0;
            left: 0;
            width: 100%;
            height: 50px;
            padding: 5px;
            box-sizing: border-box;
            background-color: #eee;
            box-shadow: 0 0 2px #ccc;            
        }

            .sphhinput input {
                -webkit-appearance: none;
                border-radius: 5px;
                border: 1px solid #e0e0e0;
                height: 40px;
                line-height: 40px;
                width: 100%;
                font-size: 15px;
                box-sizing: border-box;
                padding: 0 10px;
                color: #888;
            }

        .searbtn {
            position: fixed;
            right: 5px;
            bottom: 5px;
            width: 50px;
            height: 40px;
            font-size: 20px;
            text-align: center;
            line-height: 40px;
            color: #555;
            border-left: 1px solid #e0e0e0;            
        }

        .mask {
            color: #fff;
            position: fixed;
            top: 0;
            bottom: 0;
            left: 0;
            right: 0;
            z-index: 2001;
            font-size: 1.1em;
            text-align: center;
            display: none;
            background-color: rgba(0,0,0,0.5);
        }

        .center-translate {
            position: absolute;
            top: 50%;
            left: 50%;
            -webkit-transform: translate(-50%, -50%);
            transform: translate(-50%, -50%);
        }

        .loader {
            background-color: rgba(39, 43, 46, 0.7);
            padding: 15px 20px;
            border-radius: 5px;
        }

        #loadtext,#loadtext2 {
            font-size: 0.8em;
            margin-top: 5px;
            font-weight: bold;
        }  
        /*kcsl style*/
        #kcmx {
            position: fixed;
            top:0;
            left:0;
            width: 100%;
            height: 100%;
            background-color: #fff;                        
            z-index: 2000;
            padding: 12px;
            box-sizing: border-box;
            display: none;
            overflow-x:hidden;
            overflow-y:auto;
            -webkit-overflow-scrolling: touch;
            overflow-scrolling: touch;
        }

        .closebtn {
            position:absolute;
            top:10px;
            right:10px;  
            font-size:1.4em;          
            background-color:#444;
            padding:4px 10px;
            color:#fff;
            border-radius:4px;
        }
        .htitle {                        
            font-size:1em;
            font-weight:bold;
            color:#444; 
            margin-bottom:5px;                      
        }
        .ht2 {                        
            border-bottom:2px solid #555;            
        }
        ul.cmmxul {
            list-style:none;  
            border-radius:5px;
        }
            .cmmxul li {
                width:25%;
                box-sizing:border-box;
                float:left;
                text-align:center;                
                border-right:1px solid #ebebeb;  
                border-bottom:1px solid #ebebeb;             
            }

                .cmmxul li:nth-child(4n+1){
                    border-left:1px solid #ebebeb;  
                }

        .item-h {
            padding:8px;
            background:#444;
            color:#fff;
            font-size:16px;
            font-weight:bold;
        }

        .item-b {
            padding:10px 0;
            font-weight:bold;                       
        }
    </style>
</head>
<body>
    <div class="container">
        <div class="floatfix">
            <div class="store"><i class="fa fa-user"></i><span id="dzxm">-- </span></div>
            <div class="store">
                <img src="../../res/img/Retail/storeicon.png" />
            </div>
            <div class="store"><span id="storename">-- </span></div>
        </div>
        <div style="padding-bottom: 170px;">
            <div class="title">
                <h2><i class="fa fa-tags"></i>货号信息</h2>
                <hr />
                <div class="infoitem">
                    <div class="item">商品货号</div>
                    <div class="itemval" id="sphh">--</div>
                </div>
                <div class="infoitem">
                    <div class="item">商品名称</div>
                    <div class="itemval" id="spmc">--</div>
                </div>
                <div class="infoitem">
                    <div class="item">规 格</div>
                    <div class="itemval" id="cmmc">--</div>
                </div>
                <div class="infoitem">
                    <div class="item">吊牌价</div>
                    <div class="itemval"><strong>￥</strong><strong id="lsdj">--</strong></div>
                </div>
            </div>
            <div class="sum">
                <h2><i class="fa fa-calculator"></i>统计信息</h2>
                <hr />
                <h3>货号相关数据：</h3>
                <p style="color:#d75548;font-weight:bold;">点击库存数字可查看具体尺码明细！</p>
                <div class="infoitem">
                    <div class="item">本月销量</div>
                    <div class="itemval" id="hhbysl">--</div>
                </div>
                <div class="infoitem">
                    <div class="item">总销售量</div>
                    <div class="itemval" id="hhxsl">--</div>
                </div>
                <div class="infoitem">
                    <div class="item">总采购量</div>
                    <div class="itemval" id="hhcgsl">--</div>
                </div>
                <div class="infoitem">
                    <div class="item">售罄率</div>
                    <div class="itemval" id="hhsql">--</div>
                </div>
                <div class="infoitem">
                    <div class="item" style="background-color:#d75548;">当前库存</div>
                    <div class="itemval" id="hhkcsl" style="color:#d75548;border-bottom-color:#d75548;" onclick="LoadCMMX()">--</div>
                </div>
                <h3>同品类相关数据：</h3>
                <div class="infoitem">
                    <div class="item">本月销量</div>
                    <div class="itemval" id="plbysl">--</div>
                </div>
                <div class="infoitem">
                    <div class="item">总销售量</div>
                    <div class="itemval" id="plxsl">--</div>
                </div>
                <div class="infoitem">
                    <div class="item">总采购量</div>
                    <div class="itemval" id="plcgsl">--</div>
                </div>
                <div class="infoitem">
                    <div class="item">售罄率</div>
                    <div class="itemval" id="plsql"><strong>--</strong></div>
                </div>
                <div class="occupy">该货号在该品类中的占比：<span id="occupyval" style="font-weight: bold;">--</span></div>
                <div class="exclam">
                    <p class="exclamp"><i class="fa fa-exclamation-circle"></i></p>
                    <p>总采购量=门店的采购入库数量</p>
                    <p>售罄率=总销售量 ÷（采购量+调拨量）</p>
                </div>
            </div>
            <div class="charts">
                <h2><i class="fa fa-bar-chart-o"></i>图表信息</h2>
                <hr />
                <div id="can1">
                    <canvas id="canvas1" height="200px"></canvas>
                    <div class="legend"><span id="hh-legend"></span>货号数据<span id="pl-legend"></span>同品类数据</div>
                    <span style="margin: 10px 0;">销售量分布图</span>
                    <div class="exclam">
                        <p class="exclamp"><i class="fa fa-exclamation-circle"></i></p>
                        <p style="text-align:left;">1、单击图表可以查看具体数据！</p>
                        <p style="text-align:left;">2、进入扫描界面后也可以选择手机相册中的二维码图片！</p>
                    </div>
                </div>
            </div>
            <hr />
            <div class="star">
                <b></b>
                <a class="scanbtn" href="#" onclick="scanQRCode()">扫一扫</a>
            </div>
            <div id="ltcon"></div>
        </div>
        <div class="sphhinput">
            <input type="text" id="areatxt" placeholder="请输入要查询的完整货号" /><!--value="5QNZ20201" -->
            <div class="searbtn" onclick="search()"><i class="fa fa-search"></i></div>
        </div>
    </div>
    <div class="mask">
        <div class="loader center-translate">
            <div>
                <i class="fa fa-2x fa-spinner fa-pulse"></i>
            </div>
            <p id="loadtext2">正在加载,请稍候...</p>
        </div>
    </div>

    <%--库存尺码分布--%>    
    <div id="kcmx">
        <div class="closebtn" onclick="javascript:$(this).parent().fadeOut(100);">
            <i class="fa fa-times"></i>
        </div>
        <p class="htitle" id="cmmx_sphh">--</p>
        <p class="htitle ht2" id="cmmx_mdmc">--</p>
        <ul class="cmmxul">
        </ul>
    </div>    
    <script type="text/javascript" src="../../res/js/jquery.js"></script>
    <script type="text/javascript" src="../../res/js/Chart.min.js"></script>
    <script type="text/javascript" src="http://res.wx.qq.com/open/js/jweixin-1.0.0.js"></script>
    <script type="text/javascript">
        var appIdVal = "<%=wxConfig[0]%>", timestampVal = "<%=wxConfig[1]%>", nonceStrVal = "<%=wxConfig[2]%>", signatureVal = "<%=wxConfig[3]%>";
        var interval,barchart;
        var sphh = "", mdid = "<%=mdid%>", mdmc = "<%=mdmc%>";        
        var isProcessing = false;//用于控制在上一次操作完成后才能开始扫下一个二维码

        window.onload = function () {
            $("#dzxm").text(" <%=dzxm%>");
            $("#storename").text(mdmc);

            //WeiXin JS-SDK
            $(".title").hide();
            $(".sum").hide();
            $(".charts").hide();
            jsConfig();            
        }

        function jsConfig() {
            wx.config({
                debug: false,
                appId: appIdVal, // 必填，公众号的唯一标识
                timestamp: timestampVal, // 必填，生成签名的时间戳
                nonceStr: nonceStrVal, // 必填，生成签名的随机串
                signature: signatureVal, // 必填，签名，见附录1
                jsApiList: ['hideMenuItems', 'scanQRCode'] // 必填，需要使用的JS接口列表，所有JS接口列表见附录2
            });
            wx.ready(function () {                
                wx.hideMenuItems({
                    menuList: ['menuItem:share:qq', 'menuItem:share:timeline', 'menuItem:share:weiboApp', 'menuItem:share:QZone', 'menuItem:openWithSafari', 'menuItem:openWithQQBrowser', 'menuItem:share:email', 'menuItem:copyUrl'] //menuItem:share:appMessage 要隐藏的菜单项，只能隐藏“传播类”和“保护类”按钮，所有menu项见附录3
                });
                scanQRCode();
            });

            wx.error(function (res) {
                alert("JS注入失败！");
            });
        }

        //加载库存尺码明细
        function LoadCMMX() {
            var kcsl = $("#hhkcsl").text().replace("件","");
            if (kcsl == "" || parseInt(kcsl) == 0 || kcsl == undefined || kcsl == "--") return;
            showLoader("loading", "正在加载库存尺码明细,请稍候...");
            $.ajax({
                url: "../../WebBLL/labelProcess.aspx?ctrl=LoadCMMX",
                type: "POST",
                dataType: "text",
                data: { sphh: sphh, mdid:mdid },
                cache: false,//不使用缓存
                timeout: 10*1000,
                error: function (XMLHttpRequest, textStatus, errorThrown) {
                    showLoader("error","您的网络好像有点问题,请稍后重试...");
                    isProcessing = false;
                    hideLoadingText();                    
                },
                success: function (result) {
                    if (result.indexOf("Error:") > -1) {
                        showLoader("error", result.replace("Error:",""));
                        isProcessing = false;
                        hideLoadingText();
                    } else {                        
                        var data = JSON.parse(result);
                        var len = data.rows.length;                        
                        var cmmx_html = "";
                        var li_temp = "<li><div class='item-h'>#name#</div><div class='item-b'>#sl#</div></li>";
                        for (var i = 0; i < len; i++) {
                            var row = data.rows[i];
                            cmmx_html += li_temp.replace("#name#", row.cm).replace("#sl#", row.sl0);
                        }//end for
                        $(".cmmxul").children().remove();
                        $(".cmmxul").append(cmmx_html);
                        $("#cmmx_sphh").text("货号：" + sphh);
                        $("#cmmx_mdmc").text("门店：" + mdmc);
                        $("#kcmx").fadeIn(200);
                        showLoader("successed", "加载成功!");
                    }                    
                }
            });
        }

        //查询货号的基本信息
        function GetSphhInfos(tm, type) {
            showLoadingText("正在查询货号信息,请稍候");
            isProcessing = true;
            $.ajax({
                url: "../../WebBLL/labelProcess.aspx?ctrl=sphhInfo",
                type: "POST",
                dataType: "text",
                data: { tmcode: tm, type: type },
                cache: false,//不使用缓存
                timeout: 10*1000,
                error: function (XMLHttpRequest, textStatus, errorThrown) {
                    showLoader("error", "[GSIS]您的网络好像出现了点问题,请重试!");
                    isProcessing = false;
                    hideLoadingText();                    
                },
                success: function (result) {
                    if (result.indexOf("Error:") > -1) {
                        showLoader("error", result.replace("Error:",""));
                        isProcessing = false;
                        hideLoadingText();
                    } else {
                        var strArr = result.split("|");
                        sphh = strArr[0];
                        $("#sphh").text(sphh);                        
                        $("#spmc").text(strArr[3]);
                        $("#lsdj").text(strArr[2]);
                        if (type == "scan")
                            $("#cmmc").text(strArr[1]);
                        else
                            $("#cmmc").text("--");
                        $(".title").slideDown();
                        getCount();
                    }
                }
            });
        }

        //统计数据
        function getCount() {
            showLoadingText("正在分析相关数据,请稍候");
            $.ajax({
                url: "../../WebBLL/labelProcess.aspx?ctrl=getCount",
                type: "POST",
                dataType: "text",
                data: { sphh: sphh, mdid: mdid },
                cache: false,//不使用缓存
                timeout: 10*1000,
                error: function (XMLHttpRequest, textStatus, errorThrown) {
                    showLoader("warn", "[GC]您的网络好像出现了点问题,请重试!");
                    isProcessing = false;
                    hideLoadingText();
                },
                success: function (result) {
                    if (result.indexOf("Error:") > -1) {
                        showLoader("error", result);
                        isProcessing = false;
                        hideLoadingText();
                    } else {
                        if (result.split(':').length > 1) {
                            var strArr = result.split(":")[0].split("|");
                            var xssl = strArr[1];
                            var cgrksl = strArr[2];
                            var dbsl = strArr[3];
                            var kcsl = parseInt(cgrksl) + parseInt(dbsl);
                            var hhxsl = strArr[1];
                            $("#hhbysl").text(strArr[0] + "件");
                            $("#hhxsl").text(xssl + "件");
                            $("#hhcgsl").text(cgrksl + "件");
                            if (kcsl != 0) {
                                $("#hhsql").text((parseInt(xssl) * 100 / kcsl).toFixed(2) + "%");
                            }
                            if (strArr[4] != "")
                                $("#hhkcsl").text(strArr[4] + "件");

                            strArr = result.split(":")[1].split("|");
                            xssl = strArr[1];
                            cgrksl = strArr[2];
                            dbsl = strArr[3];
                            kcsl = parseInt(cgrksl) + parseInt(dbsl);
                            $("#plbysl").text(strArr[0] + "件");
                            $("#plxsl").text(xssl + "件");
                            $("#plcgsl").text(cgrksl + "件");

                            if (kcsl != 0) {
                                $("#plsql").text((parseInt(xssl) * 100 / kcsl).toFixed(2) + "%");
                            }
                            if (xssl != "0")
                                $("#occupyval").text((parseInt(hhxsl) * 100 / parseInt(xssl)).toFixed(2) + "%");
                            $(".sum").slideDown();

                            drawCharts();
                        }
                    }//end if else
                }
            });
        }

        //扫码入口
        function scanQRCode() {
            if (isProcessing) {
                showLoader("warn","请等待上一次操作完成!");
            } else {
                $(".title").hide();
                $(".sum").hide();
                $(".charts").hide();
                wx.scanQRCode({
                    needResult: 1, // 默认为0，扫描结果由微信处理，1则直接返回扫描结果，
                    scanType: ["qrCode"], // 可以指定扫二维码还是一维码，默认二者都有
                    success: function (res) {
                        var result = res.resultStr; // 当needResult 为 1 时，扫码返回的结果                    
                        var tmid = getQueryString(result, "id");
                        if (tmid == undefined || tmid == null || result.indexOf("tm.aspx") == -1) {
                            alert("请扫描衣服吊牌上的二维码！");
                            scanQRCode();
                            return;
                        }
                        GetSphhInfos(tmid, "scan");
                    }
                });
            }
        }

        function drawCharts() {
            showLoadingText("正在绘制图表,请稍候");
            var labels = new Array();
            var hhdatas = new Array();
            var pldatas = new Array();
            $.ajax({
                url: "../../WebBLL/labelProcess.aspx?ctrl=getChartDatas",
                type: "POST",
                dataType: "text",
                data: { sphh: sphh, mdid: mdid },
                cache: false,//不使用缓存
                timeout: 10*1000,
                error: function (XMLHttpRequest, textStatus, errorThrown) {
                    showLoader("error", "[DC]您的网络好像出现了点问题,请重试!");
                    isProcessing = false;
                    hideLoadingText();
                },
                success: function (result) {
                    if (result.indexOf("Error:") > -1) {
                        showLoader("error", result);
                        isProcessing = false;
                        hideLoadingText();
                    } else {
                        var datas = JSON.parse(result);
                        var len = datas.rows.length;
                        for (var i = 0; i < len; i++) {
                            var datarow = datas.rows[i];
                            labels.push(num2chs(datarow.ny.substring(4)));
                            hhdatas.push(parseInt(datarow.hhxssl));
                            pldatas.push(parseInt(datarow.plxssl));
                        }

                        var data1 = {
                            labels: labels,
                            datasets: [
                                {
                                    fillColor: "rgba(240,173,78,1)",
                                    strokeColor: "rgba(220,220,220,1)",
                                    data: hhdatas
                                },
                                {
                                    fillColor: "rgba(51,122,183,1)",
                                    strokeColor: "rgba(220,220,220,1)",
                                    data: pldatas
                                }
                            ]
                        }//end data1

                        $("canvas").attr("width", document.body.clientWidth - 40 + "px");
                        if (barchart != undefined)
                            barchart.destroy();
                        barchart = new Chart(document.getElementById("canvas1").getContext("2d")).Bar(data1);
                        $(".charts").slideDown();
                        clearInterval(interval);
                        $("#loadtext").text("-全部完成-").delay(1000).fadeOut(500);
                    }

                    isProcessing = false;
                }
            });
        }

        function showLoadingText(str) {
            var obj = $("#ltcon");
            if (interval != null && interval != undefined) {
                clearInterval(interval);
                obj.children().remove();
            }
            var loadtextHtml = "<div id='loadtext' style='font-weight:bold;font-size:1.1em;text-align:center;color:#c9302c;margin-top:5px;'>" + str + "</div>";
            obj.append(loadtextHtml);
            interval = window.setInterval(function () {
                var loadobj = $("#loadtext");
                var text = loadobj.text();
                if (text.length < str.length + 8) {
                    loadobj.text(text + ' . ');
                } else {
                    loadobj.text(str);
                }
            }, 400);
        }

        function hideLoadingText() {            
            if (interval != null && interval != undefined) {
                clearInterval(interval);
                $("#ltcon").children().remove();
            }
        }

        function num2chs(ny) {
            switch (ny) {
                case "01":
                    return "一月";
                case "02":
                    return "二月";
                case "03":
                    return "三月";
                case "04":
                    return "四月";
                case "05":
                    return "五月";
                case "06":
                    return "六月";
                case "07":
                    return "七月";
                case "08":
                    return "八月";
                case "09":
                    return "九月";
                case "10":
                    return "十月";
                case "11":
                    return "十一月";
                case "12":
                    return "十二月";
            }
        }

        function getQueryString(url, name) {
            var reg = new RegExp("(^|&)" + name + "=([^&]*)(&|$)", "i");
            var r = url.substr(url.indexOf("?") + 1).match(reg);
            if (r != null) return unescape(r[2]); return null;
        }

        function search() {
            var st = $("#areatxt").val();
            if (st == "")
                showLoader("warn", "请输入完整货号!");
            else if (isProcessing) {
                showLoader("warn","请等待上一次的操作完成!");
            } else {
                $(".title").slideUp();
                $(".sum").slideUp();
                $(".charts").slideUp();
                GetSphhInfos(st, "search");
            }
        }

        function showLoader(type, txt) {
            switch (type) {
                case "loading":
                    $(".mask .fa").removeAttr("class").addClass("fa fa-2x fa-spinner fa-pulse");
                    $("#loadtext2").text(txt);
                    $(".mask").show();
                    break;
                case "successed":
                    $(".mask .fa").removeAttr("class").addClass("fa fa-2x fa-check");
                    $("#loadtext2").text(txt);
                    $(".mask").show();
                    setTimeout(function () {
                        $(".mask").fadeOut(200);
                    }, 1000);
                    break;
                case "error":
                    $(".mask .fa").removeAttr("class").addClass("fa fa-2x fa-close (alias)");
                    $("#loadtext2").text(txt);
                    $(".mask").show();
                    setTimeout(function () {
                        $(".mask").fadeOut(200);
                    }, 1500);
                    break;
                case "warn":
                    $(".mask .fa").removeAttr("class").addClass("fa fa-2x fa-warning (alias)");
                    $("#loadtext2").text(txt);
                    $(".mask").show();
                    setTimeout(function () {
                        $(".mask").fadeOut(200);
                    }, 1500);
                    break;
            }
        }
    </script>
</body>
</html>
