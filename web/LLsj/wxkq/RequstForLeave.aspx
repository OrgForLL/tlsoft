<%@ Page Language="C#" Debug="true" %>
<%@ Import Namespace="System.Data" %>
<%@ Import Namespace="nrWebClass" %>
<%@ Import Namespace="WebBLL.Core" %>
<%@ Import Namespace="System.Web" %>
<%@ Import Namespace="System.IO" %>

<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<script runat="server">
    public string userid = "";
    public string username = "";
    public string rybh = "";
    public string ryid = "";
    public string bmmc = "";
    public string lxdh = "";
    protected void Page_Load(object sender, EventArgs e)
    {
        userid = Convert.ToString(Session["wxkq_userid"]);
        if (userid == null || userid == "")
        {
            Response.Write("访问超时！");
            Response.End();
        }
        else
        {
            username =Convert.ToString(Session["wxkq_username"]);
            rybh = Convert.ToString(Session["wxkq_rybh"]);
            ryid = Convert.ToString(Session["wxkq_ryid"]);
            bmmc = Convert.ToString(Session["wxkq_bmmc"]);
            lxdh = Convert.ToString(Session["wxkq_lxdh"]);
        }
    }
</script>
<html xmlns="http://www.w3.org/1999/xhtml">
<head id="Head1"  runat="server">
    <title></title>
     <meta name="viewport" content="width=device-width, initial-scale=1.0, user-scalable=no,maximum-scale=1.0,minimum-scale=1.0" />
    <meta name="format-detection" content="telephone=yes" />
    <script type="text/javascript" src="js/jquery.js"></script>
    <link rel="stylesheet" href="css/weui.min.css" />
    <link rel="stylesheet" href="css/example.css" />
    <style type="text/css">

         .copyright {
            font-size: 0.9em;
            text-align: center;
            color: #333;
            padding: 1em 0;
        }

        .page {
            overflow-x:hidden;
        }     
    </style>
