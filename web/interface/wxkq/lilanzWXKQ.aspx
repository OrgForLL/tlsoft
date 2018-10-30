<%@ Page Language="C#" %>

<%@ Import Namespace="nrWebClass" %>
<%@ Import Namespace="System.Collections.Generic" %>
<%@ Import Namespace="System.Data.SqlClient" %>
<%@ Import Namespace="System.Data" %>
<%@ Import Namespace="WebBLL.Core" %>
<%@ Import Namespace="nrWebClass"%>
<!DOCTYPE html>
<script runat="server">        
    public string connStr="server='192.168.35.23';uid=lllogin;pwd=rw1894tla;database=tlsoft";
    protected void Page_Load(object sender, EventArgs e)
    {
        string ctrl = Convert.ToString(Request.Params["ctrl"]);
                
        switch (ctrl)
        {
            case "checkHoliday":
                string jbrq = Convert.ToString(Request.Params["jbrq"]);
                string type = Convert.ToString(Request.Params["holidayType"]);                
                checkHoliday(jbrq, type);
                break;
            case "checkWorkDay":
                jbrq = Convert.ToString(Request.Params["jbrq"]);
                string rybh = Convert.ToString(Request.Params["rybh"]);
                string txts = Convert.ToString(Request.Params["txts"]);
                string id = Convert.ToString(Request.Params["id"]);
                if (jbrq == null || jbrq == "" || rybh == "" || rybh == null || txts == "" || txts == null || id == "" || id == null) {
                    clsSharedHelper.WriteErrorInfo("参数有误");
                }else
                    checkWorkDay(jbrq,txts,rybh,id);
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
            default:
                clsSharedHelper.WriteErrorInfo("无【CTRL=" + ctrl + "】对应操作！");
                break;
        }
    }

    public void loadWorkTimes(string rybh,string jbrq) {
        using (LiLanzDALForXLM dal = new LiLanzDALForXLM()) {
            string sql = @"declare @yhid int;SELECT @yhid=userid FROM [192.168.35.30].att2000.dbo.USERINFO WHERE cast(badgenumber as int)={0};
                            select top 1 dkjl=stuff((select ','+Convert(varchar(10),CHECKTIME,120)+'|'+Convert(varchar(8),CHECKTIME,114) +'|'+cast(DATEPART(dw,CHECKTIME) as varchar(3))+'|'+(CASE WHEN CHECKTYPE='I' then '上班' else '下班' end)
                            from [192.168.35.30].att2000.dbo.CHECKINOUT a where a.userid=b.userid and Convert(varchar(10),a.CHECKTIME,120)=Convert(varchar(10),b.CHECKTIME,120) for XML path('')),1,1,'')
                            from [192.168.35.30].att2000.dbo.CHECKINOUT b where userid=@yhid AND CHECKTIME >= '{1}' AND CHECKTIME < DATEADD(day, 1 , '{1}')";
            sql = string.Format(sql, rybh, jbrq);
            DataTable dt = null;
            string errinfo = dal.ExecuteQuery(sql,out dt);
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
    
    public void checkHoliday(string jbrq,string holidayType) {
        jbrq = Convert.ToDateTime(jbrq).ToString("yyyy-MM-dd");
        string sql = "";
        using (LiLanzDALForXLM dal = new LiLanzDALForXLM()) {
            if (holidayType == "0") {
                sql = @"if exists (select * from  [192.168.35.30].att2000.dbo.HOLIDAYS  where Convert(varchar(10),starttime,120)<='{0}' 
                           and '{0}'<=Convert(varchar(10),Dateadd(d, duration-1,starttime),120)) begin select bs=1 end else begin select bs=0 end;";
            }
            else if (holidayType == "3") {
                sql = @"if exists (select * from  [192.168.35.30].att2000.dbo.HOLIDAYS  where starttime='{0}' and holidaytype=3) begin select bs=1 end else begin select bs=0 end";            
            }
            if (sql == "holidayType is not find!")
                clsSharedHelper.WriteInfo("sql is null");
            else {
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
    public void checkWorkDay(string jbrq,string txts,string rybh,string id) {        
        string sql = "";        
        using (LiLanzDALForXLM dal = new LiLanzDALForXLM()) {
            sql = @"select case when  isnull(sum(qjsj),0)+{0}>1 then 0 else 1 end as bs  from [192.168.35.10].tlsoft.dbo.kq_T_ygqjb where rybh='{1}'and jbrq='{2}' and id<>{3}";
            sql = string.Format(sql,txts,rybh,jbrq,id);
            DataTable dt = null;
            string errinfo = dal.ExecuteQuery(sql,out dt);
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
    public void SaveData(string jsonData,string savetype) {
        string sql = "";
        clsJsonHelper jh = clsJsonHelper.CreateJsonHelper(jsonData);
        using (LiLanzDALForXLM dal = new LiLanzDALForXLM(connStr)) {
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
            paras.Add(new SqlParameter("@tzid",tzid));
            paras.Add(new SqlParameter("@rybh",rybh));
            paras.Add(new SqlParameter("@lx",lx));
            paras.Add(new SqlParameter("@kssj",kssj));
            paras.Add(new SqlParameter("@jssj",jssj));
            paras.Add(new SqlParameter("@qjsj",qjsj));
            paras.Add(new SqlParameter("@qjyy",qjyy));
            paras.Add(new SqlParameter("@lxdh",lxdh));
            paras.Add(new SqlParameter("@zdr",zdr));
            paras.Add(new SqlParameter("@ryid",ryid));
            paras.Add(new SqlParameter("@ksday",ksday));
            paras.Add(new SqlParameter("@jsday",jsday));
            paras.Add(new SqlParameter("@jbrq",jbrq));
            paras.Add(new SqlParameter("@flowid", flowid));
            
            //保存并自动办理第一步
            if (savetype == "SaveAndSend") {                                
                string fl_sql = "EXEC flow_up_start {0},{1},@newid,'',{2},{3},{4},'';";
                fl_sql = string.Format(fl_sql, 1, 1, flowid, userid, zdr);
                sql = sql + fl_sql;
            }
            
            string errinfo = dal.ExecuteNonQuerySecurity(sql,paras);
            if (errinfo == "")
            {
                clsSharedHelper.WriteSuccessedInfo("");
            }
            else
                clsSharedHelper.WriteErrorInfo("保存失败 原因：" + errinfo);
        }
        clsSharedHelper.WriteSuccessedInfo("");
    }
</script>
<html lang="en" xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <meta charset="utf-8" />
    <title></title>
</head>
<body>
    <form id="form1" runat="server">
    </form>
</body>
</html>
