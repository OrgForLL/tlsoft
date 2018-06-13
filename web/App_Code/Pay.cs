using System;
namespace MicroService
{
    /// <summary>
    /// 微信,银联,支付宝
    /// </summary>
    public class Pay
    {
        /// <summary>
        /// 付款操作,微信刷卡
        /// </summary>
        /// <param name="body">服装</param>
        /// <param name="total_fee">支付金额</param>
        /// <param name="authCode">认证</param>
        /// <param name="djid"></param>
        /// <param name="tzid"></param>
        /// <param name="mdid"></param>
        /// <param name="fkid"></param>
        /// <param name="fkpt"></param>
        /// <returns></returns>      
        private string PayRun(string body, string total_fee, string authCode, string djid, string tzid, string mdid, string fkid, string fkpt)
        {
        //    fkpt | fkid
        //    wxzf | -19
        //unionpay | -24
        //     zfb | -20
            try
            {
                KPay.IMicroPay pClient = new KPay.DefaultMicroPay(tzid, fkid, fkpt).Create();
                return pClient.Run(body, total_fee, authCode, djid, mdid);
            }
            catch (KPay.Common.kException ex)
            {
                return ex.Message.ToString();
            }
            catch (System.TimeoutException ex)
            {
                return "请求超时，请重试！";
            }
            catch (Exception ex)
            {
                return ex.ToString();
            }
        }

        /// <summary>
        /// 支付订单检查
        /// </summary>
        /// <param name="djid"></param>
        /// <param name="tzid"></param>
        /// <param name="fkid"></param>
        /// <param name="fkpt"></param>
        /// <returns></returns>
        private string PayCheck(string djid, string tzid, string fkid, string fkpt)
        {
            try
            {
                KPay.IMicroPay pClient = new KPay.DefaultMicroPay(tzid, fkid, fkpt).Create();
                double payJe = 0;
                if (pClient.TradeCheck(djid, out payJe) != "SUCCESS")
                {
                    payJe = 0;
                }
                return payJe.ToString();
            }
            catch (KPay.Common.kException ex)
            {
                return ex.Message.ToString();
            }
            catch (System.TimeoutException ex)
            {
                return "请求超时，请重试！";
            }
            catch (Exception ex)
            {
                //return ex.ToString();
                return "-1";
            }
        }
        /// <summary>
        /// 支付订单检查
        /// </summary>
        /// <param name="djid"></param>
        /// <param name="tzid"></param>
        /// <param name="fkid"></param>
        /// <param name="fkpt"></param>
        /// <returns></returns>
        private string PayRefund(string djid, string tzid, string fkid, string fkpt)
        {
            try
            {
                KPay.IMicroPay pClient = new KPay.DefaultMicroPay(tzid, fkid, fkpt).Create();
                return pClient.TradeRefund(djid);
            }
            catch (KPay.Common.kException ex)
            {
                return ex.Message.ToString();
            }
            catch (System.TimeoutException ex)
            {
                return "请求超时，请重试！";
            }
            catch (Exception ex)
            {
                return ex.ToString();
                //return "退款异常";
            }
        }
    }
}