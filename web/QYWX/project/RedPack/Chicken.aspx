<%@ Page Language="C#" Debug="true" %>
<%@ Import Namespace="System.IO" %>
<%@ Import Namespace="System.Xml" %>
<%@ Import Namespace="System.Net" %> 
<%@ Import Namespace="nrWebClass" %>
<%@ Import Namespace="System.Collections.Generic" %>
<%@ Import Namespace="System.Data.SqlClient" %>
<%@ Import Namespace="System.Data" %>
 
<%@ Import Namespace="System.Net.Security" %> 
<%@ Import Namespace="System.Security.Cryptography.X509Certificates" %>
 
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">

<script runat="server">

    #region 运营前需要确认以下变量 
      
    private const string SendRedPackUrl = "https://api.mch.weixin.qq.com/mmpaymkttransfers/sendredpack";                 //发红包的接口URL
    private const string CheckRedPackUrl = "https://api.mch.weixin.qq.com/mmpaymkttransfers/gethbinfo ";                 //检查红包状态的接口URL

    private string ChickenAppid = "wxc368c7744f66a3d7";        //公众号是APPID；企业号CorpID：如果发红包到企业号中的应用，则该ID为转换ID 
    private const string APISecret = "CDCB769E6AA14AD39293451DE7053AD6";        //企业号绑定商户的API密钥，可在公众号商户后台进行查询
    //private string certFile = "cert/apiclient_cert.p12";        //公众号绑定商户的API证书的路径 
    private string certFile = "oa_cert/flh.aspx";        //公众号绑定商户的API证书的路径 

    private const string mch_id = "1230883502";               //商户号（同时也作为CertPassword）
    private const string send_name = "利郎男装";           //红包发送者名称   String(32)
    //private const string total_amount = "100";                //红包金额 单位：分
    private const string wishing = "感谢您参与感恩节养鸡活动，为您奉上红包！";                      //红包祝福语 String(128)
    private const string act_name = "感恩节养鸡活动";                         //活动名称String(32)   。实测，字数超过十几个就会出错！ 
    private const string ConfigKeyValue = "3";  //微信系统索引号
     
    #endregion

    /*
     * 整个红包方法流程分为：创建打赏记录 和 执行发放接口 两个步骤。
     * 其中：创建打赏记录：目前需要传入ERP的账号和密码、打赏帖ID、打赏备注；
     *       执行发放接口：仅需要传入打赏ID即可，对于已经打赏过的记录不会再执行打赏动作。  
     * 运用场景：1 ERP通用报表执行打赏； 2 在企业平台内由于其它人执行打赏，这种打赏需要先调用微信支付存入金额后才能调用打赏（暂不开放）
     * 异常处理：如果打赏记录创建后，执行发放接口不成功，允许再重复执行发放接口（必须等待10秒钟后重试,以免因并发执行引起重复打赏）。
    */
    protected void Page_Load(object sender, EventArgs e)
    {         
        Request.ContentEncoding = Encoding.UTF8;
        Response.ContentEncoding = Encoding.UTF8;
        
        string ctrl = Request.Params["ctrl"];
                        
        switch (ctrl)
        { 
            case "Check":
                Check();
                break;
            case "SendMoneyForChicken":
                SendMoneyForChicken();
                break; 
            default:
                clsSharedHelper.WriteErrorInfo("未知参数" + ctrl);
                break;
        } 
    }
  

    /// <summary>
    /// 检查发放情况
    /// http://tm.lilanz.com/qywx/project/redpack/reward.aspx?ctrl=Check&rid=6
    /// </summary>
    /// <returns></returns>
    private bool Check()
    {
        string rid = Convert.ToString(Request.Params["rid"]);
        string strInfo = "";
        string RedPackSendInfo = "";
        string WxConnStr = ConfigurationManager.ConnectionStrings["Conn"].ConnectionString;
        using (LiLanzDALForXLM dal = new LiLanzDALForXLM(WxConnStr))
        {

            List<SqlParameter> lstParams = new List<SqlParameter>();
            lstParams.AddRange(new SqlParameter[]{
                    new SqlParameter("@id", rid)
            });

            object objMch_billno = null;
            String strSQL = @"SELECT TOP 1 mch_billno FROM wx_t_Reward A WHERE A.ID=@id";

            strInfo = dal.ExecuteQueryFastSecurity(strSQL, lstParams, out objMch_billno);
            if (strInfo != "")
            {
                WriteLog2(string.Format("读取打赏记录红包单号失败！错误：{0}", strInfo));
                RedPackSendInfo = "读取打赏记录红包单号失败！";
            }

            if (objMch_billno == null || objMch_billno == "")
            {
                WriteLog2(string.Format("打赏记录不存在！ID：{0}", rid));
                RedPackSendInfo = "还未推送打赏红包！"; 
            }

            if (RedPackSendInfo != "")
            {
                clsSharedHelper.WriteErrorInfo(RedPackSendInfo);
                return false;
            }
                        
            //开始检查红包 
            string SendRedPackPost = @"<xml>
                                            <sign>内容待生成</sign>
                                            <mch_billno><![CDATA[{0}]]></mch_billno>
                                            <mch_id><![CDATA[{1}]]></mch_id>
                                            <appid><![CDATA[{2}]]></appid>
                                            <bill_type><![CDATA[MCHT]]></bill_type> 
                                            <nonce_str><![CDATA[{3}]]></nonce_str>
                                       </xml>";

            string nonce_str = Guid.NewGuid().ToString().Replace("-", "");
            string mch_billno = Convert.ToString(objMch_billno);
            SendRedPackPost = string.Format(SendRedPackPost, mch_billno, mch_id, ChickenAppid  ,nonce_str);
            
            SendRedPackPost = clsNetExecute.GetSign(SendRedPackPost, APISecret);

            if (certFile.Contains(":") == false)
            {
                certFile = Server.MapPath(certFile);
            } 
            
            string xmlInfo = clsNetExecute.HttpRequestCert(CheckRedPackUrl, SendRedPackPost, certFile, mch_id);
            if (xmlInfo.IndexOf(clsNetExecute.Error) == 0)
            {
                WriteLog2(string.Concat("检查红包状态失败0！证书路径：", certFile, "  错误：", xmlInfo));
                RedPackSendInfo = "检查红包状态接口调用失败！可能是服务器证书位置不正确！";   //错误可能是因为证书安装不正确，也可能是因为网络原因
            }
            else
            {
                //clsLocalLoger.WriteInfo(xmlInfo);
                RedPackSendInfo = string.Concat("检查红包状态失败！错误：", xmlInfo);
                
                XmlDocument doc = new XmlDocument();
                try
                {
                    doc.LoadXml(xmlInfo);
                    XmlNode xn = doc.FirstChild;

                    XmlNodeList xnl = xn.SelectNodes("return_code");
                    if (xnl.Count > 0 && xnl[0].InnerText == "SUCCESS")
                    {
                        XmlNodeList xnl2 = xn.SelectNodes("result_code");
                        if (xnl2.Count > 0 && xnl2[0].InnerText == "SUCCESS")
                        {
                            XmlNode xnl3 = xn.SelectSingleNode("reason");
                            if (xnl3 == null)
                            {
                                RedPackSendInfo = "打赏成功！";
                            }
                            else
                            {
                                RedPackSendInfo = xnl3.InnerText;
                            }
                        }
                    }
                }
                catch (XmlException xmlErr)
                {
                    WriteLog2("检查红包状态失败！错误：" + xmlErr.Message);
                }
            }
            WriteSendInfo(dal, rid, RedPackSendInfo, "");
        }
         
        clsSharedHelper.WriteInfo(RedPackSendInfo);        
        return true;   
    }

    /// <summary>
    /// 读取打赏信息
    /// </summary>
    /// <param name="rid">打赏ID</param>
    /// <param name="lstRewardInfo">回传的打赏信息</param>
    /// <returns></returns>
    private bool LoadReward(string rid,ref List<string> lstRewardInfo)
    {
        List<SqlParameter> lstParams = new List<SqlParameter>();
        lstParams.AddRange(new SqlParameter[]{
                new SqlParameter("@id", rid)
        });

        string strInfo = "";
        string WxConnStr = ConfigurationManager.ConnectionStrings["Conn"].ConnectionString;
        using (LiLanzDALForXLM dal = new LiLanzDALForXLM(WxConnStr))
        {
            DataTable dt = null;
            String strSQL = @"SELECT TOP 1 ReceiveUserID,ReceiveUserName,RewardMoney,RewardInfo,RedPackStatus,B.sphh FROM wx_t_Reward A 
		                        INNER JOIN wx_t_Evaluation B ON A.SourceTypeID = 0 AND A.SourceID = B.ID WHERE A.ID=@id ";

            strInfo = dal.ExecuteQuerySecurity(strSQL, lstParams, out dt);
            if (strInfo != "")
            {
                WriteLog2(string.Format("读取打赏记录失败！错误：{0}", strInfo));
                return false;
            }

            if (dt.Rows.Count == 0)
            {
                WriteLog2(string.Format("打赏记录不存在！ID：{0}", rid));
                return false;
            }

            lstRewardInfo.Add(Convert.ToString(dt.Rows[0][0]));     //id
            lstRewardInfo.Add(Convert.ToString(dt.Rows[0][1]));     //被打赏人姓名
            lstRewardInfo.Add(Convert.ToString(dt.Rows[0][2]));     //金额
            lstRewardInfo.Add(Convert.ToString(dt.Rows[0][3]));     //说明备注
            lstRewardInfo.Add(Convert.ToString(dt.Rows[0][4]));     //发送状态 
                         
            strSQL = string.Concat("SELECT TOP 1 A.name FROM wx_t_customers A WHERE A.id = ", Convert.ToString(dt.Rows[0][0]), "");
            object objName = null;
            strInfo = dal.ExecuteQueryFast(strSQL, out objName);

            if (strInfo != "")
            {
                WriteLog2(string.Format("获取被打赏人企业平台name失败！错误：{0}", strInfo));      //不用return;           
            }

            if (objName == null) lstRewardInfo.Add("");         //5 —— 发送名
            else lstRewardInfo.Add(objName.ToString());

            lstRewardInfo.Add(Convert.ToString(dt.Rows[0][5]));     //6 —— sphh        
             
            dt.Clear(); dt.Dispose();
            GC.Collect();
    
        }

        return true;   
    }

    /// <summary>
    /// 写入红包状态和描述信息
    /// </summary>
    /// <param name="dal">数据操作对象</param>
    /// <param name="rid">打赏ID</param>
    /// <param name="RedPackSendInfo">描述信息。若该信息包含“打赏成功”的字样，会将发送状态置为1</param>
    /// <returns></returns>
    private bool WriteSendInfo(LiLanzDALForXLM dal, string rid, string RedPackSendInfo)
    {
        return WriteSendInfo(dal, rid, RedPackSendInfo,"");
    }
    /// <summary>
    /// 写入红包状态和描述信息。
    /// </summary>
    /// <param name="dal">数据操作对象</param>
    /// <param name="rid">打赏ID</param>
    /// <param name="RedPackSendInfo">描述信息。若该信息包含“打赏成功”的字样，会将发送状态置为1</param>
    /// <param name="mch_billno">红包单号，如果有传入该值。则更新到数据库</param>
    /// <returns></returns>
    private bool WriteSendInfo(LiLanzDALForXLM dal, string rid, string RedPackSendInfo, string mch_billno)
    {
        List<SqlParameter> lstParams = new List<SqlParameter>();
        lstParams.AddRange(new SqlParameter[]{
                new SqlParameter("@id", rid)
        });

        string Addmch_billno = "";
        if (mch_billno != "")
        {
            Addmch_billno = string.Concat(" ,mch_billno='", mch_billno, "' ");
        }

        string AddRedPackStatus = "";       //如果发送的状态中包含'打赏成功'的字样，则更新状态标识
        if (RedPackSendInfo.Contains("打赏成功"))
        {
            AddRedPackStatus = ",RedPackStatus=1 ";
        }
         
        string strSQL = string.Concat(@"UPDATE wx_t_Reward SET RedPackSendTime=GetDate(),RedPackSendInfo='", RedPackSendInfo, "'", Addmch_billno, AddRedPackStatus, " WHERE ID=@id");    //首先更新发送准备状态
        string strInfo = dal.ExecuteNonQuerySecurity(strSQL, lstParams);
        if (strInfo != "")
        {
            WriteLog2(string.Format("更新打赏状态失败！错误：{0}  |strSQL={1} |信息：{2}", strInfo , strSQL, RedPackSendInfo));
            return false;          
        } 

        return true;
    }  

    private void SendMoneyForChicken()
    {
        string openid = Convert.ToString(Request.Params["openid"]);
        string GRID = Convert.ToString(Request.Params["GRID"]);

        string SendResult = SendMoneyForChicken(openid, GRID);
        if (SendResult.IndexOf(clsSharedHelper.Successed) == 0) clsSharedHelper.WriteInfo(SendResult);
        else
        {
            clsLocalLoger.WriteError(string.Concat("【红包发放失败】错误：", SendResult));
            SendResult = "幸运女神保佑！";
            clsSharedHelper.WriteErrorInfo(SendResult);
        }
    }
     
    /// <summary>
    /// 感恩节_发放红包
    /// </summary> 
    /// <param name="openid">公众号的用户名 openid</param>
    /// <param name="GRID">游戏记录的ID。即： GameRecordsID</param>
    /// <returns></returns>
    private string SendMoneyForChicken(string openid, string GRID)
    {
        string WxConnStr = ConfigurationManager.ConnectionStrings["Conn"].ConnectionString;
        //string WxConnStr = clsConfig.GetConfigValue("OAConnStr");
        string RedPackSendInfo = "";
        DataTable dt = null;
        string rid = ""; 
        string strInfo = "";
        using (LiLanzDALForXLM dal = new LiLanzDALForXLM(WxConnStr))
        {
            //首先，先创建打赏记录 注意：SourceTypeID = 1
            string strSQL = @"DECLARE @ReceiveUserID INT,
                                      @ReceiveUserName NVARCHAR(50),
                                      @RedPackMoney DECIMAL(9,2)
                            SELECT @ReceiveUserID = 0,@ReceiveUserName = '',@RedPackMoney = 0

                            SELECT TOP 1 @RedPackMoney = RedPackMoney FROM wx_t_GameRecords WHERE ID = @GRID
                            SELECT TOP 1 @ReceiveUserID = ID,@ReceiveUserName = name FROM tk_gameusers WHERE wxopenid = @openid

                            IF (@ReceiveUserID = 0) SELECT 0 ID,0 RedPackMoney
                            -- 注释下行，以方便测试
                            ELSE IF EXISTS (SELECT TOP 1 ID FROM wx_t_Reward WHERE SourceTypeID = @SourceTypeID AND ReceiveUserID = @ReceiveUserID) SELECT -1 ID,0 RedPackMoney
                            ELSE
                            BEGIN
                                INSERT INTO wx_t_Reward (SourceTypeID,SourceID,SendUserID,SendUserName,SendUserFace,ReceiveUserID,ReceiveUserName,RewardMoney,RewardInfo)
		                            VALUES (@SourceTypeID,@SourceID,@SendUserID,@SendUserName,@SendUserFace,@ReceiveUserID,@ReceiveUserName,@RedPackMoney,@RewardInfo)

                                SELECT @@IDENTITY ID,@RedPackMoney RedPackMoney 
                            END";

            List<SqlParameter> lstParams = new List<SqlParameter>();
            lstParams.AddRange(new SqlParameter[]{
                new SqlParameter("@GRID", GRID)
              , new SqlParameter("@SourceTypeID", 2)
              , new SqlParameter("@SourceID", GRID)
              , new SqlParameter("@SendUserID", "0")
              , new SqlParameter("@SendUserName", "2016感恩节活动")
              , new SqlParameter("@SendUserFace", "")
              , new SqlParameter("@openid", openid)  
              , new SqlParameter("@RewardInfo", wishing) 
        });

            strInfo = dal.ExecuteQuerySecurity(strSQL, lstParams, out dt);
            if (strInfo != "")
            {
                strInfo = string.Format("创建感恩节红包失败！错误：{0}", strInfo);
                WriteLog2(strInfo);                
                return strInfo;
            }            
            rid = Convert.ToString(dt.Rows[0]["ID"]);            
            decimal sendMoney = Convert.ToDecimal(dt.Rows[0]["RedPackMoney"]);

            if (rid == "0") return string.Concat("用户(", openid, ")不存在！");
            else if (rid == "-1") return string.Concat("用户已经获得红包过了！");
            
            WriteSendInfo(dal, rid, "正在推送红包..");
            
            int total_amount = Convert.ToInt32(Convert.ToDecimal(sendMoney) * 100); 
            
            //开始发放红包 
            string SendRedPackPost = @"<xml>
                                                    <sign>内容待生成</sign>
                                                    <mch_billno><![CDATA[{0}]]></mch_billno>
                                                    <mch_id><![CDATA[{1}]]></mch_id>
                                                    <wxappid><![CDATA[{2}]]></wxappid>
                                                    <send_name><![CDATA[{3}]]></send_name>
                                                    <re_openid><![CDATA[{4}]]></re_openid>
                                                    <total_amount><![CDATA[{5}]]></total_amount>
                                                    <total_num>1</total_num>
                                                    <wishing><![CDATA[{6}]]></wishing>
                                                    <client_ip><![CDATA[{7}]]></client_ip>
                                                    <act_name><![CDATA[{8}]]></act_name>
                                                    <remark><![CDATA[{9}]]></remark>
                                                    <nonce_str><![CDATA[{10}]]></nonce_str>
                                                </xml>";

            string nonce_str = Guid.NewGuid().ToString().Replace("-", "");
            string mch_billno = string.Concat(mch_id, DateTime.Now.ToString("yyyyMMdd")
                , DateTime.Now.ToString("HHmmss"), DateTime.Now.Millisecond.ToString().PadLeft(4, '0'));   //商户订单号（每个订单号必须唯一）组成：mch_id+yyyymmdd+10位一天内不能重复的数字。接口根据商户订单号支持重入，如出现超时可再调用。

            SendRedPackPost = string.Format(SendRedPackPost, mch_billno, mch_id, this.ChickenAppid, send_name, openid, total_amount
                                            , wishing, clsSharedHelper.GetSourceIP(), act_name, wishing, nonce_str);

            SendRedPackPost = clsNetExecute.GetSign(SendRedPackPost, APISecret);

            if (certFile.Contains(":") == false)
            {
                certFile = Server.MapPath(certFile);
            }

            WriteSendInfo(dal, rid, "开始创建并推送红包..", mch_billno);

            string xmlInfo = clsNetExecute.HttpRequestCert(SendRedPackUrl, SendRedPackPost, certFile, mch_id);
            if (xmlInfo.IndexOf(clsNetExecute.Error) == 0)
            {
                WriteLog2(string.Concat("发送红包失败0！证书路径：", certFile, "  错误：", xmlInfo));
                RedPackSendInfo = string.Concat("红包接口调用失败！错误：",xmlInfo);   //错误可能是因为证书安装不正确，也可能是因为网络原因
            }
            else
            {
                RedPackSendInfo = string.Concat("红包发放失败！错误：", xmlInfo);

                XmlDocument doc = new XmlDocument();
                try
                {
                    doc.LoadXml(xmlInfo);
                    XmlNode xn = doc.FirstChild;

                    XmlNodeList xnl = xn.SelectNodes("return_code");
                    if (xnl.Count > 0 && xnl[0].InnerText == "SUCCESS")
                    {
                        XmlNodeList xnl2 = xn.SelectNodes("result_code");
                        if (xnl2.Count > 0 && xnl2[0].InnerText == "SUCCESS")
                        {
                            RedPackSendInfo = "打赏成功！";
                        }
                    }
                }
                catch (XmlException xmlErr)
                {
                    WriteLog2("红包发放失败！错误：" + xmlErr.Message);
                }
            }

            WriteSendInfo(dal, rid, RedPackSendInfo, "");

            if (RedPackSendInfo.Contains("打赏成功"))
            { 
                return string.Concat(clsSharedHelper.Successed,sendMoney);
            }
            else
            {
                return RedPackSendInfo;
            }
        }
    }
    
    #region 日志
     
    private void WriteLog2(string info)
    { 
        if (info.Contains(clsNetExecute.Error) || info.Contains("错误"))
        {
            clsLocalLoger.WriteError(string.Concat("[红包打赏]", info));
        }
        else
        {
            clsLocalLoger.WriteInfo(string.Concat("[红包打赏]", info));   
        } 
    }
    
    #endregion
     
</script>

<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <title></title>
</head>
<body>
    <form id="form1" runat="server">
    <div>    
    </div>
    </form>
</body>
</html>
