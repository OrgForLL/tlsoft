<%@ Page Language="C#" Debug="true" %>
<%@ Import Namespace="nrWebClass" %>
<%@ Import Namespace="System.Data" %>
<%@ Import Namespace="WebBLL.Core" %>
<%@ Import Namespace="System.Data.SqlClient" %>
<%@ Import Namespace="System.Collections.Generic" %>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<script runat="server">
    string ConnectionString = "server='192.168.35.23';uid=lllogin;pwd=rw1894tla;database=tlsoft";
    protected void Page_Load(object sender, EventArgs e)
    {
        string ctrl,rt;
        try
        {
            ctrl = Convert.ToString(Request.Params["ctrl"]);
        }
        catch (Exception ex)
        {
            ctrl ="";
            Response.Write("非法访问"+ex.ToString());
            Response.End();
        }
        
       /* string name =Convert.ToString( Session["wxopenid"]);
        if (name == null || name == "")
        {
            Response.Write(clsNetExecute.Error+"|访问超时");
            Response.End();
        }*/
        
        switch (ctrl)
        {
            case "GetPersonInfo":
                string name = Convert.ToString(Request.Params["userid"]);
                rt = GetPersonInfo(name);
                break;
            case "getDays":
                string kssj = Convert.ToString(Request.Params["kssj"]);
                string jssj = Convert.ToString(Request.Params["jssj"]);
                rt = getDays(kssj,jssj);
                break;
            case "saveDate":
                LeaveInfo l = new LeaveInfo();
                    l.xm = Convert.ToString(Request.Params["xm"]);
                    l.ryid = Convert.ToString(Request.Params["ryid"]);
                    l.rybh = Convert.ToString(Request.Params["rybh"]);
                    l.lxdh = Convert.ToString(Request.Params["lxdh"]);
                    l.qjlx = Convert.ToString(Request.Params["qjlx"]);
                    l.kssj = Convert.ToString(Request.Params["kssj"]);
                    l.jssj = Convert.ToString(Request.Params["jssj"]);
                    l.ksday = Convert.ToString(Request.Params["ksday"]);
                    l.jsday = Convert.ToString(Request.Params["jsday"]);
                    l.qjsj = Convert.ToString(Request.Params["qjsj"]);
                    l.qjyy = Convert.ToString(Request.Params["qjyy"]);
                    l.id = Convert.ToInt32(Request.Params["id"]);
                    string type = Convert.ToString(Request.Params["saveType"]);
                  rt = saveInfo(l, type);           
                break;
            default: rt = "无效参数";
                break;
        }
        clsSharedHelper.WriteInfo(rt);
    } 
    /// <summary>
    /// 保存请假数据
    /// </summary>
    /// <param name="l"></param>
    /// <param name="type"></param>
    /// <returns></returns>
    public string saveInfo(LeaveInfo l, string type)
    {
        string username =Convert.ToString(Session["username"]);
        string userid = Convert.ToString(Session["userid"]);
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
        using (LiLanzDALForXLM dal = new LiLanzDALForXLM(ConnectionString))
        {
            errInfo = dal.ExecuteQuerySecurity(mysql, para, out dt);
            para = null;
            mysql = null;
            l = null;
            
            if (errInfo == "")
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

        if (errInfo != "")
        {
            rt = errInfo;
        }
        else
        {
            string id =Convert.ToString( dt.Rows[0]["id"]);
            rt =  clsNetExecute.Successed + "|"+id;
        }
        return rt;
    }
    
    /// <summary>
    /// 获取请假天数，请假跨过节假日不带薪、周日有上班算请假
    /// </summary>
    /// <param name="kssj"></param>
    /// <param name="jssj"></param>
    /// <returns></returns>
    public string getDays(string kssj,string jssj)
    {
        string rt = "",errInfo="";
        string mysql = @"declare @kssj varchar(10);
                        declare @jssj varchar(10);
                        select @kssj=dateadd(day,-1,'"+kssj+"'),@jssj='"+jssj+@"';
                        select DATEDIFF(day,@kssj,@jssj)-DATEDIFF(wk,@kssj,@jssj)+isnull((
                        select  sum(duration) from HOLIDAYS where holidaytype=3 and starttime>=@kssj and starttime<=@jssj
                        ),0) as qjts";
        DataTable dt = new DataTable();
        using (LiLanzDALForXLM dal = new LiLanzDALForXLM(ConnectionString))
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
    /// 获取个人信息
    /// </summary>
    /// <param name="name"></param>
    /// <returns></returns>
    public string GetPersonInfo(string name)
    {
        string rt="";
        string mySql = @"select a.id as userid,a.cname as username, b.xm as cname, b.rybh,b.yddh as lxdh,b.id as ryid,b.bmmc                       
                        from t_user a inner join rs_v_oaryzhcx b on a.ryid=b.id
                        where name=@name";
         List<SqlParameter> para = new List<SqlParameter>();
        para.Add(new SqlParameter("@name", name));
        DataTable dt = new DataTable();
        string errInfo = "";
        using (LiLanzDALForXLM dal = new LiLanzDALForXLM(ConnectionString))
        {
            errInfo = dal.ExecuteQuerySecurity(mySql, para, out dt);
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
             json.AddJsonVar("cname", Convert.ToString(dt.Rows[0]["cname"]));
             json.AddJsonVar("rybh", Convert.ToString(dt.Rows[0]["rybh"]));
             json.AddJsonVar("lxdh", Convert.ToString(dt.Rows[0]["lxdh"]));
             json.AddJsonVar("ryid", Convert.ToString(dt.Rows[0]["ryid"]));
             json.AddJsonVar("bmmc", Convert.ToString(dt.Rows[0]["bmmc"]));
             Session["userid"] = Convert.ToString(dt.Rows[0]["userid"]);
             Session["username"] = Convert.ToString(dt.Rows[0]["username"]);
             Session["rybh"] = Convert.ToString(dt.Rows[0]["rybh"]);
             Session["ryid"] = Convert.ToString(dt.Rows[0]["ryid"]);
             rt = json.jSon;
             json = null;
             dt = null;
        }
        return rt;
    }
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
</script>
<html xmlns="http://www.w3.org/1999/xhtml">
<head id="Head1"  runat="server">
<title></title>
</head>
<body>
 

</body>
</html>
