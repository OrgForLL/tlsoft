!function(n){function a(n,a){if(""==n)return"";a=a>0&&a<=20?a:2;var e=(n=parseFloat((n+"").replace(/[^\d\.-]/g,"")).toFixed(a)+"").split(".")[0].split("").reverse(),s=n.split(".")[1];for(t="",i=0;i<e.length;i++)t+=e[i]+((i+1)%3==0&&i+1!=e.length?",":"");return t.split("").reverse().join("")+"."+s}function e(n){var a=new RegExp("(^|&)"+n+"=([^&]*)(&|$)","i"),t=window.location.search.substr(1).match(a);return null!=t?unescape(t[2]):""}function s(a){var t={action:"removeMenuSelect",parameter:[a],token:e("apptoken")};n.ajax({url:"http://tm.lilanz.com/qywx/project/StoreSaler/mentalMenuCore.ashx",type:"POST",dataType:"text",contentType:"application/x-www-form-urlencoded; charset=UTF-8",timeout:5e3,data:JSON.stringify(t),error:function(n,a,t){},success:function(n){console.log(n)}})}function o(n){this.chartID=n.chartID,this.chartName=n.chartName,this.tplName=n.tplName,this.$container=n.$container,this.extendEvents={},this.eventsBind=!1,this.echarts={}}function r(a){var t=a||0;o.prototype.currAutoSequ=t;var e=o.prototype.autoSequence.eq(t);if("true"==e.data("isProcess"))return gShowLoading("该模块正在加载中.."),void setTimeout(gHideLoading,800);e.hasClass("add")||n("#app").append(template(e.data("tpl"),{}))}function c(a){a.$container.remove(),delete echartConfigs[a.chartID],a.menu.removeClass("add").data("isProcess","false"),n(".loading_mask").fadeOut(200)}var p=[{name:"china",src:"http://echarts.baidu.com/asset/map/js/china.js",json:"./mapjson/china.json",load:!1},{name:"河北",src:"http://echarts.baidu.com/asset/map/js/province/hebei.js",json:"./mapjson/hebei.json",load:!1},{name:"山西",src:"http://echarts.baidu.com/asset/map/js/province/shanxi.js",json:"./mapjson/shanxi.json",load:!1},{name:"内蒙古",src:"http://echarts.baidu.com/asset/map/js/province/neimenggu.js",json:"./mapjson/neimenggu.json",load:!1},{name:"辽宁",src:"http://echarts.baidu.com/asset/map/js/province/liaoning.js",json:"./mapjson/liaoning.json",load:!1},{name:"吉林",src:"http://echarts.baidu.com/asset/map/js/province/jilin.js",json:"./mapjson/jilin.json",load:!1},{name:"黑龙江",src:"http://echarts.baidu.com/asset/map/js/province/heilongjiang.js",json:"./mapjson/heilongjiang.json",load:!1},{name:"江苏",src:"http://echarts.baidu.com/asset/map/js/province/jiangsu.js",json:"./mapjson/jiangsu.json",load:!1},{name:"浙江",src:"http://echarts.baidu.com/asset/map/js/province/zhejiang.js",json:"./mapjson/zhejiang.json",load:!1},{name:"安徽",src:"http://echarts.baidu.com/asset/map/js/province/anhui.js",json:"./mapjson/anhui.json",load:!1},{name:"福建",src:"http://echarts.baidu.com/asset/map/js/province/fujian.js",json:"./mapjson/fujian.json",load:!1},{name:"江西",src:"http://echarts.baidu.com/asset/map/js/province/jiangxi.js",json:"./mapjson/jiangxi.json",load:!1},{name:"山东",src:"http://echarts.baidu.com/asset/map/js/province/shandong.js",json:"./mapjson/shandong.json",load:!1},{name:"河南",src:"http://echarts.baidu.com/asset/map/js/province/henan.js",json:"./mapjson/henan.json",load:!1},{name:"湖北",src:"http://echarts.baidu.com/asset/map/js/province/hubei.js",json:"./mapjson/hubei.json",load:!1},{name:"湖南",src:"http://echarts.baidu.com/asset/map/js/province/hunan.js",json:"./mapjson/hunan.json",load:!1},{name:"广东",src:"http://echarts.baidu.com/asset/map/js/province/guangdong.js",json:"./mapjson/guangdong.json",load:!1},{name:"广西",src:"http://echarts.baidu.com/asset/map/js/province/guangxi.js",json:"./mapjson/guangxi.json",load:!1},{name:"海南",src:"http://echarts.baidu.com/asset/map/js/province/hainan.js",json:"./mapjson/hainan.json",load:!1},{name:"四川",src:"http://echarts.baidu.com/asset/map/js/province/sichuan.js",json:"./mapjson/sichuan.json",load:!1},{name:"贵州",src:"http://echarts.baidu.com/asset/map/js/province/guizhou.js",json:"./mapjson/guzhou.json",load:!1},{name:"云南",src:"http://echarts.baidu.com/asset/map/js/province/yunnan.js",json:"./mapjson/yunnan.json",load:!1},{name:"西藏",src:"http://echarts.baidu.com/asset/map/js/province/xizang.js",json:"./mapjson/xizang.json",load:!1},{name:"陕西",src:"http://echarts.baidu.com/asset/map/js/province/shanxi1.js",json:"./mapjson/shanxi1.json",load:!1},{name:"甘肃",src:"http://echarts.baidu.com/asset/map/js/province/gansu.js",json:"./mapjson/gansu.json",load:!1},{name:"青海",src:"http://echarts.baidu.com/asset/map/js/province/qinghai.js",json:"./mapjson/qinghai.json",load:!1},{name:"宁夏",src:"http://echarts.baidu.com/asset/map/js/province/ningxia.js",json:"./mapjson/ningxia.json",load:!1},{name:"新疆",src:"http://echarts.baidu.com/asset/map/js/province/xinjiang.js",json:"./mapjson/xinjiang.json",load:!1},{name:"北京",src:"http://echarts.baidu.com/asset/map/js/province/beijing.js",json:"./mapjson/beijing.json",load:!1},{name:"天津",src:"http://echarts.baidu.com/asset/map/js/province/tianjin.js",json:"./mapjson/tianjin.json",load:!1},{name:"上海",src:"http://echarts.baidu.com/asset/map/js/province/shanghai.js",json:"./mapjson/shanghai.json",load:!1},{name:"重庆",src:"http://echarts.baidu.com/asset/map/js/province/chongqing.js",json:"./mapjson/chongqing.json",load:!1},{name:"香港",src:"http://echarts.baidu.com/asset/map/js/province/xianggang.js",json:"./mapjson/xianggang.json",load:!1},{name:"澳门",src:"http://echarts.baidu.com/asset/map/js/province/aomen.js",json:"./mapjson/aomen.json",load:!1},{name:"台湾",src:"http://echarts.baidu.com/asset/map/js/province/taiwan.js",json:"./mapjson/taiwan.json",load:!1}],u=!1;o.prototype.echartsMap=p,o.prototype.showLoading=function(n){n=n||"正在处理，请稍候..",this.$container.find(".status").text(n),this.$container.find(".mask").css("display","flex")},o.prototype.hideLoading=function(){this.$container.find(".mask").fadeOut(100)},o.prototype.getEchartsMaps=function(){if(u||p[0].load)return new Promise(function(n,a){n()});console.log("正在加载地图数据JSON.."),this.showLoading("正在加载地图数据JSON..");var a=[];return a.push(function(a){return new Promise(function(t,e){n.get(a.json,function(n){echarts.registerMap(a.name,n),t()})})}(p[0])),new Promise(function(n,t){Promise.all(a).then(function(){p[0].load=!0,n()})})},o.prototype.loadEchartsMaps=function(){function n(n){return new Promise(function(a,t){var e=document.createElement("script");e.type="text/javascript",e.src=n.src,document.body.appendChild(e),e.onload=function(){a()}})}if(u)return new Promise(function(n,a){n()});console.log("正在加载地图数据JS.."),this.showLoading("正在加载地图数据JS..");var a=[];return p.forEach(function(t){if(t.src){var e=n(t);a.push(e)}}),new Promise(function(n,t){Promise.all(a).then(function(){u=!0,n()})})},o.prototype.getDatas=function(a,t){var e=this;return console.log("正在请求数据.."),this.showLoading("正在统计数据,请稍候.."),new Promise(function(s,o){setTimeout(function(){n.ajax({url:a,type:"POST",dataType:"text",contentType:"application/x-www-form-urlencoded; charset=UTF-8",timeout:15e3,data:t,error:function(n,a,t){console.log("获取数据失败，请稍后重试！"+n.status+"|"+n.statusText),o("获取数据失败，请稍后重试！"+n.status+"|"+n.statusText)},success:function(n){console.log(n);var i=JSON.parse(n);"200"==i.code?(e.originalDatas=i,e.datasQuote&&"function"==typeof e.datasQuote&&e.datasQuote(),e.api=a,e.params=t,s()):o("getDatas is error!"+n)}})},100)})},o.prototype.createTable=function(){console.log("正在生成表格.."),this.showLoading("正在生成表格..");var n=this;return new Promise(function(t,e){var s=[];s=n.tableDatas?n.tableDatas:n.originalDatas.info;for(var o="",i=0;i<s.length;i++){var r=s[i],c="";n.tableStruct.datas&&n.tableStruct.datas.forEach(function(n){c+=" data-"+n+"='"+r[n]+"'"}),o+="<tr "+c+"><td>"+(i+1)+"</td>";for(var p=0;p<n.tableStruct.columns.length;p++)(h=n.tableStruct.columns[p]).formatMoney?o+="<td data-col='"+p+"'>"+a(r[h.name],2)+"</td>":o+="<td data-col='"+p+"'>"+r[h.name]+"</td>";o+="</tr>"}o="<tbody>"+o+"</tbody>";for(var u="<thead><tr><th width='50px'>序号</th>",d=0;d<n.tableStruct.columns.length;d++){var h=n.tableStruct.columns[d];u+="<th width='"+h.width+"'>"+h.cname+"</th>"}var m="<table class='body-table' cellpadding='0' cellspacing='0'>"+(u+="</tr></thead>")+o+"</table>",j="<table class='body-table' cellpadding='0' cellspacing='0'>"+u+"</table>";n.$container.find(".datas .bt").empty().html(m),n.$container.find(".datas .ht").empty().html(j),setTimeout(t,200)})},o.prototype.createChart=function(){return this.showLoading("未定义图表生成函数，无法继续！"),new Promise(function(n,a){a("未定义图表生成函数，无法继续！")})},o.prototype.bindEvents=function(){console.log("正在绑定事件.."),this.showLoading("正在绑定事件..");a=this;this.$container.find(".datas .title").on("click",function(){var t=n(this).parent();if(t.hasClass("open"))t.removeClass("open"),t.find(".table_wrap").hide(0),n(this).find("span").text("展 开");else{if(0==t.find(".table_wrap .bt>table").length)return a.showLoading("对不起，此模块只有图表无数据！"),void setTimeout(a.hideLoading.bind(a),1500);t.addClass("open"),t.find(".table_wrap").show(0),n(this).find("span").text("收 缩")}}),this.$container.find(".datas .bt").off().on("scroll",function(n,a,t){var e;return function(){var s=this,o=arguments,i=t&&!e;clearTimeout(e),e=setTimeout(function(){e=null,t||n.apply(s,o)},a),i&&n.apply(s,o)}}(function(){var a=n(this).scrollLeft();n(this).prev().css("transform","translate(-"+a+"px,0)")},100,!1));var a=this;return this.$container.find(".tools").on("click","i",function(){switch(n(this).data("btn")){case"delete":confirm("确认移除此面板??")&&(a.$container.remove(),delete echartConfigs[a.chartID],a.menu.removeClass("add"),s(a.chartID));break;case"refresh":a.showLoading("正在刷新.."),a.$container.find(".table_wrap .ht").empty(),a.$container.find(".table_wrap .bt").empty(),delete a.originalDatas,delete a.chartDatas,delete a.tableDatas;for(var t in a.echarts)a.echarts[t].dispose(),delete a.echarts[t];a.getDatas(a.api,a.params).then(function(){return a.createTable()}).then(function(){return a.createChart()}).then(function(){console.log("刷新完成！"),a.showLoading("刷新完成！"),setTimeout(a.hideLoading.bind(a),200)})}}),new Promise(function(n,a){setTimeout(n,200)})},o.prototype.extendBind=function(){if(!this.eventsBind){var n=this.extendEvents||{};for(var a in n)for(var t in n[a][0])this.$container.on(t,a,n[a][0][t][0]);this.eventsBind=!0}},o.prototype.init=function(a,t){var e=this;return new Promise(function(s,o){e.menu=userMenus.find("li[data-id='"+e.chartID+"']"),e.menu.data("isProcess","true"),e.getDatas(a,t).then(function(){return e.createTable()},function(n){return e.showLoading(n),setTimeout(function(){c(e)},1500),new Promise(function(n,a){a()})}).then(function(){return e.createChart()}).then(function(){return e.bindEvents()}).then(function(){e.extendBind(),e.menu.addClass("add").data("isProcess","false"),console.log("全部完成！"),e.showLoading("全部完成！"),s(),setTimeout(e.hideLoading.bind(e),200),e.currAutoSequ<e.autoSequence.length-1?(r(e.currAutoSequ+1),n("#currentModule").text(e.currAutoSequ+1)):n(".loading_mask").fadeOut(200)})})},o.prototype.autoSequence=[],o.prototype.currAutoSequ=0,"function"==typeof define&&"object"==typeof define.amd&&define.amd?define(function(){return o}):"undefined"!=typeof module&&module.exports?module.exports.MobileChart=o:window.MobileChart=o}(jQuery);