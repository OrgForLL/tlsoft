function BindEvents() {
    //$(".header .btn").on("touchstart", function () { });

    $(".subbtn.cancle").click(backFunc);

    $(".header .return").click(backFunc);

    $(".header .flowchart").click(function () {
        if ($("#flow-chart").attr("data-load") == "1" && $("#demo .GooFlow_head").length > 0)
            GotoPage("flow-chart");
        else
            loadFlowGraph();
    });

    $(".radio_wrap .radio_item").click(function () {
        if (!$(this).hasClass("selected")) {
            $(".radio_wrap .radio_item.selected").removeClass("selected");
            $(this).addClass("selected");
        }
    });

    //退办时的岗位选择
    $(".node_radio_wrap").on("click", ".node_radio_item", function () {
        if (!$(this).hasClass("selected")) {
            $(".node_radio_item.selected i").attr("class", "fa fa-circle-o");
            $(".node_radio_item.selected").removeClass("selected");
            $(this).find("i").attr("class", "fa fa-dot-circle-o");
            $(this).addClass("selected");

            //显示对应的接收人
            var auditnode = $(this).attr("data-nodeid");
            var _html = $("#mirror_returnusers option[data-nodeid='" + auditnode + "']").clone(true);
            $("#handle-prev .select_wrap[data-type='receiver'] select").html(_html);
        }
    });

    $(".table_tabs").on("click", "a", function () {
        $(".table_infos table").hide();
        $("#" + $(this).attr("data-tableid")).show();

        $(".table_tabs li.active").removeClass("active");
        $(this).parent().addClass("active");
    });

    //办理
    $(".doc_btn[data-dir='next']").click(function () {
        if ($("#handle-next").attr("data-load") == "1")
            GotoPage('handle-next');
        else
            getNextNodes();
    });

    //退办
    $(".doc_btn[data-dir='prev']").click(function () {
        if ($("#handle-prev").attr("data-load") == "1")
            GotoPage('handle-prev');
        else
            getPrevNodes();
    });

    $("#handle-next .select_wrap[data-type='node'] select").change(function () {
        var auditnode = $(this).val();
        getNextNodeUsers(auditnode);
    });
}

function backFunc() {
    if (currentIndex == "index" && pageRoute.length == 1)
        window.history.back(-1);
    else {
        $("#" + currentIndex).addClass("page-right");
        pageRoute.pop();
        currentIndex = pageRoute[pageRoute.length - 1];
    }
}

function GotoPage(pageid) {
    if (currentIndex == pageid)
        return;

    $("#" + pageid).removeClass("page-right");
    pageRoute.push(pageid);
    currentIndex = pageid;
}

function showLoading(text) {
    $(".load_toast .load_text").text(text);
    $("#oaLoading").show();
}

//================================加载审批单据信息================================
//上部主体数据信息
function loadFlowZData(dfd) {
    showLoading("加载中..");
    setTimeout(function () {
        $.ajax({
            type: "POST",
            timeout: 10 * 1000,
            contentType: "application/x-www-form-urlencoded; charset=utf-8",
            data: { tzid: tzid, docid: docid, flowid: flowid, dxid: dxid },
            url: mainPage
        }).done(function (msg) {
            //console.log(msg);
            if (msg.indexOf("Error:") > -1) {
                showLoading(msg.replace("Error:", ""));
                dfd.reject();
            } else {
                var data = JSON.parse(msg), html = "";
                if (data.code == "200") {
                    data = data.data;
                    var row = data.data_result[0];
                    for (var p in data.data_head) {
                        var value = row[p];
                        if (value === undefined)
                            continue;
                        html += template("form_cell", { label: data.data_head[p], text: value });
                    }

                    if (uid == currentuserid) {
                        if (flow_flag == "2") {
                            //下一道终审
                            $(".doc_btn[data-dir='last']").css("display", "block");//终审按钮
                            $(".doc_btn[data-dir='prev']").css("display", "block");//退办按钮
                        } else if (flow_flag == "3") {
                            //流转中,节点不在最后一道                        
                            $(".doc_btn[data-dir='next']").css("display", "block");//办理按钮                        
                            $(".doc_btn[data-dir='prev']").css("display", "block");//退办按钮
                        }
                    }

                    $(".form_infos").empty().html(html);
                    $(".load_toast").fadeOut(200);
                } else
                    showLoading("出错啦.." + data.errormsg);
                dfd.resolve();
            }
        }).fail(function (XMLHttpRequest, textStatus, errorThrown) {
            console.log(XMLHttpRequest.status + "|" + XMLHttpRequest.statusText);
            showLoading("网络开小差啦..");
            dfd.reject();
        });
    }, 100);

    return dfd;
}

