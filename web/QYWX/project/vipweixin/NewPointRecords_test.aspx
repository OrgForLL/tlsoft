<%@ Page Language="C#" %>

<%@ Import Namespace="nrWebClass" %>
<%@ Import Namespace="System.Data" %>
<%@ Import Namespace="System.Data.SqlClient" %>
<%@ Import Namespace="System.Collections.Generic" %>

<!DOCTYPE html>
<script runat="server">
    private String ConfigKeyValue = "5"; //利郎男装
    public string vid = "";
    private string ChatProConnStr = System.Configuration.ConfigurationManager.ConnectionStrings["Conn"].ConnectionString;

    protected void Page_Load(object sender, EventArgs e)
    {
        vid = "3198605";
        return;
        if (clsWXHelper.CheckUserAuth(ConfigKeyValue, "openid"))
        {
            //生成访问日志
            clsWXHelper.WriteLog(string.Format("openid：{0} ，vipid：{1} 。访问功能页[{2}]", Convert.ToString(Session["openid"]), Convert.ToString(Session["vipid"])
                            , "积分查询"));

            if (Session["vipid"].ToString() == "0" || Session["vipid"].ToString() == "")
            {
                clsWXHelper.ShowError("对不起，您还不是利郎会员。");
            }
            else
            {
                vid = Convert.ToString(Session["vipid"]);
            }

            //using (LiLanzDALForXLM dal = new LiLanzDALForXLM(ChatProConnStr))
            //{
            //    string str_sql = @"select top 1 isnull(a.vipid,0) vipid from wx_t_vipbinging a where a.wxopenid=@openid";
            //    List<SqlParameter> paras = new List<SqlParameter>();
            //    paras.Add(new SqlParameter("@openid", Session["openid"].ToString()));
            //    DataTable dt = null;
            //    string errinfo = dal.ExecuteQuerySecurity(str_sql, paras, out dt);
            //    if (errinfo == "")
            //    {
            //        if (dt.Rows.Count == 0)
            //            clsWXHelper.ShowError("对不起，您还未关注利郎男装公众号。");
            //        else
            //        {
            //            vid=dt.Rows[0]["vipid"].ToString();
            //            if ( vid == "0" || vid == "")
            //                clsWXHelper.ShowError("对不起，您还不是利郎会员。");
            //        }
            //    }
            //    else
            //        clsWXHelper.ShowError("查询微信用户信息时出错！ " + errinfo);
            //}
        }
        else
            clsWXHelper.ShowError("微信鉴权失败！");
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
            background-color: #eee;
            color: #323232;
        }

        .header {
            background-color: #f9f9f9;
            border-bottom: 1px solid #e7e7e7;
            line-height: 50px;
            font-size: 1.3em;
        }

        .fa-angle-left {
            position: absolute;
            top: 0;
            left: 0;
            height: 100%;
            font-size: 1.3em;
            line-height: 50px;
            padding: 0 20px;
        }

            .fa-angle-left:hover {
                background-color: rgba(0,0,0,.1);
            }

        .page {
            background-color: #f9f9f9;
            padding: 0;
        }

        .pointsul {
            background-color: #fff;
            margin-top: 1px;
        }

            .pointsul li {
                position: relative;
                padding: 10px;
                border-bottom: 1px solid #e7e7e7;
            }

        .pval {
            position: absolute;
            top: 50%;
            right: 15px;
            transform: translate(0,-50%);
            -webkit-transform: translate(0,-50%);
            font-weight: bold;
            color: #eb8732;
            font-size: 1.1em;
        }

        .pointsul li.title {
            background-color: #f9f9f9;
            padding: 10px;
            border-bottom: none;
        }

        .pmark p:first-child {
            font-size: 1.1em;
            color: #444547;
        }

        .pmark p:last-child {
            font-size: 0.9em;
            color: #999;
            padding: 5px 0 0 0;
        }

        .month {
            font-weight: bold;
        }

        .t1 {
            color: #888;
            margin: 0 10px;
        }

            .t1 span {
                color: #eb8732;
                margin-left: 5px;
            }

       /*提示层*/
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
            display: none;
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
        .hint {
            color:#555;
            font-size:1.1em;
            white-space:nowrap;
            display:none;
        }
    </style>
