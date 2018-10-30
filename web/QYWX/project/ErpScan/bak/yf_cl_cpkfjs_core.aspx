<%@ Page Language="C#" %>
<%@ Import Namespace="nrWebClass" %>
<%@ Import Namespace="System.Data" %>
<%@ Import Namespace="System.Data.SqlClient" %>
<%@ Import Namespace="System.Collections.Generic" %>
<%@ Import Namespace="System.IO" %>
<%@ Import Namespace="WebBLL.Core" %>
<script runat="server">  
    string tzid;
    protected void Page_Load(object sender, EventArgs e)
    {
        tzid = "1";        
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
            case "ypcjjs_getInfo":
                GetInfo();
                break;
            case "ypcjfl_getInfo":
                GetInfo();
                break;
            case "ypwgqr_getInfo":
                GetInfo();
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
            string OAConnStr = clsConfig.GetConfigValue("OAConnStr");
            using (LiLanzDALForXLM dal = new LiLanzDALForXLM(OAConnStr))
            {
                string str_sql;
                if (cllx == "cjjs")
                {
                    str_sql = @"declare @username varchar(20);set @username='';
                         select @username=cname from t_user where id=@userid;
                         update yf_t_cpkfsjtg set cjjsr=@username,cjjsbs=1,cjjsrq=getdate() where id=@key;
                         insert into xt_t_djshjl (tzid,zblx,zbid,xh,shgwid,shsj,shr,shzt,shyj,dadm) values(@tzid,1005,@key,0,0,getdate(),@username,1,'裁剪接收','');
                        ";
                }
                else if (cllx == "cjfl")
                {
                    str_sql = @"declare @username varchar(20);set @username='';
                         select @username=cname from t_user where id=@userid;
                         update yf_t_cpkfsjtg set cjflr=@username,cjflbs=1,cjfsrq=getdate() where id=@key;
                         insert into xt_t_djshjl (tzid,zblx,zbid,xh,shgwid,shsj,shr,shzt,shyj,dadm) values(@tzid,1005,@key,0,0,getdate(),@username,1,'裁剪发料','');
                        ";
                }
                else if (cllx == "wgqr")
                {
                    str_sql = @"declare @username varchar(20);set @username='';
                         select @username=cname from t_user where id=@userid;
                         update yf_t_cpkfsjtg set zyjsr=@username,zyjsbs=1,zyjsrq=getdate() where id=@key;
                         insert into xt_t_djshjl (tzid,zblx,zbid,xh,shgwid,shsj,shr,shzt,shyj,dadm) values(@tzid,1005,@key,0,0,getdate(),@username,1,'制样接收','');
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
                Response.Write("{result:'Successed',state:'fail'}");
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
    public void GetInfo()
    {
        try
        {
            DataTable dt = null;
            string errInfo = "";
            //string strResult = "result:'Successed',key:'{0}',kfbh:'{1}',spfg:'{2}',yphh:'{3}',splbmc:'{4}',jsbs:'{5}'";
            StringBuilder strResult = new StringBuilder();            
            string info = Convert.ToString(Request.Params["info"]);
            string OAConnStr = clsConfig.GetConfigValue("OAConnStr");
            //shbs:设计图稿审批标示; jsqrbs;打版接收标示;cjjsbs;裁剪接收标示; cjflbs:裁剪发料标示; zyjsbs:制样完工标示
            using (LiLanzDALForXLM dal = new LiLanzDALForXLM(OAConnStr))
            {
                string str_sql = @"
                   select top 1 a.id,c.kfbh,c.xlid,fg.mc as spfg,a.yphh,b.ypzlbh,e.mc as splbmc,isnull(a.cjjsbs,0) as jsbs,
                     isnull(a.shbs,0) as shbs,isnull(a.jsqrbs,0) jsqrbs,isnull(a.cjjsbs,0) as cjjsbs,0 cjflbs,isnull(a.zyjsbs,0) zyjsbs                   
                   from yf_t_cpkfsjtg a
                      inner join yf_t_cpkfzlb b on a.zlmxid=b.zlmxid
                      inner join yf_t_cpkfjh c on b.id=c.id
                      left outer join yx_t_splb e on c.splbid=e.id
                      left outer join yx_v_spfgb fg on c.xlid=fg.dm and fg.tzid=1
                    where a.yphh=@yphh and a.tplx='sjtg' order by a.id desc  
                    ";
                List<SqlParameter> para = new List<SqlParameter>();
                para.Add(new SqlParameter("@yphh", info));
                errInfo = dal.ExecuteQuerySecurity(str_sql, para, out dt);

            }
            Response.Clear();
            if (dt.Rows.Count > 0)
            {
                strResult.Append("{result:'Successed',");
                strResult.Append("key:'" + dt.Rows[0]["id"].ToString()+ "',");
                strResult.Append("kfbh:'" + dt.Rows[0]["kfbh"].ToString() + "',");
                strResult.Append("spfg:'" + dt.Rows[0]["spfg"].ToString() + "',");
                strResult.Append("yphh:'" + dt.Rows[0]["yphh"].ToString() + "',");
                strResult.Append("splbmc:'" + dt.Rows[0]["splbmc"].ToString() + "',");
                strResult.Append("jsbs:'" + dt.Rows[0]["jsbs"].ToString() + "',");
                strResult.Append("shbs:'" + dt.Rows[0]["shbs"].ToString() + "',");
                strResult.Append("jsqrbs:'" + dt.Rows[0]["jsqrbs"].ToString() + "',");
                strResult.Append("cjjsbs:'" + dt.Rows[0]["cjjsbs"].ToString() + "',");
                strResult.Append("cjflbs:'" + dt.Rows[0]["cjflbs"].ToString() + "',");
                strResult.Append("zyjsbs:'" + dt.Rows[0]["zyjsbs"].ToString() + "'");
                strResult.Append("}");
                Response.Write(strResult.ToString());
                //Response.Write("{" + string.Format(strResult, dt.Rows[0]["id"].ToString(), dt.Rows[0]["kfbh"].ToString(), dt.Rows[0]["spfg"].ToString(), dt.Rows[0]["yphh"].ToString(), dt.Rows[0]["splbmc"].ToString(), dt.Rows[0]["jsbs"].ToString()) + "}");
            }
            else
            {
                Response.Write("{result:'Error',state:'无记录',errrorMessage:'" + info + "'}");
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