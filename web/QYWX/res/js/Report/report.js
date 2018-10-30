(function(window, undefined) {
    var history = [];
    var isPop = false;
    var url = "ReportInterface.aspx";
    var report = {
        init: function(){
            this.bindEvent();
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
                console.log(filters);
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
        }
    }
    
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