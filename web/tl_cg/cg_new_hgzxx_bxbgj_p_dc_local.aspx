<%@ Page Language="C#" ValidateRequest="false" %>

<%@ Import Namespace="System.Data" %>
<%@ Import Namespace="System.Data.SqlClient" %>
<%@ Import Namespace="System.Data" %>
<%@ Import Namespace="NPOI.HSSF.UserModel" %>
<%@ Import Namespace="NPOI.SS.UserModel" %>
<%@ Import Namespace="System.IO" %>
<%@ Import Namespace="nrWebClass" %>


<script runat="server">
    ArrayList sheet1TableTop = new ArrayList(new string[] { "单据号", "印刷厂", "执行标准", "安全技术类别", "鞋型", "货号", "品名", "号型", "规格", "等级", "检验", "商标", "颜色", "统一零售价", "国际码", "数量", "材料编号", "生产日期", "使用存储", "版型贴名称" });
    ArrayList sheet1TableSqlMc = new ArrayList(new string[] { "djh", "khmc", "zxbz", "jslb", "xx", "sphh", "pm", "hx", "gg", "dj", "jy", "sb", "spmc", "lsdj", "bztm", "sl0", "chdm", "cpksrq", "store", "版型贴名称" });
    ArrayList sheet2TableTop = new ArrayList(new string[] { "二维码", "唯一码" });
    ArrayList sheet2TableSqlMc = new ArrayList(new string[] { "jm", "spid" });
    ArrayList sheet3TableTop = new ArrayList(new string[] { "货号", "版型贴图片" });
    ArrayList sheet3TableSqlMc = new ArrayList(new string[] { "sphh", "版型贴图片" });
    DataSet DSdata = new DataSet();
    
    public System.Collections.Generic.Dictionary<int, string> sxtb = new System.Collections.Generic.Dictionary<int, string>();
    public System.Collections.Generic.Dictionary<int, int> sxHssf = new System.Collections.Generic.Dictionary<int, int>();

    protected void Page_Load(object sender, EventArgs e)
    {
        string gzlx = "";
        Session["userssid"] = "1";
        Session["zbid"] = "1";
        string tzid = Session["userssid"].ToString();
        string zbid = Session["zbid"].ToString();
        string xzlx = Request["xzlx"];
        string str_tj = Request["str_tj"];
        string gzlx0 = Request["gzlx0"];
        if (gzlx0 == "20") gzlx = "2010";
        sxtb.Add(0, "最高洗涤温度40℃手洗");
        sxtb.Add(1, "不可水洗");
        sxtb.Add(2, "最高洗涤温度30℃常规水洗");
        sxtb.Add(3, "最高洗涤温度30℃缓和水洗");
        sxtb.Add(4, "最高洗涤温度30℃非常缓和水洗");
        sxtb.Add(5, " 最高洗涤温度40℃常规水洗");
        sxtb.Add(6, " 最高洗涤温度40℃缓和水洗");
        sxtb.Add(7, "允许任何漂白剂");
        sxtb.Add(8, "仅允许氧漂或非氯漂");
        sxtb.Add(9, "不可漂白");
        sxtb.Add(10, "悬挂晾干");
        sxtb.Add(11, "悬挂滴干");
        sxtb.Add(12, "平摊晾干");
        sxtb.Add(13, "平摊滴干");
        sxtb.Add(14, "阴凉处悬挂晾干");
        sxtb.Add(15, "阴凉处悬挂滴干");
        sxtb.Add(16, "阴凉处平摊晾干");
        sxtb.Add(17, "阴凉处平摊滴干");
        sxtb.Add(18, "排气口最高温度60℃翻转干燥");
        sxtb.Add(19, "不可翻转干燥");
        sxtb.Add(20, "熨斗底板最高温度110℃");
        sxtb.Add(21, "熨斗底板最高温度150℃");
        sxtb.Add(22, "熨斗底板最高温度200℃");
        sxtb.Add(23, "不可熨烫");
        sxtb.Add(24, "常规干洗");
        sxtb.Add(25, "缓和干洗");
        sxtb.Add(26, "不可干洗");
        sxtb.Add(27, "专业湿洗");
        sxtb.Add(28, "专业干洗");


        string sql = @"            
             select  d.tm,g.pm,1 as sl0,gz.chdm,f.chdm as xsbhh,ysc.khmc,convert(varchar(12),f.rq,112) as tbbs,f.dsqk,b.splbdm,a.mxid,f.id as syid,a.id,a.zdr,f.shqk as xdff,a.rq,
               a.djh,a.sphh,b.dw,b.tml,b.lsdj,a.sl as zsl,b.spmc,isnull(e.tm,'1') as bztm,g.zxbz,g.dj,isnull(k.hx,'')  as hx, 
               isnull(k.gg,'') as gg,isnull(k.xx,'') as xx,h.mc as jslb,CASE WHEN ISNULL(ht.cpksrq, '') = '' THEN ''ELSE CONVERT(VARCHAR(10), ht.cpksrq, 120) END AS cpksrq ,
               te.store,case isnull(gb.sfbh,0) when 0 then '不打印' else '打印' end  as 是否显示规格,gb.mc 版型贴名称,ISNULL(gb.sytj,'') 版型贴图片,
               pic.urladdress
             into #myzb 
             from yx_V_dddjcmmx a 
             inner join yx_v_spdmb b on  a.sphh=b.sphh and b.tzid='@zbid'
             inner join yx_T_ypdmb yp on yp.yphh=b.yphh
             left  join Yf_T_bjdbjzb gb on gb.id=yp.bhks
             inner join yx_t_cmzh c  on b.tml=c.tml and a.cmdm=c.cmdm  --条码规格
             inner join (select * from yx_t_tmb where tzid=1  and tmlx=2) d ON c.cmdm= d.cmdm and c.tzid=d.tzid and a.sphh=d.sphh  --条码
             inner join (select * from yx_t_tmb where tzid=1  and tmlx=1) e ON c.cmdm= e.cmdm and c.tzid=e.tzid and a.sphh=e.sphh   --标准条码
             inner join yf_T_bjdlb f on f.lxid=903 and a.lymxid=f.id and f.tzid='@zbid' --实验室洗水标
             inner join (select a.bz as dj,a.id as zbid,a.mc as pm,b.mc as zxbz from Yf_T_bjdbjzb a,Yf_T_bjdbjzb b where a.ssid=b.id and a.lx=903 ) g on f.tplx=g.zbid  --执行标准
             inner join Yf_T_bjdbjzb h on h.lx=905 and f.sylx=h.id and h.tzid='@zbid' --安全技术类别

             left  join yx_V_sphxggb k on k.yphh=b.yphh and c.cmdm=k.cmdm 
             left  join yf_v_rinsingtemplate te on te.id=f.lydjid  

             inner join cl_T_sygzb gz on a.id=gz.lymxid and gz.gzlx='@gzlx' --品质代码        
             left  join (SELECT  ht.sphh,max(ht.cpksrq) cpksrq  FROM  zw_v_cphtddmx ht  GROUP BY ht.sphh) ht on  ht.sphh=a.sphh 
             left  join yx_T_khb ysc on gz.khid=ysc.khid  --印刷厂
             left join (
				 SELECT x2.sphh,min(ISNULL(x1.urladdress, '')) urladdress 
				 FROM t_uploadfile x1 
				 INNER JOIN ( 
					SELECT  y1.zlmxid,sp.sphh FROM   yx_t_ypdmb y1 inner join yx_T_spdmb sp on y1.yphh=sp.yphh   
				 ) x2 ON x1.tableid = x2.zlmxid AND x1.groupid = 1003
				 where ISNULL(x1.urladdress, '')<>''
				 GROUP BY x2.sphh
             ) pic on pic.sphh=a.sphh 
             where a.djlx=905 @str_tj   

             --table0
             SELECT a.*
			 from #myzb a		

             --table1
             SELECT DISTINCT a.id,a.tm, a.rq,a.djh,a.sphh,'http://tm.lilanz.com/tm.aspx?id='+dbo.f_EBPwd(spid.spid) as jm,spid.spid,a.urladdress
             FROM #myzb a 
             inner Join yx_T_spidb spid on a.id=spid.lydjid And a.tm=spid.tm --印刷厂
             order by a.rq,a.djh,a.sphh

             --table2
             select c.mxid as syid,c.*,c.sytjid as cmdm,case when isnull(c.sz,'')='/' or isnull(c.pdjg,'')='' then c.sz else c.pdjg+':'+c.sz end as mxsz 
             from yx_V_dddjmx a 
             inner join yf_T_bjdlb b on b.lxid=903 and a.lymxid=b.id and b.tzid='@zbid'  
             inner join yf_T_bjdmxb c on b.id=c.mxid  and c.bzzid<3 
             inner join cl_T_sygzb gz on a.id=gz.lymxid and gz.gzlx='@gzlx' 
             inner join (
                select a.bz as dj,a.id as zbid,a.mc as pm,b.mc as zxbz 
                from Yf_T_bjdbjzb a,Yf_T_bjdbjzb b where a.ssid=b.id and a.lx=903 
             ) g on b.tplx=g.zbid 
             where b.tzid='@zbid' @str_tj 
             order  by c.mxid

             --table3
             select sytjid as cmdm,'纤维含量'+convert(char(10),sytjid) as mc 
             from yf_T_bjdmxb a 
             where  a.lxid='903' and a.bzzid<3 and a.mxid=(
                  select top 1  a.id from (select a.mxid,b.id,count(bzzid) as sl  
                  from yx_V_dddjmx a 
                  inner join yf_T_bjdlb b on b.lxid=903 and a.lymxid=b.id and a.tzid='@zbid'  
                  inner join yf_T_bjdmxb c on b.id=c.mxid and c.bzzid>=0 
                  inner join cl_T_sygzb gz on a.id=gz.lymxid and gz.gzlx='@gzlx' 
                  inner join (
                      select a.bz as dj,a.id as zbid,a.mc as pm,b.mc as zxbz 
                      from Yf_T_bjdbjzb a,Yf_T_bjdbjzb b where a.ssid=b.id and a.lx=903 
                  ) g on b.tplx=g.zbid where b.lxid=903  and c.bzzid<3  @str_tj  
                  group by a.mxid,b.id 
               ) a order by sl desc
             ) order by id

            --table4
            SELECT a.id syid, c.icodm as pdjg FROM yf_t_bjdlb a
			INNER JOIN yf_v_rinsingtemplate b ON   a.lydjid  =b.id
			INNER JOIN yf_v_rinsingtemplateico c ON c.mxid=b.id  
            inner join (select distinct a.syid from #myzb a ) xz on xz.syid=a.id
             order by a.id,CAST(c.icodm AS INT)
 
        ";
        sql = sql.Replace("@zbid", zbid)
                 .Replace("@gzlx", gzlx)
                 .Replace("@str_tj", str_tj);
        string DBConnStr = "server='192.168.35.10';uid=ABEASD14AD;pwd=+AuDkDew;database=tlsoft";
        using (LiLanzDALForXLM sqlHelp = new LiLanzDALForXLM(tzid))
        {
            sqlHelp.ConnectionString = DBConnStr;
            string errStr = sqlHelp.ExecuteQuery(sql, out DSdata);
            if (errStr != "")
            {
                Response.Write(errStr);
                Response.End();
            }
            //成份列
            DataTable cfColumn = DSdata.Tables[3];
            //成份位置
            int cfIndex = sheet1TableTop.IndexOf("检验");
            for (int i = 0; i < cfColumn.Rows.Count; i++)
            {
                cfIndex++;
                sheet1TableTop.Insert(cfIndex, DSdata.Tables[3].Rows[i]["mc"].ToString());
                sheet1TableSqlMc.Insert(cfIndex, "");
            }

            string fileName = "合格证不干胶下单(" + DateTime.Now.ToString("yyyyMMddhhmmss") + ").xls";
            string filePath = Server.MapPath("../MyUpload/" + fileName);

            HSSFWorkbook hssfworkbook = new HSSFWorkbook();
            hssfworkbook = CreateSheet1AndSetData(hssfworkbook, "Sheet1", sheet1TableTop, sheet1TableSqlMc, DSdata);
            //hssfworkbook = CreateSheet2AndSetData(hssfworkbook, "Sheet2", sheet2TableTop, sheet2TableSqlMc, DSdata);
            hssfworkbook = CreateSheet3AndSetData(hssfworkbook, "Sheet3", sheet3TableTop, sheet3TableSqlMc, DSdata);

            FileStream fs = new FileStream(filePath, FileMode.Create);
            hssfworkbook.Write(fs);
            fs.Close();

            Response.Clear();
            Response.Buffer = true;
            Response.ContentType = "application/excel";
            Response.Charset = "UTF-8";
            Response.ContentEncoding = Encoding.UTF8;
            Response.AddHeader("Content-Disposition", "inline;filename=" + HttpUtility.UrlEncode(fileName, Encoding.UTF8));
            Response.WriteFile(filePath);
            Response.Flush();
            if (File.Exists(filePath)) File.Delete(filePath);
            Response.End();

        }
    }


    /// <summary>
    /// 创建sheet3
    /// </summary>
    /// <param name="hssfWorkbook">要创建sheet的工作簿</param>
    /// <param name="sheetName">sheet名称</param>
    /// <param name="sheetTableTop">sheet表头</param>
    /// <param name="sheetTableSqlMc">sheet表头对应的sql字段名称</param>
    /// <param name="sheetData">sheet数据</param>
    /// <returns></returns>
    public HSSFWorkbook CreateSheet3AndSetData(HSSFWorkbook hssfWorkbook, string sheetName, ArrayList sheetTableTop, ArrayList sheetTableSqlMc, DataSet sheetData)
    {
        ISheet sheet = hssfWorkbook.CreateSheet(sheetName);
        sheet.SetColumnWidth(0, 20 * 256);
        sheet.SetColumnWidth(1, 18 * 256);
        // 添加表头
        IRow row = sheet.CreateRow(0);
        int index = 0;
        foreach (string item in sheetTableTop)
        {
            ICell cell = row.CreateCell(index);
            cell.SetCellType(CellType.String);
            cell.SetCellValue(item);
            index++;
        }
        DataTable cmTable = sheetData.Tables[0];
        DataView dv = cmTable.DefaultView;
        DataTable sphhTable = dv.ToTable("Dist", true, "sphh");

        // 添加数据           
        for (int i = 0; i < sphhTable.Rows.Count; i++)
        {
            index = 0;
            row = sheet.CreateRow(i + 1);
            foreach (string item in sheetTableTop)
            {
                switch (sheetTableSqlMc[index].ToString())
                {
                    case "版型贴图片": //图片地址
                        DataRow dr0 = cmTable.Select("sphh='" + sphhTable.Rows[i]["sphh"].ToString() + "'")[0];

                        string imgPath = dr0["版型贴图片"].ToString();
                        if (imgPath == "") continue;
                        row.Height = 80 * 20;
                        if (imgPath.IndexOf("../") != -1)
                        {
                            imgPath = Server.MapPath("/" + imgPath.Replace("../", ""));
                        }
                        //将图片文件读入一个字符串
                        byte[] bytes = File.ReadAllBytes(imgPath);
                        int pictureIdx = hssfWorkbook.AddPicture(bytes, PictureType.JPEG);
                        HSSFPatriarch patriarch = (HSSFPatriarch)sheet.CreateDrawingPatriarch();
                        // 插图片的位置  HSSFClientAnchor（dx1,dy1,dx2,dy2,col1,row1,col2,row2) 后面再作解释
                        HSSFClientAnchor anchor = new HSSFClientAnchor(0, 0, 0, 0, index, i + 1, index + 1, i + 2);
                        //把图片插到相应的位置
                        HSSFPicture pict = (HSSFPicture)patriarch.CreatePicture(anchor, pictureIdx);
                        break;
                    default:
                        ICell cell = row.CreateCell(index);
                        cell.SetCellType(CellType.String);
                        cell.SetCellValue(sphhTable.Rows[i]["sphh"].ToString());
                        break;
                }
                index++;
            }
        }
        return hssfWorkbook;
    }

    /// <summary>
    /// 创建sheet2
    /// </summary>
    /// <param name="hssfWorkbook">要创建sheet的工作簿</param>
    /// <param name="sheetName">sheet名称</param>
    /// <param name="sheetTableTop">sheet表头</param>
    /// <param name="sheetTableSqlMc">sheet表头对应的sql字段名称</param>
    /// <param name="sheetData">sheet数据</param>
    /// <returns></returns>
    public HSSFWorkbook CreateSheet2AndSetData(HSSFWorkbook hssfWorkbook, string sheetName, ArrayList sheetTableTop, ArrayList sheetTableSqlMc, DataSet sheetData)
    {
        ISheet sheet = hssfWorkbook.CreateSheet(sheetName);
        sheet.SetColumnWidth(0, 50 * 256);
        sheet.SetColumnWidth(1, 20 * 256);
        // 添加表头
        IRow row = sheet.CreateRow(0);
        int index = 0;
        foreach (string item in sheetTableTop)
        {
            ICell cell = row.CreateCell(index);
            cell.SetCellType(CellType.String);
            cell.SetCellValue(item);
            index++;
        }
        // 添加数据           
        for (int i = 0; i < sheetData.Tables[1].Rows.Count; i++)
        {
            index = 0;
            row = sheet.CreateRow(i + 1);
            foreach (string item in sheetTableTop)
            {
                ICell cell = row.CreateCell(index);
                cell.SetCellType(CellType.String);
                cell.SetCellValue(sheetData.Tables[1].Rows[i]["" + sheetTableSqlMc[index]].ToString());
                index++;
            }
        }
        return hssfWorkbook;
    }

    /// <summary>
    /// 创建sheet1
    /// </summary>
    /// <param name="hssfWorkbook">要创建sheet的工作簿</param>
    /// <param name="sheetName">sheet名称</param>
    /// <param name="sheetTableTop">sheet表头</param>
    /// <param name="sheetTableSqlMc">sheet表头对应的sql字段名称</param>
    /// <param name="sheetData">sheet数据</param>
    /// <returns></returns>
    public HSSFWorkbook CreateSheet1AndSetData(HSSFWorkbook hssfWorkbook, string sheetName, ArrayList sheetTableTop, ArrayList sheetTableSqlMc, DataSet sheetData)
    {
        //尺码数据
        DataTable cmTable = sheetData.Tables[0];
        //成份列
        DataTable cfColumn = sheetData.Tables[3];
        //成份数据
        DataTable cfTable = sheetData.Tables[2];
        //唯一码
        DataTable spidTable = sheetData.Tables[1];

        //水洗图标
        DataTable sxtpTable = sheetData.Tables[4];

        ISheet sheet = hssfWorkbook.CreateSheet(sheetName);

        // 添加表头
        IRow row = sheet.CreateRow(0);
        int index = 0;
        foreach (string item in sheetTableTop)
        {
            ICell cell = row.CreateCell(index);
            cell.SetCellType(CellType.String);
            cell.SetCellValue(item);
            index++;
        }

        //把唯一码也显示
        foreach (string item in sheet2TableTop)
        {
            ICell cell = row.CreateCell(index);
            cell.SetCellType(CellType.String);
            cell.SetCellValue(item);
            index++;
        }

        //成份位置
        int cfIndex = sheetTableTop.IndexOf("检验");
        // 添加数据    
        int iRow = 1;
        for (int i = 0; i < cmTable.Rows.Count; i++)
        {
            DataRow[] spidDR = spidTable.Select("id=" + cmTable.Rows[i]["id"].ToString() + " and tm='" + cmTable.Rows[i]["tm"].ToString() + "'");
            //行开始
            foreach (DataRow spidDr in spidDR)
            {
                index = 0;
                row = sheet.CreateRow(iRow);

                //非唯一码列
                foreach (string item in sheetTableTop)
                {
                    ICell cell = row.CreateCell(index);
                    cell.SetCellType(CellType.String);
                    if (index >= (cfIndex + 1) && index < (cfIndex + 1 + cfColumn.Rows.Count))
                    {
                        //处理成份
                        DataRow[] drs = cfTable.Select("syid='" + cmTable.Rows[i]["syid"].ToString() + "' and cmdm='" + cfColumn.Rows[index - (cfIndex + 1)]["cmdm"] + "'");
                        cell.SetCellValue(drs[0]["mxsz"].ToString());
                    }
                    else
                    {
                        switch (sheetTableSqlMc[index].ToString())
                        {
                            case "jy": //检验
                                cell.SetCellValue("合格");
                                break;
                            case "sb": //商标
                                cell.SetCellValue("利郎");
                                break;
                            case "spmc": //颜色
                                string[] ys = cmTable.Rows[i]["" + sheetTableSqlMc[index]].ToString().Split('-');
                                cell.SetCellValue(ys[ys.Length - 1]);
                                break;
                            default:
                                cell.SetCellValue(cmTable.Rows[i]["" + sheetTableSqlMc[index]].ToString());
                                break;
                        }

                    }
                    index++;
                }//非唯一码列end

                //增加唯一码
                ICell jmCell = row.CreateCell(index);
                jmCell.SetCellType(CellType.String);
                jmCell.SetCellValue(spidDr["jm"].ToString());
                index++;
                ICell spidCell = row.CreateCell(index);
                spidCell.SetCellType(CellType.String);
                spidCell.SetCellValue(spidDr["spid"].ToString());
                index++;
                //增加唯一码end

                //增加图标                
                //int sxIndex = 0;
                //foreach (DataRow dr in sxtpTable.Select("syid=" + cmTable.Rows[i]["syid"].ToString()))
                //{
                //    ICell sxtpCell = row.CreateCell(index);
                //    int pictureIdx = getSxHssf(int.Parse(dr["pdjg"].ToString()), hssfWorkbook);
                //    HSSFPatriarch patriarch = (HSSFPatriarch)sheet.CreateDrawingPatriarch();
                //    // 插图片的位置  HSSFClientAnchor（dx1,dy1,dx2,dy2,col1,row1,col2,row2) 后面再作解释
                //    HSSFClientAnchor anchor = new HSSFClientAnchor(0, 0, 0, 0, iRow+sxIndex, index, iRow+sxIndex + 1, index + 1);
                //    //把图片插到相应的位置
                //    HSSFPicture pict = (HSSFPicture)patriarch.CreatePicture(anchor, pictureIdx);
                //    sxIndex++;
                //}
                //index++;
                //增加图标end

                iRow++;
            }//行开始结束
        }
        return hssfWorkbook;
    }

    public int getSxHssf(int pathIndex, HSSFWorkbook hssfWorkbook)
    {
        if (sxHssf.ContainsKey(pathIndex))
        {
            return sxHssf[pathIndex];
        }
        else
        {
            string imgPath = "../tl_yf/sxtb/09版/" + sxtb[pathIndex] + ".gif";
            if (imgPath.IndexOf("../") != -1)
            {
                imgPath = Server.MapPath("/" + imgPath.Replace("../", ""));
            }
            //将图片文件读入一个字符串
            byte[] bytes = File.ReadAllBytes(imgPath);
            int pictureIdx = hssfWorkbook.AddPicture(bytes, PictureType.JPEG);
            sxHssf.Add(pathIndex, pictureIdx);
            return pictureIdx;
        }
    }


</script>
