<%@ Page Title="琅琊榜" Language="C#" MasterPageFile="../../WebBLL/frmQQDBaseV2.Master" AutoEventWireup="true" %>

<%@ MasterType VirtualPath="../../WebBLL/frmQQDBaseV2.Master" %>

<%@ Import Namespace="nrWebClass" %>


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
    public string ryid = "";
    public string mdid = "";
    protected void Page_PreRender(object sender, EventArgs e)
    {
        mdid = Convert.ToString(Session["mdid"]);
        if (mdid == "") clsWXHelper.ShowError("找不到门店信息！");
        //mdid = "6206";
        //ryid = "54615";
         
        string SystemKey = this.Master.AppSystemKey;

        //QQD_WebService.IBLL myBLL = QQD_WebService.BLL.BLLFactory.CreateInstance("QQD_WebService.BLL.BLL_XLM"); 
        QQD_WebService.IBLL myBLL = QQD_WebService.BLL.BLLFactory.CreateInstance();
        ryid = Convert.ToString(myBLL.GetRelateID(SystemKey));

        //clsLocalLoger.WriteInfo("mdid=" + mdid);
        //clsLocalLoger.WriteInfo("ryid=" + ryid); 
        
        ////测试输出
        //clsSharedHelper.WriteInfo(string.Format("qy_customersid ={0} , SystemKey={1} , ryid={2} , mdid={3}",
        //                 Session["qy_customersid"], this.Master.AppSystemKey, ryid, Session["mdid"]));
    }

    //必须在内容页的Load中对Master.SystemID 进行赋值；
    protected void Page_Load(object sender, EventArgs e)
    {
        //this.Master.IsTestMode = true; 
    }

</script>