</head>
<body>
    <div class="header">
        <i class="fa fa-angle-left" onclick="javascript:window.history.back(-1);"></i>
        近一年的积分记录
    </div>
    <div class="wrap-page">
        <div class="page page-not-header">
            <ul class="pointsul" id="pointsul">
            </ul>
            <div class="hint center-translate">Sorry,您暂时无相关积分记录!</div>
        </div>
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
    <script type="text/javascript" src="../../res/js/jquery.js"></script>
    <script type="text/javascript" src="../../res/js/StoreSaler/fastclick.min.js"></script>
    <script type="text/javascript">
        $(function () {
            FastClick.attach(document.body);
            loadData();
        });

        function loadData() {
            showLoader("loading", "正在加载数据...");
            $.ajax({
                url: "../../WebBLL/FWHUserCenterCore.aspx?ctrl=LoadNewPointRecords2",
                type: "POST",
                dataType: "text",
                data: { vipid: "<%=vid%>" },
                timeout: 10000,
                error: function (XMLHttpRequest, textStatus, errorThrown) {
                    showLoader("error", "您的网络好像出了点问题,请稍后重试...");
                },
                success: function (result) {
                    if (result.indexOf("Error:") > -1)
                        showLoader("error", result.replace("Error:", ""));
                    else {
                        var data = result.replace("Successed", "");
                        if (data != "") {
                            data = JSON.parse(data);
                            var titleTemp = "<li class='title'><span class='month'>#month#</span><span class='t1'>累积<span>#yf_in#</span></span><span class='t1'>兑换<span>#yf_out#</span></span>";
                            var itemTemp = "<li><div class='pmark'><p>#remark#</p><p>#time#</p></div><div class='pval'>#val#</div></li>";
                            var mm = "", row, htmlStr = "", itemStr = "";
                            for (i = 0; i < data.rows.length; i++) {
                                row = data.rows[i];
                                if (mm == row.yf) {
                                    itemStr = itemTemp.replace("#remark#", row.pname).replace("#time#", row.eventtime);
//                                    if (row.flag == "True") {
                                    if (parseInt(row.changeval) > 0) {
                                        itemStr = itemStr.replace("#val#", "+" + row.changeval);
                                    }
                                    else {
                                        itemStr = itemStr.replace("#val#", row.changeval);
                                    }
                                    htmlStr += itemStr;
                                } else {
                                    htmlStr += titleTemp.replace("#month#", row.nf + "年" + row.yf + '月').replace("#yf_in#", row.ip).replace("#yf_out#", row.op);
                                    mm = row.yf;
                                    i--;
                                }
                            }//end for
                            $("#pointsul").children().remove();
                            $("#pointsul").append(htmlStr);                            
                        } else {
                            $(".hint").show();
                        }
                        showLoader("successed", "加载成功!");
                    }
                }
            });
        }

        //提示层
        function showLoader(type, txt) {
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
                case "thunder":
                    $(".mask .fa").removeAttr("class").addClass("fa fa-2x fa-bolt");
                    $("#loadtext").text(txt);
                    $(".mask").show();
                    setTimeout(function () {
                        $(".mask").fadeOut(400);
                    }, 1000);
                    break;
                case "sign-success":
                    $(".mask .fa").removeAttr("class").addClass("fa fa-2x fa-check-circle");
                    $("#loadtext").text(txt);
                    $(".mask").show();
                    setTimeout(function () {
                        $(".mask").fadeOut(400);
                    }, 1000);
                    break;
            }
        }
    </script>
</body>
</html>

