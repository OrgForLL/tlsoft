﻿ <%@ WebService Language="C#" Class="WSZXDDataPull" %>

using System;
using System.Collections;
using System.ComponentModel;
using System.Data;
using System.Diagnostics;
using System.Web;
using System.Web.Services;
using nrWebClass;
using System.IO;
using System.Text;
using System.Xml;
using System.Xml.Serialization;
using System.Collections.Generic;
using System.Data.SqlClient;

[WebService(Namespace = "http://tempuri.org/")]
[WebServiceBinding(ConformsTo = WsiProfiles.BasicProfile1_1)]
//若要允许使用 ASP.NET AJAX 从脚本中调用此 Web 服务，请取消对下行的注释。 
// [System.Web.Script.Services.ScriptService]
public class WSZXDDataPull : System.Web.Services.WebService
{
    private string connStr = "";
    public WSZXDDataPull()
    {
        //
        // TODO: 添加任何需要的构造函数代码
        //
    } 
    
    //获取材料仓库信息
    [WebMethod(Description = "获取材料仓库信息")]
    public string getCHCKXX(string tzid)
    {
        string rtMsg = "", errInfo = "";
        if (tzid == "")
            rtMsg = "error:tzid参数为空！";
        else
        {
            using (LiLanzDALForXLM dal = new LiLanzDALForXLM())
            {
                string str_sql = @" select cast(id as varchar) as dm,mc,dm as xh from cl_V_ckdmb  where tzid={0} and ty=0 
                                    union all select '' as dm,'全部' as mc,'ZZ' as xh 
                                    order by xh ";
                DataTable dt2 = null;
                str_sql = string.Format(str_sql, tzid);
                errInfo = dal.ExecuteQuery(str_sql, out dt2);
                if (errInfo == "")
                {
                    if (dt2.Rows.Count > 0)
                    {
                        dt2.TableName = "cl_V_ckdmb";
                        rtMsg = SerializeDataTableXml(dt2);
                    }
                }
                else
                {
                    rtMsg = "error:" + errInfo;
                }
            }
        }

        return rtMsg;
    }
    
    //设置材料的仓位信息
    [WebMethod]
    public string setCLInfo(DataTable cwInfo,string userName, string tzid, string qwtm)
    {
        string rtMsg = "", errInfo = "";
        int lydjlx=0;
        using (LiLanzDALForXLM dal = new LiLanzDALForXLM())
        {
            if(cwInfo!=null)
            {
                DataRow[] dr = cwInfo.Select("", "mxid");
                DataTable dt = null;
                List<SqlParameter> para = new List<SqlParameter>();
                string str_sql = " DECLARE @userName VARCHAR(50),@cwid int; SELECT @userName=cname,@cwid=0 FROM t_user WHERE NAME='" + userName + "'; ";
                for (int i = 0; i < dr.Length;i++)
                {       
                    //判断是不是调拨（<>''：是）                  
                    str_sql += " IF '" + dr[i]["lyscddbh"] + "'<>'0' and '" + dr[i]["lyscddbh"] + "'<>'' ";                                                         
                    str_sql += "    SELECT @cwid=isnull(id,0) FROM dbo.cl_t_cwxxb WHERE chdm='" + dr[i]["chdm"] + "' AND gzh='" + dr[i]["lyscddbh"] + "' AND ckid='" + dr[i]["dfckid"] + "' ";
                    str_sql += " else ";                   
                    str_sql += "    SELECT @cwid=isnull(id,0) FROM dbo.cl_t_cwxxb WHERE chdm='" + dr[i]["chdm"] + "' AND gzh='" + dr[i]["scddbh"] + "' AND ckid='" + dr[i]["ckid"] + "' ";              
                    
                    str_sql += " IF @cwid=0 ";
                    str_sql += "    insert into cl_t_cwxxb (gzh,chdm,cw,tzid,xgrq,xgr,ckid) values('" + dr[i]["scddbh"] + "','" + dr[i]["chdm"] + "','" + qwtm + "','" + tzid + "',GETDATE(),@userName,'" + dr[i]["ckid"] + "'); ";
                    str_sql += " else ";
                    str_sql += " begin ";  
                    str_sql += "       DECLARE @i INT,@num INT ,@cws varchar(max),@qw varchar(max); SET @i=1; "; 
                    str_sql += "       SELECT @num=COUNT(id) FROM [dbo].SplitToTable('" + qwtm + "', '/') ";   
                    str_sql += "       SELECT @qw=value FROM [dbo].SplitToTable('" + qwtm + "', '/') WHERE id=@i ";                 
                    str_sql += "       WHILE (@qw<>'' and @i<=@num)  ";                   
                    str_sql += "       begin   ";   
                    str_sql += "          SELECT @cws=isnull(cw,'') FROM dbo.cl_t_cwxxb WHERE id=@cwid ";                         
                    str_sql += "          IF CHARINDEX(@qw,@cws,0)=0 ";                    
                    str_sql += "             IF @cws='' ";                                                         
                    str_sql += "                UPDATE cl_t_cwxxb SET gzh='" + dr[i]["scddbh"] + "',chdm='" + dr[i]["chdm"] + "',cw=@qw,tzid='" + tzid + "',xgrq=GETDATE(),xgr=@userName,ckid='" + dr[i]["ckid"] + "' WHERE id=@cwid ";
                    str_sql += "             else ";                                                        
                    str_sql += "                UPDATE cl_t_cwxxb SET gzh='" + dr[i]["scddbh"] + "',chdm='" + dr[i]["chdm"] + "',cw=cw+'/'+@qw,tzid='" + tzid + "',xgrq=GETDATE(),xgr=@userName,ckid='" + dr[i]["ckid"] + "' WHERE id=@cwid ";
                    str_sql += "          SET @i=@i+1 ";
                    str_sql += "          SELECT @qw=value FROM [dbo].SplitToTable('" + qwtm + "', '/') WHERE id=@i ";
                    str_sql += "       end ";
                    str_sql += " end ";
                }                
                errInfo = dal.ExecuteQuerySecurity(str_sql, para, out dt);
                
                if (errInfo == "")
                {
                    rtMsg = "保存成功！";
                }
                else
                {
                    rtMsg = "error:" + errInfo;
                    writeLog(rtMsg + "\r\n" + str_sql);
                }
            }
            else
            {
                rtMsg = "error:数据不存在！";
            }
        }
        return rtMsg;   
    }
    
