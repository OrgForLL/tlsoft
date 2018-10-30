<%@ Page Language="C#" %>

<%@ Import Namespace="nrWebClass" %>
<%@ Import Namespace="Newtonsoft.Json.Linq" %>
<%@ Import Namespace="Newtonsoft.Json" %>
<%@ Import Namespace="System.Collections.Generic" %>
<%@ Import Namespace="System.Data.SqlClient" %>
<%@ Import Namespace="System.Data" %>
<%@ Import Namespace="WebBLL.Core" %>
<!DOCTYPE html>
<script runat="server">        
    ////2015-10-12 添加发送微信消息提醒的功能（企业号） By:liqf

    /// <summary>
    /// 20150714 该文件用于快递相关信息的查询 by liqf
    /// 传入参数：expressNo 快递单号 ctrl 功能选择参数
    /// ctrl=getCom 获得单号可能对应的快递公司代码如yunda
    /// </summary>
    
    protected void Page_Load(object sender, EventArgs e)
    {        
        String ctrl = Convert.ToString(Request.Params["ctrl"]);
        String rtMsg = "";
        if (ctrl == "" || ctrl == null)
        {
            rtMsg = @"{""type"":""error"",""msg"":""ctrl参数有误！""}";
        }
        else
        {
            switch (ctrl)
            {
                case "getCom":
                    String expressNo = Convert.ToString(Request.Params["expressNo"]);
                    if (expressNo == null || expressNo == "")
                        rtMsg = @"{""type"":""error"",""msg"":""快递单号参数有误！""}";
                    else
                        rtMsg = getCom(expressNo);
                    break;
                case "Decode":
                    string cardNo = Convert.ToString(Request.Params["cardNo"]);
                    if (cardNo == null || cardNo == "")
                        rtMsg = @"{""type"":""error"",""msg"":""卡号参数有误！""}";
                    else
                        rtMsg = newDecode(cardNo);
                    break;
                case "sendRTXSingle":
                    string id = Convert.ToString(Request.Params["id"]);
                    if (id == "" || id == null)
                        rtMsg = @"{""type"":""error"",""msg"":""请检查参数！""}";
                    else {                        
                        rtMsg = sendRTXmessage(id, "all");                        
                    }                        
                    break;
                case "sendNoticeMass":
                    string ids = Convert.ToString(Request.Params["ids"]);
                    string type = Convert.ToString(Request.Params["type"]);
                    if (ids == "" || ids == null || type == "" || type == null)
                        rtMsg = @"{""type"":""error"",""msg"":""请检查参数！""}";
                    else
                        rtMsg = sendRTXMass(ids,type);
                    break;                    
                default:
                    rtMsg = @"{""type"":""error"",""msg"":""无ctrl对应操作！""}";
                    break;
            }
        }

        clsSharedHelper.WriteInfo(rtMsg);
    }

    private string sendRTXMass(string receivers,string type) {
        string rtxResult = @"{{""type"":""{0}"",""msg"":""{1}""}}";       
        int sucNums = 0, errNums = 0;
        string[] RCS = receivers.Split(',');        
        if (RCS.Length > 0) {
            for (int i = 0; i < RCS.Length; i++) {
                if (RCS[i] == "0" || RCS[i] == "" || RCS[i] == null) continue;
                string errInfo = sendRTXmessage(RCS[i],type);
                if (errInfo.IndexOf("success") > -1)
                    sucNums++;
                else
                    errNums++;
            }
        }

        rtxResult = string.Format(rtxResult,"success","提交发送BQQ提醒请求，成功："+sucNums.ToString()+"个 失败："+errNums+"个。");
        return rtxResult;
    }
    
    //发送RTX消息提醒
    private string sendRTXmessage(string dataid,string type)
    {
        string rtxResult = @"{{""type"":""{0}"",""msg"":""{1}""}}";
        string title = "快递通知";
        string msg = "您好，您{3}有一份快递已到公司，信息如下：\n【快递单号】：{0}\n【快递公司】：{1}\n【经办人】：{2}\n请及时带上工作牌到前台或找相关负责人领取！\n" + DateTime.Now.ToString("yyyy年M月d日 HH:mm");
        string leaderMsg = "您好，您有一份快递已到公司，信息如下：\n【快递单号】：{0}\n【快递公司】：{1}\n【经办人】：{2}\n并且已经通知到您对应的文员【{3}】了！\n" + DateTime.Now.ToString("yyyy年M月d日 HH:mm");
        string errInfo = "";
        using (LiLanzDALForXLM dal = new LiLanzDALForXLM())
        {            
            string sql = @" 
                            select max(name) name,cname into #wxxx from wx_t_customer group by cname;
                            select a.sjr,a.kddh,kd.kdgs,a.jbr,isnull(rtx.rtxname,'') rtxname,isnull(wy.wyxm,'') wyxm,
                            isnull(sx.name,'') sjrwxname,isnull(ww.name,'') wywxname 
                            from t_kdlqdjb a left join t_kdgsdmb kd on a.kdgsdm=kd.dm 
                            left join t_rtxuser rtx on rtx.username=a.sjr 
                            left join t_ldwydyb wy on wy.ldxm=a.sjr
                            left join #wxxx sx on sx.cname=a.sjr
                            left join #wxxx ww on ww.cname=wy.wyxm
                            where a.id=@id;
                            drop table #wxxx;";
            
            DataTable dt = null;
            List<SqlParameter> para = new List<SqlParameter>();
            para.Add(new SqlParameter("@id", dataid));
            errInfo = dal.ExecuteQuerySecurity(sql, para, out dt);
            if (errInfo == "")
            {
                if (dt.Rows.Count > 0)
                {
                    string tmptxt = "", receiver2 = "";
                    //如果有对应的文员信息则会发给文员不再发给收件人本人20150806 by Liqf
                    //如果有对应的文员信息则本人和文员都要发送RTX提醒 20150911 by Liqf
                    string _receiver = dt.Rows[0]["wyxm"].ToString() == "" ? dt.Rows[0]["rtxname"].ToString() : dt.Rows[0]["wyxm"].ToString();
                    string _wxrecname = dt.Rows[0]["wyxm"].ToString() == "" ? dt.Rows[0]["sjrwxname"].ToString() : dt.Rows[0]["wywxname"].ToString();
                    if (dt.Rows[0]["wyxm"].ToString() != "")
                    {
                        tmptxt = "的领导【" + dt.Rows[0]["sjr"].ToString() + "】";
                        receiver2 = clsNetExecute.GetEncodeValue(dt.Rows[0]["rtxname"].ToString(), System.Text.Encoding.GetEncoding("GB2312"));
                        leaderMsg = string.Format(leaderMsg, dt.Rows[0]["kddh"].ToString(), dt.Rows[0]["kdgs"].ToString(), dt.Rows[0]["jbr"].ToString(), dt.Rows[0]["wyxm"].ToString());
                    }
                    msg = string.Format(msg, dt.Rows[0]["kddh"].ToString(), dt.Rows[0]["kdgs"].ToString(), dt.Rows[0]["jbr"].ToString(), tmptxt);
                    string receiver = clsNetExecute.GetEncodeValue(_receiver, System.Text.Encoding.GetEncoding("GB2312"));
                    title = clsNetExecute.GetEncodeValue(title, System.Text.Encoding.GetEncoding("GB2312"));
                    //采用下面此句编码会造成微信发出的信息是encode之后的代码
                    //msg = clsNetExecute.GetEncodeValue(msg, System.Text.Encoding.GetEncoding("GB2312"));
                    //20150922 liqf当关联不到用户的RTX信息时直接尝试将消息发给收件人，避免数据不同步的情况
                    if (receiver == "") {
                        receiver = dt.Rows[0]["sjr"].ToString();                                     
                    }
                    
                    if (receiver != "")
                    {
                        using (RTXHelper rtxHelper = new RTXHelper())
                        {                            
                            if (type == "rtx") {
                                errInfo = rtxHelper.SendRTXMSG(receiver, title, msg);
                            }
                            else if (type == "wx")
                            {
                                MsgClient msgclient = new nrWebClass.MsgClient("192.168.35.63", 21000);                          
                                msgclient.ExpressMsgSend(_wxrecname, msg);                              
                            }
                            else if (type == "all")
                            {
                                errInfo = rtxHelper.SendRTXMSG(receiver, title, msg);
                                MsgClient msgclient = new nrWebClass.MsgClient("192.168.35.63", 21000);
                                msgclient.ExpressMsgSend(_wxrecname, msg);
                            }                                                          
                            
                            //有维护对应文员信息的再发一次给本人
                            if (receiver2 != "")
                            {                                
                                if (type == "rtx")
                                {
                                    errInfo = rtxHelper.SendRTXMSG(receiver2, title, leaderMsg);
                                }
                                else if (type == "wx")
                                {
                                    MsgClient msgclient = new nrWebClass.MsgClient("192.168.35.63", 21000);
                                    msgclient.ExpressMsgSend(dt.Rows[0]["sjrwxname"].ToString(), leaderMsg);
                                }
                                else if (type == "all")
                                {
                                    errInfo = rtxHelper.SendRTXMSG(receiver2, title, leaderMsg);
                                    MsgClient msgclient = new nrWebClass.MsgClient("192.168.35.63", 21000);
                                    msgclient.ExpressMsgSend(dt.Rows[0]["sjrwxname"].ToString(), leaderMsg);
                                }
                            }

                            if (errInfo.IndexOf("操作成功") > -1)
                            {
                                try
                                {
                                    sql = " update t_kdlqdjb set rtxno=rtxno+1 where id=@id;";
                                    para.Clear();
                                    para.Add(new SqlParameter("@id", dataid));
                                    dal.ExecuteNonQuerySecurity(sql, para);
                                }
                                catch { }
                                rtxResult = string.Format(rtxResult, "success", "提交发送BQQ提醒请求成功！");
                            }
                            else
                                rtxResult = string.Format(rtxResult, "error", "提交发送BQQ提醒请求失败！");
                        }
                    }
                    else rtxResult = string.Format(rtxResult, "error", "查找不到RTX账号信息！");
                }
                else {                    
                    rtxResult = string.Format(rtxResult, "error", "发送BQQ提醒失败:查询不到相关记录！");
                }                    
            }
            else
                rtxResult = string.Format(rtxResult, "error", "发送BQQ提醒失败:" + errInfo);
        }

        return rtxResult;
    }

    //解密卡内码函数
    private string newDecode(string CardID)
    {
        try
        {
            if (CardID.Length != 10)
                return @"{""type"":""error"",""msg"":""读取的卡号有误,请重试！""}";
            else
            {
                string Base16 = Convert.ToString(Convert.ToInt64(CardID), 16);
                string subBase16 = Base16.Substring(Base16.Length - 6);
                string cardSnr = Convert.ToString(Convert.ToInt64(subBase16, 16));
                return string.Format(@"{{""type"":""success"",""msg"":""{0}""}}", cardSnr);
            }
        }
        catch (Exception ex)
        {
            return string.Format(@"{{""type"":""error"",""msg"":""解密卡号中捕获异常:{0}""}}", ex.Message);
        }
    }

    public string getCom(String expressNo)
    {
        String rtMsg = @"{{""type"":""success"",""msg"":""{0}""}}";
        String URL = String.Format("http://www.kuaidi100.com/autonumber/autoComNum?text={0}", expressNo);

        String content = clsNetExecute.HttpRequest(URL);
        clsJsonHelper jh = clsJsonHelper.CreateJsonHelper(content);
        List<clsJsonHelper> comList = jh.GetJsonNodes("auto");
        try
        {
            if (comList.Count > 0)
            {
                rtMsg = String.Format(rtMsg, comList[0].GetJsonValue("comCode"));
            }
            else
            {
                rtMsg = String.Format(rtMsg, "");
            }
        }
        catch
        {
            rtMsg = String.Format(rtMsg, "");
        }

        return rtMsg;
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
