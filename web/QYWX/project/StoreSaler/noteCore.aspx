<%@ Page Language="C#" %>
<%@ Import Namespace="nrWebClass" %>
<%@ Import Namespace="System.Data" %>
<%@ Import Namespace="System.Data.SqlClient" %>
<%@ Import Namespace="System.Collections.Generic" %>
<!DOCTYPE html>
<script runat="server">
    //private string FXDBConnStr = "server='192.168.35.11';uid=ABEASD14AD;pwd=+AuDkDew;database=FXDB";
    //private string ZBDBConnStr = "server='192.168.35.10';uid=lllogin;pwd=rw1894tla;database=tlsoft";

    private const string topMsgData = " TOP 20 ";
    
    protected void Page_Load(object sender, EventArgs e)
    {       
        string ctrl = "";

        if (ctrl == null || ctrl == "")
        {
            ctrl = Convert.ToString(Request.Params["ctrl"]);
        }
                                
        switch (ctrl)
        {
            case "getNotes":
                getList();
                break;
            case "saveNote":
                saveNote();
                break; 
            default:
                clsSharedHelper.WriteErrorInfo("无【CTRL=" + ctrl + "】对应操作！");
                break;
        }        
    }

    public void getList()
    {
        string SalerID = Convert.ToString(Request.Params["SalerID"]);
        int MsgLastID = Convert.ToInt32(Request.Params["listLastID"]);
        string strInfo = "";
        string msgInfo = "";

        string ConWX = ConfigurationManager.ConnectionStrings["Conn"].ConnectionString;
        using (LiLanzDALForXLM wxDal = new LiLanzDALForXLM(ConWX))
        {
            string AddSQL = "";
            if (MsgLastID > 0)
            {
                AddSQL = string.Format(" AND ID < {0} ", MsgLastID);
            }

            //用于加载名单
            string strSQL = string.Format(@" 
                        SELECT {0} ID,LastTime,NoteInfo FROM wx_t_SalerNote WHERE SalerID={1} {2}
                         ORDER BY ID DESC", topMsgData, SalerID, AddSQL);

            DataTable dt;
            strInfo = wxDal.ExecuteQuery(strSQL, out dt);
            if (strInfo == "")
            {
                if (dt.Rows.Count > 0)
                {
                    StringBuilder sb = new StringBuilder();
                    List<string> lstData = new List<string>();

                    foreach (DataRow dr in dt.Rows)
                    {

                        lstData.Add(string.Format(@"{{ ""id"":""{0}"",
                                                    ""time"":""{1}"",
                                                    ""info"":""{2}""}} "
                        , dr["ID"], Convert.ToDateTime(dr["LastTime"]).ToString("yyyy-MM-dd HH:mm"), Convert.ToString(dr["NoteInfo"])));
                    }

                    int newMsgLastID = Convert.ToInt32(dt.Rows[dt.Rows.Count - 1]["ID"]);

                    msgInfo = string.Concat(@"{ ""listLastID"":""", newMsgLastID, @""",
                                                        ""list"": [", string.Join(",\n", lstData.ToArray()), "] }");
                }
                else
                {
                    //什么消息都没有
                    msgInfo = string.Concat(@"{ ""listLastID"":""0"",
                                              ""list"": [] } ");
                }
                dt.Rows.Clear(); dt.Dispose();
            }
            else
            {
                clsSharedHelper.WriteErrorInfo(string.Concat("数据库查询失败！错误：", strInfo));
            }
        }
        clsSharedHelper.WriteInfo(msgInfo);
    }

    public void saveNote()
    {
        string id = Convert.ToString(Request.Params["id"]);
        string SalerID = Convert.ToString(Request.Params["SalerID"]);
        string NoteInfo = Convert.ToString(Request.Params["info"]);
        string errInfo = "";
          
        string ConWX = ConfigurationManager.ConnectionStrings["Conn"].ConnectionString;
        using (LiLanzDALForXLM wxDal = new LiLanzDALForXLM(ConWX))
        {
            string strSql;
            List<SqlParameter> param = new List<SqlParameter>();
            if (id == "0"){
                strSql = @" INSERT INTO wx_t_SalerNote (SalerID,NoteInfo) VALUES (@SalerID,@NoteInfo) 
                            SELECT @@identity";
            }else{
                strSql = @" UPDATE wx_t_SalerNote SET NoteInfo= @NoteInfo,LastTime=GetDate() WHERE SalerID=@SalerID AND id=@id
                            SELECT @id";

                param.Add(new SqlParameter("@id", id));
            }

            param.Add(new SqlParameter("@SalerID", SalerID));
            param.Add(new SqlParameter("@NoteInfo", NoteInfo));

            object objID = 0;
            errInfo = wxDal.ExecuteQueryFastSecurity(strSql, param, out objID);
            if (errInfo == "")
            {
                clsSharedHelper.WriteSuccessedInfo(Convert.ToString(objID));
            }
            else
            {
                clsLocalLoger.WriteError(string.Concat("保存学习笔记失败！错误：", errInfo));
                clsSharedHelper.WriteInfo("保存学习笔记失败！");
            }
        }
    }
    
    
</script>

<html lang="en" xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
<meta charset="utf-8" />
    <title></title>    
</head>
<body>
    <form id="form1" runat="server">   
    </form>
</body>
</html>
