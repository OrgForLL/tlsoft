<%@ Page Language="C#" %>
<%@ Import Namespace="nrWebClass" %>
<%@ Import Namespace="System.Data" %>
<%@ Import Namespace="System.Data.SqlClient" %>
<%@ Import Namespace="System.IO" %>
<%@ Import Namespace="System.Xml" %>
<%@ Import Namespace="System.Net" %>
<script runat="server">

    public string backmsg = "报名已经截止。";
    protected void Page_Load(object sender, EventArgs e)
    {
        if (Page.IsPostBack)
        {
			Response.End();
            int id = 0;
            nrWebClass.DAL.SqlDbHelper dal = new nrWebClass.DAL.SqlDbHelper();
            dal.ConnectionString = "server=192.168.35.10;database=tlsoft;uid=ABEASD14AD;pwd=+AuDkDew";
            //检查重复提交
            SqlParameter[] paraForCheck = new SqlParameter[] { 
                new SqlParameter("@mobi", txtmobi.Value)
            };
            string sql = "select 1 from wx_t_MeetingApply where ApplyPhone=@mobi ";
            if (dal.ExecuteScalar(sql, CommandType.Text, paraForCheck) == null)
            {
                Random rnd1 = new Random();
                id = rnd1.Next(100, 999);
                sql = @"INSERT INTO wx_t_MeetingApply  (ApplyName,ApplyCompany, ApplyPosition,ApplyWXName,ApplyPhone,ApplyEmail, randomCode) VALUES (@cname,@comp,@job,@wxname,@mobi,@mail,@code) ";
                SqlParameter[] para = new SqlParameter[] { 
                new SqlParameter("@cname", txtcname.Value),
                new SqlParameter("@comp", txtcomp.Value),
                new SqlParameter("@job", txtjob.Value),
                //new SqlParameter("@wxid", 0),
                new SqlParameter("@wxname", ""),
                new SqlParameter("@mobi", txtmobi.Value),
                new SqlParameter("@mail", txtmail.Value),
                new SqlParameter("@code", id)
                };
                //para[7].Direction = ParameterDirection.Output;
                if (dal.ExecuteNonQuery(sql, CommandType.Text, para) > 0)
                {
                    //发短信
                    String url = "http://192.168.35.14:88/gdSmsMsg/IMeetingMsg.aspx?phone={0}&msg={1}";
                    url = String.Format(url, txtmobi.Value, HttpUtility.UrlEncode("欢迎您参加“移动互联网时代的创业常数”主题大会，请您凭此短信随机生成的id在门口领取入场券入场，您的id为：", Encoding.GetEncoding("GB2312")) + id);
                    WebRequest request = WebRequest.Create(url);
                    request.ContentType = "text/html;charset=GB2312";
                    Stream dataStream;
                    WebResponse response;

                    response = request.GetResponse();
                    dataStream = response.GetResponseStream();
                    StreamReader reader = new StreamReader(dataStream, Encoding.GetEncoding("GB2312"));
                    // Read the content.
                    string responseFromServer = reader.ReadToEnd();
                    backmsg = "短信已经发送，请注意查收";
                };
            }
            else {
                backmsg = "此号码已有提交记录，请勿重复申请";
            }
        }
    }
