<%@ Page Title="粉丝排行榜" Language="C#" MasterPageFile="../../WebBLL/frmQQDBase.Master" AutoEventWireup="true" %>

<%@ MasterType VirtualPath="../../WebBLL/frmQQDBase.Master" %>

<%@ Import Namespace="nrWebClass" %>

<script runat="server">
    /*子页面首先运行Page_Load，再运行主页面Page_Load；因此，只需要在子页面Page_Load事件中对Master.SystemID 进行赋值；
      主页面将会在其Page_Load事件中自动鉴权获取 AppSystemKey.之后请在子页面的Page_PreRender 或 JS中进行相关处理(比如：加载页面内容等)。
      请格外注意：万万不要在子页面的Load事件中直接使用用户的Session，因为Session是在主页面中获取的顺序在后，这将会导致异常！
    
         附：母版页和内容页的触发顺序    
         * 母版页控件 Init 事件。    
         * 内容控件 Init 事件。
         * 母版页 Init 事件。    
         * 内容页 Init 事件。    
         * 内容页 Load 事件。    
         * 母版页 Load 事件。    
         * 内容控件 Load 事件。    
         * 内容页 PreRender 事件。    
         * 母版页 PreRender 事件。    
         * 母版页控件 PreRender 事件。    
         * 内容控件 PreRender 事件。
     */
    public string ryid = "";
    public string mdid = "";
    public string myID = "";
    string SystemKey = "";
    protected void Page_PreRender(object sender, EventArgs e)
    {
        //mdid = "249";
        //ryid = "64847";

        string strInfo = "";
        SystemKey = this.Master.AppSystemKey;

        clsWXHelper.CheckQQDMenuAuth(17);    //检查菜单权限
        
        string ConWX = ConfigurationManager.ConnectionStrings["Conn"].ConnectionString; //连接62
        using (LiLanzDALForXLM dalWX = new LiLanzDALForXLM(ConWX))
        {
            string strSQL = string.Format(@"SELECT TOP 1  RelateID,B.mdid FROM wx_t_OmniChannelUser A
                            INNER JOIN Rs_T_Rydwzl B ON A.RelateID = B.ID
                            WHERE A.ID = {0}", SystemKey);

            System.Data.DataTable dt;
            strInfo = dalWX.ExecuteQuery(strSQL, out dt);
            if (strInfo == "")
            {
                if (dt.Rows.Count > 0)
                {
                    ryid = Convert.ToString(dt.Rows[0]["RelateID"]);
                    //mdid = Convert.ToString(dt.Rows[0]["mdid"]);
                    mdid = Convert.ToString(Session["mdid"]);
                }
                dt.Rows.Clear(); dt.Dispose();
            }
        }

        if (mdid == "") //mdid = "0"; 
            clsWXHelper.ShowError("对不起，找不到门店信息！");

    }

    //必须在内容页的Load中对Master.SystemID 进行赋值；
    protected void Page_Load(object sender, EventArgs e)
    {
        //this.Master.IsTestMode = true;
    }

</script>

<asp:Content ID="Content1" ContentPlaceHolderID="head" runat="server">
    <meta charset="utf-8" />
    <title>粉丝排行榜</title>
    <meta name="viewport" content="width=device-width, initial-scale=1.0, maximum-scale=1.0, user-scalable=no, minimal-ui">

    <style type="text/css">
        *
        {
            margin: 0;
            padding: 0;
        }

        body
        {
            font-family: Helvetica,Arial,"Hiragino Sans GB","Microsoft Yahei","微软雅黑",STHeiti,"华文细黑",sans-serif;
            background-color: #f3f4f7;
            font-size: 16px;
        }

        ul li
        {
            list-style: none;
        }

        .header
        {
            position: fixed;
            height: 48px;
            width: 100%;
            left: 0;
            top: 0;
            font-size: 18px;
            background-color: #fff1e5;
            background-image: -webkit-gradient(linear,0 0,0 100%,color-stop(0,#eef1e5), color-stop(1,#fff1e5));
            z-index: 400;
        }

            .header .area
            {
                float: left;
                width: 25%;
                height: 100%;
                box-sizing: border-box;
                text-align: center;
                line-height: 50px;
                color: #4d4d4d;
                cursor: pointer;
            }

            .header .active
            {
                color: #f68e37;
                pointer-events: none;
            }

        .wrap-page
        {
            position: absolute;
            left: 0;
            top: 48px;
            bottom: 0;
            width: 100%;
            overflow-x: hidden;
            overflow-y: auto;
        }

            .wrap-page .month
            {
                width: 100%;
                height: 40px;
                text-align: center;
                vertical-align: middle;
                line-height: 49px;
                overflow: hidden;
                font-size: 0px;
                cursor: pointer;
            }

                .wrap-page .month div
                {
                    display: inline-block;
                    width: 20%;
                    height: 25px;
                    margin: auto auto;
                    border: 1px solid #f68e37;
                    text-align: center;
                    line-height: 26px;
                    color: #f68e37;
                    font-size: 14px;
                }
                    .wrap-page .month div:not(:last-child) {
                        border-right:none;
                    }
                    .wrap-page .month div:first-child
                    {
                        border-radius: 3px 0 0 3px;
                    }

                    .wrap-page .month div:last-child
                    {
                        border-radius: 0 3px 3px 0;
                    }

        .selected
        {
            background-color: #f68e37;
            color: #fff !important;
            pointer-events: none;
        }

        .wrap-page .fans
        {
            position: absolute;
            left: 0;
            top: 40px;
            bottom: 0;
            width: 100%;
            overflow-x: hidden;
            overflow-y: auto;
            -webkit-overflow-scrolling:touch;
        }

            .wrap-page .fans ul
            {
                background-color: #fff;
                margin: 0 8px 0 8px;
            }

                .wrap-page .fans ul li
                {
                    position: relative;
                    width: 100%;
                    height: 42px;
                    margin-bottom: 5px;
                    border-bottom: 1px solid #f3f4f7;
                    
                }

                    .wrap-page .fans ul li div
                    {
                        position: relative;
                        float: left;
                        height: 42px;
                        box-sizing:border-box;
                        width:25%;
                        text-align:center;
                        line-height: 44px;
                        color: #4d4d4d;
                    }

                    .wrap-page .fans ul li img
                    {
                        
                        
                        text-align:center;
                        width: 38px;
                        height:38px;
                        vertical-align:central;
                        border-radius: 50%;
                    }

                    .wrap-page .fans ul li .name
                    {
                        
                        text-align:center;
                        line-height: 40px;
                    }

                    .wrap-page .fans ul li .count
                    {
                       text-align:center;
                        line-height: 40px;

                    }

                    .wrap-page .fans ul li .trend
                    {
                        text-align:center;
                        width: 40px;
                        height: 40px;
                        line-height: 38px;                      
                        background-repeat: no-repeat;
                        background-position: center;
                        background-size: 30px 30px;
                    }

        .footer
        {
            position: fixed;
            width: 75px;
            height: 75px;
            right: 30px;
            bottom: 50px;
            z-index: 400;
        }

            .footer .mine
            {
                position: absolute;
                width: 100%;
                height: 100%;
                position: absolute;
                border-radius: 50%;
                background-color: #fff1e5;
                overflow: hidden;
                opacity: 0.9;
            }

                .footer .mine div
                {
                    height: 25px;
                    line-height: 25px;
                    box-sizing: border-box;
                    text-align: center;
                    overflow: hidden;
                }

                    .footer .mine div:first-child
                    {
                        line-height: 32px;
                    }

                    .footer .mine div:last-child
                    {
                        position: relative;
                        line-height: 22px;
                        overflow: hidden;
                        background-color: #f68e37;
                    }
    </style>
</asp:Content>

<asp:Content ID="Content2" ContentPlaceHolderID="ContentPlaceHolder1" runat="server">
    <header class="header">
        <div class="area active" id="shop">本店</div>
        <div class="area" id="area">区域</div>
        <div class="area" id="province">全省</div>
        <div class="area" id="all">全国</div>
    </header>

    <div class="wrap-page">
        <div class="month">
            <div id="yesterday">昨日</div>
            <div id="today">今日</div>
            <div id="lastMonth">上月</div>
            <div id="currentMonth" class="selected">本月</div>
        </div>
        <div class="fans">
            <ul>
            </ul>
        </div>
    </div>

<%--    <footer class="footer">
        <div class="mine">
            <div id="rank"></div>
            <div id="fans"></div>
            <div>我的</div>
        </div>
    </footer>--%>
    <script type="text/javascript" src="../../res/js/jquery.js"></script>
    <script type="text/javascript" src="../../res/js/StoreSaler/jquery-ui.js"></script>
    <script type="text/javascript" src="../../res/js/StoreSaler/jquery.ui.touch-punch.js"></script>
    <script type="text/javascript">
        $(function () {
            $(".footer").draggable();
        });

        window.onload = function () {
            getRank("shop", "1");
            getMine("shop", "1");
        }

        //获取自己的排名
        function getMine(area, month) {
            return;
           <%-- $.ajax({
                type: "POST",
                timeout: 15000, 
                url: "FansCoreV2.aspx",
                data: { "ctrl": "getMine", "area": area, "myID": "<%= SystemKey%>", "mdid": "<%= mdid%>", "month": month },
                cache: false,
                success: function (data) {
                    data = JSON.parse(data);
                    $("#rank").html("NO." + data[0]["rank"]);
                    $("#fans").html(data[0]["fans"] + "位");
                },
                error: function (XMLHttpRequest, textStatus, errorThrown) {
                    alert(errorThrown);
                }
        });--%>
        
        
        }


        function getRank(area, month) {
            ShowLoading("正在加载...");
            $.ajax({
                type: "POST",
                timeout: 15000, 
                url: "FansCoreV2.aspx",
                data: { "ctrl": "getRank", "mdid": "<%= mdid%>", "area": area, "month": month },
                cache: false,
                success: function (data) { 
                    HideLoading();
                    if (data == "") {
                        $(".fans ul").html("没有数据...");
                    } else {
                        data = JSON.parse(data);
                        $(".fans ul").empty();
                        window.scroll(0, 0);
                        var count = data.list.length;

                        var lihtml = "";
                        for (var i = 0; i < count; i++) {
                            lihtml = "<li><div><img src='" + data.list[i].avatar +
                                    "' /></div><div class='name'>" + data.list[i].cname +
                                    "</div><div class='count'>" + data.list[i].fans + "</div>";
                            if (Number(data.list[i].rownumber)<4) lihtml += "<div class='trend' style='background-image:url(../../res/img/StoreSaler/no" + data.list[i].rownumber + ".png)'></div>";
                            lihtml += "</li>";
                            $(".fans ul").append(lihtml);
                        }
                    }
                },
                error: function (XMLHttpRequest, textStatus, errorThrown) {
                    alert(errorThrown);
                }
            });
        }

        function returnMonth() {
            if ($(".selected").text() == "上月") {
                $("#lastMonth").removeClass("selected");
                $("#currentMonth").addClass("selected");
            }
        }

        var areaText = "shop", timeDm = "1";
        $(".area").click(function () {
            $(".area").removeClass("active");
            $(this).addClass("active");
            areaText = $(this).attr("id");
            funType(timeDm);
        });

        $(".month div").click(function () {
            $(".month div").removeClass("selected");
            $(this).addClass("selected");
            monthText = $(this).text();
            switch (monthText) {
                case "本月":
                    timeDm = "1";               
                    break;
                case "上月":
                    timeDm = "0";                  
                    break;
                case "昨日":
                    timeDm = "2";                  
                    break;
                case "今日":
                    timeDm = "3"; 
                    break;
                default:
                    break;
            }
            funType(timeDm);
        });

        function funType(timetype) {
            getRank(areaText, timetype);
        }
    </script>
</asp:Content>
