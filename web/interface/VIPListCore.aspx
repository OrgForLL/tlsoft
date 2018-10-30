<%@ Page Language="C#" %>

<%@ Import Namespace="nrWebClass" %>
<%@ Import Namespace="System.Data" %>
<%@ Import Namespace="System.Data.SqlClient" %>
<%@ Import Namespace="System.Collections.Generic" %>
<%@ Import Namespace="Newtonsoft.Json.Linq" %>
<script runat="server">
    private string DBConStr = "server='192.168.35.10';uid=ABEASD14AD;pwd=+AuDkDew;database=tlsoft";
    private string ChatProConnStr = "server='192.168.35.62';uid=sa;pwd=ll=8727;database=weChatPromotion";
    private string FXCXDBConStr = "server='192.168.35.32';uid=lllogin;pwd=rw1894tla;database=tlsoft";

    protected void Page_Load(object sender, EventArgs e)
    {
        string ctrl = Convert.ToString(Request.Params["ctrl"]);
        switch (ctrl)
        {
            case "GetVipList":
                string lastid = Convert.ToString(Request.Params["lastid"]);
                string mdid = Convert.ToString(Request.Params["mdid"]);
                if(mdid==""||mdid=="0"||mdid==null)
                    clsSharedHelper.WriteErrorInfo("缺少参数mdid！");
                else if (lastid == "" || lastid == null)
                    lastid = "0";
                else
                    GetVipList(mdid,lastid);
                break;
            case "GetUserInfo":
                string uid = Convert.ToString(Request.Params["uid"]);
                string vipkh = Convert.ToString(Request.Params["ukh"]);
                if (uid == null || uid == "0" || uid == "")
                    clsSharedHelper.WriteErrorInfo("缺少参数uid！");
                else if (vipkh == null || vipkh == "0" || vipkh == "")
                    clsSharedHelper.WriteErrorInfo("缺少参数vipkh！");
                else
                    GetUserInfo(uid, vipkh);
                break;
            case "GetTagTemplate":
                GetTagTemplate();
                break;
            case "GetUserTags":
                uid = Convert.ToString(Request.Params["uid"]);
                if (uid == null || uid == "0" || uid == "")
                    clsSharedHelper.WriteErrorInfo("缺少参数uid！");
                else
                    GetUserTags(uid);
                break;
            case "UpUserTags":
                string jsondata = Convert.ToString(Request.Params["tags"]);
                UpUserTags(jsondata);
                break;
            case "GetVIPBehavior":
                uid = Convert.ToString(Request.Params["uid"]);
                vipkh = Convert.ToString(Request.Params["ukh"]);
                if (vipkh == null || vipkh == "0" || vipkh == "")
                    clsSharedHelper.WriteErrorInfo("缺少参数ukh！");
                else
                    GetVIPBehavior(uid, vipkh);
                break;
            case "GetChartDatas":
                uid = Convert.ToString(Request.Params["uid"]);
                vipkh = Convert.ToString(Request.Params["ukh"]);
                string type = Convert.ToString(Request.Params["type"]);
                if (vipkh == null || vipkh == "0" || vipkh == "")
                    clsSharedHelper.WriteErrorInfo("缺少参数ukh！");
                else if (type == null || type == "0" || type == "")
                    clsSharedHelper.WriteErrorInfo("缺少参数type！");
                else
                    GetChartDatas(uid, vipkh, type);
                break;
            case "FilterData":
                type = Convert.ToString(Request.Params["type"]);
                mdid = Convert.ToString(Request.Params["mdid"]);
                if (mdid == "" || mdid == "0" || mdid == null)
                    clsSharedHelper.WriteErrorInfo("缺少参数mdid！");
                else if (type == null || type == "0" || type == "")
                    clsSharedHelper.WriteErrorInfo("缺少参数type！");
                else
                    FilterData(mdid, type);
                break;
            case "LatestConsume":
                vipkh = Convert.ToString(Request.Params["ukh"]);
                if (vipkh == null || vipkh == "0" || vipkh == "")
                    clsSharedHelper.WriteErrorInfo("缺少参数ukh！");
                else
                    LatestConsume(vipkh);
                break;
            case "ConsumeDetail":
                string djid = Convert.ToString(Request.Params["djid"]);
                if (djid == null || djid == "0" || djid == "")
                    clsSharedHelper.WriteErrorInfo("缺少参数djid！");
                else
                    ConsumeDetail(djid);
                break;
            case "GetClothesPics":
                string sphh = Convert.ToString(Request.Params["sphh"]);
                if (sphh == null || sphh == "")
                    clsSharedHelper.WriteErrorInfo("缺少参数sphh！");
                else
                    GetClothesPics(sphh);
                break;
            case "SyncVIPInfo":
                vipkh = Convert.ToString(Request.Params["vipkh"]);

                if (vipkh == null || vipkh == "0" || vipkh == "")
                    clsSharedHelper.WriteErrorInfo("缺少参数vipkh！");
                else
                    clsSharedHelper.WriteInfo(SyncVIPInfo(vipkh));
                break;
            case "SyncMDVIPPoints":
                mdid = Convert.ToString(Request.Params["mdid"]);
                if (mdid == "" || mdid == "0" || mdid == null)
                    clsSharedHelper.WriteErrorInfo("缺少参数mdid！");
                else
                    SyncMDVIPPoints(mdid);
                break;
            case "UpdateChange":
                string lxid = Convert.ToString(Request.Params["lxid"]);
                string jfs = Convert.ToString(Request.Params["jfs"]);
                vipkh = Convert.ToString(Request.Params["vipkh"]);
                UpdateChange(lxid,jfs,vipkh);
                break;
            default:
                clsSharedHelper.WriteErrorInfo("无ctrl=" + ctrl + "对应操作！【注意大小写】");
                break;
        }
    }

    /// <summary>
    /// 用于积分变动时的调用
    /// </summary>
    /// <param name="lxid">积分类型ID</param>
    /// <param name="jfs">变动的值，带符号，但是不可能出现对应类型的方向为-1变动值是负数的情况，或者换句话说当传入变动值为负数时，它的方向只能为正</param>
    /// <param name="vipkh">VIP卡号</param>
    public void UpdateChange(string lxid, string jfs, string vipkh)
    {
        using (LiLanzDALForXLM dal_62 = new LiLanzDALForXLM(ChatProConnStr))
        {
            string str_sql = @"select a.name,a.flag,isnull(vi.id,0) infoid,a.impactrange 
                                from wx_t_vippointtype a
                                left join wx_t_vipinfo vi on vi.vipcardno=@vipkh
                                where a.isactive=1 and a.id=@lxid;";
            List<SqlParameter> paras = new List<SqlParameter>();
            paras.Add(new SqlParameter("@vipkh", vipkh));
            paras.Add(new SqlParameter("@lxid", lxid));
            DataTable dt = null;
            string errinfo = dal_62.ExecuteQuerySecurity(str_sql, paras, out dt);
            if (errinfo == "")
            {
                if (dt.Rows.Count > 0)
                {
                    string remark = dt.Rows[0]["name"].ToString();
                    string flag=dt.Rows[0]["flag"].ToString();
                    string infoid = dt.Rows[0]["infoid"].ToString();
                    string impactRange = dt.Rows[0]["impactrange"].ToString();
                    int val = Convert.ToInt32(flag) * Convert.ToInt32(jfs);
                    int changeValue = val;
                    if (val >= 0)
                    {
                        flag = "1";
                    }
                    else
                    {
                        flag = "-1";
                        changeValue = -1 * val;
                    }
                    
                    if (infoid == "0") {
                        string rt = SyncVIPInfo(vipkh);
                        if (rt.Contains("Error:")) {
                            clsSharedHelper.WriteErrorInfo("初始化该用户积分记录失败！" + rt);
                            return;
                        }                                                                     
                    }
                    
                    string changeConsume = @" update set consumepoints=consumepoints+@fcv,userpoints=userpoints+@fcv from wx_t_vipinfo where vipcardno=@vipkh;";
                    string changeActivity = @" update set activitypoints=activitypoints+@fcv,userpoints=userpoints+@fcv from wx_t_vipinfo where vipcardno=@vipkh;";                    
                    string changeCharm = @" update set charmvalue=charmvalue+@fcv,
                                            viptitle=case when charmvalue+@fcv<=0 then 0 else case when charmvalue+@fcv<=2000 then 1 else case when charmvalue+@fcv<=6000 then 2 else case when charmvalue+@fcv<=12000 then 3 
                                            else case when charmvalue+@fcv<=20000 then 4 else case when charmvalue+@fcv<=30000 then 5 else case when charmvalue+@fcv<=42000 then 6 else 7 end end end end end end end
                                            from wx_t_vipinfo where vipcardno=@vipkh;";
                    
                    /*
                     *消费积分、活动积分、魅力值 三位
                     *100-消费积分
                     *010-活动积分
                     *001-魅力值
                     *101-消费积分+魅力值
                     *011-活动积分+魅力值
                     *110-消费积分+活动积分
                     *111-消费积分+活动积分+魅力值
                     */
                    switch (impactRange) { 
                        case "001":
                            str_sql = changeCharm;
                            break;
                        case "010":
                            str_sql = @"insert wx_t_vippointrecords(vipid,vipcardno,changevalue,changeflag,remarks,eventtime,operator,leftpoints,pointtype,relateid)
                                        select top 1 vipid,vipcardno,@cv,@cf,@remark,getdate(),'system',isnull(userpoints,0)+@changeValue,@lxid,0 from wx_t_vipinfo where vipcardno=@vipkh;";
                            str_sql += changeActivity;
                            break;
                        case "011":
                            str_sql = @"insert wx_t_vippointrecords(vipid,vipcardno,changevalue,changeflag,remarks,eventtime,operator,leftpoints,pointtype,relateid)
                                        select top 1 vipid,vipcardno,@cv,@cf,@remark,getdate(),'system',isnull(userpoints,0)+@changeValue,@lxid,0 from wx_t_vipinfo where vipcardno=@vipkh;";
                            str_sql += changeActivity + changeCharm;
                            break;
                        case "100":
                            str_sql = @"insert wx_t_vippointrecords(vipid,vipcardno,changevalue,changeflag,remarks,eventtime,operator,leftpoints,pointtype,relateid)
                                        select top 1 vipid,vipcardno,@cv,@cf,@remark,getdate(),'system',isnull(userpoints,0)+@changeValue,@lxid,0 from wx_t_vipinfo where vipcardno=@vipkh;";
                            str_sql += changeConsume;
                            break;
                        case "101":
                            str_sql = @"insert wx_t_vippointrecords(vipid,vipcardno,changevalue,changeflag,remarks,eventtime,operator,leftpoints,pointtype,relateid)
                                        select top 1 vipid,vipcardno,@cv,@cf,@remark,getdate(),'system',isnull(userpoints,0)+@changeValue,@lxid,0 from wx_t_vipinfo where vipcardno=@vipkh;";
                            str_sql += changeConsume + changeCharm;
                            break;                          
                        case "110":
                            str_sql = @"insert wx_t_vippointrecords(vipid,vipcardno,changevalue,changeflag,remarks,eventtime,operator,leftpoints,pointtype,relateid)
                                        select top 1 vipid,vipcardno,@cv,@cf,@remark,getdate(),'system',isnull(userpoints,0)+@changeValue,@lxid,0 from wx_t_vipinfo where vipcardno=@vipkh;";
                            str_sql += changeConsume + changeActivity;
                            break;
                        case "111":
                            str_sql = @"insert wx_t_vippointrecords(vipid,vipcardno,changevalue,changeflag,remarks,eventtime,operator,leftpoints,pointtype,relateid)
                                        select top 1 vipid,vipcardno,@cv,@cf,@remark,getdate(),'system',isnull(userpoints,0)+@changeValue,@lxid,0 from wx_t_vipinfo where vipcardno=@vipkh;";
                            str_sql += changeConsume + changeActivity + changeCharm;
                            break;
                    }
                    paras.Clear();
                    paras.Add(new SqlParameter("@cv", changeValue));
                    paras.Add(new SqlParameter("@cf", flag));
                    paras.Add(new SqlParameter("@remark", remark));
                    paras.Add(new SqlParameter("@changeValue", val));
                    paras.Add(new SqlParameter("@lxid", lxid));
                    paras.Add(new SqlParameter("@vipkh", vipkh));
                    errinfo = dal_62.ExecuteNonQuerySecurity(str_sql, paras);

                    if (errinfo == "")
                        clsSharedHelper.WriteSuccessedInfo("");
                    else
                        clsSharedHelper.WriteErrorInfo(errinfo);
                }
                else
                    clsSharedHelper.WriteErrorInfo("传入的积分类型有误!");
            }
            else
                clsSharedHelper.WriteErrorInfo("更新变动查询时失败 " + errinfo);
        }//end using
    }
    
    //同步某家门店的VIP积分记录
    public void SyncMDVIPPoints(string mdid) {
        int Success = 0, Fails = 0;
        using (LiLanzDALForXLM dal = new LiLanzDALForXLM(ChatProConnStr)) {
            string str_sql = "select kh from yx_t_vipkh where isnull(ty,0)=0 and mdid=@mdid";
            List<SqlParameter> paras = new List<SqlParameter>();
            DataTable dt = null;
            paras.Add(new SqlParameter("@mdid", mdid));
            string errinfo = dal.ExecuteQuerySecurity(str_sql, paras, out dt);
            if (errinfo == "")
            {
                if (dt.Rows.Count > 0)
                {
                    for (int i = 0; i < dt.Rows.Count; i++) {
                        string rt = SyncVIPInfo(dt.Rows[i]["kh"].ToString(), mdid);
                        if (rt.Contains("Error:"))
                            Fails++;
                        else if (rt.Contains("Successed"))
                            Success++;
                    }//end for
                    clsSharedHelper.WriteInfo("VIP总数：" + dt.Rows.Count.ToString() + " 成功：" + Success.ToString() + " 失败:" + Fails.ToString());
                }
                else
                    clsSharedHelper.WriteErrorInfo("该门店无VIP用户！");
            }
            else
                clsSharedHelper.WriteErrorInfo(errinfo);
        }
    }
    
    //同步计算更新积分
    public string SyncVIPInfo(string vipkh,string mdid) {
        string rt = "";      
        using (LiLanzDALForXLM dal_62 = new LiLanzDALForXLM(ChatProConnStr)) {
            //公用变量
            string str_sql = "", errinfo = "";
            List<SqlParameter> paras = new List<SqlParameter>();
            StringBuilder sb_sql = new StringBuilder();
            
            str_sql = @"select top 1 a.id,isnull(a.mdid,0) mdid,isnull(b.userpoints,0) leftpoints,isnull(b.charmvalue,0) charmvalue,
                        case when isnull(b.synctime,'')='' then '1990-01-01'else convert(varchar(10),b.synctime,120) end synctime,
                        isnull(b.activitypoints,0) activitypoints,isnull(b.consumepoints,0) consumepoints
                        from yx_t_vipkh a 
                        left join wx_t_vipinfo b on a.kh=b.vipcardno
                        where isnull(a.ty,0)=0 and a.kh=ltrim(rtrim(@vipkh));";
            paras.Add(new SqlParameter("@vipkh",vipkh));
            DataTable dt = null, dt_ls = null, dt_dh = null;
            errinfo = dal_62.ExecuteQuerySecurity(str_sql,paras,out dt);
            if (errinfo == "")
            {
                if (dt.Rows.Count > 0)
                {
                    string vipid = dt.Rows[0]["id"].ToString();                    
                    string synctime = dt.Rows[0]["synctime"].ToString();
                    int leftPoints = Convert.ToInt32(dt.Rows[0]["leftpoints"].ToString());//剩余积分
                    int charmValue = Convert.ToInt32(dt.Rows[0]["charmvalue"].ToString());//魅力值
                    int activityPoints = Convert.ToInt32(dt.Rows[0]["activitypoints"].ToString());//活动积分
                    int consumePoints = Convert.ToInt32(dt.Rows[0]["consumepoints"].ToString());//消费积分
                    string lastBuyTime = "";

                    //查询零售数据
                    //积分只统计客户在当店消费的
                    //引入积分体系门店表 只有存在于这张表中的门店才算积分
                    using (LiLanzDALForXLM dal_32 = new LiLanzDALForXLM(FXCXDBConStr))
                    {
                        str_sql = @"select a.id,a.vip,a.rq,round(a.sskje,0) jfs,
                                            case when a.djlb<0 then '商品退货' else '购买商品' end bz,
                                            case when a.djlb<0 then 3 else 2 end ptype,
                                            case when a.djlb<0 then -1 else 1 end flag
                                            from zmd_v_lsdjb a 
                                            where a.djbs=1 and a.vip=@vipkh and a.mdid=@mdid and a.rq>=convert(varchar(10),@synctime,120) and a.rq<convert(varchar(10),getdate(),120)
                                            order by a.rq desc;";
                        paras.Clear();
                        paras.Add(new SqlParameter("@vipkh", vipkh));
                        paras.Add(new SqlParameter("@mdid", mdid));
                        paras.Add(new SqlParameter("@synctime", synctime));
                        errinfo = dal_32.ExecuteQuerySecurity(str_sql, paras, out dt_ls);
                        if (errinfo == "")
                        {
                            string rq, bz, ptype, flag, id;
                            int jfs;
                            for (int i = 0; i < dt_ls.Rows.Count; i++)
                            {                                                                
                                lastBuyTime = dt_ls.Rows[0]["rq"].ToString();
                                id = dt_ls.Rows[i]["id"].ToString();
                                rq = dt_ls.Rows[i]["rq"].ToString();                                
                                jfs = Convert.ToInt32(dt_ls.Rows[i]["jfs"]);
                                bz = dt_ls.Rows[i]["bz"].ToString();
                                ptype = dt_ls.Rows[i]["ptype"].ToString();
                                flag = dt_ls.Rows[i]["flag"].ToString();

                                int _cvs = Convert.ToInt32(flag) * Convert.ToInt32(jfs);
                                leftPoints += _cvs;
                                charmValue += _cvs;
                                consumePoints += _cvs;

                                sb_sql.AppendFormat(@"insert into wx_t_vippointrecords(vipid,vipcardno,changevalue,changeflag,remarks,eventtime,operator,leftpoints,pointtype,relateid) 
                                                    values ({0},'{1}',{2},{3},'{4}','{5}','system',{6},{7},'{8}');", vipid, vipkh, jfs, flag, bz, rq, leftPoints, ptype, id);
                            }//end for

                            //查询积分兑换记录
                            //暂定积分兑换、赠送不影响魅力值，而且将其累积到活动积分中去
                            using (LiLanzDALForXLM dal_10 = new LiLanzDALForXLM(DBConStr))
                            {
                                str_sql = @"select a.id,a.kh vip,a.rq,
                                            case when a.dhjfs<0 then -1*a.dhjfs else a.dhjfs end jfs,
                                            case when a.jflx=1 then '积分兑换' else '积分赠送' end bz,
                                            case when a.jflx=1 then 4 when a.jflx=2 then 5 else 0 end ptype,
                                            case when a.dhjfs<0 then -1 else 1 end flag
                                            from zmd_t_xfjfdhb a
                                            where a.kh=@vipkh and a.rq>=convert(varchar(10),@synctime,120) and a.rq<convert(varchar(10),getdate(),120);";
                                paras.Clear();
                                paras.Add(new SqlParameter("@vipkh", vipkh));
                                paras.Add(new SqlParameter("@synctime", synctime));
                                errinfo = dal_10.ExecuteQuerySecurity(str_sql, paras, out dt_dh);

                                if (errinfo == "")
                                {
                                    for (int i = 0; i < dt_dh.Rows.Count; i++)
                                    {
                                        rq = dt_dh.Rows[i]["rq"].ToString();
                                        id = dt_ls.Rows[i]["id"].ToString();
                                        jfs = Convert.ToInt32(dt_dh.Rows[i]["jfs"]);
                                        bz = dt_dh.Rows[i]["bz"].ToString();
                                        ptype = dt_dh.Rows[i]["ptype"].ToString();
                                        flag = dt_dh.Rows[i]["flag"].ToString();

                                        int _cvs = Convert.ToInt32(flag) * Convert.ToInt32(jfs);
                                        leftPoints += _cvs;
                                        activityPoints += _cvs;
                                        sb_sql.AppendFormat(@"insert into wx_t_vippointrecords(vipid,vipcardno,changevalue,changeflag,remarks,eventtime,operator,leftpoints,pointtype,relateid) 
                                                    values ({0},'{1}',{2},{3},'{4}','{5}','system',{6},{7},'{8}');", vipid, vipkh, jfs, flag, bz, rq, leftPoints, ptype, id);
                                    }//end for                                    

                                    string titleID = "0";
                                    if (charmValue <= 0)
                                        titleID = "0";
                                    else if (charmValue <= 2000)
                                        titleID = "1";
                                    else if (charmValue <= 6000)
                                        titleID = "2";
                                    else if (charmValue <= 12000)
                                        titleID = "3";
                                    else if (charmValue <= 20000)
                                        titleID = "4";
                                    else if (charmValue <= 30000)
                                        titleID = "5";
                                    else if (charmValue <= 42000)
                                        titleID = "6";
                                    else
                                        titleID = "7";

                                    sb_sql.AppendFormat(@"if not exists(select top 1 1 from wx_t_vipinfo where vipid='{0}') 
                                    insert wx_t_vipinfo (vipid,vipcardno,consumepoints,activitypoints,userpoints,charmvalue,latestbuytime,viptitle,synctime,mdid)
                                    select '{0}','{1}',{2},{3},{4},{5},'{6}','{7}',getdate(),'{8}';", vipid, vipkh, consumePoints, activityPoints, leftPoints, charmValue, lastBuyTime, titleID, mdid);

                                    sb_sql.AppendFormat(@"else 
                                                            update a set a.consumepoints=b.cp,a.activitypoints=b.ap,a.userpoints=b.up,a.charmvalue=b.cv,a.latestbuytime=b.lbt,a.viptitle=b.vt,a.synctime=b.st,a.mdid=b.mdid
                                                            from wx_t_vipinfo a
                                                            inner join (select {0} cp,{1} ap,{2} up,{3} cv,'{4}' lbt,{5} vt,getdate() st,'{6}' mdid) b on 1=1
                                                            where a.vipcardno='{7}';", consumePoints, activityPoints, leftPoints, charmValue, lastBuyTime, titleID, mdid, vipkh);

                                    //加上事务
                                    string str_SQL = "BEGIN TRANSACTION " + sb_sql.ToString() + " COMMIT TRANSACTION GO ";
                                    
                                    errinfo = dal_62.ExecuteNonQuery(str_SQL);
                                    if (errinfo == "")
                                        rt = "Successed";
                                    else
                                        rt = "同步用户积分数据时出错【4】 " + errinfo;

                                    //释放资源
                                    DisposeDT(dt);
                                    DisposeDT(dt_ls);
                                    DisposeDT(dt_dh);
                                }
                                else
                                    rt = "同步用户积分数据时出错【3】 " + errinfo;
                            }
                        }
                        else
                            rt = "同步用户积分数据时出错【2】 " + errinfo;
                    }//end using
                }
                else
                    rt = "没有找到此VIP卡号信息！";
            }
            else
                rt = "同步用户积分数据时出错【1】 " + errinfo;
        }//end using

        return rt;
    }

    public void DisposeDT(DataTable dt) {
        if (dt != null) {
            dt.Dispose();
            dt = null;
        }    
    }            
    
    //获取衣服图片地址
    public void GetClothesPics(string sphh) {
        using (LiLanzDALForXLM dal = new LiLanzDALForXLM(DBConStr)) {
            string str_sql = @"select t1.urladdress+'|' 
                                from yx_v_ypdmb a
                                left join yf_t_cpkfsjtg cy on (a.zlmxid>0 and a.zlmxid=cy.zlmxid and cy.tplx='cyzp' ) 
                                or (a.zlmxid=0 and cy.tplx='cgyptp' and a.yphh=cy.yphh)
                                left join t_uploadfile t1 on case when isnull(a.zlmxid,0)=0 then 1002 else 1003 end=t1.groupid
                                and case when isnull(a.zlmxid,0)=0 then isnull(cy.id,0) else isnull(a.zlmxid,0) end=t1.tableid
                                where a.tzid=1 and a.sphh=@sphh
                                for xml path('')";
            DataTable dt = null;
            List<SqlParameter> paras = new List<SqlParameter>();
            paras.Add(new SqlParameter("@sphh", sphh));
            string errinfo = dal.ExecuteQuerySecurity(str_sql,paras,out dt);
            if (errinfo == "")
            {
                if (dt.Rows.Count > 0)
                {
                    clsSharedHelper.WriteInfo(dt.Rows[0][0].ToString());
                }
                else
                    clsSharedHelper.WriteInfo("");
            }
            else
                clsSharedHelper.WriteInfo("查询货号对应图片时出错 "+errinfo);
        }
    }
    
    //查询最近的消费记录
    public void LatestConsume(string vip) {
        using (LiLanzDALForXLM dal = new LiLanzDALForXLM(FXCXDBConStr)) {
            string str_sql = @"select top 5 a.* from (
                                select a.id djid,a.djh,convert(varchar(19),a.rq,120) djsj,isnull(md.mdmc,'') mdmc,sum(je) djje 
                                from zmd_v_lsdjmx a
                                left join t_mdb md on md.mdid=a.mdid
                                where a.vip=@vipkh and a.djbs=1 and a.djlb>0
                                group by a.id,djh,convert(varchar(19),a.rq,120),isnull(md.mdmc,'')
                                ) a
                                order by a.djsj desc";
            List<SqlParameter> paras = new List<SqlParameter>();
            paras.Add(new SqlParameter("@vipkh",vip));
            DataTable dt = null;
            string errinfo = dal.ExecuteQuerySecurity(str_sql,paras,out dt);
            if (errinfo == "")
            {
                if (dt.Rows.Count == 0)
                    clsSharedHelper.WriteInfo("");
                else
                    clsSharedHelper.WriteInfo(JsonHelp.dataset2json(dt));
            }
            else
                clsSharedHelper.WriteErrorInfo("查询最近消费记录时出错 "+errinfo);
        }
    }
    
    //查询消费单据详情
    public void ConsumeDetail(string djid) {
        using (LiLanzDALForXLM dal = new LiLanzDALForXLM(FXCXDBConStr))
        {
            string str_sql = @"select a.sphh,cm.cm cmmc,a.dj,a.sl
                                from zmd_v_lsdjmx a
                                inner join yx_t_spdmb sp on a.sphh=sp.sphh
                                left join yx_t_cmzh cm on cm.tml=sp.tml and a.cmdm=cm.cmdm
                                where a.djbs=1 and a.djlb>0 and a.id=@djid and a.je<>0";
            List<SqlParameter> paras = new List<SqlParameter>();
            paras.Add(new SqlParameter("@djid", djid));
            DataTable dt = null;
            string errinfo = dal.ExecuteQuerySecurity(str_sql, paras, out dt);
            if (errinfo == "")
            {
                if (dt.Rows.Count == 0)
                    clsSharedHelper.WriteInfo("");
                else
                    clsSharedHelper.WriteInfo(JsonHelp.dataset2json(dt));
            }
            else
                clsSharedHelper.WriteErrorInfo("查询消费详情时 " + errinfo);
        }
    }
    
    /// <summary>
    /// 排序、筛选功能
    /// </summary>
    public void FilterData(string mdid,string type) {
        using (LiLanzDALForXLM dal = new LiLanzDALForXLM(ChatProConnStr)) {
            string sql = @"select a.id,a.kh,isnull(v.wxheadimgurl,'') headimg,a.xb,a.xm,convert(varchar(10),a.jdrq,120) jdrq
                            from yx_t_vipkh a
                            left join wx_t_vipinfo b on a.kh=b.vipcardno
                            left join wx_t_vipbinging v on a.id=v.vipid
                            where a.ty=0 and a.kh<>'' and a.mdid=@mdid";
            switch (type) { 
                case "jf":
                    sql += " order by b.userpoints desc";
                    break;
                case "ml":
                    sql += " order by b.charmvalue desc";
                    break;
                case "je":
                    sql += " order by b.consumepoints desc";
                    break;
                case "sj":
                    sql += " order by b.latestbuytime desc";
                    break;
                case "lessm1":
                    sql += " and datediff(day,b.latestbuytime,getdate())<30";
                    break;
                case "lessm3":
                    sql += " and datediff(day,b.latestbuytime,getdate())<90";
                    break;
                case "lessy1":
                    sql += " and datediff(day,b.latestbuytime,getdate())<=365";
                    break;
                case "morey1":
                    sql += " and (datediff(day,b.latestbuytime,getdate())>365 or b.latestbuytime is null)";
                    break;
            }

            DataTable dt = null;
            List<SqlParameter> paras = new List<SqlParameter>();
            paras.Add(new SqlParameter("@mdid",mdid));
            string errinfo = dal.ExecuteQuerySecurity(sql, paras, out dt);
            if (errinfo == "")
            {
                if (dt.Rows.Count > 0)
                    clsSharedHelper.WriteInfo(JsonHelp.dataset2json(ConvertHeadimgURL(dt)));
                else
                    clsSharedHelper.WriteInfo("");
            }
            else
                clsSharedHelper.WriteErrorInfo("排序时发生错误：" + errinfo);
        }
    }
    
    /*public void FilterData() {
        DataTable pDt = null, cDt = null;
        string errinfo = "";
        using (LiLanzDALForXLM dal = new LiLanzDALForXLM(FXCXDBConStr))
        {
            string sql = @"select a.* from (
                            select vip,sum(je) xfje,max(sj) lastrq from zmd_v_lsdjmx 
                            where mdid=2097 and vip<>'' and djbs=1 and djlb<10
                            group by vip) a
                            order by a.xfje desc";
            errinfo = dal.ExecuteQuery(sql,out pDt);
        }//end using
        
        if (errinfo == "" && pDt.Rows.Count > 0) {
            using (LiLanzDALForXLM dal = new LiLanzDALForXLM(DBConStr))
            {
                string sql = @"select a.id,a.kh,'' headimg,a.xb,a.xm,convert(varchar(10),a.jdrq,120) jdrq from yx_t_vipkh a
                             where a.ty=0 and a.kh<>'' and a.mdid=2097 
                             order by a.id desc";
                errinfo = dal.ExecuteQuery(sql,out cDt);                
                if (errinfo == "" && cDt.Rows.Count > 0) {
                    DataSet ds = new DataSet();
                    ds.Tables.Add(pDt);
                    ds.Tables.Add(cDt);
                    ds.Relations.Add("内联", pDt.Columns["vip"], cDt.Columns["kh"],false);                                   
                    //建立一张新表
                    DataTable dt = new DataTable("t_viplist");
                    DataColumn dc;
                    dc = new DataColumn();
                    dc.DataType = Type.GetType("System.Int32");
                    dc.ColumnName = "id";
                    dc.AllowDBNull = false;
                    dc.Unique = true;
                    dt.Columns.Add(dc);

                    dc = new DataColumn();
                    dc.DataType = Type.GetType("System.String");
                    dc.ColumnName = "kh";
                    dc.AllowDBNull = false;
                    dc.Unique = true;
                    dt.Columns.Add(dc);

                    dc = new DataColumn();
                    dc.DataType = Type.GetType("System.String");
                    dc.ColumnName = "headimg";
                    dc.AllowDBNull = false;
                    dc.DefaultValue = "";                    
                    dt.Columns.Add(dc);

                    dc = new DataColumn();
                    dc.DataType = Type.GetType("System.String");
                    dc.ColumnName = "xb";
                    dc.AllowDBNull = false;
                    dc.DefaultValue = "0";
                    dt.Columns.Add(dc);

                    dc = new DataColumn();
                    dc.DataType = Type.GetType("System.String");
                    dc.ColumnName = "xm";
                    dc.AllowDBNull = false;
                    dc.DefaultValue = "";
                    dt.Columns.Add(dc);

                    dc = new DataColumn();
                    dc.DataType = Type.GetType("System.String");
                    dc.ColumnName = "jdrq";
                    dc.AllowDBNull = true;
                    dc.DefaultValue = "";
                    dt.Columns.Add(dc);
                                        
                    foreach (DataRow parentRow in ds.Relations["内联"].ParentTable.Rows) {
                        foreach (DataRow childRow in parentRow.GetChildRows(ds.Relations["内联"])) {                            
                            DataRow ndr = dt.NewRow();
                            ndr["id"] = childRow["id"].ToString();
                            ndr["kh"] = parentRow["vip"].ToString();
                            ndr["headimg"] = childRow["headimg"].ToString();
                            ndr["xb"] = childRow["xb"].ToString();
                            ndr["xm"] = childRow["xm"].ToString();
                            ndr["jdrq"] = childRow["jdrq"].ToString();
                            dt.Rows.Add(ndr);                                                     
                        }
                    }

                    if (dt.Rows.Count > 0)
                        clsSharedHelper.WriteInfo(JsonHelp.dataset2json(dt));
                    else
                        clsSharedHelper.WriteInfo("");
                }
            }
        }//end if


        pDt.Dispose();
        cDt.Dispose();        
    }*/
    
    //统计VIP用户的消费偏好
    public void GetChartDatas(string uid,string kh,string type) {
        using (LiLanzDALForXLM dal = new LiLanzDALForXLM(FXCXDBConStr))
        {
            string str_sql = @"                             
                                select b.spmc,lb.mc splb,xl.mc fg,replace(substring(b.spmc+'-',charindex('-',b.spmc)+1,6),'-','') ys,a.id,a.je,a.sl,a.zks into #zb
                                from zmd_v_lsdjmx a
                                inner join yx_t_spdmb b on a.sphh=b.sphh
                                left join yx_t_splb lb on lb.id=b.splbid
                                left join t_xtdm xl on xl.ssid=401 and xl.dm=b.fg
                                where a.djbs=1 and a.djlb<10 and a.vip=@vipkh;";
            switch (type) { 
                case "lb":
                    str_sql += "select top 10 a.* from (select splb label,sum(sl) sl from #zb group by splb) a order by sl desc;drop table #zb;";
                    break;
                case "xl":
                    str_sql += "select top 10 a.* from (select fg label,sum(sl) sl from #zb group by fg) a order by a.sl desc;drop table #zb;";
                    break;
                case "ys":
                    str_sql += "select top 10 a.* from (select ys label,sum(sl) sl from #zb group by ys) a order by a.sl desc ;drop table #zb;";
                    break;
                default:
                    str_sql += "drop table #zb;";
                    break;
            }                                
            List<SqlParameter> paras = new List<SqlParameter>();
            paras.Add(new SqlParameter("@vipkh", kh));
            DataTable dt = null;
            string errinfo = dal.ExecuteQuerySecurity(str_sql, paras, out dt);
            if (errinfo == "")
            {
                if (dt.Rows.Count > 0)
                {
                    if (dt.Rows[0][0].ToString() == "0")
                        clsSharedHelper.WriteInfo("Warn:该用户暂时无消费记录！");
                    else
                    {
                        clsSharedHelper.WriteInfo(JsonHelp.dataset2json(dt));
                    }
                }
                else
                    clsSharedHelper.WriteInfo("");
            }
            else
                clsSharedHelper.WriteErrorInfo("统计用户消费偏好时出错！" + errinfo+"|"+uid);
        }
    }
    
    /// <summary>
    /// 获取VIP的消费行为相关数据
    /// </summary>
    /// <param name="uid"></param>
    public void GetVIPBehavior(string uid,string vipkh)
    {
        //FXDBConStr
        using (LiLanzDALForXLM dal = new LiLanzDALForXLM(FXCXDBConStr))
        {
            string str_sql = @"                                
                                select a.rq,b.spmc,lb.mc splb,xl.mc fg,replace(substring(b.spmc+'-',charindex('-',b.spmc)+1,6),'-','') ys,a.id,a.je,a.sl,a.zks into #zb
                                from zmd_v_lsdjmx a
                                inner join yx_t_spdmb b on a.sphh=b.sphh
                                left join yx_t_splb lb on lb.id=b.splbid
                                left join t_xtdm xl on xl.ssid=401 and xl.dm=b.fg
                                where a.djbs=1 and a.djlb<10 and a.vip=@vipkh 

                                select count(distinct a.id) gmcs,sum(a.je)/sum(sl) pjdj,sum(sl)/count(distinct a.id) pjdl,sum(a.zks)/count(1) pjzks,
                                (select distinct splb+',' from #zb for xml path('')) pl,
                                (select distinct fg+',' from #zb for xml path('')) fg,
                                (select distinct ys+',' from #zb for xml path('')) ys,sum(a.je) xfje,
                                (select top 1 lastje from (select sum(je) lastje,rq from #zb group by rq) a order by rq desc) lastje,
                                (select convert(varchar(10),max(rq),120) from #zb) lastsj,datediff(day,max(rq),getdate()) dists
                                from #zb a                                
                                drop table #zb;";
            List<SqlParameter> paras = new List<SqlParameter>();
            paras.Add(new SqlParameter("@vipkh", vipkh));
            DataTable dt = null;
            string errinfo = dal.ExecuteQuerySecurity(str_sql, paras, out dt);
            if (errinfo == "" && dt.Rows.Count > 0)
            {
                if (dt.Rows[0][0].ToString() == "0")
                    clsSharedHelper.WriteInfo("Warn:该用户暂时无消费记录！");
                else
                {
                    clsSharedHelper.WriteInfo(dt.Rows[0]["gmcs"].ToString() + "|" + dt.Rows[0]["pjdj"].ToString() + "|" + dt.Rows[0]["pjdl"].ToString() + "|" + dt.Rows[0]["pjzks"].ToString() + "|" + dt.Rows[0]["pl"].ToString() + "|" + dt.Rows[0]["fg"].ToString() + "|" + dt.Rows[0]["ys"].ToString() + "|" + dt.Rows[0]["xfje"].ToString() + "|" + dt.Rows[0]["lastje"].ToString() + "|" + dt.Rows[0]["lastsj"].ToString() + "|" + dt.Rows[0]["dists"].ToString());
                }
            }
            else
                clsSharedHelper.WriteErrorInfo("查询用户消费行为时出错！ " + errinfo);
        }
    }

    /// <summary>
    /// 获取VIP用户列表
    /// </summary>
    public void GetVipList(string mdid,string lastid)
    {
        using (LiLanzDALForXLM dal = new LiLanzDALForXLM(ChatProConnStr))
        {
            string str_sql = "";
            DataTable dt = null;
            List<SqlParameter> paras = new List<SqlParameter>();
            string errinfo = "";
            if (lastid != "-1")
            {
                str_sql = @"select top 100 a.id,a.kh,a.xb,a.xm,convert(varchar(10),a.jdrq,120) jdrq,'--' sl,isnull(v.wxheadimgurl,'') headimg
                            from yx_t_vipkh a
                            left join wx_t_vipbinging v on a.id=v.vipid 
                            where a.ty=0 and a.kh<>'' and a.mdid=@mdid and a.id<@lastid
                            order by a.id desc";
                paras.Add(new SqlParameter("@lastid", lastid));
                paras.Add(new SqlParameter("@mdid", mdid));
                errinfo = dal.ExecuteQuerySecurity(str_sql, paras, out dt);
            }
            else {
                str_sql = @"select * into #zb from yx_t_vipkh where ty=0 and kh<>'' and mdid=@mdid order by id desc;
                            select top 100 a.id,a.kh,a.xb,a.xm,convert(varchar(10),a.jdrq,120) jdrq,(select count(1) from #zb) sl,isnull(v.wxheadimgurl,'') headimg
                            from #zb a
                            left join wx_t_vipbinging v on a.id=v.vipid
                            drop table #zb;";
                paras.Add(new SqlParameter("@mdid", mdid));
                errinfo = dal.ExecuteQuerySecurity(str_sql, paras, out dt);
            }

            if (errinfo == "")
            {
                if (dt.Rows.Count > 0)
                    clsSharedHelper.WriteInfo(JsonHelp.dataset2json(ConvertHeadimgURL(dt)));
                else
                    clsSharedHelper.WriteInfo("Warn:查询无数据！");
            }
            else
                clsSharedHelper.WriteErrorInfo("GetVipList error:" + errinfo);            
        }
    }

    public DataTable ConvertHeadimgURL(DataTable _dt) {
        string VIP_WebPath = clsConfig.GetConfigValue("VIP_WebPath");
        string OA_WebPath = clsConfig.GetConfigValue("OA_WebPath");
        if (_dt.Rows.Count > 0) {
            string url = "";
            for (int i = 0; i < _dt.Rows.Count; i++) {
                url = _dt.Rows[i]["headimg"].ToString();
                if (url == "")
                    url = "../../res/img/StoreSaler/defaulticon.jpg";
                else if (clsWXHelper.IsWxFaceImg(url))
                    url = clsWXHelper.GetMiniFace(url);
                else
                    url = VIP_WebPath + url;
                _dt.Rows[i]["headimg"] = url;
            }
        }
        return _dt;
    }
    
    /// <summary>
    /// 获取用户详细信息
    /// </summary>
    /// <param name="uid"></param>
    public void GetUserInfo(string uid,string ukh)
    {
        string userinfo = @"{{
                                ""username"": ""{0}"", 
                                ""yddh"": ""{1}"",
                                ""klb"":""{2}"",
                                ""qcjf"":""{3}"",
                                ""headimg"":""{4}"",
                                ""sex"":""{5}"",                                
                                ""csrq"":""{6}"",
                                ""nl"":""{7}"",
                                ""jdrq"":""{8}"",
                                ""vipkh"":""{9}"",
                                ""kkdp"":""{10}"",
                                ""lxdz"":""{11}"",
                                ""mlz"":""{12}"",
                                ""viptitle"":""{13}""
                             }}";
        using (LiLanzDALForXLM dal = new LiLanzDALForXLM(ChatProConnStr))
        {
            string str_sql = @"select a.xm,a.yddh,b.mc klb,isnull(vip.userpoints,0) qcjf,'' headimg,case when a.xb=0 then '男' else '女' end sex,
                                convert(varchar(10),csrq,120) csrq,datediff(yyyy,csrq,getdate()) nl,convert(varchar(10),a.jdrq,120) jdrq,a.kh vipkh,kh.khmc,a.zzdz,
                                isnull(vip.charmvalue,0) mlz,isnull(t.titlename,'') viptitle
                                from yx_t_vipkh a 
                                left join yx_t_viplb b on a.klb=b.dm
                                left join yx_t_khb kh on a.mdid=kh.khid
                                left join wx_t_vipinfo vip on vip.vipid=a.id
                                left join wx_t_viptitle t on t.id=vip.viptitle
                                where a.kh=@ukh";
            DataTable dt = null;
            List<SqlParameter> paras = new List<SqlParameter>();
            paras.Add(new SqlParameter("@ukh", ukh));
            string errinfo = dal.ExecuteQuerySecurity(str_sql, paras, out dt);
            if (errinfo == "")
            {
                if (dt.Rows.Count > 0)
                {
                    userinfo = string.Format(userinfo, dt.Rows[0]["xm"].ToString(), dt.Rows[0]["yddh"].ToString(), dt.Rows[0]["klb"].ToString(),
                        dt.Rows[0]["qcjf"].ToString(), dt.Rows[0]["headimg"].ToString(), dt.Rows[0]["sex"].ToString(), dt.Rows[0]["csrq"].ToString(),
                        dt.Rows[0]["nl"].ToString(), dt.Rows[0]["jdrq"].ToString(), dt.Rows[0]["vipkh"].ToString(), dt.Rows[0]["khmc"].ToString(), dt.Rows[0]["zzdz"].ToString(),
                        dt.Rows[0]["mlz"].ToString(), dt.Rows[0]["viptitle"].ToString());
                    clsSharedHelper.WriteInfo(userinfo);
                }
                else
                    clsSharedHelper.WriteErrorInfo("找不到该用户信息！");
            }
            else
                clsSharedHelper.WriteErrorInfo("GetUserInfo error:" + errinfo);
        }
    }

    //获取标签模板
    public void GetTagTemplate()
    {
        using (LiLanzDALForXLM dal = new LiLanzDALForXLM(ChatProConnStr))
        {
            string str_sql = @"select a.id,a.tagname,b.id gid,b.groupname 
                                from yx_t_VIPTags a
                                inner join yx_t_viptaggroup b on a.taggroupid=b.id
                                where a.isactive=1 and b.isactive=1
                                order by b.id";
            DataTable dt = null;
            string errinfo = dal.ExecuteQuery(str_sql, out dt);
            if (errinfo == "")
                if (dt.Rows.Count > 0)
                    clsSharedHelper.WriteInfo(JsonHelp.dataset2json(dt));
                else
                    clsSharedHelper.WriteErrorInfo("无用户标签模板数据！");
            else
                clsSharedHelper.WriteErrorInfo("加载用户标签模板时出错：" + errinfo);
        }
    }
    
    //获取用户标签数据
    public void GetUserTags(string uid)
    {
        using (LiLanzDALForXLM dal = new LiLanzDALForXLM(ChatProConnStr))
        {
            string str_sql = "select cast(tagid as varchar)+',' from yx_t_UserTags where userid=@uid for xml path('')";
            DataTable dt = null;
            List<SqlParameter> paras = new List<SqlParameter>();
            paras.Add(new SqlParameter("@uid", uid));
            string errinfo = dal.ExecuteQuerySecurity(str_sql, paras, out dt);            
            if (errinfo == "")
                if (dt.Rows.Count > 0)
                    clsSharedHelper.WriteInfo(dt.Rows[0][0].ToString());
                else
                    clsSharedHelper.WriteInfo("");
            else
                clsSharedHelper.WriteErrorInfo("加载用户标签时出错：" + errinfo);
        }
    }
    
    //更新用户标签
    public void UpUserTags(string jsondata)
    {
        using (LiLanzDALForXLM dal = new LiLanzDALForXLM(ChatProConnStr))
        {
            JObject jo = JObject.Parse(jsondata);
            string uid = Convert.ToString(jo["uid"]);
            string type = Convert.ToString(jo["type"]);
            if (type=="delete")
            {                
                string sql = string.Format("delete from yx_t_UserTags where userid='{0}';", uid);
                string errinfo = dal.ExecuteNonQuery(sql);
                if (errinfo == "")
                    clsSharedHelper.WriteInfo("");
                else
                    clsSharedHelper.WriteErrorInfo("提交失败 " + errinfo);
            }
            else if(type=="update"){
                JArray ja = (JArray)jo["data"];
                string sql = string.Format("delete from yx_t_UserTags where userid='{0}';", uid);
                for (int i = 0; i < ja.Count; i++)
                {
                    sql += string.Format(@"insert into yx_t_UserTags(userid,tagid) values ('{0}','{1}');", uid, ja[i].ToString());
                }//end for
                string errinfo = dal.ExecuteNonQuery(sql);
                if (errinfo == "")
                    clsSharedHelper.WriteInfo("");
                else
                    clsSharedHelper.WriteErrorInfo("提交失败 " + errinfo);
            }
        }
    }

    public void printDataTable(DataTable dt)
    {
        string printStr = "";
        if (dt.Rows.Count > 0)
        {
            for (int i = 0; i < dt.Rows.Count; i++)
            {
                for (int j = 0; j < dt.Columns.Count; j++)
                {
                    if (dt.Rows[i][j] == null)
                        printStr += "null&nbsp;";
                    else
                        printStr += dt.Rows[i][j].ToString() + "&nbsp;";
                }
                printStr += "<br />";
            }
            Response.Write(printStr);
            Response.End();
        }
    }       
</script>
<!DOCTYPE html>
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
