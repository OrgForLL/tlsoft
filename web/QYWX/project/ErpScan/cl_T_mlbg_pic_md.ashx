<%@ WebHandler Language="C#" Class="cl_T_mlbg_pic_md" Debug="true" %>

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

public class cl_T_mlbg_pic_md : IHttpHandler, IRequiresSessionState
{
    public void ProcessRequest(HttpContext context)
    {

        HttpRequest request = context.Request;
        HttpResponse response = context.Response;
        response.ContentType = "text/plain"; //如果返回给客户端的是 json数据时， 设置ContentType="application/json"
        string OAConnStr = clsConfig.GetConfigValue("OAConnStr");
        string mykey = request["mykey"].ToString();
        DataSet dataSet = null;
        using (LiLanzDALForXLM dal = new LiLanzDALForXLM(1))
        {
            string info;
            string str_sql;
            str_sql = @"
                      select  b.pmid,dh.djh,SUM(c.sl)sl INTO #tpm
                      from cl_v_jhdjmxb a 
                      inner join wl_t_dddjpmmx b on a.id=b.id and a.djlx=b.djlx and a.mxid=b.mxid
                      inner join cl_t_wldhmd c on c.pmid=b.pmid and c.lydjlx=0  
                      INNER JOIN dbo.CL_T_dddjb dh ON dh.id=c.dhid
                      where a.id={0}  
                      GROUP BY b.pmid,dh.djh 

                      select b.ph,b.sphh,b.mc,b.jh,b.kz,b.fk,b.gh,a.chdm,c.chmc,a.cggzh,b.ys,b.sl,b.bz,ISNULL(fs.pdjg,'') pdjg,isnull(bz.bzsl,0),dh.dhts,b.qtj khqtj,b.qtw khqtw,b.sxj khsxj,b.sxw khsxw
                      from cl_v_jhdjmxb a 
                      inner join wl_t_dddjpmmx b on a.id=b.id and a.djlx=b.djlx and a.mxid=b.mxid
                      inner join cl_t_chdmb c on a.chdm=c.chdm
                      left join dbo.Yf_T_bjdlb d on  a.jyid=d.id
                      left join (
                        select max(pdjg) pdjg,lydjid,lydjlx,scddbh,ph,gh,ms from yf_t_mlspfsmx group by lydjid,lydjlx,scddbh,ph,gh,ms 
                      ) fs on d.id=fs.lydjid and d.lxid=fs.lydjlx and a.cggzh=fs.scddbh and b.ph=fs.ph and b.gh=fs.gh and b.sl=fs.ms
                      left join (
                        select  b.pmid ,sum(c.sl) bzsl
                        from cl_v_jhdjmxb a 
                        inner join wl_t_dddjpmmx b on a.id=b.id and a.djlx=b.djlx and a.mxid=b.mxid
                        inner join cl_t_wldhmd c on c.pmid=b.pmid and c.lydjlx=2380    
                        where a.id={0} 
                        group by b.pmid
                      )bz on bz.pmid=b.pmid
                      left join(
                       SELECT pmid, 
                       Replace(Rtrim((SELECT djh+','+CAST(sl AS VARCHAR(max))+ ' ' FROM   #tpm WHERE  ( pmid = r.pmid ) FOR XML PATH (''))), ' ', '; ') AS dhts 
                       FROM  #tpm r    GROUP  BY pmid
                      )dh on dh.pmid=b.pmid
                      where a.id={0}
                      order by   case  when  ISNUMERIC(b.ph) = 1 AND CHARINDEX(',', b.ph) = 0 AND CHARINDEX('\', b.ph) = 0 then CONVERT(DECIMAL(20, 3), b.ph) else 0 end";
        info = dal.ExecuteQuery(string.Format(str_sql, mykey), out dataSet);
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



