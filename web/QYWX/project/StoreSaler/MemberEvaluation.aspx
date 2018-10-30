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
		<title>会员评价</title>
		<meta http-equiv="content-type" content="text/html; charset=UTF-8" />
        <meta name="viewport" content="width=device-width, initial-scale=1,user-scalable=0,maximum-scale=1" />
        <link rel="stylesheet" href="../../res/css/LeePageSlider.css" />
        <link rel="stylesheet" href="../../res/css/StoreSaler/swiper.min.css" />
        <link rel="stylesheet" href="../../res/css/StoreSaler/EvaluationStatistics.css" />
	</head>
	<body>
        <div class="wrap-page">
            <div class="page eval">
                <div class="eval-store-name"></div>
                <div class="eval-swiper">
                    <div class="swiper-container">
                        <div class="swiper-wrapper">
                        </div>
                    </div>
                    <div class="swiper-pagination"></div>
                </div>
                <div class="eval-list-title">评价列表<a id="eval-filter-all" class="eval-filter-selected" href="javascript:">全部</a><a id="eval-filter-bad" href="javascript:">仅看差评</a></div>
                <div class="eval-list">
                    <div class="eval-list-content">
                    </div>
                    <div class="dropload-down">
                        <div class="dropload-refresh">上拉加载更多</div>
                        <div class="dropload-load"><span class="loading"></span>加载中...</div>
                    </div>
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
        <!--总评价模板-->
        <script id="totalEval" type="text/html">
            <div class="swiper-slide {{if noswiper == 0}} swiper-no-swiping {{/if}}">
                <div class="eval-swiper-total">
                    <p>总体评分<!-- ( 近12个月 )--></p>
                    <span>{{avgAllPoint}}</span>
                </div>
                <div class="eval-swiper-detail">
                    <div>
                        <p>服务</p>
                        <span>{{avgServicePoint}}</span>
                    </div>
                    <div>
                        <p>环境</p>
                        <span>{{avgFacePoint}}</span>
                    </div>
                    <div>
                        <p>商品</p>
                        <span>{{avgProductPoint}}</span>
                    </div>
                </div>
            </div>
        </script>
        <!--评价列表模板-->
        <script id="evalDetail" type="text/html">
            <div class="eval-list-item">
                <div class="eval-list-info">
                    <div class="eval-list-user">
                        <div class="eval-list-rankinfo">
                            <p class="eval-list-username">{{wxName}}</p>
                            <div class="eval-list-icon">
                                {{each star}}
                                    <div class="eval-icon-img eval-icon-star-selected"></div>
                                {{/each}}
                                {{each nostar}}
                                    <div class="eval-icon-img eval-icon-star"></div>
                                {{/each}}
                            </div>
                            <p>服务：<span>{{ServicePoint}}</span>环境：<span>{{FacePoint}}</span>商品：<span>{{ProductPoint}}</span></p>
                            <!--<p class="eval-list-time">{{CreateTime}}</p>-->
                        </div>
                    </div>
                    <div class="eval-list-rank">
                        <!--<p>销售导购：<span>陈二狗</span></p>-->
                        <p>总体评分：<span>{{allpoint}}</span></p>
                        <!--<p>服务：<span>{{ServicePoint}}</span>环境：<span>{{FacePoint}}</span>商品：<span>{{ProductPoint}}</span></p>-->
                    </div>
                </div>
                <div class="eval-list-detail">{{if Remark}} {{Remark}} {{else}} 暂无评价 {{/if}}
                </div>
                <div class="eval-list-time">{{CreateTime}}</div>
            </div>
        </script>
        <script type="text/javascript" src="../../res/js/jquery-3.2.1.min.js"></script>
        <script type="text/javascript" src="../../res/js/fastclick.min.js"></script>
        <script type="text/javascript" src="../../res/js/template.js"></script>
        <script type="text/javascript" src="../../res/js/StoreSaler/swiper.jquery.min.js"></script>
        <script type="text/javascript">
            $(function() {
                var mySwiper = "";
                
                var url = "http://tm.lilanz.com/qywx/project/StoreSaler/StoreEvaluationAnalysis.ashx";
                var pageNum = 0; //页码
                var entries = 10; //每页数据量
                var rankNum = 1;
                var khid = GetQueryParams("khid") || "249";
                var isRefresh = true;
                var isOnFilter = true;
                
                function init() {
                    bindEvent();
                    FastClick.attach(document.body);
                    InitStoreList();
                }

                function bindEvent() {
                    $(".eval-list").scroll(debounce(function() {
                        var list = $(".eval-list");
                        var viewH = list.height();
                        var contentH = list.get(0).scrollHeight;
                        var scrollTop = list.scrollTop();

                        if(scrollTop / (contentH - viewH) >= 0.95 && isRefresh) {
                            console.log("触发下拉刷新",new Date().getTime());
                            getEvalList();
                        };
                    }, 100));

                    /*$(".eval-list").click(function() {
                        if(isRefresh) {
                            getEvalList();
                        }
                    });*/

                    $("#eval-filter-all").click(function() {
                        var isOnSelected = $(this).hasClass("eval-filter-selected");
                        var evalBadHtml = $(".eval-list-content").html();
                        var evalHtml = {
                            "html": evalBadHtml,
                            "pageNum": pageNum,
                            "isRefresh": isRefresh
                        };
                        localStorage.setItem("evalBadHtml", JSON.stringify(evalHtml));
                        if(isOnFilter && !isOnSelected) {
                            $(".eval-list-content").empty();
                            $(this).addClass("eval-filter-selected");
                            $("#eval-filter-bad").removeClass("eval-filter-selected");
                            if(localStorage.hasOwnProperty("evalAllHtml")) {
                                evalHtml = JSON.parse(localStorage.getItem("evalAllHtml"));
                                $(".eval-list-content").empty().append(evalHtml.html);
                                pageNum = evalHtml.pageNum;
                                isRefresh = evalHtml.isRefresh;
                                if(isRefresh) $(".dropload-refresh").text("上拉加载更多");
                                localStorage.removeItem("evalAllHtml");
                            }else {
                                pageNum = 0;
                                getEvalList();
                            }
                        }
                    });

                    $("#eval-filter-bad").click(function() {
                        var isOnSelected = $(this).hasClass("eval-filter-selected");
                        var evalAllHtml = $(".eval-list-content").html();
                        var evalHtml = {
                            "html": evalAllHtml,
                            "pageNum": pageNum,
                            "isRefresh": isRefresh
                        };
                        localStorage.setItem("evalAllHtml", JSON.stringify(evalHtml));
                        if(isOnFilter && !isOnSelected) {
                            $(".eval-list-content").empty();
                            $(this).addClass("eval-filter-selected");
                            $("#eval-filter-all").removeClass("eval-filter-selected");
                            if(localStorage.hasOwnProperty("evalBadHtml")) {
                                evalHtml = JSON.parse(localStorage.getItem("evalBadHtml"));
                                $(".eval-list-content").empty().append(evalHtml.html);
                                pageNum = evalHtml.pageNum;
                                isRefresh = evalHtml.isRefresh;
                                if(isRefresh) $(".dropload-refresh").text("上拉加载更多");
                                localStorage.removeItem("evalBadHtml");
                            }else {
                                pageNum = 0;
                                getEvalList("bad");
                            }
                        }
                    });
                };

                function getEvalList() {
                    console.log("获取请求数据",new Date().getTime());
                    isRefresh = false;
                    isOnFilter = false;
                    var range = arguments[0] || "all";
                    $(".dropload-refresh").hide();
                    $(".dropload-load").show();
                    var data = {
                        action: "storeDetail",
                        parameter: [khid,entries.toString(),pageNum.toString(),range]
                    };
                    console.log("开始发起请求",new Date().getTime());
                    $.ajax({
                        url: url,
                        cache:false,
                        timeout:10*1000,
                        type: "POST",
                        contentType: "text/json; charset=utf-8",
                        data: JSON.stringify(data),
                        dataType: "JSON",
                        success: function(result) {
                            console.log("获取请求数据",new Date().getTime());
                            handleData(result);
                        }
                    })
                }

                function handleData(result) {
                    if(result.code == 200) {
                        var data = result.data;
                        var detailHtml = "";

                        for(var i = 0; i < data.detail.length; i++) {
                            var time = data.detail[i].CreateTime.split("T");
                            data.detail[i].star = new Array(data.detail[i].allpoint);
                            data.detail[i].nostar = new Array(5 - data.detail[i].allpoint);
                            data.detail[i].CreateTime = time[0].substr(5,10) + " " + time[1].substr(0,5);
                            detailHtml = detailHtml + template("evalDetail",data.detail[i]);
                        }

                        if(result.data.nextpage) {
                            isRefresh = true;
                        }else {
                            $(".dropload-refresh").text("没有更多数据了");
                        }

                        pageNum++;
                        isOnFilter = true;
                        $(".eval-list-content").append(detailHtml);
                        $(".dropload-load").hide();
                        $(".dropload-refresh").show();
                        console.log("渲染页面",new Date().getTime());
                    }else {
                        console.log(result);
                    }
                }

                function InitStoreList() {
                    isRefresh = false;
                    var range = arguments[0] || "all";
                    $(".dropload-refresh").hide();
                    $(".dropload-load").show();
                    var data = {
                        action: "storeDetail",
                        parameter: [khid,entries.toString(),pageNum.toString(),range]
                    };

                    getData(JSON.stringify(data)).then(function(result){
                        if(result.code == 200) {
                            var data = result.data;
                            var totalHtml = "";
                            var detailHtml = "";
                            var currentStore = JSON.parse(localStorage.getItem("currentStore"));
                            localStorage.removeItem("currentStore");
                            totalHtml = template("totalEval",currentStore);
                            
                            for(var i = 0; i < data.detail.length; i++) {
                                var time = data.detail[i].CreateTime.split("T");
                                data.detail[i].star = new Array(data.detail[i].allpoint);
                                data.detail[i].nostar = new Array(5 - data.detail[i].allpoint);
                                data.detail[i].CreateTime = time[0].substr(0,10) + " " + time[1].substr(0,5);
                                detailHtml = detailHtml + template("evalDetail",data.detail[i]);
                            }

                            if(result.data.nextpage) {
                                isRefresh = true;
                            }else {
                                $(".dropload-refresh").text("没有更多数据了");
                            }

                            pageNum++;
                            $(".swiper-wrapper").empty().append(totalHtml);
                            initSwiper();
                            $(".eval-list-content").empty().append(detailHtml);
                            $(".eval-store-name").text(decodeURIComponent(currentStore.khmc));
                            $(".dropload-load").hide();
                            $(".dropload-refresh").show();
                            $("#myLoading").hide();
                        }else {
                            onLoading("访问超时，请在微信下使用",true);
                        }
                    });
                }

                function debounce (func, wait) {
                    let ctx;
                    let args;
                    let timer = null;
                    const later = function () {
                        func.apply(ctx, args);
                        timer = null;
                    }
                    return function () {
                        ctx = this;
                        args = arguments;
                        if (timer) {
                          clearTimeout(timer);
                          timer = null;
                        }
                        timer = setTimeout(later, wait);
                    }
                }
                
                function getData(data,result) {
                    return new Promise(function(resolve,reject){
                        console.log("一", new Date().getTime());
                        $.ajax({
                            url: url,
                            type: "POST",
                            data: data,
                            dataType: "JSON",
                            success:function(res){
                                console.log("二", new Date().getTime());
                                resolve(res);
                            },
                            fail: function(err) {
                                reject(err);
                            }
                        })
                    })
                }
                
                /* 获取URL GET参数 */
                function GetQueryParams(name) {
                    var reg = new RegExp("(^|&)" + name + "=([^&]*)(&|$)", "i");
                    var r = window.location.search.substr(1).match(reg);
                    if (r != null)
                        return unescape(r[2])
                    else
                        return "";
                };

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
                
                function initSwiper() {
                    mySwiper = new Swiper(".swiper-container", {            
                        /*pagination: ".swiper-pagination",*/
                        slidesPerView: 'auto',
                        centeredSlides: true
                        /*spaceBetween: -18*/
                    });
                }
                
                init();
            });
        </script>
	</body>
</html>