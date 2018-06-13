<%@ WebHandler Language="C#" Class="LLWebApi_CL_GetPick" Debug="true" %>

using System;
using System.Web;
using System.Data;
using System.IO;
using System.Text;
using System.Data.SqlClient;
using System.Collections.Generic;
using LLWebApi.Base;
using LLWebApi.Utils;
using nrWebClass;
using Newtonsoft.Json;
using Newtonsoft.Json.Converters;

public class LLWebApi_CL_GetPick : IHttpHandler
{

    string jsonMb = @" {{ ""errcode"": ""{0}"", ""errmsg"": ""{1}"", ""data"": ""{2}"" }} ";
    public void ProcessRequest(HttpContext context)
    {
        string reqData = readStream(context.Request.InputStream, "utf-8");
        IDictionary<string, string> pars = HttpPostUtil.getURLParameters(reqData);
        Parameter parameter = JsonConvert.DeserializeObject<Parameter>(pars["bizdata"]);
        DataSet htzinfoDs = null;
        string sql = @" exec yx_cx_Pick '{0}','{1}'";
        using (LiLanzDALForXLM dal = new LiLanzDALForXLM())
        {
            dal.ConnectionString = "Server=192.168.35.10;Database=TLSOFT;Uid=ABEASD14AD;Pwd=+AuDkDew;";
            dal.ExecuteQuery(string.Format(sql, parameter.BeginDate, parameter.EndDate), out htzinfoDs);
        }

        if (htzinfoDs.Tables.Count > 0)
        {
            htzinfoDs.Tables[0].TableName = "pick";
            context.Response.Write(string.Format(jsonMb, "0", "", JsonConvert.SerializeObject(htzinfoDs)));
        }
        else
        {
            context.Response.Write(string.Format(jsonMb, "4001", "没有记录"));
        }

        context.Response.End();
    }
    private string readStream(Stream iStream, string charset)
    {
        StreamReader reader = new StreamReader(iStream, Encoding.GetEncoding(charset));
        return HttpContext.Current.Server.UrlDecode(reader.ReadToEnd());
    }
    public bool IsReusable
    {
        get { return true; }
    }
}
public class Parameter
{
    string beginDate;

    public string BeginDate
    {
        get { return beginDate; }
        set { beginDate = value; }
    }

    string endDate;

    public string EndDate
    {
        get { return endDate; }
        set { endDate = value; }
    }

}


