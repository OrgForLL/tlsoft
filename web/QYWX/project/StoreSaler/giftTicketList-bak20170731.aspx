<%@ Page Language="C#" %>
<%@ Import Namespace="nrWebClass" %>
<%@ Import Namespace="System.Data.SqlClient" %>
<%@ Import Namespace="System.Data" %>
<%@ Import Namespace="System.Collections.Generic" %>

<!DOCTYPE html>
<script runat="server">
    public string AppSystemKey = "", CustomerID = "", CustomerName = "", mdid = "", mdmc = "", tzid = "";
    public int SystemID = 3;
    private string DBConstr = clsConfig.GetConfigValue("OAConnStr");
    
    protected void Page_Load(object sender, EventArgs e)
    {
        if (clsWXHelper.CheckQYUserAuth(true))
        {
            AppSystemKey = clsWXHelper.GetAuthorizedKey(SystemID);
            mdid = Convert.ToString(Session["mdid"]);
            if (AppSystemKey == "")
                clsWXHelper.ShowError("对不起，您还未开通全渠道系统权限！");
            else if (mdid == "" || mdid == "0") {
                clsWXHelper.ShowError("对不起，您无门店信息，无法使用此功能！");
            }
            else
            {
                CustomerID = Convert.ToString(Session["qy_customersid"]);
                CustomerName = Convert.ToString(Session["qy_cname"]);

                using (LiLanzDALForXLM dal10 = new LiLanzDALForXLM(DBConstr))
                {
                    string sql = "select top 1 khid,mdmc from t_mdb where mdid=" + mdid;
                    DataTable dt;
                    string errinfo = dal10.ExecuteQuery(sql, out dt);
                    if (errinfo == "" && dt.Rows.Count > 0)
                    {
                        mdmc = dt.Rows[0]["mdmc"].ToString();
                        tzid = dt.Rows[0]["khid"].ToString();

                        dt.Clear(); dt.Dispose();
                    }
                }//end using           
            }
        }        
    }
</script>
<html lang="en">
<head runat="server">
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
            color: #fff;
        }

        .page {
            background-color: #2f4050;
            padding: 0;
            bottom:24px;
        }

        .header {
            line-height: 51px;
            font-size: 18px;
            letter-spacing: 1px;
            font-weight: 600;
            color: #fff;
            background-color: #2f4050;
            border-bottom:1px solid #202e3c;
        }

            .header .fa-plus {
                position:absolute;
                top:0;
                right:0;
                padding:0 15px;
                line-height:51px;
                font-size:24px;
            }

        .footer {
            height:24px;
            line-height:24px;
            background-color:#2f4050; 
            font-size:12px;
            color:rgba(255,255,255,.4);           
        }

        .ticket {
            width: 100%;
            height: 100px;
            background-color: #cb6358;
            transition: all 0.4s ease;
            vertical-align: top;
            position: relative;
            margin-bottom: 20px;
        }

            .ticket .item {
                width: 100%;
                height: 100%;
                position: relative;
            }

            .ticket .options {
                width: 210px;
                height: 100%;
                background-color: #e2a33d;
                position: absolute;
                top: 0;
                right: -210px;
                padding: 10px 0;
                white-space: nowrap;
                font-size: 0;
                overflow-x: auto;
                overflow-y: hidden;
                -webkit-overflow-scrolling: touch;
            }

                .ticket .options::-webkit-scrollbar {
                    display: none;
                }

            .ticket .left {
                position: absolute;
                top: 0;
                left: 15px;
                width: 80px;
                height: 100%;
                background-color: rgba(255,255,255,.1);
                text-align: center;
            }

        .gifticon {
            width: 44px;
            margin-top: 28px;
        }

        .ticket .right {
            width: 100%;
            height: 100%;
            padding-left: 105px;
            padding-right: 80px;
            display: flex;
            align-items: center;
        }

        .right .more {
            position: absolute;
            top: 0;
            right: 0;
            width: 70px;
            height: 100%;
            line-height: 20px;
            padding-top: 30px;
            text-align: center;
            border-left: 1px dashed rgba(255,255,255,.2);
        }

        .right > div {
            width: 100%;
        }

        .right .activename {
            font-size: 18px;
            font-weight: 600;
            white-space: nowrap;
            overflow: hidden;
            text-overflow: ellipsis;
            width: 100%;
        }

        .right .ticketname {
            white-space: nowrap;
            overflow: hidden;
            text-overflow: ellipsis;
            margin-top: 10px;
        }

        .right .time {
            font-size: 12px;
            white-space: nowrap;
            overflow: hidden;
            text-overflow: ellipsis;
        }

        .ticket.open {
            transform: translate(-210px,0);
        }

        .options li {
            display: inline-block;
            text-align: center;
            color: #222;
            width: 80px;
            border-right: 1px dashed rgba(255,255,255,.2);
            font-size: 14px;
            padding-top: 5px;
        }

        .icon_txt {
            line-height: 20px;
        }

        .op_icon {
            width: 50px;
            height: 50px;
            margin: 0 auto;
            background-repeat: no-repeat;
            background-size: cover;
            background-image: url(../../res/img/storesaler/spi_gift.png);
        }

        /*.ticket.c2 {
            background-color: #4883c5;
        }

        .ticket.c3 {
            background-color: #4b6d92;
        }

        .ticket.c4 {
            background-color: #347d76;
        }

        .ticket.c5 {
            background-color: #917a4e;
        }

        .ticket.c6 {
            background-color: #ca655b;
        }*/

        .ticket.unactive {
            background-color:#ccc !important;
        }

        .noresult {
            color: rgba(255,255,255,.6);
            display: none;
        }
        .storename {
            text-align:center;
            height:50px;
            line-height:51px;
        }
            .storename > span {
                padding:5px 15px;
                background-color:#202e3c;
                border-radius:2px;
            }
    </style>
