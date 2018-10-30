<%@ Page Language="C#" Debug="true" %>
<%@ Import Namespace="nrWebClass"  %>
<%@ Import Namespace="System.Collections.Generic" %>
<%@ Import Namespace="System.Data.SqlClient" %>
<%@ Import Namespace="System.Data" %>
<%@ Import Namespace="System.IO" %>
<%@ Import Namespace="Newtonsoft.Json" %>

<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">

<script runat="server">
    string OAConnStr ="server=192.168.35.10;uid=ABEASD14AD;pwd=+AuDkDew;database=tlsoft";// clsConfig.GetConfigValue("OAConnStr"); 
   // "server=192.168.35.10;uid=ABEASD14AD;pwd=+AuDkDew;database=tlsoft";
   // string OAConnStr = "server=192.168.35.23;uid=lllogin;pwd=rw1894tla;database=tlsoft";
    protected void Page_Load(object sender, EventArgs e)
    {
        string userid = Convert.ToString(Session["userid"]);
        string rt, ctrl, docid, para;
        ctrl = Convert.ToString(Request.Params["ctrl"]);
        docid = Convert.ToString(Request.Params["docid"]);
        if (! string.IsNullOrEmpty(docid))
        {
            string errInfo;
            DataTable dt;
            string mysql =string.Format( "SELECT tzid FROM dbo.fl_t_flowRelation WHERE docID='{0}'",docid);
            using (LiLanzDALForXLM dal = new LiLanzDALForXLM(OAConnStr))
            {
                errInfo = dal.ExecuteQuery(mysql, out dt);
                if (errInfo == "" && dt.Rows.Count > 0)
                {
                    HttpContext.Current.Session["userssid"] = Convert.ToString(dt.Rows[0]["tzid"]);
                }
            }
        }
        switch (ctrl)
        {
            case "db": rt = DBList(userid); 
                break;
            case "aud":
                string date = Convert.ToString(Request.Params["date"]);
                rt = Audited(userid, date);
                break;
            case "pastNode": 
                 docid = Convert.ToString(Request.Params["docid"]);
                rt = pastNode(docid);
                break;
            case "getNextNode":
                 docid = Convert.ToString(Request.Params["docid"]);
                 rt = getNextNode(docid);
                 break;
            case "nodeUser":
                 docid = Convert.ToString(Request.Params["docid"]);
                 string nodeid = Convert.ToString(Request.Params["nodeid"]);
                 rt = getNextUser(docid,nodeid);
                 break;
            case "audisend":
                  para = Convert.ToString(Request.Params["parastr"]);
                  rt=AudiSend(para);;
                 //rt = "para:" + para;
                break;
            case "getReBackInfo":
                docid = Convert.ToString(Request.Params["docid"]);
                rt = GetReBackInfo(docid);
                break;
            case "returnback":
                para = Convert.ToString(Request.Params["parastr"]);
                rt = ReturnBack(para);
               // rt = para;
                break;
            case "version":rt="version 1.0";
                break;
            default: rt = clsNetExecute.Error + "传入参数有误！";
                break;
        }

        clsSharedHelper.WriteInfo(rt);
    }
    private string ReturnBack(string paraStr)
    {
        clsJsonHelper paraJson=clsJsonHelper.CreateJsonHelper(paraStr);
        
        SqlParameter[] paramters = new SqlParameter[]{
                new SqlParameter("@docID", paraJson.GetJsonValue("docid")),
                new SqlParameter("@returnNodeID", paraJson.GetJsonValue("returnNodeID")),
                new SqlParameter("@returnNodeUser",  paraJson.GetJsonValue("returnNodeUser")),
                new SqlParameter("@opinion",  paraJson.GetJsonValue("opinion")),
                new SqlParameter("@userid", Session["userid"]),
                new SqlParameter("@userssid", Session["userssid"]),
                new SqlParameter("@zbid",  Session["zbid"]),
                new SqlParameter("@xtlb", Session["xtlb"]),
                new SqlParameter("@username", Session["username"]),
                new SqlParameter("@pldocid", ""),
                new SqlParameter("@val","")
            };
        nrWebClass.LiLanzDAL sqlhelper = new nrWebClass.LiLanzDAL();
        sqlhelper.ConnectionString = OAConnStr;
        paramters[10].Direction = ParameterDirection.ReturnValue;
        sqlhelper.ExecuteNonQuery(@"flow_up_sendReturnNode", CommandType.StoredProcedure, paramters);
        paraJson.Dispose();

        if (paramters[10].Value.ToString() == "1")
            return clsNetExecute.Successed;
        else
            return clsNetExecute.Error;
    }
    private string GetReBackInfo(string docid)
    {
        string errInfo, rt = "";
        DataTable dt;
        clsJsonHelper rebackJoson;
        string mysql = string.Format(" SELECT currentNode FROM dbo.fl_t_flowRelation WHERE docid={0}",docid);
        using (LiLanzDALForXLM dal = new LiLanzDALForXLM(OAConnStr))
        {
            errInfo = dal.ExecuteQuery(mysql, out dt);
          
            if (errInfo != "")
            {
                return errInfo;
            }
            else if (dt.Rows.Count < 1)
            {
                return clsNetExecute.Error + "非法访问！";
            }
            string currentNode=Convert.ToString(dt.Rows[0]["currentNode"]);
            mysql = string.Format("flow_up_getReturnNode {0},{1}", docid, currentNode);
            errInfo = dal.ExecuteQuery(mysql, out dt);
            if (errInfo != "")
            {
                return errInfo;

            }
            else if (dt.Rows.Count < 1)
            {
                return clsNetExecute.Error + "无可退节点";
            }
            rebackJoson = clsJsonHelper.CreateJsonHelper(DataTableToJson("returnNode",dt));
            rt = rebackJoson.jSon;
            mysql = string.Format("flow_up_getReturnNodeUser {0},{1}", docid, currentNode);
            errInfo = dal.ExecuteQuery(mysql, out dt);
            if (errInfo != "")
            {
                return errInfo;

            }
            Dictionary<string, object> duser = JsonConvert.DeserializeObject<Dictionary<string, object>>(DataTableToJson("ReturnNodeUser", dt));
            rebackJoson.AddJsonVar("ReturnNodeUser", Convert.ToString(duser["ReturnNodeUser"]),false);
            duser.Clear();
            rt = rebackJoson.jSon;
        }
        return rt;
    }
    private string AudiSend(string parastr)
    {
        clsJsonHelper parajson = clsJsonHelper.CreateJsonHelper(parastr);
        string errInfo, rt = "";
        string flow_pldocid = "";//批量审批文档id
        DataTable dt;
        string mysql = string.Format("select currentNode,flag from fl_t_flowRelation where docID={0}", parajson.GetJsonValue("docid"));
        using (LiLanzDALForXLM dal = new LiLanzDALForXLM(OAConnStr))
        {
            errInfo = dal.ExecuteQuery(mysql, out dt);

            if (errInfo != "")
            {
                return errInfo;
            }
            else if (dt.Rows.Count < 1)
            {
                return clsNetExecute.Error + "非法访问！";
            }

            if (Convert.ToUInt32(dt.Rows[0]["flag"]) == 2)
            {
                mysql = @"DECLARE @result int ; EXEC @result=flow_up_end {0},{1},'{2}',{3},{4},'{5}','{6}','{7}' ; SELECT @result ;";
                mysql = string.Format(mysql, parajson.GetJsonValue("docid"), Session["userid"],
                    Session["username"], Session["userssid"], Session["zbid"], Session["xtlb"], parajson.GetJsonValue("opinion"), flow_pldocid);
              
            }
            else
            {
                mysql = @"DECLARE @result int ; EXEC @result=flow_up_sendNextSingle '{0}', '{1}', '{2}', 
                         '{3}', '{4}', '{5}', '{6}', '{7}', '{8}', '{9}';SELECT @result ;";
                mysql = string.Format(mysql, parajson.GetJsonValue("docid"), parajson.GetJsonValue("nextNode"), parajson.GetJsonValue("nextNodeUser"), parajson.GetJsonValue("opinion"),
                    Session["username"], Session["userid"], Session["userssid"], Session["zbid"], Session["xtlb"], flow_pldocid);
            }
            dt.Clear();
            errInfo = dal.ExecuteQuery(mysql, out dt);
            if (errInfo != "")
            {
                return errInfo;
            }
            if (Convert.ToUInt32(dt.Rows[0][0]) == 1)
            {
                rt = clsNetExecute.Successed;
            }
            else
            {
                rt =clsNetExecute.Error +"办理失败";
            }
        }
        return rt;
    }
    private string getNextNode(string docid)
    {
        string mysql = string.Format("SELECT flowid,flowname,currentNode,nodebbid,dxid FROM dbo.f_flow_getFlowData({0})", docid);
        string errInfo,rt="";
        DataTable dt;
        clsJsonHelper json = new clsJsonHelper();
        using (LiLanzDALForXLM dal = new LiLanzDALForXLM(OAConnStr))
        {
            errInfo = dal.ExecuteQuery(mysql,out dt);
            if (errInfo == "" && dt.Rows.Count>0)
            {
                mysql = string.Format("exec flow_up_getNextNode '{0}', '{1}', '{2}', '{3}', '{4}', '{5}', '{6}'", docid, dt.Rows[0]["currentNode"],
            Convert.ToString(Session["userssid"]), Convert.ToString(Session["zbid"]), Convert.ToString(Session["userid"]), Convert.ToString(Session["username"]), Convert.ToString(Session["xtlb"]));
                dt.Clear();
                errInfo = dal.ExecuteQuery(mysql, out dt);
                if (errInfo == "")
                {
                    rt = DataTableToJson("nextNode", dt);
                    json.AddJsonVar("nextNode",rt,false);
                    if (dt.Rows.Count > 0)
                    {
                        rt = getNextUser(docid,Convert.ToString(dt.Rows[0]["nodeID"]));
                        json.AddJsonVar("nextNodeUser", rt,false);
                    }
                }
            }
            else if (dt.Rows.Count < 1)
            {
                errInfo = clsNetExecute.Error+"未找到下一节点";
            }
            if (errInfo != "")
            {
                rt = errInfo;
            }
            else
            {
                rt = json.jSon;
                json.Dispose();
            }
        }
        return rt;
    }
    private string getNextUser(string docid,string nodeid)
    {
        string mysql = string.Format("exec flow_up_getNodeUser '{0}', '{1}', '{2}', '{3}', '{4}', '{5}', '{6}'", docid,nodeid,
                Convert.ToString(Session["userssid"]), Convert.ToString(Session["zbid"]), Convert.ToString(Session["userid"]), Convert.ToString(Session["username"]), Convert.ToString(Session["xtlb"]));
        string errInfo,rt="";
        DataTable dt;
        using (LiLanzDALForXLM dal = new LiLanzDALForXLM(OAConnStr))
        {
            errInfo = dal.ExecuteQuery(mysql, out dt);
        }
        if (errInfo == "")
        {
            rt = DataTableToJson("nextNodeUser", dt);
        }
        else
        {
            rt = errInfo;
        }
        return rt;
    }
    private string pastNode(string docid)
    {
        int id;
        if (!Int32.TryParse(docid,out id))
        {
            return clsNetExecute.Error + "不合法参数";
        }
        string errInfo, rt;
        string mysql = @" SELECT u.cname,a.dt,b.nodename
                            FROM fl_t_flowdata a INNER JOIN fl_t_nodeConfig b ON a.parentData=b.nodeid
                            INNER JOIN t_user u ON a.data=u.id 
                            WHERE docid=@id AND datatype in ('pasttransactor','currentTransactor')";
        DataTable dt;
        List<SqlParameter> para = new List<SqlParameter>();
        para.Add(new SqlParameter("@id", id));
        using (LiLanzDALForXLM dal = new LiLanzDALForXLM(OAConnStr))
        {
            errInfo = dal.ExecuteQuerySecurity(mysql, para, out dt);
        }
        if (errInfo != "")
        {
            rt = errInfo;
        }
        else
        {
            rt = DataTableToJson("rows", dt);
        }
        return rt;
    }
    private string Audited(string userid, string date)
    {
        DateTime mydate;
        if (! DateTime.TryParse(date,out mydate))
        {
            return clsNetExecute.Error + "日期格式不正确";
        }
        string errInfo, rt;
        string mysql = @" SELECT distinct  t1.docID docid,t2.creator,t3.bName,t2.created,t3.otherURL,t3.bidNum,t2.dxid,t2.flowid
                         FROM fl_t_flowdata as t1 INNER join fl_t_flowRelation as t2 on t1.docid=t2.docid
                         INNER JOIN t_FlowTableReation t3 ON t2.flowid=t3.flowid
                         WHERE t1.datatype in ('pasttransactor','currentTransactor') and t1.data=@userid  
                         AND t1.dt BETWEEN @date AND DATEADD(DAY,1,@date) 
                         ORDER BY t1.docID DESC";
        DataTable dt;
        List<SqlParameter> para = new List<SqlParameter>();
        para.Add(new SqlParameter("@userid", userid));
        para.Add(new SqlParameter("@date", date));
        using (LiLanzDALForXLM dal = new LiLanzDALForXLM(OAConnStr))
        {
            errInfo = dal.ExecuteQuerySecurity(mysql, para, out dt);
        }
        if (errInfo != "")
        {
            rt = errInfo;
        }
        else
        {
            rt = DataTableToJson("rows", dt);
        }
        return rt;
    }
    private string DBList(string userid)
    {
        string errInfo,rt;
        string mysql = @"select fl.docid,fl.dxid,fl.flowid,fl.creator,fl.created,fl.currentNodeName,t.bidNum,t.bName,t.otherURL,t.height,t.width,fl.flag
                        from fl_t_flowRelation fl inner join t_FlowTableReation t on fl.flowid=t.flowid
                        where fl.flag in(0,2,3) and currentuserid=@userid
                        order by fl.created DESC";
        DataTable dt;
        List<SqlParameter> para = new List<SqlParameter>();
        para.Add(new SqlParameter("@userid", userid));
        using (LiLanzDALForXLM dal = new LiLanzDALForXLM(OAConnStr))
        {
            errInfo = dal.ExecuteQuerySecurity(mysql, para, out dt);
        }
        if (errInfo != "")
        {
           rt=errInfo;
        }
        else
        {
            rt = DataTableToJson("rows",dt);
        }
        return rt;
    }
    
    
    /// <summary>
    /// datatable转成json格式
    /// </summary>
    /// <param name="jsonName">转换后的json名称</param>
    /// <param name="dt">待转数据表</param>
    /// <returns></returns>
    public static string DataTableToJson(string jsonName, DataTable dt)
    {
        StringBuilder Json = new StringBuilder();
        Json.Append("{\"" + jsonName + "\":[");
        if (dt.Rows.Count > 0)
        {
            for (int i = 0; i < dt.Rows.Count; i++)
            {
                Json.Append("{");
                for (int j = 0; j < dt.Columns.Count; j++)
                {
                    Json.Append("\"" + dt.Columns[j].ColumnName.ToString() + "\":\"" + dt.Rows[i][j].ToString() + "\"");
                    if (j < dt.Columns.Count - 1)
                    {
                        Json.Append(",");
                    }
                }
                Json.Append("}");
                if (i < dt.Rows.Count - 1)
                {
                    Json.Append(",");
                }
            }
        }
        Json.Append("]}");
        return Json.ToString();
    }
</script>

<html xmlns="http://www.w3.org/1999/xhtml">
<head id="Head1" runat="server">
</head>
 <body>
 </body>
</html>
