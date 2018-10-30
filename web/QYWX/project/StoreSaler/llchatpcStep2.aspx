<%@ Page Title="" Language="C#" MasterPageFile="../../WebBLL/frmQQDBase.Master" AutoEventWireup="true" %>

<%@ MasterType VirtualPath="../../WebBLL/frmQQDBase.Master" %>

<%@ Import Namespace="nrWebClass" %> 
<%@ Import Namespace="System.Collections.Generic" %> 
<%@ Import Namespace="System.Data.SqlClient" %>

<script runat="server">
 
    public string UserName = "";
    protected void Page_PreRender(object sender, EventArgs e)
    {
        string BindKey = this.Master.AppSystemKey;
        if (BindKey == "")
        {
            clsWXHelper.ShowError("您还未激活全渠道系统的使用权限！");
        }
        else
        {
            string QrCodeValue = Convert.ToString(Request.Params["c"]);
            
            if (QrCodeValue == "")  clsWXHelper.ShowError("页面非法访问！缺少参数：c");
           
            string ConWX = ConfigurationManager.ConnectionStrings["Conn"].ConnectionString; //连接62
            using (LiLanzDALForXLM dalWX = new LiLanzDALForXLM(ConWX))
            {
                UserName = Convert.ToString(Session["qy_cname"]);
                string mdid = Convert.ToString(Session["mdid"]); 

                string strSql = @"
                        IF EXISTS (SELECT TOP 1 ID FROM wx_t_ChatPcLogin WHERE QrCodeValue = @QrCodeValue)  SELECT 0    --已经存在
                        ELSE 
                        BEGIN
                            INSERT INTO wx_t_ChatPcLogin (QrCodeValue,OcuID,LoginName,LoginMdid) VALUES (@QrCodeValue,@OcuID,@LoginName,@LoginMdid)
                            SELECT @@IDENTITY
                        END";

                List<SqlParameter> param = new List<SqlParameter>();

                param.Add(new SqlParameter("@QrCodeValue", QrCodeValue));
                param.Add(new SqlParameter("@OcuID", BindKey));
                param.Add(new SqlParameter("@LoginName", UserName));
                param.Add(new SqlParameter("@LoginMdid", mdid));
                System.Data.DataTable dt;
                string strInfo = dalWX.ExecuteQuerySecurity(strSql, param,out dt);
                if (strInfo == "")
                {
                    int rt = Convert.ToInt32(dt.Rows[0][0]);
                    if (rt == 0)
                    {
                        clsLocalLoger.WriteError(string.Concat("微信PC管理端登录失败！原因重复扫码！"));
                        clsWXHelper.ShowError("一个二维码只能扫描使用一次！");
                    } 
                }
                else
                {
                    clsLocalLoger.WriteError(string.Concat("微信PC管理端登录失败！错误：", strInfo));
                    clsWXHelper.ShowError("PC管理端登录失败，请重试！");                    
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
            margin-left: 0;
            overflow: hidden;
            white-space: nowrap;
            text-overflow: ellipsis;
        } 
        .area {
            font-size: 14px;
            color: #808080;
            font-weight: normal;
            line-height: 40px;
        }
         
    </style>
</asp:Content>
<asp:Content ID="Content2" ContentPlaceHolderID="ContentPlaceHolder1" runat="server">

    <div class="container">
        <div class="qrcode">
            <div class="qrcon center-translate">               
                <p class="wxnick area"><%= UserName %>，您好！</p>  
                <p class="wxnick area">您的登录操作已验证成功！</p>   
                <p class="wxnick area">请从继续Step2，完成登录！</p>               
            </div>
        </div>
    </div>

</asp:Content>
