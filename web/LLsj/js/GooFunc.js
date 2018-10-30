/*本系列框架中,一些用得上的小功能函数,一些UI必须使用到它们,用户也可以单独拿出来用*/

//获取一个DIV的绝对坐标的功能函数,即使是非绝对定位,一样能获取到
function getElCoordinate(dom) {
  var t = dom.offsetTop;
  var l = dom.offsetLeft;
  dom=dom.offsetParent;
  while (dom) {
    t += dom.offsetTop;
    l += dom.offsetLeft;
	dom=dom.offsetParent;
  }; return {
    top: t,
    left: l
  };
}
//兼容各种浏览器的,获取鼠标真实位置
function mousePosition(ev){
	if(!ev) ev=window.event;
    if(ev.pageX || ev.pageY){
        return {x:ev.pageX, y:ev.pageY};
    }
    return {
        x:ev.clientX + document.documentElement.scrollLeft - document.body.clientLeft,
        y:ev.clientY + document.documentElement.scrollTop  - document.body.clientTop
    };
}
//给DATE类添加一个格式化输出字串的方法
Date.prototype.format = function(format)   
{   
   var o = {   
      "M+" : this.getMonth()+1, //month  
      "d+" : this.getDate(),    //day  
      "h+" : this.getHours(),   //hour  
      "m+" : this.getMinutes(), //minute  
      "s+" : this.getSeconds(), //second  ‘
	  //quarter  
      "q+" : Math.floor((this.getMonth()+3)/3), 
      "S" : this.getMilliseconds() //millisecond  
   }   
   if(/(y+)/.test(format)) format=format.replace(RegExp.$1,(this.getFullYear()+"").substr(4 - RegExp.$1.length));   
    for(var k in o)if(new RegExp("("+ k +")").test(format))   
      format = format.replace(RegExp.$1,   
        RegExp.$1.length==1 ? o[k] :    
          ("00"+ o[k]).substr((""+ o[k]).length));   
    return format;   
}
//JS]根据格式字符串分析日期（MM与自动匹配两位的09和一位的9）
//alert(getDateFromFormat(sDate,sFormat));
function getDateFromFormat(dateString,formatString){
	var regDate = /\d+/g;
	var regFormat = /[YyMmdHhSs]+/g;
	var dateMatches = dateString.match(regDate);
	var formatmatches = formatString.match(regFormat);
	var date = new Date();
	for(var i=0;i<dateMatches.length;i++){
		switch(formatmatches[i].substring(0,1)){
			case 'Y':
			case 'y':
				date.setFullYear(parseInt(dateMatches[i]));break;
			case 'M':
				date.setMonth(parseInt(dateMatches[i])-1);break;
			case 'd':
				date.setDate(parseInt(dateMatches[i]));break;
			case 'H':
			case 'h':
				date.setHours(parseInt(dateMatches[i]));break;
			case 'm':
				date.setMinutes(parseInt(dateMatches[i]));break;
			case 's':
				date.setSeconds(parseInt(dateMatches[i]));break;
		}
	}
	return date;
}
//货币分析成浮点数
//alert(parseCurrency("￥1,900,000.12"));
function parseCurrency(currentString){
	var regParser = /[\d\.]+/g;
	var matches = currentString.match(regParser);
	var result = '';
	var dot = false;
	for(var i=0;i<matches.length;i++){
		var temp = matches[i];
		if(temp =='.'){
			if(dot) continue;
		}
		result += temp;
	}
	return parseFloat(result);
}

