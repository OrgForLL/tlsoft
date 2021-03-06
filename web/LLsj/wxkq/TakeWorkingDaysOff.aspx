﻿<%@ Page Language="C#" %>

<!DOCTYPE html>
<script runat="server">
    public string username = "", userid = "", rybh = "", ryid = "", lxdh = "", bmmc = "";
    protected void Page_Load(object sender, EventArgs e) {
        userid = Convert.ToString(Session["wxkq_userid"]);
        if (userid == "" || userid == null) {
            Response.Write("Error:非法访问！");
            Response.End();
        }            
        username = Convert.ToString(Session["wxkq_username"]);        
        rybh = Convert.ToString(Session["wxkq_rybh"]);
        ryid = Convert.ToString(Session["wxkq_ryid"]);
        lxdh = Convert.ToString(Session["wxkq_lxdh"]);
        bmmc = Convert.ToString(Session["wxkq_bmmc"]);
        
    }    
</script>
<html lang="en" xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <meta charset="utf-8" />
    <meta name="viewport" content="width=device-width,initial-scale=1,user-scalable=0" />
    <title></title>
    <script type="text/javascript" src="js/jquery.js"></script>
    <script src="js/mobiscroll.core-2.5.2.js" charset="gb2312" type="text/javascript"></script>
    <!--<script src="js/mobiscroll.core-2.5.2-zh.js" type="text/javascript"></script>-->
    <script src="js/mobiscroll.datetime-2.5.1.js" charset="gb2312" type="text/javascript"></script>
    <!--<script src="js/mobiscroll.datetime-2.5.1-zh.js" type="text/javascript"></script>-->

    <link href="css/mobiscroll.core-2.5.2.css" rel="stylesheet" type="text/css" />
    <link href="css/mobiscroll.animation-2.5.2.css" rel="stylesheet" type="text/css" />
    <script src="js/mobiscroll.android-ics-2.5.2.js" type="text/javascript"></script>
    <link href="css/mobiscroll.android-ics-2.5.2.css" rel="stylesheet" type="text/css" />

    <link rel="stylesheet" type="text/css" href="css/weui.min.css" />
    <link rel="stylesheet" type="text/css" href="css/example.css" />

    <style type="text/css">
        input[name=appDate] {
            text-align: center;
        }

        #reason {
            padding: 10px;
            border: 1px solid #ccc;
            height: 100px;
            box-sizing: border-box;
            outline: none;
            -webkit-appearance: none;
            border-radius: 0;
        }

        #records .weui_cell:not(:last-child) {
            border-bottom: 1px solid #eee;
        }

        .copyright {
            font-size: 0.9em;
            text-align: center;
            color: #333;
            padding: 1em 0;
        }

        /* -------------------------------- 
        Mask
        -------------------------------- */
        .mask.cd-intro-content h1 {
            position: relative;
            padding-bottom: 5px;
            opacity: 1;
            color: transparent;
            overflow: hidden;
        }

            .mask.cd-intro-content h1::after {
                content: attr(data-content);
                position: absolute;
                top: 0;
                left: 0;
                height: 100%;
                width: 100%;
                color: #5cb85c;
                animation-name: cd-reveal-up;
                -webkit-animation-name: cd-reveal-up;
                animation-fill-mode: backwards;
                -webkit-animation-fill-mode: backwards;
            }

            .mask.cd-intro-content h1 span {
                position: relative;
                display: inline-block;
                opacity: 1;
            }

                .mask.cd-intro-content h1 span::before {
                    content: '';
                    position: absolute;
                    top: calc(100% + 3px);
                    left: -1em;
                    height: 2px;
                    width: calc(100% + 2em);
                    background-color: #5cb85c;
                    animation: cd-loading-mask 1s 0.3s both;
                    -webkit-animation: cd-loading-mask 1s 0.3s both;
                }

            .mask.cd-intro-content h1::after {
                animation-duration: 0.4s;
                -webkit-animation-duration: 0.4s;
                animation-delay: 0.7s;
                -webkit-animation-delay: 0.7s;
            }

        @-webkit-keyframes cd-loading-mask {
            0%, 100% {
                transform: scaleX(0);
                -webkit-transform: scaleX(0);
            }

            40%, 60% {
                transform: scaleX(1);
                -webkit-transform: scaleX(1);
            }
        }

        @-webkit-keyframes cd-reveal-up {
            0% {
                opacity: 1;
                transform: translateY(100%);
                -webkit-transform: translateY(100%);
            }

            100% {
                opacity: 1;
                transform: translateY(0);
                -webkit-transform: translateY(0);
            }
        }
    </style>
