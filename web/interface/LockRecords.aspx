<%@ Page Language="C#" %>
<%@ Import Namespace="nrWebClass" %>
<%@ Import Namespace="System.Data.SqlClient" %>
<%@ Import Namespace="System.Data" %>
<%@ Import Namespace="System.IO" %>
<%@ Import Namespace="System.Collections.Generic" %>
<%@ Import Namespace="System.Net" %>

<!DOCTYPE html>
<script runat="server">    
    public static object _syncObj = new object();//用于控制_LRDT的写互斥
    private static DataTable _LRDT = null;
    
    private static DataTable LRDT() {
        if (_LRDT == null) {
            lock (_syncObj) {
                DataTable dt = new DataTable("t_recordLock");
                DataColumn dc;
                dc = new DataColumn();
                dc.DataType = Type.GetType("System.Int32");
                dc.ColumnName = "id";
                dc.ReadOnly = true;
                dc.AutoIncrement = true;//自动增加
                dc.AutoIncrementSeed = 1;//起始为1
                dc.AutoIncrementStep = 1;//步长为1 
                dc.AllowDBNull = false;
                dc.Unique = true;
                dt.Columns.Add(dc);

                dc = new DataColumn();
                dc.DataType = Type.GetType("System.String");
                dc.ColumnName = "tablename";
                dc.AllowDBNull = false;
                dc.DefaultValue = "";
                dt.Columns.Add(dc);

                dc = new DataColumn();
                dc.DataType = Type.GetType("System.Int32");
                dc.ColumnName = "dataid";
                dc.AllowDBNull = false;
                dc.DefaultValue = 0;
                dt.Columns.Add(dc);

                dc = new DataColumn();
                dc.DataType = Type.GetType("System.Boolean");
                dc.ColumnName = "islock";
                dc.AllowDBNull = false;
                dc.DefaultValue = false;
                dt.Columns.Add(dc);

                dc = new DataColumn();
                dc.DataType = Type.GetType("System.DateTime");
                dc.ColumnName = "activetime";
                dc.AllowDBNull = false;
                dc.DefaultValue = DateTime.Now;
                dt.Columns.Add(dc);

                dc = new DataColumn();
                dc.DataType = Type.GetType("System.Int32");
                dc.ColumnName = "holderid";
                dc.AllowDBNull = false;
                dc.DefaultValue = 0;
                dt.Columns.Add(dc);

                dc = new DataColumn();
                dc.DataType = Type.GetType("System.String");
                dc.ColumnName = "holdname";
                dc.AllowDBNull = false;
                dc.DefaultValue = "";
                dt.Columns.Add(dc);

                dc = new DataColumn();
                dc.DataType = Type.GetType("System.DateTime");
                dc.ColumnName = "holdtime";
                dc.AllowDBNull = false;
                dc.DefaultValue = DateTime.Now;
                dt.Columns.Add(dc);

                dc = new DataColumn();
                dc.DataType = Type.GetType("System.String");
                dc.ColumnName = "token";
                dc.AllowDBNull = false;
                dc.DefaultValue = "";
                dt.Columns.Add(dc);                                             

                _LRDT = dt;
            }
        }
        
        return _LRDT;
    }
    
    protected void Page_Load(object sender, EventArgs e)
    {
        string ctrl = Convert.ToString(Request.Params["ctrl"]);
        switch (ctrl)
        {
            case "CheckLockStatus":
                string dataJson = Convert.ToString(Request.Params["datas"]);
                string uid = Convert.ToString(Request.Params["uid"]);
                string uname = Convert.ToString(Request.Params["uname"]);
                string token = Convert.ToString(Request.Params["token"]);
                if (dataJson == "" || dataJson == null)
                    clsSharedHelper.WriteInfo("error:datas is NullOrEmpty");
                else if (uid == null || uid == "" || uname == null || uname == "")
                    clsSharedHelper.WriteInfo("error:系统超时！");
                else if (token == null || token == "")
                    clsSharedHelper.WriteInfo("error:token无效！");
                else
                    CheckRecordsLock(dataJson, uid, uname, token);
                break;
            case "printDT":
                printDataTable(LRDT());
                break;
            default:
                clsSharedHelper.WriteErrorInfo("无对应【" + ctrl + "】操作！");
                break;
        }
    }

    public void CheckRecordsLock(string dataJson, string userid, string username, string token)
    {
        string rtMsg = "error:LRS对象使用不正确！";
        DateTime STime = DateTime.Now;
        DataTable dt = LRDT();
        clsJsonHelper jh = clsJsonHelper.CreateJsonHelper(dataJson);
        List<clsJsonHelper> records = jh.GetJsonNodes("rows");
        for (int i = 0; i < records.Count; i++)
        {
            string tablename = records[i].GetJsonValue("tablename");            
            string ids =records[i].GetJsonValue("IDS");
            if (tablename == "" || ids == "")
                continue;
            string filter = "tablename='{0}' and dataid in ({1}) and islock=1 and activetime>='{3}' and token<>'{2}'";            
            filter = string.Format(filter, tablename, ids, token, STime.ToString());            
            DataRow[] drArr = dt.Select(filter);            
            if (drArr.Length > 0)
            {
                rtMsg = "warn:" + dt.Rows[0]["holdname"].ToString() + "|" + dt.Rows[0]["holdtime"].ToString();                
                break;
            }
            else
            {                
                lock (_syncObj)
                {
                    List<int> _idLists = new List<int>();
                    _idLists = Array2List(ids.Split(','));
                    //操作内存表                                            
                    filter = string.Format("tablename='{0}' and dataid in ({1})", tablename, ids);
                    drArr = dt.Select(filter);
                    
                    //更新
                    if (drArr.Length > 0)
                    {                        
                        for (int j = 0; j < drArr.Length; j++)
                        {
                            drArr[j]["islock"] = true;                            
                            drArr[j]["activetime"] = STime.AddSeconds(7).ToString();                            
                            drArr[j]["holderid"] = userid;
                            drArr[j]["holdname"] = username;
                            drArr[j]["holdtime"] = STime.ToString();                            
                            drArr[j]["token"] = token;                            
                            _idLists.Remove(Convert.ToInt32(drArr[j]["dataid"]));
                        }
                    }
                    //新增                                   
                    for (int k = 0; k < _idLists.Count; k++)
                    {
                        DataRow dr = dt.NewRow();                                        
                        dr["tablename"] = tablename;
                        dr["dataid"] = _idLists[k];
                        dr["islock"] = true;
                        dr["activetime"] = STime.AddSeconds(7).ToString();
                        dr["holderid"] = userid;
                        dr["holdname"] = username;
                        dr["holdtime"] = STime.ToString();
                        dr["token"] = token;
                        dt.Rows.Add(dr);
                    }
                    
                    rtMsg = "successd:";
                }
            }
        }//end for      
                  
        clsSharedHelper.WriteInfo(rtMsg);
    }
    
    public List<int> Array2List(string[] arrs) {
        List<int> arrList = new List<int>();
        for (int i = 0; i < arrs.Length; i++)
        {
            arrList.Add(Convert.ToInt32(arrs[i]));
        }

        return arrList;
    }
    
    public void printDataTable(DataTable dt)
    {
        string printStr = "";
        if (dt.Rows.Count > 0)
        {
            for (int i = 0; i < dt.Rows.Count; i++)
            {
                for (int j = 0; j < dt.Columns.Count; j++)
                {
                    if (dt.Rows[i][j] == null)
                        printStr += "null&nbsp;";
                    else
                        printStr += dt.Rows[i][j].ToString() + "&nbsp;";
                }
                printStr += "<br />";
            }
            Response.Write(printStr);
            Response.End();
        }
    }
</script>

<html lang="en" xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <meta charset="utf-8" />
    <title></title>
</head>
<body>
    <form runat="server">
        <div>
        </div>        
    </form>
</body>
</html>
