<%@ WebHandler Language="C#" Class="CarSystemCore" %>

using System;
using System.Web;
using nrWebClass;
using System.Collections.Generic;
using System.Data;
using System.Data.SqlClient;
using Newtonsoft.Json.Linq;
using Newtonsoft.Json;
using System.Reflection;
using System.Collections.Specialized;
using System.IO;
using System.Text.RegularExpressions;
using System.Web.SessionState;


public class CarSystemCore : IHttpHandler, IRequiresSessionState
{
    public ResponseModel res = new ResponseModel();


    private string WXDBConnStr = nrWebClass.clsConfig.GetConfigValue("WXConnStr");//"server='192.168.35.62';uid=sa;pwd=ll=8727;database=weChatPromotion";
    private string ZBDBConnStr = nrWebClass.clsConfig.GetConfigValue("OAConnStr");//"server='192.168.35.10';uid=ABEASD14AD;pwd=+AuDkDew;database=tlsoft";
    private string CSDBConnStr = "server='192.168.35.23';uid=lllogin;pwd=rw1894tla;database=tlsoft";
    private string FXDBConnStr = nrWebClass.clsConfig.GetConfigValue("FXConStr");//"server='192.168.35.11';uid=ABEASD14AD;pwd=+AuDkDew;database=fxdb";
    private string KJDBConnStr = nrWebClass.clsConfig.GetConfigValue("ERPConnStr");//"server='192.168.35.32';uid=ABEASD14AD;pwd=+AuDkDew;database=tlsoft";
    private string DBConnStr = "";

