<%@ WebHandler Language="C#" Class="sc_fl_flcljcbg" %>
using System;
using System.Web;
using System.Collections.Generic;
using Newtonsoft.Json;
using Newtonsoft.Json.Converters;
using System.Web.SessionState;
using System.Text;
using System.Data;
using System.Data.SqlClient;
using nrWebClass;
using System.Net;
using System.IO;
using System.Drawing;

public class sc_fl_flcljcbg : IHttpHandler, IRequiresSessionState
{
    int zps = 650;  //限定之前一小时每个选手最多能被投多少票
    string bmStart = "2017-06-13"; //报名开始日期
    string bmEnd = "2017-07-10"; //报名结束日期
    string tpStart = "2017-07-13"; //投票开始日期
    string tpEnd = "2017-07-20"; //投票结束日期
    const int stopHourBegin = 0; //停止投票的限制开始时点 0:00:00
    const int stopHourEnd = 6; //停止投票的限制结束时点 6:59:59
    const string stopMsg = "夜已经深了，亲明日再来吧！";   //深夜不允许投票
    string VIPWebPath = clsConfig.GetConfigValue("VIP_WebPath");
    public void ProcessRequest(HttpContext context)
    {
        context.Response.ContentEncoding = System.Text.Encoding.UTF8;
        context.Request.ContentEncoding = System.Text.Encoding.UTF8;

        string ctrl = context.Request["ctrl"];
        switch (ctrl)
        {
            //case "LoadInfo":   //获取型男信息     //这个接口没有使用。
            //    string wxOpenid = context.Request["wxOpenid"];
            //    LoadInfo(wxOpenid, context);
            //    break;
            case "SetToken":   //粉丝投票
                string wxOpenid = context.Request["wxOpenid"]; //要投给的对象的微信openid
                SetToken(wxOpenid, context);
                break;
            case "Submit":     //型男报名
                Submit(context);
                break;
            case "LoadList":   //按票票数显示数据或按票票数排序显示TOP X型男信息
                LoadList(context);
                break;
            case "SendResult": //给参赛人员发送审核结果
                SendResult(context);
                break;
            case "UploadImg":  //上传图片
                UploadImg(context);
                break;
        }
    }

    public void UploadImg(HttpContext context)
    {
        string openid = Convert.ToString( context.Session["openid"]);
        if (string.IsNullOrEmpty(openid))
        {
            WriteTimeOut();
            return;
        }
        else
        {
            string formFile = context.Request.Params["formFile"];
            string rotate = context.Request.Params["rotate"];
            string[] rt = saveMyImgs(formFile, rotate, context).Split('|');
            if (rt[0] == "1")
            {
                context.Response.Write("{\"errcode\":\"0\",\"errmsg\":\"上传成功\",\"path\":\"" + rt[1] + "\" }");
            }
            else
            {
                context.Response.Write("{\"errcode\":\"1\",\"errmsg\":\"" + rt[1] + "\" }");
            }
            context.Response.End();
        }
    }


