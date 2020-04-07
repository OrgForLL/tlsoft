using System;
using System.Collections.Generic;
using System.Web.Services;
using System.Data;
using Newtonsoft.Json;
using nrWebClass;
using LiLanzModel;

using System.Security.Cryptography;
using System.Text;
using System.Net;
using System.IO;

/// <summary>
/// POST数据
/// </summary>
public class Par {
    public string partnerid;
    public string servicetype;
    public string bizdata;
    public string timestamp;
    public string nonce;
    public string sign;
}
/// <summary>
/// 疵点
/// </summary>
public class FabricFault
{
    public string cdmc;
    public float cdwz;
    public int cdfs;
}
/// <summary>
/// 码单
/// </summary>
public class WtMemoVO
{
    public string serviceuuid;
    public string ph;
    public string gh;
    public string ys;
    public float mdsl;
    public string xhdx;
    public string mfk;
    public float fk;
    public string kz;
    public string jh;
    public string sphh;
    public float mc;
    public string qtj;
    public string qtw;
    public string sxj;
    public string sxw;
    public float wx;
    public float sjsl;
    public float twsc;
    public float bzsc;
    public string tm;
    public string lltm;
    public string mdbz;
    public float wh;
    public float hpl;
    public string sjb;
    public string juanb;
    public string dxm;
    public List<FabricFault> fabricFaultList = new List<FabricFault>();

}
/// <summary>
/// 报告数据
/// </summary>
public class BillData
{
    public string clientuuid;
    public string djh;
    public string rq;
    public bool mlyqryzx;
    public string mlyqryzxbz;
    public bool dhyjdyzx;
    public string dhyjdyzxbz;
    public bool sghfgyqryzx;
    public string sghfgyqryzxbz;
    public bool pypzjsgyzx;
    public string pypzjsgyzxbz;
    public float hpl;
    public string bz;
    public int bgzt;
    public string tsrq;
    public List<WtMemoVO> wtMemoVOList = new List<WtMemoVO>();
}

public partial class tl_yf_Default : System.Web.UI.Page
{

