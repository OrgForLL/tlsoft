<%@ Page Language="C#" %>
<%@ Import Namespace="nrWebClass" %>
<%@ Import Namespace="System.Data" %>
<%@ Import Namespace="System.Data.SqlClient" %>
<%@ Import Namespace="System.Collections.Generic" %>
<!DOCTYPE html>
<script runat="server">
    private String ConfigKeyValue = clsConfig.GetConfigValue("CurrentConfigKey"); //取配置BLL.config
    private string ChatProConnStr = System.Configuration.ConfigurationManager.ConnectionStrings["Conn_4"].ConnectionString;
    private string DBConStr = "server='192.168.35.10';uid=ABEASD14AD;pwd=+AuDkDew;database=tlsoft"; 
    //private string ChatProConnStr = "server='192.168.35.23';uid=lllogin;pwd=rw1894tla;database=tlsoft";

    public string dgid = "";
    public Hashtable DG = new Hashtable();
    private string BindKey = "0";
    private string QR_Path = "";
    private string testUrl = "";
    public List<string> wxConfig = null;    
    protected void Page_Load(object sender, EventArgs e)
    {
        //Session["vipid"] = "3056806";    
        wxConfig = clsWXHelper.GetJsApiConfig(ConfigKeyValue);     
        
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
        AddHT(DG, "ShareText", "赶快将Ta分享给你的好友吧...");
        AddHT(DG, "ssmd", "--");
        AddHT(DG, "ssmddh", "--");
        if (clsWXHelper.CheckUserAuth(ConfigKeyValue, "openid"))
        {
            //生成访问日志
            clsWXHelper.WriteLog(string.Format("openid：{0} ，vipid：{1} 。访问功能页[{2}]", Convert.ToString(Session["openid"]), Convert.ToString(Session["vipid"])
                            , "我的专属"));     
                
            using (LiLanzDALForXLM dal = new LiLanzDALForXLM(ChatProConnStr))
            {
                string vipid = Convert.ToString(Request.Params["uid"]);

                if (vipid == "" || vipid == "0")
                {
                    clsWXHelper.ShowError("非法访问！");
                    return;
                }
                
                if (vipid != Convert.ToString(Session["vipid"])) AddHT(DG, "ShareText", "长按识别二维码<br>将Ta也指定为我的专属导购...");        //分享提示                                 
                                
                string str_sql = @"declare @uid int;declare @bindid int;
                                    select TOP 1 @uid=id from wx_t_vipbinging where vipid=@vipid;
                                    if isnull(@uid,0)=0
                                    select '00'
                                    --else if isnull(@vipid,0)=0
                                    --select '01'
                                    else
                                    begin
                                    select @bindid=id from wx_t_vipsalerbind where vipid=@vipid;
                                    if isnull(@bindid,0)=0
                                    begin
                                    select top 1 '02' dm,kh.khmc,kh.lxdh khlxdh,md.mdmc,md.lxdh mdlxdh
                                    from wx_t_vipbinging wx 
                                    left join yx_t_khb kh on wx.khid=kh.khid
                                    left join [192.168.35.10].tlsoft.dbo.t_mdb md on md.mdid=wx.mdid
                                    where wx.id=@uid
                                    end
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
                paras.Add(new SqlParameter("@vipid", vipid));
                DataTable dt = null;
                string errinfo = dal.ExecuteQuerySecurity(str_sql, paras, out dt);
                if (errinfo == "" && dt.Rows.Count>0)
                {
                    string dm = dt.Rows[0][0].ToString();
                    if (dm == "00")
                        clsWXHelper.ShowError("非法访问！");
                    //else if (dm == "01")
                    //    clsWXHelper.ShowError("对不起，您还不是利郎会员！");
                    else if (dm == "02") {
                        dgid = "";
                        //20170315 陈总：如果没有绑定导购的则显示所属门店和电话
                        string ssmd = "", ssmddh = "";
                        if (string.IsNullOrEmpty(Convert.ToString(dt.Rows[0]["mdmc"])))
                        {
                            ssmd = Convert.ToString(dt.Rows[0]["mdmc"]);
                            ssmddh = Convert.ToString(dt.Rows[0]["mdlxdh"]);
                        }
                        else {
                            ssmd = Convert.ToString(dt.Rows[0]["khmc"]);
                            ssmddh = Convert.ToString(dt.Rows[0]["khlxdh"]);      
                        }
                        AddHT(DG, "ssmd", ssmd);
                        AddHT(DG, "ssmddh", ssmddh);
                    }
                    else if (dm == "11")
                    {
                        BindKey = dt.Rows[0]["bindkey"].ToString();
                        dgid = dt.Rows[0]["dgid"].ToString();
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
    <link type="text/css" rel="stylesheet" href="../css/LeePageSlider.css" />
    <link type="text/css" rel="stylesheet" href="../css/font-awesome.min.css" />
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
        .hint,.ssinfo {
            color:#ebebeb;
            font-size:1.1em;
            white-space:nowrap;
            display:none;
        }
        .ssinfo {
            display:block;            
        }
        .chat-btn {
            width: 124px;
            height: 36px;
            line-height: 36px;
            background-color: #82BF56;
            border-bottom: 3px solid #669644;
            text-shadow: 0px -2px #669644;
            color: #fff;
            font-size: 1.1em;
            border-radius: 5px;
            margin: 0 auto;
            letter-spacing: 1px;
            text-align: center;
        }
        .tips {
            z-index: 1005;
            position: fixed;
            top: 0;
            left: 0;
            width: 100%;
            height: 100%;
            background-color: rgba(0,0,0,.6);
            display: none;
        }

            .tips .tips-c {
                width: 90%;
                height: 160px;
                background-color: #fff;
                border-radius: 4px;
                background-color: transparent;
            }

        .txt-top {
            height: 50%;
            background-color: #669644;
            border-top-left-radius: 5px;
            border-top-right-radius: 5px;
            font-size: 1.2em;
            font-weight: bold;
            text-align: center;
            line-height: 80px;
            color: #fff;
            text-shadow: 1px 2px #323232;
        }

        .btn-bot {
            height: 50%;
            background-color: #f7f7f7;
            border-bottom-left-radius: 5px;
            border-bottom-right-radius: 5px;
            text-align: center;
        }

        .fa-times-circle {
            line-height: 80px;
            color: #808080;
            margin-right: 40px;
        }

        .fa-check-circle {
            color: #669644;
        }
        /*animation css*/

        @-webkit-keyframes bounceIn {
            0%,100%,20%,40%,60%,80% {
                -webkit-transition-timing-function: cubic-bezier(0.215,.61,.355,1);
                transition-timing-function: cubic-bezier(0.215,.61,.355,1);
            }

            0% {
                opacity: 0;
                -webkit-transform: scale3d(.3,.3,.3);
                transform: scale3d(.3,.3,.3);
            }

            20% {
                -webkit-transform: scale3d(1.1,1.1,1.1);
                transform: scale3d(1.1,1.1,1.1);
            }

            40% {
                -webkit-transform: scale3d(.9,.9,.9);
                transform: scale3d(.9,.9,.9);
            }

            60% {
                opacity: 1;
                -webkit-transform: scale3d(1.03,1.03,1.03);
                transform: scale3d(1.03,1.03,1.03);
            }

            80% {
                -webkit-transform: scale3d(.97,.97,.97);
                transform: scale3d(.97,.97,.97);
            }

            100% {
                opacity: 1;
                -webkit-transform: scale3d(1,1,1);
                transform: scale3d(1,1,1);
            }
        }

        @keyframes bounceIn {
            0%,100%,20%,40%,60%,80% {
                -webkit-transition-timing-function: cubic-bezier(0.215,.61,.355,1);
                transition-timing-function: cubic-bezier(0.215,.61,.355,1);
            }

            0% {
                opacity: 0;
                -webkit-transform: scale3d(.3,.3,.3);
                -ms-transform: scale3d(.3,.3,.3);
                transform: scale3d(.3,.3,.3);
            }

            20% {
                -webkit-transform: scale3d(1.1,1.1,1.1);
                -ms-transform: scale3d(1.1,1.1,1.1);
                transform: scale3d(1.1,1.1,1.1);
            }

            40% {
                -webkit-transform: scale3d(.9,.9,.9);
                -ms-transform: scale3d(.9,.9,.9);
                transform: scale3d(.9,.9,.9);
            }

            60% {
                opacity: 1;
                -webkit-transform: scale3d(1.03,1.03,1.03);
                -ms-transform: scale3d(1.03,1.03,1.03);
                transform: scale3d(1.03,1.03,1.03);
            }

            80% {
                -webkit-transform: scale3d(.97,.97,.97);
                -ms-transform: scale3d(.97,.97,.97);
                transform: scale3d(.97,.97,.97);
            }

            100% {
                opacity: 1;
                -webkit-transform: scale3d(1,1,1);
                -ms-transform: scale3d(1,1,1);
                transform: scale3d(1,1,1);
            }
        }

        .bounceIn {
            display: block;
            -webkit-animation-name: bounceIn;
            animation-name: bounceIn;
            -webkit-animation-duration: .75s;
            animation-duration: .75s;
        }
    </style>
</head>
<body>

    <div class="wrap-page">
        <i class="fa fa-angle-left" onclick="javascript:window.history.back(-1);"></i>
        <div class="page">
            <div class="infocard">
                <div class="headimg animated">
                    
                </div>
                <p class="guidername"><%=DG["nickname"].ToString() %></p>
                <div class="chat-btn" onclick="javascript:$('.tips').show();$('.tips > div').addClass('bounceIn');">马上沟通</div>
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
                    <p><%=DG["ShareText"].ToString() %></p>
                </div>
            </div>
            <div class="hint center-translate">Sorry,您暂时还没有专属导购!</div>
            <div class="ssinfo center-translate">
                <p>尊敬的利郎会员，您暂时还没有专属导购！</p>
                <p style="padding:5px 0;"><strong>所属门店：</strong><span style="white-space:pre-line;">--</span></p>
                <p><strong>联系电话：</strong><span>--</span></p>
            </div>
        </div>
    </div>
    <div class="tips">
        <div style="width: 100%; height: 100%; position: relative;" class="animated">
            <div class="tips-c center-translate">
                <p class="txt-top">请在利郎男装中直接与我进行沟通!</p>
                <div class="btn-bot">
                    <i class="fa fa-3x fa-times-circle" onclick="javascript:$('.tips').hide();$('.tips > div').removeClass('bounceIn');"></i>
                    <i class="fa fa-3x fa-check-circle" onclick="javascript:WeixinJSBridge.call('closeWindow');"></i>
                </div>
            </div>
        </div>
    </div>
    <script type="text/javascript" src="../js/jquery.js"></script>
    <script type="text/javascript" src="../js/fastclick.min.js"></script>
    <script type="text/javascript" src="../js/jweixin-1.1.0.js"></script>

    <script type="text/javascript">
        var dgid = "<%=dgid%>";
        $(function () {
            $(".headimg").css("background-image", "url(<%=DG["headimg"].ToString() %>)");
            FastClick.attach(document.body);
            if (dgid == "" || dgid == "0" || dgid == undefined) {
                //$(".hint").show();
                $(".ssinfo p:nth-child(2) > span").text("<%=Convert.ToString(DG["ssmd"])%>");
                $(".ssinfo p:nth-child(3) > span").text("<%=Convert.ToString(DG["ssmddh"])%>");
            } else {
                $(".infocard").show();
                $(".headimg.animated").addClass("flip");
            }            
        });

        //以下是实现微信的JSAPI
        wx.config({
            debug: false, // 开启调试模式,调用的所有api的返回值会在客户端alert出来，若要查看传入的参数，可以在pc端打开，参数信息会通过log打出，仅在pc端时才会打印。
            appId: '<%= wxConfig[0] %>', // 必填，企业号的唯一标识，此处填写企业号corpid
            timestamp: '<%= wxConfig[1] %>', // 必填，生成签名的时间戳
            nonceStr: '<%= wxConfig[2] %>', // 必填，生成签名的随机串
            signature: '<%= wxConfig[3] %>',// 必填，签名，见附录1
            jsApiList: ['onMenuShareTimeline','onMenuShareAppMessage','hideMenuItems'] // 必填，需要使用的JS接口列表，所有JS接口列表见附录2
        });

        wx.ready(function(){
            // config信息验证后会执行ready方法，所有接口调用都必须在config接口获得结果之后，config是一个客户端的异步操作，所以如果需要在页面加载时就调用相关接口，则须把相关接口放在ready函数中调用来确保正确执行。对于用户触发时才调用的接口，则可以直接调用，不需要放在ready函数中。

            wx.onMenuShareTimeline({
                title: 'Ta是我的利郎专属搭配顾问...', // 分享标题
                link: '<%= Request.Url.AbsoluteUri %>', // 分享链接
                imgUrl: '<%=DG["headimg"].ToString() %>', // 分享图标
                success: function () {
                    // 用户确认分享后执行的回调函数
                    alert("感谢您的分享！");
                },
                cancel: function () {
                    // 用户取消分享后执行的回调函数
                }
            });

            wx.onMenuShareAppMessage({
                title: '我的利郎专属搭配顾问', // 分享标题
                desc: '我觉得Ta很专业、很不错，现在我把Ta分享给你！', // 分享描述
                link: '<%= Request.Url.AbsoluteUri %>', // 分享链接
                imgUrl: '<%=DG["headimg"].ToString() %>', // 分享图标
                type: 'link', // 分享类型,music、video或link，不填默认为link
                dataUrl: '', // 如果type是music或video，则要提供数据链接，默认为空
                success: function () {
                    // 用户确认分享后执行的回调函数
                    alert("感谢您的分享！");
                },
                cancel: function () {
                    // 用户取消分享后执行的回调函数
                }
            });

            wx.hideMenuItems({
                menuList: ['menuItem:openWithSafari','menuItem:openWithQQBrowser','menuItem:share:qq','menuItem:copyUrl','menuItem:favorite'] // 要隐藏的菜单项，所有menu项见附录3
            });
        });
    </script>
</body>
</html>

