<%@ Page Language="C#" %>

<%@ Import Namespace="nrWebClass" %>
<%@ Import Namespace="System.Data" %>
<%@ Import Namespace="System.Data.SqlClient" %>
<%@ Import Namespace="System.Collections.Generic" %>
<%@ Import Namespace="System.IO" %>
<%@ Import Namespace="WebBLL.Core" %>

<!DOCTYPE html>
<script runat="server">  
    string tzid;
    protected void Page_Load(object sender, EventArgs e)
    {
        string url = Request.Url.ToString().ToLower();//转为小写,indexOf 和Replace 对大小写都是敏感的   
        tzid = "1";

        if (url.IndexOf("&tlbt") > 0)
        {
            //由于URL中自动加入了tlbt 标题,tlcs个人信息,导至微信JS配置出来错误 ,所以这里要去掉.
            string tlbt = Request.QueryString["tlbt"].ToString();
            string tlcs = Request.QueryString["tlcs"].ToString();
            string newUrl = url.Replace("tlbt=" + tlbt, "").Replace("tlcs=" + tlcs, "");

            Response.Clear();

            //加上用户userid
            Response.Redirect(newUrl + "&userid=" + int.Parse(tlcs.Split('|')[2]));
            Response.End();
        }
        else
        {
            getWxConfig();
        }
    }
    //配置参数
    public void getWxConfig()
    {
        List<string> config = clsWXHelper.GetJsApiConfig("1");
        appIdVal.Value = config[0];
        timestampVal.Value = config[1];
        nonceStrVal.Value = config[2];
        signatureVal.Value = config[3];
        useridVal.Value = clsWXHelper.GetAuthorizedKey(2);
        ScanCtrl.Value = Request.Params["ScanCtrl"];

        //getInfo(useridVal.Value, ScanCtrl.Value);//进行岗位限制
    }

