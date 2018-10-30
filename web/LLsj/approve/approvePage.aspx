<%@ Page Language="C#" Debug="true" %>
<%@ Import Namespace="nrWebClass" %>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<script runat="server">
    // string OAConnStr = "server=192.168.35.10;uid=ABEASD14AD;pwd=+AuDkDew;database=tlsoft";
    protected void Page_Load(object sender, EventArgs e)
    {
        clsLoger.WriteLog(Convert.ToString(Session["userssid"]), Convert.ToString(Session["username"]), "approvePage.aspx","zbid="+ Convert.ToString(Session["zbid"]));

        HttpContext.Current.Session["userid"] = "15872";
        HttpContext.Current.Session["username"] = "林文印";
        HttpContext.Current.Session["zbid"] = "1";
        
        
        HttpContext.Current.Session["userssid"] = "1";
        HttpContext.Current.Session["zbid"] = Convert.ToString(Session["zbid"]); ;
        
        HttpContext.Current.Session["xtlb"] = "z";
        HttpContext.Current.Session["menulb"] = "IW";
    }

</script>
<html xmlns="http://www.w3.org/1999/xhtml">
<head id="Head1" runat="server">
    <meta charset="utf-8" />
    <meta name="viewport" content="width=device-width,initial-scale=1,user-scalable=0,maximum-scale=1" />
    <meta name="format-detection" content="telephone=no" />
    <meta name="apple-mobile-web-app-capable" content="yes" />
    <meta name="apple-mobile-web-app-status-bar-style" content="black" />
    <title>单据审批</title>
    <link type="text/css" rel="stylesheet" href="LeePageSlider.css" />
    <link type="text/css" rel="stylesheet" href="font-awesome.min.css" />
    <link type="text/css" rel="stylesheet" href="sweet-alert.css" />
    <style type="text/css">
        .page {
            padding: 0;
            background-color: #f0efed;
        }
        #main {
            bottom: 46px;
        }

        .header {
            background-color: #1b1b1d;
            color: #fff;
        }

        .footer {
            height: 46px;
            text-align: center;
            font-size: 0;
        }

        .filter_panel 
        {  
            text-align: center;
            font-size: 0;
            margin: 10px 0;
        }

        .filter_panel > a {
            display: inline-block;
            font-size: 15px;
            padding: 2px 25px;
            border: 1px solid #fff;
            color: #fff;
            font-weight: 400;
        }

        .filter_panel a.active {
            background-color: #fff;
            color: #000;
        }

        .djlist {
            padding: 10px 8px 0 8px;
        }

        .djlist li {
            height: 100px;
            background-color: #fff;
            margin-bottom: 8px;
            border-bottom: 1px solid #d5d5d5;
            padding: 1px 10px 0 10px;
            position: relative;
        }
        .djlist li:nth-child(2n+1) .name {
            border-left: 3px solid #ff6a1f;
        }
        .djlist li:nth-child(2n) .name {
            border-left: 3px solid #58c011;
        }
        .djlist .name {
            font-size: 16px;
            font-weight: bold;
            margin: 10px 0;
            padding: 0 10px;
        }
        .djlist .per-name {
            line-height: 20px;
        }
        .djlist .time {
            color: #ccc;
            position: absolute;
            left: 10px;
            bottom: 7px;
        }
        .djlist li .fa-angle-right {
            position: absolute;
            top: 10px;
            right: 0;
            width: 28px;
            height: 80px;
            line-height: 80px;
            text-align: center;
            color: #ccc;
            font-size: 20px;
            border-left: 1px solid #f2f2f2;
        }
        .bot {
            font-size: 0;
            text-align: center;
            height: 46px;
            bottom: 0;
            position: absolute;
            left: 0;
            width: 100%;
        }

        .footer > a, .bot > a {
            display: inline-block;
            color: #222;
            font-size: 16px;
            width: 50%;
            height: 100%;
            line-height: 46px;
            color: #fff;
            font-weight: bold;
        }

        /*detail style*/
        .top 
        {
            position: absolute;
            left: 0;
            width: 100%;
            top: 5px;
            bottom: 46px;
            overflow:auto;
        }
        .detail_list {
            padding: 10px 8px;
            overflow:auto;
            height:200px;
        }

        .detail_list li {
            background-color: #fff;
            margin-bottom: 5px;
            padding: 10px;
            position: relative;
        }

        .detail_list .name {
            font-size: 14px;
            font-weight: bold;
        }

        .detail_list .process {
            color: #58c011;
            margin: 5px 0;
            display:inline;
        }

        .detail_list .time {
            color: #ccc;
            float:right;
            text-align: right;
            display:inline;
            
        }

        .inner_iframe 
        {
            padding: 0 8px 10px 8px;
            -webkit-overflow-scrolling: touch;
            position: absolute;
            top: 200px;
            bottom: 0;
            left: 0;
            width: 100%;
            overflow: auto;
            border-top:1px solid #ccc;
        }
        .inner_iframe >iframe {
            width:100%;
            height:100%;
            overflow:auto;
            margin-bottom:10px;
        }
        .footer
        {
            display:none;
        }
        .head_back
        {
            position:fixed; 
            line-height:50px; 
            vertical-align:middle; 
            background-color:#1b1b1d;
            width:100%; 
            color:White;
            overflow:hidden;
            z-index:99;
            font-size:18px;
            padding-left:10px;
        }
        
        .headback
        {
            position: absolute;
            left: -10px;
            top: 0px;
            font-size: 14px;
            z-index: 10;
            border-radius: 10px;
            height: 36px;
            width: 100px;
            text-align: center;
            vertical-align: middle;
            line-height: 36px;
            padding-left: 10px;
            background-color: rgba(40,30,40,0.4);          
        }
       
        #handle, #returnback,#detail,#endapprove {
          display: none;
        }
        .pageTitle
        {
            display:none;
            text-align: center;
            margin: 15px 0; 
            font-size: 18px;
            font-weight: 500;
        }
        .handle_list
        {
            margin:15px 15px;
            background-color:#f7f7f7;
        }
        .handle_list li
        {
            background-color: #fff;
            margin-bottom: 5px;
            padding: 10px;
            position: relative;  
        }
          .handle_list li p
        {
            padding-top:5px;
        }
         .prompt 
        {
             font-size: 14px;
        }
         .large
        {
             font-size: 18px;
             font-weight:bold;
        }
        .content
        {
            text-align:center;
            font-weight:bold;
           
        }
         .content >a
        {
            display: inline-block;
            color: #222;
            width: 30%;
            height: 100%;
            line-height: 46px;
            color: #fff;
            font-weight: bold;
        }
        .content >select {
            width: 100%;
            padding: 6px 8px;
            border: 1px solid #ddd;
            color: #333;
            font-size: 16px;
            margin-top:5px;
        }
        .content >textarea {
            margin-top:10px;
            font-size:16px;
        }
       .content >label
       {  
           font-size:16px;
           display:block;
           margin-top:10px;
       }
        .my_mask {
            position: fixed;
            top: 0;
            left: 0;
            right: 0;
            bottom: 0;
            background-color: rgb(0,0,0);
            opacity: 0.6;
            filter: alpha(opacity=60);
            z-index: 9998;
            display: none;
        }

        .my_toast {
            position: fixed;
            z-index: 9999;
            width: 320px;
            height: 80px;
            line-height: 80px;
            color: #303030;
            background-color: #f7f7f7;
            text-align: center;
            position: absolute;
            top: 50%;
            left: 50%;
            margin-top: -40px;
            margin-left: -160px;
            display: none;
        }

    </style>
