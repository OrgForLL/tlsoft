<%@ Page Language="C#" %>
<%@ Import Namespace="nrWebClass" %>
<%@ Import Namespace="System.Data.SqlClient" %>
<%@ Import Namespace="System.Data" %>
<%@ Import Namespace="System.Collections.Generic" %>
<%@ Import Namespace="Newtonsoft.Json.Linq" %>
<%@ Import Namespace="Newtonsoft.Json" %>

<!DOCTYPE html>
<script runat="server">
    private string ZBDBConstr =clsConfig.GetConfigValue("OAConnStr");// "server='192.168.35.10';database=tlsoft;uid=ABEASD14AD;pwd=+AuDkDew";// clsConfig.GetConfigValue("OAConnStr");//
    private string WXDBConstr =clsConfig.GetConfigValue("WXConnStr");// "server='192.168.35.62';database=weChatPromotion;uid=erpUser;pwd=fjKL29ji.353";//clsConfig.GetConfigValue("WXConnStr");//
    string rtjson;
    protected void Page_Load(object sender, EventArgs e)
    {
        rtjson = @"{{""code"":""{0}"",""info"":{1},""errmsg"":""{2}""}}";
        string ctrl = Convert.ToString(Request.Params["ctrl"]);
        string cid = Convert.ToString(Session["qy_customersid"]);
        string tzid = Convert.ToString(Session["tzid"]);

        //string flag = Convert.ToString(Request.Params["flag"]);
        //if (flag == "linwy")
        //{
        //    tzid = "190";
        //    cid = "352";
        //}


        if (string.IsNullOrEmpty(tzid))
        {
            clsSharedHelper.WriteInfo(string.Format(rtjson,"500","\"\"","超时访问,请刷新!"));
            return;
        }
        string khid, rq,days;
        switch (ctrl)
        {
            case "getbirthdaylist":
                khid = Convert.ToString(Request.Params["khid"]);
                rq = Convert.ToString(Request.Params["rq"]);
                vipBirthdayList(khid, rq);  
                break;
            case "birthdaysubscribe":
                 days=Convert.ToString(Request.Params["days"]);
                birthdaySubscribe(tzid, cid, days);
                break;
            case "subscriptionrecord":
                subscriptionRecord(cid);
                break;
            case "delsubscribe":
                string id = Convert.ToString(Request.Params["id"]);
                delsubscribe(cid,id);
                break;
            default:
                clsSharedHelper.WriteInfo(string.Format(rtjson, "500", "\"\"", "无效ctrl值"));
                break;
        }
    }
    /// <summary>
    /// 删除订阅记录
    /// </summary>
    /// <param name="cid">session["qy_customersid"]用户id，只能自己删自己的订阅</param>
    /// <param name="id">单据id</param>
    private void delsubscribe(string cid, string id)
    {
        if (string.IsNullOrEmpty(id))
        {
            clsSharedHelper.WriteInfo(string.Format(rtjson, "500", "\"\"", "请提供有效单据ID"));
            return;
        }
        string errInfo, mysql;
        mysql = "DELETE FROM wx_t_MsgSubscribe WHERE cid=@cid AND id=@id";
        List<SqlParameter> paras = new List<SqlParameter>();
        paras.Add(new SqlParameter("@cid",cid));
        paras.Add(new SqlParameter("@id", id));
        using (LiLanzDALForXLM dal = new LiLanzDALForXLM(WXDBConstr))
        {
            errInfo = dal.ExecuteNonQuerySecurity(mysql, paras);
        }
        if (errInfo != "")
        {
            clsSharedHelper.WriteInfo(string.Format(rtjson, "500", "\"\"", errInfo));
        }
        else
        {
            clsSharedHelper.WriteInfo(string.Format(rtjson, "200", "\"取消成功\"", ""));
        }
    }
    
    //订阅记录
    private void subscriptionRecord(string cid)
    {
        string errInfo, mysql;
        DataTable dt;
        mysql = string.Format("SELECT * FROM wx_t_MsgSubscribe WHERE cid={0} AND MsgType='VipBirthday' AND IsActive=1 ", cid);
        using (LiLanzDALForXLM dal = new LiLanzDALForXLM(WXDBConstr))
        {
            errInfo = dal.ExecuteQuery(mysql, out dt);
            if (errInfo != "")
            {
                clsSharedHelper.WriteInfo(string.Format(rtjson, "500", "\"\"", errInfo));
                return;
            }
            if (dt.Rows.Count == 0)
            {
                clsSharedHelper.WriteInfo(string.Format(rtjson, "200", "[]", ""));
                return;
            }
            
            List<string> khidlist = new List<string>();
            Dictionary<string, string> dicTemt;
            DataTable dt_r = new DataTable();
            
            dt_r.Columns.Add("khid", System.Type.GetType("System.String"));
            dt_r.Columns.Add("khmc", System.Type.GetType("System.String"));
            dt_r.Columns.Add("days", System.Type.GetType("System.String"));
            dt_r.Columns.Add("ID", System.Type.GetType("System.Int32"));
            foreach (DataRow dr in dt.Rows)
            {
                DataRow dr_r = dt_r.NewRow();
                dicTemt = JsonConvert.DeserializeObject<Dictionary<string, string>>(dr["MsgJson"].ToString());
                dr_r["khid"] = dicTemt["khid"];
                dr_r["khmc"] = "";
                dr_r["days"] = dicTemt["day"];
                dr_r["ID"] = dr["ID"];
                dt_r.Rows.Add(dr_r);
                if (!khidlist.Contains(dicTemt["khid"]))
                {
                    khidlist.Add(dicTemt["khid"].ToString());
                }
            }
         //   clsSharedHelper.WriteInfo(string.Join(",",khidlist.ToArray()));
            clsSharedHelper.DisponseDataTable(ref dt);
            mysql = string.Format("SELECT khid,khmc ,0 AS days FROM yx_t_khb WHERE khid IN({0})", string.Join(",", khidlist.ToArray()));
            errInfo = dal.ExecuteQuery(mysql, out dt);
            if (errInfo != "")
            {
                clsSharedHelper.WriteInfo(string.Format(rtjson, "500", "\"\"", errInfo));
                return;
            }
            Dictionary<string, string> dickhmc = new Dictionary<string, string>();
            foreach (DataRow dr in dt.Rows)
            {
                dickhmc.Add(dr["khid"].ToString(),dr["khmc"].ToString());
            }
            clsSharedHelper.DisponseDataTable(ref dt);

            foreach (DataRow dr in dt_r.Rows)
            {
                dr["khmc"] = dickhmc[dr["khid"].ToString()];
            }
           
            rtjson = string.Format(rtjson, "200", DataTableToJson(dt_r, false), "");
            clsSharedHelper.DisponseDataTable(ref dt_r);
            clsSharedHelper.WriteInfo(rtjson);
        }
    }
    //订阅客户
    private void birthdaySubscribe(string khid, string cid, string days)
    {
        string errInfo, mysql;
        List<SqlParameter> paras = new List<SqlParameter>();
        string msgjson = string.Format(@"{{  ""khid"": ""{0}"",  ""day"": ""{1}"" }}", khid, days);
        using (LiLanzDALForXLM dal = new LiLanzDALForXLM(WXDBConstr))
        {
            DataTable dt;
            mysql = "SELECT * FROM wx_t_MsgSubscribe WHERE MsgType='VipBirthday' AND CID=@cid AND MsgJson=@MsgJson ";
            paras.Add(new SqlParameter("@cid", cid));
            paras.Add(new SqlParameter("@MsgJson", msgjson));
            errInfo = dal.ExecuteQuerySecurity(mysql, paras, out dt);
            if (errInfo != "")
            {
                clsSharedHelper.WriteInfo(string.Format(rtjson, "500", "\"\"", errInfo));
                return;
            }
            if (dt.Rows.Count > 0)
            {
                clsSharedHelper.WriteInfo(string.Format(rtjson, "500", "\"\"", "您已订阅过了,不需要重新订阅"));
                return;
            }
            clsSharedHelper.DisponseDataTable(ref dt);
            mysql = "INSERT INTO wx_t_MsgSubscribe(cid,MsgType,MsgJson,IsActive) VALUES(@cid,@MsgType,@MsgJson,1)";
            paras.Clear();
            paras.Add(new SqlParameter("@cid", cid));
            paras.Add(new SqlParameter("@MsgType", "VipBirthday"));
            paras.Add(new SqlParameter("@MsgJson", msgjson));
            errInfo = dal.ExecuteNonQuerySecurity(mysql, paras);
            if (errInfo != "")
            {
                clsSharedHelper.WriteInfo(string.Format(rtjson, "500", "\"\"", errInfo));
                return;
            }
            clsSharedHelper.WriteInfo(string.Format(rtjson, "200", "\"订阅成功\"", ""));
        }
    }
    //获取客户vip列表
    private void vipBirthdayList(string khid,string rq)
    {
        string mysql = @"DECLARE @date  DATETIME;
                        SELECT @date=CAST(@rq AS DATETIME) 
                        SELECT a.xm,a.yddh,CONVERT(VARCHAR(100), a.csrq,23) AS csrq,a.id AS vipid,a.kh,0 AS wx_1,0 AS wx_4
                         FROM YX_T_Vipkh a 
                         inner join YX_T_Viplb klb on a.klb=klb.dm 
                        WHERE a.khid=@khid AND a.ty=0 AND ISNULL(a.csrq ,'1900-01-01') > '1900-01-01' 
                        AND MONTH(a.csrq)=MONTH(@date) AND DAY(a.csrq) =DAY(@date)";
        List<SqlParameter> paras = new List<SqlParameter>();
        paras.Add(new SqlParameter("@rq",rq));
        paras.Add(new SqlParameter("@khid", khid));
        DataTable dt;
        using(LiLanzDALForXLM dal=new LiLanzDALForXLM(ZBDBConstr)){
            string errInfo = dal.ExecuteQuerySecurity(mysql, paras, out dt);
            if (errInfo != "")
            {
                clsSharedHelper.WriteInfo(string.Format(rtjson,"500","\"\"",errInfo));
                return;
            }
            if (dt.Rows.Count == 0)
            {
                clsSharedHelper.WriteInfo(string.Format(rtjson, "200", "[]", ""));
                return;
            }
            
            Dictionary<string, int> dic_viprow = new Dictionary<string, int>();
            for (int i = 0; i < dt.Rows.Count; i++)//遍历内存表，获取内存表与vipid的对应关系
            {
                dic_viprow.Add(Convert.ToString(dt.Rows[i]["vipid"]), i);
            }
            string[] vipidlist=new string[dt.Rows.Count];
            dic_viprow.Keys.CopyTo(vipidlist,0 );
            //clsSharedHelper.WriteInfo(string.Join(",", vipidlist));
            DataTable dt_wx;
            //查询object=1 判断是否是利郎男装的会员
            mysql = string.Format(@"SELECT vipid FROM dbo.wx_t_vipBinging WHERE ObjectID=1 AND vipid IN({0})", string.Join(",", vipidlist));
            errInfo = dal.ExecuteQuery(mysql, out dt_wx);
            if (errInfo != "")
            {
                clsSharedHelper.WriteInfo(string.Format(rtjson, "500", "\"\"", errInfo));
                return;
            }
            foreach (DataRow dr in dt_wx.Rows)
            {
                dt.Rows[dic_viprow[dr["vipid"].ToString()]]["wx_1"] = "1";
            }
            clsSharedHelper.DisponseDataTable(ref dt_wx);
            
            //查询object=4 判断是否是利郎男装的会员
            mysql = string.Format(@"SELECT vipid FROM dbo.wx_t_vipBinging WHERE ObjectID=4 AND vipid IN({0})", string.Join(",", vipidlist));
            errInfo = dal.ExecuteQuery(mysql, out dt_wx);
            if (errInfo != "")
            {
                clsSharedHelper.WriteInfo(string.Format(rtjson, "500", "\"\"", errInfo));
                return;
            }
            foreach (DataRow dr in dt_wx.Rows)
            {
                dt.Rows[dic_viprow[dr["vipid"].ToString()]]["wx_4"] = "1";
            }
            clsSharedHelper.DisponseDataTable(ref dt_wx);

            clsSharedHelper.WriteInfo(string.Format(rtjson, "200", DataTableToJson(dt, false),""));
            clsSharedHelper.DisponseDataTable(ref dt);
        }
    }
    /// <summary>
    /// datatable转成json格式
    /// </summary>
    /// <param name="jsonName">转换后的json名称</param>
    /// <param name="dt">待转数据表</param>
    /// <returns></returns>
    private static string DataTableToJson(DataTable dt)
    {
        return DataTableToJson("", dt, true);
    }
    private static string DataTableToJson(DataTable dt, bool isShowName)
    {
        return DataTableToJson("", dt, isShowName);
    }
    public static string DataTableToJson(string jsonName, DataTable dt,bool isShowName)
    {
        StringBuilder Json = new StringBuilder();
        if (string.IsNullOrEmpty(jsonName))
        {
            jsonName = "list";
        }

        if (isShowName)
        {
            Json.Append("{\"" + jsonName + "\":[");
        }
        else
        {
            Json.Append( "[");
        }
        
        if (dt.Rows.Count > 0)
        {
            for (int i = 0; i < dt.Rows.Count; i++)
            {
                Json.Append("{");
                for (int j = 0; j < dt.Columns.Count; j++)
                {
                    Json.Append("\"" + dt.Columns[j].ColumnName.ToString() + "\":\"" + dt.Rows[i][j].ToString() + "\"");
                    if (j < dt.Columns.Count - 1)
                    {
                        Json.Append(",");
                    }
                }
                Json.Append("}");
                if (i < dt.Rows.Count - 1)
                {
                    Json.Append(",");
                }
            }
        }
     
        if (isShowName)
        {
            Json.Append("]}");
        }
        else
        {
            Json.Append("]");
        }
        return Json.ToString();
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
