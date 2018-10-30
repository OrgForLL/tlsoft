<%@ Page Title="商品信息汇总" Language="C#" MasterPageFile="../../WebBLL/frmQQDBase.Master" AutoEventWireup="true" %>

<%@ MasterType VirtualPath="../../WebBLL/frmQQDBase.Master" %>

<%@ Import Namespace="nrWebClass" %>
<%@ Import Namespace="System.Data" %>
<%@ Import Namespace="System.Collections.Generic" %>
<script runat="server">
    public string ViewType = "";   //视图类型
    public string AuthOptionCollect = "";   //选择栏
    public string SeasonOptionCollect = ""; //开发编号
    public int roleID = 0;
    protected void Page_PreRender(object sender, EventArgs e)
    {
        ViewType = Convert.ToString(Request.Params["ViewType"]);
        if (ViewType == null || ViewType == "") ViewType = "sphh";

        //clsWXHelper.CheckQQDMenuAuth(21);    //检查菜单权限21-商品信息汇总

        string optionBase = "<option value=\"{0}\" data-ssid={3} {2} >{1}</option>";
        string opselect = " selected";
        StringBuilder sbCompany = new StringBuilder();
        roleID = Convert.ToInt32(Session["RoleID"]);
        //1-店员 2-店长 3-总部管理角色 4-贸易公司角色 99-开发人员
        if (roleID == 4)
        {
            //获取当前用户的身份。默认会自动选中第一个项
            using (DataTable dt = clsWXHelper.GetQQDAuth(true, false))
            {
                DataRow dr;
                for (int i = 0; i < dt.Rows.Count; i++)
                {
                    dr = dt.Rows[i];

                    sbCompany.AppendFormat(optionBase, dr["khid"], dr["mdmc"], "",dr["ssid"]);
                }

                if (dt.Rows.Count == 0) sbCompany.AppendFormat(optionBase, "-1", "您还没有授权，请联系总部IT", opselect, ""); ;
            }
        }
        else if (roleID < 3 && roleID > 0)
        {
            if (ViewType == "kh") ViewType = "md";  //门店职员 如果访问 “客户”则强制切回门店

            string dbConn = clsConfig.GetConfigValue("OAConnStr");            
            using (LiLanzDALForXLM dal = new LiLanzDALForXLM(dbConn))
            {
                object objmdKhid = "";
                string strSQL = string.Concat(@"SELECT TOP 1 CONVERT(VARCHAR(10),khid) + '|' + mdmc 
                                        FROM t_mdb WHERE mdid = ", Session["mdid"]);
                string strInfo = dal.ExecuteQueryFast(strSQL, out objmdKhid);
                if (strInfo == "")
                {
                    string[] mdinfo = Convert.ToString(objmdKhid).Split('|');
                    if (mdinfo.Length == 2) sbCompany.AppendFormat(optionBase, mdinfo[0], mdinfo[1], opselect, "");
                    else sbCompany.AppendFormat(optionBase, "-1", "门店人资权限错误！请联系总部IT", opselect, "");
                }
            }//end using            
        }
        else
        {
            sbCompany.AppendFormat(optionBase, "", "完整权限", opselect, "");
        }
                
        AuthOptionCollect = sbCompany.ToString();
        SeasonCollect();
        sbCompany.Length = 0;
    }

    //必须在内容页的Load中对Master.SystemID 进行赋值；
    protected void Page_Load(object sender, EventArgs e)
    {
        this.Master.IsTestMode = false;
    }

    public void SeasonCollect()
    {
        string dbConn = clsConfig.GetConfigValue("OAConnStr");
        using (LiLanzDALForXLM dal = new LiLanzDALForXLM(dbConn)) {
            string _sql = "select top 5 dm,mc from yf_t_kfbh where jzrq is not null order by dm desc";
            StringBuilder sbSeacon = new StringBuilder();
            string optionBase = "<div class=\"fitem {2}\" dm=\"{0}\">{1}</div>";            
            DataTable dt;
            string errinfo = dal.ExecuteQuery(_sql, out dt);
            if (errinfo == "") {
                for (int i = 0; i < dt.Rows.Count; i++) {
                    if (i == 0)
                        sbSeacon.AppendFormat(optionBase, Convert.ToString(dt.Rows[i]["dm"]), Convert.ToString(dt.Rows[i]["mc"]), " selected");
                    else
                        sbSeacon.AppendFormat(optionBase, Convert.ToString(dt.Rows[i]["dm"]), Convert.ToString(dt.Rows[i]["mc"]), "");
                }//end for
            }            
            SeasonOptionCollect = sbSeacon.ToString();
            sbSeacon.Length = 0;
            dt.Clear(); dt.Dispose();
        }     
    }
</script>

<asp:Content ID="Content1" ContentPlaceHolderID="head" runat="server">
    <meta charset="utf-8" />
    <meta name="viewport" content="width=device-width,initial-scale=1,user-scalable=0,maximum-scale=1" />
    <meta name="format-detection" content="telephone=no" />
    <meta name="apple-mobile-web-app-capable" content="yes" />
    <meta name="apple-mobile-web-app-status-bar-style" content="black" />
    <link type="text/css" rel="stylesheet" href="../../res/css/LeePageSlider.css" />
    <link type="text/css" rel="stylesheet" href="../../res/css/font-awesome.min.css" />
    <link type="text/css" rel="stylesheet" href="../../res/css/storesaler/spzhcx_style.css" />
    <title>商品信息汇总</title>
    <style type="text/css">
        .data-container {
            position: absolute;
            top: 0;
            bottom: 40px;
            left: 0;
            width: 100%;
            overflow-y: auto;
            overflow-y: auto;
            -webkit-overflow-scrolling: touch;
            overflow-scrolling: touch;
        }

        .static_count {
            position: absolute;
            left: 0;
            width: 100%;
            bottom: 0;
            height: 40px;
            background-color: #1cc1c7;
            background-color: #f9f9f9;
            border-top: 1px solid #dedede;
            line-height: 40px;
            overflow: hidden;
        }

            .static_count li {
                float: left;
            }

        .col2 {
            text-align: right;
            width: 20%;
            font-size: 14px;
        }

        .static_count .col4 {
            text-align: center;
            font-weight: bold !important;
            font-size: 14px;
        }

        p.data-item[hidden] {
            display: none;
        }

        /*sphhcmmx style*/
        #sphhcmmx {
            background-color: transparent;
            height: 300px;
            padding: 0;
            bottom: 0;
            top: initial;
            z-index: 2002;
        }

        .sphhcmul {
            background-color: #f5f5f5;
            height: 100%;
            width: 100%;
            overflow-x: hidden;
            overflow-y: auto;
            border-top: 1px solid #efefef;
            padding-top: 10px;
        }

            .sphhcmul li {
                width: 17%;
                height: 50px;
                float: left;
                margin-left: 2.5%;
                margin-bottom: 10px;
            }

        .cmdm {
            background-color: #1cc1c7;
            color: #fff;
        }

        .cmsl {
            background-color: #fff;
        }

        .sphhcmul li p {
            line-height: 25px;
            text-align: center;
        }

        #close-cmmx {
            position: absolute;
            bottom: 5px;
            margin-left: 50%;
            transform: translate(-50%,0);
            -webkit-transform: translate(-50%,0);
            color: #1cc1c7;
            border: 1px solid #1cc1c7;
            width: 46px;
            height: 46px;
            line-height: 44px;
            border-radius: 50%;
            text-align: center;
        }

        .viewicon {
            position: absolute;
            height: 44px;
            top: 0;
            left: 40px;
            padding: 2px 5px;
            line-height: 20px;
            font-size: 14px;
            color: #fff;
            z-index: 100;
        }

        .fa-retweet {
            font-size: 16px;
        }

        .searchdiv {
            padding-left: 80px;
        }

        .viewtype, .column-show {
            position: fixed;
            top: 60px;
            left: 10px;
            z-index: 2000;
            background-color: rgb(71,71,71);
            color: #fff;
            font-size: 14px;
            font-weight: bold;
            display: none;
            z-index: 2002;
        }

        .column-show {
            top: 90px;
            right: 10px;
            left: initial;
        }

            .column-show .fa-check-square {
                padding: 0 5px 0 0;
                color: #777;
            }

            .viewtype:before, .viewtype:after, .column-show:before, .column-show:after {
                content: "";
                width: 0px;
                height: 0px;
                position: absolute;
                top: -20px;
                left: 50px;
                border: 10px solid transparent;
                border-bottom-color: rgb(71,71,71);
            }

            .column-show:before, .column-show:after {
                right: 0;
                left: initial;
            }

            .viewtype li, .column-show li {
                text-align: center;
                width: 100px;
                height: 40px;
                line-height: 40px;
                position: relative;
            }

                .viewtype li:not(:last-child), .column-show li:not(:last-child) {
                    border-bottom: 1px solid #888;
                }

        .back-image {
            background-repeat: no-repeat;
            background-size: cover;
            width: 20px;
            height: 20px;
            position: absolute;
            top: 9px;
            left: 25px;
        }

        .viewtype li span {
            padding-left: 20px;
        }

        .fa-check-square {
            font-size: 16px;
            padding: 5px 10px;
        }

        .active {
            color: #1cc1c7 !important;
        }

        .date input[type=date] {
            color: #ccc;
        }

        .col15 {
            width: 15%;
            text-align: right;
        }

        .filterInfo .fa-eye {
            width: 48px;
            height: 40px;
            line-height: 40px;
            text-align: center;
            color: #1cc1c7;
            position: absolute;
            top: 0;
            right: 0;
            font-size: 20px;
        }
    </style>
