<%@ WebHandler Language="C#" Class="wxGetPrizeCore" %>

using System;
using System.Web;
using nrWebClass;
using System.Data;
using System.Data.SqlClient;
using System.Collections.Generic;
using System.Text;

public class wxGetPrizeCore : IHttpHandler, System.Web.SessionState.IRequiresSessionState 
{

    private string WXConnStr;// = clsConfig.GetConfigValue("WXConnStr");
    string OAConnStr = clsConfig.GetConfigValue("OAConnStr");
    private bool IsTestMode = false;
    public void ProcessRequest (HttpContext context) {
        context.Response.ContentType = "text/plain";

        SetDebugMode();
        
        if (clsConfig.Contains("WXConnStr"))
        {
            WXConnStr = clsConfig.GetConfigValue("WXConnStr");
        }
        else
        {
            WXConnStr = System.Web.Configuration.WebConfigurationManager.ConnectionStrings["Conn"].ConnectionString;
        }        
        

        string ctrl = context.Request.Params["ctrl"];

        switch (ctrl)
        {
            case "getPrizeList":       //店长：获取客人近一年来，获得的礼品
                getPrizeList();
                break;
            case "payPrizeOne":        //客人：确认 发放礼品1个。（此方法执行时会先进行相关检查） 
                payPrizeOne();
                break;
            case "payPrizeAll":        //客人：确认 发放全部礼品。（此方法执行时会先进行相关检查） 
                payPrizeAll();
                break;  
            default :
                clsSharedHelper.WriteErrorInfo("接口不存在！ctrl=" + ctrl);
                break;
        } 
    }

