<%@ WebHandler Language="C#" Class="Timerpick" Debug="true" %>
using System.Web;
using Newtonsoft.Json;
using Newtonsoft.Json.Converters;
using System.Web.SessionState;
using System.Text;
using System.Data;
using System.Collections.Generic;
using nrWebClass;


public class Timerpick : IHttpHandler, IRequiresSessionState
{
    public string connID = "1";
    public void ProcessRequest(HttpContext context)
    {
        HttpRequest request = context.Request;
        HttpResponse response = context.Response;
        request.ContentEncoding = Encoding.UTF8;
        response.ContentType = "application/json"; //如果返回给客户端的是 json数据时， 设置ContentType="application/json"
        string action = request["action"].ToString();
        string toID = request["toID"].ToString();
        string pivotalID = request["pivotalID"].ToString();
        string str_sql = "";
        string info = "";
        string responseString = "";
        if (toID == "1")
        {//排产之工厂列表
            DataSet dataSet = null;
            if (action == "getdata")//            
            {

                using (LiLanzDALForXLM dal = new LiLanzDALForXLM(int.Parse(connID)))
                {
                    str_sql = @"
                    select rq=CONVERT(VARCHAR(10),rq,120) from t_timepick where mxid={0} and toID={1};                    
                    ";

                    info = dal.ExecuteQuery(string.Format(str_sql, pivotalID,toID), out dataSet);
                    dataSet.Tables[0].TableName = "zb";
                    if (info.Length > 0)
                    {
                        responseString = string.Format(@"{{""errcode"":12340,""errmsg"":""{0}"",""data"":""""}}", info);
                    }
                    else
                    {
                        responseString = JsonConvert.SerializeObject(dataSet);
                    }
                }
            }
            else if (action == "savedata")
            {
                InputData json = JsonConvert.DeserializeObject<InputData>(request.Form["json"]);

                str_sql = @"  delete  t_timepick where mxid={0} and toID={2}; ";
                for (int i = 0; i < json.DateList.Count; i++)
                {
                    str_sql += " insert t_timepick(mxid,rq,zdr,zdrq,toID) values({0},'" + json.DateList[i] + "','{1}',getdate(),{2});";
                }
                using (LiLanzDALForXLM dal = new LiLanzDALForXLM(int.Parse(connID)))
                {
                    info = dal.ExecuteQuery(string.Format(str_sql, pivotalID, json.UserName,toID), out dataSet);
                }
                if (info.Length > 0)
                {
                    responseString = string.Format(@"{{""errcode"":12341,""errmsg"":""{0}"",""data"":""""}}", info);
                }
                else
                {
                    responseString = string.Format(@"{{""errcode"":0,""errmsg"":""{0}"",""data"":""""}}", info);
                }

            }
        }
        response.Write(responseString);
        response.End();

    }
    public bool IsReusable
    {
        get { return false; }
    }
}

public class InputData
{
    #region 实体成员
    private List<string> dateList;
    public List<string> DateList { get { return dateList; } set { dateList = value; } }
    private string username;
    public string UserName { get { return username; } set { username = value; } }
    #endregion
}




