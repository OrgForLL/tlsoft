<%@ Page Language="C#" Debug="true" %>
<%@ Import Namespace="nrWebClass"  %>
<%@ Import Namespace="System.Collections.Generic" %>
<%@ Import Namespace="System.Data.SqlClient" %>
<%@ Import Namespace="System.Data" %>
<%@ Import Namespace="System.IO" %>
<%@ Import Namespace="Newtonsoft.Json" %>
<%@ Import Namespace="System.Net" %>

<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<script runat="server">

    protected void Page_Load(object sender, EventArgs e)
    {
        string str_ID = System.Web.HttpContext.Current.Request.Params["Dzid"];
        string Mysession=HttpContext.Current.Request.Params["USER"];
        string[] str = Mysession.Split('|');
        string errInfo,str_Vip="",dycs,Jfqyrq;
        DataTable dt;
        string mysql = string.Format(@"SELECT max(d.jfqyrq) jfqyrq,convert(varchar(10), max(a.Rq),23) Rq,max(a.Djh) Djh,max(CASE a.Djlb WHEN 1 THEN '销售' WHEN 2 THEN '定制销售' WHEN -1 THEN '退货' WHEN -2 THEN '定制退货' END) Djlbmc,max(a.Bz) Bz,max(a.Yskje) Yskje,max(a.Sskje) Sskje,max(a.Zdr) Zdr,max(a.Vip) Vip,max(b.Mddm) Mddm,max(b.Lxdh) Lxdh, max(b.bz) as Sm,sum(c.sl) sl,max(a.zkje) zkje,isnull(max(b.dycs),0) dycs 
        FROM Zmd_t_Lsdjb a inner join T_Mdb b on a.Khid = b.Khid AND a.Mdid = b.Mdid inner join Zmd_t_Lsdjmx c on a.id=c.id inner join yx_t_khb d on a.khid=d.khid   WHERE a.ID ={0}", str_ID);
        using (LiLanzDALForXLM dal=new LiLanzDALForXLM(Convert.ToInt32(str[0])))//
        {
            errInfo = dal.ExecuteQuery(mysql,out dt);
            Jfqyrq = Convert.ToString(dt.Rows[0]["jfqyrq"]);
            Mddm.Text =Convert.ToString( dt.Rows[0]["Mddm"]);
            Djh.Text = Convert.ToString(dt.Rows[0]["Djh"]);
            Djlbmc.Text = Convert.ToString( dt.Rows[0]["Djlbmc"]);
            vip.Text = Convert.ToString( dt.Rows[0]["Vip"]);
            str_Vip = Convert.ToString( dt.Rows[0]["Vip"]);
            Zdr.Text =Convert.ToString( dt.Rows[0]["Zdr"]);
            Ysk.Text =String.Format("{0:0.#}", Convert.ToString(dt.Rows[0]["Yskje"]));
            Ssk.Text =String.Format("{0:0.#}", Convert.ToString( dt.Rows[0]["Sskje"]));
            Zl.Text = String.Format("{0:0.#}", Convert.ToDecimal(dt.Rows[0]["Sskje"]) - Convert.ToDecimal(dt.Rows[0]["Yskje"]));
            Bz.Text =  Convert.ToString( dt.Rows[0]["Bz"]);
            Rq.Text =String.Format("{0:yyyy年MM月dd日}",  Convert.ToString( dt.Rows[0]["Rq"])+"&nbsp;" + DateTime.Now.ToString("HH:mm:ss"));
            Lxdh.Text =  Convert.ToString( dt.Rows[0]["Lxdh"]);
            Lsje_Dx.Text = MoneySmallToBig(Ysk.Text);;
            Sm.Text =Convert.ToString( dt.Rows[0]["Sm"]);
            Hjsl.Text = Convert.ToString( dt.Rows[0]["sl"]);
            Sqje.Text = Convert.ToString( dt.Rows[0]["zkje"]);
            dycs =Convert.ToString( dt.Rows[0]["dycs"]);
            clsSharedHelper.DisponseDataTable(ref dt);

            mysql = "SELECT SUM(a.Je) FROM Zmd_T_Lsfkmx a inner join Zmd_T_Lsdjb b on a.id=b.id inner join Zmd_V_Fkfsb c on a.Fkid = c.Id WHERE b.Khid = c.Tzid AND a.Fkid < -1 AND a.ID = " + str_ID;
            object fk20;
            errInfo = dal.ExecuteQueryFast(mysql, out fk20);
            Fk20.Text = String.Format("{0:0}", fk20);

            if (!string.IsNullOrEmpty(str_Vip))
            {
                mysql = string.Format(@"SELECT case when b.qdkh=1 then 0 else SUM(Jfs) end Jfs FROM ( SELECT '{0}' as kh,SUM(Jfs) Jfs FROM YX_T_Vipjfxfb 
                                       WHERE Kh = '{1}' AND Rq >= '{2}'  
                                       UNION ALL 
                                       SELECT a.vip as kh,- SUM(case when isnull(a.jfbs,0)=0 then case when isnull(a.xfjf,0)=0 then a.Yskje*b.Kc else a.xfjf*b.Kc  end else 0 end)  
                                       FROM Zmd_T_Lsdjb a inner join T_Djlb b on a.Djlb = b.Dm 
                                       WHERE  isnull(a.jfbs,0)=0 AND a.Vip = '{0}' AND a.Rq >= '{2}' AND a.Djbs = 1 AND a.Djlb < 10 AND a.vip<>'' group by a.vip  
                                       UNION ALL 
                                       select kh,sum(dhjfs) from zmd_t_xfjfdhb where rq>=  '{2}'  and kh='{0}' group by kh 
                                       UNION ALL 
                                       select kh,sum(qcjf) from yx_t_vipkh where kh='{0}' group by kh) a inner join yx_t_vipkh b on a.kh=b.kh where b.kh='{0}' group by b.qdkh",str_Vip,str[0],Jfqyrq);
                object zfobj,objjf;
                errInfo = dal.ExecuteQueryFast(mysql,out zfobj);
                zf.Text = String.Format("{0:0}", zfobj);

                mysql =string.Format(@"SELECT case when b.qdkh=1 then 0 else SUM(Jfs) end Jfs 
                                       FROM ( SELECT '{0}' as kh,SUM(Jfs) Jfs FROM YX_T_Vipjfxfb WHERE Kh = {1}' AND Rq >= '{2}'  
                                       UNION ALL 
                                       SELECT a.vip as kh,- SUM(case when isnull(a.jfbs,0)=0 then case when isnull(a.xfjf,0)=0 then a.Yskje*b.Kc else a.xfjf*b.Kc  end else 0 end)  
                                       FROM Zmd_T_Lsdjb a inner join T_Djlb b on a.Djlb = b.Dm WHERE isnull(a.jfbs,0)=0 AND a.Vip = '{0}' AND a.Rq >= '{2}' AND a.Djbs = 1 AND a.Djlb < 10 and a.khid='{1}' AND a.vip<>'' group by a.vip  
                                       UNION ALL 
                                       select kh,sum(dhjfs) from zmd_t_xfjfdhb where rq>=  '{2}'  and kh='{0}' group by kh UNION ALL select kh,sum(qcjf) from yx_t_vipkh 
                                        where kh='{0}' group by kh) a inner join yx_t_vipkh b on a.kh=b.kh where b.kh='{0}' group by b.qdkh",str_Vip,str[0],Jfqyrq);
                errInfo = dal.ExecuteQueryFast(mysql,out objjf);
                Jf.Text = String.Format("{0:0}", objjf);
            }
            mysql = "SELECT TOP 3 CONVERT(VARCHAR(10),fkid) as fkid,je FROM Zmd_T_Lsfkmx WHERE fkid IN (-19,-20,-24) AND id=" + str_ID;

            errInfo = dal.ExecuteQuery(mysql, out dt);
            foreach (DataRow dr in dt.Rows)
            {
                if(Convert.ToString(dr["fkid"]) == "-19")
                {
                    Fk_19.Text = String.Format("{0:0.##}", dr["je"]);
                }else if(Convert.ToString(dr["fkid"]) == "-20")
                    Fk_20.Text = String.Format("{0:0.##}", dr["je"]);
                else  Fk_24.Text = String.Format("{0:0.##}", dr["je"]);
            }
            if (dt.Rows.Count == 0) divSmzf.Visible = false;
            clsSharedHelper.DisponseDataTable(ref dt);

            mysql = string.Format(@"SELECT 'Fk'+c.Dm Dm,sum(a.Je) Je FROM Zmd_T_Lsfkmx a INNER JOIN Zmd_T_Lsdjb b ON a.Id = b.Id AND a.Fkid > -1 
                      INNER JOIN Zmd_V_Fkfsb c ON a.Fkid = c.Id AND b.Khid = c.Tzid WHERE a.ID ={0} Group By c.Dm", str_ID );

            errInfo = dal.ExecuteQuery(mysql, out dt);
            foreach (DataRow dr in dt.Rows)
            {
                Label l =(Label)Page.FindControl(Convert.ToString(dr["Dm"]));
                l.Text = Convert.ToString(String.Format("{0:0.##}", dr["je"]));
            }
            clsSharedHelper.DisponseDataTable(ref dt);

            string str_HeaderText = @"<table>
                                   <tr height=20>
                                   <td width=60 align='left'>货号</td>
                                   <td width=25>规格</td>
                                   <td width=25>数量</td>
                                   <td width=30>原价</td>
                                   <td width=40>金额</td></tr>";

            mysql = "SELECT Sphh,Cmmc,Sl,Bj,Je,zks FROM Zmd_T_Lsdjmx WHERE Id = " + str_ID + " ORDER BY Mxid";
            errInfo = dal.ExecuteQuery(mysql, out dt);
            string row = @"<tr height=20>
                                   <td width=60 align='left'>{0}</td>
                                   <td width=25>{1}</td>
                                   <td width=25>{2}</td>
                                   <td width=30>{3:#}</td>
                                   <td width=40>{4:#}</td></tr>";
            string html = "";
            foreach (DataRow dr in dt.Rows)
            {
                html += string.Format(row,dr["Sphh"],dr["Cmmc"],dr["Sl"],dr["Bj"],dr["Je"]);
            }

            MyGrid1.InnerHtml = str_HeaderText + html +"</table>";
        }


    }
    public  string MoneySmallToBig(string par)
    {
        String[] Scale = { "分", "角", "元", "拾", "佰", "仟", "万", "拾", "佰", "仟", "亿", "拾", "佰", "仟", "兆", "拾", "佰", "仟" };
        String[] Base = { "零", "壹", "贰", "叁", "肆", "伍", "陆", "柒", "捌", "玖" };
        String Temp = par;
        string result = null;
        int index = Temp.IndexOf(".", 0, Temp.Length);//判断是否有小数点
        if (index != -1)
        {
            Temp = Temp.Remove(Temp.IndexOf("."), 1);
            for (int i = Temp.Length; i > 0; i--)
            {
                int Data = Convert.ToInt16(Temp[Temp.Length - i]);
                result += Base[Data - 48];
                result += Scale[i - 1];
            }
        }
        else
        {
            for (int i = Temp.Length; i > 0; i--)
            {
                int Data = Convert.ToInt16(Temp[Temp.Length - i]);
                result += Base[Data - 48];
                result += Scale[i + 1];
            }
        }
        return result;
    }

</script>

<html xmlns="http://www.w3.org/1999/xhtml">
<head id="Head1" runat="server">
    <title>收银单打印</title>
    		<meta content="Microsoft Visual Studio .NET 7.1" name="GENERATOR">
		<meta content="Visual Basic .NET 7.1" name="CODE_LANGUAGE">
		<meta content="JavaScript" name="vs_defaultClientScript">
		<meta content="http://schemas.microsoft.com/intellisense/ie5" name="vs_targetSchema">
		<LINK href="../00_resource/03_css/style1.css" type="text/css" rel="stylesheet">
		<OBJECT id="WebBrowser" height="0" width="0" classid="CLSID:8856F961-340A-11D0-A96B-00C04FD705A2" VIEWASTEXT></OBJECT>
</head>
<body leftMargin="18" topMargin="0">
    	<form id="Form1" method="post" runat="server" style=" font-size:12px">
               <table style="WIDTH: 5.5cm;font-family:'Microsoft YaHei','微软雅黑',Arial,'宋体','黑体';" borderColor="#000000" cellSpacing="0" cellPadding="0" border="0">
				<tr  height="20">
					<td  style="width:100%"  align="center">利郎商务男装<input id="__USER" type="hidden" runat="server"></td>
				</tr>
				<tr height="20">
					<td style="width:100%" align="right">---&nbsp;<asp:label id="Mddm" runat="server"></asp:label>&nbsp;&nbsp;&nbsp;&nbsp;</td>
				</tr>
				<tr height="18">
					<td  style="width:100%">编号：<asp:label id="Djh" runat="server"></asp:label>&nbsp;&nbsp;&nbsp;&nbsp;销售别：<asp:label id="Djlbmc" runat="server"></asp:label></td>
				</tr>
				<tr height="18">
					<td>日期：<asp:label id="Rq" Runat="server"></asp:label></td>
				</tr>
				<tr>
					<td >------------------------</td>
				</tr>
				<tr>
				<td><cc2 id="MyGrid1" runat="server" ></cc2></td>
				</tr>
				<tr>
					<td>------------------------</td>
				</tr>
				<tr>
					<td>合计：&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<span style="WIDTH: 70px"></span><asp:label id="Hjsl" runat="server"></asp:label>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<span style="WIDTH: 30px"></span>￥&nbsp;<asp:label id="Ysk" runat="server"></asp:label></td>
				</tr>
				<tr>
					<td>大写：<asp:label id="Lsje_Dx" Runat="server"></asp:label></td>
				</tr>
				<tr>
					<td>-----------------------------</td>
				</tr>
				<tr>
					<td>现金：<asp:label id="Fk10" Runat="server" Width="70"></asp:label>刷&nbsp;&nbsp;卡：<asp:label id="Fk20" Runat="server"></asp:label></td>
				</tr>
				<tr>
					<td>赠送：<asp:label id="Fk33" Runat="server" Width="70"></asp:label>抵用券：<asp:label id="Fk31" Runat="server"></asp:label></td>
				</tr>
				<tr>
					<td>签单：<asp:label id="Fk32" Runat="server" Width="70"></asp:label>签单退差：<asp:label id="Fk34" Runat="server"></asp:label></td>
				</tr>
				<tr>
					<td>代金券：<asp:label id="Fk40" Runat="server" Width="60"></asp:label>银联预付卡：<asp:label id="Fk50" Runat="server"></asp:label></td>
				</tr>
				<tr>
					<td>收款：<asp:label id="Ssk" Runat="server" Width="70"></asp:label>找&nbsp;&nbsp;零：<asp:label id="Zl" Runat="server"></asp:label></td>
				</tr>
				<tr>
					<td>送券额：<asp:label id="Sqje" Runat="server" Width="60"></asp:label>储值卡：<asp:label id="Fk35" Runat="server"></asp:label></td>
				</tr>
				<tr runat="server" id="divSmzf" style="text-align:left">
					<td><span id="span_20" runat="server" visible="false">支付宝：</span><asp:label id="Fk_20" Runat="server"></asp:label>
                        <span id="span_19" runat="server" visible="false">微支付：</span><asp:label id="Fk_19" Runat="server"></asp:label>
                        <span id="span_24" runat="server" visible="false">银联微支付：</span><asp:label id="Fk_24" Runat="server"></asp:label></td>
				</tr>
				<tr>
					<td>备注：<asp:label id="Bz" Runat="server"></asp:label></td>
				</tr>
				<tr>
					<td>-----------------------------</td>
				</tr>
				<tr>
					<td>贵宾卡：<asp:label id="vip" Runat="server" Width="70"></asp:label>总积分：<asp:label id="zf" Runat="server"></asp:label></td>
				</tr>
				<tr>
				<td>本店积分：<asp:label id="Jf" Runat="server"></asp:label></td>
				</tr>
				<tr>
					<td>-----------------------------</td>
				</tr>
				<tr>
					<td>开单：<asp:label id="Zdr" Runat="server"></asp:label></td>
				</tr>
				<tr>
					<td>售后服务电话：<asp:label id="Lxdh" Runat="server"></asp:label></td>
				</tr>
				<tr>
					<td><asp:label id="Sm" Runat="server"></asp:label></td>
				</tr>
			</table>
		</form>
    <script language="javascript"> 
        window.onload = function () {
            window.print();
            window.close();
        }

    </script>
	</body>
</html>
