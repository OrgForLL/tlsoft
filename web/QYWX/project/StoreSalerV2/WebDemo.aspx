<%@ Page Language="C#" AutoEventWireup="true" %> 

<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">

<html xmlns="http://www.w3.org/1999/xhtml">


<script runat="server"> 

 
    protected void Page_Load(object sender, EventArgs e)
    {

    }

    protected void btnText_Click(object sender, EventArgs e)
    {
        string pName = txtPlugin.Text;
        QQD_WebService.IBLL myBLL = QQD_WebService.BLL.BLLFactory.CreateInstance();//根据传入的参数创建业务逻辑插件
        lblInfo.Text = myBLL.GetPluginName();
    }

    protected void btnLoadData_Click(object sender, EventArgs e)
    {
        string pName = txtPlugin.Text;
        QQD_WebService.IBLL myBLL = QQD_WebService.BLL.BLLFactory.CreateInstance(pName);    //根据传入的参数创建业务逻辑插件

        string strBase = @"{{""Name"":""{0}"",""Operation"":""{1}"",""Value"":""{2}""}}";
        StringBuilder sbFind = new StringBuilder();
        sbFind.Append(@"{""WHERE"":[");

        sbFind.AppendFormat(strBase, "xm", "LIKE", "%金%"); 
        sbFind.Append(",");
        sbFind.AppendFormat(strBase, "xb", "=", "男");
        
        sbFind.Append("]}");


        GridView1.DataSource = myBLL.GetRyxxb(sbFind.ToString());
        GridView1.DataBind();
    } 

</script>


<head runat="server">
    <title></title>
</head>
<body>
    <form id="form1" runat="server">
    <div>
        <asp:TextBox ID="txtPlugin" runat="server"></asp:TextBox>
        <asp:Button ID="btnText" runat="server" Text="输出插件名称" OnClick="btnText_Click"/>
        <br />
        <asp:Label ID="lblInfo" runat="server" Text="插件名称"></asp:Label>        
        <br />
        <br />        
        <asp:Button ID="btnLoadData" runat="server" Text="获取人员数据(名字含有“金”的“男”)" OnClick="btnLoadData_Click" />
        
        <asp:GridView ID="GridView1" runat="server">
        </asp:GridView>
    </div>
    </form>
</body>
</html>

