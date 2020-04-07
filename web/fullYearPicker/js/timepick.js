//$('#div1').fullYearPicker('getSelected')//获取日历当前选中值
//$('#div1').fullYearPicker('acceptChange')//更新日历
//$('#div1').fullYearPicker('getSelected')//获取所有选中的日期
//$('#div1').fullYearPicker('setYear', parseInt(year))//设置指定的年份
$(document).ready(function () {
    var req = GetRequest();
    var pivotalID = req.pivotalID;
    var toID = req.toID;
    var dataList = new Array();
    $(".btn_save").click(function (e) {
        goSave(pivotalID, toID);
    });

    //取数
    $.ajax({
        url: "./timerpick.ashx?action=getdata&pivotalID=" + pivotalID + "&toID=" + toID,
        dataType: "JSON",
        timeout: 10000,
        async: false,
        contentType: "application/json",
        type: "get",
        success: function (data) {
            for (var i = 0; i < data.zb.length; i++) {
                dataList.push(new Date(data.zb[i].rq));
            }
            initTimePick(initTimePick);
        },
        error: function (a, b, c) {
            alert("请求数据失败");
        }
    });


});

function initTimePick(dataList) {
    $('#timeDiv').fullYearPicker({
        disable: false,//只读
        year: "2019",//指定年份
        initDate: dataList,//初始化选中日期
        yearScale: { min: 1949, max: 2100 },//初始化日历范围
        format: "YYYY-MM-DD",//日期格式化  YYYY-MM-DD  YYYY-M-D
        cellClick: function (dateStr, isDisabled) {//当前选中日期回调函数
        },
        choose: function (a) {//实时获取所有选中的日期的回调函数（推荐使用）
            $("#a").text(JSON.stringify(a));
        }
    });
}

function goSave(pivotalID, toID) {
    var jsonObj = {};//要传递的数组
    jsonObj.dateList = $('#timeDiv').fullYearPicker('getSelected');
    jsonObj.username = "empty";
    $.ajax({
        url: "./timerpick.ashx?action=savedata&pivotalID=" + pivotalID + "&toID=" + toID,
        dataType: "JSON",
        contentType: "application/x-www-form-urlencoded; charset=utf-8",
        timeout: 10000,
        async: false,
        data: { json: JSON.stringify(jsonObj) },
        type: "POST",
        success: function (data) {
            if (data.errcode == 0) {
                alert("保存成功")
            } else {
                alert("保存失败")
            }
        },
        error: function (a, b, c) {
            alert("请求数据失败");
        }


    });
}

function GetRequest() {
    var url = location.search; //获取url中"?"符后的字串   
    var theRequest = new Object();
    if (url.indexOf("?") != -1) {
        var str = url.substr(1);
        strs = str.split("&");
        for (var i = 0; i < strs.length; i++) {
            theRequest[strs[i].split("=")[0]] = unescape(strs[i].split("=")[1]);
        }
    }
    return theRequest;
}