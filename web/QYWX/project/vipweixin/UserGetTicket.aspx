<%@ Page Language="C#" %>

<%@ Import Namespace="nrWebClass" %>
<%@ Import Namespace="System.Data.SqlClient" %>
<%@ Import Namespace="System.Data" %>
<%@ Import Namespace="System.Collections.Generic" %>
<!DOCTYPE html>
<script runat="server">
    private String WXDBConstr = "", ConfigKeyValue = ""; //利郎男装5 轻商务7    

    //JS-SDK
    public List<string> wxConfig;       //微信OPEN_JS 动态生成的调用参数
    public string card_js_ticket = "";
    public string timestamp = "", noncestr = "", cardid = "", openid = "", sign = "", orderStr = "", ticket = "";

    protected void Page_Load(object sender, EventArgs e)
    {
        if (clsConfig.Contains("WXConnStr"))
            WXDBConstr = clsConfig.GetConfigValue("WXConnStr");
        else
            WXDBConstr = System.Configuration.ConfigurationManager.ConnectionStrings["WXDBConnStr"].ConnectionString;

        string _key = Convert.ToString(Request.Params["configkey"]);
        if (string.IsNullOrEmpty(_key) || _key == "0")
        {
            clsWXHelper.ShowError("请检查参数configkey！");
            return;
        }
        else
            ConfigKeyValue = _key;

        ticket = Convert.ToString(Request.Params["ticket"]);

        if (clsWXHelper.CheckUserAuth(ConfigKeyValue, "openid"))
        {
            openid = Convert.ToString(Session["openid"]);
            using (LiLanzDALForXLM dal = new LiLanzDALForXLM(WXDBConstr))
            {
                string str_sql = @"select top 1 a.khid,a.mdid,a.openid,a.isbind,isnull(b.id,0) cid,isnull(b.cardid,'') cardid,a.isget,
                                    isnull(c.stock,0) stock,isnull(b.getlimit,0) getlimit
                                    from wx_t_CardRelation a                                    
                                    left join wx_t_cardinfos b on a.cardcode=b.cardid and b.isdel=0                                    
                                    left join wx_t_CardDistribute c on a.cardcode=c.cardid and a.khid=c.khid and a.mdid=c.mdid
                                    where a.ticket=@ticket";
                DataTable dt = null;
                List<SqlParameter> paras = new List<SqlParameter>();
                paras.Add(new SqlParameter("@ticket", ticket));
                string errinfo = dal.ExecuteQuerySecurity(str_sql, paras, out dt);
                if (errinfo == "")
                {
                    if (dt.Rows.Count == 0)
                        clsWXHelper.ShowError("对不起，领取凭证无效！");
                    else
                    {
                        string khid = Convert.ToString(dt.Rows[0]["khid"]);
                        string mdid = Convert.ToString(dt.Rows[0]["mdid"]);
                        string dopenid = Convert.ToString(dt.Rows[0]["openid"]);
                        string isbind = Convert.ToString(dt.Rows[0]["isbind"]);
                        string cid = Convert.ToString(dt.Rows[0]["cid"]);
                        string isget = Convert.ToString(dt.Rows[0]["isget"]);
                        int stock = Convert.ToInt32(dt.Rows[0]["stock"]);
                        int getlimit = Convert.ToInt32(dt.Rows[0]["getlimit"]);
                        cardid = Convert.ToString(dt.Rows[0]["cardid"]);
                        if (cid == "0")
                            clsWXHelper.ShowError("对不起，该卡券已停用！");
                        else if (isget == "True")
                            //已经领取了
                            clsWXHelper.ShowError("对不起，该卡券已被领取!" + ticket);
                        else
                        {
                            //还未领取                            
                            if (stock <= 0)
                                clsWXHelper.ShowError("对不起，该卡券已领完！");
                            else if (isbind == "True")
                            {
                                //未领取已绑定
                                if (dopenid != "" && openid != "" && dopenid == openid)
                                {
                                    //直接调取JS-SDK
                                    wxConfig = clsWXHelper.GetJsApiConfig(ConfigKeyValue);
                                    card_js_ticket = clsWXHelper.GetWxcard_ticket(ConfigKeyValue);
                                    timestamp = ConvertDateTimeInt(DateTime.Now).ToString();
                                    noncestr = "0" + ticket.Replace("-", "");
                                    string[] ArrTmp = { card_js_ticket, timestamp, noncestr, cardid, openid };
                                    Array.Sort(ArrTmp);
                                    sign = string.Join("", ArrTmp);
                                    orderStr = sign;
                                    sign = FormsAuthentication.HashPasswordForStoringInConfigFile(sign, "SHA1").ToLower();
                                }
                                else
                                    clsWXHelper.ShowError("对不起，该卡券已被领取!!");
                            }
                            else
                            {
                                //未领取未绑定
                                //在成功绑定了用户身份后库存必须减1
                                str_sql = @"declare @cardid varchar(50);declare @khid int;declare @mdid int;
                                            select top 1 @cardid=cardcode,@khid=khid,@mdid=mdid from wx_t_CardRelation where ticket=@ticket;
                                            if exists (select id from wx_t_CardRelation 
                                                       where isget=1 and openid=@openid and khid=@khid and mdid=@mdid 
                                                        and cardcode=@cardid having count(id)>=@getlimit)
                                              select '00';
                                            else
                                              begin
                                                update wx_t_CardRelation set bindtime=getdate(),isbind=1,openid=@openid where ticket=@ticket;
                                                update wx_t_CardDistribute set stock=stock-1 where cardid=@cardid and khid=@khid and mdid=@mdid;
                                                select '11'
                                              end";
                                paras.Clear();
                                paras.Add(new SqlParameter("@ticket", ticket));
                                paras.Add(new SqlParameter("@openid", openid));
                                paras.Add(new SqlParameter("@getlimit", getlimit));
                                object scalar;
                                errinfo = dal.ExecuteQueryFastSecurity(str_sql, paras, out scalar);
                                if (errinfo == "")
                                {
                                    if (Convert.ToString(scalar) == "11")
                                    {
                                        wxConfig = clsWXHelper.GetJsApiConfig(ConfigKeyValue);
                                        card_js_ticket = clsWXHelper.GetWxcard_ticket(ConfigKeyValue);
                                        timestamp = ConvertDateTimeInt(DateTime.Now).ToString();
                                        noncestr = "0" + ticket.Replace("-", "");
                                        string[] ArrTmp = { card_js_ticket, timestamp, noncestr, cardid, openid };
                                        Array.Sort(ArrTmp);
                                        sign = string.Join("", ArrTmp);
                                        orderStr = sign;
                                        sign = FormsAuthentication.HashPasswordForStoringInConfigFile(sign, "SHA1").ToLower();
                                    }
                                    else
                                        clsWXHelper.ShowError("对不起，该卡券每个用户仅限领取" + getlimit.ToString() + "张，您已经领取过了!");
                                }//end 生成相关签名参数
                                else
                                    clsSharedHelper.WriteErrorInfo(errinfo);
                            }//判断通过，绑定该用户信息
                        }
                    }
                }
                else
                    clsSharedHelper.WriteErrorInfo(errinfo);
            }//end using            
        }
    }

    private int ConvertDateTimeInt(System.DateTime time)
    {
        System.DateTime startTime = TimeZone.CurrentTimeZone.ToLocalTime(new System.DateTime(1970, 1, 1));
        return (int)(time - startTime).TotalSeconds;
    }

    //写日志
    private void WriteLog(string strText)
    {
        String path = HttpContext.Current.Server.MapPath("logs/");
        if (!System.IO.Directory.Exists(System.IO.Path.GetDirectoryName(path)))
        {
            System.IO.Directory.CreateDirectory(path);
        }

        System.IO.StreamWriter writer = new System.IO.StreamWriter(path + DateTime.Now.ToString("yyyyMMdd") + ".log", true);
        string str;
        str = "【" + DateTime.Now.ToString() + "】" + "  " + strText;
        writer.WriteLine(str);
        writer.Close();
    }
