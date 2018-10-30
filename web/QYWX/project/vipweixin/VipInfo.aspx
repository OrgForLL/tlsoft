<%@ Page Language="C#" %>
<%@ Import Namespace="System.Data" %>
<%@ Import Namespace = "System.Collections.Generic" %>
<%@ Import Namespace="System.Data.SqlClient" %>
<%@ Import Namespace = "nrWebClass" %>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">


<script runat="server">
   public string cid;
   public string sid;
   public string FaceImage = "img/initial_img.png";
   public string khmd = "";
   public string khlb = "";
   public string birthday = "2000-01-01";
   private const string ConfigKeyValue = "5";
   public string openid = "";
    protected void Page_Load(object sender, EventArgs e)
    {

        sid = Convert.ToString(Request.QueryString["sid"]);
        if (clsWXHelper.CheckUserAuth(ConfigKeyValue, "openid"))
        {
            openid = Convert.ToString(Session["openid"]);

        }
    }
</script>


<html xmlns="http://www.w3.org/1999/xhtml">
<head id="Head1" runat="server">
    <title>个人信息</title>
    <meta name="viewport" content="width=device-width, initial-scale=1.0, user-scalable=no,maximum-scale=1.0,minimum-scale=1.0" />
    <meta http-equiv="Expires" content="0" />
    <meta http-equiv="Progma" content="no-cache" />
    <meta http-equiv="cache-control" content="no-cache,must-revalidate" />
    <link rel="stylesheet" href="../../res/css/sweet-alert.css" />
    <script type="text/javascript" src="../../res/js/jquery.js"></script>
    <script type="text/javascript" src="../../res/js/sweet-alert.min.js"></script>
    <link rel="stylesheet" href="../../res/css/weui.min.css" />
    <link rel="stylesheet" href="../../res/css/StoreSaler/weui_example.css" />
    <style type="text/css">

    </style>
</head>
<body>
    <div class="container js_container">
        <div class="page">
            <div class="hd">
                <h1 class="page_title">
                    个人信息</h1>
            </div>
            <div class="bd">
                <div class="weui_cells weui_cells_form">
                    <div class="weui_cell">
                        <div class="weui_cell_hd">
                            <label class="weui_label">姓名</label>
                        </div>
                        <div class="weui_cell_bd weui_cell_primary">
                            <input class="weui_input" id="name" type="text" placeholder="请输入姓名" style="height: 1.5em;" />
                        </div>
                    </div>
                </div>

                    <div class="weui_cell weui_cell_select weui_select_after">
                        <div class="weui_cell_hd" >
                            <label class="weui_label">性别</label>
                        </div>
                        <div class="weui_cell_bd weui_cell_primary">
                            <select class="weui_select" id="xb" >
                                <option value="0">男</option>
                                <option value="1">女</option>
                            </select>
                        </div>
                    </div>
                </div>

                <div class="weui_cells weui_cells_form">
                    <div class="weui_cell">
                        <div class="weui_cell_hd">
                            <label class="weui_label">生日</label>
                        </div>
                        <div class="weui_cell_bd weui_cell_primary">
                            <input class="weui_input" id="birthday" type="date" placeholder="请选择出生日期" style="height: 2em;" />
                        </div>
                    </div>
                </div>





                <div class="weui_cells weui_cells_form">
                    <div class="weui_cell">
                        <div class="weui_cell_hd">
                            <label class="weui_label">手机</label>
                        </div>
                        <div class="weui_cell_bd weui_cell_primary">
                            <input class="weui_input" id="phone" type="text" placeholder="请输入手机号" style="height: 1.5em;" />
                        </div>
                    </div>
                </div>

                <div class="bd spacing" style="margin-top: 10px; text-align: center;">
                <div class="button_sp_area">
                    <a href="javascript:;" id="SaveSend" class="weui_btn  weui_btn_primary" style="width: 45%; display: inline-block; margin-right: 15px;">保存提交</a>
                    <a href="javascript:;" id="Save" class="weui_btn  weui_btn_default" style="width: 45%; display: inline-block;">保存草稿</a>
                </div>
            </div>
            </div>
        </div>
    </div>


    <!--end toast-->
    <!-- loading toast -->
    <!--加载动画-->
    <div id="bottom">
    	<h1>利郎信息技术部提供技术支持</h1>
    </div>
    <div id="loadingToast" class="weui_loading_toast" style="display: none;">
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





<%--    <script type="text/javascript" src="js/LocalResizeIMG.js"></script>
    <script type="text/javascript" src="js/mobileBUGFix.mini.js"></script>--%>
    <script type="text/javascript">
        function dialog2() {
            $("#dialog2").hide();
        }
        $(document).ready(function (e) {
            $("#loadingToast").show();

            $("#loadingToast").css("display", "none");
            $("#Save").click(function (e) {
                //alert(1);
                var name = $("#name").val();
                var birthday = $("#birthday").val();
                var xb = $("#xb").val();
                var phone = $("#phone").val();
                var sid = <%=sid %>;
                var openid = <%= openid %>;
                //alert(birthday);
                if (name == "") {
                    $("#dialog2Title").html("无法获取个人信息！");
                    $("#dialog2Text").html("请填写姓名！");
                    $("#dialog2").show();
                    return false;
                } else if (phone == "" || phone == "0") {
                    $("#dialog2Title").html("还未填写手机号码！");
                    $("#dialog2Text").html("请重新填写手机号码！");
                    $("#dialog2").show();
                    return false;
                } else if (phone.length != 11 || phone.indexOf("1") != 0) {
                    $("#dialog2Title").html("您输入的手机号码不合法！");
                    $("#dialog2Text").html("请重新填写手机号码！");
                    $("#dialog2").show();
                    return false;
                }

                $.ajax({
                    type: "POST",
                    url: "ProPage.aspx",
                    contentType: "application/x-www-form-urlencoded; charset=utf-8",
                    data: { ctrl: "SaveInfo", name: name, xb: xb, birthday: birthday, phone: phone, cid: sid,openid:openid },
                    success: function (msg) {
                        if (msg.indexOf("Successed") >= 0) {
                            msg = msg.replace(/Successed\|/g, "");
                            $('#toast').show();
                            setTimeout(function () {
                                $('#toast').hide();
                            }, 5000);
                        } else {
                            $("#dialog2Title").html("出错啦");
                            $("#dialog2Text").html(msg);
                            $("#dialog2").show();
                        }
                        alert(msg);
                    },
                    error: function (XMLHttpRequest, textStatus, errorThrown) {
                        $("#dialog2Title").html("出错啦");
                        $("#dialog2Text").html(errorThrown.toString());
                        $("#dialog2").show();
                    }
                });
            });
        })

    </script>
</body>
</html>