    /// <summary>
    /// 给参赛人员发送审核结果
    /// </summary>
    /// <param name="context"></param>
    public void SendResult(HttpContext context)
    {
        string wxOpenid = context.Request["wxOpenid"];
        string shzt = HttpUtility.UrlDecode(context.Request["shzt"].ToString());
        string bz = HttpUtility.UrlDecode(context.Request["bz"].ToString());
        string ConfigKey = clsConfig.GetConfigValue("CurrentConfigKey");
        string access_token = clsWXHelper.GetAT(ConfigKey);
        //string url = "https://api.weixin.qq.com/cgi-bin/message/template/send?access_token=" + access_token;
        //string data = "{\"touser\":\"{0}\",\"template_id\":\"gtCTjn4y5OwnTqALXuyE9MnX54ORJEhvc43SFcVi1ho\",\"url\":\"http://tm.lilanz.com/qywx/Project/StylishMen/List.aspx\",\"data\":{\"first\":{\"value\":\"[我是型男]报名审核通过！\",\"color\":\"#173177\"},\"keyword1\":{\"value\":\"我是型男\",\"color\":\"#173177\"},\"keyword2\":{\"value\":\"2017年6月7日\",\"color\":\"#173177\"},\"keyword3\":{\"value\":\"通过\",\"color\":\"#173177\"},\"remark\":{\"value\":\"您报的[我是型男]已经通过，快去看看吧！\",\"color\":\"#173177\"}}}";
        //gtCTjn4y5OwnTqALXuyE9MnX54ORJEhvc43SFcVi1ho
        //http://tm.lilanz.com/qywx/Project/StylishMen/List.aspx
        string dataMb = @"
            {{
              ""touser"": ""{0}"",
              ""template_id"": ""gtCTjn4y5OwnTqALXuyE9MnX54ORJEhvc43SFcVi1ho"",
              ""url"": ""{3}"",
              ""data"": {{
                ""first"": {{
                  ""value"": ""[我是型男]报名审核情况"",
                  ""color"": ""#173177""
                }},
                ""keyword1"": {{
                  ""value"": ""我是型男"",
                  ""color"": ""#173177""
                }},
                ""keyword2"": {{
                  ""value"": ""2017年6月13日-2017年7月20日"",
                  ""color"": ""#173177""
                }},
                ""keyword3"": {{
                  ""value"": ""{1}"",
                  ""color"": ""#173177""
                }},
                ""remark"": {{
                  ""value"": ""{2}"",
                  ""color"": ""#173177""
                }}
              }}
            }}
        ";
        string[] wxOpenids = wxOpenid.Split(',');
        string jsonStr = "{\"errcode\":\"0\",\"errmsg\":\"成功！\"}";
        string errcode = "0";
        string AreaID = "", data = "";
        string sql = "";
        string errorInfo = "";
        string conn = clsWXHelper.GetWxConn();
        DataTable dt;
        List<SqlParameter> para = new List<SqlParameter>();

        StringBuilder sbErrInfo = new StringBuilder() ;
        string ID,cname;
        int ErrCount = 0;
        using (LiLanzDALForXLM sqlhelper = new LiLanzDALForXLM(conn))
        {
            for (int i = 0; i < wxOpenids.Length; i++)
            {
                para.Clear();
                para = new List<SqlParameter>();
                sql = @"
                     SELECT TOP 1 a.AreaID,ID,Cname FROM dbo.xn_t_SigninUser a where a.wxOpenID=@wxOpenID 
                ";
                para.Add(new SqlParameter("@wxOpenID", wxOpenids[i]));
                errorInfo = sqlhelper.ExecuteQuerySecurity(sql, para, out dt);
                if (errorInfo != "")
                {
                    clsLocalLoger.WriteError(string.Concat("[我是型男]区域！错误：", errorInfo));
                    continue;
                }
                ID = Convert.ToString(dt.Rows[0]["ID"]);
                cname = Convert.ToString(dt.Rows[0]["Cname"]);
                AreaID = dt.Rows[0]["AreaID"].ToString();
                clsSharedHelper.DisponseDataTable(ref dt);
                data = string.Format(dataMb, wxOpenids[i], shzt, bz, VIPWebPath + "Project/StylishMen/List.aspx?aid=" + AreaID);
                using (clsJsonHelper json = clsWXHelper.SendTemplateMessage(access_token, data))
                {
                    if (json.GetJsonValue("errcode") != "0")
                    {
                        ErrCount++;
                        sbErrInfo.AppendFormat("[{0}]号参赛者[{1}]，推送失败：{2}\n", ID, cname, json.jSon);
                        continue;
                    }
                }
            }
        }
        if (ErrCount > 0)
        {
            sbErrInfo.Insert(0,string.Concat("注意：推送失败" ,ErrCount, "人！\n"));
            jsonStr = sbErrInfo.ToString();
            sbErrInfo.Length = 0;
        }
        context.Response.Write(jsonStr);  //clsNetExecute.HttpRequestToWX(url, data).jSon
        context.Response.End();
    }

