var isInApp = false, AppInOS = "";

var llAppForIOS = (function () {
    var init = function () {
        //调用定义好的函数
        //setupWebViewJavascriptBridge(function (bridge) {
        //    //OC传值给JS 'bridgeReady'为双方自定义好的统一方法名；'data'是OC传过来的值；'responseCallback'是JS接收到之后给OC的回调
        //    bridge.registerHandler('bridgeReady', function (data, responseCallback) {
        //        isInApp = true;
        //        AppInOS = "iOS";
        //        llApp = llAppForIOS;
        //    });
        //});

        setupWebViewJavascriptBridge(function (bridge) {
            bridge.callHandler('bridgeReady', {}, function (response) {
                if (response == 'iOSBridgeReady') {
                    isInApp = true;
                    AppInOS = "iOS";
                    llApp = llAppForIOS;
                }
            });
        });
    }

    var setupWebViewJavascriptBridge = function (callback) {
        if (window.WebViewJavascriptBridge) { return callback(WebViewJavascriptBridge); }
        if (window.WVJBCallbacks) { return window.WVJBCallbacks.push(callback); }
        window.WVJBCallbacks = [callback];
        var WVJBIframe = document.createElement('iframe');
        WVJBIframe.style.display = 'none';
        WVJBIframe.src = 'wvjbscheme://__BRIDGE_LOADED__';
        document.documentElement.appendChild(WVJBIframe);
        setTimeout(function () { document.documentElement.removeChild(WVJBIframe) }, 0);
    };

    //判断变量类型
    var typoOfSource = function (o) {
        if (o === null) return "Null";
        if (o === undefined) return "Undefined";
        return Object.prototype.toString.call(o).slice(8, -1);
    }

    //APP原生提示框
    var showMessage = function (text, callback) {
        callback = callback || function () { };
        //JS给OC传值。'showMessage'为双方自定义的统一方法名；'text'&'text'为要传的值； response为OC收到后给JS的回调
        setupWebViewJavascriptBridge(function (bridge) {
            bridge.callHandler('showMessage', { "text": text }, function (response) {
                callback(response + "|" + isInApp);
            });
        });
    }

    //APP LOADING显示
    var showLoading = function (text, callback) {
        setupWebViewJavascriptBridge(function (bridge) {
            bridge.callHandler('showLoading', { "text": text }, function (response) {
                if (typeof (callback) === 'function')
                    callback(response + "|" + isInApp);
            });
        });
    }

    //APP LOADING隐藏
    var hideLoading = function () {
        setupWebViewJavascriptBridge(function (bridge) {
            bridge.callHandler('hideLoading', {}, function (response) { });
        });
    }

    //APP 图片上传
    var imageUpload = function (fun) {
        setupWebViewJavascriptBridge(function (bridge) {
            bridge.callHandler('imageUpload', {}, function (response) { });
            bridge.registerHandler("Res_imageUpload", function (data) {
                fun(data);
            });
        });
    }

    //预览图片
    var previewImage = function (imgurl) {
        setupWebViewJavascriptBridge(function (bridge) {
            bridge.callHandler('previewImage', { imgurl: imgurl }, function (response) { });
        });
    }

    //设置COOKIE
    var setWKCookie = function (val, _cb) {
        _cb = _cb || function () { };
        setupWebViewJavascriptBridge(function (bridge) {
            bridge.callHandler('setWKCookie', val, function (response) {
                _cb(response);
            });
        });
    }

    //关闭webview
    var closeWKView = function () {
        setupWebViewJavascriptBridge(function (bridge) {
            bridge.callHandler('closeWKView', {}, function (response) {
            });
        });
    }

    //扫码
    var scanQRCode = function (_cb) {
        _cb = _cb || function () { };
        setupWebViewJavascriptBridge(function (bridge) {
            bridge.callHandler('scanQRCode', {}, function (response) { });
            bridge.registerHandler("Res_scanQRCode", function (data) {
                _cb(data);
            });
        });
    }

    var getLocation = function (_cb) {
        _cb = _cb || function () { };
        setupWebViewJavascriptBridge(function (bridge) {
            bridge.callHandler('getLocation', {}, function (response) { });
            bridge.registerHandler("Res_getLocation", function (data) {
                _cb(data);
            });
        });
    }

    //驱动聊天界面
    var startChat = function (uid) {        
        setupWebViewJavascriptBridge(function (bridge) {
            bridge.callHandler('startChat', { uid: uid }, function (response) { });
        });
    }

    //打开新的webview
    var openWebView = function (url) {
        setupWebViewJavascriptBridge(function (bridge) {
            bridge.callHandler('openWebView', { url: url }, function (response) { });
        });
    }

    //获取AppToken
    var getAppToken = function (_cb) {
        _cb = _cb || function () { };
        setupWebViewJavascriptBridge(function (bridge) {
            bridge.callHandler('getAppToken', val, function (response) {
                _cb(response);
            });
        });
    }

    //20170406 liqf 聊天窗口发送URL
    var doSendURL = function (qyuid, title, desc, url, _cb) {
        _cb = _cb || function () { };
        setupWebViewJavascriptBridge(function (bridge) {
            bridge.callHandler('doSendURL', { qyuid: qyuid, title: title, desc: desc, url: url }, function (response) {
                _cb(response);
            });
        });
    }

    return {        
        init: init,
        showMessage: showMessage,
        showLoading: showLoading,
        hideLoading: hideLoading,
        imageUpload: imageUpload,
        setWKCookie: setWKCookie,
        closeWKView: closeWKView,
        scanQRCode: scanQRCode,
        getLocation: getLocation,
        startChat: startChat,
        openWebView: openWebView,
        previewImage: previewImage,
        getAppToken: getAppToken,
        doSendURL: doSendURL
    }
})();

