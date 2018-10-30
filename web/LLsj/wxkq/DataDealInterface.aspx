<%@ Page Language="C#" %>
<%@ Import Namespace="nrWebClass" %>
<%@ Import Namespace="System.Data" %>
<%@ Import Namespace="System.Data.SqlClient" %>
<%@ Import Namespace="System.Collections.Generic" %>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<script runat="server">
  
    public string connStr_tlsoft ="";
    public string connStr_att2000 = "";
    protected void Page_Load(object sender, EventArgs e)
    {
        connStr_tlsoft = clsConfig.GetConfigValue("OAConnStr");
        SqlConnection sqlconn = (SqlConnection)Class_BBlink.LILANZ.DatabaseConn.Connection("att2000");
        connStr_att2000 = sqlconn.ConnectionString;
        sqlconn.Dispose();
        
        string ctrl, rt="";
        string userid = "", username = "", rybh = "", ryid = "",checkuserid="";

        userid = Convert.ToString(Session["wxkq_userid"]);
        username = Convert.ToString(Session["wxkq_username"]);
        //checkuserid = Convert.ToString(Session["wxkq_checkuserid"]);
        rybh = Convert.ToString(Session["wxkq_rybh"]);
        ryid = Convert.ToString(Session["wxkq_ryid"]);
        //session 不存在返回超时
        if (userid == null || userid == "")
        {
            clsSharedHelper.WriteErrorInfo("访问超时！");
        }
        
        try
        {
            ctrl = Convert.ToString(Request.Params["ctrl"]);
        }
        catch (Exception ex)
        {
            ctrl = "";
            clsSharedHelper.WriteErrorInfo("非法访问:" + ex.ToString());
        }

        switch (ctrl)
        {
            //请假 linwy
            case "getDays":
                string kssj = Convert.ToString(Request.Params["kssj"]);
                string jssj = Convert.ToString(Request.Params["jssj"]);
                rt = getDays(kssj, jssj);
                break;
            case "saveDate":
                LeaveInfo l = new LeaveInfo();
                l.xm = username;
                l.ryid = ryid;
                l.rybh = rybh;
                l.lxdh = Convert.ToString(Request.Params["lxdh"]);
                l.qjlx = Convert.ToString(Request.Params["qjlx"]);
                l.kssj = Convert.ToString(Request.Params["kssj"]);
                l.jssj = Convert.ToString(Request.Params["jssj"]);
                l.ksday = Convert.ToString(Request.Params["ksday"]);
                l.jsday = Convert.ToString(Request.Params["jsday"]);
                l.qjsj = Convert.ToString(Request.Params["qjsj"]);
                l.qjyy = Convert.ToString(Request.Params["qjyy"]);
                l.id = Convert.ToInt32(Request.Params["id"]);
                string leavetype = Convert.ToString(Request.Params["saveType"]);
                rt = saveReqLeaveInfo(l, leavetype);
                break;
                //签卡 cmg
            case "check_ryxz":
                string checkdate = Convert.ToString(Request.Params["checkdate"]);
                rt = checkBC(checkdate, Convert.ToString(Request.Params["userid"]));
                break;
            case "check_ryxx":
                rt = checkRyxx(Convert.ToString(Request.Params["name"]));
                break;
            case "SaveCheckDate":
                CheckInfo check = new CheckInfo();
                check.username = Convert.ToString(Request.Params["username"]);
                check.name = Convert.ToString(Request.Params["name"]);
                check.userid = Convert.ToString(Request.Params["userid"]);
                check.rybh = Convert.ToString(Request.Params["rybh"]);
                check.checkdate = Convert.ToDateTime(Request.Params["checkdate"]);
                check.bc = Convert.ToString(Request.Params["bc"]);
                check.qdqt = Convert.ToInt32(Request.Params["qdqt"]);
                check.yy = Convert.ToString(Request.Params["yy"]);
                check.id = Convert.ToInt32(Request.Params["id"]);
                string checktype = Convert.ToString(Request.Params["saveType"]);
                rt = saveCheckInfo(check, checktype);
                break;
                //调休 lqf
            case "checkHoliday":
                string jbrq = Convert.ToString(Request.Params["jbrq"]);
                string holidayType = Convert.ToString(Request.Params["holidayType"]);
                checkHoliday(jbrq, holidayType);
                break;
            case "checkWorkDay":
                jbrq = Convert.ToString(Request.Params["jbrq"]);
                rybh = Convert.ToString(Request.Params["rybh"]);
                string txts = Convert.ToString(Request.Params["txts"]);
                string id = Convert.ToString(Request.Params["id"]);
                if (jbrq == null || jbrq == "" || rybh == "" || rybh == null || txts == "" || txts == null || id == "" || id == null)
                {
                    clsSharedHelper.WriteErrorInfo("参数有误");
                }
                else
                    checkWorkDay(jbrq, txts, rybh, id);
                break;
            case "loadWorkTimes":
                jbrq = Convert.ToString(Request.Params["jbrq"]);
                rybh = Convert.ToString(Request.Params["rybh"]);
                loadWorkTimes(rybh, jbrq);
                break;
            case "SaveData":
                string jsonStr = Convert.ToString(Request.Params["jsonData"]);
                string savetype = Convert.ToString(Request.Params["savetype"]);
                if (jsonStr == "" || jsonStr == null)
                    clsSharedHelper.WriteErrorInfo("JSON参数不能为空！");
                else
                    SaveData(jsonStr, savetype);
                break;
            default: rt = "无【CTRL=" + ctrl + "】对应操作！";
                break;
        }
        clsSharedHelper.WriteInfo(rt);
    }
    public void loadWorkTimes(string rybh, string jbrq)
    {
        using (LiLanzDALForXLM dal = new LiLanzDALForXLM(connStr_att2000))
        {
            string sql = @"declare @yhid int;SELECT @yhid=userid FROM USERINFO WHERE cast(badgenumber as int)={0};
                            select top 1 dkjl=stuff((select ','+Convert(varchar(10),CHECKTIME,120)+'|'+Convert(varchar(8),CHECKTIME,114) +'|'+cast(DATEPART(dw,CHECKTIME) as varchar(3))+'|'+(CASE WHEN CHECKTYPE='I' then '上班' else '下班' end)
                            from CHECKINOUT a where a.userid=b.userid and Convert(varchar(10),a.CHECKTIME,120)=Convert(varchar(10),b.CHECKTIME,120) for XML path('')),1,1,'')
                            from CHECKINOUT b where userid=@yhid AND CHECKTIME >= '{1}' AND CHECKTIME < DATEADD(day, 1 , '{1}')";
            sql = string.Format(sql, rybh, jbrq);
            DataTable dt = null;
            string errinfo = dal.ExecuteQuery(sql, out dt);
            if (errinfo == "")
            {
                if (dt.Rows.Count > 0)
                    clsSharedHelper.WriteSuccessedInfo(dt.Rows[0][0].ToString());
                else
                    clsSharedHelper.WriteSuccessedInfo("");
            }
            else
                clsSharedHelper.WriteErrorInfo("加载打卡记录时出错：" + errinfo);
        }
    }

    public void checkHoliday(string jbrq, string holidayType)
    {
        jbrq = Convert.ToDateTime(jbrq).ToString("yyyy-MM-dd");
        string sql = "";
        using (LiLanzDALForXLM dal = new LiLanzDALForXLM(connStr_att2000))
        {
            if (holidayType == "0")
            {
                sql = @"if exists (select * from  HOLIDAYS  where Convert(varchar(10),starttime,120)<='{0}' 
                           and '{0}'<=Convert(varchar(10),Dateadd(d, duration-1,starttime),120)) begin select bs=1 end else begin select bs=0 end;";
            }
            else if (holidayType == "3")
            {
                sql = @"if exists (select * from  HOLIDAYS  where starttime='{0}' and holidaytype=3) begin select bs=1 end else begin select bs=0 end";
            }
            if (sql == "holidayType is not find!")
                clsSharedHelper.WriteInfo("sql is null");
            else
            {
                sql = string.Format(sql, jbrq);
                DataTable dt = null;
                string errInfo = dal.ExecuteQuery(sql, out dt);
                if (errInfo == "")
                {
                    if (dt.Rows.Count > 0)
                        clsSharedHelper.WriteSuccessedInfo(dt.Rows[0][0].ToString());
                    else
                        clsSharedHelper.WriteErrorInfo("验证加班日期时查无数据！");
                }
                else
                    clsSharedHelper.WriteErrorInfo("验证加班日期时发生错误：" + errInfo);
            }
        }
    }

    //检查加班日期
    public void checkWorkDay(string jbrq, string txts, string rybh, string id)
    {
        string sql = "";
        using (LiLanzDALForXLM dal = new LiLanzDALForXLM(connStr_tlsoft))
        {
            sql = @"select case when  isnull(sum(qjsj),0)+{0}>1 then 0 else 1 end as bs  from kq_T_ygqjb where rybh='{1}'and jbrq='{2}' and id<>{3}";
            sql = string.Format(sql, txts, rybh, jbrq, id);
            DataTable dt = null;
            string errinfo = dal.ExecuteQuery(sql, out dt);
            if (errinfo == "")
            {
                if (dt.Rows.Count > 0)
                    clsSharedHelper.WriteSuccessedInfo(dt.Rows[0][0].ToString());
            }
            else
                clsSharedHelper.WriteErrorInfo(errinfo);
        }
    }

    //保存单据
    public void SaveData(string jsonData, string savetype)
    {
        string sql = "";
        clsJsonHelper jh = clsJsonHelper.CreateJsonHelper(jsonData);
        using (LiLanzDALForXLM dal = new LiLanzDALForXLM(connStr_tlsoft))
        {
            string tzid = jh.GetJsonValue("tzid");
            string rybh = jh.GetJsonValue("rybh");
            string lx = jh.GetJsonValue("lx");
            string kssj = jh.GetJsonValue("kssj");
            string jssj = jh.GetJsonValue("jssj");
            string qjsj = jh.GetJsonValue("qjsj");
            string qjyy = HttpUtility.UrlDecode(jh.GetJsonValue("qjyy"));
            string lxdh = jh.GetJsonValue("lxdh");
            string zdr = jh.GetJsonValue("zdr");
            string ryid = jh.GetJsonValue("ryid");
            string ksday = jh.GetJsonValue("ksday");
            string jsday = jh.GetJsonValue("jsday");
            string jbrq = jh.GetJsonValue("jbrq");
            string userid = jh.GetJsonValue("userid");
            string flowid = jh.GetJsonValue("flowid");
            sql = @"declare @newid int;insert into kq_t_ygqjb(tzid, rq, rybh, lx, kssj, jssj, qjsj, qjyy,lxdh,zdr,zdrq,ryid,ksday,jsday,jbrq,flowid )
                    values (@tzid,getdate(),@rybh,@lx,@kssj,@jssj,@qjsj,@qjyy,@lxdh,@zdr,getdate(),@ryid,@ksday,@jsday,@jbrq,@flowid);
                    select @newid=SCOPE_IDENTITY();";

            List<SqlParameter> paras = new List<SqlParameter>();
            paras.Add(new SqlParameter("@tzid", tzid));
            paras.Add(new SqlParameter("@rybh", rybh));
            paras.Add(new SqlParameter("@lx", lx));
            paras.Add(new SqlParameter("@kssj", kssj));
            paras.Add(new SqlParameter("@jssj", jssj));
            paras.Add(new SqlParameter("@qjsj", qjsj));
            paras.Add(new SqlParameter("@qjyy", qjyy));
            paras.Add(new SqlParameter("@lxdh", lxdh));
            paras.Add(new SqlParameter("@zdr", zdr));
            paras.Add(new SqlParameter("@ryid", ryid));
            paras.Add(new SqlParameter("@ksday", ksday));
            paras.Add(new SqlParameter("@jsday", jsday));
            paras.Add(new SqlParameter("@jbrq", jbrq));
            paras.Add(new SqlParameter("@flowid", flowid));

            //保存并自动办理第一步
            if (savetype == "SaveAndSend")
            {
                string fl_sql = "EXEC flow_up_start {0},{1},@newid,'',{2},{3},{4},'';";
                fl_sql = string.Format(fl_sql, 1, 1, flowid, userid, zdr);
                sql = sql + fl_sql;
            }

            string errinfo = dal.ExecuteNonQuerySecurity(sql, paras);
            if (errinfo == "")
            {
                clsSharedHelper.WriteSuccessedInfo("");
            }
            else
                clsSharedHelper.WriteErrorInfo("保存失败 原因：" + errinfo);
        }
        clsSharedHelper.WriteSuccessedInfo("");
    }
    /// <summary>
    /// 保存签卡信息
    /// </summary>
    /// <param name="l"></param>
    /// <returns></returns>
    public string saveCheckInfo(CheckInfo l, string checktype)
    {

        string rt = "", errInfo;

        List<SqlParameter> para = new List<SqlParameter>();

        string mysql = @"declare @id int;
                        declare @selectSj datetime;declare @sl int;
                        set @sl=@qdqt;
                        select @selectSj=case when @sl=1 then c.starttime  else c.endtime end from USER_OF_RUN a  
                        inner join NUM_RUN_DEIL b on a.num_of_run_id=b.num_runid inner join SchClass c  on b.schclassid=c.schclassid
                        WHERE a.userid=@userid and a.startdate<=@checkdate and a.enddate>=@checkdate and c.schname=@bc ;";
        if (l.id == 0)
        {
            mysql += @" insert into CHECKEXACT (userid,checktime,checktype,isadd,yuyin,modifyby,date,flowid) values 
                        (@userid,@checkdate+''+CONVERT(varchar(10),@selectSj,8),'I',0,@yy,@username,getdate(),340); SET @id=SCOPE_IDENTITY();";
        }
        else
        {
            mysql += @" UPDATE CHECKEXACT SET userid=@userid,checktime=@checkdate+' '+CONVERT(varchar(100), @selectSj, 8),yuyin=@yy 
                        where exactid=@myid and isnull(checkid,0)=0; SET @id=@myid; ";

        }
       mysql += " select @id as id";
        para.Add(new SqlParameter("@myid", l.id));
        para.Add(new SqlParameter("@username", l.username));
        para.Add(new SqlParameter("@rybh", l.rybh));
        para.Add(new SqlParameter("@userid", l.userid));
        para.Add(new SqlParameter("@checkdate", l.checkdate));
        para.Add(new SqlParameter("@bc", l.bc));
        para.Add(new SqlParameter("@qdqt", l.qdqt));
        para.Add(new SqlParameter("@yy", l.yy));
    //    Response.Write("<script  language=javascript>alert(mysql);<" + "/" + "script>");
        DataTable dt;
        using (LiLanzDALForXLM dal = new LiLanzDALForXLM(connStr_att2000))
        {
          
            errInfo = dal.ExecuteQuerySecurity(mysql, para,out dt);
            para = null;
            mysql = null;
            l = null;

        }
        if (errInfo != "")
        {
            rt = errInfo;
        }
        else
        {
            using (LiLanzDALForXLM dal = new LiLanzDALForXLM(connStr_tlsoft))
            {
                if (checktype == "send")
                {
                    mysql = "EXEC flow_up_start 1,1,{0},'',{1},{2},{3},'';";
                    try
                    {
                        mysql = string.Format(mysql, Convert.ToString(dt.Rows[0]["id"]), 340, Session["wxkq_userid"], Session["wxkq_username"]);
                        errInfo = dal.ExecuteNonQuery(mysql);
                    }
                    catch (Exception ex)
                    {
                        errInfo = ex.ToString();
                    }
                }
            }
            if (errInfo == "")
            {
                rt = clsNetExecute.Successed + "|保存成功！";
            }
            else
            {
                rt = errInfo;
            }
        }
        return rt;
    }
    /// <summary>
    /// 获取签卡人员的班次
    ///  </summary>
    /// <param name="checkdate"></param>
    /// <param name="userid"></param>
    /// <returns></returns>
    public string checkBC(string checkdate, string userid)
    {
        string rt = "", errInfo = "";
        string mysql = @"select  c.schname as dm,c.schname  from USER_OF_RUN a inner join NUM_RUN_DEIL b on a.num_of_run_id=b.num_runid inner join SchClass c  on b.schclassid=c.schclassid 
                         WHERE a.userid=@userid and a.startdate<=@checkdate and a.enddate>=@checkdate";
        List<SqlParameter> para = new List<SqlParameter>();
        para.Add(new SqlParameter("@checkdate", checkdate));
        para.Add(new SqlParameter("@userid", userid));
        DataTable dt = new DataTable();
        using (LiLanzDALForXLM dal = new LiLanzDALForXLM(connStr_att2000))
        {
            errInfo = dal.ExecuteQuerySecurity(mysql, para, out dt);
            para = null;

        }
        if (errInfo != "")
        {
            rt = errInfo;
        }
        else if (dt.Rows.Count < 1)
        {
            rt = clsNetExecute.Error + "未找到用户班次信息";
        }
        else
        {
            clsJsonHelper json = new clsJsonHelper();
            json.AddJsonVar("schname", Convert.ToString(dt.Rows[0]["schname"]));
            json.AddJsonVar("schname1", Convert.ToString(dt.Rows[1]["schname"]));
            rt = json.jSon;
            json = null;
            dt = null;
        }
        return rt;
    }
   /// <summary>
   /// 
   /// </summary>
   /// <param name="name"></param>
   /// <returns></returns>
    public string checkRyxx(string name)
    {
        string rt = "", errInfo = "";
        string mysql = @" SELECT distinct a.userid,a.name xm,a.badgenumber rybh,b.deptname bmmc  FROM USERINFO a 
                          left JOIN DEPARTMENTS b on a.defaultdeptid=b.DEPTID  WHERE   a.name like @name order by a.userid,a.name; ";
        List<SqlParameter> para = new List<SqlParameter>();
        para.Add(new SqlParameter("@name", name));
        DataTable dt = new DataTable();

        using (LiLanzDALForXLM dal = new LiLanzDALForXLM(connStr_att2000))
        {
            errInfo = dal.ExecuteQuerySecurity(mysql, para, out dt);
            para = null;
        }
        if (errInfo != "")
        {
            rt = errInfo;
        }
        else if (dt.Rows.Count < 1)
        {
            rt = clsNetExecute.Error + "未找到用户信息";
        }
        else
        {
            clsJsonHelper json = new clsJsonHelper();
            json.AddJsonVar("userid", Convert.ToString(dt.Rows[0]["userid"]));
            json.AddJsonVar("rybh", Convert.ToString(dt.Rows[0]["rybh"]));
            json.AddJsonVar("name", Convert.ToString(dt.Rows[0]["xm"]));
            json.AddJsonVar("bmmc", Convert.ToString(dt.Rows[0]["bmmc"]));
            rt = json.jSon;
            json = null;
            dt = null;
        }
        return rt;
    }
    /// <summary>
    /// 保存请假数据
    /// </summary>
    /// <param name="l"></param>
    /// <param name="type"></param>
    /// <returns></returns>
    public string saveReqLeaveInfo(LeaveInfo l, string type)
    {
        string username = Convert.ToString(Session["wxkq_username"]);
        string userid = Convert.ToString(Session["wxkq_userid"]);
        if (userid == null || username == null || userid == "" || username == "")
        {
            return "登陆超时";
        }
        string rt = "", errInfo;
        List<SqlParameter> para = new List<SqlParameter>();
        string mysql = @"
                        DECLARE @flowid int;
                        DECLARE @id int;
                        select @flowid=case when (dbo.split(a.ccid,'-',3) in(738,896,819,816) and a.rybh<>'6066') then 338 when dbo.split(a.ccid,'-',3) in(944) then 339 else 337 end  
                        from rs_v_oaryzhcx a inner join rs_t_bmdmb b on dbo.split(a.ccid,'-',3)=b.id  where  a.rybh=@rybh;";
        if (l.id == 0)
        {
            mysql += @" INSERT INTO kq_t_ygqjb(tzid, rq, rybh, lx, kssj, jssj, qjsj, qjyy,zwdlr,lxdh,zdlx,zdr,zdrq,ksday,jsday,flowid,ryid) 
                        VALUES(1,getdate(),@rybh,@lx,@kssj,@jssj,@qjsj, @qjyy,'',@lxdh,1,@zdr,getdate(),@ksday,@jsday,@flowid,@ryid);  SET @id=SCOPE_IDENTITY();";
            para.Add(new SqlParameter("@zdr", l.xm));
            para.Add(new SqlParameter("@ryid", l.ryid));
        }
        else
        {
            mysql += " UPDATE kq_t_ygqjb SET lx=@lx,kssj=@kssj,jssj=@jssj,qjsj=@qjsj,qjyy=@qjyy,ksday=@ksday,jsday=@jsday,lxdh=@lxdh where id=@MyDjid; SET @id=@MyDjid;";
            para.Add(new SqlParameter("@MyDjid", l.id));
        }
        mysql += " select @id as id,@flowid as flowid ";
        para.Add(new SqlParameter("@rybh", l.rybh));
        para.Add(new SqlParameter("@lx", l.qjlx));
        para.Add(new SqlParameter("@kssj", l.kssj));
        para.Add(new SqlParameter("@jssj", l.jssj));
        para.Add(new SqlParameter("@qjsj", l.qjsj));
        para.Add(new SqlParameter("@qjyy", l.qjyy));
        para.Add(new SqlParameter("@ksday", l.ksday));
        para.Add(new SqlParameter("@jsday", l.jsday));
        para.Add(new SqlParameter("@lxdh", l.lxdh));

        DataTable dt;
        using (LiLanzDALForXLM dal = new LiLanzDALForXLM(connStr_tlsoft))
        {
            errInfo = dal.ExecuteQuerySecurity(mysql, para, out dt);
            para = null;
            mysql = null;
            l = null;

            if (errInfo == "")
            {
                if (type == "saveandsend")
                {
                    mysql = "EXEC flow_up_start 1,1,{0},'',{1},{2},{3},'';";
                    try
                    {
                        mysql = string.Format(mysql, Convert.ToString(dt.Rows[0]["id"]), Convert.ToString(dt.Rows[0]["flowid"]), userid, username);
                        errInfo = dal.ExecuteNonQuery(mysql);
                    }
                    catch (Exception ex)
                    {
                        errInfo = ex.ToString();
                    }
                }
            }
        }

        if (errInfo != "")
        {
            rt = errInfo;
        }
        else
        {
            string id = Convert.ToString(dt.Rows[0]["id"]);
            rt = clsNetExecute.Successed + "|" + id;
        }
        return rt;
    }
    /// <summary>
    /// 获取请假天数，请假跨过节假日不带薪、周日有上班算请假
    /// </summary>
    /// <param name="kssj"></param>
    /// <param name="jssj"></param>
    /// <returns></returns>
    public string getDays(string kssj, string jssj)
    {
        string rt = "", errInfo = "";
        string mysql = @"declare @kssj varchar(10);
                        declare @jssj varchar(10);
                        select @kssj=dateadd(day,-1,'" + kssj + "'),@jssj='" + jssj + @"';
                        select DATEDIFF(day,@kssj,@jssj)-DATEDIFF(wk,@kssj,@jssj)+isnull((
                        select  sum(duration) from HOLIDAYS where holidaytype=3 and starttime>=@kssj and starttime<=@jssj
                        ),0) as qjts";
        DataTable dt = new DataTable();
        using (LiLanzDALForXLM dal = new LiLanzDALForXLM(connStr_att2000))
        {
            errInfo = dal.ExecuteQuery(mysql, out dt);

        }
        if (errInfo != "")
        {
            rt = errInfo;
        }
        else
        {
            rt = Convert.ToString(dt.Rows[0]["qjts"]);
            dt = null;
        }
        return rt;
    }
    /// <summary>
    /// 请假数据对象
    /// </summary>
    public class LeaveInfo
    {
        private string _xm;
        private string _ryid;
        private string _rybh;
        private string _lxdh;
        private string _qjlx;
        private string _kssj;
        private string _jssj;
        private string _ksday;
        private string _jsday;
        private string _qjsj;
        private string _qjyy;
        private int _id;
        public string xm
        {
            get { return _xm; }
            set { _xm = value; }
        }
        public string ryid
        {
            get { return _ryid; }
            set { _ryid = value; }
        }
        public string rybh
        {
            get { return _rybh; }
            set { _rybh = value; }
        }
        public string lxdh
        {
            get { return _lxdh; }
            set { _lxdh = value; }
        }
        public string qjlx
        {
            get { return _qjlx; }
            set { _qjlx = value; }
        }
        public string kssj
        {
            get { return _kssj; }
            set { _kssj = value; }
        }
        public string jssj
        {
            get { return _jssj; }
            set { _jssj = value; }
        }
        public string ksday
        {
            get { return _ksday; }
            set { _ksday = value; }
        }
        public string jsday
        {
            get { return _jsday; }
            set { _jsday = value; }
        }
        public string qjsj
        {
            get { return _qjsj; }
            set { _qjsj = value; }
        }
        public string qjyy
        {
            get { return _qjyy; }
            set { _qjyy = value; }
        }
        public int id
        {
            get { return _id; }
            set { _id = value; }
        }
    }
    /// <summary>
    /// 签卡信息
    /// </summary>
    public class CheckInfo
    {
        private string _name;
        private string _rybh;
        private string _userid;
        private DateTime _checkdate;
        private string _bc;
        private int _qdqt;
        private string _yy;
        private string _username;
        private int _id;
        public string name
        {
            get { return _name; }
            set { _name = value; }
        }
        public string rybh
        {
            get { return _rybh; }
            set { _rybh = value; }
        }
        public string userid
        {
            get { return _userid; }
            set { _userid = value; }
        }
        public DateTime checkdate
        {
            get { return _checkdate; }
            set { _checkdate = value; }
        }
        public string bc
        {
            get { return _bc; }
            set { _bc = value; }
        }
        public int qdqt
        {
            get { return _qdqt; }
            set { _qdqt = value; }
        }
        public string yy
        {
            get { return _yy; }
            set { _yy = value; }
        }
        public string username
        {
            get { return _username; }
            set { _username = value; }
        }
        public int id
        {
            get { return _id; }
            set { _id = value; }
        }
    }
</script>
<html xmlns="http://www.w3.org/1999/xhtml">
<head id="Head1"  runat="server">
<title></title>
</head>
<body>
 

</body>
</html>
