<%@ Page Language="C#" AutoEventWireup="true" Debug="true" %>

<%@ Import Namespace="System.Data.SqlClient" %>
<%@ Import Namespace="System.Data" %>
<%@ Import Namespace="System.Collections.Generic" %>

<script runat="server">
    public string action = "";
    public string xqcppldm = "";
    public string xqcpplName = "";
    Dictionary<string, string> winRtn, btRtn, tpRtn, heRtn, sdrRtn, gyRtn, mxjlRrn, blrRtn;
    public nrWebClass.LiLanzDAL sqlhelper = new nrWebClass.LiLanzDAL();
    public string sql = "", mypic = "0";
    public string xmjl = "", sjzj = "", sptc = "", mlgcs = "", mlkfjl = "";
    SqlDataReader sdr, bt, tp, he, gy, blr;
    int jls, pds;
    DataTable dst = new DataTable();
    public string mtitle = "";
    System.Collections.Generic.Dictionary<string, string> myFlowDic;
    protected void Page_Load(object sender, EventArgs e)
    {
        sqlhelper.ConnectionString = "server='192.168.35.10';uid=ABEASD14AD;pwd=+AuDkDew;database=tlsoft ";
        action = Request["action"];
        string id = Request["id"];
        if (id.Length > 0 && action.Equals("cx"))
        {

            winRtn = new Dictionary<string, string>();
            sql = "  select top 1 * from( ";
            sql += " select 1 as xh,b.djlx,b.lbgcs_sfjc,b.xmjl_yj,b.xmjl_khid,xmjl.khmc as xmjl_khmc,b.tcjl_yy,b.lbgcs_yy,a.yyt as shdm1,b.tcjl_ghsid,e.mc as shmc1,cast(a.bjbs as varchar(2)) as sh, cast(node.cs as varchar(10)) as currentNode,cast(a.id as varchar(10)) as id,b.gcsjl_zysx,b.lbgcs_ljxq,convert(varchar(10),b.lbgcs_wcsj,120) lbgcs_wcsj,b.lbgcs_dw,cast(b.lbgcs_jg as varchar(10))lbgcs_jg,cast(b.lbgcs_kbfy as varchar(10))lbgcs_kbfy,REPLACE(b.lbgcs_gzjh,char(13)+char(10),'<br>') lbgcs_gzjh ,REPLACE(B.lbgcs_lsyq,char(13)+char(10),'<br>') lbgcs_lsyq ,REPLACE(B.lbgcs_hzyq,char(13)+char(10),'<br>')lbgcs_hzyq ,";
            sql += " REPLACE(b.lbgcs_zysx,CHAR(13) + CHAR(10), '<br>') lbgcs_zysx ,convert(varchar(10),b.qrrq,120) as qrrq,case when b.qrbs=1 then '��ȷ��' else 'δȷ��' end qrzt,b.tcjl_ljxq,b.yybh,b.sjzj_xmgy,b.sjzj_xmgy1,b.xmjl_ks,convert(varchar(10),b.xmjl_xqrq,120) xmjl_xqrq ,cast(a.mxid as varchar(10))mxid,b.xmjl,cast(b.cylb as varchar(5)) as cypl,tckh.khmc as tckhmc,cast(b.khid as varchar(10)) ghsid,";
            sql += " kh.khmc as ghsmc,d.mc as cyplmc,b.mlcf,b.gg,b.jgfw,b.bdh,b.gyyq,c.dm as shdm,c.mc as shmc,case when a.xq_1='0' then '' else a.xq_1 end xmsx_1,case when a.xq_2='0' then '' else a.xq_2 end xmsx_2,case when a.xq_3='0' then '' else a.xq_3 end xmsx_3,";
            sql += " case when a.xq_4='0' then '' else a.xq_4 end xmsx_4,case when a.xq_5='0' then '' else a.xq_5 end xmsx_5,case when a.xq_6='0' then '' else a.xq_6 end xmsx_6,case when a.jcsl='0' then '' else jcsl end jcsl,case when cast(a.xq_1 as decimal(10,2))+cast(a.xq_2 as decimal(10,2))+cast(a.xq_3 as decimal(10,2))+cast(a.xq_4 as decimal(10,2))+cast(a.xq_5 as decimal(10,2))+cast(a.xq_6 as decimal(10,2))+cast(a.jcsl as float)=0 then '' else cast(cast(a.xq_1 as decimal(10,2))+cast(a.xq_2 as decimal(10,2))+cast(a.xq_3 as decimal(10,2))+cast(a.xq_4 as decimal(10,2))+cast(a.xq_5 as decimal(10,2))+cast(a.xq_6 as decimal(10,2))+cast(a.jcsl as decimal(10,2)) as varchar(10)) end  as hj ";
            sql += " from yf_t_mlkfxqb b inner join yf_t_mlkfxqmxb a on b.id=a.id left join yx_t_shdmb c on a.yyt=c.dm left join yx_t_khb kh on b.khid=kh.khid ";
            sql += " left join YX_T_Splb d on b.cylb=d.id left join  fl_t_flowRelation doc on b.id=doc.dxid and b.flowid=doc.flowid left join fl_t_nodeConfig  node on doc.currentNode=node.nodeid  and node.flowid=doc.flowid";
            sql += " left join yx_t_khb  xmjl on b.xmjl_khid = xmjl.khid ";
            sql += " left join yx_t_khb tckh on b.tcjl_ghsid=tckh.khid left join yx_t_shdmb e on a.sjxgt=e.dm where a.bjbs<>-1 and  b.id=" + id + " ";
            sql += " union all";
            sql += "    select top 1 2 as xh,0 djlx,'' lbgcs_sfjc,'' as xmjl_yj,-1 as xmjl_khid,'' as xmjl_khmc,'' as tcjl_yy,'' as lbgcs_yy,'' as shdm1,-1 as tcjl_ghsid,'' shmc1,'' sh, '' currentNode,'' id,'' as gcsjl_zysx,null as qrrq,'' as qrzt,'' lbgcs_ljxq,null lbgcs_wcsj,'' lbgcs_dw,'' lbgcs_jg,'' lbgcs_kbfy,'' lbgcs_gzjh,'' lbgcs_lsyq,'' lbgcs_hzyq,";
            sql += " '' lbgcs_zysx, ''tcjl_ljxq,''yybh,''sjzj_xmgy,''sjzj_xmgy1,''xmjl_ks,null xmjl_xqrq,'' mxid,''xmjl,'' cypl,'' tckhmc, '' ghsid,";
            sql += " ''ghsmc,''cyplmc,''mlcf,''gg,''jgfw,''bdh,''gyyq,'' shdm,''shmc,''xmsx_1,''xmsx_2,''xmsx_3,";
            sql += " ''xmsx_4,''xmsx_5,''xmsx_6,'' jcsl,''hj from yx_t_khb a)a order by xh";
            sdr = sqlhelper.ExecuteReader(sql);
            sdr.Read();
            for (int i = 0; i < sdr.FieldCount; i++)
            {
                if (sdr.HasRows == false)
                {
                    string str = "";
                    winRtn.Add(sdr.GetName(i), (str));
                }
                else
                {
                    winRtn.Add(sdr.GetName(i), sdr[i].ToString());
                }
            }
            sdr.Close();
            if (winRtn["djlx"] == "12341")
            {
                mtitle = "�����������з��滮";
            }
            else if (winRtn["djlx"] == "12330")
            {
                mtitle = "��Ʒ�������з�";
            }
            else if (winRtn["djlx"] == "12342")
            {
                mtitle = "�߷������Ͽ���";
            }else if (winRtn["djlx"] == "2130")
            {
                mtitle = "�쳣������";
            }
        }
        sql = "declare @hs int;select @hs=count(*) from yf_t_mlkfxqmxb a left join yx_t_shdmb g on a.yyt=g.dm left join yx_t_shdmb h on a.sjxgt=h.dm where a.bjbs<>-1 and a.id=" + id;
        sql += " select top (case when (select @hs)<10 then 10 else (select @hs) end) '��ɫ'+cast(row_number()over(order by xh)as varchar(2)) as xh2, * from (";
        sql += "  select 1 as xh,case when cast(a.xq_1 as decimal(10,2))+cast(a.xq_2 as decimal(10,2))+cast(a.xq_3 as decimal(10,2))+cast(a.xq_4 as decimal(10,2))+cast(a.xq_5 as decimal(10,2))+cast(a.xq_6 as decimal(10,2))+cast(a.jcsl as decimal(10,2))=0 then '' else cast(cast(a.xq_1 as decimal(10,2))+cast(a.xq_2 as decimal(10,2))+cast(a.xq_3 as decimal(10,2))+cast(a.xq_4 as decimal(10,2))+cast(a.xq_5 as decimal(10,2))+cast(a.xq_6 as decimal(10,2))+cast(a.jcsl as decimal(10,2)) as varchar(10)) end  as hj ,a.yyt as shdm,a.sjxgt as shdm1,a.bjbs as sh,a.mxid,g.mc as shmc,h.mc as shmc1,case when a.xq_1='0' then '' else a.xq_1 end xmsx_1,case when a.xq_2='0' then '' else a.xq_2 end xmsx_2,case when a.xq_3='0' then '' else a.xq_3 end xmsx_3,case when a.xq_4='0' then '' else a.xq_4 end xmsx_4,case when a.xq_5='0' then '' else a.xq_5 end xmsx_5,case when a.xq_6='0' then '' else a.xq_6 end xmsx_6,case when a.jcsl='0'then '' else a.jcsl end jcsl from yf_t_mlkfxqmxb a ";
        sql += "  left join yx_t_shdmb g on a.yyt=g.dm left join yx_t_shdmb h on a.sjxgt=h.dm  ";
        sql += "  where a.bjbs<>-1 and a.id=" + id;
        sql += "  union all ";
        sql += "  select top (case when (select @hs)<10 then 10 else (select @hs) end) 2 as xh,'' as hj,''shdm,''shdm1,''sh,''mxid,''shmc,''shmc1,''xmsx_1,''xmsx_2,''xmsx_3,''xmsx_4,''xmsx_5,''xmsx_6,'' jcsl  from yx_t_khb";
        sql += ") a ";
        dst = sqlhelper.ExecuteDataTable(sql);
        jls = dst.Rows.Count;
        if (id.Length > 0 && action.Equals("cx"))
        {
            sql = " select top 1 * from (  select 1 as xh,a.mxid,'' as shdm,'ͼƬ' as tp,'��ɫ' as shmc,'�ϼ�' as hj,11 as sh,a.xq_1 as xmsx_1,a.xq_2 as xmsx_2,a.xq_3 as xmsx_3,a.xq_4 as xmsx_4,a.xq_5 as xmsx_5,a.xq_6 as xmsx_6,a.jcsl from yf_t_mlkfxqmxb a inner join yf_t_mlkfxqb b on a.id=b.id where a.bjbs=-1 and a.id=" + id;
            sql += " union all  select top 1 2 as xh,0 as mxid,'' as shdm,'' as tp,'' as shmc,'' as hj,11 as sh,-1 as xmsx_1,-1 as xmsx_2,-1 as xmsx_3,-1 as xmsx_4,-1 as xmsx_5,-1 as xmsx_6,'' jcsl from yf_t_mlkfxqb )a order by xh";
            bt = sqlhelper.ExecuteReader(sql);

            bt.Read();
            if (bt.FieldCount <= 0)
            {
                return;
            }
            btRtn = new Dictionary<string, string>();
            for (int i = 0; i < bt.FieldCount; i++)
            {
                if (bt.HasRows == false)
                {
                    string str = "";
                    btRtn.Add(bt.GetName(i), (str));
                }
                else { btRtn.Add(bt.GetName(i), bt[i].ToString()); }

            }
            bt.Close();
        }
        if (id.Length > 0 && action.Equals("cx"))
        {
            sql = "  select top 1 mypic,xh from(  select URLAddress as mypic,1 as xh from t_uploadfile  where groupid=22098 and tableid=" + id + " union all select '' as mypic,2 as xh)a order by xh";
            tp = sqlhelper.ExecuteReader(sql);

            tp.Read();

            tpRtn = new Dictionary<string, string>();
            if (tp.FieldCount <= 0)
            {
                return;
            }

            for (int i = 0; i < tp.FieldCount; i++)
            {
                if (tp.HasRows == false)
                {
                    string str = "";
                    tpRtn.Add(tp.GetName(i), (str));
                }
                else { tpRtn.Add(tp.GetName(i), tp[i].ToString()); }


            }

            mypic = tpRtn["mypic"];
            tp.Close();
        }
        if (id.Length > 0 && action.Equals("cx"))
        {
            sql = "select a.djh,a.flowid,a.id,doc.docid,doc.currentNode,a.sjfg,a.zdrq,a.kfbh,b.mc,c.mc sjfgmc,node.cs,a.zdr,a.shbs,a.qrbs,doc.currentUsername as dqshr ";
            sql += "from yf_t_mlkfxqb a  ";
            sql += "left join yf_t_kfbh b on a.kfbh = b.dm ";
            sql += "left join t_xtdm c on a.sjfg = c.dm and  c.tzid=1 and c.ssid='401' and c.ty='0' ";
            sql += "left join  fl_t_flowRelation doc on a.id=doc.dxid and a.flowid=doc.flowid  ";
            sql += "left join fl_t_nodeConfig  node on doc.currentNode=node.nodeid  and node.flowid=doc.flowid  ";
            sql += "where a.id=" + id;

            // Response.Write(sql);
            //Response.End();
            he = sqlhelper.ExecuteReader(sql);
            he.Read();


            heRtn = new Dictionary<string, string>();
            if (he.FieldCount <= 0)
            {
                return;
            }
            for (int i = 0; i < he.FieldCount; i++)
            {
                if (he.HasRows == false)
                {
                    string str = "";
                    heRtn.Add(he.GetName(i), (str));
                }
                else { heRtn.Add(he.GetName(i), (he[i].ToString())); }

            }
            //Response.Write(heRtn);
            he.Close();
        }
        if (id.Length > 0 && action.Equals("cx"))
        {
            sql = "  select a.*,isnull(c.shbs,0) shbs,node.cs as shcs,doc.currentUsername as dqshr ";
            sql += " from yf_t_mlkfxqb c ";
            sql += " left join yf_t_mlgyd a on a.lydjid=c.id and a.lydjlx=c.djlx ";
            sql += " left join  fl_t_flowRelation doc on c.id=doc.dxid and c.flowid=doc.flowid ";
            sql += " left join fl_t_nodeConfig  node on doc.currentNode=node.nodeid  and node.flowid=doc.flowid ";
            sql += " where c.id='" + id + "'";

            sdr = sqlhelper.ExecuteReader(sql);
            sdr.Read();
            sdrRtn = new Dictionary<string, string>();
            if (sdr.FieldCount <= 0)
            {
                return;
            }
            for (int i = 0; i < sdr.FieldCount; i++)
            {
                if (sdr.HasRows == false)
                {
                    string str = "";
                    sdrRtn.Add(sdr.GetName(i), (str));
                }
                else { sdrRtn.Add(sdr.GetName(i), sdr[i].ToString()); }


            }
            sdr.Close();
        }
        if (id.Length > 0 && action.Equals("cx"))
        {
            sql = " select * from (select 1 as xh,yl,zz,qcl,rs,hzl,yh,tz from yf_t_mlgyd where lydjid='" + id + "'";
            sql += " union all select 2 as xh,'' yl,'' zz,'' qcl,'' rs,'' hzl,'' yh,'' tz ) a order by xh ";
            gy = sqlhelper.ExecuteReader(sql);
            gy.Read();
            gyRtn = new Dictionary<string, string>();
            if (gy.FieldCount <= 0)
            {
                return;
            }
            for (int i = 0; i < gy.FieldCount; i++)
            {

                if (gy.HasRows == false)
                {
                    string str = "";
                    gyRtn.Add(gy.GetName(i), (str));
                }
                else { gyRtn.Add(gy.GetName(i), gy[i].ToString()); }
            }
            gy.Close();
        }
        //�����λ����
        if (id.Length > 0 && action.Equals("cx"))
        {

            sql = "    declare @mykey int ; set @mykey=" + id;
            sql += " declare @flowid int ;select @flowid=flowid  from yf_t_mlkfxqb where id=@mykey ";
            //table0
            sql += "SELECT d.nodename,c.created,c.creator,c.nodeid,c.id flowopinionid ,c.body,d.cs ";
            sql += "FROM dbo.yf_t_mlkfxqb a ";
            sql += "INNER JOIN fl_t_flowrelation  b ON a.id=b.dxid AND b.flowid=@flowid ";
            sql += "INNER JOIN fl_t_flowopinion c ON c.docid=b.docID ";
            sql += "INNER JOIN fl_t_nodeconfig d ON d.nodeid=c.nodeid  ";
            sql += "WHERE a.id=@mykey ";
            DataTable flowRecord = sqlhelper.ExecuteDataTable(sql);
            //table1
            sql = "    declare @mykey int ; set @mykey=" + id;
            sql += " declare @flowid int ;select @flowid=flowid  from yf_t_mlkfxqb where id=@mykey ";
            sql += "SELECT l.mxid ,l.nodeID,l.nextNodeID ,l.bz,n.nodeName,next.nodeName nextNodeName,l.fromNode,l.toNode ";
            sql += " FROM fl_t_nodeLink l  ";
            sql += "inner join fl_t_nodeConfig n on n.nodeID=l.nodeID ";
            sql += "left outer join fl_t_nodeConfig next on l.nextNodeID=next.nodeID and next.flowID=@flowid ";
            sql += "WHERE n.flowID=@flowid";
            DataTable flowConfig = sqlhelper.ExecuteDataTable(sql);
            if (flowRecord.Rows.Count == 0)
            {

            }else
            {
                int startNodeid = int.Parse(flowRecord.Select("", " flowopinionid desc ")[0]["nodeid"].ToString());
                int tmpflowopinionid=0;
                System.Collections.Generic.Dictionary<int, FlowDataContent> flowShowDic = new Dictionary<int, FlowDataContent>();
                int tmpnodeid=startNodeid;
                DataRow tmpDr=null;
                while (tmpnodeid > 0)
                {
                    tmpDr = flowRecord.Select(" nodeid=" + tmpnodeid.ToString(), "flowopinionid desc")[0];
                    tmpflowopinionid = int.Parse(tmpDr["flowopinionid"].ToString());
                    flowShowDic.Add(tmpflowopinionid, new FlowDataContent(tmpDr["nodename"].ToString(), tmpDr["created"].ToString(), tmpDr["creator"].ToString(), tmpDr["body"].ToString(), tmpDr["cs"].ToString(), int.Parse(tmpDr["nodeid"].ToString())));
                    if(flowConfig.Select("nextnodeid=" + tmpnodeid.ToString()).Length == 1 )//'��һ���ڵ�ֻ��һ��
                    {
                        tmpnodeid = int.Parse(flowConfig.Select("nextnodeid=" + tmpnodeid.ToString())[0]["nodeid"].ToString());
                    }else if(flowConfig.Select("nextnodeid=" + tmpnodeid.ToString()).Length > 1)
                    {
                        //��һ���ڵ��ж��
                        //�ǲ������̰����������ӵ�����flowopinionid���Ǹ�id
                        int tmpMaxNodeID  = 0;
                        foreach(DataRow tmpMaxNodeIDdr in flowConfig.Select("nextnodeid=" + tmpnodeid.ToString()))
                        {
                            if(flowRecord.Select("nodeid=" + tmpMaxNodeIDdr["nodeid"].ToString()).Length > 0)
                            {
                                tmpMaxNodeID = Math.Max(tmpMaxNodeID, int.Parse((string)flowRecord.Compute("max(flowopinionid)", "nodeid=" + tmpMaxNodeIDdr["nodeid"].ToString())));

                            }
                        }
                        tmpnodeid = int.Parse(flowRecord.Select("flowopinionid=" + tmpMaxNodeID.ToString())[0]["nodeid"].ToString());
                    }else
                    {
                        tmpnodeid = 0;
                    }
                }
                myFlowDic = new Dictionary<string, string>();
                foreach( KeyValuePair<int, FlowDataContent> k in flowShowDic)
                {
                    myFlowDic.Add(k.Value.cs, k.Value.creator);
                }

            }

        }

    }
    public class FlowDataContent {
        public string nodename;
        public string created;
        public string creator;
        public string body;
        public string cs;
        public int nodeid;
        public FlowDataContent(string nodename,string created,string creator,string body,string cs,int nodeid)
        {
            this.nodename = nodename;
            this.created = created;
            this.creator = creator;
            this.body = body;
            this.cs = cs;
            this.nodeid = nodeid;
        }
    }
    public List<KeyValuePair<int,FlowDataContent>> sortByValue ( System.Collections.Generic.Dictionary<int,FlowDataContent>   dict ){
        List<KeyValuePair<int, FlowDataContent>> list = new List<KeyValuePair<int, FlowDataContent>>();
        list.Sort(hikaku);
        return list;
    }
    public int hikaku( KeyValuePair<int,FlowDataContent> kvp1, KeyValuePair<int,FlowDataContent> kvp2)
    {
        return kvp1.Key.CompareTo(kvp2.Key);
    }