</head>
<script type="text/javascript" src="../js/jquery.js"></script>
<script type="text/javascript" src="sweet-alert.min.js"></script>
<body>
    <div id="mytopwait">
    </div>
    <div class="my_mask">
    </div>
    <div class="my_toast">正在统计，请稍候..
        </div>
    <div class="header">
       <div class="filter_panel">
            <input type="hidden" id="pageType" value="db" />
            <a id="db_btn" class="active" href="javascript:changeStatu('db')" style="border-radius: 2px 0 0 2px;">待 审</a> 
            <a id="aud_btn" href="javascript: changeStatu('aud')" style="margin-left: -1px;border-radius: 0 2px 2px 0">已 审</a>
        </div>
        <div class="pageTitle">审 批</div>
    </div>
    <div class="wrap-page">
        <!--列表主页-->
        <div class="page page-not-header-footer" id="main">
            <ul class="djlist">
            </ul>
        </div>
        <!--单据明细页-->
        <div class="page" id="detail">
            <input type="hidden" id="docid" value="" />
            <div class="headback">
                <div onclick="goBack('detail')"><i class="fa fa-chevron-left"></i>返回</div>
            </div>
            <div class="top">
                <ul class="detail_list">
                </ul>
                <div class="inner_iframe">
                    <iframe id="myframe" frameborder="no" srcolling="yes" src=""></iframe>
                </div>
            </div>
            <div class="bot" id="detail_bot">
                <a id="btn_endHandle" href="javascript:endHandle()"  style="background-color: #65c4aa;">终 审</a>
                <a id="btn_Handle" href="javascript:GoHandle()" style="background-color: #65c4aa;">办 理</a> 
                <a id="btn_ReturnBack" href="javascript:ReturnBack()" style="background-color: #d5d5d5;">退 办</a>
                <a id="btn_cancel" href="javascript:goBack('detail')"  style="background-color: #d5d5d5;">取消</a>
            </div>
        </div>
        <!--办理页面-->
        <div  class="page page-not-header"  id="handle">
              <ul class="handle_list">
                  <li>
                      <P class="prompt">下一个节点:</p>
                      <p class="content"><select id="nextNode"   >
                          <option value="bz">部长审批</option>
                          <option value="jl">经理审批审批</option>
                          </select>
                      </p> 
                  </li>
                  <li>
                      <P class="prompt large">审批方式:</p>
                      <p class="content">
                      <input type="hidden" id="approvalMethod" value="list" />
                           <a href="javascript:" id="method_list" onclick="changeMethon('list')" style="background-color: #1E90FF;">单人</a>
                           <a href="javascript:" id="method_grid" onclick="changeMethon('grid')" style="background-color: #d5d5d5;">多人</a>
                      </p> 
                  </li>

                  <li>
                      <P class="prompt">下一节点办理人:</p>
                      <p class="content">
                          <select id="nextNodeUser"  >
                          <option value="bz">部长审批</option>
                          <option value="jl">经理审批审批</option>
                          </select>
                      </p> 
                  </li>
                    <li>
                      <P class="prompt large">审批意见:</p>
                      <p class="content"><textarea id="opinion" style=" width:100%; height:80px;"></textarea>
                      </p> 
                  </li>
              </ul> 
               <div class="bot">
                <a href="javascript:OkGo('handle')" style="background-color: #65c4aa;">完 成</a> 
                <a href="javascript:goBack('handle')" style="background-color: #d5d5d5;">取 消</a>
            </div>
        </div>
        <!--退办页面-->
        <div class="page page-not-header" id="returnback">
          <ul class="handle_list">
                  <li>
                     <P class="prompt">退办至节点:</p>
                        <p class="content" id="reBackNode" style=" text-align:left;">
                           <%-- <label><input type="radio" style="-webkit-appearance:radio;" name="colors" value="1" checked="checked" /> 灰色</label>
                            <label><input type="radio" style="-webkit-appearance:radio;" name="colors" value="2" /> 灰色</label>--%>
                       </p>
                  </li>
                  <li>
                     <P class="prompt">接收人:</p>
                     <p class="content"><select id="reBackUser" class="content"  >
                        <%--  <option value="bz">部长审批</option>
                          <option value="jl">经理审批审批</option>--%>
                          </select>
                      </p>  
                  </li>

                  <li>
                      <P class="prompt large">审批意见:</p>
                      <p class="content"> <textarea  id="reback_opinion" style="width:100%; height:80px;"></textarea>
                      </p> 
                  </li>

              </ul> 
               <div class="bot">
                <a href="javascrtip:" onclick="OKReturn()" style="background-color: #65c4aa;">完 成</a> 
                <a href="javascript:goBack('returnback')" style="background-color: #d5d5d5;">取 消</a>
            </div>
        </div>

        <!--终审页面-->
        <div class="page page-not-header" id="endapprove">
          <ul >
              <li>
                <P class="prompt large">终审意见:</p>
                <p class="content"> <textarea  id="end_opinion" style="width:100%; height:80px;"></textarea>
                </p> 
             </li>
          </ul> 
           <div class="bot">
                <a href="javascrtip:" onclick="endOKgo()" style="background-color: #65c4aa;">完 成</a> 
                <a href="javascript:goBack('endapprove')" style="background-color: #d5d5d5;">取 消</a>
            </div>
        </div>
    </div>
    <div class="footer">
        <input type="hidden" id="DateTime" value="" />
        <a onclick="dateChange(-1)" href="javascript:" style="background-color: #65c4aa;">前一天</a>
        <a onclick="dateChange(1)" href="javascript:" style="background-color: #d5d5d5;">后一天</a>
    </div>
    <script type="text/javascript">
        var ReturnNodeUser;
        function endHandle() {
            $(".filter_panel").hide();
            $("#detail").hide();
            $("#endapprove").show();
            $(".pageTitle").html("终 审");
            $(".pageTitle").show();
            $("#end_opinion").val("");
        }
        function endOKgo() {
            var para = new Object();
            para.docid = $("#docid").val();
            para.opinion = $("#opinion").val().replace(/\"/g, "'").replace(/[\r\n]/g, "");
            console.log(para);
            var parastr = JSON.stringify(para);
            $.ajax({
                type: "POST",
                url: "approveCore.aspx?ctrl=audisend",
                data: { parastr: parastr },
                timeout: 5000,
                error: function (xhr, type, exception) {
                    swal("糟糕", "网络出错了", "error");
                },
                success: function (res) {
                    console.log("终审返回" + res);
                    if (res.indexOf("Successed") > -1) {
                        swal({ title: "终审成功",
                            text: "点击按钮返回",
                            type: "success", 
                            confirmButtonColor: "#DD6B55",
                            confirmButtonText: "返回",
                            closeOnConfirm: true, 
                        }, 
                         function (isConfirm) { 
                            $(".pageTitle").hide();
                            $(".filter_panel").show();
                            $("#endapprove").hide();
                            $("#main").show();
                            GetDBList($("#pageType").val());  
                       });
                       // alert("终审成功,点击确认返回");
                    }
                }
            });
        }
        function OKReturn() {
            console.log($("#reBackUser").val());
            var para = new Object();
            para.docid = $("#docid").val();
            para.returnNodeID = $("input[name='returnNode']:checked").val();
            para.returnNodeUser = $("#reBackUser").val();
            para.opinion = $("#reback_opinion").val().replace(/\"/g, "'").replace(/[\r\n]/g, "");
            if (isNaN(para.returnNodeUser) || para.returnNodeUser == null) {
                swal("提示", "请选择退办节点", "warning");
                return false;
            }
            var parastr = JSON.stringify(para);
            console.log(parastr);
            $.ajax({
                type: "POST",
                url: "approveCore.aspx?ctrl=returnback",
                data: { parastr: parastr },
                timeout: 5000,
                error: function (xhr, type, exception) {
                   swal("糟糕", "网络出错了", "error");
                },
                success: function (res) {
                  //  console.log("退办返回" + res);
                    if (res.indexOf("Successed") > -1) {
                    swal({ title: "退办成功",
                            text: "点击按钮返回",
                            type: "success", 
                            confirmButtonColor: "#DD6B55",
                            confirmButtonText: "返回",
                            closeOnConfirm: true, 
                        }, 
                         function (isConfirm) { 
                             $(".pageTitle").hide();
                        $(".filter_panel").show();
                        $("#returnback").hide();
                        $("#main").show();
                        GetDBList($("#pageType").val()); 
                       });
                      //  alert("退成功,点击确认返回");
                       
                    }
                }
            });
        }
        function ReturnBack() {
            $(".filter_panel").hide();
            $("#detail").hide();
            $("#returnback").show();
            $(".pageTitle").html("退 办");
            $(".pageTitle").show();
            //alert($('#reBackNode input[name="colors"]:checked ').val());
            $.ajax({
                type: "POST",
                url: "approveCore.aspx?ctrl=getReBackInfo",
                data: { docid: $("#docid").val() },
                timeout: 5000,
                error: function (xhr, type, exception) {
                   swal("糟糕", "网络出错了", "error");
                },
                success: function (res) {
                    console.log("退办页面信息返回：" + res);
                    if (res.indexOf("Error") > -1) {
                     //   showMessage(res);
                         swal("出错了", res, "error");
                         hideMessage(2000);
                    }
                    var rtObj = JSON.parse(res);
                    var lb = "<label><input type='radio' style='-webkit-appearance:radio;' name='returnNode' value='#nodeid#' />#name#</label>";
                    var rbList = "";
                    for (var i = 0; i < rtObj.returnNode.length; i++) {
                        rbList += lb.replace("#nodeid#", rtObj.returnNode[i]["nodeid"]).replace("#name#", rtObj.returnNode[i]["nodename"]);
                    }
                    $("#reBackNode").html(rbList);
                    ReturnNodeUser = rtObj.ReturnNodeUser;
                    $("input[name='returnNode']").change(function () {
                        var ruserList = " <option value='#userid#'>#username#</option>";
                        var rhtml = "";
                        for (var i = 0; i < ReturnNodeUser.length; i++) {
                            if ($(this).val() == ReturnNodeUser[i].nodeid) {
                                rhtml += ruserList.replace("#userid#", ReturnNodeUser[i].userid).replace("#username#", ReturnNodeUser[i].username);
                            }
                            $("#reBackUser").html(rhtml);
                        }
                    });
                }
            });

        }
      
        function OkGo(value) {
            if ($("#nextNodeUser").val() == "") {
              swal("提示", "请选择办理人", "warning");
//                showMessage("请选择办理人");
//                hideMessage(2000);
                return false;
            }
            var para = new Object();
            para.docid=$("#docid").val();
            para.nextNode=$("#nextNode").val();
            para.nextNodeUser=$("#nextNodeUser").val();
            para.opinion = $("#opinion").val().replace(/\"/g, "'").replace(/[\r\n]/g, "");
            console.log(para);
            var parastr = JSON.stringify(para);
            $.ajax({
                type: "POST",
                url: "approveCore.aspx?ctrl=audisend",
                data: { parastr: parastr },
                timeout: 5000,
                error: function (xhr, type, exception) {
                    //showMessage("糟糕,网络出现异常");
                     swal("糟糕", "网络出现异常了,请重试!", "error");
                    hideMessage(2000);
                },
                success: function (res) {
                 //   console.log("办理返回" + res);
                    if (res.indexOf("Successed") > -1) {
                    swal({ title: "办理成功",
                            text: "点击按钮返回",
                            type: "success", 
                            confirmButtonColor: "#DD6B55",
                            confirmButtonText: "返回",
                            closeOnConfirm: true, 
                        }, 
                         function (isConfirm) { 
                            $(".pageTitle").hide();
                        $(".filter_panel").show();
                        $("#handle").hide();
                        $("#main").show();
                        GetDBList($("#pageType").val());; 
                       });

//                        alert("办理成功,点击确认返回");
//                        $(".pageTitle").hide();
//                        $(".filter_panel").show();
//                        $("#handle").hide();
//                        $("#main").show();
//                        GetDBList($("#pageType").val());
                    }
                }
            });
        }
        //加载审批页面信息
        function GoHandle() {
            $(".filter_panel").hide();
            $("#detail").hide();
            $("#handle").show();
            $(".pageTitle").html("审 批");
            $(".pageTitle").show();
            $("#opinion").val("");
            $.ajax({
                type: "POST",
                url: "approveCore.aspx?ctrl=getNextNode",
                data: { docid: $("#docid").val() },
                timeout: 5000,
                error: function (xhr, type, exception) {
                   // showMessage("糟糕,网络出现异常");
                    swal("糟糕", "网络出现异常了,请重试!", "error");
                    hideMessage(2000);
                },
                success: function (res) {
                    if (res.indexOf("Error") > -1) {
                        swal("出错了", res, "error");
                        //showMessage(res);
                        hideMessage(1000);
                        return false;
                    }
                    var rtObj = JSON.parse(res);

                    var opt = " <option value='#id#'>#name#</option>";
                    var optList = "";
                    for (var i = 0; i < rtObj.nextNode.nextNode.length; i++) {
                        optList += opt.replace("#id#", rtObj.nextNode.nextNode[i].nodeID).replace("#name#", rtObj.nextNode.nextNode[i].nodeName);
                    }
                    console.log(optList);
                    $("#nextNode").html(optList);
                    optList = "";
                    for (var i = 0; i < rtObj.nextNodeUser.nextNodeUser.length; i++) {
                        optList += opt.replace("#id#", rtObj.nextNodeUser.nextNodeUser[i].userid).replace("#name#", rtObj.nextNodeUser.nextNodeUser[i].username);
                    }
                    console.log("审批人：" + optList);
                    $("#nextNodeUser").html(optList);

                    $("#nextNode").change(function () {
                        $.ajax({
                            type: "POST",
                            url: "approveCore.aspx?ctrl=nodeUser",
                            data: { docid: $("#docid").val(), nodeid: $("#nextNode").val() },
                            timeout: 5000,
                            error: function (xhr, type, exception) {
                                 swal("糟糕", "网络出现异常了,请重试!", "error");
                                hideMessage(1000);
                            },
                            success: function (res) {
                                console.log(res);
                                if (res.indexOf("Error") > -1) {
                                    //showMessage(res);
                                     swal("出错了", res, "error");
                                    hideMessage(2000);
                                    return false;
                                }
                                var rtObj = JSON.parse(res);
                                var rows = rtObj.nextNodeUser;
                                var optList = "";
                                var opt = " <option value='#id#'>#name#</option>";
                                for (var i = 0; i < rows.length; i++) {
                                    optList += opt.replace("#id#", rows[i].userid).replace("#name#", rows[i].username);
                                }
                                console.log("拼接代码：" + optList);
                                $("#nextNodeUser").html(optList);
                            }
                        });
                    });
                }
            });
        }
      
        $(document).ready(function () {
            $("#mytopwait").hide();
            var mydate = new Date();
            $("#DateTime").val(mydate.getFullYear() + "-" + (mydate.getMonth() + 1) + "-" + mydate.getDate());
            GetDBList("db");
        });

        //获取单据列表（未审单据或某一天的已审单据）
        function GetDBList(status) {
            $(".djlist").empty();
            showMessage("加载中..");
            var djlist = " <li id='#id#' onclick=detailApprove('#docid#','#bid#','#djid#','#flowid#','#other#','#flag#')><p class='name'>#content#</p><p class='per-name'>#cname#</p><p class='time'>#date#</p><i class='fa fa-angle-right'></i></li>"
            $.ajax({
                type: "POST",
                url: "approveCore.aspx?ctrl=" + status,
                data: { date: $("#DateTime").val() },
                timeout: 5000,
                error: function (xhr, type, exception) {
                    swal("糟糕", "网络出现异常了,请重试!", "error");
                    hideMessage(1000);
                },
                success: function (res) {
                    console.log("数据返回" + res);
                    if (res.indexOf("Error") > -1) {
                        swal("出错了", res, "error");
                        return false;
                    }
                    var rtObj = JSON.parse(res);
                    var rows = rtObj.rows;
                    var listHtml = "";

                    for (var i = 0; i < rows.length; i++) {
                        listHtml += djlist.replace("#content#", rows[i].bName).replace("#cname#", rows[i].creator).replace("#date#", rows[i].created).replace(/\#docid\#/g, rows[i].docid).replace(/\#djid\#/g, rows[i].dxid).replace(/\#flowid\#/g, rows[i].flowid).replace(/\#other\#/g, rows[i].otherURL).replace(/\#bid\#/g, rows[i].bidNum).replace(/\#flag\#/g, rows[i].flag);
                    }
                    console.log("拼接代码：" + listHtml);
                    $(".djlist").append(listHtml);
                    if (rows.length == 0 && status == "aud") {
                        showMessage("未找到" + $("#DateTime").val() + "的已审单据");
                        hideMessage(1500);
                    } else {
                        hideMessage(100);
                    }
                }
            });
        }
        //切换已审未审状态
        function changeStatu(status) {
            $("#pageType").val(status);
            if (!$("#" + status + "_btn").hasClass("active")) {
                if (status == "aud") {
                    $("#db_btn").removeClass("active");
                    $(".footer").show();
                } else {
                    $("#aud_btn").removeClass("active");
                    $(".footer").hide();
                }
                $("#" + status + "_btn").addClass("active");
                GetDBList(status);
            }
        }
        //增减天数
        function dateChange(days) {
            var t = $("#DateTime").val();
            var mydate = new Date(t)
            mydate.setTime(mydate.getTime() + 24 * 60 * 60 * 1000 * days);
            $("#DateTime").val(mydate.getFullYear() + "-" + (mydate.getMonth() + 1) + "-" + mydate.getDate());
            GetDBList("aud");
        }

       

        //加载明细页面
        function detailApprove(docid, bid, mydjid, flowid, other,flag) {
            $("#docid").val(docid);
           // console.log("../../bb/bbmain.aspx?bid=" + bid + "&MyDJid=" + mydjid + "&OAflowID=" + flowid + "&flowid=" + flowid + "&id=" + mydjid + other + "&MySession =14261|1|1||Z|linwy|林文印|利郎总部(开发环境)|ismykey|20381|19494|");
           // document.getElementById("myframe").src = "../../bb/bbmain.aspx?bid=19493&ryid=38028&Mydjid=27960&OAflowID=343&flowid=343";
            showMessage("正在努力加载单据明细..");
            
            if ($("#pageType").val() == "aud") {
                $("#detail_bot").hide();
            } else {
                $("#detail_bot").show();
                $("#detail_bot a").hide();
                if (flag == "0") {
                    $("#btn_Handle").show();
                    $("#btn_cancel").show();
                } else if (flag == "3") {
                    $("#btn_Handle").show();
                    $("#btn_ReturnBack").show();
                } else {
                    $("#btn_endHandle").show();
                    $("#btn_ReturnBack").show();
                }
            }

            $(".filter_panel").hide();
            $(".detail_list").empty();
            var djlist = "<li><p class='name'>#cname#</p><p class='process'>#content#</p><p class='time'>#time#</p></li>";
            $.ajax({
                type: "POST",
                url: "approveCore.aspx?ctrl=pastNode",
                data: { docid: docid },
                timeout: 5000,
                error: function (xhr, type, exception) {
                   // console.log("网络出错");
                    swal("糟糕", "网络出错了", "error");
                    hideMessage(2000);
                },
                success: function (res) {
                    document.getElementById("myframe").src = "../../bb/bbmain.aspx?bid=" + bid + "&MyDJid=" + mydjid + "&OAflowID=" + flowid + "&flowid=" + flowid + "&id=" + mydjid + other;
                    document.getElementById("myframe").onload = function () {
                        try {
                            this.contentWindow.document.getElementById("mytopwait").style.display = "none";

                            this.contentWindow.document.getElementById("bbShow").contentWindow.document.getElementById("bbdiv_record").style.overflow = "auto";

                            this.contentWindow.document.getElementById("bbtab_top").style.display = "none";

                            this.contentWindow.document.getElementById("bbShow").contentWindow.document.getElementById("bbtab_find").style.display = "none";

                        } catch (e) {

                        } 
                        hideMessage(2000);
                    };
                    if (res.indexOf("Error") > -1) {
                        swal("出错了", res, "error");
                        hideMessage(1000);
                        return false;
                    }
                    var rtObj = JSON.parse(res);
                    var rows = rtObj.rows;
                    var listHtml = "";
                    for (var i = 0; i < rows.length; i++) {
                        listHtml += djlist.replace("#content#", rows[i].nodename).replace("#cname#", rows[i].cname).replace("#time#", rows[i].dt);
                    }
                    $(".detail_list").append(listHtml);
                    $("#detail").show();
                }
            });
        }
        function goBack(page) {
            if (page == "detail") {
                $("#detail").hide();
                $(".filter_panel").show();
            } else if (page == "detail") {
                $("#returnback").hide();
                $("#detail").show();
            } else if (page == "handle") {
                $("#handle").hide();
                $("#detail").show();
            } else if (page == "returnback") {
                $("#returnback").hide();
                $("#detail").show();
            }
            else if (page == "endapprove") {
                $("#endapprove").hide();
                $("#detail").show();
            }
        }
        //切换审批方式
        function changeMethon(value) {
            if ($("#approvalMethod").val() != value) {
                $("#approvalMethod").val(value);
                $("#method_list").css("background-color", "#d5d5d5");
                $("#method_grid").css("background-color", "#d5d5d5");
                $("#method_" + value).css("background-color", "#1E90FF");
            }
        }
       
        function showMessage(value) {
            if (value != undefined && value != "") {
                $(".my_toast").html(value);
            }
            $(".my_mask").show();
            $(".my_toast").show();
        }
        function hideMessage(time) {
            if (isNaN(time)) {
                time = 1000;
            }
            $(".my_mask").fadeOut(time);
            $(".my_toast").fadeOut(time);
        }

    </script>
</body>
</html>
