$(document).ready(function () {
    FastClick.attach(document.getElementById("main"));
    FastClick.attach(document.getElementById("form-btns"));
    FastClick.attach(document.getElementById("footer-btns"));
    LeeJSUtils.stopOutOfPage("#main", true);
    LeeJSUtils.stopOutOfPage("#step1", true);
    LeeJSUtils.stopOutOfPage("#step2", true);
    LeeJSUtils.stopOutOfPage(".footer", false);
    LeeJSUtils.stopOutOfPage(".header", false);
    CurrentSite = "main";
    LeeJSUtils.LoadMaskInit();
});

window.onload = function () {
    $("#loadingmask").hide();    
    if (mdid != paraMdid && typeof(paraMdid)!="undefined" && paraMdid != "" && paraMdid != "0") {
        $("#myself-btn").hide();
        mdid = paraMdid;
    }
    if (dhbh == myLastdhbh) {
        $("#myself-btn").text("编辑我的信息");
    }

    LoadMainData();
}

//主入口
function LoadMainData() {
    LeeJSUtils.showMessage("loading", "正在加载列表,请稍候...");
    $.ajax({
        type: "POST",
        timeout: 5000,
        contentType: "application/x-www-form-urlencoded; charset=utf-8",
        url: "joinOrderCore.aspx",
        data: { ctrl: "GetDhryxxList", mdid: mdid },
        success: function (msg) {
            if (msg.indexOf("Error") > -1) {
                LeeJSUtils.showMessage("warn", msg);
            } else {
                var datas = JSON.parse(msg);
                var len = datas.rows.length;
                var htmlStr = "";
                for (var i = 0; i < len; i++) {
                    var row = datas.rows[i];
                    if (row.headImg == "")
                        row.headImg = "../../res/img/storesaler/defaulticon2.jpg";
                    else if (row.headImg.indexOf("/StoreSaler/") > -1)
                        row.headImg = "http://tm.lilanz.com/oa/" + row.headImg;
                    if (row.sex == undefined || row.sex == "0")
                        row.sexicon = "../../res/img/meeting/woman.png";
                    else
                        row.sexicon = "../../res/img/meeting/man.png";
                    if (row.goWayType == "0" || row.backWayType == "0")
                        row.flyflag = "hidden";
                    else
                        row.flyflag = "";
                    if (row.shbs == "1") {
                        row.shbs = "";
                        row.shzt = "已审核";
                    } else {
                        row.shbs = "not-verify";
                        row.shzt = "未审核";
                    }

                    if (row.hotel == "") {
                        row.hotel = "还未安排";
                        row.hotelRoom = "--";
                    }
                    row.rygx = row.rygx == "0" ? "" : row.rygx;
                    if (row.rygx == "其他" || row.rygx == "其他")
                        row.rygx = row.otherRygx;
                    //到达信息
                    row.goWayType = TrafficType(row.goWayType);
                    row.goWayNum = row.goWayNum == "" ? "--" : row.goWayNum;
                    row.goToAddr = row.goToAddr == "0" ? "--" : row.goToAddr;
                    row.goEndTime = row.goEndTime == "" ? "--" : row.goEndTime.replace("T", " ");
                    row.goTime = row.goTime == "" ? "--" : row.goTime;
                    row.goStartTime = row.goStartTime == "" ? "--" : row.goStartTime.replace("T"," ");
                    //返程信息
                    row.backWayType = TrafficType(row.backWayType);
                    row.backWayNum = row.backWayNum == "" ? "--" : row.backWayNum;
                    row.backFromAddr = row.backFromAddr == "0" ? "--" : row.backFromAddr;
                    row.backStartTime = row.backStartTime == "" ? "--" : row.backStartTime.replace("T", " ");
                    row.backTime = row.backTime == "" ? "--" : row.backTime;

                    htmlStr += template("list-item", row);
                }//end for                        
                if (htmlStr != "") {
                    $("#no-result").hide();
                    $("#orders-container").html(htmlStr);
                } else {
                    $("#orders-container").empty();
                    $("#no-result").show();
                }
                $("#leemask").hide();
            }
        },
        error: function (XMLHttpRequest, textStatus, errorThrown) {
            LeeJSUtils.showMessage("error", "网络连接失败！");
        }
    });//end AJAX
}

