<%@ Page Language="C#" %>

<%@ Import Namespace="System.Collections" %>
<%@ Import Namespace="System.Collections.Generic" %>
<%@ Import Namespace="nrWebClass" %>
<%@ Import Namespace="System.Data" %>

<!DOCTYPE html>
<script runat="server">
    public string AppSystemKey = "", CustomerID = "", CustomerName = "", RoleName = "", SystemID = "3", managerStore = "";
    protected void Page_Load(object sender, EventArgs e)
    {
        if (clsWXHelper.CheckQYUserAuth(true))
        {
            AppSystemKey = clsWXHelper.GetAuthorizedKey(Convert.ToInt32(SystemID));
            RoleName = Convert.ToString(Session["RoleName"]);
            managerStore = Convert.ToString(Session["ManagerStore"]);
            if (AppSystemKey == "")
                clsWXHelper.ShowError("对不起，您还未开通全渠道系统权限！");
            //else
            //{
            //    if (RoleName == "zb" || RoleName == "my" || RoleName == "kf")
            //        Response.Redirect("managerNav.aspx?gourl=" + HttpUtility.UrlEncode(Request.Url.ToString()));
            //}
        }
    }
</script>
<html lang="en">
<head>
    <meta charset="utf-8" />
    <meta name="viewport" content="width=device-width,initial-scale=1,user-scalable=0,maximum-scale=1" />
    <meta name="format-detection" content="telephone=no" />
    <meta name="apple-mobile-web-app-capable" content="yes" />
    <meta name="apple-mobile-web-app-status-bar-style" content="black" />
    <title></title>
    <link type="text/css" rel="stylesheet" href="../../res/css/LeePageSlider.css" />
    <style type="text/css">
        .page {
            padding: 0;
        }

        .back-img {
            background-position: center center;
            background-size: cover;
            background-repeat: no-repeat;
        }

        .logoinfo {
            padding: 10px 0 0 10px;
        }

            .logoinfo .logoimg {
                width: 60px;
                height: 60px;
                display: inline-block;
            }

            .logoinfo .logotitle {
                height: 60px;
                display: inline-block;
                vertical-align: top;
            }

        .logotitle > img {
            height: 40px;
            margin-top: 10px;
        }

        .copyright {
            position: absolute;
            left: 0;
            bottom: 0;
            text-align: center;
            width: 100%;
            line-height: 24px;
            color: #ccc;
            z-index: 1000;
            font-size: 12px;
        }

        .menu_wrap {
            position: absolute;
            left: 0;
            width: 100%;
            height: 230px;
            bottom: 100px;
            padding-top: 10px;
            padding-right: 10px;
            font-size: 0;
            overflow-x: auto;
            overflow-y: hidden;
            white-space: nowrap;
            -webkit-overflow-scrolling: touch;
        }

            .menu_wrap::-webkit-scrollbar {
                /*display: none;*/
            }

        .m_group {
            width: 150px;
            height: 100%;
            margin-left: 10px;
            display: inline-block;
            font-size: 14px;
            vertical-align: top;
            color: #fff;
        }

        .m_item {
            height: 100px;
            background-color: #fc6747;
            border-radius: 4px;
            margin-bottom: 10px;
            position: relative;
            padding: 10px 0 0 10px;
        }

        .m_icon {
            width: 40px;
            height: 40px;
            background-repeat: no-repeat;
            background-size: cover;
            background-image: url(../../res/img/storesaler/ss_m_icons.png);
        }

        .m_name {
            position: absolute;
            left: 15px;
            bottom: 10px;
            font-weight: bold;
            font-size: 16px;
        }

        .m_item[data-menu='m2'] {
            background-color: #578ffe;
            background-color:#bbb;
        }

            .m_item[data-menu='m2'] .m_icon {
                background-position: 0 -40px;
            }

        .m_item[data-menu='m3'] {
            background-color: #ff7ea2;
            background-color:#bbb;
        }

            .m_item[data-menu='m3'] .m_icon {
                background-position: 0 -40px;
            }

        .m_item[data-menu='m4'] {
            background-color: #cd66ff;
            background-color:#bbb;
        }

            .m_item[data-menu='m4'] .m_icon {
                background-position: 0 -40px;
            }

        .m_item[data-menu='m5'] {
            background-color: #ffbf44;
            background-color:#bbb;
        }

            .m_item[data-menu='m5'] .m_icon {
                background-position: 0 -40px;
            }

        .mode {
            padding: 0 10px;
            position: absolute;
            left: 0;
            bottom: 322px;
        }

            .mode > img {
                width: 32px;
                vertical-align: bottom;
            }

        .mode_name {
            line-height: 32px;
            font-weight: bold;
            white-space: nowrap;
            overflow: hidden;
            text-overflow: ellipsis;
        }
    </style>
