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
            <div class="page rating">
                <div class="rating-store-name"></div>
                <div class="rating-swiper">
                    <div class="swiper-container">
                        <div class="swiper-wrapper">
                        </div>
                    </div>
                    <div class="swiper-pagination"></div>
                </div>
                <!--<div class="rating-chart-tile">
                    <p>总评价数（条）</p>
                    <span>800</span>
                </div>-->
                <div class="rating-chart">
                    <div class="rating-chart-detail">
                        <p>总体评分</p>
                        <canvas id="totality"></canvas>
                    </div>
                    <div class="rating-chart-detail">
                        <p>服务</p>
                        <canvas id="service"></canvas>
                    </div>
                    <div class="rating-chart-detail">
                        <p>环境</p>
                        <canvas id="env"></canvas>
                    </div>
                    <div class="rating-chart-detail">
                        <p>商品</p>
                        <canvas id="goods"></canvas>
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
        <script id="totalRating" type="text/html">
            <div class="swiper-slide {{if noswiper == 0}} swiper-no-swiping {{/if}}">
                <div class="rating-swiper-total">
                    <p>总体评分<!-- ( 近12个月 )--></p>
                    <span>{{avgAllPoint}}</span>
                </div>
                <div class="rating-swiper-detail">
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
        <script type="text/javascript" src="../../res/js/jquery-3.2.1.min.js"></script>
        <script type="text/javascript" src="../../res/js/fastclick.min.js"></script>
        <script type="text/javascript" src="../../res/js/template.js"></script>
        <script type="text/javascript" src="../../res/js/StoreSaler/swiper.jquery.min.js"></script>
        <script type="text/javascript" src="../../res/js/StoreSaler/Chart.min.js"></script>
        <script type="text/javascript">
            $(function() {
                var mySwiper ="";
                var url = "StoreEvaluationAnalysis.ashx";
                var khid = GetQueryParams("khid");

                function init() {
                    onLoading();
                    FastClick.attach(document.body);
                    
                    var data = {
                        action: "evaluationlCahrt",
                        parameter: [khid]
                    };

                    getData(JSON.stringify(data), function(result) {
                        if(result.code == 200) {
                            var data = result.data;
                            var totalHtml = "";
                            var currentStore = JSON.parse(localStorage.getItem("currentStore"));
                            localStorage.removeItem("currentStore");
                            totalHtml = template("totalRating",currentStore);
                            
                            var totality = getPoint(data.allpoint);
                            var service = getPoint(data.ServicePoint);
                            var env = getPoint(data.FacePoint);
                            var goods = getPoint(data.ProductPoint);
                            setTimeout(function() {
                                $(".swiper-wrapper").empty().append(totalHtml);
                                initSwiper();
                                getChart(totality,"totality");
                                getChart(service,"service");
                                getChart(env,"env");
                                getChart(goods,"goods");
                                $(".rating-store-name").text(data.totalView[0].khmc);
                                $("#myLoading").hide();
                            },1000);
                        }else {
                            onLoading("访问超时，请在微信下使用",true);
                        }
                    });
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
                
                function getChart(point,el) {
                    var data = {
                        labels : ["5分","4分","3分","2分","1分"],
                        datasets : [
                            {
                                backgroundColor: ["#FFA8B8","#91519D","#5F72B2","#0D8ABC","#FFD2A5"],
                                borderWidth: 1,
                                data : point
                            }
                        ],
                    }
                    
                    var ctx = $("#" + el).get(0).getContext("2d");
                    
                    var options = {
                        scales: {
                            yAxes: [{
                                ticks: {
                                    beginAtZero: true,
                                    max: 100,
                                    stepSize: 20,
                                    callback: function(value, index, values) {
                                        return value + '%';
                                    }
                                }
                            }],
                            xAxes: [{
                                gridLines: {
                                    display: false
                                }
                            }]
                        },
                        legend: {
                            display: false
                        }
                    };
                    
                    new Chart(ctx, {
                        type: "bar",
                        data: data,
                        options: options
                    });
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
                
                function getPoint(point) {
                    var result = [];
                    
                    result.push(point[5].split("%")[0]);
                    result.push(point[4].split("%")[0]);
                    result.push(point[3].split("%")[0]);
                    result.push(point[2].split("%")[0]);
                    result.push(point[1].split("%")[0]);
                    
                    return result;
                }
                
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