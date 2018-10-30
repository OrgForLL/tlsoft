<%@ WebHandler Language="C#" Class="CoffeePayback" %>

using System;
using System.Web;
using System.IO;
using System.Xml;
using System.Text;
using nrWebClass;
using LiLanzModel;
using System.Collections.Generic;
using System.Data.SqlClient;
using System.Data;
public class CoffeePayback : IHttpHandler
{
    
    public void ProcessRequest (HttpContext context) {
        context.Response.ContentType = "text/plain";
        context.Response.ContentEncoding = System.Text.Encoding.UTF8;
        
        string ctrl = context.Request.Params["ctrl"];

        if (string.IsNullOrEmpty(ctrl) == false)
        {
            switch (ctrl)
            {
                case "SendPay": //发起支付的测试地址 http://tm.lilanz.com/QYWX/project/CoffeePay/CoffeePayback.ashx?ctrl=SendPay&CoffeeMdid=0&terminalNo=84721944&channel=15&amount=0.01
                    int CoffeeMdid = Convert.ToInt32(context.Request.Params["CoffeeMdid"]);
                    string terminalNo = context.Request.Params["terminalNo"];
                    string channel = context.Request.Params["channel"];
                    decimal amount = Convert.ToDecimal(context.Request.Params["amount"]);
                    request(CoffeeMdid, terminalNo, channel, amount);
                    return;
                case "CheckPay": //检查支付的测试地址  http://tm.lilanz.com/QYWX/project/CoffeePay/CoffeePayback.ashx?ctrl=CheckPay&orderNo=100000170422102003&terminalNo=84721944
                    long orderNo = Convert.ToInt64(context.Request.Params["orderNo"]);
                    terminalNo = context.Request.Params["terminalNo"];
                    CheckPay(terminalNo, orderNo);
                    return;
                case "RefundPay": //检查支付的测试地址 http://tm.lilanz.com/QYWX/project/CoffeePay/CoffeePayback.ashx?ctrl=RefundPay&terminalNo=84721944&orderNo=100000170413103311
                    orderNo = Convert.ToInt64(context.Request.Params["orderNo"]);
                    terminalNo = context.Request.Params["terminalNo"];
                    refund(terminalNo, orderNo);
                    return;
                case "getCoffeeOrderState": //测试地址 http://tm.lilanz.com/QYWX/project/CoffeePay/CoffeePayback.ashx?ctrl=getCoffeeOrderState&orderNo=100000170413164401&BindBillOrderNo=1
                    orderNo = Convert.ToInt64(context.Request.Params["orderNo"]);
                    long BindBillOrderNo = Convert.ToInt64(context.Request.Params["BindBillOrderNo"]);
                    getCoffeeOrderState(orderNo, BindBillOrderNo);
                    return;
                case "CheckCoffeeOrderState": //测试地址 http://tm.lilanz.com/QYWX/project/CoffeePay/CoffeePayback.ashx?ctrl=getCoffeeOrderState&BindBillOrderNo=1&orderNo=100000170425100741&Checkamount=24.00
                    clsLocalLoger.WriteInfo("主动Checking银联..");
                    orderNo = Convert.ToInt64(context.Request.Params["orderNo"]);
                    BindBillOrderNo = Convert.ToInt64(context.Request.Params["BindBillOrderNo"]);
                    decimal Checkamount = Convert.ToDecimal(context.Request.Params["Checkamount"]);
                    CheckCoffeeOrderState(orderNo, BindBillOrderNo, Checkamount);
                    return;
                case "GetCoffeeOrderList": //测试地址 http://tm.lilanz.com/QYWX/project/CoffeePay/CoffeePayback.ashx?ctrl=GetCoffeeOrderList&CoffeeMdid=0&terminalNo=84721944&Finddate=2017-04-22&status=1&bindstatus=0
                    CoffeeMdid = Convert.ToInt32(context.Request.Params["CoffeeMdid"]);
                    terminalNo = context.Request.Params["terminalNo"];
                    string Finddate = context.Request.Params["Finddate"];
                    string status = context.Request.Params["status"];
                    string bindstatus = context.Request.Params["bindstatus"];

                    GetCoffeeOrderList(CoffeeMdid, terminalNo, Finddate, status, bindstatus);
                    return;
            }
        } 
        
        //是银联发送过来的        
        if ("post".Equals(context.Request.HttpMethod.ToLower()))
        { 
            StreamReader reader = new StreamReader(context.Request.InputStream);
            string content = reader.ReadToEnd();
            UnionPay pay = new UnionPay();
            payBack(pay.Decrypt(content));
            context.Response.Write("done");
        }
    }