    protected void Page_Load(object sender, EventArgs e)
    {
        BillData billData = new BillData();
        billData.clientuuid = "客户端uuid1";
        billData.djh = "100078";
        billData.rq = "2019-03-07";
        billData.dhyjdyzx = false;
        billData.dhyjdyzxbz = "整批大货包装方法与接单要求一致性备注";
        billData.sghfgyqryzx = true;
        billData.sghfgyqryzxbz = "整批面料手感/风格与确认样一致性备注";
        billData.pypzjsgyzx = false;
        billData.pypzjsgyzxbz = "整批面料匹与匹之间色光一致性备注";
        billData.mlyqryzx = true;
        billData.mlyqryzxbz = "整批面料材料名称与确认样一致性备注";
        billData.hpl = 3;
        billData.bz = "";
     
        WtMemoVO v1 = new WtMemoVO();
        v1.ph = "150";
        v1.gh = "1";
        v1.ys = "黑色";
        v1.mdsl = 60;
        v1.mfk = "140";
        v1.fk = 140;
        v1.kz = "305";
        v1.jh = "a";
        v1.sphh = "";
        v1.mc = 25;
        v1.qtj = "-0.5";//"汽烫缩率经";
        v1.qtw = "-0.5";//"汽烫缩率纬";
        v1.sxj = "-0.5";//"水洗缩率经";
        v1.sxw = "-0.5";//"水洗缩率纬";
        v1.wx = 3;
        v1.sjsl = 60;
        v1.twsc = 4;
        v1.bzsc = 4;
        v1.tm = "条码";
        v1.xhdx = "循环大小";
        v1.wh = 2;
        v1.mdbz = "码单备注";
        v1.sjb = "松紧边，荷叶边 ";
        v1.juanb = "卷边 ";
        v1.dxm = "倒顺毛";
        v1.hpl = 3;//换片率
        FabricFault f = new FabricFault();
        f.cdmc = "G";
        f.cdwz = 2;
        f.cdfs = 2;
        FabricFault f2 = new FabricFault();
        f2.cdmc = "K";
        f2.cdwz = 1;
        f2.cdfs = 2;
         
        v1.fabricFaultList.Add(f);
        v1.fabricFaultList.Add(f2);
        billData.wtMemoVOList.Add(v1);
        List<BillData> bDlist = new List<BillData>();
        bDlist.Add(billData);

        Par p = new Par();
        p.partnerid = "1";
        p.servicetype = "bodyInspReport";
        p.bizdata = JsonConvert.SerializeObject(bDlist);
        p.timestamp = "1569053559";
        p.nonce = "15690535598";

        p.sign = GetSign2("test", p.partnerid, p.servicetype,p.bizdata,p.timestamp,p.nonce);
        //正式
        string url = @"http://192.168.36.121:9307/ApiRoute?action=llwebapi";
        url = @"http://api.lilanz.com:9307/ApiRoute?action=llwebapi";
        string postJson = string.Format( "partnerid={0}&servicetype={1}&data={2}&timestamp={3}&nonce={4}&sign={5}",p.partnerid,p.servicetype,p.bizdata,p.timestamp,p.nonce,p.sign);
        
        string r =PostFunctionjson(url, postJson);
    }
    /*SELECT TOP 11  * FROM dbo.Yf_T_bjdlb WHERE lxid=517  AND id=1902399
SELECT jyid,* FROM dbo.cl_v_jhdjmxb WHERE id=168183
SELECT * FROM wl_t_dddjpmmx WHERE id=168183
 SELECT * FROM yf_t_bjdl_jhmxb WHERE id=1902400
 DELETE FROM wl_t_dddjpmmx WHERE id=168183*/
    public static string GetSign2(string partnerKey, string partnerid, string servicetype, string bizdata, string timestamp, string nonce)
    {

        List<String> lstParams = new List<string>();
        lstParams.Add("partnerid=" + partnerid);
        lstParams.Add("servicetype=" + servicetype);
        lstParams.Add("data=" + bizdata);
        lstParams.Add("timestamp=" + timestamp);
        lstParams.Add("nonce=" + nonce);
        string[] strParams = lstParams.ToArray();
        Array.Sort(strParams);     //参数名ASCII码从小到大排序（字典序）； 
        string origin = string.Join("&", strParams);
        origin = string.Concat(origin, partnerKey);
        MD5 md5 = new MD5CryptoServiceProvider();
        byte[] targetData = md5.ComputeHash(System.Text.Encoding.UTF8.GetBytes(origin));
        StringBuilder sign = new StringBuilder("");
        foreach (byte b in targetData)
        {
            sign.AppendFormat("{0:x2}", b);
        }
        return sign.ToString();
    }
    protected void Page_Load3(object sender, EventArgs e)
    {
        Par p = new Par();
        p.partnerid = "18134";
        p.servicetype = "LLWebApi_CL_GetScDdData";
        //传参待定
        p.bizdata = "{\"BeginDate\":\"2019-09-01\",\"EndDate\":\"2019-09-20\"}";
        p.timestamp = string.Format("{0:yyyyMMddHHmmss}", DateTime.Now);
        p.nonce = System.Guid.NewGuid().ToString();

        p.sign = GetSign("06156B03-194B-4266-A459-0A1AF03330DA", p.partnerid, p.servicetype, p.bizdata, p.timestamp, p.nonce);
        //正式
        string url = @"http://webt.lilang.com/LLService/ApiRoute.ashx?action=llwebapi";
       // string url = @"http://api.lilanz.com:9307/ApiRoute?action=llwebapi";
        //测试
        //string url = @"http://192.168.35.231/LLWebApi/ApiRoute.ASHX?action=llwebapi";
        string postJson = string.Format("partnerid={0}&servicetype={1}&bizdata={2}&timestamp={3}&nonce={4}&sign={5}", p.partnerid, p.servicetype, p.bizdata, p.timestamp, p.nonce, p.sign);

        string r = PostFunction(url, postJson);
    }

