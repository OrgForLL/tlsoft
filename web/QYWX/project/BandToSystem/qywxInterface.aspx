<%@ Page Language="C#" Debug="true"%>
<%@ Import Namespace="nrWebClass" %>
<%@ Import Namespace="System.Security.Cryptography" %>
<%@ Import Namespace="System.Data" %>
<%@ Import Namespace="System.Data.SqlClient" %>
<%@ Import Namespace="System.Collections.Generic" %>
<%@ Import Namespace="System.Net" %>
 <%@ Import Namespace="System.IO" %>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">

<script runat="server">
    private const string ConfigKeyValue = "1";
    string QYAccessToken = clsWXHelper.GetAT(ConfigKeyValue);
    string DBConStr = clsConfig.GetConfigValue("OAConnStr");
    string DBConStr_cfsf = clsConfig.GetConfigValue("CFSF");
    string DBConStr_wx = System.Web.Configuration.WebConfigurationManager.ConnectionStrings["Conn"].ToString();
    protected void Page_Load(object sender, EventArgs e)
    {
        string ctrl = Convert.ToString(Request.Params["ctrl"]);
        string cname="", phoneNo="",systemID="",rt="";

        if (Convert.ToString(Session["qy_customersid"]) == "" && Convert.ToString(Session["qy_OpenId"]) == "")
        {
            clsSharedHelper.WriteInfo(clsNetExecute.Error + "系统超时,请重新进入");
        }

        switch (ctrl)
        {
            case "bandSystem":
                cname = Convert.ToString(Request.Params["cname"]).Trim().Replace("\r", "").Replace("\n", "");
                phoneNo = Convert.ToString(Request.Params["phoneNo"]).Trim().Replace("\r", "").Replace("\n", "");
                systemID = Convert.ToString(Request.Params["SystemID"]);
                string xt_name = "", xt_pwd = "", rz_sfz, job_number;

                switch (systemID)
                {
                    case "1":
                        xt_name = Convert.ToString(Request.Params["xt_user"]).Trim().Replace("\r", "").Replace( "\n", "" );
                        xt_pwd = Convert.ToString(Request.Params["xt_pwd"]).Trim().Replace("\r", "").Replace("\n", "");
                        rt = BandOASystem(cname, phoneNo, xt_name, xt_pwd, systemID);
                        break;
                    case "2":
                        rz_sfz = Convert.ToString(Request.Params["rz_sfz"]).Trim().Replace("\r", "").Replace("\n", "");
                        rt = BandHRSystem(cname, phoneNo, rz_sfz, systemID);
                        break;
                    case "3":
                        rz_sfz = Convert.ToString(Request.Params["rz_sfz"]).Trim().Replace("\r", "").Replace("\n", "");
                        rt = BandLSSystem(cname, phoneNo, rz_sfz);
                        break;
                    case "4":
                        rz_sfz = Convert.ToString(Request.Params["rz_sfz"]).Trim().Replace("\r", "").Replace("\n", "");
                        rt = BandZZSystem(cname, phoneNo, rz_sfz,systemID);
                        break;
                    case "5":
                        job_number = Convert.ToString(Request.Params["job_number"]).Trim().Replace("\r", "").Replace("\n", "");
                        rt = BandJobCardSyStem(cname, job_number, phoneNo, systemID); break;
                    case "6":
                        rz_sfz = Convert.ToString(Request.Params["rz_sfz"]).Trim().Replace("\r", "").Replace("\n", "");
                        rt = BandToAttend(cname, phoneNo, rz_sfz, systemID);
                        break;
                    default: break;
                }
                if (rt.IndexOf("Successed") >= 0)//绑定成功后清掉session，再次进入后重新鉴权获取信息
                {
                    Session["qy_name"] = null;
                    Session["qy_customersid"] = null;
                    Session["qy_OpenId"] = null;
                }
                break;
            case "getQYOpenid":
                string key = Convert.ToString(Request.Params["key"]);
                rt = updateOpenid(key);
                break;
            case "link":
                rt = setSession();
                break;
            default: rt = "非法参数！";
                break;
        }
        Response.Write(rt);
        Response.End();
    }
    private string setSession()
    {
        string rt ;
        if (Session["qy_name"] == null)
        {
            rt = clsNetExecute.Error + "系统超时,请重新进入";
        }
        else
        {
            Session["qy_name"] = Session["qy_name"];
            Session["qy_customersid"] = Session["qy_customersid"];
            Session["qy_OpenId"] = Session["qy_OpenId"];
            rt = clsNetExecute.Successed;
        }
        return rt;
    }

    /// <summary>
    /// 更新openid
    /// </summary>
    /// <param name="key"></param>
    /// <returns></returns>
    private string updateOpenid(string key)
    {
        string errInfo, rt = "";
        string mysql = "select name,id from wx_t_customers where isnull(wxopenid,'')=''";
        DataTable dt;
        using (LiLanzDALForXLM dal = new LiLanzDALForXLM(DBConStr))
        {
            errInfo = dal.ExecuteQuery(mysql, out dt);
        }

        if (errInfo != "")
        {
            rt = errInfo;
        }
        else if (dt.Rows.Count <= 0)
        {
            rt = "无找到需要更新的数据";
        }
        else
        {
            string opneid;
            int k = 0;     //统计有更新数据的人数
            mysql = "";
            for (int i = 0; i < dt.Rows.Count; i++)
            {
                opneid = GetQYopenID(Convert.ToString(dt.Rows[i]["name"]).Trim(), QYAccessToken);
                if (opneid.IndexOf(clsNetExecute.Successed) >= 0)
                {
                    k++;
                    opneid = opneid.Replace(clsNetExecute.Successed, "");
                    mysql = string.Concat(mysql, "update wx_t_customers set wxopenid='", opneid, "' where id=", dt.Rows[i]["id"], ";");
                }
            }

            if (mysql != "")
            {
                using (LiLanzDALForXLM dal = new LiLanzDALForXLM(DBConStr))
                {
                    errInfo = dal.ExecuteNonQuery(mysql);
                }
                if (errInfo == "")
                {
                    rt = "成功更新了" + k.ToString() + "条数据";
                }
                else
                {
                    rt = "更新出错：" + errInfo;
                }
            }
            else
            {
                rt = "未找到更多需要更新的数据";
            }
        }

        return rt;
    }
    /// <summary>
    /// 根据userid获取openid
    /// </summary>
    /// <param name="userid"></param>
    /// <param name="accessToken"></param>
    /// <returns></returns>
    private string GetQYopenID(string userid, string accessToken)
    {
        string rt = "";
        string myURL = "https://qyapi.weixin.qq.com/cgi-bin/user/convert_to_openid?access_token={0}";
        myURL = string.Format(myURL, accessToken);
        clsJsonHelper json = new clsJsonHelper();
        json.AddJsonVar("userid", userid);
        string content = postDataToWX(myURL, json.jSon);
        json = clsJsonHelper.CreateJsonHelper(content);

        if (Convert.ToString(json.GetJsonValue("errmsg")) == "ok")
        {
            rt = clsNetExecute.Successed + Convert.ToString(json.GetJsonValue("openid"));
        }
        else
        {
            clsLocalLoger.WriteInfo("获取openid出错：" + json.jSon);
            rt = clsNetExecute.Error + json.jSon;
        }

        return rt;
    }
    /// <summary>
    /// 绑定协同系统,1、验证用户名密码，存在则继续，不存在则返回；2、判断是否存在微信档案信息，存在则判断电话号码是否相同，不同则更新电话号码后直接授权，不存在则新建后授权
    /// </summary>
    /// <param name="cname"></param>
    /// <param name="phoneNo"></param>
    /// <param name="ststemID"></param>
    /// <param name="name"></param>
    /// <param name="pwd"></param>
    /// <returns></returns>
    private string BandOASystem(string cname, string phoneNo, string name, string pwd, string systemID)
    {
        string mySql, errInfo, rt = "", qy_customersid, qy_name, content;
        bool flag = true;
        DataTable dt;
        mySql = @"select a.id,isnull(b.department,'') department,isnull(b.position,'') position,isnull(b.mobile,'') mobile  from t_user a
                  left join wx_t_customers b on b.id=@customerID
                  where a.name=@name and a.pass=@pwd";
        List<SqlParameter> para = new List<SqlParameter>();
        para.Add(new SqlParameter("@name", name));
        para.Add(new SqlParameter("@pwd", String2MD5(pwd)));
        para.Add(new SqlParameter("@customerID", Convert.ToString(Session["qy_customersid"])));
        using (LiLanzDALForXLM dal = new LiLanzDALForXLM(DBConStr))
        {
            errInfo = dal.ExecuteQuerySecurity(mySql, para, out dt);
            para = null;
        }

        if (errInfo != "")
        {
            rt = errInfo;
            flag = false;
        }
        else if (dt.Rows.Count < 1)
        {
            rt = clsNetExecute.Error + ":用户名或密码有误";
            flag = false;
        }

        if (flag == false)
        {
            clsLocalLoger.WriteInfo(cname + "绑定协同系统时出错：" + rt);
            return rt;
        }

        //Session["qy_customersid"] 为空时，此人还未有企业微信账号，创建个人档案，部门放在 通用未分组 
        clsJsonHelper json = new clsJsonHelper();

        if (Convert.ToString(Session["qy_customersid"]) == "")
        {
            qy_name = System.Guid.NewGuid().ToString().ToUpper();
            json.AddJsonVar("OpenId", Convert.ToString(Session["qy_OpenId"]));
            json.AddJsonVar("userid", qy_name);
            json.AddJsonVar("name", cname);
            json.AddJsonVar("department", "[4]", false);//协同系统加入统一放到未分组内
            json.AddJsonVar("position", "暂无");
            json.AddJsonVar("mobile", phoneNo);

            content = CreateCustomer(json.jSon);  //创建个人信息
        }
        else if (phoneNo != Convert.ToString(dt.Rows[0]["mobile"]))
        {
            qy_name = Convert.ToString(Session["qy_name"]);
            json.AddJsonVar("userid", qy_name);
            json.AddJsonVar("name", cname);
            json.AddJsonVar("department", "[" + Convert.ToString(dt.Rows[0]["department"]) + "]", false);
            json.AddJsonVar("position", Convert.ToString(dt.Rows[0]["position"]));
            json.AddJsonVar("mobile", phoneNo);
            //  qy_customersid = Convert.ToString(Session["qy_customersid"]);

            content = UpdateCustomerInfo(json.jSon);//更新个人信息
        }
        else
        {
            qy_name = Convert.ToString(Session["qy_name"]);
            content = clsNetExecute.Successed + Convert.ToString(Session["qy_customersid"]);
        }

        if (content.IndexOf(clsNetExecute.Successed) >= 0)
        {
            qy_customersid = content.Replace(clsNetExecute.Successed, "");
            Session["qy_customersid"] = qy_customersid;
            Session["qy_name"] = qy_name;
            rt = AuthorizedSystem(qy_customersid, systemID, Convert.ToString(dt.Rows[0]["id"]), cname);
        }
        else
        {
            flag = false;
            rt = content;
            qy_customersid = "";
        }

        if (flag == true)
        {
            rt = AuthorizedSystem(qy_customersid, systemID, Convert.ToString(dt.Rows[0]["id"]), cname);
        }

        return rt;
    }
    /// <summary>
    /// 绑定总部人资系统,只要是绑定总部人资，即部门就更新为总部人资的部门
    /// </summary>
    /// <param name="cname"></param>
    /// <param name="phoneNo"></param>
    /// <param name="rz_sfz"></param>
    /// <returns></returns>
    private string BandHRSystem(string cname, string phoneNo, string rz_sfz, string systemID)
    {
        string mySql, errInfo, rt = "", content, qy_customersid, qy_name;
        string wxbm = "0";
        bool flag = true;
        DataTable dt;
        mySql = @"select a.id,b.id as bmid,b.bmmc,isnull(c.wxid,'0') as wxbmid,case when a.xb='男' then 1 else 2 end as gender,isnull(a.gw,'') position,isnull(d.AccountNo,'') as AccountNo         
                from rs_v_oaryzhcx a inner join Rs_T_Bmdmb b on dbo.split(a.ccid,'-',3)=b.id 
                left join wx_t_deptment c on b.id=c.id and c.deptType='zb'
                left join xz_t_ygbcrysz d on a.id=d.ryid 
                where a.tzid=1 and a.rzzk='01' and ltrim(rtrim(REPLACE(a.xm, CHAR(13) , '')))=@xm and ltrim(rtrim(REPLACE(a.sfzh, CHAR(13) , '')))=@sfzh and ltrim(rtrim(REPLACE(a.yddh, CHAR(13) , '')))=@yddh ";
        List<SqlParameter> para = new List<SqlParameter>();
        para.Add(new SqlParameter("@xm", cname));
        para.Add(new SqlParameter("@yddh", phoneNo));
        para.Add(new SqlParameter("@sfzh", rz_sfz));
        using (LiLanzDALForXLM dal = new LiLanzDALForXLM(DBConStr))
        {
            errInfo = dal.ExecuteQuerySecurity(mySql, para, out dt);
            para = null;
        }

        if (errInfo != "")
        {
            rt = errInfo;
            flag = false;
        }
        else if (dt.Rows.Count < 1)
        {
            rt = string.Format(clsNetExecute.Error + "姓名【{0}】、电话【{1}】或身份证号码【{2}】与人资信息不一致!", cname, phoneNo, rz_sfz);
            flag = false;
        }

        if (flag == false)
        {
            clsLocalLoger.WriteInfo(cname + "绑定人资系统时出错：" + rt);
            return rt;
        }

        //判断此人的微信部门是否存在，不存在新建
        if (Convert.ToString(dt.Rows[0]["wxbmid"]) == "0")
        {
            //创建部门
            content = CreateDept(Convert.ToString(dt.Rows[0]["bmid"]), Convert.ToString(dt.Rows[0]["bmmc"]), "2", "1", "zb");
            if (content.IndexOf(clsNetExecute.Successed) < 0)//创建部门不成功直接返回错误
            {
                flag = false;
                rt = "创建人资部门出错：" + content;
            }
            else
            {
                wxbm = content.Replace(clsNetExecute.Successed, "");
            }
        }
        else
        {
            wxbm = Convert.ToString(dt.Rows[0]["wxbmid"]);
        }

        if (flag == false)
        {
            clsLocalLoger.WriteInfo(cname + rt);
            return rt;
        }

        clsJsonHelper json = new clsJsonHelper();
        json.AddJsonVar("name", cname);
        json.AddJsonVar("department", "[" + wxbm + "]", false);
        json.AddJsonVar("position", Convert.ToString(dt.Rows[0]["position"]));
        json.AddJsonVar("mobile", phoneNo);
        json.AddJsonVar("gender", Convert.ToString(dt.Rows[0]["gender"]));
        json.AddJsonVar("email", "");
        json.AddJsonVar("weixinid", "");

        if (Convert.ToString(Session["qy_customersid"]) != "")//判断此人是否已有企业微信账号，有则直接授权，无则加入通讯录  Session["qy_customersid"] 存放wx_T_customers的ID值
        {
            qy_name = Convert.ToString(Session["qy_name"]).Trim();
            json.AddJsonVar("userid", qy_name);
            content = UpdateCustomerInfo(json.jSon);
        }
        else //企业号中无个人信息，添加到通讯录 
        {
            qy_name = System.Guid.NewGuid().ToString().ToUpper();
            json.AddJsonVar("OpenId", Convert.ToString(Session["qy_OpenId"]));
            json.AddJsonVar("userid", qy_name);
            content = CreateCustomer(json.jSon);
        }

        if (content.IndexOf(clsNetExecute.Successed) >= 0)
        {
            qy_customersid = content.Replace(clsNetExecute.Successed, "");
            Session["qy_customersid"] = qy_customersid;
            Session["qy_name"] = qy_name;
        }
        else
        {
            rt = "创建、更新个人信息出错：" + content;
            clsLocalLoger.WriteInfo(rt);
            flag = false;
            qy_customersid = "";
        }

        if (flag == true)
        {
            rt = AuthorizedSystem(qy_customersid, systemID, Convert.ToString(dt.Rows[0]["id"]), cname);
            if (rt.IndexOf(clsNetExecute.Successed) >= 0 && Convert.ToString(dt.Rows[0]["AccountNo"]) != "")//能关联出工卡的直接帮忙关联出来
            {
                AuthorizedSystem(qy_customersid, "5", Convert.ToString(dt.Rows[0]["AccountNo"]), cname);
            }
        }
        return rt;
    }
    /// <summary>
    /// 绑定零售系统
    /// </summary>
    /// <param name="cname"></param>
    /// <param name="phoneNo"></param>
    /// <param name="sfzh"></param>
    /// <returns></returns>
    private string BandLSSystem(string cname, string phoneNo, string sfzh)
    {
        string mySql, errInfo, rt = "", content, qy_customersid, qy_name;
        string wxbm = "0", wxsjbm = "0";
        bool flag = true;
        DataTable dt;
        mySql = @"select a.id,kh.khid as sjbmid,kh.khmc as sjbmmc,tz.khid as bmid,tz.khmc as bmmc,ISNULL(gw.mc ,'') position,case when a.xb='男' then 1 else 2 end as gender,isnull(ry.department,0) wxdept,isnull(ry.id,0) wxryid,
                 case when exists(select * from wx_t_deptment where id=tz.khid and deptType='my') then 2 when exists(select * from wx_t_deptment where id=kh.khid and deptType='my') then 1 else 0 end as bmbs,
                 isnull((select top 1 wxid from wx_t_deptment where id=kh.khid and deptType='my'),'0') as wxsjbm,isnull((select top 1 wxid from wx_t_deptment where id=tz.khid and deptType='my'),'0') as wxbm
                from rs_t_Ryjbzl a
                inner join rs_t_rydwzl b on a.id=b.id
                inner join yx_t_khb tz on b.tzid=tz.khid
                inner join yx_t_khb kh on dbo.split(tz.ccid,'-',2)=kh.khid
                left join rs_t_gwdmb gw on b.gw=gw.id
                left join wx_t_customers ry on ry.name=@name
                where b.rzzk IN ('0','1','6') and  a.xm=@xm and a.sfzh=@sfzh and a.yddh=@yddh ";
        List<SqlParameter> para = new List<SqlParameter>();
        para.Add(new SqlParameter("@xm", cname));
        para.Add(new SqlParameter("@yddh", phoneNo));
        para.Add(new SqlParameter("@sfzh", sfzh));
        para.Add(new SqlParameter("@name", Convert.ToString(Session["qy_name"])));
        using (LiLanzDALForXLM dal = new LiLanzDALForXLM(DBConStr))
        {
            errInfo = dal.ExecuteQuerySecurity(mySql, para, out dt);
            para = null;
        }

        if (errInfo != "")//查询数据库出错
        {
            rt = errInfo;
            flag = false;
        }
        else if (dt.Rows.Count < 1)//未能找到对应的信息
        {
            rt = string.Concat(clsNetExecute.Error , "姓名【" ,cname , "】、电话【" ,phoneNo , "】或身份证号码【" ,sfzh , "】与人资信息不一致!");
            flag = false;
        }else{
            //添加查找62微信库，判断此人信息是否已加入全渠道，有加入则直接让其关注企业号
            using (LiLanzDALForXLM dal = new LiLanzDALForXLM(DBConStr_wx))
            {
                string mysql = string.Format(@"SELECT * FROM dbo.wx_t_OmniChannelUser a 
                                         INNER JOIN dbo.wx_t_AppAuthorized b ON a.id=b.SystemKey AND a.relateID={0} AND SystemID=3
                                         INNER JOIN dbo.wx_t_customers c ON b.UserID=c.ID AND c.mobile='{1}'", Convert.ToString(dt.Rows[0]["id"]), phoneNo);
                DataTable dt_omn;
                errInfo = dal.ExecuteQuery(mysql, out dt_omn);
                if (errInfo == "" && dt_omn.Rows.Count > 0)
                {
                    rt = "type1|您已有全渠道用户,请直接关注利郎企业平台即可!";
                    dt_omn.Clear(); dt_omn.Dispose();
                    dt.Clear(); dt_omn.Dispose();
                    Session.Clear();//清除session
                    return rt;
                }
                dt_omn.Clear(); dt_omn.Dispose();
            }

            if (flag == true && Convert.ToString(dt.Rows[0]["position"]) == "")
            {
                rt = string.Concat(clsNetExecute.Error, "姓名【", cname, "】、电话【", phoneNo, "】或身份证号码【", sfzh, "】您还没设置岗位，请联系人资设置岗位后再来扫描关注！");
                flag = false;
            }
        }

        if (flag == false)
        {
            clsLocalLoger.WriteInfo(rt);
            return rt;
        }

        if (Convert.ToString(dt.Rows[0]["wxryid"]) != "0" && Convert.ToString(dt.Rows[0]["wxdept"]) != "4")//人员信息存在，且部门信息不在“未分组”之中，则不修改其部门分组
        {
            wxbm = Convert.ToString(dt.Rows[0]["wxdept"]);
        }
        else if (Convert.ToInt32(dt.Rows[0]["bmbs"]) < 2)  //bmbs：0->微信部门不存在，部门的上级部门也不存在；1->微信部门不存在，上级部门存在，2->微信部门，上级部门都存在
        {
            if (Convert.ToInt32(dt.Rows[0]["bmbs"]) == 0)//无上级部门
            {
                content = CreateDept(Convert.ToString(dt.Rows[0]["sjbmid"]), Convert.ToString(dt.Rows[0]["sjbmmc"]), "3", "1", "my");
                if (content.IndexOf(clsNetExecute.Successed) < 0)//创建部门不成功直接返回错误
                {
                    flag = false;
                    rt = content;
                }
                else if (Convert.ToString(dt.Rows[0]["sjbmid"]) == Convert.ToString(dt.Rows[0]["bmid"]))//无下级部门id
                {
                    wxbm = content.Replace(clsNetExecute.Successed, "");
                }
                else
                {
                    wxsjbm = content.Replace(clsNetExecute.Successed, "");
                }
            }
            else
            {
                wxsjbm = Convert.ToString(dt.Rows[0]["wxsjbm"]);
            }

            if (flag == true && Convert.ToInt32(dt.Rows[0]["sjbmid"])!=Convert.ToInt32(dt.Rows[0]["bmid"]))
            {
                content = CreateDept(Convert.ToString(dt.Rows[0]["bmid"]), Convert.ToString(dt.Rows[0]["bmmc"]), wxsjbm, "1", "my");
                if (content.IndexOf(clsNetExecute.Successed) < 0)//创建部门不成功直接返回错误
                {
                    flag = false;
                    rt = content;
                }
                wxbm = content.Replace(clsNetExecute.Successed, "");
            }
        }
        else
        {
            wxbm = Convert.ToString(dt.Rows[0]["wxbm"]);
        }


        if (flag == false)
        {
            clsLocalLoger.WriteInfo(string.Concat("创建部门出错：" , rt));
            return rt;
        }

        if (Convert.ToString(dt.Rows[0]["wxdept"]) == "4" || Convert.ToString(dt.Rows[0]["wxryid"]) == "0")//人员不存在，或需要修改部门才需要修改个人资料  || Convert.ToInt32(dt.Rows[0]["bmbs"]) < 2
        {

            clsJsonHelper json = new clsJsonHelper();
            json.AddJsonVar("name", cname);
            json.AddJsonVar("department", "[" + wxbm + "]", false);
            json.AddJsonVar("position", Convert.ToString(dt.Rows[0]["position"]));
            json.AddJsonVar("mobile", phoneNo);
            json.AddJsonVar("gender", Convert.ToString(dt.Rows[0]["gender"]));
            json.AddJsonVar("enable", "1");

            if (Convert.ToString(Session["qy_customersid"]) != "")//判断此人是否已有企业微信账号，有则直接授权，无则加入通讯录  Session["qy_customersid"] 存放wx_T_customers的ID值
            {
                qy_name = Convert.ToString(Session["qy_name"]);
                json.AddJsonVar("userid", qy_name);
                content = UpdateCustomerInfo(json.jSon);
            }
            else //企业号中无个人信息，添加到通讯录 
            {
                qy_name = System.Guid.NewGuid().ToString().ToUpper();
                json.AddJsonVar("OpenId", Convert.ToString(Session["qy_OpenId"]));
                json.AddJsonVar("userid", qy_name);
                clsLocalLoger.WriteInfo("零售：" + json.jSon);
                content = CreateCustomer(json.jSon);
            }

            if (content.IndexOf(clsNetExecute.Successed) >= 0)
            {
                qy_customersid = content.Replace(clsNetExecute.Successed, "");
            }
            else
            {
                clsLocalLoger.WriteInfo("【系统绑定】:" + content);
                rt = content;
                qy_customersid = "";
                flag = false;
            }
        }
        else
        {
            qy_customersid = Convert.ToString(dt.Rows[0]["wxryid"]);
            qy_name = Convert.ToString(Session["qy_name"]);
        }

        if (flag == true)
        {
            Session["qy_customersid"] = qy_customersid;
            Session["qy_name"] = qy_name;
            mySql = @"
                       if not exists (select top 1 ID from wx_t_AppAuthorized where SystemID=3 and userid=@customerid and IsActive=1) 
                      begin 
                       insert into wx_t_OmniChannelUser(Nickname,GradePositions,PositionID,RoleID,relateID) 
                       select a.xm,b.zd,b.gw,case when c.mc like '%经理%' then '2' when c.mc like '%店%' then '2' else '1' end as roleID,a.id 
                       from rs_t_Ryjbzl a inner join rs_t_rydwzl b on a.id=b.id inner join rs_t_gwdmb c on b.gw=c.id where a.id=@ryid;
                       select @@identity; 
                      end 
                      else select SystemKey from wx_t_AppAuthorized where SystemID=3 and userid=@customerid ";
            List<SqlParameter> para1 = new List<SqlParameter>();
            para1.Add(new SqlParameter("@ryid", Convert.ToString(dt.Rows[0]["id"])));
            para1.Add(new SqlParameter("@customerid", Convert.ToString(Session["qy_customersid"])));
            dt.Clear();
            dt.Dispose();
            using (LiLanzDALForXLM dal = new LiLanzDALForXLM(DBConStr_wx))
            {
                errInfo = dal.ExecuteQuerySecurity(mySql, para1, out dt);
            }

            if (errInfo == "" && dt.Rows.Count > 0)
            {
                rt = AuthorizedSystem(qy_customersid, "3", Convert.ToString(dt.Rows[0][0]), cname + "自助开通");
                dt.Clear();
                dt.Dispose();
            }
            else
            {
                rt = errInfo;
            }
        }
        return rt;
    }

    /// <summary>
    /// 绑定制造公司系统人员信息(通过人资信息绑定、目前绑定五里信息:有人资信息)
    /// </summary>
    /// <param name="cname"></param>
    /// <param name="phoneNo"></param>
    /// <param name="rz_sfz"></param>
    /// <returns></returns>
    private string BandZZSystem(string cname, string phoneNo, string rz_sfz, string systemID)
    {
        string mySql, errInfo, rt = "", content, qy_customersid, qy_name;
        string wxbm = "0";
        bool flag = true;
        DataTable dt;
        mySql = @"select a.tzid, a.id,b.id as bmid,b.bmmc,isnull(c.wxid,'0') as wxbmid,case when a.xb='男' then 1 else 2 end as gender,isnull(a.gw,'') position,isnull(d.AccountNo,'') as AccountNo,isnull(ry.department,0) wxdept,isnull(ry.id,0) wxryid,ISNULL(cy.AccountNo,'') AccountNo
                from rs_v_oaryzhcx a inner join Rs_T_Bmdmb b on dbo.split(a.ccid,'-',1)=b.id 
                left join wx_t_deptment c on b.id=c.id and c.deptType='zz'
                left join xz_t_ygbcrysz d on a.id=d.ryid 
                left join wx_t_customers ry on ry.name=@name
                 left join xz_t_ygbcrysz cy on a.id=cy.ryid 
                where a.tzid>1 and a.rzzk='01' and xm=@xm and sfzh=@sfzh and a.yddh=@yddh ";
        List<SqlParameter> para = new List<SqlParameter>();
        para.Add(new SqlParameter("@xm", cname));
        para.Add(new SqlParameter("@yddh", phoneNo));
        para.Add(new SqlParameter("@sfzh", rz_sfz));
        para.Add(new SqlParameter("@name", Convert.ToString(Session["qy_name"])));
        using (LiLanzDALForXLM dal = new LiLanzDALForXLM(DBConStr))
        {
            errInfo = dal.ExecuteQuerySecurity(mySql, para, out dt);
            para = null;
        }

        if (errInfo != "")
        {
            rt = errInfo;
            flag = false;
        }
        else if (dt.Rows.Count < 1)
        {
            rt = string.Format(clsNetExecute.Error + "姓名【{0}】、电话【{1}】或身份证号码【{2}】与人资信息不一致!", cname, phoneNo, rz_sfz);
            flag = false;
        }

        if (flag == false)
        {
            clsLocalLoger.WriteInfo(cname + "绑定制造公司人资系统时出错：" + rt);
            return rt;
        }
        if (Convert.ToString(dt.Rows[0]["wxdept"]) != "0" && Convert.ToString(dt.Rows[0]["wxdept"])!="4")
        {
            wxbm = Convert.ToString(dt.Rows[0]["wxdept"]);
        }
        else if (Convert.ToString(dt.Rows[0]["wxbmid"]) == "0") //判断此人的微信部门是否存在，不存在新建
        {
            //创建部门  写死五里的、其他制造公司要使用需要调整
            content = CreateDept(Convert.ToString(dt.Rows[0]["bmid"]), Convert.ToString(dt.Rows[0]["bmmc"]), "2311", "1", "zz");
            if (content.IndexOf(clsNetExecute.Successed) < 0)//创建部门不成功直接返回错误
            {
                flag = false;
                rt = "创建人资部门出错：" + content;
            }
            else
            {
                wxbm = content.Replace(clsNetExecute.Successed, "");
            }
        }
        else
        {
            wxbm = Convert.ToString(dt.Rows[0]["wxbmid"]);
        }

        if (flag == false)
        {
            clsLocalLoger.WriteInfo(cname + rt);
            return rt;
        }

        clsJsonHelper json = new clsJsonHelper();
        json.AddJsonVar("name", cname);
        json.AddJsonVar("department", "[" + wxbm + "]", false);
        json.AddJsonVar("position", Convert.ToString(dt.Rows[0]["position"]));
        json.AddJsonVar("mobile", phoneNo);
        json.AddJsonVar("gender", Convert.ToString(dt.Rows[0]["gender"]));
        json.AddJsonVar("email", "");
        json.AddJsonVar("weixinid", "");

        if (Convert.ToString(Session["qy_customersid"]) != "")//判断此人是否已有企业微信账号，有则直接授权，无则加入通讯录  Session["qy_customersid"] 存放wx_T_customers的ID值
        {
            qy_name = Convert.ToString(Session["qy_name"]).Trim();
            json.AddJsonVar("userid", qy_name);
            content = UpdateCustomerInfo(json.jSon);
        }
        else //企业号中无个人信息，添加到通讯录 
        {
            qy_name = System.Guid.NewGuid().ToString().ToUpper();
            json.AddJsonVar("OpenId", Convert.ToString(Session["qy_OpenId"]));
            json.AddJsonVar("userid", qy_name);
            content = CreateCustomer(json.jSon);
        }

        if (content.IndexOf(clsNetExecute.Successed) >= 0)
        {
            qy_customersid = content.Replace(clsNetExecute.Successed, "");
            Session["qy_customersid"] = qy_customersid;
            Session["qy_name"] = qy_name;
        }
        else
        {
            rt = "创建、更新个人信息出错：" + content;
            clsLocalLoger.WriteInfo(rt);
            flag = false;
            qy_customersid = "";
        }

        if (flag == true)
        {
            rt = AuthorizedSystem(qy_customersid, systemID, Convert.ToString(dt.Rows[0]["id"]), cname);
            if (rt.IndexOf(clsNetExecute.Successed) >= 0 && Convert.ToString(dt.Rows[0]["AccountNo"]) != "")//能关联出工卡的直接帮忙关联出来
            {
                AuthorizedSystem(qy_customersid, "5", Convert.ToString(dt.Rows[0]["AccountNo"]), cname);
            }
        }
        return rt;
    }


    /// <summary>
    /// 绑定工卡系统
    /// </summary>
    /// <param name="customername"></param>
    /// <param name="customerNo"></param>
    /// <returns></returns>
    private string BandJobCardSyStem(string customername, string customerNo, string phoneNo, string systemID)
    {
        string mySql, errInfo, rt = "", content, qy_customersid;
        bool flag = true;
        DataTable dt;
        mySql = @"select a.accountno
                  from tb_Customer a
                  where a.customername=@customername and a.customerNo=@customerNo";
        List<SqlParameter> para = new List<SqlParameter>();
        para.Add(new SqlParameter("@customername", customername));
        para.Add(new SqlParameter("@customerNo", customerNo));
        using (LiLanzDALForXLM dal = new LiLanzDALForXLM(DBConStr_cfsf))
        {
            errInfo = dal.ExecuteQuerySecurity(mySql, para, out dt);
            para = null;
        }

        if (errInfo != "")
        {
            flag = false;
            rt = errInfo;
        }
        else if (dt.Rows.Count <= 0)
        {
            flag = false;
            rt = clsNetExecute.Error + string.Format("【名称:{0}】【工号:{1}】【电话号码:{2}】找不到工卡信息,请检查后再试！", customername, customerNo, phoneNo);
        }

        if (flag == false)
        {
            clsLocalLoger.WriteInfo(customername + "查找个人信息是出错：" + rt);
            return rt;
        }

        string accountNo = Convert.ToString(dt.Rows[0]["accountno"]);
        string qy_name = "";
        if (Convert.ToString(Session["qy_customersid"]) != "")
        {
            //rt = AuthorizedSystem(Convert.ToString(dt.Rows[0]["wxryid"]), "5", accountNo, customername);
            qy_customersid = Convert.ToString(Session["qy_customersid"]);
        }
        else
        {
            clsJsonHelper json = new clsJsonHelper();
            qy_name = System.Guid.NewGuid().ToString().ToUpper();
            json.AddJsonVar("OpenId", Convert.ToString(Session["qy_OpenId"]));
            json.AddJsonVar("userid", qy_name);

            json.AddJsonVar("name", customername);
            json.AddJsonVar("department", "[4]", false);
            json.AddJsonVar("position", "暂无");
            json.AddJsonVar("mobile", phoneNo);
            json.AddJsonVar("gender", "1");
            content = CreateCustomer(json.jSon);
            if (content.IndexOf(clsNetExecute.Successed) >= 0)
            {
                qy_customersid = content.Replace(clsNetExecute.Successed, "");
            }
            else
            {
                rt = content;
                qy_customersid = "";
                flag = false;
            }
        }

        if (flag == true)
        {
            rt = AuthorizedSystem(qy_customersid, systemID, accountNo, customername);
        }

        return rt;
    }
    private string BandToAttend(string cname, string phoneNo, string rz_sfz, string systemID)
    {
        string errInfo = "";
        bool flag = true;
        string mysql = @" select top 1 a.Cname,a.id as ryid,ISNULL(sjdept.wxid,0) as sjwxbm,ISNULL(dept.wxid,0) as wxbm,
                        sjkh.khid sjkhbm,sjkh.khmc as sjbmmc,kh.khid as khbm,kh.khmc as bmmc,ISNULL(wx.ID,0) wxid,ISNULL(wx.department,0) wxdept,a.rygx as position,case when a.Sex=1 then 1 else 2 end as gender,a.mdid,a.khid,c.mdmc,b.ssid
                        from yx_t_dhryxx a 
                        inner join yx_t_khb b on a.khid=b.khid
                        inner join yx_t_khb sjkh on dbo.split(b.ccid,'-',2)=sjkh.khid
                        inner join t_mdb c on a.mdid=c.mdid
                        inner join yx_t_khb kh on c.khid=kh.khid
                        left join wx_t_Deptment sjdept on sjkh.khid=sjdept.id and sjdept.deptType='my'
                        left join wx_t_Deptment dept on kh.khid=dept.id and dept.deptType='my'
                        left join wx_t_customers wx on wx.name=@name
                        where a.mdid>0 and a.Cname=@cname and a.PhoneNumber=@phoneNum and a.IdCard=@IdCard order by a.id desc";
        DataTable dt;
        List<SqlParameter> para=new List<SqlParameter>();
        para.Add(new SqlParameter("@name",Convert.ToString(Session["qy_name"]).Trim()));
        para.Add(new SqlParameter("@cname",cname));
        para.Add(new SqlParameter("@phoneNum",phoneNo));
        para.Add(new SqlParameter("@IdCard",rz_sfz));
        using (LiLanzDALForXLM dal = new LiLanzDALForXLM(DBConStr))
        {
            errInfo = dal.ExecuteQuerySecurity(mysql, para, out dt);

            if (errInfo != "")
            {
                flag = false;
            }
            else if (dt.Rows.Count < 1)
            {
                flag = false;
                errInfo = string.Concat(clsNetExecute.Error, "未找到【姓名：", cname, "】【电话：", phoneNo, "】【身份证:" + rz_sfz + "】的信息!");
                WriteLog(mysql + "name:" + Convert.ToString(Session["qy_name"]).Trim() + " cname:" + cname + " phoneNum:" + phoneNo + " idcard:" + rz_sfz);
            }
        }
        if (flag == false)//查找出错或找不到信息 返回
        {
            clsLocalLoger.WriteInfo(string.Concat(errInfo, "session信息：Session[qy_name]", Convert.ToString(Session["qy_name"])));
            return errInfo;
        }

        string sjwxbm, wxbm, content, wxid, wxdept, qy_name = Convert.ToString(Session["qy_name"]);
        sjwxbm =Convert.ToString(dt.Rows[0]["sjwxbm"]);
        wxbm = Convert.ToString(dt.Rows[0]["wxbm"]);
        wxid = Convert.ToString(dt.Rows[0]["wxid"]);
        wxdept = Convert.ToString(dt.Rows[0]["wxdept"]);
        if (wxid == "0" || wxdept == "4")//人员信息不存在或部门在未分组，需要更改人员部门，先判断部门是否存在
        {
            //上级微信部门不存在，创建微信部门
            if (sjwxbm == "0")
            {
                content = CreateDept(Convert.ToString(dt.Rows[0]["sjkhbm"]), Convert.ToString(dt.Rows[0]["sjbmmc"]), "3", "1", "my");
                if (content.IndexOf(clsNetExecute.Successed) < 0)//创建部门不成功直接返回错误
                {
                    flag = false;
                    errInfo = content;
                }
                else
                {
                    sjwxbm = content.Replace(clsNetExecute.Successed, "");
                }
            }
            //微信部门不存在，且有二级部门
            if (flag == true && wxbm == "0" && dt.Rows[0]["sjkhbm"] != dt.Rows[0]["khbm"])
            {
                content = CreateDept(Convert.ToString(dt.Rows[0]["khbm"]), Convert.ToString(dt.Rows[0]["bmmc"]), sjwxbm, "1", "my");
                if (content.IndexOf(clsNetExecute.Successed) < 0)//创建部门不成功直接返回错误
                {
                    flag = false;
                    errInfo = content;
                }
                else
                {
                    wxbm = content.Replace(clsNetExecute.Successed, "");
                }
            }
            else if (flag == true && wxbm == "0" && dt.Rows[0]["sjkhbm"] == dt.Rows[0]["khbm"])//在贸易公司层
            {
                wxbm = sjwxbm;
            }

            if (flag == false)//创建部门出错
            {
                clsLocalLoger.WriteInfo(string.Concat("创建部门出错：", errInfo));
                return errInfo;
            }
            clsJsonHelper json = new clsJsonHelper();
            json.AddJsonVar("name", cname);
            json.AddJsonVar("department", "[" + wxbm + "]", false);
            json.AddJsonVar("position", Convert.ToString(dt.Rows[0]["position"]));
            json.AddJsonVar("mobile", phoneNo);
            json.AddJsonVar("gender", Convert.ToString(dt.Rows[0]["gender"]));
            json.AddJsonVar("enable", "1");
            if (wxid == "0")
            {
                qy_name= System.Guid.NewGuid().ToString().ToUpper();
                json.AddJsonVar("OpenId", Convert.ToString(Session["qy_OpenId"]));
                json.AddJsonVar("userid", qy_name);
                clsLocalLoger.WriteInfo("订货会：" + json.jSon);
                content = CreateCustomer(json.jSon);
            }
            else
            {
                json.AddJsonVar("userid", Convert.ToString(Session["qy_name"]));
                content = UpdateCustomerInfo(json.jSon);
            }
            if (content.IndexOf(clsNetExecute.Successed) >= 0)
            {
                wxid = content.Replace(clsNetExecute.Successed, "");
            }
            else
            {
                errInfo = content;
                flag = false;
                clsLocalLoger.WriteInfo(string.Concat(errInfo, "session信息：Session[qy_name]", Convert.ToString(Session["qy_name"])));
            }
        }
        if (flag == true)
        {
            Session["qy_customersid"] = wxid;
            Session["qy_name"] = qy_name;
            errInfo = AuthorizedSystem(wxid, "6", Convert.ToString(dt.Rows[0]["ryid"]), cname + "自助开通");
            Dictionary<string, string> dicotherinfo = new Dictionary<string, string>();
            dicotherinfo.Add("cname",cname);
            dicotherinfo.Add("khid",Convert.ToString( dt.Rows[0]["khid"]));
            dicotherinfo.Add("mdid",Convert.ToString( dt.Rows[0]["mdid"]));
            dicotherinfo.Add("mdmc",Convert.ToString( dt.Rows[0]["mdmc"]));
            dicotherinfo.Add("ssid",Convert.ToString( dt.Rows[0]["ssid"]));

            try {//顺便授权全渠道，不做合法性判断
                checkOmnUser(wxid,dicotherinfo);
            }catch(Exception eee)
            {
                clsLocalLoger.Log("[全渠道授权出错]："+eee.Message);
            }
        }
        return errInfo;

    }

    //开通订货会系统额外判断是否开通了全渠道系统，如果没开通则帮其创建全渠道用户信息
    private void checkOmnUser(string wxid,Dictionary<string,string> dinfo)
    {
        using (LiLanzDALForXLM dal=new LiLanzDALForXLM(DBConStr))
        {
            DataTable dt;

            string mysql = string.Format("SELECT * FROM dbo.wx_t_AppAuthorized where UserID={0} AND SystemID=3 ",wxid);
            string errInfo = dal.ExecuteQuery(mysql,out dt);

            if(errInfo !="" || dt.Rows.Count>0)  return;//有授权则不再处理

            mysql =string.Format( @"SELECT a.id as ryid,isnull(b.zd,11) as GradePositions,case when c.mc like '%经理%' then '2' when c.mc like '%店%' then '2' else '1' end as roleID,b.gw as PositionID
                                      from rs_t_Ryjbzl a inner join rs_t_rydwzl b ON a.id=b.id inner join rs_t_gwdmb c on b.gw=c.id  WHERE b.tzid={0} AND a.xm='{1}'",dinfo["khid"],dinfo["cname"]);

            errInfo = dal.ExecuteQuery(mysql, out dt);
            dal.ConnectionString = DBConStr_wx;
            if (dt.Rows.Count > 0)//有人资信息
            {
                mysql = string.Format(@"insert into wx_t_OmniChannelUser(Nickname,GradePositions,PositionID,RoleID,relateID)
                                       values('{0}','{1}','{2}','{3}','{4}'); SELECT SCOPE_IDENTITY() as id",dinfo["cname"],dt.Rows[0]["GradePositions"],dt.Rows[0]["PositionID"],dt.Rows[0]["roleID"],dt.Rows[0]["id"]);
                clsSharedHelper.DisponseDataTable(ref dt);
                dal.ExecuteQuery(mysql,out dt);
            }
            else//无人资信息
            {
                
                mysql = string.Format("declare @id int; INSERT INTO wx_t_OmniChannelUser(Nickname,RoleID) values('{0}',4);select @id= SELECT SCOPE_IDENTITY() as id;",dinfo["cname"]);
                mysql =mysql+string.Format( @"INSERT INTO wx_t_OmniChannelAuth (Customers_ID,Customers_name,OCUID,khid,mdid,mdmc,ssid,CreateID,CreateName)
                     values({0},'{1}',@id,'{2}','{3}','{4}','{5}','0','{6}');select  @id as id",wxid,dinfo["cname"],dinfo["khid"],dinfo["mdid"],dinfo["mdmc"],dinfo["ssid"],dinfo["cname"]+"自助开通");
                clsSharedHelper.DisponseDataTable(ref dt);
                dal.ExecuteQuery(mysql,out dt);
            }
            if(dt.Rows.Count>0) AuthorizedSystem(wxid, "3", Convert.ToString(dt.Rows[0]["id"]), dinfo["cname"] + "自助开通");
        }
    }



    /// <summary>
    /// 判断微信部门是否存在，不存在则新建
    /// </summary>
    /// <param name="bmid"></param>
    /// <returns></returns>
    private string CheckWXDepart(string name, string bmid, string parentID)
    {
        string errInfo = "", rt = "";
        DataTable dt_dept;
        string mysql = "select wxid from wx_t_Deptment where bmid=@bmid and parentid=@parentid";
        List<SqlParameter> paras = new List<SqlParameter>();
        paras.Add(new SqlParameter("@bmid", bmid));
        paras.Add(new SqlParameter("@parentid", parentID));
        using (LiLanzDALForXLM dal = new LiLanzDALForXLM(DBConStr))
        {
            errInfo = dal.ExecuteQuerySecurity(mysql, paras, out dt_dept);
            paras = null;
        }
        if (errInfo != "")
        {
            rt = errInfo;
        }
        else if (dt_dept.Rows.Count < 1)//未找到部门，创建部门
        {
            string depttype = "";
            switch (parentID)
            {
                case "1": depttype = "zb"; break;
                case "2": depttype = "my"; break;
                case "3": depttype = "gys"; break;
            }
            string content = CreateDept(bmid, name, parentID, "1", depttype);
            //值返回格式为 Successed微信部门id
            rt = content;
        }
        else
        {
            rt = clsNetExecute.Successed + Convert.ToString(dt_dept.Rows[0]["wxid"]);
        }
        return rt;
    }

    /// <summary>
    /// 系统授权,将数据插入的到数据库
    /// </summary>
    /// <param name="UserID"></param>
    /// <param name="SystemKey"></param>
    /// <param name="AuthName"></param>
    /// <returns></returns>
    private string AuthorizedSystem(string UserID, string SystemID, string SystemKey, string AuthName)
    {
        if (SystemKey == "0")
        {
            return clsNetExecute.Error + "systemkey不允许为空！";
        }
        string errInfo = "";
        string mySql = @"if exists (select * from wx_t_AppAuthorized where userid=@UserID and systemID=@SystemID) 
                        update wx_t_AppAuthorized set IsActive=1,SystemKey=@SystemKey where userid=@UserID and systemID=@SystemID
                        else 
                        insert into wx_t_AppAuthorized(UserID,SystemID,SystemKey,AuthTime,AuthName) values(@UserID,@SystemID,@SystemKey,getdate(),@AuthName)";
        List<SqlParameter> para = new List<SqlParameter>();
        para.Add(new SqlParameter("@UserID", UserID));
        para.Add(new SqlParameter("@SystemID", SystemID));
        para.Add(new SqlParameter("@SystemKey", SystemKey));
        para.Add(new SqlParameter("@AuthName", AuthName));
        using (LiLanzDALForXLM dal = new LiLanzDALForXLM(DBConStr))
        {
            errInfo = dal.ExecuteNonQuerySecurity(mySql, para);
            para = null;
        }
        if (errInfo == "")
        {
            return clsNetExecute.Successed;
        }
        else
        {
            return errInfo;
        }
    }

    /*----------------------------------部门管理wx_t_deptment------------------------------------*/
    /// <summary>
    /// 创建部门
    /// </summary>
    /// <returns>返回成功Successed+ID,失败Error:+错误信息</returns>
    public string CreateDept(string bmid, string name, string parentid, string order, string depttype)
    {
        string rtMsg = "";
        using (LiLanzDALForXLM dal = new LiLanzDALForXLM(DBConStr))
        {
            string str_sql = @"if not exists(select id from wx_t_deptment where id=@bmid and parentid=@pid)
                                begin
                                insert into wx_t_deptment(tzid,id,name,parentid,orderval,depttype) values (1,@bmid,@name,@pid,@order,@type);
                                select SCOPE_IDENTITY();
                                end
                                else
                                select wxid from wx_t_deptment where id=@bmid and parentid=@pid;";
            List<SqlParameter> paras = new List<SqlParameter>();
            paras.Add(new SqlParameter("@bmid", bmid));
            paras.Add(new SqlParameter("@name", name));
            paras.Add(new SqlParameter("@pid", parentid));
            paras.Add(new SqlParameter("@order", order));
            paras.Add(new SqlParameter("@type", depttype));
            DataTable dt = null;
            string errinfo = dal.ExecuteQuerySecurity(str_sql, paras, out dt);
            if (errinfo == "")
            {
                if (dt.Rows.Count > 0)
                {
                    string wxid = dt.Rows[0][0].ToString();
                    //接下来调用微信API
                    string postURL = string.Format("https://qyapi.weixin.qq.com/cgi-bin/department/create?access_token={0}", QYAccessToken);
                    string postData = @"{{
                               ""id"": ""{0}"",
                               ""name"": ""{1}"",
                               ""parentid"": ""{2}"",
                               ""order"": ""{3}""                               
                            }}";
                    postData = string.Format(postData, wxid, name, parentid, order);
                    string content = postDataToWX(postURL, postData);
                    clsJsonHelper jh = clsJsonHelper.CreateJsonHelper(content);
                    string errcode = jh.GetJsonValue("errcode");
                    if (errcode == "40001" || errcode == "40014" || errcode == "42001")
                    {
                        ClearAT();
                        rtMsg = "Error:" + content;
                    }
                    else if (errcode != "0")
                        rtMsg = "Error:" + content;
                    else if (errcode == "0")
                        rtMsg = "Successed" + wxid;
                }
            }
            else
                rtMsg = "Error:操作本地数据创建部门时出错 " + errinfo;

            return rtMsg;
        }
    }

    /// <summary>
    /// 更新指定部门的信息
    /// </summary>
    /// 先更新本地再调用API
    /// 返回值为空代表执行成功，否则返回错误信息
    public string UpdateDept(string bmid, string name, string parentid, string order, string depttype, string wxid)
    {
        string rtMsg = "";
        using (LiLanzDALForXLM dal = new LiLanzDALForXLM(DBConStr))
        {
            string str_sql = @"if not exists(select wxid from wx_t_deptment where wxid=@wxid)
                                select '00';
                                else
                                begin
                                update wx_t_deptment set id=@bmid,name=@name,parentid=@pid,orderval=@order,depttype=@type where wxid=@wxid;
                                select '11';
                                end";
            List<SqlParameter> paras = new List<SqlParameter>();
            paras.Add(new SqlParameter("@wxid", wxid));
            paras.Add(new SqlParameter("@bmid", bmid));
            paras.Add(new SqlParameter("@name", name));
            paras.Add(new SqlParameter("@pid", parentid));
            paras.Add(new SqlParameter("@order", order));
            paras.Add(new SqlParameter("@type", depttype));
            DataTable dt = null;
            string errinfo = dal.ExecuteQuerySecurity(str_sql, paras, out dt);
            if (errinfo == "")
            {
                string rt = dt.Rows[0][0].ToString();
                if (rt == "00")
                    rtMsg = "Error:本地数据库中找不到对应的部门！ WXID=" + rt;
                else if (rt == "11")
                {
                    //本地操作成功
                    string postURL = string.Format("https://qyapi.weixin.qq.com/cgi-bin/department/update?access_token={0}", QYAccessToken);
                    string postData = @"{{
                               ""id"": ""{0}"",
                               ""name"": ""{1}"",
                               ""parentid"": ""{2}"",
                               ""order"": ""{3}""
                            }}";
                    postData = string.Format(postData, wxid, name, parentid, order);
                    string content = postDataToWX(postURL, postData);
                    clsJsonHelper jh = clsJsonHelper.CreateJsonHelper(content);
                    string errcode = jh.GetJsonValue("errcode");
                    if (errcode == "40001" || errcode == "40014" || errcode == "42001")
                    {
                        ClearAT();
                        rtMsg = content;
                    }
                    else if (errcode != "0")
                        rtMsg = content;
                }
            }
            else
                rtMsg = "Error:执行删除本地部门时出错 " + errinfo;

            return rtMsg;
        }
    }

    /// <summary>
    /// 获取部门列表
    /// </summary>
    /// <param name="deptID"></param>
    /// 直接返回微信的请求结果
    public string GetDeptList(string deptID)
    {
        string postURL = "https://qyapi.weixin.qq.com/cgi-bin/department/list?access_token={0}&id={1}";
        postURL = string.Format(postURL, QYAccessToken, deptID);
        string content = clsNetExecute.HttpRequest(postURL);
        clsJsonHelper jh = clsJsonHelper.CreateJsonHelper(content);
        string errcode = jh.GetJsonValue("errcode");
        if (errcode == "40001" || errcode == "40014" || errcode == "42001")
        {
            ClearAT();
        }
        else if (errcode == "0")
        {
            //代表执行成功
            //List<clsJsonHelper> jhList = jh.GetJsonNodes("department");
            //if (jhList == null)
            //    rtMsg = "Error:部门ID参数有误！";
        }

        return content;
    }

    /// <summary>
    /// 删除指定部门
    /// </summary>
    /// <param name="deptID"></param>
    /// 返回值为空代表执行成功否则返回错误信息
    public string DelDept(string deptID)
    {
        //先调用微信API再删除本地数据
        string rtMsg = "";
        string postURL = string.Format("https://qyapi.weixin.qq.com/cgi-bin/department/delete?access_token={0}&id={1}", QYAccessToken, deptID);
        string content = clsNetExecute.HttpRequest(postURL);
        clsJsonHelper jh = clsJsonHelper.CreateJsonHelper(content);
        string errcode = jh.GetJsonValue("errcode");
        if (errcode == "40001" || errcode == "40014" || errcode == "42001")
        {
            ClearAT();
            rtMsg = content;
        }
        else if (errcode == "0")
        {
            //代表执行成功 接下来删除本地数据
            using (LiLanzDALForXLM dal = new LiLanzDALForXLM(DBConStr))
            {
                string str_sql = @"delete from wx_t_deptment where wxid=@deptid";
                List<SqlParameter> paras = new List<SqlParameter>();
                paras.Add(new SqlParameter("@deptid", deptID));
                rtMsg = dal.ExecuteNonQuerySecurity(str_sql, paras);
            }
        }
        else
            rtMsg = content;

        return rtMsg;
    }


    /*----------------------------------成员管理wx_t_customers------------------------------------*/
    /// <summary>
    /// 新建成员
    /// </summary>
    /// 先调用API成功之后再操作本地数据，成功则返回Successed+ID，失败返回Error:+错误信息
    public string CreateCustomer(string jStr)
    {
        string rtMsg = "";
        clsJsonHelper jh = clsJsonHelper.CreateJsonHelper(jStr);
        string userOpenId = jh.GetJsonValue("OpenId");
        jh.RemoveJsonVar("OpenId");//先移除掉openid再提交微信
        DataTable dt=new DataTable();
        using (LiLanzDALForXLM dal = new LiLanzDALForXLM(DBConStr))
        {
            rtMsg = dal.ExecuteQuery(string.Format("select * from wx_t_customers where mobile='{0}'", jh.GetJsonValue("mobile").ToString()),out dt);
            if (rtMsg=="" && dt.Rows.Count > 0)
            {
                rtMsg = "type1|您之前已经关注了《利郎企业号》，但又取消关注了；请重新关注后再进行操作！";
                Session.Clear();
                return rtMsg;
            }
        }
        string postURL = string.Format("https://qyapi.weixin.qq.com/cgi-bin/user/create?access_token={0}", QYAccessToken);
        string content = postDataToWX(postURL, jh.jSon);
        clsJsonHelper wxjh = clsJsonHelper.CreateJsonHelper(content);
        string errcode = wxjh.GetJsonValue("errcode");
        if (errcode == "40001" || errcode == "40014" || errcode == "42001")
        {
            ClearAT();
            rtMsg = "Error:" + content;
        }
        else if (errcode == "0")
        {
            //代表执行成功
            using (LiLanzDALForXLM dal = new LiLanzDALForXLM(DBConStr))
            {
                string guid = jh.GetJsonValue("userid");
                string name = jh.GetJsonValue("name");
                string dept = jh.GetJsonValue("department").Replace("[", "").Replace("]", ""); ;
                string position = jh.GetJsonValue("position");
                string mobile = jh.GetJsonValue("mobile");
                string str_sql = @"insert into wx_T_Customers(name,cname,department,position,mobile,wxopenid)
                                    values(@guid,@name,@dept,@position,@mobile,@openid);
                                    select SCOPE_IDENTITY();";
                List<SqlParameter> paras = new List<SqlParameter>();
                paras.Add(new SqlParameter("@guid", guid));
                paras.Add(new SqlParameter("@name", name));
                paras.Add(new SqlParameter("@dept", dept));
                paras.Add(new SqlParameter("@position", position));
                paras.Add(new SqlParameter("@mobile", mobile));
                paras.Add(new SqlParameter("@openid", userOpenId));
                dt = null;
                errcode = dal.ExecuteQuerySecurity(str_sql, paras, out dt);
                if (errcode == "" && dt.Rows.Count > 0)
                {
                    rtMsg = "Successed" + dt.Rows[0][0].ToString();
                }
                else
                    rtMsg = "Error:新增本地成员数据时出错 " + errcode;
            }
        }
        else
            rtMsg = "Error:调用微信API错误：" + content;

        return rtMsg;
    }

    /// <summary>
    /// 获取成员
    /// </summary>
    /// <param name="userid"></param>
    public string GetCustomerInfo(string userid)
    {
        string postURL = "https://qyapi.weixin.qq.com/cgi-bin/user/get?access_token={0}&userid={1}";
        postURL = string.Format(postURL, QYAccessToken, userid);
        string content = clsNetExecute.HttpRequest(postURL);
        clsJsonHelper jh = clsJsonHelper.CreateJsonHelper(content);
        string errcode = jh.GetJsonValue("errcode");
        if (errcode == "40001" || errcode == "40014" || errcode == "42001")
        {
            ClearAT();
            clsSharedHelper.WriteErrorInfo("access_token失效，请重试！");
        }
        else if (errcode == "0")
        {
            //代表执行成功
            clsSharedHelper.WriteInfo(content);
        }
        else
            clsSharedHelper.WriteErrorInfo("获取成员失败 " + content);

        return errcode;
    }

    /// <summary>
    /// 删除指定成员
    /// </summary>
    /// <returns></returns>
    public string DelCustomer(string userid)
    {
        string rtMsg = "";
        string postURL = string.Format("https://qyapi.weixin.qq.com/cgi-bin/user/delete?access_token={0}&userid={1}", QYAccessToken, userid);
        string content = clsNetExecute.HttpRequest(postURL);
        clsJsonHelper jh = clsJsonHelper.CreateJsonHelper(content);
        string errcode = jh.GetJsonValue("errcode");
        if (errcode == "40001" || errcode == "40014" || errcode == "42001")
        {
            ClearAT();
            rtMsg = "Error:" + content;
        }
        else if (errcode == "0" || errcode == "60111")
        {
            //代表执行成功或者是微信上找不到该用户 接下来删除本地数据
            using (LiLanzDALForXLM dal = new LiLanzDALForXLM(DBConStr))
            {
                string str_sql = @"if exists (select top 1 1 from wx_t_customers where name=@userid)
                                    begin
                                    declare @uid int;
                                    select @uid=id from wx_t_customers where name=@userid;
                                    delete from wx_t_customers where name=@userid;
                                    delete from wx_t_appauthorized where userid=@uid;
                                    end";
                List<SqlParameter> para = new List<SqlParameter>();
                para.Add(new SqlParameter("@userid", userid));
                rtMsg = dal.ExecuteNonQuerySecurity(str_sql, para);
                if (rtMsg == "")
                    rtMsg = clsSharedHelper.Successed;
                else
                    rtMsg = "Error:删除本地成员时出错 " + rtMsg;
            }
        }
        else
            rtMsg = "Error:删除成员失败 " + content;

        return rtMsg;
    }

    /// <summary>
    /// 更新成员资料
    /// </summary>
    /// <param name="jStr"></param>
    /// <returns></returns>
    public string UpdateCustomerInfo(string jStr)
    {
        string rtMsg = "";
        using (LiLanzDALForXLM dal = new LiLanzDALForXLM(DBConStr))
        {
            clsJsonHelper jh = clsJsonHelper.CreateJsonHelper(jStr);
            string guid = jh.GetJsonValue("userid");
            string name = jh.GetJsonValue("name");
            string dept = jh.GetJsonValue("department").Replace("[", "").Replace("]", ""); ;
            string position = jh.GetJsonValue("position");
            string mobile = jh.GetJsonValue("mobile");
            string gender = jh.GetJsonValue("gender");
            gender = gender == "" ? "1" : "2";
            string email = jh.GetJsonValue("email");
            string weixinid = jh.GetJsonValue("weixinid");
            string enable = "1";
            string str_sql = @"declare @id int;
                                if not exists (select top 1 id from wx_t_customers where name=@userid)
                                select '00','0'
                                else
                                begin
                                select @id=id from wx_t_customers where name=@userid;
                                update wx_t_customers set cname=@name,department=@dept,position=@position,mobile=@mobile,
                                email=@email,weixinid=@weixinid,isactive=@enable,gender=@gender
                                where name=@userid;
                                select '11',@id;
                                end";

            List<SqlParameter> paras = new List<SqlParameter>();
            paras.Add(new SqlParameter("@userid", guid));
            paras.Add(new SqlParameter("@name", name));
            paras.Add(new SqlParameter("@dept", dept));
            paras.Add(new SqlParameter("@position", position));
            paras.Add(new SqlParameter("@mobile", mobile));
            paras.Add(new SqlParameter("@email", email));
            paras.Add(new SqlParameter("@weixinid", weixinid));
            paras.Add(new SqlParameter("@enable", enable));
            paras.Add(new SqlParameter("@gender", gender));
            DataTable dt = null;
            string errinfo = dal.ExecuteQuerySecurity(str_sql, paras, out dt);
            if (errinfo == "" && dt.Rows.Count > 0)
            {
                if (Convert.ToString( dt.Rows[0][0]) == "00")
                    rtMsg = "Error:对不起，本地找不到此用户信息！【guid】："+guid;
                else if (Convert.ToString(dt.Rows[0][0]) == "11")
                {
                    //提交微信更新 
                    string postURL = string.Format("https://qyapi.weixin.qq.com/cgi-bin/user/update?access_token={0}", QYAccessToken);
                    string content = postDataToWX(postURL, jStr);
                    jh = clsJsonHelper.CreateJsonHelper(content);
                    errinfo = jh.GetJsonValue("errcode");
                    if (errinfo == "40001" || errinfo == "40014" || errinfo == "42001")
                    {
                        ClearAT();
                        rtMsg = "Error:" + content;
                    }
                    else if (errinfo != "0")
                        rtMsg = "Error:" + content;
                    else if (errinfo == "0")
                        rtMsg = clsSharedHelper.Successed + Convert.ToString(dt.Rows[0][1]);
                }//end update in weixin
            }
            else
                rtMsg = "Error:更新成员时查询失败 " + errinfo;
        }

        return rtMsg;
    }

    /// <summary>
    /// 清除对应的access_token接口
    /// </summary>
    private void ClearAT()
    {
        //string ATURL = string.Format("http://10.0.0.15/wxdevelopment/QYWX/WXAccessTokenManager.aspx?ctrl={0}&key={1}", "ClearAT", QYWXKEY);
        //clsNetExecute.HttpRequest(ATURL);
        //lock (_syncObj)
        //{
        //    _QYWXAT = "";
        //}
        clsWXHelper.ClearAT(ConfigKeyValue);
    }

    /// <summary>
    /// 转换为MD5
    /// </summary>
    /// <param name="s"></param>
    /// <returns></returns>
    private string String2MD5(string s)
    {
        byte[] bytes = Encoding.Unicode.GetBytes(s);
        byte[] buffer2 = new MD5CryptoServiceProvider().ComputeHash(bytes);
        StringBuilder pw = new StringBuilder();
        foreach (byte _byte in buffer2)
            pw.Append(_byte.ToString("X2"));

        return pw.ToString();
    }
    /// <summary>
    /// POST 数据到微信服务器
    /// </summary>
    /// <param name="url"></param>
    /// <param name="datas"></param>
    /// <returns></returns>
    private String postDataToWX(String url, String datas)
    {
        //Encoding encoding = Encoding.GetEncoding("GB2312");
        Encoding encoding = Encoding.UTF8;
        byte[] data = encoding.GetBytes(datas);
        HttpWebRequest myRequest = (HttpWebRequest)WebRequest.Create(url);
        myRequest.Method = "POST";
        myRequest.Timeout = 10000;
        myRequest.ContentType = "application/x-www-form-urlencoded";
        myRequest.ContentLength = data.Length;
        Stream newStream = myRequest.GetRequestStream();
        newStream.Write(data, 0, data.Length);
        newStream.Close();
        HttpWebResponse myResponse = (HttpWebResponse)myRequest.GetResponse();
        StreamReader reader = new StreamReader(myResponse.GetResponseStream(), Encoding.Default);
        string result = reader.ReadToEnd();
        return result;
    }

    private void WriteLog(string strText)
    {
        String path = HttpContext.Current.Server.MapPath("logs/");
        if (!System.IO.Directory.Exists(System.IO.Path.GetDirectoryName(path)))
        {
            System.IO.Directory.CreateDirectory(path);
        }

        System.IO.StreamWriter writer = new System.IO.StreamWriter(path + DateTime.Now.ToString("yyyyMMdd") + ".log", true);
        string str;
        str = "【" + DateTime.Now.ToString() + "】" + "  " + strText;
        writer.WriteLine(str);
        writer.Close();
    }
</script>

<html xmlns="http://www.w3.org/1999/xhtml">
<head id="Head1" runat="server">
</head>
<body>

</body>
</html>
