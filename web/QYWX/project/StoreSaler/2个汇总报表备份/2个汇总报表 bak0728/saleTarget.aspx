<%@ Page Title="销售目标对照表" Language="C#" AutoEventWireup="true" %>

<%@ Import Namespace="nrWebClass" %>
<%@ Import Namespace="System.Data" %>
<%@ Import Namespace="System.Collections.Generic" %>
<script runat="server">
    public string roleName = "";
    public int roleID = 0;
    public string AuthOptionCollect = "";
    const int SystemID = 3;
    protected void Page_Load(object sender, EventArgs e)    
    { 
        if (clsWXHelper.CheckQYUserAuth(true))
        {
            string strSystemKey = clsWXHelper.GetAuthorizedKey(SystemID);            
            if (string.IsNullOrEmpty(strSystemKey)) {
                clsWXHelper.ShowError("超时 或 没有全渠道权限！");
                return;
            }
        }
        
        //clsWXHelper.CheckQQDMenuAuth(22);    //检查菜单权限
        string optionBase = "<option value=\"{0}\" {2} data-ssid={3}>{1}</option>";
        string opselect = " selected";
        StringBuilder sbCompany = new StringBuilder();
        roleID = Convert.ToInt32(Session["RoleID"]);
        roleName = Convert.ToString(Session["RoleName"]);

        DataTable dt = null;
        if (roleID == 4)
        {
            //获取当前用户的身份。默认会自动选中第一个项
            dt = clsWXHelper.GetQQDAuth();
        }
        else
        {
            string strSQL = "";
            if (roleID < 3 && roleID > 0)
            {
                strSQL = string.Concat(@"SELECT TOP 1 a.khid , mdmc ,convert(varchar(10),kh.ssid) 'ssid',mdid
                                            FROM t_mdb a inner join yx_t_khb kh on a.khid=kh.khid WHERE a.mdid = ", Session["mdid"]);               
            }
            else
            {
                strSQL = string.Concat(@"SELECT a.khid ,  khmc mdmc,1 'ssid',0 'mdid'  FROM yx_t_khb A 
                                                    WHERE A.ssid = 1 AND A.yxrs = 1 AND ISNULL(A.ty,0) = 0
                                                                        AND ISNULL(A.sfdm,'') <> ''                                            
                                                     ORDER BY A.khmc");
            }

            string dbConn = clsConfig.GetConfigValue("OAConnStr");
            using (LiLanzDALForXLM dal = new LiLanzDALForXLM(dbConn))
            { 
                string strInfo = dal.ExecuteQuery(strSQL, out dt);
                if (strInfo != "")
                {
                    clsWXHelper.ShowError("权限信息读取错误！strInfo:" + strInfo);
                    return;                    
                }
                if( dt.Rows.Count == 0){
                    sbCompany.AppendFormat(optionBase, "-1", "门店人资权限错误！请联系总部IT", opselect, "");
                    return;
                } 
            }
        }

        DataRow dr;
        DataRow[] drList = dt.Select("", "ssid,khid,mdid");
        for (int i = 0; i < dt.Rows.Count; i++)
        {
            dr = drList[i];

            sbCompany.AppendFormat(optionBase, dr["khid"], dr["mdmc"], "", dr["ssid"]);
        }

        if (dt.Rows.Count == 0) sbCompany.AppendFormat(optionBase, "-1", "您还没有授权，请联系总部IT", opselect, "");
        
        AuthOptionCollect = sbCompany.ToString();
        sbCompany.Length = 0; 
    }
</script>
<!DOCTYPE html>
<html>
<head> 
    <meta charset="utf-8" />
    <meta name="viewport" content="width=device-width,initial-scale=1,user-scalable=0,maximum-scale=1" />
    <meta name="format-detection" content="telephone=no" />
    <meta name="apple-mobile-web-app-capable" content="yes" />
    <meta name="apple-mobile-web-app-status-bar-style" content="black" />
    <title>销售目标对照表</title>
    <link type="text/css" rel="stylesheet" href="../../res/css/LeePageSlider.css" />
    <link type="text/css" rel="stylesheet" href="../../res/css/StoreSaler/saleTarget.css?v=1" />
</head>
<body>
	<div class="header">
		<div class="form-item">
			<span>年月</span>
    		<input type="month">
		</div>
		<div class="form-item">
			<span>状态</span>
    		<select id="sltStatus">
    			<option value="">全部</option>
    			<option value="0">未达标</option>
    			<option value="1">已达标</option>
    		</select>
		</div>
		<div class="form-item">
			<span class="checktxt">以销售目标为主</span>
    		<input id="chk" type="checkbox" checked="checked">
		</div>
		<div class="form-item">
			<span>贸易公司</span>
    		<select id="sltkhid">    			
                <%=AuthOptionCollect%>
    		</select>
		</div>
		<div class="form-item">
			<span>专卖店名</span>
    		<input id="mdmc" type="text">
		</div>
		<div class="form-item">
			<input id="inquireBtn" type="button" value="查询">
		</div>
	</div>
	<div class="wrap-page">
        <div class="page" id="table_page">
        	<div class="ht-div" id="hDiv">
        		<table class="head-table" cellpadding="0" cellspacing="0">
        			<thead>
        				<tr>
        					<th width="120px" class="txt-center">客户名</th>
        					<th width="80px">实际销售额</th>
        					<th width="80px">目标销售额</th>
        					<th width="80px">完成比率</th>
        					<th width="80px">未完成额</th>
        					<th width="100px">去年同期销售额</th>
        					<th width="80px">同期增长率</th>
        				</tr>
        			</thead>
        		</table>
        	</div>
        	<div class="bt-div" id="dDiv">
        		<table class="body-table" cellpadding="0" cellspacing="0">
        			<tbody>
        				<%--<tr>
        					<td width="120px" class="txt-center">福州中亭街专卖店</td>
        					<td width="80px">29226</td>
        					<td width="80px">297000</td>
        					<td width="60px">9.84%</td>
        					<td width="80px">-267774</td>
        					<td width="100px">153539</td>
        					<td width="80px"><span class="rate decrate">-83.50%</span></td>
        				</tr>
        				<tr>
        					<td width="120px" class="txt-center">福州泰合广场专卖店</td>
        					<td width="80px">29226</td>
        					<td width="80px">297000</td>
        					<td width="60px">9.84%</td>
        					<td width="80px">-267774</td>
        					<td width="100px">153539</td>
        					<td width="80px"><span class="rate addrate">-83.50%</span></td>
        				</tr>
        				<tr>
        					<td width="120px" class="txt-center">福州中亭街专卖店</td>
        					<td width="80px">29226</td>
        					<td width="80px">297000</td>
        					<td width="60px">9.84%</td>
        					<td width="80px">-267774</td>
        					<td width="100px">153539</td>
        					<td width="80px"><span class="rate decrate">-83.50%</span></td>
        				</tr>
        				<tr>
        					<td width="120px" class="txt-center">福州泰合广场专卖店</td>
        					<td width="80px">29226</td>
        					<td width="80px">297000</td>
        					<td width="60px">9.84%</td>
        					<td width="80px">-267774</td>
        					<td width="100px">153539</td>
        					<td width="80px"><span class="rate addrate">-83.50%</span></td>
        				</tr>
        				<tr>
        					<td width="120px" class="txt-center">福州中亭街专卖店</td>
        					<td width="80px">29226</td>
        					<td width="80px">297000</td>
        					<td width="60px">9.84%</td>
        					<td width="80px">-267774</td>
        					<td width="100px">153539</td>
        					<td width="80px"><span class="rate decrate">-83.50%</span></td>
        				</tr>
        				<tr>
        					<td width="120px" class="txt-center">福州泰合广场专卖店</td>
        					<td width="80px">29226</td>
        					<td width="80px">297000</td>
        					<td width="60px">9.84%</td>
        					<td width="80px">-267774</td>
        					<td width="100px">153539</td>
        					<td width="80px"><span class="rate addrate">-83.50%</span></td>
        				</tr>
        				<tr>
        					<td width="120px" class="txt-center">福州中亭街专卖店</td>
        					<td width="80px">29226</td>
        					<td width="80px">297000</td>
        					<td width="60px">9.84%</td>
        					<td width="80px">-267774</td>
        					<td width="100px">153539</td>
        					<td width="80px"><span class="rate decrate">-83.50%</span></td>
        				</tr>
        				<tr>
        					<td width="120px" class="txt-center">福州泰合广场专卖店</td>
        					<td width="80px">29226</td>
        					<td width="80px">297000</td>
        					<td width="60px">9.84%</td>
        					<td width="80px">-267774</td>
        					<td width="100px">153539</td>
        					<td width="80px"><span class="rate addrate">-83.50%</span></td>
        				</tr>
        				<tr>
        					<td width="120px" class="txt-center">福州中亭街专卖店</td>
        					<td width="80px">29226</td>
        					<td width="80px">297000</td>
        					<td width="60px">9.84%</td>
        					<td width="80px">-267774</td>
        					<td width="100px">153539</td>
        					<td width="80px"><span class="rate decrate">-83.50%</span></td>
        				</tr>
        				<tr>
        					<td width="120px" class="txt-center">福州泰合广场专卖店</td>
        					<td width="80px">29226</td>
        					<td width="80px">297000</td>
        					<td width="60px">9.84%</td>
        					<td width="80px">-267774</td>
        					<td width="100px">153539</td>
        					<td width="80px"><span class="rate addrate">-83.50%</span></td>
        				</tr>--%>
        			</tbody>
        		</table>
        	</div>
        	<div class="ft-div" id="fDiv">
        		<table class="foot-table" cellpadding="0" cellspacing="0">
        			<thead>
        				<%--<tr>
        					<th width="120px" class="txt-center">合计</th>
	    					<th width="80px">325689</th>
	    					<th width="80px">12345678</th>
	    					<th width="60px">13.8%</th>
	    					<th width="80px">-25689278</th>
	    					<th width="100px">1235698</th>
	    					<th width="80px"><span class="rate addrate">-83.50%</span></th>
        				</tr>		--%>
        			</thead>
        		</table>
        	</div>
        </div>
    </div>

    <!-- 加载面板 -->
    <div class="load-wrap">
    	<div class="load-mask">
    		<div class="load-container">
    			<img class="load-img" src="../../res/img/storesaler/my_loading.gif">
    			<span class="load-txt">加载中...</span>
    		</div>
    	</div>
    </div>

    <!-- 表体内容模板 -->
    <script id="bodytable-temp" type="text/html"> 
        {{each list as data i}}           
    	<tr>
			<td width="120px" class="txt-left">{{data.mdmc}}</td>
			<td width="80px">{{data.xsje}}</td>
			<td width="80px">{{data.mbje}}</td>
			<td width="80px">
                {{if data.wcbl != "" }}
                    {{if data.wcbl >= 100.0 }} <span class="rate addrate">{{data.wcbl}}%</span>
                    {{ else }} <span class="rate decrate">{{data.wcbl}}%</span>{{ /if }}
                {{ /if }}
            </td>
			<td width="80px">{{data.wwce}}</td>
			<td width="100px">{{data.qnje}}</td>
			<td width="80px">
                {{if data.tqzzl > 0 }} <span class="rate addrate">+{{data.tqzzl}}%</span>{{ /if }}
                {{if data.tqzzl < 0 }} <span class="rate decrate">{{data.tqzzl}}%</span>{{ /if }}
            </td>
		</tr>    
        {{/each}}
    </script>

    <!-- 表尾内容模板 -->
    <script id="foottable-temp" type="text/html"> 
    	<tr>
			<th width="120px" class="txt-center">合计</th>
			<th width="80px">{{SumXsje}}</th>
			<th width="80px">{{SumMbje}}</th>
			<th width="80px"> 
                {{if SumWcbl != "0" }}
                    {{if SumWcbl >= 100.0 }} <span class="rate addrate">{{SumWcbl}}%</span>
                    {{ else }} <span class="rate decrate">{{SumWcbl}}%</span>{{ /if }}    
                {{ /if }}           
            </th>
			<th width="80px">{{SumWwce}}</th>
			<th width="100px">{{SumQnje}}</th> 
			<th width="80px">
                {{if SumTqzzl > 0 }} <span class="rate addrate">+{{SumTqzzl}}%</span>{{ /if }}
                {{if SumTqzzl < 0 }} <span class="rate decrate">{{SumTqzzl}}%</span>{{ /if }}
            </td>
		</tr>		
    </script>

    <script type="text/javascript" src="../../res/js/jquery.js"></script>
    <script type="text/javascript" src="../../res/js/LeeJSUtils-0.1.1.min.js"></script>
    <script type="text/javascript" src="../../res/js/template.js"></script>
	<script type="text/javascript">
		var dDiv = document.getElementById('dDiv');

		$(document).ready(function(){
			LeeJSUtils.stopOutOfPage(".header", false);

			$("input[type='month']").val(nowdate());
			$(".body-table").prepend($(".head-table thead").clone());
			$(".body-table thead").hide();

			dDiv.addEventListener("scroll", scrollFunc);

			bindEvents();
			LeeJSUtils.fastClick();
		});

		//表头随表体横向滚动
		function scrollFunc(){ 
	    	$(".head-table").css("transform", "translate("+ dDiv.scrollLeft*-1 + "px, 0px)"); 
	    	$(".foot-table").css("transform", "translate("+ dDiv.scrollLeft*-1 + "px, 0px)"); 
		}

		function bindEvents(){
			// 查询按钮
		    $("#inquireBtn").click(function () {
		        //收集查询条件
		        var filter = {};
		        filter.rq = $("input[type='month']").val();
		        filter.status = $("#sltStatus").val();
		        filter.khid = $("#sltkhid").val();
//		        filter.ssid = $('#sltkhid option:selected').attr("data-ssid"); //选中的ssid
		        filter.mdmc = $("#mdmc").val();
		        if ($("#chk").attr("checked") == "checked") filter.tgchk = "1";
		        else filter.tgchk = "0";

		        console.log(filter);

		        $(".load-wrap").show();
		        $(".body-table").find("tbody").html("数据分析中...");
		        $.ajax({
		            type: "POST",
		            timeout: 20000,
		            contentType: "application/x-www-form-urlencoded; charset=utf-8",
		            url: "saleTargetCore.ashx",
		            data: { ctrl: "LoadData", filters: JSON.stringify(filter) },
		            error: function (XMLHttpRequest, textStatus, errorThrown) {
		                LeeJSUtils.showMessage("error", "网络连接失败！");
		                $(".load-wrap").hide();
		            },
		            success: function (msg) {
		                $(".load-wrap").hide();
		                $(".body-table").find("tbody").html("");
		                if (msg != "" && msg.indexOf("Error:") == -1) {
		                    var data = eval("(" + msg + ")");
		                    var bodyhtml = template('bodytable-temp', data);
		                    $(".body-table").find("tbody").html(bodyhtml);
		                    var foothtml = template('foottable-temp', data.Sum);
		                    $(".foot-table").find("thead").html(foothtml);

		                    bodyhtml = ""; foothtml = "";
		                } else {
		                    $(".body-table").find("tbody").html(msg);
		                }
		            }
		        });


		    });
		}

		// 获取当前年月
        function nowdate(){
            var now = new Date();
            y = now.getFullYear();
            m = now.getMonth() + 1;
            m = m < 10 ? "0" + m:m;
            return y + "-" + m;
        }
	</script>
</body>
</html>