//加载个人信息
function GetPersonInfos(obj) {
    LeeJSUtils.showMessage("loading", "正在加载，请稍候..");
    CurrentID = $(obj).parent().attr("data-id");
    setTimeout(function () {
        $.ajax({
            type: "POST",
            timeout: 5000,
            contentType: "application/x-www-form-urlencoded; charset=utf-8",
            url: "joinOrderCore.aspx",
            data: { ctrl: "GetPersonDetail", ryid: CurrentID },
            success: function (msg) {
                if (msg.indexOf("Error") > -1)
                    LeeJSUtils.showMessage("error", msg);
                else {
                    var datas = JSON.parse(msg);
                    var len = datas.rows.length;
                    if (len == 0)
                        LeeJSUtils.showMessage("warn", "查询不到该用户信息！");
                    else {
                        var row = datas.rows[0];
                        if (row.headImg == "")
                            row.headImg = "../../res/img/storesaler/defaulticon2.jpg";
                        else if (row.headImg.indexOf("/StoreSaler/") > -1)
                            row.headImg = "http://tm.lilanz.com/oa/" + row.headImg;

                        $("#step1").html(template("step1-temp", row));
                        $("#step2").html(template("step2-temp", row));
                        $(".sex-item[sex='" + row.sex + "']").addClass("selected");
                        
                        if (row.rygx == "其他") {
                            $("#f-rygx").val("其他");
                            $("#other-rygx").val(row.otherRygx);
                            $("#other-rygxdiv").show();
                        } else {
                            $("#f-rygx").val(row.rygx);
                            $("#other-rygxdiv").hide();
                        }

                        $("#arrive-tool").val(row.goWayType);
                        if (row.goWayType == "1") {
                            $("#arrive-addr-air").val(row.goToAddr).show();
                            $("#arrive-addr-train").hide();
                            $("#arrive-addr-other").hide();
                        } else if (row.goWayType == "2" || row.goWayType == "3") {
                            $("#arrive-addr-train").val(row.goToAddr).show();
                            $("#arrive-addr-air").hide();
                            $("#arrive-addr-other").hide();
                        } else {
                            $("#arrive-addr-other").val(row.goToAddr).show();
                            $("#arrive-addr-air").hide();
                            $("#arrive-addr-train").hide();
                        }
                        $("#return-tool").val(row.backWayType);

                        if (row.backWayType == "1") {
                            $("#return-addr-air").val(row.backFromAddr).show();
                            $("#return-addr-train").hide();
                            $("#return-addr-other").hide();
                        } else if (row.backWayType == "2" || row.backWayType == "3") {
                            $("#return-addr-train").val(row.backFromAddr).show();
                            $("#return-addr-air").hide();
                            $("#return-addr-other").hide();
                        } else {
                            $("#return-addr-other").val(row.backFromAddr).show();
                            $("#return-addr-train").hide();
                            $("#return-addr-air").hide();
                        }

                        if (formType == "self")
                            $("#tip2").show();
                        CurrentSite = "form-step1";

                        $("#info-form").removeClass("page-right");
                    }
                }

                $("#leemask").hide();
            },
            error: function (XMLHttpRequest, textStatus, errorThrown) {
                LeeJSUtils.showMessage("error", "网络连接失败！");
            }
        });//end AJAX
    }, 200);
}

function LookMore(obj) {
    var mobj = $(".more-info", $(obj).parent());
    if (mobj.css("display") == "none") {
        //var _mobj = $(".more-info[status='opened']").next();
        //$(".more-info[status='opened']").hide();
        //$(".fa-angle-down", _mobj).removeClass("rotate");
        //$("span", _mobj).text("更多");
        //$(".more-info[status='opened']").removeAttr("status");

        mobj.show();
        $(".bot-item .fa-angle-down", $(obj).parent()).addClass("rotate");
        $(".bot-item span", $(obj).parent()).text("收起");
        $(mobj).attr("status", "opened");
    } else {
        mobj.hide();
        $(".bot-item .fa-angle-down", $(obj).parent()).removeClass("rotate");
        $(".bot-item span", $(obj).parent()).text("查看行程");
        $(mobj).attr("status", "closed");
    }
}

