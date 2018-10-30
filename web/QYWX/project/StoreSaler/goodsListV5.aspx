<%@ Page Title="" Language="C#" MasterPageFile="../../WebBLL/frmQQDBase.Master" AutoEventWireup="true" %>

<%@ MasterType VirtualPath="../../WebBLL/frmQQDBase.Master" %>
<%@ Import Namespace="nrWebClass" %>
<%@ Import Namespace="System.Data" %>
<%@ Import Namespace="System.Data.SqlClient" %>
<%@ Import Namespace="System.Collections.Generic" %>
<%@ Import Namespace="System.Net" %>
<%@ Import Namespace="System.IO" %>
<script runat="server">
    string mdid, mdmc, showType, sphh = "", RoleName = "",khList="";
    public List<string> wxConfig; //微信OPEN_JS 动态生成的调用参数
    private const string ConfigKeyValue = "1";
    // string OAConnStr = clsConfig.GetConfigValue("OAConnStr");
    string OAConnStr = " server=192.168.35.10;uid=ABEASD14AD;pwd=+AuDkDew;database=tlsoft";
    //必须在内容页的Load中对Master.SystemID 进行赋值；
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
    private void LoadMyKhList(string khType,string khid)
    {

        string mySql = "",errInfo="";
        string khOption = "<option value='{0}'>{1}</option>";
        switch (khType)
        {
            case "md": 
                mySql =string.Format("select top 1 mdmc as mdmc,mdid as khid from t_mdb a where a.mdid={0}",khid);
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
           clsSharedHelper.WriteInfo(string.Concat("无法获取客户权限！", errInfo));
        }
        
        mdmc = Convert.ToString(dt.Rows[0]["mdmc"]);
        mdid = Convert.ToString(dt.Rows[0]["khid"]);
        for (int i = 0; i < dt.Rows.Count;i++)
        {
            khList = string.Concat(khList, string.Format(khOption, dt.Rows[i]["khid"], dt.Rows[i]["mdmc"]));
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
        body
        {
            background-color: #f7f7f7;
            color: #2f2f2f;
            font-family: Helvetica,Arial,STHeiTi, "Hiragino Sans GB" , "Microsoft Yahei" , "微软雅黑" ,STHeiti, "华文细黑" ,sans-serif;
        }
        
        .header
        {
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
        
        .fa-angle-left:hover
        {
            background-color: rgba(0,0,0,.1);
        }
        
        .page
        {
            top: 0;
            bottom: 32px;
            padding: 0;
            background-color: #f7f7f7;
        }
        
        .banner
        {
            height: 80vw;
            margin-top: -1px;
            background-color: #fafafa;
        }
        
        .foot-btns
        {
            background-color: #eceef1;
            height: 48px;
            line-height: 48px;
            font-size: 0;
        }
        
        .foot-btns > a
        {
            display: inline-block;
            text-align: center;
            width: 40%;
            color: #575d6a;
            font-size: 16px;
        }
        
        .foot-btns .color-btn
        {
            background-color: #575d6a;
            color: #fff;
            width: 60%;
        }
        
        .product-info, .product-stock, .product-detail1, .product-detail2, .product-cminfo, .product-sameStyle
        {
            background-color: #fff;
            margin: 5px 0;
            padding: 0 5px;
            box-shadow: 0 1px .5px #eceef1;
            -webkit-box-shadow: 0 1px .5px #eceef1;
            position: relative;
        }
        .product-info
        {
            padding: 0 10px;
        }
        .product-info .fa-star, .product-info .fa-star-o
        {
            position: absolute;
            top: 0;
            right: 0;
            font-size: 22px;
            line-height: 44px;
            padding: 0 15px;
            margin-top: 8px;
            border-left: 1px solid #f2f2f2;
        }
        
        .product-info .pro-name
        {
            font-size: 1.1em;
            font-weight: bold;
            color: #555;
            padding-top: 5px;
            color: #2b363a;
        }
        .product-info .llzp, .product-info .zdzt
        {
            background-color: #000;
            color: #fff;
            padding: 4px 8px;
            font-size: 12px;
            line-height: 28px;
            margin-right: 5px;
        }
        .product-info .zdzt
        {
            background-color: #e54801;
        }
        .points
        {
            color: #888;
            font-size: 1.2em;
            font-weight: bold;
            margin-top: 5px;
        }
        
        .points span
        {
            color: #ff6600;
            font-size: 1.5em;
            font-weight: bold;
        }
        .money
        {
            color: #ff5000;
        }
        .money span
        {
            font-size: 1.2em;
        }
        
        .product-stock li
        {
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
            border-radius: 3px;
            display: inline-block;
        }
        
        .product-stock li.none
        {
            color: #c5c9cd;
            border: 1px solid #d8dcdf;
            background-color: #f0f1f3;
        }
        
        .product-stock li.choose
        {
            border: 1px solid #000;
            background: #fff;
            cursor: pointer;
        }
         .product-stock li.total
        {
           
            color: #FFF;
            border: 1px solid #000;
            background-color: #000;
        }
        .product-stock .title, .product-cminfo .title
        {
            font-size: 16px;
            letter-spacing: 1px;
            margin-bottom: 8px;
            border-left: 4px solid #333;
            padding: 8px 0 8px 8px;
            font-weight: 600;
        }
        
        .product-stock
        {
            font-size: 1.1em;
        }
        
        .product-stock > p
        {
            line-height: 20px;
        }
        
        .product-detail1
        {
            font-size: 1.1em;
        }
        
        .product-detail1 > p
        {
            line-height: 20px;
        }
        
        .product-detail1 .title
        {
            font-size: 16px;
            letter-spacing: 1px;
            border-left: 4px solid #333;
            padding: 8px 0 8px 8px;
            font-weight: 600;
        }
        
        .product-detail2
        {
            padding-top: 8px;
        }
        
        .product-detail2 > img
        {
            width: 100%;
            height: auto;
            margin-top: 10px;
        }
        
        .product-detail2 .title
        {
            font-size: 16px;
            letter-spacing: 1px; /*border-bottom: 1px solid #f7f7f7;*/
            margin: -8px 0 0 0;
            border-left: 4px solid #333;
            padding: 8px 0 8px 8px;
            font-weight: 600;
        }
        
        .product-detail2 p
        {
            line-height: 20px;
        }
        /*幻灯区样式*/
        .main_image, .main_image ul, .main_image li, .main_image li span, .main_image li a
        {
            height: 80vw;/*5:4*/
        }
        
        div.flicking_con .flicking_inner
        {
            top: 200px;
        }
        
        .product-stock .u-detail-sl
        {
            color: #d9534f;
            line-height: 28px;
        }
        
        .flicking_inner a
        {
            border: #c9c9c9 0px solid;
        }
        
        .product-stock ul
        {
            padding: 0px;
        }
        
        .footer
        {
            text-align: center;
            height: 30px;
            line-height: 30px;
            font-size: 12px;
            background-color: transparent;
            color: #999;
        }
        
        .u-pro-list-top
        {
            margin-top: 40px;
        }
        
        p, .p
        {
            margin-bottom: 0;
        }
        
        .product-detail2 .img-tips
        {
            text-align: center;
            font-size: 12px;
            color: #333;
            font-weight: 600;
        }
        
        .money span
        {
            line-height: 24px;
        }
        
        td
        {
            padding: 2px 0;
        }
        
        .header .icon-camera
        {
            font-size: 1.2em;
        }
        
        .top-fixed .top-search input
        {
            line-height: 30px;
        }
        
        .top-fixed .top-title
        {
            white-space: nowrap;
            max-width: 210px;
            text-overflow: ellipsis;
        }
        /*cminfos style*/
        .product-cminfo .cm-content
        {
            width: 100%;
            height: 220px;
            overflow: auto;
            -webkit-overflow-scrolling: touch;
        }
        
        .cm-table
        {
            border-collapse: collapse;
            border: none;
            margin: 0 auto;
            color: #333;
        }
        
        .cm-table th
        {
            font-size: 14px;
            background-color: #535353;
            color: #fff;
            white-space: nowrap;
        }
        
        .cm-table td, .cm-table th
        {
            border: solid #e1e1e1 1px;
            min-width: 60px;
            text-align: center;
            padding: 6px 10px;
        }
        
        .cm-tips
        {
            padding: 5px 0;
        }
        
        .cm-tips p
        {
            color: #666;
            font-size: 14px;
            font-weight: 600;
            line-height: 1.4;
        }
        .header
        {
            border-bottom: none;
        }
        .product-sameStyle .title
        {
            font-size: 16px;
            letter-spacing: 1px; /*border-bottom: 1px solid #f7f7f7;*/
            margin: -8px 0 0 0;
            border-left: 4px solid #333;
            padding: 8px 0 8px 8px;
            font-weight: 600;
        }
        .product-sameStyle a
        {
            padding: 0px;
        }
        #sameStyle dl
        {
            float: left;
        }
        .b_goods_name_sameStyle
        {
            height: 25px;
        }
        #sameStyle dl a dt
        {
            padding-bottom: 100%;
        }
        
        #sameStyle dl a dt img
        {
            width: auto;
            height: 180px;
        }
        .product-stock p
        {
            background-color: #F4A460;
        }
        .product-stock p span
        {
            padding: 15px 5px 15px 0px;
            color: Gray;
        }
        .product-stock p :first-child
        {
            color: #000;
        }
        .product-sameStyle
        {
            display: none;
        }
        .icon-chevron-right
        {
            float: right;
        }
        .opinionClass
        {
            margin-right: 15px;
            font-weight: normal;
            font-size: 14px;
        }
        .x3
        {
            text-align: center;
            width: 33.33%;
        }
        .product-stock
        {
            padding-top: 15px;
        }
        .product-stock .nav_nums
        {
            border: 1px solid #d96a59;
            border-radius: 2px;
            margin: 0 auto 15px auto;
            width: 90%;
            font-size: 14px;
        }
        .product-stock .nav_nums li
        {
            float: left;
            margin: 0;
            border-radius: 0;
            border-right: 1px solid #d96a59;
            color: #999;
        }
        .product-stock .nav_nums li.selected
        {
            background-color: #d96a59;
            color: #fff;
        }
        .product-stock .nav_nums li:last-child
        {
         border-right: none;
        }
       .col3 li
        {
            width:33.33%;
        }
         .col5 li
        {
            width:20%;
        }
        #mykh
        {
           position:absolute;
           height:0.1px;
           opacity: 0;
           z-index:-1;
        }
      <%--  评论样式--%>
      .product-comment{
    		background-color: #fff;
            margin: 5px 0;
            padding: 0 0 5px 5px;
            box-shadow: 0 1px .5px #eceef1;
            -webkit-box-shadow: 0 1px .5px #eceef1;
            position: relative;
    	}
    	.product-comment .title{
    		font-size: 16px;
            letter-spacing: 1px;
            margin: -8px 0 0 0;
            border-left: 4px solid #333;
            padding: 8px 0 8px 8px;
            font-weight: 600;
    	}
    	.arrow{
    		color: #949494;
    		float: right;
    		padding: 8px 14px 8px 8px;
    		
    	}
    	.comment-list{
    		display: none;
    	}
    	.comment-li{
    		width: 100%;
    		padding: 12px 8px;
    		border-top: 1px solid #e4e4e4;
    	}
    	.user-info{
    		width: 100%;
    		height: 40px;
    		line-height: 40px;

    	}
    	.user-img{
    		width: 40px;
    		height: 40px;
    		border-radius: 50%;
    		background-image: url("../../res/img/StoreSaler/default.jpg");
    		background-position: 50% 50%;
    		background-size: cover;
    		float: left;   		
    	}
    	.user-name{
    		float: left;
    		margin-left: 12px;
    		color: #333;
    	}
    	.user-comment{
    		padding: 10px 0 6px 0;
    	}
    	.other-info{
    		font-size: 13px;
    		color: #949494;
    		margin-top: 10px;
    	}
    	.left-info{
    		float: left;
    	}
    	.right-info{
    		float: right;
    	}
    	.suggest, .zan{
    		display: inline-block;
    		margin-left: 5px;
    	}
    	.icon{
    		width: 18px;
    		vertical-align: middle;
    		display: inline-block;
    		margin-right: 3px;
    	}
    	.zan-icon{
    		width: 17px;
    	}
    	.right-info p{
    		display: inline-block;
    	}
    	.commentbtn{
    		width: 140px;
    		height: 26px;
    		background-color: #333;
    		margin: 10px auto;
    		color: #fff;
    		line-height: 25px;
    		text-align: center;
    		font-weight: 500;
    	}
    	/*发表评论*/
    	.comment-mask{
    		width: 100%;
            height: 100%;
            position: fixed;
            top: 0;
            left: 0;
            background-color: rgba(0,0,0,0.4);
            z-index: 9999;  
            display: none;          
    	}
    	.comment-container{
    		position: absolute;
            top: 50%;
            left: 50%;
            transform: translate(-50,-50%);
            -webkit-transform: translate(-50%,-50%);
            background-color: #f0f0f0;
            border-radius: 4px;
            height:340px;
            width: 88%;
            padding: 0 10px;
    	}
    	.mask-title{
    		width: 100%;
    		padding: 8px;
    		text-align: center;
    	}
    	.close-icon{
    		position: absolute;
    		width: 22px;
    		right: 10px;
    	}
    	.heading{
    		font-size: 16px;
            letter-spacing: 1px;
            font-weight: 600;
            display: inline-block;
    	}
    	.suggest-txt{
    		width: 100%;
    		height: 240px;
    		-webkit-appearance: none;
    		border-radius: 0;
    		border: 1px solid #e4e4e4;
    		font-size: 14px;
    	}
    	.definebtn{
    		width: 100%;
    		height: 32px;
    		background-color: #333;
    		color: #fff;
    		text-align: center;
    		line-height: 32px;
    		margin-top: 10px;
    	}
    	/*mask style*/
        .loader-container {
            position: absolute;
            top: 50%;
            left: 50%;
            transform: translate(-50,-50%);
            -webkit-transform: translate(-50%,-50%);
            background-color: rgba(0,0,0,0.4);
            border-radius: 4px;
            height:50px;
            line-height:1;
        }

        .load8 .loader {
            font-size: 10px;
            position: relative;
            border-top: 4px solid rgba(0,0,0,0.1);
            border-right: 4px solid rgba(0,0,0,0.1);
            border-bottom: 4px solid rgba(0,0,0,0.1);
            border-left: 4px solid #555;
            -webkit-animation: load8 0.5s infinite linear;
            animation: load8 0.5s infinite linear;
            position:absolute;
            top:10px;
            left:10px;       
        }

            .load8 .loader,
            .load8 .loader:after {
                border-radius: 50%;
                width: 30px;
                height: 30px;
                box-sizing: border-box;                
            }

        .loader-text {
            font-weight: bold;
            font-size: 14px;
            color: #555;
            padding: 0 10px 0 50px;
            line-height: 50px;
            white-space: nowrap;
            max-width: 200px;
        }

        @-webkit-keyframes load8 {
            0% {
                -webkit-transform: rotate(0deg);
                transform: rotate(0deg);
            }

            100% {
                -webkit-transform: rotate(360deg);
                transform: rotate(360deg);
            }
        }

        @keyframes load8 {
            0% {
                -webkit-transform: rotate(0deg);
                transform: rotate(0deg);
            }

            100% {
                -webkit-transform: rotate(360deg);
                transform: rotate(360deg);
            }
        }

        .loader {
            -webkit-transform: translateZ(0);
            -moz-transform: translateZ(0);
            -ms-transform: translateZ(0);
            -o-transform: translateZ(0);
            transform: translateZ(0);
        }
        .load{
        	display: none;
        	z-index: 99999;
        }
		.successbox{
			display: none;
			z-index: 99999;
		}
		.successbox p{
			text-align: center;
            padding: 0 32px;
            
		}
		.comment-more, .comment-nomore
		{
		    width:100%;
		    text-align:center;
		    display:none;
		    font-size:14px;
		    padding-top:5px;
		    padding-bottom:5px;
		}
		.comment-nomore
		{
		    display:none;
		    color:#999;
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
                        <span id="titleKh" onclick="selectMyKh()" ><%=mdmc %><i class="icon-sort-down"></i></span>  
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
                    <!--   <div class="serch-bar-mask-list">
                        <ul>
                            <li class="on"><a href="javascript:goodsfilter('splb','')">全部</a></li>
                            <li><a title="西服" href="javascript:goodsfilter('splb','西服')">西服</a></li>
                            <li><a title="茄克" href="javascript:goodsfilter('splb','茄克')">茄克</a></li>
                            <li><a title="风衣" href="javascript:goodsfilter('splb','风衣')">风衣</a></li>
                            <li><a title="裤子" href="javascript:goodsfilter('splb','裤')">裤子</a></li>
                        </ul>
                    </div>-->
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
               <i class="fa fa-angle-left" onclick="javascript:childDetail();"></i>
            <!--<div class="header">                
                <i class="fa-angle-left icon-camera" onclick="javascript:Scan()"></i>
                商品详情
            </div>-->
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
                        <!-- 商品库存信息 -->
                    </div>
                    <div class="product-detail1">
                        <!-- 商品信息(卖点成份) -->
                    </div>

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

                      <!--评论列表开始-->
                    <div class="product-comment">
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
                    <div class="product-detail2" >
                        <!--<p class="title">商品详情</p>-->
                    </div>
                    
                    <div class="product-sameStyle">
                        <p class="title">同款商品</p>
                        <div id="sameStyle" class="u-pro-list clearfix ">
                        
                        </div>
                    </div> 
                </div>
            </div>
             <!-- 发表评论 -->
	        <div class="comment-mask">
		        <div class="comment-container">
			        <div class="mask-title">
				        <p class="heading">发表评论</p>
				        <img class="close-icon" src="../../res/img/StoreSaler/close-icon.png" onclick="closeCommentMask()">
			        </div>
			        <textarea class="suggest-txt" placeholder="在这里写点东西吧..."></textarea>
			        <div class="definebtn" onclick="comment()">确定</div>
		        </div>
	        </div>
             <!-- 提示面板 -->
	        <div class="tip-mask">
		        <div class="load loader-container load8">
                    <div class="loader"></div>
                    <p class="loader-text">正在发表...</p>
                </div>
                <div class="loader-container successbox">
			        <p class="loader-text">发表成功！</p>
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
     <script type="text/javascript">
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
        var mdmc = "<%=mdmc %>";
        var commentMaxID="-1";//commentMaxID=-1 未加载评论信息commentMaxID=N 还有未加载的评论信息 commentMaxID=0 评论信息已全部加载
        window.onload = function () {
            wxConfig(); //微信接口注入
            if (typeof(sphh) != undefined && sphh != "") {
                goodsDetail(sphh, "", "");
                $(".header").find("i:first-child").hide();
                $(".header").find("i:last-child").show()
            } else {
                goodsList();
            }
            LeeJSUtils.stopOutOfPage("#main-page", true);
            LeeJSUtils.stopOutOfPage(".header", false);
            LeeJSUtils.stopOutOfPage(".footer", false);
        }
        function KhChange() {
            if (mdid != $("#mykh").val()) {
                mdid = $("#mykh").val();
                mdmc = $("#mykh").find("option:selected").text();
                $("#titleKh").html(mdmc+"<i class='icon-sort-down'></i>");
                $("#main").empty();
                lastID = "-1";
                searchLastID = "-1";
                goodsList();
            }
        }
        function selectMyKh() {
            $("#mykh").focus();
        }
        function wxConfig() {//微信js 注入
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
                url: "goodsListCoreV5.aspx?ctrl=goodsListSingle",
                type: "post",
                dataType: "text",
                data: { showType: "<%=showType %>", mdid: mdid, lastID: searchLastID },
                cache: false,
                timeout: 15000,
                error: function (e) {
                    HideLoading();
                    ShowInfo("网络异常", 1);
                },
                success: function (res) {
                    if (res.indexOf("Error") > -1) {
                        HideLoading();
                        ShowInfo("goodsListSingle " + res.replace("Error:", ""), 1);
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
                                    obj.rows[i]["kc"]="有";
                                }else{
                                    obj.rows[i]["kc"]="无";
                                }
                            }
                            if (obj.rows[i]["urlAddress"].toString() != "") {
                                htmlStr += temp.replace(/\$mid\$/g, obj.rows[i]["xh"].toString()).replace(/\$url\$/g, "http://webt.lilang.com:9001" + obj.rows[i]["urlAddress"].toString().replace("..", '')).replace("$productid$", obj.rows[i]["xh"].toString()).replace(/\$sphh\$/g, obj.rows[i]["sphh"].toString()).replace(/\$spmc\$/g, obj.rows[i]["spmc"].toString()).replace(/\$lsdj\$/g, obj.rows[i]["lsdj"].toString()).replace(/\$kc\$/g, obj.rows[i]["kc"].toString());
                            } else {
                                htmlStr += temp.replace(/\$mid\$/g, obj.rows[i]["xh"].toString()).replace(/\$url\$/g, "http://tm.lilanz.com" + "/oa/res/img/StoreSaler/lllogo5.jpg").replace("$productid$", obj.rows[i]["xh"].toString()).replace(/\$sphh\$/g, obj.rows[i]["sphh"].toString()).replace(/\$spmc\$/g, obj.rows[i]["spmc"].toString()).replace(/\$lsdj\$/g, obj.rows[i]["lsdj"].toString()).replace(/\$kc\$/g, obj.rows[i]["kc"].toString());
                            }
                        }
                        $("#main").append(htmlStr);
                        searchLastID = $("#main dl:last-child").attr("data-mid");
                        $("#u-more-btn").text("-加载更多-");
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
          //加载详情页
          function goodsDetail(sphh,spmc,lsdj) {
              ShowLoading("数据加载中..",5);
              if ("<%=showType%>" != "2") {
                  $("#htmlList").hide();
                  $('#htmlDetail').html($("#page2").html()).show();
                  $(".fa-angle-left.icon-camera").hide();
              } else {
                  ShowLoading("拼命加载中...", 15);
              }
              $.ajax({
                  url: "goodsListCoreV5.aspx?ctrl=goodsDetail",
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
                  var endHtml = "<ul style='padding-left:0;'>";

                  for (var i = 0; i < obj.rows.length; i++) {
                      topHtml += "<a href='javascript:'>" + (i + 1) + "</a>";
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
                $(".product-stock").empty();			   
                $(".product-stock").html(htmlStr);			
            }			
        }
        //加载详情页其他内容
        function getOtherDetail(sphh){
            $("#detail_sphh").val(sphh);
            commentMaxID="-1";

            $.ajax({
                url: "goodsListCoreV5.aspx?ctrl=otherDetail",
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
                    var CMInfos=rtObj.CMInfos;
                    var TheSameType = rtObj.TheSameType;
                    var OFBNum=rtObj.OFBNum;
                    goodsImg(gImg);
                    LoadCMInfos(CMInfos);
                    loadSameType(TheSameType);

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
                url: "goodsListCoreV5.aspx?ctrl=goodsStock",
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
                url: "goodsListCoreV5.aspx?ctrl=getScanSphh",
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
            goodsfilter("sphh",stxt);
        }
        function goodsfilter(searchName,searchVal){
        ShowLoading("数据加载中..",8);
             searchLastID=-1;
            if(searchVal!=""){
                var filter=searchName+"|"+searchVal;
            }else{
                goodsList();
                $("#main").empty();
                return;
            }
             $.ajax({
                url: "goodsListCoreV5.aspx?ctrl=goodsListSingle",
                type:"post",
                dataType: "text",
                contentType: "application/x-www-form-urlencoded; charset=gb2312",
                data: {showType: "<%=showType %>", mdid:mdid, lastID: searchLastID,filter:filter},
                catch: false,
                timeout: 15000,
                error: function(e){	
                    HideLoading();	
                    ShowInfo("网络异常",1);
                },
                success:function (res){
                    HideLoading();
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
                              goodsDetail(obj.rows[0]["sphh"].toString(),obj.rows[0]["spmc"].toString(),obj.rows[0]["lsdj"].toString());
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
                 link= link + "sphh=" + sphh;
              }else{
                 title="我发现了利郎的一批好货";
                 imgurl=$("#main").find("dl:first-child").find("dt:first-child").find("img").attr('src');
                 link=link+"showType="+"<%=showType %>";
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
            if(s["tagName"].toUpperCase()=="SPAN"){
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


          	// 关闭发表评论窗口
		function closeCommentMask(){
			$(".comment-mask").hide();
		}
		// 显示发表评论窗口
		function showCommentMask(){
			$(".comment-mask").show();
            $(".suggest-txt").val("");
		}
		// 下拉面板展开
		function showCommentList(){
			var myclass = $(".arrow").attr("class");
            if (myclass.indexOf("down") > -1) {
                myclass = myclass.replace("down", "up");
                $(".comment-list").slideDown();
                if(commentMaxID==-1){
                    LoadMoreComment();
                }
                if(commentMaxID==0){
                    $(".comment-nomore").slideDown();
                }else{
                    $(".comment-more").slideDown();
                }
            } else {
                myclass = myclass.replace("up", "down");
                $(".comment-list").slideUp();
                $(".comment-more").slideUp();
                $(".comment-nomore").slideUp();
            }
            $(".arrow").attr("class", myclass);
		}
		// 发表评论
		function comment(){
			var li = document.createElement("li");
			var comment_con = $(".suggest-txt").val();
			li.className = "comment-li";
			li.innerHTML = '<div class="user-info floatfix"><div class="user-img"></div><p class="user-name">有圈</p></div><div class="user-comment">'+comment_con+'</div><div class="other-info floatfix"><p class="left-info date">2016-08-16</p><div class="right-info">'+'<div class="suggest"><img class="icon suggest-icon" src="../../res/img/StoreSaler/suggest.png"><p>评论(<span class="suggest-num">5</span>)</p></div><div class="zan"><img class="icon zan-icon" src="../../res/img/StoreSaler/zan.png"></img><p>赞(<span class="zan-num">6</span>)</p></div></div></div>'			
//			$(".load").show();
//			setTimeout(function () {
//                $(".loader-text").html("发表成功");
//		        $(".successbox").show();
//		        $(".load").hide();
//				$(".successbox").fadeOut(1000);
//				$(".comment-mask").hide();
//				$(".comment-list").append(li);	
//		    }, 1000);
            
             ShowLoading("提交评论..","3");
             $.ajax({
                url: "goodsListCoreV5.aspx?ctrl=SubmitComment",
                type:"post",
                dataType: "text",
                data: { sphh:$("#detail_sphh").val(),comment:comment_con},
                contentType: "application/x-www-form-urlencoded; charset=utf-8",
                catch: false,
                timeout: 15000,
                error: function(e){
                    HideLoading();				
                    ShowInfo("网络异常",5);
                },
                success:function (res){
                	$(".comment-mask").hide();
                    if(res.indexOf("Error") > -1){
                        HideLoading();
                        ShowInfo(res,3);
                    }else{
                        var rtObj = JSON.parse(res);
                        var headImg="";
                         if(rtObj.headImg.indexOf("http") < 0){
                                 headImg="http://tm.lilanz.com/oa/"+rtObj.headImg;
                             }else{
                                 headImg=rtObj.headImg;
                             }
                        var liHtml="<li class='comment-li'><div class='user-info floatfix'><div class='user-img'><img class='user-img' src='#headImg#'></img></div><p class='user-name'>#username#</p></div><div class='user-comment'>#content#</div><div class='other-info floatfix'><p class='left-info date'>#date#</p><div class='right-info'><div class='zan' onclick= clickLike('#comID#')><img class='icon zan-icon' src='../../res/img/StoreSaler/zan.png'></img><p>赞(<span class='zan-num' id='zan_#comID#'>0</span>)</p></div></div></div></li>";
                        liHtml =liHtml.replace("#username#",rtObj.cname).replace("#content#",comment_con).replace("#date#",rtObj.date).replace(/\#comID#/g,rtObj.id).replace("#headImg#",headImg);
                        if(commentMaxID=="-1"){
                            commentMaxID=rtObj.id;
                        }
                        if( $(".comment-list li:first").html()==null){
                            $(".comment-list").append(liHtml);
                        }else{
                            $(".comment-list li:first").before(liHtml);
                        }
                        HideLoading();
                        ShowInfo("评论成功!",1); 
                        var comNum=$(".comment-num").html();
                        comNum=Number(comNum)+1;
                        $(".comment-num").html(comNum);
                        if( $(".arrow").attr("class").indexOf("down") > -1){
                            showCommentList();
                        }
                    }
                }
            });
		}
        //加载更多评论
        function LoadMoreComment(){
     //   ShowLoading("加载评论..","3");
           $.ajax({
                url: "goodsListCoreV5.aspx?ctrl=getCommentList",
                type:"post",
                dataType: "text",
                data: { sphh:$("#detail_sphh").val(),maxId:commentMaxID},
                catch: false,
                timeout: 15000,
                error: function(e){
                    HideLoading();				
                    ShowInfo("网络异常",1);
                },
                success:function (res){
                    if(res.indexOf("Error")>= 0){
                        HideLoading();
                        ShowInfo(res,3);
                    }else{
                        var rtObj = JSON.parse(res);
                        var liHtml="<li class='comment-li'><div class='user-info floatfix'><div class='user-img'><img class='user-img' src='#headImg#'></img></div><p class='user-name'>#username#</p></div><div class='user-comment'>#content#</div><div class='other-info floatfix'><p class='left-info date'>#date#</p><div class='right-info'><div class='zan' onclick=clickLike('#comID#')><img class='icon zan-icon' src='../../res/img/StoreSaler/zan.png'></img><p>赞(<span class='zan-num' id='zan_#comID#'>#zanNum#</span>)</p></div></div></div></li>";
                        var liList="";
                        var headImg="";
                        for(var i=0;i<rtObj.rows.length;i++){
                            if(rtObj.rows[i].headImg.indexOf("http") < 0){
                                 headImg="http://tm.lilanz.com/oa/"+rtObj.rows[i].headImg;
                             }else{
                                 headImg=rtObj.rows[i].headImg;
                             }
                           liList +=liHtml.replace("#username#",rtObj.rows[i].cname).replace("#content#",rtObj.rows[i].OFBContent).replace("#date#",rtObj.rows[i].CreateTime).replace(/\#comID#/g,rtObj.rows[i].id).replace("#zanNum#",rtObj.rows[i].LikeNum).replace("#headImg#",headImg);
                        }
                        $(".comment-list").append(liList);
                    //    HideLoading();
                    //    ShowInfo("加载成功!",1); 

                        if(rtObj.rows.length<10){//一次查询10条，小于10条则说明已无评论
                            commentMaxID=0;
                            $(".comment-more").hide();
                            $(".comment-nomore").show();
                        }else{
                            commentMaxID=rtObj.rows[9].id;
                        }
                    }
                }
            });
        }
        function clickLike(id){
            $.ajax({
                url: "goodsListCoreV5.aspx?ctrl=clickLike",
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
//        function DetailInit(sphh){

//        }
    </script>
</asp:Content>
