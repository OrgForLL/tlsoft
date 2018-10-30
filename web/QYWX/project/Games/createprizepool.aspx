<%@ Page Language="C#" %>
<%@ Import Namespace="nrWebClass" %>
<%@ Import Namespace="System.Data.SqlClient" %>
<%@ Import Namespace="System.Data" %>
<%@ Import Namespace="System.Collections.Generic" %>

<!DOCTYPE html>
<script runat="server">

    private static string WXDBConstr = "server='192.168.35.62';uid=sa;pwd=ll=8727;database=weChatPromotion";// "server='192.168.35.23';uid=lllogin;pwd=rw1894tla;database=tlsoft";// "server='192.168.35.62';uid=sa;pwd=ll=8727;database=weChatPromotion";
    protected void Page_Load(object sender, EventArgs e)
    {
        string ctrl = Convert.ToString(Request.Params["ctrl"]);
        string userid = Convert.ToString(Session["tk_userid"]);
        string allowIP = "192.168.35.33|127.0.0.1|192.168.35.15";
        if (allowIP.IndexOf(HttpContext.Current.Request.UserHostAddress) > -1 && ctrl == "createPrizePool")//内网访问投放奖品，允许不用鉴权
        {
            userid = "2";
        }
        else
        {
            clsSharedHelper.WriteErrorInfo("非法访问");
        }

        switch (ctrl)
        {
            case "createPrizePool":
                string mydate = Convert.ToString(Request.Params["GameTime"]);
                string gameid=Convert.ToString(Request.Params["gameid"]);
                string SSKey = Convert.ToString(Request.Params["SSKey"]);
                CreatePrizePool(mydate, gameid, SSKey);
                break;
            default:
                clsSharedHelper.WriteErrorInfo("请检查传入的CTRL是否有效！");
                break;
        }
    }
   
    //创建奖品池
    private void CreatePrizePool(string GTime,string gameid,string SSKey)
    {
        DateTime mydate;
        if (!DateTime.TryParse(GTime, out mydate))
        {
            clsSharedHelper.WriteErrorInfo("日期格式不合法！");
            return;
        }
        if (string.IsNullOrEmpty(gameid))
        {
            clsSharedHelper.WriteErrorInfo("gameid不合法！");
            return;
        }
        if (string.IsNullOrEmpty(SSKey))
        {
            clsSharedHelper.WriteErrorInfo("SSKey不合法！");
            return;
        }
        
        using (LiLanzDALForXLM dal = new LiLanzDALForXLM(WXDBConstr))
        {
            string str_sql = @" select a.* from wx_t_gameprize a where a.id<>0 and a.gameid=@gameid and a.sskey=@sskey and NumsPerDay>0;";
            DataTable dtTodayPrize = null;
            List<SqlParameter> para = new List<SqlParameter>();
            para.Add(new SqlParameter("@sskey", SSKey));
            para.Add(new SqlParameter("@gameid", gameid));
            string errinfo = dal.ExecuteQuerySecurity(str_sql, para, out dtTodayPrize);

            if (errinfo != "")
            {
                clsSharedHelper.WriteErrorInfo("生成奖品池数据查询数据失败 errInfo:" + errinfo);
                return;
            }
            else if (dtTodayPrize.Rows.Count < 1)
            {
                clsSharedHelper.WriteErrorInfo("还未配置奖品信息！" + gameid);
                return;
            }

            //生成算法调整将每个奖项平分到一天当中 
            int timeblock = 0, prizeNum = 0;

            string gametoken = "", activetime = "", prizeID = "";
            DateTime _time = Convert.ToDateTime(GTime);
            str_sql = "";

            int sqlblocks = 0;

            for (int i = 0; i < dtTodayPrize.Rows.Count; i++)
            {
                prizeNum = Convert.ToInt32(dtTodayPrize.Rows[i]["NumsPerDay"]);
                if (prizeNum <= 0) continue;
                prizeID = dtTodayPrize.Rows[i]["id"].ToString();
                timeblock = Convert.ToInt32(Math.Floor(Convert.ToDouble(24 * 60 * 60 / prizeNum)));
                int tcount = 0;

                for (int j = 0; j < prizeNum; j++)
                {
                    gametoken = System.Guid.NewGuid().ToString();
                    activetime = _time.AddSeconds(timeblock * tcount).ToString();
                    tcount++;

                    //利用字符串拼接去优化速度
                    str_sql = string.Concat(str_sql, string.Format(@"insert into wx_t_gamerecords(gameid,userid,gametoken,isconsume,prizeid,activetime,gametime,sskey) 
                    values ({0},0,'{1}',0,'{2}','{3}','{4}',{5});", gameid, gametoken, prizeID, activetime, GTime, SSKey));
                    sqlblocks++;
                    //每500条执行一次
                    if (sqlblocks >= 500)
                    {
                        errinfo = dal.ExecuteNonQuery(str_sql);
                        if (errinfo == "")
                        {
                            sqlblocks = 0;
                            str_sql = "";
                        }
                        else
                        {
                            clsSharedHelper.WriteErrorInfo("生成奖品【" + prizeID + "】池时出错 errinfo:" + errinfo);
                            break;
                        }
                    }
                }//end for j
            }//end for i

            if (str_sql != "")//有可能最后还有一部分SQL没执行
            {
                errinfo = dal.ExecuteNonQuery(str_sql);
                if (errinfo != "")
                    clsSharedHelper.WriteErrorInfo(errinfo);
            }
            clsSharedHelper.WriteSuccessedInfo("");
        }
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
