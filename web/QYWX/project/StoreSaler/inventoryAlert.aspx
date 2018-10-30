<%@ Page Language="C#" %>

<%@ Import Namespace="nrWebClass" %>
<%@ Import Namespace="System.Data" %>
<%@ Import Namespace="System.Collections.Generic" %>


<!DOCTYPE html>
<script runat="server">
    public string ViewType = "";   //视图类型
    public string AuthOptionCollect = "", SeasonOptionCollect = "";   //选择栏
    public string KhClassOptionCollect = ""; //客户类别
    public string roleName = "";
    public int roleID = 0;
    private string optionBase = "<option value=\"{0}\" {2} data-ssid={3}>{1}</option>";

    protected void Page_PreRender(object sender, EventArgs e)
    {
        ViewType = Convert.ToString(Request.Params["ViewType"]);
        if (ViewType == null || ViewType == "") ViewType = "kh";

        //clsWXHelper.CheckQQDMenuAuth(22);    //检查菜单权限

        string opselect = " selected";
        StringBuilder sbCompany = new StringBuilder();
        roleID = Convert.ToInt32(Session["RoleID"]);
        roleName = Convert.ToString(Session["RoleName"]);

        DataTable dt = null;
        if (roleID == 4)
        {
            //获取当前用户的身份。默认会自动选中第一个项
            dt = clsWXHelper.GetQQDAuth();           
            calCompany(ref dt, ref sbCompany);
            
        }
        else if (roleID < 3 && roleID > 0)
        {
            if (ViewType == "kh") ViewType = "md";  //门店职员 如果访问 “客户”则强制切回门店

            string dbConn = clsConfig.GetConfigValue("OAConnStr");

            using (LiLanzDALForXLM dal = new LiLanzDALForXLM(dbConn))
            {
                object objmdKhid = "";
                string strSQL = string.Concat(@"SELECT TOP 1 CONVERT(VARCHAR(10),a.khid) + '|' + mdmc+'|'+convert(varchar(10),kh.ssid)
                                        FROM t_mdb a inner join yx_t_khb kh on a.khid=kh.khid WHERE a.mdid = ", Session["mdid"]);
                clsLocalLoger.WriteInfo(strSQL);
                string strInfo = dal.ExecuteQueryFast(strSQL, out objmdKhid);
                if (strInfo == "")
                {
                    string[] mdinfo = Convert.ToString(objmdKhid).Split('|');
                    if (mdinfo.Length == 3) sbCompany.AppendFormat(optionBase, mdinfo[0], mdinfo[1], opselect, mdinfo[2]);
                    else sbCompany.AppendFormat(optionBase, "-1", "门店人资权限错误！请联系总部IT", opselect, "");
                }
            }
        }
        else
        {
            sbCompany.AppendFormat(optionBase, "", "完整权限", opselect, "");

            string strSQL = string.Concat(@"SELECT a.khid ,  khmc mdmc,1 'ssid',0 'mdid'  FROM yx_t_khb A 
                                                WHERE A.ssid = 1 AND A.yxrs = 1 AND ISNULL(A.ty,0) = 0
                                                                    AND ISNULL(A.sfdm,'') <> ''                                            
                                                    ORDER BY A.khmc");


            string dbConn = clsConfig.GetConfigValue("OAConnStr");
            using (LiLanzDALForXLM dal = new LiLanzDALForXLM(dbConn))
            {
                string strInfo = dal.ExecuteQuery(strSQL, out dt);
                if (strInfo != "")
                {
                    clsWXHelper.ShowError("权限信息读取错误2！strInfo:" + strInfo);
                    return;
                }
                if (dt.Rows.Count == 0)
                {
                    sbCompany.AppendFormat(optionBase, "-1", "门店人资权限错误！请联系总部IT", opselect, "");
                    return;
                }
            } 

            if (dt.Rows.Count == 0) sbCompany.AppendFormat(optionBase, "-1", "您还没有授权，请联系总部IT", opselect, "");
            else { calCompany(ref dt, ref sbCompany); }      
        }
        SeasonCollect();
        AuthOptionCollect = sbCompany.ToString();
        sbCompany.Length = 0; 
    }


    public void calCompany(ref DataTable dt, ref StringBuilder sbCompany)
    {
        DataRow dr;
        DataRow[] drList = dt.Select("", "ssid,mdmc");
        for (int i = 0; i < dt.Rows.Count; i++)
        {
            dr = drList[i];

            sbCompany.AppendFormat(optionBase, dr["khid"], dr["mdmc"], "", dr["ssid"]);
        }
    }

    public void SeasonCollect()
    {
        string dbConn = clsConfig.GetConfigValue("OAConnStr");
        using (LiLanzDALForXLM dal = new LiLanzDALForXLM(dbConn))
        {
            string _sql = "select top 7 dm,mc from yf_t_kfbh where jzrq is not null order by dm desc";
            StringBuilder sbSeacon = new StringBuilder();
            string optionBase = "<li dm=\"{0}\">{1}</li>";
            DataTable dt;
            string errinfo = dal.ExecuteQuery(_sql, out dt);
            if (errinfo == "")
            {
                for (int i = 0; i < dt.Rows.Count; i++)
                {
                    string name = Convert.ToString(dt.Rows[i]["mc"]).Replace("产品", "");
                    sbSeacon.AppendFormat(optionBase, Convert.ToString(dt.Rows[i]["dm"]), name, "");
                }//end for
            }
            SeasonOptionCollect = sbSeacon.ToString();
            sbSeacon.Length = 0;
            dt.Clear(); dt.Dispose();
        }
    }
</script>
<html>
    <head>
        <title>库存查询</title>
        <meta http-equiv="content-type" content="text/html; charset=UTF-8" />
        <meta name="viewport" content="width=device-width, initial-scale=1,user-scalable=0,maximum-scale=1" />
        <link rel="stylesheet" href="../../res/css/font-awesome.min.css" />
        <link rel="stylesheet" href="../../res/css/LeePageSlider.css" />
        <link rel="stylesheet" href="../../res/css/StoreSaler/inventoryAlert.css" />
    </head>
    <body>
        <div class="header">
            <i id="goback" class="fa fa-angle-left"></i>
            <div id="methods">
                <i class="fa fa-retweet"></i>
                <p>方式</p>
            </div>
            <div id="search">
                <input class="alert-search" type="text" placeholder="搜索货号" />
                <button><i class="fa fa-search"></i></button>
            </div>
            <div id="filter">
                <i class="fa fa-filter"></i>
                <p>筛选</p>
            </div>
        </div>
        <div id="type">
            <ul>
                <li id="dm"><i class="icon iconfont">&#xe600;</i><span>断码</span></li>
                <li id="dxl"><i class="icon iconfont">&#xe63a;</i><span>动销率</span></li>
            </ul>
        </div>
        <div class="wrap-page page-not-header">
            <div class="condition">
                <select id="company">
                    <%=AuthOptionCollect %>
                </select>
                <label class="fa fa-angle-down" for="company"></label>
                <div class="terms"><p></p></div>
            </div>
            <div id="alert" class="page">
                <div class="shade">
                    <table>
                        <thead>
                            <tr>
                                <th>客户</th>
                                <th>类别</th>
                                <th>货号</th>
                                <th>库存数</th>
                                <th class="type">断码</th>
                                <th>尺码</th>
                            </tr>
                        </thead>
                    </table>
                </div>
                <div class="detail">
                    <table>
                        <thead>
                            <tr>
                                <th>客户</th>
                                <th>类别</th>
                                <th>货号</th>
                                <th>库存数</th>
                                <th class="type">断码</th>
                                <th>尺码</th>
                            </tr>
                        </thead>
                        <tbody>
                        </tbody>
                    </table>
                </div>
                <div class="total">
                    <table>
                        <tr>
                            <td>合计</td>
                            <td>-</td>
                            <td>-</td>
                            <td>-</td>
                            <td>-</td>
                        </tr>
                    </table>
                </div>
            </div>
            <div id="goodsNum" class="page">
                <div class="shade">
                    <table>
                        <thead>
                            <tr>
                                <th>货物</th>
                                <th>数量</th>
                            </tr>
                        </thead>
                    </table>
                </div>
                <div class="detail">
                    <table>
                        <thead>
                            <tr>
                                <th>货物</th>
                                <th>数量</th>
                            </tr>
                        </thead>
                        <tbody>
                            <tr>
                                <td>XXXXXX</td>
                                <td>123456</td>
                            </tr>
                        </tbody>
                    </table>
                </div>
                <div class="total">
                    <table>
                        <tr>
                            <td>合计</td>
                            <td>-</td>
                        </tr>
                    </table>
                </div>
            </div>
        </div>
        <div class="layer">
            <div class="criteria">
                <div class="options">
                    <div class="local">
                        <p class="title">开发编号</p>
                        <ul id="kfbh">
                            <li class="onchoose">全部..</li>
                            <%=SeasonOptionCollect %>
                        </ul>
                    </div>
                    <div class="num">
                        <p class="title">是否断码</p>
                        <ul id="isfault">
                            <li isfault="1" >是</li>
                            <li isfault="0">否</li>
                        </ul>
                    </div>
                </div>
                <div class="confirm">
                    <button id="reset">重置</button>
                    <button id="complete">完成</button>
                </div>
            </div>
        </div>
        
        <!--加载提示-->
        <div class="load_toast" id="myLoading">
            <div class="load_toast_mask"></div>
            <div class="load_toast_container">
                <div class="lee_toast">
                    <div class="load_img">
                        <img src="../../res/img/my_loading.gif" />
                    </div>
                    <div class="load_text">加载中...</div>
                </div>
            </div>
        </div>
        
        <script id="invAlter" type="text/html">
            <tr>
                <td>{{khmc}}</td>
                <td>{{mc}}</td>
                <td>{{sphh}}</td>
                <td>{{inv}}</td>
                <td>{{typedata}}</td>
                <td>
                    <div class="size">
                        <p>
                            <span>类型</span>
                            {{each size as value i}}
                            <span>{{value}}</span>
                            {{/each}}
                        </p>
                        <p>
                            <span>当前库存</span>
                            {{each curinv as value i}}
                            {{if value == '-'}}
                            <span>{{value}}</span>
                            {{else}}
                            <span class="stock">{{value}}</span>
                            {{/if}}
                            {{/each}}
                        </p>
                        <p>
                            <span>在途库存</span>
                            {{each inway as value i}}
                            {{if value == '-'}}
                            <span>{{value}}</span>
                            {{else}}
                            <span class="stock">{{value}}</span>
                            {{/if}}
                            {{/each}}
                        </p>
                    </div>
                </td>
            </tr>
        </script>
        <script type="text/javascript" src="../../res/js/jquery-3.2.1.min.js"></script>
        <script type="text/javascript" src="../../res/js/fastclick.min.js"></script>
        <script type="text/javascript" src="../../res/js/template.js"></script>
        <script type="text/javascript" src="../../res/js/StoreSaler/inventoryAlert.js"></script>
        <script type="text/javascript">
            $(function(){
                inventoryAlert.init();
            });
        </script>
    </body>
</html>