var currentSite = "index";
$(document).ready(function () {
    FastClick.attach(document.body);
    LeeJSUtils.LoadMaskInit();
    BindEvents();
    loadProvince();
    initData();
});

//页面初始化数据
function initData() {
    var data = LeeJSUtils.GetQueryParams("data");
    if (data == "")
        return;
    LeeJSUtils.showMessage("loading", "正在加载数据..");
    setTimeout(function () {
        $.ajax({
            type: "POST",
            cache: false,
            timeout: 5 * 1000,
            contentType: "application/x-www-form-urlencoded; charset=utf-8",
            url: "/lspx/jf.do?act=OrderCheck&detail=" + encodeURIComponent(data),
            success: function (msg) {
                //console.log(msg);
                var data = JSON.parse(msg);
                if (data.code == 200) {
                    var html = "", all_points = 0;
                    for (var i = 0; i < data.list.length; i++) {
                        var row = data.list[i];
                        all_points += parseInt(row.goods_nums * row.point);
                        html += template("tmp_order_item", row);
                    }
                    if (html != "") {
                        $(".order-list ul").empty().html(html);
                        $("#total_points").text(all_points);
                        $("#total_nums").text(data.list.length);

                        $("#index .no-result").hide();
                    }

                    $("#leemask").hide();
                } else if (data.code == 202) {                    
                    window.location.href = "http://tm.lilanz.com/lspx/jf.do?act=redirectL&url=http://tm.lilanz.com/project/vipweixin/NewConfirmOrder.html?data=" + encodeURIComponent(LeeJSUtils.GetQueryParams("data"));
                } else
                    LeeJSUtils.showMessage("error", data.msg);
            },
            error: function (XMLHttpRequest, textStatus, errorThrown) {
                LeeJSUtils.showMessage("error", "您的网络出问题啦..");
            }
        });
    }, 50);
}

//导航事件
function nvaigateTo(target) {
    switch (target) {
        case "store":
            $("#sprovince").val("-1");
            $("#scity option:not(:first-child)").remove();
            $("#scity").attr("disabled", "disabled");

            $("#sshop option:not(:first-child)").remove();
            $("#sshop").attr("disabled", "disabled");

            $('#shopAdd_page').removeClass('page-right');
            currentSite = "shopAdd_page";
            break;
        case "express":
            if ($('#addressList_page .addList').attr("data-load") == "0") {
                loadAddlist();
            } else {
                $('#addressList_page').removeClass('page-right');
                currentSite = "addressList_page";
            }
            break;
        case "newaddress":
            //resetAddrForm();
            $('#myAdd_page').removeClass('page-right');
            currentSite = "myAdd_page";
            break;
        default:
            break;
    }
}

//返回事件
function returnTo(currentPage, targetPage) {
    $("#" + currentPage).addClass("page-right");
    currentSite = targetPage;
}

// 加载省份 只加载一次
function loadProvince() {
    $.ajax({
        type: "POST",
        cache: false,
        timeout: 5 * 1000,
        contentType: "application/x-www-form-urlencoded; charset=utf-8",
        url: "/lspx/jf.do?act=AddrList&cat=1",
        success: function (msg) {
            var data = JSON.parse(msg);
            if (data.code == 200) {
                var html = "";
                for (var i = 0; i < data.list.length; i++) {
                    html += template("tmp_address_option", data.list[i]);
                }//end for
                //console.log(html);
                $("#sprovince").append(html);
                $("#province").append(html);
            } else if (data.code == 202) {
                //http://tm.lilanz.com/lspx/jf.do?act=redirect&url=/QYWX/vip2/EasyBusiness/redeem.html
                //encodeURIComponent("/QYWX/vip2/EasyBusiness/NewConfirmOrder.html?data=" + encodeURIComponent(LeeJSUtils.GetQueryParams("data")));
                window.location.href = "http://tm.lilanz.com/lspx/jf.do?act=redirectL&url=http://tm.lilanz.com/project/vipweixin/NewConfirmOrder.html?data=" + encodeURIComponent(LeeJSUtils.GetQueryParams("data"));
            } else
                LeeJSUtils.showMessage("error", data.msg);
        },
        error: function (XMLHttpRequest, textStatus, errorThrown) {
            LeeJSUtils.showMessage("error", "您的网络出问题啦[province]..");
        }
    });
}

