<%@ Page Language="C#" Debug="true" %>
<%@ Import Namespace="nrWebClass" %>
<%@ Import Namespace="System.Data" %>
<%@ Import Namespace="System.Data.SqlClient" %>
<%@ Import Namespace="System.Collections.Generic" %>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<script runat="server">
    string DBConStr = System.Configuration.ConfigurationManager.ConnectionStrings["Conn_4"].ConnectionString;
    string MyOFBList;
    private const string ConfigKeyValue = "5";	//微信配置信息索引值 
    public List<string> wxConfig;       //微信OPEN_JS 动态生成的调用参数
    string vipWXid = "0";
    protected void Page_Load(object sender, EventArgs e)
    {
        string errInfo, mySql;
        List<SqlParameter> para = new List<SqlParameter>();
        DataTable dt;
        if (clsWXHelper.CheckUserAuth(ConfigKeyValue, "openid"))
        {
            mySql = "select * from wx_t_vipBinging where wxOpenid=@wxOpenid ";
            para.Add(new SqlParameter("@wxOpenid", Convert.ToString(Session["openid"])));
            using (LiLanzDALForXLM dal = new LiLanzDALForXLM(DBConStr))
            {
                errInfo = dal.ExecuteQuerySecurity(mySql, para, out dt);
            }
           
            if (errInfo != "")
            {
                clsSharedHelper.WriteInfo("查询用户出错！"+errInfo);
                return;
            }
            else if (dt.Rows.Count < 1)
            {
                clsSharedHelper.WriteInfo("未找到用户！");
                return;
            }
            else
            {
                vipWXid =Convert.ToString(dt.Rows[0]["id"]);
                dt.Clear();
                dt.Dispose();
            }   
        }
        else
        {
            clsSharedHelper.WriteInfo("鉴权失败");
            return;
        }

        clsJsonHelper json = new clsJsonHelper();
        mySql = @"select top 10 a.id,REPLACE(REPLACE(a.OFBContent,CHAR(10),''),CHAR(13),'') OFBContent,a.LikeNum,a.OFBGroupID,a.CreateTime,a.CreateName,a.CreateCustomerID,a.IsDel,a.mdid,a.ProposalType, isnull(b.wxHeadimgurl,'') headImg  from wx_t_OpinionFeedback a inner join wx_t_vipBinging b on a.CreateCustomerID=b.ID and b.id=@vipWXid
                            where a.OFBGroupID=4 and a.IsDel=0  order by a.id desc";
        para.Clear();
        para.Add(new SqlParameter("@vipWXid", vipWXid));
      
        DataTable dt_ZB;
        DataTable dt_MX = new DataTable();

        using (LiLanzDALForXLM dal = new LiLanzDALForXLM(DBConStr))
        {
            errInfo = dal.ExecuteQuerySecurity(mySql, para, out dt_ZB);

            if (errInfo == "")
            {
                mySql = "select top 50 b.parentID,c.* from wx_t_OpinionFeedback a inner join wx_t_vipBinging u on a.CreateCustomerID=u.id and u.id=@vipWXid inner join wx_t_ResRelate b on a.id=b.parentid and a.OFBGroupID=4 inner join  wx_t_uploadfile c on b.ResID=c.id ";
                para.Clear();
                para.Add(new SqlParameter("@vipWXid", vipWXid));
                errInfo = dal.ExecuteQuerySecurity(mySql, para, out dt_MX);
            }
            else
            {
                errInfo = "查询主表出错" + errInfo;
            }
        }

        json.AddJsonVar("rows", Convert.ToString(dt_ZB.Rows.Count));
        if (errInfo == "" && dt_ZB.Rows.Count > 0)
        {
            json.AddJsonVar("minMyID", Convert.ToString(dt_ZB.Rows[dt_ZB.Rows.Count - 1]["ID"]));
            clsJsonHelper OFBJson = new clsJsonHelper();
            clsJsonHelper DetailJson = new clsJsonHelper();
            DataRow[] rows;
            string DetailStr, OFJStr = "";
            for (int i = 0; i < dt_ZB.Rows.Count; i++)
            {
                OFBJson.AddJsonVar("headImg", Convert.ToString(dt_ZB.Rows[i]["headImg"]));
                OFBJson.AddJsonVar("name", Convert.ToString(dt_ZB.Rows[i]["CreateName"]).Replace(".","").Replace("\"",""));
                OFBJson.AddJsonVar("time", Convert.ToString(dt_ZB.Rows[i]["CreateTime"]));
                OFBJson.AddJsonVar("OFBContent", Convert.ToString(dt_ZB.Rows[i]["OFBContent"]).Replace(".", "").Replace("\"", ""));
                OFBJson.AddJsonVar("LikeNum", Convert.ToString(dt_ZB.Rows[i]["LikeNum"]));
                OFBJson.AddJsonVar("ID", Convert.ToString(dt_ZB.Rows[i]["ID"]));
                OFBJson.AddJsonVar("ProposalType", Convert.ToString(dt_ZB.Rows[i]["ProposalType"]));
                rows = dt_MX.Select("parentID=" + Convert.ToString(dt_ZB.Rows[i]["ID"]));
                OFBJson.AddJsonVar("PictureNum", Convert.ToString(rows.Length));
                DetailStr = "[";
                for (int j = 0; j < rows.Length - 1; j++)
                {
                    DetailJson.AddJsonVar("URLAddress", Convert.ToString(rows[j]["URLAddress"]));
                    DetailJson.AddJsonVar("ThumbnailURL", Convert.ToString(rows[j]["ThumbnailURL"]));
                    DetailJson.AddJsonVar("FileName", Convert.ToString(rows[j]["FileName"]));
                    DetailStr = string.Concat(DetailStr, DetailJson.jSon, ",");
                }

                if (rows.Length >= 1)
                {
                    DetailJson.AddJsonVar("URLAddress", Convert.ToString(rows[rows.Length - 1]["URLAddress"]));
                    DetailJson.AddJsonVar("ThumbnailURL", Convert.ToString(rows[rows.Length - 1]["ThumbnailURL"]));
                    DetailJson.AddJsonVar("FileName", Convert.ToString(rows[rows.Length - 1]["FileName"]));
                    DetailStr = string.Concat(DetailStr, DetailJson.jSon, "]");
                    OFBJson.AddJsonVar("PictureList", DetailStr, false);
                }
                else
                {
                    DetailStr = "";
                    OFBJson.AddJsonVar("PictureList", DetailStr);
                }
                OFJStr = string.Concat(OFJStr, OFBJson.jSon, ",");
            }
            OFJStr = OFJStr.TrimEnd(',');
            json.AddJsonVar("rows", string.Concat("[", OFJStr, "]"), false);
            json.AddJsonVar("length", Convert.ToString(dt_ZB.Rows.Count));
            json.AddJsonVar("BackURL", clsConfig.GetConfigValue("VIP_WebPath"));
        }
        else
        {
            MyOFBList = errInfo;
        }
        MyOFBList = json.jSon;
        json = null;
        wxConfig = clsWXHelper.GetJsApiConfig(ConfigKeyValue); 
    }
   