</asp:Content>

<asp:Content ID="Content2" ContentPlaceHolderID="ContentPlaceHolder1" runat="server">
    <ul class="viewtype">
        <li dm="kh">
            <div class="back-image" style="background-image: url(../../res/img/spxx-icon.png)"></div>
            <span>客户</span>
        </li>
        <li dm="lb">
            <div class="back-image" style="background-image: url(../../res/img/spxx-icon.png); background-position: 0 -27px;"></div>
            <span>类别</span>
        </li>
        <li dm="sphh">
            <div class="back-image" style="background-image: url(../../res/img/spxx-icon.png); background-position: 0 -52px;"></div>
            <span>货号</span>
        </li>
    </ul>
    <!--列显示选择-->
    <ul class="column-show">
        <li col="ddsl">
            <i class="fa fa-check-square active"></i>
            <span>订单数</span>
        </li>
        <li col="xssl">
            <i class="fa fa-check-square active"></i>
            <span>销售数</span>
        </li>
        <li col="zzl">
            <i class="fa fa-check-square active"></i>
            <span>周转量</span>
        </li>
        <li col="bhl">
            <i class="fa fa-check-square active"></i>
            <span>备货库存</span>
        </li>
        <li col="wcl">
            <i class="fa fa-check-square"></i>
            <span>完成率</span>
        </li>
    </ul>

    <div class="header">
        <div class="wrapSearch">
            <i class="fa fa-angle-left fa-2x" onclick="BackFunc();"></i>
            <div class="viewicon" onclick="SwitchPanel('.viewtype')">
                <i class="fa fa-retweet">
                    <br />
                </i>
                <p>方式</p>
            </div>
            <div class="searchdiv">
                <input id="searchinput" type="text" placeholder="搜索货号" />
                <i class="fa fa-search"></i>
            </div>
            <div class="filterdiv">
                <i class="fa fa-filter">
                    <br />
                </i>
                <p>筛选</p>
            </div>
        </div>
        <div class="filterInfo">
            <div style="padding-right: 40px; position: relative;">
                <select id="comlist">
                    <%=AuthOptionCollect %>
                </select>
                <i class="fa fa-angle-down"></i>
            </div>
            <div class="filters"></div>
            <i class="fa fa-eye" onclick="SwitchPanel('.column-show')"></i>
        </div>
    </div>
    <div class="wrap-page">
        <!--贸易公司数据页-->
        <div class="page page-not-header" id="kh">
            <div class="data-container">
                <ul class="data-ul floatfix">
                    <li class="item-head">
                        <p class="data-item col4" col="kh">代码</p>
                        <p class="data-item" col="ddsl">订单数</p>
                        <p class="data-item" col="xssl">销售数</p>
                        <p class="data-item" col="wcl">完成率%</p>
                    </li>
                </ul>
            </div>
            <div class="static_count">
                <ul class="floatfix">
                    <li class="col4">合 计</li>
                    <li class="col2" col="s-ddsl">--</li>
                    <li class="col2" col="s-xssl">--</li>
                </ul>
            </div>
        </div>
        <!--专卖店数据页-->
        <div class="page page-not-header page-right" id="md">
            <div class="data-container">
                <ul class="data-ul floatfix">
                    <li class="item-head">
                        <p class="data-item col4" col="md">专卖店</p>
                        <p class="data-item" col="ddsl">订单数</p>
                        <p class="data-item" col="xssl">销售数</p>
                        <p class="data-item" col="wcl">完成率%</p>
                    </li>
                </ul>
            </div>
            <div class="static_count">
                <ul class="floatfix">
                    <li class="col4">合 计</li>
                    <li class="col2" col="s-ddsl">--</li>
                    <li class="col2" col="s-xssl">--</li>
                </ul>
            </div>
        </div>
        <!--类别数据页-->
        <div class="page page-not-header page-right" id="lb">
            <div class="data-container">
                <ul class="data-ul floatfix">
                    <li class="item-head">
                        <p class="data-item col4" col="lb">类别</p>
                        <p class="data-item col15" col="ddsl">订单数</p>
                        <p class="data-item col15" col="xssl">销售数</p>
                        <p class="data-item col15" col="wcl" hidden>完成率%</p>
                        <p class="data-item col15" col="zzl">周转量</p>
                        <p class="data-item col15" col="bhl">备货库存</p>
                    </li>
                </ul>
            </div>
            <div class="static_count">
                <ul class="floatfix">
                    <li class="col4">合 计</li>
                    <li class="col15" col="s-ddsl">--</li>
                    <li class="col15" col="s-xssl">--</li>
                    <li class="col15" col="s-wcl" hidden>--</li>
                    <li class="col15" col="s-zzl">--</li>
                    <li class="col15" col="s-bhl">--</li>
                </ul>
            </div>
        </div>
        <!--货号数据页-->
        <div class="page page-not-header page-right" id="sphh">
            <div class="data-container">
                <ul class="data-ul floatfix">
                    <li class="item-head">
                        <p class="data-item col4" col="sphh">货号</p>
                        <p class="data-item col15" col="ddsl">订单数</p>
                        <p class="data-item col15" col="xssl">销售数</p>
                        <p class="data-item col15" col="wcl" hidden>完成率</p>
                        <p class="data-item col15" col="zzl">周转量</p>
                        <p class="data-item col15" col="bhl">备货库存</p>
                    </li>
                </ul>
            </div>
            <div class="static_count">
                <ul class="floatfix">
                    <li class="col4">合 计</li>
                    <li class="col15" col="s-ddsl">--</li>
                    <li class="col15" col="s-xssl">--</li>
                    <li class="col15" col="s-wcl" hidden>--</li>
                    <li class="col15" col="s-zzl">--</li>
                    <li class="col15" col="s-bhl">--</li>
                </ul>
            </div>
        </div>
        <!--货号尺码信息显示页-->
        <div class="page page-bot" id="sphhcmmx">
            <ul class="sphhcmul">
            </ul>
            <i id="close-cmmx" class="fa fa-remove (alias) fa-2x" onclick="javascript:$('#sphhcmmx').addClass('page-bot');$('.mymask').hide();"></i>
        </div>
        <!--右侧筛选页-->
        <div class="page page-right" id="fiterpage">
            <div class="filtercontainer">
                <!--开发编号-->
                <div class="farea floatfix" filter="kfbh">
                    <p class="title">开发编号</p>
