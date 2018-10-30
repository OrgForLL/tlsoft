(function (window, undefined) {
    var coupon = {
        "id": "0",
        "localtype": "",
        "cardname": "",
        "accept_category": "",
        "localdiscount": "",
        "leastcost": "",
        "total": "",
        "reducecost": "",
        "begintime": "",
        "endtime": "",
        "description": ""
    };
    var storeList = [];
    var suitList = [];
    var isSubmit = false;
    var tshtml = {
        kh: "",
        md: ""
    };
    var url = "WechatCardCore.aspx";

    var increate = {
        init: function () {
            bindEvent();
            FastClick.attach(document.body);
            couponType();
            setTimeLimit();
        }
    };

    var bindEvent = function () {
        $(".navbar").click(function () {
            var on = $(this).hasClass("navbar-on");
            var index = $(this).index();
            if (!on) {
                $(this).addClass("navbar-on").siblings().removeClass("navbar-on");
                if (index == 0) {
                    $(".entry-check").removeClass("entry-check-company").addClass("entry-check-store");
                    $(".title-select").show();
                    $(".entry-select").show();
                } else {
                    $(".entry-check").removeClass("entry-check-store").addClass("entry-check-company");
                    $(".title-select").hide();
                    $(".entry-select").hide();
                }
            }
        });

        $("#ensure").click(function () {
            $(".goback").click();
        });

        $(".coupon").on("click", ".entry-link", function () {
            if (coupon.id == "0" && false) {
                onLoading("请先创建卡券", true);
                setTimeout(function () {
                    $("#myLoading").hide();
                }, 600);
            } else {
                var length = $(".increate .entry-check-company").children().length;
                length = length + $(".increate .entry-check-store").children().length;
                if (length == 0) {
                    getStoreList();
                    // getTestData();
                }
                isSelectStore();
                $(".increate").show();
                // $(".increate").removeClass("entry-fadeOut").addClass("entry-fadeIn");
            }
        });

        $(".coupon").on("click", ".entry-close", function () {
            var khid = $(this).parent().parent().find("p").attr("data-khid");
            delStore(khid);
            $(this).parent().parent().remove();
        });

        $(".increate .entry-check").on("click", ".entry-list", function () {
            var check = $(this).find(".check-icon");
            var khid = $(this).find(".entry-bd").attr("id");
            var khmc = $(this).find("p").text();
            var atype = $(this).find(".entry-bd").attr("data-atype");
            var data = {
                khid: khid,
                khmc: khmc,
                atype: atype
            }
            var isSelect = check.hasClass("icon-xuanze1");
            if (isSelect) {
                check.removeClass("icon-xuanze1").addClass("icon-xuanze");
                storeList.push(data);
            } else {
                check.removeClass("icon-xuanze").addClass("icon-xuanze1");
                delStore(khid);
            }

            /*if(atype == "kh") {
                $(".increate .entry-check-store .icon-xuanze").parent().parent().click();
            }else if(atype == "md") {
                $(".increate .entry-check-company .icon-xuanze").parent().parent().click();
            }*/
        });

        $(".coupon").on("click", "#submit", function () {
            /* if (coupon.id == "0") {
                getItemsData();
            } else {
                addSuitStord();
            } */
            if (isSubmit) {
                alert('正在创建卡券！');
            } else {
                getItemsData();
            }
        });

        $(".goback").click(function () {
            var html = template("optionList", { storeList: storeList });
            $(".coupon .entry-check").empty().append(html);
            $(".increate").hide();
            // $(".increate").removeClass("entry-fadeIn").addClass("entry-fadeOut");
            /* setTimeout(function () {
                $(".increate").hide();
            }, 500); */
        });

        $(".entry-select .select").change(function () {
            var khid = $(this).val();
            var khmc = $(this).find("option:selected").text();
            var kh = {
                khid: khid,
                khmc: khmc,
                atype: "kh"
            };

            if (khid) {
                getXJMDList(khid, kh);
            } else {
                $(".increate .entry-check-company").empty().append(tshtml.kh);
                $(".increate .entry-check-store").empty().append(tshtml.md);
                isSelectStore();
            }
        });

        $("#searchSubmit").click(function () {
            console.log("0");
            var filter = $("#searchInput").val();
            if (filter == "") {
                $(".increate").find("label").show();
            } else {
                $(".increate .entry-check-store").find("label").hide();
                $(".increate .entry-check-store").find(".entry-list p:contains(" + filter + ")").parent().parent().show()
            }
        });

        $(".entry-allSelect").click(function () {
            $(".increate .entry-check-store").find(".icon-xuanze1").parent().parent().click();
        });

        $(".entry-allDelect").click(function () {
            $(".increate .entry-check-store").find(".icon-xuanze").parent().parent().click();
        });

        $(".entry-check-company").on("click", ".entry-list", function () {
            if ($(".increate .select").val()) {
                var list = $(".entry-check-store").find(".icon-xuanze");
                for (var i = 0; i < list.length; i++) {
                    var khid = $(list[i]).parent().next().attr("id");
                    delStore(khid);
                }
                $(".entry-check-store").find(".icon-xuanze").removeClass("icon-xuanze").addClass("icon-xuanze1");
            }
        });

        $(".entry-check-store").on("click", ".entry-list", function () {
            if ($(".increate .select").val()) {
                $(".entry-check-company").find(".icon-xuanze").removeClass("icon-xuanze").addClass("icon-xuanze1");
                var khid = $(".increate .select").val();
                delStore(khid);
            }
        });
    }

    /* 判断创建的卡券类型 */
    var couponType = function () {
        var type = GetQueryParams("type") || "1";
        var html = "";

        switch (type) {
            case "1":
                html = template("discount-curr", {});
                coupon.localtype = "LILANZ_DISCOUNT";
                break;
            case "2":
                html = template("discount-class", {});
                coupon.localtype = "LILANZ_DISCOUNT";
                break;
            case "3":
                html = template("voucher-curr", {});
                coupon.localtype = "LILANZ_CASH";
                break;
            case "4":
                html = template("voucher-class", {});
                coupon.localtype = "LILANZ_CASH";
                break;
            case "5":
                html = template("voucher-nocill", {});
                coupon.localtype = "LILANZ_CASH";
                break;
            default:
                html = template("discount-curr", {});
                coupon.localtype = "LILANZ_DISCOUNT";
                break;
        }

        $(".coupon").empty().append(html);
    };

    /* ajax */
    function getListOptions(data, msg) {
        var message = msg ? msg : "正在创建卡券";
        onLoading(message);
        return new Promise(function (resolve, reject) {
            $.ajax({
                url: url,
                type: 'POST',
                data: data,
                dataType: 'JSON'
            }).then(function (data) {
                resolve(data);
            }).fail(function (err) {
                reject(err);
            });
        });
    };

    /* 获取填写卡券数据 */
    function getItemsData() {
        for (key in coupon) {
            if (key != "id" && key != "localtype") {
                var val = $("#" + key).val();
                var wran = $("#" + key).parent().parent();
                if (val != undefined && val == "") {
                    if (!wran.hasClass("entry-warn")) {
                        wran.append(template("warn", {}));
                        wran.addClass("entry-warn");
                    }
                    onLoading("请输入" + wran.find(".entry-label").text(), true);
                    setTimeout(function () {
                        $("#myLoading").hide();
                    }, 600);
                    return;
                } else {
                    coupon[key] = val || 0;
                    if (wran.hasClass("entry-warn")) {
                        wran.removeClass("entry-warn");
                        wran.find(".entry-ft").remove();
                    }
                }
            }
        };

        if (storeList.length > 0) {
            createCoupon();
        } else {
            onLoading('请选择适用门店！', true);
            setTimeout(function () {
                $("#myLoading").hide();
            }, 600);
        }
    };

    /* 创建卡券 */
    function createCoupon() {
        var parameter = [];
        parameter.push(JSON.stringify(coupon))
        var data = {
            "action": "saveCard",
            "parameter": parameter
        }
        isSubmit = true;
        getListOptions(JSON.stringify(data)).then(function (result) {
            if (result.code == "200") {
                coupon.id = result.data[0].id;
                // $(".entry-link").click();
                $(".entry-bd").find("input").attr("readonly", "true");
                $(".entry-bd").find("textarea").attr("readonly", "true");
                addSuitStord();
                // $("#submit").text("完成");
            } else {
                if (result.data && result.data.length > 0
                    && result.data[0].id) {
                    coupon.id = result.data[0].id;
                }
                onLoading(result.message);
                setTimeout(function () {
                    $("#myLoading").hide();
                    isSubmit = false;
                }, 2000);
            }
        }).fail(function (err) {
            onLoading("网络异常");
            setTimeout(function () {
                $("#myLoading").hide();
                isSubmit = false;
            }, 2000);
        });
    };

    /* 获取门店列表信息 */
    function getStoreList() {
        var data = { "action": "authKH", "parameter": [] };
        getListOptions(JSON.stringify(data), '正在获取门店列表信息').then(function (result) {
            if (result.code == "200") {
                var list = result.data;
                var khhtml = "";
                var options = "";
                var khid = "";
                var sq = {
                    khid: "",
                    khmc: "已授权门店",
                    atype: "kh"
                };

                options = template("selectOption", sq);

                for (var i = 0; i < list.length; i++) {
                    if (list[i].atype == "md") {
                        tshtml.md = tshtml.md + template("storeList", list[i]);
                    } else if (list[i].atype == "kh") {
                        options = options + template("selectOption", list[i]);
                        tshtml.kh = tshtml.kh + template("storeList", list[i]);
                        if (khhtml == "") {
                            khhtml = template("storeList", list[i]);
                        }
                    }
                }

                $(".entry-select .select").append(options);
                $(".increate .entry-check-company").empty().append(tshtml.kh);
                $(".increate .entry-check-store").empty().append(tshtml.md);
                setTimeout(function () {
                    $("#myLoading").hide();
                }, 500);
            } else {
                onLoading(result.message);
                setTimeout(function () {
                    $("#myLoading").hide();
                }, 2000);
            }
        }).fail(function (err) {
            onLoading("网络异常");
            setTimeout(function () {
                $("#myLoading").hide();
            }, 2000);
        });
    };

    function getTestData() {
        var result = { "code": 200, "data": [{ "khid": 7211, "khmc": "晋江万达室内步行街店", "atype": "md" }, { "khid": 7743, "khmc": "晋江SM专卖店", "atype": "md" }, { "khid": 1900, "khmc": "晋江睿智商贸有限公司", "atype": "kh" }, { "khid": 244, "khmc": "晋江市润达服装贸易有限公司", "atype": "kh" }, { "khid": 249, "khmc": "福建晋江第一分公司", "atype": "kh" }, { "khid": 83, "khmc": "合肥郎胜商贸有限责任公司", "atype": "kh" }, { "khid": 85, "khmc": "合肥思晨商贸有限公司", "atype": "kh" }, { "khid": 17721, "khmc": "合肥郎亦轩商贸有限责任公司", "atype": "kh" }, { "khid": 18090, "khmc": "福建晋江长兴路轻商务展厅", "atype": "kh" }], "message": "" };
        var list = result.data;
        var khhtml = "";
        var options = "";
        var khid = "";
        var sq = {
            khid: "",
            khmc: "已授权门店",
            atype: "kh"
        };

        options = template("selectOption", sq);

        for (var i = 0; i < list.length; i++) {
            if (list[i].atype == "md") {
                tshtml.md = tshtml.md + template("storeList", list[i]);
            } else if (list[i].atype == "kh") {
                options = options + template("selectOption", list[i]);
                tshtml.kh = tshtml.kh + template("storeList", list[i]);
                if (khhtml == "") {
                    khhtml = template("storeList", list[i]);
                }
            }
        }

        $(".entry-select .select").append(options);
        $(".increate .entry-check-company").empty().append(tshtml.kh);
        $(".increate .entry-check-store").empty().append(tshtml.md);
        setTimeout(function () {
            $("#myLoading").hide();
        }, 500);
    }

    /* 获取下级门店列表信息 */
    function getXJMDList(khid, kh) {
        var data = {
            "action": "xjmd",
            "parameter": [
                khid.toString()
            ]
        }
        getListOptions(JSON.stringify(data), "加载下级门店列表").then(function (result) {
            if (result.code == "200") {
                var list = result.data;
                var html = "";
                var khhtml = template("storeList", kh);

                for (var i = 0; i < list.length; i++) {
                    html = html + template("xjmdList", list[i]);
                }

                $(".increate .entry-check-company").empty().append(khhtml);
                $(".increate .entry-check-store").empty().append(html);
                isSelectStore();
                setTimeout(function () {
                    $("#myLoading").hide();
                }, 1000);
            } else {
                onLoading(result.message);
                setTimeout(function () {
                    $("#myLoading").hide();
                }, 2000);
            }
        }).fail(function (err) {
            onLoading("网络异常");
            setTimeout(function () {
                $("#myLoading").hide();
            }, 2000);
        });
    }

    /* 添加适用门店 */
    function addSuitStord() {
        var store = [];

        for (var i = 0; i < storeList.length; i++) {
            var item = {
                "khid": storeList[i].khid,
                "type": storeList[i].atype
            };

            store.push(item);
        }

        var data = {
            "action": "AddSuitStord",
            "parameter": [
                coupon.id,
                JSON.stringify(store)
            ]
        };

        getListOptions(JSON.stringify(data), "正在添加适用门店").then(function (result) {
            if (result.code == "200") {
                // onLoading("卡券创建完成", true);
                $("#myLoading").hide();
                // webt.lilang.com:9001
                // http://webt.lilang.com:9030/bb/bbmain.aspx?bid=22235&&menuid=25393&MyBB_bt=利郎男装卡券管理
                // ERP_WebPath + 'bb/bbmain.aspx?bid=22453&cid=' + coupon.id + '&menuid=25393&MyBB_bt=为卡券分配店铺配额';
                window.location.href = ERP_WebPath + 'bb/bbmain.aspx?bid=22453&cid=' + coupon.id + '&menuid=25393&MyBB_bt=为卡券分配店铺配额';
            } else {
                onLoading(result.message);
                setTimeout(function () {
                    $("#myLoading").hide();
                }, 2000);
            }
        }).fail(function (err) {
            onLoading("网络异常");
            setTimeout(function () {
                $("#myLoading").hide();
            }, 2000);
        });
    };

    /* 移除适用门店 */
    function removeSuitStord(sid) {
        var data = {
            "action": "removeSuitStord",
            "parameter": [
                sid.toString()
            ]
        }

        getListOptions(JSON.stringify(data), "正在移除适用门店").then(function (result) {
            if (result.code == "200") {
                setTimeout(function () {
                    $("#myLoading").hide();
                }, 1000);
            } else {
                onLoading("移除失败", true);
                setTimeout(function () {
                    $("#myLoading").hide();
                }, 1000);
            }
        }).fail(function (err) {
            console.log(err);
            onLoading("网络异常");
            setTimeout(function () {
                $("#myLoading").hide();
            }, 2000);
        });
    };

    /* 已选中门店 */
    function isSelectStore() {
        for (var i = 0; i < storeList.length; i++) {
            $(".increate .entry-check").find("#" + storeList[i].khid + "[data-atype=" + storeList[i].atype + "]").parent().find(".check-icon").removeClass("icon-xuanze1").addClass("icon-xuanze");
        }
    }

    /* 设置有效时间 */
    function setTimeLimit() {
        var dateStart = $("#begintime");
        var dateEnd = $("#endtime");
        var date = new Date();
        var y = date.getFullYear();
        var m = setZero(date.getMonth() + 1);
        var d = setZero(date.getDate());
        date.setDate(date.getDate() + 6);
        var lm = setZero(date.getMonth() + 1);
        var ld = setZero(date.getDate());
        dateStart.val(y + "-" + m + "-" + d);
        dateEnd.val(y + "-" + lm + "-" + ld);
    };

    /* 小于10的数字加0 */
    function setZero(day) {
        return day < 10 ? '0' + day : day;
    };

    /* 删除列表中的门店 */
    function delStore(khid) {
        for (var i = 0; i < storeList.length; i++) {
            if (storeList[i].khid == khid) {
                storeList.splice(i, 1);
                break;
            }
        }
    };

    /* 已选中门店 */
    function isSelectStore() {
        $(".increate .entry-check").find(".icon-xuanze").removeClass("icon-xuanze").addClass("icon-xuanze1");
        for (var i = 0; i < storeList.length; i++) {
            $(".increate .entry-check").find("#" + storeList[i].khid + "[data-atype=" + storeList[i].atype + "]").parent().find(".check-icon").removeClass("icon-xuanze1").addClass("icon-xuanze");
        }
    }

    /* 获取URL GET参数 */
    function GetQueryParams(name) {
        var reg = new RegExp("(^|&)" + name + "=([^&]*)(&|$)", "i");
        var r = window.location.search.substr(1).match(reg);
        if (r != null)
            return unescape(r[2])
        else
            return "";
    };

    /* 显示加载状态 */
    function onLoading(msg, trun) {
        if (isIE8) {
            alert(msg);
            return null;
        }
        $(".load_text").text(msg || '加载中...');
        if (trun) {
            $(".load_img").hide();
        } else {
            $(".load_img").show();
        }
        $("#myLoading").show();
        // alert(msg);
    };

    window.increate = increate;
})(window)