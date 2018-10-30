<%@ Page Language="C#" Debug="true" %>

<%@ Import Namespace="System.Data" %>
<%@ Import Namespace="nrWebClass" %>
<%@ Import Namespace="System.Collections.Generic" %>
<%@ Import Namespace="System.Data.SqlClient" %>
<%--<%@ Register src="wx_header.ascx" tagname="wx_header" tagprefix="uc1" %>--%>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<script runat="server">
    public string picvip = "";
    public string cid;
    public string cname = "";
    public string openid = "";
    public string sid = "";
    public string wxHeadimgurl = "../../img/initial_img.png";
    public string beans = "0";
    public string kh = "";
    public string faceurl = "../../img/initial_img.png";
    public string ServiceLevel = "";
    public string dgname = "";
    private const string ConfigKeyValue = "5";
    string DBConStr_tlsoft = "";
    string DBConStr = "";
    protected void Page_Load(object sender, EventArgs e)
    {

        DBConStr_tlsoft = clsConfig.GetConfigValue("OAConnStr");
        DBConStr = ConfigurationManager.ConnectionStrings["Conn_4"].ConnectionString;
        if (clsWXHelper.CheckUserAuth(ConfigKeyValue, "openid"))
        {
            openid = Convert.ToString(Session["openid"]);
        }
        if (openid == "")
        {
            clsSharedHelper.WriteErrorInfo("鉴权出错，请重新进入");
            return;
        }
        List<SqlParameter> para = new List<SqlParameter>();
        DataTable dt;
        DataRow dr = FansSaleBind.GetFansSaleRowInfo(openid);
        if (dr != null)
        {
            sid = Convert.ToString(dr["sid"]);
            dgname = Convert.ToString(dr["cname"]);
            ServiceLevel = Convert.ToString(dr["ServiceLevel"]);
            faceurl = Convert.ToString(dr["faceurl"]);
        }
        //clsSharedHelper.WriteInfo(ServiceLevel);
        cid = Request.QueryString["cid"].ToString();
        //Console.Write(cid);
        if (dgname == "" && ServiceLevel == "" ) {
            string dgsql = @"select  e.Nickname,d.avatar,case when ISNUMERIC(g.dm)=1 then CONVERT(INT,g.dm) + 1 else 2 end  as ServiceLevel 
                            from wx_t_vipBinging a  
                            inner join wx_t_VipSalerBind b on a.vipID=b.vipid
                            inner join wx_t_OmniChannelUser e on b.SalerID=e.ID
                            inner join wx_t_AppAuthorized c on b.SalerID=c.SystemKey and c.SystemID=3
                            inner join wx_t_customers d on c.UserID=d.ID
                            inner join Rs_T_Rydwzl f on f.id=e.RelateID
                            inner join dm_t_xzjbb g on f.zd = g.id 
                            where a.wxOpenid=@openid ";
            para.Add(new SqlParameter("@openid", openid));
            using (LiLanzDALForXLM dal = new LiLanzDALForXLM(DBConStr))
            {
                string errInfo = dal.ExecuteQuerySecurity(dgsql, para, out dt);
                if (errInfo == "")
                {
                    if (dt.Rows.Count > 0){
                        dgname = Convert.ToString(dt.Rows[0]["Nickname"]);
                        ServiceLevel = Convert.ToString(dt.Rows[0]["ServiceLevel"]);
                        faceurl = Convert.ToString(dt.Rows[0]["avatar"]);
                        //clsSharedHelper.WriteInfo(faceurl);
                    }
                }
                para.Clear();
                dt.Clear();
            }            
        }
        picvip = cid;


        int vipid = 0;
        int.TryParse(Session["vipid"].ToString(), out vipid);


        string sqlcomm = @"select a.kh,a.xm,a.yddh,b.wxHeadimgurl,b.wxOpenid from YX_T_Vipkh a inner join wx_t_vipBinging b on a.id=b.vipid where b.wxOpenid =@openid";


        para.Add(new SqlParameter("@openid", openid));
        using (LiLanzDALForXLM dal = new LiLanzDALForXLM(DBConStr_tlsoft))
        {
            string errInfo = dal.ExecuteQuerySecurity(sqlcomm, para, out dt);
            if (errInfo == "")
            {
                //clsSharedHelper.WriteInfo("123");
                //Session["wxOpenid"] = reader["wxOpenid"].ToString();  //测试用
                if (dt.Rows.Count > 0)
                {
                    cname = Convert.ToString(dt.Rows[0]["xm"]);
                    wxHeadimgurl = Convert.ToString(dt.Rows[0]["wxHeadimgurl"]);
                    kh = Convert.ToString(dt.Rows[0]["kh"]);
                }
                else
                {
                    Response.Redirect("vipBinging_v2.aspx?cid=" + cid);
                }
                //  labelCard.Text = reader[0].ToString().Trim();
            }
            else
            {
                Response.Redirect("vipBinging_v2.aspx?cid=" + cid);
            }
        }

    }