    /* 
        * 【必须】传入的参数有：
        * usertoken 
        * 【允许】传入的参数有：
        * 无
     *  
     * 【测试连接】http://tm.lilanz.com/qywx/project/StoreSaler/wxGetPrizeCore.ashx?ctrl=getPrizeList&usertoken=37352518232719562f1d21252d020243027f061d061a2738012b1b27
     * 
        * 
        * 【错误时】返回的报文格式为：
        * Error:错误说明
        * 【正确时】返回的报文的格式 如下：　
    {"wxId":"13358",
        "wxHeadimgurl":"http://wx.qlogo.cn/mmopen/FrdAUicrPIibeOkp5RKMdIYmQNLXo2tnZyjWmqAokaD3VH9kkWNgF6nibQ2OqjDYs7fHCMKZbeDSibOOgictianRnq9rsAzxSfpU2C/64",
        "list":[{"GameToken":"efbd70f6-07de-4943-be9d-afe135fce3bb","GameName":"两蛋一新","PrizeName":"利郎精美领带","CreateTime":"2016-12-22 15:17:34","IsGet":"False","GetTime":"","Operator":" ","ValidTime":"2017-1-18 17:00:00"},{"GameToken":"1f0e63fa-4dc1-408c-b055-828849badb1e","GameName":"扫描报纸送礼品","PrizeName":"利郎精梳棉男袜","CreateTime":"2016-12-4 10:21:46","IsGet":"False","GetTime":"","Operator":" ","ValidTime":"2017-1-4 23:59:00"}],
        "wxNick":"薛灵敏",
        "wxOpenid":"oyLvDjp8wQHKJOk-Z3osaWNVYgrI"}
    */
    private void getPrizeList()
    {
        string strInfo = "";
        string strSQL = "";

        HttpContext hc = HttpContext.Current;
        if (hc == null)
        {
            clsSharedHelper.WriteErrorInfo("访问无效！");
            return;
        }

        string usertoken = hc.Request.Params["usertoken"];
        string wxOpenid = clsNetExecute.DecryptHex(usertoken);

        if (usertoken == null || Convert.ToString(usertoken) == "")
        {
            clsSharedHelper.WriteErrorInfo("参数无效！usertoken");
            return;
        }

        string wxId;
        string wxNick;
        string wxHeadimgurl;
        
        using (LiLanzDALForXLM zdal = new LiLanzDALForXLM(OAConnStr))
        {
            using (LiLanzDALForXLM dal = new LiLanzDALForXLM(WXConnStr))
            {
                strSQL = @"SELECT TOP 1 id,wxNick,wxHeadimgurl FROM wx_t_vipBinging WHERE wxOpenid=@wxOpenid";

                List<SqlParameter> lstParams = new List<SqlParameter>();
                lstParams.Add(new SqlParameter("@wxOpenid", wxOpenid));

                DataTable dt = null;
                strInfo = zdal.ExecuteQuerySecurity(strSQL, lstParams, out dt);

                if (strInfo != "")
                {
                    WriteLog(string.Concat("加载顾客信息失败！错误：", strInfo));
                    clsSharedHelper.WriteErrorInfo("顾客信息加载失败！" + strInfo);
                    return;
                }
                else if (dt.Rows.Count == 0)
                { 
                    clsSharedHelper.WriteErrorInfo("顾客信息不存在！");
                    return; 
                }

                wxId = Convert.ToString(dt.Rows[0]["id"]);
                wxNick = Convert.ToString(dt.Rows[0]["wxNick"]);
                wxHeadimgurl = Convert.ToString(dt.Rows[0]["wxHeadimgurl"]);
                
                //处理不合法的wxNick
                wxNick = wxNick.Replace("\"", "");
                wxNick = wxNick.Replace("\r", "");
                wxNick = wxNick.Replace("\n", "");
                
                //返回小图
                wxHeadimgurl = clsWXHelper.GetMiniFace(wxHeadimgurl);

                clsSharedHelper.DisponseDataTable(ref dt);  //回收资源 
                
                //读取奖品记录
                strSQL = @"SELECT TOP 30 A.GameToken,B.GameName,P.PrizeName,A.CreateTime,A.IsGet,A.GetTime,A.Operator,A.ValidTime
	                            FROM wx_t_GetPrizeRecords A
	                            INNER JOIN wx_t_GameType B ON A.GameID = B.ID
	                            INNER JOIN wx_t_GamePrize P ON A.PrizeID = P.ID
                            WHERE A.wxID = @wxid AND A.IsActive = 1
                            ORDER BY A.ID DESC";

                lstParams.Clear();
                lstParams.Add(new SqlParameter("@wxid", wxId)); 
                strInfo = dal.ExecuteQuerySecurity(strSQL, lstParams, out dt);

                if (strInfo != "")
                {
                    WriteLog(string.Concat("加载奖品信息失败！错误：", strInfo));
                    clsSharedHelper.WriteErrorInfo("奖品信息加载失败！" + strInfo);
                    return;
                }
                else if (dt.Rows.Count == 0)
                {
                    clsSharedHelper.WriteErrorInfo(string.Concat("顾客[", wxNick ,"]没有任何中奖记录！"));
                    return;
                }
                                                               
                string jsonInfo = dal.DataTableToJson(dt);

                string strReturn;
                using (clsJsonHelper jh = clsJsonHelper.CreateJsonHelper(jsonInfo))
                {
                    jh.AddJsonVar("wxId", wxId);
                    jh.AddJsonVar("wxOpenid", wxOpenid);
                    jh.AddJsonVar("wxNick", wxNick);
                    jh.AddJsonVar("wxHeadimgurl", wxHeadimgurl);

                    strReturn = jh.jSon;
                } 

               clsSharedHelper.DisponseDataTable(ref dt);  //回收资源 
                
                clsSharedHelper.WriteInfo(strReturn);
            }
        }
    }


