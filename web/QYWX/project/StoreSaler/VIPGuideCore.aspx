<%@ Page Language="C#" %>

<%@ Import Namespace="nrWebClass" %>
<%@ Import Namespace="System.Configuration" %>
<%@ Import Namespace="System.Collections.Generic" %>
<%@ Import Namespace="System.Data" %>
<%@ Import Namespace="System.Data.SqlClient" %>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<script runat="server">
    string WXconnStr = ConfigurationManager.ConnectionStrings["Conn"].ConnectionString;

    protected void Page_Load(object sender, EventArgs e)
    {
        string ctrl = Convert.ToString(Request.Params["ctrl"]);
        string salerID = "", tzid = "", mdid = "", SystemKey = "";
        switch (ctrl)
        {
            case "getVIPList":
                mdid = Convert.ToString(Request.Params["mdid"]);
                string lastId = Convert.ToString(Request.Params["lastID"]);
                SystemKey = Convert.ToString(Request.Params["SystemKey"]);
                if (lastId == "" || lastId == null)
                    lastId = "0";
                clsSharedHelper.WriteInfo(GetVIPList(mdid, lastId, SystemKey));
                break;
            case "getSalerList":
                mdid = Convert.ToString(Request.Params["mdid"]);
                tzid = Convert.ToString(Request.Params["tzid"]);
                clsSharedHelper.WriteInfo(GetSalerList(tzid, mdid));
                break;
            case "bindVIPSaler":
                mdid = Convert.ToString(Request.Params["mdid"]);
                salerID = Convert.ToString(Request.Params["salerID"]);
                //string vipID = Convert.ToString(Request.Params["vipID"]);
                string opinion= Convert.ToString(Request.Params["opinion"]);
                string openid = Convert.ToString(Request.Params["openid"]);
                clsSharedHelper.WriteInfo(BindVIPSaler(mdid, salerID, opinion, openid));
                break;
            case "getBindSaler":
                salerID = Convert.ToString(Request.Params["salerID"]);
                clsSharedHelper.WriteInfo(GetBindSaler(salerID));
                break;
            case "FilterVIP":
                mdid = Convert.ToString(Request.Params["mdid"]);
                SystemKey = Convert.ToString(Request.Params["SystemKey"]);
                string type = Convert.ToString(Request.Params["type"]);
                string saler = Convert.ToString(Request.Params["saler"]);
                clsSharedHelper.WriteInfo(FilterVIP(mdid, type, saler, SystemKey));
                break;
            default:
                clsSharedHelper.WriteErrorInfo("参数【ctrl】有误！");
                break;
        }
    }

    /// <summary>
    /// 获取VIP列表
    /// </summary>
    /// <param name="customersID"></param>
    /// <param name="defaultImg"></param>
    /// <returns></returns>
    public string GetVIPList(string mdid, string lastId, string systemkey)
    {
        string strInfo = ""; ;
        string strSQL = "";
        string img = "";
        List<SqlParameter> paras = new List<SqlParameter>();
        strSQL = @"select row_number() over ( order by v.vipid desc) xh,v.* into #temp
                    from (
	                    select vb.wxHeadimgurl,vb.wxNick xm,CONVERT(varchar(10),vb.createTime,120) createTime,ISNULL(vb.vipID,0) vipid,vb.id wxid,
                        ocu.ID as salerid,vb.wxOpenid openid,case vb.wxSex when 1 then '男' when 2 then '女' end as xb,ocu.cname salername, CASE WHEN ISNULL(vb.vipID,0)>0 THEN 'VIP-WX' ELSE 'WX' end usertype 
	                    from wx_t_vipBinging vb 
	                    left join wx_t_VipServerBind vsb on vb.wxOpenid=vsb.OpenID  AND vb.id=vsb.wxid
	                    left join wx_t_customers ocu on vsb.cid=ocu.ID 
						WHERE vb.mdid=@mdid 
                    ) v 
                       order by v.vipid desc,v.xm,v.createTime desc;";

        if (lastId != "-1")
        {
            strSQL += @"select top 100 a.wxHeadimgurl,a.xm,a.createTime,a.vipid,a.wxid,a.xb,a.salername,a.salerid,a.openid,'' rs,a.xh,a.usertype 
                        from #temp a where a.xh>@lastId order by a.xh; drop table #temp;";
        }
        else
        {
            strSQL += @"select top 100 a.wxHeadimgurl,a.xm,a.createTime,a.vipid,a.wxid,a.xb,a.salername,a.salerid,a.openid,b.rs,a.xh,a.usertype
                        from #temp a inner join (select COUNT(1) rs from #temp) b on 1=1 order by a.xh;   drop table #temp;";
        }
        paras.Add(new SqlParameter("@mdid", mdid));
        //paras.Add(new SqlParameter("@systemkey", systemkey));
        paras.Add(new SqlParameter("@lastId", lastId));

        using (LiLanzDALForXLM dal = new LiLanzDALForXLM(WXconnStr))
        {
            DataTable dt;
            strInfo = dal.ExecuteQuerySecurity(strSQL.ToString(), paras, out dt);

            if (strInfo == "")
            {
                if (dt.Rows.Count > 0)
                {
                    //foreach (DataRow row in dt.Rows)
                    //{
                    //    img = row[0].ToString();
                    //    if (clsWXHelper.IsWxFaceImg(img))
                    //    {
                    //        //是微信头像
                    //        row[0] = clsWXHelper.GetMiniFace(img);
                    //    }
                    //    else if (img.Length > 0)
                    //    {
                    //        row[0] = clsConfig.GetConfigValue("VIP_WebPath") + img;
                    //    }
                    //}
                    ConvertHeadimgURL(ref dt);
                    strInfo = JsonHelp.dataset2json(dt);
                }
                else
                {
                    strInfo = "Warn:没查询到相关VIP数据！";
                }
            }
            else
            {
                strInfo = "Error：" + strInfo;
            }
        }
        return strInfo;
    }

    /// <summary>
    /// 筛选VIP
    /// </summary>
    /// <param name="customersID"></param>
    /// <param name="defaultImg"></param>
    /// <returns></returns>
    public string FilterVIP(string mdid, string type, string saler, string systemkey)
    {
        string strInfo = ""; ;
        string strSQL = "";
        string img = "";
        strSQL = @"select v.wxHeadimgurl,v.xm,v.createTime,v.vipid,v.wxid,v.xb,v.salername,v.salerid,v.openid,
                    '' rs,row_number() over ( order by v.vipid desc) xh,v.usertype
                    from (
	                     select vb.wxHeadimgurl,vb.wxNick xm,CONVERT(varchar(10),vb.createTime,120) createTime,ISNULL(vb.vipID,0) vipid,vb.id wxid,
                          isnull(ocu.ID,0) as salerid,vb.wxOpenid openid,case vb.wxSex when 1 then '男' when 2 then '女' end as xb,
                          isnull(ocu.cname,'未分配') salername, CASE WHEN ISNULL(vb.vipID,0)>0 THEN 'VIP-WX' ELSE 'WX' end usertype 
	                    from wx_t_vipBinging vb 
	                    left join wx_t_VipServerBind vsb on vb.wxOpenid=vsb.OpenID  AND vb.id=vsb.wxid
	                    left join wx_t_customers ocu on vsb.cid=ocu.ID 
						WHERE vb.mdid=@mdid
                    ) v ";

        switch (type)
        {
            //case "haswx"://已激活微信
            //    strSQL += " where v.wxid>0 order by v.vipid desc,v.xm,v.createTime desc;";
            //    break;
            //case "notwx"://未激活微信
            //    strSQL += " where v.wxid=0 order by v.vipid desc,v.xm,v.createTime desc;";
            //    break;
            case "hasSaler"://已分配导购
                strSQL += " where isnull(v.salerid,0)>0 order by v.vipid desc,v.xm,v.createTime desc;";
                break;
            case "notSaler"://未分配导购
                strSQL += " where isnull(v.salerid,0)=0 order by v.vipid desc,v.xm,v.createTime desc;";
                break;
            case "saler"://导购saler所负责的人
                strSQL += " where v.salerid=@saler order by v.vipid desc,v.xm,v.createTime desc;";
                break;
                //case "fans"://为注册VIP
                //    strSQL += " where v.usertype='WX' order by v.vipid desc,v.xm,v.createTime desc;";
                //    break;
        }
        List<SqlParameter> paras = new List<SqlParameter>();
        paras.Add(new SqlParameter("@mdid", mdid));
        paras.Add(new SqlParameter("@saler", saler));
        //  paras.Add(new SqlParameter("@systemkey", systemkey));

        using (LiLanzDALForXLM dal = new LiLanzDALForXLM(WXconnStr))
        {
            DataTable dt;
            strInfo = dal.ExecuteQuerySecurity(strSQL.ToString(), paras, out dt);

            if (strInfo == "")
            {
                if (dt.Rows.Count > 0)
                {
                    //foreach (DataRow row in dt.Rows)
                    //{
                    //    img = row[0].ToString();
                    //    if (clsWXHelper.IsWxFaceImg(img))
                    //    {
                    //        //是微信头像
                    //        row[0] = clsWXHelper.GetMiniFace(img);
                    //    }
                    //    else if (img.Length > 0)
                    //    {
                    //        row[0] = clsConfig.GetConfigValue("VIP_WebPath") + img;
                    //    }
                    //}
                    ConvertHeadimgURL(ref dt);
                    strInfo = JsonHelp.dataset2json(dt);
                }
                else
                {
                    strInfo = "Warn:没查询到相关VIP数据！";
                }
            }
            else
            {
                strInfo = "Error：" + strInfo;
            }
        }
        return strInfo;
    }

    /// <summary>
    /// 获取导购列表
    /// </summary>
    /// <param name="customersID"></param>
    /// <param name="defaultImg"></param>
    /// <returns></returns>
    public string GetSalerList(string tzid, string mdid)
    {
        string strInfo = "";
        string img = "";
        string strSQL = @"select avatar,isnull(o.Nickname,d.xm) xm,d.xb,f.mc,v2.ID salerid,isnull(g.mc,'未知') gwmc
                        from rs_t_Ryjbzl d
                        inner join wx_t_OmniChannelUser o on d.id=o.relateID
                        inner join rs_t_rydwzl e on d.id=e.id and e.rzzk='1' and e.mdid=@mdid
                        left join dm_t_xzjbb f on o.GradePositions=f.id
                        left join rs_t_gwdmb g on o.PositionID=g.id 
                        inner  join wx_t_AppAuthorized v1 on o.id=v1.systemkey and v1.systemid=3
                        inner  join wx_t_customers v2 on v1.userid=v2.id 
                        where e.tzid=@tzid order by o.Nickname";
        List<SqlParameter> paras = new List<SqlParameter>();
        paras.Add(new SqlParameter("@tzid", tzid));
        paras.Add(new SqlParameter("@mdid", mdid));
        //paras.Add(new SqlParameter("@defaultImg", defaultImg));
        using (LiLanzDALForXLM dal = new LiLanzDALForXLM(WXconnStr))
        {
            DataTable dt;
            strInfo = dal.ExecuteQuerySecurity(strSQL, paras, out dt);

            if (strInfo == "")
            {
                if (dt.Rows.Count > 0)
                {
                    foreach (DataRow row in dt.Rows)
                    {
                        img = row[0].ToString();
                        if (clsWXHelper.IsWxFaceImg(img))
                        {
                            //是微信头像
                            row[0] = clsWXHelper.GetMiniFace(img);
                        }
                        else if (img.Length > 0)
                        {
                            row[0] = clsConfig.GetConfigValue("OA_WebPath") + img;
                        }
                    }
                    strInfo = JsonHelp.dataset2json(dt);
                }
                else
                {
                    strInfo = "Warn：没找到该门店的导购数据！";
                }
            }
            else
            {
                strInfo = "Error：" + strInfo;
            }
        }
        return strInfo;
    }

    /// <summary>
    /// 获取VIP专属导购信息
    /// </summary>
    /// <param name="salerID"></param>
    /// <returns></returns>
    public string GetBindSaler(string salerID)
    {
        string strInfo = "";
        string strSQL = @"SELECT a.avatar,a.cname AS xm,case a.gender when 1 then '男' else '女' end as xb,f.mc,isnull(g.mc,'') gwmc,isnull(sl.sl,0) rs
                            FROM wx_t_customers a
                            INNER JOIN dbo.wx_t_AppAuthorized b ON a.id=b.UserID AND b.SystemID=3
                            INNER JOIN dbo.wx_t_OmniChannelUser c ON b.SystemKey=c.ID
                            LEFT JOIN rs_t_rydwzl d ON c.relateID=d.id
                            left join dm_t_xzjbb f on c.GradePositions=f.id
                            left join rs_t_gwdmb g on c.PositionID=g.id
                            left join (select count(*) sl,a.cid   from wx_t_VipServerBind a where a.cid=@salerID group by a.cid) sl ON a.id=sl.cid
                            WHERE a.id = @salerID; ";
        List<SqlParameter> paras = new List<SqlParameter>();
        paras.Add(new SqlParameter("@salerID", salerID));
        using (LiLanzDALForXLM dal = new LiLanzDALForXLM(WXconnStr))
        {
            DataTable dt = null;
            strInfo = dal.ExecuteQuerySecurity(strSQL, paras, out dt);
            if (strInfo == "")
            {
                if (dt.Rows.Count > 0)
                {
                    string strImg = dt.Rows[0][0].ToString();
                    if (clsWXHelper.IsWxFaceImg(strImg))
                    {
                        //是微信头像
                        strImg = clsWXHelper.GetMiniFace(strImg);
                    }
                    else if (strImg.Length > 0)
                    {
                        strImg = clsConfig.GetConfigValue("OA_WebPath") + strImg;
                    }
                    string strSaler = strImg + "|" + dt.Rows[0][1].ToString() + "|" + dt.Rows[0][4].ToString() + "|" + dt.Rows[0][3].ToString() + "|" + dt.Rows[0][5].ToString();
                    strInfo = "Successed:" + strSaler;
                }
                else
                    strInfo = "";
            }
            else
                strInfo = "Error:" + strInfo;
        }
        return strInfo;
    }

    /// <summary>
    /// 分配专属导购
    /// </summary>
    /// <param name="customersID"></param>
    /// <param name="name"></param>
    /// <param name="salerID"></param>
    /// <param name="vipID"></param>
    /// <returns></returns>
    public string BindVIPSaler(string Storeid, string salerID,string opinion, string openid)
    {
        //clsWXHelper.DisBindVipOpinion enumDisBindVipOpinion = (clsWXHelper.DisBindVipOpinion)Enum.Parse(typeof(clsWXHelper.DisBindVipOpinion), opinion);
        string rtInfo =  clsWXHelper.FansBindStore(openid,Convert.ToInt32( Storeid),( clsWXHelper.DisBindVipOpinion)Convert.ToInt32(opinion)  ,Convert.ToInt32(salerID));
        //  clsJsonHelper rtjson = clsJsonHelper.CreateJsonHelper(errInfo);
        if (rtInfo.IndexOf("绑定成功")>=0)
        {
            return clsNetExecute.Successed;
        }
        else
        {
            return clsNetExecute.Error + rtInfo;
        }
        /*string strSQL = @"declare @bindID int;declare @hisID int;declare @CreateName varchar(20);
                        set @CreateName=(select Nickname from wx_t_OmniChannelUser where id=@CreateID);
                        if exists(select * from wx_t_VipSalerBind where vipid=@VipID or OpenID=(case when ISNULL(VipID,0)=0 then @OpenID end)) begin
                            if not exists(select * from wx_t_VipSalerBind where (vipid=@VipID or OpenID=(case when ISNULL(VipID,0)=0 then @OpenID end)) and salerid=@SalerID) begin
                                select top 1 @bindID=id from wx_t_VipSalerBind where vipid=@VipID or OpenID=(case when ISNULL(VipID,0)=0 then @OpenID end);
                                set @hisID=(select top 1 id from wx_t_VipSalerHistory 
                                    where BindID=@bindID and (vipid=@VipID or OpenID=(case when ISNULL(VipID,0)=0 then @OpenID end)) order by id desc);
                                update wx_t_VipSalerBind set salerid=@SalerID,CreateID=@CreateID,CreateTime=getdate(),CreateName=@CreateName, 
                                    OpenID=@OpenID where vipid=@VipID or OpenID=(case when ISNULL(VipID,0)=0 then @OpenID end);
                                update wx_t_VipSalerHistory set EndType=1,EndTime=getdate() 
                                    where id=@hisid and BindID=@bindID and (vipid=@VipID or OpenID=(case when ISNULL(VipID,0)=0 then @OpenID end));
                                INSERT INTO wx_t_VipSalerHistory(BindID,VipID,OpenID,SalerID,CreateID,CreateName,BeginType,BeginTime,EndType)
                                    VALUES(@bindID,@VipID,@OpenID,@SalerID,@CreateID,@CreateName,1,getdate(),1);
                            end
                        end else begin
                            INSERT INTO wx_t_VipSalerBind(VipID,OpenID,SalerID,CreateID,CreateTime,CreateName)
                            VALUES(@VipID,@OpenID,@SalerID,@CreateID,getdate(),@CreateName);
                            set @bindID=SCOPE_IDENTITY();
                            INSERT INTO wx_t_VipSalerHistory(BindID,VipID,OpenID,SalerID,CreateID,CreateName,BeginType,BeginTime,EndType)
                            VALUES(@bindID,@VipID,@OpenID,@SalerID,@CreateID,@CreateName,1,getdate(),1);
                        end";
        List<SqlParameter> paras = new List<SqlParameter>();
        paras.Add(new SqlParameter("@CreateID", CreateID));
        paras.Add(new SqlParameter("@VipID", vipID));
        paras.Add(new SqlParameter("@SalerID", salerID));
        paras.Add(new SqlParameter("@OpenID", openid));
        using (LiLanzDALForXLM dal = new LiLanzDALForXLM(WXconnStr))
        {
            errInfo = dal.ExecuteNonQuerySecurity(strSQL, paras);
            if (errInfo == "")
            {
                return clsNetExecute.Successed;
            }
            else
            {
                errInfo = "Error：" + errInfo;
                return errInfo;
            }
        }*/
    }

    //头像地址转换
    public void ConvertHeadimgURL(ref DataTable _dt)
    {
        string VIP_WebPath = clsConfig.GetConfigValue("VIP_WebPath");
        string OA_WebPath = clsConfig.GetConfigValue("OA_WebPath");
        if (_dt.Rows.Count > 0)
        {
            string url = "";
            for (int i = 0; i < _dt.Rows.Count; i++)
            {
                url = _dt.Rows[i]["wxheadimgurl"].ToString().Replace("\\", "");
                if (url == "")
                    url = "../../res/img/StoreSaler/defaulticon.jpg";
                else if (clsWXHelper.IsWxFaceImg(url))
                    url = clsWXHelper.GetMiniFace(url);
                else
                    url = VIP_WebPath + url;
                _dt.Rows[i]["wxheadimgurl"] = url;
            }
        }//end                       
    }

</script>
<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <title></title>
</head>
<body>
    <form id="form1" runat="server">
    <div>
    </div>
    </form>
</body>
</html>