<asp:Content ID="Content1" ContentPlaceHolderID="head" runat="server">
    <meta name="format-detection" content="telephone=no" />
    <title>琅琊榜</title>
    <link type="text/css" rel="stylesheet" href="../../res/css/font-awesome.min.css" />
    <style type="text/css">
        *
        {
            padding: 0;
            margin: 0;
        }

        a, button, input, textarea
        {
            -webkit-tap-highlight-color: rgba(0,0,0,0);
        }

        body
        {
            font-family: Helvetica,Arial,"Hiragino Sans GB","Microsoft Yahei","微软雅黑",STHeiti,"华文细黑",sans-serif;
            font-size: 14px;
            background-color: #fff;
        }

        .header
        {
            display: block;
            position: fixed;
            top: 0;
            left: 0;
            width: 100%;
            z-index: 211;
            height: 40px;
            border-bottom: 0px solid #161A1C;
            text-align: center;
            padding: 0 0px;
            box-sizing: border-box;
        }

        .logo
        {
            height: 22px;
            margin: 0 auto;
            margin-top: 18px;
            color: #fff;
            z-index: 110;
        }

            .logo img
            {
                height: 100%;
                width: auto;
            }

        .vipul
        {
            position: absolute;
            top: 90px;
            bottom: 40px;
            width: 100%;
            list-style: none;
            box-shadow: inset 0 0 0 1px rgba(0,0,0,.16),0 1px 3px rgba(0,0,0,.06);
            background-color: #f0f0f0;
            overflow-x: hidden;
            overflow-y: scroll;
            -webkit-overflow-scrolling: touch;
            -webkit-transition: -webkit-transform .4s cubic-bezier(.4,.01,.165,.99);
            transition: transform .4s cubic-bezier(.4,.01,.165,.99);
            /*-webkit-transition: -webkit-transform .4s cubic-bezier(.4,.01,.165,.99);*/
            /*transition: transform .4s cubic-bezier(.4,.01,.165,.99);*/
            transform: translate3d(-100%, 0, 0);
            -webkit-transform: translate3d(-100%, 0, 0);
        }

            .vipul li
            {
                height: 54px;
                padding: 6px 10px;
                border-bottom: 1px solid #cbcbcb;
                position: relative;
                opacity: 0;
                
            }


        .userimg
        {
            /*border: 2px solid #fff;*/
            width: 50px;
            height: 50px;
            /*overflow: hidden;*/
            float: left;
            position: relative;
            z-index: 99;
        }

        .rankicon
        {
            position: absolute;
            top: -10px;
            right: -10px;
            z-index: 100;
        }

        .userimg .rankicon img
        {
            width: 26px;
            height: 26px;
            border-radius: 50%;
        }

        .tags, .sorts
        {
            background-color: #272B2E;
            position: absolute;
            right: 10px;
            top: 50%;
            margin-top: -15px;
            padding: 0 12px;
            height: 30px;
            border-radius: 4px;
            line-height: 29px;
            border: 1px solid #161A1C;
            box-shadow: 0 1px 1px #2B2F32 inset;
            font-size: 15px;
            color: #DFE0E0;
            box-sizing: border-box;
            z-index: 120;
            cursor: pointer;
            display: none;
        }

        .userimg img
        {
            width: 100%;
            height: 100%;
            border-radius: 50%;
        }

        .vipul li > h3
        {
            color: #515151;
            font-weight: 400;
            font-size: 16px;
            margin: 2px 0 0 66px;
            line-height: 1.5;
            letter-spacing: 1px;
        }

        .vipul li p
        {
            color: #888;
            line-height: 1;
            margin: 8px 0 0 66px;
            letter-spacing: 1px;
            white-space: nowrap;
            text-overflow: ellipsis;
        }



        /*底部菜单样式*/
        .bottomnav
        {
            height: 40px;
            background-color: #f8f8f8;
            width: 100%;
            position: absolute;
            bottom: 0;
            left: 0;
            border-top: 1px solid #cbcbcb;
            z-index: 200;            
            background-image:url('../../res/img/StoreSaler/long3.jpg');
            background-repeat:repeat; 
            background-position:center;
            background-size:100%;
            background-color:#fff;
        }

        .navul
        {
            list-style: none;
            padding: 6px 0 6px 0;
            box-sizing: border-box;
        }

            .navul li
            {
                width: 25%;
                float: left;
                text-align: center;
                height: 30px;
                line-height: 30px;
                color: #101010;
                cursor: pointer;
            }



            .navul p
            {
                font-weight: 400;
                font-size: 1.2em;
            }

        #selected
        {
            color: #272b2e;
        }

        .topnav
        {
            position: fixed;
            top: 0;
            left: 0;
            right: 0;
            bottom: 0;
            padding-top: 59px;
            overflow-x: hidden;
            overflow-y: auto;
            background: #333537;
            z-index: 210;
            -webkit-transition: -webkit-transform .4s cubic-bezier(.4,.01,.165,.99);
            transition: transform .4s cubic-bezier(.4,.01,.165,.99);
            -webkit-transform: translate(0,-100%);
            -webkit-transform: translate3d(0,-100%,0);
            transform: translate3d(0,-100%,0);
            color: #fff;
        }

        div.showtags
        {
            transform: translate3d(0,0,0);
            -webkit-transform: translate3d(0,0,0);
            -webkit-transform: translate(0,0,0);
        }

        /*打标签CSS*/
        .tagcontent
        {
            width: 100%;
            color: #eee;
            padding: 0 10px;
            box-sizing: border-box;
            position: absolute;
            top: 60px;
            bottom: 60px;
            overflow-x: hidden;
            overflow-y: scroll;
            -webkit-overflow-scrolling: touch;
        }

            .tagcontent ul
            {
                list-style: none;
                text-align: center;
            }

                .tagcontent ul li
                {
                    float: left;
                    font-size: 1em;
                    width: 30.6%;
                    border: 1px solid #eee;
                    padding: 6px 0;
                    box-sizing: border-box;
                    border-radius: 5px;
                    margin-top: 10px;
                    cursor: pointer;
                }

                    .tagcontent ul li:not(:first-child)
                    {
                        margin-left: 4.1%;
                    }

                    .tagcontent ul li:nth-child(4n)
                    {
                        margin-left: 0;
                    }

            .tagcontent p
            {
                margin-top: 18px;
                font-size: 1.2em;
            }

        .floatfix:after
        {
            content: "";
            display: table;
            clear: both;
        }

        .tagselected
        {
            background-color: #ebebeb;
            color: #333;
        }

        .topnav .footer
        {
            width: 100%;
            position: absolute;
            bottom: 0;
            left: 0;
            text-align: center;
            font-size: 1.4em;
            padding: 10px 0;
            background-color: #eee;
            color: #272b2e;
            font-weight: bold;
            height: 30px;
            line-height: 30px;
            vertical-align: middle;
        }

        /*用户信息css*/
        .userinfo
        {
            position: fixed;
            top: 59px;
            bottom: 0;
            width: 100%;
            background-color: rgb(229,229,229);
            z-index: 206;
            padding: 0 5px;
            box-sizing: border-box;
            -webkit-transition: -webkit-transform .4s cubic-bezier(.4,.01,.165,.99);
            transition: transform .4s cubic-bezier(.4,.01,.165,.99);
            -webkit-transform: translate(100%,0);
            -webkit-transform: translate3d(100%,0,0);
            transform: translate3d(100%,0,0);
            overflow-x: hidden;
            overflow-y: scroll;
            -webkit-overflow-scrolling: touch;
        }

        .showinfo
        {
            transform: translate3d(0,0,0);
            -webkit-transform: translate3d(0,0,0);
            -webkit-transform: translate(0,0,0);
        }

        .headimg
        {
            width: 70px;
            height: 70px;
            border: 4px solid #ebebeb;
            border-radius: 50%;
            -webkit-border-radius: 50%;
            background-image: url(../../img/StoreSaler/headimg.jpg);
            background-size: cover;
            margin: 0 auto;
        }

        .peace1
        {
            width: 78px;
            height: 78px;
            border-radius: 50%;
            position: absolute;
            top: 25px;
            left: 50%;
            margin-left: -39px;
            -webkit-animation: peace-color 5s linear infinite;
            animation: peace-color 5s linear infinite;
        }

        @keyframes peace-color
        {
            from
            {
                transform: rotate(0deg);
            }

            50%
            {
                -webkit-box-shadow: 0 1px 4px #888;
                box-shadow: 0 1px 4px #888;
            }

            to
            {
                transform: rotate(360deg);
            }
        }

        @-webkit-keyframes peace-color
        {
            from
            {
                -webkit-transform: rotate(0deg);
            }

            50%
            {
                -webkit-box-shadow: 0 1px 4px #888;
                box-shadow: 0 1px 4px #888;
            }

            to
            {
                -webkit-transform: rotate(360deg);
            }
        }

        .userinfo hr
        {
            width: 80%;
            margin: 10px auto 15px auto;
            border: none;
            height: 1px;
            background-color: #ccc;
        }

        .nickname
        {
            text-align: center;
            font-size: 1.4em;
            margin-top: 10px;
            letter-spacing: 1px;
            color: #666;
            font-weight: bold;
        }

        .userinfo ul
        {
            list-style: none;
        }

        .userheader ul li
        {
            font-size: 1em;
            color: #808080;
            float: left;
            width: 33.33%;
            text-align: center;
            box-sizing: border-box;
        }

            .userheader ul li:not(:first-child)
            {
                border-left: 1px solid #ccc;
            }

        .userval
        {
            color: #494747;
            font-size: 1.1em;
            text-shadow: 0 0 1px #ccc;
        }

        .userheader, .usernav
        {
            background-color: #fff;
            border-radius: 5px;
            padding: 10px 0;
            margin: 10px auto;
            box-shadow: inset 0 0 0 1px rgba(0,0,0,.16),0 1px 3px rgba(0,0,0,.06);
        }

            .usernav ul
            {
                padding: 0 10px;
            }

                .usernav ul li
                {
                    position: relative;
                    padding: 8px;
                    font-size: 1.1em;
                    color: #757575;
                    border-bottom: 1px solid #ebebeb;
                }

                    .usernav ul li:last-child
                    {
                        border-bottom: none;
                    }

                    .usernav ul li i
                    {
                        color: #ababab;
                        position: absolute;
                        top: 50%;
                        margin-top: -7px;
                        right: 10px;
                    }

        .userinfo .copyright
        {
            text-align: center;
            color: #808080;
            position: relative;
        }



        .copyright
        {
            margin-bottom: 20px;
        }

        .backbtn
        {
            position: absolute;
            font-size: 1.4em;
            color: #b1afaf;
            left: 0;
            display: none;
            padding: 0 20px;
        }

        .viewout
        {
            transform: translate3d(-100%,0,0);
            -webkit-transform: translate3d(-100%,0,0);
            -webkit-transform: translate(-100%,0,0);
        }

        /*loader css*/
        .mask
        {
            color: #fff;
            position: absolute;
            top: 0;
            bottom: 0;
            left: 0;
            right: 0;
            z-index: 1000;
            font-size: 1.1em;
            text-align: center;
            display: none;
            background-color: rgba(0,0,0,0.3);
        }

        .loader
        {
            position: absolute;
            top: 50%;
            left: 50%;
            margin-top: -43px;
            margin-left: -61px;
            background-color: rgba(39, 43, 46, 0.9);
            padding: 15px 25px;
            border-radius: 5px;
        }

        #loadtext
        {
            margin-top: 5px;
            font-weight: bold;
        }

        .area-select
        {
            text-align: center;
            box-sizing: border-box;
            background-color: #2F1D0F;
            box-shadow: 0 1px 5px gray;
            color: #BFAEA6;
            text-shadow: 0 -1px 1px #335166;
            border: 1px solid #8f8f8f;
            height: 40px;
            line-height: 40px;
            font-size: 1.2em;
            float: left;
            width: 25%;
            cursor: pointer;
        }

        .search
        {
            height: 44px;
            margin-top: 40px;
            position: relative;
            z-index: 201;
            background-color: #f0f0f0;
            padding: 0 10px;
            text-align: center;
            box-sizing: border-box;
        }



        .mn
        {
            position: absolute;
            top: 0;
            right: 10px;
            height: 78px;
            line-height: 78px;
            float: right;
        }

        .mnums
        {
            color: #fff;
            font-weight: bold;
            padding: 2px 6px;
            background-color: #d9534f;
            border-radius: 6px;
            text-align: center;
        }

        .userinfo
        {
            top: 0;
            z-index: 2000;
            width: 100%;
            height: 100%;
            padding: 0;
            margin: 0;
        }

        .current-month-selected
        {
            position: fixed;
            left: 10px;
            top: 200px;
            font-size: 3em;
            opacity: 0.4;
            z-index: 960;
        }

        .last-month-selected
        {
            position: fixed;
            right: 10px;
            top: 200px;
            font-size: 3em;
            opacity: 0.4;
            z-index: 960;
        }

        .undo-month-selected
        {
            display: none;
        }

        /*.unActive
        {
            -webkit-transition: -webkit-transform .4s cubic-bezier(.4,.01,.165,.99);
            transition: transform .4s cubic-bezier(.4,.01,.165,.99);
            transform: translate3d(-100%, 0, 0);
            -webkit-transform: translate3d(-100%, 0, 0);
        }*/

        .Active
        {
            -webkit-transition: -webkit-transform .4s cubic-bezier(.4,.01,.165,.99);
            transition: transform .4s cubic-bezier(.4,.01,.165,.99);
            transform: translate3d(0, 0, 0);
            -webkit-transform: translate3d(0, 0, 0); 
        }

        .areaSelected
        {
            color:#fff;
            background-image:url('../../res/img/StoreSaler/long0.jpg');
            background-repeat:no-repeat; 
            background-position:center;
            background-size:40%;
        }


        .userzje
        {
            position: absolute;
            right: 30px;
            width: 100px;
            text-align: right;
            top: 10px;
            color: #c6a300;
        }
        .area-display
        {
            margin-top:40px;   
            height:50px;
            width:100%;
            text-align:center;
            vertical-align:middle;
            
        }
            .area-display>span
            {
                height:50px;
                line-height:50px; 
            }


        .hideMonth
        {
            display:none;
        }
        
        .premark
        { 
            display: block;            
            overflow: hidden;
            white-space: nowrap;
            text-overflow: ellipsis;
        }
        
        .long
        {
            width:150px; position:fixed; top:100px; z-index:0;
            -webkit-animation:long 2s infinite 0.9s ease-in-out alternate;
            animation:long 2s infinite 0.9s ease-in-out alternate
        }
        
        @-webkit-keyframes long{   /*透明度由0到1*/  
            0%{  
                opacity:0.1;                /*透明度为0*/  
            }  
            100%{  
                opacity:1;              /*透明度为1*/  
            }  
        }  
        @keyframes long{   /*透明度由0到1*/  
            0%{  
                opacity:0.1;                /*透明度为0*/  
            }  
            100%{  
                opacity:1;              /*透明度为1*/  
            }  
        }  
         
    </style>
