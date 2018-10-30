<%@ Page Language="C#" AutoEventWireup="true" %>
<%@ Import Namespace="System.Data.SqlClient" %>
<%@ Import Namespace="System.Data" %>
<%@ Import Namespace="nrWebClass" %>
<%@ Import Namespace="System.Collections.Generic" %>
<!DOCTYPE html>
<script runat="server">
    protected void Page_Load(object sender, EventArgs e) {
        String str_sql = "";

        String splbid = Convert.ToString(Request.Params["splbid"]);        //商品类别ID
        String xjkhid = Convert.ToString(Request.Params["xjkhid"]);
        String sst = Convert.ToString(Request.Params["sst"]);
        String dataBegin = Convert.ToString(Request.Params["dataBegin"]);        //商品类别ID
        String dataEnd = Convert.ToString(Request.Params["dataEnd"]);        //商品类别ID

        String ccid = Convert.ToString(Request.Params["ccid"]);
        string orderInfo = Convert.ToString(Request.Params["orderInfo"]);       //排序规则
        String approve = Convert.ToString(Request.Params["approve"]);       //单据状态
        string khfl = Convert.ToString(Request.Params["khfl"]);
        string kfbh = Convert.ToString(Request.Params["kfbh"]);

        orderInfo = HttpUtility.UrlDecode(orderInfo);

        if (approve == "1")
        {
            approve = " and A.djbs=1 ";
        }
        else if (approve == "0")
        {
            approve = " and A.djbs=0 ";
        }
        else
        {
            approve = " ";
        }

        if (orderInfo == null || orderInfo == "")
        {
            orderInfo = " 金额 desc";
        }

        if (xjkhid != "" && !ccid.Contains('-' + xjkhid + '-'))
        {
            //ccid = ccid.Substring(0, ccid.Length - 1) + xjkhid + "-%";
            ccid = "%-" + xjkhid + "-%";
        }

        if (sst != "" && sst != null)
        {
            sst = "and c.sst=" + sst;
        }
        else
        {
            sst = "";
        }
        string filter = khfl == "" ? "" : " and b.khfl='" + khfl + "'";
        if (string.IsNullOrEmpty(kfbh) == false) filter = string.Concat(filter," and c.kfbh='",kfbh,"'");
        str_sql = @"select c.yphh 样品货号,c.ypmc 样品名称,SUM(AB.sl) 数量,SUM(AB.je) 金额
                    FROM YX_T_dddjb A INNER JOIN yx_t_khb B ON (A.zmdid = B.khid OR (A.zmdid = 0 AND A.khid =B.khid))
                    inner join yx_t_dddjmx AB on A.id=AB.id
                    inner join yx_t_ypdmb c on AB.yphh=c.yphh                     
                    where a.djlx=203 " + approve + filter + " AND A.tzid=1 AND B.ccid + '-' like  '" + ccid + @"' ";

        if (splbid != null && splbid != ""){
            str_sql += " AND c.splbid = '" + splbid + "' " ;
        }
        if (dataBegin != "" && dataEnd != "")
        {
            str_sql += " AND a.rq>='" + dataBegin + "' AND a.rq<='" + dataEnd + "' ";
        }
        if (sst != "")
        {
            str_sql += sst;
        }

        str_sql += @" group by c.yphh,c.ypmc order by " + orderInfo;

        mySqlDbHelper.ConfigFile = HttpContext.Current.Server.MapPath("Sys.config");
        List<SqlParameter> paras = new List<SqlParameter>();
        string json = mySqlDbHelper.GetInstants().dataset2json(str_sql, paras.ToArray(), new string[] { "数量", "金额" }, new string[] { "SumSL", "SumJE" });

        if (json != "")
        {
            Response.Write(json);
            Response.End();
        }
    }
</script>
<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
<meta http-equiv="Content-Type" content="text/html; charset=utf-8"/>
    <title></title>
</head>
<body>
    <form id="form1" runat="server">
    <div>
    
    </div>
    </form>
</body>
</html>