    /// <summary>
    /// 按票票数显示数据或按票票数排序显示TOP X型男信息
    /// </summary>
    /// <param name="context"></param>
    public void LoadList(HttpContext context)
    {
        string openid = Convert.ToString(context.Session["openid"]);
        if (string.IsNullOrEmpty(openid))
        {
            WriteTimeOut();
            return;
        }
        else
        {
            string sql = "";
            string AreaID = Convert.ToString(context.Request["AreaID"]);
            string strName = "";
            string conn = clsWXHelper.GetWxConn();
            DataTable dt;
            string errorInfo = "";
            string TopCount = Convert.ToString(context.Request["TopCount"]);
            using (LiLanzDALForXLM sqlhelper = new LiLanzDALForXLM(conn))
            {
                List<SqlParameter> para = new List<SqlParameter>();
                if (string.IsNullOrEmpty(AreaID) == false)
                {
                    sql = @"
                    IF EXISTS (SELECT top 1 * FROM dbo.xn_t_BaseArea a WHERE a.ID=@ID)
                        SELECT 1 bs
                    ELSE
                        SELECT 0 bs
                ";
                    para.Add(new SqlParameter("@ID", AreaID));
                    //sql = string.Format(sql, AreaID);
                    errorInfo = sqlhelper.ExecuteQuerySecurity(sql, para, out dt);
                    if (errorInfo != "")
                    {
                        clsLocalLoger.WriteError(string.Concat("[我是型男]区域！错误：", errorInfo));
                        return;
                    }
                    if (dt.Rows[0]["bs"].ToString() == "0")
                    {
                        clsSharedHelper.DisponseDataTable(ref dt);
                        context.Response.Write("{\"errcode\":\"21\",\"errmsg\":\"赛区不存在\"}");
                        context.Response.End();
                    }
                    clsSharedHelper.DisponseDataTable(ref dt);
                    para.Clear();
                }
                else
                {
                    TopCount = "100";
                }

                if (string.IsNullOrEmpty(TopCount))
                {
                    strName = "按票票数显示数据";
                    sql = @"
                        SELECT a.Cname,a.ID,a.wxOpenID openid,b.Area,a.StoreName,a.MyImgURL1,a.MyImgURL2,a.TokenCount,b.Provinces
                        FROM xn_t_SigninUser a
                        INNER JOIN dbo.xn_t_BaseArea b ON a.AreaID=b.ID
                        WHERE a.IsActive=1 and a.shbs=1 ";
                }
                else
                {
                    strName = "按票票数排序显示TOP " + TopCount + "型男信息";
                    sql = @"
                        SELECT top (@TopCount) a.Cname,a.ID,a.wxOpenID openid,b.Area,a.StoreName,a.MyImgURL1,a.MyImgURL2,a.TokenCount,b.Provinces,c.CompanyName,c.StoreName
                        FROM xn_t_SigninUser a
                        INNER JOIN dbo.xn_t_BaseArea b ON a.AreaID=b.ID
                        INNER JOIN dbo.xn_t_BaseAreaStore c ON a.mdid=c.mdid AND a.AreaID=c.AreaID
                        WHERE a.IsActive=1 and a.shbs=1 ";
                    para.Add(new SqlParameter("@TopCount", Int32.Parse(TopCount)));
                }

                if (string.IsNullOrEmpty(AreaID) == false && AreaID != "73")
                {
                    sql = string.Concat(sql, " AND A.AreaID = @AreaID ");
                    para.Add(new SqlParameter("@AreaID", AreaID));
                }

                sql = string.Concat(sql, "   ORDER BY a.TokenCount DESC ");

                errorInfo = sqlhelper.ExecuteQuerySecurity(sql, para, out dt);
                if (errorInfo != "")
                {
                    clsSharedHelper.DisponseDataTable(ref dt);
                    clsLocalLoger.WriteError(string.Concat("[我是型男]", strName, "！错误：", errorInfo));
                    return;
                }
                string jsonStr = "{{\"errcode\": \"0\",\"errmsg\": \"读取成功！\",{0}}}";
                string data = sqlhelper.DataTableToJson(dt, "List", true);

                if (dt.Rows.Count > 0)
                {
                    jsonStr = string.Format(jsonStr, data.Substring(1, data.Length - 2));
                }
                else
                {
                    jsonStr = string.Format(jsonStr, "\"List\":[]");
                }
                clsSharedHelper.DisponseDataTable(ref dt);
                context.Response.Write(jsonStr);
                context.Response.End();
            }
        }
    }

