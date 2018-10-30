<%@ Page Language="vb" %>
<html>
<head><title>权限处理</title></head>
<OBJECT id="WebBrowser" height="0" width="0" classid="CLSID:8856F961-340A-11D0-A96B-00C04FD705A2" VIEWASTEXT></OBJECT>

<form id='MyForm' name='MyForm'  method=POST   action='#'  >
<body bgcolor=>
<%

Dim myUrlName = Trim(Request.ServerVariables("HTTP_USER_AGENT"))
response.write("========"+myUrlName  )


%>

</form>
</html>
