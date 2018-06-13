using System;
using System.Web;
using System.Collections.Generic;
using Class_BBlink.LILANZ;
using System.Data.SqlClient;
using nrWebClass;
using wechat;

/// <summary>
/// AppNoticeHelper 的摘要说明
/// </summary>
public class AppNoticeHelper
{
    /// <summary>
    /// 通用APP消息通知
    /// </summary>
    /// <param name="userid">协同userid</param>
    /// <param name="username">协同username</param>
    /// <param name="titile">标题</param>
    /// <param name="desc">描述</param>
    /// <param name="tsxx">返回错误信息</param>
    /// <returns>0 失败；1 成功</returns>
    public static int sendAPPNotice(string userid, string username, string title, string desc, out string tsxx)
    {
        int bVal = 0;
        string url = "";
        //通过协同userid，systemkey=1(协同系统)来转化成 单点登入统一唯一标识；
        string scalar = getUserKey(userid, "1");
        if (scalar == "")//入参合理判断
        {
            tsxx = "单点登入统一唯一标识获取失败";
            return bVal;
        }

        //执行发送
        if (appNotice(scalar, title, desc, url, out tsxx) == 1)
        {
            tsxx = "";
            bVal = 1;
            return bVal;
        }
        else
        {
            bVal = 0;
            return bVal;
        }
    }
    /// <summary>
    /// 发送App信息
    /// </summary>
    /// <param name="userid">协同userid</param>
    /// <param name="username">协同username</param>
    /// <param name="titile">标题</param>
    /// <param name="desc">描述</param>
    /// <param name="complex">移动页面类型 1:XXXXXX;2:XXXXX;</param>
    /// <param name="flowPar">流程参数参入 tzid|docid|dxid|flowid</param>
    /// <returns>0 失败；1 成功</returns>
    public static int sendFlowNotice(string userid, string username, string title, string desc, string complex, string flowPar, out string tsxx)
    {
        int bVal = 0;
        if (complex == "")//入参合理判断
        {
            tsxx = "移动页面类型参数异常";
            return bVal;
        }

        //获取办理页面url
        string url = getGoUrl(complex,flowPar);                        
        //通过协同userid，systemkey=1(协同系统)来转化成 单点登入统一唯一标识；
        string scalar = getUserKey(userid,"1");
        if (scalar == "")//入参合理判断
        {
            tsxx = "单点登入统一唯一标识获取失败";
            return bVal;
        }    
            
        //执行发送
        //string desc = "发送人：" + username + "  发送动作:" + act + "  发送时间：" + DateTime.Now.ToString("yyyy-MM-dd hh:mm:ss") + " 点击立即处理！";
        if (appNotice(scalar, title, desc, url, out tsxx) == 1)
        {
            tsxx = "";
            bVal = 1;
            return bVal;
        }
        else
        {
            bVal = 0;
            return bVal;
        }
    }
    /// <summary>
    /// 获取办理页面url
    /// </summary>
    /// <param name="lx">办理页面类型：=1；=</param>
    /// <param name="flowPar">办理页面称参数</param>
    /// <returns>返回="" 获取失败；=XXX  获取成功；</returns>
    private static string getGoUrl(string lx, string flowPar)
    {
        string bVal;
        string[] pars = flowPar.Split('|');
        if (pars.Length >= 4)
        {
            if (lx == "1")
            {
                bVal = "docDetailData.aspx?tzid=" + pars[0] + "&docid=" + pars[1] + "&dxid=" + pars[2] + "&flowid=" + pars[3] + "&dbname=" + pars[4];
            }
            else
            {
                bVal = "docDetail.aspx?tzid=" + pars[0] + "&docid=" + pars[1] + "&dxid=" + pars[2] + "&flowid=" + pars[3] + "&dbname=" + pars[4];
            }
        }
        else
        {
            bVal = "";
        }
        return bVal;
    }
    /// <summary>
    /// 通过协同userid，systemkey=1来转化成 单点登入统一唯一标识；
    /// </summary>
    /// <param name="erp_userid">协同userid</param>
    /// <param name="systemkey">协同系统标识，暂为1</param>
    /// <returns>返回单点登录的唯一用户表示</returns>
    private static string getUserKey(string erp_userid, string systemkey)
    {
        object userKey;
        SqlConnection sqlConnection = (SqlConnection)DatabaseConn.Connection("wechat");
        using (LiLanzDALForXLM dal = new LiLanzDALForXLM(sqlConnection.ConnectionString))
        {
            sqlConnection.Close(); sqlConnection.Dispose();
            string str_sql = @"select a.userid
                                from wx_t_appauthorized a
                                where a.systemid=@systemkey and a.systemkey=@userid";
            List<SqlParameter> para = new List<SqlParameter>();
            para.Add(new SqlParameter("@userid", erp_userid));
            para.Add(new SqlParameter("@systemkey", systemkey));

            if (dal.ExecuteQueryFastSecurity(str_sql, para, out userKey) == "")
            {
                return userKey.ToString();
            }
            else
            {
                return "";
            }
        }
    }
    /// <summary>
    /// App信息发送
    /// </summary>
    /// <param name="scalar">单点唯一标识</param>
    /// <param name="title">标题</param>
    /// <param name="desc">描述</param>
    /// <param name="url">办理页面url</param>
    /// <param name="tsxx">执行结果信息</param>
    /// <returns>返回值；0 失败； 1 成功</returns>
    private static int appNotice(string scalar, string title, string desc, string url, out string tsxx)
    {
        int bVal = 0;
        try
        {
            wechat.common app = new wechat.common(); //命名空间 wechat                 
            string baseURL = "http://sj.lilang.com:186/llsj/WXAppOuthRedirect.aspx?gourl={0}&systemid=1";
            url = HttpUtility.UrlEncode(url);
            baseURL = HttpUtility.UrlEncode(string.Format(baseURL, url));
            bool result = app.AppNotice(Convert.ToInt32(scalar), title, desc, baseURL);
            if (result == true)
            {
                bVal = 1;
                tsxx = "App信息发送成功";
            }
            else
            {
                bVal = 0;
                tsxx = "App信息-发送失败：" + url;
            }
        }
        catch (Exception ex)
        {
            bVal = 0;
            tsxx = "App信息-通讯失败：" + url;
        }

        return bVal;
    }            
}
