<%@ Page Title="邀请会员" Language="C#" MasterPageFile="../../WebBLL/frmQQDBase.Master" AutoEventWireup="true" %>

<%@ MasterType VirtualPath="../../WebBLL/frmQQDBase.Master" %>

<%@ Import Namespace="nrWebClass" %>


<script runat="server">
    public string BindKey = "";       //等同于人员ID
    public string strMdmc = "";
    public string strFace = "";
    public string strCname = "";
    public string testUrl = "";
    public string skhid = "", smdid = "";
    
    protected void Page_PreRender(object sender, EventArgs e)
    {
        string SystemKey = this.Master.AppSystemKey;
        BindKey = SystemKey;
        if (SystemKey == "")
        {
            clsSharedHelper.WriteErrorInfo("您还未激活全渠道系统的使用权限！");
        }
        else
        {
            clsWXHelper.CheckQQDMenuAuth(6);    //检查菜单权限

            skhid = Convert.ToString(Session["tzid"]);
            smdid = Convert.ToString(Session["mdid"]);
            //请注意：文件部署在正式环境和测试环境所生成的二维码路径是不一样的。    
            //GetQrCode.aspx 后缀参数在测试环境中 域名后面还需要加入 %2fQYWX ，在正式环境中则不要
            string myUrl = Request.Url.AbsoluteUri;
            if (myUrl.ToLower().Contains("tm.lilanz.com/qywx/"))    //如果这个路径是测试系统，则输出附加QYWX，使扫描结果指向231；否则不附加QYWX，扫描结果直接到15下的VIP
            {
                testUrl = "%2fQYWX";
            }

            string strInfo = "";
            string Conn = clsConfig.GetConfigValue("OAConnStr");
            string ConWX = ConfigurationManager.ConnectionStrings["Conn"].ConnectionString; //连接62
            using (LiLanzDALForXLM dalWX = new LiLanzDALForXLM(ConWX))
            {
                using (LiLanzDALForXLM dal = new LiLanzDALForXLM(Conn))
                {
                    object objmdmc = "";
                    strInfo = dal.ExecuteQueryFast(string.Concat("SELECT TOP 1 mdmc FROM t_MDb WHERE mdid=", Session["mdid"]), out objmdmc);
                    if (strInfo == "")
                    {
                        strMdmc = Convert.ToString(objmdmc);

                        //获取店员头像
                        object objavatar = "";

                        string strSQL = string.Format(@"SELECT TOP 1 C.avatar,A.Nickname FROM wx_t_OmniChannelUser A
                                INNER JOIN wx_t_AppAuthorized B ON A.ID = B.SystemKey AND B.SystemID = 3
                                INNER JOIN wx_t_customers C ON B.UserID = C.ID 
                                WHERE A.ID = {0} order by c.avatar desc", SystemKey);

                        System.Data.DataTable dt;
                        strInfo = dalWX.ExecuteQuery(strSQL, out dt);
                        if (strInfo == "")
                        {
                            if (dt.Rows.Count == 0)
                            {
                                clsLocalLoger.WriteError(string.Concat("没有获取到头像和昵称信息！strSQL=", strSQL));
                                clsWXHelper.ShowError("没有获取到头像和昵称信息！");
                            }
                            else
                            {
                                strFace = Convert.ToString(dt.Rows[0]["avatar"]);
                                strCname = Convert.ToString(dt.Rows[0]["Nickname"]);

                                if (clsWXHelper.IsWxFaceImg(strFace))
                                {
                                    strFace = clsWXHelper.GetMiniFace(strFace);
                                }
                                else
                                {
                                    strFace = string.Concat("../../" , strFace);
                                }   
                            }
                        }
                        else
                        {
                            clsLocalLoger.WriteError(string.Concat("获取头像失败！错误：" + strInfo));
                            clsWXHelper.ShowError("获取头像失败！");
                        }
                    }
                    else
                    {
                        clsLocalLoger.WriteError(string.Concat("获取门店名称失败！错误：" + strInfo));
                        clsWXHelper.ShowError("获取门店名称失败！");
                    }
                }
            }
        }
    }
</script>


<asp:Content ID="Content1" ContentPlaceHolderID="head" runat="server">
    <style type="text/css">
        * {
            padding: 0;
            margin: 0;
        }

        body {
            font-family: Helvetica,Arial,"Hiragino Sans GB","Microsoft Yahei","微软雅黑",STHeiti,"华文细黑",sans-serif;
            font-size: 14px;
            color: #333;
            background-color: #f0f0f0;
        }

        .qrcode {
            position: fixed;
            left: 0;
            right: 0;
            top: 0;
            bottom: 0;
            background: #2d3132;
        }

        .qrcon {
            background: #fff;
            border-radius: 4px;
            width: 80%;
            padding: 20px;
            max-width: 480px;
            box-sizing: border-box;
            overflow: hidden;
        }

        .center-translate {
            position: absolute;
            top: 50%;
            left: 50%;
            -webkit-transform: translate(-50%, -50%);
            transform: translate(-50%, -50%);
        }

        .qrcon .headimg {
            float: left;
            border-radius: 6px;
        }

        .qrcon .wxnick {
            letter-spacing: 0px;
            font-weight: bold;
            margin-left: 74px;
            overflow: hidden;
            white-space: nowrap;
            text-overflow: ellipsis;
        }

        .qrcon img {
            width: 96%;
            height: auto;
            max-width: 240px;
        }

        .area {
            font-size: 14px;
            color: #808080;
            font-weight: normal;
            line-height: 40px;
        }

        .qrtxt {
            margin-top: 100px;
            width: 100%;
            text-align: center;
            position: absolute;
            left: 0;
            bottom: 10px;
            color: #808080;
        }

        .headimg 
        {            
            margin: 0 auto;
            width: 60px;
            height: 60px;
            border: 2px solid #ebebeb;
            border-radius: 50%;
            -webkit-border-radius: 50%;
            background-size: cover;                        
            background-position: 50% 50%;
            background-repeat: no-repeat;
        }
    </style>
</asp:Content>
<asp:Content ID="Content2" ContentPlaceHolderID="ContentPlaceHolder1" runat="server">

    <div class="container">
        <div class="qrcode">
            <div class="qrcon center-translate">
                <div class="headimg" style="background-image: url(<%= strFace %>)"></div>
                <p class="wxnick"><%= strCname %></p>
                <p class="wxnick area">门店：<%= strMdmc %></p>
                <p style="text-align: center; margin: 10px 0 30px 0;">
                    <img alt="二维码" src="GetQrCode.aspx?code=http%3a%2f%2ftm.lilanz.com<%= testUrl %>%2fproject%2fvipweixin%2fVSB.aspx%3fsid%3d<%= BindKey  %>%26khid%3d<%=skhid %>%26mdid%3d<%=smdid %>" />
                </p>
                <div class="qrtxt">
                    扫一扫上面的二维码图案<br />
                    就可以关注我啦！
                </div>
            </div>
        </div>
    </div>

</asp:Content>
