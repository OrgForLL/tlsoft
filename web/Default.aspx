<%@ Page Language="C#" AutoEventWireup="true" CodeFile="Default.aspx.cs" Inherits="_Default" %>

<!DOCTYPE html>

<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
<meta http-equiv="Content-Type" content="text/html; charset=utf-8"/>
    <title></title>
</head>
<body>
    <form id="form1" runat="server">
    <div>
        
    <%--<iframe id="mylabmain" src="http://web.nextsgo.com"></iframe>--%>
        <input type="button" onclick="test()" tabindex="1" value="test" />
        <input type="button" onclick="go()" value="go" />
        <input type="button" onclick="tb()" value="同步" />
    </div>
    </form>
</body>
</html>
<script type="text/javascript">

    function tb() {

    }
    var t = "";
    function go() {
        window.location.href = "http://www.google.com";
    }
    var isGo = false;
    var time = 0;
    function test() {
        if (!isGo) {
            isGo = true;
            console.log(2);
            time += 1;
        } else {
            //isGo = false;
            //console.log(1);
            //time += 1;
        }
        //console.log(time);
    };
    //window.onload = function () {
    //    if (document.getElementById("mylabmain").document == undefined) {
    //        ofrm1 = document.getElementById("mylabmain").contentWindow;  //ff
    //    }
    //    else {
    //        ofrm1 = document.frames["mylabmain"];
    //    }
    //    window.ofrm1 = ofrm1;
    //}
</script>
