<%@ Page Language="C#" %>
<%@ Import Namespace = "System" %>
<%@ Import Namespace = "System.Collections.Generic" %> 
<%@ Import Namespace = "System.Data" %>
<%@ Import Namespace = "System.Text" %>
<%@ Import Namespace = "nrWebClass" %>  
<%@ Import Namespace="System.Data.SqlClient" %>

<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<%--
页面说明：本页面用于引导粉丝关注 【利郎男装】
开发人员：薛灵敏   开发时间：20160219
接口说明：页面用于存储粉丝与导购的关联关系
部署说明：页面只会部署到VIP使用的公众号 【利郎男装】 WEB应用程序根目录下。
特别说明：页面的全名为：VipSalerBindFans.aspx 。
--%>
<script runat="server"> 
    private const string GotoVIPListUrl = @"<a href='http://tm.lilanz.com/oa/project/StoreSaler/NewVipList.aspx'>马上去看看》》</a>";
    private const string ConfigKeyValue = "5";
    protected void Page_Load(object sender, EventArgs e)
    {
        string BindKey = Convert.ToString(Request.Params["sid"]);

        if (BindKey == null || BindKey == "")
        {
            RedirectERR("必须扫描专属顾问的二维码");
        }
        else
        {
            if (clsWXHelper.CheckUserAuth(ConfigKeyValue, "openid"))        //20160330 薛灵敏改成使用 openid鉴权
            {
                //生成访问日志
                clsWXHelper.WriteLog(string.Format("openid：{0} ，vipid：{1} 。访问功能页[{2}]", Convert.ToString(Session["openid"]), Convert.ToString(Session["vipid"])
                                , "引导粉丝关注"));     
                
                string openid = Convert.ToString(Session["openid"]);
                string strInfo = "";
                DataTable dt;
                string connectstring = clsConfig.GetConfigValue("OAConnStr");
                string ConWX = clsWXHelper.GetWxConn(); 
                using (LiLanzDALForXLM dalWX = new LiLanzDALForXLM(ConWX))
                {
                    string strSql1 = @"DECLARE @bdm VARCHAR(10),
				                                        @ServiceLevel INT

                                        SELECT TOP 1 @bdm=B.dm FROM Rs_T_Rydwzl A INNER JOIN dm_t_xzjbb B ON A.zd = B.id 
                                        INNER JOIN wx_t_OmniChannelUser OCU ON OCU.RelateID = A.id 
                                        WHERE OCU.ID = @BindKey

                                        IF (ISNUMERIC(@bdm) = 1) SELECT @ServiceLevel = CONVERT(INT,@bdm) + 1
                                        ELSE SELECT @ServiceLevel = 2
                                        
                                        SELECT TOP 1 @ServiceLevel ServiceLevel,D.avatar,OCU.Nickname AS MyName FROM wx_t_AppAuthorized C 
                                        INNER JOIN wx_t_OmniChannelUser OCU ON OCU.ID = C.SystemKey AND OCU.ID = @BindKey 
                                        INNER JOIN wx_t_customers D ON D.ID = C.UserID AND C.SystemID = 3
                                         ";

                    List<SqlParameter> lstParams = new List<SqlParameter>();

                    lstParams.Clear();
                    lstParams.Add(new SqlParameter("@BindKey", BindKey));
                    strInfo = dalWX.ExecuteQuerySecurity(strSql1, lstParams, out dt);
                    if (strInfo == "")
                    {
                        if (dt.Rows.Count == 0) //表明之前没有导购，或导购信息不存在！
                        {
                            clsWXHelper.ShowError("导购信息不存在！");
                        }
                        else
                        {

                            string strName = Convert.ToString(dt.Rows[0]["MyName"]);
                            string strfaceURL = Convert.ToString(dt.Rows[0]["avatar"]);
                            int intServiceLevel = Convert.ToInt32(dt.Rows[0]["ServiceLevel"]);
                            //clsSharedHelper.WriteInfo(strfaceURL);
                            SetFaceImg(ref strfaceURL);

                            spanInfo.InnerHtml = strName;
                            string salesql = @"DECLARE @oldSid INT      SET @oldSid=0
                                                select TOP 1 @oldSid=SalerID from wx_t_VipSalerBind where openid=@openid
                                                
                                                if (@oldSid <> @sid)                                                    
                                                begin
                                                    IF (@oldSid <> 0)  DELETE FROM wx_t_VipSalerBind WHERE openid=@openid AND SalerID = @oldSid --删除原先的绑定关系

                                                    declare @NewVsbID int;
                                                    INSERT INTO wx_t_VipSalerBind (VipID,SalerID,CreateID,openid) 
                                                    VALUES (0,@sid,@sid,@openid) ;
                                                    set @NewVsbID = SCOPE_IDENTITY();  
                                                    INSERT INTO wx_t_VipSalerHistory(BindID,VipID,SalerID,OpenID,CreateID,BeginType) 
                                                    VALUES (@NewVsbID,0,@sid,@openid,@sid,0);

                                                    select TOP 1 C.name,F.wxNick from wx_t_AppAuthorized A
                                                    INNER JOIN wx_t_OmniChannelUser B ON A.SystemKey = B.ID AND A.SystemID = 3
                                                    INNER JOIN wx_t_customers C ON A.UserID = C.ID
                                                    inner join wx_t_VipSalerBind D on B.ID=D.SalerID
                                                    inner join wx_t_vipBinging F on D.OpenID=F.wxopenid
                                                    WHERE  D.OpenID=@openid
                                                end";
                            dt.Clear(); dt.Dispose();
                            lstParams.Clear();
                            lstParams.Add(new SqlParameter("@sid", BindKey));
                            lstParams.Add(new SqlParameter("@openid", openid));
                            string eScal2 = dalWX.ExecuteQuerySecurity(salesql, lstParams, out dt);

                            if (eScal2 == "")
                            {
                                if (dt.Rows.Count > 0)
                                {
                                    //SendInfoWX("xuelm", "恭喜您吸收了粉丝！"); 
                                    string sendName = Convert.ToString(dt.Rows[0]["name"]).Trim();  //去空格
                                    string wxNick = Convert.ToString(dt.Rows[0]["wxNick"]);
                                    SendInfoWX(sendName, string.Concat("恭喜您吸收了粉丝【", wxNick, "】！", GotoVIPListUrl));
                                    //clsSharedHelper.WriteInfo(string.Concat("已发送给：", sendName , "信息提醒。"));
                                }
                            }
                            //将数据添加进临时关联内存表之中 
                            FansSaleBind.BindFansSale(Convert.ToString(Session["openid"]), BindKey, strName, strfaceURL, intServiceLevel);
                        }
                        clsSharedHelper.DisponseDataTable(ref dt);
                    }
                    else
                    {

                        clsLocalLoger.WriteError(string.Format("读取扫描原导购的个人信息失败！错误：{0}", strInfo));
                        RedirectERR("读取扫描原导购的个人信息失败！");
                        return;
                    }

                    GC.Collect();   //回收资源  
                }
            }
        }
    }

    private void SetFaceImg(ref string strFace)
    {
        if (clsWXHelper.IsWxFaceImg(strFace))
        {
            strFace = clsWXHelper.GetMiniFace(strFace);
        }
        else
        {
            string oaUrl = clsConfig.GetConfigValue("OA_WebPath");

            strFace = string.Concat(oaUrl, strFace);
        }
    }

    private void RedirectERR(string info)
    {
        string url = string.Concat("../../WebBLL/Error.aspx?msg=", info);
        Response.Redirect(url);
    }
    public string SendInfoWX(string user, string content)
    {
        nrWebClass.MsgClient msgclient = new nrWebClass.MsgClient("192.168.35.63", 21000);
        System.Collections.Generic.Dictionary<string, string> items = new System.Collections.Generic.Dictionary<string, string>();
        items.Add("touser", user);
        items.Add("toparty", "");
        items.Add("totag", "");
        items.Add("msgtype", "text");
        items.Add("agentid", "26");
        items.Add("content", content);
        items.Add("safe", "0");
        return msgclient.EntMsgSend(items);
    }