</script>

<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">

<html xmlns="http://www.w3.org/1999/xhtml">
<head id="Head1" runat="server">
    <title></title>
    <script type="text/javascript" src="../js_UI/jquery-1.7.min.js"></script>
    <script type="text/javascript" src='../TLTools/calendar.js'></script>
    <style type="text/css">
        input {
            border-style: none;
            border-color: inherit;
            border-width: 0;
            margin-top: 0px;
        }

        .all {
            width: 99%;
            height: 100%;
        }

        .hei {
            height: 100%;
        }

        .bor {
            border-bottom: #000000 solid 1px;
        }

        .bt {
            background-color: #f5f5f5;
        }

        .bt1 {
            width: 6%;
            height: 25px;
            background-color: #f5f5f5;
        }

        .tab1 {
            width: 1050px;
            font-size: 12px;
            border: 1px solid black;
            border-width: 1px 1px 1px 0px;
            margin: auto;
            border-collapse: collapse;
        }

        td {
            padding: 0px;
            border: 1px solid black;
        }

        ol li {
            margin: 5px 0;
        }

        .style1 {
            width: 256px;
        }

        .style3 {
            width: 317px;
        }

        .style4 {
            background-color: #f5f5f5;
            height: 30px;
        }

        .style5 {
            height: 30px;
            width: 257px;
        }

        .style6 {
            width: 256px;
            height: 30px;
        }

        .style7 {
            width: 317px;
            height: 30px;
        }

        .style8 {
            background-color: #f5f5f5;
            width: 303px;
            height: 300px;
        }

        .style9 {
            background-color: #f5f5f5;
            width: 268435408px;
        }

        .style10 {
            width: 257px;
        }

        .style11 {
            height: 30px;
            width: 50%;
        }

        .style13 {
            width: 304px;
            height: 30px;
        }

        .style20 {
            width: 465px;
            height: 30px;
        }

        .style22 {
            width: 550px;
            height: 30px;
        }

        .style26 {
            background-color: #f5f5f5;
            width: 303px;
            height: 30px;
        }

        .style30 {
            background-color: #f5f5f5;
            height: 30px;
            width: 190px;
        }

        .style31 {
            background-color: #f5f5f5;
            height: 30px;
            width: 239px;
        }

        .style33 {
            background-color: #f5f5f5;
            height: 30px;
            width: 225px;
        }

        .style34 {
            background-color: #f5f5f5;
            height: 30px;
            width: 11%;
        }

        .style35 {
            text-align: center;
            height: 30px;
            width: 70px;
            padding: 0px;
        }

        .style36 {
            text-align: center;
            width: 64px;
        }

        .style37 {
            width: 140;
        }

        .style39 {
            font-size: 10pt;
            padding: 0px;
            margin: 0px;
        }
    </style>
