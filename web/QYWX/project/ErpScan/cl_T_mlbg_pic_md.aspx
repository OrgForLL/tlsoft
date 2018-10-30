<%@ Page Language="C#" %>
<%@ Import Namespace="nrWebClass" %>
<%@ Import Namespace="System.Data" %>
<%@ Import Namespace="System.Data.SqlClient" %>
<%@ Import Namespace="System.Collections.Generic" %>
<%@ Import Namespace="System.IO" %>
<%@ Import Namespace="WebBLL.Core" %>
<!DOCTYPE html>
<script runat="server">
    protected void Page_Load(object sender, EventArgs e)
    {
         string OAConnStr = clsConfig.GetConfigValue("OAConnStr");
        string url = Request.Url.ToString().ToLower();//转为小写,indexOf 和Replace 对大小写都是敏感的   
        string SystemKey = "";
        string ctrl = Convert.ToString(Request.Params["ctrl"]);
        if (ctrl == "" || ctrl == null)
        {
            if (Request.Url.AbsoluteUri.IndexOf("192.168.35.231") ==-1)
            {
                if (clsWXHelper.CheckQYUserAuth(true))
                {
                    //鉴权成功之后，获取 系统身份SystemKey
                    string SystemID = "1";
                    SystemKey = clsWXHelper.GetAuthorizedKey(Convert.ToInt32(SystemID));    
                }
            }
            WxHelper cs = new WxHelper();
            List<string> config = clsWXHelper.GetJsApiConfig("1");
            appIdVal.Value = config[0];
            timestampVal.Value = config[1];
            nonceStrVal.Value = config[2];
            signatureVal.Value = config[3];
            useridVal.Value = SystemKey;
        }
    }
</script>
<html lang="en" xmlns="http://www.w3.org/1999/xhtml">
<head id="Head1" runat="server">
    <meta charset="utf-8" />
    <meta name="viewport" content="height=device-height,width=device-width,initial-scale=1.0,minimum-scale=1.0,maximum-scale=1.0,user-scalable=no" />
    <meta name="format-detection" content="telephone=yes" />
    <title></title>
    <script type="text/javascript" src="../../res/js/jquery-3.2.1.min.js"></script>
    <script type="text/javascript" src="../../res/js/bootstrap.min.js"></script>
    <script type="text/javascript" src="../../res/js/bootstrap-table.min.js"></script>
    <script type="text/javascript" src="../../api/lilanzAppWVJBridge.js"></script>
    <script type="text/javascript" src="http://res.wx.qq.com/open/js/jweixin-1.0.0.js"></script>
    <link rel="Stylesheet" href="../../res/css/LeePageSlider.css" />
    <link rel="Stylesheet" href="../../res/css/ErpScan/bootstrap.css" />
    <link rel="Stylesheet" href="../../res/css/font-awesome.min.css" />
    <link rel="Stylesheet" href="../../res/css/bootstrap-table.min.css" />
    <link href="../../res/css/sweet-alert.css" rel="stylesheet" type="text/css" />
    <script src="../../res/js/sweet-alert.min.js" type="text/javascript"></script>
    <script type="text/javascript">
        var appIdVal, timestampVal, nonceStrVal, signatureVal;
        $(function () {
            var mykey = getUrlParam("mykey");
            if (mykey != null) {
                //先销毁表格
                $('#table').bootstrapTable('destroy');
                //初始化表格,动态从服务器加载数据
                $("#table").bootstrapTable({
                    method: "get",
                    url: "cl_T_mlbg_pic_md.ashx?mykey=" + mykey,
                    columns: [[
                         {
                             title: '匹号',
                             field: 'ph',
                             align: 'center',
                             valign: 'middle',
                             rowspan: "2"
                         },
                         {
                             title: '缸号',
                             field: 'gh',
                             align: 'center',
                             valign: 'middle',
                             rowspan: "2"
                         },
                         {
                             title: '材料编码',
                             field: 'chdm',
                             align: 'center',
                             valign: 'middle',
                             rowspan: "2"
                         },
                         {
                             title: '材料名称',
                             field: 'chmc',
                             align: 'center',
                             valign: 'middle',
                             rowspan: "2"
                         },
                         {
                             title: '跟踪号',
                             field: 'cggzh',
                             align: 'center',
                             valign: 'middle',
                             rowspan: "2"
                         },
                         {
                             title: '颜色',
                             field: 'ys',
                             align: 'center',
                             valign: 'middle',
                             rowspan: "2"
                         },
                         {
                             title: '码单数量',
                             field: 'sl',
                             align: 'center',
                             valign: 'middle',
                             rowspan: "2"
                         },
                         {
                             title: '幅宽',
                             field: 'fk',
                             align: 'center',
                             valign: 'middle',
                             rowspan: "2"
                         },
                         {
                             title: '有效克重',
                             field: 'kz',
                             align: 'center',
                             valign: 'middle',
                             rowspan: "2"
                         },
                         {
                             title: '分色色系',
                             field: 'jh',
                             align: 'center',
                             valign: 'middle',
                             rowspan: "2"
                         },
                         {
                             title: '利郎色系',
                             field: 'pdjg',
                             align: 'center',
                             valign: 'middle',
                             rowspan: "2"
                         },
                         {
                             title: '货号',
                             field: 'sphh',
                             align: 'center',
                             valign: 'middle',
                             rowspan: "2"
                         },
                         {
                             title: '针织米长',
                             field: 'mc',
                             align: 'center',
                             valign: 'middle',
                             rowspan: "2"
                         },
                         {
                             title: '供应商按缸汽烫',
                             field: 'gysqt',
                             align: 'center',
                             valign: 'middle',
                             colspan: "2"
                         },
                         {
                             title: '供应商按缸水洗',
                             field: 'gyssx',
                             align: 'center',
                             valign: 'middle',
                             colspan: "2"
                         },
                         {
                             title: '备注',
                             field: 'bz',
                             align: 'center',
                             valign: 'middle',
                             rowspan: "2"
                         },
                         {
                             title: '编制量',
                             field: 'bzsl',
                             align: 'center',
                             valign: 'middle',
                             rowspan: "2"
                         },
                         {
                             title: '到货提示',
                             field: 'dhts',
                             align: 'center',
                             valign: 'middle',
                             rowspan: "2"
                         }],
                         [
                         {
                             title: '缩率经值',
                             field: 'khqtj',
                             valign: "middle",
                             align: "center"
                          },
                         {
                             title: '缩率纬值',
                             field: 'khqtw',
                             valign: "middle",
                             align: "center"
                         },
                         {
                             title: '缩率经值',
                             field: 'khsxj',
                             valign: "middle",
                             align: "center"
                         },
                         {
                             title: '缩率纬值',
                             field: 'khsxw',
                             valign: "middle",
                             align: "center"

                         },
                         ]
                    ]
                });
            }
        });
        function getUrlParam(name) {
            var reg = new RegExp("(^|&)" + name + "=([^&]*)(&|$)"); //构造一个含有目标参数的正则表达式对象
            var r = window.location.search.substr(1).match(reg);  //匹配目标参数
            if (r != null) return unescape(r[2]); return null; //返回参数值
        }
    </script>
</head>
<body>
    <table id="table" class="table table-bordered"  data-toggle="table"></table>
    <input type="hidden" runat="server" id="appIdVal" />
    <input type="hidden" runat="server" id="timestampVal" />
    <input type="hidden" runat="server" id="nonceStrVal" />
    <input type="hidden" runat="server" id="signatureVal" />
    <input type="hidden" runat="server" id="useridVal" />
</body>
</html>