</head>
<body   >
    <div class="container js_container">
   <input id="username" value="<%=username %>" hidden="hidden" style="display:none" />
   <input id="rybh" value="<%=rybh %>" hidden="hidden"  style="display:none"/>
   <input id="ryid" value="<%=ryid %>" hidden="hidden"  style="display:none" />
   <input id="ID" value="0" hidden="hidden"  style="display:none" />
        <div class="page">
          <div class="hd">
                <h1 class="page_title">请假单</h1>
            </div>
        <div class="bd">
            <div class="weui_cells weui_cells_form">
                <div class="weui_cell">
                    <div class="weui_cell_hd"><label class="weui_label">请假人</label></div>
                    <div class="weui_cell_bd weui_cell_primary">
                        <input class="weui_input" id="xm" type="text" value="<%=username %>" placeholder="请输入请假姓名"/>
                    </div>
                </div>
            </div>
              <div class="weui_cells weui_cells_form">
                <div class="weui_cell">
                    <div class="weui_cell_hd"><label class="weui_label">部门</label></div>
                    <div class="weui_cell_bd weui_cell_primary">
                        <input class="weui_input" id="bmmc" type="text" value="<%=bmmc %>" placeholder="请输入部门名称"/>
                    </div>
                </div>
            </div>
             <div class="weui_cells weui_cells_form">
                <div class="weui_cell">
                    <div class="weui_cell_hd"><label class="weui_label">电话</label></div>
                    <div class="weui_cell_bd weui_cell_primary">
                        <input class="weui_input"  id="lxdh" type="text"  value="<%=lxdh %>" placeholder="请输入电话号码"/>
                    </div>
                </div>
            </div>
               <div class="weui_cell weui_cell_select  weui_select_after">
                    <div class="weui_cell_hd">类型</div>
                    <div class="weui_cell_bd weui_cell_primary">
                        <select class="weui_select" id="qjlx">
                              <option value="1">婚假</option>
                              <option value="2">病假</option>
                              <option  selected="selected" value="3">事假</option>
                              <option value="6">丧假</option>
                              <option value="7">产假</option>
                              <option value="10">工伤</option>
                        </select>
                    </div>
                </div>

             <div class="weui_cells weui_cells_form">
                <div class="weui_cell">
                    <div class="weui_cell_hd"><label class="weui_label">日期</label></div>
                    <div class="weui_cell_bd weui_cell_primary">
                        <input class="weui_input" id="kssj" type="date" placeholder="开始日期" style=" width:70%; height:1.5em;"/>
                       <select class="weui_select" id="ksday" style=" width:25%;height:1.5em;">
                            <option selected="" value="1">上午</option>
                            <option value="2">下午</option>
                        </select>
                    </div>
                </div>
                 <div class="weui_cell">
                    <div class="weui_cell_hd"><label class="weui_label">至</label></div>
                    <div class="weui_cell_bd weui_cell_primary">
                       <input class="weui_input" id="jssj" type="date" placeholder="结束日期" style=" width:70%; height:1.5em;"/>
                       <select class="weui_select" id="jsday" style=" width:25%; height:1.5em;">
                            <option  value="1">上午</option>
                            <option selected="" value="2">下午</option>
                        </select>
                    </div>
                </div>
            </div>

            <div class="weui_cells weui_cells_form">
                <div class="weui_cell">
                    <div class="weui_cell_hd"><label class="weui_label">天数</label></div>
                    <div class="weui_cell_bd weui_cell_primary">
                        <input class="weui_input" id="qjsj" type="text"  value="1" readonly="readonly"/>
                    </div>
                </div>
            </div>
            <div class="weui_cells_title">请假原因</div>
            <div class="weui_cell weui_cells_form">
                    <div class="weui_cell_bd weui_cell_primary">
                        <textarea class="weui_textarea" id="qjyy" cols="3"  placeholder="请输入请假原因..."></textarea>
                    </div>
            </div>  
        </div>
         <div class="bd spacing" style=" padding-bottom:1em;">
             <div class="button_sp_area">
                <a href="javascript:SaveInfo('saveandsend');" id="SaveSend" class="weui_btn  weui_btn_primary" style=" width:45%; display: inline-block;">立即提交</a>
                <div style=" width:5%; display: inline-block;"></div>
                <a href="javascript:SaveInfo('save');" id="btnSave" class="weui_btn  weui_btn_default" style=" width:45%;display: inline-block;">保存草稿</a>
             </div>
        </div>
             <div class="copyright">&copy;2017 利郎信息技术部</div>
        </div>
    </div>
     <!--BEGIN toast-->
	<div id="toast" style="display: none;">
		<div class="weui_mask_transparent"></div>
		<div class="weui_toast">
			<i class="weui_icon_toast"></i>
			<p class="weui_toast_content">保存成功</p>
		</div>
	</div>
	<!--end toast-->

	<!-- loading toast -->
	<div id="loadingToast" class="weui_loading_toast" style="display:none;">
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
			<p class="weui_toast_content">数据加载中</p>
		</div>
	</div>
      <!--BEGIN dialog2-->
            <div class="weui_dialog_alert" id="dialog2" style="display: none;">
                <div class="weui_mask"></div>
                <div class="weui_dialog">
                    <div class="weui_dialog_hd"><strong class="weui_dialog_title" id="dialog2Title">弹窗标题</strong></div>
                    <div class="weui_dialog_bd" id="dialog2Text">弹窗内容，告知当前页面信息等</div>
                    <div class="weui_dialog_ft">
                        <a href="javascript:dialog2();" class="weui_btn_dialog primary">确定</a>
                    </div>
                </div>
            </div>
            <!--END dialog2-->
    <!-- zepto.js was cached by wechat app -->
    <script type="text/javascript" src="js/wxsaveend.js"></script>
       <script type="text/javascript">
           function dialog2() {
               $("#dialog2").hide();
               $("#loadingToast").hide();
               
           }

           $(document).ready(function (e) {
               var ksrq = new Date();
               var jsrq = new Date();
               $("#kssj").val(ksrq.format("yyyy-MM-dd"));
               $("#jssj").val(jsrq.format("yyyy-MM-dd"));

               $("#kssj").change(function (e) {
                   Get_Kqts();
               });
               $("#jssj").change(function (e) {
                   Get_Kqts();
               });
               $("#ksday").change(function (e) {
                   Get_Kqts();
               });
               $("#jsday").change(function (e) {
                   Get_Kqts();
               });
           })

           //保存单据
        //   $("#btnSave").click(function (e) {
           function SaveInfo(T) {
               $("#loadingToast").show();
               var username = $("#username").val();
               var rybh = $("#rybh").val();
               var ryid = $("#ryid").val();
               var xm = $("#xm").val();
               var lxdh = $("#lxdh").val();
               var qjlx = $("#qjlx").val();
               var kssj = $("#kssj").val();
               var ksday = $("#ksday").val();
               var jssj = $("#jssj").val();
               var jsday = $("#jsday").val();
               var qjsj = $("#qjsj").val();
               var qjyy = $("#qjyy").val();
               var idval = $("#ID").val();
               if (rybh == "") {
                   $("#dialog2Title").html("无法获取个人信息");
                   $("#dialog2Text").html("请稍后重试");
                   $(".weui_dialog_ft").hide();
                   $("#dialog2").show();
                   setTimeout(function () {
                       WeixinJSBridge.call('closeWindow');
                   }, 2000);
                   return false;
               } else if (qjsj == "") {
                   $("#dialog2Title").html("无效请假时间");
                   $("#dialog2Text").html("请重新选择请假时间");
                   $("#dialog2").show();
                   return false;
               } else if (qjsj > 0 && qjsj < 0.5) {
                   //  swal("请假天数必须是0.5天的倍数！\n请假2个小时，请填写签卡单并在签卡单上写明原因！");
                   $("#dialog2Title").html("无效请假时间");
                   $("#dialog2Text").html("请假天数必须是0.5天的倍数！\n请假2个小时，请填写签卡单并在签卡单上写明原因！");
                   $("#dialog2").show();
                   return false;
               } else if (qjsj <= 0) {
                   $("#dialog2Title").html("无效请假时间");
                   $("#dialog2Text").html("请假天数有误，请确定请假开始日期要小于请假结束日期!");
                   $("#dialog2").show();
                   return false;
               } else if (qjyy == "") {
                   $("#dialog2Title").html("请输入请假原因！");
                   $("#dialog2Text").html("");
                   $("#dialog2").show();
                   return false;
               }
               if (isNaN(idval)) idval = 0;
               $.ajax({
                   type: "POST",
                   url: "DataDealInterface.aspx",
                   contentType: "application/x-www-form-urlencoded; charset=utf-8",
                   data: { ctrl: "saveDate", userid: username, ryid: ryid, rybh: rybh, xm: xm, lxdh: lxdh, qjlx: qjlx, kssj: kssj, jssj: jssj, ksday: ksday, jsday: jsday, qjsj: qjsj, qjyy: qjyy, id: idval, saveType: T },
                   success: function (msg) {
                       $("#loadingToast").hide();
                       if (msg.indexOf("Successed") >= 0) {
                           msg = msg.replace(/Successed\|/g, "");
                           if (!isNaN(msg)) {
                               $("#ID").val(msg);
                           }
                           if (T == "saveandsend") {
                               LLOA.showpage("提交成功!", "是否立即发送审批？", "发起审批", "离开", function () {
                                   //window.location.href = "http://sj.lilang.com:186/LLsj/OnlineLogin.aspx?type=KaoQinDaiBan";
                                   window.location.href = "../docList.aspx";
                               }, function () { WeixinJSBridge.call('closeWindow'); });
                           } else {
                               $('#toast').show();
                               setTimeout(function () {
                                   $('#toast').hide();
                               }, 2000);
                           }
                       } else {
                           $("#dialog2Title").html("出错啦");
                           $("#dialog2Text").html(msg);
                           $("#dialog2").show();
                       }
                   },
                   error: function (XMLHttpRequest, textStatus, errorThrown) {
                       $("#loadingToast").hide();
                       //  swal("错误" + errorThrown.toString(), "请稍后重试", "error");
                       $("#dialog2Title").html("出错啦");
                       $("#dialog2Text").html(errorThrown.toString());
                       $("#dialog2").show();
                   }
               });
           }

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
               if (/(y+)/.test(format))
                   format = format.replace(RegExp.$1,
				(this.getFullYear() + "").substr(4 - RegExp.$1.length));
               for (var k in o)
                   if (new RegExp("(" + k + ")").test(format))
                       format = format.replace(RegExp.$1,
					RegExp.$1.length == 1 ? o[k] :
					("00" + o[k]).substr(("" + o[k]).length));
               return format;
           }

           function stringToJson(stringValue) {
               eval("var theJsonValue = " + stringValue);
               return theJsonValue;
           }

           function Get_Kqts() {
               var zts = 0, j = 0, k = 0, l = 0, zjsj;
               var kssj = new Date($("#kssj").val().replace("-", "/"));
               var jssj = new Date($("#jssj").val().replace("-", "/"));
               zts = getDayDiff(kssj, jssj) + 1;
               if ($("#qjlx").val() != 6 && $("#qjlx").val() != 7) { //假期统一不带薪
                   $.ajax({
                       url: 'DataDealInterface.aspx',
                       data: { ctrl: "getDays", kssj: $("#kssj").val(), jssj: $("#jssj").val() },
                       cache: false,
                       async: false,
                       type: "POST",
                       contentType: "application/x-www-form-urlencoded; charset=utf-8",
                       success: function (result) {
                           zts = result;
                       },
                       error: function (XMLHttpRequest, textStatus, errorThrown) {
                           $("#dialog2Title").html("出错啦");
                           $("#dialog2Text").html(errorThrown.toString());
                           $("#dialog2").show();
                           return 0;
                       }
                   });
               }
               var ks_sj = $("#ksday").val(); //上午
               var js_sj = $("#jsday").val(); //下午
               if (ks_sj == "2") { //开始 下午 -0.5天
                   zts = zts - 0.5;
               }
               if (js_sj == "1") { //结束 上午 -0.5天
                   zts = zts - 0.5;
               }
               $("#qjsj").val(zts);
           }

           function getDayDiff(d1, d2) {
               return (d2.getTime() - d1.getTime()) / (24 * 60 * 60 * 1000);
           }

           function checkday(kssjval, jssjval) {
               $.ajax({
                   type: "POST",
                   url: "DataDealInterface.aspx",
                   contentType: "application/x-www-form-urlencoded; charset=utf-8",
                   data: { ctrl: "getDays", kssj: kssjval, jssj: jssjval },
                   success: function (msg) {
                       return msg;
                   },
                   error: function (XMLHttpRequest, textStatus, errorThrown) {
                       $("#dialog2Title").html("出错啦");
                       $("#dialog2Text").html(errorThrown.toString());
                       $("#dialog2").show();
                       return 0;
                   }
               });
           }
           /*
            function GetInfo() {
               var nameval = $("#username").val();
               var idval = $("#ID").val();
               $.ajax({
                   type: "POST",
                   url: "DataDealInterface.aspx",
                   contentType: "application/x-www-form-urlencoded; charset=utf-8",
                   data: { ctrl: "GetPersonInfo", userid: nameval, id: idval },
                   success: function (msg) {
                       var t = stringToJson(msg);
                       $("#xm").val(t.cname);
                       $("#rybh").val(t.rybh);
                       $("#ryid").val(t.ryid);
                       $("#lxdh").val(t.lxdh);
                       $("#bmmc").val(t.bmmc);
                        if (idval != "" && idval != 0) {
                       $("#qjlx").val(t.lx);
                       $("#kssj").val(t.kssj);
                       $("#jssj").val(t.jssj);
                       $("#ksday").val(t.ksday);
                       $("#jsday").val(t.jsday);
                       $("#qjsj").val(t.qjsj);
                       $("#qjyy").val(t.qjyy);
                       }

                   },
                   error: function (XMLHttpRequest, textStatus, errorThrown) {
                       $("#dialog2Title").html("出错啦");
                       $("#dialog2Text").html(errorThrown.toString());
                       $("#dialog2").show();
                   }
               });
           }
           */
       </script>

</body>
</html>
