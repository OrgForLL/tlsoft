/*
* 面向对象编写方法
*/

// 当前是否处于创建类的阶段

var initializing = false;

function jClass(baseClass, prop) {
    // 只接受一个参数的情况 - jClass(prop)
    if (typeof (baseClass) === "object") {
        prop = baseClass;
        baseClass = null;
    }

    // 本次调用所创建的类（构造函数）
    function F() {
        // 如果当前处于实例化类的阶段，则调用init原型函数
        if (!initializing) {
            // 如果父类存在，则实例对象的baseprototype指向父类的原型
            // 这就提供了在实例对象中调用父类方法的途径
            if (baseClass) {
                this.baseprototype = baseClass.prototype;
            }
            this.init.apply(this, arguments);
        }
    }

    // 如果此类需要从其它类扩展
    if (baseClass) {
        initializing = true;
        F.prototype = new baseClass();
        F.prototype.constructor = F;
        initializing = false;
    }

    // 覆盖父类的同名函数
    for (var name in prop) {
        if (prop.hasOwnProperty(name)) {
            // 如果此类继承自父类baseClass并且父类原型中存在同名函数name
            if (baseClass &&
typeof (prop[name]) === "function" &&
typeof (F.prototype[name]) === "function") {
                // 重定义函数name - 
                // 首先在函数上下文设置this.base指向父类原型中的同名函数
                // 然后调用函数prop[name]，返回函数结果

                // 注意：这里的自执行函数创建了一个上下文，这个上下文返回另一个函数，
                // 此函数中可以应用此上下文中的变量，这就是闭包（Closure）。
                // 这是JavaScript框架开发中常用的技巧。
                F.prototype[name] = (function (name, fn) {
                    return function () {
                        this.base = baseClass.prototype[name];
                        return fn.apply(this, arguments);
                    };
                })(name, prop[name]);
            }
            else {
                F.prototype[name] = prop[name];
            }
        }
    }
    return F;
};

//获取URL参数
function getQueryStringRegExp(name)
{
    var reg = new RegExp("(^|\\?|&)"+ name +"=([^&]*)(\\s|&|$)", "i");
    if (reg.test(location.href)) return unescape(RegExp.$2.replace(/\+/g, " ")); return "";
};
/*
* 时间对象的格式化;
*/
Date.prototype.format = function (format) {
    /*
    * eg:format="yyyy-MM-dd hh:mm:ss";
    */
    var o = {
        "M+": this.getMonth() + 1,  //month
        "d+": this.getDate(),     //day
        "h+": this.getHours(),    //hour
        "m+": this.getMinutes(),  //minute
        "s+": this.getSeconds(), //second
        "q+": Math.floor((this.getMonth() + 3) / 3),  //quarter
        "S": this.getMilliseconds() //millisecond
    }

    if (/(y+)/.test(format)) {
        format = format.replace(RegExp.$1, (this.getFullYear() + "").substr(4 - RegExp.$1.length));
    }

    for (var k in o) {
        if (new RegExp("(" + k + ")").test(format)) {
            format = format.replace(RegExp.$1, RegExp.$1.length == 1 ? o[k] : ("00" + o[k]).substr(("" + o[k]).length));
        }
    }
    return format;
}
/*
* 字符串格式化为时间;
*/
String.prototype.todate = function () {
    var val = Date.parse(str);
    var newDate = new Date(val);
    return newDate;
} 
/*
* 字符串去空格
*/
String.prototype.trim = function () {
    return this.replace(/^\s\s*/, '').replace(/\s\s*$/, '');
}
/*
* 获取月份最后一天
*/
function LastDayOfMonth(y, m) {
    var a = new Array(31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31);
    a[1] = (0 == y % 4 && (y % 100 != 0 || y % 400 == 0)) ? 29 : 28;
    return a[m - 1];
}
/**
* 改变jQuery AJAX回调函数this指针指向
* @param {Object} thisObj 要替换当前this指针的对象
* @return {Function} function(data){}
*/
Function.prototype.Apply = function (thisObj) {
    var _method = this;
    return function (data) {
        return _method.apply(thisObj, [data]);
    };
}

//正则表达式校验
//是否整数
function isInt(str) {
    if (str.search(/^-?[1-9]\d*$/) != 0) return false;
    else return true;
}
//是否浮点数
function isFloat(str) {
    if (str.search(/^-?([1-9]\d*\.\d*|0\.\d*[1-9]\d*|0?\.0+|0)$/) != 0) return false;
    else return true;
}
//是否时间
function isTime(str) {
    var a = str.match(/^(\d{0,2}):(\d{0,2}):(\d{0,2})$/);
    if (a == null) return false;
    if (a[1] >= 24 || a[2] >= 60 || a[3] >= 60) return false;
    return true;
}
//是否日期时间
function isDateTime(str) {
    var a = str.match(/^(\d{0,4})-(\d{0,2})-(\d{0,2}) (\d{0,2}):(\d{0,2}):(\d{0,2})$/);
    if (a == null) return false;
    if (a[2] >= 13 || a[3] >= 32 || a[4] >= 24 || a[5] >= 60 || a[6] >= 60) return false;
    return true;
}
//是否日期
function isDate(str) {
    var a = str.match(/^(\d{0,4})-(\d{0,2})-(\d{0,2})$/);
    if (a == null) return false;
    if (a[2] >= 13 || a[3] >= 32 || a[4] >= 24) return false;
    return true;
}


