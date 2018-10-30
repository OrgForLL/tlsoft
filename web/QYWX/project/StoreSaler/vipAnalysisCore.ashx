<%@ WebHandler Language="C#" Class="VipAanysisCore" %>
using System;
using System.Web;
using nrWebClass;
using System.Data;
using System.Data.SqlClient;
using System.Collections.Generic;
using Newtonsoft.Json;

public class VipAanysisCore : IHttpHandler, System.Web.SessionState.IRequiresSessionState
{
    public void ProcessRequest(HttpContext context)
    {
        context.Response.ClearHeaders();
        context.Response.AppendHeader("Access-Control-Allow-Origin", "*");
        string requestHeaders = context.Request.Headers["Access-Control-Request-Headers"];
        context.Response.AppendHeader("Access-Control-Allow-Headers", string.IsNullOrEmpty(requestHeaders) ? "*" : requestHeaders);
        context.Response.AppendHeader("Access-Control-Allow-Methods", "POST, GET,OPTIONS");

        context.Response.ContentType = "text/plain";
        string ctrl = Convert.ToString(context.Request.Params["ctrl"]);
        string rt = "";
        DataSerach ds = new DataSerach();
        if (string.IsNullOrEmpty(ctrl)) ctrl = "";
        ctrl = ctrl.ToLower();
        //string khid = Convert.ToString(context.Session["tzid"]);        
        //khid = "1900";
        //if (string.IsNullOrEmpty(khid))
        //{
        //    clsSharedHelper.WriteErrorInfo("非法访问!无法获取您的身份;请刷新主页后再访问");
        //}
        switch (ctrl)
        {
            case "analysis":
                rt = ds.salesAnalysis(context);
                break;
            case "test":
                rt = ds.mytest();
                break;
            default:
                rt = JsonConvert.SerializeObject(new Response("无效请求"));
                break;
        }
        clsSharedHelper.WriteInfo(rt);
    }


    public bool IsReusable
    {
        get
        {
            return false;
        }
    }
}
#region 逻辑处理类
public class DataSerach
{
    private string CXDBConstr = clsConfig.GetConfigValue("FXDBConStr");
    public string mytest()
    {
        MdVIPSaleMode[] mvipArray = new MdVIPSaleMode[5];
        MdVIPSaleMode mvip;
        Random ran=new Random();
        for(int i = 0; i < 5; i++)
        {
            mvip = new MdVIPSaleMode();
            mvip.mdid = ran.Next(100, 9999);
            mvip.mdmc = "";
            mvip.myid = 1;
            mvip.mymc = "";
            mvip.newvips = 0;
            mvip.totalje = ran.Next(500, 10000);
            mvip.vipje =  ran.Next(10, 500);
            mvipArray[i] = mvip;
        }
        DataTable mydt = JsonConvert.DeserializeObject<DataTable>(JsonConvert.SerializeObject(mvipArray));
        string rt = JsonConvert.SerializeObject(mydt);

        SetOrder(ref mydt, "percentage", "desc");
        return string.Format("序列化前：{0}；序列化后：{1}",rt,JsonConvert.SerializeObject(mydt));
    }

