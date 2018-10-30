function SaveBaseInfo() {

    var name = escape($("#Name").val());
    var sex = escape($('input[name="sex"]:checked').val());
    var birthday = escape($("#birthday").val());
    var phoneNum = escape($("#phoneNum").val());
    var Diploma = escape($("#Diploma").val());
    var School = escape($("#School").val());
    var Major = escape($("#Major").val());

    if (name == null || name == undefined) {
        alert("必须输入姓名！"); $("#Name").focus(); return;
    } else if (sex == null || sex == undefined) {
        alert("请选择性别！"); $("#male").focus(); return;
    } else if (birthday == null || birthday == undefined) {
        alert("出生日期还未填写！"); $("#birthday").focus(); return;
    } else if (phoneNum == null || phoneNum == undefined) {
        alert("请输入电话号码！"); $("#phoneNum").focus(); return;
    } else if (Diploma == null || Diploma == undefined) {
        alert("请选择学历！"); $("#Diploma").focus(); return;
    } else if (School == null || School == undefined) {
        alert("请输入学校名称！"); $("#School").focus(); return;
    } else if (Major == null || Major == undefined) {
        alert("请输入专业！"); $("#Major").focus(); return;
    }

    var myData = "Act=SaveBaseInfo&name=" + name + "&sex=" + sex + "&birthday=" + birthday + "&phoneNum=" + phoneNum + "&Diploma=" + Diploma + "&School=" + School + "&Major=" + Major;
//    alert(myData);

    ShowWaiting("正在保存信息...");
    $.ajax({
        type: "post",
        url: "WXHRHandler.ashx",
        data: myData,
        success: function (result) {
            HideWaiting();
            if (result.err == "") {
                alert(result.msg);
                gotoResumeView();
            } else { alert(result.err); }
        }
    });
}
 
function gotoResumeView() {
    var myDate = new Date();
    var temp=myDate.toLocaleString();
    $.mobile.changePage("ResumeView.aspx?temp", { reverse:"true",transition: "slidefade"});
//    location.href = "ResumeView.aspx";
}
function SaveGoodAndWeak() {
    var goodPoint = escape($("#goodPoint").val());
    var weakPoint = escape($("#weakPoint").val());
    ShowWaiting("正在保存信息...");
    $.ajax({
        type: "post",
        url: "WXHRHandler.ashx",
        data: "Act=SaveGoodAndWeak&goodPoint=" + goodPoint + "&weakPoint=" + weakPoint,
        success: function (result) {
            HideWaiting();
            if (result.err == "") {
                alert(result.msg);
                gotoResumeView();
            } else { alert(result.err); }
        }
    });
}


function SaveWorkInfo() {
    var WorkTimeStart = escape($("#tWorkTimeStart").val()).toString();
    var WorkTimeEnd = escape($("#tWorkTimeEnd").val()).toString();
    var Company = escape($("#tCompany").val());
    var Position = escape($("#tPosition").val());
    var mxid = escape($("#tmxid").val());
  //  alert("tWorkTimeStart:" + tWorkTimeStart);
//    alert("tWorkTimeEnd:" + tWorkTimeEnd);
//    alert("Company:"+Company);
//    alert("职位：" + Position);
//    alert("mxid：" + mxid);
    ShowWaiting("正在保存信息...");
    $.ajax({
        type: "post",
        url: "WXHRHandler.ashx",
        data: "Act=SaveWorkInfo&mxid=" + mxid + "&Position=" + Position + "&Company=" + Company + "&WorkTimeStart=" + WorkTimeStart + "&WorkTimeEnd=" + WorkTimeEnd,
        success: function (result) {
            HideWaiting();
            if (result.err == "") {
                alert(result.msg);
                //保存完毕后执行的代码
                $.mobile.changePage('WorkHistory.aspx', { transition: "slidefade", reverse: "true" });
                //                location.href = "WorkHistory.aspx";
            } else { alert(result.err); }
        }
    });
}

function MyDel(mxid) {
    var t = confirm("确定要删除记录？");
    if (t == 0) return;
    ShowWaiting("正在删除信息...");
    $.ajax({
        type: "post",
        url: "WXHRHandler.ashx",
        data: "Act=DelWorkInfo&mxid=" + mxid,
        success: function (result) {
            HideWaiting();
            if (result.err == "") {
                alert(result.msg);
                //删除完毕后执行的代码
                $.mobile.changePage('WorkHistory.aspx', { transition: "slide",reverse: "true" });
            } else { alert(result.err); }
        }
    });
}