<%@ Page Language="C#" %>

<%@ Import Namespace="nrWebClass" %>
<%@ Import Namespace="System.Data" %>
<%@ Import Namespace="System.Data.SqlClient" %>
<%@ Import Namespace="System.Collections.Generic" %>
<%@ Import Namespace="System.IO" %>
<%@ Import Namespace="WebBLL.Core" %>
<!DOCTYPE html>
<script runat="server">   


    //发送信信息
    //mes=1确认,0不确认    
    public void SendWX()
    {
        string OAConnStr = clsConfig.GetConfigValue("OAConnStr");
        //TLBaseData._MyData sqlHelp = new TLBaseData._MyData();
        string str_sql = @"
             
                      
            select t1.name as zyfzr,t2.name as cgblr from (          
               
             
                select '叶谋锦' zyfzr,'叶谋锦' cgblr  
               
            ) a  inner join t_user t1 on t1.cname=a.zyfzr inner join t_user t2 on t2.cname=a.cgblr
 
         
        ";

        //SqlConnection TlConnection = (SqlConnection)Class_BBlink.LILANZ.DatabaseConn.ConnectionByID("1");      
        //DataSet dataset = (DataSet)sqlHelp.MyDataSet(TlConnection, str_sql.Replace("@chdm_in", "'" + chdm + "'").Replace("@cpjjs_in", "'" + cpjj + "'").Replace("@userid_in", "'" + userid.ToString() + "'"));
        DataSet dataset = null;
        using (LiLanzDALForXLM dal = new LiLanzDALForXLM(OAConnStr))
        {
            dal.ExecuteQuery(str_sql, out dataset);
        }


        List<string> list = new List<string>();
        //需要发送的人

        foreach (DataRow dr in dataset.Tables[0].Rows)
        {
            if (!list.Contains(dr["zyfzr"].ToString()))
            {
                list.Add(dr["zyfzr"].ToString());
            }
            if (!list.Contains(dr["cgblr"].ToString()))
            {
                list.Add(dr["cgblr"].ToString());
            }
        }
        // end 需要发送的人 

        //发送内容
        string content = "材料编号:";
        //end 发送内容
        StringBuilder result = new StringBuilder();
        try
        {
            //nrWebClass.MsgClient msgclient;
            foreach (string user in list)
            {

                //msgclient = new nrWebClass.MsgClient("192.168.35.63", 21000);
                //System.Collections.Generic.Dictionary<string, string> items = new System.Collections.Generic.Dictionary<string, string>();
                //items.Add("toparty", "");
                //items.Add("totag", "");
                //items.Add("msgtype", "text");
                //items.Add("agentid", "4");
                //items.Add("safe", "0");
                //items.Add("content", content);
                //items.Add("touser", user);
                //msgclient.EntMsgSend(items);
                result.Append(clsWXHelper.SendQYMessage(user, 0, content));

            }
            Response.Clear();
            Response.Write(result);
            Response.End();
        }
        catch (SystemException ex)
        {
            Response.Clear();
            Response.Write("{result:'Error',state:'" + ex.Message + "'}");
            Response.End();
        }


    }

    protected void Page_Load(object sender, EventArgs e)
    {

         clsJsonHelper result=clsWXHelper.SendQYMessage("Ymd", 0, "test");
        Response.Write(result.jSon);
        //SendWX();
    }



</script>
<html lang="en" xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <title>米样确认</title>
    <meta name="viewport" content="height=device-height,width=device-width,initial-scale=1.0,minimum-scale=1.0,maximum-scale=1.0,user-scalable=no" />
    <meta name="format-detection" content="telephone=yes" />
    <meta http-equiv="Content-Type" content="text/html; charset=UTF-8" />
    <link href="../../res/css/ErpScan/jquery-impromptu.css" rel="stylesheet" type="text/css" />
    <link href="../../res/css/sweet-alert.css" rel="stylesheet" type="text/css" />
    <script type="text/javascript" src="http://res.wx.qq.com/open/js/jweixin-1.0.0.js"></script>
    <script type="text/javascript" src="../../api/lilanzAppWVJBridge.js"></script>
    <script type="text/javascript" src="../../res/js/jquery.js"></script>
    <script src="../../res/js/ErpScan/jquery-impromptu.js" type="text/javascript"></script>
    <script src="../../res/js/sweet-alert.min.js" type="text/javascript"></script>
</head>
<body>
    <form id="form1" runat="server">
       
        <input type="hidden" runat="server" id="appIdVal" />
        <input type="hidden" runat="server" id="timestampVal" />
        <input type="hidden" runat="server" id="nonceStrVal" />
        <input type="hidden" runat="server" id="signatureVal" />
        <input type="hidden" runat="server" id="useridVal" />
    </form>
    
</body>
</html>
