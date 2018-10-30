<%@ Page Language="C#" %>

<%@ Import Namespace="System.Data.SqlClient" %>
<%@ Import Namespace="System.Data" %>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">

<script runat="server">

    protected void Page_Load(object sender, EventArgs e)
    {
        String ksrq, jsrq, orderInfo, ccid, approve, khfl, kfbh, mddm, mdmc;
        try
        {
            ccid = Request.Params["ccid"];
            orderInfo = Request.Params["orderInfo"];
            ksrq = Request.Params["ksrq"];
            jsrq = Request.Params["jsrq"];
            approve = Request.Params["approve"];
            khfl = Convert.ToString(Request.Params["khfl"]);
            kfbh = Convert.ToString(Request.Params["kfbh"]);
            mddm = Convert.ToString(Request.Params["mddm"]);
            mdmc = HttpUtility.UrlDecode(Convert.ToString(Request.Params["mdmc"]));
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
        if (orderInfo == null)
        {
            orderInfo = "";
        }

        string filter = "";
        if (khfl != null && khfl != "")
        {
            if (khfl == "xk") filter = string.Concat(filter, " and b.khfl LIKE 'x[k,m,n]' ");
            else filter = " and b.khfl='" + khfl + "'";
        }

        if (string.IsNullOrEmpty(mddm) == false) filter = string.Concat(filter, string.Format(" and md.mddm like '%{0}%'", mddm));
        if (string.IsNullOrEmpty(mdmc) == false) filter = string.Concat(filter, string.Format(" and md.mdmc like '%{0}%'", mdmc));

        if (string.IsNullOrEmpty(kfbh) == false) filter = string.Concat(filter, " and  D.kfbh='", kfbh, "'");
        String mySql = @"SELECT SUM(C.je) je,SUM(C.sl) sl,COUNT(distinct D.SKU) sku,MD.mddm,MD.mdmc,MD.mdid,md.khid
                            FROM YX_T_dddjb A INNER JOIN yx_t_khb B ON (A.zmdid = B.khid OR (A.zmdid = 0 AND A.khid =B.khid))
                            INNER JOIN YX_T_dddjmx C ON A.id=C.id INNER JOIN yx_t_ypdmb D ON C.yphh=D.yphh
                            INNER JOIN t_MDb MD ON A.xjshgwid=MD.mdid
                            WHERE A.tzid=1 " + approve + filter + " AND B.ccid + '-' LIKE '" + ccid + @"' AND a.rq>='" + ksrq + @"' and a.rq<dateadd(day,1,'" + jsrq + @"')
                            GROUP BY MD.mddm,MD.mdmc,MD.mdid,md.khid ";
        if (orderInfo != "")
        {
            mySql += " order by " + orderInfo;
        }
       
        mySqlDbHelper.ConfigFile = HttpContext.Current.Server.MapPath("Sys.config");
        SqlParameter[] splist = new SqlParameter[] { new SqlParameter("@ccid", ccid), new SqlParameter("@ksrq", ksrq), new SqlParameter("@jsrq", jsrq) };
        string json = mySqlDbHelper.GetInstants().dataset2json(mySql, splist, new string[] { "sl", "je", "sku" }, new string[] { "sSl", "sJe", "sSKU" });
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
