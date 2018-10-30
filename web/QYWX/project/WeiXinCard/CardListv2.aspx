<%@ Page Language="C#" %>

<%@ Import Namespace="nrWebClass" %>
<%@ Import Namespace="System.Collections.Generic" %>

<!DOCTYPE html>
<script runat="server">
    private const string ConfigKeyValue = "1";	//利郎企业号
    private string DBConStr = clsConfig.GetConfigValue("OAConnStr"); // "Data Source=192.168.35.10;Initial Catalog=tlsoft;User ID=ABEASD14AD;password=+AuDkDew";
    public string khid = "", mdid = "", mdmc = "", AppSystemKey = "", RoleID = "", RoleName = "", CustomerID = "", CustomerName = "";
    public List<string> wxConfig;       //微信OPEN_JS 动态生成的调用参数

    protected void Page_Load(object sender, EventArgs e)
    {
        if (clsWXHelper.CheckQYUserAuth(true))
        {
            string SystemID = "3";
            AppSystemKey = clsWXHelper.GetAuthorizedKey(Convert.ToInt32(SystemID));
            CustomerID = Convert.ToString(Session["qy_customersid"]);
            CustomerName = Convert.ToString(Session["qy_cname"]);
            RoleID = Convert.ToString(Session["RoleID"]);
            RoleName = Convert.ToString(Session["RoleName"]);
            if (AppSystemKey == "")
                clsWXHelper.ShowError("对不起，您还未开通全渠道系统权限！");
            else
            {
                mdid = Convert.ToString(Session["mdid"]);
                if (string.IsNullOrEmpty(mdid))
                {
                    clsWXHelper.ShowError("对不起，该模块只能在门店模式下使用！");
                    return;
                }
                using (LiLanzDALForXLM dal10 = new LiLanzDALForXLM(DBConStr))
                {
                    string str_sql = "select top 1 mdmc from t_mdb where mdid='" + mdid + "'";
                    object scalar;
                    string errinfo = dal10.ExecuteQueryFast(str_sql, out scalar);
                    if (errinfo == "")
                    {
                        mdmc = Convert.ToString(scalar);
                        khid = Convert.ToString(Session["tzid"]);
                    }
                }

                wxConfig = clsWXHelper.GetJsApiConfig(ConfigKeyValue);
                clsWXHelper.WriteLog(string.Format("AppSystemKey:{0},访问功能页[{1}]", AppSystemKey, "引流-卡券工具"));
            }
        }
        else
            clsWXHelper.ShowError("鉴权失败，仅限利郎全渠道人员使用！");
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
            font-size: 14px;
            background-color: #f0f0f0;
            line-height: 1;
            color: #363c44;
        }

        .page {
            background-color: #f4f4f4;
        }

        .page-not-header-footer {
            bottom: 28px;
        }

        .header {
            line-height: 50px;
            font-size: 16px;
            z-index: 4000;
            white-space: nowrap;
            overflow: hidden;
            text-overflow: ellipsis;
            box-shadow: 0 1px .5px #eceef1;
            -webkit-box-shadow: 0 1px .5px #eceef1;
        }

            .header .fa-angle-left {
                font-size: 24px;
                position: absolute;
                top: 0;
                left: 0;
                padding: 0 20px;
                border-right: 1px solid #f0f0f0;
                line-height: 50px;
            }

        .card {
            background-color: #fff;
            height: 170px;
            border-radius: 4px;
            box-shadow: 0 1px .5px #eceef1;
            -webkit-box-shadow: 0 1px .5px #eceef1;
        }

            .card:not(:last-child) {
                margin-bottom: 10px;
            }

            .card .card_top {
                height: 130px;
                background-color: #63b359;
                border-top-left-radius: 4px;
                border-top-right-radius: 4px;
                color: #fff;
                padding: 10px;
                position: relative;
                overflow: hidden;
            }

        .card_top .store_name {
            font-size: 14px;
            line-height: 15px;
            vertical-align: top;
        }

        .card_top .card_title {
            font-size: 24px;
            font-weight: bold;
            line-height: 47px;
        }

        .card_top .card_subtitle {
            max-height: 48px;
            line-height: 17px;
            overflow: hidden;
        }

        .card_top .fa-angle-right {
            display: block;
            position: absolute;
            top: 0;
            right: 0;
            padding: 0 10px;
            font-size: 24px;
            line-height: 130px;
            border-left: 1px dashed #fff;
        }

        .card_bot {
            line-height: 40px;
            padding: 0 10px;
            position: relative;
        }

            .card_bot .counts {
                position: absolute;
                top: 0;
                right: 10px;
            }

        .card_top .card_icon {
            width: 100px;
            height: 100px;
            position: absolute;
            top: -20px;
            right: -20px;
            opacity: 0.2;
            transform: rotate(-30deg);
        }

        .back-image {
            background-repeat: no-repeat;
            background-position: 50% 50%;
            background-size: cover;
        }

        /*卡券详情*/
        .card_content {
            background-color: #fff;
            border-bottom-left-radius: 4px;
            border-bottom-right-radius: 4px;
            box-shadow: 0 1px .5px #eceef1;
            -webkit-box-shadow: 0 1px .5px #eceef1;
        }

        .detail_top {
            color: #fff;
            height: 44px;
            line-height: 44px;
            padding: 0 10px;
            font-size: 16px;
            background-color: #63b359;
            border-top-left-radius: 4px;
            border-top-right-radius: 4px;
            position: relative;
        }

            .detail_top:before, .detail_title:before, .detail_qrcode:before, .detail_useinfo:before {
                content: '';
                width: 16px;
                height: 16px;
                background-color: #f4f4f4;
                position: absolute;
                bottom: -8px;
                left: -8px;
                border-radius: 50%;
            }

            .detail_top:after, .detail_title:after, .detail_qrcode:after, .detail_useinfo:after {
                content: '';
                width: 16px;
                height: 16px;
                background-color: #f4f4f4;
                position: absolute;
                bottom: -8px;
                right: -8px;
                border-radius: 50%;
            }

        .detail_title, .detail_useinfo, .detail_qrcode {
            padding: 10px;
            position: relative;
            border-bottom: 1px dashed #ccc;
        }

            .detail_title > h1 {
                text-align: center;
                padding: 10px;
            }

            .detail_title .sub_title {
                text-align: center;
                font-size: 16px;
                color: #888;
            }

            .detail_title .time {
                text-align: center;
                font-size: 14px;
                color: #888;
                padding: 10px 0;
            }

            .detail_useinfo .useinfo-item {
                padding-top: 10px;
                display: -webkit-box;
                display: -webkit-flex;
                display: flex;
            }

        .useinfo-item .left {
            width: 75px;
        }

        .useinfo-item .right {
            -webkit-box-flex: 1;
            -webkit-flex: 1;
            -ms-flex: 1;
            flex: 1;
            line-height: 1.2;
        }

        .detail_bot {
            height: 40px;
            line-height: 40px;
        }

            .detail_bot > div {
                float: left;
                width: 50%;
                text-align: center;
                font-weight: bold;
            }

                .detail_bot > div:not(:last-child) {
                    border-right: 1px solid #f0f0f0;
                }

                .detail_bot > div i {
                    padding-left: 5px;
                    font-size: 16px;
                    color: #cecece;
                }

                .detail_bot > div .check {
                    color: #63b359;
                }

        .footer {
            height: 28px;
            line-height: 28px;
            text-align: center;
            color: #888;
            font-size: 12px;
            background-color: #f4f4f4;
        }

        .detail_qrcode {
            text-align: center;
            font-weight: bold;
            color: #cc463d;
        }

            .detail_qrcode > p {
                line-height: 20px;
            }

        #qrcode {
            width: 52%;
            max-width: 560px;
            border: 1px solid #f0f0f0;
            margin-top: 10px;
            padding: 8px;
        }

        .card_btns {
            width: 94%;
            margin: 0 auto;
        }

            .card_btns .btn-item {
                display: block;
                color: #fff;
                background-color: #63b359;
                margin: 10px auto;
                height: 40px;
                line-height: 40px;
                font-size: 15px;
                font-weight: bold;
                text-align: center;
                border-radius: 4px;
            }

        .no-cards {
            text-align: center;
            color: #999;
            min-width: 100%;
            display: none;
        }

        .disabled {
            pointer-events: none !important;
            background-color: #ccc !important;
        }
        /*viplist style*/
        .user_list {
            line-height: 1;
            width: 100%;
        }

            .user_list li {
                color: #222;
                position: relative;
                background-color: #fff;
                margin-bottom: 5px;
            }

                .user_list li .info_top {
                    display: flex;
                    display: -webkit-flex;
                    align-items: center;
                    padding: 10px;
                }

                .user_list li .info_bot {
                    padding: 3px 10px;
                    color: #fff;
                    font-weight: bold;
                    font-style: italic;
                    line-height: 1.4;
                    transition: all 0.2s;
                    display: none;
                }

            .user_list .fa-check-circle {
                font-size: 24px;
                color: #ccc;
            }

                .user_list .fa-check-circle.check {
                    color: #63b359;
                }

            .user_list .head_img {
                width: 54px;
                min-width: 54px;
                height: 54px;
                border-radius: 50%;
                background-position: center center;
                background-size: cover;
                background-repeat: no-repeat;
                margin: 0 10px;
                border: 2px solid #f0f0f0;
            }

        .user_infos .name {
            font-size: 15px;
            font-weight: bold;
            line-height: 1.2;
        }

        .user_infos .kh {
            padding-top: 8px;
            color: #666;
        }

            .user_infos .kh.wx {
                color: #63b359;
                font-weight: bold;
            }

        .user_infos .last_send {
            font-size: 12px;
            padding-top: 6px;
            color: #666;
        }

        .info_bot.success {
            display: block !important;
            background-color: #63b359;
        }

        .info_bot.fail {
            display: block !important;
            background-color: #cc463d;
        }

        .info_bot.sending {
            display: block !important;
            background-color: #ccc;
        }
        /*viplist end*/
        #vip-list .title {
            height: 40px;
            line-height: 40px;
            background-color: #63b359;
            font-size: 16px;
            color: #fff;
            text-align: center;
            border-top-left-radius: 4px;
            border-top-right-radius: 4px;
        }

        #searchVIP {
            -webkit-appearance: none;
            border: none;
            padding: 0 10px;
            border-bottom: 1px solid #eceef1;
            border-radius: 2px;
            width: 100%;
            margin: 0 auto;
            height: 40px;
            line-height: 40px;
            font-size: 14px;
            outline: none;
        }

        #vip-list .v_top {
            position:absolute;
            top:0;
            left:0;            
            width:100%;
            bottom:40px;
            padding:10px;            
            overflow-x:hidden;
            overflow-y:scroll;
            -webkit-overflow-scrolling:touch;            
        }

        #vip-list .v_btn {
            position:absolute;
            left:0;
            bottom:0;
            width:100%;
            height:40px;          
            font-size:0;
        }

        .mass_btn {
            display:inline-block;
            width:50%;
            background-color:#ccc;
            color:#fff;
            font-weight:bold;
            font-size:14px;
            line-height:40px;
            text-align:center;
        }
            .mass_btn.confirm {
                background-color:#63b359;
            }
        .card_type {
            position: absolute;
            top: 0;
            right: 40px;
            padding: 5px 8px;
            background-color: rgba(0,0,0,.4);
            color: #fff;
            font-size: 12px;
            font-weight: bold;
        }

        .customer {
            background-color: #63b359;
            color: #fff;
            position: absolute;
            top: 50%;
            right: 10px;
            padding: 4px 6px;
            transform: translate(0,-50%);
            -webkit-transform: translate(0,-50%);
            border-radius: 2px;
            font-size: 12px;
        }

        .configname {
            margin-right: 10px;
        }

        .fa-weixin {
            margin-right: 5px;
        }
    </style>
