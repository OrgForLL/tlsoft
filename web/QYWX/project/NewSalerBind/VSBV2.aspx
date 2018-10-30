<%@ Page Language="C#" %>

<%@ Import Namespace="nrWebClass" %>
<%@ Import Namespace="System.Data" %>
<%@ Import Namespace="System.Data.SqlClient" %>
<%@ Import Namespace="System.Collections.Generic" %>
<%@ Import Namespace="Newtonsoft.Json" %>
<%@ Import Namespace="Newtonsoft.Json.Linq" %>
<!DOCTYPE html>
<script runat="server"> 
    public string ConfigKey = "", bindStoreName = "", OldSalerStr = "", NewSalerStr = "", wxOpenID = "";
    public string currentSaler = "", currentStoreID = "";
    public bool isVIP = false;
    public Dictionary<string, string> OldSaler = new Dictionary<string, string>();
    public Dictionary<string, string> NewSaler = new Dictionary<string, string>();

    private static string DBConnStr = "server='192.168.35.10';uid=ABEASD14AD;pwd=+AuDkDew;database=tlsoft";
    private static string wxconn = "server='192.168.35.62';uid=sa;pwd=ll=8727;database=weChatPromotion";

    protected void Page_Load(object sender, EventArgs e)
    {
        ConfigKey = clsConfig.GetConfigValue("CurrentConfigKey");
        currentSaler = Convert.ToString(Request.Params["cid"]);
        currentStoreID = Convert.ToString(Request.Params["mdid"]);
        if (ConfigKey == "")
            clsSharedHelper.WriteErrorInfo("读取ConfigKey失败！");
        else if (string.IsNullOrEmpty(currentSaler))
            clsSharedHelper.WriteErrorInfo("缺少参数【cid】！");
        else if (string.IsNullOrEmpty(currentStoreID))
            clsSharedHelper.WriteErrorInfo("缺少必要参数【mdid】！");
        else
        {
            if (clsWXHelper.CheckUserAuth(ConfigKey, "openid"))
            {
                wxOpenID = Convert.ToString(Session["openid"]);
                List<SqlParameter> paras = new List<SqlParameter>();
                DataTable dt;
                string dbconn = clsConfig.GetConfigValue("OAConnStr");
                using (LiLanzDALForXLM dal10 = new LiLanzDALForXLM(dbconn))
                {
                    string str_sql = @"select wx.id wxid,isnull(wx.vipid,0) vipid,isnull(md.mdmc,'') mdmc,isnull(kh.khmc,'') khmc
                                        from wx_t_vipbinging wx                                        
                                        left join t_mdb md on md.mdid=wx.mdid
                                        left join yx_t_khb kh on wx.khid=kh.khid
                                        where wx.wxopenid=@openid";
                    paras.Add(new SqlParameter("@openid", wxOpenID));
                    string errinfo = dal10.ExecuteQuerySecurity(str_sql, paras, out dt);
                    if (errinfo == "")
                    {
                        if (dt.Rows.Count > 0)
                        {
                            isVIP = Convert.ToInt32(dt.Rows[0]["vipid"]) > 0 ? true : false;
                            string khmc = Convert.ToString(dt.Rows[0]["khmc"]);
                            string mdmc = Convert.ToString(dt.Rows[0]["mdmc"]);
                            bindStoreName = string.IsNullOrEmpty(mdmc) ? khmc : mdmc;
                            //获取原始导购相关信息
                            getOldSalerInfo(wxOpenID);
                            //获取当前导购相关信息
                            getSalerInfo(currentSaler, ref NewSaler);
                            if (NewSaler.Keys.Count > 0)
                                NewSalerStr = JsonConvert.SerializeObject(NewSaler);
                        }
                        else
                            clsSharedHelper.WriteErrorInfo("对不起，找不到您的相关信息！");
                    }
                }//end using10
            }
        }
    }

    public void getOldSalerInfo(string openid)
    {
        string ConWX = clsWXHelper.GetWxConn();
        using (LiLanzDALForXLM dal = new LiLanzDALForXLM(ConWX))
        {
            string str_sql = "select top 1 cid from wx_t_VipServerBind where OpenID=@openid";
            List<SqlParameter> paras = new List<SqlParameter>();
            paras.Add(new SqlParameter("@openid", openid));
            object scalar;
            string errinfo = dal.ExecuteQueryFastSecurity(str_sql, paras, out scalar);
            if (errinfo == "" && Convert.ToInt32(scalar) > 0)
            {
                getSalerInfo(Convert.ToString(scalar), ref OldSaler);
                OldSalerStr = JsonConvert.SerializeObject(OldSaler);
            }
        }
    }

    public void getSalerInfo(string salerid, ref Dictionary<string, string> dic)
    {
        string ConWX = clsWXHelper.GetWxConn();
        using (LiLanzDALForXLM dal = new LiLanzDALForXLM(ConWX))
        {
            string str_sql = @"select a.id,a.cname,a.avatar,ISNULL(c.relateID,0) relateid,ISNUMERIC(isnull(e.dm,'')) bdm,isnull(e.dm,'') jbdm,
                                (select COUNT(id) from wx_t_VipServerBind where cid=@cid) servicecounts
                                from wx_t_customers a 
                                left join wx_t_AppAuthorized b on a.ID=b.UserID and b.SystemID=3
                                left join wx_t_omnichanneluser c on b.SystemKey=c.id
                                left join Rs_T_Rydwzl d on c.relateID=d.id
                                left join dm_t_xzjbb e on d.zd=e.id
                                where a.ID=@cid ";
            List<SqlParameter> paras = new List<SqlParameter>();
            paras.Add(new SqlParameter("@cid", salerid));
            DataTable dt;
            string errinfo = dal.ExecuteQuerySecurity(str_sql, paras, out dt);
            if (errinfo == "" && dt.Rows.Count > 0)
            {
                dic.Clear();
                dic.Add("id", Convert.ToString(dt.Rows[0]["id"]));
                dic.Add("name", Convert.ToString(dt.Rows[0]["cname"]));
                dic.Add("avatar", Convert.ToString(dt.Rows[0]["avatar"]));
                string jb = Convert.ToString(dt.Rows[0]["bdm"]);
                if (jb == "1")
                    dic.Add("serviceLevel", (Convert.ToInt32(dt.Rows[0]["jbdm"]) + 1).ToString());
                else
                    dic.Add("serviceLevel", "2");
                dic.Add("serviceCounts", Convert.ToString(dt.Rows[0]["servicecounts"]));
            }
        }
    }
