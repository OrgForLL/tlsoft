<%@ Page Language="C#" Debug="true" %> 
<%@ Import Namespace="nrWebClass" %>  
<%@ Import Namespace="System.Collections.Generic" %>

<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">

<script runat="server">

    private const string ConfigKeyValue = "7";	//微信配置信息索引值 
    public List<string> wxConfig;       //微信OPEN_JS 动态生成的调用参数
    protected void Page_Load(object sender, EventArgs e)
    {
        //获取ACCESS_TOKEN 的写法
        //string AccessToken = clsWXHelper.GetAT(ConfigKeyValue);
        //Response.Write("AccessToken=" + AccessToken);

        //获取用户鉴权的方法:该方法要求用户必须已成功关注企业号，主要是用于获取Session["qy_customersid"] 和其他登录信息 

        //Session["qy_customersid"] = "19";       //写死成 薛灵敏的账户ID ，可以跳过鉴权。方便测试
        //if (clsWXHelper.CheckQYUserAuth(true))
        //{
        //    ////clsSharedHelper.WriteInfo("鉴权成功！qy_customersid = " + Session["qy_customersid"]);

        //    //鉴权成功之后，获取 系统身份SystemKey
        //    string SystemID = "3";      //全渠道系统的ID
        //    string SystemKey = clsWXHelper.GetAuthorizedKey(Convert.ToInt32(SystemID));
        //    clsSharedHelper.WriteInfo(string.Format("SystemKey={0} tzid={1} mdid={2}", 
        //                SystemKey, Session["tzid"], Session["mdid"]));
        //} 

        //获取用户鉴权的方法:该方法不要求用户成功关注企业号，主要是用于获取Session["qy_OpenId"]
        //if (clsWXHelper.CheckQYUserAuth(false))
        //{
        //    clsSharedHelper.WriteInfo(string.Concat("鉴权成功！qy_customersid = ", Session["qy_customersid"], " | qy_OpenId = ", Session["qy_OpenId"]));
        //}
        //else
        //{
        //    clsSharedHelper.WriteInfo("鉴权失败！");
        //}

        //这个方法用于获取JS_API的激活信息，目前企业号和公众号 都支持
        wxConfig = clsWXHelper.GetJsApiConfig(ConfigKeyValue);

        //这个方法用于获取公众号鉴权信息
        //if (clsWXHelper.CheckUserAuth(ConfigKeyValue, "vipid"))
        //{
        //    //鉴权成功之后，获取 系统身份SystemKey 
        //    clsSharedHelper.WriteInfo(string.Concat("鉴权成功！openid = ", Session["openid"], " | vipid = ", Session["vipid"]));
        //}

        //统一的后台错误输出方法
        //clsWXHelper.ShowError("错误提示内容123456，自定义内容");

        ////第一步
        //string QY_ACCESSTOKEN = clsWXHelper.GetAT("1");     //1是企业号
        
        ////第二步 2.1
        //string JSON = clsNetExecute.HttpRequest("URL地址 替换 QY_ACCESSTOKEN");         //JSON中就包含了ticket
        
        ////2.2 解析JSON
        //clsJsonHelper jh = clsJsonHelper.CreateJsonHelper(JSON);
        //string ticket = jh.GetJsonValue("ticket");      //如果ticket为空，表示不包含它

        ////第三步是签名 拿着ticket 得到  signature

        ////第四步，使用signature调用你的方法。
        
        


        
        
    }
</script>

<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <title>订货会报名</title>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width,height=device-height, initial-scale=1.0, minimum-scale=1.0, maximum-scale=1.0, user-scalable=0"/>
    <link rel="stylesheet" href="../../res/css/weui.css"/> 
    <link rel="stylesheet" href="../../res/css/Meeting/example.css"/> 
    <script type="text/javascript" src="../../res/js/jquery.js"></script> 
    <%--<script type="text/javascript" src="../js/zepto.js"></script>  --%>
    <script type="text/javascript" src="../../res/js/jweixin-1.0.0.js"></script>
<style>
    
.page_title {
  text-align: center;
  font-size: 34px;
  color: #3CC51F;
  font-weight: 400;
  margin: 0 15%;
}

.page_desc {
  text-align: center;
  color: #888;
  font-size: 14px;
}
</style>