/*================================Android JS-SDK================================*/

var llAppForANDROID = (function () {
    var _funcAddrs = {};

    var init = function () {
        if (typeof (_JIAndroidObj) != "undefined") {
            var result = _JIAndroidObj.bridgeReady();
            if (result == "AndroidBridgeReady") {
                isInApp = true;
                AppInOS = "Android";
                llApp = llAppForANDROID;
            }
        }
    }

    //获取地理位置
    var getLocation = function (cb) {
        _funcAddrs["location"] = cb;
        _JIAndroidObj.getLocation();
    }

    //对应的回调
    var Res_getLocation = function (msg) {
        _funcAddrs["location"] = _funcAddrs["location"] || function () { };
        _funcAddrs["location"](msg);
    }

    //扫码
    var scanQRCode = function (cb) {
        _funcAddrs["scanqrcode"] = cb;
        _JIAndroidObj.scanQRCode();
    }

    //对应的回调
    var Res_scanQRCode = function (msg) {
        _funcAddrs["scanqrcode"] = _funcAddrs["scanqrcode"] || function () { };
        _funcAddrs["scanqrcode"](msg);
    }

    //关闭当前webview
    var closeWKView = function () {
        _JIAndroidObj.closeWKView();
    }

    var startChat = function (uid) {
        _JIAndroidObj.startChat(uid);
    }

    //图片上传
    var imageUpload = function (cb) {
        _funcAddrs["imgupload"] = cb;
        _JIAndroidObj.imageUpload();
    }

    var Res_imageUpload = function (msg) {
        _funcAddrs["imgupload"] = _funcAddrs["imgupload"] || function () { };
        _funcAddrs["imgupload"](msg);
    }

    //预览图片
    var previewImage = function (imgurl) {        
        _JIAndroidObj.previewImage(imgurl);
    }

    //新建一个WEBVIEW
    var openWebView = function (url) {
        _JIAndroidObj.openWebView(url);
    }

    //获取APP中的TOKEN
    var getAppToken = function (cb) {
        var _token = _JIAndroidObj.getAppToken();
        cb = cb || function () { };
        cb(_token);
    }

    //20170407 liqf 聊天窗口发送URL
    var doSendURL = function (qyuid, title, desc, url, cb) {
        var res = _JIAndroidObj.doSendURL(qyuid, title, desc, url);
        cb = cb || function () { };
        cb(res);
    }

    return {        
        init: init,        
        getLocation: getLocation,        
        Res_getLocation: Res_getLocation,
        scanQRCode: scanQRCode,
        Res_scanQRCode: Res_scanQRCode,
        closeWKView: closeWKView,
        imageUpload: imageUpload,
        Res_imageUpload:Res_imageUpload,
        startChat: startChat,
        openWebView: openWebView,
        previewImage: previewImage,
        getAppToken: getAppToken,
        doSendURL: doSendURL
    }
})();

/*================================Final JS-SDK================================*/

var llApp = (function () {
    var _version = "1.0.5";
    var ver = function () {
        console.log(_version);
    };

    var init = function () {
        llAppForANDROID.init();
        if (!isInApp)
            llAppForIOS.init();
    }

    return {        
        ver: ver,
        init:init
    }
})();