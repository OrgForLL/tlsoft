<%@ Page Language="C#" %>

<%@ Import Namespace="nrWebClass" %>
<%@ Import Namespace="System.Data.SqlClient" %>
<%@ Import Namespace="System.Data" %>
<%@ Import Namespace="System.Collections.Generic" %>
<!DOCTYPE html>
<script runat="server">
    private String ConfigKeyValue = ""; //利郎男装    
    private string WXDBConstr = "";

    //JS-SDK
    public List<string> wxConfig;       //微信OPEN_JS 动态生成的调用参数
    public string card_js_ticket = "";
    public string timestamp = "", noncestr = "", cardcode = "", openid = "", sign = "", orderStr = "", ticket = "";

    protected void Page_Load(object sender, EventArgs e)
    {
        try
        {
            WXDBConstr = clsConfig.GetConfigValue("WXConnStr");
        }
        catch (Exception ex)
        {
            WXDBConstr = System.Configuration.ConfigurationManager.ConnectionStrings["WXDBConnStr"].ConnectionString;
        }
        ConfigKeyValue = Convert.ToString(Request.Params["configkey"]);
        string cid = Convert.ToString(Request.Params["cardid"]);                
        string khid = Convert.ToString(Request.Params["khid"]);
        string mdid = Convert.ToString(Request.Params["mdid"]);
        string createrid = Convert.ToString(Request.Params["userid"]);
        if (ConfigKeyValue == "" || ConfigKeyValue == null)
            clsSharedHelper.WriteErrorInfo("缺少参数【configkey】！");
        else if (cid == "0" || cid == "" || cid == null)
            clsSharedHelper.WriteErrorInfo("缺少参数【cardid】！");
        else if (khid == "" || khid == "0" || khid == null)
            clsSharedHelper.WriteErrorInfo("缺少参数【khid】！");
        else if (mdid == "" || mdid == "0" || mdid == null)
            clsSharedHelper.WriteErrorInfo("缺少参数【mdid】！");
        else if (createrid == "" || createrid == "0" || createrid == null)
            clsSharedHelper.WriteErrorInfo("缺少参数【createrid】！");
        else {
            if (clsWXHelper.CheckUserAuth(ConfigKeyValue, "openid"))
            {
                openid = Convert.ToString(Session["openid"]);
                using (LiLanzDALForXLM dal = new LiLanzDALForXLM(WXDBConstr))
                {
                    string str_sql = @"select a.id,a.cardid,a.getlimit,isnull(b.id,0) distriid,b.quantity,isnull(b.stock,0) stock,
                                    isnull(c.usergets,0) usergets
                                    from wx_t_cardinfos a
                                    left join wx_t_CardDistribute b on a.id=b.cid and b.khid=@khid and b.mdid=@mdid
                                    left join (
                                        select count(id) usergets from wx_t_CardRelation 
                                        where openid=@openid and cardid=@cardid and khid=@khid and mdid=@mdid and isget=1) c on 1=1
                                    where a.isdel=0 and a.id=@cardid";
                    List<SqlParameter> paras = new List<SqlParameter>();
                    paras.Add(new SqlParameter("@khid", khid));
                    paras.Add(new SqlParameter("@mdid", mdid));
                    paras.Add(new SqlParameter("@cardid", cid));
                    paras.Add(new SqlParameter("@openid", openid));

                    DataTable dt;
                    string errinfo = dal.ExecuteQuerySecurity(str_sql, paras, out dt);
                    if (errinfo == "")
                    {
                        if (dt.Rows.Count > 0)
                        {
                            int disid = Convert.ToInt32(dt.Rows[0]["distriid"]);
                            if (disid > 0)
                            {
                                int stock = Convert.ToInt32(dt.Rows[0]["stock"]);
                                int getlimit = Convert.ToInt32(dt.Rows[0]["getlimit"]);
                                int usergets = Convert.ToInt32(dt.Rows[0]["usergets"]);
                                cardcode = Convert.ToString(dt.Rows[0]["cardid"]);
                                if (usergets >= getlimit)
                                    clsWXHelper.ShowError("对不起，该卡券每个用户仅限领取" + getlimit.ToString() + "张，您已经超过限制了无法再领取！");
                                else if (stock <= 0)
                                    clsWXHelper.ShowError("对不起，该卡券库存不足！");
                                else
                                {
                                    ticket = System.Guid.NewGuid().ToString();
                                    str_sql = @"insert wx_t_CardRelation(ticket,khid,mdid,cardid,cardcode,openid,createrid,isbind,
                                            bindtime,isget,gettime,givetype)
                                            values (@ticket,@khid,@mdid,@cardid,@cardcode,@openid,@createrid,1,getdate(),0,'','mass');
                                            update wx_t_CardDistribute set stock=stock-1 where cid=@cardid and khid=@khid and mdid=@mdid; ";
                                    paras.Clear();
                                    paras.Add(new SqlParameter("@ticket", ticket));
                                    paras.Add(new SqlParameter("@khid", khid));
                                    paras.Add(new SqlParameter("@mdid", mdid));
                                    paras.Add(new SqlParameter("@cardid", cid));
                                    paras.Add(new SqlParameter("@cardcode", cardcode));
                                    paras.Add(new SqlParameter("@openid", openid));
                                    paras.Add(new SqlParameter("@createrid", createrid));
                                    errinfo = dal.ExecuteNonQuerySecurity(str_sql, paras);
                                    if (errinfo != "")
                                        clsWXHelper.ShowError(errinfo);
                                    else
                                    {
                                        //调起JS-SDK接口
                                        wxConfig = clsWXHelper.GetJsApiConfig(ConfigKeyValue);
                                        card_js_ticket = clsWXHelper.GetWxcard_ticket(ConfigKeyValue);
                                        timestamp = ConvertDateTimeInt(DateTime.Now).ToString();
                                        noncestr = "0" + ticket.Replace("-", "");
                                        string[] ArrTmp = { card_js_ticket, timestamp, noncestr, cardcode, openid };
                                        Array.Sort(ArrTmp);
                                        sign = string.Join("", ArrTmp);
                                        orderStr = sign;
                                        sign = FormsAuthentication.HashPasswordForStoringInConfigFile(sign, "SHA1").ToLower();
                                    }
                                }
                            }
                            else
                                clsWXHelper.ShowError("对不起，找不到该门店关于此类卡券的分配信息！");
                        }
                        else
                            clsWXHelper.ShowError("对不起，请检查卡券的有效性！");
                    }
                    else
                        clsWXHelper.ShowError("[1]" + errinfo);
                }//end using
            }
            else
                clsSharedHelper.WriteErrorInfo("微信鉴权失败！");
        }               
    }

    private int ConvertDateTimeInt(System.DateTime time)
    {
        System.DateTime startTime = TimeZone.CurrentTimeZone.ToLocalTime(new System.DateTime(1970, 1, 1));
        return (int)(time - startTime).TotalSeconds;        
    }

    //依据CARDID或CARDCODE获取对应的公众号ID
    public string getConfigKey(string cardid, string cardcode)
    {
        string key = "";
        using (LiLanzDALForXLM dal = new LiLanzDALForXLM(WXDBConstr))
        {
            string str_sql = @"select top 1 a.configkey
                                from wx_t_cardinfos a
                                left join wx_t_cardcodes b on a.cardid=b.cardid
                                where a.cardid=@cardid or b.cardcode=@cardcode";
            List<SqlParameter> paras = new List<SqlParameter>();
            paras.Add(new SqlParameter("@cardid", cardid));
            paras.Add(new SqlParameter("@cardcode", cardcode));
            object scalar;
            string errinfo = dal.ExecuteQueryFastSecurity(str_sql, paras, out scalar);
            if (errinfo == "" && Convert.ToString(scalar) != "")
                key = Convert.ToString(scalar);
        }

        return key;
    }