</head>
<body ontouchstart >
    <form id="form1" runat="server">
        <div class="container js_container">
            <div class="page">
                <div class="hd">
                    <h1 class="page_title">微信报名</h1>
                    <p class="page_desc">订货会参会人员信息确认</p>
                </div>
                <div class="bd">   
                    <div class="weui_cells weui_cells_form">
                        <div class="weui_cell">
                            <div class="weui_cell_hd"><label class="weui_label">手机号</label></div>
                            <div class="weui_cell_bd weui_cell_primary">
                                <input class="weui_input" type="text" placeholder="请输入手机号码" value=""/>
                            </div>
                        </div>
                        <div class="weui_btn_area">
                            <a class="weui_btn weui_btn_primary" href="javascript:CheckPhone();">确认</a>
                        </div> 
                    </div>
                </div>
            
                <div class="bd" style="display:none" id="divInfo">   
                    <div class="weui_cells_title">您的报名信息</div>
                    <div class="weui_cells">
                        <div class="weui_cell">
                            <div class="weui_cell_bd weui_cell_primary">
                                <p>姓名</p>
                            </div>
                            <div class="weui_cell_ft">
                                张三丰
                            </div>
                        </div>
                        <div class="weui_cell">
                            <div class="weui_cell_bd weui_cell_primary">
                                <p>身份证</p>
                            </div>
                            <div class="weui_cell_ft">
                                3505**********2137
                            </div>
                        </div>
                    </div>
                    <div class="weui_cells_title">请注意：如果报名信息有误，请及时联系理单人员；若信息无误，请输入手机验证码后点击确认提交！</div>                    
                    <div class="weui_btn_area">
                        <a class="weui_btn weui_btn_primary" href="javascript:SubmitOK();"  data-id="msg">确认提交</a>
                    </div>
                    <br/>
                </div> 
            </div>

            
            <!--BEGIN toast-->
            <div id="toast" style="display: none;">
                <div class="weui_mask_transparent"></div>
                <div class="weui_toast">
                    <i class="weui_icon_toast"></i>
                    <p class="weui_toast_content">[提醒内容]</p>
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
        </div> 
    </form> 

    <script type="text/html" id="tpl_msg"> 
        <div class="page">
            <div>
                <h1 class="page_title">报名成功</h1>
            </div>
            <div>
                <div class="weui_msg" style="padding-top:0;">
                    <div class="weui_icon_area"><img src="../../res/img/Meeting/touchLilanz.jpg" alt="" /></div>
                    <div class="weui_text_area">
                        <h2 class="weui_msg_title">长按二维码识别</h2> 
                        <p class="weui_msg_desc">更多便利服务请关注“利郎企业号”</p>
                    </div> 
                    <div class="weui_extra_area">
                        注：关注企业号时可能需要手机号码验证！
                    </div>
                </div>
            </div>
            <br/>
        </div>
    </script>


     
     <script>

         //以下是实现微信的JSAPI
        wx.config({
            debug: true, // 开启调试模式,调用的所有api的返回值会在客户端alert出来，若要查看传入的参数，可以在pc端打开，参数信息会通过log打出，仅在pc端时才会打印。
            appId: '<%= wxConfig[0] %>', // 必填，企业号的唯一标识，此处填写企业号corpid
            timestamp: '<%= wxConfig[1] %>', // 必填，生成签名的时间戳
            nonceStr: '<%= wxConfig[2] %>', // 必填，生成签名的随机串
            signature: '<%= wxConfig[3] %>',// 必填，签名，见附录1
            jsApiList: ['chooseImage', 'downloadVoice'] // 必填，需要使用的JS接口列表，所有JS接口列表见附录2
        });

        wx.ready(function(){
            // config信息验证后会执行ready方法，所有接口调用都必须在config接口获得结果之后，config是一个客户端的异步操作，所以如果需要在页面加载时就调用相关接口，则须把相关接口放在ready函数中调用来确保正确执行。对于用户触发时才调用的接口，则可以直接调用，不需要放在ready函数中。
            alert("JSAPI注入成功！");

//            wx.chooseImage({
//                count: 1, // 默认9
//                sizeType: ['original', 'compressed'], // 可以指定是原图还是压缩图，默认二者都有
//                sourceType: ['album', 'camera'], // 可以指定来源是相册还是相机，默认二者都有
//                success: function (res) {
//                    var localIds = res.localIds; // 返回选定照片的本地ID列表，localId可以作为img标签的src属性显示图片
//                    alert(localIds);
////                    $("#img0").attr("src",localIds);                    
//                }
//            });
        });
        wx.error(function(res){
            alert("JSAPI注入失败！");
            // config信息验证失败会执行error函数，如签名过期导致验证失败，具体错误信息可以打开config的debug模式查看，也可以在返回的res参数中查看，对于SPA可以在这里更新签名。
            alert(res);
        });



        //以下是业务逻辑的具体实现

         function CheckPhone() {
            //验证电话号码是否正确 
//             $('#loadingToast').show();
//             setTimeout(function () {
//                 $('#loadingToast').hide();
//                 $("#divInfo").css("display", "block");
             //             }, 500);
             var sid = $('.weui_input').val();

             alert(sid);

             wx.downloadVoice({
                 serverId: sid, // 需要下载的音频的服务器端ID，由uploadVoice接口获得
                 isShowProgressTips: 1, // 默认为1，显示进度提示
                 success: function (res) {
                     alert("下载语音成功！localId=" + res.localId);
                     var localId = res.localId; // 返回音频的本地ID
                 }
             });


         }

         function SubmitOK() {
            //创建（更新）参会人员档案到参会人员档案表中

            //创建（更新）用户信息，并同步到通信录

             //创建授权信息

             //弹出提示 
             $('#loadingToast').show();
             setTimeout(function () {
                 $('#loadingToast').hide();
                 showOKMsg();
             }, 500);
         }

         var stack = [];
         var $container = $('.js_container');
         function showOKMsg() {
             var id = "msg"; 
             var $tpl = $($('#tpl_' + id).html()).addClass('slideIn').addClass(id);
             $container.append($tpl);
             stack.push($tpl);
             history.pushState({ id: id }, '', '#' + id);

             $($tpl).on('webkitAnimationEnd', function () {
                 $(this).removeClass('slideIn');
             }).on('animationend', function () {
                 $(this).removeClass('slideIn');
             });
         }


         // webkit will fired popstate on page loaded
         $(window).on('popstate', function () { 
             var $top = stack.pop();
             if (!$top) {
                 return;
             }
             $top.addClass('slideOut').on('animationend', function () {
                 $top.remove();
             }).on('webkitAnimationEnd', function () {
                 $top.remove();
             });
         });
           
             
     </script>

</body>
</html>