</script>
<html lang="en" xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <title></title>
    <meta name="viewport" content="height=device-height,width=device-width,initial-scale=1.0,minimum-scale=1.0,maximum-scale=1.0,user-scalable=no" />
    <meta name="format-detection" content="telephone=yes" />
    <meta http-equiv="Content-Type" content="text/html; charset=UTF-8" />
    <script type="text/javascript" src="../../res/js/jquery.js"></script>
    <script type="text/javascript" src="../../api/lilanzAppWVJBridge.js"></script>
    <script type="text/javascript" src="http://res.wx.qq.com/open/js/jweixin-1.0.0.js"></script>
    <link href="../../res/css/ErpScan/jquery-impromptu.css" rel="stylesheet" type="text/css" />
    <script src="../../res/js/ErpScan/jquery-impromptu.js" type="text/javascript"></script>
    <link rel="stylesheet" href="../../res/css/weui.min.css" />
    <link rel="stylesheet" href="../../res/css/StoreSaler/weui_example.css" />
    <script type="text/javascript">
        var appIdVal, timestampVal, nonceStrVal, signatureVal, userssid, userid, scanCtrl, xmjlid, bsid;
        var bcbs = "1", fzlx = "0", fzmc = "", xmjlid = "0", bsid = "0";
        $(document).ready(function () {
            ShowLoading("摄像头调取中..");
            //WeiXin JSSDK
            appIdVal = document.getElementById("appIdVal").value;
            timestampVal = document.getElementById("timestampVal").value;
            nonceStrVal = document.getElementById("nonceStrVal").value;
            signatureVal = document.getElementById("signatureVal").value;
            userid = document.getElementById("useridVal").value;
            scanCtrl = document.getElementById("ScanCtrl").value;
            // bs = document.getElementById("BS").value;
            if (userid == "" || userid == "0") {
                HideLoading();
                alert("用户未登陆,不可用");
                history.go(-1);
            } else {
                llApp.init();
                setTimeout(function () {
                    if (isInApp) {
                        scan();
                    } else {
                        jsConfig();
                    }
                }, 500)
            }
        });
        /********************签名**********************/
        function jsConfig() {
            wx.config({
                debug: false,
                appId: appIdVal, // 必填，公众号的唯一标识
                timestamp: timestampVal, // 必填，生成签名的时间戳
                nonceStr: nonceStrVal, // 必填，生成签名的随机串
                signature: signatureVal, // 必填，签名，见附录1
                jsApiList: ['scanQRCode'] // 必填，需要使用的JS接口列表，所有JS接口列表见附录2
            });
            wx.ready(function () {
                scan();
            });
            wx.error(function (res) {
                alert(allPrpos(res));
                alert("JS注入失败！");
            });
        }

        /*
        * 用来遍历指定对象所有的属性名称和值
        * obj 需要遍历的对象
        * author: Jet Mah
        * website: http://www.javatang.com/archives/2006/09/13/442864.html 
        */
        function allPrpos(obj) {
            // 用来保存所有的属性名称和值
            var props = "";
            // 开始遍历
            for (var p in obj) {
                // 方法
                if (typeof (obj[p]) == "function") {
                    obj[p]();
                } else {
                    // p 为属性名称，obj[p]为对应属性的值
                    props += p + "=" + obj[p] + "\t";
                }
            }
            // 最后显示所有的属性
            return props;
        }

        function scan() {
            //isInApp = false;
            if (isInApp) {
                llApp.scanQRCode(function (result) {
                    goScan(result);
                });
            } else {
                wx.scanQRCode({
                    desc: 'scanQRCode desc',
                    needResult: 1, // 默认为0，扫描结果由微信处理，1则直接返回扫描结果，
                    scanType: ["qrCode", "barCode"], // 可以指定扫二维码还是一维码，默认二者都有
                    success: function (res) {
                        goScan(res.resultStr); // 当needResult 为 1 时，扫码返回的结果 
                    }
                });
            }
        };

        function goScan(result) {
            ShowLoading("信息获取中..");
            if (result.indexOf(",") > -1) {
                result = result.split(",")[1];
            }
            HideLoading();
            var checkInfo = getInfo(result);
            // console.dir(result);
            if (checkInfo.result == "Successed") {
                //console.dir(checkInfo);
                var dqkey = checkInfo.key;
                //获取按钮权限json  --》格式  { "裁剪接收": "sub","取消":"iscancel"}
                var buts = getBtnJson(checkInfo);
                //获取显示的HTML字符串
                var showHtml = getShowHtml(checkInfo);

                $.prompt(showHtml,
                       {
                           title: "样衣信息",
                           buttons: buts,
                           submit: function (e, v, m, f) {
                               // use e.preventDefault() to prevent closing when needed or return false. 
                               // e.preventDefault(); 
                               if (v == "iscancel") {
                                   //scan();
                                   //close中直接调用
                               } else {
                                   ajaxSubmit(checkInfo.key, checkInfo.yphh); //一定是同步ajax
                               }
                           },
                           close: function (event, value, message, formVals) {
                               //关闭的时候就会调用这个函数,
                               scan();
                           }
                       });


            } else if (checkInfo.result == "Error") {
                //console.dir(checkInfo);
                //alert("二维码信息查询错误" + "[" + checkInfo.state + "-" + checkInfo.errrorMessage + "]");
                alert("二维码信息查询错误");
                scan();
            } else if (checkInfo.result == "netError") {
                alert("网络错误");
                scan();
            } else if (checkInfo.result == "Pro") {

            }
        };
        //ajax提交
        function ajaxSubmit(key, yphh) {
            //裁剪接收：key,fzlx,yphh,userid,fzmc
            //发料节点获取xmjl,bs
            try {
                xmjlid = document.getElementById("xmjl").value;
                bsid = document.getElementById("bs").value;
            } catch (e) { }
            if (xmjlid == "") { xmjlid = 0;}
            if (bsid == "") { bsid = 0;}

            var subData = { key: key, fzlx: fzlx, yphh: yphh, userid: document.getElementById("useridVal").value, fzmc: fzmc, xmjlid: xmjlid, bsid: bsid };
            subData.ctrl = scanCtrl + "_save";
            //alert( JSON.stringify(subData));
            $.ajax({
                type: "POST",
                timeout: 1000,
                async: false,
                contentType: "application/x-www-form-urlencoded; charset=utf-8",
                url: "yf_cl_cpkfjs_core.aspx",
                data: subData,
                success: function (msg) {
                    var msgObj = eval("(" + msg + ")");
                    if (msgObj.result == "Successed") {
                        if (msgObj.state == "ok") {
                            alert("处理成功");
                        } else {
                            alert("处理失败");
                        }
                    } else if (msgObj.result == "Error") {
                        alert(msgObj.state);
                    } else {
                        alert(msg);
                    }

                },
                error: function (XMLHttpRequest, textStatus, errorThrown) {
                    alert("您的网络好像有点问题，请重试！");
                }
            });

        }

        //获取二维码对应信息
        function getInfo(result) {
            var obj = null;
            //post数据
            var subData = { info: result, userid: document.getElementById("useridVal").value }
            subData.ctrl = scanCtrl + "_getInfo";
            var url = "yf_cl_cpkfjs_core.aspx";
            if (scanCtrl == "proMake") {
                //url = "test.aspx?yphh="+result;
                url = "http://webt.lilang.com:9001/tl_yf/yf_cl_ProductMake_prt.aspx?yphh=" + result;
                //url = "http://192.168.35.231/tl_yf/yf_cl_ProductMake_prt.aspx?yphh=" + result;
                open(url);

            } else {

                $.ajax({
                    type: "POST",
                    timeout: 1000,
                    async: false,
                    contentType: "application/x-www-form-urlencoded; charset=utf-8",
                    url: url,
                    data: subData,
                    success: function (msg) {
                        obj = eval("(" + msg + ")");
                        //console.dir(msg);
                    },
                    error: function (XMLHttpRequest, textStatus, errorThrown) {
                        obj = { result: 'netError' };
                    }
                });
                return obj;
            }

        }
        //获取显示的html字符串
        function getShowHtml(objJson) {
            var showHtml = "";
            if (scanCtrl == "ypcjjs") {
                fzlx = "2";
                fzmc = '裁剪组'; //赋默认值
                showHtml += "<div style='font-size:15px;'>操作分类:裁剪接收</br>";
                showHtml += "样品货号:" + objJson.yphh + "</br>产品风格:" + objJson.spfg + "</br>商品名称:" + objJson.splbmc
                showHtml += "</br>打版状态:" + (objJson.jsqrbs == 1 ? "已打版" : "未打版") + "</br>裁剪状态:" + (objJson.cjjsbs == 1 ? "已裁剪接收" : "未裁剪接收")
                showHtml += "</br></br><label style='font-size:20px;'><input name='moban'style='width:20px;height:20px;' checked id='moban' type='radio' checked onclick='getfz(value,2)' value='裁剪组' />裁剪组</label>"
                showHtml += "<label style='font-size:20px;'><input style='width:20px;height:20px;' name='moban' id='moban' type='radio' onclick='getfz(value,1)' value='个人' />个人</label>";
                if (objJson.CS == "false") {
                    showHtml += "</br></br><span style='color:red'>您无权限进行此模块操作！</span>";
                } else if (objJson.CS == "wsj") {
                    showHtml += "</br></br><span style='color:red'>无当前用户数据！</span>";
                } else if (objJson.cjjsbs == 1) {
                    showHtml += "</br></br><span style='color:red'>该样号已裁剪接收，无需再次扫码！</span>";
                } else if (objJson.jsqrbs == 0) {
                    showHtml += "</br></br><span style='color:red'>该样号打版未接收，请先处理后在裁剪接收！</span>";
                } else {
                    showHtml += "</br></br>请选择是否裁剪接收,若不想接收请选择[取消]";
                }
                showHtml += "</div>";
            } else if (scanCtrl == "ypcjfl") {
                fzlx = "1";
                fzmc = '个人'; //赋默认值
                showHtml += "<div style='font-size:15px;'>操作分类:裁剪发料</br>";
                showHtml += "样品货号:" + objJson.yphh + "</br>产品风格:" + objJson.spfg + "</br>商品名称:" + objJson.splbmc
                showHtml += "</br>项目经理:" + objJson.xmjl + "</br>版师:" + objJson.bs
                showHtml += "<input name='xmjl' type='hidden' id='xmjl' value='" + objJson.xmjlid + "' /><input name='bs' type='hidden' id='bs' value='" + objJson.bsid + "' />";
                showHtml += "</br>裁剪接收:" + (objJson.cjjsbs == 1 ? "已接收" : "未接收") + "</br>裁剪发料:" + (objJson.cjflbs == 1 ? "已裁剪发料" : "未裁剪发料")
                showHtml += "</br></br><label style='font-size:20px;'><input name='moban' style='width:20px;height:20px;' id='moban' type='radio' checked onclick='getfz(value,1)' value='个人' />个人</label>";
                for (i = 0; i < objJson.num ; i++) {
                    var fz = objJson.fz.split(";");
                    showHtml += "<label style='font-size:20px;'><input name='moban' style='width:20px;height:20px;' id='moban' type='radio' onclick='getfz(value,2)' value='" + fz[i] + "' />" + fz[i] + "</label>"
                }
                if (objJson.CS == "false") {
                    showHtml += "</br></br><span style='color:red'>您无权限进行此模块操作！</span>";
                } else if (objJson.CS == "wsj") {
                    showHtml += "</br></br><span style='color:red'>无当前用户数据！</span>";
                } else if (objJson.cjflbs == 1) {
                    showHtml += "</br></br><span style='color:red'>该样号已裁剪发料，无需再次扫码！</span>";
                } else if (objJson.cjjsbs == 0) {
                    showHtml += "</br></br><span style='color:red'>该样号未裁剪接收，请先处理后在裁剪发料！</span>";
                } else {
                    showHtml += "</br></br>请选择是否裁剪发料,若不想接收请选择[取消]";
                }
                showHtml += "</div>";
            } else if (scanCtrl == "ypwgqr") {
                showHtml += "<div style='font-size:15px;'>操作分类:样衣完工确认</br>";
                showHtml += "样品货号:" + objJson.yphh + "</br>产品风格:" + objJson.spfg + "</br>商品名称:" + objJson.splbmc
                showHtml += "</br>完工状态:" + (objJson.zyjsbs == 1 ? "已完工确认" : "未完工确认")
                if (objJson.CS == "false") {
                    showHtml += "</br></br><span style='color:red'>您无权限进行此模块操作！</span>";
                } else if (objJson.CS == "wsj") {
                    showHtml += "</br></br><span style='color:red'>无当前用户数据！</span>";
                }
                else if (objJson.zyjsbs == 1) {
                    showHtml += "</br></br><span style='color:red'>该样号已完工确认，无需再次扫码！</span>";
                } else if (objJson.cjflbs == 0) {
                    showHtml += "</br></br><span style='color:red'>该样号未裁剪发料，请先处理后在完工确认！</span>";
                } else {
                    showHtml += "</br></br>请选择是否样衣完工确认,若不想接收请选择[取消]";
                }
                showHtml += "</div>";

            } else if (scanCtrl == "ypxxcx") {
                showHtml += "<div style='font-size:15px;'>";
                showHtml += "样品货号:" + objJson.yphh + "</br>产品风格:" + objJson.spfg + "</br>商品名称:" + objJson.splbmc
                showHtml += "</br>主&nbsp;面&nbsp;料:" + objJson.chmc + "</br>成&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;份:" + objJson.cfbl
                showHtml += "</br>价&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;格:" + objJson.dj + "</br>供&nbsp;&nbsp;应&nbsp;&nbsp;商:" + objJson.ghsmc
                showHtml += "</br>项目经理:" + objJson.xmjl + "</br>版&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;师:" + objJson.bs
                showHtml += "</br>裁&nbsp;&nbsp;剪&nbsp;&nbsp;师:" + objJson.cjs + "</br>技&nbsp;&nbsp;术&nbsp;&nbsp;员:" + objJson.yyg
                showHtml += "</br>当前状态:" + (objJson.cjjsbs == 0 ? "未领料" : objJson.cjflbs == 0 ? "未发料" : objJson.zyjsbs == 0 ? "未完工确认" : "已完工确认")
                showHtml += "<input name='xmjl' type='hidden' id='xmjl' value='" + objJson.xmjlid + "' /><input name='bs' type='hidden' id='bs' value='" + objJson.bsid + "' />";
                showHtml += "</div>";

            } else if (scanCtrl == "ypzjts") {
                showHtml += "<div style='font-size:15px;'>操作分类:专机烫衬</br>";
                showHtml += "样品货号:" + objJson.yphh + "</br>产品风格:" + objJson.spfg + "</br>商品名称:" + objJson.splbmc;
                showHtml += "</br>烫衬人员:" + objJson.tsry;
                showHtml += "</br>烫衬接收时间:" + objJson.tsrq;
                if (objJson.CS == "false") {
                    showHtml += "</br></br><span style='color:red'>您无权限进行此模块操作！</span>";
                } else if (objJson.CS == "wsj") {
                    showHtml += "</br></br><span style='color:red'>无当前用户数据！</span>";
                } else if (objJson.cjjsbs == 0) {
                    showHtml += "</br></br><span style='color:red'>该样号未裁剪接收，请先处理后再烫衬接收！</span>";
                } else if (objJson.cjflbs == 1) {
                    showHtml += "</br></br><span style='color:red'>该样号已裁剪发料，烫衬接收结束！</span>";
                } else if (objJson.zyjsbs == 1) {
                    showHtml += "</br></br><span style='color:red'>该样号已完工确认，烫衬接收结束！</span>";
                } else {
                    showHtml += "</br></br>请选择是否专机烫衬,若不想接收请选择[取消]";
                }
                showHtml += "</div>";

            } else if (scanCtrl == "ypzjdk") {
                showHtml += "<div style='font-size:15px;'>操作分类:专机打扣</br>";
                showHtml += "样品货号:" + objJson.yphh + "</br>产品风格:" + objJson.spfg + "</br>商品名称:" + objJson.splbmc
                showHtml += "</br>打扣人员:" + objJson.tsry;
                showHtml += "</br>打扣接收时间:" + objJson.tsrq;
                if (objJson.CS == "false") {
                    showHtml += "</br></br><span style='color:red'>您无权限进行此模块操作！</span>";
                } else if (objJson.CS == "wsj") {
                    showHtml += "</br></br><span style='color:red'>无当前用户数据！</span>";
                } else if (objJson.cjjsbs == 0) {
                    showHtml += "</br></br><span style='color:red'>该样号未裁剪接收，请先处理后再打扣接收！</span>";
                } else if (objJson.cjflbs == 0) {
                    showHtml += "</br></br><span style='color:red'>该样号未裁剪发料，请先处理后再打扣接收</span>";
                } else if (objJson.zyjsbs == 1) {
                    showHtml += "</br></br><span style='color:red'>该样号已完工确认，烫衬接收结束！</span>";
                } else {
                    showHtml += "</br></br>请选择是否专机打扣,若不想接收请选择[取消]";
                }
                showHtml += "</div>";

            }

            return showHtml;

        }
        //获取分组组名,并设置保存方式
        function getfz(val, zid) {
            fzmc = val;
            fzlx = zid;            
        }
        //获取按钮配置的json
        function getBtnJson(objJson) {
            var buts = {};

            if (objJson.cjjsbs == 0 && scanCtrl == "ypcjjs" && objJson.jsqrbs == 1 && objJson.CS == "ok") {
                buts.确认 = "sub";
            } else if (objJson.cjflbs == 0 && scanCtrl == "ypcjfl" && objJson.cjjsbs == 1 && objJson.CS == "ok") {
                buts.确认 = "sub";
            } else if (objJson.zyjsbs == 0 && scanCtrl == "ypwgqr" && objJson.cjflbs == 1 && objJson.CS == "ok") {
                buts.确认 = "sub";
            } else if ((scanCtrl == "ypzjts" || scanCtrl == "ypzjdk") && objJson.zyjsbs == 0 && objJson.cjjsbs == 1) {
                buts.确认 = "sub";
            }
            if (scanCtrl != "ypxxcx") {
                buts.取消 = "iscancel";
            } else {
                buts.关闭 = "iscancel";
            }
            return buts;
        }
        //显示加载栏目
        function ShowLoading(Info, ShowTime) {
            if (ShowTime == undefined || ShowTime == "undefined") {
                ShowTime = 15;      //默认弹出15s
            };
            $("#LoadingInfo").html(Info);
            var $loadingToast = $('#loadingToast');
            if ($loadingToast.css('display') != 'none') {
                return;
            }

            $loadingToast.show();
            setTimeout(function () {
                $loadingToast.hide();
            }, ShowTime * 1000);
        }

        function HideLoading() {
            $('#loadingToast').hide();
        }
    </script>

