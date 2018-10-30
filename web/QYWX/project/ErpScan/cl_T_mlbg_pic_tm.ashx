<%@ WebHandler Language="C#" Class="sphhinfo" Debug="true" %>

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

public class sphhinfo : IHttpHandler, IRequiresSessionState
{

    public void ProcessRequest(HttpContext context)
    {

        HttpRequest request = context.Request;
        HttpResponse response = context.Response;
        response.ContentType = "text/plain"; //如果返回给客户端的是 json数据时， 设置ContentType="application/json"
        string OAConnStr = clsConfig.GetConfigValue("OAConnStr");
        string action = request.Form["action"].ToString();

        if (action == "picUpload")
        {
            string djhids = request.Form["djhids"].ToString();
            string tmid = request.Form["tmid"].ToString();
            string tmlx = request.Form["tmlx"].ToString();
            HttpFileCollection files = request.Files; //客户端上传的文件
            if (files.Count > 0)
            {
                HttpPostedFile file = files.Get(0);

                string tail = ""; //文件名尾
                if (file.FileName.LastIndexOf('.') < 0)
                {
                    tail = ".jpg";
                }
                else
                {
                    tail = Path.GetExtension(file.FileName);
                }

                Stream stream = file.InputStream;
                byte[] bytes = null;
                Image img = RotateImage(stream);
                ImageConverter imgconv = new ImageConverter();
                bytes = (byte[])imgconv.ConvertTo(img, typeof(byte[]));

                HttpWebRequest myRequest = null;
                if (request.Url.AbsoluteUri.IndexOf("192.168.35.231") == -1)
                {
                    myRequest = (HttpWebRequest)WebRequest.Create("http://webt.lilang.com:9001/service/cl_T_mlbg_pic.ashx");
                }
                else
                {
                    myRequest = (HttpWebRequest)WebRequest.Create("http://192.168.35.231/service/cl_T_mlbg_pic.ashx");
                }
                myRequest.Method = "POST";
                myRequest.Headers.Add("djhids", djhids);
                myRequest.Headers.Add("tmid", tmid);
                myRequest.Headers.Add("tmlx", tmlx);
                myRequest.Headers.Add("tail", tail);
                myRequest.Headers.Add("FileSize", bytes.Length + "");
                using (Stream newStream = myRequest.GetRequestStream())
                {
                    // Send the data. 
                    newStream.Write(bytes, 0, bytes.Length);
                    newStream.Close();
                }


                // Get response 
                HttpWebResponse myResponse = (HttpWebResponse)myRequest.GetResponse();
                StreamReader sreader = new StreamReader(myResponse.GetResponseStream(), Encoding.GetEncoding("GB2312"));
                string content = sreader.ReadToEnd();


                response.Write(content);
                response.End();
            }
            else
            {
                response.Write(string.Format(@"{{""type"":""ERROR"",""msg"":""未选择文件""}}"));
                response.End();
            }
        }
        else if (action == "getmsg")
        {
            string tm = request.Form["tm"].ToString();
            string tag = request.Form["tag"].ToString();
            int djid = int.Parse(tm.Split('$')[0].ToString());
            int djlx = int.Parse(tm.Split('$')[1].ToString());
            DataSet dataSet = null;
            using (LiLanzDALForXLM dal = new LiLanzDALForXLM(1))
            {
                string info;
                string str_sql;
                if (tag == "1")
                {//上传
                    str_sql = @"
                    SELECT A.id,A.djlx,ch.chdm,ch.chmc,e.id as id2222,e.mxid mxid2222,e.djh,e.sl,e.khid,e.jyid,E.id as mykey,md.mdms  into #myzb
                    FROM yf_T_mldsb A 
                    INNER JOIN dbo.yf_T_mldsmx B ON A.ID=B.ID
                    INNER JOIN dbo.CL_T_chdmb ch ON ch.chdm=b.chdm
                    INNER JOIN dbo.cl_v_jhdjmxb E ON E.CHDM=B.CHDM AND E.DJLX=2222 AND jylx=517 and DATEDIFF(month,e.rq,GETDATE())<=3 and isnull(e.jyid,0)=0
                    and e.bjlx<>2
                    left outer join (
						  select sum(sl) as mdms,id,max(xgrq) xgrq   from wl_t_dddjpmmx group by id
					 ) md on e.id=md.id    
                    WHERE A.ID={0} AND A.DJLX={1};
                  ";
                }
                else
                {//查询
                    str_sql = @"
                    declare @cpjjs VARCHAR(500) 
                    select @cpjjs=SUBSTRING(cpjj,1,2)+CASE WHEN CHARINDEX('冬',cpjj)>0 THEN 'd' WHEN CHARINDEX('秋',cpjj)>0 THEN 'q' WHEN CHARINDEX('春',cpjj)>0 THEN 'cx'  WHEN CHARINDEX('夏',cpjj)>0 THEN 'cx'  end from yf_T_mldsb   where   ID={0} AND DJLX={1}

                    SELECT cpjj INTO #cpjj 
                    FROM ( 
                       SELECT  cpjj= SUBSTRING(@cpjjs,1,2)+'春季' WHERE CASE  WHEN SUBSTRING(@cpjjs,3,2)='cx' THEN 1 ELSE 0 END =1 
                        UNION  
                       SELECT  cpjj=SUBSTRING(@cpjjs,1,2)+'夏季' WHERE CASE  WHEN SUBSTRING(@cpjjs,3,2)='cx' THEN 1 ELSE 0 END =1 
                        UNION  
                        SELECT  cpjj=SUBSTRING(@cpjjs,1,2)+'秋季' WHERE CASE  WHEN SUBSTRING(@cpjjs,3,2)='q' THEN 1 ELSE 0 END =1 
                        UNION  
                       SELECT  cpjj=SUBSTRING(@cpjjs,1,2)+'冬季' WHERE CASE  WHEN SUBSTRING(@cpjjs,3,2)='d' THEN 1 ELSE 0 END =1 
                     ) a 

                    SELECT A.id,A.djlx,ch.chdm,ch.chmc,e.id as id2222,e.mxid mxid2222,e.djh,e.sl,e.khid,e.jyid,E.id as mykey,md.mdms  into #myzb
                    FROM yf_T_mldsb A 
                    INNER JOIN dbo.yf_T_mldsmx B ON A.ID=B.ID
                    INNER JOIN dbo.CL_T_chdmb ch ON ch.chdm=b.chdm
                    inner join #cpjj jj on 1=1 
                    INNER JOIN dbo.cl_v_jhdjmxb E ON E.CHDM=B.CHDM AND E.DJLX=2222 AND jylx=517 and  isnull(e.jyid,0)<>0 and jj.cpjj=e.cpjj
                    and e.bjlx<>2
                    left outer join (
						  select sum(sl) as mdms,id,max(xgrq) xgrq   from wl_t_dddjpmmx group by id
					 ) md on e.id=md.id    
                    WHERE A.ID={0} AND A.DJLX={1};
                ";
                }
                str_sql += @"        
                    select c.id2222,gzh.gzh as scddbh,sp.sku into #sku
                    from #myzb c 
                    inner join cl_T_jhdjgzhb gzh on gzh.id=c.id2222 and gzh.mxid=c.mxid2222
                    inner join yx_T_spcgjhb jh on jh.cggzh=gzh.gzh
                    inner join yx_T_spdmb sp on sp.sphh=jh.sphh and sp.tzid=1

                    select sp.id2222,sp.scddbh,s.sxrq,kh.khmc into #sxrq
                    from #sku sp
                    inner join yx_v_jhdjmxnew s on   s.sphh=sp.sku
                    inner join yx_T_khb kh on kh.khid=s.khid;

                    SELECT isnull(F.bgbh,'无') as bgbh,CONVERT(varchar(100),f.rq, 20) AS bgrq,e.id2222,E.djh,kh.khmc,e.chdm,e.chmc,e.sl,sxrq.jgckhmc,sxrq.scddbh,isnull(F.ID,'') AS DJID,isnull(F.DDID,'') as syid,
                    Replace(Rtrim((SELECT DISTINCT a.URLAddress+ ' ' FROM dbo.t_uploadfile a inner JOIN #myzb zb ON ','+createname+',' LIKE ','+CONVERT(CHAR(50),zb.id2222)+',' AND a.TableID = zb.id WHERE zb.djh = E.djh FOR XML PATH (''))), ' ', ',') AS URLAddress,E.mdms,E.mykey
                    FROM #myzb E  
				    left  join (
				       select r.id2222,Replace(Rtrim((SELECT distinct scddbh+ ' ' FROM   #sxrq WHERE  ( ID2222 = r.ID2222 ) FOR XML PATH (''))), ' ', ',') AS scddbh,Replace(Rtrim((SELECT distinct khmc+ ' ' FROM   #sxrq WHERE  ( ID2222 = r.ID2222 ) FOR XML PATH (''))), ' ', ',') AS jgckhmc
				       from  #sxrq r group by r.id2222 
				    ) sxrq on e.id2222=sxrq.id2222 
                    INNER JOIN dbo.yx_t_khb KH ON KH.khid=e.khid                    
                    LEFT JOIN dbo.Yf_T_bjdlb F ON F.ID=E.jyid             

                    SELECT DISTINCT a.filename ,a.urladdress,b.djh  FROM t_uploadfile a inner join #myzb b on a.TableID = b.jyid   WHERE a.GroupID='1005'  ;
                    
                    SELECT ISNULL(Replace(Rtrim((SELECT DISTINCT a.URLAddress+ ' ' FROM dbo.t_uploadfile a inner JOIN #myzb zb ON ','+createname+',' LIKE ','+CONVERT(CHAR(50),zb.id2222)+',' AND a.TableID = zb.id WHERE zb.id = e.id FOR XML PATH (''))), ' ', ','),'') AS totalURLAddress FROM #myzb E  
					
                    drop table #myzb; drop table #sku;drop table #sxrq;
                    ";

                info = dal.ExecuteQuery(string.Format(str_sql, djid, djlx), out dataSet);
                dataSet.Tables[0].TableName = "bjd";
                dataSet.Tables[1].TableName = "bjd_img";
                dataSet.Tables[2].TableName = "totalURL";
                if (info == "")
                {
                    if (dataSet.Tables[0].Rows.Count == 0)
                    {
                        response.Write(string.Format(@"{{""type"":""ERROR"",""msg"":""条码信息无效""}}"));
                        response.End();
                    }
                    else
                    {
                        response.Write(string.Format(@"{{""type"":""SUCCESS"",""msg"":""{0}""}}", GBToUnicode(JsonConvert.SerializeObject(dataSet))));
                        response.End();
                    }
                }
                else
                {
                    response.Write(string.Format(@"{{""type"":""ERROR"",""msg"":""{0}""}}", info));
                    response.End();
                }

            }
        }
        else
        {
            response.Write(string.Format(@"{{""type"":""ERROR"",""msg"":""无效行为""}}"));
            response.End();
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



