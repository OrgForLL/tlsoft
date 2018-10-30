useridVal<%@ Page Language="C#" %>

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
        string url = Request.Url.ToString().ToLower();//转为小写,indexOf 和Replace 对大小写都是敏感的     
   
        string ctrl = Convert.ToString(Request.Params["ctrl"]);
        if (ctrl == "" || ctrl == null)
        {
            if (clsWXHelper.CheckQYUserAuth(true))
            {
                //鉴权成功之后，获取 系统身份SystemKey
                //用户要开微信协同权限
                string SystemID = "1";
                SystemKey = clsWXHelper.GetAuthorizedKey(Convert.ToInt32(SystemID));

            }
            WxHelper cs = new WxHelper();
            string OAappID = "wxe46359cef7410a06";
            string OAappSecret = "w0IiKV3RGY6lzcx1QjdzMdWfhVMJEFOmnl_6HpYzfCgyNpORbyj6wlBnvmv2bw7x";
            //string access_token=cs.GetQYWXAccessToken(OAappID, OAappSecret);
            string[] config = cs.GetWXQYJsApiConfig(OAappID, OAappSecret);
            appIdVal.Value = config[0];
            timestampVal.Value = config[1];
            nonceStrVal.Value = config[2];
            signatureVal.Value = config[3];

            useridVal.Value = SystemKey;
        }
        else if (ctrl == "save")
        {//保存
            try
            {

                string info = Convert.ToString(Request.Params["info"]);
                string chdm = "";
                int sqmxid = 0;
                for (int i = 0; i < info.Split('|').Length; i++)
                {
                    if (info.Split('|')[i].Split(':')[0] == "chdm")
                    {
                        chdm = info.Split('|')[i].Split(':')[1];
                    }
                    else if (info.Split('|')[i].Split(':')[0] == "sqmxid")
                    {
                        sqmxid = int.Parse(info.Split('|')[i].Split(':')[1]);
                    }
                }

                int userid = int.Parse(Request.Params["userid"]);
                //TLBaseData._MyData sqlHelp = new TLBaseData._MyData();

                //SqlConnection TlConnection = (SqlConnection)Class_BBlink.LILANZ.DatabaseConn.ConnectionByID("1");
                //DataSet dataset = (DataSet)sqlHelp.MyDataSet(TlConnection, "EXEC[materials]"+sqmxid+","+userid);

                DataSet dataset = null;
                using (LiLanzDALForXLM dal = new LiLanzDALForXLM(OAConnStr))
                {
                    dal.ExecuteQuery("EXEC[materials]" + sqmxid + "," + userid, out dataset);
                }

                Response.Clear();
                Response.Write("{result:'Successed',state:'" + dataset.Tables[0].Rows[0][0].ToString() + "'}");
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
        else if (ctrl == "getInfo")
        {//获取二维码对应的信息                
            try
            {
                DataTable dt = null;
                string errInfo = "";
                string info = Convert.ToString(Request.Params["info"]);
                int userid = int.Parse(Request.Params["userid"]);
                string chdm = "";
                int sqmxid = 0;
                for (int i = 0; i < info.Split('|').Length; i++)
                {
                    if (info.Split('|')[i].Split(':')[0] == "chdm")
                    {
                        chdm = info.Split('|')[i].Split(':')[1];
                    }
                    else if (info.Split('|')[i].Split(':')[0] == "sqmxid")
                    {
                        sqmxid = int.Parse(info.Split('|')[i].Split(':')[1]);
                    }
                }

                using (LiLanzDALForXLM dal = new LiLanzDALForXLM(OAConnStr))
                {
                    //使用研发管理->数据维护-辅料材质基础档案 项目经理-设计师
                    //根据维护的RTX(备注字段) 关联t_user得到可以领用人员
                    string str_sql = @"
                         DECLARE @sqmxid int ;DECLARE @userid int ;
                         SET @sqmxid=@sqmxid_in; SET @userid=@userid_in; 
                         select  case when isnull(a.htid,0)=0 then 'isnotcomp' when t.mc is null then 'forbid' else 'allow' end useridCondition, sq.mxid sqmxid,sq.sl as sqsl,sq.zdr,a.yphh as mlbh,a.chdm as llyphh,sp.mc spmc,sq.mxbz,xl.mc as xlmc ,case isnull(b.id,0) when 0 then 0 else 1 end isjs
                         from cl_v_dddjmx a  
                         inner join t_xtdm xl on a.zxid=xl.id and xl.ssid='401'   
                         inner join cl_v_dddjmx sq on sq.id=a.lydjid and sq.mxid=a.lymxid and sq.mxid=@sqmxid
                         left join yx_V_splb sp on sp.id=sq.wgbs                       
                         left join cl_v_kcdjmx b on b.djlx=333 and b.lymxid=a.mxid                         
                         left join (
                             SELECT b.mc ,c.bz rtxid,d.id FROM ghs_t_xtdm a
                             INNER join ghs_t_xtdm b on b.ssid=a.id
                             INNER JOIN ghs_t_xtdm c ON c.ssid=b.id OR c.id=b.id 
                             inner JOIN dbo.t_user d ON cast(d.id as varchar(max))=c.cs/*userid*/
                             WHERE  a.djlx1=9208 and c.ty<>1 AND  a.mc='项目经理-设计师' and isnull(c.cs,'')<>''  and d.id= @userid    
                             union
                             select cname,rtx,id from t_user where id=@userid                                               
                         )t on t.mc=sq.zdr
                         where a.djlx=8005
                         ";
                    List<SqlParameter> para = new List<SqlParameter>();
                    para.Add(new SqlParameter("@sqmxid_in", sqmxid));
                    para.Add(new SqlParameter("@userid_in", userid));
                    errInfo = dal.ExecuteQuerySecurity(str_sql, para, out dt);

                }
                Response.Clear();
                Response.Write("{result:'Successed',chdm:'" + dt.Rows[0]["llyphh"].ToString() + "',chmc:'" + dt.Rows[0]["mlbh"].ToString() + "',zdr:'" + dt.Rows[0]["zdr"].ToString() + "',sqsl:" + dt.Rows[0]["sqsl"].ToString() + ",isjs:" + dt.Rows[0]["isjs"].ToString() + ",useridCondition:'" + dt.Rows[0]["useridCondition"].ToString() + "'}");
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
    <title>研发面料领用</title>
    <meta name="viewport" content="height=device-height,width=device-width,initial-scale=1.0,minimum-scale=1.0,maximum-scale=1.0,user-scalable=no" />
    <meta name="format-detection" content="telephone=yes" />
    <meta http-equiv="Content-Type" content="text/html; charset=UTF-8" />
    <script type="text/javascript" src="../../res/js/jquery.js"></script>
    <script type="text/javascript" src="../../api/lilanzAppWVJBridge.js"></script>
    <script type="text/javascript" src="http://res.wx.qq.com/open/js/jweixin-1.0.0.js"></script>
    <link href="../../res/css/ErpScan/jquery-impromptu.css" rel="stylesheet" type="text/css" />
    <script src="../../res/js/ErpScan/jquery-impromptu.js" type="text/javascript"></script>
    <link href="../../res/css/sweet-alert.css" rel="stylesheet" type="text/css" />
    <script src="../../res/js/sweet-alert.min.js" type="text/javascript"></script>
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
                alert("用户无登陆,不可用");
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
                //alert("ready");
                scan();
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
                        goScan(res.resultStr); // 当needResult 为 1 时，扫码返回的结果 
                    }
                });
            }
        };

        function goScan(result) {
            var mes = 1;
            var checkInfo = getInfo(result);
            //alert(checkInfo.result);
            if (checkInfo.result == "Successed") {
                $.prompt("<div style='font-size:15px;'>材料编号:" + checkInfo.chdm + "</br>材料名称:" + checkInfo.chmc + "</br>申请人:" + checkInfo.zdr + (checkInfo.useridCondition == "forbid" ? "(非申请人不能领用)" : "") + (checkInfo.useridCondition == "isnotcomp" ? "</br>商控还没接收" : "") + "</br>调样米数:" + checkInfo.sqsl + "</br>领用状态:" + (checkInfo.isjs == 1 ? "已领用" : "未领用</br>请选择是否领用,如果不想操作请选择[取消]") + "</div>",
                {
                    title: "提示",
                    buttons: (checkInfo.isjs == 1 || checkInfo.useridCondition == "forbid" || checkInfo.useridCondition == "isnotcomp" ? { '取消': 'iscancel' } : { "领用": "sub", '取消': 'iscancel' }),
                    submit: function (e, v, m, f) {
                        // use e.preventDefault() to prevent closing when needed or return false. 
                        // e.preventDefault(); 
                        if (v == "iscancel") {
                            //scan();
                            //close中直接调用
                        } else {
                            ajaxSubmit(result); //一定是同步ajax
                        }
                    },
                    close: function (event, value, message, formVals) {
                        //关闭的时候就会调用这个函数,
                        scan();
                    }
                });
            } else if (checkInfo.result == "Error") {
                //alert("二维码信息查询错误");
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
            }

        };
        //ajax提交
        function ajaxSubmit(result) {
            $.ajax({
                type: "POST",
                timeout: 1000,
                async: false,
                contentType: "application/x-www-form-urlencoded; charset=utf-8",
                url: "Materials.aspx",
                data: { ctrl: "save", info: result, userid: document.getElementById("useridVal").value },
                success: function (msg) {
                    var msgObj = eval("(" + msg + ")");
                    if (msgObj.result == "Successed") {
                        if (msgObj.state == "ok") {
                            alert("领用成功");
                        } else {
                            alert(msgObj.state);
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

        //获取2维码对应信息
        function getInfo(result) {
            var obj = null;
            $.ajax({
                type: "POST",
                timeout: 1000,
                async: false,
                contentType: "application/x-www-form-urlencoded; charset=utf-8",
                url: "Materials.aspx",
                data: { ctrl: "getInfo", info: result, userid: document.getElementById("useridVal").value },
                success: function (msg) {
                    obj = eval("(" + msg + ")");
                },
                error: function (XMLHttpRequest, textStatus, errorThrown) {
                    obj = { result: 'netError' };
                }
            });
            return obj;
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
</head>
<body>
    <form id="form1" runat="server">
        <input type="hidden" runat="server" id="appIdVal" />
        <input type="hidden" runat="server" id="timestampVal" />
        <input type="hidden" runat="server" id="nonceStrVal" />
        <input type="hidden" runat="server" id="signatureVal" />
        <input type="hidden" runat="server" id="useridVal" />
       
    </form>
</body>
</html>