</head>
<body>
    <div class="header">可用卡券列表<i class="fa fa-angle-left"></i></div>
    <div class="wrap-page">
        <!--卡券主列表-->
        <div class="page page-not-header-footer" id="main-page">
            <div id="card-list">
                <p class="no-cards center-translate">对不起,您所在门店目前还没有可用的卡券...</p>
            </div>
        </div>

        <!--卡券详情页-->
        <div class="page page-not-header-footer page-top" id="card-detail" cardid="0" configkey="" isload="0"></div>

        <!--VIP列表页-->
        <div class="page page-not-header page-right" id="vip-list">
            <div class="v_top">
                <p class="title">请选择VIP用户（<span id="vipnos">--</span>）</p>
                <input type="text" id="searchVIP" placeholder="搜索VIP的名字或昵称.." oninput="searchFunc()" />
                <ul class="user_list">
                    <!--<li data-vipty="false" data-objectid="1" data-vipid="3950688" data-wxopenid="oarMEt8bqjmZIAhImSXBAg0G7F0I">
                    <div class="info_top">
                        <i class="fa fa-check-circle"></i>
                        <div class="head_img" style="background-image: url(../../res/img/storesaler/vip1.jpg)"></div>
                        <div class="user_infos">
                            <p class="name">李清峰（Elilee）</p>
                            <p class="kh">VIP卡号:15260825009</p>
                            <p class="last_send">最后发送时间:</p>
                        </div>
                    </div>
                    <div class="info_bot">                        
                    </div>
                </li>

                <li data-vipty="false" data-objectid="1" data-vipid="3403231" data-wxopenid="oarMEtzTmu6TCIO1mibQVSYfg94M">
                    <div class="info_top">
                        <i class="fa fa-check-circle"></i>
                        <div class="head_img" style="background-image: url(../../res/img/storesaler/vip1.jpg)"></div>
                        <div class="user_infos">
                            <p class="name">李清峰（李家的风）</p>
                            <p class="kh">VIP卡号:17076610538</p>
                            <p class="last_send">最后发送时间:</p>
                        </div>
                    </div>
                    <div class="info_bot">                        
                    </div>
                </li>

                    <li data-vipty="false" data-objectid="1" data-vipid="3950688" data-wxopenid="oarMEt8bqjmZIAhImSXBAg0G7F0I">
                    <div class="info_top">
                        <i class="fa fa-check-circle"></i>
                        <div class="head_img" style="background-image: url(../../res/img/storesaler/vip1.jpg)"></div>
                        <div class="user_infos">
                            <p class="name">李清峰（Elilee）</p>
                            <p class="kh">VIP卡号:15260825009</p>
                            <p class="last_send">最后发送时间:</p>
                        </div>
                    </div>
                    <div class="info_bot">                        
                    </div>
                </li>

                <li data-vipty="false" data-objectid="1" data-vipid="3403231" data-wxopenid="oarMEtzTmu6TCIO1mibQVSYfg94M">
                    <div class="info_top">
                        <i class="fa fa-check-circle"></i>
                        <div class="head_img" style="background-image: url(../../res/img/storesaler/vip1.jpg)"></div>
                        <div class="user_infos">
                            <p class="name">李清峰（李家的风）</p>
                            <p class="kh">VIP卡号:17076610538</p>
                            <p class="last_send">最后发送时间:</p>
                        </div>
                    </div>
                    <div class="info_bot">                        
                    </div>
                </li>
                    <li data-vipty="false" data-objectid="1" data-vipid="3950688" data-wxopenid="oarMEt8bqjmZIAhImSXBAg0G7F0I">
                    <div class="info_top">
                        <i class="fa fa-check-circle"></i>
                        <div class="head_img" style="background-image: url(../../res/img/storesaler/vip1.jpg)"></div>
                        <div class="user_infos">
                            <p class="name">李清峰（Elilee）</p>
                            <p class="kh">VIP卡号:15260825009</p>
                            <p class="last_send">最后发送时间:</p>
                        </div>
                    </div>
                    <div class="info_bot">                        
                    </div>
                </li>

                <li data-vipty="false" data-objectid="1" data-vipid="3403231" data-wxopenid="oarMEtzTmu6TCIO1mibQVSYfg94M">
                    <div class="info_top">
                        <i class="fa fa-check-circle"></i>
                        <div class="head_img" style="background-image: url(../../res/img/storesaler/vip1.jpg)"></div>
                        <div class="user_infos">
                            <p class="name">李清峰（李家的风）</p>
                            <p class="kh">VIP卡号:17076610538</p>
                            <p class="last_send">最后发送时间:</p>
                        </div>
                    </div>
                    <div class="info_bot">                        
                    </div>
                </li>-->
                </ul>
            </div>
            <div class="v_btn">
                <a href="javascript:;" class="mass_btn cancle">取 消</a>
                <a href="javascript:;" class="mass_btn confirm">确 认（<span id="selectAlls">0</span>）</a>
            </div>
        </div>
    </div>
    <div class="footer">&copy;2017 利郎信息技术部提供技术支持</div>
    <script type="text/javascript" src="../../res/js/jquery.js"></script>
    <script type="text/javascript" src="../../res/js/storesaler/fastclick.min.js"></script>
    <script type="text/javascript" src="../../res/js/LeeJSUtils.min.js"></script>
    <script type="text/javascript" src="../../res/js/template.js"></script>
    <script type="text/javascript" src="http://res.wx.qq.com/open/js/jweixin-1.0.0.js"></script>

    <!--模板区-->
    <script id="card_temp" type="text/html">
        <div class="card" id="{{id}}">
            <div class="card_top" style="background-color: {{color}};" onclick="GetCardDetail({{id}});">
                <div class="store_name"><i class="fa fa-weixin"></i><span class="configname" data-key="{{configkey}}">{{configname}}</span>门店：<%=mdmc %></div>
                <div class="card_title">{{title}}</div>
                <div class="card_subtitle">{{subtitle}}</div>
                <div class="back-image card_icon" style="background-image: url(../../res/img/storesaler/card-icon.png);"></div>
                <i class="fa fa-angle-right"></i>
                <div class="card_type">{{typename}}</div>
            </div>
            <div class="card_bot">
                <p class="time">有效期: {{ksrq}} 至 {{jsrq}}</p>
                <div class="counts">剩余数量:<span>{{stock}}</span></div>
            </div>
        </div>
    </script>

    <!--用户模板-->
    <script type="text/html" id="tmp_user_item">
        <li data-vipty="{{vipty}}" data-objectid="{{objectid}}" data-vipid="{{vipid}}" data-wxopenid="{{wxopenid}}">
            <div class="info_top">
                <i class="fa fa-check-circle"></i>
                <div class="head_img" style="background-image: url({{wxheadimgurl}})"></div>
                <div class="user_infos">
                    <p class="name">{{xm}}（{{wxnick}}）</p>
                    <p class="kh {{if vipid == "" && vipid == "0"}}wx{{/if}}">{{if vipid!= "" && vipid != "0"}}VIP卡号：{{vipkh}}{{else}}微信粉丝{{/if}}</p>
                    <p class="last_send">最后发送时间：{{lastsend}}</p>
                </div>
            </div>
            <div class="info_bot"></div>
        </li>
    </script>

    <!--卡券详情模板-->
    <script id="carddetail_temp" type="text/html">
        <div class="card_content">
            <div class="detail_top">
                <i class="fa fa-weixin" style="padding-right: 5px;"></i><span>--</span>
            </div>
            <div class="detail_title">
                <h1>{{title}}</h1>
                <p class="sub_title">{{subtitle}}</p>
                <p class="time">有效期：{{ksrq}} 至 {{jsrq}}</p>
            </div>
            <div class="detail_useinfo">
                <p style="padding: 3px 0 10px 0; border-bottom: 1px solid #f0f0f0; font-weight: bold;">{{cardtypename}}详情</p>
                <!--折扣券参数-->
                <div class="useinfo-item discount">
                    <div class="left" style="font-weight: bold;">折扣数：</div>
                    <div class="right" style="font-weight: bold;">{{localdiscount}} 折</div>
                </div>
                <!--抵用券参数-->
                <div class="useinfo-item cash">
                    <div class="left" style="font-weight: bold;">使用门槛：</div>
                    <div class="right" style="font-weight: bold;">{{leastcost}} 元</div>
                </div>
                <div class="useinfo-item cash">
                    <div class="left" style="font-weight: bold;">抵用金额：</div>
                    <div class="right" style="font-weight: bold;">{{reducecost}} 元</div>
                </div>
                <div class="useinfo-item">
                    <div class="left">优惠详情：</div>
                    <div class="right">{{detail}}</div>
                </div>
                <div class="useinfo-item">
                    <div class="left">每人限领：</div>
                    <div class="right">{{getlimit}}张</div>
                </div>
                <div class="useinfo-item">
                    <div class="left">使用提醒：</div>
                    <div class="right">{{notice}}</div>
                </div>
                <div class="useinfo-item">
                    <div class="left">使用说明：</div>
                    <div class="right">{{description}}</div>
                </div>
                <div class="useinfo-item">
                    <div class="left">客服电话：</div>
                    <div class="right">{{servicephone}}</div>
                </div>
            </div>
            <div class="detail_qrcode" style="display: none">
                <p>请将下面二维码让客人扫：</p>
            </div>
            <div class="detail_bot">
                <div>可转赠<i class="fa fa-check-circle {{cangive}}"></i></div>
                <div>可分享<i class="fa fa-check-circle {{canshare}}"></i></div>
            </div>
        </div>
        <div class="card_btns">
            <a class="btn-item" id="create-btn" href="javascript:" onclick="CreateTicket()">立即生成</a>
            <a class="btn-item" id="send-btn" href="javascript:" onclick="LoadVipList()">发送给VIP</a>
        </div>
    </script>

    <script type="text/javascript">
        var mdid = "<%=mdid%>", userid = "<%=CustomerID%>", username = "<%=CustomerName%>", roleName = "<%=RoleName%>", khid = "<%=khid%>";
        var CurrentSite = "index", ConfigKey = "";
        var appIdVal = "<%=wxConfig[0]%>", timestampVal = "<%=wxConfig[1]%>", nonceStrVal = "<%=wxConfig[2]%>", signatureVal = "<%=wxConfig[3]%>";
        //var apiUrl = "http://tm.lilanz.com/oa/project/WeiXinCard/WXCardCore.aspx";
        var apiUrl = "WXCardCore.aspx";
        $(function () {
            FastClick.attach(document.body);
            jsConfig();
            LeeJSUtils.stopOutOfPage("#main-page", true);
            LeeJSUtils.stopOutOfPage("#card-detail", true);            
            LeeJSUtils.stopOutOfPage(".header", false);
            LeeJSUtils.stopOutOfPage(".footer", false);
            LeeJSUtils.LoadMaskInit();
        });

        window.onload = function () {
            LoadCardList();
            BindEvents();
        };

        function jsConfig() {
            wx.config({
                debug: false,
                appId: appIdVal, // 必填，公众号的唯一标识
                timestamp: timestampVal, // 必填，生成签名的时间戳
                nonceStr: nonceStrVal, // 必填，生成签名的随机串
                signature: signatureVal, // 必填，签名，见附录1
                jsApiList: ['onMenuShareTimeline', 'onMenuShareQQ', 'onMenuShareAppMessage', 'onMenuShareQZone'] // 必填，需要使用的JS接口列表，所有JS接口列表见附录2
            });
            wx.ready(function () {

            });
            wx.error(function (res) {
                alert("JS注入失败！");
            });
        }

        //选中用户批量发送
        function massSendPerOne(order) {
            LeeJSUtils.showMessage("loading", "正在群发中.. " + (order + 1) + " / " + sendUsers);
            var item_bot = $(".user_list li.check").eq(order).find(".info_bot");
            item_bot.addClass("sending").text("正在发送..");
            var openid = item_bot.parent().attr("data-wxopenid");
            var cardid = $("#card-detail").attr("cardid");

            setTimeout(function () {
                $.ajax({
                    type: "POST",
                    timeout: 8000,
                    contentType: "application/x-www-form-urlencoded; charset=utf-8",
                    url: apiUrl,
                    data: { ctrl: "doSendCard2VIP", openid: openid, cardid: cardid },
                    success: function (msg) {
                        var data = JSON.parse(msg);
                        if (data.code == 200) {
                            var now = new Date(Date.now()).Format("yyyy-MM-dd HH:mm:ss");
                            //item_bot.removeClass("sending").addClass("success").text("发送成功！");
                            item_bot.attr("class", "info_bot").addClass("success").text("发送成功！")
                            item_bot.parent().find(".last_send").text("最后发送时间：" + now);
                        }
                        else if (data.code == 201)
                            item_bot.attr("class", "info_bot").addClass("fail").text("发送失败！" + data.message);

                        if (order < $(".user_list li.check").length - 1)
                            massSendPerOne(order + 1);
                        else {
                            $(".user_list .fa-check-circle.check").removeClass("check");
                            $(".user_list li.check").removeClass("check");
                            $("#selectAlls").text("0");
                            sendUsers = 0;
                            LeeJSUtils.showMessage("successed", "全部发送完毕，发送结果请在页面上查看。");
                        }
                    },
                    error: function (XMLHttpRequest, textStatus, errorThrown) {
                        item_bot.removeClass("sending").addClass("fail").text("网络出错！" + XMLHttpRequest.status + "|" + XMLHttpRequest.statusText);

                        if (order < $(".user_list li.check").length - 1)
                            massSendPerOne(order + 1);
                        else {
                            $(".user_list .fa-check-circle.check").removeClass("check");
                            $(".user_list li.check").removeClass("check");
                            $("#selectAlls").text("0");
                            sendUsers = 0;
                            LeeJSUtils.showMessage("successed", "全部发送完毕，发送结果请在页面上查看。");
                        }
                    }
                });//end AJAX
            }, 50);
        }

        //返回操作
        $(".header .fa-angle-left").click(function () {
            ClickBack();
        });

        function BindEvents() {
            $("#vip-list .user_list").on("click", "li", function () {
                var ele = $(this).find(".fa-check-circle");                
                if (ele.hasClass("check")) {
                    ele.removeClass("check");
                    $(this).removeClass("check");
                    $("#selectAlls").text(--sendUsers);
                }
                else {
                    var vipid = $(this).attr("data-vipid");
                    var vipty = $(this).attr("data-vipty");
                    var configkey=$("#card-detail").attr("configkey");
                    var objectid=$(this).attr("data-objectid");

                    if (parseInt(vipid) > 0 && vipty == "true") {
                        //alert("对不起，该VIP用户已经被停用，无法发送！");
                        LeeJSUtils.showMessage("warn", "对不起，该VIP用户已经被停用，无法发送！");
                    } else if ((configkey == "7" && objectid != "4") || (configkey == "5" && objectid != "1")) {
                        //alert("对不起，该用户与当前卡券所属公众号不一致，无法发送！");
                        LeeJSUtils.showMessage("warn", "对不起，该用户与当前卡券所属公众号不一致，无法发送！");
                    } else {
                        ele.addClass("check");
                        $(this).addClass("check");
                        $("#selectAlls").text(++sendUsers);
                    }
                }
            });

            $(".mass_btn.cancle").click(function () {
                ClickBack();
            });

            $(".mass_btn.confirm").click(function () {
                if (sendUsers > 0) {
                    if (confirm("确认群发给" + sendUsers + "位用户？\r\n发送过程可能需要一段时间，请耐心等待！")) {
                        massSendPerOne(0);
                    }
                }
            });
        }

        //加载卡券列表
        function LoadCardList() {
            LeeJSUtils.showMessage("loading", "正在加载微信卡券列表...");
            $.ajax({
                type: "POST",
                timeout: 5000,
                contentType: "application/x-www-form-urlencoded; charset=utf-8",
                url: apiUrl,
                data: { ctrl: "LoadCardList", mdid: mdid },
                success: function (msg) {
                    if (msg == "") {
                        $(".no-cards").show();
                        $("#leemask").hide();
                    }
                    else {
                        if (msg.indexOf("Error:") > -1)
                            LeeJSUtils.showMessage("error", msg.replace("Error:", ""));
                        else {
                            var data = JSON.parse(msg);
                            var len = data.rows.length;
                            var str_html = "";
                            for (var i = 0; i < len; i++) {
                                var row = data.rows[i];
                                var color = ColorSwitch(row.color);
                                row.color = color;
                                str_html += template("card_temp", row);
                            }//end for
                            $("#card-list").append(str_html);
                            $("#leemask").hide();
                        }//end else
                    }
                },
                error: function (XMLHttpRequest, textStatus, errorThrown) {
                }
            });//end AJAX
        }

        //加载卡券详情
        function GetCardDetail(id) {
            LeeJSUtils.showMessage("loading", "正在加载微信卡券列表...");
            $.ajax({
                type: "POST",
                timeout: 5000,
                contentType: "application/x-www-form-urlencoded; charset=utf-8",
                url: apiUrl,
                data: { ctrl: "GetCardDetail", id: id },
                success: function (msg) {
                    if (msg.indexOf("Error:") > -1)
                        LeeJSUtils.showMessage("error", msg.replace("Error:", ""));
                    else {
                        var data = JSON.parse(msg);
                        var row = data.rows[0];
                        if (row.localcardtype == "LILANZ_DISCOUNT")
                            row.cardtypename = "折扣券";
                        else if (row.localcardtype == "LILANZ_CASH")
                            row.cardtypename = "现金抵用券";
                        else
                            row.cardtypename = "未知券";
                        var str_html = template("carddetail_temp", row);
                        $("#card-detail").empty().append(str_html);
                        if (row.localcardtype == "LILANZ_DISCOUNT")
                            $(".useinfo-item.cash").hide();
                        else if (row.localcardtype == "LILANZ_CASH")
                            $(".useinfo-item.discount").hide();
                        $("#leemask").hide();
                        $("#card-detail").attr("cardid", $(this).parent().attr("id"));
                        var color = $(".card_top", "div [id=" + id + "]").css("background-color");
                        $(".detail_top").css("background-color", color);
                        $("#create-btn").css("background-color", color);
                        $("#card-detail").attr("cardid", id);

                        ConfigKey = $(".card[id=" + id + "] .configname").attr("data-key");//该卡券属于哪个公众号
                        $("#card-detail").attr("configkey", ConfigKey);

                        //只有店长才能发送给VIP
                        if (roleName != "dz")
                            $("#send-btn").hide();

                        $(".detail_top span").text($(".card[id=" + id + "] .configname").text());
                        $("#main-page").addClass("page-bot");
                        $("#card-detail").removeClass("page-top");
                        CurrentSite = "card-detail";
                        //自动生成二维码
                        CreateTicket();
                    }//end else                        
                },
                error: function (XMLHttpRequest, textStatus, errorThrown) {
                }
            });//end AJAX
        }

        //创建给用户扫描的卡券二维码
        function CreateTicket() {
            var cardid = $("#card-detail").attr("cardid");
            if (cardid == "" || cardid == "0" || cardid == undefined)
                LeeJSUtils.showMessage("error", "CARDID有误！");
            else {
                LeeJSUtils.showMessage("loading", "正在生成，请稍候...");
                $.ajax({
                    type: "POST",
                    timeout: 5000,
                    contentType: "application/x-www-form-urlencoded; charset=utf-8",
                    url: apiUrl,
                    async: false,
                    data: { ctrl: "CreateQRcode", id: cardid, userid: userid, mdid: mdid },
                    success: function (msg) {
                        if (msg.indexOf("Error:") > -1)
                            LeeJSUtils.showMessage("error", msg.replace("Error:", ""));
                        else {
                            //生成成功接下来构造用户访问的URL并生成二维码 tm.lilanz.com/project/easybusiness/
                            var TGUID = msg.replace("Successed", "").replace("Warn:", "");
                            //var redirect_url = "http%3a%2f%2ftm.lilanz.com%2fqywx%2ftest%2fweixincard%2fUserGetTicket.aspx?ticket=" + TGUID + "&configkey=" + ConfigKey;                                
                            var redirect_url = "http%3a%2f%2ftm.lilanz.com%2fproject%2feasybusiness%2fUserGetTicket.aspx?ticket=" + TGUID + "&configkey=" + ConfigKey;
                            redirect_url = escape(redirect_url);
                            var img = new Image();
                            img.src = "http://tm.lilanz.com/oa/project/StoreSaler/GetQrCode.aspx?code=" + redirect_url;
                            img.id = "qrcode";
                            img.onload = function () {
                                //$("#create-btn").addClass("disabled");
                                //用户领取时页面的数量才会-1
                                //$(".counts>span", "div [id=" + cardid + "]").text(parseInt($(".counts>span", "div [id=" + cardid + "]").text()) - 1);
                                //LeeJSUtils.showMessage("successed", "生成成功,请将下方对应的二维让客人扫！");
                                $("#leemask").hide();
                                $(".detail_qrcode img").remove();
                                $(".detail_qrcode").append(img);
                                $(".detail_qrcode").show();
                                Slide2Bottom("card-detail");
                                //alert("图像加载守毕！");
                            }
                        }
                    },
                    error: function (XMLHttpRequest, textStatus, errorThrown) {
                    }
                });//end AJAX
            }//end else
        }

        //发送模板消息 20170404 该方法停用
        function Send2VIP(openid) {
            return;
            var cardid = $("#card-detail").attr("cardid");
            var card_title = $(".card[id=" + cardid + "] .card_title").text();
            var vipname = $(".name", ".vip-li[openid=" + openid + "]").text();
            if (confirm("确定将【" + card_title + "】发送给用户【" + vipname + "】？")) {
                LeeJSUtils.showMessage("loading", "正在发送中，请稍候...");
                setTimeout(function () {
                    $(".vip-ul .active").removeClass("active");
                    $(".vip-li[openid=" + openid + "]").addClass("active");
                    $.ajax({
                        type: "POST",
                        timeout: 5000,
                        contentType: "application/x-www-form-urlencoded; charset=utf-8",
                        url: apiUrl,
                        async: false,
                        data: { ctrl: "Send2VIP", id: cardid, userid: userid, username: username, mdid: mdid, openid: openid },
                        success: function (msg) {
                            if (msg == "Successed") {
                                $(".detail_qrcode img").remove();
                                LeeJSUtils.showMessage("successed", "发送成功！");
                                ClickBack();
                            }
                            else {
                                $(".vip-ul .active").removeClass("active");
                                LeeJSUtils.showMessage("error", "发送失败！" + msg.replace("Error:", ""));
                            }
                        },
                        error: function (XMLHttpRequest, textStatus, errorThrown) {
                        }
                    });//end AJAX
                }, 500);
            }
        }

        function ColorSwitch(dm) {
            var color = "";
            switch (dm) {
                case "Color010":
                    color = "#63b359";
                    break;
                case "Color020":
                    color = "#2c9f67";
                    break;
                case "Color030":
                    color = "#509fc9";
                    break;
                case "Color040":
                    color = "#5885cf";
                    break;
                case "Color050":
                    color = "#9062c0";
                    break;
                case "Color060":
                    color = "#d09a45";
                    break;
                case "Color070":
                    color = "#e4b138";
                    break;
                case "Color080":
                    color = "#ee903c";
                    break;
                case "Color081":
                    color = "#f08500";
                    break;
                case "Color082":
                    color = "#a9d92d";
                    break;
                case "Color090":
                    color = "#dd6549";
                    break;
                case "Color100":
                    color = "#cc463d";
                    break;
                case "Color101":
                    color = "#cf3e36";
                    break;
                case "Color102":
                    color = "#5E6671";
                    break;
                default:
                    color = "#63b359";
                    break;
            }

            return color;
        }

        //滚动到底部
        function Slide2Bottom(id) {
            var obj = document.getElementById(id);
            $("#" + id).animate({ scrollTop: (obj.scrollHeight - obj.clientHeight) + 'px' }, 500);
        }

        //返回函数
        function ClickBack() {
            switch (CurrentSite) {
                case "card-detail":
                    $("#main-page").removeClass("page-bot");
                    $("#card-detail").addClass("page-top");
                    $("#card-detail").attr("cardid", "0");
                    $(".detail_qrcode img").remove();
                    $(".detail_qrcode").hide();
                    ConfigKey = "";
                    CurrentSite = "index";
                    break;
                case "vip-list":
                    $("#card-detail").removeClass("page-left");
                    $("#vip-list").addClass("page-right");
                    $(".vip-ul .active").removeClass("active");
                    $("#searchVIP").val("");
                    $(".vip-li").show();
                    CurrentSite = "card-detail";
                    break;
            }
        }

        //20170403 liqf 改造
        //加载当前卡券当前门店所属的所有粉丝 只有店长身份才能使用此功能
        var sendUsers = 0;
        function LoadVipList() {
            LeeJSUtils.showMessage("loading", "正在加载VIP用户列表...");
            var currentCID = $("#card-detail").attr("cardid");
            $.ajax({
                type: "POST",
                timeout: 5000,
                contentType: "application/x-www-form-urlencoded; charset=utf-8",
                url: apiUrl,
                data: { ctrl: "getStoreVIPList", khid: khid, cardid: currentCID },
                success: function (msg) {
                    var rows = JSON.parse(msg);
                    if (rows.code == 200) {
                        var configkey = $("#card-detail").attr("configkey"), count = 0;
                        for (var html = "", i = 0; i < rows.data.length; i++) {                            
                            var row = rows.data[i];
                            //如果用户不是当前卡券所属公众号的则不显示出来
                            if ((configkey == "7" && row.objectid != "4") || (configkey == "5" && row.objectid != "1"))
                                continue;                            
                            row.wxnick = unescape(row.wxnick);                            
                            html += template("tmp_user_item", row);
                            count++;
                        }//end for
                        $("#vip-list .user_list").empty().html(html);
                        $("#vipnos").text(count);
                        $("#leemask").hide();
                    } else
                        LeeJSUtils.showMessage("error", rows.message);
                },
                error: function (XMLHttpRequest, textStatus, errorThrown) {
                }
            });//end AJAX

            sendUsers = 0;
            $("#selectAlls").text("0");
            $("#card-detail").addClass("page-left");
            $("#vip-list").removeClass("page-right");
            CurrentSite = "vip-list";
        }

        //本地搜索功能
        $.expr[":"].Contains = function (a, i, m) {
            return (a.textContent || a.innerText || "").toUpperCase().indexOf(m[3].toUpperCase()) >= 0;
        };

        function searchFunc() {
            var obj = $("#vip-list .user_infos .name");
            if (obj.length > 0) {
                var filter = $("#searchVIP").val().trim();
                if (filter) {
                    $matches = $(".user_infos").find(".name:Contains(" + filter + ")").parent().parent().parent();
                    $(".user_list li").not($matches).hide();
                    $matches.show();
                } else {
                    $(".user_list li").show();
                }
            }
        }

        //分享功能
        function shareLink() {
            var sharelink = "", imgurl = "", title = "", desc = "";
            //分享到朋友圈
            wx.onMenuShareTimeline({
                title: title, // 分享标题
                link: sharelink, // 分享链接                        
                imgUrl: imgurl, // 分享图标
                success: function () {
                },
                cancel: function () {
                }
            });

            //分享给QQ好友
            wx.onMenuShareQQ({
                title: title, // 分享标题   
                desc: desc,
                link: sharelink, // 分享链接
                imgUrl: imgurl, // 分享图标
                success: function () {
                },
                cancel: function () {
                }
            });

            //分享给朋友
            wx.onMenuShareAppMessage({
                title: title, // 分享标题   
                desc: desc,
                link: sharelink, // 分享链接
                imgUrl: imgurl, // 分享图标
                type: 'link', // 分享类型,music、video或link，不填默认为link
                dataUrl: '', // 如果type是music或video，则要提供数据链接，默认为空
                success: function () {
                },
                cancel: function () {
                }
            });
            //分享到QQ空间
            wx.onMenuShareQZone({
                title: title, // 分享标题   
                desc: desc,
                link: sharelink, // 分享链接
                imgUrl: imgurl, // 分享图标
                success: function () {
                },
                cancel: function () {
                }
            });
        }

        Date.prototype.Format = function (fmt) { 
            var o = {
                "M+": this.getMonth() + 1,
                "d+": this.getDate(),
                "H+": this.getHours(),
                "m+": this.getMinutes(),
                "s+": this.getSeconds(),
                "q+": Math.floor((this.getMonth() + 3) / 3),
                "S": this.getMilliseconds()
            };
            var year = this.getFullYear();
            var yearstr = year + '';
            yearstr = yearstr.length >= 4 ? yearstr : '0000'.substr(0, 4 - yearstr.length) + yearstr;

            if (/(y+)/.test(fmt)) fmt = fmt.replace(RegExp.$1, (yearstr + "").substr(4 - RegExp.$1.length));
            for (var k in o)
                if (new RegExp("(" + k + ")").test(fmt)) fmt = fmt.replace(RegExp.$1, (RegExp.$1.length == 1) ? (o[k]) : (("00" + o[k]).substr(("" + o[k]).length)));
            return fmt;
        }
    </script>
</body>
</html>