</script>

<html xmlns="http://www.w3.org/1999/xhtml">

<head>
    <meta charset="utf-8" />
    <meta name="viewport" content="width=device-width,initial-scale=1,user-scalable=0,maximum-scale=1" />
    <meta name="format-detection" content="telephone=no" />
    <meta name="apple-mobile-web-app-capable" content="yes" />
    <meta name="apple-mobile-web-app-status-bar-style" content="black" />
    <title>长按识别二维码</title>
    <link rel="stylesheet" href="../../res/css/weui.min.css"/>
    <link rel="stylesheet" href="../../res/css/StoreSaler/weui_example.css"/>  
    <style> 
        .goto
        {
            color:Black;
            font-weight:900;
        }
        .red
        {
            color:red;  
            font-weight:700;          
        }
    </style>
</head>
<body ontouchstart>     
<form id="form1" runat="server">
   <input type="hidden" id="hiddenVsbID0" runat="server" value="0" />
   <input type="hidden" id="hiddenVipid" runat="server" value="0" />
   <input type="hidden" id="hiddenSid" runat="server" value="0" /> 

  <div class="container js_container">
    <div class="page">
        <div class="hd">
            <h1 class="page_title">关注利郎男装</h1>
        </div>
        <div class="bd spacing">
            <div class="weui_cells_title">您将要指定专属顾问：<span class="red" id="spanInfo" runat="server"></span></div>
            <div class="weui_cells weui_cells_form">
                <div class="weui_cell" style=" text-align:center;"> 
                    <img alt="" src="../../res/img/vipweixin/touch60001.jpg" />
                </div>
            </div> 
        </div> 
        <div class="weui_cells_title">请长按识别二维码，关注[利郎男装]。</div>
           
    </div> 
  </div>
      
    <script type='text/javascript' src='../../res/js/StoreSaler/fastclick.min.js'></script>
    <script type='text/javascript' src="../../res/js/zepto.min.js"></script>
    <script type='text/javascript' src="../../res/js/StoreSaler/weui_example.js"></script> 
    <script type="text/javascript">
     
    </script>
 </form>
</body>
</html>
