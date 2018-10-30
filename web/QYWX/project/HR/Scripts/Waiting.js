
function ShowWaiting(showInfo) {
    $("#divWaitInfo").html(showInfo);
    $("#divWaiting").css("display", "inline");
}
function HideWaiting() {
    $("#divWaiting").css("display", "none");
}