<%@ Page Language="C#" %>
<%@ Import Namespace="nrWebClass" %>
<%@ Import Namespace="System.Data" %>
<%@ Import Namespace="System.Data.SqlClient" %>
<%@ Import Namespace="System.Collections.Generic" %>
<!DOCTYPE html>
<script runat="server">
    private String ConfigKeyValue = "5"; //利郎男装
    private string ChatProConnStr = System.Configuration.ConfigurationManager.ConnectionStrings["Conn_4"].ConnectionString;
    private string DBConStr = "server='192.168.35.10';uid=ABEASD14AD;pwd=+AuDkDew;database=tlsoft"; 
    //private string ChatProConnStr = "server='192.168.35.23';uid=lllogin;pwd=rw1894tla;database=tlsoft";

    public string dgid = "";
    public Hashtable DG = new Hashtable();
    private string BindKey = "0";
    private string QR_Path = "";
    private string testUrl = "";  
    protected void Page_Load(object sender, EventArgs e)
    {        
        QR_Path = clsConfig.GetConfigValue("OA_WebPath");
        string myUrl = Request.Url.AbsoluteUri;
        if (myUrl.ToLower().Contains("tm.lilanz.com/qywx/"))    //如果这个路径是测试系统，则输出附加QYWX，使扫描结果指向231；否则不附加QYWX，扫描结果直接到15下的VIP
        {
            testUrl = "%2fQYWX";
        }
        
        //默认值
        AddHT(DG, "nickname", "--");        
        AddHT(DG, "gwmc", "--");
        AddHT(DG, "fwmc", "--");
        AddHT(DG, "service", "--");
        AddHT(DG, "ssmd", "--");
        AddHT(DG, "headimg", "img/defaulticon.png");
        if (clsWXHelper.CheckUserAuth(ConfigKeyValue, "openid"))
        {            
            using (LiLanzDALForXLM dal = new LiLanzDALForXLM(ChatProConnStr))
            {
                string str_sql = @"declare @uid int;declare @vipid int;declare @bindid int;
                                    select @uid=id,@vipid=vipid from wx_t_vipbinging where wxopenid=@openid;
                                    if isnull(@uid,0)=0
                                    select '00'
                                    else if isnull(@vipid,0)=0
                                    select '01'
                                    else
                                    begin
                                    select @bindid=id from wx_t_vipsalerbind where vipid=@vipid;
                                    if isnull(@bindid,0)=0
                                    select '02'
                                    else
                                    select '11' dm,(select count(id) from wx_t_vipsalerbind where salerid=dg.salerid) serviceCount,
                                    o.nickname,wc.avatar,wc.weixinid,gw.mc gwmc,f.mc fwmc,@bindid dgid,rs2.tzid mdid,o.id bindkey
                                    from wx_t_vipsalerbind dg
                                    inner join wx_t_OmnichannelUser o on o.id=dg.salerid
                                    inner join wx_t_AppAuthorized app on app.systemkey=o.id and app.systemid=3
                                    inner join wx_t_customers wc on wc.id=app.userid
                                    inner join rs_t_rydwzl rs2 on rs2.id=o.relateid and rs2.rzzk='1'                                    
                                    left join rs_t_gwdmb gw on gw.id=o.positionid
                                    left join dm_t_xzjbb f on o.GradePositions=f.id
                                    where dg.id=@bindid
                                    end";
                List<SqlParameter> paras = new List<SqlParameter>();
                paras.Add(new SqlParameter("@openid", Session["openid"].ToString()));
                DataTable dt = null;
                string errinfo = dal.ExecuteQuerySecurity(str_sql, paras, out dt);
                if (errinfo == "" && dt.Rows.Count>0)
                {
                    string dm = dt.Rows[0][0].ToString();
                    if (dm == "00")
                        clsWXHelper.ShowError("对不起，您还未关注利郎男装公众号。");
                    else if (dm == "01")
                        clsWXHelper.ShowError("对不起，您还不是利郎会员！");
                    else if (dm == "02")
                        dgid = "";
                    else if (dm == "11") { 
                        BindKey=dt.Rows[0]["bindkey"].ToString();
                        dgid=dt.Rows[0]["dgid"].ToString();
                        AddHT(DG, "nickname", dt.Rows[0]["nickname"].ToString());                        
                        AddHT(DG, "gwmc", dt.Rows[0]["gwmc"].ToString());
                        AddHT(DG, "fwmc", dt.Rows[0]["fwmc"].ToString());
                        AddHT(DG, "service", dt.Rows[0]["servicecount"].ToString());
                        AddHT(DG, "ssmd", getMdmc(dt.Rows[0]["mdid"].ToString()));
                        string headimg = dt.Rows[0]["avatar"].ToString();
                        if (clsWXHelper.IsWxFaceImg(headimg))
                            headimg = clsWXHelper.GetMiniFace(headimg);
                        else
                            headimg = clsConfig.GetConfigValue("OA_WebPath") + headimg;
                        AddHT(DG, "headimg", headimg);                        
                    }
                }
                else
                    clsWXHelper.ShowError("查询导购信息时出错！ " + errinfo);
            }
        }
        else
            clsWXHelper.ShowError("微信鉴权失败！");
    }

    public void AddHT(Hashtable ht, string key, string value)
    {
        if (ht.ContainsKey(key))
            ht.Remove(key);
        ht.Add(key, value);
    }

    public string getMdmc(string mdid) {
        string rt = "";
        using (LiLanzDALForXLM dal = new LiLanzDALForXLM(DBConStr)) {
            string str_sql = string.Format("select top 1 mdmc from t_mdb where mdid={0};", mdid);
            DataTable dt = null;
            string errinfo = dal.ExecuteQuery(str_sql,out dt);
            if (errinfo == "" && dt.Rows.Count > 0) {
                rt = dt.Rows[0][0].ToString();
            }
        }

        return rt;
    }
