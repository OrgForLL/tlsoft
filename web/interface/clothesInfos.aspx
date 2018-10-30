<%@ Page Language="C#" %>

<%@ Import Namespace="nrWebClass" %>
<%@ Import Namespace="System.Data" %>
<%@ Import Namespace="System.Data.SqlClient" %>
<%@ Import Namespace="System.Collections.Generic" %>
<!DOCTYPE html>
<script runat="server">  
    public string ryid = "0";
    public string AppSystemKey = "";
    private const string ConfigKeyValue = "1";	//微信配置信息索引值
    public List<string> wxConfig;       //微信OPEN_JS 动态生成的调用参数
    //private string ChatProConnStr = System.Configuration.ConfigurationManager.ConnectionStrings["Conn"].ConnectionString;
    //private string DBConstr = clsConfig.GetConfigValue("OAConnStr");

    public string dzxm = "陈红", mdid = "4291", mdmc = "嘉善市解放路店 ";
    //public string dzxm = "", mdid = "", mdmc = "";
    protected void Page_Load(object sender, EventArgs e)
    {
        //if (clsWXHelper.CheckQYUserAuth(true))
        //{
        //    string SystemID = "3";
        //    AppSystemKey = clsWXHelper.GetAuthorizedKey(Convert.ToInt32(SystemID));
        //    ryid = AppSystemKey;
        //    if (AppSystemKey == "")
        //        clsWXHelper.ShowError("对不起，您还未开通全渠道系统权限！");
        //    else
        //    {
        //        mdid=Session["mdid"].ToString();
        //        if (Session["RoleID"].ToString() != "2")
        //            clsWXHelper.ShowError("对不起，您无权限使用此功能！");
        //        using (LiLanzDALForXLM dal = new LiLanzDALForXLM(ChatProConnStr))
        //        {
        //            string sql = "select top 1 relateID,nickname from wx_t_OmniChannelUser where id='" + AppSystemKey + "'";
        //            DataTable dt = null;
        //            string errinfo = dal.ExecuteQuery(sql, out dt);
        //            if (dt.Rows.Count == 0)
        //                clsWXHelper.ShowError("");
        //            else if (dt.Rows[0][0].ToString() == "0")
        //                clsWXHelper.ShowError("对不起，找不到您对应的人资资料！");
        //            else {
        //                ryid = dt.Rows[0][0].ToString();
        //                dzxm=dt.Rows[0][1].ToString();
        //                using (LiLanzDALForXLM dal2 = new LiLanzDALForXLM(DBConstr)) {
        //                    sql = "select top 1 mdmc from t_mdb where mdid=" + mdid;
        //                    errinfo = dal2.ExecuteQuery(sql,out dt);
        //                    if (errinfo == "" && dt.Rows.Count > 0)
        //                        mdmc = dt.Rows[0][0].ToString();
        //                }
        //            }                        
        //        }
        //    }
        //}
        //else
        //{
        //    clsWXHelper.ShowError("鉴权失败！");
        //}  

        //店长身份判断
        //String userid = Convert.ToString(Session["qy_customersid"]);              
        //if (userid == null || userid == "" || userid == "0")
        //{
        //    ////获取用户鉴权的方法:该方法要求用户必须已成功关注企业号，主要是用于获取Session["qy_customersid"] 和其他登录信息
        //    //if (!clsWXHelper.CheckQYUserAuth(true))
        //    //{
        //    //    Response.Redirect("../../WebBLL/Error.aspx?msg=请先关注利郎企业号！");
        //    //    Response.End();
        //    //} 
        //}
        //else
        //{            
        //            using (LiLanzDALForXLM dal = new LiLanzDALForXLM(clsConfig.GetConfigValue("FormalModeConnStr")))
        //            {                
        //                //准备JS脚本
        //                string str_sql = @"
        //                                    if not exists( 
        //                                     select top 1 1 
        //                                     from wx_t_customer a
        //                                     inner join wx_t_AppAuthorized b on b.userid=a.id
        //                                     inner join wx_t_AppInfomation c on b.systemid=c.id
        //                                     where a.id=@qyuserid )
        //                                    select '00';
        //                                    else
        //                                    select top 1 a.xm,m.mdid,m.mdmc,isnull(c.gw,'') gw
        //                                    from rs_t_ryjbzl a
        //                                    inner join wx_t_AppAuthorized wa on wa.userid=@qyuserid and wa.systemid=2 and a.id=wa.systemkey
        //                                    left join wx_t_vipbinging b on a.id=b.vipid and b.objectid=3
        //                                    left join rs_t_rydwzl c on a.id=c.id
        //                                    left join t_mdb m on m.mdid=c.mdid ";
        //                List<SqlParameter> paras = new List<SqlParameter>();
        //                paras.Add(new SqlParameter("@qyuserid", userid));
        //                DataTable dt = null;
        //                string errinfo = dal.ExecuteQuerySecurity(str_sql, paras, out dt);
        //                if (errinfo == "")
        //                {                             
        //                    if (dt.Rows.Count > 0 && dt.Rows[0][0].ToString() != "00")
        //                    {
        //                        if (dt.Rows[0]["gw"].ToString() == "266")
        //                        {
        //                            //店长的岗位ID为266
        //                            dzxm = dt.Rows[0]["xm"].ToString();
        //                            mdid = dt.Rows[0]["mdid"].ToString();
        //                            mdmc = dt.Rows[0]["mdmc"].ToString();
        //                        }
        //                        else
        //                            execJS("对不起，只有店长才有权限使用此功能！");
        //                    }
        //                    else
        //                        execJS("请先加入利郎企业号并通过人资系统认证！");
        //                }
        //                else
        //                    execJS("执行查询时出错！ info:" + errinfo.Replace("'",""));                             
        //            }

        //}
        //wxConfig = clsWXHelper.GetJsApiConfig(ConfigKeyValue);        
    }

    public void execJS(string txt)
    {
        System.Text.StringBuilder htmlPlanContent = new System.Text.StringBuilder();
        htmlPlanContent.Append("<script language='javaScript' type='text/javascript'>");
        htmlPlanContent.Append("alert('" + txt + "');");
        htmlPlanContent.Append("</");
        htmlPlanContent.Append("script>");
        Response.Write(htmlPlanContent.ToString());
        Response.Flush();
        Response.End();
    }
