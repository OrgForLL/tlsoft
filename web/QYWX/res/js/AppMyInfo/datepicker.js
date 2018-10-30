(function( window ){
    var nowDay;
    var ynow;
    var mnow;
    var dnow;
    var firstDay;
    var firstWeek;
    var monthDay;
    var trLine;
    var today = {
        year: 0,
        month: 0,
        day: 0
    };
    
    /* 判断闰年，二月加一天 */
    function isLeap(year){
        return (year%100==0?res=(year%400==0?1:0):res=(year%4==0?1:0));
    }
    
    var getDate = {
        /* 设置时间 */
        setDay: function(){
            if(arguments.length == 0){
                nowDay = new Date();
                today.year = nowDay.getFullYear();
                today.month = nowDay.getMonth() + 1;
                today.day = nowDay.getDate();
            }else{
                nowDay = new Date(arguments[0],arguments[1]);
            }

            ynow = nowDay.getFullYear();
            mnow = nowDay.getMonth();
            dnow = nowDay.getDate();
            firstDay = new Date(ynow,mnow,1);
            firstWeek = nowDay.getDay();
            monthDay = new Array(31,28+isLeap(ynow),31,30,31,30,31,31,30,31,30,31);
            trLine = Math.ceil((monthDay[mnow] + firstWeek)/7);
        },
        
        /* 获取当前年份 */
        getYear: function(){
            return ynow;
        },
        
        /* 获取当前月份 */
        getMonth: function(){
            return mnow + 1;
        },
        
        /* 获取当前月份缩写 */
        getDateMonth: function(){
            return nowDay.toDateString().substring(4,7);
        },
        
        /* 获取当前天数 */
        getDay: function(){
            return dnow;
        },
        
        /* 获取当前星期 */
        getWeek: function(){
            return firstWeek;
        },
        
        /* 获取当前月份日期行数 */
        gettrLine: function(){
            return trLine;
        },
        
        /* 月份第一个星期 */
        getfirstDay: function(){
            if(arguments.length == 0){
                return firstDay.getDay();
            }else if(arguments.length == 2){
                return new Date(arguments[0],arguments[1],1).getDay();
            }
        },
        
        /*  获取当前月份天数 */
        getMonthDay: function(){
            return monthDay[mnow];
        },
        
        isToday: function(day){
            if(ynow == today.year && mnow + 1 == today.month && day == today.day){
                return true;
            }else{
                return false;
            }
        },

        /* 判断是否签到 */
        isSign: function(){
            var month = this.getMonth() < 10 ? "0" + this.getMonth() : this.getMonth();
            var rq = ynow + "-" + month + "-01";
            $.ajax({
                url: 'http://tm.lilanz.com/qywx/api/appmycore.ashx',
                type: 'GET',
                dataType: 'html',
                data: {
                    "action": "GetUserCheckRecords",
                    "rq": rq,
                    "apptoken": apptoken
                }
            }).then(function(data) {
                var tr = $(data).find("tr");
                for(var i = 0; i < tr.length; i = i + 2) {
                    var date = $(tr[i]).find("td");
                    var sign = $(tr[i + 1]).find("td")
                    for(var j = 1; j < date.length; j++) {
                        signData[$(date[j]).html().split("&nbsp;")[0]] = $(sign[j]).html();
                    }
                }
                getCanlendar();
                setTimeout(function() {
                    $(".sign").show();
                    $(".sign-bd").show();
                    setSignDate();
                    $("#myLoading").hide();
                },500);
            }).catch(function(err) {
                console.log("error: " + err);
            });
            
        }
    }
    
    var outputobj = function(){
        getDate.setDay();
        
        return getDate;
    }
    
    window.getCanlender = new outputobj();
    
}) ( window )