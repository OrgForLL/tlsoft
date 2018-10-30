<%@ Page Language="C#" %>

<%@ Import Namespace="nrWebClass" %>
<%@ Import Namespace="System.Data" %>
<%@ Import Namespace="System.Data.SqlClient" %>
<%@ Import Namespace="System.Collections.Generic" %>
<!DOCTYPE html>
<script runat="server"> 
    public string accountNo = "", errorMsg = "", cardSnr = "", userName = "", deptName = "", headImg = "";
    private string CFSFConnStr = "server=192.168.35.30;uid=lllogin;pwd=rw1894tla;database=CFSF";
    private string DBConnStr = "server=192.168.35.10;uid=ABEASD14AD;pwd=+AuDkDew;database=tlsoft";
    protected void Page_Load(object sender, EventArgs e)
    {
        if (clsWXHelper.CheckQYUserAuth(true))
        {            
            accountNo = clsWXHelper.GetAuthorizedKey(5);
            if (accountNo == "" || accountNo == "0")
                errorMsg = "NoSys:对不起，您还未开通工卡系统！";
            else
            {
                using (LiLanzDALForXLM dal30 = new LiLanzDALForXLM(CFSFConnStr))
                {
                    string str_sql = @"select top 1 a.accountno,a.customername,isnull(b.deptname,'--') deptname,a.cardsnr 
                                        from tb_customer a 
                                        left join tb_department b on a.deptno=b.deptno
                                        where accountno='" + accountNo + "'";
                    DataTable dt;
                    string errinfo = dal30.ExecuteQuery(str_sql, out dt);
                    if (errinfo != "")
                        errorMsg = "Error:查询数据时发生错误 " + errinfo;
                    else
                        if (Convert.ToString(dt.Rows[0]["cardsnr"]) == "")
                            errorMsg = "Warn:对不起找不到您的工卡信息【" + accountNo + "】,请联系IT解决！";
                        else
                        {
                            cardSnr = Convert.ToString(dt.Rows[0]["cardsnr"]);
                            userName = Convert.ToString(dt.Rows[0]["customername"]);
                            deptName = Convert.ToString(dt.Rows[0]["deptname"]);
                            string customersId = Convert.ToString(Session["qy_customersid"]);
                            //取头像
                            using (LiLanzDALForXLM dal10 = new LiLanzDALForXLM(DBConnStr))
                            {
                                str_sql = @"select top 1 avatar from wx_t_customers where id='" + customersId + "'";
                                object scalar;
                                errinfo = dal10.ExecuteQueryFast(str_sql, out scalar);
                                if (Convert.ToString(scalar) != "")
                                {
                                    string imgUrlHead = clsConfig.GetConfigValue("OA_WebPath");
                                    headImg = getMiniImage(ref imgUrlHead, Convert.ToString(scalar));
                                }
                                else
                                    headImg = "../../res/img/storesaler/defaulticon2.png";
                            }
                        }
                    dt.Clear(); dt.Dispose();
                }//end using
            }
        }
        else
            clsWXHelper.ShowError("鉴权失败！");

        errorMsg = errorMsg.Replace("\"", "");
    }

    /// <summary>
    /// 获取缩略图路径
    /// </summary>
    /// <param name="imgUrlHead"></param>
    /// <param name="sourceImage"></param>
    /// <returns></returns>
    private string getMiniImage(ref string imgUrlHead, string sourceImage)
    {
        if (clsWXHelper.IsWxFaceImg(sourceImage)) return clsWXHelper.GetMiniFace(sourceImage);
        else return string.Concat(imgUrlHead, sourceImage);
    }
