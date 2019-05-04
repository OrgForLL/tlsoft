 <%@ WebService Language="C#" Class="WSZXDDataPull" %>

using System;
using System.Collections;
using System.ComponentModel;
using System.Data;
using System.Diagnostics;
using System.Web;
using System.Web.Services;
using nrWebClass;
using System.IO;
using Newtonsoft.Json;
using Newtonsoft.Json.Converters;
using System.Text;
using System.Xml;
using System.Xml.Serialization;
using System.Collections.Generic;
using System.Data.SqlClient;


[WebService(Namespace = "http://tempuri.org/")]
[WebServiceBinding(ConformsTo = WsiProfiles.BasicProfile1_1)]
//若要允许使用 ASP.NET AJAX 从脚本中调用此 Web 服务，请取消对下行的注释。 12
// [System.Web.Script.Services.ScriptService]
public class WSZXDDataPull : System.Web.Services.WebService
{
    private string connStr = "";
    public WSZXDDataPull()
    {
        connStr = clsConfig.GetConfigValue("OAConnStr");
        //connStr = "server='192.168.35.10';uid=ABEASD14AD;pwd=+AuDkDew;database=tlsoft";
    }


    [WebMethod(Description = "保存数据")]
    public string saveData(string objStr, string username, string tzid, string[] tmArray, string[] xmArray, string tmDict)
    {
        Dictionary<string, List<Dictionary<string, string>>> tmdata = JsonConvert.DeserializeObject<Dictionary<string, List<Dictionary<string, string>>>>(tmDict);
        List<Dictionary<string, string>> tmll = new List<Dictionary<string, string>>();

        Result rst = new Result();
        DataTable tmdt = new DataTable();
        DataColumn dc = null;
        dc = tmdt.Columns.Add("gzh", Type.GetType("System.String"));
        dc = tmdt.Columns.Add("chdm", Type.GetType("System.String"));
        dc = tmdt.Columns.Add("ckid", Type.GetType("System.Int32"));
        dc = tmdt.Columns.Add("tzid", Type.GetType("System.Int32"));
        dc = tmdt.Columns.Add("tm", Type.GetType("System.String"));
        dc = tmdt.Columns.Add("sl", Type.GetType("System.Single"));
        dc = tmdt.Columns.Add("cw", Type.GetType("System.String"));


        string rtMsg = "";
        //string sql = " ";
        StringBuilder sb = new StringBuilder();
        DataTable tmdtcw = new DataTable();
        DataTable xmdtcw = new DataTable();
        if (username == "")
            rtMsg = "error:当前用户名为空！";
        else if (tzid == "")
            rtMsg = "error:tzid参数为空！";
        else
        {
            ZXDData obj = XmlDeSerialize<ZXDData>(objStr);
            string str_sql = "SET XACT_ABORT ON ;BEGIN TRAN ";
            str_sql += " declare @zxid int;declare @zxh varchar(50);declare @zpc varchar(50);declare @id int; ";
            str_sql += " select @zpc=right(convert(varchar(8),getdate(),112),6)+'_" + obj.khdm + "_" + obj.pc + "';";
            str_sql += " declare @maxdjh varchar(6);set @maxdjh='001';";
            str_sql += " select top 1  @maxdjh=right('000'+cast(cast(right(a.zxxh,3) as int)+1 as varchar),3) from cl_t_wlzxd a ";
            str_sql += " where a.tzid=1 and a.zxpc=@zpc order by a.zxxh desc;set @zxh=@zpc+'_'+@maxdjh;";
            #region
            if (obj.mxTable.Rows.Count > 0)
            {
                string isxj = "0";
                isxj = tzid == "1" ? "0" : "1";
                List<string> zxList = new List<string>();
                for (int i = 0; i < obj.mxTable.Rows.Count; i++)
                {
                    if (obj.mxTable.Rows[i]["xlsl"].ToString() == "")
                        continue;
                    else if (Convert.ToDouble(obj.mxTable.Rows[i]["xlsl"]) == 0)
                        continue;
                    //str_sql += " insert into cl_t_wlzxd(tzid,zxxh,lyid,lymxid,sl,zdrq,zdr,bz,zxpc,xzl,zbz,isxj) values ";
                    zxList.Add(" select @tzid,@zxh,'" + obj.mxTable.Rows[i]["id"].ToString() + "','" + obj.mxTable.Rows[i]["mxid"].ToString() + "','" + obj.mxTable.Rows[i]["xlsl"].ToString() + "',getdate(),@username,'" + obj.mxTable.Rows[i]["zxbz"].ToString() + "',@zpc,'" + obj.xzl + "','" + obj.bz + "','" + isxj + "' ");
                    //str_sql += " (@tzid,@zxh,'" + obj.mxTable.Rows[i]["id"].ToString() + "','" + obj.mxTable.Rows[i]["mxid"].ToString() + "','" + obj.mxTable.Rows[i]["xlsl"].ToString() + "'";
                    //str_sql += ",getdate(),@username,'" + obj.mxTable.Rows[i]["zxbz"].ToString() + "',@zpc,'" + obj.xzl + "','" + obj.bz + "','" + isxj + "');";
                }
                str_sql+="insert into cl_t_wlzxd(tzid,zxxh,lyid,lymxid,sl,zdrq,zdr,bz,zxpc,xzl,zbz,isxj)"+string.Join(" union all ", zxList.ToArray());
                //处理条码               
                if (tmArray.Length > 0)
                {
                    str_sql += "select a.sm into #tmtmp from (";
                    for (int i = 0; i < tmArray.Length; i++)
                    {
                        tmll = tmdata[tmArray[i]];
                        foreach (Dictionary<string, string> ff in tmll)
                        {
                            DataRow dr = tmdt.NewRow();
                            dr["gzh"] = ff["scddbh"].ToString();
                            dr["chdm"] = ff["chdm"].ToString();
                            dr["ckid"] = ff["ckid"].ToString();
                            dr["sl"] = ff["sl"].ToString();
                            dr["tzid"] = tzid;
                            dr["tm"] = tmArray[i];
                            tmdt.Rows.Add(dr);
                        }
                        if (i == tmArray.Length - 1)
                            str_sql += "select '" + tmArray[i] + "' sm) a ";
                        else
                            str_sql += "select '" + tmArray[i] + "' sm union all ";
                    }
                    rst = getPDAkc(tmdt);
                    if (rst.Errcode > 0)
                        return rst.Errmsg;
                    else
                    {

                        //tmdtcw = DeserializeDataTable(rst.Data.ToString());
                        tmdtcw = (DataTable)rst.Data;

                        //foreach (DataRow dr in tmdtcw.Select())
                        //{
                        //    sql += " insert into cl_t_pdakcdj (djlx, tm, gzh, sl, tzid, zdr, zdrq, chdm, shbs, qrbs, djbs, rq, ckid, cw )";
                        //    sql += " values (2462,'" + dr["tm"].ToString() + "','" + dr["gzh"].ToString() + "','" + dr["sl"].ToString() + "'," + tzid + ",'" + username + "',getdate(),'" + dr["chdm"].ToString() + "',1,1,1,getdate(),'" + dr["ckid"].ToString() + "','" + dr["cw"].ToString() + "')";
                        //    sql += " SET @id=SCOPE_IDENTITY(); set @ids=@ids+','+cast(@id as varchar); ";
                        //}
                        //sql += "set @ids=SUBSTRING(@ids,2,LEN(@ids)); exec pda_kc_kchz @ids,'sl-',0; ";
                    }
                    str_sql += " update a set a.zxxh=@zxh,a.syzt=1 from cl_t_wltmb a inner join #tmtmp b on a.tm=b.sm;";
                    str_sql += " insert cl_t_wlsmjlb(tzid,sm,zxxh,smlb) select @tzid,a.sm,@zxh,'tm' from #tmtmp a ;drop table #tmtmp;";
                }
                //处理箱码
                if (xmArray.Length > 0)
                {
                    for (int i = 0; i < xmArray.Length; i++)
                    {
                        tmll = tmdata[xmArray[i]];
                        str_sql += " insert into cl_t_wlsmjlb(tzid,sm,zxxh,smlb) values (@tzid,'" + xmArray[i] + "',@zxh,'xh');";
                        foreach (Dictionary<string, string> ff in tmll)
                        {
                            DataRow dr = tmdt.NewRow();
                            dr["gzh"] = ff["scddbh"].ToString();
                            dr["chdm"] = ff["chdm"].ToString();
                            dr["ckid"] = ff["ckid"].ToString();
                            dr["sl"] = ff["sl"].ToString();
                            dr["tzid"] = tzid;
                            dr["tm"] = xmArray[i];
                            tmdt.Rows.Add(dr);
                        }
                    }
                    rst = getPDAkc(tmdt);
                    if (rst.Errcode > 0)
                        return rst.Errmsg;
                    else
                    {
                        xmdtcw = (DataTable)rst.Data;
                        //StringBuilder tmdtcwSb = new StringBuilder();
                        //foreach (DataRow dr in xmdtcw.Select())
                        //{
                        //    tmdtcwSb.Append( " insert into cl_t_pdakcdj (djlx, tm, gzh, sl, tzid, zdr, zdrq, chdm, shbs, qrbs, djbs, rq, ckid, cw )");
                        //    tmdtcwSb.Append( " values (2462,'" + dr["tm"].ToString() + "','" + dr["gzh"].ToString() + "','" + dr["sl"].ToString() + "'," + tzid + ",'" + username + "',getdate(),'" + dr["chdm"].ToString() + "',1,1,1,getdate(),'" + dr["ckid"].ToString() + "','" + dr["cw"].ToString() + "')");
                        //    tmdtcwSb.Append( " SET @id=SCOPE_IDENTITY(); set @ids=@ids+','+cast(@id as varchar); ");
                        //}
                        //writeLog( "cc:" +DateTime.Now.ToString());
                        //sql += "set @ids=SUBSTRING(@ids,2,LEN(@ids)); exec pda_kc_kchz @ids,'sl-',0; ";
                    }
                }

                tmdtcw.Merge(xmdtcw);

                //StringBuilder tmdtcwSb = new StringBuilder();
                List<string> tmdtcwList = new List<string>();
                foreach (DataRow dr in tmdtcw.Rows)
                {
                    //tmdtcwSb.Append(" insert into cl_t_pdakcdj (djlx, tm, gzh, sl, tzid, zdr, zdrq, chdm, shbs, qrbs, djbs, rq, ckid, cw )");

                    tmdtcwList.Add(" select 2462,'" + dr["tm"].ToString() + "','" + dr["gzh"].ToString() + "','" + dr["sl"].ToString() + "'," + tzid + ",'" + username + "',@getdate,'" + dr["chdm"].ToString() + "',1,1,1,getdate(),'" + dr["ckid"].ToString() + "','" + dr["cw"].ToString() + "'");
                    //tmdtcwSb.Append(" SET @id=SCOPE_IDENTITY(); set @ids=@ids+','+cast(@id as varchar); ");
                }

                //tmdtcwSb.Append("set @ids=SUBSTRING(@ids,2,LEN(@ids)); exec pda_kc_kchz @ids,'sl-',0; ");
                str_sql += " declare @getdate datetime;set @getdate=getdate(); declare @ids varchar(max);"+
                        "insert into cl_t_pdakcdj (djlx, tm, gzh, sl, tzid, zdr, zdrq, chdm, shbs, qrbs, djbs, rq, ckid, cw )" + string.Join(" union all ", tmdtcwList.ToArray())+
                        "set @ids=(select CAST(id AS VARCHAR(max))+','  from cl_t_pdakcdj where djlx=2462 and zdr='"+username+"' and zdrq=@getdate FOR XML PATH('') ); exec pda_kc_kchz @ids,'sl-',0;  ";

                str_sql += "select @zxh;COMMIT TRAN GO;";
                //writeLog("\r\nSQL:" + str_sql);
                //return "error:tets";
                using (LiLanzDALForXLM dal = new LiLanzDALForXLM())
                {
                    dal.ConnectionString = connStr;
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

                    }
                }
            }
            #endregion
            writeLog("\r\nSQL:" + str_sql + "\r\ntmList:" + string.Join(",", tmArray) + "\r\nxmList:" + string.Join(",", xmArray));
        }
        return rtMsg;
    }

    /// <summary>
    /// 库存出库对照
    /// </summary>
    /// <returns></returns>
    [WebMethod(Description = "库存出库对照")]
    public Result getPDAkc(DataTable dt)
    {
        string errInfo = "";
        Result result = new Result();
        result.Errcode = 0;
        DataTable resdt = new DataTable();
        DataColumn dc = null;
        dc = resdt.Columns.Add("gzh", Type.GetType("System.String"));
        dc = resdt.Columns.Add("chdm", Type.GetType("System.String"));
        dc = resdt.Columns.Add("ckid", Type.GetType("System.Int32"));
        dc = resdt.Columns.Add("tzid", Type.GetType("System.Int32"));
        dc = resdt.Columns.Add("tm", Type.GetType("System.String"));
        dc = resdt.Columns.Add("sl", Type.GetType("System.Single"));
        dc = resdt.Columns.Add("cw", Type.GetType("System.String"));
        using (LiLanzDALForXLM dal = new LiLanzDALForXLM())
        {
            dal.ConnectionString = connStr;

            List<string> sb = new List<string>();
            string str_sql = "";
            string[] fieldNames = { "gzh", "chdm", "ckid", "tzid" };
            DataTable istinctDt = Distinct(dt, fieldNames);
            for (int i = 0; i < istinctDt.Rows.Count; i++)
                sb.Add(" select  gzh = '" + istinctDt.Rows[i]["gzh"] + "' , chdm = '" + istinctDt.Rows[i]["chdm"] + "' , ckid = " + istinctDt.Rows[i]["ckid"] + " , tzid = " + istinctDt.Rows[i]["tzid"]);

            str_sql += " SELECT A.* INTO #TMP FROM  (" + string.Join(" union ", sb.ToArray()) + ") A  ";
            str_sql += " select a.* from cl_T_pdakc a inner join  #TMP b on a.gzh=b.gzh and a.chdm=b.chdm and a.ckid=b.ckid and a.tzid=b.tzid  ORDER BY a.gzh,a.chdm,a.ckid,a.tzid,a.sl";
            //writeLog("\r\nSQL:" + str_sql);
            DataTable sldt = null;
            List<SqlParameter> para = new List<SqlParameter>();
            string aa = DateTime.Now.ToString();
            errInfo = dal.ExecuteQuerySecurity(str_sql, para, out sldt);
            string bb = DateTime.Now.ToString();
            //writeLog("\r\ntime:" + aa + "\r\ntime:" + bb);

            if (errInfo == "")
            {

                for (int i = 0; i < dt.Rows.Count; i++)
                {
                    double sl = double.Parse(dt.Rows[i]["sl"].ToString());
                    DataRow[] drs = sldt.Select("gzh = '" + dt.Rows[i]["gzh"] + "' and chdm = '" + dt.Rows[i]["chdm"] + "' and ckid = " + dt.Rows[i]["ckid"] + " and tzid = " + dt.Rows[i]["tzid"]);
                    if (drs.Length > 0)
                    {
                        for (int j = 0; j < drs.Length; j++)
                        {
                            DataRow newRow = resdt.NewRow();
                            newRow["tm"] = dt.Rows[i]["tm"];
                            newRow["tzid"] = dt.Rows[i]["tzid"];
                            newRow["ckid"] = dt.Rows[i]["ckid"];
                            newRow["gzh"] = dt.Rows[i]["gzh"];
                            newRow["chdm"] = dt.Rows[i]["chdm"];
                            newRow["cw"] = drs[j]["cw"];
                            if (sl >= double.Parse(drs[j]["sl"].ToString()))
                            {
                                newRow["sl"] = double.Parse(drs[j]["sl"].ToString());
                                resdt.Rows.Add(newRow);
                                sl -= double.Parse(drs[j]["sl"].ToString());
                                //writeLog("\r\nsl:" + sl  );
                                drs[j]["sl"] = 0;
                                if (sl == 0) break;
                            }
                            else if (sl < double.Parse(drs[j]["sl"].ToString()))
                            {
                                newRow["sl"] = sl;
                                resdt.Rows.Add(newRow);
                                drs[j]["sl"] = double.Parse(drs[j]["sl"].ToString()) - sl;
                                sl = 0;
                                break;
                            }
                        }
                        if (sl > 0)
                        {
                            //仓位库存数量不足
                            DataRow newRow = resdt.NewRow();
                            newRow["tm"] = dt.Rows[i]["tm"];
                            newRow["tzid"] = dt.Rows[i]["tzid"];
                            newRow["ckid"] = dt.Rows[i]["ckid"];
                            newRow["gzh"] = dt.Rows[i]["gzh"];
                            newRow["chdm"] = dt.Rows[i]["chdm"];
                            newRow["cw"] = "仓位不足";
                            newRow["sl"] = sl;
                            resdt.Rows.Add(newRow);
                        }

                    }
                    else
                    {
                        //库存无数据
                        DataRow newRow = resdt.NewRow();
                        newRow["tm"] = dt.Rows[i]["tm"];
                        newRow["tzid"] = dt.Rows[i]["tzid"];
                        newRow["ckid"] = dt.Rows[i]["ckid"];
                        newRow["gzh"] = dt.Rows[i]["gzh"];
                        newRow["chdm"] = dt.Rows[i]["chdm"];
                        newRow["cw"] = "仓位不足";
                        newRow["sl"] = sl;
                        resdt.Rows.Add(newRow);
                    }
                }
                resdt.TableName = "zxckcw";
                //result.Data = SerializeDataTableXml(resdt);
                result.Data = resdt;

            }
            else
            {
                result.Errmsg = "error:" + errInfo;
                result.Errcode = 201;
            }
        }
        return result;
    }

    public static DataTable Distinct(DataTable dt, string[] filedNames)
    {
        DataView dv = dt.DefaultView;
        DataTable DistTable = dv.ToTable("Dist", true, filedNames);
        return DistTable;
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

    /// <summary>
    /// 反序列化DataTable
    /// </summary>
    public static DataTable DeserializeDataTable(string pXml)
    {
        StringReader strReader = new StringReader(pXml);
        XmlReader xmlReader = XmlReader.Create(strReader);
        XmlSerializer serializer = new XmlSerializer(typeof(DataTable));
        DataTable dt = serializer.Deserialize(xmlReader) as DataTable;
        return dt;
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


public class WLLLData : IDisposable
{
    private int _id;
    private string _ch;

    public int id
    {
        get { return this._id; }
        set { this._id = value; }
    }

    public string ch
    {
        get { return this._ch; }
        set { this._ch = value; }
    }
    #region IDisposable 成员
    public void Dispose()
    {
    }
    #endregion

}

public class PDAPD : IDisposable
{
    private string _chdm;
    private string _chmc;
    private string _sl;
    private string _ckid;
    private string _cw;
    private string _tm;
    private string _scddbh;
    private string _zdr;

    public string chdm
    {
        get { return this._chdm; }
        set { this._chdm = value; }
    }
    public string chmc
    {
        get { return this._chmc; }
        set { this._chmc = value; }
    }
    public string sl
    {
        get { return this._sl; }
        set { this._sl = value; }
    }
    public string ckid
    {
        get { return this._ckid; }
        set { this._ckid = value; }
    }
    public string cw
    {
        get { return this._cw; }
        set { this._cw = value; }
    }
    public string tm
    {
        get { return this._tm; }
        set { this._tm = value; }
    }
    public string scddbh
    {
        get { return this._scddbh; }
        set { this._scddbh = value; }
    }
    public string zdr
    {
        get { return this._zdr; }
        set { this._zdr = value; }
    }
    #region IDisposable 成员
    public void Dispose()
    {
    }
    #endregion
}

public class PDAJS : IDisposable
{
    private string _tm;

    public string tm
    {
        get { return this._tm; }
        set { this._tm = value; }
    }

    #region IDisposable 成员
    public void Dispose()
    {
    }
    #endregion
}

public class Result
{
    private int errcode = 0;

    public int Errcode
    {
        get { return errcode; }
        set { errcode = value; }
    }
    private string errmsg;

    public string Errmsg
    {
        get { return errmsg; }
        set { errmsg = value; }
    }
    private object data;

    public object Data
    {
        get { return data; }
        set { data = value; }
    }
}

public class TMRecode
{
    public string tm;
    public decimal sl;
    public List<int> djIDList = new List<int>();

    public void InsertID(int id)
    {
        if (!djIDList.Contains(id))
        {
            djIDList.Add(id);
        }
    }
    //保存每支布分配 情况
    public Dictionary<int, Double> tmMxid = new Dictionary<int, Double>();
}