//查询上季人员信息 myself-自己 others-别人
function Register(type) {
    if (type == "myself") {
        formType = "self";
        if (dhbh == myLastdhbh) {
            //已录入则编辑自己的信息
            var _obj = $(".order-item[data-id=" + AppSystemKey + "]");
            var obj = $(".mid-item", _obj);
            GetPersonInfos(obj);
        } else {
            LeeJSUtils.showMessage("loading", "正在查询您的上季参会信息，请稍候..");
            $.ajax({
                type: "POST",
                timeout: 5000,
                contentType: "application/x-www-form-urlencoded; charset=utf-8",
                url: "joinOrderCore.aspx",
                data: { ctrl: "GetLastBaseInfo", cname: "", InfoType: "myself" },
                success: function (msg) {
                    if (msg.indexOf("Error") > -1)
                        LeeJSUtils.showMessage("error", msg);
                    else {
                        var datas = JSON.parse(msg);
                        var len = datas.rows.length;
                        if (len == 0) {
                            var o = {
                                "headImg": "../../res/img/storesaler/defaulticon2.jpg"
                            }
                            $("#step1").html(template("step1-temp", o));
                            $("#step2").html(template("step2-temp", o));
                            $(".sex-item[sex='0']").addClass("selected");
                            $("#f-rygx").val("0");

                        } else {
                            var row = datas.rows[0];
                            if (row.headImg == "")
                                row.headImg = "../../res/img/storesaler/defaulticon2.jpg";
                            else if (row.headImg.indexOf("/StoreSaler/") > -1)
                                row.headImg = "http://tm.lilanz.com/oa/" + row.headImg;

                            $("#step1").html(template("step1-temp", row));
                            $("#step2").html(template("step2-temp", row));
                            $(".sex-item[sex='" + row.sex + "']").addClass("selected");
                            
                            if (row.rygx == "其他") {
                                $("#f-rygx").val("其他");
                                $("#other-rygx").val(row.otherRygx);
                                $("#other-rygxdiv").show();
                            } else {
                                $("#f-rygx").val(row.rygx);
                                $("#other-rygxdiv").hide();
                            }

                            $("#tip2").show();
                            //$("#info-form").attr("wxid", row.wxid);
                        }
                        $("#info-form").attr("wxid", CustomersID);
                        $("#info-form").removeClass("page-right");
                        CurrentSite = "form-step1";
                        $("#leemask").hide();
                    }
                },
                error: function (XMLHttpRequest, textStatus, errorThrown) {
                    LeeJSUtils.showMessage("error", "网络连接失败！");
                }
            });
        }
    } else if (type == "others") {
        formType = "others";
        //直接填充进模板
        var o = {
            "headImg": "../../res/img/storesaler/defaulticon2.jpg"
        }

        $("#step1").html(template("step1-temp", o));
        $("#step2").html(template("step2-temp", o));
        $(".sex-item[sex='0']").addClass("selected");
        $("#form-search").show();
        $("#info-form").attr("wxid", "");
        $("#tip3").show();

        $("#info-form").removeClass("page-right");
        CurrentSite = "form-step1";
    }
}

$("#info-form").on("webkitTransitionEnd", function () {
    if (CurrentSite == "main") {
        $('#step2').addClass('right');
        $('#step1').removeClass('left');
        $("#info-form .line").addClass("unactive");
        $("#info-step2 p").addClass("unactive");
    }
});

$("#info-form").on("webkitAnimationEnd", ".tips", function () {
    $(".tips").removeClass("shake");
});

//当参会身份选择其它时显示输入框让其输入
$("#info-form").on("change", "#f-rygx", function () {
    var _rygx = $("#f-rygx").val();
    if (_rygx == "其他" || _rygx == "其它") {
        $("#other-rygxdiv").show();
    } else {
        $("#other-rygxdiv").hide();
    }
});

//到达交通工具选择
$("#info-form").on("change", "#arrive-tool", function () {
    var _tool = $("#arrive-tool").val();
    if (_tool == "1") {
        $("#arrive-addr-air").show();
        $("#arrive-addr-train").hide();
        $("#arrive-addr-other").hide();
    }
    else if (_tool == "2" || _tool == "3") {
        $("#arrive-addr-air").hide();
        $("#arrive-addr-train").show();
        $("#arrive-addr-other").hide();
    }
    else {
        $("#arrive-addr-air").hide();
        $("#arrive-addr-train").hide();
        $("#arrive-addr-other").show();
    }
});

$("#info-form").on("change", "#return-tool", function () {
    var _tool = $("#return-tool").val();
    if (_tool == "1") {
        $("#return-addr-air").show();
        $("#return-addr-train").hide();
        $("#return-addr-other").hide();
    }
    else if (_tool == "2" || _tool == "3") {
        $("#return-addr-air").hide();
        $("#return-addr-train").show();
        $("#return-addr-other").hide();
    }
    else {
        $("#return-addr-air").hide();
        $("#return-addr-train").hide();
        $("#return-addr-other").show();
    }
});

