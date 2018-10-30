(function () {
    var gCompanyCode, gKuaidiNumber;
	var autoJson;
	var gAjax;
	var desc = 0;
	
	var getHistory = function(){
		$("#historyList").empty();
		var history = kdHistory.all();
		if(history.length > 0){
			var input = $("#queryInput").val();
			for(var i in history){
				var nu = history[i].nu;
				if(nu.indexOf(input) >= 0){
					window.kd.company.getCompany(history[i].code, function(comJson){
						$("#historyList").append("<li><a data-code=\"" + comJson.code + "\" data-nu=\"" + nu + "\"><span>" + comJson.shortname + "</span>" + nu + "</a></li>");
					});
				}
			}
		}
		if($("#historyList").html() != ""){
			$("#history").show();
		}else{
			$("#history").hide();
		}
	}	
	var changeCompany = function(){
		var userAgent = window.navigator.userAgent.toLowerCase();
		if(window.location.href.indexOf("/meizu/") >= 0){
			chooseCompany();
		}else if(userAgent.indexOf("iphone") != -1 || userAgent.indexOf("ipad") != -1 || userAgent.indexOf("android") != -1){	
			var openSelect = function(){
				$("#comSelect").val(gCompanyCode);
				var e = document.createEvent("MouseEvents");
				e.initMouseEvent("mousedown");
				$("#comSelect")[0].dispatchEvent(e);
			};
			if($("#comSelect option").length > 0){
				openSelect();
			}else if(autoJson.length > 0){
				var total = autoJson.length;
				var count = 0;
				for(var i in autoJson){
					window.kd.company.getCompany(autoJson[i].comCode, function(json){
						$("#comSelect").append("<option value=\"" + json.code + "\">" + json.companyname + "</option>");
						count ++;
						if(count >= total){
							$("#comSelect").append("<option value=\"other\">其他</option>");
							openSelect();
						}
					});
				}
			}else{
				window.kd.company.getCompany(gCompanyCode, function(json){
					$("#comSelect").append("<option value=\"" + json.code + "\">" + json.companyname + "</option>");
					$("#comSelect").append("<option value=\"other\">其他</option>");
					openSelect();
				});
			}
		}else{
			chooseCompany();
		}
	}
	var chooseCompany = function(){
		sessionStorage.setItem("lastQueryNum", gKuaidiNumber);
		if(window.location.href.indexOf("kuaidi100.com/result.jsp") >= 0){
			window.location.href = "/all/";
		}else{
			window.location.href = "all.jsp";
		}
	}
    var selectCompany = function(com) {
        gCompanyCode = com;
		$("#companyCode").val(com);
		window.kd.company.getCompany(gCompanyCode, function(json){
			$("#comurl").attr("href", json.comurl).html(json.companyname + "官网");
			$("#content .info1").show();
			$("#comImg").attr("alt", json.companyname).show();
			
			var img = new Image();
			img.src = "//cdn.kuaidi100.com/images/all/56/" + json.code + ".png";
			img.onload = function() {
				$("#comImg").attr("src", "//cdn.kuaidi100.com/images/all/56/" + json.code + ".png");
			};
			img.onerror = function() {
				$("#comImg").attr("src", "//cdn.kuaidi100.com/images/all/" + json.code + "_logo.gif");
			};
		});
    }
    var auto = function(callback) {
        $("#loadingBox").show();
        $.ajax({
			type:"post",
			url:"/autonumber/auto?num=" + gKuaidiNumber,
			dataType:"json",
			success:function (resultJson) {
				autoJson = resultJson;
				if(callback){
					callback(resultJson);
				}
			}
        });
    }
    var query = function() {
		$("#resultBox").hide();
		$("#fail").hide();
		$("#success").hide();
		$("#nocom").hide();
		$("#loadingBox").show();
		if(gAjax){
			gAjax.abort();
		}
        gAjax = $.ajax({
			type:"get",
			url:"/query?type=" + gCompanyCode + "&postid=" + gKuaidiNumber + "&id=1&valicode=&temp=" + Math.random(),
			dataType:"json",
			success:function (resultJson) {
				$("#loadingBox").hide();
				if (resultJson.status == 200) {
					var html = "";
					var total = resultJson.data.length;
					var gIsCheck = resultJson.ischeck;
					if(desc == 0){
						//顺序
						for (var i = total - 1; i >= 0; i --) {
							var ftime = resultJson.data[i].ftime;
							var date = ftime.substring(0, 10);
							var time = ftime.substring(11, 16);
							date = date.replace(/-/g, ".");
							var className = "";
							var col2 = "";
							if (i == (total - 1)) {
								className += "first";
								col2 = '<div class="col2"><span class="step"><span class="line2"></span><span class="point"></span></span></div>';
							}else if (i == 0 && gIsCheck == 0) {
								className += "last";
								col2 = '<div class="col2"><span class="step"><span class="line1"></span><span class="point"></span></span></div>';
							}else if (i == 0 && gIsCheck == 1) {
								className += "last finish";
								col2 = '<div class="col2"><span class="step"><span class="line1"></span><span class="point"></span></span></div>';
							}else{
								col2 = '<div class="col2"><span class="step"><span class="line1"></span><span class="line2"></span><span class="point"></span></span></div>';
							}
							var context = resultJson.data[i].context;
							context = getJumpNetContext(context, gCompanyCode, "fonterm");
							context = getTelContext(context);
							
							html += '<li class="' + className + '"><div class="col1"><dl><dt>' + date + '</dt><dd>' + time + '</dd></dl></div>' + col2 + '<div class="col3">' + context + '</div></li>';
						}
					}else{
						//倒序
						for (var i = 0; i < total; i ++) {
							var ftime = resultJson.data[i].ftime;
							var date = ftime.substring(0, 10);
							var time = ftime.substring(11, 16);
							date = date.replace(/-/g, ".");
							var className = "";
							var col2 = "";
							if (i == (total - 1)) {
								className += "first";
								col2 = '<div class="col2"><span class="step"><span class="line1"></span><span class="point"></span></span></div>';
							}else if (i == 0 && gIsCheck == 0) {
								className += "last";
								col2 = '<div class="col2"><span class="step"><span class="line2"></span><span class="point"></span></span></div>';
							} else if (i == 0 && gIsCheck == 1) {
								className += "last finish";
								col2 = '<div class="col2"><span class="step"><span class="line2"></span><span class="point"></span></span></div>';
							}else{
								col2 = '<div class="col2"><span class="step"><span class="line1"></span><span class="line2"></span><span class="point"></span></span></div>';
							}
							var context = resultJson.data[i].context;
							context = getJumpNetContext(context, gCompanyCode, "fonterm");
							context = getTelContext(context);
							
							html += '<li class="' + className + '"><div class="col1"><dl><dt>' + date + '</dt><dd>' + time + '</dd></dl></div>' + col2 + '<div class="col3">' + context + '</div></li>';
						}
					}
					$("#result").html(html);
					$("#success").show();
					$("#resultBox").show();
					kdHistory.add(gCompanyCode, gKuaidiNumber, gIsCheck);
				} else {
					$("#fail").show();
					$("#resultBox").show();
					kdHistory.add(gCompanyCode, gKuaidiNumber, -1);
				}
			}
        });
    }
	var getTelContext = function(context){
		var reg = new RegExp("1\\d{10}", "gi");
		return context.replace(reg, function($0){
			var html = "";
			$.ajax({
				type: "post",
				url: "/courier/searchapi.do",
				data: "method=courierinfobyphone&json={%22phone%22:%22" + $0 + "%22}",
				dataType: "json",
				async: false,
				success: function(resultJson){
					if(resultJson.status == 200){
						html = "<a href=\"/courier/detail_" + resultJson.guid + ".html\">" + $0 + "</a>";
					}else{
						html = "<a href=\"tel:" + $0 + "\">" + $0 + "</a>";
					}
				}
			});
			return html;
		});
	}
	var getJumpNetContext = function(context, com, flag) {
		/*跳转网点处理*/
		var netUrl = "//m.kuaidi100.com/network/search.jsp";
		if(window.location.href.indexOf("haosou") >= 0){
			netUrl = "network.jsp";
		}
		var beforeKeyword = "(?:(?!的|员|型|是).|^)";
		var keyword = ".?到达.?|.?问题.?|.?派件.?|.?签收.?|.?疑难.?|.?扫描.?|.?装袋.?|.?装包.?|.?妥投.?|.?操作员.?|.?审核.?|.?备注.?|.?客服.?|.?网点经理.?|.?员工.?|.?门卫.?|.?本人.?|.?草签.?|.?图片.?|.?分拨中心.?";
		var companyNetworkCodes = {
			"shentong": "5",
			"huitongkuaidi": "6",
			"huiqiangkuaidi": "27",
			"tiantian": "7",
			"zhaijisong": "12",
			"quanfengkuaidi": "23",
			"longbanwuliu": "24",
			"guotongkuaidi": "20",
			"kuaijiesudi": "18",
			"debangwuliu": "1",
			"zhongtong": "3",
			"yunda": "2"
		}
		var companyName = {
			"shentong": "申通",
			"huitongkuaidi": "百世",
			"huiqiangkuaidi": "汇强",
			"tiantian": "天天",
			"zhaijisong": "宅急送",
			"quanfengkuaidi": "全峰",
			"longbanwuliu": "龙邦",
			"guotongkuaidi": "国通",
			"kuaijiesudi": "快捷",
			"debangwuliu": "德邦",
			"zhongtong": "中通",
			"yunda": "韵达"
		}
		switch (com) {
		case ("shentong"):
		case ("huitongkuaidi"):
		case ("huiqiangkuaidi"):
		case ("tiantian"):
		case ("quanfengkuaidi"):
		case ("longbanwuliu"):
		case ("guotongkuaidi"):
		case ("kuaijiesudi"):
			{
				var pattern = beforeKeyword + "【((?:(?!" + keyword + ")[^\\s\\d【]){2,})】";
				var reg = new RegExp(pattern, "gi");
				context = context.replace(reg, function ($0, $1, $2) {
					return "【<a href=\"" + netUrl + "?from=" + flag + "&keyword=" + encodeURIComponent($1) + "&area=" + encodeURIComponent($1) + "&company=" + companyNetworkCodes[com] + "&comname=" + companyName[com] + "\">" + $1 + "</a>】";
				});
				break;
			}
		case ("debangwuliu"):
		case ("zhaijisong"):
		case ("zhongtong"):
			{
				var pattern = beforeKeyword + "\\[((?:(?!" + keyword + ")[^\\s\\d【]){2,})\\]";
				var reg = new RegExp(pattern, "gi");
				context = context.replace(reg, function ($0, $1, $2) {
					return "[<a href=\"" + netUrl + "?from=" + flag + "&keyword=" + encodeURIComponent($1) + "&area=" + encodeURIComponent($1) + "&company=" + companyNetworkCodes[com] + "&comname=" + companyName[com] + "\">" + $1 + "</a>]";
				});
				break;
			}
		case ("yunda"):
			{
				var pattern = "((?:(?!" + keyword + ")\\S){2,}):";
				var reg = new RegExp(pattern, "gi");
				context = context.replace(reg, function ($0, $1, $2) {
					return "<a href=\"" + netUrl + "?from=" + flag + "&keyword=" + encodeURIComponent($1) + "&area=" + encodeURIComponent($1) + "&company=" + companyNetworkCodes[com] + "&comname=" + companyName[com] + "\">" + $1 + "</a>:";
				});
				break;
			}
		}
		return context;
	}
	
	$(function(){
		$("#content").delegate(".a-changecom", "click" ,changeCompany).delegate(".a-choosecom", "click" ,chooseCompany);
		$("#comSelect").change(function(){
			if($("#comSelect").val() == "other"){
				chooseCompany();
			}else{
				$("#companyCode").val($("#comSelect").val());
				$("#queryForm").submit();
			}
		});
		$("#queryInput").keyup(function(){
			if($(this).val() == ""){
				$("#clearBtn").hide();
				$("#scanBtn").show();
			}else{
				$("#scanBtn").hide();
				$("#clearBtn").show();
			}
			getHistory();
		}).focus(function(){
			if($(this).val() == ""){
				$("#clearBtn").hide();
				$("#scanBtn").show();
			}else{
				$("#scanBtn").hide();
				$("#clearBtn").show();
			}
			getHistory();
		});
		$("#scanBtn").click(function(){
			window.kd.app.openapp("kuaidi100://ilovegirl?action=scan&from=m", "想用条码扫描吗？请安装快递100最新客户端。");
		});
		$("#clearBtn").on("click", function(){
			$("#queryInput").val("");
			$("#clearBtn").hide();
			$("#scanBtn").show();
			$("#queryInput").focus();
		});
		$("#queryBtn").on("click", function(){
			$("#queryForm").submit();
		});
		$("#historyList").delegate("a", "click", function(){
			window.location.href = "result.jsp?com=" + $(this).attr("data-code") + "&nu=" + $(this).attr("data-nu");
		});
		$("#clearHistory").on("click", function(){
			kdHistory.empty();
			$("#history").hide();
		});
		$("#historyCloseBtn").on("click", function(){
			$("#history").hide();
		});
		$("#saveBtn").click(function(){
			window.kd.app.openapp("kuaidi100://ilovegirl?action=save&num=" + gKuaidiNumber + "&com=" + gCompanyCode + "&from=m", "保存快递单号？请安装快递100最新客户端。");
		});
		$("#saveBtn2").click(function(){
			window.kd.app.openapp("kuaidi100://ilovegirl?action=save&num=" + gKuaidiNumber + "&com=" + gCompanyCode + "&from=m", "保存快递单号？请安装快递100最新客户端。");
		});
	});
	
	if(window.location.href.indexOf("samsung") != -1){
		desc = 1;
	}
	if ($("#queryInput").val() != "") {
		gKuaidiNumber = $("#queryInput").val();
		$("#showNumber").html(gKuaidiNumber);
		if ($("#companyCode").val() != "") {
			selectCompany($("#companyCode").val());
			query();
			auto();
		} else {
			auto(function(json){
				if (json.length > 0) {
					selectCompany(json[0].comCode);
					query();
				} else {
					$("#content .info1").hide();
					$("#loadingBox").hide();
					$("#success").hide();
					$("#fail").hide();
					$("#nocom").show();
					$("#resultBox").show();
				}
			});
		}
	}else{
		$("#showName").html("");
		$("#loadingBox").hide();
		$("#success").hide();
		$("#fail").hide();
		$("#nocom").show();
		$("#nocom").html("<h4>抱歉，未能获取到单号</h4>");
		$("#resultBox").show();
	}
})()