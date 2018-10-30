<%@ Page Language="C#" Debug="true" %>

<%@ Import Namespace="nrWebClass" %>
<%@ Import Namespace="System.Data" %>
<%@ Import Namespace="System.Data.SqlClient" %>
<%@ Import Namespace="System.Collections.Generic" %>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<script runat="server">
    public string authNum = "0";
    string connectstring = clsConfig.GetConfigValue("OAConnStr");
    protected void Page_Load(object sender, EventArgs e)
    {
        string customerID="", OpenId="";
        if (clsWXHelper.CheckQYUserAuth(false))
        {
            customerID = Convert.ToString(Session["qy_customersid"]);
            OpenId = Convert.ToString(Session["qy_OpenId"]);
        }

        if (customerID == "" && OpenId == "")
        {
            clsSharedHelper.WriteErrorInfo("鉴权出错，请重新进入");
            return;
        }
       string str_tj;
       if (customerID != "")
       {
           str_tj = "a.id=@id";
       }
       else 
       {
           str_tj = "a.wxOpenId=@OpenId";
       }
        
       string mysql = @"select a.name,a.cname,a.ID,a.mobile,a.department,a.status,
                        max(case when b.systemid=1 then b.SystemKey else 0 end) as key1,
                        max(case when b.systemid=2 then b.SystemKey else 0 end) as key2,
                        max(case when b.systemid=3 then b.SystemKey else 0 end) as key3,
                        max(case when b.systemid=4 then b.SystemKey else 0 end) as key4,
                        max(case when b.systemid=5 then b.SystemKey else 0 end) as key5,
                        max(case when b.systemid=6 then b.SystemKey else 0 end) as key6
                        from wx_t_customers a left join wx_t_AppAuthorized b on a.id=b.userid 
                        where " + str_tj + @"
                        group by  a.name,a.cname,a.ID,a.mobile,a.department,a.status";
      
       List<SqlParameter> para = new List<SqlParameter>();
       para.Add(new SqlParameter("@id", customerID));
       para.Add(new SqlParameter("@OpenId", OpenId));
       string errInfo="";
       DataTable dt;
       using (LiLanzDALForXLM dal = new LiLanzDALForXLM(connectstring))
       {
           errInfo = dal.ExecuteQuerySecurity(mysql, para, out dt);
           para = null;
       }

       if (errInfo != "")
       {
           Response.Write("WXSystemGuide.aspx:"+errInfo);
           Response.End();
       }
       else if (dt.Rows.Count < 1)//未找到个人信息
       {
           clsLocalLoger.WriteInfo("WXSystemGuide.aspx:" + "无个人信息openid=" + OpenId);
           //Session["qy_customersid"] = "";
           //Session["qy_cname"] = "";
           //Session["qy_mobile"] = "";
           //Session["qy_status"] = "0";
           //Session["qy_OpenId"] = OpenId;
       }
       else
       {
          //Session["qy_customersid"] = Convert.ToString(dt.Rows[0]["id"]);
          //Session["qy_name"] = Convert.ToString(dt.Rows[0]["name"]).Trim();
          //Session["qy_cname"] = Convert.ToString(dt.Rows[0]["cname"]);
          //Session["qy_mobile"] = Convert.ToString(dt.Rows[0]["mobile"]);
          //Session["qy_status"] =Convert.ToString(dt.Rows[0]["status"]) ;
          int Authval = 0;
          for (int i = 1; i <= 6; i++)
          {
              if (Convert.ToString(dt.Rows[0]["key" + i.ToString()]) != "0")
              {
                  Authval += Convert.ToInt32(Math.Pow(2, i-1));
              }
          }
          authNum = Convert.ToString(Authval);
       }
    }
   
</script>
<html xmlns="http://www.w3.org/1999/xhtml">
<head id="Head1" runat="server">
    <meta charset="UTF-8" />
    <meta name="viewport" content="width=device-width,initial-scale=1,user-scalable=0" />
    <title>系统自助管理</title>
    <link rel="stylesheet" href="../../res/css/weui.css" />
    <link rel="stylesheet" href="../../res/css/BandToSystem/example.css" />
    <link rel="stylesheet" href="../../res/css/sweet-alert.css" />
    <script type="text/javascript" src="../../res/js/jquery.js"></script>
    <style type="text/css">
    .weui_cell_primary i
    {
        position:absolute;
        top:50%;
        right:10px;     
        margin-top:-11.5px;
        font-size:0.8em;
        z-index:100;            
     }
    .wkt:before
     {
        color:#ccc;
     }
     .description
     {
         color:#888;
         font-size:0.8em;
     }
    </style>
