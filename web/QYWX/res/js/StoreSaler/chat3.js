// JavaScript Document
var currentWxid = "";
var currentUser;//当前聊天的用户
var TimeCount = 0;
$(function () {
    FastClick.attach(document.body);
    GenerateEmoji();

    $(".chat-ul li").click(function (e) {
        currentUser = this;
        $('#chat-area').html("");
        showLoader("loading", "正在加载...");
        currentWxid = this.id;
        $(".red-dot", this).remove();//去除小红点
        var url = "/oa/webbll/chatdetail.ashx?wxid=" + currentWxid + "&_=" + escape(new Date());

        //李清峰增加以下代码： 
        var nickname = $(this).find(".chat-info>.chat-name").html(); 
        $(".header>.current-user").html(nickname);
        //代码增加结束

        var userimg = $(this).find(".userimg").css("background-image");

        $.getJSON(url, function (data) {
            for (var i in data) {
                data[i].Content = FaceChange(data[i].Content);
                data[i]['idx'] = 0;
                data[i]["Order"] = i;
            }

            $("#chat-list").addClass("page-left");
            $("#chat-detail").removeClass("page-right");

            $('#tmpchat').tmpl(data).appendTo("#chat-area");
            $(".mask").hide();
            positionReset();
            $(".header .notice").removeClass("twinkle");

            //李清峰增加以下代码： 
            $("#chat-area>.msgRow").find(".mine").css("background-image", userimg);
            //代码增加结束
        });
    });
	Msg.init();
	Msg.reg();
	
	$('#uploadphoto').localResizeIMG({
		width: 400,
        quality: 1,
		before: function (that, blob) {
            $("#chat-media").addClass("page-bot");
            $("#emoji-wrapper").addClass("page-bot");
            $(".mask .loader").show();
			$(".mask").show();
			return true;
		},
        success: function (result) {  
		    var submitData={
				base64img:result.clearBase64,
				wxid:currentWxid
			}; 
		    $.ajax({
			    type: "POST",
			    url: "/OA/webbll/ChatImageSendMobile.aspx",
			    data: submitData,
			    success: function(data){
					var content = "<img onclick='ReviewImage(this)' src='" + data + "'></img>";
					var data = { MsgType: 2, Content: content, status:1, idx: 0, Order:1};
					$('#tmpchat').tmpl(data).appendTo("#chat-area");
			        Msg.reset();
					return false;
			    }, 
				complete :function(XMLHttpRequest, textStatus){
					$(".mask").hide();				
				},
				error:function(XMLHttpRequest, textStatus, errorThrown){ //上传失败 
				   alert(XMLHttpRequest.status);
				   alert(XMLHttpRequest.readyState);
				   alert(textStatus);
				}
		   }); 
        }
    });
	
	wx.config({
		debug: false,
		appId: '<%= wxConfig[0] %>', 
		timestamp: '<%= wxConfig[1] %>',
		nonceStr: '<%= wxConfig[2] %>', 
		signature: '<%= wxConfig[3] %>',
		jsApiList: ['previewImage']
	});
});

function positionReset(){
	var obj = document.getElementById("chat-area");
	$("#chat-area").animate({ scrollTop: (obj.scrollHeight - obj.clientHeight) + 'px' }, 400);
}
function ChatContent() {
	$("#chat-list").addClass("page-left");
	$("#chat-detail").removeClass("page-right");
}

function BackFunc() {
	$("#chat-list").removeClass("page-left");
	$("#chat-detail").addClass("page-right");
	if ($("#chat-detail").hasClass("page-right"))
	    currentUser = undefined;
	//李清峰新增以下代码：
	$(".header>.current-user").html("");
	//代码增加结束
}

$("#btn-add").click(function () {
    $(".mask .loader").hide();
	$(".mask").show();
	$("#chat-media").removeClass("page-bot");
});

$("#btn-face").click(function () {
    $(".mask .loader").hide();
	$(".mask").show();
	$("#emoji-wrapper").removeClass("page-bot");
});

$(".mask").click(function () {
	$("#chat-media").addClass("page-bot");
	$("#emoji-wrapper").addClass("page-bot");
	$(".mask").hide();
});

