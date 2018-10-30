<%@ Page Language="C#" Debug="true"%>
<%@ Import Namespace="nrWebClass" %>
<%@ Import Namespace="System.Security.Cryptography" %>
<%@ Import Namespace="System.Data" %>
<%@ Import Namespace="System.Data.SqlClient" %>
<%@ Import Namespace="System.Collections.Generic" %>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">

<script runat="server">
    public string xtid ;
    public string ClosePag="0";//调用此页面后是否需要关闭此页面
    public string username, phoneNo, status, HaveBan;//,name,customerID,openID
    string DBConStr = clsConfig.GetConfigValue("OAConnStr");
    protected void Page_Load(object sender, EventArgs e)
    {
        xtid = Convert.ToString(Request.Params["systemid"]);
        ClosePag = Convert.ToString(Request.Params["ClosePag"]);
        if (xtid == null || xtid == "")
        {
            Response.Write("传入参数有误");
            Response.End();
            return;
        }
        if (clsWXHelper.CheckQYUserAuth(false))
        {
            username = Convert.ToString(Session["qy_cname"]);
            phoneNo = Convert.ToString(Session["qy_mobile"]);
            status = Convert.ToString(Session["qy_status"]);
            //name = Convert.ToString(Session["qy_name"]);
            //customerID = Convert.ToString(Session["qy_customersid"]);
            //openID = Convert.ToString(Session["qy_OpenId"]);
            string mySql = @" DECLARE @bs INT
                              SET @bs = 0
                IF (@customerID <> '')   
                BEGIN
                    select TOP 1 @bs = ID from wx_t_AppAuthorized where SystemID=@SystemID and userid=@customerID and IsActive=1 
                END
                SELECT @bs AS bs ";
            DataTable dt;
            string errInfo;
            List<SqlParameter> para=new List<SqlParameter>();
            para.Add(new SqlParameter("@customerID",Convert.ToString(Session["qy_customersid"])));
            para.Add(new SqlParameter("@SystemID", xtid));
           
            using (LiLanzDALForXLM dal = new LiLanzDALForXLM(DBConStr))
            {
                errInfo = dal.ExecuteQuerySecurity(mySql, para, out dt);
            }
            
            if (errInfo != "")
            {
                clsSharedHelper.WriteInfo(errInfo + "请稍后再试，或联系IT人员！");
            }
            else
            {
                HaveBan = Convert.ToString(dt.Rows[0]["bs"]);
            }
        }
        
    }
</script>

<html xmlns="http://www.w3.org/1999/xhtml">
<head id="Head1" runat="server">
    <meta charset="UTF-8" />
    <meta name="viewport" content="width=device-width,initial-scale=1,user-scalable=0" />
    <title>系统身份认证</title>
    <link rel="stylesheet" href="../../res/css/weui.css"/>
    <link rel="stylesheet" href="../../res/css/BandToSystem/example.css"/>
    <link rel="stylesheet" href="../../res/css/sweet-alert.css" />
    <script type="text/javascript" src="../../res/js/jquery.js"></script>
    <script type="text/javascript" src="../../res/js/sweet-alert.min.js"></script>