</head>
<body>
    <form id="form1" runat="server">
    <input type="hidden" id="authNum" value="<%=authNum %>" />
    <div class="container js_container">
        <div class="page">
            <div class="hd">
                <h1 class="page_title">
                    微信系统管理</h1>
                <p class="page_desc">
                    请选择所要绑定开通的系统</p>
            </div>
            <div class="bd">
                <div class="weui_cells weui_cells_access global_navs">
                    <a class="weui_cell js_cell" href="javascript:gotoBand('协同系统','1');" data-id="button">
                        <span class="weui_cell_hd">
                            <img src="../../res/img/BandToSystem/b1.png" class="icon_nav" alt=""></span>
                        <div class="weui_cell_bd weui_cell_primary">
                            <p><span>协同系统</span><span style="margin-left: 1em" id="system1"></span></p>
                            <p class="description">二维码登录、移动办公</p>
                        </div>
                        <%--<div class="weui_cell_ft">
                        </div>--%>
                    </a>
                </div>
                <div class="weui_cells weui_cells_access global_navs">
                    <a class="weui_cell js_cell" href="javascript:gotoBand('人资系统','2');" data-id="button">
                        <span class="weui_cell_hd">
                            <img src="../../res/img/BandToSystem/b2.png" class="icon_nav" alt="" /></span>
                        <div class="weui_cell_bd weui_cell_primary">
                            <p>
                                <span>人资系统</span><span style="margin-left: 1em" id="system2"></span></p>
                                   <p class="description">[仅限总部]移动考勤、移动办公</p>
                        </div>
                       <%-- <div class="weui_cell_ft">
                        </div>--%>
                    </a>
                </div>
                <div class="weui_cells weui_cells_access global_navs">
                    <a class="weui_cell js_cell" href="javascript:gotoBand('零售系统','3');" data-id="button">
                        <span class="weui_cell_hd">
                            <img src="../../res/img/BandToSystem/b3.png" class="icon_nav" alt=""></span>
                        <div class="weui_cell_bd weui_cell_primary">
                            <p>
                                <span>全渠道系统</span><span style="margin-left: 1em" id="system3"></span></p>
                                <p class="description">销售神器、销售兵法、销售内功</p>
                        </div>
                    </a>
                </div>
               <div class="weui_cells weui_cells_access global_navs">
                    <a class="weui_cell js_cell" href="javascript:gotoBand('制造公司系统','4');" data-id="button">
                        <span class="weui_cell_hd">
                            <img src="../../res/img/BandToSystem/b4.png" class="icon_nav" alt=""></span>
                        <div class="weui_cell_bd weui_cell_primary">
                            <p>
                                <span>制造公司系统</span><span style="margin-left: 1em" id="system4"></span></p>   
                                  <p class="description">制造公司服务</p> 
                        </div>
                    </a>
                </div>
                <div class="weui_cells weui_cells_access global_navs">
                    <a class="weui_cell js_cell" href="javascript:gotoBand('工卡系统','5');" data-id="button">
                        <span class="weui_cell_hd">
                            <img src="../../res/img/BandToSystem/b5.png" class="icon_nav" alt=""></span>
                        <div class="weui_cell_bd weui_cell_primary">
                            <p>
                                <span>工卡系统</span><span style="margin-left: 1em" id="system5"></span></p>
                                 <p class="description">[仅限总部]食堂消费、臻咖啡</p>  
                        </div>
                    </a>
                </div>
                     <div class="weui_cells weui_cells_access global_navs">
                    <a class="weui_cell js_cell" href="javascript:gotoBand('订货会系统','6');" data-id="button">
                        <span class="weui_cell_hd">
                            <img src="../../res/img/BandToSystem/b6.png" class="icon_nav" alt=""></span>
                        <div class="weui_cell_bd weui_cell_primary">
                            <p>
                                <span>订货会系统</span><span style="margin-left: 1em" id="system6"></span></p>
                                 <p class="description">会务管理、订货数据查询</p>  
                        </div>
                    </a>
                </div>
            </div>
        </div>
    </div>
    </form>
    <script type="text/javascript" src="../../res/js/sweet-alert.min.js"></script>
    <script type="text/javascript">
         var authArray = new Array();
         function gotoBand(name, id) {
           /*  if (id == 4) {
               //  swal("开发中...", "敬请期待");
				   swal({ title: "开发中...",
                          text: "敬请期待",
                          type: "warning",
                          confirmButtonColor: "#F8BB86",
                          confirmButtonText: "确认",
                          closeOnConfirm: true
                         },
                          function () {
							      
                          });
						  return;
             }*/
             if (authArray[id] == 0) {
                 window.location.href = "SystemBand.aspx?systemid=" + id;
             } else {
                // alert("系统已绑定");
                // swal("系统已绑定!", "该系统已绑定，无需再验证!", "success");
				  swal({ title: "系统已绑定!",
                             text: "该系统已绑定，无需再验证!",
                             type: "success",
                             confirmButtonColor: "#04be02",
                             confirmButtonText: "确认",
                             closeOnConfirm: true
                         },
                              function () {
                              });
             }
         }
         window.onload = function () {
             var authVal = Number($("#authNum").val());
             if (isNaN(authVal) == true) authVal = 0;
             var keyVal;
             for (var i = 6; i > 0; i--) {
                 keyVal = Number(Math.pow(2, i - 1));
                 if (authVal >= keyVal) {
                     authArray[i] = 1;
                     authVal = authVal - keyVal;
                     $("#system" + i).html("<i class='weui_icon_success'>已绑</i>");
                 } else {
                     $("#system" + i).html("<i class='weui_icon_success wkt'></i>");
                     authArray[i] = 0;
                 }
             }
            
         }
    </script>
</body>
</html>
