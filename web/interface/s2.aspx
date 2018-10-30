<%@ Page Language="C#" %>
<%@ Import Namespace="System.Net.Sockets" %>

<!DOCTYPE html>
<script runat="server">
    public static int i = 0;
    private static Random random = new Random(DateTime.Now.Millisecond);
    
    protected void Page_Load(object sender, EventArgs e)
    {
        Response.Write(getString(8));
        Response.End();
        string[] s = { "a", "b", "c", "d", "e" };
        Response.Write(string.Join(",", s));
        Response.End();
        TcpClient tcpClient = new TcpClient("192.168.36.132", Convert.ToInt32("2112"));  // 配置主机号及端口 127.0.0.1 2112
        LogObj obj = new LogObj();
        obj.sourceIP = "192.168.36.132";
        
        obj.logText = "测试"+i.ToString();
        obj.exMessage = "1233";
        obj.exStackTrace = "中华人民共和国中华人民共和国中华人民共和国中华人民共和国中华人民共和国中华人民共和国中华人民共和国中华人民共和国中华人民共和国中华人民共和国中华人民共和国中华人民共和国中华人民共和国中华人民共和国中华人民共和国中华人民共和国中华人民共和国中华人民共和国中华人民共和国中华人民共和国中华人民共和国中华人民共和国中华人民共和国中华人民共和国中华人民共和国中华人民共和国中华人民共和国中华人民共和国中华人民共和国中华人民共和国中华人民共和国中华人民共和国中华人民共和国中华人民共和国中华人民共和国中华人民共和国中华人民共和国中华人民共和国中华人民共和国中华人民共和国中华人民共和国中华人民共和国中华人民共和国中华人民共和国中华人民共和国中华人民共和国中华人民共和国中华人民共和国中华人民共和国中华人民共和国中华人民共和国中华人民共和国中华人民共和国中华人民共和国中华人民共和国中华人民共和国";
        
        NetworkStream nws = tcpClient.GetStream(); // 获取连接流
        string txts = Serialiaze(obj);

        byte[] data = System.Text.Encoding.GetEncoding("GB2312").GetBytes(txts);
        foreach (byte b in data)
        {
            nws.WriteByte(b);
        }

        i++;
        nws.Dispose();
        nws.Close();
        tcpClient.Close();        
    }

    public string getString(int count)
    {
        int number;
        string checkCode = String.Empty;     //存放随机码的字符串           

        for (int i = 0; i < count; i++) //产生4位校验码   
        {
            number = random.Next();
            number = number % 36;
            if (number < 10)
            {
                number += 48;    //数字0-9编码在48-57   
            }
            else
            {
                number += 55;    //字母A-Z编码在65-90   
            }

            checkCode += ((char)number).ToString();
        }

        //判断数据库重复
        return checkCode;            
    }
    
    public string Serialiaze(object obj)
    {
        StringBuilder xml = new StringBuilder();
        using (System.Xml.XmlWriter writer = System.Xml.XmlWriter.Create(xml))
        {
            System.Xml.Serialization.XmlSerializer xs = new System.Xml.Serialization.XmlSerializer(obj.GetType());
            xs.Serialize(writer, obj);
            return xml.ToString();
        }
    }

    public class LogObj
    {
        private string _sourceIP = "";
        private string _logText = "";
        private string _exMessage = "";
        private string _exStackTrace = "";

        public string sourceIP
        {
            get { return this._sourceIP; }
            set { this._sourceIP = value; }
        }

        public string logText
        {
            get { return this._logText; }
            set { this._logText = value; }
        }

        public string exMessage
        {
            get { return this._exMessage; }
            set { this._exMessage = value; }
        }

        public string exStackTrace
        {
            get { return this._exStackTrace; }
            set { this._exStackTrace = value; }
        }
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