</head>
<body>
    <input type="hidden" runat="server" id="appIdVal" />
    <input type="hidden" runat="server" id="timestampVal" />
    <input type="hidden" runat="server" id="nonceStrVal" />
    <input type="hidden" runat="server" id="signatureVal" />
    <input type="hidden" runat="server" id="useridVal" />
    <input type="hidden" runat="server" id="ScanCtrl" />
    <!-- loading toast -->
    <div id="loadingToast" class="weui_loading_toast" style="display: none; position: fixed; z-index: 99999">
        <div class="weui_mask_transparent"></div>
        <div class="weui_toast">
            <div class="weui_loading">
                <div class="weui_loading_leaf weui_loading_leaf_0"></div>
                <div class="weui_loading_leaf weui_loading_leaf_1"></div>
                <div class="weui_loading_leaf weui_loading_leaf_2"></div>
                <div class="weui_loading_leaf weui_loading_leaf_3"></div>
                <div class="weui_loading_leaf weui_loading_leaf_4"></div>
                <div class="weui_loading_leaf weui_loading_leaf_5"></div>
                <div class="weui_loading_leaf weui_loading_leaf_6"></div>
                <div class="weui_loading_leaf weui_loading_leaf_7"></div>
                <div class="weui_loading_leaf weui_loading_leaf_8"></div>
                <div class="weui_loading_leaf weui_loading_leaf_9"></div>
                <div class="weui_loading_leaf weui_loading_leaf_10"></div>
                <div class="weui_loading_leaf weui_loading_leaf_11"></div>
            </div>
            <p class="weui_toast_content" id="LoadingInfo">数据加载中</p>
        </div>
    </div>

</body>
</html>
