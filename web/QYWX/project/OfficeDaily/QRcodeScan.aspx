<%@ Page Language="C#" %>

<%@ Import Namespace="System.Data" %>
<%@ Import Namespace="Newtonsoft.Json" %>
<%@ Import Namespace="System.Collections.Generic" %>
<%@ Import Namespace="nrWebClass" %>
<%@ Import Namespace="System.Data.SqlClient" %>


<script runat="server">
    private const string appID = "wxe46359cef7410a06";  //APPID
    private const string appSecret = "wCwNUgMb4LDbaH0m0XZJV7Hb9hma2FGOX4MDtSqd3SggbUem4tV4QV2M15762qoK";    //appSecret	
    private string SchNo = ""; //餐次
    int min;
    string today;
    string account = "";
    string cname = "";
    string CardNo = "";
    string devid = "";

    protected void Page_Load(object sender, EventArgs e)
    {

        if (clsWXHelper.CheckQYUserAuth(true))
        {
            string AppSystemKey = clsWXHelper.GetAuthorizedKey(5);
            if (AppSystemKey == "" || AppSystemKey == "0")
            {
                LabelUser.Text = "未关联餐卡信息11";
            }
            else
            {
                account = AppSystemKey;
                devid = Convert.ToString(Request.Params["devid"]);
                DateTime TimeNow = DateTime.Now;
                min = TimeNow.Hour * 60 + TimeNow.Minute;
                today = TimeNow.ToString("yyyy-MM-dd");
                if (UserInfo())
                {
                    if (SchNo != "")
                        userCheck(devid);
                    else
                    {
                        LabelUser.Text = "未报餐暂不能消费!";
                        //cashPay();
                    }
                }
            }
        }
        else
        {
            LabelUser.Text = "未关注企业号";
        }

    }



    private bool UserInfo()
    {

        string CustomerName = "", DeptNo = "", ClassNo = "";
        DateTime dt1, dt2;

        using (IDataReader reader = wechat.DBFactory.CFSFDB().ExecuteReader(String.Format(@"SELECT AccountNo,CustomerName,DeptNo,ClassNo,GrpNo ,SchNo,CardNo,EnDate1,EnDate2
FROM dbo.tb_Customer_coffee WHERE AccountNo='{0}'", account)))
        {
            if (reader.Read())
            {
                CustomerName = reader.GetString(1);
                DeptNo = reader.GetString(2);
                ClassNo = reader[3].ToString();
                CardNo = reader[6].ToString();

                dt1 = reader.GetDateTime(7);
                dt2 = reader.GetDateTime(8);
            }
            else
            {
                reader.Dispose();
                return false;
            }
            reader.Dispose();
        }



        using (IDataReader reader = wechat.DBFactory.CFSFDB().ExecuteReader(String.Format(@"select SchNo from tb_ClassGrpSchT 
where ClassNo = {0} and sjsjs<={1} and sjsje>={1}", ClassNo, min)))
        {
            if (!reader.Read())
            {
                LabelUser.Text = "未到规定时间/未报餐";
            }
            else
            {
                SchNo = reader[0].ToString();
            }
            reader.Dispose();
        }
        return true;
    }
    private void userCheck(String devid)
    {
        using (IDataReader reader = wechat.DBFactory.CFSFDB().ExecuteReader(
                   String.Format(@"select 1 from tb_inf where accountno={0} and consumedate>='{1}' and SchNo = {2} ", account, today, SchNo)))
        {
            if (reader.Read() && DateTime.Now.Date > Convert.ToDateTime("2018-06-08"))
            {
                LabelUser.Text = "已消费过了";
                return;
            }
            reader.Dispose();
        }

        string DeptName = "", ClassName = "";
        using (IDataReader reader = wechat.DBFactory.CFSFDB().ExecuteReader(String.Format(@"SELECT a.tzid,CardNo,customerno, CustomerName,a.DeptNo,b.DeptName,c.ClassName FROM dbo.tb_Customer a 
                    INNER JOIN dbo.tb_Department b ON a.DeptNo=b.DeptNo INNER JOIN dbo.tb_Class c ON a.ClassNo=c.ClassNo WHERE AccountNo='{0}'  ", account)))
        {
            if (reader.Read())
            {
                cname = reader.GetString(3);
                DeptName = reader.GetString(5);
                ClassName = reader.GetString(6); ;
                reader.Dispose();
            }
        }

        string sql = string.Format(@"INSERT INTO dbo.tb_inf (AccountNo ,CustomerName,DeptNo, ClassNo,GrpNo ,LGrpNo ,SchNo ,WinNo ,OldLeftMoney ,LeftMoney ,Je, GLF, ConsumeDate, ConsumeTime , WorkerNo , OperatorNo,ConsumeNo , ItemNo,Flag )
SELECT AccountNo,CustomerName,DeptNo,ClassNo,GrpNo,1 LGrpNo,{1} SchNo,1,LeftMoney,LeftMoney - 1, 1 je,0 glf,'{2}',GETDATE(),1,0,ConsumeNo,1,0 
FROM dbo.tb_Customer WHERE AccountNo='{0}';
update tb_Customer set lastConsumeDate=GETDATE(),punchTime=GETDATE() where accountNo='{0}'", account, SchNo, today);

        wechat.DBFactory.CFSFDB().ExecuteNonQuery(sql);
        try
        {

            LabelUser.Text = String.Format("验证通过{0} 通道{1}", cname + today, devid);
            //发送消费通知
            clsNetExecute.HttpRequest(string.Format("http://192.168.135.98:12001/noodleDisplay?devid={0}&cname={1}&DeptName={2}&ClassName={3}&msg={4}", devid, cname, DeptName, ClassName, LabelUser.Text));
        }
        catch (Exception ex)
        {
            LabelUser.Text = ex.ToString();
        }
    }
    /// <summary>
    /// 没有报餐现金消费
    /// </summary>
    private void cashPay()
    {
        string cardno = "", customerno = "", DeptNo = "", DeptName = "", ClassName = "";
        int tzid = 1;
        using (IDataReader reader = wechat.DBFactory.CFSFDB().ExecuteReader(String.Format(@"SELECT a.tzid,CardNo,customerno, CustomerName,a.DeptNo,b.DeptName,c.ClassName FROM dbo.tb_Customer a 
                    INNER JOIN dbo.tb_Department b ON a.DeptNo=b.DeptNo INNER JOIN dbo.tb_Class c ON a.ClassNo=c.ClassNo WHERE AccountNo='{0}'  ", account)))
        {
            if (reader.Read())
            {
                tzid = reader.GetInt32(0);
                cardno = reader.GetString(1);
                customerno = reader.GetString(2);
                cname = reader.GetString(3);
                DeptNo = reader.GetString(4);
                DeptName = reader.GetString(5);
                ClassName = reader.GetString(6); ;
                reader.Dispose();
            }
        }

        using (LiLanzDALForXLM dal = new LiLanzDALForXLM(clsConfig.GetConfigValue("OAConnStr")))
        {
            DataTable dt;
            string err = dal.ExecuteQuery(string.Format("SELECT TOP 1 id FROM cy_t_consumerecords WHERE AccountNo='{0}' AND CONVERT(VARCHAR(10),ConsumeTime,120)=CONVERT(VARCHAR(10),GETDATE(),120)", account), out dt);
            if (err != "") { LabelUser.Text = err; return; }
            else if (dt.Rows.Count > 0 && account != "10004430" && DateTime.Now < Convert.ToDateTime("2018-08-20")) { LabelUser.Text = "未报餐，已消费过了"; return; }
            else
            {
                List<SqlParameter> paras = new List<SqlParameter>();
                paras.Add(new SqlParameter("@tzid", tzid));
                paras.Add(new SqlParameter("@cardno", cardno));
                paras.Add(new SqlParameter("@PersonNo", customerno));
                paras.Add(new SqlParameter("@AccountNo", account));
                paras.Add(new SqlParameter("@DeptNo", DeptNo));
                paras.Add(new SqlParameter("@Dept", DeptName));
                paras.Add(new SqlParameter("@cname", cname));
                paras.Add(new SqlParameter("@ConsumeMoney", "7.0"));
                dal.ExecuteNonQuerySecurity(@"declare @ryid int;set @ryid=0;select @ryid=ryid from xz_t_ygbcrysz where accountNo=@AccountNo;  INSERT INTO cy_t_consumerecords(tzid,cardno,PersonNo,PersonID,AccountNo,DeptNo,Dept,cname,ConsumeTime,ConsumeMoney)
VALUES(@tzid,@cardno,@PersonNo,@ryid,@AccountNo,@DeptNo,@Dept,@cname,GETDATE(),@ConsumeMoney);", paras);
            }

        }
        LabelUser.Text = "未报餐消费扣款";
        //消费通知
        clsNetExecute.HttpRequest(string.Format("http://192.168.135.98:12001/noodleDisplay?devid={0}&cname={1}&DeptName={2}&ClassName={3}&msg={4}", devid, cname, DeptName, ClassName, LabelUser.Text));
    }


</script>

<!DOCTYPE html>
<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <meta http-equiv="Content-Type" content="text/html; charset=utf-8" />
    <title>餐厅刷卡</title>
    <meta name="viewport" content="width=device-width,initial-scale=1,user-scalable=0">
    <style type="text/css">
        * {
            margin: 0;
            padding: 0;
        }

        .container {
            background-color: #FFF;
            display: block;
            height: 100%;
            padding-top: 36px;
        }

        .msg {
            margin-bottom: 30px;
            text-align: center;
        }

        div {
            display: block;
        }

        .msg-text {
            text-align: center;
            margin-bottom: 25px;
        }

        .msg-btn {
            text-align: center;
            margin: 15px;
        }

        .btn {
            text-decoration: none;
            font-size: 18px;
            box-sizing: border-box;
            padding-left: 18px;
            padding-right: 18px;
            background-color: #04be02;
            color: #fff;
            display: block;
            line-height: 2.3;
            border-radius: 10px;
        }
    </style>

</head>
<body>
    <form id="form1" runat="server">
        <div class="container">
            <div class="msg">
            </div>
            <div class="msg-text">
                <h2>
                    <asp:Label ID="LabelUser" runat="server" Text=""></asp:Label></h2>
                <p></p>
            </div>
            <div class="msg-btn">
                <a href="javascript:WeixinJSBridge.call('closeWindow')" class="btn">关闭</a>
            </div>
        </div>
    </form>
</body>
</html>
