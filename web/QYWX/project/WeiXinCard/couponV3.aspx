<%@ Page Language="C#" %>

<%@ Import Namespace="nrWebClass" %>
<%@ Import Namespace="System.Data.SqlClient" %>
<%@ Import Namespace="System.Data" %>
<%@ Import Namespace="System.Collections.Generic" %>
<!DOCTYPE html>
<script runat="server">
    public string roleName = "";
    public string tzid = "";
    
    protected void Page_Load(object sender, EventArgs e) {        
         if (clsWXHelper.CheckQYUserAuth(true))
         {            
        //     string strSystemKey = clsWXHelper.GetAuthorizedKey(3);    
        //     if (string.IsNullOrEmpty(strSystemKey)) {
        //         clsWXHelper.ShowError("超时 或 没有全渠道权限！");
        //         return;
        //     }

             roleName = Convert.ToString(Session["RoleName"]);
             tzid = Convert.ToString(Session["tzid"]);

             if( !roleName.Equals("dz") && !roleName.Equals("my") ) {
                 clsWXHelper.ShowError("您没有使用权限！");
             }
        } 
    }

    /// <summary>
    /// 获取缩略图路径
    /// </summary>
    /// <param name="imgUrlHead"></param>
    /// <param name="sourceImage"></param>
    /// <returns></returns>
</script>

<html>

<head>
    <title>新建卡券</title>
    <meta http-equiv="X-UA-Compatible" content="IE=edge,chrome=1">
    <meta name="renderer" content="webkit">
    <meta http-equiv="content-type" content="text/html; charset=UTF-8" />
    <meta name="viewport" content="width=device-width, initial-scale=1,user-scalable=0,maximum-scale=1" />
    <link rel="stylesheet" href="../../res/css/LeePageSlider.css" />
    <link rel="stylesheet" href="../../res/css/WeiXinCard/iconfont.css" />
    <link rel="stylesheet" href="../../res/css/WeiXinCard/couponV3.css" />
</head>

<body>
    <div class="wrap-page">
        <div class="page">
            <div class="coupon">
                <div class="title" id="discount">
                    <i class="iconfont">&#xe60d;</i>
                    <div>
                        <p>折扣券</p>
                        <p class="en-title">Discount Coupons</p>
                    </div>
                </div>
                <div class="options">
                    <ul>
                        <li class="tyzk" data-type="1">
                            <p>通用折扣</p>
                            <i class="iconfont">&#xe626;</i>
                        </li>
                        <li class="plzk" data-type="2">
                            <p>品类折扣</p>
                            <i class="iconfont">&#xe626;</i>
                        </li>
                    </ul>
                </div>
            </div>
            <div class="coupon">
                <div class="title" id="offset">
                    <i class="iconfont">&#xe60d;</i>
                    <div>
                        <p>抵用券</p>
                        <p class="en-title">Vouchers</p>
                    </div>
                </div>
                <div class="options">
                    <ul>
                        <li class="xedy" data-type="3">
                            <p>限额抵用</p>
                            <i class="iconfont">&#xe626;</i>
                        </li>
                        <li class="pldy" data-type="4">
                            <p>品类抵用</p>
                            <i class="iconfont">&#xe626;</i>
                        </li>
                        <li class="wmkdy" data-type="5">
                            <p>无门坎抵用</p>
                            <i class="iconfont">&#xe626;</i>
                        </li>
                    </ul>
                </div>
            </div>
        </div>
    </div>
    <script type="text/javascript" src="../../res/js/jquery.js"></script>
    <script type="text/javascript">
        $(function() {
            $(".options li").click(function() {
                var type = $(this).attr("data-type");
                /* if (type == '3' || type == '4' || type == '5') {
                    alert('抵用券功能正在升级，敬请期待！');
                    return null;
                } */
                window.location.href = "increateV3.aspx?type="  + type;
                // window.showModalDialog("increateV3.aspx?type="  + type);
            });
        });
    </script>
</body>

</html>
