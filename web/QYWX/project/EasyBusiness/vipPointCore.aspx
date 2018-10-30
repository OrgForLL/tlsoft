g<%@ Page Language="C#" Debug="true"  ResponseEncoding="utf-8" %>
<%@ Import Namespace="nrWebClass"  %>
<%@ Import Namespace="System.Collections.Generic" %>
<%@ Import Namespace="System.Data.SqlClient" %>
<%@ Import Namespace="System.Data" %>

<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">

<script runat="server">
    private string constr = clsConfig.GetConfigValue("OAConnStr");
    string rtmsg = "";
    string khid = "1", mdid = "1";//互联网中心的khid与mdid
    protected void Page_Load(object sender, EventArgs e)
    {
      //  SetTestMode();  //设置为测试模式，将数据查询只想到正式的数据库

        rtmsg = @"{{""code"":""{0}"",""info"":{1},""errmsg"":""{2}""}}";
        string ctrl = Convert.ToString(Request.Params["ctrl"]);
        string rt = "", vipid, wxopenid;
        switch (ctrl)
        {
            case "search":
                wxopenid = Convert.ToString(Request.Params["wxopenid"]);
                vipid = getVipid(wxopenid);
                if (vipid.IndexOf(clsNetExecute.Successed) >= 0)
                {
                    vipid = vipid.Replace(clsNetExecute.Successed, "");
                    pointSearch(vipid);
                }
                else
                    rt = string.Format(rtmsg,"500","",vipid);
                break;
            case "exchange":
                string points = Convert.ToString(Request.Params["points"]);
                wxopenid = Convert.ToString(Request.Params["wxopenid"]);
                vipid = getVipid(wxopenid);
                if (vipid.IndexOf(clsNetExecute.Successed) >= 0)
                {
                    vipid = vipid.Replace(clsNetExecute.Successed, "");
                    exchangePoints(vipid, points);
                }
                else
                    rt = string.Format(rtmsg,"500","",vipid);
                break;
            case "asynprocess":
                string ID = Convert.ToString(Request.Params["id"]);
                asynProcess(ID);
                break;
            case "getnewvipmd": getNewVipMD(); break;
            default: rt = string.Format(rtmsg, "500", "\"\"", "ctrl参数有误,请核对后再访问！"); break;
        }
        if (rt != "")
        {
            clsSharedHelper.WriteInfo(rt);
        }
    }
    private void getNewVipMD()
    {
        string errInfo, mysql,rt="";
        mysql = @"SELECT b.mdid,b.mddm+'.'+ b.mdmc AS mdmc,ISNULL(b.lxdh,'') lxdh,ISNULL(D.addressInfo,'-') addressInfo
                  FROM yx_t_khb a 
	              INNER JOIN dbo.t_mdb b ON a.khid=b.khid 
	              LEFT JOIN yx_t_jmspb C ON B.mdid = C.mdid
	              LEFT JOIN wx_t_StorePointLocation D ON D.mapType = 'jm' AND D.mapID = C.ID	
                  WHERE Vipbs LIKE 'new%' AND A.ty = 0 AND B.ty = 0";
        DataTable dt;
        using (LiLanzDALForXLM dal = new LiLanzDALForXLM(constr))
        {
            errInfo = dal.ExecuteQuery(mysql, out dt);
            if (errInfo != "")
            {
                clsSharedHelper.WriteInfo(string.Format(rtmsg, "500", "\"\"", errInfo));
                return;
            }
            rt = dal.DataTableToJson(dt);
            clsSharedHelper.DisponseDataTable(ref dt);
            rt = rt.TrimStart('{').TrimEnd('}');
            rt = rt.Replace("\"list\":","");
            clsSharedHelper.WriteInfo(string.Format(rtmsg,"200",rt,""));
        }
    }

    private string getVipid(string wxopenid)
    {
        string rt, mysql, errInfo;
        if (string.IsNullOrEmpty(wxopenid))
            return clsNetExecute.Error + "wxopenid不能为空!";
        
        DataTable dt;
        mysql = "SELECT TOP 100 ISNULL(a.vipID,0) vipid FROM dbo.wx_t_vipBinging a WHERE a.wxOpenid =@wxopenid AND a.ObjectID IN(1,4)";
        using (LiLanzDALForXLM dal = new LiLanzDALForXLM(constr))
        {
            List<SqlParameter> paras = new List<SqlParameter>();
            paras.Add(new SqlParameter("@wxopenid", wxopenid));
            errInfo = dal.ExecuteQuerySecurity(mysql, paras, out dt);
            if (errInfo != "")
            {
                rt=errInfo;
            }
            else if (dt.Rows.Count < 1 || Convert.ToInt32(dt.Rows[0]["vipid"]) <= 0)
            {
                rt = clsNetExecute.Error + "您还未注册vip";
            }
            else
            {
                rt = clsNetExecute.Successed + dt.Rows[0]["vipid"].ToString();
            }
            clsSharedHelper.DisponseDataTable(ref dt);
        }
        return rt;
    }
    
    private void pointSearch(string vipid)
    {
        string rt = @"{{""points"":""{0}"",""vipid"":""{1}""}}";
        
        if (string.IsNullOrEmpty(vipid))
        {
            clsSharedHelper.WriteInfo(string.Format(rtmsg, "500", "\"\"", "未能正确找到用户数据！"));
            return;
        }
        
        string mysql,errInfo;
        DataTable dt;
       
        mysql = string.Format("SELECT isnull(khid,0) khid,id FROM dbo.YX_T_Vipkh WHERE id={0}", vipid);
        using (LiLanzDALForXLM dal = new LiLanzDALForXLM(constr))
        {
            errInfo = dal.ExecuteQuery(mysql, out dt);
            if (errInfo != "")
            {
                clsSharedHelper.WriteInfo(string.Format(rtmsg, "500", "\"\"", errInfo));
                return;
            }
            
            if (dt.Rows.Count < 1)
            {
                clsSharedHelper.WriteInfo(string.Format(rtmsg, "500", "\"\"", "无效卡号,请检查后再试！"));
                return;
            }
            
            if(Convert.ToInt32(dt.Rows[0]["khid"])< 1)
            {
                //clsSharedHelper.WriteInfo(string.Format(rtmsg, "500", "\"\"", "vip未绑定客户,请绑定后使用"));
                //未绑定客户不可能有积分，直接返回0
                clsSharedHelper.WriteInfo(string.Format(rtmsg, "200", string.Format(rt, "0", vipid), ""));
                return;
            }
            
            string ckhid = dt.Rows[0]["khid"].ToString();
            clsSharedHelper.DisponseDataTable(ref dt);

            mysql = string.Format("SELECT top 1 khid FROM yx_T_khb WHERE vipbs LIKE 'new%' and khid={0}", ckhid);
            errInfo = dal.ExecuteQuery(mysql,out dt);
            if (errInfo != "")
            {
                clsSharedHelper.WriteInfo(string.Format(rtmsg, "500", "\"\"", errInfo));
                return;
            }
            if (dt.Rows.Count < 1)
            {
                clsSharedHelper.WriteInfo(string.Format(rtmsg, "501", "\"\"", "客户未加入新积分体系,不能使用此功能"));
                return;
            }
            clsSharedHelper.DisponseDataTable(ref dt);

            mysql = string.Format("SELECT TOP 100 ISNULL(points,0) AS points  FROM yx_V_VipPoints WHERE vipid={0} AND khid={1}", vipid, ckhid);
            errInfo = dal.ExecuteQuery(mysql, out dt);
            if (errInfo != "")
            {
                clsSharedHelper.WriteInfo(string.Format(rtmsg, "500", "\"\"", errInfo));
            }
            else if (dt.Rows.Count < 1)
            {
                clsSharedHelper.WriteInfo(string.Format(rtmsg, "500", "\"\"", "未找到vip客户的新积分"));
            }
            else
            {
                string points=Convert.ToString(dt.Rows[0]["points"]);
                clsSharedHelper.DisponseDataTable(ref dt);
                clsSharedHelper.WriteInfo(string.Format(rtmsg, "200", string.Format(rt,points,vipid),""));
            }
        }//end using
    }

    private void exchangePoints(string vipid,string pointsStr)
    {
        if (khid == "0")
        {
            clsSharedHelper.WriteInfo(string.Format(rtmsg, "500", "\"\"", "积分尚未准备就绪,khid?"));
            return;
        }
        
        if (string.IsNullOrEmpty(vipid))
        {
            clsSharedHelper.WriteInfo(string.Format(rtmsg,"500","\"\"","请提供有效vipid"));
            return;
        }

        int points;
        if (! Int32.TryParse(pointsStr,out points))
        {
            clsSharedHelper.WriteInfo(string.Format(rtmsg, "500", "\"\"", "请提供有效的兑换积分数"));
            return;
        }

        string errInfo, mysql;
        DataTable dt;
        List<SqlParameter> paras = new List<SqlParameter>();
        using (LiLanzDALForXLM dal = new LiLanzDALForXLM(constr))
        {
            mysql = "SELECT ISNULL(b.Vipbs,'') vipbs FROM yx_T_vipkh a LEFT JOIN yx_t_khb b ON a.khid=b.khid WHERE  a.id=@vipid";
            paras.Add(new SqlParameter("@vipid", vipid));
            errInfo = dal.ExecuteQuerySecurity(mysql, paras, out dt);
            if (errInfo != "")
            {
                clsSharedHelper.WriteInfo(string.Format(rtmsg, "500", "\"\"", errInfo));
                return;
            }
            if (dt.Rows.Count < 1)
            {
                clsSharedHelper.WriteInfo(string.Format(rtmsg, "500", "\"\"", "vip不存在"));
                return;
            }
            if (!dt.Rows[0]["vipbs"].ToString().Contains("new"))
            {
                clsSharedHelper.WriteInfo(string.Format(rtmsg, "501", "\"\"", "客户未加入新积分体系,不能使用此功能"));
                return;
            }
            
            mysql = "SELECT TOP 1 vipid,kh FROM yx_V_VipPoints WHERE vipid=@vipid AND points>=@points AND khid>0";
            paras.Clear();
            paras.Add(new SqlParameter("@vipid", vipid));
            paras.Add(new SqlParameter("@points", points));
            
            errInfo = dal.ExecuteQuerySecurity(mysql, paras, out dt);
            if (errInfo != "")
            {
                clsSharedHelper.WriteInfo(string.Format(rtmsg, "500", "\"\"", errInfo));
                return;
            }
            
            if (dt.Rows.Count < 1)
            {
                clsSharedHelper.WriteInfo(string.Format(rtmsg, "500", "\"\"", "vip不存在或积分不足"));
                return;
            }
            string kh = Convert.ToString(dt.Rows[0]["kh"]);
            clsSharedHelper.DisponseDataTable(ref dt);

            mysql = @"UPDATE yx_V_VipPoints SET points = ISNULL(points,0) + @points WHERE vipid = @vipid;
                      
                      INSERT INTO zmd_t_xfjfdhb(khid,kh,dhjfs,dhlp,yyy,rq,bz,jflx,mdid,fh,xtlx,djbs,zdrq,zdr,AsynRunStatus) 
                      SELECT @khid,a.kh,@points,'商城积分兑换','系统兑换',CONVERT(VARCHAR(100),GETDATE(),120),'',1,@mdid,-1,1,1,GETDATE(),'系统',3
                      FROM yx_V_VipPoints a 
                      WHERE a.vipid=@vipid; 

                      INSERT INTO zmd_t_jfjlb(lyid,khid,mdid,vipid,kh,jfs,rq,zdrq,bz,djbs,jflx,lylx,fh)
                      VALUES(@@IDENTITY,@khid,@mdid,@vipid,@kh,@points,GETDATE(),GETDATE(),'',1,1,174,-1);";
            paras.Clear();
            paras.Add(new SqlParameter("@khid", khid));
            paras.Add(new SqlParameter("@mdid", mdid));
            paras.Add(new SqlParameter("@points", "-" + points));
            paras.Add(new SqlParameter("@vipid", vipid));
            paras.Add(new SqlParameter("@kh", kh));

            errInfo = dal.ExecuteNonQuerySecurity(mysql, paras);
            if (errInfo != "")
            {
                clsSharedHelper.WriteInfo(string.Format(rtmsg, "500", "\"\"", errInfo));
            }
            else//成功插入后要发送异步处理
            {
                //string ID = Convert.ToString(dt.Rows[0][0]);
                //string rtInfo=  submitAsyn(ID);
                //if (rtInfo.IndexOf(clsNetExecute.Error) >= 0)
                //    clsLocalLoger.Log("[积分商城]订单积分处理失败：" + rtInfo);
                
               clsSharedHelper.WriteInfo(string.Format(rtmsg, "200", "\"兑换成功\"", ""));
            }
        }//end using
    }
    private string submitAsyn(string ID )
    {
        int sourceID;
        if (!Int32.TryParse(ID, out sourceID))
        {
            return clsNetExecute.Error + "非法ID,包含非数值";
        }
        
        string TaskCode = "VipJfdhServer", json = "";
        string strInfo = clsAsynTask.Submit(TaskCode, sourceID, json);
        if (strInfo.IndexOf(clsNetExecute.Error) >= 0)//发送错误发送微信通知
        {
            clsWXHelper.SendQYMessage("8DFFEECA-4237-47F1-BCBB-EA8E32D05F7D", 0, "[积分商城]订单积分处理失败：" + strInfo + ";积分兑换ID=" + sourceID);
            clsWXHelper.SendQYMessage("xuelm", 0, "[积分商城]订单积分处理失败：" + strInfo + ";积分兑换ID=" + sourceID);
            return strInfo;
        }
        return clsNetExecute.Successed;
    }
    
    private void asynProcess(string ID)
    {
       string rtInfo = submitAsyn(ID);
       if (rtInfo.IndexOf(clsNetExecute.Successed) >= 0)
           clsSharedHelper.WriteInfo(string.Format(rtmsg, "200", "\"提交成功\"", ""));
       else
       {
           clsLocalLoger.Log("[积分商城]订单积分处理失败：" + rtInfo);
           clsSharedHelper.WriteInfo(string.Format(rtmsg, "500", "\"\"", "提交失败"));
       }
    }

    private void SetTestMode()
    {
        constr = "server=192.168.35.10;uid=ABEASD14AD;pwd=+AuDkDew;database=tlsoft";
    }
</script>

<html xmlns="http://www.w3.org/1999/xhtml">
<head id="Head1" runat="server">
<title></title>
</head>
 <body>

 </body>
</html>