</asp:Content>
<asp:Content ID="Content2" ContentPlaceHolderID="ContentPlaceHolder1" runat="server">

    <img class="long" style="left:0;" alt="" src="../../res/img/StoreSaler/long1.png" />
    <img class="long" style="right:0;" alt="" src="../../res/img/StoreSaler/long2.png" />


    <div class="header">
        <div>
        <div class="area-select areaSelected" onclick="changeArea('shop')" id="shop">本 店</div>
        <div class="area-select" onclick="changeArea('area')" id="area">区 域</div>
        <div class="area-select" onclick="changeArea('province')" id="province">全 省</div>
        <div class="area-select" onclick="changeArea('all')" id="all">全 国</div>
        </div>
        
    </div>
    <div class="container" style="filter:alpha(opacity=90); -moz-opacity:0.90; opacity:0.90;">
        <div class="area-display">
            <span id="lookCurrent" style="display:none; font-weight:700;" onclick="getMyRank(0);">《查看本月</span>&nbsp; &nbsp; 您正在查看.<span id="spanMonthName" style="color:#cc1111">本月</span>.<span id="spanRankName" style="color:#cc2222">本店</span>.琅琊榜 
            &nbsp; &nbsp; <span id="lookLast" style="display:none; font-weight:700;" onclick="getMyRank(1);">查看上月》</span>
        </div>
        <div class="viplist">

            <ul class="vipul Active" id="shop0">
                正在加载本店排行... 请稍候...
            </ul>

            <ul class="vipul" id="shop1">
                正在加载本店上月排行.. 请稍候...
            </ul>

            <ul class="vipul" id="area0">
                正在加载区域排行... 请稍候...
            </ul>

            <ul class="vipul" id="area1">
                正在加载区域上月排行... 请稍候...
            </ul>

            <ul class="vipul" id="province0">
                正在加载全省排行... 请稍候...
            </ul>

            <ul class="vipul" id="province1">
                正在加载全省上月排行... 请稍候...
            </ul>
            
            <ul class="vipul" id="all0">
                正在加载全国排行... 请稍候...
            </ul>

            <ul class="vipul" id="all1">
                正在加载全国上月排行... 请稍候...
            </ul>

        </div>
    </div>

 
    <!--用户信息webview-->

    <!--用户信息End-->
    <div class="bottomnav">
        <ul class="navul">
            <li>
                <p style=" font-weight:700;">我的排名</p>
            </li>
            <li>
                <p id="pMyOrder">?</p>
            </li>
            <li>
                <p id="pMyZje" style="">?</p>
            </li>
            <li>
                <p id="pMyRemark" style=" display:none" onclick="SetRemark();">设置分享</p>
            </li>
        </ul>
    </div> 

