var gCompanyCode="";var gCompanyName="";var gCompanyUrl="";var gKuaidiNumber="";var gValiCode="";var gHasVali="";var gCheckStr="";var gCheckInfo="";var gTimeout=30000;var gAjaxGet;var gQueryResult;var gIsCheck;var gIsRss=0;var gRssId=0;var gQueryId=0;var queryurl="";var isavailable=0;var gLoading=0;var gResultJson;var gResultData;var gSortStatus=0;$(function(){var a=$("#postid");a.focus(function(){var b=$("#postid");if(b.val()==b.attr("placeholder")){b.val("").css("color","#333")}$("#postid").select()}).blur(function(){var b=$("#postid");if(b.val()==b.attr("placeholder")){b.val("").css("color","#333")}}).focus();a.keydown(function(c){$("#errorTips").hide();var b=c.keyCode?c.keyCode:c.which;if(b==13){query()}});$("#valicode").keydown(function(c){$("#errorTips").hide();var b=c.keyCode?c.keyCode:c.which;if(b==13){query()}})});function selectCompanyByCode(j){gCompanyCode=j;var h=jsoncom.company;for(var e=0;e<h.length;e++){if(gCompanyCode==h[e].code){gCompanyName=h[e].companyname;var d=h[e].tel;var c=h[e].hasvali;var a=h[e].url;var g=h[e].isavailable;var b=h[e].promptinfo;var f=h[e].comurl;gCheckStr=h[e].freg;gCheckInfo=h[e].freginfo;gCompanyUrl=f;queryurl=h[e].queryurl;isavailable=h[e].isavailable;if(queryurl!=""&&isavailable==1){c=0}if(g!=null&&g=="1"&&queryurl==""){if(b!=null&&b!=""){$("#errorTips").show();b=b.replace("官网试试","<a href='"+f+"' target='_blank'>官网试试</a>");$("#errorMessage").html(b)}else{$("#errorMessage").html(gCompanyName+"网站不稳定，请稍后尝试查询.")}$("#errorTips").show()}else{$("#errorTips").hide()}if(c=="1"){gHasVali=c;$("#valideBox").show();$("#telBox").hide();refreshCode()}else{if(c=="2"){gHasVali=c;$("#valideBox").hide();$("#telBox").hide()}else{gHasVali=c;$("#valideBox").hide();$("#telBox").hide()}}$("#selectComBtn").html(gCompanyName);$("#selectComBtn").parent().css("background",'url("//cdn.kuaidi100.com/images/all/16/'+gCompanyCode+'.png") 0 3px no-repeat');$("#companyTel").html("电话："+d).show();$("#companyUrl").attr("href",f).show();$("#notfindComapnyUrl").attr("href",f);$("#notFindRight2").hide();$("#notFindRight1").show();break}}}function queryFromUrl(){gIsCheck=0;$("#sendHistory").hide();$("#selectCom").show();$("#notFindTip").show();$("#notFindRight").hide();$("#notFindUpdate").show();$(".span-shortname").text(gCompanyName);$("#notfindUpdateUrl").attr("href",queryurl+gKuaidiNumber);kdHistory.add(gCompanyCode,gKuaidiNumber,0)}function getResult(companyCode,kuaidiNumber){var url="/query";if(gHasVali=="1"||gHasVali=="2"){url="/queryvalid"}gCompanyCode=companyCode;gKuaidiNumber=kuaidiNumber;if(queryurl!=""&&isavailable==1){queryFromUrl();return false}var agrs="type="+gCompanyCode+"&postid="+gKuaidiNumber+"&id="+gQueryType+"&valicode="+gValiCode+"&temp="+Math.random();url=url+"?"+agrs;$("#queryWait").show();$("#selectCom").hide();$("#comList").hide();gLoading=1;gAjaxGet=$.ajax({type:"GET",url:url,timeout:gTimeout,success:function(responseText){gLoading=0;$("#queryWait").hide();$("#sendHistory").hide();$("#selectCom").show();gIsCheck=0;if(responseText.length==0){$("#notFindTip").show();return}var resultJson=eval("("+responseText+")");gResultJson=resultJson;gQueryResult=resultJson.status;if(resultJson.status==200){var resultData=resultJson.data;gResultData=resultData;gIsCheck=resultJson.ischeck;var resultTable2=$("#queryResult2");resultTable2.empty();for(var i=resultData.length-1;i>=0;i--){var className="";if(resultData.length==1&&gIsCheck==0){className="status status-wait"}else{if(resultData.length==1&&gIsCheck==1){className="status status-check"}else{if(i==0&&gIsCheck==0){className="status status-wait"}else{if(i==0&&gIsCheck==1){className="status status-check"}else{if(i==resultData.length-1){className="status status-first"}else{className="status"}}}}}var context=resultData[i].context;context=getJumpNetContext(context,gCompanyCode,"fonter1");context=getTelContext(context);if(i==0){resultTable2.append('<tr class="last"><td class="row1">'+resultData[i].ftime+'</td><td class="'+className+'">&nbsp;</td><td>'+context+"</td></tr>")}else{resultTable2.append('<tr><td class="row1">'+resultData[i].ftime+'</td><td class="'+className+'">&nbsp;</td><td>'+context+"</td></tr>")}}$("#adDiv").show();$("#queryContext").show();$("#queryQr").show();$("#queryPs").show();getTimecost();getQueryQr()}else{if(resultJson.status==408){$("#errorTips").show();if(gQueryType==2){$("#errorMessage").html("需要验证码，请到快递查询页面输入验证码查询！")}else{$("#errorMessage").html("您输入的验证码错误，请重新输入！")}if($("#valideBox").is(":visible")){$("#valicode").focus()}}else{if(resultJson.status==201){$("#notFindTip").show()}else{if(resultJson.status==700){queryFromUrl()}else{$("#notFindTip").show()}}}}if(gHasVali=="1"){refreshCode()}kdHistory.add(gCompanyCode,gKuaidiNumber,gIsCheck);countHis()},error:function(xmlHttpRequest,error){gLoading=0;if(error=="timeout"){onTimeout()}}})}function countHis(){setTopCookieTips()}function getTimecost(){if(gAjaxGet){gAjaxGet.abort()}gAjaxGet=$.ajax({type:"post",url:"/mapinfo",data:"queryResult="+encodeURIComponent(Obj2str(gResultJson))+"&toAddr=&toAddrCode=&nu="+gKuaidiNumber+"&com="+gCompanyCode,dataType:"json",contentType:"application/x-www-form-urlencoded; charset=utf-8",success:function(a){if(a!=""){var c=a.usedTime;var b=a.arrTime;if(c==""){$("#timeCost").hide()}else{$("#timeCost").text(time2str(c)).show()}if(b==""){$("#arrTime").hide()}else{$("#arrTime").text(b).show()}}else{$("#timeCost").hide();$("#arrTime").hide()}$("#cityId_input").val("");$("#cityName_input").text("")}})}function getQueryQr(){$("#queryQrImg").attr("src","/twoCode.do?code=kuaidi100://ilovegirl%3Faction=detail%26num="+gKuaidiNumber+"%26com="+gCompanyCode+"%26from=index&w=100&h=100");$("#queryQrNum").text(gKuaidiNumber)}function sortToggle(){if(gSortStatus==1){sortup();gSortStatus=0}else{sortdown();gSortStatus=1}}function sortup(){var b=$("#queryResult");var a=gResultData;b.empty();b.append('<tr><th class="width-01" onclick="sortToggle()"><span class="b-btn"><b class="b-up b-up-active"></b><b class="b-down"></b></span>时间</th><th class="width-02">地点和跟踪进度</th></tr>');for(var c=0;c<a.length;c++){if(c==0){b.append('<tr class="row1"><td>'+a[c].time+"</td><td>"+a[c].context+"<span class='lastTag'></span></td></tr>")}else{b.append('<tr><td class="row">'+a[c].time+"</td><td>"+a[c].context+"</td></tr>")}}b.show()}function sortdown(){var b=$("#queryResult");var a=gResultData;b.empty();b.append('<tr><th class="width-01" onclick="sortToggle()"><span class="b-btn"><b class="b-up"></b><b class="b-down b-down-active"></b></span>时间</th><th class="width-02">地点和跟踪进度</th></tr>');for(var c=a.length-1;c>=0;c--){if(c==0){b.append('<tr class="row1"><td>'+a[c].time+"</td><td>"+a[c].context+"<span class='lastTag'></span></td></tr>")}else{b.append('<tr><td class="row">'+a[c].time+"</td><td>"+a[c].context+"</td></tr>")}}b.show()}function hideTips(){$("#inputTips").hide();$("#friendTip").hide();$("#queryWait").hide();$("#errorTips").hide();$("#adDiv").hide();$("#queryContext").hide();$("#queryQr").hide();$("#queryPs").hide();$("#notFindTip").hide();$("#notFindRight1").hide();$("#notFindRight2").show();$("#notFindRight").show();$("#notFindUpdate").hide();$("#companyTel").hide();$("#companyUrl").hide();$("#timeCost").hide();$("#arrTime").hide();if(gAjaxGet){gAjaxGet.abort()}}function validateKuaidiNumber(){if($("#queryWait").is(":visible")){return false}gKuaidiNumber=$("#postid").val().Trim();if(gCompanyCode=="rufengda"&&checkRegOfcompany(gKuaidiNumber,"^\\d{16}$")){gKuaidiNumber="DD"+gKuaidiNumber}$("#postid").val(gKuaidiNumber);gValiCode=$("#valicode").val().Trim();var a="";if($("#companyListType").val()!=null&&$("#companyListType").val()=="wuliuCompanyList"){a="物流"}else{a="快递"}if(gCompanyCode==""){$("#errorTips").show();if(gQueryType==13||gQueryType==14){$("#errorMessage").html("请您在上方选择一家"+a+"公司")}else{$("#errorMessage").html("请您在左侧列表中选择一家"+a+"公司")}return false}if(gKuaidiNumber==""||gKuaidiNumber==$("#postid").attr("placeholder")){$("#errorTips").show();$("#errorMessage").html("请您填写"+a+"单号。");$("#postid").focus();return false}if(!isNumberLetterFuhao(gKuaidiNumber)){$("#errorTips").show();$("#errorMessage").html("单号仅能由数字、字母和特殊符号组合，请您查证。");$("#postid").focus();return false}if(gKuaidiNumber.length<5){$("#errorTips").show();$("#errorMessage").html("单号不能小于5个字符，请您查证。");$("#postid").focus();return false}if(gKuaidiNumber.length>30){$("#errorTips").show();$("#errorMessage").html("单号不能超过30个字符，请您查证。");$("#postid").focus();return false}if((gKuaidiNumber.slice(0,2)).toLowerCase()=="lp"){$("#errorTips").show();$("#errorMessage").html("以[LP]开头的是淘宝内部单号，用运单号码才可查询。");$("#postid").focus();return false}if(gCheckStr!=""&&gCheckStr!=null){if(!checkRegOfcompany(gKuaidiNumber,gCheckStr)){$("#errorTips").show();$("#errorMessage").html(gCheckInfo);$("#postid").focus();return false}}if(gHasVali=="1"&&gValiCode==""){$("#errorTips").show();$("#errorMessage").html("请您填写验证码。");$("#valicode").focus();return false}if(gHasVali=="1"&&!isNumberLetterFuhao(gValiCode)){$("#errorTips").show();$("#errorMessage").html("验证码仅能由数字、字母和特殊符号组合，请您查证。");$("#valicode").focus();return false}return true}function refreshCode(){$("#valicode").val("");$("#valiimages").attr("src","//cdn.kuaidi100.com/images/clear.gif");$("#valiimages").width(1);$("#valiimages").height(1);var a="/images?type="+gCompanyCode+"&temp="+Math.random();$("#valiimages").attr("src",a);$("#valiimages").width(100);$("#valiimages").height(34);$("#valicode").focus()}function getTelContext(a){var b=new RegExp("1\\d{10}","gi");return a.replace(b,function(c){var d="";$.ajax({type:"post",url:"/courier/searchapi.do",data:"method=courierinfobyphone&json={%22phone%22:%22"+c+"%22}",dataType:"json",async:false,success:function(e){if(e.status==200){d='<a target="_blank" href="/courier/detail_'+e.guid+'.html">'+c+"</a>"}else{d=c}}});return d})}function getJumpNetContext(e,c,a){var d="(?:(?!的|员|型|是).|^)";var b=".?到达.?|.?问题.?|.?派件.?|.?签收.?|.?疑难.?|.?扫描.?|.?装袋.?|.?装包.?|.?妥投.?|.?操作员.?|.?审核.?|.?备注.?|.?客服.?|.?网点经理.?|.?员工.?|.?门卫.?|.?本人.?|.?草签.?|.?图片.?|.?分拨中心.?";var h={shentong:"5",huitongkuaidi:"6",huiqiangkuaidi:"27",tiantian:"7",zhaijisong:"12",quanfengkuaidi:"23",longbanwuliu:"24",guotongkuaidi:"20",kuaijiesudi:"18",debangwuliu:"1",zhongtong:"3",yunda:"2"};switch(c){case ("shentong"):case ("huitongkuaidi"):case ("huiqiangkuaidi"):case ("tiantian"):case ("quanfengkuaidi"):case ("longbanwuliu"):case ("guotongkuaidi"):case ("kuaijiesudi"):var g=d+"【((?:(?!"+b+")[^\\s\\d【]){2,})】";var f=new RegExp(g,"gi");e=e.replace(f,function(j,i,k){return'【<a href="//www.kuaidi100.com/network.jsp?from='+a+"&searchText="+encodeURIComponent(i)+"&company="+h[c]+'" target="_blank">'+i+"</a>】"});break;case ("debangwuliu"):case ("zhaijisong"):case ("zhongtong"):var g=d+"\\[((?:(?!"+b+")[^\\s\\d【]){2,})\\]";var f=new RegExp(g,"gi");e=e.replace(f,function(j,i,k){return'[<a href="//www.kuaidi100.com/network.jsp?from='+a+"&searchText="+encodeURIComponent(i)+"&company="+h[c]+'" target="_blank">'+i+"</a>]"});break;case ("yunda"):var g="((?:(?!"+b+")\\S){2,}):";var f=new RegExp(g,"gi");e=e.replace(f,function(j,i,k){return'<a href="//www.kuaidi100.com/network.jsp?from='+a+"&searchText="+encodeURIComponent(i)+"&company="+h[c]+'" target="_blank">'+i+"</a>:"});break}return e}function isNumberOrLetter(c){var a="^[0-9a-zA-Z]+$";var b=new RegExp(a);if(b.test(c)){return true}else{return false}}function isNumberLetterFuhao(c){var a="^[0-9a-zA-Z@#$-]+$";var b=new RegExp(a);if(b.test(c)){return true}else{return false}}function checkRegOfcompany(c,a){c=c.toUpperCase();var b=new RegExp(a);if(b.test(c)){return true}else{return false}}function onTimeout(){if($("#queryWait").is(":visible")){$("#queryWait").hide();$("#errorTips").show();$("#errorMessage").html("查询时间过长，请您稍后查询。")}}function gotofeedback(){window.open("/help/feedback.shtml?mscomcode="+gCompanyCode+"&mscomnu="+gKuaidiNumber+"&msrandommath="+Math.random())}function time2str(c){var e="";e="已耗时";if(c!=0){c=c/1000;var b=parseInt(c/86400);var a=parseInt(c%86400/3600);var d=parseInt(c%86400%3600/60);if(b!=0){e+=b+"天"}if(a!=0||b!=0){e+=a+"小时"}}return e}function Obj2str(c){if(c==undefined){return'""'}var b=[];if(typeof c=="string"){return'"'+c.replace(/([\"\\])/g,"\\$1").replace(/(\n)/g,"\\n").replace(/(\r)/g,"\\r").replace(/(\t)/g,"\\t")+'"'}if(typeof c=="object"){if(!c.sort){for(var a in c){b.push('"'+a+'":'+Obj2str(c[a]))}if(!!document.all&&!/^\n?function\s*toString\(\)\s*\{\n?\s*\[native code\]\n?\s*\}\n?\s*$/.test(c.toString)){b.push("toString:"+c.toString.toString())}b="{"+b.join()+"}"}else{for(var a=0;a<c.length;a++){b.push(Obj2str(c[a]))}b="["+b.join()+"]"}return b}return c.toString().replace(/\"\:/g,'":""')}String.prototype.isTel=function(){return(/^([0-9]{3,4}\-[0-9]{3,8}$)|(^[0-9]{3,8}$)|(^\([0-9]{3,4}\)[0-9]{3,8}$)|(^[0-9]{3,12}$)|(^((\(\d{3}\))|(\d{3}\-))?1[3578]\d{9})$/.test(this.Trim()))};String.prototype.isMobile=function(){return(/^(?:13\d|14\d|15\d|18\d)-?\d{5}(\d{3}|\*{3})$/.test(this.Trim()))};String.prototype.Trim=function(){return this.replace(/\s/g,"")};var ZeroClipboard={version:"1.0.7",clients:{},moviePath:"ZeroClipboard.swf",nextId:1,$:function(a){if(typeof(a)=="string"){a=document.getElementById(a)}if(!a.addClass){a.hide=function(){this.style.display="none"};a.show=function(){this.style.display=""};a.addClass=function(b){this.removeClass(b);this.className+=" "+b};a.removeClass=function(d){var e=this.className.split(/\s+/);var b=-1;for(var c=0;c<e.length;c++){if(e[c]==d){b=c;c=e.length}}if(b>-1){e.splice(b,1);this.className=e.join(" ")}return this};a.hasClass=function(b){return !!this.className.match(new RegExp("\\s*"+b+"\\s*"))}}return a},setMoviePath:function(a){this.moviePath=a},dispatch:function(d,b,c){var a=this.clients[d];if(a){a.receiveEvent(b,c)}},register:function(b,a){this.clients[b]=a},getDOMObjectPosition:function(c,a){var b={left:0,top:0,width:c.width?c.width:c.offsetWidth,height:c.height?c.height:c.offsetHeight};while(c&&(c!=a)){b.left+=c.offsetLeft;b.top+=c.offsetTop;c=c.offsetParent}return b},Client:function(a){this.handlers={};this.id=ZeroClipboard.nextId++;this.movieId="ZeroClipboardMovie_"+this.id;ZeroClipboard.register(this.id,this);if(a){this.glue(a)}}};ZeroClipboard.Client.prototype={id:0,ready:false,movie:null,clipText:"",handCursorEnabled:true,cssEffects:true,handlers:null,glue:function(d,b,e){this.domElement=ZeroClipboard.$(d);var f=99;if(this.domElement.style.zIndex){f=parseInt(this.domElement.style.zIndex,10)+1}if(typeof(b)=="string"){b=ZeroClipboard.$(b)}else{if(typeof(b)=="undefined"){b=document.getElementsByTagName("body")[0]}}var c=ZeroClipboard.getDOMObjectPosition(this.domElement,b);this.div=document.createElement("div");var a=this.div.style;a.position="absolute";a.left=""+c.left+"px";a.top=""+c.top+"px";a.width=""+c.width+"px";a.height=""+c.height+"px";a.zIndex=f;if(typeof(e)=="object"){for(addedStyle in e){a[addedStyle]=e[addedStyle]}}b.appendChild(this.div);this.div.innerHTML=this.getHTML(c.width,c.height)},getHTML:function(d,a){var c="";var b="id="+this.id+"&width="+d+"&height="+a;if(navigator.userAgent.match(/MSIE/)){var e=location.href.match(/^https/i)?"https://":"http://";c+='<object classid="clsid:d27cdb6e-ae6d-11cf-96b8-444553540000" codebase="'+e+'download.macromedia.com/pub/shockwave/cabs/flash/swflash.cab#version=9,0,0,0" width="'+d+'" height="'+a+'" id="'+this.movieId+'" align="middle"><param name="allowScriptAccess" value="always" /><param name="allowFullScreen" value="false" /><param name="movie" value="'+ZeroClipboard.moviePath+'" /><param name="loop" value="false" /><param name="menu" value="false" /><param name="quality" value="best" /><param name="bgcolor" value="#ffffff" /><param name="flashvars" value="'+b+'"/><param name="wmode" value="transparent"/></object>'}else{c+='<embed id="'+this.movieId+'" src="'+ZeroClipboard.moviePath+'" loop="false" menu="false" quality="best" bgcolor="#ffffff" width="'+d+'" height="'+a+'" name="'+this.movieId+'" align="middle" allowScriptAccess="always" allowFullScreen="false" type="application/x-shockwave-flash" pluginspage="http://www.macromedia.com/go/getflashplayer" flashvars="'+b+'" wmode="transparent" />'}return c},hide:function(){if(this.div){this.div.style.left="-2000px"}},show:function(){this.reposition()},destroy:function(){if(this.domElement&&this.div){this.hide();this.div.innerHTML="";var a=document.getElementsByTagName("body")[0];try{a.removeChild(this.div)}catch(b){}this.domElement=null;this.div=null}},reposition:function(d,b){if(d){this.domElement=ZeroClipboard.$(d);if(!this.domElement){this.hide()}}if(typeof(b)=="string"){b=ZeroClipboard.$(b)}else{if(typeof(b)=="undefined"){b=document.getElementsByTagName("body")[0]}}if(this.domElement&&this.div){var c=ZeroClipboard.getDOMObjectPosition(this.domElement,b);var a=this.div.style;a.left=""+c.left+"px";a.top=""+c.top+"px"}},setText:function(a){this.clipText=a;if(this.ready){this.movie.setText(a)}},addEventListener:function(a,b){a=a.toString().toLowerCase().replace(/^on/,"");if(!this.handlers[a]){this.handlers[a]=[]}this.handlers[a].push(b)},setHandCursor:function(a){this.handCursorEnabled=a;if(this.ready){this.movie.setHandCursor(a)}},setCSSEffects:function(a){this.cssEffects=!!a},receiveEvent:function(d,e){d=d.toString().toLowerCase().replace(/^on/,"");switch(d){case"load":this.movie=document.getElementById(this.movieId);if(!this.movie){var c=this;setTimeout(function(){c.receiveEvent("load",null)},1);return}if(!this.ready&&navigator.userAgent.match(/Firefox/)&&navigator.userAgent.match(/Windows/)){var c=this;setTimeout(function(){c.receiveEvent("load",null)},100);this.ready=true;return}this.ready=true;this.movie.setText(this.clipText);this.movie.setHandCursor(this.handCursorEnabled);break;case"mouseover":if(this.domElement&&this.cssEffects){this.domElement.addClass("hover");if(this.recoverActive){this.domElement.addClass("active")}}break;case"mouseout":if(this.domElement&&this.cssEffects){this.recoverActive=false;if(this.domElement.hasClass("active")){this.domElement.removeClass("active");this.recoverActive=true}this.domElement.removeClass("hover")}break;case"mousedown":if(this.domElement&&this.cssEffects){this.domElement.addClass("active")}break;case"mouseup":if(this.domElement&&this.cssEffects){this.domElement.removeClass("active");this.recoverActive=false}break}if(this.handlers[d]){for(var b=0,a=this.handlers[d].length;b<a;b++){var f=this.handlers[d][b];if(typeof(f)=="function"){f(this,e)}else{if((typeof(f)=="object")&&(f.length==2)){f[0][f[1]](this,e)}else{if(typeof(f)=="string"){window[f](this,e)}}}}}}};!function(document,undefined){var kdHistory=function(){return kdHistory.all()};var utils={getcookie:function(cookieName){var cookieValue="";if(document.cookie&&document.cookie!=""){var cookies=document.cookie.split(";");for(var i=0;i<cookies.length;i++){var cookie=cookies[i].replace(/(^\s*)|(\s*$)/g,"");if(cookie.substring(0,cookieName.length+1)==(cookieName+"=")){cookieValue=unescape(cookie.substring(cookieName.length+1));break}}}return cookieValue},setcookie:function(cookieName,cookieValue,option){var expires;if(option==-1){expires=-1}else{expires=new Date();var now=parseInt(expires.getTime());var et=(86400-expires.getHours()*3600-expires.getMinutes()*60-expires.getSeconds());expires.setTime(parseInt(expires.getTime())+1000000*(et-expires.getTimezoneOffset()*60));expires=expires.toGMTString()}document.cookie=escape(cookieName)+"="+escape(cookieValue)+";expires="+expires+";domain=kuaidi100.com;path=/";document.cookie="toolbox_urls=;expires=-1;path=/"},toJSONString:function(json){if(window.JSON){return JSON.stringify(json)}else{return utils._ToJson(json)}},toStringJSON:function(string){if(window.JSON){return JSON.parse(string)}else{return eval("("+string+")")}},_ToJson:function(o){if(o==null){return"null"}switch(o.constructor){case String:var s=o;if(s.indexOf("}")<0){s='"'+s.replace(/(["\\])/g,"\\$1")+'"'}s=s.replace(/\n/g,"\\n");s=s.replace(/\r/g,"\\r");return s;case Array:var v=[];for(var i=0;i<o.length;i++){v.push(_ToJSON(o[i]))}if(v.length<=0){return'""'}return""+v.join(",")+"";case Number:return isFinite(o)?o.toString():_ToJSON(null);case Boolean:return o.toString();case Date:var d=new Object();d.__type="System.DateTime";d.Year=o.getUTCFullYear();d.Month=o.getUTCMonth()+1;d.Day=o.getUTCDate();d.Hour=o.getUTCHours();d.Minute=o.getUTCMinutes();d.Second=o.getUTCSeconds();d.Millisecond=o.getUTCMilliseconds();d.TimezoneOffset=o.getTimezoneOffset();return _ToJSON(d);default:if(o.toJSON!=null&&typeof o.toJSON=="function"){return o.toJSON()}if(typeof o=="object"){var v=[];for(attr in o){if(typeof o[attr]!="function"){v.push('"'+attr+'": '+_ToJSON(o[attr]))}}if(v.length>0){return"{"+v.join(",")+"}"}else{return"{}"}}return o.toString()}}};kdHistory.all=function(){var cookie_old=utils.getcookie("toolbox_urls");var cookie=utils.getcookie("kd_history");if(cookie&&cookie!=""&&cookie!="\"\""){var json=utils.toStringJSON(cookie);return json}else{if(cookie_old&&cookie_old!=""&&cookie_old!="\"\""){var json=utils.toStringJSON(cookie_old);return json.history}else{return[]}}};kdHistory.add=function(code,nu,ischeck){this.remove(code,nu);var history=this.all();var historyItem={code:code,nu:nu,time:new Date(),ischeck:ischeck};history.unshift(historyItem);if(history.length>10){history.splice(10,history.length-10)}this.save(history)};kdHistory.remove=function(code,nu){var history=this.all();for(var i in history){if(history[i].code==code&&history[i].nu==nu){history.splice(i,1);break}}this.save(history)};kdHistory.empty=function(){utils.setcookie("kd_history","","-1")};kdHistory.save=function(history){if(history&&history!="undefined"){utils.setcookie("kd_history",utils.toJSONString(history))}};if(typeof define==="function"&&define.amd){define(function(){return kdHistory})}else{if(typeof exports!=="undefined"){exports.kdHistory=kdHistory}else{window.kdHistory=kdHistory}}}(document);var clip=null;copyInit();function copyInit(){ZCBinder("sendUrl","sendUrlBtn","sendHistory",function(){$("#sendUrl").select();$("#sendMsg").html("已把转发地址复制到剪贴板!");$("#sendContent").css({height:"18px"})});ZCBinder("sendContent","sendContentBtn","sendHistory",function(){$("#sendContent").select().css({height:"200px"});$("#sendMsg").html("已把转发内容复制到剪贴板!")})}function openSenBox(){var a=$("#frameName").val();if(a==null){a=""}$("#sendMsg").html("");$("#sendUrl").val("//www.kuaidi100.com/chaxun?from="+a+"&com="+gCompanyCode+"&nu="+gKuaidiNumber);$("#sendContent").val(gCompanyName+"单号“"+gKuaidiNumber+"”的查询结果：\n......\n"+translateTotext(gResultData,2)+"更多详情：http://www.kuaidi100.com/chaxun?from="+a+"&com="+gCompanyCode+"&nu="+gKuaidiNumber);$("#sendHistoryBtn").hide();$("#sendHistory").show();$("#weixin").hide();$("#sendUrl").blur();$("#sendContent").blur();$("#selectedTag").removeClass("pos1").addClass("pos2").show()}function translateTotext(b,a){try{if(a>b.length){a=b.length}var d="";for(var c=a-1;c>=0;c--){d+=$.trim(b[c].time)+" "+$.trim(b[c].context).replace(/\s+/g," ")+"\n"}return d}catch(f){}}function ZCBinder(a,d,b,c){clip=new ZeroClipboard.Client();ZeroClipboard.setMoviePath("//cdn.kuaidi100.com/images/ZeroClipboard.swf");clip.setHandCursor(true);$("#"+d).mouseover(function(){clip.setText($("#"+a).val());if(clip.div){clip.reposition(d)}else{clip.glue(d)}clip.addEventListener("complete",function(){if(c!=null){c()}});clip.receiveEvent("mouseover",null)})}function selectCtrl(){if(document.selection){document.selection.empty()}else{if(window.getSelection){window.getSelection().removeAllRanges()}}$(".sendMsg").html("")}function closeHisCtrl(){selectCtrl();$(".send-box").hide();$(".send-box-on").show();$(".sendMsg").html("");$("#selectedTag").hide();$("#sendContent").css({height:"18px"})}var gQueryType=1;var gAjaxObject;var gAjaxTime;var gLastNum="";var gSelectKeywordIndex=-1;var copyNotfindReady=0;$(function(){var b=$("#postid");var a=new RegExp("[0-9a-zA-Z]{4,}");b.keyup(function(f){var c=f.keyCode?f.keyCode:f.which;if(c!=13){var d=b.val();if(d!=""){if(d!=gLastNum){clearTimeout(gAjaxTime);gAjaxTime=setTimeout("getKeyword()",200)}}else{clearTimeout(gAjaxTime);$("#inputTips").hide();gSelectKeywordIndex=-1}}}).keydown(function(f){var c=f.keyCode?f.keyCode:f.which;var d=b.val();if(c==40&&d!=""&&a.test(d)){if($("#inputTips").is(":hidden")){$("#inputTips").show();$("#inputTips li.selection").removeClass("hover")}else{if(gSelectKeywordIndex==-1){gSelectKeywordIndex=0}else{if(gSelectKeywordIndex==$("#inputTips li.selection:last").attr("data-index")){gSelectKeywordIndex=0}else{gSelectKeywordIndex++}}$("#inputTips li.selection").removeClass("hover");$("#inputTips li.selection:eq("+gSelectKeywordIndex+")").addClass("hover")}}else{if(c==38&&d!=""&&a.test(d)){if($("#inputTips").is(":hidden")){$("#inputTips").show();$("#inputTips li.selection").removeClass("hover")}else{if(gSelectKeywordIndex==-1){gSelectKeywordIndex=$("#inputTips li.selection:last").attr("data-index")}else{if(gSelectKeywordIndex==0){gSelectKeywordIndex=$("#inputTips li.selection:last").attr("data-index")}else{gSelectKeywordIndex--}}$("#inputTips li.selection").removeClass("hover");$("#inputTips li.selection:eq("+gSelectKeywordIndex+")").addClass("hover")}}}}).click(function(d){d.stopPropagation();var c=b.val();if(c!=""&&a.test(c)){$("#inputTips").show()}});$(document).click(function(){if(!$("#inputTips").is(":hidden")){$("#inputTips").hide()}});$("#query").click(query);$("#inputTips").delegate("li.selection","mouseenter",function(){$("#inputTips li").removeClass("hover");$(this).addClass("hover");gSelectKeywordIndex=$(this).attr("data-index")}).delegate("li.selection","click",function(){query()});$("#useTips").click(function(){b.val($(this).text()).css("color","#333").focus();getKeyword()});$("#useTips2").click(function(){b.val($(this).text()).css("color","#333")});$("#selectComBtn").click(function(){$("#queryContext").hide();$("#queryQr").hide();$("#queryPs").hide();$("#notFindTip").hide();$("#comList").show();_hmt.push(["_trackEvent","company","company-open"])});$("#otherComBtn").click(function(){$("#comList").hide();if(gQueryResult==0){$("#notFindTip").show()}else{if(gQueryResult==200){$("#queryContext").show();$("#queryQr").show();$("#queryPs").show()}else{$("#notFindTip").show()}}_hmt.push(["_trackEvent","company","company-close"])});$("#comList .com-list").delegate("a","click",function(){if(gLoading==1){return}hideTips();$("#comList").hide();gSelectKeywordIndex=-1;var c=$(this).attr("data-code");if(c!=null&&c!=""){selectCompanyByCode($(this).attr("data-code"));if(validateKuaidiNumber()){if(gCompanyCode=="shunfeng"){$("#sfQr").css("display","block")}else{$("#sfQr").hide()}getResult(gCompanyCode,$("#postid").val().Trim())}}});$("#commonBox .common-netlist").delegate("[data-id]","click",function(){window.open("//www.kuaidi100.com/network/networkDt"+$(this).attr("data-id")+".htm?from=newindex");_hmt.push(["_trackEvent","networkDt","click"])});$("#commonTag").delegate("a","click",function(){var c=$(this).attr("data-tag");$("#commonTag").find("a").removeClass("tag-select");$(this).addClass("tag-select");toggleCommon($(this).attr("data-tag"));_hmt.push(["_trackEvent","card-"+c,"click"])});$("#rssBtn").click(function(){window.location.href="/user/login.shtml?com="+gCompanyCode+"&nu="+gKuaidiNumber+"&rss=1"});$("#shareBtn").click(function(){openSenBox();$("#shareBox").show();$("#sendHistory").css("margin-top",($(window).height()-120)/2+"px")});$("#shareClose").click(function(){closeHisCtrl();$("#shareBox").hide()});$("#commonShow").click(function(){$("#commonShow").hide();$("#commonBox").show();$("#commonTag").find(".tag-1").click();getHotNetwork();deleteCookie("hideIndexCommon");_hmt.push(["_trackEvent","card","card-open"])});$("#commonClose").click(function(){$("#commonBox").hide();setcookie("hideIndexCommon","1");_hmt.push(["_trackEvent","card","card-close"])});$("#wbLink").mouseenter(function(){$("#qrImg").attr("src","//cdn.kuaidi100.com/images/qrcode/qr_weibo.png");$("#qrLink").attr("href","http://e.weibo.com/kuaidi100")});$("#wxLink").mouseenter(function(){$("#qrImg").attr("src","//cdn.kuaidi100.com/images/qrcode/qr_weixin.png");$("#qrLink").removeAttr("href")});$("#appLink").mouseenter(function(){$("#qrImg").attr("src","//cdn.kuaidi100.com/images/qrcode/qr_app.png");$("#qrLink").attr("href","//www.kuaidi100.com/mobile/iphone.shtml")});$("#downloadLink").mouseenter(function(){$("#resultImgBox").hide();$("#downloadImgBox").show()}).mouseleave(function(){$("#downloadImgBox").hide();$("#resultImgBox").show()});$("#downloadBtn").mouseenter(function(){$("#downloadQr").show()}).mouseleave(function(){$("#downloadQr").hide()})});(function(){if(getcookie("indexVersion")=="2.0"){window.location.href="//www.kuaidi100.com/index_old.shtml"}else{$("#body").show();$("#versionLink").show();$("#oldLink").show().click(function(){setcookie("indexVersion","2.0");window.location.href="//www.kuaidi100.com/index_old.shtml?from=newindex"});selectNav()}var c=$("#postid");var a=GetQueryString("nu");if(a!=null&&a!=""){c.val(a);query()}if(getcookie("hideIndexCommon")!=1){$("#commonBox").show();toggleCommon("kdList");getHotNetwork()}else{$("#commonShow").show()}$.ajax({type:"post",url:"/network/www/searchapi.do",data:"method=findxzqbyip",dataType:"json",success:function(d){if(d!=null&&d!=""){var e=d.fullName;$(".current-city").text(e.substring(e.lastIndexOf(",")+1));$("#location").addClass("btn-location").click(function(){c.val(e.replace(/,/g,""))})}}});for(var b in jsoncom.company){if(jsoncom.company[b].code=="yuantong"){$("#useTips").text(jsoncom.company[b].testnu);break}}$("#wxqr").hide();$("#footAboutUs").hide()})();function logged(){countHis()}function unLogged(){countHis()}function getHotNetwork(){$.ajax({type:"post",url:"/network/www/searchapi.do",data:{method:"searchnetwork",area:"",company:"",keyword:"",offset:0,size:3,from:"www",auditStatus:1},dataType:"json",success:function(a){if(a.status==200){for(var b in a.netList){var c=a.netList[b].name.replace(/<[^>]+>/g,"");var d=$('<a data-com="'+a.netList[b].companyNumber+'" title="'+c+'" data-id="'+a.netList[b].sId+'">'+c+"</a>");d.css("background",'url("//cdn.kuaidi100.com/images/all/16/'+a.netList[b].companyNumber+'.png") 0 3px no-repeat');$(".common-netlist").append(d)}}}})}function getKeyword(){var a=$("#postid").val().Trim();gLastNum=a;if(gAjaxObject){gAjaxObject.abort()}gAjaxObject=$.ajax({type:"post",url:"/autonumber/autoComNum?text="+a,dataType:"json",success:function(b){gSelectKeywordIndex=-1;if(b.auto&&b.auto.length>0){$("#inputTips").show()}else{$("#inputTips").hide()}addSuggestion(b)}})}function addSuggestion(a){$("#suggestList").empty();$("#inputTips").empty();var e=0;var d=a.num;if(a.auto&&a.auto.length>0){$("#suggestList").append('<span class="li-title">推荐</span>');for(e=0;e<a.auto.length;e++){var c=a.auto[e].comCode;for(var b in jsoncom.company){if(c==jsoncom.company[b].code){$("#suggestList").append('<a data-code="'+c+'" data-num="'+d+'">'+jsoncom.company[b].shortname+"</a>");if(e<=2){$("#inputTips").append('<li class="selection selection'+e+'" data-index="'+e+'" data-code="'+c+'" data-num="'+d+'">'+d+"&emsp;"+jsoncom.company[b].companyname+"</li>")}}}}if(e>2){e=3}}$("#inputTips").append('<li class="selection selection'+e+'" data-index="'+e+'" data-code="other">'+d+"&emsp;其他快递</li>");$("#inputTips").append('<li class="tips_bottom">由快递100猜测</li>')}function toggleCommon(a){$("#commonBox").find(".common-list").hide();$("#"+a).show().find("[data-com]").each(function(){$(this).css("background",'url("//cdn.kuaidi100.com/images/all/16/'+$(this).attr("data-com")+'.png") 0 3px no-repeat')})}function query(){if(gLoading==1){return}var a=$("#postid").val().Trim();var c=new RegExp("[0-9a-zA-Z]{4,}");if(a==""){$("#errorTips").show();$("#errorMessage").html("请输入快递单号。");$("#postid").focus()}else{if(c.test(a)){gQueryResult=0;clearTimeout(gAjaxTime);hideTips();$("#example").hide();$("#selectCom").hide();$("#comList").hide();$("#commonBox").hide();if(gSelectKeywordIndex>=0){var b=$("#inputTips li.selection:eq("+gSelectKeywordIndex+")");var d=b.attr("data-code");if(d!="other"){if(d=="shunfeng"){$("#sfQr").css("display","block")}else{$("#sfQr").hide()}selectCompanyByCode(d);$("#postid").val(b.attr("data-num"));if(validateKuaidiNumber()){getResult(gCompanyCode,b.attr("data-num"))}_hmt.push(["_trackEvent","autoCom","click"])}else{$("#selectCom").show();$("#selectComBtn").click();_hmt.push(["_trackEvent","otherCom","click"])}}else{gLastNum=a;$("#inputTips").hide();$("#queryWait").show();if(gAjaxObject){gAjaxObject.abort()}gLoading=1;gAjaxObject=$.ajax({type:"post",url:"/autonumber/autoComNum?text="+a,dataType:"json",success:function(e){gLoading=0;$("#queryWait").hide();if(e.comCode||(e.auto&&e.auto.length>0)){var f=e.comCode?e.comCode:e.auto[0].comCode;if(f=="shunfeng"){$("#sfQr").css("display","block")}else{$("#sfQr").hide()}selectCompanyByCode(f);$("#postid").val(e.num);if(validateKuaidiNumber()){getResult(gCompanyCode,e.num)}}else{$("#queryContext").hide();$("#selectComBtn").html("其他快递");$("#selectComBtn").parent().css("background","");$("#selectCom").show();$("#notFindTip").show()}addSuggestion(e);$("#postid").select()},error:function(){gLoading=0}});_hmt.push(["_trackEvent","query","click"])}gSelectKeywordIndex=-1}else{window.open("/courier/search.jsp?searchText="+encodeURIComponent(a))}}}function addFavoritesHistory(a){var f="快递查询-查快递，寄快递，上快递100";var b="http://"+document.domain;if(a!=""&&a!=null){b=a}try{window.external.addFavorite(b,f)}catch(e){try{window.external.AddToFavoritesBar(b,f)}catch(d){try{window.sidebar.addPanel(f,b)}catch(c){alert('收藏失败，此操作被浏览器拒绝！\n请使用"Ctrl+D"进行收藏！')}}}}var logoutDone=0;isAutoLogin();function isAutoLogin(){var b=getcookie("loginAccount");var a=getcookie("loginStatus");var c=getcookie("loginSession");if(a=="1"&&c=="1"){$("#loginAccount").val(b);$("#loginStatus").val("1");setWelcomeLogin(b);if($.isFunction(window.logged)){logged()}}else{if(a=="1"){login()}else{deleteCookie("loginAccount");deleteCookie("loginStatus");deleteCookie("loginSession");deleteCookie("password");deleteCookie("ischeck");deleteCookie("phone");deleteCookie("ftype");setWelcomeLogout();setTopCookieTips();$("#loginAccount").val("");$("#loginStatus").val("0");if($.isFunction(window.unLogged)){unLogged()}}}}function login(){var account=getcookie("loginAccount");var password=getcookie("password");password=rc4(password,"kuaidi100");if(account&&account!=""&&password&&password!=""){$("#welcome").html('<img src="//cdn.kuaidi100.com/images/ajax-loader.gif" />正在自动登陆');$.ajax({type:"post",url:"/login",data:"account="+account+"&password="+password,success:function(responseText){var resultJson=eval("("+responseText+")");var account=resultJson.account;if(resultJson.status=="200"){if(resultJson.ischeck=="1"){setcookie("ischeck","1");setcookie("phone",resultJson.telephone)}else{deleteCookie("ischeck")}setWelcomeLogin(resultJson.account);$("#loginAccount").val(account);$("#loginStatus").val("1");setcookie2("loginSession","1");if($.isFunction(window.logged)){logged()}}else{if(resultJson.status=="302"){window.location.href=resultJson.url}else{deleteCookie("loginAccount");deleteCookie("loginStatus");deleteCookie("loginSession");deleteCookie("password");deleteCookie("ischeck");deleteCookie("phone");deleteCookie("ftype");setWelcomeLogout();setTopCookieTips();$("#loginAccount").val("");$("#loginStatus").val("0");if($.isFunction(window.unLogged)){unLogged()}}}}})}else{setWelcomeLogout();setTopCookieTips();$("#loginAccount").val("");$("#loginStatus").val("0");if($.isFunction(window.unLogged)){unLogged()}}}function logout(){var outAccount=getcookie("loginAccount");if(outAccount&&outAccount!=""){var logoutUrl="/logout";var sendData="account="+escape(outAccount);try{$.post(logoutUrl,{outAccount:outAccount},function(responseText){var resultJson=eval("("+responseText+")");if(resultJson.status=="200"||resultJson.status=="420"){var ftype=getcookie("ftype");deleteCookie("loginAccount");deleteCookie("loginStatus");deleteCookie("loginSession");deleteCookie("password");deleteCookie("phone");deleteCookie("ischeck");deleteCookie("ftype");logoutDone=0;doPost("//www.kuaidi100.com/sso/api.do?action=logout&temp="+Math.random());doPost("http://"+ftype+".kuaidi100.com/kdsso/loginapi.do?method=logout&temp="+Math.random())}})}catch(e){window.location.replace(location.href)}}}function doPost(a){var b=$('<iframe width="0" height="0" frameborder="0" scrolling="0"></iframe>');b.appendTo("body");b.attr("src",a);b.load(logoutFinish)}function logoutFinish(){logoutDone++;if(logoutDone>=2){window.location.reload()}}function rc4(c,f){var h=Array(256);var l=Array(c.length);var b=0;for(var d=0;d<256;d++){h[d]=d}for(var d=0;d<256;d++){b=(b+h[d]+f.charCodeAt(d%f.length))%256;var g=h[d];h[d]=h[b];h[b]=g}for(var d=0;d<c.length;d++){l[d]=c.charCodeAt(d)}var d=0,b=0;for(var e=0;e<l.length;e++){d=(d+1)%256;b=(b+h[d])%256;var g=h[d];h[d]=h[b];h[b]=g;var a=(h[d]+h[b])%256;l[e]=String.fromCharCode(l[e]^h[a])}return l.join("")};