//生成表情列表
function GenerateEmoji() {
	var strHtml = "", rowX = 0, rowY = 0, faceCount = 0;
	var itemTemp = "<a href='javascript:void(0)' onclick='face2code(this)' title='#code#'><img src='../../res/img/emoji//blank.gif' class='img' style='background: url(../../res/img/emoji//wx-face.png) #rowX#px #rowY#px no-repeat; background-size: 675px 175px;' alt=''></a>";
	for (var i = 0; i < 3; i++) {
		for (var j = 0; j < 27; j++) {
			rowX = j * -25;
			strHtml += itemTemp.replace("#code#", faceArray[faceCount]).replace("#rowX#", rowX).replace("#rowY#", rowY);
			faceCount++;
			if (faceCount == 67)
				break;
		}//end row
		rowX = 0;
		rowY -= 25;
	}//end column

	$("#emoji-wrapper .wrapper").append(strHtml);
}

function face2code(obj) {
	var attr = $(obj).attr("title");
	$("#chat-in").val($("#chat-in").val() + attr);
	$("#chat-media").addClass("page-bot");
	$("#emoji-wrapper").addClass("page-bot");
	$(".mask").hide();
	$(".btn.send").removeClass("hide");
}

function showSendBtn() {
	if ($(".chat-input input[type=text]").val() == ""&&!$(".btn.send").hasClass("hide")) {
		$(".btn.send").addClass("hide");
	} else if ($(".chat-input input[type=text]").val() != "" && $(".btn.send").hasClass("hide")) {
		$(".btn.send").removeClass("hide");
	}
}

function switchMenu(order) {    
	showLoader("loading","正在加载");
    switch (order) {
        case 0:
            window.location.href = "chatlist.aspx";            
            break;
        case 1:
            window.location.href = "NewVipList.aspx";
            break;
        case 2:            
            showLoader("warn","正在开发中...");
            break;
        case 3:
            window.location.href = "usercenter.aspx";
            break;
        default:
            showLoader("warn", "正在开发中...");
            setTimeout(function () {
                $(".mask").hide();
            }, 1000);
            break;
    }
}

$("#send-btn").click(function () {
	var content = $("#chat-in").val();	             
	var rel = Msg.send(content, currentWxid);
	$("#chat-in").val("");
	$(".btn.send").addClass("hide");

});

function FaceChange(content){
	var faceTemp = "<img src='../../res/img/emoji//blank.gif' class='img' style='background: url(../../res/img/emoji//wx-face.png) #siteX#px #siteY#px no-repeat; background-size: 675px 175px;' alt=''>";
	if (content != "") {
		var m = content.match(/([^\[\]]+)(?=\])/g);
		if (m != null && m != undefined) {
			for (var i = 0; i < m.length; i++) {
				try{
				    content = content.replace("[" + m[i] + "]", faceTemp.replace("#siteX#", FaceObj["[" + m[i] + "]"].x).replace("#siteY#", FaceObj["[" + m[i] + "]"].y));
				}
				catch(e){
					console.log(e);
				}
			}//end for
		}                
	}
	return content;
}

function showLoader(type, txt) {
    $(".mask .loader").show();
	switch (type) {
		case "loading":
			$(".mask .fa").removeAttr("class").addClass("fa fa-2x fa-spinner fa-pulse");
			$("#loadtext").text(txt);			
			$(".mask").show();
			break;
		case "successed":
			$(".mask .fa").removeAttr("class").addClass("fa fa-2x fa-check");
			$("#loadtext").text(txt);
			$(".mask").show();
			break;
		case "error":
			$(".mask .fa").removeAttr("class").addClass("fa fa-2x fa-close (alias)");
			$("#loadtext").text(txt);			
			$(".mask").show();
			break;
		case "warn":
			$(".mask .fa").removeAttr("class").addClass("fa fa-2x fa-warning (alias)");
			$("#loadtext").text(txt);			
			$(".mask").show();
			break;
	}	
}

