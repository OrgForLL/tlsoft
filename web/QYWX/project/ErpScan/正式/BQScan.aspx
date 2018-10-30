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
            if (clsWXHelper.CheckQYUserAuth(true))
            {
                //鉴权成功之后，获取 系统身份SystemKey
                string SystemID = "1";
                SystemKey = clsWXHelper.GetAuthorizedKey(Convert.ToInt32(SystemID));
            }

            WxHelper cs = new WxHelper();
            //string OAappID = "wxe46359cef7410a06";
            //string OAappSecret = "w0IiKV3RGY6lzcx1QjdzMdWfhVMJEFOmnl_6HpYzfCgyNpORbyj6wlBnvmv2bw7x";
            //string[] config = cs.GetWXQYJsApiConfig(OAappID, OAappSecret);
            List<string> config = clsWXHelper.GetJsApiConfig("1");
            appIdVal.Value = config[0];
            timestampVal.Value = config[1];
            nonceStrVal.Value = config[2];
            signatureVal.Value = config[3];
            useridVal.Value = SystemKey;
            //Response.Write(SystemKey);
            //Response.End();
            DataTable dt = null;
            string errInfo = "";
            using (LiLanzDALForXLM dal = new LiLanzDALForXLM(OAConnStr))
            {
                string str_sql = @" select * from yf_V_wx_mobile where id=@user_in";
                List<SqlParameter> para = new List<SqlParameter>();
                para.Add(new SqlParameter("@user_in", useridVal.Value));
                errInfo = dal.ExecuteQuerySecurity(str_sql, para, out dt);
            }
            if (dt.Rows.Count == 0)
            {
                isPass.Value = "0";
            }else
            {
                isPass.Value = "1";
            }

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

                         select distinct  ch.chdm,ch.chmc,a.bzdh,a.yfcwdj,kh.khmc,yp.yfcb_hj,yp.ypmc,yp.yphh,yp.mlcf,yp.lsdj,ch.tp  as tpsrc ,ch.bjid,f.mc as zhml
                         into #yphhchdm 
                         from yf_T_bom a 
                         inner join cl_t_chdmb ch on a.chdm=ch.chdm 
                         inner join yx_T_ypdmb yp on yp.yphh=a.yphh and (yp.bq=@bq or yp.yphh=@bq)
                         inner join yx_T_khb kh on kh.khid=ch.ghsid 
                         left join yf_v_plxxclfz f on f.dm=a.mxwllb
                         left join yf_t_bjdlb bj on ch.bjid=bj.id and ch.chdm=bj.chdm    
                   

                         /*实验室*/
                         select a.chdm,b.zpdjg,b.id,row_number() over(partition by a.chdm order by b.id desc ) xh
                         into #lab
                         from (select bjid,chdm from #yphhchdm group by bjid,chdm) a 
                         inner join yf_T_bjdlb b on a.bjid=b.lydjid  
                         where b.lxid=518 and b.sylx in ('4','2')   and isnull(a.bjid,0)<>0           
                 
                         select l.zpdjg, a.zhml, a.chdm,a.chmc,a.bzdh,a.yfcwdj,a.khmc,a.yfcb_hj,a.ypmc,a.yphh,a.mlcf,a.lsdj,a.tpsrc ,l.zpdjg
                         from #yphhchdm a    
                         left join  #lab   l on l.xh=1 and l.chdm=a.chdm               
                            order by SUBSTRING(a.chdm,1,1) ,a.bzdh desc ,chmc
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
                        jsonChinfo += "{zpdjg:\"" + dr["zpdjg"].ToString() + "\",zhml:\"" + dr["zhml"].ToString() + "\",chdm:\"" + dr["chdm"].ToString() + "\",chmc:\"" + dr["chmc"].ToString() + "\",bzdh:\"" + dr["bzdh"].ToString() + "\",dj:\"" + dr["yfcwdj"].ToString() + "\",khmc:\"" + dr["khmc"].ToString() + "\",tpsrc:\"" + dr["tpsrc"].ToString() + "\"},";
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
        }else if (ctrl == "getChdmLabInfo")
        {
            //材料检测信息 
            try
            {
                DataTable dt = null;
                string errInfo = "";
                string chdm = Convert.ToString(Request.Params["info"]);
                using (LiLanzDALForXLM dal = new LiLanzDALForXLM(OAConnStr))
                {
                    string str_sql = @"
                         DECLARE @chdm varchar(max) ;   SET @chdm=@chdm_in;                     
                          /*实验室*/
                         select b.id,row_number() over(partition by a.chdm order by b.id desc ) xh
                         into #lab                   
                         from cl_T_chdmb a 
                         inner join yf_T_bjdlb b on a.bjid=b.lydjid  
                         where b.lxid=518 and b.sylx in ('4','2') and isnull(a.bjid,0)<>0 and  a.chdm=@chdm                           

                         select  b.mc,d.sytj,case c.bs when 1 then'≥' when 2 then'≤' when 3 then '包含于' when 4 then '/' end +convert(varchar(10),(case c.sfbh when 1 then '('+(c.bzz+','+c.bzz1)+')' when 0 then c.bzz end)) as bsbzz,a.sz jcjg,a.pdjg 
                         from yf_T_bjdmxb a
                         inner join yf_t_bjdlb bj on a.mxid=bj.id and bj.lxid=518
                         inner join yf_T_bjdbjzb b on a.zbid=b.id 
                         inner join yf_T_bjdbjzb c on a.bzzid=c.id 
                         inner join yf_T_bjdbjzb d on a.sytjid=d.id 
                         inner join #lab  xz on xz.xh=1 and xz.id=a.mxid
                         where   a.lxid=518 
                         order by a.bzzid

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
                        jsonChinfo += "{mc:\"" + dr["mc"].ToString() + "\",sytj:\"" + dr["sytj"].ToString() + "\",bsbzz:\"" + dr["bsbzz"].ToString() + "\",jcjg:\"" + dr["jcjg"].ToString() + "\",pdjg:\"" + dr["pdjg"].ToString() + "\"},";
                    }
                    Response.Write("{result:'Successed',labinfoarray:[" + jsonChinfo.Substring(0, jsonChinfo.Length - 1) + "]}");
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
    <script type="text/javascript" src="../../api/lilanzAppWVJBridge.js"></script>
    <script type="text/javascript" src="http://res.wx.qq.com/open/js/jweixin-1.0.0.js"></script>
    <link rel="Stylesheet" href="../../res/css/LeePageSlider.css" />
    <link rel="Stylesheet" href="../../res/css/ErpScan/bootstrap.css" />
    <link rel="Stylesheet" href="../../res/css/font-awesome.min.css" />
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
                var arr = [10, 365, 677, 6551, 11665, 12742, 13902, 15976, 17557, 18732, 1036, 119, 332, 116, 11062];
                if (Number(document.getElementById("isPass").value) == 1) {                 
                    llApp.init();                 
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
                        if (res.resultStr.split(",").length > 1) {
                            goScan(res.resultStr.split(",")[1]); // 当needResult 为 1 时，扫码返回的结果 
                        } else {
                            goScan(res.resultStr); // 当needResult 为 1 时，扫码返回的结果 
                        }
                    }
                });
            }
        };

        function goScan(result) {            
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
        //构造材料代码列表
        function createChdmListHtml(checkInfo) {
            var chdmarray = checkInfo.chdmarray
            //$(".chxxcontent", "#chxx").remove();
            $("#chxx").empty("");
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
                //                $("#chxx").append("<tr class='chxxcontent " + trBgClass + "' ><td colspan=\"4\" >" + chdmarray[i].khmc + "</td></tr>")
                //                $("#chxx").append("<tr class='chxxcontent " + trBgClass + "'><td><a href='#' onclick='chdmBJInfo(this)'>" + chdmarray[i].chdm + "</a></td><td style='white-space: normal;'>" + chdmarray[i].chmc + "</td><td>" + ForDight(chdmarray[i].dj, 2) + "</td><td>" + ForDight(chdmarray[i].bzdh, 2) + "</td></tr>");
                //list-group-item-" + trBgClass + ":背景
                var str = "<li  class='list-group-item ' onclick='chdmBJInfo(\"" + chdmarray[i].chdm + "\")' style='color:#555;'>";
                str+="<h4 class='list-group-item-heading'>" + chdmarray[i].khmc + "</h4>";
                str+="<p class='list-group-item-text'>材料编号:" + chdmarray[i].chdm + "";
                str += "<br/> 材料名称:" + chdmarray[i].chmc + " ";
                str += "<br/> 单价:" + ForDight(chdmarray[i].dj, 2) + " 单耗:" + ForDight(chdmarray[i].bzdh, 2) + "";
                str += "<br/> 分类:" + chdmarray[i].zhml + " 检测结果:<a href='#' onclick='chdmLabInfo(\"" + chdmarray[i].chdm + "\")'>" + chdmarray[i].zpdjg + "</a> ";
                str += "</p></li>";
                $("#chxx").append(str);
                var tpsrc = chdmarray[i].tpsrc;
            }
        }

        //材料检验报告
        function chdmLabInfo(chdm) {
            event.stopPropagation()
            var labInfo = getChdmLabInfo(chdm);
            createLabInfoHtml(labInfo.labinfoarray);
            showDetailInfo();
            
        }
        //获取材料检验报告
        function getChdmLabInfo(chdm) {    
            var obj = null;
            $.ajax({
                type: "POST",
                timeout: 1000,
                async: false,
                contentType: "application/x-www-form-urlencoded; charset=utf-8",
                url: "bqscan.aspx",
                data: { ctrl: "getChdmLabInfo", info: chdm },
                success: function (msg) {
                    obj = eval("(" + msg + ")");
                },
                error: function (XMLHttpRequest, textStatus, errorThrown) {
                    obj = { result: 'netError' };
                }
            });
            return obj;
        }

        //构造材料检验报告HTML
        function createLabInfoHtml(infoarray) {
            $("#fhBtn").attr("onclick", "showChdmList()");
            $("#detailinfo").empty("");
            if (typeof (infoarray) != "undefined") {
                for (var i = 0; i < infoarray.length; i++) {                    
                    var str = "<a href='#' class='list-group-item'>";
                    str += "<p class='list-group-item-text'>";
                    str += "<sapn style='display:inline-block; width:30%; text-align:left;'>" + infoarray[i].mc + "</sapn>";
                    str += "<sapn style='display:inline-block; width:30%; text-align:left;'>" + infoarray[i].jcjg + "</sapn>";
                    str += "<sapn style='display:inline-block; width:40%; text-align:right;'>" + infoarray[i].pdjg + "</sapn>";
                    str += "</p></a>";
                    $("#detailinfo").append(str);
                }
            }
        }

        //单击材料列表事件
        function chdmBJInfo(obj) {
            event.stopPropagation();
            var bjInfo = getChdmBJInfo(obj);      
            createBJInfoHtml(bjInfo.bjinfoarray);
            showDetailInfo();
            
        }

        //构造报价HTML
        function createBJInfoHtml(infoarray) {
            $("#fhBtn").attr("onclick", "showChdmList()");
            $("#detailinfo").empty("");
            if (typeof (infoarray) != "undefined") {
                for (var i = 0; i < infoarray.length; i++) {                    
                    $("#detailinfo").append("<a href='#' class='list-group-item'><p class='list-group-item-text'><sapn style='display:inline-block; width:30%; text-align:left;'>" + infoarray[i].mc + "</sapn><sapn style='display:inline-block; width:70%; text-align:right;'>" + infoarray[i].sz + "</sapn></p></a>");
                }
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
            //$("#mylog").append("<div class=\"row\"><div class=\"col-md-1\"><a href=\"#\" onclick=\"bqLogSearch(this)\" >" + bq + "</a></div></div>");
            $("#mylog").append("<a href='#' class='list-group-item' onclick='bqLogSearch(this)' style='color:#4f9fcf;'>" + bq + "</a>");
        }

        //查询历史扫描记录
        function bqLogSearch(obj) {
            var checkInfo = getBQInfo(obj.innerHTML);
            createChdmListHtml(checkInfo);//构造材料列表
            showChdmList();//显示材料列表
        }

        //显示扫描页
        function showScan() {
            $("#pagescan").attr("class", "page");
            $("#pagechdm").attr("class", "page page-not-header page-right");
            $("#pagedetailinfo").attr("class", "page page-not-header page-right");
        }

        //显示材料列表
        function showChdmList() {
            $("#fhBtn").attr("onclick", "showScan()");
            $("#pagescan").attr("class", "page page-right");
            $("#pagechdm").attr("class", "page page-not-header ");
            $("#pagedetailinfo").attr("class", "page page-not-header page-right");
        }

        //显示材料报价信息
        function showDetailInfo() {
            $("#pagescan").attr("class", "page page-right");
            $("#pagechdm").attr("class", "page page-not-header page-right");
            $("#pagedetailinfo").attr("class", "page page-not-header");
        }

        //获取材料报价信息
        function getChdmBJInfo(obj) {
            var chdm = obj;
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
    <style type="text/css">
        .header
        {
            background-color: #272b2e;
            border-bottom: 1px solid #161A1C;
            text-align: center;
            padding: 0 10px;
        }

        .logo
        {
            height: 20px;
            margin: 0 auto;
            margin-top: 15px;
            color: #fff;
            z-index: 110;
        }

        .backbtn
        {
            position: absolute;
            top: 0;
            bottom: 0;
            line-height: 50px;
            font-size: 1.4em;
            color: #b1afaf;
            left: 0;
            padding: 0 20px;
            border-right: 1px solid #161A1C;
        }

        .logo img
        {
            height: 100%;
            width: auto;
        }
    </style>
</head>
<body>
    <form id="form1" runat="server">
        <header class="header" id="header">
        <div class="logo">
            <div class="backbtn"><i id="fhBtn" class="fa fa-chevron-left" onclick="showScan()"></i></div>
            <img src="../../res/img/StoreSaler/lllogo6.png" alt="" />
        </div>
        </header>
        <div class="wrap-page">
            <div id="pagescan" class="page">
                <div class="input-group input-group-lg" style="margin-bottom: 5px;">
                    <span class="input-group-addon">样号/标签:</span>
                    <input type="text" class="form-control" id="serinfo">
                </div>
                <input type="button" style="margin-top: 20px" class="btn btn-default btn-lg btn-block" onclick="goscan()" value="查询" />

                <input type="button" id="ctrlScan" style="margin-top: 20px" class="btn btn-default btn-lg btn-block" onclick="scan()" value="扫描" />

                <div style="margin-top: 20px">
                    <%--                    <div class="row">
                        <div class="col-md-1">扫描记录</div>
                    </div>--%>
                    <div class="list-group" id="mylog">
                        <a href="#" class="list-group-item disabled">扫描记录</a>
                    </div>
                </div>
            </div>
            <div id="pagechdm" class="page page-not-header page-right ">
                <div class="input-group" style="margin-bottom: 5px;">
                    <span class="input-group-addon">&#12288;品名&#12288;</span>
                    <input type="text" class="form-control" id="ypmc">
                </div>
                <div class="input-group" style="margin-bottom: 5px;">
                    <span class="input-group-addon">&#12288;颜色&#12288;</span>
                    <input type="text" class="form-control" id="ys">
                </div>
                <div class="input-group" style="margin-bottom: 5px;">
                    <span class="input-group-addon">&#12288;样号&#12288;</span>
                    <input type="text" class="form-control" id="yphh">
                </div>
                <div class="input-group" style="margin-bottom: 5px;">
                    <span class="input-group-addon">面料成份</span>
                    <input type="text" class="form-control" id="mlcf">
                </div>
                <div class="input-group" style="margin-bottom: 5px;">
                    <span class="input-group-addon">&#12288;零售价</span>
                    <input type="text" class="form-control" id="lsdj">
                </div>
                <div class="input-group" style="margin-bottom: 5px;">
                    <span class="input-group-addon">&#12288;总成本</span>
                    <input type="text" class="form-control" id="yphhcb">
                </div>

                <div class="list-group" id="chxx">
                    <%--                    <table id="chxx" style="table-layout:fixed" class="table table-bordered">
                        <tr class="chxxhead">
                            <td style="width:110px;">材料编号</td>
                            <td>材料名称</td>
                            <td style="width:50px;">单价</td>
                            <td style="width:50px;white-space: normal;">单耗</td>
                        </tr>
                    </table>--%>
                </div>

            </div>
            <div id="pagedetailinfo" class="page page-not-header page-right">      
                <div id="detailinfo" class="list-group">                   
                </div>                
            </div>        
        </div>
        <input type="hidden" runat="server" id="appIdVal" />
        <input type="hidden" runat="server" id="timestampVal" />
        <input type="hidden" runat="server" id="nonceStrVal" />
        <input type="hidden" runat="server" id="signatureVal" />
        <input type="hidden" runat="server" id="useridVal" />
        <input type="hidden" runat="server" id="isPass" />
                    
    </form>
</body>
</html>