<%@ Page Title="VIP分析" Language="C#" MasterPageFile="../../WebBLL/frmQQDBase.Master" AutoEventWireup="true" %>
<%@ MasterType VirtualPath="../../WebBLL/frmQQDBase.Master" %>

<%@ Import Namespace="nrWebClass" %> 
<%@ Import Namespace="System.Data" %> 
<%@ Import Namespace="System.Data.SqlClient" %>
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
    string mdid, mdmc;
    protected void Page_PreRender(object sender, EventArgs e)
    {
        // clsWXHelper.CheckQQDMenuAuth(13);    //检查菜单权限
        mdid = Convert.ToString(Request.Params["mdid"]);
        if (string.IsNullOrEmpty(mdid))
        {
            mdid = Convert.ToString(Session["mdid"]);
        }
       // mdid="249";
        if (string.IsNullOrEmpty(mdid)) mdid = "0";
        string OAConnStr = clsConfig.GetConfigValue("OAConnStr");
        using (LiLanzDALForXLM MDal = new LiLanzDALForXLM(OAConnStr))
        {
            DataTable dt = null;
            string strsql = @" select top 1 '('+mdmc+')' as mc from t_mdb a where a.mdid=@mdid";
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
                    mdmc = "";
                    //  clsWXHelper.ShowError("数据时查询不到数据！");
                }
            }
            else
            {
                clsWXHelper.ShowError("统计数据时出错 info:" + errinfo);
            }
            clsSharedHelper.DisponseDataTable(ref dt);  //释放资源
        }
    }

    //必须在内容页的Load中对Master.SystemID 进行赋值；
    protected void Page_Load(object sender, EventArgs e)
    {
        //this.Master.SystemID = "3";     //可设置SystemID,默认为3（全渠道系统）
        //this.Master.AppRootUrl = "../../../";     //可手动设置WEB程序的根目录,默认为 当前页面的向上两级

        //统一的后台错误输出方法
        //clsWXHelper.ShowError("错误提示内容121113456，自定义内容");
        /*母版页，新增加一个属性变量 IsTestMode  如果该值为true，则不会进行鉴权。
          默认值为 false。
          在调试样式时，可在子页面的Load中对其赋值。
		*/
    }

</script>

