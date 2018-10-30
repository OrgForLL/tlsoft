<%@ Page Title="" Language="C#" MasterPageFile="../../WebBLL/frmQQDBase.Master" AutoEventWireup="true" %>
<%@ MasterType VirtualPath="../../WebBLL/frmQQDBase.Master" %>
<%@ Import Namespace="nrWebClass" %>
<%@ Import Namespace="System.Data" %>
<%@ Import Namespace="System.Data.SqlClient" %>
<%@ Import Namespace="System.Collections.Generic" %>
<%@ Import Namespace="System.Net" %>
<%@ Import Namespace="System.IO" %>

<script runat="server">
    string mdid, mdmc, showType, sphh = "", RoleID,khListJson="0";
    public List<string> wxConfig; //微信OPEN_JS 动态生成的调用参数
    private const string ConfigKeyValue = "1";
    // string OAConnStr = clsConfig.GetConfigValue("OAConnStr");
    string OAConnStr = " server=192.168.35.10;uid=ABEASD14AD;pwd=+AuDkDew;database=tlsoft";
    //必须在内容页的Load中对Master.SystemID 进行赋值；
    protected void Page_Load(object sender, EventArgs e)   
    {
        showType = Convert.ToString(Request.Params["showType"]);
        if (showType == string.Empty)
        {
            showType = "0";
        }else if (showType == "2") //  区分鉴权(1.门店人员 | 2.顾客)
        {
            this.Master.IsTestMode = true;
        }
        else
        {
            this.Master.IsTestMode = false;
        }
    }
    protected void Page_PreRender(object sender, EventArgs e)
    {
        string codeType =Convert.ToString(Request.Params["codeType"]);
        string qrcodeid = Convert.ToString(Request.Params["qrcodeid"]);
        string paraSphh = Convert.ToString(Request.Params["sphh"]);
       

        if (codeType != "" && codeType!=null)
        {
            sphh = getScanSphh(codeType, qrcodeid);
            if (sphh.IndexOf(clsNetExecute.Error) > 0)
            {
                sphh = "";
            }
        }

        if (paraSphh != null && paraSphh != "")
        {
            sphh = paraSphh;
        }
        
        RoleID = Convert.ToString(Session["RoleID"]);
        if (RoleID == null || RoleID == "")
        {
            RoleID = "0";
        }
        
        if (showType == "1") //  区分鉴权(1.门店、贸易公司、总部人员 | 2.顾客)
        {
            if (RoleID == "1" || RoleID == "2")//1店员、2店长
            {
                mdid = Convert.ToString(Session["mdid"]);
                setMdmc(mdid);
            }
            else if (RoleID == "3" || RoleID == "99")//总部人员
            {
                mdid = "1";
                mdmc = "总部";
            }
            else if(RoleID=="4") //贸易公司人员
            {
                DataTable dt = clsWXHelper.GetQQDAuth(true, false);
                if (dt!= null && dt.Rows.Count > 0)
                {
                    string khid = Convert.ToString(Request.Params["khid"]);
                    if (khid != null && khid.Trim() != "")
                    {
                        DataRow []dr = dt.Select(string.Format("khid={0}",khid));
                        if (dr.Length > 0)
                        {
                            mdid = Convert.ToString(dr[0]["khid"]);
                            mdmc = Convert.ToString(dr[0]["mdmc"]);
                        }
                        else
                        {
                            mdid = Convert.ToString(dt.Rows[0]["khid"]);
                            mdmc = Convert.ToString(dt.Rows[0]["mdmc"]);
                        }
                    }
                    else
                    {
                        mdid = Convert.ToString(dt.Rows[0]["khid"]);
                        mdmc = Convert.ToString(dt.Rows[0]["mdmc"]);
                    }
                    
                    khListJson=JsonHelp.dataset2json(dt);
                    dt.Dispose();
                }
                else
                {
                    clsWXHelper.ShowError("您没有任何贸易公司的权限！");
                }
                dt.Dispose();
            }
        }
        else if (showType == "2")//顾客
        {
            mdid = "0";
            mdmc = "商品信息";
        }
        else
        {
            clsWXHelper.ShowError("无权限或获取权限异常(Other),请重试！");
        }
        wxConfig = clsWXHelper.GetJsApiConfig(ConfigKeyValue);
    }
    private void setMdmc(string mdid)
    {
        string mdmc = "";
        using (LiLanzDALForXLM MDal = new LiLanzDALForXLM(OAConnStr))
        {
            DataTable dt = null;
            string strsql = @" select top 1 mdmc from t_mdb a where a.mdid=@mdid";
            List<SqlParameter> param = new List<SqlParameter>();
            param.Add(new SqlParameter("@mdid", mdid));
            string errinfo = MDal.ExecuteQuerySecurity(strsql, param, out dt);
            if (errinfo == "" && errinfo.Length == 0)
            {
                if (dt.Rows.Count > 0)
                {
                    mdmc = Convert.ToString(dt.Rows[0][0]);
                }
                else
                {
                    clsWXHelper.ShowError("无权限或获取权限异常(Store),请重试！");
                }
            }
            else
            {
                clsWXHelper.ShowError("获取门店信息数据时出错 info:" + errinfo);
            }
            dt.Rows.Clear(); dt.Dispose();  //释放资源
        }
    }
    private string getScanSphh(string scanType, string scanResult)
    {
        string errInfo, mysql, rt = "";
        switch (scanType)
        {
            case "qrCode": mysql = @"declare @strGood varchar(30) select @strGood=dbo.f_DBPwd('{0}') 
                        select @strGood = (CASE WHEN (LEN(@strGood) > 13) 
                        THEN SUBSTRING(@strGood, 1, LEN(@strGood) - 6) ELSE @strGood END) 
                        select top 1 @strGood = a.sphh from yx_t_tmb a where tm=@strGood 
                        SELECT @strGood as sphh ";
                break;
            case "barCode": mysql = @"declare @strGood varchar(30)  select @strGood = SUBSTRING('{0}', 1, LEN('{0}') - 6)
                          select top 1 @strGood = a.sphh from yx_t_tmb a where tm=@strGood ; SELECT @strGood  as sphh ";
                break;
            default: mysql = "";
                break;
        }
        DataTable dt;
        if (mysql != "")
        {
            using (LiLanzDALForXLM dal = new LiLanzDALForXLM(OAConnStr))
            {
                errInfo = dal.ExecuteQuery(string.Format(mysql, scanResult), out dt);
            }
            if (errInfo != "")
            {
                rt = errInfo;
            }
            else if (dt.Rows.Count < 1)
            {
                rt = clsNetExecute.Error + "无效条码，无法找到相关信息";
            }
            else
            {
                rt = Convert.ToString(dt.Rows[0]["sphh"]);
            }
        }
        else
        {
            rt = clsNetExecute.Error + "非法访问0。";
        }
        return rt;
    }
