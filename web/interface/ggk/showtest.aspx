<%@ Page Language="C#" %>

<%@ Import Namespace="nrWebClass" %>
<%@ Import Namespace="System.Data" %>
<%@ Import Namespace="System.Data.SqlClient" %>
<%@ Import Namespace="System.Collections.Generic" %>
<!DOCTYPE html>
<script runat="server"> 
    protected void Page_Load(object sender, EventArgs e)
    {
        //Random rd = new Random();
        //int s = rd.Next(1, 301);
        //clsSharedHelper.WriteSuccessedInfo(s.ToString());

        using (LiLanzDALForXLM dal = new LiLanzDALForXLM("server=192.168.35.10;database=tlsoft;uid=lllogin;pwd=rw1894tla"))
        {
            string str_sql = @"select case when count(id)>300 then 300 else count(id) end  
                                from yx_t_xsdp
                                where convert(varchar(10),fpsj,120)=convert(varchar(10),getdate(),120)";
            DataTable dt = null;
            string errinfo = dal.ExecuteQuery(str_sql, out dt);
            if (errinfo == "" && dt.Rows.Count > 0)
            {
                clsSharedHelper.WriteSuccessedInfo(dt.Rows[0][0].ToString());
            }
            else
                clsSharedHelper.WriteErrorInfo(errinfo);
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