    public void ProcessRequest(HttpContext context)
    {

        string tzid = "0";
        //context.Session["tzid"] = 1;
        /*try
        {
            tzid = Convert.ToString(context.Session["tzid"]);
        }
        catch (Exception e) { }
        if (tzid == null || tzid == "")
        {
            tzid = "0";
        }*/

        context.Response.ContentType = "text/html;charset=utf-8";
        context.Response.ContentEncoding = System.Text.Encoding.UTF8;
        context.Request.ContentEncoding = System.Text.Encoding.UTF8;

        if ("POST" == context.Request.HttpMethod.ToUpper())
        {
            Stream stream = HttpContext.Current.Request.InputStream;
            StreamReader streamReader = new StreamReader(stream);
            string data = streamReader.ReadToEnd();
            if (string.IsNullOrEmpty(data))
                res = ResponseModel.setRes(400, "无有效参数！");
            else
            {
                RequestModel req = JsonConvert.DeserializeObject<RequestModel>(data);
                MethodInfo method = this.GetType().GetMethod(req.action);
                if (method == null)
                    res = ResponseModel.setRes(400, "无效操作！");
                else
                {
                    object[] methodAttrs = method.GetCustomAttributes(typeof(MethodPropertyAttribute), false);
                    bool isCheckPass = true;

                    if (methodAttrs.Length > 0)
                    {
                        MethodPropertyAttribute att = methodAttrs[0] as MethodPropertyAttribute;
                        if (att.WebMethod)
                        {
                            if (att.CheckToken && checkAppToken(req.token) <= 0)
                                isCheckPass = false;

                            if (isCheckPass)
                            {
                                try
                                {
                                    ;
                                    object[] parameter = req.parameter;
                                    
                                    //clsSharedHelper.WriteInfo(JsonConvert.SerializeObject(req.token.ToString()));
                                    if (req.action == "getUserinfo")//获取用户信息
                                    {
                                        try
                                        {
                                            if (int.Parse(parameter[0].ToString()) > 0)
                                            {
                                                tzid = parameter[0].ToString();
                                            }
                                        }
                                        catch (Exception e) { }
                                        Dictionary<string, object> dq;
                                        dq = getUserinfo(req.token.ToString(), tzid);
                                        //clsSharedHelper.WriteInfo(JsonConvert.SerializeObject(dq));
                                        if (dq == null)
                                        {
                                            res = ResponseModel.setRes(400, "用户信息获取失败！");
                                        }
                                        else
                                        {
                                            res = ResponseModel.setRes(200, dq);

                                        }

                                    }
                                    else if (req.action == "getDepot")
                                    {
                                        DataTable dq;
                                        dq = getDepot(parameter, int.Parse(req.orgid));
                                        if (dq == null)
                                        {
                                            res = ResponseModel.setRes(400, "仓库信息获取失败！");
                                        }
                                        else
                                        {
                                            res = ResponseModel.setRes(200, dq);

                                            dq.Dispose();
                                        }

                                    }
                                    else if (req.action == "getCompanyname")
                                    {
                                        DataTable dq;
                                        dq = getCompanyname(parameter);
                                        if (dq == null)
                                        {
                                            res = ResponseModel.setRes(400, "客户信息获取失败！");
                                        }
                                        else
                                        {
                                            res = ResponseModel.setRes(200, dq);
                                            dq.Dispose();
                                        }
                                    }
                                    else if (req.action == "saveInfo")
                                    {
                                        int rtn = 0;
                                        rtn = saveInfo(parameter, int.Parse(req.orgid));
                                        if (rtn == 1)
                                        {
                                            res = ResponseModel.setRes(200, "提交成功！！");
                                        }
                                        else if (rtn == 2)
                                        {
                                            res = ResponseModel.setRes(200, "条码已保存或条码错误，请重试！！");
                                        }
                                        else
                                        {
                                            res = ResponseModel.setRes(400, "提交失败，请重试！");
                                        }
                                    }
                                    else if (req.action == "getGoodsinfo")
                                    {
                                        DataTable dq;
                                        dq = getGoodsinfo(parameter, int.Parse(req.orgid));
                                        if (dq == null)
                                        {
                                            res = ResponseModel.setRes(400, "单据信息获取失败！");
                                        }
                                        else
                                        {
                                            res = ResponseModel.setRes(200, dq);
                                            dq.Dispose();
                                        }
                                    }
                                    else if (req.action == "getGoodslist")
                                    {
                                        DataTable dq;
                                        dq = getGoodslist(parameter, int.Parse(req.orgid));
                                        if (dq == null)
                                        {
                                            res = ResponseModel.setRes(400, "无单据或单据列表获取失败！");
                                        }
                                        else
                                        {
                                            res = ResponseModel.setRes(200, dq);
                                            dq.Dispose();
                                        }
                                    }
                                    else if (req.action == "getTzlist")
                                    {
                                        getTzlist(parameter);
                                    }
                                    else if (req.action == "setTzid")
                                    {
                                        setTzid(parameter, req.token);
                                    }

                                }
                                catch (Exception ex)
                                {
                                    res = ResponseModel.setRes(400, "Server Error!" + ex.Message);
                                }
                            }
                            else
                                res = ResponseModel.setRes(400, "无效TOKEN！");
                        }
                        else
                            res = ResponseModel.setRes(400, "越权操作！！|" + req.action);
                    }
                    else
                        res = ResponseModel.setRes(400, "越权操作！|" + req.action);
                }
            }
        }
        else
            res = ResponseModel.setRes(400, "请求方式不正确！" + context.Request.HttpMethod.ToUpper());

        clsSharedHelper.WriteInfo(JsonConvert.SerializeObject(res));
    }
    [MethodProperty(WebMethod = true, CheckToken = true)]
    //人事鉴权 返回相关的人事信息属性
    public Dictionary<string, object> getUserinfo(string token, string tzid)
    {
        Dictionary<string, object> dic = new Dictionary<string, object>();
        HttpContext hc = HttpContext.Current;
        //string token = Convert.ToString(hc.Request.Params["apptoken"]);
        using (LiLanzDALForXLM wxdal = new LiLanzDALForXLM(WXDBConnStr))
        {
            string str_sql = @"select top 1 a.uid,b.department,b.avatar,b.cname,a.dqkhid
                                from wx_t_apploginstatus a 
                                inner join wx_t_customers b on a.uid=b.id 
                              where a.token=@token";
            List<SqlParameter> paras = new List<SqlParameter>();
            paras.Add(new SqlParameter("@token", token));
            DataTable dt;
            string errinfo = wxdal.ExecuteQuerySecurity(str_sql, paras, out dt);
            if (errinfo == "" && dt.Rows.Count > 0)
            {
                using (LiLanzDALForXLM zbdal = new LiLanzDALForXLM(ZBDBConnStr))
                {
                    string headimg = dt.Rows[0]["avatar"].ToString();
                    if (headimg.Contains("http"))
                        dt.Rows[0]["avatar"] = clsWXHelper.GetMiniFace(headimg);
                    else
                    {
                        dt.Rows[0]["avatar"] = "http://tm.lilanz.com/OA/" + headimg;
                    }
                    int uid = Convert.ToInt32(dt.Rows[0]["uid"]);
                    string cname = Convert.ToString(dt.Rows[0]["cname"]);
                    string department = Convert.ToString(dt.Rows[0]["department"]);
                    string avatar = Convert.ToString(dt.Rows[0]["avatar"]);
                    int dqkhid = int.Parse(dt.Rows[0]["dqkhid"].ToString());

                    str_sql = string.Format(@"select depttype from wx_t_deptment where wxid={0}", department);
                    dt.Clear();
                    errinfo = zbdal.ExecuteQuery(str_sql, out dt);
                    if (errinfo == "" && dt.Rows.Count > 0)
                    {
                        string dept = Convert.ToString(dt.Rows[0]["depttype"]);
                        if (dept == "")
                        {
                            res.code = 400; res.message = "查询不到您的部门信息！【" + uid + "】";
                            dt.Dispose();
                            clsSharedHelper.WriteInfo(JsonConvert.SerializeObject(res));
                        }
                        else
                        {
                            int ryid = 0; string _msg = "";
                            ryid = getPersonID(wxdal, dept, uid);//得到人员ID                                                           

                            /*if (dept == "zb")
                                _msg = "请确保您已经开通人资系统，可进入【微信】-【利郎企业平台】-【用户中心】-【企业应用开通】尝试自助开通！";
                            else
                                _msg = "请确保您已经开通全渠道系统，可进入【微信】-【利郎企业平台】-【用户中心】-【企业应用开通】尝试自助开通！";
                            */
                            if (ryid == 0)
                            {
                                if (tzid == "0")
                                {
                                    _msg = "请到主界面右上角【管理角色】-【门店管理】中选择对应套账！";
                                    res.code = 400; res.message = _msg;
                                }
                                else
                                {
                                    //clsSharedHelper.WriteInfo(JsonConvert.SerializeObject(dt));
                                    //增加调店判断(只判断岗位控制项为1,2)
                                    if ((dqkhid == 0 && int.Parse(tzid) > 0) || (dqkhid != int.Parse(tzid) && int.Parse(tzid) > 0))
                                    {
                                        string str_gxsql = string.Format(@"update wx_t_apploginstatus set dqkhid={0} where token='{1}';select 1", int.Parse(tzid), token);
                                        object scalar;
                                        string errinfo1 = wxdal.ExecuteQueryFast(str_gxsql, out scalar);
                                        dqkhid = int.Parse(tzid);
                                        //clsSharedHelper.WriteInfo(JsonConvert.SerializeObject(Convert.ToInt32(scalar)));
                                    }
                                    dqkhid = dqkhid == 0 ? int.Parse(tzid) : dqkhid;

                                    int jsyid = 0;
                                    jsyid = getPersonID(ryid, dept);
                                    dic.Add("cname", cname);
                                    dic.Add("cid", uid.ToString());
                                    dic.Add("ryid", ryid.ToString());
                                    dic.Add("dept", dept);
                                    dic.Add("avatar", avatar);
                                    dic.Add("tzid", dqkhid);
                                    dic.Add("jsyid", jsyid);
                                    dic.Add("bmid", "");
                                    dic.Add("bmmc", "");
                                    dic.Add("userid", "");
                                    res.code = 200;
                                    res.data = dic;
                                }
                                clsSharedHelper.WriteInfo(JsonConvert.SerializeObject(res));
                            }
                            else
                            {
                                dt.Clear();
                                dt = getTzinfo(ryid, dept);
                                if (dt == null)
                                {
                                    res.code = 400; res.message = "未获取到所属贸易公司，请重试";
                                    clsSharedHelper.WriteInfo(JsonConvert.SerializeObject(res));
                                }
                                else
                                {
                                    //clsSharedHelper.WriteInfo(JsonConvert.SerializeObject(dt));
                                    //增加调店判断(只判断岗位控制项为1,2)
                                    if ((dqkhid == 0 && int.Parse(dt.Rows[0]["tzid"].ToString()) > 0) || (dqkhid != int.Parse(dt.Rows[0]["tzid"].ToString()) && int.Parse(dt.Rows[0]["tzid"].ToString()) > 0 && int.Parse(dt.Rows[0]["mdbs"].ToString()) == 1))
                                    {
                                        string str_gxsql = string.Format(@"update wx_t_apploginstatus set dqkhid={0} where token='{1}';select 1", int.Parse(dt.Rows[0]["tzid"].ToString()), token);
                                        object scalar;
                                        string errinfo1 = wxdal.ExecuteQueryFast(str_gxsql, out scalar);
                                        dqkhid = int.Parse(dt.Rows[0]["tzid"].ToString());
                                        //clsSharedHelper.WriteInfo(JsonConvert.SerializeObject(Convert.ToInt32(scalar)));
                                    }
                                    dqkhid = dqkhid == 0 ? int.Parse(dt.Rows[0]["tzid"].ToString()) : dqkhid;

                                    int jsyid = 0;
                                    jsyid = getPersonID(ryid, dept);
                                    dic.Add("cname", cname);
                                    dic.Add("cid", uid.ToString());
                                    dic.Add("ryid", ryid.ToString());
                                    dic.Add("dept", dept);
                                    dic.Add("avatar", avatar);
                                    dic.Add("tzid", dqkhid);
                                    dic.Add("jsyid", jsyid);
                                    dic.Add("bmid", dt.Rows[0]["bmid"].ToString());
                                    dic.Add("bmmc", dt.Rows[0]["bmmc"].ToString());
                                    dic.Add("userid", dt.Rows[0]["userid"].ToString());
                                    dt.Dispose();
                                }
                            }
                        }
                    }
                    else
                    {
                        res.code = 400;
                        res.message = "查询微信部门失败！" + errinfo;
                        dt.Dispose();
                        clsSharedHelper.WriteInfo(JsonConvert.SerializeObject(dt));
                    }
                }//end using zbdb
            }
            else
            {
                res.code = 400;
                res.message = "查询企业基本信息失败！" + errinfo;
                dt.Dispose();
                clsSharedHelper.WriteInfo(JsonConvert.SerializeObject(dt));
            }
        }//end using w
        return dic;
    }
    public int getPersonID(LiLanzDALForXLM dal, string bs, int cid)
    {
        string systemdid = bs == "zb" ? "2" : "3";
        int ryid = 0;
        string str_sql = "";
        if (systemdid == "2")
            str_sql = string.Format(@"select a.systemkey ryid from wx_t_appauthorized a where a.userid={0} and a.systemid={1}", cid, systemdid);
        else
            str_sql = string.Format(@"select isnull(b.relateid,0) ryid from wx_t_appauthorized a left join wx_t_omnichanneluser b on a.systemkey=b.id where a.userid={0} and a.systemid={1}", cid, systemdid);
        object scalar;
        string errinfo = dal.ExecuteQueryFast(str_sql, out scalar);
        if (errinfo == "")
            ryid = Convert.ToInt32(scalar);
        return ryid;
    }

