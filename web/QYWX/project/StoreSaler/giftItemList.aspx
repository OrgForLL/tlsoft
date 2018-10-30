<%@ Page Language="C#" %>

<%@ Import Namespace="nrWebClass" %>
<%@ Import Namespace="System.Data.SqlClient" %>
<%@ Import Namespace="System.Data" %>
<%@ Import Namespace="System.Collections.Generic" %>

<!DOCTYPE html>
<script runat="server">
    public string AppSystemKey = "", CustomerID = "", CustomerName = "", mdid = "", mdmc = "", tzid = "";
    public int SystemID = 3;
    private string DBConstr = clsConfig.GetConfigValue("OAConnStr");

    protected void Page_Load(object sender, EventArgs e)
    {
        if (clsWXHelper.CheckQYUserAuth(true))
        {
            AppSystemKey = clsWXHelper.GetAuthorizedKey(SystemID);
            if (AppSystemKey == "")
                clsWXHelper.ShowError("对不起，您还未开通全渠道系统权限！");
            else
            {                
                CustomerID = Convert.ToString(Session["qy_customersid"]);
                CustomerName = Convert.ToString(Session["qy_cname"]);
                mdid = Convert.ToString(Session["mdid"]);

                using (LiLanzDALForXLM dal10 = new LiLanzDALForXLM(DBConstr))
                {
                    string sql = "select top 1 khid,mdmc from t_mdb where mdid=" + mdid;
                    DataTable dt;
                    string errinfo = dal10.ExecuteQuery(sql, out dt);
                    if (errinfo == "" && dt.Rows.Count > 0)
                    {
                        mdmc = dt.Rows[0]["mdmc"].ToString();
                        tzid = dt.Rows[0]["khid"].ToString();

                        dt.Clear(); dt.Dispose();
                    }
                }//end using           
            }
        }
    }