</script>
<html>
<head>
    <meta charset="utf-8" />
    <meta name="viewport" content="width=device-width,initial-scale=1,user-scalable=0,maximum-scale=1" />
    <meta name="format-detection" content="telephone=no" />
    <meta name="apple-mobile-web-app-capable" content="yes" />
    <meta name="apple-mobile-web-app-status-bar-style" content="black" />
    <title>我的专属导购</title>
    <link type="text/css" rel="stylesheet" href="../../res/css/LeePageSlider.css" />
    <link type="text/css" rel="stylesheet" href="../../res/css/font-awesome.min.css" />
    <style type="text/css">
        body {
            color: #323232;
        }

        .fa-angle-left {
            position: absolute;
            top: 15px;
            left: 3%;
            font-size: 2em;
            color: #fff;
            z-index: 1001;
            background-color: rgba(0,0,0,0.5);
            width: 40px;
            height: 40px;
            border-radius: 5px;
            text-align: center;
            line-height: 40px;
        }

            .fa-angle-left:hover {
                background-color: #ebebeb;
                color: #333;
            }

        .page {
            background-color: #f9f9f9;
            padding: 0;
            background-color: #272b2e;
            padding-bottom: 40px;
        }

        .infocard {
            width: 96%;
            margin: 0 auto;
            background-color: #fff;
            border-radius: 7px;
            margin-top: 80px;
            position: relative;
            padding: 50px 10px 10px 10px;
            display:none;
        }

        .headimg {
            width: 80px;
            height: 80px;
            border-radius: 50%;
            overflow: hidden;
            position: absolute;
            top: -40px;
            left: 50%;
            margin-left: -40px;
            border: 3px solid #ebebeb;
            box-shadow: 0 6px 20px 0 rgba(0,0,0,.1),0 8px 12px 0 rgba(0,0,0,.1);
            background-color: #fff;
            background-size: cover;
            background-position: 50% 50%;
            background-repeat: no-repeat;
        }

        .guidername {
            text-align: center;
            font-size: 1.5em;
            font-weight: bold;
            border-bottom: 1px dashed #e1e1e1;
            letter-spacing: 1px;
            padding-bottom: 4px;
        }

        .item {
            display: -webkit-box;
            display: -webkit-flex;
            display: flex;
            -webkit-box-align: center;
            padding: 7px;
            font-size: 1.1em;
            border-bottom: 1px solid #eee;
        }

            .item > div {
                text-align: right;
                -webkit-flex: 1;
                -webkit-box-flex: 1;
                flex: 1;
                color: #808080;
                white-space: nowrap;
                overflow: hidden;
                text-overflow: ellipsis;
            }

        .qrcon {
            text-align: center;
        }

            .qrcon img {
                width: 200px;
                height: 200px;
                margin-top: 15px;
                border: 1px solid #eee;
            }

            .qrcon p {
                width: 240px;
                padding: 5px;
                background-color: #272B2E;
                color: #fff;
                border-radius: 5px;
                margin: 0 auto;
                font-size: 1.1em;
                margin-top: 5px;
            }

        /*animation*/
        .animated {
            -webkit-animation-duration: 1s;
            animation-duration: 1s;
            -webkit-animation-fill-mode: both;
            animation-fill-mode: both;
        }

        @-webkit-keyframes flip {
            0% {
                -webkit-transform: perspective(400px) rotate3d(0,1,0,-360deg);
                transform: perspective(400px) rotate3d(0,1,0,-360deg);
                -webkit-animation-timing-function: ease-out;
                animation-timing-function: ease-out;
            }

            40% {
                -webkit-transform: perspective(400px) translate3d(0,0,150px) rotate3d(0,1,0,-190deg);
                transform: perspective(400px) translate3d(0,0,150px) rotate3d(0,1,0,-190deg);
                -webkit-animation-timing-function: ease-out;
                animation-timing-function: ease-out;
            }

            50% {
                -webkit-transform: perspective(400px) translate3d(0,0,150px) rotate3d(0,1,0,-170deg);
                transform: perspective(400px) translate3d(0,0,150px) rotate3d(0,1,0,-170deg);
                -webkit-animation-timing-function: ease-in;
                animation-timing-function: ease-in;
            }

            80% {
                -webkit-transform: perspective(400px) scale3d(.95,.95,.95);
                transform: perspective(400px) scale3d(.95,.95,.95);
                -webkit-animation-timing-function: ease-in;
                animation-timing-function: ease-in;
            }

            100% {
                -webkit-transform: perspective(400px);
                transform: perspective(400px);
                -webkit-animation-timing-function: ease-in;
                animation-timing-function: ease-in;
            }
        }

        @keyframes flip {
            0% {
                -webkit-transform: perspective(400px) rotate3d(0,1,0,-360deg);
                -ms-transform: perspective(400px) rotate3d(0,1,0,-360deg);
                transform: perspective(400px) rotate3d(0,1,0,-360deg);
                -webkit-animation-timing-function: ease-out;
                animation-timing-function: ease-out;
            }

            40% {
                -webkit-transform: perspective(400px) translate3d(0,0,150px) rotate3d(0,1,0,-190deg);
                -ms-transform: perspective(400px) translate3d(0,0,150px) rotate3d(0,1,0,-190deg);
                transform: perspective(400px) translate3d(0,0,150px) rotate3d(0,1,0,-190deg);
                -webkit-animation-timing-function: ease-out;
                animation-timing-function: ease-out;
            }

            50% {
                -webkit-transform: perspective(400px) translate3d(0,0,150px) rotate3d(0,1,0,-170deg);
                -ms-transform: perspective(400px) translate3d(0,0,150px) rotate3d(0,1,0,-170deg);
                transform: perspective(400px) translate3d(0,0,150px) rotate3d(0,1,0,-170deg);
                -webkit-animation-timing-function: ease-in;
                animation-timing-function: ease-in;
            }

            80% {
                -webkit-transform: perspective(400px) scale3d(.95,.95,.95);
                -ms-transform: perspective(400px) scale3d(.95,.95,.95);
                transform: perspective(400px) scale3d(.95,.95,.95);
                -webkit-animation-timing-function: ease-in;
                animation-timing-function: ease-in;
            }

            100% {
                -webkit-transform: perspective(400px);
                -ms-transform: perspective(400px);
                transform: perspective(400px);
                -webkit-animation-timing-function: ease-in;
                animation-timing-function: ease-in;
            }
        }

        .animated.flip {
            -webkit-backface-visibility: visible;
            -ms-backface-visibility: visible;
            backface-visibility: visible;
            -webkit-animation-name: flip;
            animation-name: flip;
        }
        .hint {
            color:#ebebeb;
            font-size:1.1em;
            white-space:nowrap;
            display:none;
        }
    </style>
