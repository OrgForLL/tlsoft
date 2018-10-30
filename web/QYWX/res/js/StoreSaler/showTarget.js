define(function (require, exports, module) {
    var mdid = "", type = "";
    var init = function (mdid, type) {
        mdid = mdid; type = type;
        $(".menu > a").click(function (e) {
            type = $(e.target).attr("rel");
            $(".menu .current-select").removeClass("current-select").removeAttr("style");
            switch (type) {
                case "by":                    
                    $(e.target).addClass("current-select");
                    loadData(mdid, type);
                    break;
                case "sy":                    
                    $(e.target).addClass("current-select").css("background-color", "#629401");
                    loadData(mdid, type);
                    break;
                case "jn":                    
                    $(e.target).addClass("current-select").css("background-color", "#e63863");
                    loadData(mdid, type);
                    break;
                case "qn":                    
                    $(e.target).addClass("current-select").css("background-color", "#087583");
                    loadData(mdid, type);
                    break;
                default:
                    showMessage("error", "未知参数!");
            }
        });

        $(".header .fa-angle-left").click(function () {
            window.history.go(-1);
        });

        loadData(mdid, type);
    }

    var liTemp = "<li><div class='target-item'>"
                + "<div class='headimg backimg' style='background-image:url(#headimg#);'></div>"
                + "<p class='name'>#xm#</p>"
                + "<p>目标:<span>#target#</span>&nbsp;&nbsp;实际:<span>#sales#</span>&nbsp;&nbsp;完成率:<span>#process#</span></p></div>"
                + "<div class='process #bgcolor#'></div><div class='process-mask' style='transform: translate(0,0); -webkit-transform: translate(0,0);' process='#pro#'>"
                + "<p class='pro-val'>#process#</p></div></li>";
    //加载数据
    var loadData = function (mdid, type) {
        showMessage("loading","正在加载...");
        $.ajax({
            url: "../../project/storesaler/RankCore.aspx?ctrl=GetRySales",
            type: "POST",
            dataType: "text",            
            timeout: 10000,
            data:{mdid:mdid, type:type},
            error: function (XMLHttpRequest, textStatus, errorThrown) {
                showMessage("error", "您的网络好像出了点问题,请稍后重试...");
            },
            success: function (data) {
                if (data.indexOf("Error") > -1) {
                    showMessage("error", data.replace("Error:", ""));
                } else {
                    var htmlStr = "";
                    var obj = JSON.parse(data);
                    var len = obj.rows.length;
                    for (var i = 0; i < len; i++) {
                        var row = obj.rows[i];
                        var target = row.target == "0.0" ? "未设置" : row.target + 'W';
                        var sales = parseFloat(row.Sales / 10000).toFixed(1) + 'W';
                        var process = parseFloat(row.Process * 100).toFixed(1);
                        htmlStr += liTemp.replace("#headimg#", row.headimg).replace("#xm#", "NO." + (i + 1) + "&nbsp;&nbsp;" + row.xm).replace("#target#", target).replace("#sales#", sales).replace("#bgcolor#", "probg-" + type).replace(new RegExp("#process#", "g"), process + '%').replace("#pro#", process);
                    }//end for
                    $(".target-list").children().remove();
                    $(".target-list").append(htmlStr);
                    showProgress();
                    showMessage("successed", "获取成功!");
                }
            }
        });
    };

    var showProgress = function () {
        setTimeout(function () {
            var pros = $(".process-mask");
            for (var i = 0; i < pros.length; i++) {
                var obj = pros.eq(i);
                var val = obj.attr("process");
                $("p", obj).text(val + '%');
                if (parseFloat(val).toFixed(1) >= 100)
                    obj.css("transform", "translate(100%,0)").css("-webkit-transform", "translate(100%,0)");
                else
                    obj.css("transform", "translate(" + val + "%,0)").css("-webkit-transform", "translate(" + val + "%,0)");
            }
        }, 500);
    }

    //获取URL参数
    var getQueryString = function (name) {
        var reg = new RegExp("(^|&)" + name + "=([^&]*)(&|$)", "i");
        var r = window.location.search.substr(1).match(reg);
        if (r != null)
            return unescape(r[2]);
        else
            return "";
    }

    //提示层
    var showMessage = function (type, txt) {
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
                setTimeout(function () {
                    $(".mask").fadeOut(200);
                }, 500);
                break;
            case "error":
                $(".mask .fa").removeAttr("class").addClass("fa fa-2x fa-close (alias)");
                $("#loadtext").text(txt);
                $(".mask").show();
                setTimeout(function () {
                    $(".mask").fadeOut(400);
                }, 2000);
                break;
            case "warn":
                $(".mask .fa").removeAttr("class").addClass("fa fa-2x fa-warning (alias)");
                $("#loadtext").text(txt);
                $(".mask").show();
                setTimeout(function () {
                    $(".mask").fadeOut(400);
                }, 800);
                break;
        }
    }


    //对外提供的接口列表
    return {
        init:init,
        getQueryString: getQueryString,
        showMessage: showMessage
    };
});