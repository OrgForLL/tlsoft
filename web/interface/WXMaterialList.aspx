<%@ Page Language="C#" %>

<!DOCTYPE html>
<script runat="server">
    public string configkey = "";
    protected void Page_Load(object sender, EventArgs e) {
        configkey = Convert.ToString(Request.Params["configkey"]);
    }
</script>
<html lang="en" xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <meta charset="utf-8" />
    <title>公众号素材列表</title>
    <style type="text/css">
        * {
            margin: 0;
            padding: 0;
        }

        ul {
            list-style: none;
        }

        a {
            text-decoration: none;
        }

        body {
            font-family: Helvetica,Arial,STHeiTi,"Hiragino Sans GB","Microsoft Yahei","微软雅黑",STHeiti,"华文细黑",sans-serif;
            font-size: 14px;
            color: #333;
            background-color: #f0f0f0;
        }

        .wraper {
            width: 400px;
            margin: 10px auto 0 auto;
        }

        .item_container {
            background-color: #fff;
            position: relative;
            padding:0 10px;
            max-height: 600px;
            overflow-y: auto;
            overflow-x: hidden;
        }

        .infos {
            text-align: right;
            padding-bottom: 10px;
        }

        #total {
            background-color: #63b359;
            padding: 2px 5px;
            color: #fff;
        }

        .search_container {
            text-align: center;
            width: 100%;
            margin-bottom: 8px;
        }

        #search_input {
            outline: none;
            border: 1px solid #c9c9c9;
            padding: 0px 8px;
            margin-right: 10px;
            height: 30px;
            line-height: 30px;
            vertical-align: middle;
        }

        .item {
            border: 1px solid #e7e7e7;
            padding: 0 10px;
            margin: 20px 0;
            color: #222;
        }

        .create_time {
            color: #666;
            line-height: 20px;
            border-bottom: 1px solid #e7e7eb;
            padding: 10px 0;
        }

        .name {
            padding: 10px 0;
            border-bottom: 1px solid #eee;
        }

        .btn_select {
            color: #fff;
            background: #63b359;
            padding: 5px 10px;
            font-size: 14px;
        }

        .aright {
            margin: 15px 0;
            text-align: right;
        }

        .page_nav {
            margin: 10px 0;
            text-align: center;
        }

        .load_more {
            display: inline-block;
            width: 100%;
            color: #222;
            padding: 10px 0;
            text-align: center;
            background-color: #fff;
        }

            .load_more:hover {
                background-color: #63b359;
                color: #fff;
            }
    </style>
</head>
<body>
    <div class="wraper">
        <div class="search_container">
            <input type="text" id="search_input" />
            <a href="javascript:Search()" style="color: #fff; background-color: #63b359; display: inline-block; height: 30px; line-height: 30px; padding: 0 10px;">搜 索</a>
        </div>
        <div class="infos">
            <span>素材总数：<span id="total">--</span></span>
        </div>

        <div class="item_container">
            <!--
                <div class="item">
                <p class="create_time">2016年2月24日</p>
                <p class="name">图文消息标题一</p>
                <p class="name">图文消息标题二</p>
                <div class="aright"><a href="javascript:" class="btn_select">选 择</a></div>            
            </div>
            -->
        </div>

        <div class="page_nav">
            <a href="javascript:loadDatas()" class="load_more">加载更多..</a>
        </div>
    </div>

    <script type="text/html" id="news_temp">
        {{each item}}
        <div class="item" data-media-id="{{$value.media_id}}">
            <p class="create_time">{{$value.update_time}}</p>
            {{each $value.content.news_item}}
            <p class="name">{{$value.title}}</p>
            {{/each}}
            <div class="aright"><a href="javascript:" class="btn_select" onclick="retSelect('{{$value.media_id}}')">选 择</a></div>
        </div>
        {{/each}}
    </script>

    <script type="text/javascript" src="../js_UI/jquery-1.4.2.min.js"></script>
    <script type="text/javascript" src="../js_UI/template.js"></script>
    <script type="text/javascript" src="../JSON/json2.js"></script>
    <script type="text/javascript">
        var loaded = true, configkey = "<%=configkey%>";
        $(document).ready(function () {
            loadDatas();
        });

        var offset = 0;
        function loadDatas() {
            if (!loaded) {
                alert("正在加载数据，请稍候..");
            } else {
                loaded = false;
                $.ajax({
                    type: "POST",
                    timeout: 10 * 1000,
                    contentType: "application/x-www-form-urlencoded; charset=utf-8",
                    url: "WXMassMessageCore.aspx",
                    data: { ctrl: "getMaterial", offset: offset,configkey:configkey },
                    success: function (msg) {
                        if (msg.indexOf("Error:") > -1) {
                            alert(msg);
                        } else {
                            var rows = JSON.parse(msg);
                            if (rows.item.length > 0) {
                                $("#total").text(rows.total_count);
                                for (var i = 0; i < rows.item.length; i++) {
                                    var row = rows.item[i];
                                    row.update_time = getLocalTime(row.update_time);
                                }
                                $(".item_container").append(template("news_temp", rows));
                                offset += rows.item_count;
                            } else {
                                $(".load_more").text("没有数据了..");
                                alert("没数据啦..");
                            }
                        }
                        loaded = true;
                    },
                    error: function (XMLHttpRequest, textStatus, errorThrown) {
                        alert("网络出错");
                    }
                });
            }
        }

        function getLocalTime(nS) {
            return new Date(parseInt(nS) * 1000).toLocaleString().replace(/:\d{1,2}$/, ' ');
        }

        function Search() {
            var txt = $("#search_input").val();
            if (txt != "") {
                var items = $(".item_container .item");
                for (var i = 0; i < items.length; i++) {
                    var name = $(".name", items[i]).text();
                    if (name.indexOf(txt) <= -1)
                        $(items[i]).hide();
                    else
                        $(items[i]).show();
                }//end for
            } else
                $(".item_container .item").show();
        }

        function retSelect(mediaid) {
            var ret = new Array(2);
            ret[0] = mediaid;
            ret[1] = $(".item[data-media-id='" + mediaid + "'] .name").eq(0).text();
            window.returnValue = ret;
            window.parent.close();
        }
    </script>
</body>
</html>