</head>
<body>

    <div class="wrap-page">
        <i class="fa fa-angle-left" onclick="javascript:window.location.href='usercenter.aspx';"></i>
        <div class="page">
            <div class="infocard">
                <div class="headimg animated">
                    
                </div>
                <p class="guidername"><%=DG["nickname"].ToString() %></p>
                <div class="item">
                    <label>岗位</label>
                    <div><%=DG["gwmc"].ToString() %></div>
                </div>
                <div class="item">
                    <label>服务等级</label>
                    <div><%=DG["fwmc"].ToString() %></div>
                </div>
                <div class="item">
                    <label>服务人数</label>
                    <div><%=DG["service"].ToString() %></div>
                </div>
                <div class="item">
                    <label>所属门店</label>
                    <div><%=DG["ssmd"].ToString() %></div>
                </div>
                <div class="qrcon">
                    <img src="<%=QR_Path%>project/storesaler/GetQrCode.aspx?code=http%3a%2f%2ftm.lilanz.com<%= testUrl %>%2fproject%2fvipweixin%2fVSB.aspx%3fsid%3d<%= BindKey  %>" alt="" />
                    <p>赶快将TA让你的好友扫一扫吧...</p>
                </div>
            </div>
            <div class="hint center-translate">Sorry,您暂时还没有专属导购!</div>
        </div>
    </div>
    <script type="text/javascript" src="../../res/js/jquery.js"></script>
    <script type="text/javascript" src="../../res/js/StoreSaler/fastclick.min.js"></script>
    <script type="text/javascript">
        var dgid = "<%=dgid%>";
        $(function () {
            $(".headimg").css("background-image", "url(<%=DG["headimg"].ToString() %>)");
            FastClick.attach(document.body);
            if (dgid == "" || dgid == "0" || dgid == undefined) {
                $(".hint").show();
            } else {
                $(".infocard").show();
                $(".headimg.animated").addClass("flip");
            }            
        });
    </script>
</body>
</html>