function BackBtn() {
    $("#info-form").addClass("page-right");
    $("#info-form").attr("wxid", "");
    $("#form-search").hide();
    CurrentID = "";
    formType = "";
    CurrentSite = "main";
    if (LoadFlag)
        LoadMainData();
    LoadFlag = false;
}

//保存函数
//保存的条件判断由服务端来做控制，比如确认后航班信息不能再修改
function SaveFunc() {
    if (!(SaveCheck())) {
        $("#step1 .tips").show();
        return;
    }

    //提交信息
    if (CurrentSite == "form-step1") {
        var name = $.trim($("#f-name").val());
        var sex = $("#f-sex .selected").attr("sex");
        if (sex == undefined || sex == "")
            sex = "0";
        var phone = $.trim($("#f-phone").val());
        var idcard = $.trim($("#f-idcard").val());
        var rygx = $("#f-rygx").val();
        var otherRygx = "";
        if (rygx == "其他" || rygx == "其它")
            otherRygx = $("#other-rygx").val();
        var wxid = $("#info-form").attr("wxid");
        var jsonstr = {
            "cname": name,
            "sex": sex,
            "phoneNumber": phone,
            "idCard": idcard,
            "rygx": rygx,
            "otherRygx": otherRygx,
            "ryid": CurrentID,
            "wxid": wxid,
            "mdid": mdid
        }
        LeeJSUtils.showMessage("loading", "正在提交,请稍候..");
        $.ajax({
            type: "POST",
            timeout: 5000,
            async: false,
            contentType: "application/x-www-form-urlencoded; charset=utf-8",
            url: "joinOrderCore.aspx",
            data: { ctrl: "SaveBaseInfo", baseInfoStr: JSON.stringify(jsonstr) },
            success: function (msg) {
                if (msg != "") {
                    //var rt = JSON.parse(msg);
                    if (msg.indexOf("Successed") > -1) {
                        $("#leemask").hide();
                        CurrentID = msg.replace("Successed", "");
                        if (CurrentID == "" || CurrentID == "0" || CurrentID == undefined) {
                            LeeJSUtils.showMessage("error", "CurrentID丢失！");
                            return;
                        }
                        //保存成功
                        LoadFlag = true;
                        if (formType == "self") {
                            AppSystemKey = CurrentID;
                            dhbh = myLastdhbh;
                            $("#myself-btn").text("编辑我的信息");
                        }

                        if (confirm("基础信息保存成功，是否要马上填写航班信息？")) {
                            $('#step1').addClass('left');
                            $('#step2').removeClass('right');
                            $("#info-form .line").removeClass("unactive");
                            $("#info-step2 .unactive").removeClass("unactive");
                            CurrentSite = 'form-step2';
                        } else {
                            BackBtn();
                        }
                    }//end 基础信息保存成功
                    else
                        LeeJSUtils.showMessage("error", "保存失败 " + msg);
                } else
                    $("#leemask").hide();
            },
            error: function (XMLHttpRequest, textStatus, errorThrown) {
                LeeJSUtils.showMessage("error", "网络连接失败！");
            }
        });//end AJAX                 
    } else if (CurrentSite == "form-step2") {
        //保存航班信息
        var arrTool = $("#arrive-tool").val();
        var arrAddr = "";
        if (arrTool == "1")
            arrAddr = $("#arrive-addr-air").val();
        else if (arrTool == "2" || arrTool == "3")
            arrAddr = $("#arrive-addr-train").val();
        else
            arrAddr = $("#arrive-addr-other").val();

        var arrNum = $.trim($("#arrive-num").val().toUpperCase());
        var arrTime = $("#arrive-time").val();
        arrTime = arrTime == "" ? "" : arrTime.replace("T", " ");

        var retTool = $("#return-tool").val();
        var retAddr = "";
        if (retTool == "1")
            retAddr = $("#return-addr-air").val();
        else if (retTool == "2" || retTool == "3")
            retAddr = $("#return-addr-train").val();
        else
            retAddr = $("#return-addr-other").val();

        var retNum = $.trim($("#return-num").val().toUpperCase());
        var retTime = $("#return-time").val();
        retTime = retTime == "" ? "" : retTime.replace("T", " ");
        
        var goTime = $("#arrive-gotime").val();//报到时间
        //goTime = goTime == "" ? "" : goTime.replace("T", " ");
        var goStartTime = $("#arrive-gostarttime").val();
        goStartTime = goStartTime == "" ? "" : goStartTime.replace("T", " ");//报到起飞时间
        var goFromAddr = $.trim($("#arrive-gofromaddr").val());//报到起飞起点
        var backTime = $("#return-backtime").val();//返程时间
        //backTime = backTime == "" ? "" : backTime.replace("T", " ");

        var flyinfo = {
            "id": CurrentID,
            "goInfo": {
                "wayType": arrTool,
                "wayNum": arrNum,
                "goAddr": arrAddr,
                "endTime": arrTime,
                "goTime": goTime,
                "goStartTime": goStartTime,
                "goFromAddr":goFromAddr
            },
            "backInfo": {
                "wayType": retTool,
                "wayNum": retNum,
                "fromAddr": retAddr,
                "startTime": retTime,
                "backTime":backTime
            }
        }
        LeeJSUtils.showMessage("loading", "正在提交,请稍候..");
        setTimeout(function () {
            $.ajax({
                type: "POST",
                timeout: 5000,
                async: false,
                contentType: "application/x-www-form-urlencoded; charset=utf-8",
                url: "joinOrderCore.aspx",
                data: { ctrl: "SaveDhryway", wayInfoStr: JSON.stringify(flyinfo) },
                success: function (msg) {
                    if (msg != "") {
                        if (msg.indexOf("Successed") > -1) {
                            LeeJSUtils.showMessage("successed", "保存成功！");
                            LoadFlag = true;
                            BackBtn();
                        }//end 航班信息保存成功
                        else
                            LeeJSUtils.showMessage("error", "保存失败 " + msg);
                    } else
                        $("#leemask").hide();
                },
                error: function (XMLHttpRequest, textStatus, errorThrown) {
                    LeeJSUtils.showMessage("error", "网络连接失败！");
                }
            });//end AJAX
        }, 300);
    }
}