</script>
<html lang="zh-cmn">
<head runat="server">
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width,initial-scale=1.0,user-scalable=no">
    <title>关注我们</title>
    <link rel="stylesheet" href="../../res/css/NewVip/guide.css">
</head>
<body>
    <div class="container">
        <div class="logo">
            <img src="../../res/img/NewVip/logo_lilanz.png" alt="">
        </div>
        <div class="publicNo">利郎男装</div>
        <div class="guide">
            <p class="title">正在绑定您的专属导购</p>
            <div class="bind">
                <div class="icon">
                    <div class="border">
                        <div class="headimg"></div>
                    </div>
                </div>
                <p class="name"></p>
                <div class="stars">
                </div>
                <p class="num">服务人数: <span>0</span></p>
            </div>
            <div class="change" style="display: none;">
                <div class="old-guide">
                    <div class="icon">
                        <div class="border">
                            <div class="headimg"></div>
                        </div>
                    </div>
                    <p class="name"></p>
                    <div class="stars">
                    </div>
                    <p class="num">服务人数: <span>0</span></p>
                </div>
                <img src="../../res/img/NewVip/arrow_right.png" alt="">
                <div class="new-guide">
                    <div class="icon">
                        <div class="border">
                            <div class="headimg"></div>
                        </div>
                    </div>
                    <p class="name"></p>
                    <div class="stars">
                    </div>
                    <p class="num">服务人数: <span>0</span></p>
                </div>
            </div>
        </div>
        <div class="store-detail">
            <div class="store-name">
                <span>所属门店</span>
                <p>未绑定门店</p>
            </div>
            <div class="card">
                <span>线下卡</span>
                <p><img src="../../res/img/NewVip/tick.png" alt=""> 已关联</p>
            </div>
        </div>
        <div class="line"></div>
        <div class="submit">
            <a>立即绑定</a>
        </div>
        <div class="other" style="display: none;">
            <a href="javascript:void(0)">注册新会员</a>
            <a href="javascript:void(0)">关联线下卡</a>
        </div>
    </div>
    <div class="reason" style="display: none;">
        <div class="list">
            <div class="title">
                <img src="../../res/img/NewVip/icon_back.png" alt="">
                <span>更换导购原因</span>
            </div>
            <ul>
                <li class="onselected">
                    <span>原因 1</span>
                    <img src="../../res/img/NewVip/right.png" alt="">
                    <span class="unselected"></span>
                </li>
                <li>
                    <span>原因 2</span>
                    <img src="../../res/img/NewVip/right.png" alt="">
                    <span class="unselected"></span>
                </li>
                <li>
                    <span>原因 3</span>
                    <img src="../../res/img/NewVip/right.png" alt="">
                    <span class="unselected"></span>
                </li>
                <li>
                    <span>原因 4</span>
                    <img src="../../res/img/NewVip/right.png" alt="">
                    <span class="unselected"></span>
                </li>
                <li>
                    <span>原因 5</span>
                    <img src="../../res/img/NewVip/right.png" alt="">
                    <span class="unselected"></span>
                </li>
            </ul>
        </div>
        <div class="submit">
            <a>确定</a>
        </div>
    </div>
    <div class="prompt" style="display: none;">
        <div class="alert" style="display: none;">
            <div class="title">
                <span>绑定成功</span>
                <img src="../../res/img/NewVip/close.png" alt="">
            </div>
            <div class="content">
                <img class="pass" src="../../res/img/pass.png" alt="">
                <img class="fail" src="../../res/img/fail.png" alt="">
                <span>XXX已绑定为您的专属导购</span>
            </div>
            <div class="btn">
                <a>确定</a>
            </div>
        </div>
        <div class="loading" style="display: none;">
            <img src="../../res/img/NewVip/loading.png" alt="">
            <span>正在加载..</span>
        </div>
    </div>
    <script src="../../res/js/zepto.min.js"></script>
    <script>
        (function(window, undefind) {
            var configKey = '<%=ConfigKey %>', bindStoreName = '<%=bindStoreName %>',
                OldSalerStr = '<%=OldSalerStr %>', NewSalerStr = '<%=NewSalerStr %>';
            var isVIP = '<%=isVIP %>';
            var headurl = '//tm.lilanz.com/oa/';
            var openid = '<%=wxOpenID %>', storeid = '<%=currentStoreID %>', opinion = '0', cid = '<%=currentSaler %>';
            var OldSaler = null, NewSaler = null;
            var api = '//tm.lilanz.com/qywx/api/SalerBindCore.ashx';
            alert(NewSalerStr);
            function init() {
                bindEvents();
                setQSWLogo();
                getGuideInfo();
                setStoreInfo();
                setVIPInfo();
            }

            function bindEvents() {
                document.querySelector('.reason .title').addEventListener('click', function() {
                    showContainer();
                });

                document.querySelector('.reason .submit a').addEventListener('click', function() {
                    showLoading();
                    bindSaler();
                })

                document.querySelector('.alert .btn a').addEventListener('click', function() {
                    var err = !document.querySelector('.alert .err');
                    hidePrompt();
                    setBindGuideInfo(err);
                    showOther();
                    setTitle('已绑定该专属导购');
                });

                document.querySelector('.alert .title img').addEventListener('click', function() {
                    hidePrompt();
                    showBind();
                })
            }

            function bindSelectorEvents() {
                var li = document.querySelectorAll('.reason li');

                for (var i = 0; i < li.length; i++) {
                    li[i].addEventListener('click', function() {
                        var doms = siblings(this);
                        for (var i = 0; i < doms.length; i ++) {
                            doms[i].classList.remove('onselected');
                        }
                        this.classList.add('onselected')
                        opinion = this.getAttribute('data-id');
                    });
                }
            }

            function setQSWLogo() {
                if (configKey === '7') {
                    document.querySelector('.logo img').setAttribute('src', '../../res/img/NewVip/logo_qsw.png');
                    document.querySelector('.publicNo').innerText = '利郎轻商务';
                }
            }

            function setTitle(text) {
                document.querySelector('.guide .title').innerText = text;
            }

            function getGuideInfo() {
                NewSaler = JSON.parse(NewSalerStr);
                if (NewSaler == '') { 
                    alert('获取导购信息出错！');
                    return null;
                }
                if (OldSalerStr !== '') {
                    OldSaler = JSON.parse(OldSalerStr);
                    if (NewSaler.id === OldSaler.id) {
                        setBindGuideInfo();
                        setTitle('您已绑定该专属导购');
                        showOther();
                    } else {
                        setChangeGuideInfo();
                        getDisOpinions();
                        setTitle('正在更换您的专属导购')
                        setSubmitText('立即更换');
                        bindChangeSubmit();
                    }
                } else {
                    setBindGuideInfo();
                    setTitle('正在绑定您的专属导购');
                    setSubmitText('立即更换');
                    getDisOpinions();
                    bindBindSubmit();
                }
            }

            /* 
             * 未绑定导购时，当前正在绑定的导购
             * 已绑定导购，且扫描导购与绑定导购为同一人
             */
            function setBindGuideInfo(err) {
                var dom = document.querySelector('.bind');
                if (!err) {
                    setGuideInfo(dom, NewSaler);
                } else {
                    setGuideInfo(dom, OldSaler);
                }
                
                showBind();
            }

            /*
             * 已绑定导购，且扫描导购与已绑定导购不同 
             */
            function setChangeGuideInfo() {
                var newguide = document.querySelector('.new-guide');
                var oldguide = document.querySelector('.old-guide');
                setGuideInfo(newguide, NewSaler);
                setGuideInfo(oldguide, OldSaler);
                showChange();
            }

            function setGuideInfo(dom, data) {
                var avatarUrl = '';
                if (data.avatar == '') {
                    avatarUrl = '../../res/img/headImg.jpg';
                } else {
                    avatarUrl = headurl + data.avatar;
                }
                dom.querySelector('.headimg').style = 'background-image: url(' + avatarUrl + '); background-size: cover;';
                dom.querySelector('.name').innerText = data.name;
                dom.querySelector('.num span').innerText = data.serviceCounts;
                dom.querySelector('.stars').innerHTML = getStarsHtml(parseInt(data.serviceLevel));
            }

            /* 绑定或更换导购 */
            function bindSaler() {
                var data = {
                    action: 'fansBindStore',
                    openid: openid,
                    storeid: storeid,
                    opinion: opinion,
                    cid: cid
                };
                $.ajax({
                    type: 'POST',
                    url: api,
                    contentType: 'application/json',
                    data: JSON.stringify(data),
                    dataType: 'JSON',
                    success: function(res) {
                        var res = JSON.parse(res);
                        if (res.errcode === 0) {
                            var text = NewSaler.name + '已绑定为您的专属导购';
                            showAlert({text: text});
                        } else {
                            var text = res.errmsg;
                            showAlert({text: text, err: true});
                        }
                    }
                });
            }

            /* 获取更换理由 */
            function getDisOpinions() {
                var data = {action: 'getDisOpinions'};
                $.ajax({
                    type: 'POST',
                    url: api,
                    contentType: 'application/json',
                    data: JSON.stringify(data),
                    dataType: 'JSON',
                    success: function(res) {
                        var res = JSON.parse(res);
                        setOpinions(res.data);
                    }
                })
            }

            /* 更换导购 按钮绑定选择理由事件 */
            function bindChangeSubmit() {
                document.querySelector('.container .submit a').addEventListener('click', function() {
                    showReason();
                });
            }

            /* 未绑定导购 按钮直接绑定绑定导购事件 */
            function bindBindSubmit() {
                document.querySelector('.container .submit a').addEventListener('click', function() {
                    showLoading();
                    bindSaler();
                });
            }

            function setStoreInfo() {
                if (bindStoreName !== '') {
                    document.querySelector('.store-name p').innerText = bindStoreName;
                } else {
                    alert('未获取到门店信息！');
                }
            }

            function setVIPInfo() {
                if(!isVIP) {
                    document.querySelector('.card p').innerHTML = '未关联';
                }
            }

            function setSubmitText(text) {
                document.querySelector('.container .submit a').innerText = text;
            }

            function setOpinions(data) {
                var html = '';
                var className = 'class="onselected"';
                for (var key in data) {
                    if (key !== '0' && key > -1) {
                        html = html + '<li ' + className + ' data-id="' + key + '">'
                                    + '<span>' + data[key] + '</span>'
                                    + '<img src="../../res/img/NewVip/right.png" alt="">'
                                    + '<span class="unselected"></span>'
                                    + '</li>'
                        className = '';
                    }
                }

                document.querySelector('.reason ul').innerHTML = html;
                bindSelectorEvents();
            }

            function showBind() {
                document.querySelector('.change').style = 'display: none';
                document.querySelector('.bind').style = '';
                showContainer();
            }

            function showChange() {
                document.querySelector('.bind').style = 'display: none';
                document.querySelector('.change').style = '';
                showContainer();
            }

            function showLoading(text) {
                if (text && text !== '') {
                    document.querySelector('.loading span').innerText = text
                } else {
                    document.querySelector('.loading span').innerText = '正在加载..'
                }

                document.querySelector('.alert').style = 'display: none;';
                document.querySelector('.loading').style = 'display: block;';
                document.querySelector('.prompt').style = 'display: block;';
            }

            function showAlert(data) {
                var data = data ? data : null;

                if (data && data.title && data.title !== '') {
                    document.querySelector('.alert .title span').innerText = data.title;
                } else {
                    document.querySelector('.alert .title span').innerText = '绑定成功';
                }

                if (data && data.text && data.text !== '') {
                    document.querySelector('.alert .content span').innerText = data.text;
                } else {
                    document.querySelector('.alert .content span').innerText = 'Test已绑定为您的专属导购';
                }

                if (data && data.err) {
                    document.querySelector('.alert').classList.add('err');
                } else {
                    document.querySelector('.alert').classList.remove('err');
                }

                document.querySelector('.loading').style = 'display: none;';
                document.querySelector('.alert').style = 'display: block;';
                document.querySelector('.prompt').style = 'display: block;';
            }

            function hidePrompt() {
                document.querySelector('.loading').style = 'display: none;';
                document.querySelector('.alert').style = 'display: none;';
                document.querySelector('.prompt').style = 'display: none;';
            }

            function showReason() {
                document.querySelector('.container').style = 'display: none;';
                document.querySelector('.reason').style = 'display: flex;';
            }

            function showContainer() {
                document.querySelector('.reason').style = 'display: none;';
                document.querySelector('.container').style = '';
            }

            function showOther() {
                document.querySelector('.container .submit').style = 'display: none;';
                document.querySelector('.container .other').style = '';
            }

            function getStarsHtml(num) {
                var num = num ? num : 0;
                var html = null;

                html = new Array(num + 1).join('<img src="../../res/img/NewVip/star_selected.png" alt="">') + 
                new Array(6 - num).join('<img src="../../res/img/NewVip/star_default.png" alt="">');

                return html;
            }

            function siblings(elm) {
                var a = [];
                var p = elm.parentNode.children;
                for (var i = 0, pl = p.length; i < pl; i++) {
                    if (p[i] !== elm) a.push(p[i]);
                }
                return a;
            }

            init();
        }) (window)
    </script>
</body>
</html>