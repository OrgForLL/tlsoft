﻿<%@ Page Title="商品库存查询" Language="C#" MasterPageFile="../../WebBLL/frmQQDBase.Master" AutoEventWireup="true" %>

<%@ MasterType VirtualPath="../../WebBLL/frmQQDBase.Master" %>
<%@ Import Namespace="nrWebClass" %>
<%@ Import Namespace="System.Data" %>
<%@ Import Namespace="System.Data.SqlClient" %>
<%@ Import Namespace="System.Collections.Generic" %>
<%@ Import Namespace="System.Net" %>
<%@ Import Namespace="System.IO" %>
<script runat="server">
    string mdid, mdmc, showType, sphh = "", RoleName = "", khList = "", kfList = "", flList = "";
    public List<string> wxConfig; //微信OPEN_JS 动态生成的调用参数
    private const string ConfigKeyValue = "1";
    string OAConnStr = clsConfig.GetConfigValue("OAConnStr"); 
    //必须在内容页的Load中对Master.SystemID 进行赋值；
    
    private const  string addOption = "<option value='{0}'>{1}</option>";
    protected void Page_Load(object sender, EventArgs e)
    {
        this.Master.SystemID = "3";
        showType = Convert.ToString(Request.Params["showType"]);

        if (String.IsNullOrEmpty(showType))
        {
            if (clsWXHelper.CheckQYUserAuth(false) == true && clsWXHelper.GetAuthorizedKey(Convert.ToInt32(this.Master.SystemID)) != "")
            {
                showType = "1";
            }
            else
            {
                showType = "2";
            }
            //  clsWXHelper.ShowError("非法访问!");
        }

        if (showType == "2") //  区分鉴权(1.门店人员 | 2.顾客)
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
        GetOtherList();

        string codeType = Convert.ToString(Request.Params["codeType"]);
        string qrcodeid = Convert.ToString(Request.Params["qrcodeid"]);
        string paraSphh = Convert.ToString(Request.Params["sphh"]);

        if (!String.IsNullOrEmpty(codeType))
        {
            sphh = getScanSphh(codeType, qrcodeid);
            if (sphh.IndexOf(clsNetExecute.Error) >= 0)
            {
                sphh = "";
            }
        }

        if (!String.IsNullOrEmpty(paraSphh))
        {
            sphh = paraSphh;
        }

        RoleName = Convert.ToString(Session["RoleName"]);
        if (RoleName == null)
        {
            RoleName = "";
        }

        if (showType == "1") //  区分鉴权(1.门店、贸易公司、总部人员 | 2.顾客)
        {
            if (RoleName == "dg" || RoleName == "dz")//dg：导购、dz：店长
            {
                mdid = Convert.ToString(Session["mdid"]);
                LoadMyKhList("md", mdid);
            }
            else if (RoleName == "zb" || RoleName == "kf")//总部人员
            {
                mdid = "1";
                mdmc = "总部";
                LoadMyKhList("zb", "");
            }
            else if (RoleName == "my") //贸易公司角色走khid、khmc; mdid 为 khid,mdmc 为khmc
            {
                LoadMyKhList("my", "");
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
    private void LoadMyKhList(string khType, string khid)
    {
        string mySql = "", errInfo = "";
        switch (khType)
        {
            case "md":
                mySql = string.Format("select top 1 mdmc as mdmc,mdid as khid from t_mdb a where a.mdid={0}", khid);
                break;
            case "zb":
                mySql = @"select '总部' as mdmc,1 as khid 
                          union all
                          SELECT  a.khmc,a.khid  
                          FROM yx_t_khb a 
                          WHERE ssid=1 AND ISNULL(A.ty,0) = 0 AND ISNULL(A.sfdm,'') <> ''";
                //AND yxrs=1      By:xuelm 取消这个控制 20160829
                break;
        }
        DataTable dt = new DataTable();
        if (mySql.Equals(string.Empty) && khType == "my")
        {
            dt = clsWXHelper.GetQQDAuth();
        }
        else
        {
            using (LiLanzDALForXLM dal = new LiLanzDALForXLM(OAConnStr))
            {
                errInfo = dal.ExecuteQuery(mySql, out dt);
            }

        }
        if (!errInfo.Equals(string.Empty) || dt == null || dt.Rows.Count < 1)
        {
            clsSharedHelper.WriteInfo(string.Concat("无法获取客户权限！" + khType, mySql, errInfo));
        }

        mdmc = Convert.ToString(dt.Rows[0]["mdmc"]);
        mdid = Convert.ToString(dt.Rows[0]["khid"]);
        for (int i = 0; i < dt.Rows.Count; i++)
        {
            khList = string.Concat(khList, string.Format(addOption, dt.Rows[i]["khid"], dt.Rows[i]["mdmc"]));
        }
        dt.Clear();
        dt.Dispose();
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

        if (mysql == string.Empty)
        {
            return string.Concat(clsNetExecute.Error, "非法访问");
        }

        DataTable dt;
        using (LiLanzDALForXLM dal = new LiLanzDALForXLM(OAConnStr))
        {
            errInfo = dal.ExecuteQuery(string.Format(mysql, scanResult), out dt);
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
            dt.Clear();
            dt.Dispose();
        }
        return rt;
    }

    private void GetOtherList()
    {
        string errInfo = "";
        DataTable dt = null;
        using (LiLanzDALForXLM dal = new LiLanzDALForXLM(OAConnStr))
        {
            //获取近10期开发编号
            string mySql = string.Concat("SELECT TOP 10 dm,mc FROM YF_T_Kfbh WHERE dm <= '" ,getKfbhOpen() , "' ORDER BY dm desc");
            errInfo = dal.ExecuteQuery(mySql, out dt);            
            
            if (errInfo != "")
            {
                clsLocalLoger.WriteError("【商品库存查询】读取开发编号失败！错误：" + errInfo);
                clsWXHelper.ShowError("内部错误_12！正在维护...");
            }

            kfList = "";
            kfList = string.Concat(kfList, string.Format(addOption, "", "．．全部季节．．"));
            for (int i = 0; i < dt.Rows.Count; i++)
            {
                kfList = string.Concat(kfList, string.Format(addOption, dt.Rows[i]["dm"], Convert.ToString(dt.Rows[i]["mc"])));
            }
            dt.Clear(); dt.Dispose();

            //获取近10期开发编号
            using (dt = new DataTable())
            {
                dt.Columns.Add("dm", typeof(string), "");
                dt.Columns.Add("mc", typeof(string),"");
                 
                dt.Rows.Add(new string[]{"1485",	"长袖T恤"});
                dt.Rows.Add(new string[]{"1313",	"单西"});
                dt.Rows.Add(new string[]{"1486",	"短T恤"});
                dt.Rows.Add(new string[]{"6391",	"短裤"});
                dt.Rows.Add(new string[]{"6366",	"风衣"});
                dt.Rows.Add(new string[]{"1492",	"毛衫"});
                dt.Rows.Add(new string[]{"6374",	"棉茄克"});
                dt.Rows.Add(new string[]{"6390",	"内衣"});
                dt.Rows.Add(new string[]{"6375",	"尼克服"});
                dt.Rows.Add(new string[]{"6379",	"牛仔裤"});
                dt.Rows.Add(new string[]{"6372",	"派克"});
                dt.Rows.Add(new string[]{"1489",	"派克棉衣"});
                dt.Rows.Add(new string[]{"1487",	"茄克"});
                dt.Rows.Add(new string[]{"6409",	"时尚羽绒服"});
                dt.Rows.Add(new string[]{"6389",	"袜子"}); 
                dt.Rows.Add(new string[]{"1298",	"西服"});
                dt.Rows.Add(new string[]{"1387",	"鞋类"});
                dt.Rows.Add(new string[]{"1481",	"休闲长衬"});
                dt.Rows.Add(new string[]{"1473",	"休闲单衣"});
                dt.Rows.Add(new string[]{"1482",	"休闲短衬"});
                dt.Rows.Add(new string[]{"6380",	"休闲短裤"});
                dt.Rows.Add(new string[]{"1476",	"休闲裤"});
                dt.Rows.Add(new string[]{"6373",	"羊绒"});
                dt.Rows.Add(new string[]{"6381",	"真皮"});
                dt.Rows.Add(new string[]{"1336",	"正统长衬"});
                dt.Rows.Add(new string[]{"1337",	"正统短衬"}); 
                dt.Rows.Add(new string[] { "6396", "正统鞋" });

                flList = string.Concat(flList, string.Format(addOption, "", "．．全部分类．．"));
                for (int i = 0; i < dt.Rows.Count; i++)
                {
                    flList = string.Concat(flList, string.Format(addOption, dt.Rows[i]["dm"], string.Concat("　　", Convert.ToString(dt.Rows[i]["mc"]), "　　")));
                }
                dt.Clear(); dt.Dispose(); 
            } 
        }
   
    }
    
    
    /// <summary>
    /// 返回允许开季的最高开发编号
    /// </summary>
    /// <returns></returns>
    private string getKfbhOpen()
    {
        int y = DateTime.Now.Year;
        int m = DateTime.Now.Month;
        int d = DateTime.Now.Day;

        string jjbh;    //季节编号
        if (m == 12) y++;

        if (m == 12 || (m == 1 && d < 15)) jjbh = "1";//春季      //2016年福利会前夕确认在1月15日的时候要放出夏季商品，因此 将 m<3 改为 (m == 1 && d < 15)
        else if (m < 7 && !(m == 6 && d > 15)) jjbh = "2";//夏季 7月份之前放出夏季 ；By:20180629处理：如果大于6月15日 则不出现
        else if (m < 9) jjbh = "3";//秋季 10月份之前放出秋季
        else jjbh = "4";  //冬季       

        return string.Concat(y, jjbh);
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
    <link type="text/css" rel="stylesheet" href="../../res/css/StoreSaler/shop2.css" />
    <style type="text/css">
        body {
            background-color: #f7f7f7;
            color: #2f2f2f;
            font-family: Helvetica,Arial,STHeiTi, "Hiragino Sans GB", "Microsoft Yahei", "微软雅黑",STHeiti, "华文细黑",sans-serif;
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
            font-size: 1.5em;
            position: absolute;
            top: 10px;
            left: 10px;
            z-index: 2000;
            background-color: rgba(0,0,0,.7);
            width: 34px;
            height: 34px;
            text-align: center;
            line-height: 34px;
            color: #fff;
            border-radius: 50%;
        }

            .fa-angle-left:hover {
                background-color: rgba(0,0,0,.1);
            }

        .page {
            top: 0;
            bottom: 32px;
            padding: 0;
            background-color: #f7f7f7;
        }

        .banner {
            height: 80vw;
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

        .product-info, .product-stock, .product-detail1, .product-detail2, .product-cminfo, .product-sameStyle, .product-vcr {
            background-color: #fff;
            margin: 5px 0;
            padding: 0 5px;
            box-shadow: 0 1px .5px #eceef1;
            -webkit-box-shadow: 0 1px .5px #eceef1;
            position: relative;
        }

        .product-info {
            padding: 0 10px;
        }

            .product-info .pro-name {
                font-size: 1.1em;
                font-weight: bold;
                color: #555;
                padding-top: 5px;
                color: #2b363a;
            }

            .product-info .llzp, .product-info .zdzt, .product-info .zjbg {
                background-color: #000;
                color: #fff;
                padding: 4px 8px;
                font-size: 12px;
                line-height: 28px;
                margin-right: 5px;
                border-radius: 0;
                border: none;
            }

            .product-info .zdzt {
                background-color: #e54801;
            }

            .product-info .zjbg {
                background-color: #66b359;
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
            color: #ff5000;
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
            border-radius: 1px;
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

            .product-stock li.total {
                color: #FFF;
                border: 1px solid #000;
                background-color: #000;
            }

        .product-stock .title, .product-cminfo .title, .product-vcr .title {
            font-size: 16px;
            letter-spacing: 1px;
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
                border-left: 4px solid #333;
                padding: 8px 0 8px 8px;
                font-weight: 600;
            }

        .product-detail2 {
            padding-top: 8px;
        }

            .product-detail2 img {
                width: 90%;
                height: auto;
                margin-top: 10px;
            }

            .product-detail2 .title {
                font-size: 16px;
                letter-spacing: 1px; /*border-bottom: 1px solid #f7f7f7;*/
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
            height: 80vw; /*5:4*/
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
            max-width: 100%; 
            width:100%;
            padding:0 35px 0 50px;
            text-overflow: ellipsis;
            height:100%;           
        }
        /*cminfos style*/
        .product-cminfo .cm-content, stock-content {
            width: 100%;
            height: 220px;
            overflow: auto;
            -webkit-overflow-scrolling: touch;
        }

        .cm-table, .stock-table {
            border-collapse: collapse;
            border: none;
            margin: 0 auto;
            color: #333;
        }

        .stock-table {
            width: 100%;
        }

            .stock-table .cmdm {
                text-decoration: underline;
                color:#003EE0;
                font-weight:700;
            }

            .cm-table th, .stock-table th {
                font-size: 14px;
                background-color: #535353;
                color: #fff;
                white-space: nowrap;
                vertical-align: middle;
            }

            .cm-table td, .cm-table th, .stock-table td, .stock-table th {
                border: solid #e1e1e1 1px;
                min-width: 50px;
                text-align: center;
                padding: 6px 10px;
            }

            .stock-table tr:last-child {
                vertical-align: middle;
                font-weight: 600;
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
            border-bottom: none;
        }

        .product-sameStyle .title {
            font-size: 16px;
            letter-spacing: 1px; /*border-bottom: 1px solid #f7f7f7;*/
            margin: -8px 0 0 0;
            border-left: 4px solid #333;
            padding: 8px 0 8px 8px;
            font-weight: 600;
        }

        .product-sameStyle a {
            padding: 0px;
        }

        #sameStyle dl {
            float: left;
        }

        .b_goods_name_sameStyle {
            height: 25px;
        }

        #sameStyle dl a dt {
            padding-bottom: 100%;
        }

            #sameStyle dl a dt img {
                width: auto;
                height: 180px;
            }

        .product-sameStyle {
            display: none;
        }

        .icon-chevron-right {
            float: right;
        }

        .opinionClass {
            margin-right: 15px;
            font-weight: normal;
            font-size: 14px;
        }

        .x3 {
            text-align: center;
            width: 33.33%;
        }

        .x2 {
            text-align: center;
            width: 49.99%;
        }

        .product-stock {
            padding: 5px;
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
                    margin: 0;
                    border-radius: 0;
                    border-right: 1px solid #d96a59;
                    color: #999;
                }

                    .product-stock .nav_nums li.selected {
                        background-color: #d96a59;
                        color: #fff;
                    }

                    .product-stock .nav_nums li:last-child {
                        border-right: none;
                    }

        .col3 li {
            width: 33.33%;
        }

        .col5 li {
            width: 20%;
        }
        
        #mykh 
        {
            width: 95%;
            height:100%;
            text-align:center;    
            border-bottom:1px solid #c0c0c0;  
            padding-left:35px;                    
            border-radius:0;
        } 

        .u-pro-list dl {
            margin: 0 0 0.2rem 0.1rem;
            border: 1px solid #f0f0f0;
        }
    </style>

    <%--评论功能的样式--%>
    <style type="text/css">
        body {
            background-color: #f7f7f7;
            color: #2f2f2f;
            font-family: Helvetica,Arial,STHeiTi,"Hiragino Sans GB","Microsoft Yahei", "微软雅黑",STHeiti,"华文细黑",sans-serif;
        }

        .comment-index {
            background-color: #fff;
            margin: 15px 0;
            box-shadow: 0 1px .5px #eceef1;
            -webkit-box-shadow: 0 1px .5px #eceef1;
            position: relative;
        }

        .comment-tab {
            width: 100%;
            height: 50px;
            border-bottom: 1px solid #eee;
        }

        .tab-item {
            width: 50%;
            float: left;
            text-align: center;
            color: #a1a1a1;
            font-size: 15px;
            height: 20px;
            margin-top: 15px;
        }

            .tab-item:nth-child(1) {
                border-right: 1px solid #eee;
            }

        .blacktxt {
            color: #333;
        }

        .comment-con {
            /*padding-top: 15px;*/
        }

        .label {
            width: 100%;
            padding: 0 12px;
        }

            .label li {
                float: left;
                margin: 15px 10px 0 0;
                background-color: #fce7dc;
                padding: 0 15px;
                border-radius: 8px;
                height: 26px;
                line-height: 26px;
                font-size: 12px;
            }
        /*comment-list style*/
        .comment-list li {
            padding: 15px 12px;
            border-bottom: 1px solid #eee;
        }

        .top-item {
            height: 35px;
        }

        .user-img {
            width: 35px;
            height: 35px;
            border-radius: 50%;
            background-size: cover;
            background-position: 50% 50%;
            float: left;
            vertical-align: middle;
        }

        .user-name {
            float: left;
            height: 35px;
            line-height: 35px;
            margin-left: 10px;
            max-width: 120px;
            overflow: hidden;
            text-overflow: ellipsis;
            white-space: nowrap;
        }

        .type-txt {
            float: right;
            height: 35px;
            line-height: 35px;
            font-size: 13px;
            color: #555;
        }

        .sort {
            color: #a1a1a1;
        }

        .bottom-item {
            margin-top: 10px;
        }

        .date {
            color: #b3b3b3;
            font-size: 13px;
            margin-top: 5px;
        }

        .upload-img-list li {
            float: left;
        }

        .upload-img {
            width: 70px;
            height: 70px;
            background-position: 50% 50%;
            background-size: cover;
            margin-right: 5px;
        }
        /*end comment-list style*/
        .more {
            text-align: center;
            width: 100%;
            height: 45px;
            line-height: 45px;
            background-color: #f0f0f0;
            color: #d0d0d0;
        }

            .more span {
                color: #d96a59;
                text-decoration: underline;
            }
        /*vcr style*/
        .vcr_container {
            background-color: #fff;
            padding-bottom: 5px;
        }

        .vcr_ul {
            font-size: 0;
            padding-left: 0;
        }

        .vcr_item {
            width: 47.75%;
            display: inline-block;
            vertical-align: top;
            height: 130px;
            letter-spacing: 0;
            margin-left: 1.5%;
            margin-top: 5px;
            font-size: 14px;
            background-color: #f5f5f5;
        }

        .back-image {
            background-repeat: no-repeat;
            background-size: cover;
            background-position: center center;
        }

        .vcrthumb {
            height: 100px;
            position: relative;
        }

        .vcrtimes {
            text-align: right;
            background-color: rgba(0,0,0,0.5);
            color: #fff;
            position: absolute;
            left: 0;
            bottom: 0;
            width: 100%;
            font-size: 12px;
            padding: 0 5px;
        }

        .vcrname {
            padding: 0 5px;
            height: 30px;
            line-height: 30px;
        }

        #vcr-play {
            background: #fff;
            border: none;
            line-height: 1;
            padding: 0;
            border-radius: 0;
            margin: 0;
        }

        .product-detail2 .delay-img, .product-detail2 .img-tips.delay {
            display: none;
        }

        .rs-item.pg1 .ablock {
            border: none;
            background-color: #f5f5f5;
            border-radius: 0;
        }

        .u-pro-list dl:before {
            border-bottom: none;
        }

        .flashbox {
            animation: change 1s ease-in infinite;
        }

        @keyframes change {
            0% {
                text-shadow: 0 0 1px #900;
            }

            50% {
                text-shadow: 0 0 3px #f00;
            }

            100% {
                text-shadow: 0 0 1px #900;
            }
        }

        .page a {
            margin: 0;
        }

        .nav-btns {
            padding: 0;
            margin: 8px 0;
            background-color: #fff;
        }

            .nav-btns li {
                float: left;
                text-align: center;
                width: 33%;
                color: #303030;
                padding: 10px 0 8px 0;
            }

                .nav-btns li.active {
                    /*border-bottom:2px solid #303030;*/
                    color: #66b359;
                    font-weight: bold;
                }

        .qs_item {
            display: inline-block;
            background-color: #fff;
            text-align: center;
            padding: 10px 15px;
            font-weight: 600;
        }

            .qs_item > .back-image {
                width: 50px;
                height: 50px;
                margin: 0 auto;
            }

        .quality_suggest {
            margin-top: 10px;
            text-align: center;
        }

        .quality {
            color: #66b359;
        }

        .suggest {
            margin-left: 10px;
            color: #33475f;
        }

        .stock_detail {
            position: fixed;
            top: 0;
            left: 0;
            width: 100%;
            height: 100%;
            background-color: rgba(0,0,0,.6);
            z-index: 4000;
            display: none;
        }

        .stock_detail_wrap {
            width: 80vw;
            position: relative;
        }

        .stock_title {
            height:40px;
            line-height:40px;
            background-color:#333;
            color:#f2f2f2;
            font-weight:bold;
            padding:0 10px;
        }

        #stock_detail_ul {
            padding: 0;
            background-color: #fff;
            color:#333;
            max-height: 80vh;
            overflow-y: auto;
        }

            #stock_detail_ul li {
                font-size: 0;
                border-bottom:1px solid #eee;
            }

                #stock_detail_ul li.local {
                    background-color: #e0574f;
                    color: #fff;
                }
                 #stock_detail_ul li.shared {
                    background-color: #174F96;
                    color: #fff;
                }

                #stock_detail_ul li > div {
                    display: inline-block;
                    font-size: 14px;
                    text-align: center;
                    height: 40px;
                    line-height: 40px;
                    vertical-align:top;
                }

            #stock_detail_ul .ckmc {
                width: 80%;
                font-size:12px;
                white-space:nowrap;
                overflow:hidden;
                text-overflow:ellipsis;
                padding: 0 10px;
            }

            #stock_detail_ul .sl {
                width: 20%;
            }

        .close_btn {
            color: #333;
            position: absolute;
            top: -1px;
            right: 0;
            font-size: 18px;
            z-index:4003;
        }

        #evaluations {
            padding-left: 0;
        }

        .red_paper .red_paper_icon {
            height: 24px;
            display: inline-block;
            float: right;
            vertical-align: top;
            margin-top: 3px;
        }

        .red_paper .red_paper {
            display: inline-block;
            height: 30px;
            line-height: 30px;
            float: right;
        }

        .red_counts {
            color: #ed4658;
            font-weight: bold;
        }

        @keyframes breath {
            from {
                opacity: 0.1;
            }

            50% {
                opacity: 1;
            }

            to {
                opacity: 0.1;
            }
        }

        @-webkit-keyframes breath {
            from {
                opacity: 0.1;
            }

            50% {
                opacity: 1;
            }

            to {
                opacity: 0.1;
            }
        }

        .mybreath {
            animation-name: breath; /* 动画名称 */
            animation-duration: 1s; /* 动画时长3秒 */
            animation-timing-function: ease-in; /* 动画速度曲线：以低速开始和结束 */
            animation-iteration-count: infinite; /* 播放次数：无限 */
            /* Safari and Chrome */
            -webkit-animation-name: breath; /* 动画名称 */
            -webkit-animation-duration: 1s; /* 动画时长3秒 */
            -webkit-animation-timing-function: ease-in; /* 动画速度曲线：以低速开始和结束 */
            -webkit-animation-iteration-count: infinite; /* 播放次数：无限 */
        }
        /*#stock_detail_ul .local.ckmc {
            background-color:#e0574f;
            color:#fff;
        }*/
        /*#stock_detail_ul .local.sl {
            background-color:#6f8874;
            color:#fff;
        }*/
        #triangle-topright {
            width: 0;
            height: 0;
            border-top: 30px solid #f2f2f2;
            border-left: 30px solid transparent;
            position:absolute;
            top:0;
            right:0;
            z-index:4002;
        }
        .storeicon
        {
            border-left:1px solid #c0c0c0;
            position:absolute;
            left:50px;
            height:40px;
            top:5px;            
        }
        .storeicon img
        {
            position:absolute;
            left:5px;
            top:5px;
            width:30px;            
        }

        .top-back
        {
            z-index:9999;
        }
        
        .x4 select
        { 
            width: 100%;
            padding-right:5px;
            direction: rtl;
            height:100%
        }

        .SellingPointImg{
            width:100%;
            padding:0;
            margin:0;
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
                    <div class="storeicon">
                        <img alt="" src="../../res/img/StoreSaler/shop.png" />
                    </div>
                    <div class="top-title"> 
                        <select id="mykh" onchange="KhChange()"> 
                            <%=khList %>
                        </select>
                    </div>

                    <div class="top-search" style="display: none;">
                        <input id="keyword" name="keyword" placeholder="输入商品货号" />
                        <button type="button" class="icon-search" onclick="searchFunc()"></button>
                    </div>
                    <div class="top-signed">
                        <a id="search-btn" href="javascript:void(0);"><i class="icon-search"></i></a>
                    </div>
                </div>
                <div id="search-bar" class="search-bar">
                    <ul>
                        <li class="x4"><span id="kcli">限定有货商品</span><i></i></li>
                        <li class="x4">
                            <select id="kflst" onchange="FilterChange()"> 
                                <%=kfList %>
                            </select>
                        </li>
                        <li class="x4">    
                            <select id="fllst" onchange="FilterChange()"> 
                                <%=flList %>
                            </select>
                        </li> 
                    </ul>
                </div>
                <div class="serch-bar-mask" style="display: none;">
                    <div class="serch-bar-mask-list">
                        <ul>
                            <li class="on"><a href="javascript:goodsfilter('kczt','','选择库存类型')">显示全部</a></li>
                            <li><a title="有货" href="javascript:goodsfilter('kczt','1','限定有货商品')">限定有货商品</a></li>
                            <li><a title="缺货" href="javascript:goodsfilter('kczt','0','限定缺货商品')">限定缺货商品</a></li>
                        </ul>
                    </div> 
                    <div class="serch-bar-mask-bg"></div>
                </div>
                <div id="main" class="u-pro-list clearfix u-pro-list-top">
                </div>
                <div class="u-more-btn"><a href="javascript:goodsList();" id="u-more-btn">- 查看更多 -</a></div>
            </script>
        </div>
        <div id="htmlDetail">
        </div>
        <script type="text/html" id="page2">
            <i class="fa fa-angle-left" onclick="javascript:childDetail();"></i>
            <input type="hidden" id="detail_sphh" value="" />
            <div id="goodsDetail" class="wrap-page none">
                <div class="page page-not-footer" id="main-page">
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
                        <p class="title">库存信息</p>
                        <!-- 商品库存信息 -->
                        <div class="stock-content">
                            <table class="stock-table">
                                <thead>
                                </thead>
                                <tbody>
                                </tbody>
                            </table>
                        </div>
                    </div>

                    <!--切换按钮-->
                    <ul class="nav-btns floatfix">
                        <li class="active" data-item="cpmd" onclick="clickNav('cpmd')" show>卖点描述<br />
                            <i class="fa fa-angle-double-down mybreath"></i></li>
                        <li data-item="mdbc" onclick="clickNav('mdbc')" show>销售高手卖点补充<br />
                            <i class="fa fa-angle-double-down mybreath"></i></li>
                        <li data-item="vcrtj" onclick="clickNav('vcrtj')" show>VCR卖点推介<br />
                            <i class="fa fa-angle-double-down mybreath"></i></li>
                    </ul>

                    <!--卖点描述-->
                    <div class="product-detail1 nav-area" data-group="area-cpmd">
                        <!-- 商品信息(卖点成份) -->
                    </div>

                    <!--销售高手卖点补充-->
                    <div class="nav-area" data-group="area-mdbc" style="display: none;">
                        <div class="comment-con">
                            <!-- 标签列表 -->
                            <ul class="label floatfix" id="keywords">
                            </ul>
                            <!-- 评论列表 -->
                            <ul class="comment-list" id="evaluations">
                            </ul>
                        </div>
                        <div class="more"><span id="lookmore" onclick="lookmoreFun()">查看更多产品卖点&gt;&gt;</span>&nbsp;&nbsp;&nbsp;|&nbsp;&nbsp;&nbsp;<span class="flashbox" onclick="IsayFun()">我要点评！</span></div>
                    </div>
                    <!--VCR卖点推介-->
                    <div class="product-vcr nav-area" data-group="area-vcrtj" style="display: none">
                        <p class="title">视频介绍</p>
                        <div class="vcr_container">
                            <ul class="vcr_ul"></ul>
                            <div id="video-play"></div>
                        </div>
                    </div>

                    <!--尺码信息-->
                    <div class="product-cminfo">
                        <p class="title">尺码信息：单位CM</p>
                        <div class="cm-content">
                            <table class="cm-table">
                            </table>
                        </div>
                        <div class="cm-tips">
                            <p>1、尺码信息过多时，请滑动表格查看；</p>
                            <p>2、尺码表数据仅供参考，由于人工测量，可能会存在1-2cm左右偏差;</p>
                        </div>
                    </div>

                    <!--评论列表开始 没有样式先隐藏起来-->
                    <div class="product-comment" style="display: none;">
                        <div class="comment-head floatfix" onclick="showCommentList()">
                            <i class="arrow fa fa-angle-down fa-2x"></i>
                            <p class="title">相关评论(<span class="comment-num">0</span>)</p>
                        </div>
                        <ul class="comment-list">
                        </ul>
                        <div class="comment-more" onclick="LoadMoreComment()">--更多评论--</div>
                        <div class="comment-nomore">--无更多评论了--</div>
                        <div class="commentbtn" onclick="showCommentMask()">我要评论</div>
                    </div>
                    <!--评论列表结束-->
                    <div class="product-detail2">
                        <!--<p class="title">商品详情</p>-->
                    </div>

                    <div class="product-sameStyle">
                        <p class="title">同款商品</p>
                        <div id="sameStyle" class="u-pro-list clearfix ">
                        </div>
                    </div>

                    <!--质量反馈和开发建议入口-->
                    <div class="quality_suggest">
                        <div class="qs_item quality" onclick="goSuggest('quality')">
                            <div class="back-image" style="background-image: url(../../res/img/storesaler/spite_icons.png); background-position: 0 0;"></div>
                            <p>质量反馈</p>
                        </div>
                        <div class="qs_item suggest" onclick="goSuggest('suggest')">
                            <div class="back-image" style="background-image: url(../../res/img/storesaler/spite_icons.png); background-position: 0 -100px;"></div>
                            <p>开发建议</p>
                        </div>
                    </div>
                </div>
            </div>

            <!--库存分布详情-->
            <div class="stock_detail">
                <div class="stock_detail_wrap center-translate">
                    <div class="stock_title">货号：<span id="title_sphh">--</span>  | <span id="title_cm">--</span>码 | 总:<span id="title_sum"></span></div>
                    <ul id="stock_detail_ul">
                        <li class="floatfix">
                            <div class="ckmc">桃江县文化路专卖店</div>
                            <div class="sl">5</div>
                        </li>
                    </ul>
                    <!--<i class="fa fa-times-circle close_btn" onclick="javascript:$('.stock_detail').fadeOut(100);"></i>-->
                    <div id="triangle-topright" onclick="javascript:$('.stock_detail').hide();"></div>
                    <i class="fa fa-times close_btn" onclick="javascript:$('.stock_detail').hide();"></i>
                </div>
            </div>

            <div class="footer">
                &copy;2016 利郎(中国)有限公司						
            </div>
        </script>

        <script type="text/html" id="vcr_item_temp">
            <li class="vcr_item" data-vcrsrc="{{videosrc}}">
                <div class="back-image vcrthumb" style="background-image: url({{videothumb}})">
                    <p class="vcrtimes">{{videotimes}}分钟</p>
                </div>
                <p class="vcrname">{{videoname}}</p>
            </li>
        </script>
    </div>
    <script type="text/javascript" src="../../api/lilanzAppWVJBridge.js"></script>
    <script type="text/javascript" src="http://res.wx.qq.com/open/js/jweixin-1.0.0.js"></script>
    <script type="text/javascript" src="../../res/js/jquery.js"></script>
    <script type="text/javascript" src="../../res/js/vipweixin/jquery.event.drag-1.5.min.js"></script>
    <script type="text/javascript" src="../../res/js/vipweixin/jquery.touchSlider.js"></script>
    <script type="text/javascript" src="../../res/js/LeeJSUtils.min.js"></script>
    <script type="text/javascript" src="../../res/js/template.js"></script>
    <script type="text/javascript">
        if ("<%=showType%>" == "2") {
            //对外顾客
            $('#htmlDetail').html($("#page2").html());
            $(".fa.fa-angle-left").hide();
            $("#goodsDetail").hide();

            $(".nav-btns li[data-item='mdbc']").hide();  //顾客浏览时，不用显示该栏目。  By:xlm 20161016
            $(".nav-btns li[data-item='vcrtj']").text("产品亮点VCR");
        } else {
            //内部使用可以看到库存
            $('#htmlList').html($("#page1").html());
            $("#main").css(top, "100px");
        }
    </script>
    <script type="text/html" id="video-temp">
        <video style="display: none;" id='my-video' autoplay="autoplay" controls='controls' preload='auto' width='100%' height='240px'>
            <source src="{{vsrc}}" type='video/mp4' />
        </video>
    </script>
    
    <script type="text/html" id="stock_detail_temp">
        <li class="floatfix {{islocal}}">
            <div class="ckmc">{{ckmc}}</div>
            <div class="sl">{{sl}}</div>
        </li>
    </script>
    <script type="text/html" id="stock_detail_shared">
        <li class="floatfix shared">
            <div class="ckmc">{{ckmc}}</div>
            <div class="sl">{{sl}}</div>
        </li>
    </script>

    <script type="text/javascript">
        $(function () {
            llApp.init();
            $(".serch-bar-mask-bg").click(function () {
                $(".serch-bar-mask").hide();
                $(".serch-bar-mask-bg").hide();
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
            $("#search-bar li:eq(0)").each(function (e) {
                $(this).click(function () {
                    if ($(this).hasClass("on")) {
                        $(this).parent().find("li").removeClass("on");
                        $(this).removeClass("on");
                        $(".serch-bar-mask").hide();
                        $(".serch-bar-mask-bg").hide();
                    }
                    else {
                        $(this).parent().find("li").removeClass("on");
                        $(this).addClass("on");
                        $(".serch-bar-mask").show();
                        $(".serch-bar-mask-bg").show();
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
        var mdmc = "<%=mdmc %>";
        var commentMaxID="-1";//commentMaxID=-1 未加载评论信息commentMaxID=N 还有未加载的评论信息 commentMaxID=0 评论信息已全部加载
        window.onload = function () {
            wxConfig(); //微信接口注入
            if (typeof(sphh) != undefined && sphh != "") {
                goodsDetail(sphh, "", "");
                $(".header").find("i:first-child").hide();
                $(".header").find("i:last-child").show()
            } else {
                goodsfilter('kczt','1','限定有货商品');
                //goodsList();
            }
            if ($("#main-page").length > 0){        //增加是否找到 main-page 对象的判断。 By:xlm 20160920
                LeeJSUtils.stopOutOfPage("#main-page", true);   
                //LeeJSUtils.stopOutOfPage(".header", false);   //已经取消头部样式了
                LeeJSUtils.stopOutOfPage(".footer", false);
            }            

            $(".vcr_ul").on("click", ".vcr_item", function () {
                var $this=$(this);
                wx.getNetworkType({
                    success: function (res) {
                        var isContinue=true;
                        networkType = res.networkType; // 返回网络类型2g，3g，4g，wifi
                        if(res.networkType!="wifi")
                            if(confirm("温馨提示：您当前正在使用移动网络，继续播放将消耗流量，确认继续？？"))
                                isContinue=true;
                            else
                                isContinue=false;

                        if(isContinue){
                            LeeJSUtils.showMessage("loading", "正在加载,请稍候..");
                            var vcrsrc = $this.attr("data-vcrsrc");
                            var opt = {};                            
                            opt.vsrc = vcrsrc;
                            var html = template("video-temp", opt);
                            $("#video-play").children().remove();                            
                            $("#video-play").html(html);                            
                            $("#my-video").on("play", function () {                                
                                $("#leemask").hide();
                            });     
                        }
                    }
                });
            });
        }

        //获取网络状态
        function getNetworkType(){
            wx.getNetworkType({
                success: function (res) {
                    var networkType = res.networkType; // 返回网络类型2g，3g，4g，wifi
                }
            });
        }
        function KhChange() {
            if (mdid != $("#mykh").val()) {
                mdid = $("#mykh").val();
                mdmc = $("#mykh").find("option:selected").text();
//                $("#titleKh").html(mdmc+"<i class='icon-sort-down'></i>");
                $("#main").empty();
                lastID = "-1";
                searchLastID = "-1";
                goodsList();
            }            
        }

//        function selectMyKh() {
//            $("#mykh").focus();
//        }

        function wxConfig() {//微信js 注入
            wx.config({
                debug: false, // 开启调试模式,调用的所有api的返回值会在客户端alert出来，若要查看传入的参数，可以在pc端打开，参数信息会通过log打出，仅在pc端时才会打印。
                appId: appIdVal, // 必填，企业号的唯一标识，此处填写企业号corpid
                timestamp: timestampVal, // 必填，生成签名的时间戳
                nonceStr: nonceStrVal, // 必填，生成签名的随机串
                signature: signatureVal, // 必填，签名，见附录1
                jsApiList: ["scanQRCode", "previewImage", "onMenuShareTimeline", "onMenuShareAppMessage","getNetworkType"] // 必填，需要使用的JS接口列表，所有JS接口列表见附录2
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
                url: "goodsListCoreV7.aspx?ctrl=goodsListSingle",
                type: "post",
                dataType: "text",
                data: { showType: "<%=showType %>", mdid: mdid, lastID: searchLastID ,filter:filter},
                cache: false,
                timeout: 15000,
                error: function (e) {
                    HideLoading();
                    ShowInfo("网络异常", 1);
                },
                success: function (res) {
                    if (res.indexOf("Error") > -1) {
                        HideLoading();
                        if (res == "Error:") {
                            ShowInfo("只有这些了...",1);
                            $("#u-more-btn").text("只有这些了...");
                            $("#u-more-btn").attr("class","");
                        }else{
                            ShowInfo(res.replace("Error:", ""), 1);
                        }
                    } else if (res.indexOf("Warn") > -1) {
                        HideLoading();
                        ShowInfo("未找到相关商品信息", 1);
                    } else {
                        var obj = JSON.parse(res);
                        var temp = "<dl class='rs-item pg1' data-mid='$mid$'><a class='clearfix ablock' href=javascript:data_mid='$mid$';goodsDetail(\'$sphh$\',\'$spmc$\',\'$lsdj$\')> <dt class='pic'><img class='j_item_image pg1' src='$url$' data-brandlazy='false' data-onerror='$url$' data-productid='$productid$' data-brandid=1 /></dt> <dd class='b_goods_sphh'>$sphh$ </dd> <dd class='b_goods_name'>$spmc$</dd> <dd class='pricebox clearfix'> <span class='grallyprice f-left'>&yen;$lsdj$</span>  <span class='f-right discount'>库存 $kc$</span></dd></a> </dl>";
                        var htmlStr = "";
                        for (var i = 0; i < obj.rows.length; i++) {
                            if("<%=RoleName %>"=="dg"){
                                if(Number(obj.rows[i]["kc"])>0){
                                    obj.rows[i]["kc"]="有货";
                                }else{
                                    obj.rows[i]["kc"]="无货";
                                }
                            }
//                            if (obj.rows[i]["urlAddress"].toString() != "") {
//                                htmlStr += temp.replace(/\$mid\$/g, obj.rows[i]["xh"].toString()).replace(/\$url\$/g, "http://webt.lilang.com:9001" + obj.rows[i]["urlAddress"].toString().replace("..", '')).replace("$productid$", obj.rows[i]["xh"].toString()).replace(/\$sphh\$/g, obj.rows[i]["sphh"].toString()).replace(/\$spmc\$/g, obj.rows[i]["spmc"].toString()).replace(/\$lsdj\$/g, obj.rows[i]["lsdj"].toString()).replace(/\$kc\$/g, obj.rows[i]["kc"].toString());
//                            } else {
//                                htmlStr += temp.replace(/\$mid\$/g, obj.rows[i]["xh"].toString()).replace(/\$url\$/g, "http://tm.lilanz.com" + "/oa/res/img/StoreSaler/lllogo5.jpg").replace("$productid$", obj.rows[i]["xh"].toString()).replace(/\$sphh\$/g, obj.rows[i]["sphh"].toString()).replace(/\$spmc\$/g, obj.rows[i]["spmc"].toString()).replace(/\$lsdj\$/g, obj.rows[i]["lsdj"].toString()).replace(/\$kc\$/g, obj.rows[i]["kc"].toString());
//                            }
                               htmlStr += temp.replace(/\$mid\$/g, obj.rows[i]["xh"].toString()).replace(/\$url\$/g, obj.rows[i]["urlAddress"].toString().replace("..", '')).replace("$productid$", obj.rows[i]["xh"].toString()).replace(/\$sphh\$/g, obj.rows[i]["sphh"].toString()).replace(/\$spmc\$/g, obj.rows[i]["spmc"].toString()).replace(/\$lsdj\$/g, obj.rows[i]["lsdj"].toString()).replace(/\$kc\$/g, obj.rows[i]["kc"].toString());
                        }
                        $("#main").append(htmlStr);
                        searchLastID = $("#main dl:last-child").attr("data-mid");
                        $("#u-more-btn").text("-查看更多-");
                        $("#u-more-btn").attr("class","flashbox");

                        HideLoading();
                        if (obj.rows.length == 1) { //筛选只有1条记录时直接进入detail
                            goodsDetail(obj.rows[0]["sphh"].toString(),obj.rows[0]["spmc"].toString(),obj.rows[0]["lsdj"].toString());
                        } else {
                            ShowInfo("加载成功!", 1);
                            WXShareLink("");
                        }
                    }
                }
            });
    }


    //获取滚动条位置
    function getScrollTop()
    {
        var scrollTop=0;
        if(document.documentElement&&document.documentElement.scrollTop)
        {
            scrollTop=document.documentElement.scrollTop;
        }
        else if(document.body)
        {
            scrollTop=document.body.scrollTop;
        }
        return scrollTop;
    }

    var SaveScrollMyTop = 0;//在设置元素隐藏时，会使滚动条消失；存储滚动条位置，以便还原
    
    //加载详情页
    function goodsDetail(mysphh,spmc,lsdj) {
        //保存滚动条位置
        SaveScrollMyTop = getScrollTop();    
        sphh = mysphh;  //维护全局变量。  By:xlm 20160920

        ShowLoading("数据加载中..",5);
        if ("<%=showType%>" != "2") {
            $("#htmlList").hide();
            $('#htmlDetail').html($("#page2").html()).show();
            $(".fa-angle-left.icon-camera").hide();
        } else {
            ShowLoading("拼命加载中...", 15);
        }
        $.ajax({
            url: "goodsListCoreV7.aspx?ctrl=goodsDetail",
            type: "post",
            dataType: "text",
            data: { showType: "<%=showType %>", mdid: mdid, sphh: sphh },
            cache: false,
            timeout: 15000,
            error: function (e) {
                HideLoading();
                ShowInfo("网络异常D", 1);
            },
            success: function (res) {
                // console.log(res);
                var rtObj = JSON.parse(res);
                var gDetail = rtObj.goodDetail;
                myGoodsDeatil(gDetail);
                if ("<%=showType%>" == "1") {
                    //goodsStock(rtObj.gStock,sphh);//加载库存信息
                    newStockQuery();
                    LoadEvaluation(sphh); //只在企业内部人员访问的情况下才加载评论。 
                }else{
                    $("#lookmore").hide();
                } 
                      
                getOtherDetail(sphh);
                WXShareLink(sphh);
            }
        });
    }
    function myGoodsDeatil(obj) {
        if (typeof(obj)!="string") { //有正确返回 
            var htmlTemp = "<p class='pro-name'>$spmc$（$sphh$）</p><p class='money'>￥<span style='text-decoration: blink;'>$lsdj$<span style='font-size:12px'>(全国统一零售价)</span></span></p><span class='llzp'>利郎正品</span>";
                  
            if (obj.rows[0]["yxzt"] == "1")     htmlTemp += "<span class='zdzt'>重点主推</span>";             
            //暂时先藏起来。 By:xlm  20161102
            //if (obj.rows[0]["qsreport"] !="")   
            //根据要求呈现质检报告按钮，点击后执行查询。 By:xlm  20171227
            htmlTemp += "<a class='zjbg' href=\"javascript:LoadReport();\">质检报告 <i class='fa fa-angle-right'></i></a>";

            var topHtml = "";
            var htmlStr = htmlTemp.replace(/\$sphh\$/g, obj.rows[0]["sphh"].toString()).replace(/\$spmc\$/g, obj.rows[0]["spmc"].toString()).replace(/\$lsdj\$/g, obj.rows[0]["lsdj"].toString());
            var endHtml = "<ul style='padding-left:0;'>";

            for (var i = 0; i < obj.rows.length; i++) {
                topHtml += "<a href='javascript:'></a>";
                endHtml += "<li><span style='margin-left:0;' class='img_" + (i + 1).toString() + "' onclick='javascript:previewImage(this);'></span></li>";
            }
            endHtml += "</ul> <a href='javascript:;' id='btn_prev'></a> <a href='javascript:;' id='btn_next'></a>";
            if ("<%=showType%>" == "2") {
                $(".product-stock").hide();
                $("#goodsDetail").show();
            }
            $(".flicking_inner").html(topHtml);
            $(".main_image").html(endHtml);
            $(".product-info").html(htmlStr);
            //if(obj.rows[0]["qsreport"] =="")
            //    //$(".zjbg").attr("href","javascript:alert('对不起，暂时还没有质检报告！');");
            //    $(".zjbg").hide();
            //else{
            //    var pdfaddr=obj.rows[0]["qsreport"];
            //    pdfaddr=pdfaddr.substr(3,pdfaddr.length-3);
            //    $(".zjbg").attr("href","http://webt.lilang.com:9001/" + pdfaddr);
            //}
                //$(".zjbg").attr("href","http://webt.lilang.com:9001/photo/sygzb_pdf/"+obj.rows[0]["qsreport"]);//质检报告PDF                
            for (var i = 0; i < obj.rows.length; i++) {
                if (obj.rows[i]["urlAddress"].toString() != "") {
                    $(".img_" + (i + 1)).css({ "background": "url('" + obj.rows[i]["urlAddress"].toString().replace("..", '') + "') center center no-repeat", "background-size": "contain" });
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
                        delay: 10000,
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
                    timer = setInterval(function () { $("#btn_next").click(); }, 10000);
                    $(".main_visual").hover(function () {
                        clearInterval(timer);
                    }, function () {
                        timer = setInterval(function () { $("#btn_next").click(); }, 10000);
                    })
                    $(".main_image").bind("touchstart", function () {
                        clearInterval(timer);
                    }).bind("touchend", function () {
                        timer = setInterval(function () { $("#btn_next").click(); }, 10000);
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
        if(typeof(obj)=="string" || mdid == ""){
            $(".product-stock").hide();	
        }else{
            var htmlTemp="<li $style$>$cm$<span class='u-detail-sl'>$sl$</span></li>";
            var htmlStr="",RoleName="<%=RoleName %>";
                  if(RoleName=="zb" || RoleName=="kf"){
                      htmlStr= "<ul class='nav_nums floatfix col5' ><li class='selected' id='stock_kcxx' onclick=StockQuery('kcxx','"+sphh+"')>库存量</li><li id='stock_dhl' onclick=StockQuery('dhl','"+sphh+"')>订货量</li><li id='stock_xsl' onclick=StockQuery('xsl','"+sphh+"')>销售量</li><li id='stock_zzl' onclick=StockQuery('zzl','"+sphh+"')>周转量</li><li id='stock_bhl' onclick=StockQuery('bhl','"+sphh+"')>备货量</li></ul>";
                  }else{
                      htmlStr= "<ul class='nav_nums floatfix col3' ><li class='selected ' id='stock_kcxx' onclick=StockQuery('kcxx','"+sphh+"')>库存量</li><li id='stock_dhl' onclick=StockQuery('dhl','"+sphh+"')>订货量</li><li id='stock_xsl' onclick=StockQuery('xsl','"+sphh+"')>销售量</li></ul>";
                  }
                  var totalSl=0;
                  for(var i=0;i<obj.rows.length ;i++){
                      if(obj.rows[i]["sl"]>0){
                          if("<%=RoleName %>"=="dg"){
                              obj.rows[i]["sl"]="有";
                          }
                          totalSl +=Number(obj.rows[i]["sl"]);
                          htmlStr+=htmlTemp.replace(/\$sl\$/g,"("+obj.rows[i]["sl"].toString()+")").replace("$style$","class='choose'").replace("$cm$",obj.rows[i]["cm"].toString());                                   
                      }else{
                          htmlStr+=htmlTemp.replace(/\$sl\$/g,'').replace("$style$","class='none' ").replace("$cm$",obj.rows[i]["cm"].toString());
                      }
                  }	
                  if("<%=RoleName %>"!="dg")  htmlStr +="<li class='total'>合计:"+totalSl+"</li>";		
              }			
          }
          //加载详情页其他内容
          function getOtherDetail(sphh){
              $("#detail_sphh").val(sphh);
              commentMaxID="-1";

              $.ajax({
                  url: "goodsListCoreV7.aspx?ctrl=otherDetail",
                  type:"post",
                  dataType: "text",
                  data: { showType:<%=showType %>,mdid: $("#mykh").val(),sphh:sphh},
                  catch: false,
                  timeout: 15000,
                  error: function(e){
                      HideLoading();				
                      ShowInfo("网络异常",1);
                  },
                  success:function (res){
                      HideLoading();
                      var rtObj = JSON.parse(res);
                      var gImg = rtObj.goodsImg;
                      var SellingPointImg = rtObj.SellingPointImg;
                      var CMInfos=rtObj.CMInfos;
                      var TheSameType = rtObj.TheSameType;
                      var OFBNum=rtObj.OFBNum;
                      goodsImg(gImg,SellingPointImg);
                      LoadCMInfos(CMInfos);
                      loadSameType(TheSameType);
                      showVCRs(rtObj.sphhvcrs);

                      if("<%=RoleName %>"=="dz" || "<%=RoleName %>"=="zb" || "<%=RoleName %>"=="kf" ){
                          $(".comment-num").html(OFBNum);
                       
                      }else{
                          $(".product-comment").hide();
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
              $(".product-stock .nav_nums .selected").removeClass("selected");
              $("#stock_"+stockType).addClass("selected");
              var htmlStr="";
              if("<%=RoleName %>"=="zb" || "<%=RoleName %>"== "kf"){
                  htmlStr="<ul class='nav_nums floatfix col5'>"+$(".product-stock .nav_nums").html()+"</ul>";
              }else{
                  htmlStr="<ul class='nav_nums floatfix col3'>"+$(".product-stock .nav_nums").html()+"</ul>";
              }
          
              var htmlTemp="<li $style$>$cm$<span class='u-detail-sl'>$sl$</span></li>";
              ShowLoading("拼命加载中...", 15); 
              $.ajax({
                  url: "goodsListCoreV7.aspx?ctrl=goodsStock",
                  type:"post",
                  dataType: "text",
                  data: { showType:<%=showType %>,mdid:$("#mykh").val(),sphh:sphh,StockType:stockType},
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
                               var totalSl=0;
                               for(var i=0;i<obj.rows.length ;i++){
                                   if(obj.rows[i]["sl"]>0){
                                       totalSl +=Number(obj.rows[i]["sl"]);
                                       if("<%=RoleName %>"=="dg"){
                                    obj.rows[i]["sl"]="有";
                                }
                                htmlStr+=htmlTemp.replace(/\$sl\$/g,"("+obj.rows[i]["sl"].toString()+")").replace("$style$","class='choose'").replace("$cm$",obj.rows[i]["cm"].toString());                                   
                            }else{
                                htmlStr+=htmlTemp.replace(/\$sl\$/g,'').replace("$style$","class='none' ").replace("$cm$",obj.rows[i]["cm"].toString());
                            }
                        }	
                        if("<%=RoleName %>"!="dg"){
                            htmlStr +="<li class='total'>合计:"+totalSl+"</li>";
                        }
                        $(".product-stock").append(htmlStr);		
                        $("#sameStyle").css('display','none'); 	   
                    }
                }
                   });
        }
         
        //加载尺码信息20160613 by liqf
        function LoadCMInfos(data) {
            //  console.log("尺码信息："+data);
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
                        if(isNaN(row[p]))
                            table_html += "<td>" + row[p] + "</td>";
                        else
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
        function goodsImg(obj,SellingPointImg) {
            if(typeof(obj)=="string" && SellingPointImg == ""){
                HideLoading();
                $(".product-detail1").hide();
                $(".product-detail2").hide();
            }else{			    
                
                var htmlStr = "";
                if (SellingPointImg != ""){ 
                    //var htmlStr="<p class='title'>产品解读</p><div style='padding:8px;'>";
                    var mdPicTemp="<img class='SellingPointImg' src='$url$' onclick='javascript:previewImage(this);'/>";
                    var sp = SellingPointImg.split(",");
                    for(var i=0;i<sp.length;i++){
                        if(sp[i] != "")
                            htmlStr += mdPicTemp.replace(/\$url\$/, sp[i]); 
                    }
                }
                else if ((obj.rows[0]["cpmd"]).length>0){
                    var htmlStr="<p class='title'>产品解读</p><div style='padding:8px;'><table>";
                    htmlTemp="<tr ><td style='min-width:85px' >$name$:</td><td>$value$</td></tr>";					
                    //htmlStr+=htmlTemp.replace(/\$name\$/g,"商品货号").replace(/\$value\$/g,obj.rows[0]["sphh"].toString());
                    //htmlStr+=htmlTemp.replace(/\$name\$/g,"商品名称").replace(/\$value\$/g,obj.rows[0]["spmc"].toString());                
                    //htmlStr+=htmlTemp.replace(/\$name\$/g,"商品VCR").replace(/\$value\$/g,"<a id='vcr-play' href='javascript:' onclick='jumptovcr()'><i style='padding-right:5px;' class='fa fa-play'></i>立即查看</a>");
                    if(unescape(obj.rows[0]["cpmd"]).length>0){
                        htmlStr+=htmlTemp.replace(/\$name\$/g,"产品解读").replace(/\$value\$/g,unescape(obj.rows[0]["cpmd"]));
                    }else{                    
                        $(".product-detail1").hide();
                        //$(".nav-btns li[data-item='cpmd']").removeAttr("show").hide();
                        //$(".nav-btns li[show]").eq(0).addClass("active");
                        //$(".nav-btns li[show]").css("width","50%");
                        hideNavs("cpmd");
                    }                

                    if(obj.rows[0]["mlcf"].toString().length>0){
                        htmlStr+=htmlTemp.replace(/\$name\$/g,"面料成份").replace(/\$value\$/g,obj.rows[0]["mlcf"].toString());
                    }
                    htmlStr+="</table></div>";
                }
                
                $(".product-detail1").html(htmlStr);

                //商品图片
                var PicStr="<p class='title'>商品图片</p><div style='text-align:center;'>";
                var PicTemp="<img src='$url$' onclick='javascript:previewImage(this);'/><p class='img-tips'>@SIMPLE YET SOPHISTICATED</p>";
                var mPicTemp="<img class='delay-img' src='' pre-src='$url$' onclick='javascript:previewImage(this);'/><p class='img-tips delay'>@SIMPLE YET SOPHISTICATED</p>";
                if(obj.rows.length==0){ //无图片时
                    PicStr+=PicTemp.replace(/\$url\$/,"http://tm.lilanz.com"+"/oa/res/img/StoreSaler/lllogo5.jpg");
                }else{
                    if(obj.rows.length > 3){
                        for(var i=0;i<obj.rows.length;i++){
                            if(i<3)
                                PicStr+=PicTemp.replace(/\$url\$/,"http://webt.lilang.com:9001"+obj.rows[i]["urlAddress"].toString().replace('..',""));
                            else
                                PicStr+=mPicTemp.replace(/\$url\$/,"http://webt.lilang.com:9001"+obj.rows[i]["urlAddress"].toString().replace('..',""));
                        }
                        PicStr+="<p onclick='lookMorePics(this)' class='flashbox'>点击查看更多图片 <i class='fa fa-angle-down'></i></p>";
                    }else{
                        for(var i=0;i<obj.rows.length;i++){
                            PicStr+=PicTemp.replace(/\$url\$/,"http://webt.lilang.com:9001"+obj.rows[i]["urlAddress"].toString().replace('..',""));
                        }
                    }

                    PicStr+="</div>";                
                    $(".product-detail2").html(PicStr);

                    if($(".product-vcr .vcr_ul li").length==0){
                        $("#vcr-play").parent().parent().hide();                        
                    }                        

                    HideLoading();
                    ShowInfo("加载成功!",1); 
                }                                                        
            }
        }	

        function hideNavs(navName){
            $(".nav-btns li[data-item='"+navName+"']").removeAttr("show").hide();
            $(".nav-btns li[show]").eq(0).addClass("active");
            var len=$(".nav-btns li[show]").length;
            if(len==3){
                $(".nav-btns li[show]").css("width","33.33%");
            }else if(len==2){
                $(".nav-btns li[show]").css("width","50%");
            }else{
                $(".nav-btns li[show]").css("width","100%");
            }

            setTimeout(function(){
                var _name=$(".nav-btns li[show]").eq(0).attr("data-item");
                clickNav(_name);
            },200);
        }
        
        //加载同款商品
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
            if(isInApp){
                llApp.scanQRCode(function (result) {                    
                    var codeType,scanResult;
                    if(result.indexOf("http")>-1){ 
                        codeType="qrCode";
                        scanResult=result.split("?id=")[1];
                    }else{     
                        codeType="barCode";
                        scanResult=result.split(",")[1];                   
                    }
                    getScanSphh(codeType,scanResult);
                });
            }else{
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
        }
        function getScanSphh(codeType,scanResult){
            $.ajax({
                url: "goodsListCoreV7.aspx?ctrl=getScanSphh",
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
                document.body.scrollTop = SaveScrollMyTop;  //还原滚动条高度  
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
//            var stxt = $("[id$=keyword]").val().toUpperCase(); 
//            goodsfilter("sphh",stxt,"");                       
            goodsfilter("","","");
        }

        var searchSphh = "";
        var searchKc = "kczt:1";
        var searchZt = "";    
        var filter = "kczt:1";
        function goodsfilter(searchName,searchVal,info){            
            switch(searchName){
//                case "sphh":
//                    searchSphh = "sphh:" + searchVal;
//                    break;
                case "kczt":
                    searchKc = "kczt:" + searchVal;
                    $("#kcli").html(info);
                    break;
                case "yxzt":
                    searchZt = "yxzt:" + searchVal;
                    $("#ztli").html(info);
                    break;
            }
             
            var searchSphhVal = $("#keyword").val(); 
            searchSphh = "sphh:" + searchSphhVal;

            filter = searchSphh + "|" + searchKc + "|" + searchZt;

            if (searchSphhVal == ""){
            //增加开发编号和分类这两个筛选条件
                var kflst = $("#kflst").val();
                var fllst = $("#fllst").val();
                        
                if (kflst != "")    filter += "|kfbh:" + kflst; 
                if (fllst != "")    filter += "|fl:" + fllst;  
            }else{
                $("#kflst").val("");
                $("#fllst").val("");
            }

            goodsSearch();
        } 
        
        function FilterChange() { 
             $("#keyword").val("");               
             goodsfilter("","","");
        }
         
        function goodsSearch(){
            ShowLoading("数据加载中..",8);
            searchLastID=-1;
                        
            $("#main").empty();
            goodsList();
        }

        function WXShareLink(sphh) {
            var title,imgurl;
            var  _link=window.location.href; 
            var link;
            if (_link.indexOf("?") > -1) link =_link.substr(0,_link.indexOf("?")+1);
            else link = _link + "?"; 

            if(sphh!=""){
                title = "我发现了利郎的一款好货【" + sphh + "】";
                imgurl = $(".main_image ul li:first-child span").css("background").match(new RegExp("\\((.| )+?\\)", "igm"))[1];
                
                imgurl = imgurl.replace(/\"/g, "");//图片的格式为 ("内容") ,在原始代码执行之后 图片前后可能存在双引号，因此需要先替换掉双引号。 By:xlm 20160922
                imgurl = imgurl.substring(1, imgurl.length - 1);  
                link= link + "sphh=" + sphh;
            }else{
                title="我发现了利郎的一批好货";
                imgurl=$("#main").find("dl:first-child").find("dt:first-child").find("img").attr('src');
                link= link + "showType=<%=showType %>";
            }  

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

        function previewImage(s) { //微信预览图片
            var arrUrls = new Array();
            var p;

            if ($(s).attr("class") == "upload-img"){             
                var nowpic = $(s).css("background-image");
                 
                nowpic = nowpic.replace(/\"/g, "");
                nowpic = nowpic.substring(nowpic.indexOf("(")+1,nowpic.indexOf(")")); 
                nowpic = nowpic.replace("/my/","/");
                          
                p=$(s).parent();
                $.each($(p).find("li"), function (i, val) {
                    arrUrls[i] = $(val).css("background-image");

                    arrUrls[i] = arrUrls[i].replace(/\"/g, "");
                    arrUrls[i] = arrUrls[i].substring(arrUrls[i].indexOf("(") + 1,arrUrls[i].indexOf(")"));
                     
                    arrUrls[i] = arrUrls[i].replace("/my/","/"); 
                });
                                
                wx.previewImage({
                    current: nowpic, // 当前显示图片的http链接
                    urls: arrUrls // 需要预览的图片http链接列表
                });
            }
            else if(s["tagName"].toUpperCase()=="SPAN"){
                p=$(s).parent().parent();
                $.each($(p).find("span"), function (i, val) {
                    arrUrls[i] = $(val).attr("style");
                    arrUrls[i] = arrUrls[i].substring(arrUrls[i].indexOf("(")+1,arrUrls[i].indexOf(")"));
                });
                wx.previewImage({
                    current: $(s).attr("style").substring($(s).attr("style").indexOf("(")+1,$(s).attr("style").indexOf(")")), // 当前显示图片的http链接
                    urls: arrUrls // 需要预览的图片http链接列表
                });
            }
            else{
                p=$(s).parent();
                $.each($(p).find("img"), function (i, val) {
                    arrUrls[i] = $(val).attr("src");
                });
                wx.previewImage({
                    current: $(s).attr("src"), // 当前显示图片的http链接
                    urls: arrUrls // 需要预览的图片http链接列表
                });
            }
            arrUrls.length=0;
        }

  
        function clickLike(id){
            $.ajax({
                url: "goodsListCoreV7.aspx?ctrl=clickLike",
                type:"post",
                dataType: "text",
                data: { comID:id},
                timeout: 15000,
                error: function(e){
                    HideLoading();				
                    ShowInfo("网络异常",1);
                },
                success:function (res){
                    if(res.indexOf("Error")>-1){
                        ShowInfo(res,3);
                    }else{
                        var rtObj = JSON.parse(res);
                        $("#zan_"+id).html(rtObj.rows[0].LikeNum);
                    }
                }
            });
        }

        //加载部分评论
        function LoadEvaluation(sphh){ 
            var LoadCount = 3;  //加载帖子数量
            $.ajax({
                url: "goodsListCoreV7.aspx?ctrl=LoadEvaluation",
                type:"post",
                dataType: "text",
                data: { "sphh":sphh,"LoadCount":LoadCount},
                timeout: 15000,
                error: function(e){
                    HideLoading();				
                    ShowInfo("网络异常",2);
                },
                success:function (res){
                    if(res.indexOf("Error")>-1){
                        ShowInfo(res,2);
                    }else{
                        var rtObj = JSON.parse(res);

                        var i;
                        //构造关键字
                        var keywordsCount = rtObj.keywords.length;
                        var evaluationsCount = rtObj.evaluations.length;
                        
                        if (keywordsCount == 0 && evaluationsCount == 0){
                            $("#lookmore").html("暂时还没有评论...");
                        }


                        var htmlKeyword = "";        
                        var obj;
                        for (i = 0; i < keywordsCount; i++) {
                            obj = rtObj.keywords[i];
                            if (obj.Count == "1") htmlKeyword += "<li>" + obj.keyword + "</li>";
                            else htmlKeyword +="<li>" + obj.keyword + "(" + obj.Count + ")</li>";
                        }
                        $("#keywords").html(htmlKeyword);

                        //构造评论 
                        var imgi;
                        var imgCount;
                        var htmlEvaluation = "";                                              
                        for (i = 0; i < evaluationsCount; i++) { 
                            obj = rtObj.evaluations[i];
                            imgCount = obj.img.length;

                            htmlEvaluation += "<li class=\"floatfix\">\n" +
                                              "  <div class=\"top-item floatfix\">\n" +
                                              "      <div class=\"user-img\" style=\"background-image: url(" + obj.userimg + ");\"></div>\n" +
                                              "      <p class=\"user-name\">" + obj.username + "</p>\n" +
                                              "      <p class=\"type-txt\">\n" +
                                              "          <span class=\"comtype\">" + obj.ogroup + "</span>\n" +
                                              "          <span>|</span>\n" +
                                              "          <span class=\"sort\">" + obj.etype + "</span>\n" +
                                              "      </p>\n" +
                                              "  </div>\n" +
                                              "  <div class=\"bottom-item\">\n" +
                                              "      <p>" + obj.centent + "</p>\n" +
                                              "      <p class=\"date\">" + obj.date + "</p>\n";

                            //"<!-- 上传图片列表 (没有图片时隐藏)-->\n"
                            if (imgCount > 0){
                                htmlEvaluation += "      <ul class=\"upload-img-list floatfix\">\n";
                                for (imgi = 0; imgi < imgCount; imgi++) {  
                                    htmlEvaluation += "          <li class=\"upload-img\" style=\"background-image: url(" + obj.img[imgi] + ");\" onclick='javascript:previewImage(this);'></li>\n";
                                }
                                htmlEvaluation += "      </ul>\n" ;
                            }                 

                            htmlEvaluation +=   "  </div>\n";
                            if(parseFloat(obj.totalreward)>0)
                                htmlEvaluation += "<div class='red_paper floatfix'><div class='red_paper'>该评论共获得<span class='red_counts'>"+obj.totalreward+"</span>元赏金</div><img class='red_paper_icon' src='../../res/img/storesaler/redpaper.png' /></div>";
                            htmlEvaluation += "</li>";                                       
                        }
                        $("#evaluations").html(htmlEvaluation); 
                    }
                }
            });
        }

        function jumptovcr(){
            var obj = document.getElementById("main-page");
            $("#main-page").animate({ scrollTop: (obj.scrollHeight - obj.clientHeight) + 'px' }, 500);
        }

        function showVCRs(obj){
            if(obj=="Error:查无VCR"){
                $("#vcr-play").parent().parent().hide();
                hideNavs("vcrtj");
                return;
            } 
            var htmlStr="";
            for(var i=0;i<obj.rows.length;i++){
                var row=obj.rows[i];
                row.videothumb=row.videothumb==""?"http://tm.lilanz.com/oa/res/img/storesaler/lilanzlogo2.jpg":row.videothumb;
                htmlStr+=template("vcr_item_temp",row);
            }//end for
            if(htmlStr!=""){
                $(".vcr_container .vcr_ul").append(htmlStr);
                //$(".product-vcr").show();
            }
        }
        
        function lookmoreFun(){
            window.location.href='goodsCommentV2.aspx?sphh=' + sphh;
        }

        function IsayFun(){
            window.location.href='goodsCommentV2.aspx?Isay=1&sphh=' + sphh;
        }

        //非WIFI状态下显示三张，单击才显示更多图片
        function lookMorePics(btn){
            var obj=$(".product-detail2 .delay-img");
            for(var i=0;i<obj.length;i++){
                $(".product-detail2 .delay-img").eq(i).attr("src",$(".product-detail2 .delay-img").eq(i).attr("pre-src"));
            }

            $(".product-detail2 .delay-img").show();
            $(".product-detail2 .img-tips.delay").show();
            $(btn).hide();
        } 
        
        function clickNav(navName){
            $(".nav-btns li[show]").removeClass("active");
            $(".nav-btns li[data-item='"+navName+"']").addClass("active");
            $(".nav-area").hide();
            $(".nav-area[data-group='area-"+navName+"']").slideDown();
        }

        //新库存查询by liqf 2016-09-29
        //还要传入khid，当用户角色是店长或者是导购时则默认取session["tzid"]
        function newStockQuery(){
            ShowLoading("拼命加载列表中...", 15);
            $.ajax({
                url: "goodsListCoreV7.aspx?ctrl=LoadGoodsStockAuto",
                type: "post",
                dataType: "text",
                data: { sphh:sphh, khid:$("#mykh").val()},
                cache: false,
                timeout: 10000,
                error: function (e) {
                    HideLoading();
                    ShowInfo("网络异常", 1);
                },
                success:function(res){
                    if(res!=""){
                        var data=JSON.parse(res),html="";   
                        //表头
                        html="<tr><th>尺码</th>";
                        for(var i=0;i<data.ColumnTitle.length;i++){
                            html+="<th>"+data.ColumnTitle[i]+"</th>";
                        }
                        html+="</tr>";
                        $(".stock-table thead").append(html);
                        html="";
                        //表体
                        for(var i=0;i<data.RowTitle.length;i++){                            
                            html+="<tr><td>"+data.RowTitle[i];                            
                            for(var j=0;j<data.ColumnTitle.length;j++){             
                                if(j==2 && i<data.RowTitle.length-1)
                                    html+="<td class='cmdm' onclick='stockDetail(\""+data.RowTitle[i]+"\",this)'>"+ GetSLCaption(data["Row"+(i+1)][j])+"</td>";
                                else
                                    html+="<td>"+ GetSLCaption(data["Row"+(i+1)][j]) +"</td>";                                
                            }//end for
                            html+="</td></tr>";
                        }//end for rowtitle
                    }//end if
                    $(".stock-table tbody").append(html);                    
                }
            })
        }

        function GetSLCaption(str){
             if("<%=RoleName%>" =="dg"){
                if (str.indexOf("(") == -1)  {
                    if(parseInt(str)==0)    return "-";
                    else return "有";
                }else{
                    var v1,v2 ,newV;
                                        
                    v1 = str.substring(0,str.indexOf("("));
                    v2 = str.substring(str.indexOf("(") + 1,str.indexOf(")"));

                    newV = GetSLCaption(v1) + "(" + GetSLCaption(v2) + ")"; 
                    return newV;
                }
             }else{
                return str;
             }
        }

        //询问开发建议和质量反馈的跳转
        function goSuggest(type){
            window.location.href="goodsCommentV2.aspx?Isay=1&sphh="+sphh+"&sayType="+type;
        }

        //点击库存表格中的尺码显示对应的库存分布
        function stockDetail(cmdm,obj){
            LeeJSUtils.showMessage("loading","正在加载，请稍候..");
            $.ajax({
                url: "goodsListCoreV7.aspx?ctrl=LoadCmStock",
                type: "post",
                dataType: "text",
                data: {sphh:sphh, cm:cmdm, khid:$("#mykh").val()},
                cache: false,
                timeout: 10000,
                error: function (e) {                    
                    LeeJSUtils.showMessage("error","网络异常");
                },
                success:function(res){
                    if(res=="")
                        LeeJSUtils.showMessage("warn","查无数据！");
                    else{
                        var data=JSON.parse(res);
                        if(data.FromInfo.length==0 && data.SharedInfo.length == 0)
                            LeeJSUtils.showMessage("warn","该尺码没有库存数据！");
                        else{
                            var html="";
                            for(var i=0;i<data.FromInfo.length;i++){
                                var row=data.FromInfo[i];
                                
                                row.islocal=row.local == "1" ? "local" : "";

                                row.sl = GetSLCaption(row.sl); 
                              
                                html+=template("stock_detail_temp",row);
                            }//end for

                            for(var i=0;i<data.SharedInfo.length;i++){
                                var row=data.SharedInfo[i];                                 
                                row.sl = GetSLCaption(row.sl); 
                                html+=template("stock_detail_shared",row);
                            }//end for

                            $("#stock_detail_ul").empty().append(html);
                            $("#title_sphh").text(data.sphh);
                            $("#title_cm").text(data.cm);
                            $("#title_sum").text($(obj).text());
                            $(".stock_detail").show();
                            $("#leemask").hide();
                        }
                    }                    
                }
            });
        }


        function LoadReport(){
            LeeJSUtils.showMessage("loading","查询质检报告中...");
            $.ajax({
                url: "goodsListCoreV7.aspx?ctrl=LoadReport",
                type: "post",
                dataType: "text",
                data: {sphh:sphh},
                cache: false,
                timeout: 20000,
                error: function (e) {                    
                    LeeJSUtils.showMessage("error","网络异常");
                },
                success:function(res){
                    if (res.indexOf("Error:") == 0){
                        res = res.substring(6);
                        LeeJSUtils.showMessage("warn",res);
                    }else{ 
                        LeeJSUtils.showMessage("successed","正在下载质检报告...");
                        setTimeout(function(){
                            window.location.href = res;
                        },50);
                    }
                }
            });
        }
    </script>
</asp:Content>