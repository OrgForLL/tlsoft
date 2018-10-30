<%@ Page Language="C#" Debug="true" %>
<%@ Import Namespace="System.IO"  %>
<%@ Import Namespace="nrWebClass"  %>
<%@ Import Namespace="System.Data" %>
<%@ Import Namespace="System.Data.SqlClient" %>
<%@ Import Namespace="System.Collections.Generic" %>
<%@ Import Namespace="System.Web" %>
<%@ Import Namespace="Newtonsoft.Json" %>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">

<script runat="server">
    string OAConnStr = "server=192.168.35.10;uid=ABEASD14AD;pwd=+AuDkDew;database=tlsoft";
    protected void Page_Load(object sender, EventArgs e)
    {
        aa();
        string para = Request.Url.PathAndQuery;
        string postPara = PostInput();
        if(!string.IsNullOrEmpty(postPara)){
            para = string.Concat(para,postPara); 
        }
        clsLocalLoger.Log(para);
        string rt = "{\"result\":{\"code\":\"200\",\"msg\":\"请求成功\",\"info\":{}}}";
        Response.Write(rt);
        Response.End();
    }
    // 获取POST返回来的数据  
    private string PostInput()
    {
        try
        {
            System.IO.Stream s = Request.InputStream;
            int count = 0;
            byte[] buffer = new byte[1024];
            StringBuilder builder = new StringBuilder();
            while ((count = s.Read(buffer, 0, 1024)) > 0)
            {
                builder.Append(Encoding.UTF8.GetString(buffer, 0, count));
            }
            s.Flush();
            s.Close();
            s.Dispose();
            return builder.ToString();
        }
        catch (Exception ex)
        { throw ex; }
    }
    private void aa()
    {
        //2016-10-12 01:29:33 - /QYWX/project/MyFabricScan/MyFabricNotice.aspx?crtl=scan&userKey=1042962&taskKey=1012721&fabricKey=1083703
        string interfaceCode = Convert.ToString(Request.Params["crtl"]);
        string usrKey = Convert.ToString(Request.Params["userKey"]);
        string fabricKey = Convert.ToString(Request.Params["fabricKey"]);
        string taskKey = Convert.ToString(Request.Params["taskKey"]);
        string sql1 = string.Format("select signature from t_user where signature like '%{0}%' and isnull(signature,'')<>''", usrKey);
        clsLocalLoger.WriteInfo(string.Format("接口页面被访问：interfaceCode：{0},usrKey:{1},fabricKey:{2},taskKey:{3}", interfaceCode, usrKey, fabricKey, taskKey));
        string errInfo;
        DataTable dt;
        using (LiLanzDALForXLM dal = new LiLanzDALForXLM(OAConnStr))
        {
            errInfo = dal.ExecuteQuery(sql1, out dt);
        }
        FBC fbc;
        if (errInfo != "")
        {
            clsSharedHelper.WriteInfo(errInfo);
            return;
        }
        else if (dt.Rows.Count < 1)
        {
            fbc = new FBC();
        }
        else
        {
            Dictionary<string, string> info1 = JsonConvert.DeserializeObject<Dictionary<string, string>>(dt.Rows[0]["signature"].ToString());
            fbc = new FBC(info1["loginName"], info1["usrKey"]);
        }
        string rel;
        fbc.Init();
       
        if (!string.IsNullOrEmpty(taskKey))
        {
            fbc.UpdateScanCompletedStatue(taskKey);
        }

        if (!string.IsNullOrEmpty(fabricKey))
        {
            rel = fbc.GetFabricinfoDetail(fabricKey);
            Dictionary<string, Object> dict = JsonConvert.DeserializeObject<Dictionary<string, Object>>(rel);
            Dictionary<string, Object> rt = JsonConvert.DeserializeObject<Dictionary<string, Object>>(dict["result"].ToString());
            if (Convert.ToString(rt["code"]) == "200")
            {
                Dictionary<string, Object> info = JsonConvert.DeserializeObject<Dictionary<string, Object>>(rt["info"].ToString());
                string sql = string.Format(@"UPDATE yf_t_MyfabricScan SET fabricMainPictUrl='{0}' WHERE fabricKey='{1}' AND scanType=0;

                                                 UPDATE a set a.tpname='{0}' FROM dbo.Yf_T_bjdlb a INNER JOIN dbo.Yf_T_bjdlxb c on a.lxid=c.id AND c.bz='面料' 
                                                 INNER JOIN yf_t_MyfabricScan b ON a.ypmc=b.fabricCode WHERE b.fabricKey='{1}' AND b.scanType=0;

                                                 UPDATE d SET d.tp ='{0}' FROM Yf_T_bjdlb a 
                                                 INNER JOIN dbo.Yf_T_bjdlxb c on a.lxid=c.id AND c.bz='面料' 
                                                 INNER JOIN yf_t_MyfabricScan b ON a.ypmc=b.fabricCode 
                                                 INNER JOIN cl_t_chdmb d ON a.id=d.bjid
                                                 WHERE b.fabricKey='{1}' AND b.scanType=0 ;

                                                 DELETE e
                                                 FROM yf_t_MyfabricScan a 
                                                 INNER JOIN Yf_T_bjdlb b ON a.fabricCode=b.ypmc AND a.fabricKey='{1}'
                                                 INNER JOIN Yf_T_bjdlxb c ON b.lxid=c.id AND c.bz='面料'
                                                 INNER JOIN cl_t_chdmb d ON b.id=d.bjid
                                                 INNER JOIN dbo.t_uploadfile e ON d.id=e.TableID AND e.GroupID=2400;

                                                 INSERT INTO t_uploadfile(TableID,GroupID,URLAddress,CreateDate,createname)
                                                 SELECT DISTINCT d.id,2400,d.tp,GETDATE(),'sys'  FROM  Yf_T_bjdlb a 
                                                 INNER JOIN dbo.Yf_T_bjdlxb c on a.lxid=c.id AND c.bz='面料' 
                                                 INNER JOIN yf_t_MyfabricScan b ON a.ypmc=b.fabricCode 
                                                 INNER JOIN cl_t_chdmb d ON a.id=d.bjid
                                                 WHERE b.fabricKey='{1}' AND b.scanType=0 ;", info["fabricMainPictUrl"], fabricKey);
                using (LiLanzDALForXLM dal = new LiLanzDALForXLM(OAConnStr))
                {
                    errInfo = dal.ExecuteNonQuery(sql);
                }
                //  clsLocalLoger.WriteInfo(sql);
                if (errInfo != "")
                {
                    clsLocalLoger.WriteInfo("面料扫描接口返回更新出错：" + errInfo + sql);
                }
            }
        }
        else
        {
            Response.Write("无效数据");
        }
        Response.End();
    }  
</script>

<html xmlns="http://www.w3.org/1999/xhtml">
<head id="Head1" runat="server"></head>
 <body></body>
</html>
