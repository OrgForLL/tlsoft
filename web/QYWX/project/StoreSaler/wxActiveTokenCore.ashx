<%@ WebHandler Language="C#" Class="wxActiveTokenCore" %>

using System;
using System.Web;
using nrWebClass;
using System.Data;
using System.Data.SqlClient;
using System.Collections.Generic;
using System.Text;

public class wxActiveTokenCore : IHttpHandler
{

    private string WXConnStr;// = clsConfig.GetConfigValue("WXConnStr");
    private bool IsTestMode = false;
    public void ProcessRequest (HttpContext context) {
        context.Response.ContentType = "text/plain";

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
            case "LoadTokenInfo"://加载活动礼券信息 ok
                LoadTokenInfo();
                break;
            case "SaveTokenInfo"://保存活动礼券信息 ok  （注意编码转换问题）
                SaveTokenInfo();
                break;
            case "LoadPrizeInfo"://加载活动礼品信息 ok
                LoadPrizeInfo();
                break;
            case "SavePrizeInfo"://保存活动礼品信息 ok  （注意编码转换问题）
                SavePrizeInfo();
                break;
            case "SetTokenStatus"://设置活动的可用状态 ok
                SetTokenStatus();
                break;
            case "SetPrizeStatus"://设置礼品的可用状态 ok
                SetPrizeStatus();
                break; 
            case "GetActiveToken":     //客人：扫码获取活动礼券 ok
                GetActiveToken();
                break;
            case "BuyPrizeReady"://客人：扫码打开礼品页面加载之初执行此方法，返回兑换礼品信息（此方法会先进行相关检查） ok
                BuyPrizeReady();
                break;
            case "BuyPrizePay":  //客人：确认 兑换礼品。（此方法执行时会先进行相关检查） ok
                BuyPrizePay();
                break;
            case "GetPayedInfo":    //客人：顾客兑换礼品的支付记录 ok
                GetPayedInfo();
                break;  
            default :
                clsSharedHelper.WriteErrorInfo("接口不存在！ctrl=" + ctrl);
                break;
        } 
    }

    /* 
        * 【必须】传入的参数有：
        * mdid 
        * 【允许】传入的参数有：
        * id 、 IsActive　
     *  
     * 【测试连接】http://tm.lilanz.com/qywx/project/StoreSaler/wxActiveTokenCore.ashx?ctrl=LoadTokenInfo&mdid=1900
     * 
        * 
        * 【错误时】返回的报文格式为：
        * Error:错误说明
        * 【正确时】返回的报文的格式 如下：　
    {
        "list": [
            {
                "ID": "125",
                "ActiveName": "圣诞活动",
                "TokenName": "圣诞节礼券",
                "MaxReceiveCount": "2000",
                "GetPayPoint": "1",
                "ValidTimeBegin": "2016-12-01",
                "ValidTimeEnd": "2016-12-31",
                "ValidDayCount": "1",
                "Remark": "扫码可免费获赠蛋糕 或 爆米花之一",
                "GetTokenCount": "123",
                "CreateTime": "2016-12-08",
                "CreateCustomersID": "587",
                "CreateName": "薛灵敏",
                "IsActive": "1"
            },
            {
                "ID": 124,
                "ActiveName": "圣诞活动",
                "TokenName": "圣诞节礼券0",
                "MaxReceiveCount": "2000",
                "GetPayPoint": "1",
                "ValidTimeBegin": "2016-12-01",
                "ValidTimeEnd": "2016-12-31",
                "ValidDayCount": "1",
                "Remark": "备注说明",
                "GetTokenCount": "12",
                "CreateTime": "2016-12-08",
                "CreateCustomersID": "587",
                "CreateName": "薛灵敏",
                "IsActive": "1"
            }
        ]
    }
    */
    private void LoadTokenInfo()
    {
        string strInfo = "";
        string strSQL = ""; 
        
        HttpContext hc = HttpContext.Current;
        if (hc == null) {
            clsSharedHelper.WriteErrorInfo("访问无效！");
            return;
        }

        string mdid = hc.Request.Params["mdid"];
        string id = hc.Request.Params["id"];
        string IsActive = hc.Request.Params["IsActive"];
        
        if (mdid == null || Convert.ToString(mdid) == "")
        {
            clsSharedHelper.WriteErrorInfo("参数无效！mdid");
            return;
        }
                
        using (LiLanzDALForXLM dal = new LiLanzDALForXLM(WXConnStr))
        {
            strSQL = @"SELECT TOP 10 ID,ActiveName,TokenName,MaxReceiveCount,GetPayPoint,ValidTimeBegin,ValidTimeEnd,ValidDayCount,
                      Remark,GetTokenCount,CreateTime,CreateCustomersID,CreateName,CONVERT(INT,IsActive) 'IsActive',
                      convert(varchar(10),ValidTimeBegin,120) starttime,convert(varchar(10),ValidTimeEnd,120) endtime,TicketColor FROM wx_t_ActiveToken WHERE mdid=@mdid ";

            List<SqlParameter> lstParams = new List<SqlParameter>();
            lstParams.Add(new SqlParameter("@mdid", mdid));

            if (id != null && Convert.ToString(id) != "")
            {
                strSQL = string.Concat(strSQL, " AND ID = @id ");
                lstParams.Add(new SqlParameter("@id", id));
            }
            if (IsActive != null && Convert.ToString(IsActive) != "")
            {
                strSQL = string.Concat(strSQL, " AND IsActive = @IsActive ");
                lstParams.Add(new SqlParameter("@IsActive", IsActive));
            }
            strSQL = string.Concat(strSQL, " ORDER BY ID DESC");
            
            DataTable dt = null;
            strInfo = dal.ExecuteQuerySecurity(strSQL, lstParams, out dt);

            if (strInfo != "")
            {
                WriteLog(string.Concat("加载礼券数据失败！错误：", strInfo));
                clsSharedHelper.WriteErrorInfo("加载失败！" + strInfo);
                return;
            } 
            
            string strBase = @"{{
                    ""ID"": ""{0}"",
                    ""ActiveName"": ""{1}"",
                    ""TokenName"": ""{2}"",
                    ""MaxReceiveCount"": ""{3}"",
                    ""GetPayPoint"": ""{4}"",
                    ""ValidTimeBegin"": ""{5}"",
                    ""ValidTimeEnd"": ""{6}"",
                    ""ValidDayCount"": ""{7}"",
                    ""Remark"": ""{8}"",
                    ""GetTokenCount"": ""{9}"",
                    ""CreateTime"": ""{10}"",
                    ""CreateCustomersID"": ""{11}"",
                    ""CreateName"": ""{12}"",                    
                    ""IsActive"": ""{13}"",
                    ""starttime"":""{14}"",
                    ""endtime"":""{15}"",
                    ""TicketColor"":""{16}""
                }}";
            StringBuilder sbJson = CreateDtJson(ref dt, strBase);
            
            DisposeDataTable(ref dt);  //回收资源 

            string strReturn = sbJson.ToString();
            sbJson.Length = 0;

            clsSharedHelper.WriteInfo(strReturn);
        } 
    }


    /* 
     * 【正确时】返回的报文格式为：
     * Successed|125
     * 【错误时】返回的报文格式为：
     * Error:错误说明
     *
     * 
     * 【测试连接】http://tm.lilanz.com/qywx/project/StoreSaler/wxActiveTokenCore.ashx?ctrl=SaveTokenInfo&info=由CheckTestMode获取
     * 
     * 注意：如果是新增动作，传入报文的ID为0
     * 
     * 【必须】传入的变量info 格式如下：
        {
            "ID": "125",
            "tzid": "1900",
            "mdid": "1900",
            "ActiveName": "圣诞活动",
            "TokenName": "圣诞礼券",
            "MaxReceiveCount": "2000",
            "GetPayPoint": "1",
            "ValidTimeBegin": "2016-12-01",
            "ValidTimeEnd": "2016-12-31",
            "ValidDayCount": "1",
            "Remark": "扫码可免费获赠蛋糕 或 爆米花之一",
            "CreateCustomersID": "587",
            "CreateName": "薛灵敏"
        }
    */
    private void SaveTokenInfo()
    { 
        string strInfo = "";
        string strSQL = "";

        HttpContext hc = HttpContext.Current;
        if (hc == null)
        {
            clsSharedHelper.WriteErrorInfo("访问无效！");
            return;
        }

        string info = hc.Request.Params["info"];
        //CheckTestMode(ref info, IsTestMode, 1);

        if (info == null || Convert.ToString(info) == "")
        {
            clsSharedHelper.WriteErrorInfo("参数无效！info");
            return;
        }
        
        using (clsJsonHelper jh = clsJsonHelper.CreateJsonHelper(info))
        {
            DateTime ValidTimeBegin = Convert.ToDateTime(jh.GetJsonValue("ValidTimeBegin"));
            DateTime ValidTimeEnd = Convert.ToDateTime(jh.GetJsonValue("ValidTimeEnd"));

            if (ValidTimeEnd.Subtract(ValidTimeBegin).TotalDays < 0)
            {
                clsSharedHelper.WriteErrorInfo("有效期截止时间不允许早于开始时间！"); 
                return;                
            }
                        
            
            using (LiLanzDALForXLM dal = new LiLanzDALForXLM(WXConnStr))
            {
                List<SqlParameter> lstParams = new List<SqlParameter>();
                if (jh.GetJsonValue("ID") == "" || jh.GetJsonValue("ID") == "0")
                {
                    strSQL = @" INSERT INTO wx_t_ActiveToken (tzid,mdid,ActiveName,TokenName,MaxReceiveCount,GetPayPoint,ValidTimeBegin,ValidTimeEnd,ValidDayCount,
                        Remark,CreateTime,CreateCustomersID,CreateName,IsActive,TicketColor) VALUES (@tzid,@mdid,@ActiveName,@TokenName,@MaxReceiveCount,@GetPayPoint,@ValidTimeBegin,
                        @ValidTimeEnd,@ValidDayCount,@Remark,GetDate(),@CreateCustomersID,@CreateName,@IsActive,@TicketColor)
                
                        SELECT @@IDENTITY
                    ";
                    lstParams.Add(new SqlParameter("@tzid", jh.GetJsonValue("tzid")));
                    lstParams.Add(new SqlParameter("@mdid", jh.GetJsonValue("mdid")));
                }
                else
                {
                    strSQL = @" UPDATE wx_t_ActiveToken SET ActiveName=@ActiveName,TokenName=@TokenName,MaxReceiveCount=@MaxReceiveCount,GetPayPoint=@GetPayPoint,
                                ValidTimeBegin=@ValidTimeBegin,ValidTimeEnd=@ValidTimeEnd,ValidDayCount=@ValidDayCount,Remark=@Remark,TicketColor=@TicketColor,
                                CreateTime=GetDate(),CreateCustomersID=@CreateCustomersID,CreateName=@CreateName,IsActive=@IsActive WHERE ID=@ID
                
                                SELECT @ID
                            ";
                    lstParams.Add(new SqlParameter("@ID", jh.GetJsonValue("ID")));       
                }

                lstParams.Add(new SqlParameter("@ActiveName", jh.GetJsonValue("ActiveName")));
                lstParams.Add(new SqlParameter("@TokenName", jh.GetJsonValue("TokenName")));
                lstParams.Add(new SqlParameter("@MaxReceiveCount", jh.GetJsonValue("MaxReceiveCount")));
                lstParams.Add(new SqlParameter("@GetPayPoint", jh.GetJsonValue("GetPayPoint")));
                lstParams.Add(new SqlParameter("@ValidTimeBegin", jh.GetJsonValue("ValidTimeBegin")));
                lstParams.Add(new SqlParameter("@ValidTimeEnd", jh.GetJsonValue("ValidTimeEnd")));
                lstParams.Add(new SqlParameter("@ValidDayCount", jh.GetJsonValue("ValidDayCount")));
                lstParams.Add(new SqlParameter("@Remark", jh.GetJsonValue("Remark")));
                lstParams.Add(new SqlParameter("@CreateCustomersID", jh.GetJsonValue("CreateCustomersID")));
                lstParams.Add(new SqlParameter("@CreateName", jh.GetJsonValue("CreateName")));
                lstParams.Add(new SqlParameter("@IsActive", jh.GetJsonValue("IsActive")));
                lstParams.Add(new SqlParameter("@TicketColor", jh.GetJsonValue("TicketColor"))); 
                
                jh.Dispose();
                object objID = 0;
                strInfo = dal.ExecuteQueryFastSecurity(strSQL, lstParams, out objID);

                if (strInfo != "")
                {
                    WriteLog(string.Concat("保存礼券数据失败！错误：", strInfo));
                    clsSharedHelper.WriteErrorInfo("保存失败！");
                    return;
                }

                clsSharedHelper.WriteSuccessedInfo(string.Concat("|", objID));
            }
        }         
    }


    /* 
         * 【必须】传入的参数有：
         * 　ActiveTokenID
         *  
     * 
     * 【测试连接】http://tm.lilanz.com/qywx/project/StoreSaler/wxActiveTokenCore.ashx?ctrl=LoadPrizeInfo&ActiveTokenID=1
     * 
         * 【错误时】返回的报文格式为：
         * Error:错误说明
         * 【正确时】返回的报文的格式 如下：　
        {
            "list": [
                {
                    "ID": "2048",
                    "PrizeName": "圣诞蛋糕",
                    "Remark": "说明文字",
                    "MaxBuyCount": "1",
                    "PayPoint": "1",
                    "IsActive": "1",
                    "CreateTime": "2016-12-08",
                    "CreateCustomersID": "587",
                    "CreateName": "薛灵敏",
                    "BuyCount": "21"
                },
                {
                    "ID": "2049",
                    "PrizeName": "爆米花",
                    "Remark": "说明文字",
                    "MaxBuyCount": "1",
                    "PayPoint": "1",
                    "IsActive": "1",
                    "CreateTime": "2016-12-08",
                    "CreateCustomersID": "587",
                    "CreateName": "薛灵敏",
                    "BuyCount": "26"
                }
            ]
        }
        */
    private void LoadPrizeInfo()
    {
        string strInfo = "";
        string strSQL = "";

        HttpContext hc = HttpContext.Current;
        if (hc == null)
        {
            clsSharedHelper.WriteErrorInfo("访问无效！");
            return;
        }

        string ActiveTokenID = hc.Request.Params["ActiveTokenID"];
        if (ActiveTokenID == null || Convert.ToString(ActiveTokenID) == "")
        {
            clsSharedHelper.WriteErrorInfo("参数无效！ActiveTokenID");
            return;
        }

        using (LiLanzDALForXLM dal = new LiLanzDALForXLM(WXConnStr))
        {
            strSQL = @"SELECT ID,PrizeName,Remark,MaxBuyCount,PayPoint,CONVERT(INT,IsActive) 'IsActive',CreateTime,CreateCustomersID,
                      CreateName,BuyCount,OneBuyMaxCount FROM wx_t_ActiveTokenPrize WHERE ActiveTokenID=@ActiveTokenID ";

            List<SqlParameter> lstParams = new List<SqlParameter>();
            lstParams.Add(new SqlParameter("@ActiveTokenID", ActiveTokenID));
             
            strSQL = string.Concat(strSQL, " ORDER BY ID DESC");

            DataTable dt = null;
            strInfo = dal.ExecuteQuerySecurity(strSQL, lstParams, out dt);

            if (strInfo != "")
            {
                WriteLog(string.Concat("加载礼品数据失败！错误：", strInfo));
                clsSharedHelper.WriteErrorInfo("加载失败！");
                return;
            }

            string strBase = @"{{
                    ""ID"": ""{0}"",
                    ""PrizeName"": ""{1}"",
                    ""Remark"": ""{2}"",
                    ""MaxBuyCount"": ""{3}"",
                    ""PayPoint"": ""{4}"",
                    ""IsActive"": ""{5}"",
                    ""CreateTime"": ""{6}"",
                    ""CreateCustomersID"": ""{7}"",
                    ""CreateName"": ""{8}"",
                    ""BuyCount"": ""{9}"",
                    ""OneBuyMaxCount"":""{10}""
                }}";
            StringBuilder sbJson = CreateDtJson(ref dt, strBase);
            
            DisposeDataTable(ref dt);  //回收资源 

            string strReturn = sbJson.ToString();
            sbJson.Length = 0;

            clsSharedHelper.WriteInfo(strReturn);
        } 
    }

    /* 
         * 【正确时】返回的报文格式为：
         * Successed|2049
         * 【错误时】返回的报文格式为：
         * Error:错误说明
         * 
         * 注意：如果是新增动作，传入报文的ID为0
     * 
     * 【测试连接】http://tm.lilanz.com/qywx/project/StoreSaler/wxActiveTokenCore.ashx?ctrl=SavePrizeInfo&info=由CheckTestMode赋值
     * 
         * 【必须】的报文的格式 如下：　 
        {
            "ID": "2048",
            "ActiveTokenID": "125",
            "PrizeName": "圣诞蛋糕",
            "Remark": "说明文字",
            "MaxBuyCount": "1",
            "PayPoint": "1",
            "CreateCustomersID": "587",
            "CreateName": "薛灵敏"
        }
        */
    private void SavePrizeInfo()
    {
        string strInfo = "";
        string strSQL = "";

        HttpContext hc = HttpContext.Current;
        if (hc == null)
        {
            clsSharedHelper.WriteErrorInfo("访问无效！");
            return;
        }

        string info = hc.Request.Params["info"];
        //CheckTestMode(ref info, IsTestMode, 2);

        if (info == null || Convert.ToString(info) == "")
        {
            clsSharedHelper.WriteErrorInfo("参数无效！info");
            return;
        }

        using (clsJsonHelper jh = clsJsonHelper.CreateJsonHelper(info))
        {
            using (LiLanzDALForXLM dal = new LiLanzDALForXLM(WXConnStr))
            {
                List<SqlParameter> lstParams = new List<SqlParameter>();
                if (jh.GetJsonValue("ID") == "" || jh.GetJsonValue("ID") == "0")
                {
                    strSQL = @" INSERT INTO wx_t_ActiveTokenPrize (ActiveTokenID,PrizeName,Remark,MaxBuyCount,PayPoint,CreateCustomersID,CreateName,CreateTime)
                                VALUES (@ActiveTokenID,@PrizeName,@Remark,@MaxBuyCount,@PayPoint,@CreateCustomersID,@CreateName,GetDate())
                
                        SELECT @@IDENTITY
                    "; 
                }
                else
                {
                    strSQL = @" UPDATE wx_t_ActiveTokenPrize SET ActiveTokenID=@ActiveTokenID,PrizeName=@PrizeName,Remark=@Remark,MaxBuyCount=@MaxBuyCount,
                                PayPoint=@PayPoint,CreateCustomersID=@CreateCustomersID,CreateName=@CreateName,CreateTime=GetDate() WHERE ID=@ID
                
                                SELECT @ID
                            ";
                    lstParams.Add(new SqlParameter("@ID", jh.GetJsonValue("ID")));
                }

                lstParams.Add(new SqlParameter("@ActiveTokenID", jh.GetJsonValue("ActiveTokenID")));
                lstParams.Add(new SqlParameter("@PrizeName", jh.GetJsonValue("PrizeName")));
                lstParams.Add(new SqlParameter("@Remark", jh.GetJsonValue("Remark")));
                lstParams.Add(new SqlParameter("@MaxBuyCount", jh.GetJsonValue("MaxBuyCount")));
                lstParams.Add(new SqlParameter("@PayPoint", jh.GetJsonValue("PayPoint")));
                lstParams.Add(new SqlParameter("@CreateCustomersID", jh.GetJsonValue("CreateCustomersID")));
                lstParams.Add(new SqlParameter("@CreateName", jh.GetJsonValue("CreateName"))); 

                jh.Dispose();
                object objID = 0;
                strInfo = dal.ExecuteQueryFastSecurity(strSQL, lstParams, out objID);

                if (strInfo != "")
                {
                    WriteLog(string.Concat("保存礼品数据失败！错误：", strInfo));
                    clsSharedHelper.WriteErrorInfo("保存失败！");
                    return;
                }

                clsSharedHelper.WriteSuccessedInfo(string.Concat("|", objID));
            }
        }      
    }

    /* 
        * 【必须】传入的参数有：
        * 　ID 、CreateCustomersID 、 CreateName 、 IsActive (值为0 或 1)
        * 　
        * 【正确时】返回的报文格式为：
        * Successed
        * 【错误时】返回的报文格式为：
        * Error:错误说明
        * 【测试连接】http://tm.lilanz.com/qywx/project/StoreSaler/wxActiveTokenCore.ashx?ctrl=SetTokenStatus&ID=1&IsActive=1&CreateCustomersID=587&CreateName=xlm
        */
    private void SetTokenStatus()
    {
        SetStatus("wx_t_ActiveToken", "礼券");
    }
    private void SetStatus(string TableName,string TableText)
    {
        string strInfo = "";
        string strSQL = "";

        HttpContext hc = HttpContext.Current;
        if (hc == null)
        {
            clsSharedHelper.WriteErrorInfo("访问无效！");
            return;
        }

        string ID = hc.Request.Params["ID"];
        string IsActive = hc.Request.Params["IsActive"];
        string CreateCustomersID = hc.Request.Params["CreateCustomersID"];
        string CreateName = hc.Request.Params["CreateName"];

        if (ID == null || Convert.ToString(ID) == "")
        {
            clsSharedHelper.WriteErrorInfo("参数无效！ID");
            return;
        }
        if (IsActive == null || Convert.ToString(IsActive) == "")
        {
            clsSharedHelper.WriteErrorInfo("参数无效！IsActive");
            return;
        }
        if (CreateCustomersID == null || Convert.ToString(CreateCustomersID) == "")
        {
            clsSharedHelper.WriteErrorInfo("参数无效！CreateCustomersID");
            return;
        }
        if (CreateName == null || Convert.ToString(CreateName) == "")
        {
            clsSharedHelper.WriteErrorInfo("参数无效！CreateName");
            return;
        }
         
        using (LiLanzDALForXLM dal = new LiLanzDALForXLM(WXConnStr))
        {
            List<SqlParameter> lstParams = new List<SqlParameter>(); 
            strSQL = string.Concat(@" UPDATE " , TableName , " SET IsActive=@IsActive,CreateCustomersID=@CreateCustomersID,CreateName=@CreateName,CreateTime=GetDate() WHERE ID=@ID  ");

            lstParams.Add(new SqlParameter("@ID", ID));
            lstParams.Add(new SqlParameter("@IsActive", IsActive));
            lstParams.Add(new SqlParameter("@CreateCustomersID", CreateCustomersID));
            lstParams.Add(new SqlParameter("@CreateName", CreateName));  
             
            strInfo = dal.ExecuteNonQuerySecurity(strSQL, lstParams);

            if (strInfo != "")
            {
                WriteLog(string.Concat("设置", TableText, "状态失败！错误：", strInfo));
                clsSharedHelper.WriteErrorInfo(string.Concat("设置" ,TableText, "状态失败！"));
                return;
            }

            clsSharedHelper.WriteSuccessedInfo("");
        }   
    }
    /*  客人扫码获得礼券。
        * 【必须】传入的参数有：
        * 　ActiveTokenID 、wxID
        * 　
        * 【正确时】返回的报文格式为：
        * 领取[@TokenName]成功！|使用说明：@Remark
        * 【错误时】返回的报文格式为：
        * Error:错误说明
        * 【测试连接】http://tm.lilanz.com/qywx/project/StoreSaler/wxActiveTokenCore.ashx?ctrl=GetActiveToken&ActiveTokenID=1&wxID=1448
     */
    private void GetActiveToken()
    {
        string strInfo = "";
        string strSQL = "";

        HttpContext hc = HttpContext.Current;
        if (hc == null)
        {
            clsSharedHelper.WriteErrorInfo("访问无效！");
            return;
        }

        string ActiveTokenID = hc.Request.Params["ActiveTokenID"];
        string wxID = hc.Request.Params["wxID"];

        if (ActiveTokenID == null || Convert.ToString(ActiveTokenID) == "")
        {
            clsSharedHelper.WriteErrorInfo("参数无效！ActiveTokenID");
            return;
        }
        if (wxID == null || Convert.ToString(wxID) == "")
        {
            clsSharedHelper.WriteErrorInfo("参数无效！wxID");
            return;
        } 
        List<SqlParameter> lstParams = new List<SqlParameter>();
        string OAConnStr = clsConfig.GetConfigValue("OAConnStr");
        string wxOpenid, wxName, wxFaceImg;
        using (LiLanzDALForXLM zbdal = new LiLanzDALForXLM(OAConnStr))
        {
            strSQL = "SELECT TOP 1 ID,wxNick,wxHeadimgurl,wxOpenid FROM wx_t_vipBinging WHERE ID=@ID";
            lstParams.Add(new SqlParameter("@ID", wxID));
            DataTable dtRead = null;
            strInfo = zbdal.ExecuteQuerySecurity(strSQL, lstParams, out dtRead);

            if (strInfo != "" || dtRead.Rows.Count == 0)
            { 
                clsSharedHelper.WriteErrorInfo(string.Concat("暂时无法获取您的信息，请稍后重试！"));
                return;                
            }

            wxName = Convert.ToString(dtRead.Rows[0]["wxNick"]);
            wxFaceImg = clsWXHelper.GetMiniFace(Convert.ToString(dtRead.Rows[0]["wxHeadimgurl"])); 
            wxOpenid = Convert.ToString(dtRead.Rows[0]["wxOpenid"]);
             
            DisposeDataTable(ref dtRead);  //回收资源 
        }

        using (LiLanzDALForXLM dal = new LiLanzDALForXLM(WXConnStr))
        {
            strSQL = string.Concat(@"
                DECLARE @AtrID INT,
                        @TokenName NVARCHAR(50),
                        @IsActive BIT,
                        @GetPayPoint INT,
                        @ValidDayCount INT,
                        @MaxReceiveCount INT,
                        @GetTokenCount INT,
                        @Remark NVARCHAR(200),
                        @RetrunInfo NVARCHAR(300),
                        @ValidTimeEnd DATETIME

                SELECT @AtrID = 0,@TokenName = '',@IsActive = 0,@GetPayPoint = 0,@ValidDayCount = 0,@MaxReceiveCount = 0,@Remark = ''

                SELECT TOP 1 @IsActive = IsActive,@TokenName = TokenName,@GetPayPoint = GetPayPoint,@ValidDayCount = ValidDayCount,
                        @MaxReceiveCount = MaxReceiveCount,@GetTokenCount = GetTokenCount,@Remark = Remark FROM wx_t_ActiveToken WHERE ID = @ActiveTokenID

                IF (@IsActive = 0)      SELECT @RetrunInfo = 'Error:活动已停止！不能领取[' + @TokenName + ']！'
                ELSE IF (@MaxReceiveCount > 0 AND @GetTokenCount >= @MaxReceiveCount)      SELECT @RetrunInfo = 'Error:您来晚一步了，[' + @TokenName + ']已经被领光！'
                ELSE
                BEGIN
                    SELECT TOP 1 @AtrID = ID FROM wx_t_ActiveTokenReceive WHERE wxID = @wxID AND ActiveTokenID = @ActiveTokenID
                    IF (@AtrID > 0)  SELECT @RetrunInfo = 'Error:您已经参加了本活动了！不允许重复领取[' + @TokenName + ']！'
                    ELSE
                    BEGIN
                        IF (@ValidDayCount > 0) SELECT @ValidTimeEnd = DATEADD(DAY,@ValidDayCount,GETDATE())
                        ELSE                    SELECT @ValidTimeEnd = DATEADD(YEAR,10,GETDATE())
                        
                        --增加领取数量并插入领取数据
                        UPDATE wx_t_ActiveToken SET GetTokenCount = GetTokenCount + 1 WHERE ID = @ActiveTokenID                                               
                        INSERT INTO wx_t_ActiveTokenReceive (ActiveTokenID,wxID,wxOpenid,wxName,wxFaceImg,AllPayPoint,NowPoint,ValidTimeEnd)
                                        VALUES  (@ActiveTokenID,@wxID,@wxOpenid,@wxName,@wxFaceImg,@GetPayPoint,@GetPayPoint,@ValidTimeEnd)
                        
                        SELECT @AtrID = @@IDENTITY

                        SELECT @RetrunInfo = 'Successed|领取[' + @TokenName + ']成功！|使用说明：' + @Remark
                    END                    
                END

                SELECT @RetrunInfo");

            lstParams.Clear();
            lstParams.Add(new SqlParameter("@ActiveTokenID", ActiveTokenID));
            lstParams.Add(new SqlParameter("@wxID", wxID));
            lstParams.Add(new SqlParameter("@wxName", wxName));
            lstParams.Add(new SqlParameter("@wxOpenid", wxOpenid));
            lstParams.Add(new SqlParameter("@wxFaceImg", wxFaceImg));

            object objRetrunInfo = "";
            strInfo = dal.ExecuteQueryFastSecurity(strSQL, lstParams, out objRetrunInfo);

            if (strInfo != "")
            {
                WriteLog(string.Concat("领取礼券失败！错误：", strInfo));
                clsSharedHelper.WriteErrorInfo(string.Concat("领取礼券失败！"));
                return;
            }

            clsSharedHelper.WriteInfo(Convert.ToString(objRetrunInfo));
        } 
    }

    /* 
     * 【必须】传入的参数有：
     * 　ID 、CreateCustomersID 、 CreateName 、 IsActive (值为0 或 1)
     * 　
     * 【正确时】返回的报文格式为：
     * Successed
     * 【错误时】返回的报文格式为：
     * Error:错误说明
     * 
    * 【测试连接】http://tm.lilanz.com/qywx/project/StoreSaler/wxActiveTokenCore.ashx?ctrl=SetPrizeStatus&ID=1&IsActive=0&CreateCustomersID=587&CreateName=xlm
     */
    private void SetPrizeStatus()
    {
        SetStatus("wx_t_ActiveTokenPrize", "礼品");
    }
    /*
     * 【必须】传入的参数有：
     * 　PrizeID  、 wxID
     * 　
     * 执行时需要依次处理判断：
     * 0 获取礼品的相关信息：ActiveTokenID 、PrizeName 、 OneBuyMaxCount 、 MaxBuyCount 、BuyCount、 PayPoint 、 IsActive；
     *      IsActive判断有效性 ；MaxBuyCount 大于0，则判断 BuyCount 是否已经大于等于 MaxBuyCount；
     * 1 根据ActiveTokenID获取礼券的相关信息： ActiveName 、 ValidTimeBegin 、 ValidTimeEnd 、IsActive，并判断其有效性日期和可用性         
     * 2 根据 ActiveTokenID 和 wxID获取用户的：wxOpenid 、 NowPoint 、 ValidTimeEnd ；
     *     判断是否已经超过时间无效；判断 PayPoint 是否大于 NowPoint； 
     * 3 如果OneBuyMaxCount 大于0，则获取用户关于已购买次数，并判断是否已经大于等于OneBuyMaxCount；
     
     */
    /// <summary>
    /// 顾客扫礼品码后的有效性判断。如果有效则返回空字符串，否则返回说明；
    /// </summary>
    /// <returns></returns>
    private string CheckPrizeReadyError()
    {
        string strReturn = "";
        string strInfo = "";
        string strSQL = "";

        HttpContext hc = HttpContext.Current;
        if (hc == null)
        {
            strReturn = string.Concat(clsSharedHelper.Error_Output, "访问无效"); 
            return strReturn;
        }

        string PrizeID = hc.Request.Params["PrizeID"];
        string wxID = hc.Request.Params["wxID"];

        if (PrizeID == null || Convert.ToString(PrizeID) == "")
        {
            strReturn = string.Concat(clsSharedHelper.Error_Output, "参数无效！PrizeID"); 
            return strReturn;
        }
        if (wxID == null || Convert.ToString(wxID) == "")
        {
            strReturn = string.Concat(clsSharedHelper.Error_Output, "参数无效！wxID"); 
            return strReturn;
        }

        List<SqlParameter> lstParams = new List<SqlParameter>();  
        using (LiLanzDALForXLM dal = new LiLanzDALForXLM(WXConnStr))
        {
            strSQL = string.Concat(@"SELECT TOP 1 ActiveTokenID,PrizeName,OneBuyMaxCount,MaxBuyCount,BuyCount,PayPoint,IsActive FROM wx_t_ActiveTokenPrize WHERE ID = @PrizeID");

            lstParams.Clear();
            lstParams.Add(new SqlParameter("@PrizeID", PrizeID)); 
            DataTable dtPrize = null;
            strInfo = dal.ExecuteQuerySecurity(strSQL, lstParams, out dtPrize);

            if (strInfo != "")
            {
                strReturn = string.Concat(clsSharedHelper.Error_Output, "读取礼品信息失败！");
                WriteLog(string.Concat(strReturn,"错误：", strInfo));
                return strReturn;
            }
            else if (dtPrize.Rows.Count == 0)
            {
                strReturn = string.Concat(clsSharedHelper.Error_Output, "礼品不存在！"); 
                return strReturn;                
            }

            int ActiveTokenID, OneBuyMaxCount, MaxBuyCount, BuyCount, PayPoint, pIsActive;
            string PrizeName;
            DataRow dr = dtPrize.Rows[0];

            PrizeName = Convert.ToString(dr["PrizeName"]);

            ActiveTokenID = Convert.ToInt32(dr["ActiveTokenID"]);
            OneBuyMaxCount = Convert.ToInt32(dr["OneBuyMaxCount"]);
            MaxBuyCount = Convert.ToInt32(dr["MaxBuyCount"]);
            BuyCount = Convert.ToInt32(dr["BuyCount"]);
            PayPoint = Convert.ToInt32(dr["PayPoint"]);
            pIsActive = Convert.ToInt32(dr["IsActive"]);            
            DisposeDataTable(ref dtPrize);  //回收资源 
            
            if (pIsActive == 0)
            {
                strReturn = string.Concat("礼品[" , PrizeName ,"]已停止兑换！");
                return strReturn;
            }else if (MaxBuyCount > 0 && BuyCount >= MaxBuyCount)
            {
                strReturn = string.Concat("礼品[", PrizeName, "]已达到最大兑换数量限制：", MaxBuyCount); 
                return strReturn; 
            }            
            //以上完成礼品 IsActive 以及 最大兑换数量的判断。 

            strSQL = string.Concat(@"SELECT TOP 1 ActiveName,ValidTimeBegin,ValidTimeEnd,DATEDIFF(DAY, ValidTimeBegin,GETDATE()) TIME1
		        ,DATEDIFF(DAY, GETDATE(),ValidTimeEnd) TIME2,IsActive FROM wx_t_ActiveToken WHERE ID = @ActiveTokenID");

            lstParams.Clear();
            lstParams.Add(new SqlParameter("@ActiveTokenID", ActiveTokenID));
            DataTable dtToken = null;
            strInfo = dal.ExecuteQuerySecurity(strSQL, lstParams, out dtToken);

            if (strInfo != "")
            {
                strReturn = string.Concat(clsSharedHelper.Error_Output, "读取礼券信息失败！");
                WriteLog(string.Concat(strReturn, "错误：", strInfo));
                return strReturn;
            }
            else if (dtToken.Rows.Count == 0)
            {
                strReturn = "礼券不存在！";
                return strReturn;
            }

            string ActiveName, ValidTimeBegin, ValidTimeEnd;
            int TIME1, TIME2, tkIsActive;

            dr = dtToken.Rows[0];

            ActiveName = Convert.ToString(dr["ActiveName"]);
            ValidTimeBegin = Convert.ToDateTime(dr["ValidTimeBegin"]).ToString("yyyy-MM-dd");
            ValidTimeEnd = Convert.ToDateTime(dr["ValidTimeEnd"]).ToString("yyyy-MM-dd"); 
            TIME1 = Convert.ToInt32(dr["TIME1"]);
            TIME2 = Convert.ToInt32(dr["TIME2"]);
            tkIsActive = Convert.ToInt32(dr["IsActive"]);
            DisposeDataTable(ref dtToken);  //回收资源 
            
            if (tkIsActive == 0)
            {
                strReturn = string.Concat("[", ActiveName, "]已停止！");
                return strReturn;
            }else if (TIME1 < 0 || TIME2 < 0)
            {
                strReturn = string.Concat("现在不在[", ActiveName, "]的活动时间：", ValidTimeBegin , "～",ValidTimeEnd);
                return strReturn;
            }
            //以上完成礼券 IsActive 以及有效时间的判断。  

            strSQL = string.Concat(@"SELECT TOP 1 wxOpenid,NowPoint,ValidTimeEnd,DATEDIFF(MINUTE, GETDATE(),ValidTimeEnd) TIME2
                            FROM wx_t_ActiveTokenReceive WHERE ActiveTokenID = @ActiveTokenID AND wxID = @wxID");

            lstParams.Clear();
            lstParams.Add(new SqlParameter("@ActiveTokenID", ActiveTokenID));
            lstParams.Add(new SqlParameter("@wxID", wxID));
            DataTable dtATR = null;
            strInfo = dal.ExecuteQuerySecurity(strSQL, lstParams, out dtATR);

            if (strInfo != "")
            {
                strReturn = string.Concat(clsSharedHelper.Error_Output, "读取持有礼券的信息失败！");
                WriteLog(string.Concat(strReturn, "错误：", strInfo));
                return strReturn;
            }
            else if (dtATR.Rows.Count == 0)
            {
                strReturn = string.Concat("您还未领取[", ActiveName,"]的礼券，不能兑换礼品！");
                return strReturn;
            }

            string wxOpenid;
            int NowPoint;

            dr = dtATR.Rows[0];

            wxOpenid = Convert.ToString(dr["wxOpenid"]); 
            ValidTimeEnd = Convert.ToDateTime(dr["ValidTimeEnd"]).ToString("yyyy-MM-dd");
            NowPoint = Convert.ToInt32(dr["NowPoint"]);
            TIME2 = Convert.ToInt32(dr["TIME2"]); 
            DisposeDataTable(ref dtATR);  //回收资源 

            if (NowPoint == 0)
            {
                strReturn = string.Concat("您已经不能再兑换活动礼品了！");
                return strReturn;
            }else if (NowPoint < PayPoint)
            {
                strReturn = string.Concat("兑换[", PrizeName, "]需要[", PayPoint,"]的兑换点！您目前的兑换点只有[", NowPoint, "]");
                return strReturn;
            }
            else if (TIME2 < 0)
            {
                strReturn = string.Concat("礼券已过期！您的礼券的有效期至：", ValidTimeEnd);
                return strReturn;
            }
            //以上完成顾客持有礼券有效时间的判断 和 兑换所需点数的判断。  

            //如果 OneBuyMaxCount 设置为小于1的值，则不需要验证单个礼品是否允许多次兑换，否则需要验证
            if (OneBuyMaxCount < 1)
            {
                return "";
            }
            //获取当前顾客兑换该商品的总次数。进行判断。
            strSQL = string.Concat(@"SELECT COUNT(1) FROM wx_t_ActiveTokenPayed WHERE PrizeID = @PrizeID AND wxID = @wxID");

            lstParams.Clear();
            lstParams.Add(new SqlParameter("@PrizeID", PrizeID));
            lstParams.Add(new SqlParameter("@wxID", wxID));
            object myBuyCount = 0;
            strInfo = dal.ExecuteQueryFastSecurity(strSQL, lstParams, out myBuyCount);

            if (strInfo != "")
            {
                strReturn = string.Concat(clsSharedHelper.Error_Output, "读取礼品兑换次数失败！");
                WriteLog(string.Concat(strReturn, "错误：", strInfo));
                return strReturn;
            }

            if (OneBuyMaxCount <= Convert.ToInt32(myBuyCount))
            {
                strReturn = string.Concat("[", PrizeName, "]最多只允许兑换[", OneBuyMaxCount, "]次！");
                return strReturn;
            }
            else
            {
                return "";
            }
        }   
    }

    /* 
     * 【必须】传入的参数有：
     * 　PrizeID  、 wxID
     * 　
     * 【注意】执行时需要先调用CheckPrizeReadyOK进行有效性判断。
     * 　 
     * 【致命错误时】直接返回的报文格式为：
     * Error:错误说明
     * 【执行正确时】的报文的格式 如下：　   (BuyStatus 表示是否允许兑换；若BuyStatus==0，则BuyErrorRemark表示不允许购买的原因 )
    { 
        "ActiveTokenID": "125",
        "PrizeID": "2048",
        "PrizeName": "圣诞蛋糕",
        "Remark": "说明文字", 
        "PayPoint": "1", 
        "NowPoint": "1", 
        "BuyStatus": "0", 
        "BuyErrorRemark": "圣诞蛋糕 只允许兑换一次，你之前已经兑换过了！"
    }
     */
    private void BuyPrizeReady()
    { 
        int BuyStatus = 0;
        string BuyErrorRemark = CheckPrizeReadyError();

        if (BuyErrorRemark.StartsWith(clsSharedHelper.Error_Output)){   //如果是致命错误，则直接返回
            clsSharedHelper.WriteInfo(BuyErrorRemark);
            return;
        }        
        if (BuyErrorRemark == "")
        {
            BuyStatus = 1;
        }
        
        HttpContext hc = HttpContext.Current;       //上一步的方法调用已经验证了hc和参数有效性了，所以在这里可以直接使用
        string PrizeID = hc.Request.Params["PrizeID"];
        string wxID = hc.Request.Params["wxID"];

        string strInfo;
        string strErr = "";

        string ActiveTokenID = "", PrizeName = "", Remark = "", PayPoint = "";
        int NowPoint = 0;
        
        List<SqlParameter> lstParams = new List<SqlParameter>();
        using (LiLanzDALForXLM dal = new LiLanzDALForXLM(WXConnStr))
        {
            string strSQL = string.Concat(@"SELECT TOP 1 ActiveTokenID,PrizeName,Remark,PayPoint FROM wx_t_ActiveTokenPrize WHERE ID = @PrizeID");

            lstParams.Clear();
            lstParams.Add(new SqlParameter("@PrizeID", PrizeID));
            DataTable dtPrize = null;
            strInfo = dal.ExecuteQuerySecurity(strSQL, lstParams, out dtPrize);
            if (strInfo != "")
            {
                strErr = "读取礼品信息失败...";
                WriteLog(string.Concat(strErr, "错误：", strInfo));
            }
            else
            {

                DataRow dr = dtPrize.Rows[0];
                ActiveTokenID = Convert.ToString(dr["ActiveTokenID"]);
                PrizeName = Convert.ToString(dr["PrizeName"]);
                Remark = Convert.ToString(dr["Remark"]);
                PayPoint = Convert.ToString(dr["PayPoint"]);
                DisposeDataTable(ref dtPrize);
            }

            if (strErr == "")
            {
                strSQL = string.Concat(@"SELECT TOP 1 NowPoint FROM wx_t_ActiveTokenReceive WHERE ActiveTokenID = @ActiveTokenID AND wxID = @wxID");
                lstParams.Clear();
                lstParams.Add(new SqlParameter("@ActiveTokenID", ActiveTokenID));
                lstParams.Add(new SqlParameter("@wxID", wxID));
                object objNowPoint = 0;
                strInfo = dal.ExecuteQueryFastSecurity(strSQL, lstParams, out objNowPoint);
                if (strInfo != "")
                {
                    strErr = "读取您的剩余点数失败...";
                    WriteLog(string.Concat(strErr, "错误：", strInfo));
                }
                if (objNowPoint != null) NowPoint = Convert.ToInt32(objNowPoint);
            }

            if (strErr == "")
            {
                string strBase = @"{{ 
                                ""ActiveTokenID"": ""{0}"",
                                ""PrizeID"": ""{1}"",
                                ""PrizeName"": ""{2}"",
                                ""Remark"": ""{3}"", 
                                ""PayPoint"": ""{4}"", 
                                ""NowPoint"": ""{5}"", 
                                ""BuyStatus"": ""{6}"", 
                                ""BuyErrorRemark"": ""{7}""
                              }}";

                strBase = string.Format(strBase, ActiveTokenID, PrizeID, PrizeName, Remark,PayPoint, NowPoint, BuyStatus, BuyErrorRemark);
                clsSharedHelper.WriteInfo(strBase);
            }
            else
            {
                clsSharedHelper.WriteErrorInfo(strErr);
            } 
        }        
    }

    /* 
     * 【必须】传入的参数有：
     * 　PrizeID  、 wxID
     * 　
     * 【注意】执行时需要先调用CheckPrizeReadyOK进行有效性判断。                 
     *  若上述判断全部通过，则更新当前用户wxID、ActiveTokenID的 NowPoint =  NowPoint - PayPoint；并购买记录数据到 wx_t_ActiveTokenPayed
     * 
     * 【测试连接】http://tm.lilanz.com/qywx/project/StoreSaler/wxActiveTokenCore.ashx?ctrl=BuyPrizePay&PrizeID=1&wxID=1448
     * 
     * 【错误时】返回的报文格式为：
     * Error:错误说明
     * 【正确时】的报文的格式 如下：　(获得此报文之后，UI界面要提示：请将本画面出示给工作人员兑换礼品！) 
     * Successed|领取[圣诞蛋糕]成功！
     */
    private void BuyPrizePay()
    { 
        string BuyErrorRemark = CheckPrizeReadyError();

        if (BuyErrorRemark.StartsWith(clsSharedHelper.Error_Output))
        {   //如果是致命错误，则直接返回
            clsSharedHelper.WriteInfo(BuyErrorRemark);
            return;
        }
        else if (BuyErrorRemark != "")
        {
            clsSharedHelper.WriteErrorInfo(BuyErrorRemark);
            return;            
        }

        HttpContext hc = HttpContext.Current;       //上一步的方法调用已经验证了hc和参数有效性了，所以在这里可以直接使用
        int PrizeID = Convert.ToInt32( hc.Request.Params["PrizeID"]);
        int wxID = Convert.ToInt32(hc.Request.Params["wxID"]);

        string strInfo;
        string strErr = "";

        string PrizeName = "",wxOpenid = "";
        int ActiveTokenID = 0, PayPoint = 0;

        List<SqlParameter> lstParams = new List<SqlParameter>();
        using (LiLanzDALForXLM dal = new LiLanzDALForXLM(WXConnStr))
        {
            string strSQL = string.Concat(@"SELECT TOP 1 ActiveTokenID,PayPoint,PrizeName FROM wx_t_ActiveTokenPrize WHERE ID = @PrizeID");

            lstParams.Clear();
            lstParams.Add(new SqlParameter("@PrizeID", PrizeID));
            DataTable dtPrize = null;
            strInfo = dal.ExecuteQuerySecurity(strSQL, lstParams, out dtPrize);
            if (strInfo != "")
            {
                strErr = "读取礼品信息失败....";
                WriteLog(string.Concat(strErr, "错误：", strInfo));
            }
            else
            {

                DataRow dr = dtPrize.Rows[0];
                ActiveTokenID = Convert.ToInt32(dr["ActiveTokenID"]);
                PayPoint = Convert.ToInt32(dr["PayPoint"]);
                PrizeName = Convert.ToString(dr["PrizeName"]);
                DisposeDataTable(ref dtPrize);
            }

            if (strErr == "")
            {
                strSQL = string.Concat(@"SELECT TOP 1 wxOpenid FROM wx_t_ActiveTokenReceive WHERE ActiveTokenID = @ActiveTokenID AND wxID = @wxID");
                lstParams.Clear();
                lstParams.Add(new SqlParameter("@ActiveTokenID", ActiveTokenID));
                lstParams.Add(new SqlParameter("@wxID", wxID));
                DataTable dtATR = null;
                strInfo = dal.ExecuteQuerySecurity(strSQL, lstParams, out dtATR);
                if (strInfo != "")
                {
                    strErr = "读取您的礼券持有信息失败....";
                    WriteLog(string.Concat(strErr, "错误：", strInfo));
                }
                wxOpenid = Convert.ToString(dtATR.Rows[0]["wxOpenid"]);
                //NowPoint = Convert.ToInt32(dtATR.Rows[0]["NowPoint"]);  //这个无用，删除之
                DisposeDataTable(ref dtATR);
            }

            if (strErr == "")
            {
                //执行兑换：1插入兑换记录；2更新奖品兑换次数；3更新顾客持有的点。
                SqlCommand comm = dal.TransBeginGetCommand();
                try
                {
                    strSQL = string.Format("INSERT INTO wx_t_ActiveTokenPayed (ActiveTokenID,PrizeID,PayPoint,wxID,wxOpenid) VALUES ({0},{1},{2},{3},'{4}')",
                                                                ActiveTokenID, PrizeID, PayPoint, wxID, wxOpenid);
                    comm.CommandText = strSQL; comm.ExecuteNonQuery();
                    strSQL = string.Format("UPDATE wx_t_ActiveTokenPrize SET BuyCount = BuyCount + 1 WHERE ID={0} ", PrizeID);
                    comm.CommandText = strSQL; comm.ExecuteNonQuery();
                    strSQL = string.Format("UPDATE wx_t_ActiveTokenReceive SET NowPoint = NowPoint - {0} WHERE ActiveTokenID = {1} AND wxID={2}", PayPoint, ActiveTokenID, wxID);
                    comm.CommandText = strSQL; comm.ExecuteNonQuery();
                    dal.TransCommit();
                }
                catch (Exception ex)
                {
                    strErr = "兑换失败！";
                    WriteLog(string.Concat("顾客兑换失败！错误：", ex.Message));
                    dal.TransRollback();
                }
                finally
                {
                    dal.TransAndCommandDispose();   //结束事务并释放相关资源
                }                  
            }

            if (strErr != "")
            {
                clsSharedHelper.WriteErrorInfo(strErr);
            }
            else
            {
                clsSharedHelper.WriteSuccessedInfo(string.Concat("|领取[" , PrizeName , "]成功！"));
            }            
        }     
    }


    /* 
     * 【必须】传入的参数有：
     * 　wxID
     * 【可选】传入的参数有：
     *  ActiveTokenID
     * 
     * 【测试链接】http://tm.lilanz.com/QYWX/project/StoreSaler/wxActiveTokenCore.ashx?ctrl=GetPayedInfo&wxID=1448
     * 
     * 【错误时】返回的报文格式为：
     * Error:错误说明
     * 【正确时】的报文的格式 如下：　 
    {
        "list": [
            {
                "ActiveTokenID": "125",
                "PrizeID": "2048",
                "CreateTime": "2016-12-20 17:12:12",
                "ActiveName": "圣诞活动",
                "TokenName": "圣诞礼券",
                "PrizeName": "圣诞蛋糕",
                "PayPoint": "1"
            },
            {
                "ActiveTokenID": "124",
                "PrizeID": "2049",
                "CreateTime": "2016-12-20 17:12:02",
                "ActiveName": "圣诞活动",
                "TokenName": "圣诞礼券",
                "PrizeName": "爆米花",
                "PayPoint": "1"
            }
        ]
    }
     */
    private void GetPayedInfo()
    {
        string strInfo = "";
        string strSQL = "";

        HttpContext hc = HttpContext.Current;
        if (hc == null)
        {
            clsSharedHelper.WriteErrorInfo("访问无效！");
            return;
        }

        string wxID = hc.Request.Params["wxID"];
        string ActiveTokenID = hc.Request.Params["ActiveTokenID"];

        if (wxID == null || Convert.ToString(wxID) == "")
        {
            clsSharedHelper.WriteErrorInfo("参数无效！wxID");
            return;
        }

        using (LiLanzDALForXLM dal = new LiLanzDALForXLM(WXConnStr))
        {
            strSQL = @"SELECT TOP 10 A.ActiveTokenID,A.PrizeID,A.CreateTime,B.ActiveName,B.TokenName,C.PrizeName,A.PayPoint
                         FROM wx_t_ActiveTokenPayed A
                        INNER JOIN wx_t_ActiveToken B ON A.ActiveTokenID = B.ID 
                        INNER JOIN wx_t_ActiveTokenPrize C ON A.PrizeID = C.ID
                         WHERE wxID = @wxID ";

            List<SqlParameter> lstParams = new List<SqlParameter>();
            lstParams.Add(new SqlParameter("@wxID", wxID));

            if (ActiveTokenID != null && Convert.ToString(ActiveTokenID) != "")
            {
                strSQL = string.Concat(strSQL, " AND A.ActiveTokenID = @ActiveTokenID ");
                lstParams.Add(new SqlParameter("@ActiveTokenID", ActiveTokenID));
            }
            strSQL = string.Concat(strSQL, " ORDER BY A.ID DESC");

            DataTable dt = null;
            strInfo = dal.ExecuteQuerySecurity(strSQL, lstParams, out dt);

            if (strInfo != "")
            {
                WriteLog(string.Concat("加载兑换历史记录失败！错误：", strInfo));
                clsSharedHelper.WriteErrorInfo("加载失败！");
                return;
            }

            string strBase = @"{{            
                    ""ActiveTokenID"": ""{0}"",
                    ""PrizeID"": ""{1}"",
                    ""CreateTime"": ""{2}"",
                    ""ActiveName"": ""{3}"",
                    ""TokenName"": ""{4}"",
                    ""PrizeName"": ""{5}"",
                    ""PayPoint"": ""{6}""            
                }}";
            StringBuilder sbJson = CreateDtJson(ref dt, strBase);

            DisposeDataTable(ref dt);  //回收资源 

            string strReturn = sbJson.ToString();
            sbJson.Length = 0;

            clsSharedHelper.WriteInfo(strReturn);
        } 
    }

    public void WriteLog(string strInfo)
    {
        if (strInfo.Contains("错误")) clsLocalLoger.WriteError(string.Concat("[引流活动]", strInfo));
        else clsLocalLoger.WriteInfo(string.Concat("[引流活动]", strInfo)); 
    }


    /// <summary>
    /// 构造JSON报文并返回
    /// </summary>
    /// <param name="dt">表</param>
    /// <param name="strBase">数据行的json报文</param>
    /// <returns></returns>
    private StringBuilder CreateDtJson(ref DataTable dt, string strBase)
    {
        StringBuilder sbJson = new StringBuilder();
        sbJson.Append(@"{
                                ""list"": [");

        //构造列表
        List<object> lstObjs = new List<object>();
        int j = dt.Columns.Count;
        foreach (DataRow dr in dt.Rows)
        {
            lstObjs.Clear();
            for (int i = 0; i < j; i++)
            {
                lstObjs.Add(dr[i]);
            }

            sbJson.AppendFormat(strBase, lstObjs.ToArray());
            sbJson.Append(",");
        }
        if (dt.Rows.Count > 0) sbJson.Remove(sbJson.Length - 1, 1);        

        sbJson.Append(@"              ]
                            }");

        return sbJson;
    }

    private void DisposeDataTable(ref DataTable dt)
    {
        if (dt != null)
        {
            dt.Clear(); dt.Dispose(); dt = null;
        }
    }

    private void CheckTestMode(ref string info, bool IsTestMode, int TestType)
    {
        switch (TestType)
        {
            case 1:
                //info = @"{""ID"":""1"",""tzid"":""1900"",""mdid"":""1900"",""ActiveName"":""圣诞活动"",""TokenName"":""圣诞礼券"",""MaxReceiveCount"":""2000"",""GetPayPoint"":""1"",""ValidTimeBegin"":""2016-12-01"",""ValidTimeEnd"":""2016-12-31"",""ValidDayCount"":""1"",""Remark"":""扫码可免费获赠蛋糕或爆米花之一"",""CreateCustomersID"":""587"",""CreateName"":""薛灵敏""}";
                info = @"{""ID"":"""",""tzid"":""1900"",""mdid"":""1900"",""ActiveName"":""圣诞活动"",""TokenName"":""圣诞礼券"",""MaxReceiveCount"":""2000"",""GetPayPoint"":""1"",""ValidTimeBegin"":""2016-12-01"",""ValidTimeEnd"":""2016-12-31"",""ValidDayCount"":""1"",""Remark"":""扫码可免费获赠蛋糕或爆米花之一"",""CreateCustomersID"":""587"",""CreateName"":""薛灵敏""}";
                break;
            case 2:
                //info = @"{""ID"":""1"",""tzid"":""1900"",""mdid"":""1900"",""ActiveName"":""圣诞活动"",""TokenName"":""圣诞礼券"",""MaxReceiveCount"":""2000"",""GetPayPoint"":""1"",""ValidTimeBegin"":""2016-12-01"",""ValidTimeEnd"":""2016-12-31"",""ValidDayCount"":""1"",""Remark"":""扫码可免费获赠蛋糕或爆米花之一"",""CreateCustomersID"":""587"",""CreateName"":""薛灵敏""}";
                info = @"{""ID"": ""1"",""ActiveTokenID"": ""1"",""PrizeName"": ""蛋糕"",""Remark"": ""说明文字"",""MaxBuyCount"": ""1"",""PayPoint"": ""1"",""CreateCustomersID"": ""587"",""CreateName"": ""薛灵敏""}";
                break;
            default:
                return;
        }
    }
    
    public bool IsReusable {
        get {
            return false;
        }
    }

}