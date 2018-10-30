<%@ Page Language="C#" Debug="true" %> 
<%@ Import Namespace="nrWebClass" %>  
<%@ Import Namespace="System.Collections.Generic" %>

<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">

<script runat="server">

    private const string ConfigKeyValue = "1";	//微信配置信息索引值 
    public List<string> wxConfig;       //微信OPEN_JS 动态生成的调用参数
    public string groupId;
    public string ticket;
    string signature;
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

        //获取accessToken
        string accessToken = clsWXHelper.GetAT(ConfigKeyValue);     //1是企业号
        if (string.IsNullOrEmpty(accessToken))
        {
            clsWXHelper.ShowError("获取accessToken失败！");
            return;
        }
        //Response.Write(accessToken);
        //获取ticket
        string url = "https://qyapi.weixin.qq.com/cgi-bin/ticket/get?access_token=" + accessToken + "&type=contact";
        string json = clsNetExecute.HttpRequest(url);         //JSON中就包含了ticket
        clsJsonHelper jh = clsJsonHelper.CreateJsonHelper(json);
        if (jh == null)
        {
            clsWXHelper.ShowError("获取json失败！");
            return;
        }
        //Response.Write(json);
        ticket = jh.GetJsonValue("ticket");      //如果ticket为空，表示不包含它
        if (string.IsNullOrEmpty(ticket))
        {
            clsWXHelper.ShowError("获取ticket失败！");
            return;
        }
        //Response.Write(ticket);
        //获取signature
        string strTmp = string.Concat("group_ticket=" + ticket, "&noncestr=" + wxConfig[2], "&timestamp=" + wxConfig[1], "&url=" + Request.Url.AbsoluteUri);
        signature = FormsAuthentication.HashPasswordForStoringInConfigFile(strTmp, "sha1");
        //Response.Write(signature);
        //获取groupId
        groupId = jh.GetJsonValue("group_id");
        if (string.IsNullOrEmpty(groupId))
        {
            clsWXHelper.ShowError("获取groupID失败！");
            return;
        }
        


    }

</script>

<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <title>企业号群聊</title>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width,height=device-height, initial-scale=1.0, minimum-scale=1.0, maximum-scale=1.0, user-scalable=0"/>
    <link rel="stylesheet" href="../../res/css/weui.css"/> 
    <link rel="stylesheet" href="../../res/css/Meeting/example.css"/> 
    <script type="text/javascript" src="../../res/js/jquery.js"></script> 
    <%--<script type="text/javascript" src="../js/zepto.js"></script>  --%>
    <script type="text/javascript" src="../../res/js/jweixin-1.1.0.js"></script>
