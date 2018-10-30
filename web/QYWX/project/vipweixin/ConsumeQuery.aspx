<%@ Page Language="C#" %>
<%@ Import Namespace="nrWebClass" %>
<%@ Import Namespace="System.Data" %>
<%@ Import Namespace="System.Data.SqlClient" %>
<%@ Import Namespace="System.Collections.Generic" %>

<!DOCTYPE html>
<script runat="server">
    private String ConfigKeyValue = clsConfig.GetConfigValue("CurrentConfigKey"); //取配置BLL.config
    private String ChatProConnStr = System.Configuration.ConfigurationManager.ConnectionStrings["Conn"].ConnectionString;
    public String vipkh = "",vipid="",openID="";
    protected void Page_Load(object sender, EventArgs e)
    {
        if (clsWXHelper.CheckUserAuth(ConfigKeyValue, "openid"))
        {
            string openID = Convert.ToString(Session["openid"]);
            using (LiLanzDALForXLM dal62 = new LiLanzDALForXLM(ChatProConnStr))
            {
                string str_sql = @"select isnull(a.vipid,0) vipid,b.kh 
                                    from wx_t_vipbinging a
                                    inner join yx_t_vipkh b on a.vipid=b.id
                                    where a.wxopenid=@openid";
                List<SqlParameter> paras = new List<SqlParameter>();
                paras.Add(new SqlParameter("@openid", openID));
                DataTable dt = null;
                string errinfo = dal62.ExecuteQuerySecurity(str_sql, paras, out dt);
                if (errinfo == "")
                {
                    if (dt.Rows.Count == 0)
                    {
                        Response.Redirect("JoinUS.aspx");
                        return;
                    }
                    else
                    {
                        vipid = Convert.ToString(dt.Rows[0]["vipid"]);
                        vipkh = Convert.ToString(dt.Rows[0]["kh"]);
                    }
                }
            }
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
        body {
            font-size: 16px;
            background-color: #eee;
            color: #333;
            font-family: "San Francisco",Helvitica Neue,Helvitica,Arial,sans-serif;
        }

        .header {
            height: 50px;
            line-height: 50px;
            width: 100%;
            text-align: center;
            box-shadow: 0 1px .5px #eceef1;
            -webkit-box-shadow: 0 1px .5px #eceef1;
            font-size: 1.1em;
        }

        .page {
            top: 50px;
            bottom: 25px;
            padding: 0;
            background-color: #f7f7f7;
        }

        .fa-angle-left {
            font-size: 1.4em;
            position: absolute;
            top: 0;
            bottom: 0;
            left: 0;
            padding: 0 18px;
            line-height: 50px;
        }

            .fa-angle-left:hover {
                background-color: rgba(0,0,0,.1);
            }

        .footer {
            height: 25px;
            line-height: 25px;
            font-size: 0.8em;
            background-color: #f7f7f7;
        }

        .consumelist .item {
            background-color: #fff;
            margin-top: 6px;            
            box-shadow: 0 1px .5px #eceef1;
            -webkit-box-shadow: 0 1px .5px #eceef1; 
            position:relative;           
        }
        .item .infos {
            padding:5px 10px;
            font-size:1em;            
        }

        .header .line {
            width:100%;
            height:4px;
            background-image:url(../../res/img/vipweixin/top-line.png);
            background-size:cover;
            position:absolute;
            top:0;
            left:0;
        }
        
        .infos .order {
            font-size:0.9em;
            border-bottom:1px dashed #f2f2f2;
            padding-bottom:2px;                
        }
        .infos .mdmc {
            margin-top:4px;
        }
        .infos .mdmc,.infos .time {
            line-height:26px;
        }
        .infos .time {
            border-bottom:1px dashed #f2f2f2;
            padding-bottom:3px;
        }
        .infos .counts {
            font-size:1.1em;
            color:#d9534f;
            text-align:right;
            font-weight:bold;
            margin-right:5px;
            margin-top:4px;
        }

        .item .fa-angle-right {
            position: absolute;
            top: 50%;
            right:15px;
            transform: translate(0,-50%);
            -webkit-transform: translate(0,-50%);
            color:#b4b2b2;
            font-size:1.5em;
        }

        /*明细页样式*/
        .detailul {
            background-color:#fff;
            margin:8px 0;
        }
            .detailul .ditem {
                padding:10px;
                height:110px;
                border-bottom:1px dashed #f1f1f1;
                position:relative;
            }
        .clothesimg {
            width:90px;
            height:90px;
            position:absolute;
            top:10px;
            left:10px;
        }
        .backimg {
            background-size: cover;
            background-position: 50% 50%;
            background-repeat: no-repeat;
        }
        .ditem .clothes-info {
            padding-left:100px; 
            height:80px;           
        }
        .clothes-info p {
            font-size:0.9em;
            color:#575d6a;
        }
        .clothes-info .title {
            font-size:0.95em;
            font-weight:600;   
            height:46px;  
            line-height:21px;       
        }
        .clothes-info .price {
            font-size:1em;
            font-weight:bold;
            line-height:34px;
            color:#d9534f;                                     
        }
        /*mask style*/
        .mask {
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
            display:none;
        }

        .loader {
            background-color: rgba(39, 43, 46, 0.9);
            padding:10px 15px;
            border-radius: 5px;
            max-height: 200px;
            overflow: hidden;
        }

        #loadtext {
            margin-top: 10px;
            font-weight: bold;
            font-size: 0.9em;
        }
        .detailul .sums {
            height:46px;
            line-height:46px;
            text-align:center;
            font-size:0.9em;
        }
        #price_all {
            font-size:1.3em;
            color:#d9534f;
            font-weight:bold;
        }
        #noresults {
            color:#666;
            font-size:0.95em;
            display:none;
            white-space:nowrap;
        }
    </style>