</script>
<html lang="en" xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <meta charset="utf-8" />
    <meta name="viewport" content="width=device-width,initial-scale=1,user-scalable=0,maximum-scale=1" />
    <meta name="format-detection" content="telephone=no" />
    <meta name="apple-mobile-web-app-capable" content="yes" />
    <meta name="apple-mobile-web-app-status-bar-style" content="black" />
    <title></title>
    <link type="text/css" rel="stylesheet" href="../../res/css/LeePageSlider.css" />
    <link type="text/css" rel="stylesheet" href="../../res/css/font-awesome.min.css" />
    <style type="text/css">
        body {
            color: #363c44;
        }

        .page {
            background-color: #f2f2f2;
            padding: 0 15px 15px 15px;
        }

        .header {
            border-bottom: 1px solid #ddd;
        }

        .activename {
            line-height: 50px;
            font-size: 16px;
            font-weight: 600;
        }

        .header > i {
            position: absolute;
            top: 0;
            left: 0;
            font-size: 26px;
            line-height: 49px;
            padding: 0 15px;
        }

        .header i.fa-plus {
            position: absolute;
            top: 0;
            right: 0;
            left: initial;
            padding: 0 15px;
            line-height: 51px;
            font-size: 24px;
        }

        .item {
            width: 100%;
            background-color: #fff;
            padding: 10px;
            border-radius: 6px;
            border-right: 1px solid #eee;
            border-bottom: 1px solid #eee;
            position: relative;
            margin-top: 50px;
        }

            .item .icon {
                width: 66px;
                height: 66px;
                border-radius: 50%;
                margin: -43px auto 0 auto;
                background-color: #eee;
                border: 3px solid #fff;
                background-image: url(../../res/img/storesaler/gifticon1.png);
                background-size: 80%;
                background-position: center center;
                background-repeat: no-repeat;
            }

        .prizename {
            font-size: 22px;
            text-align: center;
            font-weight: bold;
            line-height: 40px;
            margin-bottom: 5px;
        }

        .remark {
            overflow: hidden;
            text-overflow: ellipsis;
            -webkit-box-orient: vertical;
            -webkit-line-clamp: 2;
            display: -webkit-box;
            text-align: center;
        }

        .onebuymax {
            margin-top: 10px;
            border-top: 1px solid #eee;
            border-bottom: 1px dashed #eee;
            line-height: 36px;
        }

        .maxbuycount, .isactive, .createtime, .buycount,.paypoint {
            border-bottom: 1px dashed #eee;
            line-height: 36px;
        }

        .fitem {
            position: relative;
            display: -webkit-box;
            display: -webkit-flex;
            display: flex;
            -webkit-box-align: center;
            -webkit-align-items: center;
            align-items: center;
        }

            .fitem .label {
                width: 120px;
            }

            .fitem .value {
                -webkit-box-flex: 1;
                -webkit-flex: 1;
                flex: 1;
                text-align: right;
                color: #ff6a00;
            }

        .buycount.fitem .value > span {
            padding: 2px 8px;
            background-color: #63b359;
            color: #fff;
            border-radius: 2px;
        }
        /*radio style*/
        .isactive .checkbox-switch {
            display: none;
        }

        .switch {
            box-shadow: rgb(255, 255, 255) 0px 0px 0px 0px inset;
            border: 1px solid rgb(223, 223, 223);
            transition: border 0.4s, box-shadow 0.4s;
            background-color: rgb(255, 255, 255);
            width: 46px;
            height: 24px;
            border-radius: 20px;
            line-height: 24px;
            display: inline-block;
            vertical-align: middle;
            cursor: pointer;
            box-sizing: content-box;
            outline: none;
        }

            .switch small {
                width: 24px;
                height: 24px;
                top: 0;
                border-radius: 100%;
                text-align: center;
                display: block;
                background: #fff;
                box-shadow: 0 1px 3px rgba(0,0,0,.4);
                -webkit-transition: all .2s;
                transition: all .2s;
                overflow: hidden;
                color: #000;
                font-size: 12px;
                position: relative;
                -webkit-user-select: none;
                user-select: none;
                -webkit-tap-highlight-color: transparent;
            }

            .switch.open small {
                left: 22px;
                background-color: rgb(255, 255, 255);
            }

            .switch.open {
                box-shadow: rgb(100, 189, 99) 0px 0px 0px 16.6667px inset;
                border: 1px solid rgb(100, 189, 99);
                transition: border 0.4s, box-shadow 0.4s, background-color 1.4s;
                background-color: rgb(100, 189, 99);
            }

        .noresult {
            color: #999;
        }

        #itemPage {
            display: -webkit-box;
            display: -webkit-flex;
            display: flex;
            -webkit-box-align: center;
            -webkit-align-items: center;
            align-items: center;
        }

        /*itemPage*/
        .in_prizename .label, .in_remark .label {
            font-weight: 600;
            line-height: 28px;
        }

        input {
            border: 1px solid #eee;
            width: 100%;
            height: 38px;
            line-height: 36px;
            padding: 0 10px;
            border-radius: 0;
            font-size: 14px;
            -webkit-tap-highlight-color: rgba(0, 0, 0, 0);
            background-color: transparent;
            border-radius: 4px;
        }

        #saveBtn {
            background-color: #63b359;
            color: #fff;
            font-weight: 600;
            display: block;
            text-align: center;
            margin-top: 10px;
            padding: 8px 0;
            border-radius: 4px;
            font-size: 16px;
        }

        #itemPage .fa {
            background-color: #63b359;
            color: #fff;
            width: 66px;
            height: 66px;
            border-radius: 50%;
            margin: -43px auto 0 auto;
            border: 3px solid #fff;
            display: block;
            line-height: 66px;
            text-align: center;
        }
            #itemPage .fa.fa-edit {
                background-color:#363c44;
            }
        .item .gift_qrcode {
            width:32px;
            height:32px;
            border:1px solid #ddd;
            position:absolute;
            top:10px;
            left:18px;
            border-radius:4px;
            background-repeat:no-repeat;
            background-size:cover;
            background-image:url(../../res/img/storesaler/spi_gift.png);
        }
        .item .gift_edit {
            width:32px;
            height:32px;
            border:1px solid #ddd;
            position:absolute;
            top:10px;
            right:18px;
            border-radius:4px;
            background-repeat:no-repeat;
            background-size:cover;
            background-image:url(../../res/img/storesaler/spi_gift.png);
            background-position:0 -31px;
        }
         .item .gift_txt {
            position: absolute;
            top: 45px;
            font-size: 12px;
        }
    </style>