//保存检查函数
function SaveCheck() {
    var cname = $.trim($("#f-name").val());
    if (cname == "") {
        Slide2Step1();
        $("#tip-text").text("姓名不能为空!");
        $(".tips").addClass("shake");
        return false;
    }
    var phone = $.trim($("#f-phone").val());
    if (phone == "" || phone.length != 11) {
        Slide2Step1();
        $("#tip-text").text("请填写11位有效手机号!");
        $(".tips").addClass("shake");
        return false;
    }
    var idcard = $.trim($("#f-idcard").val());
    if (idcard == "") {
        Slide2Step1();
        $("#tip-text").text("身份证不能为空!");
        $(".tips").addClass("shake");
        rt = false;
    } else if (!IdentityCodeValid(idcard)) {
        Slide2Step1();
        $("#tip-text").text("请填写有效的身份证号!");
        $(".tips").addClass("shake");
        return false;
    }

    var rygx = $("#f-rygx").val();
    var otherRygx = $.trim($("#other-rygx").val());
    if ((rygx == "其他" || rygx == "其它") && otherRygx == "") {
        Slide2Step1();
        $("#tip-text").text("请输入准确的参会身份!");
        $(".tips").addClass("shake");
        return false;
    }

    return true;
}

function Slide2Step1() {
    if (CurrentSite != "form-step1") {
        $('#step2').addClass('right');
        $('#step1').removeClass('left');
        $("#info-form .line").addClass("unactive");
        $("#info-step2 p").addClass("unactive");
        CurrentSite = 'form-step1';
    }
}