<asp:Content ID="Content1" ContentPlaceHolderID="head" runat="server">
     <link rel="stylesheet" type="text/css" href="../../res/css/font-awesome.min.css" />
     <link type="text/css" rel="stylesheet" href="../../res/css/StoreSaler/vipliststyle.css" />
     <style type="text/css">
         * {
             margin: 0;
             padding: 0;
         }

         body {
             color: #333;
             background: #eeeeee;
             font-family: "微软雅黑";
         }

         .container {
             width: 100%;
             padding: 10px 15px 15px 15px;
             box-sizing: border-box;
             position: relative;
             top: 50px;
         }

         h2 {
             text-align: center;
         }

         #titleS {
             color: #808080;
             text-align: center;
         }

         hr {
             margin-top: 10px;
             border: 1px dashed #333;
         }

         .sum, .charts {
             margin-top: 10px;
         }

         .infoitem {
             margin-top: 10px;
             display: block;
         }

         .item, .itemval {
             text-align: center;
             word-wrap: break-word;
             word-break: break-all;
             white-space: nowrap;
             display: table-cell;
         }

         .item {
             color: #fff;
             background: #333;
             padding: 6px 15px;
             min-width: 64px;
         }

         .itemval {
             font-size: 1.2em;
             border-bottom: 2px solid #333;
             width: 2000px;
         }

         .sum h3 {
             margin-top: 10px;
         }


         .copyright {
             text-align: center;
             width: 100%;
             color: #808080;
             font-size: 0.8em;
             margin-top: 140px;
         }

         @-webkit-keyframes zdjpop {
             0% {
                 opacity: 1;
                 -webkit-transform: scale(1);
             }

             100% {
                 opacity: 0;
                 -webkit-transform: scale(1.3);
             }
         }

         .legend {
             text-align: center;
             margin-bottom: 10px;
         }

             .legend span {
                 display: inline-block;
                 width: 14px;
                 height: 14px;
                 line-height: 14px;
                 vertical-align: middle;
                 margin: 0px 10px;
             }

         .fre-one-legend {
             background: rgba(240,173,78,0.8);
         }

         .fre-two-legend {
             background: rgba(51,122,183,0.8);
         }

         .fre-three-legend {
             background: rgba(195,25,240,0.8);
         }

         .fre-four-legend {
             background: rgba(232,49,49,0.8);
         }

         .fre-five-legend {
             background: rgba(139, 10, 80,0.8);
         }

         .fre-six-legend {
             background: rgba(131, 111, 255,0.8);
         }

         .fre-seven-legend {
             background: rgba(99, 192, 255,0.8);
         }

         .fre-eight-legend {
             background: rgba(118, 238, 22,0.8);
         }

         .fre-red-legend {
             background: rgba(255,0,0,0.8);
         }

         .fre-green-legend {
             background: rgba(0,255,0,0.8);
         }

         .fa-user {
             font-size: 1.3em;
         }

         .style1 {
             float: left;
             line-height: 40px;
             vertical-align: middle;
             font-weight: bold;
         }

         #act_one {
             background: rgba(255,0,0,1);
         }

         #act_two {
             background: rgba(0,255,0,1);
         }

         ul li {
             list-style: none;
             margin-top: 5px;
             margin-bottom: 2px;
         }

         .num {
             color: #f00;
             font-size: 0.9em;
         }

         .text {
             color: #7e3183;
             font-size: 1em;
         }

         .info li span {
             display: block;
             height: 40px;
             line-height: 30px;
         }

         .info li {
             background-color: #eeeeee;
             text-align: center;
             float: left;
             width: 33%;
             box-sizing: border-box;
             border-right: 1px solid #ccc;
             border-bottom: 1px solid #ccc;
         }

             .info li:nth-child(n) {
                 border-right: none;
             }

         .subtitle {
             padding-top: 5px;
             height: 35px;
         }

             .subtitle li:nth-child(n) {
                 border-right: none;
             }

             .subtitle li span {
                 display: block;
                 height: 30px;
                 line-height: 30px;
             }

             .subtitle li {
                 background-color: #eeeeee;
                 text-align: center;
                 float: left;
                 width: 50%;
                 box-sizing: border-box;
                 border-right: 1px solid #ccc;
             }

         .li_inactive {
             color: rgba(126,49,131,0.5);
             font-size: 1em;
         }

         .li_outactive {
             color: rgba(0,0,0,0.5);
             font-size: 1em;
             border-bottom: 1px solid rgba(0,0,0,0.5);
             border-left: 1px solid rgba(0,0,0,0.5);
         }

         .backbtn {
             position: absolute;
             font-size: 1.4em;
             color: #b1afaf;
             left: 0; /*display:block;*/
             padding: 0 20px;
         }

         .header {
             display: block;
             position: fixed;
             top: 0;
             left: 0;
             width: 100%;
             z-index: 211;
             height: 60px;
             background-color: #272b2e;
             border-bottom: 1px solid #cbcbcb;
             text-align: center;
             padding: 0 10px;
             box-sizing: border-box;
         }

         .logo {
             height: 22px;
             margin: 0 auto;
             margin-top: 18px;
             color: #fff;
             z-index: 110;
         }

             .logo img {
                 height: 100%;
                 width: auto;
             }

         .canvas {
             height: 230px;
             text-align: center;
             padding-top: 1em;
             box-sizing: border-box;
         }
     </style>
