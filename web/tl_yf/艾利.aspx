<%@ Page Language="C#" AutoEventWireup="true" CodeFile="艾利.aspx.cs" Inherits="tl_yf_Default" %>

<!DOCTYPE html>

<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
<meta http-equiv="Content-Type" content="text/html; charset=utf-8"/>
    <title></title>
    <script src="jquery-1.6.1.min.js"></script>
</head>
<body>
    <form id="form1" runat="server">
        <a href="javascript:;" class="doc_btn" data-dir="next" style="display: block; width: 33.33%;">办 理</a>
    <input type="button" onclick="go()" value="submit" />
        <div id="r">
    
    </div>
    </form>
</body>
</html>
<script src="../Scripts/json2.js"></script>
<script type="text/javascript">
    window.onload = function () {
        //tagPick();//测试吊牌分检
        //go();


    }

    $(document).ready(function () {
        $(".doc_btn[data-dir='next']").click(function (e) {
            getNextNodes(e);
        });

        $(".doc_btn[data-dir='next']").click(function () {
            fun2();
        });
    });

    function fun2() {
        console.log(1);
    }
    function getNextNodes(event) {
        console.log("getNextNodes");
         
    }
    function testJSON() {
        $.ajax("ht.aspx?type=getinterfacelist", {//?Method=GetListJson&FormName=GetApplicationFeeList
            data: { status: status },
            dataType: 'json', //服务器返回json格式数据
            type: 'post', //HTTP请求类型				
            success: function (reutrn) {
                alert(reutrn);
           

            },
            error: function (xhr, type, errorThrown) {
                alert(1)
            }
        });
    }
    function Goods(GoodsCode, GoodsSize, Qty) {
        this.GoodsCode = GoodsCode;
        this.GoodsSize = GoodsSize;
        this.Qty = Qty;
    }
    //测试中台
    function go() {
        var id = 1029039;
        var api = "multiStock";
        var tableID = 2;
        var json = new Array();
        json.push(new Goods("6dxk", "cm18", 12));
        json.push(new Goods("7dxf", "cm21", 1));
        $.ajax({
            type: "POST",
            async: true,
            contentType: "application/x-www-form-urlencoded; charset=utf-8",
            url: "mHandler.ashx",
            data: { mykey: id, api: api, tableID: tableID, json: JSON.stringify(json) },
            success: function (winRtn) {                
                document.getElementById("r").innerHTML = winRtn;
            },
            error: function (XMLHttpRequest, textStatus, errorThrown) {                
                document.getElementById("r").innerHTML = "error";
            }
        }); //ajax end
    }

    function tagPick() {
        var data = {};
        data.BeginDate = "2017-10-15";
        data.EndDate = "2017-10-30";        
        $.ajax({
            type: "POST",
            async: true,
            contentType: "application/x-www-form-urlencoded; charset=utf-8",
            url: "mTagPick.ashx",
            data: {data: JSON.stringify(data) },
            success: function (winRtn) {
                document.getElementById("r").innerHTML = winRtn;
            },
            error: function (XMLHttpRequest, textStatus, errorThrown) {
                document.getElementById("r").innerHTML = "error";
            }
        }); //ajax end
    }

</script>
