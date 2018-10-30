<%@ Page Title="零售综合分析" Language="C#" MasterPageFile="../../WebBLL/frmQQDBase.Master" AutoEventWireup="true" %>

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
    protected void Page_PreRender(object sender, EventArgs e)
    {
        ViewType = Convert.ToString(Request.Params["ViewType"]);
        if (ViewType == null || ViewType == "") ViewType = "kh";

        clsWXHelper.CheckQQDMenuAuth(22);    //检查菜单权限

        string optionBase = "<option value=\"{0}\" {2} data-ssid={3}>{1}</option>";
        string opselect = " selected";
        StringBuilder sbCompany = new StringBuilder();
        roleID = Convert.ToInt32(Session["RoleID"]);
        roleName = Convert.ToString(Session["RoleName"]);
                  
        if (roleID == 4)
        {
            //获取当前用户的身份。默认会自动选中第一个项
            using (DataTable dt = clsWXHelper.GetQQDAuth())
            {
                DataRow dr;
                DataRow[] drList = dt.Select("", "ssid,khid,mdid");
                for (int i = 0; i < dt.Rows.Count; i++)
                {
                    dr = drList[i];

                    sbCompany.AppendFormat(optionBase, dr["khid"], dr["mdmc"], "", dr["ssid"]);
                }

                if (dt.Rows.Count == 0) sbCompany.AppendFormat(optionBase, "-1", "您还没有授权，请联系总部IT", opselect, "");
            }
        }
        else if (roleID < 3 && roleID > 0)
        {
            if (ViewType == "kh") ViewType = "md";  //门店职员 如果访问 “客户”则强制切回门店

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
        }
        SeasonCollect();
        KhClassCollect();
        AuthOptionCollect = sbCompany.ToString();
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
        using (LiLanzDALForXLM dal = new LiLanzDALForXLM(dbConn))
        {
            string _sql = "select top 7 dm,mc from yf_t_kfbh where jzrq is not null order by dm desc";
            StringBuilder sbSeacon = new StringBuilder();
            string optionBase = "<div class=\"fitem {2}\" dm=\"{0}\">{1}</div>";
            DataTable dt;
            string errinfo = dal.ExecuteQuery(_sql, out dt);
            if (errinfo == "")
            {
                for (int i = 0; i < dt.Rows.Count; i++)
                {
                    string name = Convert.ToString(dt.Rows[i]["mc"]).Replace("产品", "");
                    if (i == 0)
                        sbSeacon.AppendFormat(optionBase, Convert.ToString(dt.Rows[i]["dm"]), name, " selected");
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
                        //_sql = "select cs,mc from yx_t_khfl where ty=0 and tzfl<>''";
                        break;
                    case "zb":
                        _sql = "select cs,mc from yx_t_khfl where ty=0 and tzfl like '%Z,%'";
                        break;
                    case "my":
                        _sql = "select cs,mc from yx_t_khfl where ty=0 and tzfl like '%D,%'";
                        break;
                    case "dz":
                        _sql = "select cs,mc from yx_t_khfl where ty=0 and tzfl like '%C,%'";
                        break;
                    default:
                        break;
                }

                if (_sql != "")
                {
                    StringBuilder sbKhClass = new StringBuilder();
                    string optionBase = "<div class=\"fitem\" cs=\"{0}\">{1}</div>";
                    DataTable dt;

                    string errinfo = dal.ExecuteQuery(_sql, out dt);
                    if (errinfo == "")
                    {
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
    <title>零售综合分析</title>
    <meta charset="utf-8" />
    <meta name="viewport" content="width=device-width,initial-scale=1,user-scalable=0,maximum-scale=1" />
    <meta name="format-detection" content="telephone=no" />
    <meta name="apple-mobile-web-app-capable" content="yes" />
    <meta name="apple-mobile-web-app-status-bar-style" content="black" />
    <link type="text/css" rel="stylesheet" href="../../res/css/LeePageSlider.css" />
    <link type="text/css" rel="stylesheet" href="../../res/css/font-awesome.min.css" />
    <link type="text/css" rel="stylesheet" href="../../res/css/storesaler/lszhfx_style.css" />
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

        .viewtype {
            position: fixed;
            top: 60px;
            left: 10px;
            z-index: 2000;
            background-color: rgb(71,71,71);
            color: #fff;
            font-size: 14px;
            font-weight: bold;
            display: none;
        }

            .viewtype:before, .viewtype:after {
                content: "";
                width: 0px;
                height: 0px;
                position: absolute;
                top: -20px;
                left: 50px;
                border: 10px solid transparent;
                border-bottom-color: rgb(71,71,71);
            }

            .viewtype li {
                text-align: center;
                width: 120px;
                height: 40px;
                line-height: 40px;
                position: relative;
            }

                .viewtype li:not(:last-child) {
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
            color: #1cc1c7;
        }

        .underline {
            color:#cc5300;
        }
        .col15 {
            width:15%;
            text-align:right;
            font-size:12px;
        }
        #sphh_page {
            padding:0;
        }
        iframe {
            width: 100%;
            height: 100%;
            border: none;
            outline: none;
        }
        #page_close_btn {
            background-color: #333;
            padding: 8px;
            position: fixed;
            left: 15px;
            bottom: 15px;
            color: #fff;
            border-radius: 4px;
            font-size: 16px;
        }

        .farea .date {
            width:270px;
        }
        .date input {
            width: 110px;
            margin: 8px 0px;            
        }        
        
        
.col29 {
    width: 29%;
    text-align: left;
    padding-left: 5px;
    white-space: nowrap;
    overflow: hidden;
    /*text-overflow: ellipsis;*/
    font-size: 12px;
}
.col14
{
    width: 14%; 
    text-align: right;
    font-size: 12px;
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
    <div class="header">
        <div class="wrapSearch">
            <i class="fa fa-angle-left fa-2x" onclick="BackFunc();"></i>
            <div class="viewicon">
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
            <i class="fa fa-angle-down"></i>
            <select id="comlist">
                <%=AuthOptionCollect %>
            </select>
            <div class="filters"></div>
        </div>
    </div>
    <div class="wrap-page">
        <!--贸易公司数据页-->
        <div class="page page-not-header page-right" id="kh">
            <div class="data-container">
                <ul class="data-ul floatfix">
                    <li class="item-head">
                        <p class="data-item col4" ordername="khdm">代码</p>
                        <p class="data-item col15" ordername="cgsl">提货数</p>
                        <p class="data-item col15" ordername="xssl">销售数</p>
                        <p class="data-item col15" ordername="xsje">销售额</p>
                        <p class="data-item col15" ordername="wcl">完成率</p>
                    </li>
                </ul>
            </div>
            <div class="static_count">
                <ul class="floatfix">
                    <li class="col4">合 计</li>
                    <li class="col15" col="s-cgsl">--</li>
                    <li class="col15" col="s-xssl">--</li>
                    <li class="col15" col="s-xsje">--</li>
                    <li class="col15" col="s-wcl">--</li>
                </ul>
            </div>
        </div>
        <!--专卖店数据页-->
        <div class="page page-not-header page-right" id="md">
            <div class="data-container">
                <ul class="data-ul floatfix">
                    <li class="item-head">
                        <p class="data-item col29" ordername="khdm">专卖店</p>                        
                        <p class="data-item col14" ordername="xssl">销售数</p>
                        <p class="data-item col15" ordername="xsje">销售额</p>
                        <p class="data-item col14" ordername="kdj">客单价</p>
                        <p class="data-item col14" ordername="kdl">客单量</p>
                        <p class="data-item col14" ordername="pjzk">平均折</p>
                    </li>
                </ul>
            </div>
            <div class="static_count">
                <ul class="floatfix">
                    <li class="col29">合 计</li> 
                    <li class="col14" col="s-xssl">--</li>
                    <li class="col15" col="s-xsje">--</li>
                    <li class="col14" col="s-kdj">--</li>
                    <li class="col14" col="s-kdl">--</li>
                    <li class="col14" col="s-pjzk">--</li>
                </ul>
            </div>
        </div>
        <!--类别数据页-->
        <div class="page page-not-header page-right" id="lb">
            <div class="data-container">
                <ul class="data-ul floatfix">
                    <li class="item-head">
                        <p class="data-item col4" ordername="lbmc">类别</p>
                        <p class="data-item col15" ordername="cgsl">提货数</p>
                        <p class="data-item col15" ordername="xssl">销售数</p>
                        <p class="data-item col15" ordername="xsje">销售额</p>
                        <p class="data-item col15" ordername="wcl">完成率</p>
                    </li>
                </ul>
            </div>
            <div class="static_count">
                <ul class="floatfix">
                    <li class="col4">合 计</li>
                    <li class="col15" col="s-cgsl">--</li>
                    <li class="col15" col="s-xssl">--</li>
                    <li class="col15" col="s-xsje">--</li>
                    <li class="col15" col="s-wcl">--</li>
                </ul>
            </div>
        </div>
        <!--货号数据页-->
        <div class="page page-not-header page-right" id="sphh">
            <div class="data-container">
                <ul class="data-ul floatfix">
                    <li class="item-head">
                        <p class="data-item col4" ordername="sphh">货号</p>
                        <p class="data-item col15" ordername="cgsl">提货数</p>
                        <p class="data-item col15" ordername="xssl">销售数</p>
                        <p class="data-item col15" ordername="xsje">销售额</p>
                        <p class="data-item col15" ordername="wcl">完成率</p>
                    </li>
                </ul>
            </div>
            <div class="static_count">
                <ul class="floatfix">
                    <li class="col4">合 计</li>
                    <li class="col15" col="s-cgsl">--</li>
                    <li class="col15" col="s-xssl">--</li>
                    <li class="col15" col="s-xsje">--</li>
                    <li class="col15" col="s-wcl">--</li>
                </ul>
            </div>
        </div>
        <!--右侧筛选页-->
        <div class="page page-right" id="fiterpage">
            <div class="filtercontainer">
                <!--开发编号-->
                <div class="farea floatfix" filter="kfbh">
                    <p class="title">开发编号</p>
                    <div class="fitem" dm="all">全部..</div>
                    <!--<div class="fitem selected" dm="20161">2016年春季产品</div>
                    <div class="fitem" dm="20162">2016年夏季产品</div>
                    <div class="fitem" dm="20163">2016年秋季产品</div>
                    <div class="fitem" dm="20164">2016年冬季产品</div>-->
                    <%=SeasonOptionCollect %>
                </div>
                <!--日期范围-->
                <div class="farea" style="border-top: 1px solid #e2e2e2; margin-bottom: 15px;">
                    <p class="title">日期范围 <i class="fa fa-check-square active"></i></p>
                    <div class="date" filter="rq">
                        <input type="date" id="ksrq">
                        <div class="line"></div>
                        <input type="date" id="jsrq" />
                    </div>
                </div>
                <!--客户类别-->
                <div class="farea fkhlb floatfix" style="border-top: 1px solid #e2e2e2;" filter="khfl">
                    <p class="title">客户类别</p>
                    <!--<div class="fitem" cs="">全部...</div>
                    <div class="fitem" cs="xf">领航营销</div>
                    <div class="fitem" cs="xd">市场管理中心</div>
                    <div class="fitem" cs="xg">直营大客户</div>
                    <div class="fitem" cs="xq">其他客户</div>
                    <div class="fitem" cs="xy">区域代理</div>
                    <div class="fitem" cs="xl">历史客户</div>-->
                    <%=KhClassOptionCollect %>
                </div>
                <div class="farea fkhlb floatfix" style="border-top: 1px solid #e2e2e2;" filter="zmdfl">
                    <p class="title">专卖店类别</p>
                    <div class="fitem" cs="">全部...</div>
                    <div class="fitem" cs="xz">主品牌直营店</div>
                    <div class="fitem" cs="xj">主品牌加盟店</div>
                    <div class="fitem" cs="xm">轻商务直营店</div>
                    <div class="fitem" cs="xn">轻商务加盟店</div>
                    <div class="fitem" cs="x[m,n]">轻商务全部店</div>
                </div>
            </div>
            <div class="fbtns">
                <a href="javascript:ResetFilter()">重置</a>
                <a href="javascript:SubmitFilter()" style="background-color: #1cc1c7; color: #fff;">完成</a>
            </div>
        </div>
        <%--商品货号详情页--%>
        <div class="page page-right" id="sphh_page"></div>
    </div>
    <div class="footer">
        <ul class="footer-ul floatfix">
            <li class="data-item total">合计</li>
            <li class="data-item" col="sum-cgsl">--</li>
            <li class="data-item" col="sum-lssl">--</li>
            <li class="data-item">--</li>
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
            <p class="data-item col4 num underline" col="khmc">{{khdm}}.{{if (khjc == "") }}{{khmc}}{{else}}{{khjc}}{{/if}}</p>
            <p class="data-item col15 num underline" col="cgsl">{{cgsl}}</p>
            <p class="data-item col15" col="xssl">{{xssl}}</p>
            <p class="data-item col15" col="xsje">{{xsje}}</p>
            <p class="data-item col15" col="wcl">{{wcl}}</p>
        </li>
    </script>

    <!--门店-->
    <script id="datali_2" type="text/html">
        <li mdid="{{khid}}">
            <p class="data-item col29 underline" col="cgsl">{{khmc}}</p> 
            <p class="data-item col14" col="xssl">{{xssl}}</p>
            <p class="data-item col15" col="xsje">{{xsje}}</p>
            <p class="data-item col14" col="kdj">{{kdj}}</p>
            <p class="data-item col14" col="kdl">{{kdl}}</p>
            <p class="data-item col14" col="pjzk">{{pjzk}}</p>
        </li>
    </script> 

    <!--商品货号-->
    <script id="datali_3" type="text/html">
        <li>
            <span style="display: none">{{sphh}}</span>
            <p class="data-item col4 num underline" col="sphh">
                <i class="fa fa-file-photo-o" /> {{sphh}}.{{spmc}}</p>
            <p class="data-item underline col15" col="cgsl">{{cgsl}}</p>
            <p class="data-item col15" col="xssl">{{xssl}}</p>
            <p class="data-item col15" col="xsje">{{xsje}}</p>
            <p class="data-item col15" col="wcl">{{wcl}}</p>
        </li>
    </script>

    <!--商品类别-->
    <script id="datali_4" type="text/html">
        <li lbid="{{lbid}}">
            <p class="data-item col4 num underline" col="splb">{{lbmc}}</p>
            <p class="data-item col15" col="cgsl">{{cgsl}}</p>
            <p class="data-item col15" col="xssl">{{xssl}}</p>
            <p class="data-item col15" col="xsje">{{xsje}}</p>
            <p class="data-item col15" col="wcl">{{wcl}}</p>
        </li>
    </script>

    <script type="text/javascript">
        var _roleName="<%=roleName%>";
        var MaxDataCount = 5000;    //最多显示数据条数，要与后台设置的一致

        var defaultSite = "<%= ViewType %>"
        var CurrentSite = "", ViewRoute = defaultSite;
        var filter = {
            "core": {
                "lx": defaultSite,
                "khid": "",
                "mdkhid": "",
                "lbid": ""                
            },
            "spsearch": "",
            "filter": {
                "kfbh": "all",
                "ksrq": "",
                "jsrq": "",
                "khfl": ""
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
                        "md": {
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


        $(document).ready(function () {
            FastClick.attach(document.body);
            LeeJSUtils.LoadMaskInit();
            LeeJSUtils.stopOutOfPage(".filtercontainer", true);
            $("#ksrq").val(new Date().format("yyyy-MM-dd"));
            $("#jsrq").val(new Date().format("yyyy-MM-dd"));

            filter.filter.ksrq=$("#ksrq").val();
            filter.filter.jsrq=$("#jsrq").val();
            //gotoSearch();
            InitPage();
        });

        function InitPage() {
            var _filter = localStorage.getItem("lszhfx-filter");
            if (_filter != null && _filter != "") {
                _obj = JSON.parse(_filter);
                var kfbh=_obj.filter.kfbh;
                $("div[filter='kfbh'] .selected").removeClass("selected");
                if(kfbh==""){                    
                    $("div[filter='kfbh'] .fitem[dm='all']").addClass("selected");
                }else{                    
                    $("div[filter='kfbh'] .fitem[dm='" + kfbh + "']").addClass("selected");
                }
                filter.filter.kfbh = kfbh;
            }
            //gotoSearch();
            $(".filterdiv").click();
        } 

        //按贸易公司汇总
        function LoadDataMain() {
            LeeJSUtils.showMessage("loading", "正在汇总数据...");
           // console.log(JSON.stringify(filter) );
            $.ajax({
                type: "POST",
                timeout: 20000,
                contentType: "application/x-www-form-urlencoded; charset=utf-8",
                url: "LSZHFXCore.aspx",
                data: { ctrl: "GetCGData", filters: JSON.stringify(filter) },
                success: function (msg) {
                    if (msg.indexOf("Error:") == -1 && msg != "") {
                        var datas = JSON.parse(msg);
                        var len = datas.rows.length;
                        var html = "";
                        for (var i = 0; i < len; i++) {
                            row = datas.rows[i];
                            html += template("datali_1", row);
                        } //end for

                        $("#kh .data-ul li:not(:first-child)").remove();
                        $("#kh .data-ul").append(html);
                        
                        openFunc("kh"); 

                        //$("#kh .data-ul li p[col='khmc']").unbind("click");
                        $("#kh .data-ul li p[col='khmc']").bind("click", function () {                            
                            filter.core.lx = "md";
                            filter.core.khid = $(this).parent().attr("khid");                            
                            gotoSearch();// LoadZMData();
                        });

                        //$("#kh .data-ul li p[col='cgsl']").unbind("click");
                        $("#kh .data-ul li p[col='cgsl']").bind("click", function () {                            
                            filter.core.lx = "lb";
                            filter.core.khid = $(this).parent().attr("khid");
                            gotoSearch();// LoadSPLBData();
                        });
                         
                        StaticCount("kh",datas.sumCgsl,datas.sumXssl,datas.sumXsje,datas.Wcl);
                            
                        if (len == MaxDataCount) LeeJSUtils.showMessage("warn", "仅显示前 " + MaxDataCount.toString() + " 条数据");
                        else $("#leemask").hide();                                     
                    } else if (msg == "") {
                        $("#md .data-ul li:not(:first-child)").remove();
                        LeeJSUtils.showMessage("warn", "查询无结果！");
                    } else
                        $("#leemask").hide();
                },
                error: function (XMLHttpRequest, textStatus, errorThrown) {
						LeeJSUtils.showMessage("error", "网络连接失败！");
                }
            }); //end AJAX
        }

        function LoadSPLBData() {
            LeeJSUtils.showMessage("loading", "正在汇总数据...");
            setTimeout(function () {
                $.ajax({
                    type: "POST",
                    timeout: 20000,                    
                    contentType: "application/x-www-form-urlencoded; charset=utf-8",
                    url: "LSZHFXCore.aspx",
                    data: { ctrl: "GetCGData", filters: JSON.stringify(filter) },
                    success: function (msg) {
                        if (msg.indexOf("Error:") == -1 && msg != "") {
                            var datas = JSON.parse(msg);
                            var len = datas.rows.length;
                            var html = "";
                            for (var i = 0; i < len; i++) {
                                var row = datas.rows[i];
                                html += template("datali_4", row);
                            } //end for
                            $("#lb .data-ul li:not(:first-child)").remove();
                            $("#lb .data-ul").append(html);
                             
                            openFunc("lb");

                            //$("#lb .data-ul li p[col='splb']").unbind("click");
                            $("#lb .data-ul li p[col='splb']").bind("click", function () {                                
                                filter.core.lx = "sphh";
                                filter.core.lbid = $(this).parent().attr("lbid");
                                gotoSearch();// LoadSPHHData();
                            });
                             
                            
                            StaticCount("lb",datas.sumCgsl,datas.sumXssl,datas.sumXsje,datas.Wcl);
                            
                            if (len == MaxDataCount) LeeJSUtils.showMessage("warn", "仅显示前 " + MaxDataCount.toString() + " 条数据");
                            else $("#leemask").hide();                                     
                        } else if (msg == "") {
                            $("#md .data-ul li:not(:first-child)").remove();
                            LeeJSUtils.showMessage("warn", "查询无结果！");
                        } else
                            $("#leemask").hide();
                    },
                    error: function (XMLHttpRequest, textStatus, errorThrown) {
						LeeJSUtils.showMessage("error", "网络连接失败！");
                    }
                }); //end AJAX
            }, 50);
        }

        function LoadSPHHData() {
            LeeJSUtils.showMessage("loading", "正在汇总数据...");
            setTimeout(function () {
                $.ajax({
                    type: "POST",
                    timeout: 20000,                    
                    contentType: "application/x-www-form-urlencoded; charset=utf-8",
                    url: "LSZHFXCore.aspx",
                    data: { ctrl: "GetCGData", filters: JSON.stringify(filter) },
                    success: function (msg) {
                        if (msg.indexOf("Error:") == -1 && msg != "") {
                            var datas = JSON.parse(msg);
                            var len = datas.rows.length;
                            var html = "";
                            for (var i = 0; i < len; i++) {
                                var row = datas.rows[i];
                                html += template("datali_3", row);
                            } //end for
                            $("#sphh .data-ul li:not(:first-child)").remove(); 
                            $("#sphh .data-ul").append(html);

                            openFunc("sphh");  

                            //点击货号跳转到该货号对应的详情页
                            //$("#sphh .data-ul li p[col='sphh']").unbind("click");
                            $("#sphh .data-ul li p[col='sphh']").bind("click", function () {                                                         
                                //var sphh=$(this).text().split(".")[0].trim();
                                //window.location.href="goodsListV3.aspx?showType=1&sphh=" + sphh;

                                LeeJSUtils.showMessage("loading", "正在加载..");
                                var sphh = $(this).text().split(".")[0].trim();
                                $.ajax({
                                    type: "POST",
                                    timeout: 10000,
                                    contentType: "application/x-www-form-urlencoded; charset=utf-8",
                                    url: "ZHCXCore_beta.aspx",
                                    data: { ctrl: "SessionCheck" },
                                    success: function (msg) {
                                        if (msg == "1") {
                                            var frame, page;
                                            frame = document.createElement('iframe');
                                            frame.src = "goodsListV3.aspx?showType=1&sphh=" + sphh;
                                            page = document.querySelector('#sphh_page');
                                            $("#sphh_page").empty().append("<a href='javascript:' id='page_close_btn' onclick='close_page()'>返回</a>");
                                            page.appendChild(frame);
                                            frame.onload = function () {                                                
                                                $("#sphh_page").removeClass("page-right");                                                
                                            }
                                        }else
                                            window.location.href = "goodsListV3.aspx?showType=1&sphh=" + sphh;
                                        $("#leemask").hide();
                                    },
                                    error: function (XMLHttpRequest, textStatus, errorThrown) {                                        
                                        LeeJSUtils.showMessage("error", "网络连接失败！");                                        
                                    }
                                }); 
                            });

                            //点击提货数进行相应的钻取
                            //$("#sphh .data-ul li p[col='cgsl']").unbind("click");
                            $("#sphh .data-ul li p[col='cgsl']").bind("click", function () {                                                         
                                filter.core.lx = "kh";     
                                $("#searchinput").val($(this).parent().find("span:eq(0)").html());
                                gotoSearch();
                            });

                            StaticCount("sphh",datas.sumCgsl,datas.sumXssl,datas.sumXsje,datas.Wcl);
                            
                            if (len == MaxDataCount) LeeJSUtils.showMessage("warn", "仅显示前 " + MaxDataCount.toString() + " 条数据");
                            else $("#leemask").hide();                                     
                        } else if (msg == "") {
                            $("#md .data-ul li:not(:first-child)").remove();
                            LeeJSUtils.showMessage("warn", "查询无结果！");
                        } else
                            $("#leemask").hide();
                    },
                    error: function (XMLHttpRequest, textStatus, errorThrown) {
						LeeJSUtils.showMessage("error", "网络连接失败！");
                    }
                }); //end AJAX
            }, 50);
        }



        function close_page() {
            $("#sphh_page").addClass("page-right");
        }

        function LoadZMData() {
            LeeJSUtils.showMessage("loading", "正在汇总数据...");
            console.log(filter);
            $.ajax({
                type: "POST",
                timeout: 20000,
                contentType: "application/x-www-form-urlencoded; charset=utf-8",
                url: "LSZHFXCore.aspx",
                data: { ctrl: "GetCGData", filters: JSON.stringify(filter) },
                success: function (msg) {
                    if (msg.indexOf("Error:") == -1 && msg != "") {
                        var datas = JSON.parse(msg);
                        var len = datas.rows.length;
                        var html = "";
                        for (var i = 0; i < len; i++) {
                            var row = datas.rows[i];
                            html += template("datali_2", row);
                        } //end for
                        $("#md .data-ul li:not(:first-child)").remove();
                        $("#md .data-ul").append(html);

                        openFunc("md"); 

                        //$("#md .data-ul li p[col='cgsl']").unbind("click");
                        $("#md .data-ul li p[col='cgsl']").bind("click", function () {
                            filter.core.lx = "lb";
                            filter.core.mdkhid = $(this).parent().attr("mdid");
                            gotoSearch();// LoadSPLBData();
                        });
                         
                        StaticCountMD("md",datas.sumXssl,datas.sumXsje,datas.avgKdl,datas.avgKdj,datas.avgPjzk);
                            
                        if (len == MaxDataCount) LeeJSUtils.showMessage("warn", "仅显示前 " + MaxDataCount.toString() + " 条数据");
                        else $("#leemask").hide();                                     
                    } else if (msg == "") {
                        $("#md .data-ul li:not(:first-child)").remove();
                        LeeJSUtils.showMessage("warn", "查询无结果！");
                    } else
                        $("#leemask").hide();
                },
                error: function (XMLHttpRequest, textStatus, errorThrown) {
					LeeJSUtils.showMessage("error", "网络连接失败！");
                }
            });   //end AJAX
        }

        //计算合计值
        function StaticCountMD(id,sumXssl,sumXsje,avgKdl,avgKdj,avgPjzk) { 
            var ulobj = $("#" + id + " .data-ul li");
            for (var i = 1; i < ulobj.length; i++) {
                var row = ulobj.eq(i); 
                
                var xsje = ($("p[col='xsje']", row).text());
                if (xsje == "")
                    xsje = "0";

                $("p[col='xsje']", row).text(toThousands(xsje));                 
            }

            $("#" + id + " [col='s-xssl']").text(toThousands(sumXssl));
            $("#" + id + " [col='s-xsje']").text(toThousands(sumXsje));
            $("#" + id + " [col='s-kdl']").text(avgKdl);
            $("#" + id + " [col='s-kdj']").text(toThousands(avgKdj));
            $("#" + id + " [col='s-pjzk']").text(avgPjzk);
        }
           
        //千分位
        function toThousands(num) {
             var num = (num || 0).toString(), result = '';
             while (num.length > 3) {
                 result = ',' + num.slice(-3) + result;
                 num = num.slice(0, num.length - 3);
             }
             if (num) { result = num + result; }
             return result;
         }

        $(".filterdiv").on("click", function () {
            $(".mymask").show();
            $("#fiterpage").removeClass("page-right");
        })

        $(".mymask").on("click", function () {
            $("#fiterpage").addClass("page-right");
            $(".mymask").hide();
        })

        //筛选事件绑定
        $("div[filter='kfbh'] .fitem").on("click", function () {
            if ($(this).hasClass("selected"))
                $(this).removeClass("selected");
            else {
                $("div[filter='kfbh'] .selected").removeClass("selected");
                $(this).addClass("selected");
            }
        });
        
        $("div[filter='khfl'] .fitem").on("click", function () {
            if ($(this).hasClass("selected"))
                $(this).removeClass("selected");
            else {
                $("div[filter='khfl'] .selected").removeClass("selected");
                $(this).addClass("selected");
            }
            //$("div[filter='zmdfl'] .selected").removeClass("selected");
            //$("div[filter='khfl'] .selected").removeClass("selected");
            //$(this).addClass("selected");
        });
        $("div[filter='zmdfl'] .fitem").on("click", function () {
            if ($(this).hasClass("selected"))
                $(this).removeClass("selected");
            else {
                $("div[filter='zmdfl'] .selected").removeClass("selected");
                $(this).addClass("selected");
            }
            //$("div[filter='khfl'] .selected").removeClass("selected");
            //$(this).addClass("selected");
        });

        //重置
        function ResetFilter() {
            $("#ksrq").val(new Date().format("yyyy-MM-dd"));
            $("#jsrq").val(new Date().format("yyyy-MM-dd"));
            filter.filter.ksrq="";
            filter.filter.jsrq="";
            filter.core.mdkhid=""; 
            filter.core.khid=""; 
            $(".fa-check-square").removeClass("active");
            $(".fa-check-square").addClass("active"); 
            $(".date input").css("color", "#000").removeAttr("readonly");
            $("div[filter='kfbh'] .fitem").removeClass("selected");
            $("div[filter='kfbh'] .fitem[dm='all']").addClass("selected");
            
            $("div[filter='khfl'] .fitem").removeClass("selected");

            $("div[filter='zmdfl'] .fitem").removeClass("selected");
            $("div[filter='zmdfl'] .fitem").eq(0).addClass("selected");
        }

        //筛选提交
        function SubmitFilter() {
            var kfbh = $("div[filter='kfbh'] .fitem.selected").attr("dm");            
            var khfl = $("div[filter='khfl'] .fitem.selected").attr("cs");
            var zmdfl = $("div[filter='zmdfl'] .fitem.selected").attr("cs");
            var ksrq = "",jsrq="";

            if($(".fa-check-square").hasClass("active")){
                ksrq=$("#ksrq").val();
                jsrq=$("#jsrq").val();
            }

            if(kfbh=="all"&&!$(".fa-check-square").hasClass("active")){
                alert("【开发编号】与【日期范围】必须至少限制一项！");
                return;
            }

            //filter.filter.kfbh = typeof(kfbh) == "undefined" ? "" : kfbh;
            if(kfbh=="all"||typeof(kfbh)=="undefined")
                filter.filter.kfbh="";
            else
                filter.filter.kfbh=kfbh;
            zmdfl = typeof(zmdfl) == "undefined" ? "" : zmdfl
            khfl= typeof(khfl) == "undefined" ? "" : khfl;
            khfl = khfl + '-' + zmdfl;
            
            filter.filter.khfl = khfl;
            filter.filter.ksrq = ksrq == "" ? "" : ksrq;
            filter.filter.jsrq = jsrq == "" ? "" : jsrq;
            $("#fiterpage").addClass("page-right");
            $(".mymask").hide();

            gotoSearch(); 
        }

        //视图返回动作
        function BackFunc() {
            if ("-" + defaultSite == ViewRoute) return;

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
            } //end switch
             
            if (CurrentSite != "") {
                $("#" + CurrentSite).removeClass("page-right");
				filter.core.lx = CurrentSite;
				
				switch (CurrentSite) {
					case "md":
						filter.core.mdkhid = ""; 
						break;
					case "lb":
						filter.core.lbid = ""; 
						break;
					case "sphh":
						$("#searchinput").val(""); 
						break;
					case "kh": 
						filter.core.khid = ""; 
						break;
				} //end switch				
            }

            ShowSearchCaption();
        }

        //打开视图
        function openFunc(newView) {
            if (CurrentSite == newView) return;

            if (CurrentSite != "") {
                $("#" + CurrentSite).addClass("page-right");
            }
            CurrentSite = newView;
            if (ViewRoute != newView)
                ViewRoute = ViewRoute + "-" + CurrentSite;

            $("#" + CurrentSite).removeClass("page-right");
        } 

         
        //计算合计值
        function StaticCount(id,sumCgsl,sumXssl,sumXsje,Wcl) {
            var ulobj = $("#" + id + " .data-ul li");
            for (var i = 1; i < ulobj.length; i++) {
                var row = ulobj.eq(i);
                var cgsl = ($("p[col='cgsl']", row).text());
                var lssl = ($("p[col='xssl']", row).text());
                var xsje = ($("p[col='xsje']", row).text());

                $("p[col='xsje']", row).text(GetJeText(xsje));

                if (cgsl == "")
                    cgsl = "0";
                if (lssl == "")
                    lssl = "0";
                if (xsje == "")
                    xsje = "0";
            } //end for  

            $("#" + id + " [col='s-cgsl']").text(GetJeText(sumCgsl));
            $("#" + id + " [col='s-xssl']").text(GetJeText(sumXssl));
            $("#" + id + " [col='s-xsje']").text(GetJeText(sumXsje));
        }

        function GetJeText(xsje){
            if (xsje == "") return "--";
            else {
                var intxsje = parseInt(xsje);

                if (intxsje < 100000) return intxsje;
                else return parseInt(intxsje * 0.0001).toString() + "万+";
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

        //检查视图路径,并返回路径是否重复
        function CheckViewRouteOK(){
            if (ViewRoute.indexOf(filter.core.lx) ==0 && ViewRoute.length > 5){
                return false;
            }else{
                return true;
            }
        }

        //开始查询
        function gotoSearch() {
            if ($("#comlist").val() == "-1")
                return;

            if (CheckViewRouteOK() == false){ 
                LeeJSUtils.showMessage("warn", "已经钻取到最后一层啦！");
                filter.core.lx = CurrentSite;//回退变量否则会有问题                
                $("#searchinput").val("");
                return;
            }

            var SearchTxt = $("#searchinput").val();
            filter.spsearch = SearchTxt;
            filter.auth.curkhid = $("#comlist").val(); 

            if (filter.auth.curkhid == null)    filter.auth.curkhid = "";
             
            var roleID = <%= roleID %>; //增加判定，如果是门店用户并且试图访问贸易公司报表，则强制指定到门店报表
            if (roleID < 3 && roleID > 0 && filter.core.lx == "kh") filter.core.lx = "md";

            //贸易公司角色
            var ssid = $("#comlist option[value=" + $("#comlist").val() + "]").attr("data-ssid");
            if (roleID == "4") {
                if (ssid != "1" && ssid != "") {  
                    if (filter.core.lx == "kh")    filter.core.lx = "md"; 
                                           
                    filter.core.khid=ssid;                    
                    filter.auth.curkhid=ssid;
                    filter.core.mdkhid = $("#comlist").val();
                } else if (ssid == "1") {
                    filter.auth.curkhid = $("#comlist").val();
                    filter.core.khid = filter.auth.curkhid;
                    if(CurrentSite == "kh") filter.core.mdkhid = "";
                }
            }
            ShowSearchCaption(); 
            
            filter.order.colname = eval("orders." + filter.core.lx + ".colname");
            filter.order.ordertype =  eval("orders." + filter.core.lx + ".ordertype");

            switch (filter.core.lx) {
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
                default:
                    LoadSPHHData();
                    break;
            } //end switch 
            localStorage.setItem("lszhfx-filter", JSON.stringify(filter));
            ShowOrder();
        }

        $("#comlist").on("change", function () {
            var roleID = "<%= roleID %>";
            if (roleID != "4")
                return;
            else {
                ResetFilter();
                //gotoSearch();                
                $(".filterdiv").click();
            }
        });

             //排序功能
        $(".item-head p").on("click", function () {
            var ordername = $(this).attr("ordername");
            var viewID = $(this).parents(".page").attr("id"); 
                         
            if (ordername == orders[viewID].colname){
                if (orders[viewID].ordertype == "asc") orders[viewID].ordertype = "desc";
                else orders[viewID].ordertype = "asc";
            }else{
                orders[viewID].colname = ordername;
                orders[viewID].ordertype = "desc";
            }
            
            gotoSearch();  
        });
         
        //显示排序项
        function ShowOrder(){         
            var viewID = filter.core.lx;
            var $p = $("#" + viewID);
            
            $p.find("i").remove(); //移除所有的i标记

            $p.find(".item-head p[ordername='" + orders[viewID].colname + "']").append("<i class='fa fa-sort-" + orders[viewID].ordertype + "'></i>");
        } 
        
        //显示钻取和筛选项 
        function ShowSearchCaption(){　
            var CoreText = "";
            var FilterText = "";
            var AllText = "";

            if (filter.core.khid != "") { CoreText = CoreText + "[贸]"; }
            if (filter.core.mdkhid != "") { CoreText = CoreText + "[店]"; }
            if (filter.core.lbid != "") { CoreText = CoreText + "[类]"; }
            
            if (filter.filter.kfbh != "") { FilterText = FilterText + "|开发编号:" + filter.filter.kfbh; }
            if (filter.filter.ksrq != "") { FilterText = FilterText + "|日期:" + filter.filter.ksrq + "～" + filter.filter.jsrq; }
            if (filter.filter.khfl != "") { FilterText = FilterText + "|客户类别:" + filter.filter.khfl; }
            　
            if (CoreText != "") AllText = "钻取:<span style='color:#f00'>" + CoreText + "</span>";
            if (FilterText != "") AllText = AllText + FilterText;
            
            //显示到外面　
            $(".filterInfo .filters").html(AllText);
        } 

        //搜索按钮
        $(".fa-search").on("click",  gotoSearch);

        //日期筛选条件是否生效
        $(".fa-check-square").on("click", function () {
            if ($(this).hasClass("active")) {
                filter.filter.ksrq="";
                filter.filter.jsrq="";
                $(".date input").css("color", "#ccc").attr("readonly", "true");
                $(this).removeClass("active");
            } else {
                $(".date input").css("color", "#000").removeAttr("readonly");
                $(this).addClass("active");
            }
        });

        //切换显示方式
        $(".viewicon").on("click", function () {
            var status = $(".viewtype").css("display");
            if (status == "none")
                $(".viewtype").fadeIn(200);
            else
                $(".viewtype").fadeOut(200);
        });

        $(".viewtype li").on("click", function () {
            var dm=$(this).attr("dm");
            var url=window.location.href;            
            setUrlParam("ViewType",dm);            
        });

        //para_name 参数名称 para_value 参数值 url所要更改参数的网址
        function setUrlParam(para_name, para_value) {
            var strNewUrl = new String();
            var strUrl = new String();
            var url = new String();
            url= window.location.href;
            strUrl = window.location.href;
            //alert(strUrl);
            if (strUrl.indexOf("?") != -1) {
                strUrl = strUrl.substr(strUrl.indexOf("?") + 1);
                //alert(strUrl);
                if (strUrl.toLowerCase().indexOf(para_name.toLowerCase()) == -1) {
                    strNewUrl = url + "&" + para_name + "=" + para_value;
                    window.location = strNewUrl;
                    //return strNewUrl;
                } else {
                    var aParam = strUrl.split("&");
                    //alert(aParam.length);
                    for (var i = 0; i < aParam.length; i++) {
                        if (aParam[i].substr(0, aParam[i].indexOf("=")).toLowerCase() == para_name.toLowerCase()) {
                            aParam[i] = aParam[i].substr(0, aParam[i].indexOf("=")) + "=" + para_value;
                        }
                    }
                    strNewUrl = url.substr(0, url.indexOf("?") + 1) + aParam.join("&");
                    //alert(strNewUrl);
                    window.location = strNewUrl;
                    //return strNewUrl;
                }
            } else {
                strUrl += "?" + para_name + "=" + para_value;                
                window.location=strUrl;
            }
        }
        
        $("#searchinput").keydown(function (e) {
            var curKey = e.which;
            if (curKey == 13) {
                gotoSearch();                
                return false;
            }            
        });
    </script>
</asp:Content>
