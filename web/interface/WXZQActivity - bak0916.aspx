<%@ Page Language="C#" %>
<%@ Import Namespace="nrWebClass" %>
<%@ Import Namespace="System.Data.SqlClient" %>
<%@ Import Namespace="System.Data" %>
<%@ Import Namespace="System.Collections.Generic" %>
<!DOCTYPE html>
<script runat="server">
    private static DataTable _CakeDT = null;
    public static String connStr = "server=192.168.35.62;database=weChatPromotion;uid=lqf;pwd=liqf,123";
    public String userid = "";
    
    private static DataTable CakeDT() {
        if (_CakeDT == null) {
            using (LiLanzDALForXLM dal = new LiLanzDALForXLM(connStr)) {
                string sql = "select * from zq_t_cakeconfig order by probability desc;";
                string errInfo = dal.ExecuteQuery(sql, out _CakeDT);
            }
        }

        return _CakeDT;
    }
    
    protected void Page_Load(object sender, EventArgs e)
    {        
        string ctrl = Convert.ToString(Request.Params["ctrl"]);
        //userid = Convert.ToString(Session["vipid"]);
        userid = "2";
        //除了保存提交的游戏数据函数其它的都需要判断SESSION
        switch (ctrl)
        {
            case "CakeOrders":
                GenarateCakeOrders();
                break;
            case "RankList":
                GetRankList();
                break;
            case "SaveGameData":

                break;
            case "SaveUserInfo":

                break;
            default:
                clsSharedHelper.WriteErrorInfo("无效的控制参数！ctrl:" + ctrl);
                break;                
        }                
    }

    private void GenarateCakeOrders() {
        if (userid == "" || userid == null)
            clsSharedHelper.WriteErrorInfo("系统超时，请重新登录！");
        else {
            String cakeOrders = "",strGUID="";
            using (LiLanzDALForXLM dal = new LiLanzDALForXLM(connStr))
            {
                string sql = "select id,cakeno,cakename,cakescore,probability from zq_t_cakeconfig order by probability desc;";
                DataTable dt = null;
                string errInfo = dal.ExecuteQuery(sql, out dt);
                if (errInfo == "")
                {
                    if (dt.Rows.Count > 0)
                    {
                        dt.Columns.Add("startSec", typeof(int));
                        dt.Columns.Add("endSec", typeof(int));
                        dt.Columns.Add("times", typeof(int));

                        //处理DATATABLE构造每种月饼的区间范围                    
                        for (int i = 0; i < dt.Rows.Count; i++)
                        {
                            if (i == 0)
                            {
                                dt.Rows[i]["startSec"] = 0;
                                dt.Rows[i]["endSec"] = dt.Rows[i]["probability"];
                            }
                            else
                            {
                                dt.Rows[i]["startSec"] = dt.Rows[i - 1]["endSec"];
                                dt.Rows[i]["endSec"] = Convert.ToInt32(dt.Rows[i]["probability"]) + Convert.ToInt32(dt.Rows[i]["startSec"]);
                            }

                            dt.Rows[i]["times"] = 0;
                        }
                        int sumb = Convert.ToInt32(dt.Rows[dt.Rows.Count - 1]["endSec"]);

                        printDataTable(dt);

                        Random rd = new Random();
                        for (int i = 0; i < 100; i++)
                        {
                            //System.Threading.Thread.Sleep(10);
                            int val = rd.Next(sumb);
                            DataRow[] drList = dt.Select("startSec<=" + val + " and " + val + "<endSec", "");
                            if (drList.Length > 0)
                            {
                                cakeOrders += Convert.ToString(drList[0]["cakeno"]) + ",";
                                int drIndex = dt.Rows.IndexOf(drList[0]);
                                dt.Rows[drIndex]["times"] = Convert.ToInt32(dt.Rows[drIndex]["times"]) + 1;
                            }
                        }
                        if (cakeOrders != "") {
                            cakeOrders = cakeOrders.Substring(0, cakeOrders.Length - 1);
                            //生成一个GUID
                            strGUID = System.Guid.NewGuid().ToString();
                            //先保存部分游戏信息
                            sql = @"insert into zq_t_gamescore(userid,gametoken,cakelist,starttime) values(@userid,@token,@orders,getdate());";
                            List<SqlParameter> paras = new List<SqlParameter>();
                            paras.Add(new SqlParameter("@userid", userid));
                            paras.Add(new SqlParameter("@token", strGUID));
                            paras.Add(new SqlParameter("@orders", cakeOrders));
                            errInfo = dal.ExecuteNonQuerySecurity(sql,paras);
                            if(errInfo=="")
                                clsSharedHelper.WriteInfo(strGUID + "|" + cakeOrders);
                            else
                                clsSharedHelper.WriteErrorInfo("预保存用户游戏数据失败！");
                        }                        

                        //Response.Write(cakeOrders);
                        //Response.Write("<br />");
                        //printDataTable(dt);

                        //算总分
                        //int sumScore = 0;
                        //for (int i = 0; i < dt.Rows.Count; i++)
                        //{
                        //    sumScore += Convert.ToInt32(dt.Rows[i]["cakescore"]) * Convert.ToInt32(dt.Rows[i]["times"]);
                        //}
                        //Response.Write("<br />总分：" + sumScore.ToString());
                    }
                    else
                        clsSharedHelper.WriteErrorInfo("请配置月饼相关信息！");
                }
                else
                    clsSharedHelper.WriteErrorInfo(errInfo);
            }
        }
    }

    //获取排行数据
    public void GetRankList() {
        if (userid == "" || userid == null)
        {
            clsSharedHelper.WriteErrorInfo("系统超时，请重新登录！");
        }
        else {
            using (LiLanzDALForXLM dal = new LiLanzDALForXLM(connStr))
            {
                string str_sql = @"select top 100 row_number() over(order by a.score desc) xh,b.wxnick,b.wxheadimgurl,a.score 
                                from zq_t_gamescore a
                                inner join wx_t_vipbinging b on a.userid=b.id
                                order by a.score desc ";
                DataTable dt = null;
                string errInfo = dal.ExecuteQuery(str_sql, out dt);
                if (errInfo == "")
                {
                    if (dt.Rows.Count > 0)
                    {
                        string jsonData = JsonHelp.dataset2json(dt);
                        clsSharedHelper.WriteInfo(jsonData);
                    }
                    else
                    {
                        clsSharedHelper.WriteErrorInfo("无排行数据！");
                    }
                }
                else
                    clsSharedHelper.WriteErrorInfo(errInfo);
            }
        }
    }
    
    public void printDataTable(DataTable dt) {
        string printStr = "";
        if (dt.Rows.Count > 0) {
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
