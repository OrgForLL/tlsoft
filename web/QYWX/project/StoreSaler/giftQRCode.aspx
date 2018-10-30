<%@ Page Language="C#" %>

<%@ Import Namespace="nrWebClass" %>
<%@ Import Namespace="System.Data.SqlClient" %>
<%@ Import Namespace="System.Data" %>
<%@ Import Namespace="System.Collections.Generic" %>

<!DOCTYPE html>
<script runat="server">
    private string ConfigKeyValue = "5";//利郎男装    
    public List<string> wxConfig;//微信OPEN_JS 动态生成的调用参数
    private string WXDBConstr = "server='192.168.35.62';uid=sa;pwd=ll=8727;database=weChatPromotion";
    public Dictionary<string, object> infos = new Dictionary<string,object>();
    
    protected void Page_Load(object sender, EventArgs e)
    {
        //传入参数wx_t_ActiveTokenPrize.id[pid]
        string pid = Convert.ToString(Request.Params["pid"]);
        if (pid == "" || pid == "0")
            clsWXHelper.ShowError("请检查参数！ pid");
        else {
            using (LiLanzDALForXLM dal = new LiLanzDALForXLM(WXDBConstr)) {
                string str_sql = @"select top 1 prizename,remark,isactive,buycount,maxbuycount,onebuymaxcount
                                from wx_t_activetokenprize
                                where id=@pid";
                List<SqlParameter> paras = new List<SqlParameter>();
                paras.Add(new SqlParameter("@pid", pid));
                DataTable dt;
                string errinfo = dal.ExecuteQuerySecurity(str_sql, paras, out dt);
                if (errinfo == "")
                    if (dt.Rows.Count == 0)
                        clsWXHelper.ShowError("请检查参数！！pid");
                    else {
                        infos.Add("prizename",Convert.ToString(dt.Rows[0]["prizename"]));
                        infos.Add("remark", Convert.ToString(dt.Rows[0]["remark"]));
                        infos.Add("isactive", Convert.ToString(dt.Rows[0]["isactive"]));
                        infos.Add("buycount", Convert.ToString(dt.Rows[0]["buycount"]));
                        infos.Add("maxbuycount", Convert.ToString(dt.Rows[0]["maxbuycount"]));
                        infos.Add("onebuymaxcount", Convert.ToString(dt.Rows[0]["onebuymaxcount"]));

                        wxConfig = clsWXHelper.GetJsApiConfig(ConfigKeyValue);
                    }
                else
                    clsWXHelper.ShowError(errinfo);
            }//end using
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
    <title></title>
    <link type="text/css" rel="stylesheet" href="../../res/css/LeePageSlider.css" />
    <link type="text/css" rel="stylesheet" href="../../res/css/font-awesome.min.css" />
    <style type="text/css">
        body {
            line-height: 1;
            color: #363c44;
        }

        .page {
            /*background-color: rgb(255,146,1);*/
            background-color:#ffb514;
            padding:10px 15px;
        }

        .gift_wrap {
            background-color: #fff;
            border-radius: 6px;
            padding: 50px 10px 10px 10px;
            position: relative;
            width:100%;
            z-index:1010;  
            margin-top:50px;          
        }
        .logo {
            width:80px;
            position:absolute;
            left:50%;
            top:-40px;
            margin-left:-40px;
        }
        .pname {
            text-align:center;
            font-size:24px;
        }
        .pdesc {            
            padding:10px 20px;
            line-height:1.4;
            position:relative;
        }
        .qrcode {
            text-align:center;
            padding:15px 0;
            border-top:1px dashed #ccc;
            border-bottom:1px dashed #ccc;
            position:relative;
        }
            .qrcode > img {
                width: 44vw;
                padding: 8px;
                border: 1px solid #eee;                                
            }
            .qrcode > p span{
                border-radius:2px;
                background-color:#ccc;
                color:#fff;
                padding:3px 10px;
            }
        .status {
            height:51px;
            vertical-align:middle;
            padding-top:13px;
            text-align:right;
            border-top:1px dashed #ccc;
        }

            .status > span {
                background-color:rgb(43,162,69);
                color:#fff;
                height:24px;
                line-height:25px;
                padding:0 10px;
                display:inline-block;
                border-radius:4px;
            }

       .status .getcount {
            background-color:#ff6a00;
        }

        .maxbuy {
            text-align: center;
            color: #555;
            font-weight: 600;
            padding: 10px 0;
        }

        .pdesc:after,.qrcode:after {
            content: '';
            width: 16px;
            height: 16px;
            background-color: #ffb514;
            position: absolute;
            bottom: -8px;
            right: -18px;
            border-radius: 50%;
        }

        .pdesc:before,.qrcode:before {
            content: '';
            width: 16px;
            height: 16px;
            background-color: #ffb514;
            position: absolute;
            bottom: -8px;
            left: -18px;
            border-radius: 50%;
        }
    </style>
</head>
<body>
    <div class="wrap-page">
        <div class="page" id="index">
            <div class="gift_wrap">
                <img class="logo" src="../../res/img/storesaler/gifticon1.png" />
                <h1 class="pname"><%=infos["prizename"] %></h1>                
                <p class="pdesc">
                    <%=infos["remark"] %>
                </p>                
                <div class="qrcode">
                    <img src="" />
                    <p style="text-align:center;margin:10px 0 5px 0;"><span>请客人扫描上方二维码</span></p>                    
                </div>
                <p class="maxbuy">允许兑换次数：<span></span></p>
                <p class="status">
                    <span class="active">状态：<span></span></span>
                    <span class="getcount">领取人数：<span><%=infos["buycount"] %></span></span>
                </p>                
            </div>
        </div>
    </div>    
    <script type="text/javascript" src="../../res/js/jquery.js"></script>
    <script type="text/javascript" src="../../res/js/storesaler/fastclick.min.js"></script>
    <script type="text/javascript" src="../../res/js/LeeJSUtils.min.js"></script>
    <script type="text/javascript" src="http://res.wx.qq.com/open/js/jweixin-1.0.0.js"></script>

    <script type="text/javascript">
        var appIdVal = "<%=wxConfig[0]%>", timestampVal = "<%=wxConfig[1]%>", nonceStrVal = "<%=wxConfig[2]%>", signatureVal = "<%=wxConfig[3]%>";
        
        $(document).ready(function () {
            LeeJSUtils.LoadMaskInit();
            init();
        });

        function init() {
            var pid = LeeJSUtils.GetQueryParams("pid");
            var codeURL = "http://tm.lilanz.com/project/vipweixin/getGiftResult.aspx?pid=" + pid;
            codeURL = encodeURIComponent(codeURL);
            $(".qrcode>img").attr("src", "http://tm.lilanz.com/oa/project/StoreSaler/GetQrCode.aspx?code=" + codeURL);

            var isactive = "<%=infos["isactive"]%>", maxbuy = "<%=infos["maxbuycount"]%>", onebuymax = "<%=infos["onebuymaxcount"]%>";
            if (isactive == "True")
                $(".active>span").text("启用");
            else {
                $(".active>span").text("停用");
                $(".active").css("background-color", "#e6250b");
            }


            /*礼品设置有两个次数限制:一个是OneBuyMaxCount：表示单个人最多可兑换的次数 另一个是BuyMaxCount：该礼品总限制兑换次数

            如果这两个值都不大于0，则显示：
            允许兑换次数：不限。

            如果 BuyMaxCount > 0 则显示：
            限总兑换次数:XX次

            如果 OneBuyMaxCount > 0 则在之后再追加显示：
            (单人限Y次)*/
            if (parseInt(maxbuy) <= 0 && parseInt(onebuymax) <= 0)
                $(".maxbuy>span").text("不限");
            else if (parseInt(maxbuy) > 0) 
                $(".maxbuy").html("限总兑换次数：<span>" + maxbuy + "次</span>");
            
            if (parseInt(onebuymax) > 0)
                $(".maxbuy").html("限总兑换次数：<span>" + maxbuy + "次</span>（单人限" + onebuymax + "次）");
        }

        function loadPrizeInfo() {
            var pid = LeeJSUtils.GetQueryParams("pid");
            if (pid == "" || pid == "0")
                LeeJSUtils.showMessage("error", "请检查传入的参数!");
            else {
                LeeJSUtils.showMessage("loading", "正在加载..");
                setTimeout(function () {
                    $.ajax({
                        type: "POST",
                        cache: false,
                        timeout: 10 * 1000,
                        data: { ActiveTokenID:1 },
                        contentType: "application/x-www-form-urlencoded; charset=utf-8",
                        url: "/OA/project/storesaler/wxActiveTokenCore.ashx?ctrl=LoadPrizeInfo",
                        success: function (msg) {
                            console.log(msg);
                            if (msg.indexOf("Error:") > -1)
                                LeeJSUtils.showMessage("error", msg.replace("Error:", ""));
                            else {
                                var data = JSON.parse(msg);
                                if (data.list.length == 0)
                                    LeeJSUtils.showMessage("warn", "请检查参数! pid");
                                else {
                                    //生成二维码
                                    var codeURL = "http://tm.lilanz.com/project/vipweixin/getGiftResult.aspx?pid=1";
                                    codeURL = encodeURIComponent(codeURL);
                                    $(".qrcode>img").attr("src", "http://tm.lilanz.com/oa/project/StoreSaler/GetQrCode.aspx?code=" + codeURL);

                                    $("#leemask").hide();
                                }
                            }
                        },
                        error: function (XMLHttpRequest, textStatus, errorThrown) {
                            LeeJSUtils.showMessage("error", "您的网络出问题啦..");
                        }
                    });
                }, 50);
            }
        }
    </script>
</body>
</html>
