<%@ Page Language="C#" Debug="true" %>
<%@ Import Namespace="nrWebClass" %>
<%@ Import Namespace="System.Collections.Generic" %>
<%@ Import Namespace="System.Data.SqlClient" %>
<%@ Import Namespace="System.Data" %>
<%@ Import Namespace="Newtonsoft.Json" %>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<script runat="server">
    string cfsfConnStr = "server=192.168.35.30;uid=lllogin;pwd=rw1894tla;database=CFSF";
    private List<string> wxConfig = new List<string>();//微信JS-SDK
    private string ConfigKeyValue = "5";
    protected void Page_Load(object sender, EventArgs e)
    {
        string rybh = Convert.ToString(Request.Params["rybh"]);

        
        if (!string.IsNullOrEmpty(rybh))
        {
            string sql = @" SELECT a.AccountNo,CardSnr,CustomerName,b.DeptName,c.ClassName,CONVERT(VARCHAR(10), a.EnDate1,23) EnDate1, CONVERT(VARCHAR(10), a.Endate2,23)  Endate2
  FROM dbo.tb_Customer a 
  INNER JOIN dbo.tb_Department b ON a.DeptNo=b.DeptNo
  INNER JOIN dbo.tb_Class c ON a.ClassNo=c.ClassNo
  WHERE a.CustomerNo=@rybh ";
            List<SqlParameter> para = new List<SqlParameter>();
            para.Add(new SqlParameter("@rybh", rybh));
            DataTable dt;
            using (LiLanzDALForXLM dal = new LiLanzDALForXLM(cfsfConnStr))
            {
                string errInfo = dal.ExecuteQuerySecurity(sql, para, out dt);
                if (errInfo != "" || dt.Rows.Count < 1)
                {
                    clsSharedHelper.WriteErrorInfo(errInfo);
                }
                else
                {
                    clsSharedHelper.WriteSuccessedInfo(JsonConvert.SerializeObject(dt));
                }
            }
        }
        else
        {
            wxConfig = clsWXHelper.GetJsApiConfig(ConfigKeyValue);
        }
    }

</script>
<html xmlns="http://www.w3.org/1999/xhtml">
<head id="Head1" runat="server">
    <meta charset="utf-8" />
    <meta name="viewport" content="width=device-width,initial-scale=1,user-scalable=0,maximum-scale=1" />
    <meta name="format-detection" content="telephone=no" />
    <meta name="apple-mobile-web-app-capable" content="yes" />
    <meta name="apple-mobile-web-app-status-bar-style" content="black" />
    <title>报餐查询</title>
    <link type="text/css" rel="stylesheet" href="../../res/css/LeePageSlider.css" />
    <link type="text/css" rel="stylesheet" href="../../res/css/font-awesome.min.css" />
    <link type="text/css" rel="stylesheet" href="../../res/css/sweet-alert.css" />
    <style type="text/css">
     * {
            margin: 0;
            padding: 0;
            box-sizing: border-box;
        }
        body {
            font-family: Helvetica,Arial,STHeiTi,"Hiragino Sans GB","Microsoft Yahei","微软雅黑",STHeiti,"华文细黑",sans-serif;
            background-color:#D8BFD8
        }
        .content
        {
            text-align:center;
        }
        .scanbtn
        {
            width:180px;
            height:40px;
            margin-top:20px;
            font-size:20px;
            background-color:#CD4F39;
        }
        .lsdjtxt
        {
            margin-top:20px;
            width:80%;
            height:60px; 
            font-size:30px;
        }
        .userinfo{
           display:block;
            margin-top:40px;
            margin-left:10%;
            width:80%;
            height:300px;
            font-size:20px;
            background-color:#EEB4B4;
        }
    </style>
</head>
<script type="text/javascript" src="../../res/js/jquery.js"></script>
<script type="text/javascript" src="../../res/js/sweet-alert.min.js"></script>
<script type="text/javascript" src="http://res.wx.qq.com/open/js/jweixin-1.0.0.js"></script>
<body>
    <div class="content">
      <input type="button" class="scanbtn" onclick="scanQRCode()" value="扫 码" />
      <input type="text" class="lsdjtxt" id="rybh" value="" placeholder="工号" />
      <input type="button" class="scanbtn" onclick="getuserInfo()" value="查 询" />
      <textarea readonly="readonly" id="userInfo" class="userinfo" rows="3" cols="20"></textarea>
    </div>
    <script type="text/javascript">
        var appIdVal = "<%=wxConfig[0]%>", timestampVal = "<%=wxConfig[1]%>", nonceStrVal = "<%=wxConfig[2]%>", signatureVal = "<%=wxConfig[3]%>";
        window.onload = function () {
          //  alert(signatureVal);
            wx.config({
                debug: false, // 开启调试模式,调用的所有api的返回值会在客户端alert出来，若要查看传入的参数，可以在pc端打开，参数信息会通过log打出，仅在pc端时才会打印。
                appId: appIdVal, // 必填，企业号的唯一标识，此处填写企业号corpid
                timestamp: timestampVal, // 必填，生成签名的时间戳
                nonceStr: nonceStrVal, // 必填，生成签名的随机串
                signature: signatureVal, // 必填，签名，见附录1
                jsApiList: ["scanQRCode"] // 必填，需要使用的JS接口列表，所有JS接口列表见附录2
            });
            wx.ready(function () {
               //  alert("注入成功");
            });
            wx.error(function (res) {
               //  alert("JS注入失败！");
            });
        }
        function scanQRCode() {
            $("#rybh").val("");
            wx.scanQRCode({
                needResult: 1, // 默认为0，扫描结果由微信处理，1则直接返回扫描结果，
                scanType: ["barCode", "scanQRCode"],
                success: function (res) {
                    var result = res.resultStr; // 当needResult 为 1 时，扫码返回的结果
                    $("#rybh").val(result);
                    getuserInfo();
                }
            });
        }
        function getuserInfo() {
            var rybh = $("#rybh").val();
            $.ajax({
                type: "POST",
                timeout: 5 * 1000,
                contentType: "application/x-www-form-urlencoded; charset=utf-8",
                url: "dinsearch.aspx?rybh=" + rybh,
                data: {},
                success: function (msg) {
                  //  $("#userInfo").val(msg);
                    if (msg.indexOf("Successed") > -1) {
                        msg = msg.replace("Successed", "");
                        var infojson = JSON.parse(msg);
                        var temp = "账号：#AccountNo \r\n卡内码：#cardSnr \r\n姓名：#cname \r\n部门：#dept \r\n报餐类型：#className \r\n开始时间：#endate1 \r\n结束时间：#endate2";
                        var infostr = "",temp1;
                        for (var i = 0; i < infojson.length; i++) {
                            temp1 = temp.replace("#AccountNo", infojson[i].AccountNo);
                            temp1 = temp1.replace("#cardSnr", infojson[i].CardSnr);
                            temp1 = temp1.replace("#cname", infojson[i].CustomerName);
                            temp1 = temp1.replace("#dept", infojson[i].DeptName);
                            temp1 = temp1.replace("#className", infojson[i].ClassName);
                            temp1 = temp1.replace("#endate1", infojson[i].EnDate1);
                            infostr += temp1.replace("#endate2", infojson[i].Endate2);
                        }
                        $("#userInfo").val(infostr);
                    } else {
                        $("#lsdj").val("未找到该货号价格");
                    }

                },
                error: function (XMLHttpRequest, textStatus, errorThrown) {
                    alert("网络出错");
                }
            });       //end ajax
        }
       
    </script>
</body>
</html>