</head>
<body>
    <div class="header"><div class="line"></div><i class="fa fa-angle-left" onClick="returnSite()"></i>消费查询</div>
    <div class="wrap-page">
        <div class="page page-not-header-footer" id="main-list">
            <ul class="consumelist">
                <!--<li class="item">                    
                    <div class="infos">
                        <p class="order">订单号：2016041210001</p>
                        <p class="mdmc"><strong>门店：</strong>晋江第一分公司</p>
                        <p class="time"><strong>时间：</strong>2016-04-12 12:20:20</p>
                        <div class="counts">￥2845</div>
                    </div>
                    <i class="fa fa-angle-right"></i>
                </li>
                <li class="item">                    
                    <div class="infos">
                        <p class="order">订单号：10001</p>
                        <p class="mdmc"><strong>门店：</strong>总部展厅</p>
                        <p class="time"><strong>时间：</strong>2016-04-12 12:20:20</p>
                        <div class="counts">￥2845</div>
                        <i class="fa fa-angle-right"></i>
                    </div>
                </li>-->
            </ul>
            <div id="noresults" class="center-translate">对不起，您暂时无消费记录！</div>
        </div>
        <!--明细页-->
        <div class="page page-not-header-footer page-right" id="detail">
            <ul class="detailul">
                <!--<li class="ditem">
                    <div class="clothesimg backimg" style="background-image:url(../../res/img/storesaler/1.png);"></div>
                    <div class="clothes-info">
                        <p class="title">衣服标题衣服标题衣服标题衣服标题衣服标题衣服标题</p>
                        <p class="cmys"><p class="cmys"><strong>尺码：</strong>L&nbsp;&nbsp;&nbsp;<strong>颜色：</strong>黑色</p>
                        <p class="price">￥1245.00</p>
                    </div>
                </li>
                <li class="sums">
                    您本次您共消费：<span id="price_all">￥2520.00</span>
                </li>-->
            </ul>            
        </div>
    </div>
    <div class="footer">&copy;2016 利郎中国有限公司</div>

    <!--MASK提示层-->
    <div class="mask">
        <div class="loader center-translate">
            <div style="font-size: 14px;">
                <i class="fa fa-2x fa-spinner fa-pulse"></i>
            </div>
            <p id="loadtext">正在加载...</p>
        </div>
    </div>
    <script type="text/javascript" src="../../res/js/fastclick.min.js"></script>
    <script type="text/javascript" src="../../res/js/jquery.js"></script>
    <script type="text/javascript">
        var currentSite = "index";
        var vipid = "<%=vipid%>", vipkh = "<%=vipkh%>";
        $(document).ready(function () {
            FastClick.attach(document.body);
            LoadZBData();
        });

        function returnSite() {
            switch (currentSite) {
                case "detail":
                    $("#detail").addClass("page-right");
                    $("#main-list").removeClass("page-left");
                    currentSite = "index";
                    break;
                case "index":
                    window.history.go(-1);
                    break;
            }
        }

        function showMessage(type, txt) {
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
                        $(".mask").fadeOut(200);
                    }, 500);
                    break;
                case "error":
                    $(".mask .fa").removeAttr("class").addClass("fa fa-2x fa-close (alias)");
                    $("#loadtext").text(txt);
                    $(".mask").show();
                    setTimeout(function () {
                        $(".mask").fadeOut(400);
                    }, 2000);
                    break;
                case "warn":
                    $(".mask .fa").removeAttr("class").addClass("fa fa-2x fa-warning (alias)");
                    $("#loadtext").text(txt);
                    $(".mask").show();
                    setTimeout(function () {
                        $(".mask").fadeOut(400);
                    }, 800);
                    break;
            }
        }

        var ztemp = "<li class='item' onclick=\"ShowDetail(\'#id#\')\"><div class='infos'><p class='order'>订单号：#order#</p><p class='mdmc'><strong>门店：</strong>#mdmc#</p><p class='time'><strong>时间：</strong>#rq#</p><div class='counts'>#sumprice#</div></div><i class='fa fa-angle-right'></i></li>";
        //加载主表数据
        function LoadZBData() {
            showMessage("loading", "正在加载...");
            $.ajax({
                url: "../../WebBLL/FWHUserCenterCore.aspx?ctrl=LoadConsumeRecords",
                type: "POST",
                dataType: "text",
                data:{vipkh:vipkh},
                timeout: 10000,
                error: function (XMLHttpRequest, textStatus, errorThrown) {
                    showMessage("error", "您的网络好像出了点问题,请稍后重试...");
                },
                success: function (datas) {
                    if (datas == "") {
                        $("#noresults").show();
                        $(".mask").hide();
                    } else if (datas.indexOf("Error:") > -1) {
                        showMessage("error", datas.replace("Error:", ""));
                    } else {
                        var data = JSON.parse(datas);
                        var len = data.rows.length;
                        var htmlStr = "";
                        for (var i = 0; i < len; i++) {
                            var row = data.rows[i];
                            htmlStr += ztemp.replace("#id#", row.id).replace("#order#", row.ordernum).replace("#mdmc#", row.mdmc).replace("#rq#", row.rq).replace("#sumprice#", row.sskje);
                        }//end for
                        $(".consumelist").children().remove();
                        $(".consumelist").append(htmlStr);
                        $(".mask").hide();                        
                    }                    
                }
            });
        }

        var mtemp = "<li class='ditem'><div class='clothesimg backimg' style='background-image:url(#imgsrc#);'></div><div class='clothes-info'><p class='title'>#spmc#</p><p class='cmys'><p class='cmys'><strong>尺码：</strong>#cmmc#&nbsp;&nbsp;&nbsp;<strong>数量：</strong>#sl#</p><p class='price'>￥#dj#</p></div></li>";
        //加载明细数据传入对应单据ID
        function ShowDetail(djid) {
            showMessage("loading", "正在加载...");
            $.ajax({
                url: "../../WebBLL/FWHUserCenterCore.aspx?ctrl=LoadConsumeDetail",
                type: "POST",
                dataType: "text",
                data:{djid:djid},
                timeout: 10000,
                error: function (XMLHttpRequest, textStatus, errorThrown) {
                    showMessage("error", "您的网络好像出了点问题,请稍后重试...");
                },
                success: function (datas) {
                    if (datas == "") {
                        showMessage("warn", "加载不到该单数据,您可以稍后重试!");
                    } else if (datas.indexOf("Error:") > -1) {
                        showMessage("error", datas.replace("Error:", ""));
                    } else {
                        var data = JSON.parse(datas);
                        var len = data.rows.length;
                        var htmlStr = "", sum_price = 0;
                        for (var i = 0; i < len; i++) {
                            var row = data.rows[i];
                            var imgsrc = row.urladdress == "" ? "../img/EasyBusiness/lilanzlogo2.jpg" : "http://webt.lilang.com:9001" + row.urladdress.replace("..", "");
                            htmlStr += mtemp.replace("#spmc#", row.spmc+" ("+row.sphh+")").replace("#cmmc#", row.cmmc).replace("#sl#", row.sl).replace("#dj#", row.dj).replace("#imgsrc#", imgsrc);
                            sum_price += parseInt(row.dj) * parseInt(row.sl);
                        }
                        htmlStr += "<li class='sums'>本单合计金额为：<span id='price_all'>￥" + sum_price + "</span></li>";
                        $(".detailul").children().remove();
                        $(".detailul").append(htmlStr);

                        $(".mask").hide();
                        $("#main-list").addClass("page-left");
                        $("#detail").removeClass("page-right");
                        currentSite = "detail";
                    }
                }
            });
        }
    </script>
</body>
</html>

