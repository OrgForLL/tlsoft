<%@ Page Language="C#" %>

<%@ Import Namespace="System.Data" %>
<%@ Import Namespace="Newtonsoft.Json" %>
<%@ Import Namespace="System.Collections.Generic" %>
<%@ Import Namespace="nrWebClass" %>
<%@ Import Namespace="System.Web.Caching" %>
<%@ Import Namespace="System.Reflection" %>
<%@ Import Namespace="System.Data.SqlClient" %>
<%@ Import Namespace="System.IO" %>

<script runat="server">
    private const string appID = "wxe46359cef7410a06";	//APPID
    private const string appSecret = "wCwNUgMb4LDbaH0m0XZJV7Hb9hma2FGOX4MDtSqd3SggbUem4tV4QV2M15762qoK";    //appSecret	
    private const string allowip = "192.168.35.197";	//	
    private readonly int[] unlimited = {9, 52 };//无限制餐次
    private const double Seconds = 10 * 60;//缓存cache时间
    private string SchNo = ""; //餐次
    int min;//当前时间（计算当天分钟数）
    string today;
    string account = "";
    int cannel = 0;
    string errInfo = "";
    string cname = "";
    string tzid = "";
    #region 程序入口
    protected void Page_Load(object sender, EventArgs e)
    {
        DateTime TimeNow = DateTime.Now;
        min = TimeNow.Hour * 60 + TimeNow.Minute;
        today = TimeNow.ToString("yyyy-MM-dd");

        Response.ContentEncoding = System.Text.Encoding.UTF8;
        Request.ContentEncoding = System.Text.Encoding.UTF8;

        string action = Convert.ToString(Request.Params["action"]);
        MethodInfo method = this.GetType().GetMethod(action);
        string rt = "";

        if (method == null)
        {
            rt = response(201, "", "未找到对应的action,请核对后再试！action:" + action);
        }
        else
        {
            try
            {
                method.Invoke(this, null);
                return;
            }
            catch (Exception ex)
            {
                rt = response(201, "", "服务器出错：" + ex.ToString());
            }
        }
        clsSharedHelper.WriteInfo(rt);
    }
    #endregion

    #region 刷卡请求
    /// <summary>
    /// 刷卡请求接口
    /// </summary>
    public void card()
    {
        //string ip = HttpContext.Current.Request.UserHostAddress;
        //if (allowip.IndexOf(ip) < 0)
        //{
        //    clsSharedHelper.WriteInfo(response(201, false, "非法访问"));
        //    return;
        //}

        errInfo = "";
        bool flag = false;
        string cardSnr = Convert.ToString(Request.Params["cardno"]), rt = "";
        string devid = Convert.ToString(Request.Params["devid"]);
        clsLocalLoger.Log(string.Format("cardno:{0}刷卡请求开始", cardSnr));

        setTzid(devid, "card");

        cardSnr = cardSnr.PadLeft(10, '0');
        cardSnr = DeCode(cardSnr);

        if (cardSnr.IndexOf("successed") > -1)
        {
            cardSnr = cardSnr.Replace("successed", "");
            if (isVailCardSnr(cardSnr))
            {
                if (userInfo())
                {
                    flag = true;
                    addConsumeRecord();
                }
            }
            errInfo += "cardsnr:" + cardSnr;
            rt = response(0, flag, errInfo);
        }
        else
        {
            rt = response(101, false, "无法识别卡号");
        }
        clsLocalLoger.Log(string.Format("cardsnr:{0}返回结果：{1}", cardSnr, rt));
        clsSharedHelper.WriteInfo(rt);
    }

    /// <summary>
    /// 判断卡内码是否有效
    /// </summary>
    /// <param name="cardSnr"></param>
    private bool isVailCardSnr(string cardSnr)
    {
        bool flag = false;
        string mysql = string.Format("SELECT cast( AccountNo as varchar(20)) FROM dbo.tb_Customer WHERE CardSnr='{0}' and CardStat=0", cardSnr);
        using (IDataReader reader = wechat.DBFactory.CFSFDB().ExecuteReader(mysql))
        {
            if (reader.Read())
            {
                account = reader.GetString(0);
                flag = true;
            }
            else
            {
                errInfo = "无效卡号";
                reader.Dispose();
            }
        }
        return flag;
    }
    /// <summary>
    /// 解密
    /// </summary>
    /// <param name="CardID">USB刷卡的加密码</param>
    /// <returns></returns>
    private string DeCode(string CardID)
    {
        try
        {
            if (CardID.Length != 10)
                return "";
            else
            {
                string Base16 = Convert.ToString(Convert.ToInt64(CardID), 16);
                string subBase16 = Base16.Substring(Base16.Length - 6);
                string cardSnr = Convert.ToString(Convert.ToInt64(subBase16, 16));
                return "successed" + cardSnr;
            }
        }
        catch (Exception ex)
        {
            return ex.Message;
        }
    }
    #endregion

    #region 二维码创建
    /// <summary>
    /// 创建二维码信息
    /// </summary>
    public void QRcode()
    {
        string rt = "";
        account = clsWXHelper.GetAuthorizedKey(5);

        if (string.IsNullOrEmpty(account) || account == "0")
        {
            clsSharedHelper.WriteInfo(JsonConvert.SerializeObject(response(101, "", "信息未关联")));
            return;
        }

        setTzid("", "QRcode");

        if (userInfo())
        {

            //long qrcodeval = GuidToLongID();
            if (HttpRuntime.Cache.Get(account) == null)//内存中无二维码信息
            {
                long guid = GuidToLongID();
                HttpRuntime.Cache.Add(account, guid.ToString(), null, DateTime.Now.AddSeconds(Seconds), TimeSpan.Zero, CacheItemPriority.Default, null);
                HttpRuntime.Cache.Add(guid.ToString(), account, null, DateTime.Now.AddSeconds(Seconds), TimeSpan.Zero, CacheItemPriority.Default, null);
            }
            rt = response(0, HttpRuntime.Cache.Get(account), "");
        }
        else
        {
            rt = response(102, "", errInfo);
        }
        clsSharedHelper.WriteInfo(rt);
    }
    /// <summary>  
    /// 根据GUID获取19位的唯一数字序列  
    /// </summary>  
    /// <returns></returns>  
    public long GuidToLongID()
    {
        byte[] buffer = Guid.NewGuid().ToByteArray();
        return BitConverter.ToInt64(buffer, 0);
    }
    #endregion

    #region 二维码消费

    public void consumeQRCode()
    {
        //接收并读取POST过来的XML文件流
        StreamReader reader = new StreamReader(Request.InputStream);
        String xmlData = reader.ReadToEnd();
        //  clsLocalLoger.Log("【二维码信息】："+xmlData);

        long code;
        string devid;
        try
        {
            code = long.Parse(xmlData);
            devid = Convert.ToString(Request.Params["devid"]);
        }
        catch (Exception e)
        {
            code = 0;
            clsSharedHelper.WriteInfo(response(101, false, e.ToString()));
            return;
        }

        if (HttpRuntime.Cache.Get(code.ToString()) == null)
        {
            clsSharedHelper.WriteInfo(response(102, false, "二维码信息不存在"));
            return;
        }

        devid = getDevid(devid);
        if (string.IsNullOrEmpty(devid))
        {
            clsSharedHelper.WriteInfo(response(103, false, "设备不存在"));
            return;
        }

        account = Convert.ToString(HttpRuntime.Cache.Get(code.ToString()));
        if (!userInfo())
        {
            clsSharedHelper.WriteInfo(response(0, false, errInfo));
            return;
        }
        string rt = clsNetExecute.HttpRequest(string.Format("http://192.168.135.98:12001/open?devid={0}", devid));
        clsLocalLoger.Log(string.Format("【二维码信息】：{0};AccountNo:{1};开门结果：{2}", xmlData, account, rt));

        Dictionary<string, object> drt = JsonConvert.DeserializeObject<Dictionary<string, object>>(rt);
        if (Convert.ToBoolean(drt["Result"]))
        {
            HttpRuntime.Cache.Remove(code.ToString());
            HttpRuntime.Cache.Remove(account);
            addConsumeRecord();
            clsSharedHelper.WriteInfo(response(0, true, ""));
        }
        else
        {
            clsSharedHelper.WriteInfo(response(0, false, ""));
        }
    }
    #endregion

    #region 统一返回格式
    /// <summary>
    /// 返回数据格式
    /// </summary>
    /// <param name="code"></param>
    /// <param name="obj"></param>
    /// <param name="errmsg"></param>
    /// <returns></returns>
    private String response(int code, object obj, String errmsg)
    {
        Dictionary<string, object> rtdic = new Dictionary<string, object>();
        rtdic.Add("errcode", code);
        rtdic.Add("data", obj);
        rtdic.Add("errmsg", errmsg);
        return JsonConvert.SerializeObject(rtdic);
    }
    #endregion

    #region 设置套账信息
    /// <summary>
    /// 根据不同请求方式设置套账信息
    /// </summary>
    /// <param name="devid"></param>
    private void setTzid(string devid, string type)
    {

        string mysql = "";
        if (type == "card")
        {
            mysql = string.Format("SELECT tzid FROM dbo.tb_Devices where devid='{0}'", devid);
        }
        else
        {
            mysql = string.Format("SELECT tzid FROM dbo.tb_Customer where AccountNo='{0}'", account);
        }

        using (IDataReader reader = wechat.DBFactory.CFSFDB().ExecuteReader(mysql))
        {
            if (reader.Read())
            {
                tzid = Convert.ToString(reader.GetInt32(0));
            }
            else
            {
                errInfo = "无效信息";
                reader.Dispose();
            }
        }
    }
    #endregion

    #region 公用方法，判断此账号是否能用餐 前提：account、tzid 有值
    /// <summary>
    /// 检查是否有报餐、是否在餐次时间内、是否已消费过
    /// </summary>
    /// <returns></returns>
    private bool userInfo()
    {
        if (string.IsNullOrEmpty(account))
        {
            errInfo = "账号不存在,请先获取账号!";
            return false;
        }
        try
        {
            string classNo;
            DateTime dt1, dt2;
            using (IDataReader reader = wechat.DBFactory.CFSFDB().ExecuteReader(String.Format(@"
SELECT AccountNo,CustomerName,DeptNo,ClassNo,GrpNo ,SchNo,CardNo,EnDate1,EnDate2 
FROM dbo.tb_Customer WHERE AccountNo='{0}' AND tzid='{1}'
UNION ALL 
SELECT b.AccountNo,CustomerName,DeptNo,ClassNo,GrpNo ,SchNo,CardNo,EnDate1,EnDate2  
FROM tb_permitAccount a INNER JOIN tb_Customer b ON a.AccountNo=b.AccountNo  
WHERE a.AccountNo='{0}' AND a.tzid='{1}'  ", account, tzid)))
            {

                if (reader.Read())
                {
                    cname = reader.GetString(1);
                    classNo = reader[3].ToString();
                    dt1 = reader.GetDateTime(7);
                    dt2 = reader.GetDateTime(8);
                    reader.Dispose();
                }
                else
                {
                    errInfo = "无效的卡号或不允许在五里消费" ;

                    reader.Dispose();
                    return false;
                }
            }

            if (DateTime.Parse(today) < dt1 || DateTime.Parse(today) > dt2)
            {
                errInfo = "未报餐！";
                return false;
            }

            using (IDataReader reader = wechat.DBFactory.CFSFDB().ExecuteReader(String.Format(@"select SchNo from tb_ClassGrpSchT 
where ClassNo = {0} and sjsjs<={1} and sjsje>={1}", classNo, min)))
            {
                if (reader.Read())
                {
                    SchNo = reader[0].ToString();
                    reader.Dispose();
                }
                else
                {
                    errInfo = "未报餐或未到规定开餐时间!";
                    reader.Dispose();
                    return false;
                }
            }

            if (Array.IndexOf(unlimited, Convert.ToInt32(classNo)) < 0)//不在无限餐次中
            {
                using (IDataReader reader = wechat.DBFactory.CFSFDB().ExecuteReader(
               String.Format(@"select CONVERT(varchar(20),ConsumeTime,120) as ConsumeTime from tb_inf where accountno={0} and consumedate>='{1}' and SchNo = {2}", account, today, SchNo)))
                {
                    if (reader.Read())
                    {
                        errInfo = string.Format("在{0}已消费过了", reader.GetString(0));
                        reader.Dispose();
                        return false;
                    }
                    reader.Dispose();
                }
            }
            return true;
        }
        catch (Exception e)
        {
            errInfo = e.ToString();
            return false;
        }
    }
    #endregion

    #region 添加消费记录
    /// <summary>
    /// 添加消费记录
    /// </summary>
    private void addConsumeRecord()
    {
        string sql = string.Format(@"INSERT INTO dbo.tb_inf (AccountNo ,CustomerName,DeptNo, ClassNo,GrpNo ,LGrpNo ,SchNo ,WinNo ,OldLeftMoney ,LeftMoney ,Je, GLF, ConsumeDate, ConsumeTime , WorkerNo , OperatorNo,ConsumeNo , ItemNo,Flag )
SELECT AccountNo,CustomerName,DeptNo,ClassNo,GrpNo,1 LGrpNo,{1} SchNo,1,LeftMoney,LeftMoney - 1, 1 je,0 glf,'{2}',GETDATE(),1,0,ConsumeNo,1,0 
FROM dbo.tb_Customer WHERE AccountNo='{0}';
update tb_Customer set lastConsumeDate=GETDATE(),punchTime=GETDATE() where accountNo='{0}'", account, SchNo, today);

        wechat.DBFactory.CFSFDB().ExecuteNonQuery(sql);
    }
    #endregion

    #region 面区消费
    /// <summary>
    /// 面区刷卡消费  套账id先写成五里的11360,改通用是要修改
    /// </summary>
    public void noodleConsumByCard()
    {
        Boolean flag = false;
        string rt;
        string cardSnr = Convert.ToString(Request.Params["cardno"]);
        string devid = Convert.ToString(Request.Params["devid"]);//设备id，系统配置通道代码
        cardSnr = DeCode(cardSnr);//转化
        if (cardSnr.IndexOf("successed") > -1)
        {

            cardSnr = cardSnr.Replace("successed", "");
            if (isVailCardSnr(cardSnr))
            {

                string cardno = "", customerno = "", DeptNo = "", DeptName = "", ClassName = "";
                int mytzid = 1;
                using (IDataReader reader = wechat.DBFactory.CFSFDB().ExecuteReader(String.Format(@"SELECT a.tzid,CardNo,customerno, CustomerName,a.DeptNo,b.DeptName,c.ClassName FROM dbo.tb_Customer a 
                    INNER JOIN dbo.tb_Department b ON a.DeptNo=b.DeptNo INNER JOIN dbo.tb_Class c ON a.ClassNo=c.ClassNo WHERE AccountNo='{0}'  ", account)))
                {

                    if (reader.Read())
                    {
                        mytzid = reader.GetInt32(0);
                        cardno = reader.GetString(1);
                        customerno = reader.GetString(2);
                        cname = reader.GetString(3);
                        DeptNo = reader.GetString(4);
                        DeptName = reader.GetString(5);
                        ClassName = reader.GetString(6); ;
                    }
                    reader.Dispose();
                }
                tzid = Convert.ToString(mytzid);
                Dictionary<string, object> rtdic = new Dictionary<string, object>();//返回结果
                rtdic.Add("cname", cname);
                rtdic.Add("DeptName", DeptName);
                rtdic.Add("ClassName", ClassName);


                if (userInfo())//正常报餐消费
                {
                    flag = true;
                    errInfo = "消费成功";
                    addConsumeRecord();
                }
                else if (SchNo == "")//未报餐消费/已报餐未到规定时间
                {
                    /*  using (LiLanzDALForXLM dal = new LiLanzDALForXLM(clsConfig.GetConfigValue("OAConnStr")))
                      {
                          DataTable dt;
                          string err = dal.ExecuteQuery(string.Format("SELECT TOP 1 ConsumeTime FROM cy_t_consumerecords WHERE AccountNo='{0}' AND CONVERT(VARCHAR(10),ConsumeTime,120)=CONVERT(VARCHAR(10),GETDATE(),120)", account), out dt);
                          if (err != "") errInfo = err;
                          else if (dt.Rows.Count > 0) errInfo = string.Format("未报餐，在 {0} 已消费过了", dt.Rows[0]["ConsumeTime"]);
                          else
                          {
                              flag = true;
                              List<SqlParameter> paras = new List<SqlParameter>();
                              paras.Add(new SqlParameter("@tzid", mytzid));
                              paras.Add(new SqlParameter("@cardno", cardno));
                              paras.Add(new SqlParameter("@PersonNo", customerno));
                              paras.Add(new SqlParameter("@AccountNo", account));
                              paras.Add(new SqlParameter("@DeptNo", DeptNo));
                              paras.Add(new SqlParameter("@Dept", DeptName));
                              paras.Add(new SqlParameter("@cname", cname));
                              paras.Add(new SqlParameter("@ConsumeMoney", "7.0"));
                              dal.ExecuteNonQuerySecurity(@"declare @ryid int;set @ryid=0;select @ryid=ryid from xz_t_ygbcrysz where accountNo=@AccountNo;  INSERT INTO cy_t_consumerecords(tzid,cardno,PersonNo,PersonID,AccountNo,DeptNo,Dept,cname,ConsumeTime,ConsumeMoney)
  VALUES(@tzid,@cardno,@PersonNo,@ryid,@AccountNo,@DeptNo,@Dept,@cname,GETDATE(),@ConsumeMoney);", paras);
                              errInfo = "未报餐/未到规定时间 消费成功";
                          }
                      }*/
                    flag = false;
                    errInfo = "未报餐/未到规定时间 不允许消费";
                }

                rtdic.Add("result", flag);
                rtdic.Add("msg", errInfo);
                rt = response(0, rtdic, "");
            }
            else//非法卡内码，找不到对应信息
            {
                rt = response(101, flag, errInfo);
            }
        }
        else
        {
            rt = response(101, flag, "无效卡号！！");
        }
        clsSharedHelper.WriteInfo(rt);
    }

    #endregion

    #region 获取二维码对应的闸机

    private static Dictionary<string, string> devDic = new Dictionary<string, string>();
    private static Dictionary<string, string> devTzid = new Dictionary<string, string>();
    private string getDevid(string devcode)
    {
        string devid;
        if (devDic.ContainsKey(devcode))
        {
            devid = devDic[devcode];
            tzid = devTzid[devcode];
        }
        else
        {
            using (IDataReader reader = wechat.DBFactory.CFSFDB().ExecuteReader(String.Format(@" SELECT devid,tzid FROM tb_Devices WHERE devCode='{0}'  ", devcode)))
            {
                if (reader.Read())
                {
                    devDic.Add(devcode, reader.GetString(0));
                    devTzid.Add(devcode, Convert.ToString(reader.GetInt32(1)));
                    devid = devDic[devcode];
                    tzid = Convert.ToString(reader.GetInt32(1));
                }
                else
                {
                    devid = "";
                }
                reader.Dispose();
            }
        }
        return devid;
    }

    #endregion

    #region 消费情况查询
    /// <summary>
    /// 查询显示当前餐次，以无限制9 类型时间为准
    /// </summary>
    /// <returns></returns>
    private int getschNo()
    {
        int schno = 0;
        using (IDataReader reader = wechat.DBFactory.CFSFDB().ExecuteReader(String.Format(@" SELECT schno FROM dbo.tb_ClassGrpSchT WHERE  SJSJS<{0} AND sjsje>{0} AND classno=9 ", min)))
        {
            if (reader.Read())
            {
                schno = Convert.ToInt32(reader[0]);
            }
            reader.Dispose();
        }
        return schno;
    }
    /// <summary>
    /// 基本信息查询
    /// </summary>
    public void showbase()
    {
        string tzid = Convert.ToString(Request.Params["tzid"]);
        string schNo = Convert.ToString(Request.Params["schno"]);
        int schno;
        if (!int.TryParse(schNo, out schno))
        {
            schno = getschNo();
        }

        int mytzid;
        if (!int.TryParse(tzid, out mytzid))
        {
            mytzid = 11360;
        }

        if (schno == 0) clsSharedHelper.WriteInfo(response(101, schno, "未到规定时间"));

        string col = "", currentSch = ""; ;
        switch (schno)
        {
            case 1: col = "B"; currentSch = "早餐"; break;
            case 2: col = "L"; currentSch = "午餐"; break;
            case 3: col = "D"; currentSch = "晚餐"; break;
        }
        int orderusers;

        using (LiLanzDALForXLM dal = new LiLanzDALForXLM(clsConfig.GetConfigValue("OAConnStr")))
        {
            object obje;
            string mysql = string.Format(@"SELECT COUNT(1) AS persons
FROM dbo.xz_t_ygbcb a INNER JOIN  xz_t_ygbcb_cls  b ON a.ClassNo=b.ClassNo
WHERE a.tzid={0} and shbz=1 AND del=0 AND  CONVERT(VARCHAR(10),GETDATE(),120)  BETWEEN StartDate AND EndDate 
AND b.{1}=1", mytzid, col);
            dal.ExecuteQueryFast(mysql, out obje);
            orderusers = Convert.ToInt32(obje);
        }
        Dictionary<string, string> drt = new Dictionary<string, string>();
        drt.Add("currentSch", currentSch);
        drt.Add("dinnerPersons", orderusers.ToString());
        drt.Add("schno", schno.ToString());
        clsSharedHelper.WriteInfo(response(0, drt, ""));
    }
    /// <summary>
    /// 查询已消费信息
    /// </summary>
    public void used()
    {
        string tzid = Convert.ToString(Request.Params["tzid"]);
        int mytzid;
        if (!int.TryParse(tzid, out mytzid))
        {
            mytzid = 11360;
        }

        string schNo = Convert.ToString(Request.Params["schno"]);
        int schno;
        if (!int.TryParse(schNo, out schno))
        {
            schno = getschNo();
        }

        int usedcounts = 0, consumeCounts;
        string mysql = string.Format(@"SELECT COUNT(1)  usedcounts
FROM dbo.tb_Customer a INNER JOIN dbo.tb_inf b ON a.AccountNo=b.AccountNo
WHERE a.tzid={0} AND b.ConsumeDate=CONVERT(VARCHAR(10),GETDATE(),23) AND b.SchNo={1}", mytzid, schno);
        using (IDataReader reader = wechat.DBFactory.CFSFDB().ExecuteReader(mysql))
        {
            if (reader.Read())
            {
                usedcounts = reader.GetInt32(0);
            }
            reader.Dispose();
        }

        using (LiLanzDALForXLM dal = new LiLanzDALForXLM(clsConfig.GetConfigValue("OAConnStr")))
        {
            object consumeObj;
            mysql = string.Format(@"SELECT count(1)  FROM cy_t_consumerecords  WHERE tzid={0} AND CONVERT(VARCHAR(10),ConsumeTime,23) = CONVERT(VARCHAR(10),GETDATE(),23) ", mytzid);
            dal.ExecuteQueryFast(mysql, out consumeObj);
            consumeCounts = Convert.ToInt32(consumeObj);
        }

        Dictionary<string, object> rtdic = new Dictionary<string, object>();
        rtdic.Add("usedcounts", usedcounts);
        rtdic.Add("consumeCounts", consumeCounts);
        rtdic.Add("schno", schno);
        clsSharedHelper.WriteInfo(response(0, rtdic, ""));
    }
    #endregion


</script>

<!DOCTYPE html>
<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <meta http-equiv="Content-Type" content="text/html; charset=utf-8" />
    <title>餐厅刷卡</title>
    <meta name="viewport" content="width=device-width,initial-scale=1,user-scalable=0">
</head>
<body>
    <form id="form1" runat="server">
    </form>
</body>
</html>