</head>
<body>
    <form id="form1" runat="server">
    <input id="xtid" type="hidden" value="<%=xtid %>" style=" display:none"   />
    <input id="h_cname" type="hidden" value="<%=username %>" style=" display:none"   />
    <input id="h_phoneNo" type="hidden" value="<%=phoneNo %>" style=" display:none"   />
    <input id="h_status" type="hidden" value="<%=status %>" style=" display:none"   />
    <input id="h_closePag" type="hidden" value="<%=ClosePag %>" style=" display:none"   />
    <input id="h_HaveBand" type="hidden" value="<%=HaveBan %>" style=" display:none"   />
     <div class="hd">
                <h1 class="page_title">微信系统绑定</h1>
         </div>
     <div class="weui_cells_title">基本信息</div>
         <div class="weui_cells weui_cells_form">
                    <div class="weui_cell">
                        <div class="weui_cell_hd"><label class="weui_label">姓名</label></div>
                        <div class="weui_cell_bd weui_cell_primary">
                            <input class="weui_input" type="text" id="cname"  placeholder="请输入姓名" value="<%=username %>" />
                        </div>
                    </div>
                   
                    <div class="weui_cell">
                        <div class="weui_cell_hd"><label class="weui_label">手机</label></div>
                        <div class="weui_cell_bd weui_cell_primary">
                            <input class="weui_input" type="number" id="phoneNo" placeholder="请输入手机号码"  value="<%=phoneNo %>"  />
                        </div>
                    </div>
         </div>

       <div class="weui_cells_title" id="xt_title" style=" display:none">协同验证信息</div>
         <div class="weui_cells weui_cells_form" id="xt_list" style=" display:none" >
                   <div class="weui_cell" >
                        <div class="weui_cell_hd"><label class="weui_label">用户名</label></div>
                        <div class="weui_cell_bd weui_cell_primary">
                            <input class="weui_input" type="text" id="xt_user" placeholder="请输入协同账号"/>
                        </div>
                    </div>
                   
                    <div class="weui_cell">
                        <div class="weui_cell_hd"><label class="weui_label">密码</label></div>
                        <div class="weui_cell_bd weui_cell_primary">
                            <input class="weui_input" type="password" id="xt_pwd" placeholder="请输入账号密码"/>
                        </div>
                    </div>
         </div>

         <div class="weui_cells_title" id="rz_title" style=" display:none">人资信息</div>
         <div class="weui_cells weui_cells_form" id="rz_list" style=" display:none" >
                   <div class="weui_cell" >
                        <div class="weui_cell_hd"><label class="weui_label">身份证</label></div>
                        <div class="weui_cell_bd weui_cell_primary">
                            <input class="weui_input" type="text" id="rz_sfz" placeholder="请输入身份证号"/>
                        </div>
                    </div>
                   
         </div>

         <div class="weui_cells_title" id="gys_title" style=" display:none">人资信息</div>
         <div class="weui_cells weui_cells_form" id="zz_list" style=" display:none" >
                   <div class="weui_cell" >
                        <div class="weui_cell_hd"><label class="weui_label">公司名称</label></div>
                        <div class="weui_cell_bd weui_cell_primary">
                            <input class="weui_input" type="text" id="gys_name" placeholder="请输入公司名称"/>
                        </div>
                    </div> 
         </div>

         <div class="weui_cells_title" id="card_title" style=" display:none">工卡信息</div>
         <div class="weui_cells weui_cells_form" id="card_list" style=" display:none" >
                   <div class="weui_cell" >
                        <div class="weui_cell_hd"><label class="weui_label">工号</label></div>
                        <div class="weui_cell_bd weui_cell_primary">
                            <input class="weui_input" type="number" id="job_number" placeholder="请输入您的工号"/>
                        </div>
                    </div> 
         </div>
         <div class="weui_cells_tips"> </div>
        <div class="weui_btn_area">
            <a class="weui_btn weui_btn_primary" href="javascript:confirmPhoneNo()">身份认证</a>
        </div><br />

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
                    <p class="weui_toast_content">处理中</p>
                </div>
            </div>

    </form>
     <script type="text/javascript">

         function confirmPhoneNo() {
             var phoneNo = $("#phoneNo").val();
             if (phoneNo == "") {
                 swal("电话号码不能空");
                 return;
             }
             swal({ title: "很重要的提示！",
                 text: "请确保号码(" + phoneNo + ")可以接收验证码,如号码有误,必须先联系人资修改！号码能收短信选'确认'，否则'取消'",
                 type: "warning",
                 showCancelButton: true,
                 confirmButtonColor: "#04be02",
                 confirmButtonText: "确认",
                 cancelButtonText: "取消",
                 closeOnConfirm: false,
                 closeOnCancel: true
             },
                    function (isConfirm) {
                        if (isConfirm) {
                            MyFunc_submit();
                        }
                        else {
                            WeixinJSBridge.call('closeWindow'); 
                         return; }
                    });
         }
         function MyFunc_submit() {
             var xtid = $("#xtid").val();
             var cname = $("#cname").val().replace(/[\r\n]/g, "").replace(/[ ]/g, "");
             var phoneNo = $("#phoneNo").val().replace(/[\r\n]/g, "").replace(/[ ]/g, "");

             var xt_user = $("#xt_user").val().replace(/[\r\n]/g, "").replace(/[ ]/g, "");
             var xt_pwd = $("#xt_pwd").val().replace(/[\r\n]/g, "").replace(/[ ]/g, "");

             var rz_sfz = $("#rz_sfz").val().replace(/[\r\n]/g, "").replace(/[ ]/g, "");

             var job_number = $("#job_number").val().replace(/[\r\n]/g, "").replace(/[ ]/g, "");
             if (cname == "") {
                 swal("姓名不能为空！");
                 return;
             }
             if (phoneNo == "") {
                 swal("电话号码不能空");
                 return;
             }

             if (xtid == "3" || xtid == "4") {
                 if (rz_sfz == "" || rz_sfz.length < 18) {
                     swal("请输入正确的身份证信息");
                     return;
                 }
             }

             $("#loadingToast").show() ;
             $.ajax({
                 type: "POST",
                 url: "qywxInterface.aspx",
                 contentType: "application/x-www-form-urlencoded; charset=utf-8",
                 data: { ctrl: "bandSystem", SystemID: xtid, cname: cname, phoneNo: phoneNo, xt_user: xt_user, xt_pwd: xt_pwd, rz_sfz: rz_sfz, job_number: job_number },
                 success: function (data) {
                     $("#loadingToast").hide();
                     if (data.indexOf("Successed") >= 0) {
                         clearInterval(int);
                         swal({ title: "绑定成功!",
                             text: "点击确认按钮离开",
                             type: "success",
                             confirmButtonColor: "#04be02",
                             confirmButtonText: "确认",
                             closeOnConfirm: false
                         },
                              function () {
                                  // WeixinJSBridge.call('closeWindow');
                                  if ($("#h_status").val() == "0" || $("#h_status").val() == "4") {
                                      window.location.href = "QY2code.aspx";
                                  } else if ($("#h_closePag").val() == "1") {
                                      WeixinJSBridge.call('closeWindow');
                                  } else {
                                      window.location.href = "WXSystemGuide.aspx";
                                  }
                              });
                     } else {
                         if (data.indexOf("type1") >= 0) {//本地已存在用户
                             swal({ title: "出错了",
                                 text: data.replace("type1|",""),
                                 type: "error",
                                 confirmButtonColor: "#DD6B55",
                                 confirmButtonText: "确认",
                                 closeOnConfirm: true
                             },
                              function () {
                                  window.location.href = "QY2code.aspx";
                              });
                         } else {
                             swal({ title: "出错了",
                                 text: data,
                                 type: "error",
                                 confirmButtonColor: "#DD6B55",
                                 confirmButtonText: "确认",
                                 closeOnConfirm: true
                             },
                              function () {
                                  //  WeixinJSBridge.call('closeWindow');
                              });
                         }
                        
                     }

                 },
                 error: function (XMLHttpRequest, textStatus, errorThrown) {
                     swal({ title: "错误",
                         text: errorThrown.toString(),
                         type: "error",
                         confirmButtonColor: "#DD6B55",
                         confirmButtonText: "确认",
                         closeOnConfirm: false
                     },
                              function () {
                                  WeixinJSBridge.call('closeWindow');
                              });
                 }
             });
         }
         $(document).ready(function () {

             if ($("#h_HaveBand").val() != "0") {
                 swal({ title: "提示",
                     text: "该系统您已认证，无须再认证;请用 " + $("#h_phoneNo").val() + " 此号码获取微信验证码,如号码有误,请联系人资修改！。",
                     type: "warning",
                     confirmButtonColor: "#DD6B55",
                     confirmButtonText: "确认",
                     closeOnConfirm: true
                 },
                    function () {
                        window.location.href = "QY2code.aspx";
                        $(".weui_btn_area").hide();
                      //  WeixinJSBridge.call('closeWindow');
                    });
             }
             var xtid = document.getElementById("xtid").value;
             switch (xtid) {
                 case "1":
                     $("#xt_title").show();
                     $("#xt_list").show();
                     $(".page_title").html("协同系统");
                     break;
                 case "2": ;
                     $("#rz_title").show();
                     $("#rz_list").show();
                     $(".page_title").html("人资系统");
                     break;
                 case "3":
                     $("#rz_title").show();
                     $("#rz_list").show();
                     //                     $("#phoneNo").val("13542644654");
                     //                     $("#cname").val("方玉结");
                     //                     $("#rz_sfz").val("441701198705260026");
                     $(".page_title").html("全渠道系统");
                     $(".weui_cells_tips").html("说明：</br>1、请输入ERP系统中的上述信息以便激活系统;</br><font color='red'>2、请确认输入的手机号码可以正常收到验证码;</font></br>3、如果您输入的信息不正确，将不能进入系统。请与上述信息的档案管理人员（通常是人资专员）进行信息确认。");
                     break;
                 case "4":
                     //$("#gys_title").show();
                     //$("#gys_list").show();
                     //$(".page_title").html("供应商系统");
                     $("#rz_title").show();
                     $("#rz_list").show();
                     //$("#phoneNo").val("18965687300");
                     //$("#cname").val("陈清格");
                     //$("#rz_sfz").val("350582198305160039");
                     $(".page_title").html("制造公司系统");
                     $(".weui_cells_tips").html("说明：</br>1、请输入ERP系统中的上述信息以便激活系统;</br><font color='red'>2、请确认输入的手机号码可以正常收到验证码;</font></br>3、如果您输入的信息不正确，将不能进入系统。请与上述信息的档案管理人员（通常是人资专员）进行信息确认。");
                     break;
                 case "5":
                     $("#card_title").show();
                     $("#card_list").show();
                     $(".page_title").html("工卡系统");
                     $(".weui_cells_tips").html("说明：</br>1、请输入上述信息以便激活系统;</br>2、如果您输入的信息不正确，将不能进入系统。请与上述信息的档案管理人员（通常是人资专员）进行信息确认。");
                     break;
                 case "6":
                     $("#rz_title").html("参会信息");
                     $("#rz_title").show();
                     $("#rz_list").show();
                     //                     $("#phoneNo").val("13542644654");
                     //                     $("#cname").val("方玉结");
                     //                     $("#rz_sfz").val("441701198705260026");
                     $(".page_title").html("订货会系统");

                     $(".weui_cells_tips").html("说明：</br>1、请输入参会信息以便激活系统;</br>2、如果您输入的信息不正确，将不能进入系统。请与参会信息的档案管理人员进行信息确认。");
                     break;
             }
             $("#phoneNo").keypress(function (event) {
                 var keyCode = event.which;
                 if (keyCode == 46 || (keyCode >= 48 && keyCode <= 57))
                     return true;
                 else
                     return false;
             }).focus(function () {
                 this.style.imeMode = 'disabled';
             });

         });
    function LinkInterface() {
        $.ajax({
            type: "POST",
            url: "qywxInterface.aspx",
            contentType: "application/x-www-form-urlencoded; charset=utf-8",
            data: { ctrl: "link" },
            success: function (data) {
                if (data.indexOf("Error") >= 0) {
                    clearInterval(int);
                    swal({ title: "错误",
                        text: data,
                        type: "error",
                        confirmButtonColor: "#DD6B55",
                        confirmButtonText: "确认",
                        closeOnConfirm: false
                    },
                        function () {
                            WeixinJSBridge.call('closeWindow');
                        });
                }
            },
            error: function (XMLHttpRequest, textStatus, errorThrown) {
                clearInterval(int);
                swal({ title: "错误",
                    text: errorThrown.toString(),
                    type: "error",
                    confirmButtonColor: "#DD6B55",
                    confirmButtonText: "确认",
                    closeOnConfirm: false
                },
                    function () {
                        WeixinJSBridge.call('closeWindow');
                    });
            }
        });
    }
    var int = setInterval("LinkInterface()", 60000);
     </script>
</body>
</html>