    #region 银联支付的相关方法

    //public string TemppalatePath = "";
    //public string InnerMerchantNo = "";

    private string getDBConn()
    {
        if (clsConfig.Contains("WXConnStr"))
        {
            return clsConfig.GetConfigValue("WXConnStr");
        }
        else
        {
            //return "Data Source=192.168.35.23;Initial Catalog=weChatTest;User ID=lllogin;password=rw1894tla";   

            return System.Configuration.ConfigurationManager.ConnectionStrings["Conn"].ConnectionString;
        }  
    }

    private string GetOrderNo(int CoffeeMdid)
    {
        return string.Concat((100000 + CoffeeMdid), DateTime.Now.ToString("yyMMddHHmmss")); 
    }
    
    
    /// <summary>
    /// 发起交易
    /// </summary>
    /// <param name="CoffeeMdid">咖啡馆门店ID，0表示总部咖啡馆</param>
    /// <param name="terminalNo">终端号</param>
    /// <param name="channel">支付应用通道(11、银行卡收单；14、POS通支付宝；15、POS通微信；（其他的暂时没有用到：12、营销联盟；13、POS通银行卡；01、现金结算;05、会员支付)</param>
    /// <param name="amount">金额。单位：元。可以是小数</param>
    public void request(int CoffeeMdid, string terminalNo, string channel, decimal amount)
    { 
        string dbConn = getDBConn();    

        //生成单据号orderNo
        Random rd = new Random();
        string orderNo = GetOrderNo(CoffeeMdid);

        string strSQL = @"INSERT INTO cy_t_UnionpayOrder(orderNo,CoffeeMdid,terminalNo,amount,channel) 
                                VALUES (@orderNo,@CoffeeMdid,@terminalNo,@amount,@channel)";
        List<SqlParameter> lstParams = new List<SqlParameter>();
        lstParams.Add(new SqlParameter("@orderNo", orderNo));
        lstParams.Add(new SqlParameter("@CoffeeMdid", CoffeeMdid));
        lstParams.Add(new SqlParameter("@terminalNo", terminalNo));
        lstParams.Add(new SqlParameter("@amount", amount));
        lstParams.Add(new SqlParameter("@channel", channel));

        string strInfo = "";
        using (LiLanzDALForXLM dal = new LiLanzDALForXLM(dbConn))
        {
            strInfo = dal.ExecuteNonQuerySecurity(strSQL, lstParams);            
        }
        if (string.IsNullOrEmpty(strInfo) == false)
        {
            clsLocalLoger.WriteError(string.Concat("创建订单失败！错误：", strInfo, " orderNo=", orderNo));
            clsSharedHelper.WriteErrorInfo("创建订单失败！内部网络错误！");
            return;// "";            
        }         
        UnionPay pay = new UnionPay();
        string PayType = "1";   //1支付  2撤销
        string oldTraceNo = ""; //撤销时需要输入批次号
        string CoffeePaybackUrl = clsConfig.GetConfigValue("CoffeePaybackUrl");
        string printInfo = "";// "<div align='center' style='font-size:30px;'>欢迎光临利郎臻咖啡</div>";

        clsLocalLoger.WriteInfo(string.Format("[银联支付]terminalNo={0}, channel={1}, orderNo={2}, PayType={3}, amount={4}, oldTraceNo={5}, \n CoffeePaybackUrl={6}, printInfo={7}"
                           ,terminalNo, channel, orderNo, PayType, amount.ToString(), oldTraceNo, CoffeePaybackUrl, printInfo));
        
        UnionPayResult back = pay.request(terminalNo, channel, orderNo, PayType, amount.ToString(), oldTraceNo, CoffeePaybackUrl, printInfo, null);
        strInfo = string.Format("[银联支付]发起支付后的回调报文：orderNo:{0} Code:{1} Msg:{2} OrderSn:{1}", orderNo, back.Code, back.Msg, back.OrderSn);
        clsLocalLoger.WriteInfo(strInfo);
        if (back.Code == "00")
        {
            clsSharedHelper.WriteSuccessedInfo(orderNo);
        }
        else
        {
            clsSharedHelper.WriteErrorInfo(strInfo);
        }                 
    }

