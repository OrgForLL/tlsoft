<%@ Page Language="C#" %>
<%@ Import Namespace="nrWebClass" %>
<%@ Import Namespace="WebBLL.Core" %>
<!DOCTYPE html>
<script runat="server"> 
    protected void Page_Load(object sender, EventArgs e)
    {
        string customerID = "linwy";

        if (clsWXHelper.CheckQYUserAuth(true))
        {
            customerID = Convert.ToString(Session["qy_customersid"]);
        }
        else
        {
            clsSharedHelper.WriteErrorInfo("鉴权出错，请确认是否已成功关注企业号！");
            return;
        }

        if (customerID == "")
        {
            clsSharedHelper.WriteErrorInfo("鉴权出错，请重新进入");
            return;
        }

        this.customerID.Value = customerID;
    }
</script>
<html style="height:110%;">
<head>
    <title></title>
    <meta name="viewport" content="width=device-width, initial-scale=1.0, user-scalable=no,maximum-scale=1.0,minimum-scale=1.0" />
    <script type="text/javascript" src="../../res/js/jquery.js"></script>
    <script type="text/javascript" src="../../res/js/sweet-alert.min.js"></script>
    <link rel="stylesheet" href="../../res/css/sweet-alert.css" />
    <style type="text/css">
        *
        {
            margin: 0;
            padding: 0;
        }
        body
        {
            font-family: "微软雅黑";
            text-align: center;
            font-size: 1em;
            background-color: #b5aa96; 
        }        
         ul {
            list-style-type: none;
        }
        .container
        {
           margin:0.5em;
           width:100%;
        }
         .container li
        {
           background-color: #efebdf;
           display:block;
           text-decoration: none;
           white-space: nowrap;
           overflow: hidden;
           text-overflow: ellipsis;
           text-align:center;
        }
        
         .DetailList
        {
        	 padding-top:1em;
        	 width:100%;
        	 text-align:center;
        }
        
        #username
        {
            text-align:left;
            padding-left:1em;
        }
        
        .DetailList li
        {
           width:100%; 
        }
        .DetailList .Listname
        {
           display:inline-block;
           width:50%;           
           text-align:center;
           margin:0;
           text-decoration: none;
           white-space: nowrap;
           overflow: hidden;
           text-overflow: ellipsis; 
        }
        .DetailList .sl
        {
           width:25%;
           text-align:center;
           margin:0;
           display:inline-block;
        }
        .DetailList .money
        {
           width:25%;
           text-align:center;
           margin:0;
           display:inline-block;  
        }
        .sumPay
        { 
        	background-color:#d0d0d0;     
            border-bottom-left-radius:0.2em;
            border-bottom-right-radius:0.2em;    
        }
        .sumPay>span
        { 	
            float:right;
            width:100%;
            text-align:right;            
            padding-right:1em;   
            font-weight:700;         
        }
        
        .btn
        {
        	margin:0.5em;
        	font-size:1.2em;
        	height:3em;
        	width:50%;
        	border-radius:0.25em;
        }
        
        .borderRadiusTop
        {
            border-top-left-radius:0.2em;
            border-top-right-radius:0.2em;  
            font-weight:700;          
        }
        .bottom 
        {
            margin:0.5em 5%;
            position:fixed;
            bottom:0;
            width:90%;
        }  
        .bottom h1 {
            color: #5F5F5F;
            white-space: nowrap;
            -webkit-background-size: 1em 1.15em;
            font-size: 1em;
            text-align:center;
            margin:0;
            padding:0;
        }       

/* 以下代码实现闪烁按钮*/           
.star
{
    margin:0.5em 15%;
    width:70%; 
    font-size:1em; 
	height:4em;
	border-radius:0.5em;
	border:1px solid #c0c0c0;
	position:relative; 
	-webkit-transform:scale(0);
	-webkit-animation-name:janim;
	-webkit-animation-duration:.3s;
	-webkit-animation-timing-function:linear;
	-webkit-animation-direction:normal;
	-webkit-animation-fill-mode:forwards;
}
.star span
{
    font-size:1.5em;
	line-height:2.67em; 
	position:absolute;	
	left:0;	
	width:100%;
	height:100%;
	color:#fff;
	vertical-align:middle;
	text-align:center;
	z-index:9;
}
.star s{
	width:100%;
	height:100%;
	display:block;
	background-color:#9ad229;
	border-radius:0.5em;
	position:absolute;
}
.star b{
	width:100%;
	height:100%;
	display:block;
	border-radius:0.5em;
	position:absolute;
	background-color:#9ad229;
	-webkit-transform:scale(2);
	opacity:.2;
	-webkit-animation:zdjpop .8s infinite;
}
@-webkit-keyframes janim {
	0% {
		-webkit-transform:scale(0.15);
	}
	50% {
		-webkit-transform:scale(1.15);
	}
	100% {
		-webkit-transform:scale(1);
	}
}
@-webkit-keyframes zdjpop {
	0% {
		opacity:1;
		-webkit-transform:scale(1);
	}
	100% {
		opacity:0;
		-webkit-transform:scale(1.3);
	}
}
                
                
    </style>
