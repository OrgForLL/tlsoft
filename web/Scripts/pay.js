// JavaScript Document
//window.onload=function () {
//	UnionPay.init();
//}         
var UnionPay =(function(){
	var PayChannel = "01";
	var _url = "./PosPayApi.ashx";
	var paytype = {"01":"现金支付","14":"支付支付宝","15":"微信支付","12":"银行卡"};
	var paystauts = {"1":"支付成功","0":"支付中","3":"支付失败"};
	var query = 0;
	var ordersn = 0;
	function MsgBox(msg){
		$(".container").hide();
		$("#UnionPayInfo").html(msg);   
		$("#UnionPayInfo").show();
		//setTimeout(function(){
		//	$("#UnionPayInfo").fadeOut(2000);
		//},2000); 
	}
	function PaySuccess(amount){	
		$("#UnionPayInfo").hide();
		$(".mask-layer").hide();		
		
		$("input[name='Fkid']").val("-21");
		$("#Fkfs").val("银联卡");
		$("#Fkje").val(amount);
		Blur("Fkje", amount);
		
	}
	function GetStatus(){
		$.ajax({
			type: "GET",
			url: _url,
			data: {
				sn: ordersn,
				act: "PayStatus",
				ver :  Math.round(Math.random() * 10000)
			},
			success: function (msg) {
				query++;
				var rel = JSON2.parse(msg);			
				$("#UnionPayInfo").html("订单号：" + ordersn + " " + paystauts[rel.status] + query + "S");
				if(rel.status == 1){
					PaySuccess(rel.amount);
					return;
				};
				if(rel.status == 3){
					MsgBox("支付失败");
					setTimeout(function(){					
					    $("#UnionPayInfo").hide();
		  				$(".mask-layer").hide();
					},1000);
					return;
				};
				if(rel.status == 0){
					setTimeout(function(){					
					    GetStatus();
					},1000);
				}                    
			}
		});
	};
	function list(){
		var id = $("#intID").val();
		$.ajax({
			type: "GET",
			url: _url,
			data: {
				id: id,
				act: "OrderList",
				ver: Math.round(Math.random() * 10000)
			},
			success: function (msg) {
				var rel = JSON2.parse(msg);
				if(rel.code == 200){
					$("#OrderList").html("");
					for(var i = 0; i < rel.data.length; i++){
						var _status = paystauts[rel.data[i].status];
						if(rel.data[i].isRefund)
						    _status = "消费撤销";
					    var html = "<tr><td>" + paytype[rel.data[i].channel] + 
						"</td><td>" + rel.data[i].orderNo +
						"</td><td class=\"price\">" + rel.data[i].amount +
						"</td><td>"+_status + 
						"</td><td class=\"cancel\" onClick=\"UnionPay.refund("+rel.data[i].orderNo+")\">撤销</td></tr>";
						$("#OrderList").append(html);
					}			
				}                
			}
		});
	}
	return{
		init:function(){
			var contop_dis = $(".container").outerHeight() / 2;
	        $(".container").css("margin-top", -contop_dis);
			// 关闭按钮
			$(".closeBtn").on("click", function () {
				$(".mask-layer").hide();
				$(".container").hide();
			});			
			// 选择支付方式
			$(".pay-type-list li").on("click", function () {
				$(".pay-type-list li").find(".circle").attr("src", "img/circle-icon.png");
				$(this).find(".circle").attr("src", "img/radio-icon.png");
				PayChannel = $(this).attr("val");
			});			
			// 撤销
			$(".cancel").on("click", function () {
				$(this).parent("tr").remove();
			});
			$("#BtnPay").click(function(e) {
				UnionPay.pay();
            });  
		},
		showMask:function(){
			if($("#ButtonPrint").attr("disabled") != "disabled"){
				list();
				$(".mask-layer").show();
				$(".container").show();
			}
			else
			    alert("请先点击结算按钮");
		},
		refund : function(_ordersn){
			$.ajax({
				type: "GET",
				url: _url,
				data: {
					sn: _ordersn,
					act: "refund",
					ver :  Math.round(Math.random() * 10000)
				},
				success: function (msg) {
					var rel = JSON2.parse(msg);
					if(rel.code == 200)
					    MsgBox("请在POS终端完成操作");
					else
					    MsgBox(rel.msg);  
					setTimeout(function(){					
					    $("#UnionPayInfo").hide();
		  				$(".mask-layer").hide();
					},2000);         
				}
			});
		},
		pay : function(){
			query = 0;
			var id = $("#intID").val();
			var amount = $("#TxtPayMoney").val();	
			//判断已经足额支付
			var debit = $("#Ysk").val();//借方		
			var payment = Number($("#Ssk").val()) + Number(amount);
			/*if(payment >= debit){
				PaySuccess(amount);
				$("#ButtonPrint").trigger("click");
				return;
			}*/
			$.ajax({
				type: "GET",
				url: _url,
				data: {
					id: id,
					channel :PayChannel,
					je: amount,
					act: "pay",
					ver: Math.round(Math.random() * 10000)
				},
				success: function (msg) {
					$("#UnionPayInfo").html(msg);
					var rel = JSON2.parse(msg);
					if(rel.code == 200){
						ordersn = rel.ordersn;
						MsgBox(ordersn+" 请在POS终端完成操作。");
						setTimeout(function(){					
							GetStatus();
						},1000);						
						//PaySuccess(amount);
						//$("#ButtonPrint").trigger("click");
					}
					else
						MsgBox(rel.msg);                
				}
			});
		}
	}
})();