</head>
<body>
    <div class="header">利郎活动礼券<i class="fa fa-plus"></i></div>
    <div class="wrap-page">
        <div class="page page-not-header-footer" id="index">
            <p class="storename"><span><%=mdmc %></span></p>            
            <div class="ticket_wrap">
            </div>
            <p class="noresult center-translate">对不起，暂时还没有礼品券..</p>
        </div>
    </div>
    <div class="footer">&copy;2016 利郎信息技术部 技术支持</div>

    <script type="text/html" id="ticket_temp">
        <div class="ticket {{if IsActive == "0"}}unactive{{/if}}" data-id="{{ID}}" style="background-color:{{TicketColor}}">
            <div class="item">
                <div class="left">
                    <img class="gifticon" src="../../res/img/storesaler/gifticon_w.png" />
                </div>
                <div class="right">
                    <div>
                        <p class="activename">{{ActiveName}}</p>
                        <p class="ticketname">{{TokenName}}</p>
                        <p class="time">{{starttime}} 至 {{endtime}}</p>
                        <div class="more">
                            更多<br />
                            选项
                        </div>
                    </div>
                </div>
            </div>
            <ul class="options">
                <li class="option_item" data-action="qrcode">
                    <div class="op_icon"></div>
                    <p class="icon_txt">预 览</p>
                </li>
                <li class="option_item" data-action="edit">
                    <div class="op_icon" style="background-position: 0 -50px;"></div>
                    <p class="icon_txt">编 辑</p>
                </li>
                <li class="option_item" data-action="items">
                    <div class="op_icon" style="background-position: 0 -100px;"></div>
                    <p class="icon_txt">礼品项</p>
                </li>
            </ul>
        </div>
    </script>

    <script type="text/javascript" src="../../res/js/jquery.js"></script>
    <script type="text/javascript" src="../../res/js/storesaler/fastclick.min.js"></script>
    <script type="text/javascript" src="../../res/js/template.js"></script>
    <script type="text/javascript" src="../../res/js/LeeJSUtils.min.js"></script>

    <script type="text/javascript">
        var mdid = "<%=mdid%>";

        $(document).ready(function () {
            FastClick.attach(document.body);
            LeeJSUtils.LoadMaskInit();

            BindEvents();
            loadTokens();
        });

        function BindEvents() {
            $(".ticket_wrap").on("click", ".more", function () {
                var par = $(this).parents(".ticket");

                var status = par.attr("data-open");
                if (status == "1") {
                    par.removeClass("open");
                    par.attr("data-open", "0");
                } else {
                    par.addClass("open");
                    par.attr("data-open", "1");
                }
            });

            $(".ticket_wrap").on("click", ".option_item", function () {
                var action = $(this).attr("data-action");
                var par = $(this).parents(".ticket");
                switch (action) {
                    case "qrcode":                        
                        window.location.href = "ticketQRCode.aspx?tid=" + par.attr("data-id");
                        break;
                    case "edit":
                        window.location.href = "SaveTokenInfo.aspx?tid=" + par.attr("data-id");
                        break;
                    case "items":
                        window.location.href = "giftItemList.aspx?tid=" + par.attr("data-id");
                        break;
                    default:
                        break;
                }
            });

            //新建动作
            $(".header .fa-plus").click(function () {
                window.location.href = "SaveTokenInfo.aspx";
            });
        }

        //加载活动礼券信息
        function loadTokens() {
            LeeJSUtils.showMessage("loading", "正在加载..");
            setTimeout(function () {
                $.ajax({
                    type: "POST",
                    cache: false,
                    timeout: 5 * 1000,
                    data: { mdid: mdid },
                    contentType: "application/x-www-form-urlencoded; charset=utf-8",
                    url: "/OA/project/storesaler/wxActiveTokenCore.ashx?ctrl=LoadTokenInfo",
                    success: function (msg) {
                        //console.log(msg);
                        if (msg.indexOf("Error:") > -1)
                            LeeJSUtils.showMessage("error", msg.replace("Error:", ""));
                        else {
                            var data = JSON.parse(msg);
                            if (data.list.length == 0) {
                                $(".ticket_wrap").hide();
                                $(".noresult").show();
                            }
                            else {
                                var rows = data.list, html = "";
                                for (var i = 0; i < rows.length; i++) {
                                    var row=rows[i];
                                    //row.xh = "c" + ((i) % 6 + 1);
                                    html += template("ticket_temp", row);                                    
                                }//end for                                
                                $(".ticket_wrap").empty().html(html);                                
                            }

                            $("#leemask").hide();
                        }
                    },
                    error: function (XMLHttpRequest, textStatus, errorThrown) {
                        LeeJSUtils.showMessage("error", "您的网络出问题啦..");
                    }
                });
            }, 50);
        }
    </script>
</body>
</html>
