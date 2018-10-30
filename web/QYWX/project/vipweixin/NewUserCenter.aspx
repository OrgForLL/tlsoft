<%@ Page Language="C#" %>

<%@ Import Namespace="nrWebClass" %>
<%@ Import Namespace="System.Data" %>
<%@ Import Namespace="System.Data.SqlClient" %>
<%@ Import Namespace="System.Collections.Generic" %>

<!DOCTYPE html>
<script runat="server">

    private string ChatProConnStr = clsWXHelper.GetWxConn();
    private string DBConStr = System.Configuration.ConfigurationManager.ConnectionStrings["Conn_1"].ConnectionString;
    public Hashtable VI = new Hashtable();

    protected void Page_Load(object sender, EventArgs e)
    {
        string ConfigKeyValue = clsConfig.GetConfigValue("CurrentConfigKey"); //取配置BLL.config
        if (clsWXHelper.CheckUserAuth(ConfigKeyValue, "openid"))
        {
            string _vipID = Convert.ToString(Session["vipid"]);

            if (_vipID == "" || _vipID == "0" || _vipID == null)
            {
                //Session["vipid"] = "";
                //Session["openid"] = "";
                Session.Clear();
                clsWXHelper.ShowError("请重新打开本功能....");
                return;
            }
            else
                UpdateLoginTime(_vipID);

            //生成访问日志
            clsWXHelper.WriteLog(string.Format("openid：{0} ，vipid：{1} 。访问功能页[{2}]", Convert.ToString(Session["openid"]), Convert.ToString(Session["vipid"]), "新版用户中心"));

            using (LiLanzDALForXLM zdal = new LiLanzDALForXLM(DBConStr))
            {
                using (LiLanzDALForXLM dal = new LiLanzDALForXLM(ChatProConnStr))
                {
                    //薛灵敏改成内连 INNER 。20160310
                    string str_sql = @"SELECT TOP 1
                                            a.wxNick ,
                                            CASE WHEN a.wxSex = 1 THEN '男'
                                                 ELSE '女'
                                            END xb ,
                                            a.wxCity ,
                                            a.wxProvince ,
                                            a.wxHeadimgurl ,
                                            ISNULL(a.vipID, 0) vipid ,
                                            ISNULL(vl.mc, '--') viplb,vip.xm as cname
                                        FROM    wx_t_vipBinging a
                                                INNER JOIN YX_T_Vipkh vip ON a.vipID = vip.id
                                                INNER JOIN YX_T_Viplb vl ON vip.klb = vl.Dm
                                        WHERE   a.wxOpenid = @openid";

                    string str_sql2 = @"SELECT TOP 1
                                                ISNULL(vi.charmvalue, 0) charmvalue ,
                                                ISNULL(vt.titlename, '') titlename
                                        FROM    wx_t_vipinfo vi
                                                LEFT JOIN wx_t_viptitle vt ON vt.id = vi.viptitle
                                        WHERE   vi.vipid = @vipid";
                    List<SqlParameter> paras = new List<SqlParameter>();
                    List<SqlParameter> paras2 = new List<SqlParameter>();
                    paras.Add(new SqlParameter("@openid", Convert.ToString(Session["openid"])));
                    paras2.Add(new SqlParameter("@vipid", Convert.ToString(Session["vipid"])));
                    DataTable dt = null;
                    DataTable dt2 = null;
                    string errinfo = zdal.ExecuteQuerySecurity(str_sql, paras, out dt);
                    errinfo += dal.ExecuteQuerySecurity(str_sql2, paras2, out dt2);
                    if (errinfo == "")
                    {
                        if (dt.Rows.Count == 0)
                        {                         
                            Session.Clear();
                            clsWXHelper.ShowError("请重新打开本功能.....");
                            return;
                        }
                        else
                        {
                            if (dt.Rows[0]["vipid"].ToString() == "0" || dt.Rows[0]["vipid"].ToString() == "")
                            {
                                //Session["vipid"] = "";
                                //Session["openid"] = "";
                                Session.Clear();
                                clsWXHelper.ShowError("请重新打开本功能......");
                                return;
                            }
                            else
                            {
                                AddHT(VI, "vid", dt.Rows[0]["vipid"].ToString());
                                AddHT(VI, "wxnick", dt.Rows[0]["wxnick"].ToString());
                                AddHT(VI, "xb", dt.Rows[0]["xb"].ToString());
                                AddHT(VI, "wxcity", dt.Rows[0]["wxcity"].ToString());
                                AddHT(VI, "wxpro", dt.Rows[0]["wxprovince"].ToString());
                                AddHT(VI, "cname", dt.Rows[0]["cname"].ToString());
                                string headimg = dt.Rows[0]["wxheadimgurl"].ToString().Replace("\\", "");
                                if (clsWXHelper.IsWxFaceImg(headimg))
                                {
                                    //是微信头像
                                    AddHT(VI, "headimg_bg", headimg);
                                    headimg = clsWXHelper.GetMiniFace(headimg);
                                }
                                else
                                {
                                    headimg = clsConfig.GetConfigValue("VIP_WebPath") + headimg;
                                    AddHT(VI, "headimg_bg", headimg.Replace("my/", ""));
                                }
                                AddHT(VI, "headimg", headimg);
                                AddHT(VI, "userpoints", GetUserPoints(_vipID));
                                AddHT(VI, "viplb", dt.Rows[0]["viplb"].ToString());

                                if (dt2.Rows.Count > 0)
                                {
                                    AddHT(VI, "charmvalue", dt2.Rows[0]["charmvalue"].ToString());
                                    AddHT(VI, "titlename", dt2.Rows[0]["titlename"].ToString() == "" ? "风流才子" : dt2.Rows[0]["titlename"].ToString());
                                }
                                else
                                {
                                    AddHT(VI, "charmvalue", "0");
                                    AddHT(VI, "titlename", "风流才子");
                                }
                            }
                            dt.Clear(); dt.Dispose();
                            dt2.Clear(); dt2.Dispose();
                        }
                    }
                    else
                        clsWXHelper.ShowError("查询微信用户信息时出错！ " + errinfo);
                }
            }
        }
    }

    public string GetUserPoints(string vipid)
    {
        //将积分存储起来，这样没必要重新计算了。         
        //if (Convert.ToString(Session["userpoint"]) != "")
        //挂钩积分商城后，积分必须实时计算否则不准确 20170316 by liqf
        if(1==2)
        {            
            return Convert.ToString(Session["userpoint"]);
        }
        else
        {
            using (LiLanzDALForXLM dal10 = new LiLanzDALForXLM(DBConStr))
            {
                List<SqlParameter> paras = new List<SqlParameter>();
                string str_sql0 = @"DECLARE @kh VARCHAR(30),
				                            @khid INT,
				                            @DBName VARCHAR(30),
				                            @vipbs VARCHAR(6)

                            SELECT @kh = '',@khid=0,@vipbs = ''

                            SELECT TOP 1 @kh = kh,@khid = khid FROM yx_t_vipkh WHERE ID = @vipid
                            IF (@khid > 0)	SELECT TOP 1 @DBName=DBName,@vipbs = vipbs FROM yx_t_khb WHERE khid = @khid

                            SELECT @kh kh,@DBName DBName,@vipbs vipbs";

                paras.Add(new SqlParameter("@vipid", vipid));
                DataTable dt = null;
                string errinfo = dal10.ExecuteQuerySecurity(str_sql0, paras, out dt);
                if (errinfo != "")
                {
                    clsLocalLoger.WriteError(string.Format("获取VIP（ID:{0}）的基础信息失败！错误：{1}", vipid, errinfo));
                    return "暂不可查";
                }
                else
                {
                    string kh = Convert.ToString(dt.Rows[0]["kh"]);
                    string DBName = Convert.ToString(dt.Rows[0]["DBName"]).ToUpper();
                    string vipbs = Convert.ToString(dt.Rows[0]["vipbs"]);

                    dt.Clear(); dt.Dispose();

                    string str_sql;
                    Object scalar;
                    if (vipbs == "new")     //如果是新积分体系，则走新积分体系的查询（这个逻辑尚未测试到）
                    {
                        DBName = DBConStr;
                        str_sql = @"SELECT TOP 1 isnull(points,0) points from yx_v_VipPoints where vipid=@vipid";
                        paras.Clear();
                        paras.Add(new SqlParameter("@vipid", vipid));
                    }
                    else
                    {
                        if (DBName == "FXDB") DBName = clsConfig.GetConfigValue("FXConStr");
                        else DBName = DBName = clsConfig.GetConfigValue("ERPConStr");

                        str_sql = @" SELECT  SUM(jfs) points
                                            FROM    ( SELECT    -SUM(CASE WHEN ISNULL(a.jfbs, 0) = 0
                                                                          THEN CASE WHEN ISNULL(a.xfjf, 0) = 0
                                                                                    THEN a.Yskje * b.Kc
                                                                                    ELSE a.xfjf * b.Kc
                                                                               END
                                                                          ELSE 0
                                                                     END) AS jfs
                                                      FROM      Zmd_T_Lsdjb a
                                                                INNER JOIN T_Djlb b ON a.Djlb = b.Dm
                                                                INNER JOIN yx_t_khb kh ON a.Vip = @kh
                                                                                          AND a.khid = kh.khid
                                                                                          AND a.Rq >= kh.jfqyrq
                                                      WHERE     a.Djbs = 1
                                                                AND a.Djlb < 10
                                                      UNION ALL
                                                      SELECT    SUM(a.dhjfs)
                                                      FROM      zmd_t_xfjfdhb a
                                                                INNER JOIN yx_t_khb kh ON a.khid = kh.khid
                                                                                          AND a.rq >= kh.jfqyrq
                                                                                          AND a.kh = @kh
                                                      UNION ALL
                                                      SELECT    qcjf
                                                      FROM      YX_T_Vipkh
                                                      WHERE     id = @vipid  
                                                    ) a";
                        paras.Clear();
                        paras.Add(new SqlParameter("@kh", kh));
                        paras.Add(new SqlParameter("@vipid", vipid));
                    }

                    using (LiLanzDALForXLM dalDB = new LiLanzDALForXLM(DBName))
                    {
                        errinfo = dalDB.ExecuteQueryFastSecurity(str_sql, paras, out scalar);
                        if (errinfo == "")
                        {
                            string rt = Convert.ToString(scalar) == "" ? "0" : Convert.ToString(scalar);
                            Session["userpoint"] = rt;
                            return rt;
                        }
                        else
                        {
                            clsLocalLoger.WriteError(string.Format("获取VIP（ID:{0}）的积分失败！错误：{1}", vipid, errinfo));
                            return "暂不可查";
                        }
                    }
                }
            }
        }
    }

    public void AddHT(Hashtable ht, string key, string value)
    {
        if (ht.ContainsKey(key))
            ht.Remove(key);
        ht.Add(key, value);
    }

    public void UpdateLoginTime(string vipid)
    {
        using (LiLanzDALForXLM dal = new LiLanzDALForXLM(ChatProConnStr))
        {
            string str_sql = "update wx_t_vipinfo set wxLoginTime=getdate() where vipid=@vipid;";
            List<SqlParameter> paras = new List<SqlParameter>();
            paras.Add(new SqlParameter("@vipid", vipid));
            dal.ExecuteNonQuerySecurity(str_sql, paras);
        }
    }
