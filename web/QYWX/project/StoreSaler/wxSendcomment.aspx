<%@ Page Language="C#" %>
<%@ Import Namespace="System.Data" %>
<%@ Import Namespace="System.Data.SqlClient" %>
<%@ Import Namespace="System.Collections.Generic" %>
<%@ Import Namespace="nrWebClass" %>
<%@ Import Namespace="Newtonsoft.Json" %>
<%@ Import Namespace="Newtonsoft.Json.Linq" %>
<!DOCTYPE html>
<script runat="server"> 

    private bool IsDebugMode = true;    //是否为调试模式



    protected void Page_Load(object sender, EventArgs e)
    {
        string ctrl = Convert.ToString(Request.Params["ctrl"]);

        switch (ctrl)
        {
            case "SendOK":
                SendOK();
                break;
            default:
                break;
        }
    }

    private void SendOK()
    {   string id = Convert.ToString(Request.Params["id"]);
        string parentid = Convert.ToString(Request.Params["parentid"]);
        string touserid = Convert.ToString(Request.Params["touserid"]);

        string DBcon = clsConfig.GetConfigValue("OAConnStr");
        using (LiLanzDALForXLM dal = new LiLanzDALForXLM(DBcon))
        {
            string strSQL = @"
            DECLARE @wxid1 VARCHAR(100),
                    @wxid2 VARCHAR(100),
                    @replyname VARCHAR(100),
                    @comment VARCHAR(500),
                 
            SELECT    @wxid1 = '',@wxid2 = '',@replyname = '',  @comment = ''
           
            
            SELECT TOP 1 @wxid1 = wxid from v_usercomment WHERE id = @parentid
          
            SELECT TOP 1 @replyname = CommentName ,  @comment = CommentContent WHERE id = @id and parentid = @parentid
           
            IF (@touserid!=0)    
           
            BEGIN                        
                    SELECT TOP 1 @wxid2 = wxid from v_usercomment  WHERE id = @touserid
                    
            END
             ";

            List<SqlParameter> listSqlParameter = new List<SqlParameter>();
            listSqlParameter.Add(new SqlParameter("@id", id));
            listSqlParameter.Add(new SqlParameter("@parentid", parentid));
            listSqlParameter.Add(new SqlParameter("@touserid",touserid));
            DataTable dtRead;
            string strInfo = dal.ExecuteQuerySecurity(strSQL, listSqlParameter, out dtRead);
            if (strInfo == "")
            {
                DataRow dr = dtRead.Rows[0];
              
                string wxid1 = Convert.ToString(dr["wxid1"]).Trim();  //必须去空格  
                string wxid2 = Convert.ToString(dr["wxid2"]).Trim();
                string comment = Convert.ToString(dr["comment"]).Trim();  //必须去空格  
                string replyname = Convert.ToString(dr["replyname"]).Trim();

                dtRead.Clear(); dtRead.Dispose();
                StringBuilder sbInfo = new StringBuilder();
                sbInfo.AppendFormat("{0}:对你做出了回复：{1}。", replyname, comment);

                string info1 = SendInfoWX(wxid1, sbInfo.ToString());
                if (wxid2 != "")
                {
                    SendInfoWX(wxid2, sbInfo.ToString());
                }
            }
            else 
{
              clsSharedHelper.WriteSuccessedInfo("评论回复失败！");    

            }


        }
    }


    public string SendInfoWX(string user, string content)
    {


        using (clsJsonHelper jh = clsWXHelper.SendQYMessage(user, 0, content))
        {
            clsLocalLoger.WriteInfo(string.Concat("[评论回复信息]", user, " 消息内容：",content , " 执行反馈：" , jh.jSon));
            if (jh.GetJsonValue("errcode") == "0" && jh.GetJsonValue("invaliduser") == "") return "done";
            else
            {
                //if (SendManagerName != user)
                //{
                //   clsLocalLoger.WriteError(string.Concat("[评论回复发送失败]", user, " 消息内容：", content, " 错误反馈：", jh.jSon));
                // using (clsJsonHelper jhMaster = clsWXHelper.SendQYMessage(SendManagerName, 0, string.Concat("(请注意：以下提醒未收到)\n", content)))
                //{
                //     if (jhMaster.GetJsonValue("errcode") != "0") clsLocalLoger.WriteError(string.Concat("[评论回复发送失败]提醒管理员【", SendManagerName, "】失败！", " 错误反馈：", jhMaster.jSon));
                //}
                //}
                return jh.jSon.Replace("\"", "'");
            }
        }
    }



</script>
<html>
<head id="Head1" runat="server">
    <meta http-equiv="Content-Type" content="text/html; charset=utf-8" />
    <title></title>
</head>
<body>
    <form id="form1" runat="server">
    <div>
    </div>
    </form>
</body>
</html>
