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
        clsWXHelper.CheckQYUserAuth(true);

    }
</script>
<html lang="en">
<head>
    <meta charset="utf-8" />
    <meta name="viewport" content="width=device-width,initial-scale=1,user-scalable=0,maximum-scale=1" />
    <meta name="format-detection" content="telephone=no" />
    <meta name="apple-mobile-web-app-capable" content="yes" />
    <meta name="apple-mobile-web-app-status-bar-style" content="black" />
    <link type="text/css" rel="stylesheet" href="../../res/css/LeePageSlider.css" />
    <link type="text/css" rel="stylesheet" href="../../res/css/llMeeting/llMeeting.css" />
    <title></title>
    <style type="text/css">
        
    </style>
</head>
<body ontouchstart>
    <!-- 提交提示 -->
    <div class="loader-wrap">
        <div class="circle-loader">
            <div class="checkmark draw">
            </div>
        </div>
    </div>
    <div class="wrap-page">
        <div class="no-meeting">
            <img src="../../res/img/llMeeting/icon-meeting.png">
            <p>
                今日暂无会议安排</p>
        </div>
        <div class="page">
            <div class="tip">
                会议暂未开始！若已开始，请刷新此页面！</div>
            <div class="info-wrap">
                <!-- 评价区 -->
                <div class="comment-area">
                    <p class="heading">
                        — 我要评价 —</p>
                    <div class="comment-item" id="allscore">
                        <span class="title">总平均分</span>
                        <div class="star-wrap">
                            <div class="icon-star icon-star-o">
                            </div>
                            <div class="icon-star icon-star-o">
                            </div>
                            <div class="icon-star icon-star-o">
                            </div>
                            <div class="icon-star icon-star-o">
                            </div>
                            <div class="icon-star icon-star-o">
                            </div>
                        </div>
                    </div>
                    <div class="comment-item" id="hyscore">
                        <span class="title">会议内容</span>
                        <div class="star-wrap">
                            <div class="icon-star icon-star-o">
                            </div>
                            <div class="icon-star icon-star-o">
                            </div>
                            <div class="icon-star icon-star-o">
                            </div>
                            <div class="icon-star icon-star-o">
                            </div>
                            <div class="icon-star icon-star-o">
                            </div>
                        </div>
                    </div>
                    <div class="comment-item" id="yjscore">
                        <span class="title">演讲水平</span>
                        <div class="star-wrap">
                            <div class="icon-star icon-star-o">
                            </div>
                            <div class="icon-star icon-star-o">
                            </div>
                            <div class="icon-star icon-star-o">
                            </div>
                            <div class="icon-star icon-star-o">
                            </div>
                            <div class="icon-star icon-star-o">
                            </div>
                        </div>
                    </div>
                    <textarea placeholder="说点什么吧..."></textarea>
                    <div class="btn_sumbit">
                        提交</div>
                </div>
            </div>
            <div class="btn_comment">
                立即评价</div>
        </div>
        <img class="logo" src="../../res/img/lilanz_logo.png">
    </div>
    <!-- 表单数据模板 -->
    <script id="form-temp" type="text/html">
        <div class="speaker-info">
            <div class="avatar" style="background-image: url({{headImg}})"></div>
            <div class="identity">
                <p class="speaker">{{MainUser}}</p>
                <p class="post">{{MainUserJobs}}</p>
            </div>
        </div>
        <div class="meet-info" data-id="{{MeetingID}}">
            <div class="wrap-txt">
                <span class="title">会议主题</span>
                <span class="txt" id="theme">{{Title}}</span>
            </div>
            <div>
                <span class="title">开始时间</span>
                <span class="txt">{{StartTime}}</span>
            </div>
            <div>
                <span class="title">会议时长</span>
                <span class="txt">{{MeetingHours}}小时</span>
            </div>
            <div class="wrap-txt">
                <span class="title">内容摘要</span>
                <span class="txt">{{Remark}}</span>
            </div>
            <div>
                <span class="title">会议地址</span>
                <span class="txt">{{Address}}</span>
            </div>
        </div>
        <div class="score-info">
            <div>
                <span class="title">总平均分</span>
                <span class="txt">{{AvgScore}}分</span>
            </div>
            <div>
                <span class="title">会议内容</span>
                <span class="txt">{{AvgScore1}}分</span>
            </div>
            <div>
                <span class="title">演讲水平</span>
                <span class="txt">{{AvgScore2}}分</span>
            </div>
        </div>
    </script>
    <script type="text/javascript" src="../../res/js/jquery.js"></script>
    <script type="text/javascript" src="../../res/js/fastclick.min.js"></script>
    <script type="text/javascript" src="../../res/js/template.js"></script>
    <script type="text/javascript">
        $(function () {

            var baseApi = "meetingCore.ashx";
            var ibeaconKey = getUrlParam('ibeaconKey');

            // 获取当前时间
            Date.prototype.Format = function (fmt) {
                var o = {
                    "M+": this.getMonth() + 1, //月份   
                    "d+": this.getDate(), //日   
                    "H+": this.getHours(), //小时   
                    "m+": this.getMinutes(), //分   
                    "s+": this.getSeconds(), //秒   
                    "q+": Math.floor((this.getMonth() + 3) / 3), //季度   
                    "S": this.getMilliseconds() //毫秒   
                };
                if (/(y+)/.test(fmt)) fmt = fmt.replace(RegExp.$1, (this.getFullYear() + "").substr(4 - RegExp.$1.length));
                for (var k in o)
                    if (new RegExp("(" + k + ")").test(fmt)) fmt = fmt.replace(RegExp.$1, (RegExp.$1.length == 1) ? (o[k]) : (("00" + o[k]).substr(("" + o[k]).length)));
                return fmt;
            }

            //获取url中的参数
            function getUrlParam(name) {
                var reg = new RegExp("(^|&)" + name + "=([^&]*)(&|$)"); //构造一个含有目标参数的正则表达式对象
                var r = window.location.search.substr(1).match(reg); //匹配目标参数
                if (r != null) return unescape(r[2]);
                return null; //返回参数值
            }

            // 初始化会议信息
            function initMeeting() {
                var para1 = new Array();
                para1[0] = ibeaconKey;
                var currtime = new Date().Format("yyyy-MM-dd HH:mm:ss");
                $.ajax({
                    type: "POST",
                    timeout: 5 * 1000,
                    url: baseApi,
                    contentType: "application/x-www-form-urlencoded; charset=utf-8",
                    data: JSON.stringify({
                        action: "initMetting",
                        parameter: para1
                    }),
                    success: function (msg) {

                        var jsondata = JSON.parse(msg);
                        if (jsondata.code == 200) {
                            $(".info-wrap").prepend(template("form-temp", jsondata.data[0]));
                            // 会议还未开始时
                            if (jsondata.data[0].StartTime > currtime) {
                                $(".tip").show();
                                $(".btn_comment").hide();
                                // 会议已经开始
                            } else {
                                $(".tip").hide();
                                // 用户已经评价过
                                if (jsondata.data[0].score > 0) {
                                    $(".heading").text("我的评价");
                                    $(".btn_sumbit").hide();
                                    $(".btn_comment").hide();
                                    $(".comment-area").show();
                                    $(".icon-star").unbind("click");
                                    $("textarea").attr("disabled", "true");
                                    $("#allscore").find(".icon-star").eq(jsondata.data[0].score - 1).prevAll().removeClass("icon-star-o").addClass("icon-star-s");
                                    $("#allscore").find(".icon-star").eq(jsondata.data[0].score - 1).removeClass("icon-star-o").addClass("icon-star-s");
                                    $("#hyscore").find(".icon-star").eq(jsondata.data[0].score1 - 1).prevAll().removeClass("icon-star-o").addClass("icon-star-s");
                                    $("#hyscore").find(".icon-star").eq(jsondata.data[0].score1 - 1).removeClass("icon-star-o").addClass("icon-star-s");
                                    $("#yjscore").find(".icon-star").eq(jsondata.data[0].score2 - 1).prevAll().removeClass("icon-star-o").addClass("icon-star-s");
                                    $("#yjscore").find(".icon-star").eq(jsondata.data[0].score2 - 1).removeClass("icon-star-o").addClass("icon-star-s");
                                    $("textarea").val(jsondata.data[0].ERemark);
                                } else {
                                    $(".btn_comment").show();
                                }
                            }

                        } else if (jsondata.code == 402) { //没有会议时

                            $(".page").hide();
                            $(".no-meeting").show();

                        } else {
                            alert(jsondata.message);
                        }

                    },
                    error: function (XMLHttpRequest, textStatus, errorThrown) {
                        console.log("error" + errorThrown);
                    }
                });
            }

            function bindEvents() {

                // 评分
                $(".icon-star").click(function () {
                    $(this).parent().find(".icon-star").removeAttr("class").addClass("icon-star icon-star-o");
                    $(this).prevAll().removeClass("icon-star-o").addClass("icon-star-s");
                    $(this).removeClass("icon-star-o").addClass("icon-star-s");
                });

                // 立即评价
                $(".btn_comment").click(function () {
                    $(this).hide();
                    $('.info-wrap').animate({
                        scrollTop: $(".info-wrap").height()
                    }, 400);
                    $(".comment-area").show();
                });

                // 提交评价
                $(".info-wrap").on("click", ".btn_sumbit", function () {
                    var para2 = new Array();
                    var avg = $("#allscore").find(".icon-star-s").length;
                    var hyf = $("#hyscore").find(".icon-star-s").length;
                    var yjf = $("#yjscore").find(".icon-star-s").length;
                    var myremark = $("textarea").val();
                    var meetingID = $(".meet-info").attr("data-id")
                    para2.push(JSON.stringify({
                        MeetingID: meetingID,
                        Score: avg,
                        Score1: hyf,
                        Score2: yjf,
                        Remark: myremark
                    }));

                    if (hyf == 0 || yjf == 0 || avg == 0) {
                        alert("请先进行评分！");
                    } else {
                        $(".loader-wrap").show();
                        $.ajax({
                            type: "POST",
                            timeout: 5 * 1000,
                            url: baseApi,
                            contentType: "application/x-www-form-urlencoded; charset=utf-8",
                            data: JSON.stringify({
                                action: "putInEval",
                                parameter: para2
                            }),
                            success: function (msg) {
                                var jsondata = JSON.parse(msg);
                                if (jsondata.code == 200) {
                                    setTimeout(function () {
                                        $('.circle-loader').toggleClass('load-complete');
                                        $('.checkmark').toggle();
                                    }, 1000);
                                    setTimeout(function () {
                                        location.replace("llMeeting.aspx?ibeaconKey=" + ibeaconKey);
                                    }, 1500);
                                    console.log(ibeaconKey);
                                } else {
                                    $(".loader-wrap").hide();
                                    alert(jsondata.message);
                                }

                            },
                            error: function (XMLHttpRequest, textStatus, errorThrown) {
                                console.log("error" + errorThrown);
                            }
                        });
                    }

                });
            }

            function init() {
                $(".loader-wrap").hide();
                FastClick.attach(document.body);
                if (ibeaconKey == null) {
                    $(".page").hide();
                    alert("非法访问！");
                }
                else {
                    initMeeting();
                }
                console.log(ibeaconKey);
                bindEvents();
            }

            init();

        });
    </script>
</body>
</html>