</script>
<html>
<head runat="server">
    <meta charset="utf-8" />
    <meta name="viewport" content="width=device-width,initial-scale=1,user-scalable=0,maximum-scale=1" />
    <meta name="format-detection" content="telephone=no" />
    <meta name="apple-mobile-web-app-capable" content="yes" />
    <meta name="apple-mobile-web-app-status-bar-style" content="black" />
    <title>利郎会员中心</title>
    <link type="text/css" rel="stylesheet" href="../../res/css/LeePageSlider.css" />
    <link type="text/css" rel="stylesheet" href="../../res/css/font-awesome.min.css" />
    <style type="text/css">
        body {
            background-color: #f3f3f3;
        }

        .top_view {
            width: 100%;
            height: 250px;
            position: relative;
            background-image: url(../../res/img/vipweixin/usercenterbg.jpg);
            color: #fff;
            text-align: center;
            padding-top: 15px;
        }

        .myorder {
            height: 44px;
            background-color: #fff;
            border-bottom: 1px solid #eee;
            position: relative;
        }

        .bottom_nav {
            position: absolute;
            top: 294px;
            left: 0;
            width: 100%;
            bottom: 24px;
            overflow-x: hidden;
            overflow-y: auto;
            -webkit-overflow-scrolling: touch;
            padding: 0 2vw 20px 2vw;
        }

        .back-img {
            background-repeat: no-repeat;
            background-position: center center;
            background-size: cover;
        }

        .top_info {
            position: absolute;
            left: 0;
            bottom: 0;
            width: 100%;
            height: 55px;
            background-color: rgba(0,0,0,.4);
        }

        .headimg {
            width: 100px;
            height: 100px;
            margin: 0 auto;
            border-radius: 50%;
            border: 4px solid #f0f0f0;
        }

        .username {
            margin-top: 5px;
            font-size: 20px;
            font-weight: bold;
            line-height: 40px;
        }

        .location {
            line-height: 30px;
        }

        .icon_location {
            height: 24px;
            vertical-align: middle;
            margin-right: -5px;
            margin-top: -3px;
        }

        .icon_config {
            position: absolute;
            top: 10px;
            right: 15px;
            width: 30px;
        }

        .top_info ul {
            display: flex;
            justify-content: space-around;
            align-items: center;
            width: 100%;
            height: 100%;
            line-height: 1;
        }

            .top_info ul li {
                width: 33.3%;
            }

                .top_info ul li .title {
                    color: #918287;
                    font-size: 16px;
                    margin-bottom: 5px;
                }

        .value.num {
            font-size: 15px;
            font-weight: 200;
            white-space: nowrap;
            overflow: hidden;
            text-overflow: ellipsis;
        }

        .icon_order {
            width: 30px;
            height: 30px;
            margin-top: 7px;
            margin-left: 10px;
            vertical-align: middle;
        }

        .myorder > span {
            color: #555;
            font-size: 16px;
            position: absolute;
            left: 45px;
            top: 0;
            height: 100%;
            line-height: 43px;
        }

        .lookmore {
            position: absolute;
            top: 0;
            height: 100%;
            right: 10px;
            color: #999;
            line-height: 43px;
        }

            .lookmore .fa {
                margin-left: 5px;
                font-size: 18px;
            }

        .nav_item {
            width: 20vw;
            float: left;
            text-align: center;
            margin-top: 20px;
        }

            .nav_item > a {
                color: #545454;
            }

            .nav_item:nth-child(4n-2) {
                margin-left: 5.33vw;
            }

            .nav_item:nth-child(4n-1) {
                margin-left: 5.33vw;
                margin-right: 5.33vw;
            }

        .menu_icon {
            width: 10vw;
            height: 10vw;
            margin: 0 auto;
            background-image: url(../../res/img/vipweixin/index_icon2.png);
        }

        .icon_sign {
            position: absolute;
            top: 100px;
            left: 50%;
            width: 40px;
            height: 40px;
            background-color: rgba(0,0,0,.6);
            border-radius: 50%;
            background-size: 80%;
            margin-left: 55px;
        }

        .copyright {
            font-size: 12px;
            color: #999;
            text-align: center;
            line-height: 24px;
            position: fixed;
            left: 0;
            width: 100%;
            bottom: 0;
        }

        /*points animated style*/
        .animated {
            -webkit-animation-duration: 1.5s;
            animation-duration: 1.5s;
            -webkit-animation-fill-mode: both;
            animation-fill-mode: both;
        }
        .points_mask {
            color: #fff;
            position: absolute;
            top: 0;
            bottom: 0;
            left: 0;
            right: 0;
            z-index: 1001;
            font-size: 1.1em;
            text-align: center;
            background-color: rgba(0,0,0,0.5);
            display: none;            
        }

        .points {
            font-size: 3.2em;
            font-weight: bold;
            color: #fff;
            text-shadow: 0px 0px 2px #ccc;
            padding: 20px;
            width: 100px;
            height: 100px;
            position: absolute;
            top: 50%;
            left: 50%;
            margin-top: -50px;
            margin-left: -50px;            
        }

        @keyframes fadeOutUp {
            0% {
                opacity: 1;
            }

            100% {
                opacity: 0;
                -webkit-transform: translate3d(0,-100%,0);
                transform: translate3d(0,-100%,0);
            }
        }

        @-webkit-keyframes fadeOutUp {
            0% {
                opacity: 1;
            }

            100% {
                opacity: 0;
                -webkit-transform: translate3d(0,-100%,0);
                transform: translate3d(0,-100%,0);
            }
        }

        .fadeOutUp {
            -webkit-animation-name: fadeOutUp;
            animation-name: fadeOutUp;
        }

        .menu_coupon_icon {
            width: 10vw;
            height: 10vw;
            margin: 0 auto;
            background-image: url(../../res/img/vipweixin/f-usecard.png);
        }
    </style>
	<script>
	    var _hmt = _hmt || [];
	    (function () {
	        var hm = document.createElement("script");
	        hm.src = "https://hm.baidu.com/hm.js?f274c2a4c37455fe3bba3b7477d74d26";
	        var s = document.getElementsByTagName("script")[0];
	        s.parentNode.insertBefore(hm, s);
	    })();
	</script>