</script>
<asp:Content ID="Content1" ContentPlaceHolderID="head" runat="server">
    <meta name="format-detection" content="telephone=no" />
    <link type="text/css" rel="stylesheet" href="../../res/css/LeePageSlider.css" />
    <link type="text/css" rel="stylesheet" href="../../res/css/vipweixin/touchSlider.css" />
    <link type="text/css" rel="stylesheet" href="../../res/css/font-awesome.min.css" />

    <link rel="stylesheet" href="../../res/css/StoreSaler/layout.css" type="text/css" />
    <link type="text/css" rel="stylesheet" href="../../res/css/StoreSaler/base.css" />
    <link type="text/css" rel="stylesheet" href="../../res/css/StoreSaler/layer.css" />
    <link type="text/css" rel="stylesheet" href="../../res/css/StoreSaler/shop.css" />
    <style type="text/css">
        body {
            background-color: #f7f7f7;
            color: #2f2f2f;
            font-family: Helvetica,Arial,STHeiTi,"Hiragino Sans GB","Microsoft Yahei","微软雅黑",STHeiti,"华文细黑",sans-serif;
        }

        .header {
            height: 50px;
            line-height: 50px;
            width: 100%;
            text-align: center;
            font-size: 1.2em;
            letter-spacing: 2px;
            background-color: #000;
            color: #fff;
            border-bottom: 1px solid #e5e5e5;
        }

        .fa-angle-left {
            font-size: 1.4em;
            position: absolute;
            top: 0;
            bottom: 0;
            left: 0;
            padding: 0 18px;
            line-height: 50px;
            color: #fff;
        }

            .fa-angle-left:hover {
                background-color: rgba(0,0,0,.1);
            }

        .page {
            top: 50px;
            bottom: 32px;
            padding: 0;
            background-color: #f7f7f7;
        }

        .banner {
            height: 220px;
            margin-top: -1px;
            background-color: #fafafa;
        }

        .foot-btns {
            background-color: #eceef1;
            height: 48px;
            line-height: 48px;
            font-size: 0;
        }

            .foot-btns > a {
                display: inline-block;
                text-align: center;
                width: 40%;
                color: #575d6a;
                font-size: 16px;
            }

            .foot-btns .color-btn {
                background-color: #575d6a;
                color: #fff;
                width: 60%;
            }

        .product-info, .product-stock, .product-detail1, .product-detail2, .product-cminfo,.product-sameStyle {
            background-color: #fff;
            margin: 5px 0;
            padding: 0 5px;
            box-shadow: 0 1px .5px #eceef1;
            -webkit-box-shadow: 0 1px .5px #eceef1;
            position: relative;
        }
        .product-info {
            padding:0 10px;
        }
            .product-info .fa-star, .product-info .fa-star-o {
                position: absolute;
                top: 0;
                right: 0;
                font-size: 22px;
                line-height: 44px;
                padding: 0 15px;
                margin-top: 8px;
                border-left: 1px solid #f2f2f2;
            }

            .product-info .pro-name {
                font-size: 1.1em;
                font-weight: bold;
                color: #555;
                /*line-height: 30px;*/
                padding-top:5px;
                color:#2b363a;
            }
        .product-info .llzp,.product-info .zdzt {
            background-color: #000;
            color: #fff;
            padding: 4px 8px;
            font-size: 12px;            
            line-height: 28px;
            margin-right:5px;
        }
            .product-info .zdzt {
                background-color:#e54801;
            }
        .points {
            color: #888;
            font-size: 1.2em;
            font-weight: bold;
            margin-top: 5px;
        }

            .points span {
                color: #ff6600;
                font-size: 1.5em;
                font-weight: bold;
            }
        .money {
            color:#ff5000;
        }
        .money span {            
            font-size: 1.2em;            
        }

        .product-stock li {
            list-style-type: none;
            margin: 0 1.6666% 8px;
            box-sizing: border-box;
            color: #000;
            text-align: center;
            width: 30%;
            height: 28px;
            line-height: 28px;
            overflow: hidden;
            word-break: break-all;
            white-space: nowrap;
            text-overflow: ellipsis;
            border-radius: 2px;
            display: inline-block;
        }

            .product-stock li.none {
                color: #c5c9cd;
                border: 1px solid #d8dcdf;
                background-color: #f0f1f3;
            }

            .product-stock li.choose {
                border: 1px solid #000;
                background: #fff;
                cursor: pointer;
            }

        .product-stock .title, .product-cminfo .title {
            font-size: 16px;
            letter-spacing: 1px;
            /*border-bottom: 1px solid #f7f7f7;*/
            margin-bottom: 8px;
            border-left: 4px solid #333;
            padding: 8px 0 8px 8px;
            font-weight: 600;
        }

        .product-stock {
            font-size: 1.1em;
        }

            .product-stock > p {
                line-height: 20px;
            }

        .product-detail1 {
            font-size: 1.1em;
        }

            .product-detail1 > p {
                line-height: 20px;
            }

            .product-detail1 .title {
                font-size: 16px;
                letter-spacing: 1px;
                /*border-bottom: 1px dashed #f2f2f2;*/
                border-left: 4px solid #333;
                padding: 8px 0 8px 8px;
                font-weight: 600;
            }

        .product-detail2 {
            padding-top: 8px;
        }

            .product-detail2 > img {
                width: 100%;
                height: auto;
                margin-top: 10px;
            }

            .product-detail2 .title {
                font-size: 16px;
                letter-spacing: 1px;
                /*border-bottom: 1px solid #f7f7f7;*/
                margin: -8px 0 0 0;
                border-left: 4px solid #333;
                padding: 8px 0 8px 8px;
                font-weight: 600;
            }

            .product-detail2 p {
                line-height: 20px;
            }
        /*幻灯区样式*/
        .main_image, .main_image ul, .main_image li, .main_image li span, .main_image li a {
            height: 220px;
        }

        div.flicking_con .flicking_inner {
            top: 200px;
        }

        .product-stock .u-detail-sl {
            color: #d9534f;
            line-height: 28px;
        }

        .flicking_inner a {
            border: #c9c9c9 0px solid;
        }

        .product-stock ul {
            padding: 0px;
        }

        .footer {
            text-align: center;
            height: 30px;
            line-height: 30px;
            font-size: 12px;
            background-color: transparent;
            color: #999;
        }

        .u-pro-list-top {
            margin-top: 40px;
        }

        p, .p {
            margin-bottom: 0;
        }

        .product-detail2 .img-tips {
            text-align: center;
            font-size: 12px;
            color: #333;
            font-weight: 600;
        }

        .money span {
            line-height: 24px;
        }

        td {
            padding: 2px 0;
        }

        .header .icon-camera {
            font-size: 1.2em;
        }

        .top-fixed .top-search input {
            line-height: 30px;
        }

        .top-fixed .top-title {
            white-space: nowrap;
            max-width: 210px;
            text-overflow: ellipsis;
        }
        /*cminfos style*/
        .product-cminfo .cm-content {
            width: 100%;
            height: 220px;
            overflow: auto;
            -webkit-overflow-scrolling: touch;
        }

        .cm-table {
            border-collapse: collapse;
            border: none;
            margin: 0 auto;
            color: #333;
        }

            .cm-table th {
                font-size: 14px;
                background-color: #535353;
                color: #fff;
                white-space: nowrap;
            }

            .cm-table td, .cm-table th {
                border: solid #e1e1e1 1px;
                min-width: 60px;
                text-align: center;
                padding: 6px 10px;
            }

        .cm-tips {
            padding: 5px 0;
        }

            .cm-tips p {                
                color: #666;
                font-size: 14px;
                font-weight: 600;
                line-height: 1.4;
            }
        .header {
            border-bottom:none;
        }
          .product-sameStyle .title {
                font-size: 16px;
                letter-spacing: 1px;
                /*border-bottom: 1px solid #f7f7f7;*/
                margin: -8px 0 0 0;
                border-left: 4px solid #333;
                padding: 8px 0 8px 8px;
                font-weight: 600;
            }
              .product-sameStyle a {
                padding:0px;
            }
           #sameStyle dl
            {
                float:left;
            }
            .b_goods_name_sameStyle
            {
                height:25px;
            }
           #sameStyle dl a dt
            {
              padding-bottom:100%;
            }
             
                #sameStyle dl a dt img
            {
              width:auto;
              height:180px;
            }
            .product-stock p
             {
               background-color:#F4A460;
             }
            .product-stock p span 
            {
               padding:15px 5px 15px 0px;
               color:Gray;
            }
            .product-stock p :first-child 
            {
               color:#000;
            }
            .product-sameStyle
          {
              display:none;
          }
         .icon-chevron-right
         {
             float:right;
         }
         .opinionClass
         {
             margin-right:15px;
             font-weight:normal;
             font-size:14px;
         }
           .myKhList
           {
               z-index:1000;
               background-color:Black;
               display:block;
               position:fixed;
               margin-top:-45px;
               text-align:center;
               width:100%;
               color:White;
               font-style:italic;
               font-size:15px;
              display:none;
           }
         .myKhList ul
         {
             padding:0;
             margin:0;
         }
          .myKhList ul li
         {
            padding:0px 0 6px 0;
            width:100%;
            border-right:1px ;
            border-top:1px double Grey ;
            padding-top:5px;
         }
         .x3
         {
             text-align:center;
             width:33.33%;
         }
        .product-stock {
            padding-top:15px;
        }
        .product-stock .nav_nums {
            border: 1px solid #d96a59;
            border-radius: 2px;
            margin: 0 auto 15px auto;
            width: 90%;
            font-size: 14px;
        }

            .product-stock .nav_nums li {
                float: left;                
                width: 20%;
                margin: 0;
                border-radius: 0; 
                border-right:1px solid #d96a59;  
                color:#999;            
            }
                .product-stock .nav_nums li.selected {
                    background-color:#d96a59;
                    color:#fff;
                }
                .product-stock .nav_nums li:last-child {
                    border-right:none;
                }
        .col3 {
            width:33.33%;
        }
    </style>
