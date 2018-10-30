(function () {
    'use strict';
    var isToBottom = false, isMoved = false;
    var auiScroll = function (params, callback) {
        this.extend(this.params, params);
        this._init(params, callback);
    }
    auiScroll.prototype = {
        params: {
            listen: false,
            distance: 100,
            element: ""
        },
        _init: function (params, callback) {
            var self = this;

            if (self.params.listen) {
                document.getElementById(self.params.element).addEventListener("touchmove", function (e) {
                    self.scroll(callback);
                });
                document.getElementById(self.params.element).addEventListener("touchend", function (e) {
                    self.scroll(callback);
                });
            }
            window.onscroll = function () {
                self.scroll(callback);
            }
            document.getElementById(self.params.element).onscroll = function () {
                self.scroll(callback);
            }
        },
        scroll: function (callback) {
            var self = this;
            var scrollTop = document.getElementById(self.params.element).scrollTop;
            var scrollHeight = document.getElementById(self.params.element).scrollHeight;
            if (scrollHeight - scrollTop - self.params.distance <= window.innerHeight) {
                isToBottom = true;
                if (isToBottom) {
                    callback({
                        "scrollTop": scrollTop,
                        "isToBottom": true
                    })
                }
            } else {
                isToBottom = false;
                callback({
                    "scrollTop": scrollTop,
                    "isToBottom": false
                })
            }
        },
        extend: function (a, b) {
            for (var key in b) {
                if (b.hasOwnProperty(key)) {
                    a[key] = b[key];
                }
            }
            return a;
        }
    }
    window.auiScroll = auiScroll;
})();