</head>
<body>
    <!--顶部视窗-->
    <div class="top_view">
        <img src="../../res/img/vipweixin/config.png" class="icon_config" onclick="javascript:window.location.href='MyInfos.aspx'" />
        <div class="back-img headimg" style="background-image: url(<%=Convert.ToString(VI["headimg_bg"])%>)"></div>
        <div class="username"><%=Convert.ToString(VI["wxnick"]) %></div>
        <div class="location">
            <img src="../../res/img/vipweixin/location.png" class="icon_location" />
            <span><%=VI["wxpro"].ToString()+" "+VI["wxcity"].ToString() %></span>
        </div>
        <div class="icon_sign back-img" style="background-image: url(../../res/img/vipweixin/icon_sign.png)" onclick="signPerDay();"></div>
        <div class="top_info">
            <ul class="floatfix">
                <li>
                    <p class="title"><%=Convert.ToString(VI["titlename"]) %></p>
                    <p class="value num"><%=Convert.ToString(VI["charmvalue"]) %></p>
                </li>
                <li>
                    <p class="title">会员积分</p>
                    <p class="value num"><%=Convert.ToString(VI["userpoints"]) %></p>
                </li>
                <li>
                    <p class="title">等级</p>
                    <p class="value"><%=Convert.ToString(VI["viplb"]) %></p>
                </li>
            </ul>
        </div>
    </div>
    <!--我的订单-->
    <div class="myorder" onclick="javascript:window.location.href='ConsumeQuery.aspx'">
        <img src="../../res/img/vipweixin/icon_order.png" class="icon_order" />
        <span>我的订单</span>
        <div class="lookmore">
            查看全部<i class="fa fa-angle-right"></i>
        </div>
    </div>
    <!--底部导航按钮-->
    <div class="bottom_nav">
        <ul class="floatfix">
            <li class="nav_item">
                <a href="VIPCode.aspx">
                    <div class="menu_icon back-img" style="background-position: 0 0;"></div>
                    <p class="menu_text">电子名片</p>
                </a>
            </li>