</script>
<html xmlns="http://www.w3.org/1999/xhtml">
<head id="Head1" runat="server">
    <meta name="viewport" content="width=device-width,initial-scale=1,user-scalable=0" /> 
    <meta http-equiv="Content-Type" content="text/html; charset=utf-8" />
    <title></title>
    <link rel="stylesheet" href="../../res/css/weui.min.css"/>
    <link rel="stylesheet" href="../../res/css/StoreSaler/weui_example.css"/>
    <script type="text/javascript" src="../../res/js/zepto.min.js"></script>  

    <link type="text/css" rel="stylesheet" href="../../res/css/font-awesome.min.css" />
    <link type="text/css" rel="stylesheet" href="../../res/css/LeePageSlider.css" />
    <link type="text/css" rel="stylesheet" href="../../res/css/StoreSaler/OFBPage.css" />
    <script src="../../res/js/jquery.js" type="text/javascript"></script>
    <script src="../../res/js/StoreSaler/LocalResizeIMG.js" type="text/javascript"></script>
    <script src="../../res/js/StoreSaler/mobileBUGFix.mini.js" type="text/javascript"></script>
    <script src="../../res/js/StoreSaler/binaryajax.min.js" type="text/javascript"></script>
    <script src="../../res/js/StoreSaler/exif.min.js" type="text/javascript"></script>
    <script src="../../res/js/jweixin-1.0.0.js" type="text/javascript"></script>
    <script src="../../res/js/StoreSaler/fastclick.min.js" type="text/javascript"></script>