<script type="text/html" id="setRemark">
    <div class="page" style="z-index:8899;">
        <div class="hd">
            <h1 class="page_title">分享心得体会</h1>
        </div>
        <div class="weui_msg"> 
            <div class="weui_cells_title">分享您心得体会</div>
            <div class="weui_cells weui_cells_form">
                <div class="weui_cell">
                    <div class="weui_cell_bd weui_cell_primary">
                        <textarea id="txtRemarkInfo" class="weui_textarea" placeholder="请输入心得体会(限100个字)" rows="3"></textarea>
                        <div class="weui_textarea_counter"><span>0</span>/100</div>
                    </div>
                </div>
            </div>
            <div class="weui_opr_area">
                <p class="weui_btn_area">
                    <a href="javascript:SaveRemark();" class="weui_btn weui_btn_primary">确定</a>
                    <a href="javascript:CloseRemark();" class="weui_btn weui_btn_default">取消</a>
                </p>
            </div> 
        </div>
    </div>
</script>
<script type="text/html" id="showRemark">
    <div class="page" style="z-index:8899;">
        <div class="hd">
            <h1 class="page_title">Ta的心得体会</h1>
        </div>
        
        <div class="weui_cells_title"><span id="showRemarkCname">Ta</span>的业绩</div>
        <div class="weui_cell">
            <div class="weui_cell_bd weui_cell_primary">
                <p id="showYj" style="font-size:24px">123万</p>
            </div>
        </div> 
        <div  id="gotoSaleHonor" class="weui_cells weui_cells_access" style="display:none"> 
            <a class="weui_cell" href="javascript:;">
                <div class="weui_cell_hd"><img src="data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAAC4AAAAuCAMAAABgZ9sFAAAAVFBMVEXx8fHMzMzr6+vn5+fv7+/t7e3d3d2+vr7W1tbHx8eysrKdnZ3p6enk5OTR0dG7u7u3t7ejo6PY2Njh4eHf39/T09PExMSvr6+goKCqqqqnp6e4uLgcLY/OAAAAnklEQVRIx+3RSRLDIAxE0QYhAbGZPNu5/z0zrXHiqiz5W72FqhqtVuuXAl3iOV7iPV/iSsAqZa9BS7YOmMXnNNX4TWGxRMn3R6SxRNgy0bzXOW8EBO8SAClsPdB3psqlvG+Lw7ONXg/pTld52BjgSSkA3PV2OOemjIDcZQWgVvONw60q7sIpR38EnHPSMDQ4MjDjLPozhAkGrVbr/z0ANjAF4AcbXmYAAAAASUVORK5CYII=" alt="" style="width:20px;margin-right:5px;display:block"></div>
                <div class="weui_cell_bd weui_cell_primary">
                    <p>个人传记</p>
                </div>
                <div class="weui_cell_ft">立刻查看</div>
            </a> 
        </div>
        <div class="weui_msg"> 
            <div class="weui_cells_title">Ta分享的心得体会如下</div>
            <div class="weui_cells weui_cells_form">
                <div class="weui_cell">
                    <div class="weui_cell_bd weui_cell_primary">
                        <textarea id="showRemarkInfo" class="weui_textarea" placeholder="" rows="3" readonly="readonly"></textarea> 
                    </div>
                </div>
            </div>
            <div class="weui_opr_area">
                <p class="weui_btn_area"> 
                    <a href="javascript:CloseRemark();" class="weui_btn weui_btn_default">返回</a>
                </p>
            </div> 
        </div>
    </div>