    /* 
        * 【必须】传入的参数有：
        * wxId 、 GameToken
        * 【允许】传入的参数有：
        * 
     *  
     * 【测试连接】http://tm.lilanz.com/qywx/project/StoreSaler/wxGetPrizeCore.ashx?ctrl=payPrizeOne&wxId=13358&GameToken=efbd70f6-07de-4943-be9d-afe135fce3bb
     * (注意测试前请先在执行企业号鉴权 或 解除 SetDebugMode() 关于Session的赋值代码注释)
     * 
        * 
        * 【错误时】返回的报文格式为：
        * Error:错误说明
        * 【正确时】返回的报文的格式如下：　
        Successed
    */
    private void payPrizeOne()
    {
        string strInfo = "";
        string strSQL = "";
                
        HttpContext hc = HttpContext.Current;        
        if (hc == null)
        {
            clsSharedHelper.WriteErrorInfo("访问无效！");
            return;
        }

        string Operator = Convert.ToString(hc.Session["qy_cname"]);
        if (string.IsNullOrEmpty(Operator))
        {
            clsSharedHelper.WriteErrorInfo("执行奖品发放功能，必须先鉴权！");
            return;            
        }
         
        string wxId = hc.Request.Params["wxId"]; 
        string GameToken = hc.Request.Params["GameToken"];

        if (string.IsNullOrEmpty(wxId))
        {
            clsSharedHelper.WriteErrorInfo("参数无效！wxId");
            return;
        } 
        if (string.IsNullOrEmpty(GameToken))
        {
            clsSharedHelper.WriteErrorInfo("参数无效！GameToken");
            return;
        } 
         
        using (LiLanzDALForXLM dal = new LiLanzDALForXLM(WXConnStr))
        {
            strSQL = @"SELECT TOP 1 A.ID,A.IsGet,A.GetTime,A.Operator,A.IsActive 
	                    FROM wx_t_GetPrizeRecords A
                    WHERE A.wxId = @wxid AND A.GameToken = @GameToken";

            List<SqlParameter> lstParams = new List<SqlParameter>();
            lstParams.Add(new SqlParameter("@wxid", wxId));
            lstParams.Add(new SqlParameter("@GameToken", GameToken));

            DataTable dt = null;
            strInfo = dal.ExecuteQuerySecurity(strSQL, lstParams, out dt);

            if (strInfo != "")
            {
                WriteLog(string.Concat("验证中奖信息失败！错误：", strInfo));
                clsSharedHelper.WriteErrorInfo("验证中奖信息失败！" + strInfo);
                return;
            }
            else if (dt.Rows.Count == 0)
            { 
                clsSharedHelper.WriteErrorInfo("中奖信息不存在！");
                return; 
            }

            int GetPrizeRecordsID;
            //判断有效性            
            if (Convert.ToBoolean(dt.Rows[0]["IsActive"]) == false)
            {
                clsSharedHelper.WriteErrorInfo("该奖品暂时无法领取！");
                return;
            }
            else if (Convert.ToBoolean(dt.Rows[0]["IsGet"]) == true)
            {
                clsSharedHelper.WriteErrorInfo(string.Concat("该奖品已被[" , dt.Rows[0]["Operator"] , "]发放！"));
                return;
            }

            GetPrizeRecordsID = Convert.ToInt32(dt.Rows[0]["ID"]);
            clsSharedHelper.DisponseDataTable(ref dt);  //回收资源 
            
            //有效性检查完毕，开始执行更新
                
            //读取奖品记录
            strSQL = @"UPDATE wx_t_GetPrizeRecords SET IsGet = 1,GetTime = GetDate(),Operator = @Operator	                        
                        WHERE ID = @GetPrizeRecordsID AND IsGet = 0";

            lstParams.Clear();
            lstParams.Add(new SqlParameter("@GetPrizeRecordsID", GetPrizeRecordsID));
            lstParams.Add(new SqlParameter("@Operator", Operator)); 
            strInfo = dal.ExecuteNonQuerySecurity(strSQL, lstParams);

            if (strInfo != "")
            {
                WriteLog(string.Concat("发放奖品失败！错误：", strInfo));
                clsSharedHelper.WriteErrorInfo("发放奖品失败！" + strInfo);
                return;
            } 
                
            clsSharedHelper.WriteSuccessedInfo("");
        } 
    }


