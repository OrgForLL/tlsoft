<%@ Page Language="C#" %>

<%@ Import Namespace="System.Data" %>
<%@ Import Namespace="nrWebClass" %>
<%@ Import Namespace="WebBLL.Core" %>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<script runat="server">
    //public string username = "蔡铭光";
    public string CheckID = "0";
    //public string CheckID = "0";
   // public string userid = "0";
    public string userid = "";
    public string username = "";
    public string bmmc = "";
    public string rybh = "";
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
            username = Convert.ToString(Session["wxkq_username"]);
            bmmc = Convert.ToString(Session["wxkq_bmmc"]);
            rybh = Convert.ToString(Session["wxkq_rybh"]);
        }
    }
</script>
<html xmlns="http://www.w3.org/1999/xhtml">
<head id="Head1" runat="server">
    <title></title>
    <meta name="viewport" content="width=device-width, initial-scale=1.0, user-scalable=no,maximum-scale=1.0,minimum-scale=1.0" />
    <meta name="format-detection" content="telephone=yes" />
    <script type="text/javascript" src="js/jquery.js"></script>
    <link rel="stylesheet" href="css/weui.min.css" />
    <link rel="stylesheet" href="css/example.css" />
    <style type="text/css">
        .page {
            overflow-x:hidden;
        }
    </style>
