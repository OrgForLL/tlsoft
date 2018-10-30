<%@ Page Language="C#"%>
<%@ Import Namespace="System.Data" %> 
<%@ Import Namespace="Newtonsoft.Json" %> 
<script runat="server">
    private const string appID = "wxe46359cef7410a06";	//APPID
    private const string appSecret = "wCwNUgMb4LDbaH0m0XZJV7Hb9hma2FGOX4MDtSqd3SggbUem4tV4QV2M15762qoK";	//appSecret	
    private string SchNo = ""; //餐次
    int min;
    string today;
    string account = "";
    string cname = "";
    string CardNo = "";
    int cannel = 0;
    
    protected void Page_Load(object sender, EventArgs e)
    {
        cannel = nrWebClass.QueryString.QId("c");
        //if (cannel != 7 && cannel != 8)
        //    cannel = 8;
        
        DateTime TimeNow = DateTime.Now;
        min = TimeNow.Hour * 60 + TimeNow.Minute;
        today = TimeNow.ToString("yyyy-MM-dd");
        if (UserInfo())
        {
            if (SchNo != "")//有报餐
                userCheck(cannel);
            else // 等于通道9没有报餐  
            {
                if (cannel == 9)
                    cashPay();
            }         
        }
    }
    private bool UserInfo()
    {
        string wxcode = nrWebClass.QueryString.Q("code");
        string url = "https://qyapi.weixin.qq.com/cgi-bin/user/getuserinfo?access_token={0}&code={1}";
        string token = "";
        string rel = "";
        string  CustomerName = "", DeptNo = "", ClassNo = "";
        DateTime dt1, dt2;
        
        WxModel.wxEntUserQuery userinfo = null;
        nrWebClass.HttpHelper http = new nrWebClass.HttpHelper();
        using(IDataReader reader = wechat.DBFactory.dbhelper().ExecuteReader(@"SELECT AccessToken,validtime FROM wx_t_TokenConfigInfo WHERE ConfigKey = 1"))
        {
            if (reader.Read())
                token = reader.GetString(0);
        }
        url = string.Format(url, token, wxcode);
        rel = http.get(url);
        userinfo = JsonConvert.DeserializeObject<WxModel.wxEntUserQuery>(rel);

        String sql = String.Format(@"select b.SystemKey as AccountNo,a.cname as username,a.id as userid
from wx_t_customers a 
inner join wx_t_AppAuthorized b on a.ID=b.UserID and b.SystemID=5
where a.name='{0}' AND a.name<>''", userinfo.UserId);

        using(IDataReader reader = wechat.DBFactory.dbhelper().ExecuteReader(sql))
        { 
            if (reader.Read())
            {
                account = reader.GetString(0);
                cname = reader.GetString(1);
            }
            else
            {
                LabelUser.Text = "信息未关联";
               
                return false;
            }
            reader.Dispose();
        }
        
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
        
        if ((DateTime.Parse(today) < dt1 || DateTime.Parse(today) > dt2) && cannel != 9)
        {
            LabelUser.Text = "未报餐！！";
            return false;
        }
        
        using(IDataReader reader = wechat.DBFactory.CFSFDB().ExecuteReader(String.Format(@"select SchNo from tb_ClassGrpSchT 
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
    private void userCheck(int cannel)
    {
        using(IDataReader reader = wechat.DBFactory.CFSFDB().ExecuteReader(
            String.Format(@"select 1 from tb_inf where accountno={0} and consumedate>='{1}' and SchNo = {2}", account, today, SchNo)))
        { 
            if (reader.Read())
            {
                LabelUser.Text = "已消费过";
                return;
            }
            reader.Dispose();
        }
        string sql = string.Format(@"INSERT INTO dbo.tb_inf (AccountNo ,CustomerName,DeptNo, ClassNo,GrpNo ,LGrpNo ,SchNo ,WinNo ,OldLeftMoney ,LeftMoney ,Je, GLF, ConsumeDate, ConsumeTime , WorkerNo , OperatorNo,ConsumeNo , ItemNo,Flag )
SELECT AccountNo,CustomerName,DeptNo,ClassNo,GrpNo,1 LGrpNo,{1} SchNo,1,LeftMoney,LeftMoney - 1, 1 je,0 glf,'{2}',GETDATE(),1,0,ConsumeNo,1,0 
FROM dbo.tb_Customer WHERE AccountNo='{0}';
update tb_Customer set lastConsumeDate=GETDATE(),punchTime=GETDATE() where accountNo='{0}'", account, SchNo, today);

        wechat.DBFactory.CFSFDB().ExecuteNonQuery(sql);
        try
        {
            /*通道9煮面发送*/
            if(cannel != 9)
            { 
                nrWebClass.HttpHelper http2 = new nrWebClass.HttpHelper();
                string rel2 = http2.get(string.Format("http://192.168.35.63/?{0}", cannel));
            }
            else
            {
                nrWebClass.TaskClient client = new nrWebClass.TaskClient("192.168.35.63", 5000);
                client.CanteenSend(new string[] { "微信刷卡成功", CardNo, cname, "" }, 3, 128);
            }
            LabelUser.Text = String.Format("验证通过{0} 通道{1}", cname + today, cannel);
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
        nrWebClass.TaskClient client = new nrWebClass.TaskClient("192.168.35.63", 5000);
        client.CanteenSend(new string[] { "未报餐微信刷卡", CardNo, cname, "" }, 2, 128);
        LabelUser.Text = "未报餐消费扣款";
    }
</script>

<!DOCTYPE html>
<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
<meta http-equiv="Content-Type" content="text/html; charset=utf-8"/>
    <title>餐厅刷卡</title>
    <meta name="viewport" content="width=device-width,initial-scale=1,user-scalable=0">
    <style type="text/css">
*{margin:0;
padding:0;
}
.container{
	background-color:#FFF;
	display:block;
	height:100%;
	padding-top:36px}
.msg{ margin-bottom:30px;
text-align:center}
div{display:block}
.msg-text{text-align:center; 
margin-bottom:25px}
.msg-btn{text-align:center;
margin:15px;}
.btn{text-decoration:none;
font-size:18px;
box-sizing:border-box;
padding-left:18px;
padding-right:18px;
background-color:#04be02;
color:#fff;
display:block;
line-height:2.3;
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