    public DataTable getTzinfo(int ryid, string dept)
    {
        DataTable rtn;
        using (LiLanzDALForXLM dal = new LiLanzDALForXLM(ZBDBConnStr))
        {
            string str_sql = "";
            if (dept == "zb")
            {
                str_sql = string.Format(@"select a.tzid,d.id as bmid,d.bmmc,isnull(c.id,0) as userid,0 as mdbs from rs_v_zbryxxcx a left join rs_t_bmdmb b on a.bmid=b.id left join t_user c on a.id=c.ryid  and c.onoff=1 left join rs_t_bmdmb d on dbo.split(b.ccid,'-',3)=d.id where a.id='{0}';", ryid);
            }
            else
            {
                str_sql = string.Format(@"select a.tzid as tzid,a.bmid,c.bmmc,isnull(d.id,0) as userid,case when isnull(gw.id,0)=0 then 0 else 1 end mdbs from rs_t_rydwzl a left join rs_t_gwdmb gw on a.gw=gw.id and gw.kzx in (1,2) left join rs_t_bmdmb c on a.bmid=c.id left join t_user d on a.id=d.ryid and d.onoff=1 
                                where a.id ='{0}' ", ryid);
            }

            string errinfo = dal.ExecuteQuery(str_sql, out rtn);

            if (errinfo != "" || rtn.Rows.Count == 0)
            {
                rtn = null;
            }

        }

        return rtn;
    }
    public int getPersonID(int ryid, string dept)
    {
        int tzid = 0;
        string connStr = "";
        if (dept == "zb")
        {
            connStr = ZBDBConnStr;
        }
        else
        {
            connStr = FXDBConnStr;
        }
        using (LiLanzDALForXLM dal = new LiLanzDALForXLM(connStr))
        {
            string str_sql = string.Format(@"select isnull(id,0) from rs_t_jsyb where ryid={0} and ty<>1", ryid);
            object scalar;
            string errinfo = dal.ExecuteQueryFast(str_sql, out scalar);
            if (errinfo == "")
                tzid = Convert.ToInt32(scalar);

            //nrWebClass.LogHelper.Info("carsystem" + dal.ConnectionString + "||||" + str_sql);
        }
        return tzid;
    }

    //检查TOKEN
    public int checkAppToken(string token)
    {
        int uid = 0;
        HttpContext hc = HttpContext.Current;
        if (!string.IsNullOrEmpty(token))
        {
            using (LiLanzDALForXLM dal62 = new LiLanzDALForXLM(WXDBConnStr))
            {
                string str_sql = @"SELECT top 1 uid from wx_t_appLoginStatus where token=@token and tokenLastGet<>''";
                List<SqlParameter> para = new List<SqlParameter>();
                para.Add(new SqlParameter("@token", token));
                object scalar;
                string errinfo = dal62.ExecuteQueryFastSecurity(str_sql, para, out scalar);
                if (errinfo == "")
                    uid = Convert.ToInt32(scalar);
            }//end using
        }

        return uid;
    }
    [MethodProperty(WebMethod = true, CheckToken = true)]
    public void getTzlist(object[] para)
    {
        DataTable rtn;
        res = ResponseModel.setRes(400, "查询错误，请重试！");
        using (LiLanzDALForXLM dal32 = new LiLanzDALForXLM(KJDBConnStr))
        {
            string str_sql = "";
            str_sql = string.Format(@"  select kh.khid ,kh.khdm , kh.khjc as khmc,case kh.khlbdm when 'z' then 1 when 'd' then 2 when 'c' then 3 else 4 end xh  
                                        from t_user_gsqx a inner join yx_t_khb kh on a.khid=kh.khid where a.id_user={0}
                                        order by xh,khid ;
                                    ", para[0].ToString());


            string errinfo = dal32.ExecuteQuery(str_sql, out rtn);
            //clsSharedHelper.WriteInfo(JsonConvert.SerializeObject(rtn));
            if (errinfo != "" || rtn.Rows.Count == 0)
            {
                res = ResponseModel.setRes(400, "查无数据，请重试！");
            }
            else
            {
                res = ResponseModel.setRes(200, rtn, "");
            }

        }
        clsSharedHelper.WriteInfo(JsonConvert.SerializeObject(res));
    }
    [MethodProperty(WebMethod = true, CheckToken = true)]
    public void setTzid(object[] para, string token)
    {
        int rtn = 0;
        using (LiLanzDALForXLM wxdal = new LiLanzDALForXLM(WXDBConnStr))
        {
            string str_gxsql = string.Format(@"update wx_t_apploginstatus set dqkhid={0} where token='{1}';select 1", int.Parse(para[0].ToString()), token);
            object scalar;
            string errinfo1 = wxdal.ExecuteQueryFast(str_gxsql, out scalar);
            if (errinfo1 == "")
            {
                rtn = Convert.ToInt32(scalar);
            }
        }
        if (rtn == 0)
        {
            res = ResponseModel.setRes(400, "客户切换失败，请重试！");
        }
        else if (rtn == 1)
        {
            res = ResponseModel.setRes(200, "客户切换成功！");
        }
        else
        {
            res = ResponseModel.setRes(400, "未知错误！");
        }
        clsSharedHelper.WriteInfo(JsonConvert.SerializeObject(res));
    }
    [MethodProperty(WebMethod = true, CheckToken = true)]
    public DataTable getDepot(object[] para, int orgid)
    {
        DataTable rtn;
        using (LiLanzDALForXLM dal = new LiLanzDALForXLM(orgid))
        {
            string str_sql = "";
            str_sql = string.Format(@"select a.id,rtrim(a.dm)+a.mc as mc 
                        from yx_v_ckdmb a
                        /*inner join v_sjqx_ck b on a.tzid=b.tzid and a.id=b.ckid*/
                        where a.tzid={0} and a.mj=1  /*and b.userid={1} */
                        order by a.dm", para[0].ToString(), para[1].ToString());


            string errinfo = dal.ExecuteQuery(str_sql, out rtn);
            //clsSharedHelper.WriteInfo(JsonConvert.SerializeObject(rtn));
            if (errinfo != "" || rtn.Rows.Count == 0)
            {
                rtn = null;
            }

        }

        return rtn;
    }
    [MethodProperty(WebMethod = true, CheckToken = true)]
    public DataTable getCompanyname(object[] para)
    {
        DataTable rtn;
        using (LiLanzDALForXLM dal = new LiLanzDALForXLM(ZBDBConnStr))
        {
            string str_sql = "";

            str_sql = string.Format(@"select khid,khmc   
                        from yx_t_khb a
                        where a.khid={0} 
                        ", para[0].ToString());

            string errinfo = dal.ExecuteQuery(str_sql, out rtn);
            //clsSharedHelper.WriteInfo(JsonConvert.SerializeObject(rtn));
            if (errinfo != "" || rtn.Rows.Count == 0)
            {
                rtn = null;
            }

        }

        return rtn;
    }
    [MethodProperty(WebMethod = true, CheckToken = true)]
    public DataTable getGoodsinfo(object[] para, int orgid)
    {
        DataTable rtn;
        using (LiLanzDALForXLM dal = new LiLanzDALForXLM(orgid))
        {
            string str_sql = "";
            if (para[1].ToString() == "sphh")
            {
                str_sql = string.Format(@"select sphh,sl   
                        from yx_t_kcdjmx a
                        where a.id={0} 
                        ", para[0].ToString());
            }
            else if (para[1].ToString() == "lb")
            {
                str_sql = string.Format(@"select c.djh,lb.mc as lbmc, sum(a.sl) as sl   
                        from yx_t_kcdjmx a inner join yx_t_kcdjb c on a.id=c.id inner join yx_t_spdmb sp on a.sphh=sp.sphh inner join yx_t_splb lb on sp.splbid=lb.id
                        where a.id={0}  group by lb.mc,c.djh
                        ", para[0].ToString());
            }
            else if (para[1].ToString() == "wym")
            {
                str_sql = string.Format(@"select spid   
                        from yx_t_kcdjspid
                        where id={0}  
                        ", para[0].ToString());
            }
            string errinfo = dal.ExecuteQuery(str_sql, out rtn);
            //clsSharedHelper.WriteInfo(JsonConvert.SerializeObject(rtn));
            if (errinfo != "" || rtn.Rows.Count == 0)
            {
                rtn = null;
            }

        }

        return rtn;
    }
    [MethodProperty(WebMethod = true, CheckToken = true)]
    public DataTable getGoodslist(object[] para, int orgid)
    {
        DataTable rtn;
        using (LiLanzDALForXLM dal = new LiLanzDALForXLM(orgid))
        {
            string str_sql = "";

            str_sql = string.Format(@"select a.id,a.djh,sum(b.sl) as sl,convert(varchar(10),a.zdrq,120) as zdrq from yx_t_kcdjb a inner join yx_t_kcdjmx b on a.id=b.id    
                        where a.tzid={0} and a.zdr='{1}' and a.djlx=124 and convert(varchar(8),a.zdrq,112)=convert(varchar(8),getdate(),112)
                        group by a.id,a.djh,a.zdrq", para[0].ToString(), para[1].ToString());

            string errinfo = dal.ExecuteQuery(str_sql, out rtn);
            //clsSharedHelper.WriteInfo(JsonConvert.SerializeObject(para[1].ToString()));
            if (errinfo != "" || rtn.Rows.Count == 0)
            {
                rtn = null;
            }

        }

        return rtn;
    }
    [MethodProperty(WebMethod = true, CheckToken = true)]
    public int saveInfo(object[] par, int orgid)
    {
        //clsSharedHelper.WriteInfo(JsonConvert.SerializeObject(connStr));
        int rtn = 0;
        using (LiLanzDALForXLM dal = new LiLanzDALForXLM(orgid))
        {

            string str_sql = "";
            if (par[0].ToString() == "0")
            {
                str_sql += @"  declare @djh int;declare @id int;declare @pd int;
                               declare @shgwid int;select @pd = 0;
                               select top 1 @shgwid=shgwid FROM xt_v_djshl where tzid=@tzid and djlxid=124 and sfsh=1 order by xh ;
                               select @djh=ISNULL(cast(MAX(djh) as int) + 1,100001) from yx_t_kcdjb where djlx=124 and tzid=@tzid and convert(varchar(6),rq,112)=CONVERT(varchar(6),GETDATE(),112)
                               insert into yx_t_kcdjb (tzid,dhbh,djlx,djlb,djbs,djh,rq,khid,shdwid,ckid,dfckid,je,cjje,skje,kpje,zdr,shr
                               ,qrr,jyr,zdrq,xgrq,shrq,qrrq,shbs,qrbs,shgwid,pzzdr,pzzdbs,pzdqrq,pzkz,dycs,djzt,yyy,gbk,yskje,sskje,bc
                               ,lydjid,bz,yckdm,yid,spdlid,zzbs) values 
                               (@tzid,'',124,0,1,@djh,@rq,0,0,@ckid,0,0,0,0,0,@name,''
                               ,'','',GETDATE(),'','','',0,0,@shgwid,'',0,'','',0,0,'','',0,0,'',0,'移动盘点：' + @bz,0,0,1166,0);
                              set @id=SCOPE_IDENTITY();";
            }
            else
            {
                str_sql += @" declare @id int;declare @pd int;  select @pd = 0;                             
                              set @id=@djid;";
            }
            string str_mxsql = " Create Table #temp(spid varchar(50),tm varchar(50)) ;CREATE INDEX IX_temp_tm ON #temp(tm); ";

            for (int m = 6; m < par.Length; m++)
            {
                JArray ja = (JArray)par[m];
                string spid = Convert.ToString(ja[0]);
                string tm = spid.Substring(0, spid.Length - 6);
                spid = spid.Replace("'", "");
                tm = tm.Replace("'", "");
                //clsSharedHelper.WriteInfo(Convert.ToString(spid+"|"+tm));
                //clsSharedHelper.WriteInfo(JsonConvert.SerializeObject(zf2+sl.ToString()));
                str_mxsql += "insert into #temp (spid,tm) values ('" + spid + "','" + tm + "');";

            }

            str_mxsql += " select b.sphh,b.cmdm,count(1) as sl into #temp1 from  #temp  a";
            str_mxsql += " inner join yx_t_tmb b on  b.tm=a.tm collate SQL_Latin1_General_CP1_CI_AS ";//SQL_Latin1_General_CP1_CI_AS 字符转换问题
            str_mxsql += " left join (";
            str_mxsql += "     select b.spid from yx_t_kcdjb a ";
            str_mxsql += "     inner join yx_t_kcdjspid b on a.id=b.id ";
            str_mxsql += "     where tzid=@tzid and djlx=124 and convert(varchar(8),zdrq,112)=convert(varchar(8),getdate(),112) group by b.spid";
            str_mxsql += " ) c on a.spid=c.spid collate SQL_Latin1_General_CP1_CI_AS ";
            str_mxsql += " where c.spid is null";
            str_mxsql += " group by b.sphh,b.cmdm";
            str_mxsql += " select a.*,b.mxid into #temp2 from #temp1 a inner join yx_t_kcdjcmmx b on  a.cmdm=b.cmdm inner join yx_t_kcdjmx c on b.mxid=c.mxid and a.sphh=c.sphh where b.id=@id";
            str_mxsql += " insert into yx_t_kcdjspid (id,ckid,spid,tm,zxxh,gdbs) select  @id,@ckid,a.spid,a.tm,'',0 from #temp a ";
            str_mxsql += " left join (";
            str_mxsql += "     select b.spid from yx_t_kcdjb a ";
            str_mxsql += "     inner join yx_t_kcdjspid b on a.id=b.id ";
            str_mxsql += "     where tzid=@tzid and djlx=124 and convert(varchar(8),zdrq,112)=convert(varchar(8),getdate(),112) group by b.spid";
            str_mxsql += " ) c on a.spid=c.spid collate SQL_Latin1_General_CP1_CI_AS ";
            str_mxsql += " where c.spid is null and len(a.spid)<=30 ";
            str_mxsql += " insert into yx_t_kcdjmx (id,sphh,shdm,sl,js,zxid,bj,zks,dj,je,cjje,zzsl,cbje,hscbje,rkjs,rksl,yyy,jysl,lymxid,djzt,yid,yxh)  ";
            str_mxsql += " select @id,b.sphh,'',a.sl,0,0,0,0,b.lsdj,a.sl*b.lsdj,0,0,0,0,0,0,'',0,0,0,0,0 ";
            str_mxsql += " from YX_T_Spdmb b inner join (select a.sphh,sum(a.sl) as sl from #temp1 a left join yx_t_kcdjmx b on a.sphh=b.sphh and b.id=@id where b.id is null group by a.sphh) a on a.sphh=b.sphh ";
            str_mxsql += " update a set sl=a.sl+isnull(b.sl,0),je=(a.sl+isnull(b.sl,0))*a.dj from yx_t_kcdjmx a inner join (select sphh,sum(sl) as sl from #temp2 group by sphh) b on a.sphh=b.sphh where a.id=@id ";
            str_mxsql += " insert into yx_t_kcdjcmmx(id,mxid,cmdm,sl0)  ";
            str_mxsql += " select @id,a.mxid,b.cmdm,b.sl from yx_t_kcdjmx a inner join #temp1 b  on a.sphh=b.sphh left join yx_t_kcdjcmmx c on  c.cmdm=b.cmdm and a.mxid=c.mxid  where a.id=@id  and c.id is null ";
            str_mxsql += " update a set sl0=a.sl0+isnull(b.sl,0) from yx_t_kcdjcmmx a inner join #temp2 b on a.cmdm=b.cmdm and a.mxid=b.mxid where a.id=@id";
            str_mxsql += " if (select count(1) from yx_t_kcdjmx where id=@id)=0 begin delete yx_t_kcdjb where id=@id;select @pd=2 end else begin ";
            //str_mxsql += " update a set sl=b.sl,je=b.sl*a.dj from yx_t_kcdjmx a inner join (select mxid,sum(sl0) as sl from yx_t_kcdjcmmx where id=@id group by mxid) b on a.mxid=b.mxid where a.id=@id";
            str_mxsql += " update yx_t_kcdjb set je=(select sum(je) from yx_t_kcdjmx where id=@id) where id=@id; select @pd=1 end; select @pd;drop table #temp;drop table #temp1;";

            List<SqlParameter> para = new List<SqlParameter>();

            para.Add(new SqlParameter("@rq", par[1].ToString()));
            para.Add(new SqlParameter("@tzid", par[2].ToString()));
            para.Add(new SqlParameter("@ckid", par[3].ToString()));
            para.Add(new SqlParameter("@bz", par[4].ToString()));
            para.Add(new SqlParameter("@name", par[5].ToString()));
            para.Add(new SqlParameter("@djid", par[0].ToString()));

            object scalar;
            //clsSharedHelper.WriteInfo(JsonConvert.SerializeObject(1));
            string errinfo = dal.ExecuteQueryFastSecurity(str_sql + str_mxsql, para, out scalar);
            //clsSharedHelper.WriteInfo(JsonConvert.SerializeObject(errinfo));
            if (errinfo == "")
                rtn = Convert.ToInt32(scalar);

            nrWebClass.LogHelper.Info("carsystem" + dal.ConnectionString + "||||" + str_sql + str_mxsql + "|||" + rtn.ToString());
        }
        return rtn;
    }
    public void func()
    {

    }

    public bool IsReusable
    {
        get
        {
            return false;
        }
    }


    public void Abandon()
    {
        throw new NotImplementedException();
    }

    public void Add(string name, object value)
    {
        throw new NotImplementedException();
    }

    public void Clear()
    {
        throw new NotImplementedException();
    }

    public int CodePage
    {
        get
        {
            throw new NotImplementedException();
        }
        set
        {
            throw new NotImplementedException();
        }
    }

    public HttpCookieMode CookieMode
    {
        get { throw new NotImplementedException(); }
    }

    public void CopyTo(Array array, int index)
    {
        throw new NotImplementedException();
    }

    public int Count
    {
        get { throw new NotImplementedException(); }
    }

    public System.Collections.IEnumerator GetEnumerator()
    {
        throw new NotImplementedException();
    }

    public bool IsCookieless
    {
        get { throw new NotImplementedException(); }
    }

    public bool IsNewSession
    {
        get { throw new NotImplementedException(); }
    }

    public bool IsReadOnly
    {
        get { throw new NotImplementedException(); }
    }

    public bool IsSynchronized
    {
        get { throw new NotImplementedException(); }
    }

    public NameObjectCollectionBase.KeysCollection Keys
    {
        get { throw new NotImplementedException(); }
    }

    public int LCID
    {
        get
        {
            throw new NotImplementedException();
        }
        set
        {
            throw new NotImplementedException();
        }
    }

    public SessionStateMode Mode
    {
        get { throw new NotImplementedException(); }
    }

    public void Remove(string name)
    {
        throw new NotImplementedException();
    }

    public void RemoveAll()
    {
        throw new NotImplementedException();
    }

    public void RemoveAt(int index)
    {
        throw new NotImplementedException();
    }

    public string SessionID
    {
        get { throw new NotImplementedException(); }
    }

    public HttpStaticObjectsCollection StaticObjects
    {
        get { throw new NotImplementedException(); }
    }

    public object SyncRoot
    {
        get { throw new NotImplementedException(); }
    }

    public int Timeout
    {
        get
        {
            throw new NotImplementedException();
        }
        set
        {
            throw new NotImplementedException();
        }
    }

    public object this[int index]
    {
        get
        {
            throw new NotImplementedException();
        }
        set
        {
            throw new NotImplementedException();
        }
    }

    public object this[string name]
    {
        get
        {
            throw new NotImplementedException();
        }
        set
        {
            throw new NotImplementedException();
        }
    }
}

[AttributeUsage(AttributeTargets.Method)]
public class MethodPropertyAttribute : Attribute
{
    private bool checkToken = false;
    private bool webMethod = false;

    public bool CheckToken
    {
        get { return this.checkToken; }
        set { this.checkToken = value; }
    }

    public bool WebMethod
    {
        get { return this.webMethod; }
        set { this.webMethod = value; }
    }
}

public class ResponseModel
{
    private int _code;
    public int code
    {
        set { this._code = value; }
        get { return this._code; }
    }

    private object _data;
    public object data
    {
        set { this._data = value; }
        get { return this._data == null ? string.Empty : this._data; }
    }

    private string _message = "";
    public string message
    {
        set { this._message = value; }
        get { return this._message; }
    }

    public static ResponseModel setRes(int pcode, object pdata, string pmes)
    {
        ResponseModel res = new ResponseModel();
        res.code = pcode;
        res.data = pdata;
        res.message = pmes;
        return res;
    }

    public static ResponseModel setRes(int pcode, object pdata)
    {
        return setRes(pcode, pdata, string.Empty);
    }

    public static ResponseModel setRes(int pcode, string pmes)
    {
        return setRes(pcode, string.Empty, pmes);
    }
}

public class RequestModel
{
    private string _action;
    public string action
    {
        get { return this._action; }
        set { this._action = value; }
    }
    private string _orgid;
    public string orgid
    {
        get { return this._orgid; }
        set { this._orgid = value; }
    }
    private string _token;
    public string token
    {
        get { return this._token; }
        set { this._token = value; }
    }
    private string _dept;
    public string dept
    {
        get { return this._dept; }
        set { this._dept = value; }
    }

    private Object[] _parameter;
    public Object[] parameter
    {
        get { return this._parameter; }
        set { this._parameter = value; }
    }

}