</head>
<body>
    <div class="header">
        <i class="fa fa-angle-left"></i>
        <p class="activename">编辑礼品</p>
        <i class="fa fa-plus"></i>
    </div>
    <div class="wrap-page">
        <div class="page page-not-header" id="index">
            <div class="gift_wrap">
                <!--<div class="item">
                    <div class="icon"></div> 
                    <div class="gift_qrcode"></div>                   
                    <p class="prizename">礼品名称</p>
                    <p class="remark">备注信息</p>                    
                    <div class="onebuymax fitem">
                        <div class="label">单人最多兑换次数</div>
                        <div class="value">不限</div>
                    </div>                    
                    <div class="maxbuycount fitem">
                        <div class="label">最多允许兑换次数</div>
                        <div class="value">不限</div>
                    </div>
                    <div class="isactive fitem">
                        <div class="label">启用状态</div>
                        <div class="value">
                            <input type="checkbox" class="checkbox-switch" />
                            <span class="switch" data-open="0"><small></small></span>
                        </div>
                    </div>
                    <div class="createtime fitem">
                        <div class="label">创建时间</div>
                        <div class="value" style="color: #aaa;">2016-12-12 12:30:20</div>
                    </div>                    
                    <div class="buycount fitem" style="border-bottom: none;">
                        <div class="label">已消费次数</div>
                        <div class="value"><span>1024</span></div>
                    </div>
                </div>-->
            </div>
            <p class="noresult center-translate">暂时还未定义礼品项..</p>
        </div>

        <!--礼品项编辑、添加-->
        <div class="page page-not-header page-right" id="itemPage">
        </div>
    </div>

    <!--模板区-->
    <script type="text/html" id="giftItem_temp">
        <div class="item" data-id="{{ID}}">
            <div class="icon"></div>
            <div class="gift_qrcode"></div>
            <span class="gift_txt">领取礼品</span>
            <div class="gift_edit"></div>
            <span class="gift_txt" style="right:21px">编辑</span>
            <p class="prizename">{{PrizeName}}</p>
            <p class="remark">{{Remark}}</p>
            <!--单人最多允许兑换次数 0表示不限-->
            <div class="onebuymax fitem">
                <div class="label">单人最多兑换次数</div>
                <div class="value">{{if OneBuyMaxCount == "0" }}不限{{ else }}{{ OneBuyMaxCount }}次{{/if}}</div>
            </div>
            <!--最多允许兑换次数 0表示不限-->
            <div class="maxbuycount fitem">
                <div class="label">最多允许兑换次数</div>
                <div class="value">{{if MaxBuyCount == "0" }}不限{{ else }}{{ MaxBuyCount }}次{{/if}}</div>
            </div>
            <!--单次支付点数-->
            <div class="paypoint fitem">
                <div class="label">单次兑换消费点数</div>
                <div class="value">{{PayPoint}}</div>
            </div>
            <div class="isactive fitem">
                <div class="label">启用状态</div>
                <div class="value">
                    <input type="checkbox" class="checkbox-switch" />
                    <span class="switch {{if IsActive == "1"}}open{{/if}}" data-open="{{IsActive}}"><small></small></span>
                </div>
            </div>
            <div class="createtime fitem">
                <div class="label">创建时间</div>
                <div class="value" style="color: #aaa;">{{CreateTime}}</div>
            </div>
            <!--消费次数-->
            <div class="buycount fitem" style="border-bottom: none;">
                <div class="label">已消费次数</div>
                <div class="value"><span>{{BuyCount}}</span></div>
            </div>
        </div>
    </script>

    <script type="text/html" id="newItem">
        <div class="item" style="margin-top: -10px;" data-id="0">
            <i class="fa fa-3x fa-plus"></i>
            <div class="in_prizename">
                <p class="label">礼品名称</p>
                <input type="text" placeholder="输入礼品名称.." id="new_pname" />
            </div>
            <div class="in_remark">
                <p class="label">备注信息</p>
                <input type="text" placeholder="输入礼品描述.." id="new_remark" />
            </div>
            <div class="onebuymax fitem" style="padding-top: 10px;">
                <div class="label">单人最多兑换次数</div>
                <div class="value">
                    <input type="text" value="1" id="new_obm" placeholder="0代表不限" style="border: none; text-align: right;" />
                </div>
            </div>
            <div class="maxbuycount fitem">
                <div class="label">最多允许兑换次数</div>
                <div class="value">
                    <input type="text" id="new_mbc" placeholder="0代表不限" style="border: none; text-align: right;"/>
                </div>
            </div>
            <div class="paypoint fitem">
                <div class="label">单次兑换消费点数</div>
                <div class="value">
                    <input type="number" id="new_pp" value="1" style="border: none; text-align: right;"/>
                </div>
            </div>
            <div class="isactive fitem">
                <div class="label">启用状态</div>
                <div class="value">
                    <input type="checkbox" class="checkbox-switch" />
                    <span class="switch open" data-open="1"><small></small></span>
                </div>
            </div>
            <a href="javascript:SaveForm();" id="saveBtn">保 存</a>
        </div>
    </script>
    <script type="text/javascript" src="../../res/js/jquery.js"></script>
    <script type="text/javascript" src="../../res/js/storesaler/fastclick.min.js"></script>
    <script type="text/javascript" src="../../res/js/template.js"></script>
    <script type="text/javascript" src="../../res/js/LeeJSUtils.min.js"></script>

    <script type="text/javascript">
        var tid = "", isProcess = false, currentPage = "index";
        var userid = "<%=CustomerID%>", username = "<%=CustomerName%>";

        $(document).ready(function () {
            LeeJSUtils.LoadMaskInit();
            FastClick.attach(document.body);

            BindEvents();
            init();
        });

        function init() {
            tid = LeeJSUtils.GetQueryParams("tid");
            if (isNaN(tid)) {
                LeeJSUtils.showMessage("error", "请检查参数！ tid");
                isProcess = true;
            } else {
                loadGiftItems();
            }
        }

        //加载活动礼品信息
        function loadGiftItems() {
            LeeJSUtils.showMessage("loading", "正在加载..");
            setTimeout(function () {
                isProcess = true;
                $.ajax({
                    type: "POST",
                    cache: false,
                    timeout: 5 * 1000,
                    data: { ActiveTokenID: tid },
                    contentType: "application/x-www-form-urlencoded; charset=utf-8",
                    url: "/OA/project/storesaler/wxActiveTokenCore.ashx?ctrl=LoadPrizeInfo",
                    success: function (msg) {
                        if (msg.indexOf("Error:") > -1)
                            LeeJSUtils.showMessage("error", msg.replace("Error:", ""));
                        else {
                            //console.log(msg);
                            var data = JSON.parse(msg);
                            if (data.list.length > 0) {
                                var html = "";
                                for (var i = 0; i < data.list.length; i++) {
                                    var row = data.list[i];
                                    html += template("giftItem_temp", row);
                                }//end for
                                $(".gift_wrap").empty().html(html);
                                $(".noresult").hide();
                            }
                            $("#leemask").hide();
                            isProcess = false;
                        }
                    },
                    error: function (XMLHttpRequest, textStatus, errorThrown) {
                        isProcess = false;
                        LeeJSUtils.showMessage("error", "您的网络出问题啦..");
                    }
                });
            }, 50);
        }

        function BindEvents() {
            //状态设置
            $(".gift_wrap").on("click", ".switch", function () {
                setIsActive(this);
            });

            //点击二维码跳转
            $(".gift_wrap").on("click", ".gift_qrcode", function () {
                var gid = $(this).parent().attr("data-id");
                window.location.href = "giftQRCode.aspx?pid=" + gid;
            });

            $("#itemPage").on("click", ".switch", function () {
                var status = $(this).attr("data-open");
                if (status == "1") {
                    $(this).attr("data-open", "0");
                    $(this).removeClass("open");
                } else {
                    $(this).attr("data-open", "1");
                    $(this).addClass("open");
                }
            });

            //新增
            $(".header .fa-plus").click(function () {
                $("#itemPage").empty().html(template("newItem", {}));
                $("#itemPage").removeClass("page-right");
                currentPage = "create";
                $(this).fadeOut(200);
            });

            //返回动作
            $(".header .fa-angle-left").click(backFunc);

            //编辑模式
            //点击二维码跳转
            $(".gift_wrap").on("click", ".gift_edit", function () {
                var gid = $(this).parent().attr("data-id");
                var $that = $(this).parent();
                $("#itemPage").empty().html(template("newItem", {}));

                //填充数据
                $("#new_pname").val($(".prizename", $that).text());
                $("#new_remark").val($(".remark", $that).text());
                $("#new_obm").val($(".onebuymax .value", $that).text().replace("次", ""));
                $("#new_mbc").val($(".maxbuycount .value", $that).text().replace("次", ""));
                $("#new_pp").val($(".paypoint .value", $that).text());

                var isactive = $(".isactive .switch", $that).attr("data-open");
                var obj = $("#itemPage .switch");
                if (isactive == "1") {
                    obj.attr("data-open", "1");
                    obj.addClass("open");
                } else {
                    obj.attr("data-open", "0");
                    obj.removeClass("open");
                }
                $("#itemPage .item").attr("data-id", gid);
                $("#itemPage .item .fa").removeClass("fa-plus").addClass("fa-edit");
                $("#saveBtn").css("background-color", "#363c44");
                $("#itemPage").removeClass("page-right");
                currentPage = "create";
                $(".header .fa-plus").fadeOut(200);
            });
        }

        //保存表单信息
        /*
        {
            "ID": "2048",
            "ActiveTokenID": "125",
            "PrizeName": "圣诞蛋糕",
            "Remark": "说明文字",
            "MaxBuyCount": "1",
            "PayPoint": "1",
            "CreateCustomersID": "587",
            "CreateName": "薛灵敏"
        }
        */
        function SaveForm() {
            if (isProcess)
                return;
            var id = $("#itemPage .item").attr("data-id");
            var prizename = $("#new_pname").val().trim();
            var remark = $("#new_remark").val().trim();
            var onebuymax = $("#new_obm").val().trim();
            onebuymax = onebuymax == "不限" ? "0" : onebuymax;
            var maxbuycount = $("#new_mbc").val().trim();
            maxbuycount = maxbuycount == "不限" ? "0" : maxbuycount;
            var isactive = $("#itemPage .switch").attr("data-open");
            var paypoint = $("#new_pp").val().trim();

            if (prizename == "") {
                LeeJSUtils.showMessage("error", "礼品名称不能为空！");
                return false;
            } else if (onebuymax == "") {
                LeeJSUtils.showMessage("error", "单人最多允许兑换次数不能为空（0代表不限）！");
                return false;
            } else if (isNaN(onebuymax)) {
                LeeJSUtils.showMessage("error", "单人最多允许兑换次数只能为纯数字！");
                return false;
            } else if (maxbuycount == "") {
                LeeJSUtils.showMessage("error", "最多允许兑换次数不能为空！");
                return false;
            } else if (isNaN(maxbuycount)) {
                LeeJSUtils.showMessage("error", "最多允许兑换次数只能为纯数字！");
                return false;
            } else if (paypoint == "") {
                LeeJSUtils.showMessage("error", "单次兑换消费点数不能为空！");
                return false;
            } else if (isNaN(paypoint)) {
                LeeJSUtils.showMessage("error", "单次兑换消费点数只能为数字！");
                return false;
            } else if (parseInt(paypoint) <= 0) {
                LeeJSUtils.showMessage("error", "单次兑换消费点数输入有误！");
                return false;
            } else {
                var info = { ID: id, ActiveTokenID: tid, PrizeName: prizename, Remark: remark, MaxBuyCount: maxbuycount, PayPoint: paypoint, CreateCustomersID: userid, CreateName: username, OneBuyMaxCount: onebuymax };
                LeeJSUtils.showMessage("loading", "正在保存..");
                setTimeout(function () {
                    isProcess = true;
                    $.ajax({
                        type: "POST",
                        cache: false,
                        timeout: 5 * 1000,
                        data: { info: JSON.stringify(info) },
                        contentType: "application/x-www-form-urlencoded; charset=utf-8",
                        url: "/OA/project/storesaler/wxActiveTokenCore.ashx?ctrl=SavePrizeInfo",
                        success: function (msg) {
                            console.log(msg);
                            if (msg.indexOf("Error:") > -1) {
                                LeeJSUtils.showMessage("error", msg.replace("Error:", ""));
                                isProcess = false;
                            }
                            else {
                                if (parseInt(id) > 0)
                                    LeeJSUtils.showMessage("successed", "礼品修改成功!");
                                else
                                    LeeJSUtils.showMessage("successed", "礼品添加成功!");
                                setTimeout(function () {
                                    isProcess = false;
                                    backFunc();
                                    loadGiftItems();
                                }, 1500);
                            }
                        },
                        error: function (XMLHttpRequest, textStatus, errorThrown) {
                            isProcess = false;
                            LeeJSUtils.showMessage("error", "您的网络出问题啦..");
                        }
                    });
                }, 50);
            }
        }

        //返回操作
        function backFunc() {
            switch (currentPage) {
                case "index":
                    window.history.go(-1);
                    currentPage = "create";
                    break;
                case "create":
                    $("#itemPage").addClass("page-right");
                    $(".header .fa-plus").fadeIn(200);
                    currentPage = "index";
                    break;
            }
        }

        //设置礼品项的可用状态
        function setIsActive(obj) {
            if (isProcess)
                return;

            isProcess = true;
            LeeJSUtils.showMessage("loading", "正在处理..");
            var gid = $(obj).parents(".item").attr("data-id");
            var status = $(obj).attr("data-open");
            var isactive = status == "0" ? "1" : "0";
            setTimeout(function () {
                $.ajax({
                    type: "POST",
                    cache: false,
                    timeout: 5 * 1000,
                    data:{ID:gid, IsActive:isactive, CreateCustomersID:userid, CreateName:username},
                    contentType: "application/x-www-form-urlencoded; charset=utf-8",
                    url: "/OA/project/storesaler/wxActiveTokenCore.ashx?ctrl=SetPrizeStatus",
                    success: function (msg) {                        
                        if (msg.indexOf("Error:") > -1)
                            LeeJSUtils.showMessage("error", "操作失败 " + msg.replace("Error:", ""));
                        else {
                            LeeJSUtils.showMessage("successed", "操作成功!");
                            if (status == "1") {
                                $(obj).attr("data-open", "0");
                                $(obj).removeClass("open");
                            } else {
                                $(obj).attr("data-open", "1");
                                $(obj).addClass("open");
                            }
                        }
                        isProcess = false;
                    },
                    error: function (XMLHttpRequest, textStatus, errorThrown) {
                        isProcess = false;
                        showMessage("您的网络出问题啦..", null);
                    }
                });
            }, 20);
        }

        //$.ajax({
        //    type: "POST",
        //    cache: false,
        //    timeout: 10 * 1000,
        //    contentType: "application/x-www-form-urlencoded; charset=utf-8",
        //    url: "turkeyPlanCoreV2.aspx?ctrl=",
        //    success: function (msg) {
        //        var data = JSON.parse(msg);
        //    },
        //    error: function (XMLHttpRequest, textStatus, errorThrown) {
        //        showMessage("您的网络出问题啦..", null);
        //    }
        //});
    </script>
</body>
</html>
