function getAjaxHttp(){var t;try{t=new XMLHttpRequest}catch(e){try{t=new ActiveXObject("Msxml2.XMLHTTP")}catch(e){try{t=new ActiveXObject("Microsoft.XMLHTTP")}catch(t){return alert("您的浏览器不支持AJAX！"),!1}}}return t}function requestFile(t,e,n,a,c){var r=getAjaxHttp();r.onreadystatechange=function(){4==r.readyState&&(200==r.status?a(r.responseText):(c=c||function(){})(r.status+"|"+r.statusText))},r.open(e,t,n),r.send()}