    public static string GetSign(string partnerKey,string partnerid,string servicetype,string bizdata,string timestamp,string nonce)
    {
        
        List<String> lstParams = new List<string>();
        lstParams.Add("partnerid="+ partnerid);
        lstParams.Add("servicetype="+ servicetype);
        lstParams.Add("bizdata=" + bizdata);
        lstParams.Add("timestamp=" + timestamp);
        lstParams.Add("nonce=" + nonce);
        string[] strParams = lstParams.ToArray();
        Array.Sort(strParams);     //参数名ASCII码从小到大排序（字典序）； 
        string origin = string.Join("&", strParams);
        origin = string.Concat(origin, partnerKey);
        MD5 md5 = new MD5CryptoServiceProvider();
        byte[] targetData = md5.ComputeHash(System.Text.Encoding.UTF8.GetBytes(origin));
        StringBuilder sign = new StringBuilder("");
        foreach (byte b in targetData)
        {
            sign.AppendFormat("{0:x2}", b);
        }
        return sign.ToString();
    }
    /// <summary>
    /// 发送POST请求
    /// </summary>
    /// <param name="url"></param>
    /// <param name="postJson"></param>
    /// <returns></returns>
    public string PostFunction(string url, string postJson)
    {
        string Result = "";
        string serviceAddress = url;
        HttpWebRequest request = (HttpWebRequest)WebRequest.Create(serviceAddress);

        request.Method = "POST";
        request.ContentType = "application/x-www-form-urlencoded";
        string strContent = postJson;
        using (StreamWriter dataStream = new StreamWriter(request.GetRequestStream()))
        {
            dataStream.Write(strContent);
            dataStream.Close();
        }

        HttpWebResponse response = (HttpWebResponse)request.GetResponse();
        string encoding = response.ContentEncoding;
        if (encoding == null || encoding.Length < 1)
        {
            encoding = "UTF-8"; //默认编码  
        }
        // Encoding.GetEncoding(encoding)
        StreamReader reader = new StreamReader(response.GetResponseStream());
        Result = reader.ReadToEnd();
        //Console.WriteLine(Result);
        return Result;

    }
    public string PostFunctionjson(string url, string postJson)
    {
        string Result = "";
        string serviceAddress = url;
        HttpWebRequest request = (HttpWebRequest)WebRequest.Create(serviceAddress);

        request.Method = "POST";
        request.ContentType = "application/json";
        string strContent = postJson;
        using (StreamWriter dataStream = new StreamWriter(request.GetRequestStream()))
        {
            dataStream.Write(strContent);
            dataStream.Close();
        }

        HttpWebResponse response = (HttpWebResponse)request.GetResponse();
        string encoding = response.ContentEncoding;
        if (encoding == null || encoding.Length < 1)
        {
            encoding = "UTF-8"; //默认编码  
        }
        // Encoding.GetEncoding(encoding)
        StreamReader reader = new StreamReader(response.GetResponseStream());
        Result = reader.ReadToEnd();
        //Console.WriteLine(Result);
        return Result;

    }
    public string orderDetail(string data)
    {

        //货号1|尺码1|尺码2|,货号2|尺码1|尺码2
        //货号1,货号2,....
        //string data = Context.Request.QueryString["data"].ToString();
        string sphhSql = "";
        //构造货号范围表   //
        foreach (string item in data.Split(','))
        {
            if (item.Contains("|"))
            {
                for (int i = 1; i < item.Split('|').Length; i++)
                {
                    sphhSql = sphhSql + " select '" + item.Split('|')[0] + "' as sphh,'cm" + item.Split('|')[i] + "' as cm union ";
                }
            }
            else
            {
                sphhSql = sphhSql + " select '" + item + "' as sphh,'cm24' as cm union ";
            }
        }
        string sql = "select a.sphh,a.cm into #sphh from (" + sphhSql.Substring(0, sphhSql.Length - 6) + ") a ;";
        sql += " select distinct sphh.lydjid as xzid,sphh.sphh into #range  ";
        sql += " from yf_v_rinsing_sphh_all sphh ";
        sql += " inner join (select distinct sphh from #sphh) hh on hh.sphh=sphh.sphh where  sphh.djzt=0 ";
        //构造货号范围表 end //

        //合格证信息           
        sql += " select f.id,f.lydjid,f.dbhg,f.dbtg,f.ddh as '水洗材料',f.fk as '水洗材料下装',f.dbxx as '西服三件套马甲',pm.mc '品名',isnull(bsz.mc,'') '品名上装',isnull(bxz.mc,'') '品名下装',isnull(bmj.mc,'') as '品名西服三件套马甲' ,";
        sql += " gb.dm '版型',yp.yphh '样号',case f.dsqk when '' then '' else f.dsqk+'：' end +f.shqk '洗涤方法',case f.dekz when '' then '' else f.dekz+'：' end +f.desz '洗涤方法上装',case f.jfk when '' then '' else f.jfk+'：' end+f.ghsyj '洗涤方法下装',xt.mc '警告语',g.mc '执行标准',f.jpg '等级',h.mc '安全技术类别',sphh.sphh '货号', m.notice '注意事项',m.store '使用和贮藏',";
        sql += " sx.notice 'sx注意事项',sx.store 'sx使用和贮藏',kusx.notice 'kusx注意事项',kusx.store 'kusx使用和贮藏' ";
        sql += " into #myzb  ";
        sql += " from yf_T_bjdlb f ";
        sql += " inner join #range r on r.xzid=f.id   ";
        sql += " inner join yf_v_rinsing_sphh_all sphh on f.id=sphh.lydjid  and sphh.sphh=r.sphh ";
        sql += " inner join Yf_T_bjdbjzb pm on pm.id=f.tplx";
        sql += " left join Yf_T_bjdbjzb bsz on f.dycs=bsz.id  ";
        sql += " left join Yf_T_bjdbjzb bxz on f.wtlx=bxz.id  ";
        sql += " left join Yf_T_bjdbjzb bmj on f.sftj=bmj.id  ";
        sql += " inner join Yf_T_bjdbjzb g on g.id=f.ddid";
        sql += " inner join yx_T_spdmb sp on sp.sphh=sphh.sphh";
        sql += " inner join yx_v_ypdmb yp on yp.yphh=sp.yphh ";
        sql += " left join  Yf_T_bjdbjzb gb on gb.id=yp.bhks  ";
        sql += " inner join Yf_T_bjdbjzb h on h.lx=905 and f.sylx=h.id and h.tzid=1 ";
        sql += " left join ghs_t_xtdm xt on xt.id=isnull(f.kzx4,0) ";
        sql += " inner join yf_v_rinsingtemplate  m on m.id=f.lydjid  ";
        sql += " left join yf_v_rinsingtemplate sx on sx.id=f.dbhg ";
        sql += " left join yf_v_rinsingtemplate kusx on kusx.id=f.dbtg ";
        sql += "  where   f.lxid=903 and  f.tzid='1' ; ";
        //table0 标签信息,一个货号一条记录
        sql += "  select * from #myzb; ";
        //table1 纤维含量
        sql += " select zb.货号,  ROW_NUMBER() OVER(PARTITION BY zb.货号 order by xw.sytjid) sytjid, ";
        sql += " /*case when isnull(xw.sz,'')='/' or isnull(xw.pdjg,'')='' then xw.sz else xw.pdjg+':'+xw.sz end as mxsz*/xw.pdjg,xw.sz,xw.glz   ";
        sql += " from #myzb zb   inner join yf_T_bjdmxb xw on zb.id=xw.mxid  and xw.lxid=903 ; ";
        //table2图标
        sql += " select a.* from ( ";
        sql += "   SELECT '主模版' lx, zb.货号, b.path,b.mc,b.dm FROM yf_v_rinsingtemplateico a INNER JOIN yf_V_rinsingico b ON a.icodm=b.dm  ";
        sql += "   inner join #myzb zb on zb.lydjid=a.mxid      ";
        sql += "   union all";
        sql += "   SELECT '上装' lx ,zb.货号, b.path,b.mc,b.dm FROM yf_v_rinsingtemplateico a INNER JOIN yf_V_rinsingico b ON a.icodm=b.dm  ";
        sql += "   inner join #myzb zb on zb.dbhg=a.mxid     ";
        sql += "   union all";
        sql += "   SELECT '下装' lx,zb.货号, b.path,b.mc,b.dm FROM yf_v_rinsingtemplateico a INNER JOIN yf_V_rinsingico b ON a.icodm=b.dm  ";
        sql += "   inner join #myzb zb on zb.dbtg=a.mxid      ";
        sql += "  ) a order by a.lx, cast( a.dm as int)   ";
        //table3 各尺寸绒含量
        sql += " SELECT b.lxbs,a.货号, hjyl=(mx.hsz+mx.bzsh),gg.hx crlhx,mx.cmdm ";
        sql += " FROM #myzb a ";
        sql += " inner join yx_T_spdmb sp on sp.sphh=a.货号";
        sql += " INNER JOIN dbo.YX_T_Ypdmb yp ON sp.yphh=yp.yphh ";
        sql += " INNER JOIN YF_T_Bom b ON b.yphh=yp.yphh  AND b.cmfj=1 ";
        sql += " inner join cl_v_chdmb_all ch on ch.chdm=b.chdm ";
        sql += " inner join yf_T_bjdlb bj on bj.id=ch.bjid and bj.kzx1 =297";
        sql += " INNER JOIN YF_T_Bomcmmx mx ON b.id=mx.id ";
        sql += " inner JOIN yx_V_sphxggb gg ON 'cm'+mx.cmdm=gg.cmdm AND yp.yphh=gg.yphh";
        //table4 水洗标材料
        sql += " select b.货号,b.lx, a.* from YF_v_SXBCHDM a inner join ( select 货号, 水洗材料 chdm,'上装' lx from #myzb union select 货号, 水洗材料下装 chdm,'下装' lx from #myzb union select 货号, 西服三件套马甲 chdm,'西服三件套马甲' lx from #myzb ) b on a.chdm=b.chdm ;";
        //5号型规格
        sql += " select  a.货号, zh.cmdm,isnull(k.hx,case when lw.id is not  null then  '不打印' else '未维护' end )  as hx, ";
        sql += " isnull(k.hx2,case when lw.id is not  null then  '不打印' else '未维护' end)  as hx2,";
        sql += " hx2isExists= case isnull(k.hx2,'') when '' then 0 else 1 end , ";
        sql += " isnull(k.gg,case when lw.id is not  null then  '不打印' else '未维护' end)  as gg ";
        sql += " from #myzb a";
        sql += " inner join yx_T_spdmb sp on sp.sphh=a.货号";
        sql += " inner join yx_v_ypdmb yp on yp.yphh=sp.yphh ";
        sql += " inner join yx_t_cmzh zh on zh.tml=yp.tml ";
        sql += " inner join (select distinct sphh from #sphh) kz on kz.sphh=a.货号  ";
        sql += " left join yx_V_sphxggb k on k.yphh=yp.yphh and zh.cmdm=k.cmdm";
        sql += " left join yx_V_noneedhxgg lw on lw.id=yp.splbid ";
        //6要显示哪些尺码
        sql += " select * from #sphh;";
        sql += " drop table #myzb; drop table #sphh;drop table #range;";
        DataSet htzinfoDs = null;
        //string ConnectionString = "Server=192.168.35.10;Database=TLSOFT;Uid=ABEASD14AD;Pwd=+AuDkDew;";
        using (LiLanzDALForXLM dal = new LiLanzDALForXLM(1))
        {
            dal.ConnectionString = "server='192.168.35.10';uid=ABEASD14AD;pwd=+AuDkDew;database=tlsoft "; ;
            dal.ExecuteQuery(sql, out htzinfoDs);
        }
        DataTable htzinfo = htzinfoDs.Tables[0].Copy();//'水洗信息
        DataTable hlinfo = htzinfoDs.Tables[1].Copy(); //纤维成份'
        DataTable icoinfo = htzinfoDs.Tables[2].Copy();// '图标'
        DataTable crlinfo = htzinfoDs.Tables[3].Copy();// '各尺寸绒含量
        DataTable chdminfo = htzinfoDs.Tables[4].Copy();// '水洗标材料
        DataTable hxgginfo = htzinfoDs.Tables[5].Copy();// '尺码表
        DataTable showinfo = htzinfoDs.Tables[6].Copy();// '要显示哪些尺码
        List<SphhInfo> sphhInfoList = new List<SphhInfo>();
        foreach (DataRow sphhdr in htzinfo.Rows)
        {
            SphhInfo sphhInfo = new SphhInfo();
            if (string.Compare(sphhdr["洗涤方法"].ToString(), "/") == 0)
            {
                sphhInfo.Xdff = "";
            }
            else
            {
                sphhInfo.Xdff = sphhdr["洗涤方法"].ToString();
            }
            if (string.Compare(sphhdr["洗涤方法上装"].ToString(), "/") == 0)
            {
                sphhInfo.Xdff_sz = "";
            }
            else
            {
                sphhInfo.Xdff_sz = sphhdr["洗涤方法上装"].ToString();
            }
            if (string.Compare(sphhdr["洗涤方法下装"].ToString(), "/") == 0)
            {
                sphhInfo.Xdff_xz = "";
            }
            else
            {
                sphhInfo.Xdff_xz = sphhdr["洗涤方法下装"].ToString();
            }
            //成份
            foreach (DataRow dr in hlinfo.Select("货号='" + sphhdr["货号"].ToString() + "'   "))
            {
                MaterialInfo2 cf = new MaterialInfo2();
                cf.Glz = int.Parse(dr["Glz"].ToString());
                cf.Sytjid = int.Parse(dr["Sytjid"].ToString());
                cf.Value = dr["sz"].ToString();
                cf.Title = dr["Pdjg"].ToString();
                sphhInfo.CfList.Add(cf);
            }
            //图标        
            foreach (DataRow dr in icoinfo.Select("货号='" + sphhdr["货号"].ToString() + "'   "))
            {
                Ico ico = new Ico();
                ico.Path = dr["path"].ToString();
                ico.Mc = dr["mc"].ToString();
                ico.Lx = dr["lx"].ToString();
                sphhInfo.IcoList.Add(ico);
            }
            //水洗标材料
            foreach (DataRow dr in chdminfo.Select("货号='" + sphhdr["货号"].ToString() + "'   "))
            {
                SxChdmDataContent sx = new SxChdmDataContent();
                sx.Lx = dr["lx"].ToString();
                sx.Sm = dr["sm"].ToString();
                sphhInfo.SxChdmList.Add(sx);
            }

            foreach (DataRow cmdr in hxgginfo.Select("货号='" + sphhdr["货号"].ToString() + "'   "))
            {
                SphhCmInfo s = new SphhCmInfo();
                s.Sphh = sphhdr["货号"].ToString();
                s.Cm = cmdr["cmdm"].ToString();
                s.Gg = cmdr["gg"].ToString();
                DataRow[] clrdr = crlinfo.Select("货号='" + sphhdr["货号"].ToString() + "' and 'cm'+cmdm='" + cmdr["cmdm"].ToString() + "'");
                if (clrdr.Length >= 1)
                {
                    foreach (DataRow dr in clrdr)
                    {
                        if (Decimal.Parse(dr["hjyl"].ToString()) > 0)
                        {
                            Dictionary<string, string> g = new Dictionary<string, string>();
                            g.Add("Clr", String.Format("{0:####.#}", Math.Round(Decimal.Parse(dr["hjyl"].ToString()) * 1000, 1)) + "g");
                            g.Add("Clrgg", dr["crlhx"].ToString());
                            g.Add("lxbs", dr["lxbs"].ToString());
                            s.ClrInfo.Add(g);
                        }
                        else
                        {
                            Dictionary<string, string> g = new Dictionary<string, string>();
                            g.Add("Clr", "");
                            g.Add("Clrgg", "");
                            g.Add("lxbs", "0");
                            s.ClrInfo.Add(g);
                        }
                    }
                }
                else
                {
                    Dictionary<string, string> g = new Dictionary<string, string>();
                    g.Add("Clr", "");
                    g.Add("Clrgg", "");
                    g.Add("lxbs", "0");
                    s.ClrInfo.Add(g);
                }
                s.Hx2isExists = int.Parse(cmdr["hx2isExists"].ToString());
                s.Hx = cmdr["hx"].ToString();
                s.Hx2 = cmdr["hx2"].ToString();
                sphhInfo.SphhCmInfo.Add(s);
            }
            sphhInfo.Sphh = sphhdr["货号"].ToString();
            foreach (DataRow dr in showinfo.Select("sphh='" + sphhdr["货号"].ToString() + "'"))
            {
                sphhInfo.Cm.Add(dr["cm"].ToString(), 1);
            }
            //sphhInfo.Cm = showinfo.Select("sphh='" + sphhdr["货号"].ToString() + "'")[0]["cm"].ToString();
            sphhInfo.Pm = sphhdr["品名"].ToString();
            sphhInfo.Pm_sz = sphhdr["品名上装"].ToString();
            sphhInfo.Pm_xz = sphhdr["品名下装"].ToString();
            sphhInfo.Pm_mj3 = sphhdr["品名西服三件套马甲"].ToString();
            sphhInfo.Yphh = sphhdr["样号"].ToString();
            sphhInfo.Bx = sphhdr["版型"].ToString();
            sphhInfo.Aqjb = sphhdr["安全技术类别"].ToString();
            sphhInfo.Jgy = sphhdr["警告语"].ToString();
            sphhInfo.Zysx = sphhdr["注意事项"].ToString();
            sphhInfo.Sycc = sphhdr["使用和贮藏"].ToString();
            sphhInfo.Zysx_sx = sphhdr["sx注意事项"].ToString();
            sphhInfo.Sycc_sx = sphhdr["sx使用和贮藏"].ToString();
            sphhInfo.Zysx_kusx = sphhdr["kusx注意事项"].ToString();
            sphhInfo.Sycc_kusx = sphhdr["kusx使用和贮藏"].ToString();
            sphhInfo.Zxbz = sphhdr["执行标准"].ToString();
            sphhInfoList.Add(sphhInfo);
        }
        return JsonConvert.SerializeObject(sphhInfoList);


    }

}