    /// <summary>
    /// 保存
    /// </summary>
    /// <param name="context"></param>
    public void Submit(HttpContext context)
    {
        string openid = Convert.ToString(context.Session["openid"]);
        if (string.IsNullOrEmpty(openid))
        {
            WriteTimeOut();
            return;
        }
        else
        {
            DateTime bStart = DateTime.Parse(bmStart);
            DateTime bEnd = DateTime.Parse(bmEnd);

            if (DateTime.Parse(DateTime.Now.ToString("yyyy-MM-dd")) < bStart || DateTime.Parse(DateTime.Now.ToString("yyyy-MM-dd")) > bEnd)
            {
                context.Response.Write(string.Concat("{\"errcode\":\"3\",\"errmsg\":\"报名时间为：<br>", bStart.ToString("M月d日"), " 至 ", bEnd.ToString("M月d日"), "\"}"));
                context.Response.End();
                return;
            }
            string mdid = "", Cname = "", DPCname = "", Phone = "", ISay = "", Idea = "", MyImgURL1 = "", MyImgURL2 = "", userOpenId = "";
            userOpenId = context.Session["openid"].ToString();
            mdid = HttpUtility.UrlDecode(context.Request["mdid"].ToString());
            Cname = HttpUtility.UrlDecode(context.Request["Cname"].ToString());
            DPCname = HttpUtility.UrlDecode(context.Request["DPCname"].ToString());
            Phone = HttpUtility.UrlDecode(context.Request["Phone"].ToString());
            ISay = HttpUtility.UrlDecode(context.Request["ISay"].ToString());
            Idea = HttpUtility.UrlDecode(context.Request["Idea"].ToString());
            MyImgURL1 = HttpUtility.UrlDecode(context.Request["MyImgURL0"].ToString());
            MyImgURL2 = HttpUtility.UrlDecode(context.Request["MyImgURL1"].ToString());

            string conn = clsWXHelper.GetWxConn();
            DataTable dt;
            using (LiLanzDALForXLM sqlhelper = new LiLanzDALForXLM(conn))
            {
                List<SqlParameter> para = new List<SqlParameter>();
                string sql = @"
                    IF EXISTS (SELECT top 1 a.ID FROM dbo.xn_t_SigninUser a WHERE (a.wxOpenID=@wxOpenID or Phone=@Phone) and a.IsActive=1)
                        SELECT 1 bs
                    ELSE
                    BEGIN
                        SELECT 0 bs
                    END
                ";
                para.Add(new SqlParameter("@wxOpenID", userOpenId));
                para.Add(new SqlParameter("@Phone", Phone));
                //sql = string.Format(sql, userOpenId, Cname, DPCname, Phone, ISay, MyImgURL1, MyImgURL2, mdid);
                string errorInfo = sqlhelper.ExecuteQuerySecurity(sql, para, out dt);
                if (errorInfo != "")
                {
                    clsLocalLoger.WriteError(string.Concat("[我是型男]查询是否已经报名！错误：", errorInfo));
                    return;
                }
                if (dt.Rows[0]["bs"].ToString() == "0")
                {
                    para.Clear();
                    clsSharedHelper.DisponseDataTable(ref dt);
                    sql = @"
                        INSERT INTO dbo.xn_t_SigninUser(tzid, AreaID, StoreName, mdid, wxOpenID, Cname, DPCname, Phone, ISay, Idea, MyImgURL1, MyImgURL2)
                        SELECT top 1 a.tzid, a.AreaID, a.StoreName, a.mdid, @wxOpenID, @Cname, @DPCname, @Phone, @ISay, @Idea, @MyImgURL1, @MyImgURL2
                        FROM xn_t_BaseAreaStore a
                        WHERE a.mdid=@mdid
                    ";
                    para.Add(new SqlParameter("@wxOpenID", userOpenId));
                    para.Add(new SqlParameter("@Cname", Cname));
                    para.Add(new SqlParameter("@DPCname", DPCname));
                    para.Add(new SqlParameter("@Phone", Phone));
                    para.Add(new SqlParameter("@ISay", ISay));
                    para.Add(new SqlParameter("@Idea", Idea));
                    para.Add(new SqlParameter("@MyImgURL1", MyImgURL1));
                    para.Add(new SqlParameter("@MyImgURL2", MyImgURL2));
                    para.Add(new SqlParameter("@mdid", mdid));
                    errorInfo = sqlhelper.ExecuteNonQuerySecurity(sql, para);
                    if (errorInfo != "")
                    {
                        clsLocalLoger.WriteError(string.Concat("[我是型男]报名！错误：", errorInfo));
                        return;
                    }
                    context.Response.Write("{\"errcode\":\"0\",\"errmsg\":\"报名成功，等待审核\"}");
                    context.Response.End();
                }
                else
                {
                    clsSharedHelper.DisponseDataTable(ref dt);
                    context.Response.Write("{\"errcode\":\"12\",\"errmsg\":\"您已经报名过了或改电话已被使用\"}");
                    context.Response.End();
                }
            }
        }
    }

