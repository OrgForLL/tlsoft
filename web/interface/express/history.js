
!function(document, undefined){
	var kdHistory = function(){
		return kdHistory.all();
	}
	var utils = {
		getcookie : function(cookieName){
			var cookieValue="";
			if (document.cookie && document.cookie != '') {
				var cookies = document.cookie.split(';');
				for (var i = 0; i < cookies.length; i++) {
					var cookie = cookies[i].replace(/(^\s*)|(\s*$)/g, "");
					if(cookie.substring(0, cookieName.length + 1) == (cookieName + '=')){
						cookieValue = unescape(cookie.substring(cookieName.length + 1));
						break;
					}
				}
			}
			return cookieValue;
		},
		setcookie : function(cookieName, cookieValue, option){
			var expires;
			if(option == -1){
				expires = -1;
			}else{
				expires = new Date();
				var now = parseInt(expires.getTime());
				var et = (86400 - expires.getHours() * 3600 - expires.getMinutes() * 60 - expires.getSeconds());
				expires.setTime(parseInt(expires.getTime()) + 1000000 * (et - expires.getTimezoneOffset() * 60));
				expires = expires.toGMTString();
			}
			document.cookie = escape(cookieName) + "=" + escape(cookieValue) + ";expires=" + expires + ";domain=kuaidi100.com;path=/";
			document.cookie = "toolbox_urls=;expires=-1;path=/";
		},
		toJSONString : function(json){
			if(window.JSON){
				return JSON.stringify(json);
			}else{
				return utils._ToJson(json);
			}
		},
		toStringJSON : function(string){
			if(window.JSON){
				return JSON.parse(string);
			}else{
				return eval("(" + string + ")");
			}
		},
		_ToJson : function(o) {
		  if (o == null) return "null";
		  switch (o.constructor) {
		  case String:
			var s = o; // .encodeURI();
			if (s.indexOf("}") < 0) s = '"' + s.replace(/(["\\])/g, '\\$1') + '"';
			s = s.replace(/\n/g, "\\n");
			s = s.replace(/\r/g, "\\r");
			return s;
		  case Array:
			var v = [];
			for (var i = 0; i < o.length; i++) v.push(_ToJSON(o[i]));
			if (v.length <= 0) return "\"\"";
			return "" + v.join(",") + "";
		  case Number:
			return isFinite(o) ? o.toString() : _ToJSON(null);
		  case Boolean:
			return o.toString();
		  case Date:
			var d = new Object();
			d.__type = "System.DateTime";
			d.Year = o.getUTCFullYear();
			d.Month = o.getUTCMonth() + 1;
			d.Day = o.getUTCDate();
			d.Hour = o.getUTCHours();
			d.Minute = o.getUTCMinutes();
			d.Second = o.getUTCSeconds();
			d.Millisecond = o.getUTCMilliseconds();
			d.TimezoneOffset = o.getTimezoneOffset();
			return _ToJSON(d);
		  default:
			if (o["toJSON"] != null && typeof o["toJSON"] == "function") return o.toJSON();
			if (typeof o == "object") {
			  var v = [];
			  for (attr in o) {
				if (typeof o[attr] != "function") v.push('"' + attr + '": ' + _ToJSON(o[attr]));
			  }
			  if (v.length > 0) return "{" + v.join(",") + "}";
			  else return "{}";
			}
			//alert(o.toString());
			return o.toString();
		  }
		}
	}
	kdHistory.all = function(){
		var cookie_old = utils.getcookie("toolbox_urls"); //兼容老用户
		var cookie = utils.getcookie("kd_history");
		if(cookie && cookie != "" && cookie != "\"\""){
			var json = utils.toStringJSON(cookie);
			return json;
		}else if(cookie_old && cookie_old != "" && cookie_old != "\"\""){
			var json = utils.toStringJSON(cookie_old);
			return json.history;
		}else{
			return [];
		}
	};
	kdHistory.add = function(code, nu, ischeck){
		this.remove(code, nu);
		var history = this.all();
		var historyItem = {
			code : code,
			nu : nu,
			time : new Date(),
			ischeck : ischeck
		};
		history.unshift(historyItem);
		if(history.length > 10){
			history.splice(10, history.length - 10);
		}
		this.save(history);
	};
	kdHistory.remove = function(code, nu){
		var history = this.all();
		for(var i in history){
			if(history[i].code == code && history[i].nu == nu){
				history.splice(i, 1);
				break;
			}
		}
		this.save(history);
	};
	kdHistory.empty = function(){
		utils.setcookie("kd_history", "", "-1");
	};
	kdHistory.save = function(history){
		if(history && history != "undefined"){
			utils.setcookie("kd_history", utils.toJSONString(history));
		}
	};
	
	if (typeof define === 'function' && define.amd) {
		define(function () {
			return kdHistory;
		});
	} else if (typeof exports !== 'undefined') {
		exports.kdHistory = kdHistory;
	} else window.kdHistory = kdHistory;
}(document);