</script>
<html lang="en" xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <meta charset="utf-8" />
    <meta name="viewport" content="width=device-width,initial-scale=1,user-scalable=0,maximum-scale=1" />
    <meta name="format-detection" content="telephone=no" />
    <meta name="apple-mobile-web-app-capable" content="yes" />
    <meta name="apple-mobile-web-app-status-bar-style" content="black" />
    <title>正在处理,请稍候...</title>
</head>
<body>
    <script type="text/javascript" src="http://res.wx.qq.com/open/js/jweixin-1.0.0.js"></script>
    <script type="text/javascript" src="../../res/js/jquery.js"></script>    
    <script type="text/javascript">
        var appIdVal = "<%=wxConfig[0]%>", timestampVal = "<%=wxConfig[1]%>", nonceStrVal = "<%=wxConfig[2]%>", signatureVal = "<%=wxConfig[3]%>";
        function jsConfig() {
            wx.config({
                debug: false,
                appId: appIdVal, // 必填，公众号的唯一标识
                timestamp: timestampVal, // 必填，生成签名的时间戳
                nonceStr: nonceStrVal, // 必填，生成签名的随机串
                signature: signatureVal, // 必填，签名，见附录1
                jsApiList: ['addCard'] // 必填，需要使用的JS接口列表，所有JS接口列表见附录2
            });

            wx.ready(function () {
                AddWXCard();//页面加载完成自动调取API直接进入微信的卡券界面
            });

            wx.error(function (res) {
                alert("JS注入失败！");
            });
        }

        $(function () {
            jsConfig();
        });

        function AddWXCard() {
            var obj = {};
            obj.openid = "<%=openid %>";
            obj.timestamp = "<%=timestamp %>";
            obj.nonce_str = "<%=noncestr %>";
            obj.signature = "<%=sign%>";
            var json = JSON.stringify(obj);
            wx.addCard({
                cardList: [{
                    cardId: "<%=cardcode%>",
                    cardExt: json
                }], // 需要添加的卡券列表
                success: function (res) {
                    //alert("用户领取卡券！");
                    $.ajax({
                        type: "POST",
                        timeout: 5000,
                        contentType: "application/x-www-form-urlencoded; charset=utf-8",
                        url: "WXCardCore.aspx",
                        data: { ctrl: "UserGetTicket", ticket: "<%=ticket%>" },
                        success: function (msg) {
                            if (msg.indexOf("Successed") > -1) {
                                alert("恭喜您领取成功,您可以在微信客户端【卡券】中查看。");
                                WeixinJSBridge.call('closeWindow');
                            }
                        },
                        error: function (XMLHttpRequest, textStatus, errorThrown) { }
                    });//end AJAX
                }
            });
        }
    </script>
</body>
</html>
