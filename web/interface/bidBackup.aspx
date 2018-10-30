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
        string str = "";
        string bid = bidtxt.Text;
        if (bid == "")
        {
            txtlab.Text = "请输入您要备份的BID！";
            return;
        }

        using (LiLanzDALForXLM dal = new LiLanzDALForXLM("Data Source = 192.168.35.23;Initial Catalog = hgpsoft0;User Id = lllogin;Password = rw1894tla;"))
        {
            string sql = "select sql,sql_zb,sql_cm,myFunc from t_rltable where bid=" + bid;
            DataTable dt = null;
            string errinfo = dal.ExecuteQuery(sql, out dt);
            if (errinfo == "")
            {
                if (dt.Rows.Count > 0)
                {
                    str += "\r\n-----------------------------------------JS---------------------------------------------\r\n";
                    str += dt.Rows[0]["myFunc"].ToString().Replace("^", "'");
                    str += "\r\n---------------------------------------主表SQL------------------------------------------\r\n";
                    str += dt.Rows[0]["sql_zb"].ToString().Replace("^", "'");
                    str += "\r\n---------------------------------------明细SQL------------------------------------------\r\n";
                    str += dt.Rows[0]["sql"].ToString().Replace("^", "'");
                    str += "\r\n---------------------------------------尺码SQL------------------------------------------\r\n";
                    str += dt.Rows[0]["sql_cm"].ToString().Replace("^", "'");
                    
                    Log(string.Concat("\r\n", str), Server.MapPath("./"));
                    System.Threading.Thread.Sleep(1000);
                    downFile2Local("BID" + bid + " " + DateTime.Now.ToString("yyMMddhhmmss") + ".log");
                    
                }
                else
                    txtlab.Text = "查询不到对应的BID信息！";
            }
            else
                txtlab.Text = errinfo;
        }
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
