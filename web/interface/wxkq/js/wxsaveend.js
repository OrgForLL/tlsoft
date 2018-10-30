//使用说明：该提示层是基于WEUI插件
//默认是放了两个按钮，如果第二个铵钮的文字参数为空则不显示出来
//使用方法：在body标签后引入该JS文件
//LLOA.showpage(标题，描述，按钮一文字，按钮二文字，按钮一执行的函数，按钮二执行的函数);
//LLOA.showpage("", "123", "发起办理", "", function () { alert("confirm"); }, function () { alert("cancle"); });

(function (window, jQuery, undefined) {

    var lloa_html = "<div id='successPage' class='page' style='z-index: 1000; position: fixed;transition: all 0.2s;'>";
    lloa_html += "<div class='hd'><h1 class='page_title'></h1></div>";
    lloa_html += "<div class='bd'><div class='weui_msg'><div class='weui_icon_area'><i class='weui_icon_success weui_icon_msg'></i></div>";
    lloa_html += "<div class='weui_text_area'><h2 class='weui_msg_title'></h2><p class='weui_msg_desc'></p></div>";
    lloa_html += "<div class='weui_opr_area'><p class='weui_btn_area'><a href='#' id='sucConfirm' class='weui_btn weui_btn_primary'>确定</a></p>";
    lloa_html += "<br /><p class='weui_btn_area'><a href='javascript:;' id='sucCancle' class='weui_btn weui_btn_default'>关闭</a></p>";
    lloa_html += "</div><div class='weui_extra_area' style='position: relative;'>利郎信息技术部</div>";
    lloa_html += "</div></div></div>";

    function LLWXALERT() {
        this.init();
    }

    LLWXALERT.prototype = {
        init: function () {
            var config = {};
            this.get = function (n) {
                return config[n];
            }

            this.set = function (n, v) {
                config[n] = v;
            }

            this.createDOM();
            this.bindEvent();
        },
        createDOM: function () {
            var body = jQuery("body");
            ovl = jQuery("#successPage");
            if (ovl.length === 0) {
                body.append(lloa_html);
                this.phide();
            }

            this.set("ovl", jQuery("#successPage"));
        },
        bindEvent: function () {
            var _this = this;
            var ovl = _this.get("ovl");
            ovl.on("click", "#sucConfirm", function (e) {
                var cb = _this.get("confirmSub");
                _this.phide();
                cb && cb(true);
            });

            ovl.on("click", "#sucCancle", function (e) {
                var cb = _this.get("cancleSub");
                _this.phide();
                cb && cb(true);
            });
        },
        showpage: function (title1,title2,btntext1,btntext2,callback1,callback2) {
            var title1 = typeof title1 === 'string' ? title1 : title1.toString();
            var title2 = typeof title2 === 'string' ? title2 : title2.toString();
            var btntext1 = typeof btntext1 === 'string' ? btntext1 : btntext1.toString();
            var btntext2 = typeof btntext2 === 'string' ? btntext2 : btntext2.toString();
            if (title1 == "")
                title1 = "保存成功";            
            ovl = this.get("ovl");
            ovl.find(".weui_msg_title").html(title1);
            ovl.find(".weui_msg_desc").html(title2);
            if (btntext1 != "")
                ovl.find("#sucConfirm").html(btntext1);
            if (btntext2 != "") {
                ovl.find("#sucCancle").html(btntext2);
                ovl.find("#sucCancle").show();
            }
            else
                ovl.find("#sucCancle").hide();
            this.set("confirmSub", (callback1 || function () { }));
            this.set("cancleSub", (callback2 || function () { }));
            this.pshow();
        },
        pshow: function () {
            $("#successPage").css("opacity", "1");
            $("#successPage").css("left", "0px");
        },
        phide: function () {
            $("#successPage").css("opacity", "0");
            $("#successPage").css("left", document.body.clientWidth + "px");
        }
    };

    LLOA = new LLWXALERT();
})(window, jQuery);