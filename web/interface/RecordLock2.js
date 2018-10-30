document.write("<script src='../js_ui/jquery-1.4.2.min.js'><\/script>");
document.write("<script src='../JSON/json2.js'><\/script>");

var LRS = (function () {
    var _lock, _times, _SI, _errTimes,_isAlert=false, _checkTimes;
    var _uid, _uname, _token, _recordsObj = new Object();    

    //初始化相关变量
    function InitVars(uid, uname, token, checkTimes, recsObj) {
        _uid = uid;
        _uname = uname;
        _token = token;
        _checkTimes = checkTimes;
        _recordsObj = recsObj;
    }

    function LockRecordsMain(unlockCB, lockCB) {
        if (_lock) return;
        _lock = true;

        if (_SI != null && _SI != undefined && _checkTimes != 0 && _times >= _checkTimes || _errTimes > 10) {
            clearInterval(_SI);
            return;
        }

        $.ajax({
            type: "post", //AJAX请求类型
            contentType: "application/x-www-form-urlencoded; charset=utf-8",
            url: "../interface/LockRecords.aspx", //请求url        
            cache: false,  //无缓存
            timeout: 1000 * 2,  //AJAX请求超时时间  
            data: { datas: JSON.stringify(_recordsObj), uid: _uid, uname: _uname, token: _token, ctrl: "CheckLockStatus" },
            success: function (data) {//data warn:有人占用 successd:成功
                _times++;
                _errTimes = 0;
                _lock = false;
                if (data.indexOf("warn:") > -1) {
                    lockCB();
                    if (!_isAlert) {
                        alert("您打开的数据目前已被【" + data.replace("warn:", "") + "】打开，您将无法编辑，当占用者释放时会自动解除！");
                        _isAlert = true;
                    }
                } else if (data.indexOf("successd:") > -1) {
                    unlockCB();
                    _isAlert = false;
                } else if (data.indexOf("error:") > -1) {
                    alert(data);
                    if (_SI != undefined && _SI != null)
                        clearInterval(_SI);
                }
            },
            error: function (XMLHttpRequest, textStatus, errorThrown) {
                _times++;
                _errTimes++;
                _lock = false;                                
                _isAlert = false;
            }
        });

        return;
    }

    function LockRecords(successCB, failCB) {
        if (_recordsObj == null || _recordsObj == undefined)
            return;
        _times = 0;
        _lock = false;
        _errTimes = 0;//发生错误时最大重试次数 
        successCB = successCB || function () { };
        failCB = failCB || function () { };
        //立即执行一次
        LockRecordsMain(successCB,failCB);

        if (_checkTimes == 0 || _checkTimes > 1) {
            _SI = setInterval(function () {
                LockRecordsMain(successCB,failCB);
            }, 4000);
        }
    }

    //用于清除检查锁定
    function clearLock() {
        clearInterval(_SI);
    }

    //用于生成令牌
    function Guid() {        
        var guidStr= 'xxxxxxxx-xxxx-4xxx-yxxx-xxxxxxxxxxxx'.replace(/[xy]/g, function (c) {
            var r = Math.random() * 16 | 0, v = c == 'x' ? r : (r & 0x3 | 0x8);
            return v.toString(16);
        });

        return guidStr;
    }   

    //接口列表
    return {
        token: _token,
        InitVars: InitVars,
        LockRecords: LockRecords,
        Guid: Guid,
        clearLock:clearLock
    };
})();


//top.MyForm["mybb_button_" + btns[i]].disabled = true
//top.MyForm["mybb_button_" + btns[i]].style.visibility = "hidden"
//top.MyForm["mybb_button_" + btns[i]].style.visibility = "visible"