var faceArray = ["[微笑]", "[撇嘴]", "[色]", "[发呆]", "[得意]", "[流泪]", "[害羞]", "[闭嘴]", "[睡]", "[大哭]", "[尴尬]", "[发怒]", "[调皮]", "[呲牙]", "[惊讶]", "[难过]", "[酷]", "[冷汗]", "[抓狂]", "[吐]", "[偷笑]", "[愉快]", "[白眼]", "[右哼哼]", "[哈欠]", "[鄙视]", "[委屈]", "[快哭]", "[阴险]", "[亲亲]", "[吓]", "[可怜]", "[菜刀]", "[西瓜]", "[啤酒]", "[篮球]", "[乒乓]", "[咖啡]", "[饭]", "[猪头]", "[玫瑰]", "[凋谢]", "[嘴唇]", "[爱心]", "[心碎]", "[蛋糕]", "[闪弹]", "[炸弹]", "[刀]", "[足球]", "[瓢虫]", "[便便]", "[月亮]", "[太阳]", "[礼物]", "[拥抱]", "[强]", "[弱]", "[握手]", "[胜利]", "[抱拳]", "[勾引]", "[拳头]", "[差劲]", "[爱你]", "[No]", "[OK]"];
var FaceObj = new Object();
FaceObj["[微笑]"] = { x: 0, y: 0 };
FaceObj["[撇嘴]"] = { x: -25, y: 0 };
FaceObj["[色]"] = { x: -50, y: 0 };
FaceObj["[发呆]"] = { x: -75, y: 0 };
FaceObj["[得意]"] = { x: -100, y: 0 };
FaceObj["[流泪]"] = { x: -125, y: 0 };
FaceObj["[害羞]"] = { x: -150, y: 0 };
FaceObj["[闭嘴]"] = { x: -175, y: 0 };
FaceObj["[睡]"] = { x: -200, y: 0 };
FaceObj["[大哭]"] = { x: -225, y: 0 };
FaceObj["[尴尬]"] = { x: -250, y: 0 };
FaceObj["[发怒]"] = { x: -275, y: 0 };
FaceObj["[调皮]"] = { x: -300, y: 0 };
FaceObj["[呲牙]"] = { x: -325, y: 0 };
FaceObj["[惊讶]"] = { x: -350, y: 0 };
FaceObj["[难过]"] = { x: -375, y: 0 };
FaceObj["[酷]"] = { x: -400, y: 0 };
FaceObj["[冷汗]"] = { x: -425, y: 0 };
FaceObj["[抓狂]"] = { x: -450, y: 0 };
FaceObj["[吐]"] = { x: -475, y: 0 };
FaceObj["[偷笑]"] = { x: -500, y: 0 };
FaceObj["[愉快]"] = { x: -525, y: 0 };
FaceObj["[白眼]"] = { x: -550, y: 0 };
FaceObj["[右哼哼]"] = { x: -575, y: 0 };
FaceObj["[哈欠]"] = { x: -600, y: 0 };
FaceObj["[鄙视]"] = { x: -625, y: 0 };
FaceObj["[委屈]"] = { x: -650, y: 0 };
FaceObj["[快哭]"] = { x: 0, y: -25 };
FaceObj["[阴险]"] = { x: -25, y: -25 };
FaceObj["[亲亲]"] = { x: -50, y: -25 };
FaceObj["[吓]"] = { x: -75, y: -25 };
FaceObj["[可怜]"] = { x: -100, y: -25 };
FaceObj["[菜刀]"] = { x: -125, y: -25 };
FaceObj["[西瓜]"] = { x: -150, y: -25 };
FaceObj["[啤酒]"] = { x: -175, y: -25 };
FaceObj["[篮球]"] = { x: -200, y: -25 };
FaceObj["[乒乓]"] = { x: -225, y: -25 };
FaceObj["[咖啡]"] = { x: -250, y: -25 };
FaceObj["[饭]"] = { x: -275, y: -25 };
FaceObj["[猪头]"] = { x: -300, y: -25 };
FaceObj["[玫瑰]"] = { x: -325, y: -25 };
FaceObj["[凋谢]"] = { x: -350, y: -25 };
FaceObj["[嘴唇]"] = { x: -375, y: -25 };
FaceObj["[爱心]"] = { x: -400, y: -25 };
FaceObj["[心碎]"] = { x: -425, y: -25 };
FaceObj["[蛋糕]"] = { x: -450, y: -25 };
FaceObj["[闪弹]"] = { x: -475, y: -25 };
FaceObj["[炸弹]"] = { x: -500, y: -25 };
FaceObj["[足球]"] = { x: -525, y: -25 };
FaceObj["[瓢虫]"] = { x: -550, y: -25 };
FaceObj["[便便]"] = { x: -575, y: -25 };
FaceObj["[月亮]"] = { x: -600, y: -25 };
FaceObj["[太阳]"] = { x: -625, y: -25 };
FaceObj["[礼物]"] = { x: -650, y: -25 };
FaceObj["[拥抱]"] = { x: 0, y: -50 };
FaceObj["[强]"] = { x: -25, y: -50 };
FaceObj["[弱]"] = { x: -50, y: -50 };
FaceObj["[握手]"] = { x: -75, y: -50 };
FaceObj["[胜利]"] = { x: -100, y: -50 };
FaceObj["[抱拳]"] = { x: -125, y: -50 };
FaceObj["[勾引]"] = { x: -150, y: -50 };
FaceObj["[差劲]"] = { x: -175, y: -50 };
FaceObj["[爱你]"] = { x: -200, y: -50 };
FaceObj["[No]"] = { x: -225, y: -50 };
FaceObj["[OK]"] = { x: -250, y: -50 };

