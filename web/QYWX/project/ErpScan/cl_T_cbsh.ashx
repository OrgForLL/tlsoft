<%@ WebHandler Language="C#" Class="cl_T_cbsh" Debug="true" %>

using System;
using System.Web;
using System.Collections.Generic;
using Newtonsoft.Json;
using Newtonsoft.Json.Converters;
using System.Web.SessionState;
using System.Text;
using System.Data;
using System.Data.SqlClient;
using nrWebClass;
using System.IO;
using System.Net;
using System.Drawing;
using System.Drawing.Imaging;

public class cl_T_cbsh : IHttpHandler, IRequiresSessionState
{
    public void ProcessRequest(HttpContext context)
    {
        HttpRequest request = context.Request;
        HttpResponse response = context.Response;
        request.ContentEncoding = Encoding.UTF8;
        response.ContentType = "application/json"; //如果返回给客户端的是 json数据时， 设置ContentType="application/json"
        string OAConnStr = clsConfig.GetConfigValue("OAConnStr");
        string action = request["action"].ToString();
        string str_sql = "";
        string info = "";
        if (action == "search")
        {
            string cpjj = "", ddbh = "", sphh = "", khmc = "", shbs = "", htlx = "";
            bool isInit = true;
            isInit = bool.Parse(request["isInit"].ToString());

            if (isInit)
            {
                response.Write("");
                response.End();
            }

            if (request["cpjj"].ToString() != "")
            {

                cpjj = "and ht.cpjj='" + request["cpjj"].ToString() + "'";
            }
            if (request["ddbh"].ToString() != "")
            {
                ddbh = "and ht.ddbh like '" + request["ddbh"].ToString() + "%'";
            }
            if (request["sphh"].ToString() != "")
            {
                sphh = "and ht.sphh like '" + request["sphh"].ToString() + "%'";
            }
            if (request["khmc"].ToString() != "")
            {
                khmc = "and kh.khmc like '%" + request["khmc"].ToString() + "%'";
            }

            shbs = "and a.shbs='" + request["shbs"].ToString() + "'";
            if (request["htlx"].ToString() != "")
            {
                htlx = "and ht.djlx=" + request["htlx"].ToString();
            }
            string fjs = request["fjs"].ToString();
            DataSet dataSet = null;
            using (LiLanzDALForXLM dal = new LiLanzDALForXLM(1))
            {
                str_sql = @"
                       select ht.id,ht.sphh,ht.cpjj,ht.ddbh into #htdd
                         from zw_v_cphtddmx ht  
                         where ht.tzid=1 {0} {1} {2} {3}

                         select * 
                         from( 
                            select distinct a.id as jsid,a.htddid as htid,case a.shbs when 1 then '弃审' else '审核' end as sh,
                            case a.shbs when 1 then '已审' else '未审' end as shzt,a.*,ht.ddbh,kh.khmc,dd.ddsl,rk.rksl,
                            (select sum(mx.kkje) from cl_T_chlychmx mx where mx.id=a.id group by mx.id) as kkje,
                            (select count(1) from t_uploadfile where tableid=a.id and groupid=8008 ) fjs  ,
                            '查询' as yfkcx,ht.cpjj,ly.jyje   
                            from cl_T_chlychb a 
                            inner join #htdd ht on a.htddid=ht.id   
                            inner join yx_T_khb kh on a.khid=kh.khid 
                            left outer join (
                                select a.id,sum(b.sl) ddsl from (select a.id,a.sphh from #htdd a group by a.id,a.sphh) a 
                                inner join yx_V_dddjmx b on a.id=b.htddid and a.sphh=b.sphh where b.tzid=1  group by a.id
                            ) dd on a.htddid=dd.id 
                            left outer join (
                                select a.id,sum(b.sl*lx.kc) rksl from (select a.id,a.sphh from #htdd a group by a.id,a.sphh)  a 
                                inner join yx_V_kcdjmx b on a.id=b.htddid and a.sphh=b.sphh  
                                inner join t_djlxb lx on b.djlx=lx.dm where b.tzid=1 and b.djlx=141 group by a.id 
                            ) rk on a.htddid=rk.id 
     
                            left join (  /*算节约金额*/       
                               select a.htddid,a.khid,sum(isnull(mx.jyje,0)) jyje
                               from cl_T_chlychb a 
                               left join cl_T_chlychmx mx on mx.id=a.id 
                               inner join (select a.id from #htdd a group by a.id) c on a.htddid=c.id 
                               where a.tzid=1 group by a.khid,a.htddid
                            ) ly on a.htddid=ly.htddid and a.khid=ly.khid  
                            where a.tzid=1 and a.djlx=8008 {4} {5}
                         ) a where case when '{6}'='0' then 1 when '{6}'='1'  and a.fjs>0 then 1 when  '{6}'='2'  and a.fjs=0 then 1 else 0 end =1
                        ;

                         drop table #htdd;";
                IsoDateTimeConverter iso = new IsoDateTimeConverter();
                iso.DateTimeFormat = "yyyy-MM-dd";
                info = dal.ExecuteQuery(string.Format(str_sql, htlx, cpjj, ddbh, sphh, khmc, shbs, fjs), out dataSet);
                if (info == "")
                {
                    response.Write(JsonConvert.SerializeObject(dataSet.Tables[0], iso));
                    response.End();
                }
                else
                {
                    response.Write(string.Format(@"{{""type"":""ERROR"",""msg"":""{0}""}}", info));
                    response.End();
                }
            }
        }
        else if (action == "sh")
        {
            string jsid = request["jsid"].ToString();
            string userid = request["userid"].ToString();
            using (LiLanzDALForXLM dal = new LiLanzDALForXLM(1))
            {
                str_sql = " update cl_T_chlychb set shbs=1,shgwid=0,shr=(select cname from t_user where id =" + userid + "),shrq=getdate() where id=" + jsid;
                info = dal.ExecuteNonQuery(str_sql);
                if (info != "-1")
                {
                    response.Write(string.Format(@"{{""type"":""SUCCESS"",""msg"":""{0}""}}", info));
                    response.End();
                }
            }
        }
        else if (action == "cpjj")
        {
            DataSet dataSet = null;
            using (LiLanzDALForXLM dal = new LiLanzDALForXLM(1))
            {
                str_sql = "SELECT * FROM (SELECT '' dm,'全部' as mc,'99' ord union select cast(mc as varchar) dm ,mc,mc ord from dbo.f_ht_cpjj(2009)) a order by ord DESC";
                info = dal.ExecuteQuery(str_sql, out dataSet);
                if (info == "")
                {
                    response.Write(JsonConvert.SerializeObject(dataSet.Tables[0]));
                    response.End();
                }
                else
                {
                    response.Write(string.Format(@"{{""type"":""ERROR"",""msg"":""{0}""}}", info));
                    response.End();
                }
            }
        }
        else if (action == "mx")
        {
            string htid = "", khid = "", jsid = "";
            htid = request["htid"].ToString();
            khid = request["khid"].ToString();

            if (request["jsid"].ToString() != null)
            {
                jsid = "and a.id = " + request["jsid"].ToString();
            }
            DataSet dataSet = null;
            using (LiLanzDALForXLM dal = new LiLanzDALForXLM(1))
            {
                str_sql = @"
                        select a.shbs, isnull(cwqr,0) as cwqr,zdr,bz,isnull(qrbs,0) qrbs,isnull(skje,0) skje from cl_T_chlychb a where 1=1 {2};

                        select a.tzid,ht.sphh,a.cmdm,a.chdm,sum(a.hjyl) as hjyl,max(a.sjlx) sjlx into #abom 
                         from YF_v_Bom_cmmx  a 
                         inner join yx_t_spdmb sp on a.yphh=sp.yphh
                         inner join (select distinct sphh from zw_V_cphtddmx a where a.id={0}) ht on sp.sphh=ht.sphh 
                         group by a.tzid,ht.sphh,a.cmdm,a.chdm;
 
                         select isnull(bfmx.kkje,0) as bfkkje,case isnull(mx.bfsl,0) when 0 then bf.bfsl else isnull(mx.bfsl,0) end as bfsl,
                         case when isnull(mx.kkje,0)>=0 then mx.kkje when ly.lysl-(jhrk.dhsl+isnull(mx.bhsl,0))*isnull(mx.shbl,1)>=0 and ly.lysl-(jhrk.dhsl+isnull(mx.bhsl,0))*isnull(mx.shbl,1)<1 then isnull(bfmx.kkje,0)  
                         when (ch.zzdj*isnull(mx.cgje,1.1))*(ly.lysl-isnull(bf.bfsl,0)-(jhrk.dhsl+isnull(mx.bhsl,0))*isnull(mx.shbl,1)-isnull(bfmx.hjsl,0))<0   
                         then isnull(bfmx.kkje,0) else  (ch.zzdj*isnull(mx.cgje,1.1))*(ly.lysl-isnull(bf.bfsl,0)-(jhrk.dhsl+isnull(mx.bhsl,0))*isnull(mx.shbl,1)-isnull(bfmx.hjsl,0))+isnull(bfmx.kkje,0) end as kkje,
 
                         isnull(mx.cgje,1.1) as cgje,ch.zzdj*isnull(mx.cgje,1.1) as cwdj,case isnull(mx.dj,0) when 0 then ch.zzdj else mx.dj end as dj,
                         ly.lysl-(jhrk.dhsl+isnull(mx.bhsl,0))*isnull(mx.shbl,1)-isnull(bfmx.hjsl,0) as chsl,isnull(mx.shbl,1) as shbl,(jhrk.dhsl+isnull(mx.bhsl,0))*isnull(mx.shbl,1) as dhzsl,ly.lysl-isnull(bfmx.hjsl,0) as hj,isnull(bfmx.hjsl,0) as cqsl,mx.shbl,mx.bhsl,mx.bfdj,mx.bfje as bfkk,mx.zje as zkk,mx.bfsl as bf,mx.bz ,isnull(mx.mxid,'0') as mxid,*,
                         case when mx.jyje<0 or jhrk.sjlx=2 then null else mx.jyje end jyje,case jhrk.sjlx when 1 then '厂家提供' when 2 then '指定采购' when 0 then  '总部材料' else ''  end sjlxmc
                         from (
                           select a.tzid,a.chdm,sum(rksl) rksl,sum(jhdh) dhsl,max(a.sjlx) sjlx 
                           from (
                             select bom.tzid,bom.chdm,bom.hjyl*rk.rksl as jhdh,rk.rksl,bom.sjlx
                             from(
                                select distinct chdm,tzid,hjyl,sjlx from (select distinct chdm,tzid,hjyl,sjlx from #abom ) a
                             ) bom 
                             left outer join(
                               select a.tzid,bom.chdm,bom.hjyl,sum(a.sl0*lx.kc) rksl 
                               from yx_V_kcdjcmmx a 
                               inner join (select distinct cmdm,hjyl,sphh,chdm from #abom) bom on a.sphh=bom.sphh and a.cmdm=bom.cmdm
                               inner join t_djlxb lx on a.djlx=lx.dm   
                               where  a.khid={1} and a.djlx = 141 and a.htddid={0} group by a.tzid,bom.chdm,bom.hjyl
                             ) rk on bom.chdm=rk.chdm and bom.hjyl=rk.hjyl 
                           ) a group by a.tzid,a.chdm
                         ) jhrk 
 
                         left outer join 
                         (
                         select a.tzid,a.chdm,-sum(a.sl*a.kcfh) lysl from cl_V_kcdjmx a  
                         inner join  (select distinct chdm from #abom ) bom on  bom.chdm=a.chdm 
                         where djlx in (511,512) and a.djlb in (2163,2160,4781,4782,2164) and a.htddid={0} 
                         and a.khid={1}  group by a.tzid,a.chdm 
 
                         ) ly on  jhrk.chdm=ly.chdm and jhrk.tzid=ly.tzid 
 
                         left outer join  
                         (
                         select a.tzid,a.chdm,-sum(a.sl*a.kcfh) as bfsl from cl_V_kcdjmx a 
                         inner join  (select distinct chdm from #abom ) bom on  bom.chdm=a.chdm 
                         where djlx in (511,512) and a.djlb=2166 and a.htddid={0} 
                         and a.khid={1}  group by a.tzid,a.chdm 
                         ) bf on  jhrk.chdm=bf.chdm and jhrk.tzid=bf.tzid 
 
                         inner join cl_V_chdmb ch on jhrk.chdm=ch.chdm and ch.tzid=1 and jhrk.tzid=ch.tzid  
                         left outer join (select a.htddid,a.tzid,b.id,b.mxid,b.chdm,b.rksl,b.jhdh,b.jhsl,b.cqy,b.lysl,b.hjsl,b.chsl,b.stsl,b.bfsl,
                           b.scsl,b.dj,b.kkje,b.bfdj,b.bfje,b.zje,b.bz,b.bhsl,b.shbl,b.cgje,b.cwdj,b.bfkkje,b.cqsl,b.jzrq,b.lymxid,b.jyje 
                           from cl_T_chlychb a 
                           inner join cl_T_chlychmx b on a.id=b.id where tzid=1 and a.htddid={0} and a.djlx=8008
                         ) mx on mx.chdm=jhrk.chdm and mx.tzid=1
                         left outer join (select a.htddid,a.tzid,b.id,b.mxid,b.chdm,b.rksl,b.jhdh,b.jhsl,b.cqy,b.lysl,b.hjsl,b.chsl,b.stsl,b.bfsl,
                           b.scsl,b.dj,b.kkje,b.bfdj,b.bfje,b.zje,b.bz,b.bhsl,b.shbl,b.cgje,b.cwdj,b.bfkkje,b.cqsl,b.jzrq,b.lymxid 
                           from cl_T_chlychb a 
                           inner join cl_T_chlychmx b on a.id=b.id where tzid=1 and a.htddid={0} and a.djlx=8017
                         ) bfmx on bfmx.chdm=jhrk.chdm and bfmx.tzid=1 
 
                         drop table #abom;";
                IsoDateTimeConverter iso = new IsoDateTimeConverter();
                iso.DateTimeFormat = "yyyy-MM-dd";
                info = dal.ExecuteQuery(string.Format(str_sql, htid, khid, jsid), out dataSet);

                dataSet.Tables[0].TableName = "zb";
                dataSet.Tables[1].TableName = "mx";
                if (info == "")
                {
                    response.Write(JsonConvert.SerializeObject(dataSet, iso));
                    response.End();
                }
                else
                {
                    response.Write(string.Format(@"{{""type"":""ERROR"",""msg"":""{0}""}}", info));
                    response.End();
                }
            }
        }
    }

    /// <summary>
    /// 将汉字转换为Unicode
    /// </summary>
    /// <param name="text">要转换的字符串</param>
    /// <returns></returns>
    public static string GBToUnicode(string text)
    {
        byte[] bytes = System.Text.Encoding.Unicode.GetBytes(text);
        string lowCode = "", temp = "";
        for (int i = 0; i < bytes.Length; i++)
        {
            if (i % 2 == 0)
            {
                temp = System.Convert.ToString(bytes[i], 16);//取出元素4编码内容（两位16进制）
                if (temp.Length < 2) temp = "0" + temp;
            }
            else
            {
                string mytemp = Convert.ToString(bytes[i], 16);
                if (mytemp.Length < 2) mytemp = "0" + mytemp; lowCode = lowCode + @"\u" + mytemp + temp;//取出元素4编码内容（两位16进制）
            }
        }
        return lowCode;
    }
    public bool IsReusable
    {
        get
        {
            return false;
        }
    }
    /// <summary>
    /// 根据图片exif调整方向
    /// </summary>
    /// <param name="sm"></param>
    /// <returns></returns>
    public static Image RotateImage(Stream sm)
    {
        Image img = Image.FromStream(sm);
        PropertyItem[] exif = img.PropertyItems;
        byte orien = 0;
        foreach (PropertyItem i in exif)
        {
            if (i.Id == 274)
            {
                orien = i.Value[0];
                i.Value[0] = 1;
                img.SetPropertyItem(i);
            }
        }

        switch (orien)
        {
            case 2:
                img.RotateFlip(RotateFlipType.RotateNoneFlipX);//horizontal flip
                break;
            case 3:
                img.RotateFlip(RotateFlipType.Rotate180FlipNone);//right-top
                break;
            case 4:
                img.RotateFlip(RotateFlipType.RotateNoneFlipY);//vertical flip
                break;
            case 5:
                img.RotateFlip(RotateFlipType.Rotate90FlipX);
                break;
            case 6:
                img.RotateFlip(RotateFlipType.Rotate90FlipNone);//right-top
                break;
            case 7:
                img.RotateFlip(RotateFlipType.Rotate270FlipX);
                break;
            case 8:
                img.RotateFlip(RotateFlipType.Rotate270FlipNone);//left-bottom
                break;
            default:
                break;
        }
        foreach (PropertyItem i in exif)
        {
            if (i.Id == 40962)
            {
                i.Value = BitConverter.GetBytes(img.Width);
            }
            else if (i.Id == 40963)
            {
                i.Value = BitConverter.GetBytes(img.Height);
            }

        }
        return img;
    }
}



