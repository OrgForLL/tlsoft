
//微信浏览器控制
function onBridgeReady() {
    WeixinJSBridge.call('hideOptionMenu');     //隐藏右上角菜单按钮
    WeixinJSBridge.call('hideToolbar');        //隐藏底部栏
}

if (typeof WeixinJSBridge == "undefined") {
    if (document.addEventListener) {
        document.addEventListener('WeixinJSBridgeReady', onBridgeReady, false);
    } else if (document.attachEvent) {
        document.attachEvent('WeixinJSBridgeReady', onBridgeReady);
        document.attachEvent('onWeixinJSBridgeReady', onBridgeReady);
    }
} else {
    onBridgeReady();
}
          