    private void WriteTimeOut()
    {
        clsSharedHelper.WriteInfo("{\"errcode\":\"304\",\"errmsg\":\"操作超时，请重新打开页面！\"}");
        return;
    }

    /// <summary>
    /// 投票
    /// </summary>
    /// <param name="Openid">被投票的参赛用户的微信openid</param>
    /// <param name="context"></param>
    public void SetToken(string Openid, HttpContext context)
    {
        if (DateTime.Now.Hour >= stopHourBegin && DateTime.Now.Hour <= stopHourEnd)
        {
            context.Response.Write(string.Concat("{\"errcode\":\"3\",\"errmsg\":\"" , stopMsg , "\"}"));
            context.Response.End();
            return;
        }
        
        //context.Response.Write(string.Concat("{\"errcode\":\"3\",\"errmsg\":\"系统维护中，暂时不允许投票！\"}"));
        //context.Response.End();
        //return;


        string openid = Convert.ToString(context.Session["openid"]);
        if (string.IsNullOrEmpty(openid))
        {
            WriteTimeOut();
            return;
        }
        else
        {
            DateTime tStart = DateTime.Parse(tpStart);
            DateTime tEnd = DateTime.Parse(tpEnd);

            if (DateTime.Parse(DateTime.Now.ToString("yyyy-MM-dd")) < tStart || DateTime.Parse(DateTime.Now.ToString("yyyy-MM-dd")) > tEnd)
            {
                context.Response.Write(string.Concat("{\"errcode\":\"3\",\"errmsg\":\"投票时间为：<br>", tStart.ToString("M月d日"), " 至 ", tEnd.ToString("M月d日"), "\"}"));
                context.Response.End();
                return;
            }
            string userOpenId = ""; //当前用户的微信openid
            userOpenId = context.Session["openid"].ToString();
            string conn = clsWXHelper.GetWxConn();
            DataTable dt;
            using (LiLanzDALForXLM sqlhelper = new LiLanzDALForXLM(conn))
            {
                List<SqlParameter> para = new List<SqlParameter>();
                string sql = @"
                    SELECT top 1 a.ID,a.shbs
                    FROM dbo.xn_t_SigninUser a
                    WHERE a.wxOpenID=@wxOpenID and a.IsActive=1
                ";
                para.Add(new SqlParameter("@wxOpenID", Openid));
                string errorInfo = sqlhelper.ExecuteQuerySecurity(sql, para, out dt);
                if (errorInfo != "")
                {
                    clsSharedHelper.DisponseDataTable(ref dt);
                    clsLocalLoger.WriteError(string.Concat("[我是型男]查询所投的人是否存在！错误：", errorInfo));
                    return;
                }
                if (dt.Rows.Count == 0)
                {
                    clsSharedHelper.DisponseDataTable(ref dt);
                    context.Response.Write("{\"errcode\":\"1\",\"errmsg\":\"型男不存在\"}");
                    context.Response.End();
                }
                else
                {
                    para.Clear();
                    string SendToUserID = dt.Rows[0]["ID"].ToString();
                    if (dt.Rows[0]["shbs"].ToString() == "True")
                    {
                        clsSharedHelper.DisponseDataTable(ref dt);
                        //IF EXISTS (SELECT top 1 b.ID FROM dbo.xn_t_SigninUser a INNER JOIN dbo.xn_t_FansToken b ON a.AreaID=b.AreaID
                        sql = @"
                            SELECT top 1 b.ID FROM xn_t_FansToken b
                                       WHERE b.FansOpenid=@FansOpenid and CONVERT(CHAR(8),b.CreateTime,112)=CONVERT(CHAR(8),GETDATE(),112)
                        ";
                        //para.Add(new SqlParameter("@wxOpenID", Openid));
                        para.Add(new SqlParameter("@FansOpenid", userOpenId));
                        //sql = string.Format(sql, Openid, userOpenId);
                        object objID = null;
                        errorInfo = sqlhelper.ExecuteQueryFastSecurity(sql, para, out objID);
                        if (errorInfo != "")
                        {
                            clsLocalLoger.WriteError(string.Concat("[我是型男]查询粉丝是否投票！错误：", errorInfo));
                            return;
                        }
                        if (objID != null)
                        {
                            context.Response.Write("{\"errcode\":\"3\",\"errmsg\":\"您今天已投过票了，明天再来吧~\"}");
                            return;
                        }

                        para.Clear();
                        sql = @"
                            SELECT COUNT(1) ps
                            FROM xn_t_FansToken a
                            WHERE a.CreateTime > DATEADD(HOUR,-1,GETDATE()) AND a.SendToOpenid=@wxOpenID
                        ";
                        para.Add(new SqlParameter("@wxOpenID", Openid));
                        errorInfo = sqlhelper.ExecuteQuerySecurity(sql, para, out dt);
                        if (errorInfo != "")
                        {
                            clsSharedHelper.DisponseDataTable(ref dt);
                            clsLocalLoger.WriteError(string.Concat("[我是型男]查询之前1小时的投票数！错误：", errorInfo));
                            return;
                        }
                        if (Int32.Parse(dt.Rows[0]["ps"].ToString()) >= zps )
                        {
                            clsSharedHelper.DisponseDataTable(ref dt);
                            context.Response.Write("{\"errcode\":\"3\",\"errmsg\":\"该选手人气太火爆啦~~等一会再来吧\"}");
                            return;
                        }

                        para.Clear();
                        sql = @"
	                        INSERT INTO dbo.xn_t_FansToken(CreateTime, AreaID, FansOpenid, SendToUserID, SendToOpenid)
	                        SELECT top 1 GETDATE() ,a.AreaID ,@FansOpenid ,a.ID ,a.wxOpenID
	                        FROM dbo.xn_t_SigninUser a
	                        WHERE a.wxOpenID=@wxOpenID and a.IsActive=1

                            UPDATE xn_t_SigninUser SET TokenCount=TokenCount+1 WHERE wxOpenID=@wxOpenID and IsActive=1
                        ";
                        para.Add(new SqlParameter("@wxOpenID", Openid));
                        para.Add(new SqlParameter("@FansOpenid", userOpenId));
                        errorInfo = sqlhelper.ExecuteNonQuerySecurity(sql, para);
                        if (errorInfo != "")
                        {
                            clsLocalLoger.WriteError(string.Concat("[我是型男]投票！错误：", errorInfo));
                            return;
                        }
                        context.Response.Write("{\"errcode\":\"0\",\"errmsg\":\"投票成功\"}");

                        clsSharedHelper.DisponseDataTable(ref dt);
                        context.Response.End();
                    }
                    else
                    {
                        clsSharedHelper.DisponseDataTable(ref dt);
                        context.Response.Write("{\"errcode\":\"2\",\"errmsg\":\"型男未通过审核\"}");
                        context.Response.End();
                    }
                }
            }
        }
    }