// 加载城市
function loadCity() {
    var proid = "-1";
    if (currentSite == "myAdd_page")
        proid = $("#province").val();
    else if (currentSite == "shopAdd_page")
        proid = $("#sprovince").val();

    if (proid != "-1") {
        $.ajax({
            type: "POST",
            cache: false,
            timeout: 5 * 1000,
            contentType: "application/x-www-form-urlencoded; charset=utf-8",
            url: "/lspx/jf.do?act=AddrList&cat=2&pid=" + proid,
            success: function (msg) {
                var data = JSON.parse(msg);
                if (data.code == 200) {
                    if (data.list.length != 0) {
                        var html = "";
                        for (var i = 0; i < data.list.length; i++) {
                            html += template("tmp_address_option", data.list[i]);
                        }//end for

                        if (currentSite == "myAdd_page") {
                            $("#city option:not(:first-child)").remove();
                            $("#city").append(html);
                            $("#city").removeAttr("disabled");
                        }

                        if (currentSite == "shopAdd_page") {
                            $("#scity option:not(:first-child)").remove();
                            $("#scity").append(html);
                            $("#scity").removeAttr("disabled");
                        }

                        if ($("#myAdd_page").attr("data-mode") == "edit") {
                            $("#city option").each(function () {
                                if ($(this).text() == $("#myAdd_page").attr("data-city")) {
                                    $(this).attr("selected", "selected");
                                    loadDistrict();
                                }
                            });
                        }
                    }
                } else
                    LeeJSUtils.showMessage("error", data.msg);
            },
            error: function (XMLHttpRequest, textStatus, errorThrown) {
                LeeJSUtils.showMessage("error", "您的网络出问题啦[city]..");
            }
        });
    } else
        console.log("no selected province | " + currentSite);
}

// 加载街道
function loadDistrict() {
    var cityid = $('#city').val();
    if (cityid != "-1") {
        $.ajax({
            type: "POST",
            cache: false,
            timeout: 5 * 1000,
            contentType: "application/x-www-form-urlencoded; charset=utf-8",
            url: "/lspx/jf.do?act=AddrList&cat=3&pid=" + cityid,
            success: function (msg) {
                var data = JSON.parse(msg);
                if (data.code == 200) {
                    if (data.list.length != 0) {
                        var html = "";
                        for (var i = 0; i < data.list.length; i++) {
                            html += template("tmp_address_option", data.list[i]);
                        }

                        $("#district option:not(:first-child)").remove();
                        $("#district").append(html);
                        $("#district").removeAttr("disabled");

                        if ($("#myAdd_page").attr("data-mode") == "edit") {
                            $("#district option").each(function () {
                                if ($(this).text() == $("#myAdd_page").attr("data-dist")) {
                                    $(this).attr("selected", "selected");
                                }
                            });
                        }
                    }
                } else
                    LeeJSUtils.showMessage("error", data.msg);
            },
            error: function (XMLHttpRequest, textStatus, errorThrown) {
                LeeJSUtils.showMessage("error", "您的网络出问题啦[street]..");
            }
        });
    }
}