    public void getCoffeeOrderState(long orderNo, long BindBillOrderNo)
    {
        string dbConn = getDBConn();

        //生成单据号orderNo  
        string strSQL = @"SELECT TOP 1 traceNo,isRefund,channel FROM cy_t_UnionpayOrder WHERE orderNo = @orderNo AND BindBillOrderNo = 0";
        List<SqlParameter> lstParams = new List<SqlParameter>();
        lstParams.Add(new SqlParameter("@orderNo", orderNo)); 

        string strInfo = "";
        DataTable dt = null;
        string traceNo = "";
        bool isRefund = false;
        string channel = "";
        using (LiLanzDALForXLM dal = new LiLanzDALForXLM(dbConn))
        {
            strInfo = dal.ExecuteQuerySecurity(strSQL, lstParams, out dt);
            if (string.IsNullOrEmpty(strInfo) == false)
            {
                clsLocalLoger.WriteError(string.Concat("检查支付订单失败！错误：", strInfo, " orderNo=", orderNo));
                clsSharedHelper.WriteErrorInfo("检查支付订单失败！内部网络错误！");
                return;
            }
            if (dt.Rows.Count == 0)
            {
                clsSharedHelper.WriteErrorInfo("支付单不存在！");
                return;
            }
            traceNo = Convert.ToString(dt.Rows[0]["traceNo"]);
            isRefund = Convert.ToBoolean(dt.Rows[0]["isRefund"]);
            channel = Convert.ToString(dt.Rows[0]["channel"]);
            if (isRefund)
            {
                clsSharedHelper.WriteErrorInfo("支付单已被退款！");
                return;
            }

            if (string.IsNullOrEmpty(traceNo) == false)
            {
                strSQL = @"UPDATE cy_t_UnionpayOrder SET BindBillOrderNo = @BindBillOrderNo,BindBillOrderDate = GetDate() WHERE orderNo=@orderNo ";
                lstParams.Clear();
                lstParams.Add(new SqlParameter("@BindBillOrderNo", BindBillOrderNo));
                lstParams.Add(new SqlParameter("@orderNo", orderNo));
                strInfo = dal.ExecuteNonQuerySecurity(strSQL, lstParams);
                
                clsSharedHelper.WriteSuccessedInfo(string.Concat("OK|",channel));
            }
            else
            {
                clsSharedHelper.WriteSuccessedInfo("WaitingPay");
            }
        }    
    }


    public void CheckCoffeeOrderState(long orderNo, long BindBillOrderNo, decimal Checkamount)
    {
        string dbConn = getDBConn();

        //生成单据号orderNo  
        string strSQL = @"SELECT TOP 1 traceNo,isRefund,channel,amount FROM cy_t_UnionpayOrder WHERE orderNo = @orderNo AND BindBillOrderNo = 0";
        List<SqlParameter> lstParams = new List<SqlParameter>();
        lstParams.Add(new SqlParameter("@orderNo", orderNo));

        string strInfo = "";
        DataTable dt = null;
        string traceNo = "";
        bool isRefund = false;
        string channel = ""; 
        decimal amount = 0;
        using (LiLanzDALForXLM dal = new LiLanzDALForXLM(dbConn))
        {
            strInfo = dal.ExecuteQuerySecurity(strSQL, lstParams, out dt);
            if (string.IsNullOrEmpty(strInfo) == false)
            {
                clsLocalLoger.WriteError(string.Concat("检查支付订单失败！错误：", strInfo, " orderNo=", orderNo));
                clsSharedHelper.WriteErrorInfo("检查支付订单失败！内部网络错误！");
                return;
            }
            if (dt.Rows.Count == 0)
            {
                clsSharedHelper.WriteErrorInfo("待补录的支付单不存在！");
                return;
            }
            traceNo = Convert.ToString(dt.Rows[0]["traceNo"]);
            isRefund = Convert.ToBoolean(dt.Rows[0]["isRefund"]);
            channel = Convert.ToString(dt.Rows[0]["channel"]); 
            amount = Convert.ToDecimal(dt.Rows[0]["amount"]);
            if (isRefund)
            {
                clsSharedHelper.WriteErrorInfo("支付单已被退款！");
                return;
            } 
            if (amount != Checkamount)
            {
                clsSharedHelper.WriteErrorInfo(string.Format("支付金额错误，该支付单的金额为：{0}",amount));
                return;
            }

            if (string.IsNullOrEmpty(traceNo) == false)
            {
                strSQL = @"UPDATE cy_t_UnionpayOrder SET BindBillOrderNo = @BindBillOrderNo,BindBillOrderDate = GetDate() WHERE orderNo=@orderNo ";
                lstParams.Clear();
                lstParams.Add(new SqlParameter("@BindBillOrderNo", BindBillOrderNo));
                lstParams.Add(new SqlParameter("@orderNo", orderNo));
                strInfo = dal.ExecuteNonQuerySecurity(strSQL, lstParams);

                clsSharedHelper.WriteSuccessedInfo(string.Concat("OK|", channel));
            }
            else
            {
                clsSharedHelper.WriteErrorInfo("该订单未支付，请先在支付管理中状态检查功能！若实际已支付了，请稍后再检查！需要了解更多可直接联系IT部...");
            }
        }
    }