<%--                    <div class="fitem selected" dm="20161">2016年春季产品</div>
                    <div class="fitem" dm="20162">2016年夏季产品</div>
                    <div class="fitem" dm="20163">2016年秋季产品</div>
                    <div class="fitem" dm="20164">2016年冬季产品</div>--%>
                    <%=SeasonOptionCollect %>
                </div>
                <!--日期范围-->
                <div class="farea" style="border-top: 1px solid #e2e2e2; margin-bottom: 15px;">
                    <p class="title">日期范围 <i class="fa fa-check-square" id="rq-switch"></i></p>
                    <div class="date" filter="rq">
                        <input type="date" id="ksrq" readonly="true" />
                        <div class="line"></div>
                        <input type="date" id="jsrq" readonly="true" />
                    </div>
                </div>
                <!--客户类别-->
                <div class="farea fkhlb floatfix" style="border-top: 1px solid #e2e2e2;" filter="khlb">
                    <p class="title">客户类别</p>
                    <div class="fitem" cs="zh">综合套帐</div>
                    <div class="fitem" cs="lh">领航套帐</div>
                    <div class="fitem" cs="0">总部套帐</div>
                    <div class="fitem" cs="xf">领航营销</div>
                    <div class="fitem" cs="xd">市场管理中心</div>
                    <div class="fitem" cs="xz">自营专卖店</div>
                    <div class="fitem" cs="xg">直营大客户</div>
                    <div class="fitem" cs="xj">加盟门店</div>
                    <div class="fitem" cs="xq">其他客户</div>
                    <div class="fitem" cs="xy">区域代理</div>
                    <div class="fitem" cs="xl">历史客户</div>
                </div>
            </div>
            <div class="fbtns">
                <a href="javascript:ResetFilter()">重置</a>
                <a href="javascript:SubmitFilter()" style="background-color: #1cc1c7; color: #fff;">完成</a>
            </div>
        </div>
    </div>
    <div class="footer">
        <ul class="footer-ul floatfix">
            <li class="data-item total">合计</li>
            <li class="data-item" col="s-ddsl">--</li>
            <li class="data-item" col="s-xssl">--</li>
            <li class="data-item"></li>
        </ul>
    </div>
    <div class="mymask"></div>

    <script type="text/javascript" src="../../res/js/jquery.js"></script>
    <script type="text/javascript" src="../../res/js/storesaler/fastclick.min.js"></script>
    <script type="text/javascript" src="../../res/js/LeeJSUtils.min.js"></script>
    <script type="text/javascript" src="../../res/js/template.js"></script>

    <!--模板区-->
    <!--贸易公司-->
    <script id="datali_1" type="text/html">
        <li khid="{{khid}}" khfl="{{khfl}}">
            <p class="data-item col4 underline" col="khmc">{{khdm}}.{{khmc}}</p>
            <p class="data-item num underline" col="ddsl">{{ddsl}}</p>
            <p class="data-item" col="xssl">{{xssl}}</p>
            <p class="data-item" col="wcl">{{wcl}}</p>
        </li>
    </script>

    <!--门店-->
    <script id="datali_2" type="text/html">
        <li mdid="{{khid}}">
            <p class="data-item col4">{{khmc}}</p>
            <p class="data-item num underline" col="ddsl">{{ddsl}}</p>
            <p class="data-item" col="xssl">{{xssl}}</p>
            <p class="data-item" col="wcl">{{wcl}}</p>
        </li>
    </script>

    <!--商品货号-->
    <script id="datali_3" type="text/html">
        <li>
            <p class="data-item col4 underline" col="sphh">{{sphh}}.{{spmc}}</p>
            <p class="data-item num col15 underline" col="ddsl">{{ddsl}}</p>
            <p class="data-item col15" col="xssl">{{xssl}}</p>
            <p class="data-item col15" col="wcl" hidden>{{wcl}}</p>
            <p class="data-item underline col15" col="zzl">{{zzl}}</p>
            <p class="data-item underline col15" col="bhl">{{bhl}}</p>
        </li>
    </script>

    <!--商品类别-->
    <script id="datali_4" type="text/html">
        <li lbid="{{lbid}}">
            <p class="data-item col4 underline" col="splb">{{lbmc}}</p>
            <p class="data-item num col15" col="ddsl">{{ddsl}}</p>
            <p class="data-item col15" col="xssl">{{xssl}}</p>
            <p class="data-item col15" col="wcl">{{wcl}}</p>
            <p class="data-item col15" col="zzl">{{zzl}}</p>
            <p class="data-item col15" col="bhl">{{bhl}}</p>
        </li>
    </script>

    <!--尺码明细-->
    <script id="cmmx" type="text/html">
        <li>
            <p class="cmdm">{{cmdm}}</p>
            <p class="cmsl">{{cmsl}}</p>
        </li>
    </script>

    <script type="text/javascript">
        var defaultSite = "<%=ViewType%>", CurrentSite = "", ViewRoute = defaultSite;
        var roleID = "<%=roleID%>";
        var filter = {
            "lx": defaultSite,
            "khid": "",
            "mdid": "",
            "sphh": "",
            "lbid": "",
            "kfbh": "20161",
            "ksrq": "",
            "jsrq": "",
            "khlb": "",
            "roleid": "",
            "curkhid": "",
            "curkhfl": "",
            "order": { "col": "", "direc": "" }
        };

        $(document).ready(function () {
            FastClick.attach(document.body);
            LeeJSUtils.LoadMaskInit();
            LeeJSUtils.stopOutOfPage(".filtercontainer", true);
            $("#ksrq").val(new Date().format("yyyy-MM") + "-01");
            $("#jsrq").val(new Date().format("yyyy-MM-dd"));

            var vt = LeeJSUtils.GetQueryParams("ViewType");
            if (vt != "") {
                defaultSite = vt;
                ViewRoute = defaultSite;
                filter.lx = defaultSite;
            }
            //gotoSearch();
            InitPage();
        });

        function InitPage() {
            var _filter = localStorage.getItem("spzhcx-filter");
            if (_filter != null && _filter != "") {
                _obj = JSON.parse(_filter);
                $("div[filter='kfbh'] .selected").removeClass("selected");
                $("div[filter='kfbh'] .fitem[dm='" + _obj.kfbh + "']").addClass("selected");
                filter.kfbh = _obj.kfbh;
            }
            gotoSearch();
        }

        //按贸易公司汇总
        function LoadDataMain() {
            LeeJSUtils.showMessage("loading", "正在汇总数据...");
            var ordercol = filter.order.col;
            if (ordercol == "zzl" || ordercol == "bhl" || CurrentSite != "kh")
                filter.order.col = "";
            $.ajax({
                type: "POST",
                timeout: 20000,
                contentType: "application/x-www-form-urlencoded; charset=utf-8",
                url: "ZHCXCore_beta.aspx",
                data: { ctrl: "GetDHData", filters: JSON.stringify(filter) },
                success: function (msg) {
                    RollBack("clear");
                    if (msg.indexOf("Error:") == -1 && msg != "") {
                        var datas = JSON.parse(msg);
                        var len = datas.rows.length;
                        var html = "";
                        for (var i = 0; i < len; i++) {
                            row = datas.rows[i];
                            html += template("datali_1", row);
                        }//end for

                        $("#kh .data-ul li:not(:first-child)").remove();
                        $("#kh .data-ul").append(html);
                        openView("kh");

                        $("#kh .data-ul li:not(:first-child) p[col='khmc']").bind("click", function () {
                            RollBack("write");
                            filter.lx = "md";
                            filter.khid = $(this).parent().attr("khid");
                            filter.curkhfl = $(this).parent().attr("khfl");
                            gotoSearch();//LoadZMData();
                        });

                        $("#kh .data-ul li:not(:first-child) p[col='ddsl']").bind("click", function () {
                            RollBack("write");
                            filter.lx = "lb";
                            filter.khid = $(this).parent().attr("khid");
                            gotoSearch();//LoadSPLBData();
                        });

                        StaticCount("kh");
                        $("#leemask").hide();
                    } else if (msg == "") {
                        $("#kh .data-ul li:not(:first-child)").remove();
                        LeeJSUtils.showMessage("warn", "查询无结果！");
                        ClearStatics("kh");
                    } else
                        $("#leemask").hide();
                },
                error: function (XMLHttpRequest, textStatus, errorThrown) {
                    RollBack("read");
                    LeeJSUtils.showMessage("error", "网络连接失败！");
                }
            });//end AJAX
        }

        //商品类别汇总
        function LoadSPLBData() {
            LeeJSUtils.showMessage("loading", "正在汇总数据...");
            if (CurrentSite != "lb")
                filter.order.col = "";
            setTimeout(function () {
                $.ajax({
                    type: "POST",
                    timeout: 20000,
                    contentType: "application/x-www-form-urlencoded; charset=utf-8",
                    url: "ZHCXCore_beta.aspx",
                    data: { ctrl: "GetDHData", filters: JSON.stringify(filter) },
                    success: function (msg) {
                        RollBack("clear");
                        if (msg.indexOf("Error:") == -1 && msg != "") {
                            var datas = JSON.parse(msg);
                            var len = datas.rows.length;
                            var html = "";
                            for (var i = 0; i < len; i++) {
                                var row = datas.rows[i];
                                html += template("datali_4", row);
                            }//end for
                            $("#lb .data-ul li:not(:first-child)").remove();
                            $("#lb .data-ul").append(html);
                            openView("lb");

                            //remove后事件会一起删掉
                            $("#lb .data-ul li:not(:first-child) p[col='splb']").bind("click", function () {
                                RollBack("write");
                                filter.lx = "sphh";
                                filter.lbid = $(this).parent().attr("lbid");
                                gotoSearch();//LoadSPHHData();
                            });

                            $("#lb").removeClass("page-right");

                            StaticCount("lb");
                            $("#leemask").hide();
                        } else if (msg == "") {
                            $("#lb .data-ul li:not(:first-child)").remove();
                            LeeJSUtils.showMessage("warn", "查询无结果！");
                            ClearStatics("lb");
                        } else
                            $("#leemask").hide();
                    },
                    error: function (XMLHttpRequest, textStatus, errorThrown) {
                        RollBack("read");
                        LeeJSUtils.showMessage("error", "网络连接失败！");
                    }
                });//end AJAX
            }, 50);
        }

        //商品货号
        function LoadSPHHData() {
            LeeJSUtils.showMessage("loading", "正在汇总数据...");
            if (CurrentSite != "sphh")
                filter.order.col = "";
            setTimeout(function () {
                $.ajax({
                    type: "POST",
                    timeout: 20000,
                    contentType: "application/x-www-form-urlencoded; charset=utf-8",
                    url: "ZHCXCore_beta.aspx",
                    data: { ctrl: "GetDHData", filters: JSON.stringify(filter) },
                    success: function (msg) {
                        RollBack("clear");
                        if (msg.indexOf("Error:") == -1 && msg != "") {
                            var datas = JSON.parse(msg);
                            var len = datas.rows.length;
                            var html = "";
                            for (var i = 0; i < len; i++) {
                                var row = datas.rows[i];
                                html += template("datali_3", row);
                            }//end for
                            $("#sphh .data-ul li:not(:first-child)").remove();
                            $("#sphh .data-ul").append(html);
                            openView("sphh");

                            //点击货号跳转到该货号对应的详情页                            
                            $("#sphh .data-ul li:not(:first-child) p[col='sphh']").bind("click", function () {
                                var sphh = $(this).text().split(".")[0].trim();
                                window.location.href = "goodsListV3.aspx?showType=1&sphh=" + sphh;
                            });

                            //点击订单数进行相应的钻取                            
                            $("#sphh .data-ul li:not(:first-child) p[col='ddsl']").bind("click", function () {
                                RollBack("write");
                                filter.lx = "kh";
                                $("#searchinput").val($(this).prev().text().split(".")[0]);
                                gotoSearch();
                            });

                            //周转量                            
                            $("#sphh .data-ul li:not(:first-child) p[col='zzl']").bind("click", function () {
                                var val = $(this).text();
                                if (val == "" || val == "0")
                                    return;
                                var sphh = $("p:first-child", $(this).parent()).text().split(".")[0];
                                GetSphhCmmx("zzl", sphh);
                            });

                            //备货量                            
                            $("#sphh .data-ul li:not(:first-child) p[col='bhl']").bind("click", function () {
                                var val = $(this).text();
                                if (val == "" || val == "0")
                                    return;
                                var sphh = $("p:first-child", $(this).parent()).text().split(".")[0];
                                GetSphhCmmx("bhl", sphh);
                            });

                            $("#sphh").removeClass("page-right");

                            StaticCount("sphh");
                            $("#leemask").hide();
                        } else if (msg == "") {
                            $("#sphh .data-ul li:not(:first-child)").remove();
                            LeeJSUtils.showMessage("warn", "查询无结果！");
                            ClearStatics("sphh");
                        } else
                            $("#leemask").hide();
                    },
                    error: function (XMLHttpRequest, textStatus, errorThrown) {
                        RollBack("clear");
                        LeeJSUtils.showMessage("error", "网络连接失败！");
                    }
                });//end AJAX
            }, 50);
        }

        //门店
        function LoadZMData() {
            LeeJSUtils.showMessage("loading", "正在汇总数据...");
            var ordercol = filter.order.col;
            if (ordercol == "zzl" || ordercol == "bhl" || CurrentSite != "md")
                filter.order.col = "";
            $.ajax({
                type: "POST",
                timeout: 20000,
                contentType: "application/x-www-form-urlencoded; charset=utf-8",
                url: "ZHCXCore_beta.aspx",
                data: { ctrl: "GetDHData", filters: JSON.stringify(filter) },
                success: function (msg) {
                    RollBack("clear");
                    if (msg.indexOf("Error:") == -1 && msg != "") {
                        var datas = JSON.parse(msg);
                        var len = datas.rows.length;
                        var html = "";
                        for (var i = 0; i < len; i++) {
                            var row = datas.rows[i];
                            html += template("datali_2", row);
                        }//end for
                        $("#md .data-ul li:not(:first-child)").remove();
                        $("#md .data-ul").append(html);
                        openView("md");

                        $("#md .data-ul li:not(:first-child) p[col='ddsl']").bind("click", function () {
                            filter.lx = "lb";
                            filter.mdid = $(this).parent().attr("mdid");
                            gotoSearch();//LoadSPLBData();
                        });

                        $("#md").removeClass("page-right");

                        StaticCount("md");
                        $("#leemask").hide();
                    } else if (msg == "") {
                        $("#md .data-ul li:not(:first-child)").remove();
                        LeeJSUtils.showMessage("warn", "查询无结果！");
                        ClearStatics("md");
                    } else
                        $("#leemask").hide();
                },
                error: function (XMLHttpRequest, textStatus, errorThrown) {
                    RollBack("read");
                    LeeJSUtils.showMessage("error", "网络连接失败！");
                }
            });//end AJAX
        }

        function GetSphhCmmx(type, sphh) {
            LeeJSUtils.showMessage("loading", "正在加载尺码信息..");
            $.ajax({
                type: "POST",
                timeout: 20 * 1000,
                contentType: "application/x-www-form-urlencoded; charset=utf-8",
                url: "ZHCXCore_beta.aspx",
                data: { ctrl: "sphhcmmx", type: type, sphh: sphh },
                success: function (msg) {
                    if (msg == "Error:") {
                        $(".sphhcmul").empty();
                        LeeJSUtils.showMessage("warn", "查询无结果！");
                    } else {
                        var datas = JSON.parse(msg);
                        var len = datas.rows.length;
                        var html = "";
                        for (var i = 0; i < len; i++) {
                            var row = datas.rows[i];
                            html += template("cmmx", row);
                        }//end for
                        $(".sphhcmul").empty().append(html)
                        $("#leemask").hide();
                        $(".mymask").show();
                        $("#sphhcmmx").removeClass("page-bot");
                    }
                },
                error: function (XMLHttpRequest, textStatus, errorThrown) {
                    LeeJSUtils.showMessage("error", "网络连接失败！");
                }
            });//end AJAX
        }

        $(".filterdiv").on("click", function () {
            $(".mymask").show();
            $("#fiterpage").removeClass("page-right");
        })

        $(".mymask").on("click", function () {
            $("#fiterpage").addClass("page-right");
            $("#sphhcmmx").addClass("page-bot");
            $(".column-show").hide();
            $(".viewtype").hide();
            $(".mymask").hide();
        })

        //重置
        function ResetFilter() {
            $("#ksrq").val("2015-03-01");
            $("#jsrq").val("2016-03-01");
            $(".date input[type=date]").css("color", "#ccc").attr("readonly", "true");
            $("#rq-switch").removeClass("active");
            $("div[filter='khlb'] .fitem.selected").removeClass("selected");
            $("div[filter='kfbh'] .fitem[dm='20161']").addClass("selected");
        }

        //筛选提交
        function SubmitFilter() {
            var kfbh = $("div[filter='kfbh'] .fitem.selected").attr("dm");
            var khlb = $("div[filter='khlb'] .fitem.selected").attr("cs");
            var ksrq = "", jsrq = "";

            if ($("#rq-switch").hasClass("active")) {
                ksrq = $("#ksrq").val();
                jsrq = $("#jsrq").val();
            }

            filter.khlb = khlb == undefined ? "" : khlb;
            filter.kfbh = kfbh == undefined ? "20161" : kfbh;
            filter.ksrq = ksrq; filter.jsrq = jsrq;

            $("#fiterpage").addClass("page-right");
            $(".mymask").hide();
            gotoSearch();
        }

        //返回动作
        function BackFunc() {
            if (ViewRoute == CurrentSite)
                return;
            //清除当前视图的排序
            $("#" + CurrentSite + " .item-head .sorted").removeAttr("sort").removeClass("sorted");
            $("#" + CurrentSite + " .item-head i").remove();
            switch (CurrentSite) {
                case "md":
                    $("#md").addClass("page-right");
                    ViewRoute = ViewRoute.substring(0, ViewRoute.lastIndexOf("-md"));
                    CurrentSite = ViewRoute.substring(ViewRoute.lastIndexOf("-") + 1);
                    break;
                case "lb":
                    $("#lb").addClass("page-right");
                    ViewRoute = ViewRoute.substring(0, ViewRoute.lastIndexOf("-lb"));
                    CurrentSite = ViewRoute.substring(ViewRoute.lastIndexOf("-") + 1);
                    break;
                case "sphh":
                    $("#sphh").addClass("page-right");
                    ViewRoute = ViewRoute.substring(0, ViewRoute.lastIndexOf("-sphh"));
                    CurrentSite = ViewRoute.substring(ViewRoute.lastIndexOf("-") + 1);
                    break;
                case "kh":
                    $("#kh").addClass("page-right");
                    ViewRoute = ViewRoute.substring(0, ViewRoute.lastIndexOf("-kh"));
                    CurrentSite = ViewRoute.substring(ViewRoute.lastIndexOf("-") + 1);
                    break;
            }//end switch

            //返回时应清空对应参数 否则会影响到上一级的搜索功能
            if (CurrentSite != "") {
                $("#" + CurrentSite).removeClass("page-right");
                filter.lx = CurrentSite;
                switch (CurrentSite) {
                    case "md":
                        filter.mdid = "";
                        break;
                    case "lb":
                        filter.lbid = "";
                        break;
                    case "sphh":
                        $("#searchinput").val("");
                        filter.sphh = "";
                        break;
                    case "kh":
                        filter.khid = "";
                        filter.curkhfl = "";
                        break;
                } //end switch		
                filter.order.col = "";
                ColumnShowRelate(CurrentSite);
            }
        }

        //计算合计值
        function StaticCount(id) {
            var s_ddsl = 0, s_lssl = 0, s_zzl = 0, s_bhl = 0;
            var ulobj = $("#" + id + " .data-ul li");
            for (var i = 1; i < ulobj.length; i++) {
                var row = ulobj.eq(i);
                var ddsl = ($("p[col='ddsl']", row).text());
                var lssl = ($("p[col='xssl']", row).text());
                if (ddsl == "")
                    ddsl = "0";
                if (lssl == "")
                    lssl = "0";
                if (CurrentSite == "sphh" || CurrentSite == "lb") {
                    var zzl = ($("p[col='zzl']", row).text());
                    var bhl = ($("p[col='bhl']", row).text());
                    zzl = zzl == "" ? "0" : zzl;
                    bhl = bhl == "" ? "0" : bhl;
                    s_zzl += parseInt(zzl);
                    s_bhl += parseInt(bhl);
                }
                s_ddsl += parseInt(ddsl);
                s_lssl += parseInt(lssl);
            }//end for

            $("#" + id + " [col='s-ddsl']").text(GetJeText(s_ddsl));
            $("#" + id + " [col='s-xssl']").text(GetJeText(s_lssl));
            if (id == "sphh" || id == "lb") {
                $("#" + id + " [col='s-zzl']").text(GetJeText(s_zzl));
                $("#" + id + " [col='s-bhl']").text(GetJeText(s_bhl));
            }
        }

        //无结果时调用这方法清掉统计栏结果
        function ClearStatics(id) {
            $("#" + id + " [col='s-ddsl']").text("");
            $("#" + id + " [col='s-xssl']").text("");
            if (id == "sphh") {
                $("#" + id + " [col='s-zzl']").text("");
                $("#" + id + " [col='s-bhl']").text("");
            }
        }

        //日期格式化
        Date.prototype.format = function (format) {
            var o = {
                "M+": this.getMonth() + 1, //month 
                "d+": this.getDate(), //day 
                "h+": this.getHours(), //hour 
                "m+": this.getMinutes(), //minute 
                "s+": this.getSeconds(), //second 
                "q+": Math.floor((this.getMonth() + 3) / 3), //quarter 
                "S": this.getMilliseconds() //millisecond 
            }

            if (/(y+)/.test(format)) {
                format = format.replace(RegExp.$1, (this.getFullYear() + "").substr(4 - RegExp.$1.length));
            }

            for (var k in o) {
                if (new RegExp("(" + k + ")").test(format)) {
                    format = format.replace(RegExp.$1, RegExp.$1.length == 1 ? o[k] : ("00" + o[k]).substr(("" + o[k]).length));
                }
            }
            return format;
        }

        function GetJeText(xsje) {
            if (xsje == "") return "--";
            else {
                var intxsje = parseInt(xsje);

                if (intxsje < 100000) return intxsje;
                else return parseInt(intxsje * 0.0001).toString() + "万+";
            }
        }

        //合计结果格式化
        //function toThousands(num) {
        //    var result = '', counter = 0;
        //    num = (num || 0).toString();
        //    for (var i = num.length - 1; i >= 0; i--) {
        //        counter++;
        //        result = num.charAt(i) + result;
        //        if (!(counter % 3) && i != 0) { result = ',' + result; }
        //    }
        //    return result;
        //}

        //搜索按钮
        $(".fa-search").on("click", gotoSearch);

        //搜索函数
        function gotoSearch() {
            if ($("#comlist").val() == "-1")
                return;

            if (CheckViewRouteOK() == false) {
                LeeJSUtils.showMessage("warn", "已经钻取到最后一层啦！");
                filter.lx = CurrentSite;//回退变量否则会有问题                
                $("#searchinput").val("");
                return;
            }

            var SearchTxt = $("#searchinput").val();
            filter.sphh = SearchTxt;
            filter.roleid = "<%=roleID%>";
            filter.curkhid = $("#comlist").val();
            if (filter.curkhid == null) filter.curkhid = "";
            if (roleID < 3 && roleID > 0 && filter.lx == "kh") filter.lx = "md";

            switch (filter.lx) {
                case "kh":
                    LoadDataMain();
                    break;
                case "lb":
                    LoadSPLBData();
                    break;
                case "md":
                    LoadZMData();
                    break;
                case "sphh":
                    LoadSPHHData();
                    break;
            }//end switch

            //显示到外面
            var filterStr = "开发编号：" + $("div[filter='kfbh'] .fitem.selected").addClass("selected").text();
            if ($("#rq-switch").hasClass("active"))
                filterStr += " 日期：" + $("#ksrq").val() + "至" + $("#jsrq").val();
            if ($("div[filter='khlb'] .fitem.selected").length != 0)
                filterStr += " 客户类别：" + $("div[filter='khlb'] .fitem.selected").text();
            $(".filterInfo .filters").text(filterStr);
            localStorage.setItem("spzhcx-filter", JSON.stringify(filter));
        }

        //筛选相关事件绑定
        $("div[filter='kfbh'] .fitem").on("click", function () {
            $("div[filter='kfbh'] .selected").removeClass("selected");
            $(this).addClass("selected");
        });

        $("div[filter='khlb'] .fitem").on("click", function () {
            if ($(this).hasClass("selected"))
                $(this).removeClass("selected");
            else {
                $("div[filter='khlb'] .selected").removeClass("selected");
                $(this).addClass("selected");
            }
        });

        function SwitchPanel(selector) {
            var status = $(selector).css("display");
            if (status == "none") {
                $(".mymask").show();
                $(selector).fadeIn(200);
            }
            else {
                $(".mymask").hide();
                $(selector).fadeOut(200);
            }
        }

        //日期筛选条件是否生效
        $("#rq-switch").on("click", function () {
            if ($(this).hasClass("active")) {
                filter.ksrq = "";
                filter.jsrq = "";
                $(".date input").css("color", "#ccc").attr("readonly", "true");
                $(this).removeClass("active");
            } else {
                $(".date input").css("color", "#000").removeAttr("readonly");
                $(this).addClass("active");
            }
        });

        //不同视图的切换，选择使用地址跳转方便回退的时候
        $(".viewtype li").on("click", function () {
            var dm = $(this).attr("dm");
            var url = window.location.href;
            setUrlParam("ViewType", dm);
        });

        //列选择性显示
        $(".column-show li").on("click", function () {
            var col = $(this).attr("col");
            if (CurrentSite != "sphh" && CurrentSite != "lb" && (col == "zzl" || col == "bhl")) {
                alert("对不起，该功能只在【货号】和【类别】视图下才可使用！");
            } else {
                if ($("i", this).hasClass("active")) {
                    $("i", this).removeClass("active");
                    $("#" + CurrentSite + " li p[col='" + col + "']").hide();
                    $("#" + CurrentSite + " li[col='s-" + col + "']").hide();
                } else {
                    if ($(".column-show i.active").length >= 4) {
                        alert("对不起,最多只能显示5列数据！");
                        return;
                    }
                    $("i", this).addClass("active");
                    $("#" + CurrentSite + " li p[col='" + col + "']").show();
                    $("#" + CurrentSite + " li[col='s-" + col + "']").show();
                }
            }
        });

        function ColumnShowRelate(pageid) {
            var columns = $(".column-show li");
            for (var i = 0; i < columns.length; i++) {
                var col = columns.eq(i).attr("col");
                var display = $("#" + pageid + " .item-head p[col=" + col + "]").css("display");
                if (display == "block") {
                    $(".column-show li[col='" + col + "'] i").addClass("active");
                    $("#" + pageid + " li p[col='" + col + "']").show();
                    $("#" + pageid + " li[col='s-" + col + "']").show();
                }
                else {
                    $(".column-show li[col='" + col + "'] i").removeClass("active");
                    $("#" + pageid + " li p[col='" + col + "']").hide();
                    $("#" + pageid + " li[col='s-" + col + "']").hide();
                }
            }//end for
        }

        //控制页面的显示
        function openView(newView) {
            if (CurrentSite != newView) {
                //原先的页面移出
                if (CurrentSite != "") {
                    $("#" + CurrentSite).addClass("page-right");
                }
                CurrentSite = newView;
                if (ViewRoute != newView)
                    ViewRoute = ViewRoute + "-" + CurrentSite;
                $("#" + CurrentSite).removeClass("page-right");
            }

            ColumnShowRelate(CurrentSite);
        }

        //排序功能
        $(".item-head p").on("click", function () {
            var col = $(this).attr("col");
            var direc = $(this).attr("sort");
            if (direc == "desc")
                direc = "asc";
            else
                direc = "desc";
            filter.order.col = col;
            filter.order.direc = direc;
            var curpage = $("#" + CurrentSite);
            $(".item-head .sorted .fa", curpage).remove();
            $(".item-head .sorted", curpage).removeClass("sorted");
            $(this).addClass("sorted").attr("sort", direc);
            $("i", this).remove();
            $(this).append("<i class='fa fa-sort-" + direc + "'></i>");
            gotoSearch("Sort");
        });

        //检查视图路径,并返回路径是否重复
        function CheckViewRouteOK() {
            //ViewRoute.indexOf(filter.lx + "-") > -1
            if (ViewRoute.indexOf(filter.lx) == 0 && ViewRoute.length > 5) {
                return false;
            } else {
                return true;
            }
        }

        //para_name 参数名称 para_value 参数值 url所要更改参数的网址
        function setUrlParam(para_name, para_value) {
            var strNewUrl = new String();
            var strUrl = new String();
            var url = new String();
            url = window.location.href;
            strUrl = window.location.href;
            if (strUrl.indexOf("?") != -1) {
                strUrl = strUrl.substr(strUrl.indexOf("?") + 1);
                if (strUrl.toLowerCase().indexOf(para_name.toLowerCase()) == -1) {
                    strNewUrl = url + "&" + para_name + "=" + para_value;
                    window.location = strNewUrl;
                } else {
                    var aParam = strUrl.split("&");
                    for (var i = 0; i < aParam.length; i++) {
                        if (aParam[i].substr(0, aParam[i].indexOf("=")).toLowerCase() == para_name.toLowerCase()) {
                            aParam[i] = aParam[i].substr(0, aParam[i].indexOf("=")) + "=" + para_value;
                        }
                    }
                    strNewUrl = url.substr(0, url.indexOf("?") + 1) + aParam.join("&");
                    window.location = strNewUrl;
                }
            } else {
                strUrl += "?" + para_name + "=" + para_value;
                window.location = strUrl;
            }
        }

        function RollBack(mode) {
            if (mode == "write") {
                localStorage.setItem("tmp-CurrentSite", CurrentSite);
                localStorage.setItem("tmp-ViewRoute", ViewRoute);
                localStorage.setItem("tmp-filter", JSON.stringify(filter));
            } else if (mode == "read") {
                CurrentSite = localStorage.getItem("tmp-CurrentSite");
                ViewRoute = localStorage.getItem("tmp-ViewRoute");
                filter = JSON.parse(localStorage.getItem("tmp-filter"));
            } else {
                localStorage.removeItem("tmp-CurrentSite");
                localStorage.removeItem("tmp-ViewRoute");
                localStorage.removeItem("tmp-filter");
            }
        }
    </script>
</asp:Content>