// 加载店铺
function loadShop() {
    var cityid = $('#scity').val();
    if (cityid != "-1") {
        $.ajax({
            type: "POST",
            cache: false,
            timeout: 5 * 1000,
            contentType: "application/x-www-form-urlencoded; charset=utf-8",
            url: "/lspx/jf.do?act=ShopList&id=" + cityid,
            success: function (msg) {
                //console.log(msg);
                var data = JSON.parse(msg);
                if (data.code == 200) {
                    var html = "";
                    for (var i = 0; i < data.info.length; i++) {
                        html += template("tmp_shop_option", data.info[i]);
                    }//end for
                    $("#sshop option:not(:first-child)").remove();
                    $("#sshop").append(html);
                    $("#sshop").removeAttr("disabled");
                } else {
                    LeeJSUtils.showMessage("error", data.msg);
                }
            },
            error: function (XMLHttpRequest, textStatus, errorThrown) {
                LeeJSUtils.showMessage("error", "您的网络出问题啦[loadShop]..");
            }
        });
    }
}

// 请求地址列表数据
function loadAddlist() {
    LeeJSUtils.showMessage("loading", "正在加载地址列表..");
    setTimeout(function () {
        $.ajax({
            type: "POST",
            cache: false,
            timeout: 5 * 1000,
            contentType: "application/x-www-form-urlencoded; charset=utf-8",
            url: "/lspx/jf.do?act=UserAddrList",
            success: function (msg) {
                var data = JSON.parse(msg);
                if (data.code == 200) {
                    var html = "";
                    for (var i = 0; i < data.list.length; i++) {
                        var row = data.list[i];
                        row.defaultAddr = row.isDefault == true ? "1" : "0";
                        html += template("tmp_myaddress", row);
                    }
                    //console.log(data);
                    $(".addList").empty().html(html);
                    $('#addressList_page .addList').attr("data-load", "1");

                    $("#leemask").hide();
                    $('#addressList_page').removeClass('page-right');
                    currentSite = "addressList_page";
                } else if (data.code == 202)
                    window.location.href = "http://tm.lilanz.com/lspx/jf.do?act=redirectL&url=/project/vipweixin/NewConfirmOrder.html?data=" + encodeURIComponent(LeeJSUtils.GetQueryParams("data"));
                else
                    LeeJSUtils.showMessage("error", data.msg);
            },
            error: function (XMLHttpRequest, textStatus, errorThrown) {
                LeeJSUtils.showMessage("error", "您的网络出问题啦..");
            }
        });
    }, 50);
}

//事件绑定
function BindEvents() {
    $("#addressList_page").on("click", ".top-rec-info", function () {
        var id = $(this).parent().attr("data-id");
        var cname = $(".user-name", $(this)).text();
        var mobile = $(".user-phone", $(this)).text();
        var address = $(".sf", $(this)).text() + $(".cs", $(this)).text() + $(".jd", $(this)).text() + $(".xxdz", $(this)).text();
        $(".address-wrap").html(template("tmp_chooseAddr", { cname: cname, mobile: mobile, address: address }));
        $(".address-wrap").attr("data-addr", id);
        $(".address-wrap").attr("data-addtype", "myaddr");
        returnTo('addressList_page', 'index');
    });

    //编辑地址
    $("#addressList_page").on("click", ".edit-wrap", function () {
        var addrid = $(this).parent().parent().parent().attr("data-id");
        editMyAddr(addrid);
    });

    $("#sprovince").change(function () {
        $("#sshop option:not(:first-child)").remove();
        $("#sshop").attr("disabled", "disabled");

        loadCity();
    });

    $("#province").change(function () {
        $("#city option:not(:first-child)").remove();
        $("#city").attr("disabled", "disabled");

        loadCity();
    });

    $("#scity").change(function () {
        loadShop();
    });

    $("#city").change(function () {
        loadDistrict();
    });

    $(".footer .subbtn").click(subOrder);

    //选择店铺地址
    $(".sureBtn").click(function () {
        var name = $("#shopname").val().trim();
        var mobile = $("#number").val().trim();
        var storeid = $("#sshop").val();
        if (name == "")
            LeeJSUtils.showMessage("warn", "收货人姓名不能为空");
        else if (mobile == "")
            LeeJSUtils.showMessage("warn", "收货人联系电话不能为空");
        else if (storeid == "" || storeid == "-1" || storeid == "0")
            LeeJSUtils.showMessage("warn", "请选择一家收货店铺");
        else {
            var ssf = $("#sprovince").find("option:selected").text();
            var scs = $("#scity").find("option:selected").text();
            var smd = $("#sshop").find("option:selected").text();
            $(".address-wrap").attr("data-addr", storeid);
            $(".address-wrap").attr("data-addtype", "shopaddr");

            var html = template("tmp_chooseAddr", { cname: name, mobile: mobile, address: ssf + scs + smd });
            $(".address-wrap").html(html);
            returnTo('shopAdd_page', 'index');
        }
    });

    //地址设置默认
    $("#setDefBtn").click(function () {
        var choose = $(this).attr("data-select");
        if (choose == "0") {
            $(".fa", $(this)).removeClass("fa-circle-thin").addClass("fa-check-circle");
            $(this).attr("data-select", "1");
        } else {
            $(".fa", $(this)).removeClass("fa-check-circle").addClass("fa-circle-thin");
            $(this).attr("data-select", "0");
        }
    });

    $(".addBtn").click(saveMyAddr);
}