    //    /// <summary>
    //    /// 获取型男信息
    //    /// </summary>
    //    /// <param name="Openid">微信openid</param>
    //    /// <param name="context"></param>
    //    public void LoadInfo(string Openid, HttpContext context)
    //    {
    //        string openid = Convert.ToString(context.Session["openid"]);
    //        if (string.IsNullOrEmpty(openid))
    //        {
    //            WriteTimeOut();
    //            return;
    //        }
    //        else
    //        {
    //            string conn = clsWXHelper.GetWxConn();
    //            DataTable dt;
    //            using (LiLanzDALForXLM sqlhelper = new LiLanzDALForXLM(conn))
    //            {
    //                List<SqlParameter> para = new List<SqlParameter>();
    //                string sql = @"
    //                    SELECT top 1 a.ID,a.wxOpenID openid,a.AreaID,b.Provinces ProvincesName,b.Area,a.StoreName,a.MyImgURL1,a.MyImgURL2,a.ISay,a.TokenCount,a.shbs
    //                    FROM dbo.xn_t_SigninUser a
    //                    INNER JOIN dbo.xn_t_BaseArea b ON a.AreaID=b.ID
    //                    WHERE a.wxOpenID=@wxOpenID and a.IsActive=1
    //                ";
    //                para.Add(new SqlParameter("@wxOpenID", Openid));
    //                string errorInfo = sqlhelper.ExecuteQuerySecurity(sql, para, out dt);
    //                if (errorInfo != "")
    //                {
    //                    clsLocalLoger.WriteError(string.Concat("[我是型男]获取型男信息！错误：", errorInfo));
    //                    return;
    //                }
    //                if (dt.Rows.Count == 0)
    //                {
    //                    clsSharedHelper.DisponseDataTable(ref dt);
    //                    context.Response.Write("{\"errcode\":\"1\",\"errmsg\":\"型男不存在\"}");
    //                    context.Response.End();
    //                }
    //                else
    //                {
    //                    string jsonStr = "";
    //                    if (dt.Rows[0]["shbs"].ToString() == "True")
    //                    {
    //                        string jsonMb = "{{\"ID\":\"{0}\",\"openid\":\"{1}\",\"AreaID\":\"{2}\",\"ProvincesName\":\"{3}\",\"Area\":\"{4}\",\"StoreName\":\"{5}\",\"MyImgURL1\":\"{6}\",\"MyImgURL2\":\"{7}\",\"ISay\":\"{8}\",\"TokenCount\":\"{9}\",\"errcode\":\"{10}\",\"errmsg\":\"{11}\"}}";
    //                        jsonStr = string.Format(jsonMb, dt.Rows[0]["ID"].ToString(), dt.Rows[0]["openid"].ToString(),
    //                            dt.Rows[0]["AreaID"].ToString(), dt.Rows[0]["ProvincesName"].ToString(), dt.Rows[0]["Area"].ToString(),
    //                            dt.Rows[0]["StoreName"].ToString(), dt.Rows[0]["MyImgURL1"].ToString(), dt.Rows[0]["MyImgURL2"].ToString(),
    //                            dt.Rows[0]["ISay"].ToString(), dt.Rows[0]["TokenCount"].ToString(), "0", "读取成功");
    //                    }
    //                    else
    //                    {
    //                        jsonStr = "{\"errcode\":\"2\",\"errmsg\":\"型男未通过审核\"}";
    //                    }
    //                    clsSharedHelper.DisponseDataTable(ref dt);
    //                    context.Response.Write(jsonStr);
    //                    context.Response.End();
    //                }
    //            }
    //        }
    //    }