</head>
<body ontouchstart>
    <form id="form1" runat="server">
        <br/>
        <div class="weui_btn_area">
            <a class="weui_btn weui_btn_primary" href="javascript:wx.closeWindow()">关闭</a>
        </div>
    </form>
    <script type="text/javascript">

        //以下是实现微信的JSAPI
        wx.config({
            debug: false, // 开启调试模式,调用的所有api的返回值会在客户端alert出来，若要查看传入的参数，可以在pc端打开，参数信息会通过log打出，仅在pc端时才会打印。
            appId: '<%= wxConfig[0] %>', // 必填，企业号的唯一标识，此处填写企业号corpid
            timestamp: '<%= wxConfig[1] %>', // 必填，生成签名的时间戳
            nonceStr: '<%= wxConfig[2] %>', // 必填，生成签名的随机串
            signature: '<%= wxConfig[3] %>',// 必填，签名，见附录1
            jsApiList: ['openEnterpriseContact', 'openEnterpriseChat'] // 必填，需要使用的JS接口列表，所有JS接口列表见附录2
        });

        wx.ready(function () {
            // config信息验证后会执行ready方法，所有接口调用都必须在config接口获得结果之后，config是一个客户端的异步操作，所以如果需要在页面加载时就调用相关接口，则须把相关接口放在ready函数中调用来确保正确执行。对于用户触发时才调用的接口，则可以直接调用，不需要放在ready函数中。
            //alert("JSAPI注入成功！");

            //====================================test open ent chat===========================================
            /*alert("before");
            wx.openEnterpriseChat({
                userIds: 'linwy;liyibin;',    // 必填，参与会话的成员列表。格式为userid1;userid2;...，用分号隔开，最大限制为1000个。userid单个时为单聊，多个时为群聊。
                //userIds: ["linwy","liyibin","chenyh"],    // 必填，参与会话的成员列表。格式为userid1;userid2;...，用分号隔开，最大限制为1000个。userid单个时为单聊，多个时为群聊。
                groupName: '讨论组',  // 必填，会话名称。单聊时该参数传入空字符串""即可。
                success: function (res) {
                    // 回调
                    alert("创建成功！");
                },
                fail: function (res) {
                    alert(res);
                    if (res.errMsg.indexOf('function not exist') > 0) {
                        alert('版本过低请升级')
                    }
                }
            });
            alert("over");*/
            //====================================test open ent chat===========================================
            //wx.closeWindow();
            /*setTimeout(function () {
                //wx.closeWindow();
                openEntCont();
            }, 1000);*/
            //wx.closeWindow();
            openEntCont();
            //alert("func over");
            //window.close();
            //wx.closeWindow();
        });

        wx.error(function (res) {
            alert("JSAPI注入失败！");
            // config信息验证失败会执行error函数，如签名过期导致验证失败，具体错误信息可以打开config的debug模式查看，也可以在返回的res参数中查看，对于SPA可以在这里更新签名。
            alert(res);
        });

        //打开企业通讯录选人
        function openEntCont() {
            var evalWXjsApi = function (jsApiFun) {
                if (typeof WeixinJSBridge == "object" && typeof WeixinJSBridge.invoke == "function") {
                    jsApiFun();
                } else {
                    document.attachEvent && document.attachEvent("WeixinJSBridgeReady", jsApiFun);
                    document.addEventListener && document.addEventListener("WeixinJSBridgeReady", jsApiFun);
                }
            }

            evalWXjsApi(function () {
                WeixinJSBridge.invoke("openEnterpriseContact", {
                    "groupId": "<%= groupId %>",    // 必填，管理组权限验证步骤1返回的group_id
                        "timestamp": "<%= wxConfig[1] %>",    // 必填，管理组权限验证步骤2使用的时间戳
                        "nonceStr": "<%= wxConfig[2] %>",    // 必填，管理组权限验证步骤2使用的随机字符串
                        "signature": "<%= signature %>",  // 必填，管理组权限验证步骤2生成的签名
                        "params": {
                            'departmentIds': [2],    // 非必填，可选部门ID列表（如果ID为0，表示可选管理组权限下所有部门）
                            'tagIds': [0],    // 非必填，可选标签ID列表（如果ID为0，表示可选所有标签）
                            'userIds': [],    // 非必填，可选用户ID列表
                            'mode': 'multi',    // 必填，选择模式，single表示单选，multi表示多选
                            'type': ['user'],    // 必填，选择限制类型，指定department、tag、user中的一个或者多个
                            'selectedDepartmentIds': [],    // 非必填，已选部门ID列表
                            'selectedTagIds': [],    // 非必填，已选标签ID列表
                            'selectedUserIds': [],    // 非必填，已选用户ID列表
                        },
                    }, function (res) {
                        if (res.err_msg.indexOf('function_not_exist') > 0) {
                            alert('版本过低请升级');
                            //wx.closeWindow();
                            return;
                        } else if (res.err_msg.indexOf('openEnterpriseContact:fail') > 0) {
                            //wx.closeWindow();
                            return;
                        }
                        var result = JSON.parse(res.result);    // 返回字符串，开发者需自行调用JSON.parse解析
                        var selectAll = result.selectAll;     // 是否全选（如果是，其余结果不再填充）
                        if (!selectAll) {
                            var selectedDepartmentList = result.departmentList;    // 已选的部门列表
                            for (var i = 0; i < selectedDepartmentList.length; i++) {
                                var department = selectedDepartmentList[i];
                                var departmentId = department.id;    // 已选的单个部门ID
                                var departemntName = department.name;    // 已选的单个部门名称
                            }
                            var selectedTagList = result.tagList;    // 已选的标签列表
                            for (var i = 0; i < selectedTagList.length; i++) {
                                var tag = selectedTagList[i];
                                var tagId = tag.id;    // 已选的单个标签ID
                                var tagName = tag.name;    // 已选的单个标签名称
                            }
                            var selectedUserList = result.userList;    // 已选的成员列表
                            var userIds = "";   //所有用户id字符串
                            for (var i = 0; i < selectedUserList.length; i++) {
                                var user = selectedUserList[i];
                                var userId = user.id;    // 已选的单个成员ID
                                var userName = user.name;    // 已选的单个成员名称
                                //alert(userId);
                                userIds = userIds + userId + ";";
                            }
                            if (userIds.length > 0) {
                                userIds = userIds.substring(0, userIds.length - 1);     //去掉最后一个字符（;）
                                //wx.closeWindow();
                                setTimeout(function () {
                                    //wx.closeWindow();
                                    openEntChat(userIds);
                                }, 50);
                                //openEntChat(userIds);
                                //wx.closeWindow();
                            }
                        }
                    })
            });
            //wx.closeWindow();
        }

        //根据选定的用户id，打开会话
        function openEntChat(userIds) {
            wx.openEnterpriseChat({
                userIds: userIds,    // 必填，参与会话的成员列表。格式为userid1;userid2;...，用分号隔开，最大限制为1000个。userid单个时为单聊，多个时为群聊。
                groupName: '讨论组',  // 必填，会话名称。单聊时该参数传入空字符串""即可。
                success: function (res) {
                    // 回调
                    /*setTimeout(function () {
                        wx.closeWindow()
                    }, 5000);*/
                    //alert("创建成功！");
                    
                    //window.history.go(-1);
                },
                fail: function (res) {
                    if (res.errMsg.indexOf('function not exist') > 0) {
                        alert('版本过低请升级')
                    }
                }
            });
        }
    </script>

</body>
</html>