//将#XXXXXX颜色格式转换为RGB格式，并附加上透明度
function brgba(hex, opacity) {
    if( ! /#?\d+/g.test(hex) ) return hex; //如果是“red”格式的颜色值，则不转换。//正则错误，参考后面的PS内容
    var h = hex.charAt(0) == "#" ? hex.substring(1) : hex,
        r = parseInt(h.substring(0,2),16),
        g = parseInt(h.substring(2,4),16),
        b = parseInt(h.substring(4,6),16),
        a = opacity;
    return "rgba(" + r + "," + g + "," + b + "," + a + ")";
}

/*我的代码*/
var property = {
    width: 400,
    height: 600,
    toolBtns: ["start round", "end", "task", "node", "chat", "state", "plug", "join", "fork", "complex mix"],
    haveHead: true,
    headBtns: ["new", "open", "save", "undo", "redo", "reload"],//如果haveHead=true，则定义HEAD区的按钮
    haveTool: true,
    haveGroup: true,
    useOperStack: true
};
var remark = {
    cursor: "选择指针",
    direct: "转换连线",
    start: "开始结点",
    "end round": "结束结点",
    "task round": "任务结点",
    node: "自动结点",
    chat: "决策结点",
    state: "状态结点",
    plug: "附加插件",
    fork: "分支结点",
    "join": "联合结点",
    "complex mix": "复合结点",
    group: "组织划分框编辑开关"
};

var json_data = {}, flow_chart;
function loadFlowGraphConfig(arg, cb) {
    $.ajax({
        type: "POST",
        timeout: 5000,
        contentType: "application/x-www-form-urlencoded; charset=utf-8",
        data: arg.data,
        url: arg.url,
        success: function (msg) {
            if (msg.indexOf("Error:") > -1) {
                showLoading(msg);
            } else {
                var ajax_data = JSON.parse(msg), nodes = {}, lines = {};
                json_data = { title: "利郎审批流程图" };
                for (var i = 0; i < ajax_data.nodes.length; i++) {
                    var attr = ajax_data.nodes[i].nodedisp;
                    var left = getAttribute(attr, "left");
                    var top = getAttribute(attr, "top");
                    var width = getAttribute(attr, "width");
                    var height = getAttribute(attr, "height");
                    nodes[ajax_data.nodes[i].nodeid] = { name: ajax_data.nodes[i].nodename, top: top, left: left, width: width, height: height, type: "task", alt: true };
                }//end for            
                json_data.nodes = nodes;
                json_data.initNum = ajax_data.nodes.length;

                for (var i = 0; i < ajax_data.lines.length; i++) {
                    lines[ajax_data.lines[i].mxid] = { type: "sl", from: ajax_data.lines[i].fromnode, to: ajax_data.lines[i].tonode, name: "", alt: true };
                }//end for

                json_data.lines = lines;
                console.log(json_data);
                flow_chart.clearData();
                flow_chart.loadData(json_data);
                $("#" + ajax_data.editnode).addClass("current");
                cb();
            }
        },
        error: function (XMLHttpRequest, textStatus, errorThrown) {
            showLoading(XMLHttpRequest.status + "|" + XMLHttpRequest.statusText);
            console.log(XMLHttpRequest.status + "|" + XMLHttpRequest.statusText);
        }
    });
}

//function createLines(arg) {    
//    $.ajax({
//        type: "POST",
//        timeout: 5000,
//        contentType: "application/x-www-form-urlencoded; charset=utf-8",
//        data: arg.data,
//        url: arg.url,
//        success: function (msg) {            
//            var data = JSON.parse(msg), lines = {};            
//            for (var i = 0; i < data.rows.length; i++) {
//                lines[data.rows[i].mxid] = { type: "sl", from: data.rows[i].fromnode, to: data.rows[i].tonode, name: "", alt: true };
//            }//end for
//            json_data.lines = lines;                        
//            flow_chart.loadData(json_data);            
//        },
//        error: function (XMLHttpRequest, textStatus, errorThrown) {
//            console.log(XMLHttpRequest.status + "|" + XMLHttpRequest.statusText);
//        }
//    });    
//}

//function clearLines() {
//    flow_chart.clearData();    
//    json_data = {};
//}

function getAttribute(str, name) {
    switch (name) {
        case "left":
            return parseInt(str.substring(str.indexOf("t:") + 2, str.indexOf(";t")));
            break;
        case "top":
            return parseInt(str.substring(str.indexOf("p:") + 2, str.indexOf(";w")));
            break;
        case "width":
            return parseInt(str.substring(str.indexOf("h:") + 2, str.indexOf(";h")));
            break;
        case "height":
            return parseInt(str.substring(str.indexOf("ht:") + 3, str.length - 1));
            break;
        default:
            break;
    }
}

function initFlowChart(config, containerid, cb) {
    flow_chart = $.createGooFlow($("#" + containerid), property);
    flow_chart.setNodeRemarks(remark);
    flow_chart.setTitle("利郎审批流程图");
    cb = cb || function () { };    
    loadFlowGraphConfig(config, cb);
    //$.when(createNodes(arg_node)).done(createLines(arg_line)).done(cb());
}