    ///// <summary>
    ///// 返回的字符串如果包含换行，就需要替换它
    ///// </summary>
    ///// <param name="str"></param>
    ///// <returns></returns>
    //public string getJsonVal(string str)
    //{
    //    str = str.Replace("/n", "<br>");
    //    str = str.Replace("/r", "<br>");
    //    str = str.Replace(@"""", "'");

    //    return str;        
    //}

    public bool IsReusable
    {
        get
        {
            return false;
        }
    }

    //保存图片
    private string saveMyImgs(String PicBase, String rotate, HttpContext context)
    {
        string rt = "";
        string myFolder = DateTime.Now.ToString("yyyyMM");
        string pathStr = "upload/StylishMen/" + myFolder + "/";
        string path = HttpContext.Current.Server.MapPath("~/" + pathStr);
        string myPath = HttpContext.Current.Server.MapPath("~/" + pathStr + "my/");
        String strPath = Path.GetDirectoryName(path);
        String filename = DateTime.Now.ToString("yyyyMMddHHmmssfff") + ".jpg";
        if (!Directory.Exists(strPath))
        {
            Directory.CreateDirectory(strPath);
        }

        rt = Base64StringToImage(PicBase, path, filename, rotate);


        if (!rt.Equals(""))
        {
            return "0|" + rt;
        }
        strPath = Path.GetDirectoryName(myPath);
        if (!Directory.Exists(strPath))
        {
            Directory.CreateDirectory(strPath);
        }
        rt = MakeImage(path + filename, myPath + filename, 200);
        if (rt.Equals(""))
        {
            return string.Concat("1|", pathStr, "my/", filename);
        }
        return "0|" + rt;
    }

