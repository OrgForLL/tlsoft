<%@ Page Language="C#" %>

<%@ Import Namespace="nrWebClass" %>
<%@ Import Namespace="System.Data" %>
<%@ Import Namespace="System.Data.SqlClient" %>
<%@ Import Namespace="System.Collections.Generic" %>
<%@ Import Namespace="System.IO" %>
<%@ Import Namespace="WebBLL.Core" %>
<!DOCTYPE html>
<script runat="server">   


    //发送信信息
    //mes=1确认,0不确认    
    public void SendWX(string chdm, string cpjj, int userid, int mes, string mes_m)
    {
        string OAConnStr = clsConfig.GetConfigValue("OAConnStr");
        //TLBaseData._MyData sqlHelp = new TLBaseData._MyData();
        string str_sql = @"
            DECLARE @chdm VARCHAR(max),@cpjjs VARCHAR(max), @username varchar(max) ;
            SET @cpjjs=@cpjjs_in;SET @chdm=@chdm_in;  
            select top 1  @username=cname from t_user where id=@userid_in;
            SELECT a.kfbh INTO #kfbh
            FROM (
	            SELECT kfbh= '20'+SUBSTRING(@cpjjs,1,2)+'1' WHERE CASE  WHEN SUBSTRING(@cpjjs,3,2)='cx' THEN 1 ELSE 0 END =1
                   
	            UNION 
	            SELECT kfbh='20'+SUBSTRING(@cpjjs,1,2)+'2' WHERE CASE  WHEN SUBSTRING(@cpjjs,3,2)='cx' THEN 1 ELSE 0 END =1
	                
	            UNION 
	            SELECT kfbh='20'+SUBSTRING(@cpjjs,1,2)+'3' WHERE CASE  WHEN SUBSTRING(@cpjjs,3,2)='q' THEN 1 ELSE 0 END =1
	                
	            UNION 
	            SELECT kfbh='20'+SUBSTRING(@cpjjs,1,2)+'4' WHERE CASE  WHEN SUBSTRING(@cpjjs,3,2)='d' THEN 1 ELSE 0 END =1
	               
            ) a 

            SELECT cpjj INTO #cpjj
            FROM (
	            SELECT  cpjj= SUBSTRING(@cpjjs,1,2)+'春秋' WHERE CASE  WHEN SUBSTRING(@cpjjs,3,2)='cx' THEN 1 ELSE 0 END =1
	            UNION 
	            SELECT  cpjj=SUBSTRING(@cpjjs,1,2)+'夏季' WHERE CASE  WHEN SUBSTRING(@cpjjs,3,2)='cx' THEN 1 ELSE 0 END =1
	            UNION 
	            SELECT  cpjj=SUBSTRING(@cpjjs,1,2)+'秋季' WHERE CASE  WHEN SUBSTRING(@cpjjs,3,2)='q' THEN 1 ELSE 0 END =1
	            UNION 
	            SELECT  cpjj=SUBSTRING(@cpjjs,1,2)+'冬季' WHERE CASE  WHEN SUBSTRING(@cpjjs,3,2)='d' THEN 1 ELSE 0 END =1
            ) a 

            SELECT t1.name as qcjl,t2.name as qc  
            FROM yf_T_ghsmlsyb a  INNER JOIN #kfbh b ON  a.kfbh=b.kfbh 
	        INNER JOIN yf_T_ghsmlsyb c ON c.djlx=9141 AND c.lydjid=a.id inner join t_user t1 on t1.cname=a.chr
            inner join t_user t2 on t2.cname=c.chr
            WHERE a.llyphh=@chdm AND a.djlx=9140
                      
            select t1.name as zyfzr,t2.name as cgblr from (          
                select a.zyfzr,a.cgblr from yf_v_chdmcpjj a inner join #cpjj b on a.cpjj=b.cpjj where a.chdm=@chdm 
                union all 
                select '叶谋锦' zyfzr,'叶谋锦' cgblr  
                union all 
                select '张茂洪' zyfzr,'庄惠勇' cgblr  
                union all 
                select '李丽云' zyfzr,'施美芽' cgblr 
            ) a  inner join t_user t1 on t1.cname=a.zyfzr inner join t_user t2 on t2.cname=a.cgblr
 
            select a.chdm,a.chmc,kh.khmc,@username username from cl_T_chdmb a inner join yx_T_khb kh on kh.khid=a.ghsid             
            where a.chdm=@chdm
            drop table #cpjj;drop table #kfbh;
        ";
        List<SqlParameter> para = new List<SqlParameter>();
        para.Add(new SqlParameter("@chdm_in", chdm));
        para.Add(new SqlParameter("@cpjjs_in", cpjj));
        para.Add(new SqlParameter("@userid_in", userid));

        //SqlConnection TlConnection = (SqlConnection)Class_BBlink.LILANZ.DatabaseConn.ConnectionByID("1");      
        //DataSet dataset = (DataSet)sqlHelp.MyDataSet(TlConnection, str_sql.Replace("@chdm_in", "'" + chdm + "'").Replace("@cpjjs_in", "'" + cpjj + "'").Replace("@userid_in", "'" + userid.ToString() + "'"));
        DataSet dataset = null;
        using (LiLanzDALForXLM dal = new LiLanzDALForXLM(OAConnStr))
        {
            dal.ExecuteQuery(str_sql.Replace("@chdm_in", "'" + chdm + "'").Replace("@cpjjs_in", "'" + cpjj + "'").Replace("@userid_in", "'" + userid.ToString() + "'"), out dataset);
        }


        List<string> list = new List<string>();
        //需要发送的人
        foreach (DataRow dr in dataset.Tables[0].Rows)
        {
            if (!list.Contains(dr["qcjl"].ToString()))
            {
                list.Add(dr["qcjl"].ToString());
            }
            if (!list.Contains(dr["qc"].ToString()))
            {
                list.Add(dr["qc"].ToString());
            }
        }
        foreach (DataRow dr in dataset.Tables[1].Rows)
        {
            if (!list.Contains(dr["zyfzr"].ToString()))
            {
                list.Add(dr["zyfzr"].ToString());
            }
            if (!list.Contains(dr["cgblr"].ToString()))
            {
                list.Add(dr["cgblr"].ToString());
            }
        }
        // end 需要发送的人 

        //发送内容
        string content = "材料编号:" + chdm + "\r\n";
        content += "材料名称:" + dataset.Tables[2].Rows[0]["chmc"].ToString() + "\r\n";
        content += "供应商名称:" + dataset.Tables[2].Rows[0]["khmc"].ToString() + "\r\n";
        content += "确认状态:" + (mes == 1 ? "确认" : "不确认") + "\r\n";
        content += "确认人:" + dataset.Tables[2].Rows[0]["username"].ToString() + "\r\n";
        content += "确认情况:" + mes_m;
        //end 发送内容

        try
        {
            //nrWebClass.MsgClient msgclient;
            foreach (string user in list)
            {

                //msgclient = new nrWebClass.MsgClient("192.168.35.63", 21000);
                //System.Collections.Generic.Dictionary<string, string> items = new System.Collections.Generic.Dictionary<string, string>();
                //items.Add("toparty", "");
                //items.Add("totag", "");
                //items.Add("msgtype", "text");
                //items.Add("agentid", "4");
                //items.Add("safe", "0");
                //items.Add("content", content);
                //items.Add("touser", user);
                //msgclient.EntMsgSend(items);
                clsWXHelper.SendQYMessage(user, 4, content);

            }
        }
        catch (SystemException ex)
        {
            Response.Clear();
            Response.Write("{result:'Error',state:'" + ex.Message + "'}");
            Response.End();
        }


    }

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
            //string access_token=cs.GetQYWXAccessToken(OAappID, OAappSecret);
            //string[] config = cs.GetWXQYJsApiConfig(OAappID, OAappSecret);
            List<string> config = clsWXHelper.GetJsApiConfig("1");
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
                DataTable dt = null;
                string errInfo = "";
                string info = Convert.ToString(Request.Params["info"]);
                string chdm = info.Split('$')[0].ToString();
                string cpjj = info.Split('$')[1].ToString();
                int userid = int.Parse(Request.Params["userid"]);
                int mes = int.Parse(Request.Params["mes"]);
                string mes_m = Request.Params["mes_m"].ToString();

                using (LiLanzDALForXLM dal = new LiLanzDALForXLM(OAConnStr))
                {
                    string str_sql = @"
                         DECLARE @chdm VARCHAR(max),@cpjjs VARCHAR(max),@r VARCHAR(max),@maxxglx INT, @mes int, @mes_m varchar(500), @username varchar(max) ;
                         SET @cpjjs=@cpjjs_in;SET @chdm=@chdm_in; set @mes=@mes_in;set @mes_m=@mes_m_in;
                         select top 1  @username=cname from t_user where id=@userid_in;
                         SELECT a.kfbh INTO #kfbh
                         FROM (
	                         SELECT kfbh= '20'+SUBSTRING(@cpjjs,1,2)+'1' WHERE CASE  WHEN SUBSTRING(@cpjjs,3,2)='cx' THEN 1 ELSE 0 END =1
	                         UNION 
	                         SELECT kfbh='20'+SUBSTRING(@cpjjs,1,2)+'2' WHERE CASE  WHEN SUBSTRING(@cpjjs,3,2)='cx' THEN 1 ELSE 0 END =1
	                         UNION 
	                         SELECT kfbh='20'+SUBSTRING(@cpjjs,1,2)+'3' WHERE CASE  WHEN SUBSTRING(@cpjjs,3,2)='q' THEN 1 ELSE 0 END =1
	                         UNION 
	                         SELECT kfbh='20'+SUBSTRING(@cpjjs,1,2)+'4' WHERE CASE  WHEN SUBSTRING(@cpjjs,3,2)='d' THEN 1 ELSE 0 END =1
                         ) a 
                         IF EXISTS(SELECT * FROM yf_T_ghsmlsyb a  INNER JOIN #kfbh b ON  a.kfbh=b.kfbh    WHERE a.llyphh=@chdm AND a.djlx=9140)
                         BEGIN
	                        SELECT @maxxglx=MAX(c.xglx) FROM yf_T_ghsmlsyb a  INNER JOIN #kfbh b ON  a.kfbh=b.kfbh 
	                        INNER JOIN yf_T_ghsmlsyb c ON c.djlx=9142 AND c.lydjid=a.id   WHERE a.llyphh=@chdm AND a.djlx=9140
	                        IF @maxxglx=3
	                        BEGIN
		                        SET @r='maxRecord'
	                        END
	                        ELSE  
	                        BEGIN
                                declare @flow_docID int ;
                                select @flow_docID=b.docid
                                FROM yf_T_mldsb a
                                inner JOIN dbo.fl_t_flowRelation b ON a.id=b.dxid AND b.flowid=a.flowid
                                INNER JOIN fl_t_nodeconfig c ON c.nodeid=b.currentNode AND c.flowid=b.flowid
                                WHERE a.djlx='3230' AND a.chdm=@chdm and c.cs='zs' and a.shbs<>1
                                if @flow_docID is not  null 
                                begin    
		                            IF @maxxglx IS NULL SET @maxxglx=0;
		                            INSERT yf_T_ghsmlsyb (tzid,djlx,lydjid,xglx,qrrq,shyjbz,chyj,qryj,chr,zdrq,bz)
		                            SELECT a.tzid,9142,a.id,@maxxglx+1,GETDATE(),'',case @mes when 1 then '确认' else '不确认' end,@mes_m ,@username,GETDATE(),'微信号扫描'
		                            FROM yf_T_ghsmlsyb a  INNER JOIN #kfbh b ON  a.kfbh=b.kfbh    WHERE a.llyphh=@chdm AND a.djlx=9140 
                                
                                    update a set a.shbs=1,a.shr=@username,shrq=getdate()
                                    FROM yf_T_mldsb a
                                    inner JOIN dbo.fl_t_flowRelation b ON a.id=b.dxid AND b.flowid=a.flowid and b.docid=@flow_docID                            
                                    WHERE a.djlx='3230' 

                                    INSERT  INTO fl_t_flowspjl( flowid ,docid ,nodeid ,dxid , dxtzid , shr ,shyj ,shrq)
                                    SELECT a.flowid,a.docID,a.currentNode,a.dxid,a.dxtzid,@username,'刷码通过'shyj,getdate() shrq FROM fl_t_flowRelation a WHERE a.docID=@flow_docID

                                    SET XACT_ABORT ON ;
                                    DECLARE @result int ; EXEC @result=flow_up_end @flow_docID,@userid_in,@username,1,1,'Z','刷码通过',''; 
                                    SET XACT_ABORT OFF 

		                            SET @r='ok'
                                end
                                else
                                begin
                                   set @r='noFlowdocid'
                                end
	                        END	
                         END
                         ELSE
                         BEGIN
	                        SET @r='noRecord'
                         end 
                         DROP TABLE #kfbh
                         SELECT @r
                        ";

                    List<SqlParameter> para = new List<SqlParameter>();
                    para.Add(new SqlParameter("@chdm_in", chdm));
                    para.Add(new SqlParameter("@cpjjs_in", cpjj));
                    para.Add(new SqlParameter("@userid_in", userid));
                    para.Add(new SqlParameter("@mes_in", mes));
                    para.Add(new SqlParameter("@mes_m_in", mes_m));
                    errInfo = dal.ExecuteQuerySecurity(str_sql, para, out dt);
                    //发送信息
                    SendWX(chdm, cpjj, userid, mes, mes_m);

                }
                Response.Clear();
                Response.Write("{result:'Successed',state:'" + dt.Rows[0][0].ToString() + "'}");
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
                string chdm = info.Split('$')[0].ToString();
                string cpjj = info.Split('$')[1].ToString();

                using (LiLanzDALForXLM dal = new LiLanzDALForXLM(OAConnStr))
                {
                    string str_sql = @"
                         DECLARE @chdm VARCHAR(max);DECLARE @cpjj VARCHAR(max) ;declare  @iszs int ;set @iszs=0;declare  @ddsl int;DECLARE @htqrrq VARCHAR(10);DECLARE @htjhrq VARCHAR(10);
                         SET @chdm=@chdm_in; SET @cpjj=@cpjj_in; 
                     
                         SELECT a.* into #cpjj
                         FROM   dbo.f_ht_cpjj(2009)a 
                         WHERE CASE WHEN CHARINDEX('cx',@cpjj)>0 AND mc in (SUBSTRING(@cpjj,1,2)+'春季',SUBSTRING(@cpjj,1,2)+'夏季')  THEN 1
                         WHEN  CHARINDEX('q',@cpjj)>0 AND mc =SUBSTRING(@cpjj,1,2)+'秋季' THEN 1 
                         WHEN  CHARINDEX('d',@cpjj)>0 AND mc =SUBSTRING(@cpjj,1,2)+'冬季' THEN 1	 ELSE 0 END =1
 

                         SELECT @iszs=1 FROM yf_T_mldsb a
                         inner JOIN dbo.fl_t_flowRelation b ON a.id=b.dxid AND b.flowid=a.flowid
                         INNER JOIN fl_t_nodeconfig c ON c.nodeid=b.currentNode AND c.flowid=b.flowid
                         WHERE a.djlx='3230' AND a.chdm=@chdm and c.cs='zs'

                         SELECT @ddsl= SUM(a.sl)  
                         FROM cl_v_dddjmx a
                         INNER JOIN #cpjj  cpjj ON cpjj.mc = a.zzr
                         where a.djlx=621 and a.chdm=@chdm  

                         SELECT @htqrrq=MIN(CONVERT(VARCHAR(10), htmx.qrlxrq, 120))  ,@htjhrq=MIN(CONVERT(VARCHAR(10), htmx.jhksrq, 120)) 
	                     FROM     zw_t_htdddjb ht  
		                 INNER JOIN zw_t_htylddmx htmx ON ht.id = htmx.id
		                 INNER JOIN #cpjj cpjj ON cpjj.mc = ht.cpjj
		                 where  htmx.clbh=@chdm  

                         select ch.chdm,ch.chmc,@ddsl ddsl,ch.dw,kh.khmc,@htqrrq htqrrq ,@htjhrq htjhrq,@iszs iszs from cl_T_chdmb ch 
                         inner join yx_T_khb kh on kh.khid=ch.ghsid                         
                         where ch.chdm=@chdm
                         ";
                    List<SqlParameter> para = new List<SqlParameter>();
                    para.Add(new SqlParameter("@chdm_in", chdm));
                    para.Add(new SqlParameter("@cpjj_in", cpjj));
                    errInfo = dal.ExecuteQuerySecurity(str_sql, para, out dt);

                }
                Response.Clear();
                Response.Write("{result:'Successed',chdm:'" + dt.Rows[0]["chdm"].ToString() + "',chmc:'" + dt.Rows[0]["chmc"].ToString() + "',ddsl:'" + dt.Rows[0]["ddsl"].ToString() + "',dw:'" + dt.Rows[0]["dw"].ToString() + "',htqrrq:'" + dt.Rows[0]["htqrrq"].ToString() + "',htjhrq:'" + dt.Rows[0]["htjhrq"].ToString() + "',khmc:'" + dt.Rows[0]["khmc"].ToString() + "',iszs:" + dt.Rows[0]["iszs"].ToString() + "}");
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
    <title>米样确认</title>
    <meta name="viewport" content="height=device-height,width=device-width,initial-scale=1.0,minimum-scale=1.0,maximum-scale=1.0,user-scalable=no" />
    <meta name="format-detection" content="telephone=yes" />
    <meta http-equiv="Content-Type" content="text/html; charset=UTF-8" />
    <link href="../../res/css/ErpScan/jquery-impromptu.css" rel="stylesheet" type="text/css" />
    <link href="../../res/css/sweet-alert.css" rel="stylesheet" type="text/css" />
    <script type="text/javascript" src="http://res.wx.qq.com/open/js/jweixin-1.0.0.js"></script>
    <script type="text/javascript" src="../../api/lilanzAppWVJBridge.js"></script>
    <script type="text/javascript" src="../../res/js/jquery.js"></script>
    <script src="../../res/js/ErpScan/jquery-impromptu.js" type="text/javascript"></script>
    <script src="../../res/js/sweet-alert.min.js" type="text/javascript"></script>
</head>
<body>
    <form id="form1" runat="server">
       
        <input type="hidden" runat="server" id="appIdVal" />
        <input type="hidden" runat="server" id="timestampVal" />
        <input type="hidden" runat="server" id="nonceStrVal" />
        <input type="hidden" runat="server" id="signatureVal" />
        <input type="hidden" runat="server" id="useridVal" />
    </form>
    <script type="text/javascript">
        var appIdVal, timestampVal, nonceStrVal, signatureVal;

        $(document).ready(function () {
            //WeiXin JSSDK  
            appIdVal = document.getElementById("appIdVal").value;
            timestampVal = document.getElementById("timestampVal").value;
            nonceStrVal = document.getElementById("nonceStrVal").value;
            signatureVal = document.getElementById("signatureVal").value;
            if (document.getElementById("useridVal").value == "" || document.getElementById("useridVal").value == "0") {
                alert("用户无登陆,不可用");
            } else {
                llApp.init();               
                setTimeout(function () {
                    if (isInApp) {
                        scan();
                    } else {
                        jsConfig();
                    }
                },500)                               
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
            var mes = 1; var mes_m;
            var checkInfo = getInfo(result);
            var TS;
            TS = (checkInfo.iszs == 1 ? "" : "未审批");

            if (checkInfo.result == "Successed") {

                $.prompt("<div style='font-size:15px;'>材料编号:" + checkInfo.chdm + "</br>材料名称:" + checkInfo.chmc + "</br>下单量:" + checkInfo.ddsl + " 单位:" + checkInfo.dw + "</br>合同米样确认时间:" + checkInfo.htqrrq + "</br>面料合同交期:" + checkInfo.htjhrq + "</br>供应商:" + checkInfo.khmc + "" +
                '<div> 确认 </br><label><input id="myxz_qr"  style="width:15px;height:15px" type="radio" name="myxz" checked="checked" value="qr">颜色,风格,手感</label></div>' +
                '<div>不确认</br><input id="myxz_bqr"  style="width:15px;height:15px" type="radio" name="myxz"  value="bqr">意见:<input type="text" name="bqrtxt" onfocus="bqrtxtFocus()"  /></div></div>',
                {
                    title: "提示" + TS,
                    buttons: { "提交": "sub", '取消': 'iscancel' },
                    submit: function (e, v, m, f) {
                        // use e.preventDefault() to prevent closing when needed or return false. 
                        // e.preventDefault(); 
                        if (v == "iscancel") {
                            //scan();
                            //close中直接调用
                        } else if (v == "") {

                        } else if (v == "sub") {
                            if (checkInfo.iszs == 1) {
                                if (f.myxz == undefined) {
                                    alert("请先选择");
                                    return false;
                                } else {
                                    mes = (f.myxz == "qr" ? 1 : 0);
                                    //mes_m = (f.myxz == "qr" ? "颜色,风格,手感" : ((f.myxz == "bqr_sg" ? "颜色,手感" : "内在检测不合格")));
                                    mes_m = (f.myxz == "qr" ? "颜色,风格,手感" : f.bqrtxt);
                                    ajaxSubmit(mes, mes_m, result);//一定是同步ajax
                                }
                            } else {
                                alert("未审核");
                                return false;
                            }
                        }
                    },
                    close: function (event, value, message, formVals) {
                        //关闭的时候就会调用这个函数,
                        scan();
                    }
                });
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
            }
        }

        //不确认文本框得到焦点时候
        //将不确认单选框直接选中
        function bqrtxtFocus() {
            $("#myxz_bqr").attr("checked", "checked");
        }

        //ajax提交
        function ajaxSubmit(mes, mes_m, result) {
            $.ajax({
                type: "POST",
                timeout: 1000,
                async: false,
                contentType: "application/x-www-form-urlencoded; charset=utf-8",
                url: "ScanMain.aspx",
                data: { ctrl: "save", info: result, userid: document.getElementById("useridVal").value, mes: mes, mes_m: mes_m },
                success: function (msg) {
                    var msgObj = eval("(" + msg + ")");
                    if (msgObj.result == "Successed") {
                        if (msgObj.state == "ok") {
                            alert((mes == 1 ? "确认" : "不确认") + "成功");
                        } else if (msgObj.state == "maxRecord") {
                            //已经处理过三次了
                            alert("米样操作已经有三次,不能再处理");

                        } else if (msgObj.state == "noRecord") {
                            //查无记录                                    
                            alert(result.split("$")[1] + ",没有此面料[" + result.split("$")[0] + "]的信息,请让QC检查[面料下单,接单,生产品质分析控制]");
                        } else if (msgObj.state == "noFlowdocid") {
                            alert(result.split("$")[1] + ",面料[" + result.split("$")[0] + "]生管中心生产的米样单据已全部办理[物料采购转验货申请单V2]");
                        }
                        //scan();
                        //close中直接调用
                    } else if (msgObj.result == "Error") {
                        alert(msgObj.state);
                        //scan();
                        //close中直接调用
                    } else {
                        alert(msg);
                        //scan();
                        //close中直接调用
                    }

                },
                error: function (XMLHttpRequest, textStatus, errorThrown) {
                    alert("您的网络好像有点问题，请重试！");
                    //scan();
                    //close中直接调用
                }
            });
        }

        //获取2维码对应信息
        function getInfo(result) {
            var obj = null;
            try {
                $.ajax({
                    type: "POST",
                    timeout: 1000,
                    async: false,
                    contentType: "application/x-www-form-urlencoded; charset=utf-8",
                    url: "ScanMain.aspx",
                    data: { ctrl: "getInfo", info: result },
                    success: function (msg) {
                        obj = eval("(" + msg + ")");
                    },
                    error: function (XMLHttpRequest, textStatus, errorThrown) {
                        obj = { result: 'netError' }; alert("getinfo-err");
                    }
                });

            } catch (e) {
                alert(e.message);
            }
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
</body>
</html>
