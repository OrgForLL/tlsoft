<%@ Page Title="客户提货销售对照分析" Language="C#" MasterPageFile="../../WebBLL/frmQQDBase.Master" AutoEventWireup="true" %>

<%@ MasterType VirtualPath="../../WebBLL/frmQQDBase.Master" %>

<%@ Import Namespace="nrWebClass" %>
<%@ Import Namespace="System.Data" %>
<%@ Import Namespace="System.Collections.Generic" %>

<script runat="server">
    /*子页面首先运行Page_Load，再运行主页面Page_Load；因此，只需要在子页面Page_Load事件中对Master.SystemID 进行赋值；
      主页面将会在其Page_Load事件中自动鉴权获取 AppSystemKey.之后请在子页面的Page_PreRender 或 JS中进行相关处理(比如：加载页面内容等)。
      请格外注意：万万不要在子页面的Load事件中直接使用用户的Session，因为Session是在主页面中获取的顺序在后，这将会导致异常！
    
         附：母版页和内容页的触发顺序    
         * 母版页控件 Init 事件。    
         * 内容控件 Init 事件。
         * 母版页 Init 事件。    
         * 内容页 Init 事件。    
         * 内容页 Load 事件。    
         * 母版页 Load 事件。    
         * 内容控件 Load 事件。    
         * 内容页 PreRender 事件。    
         * 母版页 PreRender 事件。    
         * 母版页控件 PreRender 事件。    
         * 内容控件 PreRender 事件。
     */

    public string ViewType = "";   //视图类型
    public string AuthOptionCollect = "", SeasonOptionCollect = "";   //选择栏
    public string KhClassOptionCollect = ""; //客户类别
    public string roleName = "";
    public int roleID = 0;
    private string optionBase = "<option value=\"{0}\" {2} data-ssid={3}>{1}</option>";
    protected void Page_PreRender(object sender, EventArgs e)
    {
        ViewType = Convert.ToString(Request.Params["ViewType"]);
        if (ViewType == null || ViewType == "") ViewType = "kh";

        clsWXHelper.CheckQQDMenuAuth(22);    //检查菜单权限

        string opselect = " selected";
        StringBuilder sbCompany = new StringBuilder();
        roleID = Convert.ToInt32(Session["RoleID"]);
        roleName = Convert.ToString(Session["RoleName"]);

        DataTable dt = null;
        if (roleID == 4)
        {
            //获取当前用户的身份。默认会自动选中第一个项
            dt = clsWXHelper.GetQQDAuth();
            calCompany(ref dt, ref sbCompany);

        }
        else if (roleID < 3 && roleID > 0)
        {
            string dbConn = clsConfig.GetConfigValue("OAConnStr");

            using (LiLanzDALForXLM dal = new LiLanzDALForXLM(dbConn))
            {
                object objmdKhid = "";
                string strSQL = string.Concat(@"SELECT TOP 1 CONVERT(VARCHAR(10),a.khid) + '|' + mdmc+'|'+convert(varchar(10),kh.ssid)
                                        FROM t_mdb a inner join yx_t_khb kh on a.khid=kh.khid WHERE a.mdid = ", Session["mdid"]);
                clsLocalLoger.WriteInfo(strSQL);
                string strInfo = dal.ExecuteQueryFast(strSQL, out objmdKhid);
                if (strInfo == "")
                {
                    string[] mdinfo = Convert.ToString(objmdKhid).Split('|');
                    if (mdinfo.Length == 3) sbCompany.AppendFormat(optionBase, mdinfo[0], mdinfo[1], opselect, mdinfo[2]);
                    else sbCompany.AppendFormat(optionBase, "-1", "门店人资权限错误！请联系总部IT", opselect, "");
                }
            }
        }
        else
        {
            sbCompany.AppendFormat(optionBase, "", "完整权限", opselect, "");

            string strSQL = string.Concat(@"SELECT a.khid ,  khmc mdmc,1 'ssid',0 'mdid'  FROM yx_t_khb A 
                                                WHERE A.ssid = 1 AND A.yxrs = 1 AND ISNULL(A.ty,0) = 0
                                                                    AND ISNULL(A.sfdm,'') <> ''                                            
                                                    ORDER BY A.khmc");


            string dbConn = clsConfig.GetConfigValue("OAConnStr");
            using (LiLanzDALForXLM dal = new LiLanzDALForXLM(dbConn))
            {
                string strInfo = dal.ExecuteQuery(strSQL, out dt);
                if (strInfo != "")
                {
                    clsWXHelper.ShowError("权限信息读取错误2！strInfo:" + strInfo);
                    return;
                }
                if (dt.Rows.Count == 0)
                {
                    sbCompany.AppendFormat(optionBase, "-1", "门店人资权限错误！请联系总部IT", opselect, "");
                    return;
                }
            }

            if (dt.Rows.Count == 0) sbCompany.AppendFormat(optionBase, "-1", "您还没有授权，请联系总部IT", opselect, "");
            else { calCompany(ref dt, ref sbCompany); }
        }
        SeasonCollect();
        KhClassCollect();
        AuthOptionCollect = sbCompany.ToString();
        sbCompany.Length = 0;
    }

    public void calCompany(ref DataTable dt, ref StringBuilder sbCompany)
    {
        DataRow dr;
        DataRow[] drList = dt.Select("", "ssid,mdmc");
        for (int i = 0; i < dt.Rows.Count; i++)
        {
            dr = drList[i];

            sbCompany.AppendFormat(optionBase, dr["khid"], dr["mdmc"], "", dr["ssid"]);
        }
    }

    //必须在内容页的Load中对Master.SystemID 进行赋值；
    protected void Page_Load(object sender, EventArgs e)
    {
        this.Master.IsTestMode = false;
    }

    public void SeasonCollect()
    {
        string dbConn = clsConfig.GetConfigValue("OAConnStr");
        using (LiLanzDALForXLM dal = new LiLanzDALForXLM(dbConn))
        {
            string _sql = "select top 7 dm,mc from yf_t_kfbh where jzrq is not null order by dm desc";
            StringBuilder sbSeacon = new StringBuilder();
            //string optionBase = "<div class=\"fitem {2}\" dm=\"{0}\">{1}</div>";
            string optionBase = "<li class=\"{2}\" data-dm=\"{0}\">{1}</li>";
            DataTable dt;
            string errinfo = dal.ExecuteQuery(_sql, out dt);
            if (errinfo == "")
            {
                //DataRow dr = dt.NewRow();
                //dr["dm"] = "";
                //dr["mc"] = "全部..";
                //dt.Rows.InsertAt(dr,0);
                for (int i = 0; i < dt.Rows.Count; i++)
                {
                    string name = Convert.ToString(dt.Rows[i]["mc"]).Replace("产品", "");
                    if (i == 0)
                        sbSeacon.AppendFormat(optionBase, Convert.ToString(dt.Rows[i]["dm"]), name, "onchoose");
                    else
                        sbSeacon.AppendFormat(optionBase, Convert.ToString(dt.Rows[i]["dm"]), name, "");
                }//end for
            }
            SeasonOptionCollect = sbSeacon.ToString();
            sbSeacon.Length = 0;
            dt.Clear(); dt.Dispose();
        }
    }

    //暂定按roleName来区分 kf ty=0 and tzfl<>'' zb(Z) my(D) dz(C)
    public void KhClassCollect()
    {
        if (roleName != "")
        {
            string dbConn = clsConfig.GetConfigValue("OAConnStr");
            using (LiLanzDALForXLM dal = new LiLanzDALForXLM(dbConn))
            {
                string _sql = "";
                switch (roleName)
                {
                    case "kf":
                        _sql = "select cs,mc from yx_t_khfl where ty=0 and tzfl<>''";
                        break;
                    case "zb":
                        _sql = "select cs,mc from yx_t_khfl where ty=0 and tzfl like '%Z,%'";
                        break;
                    case "my":
                        //_sql = "select cs,mc from yx_t_khfl where ty=0 and tzfl like '%D,%'";
                        break;
                    case "dz":
                        //_sql = "select cs,mc from yx_t_khfl where ty=0 and tzfl like '%C,%'";
                        break;
                    default:
                        break;
                }

                if (_sql != "")
                {
                    StringBuilder sbKhClass = new StringBuilder();
                    string optionBase = "<li data-dm=\"{0}\">{1}</li>";
                    DataTable dt;

                    string errinfo = dal.ExecuteQuery(_sql, out dt);
                    if (errinfo == "")
                    {
                        DataRow dr = dt.NewRow();
                        dr["cs"] = "";
                        dr["mc"] = "全部..";
                        dt.Rows.InsertAt(dr, 0);
                        for (int i = 0; i < dt.Rows.Count; i++)
                        {
                            sbKhClass.AppendFormat(optionBase, Convert.ToString(dt.Rows[i]["cs"]), dt.Rows[i]["mc"], "");
                        }//end for
                    }

                    KhClassOptionCollect = sbKhClass.ToString();
                    sbKhClass.Length = 0;
                    dt.Clear(); dt.Dispose();
                }
            }//end using  
        }
    }
</script>

<asp:Content ID="Content1" ContentPlaceHolderID="head" runat="server">
    <title>客户提货销售对照分析</title>
    <meta http-equiv="content-type" content="text/html; charset=UTF-8" />
    <meta name="viewport" content="width=device-width, initial-scale=1,user-scalable=0,maximum-scale=1" />
    <link rel="stylesheet" href="../../res/css/font-awesome.min.css" />
    <link rel="stylesheet" href="../../res/css/LeePageSlider.css" />
    <link rel="stylesheet" href="../../res/css/StoreSaler/inventory.css" />
    
</asp:Content>
<asp:Content ID="Content2" ContentPlaceHolderID="ContentPlaceHolder1" runat="server">
  <body>
        <div class="header">
            <i id="goback" class="fa fa-angle-left"></i>
            <div id="search">
                <input type="text" placeholder="搜索货号" />
                <button type="button"><i class="fa fa-search"></i></button>
            </div>
            <div id="filter">
                <i class="fa fa-filter"></i>
                <p>筛选</p>
            </div>
        </div>
        <div class="wrap-page page-not-header">
            <div class="condition">
                <select id="company">                    
                    <%=AuthOptionCollect %>
                </select>
                <label class="fa fa-angle-down" for="company"></label>
                <div class="terms"><p></p></div>
            </div>
            <div id="kh" class="page">
                <div class="shade">
                    <table>
                        <thead>
                            <tr>
                                <th colname="khdm">客户码</th>
                                <th colname="dds">订单数</th>
                                <th colname="ths">提货数</th>
                                <th colname="cks">出库数</th>
                                <th colname="lss">零售数</th>
                                <th colname="kcs">库存数</th>
                                <th colname="dxl">动销率</th>
                                <th colname="sql">售罄率</th>
                            </tr>
                        </thead>
                    </table>
                </div>
                <div class="detail">
                    <table>
                        <thead>
                            <tr>
                                <th>客户名/客户码</th>
                                <th>订单数</th>
                                <th>提货数</th>
                                <th>出库数</th>
                                <th>零售数</th>
                                <th>库存数</th>
                                <th>动销率</th>
                                <th>售罄率</th>
                            </tr>
                        </thead>
                        <tbody>
                        </tbody>
                    </table>
                </div>
                <div class="total">
                    <table>
                        <tr>
                            <td>合计</td>
                            <td>-</td>
                            <td>-</td>
                            <td>-</td>
                            <td>-</td>
                            <td>-</td>
                            <td>-</td>
                            <td>-</td>
                        </tr>
                    </table>
                </div>
            </div>
            <div id="lb" class="page">
                <div class="shade">
                    <table>
                        <thead>
                            <tr>
                                <th colname="lb">类别</th>
                                <th colname="dds">订单数</th>
                                <th colname="ths">提货数</th>
                                <th colname="cks">出库数</th>
                                <th colname="lss">零售数</th>
                                <th colname="kcs">库存数</th>
                                <th colname="dxl">动销率</th>
                                <th colname="sql">售罄率</th>
                            </tr>
                        </thead>
                    </table>
                </div>
                <div class="detail">
                    <table>
                        <thead>
                            <tr>
                                <th>类别</th>
                                <th>订单数</th>
                                <th>提货数</th>
                                <th>出库数</th>
                                <th>零售数</th>
                                <th>库存数</th>
                                <th>动销率</th>
                                <th>售罄率</th>
                            </tr>
                        </thead>
                        <tbody>
                        </tbody>
                    </table>
                </div>
                <div class="total">
                    <table>
                        <tr>
                            <td>合计</td>
                            <td>-</td>
                            <td>-</td>
                            <td>-</td>
                            <td>-</td>
                            <td>-</td>
                            <td>-</td>
                            <td>-</td>
                        </tr>
                    </table>
                </div>
            </div>
            <div id="sphh" class="page">
                <div class="shade">
                    <table>
                        <thead>
                            <tr>
                                <th colname="sphh">货号</th>
                                <th colname="dds">订单数</th>
                                <th colname="ths">提货数</th>
                                <th colname="cks">出库数</th>
                                <th colname="lss">零售数</th>
                                <th colname="kcs">库存数</th>
                                <th colname="dxl">动销率</th>
                                <th colname="sql">售罄率</th>
                            </tr>
                        </thead>
                    </table>
                </div>
                <div class="detail">
                    <table>
                        <thead>
                            <tr>
                                <th>货号</th>
                                <th>订单数</th>
                                <th>提货数</th>
                                <th>出库数</th>
                                <th>零售数</th>
                                <th>库存数</th>
                                <th>动销率</th>
                                <th>售罄率</th>
                            </tr>
                        </thead>
                        <tbody>
                        </tbody>
                    </table>
                </div>
                <div class="total">
                    <table>
                        <tr>
                            <td>合计</td>
                            <td>-</td>
                            <td>-</td>
                            <td>-</td>
                            <td>-</td>
                            <td>-</td>
                            <td>-</td>
                            <td>-</td>
                        </tr>
                    </table>
                </div>
            </div>
        </div>
        <div class="layer">
            <div class="criteria">
                <div class="options">
                    <div class="num">
                        <p class="title">查询条件</p>
                        <ul>
                            <li id="date" class="onchoose">日期</li>
                            <li id="developNo">开发编号</li>
                        </ul>
                    </div>
                    <div class="date">
                        <p class="title">
                            <span>日期范围</span>
                        </p>
                        <div class="range">
                            <p>提货日期:</p>
                            <input id="thDateStart" type="date" value="2017-07-07" />
                            <div class="line"></div>
                            <input id="thDateEnd" type="date" value="2017-07-07" />
                        </div>
                        <div class="range">
                            <p>销售日期:</p>
                            <input id="xsDateStart" type="date" value="2017-07-07" />
                            <div class="line"></div>
                            <input id="xsDateEnd" type="date" value="2017-07-07" />
                        </div>
                    </div>
                    <div class="local">
                        <p class="title">开发编号</p>
                        <ul id="kfbh">
                           <%= SeasonOptionCollect %>
                        </ul>
                    </div>
                    <div class="classified">
                        <p class="title">客户类别</p>
                        <ul id="khlb">
                          <%= KhClassOptionCollect%>
                        </ul>
                    </div>
                    <div class="classified">
                        <p class="title">专卖店类别</p>
                        <ul id="zmdlb">
                            <li data-dm="" >全部...</li>
                            <li data-dm="xz">主品牌直营店</li>
                            <li data-dm="xj">主品牌加盟店</li>
                            <li data-dm="xm">轻商务直营店</li>
                            <li data-dm="xn">轻商务加盟店</li>
                            <li data-dm="x[m,n]">轻商务全部店</li> 
                        </ul>
                    </div>
                </div>
                <div class="confirm">
                    <button type="button" id="reset">重置</button>
                    <button type="button" id="complete">完成</button>
                </div>
            </div>
        </div>

      <!--加载提示-->
        <div class="load_toast" id="myLoading">
            <div class="load_toast_mask"></div>
            <div class="load_toast_container">
                <div class="lee_toast">
                    <div class="load_img">
                        <img src="../../res/img/my_loading.gif" />
                    </div>
                    <div class="load_text">加载中...</div>
                </div>
            </div>
        </div>

        
    <!--模板区-->
    <!--贸易公司-->
    <script id="datali_1" type="text/html">
        <li khid="{{khid}}"> 
            <p class="data-item col29 underline" col="khmc">{{khdm}}.{{if (khjc == "") }}{{khmc}}{{else}}{{khjc}}{{/if}}</p> 
            <p class="data-item col14" col="xssl">{{xssl}}</p>
            <p class="data-item col15" col="xsje">{{xsje | valueFormat:0}}</p>
            <p class="data-item col14" col="kdj">{{kdj}}</p>
            <p class="data-item col14" col="kdl">{{kdl}}</p>
            <p class="data-item col14" col="pjzk">{{pjzk}}</p>
        </li>
    </script> 
      <!--客户模板-->
    <script id="detail_kh" type="text/html">
        <tr>
            <td><a id="{{khid}}" href="javascript:void(0)" class="khbm" >{{khdm}}.{{khjc}}</a></td>
            <td>{{formatMoney(dds)}}</td>
            <td>{{formatMoney(ths)}}</td>
            <td>{{formatMoney(cks)}}</td>
            <td>{{formatMoney(lss)}}</td>
            <td>{{formatMoney(kcs)}}</td>
            <td>{{formatPrec(dxl)}}</td>
            <td>{{formatPrec(sql)}}</td>
        </tr>
    </script>
      <!--类别模板-->
      <script id="detail_lb" type="text/html">
        <tr>
            <td><a id="{{id}}" href="javascript:void(0)">{{mc}}</a></td>
            <td>{{formatMoney(dds)}}</td>
            <td>{{formatMoney(ths)}}</td>
            <td>{{formatMoney(cks)}}</td>
            <td>{{formatMoney(lss)}}</td>
            <td>{{formatMoney(kcs)}}</td>
            <td>{{formatPrec(dxl)}}</td>
            <td>{{formatPrec(sql)}}</td>
        </tr>
    </script>
      <!--商品货号模板-->
      <script id="detail_sphh" type="text/html">
        <tr>
            <td>{{sphh}}.{{spmc}}</td>
            <td>{{formatMoney(dds)}}</td>
            <td>{{formatMoney(ths)}}</td>
            <td>{{formatMoney(cks)}}</td>
            <td>{{formatMoney(lss)}}</td>
            <td>{{formatMoney(kcs)}}</td>
            <td>{{formatPrec(dxl)}}</td>
            <td>{{formatPrec(sql)}}</td>
        </tr>
    </script>

    <script id="total" type="text/html">
        <table>
            <tr>
                <td>合计</td>
                <td>{{formatMoney(dds)}}</td>
                <td>{{formatMoney(ths)}}</td>
                <td>{{formatMoney(cks)}}</td>
                <td>{{formatMoney(lss)}}</td>
                <td>{{formatMoney(kcs)}}</td>
                <td>{{dxl}}</td>
                <td>{{sql}}</td>
             </tr>
         </table>
    </script>

        <script type="text/javascript" src="../../res/js/jquery-3.2.1.min.js"></script>
        <script type="text/javascript" src="../../res/js/fastclick.min.js"></script>
        <script type="text/javascript" src="../../res/js/template.js"></script>
        <script type="text/javascript">
            $(function () {
                var isPop = false;  //弹层控制
                var history = [];
                bindEvent();
                FastClick.attach(document.body);
                setDefaultTime();
                $("#date").click();
                $("#filter").click();

                function bindEvent() {
                    $(".layer").click(function () {
                        $(".criteria").css("animation", "fideout 400ms");
                        isPop = true;
                    });

                    $(".criteria").click(function (e) {
                        e.stopPropagation();
                    });

                    $("#filter").click(function () {
                        $(".layer").show();
                        $(".criteria").css("animation", "fidein 400ms");
                        isPop = false;
                    });

                    $(".criteria")[0].addEventListener("webkitAnimationEnd", function () {
                        $(".criteria").css("animation", "none");
                        if (isPop) {
                            $(".layer").hide();
                        }
                    });

                    $(".num").on('click', 'li', function () {
                        $(this).addClass('onchoose').siblings().removeClass('onchoose');
                    });

                    $("#reset").click(function () {

                    });

                    $("#date").click(function () {
                        var range = $(".range");
                        var local = $(".local");
                        range.find("input").removeAttr("readonly");
                        range.find("input").css("color", "#000");
                        local.unbind();
                        local.find(".onchoose").removeClass('onchoose');
                        local.find("li").css("color", "#9e9e9f");
                    });

                    $("#developNo").click(function () {
                        var range = $(".range");
                        var local = $(".local");
                        range.find("input").attr("readonly", "readonly");
                        range.find("input").css("color", "#9e9e9f");
                        local.on('click', 'li', function () {
                            $(this).addClass('onchoose').siblings().removeClass('onchoose');
                        });
                        local.find("li:first-child").addClass('onchoose');
                        local.find("li").css("color", "#000");
                    });

                    $(".detail").scroll(throttle(bindscroll, 20, 10));

                    $("#kh .detail").on('click', 'a', function () {
                        filter.core.khid = $(this).attr("id");
                        pushPage("kh", "lb");
                    });

                    $("#lb .detail").on('click', 'a', function () {
                        filter.core.lbid = $(this).attr("id");
                        pushPage("lb", "sphh");
                    });

                    $("#goback").click(function () {
                        if (history.length > 0) {
                            var dom = history.pop();
                            dom.node.css("animation", "pageout 500ms forwards");
                            dom.detail.scroll(throttle(bindscroll, 20, 10));
                            filter.core.lx = dom.lx;
                            if (dom.lx == "lb") filter.core.lbid = "";
                            if (dom.lx == "kh") filter.core.khid = "";
                        }
                    });

                    $("#khlb").on('click', 'li', function () {
                        $("#khlb li").removeClass("onchoose");
                        $(this).addClass('onchoose');
                    });

                    $("#zmdlb").on('click', 'li', function () {
                        $("#zmdlb li").removeClass("onchoose");
                        $(this).addClass('onchoose');
                    });

                    $(".shade th").on('click', function () {
                        var colname = $(this).attr('colname');
                        var asc = "";
                        var th = $(this);
                        $(".shade th").find("i").remove();
                        
                        if (colname == filter.order.colname) { //排序的列相同则改变排序方式
                            if (filter.order.ordertype == "asc") {
                                filter.order.ordertype = "desc";
                                th.append("<i class=\"fa fa-caret-down\"></i>");
                            } else {
                                filter.order.ordertype = "asc";
                                th.append("<i class=\"fa fa-caret-up\"></i>");
                            } 
                        } else {
                            filter.order.colname = colname;
                            filter.order.ordertype = 'asc';
                            th.append("<i class=\"fa fa-caret-up\"></i>");
                        }
                        Search();
                    });

                    $("#search button").on("click", function () {
                        if (filter.core.lx == 'lb') {
                            pushPage('kh', filter.core.lx);
                        } else if (filter.core.lx == 'sphh') {
                            pushPage('lb', filter.core.lx);
                        } else {
                            Search();
                        }
                    });

                    $("#complete").on("click", function () {
                        filter.core.khid = "";
                        filter.core.lbid = "";
                        popPage();
                        Search();
                    });

                    $("#reset").on("click", Reset);
                }

                function pushPage(nowpage, tagetpage) {
                    var tpage = $("#" + tagetpage);
                    var detail = $("#" + nowpage + " .detail");
                    tpage.find(".detail tbody").empty();
                    tpage.css("animation", "pagein 500ms forwards");
                    detail.unbind('scroll');
                    history.push({
                        node: tpage,
                        detail: detail,
                        lx: nowpage
                    });

                    filter.core.lx = tagetpage;
                    Search();
                }

                function popPage() {
                    while (history.length > 0) {
                        $("#goback").click();
                    }
                }

                function bindscroll() {
                    var left = this.scrollLeft * -1;
                    $(".shade table").css("left", left);
                    $(".total table").css("left", left);
                }

                function throttle(func, wait, mustRun) {
                    var timeout,
                        startTime = new Date();

                    return function () {
                        var context = this,
                            args = arguments,
                            curTime = new Date();

                        clearTimeout(timeout);
                        if (curTime - startTime >= mustRun) {
                            func.apply(context, args);
                            startTime = curTime;
                        } else {
                            timeout = setTimeout(func, wait);
                        }
                    };
                }

                function setDefaultTime() {
                    var date = new Date();
                    var year = date.getFullYear();
                    var month = formatTime(date.getMonth() + 1);
                    var day = formatTime(date.getDate());
                    var now = year + "-" + month + "-" + day;
                    var nowMonth = year + "-" + month + "-01";
                    $("#thDateStart").val(nowMonth);
                    $("#thDateEnd").val(now);
                    $("#xsDateStart").val(now);
                    $("#xsDateEnd").val(now);
                    
                }

                function formatTime(date) {
                    if (date < 10) {
                        return '0' + date;
                    } else {
                        return date;
                    }
                }

                /* 千位分隔符 */
                Number.prototype.formatMoney = function (places, symbol, thousand, decimal) {
                    places = !isNaN(places = Math.abs(places)) ? places : 2;
                    symbol = symbol !== undefined ? symbol : "¥";
                    thousand = thousand || ",";
                    decimal = decimal || ".";
                    var number = this,
                        negative = number < 0 ? "-" : "",
                        i = parseInt(number = Math.abs(+number || 0).toFixed(places), 10) + "",
                        j = (j = i.length) > 3 ? j % 3 : 0;
                    return symbol + negative + (j ? i.substr(0, j) + thousand : "") + i.substr(j).replace(/(\d{3})(?=\d)/g, "$1" + thousand) + (places ? decimal + Math.abs(number - i).toFixed(places).slice(2) : "");
                }
            });
        </script>


    <script type="text/javascript">
        var _roleName="<%=roleName%>"; 

        var defaultSite = "<%= ViewType %>"
        var CurrentSite = "", ViewRoute = defaultSite;
        var filter = {
            "core": {
                "lx": defaultSite,
                "khid": "", 
                "lbid": ""                
            },
            "spsearch": "",
            "filter": {
                "cxtj":"date",
                "kfbh": "",
                "thksrq": "",
                "thjsrq": "",
                "xsksrq": "",
                "xsjsrq": "",
                "khlb": "",
                "zmdlb": ""
            },
            "auth": {
                "roleid": "<%=roleID %>",
                "curkhid": "" 
            },
            "order": {
                "colname":"", 
                "ordertype": "" 
            }
        }; 

        //用于排序
        var orders = {
                        "kh": {
                            "colname": "cgsl",
                            "ordertype": "desc"
                        },
                        "lb": {
                            "colname": "cgsl",
                            "ordertype": "desc"
                        },
                        "sphh": {
                            "colname": "cgsl",
                            "ordertype": "desc"                     
                        }
                    };

                    function Reset() {
                        $("#date").click();

                        $("#khlb").find(".onchoose").removeClass("onchoose");
                        $("#khlb").find("li").eq(0).addClass("onchoose");
                        $("#zmdlb").find(".onchoose").removeClass("onchoose");
                        $("#zmdlb").find("li").eq(0).addClass("onchoose");
                    }
                    function Search() {
                        onLoading();
                        //上面区域赋值
                        filter.spsearch = $("#search>input").val();
                        filter.auth.curkhid = $("#company").val();

                        //钻取区域
                        switch (filter.core.lx) {
                            case "kh":
                                filter.core.khid = "";
                                filter.core.lbid = "";
                                break;
                            case "lb":
                                filter.core.lbid = "";
                                break;
                        }

                        //筛选区
                        if ($("#date").hasClass("onchoose"))  filter.filter.cxtj = "date"
                        else filter.filter.cxtj = "developNo";

                        filter.filter.thksrq = $("#thDateStart").val();
                        filter.filter.thjsrq = $("#thDateEnd").val();
                        filter.filter.xsksrq = $("#xsDateStart").val();
                        filter.filter.xsjsrq = $("#xsDateEnd").val();
                        filter.filter.kfbh = getSelectValue("kfbh");
                        filter.filter.khlb = getSelectValue("khlb");
                        filter.filter.zmdlb = getSelectValue("zmdlb");

                        console.log(filter);
                        $.ajax({
                            type: "POST",
                            timeout: 60000,
                            contentType: "application/x-www-form-urlencoded; charset=utf-8",
                            url: "SalesComparisonCore.ashx",
                            data: { ctrl: "GetDZData", filters: JSON.stringify(filter) },
                            success: function (msg) {
                                if (msg.indexOf("Error:") == -1 && msg != "") {
                                    var datas = JSON.parse(msg);
                                    var len = datas.length;
                                    var html = "";
                                    var totalhtml = '';
                                    var total = {
                                        dds: 0,
                                        ths: 0,
                                        cks: 0,
                                        lss: 0,
                                        kcs: 0,
                                        dxl: 0,
                                        sql: 0,
                                        dxl: '-',
                                        sql: '-'
                                    };

                                    template.helper('formatMoney', function (date) {
                                        return parseFloat(date).formatMoney(0,'');
                                    });

                                    template.helper('formatPrec', function (data) {
                                        if (!data) return '';
                                        return data + '%';
                                    });

                                    for (var i = 0; i < len; i++) {
                                        html = html + template("detail_" + filter.core.lx, datas[i]);
                                        total.dds += datas[i].dds;
                                        total.ths += datas[i].ths;
                                        total.cks += datas[i].cks;
                                        total.lss += datas[i].lss;
                                        total.kcs += datas[i].kcs;
                                    }

                                    if (total.lss != 0) {
                                        if (total.ths != 0) {
                                            total.dxl = (total.lss / total.ths * 100).toFixed(2) + '%';
                                        }
                                        if (total.dds != 0) {
                                            total.sql = (total.lss / total.dds * 100).toFixed(2) + '%';
                                        }
                                    }

                                    totalhtml = template("total", total);;
                                    $("#" + filter.core.lx + " .detail tbody").empty().append(html);
                                    $("#" + filter.core.lx + " .total").empty().append(totalhtml);
                                    
                                    //filter.order.colname = "";
                                    //filter.order.ordertype = "";

                                    setTimeout(function () {
                                        $(".layer").click();
                                        $("#myLoading").hide();
                                    }, 1000);
                                    

                                    //var len = datas.rows.length;
                                    //var html = "";
                                    //for (var i = 0; i < len; i++) {
                                    //    var row = datas.rows[i];
                                    //    html += template("datali_2", row);
                                    //} //end for

                                    //$("#md .data-ul li:not(:first-child)").remove();
                                    //$("#md .data-ul").append(html);
//                                      
//                                    $("#md .data-ul li p[col='mdmc']").bind("click", function () {
//                                        filter.core.lx = "lb";
//                                        filter.core.mdkhid = $(this).parent().attr("mdid");
//                                        gotoSearch(); // LoadSPLBData();
//                                    });

//                                    StaticCountMD("md", len, datas.sumXssl, datas.sumXsje, datas.avgKdl, datas.avgKdj, datas.avgPjzk);

//                                    if (len == MaxDataCount) LeeJSUtils.showMessage("warn", "仅显示前 " + MaxDataCount.toString() + " 条数据");
//                                    else $("#leemask").hide();
                                } else if (msg == "") {
                                    //                                    $("#md .data-ul li:not(:first-child)").remove();
                                    var totalhtml = "<table><tr><td>合计</td><td>-</td><td>-</td><td>-</td><td>-</td><td>-</td><td>-</td><td>-</td></tr></table>";
                                    $("#" + filter.core.lx + " .detail tbody").empty();
                                    $("#" + filter.core.lx + " .total").empty().append(totalhtml);
                                    onLoading("查询无结果！");
                                    //                                    $("#md .data-ul").html("");
                                    setTimeout(function () {
                                        $("#myLoading").hide();
                                    }, 2000);
                                } else {
                                    //$("#leemask").hide();
                                    onLoading(msg.replace("Error:", ""));
                                    setTimeout(function () {
                                        $("#myLoading").hide();
                                    }, 2000);
                                }
                                    
                            },
                            error: function (XMLHttpRequest, textStatus, errorThrown) {
                                onLoading("网络连接失败！");
                                $(".layer").click();
                                setTimeout(function () {
                                    $("#myLoading").hide();
                                }, 2000);
                            }
                        });   //end AJAX
                        
                    }

                    function getSelectValue(vname) {
                        if ($("#" + vname).find(".onchoose").length == 0) return "";
                        else return $("#" + vname).find(".onchoose").attr("data-dm");
                    }

                    /* 显示加载状态 */
                    function onLoading(msg) {
                        $(".load_text").text(msg || '加载中...');
                        $("#myLoading").show();
                    }
 
    </script>

     
</asp:Content>
