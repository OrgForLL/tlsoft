<%@ Page Language="C#" %>  
<%@ Import Namespace="nrWebClass" %>
<%@ Import Namespace="System.Data" %>
<%@ Import Namespace="System.Data.SqlClient" %>
<%@ Import Namespace="System.Collections.Generic" %>
<!DOCTYPE html>
<script runat="server"> 

    private bool IsDebugMode = true;    //是否为调试模式

    private const int SystemID = 2; //人资系统
    public string myInfo = "";    //信息内容
    protected void Page_Load(object sender, EventArgs e)
    { 
        if (clsWXHelper.CheckQYUserAuth(true))
        {
            string SystemKey = clsWXHelper.GetAuthorizedKey(SystemID);
            if (SystemKey != "")
            {
                LoadCar();
            }
            else
            {
                clsWXHelper.ShowError("你还未开通 人资系统！");
                return;
            }
        }
        else
        {
            clsWXHelper.ShowError("你还未关注 利郎企业号！");
            return;
        }  
    }
     
    private void LoadCar()
    {
        string id = Convert.ToString(Request.Params["id"]);

        if (id == null || id == "")
        {
            clsWXHelper.ShowError("非法访问！");
            return;
        }

        string DBcon = clsConfig.GetConfigValue("OAConnStr");
        using (LiLanzDALForXLM dal = new LiLanzDALForXLM(DBcon))
        {
            string strSQL = @"
            DECLARE @billCount INT,
                    @jsy VARCHAR(50),                    
                    @sqr VARCHAR(50),                    
                    @name VARCHAR(50),                    
                    @mymobile VARCHAR(50),   
                    @myTime VARCHAR(10)

            SELECT @billCount = 0,@jsy = '',@sqr = '',@name = '',@mymobile = '',@myTime = ''

            SELECT TOP 1 @jsy = jsy,@sqr = sqr,@myTime = CONVERT(VARCHAR(10),kssj,120)  FROM rs_t_pcydb WHERE id = @id
            SELECT @billCount = COUNT(1) FROM rs_t_pcydb WHERE jsy=@jsy AND id < @id AND CONVERT(VARCHAR(10),ISNULL(kssj,'1970-01-01'),120) = @myTime 
            SELECT @billCount = @billCount + 1        

            SELECT TOP 1 @name = [name],@mymobile = mobile FROM wx_t_customers WHERE cname = @sqr

            SELECT TOP 1 @billCount billCount,@mymobile mobile,jsy,cph,sydw,kssj,yjjssj,rs,sqr,syr,lslxdh,scdd,qx,bz,hzbs,djbs FROM rs_t_pcydb WHERE id = @id";

            List<SqlParameter> listSqlParameter = new List<SqlParameter>();
            listSqlParameter.Add(new SqlParameter("@id", id));
            DataTable dtRead;
            string strInfo = dal.ExecuteQuerySecurity(strSQL, listSqlParameter, out dtRead);
            if (strInfo == "")
            {
                DataRow dr = dtRead.Rows[0];  
                string billCount = string.Concat(Convert.ToDateTime(dr["kssj"]).ToString("yyMMdd-"), Convert.ToString(dr["billCount"]));
                string jsy = Convert.ToString(dr["jsy"]);
                string cph = Convert.ToString(dr["cph"]);
                string sydw = Convert.ToString(dr["sydw"]);
                DateTime kssj = Convert.ToDateTime(dr["kssj"]);
                DateTime yjjssj = Convert.ToDateTime(dr["yjjssj"]);
                string rs = Convert.ToString(dr["rs"]);
                string sqr = Convert.ToString(dr["sqr"]);
                string sqrdh = Convert.ToString(dr["mobile"]); 
                string syr = Convert.ToString(dr["syr"]);
                string lslxdh = Convert.ToString(dr["lslxdh"]);
                string scdd = Convert.ToString(dr["scdd"]);
                string qx = Convert.ToString(dr["qx"]);
                string bz = Convert.ToString(dr["bz"]);
                string hzbs = Convert.ToString(dr["hzbs"]);
                string djbs = Convert.ToString(dr["djbs"]);
                string state;
                if (djbs != "1") state = "已作废";
                else if (hzbs == "1") state = "已回执";
                else state = "正常单";  

                dtRead.Clear(); dtRead.Dispose();


                if (IsDebugMode == false && jsy != Convert.ToString(Session["qy_cname"]))       //限定驾驶员
                {
                    clsWXHelper.ShowError(string.Concat("这是[", jsy, "]负责的派车单！"));
                    return;
                }
                                
                this.Djid.Value = id;
                this.Hzbs.Value = hzbs;
                this.Djbs.Value = djbs;
                
                StringBuilder sbInfo = new StringBuilder();

                sbInfo.Append(@"<ul id=""DetailList"" class=""DetailList"">");
                sbInfo.Append(@"<li><span>信息项</span><span>信息内容</span></li>");

                sbInfo.AppendFormat(@"<li><span>单据状态</span><span>{0}</span></li>", state);
                sbInfo.AppendFormat(@"<li><span>派车序号</span><span>{0}</span></li>", billCount); 
                sbInfo.AppendFormat(@"<li><span>车辆信息</span><span>{0}</span></li>", jsy, cph);
                sbInfo.AppendFormat(@"<li><span>使用单位</span><span>{0}</span></li>", sydw);
                sbInfo.AppendFormat(@"<li><span>起止时间</span><span>{0}-{1}</span></li>", kssj.ToString("M月d日 HH:mm"), yjjssj.ToString("HH:mm"));
                sbInfo.AppendFormat(@"<li><span>派车人数</span><span>{0}</span></li>", rs);
                sbInfo.AppendFormat(@"<li><span>派 车 人</span><span>{0} {1}</span></li>", sqr, sqrdh);
                sbInfo.AppendFormat(@"<li><span>主 使 用</span><span>{0} {1}</span></li>", syr, lslxdh);
                sbInfo.AppendFormat(@"<li><span>上车地点</span><span>{0}</span></li>", scdd);
                sbInfo.AppendFormat(@"<li><span>到达地点</span><span>{0}</span></li>", qx);
                sbInfo.AppendFormat(@"<li><span>备注信息</span><span>{0}</span></li>", bz);  
                    
                sbInfo.Append("</ul>");

                myInfo = sbInfo.ToString();

                sbInfo.Length = 0; 
            }
            else
            {
                clsSharedHelper.WriteErrorInfo(string.Concat("错误：", strInfo));
            }
        }
    }
