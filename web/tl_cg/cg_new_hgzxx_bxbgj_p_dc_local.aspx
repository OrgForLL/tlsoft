<%@ Page Language="C#" ValidateRequest="false" %>

<%@ Import Namespace="System.Data" %>
<%@ Import Namespace="System.Data.SqlClient" %>
<%@ Import Namespace="System.Data" %>
<%@ Import Namespace="NPOI.HSSF.UserModel" %>
<%@ Import Namespace="NPOI.SS.UserModel" %>
<%@ Import Namespace="System.IO" %>
<%@ Import Namespace="nrWebClass" %>


<script runat="server">
    ArrayList sheet1TableTop = new ArrayList(new string[] { "���ݺ�", "ӡˢ��", "ִ�б�׼", "��ȫ�������", "Ь��", "����", "Ʒ��", "����", "���", "�ȼ�", "����", "�̱�", "��ɫ", "ͳһ���ۼ�", "������", "����", "���ϱ��", "��������", "ʹ�ô洢", "����������" });
    ArrayList sheet1TableSqlMc = new ArrayList(new string[] { "djh", "khmc", "zxbz", "jslb", "xx", "sphh", "pm", "hx", "gg", "dj", "jy", "sb", "spmc", "lsdj", "bztm", "sl0", "chdm", "cpksrq", "store", "����������" });
    ArrayList sheet2TableTop = new ArrayList(new string[] { "��ά��", "Ψһ��" });
    ArrayList sheet2TableSqlMc = new ArrayList(new string[] { "jm", "spid" });
    ArrayList sheet3TableTop = new ArrayList(new string[] { "����", "������ͼƬ" });
    ArrayList sheet3TableSqlMc = new ArrayList(new string[] { "sphh", "������ͼƬ" });
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
        sxtb.Add(0, "���ϴ���¶�40����ϴ");
        sxtb.Add(1, "����ˮϴ");
        sxtb.Add(2, "���ϴ���¶�30�泣��ˮϴ");
        sxtb.Add(3, "���ϴ���¶�30�滺��ˮϴ");
        sxtb.Add(4, "���ϴ���¶�30��ǳ�����ˮϴ");
        sxtb.Add(5, " ���ϴ���¶�40�泣��ˮϴ");
        sxtb.Add(6, " ���ϴ���¶�40�滺��ˮϴ");
        sxtb.Add(7, "�����κ�Ư�׼�");
        sxtb.Add(8, "��������Ư�����Ư");
        sxtb.Add(9, "����Ư��");
        sxtb.Add(10, "��������");
        sxtb.Add(11, "���ҵθ�");
        sxtb.Add(12, "ƽ̯����");
        sxtb.Add(13, "ƽ̯�θ�");
        sxtb.Add(14, "��������������");
        sxtb.Add(15, "���������ҵθ�");
        sxtb.Add(16, "������ƽ̯����");
        sxtb.Add(17, "������ƽ̯�θ�");
        sxtb.Add(18, "����������¶�60�淭ת����");
        sxtb.Add(19, "���ɷ�ת����");
        sxtb.Add(20, "�ٶ��װ�����¶�110��");
        sxtb.Add(21, "�ٶ��װ�����¶�150��");
        sxtb.Add(22, "�ٶ��װ�����¶�200��");
        sxtb.Add(23, "��������");
        sxtb.Add(24, "�����ϴ");
        sxtb.Add(25, "���͸�ϴ");
        sxtb.Add(26, "���ɸ�ϴ");
        sxtb.Add(27, "רҵʪϴ");
        sxtb.Add(28, "רҵ��ϴ");


        string sql = @"            
             select  d.tm,g.pm,1 as sl0,gz.chdm,f.chdm as xsbhh,ysc.khmc,convert(varchar(12),f.rq,112) as tbbs,f.dsqk,b.splbdm,a.mxid,f.id as syid,a.id,a.zdr,f.shqk as xdff,a.rq,
               a.djh,a.sphh,b.dw,b.tml,b.lsdj,a.sl as zsl,b.spmc,isnull(e.tm,'1') as bztm,g.zxbz,g.dj,isnull(k.hx,'')  as hx, 
               isnull(k.gg,'') as gg,isnull(k.xx,'') as xx,h.mc as jslb,CASE WHEN ISNULL(ht.cpksrq, '') = '' THEN ''ELSE CONVERT(VARCHAR(10), ht.cpksrq, 120) END AS cpksrq ,
               te.store,case isnull(gb.sfbh,0) when 0 then '����ӡ' else '��ӡ' end  as �Ƿ���ʾ���,gb.mc ����������,ISNULL(gb.sytj,'') ������ͼƬ,
               pic.urladdress
             into #myzb 
             from yx_V_dddjcmmx a 
             inner join yx_v_spdmb b on  a.sphh=b.sphh and b.tzid='@zbid'
             inner join yx_T_ypdmb yp on yp.yphh=b.yphh
             left  join Yf_T_bjdbjzb gb on gb.id=yp.bhks
             inner join yx_t_cmzh c  on b.tml=c.tml and a.cmdm=c.cmdm  --������
             inner join (select * from yx_t_tmb where tzid=1  and tmlx=2) d ON c.cmdm= d.cmdm and c.tzid=d.tzid and a.sphh=d.sphh  --����
             inner join (select * from yx_t_tmb where tzid=1  and tmlx=1) e ON c.cmdm= e.cmdm and c.tzid=e.tzid and a.sphh=e.sphh   --��׼����
             inner join yf_T_bjdlb f on f.lxid=903 and a.lymxid=f.id and f.tzid='@zbid' --ʵ����ϴˮ��
             inner join (select a.bz as dj,a.id as zbid,a.mc as pm,b.mc as zxbz from Yf_T_bjdbjzb a,Yf_T_bjdbjzb b where a.ssid=b.id and a.lx=903 ) g on f.tplx=g.zbid  --ִ�б�׼
             inner join Yf_T_bjdbjzb h on h.lx=905 and f.sylx=h.id and h.tzid='@zbid' --��ȫ�������

             left  join yx_V_sphxggb k on k.yphh=b.yphh and c.cmdm=k.cmdm 
             left  join yf_v_rinsingtemplate te on te.id=f.lydjid  

             inner join cl_T_sygzb gz on a.id=gz.lymxid and gz.gzlx='@gzlx' --Ʒ�ʴ���        
             left  join (SELECT  ht.sphh,max(ht.cpksrq) cpksrq  FROM  zw_v_cphtddmx ht  GROUP BY ht.sphh) ht on  ht.sphh=a.sphh 
             left  join yx_T_khb ysc on gz.khid=ysc.khid  --ӡˢ��
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
             inner Join yx_T_spidb spid on a.id=spid.lydjid And a.tm=spid.tm --ӡˢ��
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
             select sytjid as cmdm,'��ά����'+convert(char(10),sytjid) as mc 
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
            //�ɷ���
            DataTable cfColumn = DSdata.Tables[3];
            //�ɷ�λ��
            int cfIndex = sheet1TableTop.IndexOf("����");
            for (int i = 0; i < cfColumn.Rows.Count; i++)
            {
                cfIndex++;
                sheet1TableTop.Insert(cfIndex, DSdata.Tables[3].Rows[i]["mc"].ToString());
                sheet1TableSqlMc.Insert(cfIndex, "");
            }

            string fileName = "�ϸ�֤���ɽ��µ�(" + DateTime.Now.ToString("yyyyMMddhhmmss") + ").xls";
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
    /// ����sheet3
    /// </summary>
    /// <param name="hssfWorkbook">Ҫ����sheet�Ĺ�����</param>
    /// <param name="sheetName">sheet����</param>
    /// <param name="sheetTableTop">sheet��ͷ</param>
    /// <param name="sheetTableSqlMc">sheet��ͷ��Ӧ��sql�ֶ�����</param>
    /// <param name="sheetData">sheet����</param>
    /// <returns></returns>
    public HSSFWorkbook CreateSheet3AndSetData(HSSFWorkbook hssfWorkbook, string sheetName, ArrayList sheetTableTop, ArrayList sheetTableSqlMc, DataSet sheetData)
    {
        ISheet sheet = hssfWorkbook.CreateSheet(sheetName);
        sheet.SetColumnWidth(0, 20 * 256);
        sheet.SetColumnWidth(1, 18 * 256);
        // ��ӱ�ͷ
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

        // �������           
        for (int i = 0; i < sphhTable.Rows.Count; i++)
        {
            index = 0;
            row = sheet.CreateRow(i + 1);
            foreach (string item in sheetTableTop)
            {
                switch (sheetTableSqlMc[index].ToString())
                {
                    case "������ͼƬ": //ͼƬ��ַ
                        DataRow dr0 = cmTable.Select("sphh='" + sphhTable.Rows[i]["sphh"].ToString() + "'")[0];

                        string imgPath = dr0["������ͼƬ"].ToString();
                        if (imgPath == "") continue;
                        row.Height = 80 * 20;
                        if (imgPath.IndexOf("../") != -1)
                        {
                            imgPath = Server.MapPath("/" + imgPath.Replace("../", ""));
                        }
                        //��ͼƬ�ļ�����һ���ַ���
                        byte[] bytes = File.ReadAllBytes(imgPath);
                        int pictureIdx = hssfWorkbook.AddPicture(bytes, PictureType.JPEG);
                        HSSFPatriarch patriarch = (HSSFPatriarch)sheet.CreateDrawingPatriarch();
                        // ��ͼƬ��λ��  HSSFClientAnchor��dx1,dy1,dx2,dy2,col1,row1,col2,row2) ������������
                        HSSFClientAnchor anchor = new HSSFClientAnchor(0, 0, 0, 0, index, i + 1, index + 1, i + 2);
                        //��ͼƬ�嵽��Ӧ��λ��
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
    /// ����sheet2
    /// </summary>
    /// <param name="hssfWorkbook">Ҫ����sheet�Ĺ�����</param>
    /// <param name="sheetName">sheet����</param>
    /// <param name="sheetTableTop">sheet��ͷ</param>
    /// <param name="sheetTableSqlMc">sheet��ͷ��Ӧ��sql�ֶ�����</param>
    /// <param name="sheetData">sheet����</param>
    /// <returns></returns>
    public HSSFWorkbook CreateSheet2AndSetData(HSSFWorkbook hssfWorkbook, string sheetName, ArrayList sheetTableTop, ArrayList sheetTableSqlMc, DataSet sheetData)
    {
        ISheet sheet = hssfWorkbook.CreateSheet(sheetName);
        sheet.SetColumnWidth(0, 50 * 256);
        sheet.SetColumnWidth(1, 20 * 256);
        // ��ӱ�ͷ
        IRow row = sheet.CreateRow(0);
        int index = 0;
        foreach (string item in sheetTableTop)
        {
            ICell cell = row.CreateCell(index);
            cell.SetCellType(CellType.String);
            cell.SetCellValue(item);
            index++;
        }
        // �������           
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
    /// ����sheet1
    /// </summary>
    /// <param name="hssfWorkbook">Ҫ����sheet�Ĺ�����</param>
    /// <param name="sheetName">sheet����</param>
    /// <param name="sheetTableTop">sheet��ͷ</param>
    /// <param name="sheetTableSqlMc">sheet��ͷ��Ӧ��sql�ֶ�����</param>
    /// <param name="sheetData">sheet����</param>
    /// <returns></returns>
    public HSSFWorkbook CreateSheet1AndSetData(HSSFWorkbook hssfWorkbook, string sheetName, ArrayList sheetTableTop, ArrayList sheetTableSqlMc, DataSet sheetData)
    {
        //��������
        DataTable cmTable = sheetData.Tables[0];
        //�ɷ���
        DataTable cfColumn = sheetData.Tables[3];
        //�ɷ�����
        DataTable cfTable = sheetData.Tables[2];
        //Ψһ��
        DataTable spidTable = sheetData.Tables[1];

        //ˮϴͼ��
        DataTable sxtpTable = sheetData.Tables[4];

        ISheet sheet = hssfWorkbook.CreateSheet(sheetName);

        // ��ӱ�ͷ
        IRow row = sheet.CreateRow(0);
        int index = 0;
        foreach (string item in sheetTableTop)
        {
            ICell cell = row.CreateCell(index);
            cell.SetCellType(CellType.String);
            cell.SetCellValue(item);
            index++;
        }

        //��Ψһ��Ҳ��ʾ
        foreach (string item in sheet2TableTop)
        {
            ICell cell = row.CreateCell(index);
            cell.SetCellType(CellType.String);
            cell.SetCellValue(item);
            index++;
        }

        //�ɷ�λ��
        int cfIndex = sheetTableTop.IndexOf("����");
        // �������    
        int iRow = 1;
        for (int i = 0; i < cmTable.Rows.Count; i++)
        {
            DataRow[] spidDR = spidTable.Select("id=" + cmTable.Rows[i]["id"].ToString() + " and tm='" + cmTable.Rows[i]["tm"].ToString() + "'");
            //�п�ʼ
            foreach (DataRow spidDr in spidDR)
            {
                index = 0;
                row = sheet.CreateRow(iRow);

                //��Ψһ����
                foreach (string item in sheetTableTop)
                {
                    ICell cell = row.CreateCell(index);
                    cell.SetCellType(CellType.String);
                    if (index >= (cfIndex + 1) && index < (cfIndex + 1 + cfColumn.Rows.Count))
                    {
                        //����ɷ�
                        DataRow[] drs = cfTable.Select("syid='" + cmTable.Rows[i]["syid"].ToString() + "' and cmdm='" + cfColumn.Rows[index - (cfIndex + 1)]["cmdm"] + "'");
                        cell.SetCellValue(drs[0]["mxsz"].ToString());
                    }
                    else
                    {
                        switch (sheetTableSqlMc[index].ToString())
                        {
                            case "jy": //����
                                cell.SetCellValue("�ϸ�");
                                break;
                            case "sb": //�̱�
                                cell.SetCellValue("����");
                                break;
                            case "spmc": //��ɫ
                                string[] ys = cmTable.Rows[i]["" + sheetTableSqlMc[index]].ToString().Split('-');
                                cell.SetCellValue(ys[ys.Length - 1]);
                                break;
                            default:
                                cell.SetCellValue(cmTable.Rows[i]["" + sheetTableSqlMc[index]].ToString());
                                break;
                        }

                    }
                    index++;
                }//��Ψһ����end

                //����Ψһ��
                ICell jmCell = row.CreateCell(index);
                jmCell.SetCellType(CellType.String);
                jmCell.SetCellValue(spidDr["jm"].ToString());
                index++;
                ICell spidCell = row.CreateCell(index);
                spidCell.SetCellType(CellType.String);
                spidCell.SetCellValue(spidDr["spid"].ToString());
                index++;
                //����Ψһ��end

                //����ͼ��                
                //int sxIndex = 0;
                //foreach (DataRow dr in sxtpTable.Select("syid=" + cmTable.Rows[i]["syid"].ToString()))
                //{
                //    ICell sxtpCell = row.CreateCell(index);
                //    int pictureIdx = getSxHssf(int.Parse(dr["pdjg"].ToString()), hssfWorkbook);
                //    HSSFPatriarch patriarch = (HSSFPatriarch)sheet.CreateDrawingPatriarch();
                //    // ��ͼƬ��λ��  HSSFClientAnchor��dx1,dy1,dx2,dy2,col1,row1,col2,row2) ������������
                //    HSSFClientAnchor anchor = new HSSFClientAnchor(0, 0, 0, 0, iRow+sxIndex, index, iRow+sxIndex + 1, index + 1);
                //    //��ͼƬ�嵽��Ӧ��λ��
                //    HSSFPicture pict = (HSSFPicture)patriarch.CreatePicture(anchor, pictureIdx);
                //    sxIndex++;
                //}
                //index++;
                //����ͼ��end

                iRow++;
            }//�п�ʼ����
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
            string imgPath = "../tl_yf/sxtb/09��/" + sxtb[pathIndex] + ".gif";
            if (imgPath.IndexOf("../") != -1)
            {
                imgPath = Server.MapPath("/" + imgPath.Replace("../", ""));
            }
            //��ͼƬ�ļ�����һ���ַ���
            byte[] bytes = File.ReadAllBytes(imgPath);
            int pictureIdx = hssfWorkbook.AddPicture(bytes, PictureType.JPEG);
            sxHssf.Add(pathIndex, pictureIdx);
            return pictureIdx;
        }
    }


</script>