</script>
<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <title>个人中心</title>
    <meta name="viewport" content="width=device-width, initial-scale=1.0, user-scalable=no,maximum-scale=1.0,minimum-scale=1.0" />
    <meta http-equiv="pragma" content="no-cache" />
    <meta http-equiv="Cache-Control" content="no-cache, must-revalidate" />
    <meta http-equiv="expires" content="Wed, 26 Feb 1978 08:21:57 GMT" />
    <meta http-equiv="Expires" content="0" />
    <meta http-equiv="Progma" content="no-cache" />
    <meta http-equiv="cache-control" content="no-cache,must-revalidate" />
    <style type="text/css">
        * {
            padding: 0;
            margin: 0;
        }

        body {
            background-color: #ececec;
            margin-bottom: 60px;
        }

        ul {
            list-style: none;
        }

        a {
            text-decoration: none;
        }

            a:link, a:visited {
                color: #000;
            }

        html {
            font-family: "微软雅黑";
        }

        #topCon {
            width: 100%;
            background-color: #333;
            box-shadow: 0px 0px 2px #555;
            position:relative;
            overflow:hidden;
        }

        #FaceImage {
            margin: 0 auto;
            padding-top: 35px;
            width: 80px;
            height: 80px;
            -webkit-animation: getin 1s ease-out;
        }

            #FaceImage img {
                border-radius: 40px;
                padding: 4px;
                border: 1px solid #999;
            }

        #nicname 
        {

            margin: 0 auto;
            margin-top: 10px;
            width: 100px;
            text-align: center;
            white-space: nowrap;
            overflow: hidden;
            text-overflow: ellipsis;
            color: #fff;
            font-size: 1.4rem;
            -webkit-animation: getin2 1.5s ease-out;
        }

        #beans {
            background-color: #fff;
            background: rgba(255,255,255,0.4);
            margin: 5px auto 0px auto;
            padding: 4px 8px;
            width: auto;
            display: inline-block;
            text-align: center;
            white-space: nowrap;
            overflow: hidden;
            text-overflow: ellipsis;
            color: #fff;
            font-size: 15px;
            border-radius: 15px;
            max-width: 150px;
            min-width: 50px;
            -webkit-animation-delay: 1s;
            -webkit-animation: getin2 1.5s ease-out;
        }
           #No 
           {
           	background-color: #fff;
            background: rgba(255,255,255,0.4);
            margin: 5px auto 0px auto;
            border-radius: 15px;
            margin-top: 5px;
            width: 120px;
            text-align: center;
            white-space: nowrap;
            overflow: hidden;
            color: #fff;
            font-size: 0.8rem;
             -webkit-animation-delay: 1s;
            -webkit-animation: getin2 1.5s ease-out;
        }
        .downBtns {
            margin: 20px auto 15px auto;
            padding-top: 10px;
            padding-bottom: 14px;
            width: 90%;
            border-top: 1px solid rgb(154,154,154);
        }

        #btns li {
            width: 50%;
            text-align: center;
            float: left;
            color: #ccc;
            font-size: 18px;
        }

            #btns li:first-child {
                box-sizing: border-box;
                border-right: 1px solid #ccc;
            }

        #bodyCon .menus {
            box-shadow: 0px 0px 2px #c8c7cc;
        }

            #bodyCon .menus li {
                padding: 0px 20px;
                height: 40px;
                line-height: 40px;
                font-size: 16px;
                background-color: #fff;
                border-bottom: 1px solid #e3e3e3;
            }

                #bodyCon .menus li:last-child {
                    border-bottom: none;
                }

                #bodyCon .menus li:hover {
                    cursor: pointer;
                }

                #bodyCon .menus li:active {
                    background-color: rgb(217,217,217);
                }

        .menu-icon {
            float: right;
            
        }

     .menu-icon img{
           margin-top:0.6em;
            
        }
        @-webkit-keyframes getin {
            0% {
                opacity: 0;
                -webkit-transform: translateY(60px);
            }

            100% {
                opacity: 1;
                -webkit-transform: translateY(0px);
            }
        }

        @-webkit-keyframes getin2 {
            0% {
                opacity: 0;
                -webkit-transform: translateY(60px);
            }

            50% {
                opacity: 0;
                -webkit-transform: translateY(30px);
            }

            100% {
                opacity: 1;
                -webkit-transform: translateY(0px);
            }
        }
         
        #filebox {
            visibility: hidden;
        }

        .floatfix:after {
            content: "";
            display: table;
            clear: left;
        }
        #topCon1 {
            width: 100%;
            background-color: #333;
            box-shadow: 0px 0px 2px #555;
        }

        #FaceImage1 {
            margin: 0 auto;
            padding-top: 35px;
            width: 80px;
            height: 80px;
            
        }

            #FaceImage1 img {
                border-radius: 40px;
                padding: 4px;
                border: 1px solid #999;
            }

        #nicname1 
        {

            margin: 0 auto;
            margin-top: 10px;
            width: 150px;
            text-align: center;
            white-space: nowrap;
            overflow: hidden;
            
            color: #fff;
            font-size: 1.4rem;
            
        }
        #nicname2 
        {

            margin: 0 auto;
            margin-top: 10px;
            width: 150px;
            text-align: center;
            white-space: nowrap;
            overflow: hidden;

            color: #fff;
            font-size: 1.4rem;

        }
        #btns1 li {
            width: 50%;
            text-align: center;
            float: left;
            color: #ccc;
            font-size: 18px;
        }
        #btns1 li:first-child {
                box-sizing: border-box;
                border-right: 1px solid #ccc;
            }
        #FaceImage2 img {
                border-radius: 40px;
                padding: 4px;
                border: 1px solid #999;
            }
       #FaceImage3 img {
                border-radius: 40px;
                padding: 4px;
                border: 1px solid #999;
            }
       #dgbtn {            
            position:absolute;
            color:#e0e0e0;
            right:15px;
            top:10px;
            font-size:0.8em;
            border: 1px solid #161A1C;           
            font-weight:bold;
            letter-spacing:1px;
            padding:5px 8px;
            border-radius:4px;
        }
        #dgcard {
            position: absolute;
            top: 10px;
            width: 100%;
            left: 2%;
            background-color: #fff;
            height: 180px;
            border-radius: 5px;
            box-shadow: 0 0 2px #ccc;
            padding: 10px;
            box-sizing: border-box;
            z-index: 1000;
            overflow: hidden;
            -webkit-transition: -webkit-transform 400ms cubic-bezier(0.42, 0, 0.58, 1) 0.1s;
            -ms-transition: transform 400ms cubic-bezier(0.42, 0, 0.58, 1) 0.1s;
            transition: transform 400ms cubic-bezier(0.42, 0, 0.58, 1) 0.1s;
        }

        .dgimg {
            width: 70px;
            height: 70px;
            position: absolute;
            top:50%;
            left:50%;
            margin-top:-35px;
            margin-left:-35px;
        }
            .dgimg img {
                width:100%;
                height:100%;
                border-radius:50%;
                border: 1px solid #999;
                padding:4px;
                box-sizing:border-box;
            }

        .dgname {
            text-align:center;
            color:#333;
            font-size:1.2em;
            font-weight:bold;
        }
        .dgleft, .dgright {
            position:relative;            
            width:50%;
            height:100%;
            box-sizing:border-box;
            float:left;
        }
        .dgleft {
            border-right:1px solid #eee;
        }
        .dgright {
            padding:10px;
            text-align:center; 
            position:relative;                       
        }
        .dginfo {
            width:100%;
        }
        .dgtitle {
            font-weight:bold;
        }
        .center-translate {
            position: absolute;
            top: 30%;
            left: 50%;
            -webkit-transform: translate(-50%, -50%);
            transform: translate(-50%, -50%);
        }
        .get-out {
            -webkit-transform: translate3d(120%, 0, 0);
            transform: translate3d(120%, 0, 0);
        }
        #shut{
            width:9%;
            height:18%;
	        float:right;
	        margin-right:10px;
	        background:url('../../img/delete.png') no-repeat 0px 0px;
        }
        #shut:hover{
	    background:url('../../img/delete.png') no-repeat 0px -32px;
        }
    </style>