</script>
<html>
<head runat="server">
    <meta charset="utf-8" />
    <meta name="viewport" content="width=device-width,initial-scale=1,user-scalable=0,maximum-scale=1" />
    <meta name="format-detection" content="telephone=no" />
    <meta name="apple-mobile-web-app-capable" content="yes" />
    <title>我的电子工卡</title>
    <link rel="stylesheet" href="../../res/css/sweet-alert.css" />
    <link type="text/css" rel="stylesheet" href="../../res/css/LeePageSlider.css" />
    <style type="text/css">
        #main {
            background-color: rgb(242,242,242);
            background-image: url(../../res/img/storesaler/express_bg4.jpg);
            background-size: cover;
            background-position: center center;
            background-repeat: no-repeat;
        }

        .footer {
            height: 24px;
            line-height: 24px;
            font-size: 12px;
            color: #999;
            background-color: rgb(242,242,242);
        }

        .mywrap {
            width: 90vw;
            height: 88vh;
            background-color: rgba(255,255,255,.6);
            padding: 15px 20px;
            overflow-x: hidden;
            overflow-y: auto;
            -webkit-overflow-scrolling: touch;
        }

        .back-image {
            background-position: center center;
            background-repeat: no-repeat;
            background-size: cover;
        }

        .headimg {
            width: 70px;
            height: 70px;
            border-radius: 50%;
            margin: 0 auto;
            border: 2px solid #ebebeb;
            background-color: #ccc;
        }

        .username {
            text-align: center;
            font-size: 18px;
            font-weight: bold;
            margin: 10px 0 5px 0;
        }

        .deptname {
            text-align: center;
            font-size: 14px;
        }

            .deptname > span {
                background-color: #ab253d;
                color: #fff;
                border-radius: 2px;
                padding: 2px 8px;
            }

        .qrcode {
            padding: 10px;
            background-color: #fff;
            margin: 15px auto;
            display: block;
        }

        .tips {
            text-align: center;
            font-weight: bold;
            margin-bottom: 10px;
        }

        .title {
            font-weight: bold;
            margin-bottom: 10px;
        }

            .title > span {
                background-color: #000;
                padding: 2px 8px;
                border-radius: 2px;
                color: #fff;
            }

        .tip-item {
            line-height: 1.5;
        }
    </style>
</head>
<body>
    <div class="wrap-page">
        <div class="page" id="main">
            <div class="mywrap center-translate">
                <div class="back-image headimg" style="background-image: url(<%=headImg%>);"></div>
                <p class="username"><%=userName %></p>
                <p class="deptname"><span><%=deptName %></span></p>
                <img class="qrcode" src="http://tm.lilanz.com/oa/project/StoreSaler/GetQrCode.aspx?code=cardSnr:<%=cardSnr %>" />
                <p class="tips">请让前台工作人员扫描上方二维码</p>
                <p class="title"><span>注意事项</span></p>
                <p class="tip-item">1、利郎员工使用此功能，必须先开通工卡系统</p>
                <p class="tip-item">2、到前台领取快件时，如果您忘记携带工卡，也可以直接打开此页面让前台工作人员扫一扫即可；</p>
                <p class="tip-item">3、如果有任何疑问可以联系IT解决；</p>
            </div>
        </div>
    </div>

    <script type="text/javascript" src="../../res/js/sweet-alert.min.js"></script>
    <script type="text/javascript" src="../../res/js/LeeJSUtils.min.js"></script>
    <script type="text/javascript">
        var errorMsg = "<%=errorMsg%>";
        window.onload = function () {
            LeeJSUtils.stopOutOfPage(".mywrap", true);

            if (errorMsg.indexOf("NoSys:") > -1) {
                swal({
                    title: "",
                    text: errorMsg.replace("NoSys:", ""),
                    type: "warning",
                    confirmButtonColor: "#DD6B55",
                    confirmButtonText: "自助开通",
                    showCancelButton: true,
                    cancelButtonText: "取消",
                }, function (isConfirm) {
                    if (confirm)
                        window.location.href = "http://tm.lilanz.com/oa/project/BandToSystem/SystemBand.aspx?systemid=5&closepag=1";
                    else
                        WeixinJSBridge.call('closeWindow');
                });
            } else if (errorMsg.indexOf("Warn:") > -1) {
                swal({
                    title: "",
                    text: errorMsg.replace("Warn:", ""),
                    type: "warning",
                    confirmButtonColor: "#DD6B55",
                    confirmButtonText: "知道了！"
                }, function (isConfirm) {
                    WeixinJSBridge.call('closeWindow');
                });
            } else if (errorMsg != "") {
                swal({
                    title: "",
                    text: errorMsg.replace("error:", ""),
                    type: "error",
                    confirmButtonColor: "#DD6B55",
                    confirmButtonText: "确定"
                }, function (isConfirm) {
                    WeixinJSBridge.call('closeWindow');
                });
            }
        }
    </script>
</body>
</html>
