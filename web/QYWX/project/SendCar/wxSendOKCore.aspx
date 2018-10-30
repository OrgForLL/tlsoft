<%@ Page Language="C#" %>
<%@ Import Namespace="System.Data" %>
<%@ Import Namespace="System.Data.SqlClient" %>
<%@ Import Namespace="System.Collections.Generic" %>
<%@ Import Namespace="nrWebClass" %>
<%@ Import Namespace="Newtonsoft.Json" %>
<%@ Import Namespace="Newtonsoft.Json.Linq" %>
<!DOCTYPE html>
<script runat="server"> 

    private bool IsDebugMode = true;    //是否为调试模式
    
    private const string SendManagerName = "xuelm|chenyh|hyam"; //发送派车提醒的时候：额外发送给管理人员。取自wx_t_customers.name（一定要记得去空格）

    protected void Page_Load(object sender, EventArgs e)
    {
        string ctrl = Convert.ToString(Request.Params["ctrl"]);

        switch (ctrl)
        {
            case "SendOK":
                SendOK();
                break;
            default:
                break;
        }
    }

    private void SendOK()
    {
        string id = Convert.ToString(Request.Params["id"]);
        string DBcon = clsConfig.GetConfigValue("OAConnStr");
        using (LiLanzDALForXLM dal = new LiLanzDALForXLM(DBcon))
        {
            string strSQL = @"
            DECLARE @billCount INT,
                    @syr VARCHAR(50),                    
                    @sqr VARCHAR(50),                    
                    @name VARCHAR(50),
                    @djbs INT,
                    @hzbs INT, 
                    @kssj VARCHAR(20),
                    @yjjssj VARCHAR(20)

            SELECT @billCount = 0,@syr = '',@sqr = '',@name = '',@djbs = 0,@hzbs = 0,@kssj = '',@yjjssj = ''
            
            SELECT TOP 1 @syr = syr,@sqr = sqr,@djbs = djbs,@hzbs = hzbs,@kssj = kssj,@yjjssj = yjjssj FROM rs_t_pcydb WHERE id = @id
            
            IF (@djbs <> 1)     SELECT '该单据已经作废，不允许发回执！' info
            ELSE IF (@hzbs = 1)     SELECT '该单据已发过回执了，不允许重复发！' info
            ELSE
            BEGIN                        
                UPDATE rs_t_pcydb SET hzbs = 1 WHERE id = @id
                SELECT TOP 1 @name = [name] FROM wx_t_customers WHERE cname = @sqr
                SELECT TOP 1 '' info,@syr syr,@name myname,@kssj kssj,@yjjssj yjjssj          
            END
             ";

            List<SqlParameter> listSqlParameter = new List<SqlParameter>();
            listSqlParameter.Add(new SqlParameter("@id", id));
            DataTable dtRead;
            string strInfo = dal.ExecuteQuerySecurity(strSQL, listSqlParameter, out dtRead);
            if (strInfo == "")
            {
                DataRow dr = dtRead.Rows[0];
                string info = Convert.ToString(dr["info"]);

                if (info != "")
                {
                    dtRead.Clear(); dtRead.Dispose();
                    clsSharedHelper.WriteInfo(info);
                }
                else
                {
                    string myname = Convert.ToString(dr["myname"]).Trim();  //必须去空格  
                    string syr = Convert.ToString(dr["syr"]);
                    DateTime kssj = Convert.ToDateTime(dr["kssj"]);
                    DateTime yjjssj = Convert.ToDateTime(dr["yjjssj"]);

                    dtRead.Clear(); dtRead.Dispose();

                    if (myname == "" && IsDebugMode) myname = SendManagerName; // "chenyh"; //如果发送目标不存在，则强制指定为测试人：薛灵敏

                    if (myname != "")
                    {
                        StringBuilder sbInfo = new StringBuilder();
                        sbInfo.AppendFormat("客人【{0}】送达目的地，该派车单({1}-{2})已结束。", syr, kssj.ToString("M月d日 HH:mm"), yjjssj.ToString("HH:mm"));

                        info = SendInfoWX(myname, sbInfo.ToString());
                        if (info.ToLower() == "done") clsSharedHelper.WriteSuccessedInfo("");
                        else clsSharedHelper.WriteInfo(string.Concat("回执发送失败！错误：", info));
                    }
                    else
                    {
                        clsSharedHelper.WriteSuccessedInfo("派车人尚未关注利郎企业号！因此将不会接收到回执提醒！");
                    }
                }
            }
            else
            {
                clsSharedHelper.WriteInfo(string.Concat("错误：", strInfo));
            }
        }
    }


    public string SendInfoWX(string user, string content)
    {
        //nrWebClass.MsgClient msgclient = new nrWebClass.MsgClient("192.168.35.63", 21000);
        //System.Collections.Generic.Dictionary<string, string> items = new System.Collections.Generic.Dictionary<string, string>();
        //items.Add("touser", user);
        //items.Add("toparty", "");
        //items.Add("totag", "");
        //items.Add("msgtype", "text");
        //items.Add("agentid", "31");
        //items.Add("content", content);
        //items.Add("safe", "0");
        //return msgclient.EntMsgSend(items);
        
        using (clsJsonHelper jh = clsWXHelper.SendQYMessage(user, 31, content))
        {
            clsLocalLoger.WriteInfo(string.Concat("[派车提醒调试信息]", user, " 消息内容：",content , " 执行反馈：" , jh.jSon));
            if (jh.GetJsonValue("errcode") == "0" && jh.GetJsonValue("invaliduser") == "") return "done";
            else
            {
                if (SendManagerName != user)
                {
                    clsLocalLoger.WriteError(string.Concat("[派车提醒发送失败]", user, " 消息内容：", content, " 错误反馈：", jh.jSon));
                    using (clsJsonHelper jhMaster = clsWXHelper.SendQYMessage(SendManagerName, 31, string.Concat("(请注意：以下提醒未收到)\n", content)))
                    {
                        if (jhMaster.GetJsonValue("errcode") != "0") clsLocalLoger.WriteError(string.Concat("[派车提醒发送失败]提醒管理员【", SendManagerName, "】失败！", " 错误反馈：", jhMaster.jSon));
                    }
                }
                return jh.jSon.Replace("\"", "'");
            }
        }
    }



</script>
<html>
<head id="Head1" runat="server">
    <meta http-equiv="Content-Type" content="text/html; charset=utf-8" />
    <title></title>
</head>
<body>
    <form id="form1" runat="server">
    <div>
    </div>
    </form>
</body>
</html>
