<%@ Page Language="C#" %>

<%@ Import Namespace="nrWebClass" %>
<%@ Import Namespace="System.Data" %>
<%@ Import Namespace="System.Data.SqlClient" %>
<%@ Import Namespace="System.Collections.Generic" %>
<!DOCTYPE html>
<script runat="server">
    public string ryid = "";
    public string AppSystemKey = "";
    private string ChatProConnStr = System.Configuration.ConfigurationManager.ConnectionStrings["Conn"].ConnectionString;
    private const string ConfigKeyValue = "1";	//微信配置信息索引值 1为企业号
    public List<string> wxConfig;       //微信OPEN_JS 动态生成的调用参数
    
    //20160408 liqf添加可以传入RYID参数，且当roleid!=1时就使用传的参数 
    //20160413 当使用传入的RYID参数时还要判断该RYID所属的MDID是否与当前用户的一致否则就算越权访问
    //20160527 liqf增加单据明细中货号图片的查看功能
    protected void Page_Load(object sender, EventArgs e)
    {
        //Session["qy_customersid"] = "354";
        if (clsWXHelper.CheckQYUserAuth(true))
        {
            string SystemID = "3";
            AppSystemKey = clsWXHelper.GetAuthorizedKey(Convert.ToInt32(SystemID));            
            if (AppSystemKey == "")
                clsWXHelper.ShowError("对不起，您还未开通全渠道系统权限！");
            else
            {
                string roleid = Convert.ToString(Session["RoleID"]);
                string pRyid = Convert.ToString(Request.Params["ryid"]);
                if (pRyid != null && pRyid != "0" && pRyid != null && roleid != "1") {
                    ryid = pRyid;
                    //判断传入的人员ID是否与当前用户所属同一门店
                    using (LiLanzDALForXLM dal = new LiLanzDALForXLM(ChatProConnStr)) {
                        string sql = "select top 1 mdid from rs_t_rydwzl where id=@ryid;";
                        List<SqlParameter> paras = new List<SqlParameter>();
                        paras.Add(new SqlParameter("@ryid",ryid));
                        DataTable _dt=null;
                        string errinfo = dal.ExecuteQuerySecurity(sql, paras, out _dt);
                        if (errinfo == "") {
                            if (_dt.Rows.Count > 0 && Convert.ToInt32(roleid) <= 2 && Convert.ToString(Session["mdid"]) != Convert.ToString(_dt.Rows[0]["mdid"]))
                                clsWXHelper.ShowError("Sorry，您已越权访问！");
                            else if (_dt.Rows.Count == 0)
                                clsWXHelper.ShowError("Sorry，没有找到业绩数据！");
                            else
                                wxConfig = clsWXHelper.GetJsApiConfig(ConfigKeyValue);
                        }                            
                    }
                }
                else
                {
                    using (LiLanzDALForXLM dal = new LiLanzDALForXLM(ChatProConnStr))
                    {
                        string sql = "select top 1 relateID from wx_t_OmniChannelUser where id='" + AppSystemKey + "'";
                        DataTable dt = null;
                        string errinfo = dal.ExecuteQuery(sql, out dt);
                        if (dt.Rows.Count == 0)
                            clsWXHelper.ShowError("该用户信息不存在，可能已经被停用！");
                        else if (dt.Rows[0][0].ToString() == "0")
                            clsWXHelper.ShowError("对不起，找不到您对应的人资资料！");
                        else
                        {
                            ryid = dt.Rows[0][0].ToString();

                            wxConfig = clsWXHelper.GetJsApiConfig(ConfigKeyValue);
                            clsWXHelper.WriteLog(string.Format("AppSystemKey:{0},访问功能页[{1}]", AppSystemKey, "个人提成记录"));
                        }
                    }
                }
            }
        }
        else
        {
            clsWXHelper.ShowError("鉴权失败！");
        }
    }
</script>
<html lang="en" xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <meta charset="utf-8" />
    <meta name="viewport" content="height=device-height,width=device-width,initial-scale=1.0,minimum-scale=1.0,maximum-scale=1.0,user-scalable=no" />
    <meta name="format-detection" content="telephone=yes" />
    <link href="../../res/css/font-awesome.min.css" rel="stylesheet" />
    <link href="../../res/css/Retail/tcstyle.css" rel="stylesheet" />
    <title></title>
    <style type="text/css">
        /*mask style*/
        .mask {
            color: #fff;
            position: absolute;
            top: 0;
            bottom: 0;
            width:100%;
            height:100%;
            z-index: 1001;
            font-size: 1.1em;
            text-align: center;
            display: none;
            background-color: rgba(0,0,0,0.5);
        }

        #mask2 {
            position: fixed;
            z-index: 901;
        }

        .loader {
            background-color: rgba(39, 43, 46, 0.9);
            padding: 10px 14px;
            border-radius: 5px;
            max-height: 200px;
            overflow: hidden;
            white-space:nowrap;
        }

        #loadtext {
            margin-top: 5px;
            font-weight: bold;
            font-size: 0.9em;
        }

        .center-translate {
            position: absolute;
            top: 50%;
            left: 50%;
            -webkit-transform: translate(-50%, -50%);
            transform: translate(-50%, -50%);
        }
    </style>