</asp:Content>      
<asp:Content ID="Content2" ContentPlaceHolderID="ContentPlaceHolder1" runat="server">
       <div class="header">
        <div class="logo">
            <div class="backbtn"> <i class="fa fa-chevron-left"></i></div>
            <img src="../../res/img/StoreSaler/lllogo6.png" alt="" />
        </div>
       </div>
   
       <div class="container">
         <div id="title"">
          <h2>店铺VIP分析</h2>
          <div align="center"><span id="titleS"><%=mdmc %></span></div>
          <hr/>
          <div id="vipMain" class="info">
                 <ul>
                    <li>
                        <span class="text">VIP总数</span>
                        <span id="ActvipCount" class="num"/>                        
                    </li>
                    <li>
                        <span class="text">本月到店VIP</span>
                        <span id="ActmonthNum" class="num"/>                      
                    </li>
                    <li>
                        <span class="text">半年未消费</span>
                        <span id="ActotherNum" class="num"/>
                    </li>
                </ul>
            </div>
            <div id="Acc" class="infoitem">               
                <div class="item">VIP消费占比</div>
                <div class="subtitle">
                    <ul>
                        <li id="Acc_this" class="li_inactive" onclick="CanvasChange(this,Acc_before,canvas_Acc,Accounting)" >
                            本&nbsp;月              
                        </li>
                        <li id="Acc_before" class="li_outactive" onclick="CanvasChange(this,Acc_this,canvas_Acc,Accounting)">
                            上&nbsp;月             
                        </li>
                    </ul>
                </div>
                <div id="canvas_Acc" class="canvas">
                    <canvas id="Accounting" height="200px"></canvas>
                </div>
                <div class="legend">
                      <span id="acc_one" class="fre-one-legend"></span>vip消费额
                      <span id="acc_two" class="fre-two-legend"></span>非vip消费额
                </div>
                <div class="itemval">              
                </div>
            </div> 
            <div id="Fre" class="infoitem">
                <div id="Fre_title" class="item">客单量分析</div>
                <div class="subtitle">
                    <ul>
                        <li id="Fre_this" class="li_inactive" onclick="CanvasChange(this,Fre_before,canvas_Fre,Frequency)" >
                            本&nbsp;月              
                        </li>
                        <li id="Fre_before" class="li_outactive" onclick="CanvasChange(this,Fre_this,canvas_Fre,Frequency)">
                            上&nbsp;月             
                        </li>
                    </ul>
                </div>
                <div id="canvas_Fre" class="canvas">
                    <canvas id="Frequency" height="200px"></canvas>
                </div>
                <div id="freFoot"class="legend"></div>
                <div class="itemval" ></div>              
            </div>
            <div id="Act" class="infoitem">
                <div class="item">新增会员分析</div>
                <div id="canvas_act" class="canvas">
                    <canvas id="Activity" height="200px"></canvas>
                </div>
                <div id="actFoot" class="legend">
                      <span id="act_one" class="fre-red-legend"></span>新增
                      <span id="act_two" class="fre-green-legend"></span>流失
                </div>
                <div class="itemval">              
                </div>
            </div> 
            <div id="cardCategory" class="infoitem">               
                <div class="item">vip卡类别占比</div>
                <div id="CategoryCanvasTiele" class="canvas">
                    <canvas id="CategoryCanvas"  height="200"></canvas>
                </div>
                <div id="CategoryFoot"class="legend"></div>
                 <div class="itemval" ></div>  
            </div>
            <div id="cardSale" class="infoitem">
                <div id="cardSale_title" class="item">卡类别消费占比</div>
                <div class="subtitle">
                    <ul>
                        <li id="cardSale_this" class="li_inactive" onclick="CanvasChange(this,cardSale_before,cardSaleCanvasTitle,cardSaleCanvas)" >
                            本&nbsp;月              
                        </li>
                        <li id="cardSale_before" class="li_outactive" onclick="CanvasChange(this,cardSale_this,cardSaleCanvasTitle,cardSaleCanvas)">
                            上&nbsp;月             
                        </li>
                    </ul>
                </div>
                <div id="cardSaleCanvasTitle" class="canvas">
                    <canvas id="cardSaleCanvas" height="200"></canvas>
                </div>
                <div id="cardSaleFoot"class="legend"></div>      
            </div>
              <div id="nOSale" class="infoitem">               
                <div class="item">新老客户消费</div>
                <div class="subtitle">
                    <ul>
                        <li id="nOSale_this" class="li_inactive" onclick="CanvasChange(this,nOSale_before,canvas_nOSale,nOSaleAccounting)" >
                            本&nbsp;月              
                        </li>
                        <li id="nOSale_before" class="li_outactive" onclick="CanvasChange(this,nOSale_this,canvas_nOSale,nOSaleAccounting)">
                            上&nbsp;月             
                        </li>
                    </ul>
                </div>
                <div id="canvas_nOSale" class="canvas">
                    <canvas id="nOSaleAccounting" height="200px"></canvas>
                </div>
                <div class="legend">
                      <span id="nOSale_one" class="fre-one-legend"></span>新客户消费额
                      <span id="nOSale_two" class="fre-two-legend"></span>老客户消费额
                </div>
                <div class="itemval">              
                </div>
            </div> 
       </div>

       <div class="copyright">&copy;&nbsp;<%=DateTime.Now.ToString("yyyy")%>利郎信息技术部</div>
    <!--weui_dialog_confirm -->
          <div class="weui_dialog_confirm"  style="display:none">
            <div class="weui_mask"></div>
            <div class="weui_dialog">
                <div class="weui_dialog_hd"><strong class="weui_dialog_title">弹窗标题</strong></div>
                <div class="weui_dialog_bd">自定义弹窗内容...</div>
                <div class="weui_dialog_ft">
                    <a href="javascript:;" id="cancel" class="weui_btn_dialog default">取消</a>
                    <a href="javascript:;" id="confirm" class="weui_btn_dialog primary">确定</a>
                </div>
            </div>
        </div>
    <!--weui_dialog_confirm-->
      </div>
    <script type="text/javascript" src="../../res/js/jquery.js"></script>
    <script type="text/javascript" src="../../res/js/Chart.min.js?ver=160202"></script>
    <script type="text/javascript" src="http://res.wx.qq.com/open/js/jweixin-1.0.0.js"></script>
    <script type='text/javascript' src='../../res/js/StoreSaler/fastclick.min.js'></script>


       <script type="text/javascript">
      
           var way = "thisMonth";
           var mdid = <%=mdid %>;
       
           var arr_color,arr_num,pin_color ;
           $(document).ready(function () {
               FastClick.attach(document.body);
               ShowLoading("拼命加载中...");
           });

           window.onload = function () {
               if(mdid == "0"){
                   HideLoading();
                   confrimAlter("提示","您当前处于管理者，不能使用此功能，是否切换到门店管理模式？");
                   $("#cancel").click(function(){ $(".weui_dialog_confirm").hide();  WeixinJSBridge.call('closeWindow'); });
                   $("#confirm").click(function(){ 
                       $.ajax({
                           type: "POST",
                           timeout: 5000,
                           contentType: "application/x-www-form-urlencoded; charset=utf-8",
                           url: "managerNavCore.aspx",
                           data: { ctrl: "clearSession"},
                           success: function (msg) {
                               if (msg == "Successed") {
                                   localStorage.removeItem("llmanagerNav_mode");
                                   localStorage.removeItem("llmanagerNav_time");
                                   window.location.href = "managerNav.aspx";
                               }
                           },
                           error: function (XMLHttpRequest, textStatus, errorThrown) {
                               LeeJSUtils.showMessage("error", "您的网络有问题..");
                               ShowLoading( "您的网络有问题..",3)
                           }
                       });//end AJAX
                   });
                   //  alert("您当前处于管理模式，请切换到门店模式才可使用本功能");
                   return ;
               }
               arr_color = ["rgba(240,173,78,0.8)", "rgba(51,122,183,0.8)", "rgba(195, 25, 240,0.8)", "rgba(232, 49, 49,0.8)","rgba(139, 10, 80,0.8)","rgba(131, 111, 255,0.8)","rgba(99, 192, 255,0.8)","rgba(118, 238, 22,0.8)"];
               arr_num = ["one", "two", "three", "four","five","six","seven","eight"];
               getVipMain();
            
               //alert(navigator["appCodeName"]);
           }    
           function confrimAlter(title, content) {
               $(".weui_dialog_title").html(title);
               $(".weui_dialog_bd").html(content);
               $(".weui_dialog_confirm").show();
           }

           function CanvasChange(ID,otherID,canvasDiv,canvasID){   
               $("#"+ID["id"]).attr("class","li_inactive");
               $("#"+otherID["id"]).attr("class", "li_outactive"); 
               $("#"+canvasID["id"]).remove();
               $("#"+canvasDiv["id"]).append("<canvas id='"+canvasID["id"]+"' height='200px'></canvas>");

               if(ID["id"].indexOf("this")>-1){
                   way = "thisMonth";
               }else{
                   way = "beforeMonth";
               }

               if(ID["id"].indexOf("Acc")>-1){
                   getAccData(false);
               }else if(ID["id"].indexOf("Fre")>-1) {
                   getFreData(false);
               }else if(ID["id"].indexOf("cardSale")>-1){
                   getCardSale(false);
               }else if(ID["id"].indexOf("nOSale")>-1){
                   getNew_oldSale(false);
               }
           }

           function getVipMain() {
               $.ajax({
                   url: "ShopVipAnalysisCore.aspx?ctrl=VipMain",
                   type: "post",
                   dataType: "text",
                   data: {  mdid: mdid, way: way },
                   cache: false,
                   timeout: 15000,
                   error: function (e) {
                       RedirectErr();
                       return;
                   },
                   success: function (result) {
                       var obj = JSON.parse(result);
                       $("#ActvipCount").html(obj.rows[0].vipCount+"(人)");
                       $("#ActmonthNum").html(obj.rows[0].thisNum+"(人)");
                       $("#ActotherNum").html(obj.rows[0].otherNum+"(人)");
                       getAccData(true);
                   }
               });       
           }

           function getAccData(param) {
               if(param!=true){
                   ShowLoading("拼命加载中...", 5);
               }

               $.ajax({
                   url: "ShopVipAnalysisCore.aspx?ctrl=VipAccounting",
                   type: "post",
                   dataType: "text",
                   data: { mdid: mdid, way: way },
                   cache: false,
                   timeout: 15000,
                   error: function (e) {
                       RedirectErr(Accounting);
                       return;
                   },
                   success: function (result) {
                       var Acc_data = new Array();
                       var obj = JSON.parse(result);
                       //$("#canvas_Acc").destory();
                       $("#Accounting").remove();

                       if (parseInt(obj.rows[0].vipje) != 0) {
                           Acc_data.push({
                               value: parseInt(obj.rows[0].vipje),
                               color: "rgba(240,173,78,0.8)"
                           });
                       }
                       if (parseInt(obj.rows[0].otherje) != 0) {
                           Acc_data.push({
                               value: parseInt(obj.rows[0].otherje),
                               color: "rgba(51,122,183,0.8)"
                           });
                       }
                       if (Acc_data.length == 0) {
                           $("#canvas_Acc").append("<div id='Accounting' height='200px'>Sorry,计算图表数据时查询不到数据!</div>");
                       } else {
                           $("#canvas_Acc").append("<canvas id='Accounting' height='200px'></canvas>");
                           var Acc = $("#Accounting").get(0).getContext("2d");
                           var MyNewChart = new Chart(Acc).Pie(Acc_data);
                       }
                       if (param == true) {
                           getFreData(true);
                       } else {
                           HideLoading();
                           ShowInfo("", 1);
                       }
                   }
               });
           }

           function getFreData(param) {
               if(param!=true){
                   ShowLoading("拼命加载中...", 5);
               }
               $.ajax({
                   url: "ShopVipAnalysisCore.aspx?ctrl=VipFrequency",
                   type: "post",
                   dateType: "text",
                   data: { mdid: mdid, way: way },
                   cache: false,
                   timeout: 15000,
                   error: function (e) {
                       RedirectErr(Frequency);
                       return;
                   },
                   success: function (result) {
                       var obj = JSON.parse(result);
                       var Fre_data = [];
                       $("#freFoot").empty();
                       $("#Frequency").remove();

                       if (obj.rows.length == 0) {
                           $("#canvas_Fre").append("<div id='Frequency' height='200px'>Sorry,计算图表数据时查询不到数据!</div>");
                       } else {
                           $("#canvas_Fre").append("<canvas id='Frequency' height='200px'></canvas>");
                           for (var i = 0; i < obj.rows.length; i++) {
                               Fre_data.push({
                                   value: parseInt(obj.rows[i].num),
                                   color: arr_color[i]
                               });
                               $("#freFoot").append("<span id='fre_" + arr_num[i] + "' class='fre-" + arr_num[i] + "-legend'></span>" + obj.rows[i].js);
                           }
                           var Fre = $("#Frequency").get(0).getContext("2d");
                           var MyNewChart = new Chart(Fre).Pie(Fre_data);
                       }
                       if (param == true) {
                           getActData();
                       } else {
                           HideLoading();
                           ShowInfo("", 1);
                       }
                   }
               });
           }

           function getActData() {
               var labels = new Array();
               var dataAdd = new Array();
               var dataLost = new Array();
               $.ajax({
                   url: "ShopVipAnalysisCore.aspx?ctrl=VipActivity",
                   type: "post",
                   dateType: "text",
                   data: { mdid: mdid, way: way },
                   cache: false,
                   timeout: 15000,
                   error: function (e) {
                       RedirectErr();
                       return;
                   },
                   success: function (result) {
                       var obj = JSON.parse(result);
                       $("#Activity").remove();
                       if(obj.rows.length==0){
                           $("#canvas_act").append("<div id='Activity' height='200px'>Sorry,计算图表数据时查询不到数据!</div>");
                       }else{
                           for (var i = 0; i < obj.rows.length; i++) {
                               labels.push(obj.rows[i].month);
                               dataAdd.push(parseInt(obj.rows[i].addvip));
                               dataLost.push(parseInt(obj.rows[i].lostvip));
                           }
                           var Act_data = {
                               labels: labels,
                               datasets: [
                               {
                                   fillColor: "rgba(255,0,0,0)",
                                   strokeColor: "rgba(255,0,0,1)",
                                   pointColor : "rgba(255,0,0,1)",
                                   pointStrokeColor : "#F00",
                                   data: dataAdd
                               },
                               {
                                   fillColor: "rgba(0,255,0,0)",
                                   strokeColor: "rgba(0,255,0,1)",
                                   pointColor : "rgba(0,255,0,1)",
                                   pointStrokeColor : "#0F0",
                                   data:  dataLost
                               }
                               ]
                           };
                           $("#canvas_act").append("<canvas id='Activity' height='200px'></canvas>");
                           var Act = $("#Activity").get(0).getContext("2d");
                           var MyNewChart = new Chart(Act).Line(Act_data);
		                
                       }
                       setTimeout(getCardCategory(),100);
                       // HideLoading();
                       //   ShowInfo("",1);
                   }             
               });	     
           }
           
           function getCardCategory() {
               $.ajax({
                   url: "ShopVipAnalysisCore.aspx?ctrl=VipCardRatio",
                   type: "post",
                   dateType: "text",
                   data: { mdid: mdid, way: way },
                   cache: false,
                   timeout: 15000,
                   error: function (e) {
                       RedirectErr();
                       return;
                   },
                   success: function (result) {
                       var obj = JSON.parse(result);
                       $("#CategoryCanvas").remove();
                       $("#CategoryFoot").empty();

                       $("#cardSaleCanvas").remove();
                       $("#cardSaleFoot").empty();
                       var Fre_data = [];
                       var sale_data = [];
                       if(obj.code=="200"){
                           if(obj.vip.length==0){
                               $("#CategoryCanvasTiele").append("<div id='CategoryCanvas' height='200px'>Sorry,计算图表数据时查询不到数据!</div>");
                           }else{
                               $("#CategoryCanvasTiele").append("<canvas id='CategoryCanvas'  height='200'></canvas>");
                               for (var i = 0; i < obj.vip.length; i++) {
                                   Fre_data.push({
                                       value: parseInt(obj.vip[i].sl),
                                       color: arr_color[i]
                                   });
                                   $("#CategoryFoot").append("<span class='fre-" + arr_num[i] + "-legend'></span>" + obj.vip[i].mc);
                               }
                               var  ctx =$("#CategoryCanvas").get(0).getContext("2d");
                               var MyNewChart = new Chart(ctx).Pie(Fre_data);
                           }
                       }
                       setTimeout(getCardSale(true),10);
                       //  HideLoading();
                   }             
               });	     
           }
           function getCardSale(param){
               if(param!=true){
                   ShowLoading("拼命加载中...", 5);
               }
               $.ajax({
                   url: "ShopVipAnalysisCore.aspx?ctrl=VipSaleRatio",
                   type: "post",
                   dateType: "text",
                   data: { mdid: mdid, way: way },
                   cache: false,
                   timeout: 15000,
                   error: function (e) {
                       RedirectErr();
                       return;
                   },
                   success: function (result) {
                       var obj = JSON.parse(result);
                       $("#cardSaleCanvas").remove();
                       $("#cardSaleFoot").empty();
                       var sale_data = [];
                       if(obj.code=="200"){
                           if(obj.sale.length==0){
                               $("#cardSaleCanvasTitle").append("<div id='cardSaleCanvas' height='200px'>Sorry,计算图表数据时查询不到数据!</div>");
                           }else{
                               $("#cardSaleCanvasTitle").append("<canvas id='cardSaleCanvas'  height='200'></canvas>");
                               for (var i = 0; i < obj.sale.length; i++) {
                                   sale_data.push({
                                       value: parseInt(obj.sale[i].sje),
                                       color: arr_color[i]
                                   });
                                   $("#cardSaleFoot").append("<span class='fre-" + arr_num[i] + "-legend'></span>" + obj.sale[i].mc);
                               }
                               var  salep =$("#cardSaleCanvas").get(0).getContext("2d");
                               var MySaleChart = new Chart(salep).Pie(sale_data);
                           }
                       }
                       getNew_oldSale();
                       HideLoading();
                       ShowInfo("", 1);
                   }             
               });	     
           }
           //新老用户消费
           function getNew_oldSale(){
               $.ajax({
                   url: "ShopVipAnalysisCore.aspx?ctrl=getNew_oldSale",
                   type: "post",
                   dateType: "text",
                   data: { mdid: mdid, way: way },
                   cache: false,
                   timeout: 15000,
                   error: function (e) {
                       RedirectErr();
                       return;
                   },
                   success: function (result) {
                       
                       var AcnOSale_data = new Array();
                       var obj = JSON.parse(result);
                     
                      // console.log(obj);
                       //$("#canvas_Acc").destory();
                       $("#nOSaleAccounting").remove();

                       if (parseInt(obj.sale[0].xje) != 0) {
                           AcnOSale_data.push({
                               value: parseInt(obj.sale[0].xje),
                               color: "rgba(240,173,78,0.8)"
                           });
                       }
                       if (parseInt(obj.sale[0].jje) != 0) {
                           AcnOSale_data.push({
                               value: parseInt(obj.sale[0].jje),
                               color: "rgba(51,122,183,0.8)"
                           });
                       }
                       if ( AcnOSale_data.length == 0) {
                           $("#canvas_nOSale").append("<div id='nOSaleAccounting' height='200px'>Sorry,计算图表数据时查询不到数据!</div>");
                       } else {
                           $("#canvas_nOSale").append("<canvas id='nOSaleAccounting' height='200px'></canvas>");
                           var nOSale = $("#nOSaleAccounting").get(0).getContext("2d");
                           var MyNewChart = new Chart(nOSale).Pie( AcnOSale_data);
                       }
                       
                   }
               })
            }

           function num2chs(ny) {
               switch (ny) {
                   case "01":
                       return "一月";
                   case "02":
                       return "二月";
                   case "03":
                       return "三月";
                   case "04":
                       return "四月";
                   case "05":
                       return "五月";
                   case "06":
                       return "六月";
                   case "07":
                       return "七月";
                   case "08":
                       return "八月";
                   case "09":
                       return "九月";
                   case "10":
                       return "十月";
                   case "11":
                       return "十一月";
                   case "12":
                       return "十二月";
               }
           }    
    </script>       
</asp:Content>
