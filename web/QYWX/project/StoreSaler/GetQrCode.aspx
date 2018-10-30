<%@ Page Language="C#" %>
<%@ Import Namespace="System.IO" %>
<%@ Import Namespace="ThoughtWorks.QRCode.Codec" %>
<%@ Import Namespace="ThoughtWorks.QRCode.Codec.Data" %>
<%@ Import Namespace="ThoughtWorks.QRCode.Codec.Util" %>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">

<script runat="server">

    protected void Page_Load(object sender, EventArgs e)
    {
        string MyCode = Request.QueryString["code"];

        if (MyCode == string.Empty)
        {
            return;
        }
        else
        {
            MyCode = HttpUtility.UrlDecode(MyCode);
        }

        Response.ContentType = "application/octet-stream";
        MemoryStream MemStream = new MemoryStream();
        QRCodeEncoder qrCodeEncoder = new QRCodeEncoder();
        qrCodeEncoder.QRCodeEncodeMode = QRCodeEncoder.ENCODE_MODE.BYTE;
        qrCodeEncoder.QRCodeScale = 4;
        qrCodeEncoder.QRCodeVersion = 8;
        qrCodeEncoder.QRCodeErrorCorrect = QRCodeEncoder.ERROR_CORRECTION.M;
        System.Drawing.Image image = qrCodeEncoder.Encode(MyCode);
        image.Save(MemStream, System.Drawing.Imaging.ImageFormat.Png);

        Response.Clear();
        
        MemStream.WriteTo(Response.OutputStream);        
        MemStream.Close();
        image.Dispose();

        Response.End();
    }
</script>

<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <title></title>
</head>
<body>
    <form id="form1" runat="server">
    <div>
    
    </div>
    </form>
</body>
</html>
