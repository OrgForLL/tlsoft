<%@ Page Language="C#" %>
<%@ Import Namespace="System.Data.SqlClient" %>
<%@ Import Namespace="System.Data" %>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">

<script runat="server">

    protected void Page_Load(object sender, EventArgs e)
    {
        String ksrq, jsrq, orderInfo, ccid, approve, khfl,splbid;
        try
        {
            ccid =Convert.ToString(Request.Params["ccid"]);
            orderInfo = HttpUtility.UrlDecode(Request.Params["orderInfo"]);
            ksrq = Request.Params["ksrq"];
            jsrq = Request.Params["jsrq"];
            approve = Request.Params["approve"];
            khfl = Convert.ToString(Request.Params["khfl"]);
            splbid = Convert.ToString(Request.Params["splbid"]);
        }
        catch
        {
            Response.Write(@"{""err"":""【参数获取失败】""}");
            Response.End();
            return;
        }

        if (approve == "1")
        {
            approve = " AND b.djbs=1 ";
        }
        else if (approve == "0")
        {
            approve = " AND b.djbs=0 ";
        }
        else
        {
            approve = " ";
        }

        string[] khidArray = ccid.Split('-');
        if (ccid == "" || ccid==null)
        {
            Response.Write("无法获取用户信息，请重新登录");
            Response.End();
        }
        string filter="";
        if (khfl != null && khfl != "")
        {
            filter = " and a.khfl='" + khfl + "'";
        }

        if (splbid != null && splbid != "")
        {
            filter = string.Concat(filter," and d.splbid=",splbid);
        }

        string mySql = string.Format(@"
                SELECT a.khdm,a.khmc ,a.khid, SUM(c.je) je,SUM(c.sl) sl,COUNT(distinct d.SKU) sku
                FROM yx_T_khb a
                INNER JOIN YX_T_dddjb b ON a.khid=b.zmdid INNER JOIN dbo.YX_T_dddjmx c ON b.id=c.id
                INNER JOIN dbo.YX_T_Ypdmb d ON c.yphh=d.yphh
                WHERE  a.khid={0} AND a.ty=0 {1} and b.rq>='{2}' and a.rq<dateadd(day,1,'{3}') {4}
                GROUP BY a.khdm,a.khmc ,a.khid
                UNION ALL
                SELECT kh.khdm,kh.khmc ,kh.khid, SUM(c.je) je,SUM(c.sl) sl,COUNT(distinct d.SKU) sku
                FROM yx_T_khb kh INNER JOIN yx_t_khb a ON a.ty=0 AND  a.ccid+'-' LIKE kh.ccid+'-%' 
                INNER JOIN YX_T_dddjb b ON a.khid=b.zmdid INNER JOIN dbo.YX_T_dddjmx c ON b.id=c.id
                INNER JOIN dbo.YX_T_Ypdmb d ON c.yphh=d.yphh
                WHERE  kh.ssid={0} AND kh.ty=0 AND kh.khid<>1 {1} and b.rq>='{2}' and a.rq<dateadd(day,1,'{3}') {4}
                GROUP BY kh.khdm,kh.khmc ,kh.khid", khidArray[khidArray.Length - 1],approve,ksrq,jsrq,filter);

        if (khidArray[khidArray.Length - 1] == "1")
        {
            mySql =string.Format( @"SELECT a.khdm,a.khmc ,a.khid, SUM(c.je) je,SUM(c.sl) sl,COUNT(distinct d.SKU) sku
                        FROM yx_t_khb a inner JOIN  dbo.YX_T_dddjb b ON a.khid=b.khid
                        INNER JOIN YX_T_dddjmx c ON  b.id=c.id
                        INNER JOIN dbo.YX_T_Ypdmb d ON c.yphh=d.yphh
                        WHERE  a.ty=0 and b.rq>='{0}' and a.rq<dateadd(day,1,'{1}') {2} {3}
                        GROUP BY a.khdm,a.khmc ,a.khid", ksrq, jsrq, approve, filter);
        }

        if (!string.IsNullOrEmpty(orderInfo))
            mySql = @"select a.* from ( " + mySql + " ) a order by " + orderInfo;
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
