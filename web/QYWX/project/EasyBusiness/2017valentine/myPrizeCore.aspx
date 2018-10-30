<%@ Page Language="C#" %>
<%@ Import Namespace="nrWebClass" %>
<%@ Import Namespace="System.Data.SqlClient" %>
<%@ Import Namespace="System.Data" %>
<%@ Import Namespace="System.Collections.Generic" %>

<!DOCTYPE html>
<script runat="server">
    private const string WXDBConstr = "server='192.168.35.62';uid=sa;pwd=ll=8727;database=weChatPromotion";
    private const string OAConnStr = "server=192.168.35.10;uid=ABEASD14AD;pwd=+AuDkDew;database=tlsoft";
    private string sskey = "7";//LILANZ利郎轻商务
    
    protected void Page_Load(object sender, EventArgs e) {
        string ctrl = Convert.ToString(Request.Params["ctrl"]);
        string openid = Convert.ToString(Session["openid"]);
        string wxid = Convert.ToString(Session["wxid"]);
        if (openid == "" || openid == null)
            clsSharedHelper.WriteErrorInfo("非法访问");
        else {
            switch (ctrl) {
                case "getMyPrizes":
                    getMyPrizes(openid);
                    break;    
                case "registInfo":
                    registInfo();
                    break;
                case "AutoLoadUserInfo":
                    AutoLoadUserInfo();
                    break;     
                default:
                    clsSharedHelper.WriteErrorInfo("请检查传入的参数！CTRL");
                    break;
            }
        }
    }    
    
    //查询个人的中奖记录
    public void getMyPrizes(string openid) {
        using (LiLanzDALForXLM dal = new LiLanzDALForXLM(WXDBConstr)) {
            string str_sql = @"select a.gameid,p.prizename,a.validtime,a.isget
                                from wx_t_getprizerecords a
                                inner join wx_t_gameprize p on a.prizeid=p.id
                                inner join wx_t_vipbinging wx on wx.id=a.wxid
                                where a.sskey=@sskey and wx.wxopenid=@openid
                                order by a.gameid asc,a.createtime desc";
            List<SqlParameter> paras = new List<SqlParameter>();
            paras.Add(new SqlParameter("@sskey",sskey));
            paras.Add(new SqlParameter("@openid", openid));
            DataTable dt;
            string errinfo = dal.ExecuteQuerySecurity(str_sql, paras, out dt);
            if (errinfo == "")
            {
                string msg = JsonHelp.dataset2json(dt);
                dt.Clear(); dt.Dispose();
                clsSharedHelper.WriteInfo(msg);
            }
            else
                clsSharedHelper.WriteErrorInfo(errinfo);
        }//end using
    }
    /// <summary>
    /// 登记信息
    /// </summary>
    private void registInfo()
    {
        string info = Convert.ToString(Request.Params["info"]);
       // clsLocalLoger.Log(info);
        //info = "{\"wxOpenid\":\"oyLvDjlGvpiCr0iuzCOyKWDjd3I8\",\"wxid\":\"41701\",\"Phone\":\"13799514955\",\"IDCard\":\"350524198906020572\",\"cname\":\"林文印1\"}";
        clsJsonHelper json = clsJsonHelper.CreateJsonHelper(info);
        if (string.IsNullOrEmpty(json.GetJsonValue("wxid")))
        {
            clsSharedHelper.WriteErrorInfo("wxid不允许为空");
            return;
        }
        if (string.IsNullOrEmpty(json.GetJsonValue("wxOpenid")))
        {
            clsSharedHelper.WriteErrorInfo("wxOpenid不允许为空");
            return;
        }
        if (json.GetJsonValue("Phone").Length != 11)
        {
            clsSharedHelper.WriteErrorInfo("电话号码不合法");
            return;
        }
         
        using (LiLanzDALForXLM dal = new LiLanzDALForXLM(WXDBConstr))
        {
            string errInfo;
            
            string mysql = "SELECT COUNT(1) FROM tm_t_UserInfo WHERE IDCard = @IDCard";
            List<SqlParameter> paras = new List<SqlParameter>();
            paras.Add(new SqlParameter("@IDCard", json.GetJsonValue("IDCard")));

            object objCount = 0;
            errInfo = dal.ExecuteQueryFastSecurity(mysql, paras, out objCount);
            if (errInfo != "")
            {
                clsLocalLoger.WriteError(string.Concat("查询身份证登记次数失败！IDCard=", json.GetJsonValue("IDCard")));
                clsSharedHelper.WriteInfo("网络不给力哟~");
                return;
            }
            if (objCount != null && Convert.ToInt32(objCount) > 1)
            {
                clsSharedHelper.WriteInfo("此身份证号码已登记多次！");
                return;
            } 
        
            mysql = "INSERT INTO tm_t_UserInfo(wxid,UserName,wxOpenid,Phone,IDCard,CreateTime) VALUES(@wxid,@UserName,@wxOpenid,@Phone,@IDCard,GETDATE())";
            paras.Clear();
            paras.Add(new SqlParameter("@wxid", json.GetJsonValue("wxid")));
            paras.Add(new SqlParameter("@UserName", json.GetJsonValue("cname")));
            paras.Add(new SqlParameter("@wxOpenid", json.GetJsonValue("wxOpenid")));
            paras.Add(new SqlParameter("@Phone", json.GetJsonValue("Phone")));
            paras.Add(new SqlParameter("@IDCard", json.GetJsonValue("IDCard")));
            errInfo = dal.ExecuteNonQuerySecurity(mysql,paras);
            if (errInfo != "")
            {
                clsLocalLoger.WriteError("登记身份证信息出错："+errInfo);
                clsSharedHelper.WriteInfo("呜呜~~，这里的网络不给力");
            }
            else
                clsSharedHelper.WriteSuccessedInfo("");
        }
    }


    //查询个人领票登记的信息
    public void AutoLoadUserInfo()
    {
        string openid = Request.Params["wxOpenid"];
        using (LiLanzDALForXLM dal = new LiLanzDALForXLM(OAConnStr))
        {
            string str_sql = @"SELECT TOP 1 dpxm,sfz,dh FROM yx_t_xsdp WHERE wxOpenID = @openid ";
            List<SqlParameter> paras = new List<SqlParameter>(); 
            paras.Add(new SqlParameter("@openid", openid));
            DataTable dt;
            string errinfo = dal.ExecuteQuerySecurity(str_sql, paras, out dt);
            if (errinfo == "")
            {
                if (dt.Rows.Count == 0)
                {
                    dt.Clear(); dt.Dispose();
                    clsSharedHelper.WriteInfo("");
                    return;                    
                }
                 
                string msg = JsonHelp.dataset2json(dt);
                dt.Clear(); dt.Dispose();
                clsSharedHelper.WriteInfo(msg);
            }
            else
                clsSharedHelper.WriteErrorInfo(errinfo);
        }//end using
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
