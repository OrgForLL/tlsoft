$(function(){function e(){var e=$("#chartPanels");e.hasClass("page-bot")?(e.removeClass("page-bot"),$("#moreapps").hasClass("page-bot")||t()):(e.find(".panel_mask").hide(0),e.addClass("page-bot"))}function t(){var t=$("#moreapps");t.hasClass("page-bot")?(t.removeClass("page-bot"),$("#chartPanels").hasClass("page-bot")||e()):(t.find(".more_mask").hide(0),t.addClass("page-bot"))}function a(e,t){2==arguments.length?(e.find(".status").text(t),e.find(".mask").css("display","flex")):($(".global_mask").find(".status").text(e),$(".global_mask").css("display","flex"))}function n(e){e?e.find(".mask").fadeOut(200):$(".global_mask").fadeOut(200)}function o(){$("#chartPanels").on("webkitTransitionEnd",function(){$(this).hasClass("page-bot")||$(this).find(".panel_mask").show(0)}),$("#moreapps").on("webkitTransitionEnd",function(){$(this).hasClass("page-bot")||$(this).find(".more_mask").show(0)}),$("#chartPanels").on("click",".panel_mask",e),$("#chartPanels").on("click",".icon-guanbi",e),$("#moreapps").on("click",".more_top",t),$("#chartPanels").on("click",".chartlist li",function(){$(this).data("id")?s($(this)):(a("尚未配置！"),setTimeout(n,1500))}),$(".footer").on("click",".btn",function(){$(this).hasClass("btn_add")?e():$(this).hasClass("btn_more")&&t()}),$("#moreapps").on("click",".app_item",function(){var e=$(this).data("url");llApp.isInApp?llApp.openWebView(e):window.location.href=e})}function s(t){if("true"==t.data("isProcess"))return a("该模块正在加载中.."),void setTimeout(n,800);if(!t.hasClass("add")){var o={action:"saveMenuSelect",parameter:[t.attr("data-id")],token:u};$.ajax({url:"http://tm.lilanz.com/qywx/project/StoreSaler/mentalMenuCore.ashx",type:"POST",dataType:"text",contentType:"application/x-www-form-urlencoded; charset=UTF-8",timeout:15e3,data:JSON.stringify(o),error:function(e,t,a){},success:function(o){console.log(o);var s=JSON.parse(o);200==s.code?(e(),c.append(template(t.data("tpl"),{}))):(a("Save User Process Fail.."+s.message),setTimeout(n,1e3))}})}}function i(e){var t=e||0;MobileChart.prototype.currAutoSequ=t;var o=MobileChart.prototype.autoSequence.eq(t);if("true"==o.data("isProcess"))return a("该模块正在加载中.."),void setTimeout(n,800);o.hasClass("add")||c.append(template(o.data("tpl"),{}))}function r(){if(""!=u){a("正在检查权限..");var e={action:"getMenuAuth",parameter:[],token:u};$.ajax({url:"http://tm.lilanz.com/qywx/project/StoreSaler/mentalMenuCore.ashx",type:"POST",dataType:"text",contentType:"application/x-www-form-urlencoded; charset=UTF-8",timeout:15e3,data:JSON.stringify(e),error:function(e,t,a){},success:function(e){console.log(e);var t=JSON.parse(e);if(200==t.code){for(var a="",o=0;o<t.data.length;o++)a+=template("tpl_chartListItem",t.data[o]);if(""!=a){$(".panel_wrap .chartlist").empty().html(a),$(".panel_wrap .chartlist").show(),$(".panel_wrap .no-result").hide();var s=$(".chartlist li[data-selected='1']");s.length>0&&(MobileChart.prototype.autoSequence=s,i(0),p.find("#currentModule").text(1),p.find("#totalModules").text(s.length))}}else console.log("加载用户菜单出错:"+t.message);n()}})}}function l(){a("加载用户菜单..");var e={action:"AppBBMenus",Parameter:[],token:u};$.ajax({url:"http://tm.lilanz.com/qywx/api/action.ashx",type:"POST",dataType:"text",contentType:"application/x-www-form-urlencoded; charset=UTF-8",timeout:5e3,data:JSON.stringify(e),error:function(e,t,a){},success:function(e){var t=JSON.parse(e);if("200"==t.Status){var a="";t.Menulist.forEach(function(e){a+=template("tpl_appgridItem",e)}),$("#moreapps .app_grid").empty().html(a)}n()}})}particlesJS("particles-js",{particles:{number:{value:6,density:{enable:!0,value_area:240}},color:{value:"#ecedee"},shape:{type:"circle",stroke:{width:0,color:"#000000"},polygon:{nb_sides:5},image:{src:"img/github.svg",width:100,height:100}},opacity:{value:1,random:!1,anim:{enable:!1,speed:20,opacity_min:.1,sync:!1}},size:{value:22,random:!0,anim:{enable:!0,speed:2,size_min:.1,sync:!1}},line_linked:{enable:!0,distance:200,color:"#ddd",opacity:1,width:1},move:{enable:!0,speed:4,direction:"none",random:!0,straight:!1,out_mode:"out",bounce:!1,attract:{enable:!1,rotateX:600,rotateY:1200}}},interactivity:{detect_on:"canvas",events:{onhover:{enable:!0,mode:"grab"},onclick:{enable:!0,mode:"push"},resize:!0},modes:{grab:{distance:140,line_linked:{opacity:1}},bubble:{distance:400,size:40,duration:2,opacity:8,speed:3},repulse:{distance:200,duration:.4},push:{particles_nb:4},remove:{particles_nb:2}}},retina_detect:!0}),Date.prototype.format=function(e){var t={"M+":this.getMonth()+1,"d+":this.getDate(),"h+":this.getHours(),"m+":this.getMinutes(),"s+":this.getSeconds(),"q+":Math.floor((this.getMonth()+3)/3),S:this.getMilliseconds()};/(y+)/.test(e)&&(e=e.replace(RegExp.$1,(this.getFullYear()+"").substr(4-RegExp.$1.length)));for(var a in t)new RegExp("("+a+")").test(e)&&(e=e.replace(RegExp.$1,1==RegExp.$1.length?t[a]:("00"+t[a]).substr((""+t[a]).length)));return e};var c=$("#app"),p=$(".loading_mask"),d={},u=function(e){var t=new RegExp("(^|&)"+e+"=([^&]*)(&|$)","i"),a=window.location.search.substr(1).match(t);return null!=a?unescape(a[2]):""}("apptoken");MobileChart.prototype.api="http://tm.lilanz.com/qywx/project/storesaler/salesChartCore.ashx",window.gShowLoading=a,window.gHideLoading=n,FastClick.attach(document.body),o(),window.echartConfigs=d,window.userMenus=$(".panel_wrap .chartlist"),r(),l(),llApp.init().then(function(e){})});