//提交订单
function subOrder() {
    var addrid = $(".header .address-wrap").attr("data-addr");
    var itemCount = $("#index .order-list ul li").length;
    if (addrid == "" || addrid == "0")
        LeeJSUtils.showMessage("warn", "请选择收货地址");
    else if (parseInt(itemCount) <= 0)
        LeeJSUtils.showMessage("warn", "请至少选择一件要兑换的商品");
    else {
        LeeJSUtils.showMessage("loading", "正在提交订单，请稍候..");
        var detail = encodeURIComponent(LeeJSUtils.GetQueryParams("data"));
        //var _arr = [];
        //var items = $("#index .order-list ul li");
        //for (var i = 0; i < items.length; i++) {
        //    _arr.push({ id: $(items[i]).attr("data-id"), number: $(".nums>span", items[i]).text() });
        //}//end for
        setTimeout(function () {
            $.ajax({
                type: "POST",
                cache: false,
                timeout: 5 * 1000,
                contentType: "application/x-www-form-urlencoded; charset=utf-8",
                url: "/lspx/jf.do?act=OrderAdd&addrid=" + addrid + "&detail=" + detail,

                success: function (msg) {
                    var data = JSON.parse(msg);
                    if (data.code == 200) {
                        //window.location.href = "NewMyOrder.html";
                        LeeJSUtils.showMessage("successed", "操作成功！");
                        setTimeout(function () {
                            window.location.href = "NewMyOrder.html";
                        }, 1000);
                    } else {
                        LeeJSUtils.showMessage("error", data.msg);
                    }
                },
                error: function (XMLHttpRequest, textStatus, errorThrown) {
                    LeeJSUtils.showMessage("error", "您的网络出问题啦..");
                }
            });
        }, 100);
    }
}