</script>
<html style="height:110%;">
<head>
    <title></title>
    <meta name="viewport" content="width=device-width, initial-scale=1.0, user-scalable=no,maximum-scale=1.0,minimum-scale=1.0" />
    <script type="text/javascript" src="../../res/js/jquery.js"></script>
    <script type="text/javascript" src="../../res/js/sweet-alert.min.js"></script>
    <script type="text/javascript" src="../../res/js/StoreSaler/fastclick.min.js"></script>
    <link rel="stylesheet" href="../../res/css/sweet-alert.css" />
    <style type="text/css">
        *
        {
            margin: 0;
            padding: 0;
            -webkit-box-sizing: border-box;
            -moz-box-sizing: border-box;
            box-sizing: border-box;
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
           margin:0;
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
        	 padding:0.25em;
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
           border-bottom:1px solid #e0e0e0;
        }
        .DetailList>li>span:nth-child(1) 
        {
           display:inline-block;
           width:30%;           
           text-align:center;
           margin:0;
           text-decoration: none;
           white-space: nowrap;
           overflow: hidden;
           text-overflow: ellipsis; 
        } 
        
        .DetailList>li>span:nth-last-child(1) 
        {
           width:70%;
           text-align:center;
           margin:0;
           display:inline-block;
           text-overflow:ellipsis; overflow:hidden; white-space:nowrap; 
        } 
        
        .DetailList>li:nth-child(1)
        {
            border-top-left-radius:0.5em;
            border-top-right-radius:0.5em;  
            font-weight:700;          
            background-color:#e0e0d0;
            
        }
        .DetailList>li:nth-last-child(1)
        {
            border-bottom-left-radius:0.5em;
            border-bottom-right-radius:0.5em; 
            border-bottom:none;          
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
        
        .bottom 
        {
            margin:0.5em 5%;
            position:relative;
            bottom:0;
            width:90%;
        }  
        .bottom h1 {
            color: #CFCFCF;
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

.title
{
    width:100%; background:#302921; height:4em; text-align:center; vertical-align:middle; line-height:1em; padding:0.5em;
}
.title img
{
    height:1em;
}

.title span
{
    font-size:1.2em; margin-top:0.2em; color:#fff;
}     
 
 #btnSure
 {
     display:none;
     cursor:pointer;     
 }
                
    </style>
</head>
<body style="height:100%;">  
       <input id="Djid" type="hidden" runat="server" value="" /> 
       <input id="Hzbs" type="hidden" runat="server" value="" />       
       <input id="Djbs" type="hidden" runat="server" value="" />       
       <div class="title">
           <img alt="logo" src="../../res/img/CoffeePay/poslogo.png" /><br/><br/>
           <span>派车管理－发送回执</span>
       </div>
     <div class="container">
       <%= myInfo%>
     </div> 
     <span id="sureTS">
            请点击以下按钮发送回执
     </span> 
     <div id="btnSure" class="star">
	    <span>发送回执</span>
        <s></s>
        <b></b>
     </div>
    
   <div class="bottom">
    	<h1>利郎信息技术部提供技术支持</h1>
    </div>
    <script type="text/javascript">

        window.onload = function () {

            var hzbs = $("#<%= Hzbs.ClientID%>").val();
            var djbs = $("#<%= Djbs.ClientID%>").val();
            if (djbs == "1") {
                if (hzbs == "0") {
                    $("#btnSure").fadeIn();
                } else {
                    $("#sureTS").html("该派车单已经发送回执！");
                    $("#btnSure").fadeOut();
                }
            } else {
                $("#sureTS").html("该派车单已经作废！");
                $("#btnSure").fadeOut();
            }


            $("#btnSure").click(function (e) {
                $("#btnSure").attr("disabled", true); 
                var Djid = $("#<%= Djid.ClientID %>").val(); 
                $.ajax({
                    url: "WxSendOKCore.aspx",
                    type: "POST",
                    data: { ctrl: "SendOK", id: Djid },
                    dataType: "HTML",
                    timeout: 15000,
                    error: function (XMLHttpRequest, textStatus, errorThrown) {
                        swal("网络错误", "请重新打开试试!", "error");

                        $("#btnSure").attr("disabled", ""); 
                    },
                    success: function (result) {
                        if (result.indexOf("Successed") >= 0) {
                            result = result.substring(9);

                            var strType = "success";

                            if (result == "") result = "派车人将会收到您的回执！";
                            else strType = "info"; 

                            swal({ title: "发送成功",
                                text: result,
                                type: strType,
                                showCancelButton: false
                            },
                              function () {
                                  WeixinJSBridge.call('closeWindow');
                              });

                        } else {
                              swal("操作提示", result, "error");
                              $("#btnSure").attr("disabled", ""); 
                        }
                    }

                });

            });
        }

    </script>
</body>
</html>
