<%@ Page Language="C#" %>
<%@ Import Namespace="nrWebClass" %>
<%@ Import Namespace="System.Data" %>
<%@ Import Namespace="System.Data.SqlClient" %>
<%@ Import Namespace="System.Collections.Generic" %>
<%@ Import Namespace="System.IO" %>
<%@ Import Namespace="WebBLL.Core" %>
<script runat="server">  
    string tzid;
    string xmjl;
    string xmjlid;
    string bs;
    string bsid;

    protected void Page_Load(object sender, EventArgs e)
    {
        tzid = "1";
        xmjl = "";
        xmjlid = "";
        bs = "";
        bsid = "";

        string ctrl = Request.Params["ctrl"];
        if (string.IsNullOrEmpty(ctrl))
        {
            ctrl = "";
        }

        switch (ctrl)
        {
            case "ypcjjs_save":
                InfoSave("cjjs");
                break;
            case "ypwgqr_save":
                InfoSave("wgqr");
                break;
            case "ypcjjs_getInfo":
                GetInfo("cjjs");
                break;
            case "ypwgqr_getInfo":
                GetInfo("wgqr");
                break;
            default :
                break;
        }
    }
    //信息更新
    public void InfoSave(string cllx)
    {
        try
        {
            string errInfo = "";
            string key = Convert.ToString(Request.Params["key"]);
            string yphh = Convert.ToString(Request.Params["yphh"]);
            int userid = int.Parse(Request.Params["userid"]);
            int fzid = int.Parse(Request.Params["fzid"]);
            int bcbs = int.Parse(Request.Params["bcbs"]);
            string user = Convert.ToString(Request.Params["username"]);
            string OAConnStr = clsConfig.GetConfigValue("OAConnStr");
            using (LiLanzDALForXLM dal = new LiLanzDALForXLM(OAConnStr))
            {
                string str_sql;
                if (cllx == "cjjs")
                {
                    str_sql = @"
                         declare @username varchar(20);set @username='';
                         select @username=xm from rs_t_ryxxb where id=@userid;
                         if @bcbs =2
                         begin
                            declare @i int;declare @j int;declare @userss varchar(200);
                            set @j=1;
                                select @i=count(a.rymc) from yf_v_cpkfmbz a where a.fzid=@fzid ;
                                select @userss=stuff((select ';'+a.rymc from yf_v_cpkfmbz a where a.fzid=@fzid for xml path('')),1,1,'');
                                delete from yf_t_yprygxb where tzid=@tzid and id=@key and djlx='tgry' and dxlx='cjs';
                            while @j<@i+1 and @j<11
                            begin
                                declare @ryid int;declare @rymc varchar(15);
                                select @ryid=b.ryid,@rymc=b.rymc from (select ROW_NUMBER()over(order by a.ryid ) as xh,a.rymc,a.ryid From yf_v_cpkfmbz a where a.fzid=@fzid)b where b.xh=@j ;
                                Insert into yf_t_yprygxb (tzid,id,mxid,djlx,dxlx,val,txt,bl) values(@tzid,@key,0,'tgry','cjs',@ryid,@rymc,'0');
                                set @j=@j+1
                            end
                                update yf_t_cpkfsjtg set cjs=@userss,cjjsr=@username,cjjsbs=1,cjjsrq=getdate() where id=@key;
                                insert into xt_t_djshjl (tzid,zblx,zbid,xh,shgwid,shsj,shr,shzt,shyj,dadm) values(@tzid,1005,@key,0,0,getdate(),@username,1,'裁剪接收','');
                         end else if @bcbs =1
                         begin
                            
                            update yf_t_cpkfsjtg set cjs=@username,cjjsr=@username,cjjsbs=1,cjjsrq=getdate() where id=@key;
                            insert into xt_t_djshjl (tzid,zblx,zbid,xh,shgwid,shsj,shr,shzt,shyj,dadm) values(@tzid,1005,@key,0,0,getdate(),@username,1,'裁剪接收','');
                         end
                            ";

                }
                else if (cllx == "wgqr")
                {
                    str_sql = @"
                         declare @username varchar(20);set @username='';
                         select @username=xm from rs_t_ryxxb where id=@userid;
                         if @bcbs ='2'
                         begin
                            update yf_t_cpkfsjtg set zyjsr=@user,zyjsbs=1,zyjsrq=getdate(),xmjl=@xmjl,xmjlid=@xmjlid,bs=@bs,bsid=@bsid where id=@key;
                            insert into xt_t_djshjl (tzid,zblx,zbid,xh,shgwid,shsj,shr,shzt,shyj,dadm) values(@tzid,1005,@key,0,0,getdate(),@username,1,'完工确认','');                         
                         end else if @bcbs ='1'
                         begin
                            update yf_t_cpkfsjtg set zyjsr=@username,zyjsbs=1,zyjsrq=getdate(),xmjl=@xmjl,xmjlid=@xmjlid,bs=@bs,bsid=@bsid where id=@key;
                            insert into xt_t_djshjl (tzid,zblx,zbid,xh,shgwid,shsj,shr,shzt,shyj,dadm) values(@tzid,1005,@key,0,0,getdate(),@username,1,'完工确认','');
                        end
                        ";
                }
                else
                {
                    str_sql = "";
                }

                //clsSharedHelper.WriteInfo(str_sql);
                List<SqlParameter> para = new List<SqlParameter>();
                para.Add(new SqlParameter("@userid", userid));
                para.Add(new SqlParameter("@key", key));
                para.Add(new SqlParameter("@tzid", tzid));
                para.Add(new SqlParameter("@fzid", fzid));
                para.Add(new SqlParameter("@bcbs", bcbs));
                para.Add(new SqlParameter("@user", user));
                para.Add(new SqlParameter("@xmjl", xmjl));
                para.Add(new SqlParameter("@xmjlid", xmjlid));
                para.Add(new SqlParameter("@bs", bs));
                para.Add(new SqlParameter("@bsid", bsid));
                errInfo = dal.ExecuteNonQuerySecurity(str_sql, para);
                //发送信息
                SendWX(yphh, userid);
            }
            Response.Clear();

            if (errInfo == "")
            {
                Response.Write("{result:'Successed',state:'ok'}");
            }
            else
            {
                Response.Write("{result:'Successed',state:'Fail'}");
            }

        }
        catch (SystemException ex)
        {
            Response.Clear();
            Response.Write("{result:'Error',state:'" + ex.Message + "'}");
        }
        finally
        {
            Response.End();
        }
    }
    //获取信息
    public void GetInfo( string cxlx)
    {
        try
        {
            DataTable dt = null;
            DataTable MyDt = null;
            DataTable MbDt = null;
            string errInfo = "";
            //string strResult = "result:'Successed',key:'{0}',kfbh:'{1}',spfg:'{2}',yphh:'{3}',splbmc:'{4}',jsbs:'{5}'";
            StringBuilder strResult = new StringBuilder();
            string yphh = Convert.ToString(Request.Params["info"]);
            string OAConnStr = clsConfig.GetConfigValue("OAConnStr");
            //shbs:设计图稿审批标示; jsqrbs;打版接收标示;cjjsbs;裁剪接收标示; cjflbs:裁剪发料标示; zyjsbs:制样完工标示
            using (LiLanzDALForXLM dal = new LiLanzDALForXLM(OAConnStr))
            {
                string str_sql = @"
                   select top 1 a.id,a.flowid,a.jsr,c.kfbh,c.xlid,fg.mc as spfg,a.yphh,b.ypzlbh,e.mc as splbmc,isnull(a.cjjsbs,0) as jsbs,
                     isnull(a.shbs,0) as shbs,isnull(a.jsqrbs,0) jsqrbs,isnull(a.cjjsbs,0) as cjjsbs,isnull(a.cjflbs,0) cjflbs,isnull(a.zyjsbs,0) zyjsbs                   
                   from yf_t_cpkfsjtg a
                      inner join yf_t_cpkfzlb b on a.zlmxid=b.zlmxid
                      inner join yf_t_cpkfjh c on b.id=c.id
                      left outer join yx_t_splb e on c.splbid=e.id
                      left outer join yx_v_spfgb fg on c.xlid=fg.dm and fg.tzid=1
                    where a.yphh=@yphh and a.tplx='sjtg' order by a.id desc  
                    ";
                List<SqlParameter> para = new List<SqlParameter>();
                para.Add(new SqlParameter("@yphh", yphh));
                errInfo = dal.ExecuteQuerySecurity(str_sql, para, out dt);
            }


            Response.Clear();
            if (dt.Rows.Count > 0)
            {

                //int flowid = int.Parse(dt.Rows[0]["flowid"].ToString());
                //int tpid = int.Parse(dt.Rows[0]["id"].ToString());
                //string jsr = dt.Rows[0]["jsr"].ToString();
                if (cxlx == "wgqr") {
                    using (LiLanzDALForXLM MyDal = new LiLanzDALForXLM(OAConnStr))
                    {
                        string MySql = @"
                   
                             declare @zdxmjl varchar(20);declare @ryid int;
                             select top 1 @zdxmjl=a.creator,@ryid=t.ryid From fl_t_flowOpinion a inner join fl_t_nodeConfig b on a.nodeid=b.nodeid 
                             inner join t_user t on t.id=a.userid  where a.docid=(select docid FROM fl_t_flowRelation WHERE flowid=@flowid and dxid=@tpid  ) and b.cs='xmjl' order by a.id desc; 

                             select 1 xh, a.id as ryid,a.xm,a.xb,gw.mc as gwmc,bm.bmmc into #xmjl 
                             from rs_t_ryxxb a inner join rs_t_rygzdwzlb b on a.id=b.id    
                             inner join dm_t_gwdmb gw on b.gwid=gw.id inner join rs_t_bmdmb bm on b.bmid=bm.id 
                             where a.tzid=@userssid  and b.tzid=@userssid  and  a.xm =@zdxmjl or a.id=@ryid ; 

                             select 1 xh,a.id as ryid,a.xm,a.xb,gw.mc as gwmc,bm.bmmc  into #bs 
                             from rs_t_ryxxb a inner join rs_t_rygzdwzlb b on a.id=b.id   
                             inner join dm_t_gwdmb gw on b.gwid=gw.id inner join rs_t_bmdmb bm on b.bmid=bm.id 
                             where a.tzid=@userssid  and b.tzid=@userssid and a.xm =@jsr ; 

                             select 1 xh  into #wz; 
                             select * from #wz a left join  #xmjl b on a.xh=b.xh 
                                      union all 
                             select * from #wz a  left join #bs b on a.xh=b.xh; 
                             drop table #xmjl; drop table #bs;drop table #wz  
                        ";


                        List<SqlParameter> MyPara = new List<SqlParameter>();
                        MyPara.Add(new SqlParameter("@userssid",tzid ));
                        MyPara.Add(new SqlParameter("@flowid",int.Parse(dt.Rows[0]["flowid"].ToString()) ));
                        MyPara.Add(new SqlParameter("@tpid", int.Parse(dt.Rows[0]["id"].ToString())));
                        MyPara.Add(new SqlParameter("@jsr", dt.Rows[0]["jsr"].ToString()));
                        errInfo = MyDal.ExecuteQuerySecurity(MySql, MyPara, out MyDt);
                    }
                    using (LiLanzDALForXLM MbDal = new LiLanzDALForXLM(OAConnStr))
                    {
                        string MbSql = @"
                            select xm as mc,id as ryid from rs_t_ryxxb where bz='xnry'
                        ";
                        List<SqlParameter> MbPara = new List<SqlParameter>();
                        errInfo = MbDal.ExecuteQuerySecurity(MbSql, MbPara, out MbDt);
                        int num = MbDt.Rows.Count;
                    }
                }

                strResult.Append("{result:'Successed',");
                strResult.Append("key:'" + dt.Rows[0]["id"].ToString() + "',");
                strResult.Append("kfbh:'" + dt.Rows[0]["kfbh"].ToString() + "',");
                strResult.Append("spfg:'" + dt.Rows[0]["spfg"].ToString() + "',");
                strResult.Append("yphh:'" + dt.Rows[0]["yphh"].ToString() + "',");
                strResult.Append("splbmc:'" + dt.Rows[0]["splbmc"].ToString() + "',");
                strResult.Append("jsbs:'" + dt.Rows[0]["jsbs"].ToString() + "',");
                strResult.Append("shbs:'" + dt.Rows[0]["shbs"].ToString() + "',");
                strResult.Append("jsqrbs:'" + dt.Rows[0]["jsqrbs"].ToString() + "',");
                strResult.Append("cjjsbs:'" + dt.Rows[0]["cjjsbs"].ToString() + "',");
                strResult.Append("cjflbs:'" + dt.Rows[0]["cjflbs"].ToString() + "',");

                if (cxlx == "wgqr") {
                    string xz ="" ;
                    xmjlid = MbDt.Rows[0]["ryid"].ToString();
                    bsid = MbDt.Rows[1]["ryid"].ToString();
                    xmjl = MbDt.Rows[0]["mc"].ToString();
                    bs = MbDt.Rows[1]["mc"].ToString();
                    strResult.Append("xmjl:'" + MyDt.Rows[0]["xm"].ToString() + "',");
                    strResult.Append("bs:'" + MyDt.Rows[1]["xm"].ToString() + "',");
                    strResult.Append("num:'" + MbDt.Rows.Count + "',");
                    for(int i = 0; i < MbDt.Rows.Count; i++)
                    {
                        xz +=  MbDt.Rows[i]["mc"].ToString()+";";
                    }
                    strResult.Append("fz:'" + xz.ToString() + "',");
                }
                strResult.Append("zyjsbs:'" + dt.Rows[0]["zyjsbs"].ToString() + "'");
                strResult.Append("}");
                Response.Write(strResult.ToString());
                //Response.Write("{" + string.Format(strResult, dt.Rows[0]["id"].ToString(), dt.Rows[0]["kfbh"].ToString(), dt.Rows[0]["spfg"].ToString(), dt.Rows[0]["yphh"].ToString(), dt.Rows[0]["splbmc"].ToString(), dt.Rows[0]["jsbs"].ToString()) + "}");
            }
            else
            {
                Response.Write("{result:'Error',state:'无记录',errrorMessage:'" + yphh + "'}");
            }
        }
        catch (SystemException ex)
        {
            Response.Clear();
            Response.Write("{result:'Error',state:'" + ex.Message + "'}");
        }
        finally
        {
            Response.End();
        }
    }
    //微信消息发送
    public void SendWX(string yphh, int userid)
    {

        List<string> list = new List<string>();
        list.Add("1tlkjx");
        // end 需要发送的人 

        //发送内容
        string content = "样品货号:" + yphh + "\r\n";
        content += "接收人:" + yphh + "\r\n";
        content += "接收时间:" + DateTime.Now.ToLongDateString()+ "\r\n";
        content += "处理状态:裁剪接收成功";
        //end 发送内容

        try
        {
            foreach (string user in list)
            {
                clsJsonHelper bavJson=clsWXHelper.SendQYMessage(user,4,content);
                clsLocalLoger.WriteError(bavJson.jSon);
            }
        }
        catch (SystemException ex)
        {
            Response.Clear();
            Response.Write("{result:'Error',state:'" + ex.Message + "'}");
            Response.End();
        }
    }
</script>