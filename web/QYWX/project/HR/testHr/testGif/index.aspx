<!DOCTYPE html>
<html lang="en">
	<head>
		<meta charset="UTF-8" />
		<title>FANTASTICの夜</title>
		<meta name="viewport" content="width=device-width, initial-scale=1, maximum-scale=1, user-scalable=no">
		<meta name="apple-mobile-web-app-capable" content="yes">  
		<meta name="apple-mobile-web-app-status-bar-style" content="black">  
		<meta content="telephone=no,email=no" name="format-detection">
		<link rel="stylesheet" href="css/custom.css" />
		<script src="js/modernizr.custom.js"></script>
	</head>
	<body>
		<div class="container demo-2">
			<div id="slider" class="sl-slider-wrapper">
				<div class="sl-slider">
					
					<div class="sl-slide" data-orientation="horizontal" data-slice1-rotation="-25" data-slice2-rotation="-25" data-slice1-scale="2" data-slice2-scale="2">
						<div class="sl-slide-inner">
							<div class="bg-img bg-img-1"></div>
						</div>
					</div>

                    <div class="sl-slide" data-orientation="horizontal" data-slice1-rotation="3" data-slice2-rotation="3" data-slice1-scale="2" data-slice2-scale="1">
                        <div class="sl-slide-inner">
                            <div class="bg-img bg-img-2"></div>            
                        </div>
                    </div>

<!-- 					<div class="sl-slide" data-orientation="vertical" data-slice1-rotation="10" data-slice2-rotation="-15" data-slice1-scale="1.5" data-slice2-scale="1.5">
						<div class="sl-slide-inner">
							<div class="bg-img bg-img-2"></div>
							<div class="deco" data-icon="t"></div>
							<h2 style="padding-top:10px;padding-bottom:0;margin:150px auto 0;width:90%;">前海梦想小镇 三大创新<p class="text_title"><a href="http://app.aimapp.net/wx/business/app/index/525e5666a8b3ac75e50007d6/home#piao.qq.com" class="btn_back"></a></p></h2>
							<blockquote style="width:90%;margin:0 auto;">
								<p>
									要以合作、共赢的精神，不要固有成见的壁垒；
									要营造共享、开放的氛围，不要封闭、排他的独占；
									要建立公共价值最大化的小镇价值观，不要私有价值的独尊；利他才是最好的利己；
								</p><cite style="padding-top:10px;">观念创新</cite>
							</blockquote>
						</div>
					</div> -->

					<div class="tc"><img class="arrowBtn" src="images/arrowBtn.png" alt="" /></div>
					
				</div>
			</div>
		</div>
		<audio id="bgaudio" loop src="mp3/FANTASTIC.mp4"></audio>
		<script src="js/jquery-1.10.0.min.js"></script>
		<script src="js/jquery.ba-cond.min.js"></script>
		<script src="js/jquery.slitslider.js"></script>
		<script src="js/jquery.touchSwipe.min.js"></script>
		<script type="text/javascript" src="http://res.wx.qq.com/open/js/jweixin-1.0.0.js"></script>
		<script>
			$(function() {
				$('.sl-slider-wrapper').height($(window).height());
				var Page = (function() {
					var $nav = $('#nav-dots > span'), slitslider = $('#slider').slitslider({
						//interval : 2000, //自动播放时间间隔
						//autoplay : true, //是否自动播放
						onBeforeChange : function(slide, pos) {
							$nav.removeClass('nav-dot-current');
							$nav.eq(pos).addClass('nav-dot-current');
						}
					})
					
					$('body').swipe({
						swipeUp : function(event, direction, distance, duration, fingerCount) {
							slitslider.next();
						},
						swipeDown : function(event, direction, distance, duration, fingerCount) {
							slitslider.previous();
						}
					});
				})();
			});
			$(document).ready(function(e) {
                var bgaudio = document.getElementById('bgaudio');
				bgaudio.play();		
				wx.config({
					debug: false, 
					appId: 'wxc368c7744f66a3d7', // 必填，公众号的唯一标识
					timestamp: '', // 必填，生成签名的时间戳
					nonceStr: '', // 必填，生成签名的随机串
					signature: '', // 必填，签名，见附录1
					jsApiList: [
					'onMenuShareTimeline',
					'onMenuShareAppMessage'
					] // 必填，需要使用的JS接口列表，所有JS接口列表见附录2
				});
				wx.ready(function () {                            
					var sharelink = "http://tm.lilanz.com/Hr/testHr/testGif/index.html";
					//分享给朋友
					wx.onMenuShareAppMessage({
						title: 'FANTASTICの夜', // 分享标题
						desc: 'FANTASTICの夜', // 分享描述
						link: sharelink, // 分享链接                    
						imgUrl: 'http://tm.lilanz.com/img/012.jpg', // 分享图标
						type: '', // 分享类型,music、video或link，不填默认为link
						dataUrl: '', // 如果type是music或video，则要提供数据链接，默认为空
						success: function () {
							// 用户确认分享后执行的回调函数
						},
						cancel: function () {
							// 用户取消分享后执行的回调函数
						}
					});
					//分享到朋友圈
					wx.onMenuShareTimeline({
						title: 'FANTASTICの夜', // 分享标题
						link: 'http://tm.lilanz.com/Hr/testHr/testGif/index.html', // 分享链接
						imgUrl: 'http://tm.lilanz.com/img/012.jpg', // 分享图标
						success: function () {
							// 用户确认分享后执行的回调函数
						},
						cancel: function () {
							// 用户取消分享后执行的回调函数
						}
					});
                });
            });
		</script>
	</body>
</html>