</head>
<body>
    <div class="container js_container">
        <input id="username" value="<%=username %>" hidden="hidden" style="display: none" />
        <input id="userid" value="<%=userid %>" hidden="hidden" style="display: none" />
        <input id="ID" value="<%=CheckID %>" hidden="hidden" style="display: none" />
        <div class="page">
            <div class="hd">
                <h1 class="page_title">
                    签卡单</h1>
            </div>
            <div class="bd">
                <div class="weui_cells weui_cells_form">
                    <div class="weui_cell">
                        <div class="weui_cell_hd">
                            <label class="weui_label">
                                姓&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;名</label></div>
                        <div class="weui_cell_bd weui_cell_primary">
                            <input class="weui_input" id="name" type="text" placeholder="请输入签卡人姓名" value="<%=username %>" style="height: 1.5em;padding-left:12px;" />
                        </div>
                    </div>
                </div>
                <div class="weui_cells weui_cells_form">
                    <div class="weui_cell">
                        <div class="weui_cell_hd">
                            <label class="weui_label">
                                人员编号</label></div>
                        <div class="weui_cell_bd weui_cell_primary">
                            <input class="weui_input" id="rybh" type="text" placeholder="请输入人员编号" value="<%=rybh %>"  style="height: 1.5em;padding-left:10px;" />
                        </div>
                    </div>
                </div>
                <div class="weui_cells weui_cells_form">
                    <div class="weui_cell">
                        <div class="weui_cell_hd">
                            <label class="weui_label">
                                部&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;门</label></div>
                        <div class="weui_cell_bd weui_cell_primary">
                            <input class="weui_input" id="bmmc" type="text" placeholder="请输入部门名称" value="<%=bmmc %>" style="height: 1.5em;padding-left:10px;" />
                        </div>
                    </div>
                </div>
                <div class="weui_cells weui_cells_form">
                    <div class="weui_cell">
                        <div class="weui_cell_hd">
                            <label class="weui_label">
                                签卡日期</label>
                        </div>
                        <div class="weui_cell_bd weui_cell_primary">
                            <input class="weui_input" id="checkdate" type="date" placeholder="请选择签卡日期" style="height: 2em;padding-left:20px;" />
                        </div>
                    </div>
                    <div class="weui_cell weui_cell_select  weui_select_after">
                        <div class="weui_cell_hd">
                            班&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;次
                        </div>
                        <div class="weui_cell_bd weui_cell_primary">
                            <select class="weui_select" id="bc" style="height: 2em;">
                                <option selected="" value="上午">上午</option>
                                <option value="下午">下午</option>
                            </select>
                        </div>
                    </div>
                    <div class="weui_cell weui_cell_select weui_select_after">
                        <div class="weui_cell_hd" style="width: 1.5em, height:1.5em;">
                            签到/退
                        </div>
                        <div class="weui_cell_bd weui_cell_primary">
                            <select class="weui_select" id="qdqt" style="height: 2em;">
                                <option value="1">上班</option>
                                <option value="2">下班</option>
                            </select>
                        </div>
                    </div>
                </div>
                <div class="weui_cells_title">
                    签卡原因</div>
                <div class="weui_cell weui_cells_form">
                    <div class="weui_cell_bd weui_cell_primary">
                        <textarea class="weui_textarea" id="yy" cols="3"></textarea>
                    </div>
                </div>
            </div>
            <div class="bd spacing" style="padding-bottom: 3em;">
                <div class="button_sp_area">
                    <a href="javascript:SaveInfo('send');" id="SaveSend" class="weui_btn  weui_btn_primary" style="width: 45%;
                        display: inline-block;">立即提交</a>
                    <div style="width: 5%; display: inline-block;">
                    </div>
                    <a href="javascript:SaveInfo('save');" id="btnSave" class="weui_btn  weui_btn_default" style="width: 45%;
                        display: inline-block;">保存草稿</a>
                </div>
            </div>
        </div>
    </div>
    <!--BEGIN toast-->
    <div id="toast" style="display: none;">
        <div class="weui_mask_transparent">
        </div>
        <div class="weui_toast">
            <i class="weui_icon_toast"></i>
            <p class="weui_toast_content">
                已完成</p>
        </div>
    </div>
    <!--end toast-->
    <!-- loading toast -->
    <div id="loadingToast" class="weui_loading_toast" style="display: none;">
        <div class="weui_mask_transparent">
        </div>
        <div class="weui_toast">
            <div class="weui_loading">
                <div class="weui_loading_leaf weui_loading_leaf_0">
                </div>
                <div class="weui_loading_leaf weui_loading_leaf_1">
                </div>
                <div class="weui_loading_leaf weui_loading_leaf_2">
                </div>
                <div class="weui_loading_leaf weui_loading_leaf_3">
                </div>
                <div class="weui_loading_leaf weui_loading_leaf_4">
                </div>
                <div class="weui_loading_leaf weui_loading_leaf_5">
                </div>
                <div class="weui_loading_leaf weui_loading_leaf_6">
                </div>
                <div class="weui_loading_leaf weui_loading_leaf_7">
                </div>
                <div class="weui_loading_leaf weui_loading_leaf_8">
                </div>
                <div class="weui_loading_leaf weui_loading_leaf_9">
                </div>
                <div class="weui_loading_leaf weui_loading_leaf_10">
                </div>
                <div class="weui_loading_leaf weui_loading_leaf_11">
                </div>
            </div>
            <p class="weui_toast_content">
                数据加载中</p>
        </div>
    </div>
    <!--BEGIN dialog2-->
    <div class="weui_dialog_alert" id="dialog2" style="display: none;">
        <div class="weui_mask">
        </div>
        <div class="weui_dialog">
            <div class="weui_dialog_hd">
                <strong class="weui_dialog_title" id="dialog2Title">弹窗标题</strong></div>
            <div class="weui_dialog_bd" id="dialog2Text">
                弹窗内容，告知当前页面信息等</div>
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
           }

           $(document).ready(function (e) {

               $("#loadingToast").show();

               //GetInfo();
               $("#loadingToast").css("display", "none");


               $("#checkdate").change(function (e) {
                   var userid = $("#userid").val();
                   var checkdate = $("#checkdate").val();
                   //alert(userid);
                   if (userid == "") {
                       $("#dialog2Text").html("请选择签卡人员！");
                       $("#dialog2").show();
                       return false;
                   }
                   checkbc(userid,checkdate);
               });
               $("#name").change(function (e) {
                   var name = $("#name").val();
                   check_ryxx();
               });
              })
               //保存单据
              function SaveInfo(str) { 
                   var username = $("#username").val();
                   //var rybh = $("#rybh").val();
                   var userid = $("#userid").val();
                   var name = $("#name").val();
                   var rybh = $("#rybh").val();
                   var bmmc = $("#bmmc").val();
                   var checkdate = $("#checkdate").val();
                   var bc = $("#bc").val();
                   var qdqt = $("#qdqt").val();
                   var yy = $("#yy").val();
                   var id = $("#ID").val();
                   if (isNaN(id)) id = 0;
                   if (rybh == "") {
                       $("#dialog2Title").html("无法获取个人信息！");
                       $("#dialog2Text").html("请稍后重试！");
                       $(".weui_dialog_ft").hide();
                       $("#dialog2").show();
                       setTimeout(function () {
                           WeixinJSBridge.call('closeWindow');
                       }, 2000);
                       return false;
                   } else if (checkdate == "") {
                       $("#dialog2Title").html("无效签卡日期！");
                       $("#dialog2Text").html("请重新选择签卡日期！");
                       $("#dialog2").show();
                       return false;
                   } else if (bc == "" || bc == "0") {
                       $("#dialog2Text").html("请重新选择签卡班次！");
                       $("#dialog2").show();
                       return false;
                   } else if (qdqt == "" || qdqt == "0") {
                       $("#dialog2Text").html("请重新选择签到签退！");
                       $("#dialog2").show();
                       return false;
                   } else if (yy == "") {
                       $("#dialog2Title").html("请输入签卡原因！");
                       $("#dialog2Text").html("");
                       return false;
                   }


                   $.ajax({
                       type: "POST",
                       url: "DataDealInterface.aspx",
                       contentType: "application/x-www-form-urlencoded; charset=utf-8",
                       data: { ctrl: "SaveCheckDate", userid: userid, rybh: rybh, name: name, bc: bc, qdqt: qdqt, yy: yy, id: id, username: username, checkdate: checkdate, saveType: str },
                       success: function (msg) {
                           $("#loadingToast").hide();
                           if (msg.indexOf("Successed") >= 0) {
                               msg = msg.replace(/Successed\|/g, "");

                               if (!isNaN(msg)) {
                                   $("#ID").val(msg);
                               }
                            
                               if (str == "send") {
                                   //alert(msg);
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
                           //alert(msg);
                       },
                       error: function (XMLHttpRequest, textStatus, errorThrown) {
                           $("#dialog2Title").html("出错啦");
                           $("#dialog2Text").html(errorThrown.toString());
                           $("#dialog2").show();
                       }
                   });

           }
           function checkbc(userid, checkdate) {
           //alert(1)
               $.ajax({
                   type: "POST",
                   url: "DataDealInterface.aspx",
                   contentType: "application/x-www-form-urlencoded; charset=utf-8",
                   data: { ctrl: "check_ryxz", checkdate: checkdate, userid: userid },
                   success: function (msg) {
                       //alert(msg);
                       var t = stringToJson(msg);
                       $("#bc").empty(); //删除值为3的Option
                       $("#bc").append("<option value=" + t.schname + ">" + t.schname + "</option>");
                       $("#bc").append("<option value=" + t.schname1 + ">" + t.schname1 + "</option>");
                   },
                   error: function (XMLHttpRequest, textStatus, errorThrown) {
                       // alert("错误" + errorThrown.toString());
                       $("#dialog2Title").html("出错啦");
                       $("#dialog2Text").html(errorThrown.toString());
                       $("#dialog2").show();
                       return 0;
                   }
               });
           }
           function check_ryxx() {
           //alert(2);
               var name = $("#name").val();

               if (name == "") {
                   $("#name").val("");
                   $("#rybh").val("");
                   $("#userid").val("");
                   $("#bmmc").val("");
               }
               $.ajax({
                   type: "POST",
                   url: "DataDealInterface.aspx",
                   contentType: "application/x-www-form-urlencoded; charset=utf-8",
                   data: { ctrl: "check_ryxx", name: name },
                   success: function (msg) {
                       //alert(msg);
                       var t = stringToJson(msg);
                      // alert(t.sl);
                       $("#name").val(t.name);
                       $("#rybh").val(t.rybh);
                       $("#userid").val(t.userid);
                       $("#bmmc").val(t.bmmc);
                   },
                   error: function (XMLHttpRequest, textStatus, errorThrown) {
                       $("#dialog2Title").html("出错啦");
                       $("#dialog2Text").html(errorThrown.toString());
                       $("#dialog2").show();
                   }
               });
           }
           /* linwy暂时没用
           function GetInfo() {
           var userid = $("#userid").val();
           var id = $("#ID").val();
           $.ajax({
           type: "POST",
           url: "DataDealInterface.aspx",
           contentType: "application/x-www-form-urlencoded; charset=utf-8",
           data: { ctrl: "GetPersonInfo", userid: userid, id: id },
           success: function (msg) {
           //alert(msg);

           var t = stringToJson(msg);
           $("#name").val(t.name);
           $("#rybh").val(t.rybh);
           $("#userid").val(t.userid);
           $("#id").val(t.id);
           $("#bmmc").val(t.bmmc);

           },
           error: function (XMLHttpRequest, textStatus, errorThrown) {

           $("#dialog2Title").html("出错啦");
           $("#dialog2Text").html(errorThrown.toString());
           $("#dialog2").show();
           }
           });
           }*/


           function stringToJson(stringValue) {
               eval("var theJsonValue = " + stringValue);
               return theJsonValue;
           }

          
    </script>
</body>
</html>