    //获取要维护仓位的材料信息
    [WebMethod]
    public string getCLInfo(string djid, string djly, string tzid, string ckid)
    {
        string rtMsg = "", errInfo = "";
        using (LiLanzDALForXLM dal = new LiLanzDALForXLM())
        {
            if (tzid == "")
            {
                rtMsg = "error:tzid参数为空！";
            }
            else
            {
                string str_sql="";
                DataTable dt = null;
                List<SqlParameter> para = new List<SqlParameter>();
                
                if(djly=="1" || djly=="S")
                {
                    if(djly=="S")
                    {
                        str_sql = @" declare @djids varchar(500) 
                                   SELECT @djids=ids FROM  cl_t_cwdjtmIDgl WHERE id=@djid
                                   IF(LEN(@djids)!=0)
                                     SELECT  @djids=SUBSTRING(@djids,2,LEN(@djids))
                                   ELSE 
                                     SELECT @djids=0
                                     
                                   exec('select a.* into #myzb from cl_v_dddjmx a where a.id in ('+ @djids +')               
                                   select distinct a.scddbh,a.chdm,a.sl,a.mxid,a.ckid,xx.id cwid,0 lyscddbh,0 dfckid  
                                   from #myzb a 
                                   inner join cl_v_chdmb c on a.chdm=c.chdm 
                                   inner join  cl_T_chgzhkcmx ch on a.chdm=ch.chdm AND a.scddbh=ch.gzh AND a.ckid=ch.ckid  
                                   left join cl_t_cwxxb xx on xx.tzid='+ @tzid +' and xx.chdm=ch.chdm and a.scddbh=xx.gzh and xx.ckid=a.ckid 
                                   where c.tzid='+ @tzid +' and a.djlx=624
                                   order by a.mxid 
                                   drop table #myzb;') ";                        
                    }
                    else
                    {
                        str_sql = @" 
                                  SELECT b.*
                                  into #myzb 
                                  FROM CL_T_dddjb a 
                                  inner JOIN cl_v_dddjmx b ON a.id=b.id
                                  where (CAST(DATENAME(yyyy,a.zdrq) AS VARCHAR(max))+CAST(DATENAME(mm,a.zdrq) AS VARCHAR(max))+CAST(a.djh AS VARCHAR(max)))=@djid
                                  AND a.djlx=624
                                                              
                                  select distinct a.scddbh,a.chdm,a.sl,a.mxid,a.ckid,xx.id cwid,0 lyscddbh,0 dfckid     
                                  from #myzb a 
                                  inner join cl_v_chdmb c on a.chdm=c.chdm 
                                  inner join  cl_T_chgzhkcmx ch on a.chdm=ch.chdm AND a.scddbh=ch.gzh AND a.ckid=ch.ckid  
                                  left join cl_t_cwxxb xx on xx.tzid=@tzid and xx.chdm=ch.chdm and a.scddbh=xx.gzh and xx.ckid=a.ckid 
                                  where c.tzid=@tzid and a.djlx=624
                                  order by a.mxid 
                                  drop table #myzb; ";
                    }
                    
                    para.Add(new SqlParameter("@djid", djid));
                    //para.Add(new SqlParameter("@jsrq", jsrq));
                    para.Add(new SqlParameter("@tzid", tzid));
                    errInfo = dal.ExecuteQuerySecurity(str_sql, para, out dt);
                }                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                    
                else if(djly=="2")
                {
                    str_sql = @" SELECT DISTINCT a.scddbh,a.chdm,a.sl,a.mxid,a.ckid,xx.id cwid,isnull(a.lyscddbh,'') lyscddbh,isnull(a.dfckid,'') dfckid  
                              FROM    cl_v_kcdjmx a
                                      INNER JOIN cl_v_chdmb c ON a.chdm = c.chdm AND c.tzid = @tzid
                                      inner join  cl_T_chgzhkcmx ch on a.chdm=ch.chdm AND a.scddbh=ch.gzh AND a.ckid=ch.ckid
                                      left join cl_t_cwxxb xx on xx.tzid=@tzid and xx.chdm=ch.chdm and a.scddbh=xx.gzh and xx.ckid=a.ckid 
                              WHERE   a.djlx = 512 AND a.id = @djid
                              ORDER BY a.mxid ";
                    
                    para.Add(new SqlParameter("@djid", djid));
                    //para.Add(new SqlParameter("@jsrq", jsrq));
                    para.Add(new SqlParameter("@tzid", tzid));
                    errInfo = dal.ExecuteQuerySecurity(str_sql, para, out dt);
                }
                else if(djly=="3")
                {
                    str_sql = @"  select distinct sum(isnull(kc.sl-kc.dbdf-kc.qtdf,0)) as gzzsl,a.scddbh,sum(a.sl) as gzsl,
                              a.chdm into #clgzhz  
                              from cl_v_kcdjmx a  
                              inner join cl_v_chdmb c on a.chdm=c.chdm and c.tzid=@tzid  
                              left outer join CL_T_chgzhkcmx kc on a.ckid=kc.ckid and a.chdm=kc.chdm and a.tzid=kc.tzid and a.scddbh=kc.gzh  
                              left outer join cl_t_chkcmx clkc on a.ckid=clkc.ckid and a.chdm=clkc.chdm and a.tzid=clkc.tzid  
                              where a.id=@djid  
                              group by a.chdm,a.scddbh 
                              order by a.chdm ; 
                              
                              select distinct max(isnull(clkc.sl-clkc.dbdf-clkc.qtdf,0)) as clzsl,sum(a.sl) as clsl,a.chdm 
                              into #clhz  from cl_v_kcdjmx a  
                              inner join cl_v_chdmb c on a.chdm=c.chdm and c.tzid=@tzid  
                              left outer join CL_T_chgzhkcmx kc on a.ckid=kc.ckid and a.chdm=kc.chdm and a.tzid=kc.tzid and a.scddbh=kc.gzh  
                              left outer join cl_t_chkcmx clkc on a.ckid=clkc.ckid and a.chdm=clkc.chdm and a.tzid=clkc.tzid  
                              where a.id=@djid  
                              group by a.chdm 
                              order by a.chdm ; 
                              
                              select distinct a.scddbh,a.chdm,a.sl,a.mxid,a.ckid,xx.id cwid,isnull(a.lyscddbh,'') lyscddbh,isnull(a.dfckid,0) dfckid  
                              from cl_v_kcdjmx a  
                              inner join cl_v_chdmb c on a.chdm=c.chdm and c.tzid=@tzid 
                              inner join cl_t_chdmb cc on c.chdm=cc.chdm 
                              inner join  cl_T_chgzhkcmx ch on a.chdm=ch.chdm AND a.scddbh=ch.gzh AND a.ckid=ch.ckid
                              inner join cl_t_cwxxb xx on xx.tzid=@tzid and xx.chdm=ch.chdm and a.lyscddbh=xx.gzh and xx.ckid=a.dfckid 
                              inner join #clgzhz gz on a.chdm=gz.chdm and a.scddbh=gz.scddbh 
                              inner join #clhz cl on a.chdm=cl.chdm  
                              where  a.id=@djid AND a.djlx=561
                              order by a.mxid  
                              
                              drop table #clgzhz; drop table #clhz; ";
                    
                    para.Add(new SqlParameter("@djid", djid));
                    //para.Add(new SqlParameter("@jsrq", jsrq));
                    para.Add(new SqlParameter("@tzid", tzid));
                    errInfo = dal.ExecuteQuerySecurity(str_sql, para, out dt);
                }                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                   
                else if(djly=="0")
                {
                    str_sql = @" SELECT t1.gzh scddbh,t1.chdm,isnull(t1.sl,0) as sl,t1.id mxid,t1.ckid,cw.id cwid 
                              from cl_T_chgzhkcmx as t1
                              inner join cl_v_chdmb as ch ON t1.chdm=ch.chdm and t1.tzid=@tzid
                              inner join yx_t_ckdmb as ck on t1.ckid=ck.id
                              LEFT JOIN cl_t_cwxxb AS cw on t1.chdm=cw.chdm and t1.gzh=cw.gzh  and t1.ckid=cw.ckid  and cw.tzid=@tzid
                              where t1.tzid=@tzid and t1.chdm=@djid and t1.ckid=@ckid and (isnull(cw.id,0)=0 or cw.cw='') ";
                    
                    para.Add(new SqlParameter("@ckid", ckid));
                    para.Add(new SqlParameter("@djid", djid));
                    para.Add(new SqlParameter("@tzid", tzid));
                    errInfo = dal.ExecuteQuerySecurity(str_sql, para, out dt);
                }
                
                if (errInfo == "")
                {
                    if (dt.Rows.Count > 0)
                    {                    
                        if(djly=="1" || djly=="S")
                        {
                            dt.TableName = "cl_v_dddjmx";
                            rtMsg = SerializeDataTableXml(dt);
                            dt=null;                          
                        }
                        else if(djly=="2")
                        {
                            dt.TableName = "cl_v_dddjmx";
                            rtMsg = SerializeDataTableXml(dt);
                            dt=null;                          
                        }
                        else if(djly=="3")
                        {
                            dt.TableName = "cl_v_kcdjmx";
                            rtMsg = SerializeDataTableXml(dt);
                            dt=null;                          
                        }
                        else if(djly=="0")
                        {
                            dt.TableName = "cl_T_chgzhkcmx";
                            rtMsg = SerializeDataTableXml(dt);
                            dt=null;                          
                        }
                        else
                        {
                            rtMsg = "error:该单据类型不存在！("+djly+")";
                        }
                    }
                    else
                    {
                        rtMsg = "error:查询无记录！";
                    }
                }
                else
                {
                    rtMsg = "error:" + errInfo;
                    writeLog(rtMsg + "\r\n" + str_sql);
                }
             }
         }
        return rtMsg;        
    }
    
    //加载主表数据 数据源是物料发货计划(cl_t_dddjb.djlx=605)
    [WebMethod]
    public string getZXDList(string ksrq, string jsrq, string tzid, string khid)
    {
        string rtMsg = "", errInfo = "";
        if (tzid == "")
            rtMsg = "error:tzid参数为空！";
        else
        {
            using (LiLanzDALForXLM dal = new LiLanzDALForXLM())
            {
                string str_sql = @"select a.djh,a.khid,kh.khdm,kh.khmc,(select sum(sl) from cl_v_dddjmx where djlx=605 and id=a.id group by id) sl,isnull(ht.ddbh,'') ddbh,g.mc djlbmc,a.id into #myzb
                                from cl_t_dddjb a
                                inner join yx_t_khb kh on kh.khid=a.khid
                                inner join yx_v_djlb g on a.djlb=g.id and g.tzid=a.tzid 
                                left join zw_t_htdddjb ht on ht.id=a.htddid
                                where a.tzid=@tzid and a.rq>=@ksrq and a.rq<dateadd(day,1,@jsrq) and a.djlx=605 ";
                if (khid != "")
                    str_sql += " and a.khid='" + khid + "' order by a.rq desc;";
                else
                    str_sql += " order by a.rq desc;";

                str_sql += @"select a.djh,a.khmc,a.sl,isnull(a.sl,0)-isnull(b.zxsl,0) sysl,a.ddbh,a.djlbmc,a.id,a.khid,a.khdm
                                from #myzb a
                                left join (
                                   select sum(a.sl) zxsl,a.lyid from cl_t_wlzxd a inner join #myzb b on a.lyid=b.id group by a.lyid
                                ) b on a.id=b.lyid where a.sl>0;
                                drop table #myzb;";

                DataTable dt = null;
                List<SqlParameter> para = new List<SqlParameter>();
                para.Add(new SqlParameter("@ksrq", ksrq));
                para.Add(new SqlParameter("@jsrq", jsrq));
                para.Add(new SqlParameter("@tzid", tzid));
                errInfo = dal.ExecuteQuerySecurity(str_sql, para, out dt);
                if (errInfo == "")
                {
                    if (dt.Rows.Count > 0)
                    {
                        dt.TableName = "cl_t_wlzxd";
                        rtMsg = SerializeDataTableXml(dt);
                    }
                    else
                        rtMsg = "error:查询无记录！";
                }
                else
                    rtMsg = "error:" + errInfo;
            }
        }

        return rtMsg;
    }

    
    //加载单据表明细 传入的是多张领用计划单
    [WebMethod]
    public string getZXDMXList(string ids, string tzid)
    {
        string rtMsg = "", errInfo = "";
        if (tzid == "")
            rtMsg = "error:tzid参数为空！";
        else
        {
            using (LiLanzDALForXLM dal = new LiLanzDALForXLM())
            {
                string str_sql = @"select b.djh,b.id,a.mxid,a.chdm,d.chmc,a.sl,d.dw,a.scddbh into #zb
                                from cl_t_dddjb  b 
                                inner join cl_t_dddjmx a on a.id=b.id 
                                inner join cl_v_chdmb d on d.tzid={0} and d.chdm=a.chdm   
                                where b.id in ({1});

                                select a.chdm,'0' xlsl,isnull(a.sl,0)-isnull(b.sl,0) sysl,a.sl,isnull(b.sl,0) zxsl,a.mxid,a.id,a.chmc,a.dw,a.scddbh,'' tm,'' zxbz,'0' yssl,'0' sssl
                                from #zb a
                                left join (
                                select sum(a.sl) sl,a.lyid,a.lymxid from cl_t_wlzxd a inner join #zb b on a.lymxid=b.mxid group by a.lyid,a.lymxid 
                                ) b on a.id=b.lyid and a.mxid=b.lymxid order by a.chdm;
                                drop table #zb;";
                DataTable dt2 = null;
                str_sql = string.Format(str_sql, tzid, ids);
                errInfo = dal.ExecuteQuery(str_sql, out dt2);
                if (errInfo == "")
                {
                    if (dt2.Rows.Count > 0)
                    {
                        dt2.TableName = "cl_t_wlzxdmx";
                        rtMsg = SerializeDataTableXml(dt2);
                    }
                }
                else
                {
                    rtMsg = "error:" + errInfo;
                }
            }
        }

        return rtMsg;
    }

    //检查箱码的有效性
    [WebMethod]
    public string checkXM(string tzid, string tm, string ids)
    {
        string rtMsg = "", str_sql = "";
        if (tm == "")
            rtMsg = "error:箱码参数为空！";
        else if (tzid == "")
            rtMsg = "error:当前套账ID参数为空！";
        else {
            using (LiLanzDALForXLM dal = new LiLanzDALForXLM()) {
                str_sql = "select count(*) from cl_t_wlzxd where zxxh='" + tm + "'";
                DataTable dt = null;
                string errInfo = dal.ExecuteQuery(str_sql,out dt);
                if (errInfo == "")
                {
                    if (dt.Rows[0][0].ToString() == "0") {
                        //rtMsg = "error:该箱码无效！";
                        //不能直接判定为无效箱码，因为后面箱码有可能直接由物料条码直接生成
                        //20160509  李清峰调整
                        str_sql = @"if not exists (select top 1 1 from cl_t_wlsmjlb where zxxh='{0}' and smlb='tm' and zxbs=1)
                                      select '00';
                                    else if exists (select top 1 1 from cl_t_wlsmjlb where tzid=1 and smlb='xh' and sm='{0}')
                                      select '01',zxxh from cl_t_wlsmjlb where tzid=1 and smlb='xh' and sm='{0}';
                                    else
                                      begin
                                        select a.id
                                        from cl_t_wlsmjlb a
                                        inner join cl_t_wltmb tm on a.sm=tm.tm and a.zxxh='{0}' and a.smlb='tm' and a.zxbs=1
                                        left join cl_t_dddjmx s on s.chdm=tm.chdm and s.id in ({1})
                                        where s.chdm is null;
                                      end";
                        str_sql = string.Format(str_sql, tm, ids);
                        errInfo = dal.ExecuteQuery(str_sql,out dt);
                        if (errInfo == "")
                        {
                            if (dt.Rows.Count > 0)
                            {
                                string dm = Convert.ToString(dt.Rows[0][0]);
                                if (dm == "00")
                                    rtMsg = "error:该箱码无效！！";
                                else if (dm == "01")
                                    rtMsg = "error:该箱码已装箱，装箱号为：" + Convert.ToString(dt.Rows[0][1]);
                                else
                                    rtMsg = "error:该箱码与要装箱的材料不符！";
                            }
                            else {
                                str_sql = @"select tm.chdm+':'+convert(char(10),sum(tm.sl))+'|'
                                            from cl_t_wlsmjlb a
                                            inner join cl_t_wltmb tm on a.sm=tm.tm 
                                            and a.zxxh='{0}' and a.smlb='tm' and a.zxbs=1
                                            group by tm.chdm
                                            for xml path('');";
                                str_sql = string.Format(str_sql, tm);
                                if (dt != null) {
                                    dt.Dispose();
                                    dt = null;
                                }
                                errInfo = dal.ExecuteQuery(str_sql, out dt);
                                if (errInfo == "" && dt.Rows.Count > 0)
                                {
                                    rtMsg = "success:" + dt.Rows[0][0].ToString();
                                }
                                else
                                {
                                    rtMsg = "error:获取对应箱码装箱数据2失败：" + errInfo;
                                    writeLog(rtMsg + "\r\n" + str_sql);
                                }                       
                            }
                        }
                        else {
                            rtMsg = "error:查询箱码2使用情况时出错:" + errInfo;
                            writeLog(rtMsg + "\r\n" + str_sql);
                        }
                    }
                    else
                    {
                        str_sql = " declare @zxh varchar(50);set @zxh=isnull((select isnull(zxxh,0) from cl_t_wlsmjlb where tzid='" + tzid + "' and smlb='xh' and sm = '" + tm + "'),0);";
                        str_sql += " if @zxh='0' select top 1 convert(char(10),count(*))+'|' from cl_t_dddjmx a inner join cl_t_wlzxd wl on wl.lymxid=a.mxid and wl.zxxh = '" + tm + "'";
                        str_sql += " left outer join cl_t_dddjmx l on l.chdm=a.chdm and l.id in (" + ids + ")  where l.chdm is null; else select @zxh;";
                        dt = null;
                        errInfo = dal.ExecuteQuery(str_sql, out dt);
                        if (errInfo == "" && dt.Rows.Count > 0)
                        {
                            string[] rt = dt.Rows[0][0].ToString().Split('|');
                            if (rt.Length == 1)
                                rtMsg = "error:该箱码已装箱，装箱号为：" + rt[0];
                            else
                            {
                                if (Convert.ToInt32(rt[0]) > 0)
                                    rtMsg = "error:该箱码与要装箱的材料不符！";
                                else
                                {
                                    str_sql = "select a.chdm+':'+convert(char(10),sum(wl.sl))+'|' from cl_t_dddjmx a inner join cl_t_wlzxd wl on wl.lymxid=a.mxid and wl.zxxh = '" + tm + "' group by a.chdm for xml path('');";
                                    dt = null;
                                    errInfo = dal.ExecuteQuery(str_sql, out dt);
                                    if (errInfo == "" && dt.Rows.Count > 0)
                                    {
                                        rtMsg = "success:" + dt.Rows[0][0].ToString();
                                    }
                                    else
                                    {
                                        rtMsg = "error:获取对应箱码装箱数据失败：" + errInfo;
                                        writeLog(rtMsg + "\r\n" + str_sql);
                                    }
                                }//提取该箱码中对应的所有材料及数量                              
                            }
                        }
                        else
                        {
                            rtMsg = "error:查询箱码使用情况时出错:" + errInfo;
                            writeLog(rtMsg + "\r\n" + str_sql);
                        }
                    }
                }
                else {
                    rtMsg = "error:查询箱码是否有效时出错：" + errInfo;
                    writeLog(rtMsg + "\r\n" + str_sql);
                }                    
            }
        }
        
        return rtMsg;
    }
    
    [WebMethod]
    public string checkTM(string tzid, string tm)
    {
        string rtMsg = "", str_sql = "";
        if (tm == "")
            rtMsg = "error:条码参数为空！";
        else if (tzid == "")
            rtMsg = "error:当前套账ID参数为空！";
        else
        {
            using (LiLanzDALForXLM dal = new LiLanzDALForXLM())
            {
                str_sql = @"declare @zxxh varchar(50);declare @str varchar(100); 
                        select @zxxh=isnull((select top 1 isnull(a.zxxh,0) from cl_t_wlsmjlb a where a.tzid=@tzid and a.smlb='tm' and a.sm=@tm),0);

                        if @zxxh = '0' 
                        begin 
                        select @str=isnull((select convert(char(8),a.id)+'|'+isnull(a.chdm,'')+'|'+ convert(char(10),isnull(a.sl,0)) from cl_t_wltmb a where a.tm=@tm),-1) end
                        else 
                        begin 
                        select @str=@zxxh 
                        end; 

                        select @str;";
                DataTable dt = null;
                List<SqlParameter> para = new List<SqlParameter>();
                para.Add(new SqlParameter("@tzid", tzid));
                para.Add(new SqlParameter("@tm", tm));

                string errInfo = dal.ExecuteQuerySecurity(str_sql, para, out dt);
                if (errInfo == "")
                {
                    if (dt.Rows.Count > 0)
                    {
                        string result = dt.Rows[0][0].ToString();
                        if (result == "-1")
                            rtMsg = "warn:扫描的条码不存在！";
                        else if (result != "")
                            rtMsg = "success:" + result;
                    }
                }
                else
                {
                    rtMsg = "error:" + errInfo;
                }
            }
        }
        return rtMsg;
    }

    [WebMethod]
    public string saveData(string objStr, string username, string tzid, string[] tmArray,string[] xmArray)
    {
        string rtMsg = "";
        if (username == "")
            rtMsg = "error:当前用户名为空！";
        else if (tzid == "")
            rtMsg = "error:tzid参数为空！";
        else
        {
            ZXDData obj = XmlDeSerialize<ZXDData>(objStr);
            string str_sql = "SET XACT_ABORT ON BEGIN TRAN ";
            str_sql += " declare @zxid int;declare @zxh varchar(50);declare @zpc varchar(50);";
            str_sql += " select @zpc=right(convert(varchar(8),getdate(),112),6)+'_" + obj.khdm + "_" + obj.pc + "';";
            str_sql += " declare @maxdjh varchar(6);set @maxdjh='001';";
            str_sql += " select top 1  @maxdjh=right('000'+cast(cast(right(a.zxxh,3) as int)+1 as varchar),3) from cl_t_wlzxd a ";
            str_sql += " where a.tzid=1 and a.zxpc=@zpc order by a.zxxh desc;set @zxh=@zpc+'_'+@maxdjh;";

            if (obj.mxTable.Rows.Count > 0)
            {
                string isxj = "0";
                isxj = tzid == "1" ? "0" : "1";
                for (int i = 0; i < obj.mxTable.Rows.Count; i++)
                {
                    if (obj.mxTable.Rows[i]["xlsl"] == "")
                        continue;
                    else if (Convert.ToDouble(obj.mxTable.Rows[i]["xlsl"]) == 0)
                        continue;
                    str_sql += " insert into cl_t_wlzxd(tzid,zxxh,lyid,lymxid,sl,zdrq,zdr,bz,zxpc,xzl,zbz,isxj) values ";
                    str_sql += " (@tzid,@zxh,'" + obj.mxTable.Rows[i]["id"].ToString() + "','" + obj.mxTable.Rows[i]["mxid"].ToString() + "','" + obj.mxTable.Rows[i]["xlsl"].ToString() + "'";
                    str_sql += ",getdate(),@username,'" + obj.mxTable.Rows[i]["zxbz"].ToString() + "',@zpc,'" + obj.xzl + "','" + obj.bz + "','" + isxj + "');";
                }

                //处理条码
                if (tmArray.Length > 0)
                {
                    str_sql += "select a.sm into #tmtmp from (";
                    for (int i = 0; i < tmArray.Length; i++)
                    {
                        //str_sql += "update cl_t_wltmb set zxxh=@zxh,syzt=1 where tm='" + tmArray[i] + "';";
                        //str_sql += "if not exists(select top 1 1 from cl_t_wlsmjlb where sm='"+tmArray[i]+"' and zxxh=@zxh and smlb='tm' and tzid=@tzid) ";
                        //str_sql += " insert into cl_t_wlsmjlb(tzid,sm,zxxh,smlb) select @tzid,tm,@zxh,'tm' from cl_t_wltmb where tm='" + tmArray[i] + "';";

                        if (i == tmArray.Length - 1)
                            str_sql += "select '" + tmArray[i] + "' sm) a ";
                        else
                            str_sql += "select '" + tmArray[i] + "' sm union all ";
                    }
                    //left join cl_t_wlsmjlb b on a.sm=b.sm and b.tzid=@tzid where b.id is null;
                    str_sql += " update a set a.zxxh=@zxh,a.syzt=1 from cl_t_wltmb a inner join #tmtmp b on a.tm=b.sm;";
                    str_sql += " insert cl_t_wlsmjlb(tzid,sm,zxxh,smlb) select @tzid,a.sm,@zxh,'tm' from #tmtmp a ;drop table #tmtmp;";
                }
                //处理箱码
                if (xmArray.Length > 0) {
                    for (int i = 0; i < xmArray.Length; i++) {
                        str_sql += " insert into cl_t_wlsmjlb(tzid,sm,zxxh,smlb) values (@tzid,'" + xmArray[i] + "',@zxh,'xh');";
                    }                 
                }                
                str_sql += "select @zxh;COMMIT TRAN GO;";
                using (LiLanzDALForXLM dal = new LiLanzDALForXLM())
                {
                    DataTable dt = null;
                    List<SqlParameter> para = new List<SqlParameter>();
                    para.Add(new SqlParameter("@tzid", tzid));
                    para.Add(new SqlParameter("@username", username));

                    string errInfo = dal.ExecuteQuerySecurity(str_sql, para, out dt);
                    if (errInfo == "")
                    {
                        if (dt.Rows.Count > 0)
                        {
                            rtMsg = dt.Rows[0][0].ToString();
                        }
                    }
                    else
                    {
                        rtMsg = "error:" + errInfo;                        
                        //writeLog(rtMsg + "\r\n" + str_sql);
                    }
                }
            }
            writeLog("\r\nSQL:" + str_sql + "\r\ntmList:" + string.Join(",", tmArray) + "\r\nxmList:" + string.Join(",", xmArray));
        }        
        return rtMsg;
    }

    //条码生成模块的条码信息查询
    [WebMethod]
    public string GetTMInfo(string tmcode)
    {
        string rtMsg = "";
        using (LiLanzDALForXLM dal = new LiLanzDALForXLM())
        {
            string str_sql = @"select convert(char(8),a.id)+'|'+a.chdm+'|'+isnull(a.bz,'')+'|'+CONVERT(varchar, a.rq, 102)+'|'+isnull(b.chmc,'')+'|'+isnull(b.dw,'')+'|'+isnull(b.fk,'')+'|'+isnull(b.kez,'')+
                                '|'+isnull(a.fs,'')+'|'+isnull(a.gh,'')+'|'+isnull(a.zl,'')+'|'+isnull(a.mlbz,'')+'|'+isnull(a.tmdw,'')+'|'+convert(char(2),a.tmlb)+'|'+isnull(a.fk,'')+'|'+isnull(a.kz,'')+'|'+isnull(a.ddh,'')+'|'+cast(isnull(a.sl,0) as varchar)
                                from cl_t_wltmb a inner join CL_T_chdmb b on a.chdm=b.chdm and b.tzid=@zbid where tm=@tmcode";
            List<SqlParameter> paras = new List<SqlParameter>();
            paras.Add(new SqlParameter("@zbid", 1));
            paras.Add(new SqlParameter("@tmcode", tmcode));
            DataTable dt = null;
            string errInfo = dal.ExecuteQuerySecurity(str_sql, paras, out dt);
            if (errInfo == "")
            {
                if (dt.Rows.Count > 0)
                {
                    rtMsg = dt.Rows[0][0].ToString();
                }
                else
                    rtMsg = "Error:查询不到该条码信息！";
            }
            else
            {
                rtMsg = "Error:查询条码信息时出错！" + errInfo;
            }
        }
        return rtMsg;
    }

    //条码生成模块的条码生成函数    
    [WebMethod]
    public string GenerateTM(string SourceID, double sl, string zl, string zdr)
    {
        string rtMsg = "";
        using (LiLanzDALForXLM dal = new LiLanzDALForXLM())
        {
            string str_sql = @"declare @strTm varchar(20); 
                                set @strTm=right(CONVERT(varchar(12), getdate(), 112),6) + isnull((select top 1 right(tm,5) as b from cl_t_wltmb where CONVERT(varchar(12),rq,112)=CONVERT(varchar(12),getdate(),112) order by id desc),'00000'); 
                                insert cl_t_wltmb(tzid,tmlb,chdm,bz,tmdw,rq,sl,tm,syzt,zdr,zl,fs,gh,mlbz,fk,kz,ddh) 
                                select 1,tmlb,chdm,'',tmdw,getdate(),@sl,cast(@strTm as bigint)+1,0,@zdr,@zl,fs,gh,'',fk,kz,'' from cl_t_wltmb where id=@id;
                                select cast(@strTm as bigint)+1;";//SCOPE_IDENTITY();
            List<SqlParameter> paras = new List<SqlParameter>();
            paras.Add(new SqlParameter("@sl", sl));
            paras.Add(new SqlParameter("@zdr", zdr));
            paras.Add(new SqlParameter("@zl", zl));
            paras.Add(new SqlParameter("@id", SourceID));
            DataTable dt = null;
            string errInfo = dal.ExecuteQuerySecurity(str_sql, paras, out dt);
            if (errInfo == "")
            {
                if (dt.Rows.Count > 0)
                {
                    rtMsg = dt.Rows[0][0].ToString();
                }
                else
                    rtMsg = "Error:生成失败！newid=0";
            }
            else
                rtMsg = "Error:" + errInfo;
        }//end using

        return rtMsg;
    }

    /// <summary>
    /// 序列化DataTable
    /// </summary>
    private string SerializeDataTableXml(DataTable pDt)
    {
        //序列化DataTable
        StringBuilder sb = new StringBuilder();
        XmlWriter writer = XmlWriter.Create(sb);
        XmlSerializer serializer = new XmlSerializer(typeof(DataTable));
        serializer.Serialize(writer, pDt);
        writer.Close();
        return sb.ToString();
    }

    //反序列化函数
    public static T XmlDeSerialize<T>(string objString)
    {
        XmlSerializer serializer = new XmlSerializer(typeof(T));
        MemoryStream ms = new MemoryStream(System.Text.Encoding.UTF8.GetBytes(objString));
        ms.Position = 0;
        T _obj = (T)serializer.Deserialize(ms);
        ms.Close();
        return _obj;
    }

    //写日志文件方法
    public static void writeLog(string info)
    {
        try
        {
            clsLocalLoger.logDirectory = HttpContext.Current.Server.MapPath("logs/");
            if (System.IO.Directory.Exists(clsLocalLoger.logDirectory) == false)
            {
                System.IO.Directory.CreateDirectory(clsLocalLoger.logDirectory);
            }
            clsLocalLoger.WriteInfo(info);
        }
        catch (Exception ex)
        {

        }
    }
}

/// <summary>
/// 数据实体类
/// </summary>
public class ZXDData : IDisposable
{
    //主表信息
    private string _pc;
    private string _bz;
    private string _xzl;
    private string _khdm;

    //明细数据
    private DataTable _mxTable;

    public string pc
    {
        get { return this._pc; }
        set { this._pc = value; }
    }

    public string bz
    {
        get { return this._bz; }
        set { this._bz = value; }
    }

    public string xzl
    {
        get { return this._xzl; }
        set { this._xzl = value; }
    }

    public string khdm
    {
        get { return this._khdm; }
        set { this._khdm = value; }
    }

    public DataTable mxTable
    {
        get { return this._mxTable; }
        set { this._mxTable = value; }
    }


    #region IDisposable 成员

    public void Dispose()
    {
        _mxTable.Clear();
        _mxTable.Dispose();
    }

    #endregion
}

