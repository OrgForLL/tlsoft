<%@ Page Language="C#" %>

<%@ Import Namespace="nrWebClass" %>
<%@ Import Namespace="System.Data.SqlClient" %>
<%@ Import Namespace="System.Data" %>
<%@ Import Namespace="System.Collections.Generic" %>

<!DOCTYPE html>
<script runat="server">
    private string ConfigKeyValue = "5";//利郎男装
    private string WXDBConstr = "server='192.168.35.62';uid=sa;pwd=ll=8727;database=weChatPromotion";
    private string DBConstr = "server=192.168.35.10;uid=ABEASD14AD;pwd=+AuDkDew;database=tlsoft";
    private string TestDBConstr = "server=192.168.35.23;uid=lllogin;pwd=rw1894tla;database=tlsoft";

    public string openid = "", wxid = "", wxnick = "", wxhead = "";
    protected void Page_Load(object sender, EventArgs e)
    {
        if (clsWXHelper.CheckUserAuth(ConfigKeyValue, "openid"))
        {
            openid = Convert.ToString(Session["openid"]);
            using (LiLanzDALForXLM dal10 = new LiLanzDALForXLM(DBConstr))
            {
                string str_sql = "select top 1 id,wxnick,wxheadimgurl from wx_t_vipbinging where wxopenid=@openid and objectid=1";
                List<SqlParameter> paras = new List<SqlParameter>();
                paras.Add(new SqlParameter("@openid", openid));
                DataTable dt;
                string errinfo = dal10.ExecuteQuerySecurity(str_sql, paras, out dt);
                if (errinfo == "") {
                    wxid = Convert.ToString(dt.Rows[0]["id"]);
                    wxnick = Convert.ToString(dt.Rows[0]["wxnick"]);
                    wxhead = Convert.ToString(dt.Rows[0]["wxheadimgurl"]);
                }
                else
                    clsSharedHelper.WriteErrorInfo(errinfo);
            }//end using 10
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
    <title>我的兑换记录</title>
    <link type="text/css" rel="stylesheet" href="../../res/css/LeePageSlider.css" />
    <link type="text/css" rel="stylesheet" href="../../res/css/font-awesome.min.css" />
    <style type="text/css">
        .page {
            background-color: #efefef;
            bottom: 24px;
        }

        body {
            color: #363c44;
            font-family: "Helvetica Neue",Arial,"Microsoft Yahei",Helvetica,sans-serif,Lato;
            -webkit-font-smoothing: antialiased;
        }

        .footer {
            color: #aaa;
            height: 24px;
            line-height: 25px;
            background-color: #efefef;
            font-size: 12px;
        }

        #index {
            padding:10px;
        }

        .item {
            padding: 15px 15px 0 15px;
            border-right: 1px solid #eee;
            margin-bottom: 10px;
            border-radius: 10px;
            background-color: #fff;
        }

        .prizename {
            padding: 5px 0;
            border-bottom: 1px dashed #ddd;
        }

        .time {
            text-align: right;
            height: 34px;
            line-height: 34px;
        }

        .noresult {
            display: none;
        }
        .userinfo {
            border-radius:10px;
            width:80px;            
            margin-bottom:10px;
            position:relative;
            margin:0 auto 10px auto;
            border-bottom:1px solid #eee;
            border-right:1px solid #eee;
        }
        .wxhead {
            background-repeat:no-repeat;
            background-size:cover;
            background-position:center center;
            width:64px;
            height:64px;
            margin:0 auto;
            border:3px solid #fff;
            border-radius:50%;
        }
        .wxnick {
            text-align:center;
            white-space:nowrap;
            overflow:hidden;
            text-overflow:ellipsis;
            font-size:14px;
            line-height:20px;
            background-color:#363c44;
            color:#fff;
            padding:0 5px;
            border-radius:2px;
            margin-top:10px;
        }
    </style>
</head>
<body>
    <div class="wrap-page">
        <div class="page page-not-footer" id="index">
            <div class="userinfo">
                <div class="wxhead" style="background-image:url(<%=wxhead%>)"></div>
                <p class="wxnick"><%=wxnick %></p>
            </div>
            <div class="prize_wrap">
                <!--<div class="item">
                    <h1 class="activename">活动名称</h1>
                    <p class="prizename">礼品名称礼品名称礼品名称礼品名称礼品名称礼品名称礼品名称礼品名称礼品名称礼品名称礼品名称</p>
                    <p class="time">兑换时间：<span>2016-12-12 08:20:20</span></p>
                </div>
                <div class="item">
                    <h1 class="activename">活动名称</h1>
                    <p class="prizename">礼品名称</p>
                    <p class="time">兑换时间：<span>2016-12-12 08:20:20</span></p>
                </div>
                <div class="item">
                    <h1 class="activename">活动名称</h1>
                    <p class="prizename">礼品名称</p>
                    <p class="time">兑换时间：<span>2016-12-12 08:20:20</span></p>
                </div>
                <div class="item">
                    <h1 class="activename">活动名称</h1>
                    <p class="prizename">礼品名称</p>
                    <p class="time">兑换时间：<span>2016-12-12 08:20:20</span></p>
                </div>-->
            </div>

            <p class="noresult center-translate">对不起，您暂时无兑换记录..</p>
        </div>
    </div>
    <div class="footer">
        &copy;2016 利郎（中国）有限公司
    </div>

    <script type="text/html" id="item_temp">
        <div class="item">
            <h1 class="activename">{{ActiveName}}</h1>
            <p class="prizename">{{PrizeName}}</p>
            <p class="time">兑换时间：<span>{{CreateTime}}</span></p>
        </div>
    </script>

    <script type="text/javascript" src="../../res/js/jquery.js"></script>
    <script type="text/javascript" src="../../res/js/template.js"></script>
    <script type="text/javascript" src="../../res/js/LeeJSUtils.min.js"></script>
    <script type='text/javascript' src='../../res/js/StoreSaler/fastclick.min.js'></script>
    <script type="text/javascript">
        var openid = "<%=openid%>", wxid = "<%=wxid%>";
        var tid = "";
        $(document).ready(function () {
            LeeJSUtils.LoadMaskInit();
            loadDatas();

            tid = LeeJSUtils.GetQueryParams("tid");
            if (tid == "" || tid == "0")
                LeeJSUtils.showMessage("warn","请检查参数 tid");
        });        

        function loadDatas() {
            LeeJSUtils.showMessage("loading", "正在加载，请稍候...");
            setTimeout(function () {
                $.ajax({
                    type: "POST",
                    cache: false,
                    timeout: 10 * 1000,
                    data: { wxID: wxid, ActiveTokenID:tid },
                    contentType: "application/x-www-form-urlencoded; charset=utf-8",
                    url: "/OA/project/storesaler/wxActiveTokenCore.ashx?ctrl=GetPayedInfo",
                    success: function (msg) {
                        //console.log(msg);
                        if (msg.indexOf("Error:") > -1)
                            LeeJSUtils.showMessage("error", msg.replace("Error:", ""));
                        else {
                            var rows = JSON.parse(msg).list;
                            if (rows.length == 0) {
                                $(".noresult").show();                                
                            } else {
                                var html = "";
                                for (var i = 0; i < rows.length; i++) {
                                    html += template("item_temp", rows[i]);
                                }//end for

                                $(".prize_wrap").html(html);
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
