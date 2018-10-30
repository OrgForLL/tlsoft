<%@ Page Language="C#" %>

<%@ Import Namespace="nrWebClass" %>
<%@ Import Namespace="System.Data" %>
<%@ Import Namespace="System.Data.SqlClient" %>
<%@ Import Namespace="System.Collections.Generic" %>
<%@ Import Namespace="System.IO" %>
<%@ Import Namespace="WebBLL.Core" %>
<%@ Import Namespace="System.Text.RegularExpressions" %>
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
            //SystemKey = "12742";
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
            //DataTable dt = null;
            //string errInfo = "";
            /*using (LiLanzDALForXLM dal = new LiLanzDALForXLM(OAConnStr))
            {
                string str_sql = @" select * from yf_V_wx_mobile where id=@user_in";
                List<SqlParameter> para = new List<SqlParameter>();
                para.Add(new SqlParameter("@user_in", useridVal.Value));
                errInfo = dal.ExecuteQuerySecurity(str_sql, para, out dt);
            }
            if (dt.Rows.Count == 0)
            {
                isPass.Value = "0";
            }
            else
            {*/
                isPass.Value = "1";
            //}

        }
        else if (ctrl == "getInfo")
        {
            //获取二维码对应的信息                
            try
            {
                DataTable dt = null;
                string errInfo = "";
                string bq = Convert.ToString(Request.Params["info"]);
                //Response.Write(bq);
                using (LiLanzDALForXLM dal = new LiLanzDALForXLM(OAConnStr))
                {
                    string str_sql = @"
                         DECLARE @bq varchar(max) ;   
                         SET @bq=@bq_in;    

                         select distinct  sp.yphh,sp.sphh,b.dj  as cbdj 
                         from  yx_t_ypdmb sp 
                         left join (select max(b.dj) as dj,b.yphh from yx_t_kcdjb a inner join yx_t_kcdjmx b on a.id=b.id where b.yphh=@bq and a.djlx in (111,112,121,122,141,142,161,162,118,119,125,126,157,158) and a.shbs=1 and a.djbs=1 group by b.yphh) b on sp.yphh=b.yphh
                         where (sp.sphh=@bq or sp.yphh=@bq) 
                   
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
                        jsonChinfo += "{yphh:\"" + dr["yphh"].ToString() + "\",sphh:\"" + dr["sphh"].ToString() + "\",cbdj:\"" + dr["cbdj"].ToString() + "\" },";
                    }
                    //,ypmc:\"" + dr["ypmc"].ToString() + "\",yphh:\"" + dr["yphh"].ToString() + "\",mlcf:\"" + dr["mlcf"].ToString() + "\",lsdj:\"" + dr["lsdj"].ToString() + "
                    Response.Write("{result:'Successed',hhxxarray:[" + jsonChinfo.Substring(0, jsonChinfo.Length - 1) + "]}");
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
        else if (ctrl == "saveInfo")
        {
            string userid = Convert.ToString(Request.Params["userid"]);
            string info = Convert.ToString(Request.Params["info"]);
            string str_sql = "";
            /*str_sql += " declare @djh int,@id int,@mxid int,@shgwid int,@zdr varchar(20);";
            str_sql += " select @djh = convert(int,isnull(max(djh),100001)) + 1   from yx_t_kcdjb where tzid=1 and year(rq)=YEAR(GETDATE()) and month(rq)=month(GETDATE()) and djlx=157;";
            str_sql += " select @zdr = cname from t_user where id = '" + userid + "' ;" ;
            str_sql += " select @shgwid = isnull(shgwid,0) from xt_t_djshgw where tzid=1 and djlxid=157 and xh=1; ";
            str_sql += " insert into yx_t_kcdjb (tzid,dhbh,djlx,djlb,djbs,djh,rq,khid,shdwid,ckid,dfckid,je,cjje,skje,kpje,zdr,shr,qrr,jyr,zdrq,shrq,qrrq,shbs,qrbs,shgwid,pzzdr,pzzdbs,pzdqrq,pzkz,dycs,djzt,zzbs,zzrq,zzr,lydjid,bz,spdlid) values ";
            str_sql += " (1,'',157,'2399',1,@djh,getdate(),11228,0,6671,0,0,0,0,0,@zdr,@zdr,'','',getdate(),getdate(),'',1,0,@shgwid,'',0,'','',0,0,0,'','',0,'',1166);";
            str_sql += " select @id = SCOPE_IDENTITY();";
            for (int m = 0; m < info.Split(',').Length; m++)
            {
                string[] sArray = info.Split(',')[m].Split('|');
                str_sql += " insert into yx_t_kcdjmx (id,yphh,shdm,sl,js,zxid,bj,zks,dj,je,cjje,zzsl,cbje,hscbje,rkjs,rksl,jysl,lymxid,djzt,sphh) values ";
                str_sql += " (@id,'" + sArray[2] + "',''," + sArray[1] + ",0,0," + sArray[3] + ",0," + sArray[3] + ",0,0,0,0,0,0,0,0,0,0,'" + sArray[0] + "');";
                str_sql += " SET @mxid=SCOPE_IDENTITY();";
                str_sql += " update yx_t_kcdjmx set je = isnull(dj,0)*isnull(sl,0) where mxid=@mxid;";
                str_sql += " insert into yx_t_kcdjcmmx(id,mxid,cmdm,sl0) ";
                str_sql += " values(@id,@mxid,'cm24'," + sArray[1] + ");";
                str_sql += " if not exists (select * from yx_t_ypkccmmx where tzid=1 and ckid=6671 and yphh='" + sArray[2] + "' and shdm='' and cmdm='cm24') begin ";
                str_sql += " insert into yx_t_ypkccmmx(tzid,ckid,yphh,shdm,cmdm,sl0,dbdf0,dbzt0,qtdf0,qtzt0)";
				str_sql += " values(1,6671,'"+ sArray[2] +"','','cm24',0,0,0,0,0) end ;";
            }*/
            str_sql += " declare @djh int,@djh1 int,@id int,@id1 int,@mxid int,@shgwid int,@zdr varchar(20);";
            str_sql += " select @djh = convert(int,isnull(max(djh),100001)) + 1   from yx_t_kcdjb where tzid=1 and year(rq)=YEAR(GETDATE()) and month(rq)=month(GETDATE()) and djlx=118;";
            str_sql += " select @djh1 = convert(int,isnull(max(djh),100001)) + 1   from yx_t_kcdjb where tzid=1 and year(rq)=YEAR(GETDATE()) and month(rq)=month(GETDATE()) and djlx=119;";
            str_sql += " select @zdr = cname from t_user where id = '" + userid + "' ;";
            str_sql += " select @shgwid = isnull(shgwid,0) from xt_t_djshgw where tzid=1 and djlxid=157 and xh=1; ";
            str_sql += " insert into yx_t_kcdjb (tzid,dhbh,djlx,djlb,djbs,djh,rq,khid,shdwid,ckid,dfckid,je,cjje,skje,kpje,zdr,shr,qrr,jyr,zdrq,shrq,qrrq,shbs,qrbs,shgwid,pzzdr,pzzdbs,pzdqrq,pzkz,dycs,djzt,zzbs,zzrq,zzr,lydjid,bz,spdlid)";
            str_sql += " values ('1','','118','2407',1,@djh,getdate(),'11228',0,'12234','10660',0,0,0,0,@zdr,'','','',getdate(),'','',1,0,0,'',0,'','',0,0,0,'','',0,'','1166')";
            str_sql += " select @id = SCOPE_IDENTITY();";
            str_sql += " insert into yx_t_kcdjb (tzid,dhbh,djlx,djlb,djbs,djh,rq,khid,shdwid,ckid,dfckid,je,cjje,skje,kpje,zdr,shr,qrr,jyr,zdrq,shrq,qrrq,shbs,qrbs,shgwid,pzzdr,pzzdbs,pzdqrq,pzkz,dycs,djzt,zzbs,zzrq,zzr,lydjid,bz,spdlid)";
            str_sql += " values ('1','','119','2408',1,@djh1,getdate(),'',0,'10660','12234',0,0,0,0,@zdr,'','','',getdate(),'','',1,0,0,'',0,'','',1,0,0,'','',@id,'','1166')";
            str_sql += " SET @id1=SCOPE_IDENTITY();";
            for (int m = 0; m < info.Split(',').Length; m++)
            {
                string[] sArray = info.Split(',')[m].Split('|');
                if (sArray[3] == "") {
                    sArray[3] = "0";
                }
                str_sql += " insert into yx_t_kcdjmx  (id,yphh,shdm,sl,js,zxid,bj,zks,dj,je,cjje,zzsl,cbje,hscbje,rkjs,rksl,jysl,lymxid,djzt,sphh) values (@id,'" + sArray[2] + "','','" + sArray[1] + "',0,0,0,0,'" + sArray[3] + "',0,0,0,0,0,0,0,0,0,0,'" + sArray[0] + "');";
                str_sql += " set @mxid=SCOPE_IDENTITY()";
                str_sql += " insert into yx_t_kcdjcmmx(id,mxid,cmdm,sl0) ";
                str_sql += " values(@id,@mxid,'cm24'," + sArray[1] + ");";
                str_sql += " update yx_t_kcdjmx set je=sl*dj where mxid=@mxid; ";
                str_sql += " insert into yx_t_kcdjmx  (id,yphh,shdm,sl,js,zxid,bj,zks,dj,je,cjje,zzsl,cbje,hscbje,rkjs,rksl,jysl,lymxid,djzt,sphh) values (@id1,'" + sArray[2] + "','','" + sArray[1] + "',0,0,0,0,'" + sArray[3] + "',0,0,0,0,0,0,0,0,0,0,'" + sArray[0] + "');";
                str_sql += " set @mxid=SCOPE_IDENTITY()";
                str_sql += " insert into yx_t_kcdjcmmx(id,mxid,cmdm,sl0) ";
                str_sql += " values(@id1,@mxid,'cm24'," + sArray[1] + ");";
                str_sql += " update yx_t_kcdjmx set je=sl*dj where mxid=@mxid; ";
                
            }
            str_sql += " update yx_t_kcdjb set je=(select sum(je) from yx_t_kcdjmx where id=@id),mxjls=(select count(id) from yx_t_kcdjmx where id=@id) where id=@id;";
            str_sql += " update yx_t_kcdjb set je=(select sum(je) from yx_t_kcdjmx where id=@id1),mxjls=(select count(id) from yx_t_kcdjmx where id=@id1) where id=@id1;";
            //str_sql += " Exec yp_up_cgrkd_bc @id;";
            LiLanzDALForXLM dal = new LiLanzDALForXLM(OAConnStr);
            List<SqlParameter> para = new List<SqlParameter>();
            string errInfo = dal.ExecuteNonQuerySecurity(str_sql,para);
            Response.Clear();
            if (errInfo == "")
            {
                Response.Write("{result:'Successed',state:'ok'}");
            }
            else {
                Response.Write("{result:'Successed',state:'Fail'}" + errInfo);
            }
            Response.End();
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
    <script type="text/javascript" src="../../api/lilanzAppWVJBridge.min.js"></script>
    <script type="text/javascript" src="http://res.wx.qq.com/open/js/jweixin-1.0.0.js"></script>
    <link rel="Stylesheet" href="../../res/css/LeePageSlider.css" />
    <link rel="Stylesheet" href="../../res/css/ErpScan/bootstrap.css" />
    <link rel="Stylesheet" href="../../res/css/font-awesome.min.css" />
    <link href="../../res/css/sweet-alert.css" rel="stylesheet" type="text/css" />
    <script src="../../res/js/sweet-alert.min.js" type="text/javascript"></script>
    <style type="text/css">
        body {
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
                    //alert("无权限");
                    //document.getElementById("ctrlScan").style.display = "none";
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
            //alert(1);
            //var isInApp = false ;
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
            var checkInfo = getInfo(result);
            //alert(checkInfo);
            //alert(checkInfo.result);
            if (checkInfo.result == "Successed") {
                for (var i = 0; i < checkInfo.hhxxarray.length; i++) {
                    addLog(checkInfo.hhxxarray[i].yphh, checkInfo.hhxxarray[i].sphh, checkInfo.hhxxarray[i].cbdj);//增加扫描记录
                    setTimeout(scan(), 500);
                }
                //createChdmListHtml(checkInfo);//构造材料列表
                //showChdmList();//显示材料列表                     
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

        //获取条码对应信息
        function getInfo(result) {
            var obj = null;
            $.ajax({
                type: "POST",
                timeout: 1000,
                async: false,
                contentType: "application/x-www-form-urlencoded; charset=utf-8",
                url: "YYScan.aspx",
                data: { ctrl: "getInfo", info: result },
                success: function (msg) {
                    obj = eval("(" + msg + ")");
                },
                error: function (XMLHttpRequest, textStatus, errorThrown) {
                    obj = { result: 'netError' };
                }
            });
            return obj;
        }

        var pd = 0;
        var delinfo = '';
        //增加一个扫描历史
        function addLog(yphh, sphh, cbdj) {
            if (pd == 0) {
                $("#mylog").append("<div href='#' class='list-group-item'  style='color:#4f9fcf;height:40px;'><div style='width:110px;float:left;'>样号</div><div style='width:60px;float:left;'>数量</div></div>");
            }
            //$("#mylog").append("<div class=\"row\"><div class=\"col-md-1\"><a href=\"#\" onclick=\"bqLogSearch(this)\" >" + bq + "</a></div></div>");
            $("#mylog").append("<div id='info_" + pd + "' ><div  href='#' class='list-group-item'  style='color:#4f9fcf;height:40px;'><input style='width:110px;float:left;border-style:none' id='mytext_" + pd + "_yphh' value = " + yphh + " ><input style='width:60px;float:left;border-style:none' id='mytext_" + pd + "_sl' value='1' ><input style='width:40px;float:left;border-style:none' type='button' onclick='mydel(" + pd + ")'value='取消' ><input type='hidden' id='mytext_" + pd + "_cbdj' value='" + cbdj + "' ><input type='hidden' id='mytext_" + pd + "_sphh' value='" + sphh + "' ></div></div>");
            pd += 1;
            //alert(pd);
        }
        function mydel(cs) {
            //alert(cs);
            delinfo += ',' + cs;
            $("#info_" + cs).empty();
        }
        function mysave() {
            //alert(pd);
            var obj = null;
            if (pd == 0) {
                alert("无扫描数据，不能提交");
                return;
            }
            var result = '';
            for (var m = 0; m < pd; m++) {
                var delpd = 0
                for (var i = 1; i < delinfo.split(',').length; i++) {
                    if (m == delinfo.split(',')[i]) {
                        delpd = 1;
                    }
                }
                if (delpd == 1) {
                    continue;
                }
                result += ',' + document.getElementById("mytext_" + m + "_sphh").value + '|' + document.getElementById("mytext_" + m + "_sl").value + '|' + document.getElementById("mytext_" + m + "_yphh").value + '|' + document.getElementById("mytext_" + m + "_cbdj").value;
            }
            if (result == '') {
                alert("无扫描数据，不能提交");
                return;
            }
            result = result.substring(1, result.length);
            $.ajax({
                type: "POST",
                timeout: 1000,
                async: false,
                contentType: "application/x-www-form-urlencoded; charset=utf-8",
                url: "YYScan.aspx",
                data: { ctrl: "saveInfo", info: result, userid: document.getElementById("useridVal").value },
                success: function (msg) {
                    obj = eval("(" + msg + ")");
                },
                error: function (XMLHttpRequest, textStatus, errorThrown) {
                    obj = { result: 'netError' };
                }
            });
            if (obj.state == "ok") {
                alert("提交成功");
                pd = 0;
                delinfo = '';
                $("#mylog").empty();
            } else {
                alert("提交失败");
            }
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


    </script>
    <style type="text/css">
        .header {
            background-color: #272b2e;
            border-bottom: 1px solid #161A1C;
            text-align: center;
            padding: 0 10px;
        }

        .logo {
            height: 20px;
            margin: 0 auto;
            margin-top: 15px;
            color: #fff;
            z-index: 110;
        }

        .backbtn {
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

        .logo img {
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
                <input type="button" style="margin-top: 20px" class="btn btn-default btn-lg btn-block" onclick="mysave()" value="提交" />

                <input type="button" id="ctrlScan" style="margin-top: 20px" class="btn btn-default btn-lg btn-block" onclick="scan()" value="扫描" />

                <div style="margin-top: 20px">
                    <%--                    <div class="row">
                        <div class="col-md-1">扫描记录</div>
                    </div>--%>
                    <div class="list-group-item disabled">扫描记录</div>
                    <div class="list-group" id="mylog">
                        
                    </div>
                </div>
            </div>

        </div>
        <div id="pagedetailinfo" class="page page-not-header page-right">
            <div id="detailinfo" class="list-group">
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
