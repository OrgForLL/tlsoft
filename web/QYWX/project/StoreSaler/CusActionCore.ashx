<%@ WebHandler Language="C#" Class="CusActionCore" %>

using System.Web;
using System.Web.SessionState;
using System.Reflection;
using nrWebClass;

public class CusActionCore : IRequiresSessionState
{
    public void ProcessRequest(HttpContext context)
    {
        string act = context.Request.Params["act"];

        if (string.IsNullOrEmpty(act))
        {
            clsSharedHelper.WriteErrorInfo("缺乏参数act");
        }

        MethodInfo mi = this.GetType().GetMethod(act);
        mi.Invoke(this, null);
    }


    /// <summary>
    /// 用VIP卡号作为标识，记录顾客行为。
    /// </summary>
    /// <param name="vipkh">卡号</param>
    /// <param name="ActionID">行为类型ID</param>
    /// <param name="ActionRemark">行为描述</param>
    /// <param name="DataJson">相关数据</param>
    /// <returns></returns>
    public void AddCusAction_ERP(string vipkh, int ActionID, string ActionRemark, string DataJson)
    {
        return true;
    }

    /// <summary>
    /// 用微信OPENID作为标识，记录顾客行为。
    /// </summary>
    /// <param name="openid">OPENID</param>
    /// <param name="ActionID">行为类型ID</param>
    /// <param name="ActionRemark">行为描述</param>
    /// <param name="DataJson">相关数据</param>
    /// <returns></returns>
    public void AddCusAction_WX()
    {
        //取得参数值
        string openid = HttpContext.Current.Request.Params["openid"];
        string strActionID = HttpContext.Current.Request.Params["ActionID"];
        string ActionRemark = HttpContext.Current.Request.Params["ActionRemark"];
        string DataJson = HttpContext.Current.Request.Params["DataJson"];
        int ActionID = 0;

        if (string.IsNullOrEmpty(openid))
        {
            clsSharedHelper.WriteErrorInfo("缺少参数1");
        }
        if (string.IsNullOrEmpty(strActionID))
        {
            clsSharedHelper.WriteErrorInfo("缺少参数2");
        }
        if (string.IsNullOrEmpty(ActionRemark))
        {
            clsSharedHelper.WriteErrorInfo("缺少参数3");
        }
        if (string.IsNullOrEmpty(DataJson))
        {
            DataJson = "{}";
        }
        int.TryParse(strActionID, out ActionID);

        //首先 根据 LinkKey = openid 去取 wx_t_CusLink 表 LinkType = 2 的数据，是否存在。
        

        //如果存在，则得到其 CusKey；否则创建 一条数据到 wx_t_CusInfo 中，并得到 CusKey

        //插入行为数据到wx_t_CusHistory

    }

    ///// <summary>
    ///// 用VIP卡号返回用户的行为数据（近一年）
    ///// </summary>
    ///// <param name="vipkh"></param>
    ///// <returns></returns>
    //public static DataTable GetCusHistory_ERP(string vipkh)
    //{
    //    return null;
    //}

    ///// <summary>
    ///// 用微信OPENID返回用户的行为数据（近一年）
    ///// </summary>
    ///// <param name="openid"></param>
    ///// <returns></returns>
    //public static DataTable GetCusAction_WX(string openid)
    //{
    //    return null;
    //}

    ///// <summary>
    ///// 用VIP卡号返回用户特定时间开始到当前为止的行为数据
    ///// </summary>
    ///// <param name="vipkh">VIP卡号</param> 
    ///// <param name="FindDateBegin">查询开始时间</param>
    ///// <returns></returns>
    //public static DataTable GetCusHistory_ERP(string vipkh,DateTime FindDateBegin)
    //{
    //    return null;
    //}

    ///// <summary>
    ///// 用微信OPENID返回用户特定时间开始到当前为止的行为数据
    ///// </summary>
    ///// <param name="openid">openid</param> 
    ///// <param name="FindDateBegin">查询开始时间</param>
    ///// <returns></returns>
    //public static DataTable AddCusAction_WX(string openid, DateTime FindDateBegin)
    //{
    //    return null;
    //}

}