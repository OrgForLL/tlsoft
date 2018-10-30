<%@ Page Language="C#" Debug="true" %>
<%@ Import Namespace="System.Data" %>
<%@ Import Namespace = "nrWebClass" %>
<%@ Import Namespace="System.Collections.Generic" %>
<%--<%@ Register src="wx_header.ascx" tagname="wx_header" tagprefix="uc1" %>--%>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<script runat="server">
    public string picvip = "";
	public string cid;
    public string cname = "";
    public string wxHeadimgurl = "img/initial_img.png";
    public string beans = "0";
    public string kh = "";
    private const string ConfigKeyValue = "5";
    protected void Page_Load(object sender, EventArgs e)
    {

        //String ip = "123";
        //clsSharedHelper.WriteInfo("访问111111111111111111111111111");
        cid = Request.QueryString["cid"].ToString();
        //Console.Write(cid);
      
        //return;
        string openid = "";
        ////String ip = "123";

        if (clsWXHelper.CheckUserAuth(ConfigKeyValue, "openid"))
        {

            openid = Convert.ToString(Session["openid"]);
            clsSharedHelper.WriteInfo(openid);
            return;

        }
        else
        {
            //clsSharedHelper.WriteInfo(cid);
            //Response.Write("12113");
            //Response.End();
            openid = "";
            clsSharedHelper.WriteInfo(openid);
            return;
        }

        picvip = cid;
        DAL.SqlDbHelper dbHelper = new DAL.SqlDbHelper(cid);
        int vipid = 0;
        int.TryParse(Session["vipid"].ToString(), out vipid);
        if (vipid != 0)
        {
            // Session["vipid"] = vipid;
            string sqlcomm = String.Format("select a.kh,a.xm,a.yddh,b.wxHeadimgurl,b.wxOpenid from YX_T_Vipkh a inner join wx_t_vipBinging b on a.id=b.vipid where a.id = {0}", vipid);
            using (IDataReader reader = dbHelper.ExecuteReader(sqlcomm))
            {
                if (reader.Read())
                {
                    //Session["wxOpenid"] = reader["wxOpenid"].ToString();  //测试用
                    cname = reader[1].ToString();
                    wxHeadimgurl = reader[3].ToString();
                    kh = reader["kh"].ToString();
                    //  labelCard.Text = reader[0].ToString().Trim();
                }
                else
                {
                    Response.Redirect("vipBinging.aspx?cid=" + cid);
                }
            }
        }
        else
        {
            Response.Redirect("vipBinging.aspx?cid=" + cid);
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
    </style>
</head>
<body>
       <form id="myInfo" runat="server">
        <div id="topCon">
            <div id="FaceImage" onclick="CheoosFaceImg()">
                <img width="70" height="70" src="<%=wxHeadimgurl %>" alt="头像" />
            </div>
            <div id="nicname"><%=cname%></div>
             <div style="text-align: center">
                <p id="No">№:<%=kh%></p>
            </div>
           <%-- <div style="text-align: center">
                <p id="beans">积分:<%=beans%></p>
            </div>--%>
            <div class="downBtns">
                <ul id="btns" class="floatfix">
                    <li onclick="signIn()">签&nbsp;&nbsp;到</li>
                    <li onclick="SkipTo('Edit')">详&nbsp;&nbsp;情</li>
                </ul>
            </div>
        </div>
        <div id="bodyCon">
            <ul class="menus">
                <li onclick="SkipTo('BeansDetail')">积分记录<span class="menu-icon"><img width="15" height="15" src="img/menu-right.png" alt=""/></span></li>
                <li onclick="SkipTo('MyPurchase')"><a href="#">消费记录</a><span class="menu-icon"><img width="15" height="15" src="img/menu-right.png" alt="" /></span></li>
                <li onclick="SkipTo('MySign')"><a href="#">签到记录</a><span class="menu-icon"><img width="15" height="15" src="img/menu-right.png" alt="" /></span></li>
                <li><a href="#">更多功能，敬请期待...</a><span class="menu-icon"><img width="15" height="15" src="img/menu-right.png" alt="" /></span></li>
            </ul>
        </div>
        <input id="cidVal" type="hidden" value="<%=cid %>" />
    </form>
        <script type="text/javascript" src="jquery-1.7.min.js"></script>
    <script type="text/javascript" src="js/LocalResizeIMG.js"></script>
    <script type="text/javascript" src="js/mobileBUGFix.mini.js"></script>
    <script type="text/javascript" src="js/sweet-alert.min.js"></script>
    <link rel="stylesheet" href="css/sweet-alert.css" />
    <script type="text/javascript" >
        function signIn() {//签到
            $.ajax({
                url: "ProcessingPage.aspx",
                type: "POST",
                data: { ctrl: "signIn", cid:$("#cidVal").val() },
                dataType: "HTML",
                timeout: 30000,
                error: function (XMLHttpRequest, textStatus, errorThrown) {
                    //  alert(XMLHttpRequest);
                    swal("好像出了点问题", "请稍后再试", "error");
                },
                success: function (result) {
                    if (result=="True") {
                        swal("您今天已签到过了哦!");  
                    } else {
                        swal("签到成功", "", "success");
                    }
                }
            });
        }
        function SkipTo(t) {
            if (t == "Edit") {
                window.location.href = "Info_v2.aspx?cid=" + $("#cidVal").val();

            } else if (t == "MyPurchase") {//消费记录
                window.location.href = "PurchaseHistory_v2.aspx?cid=" + $("#cidVal").val();
            } else if (t == "MySign") {
                window.location.href = "signInRecord_v2.aspx?cid=" + $("#cidVal").val();
            } else if (t == "BeansDetail") {
                window.location.href = "vipScore_v2.aspx?cid=" + $("#cidVal").val();
            }
            else {
                swal("正在努力开发中..");
            } 

        }
    </script>
</body>
</html>
