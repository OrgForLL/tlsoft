var timeoutState = null;
var funSub; 

//探测二维码状态的方法
function RunGet2WCodeState(uuid) {
    var myData = "ctrl=Get2WCodeState";
    myData += "&uuid=" + uuid;

    $.ajax({
        url: "WX2wCode.aspx",
        type: "POST",
        data: myData,
        timeout: 1500,
        success: function (data) {
            my2WCodeState(uuid, data);
        }
    });
}