var Msg = (function(){
	var SocketHandle;
	var index = 0;
	return {
		init:function(){
			SocketHandle = io.connect('http://tm.lilanz.com/chat');
			//收到信息
			SocketHandle.on('newmessage', function (data) {			    			    
        	    if (currentUser != undefined && currentUser.id == data.wxid) {
        	        var data = { MsgType: 1, Content: data.message, idx: 0, wxid: data.wxid, Order: 1 };
        	        $('#tmpchat').tmpl(data).appendTo("#chat-area");
        	        if (TimeCount == 5) {
        	            $("#chat-area .msgRow:last-child").prepend("<p class='message-time'>" + new Date().Format("MM月dd日 hh:mm") + "</p>");
        	            TimeCount = 0;
        	        } else
        	            TimeCount++;
        	        positionReset();
        	    } else {
        	        $(".header .notice").addClass("twinkle");
        	        $(".userimg", "#" + data.wxid).append("<div class='red-dot'></div>");
        	        $(".chat-ul").prepend($("#" + data.wxid));
        	    }
			});
			//收到信息
			SocketHandle.on('MsgStatus', function (data) {				
        	    //console.log(data);
				if(data.err == 0)
				    $(document.getElementById('msg_'+data.idx)).hide();
				else
				    $(document.getElementById('msg_'+data.idx)).
					addClass("fa-exclamation-circle").removeClass("fa-spinner");
			});
			console.log("初始化成功!");
		},
		//发送信息
        send:function(content, currentWxid){
			index++;
            SocketHandle.emit('sendMessage', {message: content, touser: currentWxid, idx: index});//--1
            var data = { MsgType: 2, Content: FaceChange(content), status: 1, idx: index, Order: 1 }; //--2
            $('#tmpchat').tmpl(data).appendTo("#chat-area");
            if (TimeCount == 5) {
                $("#chat-area .msgRow:last-child").prepend("<p class='message-time'>" + new Date().Format("MM月dd日 hh:mm") + "</p>");
                TimeCount = 0;
            } else
                TimeCount++;
			positionReset();
			return index;
        },
		reg:function(){
	        var rel = SocketHandle.emit('reg', { userid: _userid, type: 0 });
			console.log("用户注册!");
		},
		reset:function(){
			positionReset();
		}
    };
	function positionReset(){
		var obj = document.getElementById("chat-area");
		$("#chat-area").animate({ scrollTop: (obj.scrollHeight - obj.clientHeight) + 'px' }, 400);
	}
})();

function ReviewImage(obj){
	var imgURLs = [];
	imgURLs.push(obj.src.replace('/small',''));
	wx.previewImage({
		current: imgURLs[0],
		urls: imgURLs 
	});
}

//搜索功能
$.expr[":"].Contains = function (a, i, m) {
    return (a.textContent || a.innerText || "").toUpperCase().indexOf(m[3].toUpperCase()) >= 0;
};

function searchFunc() {
    var obj = $(".chat-ul .chat-name");    
    if (obj.length > 0) {
        var filter = $("#searchtxt").val();
        if (filter) {
            $matches = $(".chat-ul .chat-info").find("p:Contains(" + filter + ")").parent().parent();
            $("li", $(".chat-ul")).not($matches).hide();
            $matches.show();
        } else {
            $(".chat-ul").find("li").show();
        }
    }
}

Date.prototype.Format = function (fmt) { //author: meizz 
    var o = {
        "M+": this.getMonth() + 1, //月份 
        "d+": this.getDate(), //日 
        "h+": this.getHours(), //小时 
        "m+": this.getMinutes(), //分 
        "s+": this.getSeconds(), //秒 
        "q+": Math.floor((this.getMonth() + 3) / 3), //季度 
        "S": this.getMilliseconds() //毫秒 
    };
    if (/(y+)/.test(fmt)) fmt = fmt.replace(RegExp.$1, (this.getFullYear() + "").substr(4 - RegExp.$1.length));
    for (var k in o)
        if (new RegExp("(" + k + ")").test(fmt)) fmt = fmt.replace(RegExp.$1, (RegExp.$1.length == 1) ? (o[k]) : (("00" + o[k]).substr(("" + o[k]).length)));
    return fmt;
}