<%@ Page Language="C#" %>

<%@ Import Namespace="nrWebClass" %>
<%@ Import Namespace="System.Data.SqlClient" %>
<%@ Import Namespace="System.Data" %>
<%@ Import Namespace="System.IO" %>
<%@ Import Namespace="System.Reflection" %>
<%@ Import Namespace="Newtonsoft.Json" %>
<%@ Import Namespace="System.Collections.Generic" %>
<!DOCTYPE html>
<script runat="server">
    private static string OAConnStr = clsConfig.GetConfigValue("OAConnStr");
    public string roleName = "";
    public string tzid = "";
    public string qy_customersid = "";
    public string brandname = "利郎男装 利郎轻商务";
    public string khfl = "";
    
    protected void Page_Load(object sender, EventArgs e) {        
        if (clsWXHelper.CheckQYUserAuth(true))
        {            

            string strSystemKey = clsWXHelper.GetAuthorizedKey(3);
            if (string.IsNullOrEmpty(strSystemKey)) {
                clsWXHelper.ShowError("超时 或 没有全渠道权限！");
                return;
            }

            OAConnStr = "server=192.168.35.10;database=tlsoft;uid=ABEASD14AD;pwd=+AuDkDew";
            roleName = Convert.ToString(Session["RoleName"]);
            tzid = Convert.ToString(Session["tzid"]);
            qy_customersid = Convert.ToString(Session["qy_customersid"]);
            DataTable dt;

            if( roleName.Equals("dz") || roleName.Equals("my") || roleName.Equals("dg") ) {
                List<SqlParameter> paras = new List<SqlParameter>();
                string errInfo, mysql;

                if(roleName.Equals("my"))
                {
                    mysql = @"SELECT c.khid, c.khfl 
                            FROM  dbo.wx_t_customers a 
                            INNER JOIN dbo.wx_t_Deptment b ON a.department=b.wxid AND b.deptType='my'
                            INNER JOIN yx_T_khb c ON b.id=c.khid  AND a.id=@uid";
                    paras.Add(new SqlParameter("@uid", qy_customersid));
                }
                else
                {
                    mysql = "select khid,khfl from yx_t_khb where khid=@khid";
                    paras.Add(new SqlParameter("@khid", tzid));
                }

                using (LiLanzDALForXLM dal = new LiLanzDALForXLM(OAConnStr))
                {
                    errInfo = dal.ExecuteQuerySecurity(mysql, paras, out dt);
                }

                if (errInfo != "")
                {
                    clsLocalLoger.Log("【移动端微信卡券出错】：" + errInfo);
                    return;
                }

                if (dt.Rows.Count > 0)
                {
                    khfl = Convert.ToString(dt.Rows[0]["khfl"]);
                }
                clsSharedHelper.DisponseDataTable(ref dt);

                if(khfl == "xm" || khfl == "xn" || khfl == "xk")
                {
                    brandname = "利郎轻商务";
                }
                else
                {
                    brandname = "利郎男装";
                }

            }else {
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
    <title>卡包</title>
    <meta http-equiv="content-type" content="text/html; charset=UTF-8" />
    <meta name="viewport" content="width=device-width, initial-scale=1,user-scalable=0,maximum-scale=1" />
    <link rel="stylesheet" href="../../res/css/LeePageSlider.css" />
    <link rel="stylesheet" href="../../res/css/WeiXinCard/iconfont.css" />
    <link rel="stylesheet" href="../../res/css/WeiXinCard/index.css" />
</head>

<body>
    <div class="wrap-page">
        <div class="page">
            <p class="title">所属公众号：<%=brandname %></p>
            <div class="logo">
                <img src="../../res/img/WeiXinCard/icon_coupon.png">
            </div>
            <div id="exist" class="coupon">
                <i class="iconfont">&#xe602;</i>
                <div>
                    <p>已有卡券</p>
                    <p class="en-name">Has A Card</p>
                </div>
                <i class="iconfont">&#xe626;</i>
            </div>
            <div id="create" class="coupon">
                <i class="iconfont">&#xe66a;</i>
                <div>
                    <p>新建卡券</p>
                    <p class="en-name">New Coupons</p>
                </div>
                <i class="iconfont">&#xe626;</i>
            </div>
            <div id="grant" class="coupon">
                <i class="iconfont">&#xe60d;</i>
                <div>
                    <p>发放卡券</p>
                    <p class="en-name">Issuing Coupons</p>
                </div>
                <i class="iconfont">&#xe626;</i>
            </div>
        </div>
    </div>
    <script type="text/javascript" src="../../res/js/jquery-3.2.1.min.js"></script>
    <script type="text/javascript">
    $(function() {
        var roleName = "<%=roleName %>";

        if(roleName == "my") {
            $("#create").hide();
            $("#grant").hide();
        }else if(roleName == "dg") {
            $("#create").hide();
            $("#exist").hide();
        }

        $("#exist").click(function() {
            window.location.href = "existing.aspx";
            // prompt();
        });

        $("#create").click(function() {
            // window.location.href = "coupon.aspx";
            prompt();
        });

        $("#grant").click(function() {
            window.location.href = "CardListv2.aspx";
            // prompt();
        });

        function prompt () {
            alert('卡券创建和审核功能已移到ERP，请在ERP的微信卡券中进行创建和审核。');
        }
    });
    </script>
</body>

</html>