</script>
<html>
<head runat="server">
    <meta charset="utf-8" />
    <meta name="viewport" content="width=device-width,initial-scale=1,user-scalable=0">
    <title></title>
    <link rel="stylesheet" type="text/css" href="css/font-awesome.min.css" />
    <style type="text/css">
        * {
            margin: 0;
            padding: 0;
        }

        body {
            color: #333;
            background: #eeeeee;
            font-family: "微软雅黑";
        }

        .container {
            width: 100%;
            padding: 10px 15px 15px 15px;
            box-sizing: border-box;
            position: relative;
        }

        h2 {
            text-align: center;
        }

        hr {
            margin-top: 10px;
            border: 1px dashed #333;
        }

        .sum, .charts {
            margin-top: 10px;
        }

        .infoitem {
            margin-top: 10px;
            display: block;
        }

        .item, .itemval {
            text-align: center;
            word-wrap: break-word;
            word-break: break-all;
            white-space: nowrap;
            display: table-cell;
        }

        .item {
            color: #fff;
            background: #333;
            padding: 6px 15px;
            min-width: 64px;
        }

        .itemval {
            font-size: 1.2em;
            border-bottom: 2px solid #333;
            width: 2000px;
        }

        .sum h3 {
            margin-top: 10px;
        }

        .charts span {
            display: block;
            text-align: center;
        }

        .occupy {
            text-align: center;
            margin: 10px 0;
            padding: 6px 0;
            background: #333;
            color: #fff;
        }

        .star {
            position: absolute;
            left: 50%;
            margin-left: -40px;
        }

        .scanbtn {
            position: absolute;
            text-decoration: none;
            display: block;
            text-align: center;
            margin: 30px auto 15px auto;
            padding: 10px;
            color: #fff;
            background: #333;
            box-sizing: border-box;
            width: 80px;
            height: 80px;
            border-radius: 40px;
            font-size: 1.2em;
            line-height: 60px;
            font-weight: 600;
        }

        .copyright {
            text-align: center;
            width: 100%;
            color: #808080;
            font-size: 0.8em;
            margin-top: 140px;
        }
        /*动画心跳动画*/
        .star b {
            width: 80px;
            height: 80px;
            display: block;
            border-radius: 40px;
            margin: 30px auto 15px auto;
            position: absolute;
            background-color: #808080;
            -webkit-transform: scale(2);
            opacity: .2;
            -webkit-animation: zdjpop .8s infinite;
        }

        @-webkit-keyframes zdjpop {
            0% {
                opacity: 1;
                -webkit-transform: scale(1);
            }

            100% {
                opacity: 0;
                -webkit-transform: scale(1.3);
            }
        }

        .floatfix:after {
            content: "";
            display: table;
            clear: both;
        }

        .store {
            float: left;
            height: 40px;
            line-height: 40px;
            vertical-align: middle;
            font-weight: bold;
        }

            .store img {
                width: 40px;
                height: 40px;
            }

        .exclam {
            font-weight: bold;
            border: 1px dashed #333;
            padding: 45px 8px 10px 8px;
            text-align: center;
            position: relative;
            background: #fff;
        }

        .exclamp {
            background: #333;
            position: absolute;
            left: 0;
            top: 0;
            width: 100%;
            color: #fff;
            font-size: 1.5em;
            padding: 2px 0px;
        }

        .legend {
            text-align: center;
            margin-bottom: 10px;
        }

            .legend span {
                display: inline-block;
                width: 16px;
                height: 16px;
                line-height: 16px;
                vertical-align: middle;
                margin: 0px 10px;
            }

        #hh-legend {
            background: rgb(240,173,78);
        }

        #pl-legend {
            background: rgb(51,122,183);
        }

        .fa-user {
            font-size: 1.3em;
        }

        .sphhinput {
            position: fixed;
            bottom: 0;
            left: 0;
            width: 100%;
            height: 50px;
            padding: 5px;
            box-sizing: border-box;
            background-color: #eee;
            box-shadow: 0 0 2px #ccc;
        }

            .sphhinput input {
                -webkit-appearance: none;
                border-radius: 5px;
                border: 1px solid #e0e0e0;
                height: 40px;
                line-height: 40px;
                width: 100%;
                font-size: 15px;
                box-sizing: border-box;
                padding: 0 10px;
                color: #888;
            }

        .searbtn {
            position: fixed;
            right: 5px;
            bottom: 5px;
            width: 50px;
            height: 40px;
            font-size: 20px;
            text-align: center;
            line-height: 40px;
            color: #555;
            border-left: 1px solid #e0e0e0;
        }

        .mask {
            color: #fff;
            position: absolute;
            top: 0;
            bottom: 0;
            left: 0;
            right: 0;
            z-index: 1001;
            font-size: 1.1em;
            text-align: center;
            display:none;
            background-color: rgba(0,0,0,0.3);
        }

        .center-translate {
            position: absolute;
            top: 50%;
            left: 50%;
            -webkit-transform: translate(-50%, -50%);
            transform: translate(-50%, -50%);
        }

        .loader {
            background-color: rgba(39, 43, 46, 0.7);
            padding: 15px 20px;
            border-radius: 5px;
        }

        #loadtext {
            font-size:0.8em;
            margin-top: 5px;
            font-weight: bold;
        }
    </style>