</head>
<body style="height:100%;"> 
       <input id="customerID" type="hidden" runat="server" value="" />       
       <div style="width:100%; background:#302921; height:3.75em; text-align:center; vertical-align:middle; line-height:1em; padding:0.5em;">
       <img style="height:1em;" alt="logo" src="../../res/img/CoffeePay/poslogo.png" /><br/><br/>
       <span style=" font-size:1.2em; margin-top:0.2em; color:#fff;">臻咖啡－支付确认</span>
       </div>
     <div class="container">
         <div id="username" >
          </div>
       <ul id="DetailList" class="DetailList">
       <li class="borderRadiusTop"><span class="Listname">菜品</span><span class="sl">数量</span><span class="money">金额</span></li>
<%--       <li><span class="Listname">百香绿茶百香绿茶百香绿茶百香绿茶</span><span class="sl">1</span><span class="money">8</span></li>
       <li><span class="Listname">美式咖啡</span><span class="sl">3</span><span class="money">18.5</span></li>
       <li><span class="Listname">芒果冰沙</span><span class="sl">1</span><span class="money">10</span></li>--%>
       </ul>
     </div> 
     <span id="sureTS">
            请点击以下按钮确认支付
     </span> 
   <div id="btnSure" class="star">
	<span>确认支付</span>
    <s></s>
    <b></b>
  </div>
    
   <div class="bottom">
    	<h1>利郎信息技术部提供技术支持</h1>
    </div>
    <script type="text/javascript">

        window.onload = function () {
            //alert($("#<%= customerID.ClientID %>").val());
            GetInfo();
            $("#btnSure").click(function (e) {
                var customerID = $("#<%= customerID.ClientID %>").val();
                // alert(userid);
                $.ajax({
                    url: "WxPayCore.aspx?ctrl=SurePay",
                    type: "POST",
                    data: { customerID: customerID },
                    dataType: "HTML",
                    timeout: 30000,
                    error: function (XMLHttpRequest, textStatus, errorThrown) {
                        swal("糟糕，出错了", "请重新扫描试试!", "error");
                    },
                    success: function (result) {
                        if (result.indexOf("Successed") >= 0) {
                            swal({ title: "确认支付成功!",
                                text: "实际支付金额以咖啡馆收银台显示为准!",
                                type: "success",
                                showCancelButton: false
                            },
                              function () {
                                  WeixinJSBridge.call('closeWindow');
                              });

                        } else {
                            swal("糟糕，出错了", result, "error");
                        }
                    }

                });

            });
        }
        function GetInfo() {
            var customerID = $("#<%= customerID.ClientID %>").val();
            $.ajax({
                url: "WxPayCore.aspx?ctrl=GetInfo",
                type: "POST",
                data: { customerID: customerID },
                dataType: "HTML",
                timeout: 30000,
                error: function (XMLHttpRequest, textStatus, errorThrown) {
                    swal("糟糕，出错了", "请重新打开页面!", "error");
                },
                success: function (result) {
                    alert(result);
                    result = result.replace(/"\[/g, "[");
                    result = result.replace(/\]"/g, "]");
                    var t;
                    try {
                        if (result.indexOf("Successed") == 0) {
                            result = result.substring(9);
                        } else if (result.indexOf("Type1") > 0) {//跳到绑定页面
                            window.location.href = "../BandToSystem/SystemBand.aspx?systemid=5&ClosePag=1";
                        } else if (result.indexOf("Error:") == 0) {
                            result = result.substring(6);
                        }

                        t = stringToJson(result);

                        $("#username").html("尊敬的 <span style='color:#f00'>" + t.UserName + "</span> ，您好！<br/>您在咖啡馆消费情况如下：");
                        var detail = t.BillDetail;
                        var row;
                        for (var i = 0; i < detail.length; i++) {
                            row = detail[i];
                            $("#DetailList").append("<li><span class=\"Listname\">" + row.Name + "</span><span class=\"sl\">" + row.sl + "</span><span class=\"money\">" + row.je + "</span></li>");
                        }
                        $("#DetailList").append("<li class=\"sumPay\"><span>总消费金额为： <span style='color:#f00'>" + t.AllPay + "</span> 元</span></li>");
                    } catch (e) {
                        $("#btnSure").css("display", "none");
                        $("#container").css("display", "none");
                        $("#sureTS").css("display", "none");
                        $("#DetailList").css("display", "none");
                        $("#username").html(result);
                        swal({ title: result,
                            text: "",
                            type: "error",
                            showCancelButton: false
                        },
                              function () {
                                  WeixinJSBridge.call('closeWindow');
                              });
                        return;
                    }
                }
            });
        }
        function stringToJson(stringValue) {
            eval("var theJsonValue = " + stringValue);
            return theJsonValue;
        }
    </script>
</body>
</html>
