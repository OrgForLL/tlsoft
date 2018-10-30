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
    string  CS="ok";
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
            case "ypcjfl_save":
                InfoSave("cjfl");
                break;
            case "ypwgqr_save":
                InfoSave("wgqr");
                break;
            case "ypzjts_save":
                InfoSave("zjts");
                break;
            case "ypzjdk_save":
                InfoSave("zjdk");
                break;
            case "ypcjjs_getInfo":
                GetInfo("cjjs");
                break;
            case "ypcjfl_getInfo":
                GetInfo("cjfl");
                break;
            case "ypwgqr_getInfo":
                GetInfo("wgqr");
                break;
            case "ypzjts_getInfo":
                GetInfo("wgqr");
                break;
            case "ypzjdk_getInfo":
                GetInfo("wgqr");
                break;
            case "ypxxcx_getInfo":
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
            int fzlx = int.Parse(Request.Params["fzlx"]);
            int bsid = int.Parse(Request.Params["bsid"]);
            int xmjlid = int.Parse(Request.Params["xmjlid"]);
            string fzmc = Convert.ToString(Request.Params["fzmc"]);
            string OAConnStr = clsConfig.GetConfigValue("OAConnStr");
            using (LiLanzDALForXLM dal = new LiLanzDALForXLM(OAConnStr))
            {

                string str_sql;
                if (cllx == "cjjs")
                {
                    str_sql = @"
                         declare @username varchar(20);set @username='';
                         select @username=xm from rs_t_ryxxb where id=@userid;
                         if @fzlx ='1'
                         begin
                            delete from yf_t_yprygxb where tzid=@tzid and id=@key and djlx='tgry' and dxlx='cjs';
                            update yf_t_cpkfsjtg set cjs=@username+';',cjjsr=@username,cjjsbs=1,cjjsrq=getdate() where id=@key;
			                Insert into yf_t_yprygxb (tzid,id,mxid,djlx,dxlx,val,txt,bl) values(@tzid,@key,0,'tgry','cjs',@userid,@username,'100.00');
                            insert into xt_t_djshjl (tzid,zblx,zbid,xh,shgwid,shsj,shr,shzt,shyj,dadm) values(@tzid,1005,@key,0,0,getdate(),@username,1,'手机裁剪接收','');                                
                         end 
                         else if @fzlx='2'
                         begin
                             declare @userss varchar(200);
                             select @userss=(select a.rymc+';' from yf_v_cpkfmbz a where a.fzmc=@fzmc for xml path(''));
                             delete from yf_t_yprygxb where tzid=@tzid and id=@key and djlx='tgry' and dxlx='cjs';
                             Insert into yf_t_yprygxb (tzid,id,mxid,djlx,dxlx,val,txt,bl) select a.tzid,@key,0,'tgry','cjs',ryid,rymc,bl from yf_v_cpkfmbz a where a.fzmc=@fzmc;
                                
                             update yf_t_cpkfsjtg set cjs=@userss,cjjsr=@username,cjjsbs=1,cjjsrq=getdate() where id=@key;
                             insert into xt_t_djshjl (tzid,zblx,zbid,xh,shgwid,shsj,shr,shzt,shyj,dadm) values(@tzid,1005,@key,0,0,getdate(),@username,1,'手机裁剪接收','');                            
                         end
                            ";

                }else if (cllx == "cjfl")
                {
                    str_sql = @"declare @username varchar(20);declare @xmjl varchar(20);declare @bs varchar(20);declare @yygid varchar(20);set @username='';
                         declare @userss varchar(200);
                         select @username=xm from rs_t_ryxxb where id=@userid;
                         select @yygid=id from rs_t_ryxxb where xm=@fzmc;
                         select @xmjl=xm+';' from rs_t_ryxxb where id=@xmjlid;
                         select @bs=xm+';' from rs_t_ryxxb where id=@bsid;
                         if @fzlx ='1'
                         begin
                            delete from yf_t_yprygxb where tzid=@tzid and id=@key and djlx='tgry' and dxlx='yygs';
                            update yf_t_cpkfsjtg set yyg=@username,cjflbs=1,cjflr=@username,cjfsrq=getdate(),xmjl=@xmjl,xmjlid=@xmjlid,bs=@bs,bsid=@bsid where id=@key;
                            Insert into yf_t_yprygxb (tzid,id,mxid,djlx,dxlx,val,txt,bl) values(@tzid,@key,0,'tgry','yygs',@userid,@username,'100');
			                insert into xt_t_djshjl (tzid,zblx,zbid,xh,shgwid,shsj,shr,shzt,shyj,dadm) values(@tzid,1005,@key,0,0,getdate(),@username,1,'手机裁剪发料','');
                         end
                         else if @fzlx='2'
                         begin
                                if @fzmc = 'T恤组' or @fzmc='休衬组' or @fzmc='正衬组' or @fzmc='轻商务组' 
                                begin
                                    select @userss=(select a.rymc+';' from yf_v_cpkfmbz a where a.fzmc=@fzmc for xml path(''));
                                    delete from yf_t_yprygxb where tzid=@tzid and id=@key and djlx='tgry' and dxlx='yygs';
                                    Insert into yf_t_yprygxb (tzid,id,mxid,djlx,dxlx,val,txt,bl) select a.tzid,@key,0,'tgry','yygs',ryid,rymc,bl from yf_v_cpkfmbz a where a.fzmc=@fzmc;

                                    update yf_t_cpkfsjtg set yyg=@userss,cjflbs=1,cjflr=@username,cjfsrq=getdate(),xmjl=@xmjl,xmjlid=@xmjlid,bs=@bs,bsid=@bsid where id=@key;
                                    insert into xt_t_djshjl (tzid,zblx,zbid,xh,shgwid,shsj,shr,shzt,shyj,dadm) values(@tzid,1005,@key,0,0,getdate(),@username,1,'手机裁剪发料','');                         
                                end else
                                begin
                                    delete from yf_t_yprygxb where tzid=@tzid and id=@key and djlx='tgry' and dxlx='yygs';
                                    update yf_t_cpkfsjtg set yyg=@fzmc+';',cjflbs=1,cjflr=@username,cjfsrq=getdate(),xmjl=@xmjl,xmjlid=@xmjlid,bs=@bs,bsid=@bsid where id=@key;
                                    insert into yf_t_yprygxb (tzid,id,mxid,djlx,dxlx,val,txt,bl) values(@tzid,@key,0,'tgry','yygs',@yygid,@fzmc,'100');
                                    insert into xt_t_djshjl (tzid,zblx,zbid,xh,shgwid,shsj,shr,shzt,shyj,dadm) values(@tzid,1005,@key,0,0,getdate(),@username,1,'手机裁剪发料','');                         
                                end
                         end 
                        ";
                }
                else if (cllx == "wgqr")
                {
                    str_sql = @"
                            declare @username varchar(20);set @username='';                         
                            select @username=xm from rs_t_ryxxb where id=@userid;
                            update yf_t_cpkfsjtg set zyjsr=@username,zyjsrq=getdate(),zyjsbs=1 where id=@key;
			                insert into xt_t_djshjl (tzid,zblx,zbid,xh,shgwid,shsj,shr,shzt,shyj,dadm) values(@tzid,1005,@key,0,0,getdate(),@username,1,'手机完工确认','');
                            

                            declare @zlmxid int ;
                            select @zlmxid=zlmxid from yf_t_cpkfsjtg where id=@key;
                            insert into yx_t_spdmb_ghs(tzid,sphh,shdm,spkh,spmc,yphh,kfbh) 
                            select 11228 as tzid,a.ypbh as sphh,'' shdm,a.ypkh spkh,e.ypmc spmc,a.ypbh as yphh,c.kfbh from yf_T_cpkfzlb a 
                            inner join yf_t_cpkfjh c on a.id=c.id 
                            left outer join YX_T_Ypdmb e on a.ypbh=e.yphh and e.tzid=@tzid
                            left outer join yx_t_spdmb_ghs hh on hh.tzid=11228 and a.ypbh=hh.sphh 
                            where c.tzid=@tzid and a.djlx=1003 and a.ypbh<>'' and a.zlmxid=@zlmxid and hh.sphh is null 
                        ";
                }
                else if (cllx == "zjts")
                {
                    str_sql = @"
                         declare @username varchar(20);set @username='';
                         select @username=xm from rs_t_ryxxb where id=@userid;
                         delete from yf_t_yprygxb where tzid=@tzid and id=@key and djlx='tgry' and dxlx='zjts';
                         update yf_t_cpkfsjtg set tsry=@username,tsrq=getdate() where id=@key;
			             Insert into yf_t_yprygxb (tzid,id,mxid,djlx,dxlx,val,txt,bl) values(@tzid,@key,0,'tgry','zjts',@userid,@username,'100.00');
                         insert into xt_t_djshjl (tzid,zblx,zbid,xh,shgwid,shsj,shr,shzt,shyj,dadm) values(@tzid,1005,@key,0,0,getdate(),@username,1,'手机烫衬','');                                                         
                    ";

                }
                else if (cllx == "zjdk")
                {
                    str_sql = @"
                         declare @username varchar(20);set @username='';
                         select @username=xm from rs_t_ryxxb where id=@userid;
                         delete from yf_t_yprygxb where tzid=@tzid and id=@key and djlx='tgry' and dxlx='zjdk';
                         update yf_t_cpkfsjtg set dkry=@username,dkrq=getdate() where id=@key;
			             Insert into yf_t_yprygxb (tzid,id,mxid,djlx,dxlx,val,txt,bl) values(@tzid,@key,0,'tgry','zjdk',@userid,@username,'100.00');
                         insert into xt_t_djshjl (tzid,zblx,zbid,xh,shgwid,shsj,shr,shzt,shyj,dadm) values(@tzid,1005,@key,0,0,getdate(),@username,1,'手机打扣',''); 
                    ";

                }
                else
                {
                    str_sql = "";
                }
                List<SqlParameter> para = new List<SqlParameter>();
                para.Add(new SqlParameter("@userid", userid));
                para.Add(new SqlParameter("@key", key));
                para.Add(new SqlParameter("@tzid", tzid));
                para.Add(new SqlParameter("@fzlx", fzlx));
                para.Add(new SqlParameter("@fzmc", fzmc));
                para.Add(new SqlParameter("@xmjlid", xmjlid));
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
                Response.Write("{result:'Successed',state:'Fail'}"+errInfo);
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
            int userid = int.Parse(Request.Params["userid"]);
            string OAConnStr = clsConfig.GetConfigValue("OAConnStr");
            //shbs:设计图稿审批标示; jsqrbs;打版接收标示;cjjsbs;裁剪接收标示; cjflbs:裁剪发料标示; zyjsbs:制样完工标示
            using (LiLanzDALForXLM dal = new LiLanzDALForXLM(OAConnStr))
            {
                string str_sql = @"
                   select a.* from (select a.id,a.cjs,a.yyg,a.flowid,a.jsr,c.kfbh,c.xlid,fg.mc as spfg,a.yphh,b.ypzlbh,e.mc as splbmc,isnull(a.cjjsbs,0) as jsbs,
                     isnull(a.shbs,0) as shbs,isnull(a.jsqrbs,0) jsqrbs,isnull(a.cjjsbs,0) as cjjsbs,isnull(a.cjflbs,0) cjflbs,isnull(a.zyjsbs,0) zyjsbs,a.zdrq,
                     case when a.zyjsbs=1 and DATEDIFF(D,isnull(a.zyjsrq,getdate()),getdate())>=1 then 1 else 0 end  as bs,a.tsrq,a.tsry,a.dkrq,a.dkry                                      
                      from yf_t_cpkfsjtg a
                      inner join yf_t_cpkfzlb b on a.zlmxid=b.zlmxid
                      inner join yf_t_cpkfjh c on b.id=c.id
                      left outer join yx_t_splb e on c.splbid=e.id
                      left outer join yx_v_spfgb fg on c.xlid=fg.dm and fg.tzid=1
                    where a.yphh=@yphh and a.tplx='sjtg' )a order by a.bs,a.zdrq asc ";
                //Response.Write(str_sql);
                List<SqlParameter> para = new List<SqlParameter>();
                para.Add(new SqlParameter("@yphh", yphh));
                errInfo = dal.ExecuteQuerySecurity(str_sql, para, out dt);
                //Response.Write(dt.Rows.Count);
            }


            //Response.Clear();
            if (dt.Rows.Count > 0)
            {
                getInfo(userid, cxlx);          
                if (cxlx == "wgqr"||cxlx=="cjfl") {                    
                    using (LiLanzDALForXLM MyDal = new LiLanzDALForXLM(OAConnStr))
                    {
                        string MySql = @"
                   
                             declare @zdxmjl varchar(20);declare @ryid int;declare @chmc varchar(200);declare @cfbl varchar(200);
                             select top 1 @chmc=a.mlbh,@cfbl=b.cfbl from yf_t_cpkfplxx_ml a inner join cl_t_chdmb b on a.chdm=b.chdm 
                                 inner join yf_t_cpkfsjtg c on a.zlmxid=c.zlmxid 
                             where a.zhmlid=1 and c.id=@tpid;
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

                             select 1 xh,@chmc as chmc,@cfbl as cfbl  into #wz; 
                             select * from #wz a left join  #xmjl b on a.xh=b.xh 
                                      union all 
                             select * from #wz a  left join #bs b on a.xh=b.xh; 
                             drop table #xmjl; drop table #bs;drop table #wz  
                        ";

                        //Response.Write(MySql);
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
                strResult.Append("cjs:'" + dt.Rows[0]["cjs"].ToString() + "',");
                strResult.Append("yyg:'" + dt.Rows[0]["yyg"].ToString() + "',");
                strResult.Append("jsqrbs:'" + dt.Rows[0]["jsqrbs"].ToString() + "',");
                strResult.Append("cjjsbs:'" + dt.Rows[0]["cjjsbs"].ToString() + "',");
                strResult.Append("cjflbs:'" + dt.Rows[0]["cjflbs"].ToString() + "',");
                strResult.Append("tsry:'" + dt.Rows[0]["tsry"].ToString() + "',");
                strResult.Append("tsrq:'" + dt.Rows[0]["tsrq"].ToString() + "',");
                strResult.Append("dkry:'" + dt.Rows[0]["dkry"].ToString() + "',");
                strResult.Append("dkrq:'" + dt.Rows[0]["dkrq"].ToString() + "',");
                
                if (cxlx == "wgqr" || cxlx=="cjfl") {
                    string xz ="" ;
                    xmjlid = MyDt.Rows[0]["ryid"].ToString();
                    bsid = MyDt.Rows[1]["ryid"].ToString();
                    xmjl = MyDt.Rows[0]["xm"].ToString();
                    bs = MyDt.Rows[1]["xm"].ToString();
                    strResult.Append("xmjl:'" + MyDt.Rows[0]["xm"].ToString() + "',");
                    strResult.Append("bs:'" + MyDt.Rows[1]["xm"].ToString() + "',");
                    strResult.Append("xmjlid:'" + MyDt.Rows[0]["ryid"].ToString() + "',");
                    strResult.Append("bsid:'" + MyDt.Rows[1]["ryid"].ToString() + "',");
                    strResult.Append("num:'" + MbDt.Rows.Count + "',");
                    //面料信息赋值 20161118
                    strResult.Append("chmc:'" + MyDt.Rows[0]["chmc"].ToString() + "',");
                    strResult.Append("cfbl:'" + MyDt.Rows[0]["cfbl"].ToString() + "',");

                    for(int i = 0; i < MbDt.Rows.Count; i++)
                    {
                        xz +=  MbDt.Rows[i]["mc"].ToString()+";";
                    }
                    strResult.Append("fz:'" + xz.ToString() + "',");
                }
                strResult.Append("zyjsbs:'" + dt.Rows[0]["zyjsbs"].ToString() + "',");
                strResult.Append("CS:'" + CS + "'");
                strResult.Append("}");
                Response.Write(strResult.ToString());
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
    //获取当前登录人员的岗位
    public void getInfo( int userid,string scanctrl)
    {
        DataTable ryid = null;
        try
        {
            string errInfo = "";
            string OAConnStr = clsConfig.GetConfigValue("OAConnStr");
            using (LiLanzDALForXLM dal = new LiLanzDALForXLM(OAConnStr))
            {
                string str_sql;
                str_sql = @"select a.id,gw.wlkzx,gw.kzx from rs_t_ryxxb a inner join rs_t_rygzdwzlb b on a.id=b.id inner join dm_t_gwdmb gw on b.gwid=gw.id where a.id=@userid";
                List<SqlParameter> para = new List<SqlParameter>();
                para.Add(new SqlParameter("@userid",userid));
                errInfo = dal.ExecuteQuerySecurity(str_sql, para,out ryid );
            }
            if (errInfo == "")
            {
                if ((scanctrl == "wgqr" || scanctrl == "cjfl") && ryid.Rows[0]["wlkzx"].ToString() == "21" && ryid.Rows[0]["kzx"].ToString() == "20")
                {
                    CS = "false";
                }
                else if ((scanctrl == "wgqr" || scanctrl == "cjjs") && ryid.Rows[0]["wlkzx"].ToString() == "22" && ryid.Rows[0]["kzx"].ToString() == "20")
                {
                    CS = "false";
                } else {
                    CS = "ok";
                }
            }else if (userid == 19163)
            {
                CS = "ok";
            } else
            {
                CS = "wsj";
            }
        }
        catch (SystemException ex)
        {
            CS = "wsj";
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