</head>
<body ontouchstart>
    <div class="weui_toptips weui_warn js_tooltips">格式不对</div>
    <div id="container">
        <div class="cd-intro">
            <div class="hd cd-intro-content mask">
                <h1 class="page_title" data-content="调休申请单"><span>调休申请单</span></h1>
            </div>
        </div>
        <div class="bd">
            <!--列表表单-->
            <div class="weui_cells_title">个人信息</div>
            <div class="weui_cells weui_cells_form">
                <div class="weui_cell">
                    <div class="weui_cell_hd">
                        <label class="weui_label">姓 名</label>
                    </div>
                    <div class="weui_cell_bd weui_cell_primary">
                        <input class="weui_input" type="text" placeholder="请输入姓名(必填)" id="name" value="<%=username %>" />
                    </div>
                </div>
                <div class="weui_cell">
                    <div class="weui_cell_hd">
                        <label class="weui_label">部 门</label>
                    </div>
                    <div class="weui_cell_bd weui_cell_primary">
                        <input id="dept" class="weui_input" type="text" placeholder="所属部门(选填)" value="<%=bmmc %>" />
                    </div>
                </div>
                <div class="weui_cell">
                    <div class="weui_cell_hd">
                        <label class="weui_label">电 话</label>
                    </div>
                    <div class="weui_cell_bd weui_cell_primary">
                        <input id="telno" class="weui_input" type="text" placeholder="联系电话(选填)" value="<%=lxdh %>" />
                    </div>
                </div>
            </div>
            <!--加班信息-->
            <div class="weui_cells_title">加班信息</div>
            <div class="weui_cells weui_cells_form">
                <div class="weui_cell">
                    <div class="weui_cell_hd">
                        <label class="weui_label">加班日期</label>
                    </div>
                    <div class="weui_cell_bd weui_cell_primary">
                        <input type="text" class="weui_input" name="appDate" id="appDate1" placeholder="2015-01-01" />
                    </div>
                </div>
            </div>

            <div class="weui_cells_title">加班原因</div>
            <div class="weui_cells weui_cells_form">
                <div class="weui_cell">
                    <div class="weui_cell_bd weui_cell_primary">
                        <textarea id="reason" rows="50" class="weui_input" placeholder="请输入加班原因....."></textarea>
                    </div>
                </div>

                <div class="weui_cell">
                    <div class="weui_cell_hd">
                        <label class="weui_label">调休日期</label>
                    </div>
                    <div class="weui_cell_bd">
                        <input type="text" class="weui_input" name="appDate" id="appDate3" placeholder="2015-01-01" />
                    </div>
                    <div class="weui_cell_bd">
                        <select class="weui_select" id="Select2" style="height: auto;">
                            <option value="1" selected="selected">上午</option>
                            <option value="2">下午</option>
                        </select>
                    </div>
                </div>
                <div class="weui_cell">
                    <div class="weui_cell_hd">
                        <label class="weui_label" style="text-align: center;">&nbsp;&nbsp;&nbsp;至</label>
                    </div>
                    <div class="weui_cell_bd">
                        <input type="text" class="weui_input" name="appDate" id="appDate4" placeholder="2015-01-01" />
                    </div>
                    <div class="weui_cell_bd">
                        <select class="weui_select" id="Select3" style="height: auto;">
                            <option value="1" selected="selected">上午</option>
                            <option value="2">下午</option>
                        </select>
                    </div>
                </div>
                <div class="weui_cell">
                    <div class="weui_cell_hd">
                        <label class="weui_label">调休天数</label>
                    </div>
                    <div class="weui_cell_bd weui_cell_primary">
                        <label id="txts" class="weui_input" style="text-align: center; font-weight: bold; color: #E64340; display: block;" val="0">0天</label>
                    </div>
                </div>
            </div>

            <!--打卡记录-->
            <div class="weui_cells_title">打卡记录</div>
            <div class="weui_cells weui_cells_form" id="records">
                <div class="weui_cell" id="noresult">
                    <div class="weui_cell_bd weui_cell_primary">
                        <label class="weui_input" style="text-align: center; font-weight: bold; color: #E64340; display: block;">无打卡记录！</label>
                    </div>
                </div>
            </div>

            <div class="bd spacing" style="margin-top: 10px; text-align: center;">
                <div class="button_sp_area">
                    <a href="javascript:;" id="SaveSend" class="weui_btn  weui_btn_primary" style="width: 45%; display: inline-block; margin-right: 15px;">立即提交</a>
                    <a href="javascript:;" id="Save" class="weui_btn  weui_btn_default" style="width: 45%; display: inline-block;">保存草稿</a>
                </div>
            </div>
        </div>
    </div>
    <!--加载动画-->
    <div class="copyright">&copy;2017 利郎信息技术部</div>
    <div id="loadingToast" class="weui_loading_toast" style="display: none;">
        <div class="weui_mask_transparent"></div>
        <div class="weui_toast">
            <div class="weui_loading">
                <div class="weui_loading_leaf weui_loading_leaf_0"></div>
                <div class="weui_loading_leaf weui_loading_leaf_1"></div>
                <div class="weui_loading_leaf weui_loading_leaf_2"></div>
                <div class="weui_loading_leaf weui_loading_leaf_3"></div>
                <div class="weui_loading_leaf weui_loading_leaf_4"></div>
                <div class="weui_loading_leaf weui_loading_leaf_5"></div>
                <div class="weui_loading_leaf weui_loading_leaf_6"></div>
                <div class="weui_loading_leaf weui_loading_leaf_7"></div>
                <div class="weui_loading_leaf weui_loading_leaf_8"></div>
                <div class="weui_loading_leaf weui_loading_leaf_9"></div>
                <div class="weui_loading_leaf weui_loading_leaf_10"></div>
                <div class="weui_loading_leaf weui_loading_leaf_11"></div>
            </div>
            <p class="weui_toast_content">数据加载中</p>
        </div>
    </div>

    <!--保存成功展示页-->
    <!--    <div id="successPage" class="page" style="z-index: 1000; position: fixed;">
        <div class="hd">
            <h1 class="page_title"></h1>
        </div>
        <div class="bd">
            <div class="weui_msg">
                <div class="weui_icon_area"><i class="weui_icon_success weui_icon_msg"></i></div>
                <div class="weui_text_area">
                    <h2 class="weui_msg_title">保存成功</h2>
                    <p class="weui_msg_desc">利郎微信考勤系统</p>
                </div>
                <div class="weui_opr_area">
                    <p class="weui_btn_area">
                        <a href="javascript:;" id="sucConfirm" class="weui_btn weui_btn_primary">确定</a>
                    </p>
                    <br />
                    <p class="weui_btn_area">
                        <a href="javascript:;" id="sucCancle" class="weui_btn weui_btn_default">关闭</a>
                    </p>
                </div>
                <div class="weui_extra_area" style="position: relative;">
                    利郎信息技术部
                   
                </div>
            </div>
        </div>
    </div>-->

    <!--<script type="text/javascript" src="../lilanzAppWVJBridge.js"></script>-->
    <script type="text/javascript" src="js/wxsaveend.js"></script>
    <script type="text/javascript">
        //用户信息
        var username = "<%=username%>", userid = "<%=userid%>", rybh = "<%=rybh%>", ryid = "<%=ryid%>", flowid = "333";

        $(function () {
            var currYear = (new Date()).getFullYear();
            var opt = {};
            opt.date = { preset: 'date' };
            opt.datetime = { preset: 'datetime' };
            opt.time = { preset: 'time' };
            opt.default = {
                theme: 'android-ics light', //皮肤样式
                display: 'modal', //显示方式 
                mode: 'scroller', //日期选择模式
                lang: 'zh',
                startYear: currYear - 10, //开始年份
                endYear: currYear + 10 //结束年份
            };

            $("#appDate1").val('').scroller('destroy').scroller($.extend(opt['date'], opt['default']));
            $("#appDate3").val('').scroller('destroy').scroller($.extend(opt['date'], opt['default']));
            $("#appDate4").val('').scroller('destroy').scroller($.extend(opt['date'], opt['default']));

            llApp.init();
        });

        function loadworktime(_rybh, _jbrq) {
            //加载加班日期的打卡记录
            $.ajax({
                type: "POST",
                timeout: 4000,
                contentType: "application/x-www-form-urlencoded; charset=utf-8",
                url: "DataDealInterface.aspx",
                data: { ctrl: "loadWorkTimes", rybh: _rybh, jbrq: _jbrq },
                success: function (msg) {
                    if (msg.indexOf("Successed") > -1) {
                        msg = msg.replace("Successed", "");
                        var dkjlHTML = "";
                        if (msg != "") {
                            var str1 = msg.split(",");
                            for (var i = 0; i < str1.length; i++) {
                                dkjlHTML += "<div class='weui_cell'><div class='weui_cell_bd weui_cell_primary'>";
                                dkjlHTML += "<label class='weui_input' style='text-align: center; font-weight: bold; color: #333; display: block;'>";
                                var str2 = str1[i].split("|");
                                for (var j = 0; j < str2.length; j++) {
                                    if (j == 2) {
                                        dkjlHTML += dkWeek(str2[j]) + "&nbsp;|&nbsp;";
                                        j++;
                                    }
                                    if (i % 2 == 1 && j == str2.length - 1) str2[j] = "下班";
                                    dkjlHTML += str2[j] + "&nbsp;|&nbsp;";
                                }
                                dkjlHTML += "</label></div></div>";
                            }//end for                               
                            var tmp = "<div class='weui_cell' id='noresult'>" + $("#noresult").html() + "</div>";
                            $("#records").children().remove();
                            $("#records").append(tmp);
                            $("#records").append(dkjlHTML);
                            $("#noresult").hide();
                        } else {
                            //无打卡记录
                            var tmp = "<div class='weui_cell' id='noresult'>" + $("#noresult").html() + "</div>";
                            $("#records").children().remove();
                            $("#records").append(tmp);
                        }
                    } else
                        alert(msg);
                },
                error: function (XMLHttpRequest, textStatus, errorThrown) {
                    showInfo("加载打卡记录时服务器错误：" + XMLHttpRequest.status + "|" + XMLHttpRequest.readyState + "|" + textStatus);
                }
            });
        }

        //选择完加班日期后进行验证
        $("#appDate1").change(function () {
            $(".weui_toast_content").text("正在验证日期的合法性,请稍候...");
            $('#loadingToast').show();
            var jbrq = $("#appDate1").val();
            if (!checkjbrq(jbrq)) {
                //不是周天
                $.ajax({
                    type: "POST",
                    timeout: 2000,
                    contentType: "application/x-www-form-urlencoded; charset=utf-8",
                    url: "DataDealInterface.aspx",
                    data: { ctrl: "checkHoliday", holidayType: "0", jbrq: jbrq },
                    success: function (msg) {
                        $('#loadingToast').hide();
                        $(".weui_toast_content").text("正在加载数据...");
                        if (msg.indexOf("Successed") > -1) {
                            var rt = msg.replace("Successed", "");
                            if (rt != "1") {
                                showInfo("加班日期不是周日也不是假期，无法调休！请重新选择日期！");
                                $("#appDate1").val("");
                                var tmp = "<div class='weui_cell' id='noresult'>" + $("#noresult").html() + "</div>";
                                $("#records").children().remove();
                                $("#records").append(tmp);
                            } else {
                                loadworktime(rybh, $("#appDate1").val());//加载打卡记录
                                if ($("#appDate3").val() != "" && checktxrq() == 0) {
                                    showInfo("只能在加班日期之后调休！");
                                    $("#txts").attr("val", 0);
                                    $("#txts").text("0天");
                                    return;
                                }
                                calDateDiff();
                            }
                        } else {
                            showInfo(msg);
                            $("#appDate1").val("");
                        }
                    },
                    error: function (XMLHttpRequest, textStatus, errorThrown) {
                        $('#loadingToast').hide();
                        $(".weui_toast_content").text("正在加载数据...");
                        $("#appDate1").val("");
                        showInfo("服务器错误：" + XMLHttpRequest.status + "|" + XMLHttpRequest.readyState + "|" + textStatus);
                    }
                });
            } else {
                $.ajax({
                    type: "POST",
                    timeout: 2000,
                    contentType: "application/x-www-form-urlencoded; charset=utf-8",
                    url: "DataDealInterface.aspx",
                    data: { ctrl: "checkHoliday", holidayType: "3", jbrq: jbrq },
                    success: function (msg) {
                        $('#loadingToast').hide();
                        $(".weui_toast_content").text("正在加载数据...");
                        if (msg.indexOf("Successed") > -1) {
                            var rt = msg.replace("Successed", "");
                            if (rt == "1") {
                                showInfo("亲，周末上班，不能调休！");
                                $("#appDate1").val("");
                            } else {
                                loadworktime(rybh, $("#appDate1").val());//加载打卡记录
                                if ($("#appDate3").val() != "" && checktxrq() == 0) {
                                    showInfo("只能在加班日期之后调休！");
                                    $("#txts").attr("val", 0);
                                    $("#txts").text("0天");
                                    return;
                                }
                                calDateDiff();
                            }
                        } else {
                            showInfo(msg);
                            $("#appDate1").val("");
                        }
                    },
                    error: function (XMLHttpRequest, textStatus, errorThrown) {
                        $('#loadingToast').hide();
                        $(".weui_toast_content").text("正在加载数据...");
                        $("#appDate1").val("");
                        showInfo("服务器错误：" + XMLHttpRequest.status + "|" + XMLHttpRequest.readyState + "|" + textStatus);
                    }
                });
            }
        });

        //保存草稿，仅仅生成单据并不发起办理
        $("#Save").click(function () {
            beforeSave("Save");
        });

        //立即保存，保存单据后并自动发起第一次的办理
        $("#SaveSend").click(function () {
            beforeSave("SaveAndSend");
        });

        function beforeSave(savetype) {
            var name = $("#name").val();
            if (name == "") {
                showInfo("姓名不能为空！");
                return;
            }

            var jbrq0 = $("#appDate1").val();
            if (jbrq0 == "") {
                showInfo("请选择加班日期！");
                return;
            }

            var jbyy = $("#reason").val();
            if (jbyy == "") {
                showInfo("加班原因不能为空！");
                return;
            }

            var txrq0 = $("#appDate3").val();
            if (txrq0 == "") {
                showInfo("请选择调休开始日期！");
                return;
            }

            var txrq1 = $("#appDate4").val();
            if (txrq1 == "") {
                showInfo("请选择调休结束日期！");
                return;
            }
            var txts = parseFloat($("#txts").attr("val"));
            if ($("#txts").attr("val") <= 0) {
                showInfo("调休天数无效！");
                return;
            }

            validjbrq(savetype);
        }

        //验证后的提交数据
        function uploadData(savetype) {
            //数据检验完毕，开始保存数据            
            var tzid = 1;
            var name = $("#name").val();
            var lxdh = $("#telno").val();
            var jbrq0 = $("#appDate1").val();
            var txrq0 = $("#appDate3").val();
            var txrq1 = $("#appDate4").val();
            var txts = parseFloat($("#txts").attr("val"));
            var jbyy = $("#reason").val();
            var ksday = $("#Select2").val();
            var jsday = $("#Select3").val();
            var jsonStr = { tzid: tzid, rybh: rybh, lx: "4", kssj: txrq0, jssj: txrq1, qjsj: txts, qjyy: escape(jbyy), lxdh: lxdh, zdr: username, ryid: ryid, ksday: ksday, jsday: jsday, jbrq: jbrq0, flowid: flowid, userid: userid };
            //alert(JSON.stringify(jsonStr)); return;
            $(".weui_toast_content").text("正在保存，请稍候...");
            $('#loadingToast').show();
            $.ajax({
                type: "POST",
                timeout: 2000,
                contentType: "application/x-www-form-urlencoded; charset=utf-8",
                url: "DataDealInterface.aspx",
                data: { ctrl: "SaveData", jsonData: JSON.stringify(jsonStr), savetype: savetype },
                success: function (msg) {
                    $('#loadingToast').hide();
                    $(".weui_toast_content").text("正在加载数据...");
                    if (msg.indexOf("Successed") > -1) {
                        //保存成功
                        LLOA.showpage("", "", "好的,马上办理", "离开", function () {
                            //window.location.href = "http://sj.lilang.com:186/LLsj/OnlineLogin.aspx?type=KaoQinDaiBan";
                            window.location.href = "../docList.aspx";
                        }, function () { WeixinJSBridge.call('closeWindow'); });
                    } else {
                        //保存失败
                        showInfo(msg);
                        return false;
                    }
                },
                error: function (XMLHttpRequest, textStatus, errorThrown) {
                    $('#loadingToast').hide();
                    $(".weui_toast_content").text("正在加载数据...");
                    showInfo("服务器错误：" + XMLHttpRequest.status + "|" + XMLHttpRequest.readyState + "|" + textStatus);
                    return false;
                }
            });
        }

        function showInfo(text) {
            $(".js_tooltips").text(text);
            $('.js_tooltips').show();
            setTimeout(function () {
                $('.js_tooltips').hide();
            }, 3000);
        }

        //判断加班日期是否为周日或者是节假日
        function checkjbrq(jbrq) {
            if (jbrq == "" || jbrq == undefined || jbrq == null)
                return false;
            var jbrqName = new Date(Date.parse(jbrq.replace(/-/g, "/")));
            var weekDay = ["星期天", "星期一", "星期二", "星期三", "星期四", "星期五", "星期六"]
            if (weekDay[jbrqName.getDay()] == "星期天")
                return true;
            else
                return false;
        }

        function dkWeek(X) {
            var i = X;
            var week = '';
            switch (i) {
                case "1":
                    week = "星期天";
                    break;
                case "2":
                    week = "星期一";
                    break;
                case "3":
                    week = "星期二";
                    break;
                case "4":
                    week = "星期三";
                    break;
                case "5":
                    week = "星期四";
                    break;
                case "6":
                    week = "星期五";
                    break;
                case "7":
                    week = "星期六";
                    break;
                default:
                    week = "false";
            }
            return week;
        }

        $("#appDate3").change(function () { calDateDiff() });
        $("#appDate4").change(function () { calDateDiff() });
        $("#Select2").change(function () { calDateDiff() });
        $("#Select3").change(function () { calDateDiff() });

        //计算两个日期的间隔天数
        function calDateDiff() {
            var ksrq = $("#appDate3").val();
            var jsrq = $("#appDate4").val();
            if (ksrq == "" || jsrq == "") return;
            var _ksrq = new Date(ksrq.replace(/-/g, "/")).getTime();
            var _jsrq = new Date(jsrq.replace(/-/g, "/")).getTime();
            var zts = (_jsrq - _ksrq) / (24 * 60 * 60 * 1000) + 1;
            var ks_sj = $("#Select2").val();
            var js_sj = $("#Select3").val();
            if (ks_sj == "2") {
                zts = zts - 0.5;
            }
            if (js_sj == "1") {
                zts = zts - 0.5;
            }

            $("#txts").attr("val", zts);
            $("#txts").text(zts + "天");

            if (checktxrq() == 0) {
                showInfo("只能在加班日期之后调休！");
                $("#txts").attr("val", 0);
                $("#txts").text("0天");
            }
        }

        //判断调休日期是否在加班日期之后
        function checktxrq() {
            var day1 = getDayDiff(new Date($("#appDate1").val().replace(/-/g, "/")), new Date($("#appDate3").val().replace(/-/g, "/")));
            if (day1 <= 0)
                return 0;
            else
                return 1;
        }

        function getDayDiff(d1, d2) {
            return (d2.getTime() - d1.getTime()) / (24 * 60 * 60 * 1000)
        }

        //检查是否已经调休过了
        function validjbrq(savetype) {
            $(".weui_toast_content").text("正在检查加班日期的有效性...");
            $('#loadingToast').show();
            var jbrq = $("#appDate1").val();
            var txts = $("#txts").attr("val");
            $.ajax({
                type: "POST",
                timeout: 2000,
                contentType: "application/x-www-form-urlencoded; charset=utf-8",
                url: "DataDealInterface.aspx",
                data: { ctrl: "checkWorkDay", jbrq: jbrq, rybh: rybh, id: "0", txts: txts },
                success: function (msg) {
                    $('#loadingToast').hide();
                    $(".weui_toast_content").text("正在加载数据...");                    
                    if (msg.indexOf("Successed") > -1) {
                        var rt = msg.replace("Successed", "");
                        if (rt == "0") {
                            showInfo("调休天数超限,不允许再调了,最多只能调一天！或者是选择的加班日期之前已经调休过了！");
                            $("#appDate1").val("");
                            $("#appDate3").val("");
                            $("#appDate4").val("");
                            $("#txts").attr("val", 0);
                            $("#txts").text("0天");
                            return false;
                        } else
                            uploadData(savetype);
                    } else {
                        showInfo(msg);
                        $("#appDate1").val("");
                        return false;
                    }
                },
                error: function (XMLHttpRequest, textStatus, errorThrown) {
                    $('#loadingToast').hide();
                    $(".weui_toast_content").text("正在加载数据...");
                    showInfo("服务器错误：" + XMLHttpRequest.status + "|" + XMLHttpRequest.readyState + "|" + textStatus);
                    return false;
                }
            });

            return true;
        }
    </script>
</body>
</html>