//加载明细数据
function loadFlowTables() {
    showLoading("加载数据，请稍候..");
    setTimeout(function () {
        $.ajax({
            type: "POST",
            timeout: 10 * 1000,
            data: { tzid: tzid, docid: docid, flowid: flowid, dxid: dxid },
            contentType: "application/x-www-form-urlencoded; charset=utf-8",
            url: detailPage
        }).done(function (msg) {
            //console.log(msg);
            var data = JSON.parse(msg);
            if (data.code == "200") {
                var tables = data.data.table_datas, table_html = "";
                for (var i = 0; i < tables.length; i++) {
                    var rows = tables[i].table_rows;
                    var table_body = "", table_head = "";
                    //构造表体
                    for (var j = 0; j < rows.length; j++) {
                        var _tr = "";
                        for (var p in rows[j]) {
                            _tr += "<td>" + rows[j][p] + "</td>";
                        }

                        if (_tr != "") {
                            table_body += "<tr>" + _tr + "</tr>";
                        }
                    }//end for j

                    //构造表头                            
                    for (var k in rows[0]) {
                        for (var x = 0; x < tables[i].table_head.length; x++) {
                            if (tables[i].table_head[x].code == k) {
                                table_head += "<th width='" + tables[i].table_head[x].width + "px'>" + tables[i].table_head[x].name + "</th>";
                                continue;
                            }
                        }//end                      
                    }

                    table_head = "<tr>" + table_head + "</tr>";
                    table_html += "<table style='table-layout: fixed; width: 100%;' id='table_" + i + "' data-name='" + tables[i].table_name + "'><thead>" + table_head + "</thead><tbody>" + table_body + "</tbody>";
                }//end for i

                $(".table_infos").empty().html(table_html);

                var tables = $(".table_infos table");
                for (var i = 0; i < tables.length; i++) {
                    $(".table_tabs").append("<li><a href='javascript:' data-tableid='table_" + i + "'>" + tables.eq(i).attr("data-name") + "</a></li>");
                }//end for

                $(".table_tabs li:first-child a").click();
                $(".load_toast").hide();                
            } else
                showLoading("加载明细出错！" + data.errormsg);
        }).fail(function (XMLHttpRequest, textStatus, errorThrown) {
            console.log(XMLHttpRequest.status + "|" + XMLHttpRequest.statusText);
            showLoading("网络开小差啦.." + XMLHttpRequest.status + "|" + XMLHttpRequest.statusText);
        });
    }, 50);
}

//退办时获取节点及所有退办节点办理人
function getPrevNodes() {
    showLoading("获取退办节点..");
    setTimeout(function () {
        $.ajax({
            type: "POST",
            timeout: 10 * 1000,
            contentType: "application/x-www-form-urlencoded; charset=utf-8",
            data: { docid: docid, flowid: flowid },
            url: "LLMobileOACore.aspx?ctrl=loadPrevNodeInfo"
        }).done(function (msg) {
            //console.log(msg);
            if (msg.indexOf("Error:") == -1) {
                var data = JSON.parse(msg);
                var html = template("tmp_prevnodes", data.returnNodes);
                $(".node_radio_wrap").empty().html(html);
                html = template("tmp_prevusers", data.returnUsers);
                //$("#handle-prev .select_wrap[data-type='receiver'] select").empty().html(html);
                $("#mirror_returnusers").html(html);

                $("#handle-prev").attr("data-load", "1");
                GotoPage("handle-prev");
                $(".load_toast").fadeOut(200);
            } else
                showLoading(msg.replace("Error:", ""));            
        }).fail(function (XMLHttpRequest, textStatus, errorThrown) {
            console.log(XMLHttpRequest.status + "|" + XMLHttpRequest.statusText);
            showLoading("网络开小差啦..");
        });
    }, 50);
}