//查询他人上季参会信息
function SearchOthers() {
    var cname = $("#f-name").val();
    if (cname == "")
        LeeJSUtils.showMessage("warn", "请输入TA的姓名！");
    else {
        LeeJSUtils.showMessage("loading", "正在查询【" + cname + "】的上季参会信息..");
        $.ajax({
            type: "POST",
            timeout: 5000,
            async: false,
            contentType: "application/x-www-form-urlencoded; charset=utf-8",
            url: "joinOrderCore.aspx",
            data: { ctrl: "GetLastBaseInfo", cname: cname, InfoType: "others" },
            success: function (msg) {
                if (msg.indexOf("Error") > -1) {
                    LeeJSUtils.showMessage("error", "查询失败 " + msg);
                } else {
                    var datas = JSON.parse(msg);
                    var len = datas.rows.length;
                    if (len == 0) {
                        LeeJSUtils.showMessage("warn", "对不起，找不到【" + cname + "】的上季参会信息，请手动录入！");
                    }
                    else {
                        var row = datas.rows[0];
                        if (row.headImg == "")
                            row.headImg = "../../res/img/storesaler/defaulticon2.jpg";
                        else if (row.headImg.indexOf("/StoreSaler/") > -1)
                            row.headImg = "http://tm.lilanz.com/oa/" + row.headImg;

                        $("#step1").html(template("step1-temp", row));
                        $("#step2").html(template("step2-temp", row));
                        $(".sex-item[sex='" + row.sex + "']").addClass("selected");
                        $("#f-rygx").val(row.rygx);
                        $("#info-form").attr("wxid", row.wxid);
                        //设置姓名框只读，防止找到某人信息后又把名字改掉导致资料乱套，并给出提示
                        $("#f-name").attr("readonly", "readonly");
                        $("#tip1 span").text(cname);
                        $("#tip1").show();

                        LeeJSUtils.showMessage("successed", "找到【" + cname + "】的上季参会信息！");
                        $("#info-form").removeClass("page-right");
                        CurrentSite = "form-step1";
                    }
                }
            },
            error: function (XMLHttpRequest, textStatus, errorThrown) {
                LeeJSUtils.showMessage("error", "网络连接失败！");
            }
        });//end AJAX 
    }
}

function TrafficType(traffic) {
    switch (traffic) {
        case '1':
            return "飞机";
            break;
        case '2':
            return "火车";
            break;
        case '3':
            return "动车";
            break;
        case '4':
            return "汽车";
            break;
        case '5':
            return "其他";
            break;
        default: return "--";
    }
}

//性别切换
function SexSwitch(obj) {
    $(".selected", $(obj).parent()).removeClass("selected");
    $(obj).addClass("selected");
}

//步骤切换
$(".step-item").on("touchend", function () {
    var id = $(this).attr("id");
    if (id == "info-step1") {
        if (CurrentSite != "form-step1") {
            $('#step2').addClass('right');
            $('#step1').removeClass('left');
            $("#info-form .line").addClass("unactive");
            $("#info-step2 p").addClass("unactive");
            CurrentSite = 'form-step1';
        }
    } else if (id == "info-step2") {
        if (CurrentSite != "form-step2") {
            if (CurrentID == "" || CurrentID == "0")
                LeeJSUtils.showMessage("warn", "对不起，请先保存基础信息！");
            else {
                $('#step1').addClass('left');
                $('#step2').removeClass('right');
                $("#info-form .line").removeClass("unactive");
                $("#info-step2 .unactive").removeClass("unactive");
                CurrentSite = 'form-step2';
            }
        }
    }
});

//身份证有效性判断
function IdentityCodeValid(code) {
    var city = { 11: "北京", 12: "天津", 13: "河北", 14: "山西", 15: "内蒙古", 21: "辽宁", 22: "吉林", 23: "黑龙江 ", 31: "上海", 32: "江苏", 33: "浙江", 34: "安徽", 35: "福建", 36: "江西", 37: "山东", 41: "河南", 42: "湖北 ", 43: "湖南", 44: "广东", 45: "广西", 46: "海南", 50: "重庆", 51: "四川", 52: "贵州", 53: "云南", 54: "西藏 ", 61: "陕西", 62: "甘肃", 63: "青海", 64: "宁夏", 65: "新疆", 71: "台湾", 81: "香港", 82: "澳门", 91: "国外 " };
    var pass = true;

    if (!code || !/^\d{6}(18|19|20)?\d{2}(0[1-9]|1[12])(0[1-9]|[12]\d|3[01])\d{3}(\d|X)$/i.test(code)) {
        pass = false;
    }

    else if (!city[code.substr(0, 2)]) {
        pass = false;
    }
    else {
        //18位身份证需要验证最后一位校验位
        if (code.length == 18) {
            code = code.split('');
            //加权因子
            var factor = [7, 9, 10, 5, 8, 4, 2, 1, 6, 3, 7, 9, 10, 5, 8, 4, 2];
            //校验位
            var parity = [1, 0, 'X', 9, 8, 7, 6, 5, 4, 3, 2];
            var sum = 0;
            var ai = 0;
            var wi = 0;
            for (var i = 0; i < 17; i++) {
                ai = code[i];
                wi = factor[i];
                sum += ai * wi;
            }
            var last = parity[sum % 11];
            if (parity[sum % 11] != code[17]) {
                pass = false;
            }
        }
    }
    return pass;
}