<%--            <li class="nav_item">
                <a href="MyGuider.aspx?uid=<%=Convert.ToString(VI["vid"]) %>">
                    <div class="menu_icon back-img" style="background-position: 0 -10vw;"></div>
                    <p class="menu_text">我的专属</p>
                </a>
            </li>--%>
            <li class="nav_item">
                <a href="QualityFeedback.aspx">
                    <div class="menu_icon back-img" style="background-position: 0 -20vw;"></div>
                    <p class="menu_text">顾客心声</p>
                </a>
            </li>
            <li class="nav_item">
                <a href="PointRecords.aspx">
                    <div class="menu_icon back-img" style="background-position: 0 -30vw;"></div>
                    <p class="menu_text">利豆查询</p>
                </a>
            </li>
            <li class="nav_item">
                <a href="ConsumeQuery.aspx">
                    <div class="menu_icon back-img" style="background-position: 0 -40vw;"></div>
                    <p class="menu_text">消费查询</p>
                </a>
            </li>
            <li class="nav_item">
                <a href="NewPointRecords.aspx">
                    <div class="menu_icon back-img" style="background-position: 0 -50vw;"></div>
                    <p class="menu_text">积分记录</p>
                </a>
            </li>
            <li class="nav_item">
                <a href="goodslist.aspx?showType=2">
                    <div class="menu_icon back-img" style="background-position: 0 -60vw;"></div>
                    <p class="menu_text">商品扫描</p>
                </a>
            </li>
            <li class="nav_item">
                <a href="http://tm.lilanz.com/lspx/redeem.html">
                    <div class="menu_icon back-img" style="background-position: 0 -70vw;"></div>
                    <p class="menu_text">积分兑换</p>
                </a>
            </li>
            <li class="nav_item">
                <a href="storelists.aspx">
                    <div class="menu_icon back-img" style="background-position: 0 -80vw;"></div>
                    <p class="menu_text">附近门店</p>
                </a>
            </li>
            <li class="nav_item">
                <a href="UseCard.aspx">
                    <div class="menu_coupon_icon back-img"></div>
                    <p class="menu_text">我的卡券</p>
                </a>
            </li>
        </ul>
    </div>
    <p class="copyright">&copy;2017 利郎（中国）有限公司</p>
    <!--签到积分动画-->
    <section class="points_mask">
        <div class="points animated">+5</div>
    </section>
    <script type="text/javascript" src="../../res/js/jquery.js"></script>
    <script type="text/javascript" src="../../res/js/fastclick.min.js"></script>
    <script type="text/ecmascript">
        var vid = "<%=VI["vid"].ToString()%>";

        $(document).ready(function () {
            var points = "<%=Convert.ToString(VI["userpoints"])%>";
            FastClick.attach(document.body);
            if (isNaN(points)) {
                $(".top_info li:nth-child(2) .value").removeClass("num");
            }

            BindEvents();

        });

        window.onload=function (){
         if( "<%=Convert.ToString(VI["cname"])%>" == ""){
                setTimeout($(".icon_config").click(),10);
            }
        }

        function BindEvents() {
            $(".points").on("webkitAnimationEnd", function () {
                $(".points").removeClass("fadeOutUp")
                $(".points_mask").hide();
                alert("今日签到成功!");
                setTimeout(function () {
                    window.location.href = "";//刷新页面
                }, 500);
            });
        }

        //每日签到
        var isProcessing = false;
        function signPerDay() {
            if (isProcessing)
                return;
            else {
                isProcessing = true;
                $.ajax({
                    url: "http://tm.lilanz.com/WebBLL/FWHUserCenterCore.aspx?ctrl=SignToday",
                    type: "POST",
                    dataType: "text",
                    data: { vipid: vid },
                    timeout: 5*1000,
                    error: function (XMLHttpRequest, textStatus, errorThrown) {                        
                        alert("您的网络好像出了点问题,请稍后重试...");
                        isProcessing = false;
                    },
                    success: function (result) {
                        if (result.indexOf("Error:") > -1)
                            alert(result.replace("Error:", ""));
                        else if (result.indexOf("Warn:") > -1)
                            alert(result.replace("Warn:", ""));
                        else if (result.indexOf("Successed") > -1) {                            
                            $(".points_mask").show();
                            $(".points").addClass("fadeOutUp");
                        }

                        isProcessing = false;
                    }
                });
            }
        }
    </script>
</body>
</html>
