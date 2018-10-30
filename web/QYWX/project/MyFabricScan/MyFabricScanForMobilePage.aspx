<%@ Page Language="C#" Debug="true"%>
<%@ Import Namespace="nrWebClass" %>
<%@ Import Namespace="System.Security.Cryptography" %>
<%@ Import Namespace="System.Data" %>
<%@ Import Namespace="System.Data.SqlClient" %>
<%@ Import Namespace="System.Collections.Generic" %>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">

<script runat="server">
    string DBConStr = clsConfig.GetConfigValue("OAConnStr");
    private const string ConfigKeyValue = "1";
    public List<string> wxConfig; //微信OPEN_JS 动态生成的调用参数
    protected void Page_Load(object sender, EventArgs e)
    {
        wxConfig = clsWXHelper.GetJsApiConfig(ConfigKeyValue);
    }
</script>

<html xmlns="http://www.w3.org/1999/xhtml">
<head id="Head1" runat="server">
    <meta charset="UTF-8" />
    <meta name="viewport" content="width=device-width,initial-scale=1,user-scalable=0" />
    <meta name="format-detection" content="telephone=no" />
    <meta name="apple-mobile-web-app-capable" content="yes" />
    <link type="text/css" rel="stylesheet" href="../../res/css/LeePageSlider.css" />
    <link type="text/css" rel="stylesheet" href="../../res/css/font-awesome.min.css" />

    <title></title>
   
   <style type="text/css">
        .page {
            background-color: #f0f0f0;
        }
        .footer {
            height:60px;
        }
        .page-not-footer {
            bottom:60px;
            border-top:1px solid #fafafa;
        }
        .title {
            color:#525252;
            text-align:center;
            margin-bottom:20px;            
        }
        .num {
            width: 60%;
            text-align: center;
            border:1px dashed #50bb8d;
            color: #ccc;
            padding: 5px 10px;
            font-size: 16px;
            margin: 0 auto;
            border-radius: 2px;
            box-shadow: 0 1px .5px #eceef1;
            -webkit-box-shadow: 0 1px .5px #eceef1;
            word-wrap:break-word; word-break:normal;
        }
        .mid-line {
            border-right:1px dashed #50bb8d;
            height:10px;
            width:1px;
            margin:0 auto;
        }
        .img-container {
            width:90vw;
            height:90vw;            
            margin:0 auto;
            border-radius:2px;
            border:1px dashed #50bb8d;
            position:relative;
        }
        .img-title {
            line-height:90vw;
            text-align:center;            
            color:#ccc;
            font-size:16px;
            z-index:100;
        }
        .footer {
            font-size:0;            
            text-align:left;
        }
        .footer .f-btn {
            width:47%;
            margin-left:2%;
            margin-top:5px;
            border-radius:2px;            
            background-color:#50bb8d;
            color:#fff;
            display:inline-block;
            font-size:16px;
            height:40px;    
            line-height:40px;
            font-weight:bold;
            text-align:center;        
        }
        #addPicture {
            background-color:rgb(234,150,77);
        }
        .back-image {
            background-position:50% 50%;
            background-repeat:no-repeat;
            background-size:cover;
        }
        #myimg {
            width:100%;
            height:100%;
            z-index:200;
        }
        #choosefile,#mxid
        {
            display:none;
        }
        .descript
        {
            margin-top:15px;
            color:Red;
        }
    </style>
