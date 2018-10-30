<%@ Page Language="C#"  %>
<%@ Import Namespace="System.IO" %>
<%@ Import Namespace="System.Xml" %>
<%@ Import Namespace="System.Net" %>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">

<script runat="server">

    protected void Page_Load(object sender, EventArgs e)
    {
        if (Request.QueryString["openid"] == null && (!IsPostBack))
            LabelMsg.Text = "请到微信公众号点订票打开。";
        if (Request.QueryString["openid"] != null)
            wxid.Value = Request.QueryString["openid"].ToString();
        if (IsPostBack && wxid.Value.Length > 0)
        {
            string IdCard = Request.Form["IdCard"].ToString();
            string cname = Request.Form["Cname"].ToString();
            string moblie = Request.Form["Moblie"].ToString();
            string errorMsg = DpChcek(moblie, IdCard, cname);
            if (DpChcek(moblie, IdCard, cname) == "")
            {
                String url = "http://192.168.35.14:88/gdSmsMsg/IReceive.aspx?phone={0}&cname={1}&idcard={2}&wxid={3}";

                url = String.Format(url, moblie, HttpUtility.UrlEncode(cname, Encoding.GetEncoding("GB2312")), IdCard, wxid.Value);
                WebRequest request;
                request = WebRequest.Create(url);
                request.ContentType = "text/html;charset=GB2312";
                Stream dataStream;
                WebResponse response;

                response = request.GetResponse();
                dataStream = response.GetResponseStream();
                StreamReader reader = new StreamReader(dataStream, Encoding.GetEncoding("GB2312"));
                // Read the content.
                string responseFromServer = reader.ReadToEnd();
                if (responseFromServer.Substring(0, 2) == "OK")
                {
                    errorMsg = responseFromServer.Substring(3);
                    try
                    {
                        ServiceMsgSend ser = new ServiceMsgSend();
                        ser.send("尊敬的用户：您已成功预订利郎2015'重装归来'福利卷2张，请在活动期间内凭身份证原件到利郎公司领票处免费领取.", wxid.Value);
                    }
                    catch (Exception ex) 
                    {
                        common.WriteLog(ex.ToString());
                    }
                    
                }
                else
                    errorMsg = "请确认：" + responseFromServer.Substring(3);
                response = null;
                request = null;
                LabelMsg.Text = errorMsg;
            }
            else
            {
                LabelMsg.Text = errorMsg;
            }
        }
        else
        {
            //LabelMsg.Text = "异常，请尝试微信公众号点订票打开";
        }

    }
    public String DpChcek(String phone, String IdCard, String Cname)
    {
        //if (CheckIDCard(IdCard))
        //    return "身份证号有误！";
        //if (!IsHandset(phone))
        //    return "手机号码有误！";
        return "活动尚未开始，敬请期待";
    }
    /// 身份证验证
    /// </summary>
    /// <param name="Id">身份证号</param>
    /// <returns></returns>
    public bool CheckIDCard(string Id)
    {
        if (Id.Length == 18)
        {
            //bool check = CheckIDCard18(Id);
            return false;
        }
        else if (Id.Length == 15)
        {
            //bool check = CheckIDCard15(Id);
            return false;
        }
        else
        {
            return true;
        }
    }
    public bool IsHandset(string str_handset)
    {
        return System.Text.RegularExpressions.Regex.IsMatch(str_handset, @"^[1]+[3-9]+\d{9}");
    }
</script>

<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <meta charset="utf-8">
    <meta name="robots" content="noindex, follow">
    <meta name="viewport" content="width=device-width, initial-scale=1, user-scalable=0">
    <meta name="description" content="时间：12月18日  地点：福建晋江长兴路200号利郎总部" />
    <title>领票信息登记</title>
    <link rel="stylesheet" type="text/css" href="css/weui.min.css"/>
    <script src="js/jquery.js"></script>
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
/*	body{text-align:center;}*/
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
		width:50%;
	}
	.divSubmit{height:50px;
	padding-top:20px;
	text-align:left}
	msgbox, msgbox span{
		z-index: 10; margin-left: 5px; color: #fff; background: #7A3230; font-size: 16px; padding: 1px 5px; text-align: center; white-space: nowrap; font-weight: normal;
		word-break:break-all;
	}
	.content2{color:#999; font-size:12px;}
	#Moblie,#IdCard{IME-MODE: disabled; }
	.bt{text-align:center}
	</style>
<script type="text/javascript">
    $(document).ready(function (e) {
        $("#submitBtn").click(function (e) {
	
			var pass = true;
			$(".field input").each(function(index, element) {
                if ($(element).val() == ""){
					pass = false;
					$(element).prev().find("span").show();
				}
				else
					$(element).prev().find("span").hide();
            });
			if(pass){
				$("#loadingToast").show();
            	$("#form1").submit();
			}
        });
		if($("msgbox").text() == ""){
			$("msgbox").hide();
			
		}
		else{
			$("msgbox").show();	
			$("#LabelMsg").show();
		}
    });
</script>
</head>
<body>
<div class="page">
    <form id="form1" runat="server">
    <asp:HiddenField ID="wxid" runat="server" />
    <div style="border-bottom:#999 1px solid; text-align:center">
        领票信息登记
    </div>
    
    <div class="bd">
       <div>
       	   <msgbox><asp:Label ID="LabelMsg" runat="server" Text=""></asp:Label></msgbox>
       </div>
       
       <article class="weui_article content2">
            <p><cite>地点</cite>：福建省晋江市长兴路利郎总部</p>
            <p><cite>领票说明</cite>：</p>
            <p>活动期间微信领票信息登记成功以后凭身份证到利郎总部领票处领票两张</p>
            <p>或拨打客服热线进行预订</p>
            <p><cite>咨询电话</cite>：82039926&nbsp;&nbsp;82039930&nbsp;&nbsp;82039932</p>
                <p style="margin-top: 8px;">为了您购物的方便与安全,请勿带大包和1.2米以下的儿童入场。（工作人员有权限制大包不得带入场）</p>
            </p>
       </article>
       <div class="weui_cells weui_cells_form">
           <div class="weui_cell">
               <div class="field">
                    <p>手机*：<span>此项为必填项</span></p>
                    <input name="Moblie" id="Moblie" placeholder="请填写正确的手机号码" value="" type="number">
               </div>
           </div>
       
           <div class="weui_cell">
               <div class="field">
                    <p>姓名*：<span>此项为必填项</span></p>
                     <input name="Cname" id="Cname" placeholder="请填写身份证上的姓名" value="" type="text">
               </div>
           </div>
           <div class="weui_cell">
               <div class="field">
                    <p>身份证号*：<span>此项为必填项</span></p>
                    <input name="IdCard" id="IdCard" placeholder="请填写身份证号码" value="" type="number">
               </div> 
            </div>    
            
            <div class="weui_cell">
                <div class="button_sp_area">
                    <a id="submitBtn" href="javascript:void(0)"  class="weui_btn  weui_btn_primary" >筹备中...</a>
                </div>
            </div>  
        </div>
    </div>  
    </form>
</div>
<div class="content2 bt">由利郎信息技术部提供技术支持</div>

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
</body>
</html>
