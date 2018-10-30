<%@ Page Language="C#" AutoEventWireup="true" %>
<%@ Import Namespace = "System.Data"%>
<script runat="server">

    protected void Page_Load(object sender, EventArgs e)
    {
        nrWebClass.DAL.SqlDbHelper sqlHelp = new nrWebClass.DAL.SqlDbHelper("data source=192.168.35.24;initial catalog=DHDB;user id=lllogin;password=rw1894tla;");
        string comm = @"select khid,khdm,khdm+'.'+khmc khmc,khfl from yx_t_khb where ssid=1 and khfl like 'x[g,f,d]' and ty=0";
        if (Request.QueryString["khid"] != null)
        {
            comm = @"select t2.khmc,t3.mddm+'.'+t3.mdmc mdmc,t3.mdid, pwd, t1.khid from yx_T_khb as t1
                        inner join yx_T_khb as t2 on t2.khid=dbo.split(t1.ccid,'-',2) and t2.jb=1
                        inner join t_MDb as t3 on t1.khid=t3.khid
                        where t2.khid={0} and t1.ty=0";
            comm = string.Format(comm, Request.QueryString["khid"].ToString());
        }
        DataTable dt = sqlHelp.ExecuteDataTable(comm);
        Response.Write(nrWebClass.JsonHelp.dataset2json(dt));
        Response.End();
    }

</script>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">

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
