<%@ Page Language="C#" %>
<%@ Import Namespace="System.Data.SqlClient" %>
<%@ Import Namespace="System.Data" %>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">

<script runat="server">

    protected void Page_Load(object sender, EventArgs e)
    {
        String ksrq, jsrq, orderInfo, ccid, approve;
        try
        {
            ccid =Convert.ToString(Request.Params["ccid"]);
            orderInfo = Request.Params["orderInfo"];
            ksrq = Request.Params["ksrq"];
            jsrq = Request.Params["jsrq"];
            approve = Request.Params["approve"];
        }
        catch
        {
        Response.Write(@"{""err"":""【参数获取失败】""}");
        Response.End();
        return;
        }
        if (approve == "1")
        {
            approve = " AND A.djbs=1 ";
        }
        else if (approve == "0")
        {
            approve = " AND A.djbs=0 ";
        }
        else
        {
            approve = " ";
        }
        orderInfo = HttpUtility.UrlDecode(orderInfo);
        if (orderInfo == null || orderInfo == "")
        {
            orderInfo = " khdm ";
        }
       
        //Response.Write("无法获取用户信息，请重新登录");
        //Response.End();
        if (ccid == "" || ccid==null)
        {
            Response.Write("无法获取用户信息，请重新登录");
            Response.End();
        }
        
//         string mySql = @"select a.*,b.khmc,b.khdm from (
//                            SELECT SUM(C.je) je,SUM(C.sl) sl,COUNT(distinct D.SKU) sku,
//                            substring(replace(b.ccid,'-1-','')+'-',1,charindex('-',replace(b.ccid,'-1-','')+'-')-1) khid
//                            FROM YX_T_dddjb A 
//                            INNER JOIN yx_t_khb B ON (A.zmdid = B.khid OR (A.zmdid = 0 AND A.khid =B.khid))
//                            INNER JOIN YX_T_dddjmx C ON A.id=C.id INNER JOIN yx_t_ypdmb D ON C.yphh=D.yphh
//                            WHERE A.tzid=1 " + approve + " AND B.ccid + '-' LIKE '" + ccid + @"' AND a.rq>='" + ksrq + @"' and a.rq<dateadd(day,1,'" + jsrq + @"') 
//                            group by substring(replace(b.ccid,'-1-','')+'-',1,charindex('-',replace(b.ccid,'-1-','')+'-')-1)) a
//                            inner join yx_t_khb b on a.khid=b.khid ";

        string mySql = @"   SELECT SUM(C.je) je,SUM(C.sl) sl,COUNT(distinct D.SKU) sku,a.khid,b.khmc,b.khdm
                            FROM YX_T_dddjb A 
                            INNER JOIN yx_t_khb B on a.khid=b.khid --ON (A.zmdid = B.khid OR (A.zmdid = 0 AND A.khid =B.khid))
                            INNER JOIN YX_T_dddjmx C ON A.id=C.id INNER JOIN yx_t_ypdmb D ON C.yphh=D.yphh
                             WHERE A.tzid=1 " + approve + " AND B.ccid + '-' LIKE '" + ccid + @"' AND a.rq>='" + ksrq + @"' and a.rq<dateadd(day,1,'" + jsrq + @"') 
                            group by a.khid,b.khmc,b.khdm ";
         if (orderInfo != "")
         {
             mySql += " order by " + orderInfo;
         }
        
        mySqlDbHelper.ConfigFile = HttpContext.Current.Server.MapPath("Sys.config");
        SqlParameter[] splist = new SqlParameter[] { new SqlParameter("@ccid", ccid),new SqlParameter("@ksrq",ksrq),new SqlParameter("@jsrq",jsrq) };
        string json= mySqlDbHelper.GetInstants().dataset2json(mySql,splist, new string[]{"sl","je","sku"},new string[]{"sSl","sJe","sSKU"});
        if (json != "")
        {
            Response.Write(json);
            Response.End();
        }
        else
        {
            Response.Write("[]");
        }
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
