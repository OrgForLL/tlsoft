<%@ Page Language="C#" %>
<%@ Import Namespace="nrWebClass" %>
<%@ Import Namespace="System.Data.SqlClient" %>
<%@ Import Namespace="System.Data" %>
<%@ Import Namespace="System.IO" %>
<%@ Import Namespace="System.Collections.Generic" %>


<!DOCTYPE html>
<script runat="server">    

    protected void Page_Load(object sender, EventArgs e)
    {
        clsLocalLoger.logDirectory = Server.MapPath("./logs/");
        if (System.IO.Directory.Exists(clsLocalLoger.logDirectory) == false)
        {
            System.IO.Directory.CreateDirectory(clsLocalLoger.logDirectory);
        }
        clsLocalLoger.WriteInfo("123");
    }

    public static void Log(string strInfo, string logDirectory)
    {
        strInfo = string.Concat(DateTime.Now.ToString("yyyy-MM-dd HH:mm:ss"), " - ", "信息", "\r\n") + strInfo;
        string fileName = string.Concat(logDirectory, "\\", "tmp", ".log");
        System.IO.File.WriteAllText(fileName, strInfo, System.Text.Encoding.Default);
    }  
</script>

<html lang="en" xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <meta charset="utf-8" />
    <title></title>
</head>
<body>
    <form runat="server">
        <div>
            BID:<asp:TextBox ID="bidtxt" runat="server"></asp:TextBox><asp:Button ID="backup" runat="server" Text="Backup" />
            <asp:Label ID="txtlab" runat="server" Text="" ForeColor="Red"></asp:Label>
        </div>        
    </form>
</body>
</html>