    /* 
        * 【必须】传入的参数有：
        * wxId 、wxOpenid
        * 【允许】传入的参数有：
        * 
     *  
     * 【测试连接】http://tm.lilanz.com/qywx/project/StoreSaler/wxGetPrizeCore.ashx?ctrl=payPrizeAll&wxId=13358&wxOpenid=oyLvDjp8wQHKJOk-Z3osaWNVYgrI
     * (注意测试前请先在执行企业号鉴权 或 解除 SetDebugMode() 关于Session的赋值代码注释)
     * 
        * 
        * 【错误时】返回的报文格式为：
        * Error:错误说明
        * 【正确时】返回的报文的格式如下：　
        Successed
    */
    private void payPrizeAll()
    {
        string strInfo = "";
        string strSQL = "";

        HttpContext hc = HttpContext.Current;
        if (hc == null)
        {
            clsSharedHelper.WriteErrorInfo("访问无效！");
            return;
        }

        string Operator = Convert.ToString(hc.Session["qy_cname"]);
        if (string.IsNullOrEmpty(Operator))
        {
            clsSharedHelper.WriteErrorInfo("执行奖品发放功能，必须先鉴权！");
            return;
        }

        string wxId = hc.Request.Params["wxId"];
        string wxOpenid = hc.Request.Params["wxOpenid"];

        if (string.IsNullOrEmpty(wxId))
        {
            clsSharedHelper.WriteErrorInfo("参数无效！wxId");
            return;
        }
        if (string.IsNullOrEmpty(wxOpenid))
        {
            clsSharedHelper.WriteErrorInfo("参数无效！wxOpenid");
            return;
        }

        using (LiLanzDALForXLM zdal = new LiLanzDALForXLM(OAConnStr))
        {
            using (LiLanzDALForXLM dal = new LiLanzDALForXLM(WXConnStr))
            {
                strSQL = @"SELECT TOP 1 wxOpenid FROM wx_t_vipBinging WHERE ID = @wxid";

                List<SqlParameter> lstParams = new List<SqlParameter>();
                lstParams.Add(new SqlParameter("@wxid", wxId)); 

                object scal = null;
                strInfo = zdal.ExecuteQueryFastSecurity(strSQL, lstParams, out scal);

                if (strInfo != "")
                {
                    WriteLog(string.Concat("验证用户信息失败！错误：", strInfo));
                    clsSharedHelper.WriteErrorInfo("验证用户信息失败！" + strInfo);
                    return;
                }
                else if (scal == null)
                {
                    clsSharedHelper.WriteErrorInfo("用户信息不存在！");
                    return;
                }
                else if (Convert.ToString(scal) != wxOpenid)
                {
                    clsSharedHelper.WriteErrorInfo("用户信息不合法！");
                    return;
                }                    
                //有效性检查完毕，开始执行更新

                //读取奖品记录
                strSQL = @"UPDATE wx_t_GetPrizeRecords SET IsGet = 1,GetTime = GetDate(),Operator = @Operator	                        
                        WHERE wxID = @wxId AND IsGet = 0 AND IsActive = 1";

                lstParams.Clear();
                lstParams.Add(new SqlParameter("@wxId", wxId));
                lstParams.Add(new SqlParameter("@Operator", Operator)); 
                strInfo = dal.ExecuteNonQuerySecurity(strSQL, lstParams);

                if (strInfo != "")
                {
                    WriteLog(string.Concat("批量发放奖品失败！错误：", strInfo));
                    clsSharedHelper.WriteErrorInfo("批量发放奖品失败！" + strInfo);
                    return;
                }

                clsSharedHelper.WriteSuccessedInfo("");
            }
        }
    }

    public void WriteLog(string strInfo)
    {
        if (strInfo.Contains("错误")) clsLocalLoger.WriteError(string.Concat("[引流活动]", strInfo));
        else clsLocalLoger.WriteInfo(string.Concat("[引流活动]", strInfo)); 
    }

     

    private void SetDebugMode()
    {
        OAConnStr = "server=192.168.35.10;uid=ABEASD14AD;pwd=+AuDkDew;database=tlsoft";
        
        //解除下行注释，可以用于测试 奖品发放方法
        //HttpContext.Current.Session["qy_cname"] = "测试用户";        
    }
    
    public bool IsReusable {
        get {
            return false;
        }
    }

}