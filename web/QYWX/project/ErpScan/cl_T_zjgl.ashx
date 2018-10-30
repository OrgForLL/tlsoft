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
        string action = request["action"].ToString();
        string str_sql = "";
        string info = "";

        if (action == "search")
        {
            string dzdfj = "", ksrq = "", jsrq = "", shbs = "", khmc = "";

            string OAConnStr = clsConfig.GetConfigValue("OAConnStr");
            bool isInit = bool.Parse(request["isInit"].ToString());
            if (isInit)
            {
                response.Write("");
                response.End();
            }
            if (request["dzdfj"].ToString() != "")
            {
                dzdfj = request["dzdfj"].ToString();
            }
            ksrq = request["ksrq"].ToString();
            jsrq = request["jsrq"].ToString();
            if (request["dzdfj"].ToString() != "")
            {
                dzdfj = request["dzdfj"].ToString();
            }
            if (request["shbs"].ToString() != "")
            {
                shbs = "and a.shbs='" + request["shbs"].ToString() + "'";
            }
            if (request["khmc"].ToString() != "")
            {
                khmc = "and b.khmc like '%" + request["khmc"].ToString() + "%'";
            }
            DataSet dataSet = null;
            using (LiLanzDALForXLM dal = new LiLanzDALForXLM(1))
            {
                str_sql = @"
                       if '{0}'='1' 
                             begin
                             select a.id,a.djh,b.khdm+'.'+b.khmc khmc,a.fkje,a.skje,a.fkje-a.skje ce,a.bz,a.zdr,a.rq,a.yfye,a.k3zdrq,wts.sqjsrq
                             ,case a.shbs when 1 then '已审' else '未审' end shbs ,a.shr,a.shrq,sum(c.je) k3ye,k3ce=isnull(a.fkje,0)-isnull(sum(c.je),0),
                             (select count(1) from ghs_t_zldamxb where zd = 'ghs_dzd' and mlid = a.id) dzdgs,isnull(wts.fjs,0) as wtssl,wts.id as wtsid 
                              from zw_t_gyswldzd a inner join yx_t_khb b on a.khid=b.khid 
                              left join zw_t_k3ye c on a.id=c.lyid
                               left join  (select   s.khid,s.id,count(1) as fjs,s.sqksrq,s.sqjsrq ,row_number()over(partition by s.khid order by s.id desc) as xh
                                 from yx_t_sqwts s 
                                  inner join t_uploadfile fj on s.id=fj.tableid and fj.groupid=105 
                                  group by s.khid,s.id,s.sqksrq,s.sqjsrq)wts 
                               on wts.khid=a.khid /* and wts.sqksrq<=a.ksrq and wts.sqjsrq>=a.jsrq*/ and wts.xh=1  
                             where a.tzid='1' and a.zdrq>='{1}' and a.zdrq<dateadd(d,1,'{2}') {3} {4}
                             and a.id in (select distinct a.id from zw_t_gyswldzd a inner join ghs_t_zldamxb b on a.id=b.mlid and b.zd='ghs_dzd' where a.tzid='1' 
                             and a.zdrq>='{1}' and a.zdrq<dateadd(d,1,'{2}') {3}) 
                              group by a.id,a.djh,b.khdm,b.khmc,a.fkje,a.skje,a.fkje,a.skje,a.bz,a.zdr,a.rq,a.yfye,a.shbs,a.shr,a.shrq,a.k3zdrq,wts.fjs,wts.id,wts.sqjsrq
                             order by a.djh,a.rq
                             end else if '{0}'='0'
                             begin
                             select a.id,a.djh,b.khdm+'.'+b.khmc khmc,a.fkje,a.skje,a.fkje-a.skje ce,a.bz,a.zdr,a.rq,a.yfye,a.k3zdrq,wts.sqjsrq
                             ,case a.shbs when 1 then '已审' else '未审' end shbs ,a.shr,a.shrq,sum(c.je) k3ye,k3ce=isnull(a.fkje,0)-isnull(sum(c.je),0),
                             (select count(1) from ghs_t_zldamxb where zd = 'ghs_dzd' and mlid = a.id) dzdgs,isnull(wts.fjs,0) as wtssl,wts.id as wtsid 
                              from zw_t_gyswldzd a inner join yx_t_khb b on a.khid=b.khid 
                              left join zw_t_k3ye c on a.id=c.lyid 
                               left join  (select   s.khid,s.id,count(1) as fjs,s.sqksrq,s.sqjsrq ,row_number()over(partition by s.khid order by s.id desc) as xh
                                 from yx_t_sqwts s 
                                  inner join t_uploadfile fj on s.id=fj.tableid and fj.groupid=105 
                                  group by s.khid,s.id,s.sqksrq,s.sqjsrq)wts 
                              on wts.khid=a.khid /*and wts.sqksrq<=a.ksrq and wts.sqjsrq>=a.jsrq*/ and wts.xh=1  
                             where a.tzid='1' and a.zdrq>='{1}' and a.zdrq<dateadd(d,1,'{2}') {3} {4}
                             and a.id not in (select distinct a.id from zw_t_gyswldzd a inner join ghs_t_zldamxb b on a.id=b.mlid and b.zd='ghs_dzd' where a.tzid='1' 
                             and a.zdrq>='{1}' and a.zdrq<dateadd(d,1,'{2}') {3})  
                              group by a.id,a.djh,b.khdm,b.khmc,a.fkje,a.skje,a.fkje,a.skje,a.bz,a.zdr,a.rq,a.yfye,a.shbs,a.shr,a.shrq,a.k3zdrq,wts.fjs,wts.id ,wts.sqjsrq
                             order by a.djh,a.rq
                             end else
                             begin 
                             select a.id,right('000000'+convert(varchar,a.djh),6) as djh,b.khdm+'.'+b.khmc khmc,a.fkje,a.skje,a.fkje-a.skje ce,a.bz,a.zdr,a.rq,a.yfye,a.k3zdrq,wts.sqjsrq
                             ,case a.shbs when 1 then '已审' else '未审' end shbs ,a.shr,a.shrq,sum(c.je) k3ye,k3ce=isnull(a.fkje,0)-isnull(sum(c.je),0),
                             (select count(1) from ghs_t_zldamxb where zd = 'ghs_dzd' and mlid = a.id) dzdgs,isnull(wts.fjs,0) as wtssl,wts.id as wtsid 
                              from zw_t_gyswldzd a inner join yx_t_khb b on a.khid=b.khid 
                              left join zw_t_k3ye c on a.id=c.lyid
                               left join (select   s.khid,s.id,count(1) as fjs,s.sqksrq,s.sqjsrq ,row_number()over(partition by s.khid order by s.id desc) as xh
                                 from yx_t_sqwts s 
                                  inner join t_uploadfile fj on s.id=fj.tableid and fj.groupid=105 
                                  group by s.khid,s.id,s.sqksrq,s.sqjsrq)wts 
                              on wts.khid=a.khid /*and wts.sqksrq<=a.ksrq and wts.sqjsrq>=a.jsrq*/ and wts.xh=1  
                             where a.tzid='1' and a.zdrq>='{1}' and a.zdrq<dateadd(d,1,'{2}') {3}  {4}
                              group by a.id,a.djh,b.khdm,b.khmc,a.fkje,a.skje,a.fkje,a.skje,a.bz,a.zdr,a.rq,a.yfye,a.shbs,a.shr,a.shrq,a.k3zdrq,wts.fjs,wts.id ,wts.sqjsrq
                             order by a.djh,a.rq
                             end;";
                IsoDateTimeConverter iso = new IsoDateTimeConverter();
                iso.DateTimeFormat = "yyyy-MM-dd";
                info = dal.ExecuteQuery(string.Format(str_sql, dzdfj, ksrq, jsrq, shbs, khmc), out dataSet);
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
            string id = request["id"].ToString();
            string userid = request["userid"].ToString();
            using (LiLanzDALForXLM dal = new LiLanzDALForXLM(1))
            {
                str_sql = "update zw_t_gyswldzd set shbs=1,shr=(select cname from t_user where id =" + userid + "),shrq=getdate() where isnull(shbs,0)=0 and id=" + id;
                info = dal.ExecuteNonQuery(str_sql);
                if (info != "-1")
                {
                    response.Write(string.Format(@"{{""type"":""SUCCESS"",""msg"":""{0}""}}", info));
                    response.End();
                }
            }
        }
        else if (action == "mx")
        {
            string id = request["id"].ToString();
            string userid = request["userid"].ToString();
            DataSet dataSet = null;
            using (LiLanzDALForXLM dal = new LiLanzDALForXLM(1))
            {
                str_sql = @"
                       select  a.id,a.djh,a.khid,a.khmc,a.fkje,a.skje,a.ce,a.bz,a.rq,a.tmje,a.shbs,a.zdr,a.k3ye,a.dzdsc,a.showI,a.ksrq,a.jsrq,a.yfye,a.shr,a.nbbz,a.xgbs
                        ,case when isnull(a.email,'')='' then us.email+'/'+us.QQno else a.email end as email,case when isnull(a.cz,'')='' then us.yddh else a.cz end  as  cz
                        ,case when isnull(a.dh,'')='' then us.lxdh else a.dh end  as dh,t_zdr.id as zdrid
                        from (
                        select a.id,a.djh,a.khid,b.khdm+'.'+b.khmc khmc,a.fkje,a.skje,a.fkje-a.skje ce,a.bz,a.rq,a.yfye,a.fkje tmje
                         ,case a.shbs when 1 then '已审' else '未审' end shbs ,a.zdr,'K3余额' k3ye
                         , a.email,'对账单上传' dzdsc
                         ,'请先选择对帐客户！' showI
                         ,a.ksrq,a.jsrq,a.dh
                         ,a.cz,a.shr,a.nbbz,xgbs=1
                          from zw_t_gyswldzd a inner join yx_t_khb b on a.khid=b.khid 
                         where a.tzid='1' and a.id='{0}'
                        )a
                          left join t_user  us on us.id='{1}'
                          inner join t_user t_zdr on a.zdr = t_zdr.cname";
                IsoDateTimeConverter iso = new IsoDateTimeConverter();
                iso.DateTimeFormat = "yyyy-MM-dd";
                info = dal.ExecuteQuery(string.Format(str_sql, id, userid), out dataSet);
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
        else if (action == "upd")
        {
            string ksrq = request["ksrq"].ToString();
            string jsrq = request["jsrq"].ToString();
            string skje = request["skje"].ToString();
            string fkje = request["fkje"].ToString();
            string khid = request["khid"].ToString();
            string bz = request["bz"].ToString();
            string nbbz = request["nbbz"].ToString();
            string rq = request["rq"].ToString();
            string yfye = request["yfye"].ToString();
            string email = request["email"].ToString();
            string dh = request["dh"].ToString();
            string cz = request["cz"].ToString();
            string id = request["id"].ToString();
            string userid = request["id"].ToString();
            string tmje = request["tmje"].ToString();
            using (LiLanzDALForXLM dal = new LiLanzDALForXLM(1))
            {
                str_sql = "declare @djh int,@tmdjh int,@zdr varchar(20);";
                    
                str_sql += "select @zdr=cname from t_user where id=" + userid + ";";

                str_sql += "select @djh=isnull(max(djh),0)+1 from zw_t_gyswldzd where tzid=1 and convert(char(6),rq,112)=convert(char(6),convert(datetime,'" + rq + "'),112);";

                str_sql += "select @tmdjh=max(djh)+1 from zw_t_gyswldzd where tzid=1 and convert(char(6),rq,112)<>convert(char(6),convert(datetime,'" + rq + "'),112) and id=" + id + ";";

                str_sql += "update zw_t_gyswldzd set ksrq='" + ksrq + "',jsrq='" + jsrq + "',skje='" + skje + "',fkje='" + fkje + "'";
                str_sql += " ,khid='" + khid + "',bz='" + bz + "',nbbz='" + nbbz + "',rq='" + rq + "',xgr=@zdr,yfye='" + yfye + "',email='" + email + "'";
                if (tmje == "0") { str_sql += ",zdr=@zdr"; }
                str_sql += ",xgrq=getdate(),dh='" + dh + "',cz='" + cz + "',djh=case when @tmdjh is null then djh else @djh end where id=" + id;
                str_sql += " update a set a.yfye=dbo.kh_yfye(tzid,khid,ksrq,jsrq) from zw_t_gyswldzd a where id="+id;
                info = dal.ExecuteNonQuery(str_sql);
                if (info != "-1")
                {
                    response.Write(string.Format(@"{{""type"":""SUCCESS"",""msg"":""{0}""}}", info));
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