</head>
<body>
    <!--加载提示层-->
    <section class="mask">
        <div class="loader center-translate">
            <div style="font-size: 1.2em;">
                <i class="fa fa-2x fa-spinner fa-pulse"></i>
            </div>
            <p id="loadtext">正在加载...</p>
        </div>
    </section>
    <div class="header" style="z-index: 1000;">
        <div class="backbtn"><i class="fa fa-chevron-left"></i></div>
        <h1>个人提成记录</h1>
    </div>
    <div id="mycontent">
        <div class="switch-menu">
            <ul class="floatfix">
                <li onclick="FilterData('today')" class="selected">今 日</li>
                <li onclick="FilterData('all')">全 部</li>
            </ul>
        </div>
        <ul id="accordion" class="accordion">
        </ul>
        <div class="loading" id="nomoreresults">
            Sorry,您暂时还没有相关提成,加油！
        </div>
    </div>
    <div class="modalbg">
        <div id="modaldialog" class="modal">
            <div class="modalcontent">
                <h4 id="detailhead"></h4>
                <br />
                <table id="DJTable" border="1">
                </table>
                <br />
                <p id="finalTC" class="alignright">总提成:0元</p>
                <div class="closemodal" onclick="closeModal()">
                    <svg class="" viewBox="0 0 24 24">
                        <path d="M19 6.41l-1.41-1.41-5.59 5.59-5.59-5.59-1.41 1.41 5.59 5.59-5.59 5.59 1.41 1.41 5.59-5.59 5.59 5.59 1.41-1.41-5.59-5.59z" />
                        <path d="M0 0h24v24h-24z" fill="none" />
                    </svg>
                </div>
            </div>
        </div>
    </div>

    <script type="text/javascript" src="../../res/js/jquery.js"></script>
    <script type="text/javascript" src="http://res.wx.qq.com/open/js/jweixin-1.0.0.js"></script>
    <script type='text/javascript' src='../../res/js/Retail/fastclick.min.js'></script>
    <script type="text/javascript">
        var appIdVal = "<%=wxConfig[0]%>", timestampVal = "<%=wxConfig[1]%>", nonceStrVal = "<%=wxConfig[2]%>", signatureVal = "<%=wxConfig[3]%>";
        var ryid = "<%=ryid%>", st = 0, todayLoaded = false, allLoaded = false;

        $(document).ready(function () {
            FastClick.attach(document.body);
            jsConfig();
        });

        var Accordion = function (el, multiple, classname) {
            this.el = el || {};
            this.multiple = multiple || false;
            var links = this.el.find(classname);
            links.on('click', {
                el: this.el,
                multiple: this.multiple
            }, this.dropdown);
        };

        function getQueryString(name) {
            var reg = new RegExp("(^|&)" + name + "=([^&]*)(&|$)", "i");
            var r = window.location.search.substr(1).match(reg);
            if (r != null)
                return unescape(r[2]);
            else
                return "";
        }

        window.onload = function () {                       
            //FilterData("today");//默认显示今日的提成记录

            var ctrl = getQueryString("ctrl");
            if (ctrl == "today" || ctrl == "" || ctrl == undefined)
                FilterData("today");
            else if (ctrl == "all")
                FilterData("all");
        };

        function loadData() {
            showLoader("loading", " 正在加载数据");
            $.ajax({
                type: "POST",
                timeout: 10000,
                url: "../../WebBLL/RetailTC.aspx",
                data: { ctrl: "getALL", ryid: ryid },
                success: function (data) {
                    if (data != "") {
                        $("#accordion").append(data);
                        $("#nomoreresults").hide();
                    }
                    else
                        $("#nomoreresults").fadeIn(200);
                    $(".mask").hide();
                    var obj = $("#accordion");
                    new Accordion(obj, false, ".link");
                    allLoaded = true;                    
                },
                error: function (XMLHttpRequest, textStatus, errorThrown) {
                    showLoader("error", "您的网络好像出了点问题，请稍候重试!");
                }
            });
        }

        Accordion.prototype.dropdown = function (e) {
            var htmlstr = "<li><a href='#'>正在加载数据，请稍候...</a></li>";
            var $el = e.data.el;
            $this = $(this), $next = $this.next();
            var classname = $this.parent().attr('class');
            if (!(classname == "" || classname == "open")) {
                $this.parent().find("ul").append(htmlstr);
                var nydm = $($this.parent().children(0)[0]).val();
                $.ajax({
                    type: "POST",
                    timeout: 10000,
                    url: "../../WebBLL/RetailTC.aspx",
                    data: { ctrl: "getTCByNy", ryid: ryid, ny: nydm },
                    success: function (data) {
                        if (data != "") {
                            $this.parent().find("ul").find("li").remove();
                            $this.parent().find("ul").append(data);
                        }
                    },
                    error: function (XMLHttpRequest, textStatus, errorThrown) {
                        alert(XMLHttpRequest.status + "|" + XMLHttpRequest.readyState + "|" + textStatus);
                    }
                });
            }
            $next.slideToggle();
            $this.parent().toggleClass('open');
            if (!e.data.multiple) {
                $el.find('.submenu').not($next).slideUp().parent().removeClass('open');
            };
        };

        //今日、全部的筛选
        function FilterData(type) {
            if (type == "today") {
                if (!todayLoaded) {
                    showLoader("loading", " 正在加载数据");
                    $.ajax({
                        type: "POST",
                        timeout: 10000,
                        url: "../../WebBLL/RetailTC.aspx",
                        data: { ctrl: "TodayTcData", ryid: ryid },
                        success: function (data) {
                            var str_html = "";
                            if (data.indexOf("Error:") > -1) {
                                showLoader("error", data);
                                return;
                            } else if (data == "")
                                str_html = "<li class='open'><div class='link'><i class='fa fa-angle-double-right'></i>今日暂无提成记录！</div></li>";
                            else {
                                var ds = JSON.parse(data);
                                var len = ds.rows.length;
                                str_html = "<li class='open'><input type='hidden' value='' /><div class='link'><i class='fa fa-angle-double-right'></i>今日总提成：#tczje#元<i class='fa fa-chevron-down'></i></div><ul class='submenu' style='overflow:hidden;display:block;'>#tclist#</ul></li>";
                                var liTemp = "<li><a href='#' onclick='detail(#lsid#,#tcje#)'>时间:#rq# 单据号:#djh#<br/>销售金额:#xsje#元 提成金额:#tcje#元 </a></li>";
                                var str = "", tczje = 0;
                                for (var i = 0; i < len; i++) {
                                    var row = ds.rows[i];
                                    tczje += parseFloat(row.tcje);
                                    str += liTemp.replace("#lsid#", row.id).replace("#tcje#", row.tcje).replace("#rq#", row.rq).replace("#djh#", row.djh).replace("#xsje#", row.xsje).replace("#tcje#", row.tcje);
                                }//end for
                                str_html = str_html.replace("#tczje#", parseFloat(tczje).toFixed(2)).replace("#tclist#", str);
                            }

                            $("#accordion").prepend(str_html);
                            todayLoaded = true;
                            $(".mask").hide();                            
                            $("#accordion > li:not(:first-child)").hide();
                        },
                        error: function (XMLHttpRequest, textStatus, errorThrown) {
                            alert(XMLHttpRequest.status + "|" + XMLHttpRequest.readyState + "|" + textStatus);
                        }
                    });
                } else {
                    $("#accordion > li:not(:first-child)").hide();
                    $("#accordion > li:first-child").addClass("open");
                    $("#accordion > li:first-child").show();
                }

                $(".switch-menu .selected").removeClass("selected");
                $(".switch-menu ul li:first-child").addClass("selected");
                $("#nomoreresults").hide();
            } else if (type == "all") {
                if (!allLoaded)
                    loadData();

                $("#accordion > li:not(:first-child)").show();
                $("#accordion > li:first-child[class='open']").hide();
                //$("#accordion > li:first-child").hide();
                $(".switch-menu .selected").removeClass("selected");
                $(".switch-menu ul li:last-child").addClass("selected");
            }
        }

        function closeModal() {
            $(".modalbg").hide();
            document.body.scrollTop = st;
        }

        function detail(id, je) {
            st = document.body.scrollTop;
            $.ajax({
                type: "POST",
                timeout: 10000,
                url: "../../WebBLL/RetailTC.aspx",
                data: { ctrl: "getDjDetail", ryid: ryid, djid: id },
                success: function (data) {
                    data = JSON.parse(data);
                    var len = data.rows.length;
                    if (len > 0) {
                        $("#detailhead").html("单据号：" + data.rows[0].djh + " 交易时间：" + data.rows[0].sj);
                        var tablehtml = "<thead><tr><td>商品货号</td><td>尺码</td><td>折扣</td><td>单价</td><td>数量</td><td>金额</td></tr></thead><tbody>";
                        for (var i = 0; i < len; i++) {
                            var row = data.rows[i];
                            tablehtml += "<tr><td class='aligncenter' style='color:#1765c5;text-decoration:underline;' onclick='previewImage(\"" + row.sphh + "\")'>" + row.sphh + "</td><td class='alignright'>" + row.cmmc + "</td><td class='alignright'>" + row.zks + "</td><td class='alignright'>" + parseInt(row.dj) + "</td><td class='alignright'>" + row.sl + "</td><td class='alignright'>" + parseInt(row.je) + "</td></tr>";
                        }
                        tablehtml += "</tbody>";
                        $("#DJTable").children().remove();
                        $("#DJTable").append(tablehtml);
                        $("#finalTC").html("总提成：" + je + "元");
                    }
                },
                error: function (XMLHttpRequest, textStatus, errorThrown) {
                    alert(XMLHttpRequest.status + "|" + XMLHttpRequest.readyState + "|" + textStatus);
                }
            });
            $(".modalbg").fadeIn(400);
        }

        $(".backbtn").click(function () {
            window.history.go(-1);
        });

        //提示层
        function showLoader(type, txt) {
            switch (type) {
                case "loading":
                    $(".mask .fa").removeAttr("class").addClass("fa fa-2x fa-spinner fa-pulse");
                    $("#loadtext").text(txt);
                    $(".mask").show();
                    break;
                case "successed":
                    $(".mask .fa").removeAttr("class").addClass("fa fa-2x fa-check");
                    $("#loadtext").text(txt);
                    $(".mask").show();
                    setTimeout(function () {
                        $(".mask").fadeOut(200);
                    }, 500);
                    break;
                case "error":
                    $(".mask .fa").removeAttr("class").addClass("fa fa-2x fa-close (alias)");
                    $("#loadtext").text(txt);
                    $(".mask").show();
                    setTimeout(function () {
                        $(".mask").fadeOut(400);
                    }, 2000);
                    break;
                case "warn":
                    $(".mask .fa").removeAttr("class").addClass("fa fa-2x fa-warning (alias)");
                    $("#loadtext").text(txt);
                    $(".mask").show();
                    setTimeout(function () {
                        $(".mask").fadeOut(400);
                    }, 800);
                    break;
            }
        }

        //使用微信JS-SDK
        function jsConfig() {
            wx.config({
                debug: false,
                appId: appIdVal, // 必填，公众号的唯一标识
                timestamp: timestampVal, // 必填，生成签名的时间戳
                nonceStr: nonceStrVal, // 必填，生成签名的随机串
                signature: signatureVal, // 必填，签名，见附录1
                jsApiList: ['previewImage'] // 必填，需要使用的JS接口列表，所有JS接口列表见附录2
            });
            wx.ready(function () {

            });
            wx.error(function (res) {
                alert("JS注入失败！");
            });
        }

        var imgURLs = new Array();
        //微信的预览图片接口
        function previewImage(sphh) {
            showLoader("loading", "正在加载图片,请稍候...");
            $.ajax({
                url: "../../WebBLL/VIPListCore.aspx?ctrl=GetClothesPics",
                type: "POST",
                dataType: "text",
                data: { sphh: sphh },
                timeout: 5000,
                error: function (XMLHttpRequest, textStatus, errorThrown) {
                    showLoader("error", "您的网络好像出了点问题,请稍后重试...");
                },
                success: function (result) {
                    if (result == "") {
                        showLoader("warn", "对不起,这个货号暂时还没上传图片!");
                    } else if (result.indexOf("Error:") > -1) {
                        showLoader("error", result);
                    } else {
                        var imgs = result.split('|');
                        imgURLs = [];//每次都先清空数组
                        for (var i = 0; i < imgs.length - 1; i++) {
                            imgURLs.push("http://webt.lilang.com:9001" + imgs[i].replace("..", ""));
                        }//end for
                        wx.previewImage({
                            current: imgURLs[0], // 当前显示图片的http链接
                            urls: imgURLs // 需要预览的图片http链接列表
                        });
                        $(".mask").hide();
                    }
                }
            });
        }
    </script>
</body>
</html>
