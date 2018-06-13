using System;
using System.Collections;
using System.Collections.Generic;
using System.Data;
using System.Web.Services;
using Newtonsoft.Json;
using System.Net;
using System.Data.SqlClient;
using Class_TLtools;
using System.IO;
using Newtonsoft.Json.Linq;
using System.Text;
using System.Xml;
using nrWebClass;

public class PosTPay
{
    private String[] strDigits = new String[16];
    private string WXDBConstr = "server=192.168.35.62;database=weChatPromotion;uid=erpUser;pwd=fjKL29ji.353";
    public ResponseModel res = new ResponseModel();
    //微信，支付宝，银联开始
    public ResponseModel PosTPayForm(string djid, string payment, string dqmd, string dqtz, string fkid, string cllx, string authCode)
    {
        string btmc = "";
        string fkpt = "";
        if (fkid == "-19") { btmc = "微信刷卡支付"; fkpt = "wxzf"; }
        else if (fkid == "-24") { btmc = "银联刷卡支付"; fkpt = "unionpay"; }
        else { btmc = "支付宝刷卡支付"; fkpt = "zfb"; }//fkid = "-20";

        if (djid == "" )
        {
            res = ResponseModel.setRes(1, "无有效参数！");
            return res;
        }
       
        if (cllx == "pay")
        {
            res = PayRun("服装", payment, authCode, djid, dqtz, dqmd, fkid, fkpt);
        }
        else if (cllx == "check")
        {
            res = PayCheck(djid, dqtz, fkid, fkpt);
        }
        else if (cllx == "refund")
        {
            res = PayRefund(djid, dqtz, fkid, fkpt);
        }
        else
        {
            res = ResponseModel.setRes(1, "无有效参数！");
        }
        return res;

    }
    //付款操作
    private ResponseModel PayRun(string body, string total_fee, string authCode, string djid, string tzid, string mdid, string fkid, string fkpt)
    {
        try
        {
            KPay.IMicroPay pClient = new KPay.DefaultMicroPay(tzid, fkid, fkpt).Create();
            string rt = pClient.Run(body, total_fee, authCode, djid, mdid);
            if(rt != "SUCCESS")
            {
                return ResponseModel.setRes(201, "",rt);
            }
            else
            {
                return ResponseModel.setRes(0, rt, "");
            }
        }
        catch (KPay.Common.kException ex)
        {
            return ResponseModel.setRes(1, ex.Message.ToString());
        }
        catch (System.TimeoutException ex)
        {
            return ResponseModel.setRes(1, "请求超时，请重试！");
        }
        catch (Exception ex)
        {
            return ResponseModel.setRes(1, ex.ToString());
        }
    }
    //支付订单检查
    private ResponseModel PayCheck(string djid, string tzid, string fkid, string fkpt)
    {
        try
        {
            KPay.IMicroPay pClient = new KPay.DefaultMicroPay(tzid, fkid, fkpt).Create();
            double payJe = 0;
            if (pClient.TradeCheck(djid, out payJe) != "SUCCESS")
            {
                payJe = 0;
            }
            return ResponseModel.setRes(0, payJe.ToString(),"");
        }
        catch (KPay.Common.kException ex)
        {
            return ResponseModel.setRes(1, ex.Message.ToString());
        }
        catch (System.TimeoutException ex)
        {
            return ResponseModel.setRes(1, "请求超时，请重试！");
        }
        catch (Exception ex)
        {
            //return ex.ToString();
            return ResponseModel.setRes(1, "-1");
        }
    }
    //退款
    private ResponseModel PayRefund(string djid, string tzid, string fkid, string fkpt)
    {
        try
        {
            KPay.IMicroPay pClient = new KPay.DefaultMicroPay(tzid, fkid, fkpt).Create();
            string rt = pClient.TradeRefund(djid);
            if(rt== "SUCCESS")
            {
                return ResponseModel.setRes(0, rt, "");
            }
            else
            {
                return ResponseModel.setRes(201,"", rt);
            }
            
        }
        catch (KPay.Common.kException ex)
        {
            return ResponseModel.setRes(1, ex.Message.ToString());
        }
        catch (System.TimeoutException ex)
        {
            return ResponseModel.setRes(1, "请求超时，请重试！");
        }
        catch (Exception ex)
        {
            return ResponseModel.setRes(1, ex.ToString());
            //return "退款异常";
        }
    }
    //微信卡券
    //查询CODE接口--卡卷查询
    public string CheckCode(string code, string configkey)
    {
        string rtJson = @"{{""can_consume"":{0},""card_status"":""{1}"",""card_description"":""{3}"",""card_discount"":""{4}"",""errmsg"":""{2}"",""localtype"":""{5}"",""leastcost"":""{6}"",""reducecost"":""{7}""}}";
        using (LiLanzDALForXLM dal62 = new LiLanzDALForXLM(WXDBConstr))
        {
            string url = string.Format("https://api.weixin.qq.com/card/code/get?access_token={0}", GetToken(configkey));
            List<SqlParameter> paras = new List<SqlParameter>();
            string str_sql = "", errinfo = "";
            string datas = @"{{                           
                           ""code"" : ""{0}"",
                           ""check_consume"" : false
                        }}";