    //倒序返回近30次已成交的单据数据
    public void GetCoffeeOrderList(int CoffeeMdid, string terminalNo, string Finddate,string status,string bindstatus)
    {
        string dbConn = getDBConn();

        StringBuilder sb = new StringBuilder();
        List<SqlParameter> lstParams = new List<SqlParameter>();
        sb.Append(@"SELECT orderNo,traceNo,status,cdate,amount,isRefund,channel,RefundDate,BindBillOrderDate,BindBillOrderNo
                            FROM cy_t_UnionpayOrder WHERE CoffeeMdid = @CoffeeMdid AND terminalNo=@terminalNo ");
        lstParams.Add(new SqlParameter("@CoffeeMdid", CoffeeMdid));
        lstParams.Add(new SqlParameter("@terminalNo", terminalNo));

        sb.Append(" AND cdate > @Finddate AND cdate < DateAdd(day,1,@Finddate) ");
        lstParams.Add(new SqlParameter("@Finddate", Finddate));

        if (status == "0")              sb.Append(" AND status <> 1 ");
        else sb.Append(" AND status = 1 ");

        if (bindstatus == "1") sb.Append(" AND isRefund = 1 ");
        else if (bindstatus == "2") sb.Append(" AND status = 1 AND isRefund = 0 AND BindBillOrderNo = 0 ");        
        
        sb.Append(" ORDER BY ID DESC");
        string strSQL = sb.ToString();
        sb.Length = 0;

        string strInfo = "";
        DataTable dt = null;
        using (LiLanzDALForXLM dal = new LiLanzDALForXLM(dbConn))
        {
            strInfo = dal.ExecuteQuerySecurity(strSQL, lstParams, out dt);
            if (string.IsNullOrEmpty(strInfo) == false)
            {
                clsLocalLoger.WriteError(string.Concat("获取支付订单失败！错误：", strInfo, " CoffeeMdid=", CoffeeMdid));
                clsSharedHelper.WriteErrorInfo("获取支付订单失败！内部网络错误！"); 
                return;
            }

            strInfo = dal.DataTableToXML(dt, "PayOrder");

            clsSharedHelper.DisponseDataTable(ref dt);
            clsSharedHelper.WriteSuccessedInfo(strInfo);            
        }  
        
    } 
    
    /// <summary>
    /// 退款
    /// </summary> 
    /// <returns></returns>
    public void refund(string terminalNo, Int64 orderNo)
    {
        string dbConn = getDBConn();     
        string strInfo = "";
        int status;
        string channel;
        bool isRefund;
        decimal amount;
        string oldTraceNo;
        int CoffeeMdid = 0;
        long oldRefundOrderNo = 0;
        string RefundOrderNo = "";
        DateTime RefundDate;
        using (LiLanzDALForXLM dal = new LiLanzDALForXLM(dbConn))
        {
            System.Data.DataTable dt;
            string strSQL = @"SELECT TOP 1 CoffeeMdid,status,channel,amount,isRefund,traceNo,ISNULL(RefundDate,'1970-01-01') RefundDate
                    ,RefundOrderNo FROM cy_t_UnionpayOrder WHERE terminalNo=@terminalNo AND orderNo=@orderNo";
            List<SqlParameter> lstParams = new List<SqlParameter>();
            lstParams.Add(new SqlParameter("@orderNo", orderNo)); 
            lstParams.Add(new SqlParameter("@terminalNo", terminalNo)); 
            strInfo = dal.ExecuteQuerySecurity(strSQL, lstParams,out dt);  
            if (strInfo != "" || dt.Rows.Count == 0){
                clsLocalLoger.WriteError( string.Concat("[银联支付]退款失败！无法获取原支付信息。错误：", strInfo));
                clsSharedHelper.WriteErrorInfo( string.Concat("[银联支付]退款失败！无法获取原支付信息。"));
                return;
            }
            status = Convert.ToInt32(dt.Rows[0]["status"]);
            channel = Convert.ToString(dt.Rows[0]["channel"]);
            isRefund = Convert.ToBoolean(dt.Rows[0]["isRefund"]);
            amount = Convert.ToDecimal(dt.Rows[0]["amount"]);
            oldTraceNo = Convert.ToString(dt.Rows[0]["traceNo"]);
            CoffeeMdid = Convert.ToInt32(dt.Rows[0]["CoffeeMdid"]);
            RefundDate = Convert.ToDateTime(dt.Rows[0]["RefundDate"]);
            oldRefundOrderNo = Convert.ToInt64(dt.Rows[0]["RefundOrderNo"]);
            clsSharedHelper.DisponseDataTable(ref dt);

            if (status != 1)
            {
                CheckPay(terminalNo, orderNo);
                clsSharedHelper.WriteErrorInfo(string.Concat("[银联支付]暂时不可退款！(status=", status, ")"));
                return;
            }
            if (isRefund)
            {
                clsSharedHelper.WriteErrorInfo(string.Concat("[银联支付]已执行过退款！"));
                return;
            }
            if (oldRefundOrderNo > 0 && DateTime.Now.Subtract(RefundDate).TotalMinutes < 1)
            {
                clsSharedHelper.WriteErrorInfo(string.Concat("[银联支付]一分钟内不允许重复发起退款动作！"));
                return;            
            }
        
            //产生一个新的单号
            RefundOrderNo = GetOrderNo(CoffeeMdid);
            strSQL = string.Format(@"UPDATE  TOP (1) cy_t_UnionpayOrder SET RefundDate='{0}',RefundOrderNo={1} WHERE orderNo={2}", DateTime.Now.ToString("yyyy-MM-dd HH:mm:ss"), RefundOrderNo,orderNo);
            strInfo = dal.ExecuteNonQuery(strSQL);
            if (strInfo != "")
            {
                clsLocalLoger.WriteError(string.Concat("[银联支付]退款失败！创建退款信息失败。错误：", strInfo));
                clsSharedHelper.WriteErrorInfo(string.Concat("[银联支付]退款失败！无法创建退款单。"));
                return;
            }
        }
        
        
        UnionPay pay = new UnionPay(); 
        string PayType = "2";   //1支付  2撤销 
        string CoffeePaybackUrl = clsConfig.GetConfigValue("CoffeePaybackUrl"); 
        string printInfo = "";// "<div align='center' style='font-size:30px;'>欢迎再次光临利郎臻咖啡</div>";

        clsLocalLoger.WriteInfo(string.Format("[银联支付]terminalNo={0}, channel={1}, orderNo={2}, PayType={3}, amount={4}, oldTraceNo={5}, \n CoffeePaybackUrl={6}, 原始单据orderNo={7}"
                           , terminalNo, channel, RefundOrderNo, PayType, amount.ToString(), oldTraceNo, CoffeePaybackUrl, orderNo));

        UnionPayResult back = pay.request(terminalNo, channel, RefundOrderNo, PayType, amount.ToString(), oldTraceNo, CoffeePaybackUrl, printInfo, null);
        strInfo = string.Format("[银联支付]发起退款后的回调报文：orderNo:{0} Code:{1} Msg:{2} OrderSn:{1}", orderNo, back.Code, back.Msg, back.OrderSn);
        clsLocalLoger.WriteInfo(strInfo);
        if (back.Code == "00")
        {
            clsSharedHelper.WriteSuccessedInfo("请在设备上确认！");
        }
        else
        {
            clsSharedHelper.WriteErrorInfo(strInfo);
        }                
    } 
    /// <summary>
    /// 支付回调
    /// </summary>
    /// <param name="xml"></param>
    public void payBack(string xml)
    {
        clsLocalLoger.WriteInfo("[银联支付]收到银联主动推送：" + xml);        
        XmlDocument result = new XmlDocument();
        result.LoadXml(xml); 
        if (result.SelectSingleNode("root/head/result/code").InnerText == "00")
        {
            XmlNode backbody = result.SelectSingleNode("root/body");

            //需根据返回的值判断是否支付成功 
            string rescode = backbody.SelectSingleNode("resCode").InnerText;

            string dbConn = getDBConn();
            using (LiLanzDALForXLM dal = new LiLanzDALForXLM(dbConn))
            {
                string strInfo = "", strSQL;
                int status;
                if (rescode != "00") status = 3;
                else status = 1;
                    
                if (backbody.SelectSingleNode("payTransType").InnerText == "1")
                { //收款行为
                    strSQL = "UPDATE  TOP (1) cy_t_UnionpayOrder SET status=@status,PayBackXml = @PayBackXml,traceNo=@traceNo,channel=@channel where orderNo=@orderNo";
                    List<SqlParameter> lstParams = new List<SqlParameter>();
                    lstParams.Add(new SqlParameter("@status", status));
                    lstParams.Add(new SqlParameter("@PayBackXml", xml));
                    lstParams.Add(new SqlParameter("@orderNo", backbody.SelectSingleNode("orderNo").InnerText));
                    lstParams.Add(new SqlParameter("@traceNo", backbody.SelectSingleNode("traceNo").InnerText));
                    lstParams.Add(new SqlParameter("@channel",backbody.SelectSingleNode("payAppChannel").InnerText));
                    strInfo = dal.ExecuteNonQuerySecurity(strSQL, lstParams);
                    if (strInfo != "")
                    {
                        clsLocalLoger.WriteInfo(string.Concat("[银联支付回调处理]数据更新失败，请重试。错误：", strInfo));
                        clsSharedHelper.WriteErrorInfo("请重新检查支付状态！");
                        return;                           
                    }
                    if (status == 1) clsSharedHelper.WriteSuccessedInfo("OK");
                    else clsSharedHelper.WriteSuccessedInfo("");
                    return;
                }
                else if (backbody.SelectSingleNode("payTransType").InnerText == "2")//退款成功
                {
                    if (status == 1) strSQL = "UPDATE  TOP (1) cy_t_UnionpayOrder SET isRefund=1,RefundDate=getdate(),PayBackXml = @PayBackXml where RefundOrderNo=@orderNo";
                    else strSQL = "UPDATE  TOP (1) cy_t_UnionpayOrder SET RefundOrderNo=0,PayBackXml = @PayBackXml where RefundOrderNo=@orderNo";
                    List<SqlParameter> lstParams = new List<SqlParameter>();
                    lstParams.Add(new SqlParameter("@PayBackXml", xml));
                    lstParams.Add(new SqlParameter("@orderNo", backbody.SelectSingleNode("orderNo").InnerText));
                    strInfo = dal.ExecuteNonQuerySecurity(strSQL, lstParams);
                    if (strInfo != "")
                    {
                        clsLocalLoger.WriteInfo(string.Concat("[银联支付回调处理]退款状态更新失败。错误：", strInfo));
                        clsSharedHelper.WriteErrorInfo("退款状态更新失败！");
                        return;
                    }
                    if (status == 1) clsSharedHelper.WriteSuccessedInfo("Refund OK");
                    else clsSharedHelper.WriteSuccessedInfo("Refund Cancel");
                    return;
                }
                else 
                {
                    strSQL = "UPDATE  TOP (1) cy_t_UnionpayOrder SET PayBackXml = @PayBackXml where orderNo=@orderNo";
                    List<SqlParameter> lstParams = new List<SqlParameter>(); 
                    lstParams.Add(new SqlParameter("@PayBackXml", xml));
                    lstParams.Add(new SqlParameter("@orderNo", backbody.SelectSingleNode("orderNo").InnerText));
                    clsSharedHelper.WriteSuccessedInfo("[银联支付回调处理]检查支付状态失败！");
                    return;                        
                }
            }
        }
        else
        {
            clsLocalLoger.WriteError(string.Concat("检查支付结果！错误：", xml));
            clsSharedHelper.WriteSuccessedInfo("");
            return;                
        }  
    }
    
    public string CheckPay(string terminalNo, Int64 ordersn)
    {
        clsLocalLoger.WriteInfo(string.Format("[银联支付]发出请求。terminalNo={0} , ordersn={1}", terminalNo, ordersn));
        UnionPay pay = new UnionPay();
        pay.InnerMerchantNo = terminalNo;
        string xml = pay.query(terminalNo, ordersn.ToString(), "1");
        payBack(xml);//重新回填信息
        
        //return PayStatus(ordersn);
        return "ok";
    }
    
    #endregion

    public bool IsReusable {
        get {
            return false;
        }
    }

}