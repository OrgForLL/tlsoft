<%@ Page Title="销售目标对照表" Language="C#" AutoEventWireup="true" %>

<%@ Import Namespace="nrWebClass" %>
<%@ Import Namespace="System.Data" %>
<%@ Import Namespace="System.Collections.Generic" %>
<script runat="server">
    public string roleName = "";
    public int roleID = 0;
    public string AuthOptionCollect = "" ;   //选择栏
    public string KhClassOptionCollect = ""; //客户类别
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
          
        KhClassCollect();
        
        DataTable dt = null;
        if (roleID == 4)
        {
            //获取当前用户的身份。默认会自动选中第一个项
            dt = clsWXHelper.GetQQDAuth();
        }
        else if (roleID < 3 && roleID > 0)
        {
            string strSQL = "";            
                strSQL = string.Concat(@"SELECT TOP 1 a.khid , mdmc ,convert(varchar(10),kh.ssid) 'ssid',mdid
                                            FROM t_mdb a inner join yx_t_khb kh on a.khid=kh.khid WHERE a.mdid = ", Session["mdid"]);            
//            else
//            {
//                strSQL = string.Concat(@"SELECT a.khid ,  khmc mdmc,1 'ssid',0 'mdid'  FROM yx_t_khb A 
//                                                    WHERE A.ssid = 1 AND A.yxrs = 1 AND ISNULL(A.ty,0) = 0
//                                                                        AND ISNULL(A.sfdm,'') <> ''                                            
//                                                     ORDER BY A.khmc");
//            }

            string dbConn = clsConfig.GetConfigValue("OAConnStr");
            using (LiLanzDALForXLM dal = new LiLanzDALForXLM(dbConn))
            {
                string strInfo = dal.ExecuteQuery(strSQL, out dt);
                if (strInfo != "")
                {
                    clsWXHelper.ShowError("权限信息读取错误！strInfo:" + strInfo);
                    return;
                }
                if (dt.Rows.Count == 0)
                {
                    sbCompany.AppendFormat(optionBase, "-1", "门店人资权限错误！请联系总部IT", opselect, "");
                    return;
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
        }
        else
        {
            sbCompany.AppendFormat(optionBase, "", "完整权限", opselect, "");                        
        } 
        
        AuthOptionCollect = sbCompany.ToString();
        sbCompany.Length = 0; 
    }
     

    //暂定按roleName来区分 kf ty=0 and tzfl<>'' zb(Z) my(D) dz(C)
    public void KhClassCollect()
    {
        if (roleName != "")
        {
            string dbConn = clsConfig.GetConfigValue("OAConnStr");
            using (LiLanzDALForXLM dal = new LiLanzDALForXLM(dbConn))
            {
                string _sql = "";
                switch (roleName)
                {
                    case "kf":
                        //_sql = "select cs,mc from yx_t_khfl where ty=0 and tzfl<>''";
                        break;
                    case "zb":
                        _sql = "select cs,mc from yx_t_khfl where ty=0 and tzfl like '%Z,%'";
                        break;
                    case "my":
                        _sql = "select cs,mc from yx_t_khfl where ty=0 and tzfl like '%D,%'";
                        break;
                    case "dz":
                        _sql = "select cs,mc from yx_t_khfl where ty=0 and tzfl like '%C,%'";
                        break;
                    default:
                        break;
                }

                if (_sql != "")
                {
                    StringBuilder sbKhClass = new StringBuilder();
                    string optionBase = "<div class=\"fitem\" cs=\"{0}\">{1}</div>";
                    DataTable dt;

                    string errinfo = dal.ExecuteQuery(_sql, out dt);
                    if (errinfo == "")
                    {
                        for (int i = 0; i < dt.Rows.Count; i++)
                        {
                            sbKhClass.AppendFormat(optionBase, Convert.ToString(dt.Rows[i]["cs"]), dt.Rows[i]["mc"], "");
                        }//end for
                    }

                    KhClassOptionCollect = sbKhClass.ToString();
                    sbKhClass.Length = 0;
                    dt.Clear(); dt.Dispose();
                }
            }//end using  
        }
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
    <link type="text/css" rel="stylesheet" href="../../res/css/font-awesome.min.css" />
    <link type="text/css" rel="stylesheet" href="../../res/css/StoreSaler/saleTarget.css?v=2" />
</head>
<body>
	<div class="header">
		<%--<div class="form-item">
			<span>年月</span>
    		<input type="month">
		</div>--%>
<%--		<div class="form-item">
			<span>状态</span>
    		<select id="sltStatus">
    			<option value="">全部</option>
    			<option value="0">未达标</option>
    			<option value="1">已达标</option>
    		</select>
		</div>--%>
<%--		<div class="form-item">
			<span class="checktxt">以销售目标为主</span>
    		<input id="chk" type="checkbox" checked="checked">
		</div>--%>
		<div class="form-item">
			<span>贸易公司</span>
            <div>
                <select id="sltkhid">    			
                    <%=AuthOptionCollect%>
    		    </select>
            </div>    		
		</div>
        
        <div class="filterdiv">
            <i class="fa fa-filter">
                <br />
            </i>
            <p>筛选</p>
        </div>
		<%--<div class="form-item">
			<span>专卖店名</span>
    		<input id="mdmc" type="text">
		</div>--%>
<%--		<div class="form-item">
			<input id="inquireBtn" type="button" value="查询">
		</div>--%>
	</div>
	<div class="wrap-page">
        <div class="page" id="table_page">
        	<div class="ht-div" id="hDiv">
        		<table class="head-table" cellpadding="0" cellspacing="0">
        			<thead>
        				<tr>
        					<th width="120px" class="txt-center" data-ordername="mdmc">客户名</th>
        					<th width="80px" data-ordername="xsje">实际销售额<i class='fa fa-sort-desc'></i></th>
        					<th width="80px" data-ordername="mbje">目标销售额</th>
        					<th width="80px" data-ordername="wcbl">完成比率</th> 
        					<th width="100px" data-ordername="qnje">去年同期销售</th>
        					<th width="80px" data-ordername="tqzzl">同期增长率</th>
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
            
        </div>
    </div>
    <!--右侧筛选页-->
            <div class="page page-right" id="fiterpage">
                <div class="filtercontainer">
                    <!--专卖店筛选-->
                    <div class="farea floatfix">
                        <p class="title nowarp">专卖店名称：</p> 
                        <input class="oneline" id="zmdmc" />
                    </div>
                    <!--可比选择-->
                    <div class="farea fkhlb floatfix" style="border-top: 1px solid #e2e2e2;" filter="kbxz">
                        <p class="title">可比选择</p>
                        <div class="fitem" cs="">全部...</div>
                        <div class="fitem" cs="1">同期可比</div>
                        <div class="fitem" cs="2">同期不可比</div>                        
                    </div>
                    <!--日期范围-->
                    <div class="farea" style="border-top: 1px solid #e2e2e2; margin-bottom: 15px;">
                        <p class="title">日期范围 <i class="fa fa-check-square active"></i></p>
                        <div class="date" filter="rq">
                            <input type="date" id="ksrq">
                            <div class="line"></div>
                            <input type="date" id="jsrq" />
                        </div>
                    </div>
                    <!--客户类别-->
                    <div class="farea fkhlb floatfix" style="border-top: 1px solid #e2e2e2;" filter="khfl">
                        <p class="title">客户类别</p> 
                        <%=KhClassOptionCollect %>
                    </div>
                    <div class="farea fkhlb floatfix" style="border-top: 1px solid #e2e2e2;" filter="zmdfl">
                        <p class="title">专卖店类别</p>
                        <div class="fitem" cs="">全部...</div>
                        <div class="fitem" cs="xz">主品牌直营店</div>
                        <div class="fitem" cs="xj">主品牌加盟店</div>
                        <div class="fitem" cs="xm">轻商务直营店</div>
                        <div class="fitem" cs="xn">轻商务加盟店</div>
                        <div class="fitem" cs="x[m,n]">轻商务全部店</div>
                    </div>
                </div>
                <div class="fbtns">
                    <a href="javascript:ResetFilter()">重置</a>
                    <a href="javascript:SubmitFilter()" style="background-color: #1cc1c7; color: #fff;">完成</a>
                </div>
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
    <div class="mymask"></div>
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
			<td width="160px" class="txt-left">{{data.mdmc}}</td>
			<td width="80px">{{data.xsje}}</td>
			<td width="80px">{{data.mbje}}</td>
			<td width="80px">
                {{if data.wcbl != "" }}
                    {{if data.wcbl >= 100.0 }} <span class="rate addrate">{{data.wcbl}}%</span>
                    {{ else }} <span class="rate decrate">{{data.wcbl}}%</span>{{ /if }}
                {{ /if }}
            </td> 
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
			<th width="100px">{{SumQnje}}</th> 
			<th width="80px">
                {{if SumTqzzl > 0 }} <span class="rate addrate">+{{SumTqzzl}}%</span>{{ /if }}
                {{if SumTqzzl < 0 }} <span class="rate decrate">{{SumTqzzl}}%</span>{{ /if }}
            </td>
		</tr>		
    </script>

    <script type="text/javascript" src="../../res/js/jquery.js"></script>
    <script type="text/javascript" src="../../res/js/LeeJSUtils.min.js"></script>
    <script type="text/javascript" src="../../res/js/template.js"></script>
	<script type="text/javascript">
	    var OrderColumn = "xsje";
	    var OrderDirec = "desc"

		var dDiv = document.getElementById('dDiv');

		$(document).ready(function () {
		    LeeJSUtils.stopOutOfPage(".header", false);

		    $("input[type='month']").val(nowdate());
		    $(".body-table").prepend($(".head-table thead").clone());
		    $(".body-table thead").hide();

		    dDiv.addEventListener("scroll", scrollFunc);
             
		    //			LeeJSUtils.fastClick();

		    $(".filterdiv").on("click", function () {
		        $(".mymask").show();
		        $("#fiterpage").removeClass("page-right");
		    })
		    $(".mymask").on("click", function () {
		        $("#fiterpage").addClass("page-right");
		        $(".mymask").hide();
		    })

		    $(".filterdiv").click();
		    ResetFilter();

		    BindSelectObjects();


            $(".head-table").find("thead>tr>th").on("click",SetOrder);
		});

		//表头随表体横向滚动
		function scrollFunc(){ 
	    	$(".head-table").css("transform", "translate("+ dDiv.scrollLeft*-1 + "px, 0px)"); 
	    	$(".foot-table").css("transform", "translate("+ dDiv.scrollLeft*-1 + "px, 0px)");
    	 }

    	 function SetOrder() {
    	     var nowordername = $(this).attr("data-ordername");
    	     $(this).parent().find("i").remove(); //移除所有的i标记

    	     if (nowordername == OrderColumn) {
    	         if (OrderDirec == "asc") OrderDirec = "desc";
    	         else OrderDirec = "asc";
    	     } else {
    	         OrderColumn = nowordername;
    	         OrderDirec = "desc";
    	     }
    	     $(this).append("<i class='fa fa-sort-" + OrderDirec + "'></i>");
    	     Search();
    	 }

          
		// 查询按钮
		function Search() {
		    //收集查询条件
		    var filter = {};
		    var kbxz = $("div[filter='kbxz'] .fitem.selected").attr("cs");
		    var khfl = $("div[filter='khfl'] .fitem.selected").attr("cs");
		    var zmdfl = $("div[filter='zmdfl'] .fitem.selected").attr("cs");
		    var ksrq = "", jsrq = "";

		    if ($(".fa-check-square").hasClass("active")) {
		    	ksrq = $("#ksrq").val();
		    	jsrq = $("#jsrq").val();
		    }   

		    zmdfl = typeof (zmdfl) == "undefined" ? "" : zmdfl
		    khfl = typeof (khfl) == "undefined" ? "" : khfl;
             
		    filter.ksrq = ksrq;
		    filter.jsrq = jsrq;
		    filter.kbxz = kbxz;
		    filter.zmdfl = zmdfl;
		    filter.khfl = khfl; 
		    filter.khid = $("#sltkhid").val();
		    filter.mdmc = $("#zmdmc").val(); 

		    console.log(filter);

		    $(".load-wrap").show();
		    $(".body-table").find("tbody").html("数据分析中...");
		    $.ajax({
		        type: "POST",
		        timeout: 30000,
		        contentType: "application/x-www-form-urlencoded; charset=utf-8",
		        url: "saleTargetCore.ashx",
		        data: { ctrl: "LoadData", filters: JSON.stringify(filter), "OrderColumn": OrderColumn, "OrderDirec": OrderDirec },
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
		}


		//筛选事件绑定

		function BindSelectObjects() {
		    BindSelectPanel("kbxz");
		    BindSelectPanel("khfl");
		    BindSelectPanel("zmdfl");
		}

		function BindSelectPanel(v) {
		    $("div[filter='" + v + "'] .fitem").on("click", function () {
		        if ($(this).hasClass("selected"))
		            $(this).removeClass("selected");
		        else {
		            $("div[filter='" + v + "'] .selected").removeClass("selected");
		            $(this).addClass("selected");
		        }
		    });
		}
         

		//日期筛选条件是否生效
		$(".fa-check-square").on("click", function () {
		    if ($(this).hasClass("active")) { 
		        $(".date input").css("color", "#ccc").attr("readonly", "true");
		        $(this).removeClass("active");
		    } else {
		        $(".date input").css("color", "#000").removeAttr("readonly");
		        $(this).addClass("active");
		    }
		});

		//重置
		function ResetFilter() {
		    $("#zmdmc").val("");

		    $("#ksrq").val(new Date().format("yyyy-MM") + "-01");
		    $("#jsrq").val(new Date().format("yyyy-MM-dd"));
            
		    $(".fa-check-square").removeClass("active");
		    $(".fa-check-square").addClass("active");

		    $(".date input").css("color", "#000").removeAttr("readonly");
		    $("div[filter='kbxz'] .fitem").removeClass("selected");
		    $("div[filter='kbxz'] .fitem").eq(0).addClass("selected");

		    $("div[filter='khfl'] .fitem").removeClass("selected");

		    $("div[filter='zmdfl'] .fitem").removeClass("selected");
		    $("div[filter='zmdfl'] .fitem").eq(0).addClass("selected");
		}

		//筛选提交
		function SubmitFilter() {
//		    var kfbh = $("div[filter='kfbh'] .fitem.selected").attr("dm");
//		    var khfl = $("div[filter='khfl'] .fitem.selected").attr("cs");
//		    var zmdfl = $("div[filter='zmdfl'] .fitem.selected").attr("cs");
//		    var ksrq = "", jsrq = "";

//		    if ($(".fa-check-square").hasClass("active")) {
//		        ksrq = $("#ksrq").val();
//		        jsrq = $("#jsrq").val();
//		    }

//		    if (kfbh == "all" && !$(".fa-check-square").hasClass("active")) {
//		        alert("【开发编号】与【日期范围】必须至少限制一项！");
//		        return;
//		    }

//		    //filter.filter.kfbh = typeof(kfbh) == "undefined" ? "" : kfbh;
//		    if (kfbh == "all" || typeof (kfbh) == "undefined")
//		        filter.filter.kfbh = "";
//		    else
//		        filter.filter.kfbh = kfbh;
//		    zmdfl = typeof (zmdfl) == "undefined" ? "" : zmdfl
//		    khfl = typeof (khfl) == "undefined" ? "" : khfl;
//		    khfl = khfl + '-' + zmdfl;

//		    filter.filter.khfl = khfl;
//		    filter.filter.ksrq = ksrq == "" ? "" : ksrq;
//		    filter.filter.jsrq = jsrq == "" ? "" : jsrq;
		    $("#fiterpage").addClass("page-right");
		    $(".mymask").hide();

            Search();
		}
		// 获取当前年月
        function nowdate(){
            var now = new Date();
            y = now.getFullYear();
            m = now.getMonth() + 1;
            m = m < 10 ? "0" + m:m;
            return y + "-" + m;
        }

        //日期格式化
        Date.prototype.format = function (format) {
            var o = {
                "M+": this.getMonth() + 1, //month 
                "d+": this.getDate(), //day 
                "h+": this.getHours(), //hour 
                "m+": this.getMinutes(), //minute 
                "s+": this.getSeconds(), //second 
                "q+": Math.floor((this.getMonth() + 3) / 3), //quarter 
                "S": this.getMilliseconds() //millisecond 
            }

            if (/(y+)/.test(format)) {
                format = format.replace(RegExp.$1, (this.getFullYear() + "").substr(4 - RegExp.$1.length));
            }

            for (var k in o) {
                if (new RegExp("(" + k + ")").test(format)) {
                    format = format.replace(RegExp.$1, RegExp.$1.length == 1 ? o[k] : ("00" + o[k]).substr(("" + o[k]).length));
                }
            }
            return format;
        }
	</script>
</body>
</html>