</head>
<body >

   <div class="wrap-page" >
        <div class="page page-not-footer" id="main">
            <h2 class="title">利郎面料扫描模块<sup>1.1</sup></h2>
            <div class="scan-container center-translate">
                <p class="num" >--面料编号--</p>
                <div class="mid-line"></div>
                <div class="img-container">
                    <div class="back-image" id="myimg" style="background-image:url()"></div>
                    <p class="img-title center-translate">- 面料图片 -</p>
                </div>
                <div class="descript" >
                    <p>1、点击添加面料,扫面料二维码获取面料编号;</p>
                    <p>2、点击添加图片,选择拍照或相册图片上传即可。</p>
                </div>
            </div>
            
        </div>
    </div>
      <input type="file" id="choosefile" />
      <input type="text" id="mxid" value="" />
    <div class="footer">
        <a class="f-btn" href="javascript:scanQRCode()" id="addFabric">添加面料</a>
        <a class="f-btn" href="javascript:chooseFile()" id="addPicture" >添加图片</a>
    </div>
     <script type="text/javascript" src="../../res/js/jquery.js"></script>
    <script type="text/javascript" src="../../res/js/storesaler/fastclick.min.js"></script>    
    <script type="text/javascript" src="../../res/js/LeeJSUtils.min.js"></script>
    <script type="text/javascript" src="../../res/js/jweixin-1.0.0.js"></script>
    <script type="text/javascript" src="../../res/js/StoreSaler/LocalResizeIMG.js"></script>
    <script type="text/javascript" src="../../res/js/StoreSaler/mobileBUGFix.mini.js" ></script>
     <script type="text/javascript">
          var appIdVal = "<%=wxConfig[0]%>", timestampVal = "<%=wxConfig[1]%>", nonceStrVal = "<%=wxConfig[2]%>", signatureVal = "<%=wxConfig[3]%>";
          var oRotate = 0;
          window.onload = function () {
              wxConfig();
              FastClick.attach(document.body);
              LeeJSUtils.stopOutOfPage("#main", true);
              LeeJSUtils.stopOutOfPage(".footer", false);
              LeeJSUtils.LoadMaskInit();
             
              $(function () {
                  FastClick.attach(document.body);
              });
          }
          function wxConfig() {//微信js 注入
              wx.config({
                  debug: false, // 开启调试模式,调用的所有api的返回值会在客户端alert出来，若要查看传入的参数，可以在pc端打开，参数信息会通过log打出，仅在pc端时才会打印。
                  appId: appIdVal, // 必填，企业号的唯一标识，此处填写企业号corpid
                  timestamp: timestampVal, // 必填，生成签名的时间戳
                  nonceStr: nonceStrVal, // 必填，生成签名的随机串
                  signature: signatureVal, // 必填，签名，见附录1
                  jsApiList: ["scanQRCode", "previewImage", "onMenuShareTimeline", "onMenuShareAppMessage"] // 必填，需要使用的JS接口列表，所有JS接口列表见附录2
              });
              wx.ready(function () {
                  //   alert("注入成功");
              });
              wx.error(function (res) {
                  // alert("JS注入失败！");
              });
          }

          function scanQRCode() {
              wx.scanQRCode({
                  needResult: 1, // 默认为0，扫描结果由微信处理，1则直接返回扫描结果，
                  scanType: ["barCode", "qrCode"], // 可以指定扫二维码还是一维码，默认二者都有 //, "qrCode"
                  success: function (res) {
                      try {
                          var resultStr = stringToJson(res.resultStr); // 当needResult 为 1 时，扫码返回的结果
                          var result = resultStr.scan_code.scan_result;
                          var rtList = result.split('|');
                          var sqmxid = rtList[1].substr(7);
                          GetFabricCode(sqmxid);
                      } catch (e) {
                          try {
                              var result = res.resultStr;
                              var rtList = result.split('|');
                              var sqmxid = rtList[1].substr(7);
                              GetFabricCode(sqmxid);
                          } catch (e) {
                              LeeJSUtils.showMessage("error", "扫描二维码出错了！");
                          }
                      }
                  }
              });
          }
          function GetFabricCode(mxid) {
              $.ajax({
                  type: "POST",
                  url: "MyFabricScanForMobileCore.aspx?ctrl=GetFabricCode&mxid=" + mxid,
                  timeout: 5000,
                  error: function (xhr, type, exception) {
                      LeeJSUtils.showMessage("error", type + ":" + exception + "网络出错了..");
                  },
                  success: function (res) {
                      LeeJSUtils.showMessage("successed", res);
                      if (res.indexOf("Error") >= 0) {
                          LeeJSUtils.showMessage("error", "未找到相关编号");
                          $("#mxid").val("");
                          $(".num").html("--面料编号--");
                          $(".num").css("color", "#ccc")
                          return false;
                      } else {
                          LeeJSUtils.showMessage("successed", res);
                          $(".num").css("color", "#000")
                          $("#mxid").val(mxid);
                          $(".num").html(res);
                          $("#myimg").css("background-image", "");
                          $(".img-title").show();
                      }
                  }
              });
          }

          function chooseFile() {
              if ($("#mxid").val() == undefined || $("#mxid").val() == "") {
                  LeeJSUtils.showMessage("warn", "请先扫面料二维码后再拍照");
                  return;
              }
              $("#choosefile").trigger("click");
              $("#choosefile").click();
          }
         
          //{大对象 有方法有属性} 图片上传
          $("input:file").localResizeIMG({
              width: 500,
              quality: 0.8,
              before: function (that, blob) {
                  LeeJSUtils.showMessage("loading", "图片上传中..");
                  var filePath = $("#choosefile").val();
                  var extStart = filePath.lastIndexOf(".");
                  var ext = filePath.substring(extStart, filePath.length).toUpperCase();
                  if (ext != ".BMP" && ext != ".PNG" && ext != ".GIF" && ext != ".JPG" && ext != ".JPEG") {
                      LeeJSUtils.showMessage("warn", "只能上传图片");
                      return false;
                  }
                  var orientation = 0;
                  var imgfile = that.files[0];
                  fr = new FileReader;
                  fr.readAsBinaryString(imgfile);
                  fr.onloadend = function () {
                      var exif = EXIF.readFromBinaryFile(new BinaryFile(this.result));
                      if (exif.Orientation == undefined)
                          oRotate = 0;
                      else
                          oRotate = exif.Orientation;
                  };
                  return true;
              },
              success: function (result) {
                  $("#myimg").css("background-image", "url(" + result.base64 + ")");
                  $.ajax({
                      url: "MyFabricScanForMobileCore.aspx?ctrl=SaveImgs&rotate=" + oRotate + "&mxid=" + $("#mxid").val(),
                      type: "POST",
                      data: { formFile: result.clearBase64 },
                      dataType: "HTML",
                      timeout: 30000,
                      error: function (XMLHttpRequest, textStatus, errorThrown) {
                          LeeJSUtils.showMessage("error", "网络出错");
                      },
                      success: function (result) {
                          if (result.indexOf("Error") >= 0) {
                              $("#myimg").css("background-image", "url('')");
                              LeeJSUtils.showMessage("error", "上传失败");
                          } else {
                              LeeJSUtils.showMessage("successed", "上传成功");
                              $(".img-title").hide()
                          }
                      }
                  });
              }
          });
          function stringToJson(stringValue) {
              eval("var theJsonValue = " + stringValue);
              return theJsonValue;
          }
        
        </script>
</body>
</html>
