<%@ Page Language="C#" %>

<%@ Import Namespace="nrWebClass" %>
<%@ Import Namespace="System.Data" %>
<%@ Import Namespace="System.Data.SqlClient" %>
<%@ Import Namespace="System.Collections.Generic" %>

<!DOCTYPE html>
<script runat="server">
    public string mdid = "", wxid = "";
    public String msg = "", openid = "", headimg = "", username = "", oldMdmc = "", newMdmc = "";
    private String ConfigKeyValue = "5"; //利郎男装
    private String DBConnStr = "server=192.168.35.10;uid=ABEASD14AD;pwd=+AuDkDew;database=tlsoft";
    protected void Page_Load(object sender, EventArgs e)
    {
        mdid = Convert.ToString(Request.Params["mdid"]);
        if (mdid == "" || mdid == "0" || mdid == null)
            msg = "Error:请检查相关参数！";
        else
        {
            if (clsWXHelper.CheckUserAuth(ConfigKeyValue, "openid"))
            {
                openid = Convert.ToString(Session["openid"]);                
                using (LiLanzDALForXLM dal10 = new LiLanzDALForXLM(DBConnStr))
                {
                    string sql = @"select top 1 a.id,a.wxheadimgurl,isnull(b.id,0) vipid,b.xm,
                                    isnull(md.mdmc,'未知门店') om,nm.mdmc nm,isnull(nm.mdid,0) newMdid,isnull(b.mdid,0) oldMdid
                                    from wx_t_vipbinging a
                                    left join yx_t_vipkh b on a.vipid=b.id
                                    left join t_mdb md on b.mdid=md.mdid
                                    left join t_mdb nm on nm.mdid=@mdid and nm.ty=0
                                    where a.objectid=1 and a.wxopenid=@openid";
                    DataTable dt;
                    List<SqlParameter> paras = new List<SqlParameter>();
                    paras.Add(new SqlParameter("@mdid",mdid));
                    paras.Add(new SqlParameter("@openid", openid));
                    string errinfo = dal10.ExecuteQuerySecurity(sql, paras, out dt);
                    if (errinfo != "")
                        msg = "Error:" + errinfo;
                    else if (Convert.ToInt32(dt.Rows[0]["vipid"]) == 0) {
                        msg = "Error:对不起，您还不是利郎VIP会员！";
                    }
                    else{
                        wxid = Convert.ToString(dt.Rows[0]["id"]);                        
                        headimg = Convert.ToString(dt.Rows[0]["wxheadimgurl"]);                        
                        headimg = headimg == "" ? "../../res/img/vipweixin/defaulticon2.png" : headimg;
                        username = Convert.ToString(dt.Rows[0]["xm"]);
                        oldMdmc = Convert.ToString(dt.Rows[0]["om"]);
                        if (Convert.ToInt32(dt.Rows[0]["newMdid"]) == 0)
                            msg = "Error:请检查参数的有效性！";
                        else if (Convert.ToInt32(dt.Rows[0]["oldMdid"]) == Convert.ToInt32((dt.Rows[0]["newMdid"])))
                            msg = "Error:已经设置了【" + Convert.ToString(dt.Rows[0]["nm"]) + "】作为您专属客服门店！";
                        else
                            newMdmc = Convert.ToString(dt.Rows[0]["nm"]);                        
                    }                        
                }//end using
            }
        }
    }    