</script>

<html>
<head>
    <meta charset="utf-8" />
    <meta name="viewport" content="width=device-width,initial-scale=1,user-scalable=0,maximum-scale=1" />
    <meta name="format-detection" content="telephone=no" />
    <meta name="apple-mobile-web-app-capable" content="yes" />
    <meta name="apple-mobile-web-app-status-bar-style" content="black" />
    <title>正在处理,请稍候...</title>
</head>
<body>
    <script type="text/javascript" src="http://res.wx.qq.com/open/js/jweixin-1.0.0.js"></script>
    <script type="text/javascript" src="http://tm.lilanz.com/oa/res/js/jquery.js"></script>    
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
            LeeJSUtils.LoadMaskInit();
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
                    cardId: "<%=cardid%>",
                    cardExt: json
                }], // 需要添加的卡券列表
                success: function (res) {
                    //$.ajax({
                    //    type: "POST",
                    //    timeout: 5000,
                    //    url: "WXCardCore.aspx",
                    //    data: { ctrl: "UserGetTicket", ticket: "" },
                    //    success: function (msg) {
                    //        //在苹果微信新内核中如果此时用ALERT会导致微信闪退，旧内核不会
                    //        //alert("领取成功！请在微信-【我】-【卡包】-【我的票券】中查看");
                    //        //尝试跳转进入公众号关注页                            
                    //        //window.location.href = "http://tm.lilanz.com/project/vipweixin/followus.html?configkey=" + getQueryString("configkey");
                    //        //WeixinJSBridge.call('closeWindow');
                    //    },
                    //    error: function (XMLHttpRequest, textStatus, errorThrown) { }
                    //});
                    //console.log(JSON.stringify(res));
                    window.location.href = "http://tm.lilanz.com/project/vipweixin/followus.html?configkey=" + getQueryString("configkey");
                }//end success
            });
        }

        function getQueryString(name) {
            var reg = new RegExp("(^|&)" + name + "=([^&]*)(&|$)", "i");
            var r = window.location.search.substr(1).match(reg);
            if (r != null) return unescape(r[2]); return null;
        }
    </script>
</body>
</html>
