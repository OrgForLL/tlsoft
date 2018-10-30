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
     
    private const string UseridToOpenidUrl = "https://qyapi.weixin.qq.com/cgi-bin/user/convert_to_openid?access_token={0}";    //将userid转换成openid的接口URL
    private const string SendRedPackUrl = "https://api.mch.weixin.qq.com/mmpaymkttransfers/sendredpack";                 //发红包的接口URL
    private const string CheckRedPackUrl = "https://api.mch.weixin.qq.com/mmpaymkttransfers/gethbinfo ";                 //检查红包状态的接口URL

    private string CheckAppid = "wxe46359cef7410a06";        //企业号CorpID ；如果发红包到企业号中的应用，则该ID为转换ID
    private const int agentid = 26;            //发放红包的应用ID
    private const string APISecret = "6A656A06713E495D9F0CE840BDACB8F9";        //企业号绑定商户的API密钥，可在企业号商户后台进行查询
    //private string certFile = "cert/apiclient_cert.p12";        //企业号绑定商户的API证书的路径 
    private string certFile = "oa_cert/qyh.aspx";        //企业号绑定商户的API证书的路径 
    
    private const string mch_id = "1299908201";               //商户号（同时也作为CertPassword）
    private const string send_name = "利郎男装";           //红包发送者名称   String(32)
    //private const string total_amount = "100";                //红包金额 单位：分
    private const string wishing = "感谢您参加评论活动，为您奉上一个红包！";                      //红包祝福语 String(128)
    private const string act_name = "写点评奖红包活动";                         //活动名称String(32)   。实测，字数超过十几个就会出错！ 
    private const string ConfigKeyValue = "1";  //微信系统索引号
    
    private const decimal maxRewardMoney = 30.0M;                         //一次最多打赏金额限制
    
    private const int QARewardMin = 2;               //市调功能，在最后提交时直接发放红包。
    private const int QARewardMax = 10;
    private const string QARemark = "感谢您参加问卷调查活动，为您奉上一个红包！";
    private const string QAact_name = "填问卷奖红包活动！";
   
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
            case "Create":
                Create();
                break;
            case "Send":
                Send();
                break;
            case "Check":
                Check();
                break;
            case "SendMoneyForQA":
                SendMoneyForQA();
                break; 
        } 
    }

    /// <summary>
    /// 创建打赏记录，创建成功会返回 打赏记录ID。打赏的文字要用utf-8先编码一次再传入，否则会乱码
    /// http://tm.lilanz.com/qywx/project/redpack/reward.aspx?ctrl=Create&username=xlm&pwd=密码要对&eid=105&RewardMoney=1.01&RewardInfo=%e6%82%a8%e7%9a%84%e8%af%84%e8%ae%ba%e5%86%99%e5%be%97%e5%be%88%e5%a5%bd%ef%bc%81%e5%9c%a8%e6%ad%a4%e5%a5%89%e4%b8%8a%e4%b8%80%e4%b8%aa%e7%ba%a2%e5%8c%85%ef%bc%81%e8%af%b7%e7%ac%91%e7%ba%b3%7e
    /// http://tm.lilanz.com/qywx/project/redpack/reward.aspx?ctrl=Create&username=xlm&pwd=密码要对&eid=105&RewardMoney=1.01&RewardInfo=您的评论写得很好！在此奉上一个红包！请笑纳~
    /// </summary>
    /// <returns></returns>
    private bool Create()
    {
        //1 通过用户名和密码，获得登录人资料ID和姓名，并试图获取其在企业号中的头像
        string username = Convert.ToString(Request.Params["username"]);
        string pwd = Convert.ToString(Request.Params["pwd"]);
        List<string> lstUserInfo = new List<string>();
        if (ErpLogin(username, pwd, ref lstUserInfo) == false)        
        {
            clsSharedHelper.WriteErrorInfo("打赏人登录失败！账号或密码错误！");
            return false;
        }

        //2 使用ID读取被打赏评论的信息（主要是发帖人信息）
        string eid = Convert.ToString(Request.Params["eid"]);
        List<string> ReceiveUserInfo = new List<string>();
        if (LoadEvaluation(eid, ref ReceiveUserInfo) == false)
        {
            clsSharedHelper.WriteErrorInfo("读取评论失败");
            return false;
        }
                
        //3 创建打赏记录
        int rid = CreateReward(eid,ref lstUserInfo,ref ReceiveUserInfo);
        if (rid  == 0)
        {
            clsSharedHelper.WriteErrorInfo("创建打赏记录失败");
            return false;
        }

        clsSharedHelper.WriteSuccessedInfo(rid.ToString());
        return true;
    }

    /// <summary>
    /// 根据打赏记录执行发送红包的接口
    /// http://tm.lilanz.com/qywx/project/redpack/reward.aspx?ctrl=Send&rid=6
    /// </summary>
    /// <returns></returns>
    private bool Send()
    {
        //1 读取打赏记录情况。获得被打赏人信息（包括 企业平台name）、打赏记录金额、打赏备注 和 打赏状态。
        string rid = Convert.ToString(Request.Params["rid"]);
        List<string> lstRewardInfo = new List<string>();
        if (LoadReward(rid, ref lstRewardInfo) == false)
        {
            clsSharedHelper.WriteErrorInfo("读取打赏记录失败");
            return false;
        }
        
        //2 如果之前未打赏成功 并且 已获取到 被打赏人的 企业平台name 则调用红包发放逻辑
        if (lstRewardInfo[4] != "0")
        {
            clsSharedHelper.WriteErrorInfo("红包之前已经发送成功了，没有必要重复发！");
            return false;
        }
        else if (lstRewardInfo[5] == "")
        {
            clsSharedHelper.WriteErrorInfo("找不到被打赏人的企业平台账号，请确认Ta的账号是否已经变更或已经离职！");
            return false;
        }
        else if (Convert.ToDecimal(lstRewardInfo[2]) <= 0 || Convert.ToDecimal(lstRewardInfo[2]) > maxRewardMoney)
        {
            clsSharedHelper.WriteErrorInfo(string.Concat("每次打赏金额必须大于0，且不允许超过", maxRewardMoney));
            return false;
        }

        if (SendMoney(rid, ref lstRewardInfo))
        {
            clsSharedHelper.WriteSuccessedInfo("打赏成功！");
            return true;
        }
        else
        {
            clsSharedHelper.WriteErrorInfo("打赏失败！");
            return false;            
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
            SendRedPackPost = string.Format(SendRedPackPost, mch_billno, mch_id, CheckAppid  ,nonce_str);
            
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

        //更新主表统计的金额
        if (RedPackSendInfo.Contains("打赏成功"))
        {
            strSQL = string.Concat(@" DECLARE @SourceID INT
                                      DECLARE @SumMoney DECIMAL(18,2)
                                      DECLARE @SourceTypeID INT

                        SELECT @SourceID = SourceID,@SourceTypeID = SourceTypeID FROM wx_t_Reward WHERE id = @id
                        IF (@SourceTypeID = 0)
                        BEGIN 
                            SELECT @SumMoney = SUM(RewardMoney) FROM wx_t_Reward WHERE SourceID = @SourceID AND RedPackStatus = 1
                            UPDATE wx_t_Evaluation SET TotalReward = @SumMoney WHERE ID = @SourceID 
                        END ");
            lstParams.Clear();
            lstParams.Add(new SqlParameter("@id", rid));
            strInfo = dal.ExecuteNonQuerySecurity(strSQL, lstParams);
            if (strInfo != "")
            {
                WriteLog2(string.Format("更新合计打赏金额失败！错误：{0}  |strSQL={1} |信息：{2}", strInfo, strSQL, RedPackSendInfo));
                return false;
            }            
        }        

        return true;
    }
    
    /// <summary>
    /// 发放红包
    /// </summary>
    /// <param name="rid">打赏ID</param>
    /// <param name="lstRewardInfo">回传的打赏信息</param>
    /// <returns></returns>
    private bool SendMoney(string rid, ref List<string> lstRewardInfo)
    { 
        string WxConnStr = ConfigurationManager.ConnectionStrings["Conn"].ConnectionString;
        string RedPackSendInfo = "";
        using (LiLanzDALForXLM dal = new LiLanzDALForXLM(WxConnStr))
        {
            if (WriteSendInfo(dal, rid, "正在推送红包..") == false) return false;


            //执行发放红包的动作
            string UseridToOpenidPost = @"{{                               
                            ""userid"": ""{0}"",
                            ""agentid"": {1}
                        }}";


            string at = clsWXHelper.GetAT(ConfigKeyValue);
            string appid = "";
            string openid = "";
            using (clsJsonHelper jh = clsNetExecute.HttpRequestToWX(string.Format(UseridToOpenidUrl, at), string.Format(UseridToOpenidPost, lstRewardInfo[5], agentid)))
            {
                if (clsWXHelper.CheckResult(ConfigKeyValue, jh.jSon))
                {
                    appid = jh.GetJsonValue("appid");
                    openid = jh.GetJsonValue("openid");
                }
                else
                {
                    WriteLog2(string.Format("name转换openid失败！错误：{0}", jh.jSon));
                    WriteSendInfo(dal, rid, "用户账号识别执行错误！name转换openid失败！" + jh.jSon);

                    return false;
                }
            }

            int total_amount = Convert.ToInt32(Convert.ToDecimal(lstRewardInfo[2]) * 100);
            string remark = lstRewardInfo[3];

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

            SendRedPackPost = string.Format(SendRedPackPost, mch_billno, mch_id, appid, send_name, openid, total_amount
                                            , wishing, clsSharedHelper.GetSourceIP(), act_name, remark, nonce_str);
            
            SendRedPackPost = clsNetExecute.GetSign(SendRedPackPost, APISecret);

            if (certFile.Contains(":") == false)
            {
                certFile = Server.MapPath(certFile);
            }

            if (WriteSendInfo(dal, rid, "开始创建并推送红包..", mch_billno) == false) return false;

            string xmlInfo = clsNetExecute.HttpRequestCert(SendRedPackUrl, SendRedPackPost, certFile, mch_id);
            if (xmlInfo.IndexOf(clsNetExecute.Error) == 0)
            {
                WriteLog2(string.Concat("打赏红包失败0！证书路径：", certFile, "  错误：", xmlInfo));
                RedPackSendInfo = "红包接口调用失败！可能是服务器证书位置不正确！";   //错误可能是因为证书安装不正确，也可能是因为网络原因
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
                string content = string.Concat(lstRewardInfo[3],
                    "\\n\\n<a href='http://tm.lilanz.com/oa/project/StoreSaler/goodsCommentV2.aspx?Isay=1&sphh=", lstRewardInfo[6], "'>>>马上去看看吧！</a>");
                using (clsJsonHelper jh2 = clsWXHelper.SendQYMessage(lstRewardInfo[5], agentid, content))
                {
                    if (jh2.GetJsonValue("errcode") != "0")
                    {
                        RedPackSendInfo = "打赏成功！但发送备注消息失败！错误：" + jh2.jSon;
                        WriteSendInfo(dal, rid, RedPackSendInfo, "");
                    }
                } 
                return true;
            }
            else
            {
                return false;
            }
        }
    }
    
    /// <summary>
    /// EPR登录验证，并返回登录者信息
    /// </summary>
    /// <param name="name">账号</param>
    /// <param name="pwd">密码</param>
    /// <param name="UserInfo">回传的用户信息</param>
    /// <returns></returns>
    private bool ErpLogin(string name,string pwd,ref List<string> UserInfo)
    {
        List<SqlParameter> lstParams = new List<SqlParameter>();
        lstParams.AddRange(new SqlParameter[]{
                new SqlParameter("@name", name),
                new SqlParameter("@pwd", Security.String2MD5(pwd))
        });

        string strInfo = "";
        string OAConnStr = clsConfig.GetConfigValue("OAConnStr");
        using (LiLanzDALForXLM dal = new LiLanzDALForXLM(OAConnStr))
        {
            DataTable dt = null; 
            String strSQL = @"SELECT TOP 1 id,cname FROM t_user WHERE name=@name AND pass=@pwd";

            strInfo = dal.ExecuteQuerySecurity(strSQL, lstParams, out dt);
            if (strInfo !=  "")
            {
                WriteLog2(string.Format("登录失败！错误：{0}", strInfo));
                return false;
            }

            if (dt.Rows.Count == 0)
            {
                WriteLog2(string.Format("登录不成功！账号：{0}密码：{1}", name, pwd));
                return false;                
            }
            
            UserInfo.Add(Convert.ToString(dt.Rows[0][0]));
            UserInfo.Add(Convert.ToString(dt.Rows[0][1]));
            //登录成功，尝试取得其头像

            strSQL = string.Concat("SELECT TOP 1 A.avatar FROM wx_t_customers A INNER JOIN wx_t_AppAuthorized B ON A.ID = B.UserID AND B.SystemID = 1 WHERE B.SystemKey = '", Convert.ToString(dt.Rows[0][0]) , "'");
            object objFace = null;
            strInfo = dal.ExecuteQueryFast(strSQL, out objFace);
            
            dt.Clear(); dt.Dispose();
            GC.Collect();

            if (strInfo != "")
            {
                WriteLog2(string.Format("获取头像失败！错误：{0}", strInfo));      //不用return;           
            }
             
            if (objFace == null) UserInfo.Add("");
            else UserInfo.Add(objFace.ToString()); 
        }

        return true;
    }
        
    /// <summary>
    /// 读取评论信息
    /// </summary>
    /// <param name="eID">评论ID</param>
    /// <param name="lstEvaluationInfo">回传的评论信息</param>
    /// <returns></returns>
    private bool LoadEvaluation(string eID, ref List<string> lstEvaluationInfo)
    {
        List<SqlParameter> lstParams = new List<SqlParameter>();
        lstParams.AddRange(new SqlParameter[]{
                new SqlParameter("@id", eID)
        });

        string strInfo = "";
        string WxConnStr = ConfigurationManager.ConnectionStrings["Conn"].ConnectionString;
        using (LiLanzDALForXLM dal = new LiLanzDALForXLM(WxConnStr))
        {
            DataTable dt = null;
            String strSQL = @"SELECT CreaterID,CreaterName FROM wx_t_Evaluation A WHERE A.ID=@id AND IsActive = 1";

            strInfo = dal.ExecuteQuerySecurity(strSQL, lstParams, out dt);
            if (strInfo != "")
            {
                WriteLog2(string.Format("查询评论失败！错误：{0}", strInfo));
                return false;
            }

            if (dt.Rows.Count == 0)
            {
                WriteLog2(string.Format("评论不存在！ID：{0}", eID));
                return false;
            }

            lstEvaluationInfo.Add(Convert.ToString(dt.Rows[0][0]));
            lstEvaluationInfo.Add(Convert.ToString(dt.Rows[0][1])); 
            
            dt.Clear(); dt.Dispose();
            GC.Collect(); 
        }

        return true;         
    }

    /// <summary>
    /// 创建一条打赏信息
    /// </summary>
    /// <param name="eID">评论ID</param>
    /// <param name="SendUserInfo">打赏者的信息</param>
    /// <param name="ReceiveUserInfo">被打赏者的信息</param>
    /// <returns></returns>
    private int CreateReward(string eID, ref List<string> SendUserInfo, ref List<string> ReceiveUserInfo)
    {
        object rid = 0;

        string RewardMoney = "1";   //最低打赏1元
        string StarLevel = Convert.ToString(Request.Params["StarLevel"]);
        string RewardInfo = Convert.ToString(Request.Params["RewardInfo"]);

        /* //如果本页部署在231则需要进行额外的编码.
        clsLocalLoger.WriteInfo("0:" + RewardInfo);
        RewardInfo = HttpUtility.UrlEncode(RewardInfo, Encoding.GetEncoding("GB2312"));
        clsLocalLoger.WriteInfo("1:" + RewardInfo);
        RewardInfo = HttpUtility.UrlDecode(RewardInfo, System.Text.Encoding.UTF8); 
        clsLocalLoger.WriteInfo("2:" + RewardInfo);
        */
        //231额外编码结束
        string strInfo = "";
        string WxConnStr = ConfigurationManager.ConnectionStrings["Conn"].ConnectionString;
        using (LiLanzDALForXLM dal = new LiLanzDALForXLM(WxConnStr))
        {
            string strSQL;
            List<SqlParameter> lstParams = new List<SqlParameter>();
            
            if (StarLevel == null || StarLevel == "")   //不选星级，直接传入打赏金额
            {
                RewardMoney = Convert.ToString(Request.Params["RewardMoney"]);
                StarLevel = "0";
            }
            else
            {
                strSQL = "SELECT TOP 1 MinMoney,MaxMoney FROM wx_t_RewardStarLevel WHERE StarLevel=@StarLevel";
                lstParams.Add(new SqlParameter("@StarLevel", StarLevel));
                DataTable dtReward;
                strInfo = dal.ExecuteQuerySecurity(strSQL, lstParams, out dtReward);
                if (strInfo != "")
                {
                    WriteLog2(string.Format("获取星级配置失败！错误：", strInfo));
                    return 0;
                }
                else if (dtReward.Rows.Count != 1)
                {
                    WriteLog2(string.Format("无法获取星级配置！StarLevel=", StarLevel));
                    return 0;
                }
                else
                {
                    int rmin = Convert.ToInt32(dtReward.Rows[0]["MinMoney"]);
                    int rmax = Convert.ToInt32(dtReward.Rows[0]["MaxMoney"]);

                    Random rd = new Random();
                    RewardMoney = Convert.ToString(Convert.ToDecimal(rmin + (rmax - rmin) * rd.NextDouble()));

                    dtReward.Clear(); dtReward.Dispose();                    
                }
            } 

            decimal decRewardMoney = 0M;
            if (RewardMoney == null || RewardMoney == "" || decimal.TryParse(RewardMoney, out decRewardMoney) == false)
            {
                WriteLog2(string.Format("打赏金额不错误！RewardMoney={0}", RewardMoney));
                return 0;
            }
            if (RewardInfo == null || RewardInfo == "")
            {
                WriteLog2("必须要输入打赏描述！RewardInfo为空");
                return 0;
            }

            lstParams.Clear();
            lstParams.AddRange(new SqlParameter[]{
                        new SqlParameter("@SourceID", eID)
                      , new SqlParameter("@SendUserID", SendUserInfo[0])
                      , new SqlParameter("@SendUserName", SendUserInfo[1])
                      , new SqlParameter("@SendUserFace", SendUserInfo[2])
                      , new SqlParameter("@ReceiveUserID", ReceiveUserInfo[0])
                      , new SqlParameter("@ReceiveUserName", ReceiveUserInfo[1])
                      , new SqlParameter("@RewardMoney", decRewardMoney)
                      , new SqlParameter("@RewardInfo", RewardInfo)
                      , new SqlParameter("@StarLevel", StarLevel)
                });
                 
            strSQL = @"INSERT INTO wx_t_Reward (SourceID,SendUserID,SendUserName,SendUserFace,ReceiveUserID,ReceiveUserName,RewardMoney,RewardInfo,StarLevel)
		                            VALUES (@SourceID,@SendUserID,@SendUserName,@SendUserFace,@ReceiveUserID,@ReceiveUserName,@RewardMoney,@RewardInfo,@StarLevel)

                               SELECT @@IDENTITY";

            strInfo = dal.ExecuteQueryFastSecurity(strSQL, lstParams, out rid);
            if (strInfo != "")
            {
                WriteLog2(string.Format("创建打赏记录失败！错误：{0}", strInfo));
                rid = 0;
            }
        }

        return Convert.ToInt32(rid);
    }

    private void SendMoneyForQA()
    {
        string qyname = Convert.ToString(Request.Params["name"]);

        string SendError = SendMoneyForQA(qyname);
        if (SendError == "") clsSharedHelper.WriteSuccessedInfo("");
        else clsSharedHelper.WriteErrorInfo(SendError);
    }


    /// <summary>
    /// 直接发放红包
    /// </summary> 
    /// <param name="qyname">企业号的用户名 wx_t_customers.name</param>
    /// <returns></returns>
    private string SendMoneyForQA(string qyname)
    {
        string WxConnStr = ConfigurationManager.ConnectionStrings["Conn"].ConnectionString;
        string RedPackSendInfo = "";
        object objrid = "";
        string rid = ""; 
        string strInfo = "";
        using (LiLanzDALForXLM dal = new LiLanzDALForXLM(WxConnStr))
        {
            //首先，先创建打赏记录 注意：SourceTypeID = 1
            decimal sendMoney = 0.0M;       //随机金额 2-10
            Random rd = new Random();
            sendMoney = Convert.ToDecimal(QARewardMin + (QARewardMax -QARewardMin) * rd.NextDouble());
                        
            string strSQL = @"DECLARE @ReceiveUserID INT,
                                      @ReceiveUserName NVARCHAR(50)
                            SELECT @ReceiveUserID = 0,@ReceiveUserName = ''
                            SELECT TOP 1 @ReceiveUserID = ID,@ReceiveUserName = cname FROM wx_t_customers WHERE [name] = @qyname

                            IF (@ReceiveUserID = 0) SELECT 0
                            -- 注释下行，以方便测试
                            ELSE IF EXISTS (SELECT TOP 1 ID FROM wx_t_Reward WHERE SourceTypeID = @SourceTypeID AND ReceiveUserID = @ReceiveUserID) SELECT -1
                            ELSE
                            BEGIN
                                INSERT INTO wx_t_Reward (SourceTypeID,SourceID,SendUserID,SendUserName,SendUserFace,ReceiveUserID,ReceiveUserName,RewardMoney,RewardInfo)
		                            VALUES (@SourceTypeID,@SourceID,@SendUserID,@SendUserName,@SendUserFace,@ReceiveUserID,@ReceiveUserName,@RewardMoney,@RewardInfo)

                                SELECT @@IDENTITY
                            END";

            List<SqlParameter> lstParams = new List<SqlParameter>();
            lstParams.AddRange(new SqlParameter[]{
                new SqlParameter("@SourceTypeID", 1)
              , new SqlParameter("@SourceID", "0")
              , new SqlParameter("@SendUserID", "0")
              , new SqlParameter("@SendUserName", "利郎销售管理系统")
              , new SqlParameter("@SendUserFace", "")
              , new SqlParameter("@qyname", qyname) 
              , new SqlParameter("@RewardMoney", sendMoney)
              , new SqlParameter("@RewardInfo", QARemark)
        });

            strInfo = dal.ExecuteQueryFastSecurity(strSQL, lstParams, out objrid);
            if (strInfo != "")
            {
                strInfo = string.Format("直接创建打赏记录失败！错误：{0}", strInfo);
                WriteLog2(strInfo);                
                return strInfo;
            }
            rid = Convert.ToString(objrid);

            if (rid == "0") return string.Concat("用户(", qyname, ")不存在！");
            else if (rid == "-1") return string.Concat("用户已经自动打赏过了！");
            
            WriteSendInfo(dal, rid, "正在推送红包..");
             
            //执行发放红包的动作
            string UseridToOpenidPost = @"{{                               
                            ""userid"": ""{0}"",
                            ""agentid"": {1}
                        }}";

            string at = clsWXHelper.GetAT(ConfigKeyValue);
            string appid = "";
            string openid = "";
            using (clsJsonHelper jh = clsNetExecute.HttpRequestToWX(string.Format(UseridToOpenidUrl, at), string.Format(UseridToOpenidPost, qyname, agentid)))
            {
                if (clsWXHelper.CheckResult(ConfigKeyValue, jh.jSon))
                {
                    appid = jh.GetJsonValue("appid");
                    openid = jh.GetJsonValue("openid");
                }
                else
                {
                    strInfo = string.Format("name转换openid失败！错误：{0}", jh.jSon);
                    WriteLog2(strInfo);
                    WriteSendInfo(dal, rid, "用户账号识别执行错误！name转换openid失败！" + jh.jSon);

                    return strInfo;
                }
            }

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

            SendRedPackPost = string.Format(SendRedPackPost, mch_billno, mch_id, appid, send_name, openid, total_amount
                                            , QARemark, clsSharedHelper.GetSourceIP(), QAact_name, QARemark, nonce_str);

            SendRedPackPost = clsNetExecute.GetSign(SendRedPackPost, APISecret);

            if (certFile.Contains(":") == false)
            {
                certFile = Server.MapPath(certFile);
            }

            WriteSendInfo(dal, rid, "开始创建并推送红包..", mch_billno);

            string xmlInfo = clsNetExecute.HttpRequestCert(SendRedPackUrl, SendRedPackPost, certFile, mch_id);
            if (xmlInfo.IndexOf(clsNetExecute.Error) == 0)
            {
                WriteLog2(string.Concat("打赏红包失败0！证书路径：", certFile, "  错误：", xmlInfo));
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
                return "";
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
