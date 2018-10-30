<%@ Page Language="C#" %>

<%@ Import Namespace="nrWebClass" %>

<!DOCTYPE html>
<script runat="server">
    public string ryid = "0";
    public string mdid = "0";
    protected void Page_Load(object sender, EventArgs e)
    {
        //ryid = Convert.ToString(Session["ID"]);
        //ryid = "54067";
        //ryid = Convert.ToString(Session["qy_customersid"]);
        ////获取用户鉴权的方法:该方法要求用户必须已成功关注企业号，主要是用于获取Session["qy_customersid"] 和其他登录信息
        if (!clsWXHelper.CheckQYUserAuth(true))
        {
            Response.Redirect("../../WebBLL/Error.aspx?msg=请先关注利郎企业号！");
            Response.End();
        }

        //ryid = "54067";
        mdid = Convert.ToString(Session["mdid"]);
        //mdid = "249";
    }
</script>
<html>
<head runat="server">
    <meta charset="utf-8" />
    <meta name="viewport" content="height=device-height,width=device-width,initial-scale=1.0,minimum-scale=1.0,maximum-scale=1.0,user-scalable=no" />
    <meta name="format-detection" content="telephone=no" />
    <title>琅琊榜</title>
    <style type="text/css">
        * {
            margin: 0px;
            padding: 0px;
        }

        ul li {
            list-style: none;
        }

        body {
            font-family: Helvetica,Arial,"Hiragino Sans GB","Microsoft Yahei","微软雅黑",STHeiti,"华文细黑",sans-serif;
            -ms-text-size-adjust: 100%;
            -webkit-text-size-adjust: 100%;
            font-size: 14px;
        }

        .header {
            border-bottom: 1px solid;
            text-align: center;
            padding: 0 10px;
            display: block;
            position: fixed;
            height: 80px;
            width: 100%;
            text-align: center;
            padding: 0;
            box-sizing: border-box;
            z-index: 2;
            
        }

            .header .logo {
                height: 80px;
            }


        .logo img {
            height: 100%;
            width: 100%;
        }

        .container {
            padding-top: 80px;
        }

            .container .fight {
                display: block;
                text-align: center;
                height: 40px;
                line-height: 40px;
            }

        .playHead {
            box-sizing: border-box;
        }

            .playHead .item {
                box-sizing: border-box;
                float: left;
                width: 25%;
                text-align: center;
                height: 30px;
                line-height: 30px;
                border: 3px solid #eee;
                font-size: 1.2em;
            }

        .playList {
            box-sizing: border-box;
        }

            .playList .player {
                box-sizing: border-box;
                float: left;
                width: 25%;
                text-align: center;
                height: 30px;
                line-height: 30px;
                border-bottom: 1px solid #eee;
            }






        .playul {
            padding-top: 30px;
            width: 100%;
            list-style: none;
            background-color: #f0f0f0;
        }

            .playul li {
                height: 30px;
                padding: 6px 10px;
                line-height: 54px;
                position: relative;
                opacity: 1;
                box-sizing: content-box;
                font-size: 1.2em;
            }

                .playul li:not(:last-child) {
                    border-bottom: 2px solid #cbcbcb;
                }

                .playul li:after {
                    content: "";
                    display: table;
                    clear: both;
                }
    </style>
</head>
<body>
    <div class="header">
        <div class="logo">
            <img src="..\..\res\img\StoreSaler\shoprank.jpg" alt="" />
        </div>
    </div>

    <div class="container">


        <div class="honorList">
            <div class="playHead">
                <span class="item">排 名</span>
                <span class="item">姓 名</span>
                <span class="item">销售量</span>
                <span class="item">金 额</span>
            </div>
            <div class="playList" >
                <ul id="shopRank" class="playul">
					<%= mdid %>
                    <%--<li>
                        -暂时没有数据-
                    </li>--%>
                    
                </ul>
            </div>
        </div>

        <div class="mask">
            <div class="loader">
                <div>
                    <i class="fa fa-2x fa-spinner fa-pulse"></i>
                </div>
                <p id="loadtext"></p>
            </div>
        </div>

    </div>
    <script type="text/javascript" src="../../res/js/jquery.js"></script>
    <script type="text/javascript" src="../../res/js/Chart.min.js"></script>
    <script type="text/javascript">

        window.onload = function () {
            //showLoader("loading", "正在加载...");
            getShopRank();
        }

        var mdid = "<%=mdid%>";


        function getShopRank() {
            //st = document.body.scrollTop;
            $.ajax({
                type: "POST",
                timeout: 10000,
                url: "ShopRankCore.aspx",
                data: { ctrl: "getShopRank", mdid: mdid },
                success: function (data) {
                    data = JSON.parse(data);
                    var len = data.rows.length;
                    var rankhtml = "";
                    if (len > 0) {
                        for (var i = 1; i <= len; i++) {
                            var row = data.rows[i - 1];
                            rankhtml += "<li><span class='player'>" + i +
                            "</span><span class='player'>" + row.xm + "</span><span class='player'>" +
                            row.ddsl + "</span><span class='player'>" + row.zje + "</span></li>";
                        }
                        $("#shopRank").append(rankhtml);
                    } else {
                        $("#shopRank").append("<li>-暂时没有数据-</li>");
                    }
                    //$("#shopRank").children().remove();
                    
                    //alert(data.rows[0].xm);
                    //if (len > 0) {
                    //    for (var i = 1; i <= len; i++) {
                    //        var row = data.rows[i-1];
                    //        rankhtml = "<li><span class='player'>" + i + "</span><span class='player'>" + row.xm +
                    //            "</span><span class='player'>" + row.zje + "</span><span class='player'>" + row.ddsl +
                    //            "</span></li>";
                    //        rankhtml += row;
                    //    }
                    //}
                    //    alert(rankhtml);
                    //    $("#shopRank").children().remove();
                    //    $("#shopRank").append(rankhtml);

                    
                },
                error: function (XMLHttpRequest, textStatus, errorThrown) {
                    alert(XMLHttpRequest.status + "|" + XMLHttpRequest.readyState + "|" + textStatus);
                }
            });
        }
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
                    break;
                case "error":
                    $(".mask .fa").removeAttr("class").addClass("fa fa-2x fa-close (alias)");
                    $("#loadtext").text(txt);
                    $(".mask").show();
                    break;
                case "warn":
                    $(".mask .fa").removeAttr("class").addClass("fa fa-2x fa-warning (alias)");
                    $("#loadtext").text(txt);
                    $(".mask").show();
                    break;
            }
        }
        $(".backbtn").click(function () {
            window.history.go(-1);
        });

    </script>


</body>
</html>
