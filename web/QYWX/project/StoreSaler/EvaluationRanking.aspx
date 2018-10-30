<%@ Page Language="C#" %>

<%@ Import Namespace="nrWebClass" %>
<%@ Import Namespace="System.Data.SqlClient" %>
<%@ Import Namespace="System.Data" %>
<%@ Import Namespace="System.Collections.Generic" %>
<!DOCTYPE html>
<script runat="server">
    public string roleName = "";
    public string tzid = "";
    
    protected void Page_Load(object sender, EventArgs e) {        
        if (clsWXHelper.CheckQYUserAuth(true))
        {            
            string strSystemKey = clsWXHelper.GetAuthorizedKey(3);    
            if (string.IsNullOrEmpty(strSystemKey)) {
                clsWXHelper.ShowError("超时 或 没有全渠道权限！");
                return;
            }

            roleName = Convert.ToString(Session["RoleName"]);
            tzid = Convert.ToString(Session["tzid"]);
        }
    }

    /// <summary>
    /// 获取缩略图路径
    /// </summary>
    /// <param name="imgUrlHead"></param>
    /// <param name="sourceImage"></param>
    /// <returns></returns>
</script>

<html>
	<head>
		<title>评价排名</title>
		<meta http-equiv="content-type" content="text/html; charset=UTF-8" />
        <meta name="viewport" content="width=device-width, initial-scale=1,user-scalable=0,maximum-scale=1" />
        <link rel="stylesheet" href="../../res/css/StoreSaler/percircle.css" />
        <link rel="stylesheet" href="../../res/css/LeePageSlider.css" />
        <link rel="stylesheet" href="../../res/css/StoreSaler/EvaluationStatistics.css" />
	</head>
	<body>
        <div class="wrap-page">
            <div class="page ranking">
                <div class="rank-search-bar" id="searchBar">
                    <form class="rank-search-bar_form">
                        <div class="rank-search-bar_box">
                            <i class="fa fa-search rank-icon-search"></i>
                            <input type="search" class="rank-search-bar_input" id="searchInput" placeholder="搜索" required />
                        </div>
                    </form>
                    <a href="javascript:" class="rank-search-bar_search-btn" id="searchSubmit">
                    搜索</a>
                </div>
                <div class="rank-filter"></div>
                <div class="rank-storelist">
                    <div class="rank-list-content">
                    </div>
                    <div class="dropload-down">
                        <div class="dropload-refresh">上拉加载更多</div>
                        <div class="dropload-load"><span class="loading"></span>加载中...</div>
                    </div>
                    <div class="rank-list-shade"></div>
                </div>
                <div class="rank-store-own">
                </div>
            </div>
        </div>
        <!--加载提示-->
        <div class="load_toast" id="myLoading">
            <div class="load_toast_mask"></div>
            <div class="load_toast_container">
                <div class="lee_toast">
                    <div class="load_img">
                        <img src="../../res/img/my_loading.gif" />
                    </div>
                    <div class="load_text">加载中...</div>
                </div>
            </div>
        </div>
        <!--排名模板-->
        <script id="storeLabel" type="text/html">
            <label class="rank-storelist_label" data-khid="{{khid}}">
                <div class="rank-store-ranking  {{if rank == 1}} rank-first {{else if rank == 2}} rank-second {{else if rank == 3 }} rank-third {{/if}} " >{{rank}}</div>
                <div class="rank-store-detail">
                    <div class="rank-info">
                        <div class="rank-info-name">{{khmc}}</div>
                        <div class="rank-info-code">{{khdm}}</div>
                    </div>
                    <div class="rank-score">
                        <div class="rank-score-service">
                            <p>服务</p>
                            <span>{{avgServicePoint}}</span>
                        </div>
                        <div class="rank-score-env">
                            <p>环境</p>
                            <span>{{avgFacePoint}}</span>
                        </div>
                        <div class="rank-score-goods">
                            <p>商品</p>
                            <span>{{avgProductPoint}}</span>
                        </div>
                        <div class="rank-score-djs">
                            <p>评价数</p>
                            <span>{{djs}}</span>
                        </div>
                    </div>
                </div>
                <div class="rank-store-statis">
                    <div class="rank-statis_perc">
                        <div class="rank-statis-info">
                            <p>总体评分</p>
                            <span>{{avgAllPoint}}</span>
                        </div>
                        <div id="pinkcircle" class="c100 {{prcAllPoint}} small pink">
                            <span></span>
                            <div class="slice">
                                <div class="bar"></div>
                                <div class="fill"></div>
                            </div>
                        </div>
                    </div>
                </div>
            </label>
        </script>
        <script type="text/javascript" src="../../res/js/jquery-3.2.1.min.js"></script>
        <script type="text/javascript" src="../../res/js/fastclick.min.js"></script>
        <script type="text/javascript" src="../../res/js/StoreSaler/percircle.js"></script>
        <script type="text/javascript" src="../../res/js/template.js"></script>
        <script type="text/javascript" src="../../res/js/fastclick.min.js"></script>
        <script type="text/javascript">
            $(function() {
                var url = "StoreEvaluationAnalysis.ashx";
                var pageNum = 0; //页码
                var entries = 10; //每页数据量
                var rankNum = 1;
                var isRefresh = true;
                var dataList = {
                    rows: []
                };
                var ranking = {
                    init: function() {
                        FastClick.attach(document.body);
                        bindEvent();
                        localStorage.removeItem("evalAllHtml");
                        localStorage.removeItem("evalBadHtml");
                        if(localStorage.hasOwnProperty("dataList")) {
                            dataList = JSON.parse(localStorage.getItem("dataList"));
                            pageNum = dataList.page - 1;
                            isRefresh = dataList.nextpage;
                            setLabelData(dataList);
                            localStorage.removeItem("dataList");
                        }else {
                            InitStoreList();
                        }
                    }
                };

                function bindEvent() {
                    $(".rank-storelist").scroll(function() {
                        var list = $(this);
                        var viewH = list.height();
                        var contentH = list.get(0).scrollHeight;
                        var scrollTop = list.scrollTop();

                        if(scrollTop / (contentH - viewH) >= 0.99 && isRefresh) {
                            isRefresh = false;
                            $(".dropload-refresh").hide();
                            $(".dropload-load").show();
                            var data = {
                                action: "storeRanking",
                                parameter: [entries.toString(),pageNum.toString()]
                            };

                            getData(JSON.stringify(data), function(result) {
                                if(result.code == 200) {
                                    var rows = result.data.rows;
                                    var html = "";

                                    for(var i = 0; i < rows.length; i++) {
                                        rows[i].rank = rankNum;
                                        rankNum++;
                                        rows[i].prcAllPoint = "p" + (rows[i].avgAllPoint / 5 * 100).toFixed(0);
                                        html = html + template("storeLabel", rows[i]);
                                    }

                                    dataList.rows = dataList.rows.concat(rows);
                                    dataList.nextpage = result.data.nextpage;

                                    setTimeout(function() {
                                        if(result.data.nextpage) {
                                            isRefresh = true;
                                        }else {
                                            $(".dropload-refresh").text("没有更多数据了");
                                            $(".rank-list-shade").show();
                                        }

                                        pageNum++;
                                        $(".rank-list-content").append(html);
                                        window.percInit();
                                        $(".dropload-load").hide();
                                        $(".dropload-refresh").show();
                                    },100);
                                }else {
                                    console.log(result);
                                }
                            });
                        };
                    });

                    $(".rank-list-content").on("click",".rank-store-detail",function() {
                        var khid = $(this).parent().attr("data-khid");
                        redirectPage(this);
                        window.location.href = "MemberEvaluation.aspx?khid=" + khid;
                    });

                    $(".rank-list-content").on("click",".rank-store-statis",function() {
                        var khid = $(this).parent().attr("data-khid");
                        redirectPage(this);
                        window.location.href = "MembershipRating.aspx?khid=" + khid;
                    });

                    $(".rank-store-own").on("click",".rank-store-detail",function() {
                        var khid = $(this).parent().attr("data-khid");
                        redirectPage(this);
                        window.location.href = "MemberEvaluation.aspx?khid=" + khid;
                    });

                    $(".rank-store-own").on("click",".rank-store-statis",function() {
                        var khid = $(this).parent().attr("data-khid");
                        redirectPage(this);
                        window.location.href = "MembershipRating.aspx?khid=" + khid;
                    });

                    $("#searchSubmit").click(function() {
                        var search =  $("#searchInput").val();
                        if(search != "") {
                            $(".rank-list-content").find("label").hide();
                            $(".rank-list-content").find(".rank-info-name:contains(" + search + ")").parent().parent().parent().show();
                        }else {
                            $(".rank-list-content").find("label").show();
                        }

                    });
                };

                function redirectPage(dom) {
                    dataList.page = pageNum;
                    dataList.scroll = document.querySelector(".rank-storelist").scrollTop;
                    localStorage.setItem("dataList",JSON.stringify(dataList));
                    var currentStore = {};
                    var self = $(dom).parent();
                    currentStore.avgAllPoint = self.find(".rank-statis-info span").text();
                    currentStore.avgServicePoint = self.find(".rank-score-service span").text();
                    currentStore.avgFacePoint = self.find(".rank-score-env span").text();
                    currentStore.avgProductPoint = self.find(".rank-score-goods span").text();
                    currentStore.khmc = self.find(".rank-info-name").text();
                    localStorage.setItem("currentStore",JSON.stringify(currentStore));
                }

                function InitStoreList() {
                    isRefresh = false;
                    $(".dropload-refresh").hide();
                    $(".dropload-load").show();
                    var data = {
                        action: "storeRanking",
                        parameter: [entries.toString(),pageNum.toString()]
                    };

                    getData(JSON.stringify(data), function(result) {
                        if(result.code == 200) {
                            setLabelData(result.data);
                            dataList.rows = result.data.rows;
                            dataList.currentStore = result.data.currentStore;
                            dataList.nextpage = result.data.nextpage;
                        }else {
                            onLoading("访问超时，请在微信下使用",true);
                        }
                    });
                }

                function setLabelData(data) {
                    var rows = data.rows;
                    var currentStore = data.currentStore;
                    var html = "";

                    if(currentStore.xh != undefined ) {
                        currentStore.rank = currentStore.xh;
                        currentStore.prcAllPoint = "p" + (currentStore.avgAllPoint / 5 * 100).toFixed(0);
                        $(".rank-store-own").append(template("storeLabel",currentStore));
                    }else {
                        $(".rank-store-own").append("<p style='padding: 10px; width: 100%; text-align: center;'>您的门店暂未上榜</p>");
                    }

                    for(var i = 0; i < rows.length; i++) {
                        rows[i].rank = rankNum;
                        rankNum++;
                        rows[i].prcAllPoint = "p" + (rows[i].avgAllPoint / 5 * 100).toFixed(0);
                        html = html + template("storeLabel", rows[i]);
                    }

                    setTimeout(function() {
                        if(data.nextpage) {
                            isRefresh = true;
                        }else {
                            $(".dropload-refresh").text("没有更多数据了");
                            $(".rank-list-shade").show();
                        }

                        pageNum++;
                        $(".rank-list-content").empty().append(html);
                        window.percInit();
                        $(".dropload-load").hide();
                        $(".dropload-refresh").show();
                        if(data.scroll) {
                            document.querySelector(".rank-storelist").scrollTop = dataList.scroll;
                        }
                    },100);
                }

                function getData(data,result) {
                    $.ajax({
                        url: url,
                        type: "POST",
                        data: data,
                        dataType: "JSON"
                    }).then(result).fail(function(err) {
                        console.log(err);
                    });
                }

                /* 显示加载状态 */
                function onLoading(msg,trun){
                    $(".load_text").text(msg || '加载中...');
                    if(trun) {
                        $(".load_img").hide();
                    }else {
                        $(".load_img").show();
                    }
                    $("#myLoading").show();
                };
                
                ranking.init();
            });
        </script>
	</body>
</html>