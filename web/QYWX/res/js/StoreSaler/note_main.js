 /*入口脚本*/
require.config({
    baseUrl: "../../res/js/",
    paths: {
        "jquery": "jquery", 
        "FastClick": "StoreSaler/fastclick.min",
        "base": "base" , 
        "note": "StoreSaler/note", 
        "template": "template-native",
        "wx": "jweixin-1.0.0"
    },
    waitSeconds: 15,
    map: {
        '*': {
            'css': 'plugins/css.min',
            'text': 'plugins/text'
        }
    },
    shim: {
        "jquery": {
            exports: "$"
        },
        "wx": {
            exports: "wx"
        }, 
        'note': [ 'css!../css/LeePageSlider.css'
                  , 'css!../css/font-awesome.min.css'
                  , 'css!../css/StoreSaler/note.css'
                  , 'base','jquery']
    }
});

require(["note", "FastClick"], function (note, FastClick) {
    FastClick.attach(document.body);

    note.Init();
    note.LoadInfo();

    $("#loadingmask").fadeOut();   //加载完毕
});


 