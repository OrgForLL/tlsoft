<%@ Page Title="" Language="C#" MasterPageFile="../../WebBLL/frmQQDBase.Master" AutoEventWireup="true" %>

<%@ MasterType VirtualPath="../../WebBLL/frmQQDBase.Master" %>

<%@ Import Namespace="nrWebClass" %>
<script runat="server">
    public string ryid = "";
    public string mdid = "";
    protected void Page_PreRender(object sender, EventArgs e)
    {
        string SystemKey = this.Master.AppSystemKey;
        string ConWX = ConfigurationManager.ConnectionStrings["Conn"].ConnectionString; //连接62
        using (LiLanzDALForXLM dalWX = new LiLanzDALForXLM(ConWX))
        {
            string strSQL = string.Format(@"SELECT TOP 1 RelateID,B.mdid FROM wx_t_OmniChannelUser A
                            INNER JOIN Rs_T_Rydwzl B ON A.RelateID = B.ID
                            WHERE A.ID = {0}", SystemKey);
            System.Data.DataTable dt;
            string strInfo = dalWX.ExecuteQuery(strSQL, out dt);
            if (strInfo == "")
            {
                if (dt.Rows.Count > 0)
                {
                    ryid = Convert.ToString(dt.Rows[0]["RelateID"]);
                    mdid = Convert.ToString(dt.Rows[0]["mdid"]);
                }
                dt.Rows.Clear(); dt.Dispose();
            }

        }
    }

    //必须在内容页的Load中对Master.SystemID 进行赋值；
    protected void Page_Load(object sender, EventArgs e)
    {
        
    }

</script>

<asp:Content ID="Content1" ContentPlaceHolderID="head" runat="server">
    <meta charset="utf-8" />
    <meta name="viewport" content="height=device-height,width=device-width,initial-scale=1.0,minimum-scale=1.0,maximum-scale=1.0,user-scalable=no" />
    <meta name="format-detection" content="telephone=no" />
    <title>个人业绩目标设置</title>
    <link rel="stylesheet" href=""../../res/css/weui.min.css" />
    <link type="text/css" rel="stylesheet" href="../../res/css/font-awesome.min.css" />
    <style type="text/css">
        *
        {
            margin: 0px;
            padding: 0px;
        }

        ul li
        {
            list-style: none;
        }

        body
        {
            font-size: 1.2em;
            font-family: Helvetica,Arial,"Hiragino Sans GB","Microsoft Yahei","微软雅黑",STHeiti,"华文细黑",sans-serif;
            background-color:#eee;
        }


        .page_title
        {
            height: 40px;
            line-height: 40px;
            margin: 10px auto 10px auto;
            padding-top: 5px;
            padding-bottom: 5px;
            text-align: center;
            font-size: 1.4em;
            color: #3cc51f;
            font-weight: 400;
            width: 100%;
        }



        .totalGoal
        {
            position: relative;
            margin: 15px auto 15px auto;
            height: 120px;
            width: 80%;
            border: 1px solid #3cc51f;
            border-radius: 5px;
        }

            .totalGoal div
            {
                position: relative;
                padding-right: 12px;
                left: 30px;
                height: 40px;
                line-height: 40px;
                text-align: right;
                float: left;
                box-sizing: border-box;
            }

        .myGoal
        {
            position: relative;
            height: 40px;
            width: 80%;
            margin: 15px auto 15px auto;
            border: 1px solid #3cc51f;
            border-radius: 5px;
            line-height: 40px;
        }

            .myGoal div
            {
                position: relative;
                padding-right: 12px;
                left: 30px;
                height: 40px;
                line-height: 40px;
                text-align: right;
                float: left;
                box-sizing: border-box;
            }






        .changeMonth
        {
            position:relative;
            border: 1px solid #3cc51f;            
            width:100%;

        }
            .changeMonth span
            {
                text-align:center;
            }
            
        .add
        {
            position:absolute;
            width:25px; 
            left:110px;      
            font-size:22px;

        }
        .nYear
        {
            position:absolute;
            left:30px;
            width:50px;
            color:#f00;
        }
        .nMonth
        {
            position:absolute;         
            width:25px;
            left:80px;
            color:#f00;
        }
        .minus
        {
            position:absolute;
            left:2px;   
            width:25px;
            font-size:22px;           
        }
    </style>
</asp:Content>
<asp:Content ID="Content2" ContentPlaceHolderID="ContentPlaceHolder1" runat="server">
    <div class="container">
        <p class="page_title">个人业绩目标设置</p>

        <div class="totalGoal">
            <div style="width: 35%;">&nbsp;月&nbsp;&nbsp;&nbsp;份</div>
            <div style="width: 65%; text-align: left; border:1px;" class="changeMonth">               
                <span class="minus" onclick="minusMonth()"><i class="fa fa-minus-square"></i></span>
                <span class="nYear" id="nYear"></span>
                <span class="nMonth" id="nMonth"></span>
                <span class="add" onclick="addMonth()"><i class="fa fa-plus-square"></i></span>
            </div>
            <div style="width: 35%;">本店目标</div>
            <div id="totalGoal" style="width: 65%; text-align: left;color:#f00;">暂未设置</div>


            <div style="width: 35%;">我的目标</div>
            <div id="myGoal" style="width: 65%; text-align: left;color:#f00;">暂未设置</div>
        </div>
  
            <div class="myGoal">
                <div style="width: 45%;">业绩目标(万)</div>
                <div style="width: 55%; text-align: left; height:30px;"><input id="saleTarget" style="height:80%;width:auto;" type="number" placeholder="支持一位小数，如5.1"  /></div>
            </div>
            <input type="button" id="showToast" onclick="saveSaleTarget()" value="提 交" style="width: 80%; height: 40px;" class="weui_btn weui_btn_plain_primary" />
            <input type="button" id="backBtn" onclick="history.go(-1);" value="返 回" style="width: 80%; height: 40px;" class="weui_btn weui_btn_plain_primary" />

    </div>
    
    <div class="footer"></div>
    <script type="text/javascript" src="../../res/js/jquery.js"></script>
    <script type="text/javascript">
            Date.prototype.Format = function (fmt) {
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

            function GetWan(y) {
                var rt;
                if (isNaN(y)) {
                    rt = y;
                } else {
                    var vvv = parseInt(y) * 0.0001;
                    if (vvv < 10) {
                        rt = y;
                    } else {
                        vvv = parseInt(vvv);
                        rt = vvv.toString() + "万";
                    }
                }

                return rt;
            }

            function minusMonth() {
                var cMonth = parseInt($("#nMonth").text());
                var cYear = parseInt($("#nYear").text());
                //alert(cMonth);
                var sMonth = cMonth - 1;
                if (sMonth < 1) {
                    sMonth = sMonth + 12;
                    cYear = cYear - 1;
                }
                $("#nMonth").html(sMonth < 10 ? "0" + sMonth : sMonth);
                $("#nYear").html(cYear);
                //alert(sMonth);
                ShowLoading("正在加载");
                getSaleTarget(cYear, sMonth);
            }

            function addMonth() {
                var cMonth = parseInt($("#nMonth").text());
                var cYear = parseInt($("#nYear").text());
                //alert(cMonth);
                var sMonth = cMonth + 1;
                if (sMonth > 12) {
                    sMonth = sMonth - 12;
                    cYear = cYear + 1;
                }
                $("#nMonth").html( sMonth<10 ? "0"+sMonth : sMonth);
                $("#nYear").html(cYear);
                //alert(sMonth);
                ShowLoading("正在加载");
                getSaleTarget(cYear, sMonth);
            }

          
            

            $(document).ready(function () {


                var tYear = new Date().getFullYear();
                var tMonth = new Date().getMonth() + 1;
                $("#nYear").html(tYear);
                $("#nMonth").html((tMonth < 12) ? ("0" + tMonth) : tMonth);
                ShowLoading("正在加载");
                getSaleTarget(tYear, tMonth);

            });

            function getSaleTarget(nYear, nMonth) {

                var ny = new Date(nYear, nMonth - 1).Format("yyyyMM");

                $.ajax({
                    url: "saleTargetCore.aspx?ctrl=getSaleTarget",
                    type: "POST",
                    data: { "mdid": "<%= mdid%>", "ryid": "<%= ryid%>", "nYear": nYear, "nMonth": nMonth, "ny": ny },
                    dataType: "HTML",
                    timeout: 15000,
                    error: function (XMLHttpRequest, textStatus, errorThrown) {
                        alert(errorThrown);
                    },
                    success: function (result) {
                        HideLoading();
                        var obj = JSON.parse(result);
                        if (obj.rows[0].je == 0) {
                            $("#totalGoal").html("暂未设置");
                        }
                        else {
                            $("#totalGoal").html(GetWan(parseInt(obj.rows[0].je)));
                        }

                        if (obj.rows[0].SaleTarget == 0) {
                            $("#myGoal").html("暂未设置");
                            $("#saleTarget").focus();
                        } else {
                            $("#myGoal").html(parseFloat(obj.rows[0].SaleTarget).toFixed(1) + "万");
                        }
                    }
                });
            }

            function saveSaleTarget() {                
                var saleTarget = $("#saleTarget").val();
                if (saleTarget == "") {
                    alert("请填写业绩目标");
                    return;
                }
                if (parseFloat(saleTarget).toFixed(1) <= 0) {
                    alert("业绩目标非法");
                    return;
                }
                nYear = $("#nYear").text();
                nMonth = $("#nMonth").text();

                $.ajax({
                    url: "saleTargetCore.aspx?ctrl=saveSaleTarget",
                    type: "POST",
                    data: { "mdid": "<%= mdid%>", "ryid": "<%= ryid%>", "nYear": nYear, "nMonth": nMonth, "saleTarget": saleTarget },
                    dataType: "HTML",
                    timeout: 15000,
                    error: function (XMLHttpRequest, textStatus, errorThrown) {
                        alert(errorThrown)
                    },
                    success: function (result) {
                        ShowInfo("设置成功");
                    
                        getSaleTarget(nYear, nMonth);
                    }
                });
            }
    </script>

</asp:Content>