</head>
<body>
    <form id="myInfo" runat="server">
    <div id="topCon">
        <div id="dgbtn">
            专属导购</div>
        <div id="dgcard" class="get-out">
            <div id="shut">
            </div>
            <div class="dgleft">
                <div class="dgimg">
                    <img src="<%=faceurl %>" alt="" />
                </div>
            </div>
            <div class="dgright">
                <div class="dginfo center-translate">
                    <p>
                        <span class="dgtitle">导购姓名：</span><span><%=dgname%></span></p>
                    <p>
                        <span class="dgtitle">服务等级：</span><span><%=ServiceLevel%></span></p>
                </div>
            </div>
        </div>
        <div id="FaceImage" onclick="CheoosFaceImg()">
            <img width="70" height="70" src="<%=wxHeadimgurl %>" alt="头像" />
        </div>
        <div id="nicname">
            <%=cname%></div>
        <div style="text-align: center">
            <p id="No">
                №:<%=kh%></p>
        </div>
        <div class="downBtns">
            <ul id="btns" class="floatfix">
                <li onclick="signIn()">签&nbsp;&nbsp;到</li>
                <li onclick="SkipTo('Edit')">详&nbsp;&nbsp;情</li>
            </ul>
        </div>
    </div>
    <div id="bodyCon">
        <ul class="menus">
            <li onclick="SkipTo('BeansDetail')">积分记录<span class="menu-icon"><img width="15" height="15"
                src="../../img/menu-right.png" alt="" /></span></li>
            <li onclick="SkipTo('MyPurchase')"><a href="#">消费记录</a><span class="menu-icon"><img
                width="15" height="15" src="../../img/menu-right.png" alt="" /></span></li>
            <li onclick="SkipTo('MySign')"><a href="#">签到记录</a><span class="menu-icon"><img width="15"
                height="15" src="img/menu-right.png" alt="" /></span></li>
            <li><a href="#">更多功能，敬请期待...</a><span class="menu-icon"><img width="15" height="15"
                src="../../img/menu-right.png" alt="" /></span></li>
        </ul>
    </div>
    <input id="cidVal" type="hidden" value="<%=cid %>" />
    </form>
    <script type="text/javascript" src="../../jquery-1.7.min.js"></script>
    <script type="text/javascript" src="../../js/LocalResizeIMG.js"></script>
    <script type="text/javascript" src="../../js/mobileBUGFix.mini.js"></script>
    <script type="text/javascript" src="../../js/sweet-alert.min.js"></script>
    <script type="text/javascript" src="../../js/jquery.js"></script>
    <link rel="stylesheet" href="../../css/sweet-alert.css" />
    <script type="text/javascript">
        function signIn() {//签到
            $.ajax({
                url: "../../ProcessingPage.aspx",
                type: "POST",
                data: { ctrl: "signIn", cid: $("#cidVal").val() },
                dataType: "HTML",
                timeout: 30000,
                error: function (XMLHttpRequest, textStatus, errorThrown) {
                    //  alert(XMLHttpRequest);
                    swal("好像出了点问题", "请稍后再试", "error");
                },
                success: function (result) {
                    if (result == "True") {
                        swal("您今天已签到过了哦!");
                    } else {
                        swal("签到成功", "", "success");
                    }
                }
            });
        }
        function SkipTo(t) {
            if (t == "Edit") {
                window.location.href = "../../Info_v2.aspx?cid=" + $("#cidVal").val();

            } else if (t == "MyPurchase") {//消费记录
                window.location.href = "../../PurchaseHistory_v2.aspx?cid=" + $("#cidVal").val();
            } else if (t == "MySign") {
                window.location.href = "../../signInRecord_v2.aspx?cid=" + $("#cidVal").val();
            } else if (t == "BeansDetail") {
                window.location.href = "../../vipScore_v2.aspx?cid=" + $("#cidVal").val();
            }
            else {
                swal("正在努力开发中..");
            }

        }
        function divDisplay() {
            var divD = document.getElementById("topCon");
            if (divD.style.display == "none") { divD.style.display = "block"; }
            else { divD.style.display = "none"; }
            var divV = document.getElementById("topCon1");
            if (divV.style.display == "none") { divV.style.display = "block"; }
            else { divV.style.display == "none" }
        }
        function divVisibility() {
            var divD = document.getElementById("topCon");
            if (divD.style.display == "block") { divD.style.display = "none"; }
            else { divD.style.display = "block"; }
            var divV = document.getElementById("topCon1");
            if (divV.style.display == "block") { divV.style.display = "none"; }
            else { divV.style.display == "block" }
        }
        //        function showOKMsg() {
        //            var id = "msg";
        //            var $tpl = $($('#tpl_' + id).html()).addClass('slideIn').addClass(id);
        //            $container.append($tpl);
        //            stack.push($tpl);
        //            history.pushState({ id: id }, '', '#' + id);

        //            $($tpl).on('webkitAnimationEnd', function () {
        //                $(this).removeClass('slideIn');
        //            }).on('animationend', function () {
        //                $(this).removeClass('slideIn');
        //            });
        //        }
        $("#dgbtn").click(function () {
            //alert(1);
            $("#dgcard").removeClass("get-out");
        });
        $("#shut").click(function () {
            $("#dgcard").addClass("get-out");
        });
    </script>
</body>
</html>
