﻿<%@ Page Language="C#" %>
<%@ Import Namespace="nrWebClass" %>
<!DOCTYPE html>
<script runat="server">
    protected void Page_Load(object sender, EventArgs e) {
        clsSharedHelper.WriteInfo(@"{""stauts"":""1""}");
    }    
</script>
<html lang="en" xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
<meta charset="utf-8" />
    <title></title>    
</head>
<body>
    <form id="form1" runat="server">   
    </form>
</body>
</html>