//获取下道办理节点
function getNextNodes() {
    showLoading("获取办理节点..");
    setTimeout(function () {
        $.ajax({
            type: "POST",
            timeout: 10 * 1000,
            contentType: "application/x-www-form-urlencoded; charset=utf-8",
            data: { docid: docid, flowid: flowid },
            url: "LLMobileOACore.aspx?ctrl=loadNextNodeInfo"
        }).done(function (msg) {
            //console.log(msg);
            if (msg.indexOf("Error:") == -1) {
                var selObj = $("#handle-next .select_wrap[data-type='node'] select");
                var data = JSON.parse(msg);
                var html = template("tmp_nextnodes", data.rows);
                //html += "<option value='1442'>分管副部长审批</option>";
                selObj.empty().html(html);
                $("#next_opinion").val("");
                GotoPage('handle-next');
                if (selObj.find("option").length > 0) {
                    getNextNodeUsers(selObj.val());
                }
                $("#handle-next").attr("data-load", "1");
                $(".load_toast").fadeOut(200);
            } else
                showLoading(msg.replace("Error:", ""));
        }).fail(function (XMLHttpRequest, textStatus, errorThrown) {
            console.log(XMLHttpRequest.status + "|" + XMLHttpRequest.statusText);
            showLoading("网络开小差啦..");
        });
    }, 50);
}

function getNextNodeUsers(auditnode) {
    showLoading("获取相关办理人..");
    setTimeout(function () {
        $.ajax({
            type: "POST",
            timeout: 10 * 1000,
            contentType: "application/x-www-form-urlencoded; charset=utf-8",
            data: { docid: docid, auditnode: auditnode },
            url: "LLMobileOACore.aspx?ctrl=loadNextUsersInfo"
        }).done(function (msg) {
            console.log(msg);
            if (msg.indexOf("Error:") == -1) {
                var data = JSON.parse(msg);
                var selObj = $("#handle-next .select_wrap[data-type='user'] select");
                var html = template("tmp_nextusers", data.rows);
                selObj.empty().html(html);
                $(".load_toast").fadeOut(200);
            } else
                showLoading(msg.replace("Error:", ""));
        }).fail(function (XMLHttpRequest, textStatus, errorThrown) {
            console.log(XMLHttpRequest.status + "|" + XMLHttpRequest.statusText);
            showLoading("网络开小差啦..");
        });
    }, 50);
}

//加载审批记录
/*
0 流程第一步，当前处在第一道，还未办理给下一道 
1 已归档
2 流程最后一步,还未终审
3 流转中,节点不在最后一道
*/
function loadFlowOpinions() {
    $.ajax({
        type: "POST",
        timeout: 5 * 1000,
        contentType: "application/x-www-form-urlencoded; charset=utf-8",
        data: { flowid: flowid, dxid: dxid },
        url: "LLMobileOACore.aspx?ctrl=loadFlowOpinions"
    }).done(function (msg) {
        if (msg.indexOf("Error:") > -1) {
            showLoading(msg.replace("Error:", ""));
        } else {
            var rows = JSON.parse(msg).rows;
            if (rows.length > 0) {
                var html = "";
                for (var i = 0; i < rows.length; i++) {
                    if (i > 0) {
                        if (parseInt(rows[i].nodesort) < parseInt(rows[i - 1].nodesort))
                            rows[i].direction = "1";//办理
                        else
                            rows[i].direction = "0";//退办
                    } else
                        rows[i].direction = "1";//办理
                    html += template("tmp_docNode", rows[i]);
                }//end for direction
                if (html != "") {
                    //添加开始节点提示
                    html += "<div class='doc_node start_node'><p class='job_name'>开始申请</p><span class='dot'></span></div>";//倒序显示
                }
                if (rows[0].nodetype == "2" && rows[0].flag == "1") {
                    //添加结束节点提示
                    html = "<div class='doc_node end_node'><p class='job_name'>审批结束</p><span class='dot'></span></div>" + html;
                }
                $(".doc_records").empty().html(html);
                $(".doc_records_wrap .no-result").hide();
            }
        }
    }).fail(function (XMLHttpRequest, textStatus, errorThrown) {
        console.log(XMLHttpRequest.status + "|" + XMLHttpRequest.statusText);
        showLoading("网络开小差啦.." + XMLHttpRequest.status);
    });
}

