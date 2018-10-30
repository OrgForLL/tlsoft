(function(window, undefined) {
    var history = [];
    var isPop = false;
    var url = "ReportInterface.aspx";
    var report = {
        init: function(){
            this.bindEvent();
            FastClick.attach(window.document.body);
            onLoading("加载中...");
            report.setDate();
            report.getCompany();
            $("#filter").click();
            
            Number.prototype.formatMoney = function (places, symbol, thousand, decimal) {
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
            $(".layer").click(function(){
                $(".criteria").css("animation","fideout 400ms");
                isPop = true;
            });

            $(".criteria").click(function(e) {
                e.stopPropagation();
            });

            $("#filter").click(function(){
                $(".layer").show();
                $(".criteria").css("animation","fidein 400ms");
                isPop = false;
            });

            $(".criteria")[0].addEventListener("webkitAnimationEnd", function(){
                $(".criteria").css("animation","none");
                if(isPop ) {
                    $(".layer").hide();
                }
            });

            $(".classified").on('click','li', function(){
                $(".classified").find("li").removeClass("onchoose");
                $(this).addClass('onchoose');
            });

            $(".detail").scroll(throttle(bindscroll, 20, 10));
            
            $("#complete").click(function() {
                var filters = report.getFilters();
                filters = JSON.stringify(filters);
                report.getData(filters);
            });
            
            $("#submit").click(function() {
                var condition = $("#search input").val();
                var filters = report.getFilters();
                if(condition) {
                    filters.khdmmc = condition;
                    filters = JSON.stringify(filters);
                    report.getData(filters);
                }else {
                    filters = JSON.stringify(filters);
                    report.getData(filters);
                }
            });
        },
        
        getFilters: function() {
            var filters = {};
            filters.ksrq = $("#dateStart").val();
            filters.jsrq = $("#dateEnd").val();
            filters.khid = $("#khid").val();
            filters.khfl = $("#khfl").val();
            filters.kbxz = $("#kbxz").val();
            return filters;
        },
        
        getCompany: function() {
            $.ajax({
                url: url,
                type: "GET",
                data: {
                    method: "getExpFil"
                },
                dataType: "JSON",
                timeout: 10000
            }).then(function(data) {
                if(data.code == "200") {
                    var khid = $("#khid");
                    var khfl = $("#khfl");
                    var khidList = data.data.khid;
                    var khflList = data.data.khfl;
                    var khidhtml = '', khflhtml = '';
                    
                    for(var i = 0; i < khidList.length; i++) {
                        khidhtml = khidhtml + "<option value=" + khidList[i].dm + " >" + khidList[i].mc + "</option>";
                    }
                    
                    for(var i = 0; i < khflList.length; i++) {
                        khflhtml = khflhtml + "<option value=" + khflList[i].dm + " >" + khflList[i].mc + "</option>";
                    }
                    
                    khid.append(khidhtml);
                    khfl.append(khflhtml);
                    $("#myLoading").hide();
                }else {
                    onLoading(data.msg);
                    setTimeout(function(){
                        $("#myLoading").hide();
                    },3000);
                }
            }).fail(function() {
                onLoading("数据查询超时！");
                setTimeout(function(){
                    $("#myLoading").hide();
                },3000);
            });
        },
        
        getData: function(filters) {
            onLoading();
            $.ajax({
                url: url,
                type: "POST",
                data: {
                    method: "getExpRpt",
                    filters: filters
                },
                dataType: "JSON"
            }).then(function(data) {
                if(data.code == "200") {
                    var list = data.data;
                    var detail = $(".detail tbody");
                    var totaltable = $(".total tbody");
                    var total = {
                        khdm: "合计",
                        khmc: "-",
                        ys_hjfy: 0,
                        sj_hjfy: 0,
                        wlsr: 0,
                        wlzc: 0,
                        wlce: 0,
                        gsfyzb: 0,
                        ddfyzb: 0,
                        jc_hjfy: 0
                    };
                    var html = '';
                    
                    template.helper('formatMoney',function(data){
                        return parseFloat(data).formatMoney(2,"");
                    });
                    
                    for(var i = 0; i < list.length; i++) {
                        html = html + template("detail",list[i]);
                        for(key in total) {
                            if( typeof(total[key]) == "number" ) {
                                total[key] = total[key] + list[i][key];
                            }
                        }
                    }
                    
                    detail.empty().append(html);
                    totaltable.empty().append(template("detail",total));
                    
                    setTimeout(function(){
                        $("#myLoading").hide();
                        $(".layer").click();
                    },1000);
                }else {
                    onLoading(data.msg);
                    setTimeout(function(){
                        $("#myLoading").hide();
                    },3000);
                }
            }).fail(function() {
                onLoading("数据查询超时！");
                setTimeout(function(){
                    $("#myLoading").hide();
                },3000);
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
    
    var setZero = function(day) {
        return day < 10 ? '0' + day : day;
    };
    
    var bindscroll = function(){
        var left = this.scrollLeft * -1;
        document.querySelector(".shade table").style.transform = "translate(" + left + "px,0)";
        document.querySelector(".total table").style.transform = "translate(" + left + "px,0)";
    };

    var throttle = function(func, wait, mustRun){
        var timeout,
            startTime = new Date();

        return function() {
            var context = this,
                args = arguments,
                curTime = new Date();

            clearTimeout(timeout);
            if(curTime - startTime >= mustRun) {
                func.apply(context,args);
                startTime = curTime;
            }else {
                timeout = setTimeout(func, wait);
            }
        };
    }
    
    /* 显示加载状态 */
    function onLoading(msg){
        $(".load_text").text(msg || '加载中...');
        $("#myLoading").show();
    }
    
    window.report = report;
})(window)