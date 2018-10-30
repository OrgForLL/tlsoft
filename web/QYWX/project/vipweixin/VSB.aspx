<%@ Page Language="C#" %>
<%@ Import Namespace = "System" %>
<%@ Import Namespace = "System.Collections.Generic" %> 
<%@ Import Namespace = "System.Data" %>
<%@ Import Namespace = "System.Text" %>
<%@ Import Namespace = "nrWebClass" %>  
<%@ Import Namespace="System.Data.SqlClient" %>

<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<%--
页面说明：这个页面用于VIP绑定导购(更换导购)
开发人员：薛灵敏   开发时间：20160127
接口说明：页面将会调用 VSBCore.aspx 页面
部署说明：页面只会部署到VIP使用的公众号 【利郎男装】 WEB应用程序根目录下。
特别说明：页面的全名为：VipSalerBind.aspx 。由于页面地址最终将会以二维码的形式被访问，
          页面URL越短，页面越容易被扫描成功；反之则难以被扫描，因此页面名称应该尽可能取短。
--%>
<script runat="server"> 
    private const string ConfigKeyValue = "5";
    public string openid = "";
    public string IsSubscribe = "";
    protected void Page_Load(object sender, EventArgs e)
    {
        string BindKey = Convert.ToString(Request.Params["sid"]);

        if (BindKey == null || BindKey == "")
        {
            RedirectERR("必须扫描专属顾问的二维码");
        }
        else
        {
            if (clsWXHelper.CheckUserAuth(ConfigKeyValue, "openid"))//20160330 薛灵敏改成使用 openid鉴权
            {

                string strInfo = "";

                string ConWX = clsWXHelper.GetWxConn();
                using (LiLanzDALForXLM dalWX = new LiLanzDALForXLM(ConWX))
                {
                    openid = Convert.ToString(Session["openid"]);

                    if (Convert.ToString(Session["vipid"]) == "0")
                    {
                        //首先取得该导购sid的 RelateID 对应的 khid 和 mdid。然后无条件更新主库的粉丝表
                        //20170422 由于管理员没有relateid所以选择精确管理后再去吸粉也是没有的。以传入的khid,mdid来更新
                        /*string strSQL00 = @"DECLARE @rid INT
                                        SET @rid = 0
                                        SELECT TOP 1 @rid = RelateID FROM wx_t_OmniChannelUser WHERE ID = @sid

                                        IF @rid = 0 SELECT 0 khid,0 mdid
                                        ELSE SELECT TOP 1 tzid khid,mdid FROM Rs_T_Rydwzl WHERE id = @rid
                                        ";
                        DataTable dt00;
                        
                        List<SqlParameter> lstParams2 = new List<SqlParameter>();
                        lstParams2.Add(new SqlParameter("@sid", BindKey));

                        strInfo = dalWX.ExecuteQuerySecurity(strSQL00, lstParams2, out dt00);
                        if (strInfo != "")
                        {
                            clsLocalLoger.WriteError(string.Concat("读取导购所属资料失败！错误：",strInfo));
                            RedirectERR("很抱歉！本功能正在维护，暂时不可用_code0");
                            return;
                        }*/

                        string skhid = Convert.ToString(Request.Params["khid"]);
                        string smdid = Convert.ToString(Request.Params["mdid"]);

                        //dt00.Clear(); dt00.Dispose();

                        if (!string.IsNullOrEmpty(skhid) && skhid != "0")
                        {
                            string strSQL00 = string.Format("UPDATE wx_t_vipBinging SET khid={0},mdid={1} WHERE wxopenid = '{2}'", skhid, smdid, Session["openid"]);

                            string connectstring = clsConfig.GetConfigValue("OAConnStr");
                            using (LiLanzDALForXLM dalZB = new LiLanzDALForXLM(connectstring))
                            {
                                strInfo = dalZB.ExecuteNonQuery(strSQL00);
                                if (strInfo != "")
                                {
                                    clsLocalLoger.WriteError(string.Concat("更新粉丝表所属关系！错误：",strInfo));
                                    RedirectERR("很抱歉！本功能正在维护，暂时不可用！_code1");
                                    return;
                                }
                            }
                        }

                        Response.Redirect("VSBFans.aspx?sid=" + BindKey);
                    }
                    else
                    {

                        //生成访问日志
                        clsWXHelper.WriteLog(string.Format("openid：{0} ，vipid：{1} 。访问功能页[{2}]", Convert.ToString(Session["openid"]), Convert.ToString(Session["vipid"])
                                        , "VIP指定顾问"));


                        string strSql0 = @" SELECT TOP 1 A.ID AS vsbID,A.SalerID FROM wx_t_VipSalerBind A WHERE A.OpenID=@openid  ";

                        DataTable dt;
                        string strName0, strName1;            //之前导购的姓名和新导购的姓名
                        int intServiceLevel0, intServiceLevel1;  //服务星级,来源： Rs_T_Rydwzl.zd 关联 dm_t_xzjbb.id 取 dm_t_xzjbb.dm + 1
                        string strfaceURL0, strfaceURL1;            //照片URL
                        int intServiceCount0, intServiceCount1;  //服务人数
                        int intSalerID0;  //之前的服务人员ID
                        int intVsbID0;  //之前绑定关系的ID
                        int mdid0, mdid1;   //门店ID 

                        mdid0 = 0; mdid1 = 0;
                        intServiceLevel0 = 0; intServiceLevel1 = 0;
                        intServiceCount0 = 0; intServiceCount1 = 0;


                        List<SqlParameter> lstParams = new List<SqlParameter>();
                        lstParams.Add(new SqlParameter("@openid", Convert.ToString(Session["openid"])));

                        strInfo = dalWX.ExecuteQuerySecurity(strSql0, lstParams, out dt);
                        if (strInfo == "")
                        {
                            if (dt.Rows.Count == 0) //表明之前没有导购，或导购信息不存在！
                            {
                                intSalerID0 = 0;
                                intVsbID0 = 0;
                                //strName0 = "";
                                //strfaceURL0 = "";
                            }
                            else
                            {
                                intSalerID0 = Convert.ToInt32(dt.Rows[0]["SalerID"]);
                                intVsbID0 = Convert.ToInt32(dt.Rows[0]["vsbID"]);
                                //strName0 = Convert.ToString(dt.Rows[0]["MyName"]);
                                //strfaceURL0 = Convert.ToString(dt.Rows[0]["avatar"]);
                            }
                            dt.Clear(); dt.Dispose();
                        }
                        else
                        {
                            clsLocalLoger.WriteError(string.Format("读取扫描原导购的关联信息失败！错误：{0}", strInfo));
                            RedirectERR("读取扫描原导购的关联信息失败！");
                            return;
                        }

                        string strSql1 = @"DECLARE @bdm VARCHAR(10),
				                                        @ServiceLevel INT,
                                                       @mdid INT
                                                        
                                        SELECT @mdid  = 0
                                        SELECT TOP 1 @bdm=B.dm,@mdid = mdid FROM Rs_T_Rydwzl A INNER JOIN dm_t_xzjbb B ON A.zd = B.id 
                                        INNER JOIN wx_t_OmniChannelUser OCU ON OCU.RelateID = A.id 
                                        WHERE OCU.ID = @BindKey

                                        IF (ISNUMERIC(@bdm) = 1) SELECT @ServiceLevel = CONVERT(INT,@bdm) + 1
                                        ELSE SELECT @ServiceLevel = 2
                                        
                                        SELECT TOP 1 @ServiceLevel ServiceLevel,@mdid mdid,D.avatar,OCU.Nickname AS MyName FROM wx_t_AppAuthorized C 
                                        INNER JOIN wx_t_OmniChannelUser OCU ON OCU.ID = C.SystemKey AND OCU.ID = @BindKey 
                                        INNER JOIN wx_t_customers D ON D.ID = C.UserID AND C.SystemID = 3
                                         ";

                        lstParams.Clear();
                        lstParams.Add(new SqlParameter("@BindKey", intSalerID0));
                        strInfo = dalWX.ExecuteQuerySecurity(strSql1, lstParams, out dt);
                        if (strInfo == "")
                        {
                            if (dt.Rows.Count == 0) //表明之前没有导购，或导购信息不存在！
                            {
                                strName0 = "";
                                strfaceURL0 = "";
                                intServiceLevel0 = 1;
                            }
                            else
                            {
                                strName0 = Convert.ToString(dt.Rows[0]["MyName"]);
                                strfaceURL0 = Convert.ToString(dt.Rows[0]["avatar"]);
                                intServiceLevel0 = Convert.ToInt32(dt.Rows[0]["ServiceLevel"]);

                                SetFaceImg(ref strfaceURL0);
                            }
                            dt.Clear(); dt.Dispose();
                        }
                        else
                        {

                            clsLocalLoger.WriteError(string.Format("读取扫描原导购的个人信息失败！错误：{0}", strInfo));
                            RedirectERR("读取扫描原导购的个人信息失败！");
                            return;
                        }


                        //查询出目标人员的情况 
                        if (dt != null) { dt.Clear(); dt.Dispose(); }
                        lstParams.Clear();
                        lstParams.Add(new SqlParameter("@BindKey", BindKey));
                        strInfo = dalWX.ExecuteQuerySecurity(strSql1, lstParams, out dt);
                        if (strInfo == "")
                        {
                            if (dt.Rows.Count == 0) //表明当前BindKey所对应的导购不存在或没有企业号权限不可用！
                            {
                                dt.Clear(); dt.Dispose();

                                strName1 = "";
                                BindKey = "0";
                                strfaceURL1 = "";
                                intServiceLevel1 = 0;
                                mdid1 = 0;

                                clsLocalLoger.WriteError(string.Format("扫描的专属导购授权信息异常！strSql1={0}", strSql1));
                                RedirectERR("扫描的专属导购授权信息异常！");
                                return;
                            }
                            else
                            {
                                strName1 = Convert.ToString(dt.Rows[0]["MyName"]);
                                strfaceURL1 = Convert.ToString(dt.Rows[0]["avatar"]);
                                intServiceLevel1 = Convert.ToInt32(dt.Rows[0]["ServiceLevel"]);
                                mdid1 = Convert.ToInt32(dt.Rows[0]["mdid"]);

                                SetFaceImg(ref strfaceURL1);
                            }
                            dt.Clear(); dt.Dispose();
                        }
                        else
                        {
                            clsLocalLoger.WriteError(string.Format("读取扫描专属导购的信息失败！错误：{0}", strInfo));
                            RedirectERR("读取扫描专属导购的信息失败！");
                            return;
                        }


                        //开始计算
                        string strSql3 = @" SELECT COUNT(1) FROM wx_t_VipSalerBind WHERE SalerID=@SalerID";

                        if (intSalerID0 == 0)
                        {
                            intServiceCount0 = 0;
                        }
                        else
                        {
                            if (dt != null) { dt.Clear(); dt.Dispose(); }
                            lstParams.Clear();
                            lstParams.Add(new SqlParameter("@SalerID", intSalerID0));
                            strInfo = dalWX.ExecuteQuerySecurity(strSql3, lstParams, out dt);
                            if (strInfo == "")
                            {
                                if (dt.Rows.Count == 0) //表明当前intSalerID0所对应的导购不存在或没有全渠道权限！
                                {
                                    intServiceCount0 = 0;
                                }
                                else
                                {
                                    intServiceCount0 = Convert.ToInt32(dt.Rows[0][0]);
                                }
                            }
                            else
                            {
                                clsLocalLoger.WriteError(string.Format("读取原专属导购服务人数失败！错误：{0}", strInfo));
                                RedirectERR("读取原专属导购服务人数失败！");
                                return;
                            }

                            if (dt != null) { dt.Clear(); dt.Dispose(); }
                            lstParams.Clear();
                            lstParams.Add(new SqlParameter("@SalerID", BindKey));
                            strInfo = dalWX.ExecuteQuerySecurity(strSql3, lstParams, out dt);
                            if (strInfo == "")
                            {
                                if (dt.Rows.Count == 0) //表明当前BindKey所对应的导购不存在或没有全渠道权限！
                                {
                                    intServiceCount1 = 0;
                                }
                                else
                                {
                                    intServiceCount1 = Convert.ToInt32(dt.Rows[0][0]);
                                }
                                dt.Clear(); dt.Dispose();
                            }
                            else
                            {
                                clsLocalLoger.WriteError(string.Format("读取扫码专属导购服务人数失败！错误：{0}", strInfo));
                                RedirectERR("读取扫码专属导购服务人数失败！");
                                return;
                            }
                        }

                        //赋值
                        hiddenVsbID0.Value = intVsbID0.ToString();
                        hiddenVipid.Value = Convert.ToString(Session["vipid"]);
                        hiddenSid.Value = BindKey;
                        hiddenmdid1.Value = Convert.ToString(mdid1);

                        //获取当前用户的关注状态，在前台如果处于未关注状态，则引导其关注。
                        //开始计算
                        string strSql4 = string.Concat(@" SELECT TOP 1 ISNULL(IsSubscribe,0) FROM wx_t_vipBinging WHERE wxOpenid='" , openid , "'");
                        object objTemp = null;
                        string ConOA = clsConfig.GetConfigValue("OAConnStr");
                        using (LiLanzDALForXLM zdal = new LiLanzDALForXLM(ConOA))
                        {
                            strInfo = zdal.ExecuteQueryFast(strSql4, out objTemp);
                            if (strInfo != "" || objTemp == null)
                            {
                                clsLocalLoger.WriteError("[吸收会员]获取客户关注状态时出错！错误：" + strInfo);
                                clsSharedHelper.WriteInfo("无法获取客户关注状态！");
                            }
                            IsSubscribe = Convert.ToString(objTemp);
                        }


                        //开始UI呈现代码
                        StringBuilder sbFace = new StringBuilder();
                        StringBuilder sbName = new StringBuilder();
                        StringBuilder sbServiceLevel = new StringBuilder();
                        StringBuilder sbServiceCount = new StringBuilder();
                        if (intSalerID0 != 0 && intSalerID0 != Convert.ToInt32(BindKey))
                        {
                            sbFace.AppendFormat(@"                                                
                                        <li class=""weui_uploader_file weui_uploader_status"" style=""background-image:url({0});background-size: 100% 100%;""> 
                                        </li>                                                              
                                        <li class=""weui_uploader_file"" style=""vertical-align:middle; line-height:79px; width:1em; font-size:xx-large;""> → 
                                        </li> ", strfaceURL0);
                            sbName.AppendFormat(@"{0}<span class=""goto""> → </span>", strName0);
                            sbServiceLevel.AppendFormat(@"{0}<span class=""goto""> → </span>", intServiceLevel0);
                            sbServiceCount.AppendFormat(@"{0}<span class=""goto""> → </span>", intServiceCount0);
                        }
                        else
                        {
                            spanInfo.InnerHtml = "指定";
                        }

                        if (intSalerID0 == Convert.ToInt32(BindKey)) spanInfo.InnerHtml = "查看";
                        else if (intSalerID0 == 0) spanInfo.InnerHtml = "指定";
                        else spanInfo.InnerHtml = "更换";


                        sbFace.AppendFormat(@"
                                    <li class=""weui_uploader_file"" style=""background-image:url({0})""></li> ", strfaceURL1);
                        sbName.AppendFormat(@"<span class=""goto"">{0}</span>", strName1);
                        sbServiceLevel.AppendFormat(@"<span class=""goto"">{0}</span>", intServiceLevel1);
                        sbServiceCount.AppendFormat(@"<span class=""goto"">{0}</span>", intServiceCount1);

                        divFace.InnerHtml = sbFace.ToString();
                        divName.InnerHtml = sbName.ToString();
                        divServiceLevel.InnerHtml = sbServiceLevel.ToString();
                        divServiceCount.InnerHtml = sbServiceCount.ToString();

                        sbFace.Length = 0; sbName.Length = 0; sbServiceLevel.Length = 0; sbServiceCount.Length = 0;
                        GC.Collect();   //回收资源  
                    }
                }
            }
        }
    }

    private void SetFaceImg(ref string strFace){
        if (clsWXHelper.IsWxFaceImg(strFace))
        {
            strFace = clsWXHelper.GetMiniFace(strFace);
        }
        else
        {
            string oaUrl = clsConfig.GetConfigValue("OA_WebPath");
            strFace =  string.Concat(oaUrl,strFace);
        }
    }

    private void RedirectERR(string info)
    {
        string url = string.Concat("../../WebBLL/Error.aspx?msg=", info);
        Response.Redirect(url);
    }
</script>

<html xmlns="http://www.w3.org/1999/xhtml">

<head>
    <meta charset="utf-8" />
    <meta name="viewport" content="width=device-width,initial-scale=1,user-scalable=0,maximum-scale=1" />
    <meta name="format-detection" content="telephone=no" />
    <meta name="apple-mobile-web-app-capable" content="yes" />
    <meta name="apple-mobile-web-app-status-bar-style" content="black" />
    <title></title>
    <link rel="stylesheet" href="../../res/css/weui.min.css"/>
    <link rel="stylesheet" href="../../res/css/StoreSaler/weui_example.css"/>  
    <style> 
        .goto
        {
            color:Black;
            font-weight:900;
        }
        .red
        {
            color:red;  
            font-weight:700;          
        }
    </style>
</head>
<body ontouchstart>     
<form id="form1" runat="server">
   <input type="hidden" id="hiddenVsbID0" runat="server" value="0" />
   <input type="hidden" id="hiddenVipid" runat="server" value="0" />
   <input type="hidden" id="hiddenSid" runat="server" value="0" /> 

   <input type="hidden" id="hiddenmdid1" runat="server" value="0" /> 

  <div class="container js_container">
    <div class="page">
        <div class="hd">
            <h1 class="page_title">指定专属顾问</h1>
        </div>
        <div class="bd spacing">
            <div class="weui_cells_title">您正在<span class="red" id="spanInfo" runat="server">更换</span>专属顾问：</div>
            <div class="weui_cells weui_cells_form">
                <div class="weui_cell" style=" text-align:center;"> 
                    <ul class="weui_uploader_files" id="divFace" runat="server">                                                                
          <%--              <li class="weui_uploader_file weui_uploader_status" style="background-image:url(../../res/img/StoreSaler/head4.jpg)"> 
                        </li>                                                              
                        <li class="weui_uploader_file"style=" vertical-align:middle; line-height:79px; width:1em; font-size:xx-large;"> → 
                        </li> 
                        <li class="weui_uploader_file" style="background-image:url(../../res/img/StoreSaler/head5.jpg)"></li>--%>
                    </ul>   
                </div>
            </div> 
        </div> 
        <div class="weui_cells_title">专属顾问情报</div>
        <div class="weui_cells">
            <div class="weui_cell">
                <div class="weui_cell_bd weui_cell_primary">
                    <p>姓名</p>
                </div>
                <div class="weui_cell_ft" id="divName" runat="server">林小灵<span class="goto"> → </span><span class="goto">张小梅</span></div>
            </div>
            <div class="weui_cell">                
                <div class="weui_cell_bd weui_cell_primary">
                    <p>服务星级</p>
                </div>
                <div class="weui_cell_ft" id="divServiceLevel" runat="server">4星<span class="goto"> → </span><span class="red">5星</span></div>
            </div>
            <div class="weui_cell">
                <div class="weui_cell_bd weui_cell_primary">
                    <p>服务人数</p>
                </div>
                <div class="weui_cell_ft" id="divServiceCount" runat="server">28人<span class="goto"> → </span><span class="red">123人</span></div>
            </div>
        </div>
         
        <div class="weui_btn_area">
            <a class="weui_btn weui_btn_primary" id="btnOK" href="javascript:SubmitOK();">确定</a>
        </div>    
    </div> 
  </div>

       <script type="text/html" id="tpl_msg">
    <div class="page">
        <div class="weui_msg" style="padding-top:0">
            <div class="weui_icon_area" style="margin-bottom:0;"><i class="weui_icon_success weui_icon_msg"></i></div>
            <div class="weui_text_area">
                <h2 class="weui_msg_title">操作成功</h2>
                <div class="weui_cells_title">请选择您更换顾问的原因</div>
                <div class="weui_cells weui_cells_radio">
                    <label class="weui_cell weui_check_label" for="x11">
                        <div class="weui_cell_bd weui_cell_primary">
                            <p>1、服务态度不满意</p>
                        </div>
                        <div class="weui_cell_ft">
                            <input type="radio" name="radio1" class="weui_check" id="x11" value="1">
                            <span class="weui_icon_checked"></span>
                        </div>
                    </label>
                    <label class="weui_cell weui_check_label" for="x12">
                        <div class="weui_cell_bd weui_cell_primary">
                            <p>2、搭配水平不满意</p>
                        </div>
                        <div class="weui_cell_ft">
                            <input type="radio" name="radio1" class="weui_check" id="x12" value="2">
                            <span class="weui_icon_checked"></span>
                        </div>
                    </label>
                    <label class="weui_cell weui_check_label" for="x13">
                        <div class="weui_cell_bd weui_cell_primary">
                            <p>3、沟通不顺利</p>
                        </div>
                        <div class="weui_cell_ft">
                            <input type="radio" name="radio1" class="weui_check" id="x13" value="3">
                            <span class="weui_icon_checked"></span>
                        </div>
                    </label>
                    <label class="weui_cell weui_check_label" for="x14">
                        <div class="weui_cell_bd weui_cell_primary">
                            <p>4、导购形象不专业</p>
                        </div>
                        <div class="weui_cell_ft">
                            <input type="radio" name="radio1" class="weui_check" id="x14" value="4">
                            <span class="weui_icon_checked"></span>
                        </div>
                    </label>
                    <label class="weui_cell weui_check_label" for="x15">
                        <div class="weui_cell_bd weui_cell_primary">
                            <p>5、说不出感觉</p>
                        </div>
                        <div class="weui_cell_ft">
                            <input type="radio" name="radio1" class="weui_check" id="x15" value="5">
                            <span class="weui_icon_checked"></span>
                        </div>
                    </label>
                    <label class="weui_cell weui_check_label" for="x16">
                        <div class="weui_cell_bd weui_cell_primary">
                            <p>6、其它</p>
                        </div>
                        <div class="weui_cell_ft">
                            <input type="radio" name="radio1" class="weui_check" id="x16" value="6">
                            <span class="weui_icon_checked"></span>
                        </div>
                    </label> 
                </div>
            </div>
            <div class="weui_opr_area">
                <p class="weui_btn_area">
                    <a href="javascript:SubmitOK2();" class="weui_btn weui_btn_primary">确定提交</a> 
                </p>
            </div>
        </div>
    </div>

     
</script>

    
    
        <!--BEGIN toast-->
        <div id="toast" style="display: none;">
            <div class="weui_mask_transparent"></div>
            <div class="weui_toast">
                <i class="weui_icon_toast" id="toasticon"></i>
                <p class="weui_toast_content" id="toastinfo">感谢您的宝贵意见</p>
            </div>
        </div>
        <!--end toast-->
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
    
    <script type='text/javascript' src='../../res/js/StoreSaler/fastclick.min.js'></script>
    <script type='text/javascript' src="../../res/js/zepto.min.js"></script>
    <script type='text/javascript' src="../../res/js/StoreSaler/weui_example.js"></script> 
    <script type="text/javascript">

        var stack = [];
        var $container = $('.js_container');
        var radioSelect = 0;

        var sInfo = $("#<%= spanInfo.ClientID %>").html();      //如果是查看模式，则不显示按钮
        if (sInfo == "查看") {
            $("#btnOK").hide();
            CheckSubscribe();
        }

        //选择项
        $(document).on("click", "input[type='radio']", function (event) {
            radioSelect = this.value;
            event.stopPropagation();
        });
         
        function SubmitOK() {
            var vsbid = "<%= hiddenVsbID0.Value %>";
            var vipid = "<%= hiddenVipid.Value %>";
            var sid = "<%= hiddenSid.Value %>";
            var mdid1 = "<%= hiddenmdid1.Value %>";
             
            $('#loadingToast').show();             //弹出等待提示 

            //保存新的绑定关系
            $.ajax({
                url: "VSBCore.aspx",
                type: "POST",
                data: { ctrl: "SaveVSB", "vsbid": vsbid, "vipid": vipid, "openid": "<%= openid %>", "sid": sid, "mdid": mdid1 },
                dataType: "HTML",
                timeout: 10000,
                error: function (XMLHttpRequest, textStatus, errorThrown) {
                    $('#loadingToast').hide();
                    alert(errorThrown);
                },
                success: function (result) {
                    $('#loadingToast').hide();
                    if (result.indexOf("Successed") == 0) {
                        //                        result = result.substring(9);

                        if (vsbid == "0") { //不弹出调查页，直接关闭退出本画面
                            $('#loadingToast').hide();
                            var $toast = $('#toast');
                            if ($toast.css('display') != 'none') {
                                return;
                            }

                            CheckSubscribe();
                        } else {
                            $('#loadingToast').hide();
                            showOKMsg();
                        }
                    }
                    else {
                        alert(result);
                    }
                }
            });  
        }

        function CheckSubscribe() {
            var $toast = $('#toast');
            $("#toasticon").attr("class", "weui_icon_toast");
            if ("<%= IsSubscribe%>" != "True") {
                $("#toastinfo").html("请您关注我们!"); 
                $toast.show();
                setTimeout(function () {
                    $toast.hide();
                    window.location.href = "VSBFans.aspx?sid=<%= hiddenSid.Value %>";
                }, 1500); 
            } else {
                $("#toastinfo").html("感谢您的关注!");
                $toast.show();
                setTimeout(function () {
                    $toast.hide();
                    //关掉窗口
                    WeixinJSBridge.call('closeWindow'); //直接调用免激活微信API的窗口关闭方法
                }, 3000);
            }
        }

        function showOKMsg() {
            var id = "msg";
            var $tpl = $($('#tpl_' + id).html()).addClass('slideIn').addClass(id);
            $container.append($tpl);
            stack.push($tpl);
            history.pushState({ id: id }, '', '#' + id);

            $($tpl).on('webkitAnimationEnd', function () {
                $(this).removeClass('slideIn');
            }).on('animationend', function () {
                $(this).removeClass('slideIn');
            });
        }

        function SubmitOK2() {
            var $toast = $('#toast');
            if (radioSelect == 0) {
                $("#toasticon").attr("class", "weui_icon_warn weui_icon_msg");
                $("#toastinfo").html("您就稍微给点意见吧..."); 
                $toast.show();
                setTimeout(function () {
                    $toast.hide();
                }, 1000);
                return;
            }

            vsbid = "<%= hiddenVsbID0.Value %>";
            vipid = "<%= hiddenVipid.Value %>"; 

            $('#loadingToast').show();             //弹出等待提示 

            //保存新的绑定关系
            $.ajax({
                url: "VSBCore.aspx",
                type: "POST",
                data: { ctrl: "SaveOpinion", "vsbid": vsbid, "vipid": vipid, "Opinion": radioSelect },
                dataType: "HTML",
                timeout: 10000,
                error: function (XMLHttpRequest, textStatus, errorThrown) {
                    $('#loadingToast').hide();
                    alert(errorThrown);
                },
                success: function (result) {
                    $('#loadingToast').hide();
                    if (result.indexOf("Successed") == 0) {
                        //                        result = result.substring(9); 

                        $('#loadingToast').hide();

                        $("#toasticon").attr("class", "weui_icon_toast");
                        $("#toastinfo").html("谢谢您的宝贵意见!"); 

                        if ($toast.css('display') != 'none') {
                            return;
                        } 
                        $toast.show(); 
                        setTimeout(function () {
                            $toast.hide();
                            //关掉窗口
                            WeixinJSBridge.call('closeWindow'); //直接调用免激活微信API的窗口关闭方法
                        }, 2000); 
                    }
                    else {
                        alert(result);
                    }
                }
            });   
        }



        // webkit will fired popstate on page loaded
        $(window).on('popstate', function () {
            var $top = stack.pop();
            if (!$top) {
                return;
            }
            $top.addClass('slideOut').on('animationend', function () {
                $top.remove();
            }).on('webkitAnimationEnd', function () {
                $top.remove();
            });
        });
    </script>
 </form>
</body>
</html>