</script>

    <script type="text/javascript" src="../../res/js/jquery.js"></script>
    <script type='text/javascript' src='../../res/js/StoreSaler/fastclick.min.js'></script>
    <script type='text/javascript' src='../../res/js/StoreSaler/jsHashTable.js'></script> 
    <script type="text/javascript">

        var NowRankID = "";
        var NowRankName = "";
        var NowMonth = "";
        var htMyInfo = new HashTable();
                
        window.onload = function () {        
            changeArea("shop");
        }

        //保存并显示我的排名信息
        function SaveAndShowMyInfo(myKey, data) {
            if (SaveMyOrderInfo(myKey, data)) {
                ShowMyInfo(myKey);
            }
        }

        //保存排名信息
        function SaveMyOrderInfo(myKey, data) {
            if (data.MyOrder != undefined) {
                var myData = data.MyOrder + "|" + GetWan(data.MyZje) + "元";
                htMyInfo.add(myKey, myData);

                return true;
            } else {
                return false;
            }
        }

        //显示排名信息
        function ShowMyInfo(myKey) {
            var myInfo = htMyInfo.getValue(myKey);
            if (myInfo != null) {
                myInfo = myInfo.split("|");

                $("#pMyOrder").html("№" + myInfo[0]);
                $("#pMyZje").html(myInfo[1]);

                GetPRemarkVisible();

                return true;
            }else{
                return false;
            }
        }

        function GetPRemarkVisible() {
            var premarkClass = "Remark<%= ryid %>_" + NowMonth;

            if (NowRankID == "shop" || $("." + premarkClass).length == 0) {
                $("#pMyRemark").fadeOut(200);
            } else {
                $("#pMyRemark").fadeIn(200);
            }
        }

        function SetRemark() {
            OpenPage("setRemark");
            
            var premarkClass = "Remark<%= ryid %>_" + NowMonth;
            if ($("." + premarkClass).length > 0) {
                $("#txtRemarkInfo").val($("." + premarkClass).html());
            }
        }

        function ShowRemark(sender, cname, yj, LinkTitle, IconUrl, PageUrl) {
            OpenPage("showRemark");       

            $("#showRemarkCname").html(cname);
            $("#showYj").html(yj);

            var s = $(sender);
            var remarkinfo = s.children("p").html();
            $("#showRemarkInfo").html(remarkinfo);

            ShowLoading("正在加载..", 0.8);
            setTimeout(function () {
                if (LinkTitle == "") {
                    $("#gotoSaleHonor").fadeOut();
                } else {
                    $("#gotoSaleHonor>a").attr("href", PageUrl);
                    $("#gotoSaleHonor>a>div>p").html(LinkTitle);
                    $("#gotoSaleHonor>a>div>img").attr("src", IconUrl);
                    $("#gotoSaleHonor").fadeIn();
                }
            }, 500);
        }
        function CloseRemark() {
            $("#gotoSaleHonor").fadeOut();
            window.history.back(); 
        } 

        function getMyRank(datamonth) {
            changeArea(NowRankID, datamonth); 
        }

        function getRank(divname, rankname, datamonth) { 

            NowRankID = divname;
            NowRankName = rankname;
            NowMonth = datamonth;
            //设置显示内容 
            $("#spanRankName").html(rankname);
            if (datamonth == "0") {
                $("#lookLast").css("display", "inline");                
                $("#lookCurrent").css("display", "none");
                $("#spanMonthName").html("本月");
            } else {
                $("#lookLast").css("display", "none");
                $("#lookCurrent").css("display", "inline");
                $("#spanMonthName").html("上月");
            } 
             
            if (ShowMyInfo(divname + datamonth) == true) { //如果能成功显示我的排名，则不继续查询数据
                $("#" + divname + rankname).css("opacity", 1);
                return;   
            }

            var rankhtml = "";
            rankhtml = "";

            var timestamp = Date.parse(new Date());

            var mdid = "<%= mdid %>";
            var ryid = "<%= ryid %>";
                         
            ShowLoading("正在加载..");
            $.ajax({
                type: "POST",
                timeout: 15000,
                datatype: "html",
                url: "ShopRankCore.aspx",
                data: { "ctrl": "getRank", "ryid": ryid, "mdid": mdid, "datatype": divname, "datamonth": datamonth, "ref": timestamp },
                cache: false,
                contentType: "application/x-www-form-urlencoded; charset=utf-8",
                success: function (data) {
                    HideLoading();
                     
                    data = JSON.parse(data);
                    var len = data.rows.length;

                    SaveAndShowMyInfo(divname + datamonth, data);   //保存并显示我的排名

                    if (len > 0) {

                        var premarkClass = "";      //用于判断我的心得
                        var myyj;
                        for (var i = 0; i < len; i++) {
                            var row = data.rows[i];
                            myyj = GetWan(row.zje) + "元";

                            row.myremark = ReplaceJson(row.myremark);

                            rankhtml += "<li onclick=\"ShowRemark(this,'" + row.yyy + "','" + myyj + "','" + row.LinkTitle + "','" + row.IconUrl + "','" + row.PageUrl + "');\">"
                                           + "<div class='userimg'>"
                                           + "  <img src='" + row.faceimg + "' alt='' />";

                            if (i < 3) {
                                rankhtml += "<div class='rankicon'>"
                              + "<img src='../../res/img/StoreSaler/gold" + i.toString() + ".png' />"
                            + "</div>";
                            }

                            if (divname == "shop") premarkClass = "";           //只显示本店时，不出现心得
                            else premarkClass = "Remark" + row.ryid + "_" + datamonth;

                            rankhtml += "</div>"
                                           + "<h3>" + "№" + (i + 1).toString() + " " + row.yyy + "</h3><span class='userzje'>" + myyj + "</span>"
                                           + "<p class='premark " + premarkClass + "'>" + row.myremark + "</p>"
                                       + "</li>      ";
                        }
                        $("#" + divname + datamonth).html(rankhtml);

                        var obj = $("#" + divname + datamonth).children();

                        $(obj).fadeInWithDelay();

                        GetPRemarkVisible();
                    } else {
                        $("#" + divname + datamonth).html("<li>-暂时没有数据-</li>");
                    }
                },
                error: function (XMLHttpRequest, textStatus, errorThrown) {
                    HideLoading();
                    if (errorThrown.toString() != "") {     //如果没有错误，则不输出（AJAX调用期间，页面被关掉，也会出此错误；但错误内容为空）
                        alert(errorThrown);
                    }
                }
            });
        }

        function ReplaceJson(data) {
            data = data.replace(/\\r/g, "\r");
            data = data.replace(/\\n/g, "\n");
            return data;
        }

        function SaveRemark() { 
            var ryid = "<%= ryid %>";
            var remark = $("#txtRemarkInfo").val();
              
            var timestamp = Date.parse(new Date());
            
            ShowLoading("设置中...");
            $.ajax({
                type: "POST",
                timeout: 15000,
                datatype: "html",
                url: "ShopRankCore.aspx",
                data: { "ctrl": "saveRemark", "ryid": ryid, "datamonth": NowMonth, "remark": remark, "ref": timestamp },
                cache: false, 
                contentType: "application/x-www-form-urlencoded; charset=utf-8", 
                success: function (data) {
                    HideLoading();

                    if (data == "Successed") {
                        ShowInfo("设置成功！");

                        setTimeout(function () {
                            CloseRemark();

                            var premarkClass = "Remark<%= ryid %>_" + NowMonth;
                            if ($("." + premarkClass).length > 0) {
                                $("." + premarkClass).html(remark);
                            }
                        }, 1000);
                    } else {
                        ShowInfo(data);
                    }
                },
                error: function (XMLHttpRequest, textStatus, errorThrown) {
                    HideLoading();
                    if (errorThrown.toString() != "") {     //如果没有错误，则不输出（AJAX调用期间，页面被关掉，也会出此错误；但错误内容为空）
                        alert(errorThrown);
                    }
                }
            });
        }

        
        function GetWan(y) {
            var rt;
            if (isNaN(y)) {
                rt = y;
            }else{
                var vvv = parseInt(y) * 0.0001;
                if (vvv < 10){
                    rt = y;
                }else{
                    vvv = parseInt(vvv);
                    rt = vvv.toString() + "万";
                }
            }

            return rt;
        }

           
        $(".area-display").click(function () {
            var area = $(".header .areaSelected").attr("id");
            //alert(area);

        });

        function changeArea(objid, datamonth) { 
            if (datamonth == undefined) {
                datamonth = "0";
            } 

            $(".header .areaSelected").removeClass("areaSelected");
            $("#" + objid).addClass("areaSelected"); 
            switch (objid) {
                case "shop":
                    $(".Active").removeClass("Active");
                    $("#" + objid + datamonth).addClass("Active"); 
                    getRank(objid, "本店", datamonth); 
                    break;
                case "area":
                    $(".Active").removeClass("Active");
                    $("#" + objid + datamonth).addClass("Active");
                    getRank(objid, "区域", datamonth); 
                    break;
                case "province":
                    $(".Active").removeClass("Active");
                    $("#" + objid + datamonth).addClass("Active");
                    getRank(objid, "全省", datamonth); 
                    break;
                case "all":
                    $(".Active").removeClass("Active");
                    $("#" + objid + datamonth).addClass("Active");
                    getRank(objid, "全国", datamonth);
                    break;
                default:
                    break;

            } 
        }
         

        $(function () {
            FastClick.attach(document.body);
            var obj = $(".vipul").children();
            $(obj).fadeInWithDelay();
        });
         


        $(".backbtn").click(function () {
            if (tagsShow)
                showtags();
            $(".tags").fadeOut(500);
            $(".backbtn").fadeOut(500);
            $(".userinfo").removeClass("showinfo");
            $(".vipul").removeClass("viewout");
        });





        //function showLoader(type, txt) {
        //    switch (type) {
        //        case "loading":
        //            $(".mask .fa").removeAttr("class").addClass("fa fa-2x fa-spinner fa-pulse");
        //            $("#loadtext").text(txt);
        //            $(".mask").show();
        //            break;
        //        case "successed":
        //            $(".mask .fa").removeAttr("class").addClass("fa fa-2x fa-check");
        //            $("#loadtext").text(txt);
        //            $(".mask").show();
        //            break;
        //        case "error":
        //            $(".mask .fa").removeAttr("class").addClass("fa fa-2x fa-close (alias)");
        //            $("#loadtext").text(txt);
        //            $(".mask").show();
        //            break;
        //        case "warn":
        //            $(".mask .fa").removeAttr("class").addClass("fa fa-2x fa-warning (alias)");
        //            $("#loadtext").text(txt);
        //            $(".mask").show();
        //            break;
        //    }
        //}



        $.fn.fadeInWithDelay = function () {
            var delay = 0;
            return this.each(function () {
                $(this).delay(delay).animate({ opacity: 1 }, 200);
                delay += 100;
            });
        };
    </script>
</asp:Content>
