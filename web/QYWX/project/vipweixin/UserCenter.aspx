<%@ Page Language="C#" Debug="true" %>

<%@ Import Namespace="nrWebClass" %>
<%@ Import Namespace="System.Data" %>
<%@ Import Namespace="System.Data.SqlClient" %>
<%@ Import Namespace="System.Collections.Generic" %>
<!DOCTYPE html>
<script runat="server">
    private String ConfigKeyValue = "5"; //利郎男装
    private string ChatProConnStr = System.Configuration.ConfigurationManager.ConnectionStrings["Conn"].ConnectionString;
    private string DBConStr = System.Configuration.ConfigurationManager.ConnectionStrings["Conn_1"].ConnectionString;     
    public Hashtable VI = new Hashtable();

    protected void Page_Load(object sender, EventArgs e)
    {
        //clsLocalLoger.WriteInfo(string.Concat("1- ", DateTime.Now.Second , "." , DateTime.Now.Millisecond));        
        //Session["openid"] = "oarMEt8bqjmZIAhImSXBAg0G7F0I";
        //Session["vipid"] = "3056806";
        if (clsWXHelper.CheckUserAuth(ConfigKeyValue, "vipid"))
        {
            string _vipID = Convert.ToString(Session["vipid"]);

            if (_vipID == "" || _vipID == "0" || _vipID == null)
            {
                Response.Redirect("JoinUS.aspx");
                return;
            }
            else UpdateLoginTime(_vipID);

            //生成访问日志
            clsWXHelper.WriteLog(string.Format("openid：{0} ，vipid：{1} 。访问功能页[{2}]", Convert.ToString(Session["openid"]), Convert.ToString(Session["vipid"])
                            , "用户中心"));

            //clsSharedHelper.WriteInfo(Session["openid"].ToString());            
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
                                            ISNULL(vl.mc, '--') viplb
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
                            clsWXHelper.ShowError("对不起，您还未关注利郎男装公众号。");
                        else
                        {
                            if (dt.Rows[0]["vipid"].ToString() == "0" || dt.Rows[0]["vipid"].ToString() == "")
                                Response.Redirect("JoinUS.aspx");
                            else
                            { 
                                AddHT(VI, "vid", dt.Rows[0]["vipid"].ToString());
                                AddHT(VI, "wxnick", dt.Rows[0]["wxnick"].ToString());
                                AddHT(VI, "xb", dt.Rows[0]["xb"].ToString());
                                AddHT(VI, "wxcity", dt.Rows[0]["wxcity"].ToString());
                                AddHT(VI, "wxpro", dt.Rows[0]["wxprovince"].ToString());
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
                                //clsSharedHelper.WriteInfo(headimg.Replace("my/", ""));
                                AddHT(VI, "headimg", headimg);
                                AddHT(VI, "userpoints", GetUserPoints(_vipID));
                                AddHT(VI, "viplb", dt.Rows[0]["viplb"].ToString());

                                if (dt2.Rows.Count > 0)
                                {
                                    AddHT(VI, "charmvalue", dt2.Rows[0]["charmvalue"].ToString());
                                    AddHT(VI, "titlename", dt2.Rows[0]["titlename"].ToString() == "" ? "风流才子" : dt.Rows[0]["titlename"].ToString());
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

    public string GetUserPoints(string vipid) {                
        //将积分存储起来，这样没必要重新计算了。         
        if (Convert.ToString(Session["userpoint"]) != "")
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
        #page-index {
            max-width: 600px;
            position: relative;
            margin: 0 auto;
            height: 100%;
        }

        .page {
            padding: 0;
        }

        .page-head {
            height: 210px;
            background: linear-gradient(90deg,#272b2e 0%,#555 100%);
            background: -webkit-linear-gradient(90deg,#272b2e 0%,#555 100%);
            border-bottom: 1px solid #444;
            box-sizing: border-box;
            position: relative;
            background-color: rgba(0,0,0,0.2);
            overflow: hidden;
        }

        .blurbg {
            position: absolute;
        }

        .navs {
            position: absolute;
            top: 210px;
            left: 0;
            right: 0;
            bottom: 26px;
            background: #272b2e;
            overflow-x: hidden;
            overflow-y: auto;
            -webkit-overflow-scrolling: touch;
            overflow-scrolling: touch;
            z-index: 2000;
        }

        .headimg {
            width: 70px;
            height: 70px;
            border-radius: 4px;
            overflow: hidden;
            margin: 0 auto;
            box-shadow: 0 0 3px #333;
            background-size: cover;
            background-position: 50% 50%;
            background-repeat: no-repeat;
            position: relative;
        }

            .headimg:before {
                content: '';
                background: rgba(255, 255, 255, 0.3);
                height: 100%;
                width: 46px;
                position: absolute;
                top: 0;
                transform: translate(-220%,0);
                -webkit-transform: translate(-220%,0);
                animation: move 2.5s cubic-bezier(0.42, 0, 0.58, 1) infinite;
                -webkit-animation: move 2.5s cubic-bezier(0.42, 0, 0.58, 1) infinite;
            }

        @-webkit-keyframes move {
            0% {
                transform: skew(-45deg) translate(-230%,0);
                -webkit-transform: skew(-45deg) translate(-230%,0);
            }

            20% {
                transform: skew(-45deg) translate(230%,0);
                -webkit-transform: skew(-45deg) translate(230%,0);
            }

            100% {
                transform: skew(-45deg) translate(220%,0);
                -webkit-transform: skew(-45deg) translate(220%,0);
            }
        }

        .headimg img {
            width: 100%;
            height: 100%;
        }

        .username {
            font-size: 1.4em;
            color: #fff;
            font-weight: bold;
            text-align: center;
            margin: 8px 0 2px 0;
            text-shadow: 1px 1px 1px #999;
            letter-spacing: 1px;
        }

        .area {
            color: #fff;
            text-align: center;
            text-shadow: 0 0 1px #ccc;
            font-size: 1em;
            text-shadow: 1px 1px 1px #999;
        }

            .area img {
                width: 12px;
                height: 12px;
            }

        .iconcircle {
            width: 34px;
            height: 34px;
            padding: 7px;
            border-radius: 5px;
            background: rgba(0,0,0,0.2);
            position: absolute;
            top: 50%;
            left: 66%;
            margin-top: -40px;
        }

            .iconcircle img {
                width: 20px;
                height: 20px;
            }

        .left {
            left: initial;
            right: 66%;
        }

        .iconcircle:hover {
            background: rgba(0,0,0,0.8);
        }

        .top-navs {
            position: absolute;
            left: 0;
            width: 100%;
            bottom: 0;
            height: 50px;
            background-color: rgba(0,0,0,0.4);
        }

        .tnavul {
            list-style: none;
            color: #f0f0f0;
        }

            .tnavul li {
                float: left;
                width: 33.33%;
                box-sizing: border-box;
                text-align: center;
                padding: 5px 0;
                line-height: 20px;
                position: relative;
            }

                .tnavul li > p {
                    border-right: 1px solid rgba(255,255,255,.2);
                    vertical-align:bottom;
                }

        .vipval {
            font-size: 1.1em;
        }

        .num {
            font-size: 1.2em;
        }
        .vipval.num img {
            width:20px;
            height:20px;
            margin-right:5px; 
            vertical-align:bottom;           
        }
        .tnavul li:last-child p {
            border-right: none;
        }

        .navul {
            list-style: none;
            color: #ccc;
        }

            .navul li {
                width: 50%;
                float: left;
                position: relative;
                height: 80px;
                text-align: center;
                border-right: 1px solid #333;
                border-bottom: 1px solid #333;
                box-sizing: border-box;
                background-color: #272b2e;
            }

                .navul li:nth-child(2n) {
                    border-right: none;
                }

                .navul li:hover {
                    background-color: rgba(0,0,0,0.4);
                }

        .icon {
            width: 40px;
            height: 40px;
            float: left;
        }

        .icontext {
            height: 40px;
            line-height: 40px;
            float: left;
            padding: 0 5px;
            font-size: 1.1em;
        }

        .item {
            position: relative;
            top: 20px;
            display: inline-block;
        }

        .copy {
            color: #aaa;
            position: fixed;
            bottom: 0;
            left: 0;
            width: 100%;
            text-align: center;
            font-size: 0.9em;
            height: 27px;
            line-height: 30px;
            z-index: 100;
            background-color: #272b2e;
        }

        /*loader style*/
        .mask, .mask2 {
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

        .mask2 {
            z-index: 2000;
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

        .loader {
            background-color: rgba(39, 43, 46, 0.9);
            padding: 15px;
            border-radius: 5px;
            max-height: 200px;
            overflow: hidden;
        }

        #loadtext {
            margin-top: 10px;
            font-weight: bold;
            letter-spacing: 1px;
        }
        /*animation css*/
        .animated {
            -webkit-animation-duration: 1.5s;
            animation-duration: 1.5s;
            -webkit-animation-fill-mode: both;
            animation-fill-mode: both;
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
        /*guide-layer*/
        .guide-layer {
            position: absolute;
            top: 0;
            left: 0;
            width: 100%;
            height: 100%;
            background-color: #131517;
            z-index: 2002;
            overflow-x: hidden;
            overflow-y: auto;
            -webkit-overflow-scrolling: touch;
            overflow-scrolling: touch;
            display: none;
        }

            .guide-layer img {
                width: 100%;
                height: auto;
            }

        .countdown {
            position: fixed;
            bottom: 15px;
            left: 15px;
            font-size: 1.4em;
            font-weight: bold;
            color: #333;
            z-index: 2005;
            background: #ebebeb;
            border-radius: 4px;
            width: 50px;
            height: 50px;
            line-height: 50px;
            text-align: center;
        }
        /*利豆说明页*/
        #explain,#points-explain {
            background-color: #272b2e;
            color: #fff;
            display: none;
        }

        .content {
            max-width: 600px;
            margin: 0 auto;
            padding: 10px 15px;
            position: relative;
        }

            .content .question {
                font-size: 1.2em;
                font-weight: bold;
            }

                .content .question::first-letter {
                    font-size: 1.4em;
                    font-style: italic;
                    letter-spacing:2px;
                }

            .content .answer {
                font-size: 1.1em;
                line-height: 24px;
                margin-bottom: 10px;
            }

                .content .answer::first-letter {
                    font-size: 1.4em;
                    font-weight: bold;
                    font-style: italic;
                }

            .content .rights {
                color: #999;
                text-align: center;
                font-style: italic;
                margin-top: 20px;
            }

        #explain .close-btn,#points-explain .close-btn {
            position: fixed;
            top: 0;
            right: 0;
            font-size: 1.2em;
            z-index: 1005;
            padding:10px 15px;
        }

        .fa-question-circle {
            display: block;
            position: absolute;
            top: 0;
            right: 0;
            font-size: 1.3em;
            height: 50px;
            line-height: 50px;
            padding: 0 8px;
        }
    </style>
</head>
<body>
    <div class="guide-layer">
        <img class="center-translate" id="guide-pic" src="../../res/img/vipweixin/guidepic.jpg" alt="" />
        <div class="countdown" onclick="start()">进入</div>
    </div>
    <div id="main" class="wrap-page">
        <!--主页-->
        <section id="page-index" class="page">
            <div class="page-head">
                <div style="position: absolute; top: 0; left: 0; height: 100%; width: 100%; padding-top: 20px; z-index: 205;">
                    <div class="headimg"></div>
                    <p class="username"><%=VI["wxnick"].ToString() %></p>
                    <p class="area">- <%=VI["wxpro"].ToString()+" "+VI["wxcity"].ToString() %> -</p>
                    <div class="top-navs">
                        <ul class="tnavul">
                            <li>                                
                                <p class="vipval num"><img src="../../res/img/vipweixin/bean-icon.png" /><%=VI["charmvalue"].ToString() %></p>
                                <p><%=VI["titlename"].ToString() %></p>
                                <i class="fa fa-question-circle" onclick="javascript:$('#explain').fadeIn(500)"></i>
                            </li>
                            <li>
                                <p class="vipval num"><%=VI["userpoints"].ToString() %></p>
                                <p>总积分</p>
                                <%--<i class="fa fa-question-circle" onclick="javascript:$('#points-explain').fadeIn(500)"></i>--%>
                            </li>
                            <li>
                                <p class="vipval"><%=VI["viplb"].ToString() %></p>
                                <p>等 级</p>
                            </li>
                        </ul>
                    </div>
                    <div class="iconcircle left" onclick="signToday()">
                        <img class="edit" src="../../res/img/vipweixin/signicon.png" alt="" />
                    </div>
                    <div class="iconcircle" onclick="javascript:window.location.href='MyInfos.aspx'">
                        <img class="sign" src="../../res/img/vipweixin/editicon.png" alt="" />
                    </div>
                </div>
                <div class="blurbg" id="blurbg">
                </div>
            </div>
            <div class="navs floatfix">
                <ul class="navul">
                    <li onclick="Redirect('myvip')">
                        <div class="item floatfix">
                            <img class="icon" src="../../res/img/vipweixin/f-myvipcard.png" alt="" />
                            <span class="icontext">电子名片</span>
                        </div>
                    </li>
                    <li onclick="Redirect('wdzs')">
                        <div class="item floatfix">
                            <img class="icon" src="../../res/img/vipweixin/f-my.png" alt="" />
                            <span class="icontext">我的专属</span>
                        </div>
                    </li>
                    <li onclick="Redirect('tsjy')">
                        <div class="item floatfix">
                            <img class="icon" src="../../res/img/vipweixin/f-support.png" alt="" />
                            <span class="icontext">顾客心声</span>
                        </div>
                    </li>
                    <li onclick="Redirect('jfcx')">
                        <div class="item floatfix">
                            <img class="icon" src="../../res/img/vipweixin/f-points.png" alt="" />
                            <span class="icontext">利豆查询</span>
                        </div>
                    </li>
                    <li onclick="Redirect('xfcx')">
                        <div class="item floatfix">
                            <img class="icon" src="../../res/img/vipweixin/f-xfcx.png" alt="" />
                            <span class="icontext">消费查询</span>
                        </div>
                    </li>
                    <li onclick="Redirect('njfcx')">
                        <div class="item floatfix">
                            <img class="icon" src="../../res/img/vipweixin/f-newpoints.png" alt="" />
                            <span class="icontext">积分记录</span>
                        </div>
                    </li>
                    <li onclick="Redirect('scan')">
                        <div class="item floatfix">
                            <img class="icon" src="../../res/img/vipweixin/f-scan.png" alt="" />
                            <span class="icontext">商品扫描</span>
                        </div>
                    </li>
                    <li onclick="showGuide()">
                        <div class="item floatfix">
                            <img class="icon" src="../../res/img/vipweixin/f-help.png" alt="" />
                            <span class="icontext">新手指引</span>
                        </div>
                    </li>
                </ul>
            </div>
            <div class="copy">&copy; 2016 利郎（中国）有限公司</div>
        </section>
        <!--利豆说明页-->
        <section class="page" id="explain">            
            <div class="content">
                <div class="close-btn" onclick="javascript:$('#explain').fadeOut(250);"><i class="fa fa-2x fa-times-circle"></i></div>
                <p class="question">Q1：什么是利豆？</p>
                <p class="answer">A：利豆的全名是“利郎豆”，是利郎线上会员活动的所产生的积分统称为“利郎豆”。</p>
                <p class="question">Q2：利豆有什么用？</p>
                <p class="answer">A：利郎将陆续推出多个线上活动（利豆抽奖、利豆兑礼品、利豆游戏等），参与这些活动需要消耗一定的利豆。</p>
                <p class="question">Q3：如何获取利豆？</p>
                <p class="answer">A：通过每日签到获取利豆；分享指定帖子、参与线上活动、参与利郎不定时推出的线上游戏 都可能获取利豆。</p>
                <p class="question">Q4：利豆和利郎积分是一样的吗？</p>
                <p class="answer">A：利豆和利郎积分是不一样的。利豆来源于线上，通常用于线上活动；积分通常只来源于线下。</p>                
                <div class="rights">
                    关于利豆的最终解释权归我司所有
                </div>
            </div>
        </section>
        <!--新积分体系说明页-->
        <section class="page" id="points-explain">            
            <div class="content">
                <div class="close-btn" onclick="javascript:$('#points-explain').fadeOut(250);"><i class="fa fa-2x fa-times-circle"></i></div>
                <p class="question">Q1：什么是“利郎新积分”?</p>
                <p class="answer">A：A：利郎新积分与旧积分体系是完全不同的。最大的区别在于新积分可以在任意一家加入“新积分体系”的店铺中使用、累计；而旧积分体系只能在会员卡开卡所在门店及共享门店范围内进行积分兑换和累计。</p>
                <p class="question">Q2：为什么我微信上显示的积分数为零？ </p>
                <p class="answer">A：利郎男装微信会员中心所显示的积分是新积分体系的积分，如果您会员卡所属门店并未加入“新积分体系”，则您的积分是旧积分。请以当地门店的积分查询结果为准。</p>
                <p class="question">Q3：我的会员积分是新积分还是旧积分？</p>
                <p class="answer">A：请咨询您会员卡所属门店；如果是微信会员，请咨询您首次消费的门店或专属导购。</p>
                <p class="question">Q4：新积分有什么用？</p>
                <p class="answer">A：可以在全国任意一家加入“新积分体系”的利郎专卖店进行积分兑换。利郎男装后续推出的积分商城使用新积分进行在线礼品兑换。</p>                
                <p class="question">Q5：新积分如何获取？</p>
                <p class="answer">A：在全国任意一家加入“新积分体系”的利郎专卖店进行消费时，新积分将会自动到账。</p>
                <p class="question">Q6：为什么我的会员卡在门店消费时被告之卡号无效？</p>
                <p class="answer">A：1.请确认您提供的会员卡号是否正确；2.请注意如果您会员卡所属门店是否已经加入“新积分体系”，已经加入“新积分体系”的会员卡不可在未加入“新积分体系”的门店中消费；反之，未加入“新积分体系”的会员卡也无法在已加入“新积分体系”的门店中消费。</p>
                <div class="rights">
                    关于利郎新积分的最终解释权归我司所有
                </div>
            </div>
        </section>
    </div>
    <!--加载提示层-->
    <section class="mask">
        <div class="loader center-translate">
            <div style="font-size: 1.2em;">
                <i class="fa fa-2x fa-spinner fa-pulse"></i>
            </div>
            <p id="loadtext">正在加载...</p>
        </div>
    </section>
    <section class="mask2">
        <div class="points animated">+5</div>
    </section>
    <script type="text/javascript" src="../../res/js/jquery.js"></script>
    <script type="text/javascript" src="../../res/js/StoreSaler/fastclick.min.js"></script>
    <script type="text/javascript" src="../../res/js/vipweixin/background-blur.min.js"></script>
    <script type="text/javascript" src="../../res/js/LeeJSUtils.min.js"></script>
    <script type="text/javascript">
        var vid = "<%=VI["vid"].ToString()%>";
        var userhead = "url(<%=VI["headimg"].ToString() %>)";
        var userhead_bg = "<%=VI["headimg_bg"].ToString() %>";

        $(function () {
            if (window.localStorage) {
                //支持localStorage
                //window.localStorage.clear();
                var ir = localStorage["IsRead"];
                if (ir != "1") {
                    $(".guide-layer").show();
                    var gimg = new Image();
                    gimg.src = $("#guide-pic").attr("src");
                }
            }

            LeeJSUtils.stopOutOfPage(".page-head", false);
            LeeJSUtils.stopOutOfPage("#explain", true);
            LeeJSUtils.stopOutOfPage(".navs", true);
        });

        function start() {
            localStorage["IsRead"] = "1";
            $(".guide-layer").fadeOut(500);
        }

        function showGuide() {
            $(".guide-layer").fadeIn(500);
        }

        //链接跳转
        function Redirect(type) {
            switch (type) {
                case "myvip":
                    window.location.href = "VIPCode.aspx";
                    break;
                case "wdzs":
                    window.location.href = "MyGuider.aspx?uid=" + vid;
                    break;
                case "tsjy":
                    window.location.href = "QualityFeedback.aspx";
                    break;
                case "jfcx":
                    window.location.href = "PointRecords.aspx";
                    break;
                case "xfcx":
                    window.location.href = "ConsumeQuery.aspx";
                    break;
                case "scan":
                    window.location.href = "goodslist.aspx?showType=2";
                    break;
                case "njfcx":
                    window.location.href = "NewPointRecords.aspx";
                    break;
                default:
                    showLoader("thunder", "即将推出,敬请期待!");
            }
        }
    </script>
    <script type="text/javascript" src="../../res/js/vipweixin/usercenter-main.min.js"></script>
</body>
</html>

