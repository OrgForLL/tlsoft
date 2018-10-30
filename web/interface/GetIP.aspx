<%@ Page Language="C#" %>
<%@ Import Namespace="nrWebClass" %>
<%@ Import Namespace="System.Data.SqlClient" %>
<%@ Import Namespace="System.Data" %>
<%@ Import Namespace="System.IO" %>
<%@ Import Namespace="System.Collections.Generic" %>
<%@ Import Namespace="System.Net" %>

<!DOCTYPE html>
<script runat="server">    

    protected void Page_Load(object sender, EventArgs e)
    {
        clsSharedHelper.WriteInfo(GetClientIP());
    }

    public static string GetClientIP()
    {
        //HttpContext.Current.Request.ServerVariables["HTTP_X_FORWARDED_FOR"]
        string result = null;
        if (null == result || result == String.Empty)
        {
            result = HttpContext.Current.Request.ServerVariables["REMOTE_ADDR"];
        }

        if (null == result || result == String.Empty)
        {
            result = HttpContext.Current.Request.UserHostAddress;
        }
        return result;
    }
    
    public string HttpDownloadFile(string url, string path)
    {
        // 设置参数
        HttpWebRequest request = WebRequest.Create(url) as HttpWebRequest;
        //发送请求并获取相应回应数据
        HttpWebResponse response = request.GetResponse() as HttpWebResponse;
        //直到request.GetResponse()程序才开始向目标网页发送Post请求
        Stream responseStream = response.GetResponseStream();
        //创建本地文件写入流
        Stream stream = new FileStream(path, FileMode.Create);
        byte[] bArr = new byte[1024];
        int size = responseStream.Read(bArr, 0, (int)bArr.Length);
        while (size > 0)
        {
            stream.Write(bArr, 0, size);
            size = responseStream.Read(bArr, 0, (int)bArr.Length);
        }
        stream.Close();
        responseStream.Close();
        return path;
    }

    public void downFile2Local(string localname)
    {        
        string fileName = localname;//客户端保存的文件名 
        string filePath = Server.MapPath("tmp.log");//路径 
        FileInfo fileInfo = new FileInfo(filePath);
        Response.Clear();
        Response.ClearContent();
        Response.ClearHeaders();
        Response.AddHeader("Content-Disposition", "attachment;filename=" + fileName);
        Response.AddHeader("Content-Length", fileInfo.Length.ToString());
        Response.AddHeader("Content-Transfer-Encoding", "binary");
        Response.ContentType = "application/octet-stream";
        Response.ContentEncoding = System.Text.Encoding.GetEncoding("gb2312");
        Response.WriteFile(fileInfo.FullName);
        Response.Flush();
        Response.End();
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
