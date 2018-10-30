<%@ Page Language="C#" %>
<%@ Import Namespace="nrWebClass" %>
<%@ Import Namespace="System.Data" %>
<%@ Import Namespace="System.Data.SqlClient" %>
<%@ Import Namespace="System.Collections.Generic" %>
<!DOCTYPE html>
<script runat="server">  	 
    string OAConnStr = clsConfig.GetConfigValue("OAConnStr"); 
    //string OAConnStr = "server='192.168.35.10';uid=ABEASD14AD;pwd=+AuDkDew;database=tlsoft"; 
    protected void Page_Load(object sender, EventArgs e)
    { 
        string customersID = Convert.ToString(Session["qy_customersid"]);
        //if (customersID == null || customersID == "")
        //{
        //    clsSharedHelper.WriteErrorInfo("您已超时,请重新刷新后访问");
        //    return;
        //}
        string rt = "";
        string ctrl = Convert.ToString(Request.Params["ctrl"]);

        switch (ctrl)
        {
            case "SendOne":
                SendOne();
                break;
            case "Select":
                SendSelect(false);
                break;
            case "SendSelect":
                SendSelect(true);
                break;
            default: rt = clsNetExecute.Error + "参数有误"; break;
        }
        clsSharedHelper.WriteInfo(rt); 
    }

    public string SendSelect(bool isSend)
    {
        string khid = Request.Params["khid"];   //贸易公司的客户ID 
        string dhbh = Request.Params["dhbh"];
        string bat = Request.Params["bat"];
        string Hotel = Request.Params["hotel"];     //由于微信端可能会自动解码JS调用端必须进行两次UTF-8的编码。
        string cname = Request.Params["cname"];
        string mobile = Request.Params["mobile"];      

        string strInfo = "";
                

        List<SqlParameter> lstSqlParams = new List<SqlParameter>();
        string strSQL = @"SELECT DISTINCT C.name,C.cname,C.mobile FROM yx_t_dhryxx A
                            INNER JOIN yx_t_khb B ON A.khid = B.khid
                            INNER JOIN wx_t_customers C ON A.PhoneNumber = C.mobile ";
                             
        if (bat != null && bat != "" && bat != "0")   // 1 2 3
        {
            strSQL = string.Concat(strSQL , @" INNER JOIN t_customer as t7 on DBO.split(B.ccid,'-',2)=t7.khid AND bat=@bat");
            lstSqlParams.Add(new SqlParameter("@bat", bat));
        }

        if (dhbh != null && dhbh != "")
        {
            strSQL = string.Concat(strSQL, @" WHERE A.dhbh = @dhbh ");
            lstSqlParams.Add(new SqlParameter("@dhbh", dhbh));
        }
        else
        {
            strSQL = string.Concat(strSQL, @" WHERE 1=1 ");
        }
        

        if (khid != null && khid != "" && khid != "0")
        {
            string khccid = string.Concat("-1-", khid, "-%");
            lstSqlParams.Add(new SqlParameter("@khccid", khccid));
            strSQL = string.Concat(strSQL, " AND B.ccid + '-' LIKE @khccid ");            
        }

        if (Hotel != null && Hotel != "")
        {
            //clsLocalLoger.WriteInfo(Hotel);
            Hotel = HttpUtility.UrlDecode(Hotel,System.Text.Encoding.UTF8);
            //clsLocalLoger.WriteError(Hotel);
            lstSqlParams.Add(new SqlParameter("@Hotel", string.Concat('%', Hotel,'%')));
            strSQL = string.Concat(strSQL, " AND A.Hotel LIKE @Hotel ");            
        }

        if (mobile != null && mobile != "")
        {
            lstSqlParams.Add(new SqlParameter("@mobile", mobile));
            strSQL = string.Concat(strSQL, " AND C.mobile = @mobile ");            
        }
        if (cname != null && cname != "")
        {
            lstSqlParams.Add(new SqlParameter("@cname", cname));
            strSQL = string.Concat(strSQL, " AND C.cname = @cname ");            
        }
         
        using (LiLanzDALForXLM dal = new LiLanzDALForXLM(OAConnStr))
        {
            DataTable dt;
            strInfo = dal.ExecuteQuerySecurity(strSQL, lstSqlParams, out dt);
            if (strInfo == "")
            {
                if (isSend)
                {
                    string sendMsg = Request.Params["msg"];
                    string beginIndex = Request.Params["beginIndex"];
                    if (sendMsg == null || sendMsg == "")
                    {
                        strInfo = "必须传入msg参数！";
                        clsLocalLoger.WriteError(strInfo);
                        clsSharedHelper.WriteErrorInfo(strInfo);
                        return strInfo;
                    }
                    else if (beginIndex == null || beginIndex == "")
                    {
                        strInfo = "必须传入beginIndex参数！";
                        clsLocalLoger.WriteError(strInfo);
                        clsSharedHelper.WriteErrorInfo(strInfo);
                        return strInfo;
                    }
                    else
                    {
                        DataRow dr;
                        int j = dt.Rows.Count;
                        int myIndex = Convert.ToInt32(beginIndex);
                        clsLocalLoger.WriteInfo(string.Format("【订货会务管理】准备发送消息({0})，给{1}个对象...", sendMsg, j - myIndex));

                        string SendMsgInfo = "";
                        int SendOK = 0;
                        int SendErr = 0;
                        for (int i = myIndex; i < j; i++)
                        {
                            dr = dt.Rows[i];
                            clsLocalLoger.WriteInfo(string.Format("【订货会务管理】开始发送第 {0} 个，姓名：{1}", i+1, dr["cname"]));
                            SendMsgInfo = string.Concat(strInfo, SendMsg(Convert.ToString(dr["name"]), sendMsg));

                            if (SendMsgInfo == "") SendOK++;
                            else SendErr++;
                        }

                        strInfo = string.Format("发送完毕！查询到{0}人。从索引开始推送：{1} 人。成功 {2} 人，失败 {3} 人。", j , j - myIndex, SendOK, SendErr);                   
                        clsLocalLoger.WriteInfo(string.Concat("【订货会务管理】" , strInfo));
                        //StringBuilder sb = new StringBuilder();
                        //foreach (DataRow dr in dt.Rows)
                        //{
                        //    sb.AppendFormat("|{0}", Convert.ToString(dr["name"])); 
                        //}
                        //if (sb.Length > 0) sb.Remove(0, 1);

                        //strInfo = string.Concat(strInfo, SendMsg(sb.ToString(), sendMsg));
                    }
                } 
                else
                {                    
                    List<string> sbList = new List<string>();
                    foreach (DataRow dr in dt.Rows)
                    {
                        sbList.Add((string)dr["cname"]);
                    }

                    strInfo = string.Concat("找到对象(", sbList.Count, ")：", string.Join(",", sbList.ToArray()));                    
                }
            }
            else
            {
                strInfo = string.Concat("SQL执行失败！错误：", strInfo);
                clsLocalLoger.WriteError(strInfo); 
            }
            if (dt != null) {dt.Clear(); dt.Dispose();}
        }
        clsSharedHelper.WriteInfo(strInfo);
        return strInfo;        
    }
        
    public string SendOne()
    {
        string sendUser = Request.Params["SendUser"];
        string sendMsg = Request.Params["msg"];
        return SendMsg(sendUser, sendMsg);
    }
   
    public string SendMsg(string sendUser, string sendMsg)
    { 
        int meetingAppID = 30;
        string strReturn;
        using (clsJsonHelper jh = clsWXHelper.SendQYMessage(sendUser, meetingAppID, sendMsg))
        {
            if (jh.GetJsonValue("errcode") != "0")
            {
                strReturn = jh.jSon;
                clsLocalLoger.WriteError(string.Concat("【订货会务管理】推送给 ", sendUser, " 失败！错误：", strReturn));            
            }
            else
            {
                strReturn = "";
                clsLocalLoger.WriteInfo(string.Concat("【订货会务管理】推送给 ", sendUser, " 成功！"));            
            }
        }
        return strReturn;
    }
     
</script>

<html lang="en" xmlns="http://www.w3.org/1999/xhtml">
<head id="Head1" runat="server">
    <meta charset="utf-8" />
    <title></title>
</head>
<body>
    <form id="form1" runat="server">
    </form>
</body>
</html>
