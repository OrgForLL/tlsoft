<%@ Page Language="C#" AutoEventWireup="true" %>

<%@ Import Namespace="nrWebClass" %>
<%@ Import Namespace="System.Data" %> 
<%@ Import Namespace="System.Collections.Generic" %>
 
<script runat="server">
 
    //公共变量
    public string AppSystemKey = "";
    
    private string SystemID = "3";//默认为全渠道系统      
    private string APIConfigKey = "1";
    
    //配置参数
    private List<string> apiConfig = new List<string>();
    protected void Page_Load(object sender, EventArgs e)
    {
        AppSystemKey = "9";
        apiConfig = clsWXHelper.GetJsApiConfig(APIConfigKey);
        
        //if (clsWXHelper.CheckQYUserAuth(true))
        //{
        //    AppSystemKey = clsWXHelper.GetAuthorizedKey(Convert.ToInt32(SystemID));
        //    if (AppSystemKey == "")
        //    {
        //        clsWXHelper.ShowError("对不起，您还未开通全渠道系统权限！");
        //    }
        //    else
        //    {
        //        clsWXHelper.WriteLog(string.Format("AppSystemKey:{0},访问功能页[{1}]", AppSystemKey, "销售神器-客户模块"));

        //        apiConfig = clsWXHelper.GetJsApiConfig(APIConfigKey);
        //        if (apiConfig.Count < 4)
        //        {
        //            apiConfig.AddRange(new string[] { "", "", "", "" });
        //        }
        //    }
        //}
        //else
        //{
        //    clsWXHelper.ShowError("鉴权失败！");
        //}
    }

</script>

<!DOCTYPE html>

<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <meta charset="utf-8" />
    <meta name="viewport" content="width=device-width,initial-scale=1,user-scalable=0,maximum-scale=1" />
    <meta name="format-detection" content="telephone=no" />
    <meta name="apple-mobile-web-app-capable" content="yes" />
    <meta name="apple-mobile-web-app-status-bar-style" content="black" />
    <meta http-equiv="Pragma" contect="no-cache">
    <title></title>	
    <link rel="stylesheet" href="../../res/css/Loading.css"/>
     
</head>
<body>
    <form id="form1" runat="server">
    <div class="header">
        <div class="backbtn" onclick="BackFunc()"><i class="fa fa-chevron-left"></i></div>
        <div class="title current-user">我的学习笔记</div>         
    </div>
    <div id="main" class="wrap-page">
        <!--聊天列表主页-->
        <div class="page page-not-header" id="chat-list">
            <div class="search">
                <input id="searchtxt" type="text" placeholder="请输入搜索关键字" />
            </div>
            <ul class="chat-ul"> 
                <li myid="0"> 
                    <div class="chat-info">
                        <p class="chat-name"><i class="fa fa-plus-circle"></i><span>填写新的学习笔记</span></p>
                        <p class="chat-time">现在</p>
                    </div>
                    <div class="message-nums"><i class="fa fa-chevron-right"></i></div>					
                </li> 
            </ul>
        </div>
		<!-- 详情页 -->
        <div class="page page-right" id="personal">
            <div class="fromstore"><img alt="" src="../../res/img/StoreSaler/shop.png" /><span>2016年4月28日</span></div>
            <div class="person-win backimg" style="background-color: #31343b;"></div>
            <div class="share">
                <p class="title noSelect">笔记内容：</p>　
                <span class="btnVoice noSelect"><i class="fa fa-volume-up fa-3x"></i></span>
                <span class="VoiceState hide noSelect" id="voiceState1"><i class="fa fa-circle-o-notch fa-spin"></i>请说话，说完以后放开...</span>
                <span class="VoiceState hide noSelect" id="voiceState2"><i class="fa fa-spinner fa-spin"></i>正在解析成文字，请稍候...</span>

                <textarea class="content inputcss" placeholder="每天成长一点点，终有剥茧成蝶的一天！开始记录学习笔记内容吧..."></textarea>
				 
                <div class="icons">
                    <a href="javascript:" onclick="$('#personal').addClass('page-right');"><i class="fa fa-rotate-left"></i>返 回</a>
                    <a href="javascript:" id="saveNote" ><i class="fa fa-save"></i>保 存</a>
                    <i class="fa fa-bookmark"></i>
                </div>
            </div> 
        </div>
    </div>  
	 
    <script type="text/javascript">
        var SalerID = "<%= AppSystemKey %>";

        
        //以下是JSAPI专用的配置
        var appId = "<%= apiConfig[0] %>";
        var timestamp = <%= apiConfig[1] %>;    
        var nonceStr = "<%= apiConfig[2] %>";
        var signature = "<%= apiConfig[3] %>";
    </script> 
    <script type="text/javascript" data-main="../../res/js/StoreSaler/note_main" src="../../res/js/require.js"></script>
     
    <!--提示层-->
    <div class="mymask">
        <div class="loader">
            <div>
                <i class="fa fa-2x fa-warning (alias)"></i>
            </div>
            <p id="loadtext">
                正在处理...
            </p>
        </div>
    </div>
	<!--loading mask-->
	<div id="loadingmask" style="position: fixed; background-color: #f0f0f0; top: 0; height: 100%; left: 0; width: 100%; z-index: 2000;">
		<div id="loading-center-absolute">
			<div class="object" id="object_one"></div>
			<div class="object" id="object_two"></div>
			<div class="object" id="object_three"></div>
			<div class="object" id="object_four"></div>            
		</div>        
	</div> 
	
    </form>  
</body>



</html>
