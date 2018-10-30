<%@ Page Language="C#" AutoEventWireup="true" %>
<%@ Import Namespace = "System.Data"%>
<script runat="server">

    protected void Page_Load(object sender, EventArgs e)
    {
        nrWebClass.DAL.SqlDbHelper sqlHelp = new nrWebClass.DAL.SqlDbHelper("data source=192.168.35.24;initial catalog=DHDB;user id=lllogin;password=rw1894tla;");
        string comm = @"DECLARE @khid INT
		set @khid = (select ssid from yx_T_khb where khid={0})
		set @khid =(select top 1 t2.khid from t_khdhsj as t1 
		inner join yx_t_khb as t2  on t1.khid=t2.khid where t2.ssid=@khid)
		insert into t_khdhsj 
		select {0} khid,sst,startday,endday FROM t_khdhsj WHERE khid = @khid";
		
        if (Request.QueryString["khid"] != null)
        {
            comm = string.Format(comm, Request.QueryString["khid"].ToString());
			//log4net.Config.XmlConfigurator.Configure();
			//log4net.ILog log  = log4net.LogManager.GetLogger("File");
			//log.Info(comm);
        }
        if (sqlHelp.ExecuteNonQuery(comm) > 0)
            Response.Write("ok");
        else
            Response.Write("err");
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