</script>
<!DOCTYPE html>
<html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=utf-8" />
<title>利郎相约王雨豪-移动互联网时代的创业常数</title>
<!--<meta name="viewport" content="width=device-width, initial-scale=1">-->
<meta name="viewport" content="width=device-width, initial-scale=1.0, maximum-scale=1.0, user-scalable=no">
<meta name="description" content="时间：10月12日  地点：福建晋江利郎总部8楼   限量免费参会名额发放中！" />
<script src="js/jquery.min.js"></script>
<style>
input{
	margin-top: 3px; 
	line-height: 18px; 
	border: 1px solid #D9D9D9; 
	border-top-color: #AAAAAA; 
	border-radius: 2px;
	width:75%;
	height:35px;
}
input:focus
{ border: 1px solid #609ED2; }
.moblieDescribe { padding: 0 5px; line-height: 20px; color: #7C7C7C; border-top: 1px dashed #7C7C7C; width:75%;}
body{text-align:center;}
.main{
	margin:0px auto;
	text-align:left;
	display: block;
	position: relative;
	width: 100%;
	height: auto;
	z-index: 30;
}
span { z-index: 10; margin-left: 5px; color: #fff; background: #7A3230; font-size: 12px; padding: 1px 5px; text-align: center; white-space: nowrap; font-weight: normal;
display:none}
#submitBtn {
	display: inline-block;
	line-height: 28px;
	padding: 0 20px;
	font-size: 13px;
	text-align: center;
	color: #FFF;
	border-radius: 2px;
	background:#999;
}
.divSubmit{height:50px;
padding-top:20px}
msgbox{
	z-index: 10; margin-left: 5px; color: #fff; background: #7A3230; font-size: 16px; padding: 1px 5px; text-align: center; white-space: nowrap; font-weight: normal;
}
.content2{
	font-size:14px;
	color:#999}
</style>
<script type="text/javascript">
    $(document).ready(function (e) {
        $("#submitBtn").click(function (e) {
            if (!$("#txtmail").val().match(/^\w+((-\w+)|(\.\w+))*\@[A-Za-z0-9]+((\.|-)[A-Za-z0-9]+)*\.[A-Za-z0-9]+$/))
                $("#mail").show();
            else
                $("#mail").hide();
            if (!$("#txtmobi").val().match(/^(((1[3-8][0-9]{1})|159|153)+\d{8})$/))
                $("#mobi").show();
            else
                $("#mobi").hide();

            if ($("#txtcname").val() == "")
                $("#cname").show();
            else
                $("#cname").hide();
            //公司		
            if ($("#txtcomp").val() == "")
                $("#comp").show();
            else
                $("#comp").hide();
            //职位
            if ($("#txtjob").val() == "")
                $("#job").show();
            else
                $("#job").hide();

            if ($("span:hidden").length == $("span").length)
                $("#form1").submit();
        });
		if($("msgbox").html()== "")
			$("msgbox").hide();
		else
			$("msgbox").show();	
    });
</script>
<script type="application/javascript">
// 自定义微信分享内容
var _share_imgWeixin = "http://tm.lilanz.com/hr/img/title.png";
var _share_desc = "时间：2014年10月12日 地点：福建晋江利郎总部8楼  限量免费参会名额发放中！";
if(document.addEventListener){
	document.addEventListener('WeixinJSBridgeReady', function onBridgeReady() {
		WeixinJSBridge.on('menu:share:appmessage', function(argv){
			WeixinJSBridge.invoke('sendAppMessage',{
			"appid": "wxe4ef27b28da6709f",
			"title": "利郎相约王雨豪-移动互联网时代的创业常数",
			"link": "http://tm.lilanz.com/hr/MeetingSignIn.aspx",
			"desc": _share_desc,
			"img_url": _share_imgWeixin,
			"img_width": "640",
			"img_height": "640"
			}, function(res) {
				//_report('send_msg', res.err_msg);
			});
		});
		WeixinJSBridge.on('menu:share:timeline', function(argv){
			WeixinJSBridge.invoke('shareTimeline',{
			"appid": "wxc368c7744f66a3d7",
			"title": "利郎相约王雨豪-移动互联网时代的创业常数",
			"link": "http://tm.lilanz.com/hr/MeetingSignIn.aspx",
			"img_url": _share_imgWeixin,
			"desc": _share_desc,
			"img_width": "640",
			"img_height": "640"
			}, function(res) {
				//_report('send_msg', res.err_msg);
			});
		});
		//WeixinJSBridge.call('showOptionMenu');
	},false);
} else {
}
</script>
</head>
<body>
    <form id="form1" runat="server">
	<div class="main" style="">
   <div>
   </div>
   <div>
    	<%--<h4 style="text-align:center">移动互联网时代的创业常数</h4>--%>
        <%--<h5 style="text-align:right;padding-right:50px">——向时局死，向时代生</h5>--%>
        <div><img src="img/top3.jpg" style=" width:98%" /></div>        
    	<div style="font-size:16px;font-weight:bold">
        	<p>
                时间：2014年10月12日(星期日)14：00-17:30<br/>
                地点：福建晋江利郎总部8楼<br/>
                对象：企业家、企业高管、媒体等<br/>
                主办方：利郎（中国）有限公司、友商慧<br/>
                演讲主题：移动互联网时代的创业常数<br/>
            </p>
        </div>
        <div style="font-size:17px;">
            <p>
                <font style="color: #FF8040">
                    15年前，中国还没有互联网，马云要证明别人都没有见过的互联网。<br/>
                    15年后，土生土长的阿里巴巴成为全球第二大互联网公司，<br/>
                    市值2285亿美元，马云身价300亿美元。<br/>
                    <br/>
                    5年前，谁也不知道什么叫移动互联网。<br/>
                    5年后，中国的移动互联网，微信排名世界第一。<br/>
                </font>
                <br/>
                马化腾说：   <br/>
                “智能终端是人感官的延伸；<br/>
                移动互联网才是真正的互联网”。 <br/>
                那么这是一个什么样的时代？<br/>
                为什么新创企业大多数会失败？<br/>
                王雨豪说移动互联网是女性的？<br/>
                <br/>
                <font style="font-weight:bold">
                王雨豪<br/>
                【互联网人贩子】<br/>
                福布斯专栏作家<br/>
                人人猎头总裁<br/>
                </font>
                <br/>
                他是“灭绝人性”的青年演讲家，携大规模杀伤武器《微信纪元》<br/>
                在奇虎360，中欧，复旦，交大......掀起热浪，引爆全场<br/>
                <br/>
                他是一个将杨过，韦小宝，令狐冲气质融合一体的现代思考者，创业者<br/>
                <br/>
                他说，创业是一种信仰<br/>
                以颠覆性创新模式杀入猎头行业<br/>
                他用二十个月打造中国最大的网络猎头公司<br/>
                <br/>
                宇宙无常，创业有常，<br/>
                创业的最大常数，是“所属时代”，<br/>
                摸清“常数”，创业才会变成伟业。<br/>
                <br/>
                <font style="color:#FF8040">
                    我们不曾拥有这个时代，我们选择创造时代。<br/>
                    创业不只是眼前的苟且，一定要有诗意和远方。<br/>
                
                    <br/>
                     2014年10月12日，晋江，利郎相约王雨豪，与你娓娓道来——什么是他眼中的“创业常数”。
                    <br/>
                </font>
                <br>
          (限量免费名额陆续报名中) </p>
        </div>        
      <img src="img/top.jpg" style=" width:98%"/>
   </div>
   <div><msgbox><%=backmsg%></msgbox></div>
   <div>
        <p>姓名*<span id="cname">此项为必填项</span></p>
        <input name="txtcname" type="text" class="" id="txtcname" value="" readonly runat="server" />
   </div>
    <div>
      <p>公司*<span id="comp">此项为必填项</span></p>
        <input type="text" class="" value="" name="txtcomp" id="txtcomp" readonly runat="server"/>
   </div>
   <div>
        <p>职位*<span id="job">此项为必填项</span></p>
        <input type="text" class="" value="" name="txtjob" id="txtjob" readonly runat="server"/>
  </div>    
  <div>
      <p>微信</p>
      <input type="text" class="" value="" name="txtchat" id="txtchat" readonly runat="server"/>
  </div>
  <div>
      <p>手机*<span id="mobi">手机号码格式有误</span></p>
      <p class="moblieDescribe">报名成功后我们将发送参会编码短信，现场凭短信领取入场劵。</p>
    <input type="text" class="" value=""  name="txtmobi" id="txtmobi" readonly runat="server"/>
  </div>
  <div>
      <p>E-mail*<span id="mail">邮箱格式不正确</span></p>
      <input type="text" class="" value=""  name="txtmail" id="txtmail" readonly runat="server"/>
  </div>
  <div class="divSubmit"><a id="submitBtn" href="javascript:void(0)">报名已经截止</a></div>
  <div style="text-align:center; color:#999; font-size:12px">由利郎信息技术部提供技术支持</div>
</div>
    </form>
</body>
</html>
