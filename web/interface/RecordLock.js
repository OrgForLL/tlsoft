document.write("<script src='../js_ui/jquery-1.4.2.min.js'><\/script>");
document.write("<script src='../JSON/json2.js'><\/script>");
var _lock, _times, SI, _errTimes;
var uid, uname, token;
var btnObj = new Object();//  btnObj["disabled"]="保存";btnObj["hidden"] = "设置";
var isAlert = false;
function LockRecordsMain(recordsObj,lockNow,checkTimes) {
    //obj 对象数组 {rows:[{"tablename":"",IDS:[ids]},{"tablename":"",IDS:[]}..]}
    //lockNow 发现记录没有锁定时是否马上锁定
    //checktimes 检查次数 0 为一直检查记录的占用状态

    if (_lock) return;
    _lock = true;

    if (SI != null && SI != undefined && checkTimes != 0 && _times >= checkTimes || _errTimes > 10) {
        clearInterval(SI);
        return;
    }

    $.ajax({
        type: "post", //AJAX请求类型
        contentType: "application/x-www-form-urlencoded; charset=utf-8",
        url: "../interface/LockRecords.aspx", //请求url        
        cache: false,  //无缓存
        timeout: 1000 * 2,  //AJAX请求超时时间  
        data: { datas: JSON.stringify(recordsObj), uid: uid, uname: uname, token: token, ctrl: "CheckLockStatus" },
        success: function (data) {//data warn:有人占用 successd:成功
            _times++;
            _errTimes = 0;
            _lock = false;            
            if (data.indexOf("warn:") > -1 && !isAlert) {
                setStatic(true);
                alert("您打开的记录目前已被"+data.replace("warn:", "")+"打开，请注意数据的有效性！");
                isAlert = true;
            } else if (data.indexOf("successd:") > -1) {
                setStatic(false);
                isAlert = false;
            }
        },
        error: function (XMLHttpRequest, textStatus, errorThrown) {
            _times++;
            _errTimes++;
            _lock = false;
            setStatic(false);
            isAlert = false;
            //if (textStatus == "timeout") {
            //    _times++;
            //    _lock = false;
            //} else if (textStatus == "error") {
            //    clearInterval(SI);//出现错误时停止请求                
            //}
        }
    });

    return;
}

function LockRecords(recordsObj, lockNow, checkTimes) {
    if (recordsObj == null || recordsObj == undefined)
        return;    
    _times = 0;
    _lock = false;
    _errTimes = 0;//发生错误时最大重试次数
    //token = guid();//生成本次的令牌
    //立即执行一次
    LockRecordsMain(recordsObj, lockNow, checkTimes);

    if (checkTimes == 0 || checkTimes > 1) {
        SI = setInterval(function () {
            LockRecordsMain(recordsObj, lockNow, checkTimes);
        }, 4000);
    }
}

//用于生成令牌
function guid() {
    return 'xxxxxxxx-xxxx-4xxx-yxxx-xxxxxxxxxxxx'.replace(/[xy]/g, function (c) {
        var r = Math.random() * 16 | 0, v = c == 'x' ? r : (r & 0x3 | 0x8);
        return v.toString(16);
    });
}

function setStatic(sp) {
    if(sp){
        for (var el in btnObj) {
            if (el == "disabled") {
                var btns = btnObj[el].split(',');
                for (var i = 0; i < btns.length; i++) {
                    top.MyForm["mybb_button_"+btns[i]].disabled = true;
                }
            } else if (el == "hidden") {
                var btns = btnObj[el].split(',');
                for (var i = 0; i < btns.length; i++) {
                    top.MyForm["mybb_button_" + btns[i]].style.visibility = "hidden";
                }
            }
        }
    }else{
        for (var el in btnObj) {
            if (el == "disabled") {
                var btns = btnObj[el].split(',');
                for (var i = 0; i < btns.length; i++) {
                    top.MyForm["mybb_button_" + btns[i]].disabled = false;
                }
            } else if (el == "hidden") {
                var btns = btnObj[el].split(',');
                for (var i = 0; i < btns.length; i++) {
                    top.MyForm["mybb_button_" + btns[i]].style.visibility = "visible";
                }
            }
        }
    }
}