//加载流程图，首次单击时才去加载
function loadFlowGraph() {
    showLoading("加载流程图..");
    setTimeout(function () {
        //加载流程图            
        var flowConfig = { url: "LLMobileOACore.aspx", data: { ctrl: "loadFlowGraphInfo", flowid: flowid, docid: docid } };
        initFlowChart(flowConfig, 'demo', function () {
            $("#flow-chart").attr("data-load", "1");
            $(".load_toast").hide();
            GotoPage("flow-chart");
        });
    }, 200);
}

//办理到下一节点
function doSendNextNode() {
    //exec flow_up_sendnextsingle docid,nextnode,nextnodeuser,flow_opinion,username,userid,tzid,zbid,xtlb,flow_pldocid
    var nextnode = $("#handle-next .select_wrap[data-type='node'] select").val();
    var nextnodeuser = $("#handle-next .select_wrap[data-type='user'] select").val();
    var nextopinion = $("#next_opinion").val().trim();
    if (nextnode == "" || nextnode == "0" || nextnode === undefined || nextnode === null)
        LeeTips("warn", "请选择下一道办理节点！");
    else if (nextnodeuser == "" || nextnodeuser == "0" || nextnodeuser === undefined || nextnodeuser === null)
        LeeTips("warn", "请选择下一道接收人！");
    else {
        var _node = $("#handle-next .select_wrap[data-type='node'] select").find("option:selected").text();
        var _user = $("#handle-next .select_wrap[data-type='user'] select").find("option:selected").text();
        LeeTips("ask", "确认办理给<br />【" + _node + "】-【" + _user + "】？", function () {
            LeeTips("loading", "正在办理..");
            setTimeout(function () {
                $.ajax({
                    type: "POST",
                    timeout: 15 * 1000,
                    contentType: "application/x-www-form-urlencoded; charset=utf-8",
                    data: { nextnode: nextnode, nextnodeuser: nextnodeuser, nextopinion: nextopinion, currentnode: current_node, docid: docid },
                    url: "LLMobileOACore.aspx?ctrl=doSendNextNode"
                }).done(function (msg) {
                    console.log(msg);                    
                    if (msg == "Successed") {
                        LeeTips("successed", "办理成功", function () {
                            //var scene = LeeJSUtils.GetQueryParams("scene");
                            //if (isInApp && scene == "onchat") {
                            //    LeeTips("ask", "是否将该审批单发送到当前聊天窗口？", function () {
                            //        llApp.doSendURL("354", "请假申请单", "审批单据描述", "http://192.168.35.231/mobileoa/oalogin.aspx?gourl=" + encodeURIComponent(window.location.href), function (result) {
                            //            if (result) {
                            //                llApp.closeWKView();
                            //            }
                            //        });
                            //    }, function () { window.location.href = ""; });
                            //}else
                            window.location.href = "";
                        });
                    } else
                        LeeTips("fail", "操作失败！" + msg.replace("Error:", ""));
                }).fail(function (XMLHttpRequest, textStatus, errorThrown) {
                    console.log(XMLHttpRequest.status + "|" + XMLHttpRequest.statusText);
                    LeeTips("fail", "网络开差啦，请稍后重试！" + XMLHttpRequest.status);
                });
            }, 500);
        });
    }
}

