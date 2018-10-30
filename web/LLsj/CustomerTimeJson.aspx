<%@ Page Language="C#" AutoEventWireup="true" %>
<%@ Import Namespace = "System.Data"%>
<script runat="server">

    protected void Page_Load(object sender, EventArgs e)
    {
        nrWebClass.DAL.SqlDbHelper sqlHelp = new nrWebClass.DAL.SqlDbHelper("data source=192.168.35.24;initial catalog=DHDB;user id=lllogin;password=rw1894tla;");
        string comm = "";
        if (Request.QueryString["khid"] != null)
        {
            comm = @"select t2.mc,t1.startday From t_khdhsj AS T1
                    INNER JOIN v_dht AS T2 ON T1.sst=t2.id
                     where khid={0} order by 2";
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