</head>
<body>
    <%
        string date = DateTime.Now.ToShortDateString();
        string[] dates = date.Split('-');
        date = "";
        foreach (string dt in dates)
        {
            if (dt.Length > 1)
            {
                date = date + dt + "-";
            }
            else
            {
                date = date + "0" + dt + "-";
            }
        }

        date = date.Substring(0, date.Length - 1);

    %>
    <form name="MyForm" id="MyForm" style="border-bottom: 0px; border-left: 0px; padding-bottom: 0px; padding-left: 0px; padding-right: 0px; border-top: 0px; border-right: 0px; padding-top: 0px;" action="#" align="center">
        <input type="hidden" id="xqcppldm" name="xqcppldm" value="" />
        <input type="hidden" id="plid" name="plid" value="" />
        <input type="hidden" id="ghsid" name="ghsid" value="" />
        <input type="hidden" id="ghsdm" name="ghsdm" value="" />
        <input type="hidden" id="currentNode" name="currentNode" value="" />
        <input type="hidden" id="id" name="id" value="" />
        <input type="hidden" id="tz" name="tz" />
        <input type="hidden" id="xmjl_khid" name="xmjl_khid" />
        <h1 style="text-align: center;"><%=mtitle %></h1>
        <table class="tab1">
            <tr>
                <% string zdrq = ""; if (heRtn["zdrq"] == "") { zdrq = ""; } else { zdrq = DateTime.Parse(heRtn["zdrq"]).ToString("yyyy-MM-dd"); } %>
                <td class="style35">�Ƶ�����</td>
                <td class="style37"><%=zdrq%></td>
                <td class="style35">�������</td>
                <td class="style37"><%=heRtn["mc"] %></td>
                <td class="style35">���ݺ�</td>
                <td class="style37"><%=heRtn["djh"] %></td>
                <td class="style35">��Ʒ��</td>
                <td class="style37"><%=heRtn["sjfgmc"] %></td>
                <td class="style35">�Ƶ���</td>
                <td class="style37"><%=heRtn["zdr"] %></td>
            </tr>
        </table>

        <table class="tab1">
            <tr>
                <td class="style35">���ϳɷ�</td>
                <td style="width: 140px;"><% =sdrRtn["cf"] %></td>
                <td class="style35">ɴ֧</td>
                <td style="width: 140px;"><% =sdrRtn["sz"] %></td>
                <td class="style35">�ܶ�</td>
                <td style="width: 140px;"><% =sdrRtn["md"] %></td>
                <td class="style35">����</td>
                <td style="width: 140px;"><% =sdrRtn["kz"] %></td>
                <td class="style35">��Ч����</td>
                <td style="width: 140px;"><% =sdrRtn["fk"] %></td>
            </tr>
        </table>

        <table class="tab1">
            <tr>
                <td width="121" class="style6" align="left">��Ŀ����<%=winRtn["xmjl"] %></td>
                <!--<td colspan="1" class="style5"><%=winRtn["xmjl"] %></td>-->
                <td class="style6">����Ʒ�ࣺ<%=winRtn["cyplmc"] %></td>
                <td class="style7">�������ң�<%=winRtn["ghsmc"] %></td>
                <td width="121" class="style4" align="right">�浥�ţ�</td>
                <td colspan="1" class="style5"><%=winRtn["bdh"] %></td>
            </tr>
            <!--
      <tr>
        <td width="121" height="30" class="bt" align="right">���ϳɷ�/����˵����</td>
        <td colspan="1" class="style10"><%=winRtn["mlcf"] %></td>
        <td class="style1" >����/���<%=winRtn["gg"] %></td>
        <td class="style3" >����۸�Χ��<%=winRtn["jgfw"] %></td>
      </tr>
      <tr>
        <td width="121" class="style4" align="right">�浥�ţ�</td>
        <td colspan="1" class="style5"><%=winRtn["bdh"] %></td>
        <td class="style6" >����Ҫ��<%=winRtn["gyyq"] %></td>
        <td></td>
      </tr>
      -->

        </table>



        <table class="tab1">

            <tr>
                <td rowspan="2" class="style26" align="left">ԭ����ţ�<%=winRtn["yybh"] %></td>
                <td rowspan="2" colspan="3" class="bt" align="center">ɫ��</td>
                <td rowspan="1" colspan="7" class="style9" align="center">���ʦȷ����������/kg��</td>
                <td colspan="1" rowspan="2" class="bt" align="center">�ϼ�</td>

            </tr>

            <tr>

                <%
                    sql = "  select t1.cname as mc1,t2.cname mc2,t3.cname mc3,t4.cname mc4,t5.cname mc5,t6.cname mc6,'�������' as mc7 ";
                    sql += " from  yf_t_mlkfxqmxb a ";
                    sql += " left outer join t_user t1 on a.xq_1=t1.id ";
                    sql += " left outer join t_user t2 on a.xq_2=t2.id ";
                    sql += " left outer join t_user t3 on a.xq_3=t3.id";
                    sql += " left outer join t_user t4 on a.xq_4=t4.id ";
                    sql += " left outer join t_user t5 on a.xq_5=t5.id ";
                    sql += " left outer join t_user t6 on a.xq_6=t6.id ";
                    sql += "where a.id=" + Request["id"] + " and a.bjbs=-1";
                    //Response.Write(sql);
                    //Response.End();
                    sdr = sqlhelper.ExecuteReader(sql);
                    sdr.Read();
                    string aaa = "";
                    for (int i = 0; i < sdr.FieldCount; i++)
                    {
                        if (sdr.HasRows == false)
                        {
                            aaa = "";
                        }
                        else
                        {
                            aaa = sdr[i].ToString();

                        }
                %>
                <td rowspan="1" class="bt1" id="aaa" align="center"><%=aaa %></td>
                <%
                    }
                    for (int a = sdr.FieldCount; a < 6; a++)
                    {
                %>
                <td rowspan="1" class="bt1" align="center"></td>
                <%
                    }
                    sdr.Close();
                %>
            </tr>
            <td rowspan="<%=jls+1 %>" style="height: <%=(jls+1)*20 %>px" class="style8" align="center"></td>
            <%
                for (int i = 0; i < jls; i++)
                {

            %>
            <tr>
                <td class="style36"><%=dst.Rows[i]["xh2"].ToString() %></td>
                <td class="style36"><%=dst.Rows[i]["shdm"].ToString()%></td>
                <td class="style36"><%=dst.Rows[i]["shdm1"].ToString() %></td>
                <td class="style36"><%=dst.Rows[i]["xmsx_1"].ToString() %></td>
                <td class="style36"><%=dst.Rows[i]["xmsx_2"].ToString() %></td>
                <td class="style36"><%=dst.Rows[i]["xmsx_3"].ToString() %></td>
                <td class="style36"><%=dst.Rows[i]["xmsx_4"].ToString() %></td>
                <td class="style36"><%=dst.Rows[i]["xmsx_5"].ToString() %></td>
                <td class="style36"><%=dst.Rows[i]["xmsx_6"].ToString() %></td>
                <td class="style36"><%=dst.Rows[i]["jcsl"].ToString() %></td>
                <td class="style36"><%=dst.Rows[i]["hj"].ToString() %></td>
            </tr>
            <%
                }
            %>
        </table>
        <!--
    <table class="tab1">
      <tr>
        <td class="style30" align="right">��Ŀ����ȷ�ϣ�</td>
        <td colspan="1" ><% =winRtn["xmjl_ks"]%></td>
      </tr>
       <%-- <tr><td class="style34" align="right"></td>
        <td>�������ң�<%=winRtn["xmjl_khmc"] %></td>
        <td>�����������ڣ�<% =date %></td>
        </tr>
       <tr>
        <td class="style34" align="right"></td>
        <td colspan="2" class="style11"> ��Ŀ���������<br />
            <textarea rows="1"  style="width:98%; height: 125px; overflow:hidden;" id="xmjl_yj"  name="xmjl_yj" cols="20"   onclick="return xmjl_yj_onclick()">
                <% =winRtn["xmjl_yj"]%>
             </textarea>
         </td>
      </tr>
    </table>
    <table class="tab1">
      <tr>
        <td class="style34" align="right">����ܼಹ�䣺</td>
        <td colspan="1" class="style11">
         <textarea   style="width:98%; height: 84px; overflow:hidden;" id="sjzj_xmgy"  name="sjzj_xmgy" cols="20" rows="1"  >
            <% =winRtn["sjzj_xmgy"]%>
         </textarea>
        </td>
      </tr>
    </table>
    <table class="tab1">
      <tr>
        <td class="style30" align="right">��Ʒͳ�ﾭ���ˣ�</td>
        <td colspan="1" >�Ƿ���⿪������<%=winRtn["tcjl_ljxq"] %></td>
         <td>ԭ��<%=winRtn["tcjl_yy"] %></td> 
        </tr>
        <tr>
        <td class="style30" align="right"></td>
        <td class="style13" >�������ң�<%=winRtn["ghsmc"] %></td>
        <td></td>
      </tr>--%>
    </table>
    -->

        <table class="tab1">
            <tr>
                <%--  <td class="style31" align="right">������𹤳�ʦ���ˣ�</td>
        <td colspan="1" class="" style="width:275px;height:30px;">�Ƿ���⿪������<%=winRtn["lbgcs_ljxq"] %></td>--%>
                <td colspan="1" class="" style="width: 275px; height: 30px;">�Ƿ��⣺<%=winRtn["lbgcs_sfjc"] %></td>
                <%--  <td>ԭ��<%=winRtn["lbgcs_yy"] %></td> --%>
                <td colspan="2" class="style20">��λ��<%=winRtn["lbgcs_dw"] %></td>
                <td class="style20">��ŵ���ʱ�䣺<%=winRtn["lbgcs_wcsj"] %></td>
            </tr>

            <%--<tr id="gcsjg"><td class="style31" align="right"></td><td class="style22" >�۸�<%=winRtn["lbgcs_jg"] %></td>

        <td colspan="1" class="style22">������ã�<%=winRtn["lbgcs_kbfy"] %> </td>       
        </tr>--%>
            <%if (winRtn["lbgcs_zysx"] != "")
                {  %>
            <tr>
                <td class="style31" align="right">ɴ��Ҫ��</td>
                <td colspan="3">
                    <%--            <textarea  id="lbgcs_zysx" name="lbgcs_zysx"  style="width:98%; height: 100px; margin-left: 0px;overflow:hidden;"  cols="20" rows="1">
                <% =winRtn["lbgcs_zysx"] %>
            </textarea>--%>

                    <% =winRtn["lbgcs_zysx"] %>
            
                </td>

            </tr>
            <%} %>
            <%if (winRtn["lbgcs_gzjh"] != "")
                {  %>
            <tr>
                <td class="style31" align="right">֯��Ҫ��</td>
                <td colspan="3">
                    <%--                <textarea id="lbgcs_gzjh" name="lbgcs_gzjh"   style="width:98%; height: 89px;overflow:hidden;"  cols="20" rows="1">
                    
                </textarea>--%>
                    <% =winRtn["lbgcs_gzjh"] %>
                </td>
            </tr>
            <%} %>
            <%if (winRtn["lbgcs_lsyq"] != "")
                {  %>
            <tr>
                <td class="style31" align="right">ȾɫҪ��</td>
                <td colspan="3">
                    <%--                <textarea id="lbgcs_lsyq" name="lbgcs_lsyq"   style="width:98%; height: 89px;overflow:hidden;"  cols="20" rows="1">
                    
                </textarea>--%>
                    <% =winRtn["lbgcs_lsyq"] %>
                </td>
            </tr>
            <%} %>
            <%if (winRtn["lbgcs_hzyq"] != "")
                {  %>
            <tr>
                <td class="style31" align="right">����Ҫ��</td>
                <td colspan="3">
                    <%--               <textarea id="lbgcs_hzyq" name="lbgcs_hzyq"   style="width:98%; height: 89px;overflow:hidden;"  cols="20" rows="1">
                   
                </textarea>--%>
                    <% =winRtn["lbgcs_hzyq"] %>
                </td>
            </tr>
            <%} %>
        </table>

        <table id="lbgcs_ml" class="tab1">

            <!--
        <tr>
         <%
                if (gyRtn["yl"].ToString() != "")
                {
                    string at = "";
                    string[] a = gyRtn["yl"].ToString().Split(',');
                    for (int i = 0; i < a.Length; i++)
                    {
                        switch (a[i])
                        {
                            case "a1":
                                at += "��,";
                                break;
                            case "a2":
                                at += "ë,";
                                break;
                            case "a3":
                                at += "��,";
                                break;
                            case "a4":
                                at += "˿,";
                                break;
                            case "a5":
                                at += "����,";
                                break;
                            case "a6":
                                at += "����,";
                                break;
                            case "a7":
                                at += "����,";
                                break;
                            case "a8":
                                at += "����,";
                                break;
                            case "a9":
                                at += "����,";
                                break;
                            case "a10":
                                at += "ճ��,";
                                break;
                            case "a11":
                                at += "Ī����,";
                                break;
                            case "a12":
                                at += "��˿,";
                                break;
                            case "a13":
                                at += "����ά,";
                                break;
                            case "a14":
                                at += "ͭ����ά,";
                                break;
                            case "a15":
                                at += "ţ����ά,";
                                break;
                        }
                    }
         %> 
        
            <td class="style39" colspan="5">ԭ��:<%=at %></td>
        <%
                }
                if (gyRtn["zz"].ToString() != "")
                {
                    string btr = "";
                    string[] b = gyRtn["zz"].ToString().Split(',');
                    for (int i = 0; i < b.Length; i++)
                    {
                        switch (b[i])
                        {
                            case "b1":
                                btr += "����֯��,";
                                break;
                            case "b2":
                                btr += "��ˮ֯��,";
                                break;
                            case "b3":
                                btr += "����֯��,";
                                break;
                            case "b4":
                                btr += "Ƭ��֯��,";
                                break;
                            case "b5":
                                btr += "����֯��,";
                                break;
                            case "b6":
                                btr += "���,";
                                break;
                            case "b7":
                                btr += "�����,";
                                break;
                            case "b8":
                                btr += "��Բ��,";
                                break;
                        }
                    }
        %>
            <td class="style39" colspan="5">֯��:<%=btr%></td>
        <%
                }
         %>
        </tr>
        <tr>
        <%
                if (gyRtn["yl"].ToString() != "")
                {
         %> 
            <td class="style39" colspan="5">����Ҫ��˵��:<% =sdrRtn["ylsm"] %></td>
        <%
                }
                if (gyRtn["zz"].ToString() != "")
                {
        %>
            <td class="style39" colspan="5">����Ҫ��˵��:<% =sdrRtn["zzsm"] %></td>
        <%
                }
         %>
        </tr>
         <tr>
         <%
                if (gyRtn["qcl"].ToString() != "")
                {
                    string ct = "";
                    string[] c = gyRtn["qcl"].ToString().Split(',');
                    for (int i = 0; i < c.Length; i++)
                    {
                        switch (c[i])
                        {
                            case "c1":
                                ct += "����,";
                                break;
                            case "c2":
                                ct += "��ë,";
                                break;
                            case "c3":
                                ct += "�˽�,";
                                break;
                            case "c4":
                                ct += "����,";
                                break;
                            case "c5":
                                ct += "Ư��,";
                                break;
                            case "c6":
                                ct += "˿��,";
                                break;
                            case "c7":
                                ct += "ϴ��,";
                                break;
                            case "c8":
                                ct += "����,";
                                break;
                            case "c9":
                                ct += "����,";
                                break;
                            case "c10":
                                ct += "�ȶ���,";
                                break;
                            case "c11":
                                ct += "�ѽ�,";
                                break;
                            case "c12":
                                ct += "�����,";
                                break;
                        }
                    }
         %> 
            <td class="style39" colspan="5">ǰ����:<%=ct %></td>
         <%
                }
                if (gyRtn["rs"].ToString() != "")
                {
                    string dt = "";
                    string[] d = gyRtn["rs"].ToString().Split(',');
                    for (int i = 0; i < d.Length; i++)
                    {
                        switch (d[i])
                        {
                            case "d1":
                                dt += "ɢ��Ⱦɫ,";
                                break;
                            case "d2":
                                dt += "Ͳ��Ⱦɫ,";
                                break;
                            case "d3":
                                dt += "��ɴȾɫ,";
                                break;
                            case "d4":
                                dt += "����Ⱦɫ,";
                                break;
                            case "d5":
                                dt += "����Ⱦɫ,";
                                break;
                            case "d6":
                                dt += "����Ⱦɫ,";
                                break;
                            case "d7":
                                dt += "����Ⱦɫ,";
                                break;
                            case "d8":
                                dt += "��Ⱦ,";
                                break;
                        }
                    }
        %>
            <td class="style39" colspan="5">Ⱦɫ:<%=dt %></td>
        <%
                }
         %>
        </tr>
         <tr>
         <%
                if (gyRtn["qcl"].ToString() != "")
                {
         %> 
            <td class="style39" colspan="5">����Ҫ��˵��:<% =sdrRtn["qclsm"] %></td>
        <%
                }
                if (gyRtn["rs"].ToString() != "")
                {
        %>
            <td class="style39" colspan="5">����Ҫ��˵��:<% =sdrRtn["rssm"] %></td>
        <%
                }
         %>
        </tr>
         <tr>
          <%
                if (gyRtn["hzl"].ToString() != "")
                {
                    string et = "";
                    string[] e = gyRtn["hzl"].ToString().Split(',');
                    for (int i = 0; i < e.Length; i++)
                    {
                        switch (e[i])
                        {
                            case "e1":
                                et += "Һ��,";
                                break;
                            case "e2":
                                et += "����,";
                                break;
                            case "e3":
                                et += "Ԥ��,";
                                break;
                            case "e4":
                                et += "ѹ��,";
                                break;
                            case "e5":
                                et += "ĥë,";
                                break;
                            case "e6":
                                et += "��ë,";
                                break;
                            case "e7":
                                et += "��ë,";
                                break;
                            case "e8":
                                et += "����ϴ,";
                                break;
                            case "e9":
                                et += "����,";
                                break;
                            case "e10":
                                et += "ˢ��,";
                                break;
                            case "e11":
                                et += "��ʪ,";
                                break;
                            case "e12":
                                et += "����,";
                                break;
                            case "e13":
                                et += "����,";
                                break;
                            case "e14":
                                et += "��ѹ,";
                                break;
                            case "e15":
                                et += "����,";
                                break;
                        }
                    }
         %> 
            <td class="style39" colspan="5">������:<%=et %></td>
         <%
                }
                if (gyRtn["yh"].ToString() != "")
                {
                    string ft = "";
                    string[] f = gyRtn["yh"].ToString().Split(',');
                    for (int i = 0; i < f.Length; i++)
                    {
                        switch (f[i])
                        {
                            case "f1":
                                ft += "Բ��ӡ��,";
                                break;
                            case "f2":
                                ft += "ƽ��ӡ��,";
                                break;
                            case "f3":
                                ft += "��Ͳӡ��,";
                                break;
                            case "f4":
                                ft += "�����ӡ,";
                                break;
                            case "f5":
                                ft += "��īӡ��,";
                                break;
                            case "f6":
                                ft += "ֲ��ӡ��,";
                                break;
                            case "f7":
                                ft += "ת��ӡ��,";
                                break;
                            case "f8":
                                ft += "��Ⱦӡ��,";
                                break;
                            case "f9":
                                ft += "ֱ��ӡ��,";
                                break;
                            case "f10":
                                ft += "��Ⱦӡ��,";
                                break;
                            case "f11":
                                ft += "��Ⱦӡ��,";
                                break;
                            case "f12":
                                ft += "��ӡӡ��,";
                                break;
                            case "f13":
                                ft += "ѹ��,";
                                break;
                            case "f14":
                                ft += "�̻�,";
                                break;
                            case "f15":
                                ft += "����,";
                                break;
                            case "f16":
                                ft += "�û�,";
                                break;
                        }
                    }
        %>
            <td class="style39" colspan="5">ӡ��<%=ft %></td>
        <%
                }
         %>
        </tr>
         <tr>
         <%
                if (gyRtn["hzl"].ToString() != "")
                {
         %> 
            <td class="style39" colspan="5">����Ҫ��˵��:<% =sdrRtn["hzlsm"] %></td>
         <%
                }
                if (gyRtn["yh"].ToString() != "")
                {
        %>
            <td class="style39" colspan="5">����Ҫ��˵��:<% =sdrRtn["yhsm"] %></td>
         <%
                }
         %>
        </tr>
         <tr>
         <%
                if (gyRtn["tz"].ToString() != "")
                {
                    string gt = "";
                    string[] g = gyRtn["tz"].ToString().Split(',');
                    for (int i = 0; i < g.Length; i++)
                    {
                        switch (g[i])
                        {
                            case "g1":
                                gt += "Ϳ��,";
                                break;
                            case "g2":
                                gt += "��Ĥ,";
                                break;
                            case "f3":
                                gt += "����,";
                                break;
                            case "g4":
                                gt += "����,";
                                break;
                            case "g5":
                                gt += "��������,";
                                break;
                            case "g6":
                                gt += "����ˮ,";
                                break;
                            case "g7":
                                gt += "��ˮ����,";
                                break;
                            case "g8":
                                gt += "��ȥ��,";
                                break;
                            case "g9":
                                gt += "��ʪ���,";
                                break;
                            case "g10":
                                gt += "������,";
                                break;
                            case "g11":
                                gt += "����,";
                                break;
                            case "g12":
                                gt += "��������,";
                                break;
                            case "g13":
                                gt += "�ȸ�����,";
                                break;
                            case "g14":
                                gt += "��������,";
                                break;
                            case "g15":
                                gt += "��������,";
                                break;
                            case "g16":
                                gt += "������,";
                                break;
                        }
                    }
         %> 
            <td class="style39" colspan="5">��������:<%=gt %></td>
         <%
                }
         %>
            <td class="style39" colspan="5">������ע:<% =sdrRtn["bz"] %></td>
        </tr>
        -->
        </table>

        <table id="gcsjl" class="tab1">
            <tr>
                <td class="style34" align="right">������𹤳�ʦ��������</td>
                <td colspan="1" class="style11">����ע�����<% =winRtn["gcsjl_zysx"] %> </td>
            </tr>
        </table>
        <table id="gys" class="tab1">
            <tr>
                <td class="style33" align="right"></td>
                <td colspan="1" class="style22">��Ӧ��ȷ�ϣ�<% =winRtn["qrzt"] %></td>
                <td class="style20">���ʱ�䣺<% =winRtn["qrrq"] %></td>
            </tr>
        </table>
        <table id="Table1" class="tab1">
            <tr>
                <% if (winRtn["djlx"] == "12342")
                    { //�߷���%>
                <td colspan="1" class="style22">&nbsp;�Ƶ��ˣ�<% = (myFlowDic.ContainsKey("1") ? myFlowDic["1"] : "")  %></td>
                <td colspan="1" class="style22">&nbsp;����ʦ��<% =(myFlowDic.ContainsKey("4") ? myFlowDic["4"] : "") %></td>
                <td colspan="1" class="style22">&nbsp;����ʦ���ܣ�<% =(myFlowDic.ContainsKey("5") ? myFlowDic["5"] : "") %></td>
                <td colspan="1" class="style22">&nbsp;�̿ز�����<% =(myFlowDic.ContainsKey("80") ? myFlowDic["80"] : "") %></td>
                <% } %>
                <% else if (winRtn["djlx"] == "12330" || winRtn["djlx"] == "12341")//�������� �����������з��滮 %>
                <% { %>
                <td colspan="1" class="style22">&nbsp;��Ŀ����<% =myFlowDic["1"] %></td>
                <td colspan="1" class="style22">&nbsp;����ܼࣺ<% =(myFlowDic.ContainsKey("2") ? myFlowDic["2"] : "") %></td>
                <td colspan="1" class="style22">&nbsp;��Ʒͳ�<% =(myFlowDic.ContainsKey("3") ? myFlowDic["3"] : "") %></td>
                <td colspan="1" class="style22">&nbsp;���Ϲ���ʦ��<% =(myFlowDic.ContainsKey("4") ? myFlowDic["4"] : "") %></td>
                <td colspan="1" class="style22">&nbsp;���Ͽ�������<% =(myFlowDic.ContainsKey("5") ? myFlowDic["5"] : "") %></td>
                <% } else if (winRtn["djlx"] == "2130"){//�쳣������ %>                
                <td colspan="1" class="style22">&nbsp;����ʦ��<% =(myFlowDic.ContainsKey("gcs") ? myFlowDic["gcs"] : "") %></td>
                <td colspan="1" class="style22">&nbsp;��Ʒͳ�<% =(myFlowDic.ContainsKey("tc") ? myFlowDic["tc"] : "") %></td>
                <td colspan="1" class="style22">&nbsp;�̿ز�����<% =(myFlowDic.ContainsKey("skbz") ? myFlowDic["skbz"] : "") %></td>
                <%} %>
            </tr>
        </table>
        <input type="hidden" id="dm" name="dm" value="ml" />
    </form>
</body>
</html>