</head>
<body>
    <div class="wrap-page">
        <div class="page back-img" id="index" style="background-image: url(../../res/img/storesaler/ssbg2.jpg);">
            <div class="logoinfo">
                <div class="back-img logoimg" style="background-image: url(../../res/img/storesaler/ssllogo.png);"></div>
                <div class="logotitle">
                    <img src="../../res/img/storesaler/sslltitle.png" />
                </div>
            </div>
            <div class="mode" onclick="switchAdmin();">
                <img src="../../res/img/storesaler/mode_icon.png" />
                <span class="mode_name">当前模式：<span style="text-decoration:underline;"><%=managerStore %></span></span>
            </div>
            <ul class="menu_wrap">
                <li class="m_group">
                    <div class="m_item" data-menu="imaginal" onclick="javascript:window.location.href='imaginalList.aspx';">
                        <div class="m_icon"></div>
                        <p class="m_name">形象管理</p>
                    </div>
                    <div class="m_item" data-menu="m2">
                        <div class="m_icon"></div>
                        <p class="m_name">敬请期待..</p>
                    </div>
                </li>
                <li class="m_group">
                    <div class="m_item" data-menu="m3">
                        <div class="m_icon"></div>
                        <p class="m_name">敬请期待..</p>
                    </div>
                    <div class="m_item" data-menu="m4">
                        <div class="m_icon"></div>
                        <p class="m_name">敬请期待..</p>
                    </div>
                </li>
                <li class="m_group">
                    <div class="m_item" data-menu="m3">
                        <div class="m_icon"></div>
                        <p class="m_name">敬请期待..</p>
                    </div>
                    <div class="m_item" data-menu="m4">
                        <div class="m_icon"></div>
                        <p class="m_name">敬请期待..</p>
                    </div>
                </li>
                <li class="m_group">
                    <div class="m_item" data-menu="m3">
                        <div class="m_icon"></div>
                        <p class="m_name">敬请期待..</p>
                    </div>
                    <div class="m_item" data-menu="m4">
                        <div class="m_icon"></div>
                        <p class="m_name">敬请期待..</p>
                    </div>
                </li>
                <li class="m_group">
                    <div class="m_item" data-menu="m5">
                        <div class="m_icon"></div>
                        <p class="m_name">敬请期待..</p>
                    </div>
                </li>
            </ul>
        </div>
        <p class="copyright">&copy;2017 利郎（中国）有限公司</p>
    </div>

    <script type="text/javascript" src="../../res/js/jquery.js"></script>
    <script type='text/javascript' src='../../res/js/StoreSaler/fastclick.min.js'></script>
    <script type="text/javascript">
        var manage_mode = "<%=managerStore%>";
        if (manage_mode == "")
            $(".mode").hide();

        function switchAdmin() {
            $.ajax({
                type: "POST",
                timeout: 5000,
                contentType: "application/x-www-form-urlencoded; charset=utf-8",
                url: "managerNavCore.aspx",
                data: { ctrl: "clearSession" },
                success: function (msg) {
                    if (msg == "Successed") {
                        localStorage.removeItem("llmanagerNav_mode");
                        localStorage.removeItem("llmanagerNav_time");
                        window.location.href = "managerNav.aspx?gourl=" + encodeURI(window.location.href);
                    }
                },
                error: function (XMLHttpRequest, textStatus, errorThrown) {
                    LeeJSUtils.showMessage("error", "您的网络有问题..");
                }
            });//end AJAX
        }
    </script>
</body>
</html>