</asp:Content>
<asp:Content ID="Content2" ContentPlaceHolderID="ContentPlaceHolder1" runat="server">
    <div class="html_container">
        <div id="htmlList">

            <script type="text/html" id="page1"> 
                <div class="top-fixed bg-yellow bg-inverse">
                    <div class="top-back">
                        <a class="top-addr" href="javascript:Scan()"><i class="icon-camera"></i></a>
                    </div>
                    <div class="top-title">
                       <li onclick="KhSelectList()"> <i id="mdmc"><%=mdmc %></i> <i class="icon-sort-down "></i></li>
                    </div>
                    <div class="top-search" style="display: none;">
                        <input id="keyword" name="keyword" placeholder="输入商品货号" />
                        <button type="button" class="icon-search" onclick="searchFunc()"></button>
                    </div>
                    <div class="top-signed">
                        <a id="search-btn" href="javascript:void(0);"><i class="icon-search"></i></a>
                    </div>
                </div>

                 <div class="myKhList">
                 </div>

                <div id="search-bar" class="search-bar">
                    <ul class="line">
                        <li class="x3"><span>库存</span><i></i></li>
                       <!-- <li class="x3"><span>类别</span><i></i></li>-->
                        <li class="x3"><span>主推</span><i></i></li>
                        <li class="x3"><span>排序</span><i></i></li>
                    </ul>
                </div>

                

                <div class="serch-bar-mask" style="display: none;">
                    <div class="serch-bar-mask-list">
                        <ul>
                            <li class="on"><a href="javascript:goodsfilter('kczt','')">全部</a></li>
                            <li><a title="有货" href="javascript:goodsfilter('kczt','1')">有货商品</a></li>
                            <li><a title="缺货" href="javascript:goodsfilter('kczt','0')">缺货商品</a></li>
                        </ul>
                    </div>
                    <div class="serch-bar-mask-list">
                        <ul>
                            <li class="on"><a href="javascript:goodsfilter('splb','')">全部</a></li>
                            <li><a title="西服" href="javascript:goodsfilter('splb','西服')">西服</a></li>
                            <li><a title="茄克" href="javascript:goodsfilter('splb','茄克')">茄克</a></li>
                            <li><a title="风衣" href="javascript:goodsfilter('splb','风衣')">风衣</a></li>
                            <li><a title="裤子" href="javascript:goodsfilter('splb','裤')">裤子</a></li>
                        </ul>
                    </div>
                    <div class="serch-bar-mask-list">
                        <ul>
                            <li class="on"><a href="javascript:goodsfilter('yxzt','')">全部</a></li>
                            <li><a title="主推" href="javascript:goodsfilter('yxzt',1)">主推商品</a></li>
                        </ul>
                    </div>
                    <div class="serch-bar-mask-list">
                        <ul>
                            <li><a href="#">新货排序</a></li>
                        </ul>
                    </div>
                    <div class="serch-bar-mask-bg"></div>
                </div>
                <div id="main" class="u-pro-list clearfix u-pro-list-top">
                </div>

                <div class="u-more-btn"><a href="javascript:goodsList();" id="u-more-btn">- 加载更多 -</a></div>
            </script>
        </div>
        <div id="htmlDetail">
        </div>
 
        <script type="text/html" id="page2">
            <div class="header">
                <i class="fa fa-angle-left" onclick="javascript:childDetail();"></i>
                <i class="fa-angle-left icon-camera" onclick="javascript:Scan()"></i>
                商品详情
            </div>
            <div id="goodsDetail" class="wrap-page none">
                <div class="page page-not-header-footer" id="main-page">
                    <!--幻灯片区-->
                    <div class="banner">
                        <div class="main_visual">
                            <div class="flicking_con">
                                <div class="flicking_inner">
                                    <!--样衣图序号-->
                                </div>
                            </div>
                            <div class="main_image">
                                <!--样衣图-->
                            </div>
                        </div>
                    </div>
                    <div class="product-info" style="margin-top: 0; padding-bottom: 5px;">
                        <!-- 商品一般信息高亮 -->
                        <i class="fa fa-star"></i>
                    </div>
                    <div class="product-stock">
                        <!-- 商品库存信息 -->
                    </div>
                    <div class="product-detail1">
                        <!-- 商品信息(卖点成份) -->
                    </div>
                    <!-- 货号尺码信息 20160613 by liqf -->
                    <div class="product-cminfo">
                        <p class="title">尺码信息：单位CM</p>
                        <div class="cm-content">
                            <table class="cm-table">
                            </table>
                        </div>
                        <div class="cm-tips">
                            <p>1、尺码信息过多时，请滑动表格查看；</p>
                            <p>2、尺码表数据仅供参考，由于人工测量，可能会存在1-2cm左右偏差；</p>
                        </div>
                    </div>
                      <div class="product-sameStyle" id="OpinionFeedback" style="display:none;">
                        
                     </div>
                    <div class="product-detail2" >
                        <!--<p class="title">商品详情</p>-->
                    </div>
                    
                    <div class="product-sameStyle">
                        <p class="title">同款商品</p>
                        <div id="sameStyle" class="u-pro-list clearfix ">
                            <dl class="rs-item pg1 j_item_image_sameStyle" data-mid="270">
                                <a class="clearfix ablock " href="javascript:data_mid='270';goodsDetail('6QZC0034Y','正统长衬-蓝色','399.00')">
                                     <dt class="pic"  >
                                         <img class="j_item_image pg1" src="http://webt.lilang.com:9001/MyUpload/201606QJ/6QZC0034Y/6QZC0034Y-01.jpg" data-onerror="http://webt.lilang.com:9001/MyUpload/201606QJ/6QZC0034Y/6QZC0034Y-01.jpg" data-productid="200" data-brandid="1">
                                     </dt> 
                                     <dd class="b_goods_sphh">6QZC0034Y </dd> 
                                     <dd class="b_goods_name b_goods_name_sameStyle">正统长衬-蓝色</dd> 
                                </a>
                            </dl>
                        </div>
                    </div> 

                </div>
            </div>
            <div class="footer">
                &copy;2016 利郎(中国)有限公司						
            </div>
        </script>
    </div>
    <script type="text/javascript" src="http://res.wx.qq.com/open/js/jweixin-1.0.0.js"></script>
    <script type="text/javascript" src="../../res/js/jquery.js"></script>
    <script type="text/javascript" src="../../res/js/vipweixin/jquery.event.drag-1.5.min.js"></script>
    <script type="text/javascript" src="../../res/js/vipweixin/jquery.touchSlider.js"></script>
    <script type="text/javascript" src="../../res/js/LeeJSUtils.min.js"></script>
    <script type="text/javascript">
        if ("<%=showType%>" == "2") {
            //对外顾客
            $('#htmlDetail').html($("#page2").html());
            $(".fa.fa-angle-left").hide();
            $("#goodsDetail").hide();
        } else {
            //内部使用可以看到库存
            $('#htmlList').html($("#page1").html());
            $("#main").css(top, "100px");
        }

    </script>
    <script>
        $(function () {
            $("#serch-bar-mask-bg").click(function () {
                $(".serch-bar-mask").hide();
            });
            $("#search-btn").click(function () {
                if ($(".top-search").css("display") == 'block') {
                    $("#search-btn").children("i").removeClass("icon-remove").addClass("icon-search");
                    $(".top-search").hide();
                    $(".top-title").show(200);
                    $("#main dl").show();
                }
                else {
                    $("#search-btn").children("i").removeClass("icon-search").addClass("icon-remove");
                    $(".top-search").show();
                    $(".top-title").hide(200);
                }
            });

            $("#search-bar li").each(function (e) {
                $(this).click(function () {
                    if ($(this).hasClass("on")) {
                        $(this).parent().find("li").removeClass("on");
                        $(this).removeClass("on");
                        $(".serch-bar-mask").hide();
                    }
                    else {
                        $(this).parent().find("li").removeClass("on");
                        $(this).addClass("on");
                        $(".serch-bar-mask").show();
                    }
                    $(".serch-bar-mask .serch-bar-mask-list").each(function (i) {
                        if (e == i) {
                            $(this).parent().find(".serch-bar-mask-list").hide();
                            $(this).show();
                        }
                        else {
                            $(this).hide();
                        }
                        $(this).find("li").click(function () {
                            $(this).parent().find("li").removeClass("on");
                            $(this).addClass("on");
                            (function () { setTimeout(function () { $(".serch-bar-mask").hide(); $("#search-bar").find("li").removeClass("on"); }, 200); })();
                        });
                    });
                });
            });
        });
	
    </script>
    <script type="text/javascript">
        var appIdVal = "<%=wxConfig[0]%>", timestampVal = "<%=wxConfig[1]%>", nonceStrVal = "<%=wxConfig[2]%>", signatureVal = "<%=wxConfig[3]%>";
        var lastID = "-1", searchLastID = "-1";
        var isProcessing = false; //用于控制在上一次操作完成后才能开始扫下一个二维码
        var data_mid = ""; //由于是单页所以当分享出去的是详情页时根据此参数来判断  当对内时存放的是列表对应的data-mid对外则存放的是对应扫描的值
        var codeType = "";
        var sphh = "<%=sphh %>"; //页面sphh
        var viewType = "<%=showType%>";
        var mdid="<%=mdid %>";
        var mdmc="<%=mdmc %>";
        var khList=<%=khListJson %>;

        window.onload = function () {
            wxConfig(); //微信接口注入
            if (sphh != "" && sphh != undefined) {
                goodsDetail(sphh,"","");
                $(".header").find("i:first-child").hide();
                  $(".header").find("i:last-child").show()
               // $(".fa-angle-left").show();
                //$(".fa-angle-left icon-camera").show();
            } else {
                goodsList();
            }
            if("<%=RoleID %>"=="4" && khList.rows.length>1){
            //<li onclick="selectKh('1384','福建福州嘉润鸿贸易有限责任公司')">福建福州嘉润鸿贸易有限责任公司</li>
                var tempLi="<li onclick=selectKh('#khid#','#khmc#')>#khmc#</li>"
                var tempHtml="";
                for(var i=0;i<khList.rows.length;i++){
                    if(khList.rows[i]["khid"].toString()!=mdid){
                        tempHtml+=tempLi.replace(/\#khid#/g, khList.rows[i]["khid"].toString()).replace(/\#khmc#/g, khList.rows[i]["mdmc"].toString());
                    }
                }
                $(".myKhList").html("<ul>"+tempHtml+"</ul>");
            }else{
                $(".icon-sort-down").css("display","none");
            }
           
           LeeJSUtils.stopOutOfPage("#main-page",true);
           LeeJSUtils.stopOutOfPage(".header",false);
           LeeJSUtils.stopOutOfPage(".footer",false);
            //$(".icon-sort-down").css("display","");
        }
       function wxConfig () {//微信js 注入
              wx.config({
                  debug: false, // 开启调试模式,调用的所有api的返回值会在客户端alert出来，若要查看传入的参数，可以在pc端打开，参数信息会通过log打出，仅在pc端时才会打印。
                  appId: appIdVal, // 必填，企业号的唯一标识，此处填写企业号corpid
                  timestamp: timestampVal, // 必填，生成签名的时间戳
                  nonceStr: nonceStrVal, // 必填，生成签名的随机串
                  signature: signatureVal, // 必填，签名，见附录1
                  jsApiList: ["scanQRCode", "previewImage", "onMenuShareTimeline", "onMenuShareAppMessage"] // 必填，需要使用的JS接口列表，所有JS接口列表见附录2
              });
              wx.ready(function () {
                 // alert("注入成功");
              });
              wx.error(function (res) {
                 // alert("JS注入失败！");
              });
          }
          function goodsList() {
              ShowLoading("拼命加载列表中...", 15);
              $.ajax({
                  url: "goodsListCoreV3.aspx?ctrl=goodsListSingle",
                  type: "post",
                  dataType: "text",
                  data: { showType: "<%=showType %>", mdid:mdid, lastID: searchLastID },
                  cache: false,
                  timeout: 15000,
                  error: function (e) {
                      HideLoading();
                      ShowInfo("网络异常", 1);
                  },
                  success: function (res) {
                      if (res.indexOf("Error") > -1) {
                          HideLoading();
                          ShowInfo("未找到商品 " + res.replace("Error:", ""), 1);
                      } else if (res.indexOf("Warn") > -1) {
                          HideLoading();
                          ShowInfo("未找到相关商品信息", 1);
                      } else {
                          var obj = JSON.parse(res);
                          var temp = "<dl class='rs-item pg1' data-mid='$mid$'><a class='clearfix ablock' href=javascript:data_mid='$mid$';goodsDetail(\'$sphh$\',\'$spmc$\',\'$lsdj$\')> <dt class='pic'><img class='j_item_image pg1' src='$url$' data-brandlazy='false' data-onerror='$url$' data-productid='$productid$' data-brandid=1 /></dt> <dd class='b_goods_sphh'>$sphh$ </dd> <dd class='b_goods_name'>$spmc$</dd> <dd class='pricebox clearfix'> <span class='grallyprice f-left'>&yen;$lsdj$</span>  <span class='f-right discount'>库存 $kc$</span></dd></a> </dl>";
                          var htmlStr = "";
                          for (var i = 0; i < obj.rows.length; i++) {
                              if (obj.rows[i]["urlAddress"].toString() != "") {
                                  htmlStr += temp.replace(/\$mid\$/g, obj.rows[i]["xh"].toString()).replace(/\$url\$/g, "http://webt.lilang.com:9001" + obj.rows[i]["urlAddress"].toString().replace("..", '')).replace("$productid$", obj.rows[i]["xh"].toString()).replace(/\$sphh\$/g, obj.rows[i]["sphh"].toString()).replace(/\$spmc\$/g, obj.rows[i]["spmc"].toString()).replace(/\$lsdj\$/g, obj.rows[i]["lsdj"].toString()).replace(/\$kc\$/g, obj.rows[i]["kc"].toString());
                              } else {
                                  htmlStr += temp.replace(/\$mid\$/g, obj.rows[i]["xh"].toString()).replace(/\$url\$/g, "http://tm.lilanz.com" + "/oa/res/img/StoreSaler/lllogo5.jpg").replace("$productid$", obj.rows[i]["xh"].toString()).replace(/\$sphh\$/g, obj.rows[i]["sphh"].toString()).replace(/\$spmc\$/g, obj.rows[i]["spmc"].toString()).replace(/\$lsdj\$/g, obj.rows[i]["lsdj"].toString()).replace(/\$kc\$/g, obj.rows[i]["kc"].toString());
                              }
                          }
                          /*  没看懂这是干什么的
                          if (obj.rows.length == 0) {
                          htmlStr += temp.replace(/\$mid\$/g, obj.rows[i]["xh"].toString()).replace(/\$url\$/g, "http://tm.lilanz.com" + "/oa/res/img/StoreSaler/lllogo5.jpg").replace("$productid$", obj.rows[i]["xh"].toString()).replace(/\$sphh\$/g, obj.rows[i]["sphh"].toString()).replace(/\$spmc\$/g, obj.rows[i]["spmc"].toString()).replace(/\$lsdj\$/g, obj.rows[i]["lsdj"].toString()).replace(/\$kc\$/g, obj.rows[i]["kc"].toString());
                          }*/
                          $("#main").append(htmlStr);
                          searchLastID = $("#main dl:last-child").attr("data-mid");
                          $("#u-more-btn").text("-加载更多-");
                          HideLoading();
                          if (obj.rows.length == 1) { //筛选只有1条记录时直接进入detail
                              goodsDetail(scanResult, scanType);
                          } else {
                              ShowInfo("加载成功!", 1);
                              WXShareLink("");
                          }
                      }
                  }
              });
          }
           //加载详情页
          function goodsDetail(sphh,spmc,lsdj) {
              if ("<%=showType%>" != "2") {
                  $("#htmlList").hide();
                  $('#htmlDetail').html($("#page2").html()).show();
                  $(".fa-angle-left.icon-camera").hide();
              } else {
                  ShowLoading("拼命加载中...", 15);
              }
              $.ajax({
                  url: "goodsListCoreV3.aspx?ctrl=goodsDetail",
                  type: "post",
                  dataType: "text",
                  data: { showType: "<%=showType %>", mdid: mdid, sphh: sphh, showType: viewType },
                  cache: false,
                  timeout: 15000,
                  error: function (e) {
                      HideLoading();
                      ShowInfo("网络异常", 1);
                  },
                  success: function (res) {
                      var rtObj = JSON.parse(res);
                      var gDetail = rtObj.goodDetail;
                      myGoodsDeatil(gDetail);
                      if ("<%=showType%>" == "1") {
                          goodsStock(rtObj.gStock,sphh);
                      }
                      getOtherDetail(sphh);
                      WXShareLink(sphh);
                  }
              });
          }
           function myGoodsDeatil(obj) {
              if (typeof(obj)!="string") { //有正确返回
                  var htmlTemp = "<p class='pro-name'>$spmc$（$sphh$）</p><p class='money'>￥<span style='text-decoration: blink;'>$lsdj$</span></p><i class='fa fa-star-o'></i><span class='llzp'>利郎正品</span><span class='zdzt'>重点主推</span>";
                  var topHtml = "";
                  var htmlStr = htmlTemp.replace(/\$sphh\$/g, obj.rows[0]["sphh"].toString()).replace(/\$spmc\$/g, obj.rows[0]["spmc"].toString()).replace(/\$lsdj\$/g, obj.rows[0]["lsdj"].toString());
                  var endHtml = "<ul>";

                  for (var i = 0; i < obj.rows.length; i++) {
                      topHtml += "<a href='javascript:'>" + (i + 1) + "</a>";
                      endHtml += "<li><span class='img_" + (i + 1).toString() + "' onclick='javascript:previewImage(this);'></span></li>";
                  }
                 
                  endHtml += "</ul> <a href='javascript:;' id='btn_prev'></a> <a href='javascript:;' id='btn_next'></a>";
                  if ("<%=showType%>" == "2") {
                      $(".product-stock").hide();
                      $("#goodsDetail").show();
                  }
                  $(".flicking_inner").html(topHtml);
                  $(".main_image").html(endHtml);
                  $(".product-info").html(htmlStr);
                 if(Number(obj.rows[0]["kfbh"])<20161){
                      $(".money").hide();
                  }else{
                      $(".money").show();
                  }
                  for (var i = 0; i < obj.rows.length; i++) {
                      if (obj.rows[i]["urlAddress"].toString() != "") {
                          $(".img_" + (i + 1)).css({ "background": "url('" + "http://webt.lilang.com:9001" + obj.rows[i]["urlAddress"].toString().replace("..", '') + "') center center no-repeat", "background-size": "contain" });
                      } else {
                          $(".img_" + (i + 1)).css({ "background": "url('" + "http://tm.lilanz.com" + "/oa/res/img/StoreSaler/lllogo5.jpg" + "') center center no-repeat", "background-size": "contain" });
                      }
                  }
                  if (obj.rows.length > 1) {
                      (function () { //多图才轮播
                          $dragBln = false;
                          $(".main_image").touchSlider({
                              flexible: true,
                              speed: 250,
                              delay: 3000,
                              autoplay: true,
                              btn_prev: $("#btn_prev"),
                              btn_next: $("#btn_next"),
                              paging: $(".flicking_con a"),
                              counter: function (e) {
                                  $(".flicking_con a").removeClass("on").eq(e.current - 1).addClass("on");
                              }
                          });
                          $(".main_image").bind("mousedown", function () {
                              $dragBln = false;
                          })
                          $(".main_image").bind("dragstart", function () {
                              $dragBln = true;
                          })
                          $(".main_image a").click(function () {
                              if ($dragBln) {
                                  return false;
                              }
                          })
                          timer = setInterval(function () { $("#btn_next").click(); }, 5000);
                          $(".main_visual").hover(function () {
                              clearInterval(timer);
                          }, function () {
                              timer = setInterval(function () { $("#btn_next").click(); }, 5000);
                          })
                          $(".main_image").bind("touchstart", function () {
                              clearInterval(timer);
                          }).bind("touchend", function () {
                              timer = setInterval(function () { $("#btn_next").click(); }, 5000);
                          });
                      })();
                  }
              } else{
                  alert("对不起，查询不到该二维码信息！");
                  HideLoading();
                  return;
              }
          }
        //商品库存		
        function goodsStock(obj,sphh){  
           		if(typeof(obj)=="string"){
                  $(".product-stock").hide();	
                }else{
                var htmlTemp="<li $style$>$cm$<span class='u-detail-sl'>$sl$</span></li>";
                var htmlStr="",RoleID="<%=RoleID %>";
           		    if(RoleID=="3" || RoleID=="99"){
           		        //htmlStr= "<p class='title' ><span id='stock_kcxx' onclick=StockQuery('kcxx','"+sphh+"')>库存量</span><span id='stock_dhl' onclick=StockQuery('dhl','"+sphh+"')>订货量</span><span id='stock_xsl' onclick=StockQuery('xsl','"+sphh+"')>销售量</span><span id='stock_zzl' onclick=StockQuery('zzl','"+sphh+"')>周转量</span><span id='stock_bhl' onclick=StockQuery('bhl','"+sphh+"')>备货库存</span></p>";
           		        htmlStr= "<ul class='nav_nums floatfix' ><li class='selected' id='stock_kcxx' onclick=StockQuery('kcxx','"+sphh+"')>库存量</li><li id='stock_dhl' onclick=StockQuery('dhl','"+sphh+"')>订货量</li><li id='stock_xsl' onclick=StockQuery('xsl','"+sphh+"')>销售量</li><li id='stock_zzl' onclick=StockQuery('zzl','"+sphh+"')>周转量</li><li id='stock_bhl' onclick=StockQuery('bhl','"+sphh+"')>备货量</li></ul>";
           		    }else{
           		        //htmlStr= "<p class='title' ><span id='stock_kcxx' onclick=StockQuery('kcxx','"+sphh+"')>库存量</span><span id='stock_dhl' onclick=StockQuery('dhl','"+sphh+"')>订货量</span><span id='stock_xsl' onclick=StockQuery('xsl','"+sphh+"')>销售量</span></p>";
           		        htmlStr= "<ul class='nav_nums floatfix col3' ><li class='selected' id='stock_kcxx' onclick=StockQuery('kcxx','"+sphh+"')>库存量</li><li id='stock_dhl' onclick=StockQuery('dhl','"+sphh+"')>订货量</li><li id='stock_xsl' onclick=StockQuery('xsl','"+sphh+"')>销售量</li></ul>";
                }
                for(var i=0;i<obj.rows.length ;i++){
                    if(obj.rows[i]["sl"]>0){
                        htmlStr+=htmlTemp.replace(/\$sl\$/g,"("+obj.rows[i]["sl"].toString()+")").replace("$style$","class='choose'").replace("$cm$",obj.rows[i]["cm"].toString());                                   
                    }else{
                        htmlStr+=htmlTemp.replace(/\$sl\$/g,'').replace("$style$","class='none' ").replace("$cm$",obj.rows[i]["cm"].toString());
                    }
                }	
                $(".product-stock").empty();			   
                $(".product-stock").html(htmlStr);			
            }			
        }
        //加载详情页其他内容
        function getOtherDetail(sphh){
            $.ajax({
                url: "goodsListCoreV3.aspx?ctrl=otherDetail",
                type:"post",
                dataType: "text",
                data: { showType:<%=showType %>,mdid: mdid,sphh:sphh},
                catch: false,
                timeout: 15000,
                error: function(e){
                    HideLoading();				
                    ShowInfo("网络异常",1);
                },
                success:function (res){
                    var rtObj = JSON.parse(res);
                    var gImg = rtObj.goodsImg;
                    var CMInfos=rtObj.CMInfos;
                    var TheSameType = rtObj.TheSameType;
                    var OFBNum=rtObj.OFBNum;
                    goodsImg(gImg);
                    LoadCMInfos(CMInfos);
                    loadSameType(TheSameType);

                    if("<%=RoleID %>"==2 || "<%=RoleID %>"==3 ){
                        var t= "<p class='title' onclick=loadOFBContent('#sphh#')><span id='spyj'>商品意见</span><span class='opinionClass'></span><span class='icon-chevron-right'></span></p>";
                        t=t.replace("#sphh#",sphh);
                        $("#OpinionFeedback").html(t);
                        $("#OpinionFeedback").show();
                        if(OFBNum=="0"){
                            $(".opinionClass").html("(暂无意见)");
                        }else{
                            $(".opinionClass").html("("+OFBNum+")");
                        }
                    }else{
                        $("#OpinionFeedback").hide();
                    }
                }
            });
          }
          //linwy 重新加载库存信息
		function StockQuery(stockType,sphh){
            if(sphh==""){
                alert("无效数据,请重新加载");
                return;
            }
            //var t="kcxx|dhl|xsl|zzl|bhl";
            //var stockTypeArry=t.split('|');
            //for(var i=0;i<=stockTypeArry.length;i++){
            //    if(stockTypeArry[i]==stockType){
            //        $("#stock_"+stockType).css("color","#000");
            //    }else{
            //        $("#stock_"+stockTypeArry[i]).css("color","Grey");
            //    }
		    //}
            $(".product-stock .nav_nums .selected").removeClass("selected");
            $("#stock_"+stockType).addClass("selected");
		    //var htmlStr="<p class='title'>"+$(".product-stock").children("p").html()+"</p>";
            var htmlStr="<ul class='nav_nums floatfix'>"+$(".product-stock .nav_nums").html()+"</ul>";
            var htmlTemp="<li $style$>$cm$<span class='u-detail-sl'>$sl$</span></li>";
             ShowLoading("拼命加载中...", 15); 
            $.ajax({
                url: "goodsListCoreV3.aspx?ctrl=goodsStock",
                type:"post",
                dataType: "text",
                data: { showType:<%=showType %>,mdid:mdid,sphh:sphh,StockType:stockType},
                catch: false,
                timeout: 15000,
                error: function(e){
                    HideLoading();				
                    ShowInfo("网络异常",1);
                },
                success:function (res){
                    HideLoading();	
                    if(res.indexOf("Error")>=0){
                        ShowLoading(res, 3);
                    }else{
                        $(".product-stock").empty();
                        $(".product-stock").html(htmlStr);
                        htmlStr="";
                        var obj=JSON.parse(res); 
                        for(var i=0;i<obj.rows.length ;i++){
                            if(obj.rows[i]["sl"]>0){
                                htmlStr+=htmlTemp.replace(/\$sl\$/g,"("+obj.rows[i]["sl"].toString()+")").replace("$style$","class='choose'").replace("$cm$",obj.rows[i]["cm"].toString());                                   
                            }else{
                                htmlStr+=htmlTemp.replace(/\$sl\$/g,'').replace("$style$","class='none' ").replace("$cm$",obj.rows[i]["cm"].toString());
                            }
                        }	
                       $(".product-stock").append(htmlStr);		
                       $("#sameStyle").css('display','none'); 	   
                    }
                }
            });
        }
         
          //加载尺码信息20160613 by liqf
        function LoadCMInfos(data) {
            if (typeof(data) != "string") {
                var len = data.rows.length;
                //遍历属性，构造出表头
                var table_html = "<thead><tr>";
                for (var p in data.rows[0]) {
                    table_html += "<th>" + p + "</th>";
                } //end for
                table_html += "</tr></thead><tbody>";
                //遍历值，构造表体
                for (var i = 0; i < len; i++) {
                    var row = data.rows[i];
                    table_html += "<tr>";
                    for (var p in row) {
                        table_html += "<td>" + parseFloat(row[p]) + "</td>";
                    } //end for row
                    table_html += "</tr>";
                } //end for all
                table_html += "</tbody></table>";
                //alert(table_html);
                $(".cm-table").empty().append(table_html);
            } else {
                $(".product-cminfo").hide();
            }
        }
        function goodsImg(obj) {
          if(typeof(obj)=="string"){
              HideLoading();
              $(".product-detail1").hide();
              $(".product-detail2").hide();
           }else{			    
               var htmlStr="<p class='title'>商品参数</p><div style='padding:8px;'><table>";
               htmlTemp="<tr ><td style='min-width:85px' >$name$:</td><td>$value$</td></tr>";					
               htmlStr+=htmlTemp.replace(/\$name\$/g,"商品货号").replace(/\$value\$/g,obj.rows[0]["sphh"].toString());
               htmlStr+=htmlTemp.replace(/\$name\$/g,"商品名称").replace(/\$value\$/g,obj.rows[0]["spmc"].toString());
               if(unescape(obj.rows[0]["cpmd"]).length>0){
                   htmlStr+=htmlTemp.replace(/\$name\$/g,"产品解读").replace(/\$value\$/g,unescape(obj.rows[0]["cpmd"]));
               }
               if(obj.rows[0]["mlcf"].toString().length>0){
                   htmlStr+=htmlTemp.replace(/\$name\$/g,"面料成份").replace(/\$value\$/g,obj.rows[0]["mlcf"].toString());
               }
               htmlStr+="</table></div>";
               //商品图片
               var PicStr="<p class='title'>商品图片</p>";
               var PicTemp="<img src='$url$' onclick='javascript:previewImage(this);'/><p class='img-tips'>@SIMPLE YET SOPHISTICATED</p>";
               for(var i=0;i<obj.rows.length;i++){
                   PicStr+=PicTemp.replace(/\$url\$/,"http://webt.lilang.com:9001"+obj.rows[i]["urlAddress"].toString().replace('..',""));
               }
               if(obj.rows.length==0){ //无图片时
                   PicStr+=PicTemp.replace(/\$url\$/,"http://tm.lilanz.com"+"/oa/res/img/StoreSaler/lllogo5.jpg");
               }
               $(".product-detail1").html(htmlStr);
               $(".product-detail2").html(PicStr);
               HideLoading();
               ShowInfo("加载成功!",1); 
            }
        }			
        function loadSameType(obj) {
            if (typeof (obj) != "string") {
                var flag = false;
                var temp = "<dl class='rs-item pg1' data-mid='$mid$'><a class='clearfix ablock' href=javascript:data_mid='$mid$';goodsDetail(\'$sphh$\',\'$spmc$\',\'$lsdj$\')> <dt class='pic'><img class='j_item_image pg1' src='$url$' data-brandlazy='false' data-onerror='$url$' data-productid='$productid$' data-brandid=1 /></dt> <dd class='b_goods_sphh'>$sphh$ </dd> <dd class='b_goods_name'>$spmc$</dd> </a> </dl>";
                var htmlStr = "";
                for (var i = 0; i < obj.rows.length; i++) {
                    if (obj.rows[i]["urlAddress"].toString() != "") {//部分替换已去掉，需要更改，库存没取，是否需要取有店存的才显示
                        flag = true;
                        htmlStr += temp.replace(/\$mid\$/g, obj.rows[i]["id"].toString()).replace(/\$url\$/g, "http://webt.lilang.com:9001" + obj.rows[i]["urlAddress"].toString().replace("..", '')).replace("$productid$", obj.rows[i]["id"].toString()).replace(/\$sphh\$/g, obj.rows[i]["sphh"].toString()).replace(/\$spmc\$/g, obj.rows[i]["spmc"].toString()).replace(/\$lsdj\$/g, obj.rows[i]["lsdj"].toString());
                    }
                }
                if (flag == false) {
                    $(".product-sameStyle").hide();
                } else {
                    $("#sameStyle").empty();
                    $("#sameStyle").append(htmlStr);
                    $(".product-sameStyle").show();
                }
            }     
        }
           function loadOFBContent(sphh) {
            window.location.href="OFBPage.aspx?sphh="+sphh;
        }
        /**********主页表头搜索***********/
        function Scan(){ 
            isProcessing=true;
            scanQRCode();             
        }
        //showType=1内部使用 =2外部使用
        function scanQRCode() {
            if (isProcessing == false) { return false;}
            wx.scanQRCode({
                needResult: 1, // 默认为0，扫描结果由微信处理，1则直接返回扫描结果，
                scanType: ["barCode","qrCode"], // 可以指定扫二维码还是一维码，默认二者都有 //, "qrCode"
                success: function (res) {
                   var result = res.resultStr; // 当needResult 为 1 时，扫码返回的结果
                   var codeType,scanResult;
                   if(result.indexOf("http")>-1){ 
                       codeType="qrCode";
                       scanResult=result.split("?id=")[1];
                   }else{     
                       codeType="barCode";
                       scanResult=result.split(",")[1];                   
                  }
                   getScanSphh(codeType,scanResult);
                }
            });
        }
        function getScanSphh(codeType,scanResult){
         $.ajax({
                url: "goodsListCoreV3.aspx?ctrl=getScanSphh",
                type:"post",
                dataType: "text",
                data: { scanType:codeType,scanResult:scanResult},
                catch: false,
                timeout: 15000,
                error: function(e){		
                    ShowInfo("网络异常",1);
                },
                success:function (res){
                    if(res.indexOf("Error")<0){
                        goodsDetail(res,"","");
                     }else{
                        ShowInfo(res,3);
                     }
                }
            });
        }
        function childDetail(){
            $("#htmlList").show();
            $("#htmlDetail").hide();
           
           // lastID="-1";
           // searchLastID="-1";//返回时将此ID重置为-1否则再次搜索商品将搜索不到
           var t=$("#main").html();
           if(t==undefined || t==null || t.replace(/\s+/g,"")=="" ){
               goodsList();
           }else{
               WXShareLink("");
           }
        }
          $('#keyword').bind('keypress', function(event) {
            if (event.keyCode == "13") { 
                //回车执行查询
                searchFunc();
                return false;
            }
        });
        function searchFunc() {   
            var stxt = $("[id$=keyword]").val().toUpperCase(); 
          // searchLastID="-1";
          //  alert("123");
          goodsfilter("sphh",stxt);
        }
        function goodsfilter(searchName,searchVal){
             searchLastID=-1;
            if(searchVal!=""){
                var filter=searchName+"|"+searchVal;
            }else{
                goodsList();
                $("#main").empty();
                return;
            }
             $.ajax({
                url: "goodsListCoreV3.aspx?ctrl=goodsListSingle",
                type:"post",
                dataType: "text",
                contentType: "application/x-www-form-urlencoded; charset=gb2312",
                data: {showType: "<%=showType %>", mdid: mdid, lastID: searchLastID,filter:filter},
                catch: false,
                timeout: 15000,
                error: function(e){		
                    ShowInfo("网络异常",1);
                },
                success:function (res){
                    if(res.indexOf("Error")<0){
                          var obj = JSON.parse(res);
                          var temp = "<dl class='rs-item pg1' data-mid='$mid$'><a class='clearfix ablock' href=javascript:data_mid='$mid$';goodsDetail(\'$sphh$\',\'$spmc$\',\'$lsdj$\')> <dt class='pic'><img class='j_item_image pg1' src='$url$' data-brandlazy='false' data-onerror='$url$' data-productid='$productid$' data-brandid=1 /></dt> <dd class='b_goods_sphh'>$sphh$ </dd> <dd class='b_goods_name'>$spmc$</dd> <dd class='pricebox clearfix'> <span class='grallyprice f-left'>&yen;$lsdj$</span>  <span class='f-right discount'>库存 $kc$</span></dd></a> </dl>";
                          var htmlStr = "";
                          for (var i = 0; i < obj.rows.length; i++) {
                              if (obj.rows[i]["urlAddress"].toString() != "") {
                                  htmlStr += temp.replace(/\$mid\$/g, obj.rows[i]["xh"].toString()).replace(/\$url\$/g, "http://webt.lilang.com:9001" + obj.rows[i]["urlAddress"].toString().replace("..", '')).replace("$productid$", obj.rows[i]["xh"].toString()).replace(/\$sphh\$/g, obj.rows[i]["sphh"].toString()).replace(/\$spmc\$/g, obj.rows[i]["spmc"].toString()).replace(/\$lsdj\$/g, obj.rows[i]["lsdj"].toString()).replace(/\$kc\$/g, obj.rows[i]["kc"].toString());
                              } else {
                                  htmlStr += temp.replace(/\$mid\$/g, obj.rows[i]["xh"].toString()).replace(/\$url\$/g, "http://tm.lilanz.com" + "/oa/res/img/StoreSaler/lllogo5.jpg").replace("$productid$", obj.rows[i]["xh"].toString()).replace(/\$sphh\$/g, obj.rows[i]["sphh"].toString()).replace(/\$spmc\$/g, obj.rows[i]["spmc"].toString()).replace(/\$lsdj\$/g, obj.rows[i]["lsdj"].toString()).replace(/\$kc\$/g, obj.rows[i]["kc"].toString());
                              }
                          }
                           $("#main").empty();
                          $("#main").append(htmlStr);
                          searchLastID = $("#main dl:last-child").attr("data-mid");
                          $("#u-more-btn").text("-加载更多-");
                          HideLoading();
                          if (obj.rows.length == 1) { //筛选只有1条记录时直接进入detail
                              goodsDetail(scanResult, scanType);
                          } else {
                              ShowInfo("加载成功!", 1);
                          }
                     }else{
                        $("#main").empty();
                        ShowInfo(res,3);
                     }
                }
            });
        }
          function WXShareLink(sphh) {
              var title,imgurl;
              var  _link=window.location.href;
              var  link=_link.substr(0,_link.indexOf("?")+1);
             if(sphh!=""){
                 title = "我发现了利郎的一款好货【" + sphh + "】";
                 imgurl = $(".main_image ul li:first-child span").css("background").match(new RegExp("\\((.| )+?\\)", "igm"))[1];
                 imgurl = imgurl.substring(1, imgurl.length - 1);
                 link=link+"showType="+"<%=showType %>"+"&sphh="+sphh;
              }else{
                 title="我发现了利郎的一批好货";
                 imgurl=$("#main").find("dl:first-child").find("dt:first-child").find("img").attr('src');
                 link=link+"showType="+"<%=showType %>";
              }
              //20160607 liqf重复分享会使链接参数过长
              //var link=window.location.href+"&cid="+data_mid+"&codeType="+codeType;            
            //  var _link = setQueStr(window.location.href, "cid", sphh);
            //  var link = setQueStr(_link, codeType, codeType);

             
             

              //分享给朋友
              wx.onMenuShareAppMessage({
                  title: title, // 分享标题                
                  imgUrl: imgurl,
                  desc: '赶快点开一探究竟吧....',
                  link: link, // 分享链接                    
                  type: 'link', // 分享类型,music、video或link，不填默认为link
                  dataUrl: '', // 如果type是music或video，则要提供数据链接，默认为空
                  success: function () {
                      // 用户确认分享后执行的回调函数                   
                  },
                  cancel: function () {
                      // 用户取消分享后执行的回调函数
                  }
              });

              //分享到朋友圈
              wx.onMenuShareTimeline({
                  title: title, // 分享标题
                  imgUrl: imgurl,
                  link: link, // 分享链接                    
                  success: function () {
                      // 用户确认分享后执行的回调函数                        
                  },
                  cancel: function () {
                      // 用户取消分享后执行的回调函数
                  }
              });
          }
          function selectKh(khid,khmc){
            mdid=khid;
            mdmc=khmc;
            $("#mdmc").html(khmc);
            $(".myKhList").hide();
            $(".icon-sort-up").removeClass("icon-sort-up").addClass("icon-sort-down").css("margin-top","0px");
            var tempLi="<li onclick=selectKh('#khid#','#khmc#')>#khmc#</li>"
            var tempHtml="";
            for(var i=0;i<khList.rows.length;i++){
                if(khList.rows[i]["khid"].toString()!=khid){
                    tempHtml+=tempLi.replace(/\#khid#/g, khList.rows[i]["khid"].toString()).replace(/\#khmc#/g, khList.rows[i]["mdmc"].toString());
                  }
            }
            $(".myKhList").html("<ul>"+tempHtml+"</ul>");
            lastID = "-1";
            searchLastID = "-1";
            $("#main").empty();
            goodsList();
          }
          function KhSelectList(){
            
              if($(".myKhList").css("display")=="block"){
                  $(".myKhList").css("display","none");
                  $(".icon-sort-up").removeClass("icon-sort-up").addClass("icon-sort-down").css("margin-top","0px");
              }else{
                  $(".myKhList").css("display","block");
                   $(".icon-sort-down").removeClass("icon-sort-down").addClass("icon-sort-up").css("margin-top","5px");
              }
          }
        //20160607 liqf 设置URL中指定参数的值        
      /*  function setQueStr(url, ref, value) //设置参数值
        {
            var str = "";
            if (url.indexOf('?') != -1)
                str = url.substr(url.indexOf('?') + 1);
            else
                return url + "?" + ref + "=" + value;
            var returnurl = "";
            var setparam = "";
            var arr;
            var modify = "0";

            if (str.indexOf('&') != -1) {
                arr = str.split('&');

                for (i in arr) {
                    if (arr[i].split('=')[0] == ref) {
                        setparam = value;
                        modify = "1";
                    }
                    else {
                        setparam = arr[i].split('=')[1];
                    }
                    returnurl = returnurl + arr[i].split('=')[0] + "=" + setparam + "&";
                }
                returnurl = returnurl.substr(0, returnurl.length - 1);

                if (modify == "0")
                    if (returnurl == str)
                        returnurl = returnurl + "&" + ref + "=" + value;
            }
            else {
                if (str.indexOf('=') != -1) {
                    arr = str.split('=');

                    if (arr[0] == ref) {
                        setparam = value;
                        modify = "1";
                    }
                    else {
                        setparam = arr[1];
                    }
                    returnurl = arr[0] + "=" + setparam;
                    if (modify == "0")
                        if (returnurl == str)
                            returnurl = returnurl + "&" + ref + "=" + value;
                }
                else
                    returnurl = ref + "=" + value;
            }
            return url.substr(0, url.indexOf('?')) + "?" + returnurl;
        }*/
        /**********主页表头搜索结束***********/
    </script>
</asp:Content>
