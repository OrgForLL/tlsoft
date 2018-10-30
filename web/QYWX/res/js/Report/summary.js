(function(window, undefined) {
    var history = [];
    var isPop = false;
    var url = "ReportInterface.aspx";
    var summary = {
        init: function() {
            this.bindEvent();
            FastClick.attach(window.document.body);
            onLoading("加载中...");
            summary.setDate();
            summary.getCompany();
            $("#filter").click();

            Number.prototype.formatMoney = function(places, symbol, thousand, decimal) {
                places = !isNaN(places = Math.abs(places)) ? places : 2;
                symbol = symbol !== undefined ? symbol : "¥";
                thousand = thousand || ",";
                decimal = decimal || ".";
                var number = this,
                    negative = number < 0 ? "-" : "",
                    i = parseInt(number = Math.abs(+number || 0).toFixed(places), 10) + "",
                    j = (j = i.length) > 3 ? j % 3 : 0;
                return symbol + negative + (j ? i.substr(0, j) + thousand : "") + i.substr(j).replace(/(\d{3})(?=\d)/g, "$1" + thousand) + (places ? decimal + Math.abs(number - i).toFixed(places).slice(2) : "");
            };
        },
        bindEvent: function() {
            $(".layer").click(function() {
                $(".criteria").css("animation", "fideout 400ms");
                isPop = true;
            });

            $(".criteria").click(function(e) {
                e.stopPropagation();
            });

            $("#filter").click(function() {
                $(".layer").show();
                $(".criteria").css("animation", "fidein 400ms");
                isPop = false;
            });

            $(".criteria")[0].addEventListener("webkitAnimationEnd", function() {
                $(".criteria").css("animation", "none");
                if (isPop) {
                    $(".layer").hide();
                }
            });

            $(".classified").on('click', 'li', function() {
                $(".classified").find("li").removeClass("onchoose");
                $(this).addClass('onchoose');
            });

            $(".detail").scroll(throttle(bindscroll, 20, 10));

            $("#complete").click(function() {
                var filters = summary.getFilters();
                filters = JSON.stringify(filters);
                summary.getData(filters);
            });

            $("#fykm").click(function() {
                if (!$(this).attr("checked")) {
                    $(this).attr("checked", "checked");
                } else {
                    $(this).removeAttr("checked");
                }
            });

            $("#submit").click(function() {
                var condition = $("#search input").val();
                var filters = summary.getFilters();
                if (condition) {
                    filters.khdmmc = condition;
                    filters = JSON.stringify(filters);
                    summary.getData(filters);
                } else {
                    filters = JSON.stringify(filters);
                    summary.getData(filters);
                }
            });
        },

        getFilters: function() {
            var filters = {};
            filters.ksrq = $("#dateStart").val();
            filters.jsrq = $("#dateEnd").val();
            filters.khid = $("#khid").val();
            filters.tpzt = $("#tpzt").val();
            filters.fykm = $("#fykm").attr("checked") ? 1 : 0;
            return filters;
        },

        getCompany: function() {
            $.ajax({
                url: url,
                type: "GET",
                data: {
                    method: "getFinFil"
                },
                dataType: "JSON",
                timeout: 10000
            }).then(function(data) {
                if (data.code == "200") {
                    var khid = $("#khid");
                    var list = data.data.khid;
                    var html = '';

                    for (var i = 0; i < list.length; i++) {
                        html = html + "<option value=" + list[i].dm + " >" + list[i].mc + "</option>";
                    }
                    khid.append(html);
                    $("#myLoading").hide();
                } else {
                    onLoading(data.msg);
                    setTimeout(function() {
                        $("#myLoading").hide();
                    }, 3000);
                }
            }).fail(function() {
                onLoading("数据查询超时！");
                setTimeout(function() {
                    $("#myLoading").hide();
                }, 3000);
            });
        },

        getData: function(filters) {
            onLoading();
            $.ajax({
                url: url,
                type: "POST",
                data: {
                    method: "getFinRpt",
                    filters: filters
                },
                dataType: "JSON"
            }).then(function(data) {
                if (data.code == "200") {
                    var list = data.data;
                    var detail = $(".detail tbody");
                    var totaltable = $(".total tbody");
                    var total = {
                        djkhdm: "合计",
                        djkhmc: "-",
                        hk_jh: 0,
                        hk_sj: 0,
                        hk_ce: 0,
                        fy_jh: 0,
                        fy_sj: 0,
                        fy_ce: 0,
                        kz_je: 0,
                        fykz_hj: 0
                    };
                    var html = '';

                    template.helper('formatMoney', function(data) {
                        return parseFloat(data).formatMoney(2, "");
                    });

                    for (var i = 0; i < list.length; i++) {
                        html = html + template("detail", list[i]);
                        for (var i = 0; i < list.length; i++) {
                            html = html + template("detail", list[i]);
                            for (key in total) {
                                if (typeof(total[key]) == "number") {
                                    total[key] = total[key] + list[i][key];
                                }
                            }
                        }
                    }

                    detail.empty().append(html);
                    totaltable.empty().append(template("detail", total));
                    setTimeout(function() {
                        $("#myLoading").hide();
                        $(".layer").click();
                    }, 1000);
                } else {
                    onLoading(data.msg);
                    setTimeout(function() {
                        $("#myLoading").hide();
                    }, 3000);
                }
            }).fail(function() {
                onLoading("数据查询超时！");
                setTimeout(function() {
                    $("#myLoading").hide();
                }, 3000);
            });
        },

        setDate: function() {
            var dateStart = $("#dateStart");
            var dateEnd = $("#dateEnd");
            var date = new Date();
            var y = date.getFullYear();
            var m = setZero(date.getMonth() + 1);
            var d = setZero(date.getDate());
            dateStart.val(y + "-" + m + "-01");
            dateEnd.val(y + "-" + m + "-" + d);
        }
    }

    /* 校验返回的JSON数据格式 */
    var validation = function(data) {
        try {
            var data = JSON.parse(data);
            return data;
        } catch (e) {
            onLoading("JSON数据格式错误！");
        }
    }

    var setZero = function(day) {
        return day < 10 ? '0' + day : day;
    }

    var bindscroll = function() {
        var left = this.scrollLeft * -1;
        document.querySelector(".shade table").style.transform = "translate(" + left + "px,0)";
        document.querySelector(".total table").style.transform = "translate(" + left + "px,0)";
        // $(".shade th:not(.fixed)").css("transform", "translate("+ left + "px, 0px)"); 
        // $(".total td:not(.fixed)").css("transform", "translate("+ left + "px, 0px)"); 
        // $(".detail table .fixed").css("transform", "translate(0px,"+ this.scrollTop*-1 + "px)");  
    };

    var throttle = function(func, wait, mustRun) {
        var timeout,
            startTime = new Date();

        return function() {
            var context = this,
                args = arguments,
                curTime = new Date();

            clearTimeout(timeout);
            if (curTime - startTime >= mustRun) {
                func.apply(context, args);
                startTime = curTime;
            } else {
                timeout = setTimeout(func, wait);
            }
        };
    }

    /* 显示加载状态 */
    function onLoading(msg) {
        $(".load_text").text(msg || '加载中...');
        $("#myLoading").show();
    }

    window.summary = summary;
})(window)
