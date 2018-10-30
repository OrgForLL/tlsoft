define(function () {
    var MaxMsgCount = 20; //加载消息列表时，一次性最多显示这么多消息
    var listLastID = 0;
    var template = null;
    var $nowSelect = null;  //当前选择项

    var Init = function () {
        $("#saveNote").on("click", saveNote);
        $("#searchtxt").on("input", searchFunc);
        $(".btnVoice").on("touchstart", VoiceTouchstart);
        $(".btnVoice").on("touchend", VoiceTouchend);

        require(["wx"], function (mywx) {
            wx = mywx;  //保存起来以备后用

            wx.config({
                debug: false, // 开启调试模式,调用的所有api的返回值会在客户端alert出来，若要查看传入的参数，可以在pc端打开，参数信息会通过log打出，仅在pc端时才会打印。
                appId: appId, // 必填，公众号的唯一标识
                timestamp: timestamp, // 必填，生成签名的时间戳
                nonceStr: nonceStr, // 必填，生成签名的随机串
                signature: signature, // 必填，签名，见附录1
                jsApiList: ["startRecord", "stopRecord", "onVoiceRecordEnd", "translateVoice"] // 必填，需要使用的JS接口列表，所有JS接口列表见附录2
            });
        });
    }

    var flag = false;
    var stop;
    function VoiceTouchstart() {
        stop = setTimeout(function () {//down 1s，才运行。
            flag = true;
            startRecord();
        }, 800);
    }

    function VoiceTouchend() {//鼠标up时，判断down了多久，不足500ms，不执行down的代码。
        if (!flag) {
            clearTimeout(stop);
            showLoader("warn", "按住的时间太短！");
        }
        stopRecord();
    }

    var voiceStatus = 0;    //0未录制 1录制中 2录制完毕正在识别
    var localVoiceId = 0;

    function SetVoiceStatus(value) {
        voiceStatus = value;

        if (value == 0) {
            $(".VoiceState").addClass("hide");
        } else if (value == 1) {
            $("#voiceState1").removeClass("hide");
            $("#voiceState2").addClass("hide");
        } else if (value == 2) {
            $("#voiceState1").addClass("hide");
            $("#voiceState2").removeClass("hide");
        }
    }

    function startRecord() {
        if (voiceStatus == 0) {
            SetVoiceStatus(1);    //开始录制
            wx.startRecord();

            wx.onVoiceRecordEnd({
                // 录音时间超过一分钟没有停止的时候会执行 complete 回调
                complete: function (res) {
                    localVoiceId = res.localId;
                    translateVoice();
                }
            });
        } else {
            showLoader("warn", "请不要操作太快...");
            SetVoiceStatus(0);
        }
    }

    function stopRecord() {
        SetVoiceStatus(0);
        wx.stopRecord({
            success: function (res) {
                localVoiceId = res.localId;
                translateVoice();
            }
        });
    }

    function translateVoice() {
        SetVoiceStatus(2);

        wx.translateVoice({
            localId: localVoiceId, // 需要识别的音频的本地Id，由录音相关接口获得
            isShowProgressTips: 1, // 默认为1，显示进度提示
            success: function (res) {
                SetVoiceStatus(0);

                if (typeof (res.translateResult) != "undefined") {
                    var txt = $(".inputcss").val();
                    $(".inputcss").val(txt + res.translateResult); // 语音识别的结果 
                }
            }
        });
    }




    var LoadInfo = function () {
        if (template == null) {
            require(["text!../../project/StoreSaler/noteTemplate.html", "template"], function (content, loadtemplate) {
                $("body").append(content);
                template = loadtemplate;    //存储这个模板,以便在其它地方使用 

                LoadList();
            });
        } else {
            LoadList();
        }
    }

    function LoadList() {
        var timestamp = Date.parse(new Date());
        $.ajax({
            type: "POST",
            timeout: 15000,
            datatype: "html",
            url: "noteCore.aspx",
            data: { "ctrl": "getNotes", "SalerID": SalerID, "listLastID": listLastID, "ref": timestamp },
            cache: false,
            contentType: "application/x-www-form-urlencoded; charset=utf-8",
            success: function (data) {
                if (data.indexOf("Error:") == 0) {
                    showLoader("error", "加载错误！" + data);
                } else {
                    showLoader("successed", "加载成功！");

                    var infodata = JSON.parse(data);
                    var uhtml = template("infolist", infodata);
                    $(".chat-ul").append($(uhtml));

                    listLastID = infodata.listLastID;

                    infodata = "";  //注销大字符串
                    uhtml = "";

                    $(".chat-ul").on("click", "li", ChatContent);
                }
            },
            error: function (XMLHttpRequest, textStatus, errorThrown) {
                if (errorThrown.toString() != "") {     //如果没有错误，则不输出（AJAX调用期间，页面被关掉，也会出此错误；但错误内容为空）
                    showLoader("error", "网络错误！");
                    alert(errorThrown);
                }
            }
        });
    }

    var ChatContent = function () {
        $nowSelect = $(this);    //设置当前选择项

        var time = $nowSelect.find(".chat-info>.chat-time").html();
        var info = $nowSelect.find(".chat-info>.chat-name>span").html();
        if (time == "现在") {
            time = "现在正记录新笔记...";
            info = "";
        }

        $(".fromstore>span").html(time);
        $(".inputcss").val(info);
        $("#personal").removeClass("page-right");
    }

    $("#personal").on("webkitTransitionEnd", function () {
        if ($("#personal").hasClass("page-right"))
            $(".mask").fadeOut(250);
    });

    function BackFunc() {
        $("#chat-list").removeClass("page-left");
        $("#chat-detail").addClass("page-right");
    }

    function saveNote() {
        var id = $nowSelect.attr("myid");
        var info = $(".inputcss").val();

        if (info.length > 1000) {
            showLoader("error", "最多1000个字...");
            return;
        }

        var timestamp = Date.parse(new Date());
        $.ajax({
            type: "POST",
            timeout: 15000,
            datatype: "html",
            url: "noteCore.aspx",
            data: {
                "ctrl": "saveNote",
                "id": id,
                "SalerID": SalerID,
                "info": info,
                "ref": timestamp
            },
            cache: false,
            contentType: "application/x-www-form-urlencoded; charset=utf-8",
            success: function (data) {
                if (data.indexOf("Successed") == 0) {
                    showLoader("successed", "保存成功！");
                    data = data.substring(9);

                    if (id == "0") { //创建新版块 
                        id = data;

                        var infodata = {
                            list: [{
                                "id": data,
                                "time": "刚刚新增的笔记",
                                "info": info
                            }]
                        };

                        var uhtml = template("infolist", infodata);
                        $nowSelect = $(uhtml);
                        $(".chat-ul").find("li").eq(0).after($nowSelect);
                    } else { //修改旧值
                        $nowSelect.find(".chat-info>.chat-name>span").html(info);
                        $nowSelect.find(".chat-info>.chat-time").html("刚刚编辑的笔记");
                    }
                } else {
                    showLoader("error", "保存错误！" + data);
                }
            },
            error: function (XMLHttpRequest, textStatus, errorThrown) {
                if (errorThrown.toString() != "") { //如果没有错误，则不输出（AJAX调用期间，页面被关掉，也会出此错误；但错误内容为空）
                    showLoader("error", "网络错误！");
                    alert(errorThrown);
                }
            }
        });
    }

    //提示层
    function showLoader(type, txt) {
        switch (type) {
            case "loading":
                $(".mymask .fa").removeAttr("class").addClass("fa fa-2x fa-spinner fa-pulse");
                $("[id$=loadtext]").text(txt);
                $(".mymask").show();
                setTimeout(function () {
                    $(".mymask").fadeOut(500);
                }, 15000);
                break;
            case "successed":
                $(".mymask .fa").removeAttr("class").addClass("fa fa-2x fa-check");
                $("[id$=loadtext]").text(txt);
                $(".mymask").show();
                setTimeout(function () {
                    $(".mymask").fadeOut(500);
                }, 500);
                break;
            case "error":
                $(".mymask .fa").removeAttr("class").addClass("fa fa-2x fa-close (alias)");
                $("[id$=loadtext]").text(txt);
                $(".mymask").show();
                setTimeout(function () {
                    $(".mymask").fadeOut(500);
                }, 2000);
                break;
            case "warn":
                $(".mymask .fa").removeAttr("class").addClass("fa fa-2x fa-warning (alias)");
                $("[id$=loadtext]").text(txt);
                $(".mymask").show();
                setTimeout(function () {
                    $(".mymask").fadeOut(500);
                }, 1000);
                break;
        }
    }


    $.expr[":"].Contains = function (a, i, m) {
        return (a.textContent || a.innerText || "").toUpperCase().indexOf(m[3].toUpperCase()) >= 0;
    };

    function searchFunc() {
        var obj = $(".chat-ul li");
        if (obj.length > 0) {
            var filter = $("#searchtxt").val();
            if (filter != "") {
                var $matches = $(".chat-ul>li>.chat-info>.chat-name").find("span:Contains(" + filter + ")").parent().parent().parent();
                $("li", $(".chat-ul")).not($matches).hide();
                $matches.show();
            } else {
                $("li", $(".chat-ul")).show();
            }
        }
    }

    //对外只暴露这个函数
    return {
        Init: Init,
        LoadInfo: LoadInfo
    };
});