    /// <summary>
    /// 处理图片成指定尺寸()正方形 方便后期的直接使用；
    /// By:xlm 由于处理成正方形可能导致图片呈现效果不理想，因此缩放即可，但是不填充成正方形。
    /// </summary>
    /// <param name="SourceImage">源图片的文件位置</param>
    /// <param name="SaveImage">图片文件保存的目标位置</param>
    /// <param name="setWidth">设置的宽度，以宽度为基准</param>
    /// <returns></returns>
    public string MakeImage(string SourceImage, string SaveImage, int setWidth)
    {
        int imgWidth = setWidth; //缩放以宽度为基准
        try
        {
            Bitmap myBitMap = new Bitmap(SourceImage);
            int pWidth = myBitMap.Width;
            int pHeight = myBitMap.Height;
            int draX = 0;
            int draY = 0;

            double pcent = pWidth * 1.0 / imgWidth; //得到缩放比分比
            int imgHeight = Convert.ToInt32(Math.Round(pHeight * 1.0 / pcent));

            Bitmap eImage = new Bitmap(imgWidth, imgHeight);
            Graphics g = Graphics.FromImage(eImage);
            g.DrawImage(myBitMap, draX, draY, imgWidth, imgHeight);
            g.Save();
            myBitMap.Dispose();

            eImage.Save(SaveImage, System.Drawing.Imaging.ImageFormat.Jpeg);
            g.Dispose();

            return "";
        }
        catch (Exception ex)
        {
            return "处理图片失败！错误：" + ex.Message;
        }
    }

    //图片处理上传
    private String Base64StringToImage(string PicBase64, string path, string filename, string rotate)
    {
        try
        {
            byte[] arr = Convert.FromBase64String(PicBase64);
            MemoryStream ms = new MemoryStream(arr);
            using (Bitmap bmp = new Bitmap(ms))
            {
                switch (rotate)
                {
                    case "2":
                        bmp.RotateFlip(RotateFlipType.RotateNoneFlipX);
                        break;
                    case "3":
                        bmp.RotateFlip(RotateFlipType.Rotate180FlipNone);
                        break;
                    case "4":
                        bmp.RotateFlip(RotateFlipType.RotateNoneFlipY);
                        break;
                    case "5":
                        bmp.RotateFlip(RotateFlipType.Rotate90FlipX);
                        break;
                    case "6":
                        bmp.RotateFlip(RotateFlipType.Rotate90FlipNone);
                        break;
                    case "7":
                        bmp.RotateFlip(RotateFlipType.Rotate270FlipX);
                        break;
                    case "8":
                        bmp.RotateFlip(RotateFlipType.Rotate270FlipNone);
                        break;
                    default:
                        break;
                }

                bmp.Save(path + filename, System.Drawing.Imaging.ImageFormat.Jpeg);
                ms.Close();
                return "";
            }
        }
        catch (Exception ex)
        {
            return "Base64StringToImage 转换失败\nException：" + ex.Message;
        }
    }
}