    public string salesAnalysis(HttpContext context)
    {
        // string khid, mdmc, ksrq, jsrq, khfl, mdfl, sphh;
        string mdmc = Convert.ToString(context.Request.Params["mdmc"]);
        string ksrq = Convert.ToString(context.Request.Params["ksrq"]);
        string jsrq = Convert.ToString(context.Request.Params["jsrq"]);
        string khfl = Convert.ToString(context.Request.Params["khfl"]);
        string mdfl = Convert.ToString(context.Request.Params["mdfl"]);
        string khid = Convert.ToString(context.Request.Params["myid"]);
        string sphh = Convert.ToString(context.Request.Params["sphh"]);

        string colname = Convert.ToString(context.Request.Params["colname"]);
        string ordertype =  Convert.ToString(context.Request.Params["ordertype"]);

        string rt, filter = "", mysql;
        DateTime mydate;

        if (!DateTime.TryParse(ksrq, out mydate))
        {
            return JsonConvert.SerializeObject(new Response("非法日期1"));
        }
        if (!DateTime.TryParse(jsrq, out mydate))
        {
            return JsonConvert.SerializeObject(new Response("非法日期2"));
        }

        if (!string.IsNullOrEmpty(mdmc))
        {
            filter = string.Format(" and a.mdmc like '%{0}%'", mdmc);
        }

        if (!string.IsNullOrEmpty(khfl))
        {
            filter = string.Concat(filter, string.Format(" and c.khfl='{0}'", khfl));
        }
        if (!string.IsNullOrEmpty(mdfl))
        {
            filter = string.Concat(filter, string.Format(" and b.khfl='{0}'", mdfl));
        }

        int myid;
        if (string.IsNullOrEmpty(khid)== false && int.TryParse(khid,out myid))
        {
            filter = string.Concat(filter, string.Format(" and c.khid='{0}'", khid));
        }

        DataTable dt;
        List<SqlParameter> paras = new List<SqlParameter>();
        paras.Add(new SqlParameter("@ksrq", ksrq));
        paras.Add(new SqlParameter("@jsrq", jsrq));

        mysql =string.Format( @"SELECT a.mdid,a.mdmc,c.khid AS myid,c.khmc as mymc,SUM(CASE WHEN ISNULL(d.id,0)=0 THEN 0 ELSE 1 END) AS newvip,b.khdm
                FROM dbo.t_mdb a 
                INNER JOIN dbo.yx_t_khb b ON a.khid=b.khid 
                INNER JOIN dbo.yx_t_khb c ON dbo.split(b.ccid,'-',2)=c.khid 
                LEFT JOIN dbo.YX_T_Vipkh d ON a.mdid=d.mdid AND d.khid=b.khid AND d.tbrq>=@ksrq AND d.tbrq<DATEADD(DAY,1,@jsrq)
                WHERE a.ty=0 AND b.ty=0 AND c.khfl IN('xf','xd','xg','xk','xm') {0} GROUP BY a.mdid,a.mdmc,c.khid,c.khmc,b.khdm ",filter);
        using (LiLanzDALForXLM dal = new LiLanzDALForXLM(CXDBConstr))
        {
            string errInfo = dal.ExecuteQuerySecurity(mysql, paras, out dt);
            if (errInfo != "") return JsonConvert.SerializeObject(new Response(errInfo));
            RemoveMyData(ref dt);
            Dictionary<string, MdVIPSaleMode> dic_mdmode = new Dictionary<string, MdVIPSaleMode>();
            string mdid = "";
            MdVIPSaleMode mvm;
            //SetOrder(ref dt, colname, ordertype);
            foreach (DataRow dr in dt.Rows)
            {
                mdid = Convert.ToString(dr["mdid"]);
                mvm = new MdVIPSaleMode();
                mvm.mdid = Convert.ToInt32(mdid);
                mvm.mdmc = Convert.ToString(dr["mdmc"]);
                mvm.newvips = Convert.ToInt32(dr["newvip"]);
                if (string.IsNullOrEmpty(khid)) {//总部查询需要贸易公司信息
                    mvm.myid = Convert.ToInt32(dr["myid"]);
                    mvm.mymc = Convert.ToString(dr["mymc"]);
                }
                dic_mdmode.Add(mdid, mvm);
            }
            clsSharedHelper.DisponseDataTable(ref dt);
            if (dic_mdmode.Count < 1)
            {
                return JsonConvert.SerializeObject(new Response(new object[0]));
            }
            string[] mdidArray = new string[dic_mdmode.Count];
            dic_mdmode.Keys.CopyTo(mdidArray, 0);

            //计算门店销售金额
            filter = "";
            if (string.IsNullOrEmpty(sphh)== false)
            {
                filter = string.Format(" and sphh like '{0}%'",sphh);
            }
            mysql = string.Format(@"SELECT cast(SUM(d.je*abs(d.djlb)/d.djlb) as decimal(11,2)) AS totalje,cast(SUM(CASE WHEN d.vip<>'' THEN d.je*abs(d.djlb)/d.djlb ELSE 0 END) as decimal(11,2)) vipje,d.mdid
                                FROM  dbo.zmd_v_lsdjmx d
                                WHERE d.djbs=1 and d.rq>=@ksrq AND d.rq<dateadd(day,1,@jsrq) AND mdid IN({0}){1}
                                GROUP BY d.mdid", string.Join(",", mdidArray),filter);
            paras.Clear();
            paras.Add(new SqlParameter("@ksrq", ksrq));
            paras.Add(new SqlParameter("@jsrq", jsrq));
            errInfo = dal.ExecuteQuerySecurity(mysql, paras, out dt);
            if (errInfo != "") return JsonConvert.SerializeObject(new Response(errInfo));
            //SetOrder(ref dt, colname, ordertype); //新增排序
            foreach (DataRow dr in dt.Rows)
            {
                mdid = Convert.ToString(dr["mdid"]);
                dic_mdmode[mdid].totalje = Convert.ToDecimal(dr["totalje"]);
                dic_mdmode[mdid].vipje = Convert.ToDecimal(dr["vipje"]);
            }
            clsSharedHelper.DisponseDataTable(ref dt);  //注销并回收资源

            if (string.IsNullOrEmpty(khid))//总部查询的是贸易公司
            {
                Dictionary<string, MdVIPSaleMode> dic_mymode = new Dictionary<string, MdVIPSaleMode>();
                MdVIPSaleMode myMVSM;
                foreach (MdVIPSaleMode mvsm in dic_mdmode.Values)
                {
                    if (dic_mymode.ContainsKey(mvsm.myid.ToString()))
                    {
                        dic_mymode[mvsm.myid.ToString()].totalje += mvsm.totalje;
                        dic_mymode[mvsm.myid.ToString()].vipje += mvsm.vipje;
                        dic_mymode[mvsm.myid.ToString()].newvips += mvsm.newvips;
                    }
                    else
                    {
                        myMVSM = new MdVIPSaleMode();
                        myMVSM.mdid = mvsm.myid;
                        myMVSM.mdmc = mvsm.mymc;
                        myMVSM.totalje = mvsm.totalje;
                        myMVSM.vipje = mvsm.vipje;
                        myMVSM.newvips = mvsm.newvips;
                        dic_mymode.Add(mvsm.myid.ToString(), myMVSM);
                    }
                }
                dic_mdmode.Clear();
                dic_mdmode = dic_mymode;
            }
            MdVIPSaleMode[] mvsmArray = new MdVIPSaleMode[dic_mdmode.Count];
            dic_mdmode.Values.CopyTo(mvsmArray, 0);
            if (string.IsNullOrEmpty(colname) == false)//有排序转成datatable排序，无排序直接序列化
            {
                if (string.IsNullOrEmpty(ordertype)) ordertype = "asc";
                DataTable mydt = JsonConvert.DeserializeObject<DataTable>(JsonConvert.SerializeObject(mvsmArray));
                SetOrder(ref mydt, colname, ordertype);
                rt = JsonConvert.SerializeObject(new Response(mydt));
                clsSharedHelper.DisponseDataTable(ref mydt);
            }
            else
            {
                rt = JsonConvert.SerializeObject(new Response(mvsmArray));
            }
            dic_mdmode.Clear(); dic_mdmode = null;
            mvsmArray = null;
        }
        return rt;
    }

    //By:xlm .官部提出需求：要屏蔽 领航营销管理有限公司-综合帐套、领航营销管理有限公司(特卖专户)、内部结算(部门领用) 三个套帐的数据；参考PC存储的写法执行效率较低，因此考虑删除 khdm LIKE '0000__' 的数据即可
    private void RemoveMyData(ref DataTable dt)
    {
        if (dt.Columns.Contains("khdm") == false) return;
        int j = dt.Rows.Count;
        for (int i = j - 1; i > -1; i--)
        {
            if (Convert.ToString(dt.Rows[i]["khdm"]).StartsWith("0000"))
            {
                dt.Rows.RemoveAt(i);
            }
        }
    }

    private void SetOrder(ref DataTable dt, string order_colName, string order_direc)
    {
        //排序  
        //clsLocalLoger.WriteInfo("1:" + order_colName);
        if (string.IsNullOrEmpty(order_colName) == false)
        {
            //clsLocalLoger.WriteInfo("2:" + order_colName);
            if (dt.Columns.Contains(order_colName) == false) return;

            //clsLocalLoger.WriteInfo("3:" + order_colName);
            DataView dv = dt.DefaultView;
            dv.Sort = string.Concat(order_colName, " ", order_direc);

            DataTable dt2 = dv.ToTable();
            dt.Clear(); dt.Dispose();

            dt = dt2;
        }
    }
}
#endregion
#region 实体类
public class MdVIPSaleMode
{
    int _mdid;
    public int mdid
    {
        get { return _mdid; }
        set { _mdid = value; }
    }
    string _mdmc;
    public string mdmc
    {
        get { return _mdmc; }
        set { _mdmc = value; }
    }
    int _myid;
    public int myid
    {
        get { return _myid; }
        set { _myid = value; }
    }
    string _mymc;
    public string mymc
    {
        get { if (_mymc == null) _mymc = "";
            return _mymc; }
        set { _mymc = value; }
    }
    int _newvip;
    public int newvips
    {
        get { return _newvip; }
        set { _newvip = value; }
    }
    decimal _totalje;
    public decimal totalje
    {
        get { return _totalje; }
        set { _totalje = value; }
    }
    decimal _vipje;
    public decimal vipje
    {
        get { return _vipje; }
        set { _vipje = value; }
    }
    public decimal percentage
    {
        get
        {
            if (_totalje == 0) return 0;
            else return Math.Round((_vipje / _totalje)*100, 2) ;
        }
    }
}

#endregion
#region 基础类
public class Response
{
    public Response() { }
    public Response(object obj)
    {
        _code = "200";
        _info = obj;
    }
    public Response(string errmsg)
    {
        this._code = "201";
        this._msg = errmsg;
    }
    string _code;
    public string code
    {
        get
        {
            if (string.IsNullOrEmpty(_code)) _code = "201";
            return _code;
        }
        set
        {
            _code = value;
        }
    }
    object _info;
    public object info
    {
        get { return _info == null ? "" : _info; }
        set { _info = value; }
    }
    string _msg;
    public string msg
    {
        get
        {
            if (string.IsNullOrEmpty(_msg)) _msg = "";
            return _msg;
        }
        set
        {
            _msg = value;
        }
    }
}
#endregion