</head>
<body>
    <div class="container">
        <div class="floatfix">
            <div class="store"><i class="fa fa-user"></i><span id="dzxm">-- </span></div>
            <div class="store">
                <img src="../../res/img/Retail/storeicon.png" />
            </div>
            <div class="store"><span id="storename">-- </span></div>
        </div>
        <div style="padding-bottom: 170px;">
            <div class="title">
                <h2><i class="fa fa-tags"></i>货号信息</h2>
                <hr />
                <div class="infoitem">
                    <div class="item">商品货号</div>
                    <div class="itemval" id="sphh">--</div>
                </div>
                <div class="infoitem">
                    <div class="item">商品名称</div>
                    <div class="itemval" id="spmc">--</div>
                </div>
                <div class="infoitem">
                    <div class="item">规 格</div>
                    <div class="itemval" id="cmmc">--</div>
                </div>
                <div class="infoitem">
                    <div class="item">吊牌价</div>
                    <div class="itemval"><strong>￥</strong><strong id="lsdj">--</strong></div>
                </div>
            </div>
            <div class="sum">
                <h2><i class="fa fa-calculator"></i>统计信息</h2>
                <hr />
                <h3>货号相关数据：</h3>
                <div class="infoitem">
                    <div class="item">本月销量</div>
                    <div class="itemval" id="hhbysl">--</div>
                </div>
                <div class="infoitem">
                    <div class="item">总销售量</div>
                    <div class="itemval" id="hhxsl">--</div>
                </div>
                <div class="infoitem">
                    <div class="item">总采购量</div>
                    <div class="itemval" id="hhcgsl">--</div>
                </div>
                <div class="infoitem">
                    <div class="item">售罄率</div>
                    <div class="itemval" id="hhsql"><strong>--</strong></div>
                </div>
                <h3>同品类相关数据：</h3>
                <div class="infoitem">
                    <div class="item">本月销量</div>
                    <div class="itemval" id="plbysl">--</div>
                </div>
                <div class="infoitem">
                    <div class="item">总销售量</div>
                    <div class="itemval" id="plxsl">--</div>
                </div>
                <div class="infoitem">
                    <div class="item">总采购量</div>
                    <div class="itemval" id="plcgsl">--</div>
                </div>
                <div class="infoitem">
                    <div class="item">售罄率</div>
                    <div class="itemval" id="plsql"><strong>--</strong></div>
                </div>
                <div class="occupy">该货号在该品类中的占比：<span id="occupyval" style="font-weight: bold;">--</span></div>
                <div class="exclam">
                    <p class="exclamp"><i class="fa fa-exclamation-circle"></i></p>
                    <p>总采购量=门店的采购入库数量</p>
                    <p>售罄率=总销售量 ÷（采购量+调拨量）</p>
                </div>
            </div>
            <div class="charts">
                <h2><i class="fa fa-bar-chart-o"></i>图表信息</h2>
                <hr />
                <div id="can1">
                    <canvas id="canvas1" height="200px"></canvas>
                    <div class="legend"><span id="hh-legend"></span>货号数据<span id="pl-legend"></span>同品类数据</div>
                    <span style="margin: 10px 0;">2015年销售量分布图</span>
                    <div class="exclam">
                        <p class="exclamp"><i class="fa fa-exclamation-circle"></i></p>
                        <p>单击图表可以查看具体数据！</p>
                        <p>进入扫描界面后也可以选择手机相册中的二维码图片！</p>
                    </div>
                </div>
            </div>
            <hr />
            <div class="star">
                <b></b>
                <a class="scanbtn" href="#" onclick="scanQRCode()">扫一扫</a>
            </div>
            <div id="ltcon"></div>
        </div>
        <div class="sphhinput">
            <input type="text" id="areatxt" placeholder="请输入要查询的完整货号" />
            <div class="searbtn" onclick="search()"><i class="fa fa-search"></i></div>
        </div>
    </div>
    <div class="mask">
        <div class="loader center-translate">
            <div>
                <i class="fa fa-2x fa-spinner fa-pulse"></i>
            </div>
            <p id="loadtext">正在加载...</p>
        </div>
    </div>
    <script type="text/javascript" src="../../res/js/jquery.js"></script>
    <script type="text/javascript" src="../../res/js/Chart.min.js"></script>
    <script type="text/javascript" src="http://res.wx.qq.com/open/js/jweixin-1.0.0.js"></script>
    <script>
        function search() {
            var st = $("#areatxt").text();
            alert(st);
        }

        function showLoader(type, txt) {
            switch (type) {
                case "loading":
                    $(".mask .fa").removeAttr("class").addClass("fa fa-2x fa-spinner fa-pulse");
                    $("#loadtext").text(txt);
                    $(".mask").show();
                    break;
                case "successed":
                    $(".mask .fa").removeAttr("class").addClass("fa fa-2x fa-check");
                    $("#loadtext").text(txt);
                    $(".mask").show();
                    setTimeout(function () {
                        $(".mask").fadeOut(200);
                    }, 500);
                    break;
                case "error":
                    $(".mask .fa").removeAttr("class").addClass("fa fa-2x fa-close (alias)");
                    $("#loadtext").text(txt);
                    $(".mask").show();
                    break;
                case "warn":
                    $(".mask .fa").removeAttr("class").addClass("fa fa-2x fa-warning (alias)");
                    $("#loadtext").text(txt);
                    $(".mask").show();
                    setTimeout(function () {
                        $(".mask").fadeOut(400);
                    }, 800);
                    break;
            }
        }
    </script>
</body>
</html>