//退办至上一节点
function doReturnPrevNode() {
    var returnNode = $("#handle-prev .node_radio_wrap .node_radio_item.selected").attr("data-nodeid");
    var returnNodeUser = $("#handle-prev .select_wrap[data-type='receiver'] select").val();
    var opinion = $("#return_opinion").val().trim();
    if (returnNode == "" || returnNode == "0" || returnNode === undefined || returnNode === null)
        LeeTips("warn", "请选择退办节点！");
    else if (returnNodeUser == "" || returnNodeUser == "0" || returnNodeUser === undefined || returnNodeUser === null)
        LeeTips("warn", "请选择退办节点接收人！");
    else {
        var _node = $("#handle-prev .node_radio_item.selected").text();
        var _select = $("#handle-prev .select_wrap[data-type='receiver'] select");
        var _user = _select.find("option:selected").text();
        LeeTips("ask", "确认退办至<br />【" + _node + "】-【" + _user + "】？", function () {
            LeeTips("loading", "正在处理..");
            setTimeout(function () {
                $.ajax({
                    type: "POST",
                    timeout: 15 * 1000,
                    contentType: "application/x-www-form-urlencoded; charset=utf-8",
                    data: { docid: docid, currentnode: current_node, returnNode: returnNode, returnNodeUser: returnNodeUser, opinion: opinion },
                    url: "LLMobileOACore.aspx?ctrl=doReturnPrevNode"
                }).done(function (msg) {
                    console.log(msg);
                    if (msg == "Successed") {
                        LeeTips("successed", "退办成功", function () {
                            //var scene = LeeJSUtils.GetQueryParams("scene");
                            //if (isInApp && scene == "onchat") {
                            //    LeeTips("ask", "是否将该审批单发送到当前聊天窗口？", function () {
                            //        //请求一次接口将t_user.id转换为t_customersid
                            //        llApp.doSendURL("354", "请假申请单", "审批单据描述", "http://192.168.35.231/mobileoa/oalogin.aspx?gourl=" + encodeURIComponent(window.location.href), function (result) {
                            //            alert(result);
                            //            if (result) {
                            //                llApp.closeWKView();
                            //            }
                            //        });
                            //    }, function () { window.location.href = ""; });
                            //} else
                            window.location.href = "";
                        });
                    } else
                        LeeTips("fail", "操作失败！" + msg.replace("Error:", ""));
                }).fail(function (XMLHttpRequest, textStatus, errorThrown) {
                    console.log(XMLHttpRequest.status + "|" + XMLHttpRequest.statusText);
                    LeeTips("fail", "网络开差啦，请稍后重试！" + XMLHttpRequest.status);
                });
            }, 500);
        });
    }
}

//终审
function doSendEnd() {
    var endopinion = $("#endopinion").val().trim();
    LeeTips("ask", "确认终审？", function () {
        LeeTips("loading", "正在处理..");
        setTimeout(function () {
            $.ajax({
                type: "POST",
                timeout: 15 * 1000,
                contentType: "application/x-www-form-urlencoded; charset=utf-8",
                data: { docid: docid, currentnode: current_node, endOpinion: endopinion },
                url: "LLMobileOACore.aspx?ctrl=doSendEnd"
            }).done(function (msg) {
                console.log(msg);
                if (msg == "Successed") {
                    LeeTips("successed", "终审成功", function () { window.location.href = "docList.html"; });
                } else
                    LeeTips("fail", "操作失败！" + msg.replace("Error:", ""));
            }).fail(function (XMLHttpRequest, textStatus, errorThrown) {
                console.log(XMLHttpRequest.status + "|" + XMLHttpRequest.statusText);
                LeeTips("fail", "网络开差啦，请稍后重试！" + XMLHttpRequest.status);
            });
        }, 500);
    });
}

/*LeeTips*/
function LeeTips(type, text, cb1, cb2) {
    $(".doTips").attr("data-type", type);
    $(".doTips .doTip_txt").html(text);

    if (typeof (cb1) == "function")
        $(".dobtn.confirm").unbind("click").click(cb1);
    else
        $(".dobtn.confirm").unbind("click").click(function () { $("#LeeTips").fadeOut(200); });

    if (typeof (cb2) == "function")
        $(".dobtn.cancle").unbind("click").click(cb2);
    else
        $(".dobtn.cancle").unbind("click").click(function () { $("#LeeTips").fadeOut(200); });

    $("#LeeTips").show();
}