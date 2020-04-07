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
        lilanz
    <%--<iframe id="mylabmain" src="http://web.nextsgo.com"></iframe>--%>
        <input type="button" onclick="test()" tabindex="1" value="test" />
        <input type="button" onclick="go()" value="go" />
        <input type="button" onclick="tb()" value="同步111" />
        <input type="text" id="cookieName" />
        <input type="text" id="cookieValue" />
        <input type="button" onclick="cookieFun(1)" value="写入" />
        <input type="button" onclick="cookieFun(2)" value="读取" />
    </div>
    </form>
</body>
</html>
<script type="text/javascript">

    function cookieFun(tag) {
        if (tag==1) {
            setCookie(document.getElementById("cookieName").value, document.getElementById("cookieValue").value, 12)
        } else if(tag==2) {
            var r = getCookie(document.getElementById("cookieName").value);
            document.getElementById("cookieValue").value = r;
        }
    }

    function setCookie(c_name, value, expiredays) {
        var exdate = new Date();
        exdate.setDate(exdate.getDate() + expiredays);
        document.cookie = c_name + "=" + escape(value)
                          + ((expiredays == null) ? "" : ";expires=" + exdate.toGMTString())
                          + ";path=/"
                          + ";domain=lilanz.nextsgo.com";
    }

    function getCookie(name) {
        var arr, reg = new RegExp("(^| )" + name + "=([^;]*)(;|$)"); //正则匹配
        if (arr = document.cookie.match(reg)) {
            return unescape(arr[2]);
        }
        else {
            return null;
        }
    }

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