//添加个人新的收货地址
function saveMyAddr() {
    var name = $("#name").val().trim();
    var phone = $("#phone").val().trim();
    var pro = $("#province").val();
    var city = $("#city").val();
    var dis = $("#district").val();
    var addr = $("#detailadd").val().trim();
    if (name == "")
        LeeJSUtils.showMessage("warn", "请输入收货人姓名");
    else if (phone == "")
        LeeJSUtils.showMessage("warn", "请输入收货人联系电话");
    else if (pro == "" || pro == "-1")
        LeeJSUtils.showMessage("warn", "请选择省份");
    else if (city == "" || city == "-1")
        LeeJSUtils.showMessage("warn", "请选择城市");
    else if (addr == "")
        LeeJSUtils.showMessage("warn", "请详细收货地址");
    else {
        var cn_pro = $("#province").find("option:selected").text();
        var cn_city = $("#city").find("option:selected").text();
        var cn_dis = "";
        if ($("#district").val() != -1) {
            cn_dis = $("#district").find("option:selected").text();
        }

        var isDefault = $("#setDefBtn").attr("data-select");
        LeeJSUtils.showMessage("loading", "正在保存，请稍候...");
        var mode = $("#myAdd_page").attr("data-mode"), url = "";
        var _data = {};
        if (mode == "add") {
            url = "/lspx/jf.do?act=UserAddrAdd";
            _data = { prov: cn_pro, city: cn_city, dist: cn_dis, oth: addr, mobi: phone, cname: name, isDefault: isDefault };
        } else if (mode == "edit") {
            url = "/lspx/jf.do?act=UserAddrEdit";
            var addrid = $("#myAdd_page").attr("data-id");
            _data = { prov: cn_pro, city: cn_city, dist: cn_dis, oth: addr, mobi: phone, cname: name, isDefault: isDefault, id: addrid };
        }
        setTimeout(function () {
            $.ajax({
                type: "POST",
                cache: false,
                timeout: 5 * 1000,
                contentType: "application/x-www-form-urlencoded; charset=utf-8",
                url: url,
                data: _data,
                success: function (msg) {
                    var data = JSON.parse(msg);
                    if (data.code == 200) {
                        LeeJSUtils.showMessage("successed", "操作成功！");
                        setTimeout(function () {
                            returnTo('myAdd_page', 'addressList_page');
                            loadAddlist();
                        }, 500);
                    } else {
                        LeeJSUtils.showMessage("error", data.msg);
                    }
                },
                error: function (XMLHttpRequest, textStatus, errorThrown) {
                    LeeJSUtils.showMessage("error", "您的网络出问题啦..");
                }
            });
        }, 50);
    }
}

//编辑收货地址
function editMyAddr(id) {
    //resetAddrForm();
    var obj = $(".selfaddress[data-id='" + id + "']");
    var name = $(".user-name", obj).text();
    var mobile = $(".user-phone", obj).text();
    var cn_pro = $(".sf", obj).text();
    var cn_city = $(".cs", obj).text();
    var cn_dist = $(".jd", obj).text();
    var cn_address = $(".xxdz", obj).text();
    var isDefault = obj.attr("data-default");
    if (isDefault == "1") {
        $("#setDefBtn .fa").removeClass("fa-circle-thin").addClass("fa-check-circle");
        $(this).attr("data-select", "1");
    } else {
        $("#setDefBtn .fa").removeClass("fa-check-circle").addClass("fa-circle-thin");
        $(this).attr("data-select", "0");
    }
    //填充数据到表单中
    $("#name").val(name);
    $("#phone").val(mobile);
    $("#detailadd").val(cn_address);

    $("#myAdd_page").attr("data-mode", "edit");
    $("#myAdd_page").attr("data-pro", cn_pro);
    $("#myAdd_page").attr("data-city", cn_city);
    $("#myAdd_page").attr("data-dist", cn_dist);
    $("#myAdd_page").attr("data-id", id);

    $("#province option").each(function () {
        if (cn_pro == $(this).text()) {
            $(this).attr("selected", "selected");
            $('#myAdd_page').removeClass('page-right');
            currentSite = "myAdd_page";
            loadCity();
        }
    });
}

//初始化地址表单
function resetAddrForm() {
    $("#name").val("");
    $("#phone").val("");
    $("#detailadd").val("");
    $("#setDefBtn .fa").removeClass("fa-check-circle").addClass("fa-circle-thin");
    $(this).attr("data-select", "0");

    $("#myAdd_page").attr("data-id", "");
    $("#myAdd_page").attr("data-mode", "");
    $("#myAdd_page").attr("data-pro", "");
    $("#myAdd_page").attr("data-city", "");
    $("#myAdd_page").attr("data-dist", "");

    $("#province").val("-1");
    $("#city option:not(:first-child)").remove();
    $("#city").attr("disabled", "disabled");

    $("#district option:not(:first-child)").remove();
    $("#district").attr("disabled", "disabled");
}