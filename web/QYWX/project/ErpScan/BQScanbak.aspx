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
        string SystemKey = "";
        string ctrl = Convert.ToString(Request.Params["ctrl"]);
        if (ctrl == "" || ctrl == null)
        {
            if (clsWXHelper.CheckQYUserAuth(true))
            {
                //鉴权成功之后，获取 系统身份SystemKey
                string SystemID = "1";
                SystemKey = clsWXHelper.GetAuthorizedKey(Convert.ToInt32(SystemID));
            }
            
            WxHelper cs = new WxHelper();
            string OAappID = "wxe46359cef7410a06";
            string OAappSecret = "w0IiKV3RGY6lzcx1QjdzMdWfhVMJEFOmnl_6HpYzfCgyNpORbyj6wlBnvmv2bw7x";
            string[] config = cs.GetWXQYJsApiConfig(OAappID, OAappSecret);
            appIdVal.Value = config[0];
            timestampVal.Value = config[1];
            nonceStrVal.Value = config[2];
            signatureVal.Value = config[3];
            useridVal.Value = SystemKey;
            //Response.Write(SystemKey);
            //Response.End();

        }
        else if (ctrl == "getBQInfo")
        {
            //获取二维码对应的信息                
            try
            {
                DataTable dt = null;
                string errInfo = "";
                string bq = Convert.ToString(Request.Params["info"]);

                using (LiLanzDALForXLM dal = new LiLanzDALForXLM(OAConnStr))
                {
                    string str_sql = @"
                         DECLARE @bq varchar(max) ;   
                         SET @bq=@bq_in;                     
                         select distinct a.chdm,  ch.chdm,ch.chmc,a.bzdh,a.yfcwdj,kh.khmc,yp.yfcb_hj,yp.ypmc,yp.yphh,yp.mlcf,yp.lsdj,bj.tpname as tpsrc from yf_T_bom a 
                         inner join cl_t_chdmb ch on a.chdm=ch.chdm 
                         inner join yx_T_ypdmb yp on yp.yphh=a.yphh and (yp.bq=@bq or yp.yphh=@bq)
                         inner join yx_T_khb kh on kh.khid=ch.ghsid 
                         left join yf_t_bjdlb bj on ch.bjid=bj.id and ch.chdm=bj.chdm    
                            order by a.chdm 
                         ";
                    List<SqlParameter> para = new List<SqlParameter>();
                    para.Add(new SqlParameter("@bq_in", bq));
                    errInfo = dal.ExecuteQuerySecurity(str_sql, para, out dt);

                }
                Response.Clear();
                if (dt.Rows.Count == 0)
                {
                    Response.Write("{result:'NoRows',state:'have no rows'}");
                }
                else
                {
                    string jsonChinfo = "";
                    foreach (DataRow dr in dt.Rows)
                    {
                        jsonChinfo += "{chdm:\"" + dr["chdm"].ToString() + "\",chmc:\"" + dr["chmc"].ToString() + "\",bzdh:\"" + dr["bzdh"].ToString() + "\",dj:\"" + dr["yfcwdj"].ToString() + "\",khmc:\"" + dr["khmc"].ToString() + "\",tpsrc:\"" + dr["tpsrc"].ToString() + "\"},";
                    }
                    //,ypmc:\"" + dr["ypmc"].ToString() + "\",yphh:\"" + dr["yphh"].ToString() + "\",mlcf:\"" + dr["mlcf"].ToString() + "\",lsdj:\"" + dr["lsdj"].ToString() + "
                    Response.Write("{result:'Successed',chdmarray:[" + jsonChinfo.Substring(0, jsonChinfo.Length - 1) + "],yphhcb:'" + dt.Rows[0]["yfcb_hj"].ToString() + "',ypmc:'" + dt.Rows[0]["ypmc"].ToString() + "',yphh:'" + dt.Rows[0]["yphh"].ToString() + "',mlcf:'" + dt.Rows[0]["mlcf"].ToString() + "',lsdj:'" + dt.Rows[0]["lsdj"].ToString() + "'}");
                }
            }
            catch (SystemException ex)
            {
                Response.Clear();
                Response.Write("{result:'Error',state:'" + ex.Message + "'}");
            }
            finally
            {
                Response.End();
            }
        }
        else if (ctrl == "getChdmBJInfo")
        {
            //材料报价信息
            try
            {
                DataTable dt = null;
                string errInfo = "";
                string chdm = Convert.ToString(Request.Params["info"]);
                using (LiLanzDALForXLM dal = new LiLanzDALForXLM(OAConnStr))
                {
                    string str_sql = @"
                         DECLARE @chdm varchar(max) ;   SET @chdm=@chdm_in;                     
                         SELECT c.mc, mx.sz  
                        FROM dbo.Yf_T_bjdlb a
                        INNER JOIN dbo.Yf_T_bjdlxb b ON a.lxid=b.id AND b.bz='面料' 
                        INNER JOIN dbo.Yf_T_bjdmxb mx ON mx.mxid=a.id AND ISNULL(mx.lydjlx,0)=0
                        INNER JOIN dbo.Yf_T_bjdbjzb c ON c.id=mx.zbid
                        WHERE a.chdm=@chdm;                            
                         ";
                    List<SqlParameter> para = new List<SqlParameter>();
                    para.Add(new SqlParameter("@chdm_in", chdm));
                    errInfo = dal.ExecuteQuerySecurity(str_sql, para, out dt);

                }
                Response.Clear();
                if (dt.Rows.Count == 0)
                {
                    Response.Write("{result:'NoRows',state:'have no rows'}");
                }
                else
                {
                    string jsonChinfo = "";
                    foreach (DataRow dr in dt.Rows)
                    {
                        jsonChinfo += "{mc:\"" + dr["mc"].ToString() + "\",sz:\"" + dr["sz"].ToString() + "\"},";
                    }
                    Response.Write("{result:'Successed',bjinfoarray:[" + jsonChinfo.Substring(0, jsonChinfo.Length - 1) + "]}");
                }
            }
            catch (SystemException ex)
            {
                Response.Clear();
                Response.Write("{result:'Error',state:'" + ex.Message + "'}");
            }
            finally
            {
                Response.End();
            }
        }
    }