            datas = string.Format(datas, code);
            string content = PostDataToWX(url, datas);
            JObject jo = JObject.Parse(content);
            if (Convert.ToString(jo["errcode"]) == "0")
            {
                string can_consume = Convert.ToString(jo["can_consume"]).ToLower();
                string openid = Convert.ToString(jo["openid"]);
                string status = Convert.ToString(jo["user_card_status"]);
                string cardid = Convert.ToString(jo["card"]["card_id"]);

                str_sql = @" if exists (select top 1 1 from wx_t_cardinfos where cardid=@cardid and configkey=@configkey and isdel=0)                               
                               begin
                               if exists (select top 1 1 from wx_t_cardcodes where cardid=@cardid and cardcode=@cardcode)
                                 update wx_t_CardCodes set getuser=@openid,usercardstatus=@status,canconsume=@canconsume where cardid=@cardid and cardcode=@cardcode;
                               else
                                 insert into wx_t_CardCodes(cardid,cardcode,isget,getuser,gettime,isconsume,usercardstatus,canconsume)
                                 values(@cardid,@cardcode,1,@openid,getdate(),0,'NORMAL',@canconsume);
                               select top 1 '11',description,localdiscount,localcardtype,LeastCost,ReduceCost from wx_t_cardinfos where cardid=@cardid and configkey=@configkey and isdel=0;
                               end
                             else
                               select '00';";
                paras.Clear();
                paras.Add(new SqlParameter("@cardid", cardid));
                paras.Add(new SqlParameter("@configkey", configkey));
                paras.Add(new SqlParameter("@openid", openid));
                paras.Add(new SqlParameter("@status", status));
                paras.Add(new SqlParameter("@canconsume", can_consume));
                paras.Add(new SqlParameter("@cardcode", code));
                DataTable dt = null;
                errinfo = dal62.ExecuteQuerySecurity(str_sql, paras, out dt);
                if (errinfo != "")
                {
                    //WriteLog("CheckCode WriteDB Is ERROR!" + errinfo);
                    rtJson = string.Format(rtJson, can_consume, status, errinfo, "", "", "", "", "");
                }
                else
                {
                    if (Convert.ToString(dt.Rows[0][0]) == "00")
                        rtJson = string.Format(rtJson, can_consume, status, "该卡券已停用！", "", "", "", "", "");
                    else
                        rtJson = string.Format(rtJson, can_consume, status, "", Convert.ToString(dt.Rows[0][1]), Convert.ToString(dt.Rows[0][2]),
                            Convert.ToString(dt.Rows[0][3]), Convert.ToString(dt.Rows[0][4]), Convert.ToString(dt.Rows[0][5]));
                }
            }
            else
                rtJson = string.Format(rtJson, "false", "", jo["errmsg"], "", "", "", "", "");
        }

        return rtJson;
    }
    //核销Code接口
    //检查跟核销接口中的ACCESSTOKEN都直接根据传入的TZID来判断如果是KHID=17832则使用轻商务的反之使用利郎男装
    //由于不能保证CODE在本地一定存在
    public ResponseModel ConsumeCode(string khid, string code, string configkey)
    {
        JObject ja = new JObject();
        //我们强烈建议开发者在调用核销code接口之前调用查询code接口，并在核销之前对非法状态的code(如转赠中、已删除、已核销等)做出处理。
        string url = string.Format("https://api.weixin.qq.com/card/code/consume?access_token={0}", GetToken(configkey));
        string data = string.Format(@"{{""code"": ""{0}""}}", code);
        string CheckCodeResult = CheckCode(code, configkey);
        JObject ccrjo = JObject.Parse(CheckCodeResult);
        if (Convert.ToBoolean(ccrjo["can_consume"]) && Convert.ToString(ccrjo["errmsg"]) == "")
        {
            string content = PostDataToWX(url, data);
            JObject jo = JObject.Parse(content);
            if (Convert.ToString(jo["errcode"]) == "0")
            {
                //核销成功更新本地数据库
                using (LiLanzDALForXLM dal62 = new LiLanzDALForXLM(WXDBConstr))
                {
                    string str_sql = @"update wx_t_CardCodes set usercardstatus='CONSUMED',canconsume=0,isconsume=1,consumetime=getdate() where cardcode=@cardcode;
                                       insert wx_t_CodeConsume(codeid,cardcode,saleid,creater,createtime,khid)
                                       select top 1 id,cardcode,0,0,getdate()," + khid + " from wx_t_CardCodes where cardcode=@cardcode;";
                    List<SqlParameter> paras = new List<SqlParameter>();
                    paras.Add(new SqlParameter("@cardcode", code));
                    string errinfo = dal62.ExecuteNonQuerySecurity(str_sql, paras);
                    if (errinfo != "")
                    {
                        //WriteLog("核销时提交微信成功，但是更新本地数据时失败！ INFOS:" + errinfo);
                        //clsSharedHelper.WriteErrorInfo("核销时提交微信成功，但是更新本地数据时失败！ INFOS:" + errinfo);
                        res = ResponseModel.setRes(1, "核销时提交微信成功，但是更新本地数据时失败！ INFOS:" + errinfo);
                    }
                    else
                        //clsSharedHelper.WriteSuccessedInfo("核销成功：" + Convert.ToString(jo["openid"]));
                        ja["openid"] = Convert.ToString(jo["openid"]);
                    res = ResponseModel.setRes(0, ja, "核销成功!");
                }
            }
            else
            {
                //WriteLog("核销失败 INFOS:" + content);
                //clsSharedHelper.WriteErrorInfo("核销失败 INFOS:" + content);
                res = ResponseModel.setRes(1, "核销失败 INFOS:" + content);
            }
        }
        else
        {
            //clsSharedHelper.WriteErrorInfo("检查CODE状态不通过！" + CheckCodeResult);
            res = ResponseModel.setRes(1, "检查CODE状态不通过！" + CheckCodeResult);
        }
        return res;
    }
    //获取ACCESS_TOKEN
    public string GetToken(string configkey)
    {
        string _AT = "";
        using (LiLanzDALForXLM dal23 = new LiLanzDALForXLM("server='192.168.35.62';uid=sa;pwd=ll=8727;database=weChatPromotion"))
        {
            string str_sql = "select top 1 accesstoken from wx_t_tokenconfiginfo where configkey='" + configkey + "'";
            object scaler = null;
            string errinfo = dal23.ExecuteQueryFast(str_sql, out scaler);
            if (errinfo == "")
            {
                _AT = Convert.ToString(scaler);
                //if (_AT == "")
                //WriteLog("找不到ConfigKey的ACCESS_TOKEN！");
            }
            //else
            //WriteLog("查询ACCESS_TOKEN时出错 ConfigKey:" + configkey + " " + errinfo);
        }

        return _AT;
    }
    //根据客户id来获取使用哪个公众号的key,错误返回clsNetExecute.Error +错误信息；正确返回key值
    private string GetTokenKey(string khid)
    {
        string errInfo, rt;
        string mysql = "select ccid+'-' from yx_t_khb where khid=@khid";
        List<SqlParameter> para = new List<SqlParameter>();
        para.Add(new SqlParameter("@khid", khid));
        DataTable dt;
        using (LiLanzDALForXLM dal = new LiLanzDALForXLM("server='192.168.35.10';uid=ABEASD14AD;pwd=+AuDkDew;database=tlsoft"))
        {
            errInfo = dal.ExecuteQuerySecurity(mysql, para, out dt);
        }

        if (errInfo != "")
        {
            rt = clsNetExecute.Error + errInfo;
        }
        else if (dt.Rows.Count > 0)
        {
            if (Convert.ToString(dt.Rows[0][0]).IndexOf("-17832-") > 0)
            {
                rt = "7";
            }
            else
            {
                rt = "5";
            }
        }
        else
        {
            rt = clsNetExecute.Error + "系统未找到该客户信息";
        }
        return rt;
    }
    /// <summary>
    /// POST一段信息给微信服务器
    /// </summary>
    /// <param name="url">目标方法的API的URL</param>
    /// <param name="postData">POS数据</param>
    private string PostDataToWX(string url, string postData)
    {
        try
        {
            Stream outstream = null;
            Stream instream = null;
            StreamReader sr = null;
            HttpWebResponse response = null;
            HttpWebRequest request = null;
            Encoding encoding = Encoding.UTF8;
            byte[] data = encoding.GetBytes(postData);
            request = WebRequest.Create(url) as HttpWebRequest;
            CookieContainer cookieContainer = new CookieContainer();
            request.CookieContainer = cookieContainer;
            request.AllowAutoRedirect = true;
            request.Method = "POST";
            request.ContentType = "application/x-www-form-urlencoded";
            request.ContentLength = data.Length;
            outstream = request.GetRequestStream();
            outstream.Write(data, 0, data.Length);
            outstream.Close();
            //发送请求并获取相应回应数据
            response = request.GetResponse() as HttpWebResponse;
            instream = response.GetResponseStream();
            sr = new StreamReader(instream, encoding);
            string content = sr.ReadToEnd();
            return content;
        }
        catch (Exception ex)
        {
            //WriteLog("远程调用异常：" + ex.Message);
            return ex.Message;
        }
    }
    //智能pos
    /// <summary>
    /// 获取POS机终端号
    /// </summary>
    /// <param name="khid">客户ID</param>
    /// <param name="mdid">门店ID</param>
    public ResponseModel getTermialNo(string khid, string mdid)
    {
        JObject ja = new JObject();
        string sql = "";
        sql += " SELECT   a.id,COUNT(a.id) count,MAX(b.termialNo) termialNo ";
        sql += " FROM    zmd_t_postarTerm a ";
        sql += " LEFT JOIN zmd_t_postarTermDetail b ON a.id = b.parentId ";
        sql += " WHERE   a.mdid = " + mdid;
        sql += " GROUP BY a.id; ";
        MyData md = new MyData();
        SqlConnection conn = (SqlConnection)md.MyConn("1");
        SqlDataReader sdr = (SqlDataReader)md.MyDataRead(conn, sql);
        int count = 0;
        string termialNo = "";
        if (sdr.Read())
        {
            count = (int)sdr["count"];
            //termialNo = (string)sdr["termialNo"];
            ja["termialNo"] = Convert.ToString(sdr["termialNo"]);
            res = ResponseModel.setRes(0, ja, "");
        }
        conn.Close();
        md = null;
        //门店没有维护POS机
        if (count == 0 || string.IsNullOrEmpty(termialNo))
        {
            //respMsg(preErr + "本店没有维护星驿付POS机，请添加后再试！");
            //return;
            res = ResponseModel.setRes(1,  "本店没有维护星驿付POS机，请添加后再试！");
        }
        //门店维护多台POS机
        if (count > 1)
        {
            //respMsg(preErr + "本店存在多台星驿付POS机，请选择后再试！");
            //return;
            res = ResponseModel.setRes(1, "本店存在多台星驿付POS机，请选择后再试！");
        }
        ///respMsg(termialNo);
        return res;
    }
    /// <summary>
    /// 新增支付记录，并获取ID
    /// </summary>
    /// <param name="khid">客户ID</param>
    /// <param name="lsdjId">零售单据ID</param>
    /// <param name="je">金额</param>
    public ResponseModel getRecordId(string khid, string lsdjId, string je)
    {
        JObject ja = new JObject();
        string sql = "";
        sql += " INSERT dbo.zmd_t_postarRecord(lsdjId,erpAmt,erpTime,type) ";
        sql += " VALUES(" + lsdjId + "," + je + ",GETDATE(),1); ";
        sql += " SELECT SCOPE_IDENTITY(); ";
        MyData md = new MyData();
        SqlConnection conn = (SqlConnection)md.MyConn(khid);
        object rtnObj = md.MyDataTransID(conn, sql);
        conn.Close();
        md = null;
        string id = "";
        if (rtnObj == null)
        {
            //respMsg(preErr + "新增星驿付付款记录失败，请重试！");
            //return;
            res = ResponseModel.setRes(1, "新增星驿付付款记录失败，请重试！");
        }
        else
        {
            //id = rtnObj.ToString();
            ja["id"] = Convert.ToString(rtnObj.ToString());
            res = ResponseModel.setRes(0, ja);
        }
        return res;
    }


    /// <summary>
    /// 获取订单状态
    /// </summary>
    /// <param name="khid">khid</param>
    /// <param name="recordId">支付记录ID</param>
    public ResponseModel getOrdStatus(string khid, string recordId)
    {
        JObject ja = new JObject();
        string sql = " SELECT ordStatus FROM zmd_t_postarRecord WHERE id = " + recordId + "; ";
        MyData md = new MyData();
        SqlConnection conn = (SqlConnection)md.MyConn(khid);
        SqlDataReader sdr = (SqlDataReader)md.MyDataRead(conn, sql);
        string ordStatus = "";
        if (sdr.Read())
        {
            ordStatus = sdr["ordStatus"] == null ? "" : sdr["ordStatus"].ToString();
            ja["ordStatus"] = Convert.ToString(ordStatus);
            res = ResponseModel.setRes(0, ja);
        }
        conn.Close();
        md = null;
        if (string.IsNullOrEmpty(ordStatus))
        {
            //respMsg(preErr + "获取订单状态失败，请重试！");
            //return;
            res = ResponseModel.setRes(1, "获取订单状态失败，请重试！");
        }
        //respMsg(ordStatus);
        return res;
    }
    /// <summary>
    /// 发送订单信息到星驿付服务器
    /// </summary>
    /// <param name="khid">khid</param>
    /// <param name="mdid">mdid</param>
    /// <param name="recordId">支付记录ID</param>
    /// <param name="je">金额</param>
    /// <param name="termialNo">POS设备终端号</param>
    public ResponseModel sendOrder(string khid, string mdid, string recordId, string je, string termialNo)
    {
        JObject ja = new JObject();
        string sql = "";
        sql += " SELECT   a.id,a.channel,a.agency,b.businessesNo,a.md5Key,a.url ";
        sql += " FROM    zmd_t_postarTerm a ";
        sql += " LEFT JOIN zmd_t_postarTermDetail b ON a.id = b.parentId ";
        sql += " WHERE  a.ty = 0 and a.mdid = " + mdid + " AND b.termialNo = '" + termialNo + "'; ";
        MyData md = new MyData();
        SqlConnection conn = (SqlConnection)md.MyConn("1");
        SqlDataReader sdr = (SqlDataReader)md.MyDataRead(conn, sql);
        string channel = "", agency = "", businessesNo = "", md5Key = "", url = "";
        if (sdr.Read())
        {
            channel = (string)sdr["channel"];
            agency = (string)sdr["agency"];
            businessesNo = (string)sdr["businessesNo"];
            md5Key = (string)sdr["md5Key"];
            url = (string)sdr["url"];
        }
        conn.Close();
        md = null;
        if (string.IsNullOrEmpty(channel) || string.IsNullOrEmpty(agency) || string.IsNullOrEmpty(businessesNo) || string.IsNullOrEmpty(md5Key) || string.IsNullOrEmpty(url))
        {
            //respMsg(preErr + "本店没有维护渠道标识、代理商、商户号、秘钥或地址，或者POS终端号不匹配。\n请检查资料准确性，或者重新选择终端后，再次尝试！");
            //return;
            res = ResponseModel.setRes(1, "本店没有维护渠道标识、代理商、商户号、秘钥或地址，或者POS终端号不匹配。\n请检查资料准确性，或者重新选择终端后，再次尝试！");
        }
        else
        {

            string orderId = khid + "N" + recordId;
            string strToSgin = "CHANNEL=" + channel + "&AGENCY=" + agency;  //渠道标识、代理商
            strToSgin += "&PRDORDNO=" + orderId;  //充值订单号
            strToSgin += "&ORDAMT=" + (decimal.Parse(je) * 100).ToString();  //订单金额
            strToSgin += "&ORDERDATE=" + DateTime.Now.ToString("yyyy-MM-dd HH:mm:ss");  //当前日期
            strToSgin += "&ORDNOTE=" + termialNo;  //订单备注(终端号)
            strToSgin += "&BUSINESSESNO=" + businessesNo;  //商户号
            string sgin = GetMD5Code(strToSgin, md5Key);
            if (!url.EndsWith("/")) url = url + "/";
            url = url + "900001.xml";
            url = url + "?" + strToSgin + "&SGIN=" + sgin;
            //CreateErrorMsg(url);  //打印日志

            //记录服务器、客户端IP
            string serverIP = "", clientIP = "";
            System.Net.IPAddress[] addressList = Dns.GetHostEntry(Dns.GetHostName()).AddressList;
            if (addressList.Length > 1)
            {
                serverIP = addressList[1].ToString();
            }
            clientIP = System.Web.HttpContext.Current.Request.ServerVariables["REMOTE_ADDR"].ToString();
            ja["orderId"] = Convert.ToString(orderId);
            ja["serverIP"] = Convert.ToString(serverIP);
            ja["clientIP"] = Convert.ToString(clientIP);
            ja["url"] = Convert.ToString(url);
            res = ResponseModel.setRes(0, ja);
            //记录访问开始、结束时间
            //CreateErrorMsg("访问对方服务器开始orderId=" + orderId + "|serverIP=" + serverIP + "|clientIP=" + clientIP);
            //respMsg(webRequest(url));
            //CreateErrorMsg("访问对方服务器结束orderId=" + orderId);
        }
        return res;
    }
    /**
   * 加密
   * @param strObj 要加密的对象
   * @param key 16位秘钥值
   * @return
   */
    public String GetMD5Code(String strObj, String key)
    {
        String resultString = null;
        try
        {
            resultString = strObj;
            parseToStringArray(key);
            System.Security.Cryptography.MD5 md5 = System.Security.Cryptography.MD5.Create();
            //返回值为存放哈希值结果的byte数组
            resultString = byteToString(md5.ComputeHash(Encoding.UTF8.GetBytes(strObj)));
            //MessageDigest md = MessageDigest.getInstance("MD5");
            //md.digest()该函数返回值为存放哈希值结果的byte数组
            //resultString = byteToString(md.digest(strObj.getBytes("UTF-8")));
        }
        catch (Exception ex)
        {
            Console.WriteLine(ex.Message);
        }
        return resultString;
    }
    public void CreateErrorMsg(string message)
    {
        string m_fileName = System.Web.HttpContext.Current.Request.MapPath("systemlog.txt");
        if (File.Exists(m_fileName))
        {
            StreamWriter sr = File.AppendText(m_fileName);
            sr.Write("\n");
            sr.WriteLine(DateTime.Now.ToString() + " " + message);
            sr.Close();
        }
        else
        {
            ///创建日志文件
            StreamWriter sr = File.CreateText(m_fileName);
            sr.WriteLine(DateTime.Now.ToString() + " " + message);
            sr.Close();
        }
    }
    //返回形式为数字跟字符串
    private String byteToArrayString(byte bByte)
    {
        int iRet = bByte;
        //System.out.println("iRet="+iRet);
        if (iRet < 0)
        {
            iRet += 256;
        }
        int iD1 = iRet / 16;
        int iD2 = iRet % 16;
        return strDigits[iD1] + strDigits[iD2];
    }

    //转换字节数组为16进制字串
    private String byteToString(byte[] bByte)
    {
        StringBuilder sBuffer = new StringBuilder();
        for (int i = 0; i < bByte.Length; i++)
        {
            sBuffer.Append(byteToArrayString(bByte[i]));
        }
        return sBuffer.ToString();
    }

    //将16位秘钥值转换成字符数组
    private void parseToStringArray(String key)
    {
        if (key.Length == 16)
        {
            for (int i = 0; i < 16; i++)
            {
                //strDigits[i] = key.Substring(i, i + 1);
                strDigits[i] = key.Substring(i, 1);
            }
        }
    }

}