</head>
<body>
    <form id="form1" runat="server">
    <header class="header">
        <i class="fa fa-angle-left" id="backbtn" onclick="GoBack()"> </i><span id="GroupName">顾客心声</span>
        <span id="rightBtn"> <i onclick="addItem()" class="fa fa-plus "></i></span>
    </header>
    <div id="main" class="wrap-page">
        <!--主页-->
        <section class="page page-not-header" id="page-main">
            <div class="container">
              <div class="lmdiv">
                <a href="javascript:;" id="loadmore_btn">- 加载更多 -</a>
              </div>
            </div>
        </section>
        <!--详情页-->
        <section class="page page-not-header page-right" id="detail-page" style="z-index: 0;">
            <div class="detail_container">
               <div id="detail_head"></div>
                <ul class="picul">
                </ul>
                <div class="detail_content">
                </div>
                <div class="navs">
                    <a  href="javascript:ToComment()";> <i class="fa fa-comment-o" "></i>评论</a>
                    <a  href="javascript:ToThumbs()";> <i class="fa fa-thumbs-o-up"></i><span id="cancelThumbs">取消</span>点赞</a>
                </div>
                <div class="heartNames"><i class="fa fa-heart-o"></i><span id="heartNames"></span></div>
                <div class="comments">
                    <p class="comtitle"><span>评论列表 | </span><span id="commentsCount"> 0</span></p>
                    <div class="comms">
                    </div>
                </div>
            </div>
               <input type="hidden" id="comCountsVal" value="0" />
               <input type="hidden" id="likeNums" value="0" />
               <input type="hidden" id="IsThumbs" value="0" />
        </section>
        <!--编辑页-->
        <section class="page page-not-header page-top" id="edit-page" style="z-index: 0;">
          <div class="edit_container">
            <p class="title">
                添加关联商品</p>
            <div class="chopics">
                <ul class="pics">
                    <li onclick="ScanAddRelated()">扫码添加+</li>
                    <li onclick="InputAddRelated()">输入添加+</li>
                </ul>
            </div>
            <div class="content">
                <textarea id="content" rows="12" placeholder="在这里写点东西吧....."></textarea>
                <ul class="pics2 floatfix">
                    <li class="chobtn" onclick="chooseFile()">
                        <img src="../../res/img/vipweixin/cameraicon.jpg" />
                    </li>
                </ul>
            </div>
            <input type="file" id="choosefile" />
        </div>
        </section>
        <input type="hidden" id="minMyID" value="0" />
        <input type="hidden" id="OFBGroupID" value="" />
        <input type="hidden" id="MyDjID" value="0" />
    </div>
    <div class="cominput">
        <input id="comText" type="text" placeholder="我也说两句" />
        <div class="subbtn" onclick="submitCom()">
            提 交</div>
    </div>
    <div class="inputBackground" onclick="otherClick()">
        <div class="inputRelateDiv">
            <input type="text" class="inputRelateInput" id="MyText" />
            <div class="submitBtn" onclick="ToSearchRelate()">
                查 找</div>
        </div>
    </div>
   <!--BEGIN dialog1-->
    <div class="weui_dialog_confirm" id="dialog1" style="display: none;">
        <div class="weui_mask">
        </div>
        <div class="weui_dialog">
            <div class="weui_dialog_hd">
                <strong class="weui_dialog_title">弹窗标题</strong></div>
            <div class="weui_dialog_bd">
                自定义弹窗内容<br>
                ...</div>
            <div class="weui_dialog_ft">
                <a href="javascript:;" id="dialog_default" class="weui_btn_dialog default">取消</a>
                <a href="javascript:;" id="dialog_primary" class="weui_btn_dialog primary">确定</a>
            </div>
        </div>
    </div>
    <!--END dialog1-->
     <!--BEGIN dialog2-->
    <div class="weui_dialog_alert" id="dialog2" style="display: none;">
        <div class="weui_mask">
        </div>
        <div class="weui_dialog">
            <div class="weui_dialog_hd">
                <strong class="weui_dialog_title">弹窗标题</strong></div>
            <div class="weui_dialog_bd">
                弹窗内容，告知当前页面信息等</div>
            <div class="weui_dialog_ft">
                <a href="javascript:dialog_default(2);" class="weui_btn_dialog primary">确定</a>
            </div>
        </div>
    </div>
    <!--END dialog2-->
    <!--BEGIN toast-->
    <div id="toast" style="display: none; position:fixed;z-index:99999">
        <div class="weui_mask_transparent"></div>
        <div class="weui_toast">
            <i class="weui_icon_toast"></i>
            <p class="weui_toast_content" id="MsgInfo">已完成</p>
        </div>
    </div>
    <!--end toast-->
    <!-- loading toast -->
    <div id="loadingToast" class="weui_loading_toast" style="display:none; position:fixed; z-index:99999">
        <div class="weui_mask_transparent"></div>
        <div class="weui_toast">
            <div class="weui_loading">
                <div class="weui_loading_leaf weui_loading_leaf_0"></div>
                <div class="weui_loading_leaf weui_loading_leaf_1"></div>
                <div class="weui_loading_leaf weui_loading_leaf_2"></div>
                <div class="weui_loading_leaf weui_loading_leaf_3"></div>
                <div class="weui_loading_leaf weui_loading_leaf_4"></div>
                <div class="weui_loading_leaf weui_loading_leaf_5"></div>
                <div class="weui_loading_leaf weui_loading_leaf_6"></div>
                <div class="weui_loading_leaf weui_loading_leaf_7"></div>
                <div class="weui_loading_leaf weui_loading_leaf_8"></div>
                <div class="weui_loading_leaf weui_loading_leaf_9"></div>
                <div class="weui_loading_leaf weui_loading_leaf_10"></div>
                <div class="weui_loading_leaf weui_loading_leaf_11"></div>
            </div>
            <p class="weui_toast_content" id="LoadingInfo">数据加载中</p>
        </div>
    </div>
    <div class="weui_toptips weui_warn js_tooltips"></div>
        <script type="text/javascript">
         var nowPage = "main";
        var imgErr = 0, oRotate = 0;
        var errNums = 0;
        var ImgOK = new Array(); //[0,0,0,0,0,0];//0代表没使用过或者是上传失败的
        var ImgID = new Array();
        var maxImgCount = 5; //最大允许的照片数量
        var NowImgCount = 0;
        var NowImgIndex = 0;   //当前的图片索引
        var PIDs;
        var ew, ew2;
        function AlertInfo(info) {
            $(".weui_dialog_alert .weui_dialog_title").html("提示");
            $(".weui_dialog_alert .weui_dialog_bd").html(info);
            $(".weui_dialog_alert").css("z-index", 100);
            $(".weui_dialog_alert").show();
        }
        function showWarnInfo(Info, showTime) {
            if (showTime == undefined || showTime == "undefined") {
                ShowTime = 2;      //默认弹出2s
            };
            $(".js_tooltips").html(Info);
            $(".js_tooltips").css("z-index", "10000");
            $(".js_tooltips").show();
            setTimeout(function () {
                $(".js_tooltips").hide();
            }, showTime * 1000);
        }

        //显示加载栏目
        function ShowLoading(Info, ShowTime) {
            if (ShowTime == undefined || ShowTime == "undefined") {
                ShowTime = 15;      //默认弹出15s
            };
            $("#LoadingInfo").html(Info);
            var $loadingToast = $('#loadingToast');
            if ($loadingToast.css('display') != 'none') {
                return;
            }

            $loadingToast.show();
            setTimeout(function () {
                $loadingToast.hide();
            }, ShowTime * 1000);
        }
        function HideLoading() {
            $('#loadingToast').hide();
        }
        //弹出提示窗口
        function ShowInfo(Info, ShowTime) {
            if (ShowTime == undefined || ShowTime == "undefined") {
                ShowTime = 2;      //默认弹出2s
            };
            $("#MsgInfo").html(Info);
            var $toast = $('#toast');
            if ($toast.css('display') != 'none') {
                return;
            }

            $toast.show();
            setTimeout(function () {
                $toast.hide();
            }, ShowTime * 1000);
        }
         $(document).ready(function () {
           $(function() {
               FastClick.attach(document.body);
           });
            var t =<%=MyOFBList %> ;
             addToList(t);//添加到列表中

            $("#loadmore_btn").click(function (){
                var maxID=$("#minMyID").val();
                if(maxID=="0"){
                    $("#loadmore_btn").html("- 无更多数据了 -");
                    $(".lmdiv a").css("color","#333");
                    return;
                }
                $.ajax({
                    url: "QualityFeedbackCore.aspx?ctrl=loadList&maxID=" +maxID+"&OFBGroupID=4",
                    type: "POST",
                    dataType: "HTML",
                    timeout: 30000,
                    error: function (XMLHttpRequest, textStatus, errorThrown) {
                        AlertInfo("网络出错"); 
                    },
                    success: function (result) {
                        var myJoson;
                        try{
                            myJoson=stringToJson(result);  
                        }catch(e){
                            $(".lmdiv a").css("color","#333");
                            $("#loadmore_btn").html("- 无更多数据了 -");
                            $("#minMyID").val("0")
                            return;
                        }
                        addToList(myJoson);
                    }
                });
            })
        });
        function stringToJson(stringValue){
            eval("var theJsonValue = " + stringValue);
            return theJsonValue;
        }
         function addToList(t){
            $("#minMyID").val(t.minMyID);
            var MyLenth=t.length;
            if( typeof(MyLenth) == "undefined"){
                    return ;
            }
            var ImgURL=t.BackURL;
            var ID,name,time,content,headimg,ProposalType;
            var ImgArray=new Array();
            var rows=t.rows;
            var MyDiv;
            var ImgStr;
            for(var i=0;i<MyLenth;i++){
                ID=rows[i].ID;       
                name=rows[i].name;
                time=rows[i].time;
                content=rows[i].OFBContent;
                headimg=rows[i].headImg;
                ImgArray=rows[i].PictureList;

                ImgStr="";
                if(rows[i].PictureNum>0){
                    for(var j=0;j<ImgArray.length;j++){
                        ImgStr+=" <li><img src='"+ImgURL+ImgArray[j].ThumbnailURL+ImgArray[j].FileName+"' alt='' /></li>";
                    }
                }
                if(headimg==null || headimg==""){
                    headimg="../../res/img/vipweixin/headimg.png";
                }else if(headimg.indexOf("http://")<0){
                    headimg=ImgURL+headimg;
                }else{
                    headimg=headimg.replace("/0","/64");
                }
                var lmdiv="<div class='listitem' id='Item_#ID#' ><div class='itemhead'><div class='delBtn' onclick='DelMyItem(#ID#)'> <i class='fa fa-trash-o fa-lg'></i></div><div class='userimg'><img src='#HeadImg#' alt='头像' /></div>";
                lmdiv+="<div class='userinfo'><p class='name'>#name#</p><p class='time'>#time#</p></div></div><div class='itembody' onclick='godetail(#ID#)'><div class='itemcontent'><p>#content#</p></div>";
                lmdiv+="<div class='itempics'><ul class='picsul floatfix'>#ImgS# </ul><div class='itemnav'><span><i class='fa  fa-pencil'></i> 回复</span></div></div></div></div>";
                lmdiv=lmdiv.replace(/#ID#/gm,ID);
                lmdiv=lmdiv.replace(/#HeadImg#/gm,headimg);
                lmdiv=lmdiv.replace(/#name#/gm,name);
                lmdiv=lmdiv.replace(/#time#/gm,time);
                lmdiv=lmdiv.replace(/#content#/gm,content);
                lmdiv=lmdiv.replace(/#ImgS#/gm,ImgStr);
                lmdiv=lmdiv.replace(/'/gm,"\"");
               // alert(lmdiv);
                $(".lmdiv").before(lmdiv);
                }
        }
         function GoBack() {
            $("#MyDjID").val("0");
            switch (nowPage) {
                case "main":   
                    window.history.go(-1);
                break;
                case "detail":
                    $("#detail-page").addClass("page-right");
                    $("#page-main").removeClass("page-left");
                    $("#rightBtn").html("<i onclick='addItem()' class='fa fa-plus'></i>");
                    $(".cominput").hide();
                    nowPage="main";
                break;
                case "edit":
                    $("#edit-page").addClass("page-top");
                    $("#page-main").removeClass("page-bot");
                    $("#rightBtn").html("<i onclick='addItem()' class='fa fa-plus'></i>");
                    nowPage="main";
                break;
            }
        }
         function godetail(ID) {
            nowPage = "detail";
            $("#page-main").addClass("page-left");
            $("#detail-page").removeClass("page-right");
            $("#rightBtn").html("");//要改成头像
            if($("#MyDjID").val()==ID){
                return;
            }
            $("#MyDjID").val(ID);
            $.ajax({
                url: "QualityFeedbackCore.aspx?ctrl=GetDetail&ID=" +ID,
                type: "POST",
                dataType: "HTML",
                timeout: 30000,
                error: function (XMLHttpRequest, textStatus, errorThrown) {
                    RedirectErr("服务器出错.");
                },
                success: function (result) {
                    var t=stringToJson(result);
                    $(".picul").empty();
                    $(".detail_content").empty();
                    $(".comms").empty();
                    $("#heartNames").empty();
                    $("#detail_head").empty();
                    setTimeout(loadDetail(t),10);
                }
            });
        }
         function ToComment() {  
            $(".cominput").show();      
            $("#comText").select();
        }
        function loadDetail(t){

            var ImgURL=t.BackURL;
            var ID,name,time,content,headImg;
            var ImgArray=new Array();
            var CommentAry=t.CommentList;
            var heartNameAry=t.likeRecordList;
            var rows=t.rows;
            name=t.name;
            time=t.time;
            headImg=t.headImg;
            $("#comCountsVal").val(t.comCountsVal);
            $("#commentsCount").html(t.comCountsVal);
         
            $("#likeNums").val(t.LikeNum);
            $("#IsThumbs").val(t.isThums);
            if(t.isThums=="1"){
                $("#heartNames").append("<span id='myName'>"+t.myName+"</span>");
            }else{
                $("#cancelThumbs").hide();
            }
            if(t.LikeNum<=0){
                $(".heartNames").hide();
            }

            if(typeof(headImg)=="undefined"){
              headImg="../../res/img/headImg";
            }else if(headImg.indexOf("http://")>=0){
                 headImg=headImg.replace("/0","/64");
             }else{
                 headImg=ImgURL+headImg;
             }
             var itemhead="<div class='itemhead'><div class='userimg'><img src=#headimg# alt='头像' /></div> <div class='userinfo'><p class='name'>#name#</p><p class='time'>#time#</p></div>";
            itemhead=itemhead.replace("#headimg#",headImg);
            itemhead=itemhead.replace("#name#",name);
            itemhead=itemhead.replace("#time#",time);
            $("#detail_head").append(itemhead);

            var MyDiv,ProposalType;
            ImgArray=t.Picture;
            var ImgStr="";
            
            for(var j=0;j<ImgArray.length;j++){
                ImgStr=" <li><img src='"+ImgURL+ImgArray[j].URLAddress+ImgArray[j].FileName+"' alt='' /></li>";
                $(".picul").append(ImgStr); 
            }
            $(".detail_content").append("<p>" +t.OFBContent + "</p>");

            for(var i=0;i<CommentAry.length;i++){
                MyDiv="<div class='commentitem' onclick='ToComment()'><p>"+CommentAry[i].Content+"</p>";
                MyDiv+=" <p><span class='comuser'>"+CommentAry[i].CreateName+"</span>"; 
                MyDiv+="  <span class='comtime'>"+CommentAry[i].CreateTime+"</span></p></div>";
                $(".comms").append(MyDiv);
            }
            for(var i=0;i<heartNameAry.length;i++){
                MyDiv="<span>"+heartNameAry[i].customerName+"</span>";
                $("#heartNames").append(MyDiv);
            }

            if(CommentAry.length==0){
                $(".comtitle").hide();
            }else{
                $(".comtitle").show();
            }
        }

        function addItem() {
            nowPage = "edit";
            $("#page-main").addClass("page-bot");
            $("#edit-page").removeClass("page-top");
            $("#rightBtn").html("<div onclick='MySave()' class='pubbtn'>发 布</div>");
            //初始化编辑页数据
            $("#MyDjID").val("0");
            $(".content ul:last-child li:first-child").nextAll().remove();
            $(".pics li:first-child").next().nextAll().remove();
            $("#content").val("");
            imgErr = 0, oRotate = 0,errNums = 0,NowImgCount = 0;
            ImgOK = new Array(); //[0,0,0,0,0,0];//0代表没使用过或者是上传失败的
            ImgID = new Array();
            NowImgIndex = 0;   //当前的图片索引
            var pageWidth = document.body.offsetWidth - 17;
            ew = (pageWidth - 6) * 0.312;
            wx.config({
                debug: false, // 开启调试模式,调用的所有api的返回值会在客户端alert出来，若要查看传入的参数，可以在pc端打开，参数信息会通过log打出，仅在pc端时才会打印。
                appId: '<%= wxConfig[0] %>', // 必填，企业号的唯一标识，此处填写企业号corpid
                timestamp: '<%= wxConfig[1] %>', // 必填，生成签名的时间戳
                nonceStr: '<%= wxConfig[2] %>', // 必填，生成签名的随机串
                signature: '<%= wxConfig[3] %>',// 必填，签名，见附录1
                jsApiList: ['scanQRCode'] // 必填，需要使用的JS接口列表，所有JS接口列表见附录2
            });
//            wx.ready(function(){
//                alert("签名成功");
//            });
//            wx.error(function(res){
//                alert("签名失败"+res);
//           });
        }
         function DelMyItem(ID){
            $(".weui_dialog_title").html("提示");
            $(".weui_dialog_bd").html("点击确定删除这条消息,取消离开");
            $(".header").css("z-index","3");
            $("#page-main").css("z-index","1");
            $("#dialog1").css("z-index","5");
            $(".weui_mask").css("z-index","4");
            $("#dialog1").show();
            $("#dialog_default").attr("href","javascript:dialog_default(1);"); 
            $("#dialog_primary").attr("href","javascript:dialog_primary("+ID+");"); 
        }
        function dialog_default(val){
            $("#dialog"+val).hide();
        }
        function dialog_primary(ID){
            $("#dialog1").hide();
            $.ajax({
                url: "QualityFeedbackCore.aspx?ctrl=DelMyItem&ID=" +ID,
                type: "POST",
                dataType: "HTML",
                timeout: 30000,
                error: function (XMLHttpRequest, textStatus, errorThrown) {
                    RedirectErr("服务器出错");
                },
                success: function (result) {
                if(result.indexOf("Successed")>=0){
                    $("#Item_"+ID).remove();
                }
                }
            });
        }
        function submitCom() {
            $(".cominput").hide();
            var ComContent=$("#comText").val();
            $("#comText").val("");  
            var MyDjID=$("#MyDjID").val();
            if(ComContent==""){
            return;
            }
            $.ajax({//AJAX提交数据保存
                url: "QualityFeedbackCore.aspx?ctrl=submitComment",
                type: "POST",
                data: { MyDjID: MyDjID,content:ComContent },
                contentType: "application/x-www-form-urlencoded; charset=utf-8",
                timeout: 10000,
                error: function (XMLHttpRequest, textStatus, errorThrown) {
                    RedirectErr("服务器出错");
                },
                success: function (result) {
                    if(result.indexOf("Successed")>=0){
                        var t=result.split('|');
                        var MyCom="<div class='commentitem' onclick='ToComment()'><p>"+ComContent+"</p>";
                        MyCom+=" <p><span class='comuser'>"+t[1]+"</span> ";
                        MyCom+= " <span class='comtime'>"+t[2]+"</span></p></div>";
                        $(".comms").append(MyCom);
                        $(".comtitle").show();
                        $("#comCountsVal").val(Number($("#comCountsVal").val())+1);
                        $("#commentsCount").html(  $("#comCountsVal").val());
                    }else{
                        RedirectErr(result);
                    }
                }
            });
        }
        function ScanAddRelated(){
            wx.scanQRCode({
                needResult: 1, // 默认为0，扫描结果由微信处理，1则直接返回扫描结果，
                scanType: ["barCode"], // 可以指定扫二维码还是一维码，默认二者都有
                success: function (res) {
                    var result = res.resultStr; // 当needResult 为 1 时，扫码返回的结果
                    var t=stringToJson(result);
                    var scan_result=t.scan_code.scan_result.split(",");
                    var sphh= scan_result[1];
                    if(sphh==""){
                        return;
                    }
                    $.ajax({
                        url: "QualityFeedbackCore.aspx?ctrl=addRelate&MyDjID=" + $("#MyDjID").val() + "&sphh=" + sphh + "&OFBGroupID=4",
                        type: "POST",
                        dataType: "HTML",
                        timeout: 30000,
                        error: function (XMLHttpRequest, textStatus, errorThrown) {
                            showWarnInfo("服务器出错",3);
                        },
                        success: function (result) {
                            if(result.indexOf("Successed")>=0){
                                var myResult=result.split('|');
                                if($("#MyDjID").val()=="0"){
                                    $("#MyDjID").val(myResult[1]);
                                }
                                if(myResult[4]=="0"){
                                    var myRelateLi=" <li id='pics_"+myResult[2]+"' onclick='DelRelated("+myResult[2]+")'>"+myResult[3]+"</li>";
                                    $(".pics").append(myRelateLi);
                                }
                            }else{
                                showWarnInfo(result,3);
                            }
                        }
                    });
                }
            });
        }

        function chooseFile() {
            if (NowImgCount >= maxImgCount) {
                showWarnInfo("亲，图片已经太多啦~",3);
                return;
            }
            $("#choosefile").trigger("click");
            $("#choosefile").click();
        }
         //{大对象 有方法有属性} 图片上传
        $("input:file").localResizeIMG({
            width: 500,
            quality: 0.8,
            before: function (that, blob) {
                var filePath = $("#choosefile").val();
                var extStart = filePath.lastIndexOf(".");
                var ext = filePath.substring(extStart, filePath.length).toUpperCase();
                if (ext != ".BMP" && ext != ".PNG" && ext != ".GIF" && ext != ".JPG" && ext != ".JPEG") {
                    AlertInfo("只能上传图片哦~");
                    return false;
                }
                var orientation = 0;
                var imgfile = that.files[0];
                fr = new FileReader;
                fr.readAsBinaryString(imgfile);
                fr.onloadend = function () {
                    var exif = EXIF.readFromBinaryFile(new BinaryFile(this.result));
                    if (exif.Orientation == undefined)
                        oRotate = 0;
                    else
                        oRotate = exif.Orientation;
                };
                ShowLoading("正在压缩..", 10);
                ImgOK[NowImgIndex] = 3; //3代表上传中 this指当前对象
                return true;
            },

            success: function (result) {
                var img = new Image();
                var myTag = NowImgIndex; //局部变量 记录对应图片的状态
                if (NowImgCount >= maxImgCount) {
                    // showts("最多只能上传" + maxImgCount + "张图片！");
                    showWarnInfo("最多只能上传" + maxImgCount + "张图片！", 3);
                    return;
                } //用于限制不能再上传
                NowImgIndex++;
                NowImgCount++;
                img.width = ew;
                img.src = result.base64;
                //  img.onclick = function () { RemoveImg(this) };
                img.myTag = myTag;
                img.id = "pimg_" + myTag;

                $(".content ul:last-child li:last-child").after(" <li id='img_" + myTag + "'> <div class='hh'></div> <div class='delpic'></div>  <div  class='upoka'></div></li>");
                $(".content ul:last-child li:last-child .hh").append(img);
                $(".content ul:last-child li:last-child .upoka").append("上传中..");
                turnIMG(oRotate);
                HideLoading();
                var MyDjID = $("#MyDjID").val();
                $.ajax({
                    url: "QualityFeedbackCore.aspx?ctrl=SaveImgs&rotate=" + oRotate + "&OFBGroupID=4&MyID=" + MyDjID,
                    type: "POST",
                    data: { formFile: result.clearBase64 },
                    dataType: "HTML",
                    timeout: 30000,
                    error: function (XMLHttpRequest, textStatus, errorThrown) {
                        errNums++;
                        showWarnInfo("提示：有" + errNums + "张上传失败,但仍可继续上传！");
                        $("#img_" + myTag + " .upoka").css("background-color", "#F00");
                        $("#img_" + myTag + " .upoka").html("上传失败");
                        ImgOK[myTag] = 0;
                        ImgID[myTag] = "";
                    },
                    success: function (result) {
                        if (result.indexOf("success") > -1) {
                            ImgOK[myTag] = 1; //1代表上传完成
                            ImgID[myTag] = result.split("|")[1];
                            $("#img_" + myTag + " .upoka").html("上传成功");
                            $("#img_" + myTag + " .delpic").html("<img src='../../res/img/vipweixin/closebtn.png' alt=''onclick='deleteMyImg(" + myTag + ")'  />");
                            if ($("#MyDjID").val() == "0") {
                                $("#MyDjID").val(result.split("|")[2]);
                            }
                        } else {
                            //showts(result);
                            AlertInfo(result);
                        }
                    }
                });
            }
        });

        function turnIMG(rotateVal) {
            var Num = 0;
            switch (rotateVal) {
                case 3: Num = 180;
                    break;
                case 5: Num = 90;
                    break;
                case 6: Num = 90;
                    break;
                case 7: Num = 270;
                    break;
                case 8: Num = 270;
                    break;
                default:
                    break;
            }
            $(".content ul:last-child li:last-child .hh img").attr("style", "transform:rotate(" + Num + "deg);transform-origin: 50% 50%;-webkit-transform:rotate(" + Num + "deg);-webkit-transform-origin: 50% 50%;")
        }
         function DelRelated(ID){
            $(".weui_dialog_title").html("提示");
            $(".weui_dialog_bd").html("确定删除关联信息嘛,取消离开");
            $(".header").css("z-index","3");
            $("#dialog1").css("z-index","5");
            $(".weui_mask").css("z-index","4");
            $("#dialog1").show();
            $("#dialog_default").attr("href","javascript:dialog_default(1);"); 
            $("#dialog_primary").attr("href","javascript:GoToDelRelate("+ID+");"); 
        } 
            function GoToDelRelate(ID){
            $("#dialog1").hide();
            $.ajax({
                url: "QualityFeedbackCore.aspx?ctrl=DelRelated&ID=" +ID,
                type: "POST",
                dataType: "HTML",
                timeout: 30000,
                error: function (XMLHttpRequest, textStatus, errorThrown) {
                    showWarnInfo("服务器出错了~",4);
                },
                success: function (result) {
                    if(result.indexOf("Successed")>=0){
                        $("#pics_"+ID).remove();
                    }
                }
            });
        }
        function MySave() {
            var MyDjID = $("#MyDjID").val();
            var content = $("#content").val();
            if (content == "") {
                AlertInfo("亲，内容不能为空哦！");
                return false;
            }
            
        //检查图片是否都上传完毕
            PIDs="";
            for (var i = 0; i < ImgOK.length; i++) {
                if (ImgOK[i] == 3) {
                    showWarnInfo("还有图片还没未上传完成，请等待~",3);
                    return false;
                }else if (ImgOK[i] == 1) {
                    PIDs += ImgID[i]+"|";
                }
            }
            ShowLoading("正在保存",10);
            $(".pubbtn").attr("disabled", "true");
            //AJAX提交数据保存
            $.ajax({
                url: "QualityFeedbackCore.aspx?ctrl=saveConten",
                type: "POST",
                data: { MyDjID: MyDjID, content: content,strPID: PIDs,OFBGroupID:"4" },
                contentType: "application/x-www-form-urlencoded; charset=utf-8",
                timeout: 10000,
                error: function (XMLHttpRequest, textStatus, errorThrown) {
                    $(".pubbtn").attr("disabled", "false");
                    if (XMLHttpRequest.status == 500)
                        showWarnInfo("提示：服务器出错",3);
                    else
                        showWarnInfo("提示：超时，请重试",4);
                },
                success: function (result) {
                    HideLoading();
                    $(".pubbtn").attr("disabled", "false");
                    if (result.indexOf("Successed") >= 0) {
                        $("#MyDjID").val(result.replace("Successed", ""));
                        ShowInfo("保存成功",2);
                        loadNewList( $("#MyDjID").val());
                    } else {
                        showWarnInfo(result,13);
                    }
                }
            });
        }
        function loadNewList(ID){//加载新添加记录到列表
            $.ajax({
                url: "QualityFeedbackCore.aspx?ctrl=loadNewList&MyDjID="+$("#MyDjID").val(),
                type: "POST",
                dataType: "HTML",
                timeout: 30000,
                error: function (XMLHttpRequest, textStatus, errorThrown) {
                    showWarnInfo("服务器出错",3);
                },
                success: function (result) {
                    var t= stringToJson(result);
                    var ImgURL=t.BackURL;
                    var ID,name,time,content,headimg;
                    var ImgArray=new Array();
                    var rows=t.rows;
                    var MyDiv;
                    var ImgStr;
                    for(var i=0;i<t.length;i++){
                        ID=rows[i].ID;
                        name=rows[i].name;
                        time=rows[i].time;
                        content=rows[i].OFBContent;
                        headimg=rows[i].headImg;
                        ImgArray=rows[i].PictureList;
                        ImgStr="";
                        if(rows[i].PictureNum>0){
                            for(var j=0;j<ImgArray.length;j++){
                                ImgStr+=" <li><img src='"+ImgURL+ImgArray[j].ThumbnailURL+ImgArray[j].FileName+"' alt='' /></li>";
                            }
                        }
                        if(headimg==null || headimg==""){
                            headimg="../../res/img/StoreSaler/headimg.jpg";
                        }else if(headimg.indexOf("http://")<0){
                           headimg= ImgURL+headimg;
                        }else{
                           headimg=headimg.replace("/0","/64");
                        }
                        MyDiv="<div class='listitem' id='Item_"+ID+"' >";
                        MyDiv+="<div class='itemhead'><div class='delBtn' onclick='DelMyItem("+ID+")'> <i class='fa fa-trash-o fa-lg'></i></div><div class='userimg'><img src='"+headimg+"' alt='' /></div>";
                        MyDiv+=" <div class='userinfo'><p class='name'>"+name+"</p><p class='time'>"+time+"</p></div></div>";
                        MyDiv+="<div class='itembody' onclick='godetail("+ID+")'><div class='itemcontent'><p>"+content+"</p></div>";
                        MyDiv+="<div class='itempics'><ul class='picsul floatfix'> "+ImgStr+" </ul>";
                        MyDiv+="<div class='itemnav'><span><i class='fa  fa-pencil'></i> 回复</span></div></div></div>";
                        MyDiv.replace("'","\"");
                        $(".container").prepend(MyDiv);
                    }
                    GoBack();
                }
            });
        }
         function InputAddRelated(){
           $(".inputBackground").show();
           $("#MyText").focus();
        }
         function otherClick(){
             $(".inputBackground").hide();
        }
        function ToSearchRelate(){//手输查找货号关联
        var sphh=$("#MyText").val();
        $.ajax({
            url: "QualityFeedbackCore.aspx?ctrl=addRelate&MyDjID=" + $("#MyDjID").val() + "&sphh=" + sphh + "&OFBGroupID=4",
                type: "POST",
                dataType: "HTML",
                timeout: 30000,
                error: function (XMLHttpRequest, textStatus, errorThrown) {
                  showWarnInfo("服务器出错",3);
                },
                success: function (result) {
                   if(result.indexOf("Successed")>=0){
                       $("#MyText").val("");
                       var myResult=result.split('|');
                       if($("#MyDjID").val()=="0"){
                           $("#MyDjID").val(myResult[1]);
                       }
                       if(myResult[4]=="0"){
                           var myRelateLi=" <li id='pics_"+myResult[2]+"' onclick='DelRelated("+myResult[2]+")'>"+myResult[3]+"</li>";
                           $(".pics").append(myRelateLi);
                       }
                   }else{
                      showWarnInfo(result,3);
                   }
                }
            });
        }

         function deleteMyImg(tagNum) {
               $(".weui_dialog_title").html("提示");
               $(".weui_dialog_bd").html("确定删除图片嘛,取消离开");
               $(".header").css("z-index","3");
               $("#dialog1").css("z-index","5");
               $(".weui_mask").css("z-index","4");
               $("#dialog1").show();
               $("#dialog_default").attr("href","javascript:dialog_default(1);"); 
               $("#dialog_primary").attr("href","javascript:GoToDeleteImg("+tagNum+");"); 
           }
           function GoToDeleteImg(tagNum) {
                $.ajax({
                    url: "QualityFeedbackCore.aspx?ctrl=DelImg&ImgID=" + ImgID[tagNum],
                    type: "POST",
                    dataType: "HTML",
                    timeout: 30000,
                    error: function (XMLHttpRequest, textStatus, errorThrown) {
                       showWarnInfo("服务器出错了");
                    },
                    success: function (result) {
                       $("#dialog1").hide();
                        NowImgCount = NowImgCount - 1;
                        $("#img_" + tagNum).remove();
                        ImgID[tagNum] = 0;
                        ImgOK[tagNum] = 0;
                    }
                });
        }
    function ToThumbs(){
        $.ajax({
            url: "QualityFeedbackCore.aspx?ctrl=ToThumb&MyDjID="+$("#MyDjID").val(),
            type: "POST",
            dataType: "HTML",
            timeout: 30000,
            error: function (XMLHttpRequest, textStatus, errorThrown) {
                showWarnInfo("服务器出错了");
            },
            success: function (result) {
                if(result.indexOf("Successed")>=0){
                    var strArr=result.split("|");
                    if(strArr[3]=="cancel"){
                        $("#cancelThumbs").hide();
                        $("#myName").remove();
                        $("#likeNums").val(Number($("#likeNums").val())-1);
                        $("#IsThumbs").val("0");
                        if(Number($("#likeNums").val())<=0){
                            $(".heartNames").hide();
                        }
                    }else{
                        $("#cancelThumbs").show();
                        $("#heartNames").append("<span id='myName'>"+strArr[2]+"</span>");
                        $("#likeNums").val(Number($("#likeNums").val())+1);
                        $("#IsThumbs").val("1");
                        if(Number($("#likeNums").val())>0){
                            $(".heartNames").show();
                        }
                    }
                }else{
                   showWarnInfo(result,3);
                }
            }
        });
    }
        </script>
    </form>
</body>
</html>