</script>
<html lang="zh-cn">
<head>
    <meta charset="utf-8" />
    <meta name="viewport" content="width=device-width,initial-scale=1,user-scalable=0,maximum-scale=1" />
    <meta name="format-detection" content="telephone=no" />
    <meta name="apple-mobile-web-app-capable" content="yes" />
    <meta name="apple-mobile-web-app-status-bar-style" content="black" />
    <title>门店变更操作</title>
    <link type="text/css" rel="stylesheet" href="../../res/css/LeePageSlider.css" />
    <link type="text/css" rel="stylesheet" href="../../res/css/font-awesome.min.css" />
    <link rel="stylesheet" href="../../res/css/sweet-alert.css" />
    <style type="text/css">
        .page {
            padding: 0;
            padding: 70px 20px 20px 20px;
            background-color: #fff;
        }

        .new-store {
            height: 160px;
            background-color: #38c4a9;
            border-radius: 4px;
            border: 1px solid #eee;
        }

        .old-store {
            height: 160px;
            background-color: #f0f0f0;
            border-radius: 4px;
            border: 1px solid #eee;
        }

        .icon {
            width: 50px;
            height: 50px;
            background-repeat: no-repeat;
            background-size: cover;
            background-image: url(../../res/img/vipweixin/store_icon2.png);
            border-radius: 50%;
            border: 2px solid #fff;
            margin: 35px auto 20px auto;
        }

        .old-store .icon {
            background-position: 0 -46px;
            border: 2px solid #38c4a9;
        }

        .store_name {
            text-align: center;
            color: #fff;
            font-size: 16px;
            font-weight: 600;
        }

        .old-store .store_name {
            color: #38c4a9;
        }

        .down-arrow {
            width: 30px;
            height: 30px;
            background-repeat: no-repeat;
            background-size: cover;
            background-image: url(../../res/img/vipweixin/down-arrow.png);
            margin: 5px auto;
        }

        .tips {
            padding: 20px;
            text-indent: 10px;
            padding-bottom: 0;
        }

        .user-info {
            position: fixed;
            top: 0;
            left: 0;
            width: 100%;
            height: 50px;
            line-height: 50px;
            z-index: 5000;
            padding: 0 20px;
            background-color: rgba(18,149,124,0.8);
            color: #fff;
            border-bottom: 1px solid #eee;
            box-sizing: content-box;
            font-weight: 600;
        }

        .headimg {
            width: 40px;
            height: 40px;
            background-repeat: no-repeat;
            background-size: cover;
            background-position: center center;
            border-radius: 50%;            
            vertical-align: middle;
            display: inline-block;
            margin-right: 5px;
            border: 2px solid #fff;
        }

        .footer > .btn {
            width: 38%;
            display: inline-block;
            background-color: #38c4a9;
            color: #fff;
            height: 40px;
            line-height: 40px;
            font-size: 16px;
            margin-top: 10px;
            border-radius: 4px;
            font-weight: bold;
        }

        .no.btn {
            background-color: #f0f0f0;
            color: #38c4a9;
            margin-left: 15px;
        }
    </style>
</head>
<body>
    <div class="user-info">
        <div class="headimg" style="background-image:url(<%=headimg%>)"></div>
        <span>尊敬的利郎VIP：<%=username %></span>
    </div>
    <div class="wrap-page">
        <div class="page page-not-footer" id="main">
            <div class="old-store">
                <div class="icon"></div>
                <div class="store_name"><%=oldMdmc %></div>
            </div>
            <div class="down-arrow"></div>
            <div class="new-store">
                <div class="icon"></div>
                <div class="store_name"><%=newMdmc %></div>
            </div>

            <div class="tips">
                尊敬的利郎VIP，系统发现您最近两笔消费均发生在【<%=newMdmc %>】，为了给您提供更好的服务，是否将您的客户服务门店指定为【<%=newMdmc %>】？
            </div>
        </div>
    </div>
    <div class="footer">
        <a class="btn yes" href="javascript:transfromVIP()">是</a>
        <a class="btn no" href="javascript:WeixinJSBridge.call('closeWindow');">否</a>
    </div>
    <i style="display:none;" class="fa fa-angle-up"></i>
    <script type="text/javascript" src="../../res/js/jquery.js"></script>
    <script type="text/javascript" src="../../res/js/LeeJSUtils.min.js"></script>
    <script type="text/javascript" src="../../res/js/sweet-alert.min.js"></script>
    <script type="text/javascript">
        var msg = "<%=msg%>", mdid = "<%=mdid%>", wxid = "<%=wxid%>";
        window.onload = function () {
            LeeJSUtils.LoadMaskInit();
            LeeJSUtils.stopOutOfPage("#main", true);

            if (msg.indexOf("Error:") > -1)
                swal({
                    title: "",
                    text: msg.replace("Error:", ""),
                    type: "warning",
                    confirmButtonColor: "#DD6B55",
                    confirmButtonText: "知道了！"
                }, function (isConfirm) {
                    WeixinJSBridge.call('closeWindow');
                });
        }

        function transfromVIP() {
            LeeJSUtils.showMessage("loading", "正在处理，请稍候..");
            setTimeout(function () {
                $.ajax({
                    type: "POST",
                    timeout: 10*1000,
                    contentType: "application/x-www-form-urlencoded; charset=utf-8",
                    url: "VIPtransCore.aspx",
                    data: { mdid:mdid, wxid:wxid },
                    success: function (msg) {
                        if (msg.indexOf("Error:") > -1)
                            LeeJSUtils.showMessage("error", msg.replace("Error:", ""));
                        else if (msg == "Successed") {
                            swal({
                                title: "操作成功！",
                                text: "设置客服门店成功！",
                                type: "success",
                                confirmButtonColor: "#59a714",
                                confirmButtonText: "确定"
                            }, function (isConfirm) {
                                WeixinJSBridge.call('closeWindow');
                            });
                        }
                    },
                    error: function (XMLHttpRequest, textStatus, errorThrown) {
                        LeeJSUtils.showMessage("error","您的网络出问题啦..");
                    }
                });//end AJAX
            }, 200);
        }
    </script>
</body>
</html>