</script>
<html lang="en" xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <meta charset="utf-8" />
    <meta name="viewport" content="height=device-height,width=device-width,initial-scale=1.0,minimum-scale=1.0,maximum-scale=1.0,user-scalable=no" />
    <meta name="format-detection" content="telephone=yes" />
    <title></title>
    <script type="text/javascript" src="../../res/js/jquery.js"></script>
    <script type="text/javascript" src="http://res.wx.qq.com/open/js/jweixin-1.0.0.js"></script>
    <link rel="Stylesheet" href="../../res/css/LeePageSlider.css" />
    <link rel="Stylesheet" href="../../res/css/ErpScan/bootstrap.css" />
    <link href="../../res/css/sweet-alert.css" rel="stylesheet" type="text/css" />
    <script src="../../res/js/sweet-alert.min.js" type="text/javascript"></script>
    <style type="text/css">
        body
        {
            font-size: 14px;
            line-height: 20px;
        }
    </style>
    <script type="text/javascript">
        var appIdVal, timestampVal, nonceStrVal, signatureVal;

        $(document).ready(function () {

            //WeiXin JSSDK
            appIdVal = document.getElementById("appIdVal").value;
            timestampVal = document.getElementById("timestampVal").value;
            nonceStrVal = document.getElementById("nonceStrVal").value;
            signatureVal = document.getElementById("signatureVal").value;
            //alert(appIdVal);   
           
            if (document.getElementById("useridVal").value == "" || document.getElementById("useridVal").value == "0") {
                //用户不可用
                alert("鉴权不成功");
                document.getElementById("ctrlScan").style.display = "none";
            } else {
                var arr = [10, 365, 677, 6551, 11665, 12742, 13902, 15976, 17557, 18732, 1036, 119, 332,116 ,11062];
                if (arr.indexOf(Number(document.getElementById("useridVal").value)) >= 0) {
                    jsConfig();
                } else {
                    alert("无权限");
                    document.getElementById("ctrlScan").style.display = "none";
                }
                
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
                //alert("ready");
                //scan();
            });
            wx.error(function (res) {
                alert(allPrpos(res));
                alert("JS注入失败！");
            });
        }



        function scan() {
            wx.scanQRCode({
                desc: 'scanQRCode desc',
                needResult: 1, // 默认为0，扫描结果由微信处理，1则直接返回扫描结果，
                scanType: ["barCode"], // 可以指定扫二维码还是一维码，默认二者都有
                success: function (res) {
                    var result = res.resultStr.split(",")[1]; // 当needResult 为 1 时，扫码返回的结果                 

                    var checkInfo = getBQInfo(result);

                    if (checkInfo.result == "Successed") {
                        addLog(result);//增加扫描记录
                        createChdmListHtml(checkInfo);//构造材料列表
                        showChdmList();//显示材料列表                     
                    } else if (checkInfo.result == "Error") {

                        swal({
                            title: "提示信息",
                            text: "二维码信息查询错误",
                            type: "error",
                        }, function () {
                            scan();
                        });
                    } else if (checkInfo.result == "netError") {
                        swal({
                            title: "提示信息",
                            text: "网络错误",
                            type: "error",
                        }, function () {
                            scan();
                        });
                    } else if (checkInfo.result == "NoRows") {
                        swal({
                            title: "提示信息",
                            text: "查无数据,请检查当前用户是否有权限",
                            type: "error",
                        }, function () {
                            scan();
                        });
                    }

                }
            });
        };

        //构造材料代码列表
        function createChdmListHtml(checkInfo) {
            var chdmarray = checkInfo.chdmarray
            $(".chxxcontent", "#chxx").remove();

            document.getElementById("yphhcb").value = checkInfo.yphhcb;
            if (checkInfo.ypmc.split("-").length = 2) {
                document.getElementById("ypmc").value = checkInfo.ypmc.split("-")[0];
                document.getElementById("ys").value = checkInfo.ypmc.split("-")[1];
            } else {
                document.getElementById("ypmc").value = checkInfo.ypmc;
                document.getElementById("ys").value = "";
            }
            document.getElementById("yphh").value = checkInfo.yphh;
            document.getElementById("mlcf").value = checkInfo.mlcf;

            var trBgClass;
            for (var i = 0; i < chdmarray.length; i++) {

                if (i % 2 == 0) {
                    trBgClass = "info"
                } else {
                    trBgClass = "success"
                }
                $("#chxx").append("<tr class='chxxcontent " + trBgClass + "' ><td colspan=\"4\" >" + chdmarray[i].khmc + "</td></tr>")
                $("#chxx").append("<tr class='chxxcontent " + trBgClass + "'><td><a href='#' onclick='chdmBJInfo(this)'>" + chdmarray[i].chdm + "</a></td><td style='white-space: normal;'>" + chdmarray[i].chmc + "</td><td>" + ForDight(chdmarray[i].dj, 2) + "</td><td>" + ForDight(chdmarray[i].bzdh, 2) + "</td></tr>");

                var tpsrc = chdmarray[i].tpsrc;                                
                //var divcss, imgcss;
                //if (tpsrc.length > 0) {
                //    if (tpsrc.indexOf("http") < 0) {
                //        tpsrc = "../" + tpsrc;
                //    }                    
                //    var width = 200;                    
                //    divcss = "style=\"width:" + width + "px;overflow:hidden;\""
                //    imgcss = "style=\"width:" + width + "px;\""

                //    $("#chxx").append("<tr class='chxxcontent " + trBgClass + "' ><td colspan=\"4\" >" + "<div " + divcss + "><img onclick='window.open(\"../tl_yf/cl_cx_Materil.aspx?chdm=" + chdmarray[i].chdm + "\")' " + imgcss + " src='../tl_yf/ImageTurnShow.aspx?src=" + tpsrc + "' /></div>" + "</td></tr>")
                //} else {
                //}

                
            }
        }

        //单击材料列表事件
        function chdmBJInfo(obj) {
            var bjInfo = getChdmBJInfo(obj);
            createBJInfoHtml(bjInfo.bjinfoarray);
            showBJInfo();
        }

        //构造报价HTML
        function createBJInfoHtml(infoarray) {
            $(".bjxxcontent", "#bjxx").remove();
            for (var i = 0; i < infoarray.length; i++) {
                $("#bjxx").append("<tr class='bjxxcontent'><td>" + infoarray[i].mc + "</td><td>" + infoarray[i].sz + "</td></tr>");
            }

        }

        //获取条码对应信息
        function getBQInfo(result) {
            var obj = null;
            $.ajax({
                type: "POST",
                timeout: 1000,
                async: false,
                contentType: "application/x-www-form-urlencoded; charset=utf-8",
                url: "bqscan.aspx",
                data: { ctrl: "getBQInfo", info: result },
                success: function (msg) {
                    obj = eval("(" + msg + ")");
                },
                error: function (XMLHttpRequest, textStatus, errorThrown) {
                    obj = { result: 'netError' };
                }
            });
            return obj;
        }

        //增加一个扫描历史
        function addLog(bq) {
            $("#mylog").append("<div class=\"row\"><div class=\"col-md-1\"><a href=\"#\" onclick=\"bqLogSearch(this)\" >" + bq + "</a></div></div>");
        }

        //查询历史扫描记录
        function bqLogSearch(obj) {
            var checkInfo = getBQInfo(obj.innerHTML);
            createChdmListHtml(checkInfo);//构造材料列表
            showChdmList();//显示材料列表
        }

        //显示扫描页
        function showScan() {
            $("#pagescan").attr("class", "page ");
            $("#pagechdm").attr("class", "page page-right");
            $("#pagebjinfo").attr("class", "page page-right");
        }

        //显示材料列表
        function showChdmList() {
            $("#pagescan").attr("class", "page page-right");
            $("#pagechdm").attr("class", "page ");
            $("#pagebjinfo").attr("class", "page page-right");
        }

        //显示材料报价信息
        function showBJInfo() {
            $("#pagescan").attr("class", "page page-right");
            $("#pagechdm").attr("class", "page page-right");
            $("#pagebjinfo").attr("class", "page");
        }

        //获取材料报价信息
        function getChdmBJInfo(obj) {
            var chdm = obj.innerHTML;
            var obj = null;
            $.ajax({
                type: "POST",
                timeout: 1000,
                async: false,
                contentType: "application/x-www-form-urlencoded; charset=utf-8",
                url: "bqscan.aspx",
                data: { ctrl: "getChdmBJInfo", info: chdm },
                success: function (msg) {
                    obj = eval("(" + msg + ")");
                },
                error: function (XMLHttpRequest, textStatus, errorThrown) {
                    obj = { result: 'netError' };
                }
            });
            return obj;
        }

        //取小数位
        function ForDight(Dight, How) {
            Dight = Math.round(Dight * Math.pow(10, How)) / Math.pow(10, How);
            return Dight;
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

        function goscan() {
            if (document.getElementById("serinfo").value.length > 0) {

                var result = document.getElementById("serinfo").value
            

                var checkInfo = getBQInfo(result);

                if (checkInfo.result == "Successed") {
                    addLog(result);//增加扫描记录
                    createChdmListHtml(checkInfo);//构造材料列表
                    showChdmList();//显示材料列表                     
                } else if (checkInfo.result == "Error") {

                    swal({
                        title: "提示信息",
                        text: "二维码信息查询错误",
                        type: "error",
                    }, function () {
                       
                    });
                } else if (checkInfo.result == "netError") {
                    swal({
                        title: "提示信息",
                        text: "网络错误",
                        type: "error",
                    }, function () {
                       
                    });
                } else if (checkInfo.result == "NoRows") {
                    swal({
                        title: "提示信息",
                        text: "查无数据,请检查当前用户是否有权限",
                        type: "error",
                    }, function () {
                       
                    });
                }
            }
        }
    </script>
</head>
<body>
    <form id="form1" runat="server">

        <div class="wrap-page">

            <div id="pagescan" class="page">
                <div class="form-group">
                    <label for="yphhcb">样号/标签:</label>
                    <input type="text" class="form-control" id="serinfo" />
                </div>
                <input type="button"  style="margin-top: 20px" class="btn btn-default btn-lg btn-block" onclick="goscan()" value="查询" />

                <input type="button" id="ctrlScan" style="margin-top: 20px" class="btn btn-default btn-lg btn-block" onclick="scan()" value="扫描" />

                <div id="mylog">
                    <div class="row">
                        <div class="col-md-1">扫描记录</div>
                    </div>
                </div>
            </div>

            <div id="pagechdm" class="page page-right">
                <div class="form-group">
                    <input type="button"   onclick="showScan()" value="返回" class="btn btn-default" />
                </div>

                <div class="form-group">
                    <label for="yphhcb">品名:</label>
                    <input type="text" class="form-control" id="ypmc" />
                </div>
                <div class="form-group">
                    <label for="yphhcb">颜色:</label>
                    <input type="text" class="form-control" id="ys" />
                </div>
                <div class="form-group">
                    <label for="yphhcb">样号:</label>
                    <input type="text" class="form-control" id="yphh" />
                </div>

                <div class="form-group">
                    <label for="yphhcb">面料成份:</label>
                    <input type="text" class="form-control" id="mlcf" />
                </div>
                <div class="form-group">
                    <label for="yphhcb">零售价:</label>
                    <input type="text" class="form-control" id="lsdj" />
                </div>
                <div class="form-group">
                    <label for="yphhcb">总成本:</label>
                    <input type="text" class="form-control" id="yphhcb" />
                </div>


                <div class="table-responsive">
                    <table id="chxx" style="table-layout:fixed" class="table table-bordered">
                        <tr class="chxxhead">
                            <td style="width:110px;">材料编号</td>
                            <td>材料名称</td>
                            <td style="width:50px;">单价</td>
                            <td style="width:50px;white-space: normal;">单耗</td>
                        </tr>
                    </table>
                </div>

            </div>
            <div id="pagebjinfo" class="page page-right">
                <div class="form-group">
                    <input type="button"   onclick="showChdmList()" value="返回" class="btn btn-default" />
                </div>
                <div class="table-responsive">
                    <table id="bjxx" class="table table-bordered">
                        <tr class="bjxxhead">
                            <td>名称</td>
                            <td>数值</td>
                        </tr>
                    </table>
                </div>
            </div>

        </div>
        <input type="hidden" runat="server" id="appIdVal" />
        <input type="hidden" runat="server" id="timestampVal" />
        <input type="hidden" runat="server" id="nonceStrVal" />
        <input type="hidden" runat="server" id="signatureVal" />
        <input type="hidden" runat="server" id="useridVal" />
    </form>


</body>
</html>
