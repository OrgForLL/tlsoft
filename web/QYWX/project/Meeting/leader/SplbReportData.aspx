<%@ Page Language="C#" AutoEventWireup="true" %>
<%@ Import Namespace="System.Data.SqlClient" %>
<%@ Import Namespace="System.Data" %>
<%@ Import Namespace="System.Collections.Generic" %>
<%@ Import Namespace="nrWebClass" %>
<!DOCTYPE html>
<script runat="server">
    private string DHDBConstr = "server='192.168.35.19';uid=ABEASD14AD;pwd=+AuDkDew;database=DHDB";
    protected void Page_Load(object sender, EventArgs e) {
        String str_sql = "", json = "", lx = "", orderInfo = "", showmsg = "", ksrq = "", jsrq = "", approve = "", khfl = "";
        String ccid = Convert.ToString(Request.Params["ccid"]);
        lx = Convert.ToString(Request.Params["lx"]);
        if (lx == "khfl") {
            LoadKhfl();
            return;
        }
        
        if (ccid == null || ccid == "") {
            showmsg = @"{""err"":""CCID丢失，请从iPad重新访问！""}";
            Response.Write(showmsg);
            Response.End();
            return;
        }
        
        try
        {             
             lx = Request.Params["lx"].ToString();            
             orderInfo = Request.Params["orderInfo"].ToString();//排序规则
             orderInfo = HttpUtility.UrlDecode(orderInfo);
             ksrq = Convert.ToString(Request.Params["ksrq"]);
             jsrq = Convert.ToString(Request.Params["jsrq"]);
             khfl = Convert.ToString(Request.Params["khfl"]);
            approve = Request.Params["approve"];//单据状态筛选条件 ""、0、1
        }
        catch {
            showmsg = @"{""err"":""【参数获取失败】""}";
            Response.Write(showmsg);
            Response.End();
            return;
        }
        if (approve == "1")
        {
            approve = " and a.djbs=1 ";
        }
        else if (approve == "0")
        {
            approve = " and a.djbs=0 ";
        }
        else
        {
            approve = " ";
        }
               
        if (lx == "splb") {
            string filter = khfl == "" ? "" : " and kh.khfl='" + khfl + "'";
            str_sql = @"select * from (select lb.dm,lb.mc,COUNT(distinct c.sku) SKU,SUM(isnull(b.sl,0)) sl,SUM(isnull(b.je,0)) je,lb.id from yx_t_dddjb a            
                        inner join yx_t_khb kh on a.khid=kh.khid
                        inner join yx_t_dddjmx b on a.id=b.id                                                                            
                        inner join yx_t_ypdmb c on b.yphh=c.yphh                    
                        inner join yx_T_Splb lb on c.splbid=lb.id                    
                        where a.djlx=203 " + approve + filter + " and a.tzid=1 and a.rq>='" + ksrq + @"' and a.rq<dateadd(day,1,'" + jsrq + @"') and kh.ccid + '-' like '" + ccid + @"'                    
                        group by lb.id,lb.mc,lb.dm) a ";
        }
        else if (lx == "dht") {
            str_sql = @"select * from (select t.dm,case when t.mc is null then '无厅信息' else t.mc end as mc,COUNT(distinct c.sku) SKU,SUM(b.sl) sl,SUM(b.je) je,isnull(c.sst,0) sst from yx_t_dddjb a
                        inner join yx_t_dddjmx b on a.id=b.id
                        inner join yx_t_khb kh on (a.zmdid = kh.khid or (a.zmdid = 0 and a.khid =kh.khid))
                        inner join yx_t_ypdmb c on b.yphh=c.yphh                    
                        left join v_dht t on c.sst=t.id 
                        where a.djlx=203 " + approve + " and a.tzid=1 and a.rq>='" + ksrq + @"' and a.rq<dateadd(day,1,'" + jsrq + @"') and kh.ccid + '-' like '" + ccid + @"'  
                        group by t.dm,t.mc,c.sst) a ";
        }
        
        if (orderInfo != "")
            str_sql += " order by " + orderInfo;

        mySqlDbHelper.ConfigFile = HttpContext.Current.Server.MapPath("Sys.config");
        SqlParameter[] paras = new SqlParameter[]{new SqlParameter("@ccid", ccid), new SqlParameter("@ksrq", ksrq), new SqlParameter("@jsrq", jsrq) };        
        json = mySqlDbHelper.GetInstants().dataset2json(str_sql, paras, new String[] { "SKU", "sl", "je" }, new String[] { "sSKU", "sSl", "sJe" });        

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

    public void LoadKhfl() {
        using (LiLanzDALForXLM dal = new LiLanzDALForXLM(DHDBConstr)) {
            string str_sql = @"select cs,cs+'.'+mc mc from yx_t_khfl where tzid=1";
            DataTable dt = null;
            string errinfo = dal.ExecuteQuery(str_sql,out dt);
            if (errinfo != "")
                clsSharedHelper.WriteErrorInfo(errinfo);
            else if (dt.Rows.Count == 0)
                clsSharedHelper.WriteInfo("");
            else
                clsSharedHelper.WriteInfo(JsonHelp.dataset2json(dt));                
        }//end using        
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
