﻿ <%@ WebHandler Language="C#" Class="PosCore" %>

using System;
using System.Web;
using nrWebClass;
using Newtonsoft.Json;
using System.Reflection;
using System.Collections.Generic;
using System.Data.SqlClient;
using System.Data;
using Class_TLtools;
using Newtonsoft.Json.Linq;
using System.IO;
using System.Net;
using System.Text;
using MicroService;
public class PosCore : IHttpHandler, System.Web.SessionState.IRequiresSessionState
{
    int errcode = 0;
    public ResponseModel res;
    public string xlmbaseurl = "http://192.168.135.100:8900/retail-service";
    public string linwybaseurl = "http://192.168.135.100:8900/service-pos";
    public string policiesurl = "http://192.168.135.100:9301/svr-commodity";
    public void ProcessRequest(HttpContext context)
    {
        context.Response.ContentEncoding = System.Text.Encoding.UTF8;
        context.Request.ContentEncoding = System.Text.Encoding.UTF8;
        string action = Convert.ToString(context.Request.Params["action"]);

        MethodInfo method = this.GetType().GetMethod(action);
        if (method == null)
            res = ResponseModel.setRes(201, "无效操作！");
        else
        {
            try
            {
                method.Invoke(this, null);
                return;
            }
            catch (Exception ex)
            {
                res = ResponseModel.setRes(201, "Server Error!!" + ex.Message);
                clsLocalLoger.Log("[posapi.ashx]"+ex.StackTrace);
            }
        }
        clsSharedHelper.WriteInfo(JsonConvert.SerializeObject(res));
    }
    public void MicroPay()
    {
        string djid = Convert.ToString(HttpContext.Current.Request.Params["billID"]);
        string payment = Convert.ToString(HttpContext.Current.Request.Params["payAmount"]);
        string dqmd = Convert.ToString(HttpContext.Current.Request.Params["storeid"]);
        string dqtz = Convert.ToString(HttpContext.Current.Request.Params["orgid"]);
        string fkid = Convert.ToString(HttpContext.Current.Request.Params["payID"]);//付款id
        string cllx = Convert.ToString(HttpContext.Current.Request.Params["category"]);//处理类型
        string authCode = Convert.ToString(HttpContext.Current.Request.Params["authCode"]);

        PosTPay pay = new PosTPay();
        res = pay.PosTPayForm(djid, payment, dqmd, dqtz, fkid, cllx, authCode);
        clsSharedHelper.WriteInfo(JsonConvert.SerializeObject(res));
    }
    public void UnionPay()
    {
        int orgid = Convert.ToInt32(HttpContext.Current.Request.Params["orgid"]);
        int storeid = Convert.ToInt32(HttpContext.Current.Request.Params["storeid"]);
        int userid = Convert.ToInt32(HttpContext.Current.Request.Params["userid"]);
        string operate = Convert.ToString(HttpContext.Current.Request.Params["category"]);//处理类型
        int billID = Convert.ToInt32(HttpContext.Current.Request.Params["billID"]);
        Decimal payment = Convert.ToDecimal(HttpContext.Current.Request.Params["payAmount"]);
        string channel = Convert.ToString(HttpContext.Current.Request.Params["channel"]);//通道

        string ordersn = Convert.ToString(HttpContext.Current.Request.Params["ordersn"]);//订单号


        switch (operate)
        {
            case "pay": pay(billID, payment, channel, orgid, storeid, userid); break;
            case "payStatus": PayStatus(orgid, storeid, userid, ordersn); break;
            case "refund": refund(orgid, storeid, userid, ordersn); break;
            case "orderList": OrderList(orgid, storeid, userid, billID); break;
            case "repay": repay(orgid, storeid, userid, ordersn); break;
            default: clsSharedHelper.WriteInfo("无效操作"); break;
        }
    }
    /***银联智能pos开始***/
    /// <summary>
    /// 支付列表
    /// </summary>
    /// <param name="context"></param>
    public void OrderList(int khid, int mdid, int userid, int id)
    {
        if (id == 0)
        {
            res = ResponseModel.setRes(201, "", "单据不存在,请结算后再支付");
            clsSharedHelper.WriteInfo(JsonConvert.SerializeObject(res));

        }
        LibErp.UnionPosPay pospay = new LibErp.UnionPosPay(khid, mdid, userid);
        Dictionary<string, object> drt = JsonConvert.DeserializeObject<Dictionary<string, object>>(pospay.List(id));
        if (Convert.ToInt32(drt["code"]) == 200)
        {
            res = ResponseModel.setRes(0, drt["data"], "");
        }
        else
        {
            res = ResponseModel.setRes(0, "", Convert.ToString(drt["msg"]));
        }
        clsSharedHelper.WriteInfo(JsonConvert.SerializeObject(res));
    }
    /// <summary>
    /// 重新支付
    /// </summary>
    public void repay(int khid, int mdid, int userid, string ordersn)
    {
        Int64 sn = 0;
        Int64.TryParse(ordersn, out sn);
        LibErp.UnionPosPay pospay = new LibErp.UnionPosPay(khid, mdid, userid);
        res = ResponseModel.setRes(0, pospay.RePay(sn), "");
        clsSharedHelper.WriteInfo(JsonConvert.SerializeObject(res));
    }
    /// <summary>
    /// 退款申请
    /// </summary>
    /// <param name="context"></param>
    public void refund(int khid, int mdid, int userid, string ordersn)
    {
        Int64 sn = 0;
        Int64.TryParse(ordersn, out sn);

        LibErp.UnionPosPay pospay = new LibErp.UnionPosPay(khid, mdid, userid);
        string rel = pospay.refund(sn);
        if (rel == "00")
        {
            res = ResponseModel.setRes(0, "发起撤销成功，请在POS机上完成操作。", "");
            clsSharedHelper.WriteInfo(JsonConvert.SerializeObject(res));
        }
        else
        {
            res = ResponseModel.setRes(201, "", String.Format("发起撤销失败,错误代码：{0}", rel));
            clsSharedHelper.WriteInfo(JsonConvert.SerializeObject(res));
        }
    }
    /// <summary>
    /// 付款状态查询
    /// </summary>
    /// <param name="context"></param>
    public void PayStatus(int khid, int mdid, int userid, string ordersn)
    {
        Int64 id = 0;
        Int64.TryParse(ordersn, out id);
        LibErp.UnionPosPay pospay = new LibErp.UnionPosPay(khid, mdid, userid);
        Dictionary<string, object> drt = JsonConvert.DeserializeObject<Dictionary<string, object>>(pospay.PayStatus(id));
        if (Convert.ToInt32(drt["code"]) == 200)
        {
            drt.Remove("code");
            drt.Remove("msg");
            drt["status"] = Convert.ToInt32(drt["status"]);
            res = ResponseModel.setRes(0, drt, "");
        }
        else
        {
            res = ResponseModel.setRes(0, "", Convert.ToString(drt["msg"]));
        }
        clsSharedHelper.WriteInfo(JsonConvert.SerializeObject(res));
    }
    /// <summary>
    /// 付款申请
    /// </summary>
    /// <param name="context"></param>
    public void pay(int id, decimal amount, string channel, int khid, int mdid, int userid)
    {
        int CheckTime = 30;
        using (LiLanzDALForXLM dal = new LiLanzDALForXLM(khid))
        {
            object objOrderNo = null;
            string strInfo = dal.ExecuteQueryFast(string.Concat(@"SELECT TOP 1 OrderNo FROM zmd_t_UnionpayOrder 
                            WHERE id = ", id, " AND status = 0 AND DATEDIFF(SECOND, cdate, GetDate()) < ", CheckTime, " ORDER BY OrderNo DESC"), out objOrderNo);
            if (strInfo != "")
            {
                clsLocalLoger.WriteError("PosApi.ashx验证支付记录失败！错误：" + strInfo);
                res = ResponseModel.setRes(201, "", "验证支付记录失败！");
                clsSharedHelper.WriteInfo(JsonConvert.SerializeObject(res));
                return;
            }

            if (objOrderNo != null)
            {
                res = ResponseModel.setRes(202, "", "支付已经发起，请在支付设备上操作...");
                clsSharedHelper.WriteInfo(JsonConvert.SerializeObject(res));
                return;
            }
        }

        if (amount == 0)
        {
            res = ResponseModel.setRes(201, "", "支付金额为0！");
            clsSharedHelper.WriteInfo(JsonConvert.SerializeObject(res));
            return;
        }
        LibErp.UnionPosPay pospay = new LibErp.UnionPosPay(khid, mdid, userid);
        pospay.TemppalatePath = HttpContext.Current.Server.MapPath(".\\PrintTempalate.html");

        LiLanzModel.UnionPayResult payres = pospay.pay(id, channel, amount);
        if (payres.Code == "00")
        {
            Dictionary<string, Object> dorder = new Dictionary<string, object>();
            dorder.Add("ordersn", payres.OrderSn);
            res = ResponseModel.setRes(0, dorder, "成功");
        }
        else
        {
            res = ResponseModel.setRes(201, "", payres.Msg);
        }
        clsSharedHelper.WriteInfo(JsonConvert.SerializeObject(res));
    }
    /***智能pos结束***/


    public void PostarPay()
    {
        string orgid = Convert.ToString(HttpContext.Current.Request.Params["orgid"]);
        string storeid = Convert.ToString(HttpContext.Current.Request.Params["storeid"]);

        string billID = Convert.ToString(HttpContext.Current.Request.Params["billID"]);
        string payment = Convert.ToString(HttpContext.Current.Request.Params["payAmount"]);
        string payMode = Convert.ToString(HttpContext.Current.Request.Params["payMode"]);//支付方式
        string operate = Convert.ToString(HttpContext.Current.Request.Params["category"]);//处理类型
        string termialNo=Convert.ToString(HttpContext.Current.Request.Params["termialNo"]);//终端号

        string recordId = Convert.ToString(HttpContext.Current.Request.Params["recordId"]);//支付记录ID
        switch (operate)
        {
            case "getTermialNo":getTermialNo(orgid,storeid);break;
            case "pay":
                postarPay(orgid, storeid, billID, payment, termialNo, payMode); break;
            case "payStatus":getOrdStatus(orgid,recordId);break;

            default:res=ResponseModel.setRes(201,"","无有效的category处理类型");
                clsSharedHelper.WriteInfo(JsonConvert.SerializeObject(res));
                break;
        }
    }
    /********星驿付开始********/

    /// <summary>
    /// 获取订单状态和实际支付金额
    /// </summary>
    /// <param name="khid">khid</param>
    /// <param name="recordId">支付记录ID</param>
    public void getOrdStatus(string khid, string recordId)
    {
        string orderNo = khid + "N" + recordId;
        string sql = " SELECT ordStatus,ordAmt FROM zmd_t_postarRecord WHERE id = " + recordId + "; ";
        string ordStatus = "", ordAmt = "",errInfo;
        DataTable dt;
        using (LiLanzDALForXLM dal=new LiLanzDALForXLM(Convert.ToInt32(khid)))
        {
            errInfo = dal.ExecuteQuery(sql,out dt);
            if(errInfo!="")
            {
                res = ResponseModel.setRes(201, "", "获取订单信息失败，请重试！");
                clsSharedHelper.WriteInfo(JsonConvert.SerializeObject(res));
            }
            if (dt.Rows.Count < 1)
            {
                res = ResponseModel.setRes(201, "", "订单不存在！");
                clsSharedHelper.WriteInfo(JsonConvert.SerializeObject(res));
            }
            ordStatus = Convert.ToString(dt.Rows[0]["ordStatus"]);
            ordAmt = Convert.ToString(dt.Rows[0]["ordAmt"]);
        }

        if (string.IsNullOrEmpty(ordStatus) || string.IsNullOrEmpty(ordAmt))
        {
            res = ResponseModel.setRes(201, "", "获取订单信息失败，请重试！");
            clsSharedHelper.WriteInfo(JsonConvert.SerializeObject(res));
        }
        Dictionary<string, Object> dicRes = new Dictionary<string, Object>();
        dicRes.Add("ordStatus", ordStatus);
        dicRes.Add("ordAmt", ordAmt);
        res = ResponseModel.setRes(0, dicRes, "");
        clsSharedHelper.WriteInfo(JsonConvert.SerializeObject(res));
    }
    /// <summary>
    /// 新增支付记录，并获取ID
    /// </summary>
    /// <param name="khid">客户ID</param>
    /// <param name="lsdjId">零售单据ID</param>
    /// <param name="je">金额</param>
    public String getRecordId(string khid, string lsdjId, string je, string payMode)
    {
        int CheckTime = 30;//30秒内只能发起一次
        string RecordId = "0";
        using (LiLanzDALForXLM dal = new LiLanzDALForXLM(Convert.ToInt32(khid)))
        {
            object objOrderNo = null;
            string strSQL = string.Concat(@"SELECT TOP 1 id FROM zmd_t_postarRecord 
                            WHERE lsdjid = ", lsdjId, " AND ordStatus = 0 AND DATEDIFF(SECOND, erpTime, GetDate()) < ", CheckTime, " ORDER BY ID DESC");
            string strInfo = dal.ExecuteQueryFast(strSQL, out objOrderNo);
            if (strInfo != "")
            {
                res = ResponseModel.setRes(201, "", "验证支付记录失败！");
                clsSharedHelper.WriteInfo(JsonConvert.SerializeObject(res));
            }
            else if (objOrderNo != null)
            {
                res = ResponseModel.setRes(202, "", "支付已经发起，请在支付设备上操作...");
                clsSharedHelper.WriteInfo(JsonConvert.SerializeObject(res));
            }

            strSQL = string.Format(@" DECLARE @id INT; 
        INSERT dbo.zmd_t_postarRecord(lsdjId,erpAmt,erpTime,type,payMode) VALUES({0},{1},GETDATE(),1, {2});
        SELECT @id = SCOPE_IDENTITY(); UPDATE zmd_t_postarRecord SET prdOrdNo = '{3}' + 'N' + CAST(@id AS VARCHAR(20)) WHERE id = @id; SELECT @id;  ", lsdjId, je, payMode, khid);
            object rtnObj;
            strInfo = dal.ExecuteQueryFast(strSQL, out rtnObj);
            if (rtnObj == null)
            {
                res = ResponseModel.setRes(201, "", "新增星驿付付款记录失败，请重试！");
                clsSharedHelper.WriteInfo(JsonConvert.SerializeObject(res));
            }
            else
            {
                // res = ResponseModel.setRes(0, rtnObj, "");
                RecordId = Convert.ToString(rtnObj);
            }
        }
        return RecordId;
    }
    /// <summary>
    /// 获取POS机终端号
    /// </summary>
    /// <param name="khid">客户ID</param>
    /// <param name="mdid">门店ID</param>
    public void getTermialNo(string khid, string mdid)
    {
        string sql = @"SELECT a.id,b.termialNo 
                       FROM zmd_t_postarTerm a 
                       LEFT JOIN zmd_t_postarTermDetail b ON a.id = b.parentId 
                       WHERE   a.mdid = " + mdid;
        using (LiLanzDALForXLM dal = new LiLanzDALForXLM(1))
        {
            DataTable dt;
            string errInfo = dal.ExecuteQuery(sql, out dt);
            if (errInfo != "")
            {
                res = ResponseModel.setRes(201, "", errInfo);
            }
            else
            {
                res = ResponseModel.setRes(0, dt, "");
            }
        }
        clsSharedHelper.WriteInfo(JsonConvert.SerializeObject(res));
    }

    /// <summary>
    /// 发送订单信息到星驿付服务器
    /// </summary>
    /// <param name="khid">khid</param>
    /// <param name="mdid">mdid</param>
    /// <param name="recordId">支付记录ID</param>
    /// <param name="je">金额</param>
    /// <param name="termialNo">POS设备终端号</param>
    public void postarPay(string khid, string mdid, string lsdjId, string je, string termialNo, string payMode)
    {
        string recordId = getRecordId(khid, lsdjId, je, payMode);
        string sql = string.Format(@"SELECT a.id,a.channel,a.agency,b.businessesNo,a.md5Key,a.url 
                                      FROM zmd_t_postarTerm a 
                                      LEFT JOIN zmd_t_postarTermDetail b ON a.id = b.parentId 
                                      WHERE a.ty = 0 and a.mdid = {0} AND b.termialNo = '{1}'; ", mdid, termialNo);
        string channel = "", agency = "", businessesNo = "", md5Key = "", url = "";
        DataTable dt;
        using (LiLanzDALForXLM dal = new LiLanzDALForXLM(1))
        {
            string errInfo = dal.ExecuteQuery(sql, out dt);
            if (errInfo != "")
            {
                res = ResponseModel.setRes(201, "", errInfo);
                clsSharedHelper.WriteInfo(JsonConvert.SerializeObject(res));
            }
            channel =Convert.ToString( dt.Rows[0]["channel"]);
            agency = Convert.ToString( dt.Rows[0]["agency"]);
            businessesNo = Convert.ToString( dt.Rows[0]["businessesNo"]);
            md5Key =Convert.ToString( dt.Rows[0]["md5Key"]);
            url = Convert.ToString( dt.Rows[0]["url"]);
        }

        if (string.IsNullOrEmpty(channel) || string.IsNullOrEmpty(agency) || string.IsNullOrEmpty(businessesNo) || string.IsNullOrEmpty(md5Key) || string.IsNullOrEmpty(url))
        {
            res = ResponseModel.setRes(201, "",  "本店没有维护渠道标识、代理商、商户号、秘钥或地址，或者POS终端号不匹配。\n请检查资料准确性，或者重新选择终端后，再次尝试！");
            clsSharedHelper.WriteInfo(JsonConvert.SerializeObject(res));
        }

        string orderId = khid + "N" + recordId;
        string strToSgin = "CHANNEL=" + channel + "&AGENCY=" + agency;  //渠道标识、代理商
        strToSgin += "&PRDORDNO=" + orderId;  //充值订单号
        strToSgin += "&ORDAMT=" + (decimal.Parse(je) * 100).ToString();  //订单金额
        strToSgin += "&ORDERDATE=" + DateTime.Now.ToString("yyyy-MM-dd HH:mm:ss");  //当前日期
        strToSgin += "&ORDNOTE=" + termialNo;  //订单备注(终端号)
        strToSgin += "&BUSINESSESNO=" + businessesNo;  //商户号
        strToSgin += "&PAYMODE=" + payMode;  //支付方式
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
        clientIP = HttpContext.Current.Request.ServerVariables["REMOTE_ADDR"].ToString();

        //记录访问开始、结束时间
        //CreateErrorMsg("访问对方服务器开始orderId=" + orderId + "|serverIP=" + serverIP + "|clientIP=" + clientIP);
        string strRtn =webRequest(url);
        //CreateErrorMsg("访问对方服务器结束orderId=" + orderId);
        JObject jo = null;
        jo = JsonConvert.DeserializeObject<JObject>(strRtn);
        if (jo == null)
        {
            res = ResponseModel.setRes(201, "",  "发送订单信息失败，请重试！");
            clsSharedHelper.WriteInfo(JsonConvert.SerializeObject(res));
        }
        string strRspCod = (string)jo.GetValue("RSPCOD", StringComparison.OrdinalIgnoreCase);
        string strRspMsg = (string)jo.GetValue("RSPMSG", StringComparison.OrdinalIgnoreCase);
        if (strRspCod == "000000")
        {
            Dictionary<string, object> rd = new Dictionary<string, object>();
            rd.Add("recordId", recordId);
            rd.Add("paymsg", strRspMsg);
            res = ResponseModel.setRes(0, rd, "");
        }
        else
        {
            res = ResponseModel.setRes(201,"", strRspMsg);
        }
        clsSharedHelper.WriteInfo(JsonConvert.SerializeObject(res));
    }
    /// <summary>
    /// 访问指定url页面
    /// </summary>
    /// <param name="url">url</param>
    /// <returns>输出结果</returns>
    public string webRequest(string url)
    {
        WebRequest req = WebRequest.Create(url);
        //超时时间设成10秒
        //req.Timeout = 10000;
        WebResponse resp = req.GetResponse();
        Stream stream = resp.GetResponseStream();
        StreamReader sr = new StreamReader(stream, encoding);
        return sr.ReadToEnd();
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
            resultString = byteToString(md5.ComputeHash( Encoding.UTF8.GetBytes(strObj)));
        }
        catch (Exception ex)
        {
            Console.WriteLine(ex.Message);
        }
        return resultString;
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
    //全局数组
    private String[] strDigits = new String[16];
    Encoding encoding = Encoding.UTF8;
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
    /********星驿付结束********/

    /// <summary>
    /// 加载退货单据详情
    /// </summary>
    public void LoadByBillNo()
    {
        string storeid = Convert.ToString(HttpContext.Current.Request.Params["storeid"]);
        string billNo = Convert.ToString(HttpContext.Current.Request.Params["billNo"]);
        string rt = clsNetExecute.HttpRequest(string.Format("{0}/LoadByBillNo?storeid={1}&billNo={2}", linwybaseurl,storeid, billNo));
        clsSharedHelper.WriteInfo(rt);
    }

    /// <summary>
    /// 加载付款方式列表
    /// </summary>
    public void LoadPayMode()
    {
        string orgid = Convert.ToString(HttpContext.Current.Request.Params["orgid"]);
        string mode = Convert.ToString(HttpContext.Current.Request.Params["mode"]);
        string rt = clsNetExecute.HttpRequest(string.Format(linwybaseurl+"/LoadPayMode?orgid={0}&mode={1}", orgid, mode));
        clsSharedHelper.WriteInfo(rt);
    }
    /// <summary>
    /// 销售汇总
    /// </summary>
    public void GetSales()
    {
        string storeid = Convert.ToString(HttpContext.Current.Request.Params["storeid"]);

        string rt = clsNetExecute.HttpRequest(string.Format(linwybaseurl+"/GetSales?storeid={0}", storeid));
        clsSharedHelper.WriteInfo(rt);
    }
    /// <summary>
    /// 打印保存
    /// </summary>
    public void SavePrint()
    {
        string jsondata = Convert.ToString(HttpContext.Current.Request.Params["data"]);
        string rt = clsNetExecute.HttpRequest(linwybaseurl+"/SavePrint?data=" + jsondata);
        Dictionary<string, object> djson = JsonConvert.DeserializeObject<Dictionary<string, object>>(jsondata);
        Dictionary<string, object> drt = JsonConvert.DeserializeObject<Dictionary<string, object>>(rt);
        if(Convert.ToInt32( drt["errcode"]) == 0)
        {
            string mysql = "select ssclxz from yx_t_khb where khid={0}";
            string errInfo;
            object objtemp;
            using (LiLanzDALForXLM dal=new LiLanzDALForXLM(Convert.ToString(djson["storeID"])))
            {
                errInfo = dal.ExecuteQueryFast(string.Format(mysql,djson["storeID"]),out objtemp);
                if(Convert.ToInt32(objtemp) > 1)//客户表ssclxz大于1才有实时控制库存
                {
                    errInfo = dal.ExecuteQueryFast(string.Format("select djlb from Zmd_T_lsdjb where id={0}",djson["id"]),out objtemp);
                    Stock stock = new Stock();
                    int tableID = 2;
                    string json = "";
                    string api =  (Convert.ToInt32(objtemp) < 0) ? "multiDelStock" : "";
                    int mykey = Convert.ToInt32(djson["id"]);
                    errInfo=stock.upData(api, mykey, tableID, json);
                    clsLocalLoger.Log("【零售开单--库存处理】：" + errInfo);
                }
            }
        }
        clsSharedHelper.WriteInfo(rt);
    }
    /// <summary>
    /// 打印页面
    /// </summary>
    public void printurl()
    {
        string url = Convert.ToString(HttpContext.Current.Request.Params["data"]);
        url = HttpUtility.UrlDecode(url);
        string[] param = url.Split('|');
        if (param.Length > 0)
        {
            string id = param[param.Length - 1].Split('=')[1];
            string TaskCode = "VipLsdjServer";
            string json = "{ \"khid\":\""+ param[0].Split('=')[1].Split('|')[0]+"\" }";
            string strInfo=  clsAsynTask.Submit(TaskCode, Convert.ToInt32(id), json);
            if(strInfo != clsSharedHelper.Successed)
            {
                clsLocalLoger.WriteError(String.Format("【PosApi.ashx】提交异步任务失败！参数：{0} id:{1}  {2} 。错误：{3}", TaskCode, id, json, strInfo));
            }
        }
        System.Web.HttpContext.Current.Response.Redirect(url);
    }

    /// <summary>
    /// 读取单据列表(挂单列表)
    /// </summary>
    /// <param name="storeid"></param>
    public void LoadOrderList()
    {
        string storeid = Convert.ToString(HttpContext.Current.Request.Params["storeid"]);
        string rt = clsNetExecute.HttpRequest(linwybaseurl+"/LoadOrderList?storeid=" + storeid);
        clsSharedHelper.WriteInfo(rt);
    }
    /// <summary>
    /// 读取单据列表(挂单列表)
    /// </summary>
    /// <param name="storeid"></param>
    public void GetOrder()
    {
        string billID = Convert.ToString(HttpContext.Current.Request.Params["orderid"]);
        string rt = clsNetExecute.HttpRequest(linwybaseurl+"/GetOrder?billID=" + billID);
        clsSharedHelper.WriteInfo(rt);
    }
    /// <summary>
    /// (微信)卡券核销
    /// </summary>
    /// <param name="cardno"></param>
    public void CardUse(string cardno)
    {
        res = ResponseModel.setRes(errcode, "", "成功");
        clsSharedHelper.WriteInfo(JsonConvert.SerializeObject(res));
    }


    /// <summary>
    /// 营业员
    /// </summary>
    /// <param name="storeid"></param>
    public void LoadSaler()
    {
        string orgid = Convert.ToString(HttpContext.Current.Request.Params["orgid"]);
        string cname = Convert.ToString(HttpContext.Current.Request.Params["cname"]);
        string rt = clsNetExecute.HttpRequest(string.Format(linwybaseurl+"/LoadSaler?orgid={0}&cname={1}", orgid, cname));
        clsSharedHelper.WriteInfo(rt);
    }
    /// <summary>
    /// 结算保存(保存为草稿)
    /// </summary>
    /// <param name="vipcardno"></param>
    public void SaveOrder()
    {
        string jsondata = Convert.ToString(HttpContext.Current.Request.Params["data"]);
        Dictionary<string, object> djson = JsonConvert.DeserializeObject<Dictionary<string, object>>(jsondata);
        string rt = "";
        try
        {
            rt = clsNetExecute.HttpRequest(linwybaseurl+"/SaveOrder","data="+jsondata,"POST","UTF-8",10000);
        }catch(Exception ex)
        {
            res = ResponseModel.setRes(201, "", ex.StackTrace);
        }
        clsSharedHelper.WriteInfo(rt);
    }

    // <summary>
    /// 读取VIP常用地址
    /// </summary>
    /// <param name="vipcardno"></param>
    public void LoadVipAddress()
    {
        string vipcardno = Convert.ToString(HttpContext.Current.Request.Params["vipcardno"]);
        string rt = clsNetExecute.HttpRequest(string.Format("{0}/LoadVipAddress?code={1}", xlmbaseurl, vipcardno));
        clsSharedHelper.WriteInfo(rt);
    }
    /// <summary>
    /// 取VIP历史消费数据
    /// </summary>
    /// <param name="vipcardno"></param>
    public void LoadVipOrder()
    {
        string vipcardno = Convert.ToString(HttpContext.Current.Request.Params["vipcardno"]);
        string rt = clsNetExecute.HttpRequest(string.Format("{0}/LoadVipOrder?vipcardno={1}", xlmbaseurl, vipcardno));
        clsSharedHelper.WriteInfo(rt);
    }

    /// <summary>
    /// 取VIP行为轨迹
    /// </summary>
    /// <param name="vipcode"></param>
    public void LoadVipAction()
    {
        string vipcardno = Convert.ToString(HttpContext.Current.Request.Params["vipcardno"]);
        string rt = clsNetExecute.HttpRequest(string.Format("{0}/LoadVipAction?vipcardno={1}", xlmbaseurl, vipcardno));
        clsSharedHelper.WriteInfo(rt);
    }

    /// <summary>
    /// 读VIP
    /// </summary>
    public void GetVip()
    {
        string vipcardno = Convert.ToString(HttpContext.Current.Request.Params["vipcardno"]);
        string phone = Convert.ToString(HttpContext.Current.Request.Params["phone"]);
        string name = Convert.ToString(HttpContext.Current.Request.Params["name"]);
        string orgid = Convert.ToString(HttpContext.Current.Request.Params["orgid"]);

        if (string.IsNullOrEmpty(orgid))
        {
            res = ResponseModel.setRes(201, "", "缺少orgid参数");
            clsSharedHelper.WriteInfo(JsonConvert.SerializeObject(res));
        }

        string url;
        if (!string.IsNullOrEmpty(vipcardno))
        {
            url = string.Format(xlmbaseurl+"/GetVipByCard?vipcardno={0}&orgid={1}", vipcardno, orgid);
        }
        else if (!string.IsNullOrEmpty(phone))
        {
            url = string.Format(xlmbaseurl+"/GetVipByPhone?phone={0}&orgid={1}", phone, orgid);
        }
        else
        {
            url = string.Format(xlmbaseurl+"/GetVipByName?name={0}&orgid={1}", name, orgid);
        }

        string rt = clsNetExecute.HttpRequest(url);

        Dictionary<string, object> drt = JsonConvert.DeserializeObject< Dictionary<string, object>>(rt);
        if(Convert.ToInt32( drt["errcode"])== 0)
        {
            Dictionary<string, object> data = JsonConvert.DeserializeObject<Dictionary<string, object>>(JsonConvert.SerializeObject(drt["data"]));
            if(Convert.ToString(data["vipFlag"]) != "new")
            {
                data["points"] = "";
                int point = vipPoints(Convert.ToString(data["vipCardCode"]));
                if(point !=-1)
                {
                    data["points"] = point;
                }
            }
        }

        clsSharedHelper.WriteInfo(rt);
    }
    /// <summary>
    /// 读条码
    /// </summary>
    public void LoadProduct()
    {
        string code = Convert.ToString(HttpContext.Current.Request.Params["code"]);
        string orgid = Convert.ToString(HttpContext.Current.Request.Params["orgid"]);
        string storeid = Convert.ToString(HttpContext.Current.Request.Params["storeid"]);
        string rt = clsNetExecute.HttpRequest(string.Format("{0}/LoadProduct?code={1}&orgid={2}&storeid={3}", xlmbaseurl, code, orgid,storeid));

        clsSharedHelper.WriteInfo(rt);
    }

    /// <summary>
    /// 当前用户信息（userid,username,折扣等）
    /// </summary>
    /// <param name="storeid"></param>
    /// <param name="userid"></param>
    public void InitCurrent()
    {
        string storeid = Convert.ToString(HttpContext.Current.Session["mdid"]);
        string userid = Convert.ToString(HttpContext.Current.Session["userid"]);
        string mySession = Convert.ToString(HttpContext.Current.Session["MySession"]);

        if ( clsConfig.Contains("mode")  )
        {
            if (clsConfig.GetConfigValue("mode") == "test")
            {
                storeid = "1522";
                userid = "15872";
            }
        }

        mySession=  string.Format("{0}|{1}|{2}|{3}|{4}|192.168.35.11|FXDB",HttpContext.Current.Session["userssID"],HttpContext.Current.Session["user"],HttpContext.Current.Session["username"]
              ,HttpContext.Current.Session["userID"],HttpContext.Current.Session["zbid"]);

        string rt = clsNetExecute.HttpRequest(string.Format("{0}/InitCurrent?storeid={1}&userid={2}", xlmbaseurl, storeid, userid));
        Dictionary<string, object> dobj = JsonConvert.DeserializeObject<Dictionary<string, object>>(rt);
        if(dobj["data"] != null)
        {
            Dictionary<string, object> ddata = JsonConvert.DeserializeObject<Dictionary<string, object>>(JsonConvert.SerializeObject(dobj["data"]));
            ddata.Add("mySession", mySession);
            dobj["data"] = ddata;
            clsSharedHelper.WriteInfo(JsonConvert.SerializeObject(dobj));
        }
        else
        {
            clsSharedHelper.WriteInfo(rt);
        }
    }


    public void GetVipPoints()
    {
        string vipCardCode = Convert.ToString(HttpContext.Current.Request.Params["vipCardCode"]);
        string rt = clsNetExecute.HttpRequest(string.Format("http://192.168.35.29:9401/GetVipPoint?vipcardno={0}",vipCardCode));
        clsSharedHelper.WriteInfo(rt);
    }

    private int vipPoints(string cardCode)
    {
        int point = -1;
        string rt = clsNetExecute.HttpRequest(string.Format("http://192.168.35.29:9401/GetVipPoint?vipcardno={0}",cardCode));
        Dictionary<string, object> drt = JsonConvert.DeserializeObject<Dictionary<string, object>>(rt);
        point = Convert.ToInt32(drt["data"]);
        return point;
    }

    public bool IsReusable
    {
        get
        {
            return false;
        }
    }
}