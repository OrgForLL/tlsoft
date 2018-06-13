<%@ Page Language="VB" Debug="true" %>
<%@ Import Namespace="System.Data" %>
<%@ Import Namespace="System.Data.SqlClient" %>
<%@ Import Namespace="Newtonsoft.Json" %>
<%@ Import Namespace="System.Collections.Generic" %>
<html>
<head>
    <title>洗水标</title>
    <script type="text/javascript" src='../Scripts/jquery.js'></script>
    <script type="text/javascript" language="javascript">
        //console调试出错
        window.console = window.console || (function () {
            var c = {}; c.log = c.warn = c.debug = c.info = c.error = c.time = c.dir = c.profile = c.clear = c.exception = c.trace = c.assert = function () { };
            return c;
        })();

        window.onload = function () {
            var divWith = 0;
            $.each($(" #mainDiv > div"), function (i, n) {
                divWith += $(n).width()
            });
            if (divWith > 0) {
                $("#mainDiv").width(divWith + 10);
                $("#mainDiv").css("overflow", "auto");
            }
        }
    </script>
    <style type="text/css">
        A
        {
            text-decoration: NONE;
        }

        .bt
        {
            font-weight: 700;
            font-size: 20px;
        }

        .mxbt
        {
            font-weight: 700;
            font-size: 18px;
        }

        #hgzbm
        {
            color: White;
        }

        .ylTableTdCss
        {
            width: 11mm;
        }

        .ylTableCol1Css
        {
            width: 9mm;
        }

        .bt
        {
            font-size: 14pt;
            font-weight: 700;
        }
    </style>
</head>
<script runat="server">
    Dim mylink0 As New mylink.mylink
    Dim mylink = mylink0.mylink1()
    Dim myconn As New SqlConnection(mylink)
    Dim TLConn As New SqlConnection(mylink)
    Dim lbdll As New lbclass.lbdll
    Dim lb_tldll As New lbclass.tldll

    Public Function getArrayConter(ByVal array As Array, ByVal positionNum As Integer) As String
        If array Is Nothing Then
            Return ""
        Else
            If array.Length < positionNum + 1 Then
                Return ""
            Else
                Return array(positionNum)
            End If

        End If
    End Function
    ''' <summary>
    ''' 
    ''' </summary>
    ''' <param name="dt"></param>
    ''' <param name="strWhere"></param>
    ''' <param name="sort"></param>
    ''' <returns></returns>
    Public Function SreeenDataTable(ByVal dt As DataTable, ByVal strWhere As String, ByVal sort As String) As DataTable
        If dt.Rows.Count = 0 Then
            Return dt
        Else
            Dim dtNew As DataTable = dt.Clone()
            Dim drs As DataRow() = dt.Select(strWhere, sort)
            If drs.Length > 0 Then
                For Each dr As DataRow In drs
                    dtNew.ImportRow(dr)
                Next
            End If
            Return dtNew
        End If
    End Function
    ''' <summary>
    ''' 获取纤维含量
    ''' </summary>
    ''' <param name="hlinfo">需打印的成份</param>
    ''' <param name="充绒量"></param>    
    ''' <param name="ty">版本=0不显示类别=1显示类别=3直接返回成份串</param>    
    ''' <param name="istzsy">套装上衣标识</param>
    ''' <param name="istzxz">套装下装标识</param>
    ''' <returns></returns>
    ''' <remarks></remarks>
    Public Function getCF(ByVal hlinfo As DataTable, ByVal 充绒量 As String, ByVal ty As String, ByVal istzsy As Integer, ByVal istzxz As Integer, ByVal ismj As Integer) As String
        Dim result As String = ""
        Dim 需打印的成份 As DataTable = New DataTable
        Dim 裤子打印类别 As Integer = 0 '除了本身ty=1需要打类别的外的(ty=0),如果成份有二种以上,那么就需要打印类别
        If istzsy = 1 Then '套装上衣
            需打印的成份 = SreeenDataTable(hlinfo, "glz in (0,1)", "sytjid")
        ElseIf istzxz = 1 Then '套装裤
            需打印的成份 = SreeenDataTable(hlinfo, "glz in (0,2)", "sytjid")
        ElseIf ismj = 1 Then '马甲
            需打印的成份 = SreeenDataTable(hlinfo, "glz in (0,3)", "sytjid")
        Else
            需打印的成份 = hlinfo
        End If

        If ty = 1 Then
            '纤维含量 适应用于标签要体现类别
            '主色面料：聚酯纤维93.3% 
            '          桑蚕丝6.7%
            '插色面料：聚酯纤维100%
            '主色里料：聚酯纤维51.2% 
            '          粘纤48.8%
            '插色里料：聚酯纤维100%
            '填充物外层：白鸭绒(含绒量90%)
            '填充物里层：聚酯纤维100%
            '            (无纺布除外)            
            For Each dr As DataRow In 需打印的成份.Rows
                If dr("mxsz").ToString().IndexOf(" ") > 0 Then '成份维护的时候有空格,折成多行
                    result += "<div>" + dr("mxsz").ToString().Split(" ")(0) + "</div>"
                    For tmpc As Integer = 1 To dr("mxsz").ToString().Split(" ").Length - 1
                        result += "<div>"
                        For tmpi As Integer = 1 To dr("mxsz").ToString().Split(":")(0).Length '后面那个成份空出标题的空格出来
                            result += "&#12288;"
                        Next
                        result += "&nbsp;" + dr("mxsz").ToString().Split(" ")(tmpc) + "</div>" '有一个冒号:    
                    Next

                Else
                    result += "<div>" + dr("mxsz") + "</div>"
                End If
            Next
            '纤维含量 适应用于标签要体现类别 end 
        ElseIf ty = 0 Then
            If 需打印的成份.Rows.Count > 1 Then
                裤子打印类别 = 1
            Else
                裤子打印类别 = 0
            End If
            If 裤子打印类别 = 0 Then
                '纤维含量 适应于不体现类别,

                '   棉72%
                '   再生纤维素纤维26.8%
                '   氨纶1.2%
                For Each dr As DataRow In 需打印的成份.Rows
                    Dim tmp As String
                    If dr("mxsz").ToString().IndexOf(":") > 0 Then '取冒号之后的纤维含量
                        tmp = dr("mxsz").ToString().Split(":")(1)
                    Else
                        tmp = dr("mxsz").ToString()
                    End If

                    If tmp.IndexOf(" ") > 0 Then '成份维护的时候有空格,折成多行
                        result += "<div>" + tmp.Split(" ")(0) + "</div>"
                        For tmpc As Integer = 1 To tmp.Split(" ").Length - 1
                            result += "<div>" + tmp.Split(" ")(tmpc) + "</div>"
                        Next
                    Else
                        result += "<div>" + tmp + "</div>"
                    End If

                Next
                '纤维含量 适应于不体现类别 end  
            ElseIf 裤子打印类别 = 1 Then
                '纤维含量 适应用于标签要体现类别,成份要重新换一行
                '主色面料:
                '粘纤+莱赛尔54.5%
                '锦纶21.7%
                '聚酯纤维20.0%
                '氨纶3.8%
                '插色面料:
                '锦纶97.4%
                '氨纶2.6%
                For Each dr As DataRow In 需打印的成份.Rows
                    If dr("mxsz").ToString().IndexOf(" ") > 0 Then '成份维护的时候有空格,折成多行
                        '处理第一个空格前面的数据'
                        If dr("mxsz").ToString().Split(" ")(0).IndexOf(":") Then
                            result += "<div>" + dr("mxsz").ToString().Split(" ")(0).Split(":")(0) + ":</div>"
                            result += "<div>" + dr("mxsz").ToString().Split(" ")(0).Split(":")(1) + "</div>"
                        Else
                            result += "<div>" + dr("mxsz").ToString().Split(" ")(0) + "</div>"
                        End If
                        '处理第一个空格前面的数据 end'

                        For tmpc As Integer = 1 To dr("mxsz").ToString().Split(" ").Length - 1
                            result += "<div>"
                            result += dr("mxsz").ToString().Split(" ")(tmpc) + "</div>"
                        Next

                    Else
                        result += "<div>" + dr("mxsz") + "</div>"
                    End If
                Next
                '纤维含量 适应用于标签要体现类别 end 
            End If
        ElseIf ty = 3 Then

            For Each dr As DataRow In 需打印的成份.Rows
                result += dr("mxsz")
            Next

        End If

        If 充绒量 <> "" Then
            result += "<div>充绒量:" + 充绒量 + "</div>"
        End If
        Return result

    End Function
    ''' <summary>
    ''' 获取水洗标号型
    ''' </summary>
    ''' <param name="htzinfodr"></param>
    ''' <param name="istzsy">套装上衣标识</param>
    ''' <param name="istzxz">套装裤子标识</param>
    ''' <returns></returns>
    ''' <remarks></remarks>    
    Public Function getHX(ByVal htzinfodr As DataRow, ByVal istzsy As Integer, ByVal istzxz As Integer, ByVal ismj As Integer) As String
        Dim 号型 As String = ""
        If Integer.Parse(htzinfodr("hx2isExists").ToString()) = "0" Then
            '说明hx2没有内容
            号型 = htzinfodr("hx").ToString()
        Else
            If istzsy = 1 Or ismj = 1 Then
                号型 = htzinfodr("hx").ToString()
            ElseIf istzxz = 1 Then
                号型 = htzinfodr("hx2").ToString()
            Else
                号型 = "上衣:" + htzinfodr("hx").ToString() + " 裤子:" + htzinfodr("hx2").ToString()
            End If

        End If
        Return 号型
    End Function

    ''' <summary>
    ''' 水洗标材料信息
    ''' </summary>
    ''' <remarks></remarks>        
    Class SxChdmDataContent
        ''' <summary>
        ''' 套装的上衣/里外2件装的外装
        ''' </summary>
        ''' <remarks></remarks>
        'Public istzsy As Integer
        'Public istzxz As Integer
        Public sm As String
        Public lx As String
        'Public chdm As String
        Sub New(ByVal lx As String, ByVal sm As String)
            'Me.chdm = chdm
            'Me.istzsy = istzsy
            'Me.istzxz = istzxz
            Me.sm = sm
            Me.lx = lx
        End Sub
    End Class

    ''' <summary>
    ''' 尺码信息
    ''' </summary>
    ''' <remarks></remarks>
    Class SphhCmInfo
        Public cm As String
        Public 规格 As String '内裤打印时用到的
        Public 充绒信息 As List(Of Dictionary(Of String, String))
        Sub New(ByVal cm As String, ByVal 规格 As String, ByRef 充绒信息 As List(Of Dictionary(Of String, String)))
            Me.cm = cm
            Me.规格 = 规格
            Me.充绒信息 = 充绒信息
        End Sub
    End Class

    ''' <summary>
    ''' 货号标签信息数据 
    ''' </summary>
    ''' <remarks></remarks>
    Class SphhInfo
        Public 货号 As String
        Public 要显示的尺码 As String
        Public 品名 As String
        Public 品名上装 As String
        Public 品名下装 As String
        Public 品名西服三件套马甲 As String

        Public 样号 As String
        Public 版型 As String
        Public 等级 As String
        Public 执行标准 As String
        Public 安全技术类别 As String
        Public 洗涤方法 As String
        Public 洗涤方法上装 As String
        Public 洗涤方法下装 As String

        Public 警告语 As String
        Public 注意事项 As String
        Public 使用和贮藏 As String
        Public sx注意事项 As String
        Public sx使用和贮藏 As String
        Public kusx注意事项 As String
        Public kusx使用和贮藏 As String
        Public 腰卡图片 As String

        Public sxChdmList As Collections.Generic.List(Of SxChdmDataContent) '水洗标材料信息

        Public icoList As New Collections.Generic.List(Of Hashtable)
        Public SphhCmInfo As Collections.Generic.List(Of SphhCmInfo)
        Sub New(ByVal 货号 As String, ByVal 要显示的尺码 As String, ByVal 品名 As String, ByVal 品名上装 As String, ByVal 品名下装 As String, ByVal 品名西服三件套马甲 As String, ByVal 样号 As String, ByVal 版型 As String, ByVal 等级 As String, ByVal 执行标准 As String, _
                ByVal 安全技术类别 As String, ByVal 洗涤方法 As String, ByVal 洗涤方法上装 As String, ByVal 洗涤方法下装 As String, ByVal 警告语 As String, ByVal 注意事项 As String, ByVal 使用和贮藏 As String, ByVal sx注意事项 As String, ByVal sx使用和贮藏 As String, ByVal kusx注意事项 As String, ByVal kusx使用和贮藏 As String, ByVal 腰卡图片 As String, ByVal icoList As Collections.Generic.List(Of Hashtable), _
                ByVal sxChdmList As Collections.Generic.List(Of SxChdmDataContent), ByVal SphhCmInfo As Collections.Generic.List(Of SphhCmInfo))
            Me.货号 = 货号
            Me.要显示的尺码 = 要显示的尺码
            Me.品名 = 品名
            Me.品名上装 = 品名上装
            Me.品名下装 = 品名下装
            Me.品名西服三件套马甲 = 品名西服三件套马甲
            Me.样号 = 样号
            Me.版型 = 版型
            Me.等级 = 等级
            Me.执行标准 = 执行标准
            Me.安全技术类别 = 安全技术类别
            Me.洗涤方法 = 洗涤方法
            Me.洗涤方法上装 = 洗涤方法上装
            Me.洗涤方法下装 = 洗涤方法下装
            Me.腰卡图片 = 腰卡图片

            Me.警告语 = 警告语
            Me.注意事项 = 注意事项
            Me.使用和贮藏 = 使用和贮藏
            Me.sx注意事项 = sx注意事项
            Me.sx使用和贮藏 = sx使用和贮藏
            Me.kusx注意事项 = kusx注意事项
            Me.kusx使用和贮藏 = kusx使用和贮藏

            Me.icoList = icoList

            Me.sxChdmList = sxChdmList
            Me.SphhCmInfo = SphhCmInfo
        End Sub
    End Class
</script>
<body style="border: 0px; padding: 0px;">
    <form id="MyForm" name="MyForm" action="#" align="center" style="border: 0px; padding: 0px;">
        <%
            Dim lbdll As New lbclass.lbdll()
            Dim myconn As New SqlConnection()
            myconn.ConnectionString = "server='192.168.35.10';uid=ABEASD14AD;pwd=+AuDkDew;database=tlsoft "

            Dim path As String = "http://" + Request.Url.Authority

            Dim myid As Integer
            If Request.QueryString("myid") = "" Then
                myid = 0
            Else
                myid = Integer.Parse(Trim(Request.QueryString("myid")))
                ' 在查询做废的单据的时候有用
            End If

            Dim sphh As String = "" '货号1|尺码1|尺码2|,货号2|尺码1|尺码2
            Dim sphhSql As String = ""
            Dim htzinfoDs As Data.DataSet
            sphh = Trim(Request.QueryString("sphh"))

            '构造货号范围表'
            For Each item As String In sphh.Split(",")
                If item.Split("|").Length = 1 Then
                    sphhSql = sphhSql + " select '" + item + "' as sphh,'cm24' as cm union "
                Else
                    For tmpi As Integer = 1 To item.Split("|").Length - 2
                        sphhSql = sphhSql + " select '" + item + "' as sphh,'cm" + item.Split("|")(tmpi) + "' as cm union "
                    Next
                End If
            Next
            If sphhSql.Length = 0 And myid = 0 Then
                Response.Write("未传入货号")
                Response.End()

            ElseIf myid <> 0 Then
                sphhSql = " select a.sphh,MIN(CASE WHEN b.yphh is NULL THEN b2.cmdm ELSE  'cm24' END) AS cm  into #sphh  from yf_v_rinsing_sphh_all a  "
                sphhSql += " inner JOIN YX_T_Spdmb sp ON sp.sphh=a.sphh "
                sphhSql += " LEFT JOIN yx_V_sphxggb b ON sp.yphh=b.yphh AND b.cmdm='cm24' "
                sphhSql += " LEFT JOIN yx_V_sphxggb b2 ON sp.yphh=b2.yphh "
                sphhSql += " where a.lydjid=" + myid.ToString() + " and a.sphh='" + sphh + "' GROUP BY a.sphh ;"
                sphhSql += " select " + myid.ToString() + " as xzid,'" + sphh + "'  sphh into #range;"
            Else
                sphhSql = "select a.sphh,a.cm into #sphh from (" + sphhSql.Substring(0, sphhSql.Length - 6) + ") a ;"
                sphhSql += " select distinct sphh.lydjid as xzid,sphh.sphh into #range  "
                sphhSql += " from yf_v_rinsing_sphh_all sphh "
                sphhSql += " inner join (select distinct sphh from #sphh) hh on hh.sphh=sphh.sphh where  sphh.djzt=0 "
            End If
            '构造货号范围表 end '

            '合格证信息
            Dim MySql As String = sphhSql
            MySql += " select f.id,f.lydjid,f.dbhg,f.dbtg,f.ddh as '水洗材料',f.fk as '水洗材料下装',f.dbxx as '西服三件套马甲',pm.mc '品名',isnull(bsz.mc,'') '品名上装',isnull(bxz.mc,'') '品名下装',isnull(bmj.mc,'') as '品名西服三件套马甲' ,"
            MySql += " gb.dm '版型',yp.yphh '样号',case f.dsqk when '' then '' else f.dsqk+'：' end +f.shqk '洗涤方法',case f.dekz when '' then '' else f.dekz+'：' end+f.desz '洗涤方法上装',case f.jfk when '' then '' else f.jfk+'：' end+f.ghsyj '洗涤方法下装',xt.mc '警告语',g.mc '执行标准',f.jpg '等级',h.mc '安全技术类别',sphh.sphh '货号', m.notice '注意事项',m.store '使用和贮藏',"
            MySql += " sx.notice 'sx注意事项',sx.store 'sx使用和贮藏',kusx.notice 'kusx注意事项',kusx.store 'kusx使用和贮藏' "
            MySql += " into #myzb  "
            MySql += " from yf_T_bjdlb f "
            MySql += " inner join #range r on r.xzid=f.id   "
            MySql += " inner join yf_v_rinsing_sphh_all sphh on f.id=sphh.lydjid  and sphh.sphh=r.sphh "
            'MySql += " inner join (select a.bz as dj,a.id as zbid,a.mc as pm,b.mc as zxbz from Yf_T_bjdbjzb a,Yf_T_bjdbjzb b where a.ssid=b.id and a.lx=903 ) g on f.tplx=g.zbid "
            MySql += " inner join Yf_T_bjdbjzb pm on pm.id=f.tplx"
            MySql += " left join Yf_T_bjdbjzb bsz on f.dycs=bsz.id  "
            MySql += " left join Yf_T_bjdbjzb bxz on f.wtlx=bxz.id  "
            MySql += " left join Yf_T_bjdbjzb bmj on f.sftj=bmj.id  "

            MySql += " inner join Yf_T_bjdbjzb g on g.id=f.ddid"
            MySql += " inner join yx_T_spdmb sp on sp.sphh=sphh.sphh"
            MySql += " inner join yx_v_ypdmb yp on yp.yphh=sp.yphh "
            MySql += " left join  Yf_T_bjdbjzb gb on gb.id=yp.bhks  "
            'MySql += " left join yx_V_sphxggb k on k.yphh=yp.yphh /*and k.cmdm='cm24'*/ " 'yx_V_sphxggb 只取cmdm=cm24作为显示效果
            MySql += " inner join Yf_T_bjdbjzb h on h.lx=905 and f.sylx=h.id and h.tzid=1 "
            MySql += " left join ghs_t_xtdm xt on xt.id=isnull(f.kzx4,0) "
            MySql += " inner join yf_v_rinsingtemplate  m on m.id=f.lydjid  "
            MySql += " left join yf_v_rinsingtemplate sx on sx.id=f.dbhg "
            MySql += " left join yf_v_rinsingtemplate kusx on kusx.id=f.dbtg "
            MySql += "  where   f.lxid=903 and  f.tzid='1' ; "
            'table0 标签信息,一个货号一条记录
            MySql += "  select * from #myzb; "
            'table1 纤维含量
            MySql += " select zb.货号,  ROW_NUMBER() OVER(PARTITION BY zb.货号 order by xw.sytjid) sytjid, "
            MySql += " case when isnull(xw.sz,'')='/' or isnull(xw.pdjg,'')='' then xw.sz else xw.pdjg+':'+xw.sz end as mxsz,xw.glz   "
            MySql += " from #myzb zb   inner join yf_T_bjdmxb xw on zb.id=xw.mxid  and xw.lxid=903 ; "
            'table2图标
            MySql += " select a.* from ( "
            MySql += "   SELECT '主模版' lx, zb.货号, b.path,b.mc,b.dm FROM yf_v_rinsingtemplateico a INNER JOIN yf_V_rinsingico b ON a.icodm=b.dm  "
            MySql += "   inner join #myzb zb on zb.lydjid=a.mxid      "

            MySql += "   union all"
            MySql += "   SELECT '上装' lx ,zb.货号, b.path,b.mc,b.dm FROM yf_v_rinsingtemplateico a INNER JOIN yf_V_rinsingico b ON a.icodm=b.dm  "
            MySql += "   inner join #myzb zb on zb.dbhg=a.mxid     "

            MySql += "   union all"
            MySql += "   SELECT '下装' lx,zb.货号, b.path,b.mc,b.dm FROM yf_v_rinsingtemplateico a INNER JOIN yf_V_rinsingico b ON a.icodm=b.dm  "
            MySql += "   inner join #myzb zb on zb.dbtg=a.mxid      "
            MySql += "  ) a order by a.lx, cast( a.dm as int)   "

            'table3 各尺寸绒含量
            MySql += " SELECT b.lxbs, a.货号, hjyl=(mx.hsz+mx.bzsh),gg.hx crlhx,mx.cmdm "
            MySql += " FROM #myzb a "
            MySql += " inner join yx_T_spdmb sp on sp.sphh=a.货号"
            MySql += " INNER JOIN dbo.YX_T_Ypdmb yp ON sp.yphh=yp.yphh "
            MySql += " INNER JOIN YF_T_Bom b ON b.yphh=yp.yphh  AND b.cmfj=1 "
            MySql += " inner join cl_v_chdmb_all ch on ch.chdm=b.chdm "
            MySql += " inner join yf_T_bjdlb bj on bj.id=ch.bjid and bj.kzx1 =297"
            MySql += " INNER JOIN YF_T_Bomcmmx mx ON b.id=mx.id "
            MySql += " inner JOIN yx_V_sphxggb gg ON 'cm'+mx.cmdm=gg.cmdm AND yp.yphh=gg.yphh"
            'MySql += " WHERE yp.tml=3; "
            'table4 水洗标材料
            MySql += " select b.货号,b.lx, a.* from YF_v_SXBCHDM a inner join ( select 货号, 水洗材料 chdm,'上装' lx from #myzb union select 货号, 水洗材料下装 chdm,'下装' lx from #myzb union select 货号, 西服三件套马甲 chdm,'西服三件套马甲' lx from #myzb ) b on a.chdm=b.chdm ;"
            '5号型规格
            MySql += " select  a.货号, zh.cmdm,isnull(k.hx,case when lw.id is not  null then  '不打印' else '未维护' end )  as hx, "
            MySql += " isnull(k.hx2,case when lw.id is not  null then  '不打印' else '未维护' end)  as hx2,"
            MySql += " hx2isExists= case isnull(k.hx2,'') when '' then 0 else 1 end , "
            MySql += " isnull(k.gg,case when lw.id is not  null then  '不打印' else '未维护' end)  as gg "
            MySql += " from #myzb a"
            MySql += " inner join yx_T_spdmb sp on sp.sphh=a.货号"
            MySql += " inner join yx_v_ypdmb yp on yp.yphh=sp.yphh "
            MySql += " inner join yx_t_cmzh zh on zh.tml=yp.tml "
            MySql += " inner join (select distinct sphh from #sphh) kz on kz.sphh=a.货号  "
            MySql += " left join yx_V_sphxggb k on k.yphh=yp.yphh and zh.cmdm=k.cmdm"
            MySql += " left join yx_V_noneedhxgg lw on lw.id=yp.splbid "
            '6要显示哪些尺码
            MySql += " select * from #sphh;"
            '7货号腰卡
            MySql += " select distinct rg.sphh, a.mypic from wl_t_flkfjh a"
            MySql += " inner join yf_T_bjdlb lb on lb.dbxx=a.zlbh"
            MySql += " inner join Cl_v_chdmb dm on dm.bjid=lb.id"
            MySql += " inner join YF_T_Bom bom on bom.chdm=dm.chdm"
            MySql += " inner join ghs_v_clyq yq on a.clyq=yq.id and yq.mc='裤卡'"
            MySql += " inner join ghs_v_xtdm xt on a.lx = xt.id and xt.mc='包装物'"
            MySql += " inner join  yx_T_spdmb sp on sp.yphh=bom.yphh  "
            MySql += " inner join #range rg on rg.sphh=sp.sphh "

            MySql += " drop table #myzb; drop table #sphh;drop table #range;"

            htzinfoDs = lbdll.CreateDataSet(myconn, MySql)

            Dim htzinfo As DataTable = htzinfoDs.Tables(0).Copy() '水洗信息
            Dim hlinfo As DataTable = htzinfoDs.Tables(1).Copy() '纤维成份'
            Dim icoinfo As DataTable = htzinfoDs.Tables(2).Copy() '图标'
            Dim crlinfo As DataTable = htzinfoDs.Tables(3).Copy() '各尺寸绒含量
            Dim chdminfo As DataTable = htzinfoDs.Tables(4).Copy() '水洗标材料
            Dim hxgginfo As DataTable = htzinfoDs.Tables(5).Copy() '尺码表
            Dim showinfo As DataTable = htzinfoDs.Tables(6).Copy() '要显示哪些尺码
            Dim ykinfo As DataTable = htzinfoDs.Tables(7).Copy() '要显示哪些尺码
            Dim sphhInfoList As New List(Of SphhInfo)


            For Each sphhdr As DataRow In htzinfo.Rows

                Dim tmpxdff As String
                If sphhdr("洗涤方法").ToString() = "/" Then
                    tmpxdff = ""
                Else
                    tmpxdff = sphhdr("洗涤方法").ToString()
                End If
                Dim tmpxdff_sz As String
                If sphhdr("洗涤方法上装").ToString() = "/" Then
                    tmpxdff_sz = ""
                Else
                    tmpxdff_sz = sphhdr("洗涤方法上装").ToString()
                End If
                Dim tmpxdff_xz As String
                If sphhdr("洗涤方法下装").ToString() = "/" Then
                    tmpxdff_xz = ""
                Else
                    tmpxdff_xz = sphhdr("洗涤方法下装").ToString()
                End If
                '图标   
                Dim icoList As New List(Of Hashtable)
                For Each dr As DataRow In icoinfo.Select("货号='" + sphhdr("货号").ToString() + "'   ")
                    Dim hs As New Hashtable
                    hs.Add("path", dr("path"))
                    hs.Add("mc", dr("mc"))
                    hs.Add("lx", dr("lx"))
                    icoList.Add(hs)
                Next
                '取出腰卡
                Dim mypic As String = ""
                If ykinfo.Select("sphh='" + sphhdr("货号").ToString() + "'").Length > 0 Then
                    mypic = ykinfo.Select("sphh='" + sphhdr("货号").ToString() + "'")(0)("mypic")
                End If

                '水洗材料
                Dim sxChdmList As New List(Of SxChdmDataContent)
                For Each dr As DataRow In chdminfo.Select("货号='" + sphhdr("货号").ToString() + "'")
                    '这个对象有待优化
                    sxChdmList.Add(New SxChdmDataContent(dr("lx").ToString(), dr("sm").ToString()))
                Next

                Dim sphhCmInfoDic As New List(Of SphhCmInfo)
                For Each cmdr As DataRow In hxgginfo.Select("货号='" + sphhdr("货号").ToString() + "'")

                    Dim cmclr, crlhx As String '充绒量
                    Dim clrdr As DataRow() = crlinfo.Select("货号='" + sphhdr("货号").ToString() + "' and 'cm'+cmdm='" + cmdr("cmdm").ToString() + "'")
                    Dim clrList As New List(Of Generic.Dictionary(Of String, String))

                    If clrdr.Length >= 1 Then
                        For Each drtmp As DataRow In clrdr
                            Dim g As New Dictionary(Of String, String)
                            If Decimal.Parse(drtmp("hjyl").ToString()) > 0 Then
                                cmclr = String.Format("{0:####.#}", Math.Round(Decimal.Parse(drtmp("hjyl").ToString()) * 1000, 1)) + "g"
                                crlhx = drtmp("crlhx").ToString()
                                g.Add("cmclr", cmclr)
                                g.Add("crlhx", crlhx)
                                g.Add("lxbs", drtmp("lxbs").ToString())
                                clrList.Add(g)
                            Else
                                g.Add("cmclr", "")
                                g.Add("crlhx", "")
                                g.Add("lxbs", "0")
                                clrList.Add(g)
                            End If
                        Next
                    Else
                        Dim g As New Dictionary(Of String, String)
                        g.Add("cmclr", "")
                        g.Add("crlhx", "")
                        g.Add("lxbs", "0")
                        clrList.Add(g)
                    End If
                    sphhCmInfoDic.Add(New SphhCmInfo(cmdr("cmdm").ToString(), cmdr("gg").ToString(), clrList))
                Next

                sphhInfoList.Add( _
                        New SphhInfo(sphhdr("货号").ToString(), showinfo.Select("sphh='" + sphhdr("货号").ToString() + "'")(0).Item("cm").ToString(), _
                        sphhdr("品名").ToString(), sphhdr("品名上装").ToString(), sphhdr("品名下装").ToString(), sphhdr("品名西服三件套马甲").ToString(), sphhdr("样号").ToString(), sphhdr("版型").ToString(), _
                        sphhdr("等级").ToString(), sphhdr("执行标准").ToString(), _
                        sphhdr("安全技术类别").ToString(), tmpxdff, tmpxdff_sz, tmpxdff_xz, sphhdr("警告语").ToString(), _
                        sphhdr("注意事项").ToString(), sphhdr("使用和贮藏").ToString(), _
                        sphhdr("sx注意事项").ToString(), sphhdr("sx使用和贮藏").ToString(), _
                        sphhdr("kusx注意事项").ToString(), sphhdr("kusx使用和贮藏").ToString(), mypic, _
                        icoList, sxChdmList, sphhCmInfoDic))
            Next


            Dim 纤维含量, 充绒量, 号型, 品名, 版型, 样号, 洗涤方法, 图标, 简化图标, 警告语, 规格, 执行标准, 货号, 腰卡图片 As String
            'Response.Write(sphhInfoDic.Keys.Count)
            'Response.End()
        %>
        <%For Each sphhItem As SphhInfo In sphhInfoList%>
        <%
            货号 = sphhItem.货号
            版型 = sphhItem.版型
            样号 = sphhItem.样号
            警告语 = sphhItem.警告语
            执行标准 = sphhItem.执行标准
            腰卡图片 = sphhItem.腰卡图片
        %>
        <%For Each sphhCm As SphhCmInfo In sphhItem.SphhCmInfo

                If sphhCm.cm <> sphhItem.要显示的尺码 Then
                    Continue For
                End If

                Dim 号型datarow As DataRow
                If hxgginfo.Select("货号='" + 货号 + "' and cmdm='" + sphhCm.cm + "' ").Length = 1 Then
                    号型datarow = hxgginfo.Select("货号='" + 货号 + "' and cmdm='" + sphhCm.cm + "' ")(0)
                End If
                规格 = sphhCm.规格
        %>

        <div id="mainDiv" style="">
            <%
                For Each sxChdmObj As SxChdmDataContent In sphhItem.sxChdmList
                    Dim sxchdmkey As String = sxChdmObj.sm
                    Dim istzsy, istzxz, ismj As Integer
                    'istzsy = sphhItem.sxChdmDic.Item(sxchdmkey).istzsy
                    'istzxz = sphhItem.sxChdmDic.Item(sxchdmkey).istzxz   
                    If sxChdmObj.lx = "上装" Then
                        istzsy = 1
                        istzxz = 0
                        ismj = 0
                        If sphhItem.洗涤方法上装.Length = 0 Then
                            洗涤方法 = sphhItem.洗涤方法
                        Else
                            洗涤方法 = sphhItem.洗涤方法上装
                        End If
                        If sphhItem.品名上装.Length = 0 Then
                            品名 = sphhItem.品名
                        Else
                            品名 = sphhItem.品名上装
                        End If
                    ElseIf sxChdmObj.lx = "下装" Then
                        istzsy = 0
                        istzxz = 1
                        ismj = 0
                        If sphhItem.洗涤方法下装.Length = 0 Then
                            洗涤方法 = sphhItem.洗涤方法
                        Else
                            洗涤方法 = sphhItem.洗涤方法下装
                        End If

                        If sphhItem.品名下装.Length = 0 Then
                            品名 = sphhItem.品名
                        Else
                            品名 = sphhItem.品名下装
                        End If
                    ElseIf sxChdmObj.lx = "西服三件套马甲" Then
                        istzsy = 0
                        istzxz = 0
                        ismj = 1
                        If sphhItem.洗涤方法上装.Length = 0 Then
                            洗涤方法 = sphhItem.洗涤方法
                        Else
                            洗涤方法 = sphhItem.洗涤方法上装
                        End If
                        If sphhItem.品名西服三件套马甲.Length = 0 Then
                            品名 = sphhItem.品名
                        Else
                            品名 = sphhItem.品名西服三件套马甲
                        End If
                    End If

                    '处理充绒量表格使用到的数据
                    Dim crlhx() As String
                    crlhx = Nothing
                    Dim crl() As String
                    crl = Nothing

                    Dim tmpi As Integer = 0
                    Dim has2 As Boolean = False '有2种羽绒
                    Dim lxbsList As New List(Of String)
                    '1判断是否有多个羽绒
                    For Each key As SphhCmInfo In sphhItem.SphhCmInfo
                        For Each d As Dictionary(Of String, String) In key.充绒信息
                            If lxbsList.Contains(d.Item("lxbs")) = False And d.Item("cmclr").Length > 0 Then
                                lxbsList.Add(d.Item("lxbs"))
                            End If
                        Next
                    Next

                    If lxbsList.Count > 1 Then
                        has2 = True
                    End If
                    'Response.Write(sxChdmObj.lx)
                    'Response.Write(JsonConvert.SerializeObject(sphhItem.SphhCmInfo))
                    'Response.Write("</br>")
                    For Each key As SphhCmInfo In sphhItem.SphhCmInfo

                        For Each d As Dictionary(Of String, String) In key.充绒信息
                            If has2 Then
                                If (sxChdmObj.lx = "上装" And d.Item("lxbs") = "1") Or (sxChdmObj.lx <> "上装" And d.Item("lxbs") = "0") Then
                                    '如果打印的是上装,但当前材料配料卡有打勾内胆 那么跳过
                                    '如果打印的是非上装,但当前材料配料卡没有打勾,那么跳过
                                    'If sxChdmObj.lx = "上装" Then
                                    '    Response.Write(key.cm + ",")
                                    '    Response.Write(crl.Length)
                                    'End If
                                    Continue For
                                End If
                            End If

                            If d.Item("cmclr").Length > 0 Then
                                ReDim Preserve crlhx(tmpi + 1)
                                crlhx(tmpi) = d.Item("crlhx")
                                ReDim Preserve crl(tmpi + 1)
                                crl(tmpi) = d.Item("cmclr")
                                tmpi = tmpi + 1
                                If key.cm = sphhItem.要显示的尺码 Then
                                    充绒量 = d.Item("cmclr")
                                End If
                            End If
                        Next
                    Next
                    '处理充绒量表格使用到的数据 end

                    If sxchdmkey = ("羽绒单衣") Or sxchdmkey = ("茄克衫v2") Or sxchdmkey = ("休闲服时尚羽绒服v2") Or sxchdmkey = ("休闲服时尚羽绒服") Or sxchdmkey = ("时尚羽绒服l2") Then
                        充绒量 = ""
                    End If
                    纤维含量 = getCF(SreeenDataTable(hlinfo, "货号='" + 货号 + "' ", ""), 充绒量, 0, istzsy, istzxz, ismj)
                    号型 = getHX(号型datarow, istzsy, istzxz, ismj)

                    Dim icolx As String = ""
                    If sphhItem.sx注意事项.Length = 0 And sphhItem.kusx注意事项.Length = 0 Then
                        icolx = "主模版"
                    Else
                        icolx = sxChdmObj.lx
                    End If

                    图标 = "<div>"
                    简化图标 = ""
                    For Each ico As Hashtable In sphhItem.icoList
                        If ico.Item("lx") = icolx Then
                            图标 += "<div><img style='width:3mm' src='" + path + "/" + ico.Item("path") + "' />&#12288;" + ico.Item("mc") + "</div>"
                            简化图标 += "<img style='width:3mm' src='" + path + "/" + ico.Item("path") + "' />"
                        End If
                    Next
                    图标 += "</div>"

            %>            
            <% If sxchdmkey = ("水洗牛仔裤") Then %>
            <!--水洗牛仔裤 -->
            <div style="width: 35mm; height: 140mm; float: left; overflow: hidden; border: 1px solid Black;">
                <div style=" padding: 5mm 0mm 6.8mm 0mm; text-align: center; white-space: nowrap;">
                    <div style="text-align: center;" class="bt">
                        <img style="width: 25mm" src="sxtb/lilanz-ku.png"></img></div>
                </div>
                <div style="height: 4.06mm; font-size: 8pt; overflow: hidden;">
                    <div style="padding: 0mm 0mm 0mm 3.59mm; height: 100%; overflow: hidden">品名:<%=品名 %></div>
                </div>
                <div style="height: 4.06mm; font-size: 8pt; overflow: hidden;">
                    <div style="padding: 0mm 0mm 0mm 3.59mm; height: 100%; overflow: hidden">号型:<%=号型 %></div>
                </div>
                <div style="height: 4.06mm; font-size: 8pt; overflow: hidden;">
                    <div style="padding: 0mm 0mm 0mm 3.59mm; white-space: nowrap; overflow: hidden;">版型:<%=版型 %></div>
                </div>
                <div style="height: 4.06mm; font-size: 8pt; overflow: hidden;">
                    <div style="padding: 0mm 0mm 0mm 3.59mm; height: 100%; overflow: hidden">纤维含量:</div>
                </div>
                <div style=" padding: 0mm 0mm 0mm 6.6mm; font-size: 8pt; overflow: hidden;"><%=纤维含量%></div>

                <div style="height: 6.88mm; font-size: 8pt; overflow: hidden;">
                    <div style="width: 70%; float: left; padding: 1mm 0mm 0mm 4.61mm; height: 100%; overflow: hidden"><%=样号 %></div>
                    <div style="width: 30%; float: left; height: 100%; padding: 1mm 0mm 0mm 0mm; overflow: hidden"></div>
                </div>

                <div style="height: auto; font-size: 6.2pt; overflow: hidden;">
                    <div style="padding: 0mm 0mm 0mm 3.24mm; height: 100%; overflow: hidden">洗涤方法:</div>
                </div>

                <div style="height: 18.86mm; font-size: 6.2pt; overflow: hidden;">
                    <div style="padding: 0mm 0mm 0mm 3.24mm; height: 100%; overflow: hidden">                     
                        <%=图标 %>
                    </div>
                </div>
          
                <div style=" font-size: 6.2pt; overflow: hidden;">
                    <div style="padding: 0mm 0mm 0mm 3.24mm; height: 100%; overflow: hidden"><%=洗涤方法 %></div>
                </div>
                <div style=" font-size: 6.2pt; overflow: hidden;">
                    <div style="padding: 0mm 0mm 0mm 3.24mm; height: 100%; overflow: hidden"><%=警告语 %></div>
                </div>

            </div>
            <!--水洗牛仔裤 end -->
            
            <% Elseif sxchdmkey = ("水洗牛仔裤v2") Then %>
            <!--水洗牛仔裤v2-->
            <div style="width: 35mm; height: 70mm; float: left; overflow: hidden; border: 1px solid Black;">

                <div style=" padding: 5mm 0mm 6.8mm 0mm; text-align: center; white-space: nowrap;">
                    <div style="text-align: center;" class="bt">
                        <img style="width: 25mm" src="sxtb/lilanz-ku.png"></img></div>
                </div>
                <div style="height: 4.06mm; font-size: 8pt; overflow: hidden;">
                    <div style="padding: 0mm 0mm 0mm 3.59mm; height: 100%; overflow: hidden">品名:<%=品名 %></div>
                </div>
                <%
                    if 样号<>货号 Then
                %>
                    <div style="height: 4.06mm; font-size: 7pt; overflow: hidden;">
                        <div style="padding: 0mm 0mm 0mm 3.59mm; height: 100%; overflow: hidden"><%=货号 %>-<%=样号 %></div>
                    </div>
                 <% End If %>
                <div style="height: 4.06mm; font-size: 8pt; overflow: hidden;">
                    <div style="padding: 0mm 0mm 0mm 3.59mm; height: 100%; overflow: hidden">号型:<%=号型 %></div>
                </div>
                <div style="height: 4.06mm; font-size: 8pt; overflow: hidden;">
                    <div style="padding: 0mm 0mm 0mm 3.59mm; white-space: nowrap; overflow: hidden;">版型:<%=版型 %></div>
                </div>
                <div style="height: 4.06mm; font-size: 8pt; overflow: hidden;">
                    <div style="padding: 0mm 0mm 0mm 3.59mm; height: 100%; overflow: hidden">纤维含量:</div>
                </div>
                <div style="padding: 0mm 0mm 0mm 6.6mm; font-size: 8pt; overflow: hidden;">
                    <%=纤维含量%>
                </div>
                <%
                    If 样号 = 货号 Then
                %>                
                    <div style="height: 6.88mm; font-size: 8pt; overflow: hidden;">
                        <div style="width: 70%; float: left; padding: 1mm 0mm 0mm 4.61mm; height: 100%; overflow: hidden"><%=样号 %></div>
                        <div style="width: 30%; float: left; height: 100%; padding: 1mm 0mm 0mm 0mm; overflow: hidden"></div>
                    </div>
                <% End If %>

            </div>
            <!--左右分隔 -->
            <div style="width: 35mm; height: 70mm; float: left; overflow: hidden; border: 1px solid Black;">
                <div style="text-align:center;padding-top: 5mm; font-size: 6.2pt; overflow: hidden;">
                    <img style="height:10mm;" alt="" src="../BB_apply/getCode128.aspx?code=<%=货号 %>" />
                </div>
                <div style="font-size: 6.2pt; overflow: hidden;">
                    <div style="padding: 0mm 0mm 0mm 3.24mm; height: 100%; overflow: hidden">洗涤方法:</div>
                </div>
                <div style="font-size: 6.2pt; overflow: hidden;">
                    <div style="padding: 0mm 0mm 0mm 3.24mm; height: 100%; overflow: hidden">
                        
                        <%=图标 %>
                        <%=洗涤方法 %>
                    </div>
                </div>      

                <div style="height: 32mm; font-size: 6.2pt; overflow: hidden;">
                    <div style="padding: 0mm 0mm 0mm 3.24mm; height: 100%; overflow: hidden"><%=警告语 %></div>
                </div>

            </div>
            <!--水洗牛仔裤v2 end-->


            <%  Elseif sxchdmkey = ("休闲裤") Then%>
            <!-- 休闲裤-->
            <div style="width: 35mm; height: 120mm; float: left; overflow: hidden; border: 1px solid Black;">

                <div style="padding: 5mm 0mm 0mm 0mm; white-space: nowrap; text-align: center; overflow: hidden;">
                    <div style="text-align: center;" class="bt">
                        <img style="width: 25mm" src="sxtb/lilanz-ku.png"></img></div>
                </div>
                <div style="height: 4.06mm; font-size: 8pt; overflow: hidden;">
                    <div style="padding: 0mm 0mm 0mm 3.59mm; height: 100%; overflow: hidden">品名:<%=品名 %></div>
                </div>
                <div style="height: 4.06mm; font-size: 8pt; overflow: hidden;">
                    <div style="padding: 0mm 0mm 0mm 3.59mm; height: 100%; overflow: hidden">号型:<%=号型 %></div>
                </div>
                <div style="height: 4.06mm; font-size: 8pt; overflow: hidden;">
                    <div style="padding: 0mm 0mm 0mm 3.59mm; white-space: nowrap; overflow: hidden">版型:<%=版型 %></div>
                </div>
                <div style="height: 4.06mm; font-size: 8pt; overflow: hidden;">
                    <div style="padding: 0mm 0mm 0mm 3.59mm; height: 100%; overflow: hidden">纤维含量:</div>
                </div>
                <div style=" padding: 0mm 0mm 0mm 6.6mm; font-size: 8pt; overflow: hidden;"><%=纤维含量%></div>


                <div style="height: 6.88mm; font-size: 8pt; overflow: hidden;">
                    <div style="width: 70%; float: left; padding: 1mm 0mm 0mm 4.61mm; height: 100%; overflow: hidden"><%=样号 %></div>
                    <div style="width: 30%; float: left; padding: 1mm 0mm 0mm 0mm; height: 100%; overflow: hidden"></div>
                </div>


                <div style="height: auto; font-size: 6.2pt; overflow: hidden;">
                    <div style="padding: 0mm 0mm 0mm 3.24mm; height: 100%; overflow: hidden">洗涤方法:</div>
                </div>

                <div style="font-size: 6.2pt; overflow: hidden;">
                    <div style="padding: 0mm 0mm 0mm 3.24mm; height: 100%; overflow: hidden">
                        
                        <%=图标 %>
                        <%=洗涤方法 %>
                    </div>
                </div>

            </div>
            <!-- 休闲裤 END-->
   

            <%  Elseif sxchdmkey = ("休闲裤v2") Then%>
            <!-- 休闲裤V2-->
            <div style="width: 35mm; height: 60mm; float: left; overflow: hidden; border: 1px solid Black;">
                <div style=" padding: 5mm 0mm 0mm 0mm; white-space: nowrap; text-align: center; overflow: hidden;">
                    <div style="text-align: center;" class="bt">
                        <img style="width: 25mm" src="<%=path%>/tl_yf/sxtb/lilanz-ku.png"></img></div>
                </div>
                <div style="height: 4.06mm; font-size: 8pt; overflow: hidden;">
                    <div style="padding: 0mm 0mm 0mm 3.59mm; height: 100%; overflow: hidden">品名:<%=品名 %></div>
                </div>
                <%
                    if 样号<>货号 Then
                %>
                    <div style="height: 4.06mm; font-size: 7pt; overflow: hidden;">
                        <div style="padding: 0mm 0mm 0mm 3.59mm; height: 100%; overflow: hidden"><%=货号 %>-<%=样号 %></div>
                    </div>
                 <% End If %>
                <div style="height: 4.06mm; font-size: 8pt; overflow: hidden;">
                    <div style="padding: 0mm 0mm 0mm 3.59mm; height: 100%; overflow: hidden">号型:<%=号型 %></div>
                </div>
                <div style="height: 4.06mm; font-size: 8pt; overflow: hidden;">
                    <div style="padding: 0mm 0mm 0mm 3.59mm; white-space: nowrap; overflow: hidden">版型:<%=版型 %></div>
                </div>
                <div style="height: 4.06mm; font-size: 8pt; overflow: hidden;">
                    <div style="padding: 0mm 0mm 0mm 3.59mm; height: 100%; overflow: hidden">纤维含量:</div>
                </div>
                <div style="padding: 0mm 0mm 0mm 6.6mm; font-size: 8pt; overflow: hidden;"><%=纤维含量%></div>                
                <%
                    If 样号 = 货号 Then
                %>                
                    <div style="height: 6.88mm; font-size: 8pt; overflow: hidden;">
                        <div style="width: 70%; float: left; padding: 1mm 0mm 0mm 4.61mm; height: 100%; overflow: hidden"><%=样号 %></div>
                        <div style="width: 30%; float: left; height: 100%; padding: 1mm 0mm 0mm 0mm; overflow: hidden"></div>
                    </div>
                <% End If %>

            </div>
            <!--左右分隔 -->
            <div style="width: 35mm; height: 60mm; float: left; overflow: hidden; border: 1px solid Black;">
                <div style="text-align:center;padding-top: 15mm; font-size: 6.2pt; overflow: hidden;">
                    <img style="height:10mm;" alt="" src="<%=path %>/BB_apply/getCode128.aspx?code=<%=货号 %>" />
                </div>
                <div style="font-size: 6.2pt; overflow: hidden;">
                    <div style="padding: 0mm 0mm 0mm 3.24mm; height: 100%; overflow: hidden">洗涤方法:</div>
                </div>

                <div style="font-size: 6.2pt; overflow: hidden;">
                    <div style="padding: 0mm 0mm 0mm 3.24mm; height: 100%; overflow: hidden">
                        
                        <%=图标 %>
                        <%=洗涤方法 %>
                    </div>
                </div>

            </div>
            <!-- 休闲裤V2 END-->
       

            <%  Elseif sxchdmkey = ("男西裤") Then %>
            <!-- 男西裤-->
            <div style="width: 35mm; height: 120mm; float: left; border: 1px solid Black;">
                <div style=" padding: 5mm 0mm 0mm 0mm; text-align: center; white-space: nowrap; overflow: hidden;">
                    <div style="text-align: center;" class="bt">
                        <img style="width: 25mm" src="sxtb/lilanz-ku.png"></img></div>
                </div>

                <div style="height: 4.06mm; font-size: 8pt; overflow: hidden;">
                    <div style="padding: 0mm 0mm 0mm 3.59mm; height: 100%; overflow: hidden">品名:<%=品名 %></div>
                </div>
                <div style="height: 4.06mm; font-size: 8pt; overflow: hidden;">
                    <div style="padding: 0mm 0mm 0mm 3.59mm; height: 100%; overflow: hidden">号型:<%=号型 %></div>
                </div>

                <div style="height: 4.06mm; font-size: 8pt; overflow: hidden;">
                    <div style="padding: 0mm 0mm 0mm 3.59mm; height: 100%; overflow: hidden">纤维含量:</div>
                </div>
                <div style=" padding: 0mm 0mm 0mm 6.6mm; font-size: 8pt; overflow: hidden;"><%=纤维含量 %></div>


                <div style="height: 6.88mm; font-size: 8pt; overflow: hidden;">
                    <div style="width: 70%; float: left; padding: 1mm 0mm 0mm 4.61mm; height: 100%; overflow: hidden"><%=样号 %></div>
                    <div style="width: 30%; float: left; padding: 1mm 0mm 0mm 0mm; height: 100%; overflow: hidden"></div>
                </div>


                <div style="height: auto; font-size: 6.2pt; overflow: hidden;">
                    <div style="padding: 0mm 0mm 0mm 3.24mm; height: 100%; overflow: hidden">洗涤方法:</div>
                </div>

                <div style="font-size: 6.2pt; overflow: hidden;">
                    <div style="padding: 0mm 0mm 0mm 3.24mm; height: 100%; overflow: hidden">
                        
                        <%=图标 %>
                        <%=洗涤方法 %>
                    </div>
                </div>

            </div>
            <!-- 男西裤 END-->
    

            <%  Elseif sxchdmkey = ("男西裤v2") Then%>
            <!-- 男西裤V2-->
            <div style="width: 35mm; height: 60mm; float: left; border: 1px solid Black;">
                <div style=" padding: 5mm 0mm 0mm 0mm; text-align: center; white-space: nowrap; overflow: hidden;">
                    <div style="text-align: center;" class="bt">
                        <img style="width: 25mm" src="sxtb/lilanz-ku.png"></img></div>
                </div>

                <div style="height: 4.06mm; font-size: 8pt; overflow: hidden;">
                    <div style="padding: 0mm 0mm 0mm 3.59mm; height: 100%; overflow: hidden">品名:<%=品名 %></div>
                </div>
                <%
                    if 样号<>货号 Then
                %>
                    <div style="height: 4.06mm; font-size: 7pt; overflow: hidden;">
                        <div style="padding: 0mm 0mm 0mm 3.59mm; height: 100%; overflow: hidden"><%=货号 %>-<%=样号 %></div>
                    </div>
                 <% End If %>
                <div style="height: 34mm; font-size: 8pt; overflow: hidden;">
                    <div style=" font-size: 8pt; overflow: hidden;">
                        <div style="padding: 0mm 0mm 0mm 3.59mm; height: 100%; overflow: hidden">号型:<%=号型 %></div>
                    </div>

                    <div style="height: 4.06mm; font-size: 8pt; overflow: hidden;">
                        <div style="padding: 0mm 0mm 0mm 3.59mm; height: 100%; overflow: hidden">纤维含量:</div>
                    </div>
                    <div style=" padding: 0mm 0mm 0mm 6.6mm; font-size: 8pt; overflow: hidden;"><%=纤维含量 %></div>
                </div>
                <%
                    if 样号=货号 Then
                %>                
                    <div style="height: 6.88mm; font-size: 8pt; overflow: hidden;">
                        <div style="width: 70%; float: left; padding: 1mm 0mm 0mm 4.61mm; height: 100%; overflow: hidden"><%=样号 %></div>
                        <div style="width: 30%; float: left; height: 100%; padding: 1mm 0mm 0mm 0mm; overflow: hidden"></div>
                    </div>
                <% End If %>


            </div>
            <!--左右分隔 -->
            <div style="width: 35mm; height: 60mm; float: left; border: 1px solid Black;">
                <div style="text-align:center;padding-top: 15mm; font-size: 6.2pt; overflow: hidden;">
                    <img alt="" style="height:10mm;" src="../BB_apply/getCode128.aspx?code=<%=货号 %>" />
                </div>
                <div style="font-size: 6.2pt; overflow: hidden;">
                    <div style="padding: 0mm 0mm 0mm 3.24mm; height: 100%; overflow: hidden">洗涤方法:</div>
                </div>

                <div style="font-size: 6.2pt; overflow: hidden;">
                    <div style="padding: 0mm 0mm 0mm 3.24mm; height: 100%; overflow: hidden">
                        
                        <%=图标 %>
                        <%=洗涤方法 %>
                    </div>
                </div>

            </div>
            <!-- 男西裤V2 END-->
            <% elseIf sxchdmkey = ("休闲衬衫") Then %>
            <!-- 休闲衬衫-->
            <div style="width: 35mm; height: 120mm; float: left; border: 1px solid Black;">

                <div style=" padding: 5mm 0mm 0mm 0mm; text-align: center; white-space: nowrap; overflow: hidden;">
                    <div style="text-align: center;" class="bt">
                        <img style="width: 25mm" src="sxtb/lilanz-ku.png"></img></div>
                </div>
                <div style="height: 4.06mm; font-size: 8pt; overflow: hidden;">
                    <div style="padding: 0mm 0mm 0mm 3.59mm; overflow: hidden">品名:<%=品名 %></div>
                </div>

                <div style="height: 4.06mm; font-size: 8pt; overflow: hidden;">
                    <div style="padding: 0mm 0mm 0mm 3.59mm; height: 100%; overflow: hidden">纤维含量:</div>
                </div>
                <div style=" padding: 0mm 0mm 0mm 6.6mm; font-size: 8pt; overflow: hidden;"><%=纤维含量 %></div>


                <div style="height: 6.88mm; font-size: 8pt; overflow: hidden;">
                    <div style="width: 70%; float: left; padding: 1mm 0mm 0mm 4.61mm; height: 100%; overflow: hidden"><%=样号 %></div>
                    <div style="width: 30%; float: left; padding: 1mm 0mm 0mm 0mm; height: 100%; overflow: hidden"></div>
                </div>


                <div style="height: auto; font-size: 6.2pt; overflow: hidden;">
                    <div style="padding: 0mm 0mm 0mm 3.24mm; height: 100%; overflow: hidden">洗涤方法:</div>
                </div>

                <div style="font-size: 6.2pt; overflow: hidden;">
                    <div style="padding: 0mm 0mm 0mm 3.24mm; height: 100%; overflow: hidden">
                        
                        <%=图标 %>
                        <%=洗涤方法 %>
                    </div>
                </div>

            </div>
            <!-- 休闲衬衫 END-->
            <% elseIf sxchdmkey = ("休闲衬衫v2") Then %>
            <!-- 休闲衬衫v2 -->
            <div style="width: 35mm; height: 60mm; float: left; border: 1px solid Black;">
                <div style=" padding: 5mm 0mm 0mm 0mm; text-align: center; white-space: nowrap; overflow: hidden;">
                    <div style="text-align: center;" class="bt">
                        <img style="width: 25mm" src="sxtb/lilanz-ku.png"></img></div>
                </div>
                <div style="height: 4.06mm; font-size: 8pt; overflow: hidden;">
                    <div style="padding: 0mm 0mm 0mm 3.59mm; overflow: hidden">品名:<%=品名 %></div>
                </div>
                <%
                    if 样号<>货号 Then
                %>
                    <div style="height: 4.06mm; font-size: 7pt; overflow: hidden;">
                        <div style="padding: 0mm 0mm 0mm 3.59mm; height: 100%; overflow: hidden"><%=货号 %>-<%=样号 %></div>
                    </div>
                 <% End If %>

                <div style="height: 4.06mm; font-size: 8pt; overflow: hidden;">
                    <div style="padding: 0mm 0mm 0mm 3.59mm; height: 100%; overflow: hidden">纤维含量:</div>
                </div>
                <div style="padding: 0mm 0mm 0mm 6.6mm; font-size: 8pt; overflow: hidden;"><%=纤维含量 %></div>
                
                <%
                    if 样号=货号 Then
                %>                
                    <div style="height: 6.88mm; font-size: 8pt; overflow: hidden;">
                        <div style="width: 70%; float: left; padding: 1mm 0mm 0mm 4.61mm; height: 100%; overflow: hidden"><%=样号 %></div>
                        <div style="width: 30%; float: left; height: 100%; padding: 1mm 0mm 0mm 0mm; overflow: hidden"></div>
                    </div>
                <% End If %>

            </div>
            <!--左右分隔 -->
            <div style="width: 35mm; height: 60mm; float: left; border: 1px solid Black;">
                <div style="text-align:center;padding-top: 15mm; font-size: 6.2pt; overflow: hidden;">
                    <img alt="" style="height:10mm;" src="../BB_apply/getCode128.aspx?code=<%=货号 %>" />
                </div>
                <div style="font-size: 6.2pt; overflow: hidden;">
                    <div style="padding: 0mm 0mm 0mm 3.24mm; height: 100%; overflow: hidden">洗涤方法:</div>
                </div>

                <div style="font-size: 6.2pt; overflow: hidden;">
                    <div style="padding: 0mm 0mm 0mm 3.24mm; height: 100%; overflow: hidden">
                        
                        <%=图标 %>
                        <%=洗涤方法 %>
                    </div>
                </div>

            </div>
            <!-- 休闲衬衫v2 END -->
            <% elseIf sxchdmkey = ("帽子围巾领带领结水洗标") Then %>
            <!-- 帽子围巾领带领结水洗标 -->
            <div style="width: 25mm; height: 30mm; float: left; font-size:5pt; border: 1px solid Black;">
                <div style=" padding: 5mm 0mm 0mm 0mm; text-align: center; white-space: nowrap; overflow: hidden;">
                    <div style="text-align: center;" class="bt">
                        <img style="width: 20mm" src="sxtb/lilanz-ku.png"></img></div>
                </div>
                <div style="overflow: hidden;">
                    <div style="padding: 2mm 0mm 0mm 3.59mm; overflow: hidden">品名:<%=品名 %></div>
                </div>
                <%
                    if 样号<>货号 Then
                %>
                    <div style="   overflow: hidden;">
                        <div style="padding: 0mm 0mm 0mm 3.59mm; height: 100%; overflow: hidden"><%=货号 %>-<%=样号 %></div>
                    </div>
                 <% else %>                            
                    <div style="  overflow: hidden;">
                        <div style="width: 70%; float: left; padding: 1mm 0mm 0mm 4.61mm; height: 100%; overflow: hidden"><%=样号 %></div>
                        <div style="width: 30%; float: left; height: 100%; padding: 1mm 0mm 0mm 0mm; overflow: hidden"></div>
                    </div>
                <% End If %>
                <div >
                        <div style="padding: 0mm 0mm 0mm 3.59mm; font-size: 6.5pt;">规格:<%=规格 %></div>
                    </div>
                <div style="  overflow: hidden;">
                    <div style="padding: 0mm 0mm 0mm 3.59mm; height: 100%; overflow: hidden">纤维含量:</div>
                </div>
                <div style="padding: 0mm 0mm 0mm 6.6mm;   overflow: hidden;"><%=纤维含量 %></div>
            </div>
            <!--左右分隔 -->
            <div style="width: 25mm;font-size: 5pt; height: 30mm; float: left; border: 1px solid Black;">
           
                <div style="overflow: hidden;">
                    <div style="padding: 2mm 0mm 0mm 1mm; height: 100%; overflow: hidden">洗涤方法:</div>
                </div>

                <div style="overflow: hidden;">
                    <div style="padding: 0mm 0mm 0mm 1mm; height: 100%; overflow: hidden">
                        
                        <%=图标 %>
                        <%=洗涤方法 %>
                    </div>
                </div>

            </div>
            <!-- 帽子围巾领带领结水洗标 END -->
            <% elseIf sxchdmkey = ("短裤内裤") Then %>
            <!-- 短裤内裤 -->
            <div style="height: 25mm; width: 94mm; float: left; border: 1px solid Black; overflow: hidden;">
                <div style="height: 25mm; width: 40mm; float: left;">
                    <div style="height: 15.12mm;">
                        <div style="padding: 8.35mm 0mm 0mm 7mm; text-align: center;" class="bt">
                            <img style="width: 30.5mm" src="sxtb/lilanz-duanku.png"></img></div>
                    </div>
                    <div style="height: 3.1mm;">
                        <div style="padding: 0mm 0mm 0mm 14.9mm; font-size: 6.5pt;">号型:<%=号型 %></div>
                    </div>
                    <div style="height: 3.1mm;">
                        <div style="padding: 0mm 0mm 0mm 14.9mm; font-size: 6.5pt;">规格:<%=规格 %></div>
                    </div>
                </div>

                <div style="height: 25mm; width: 27mm; float: left; overflow: hidden;">
                    <div style="height: 6.16mm;">
                        <div style="padding: 3.58mm 0mm 0mm 3.28mm; font-size: 5.426pt;">品名:<%=品名 %></div>
                    </div>
                    <div style="height: 2.91mm;">
                        <div style="padding: 0mm 0mm 0mm 3.28mm; font-size: 5.426pt;">执行标准:<%=执行标准 %></div>
                    </div>
                    <div style="height: 2.91mm;">
                        <div style="padding: 0mm 0mm 0mm 3.28mm; font-size: 5.426pt;">货号:<%=货号 %></div>
                    </div>
                    <div style="height: 3.83mm;">
                        <div style="height: 4.5mm; width: 8mm; padding: 0mm 0mm 0mm 3.28mm; font-size: 5.426pt; float: left; white-space: nowrap; overflow: hidden;">成份:</div>
                        <div style="height: 4.5mm; width: 19mm; font-size: 5.426pt; float: left; white-space: nowrap; overflow: hidden;"><%=纤维含量 %></div>
                    </div>
                    <div style="height: 6.8mm;">
                        <div style="padding: 0mm 0mm 0mm 3.28mm; font-size: 5.426pt;">洗涤方法:</div>
                        <div style="padding: 0mm 0mm 0mm 3.28mm; font-size: 4.778pt;"><%=洗涤方法 %></div>
                    </div>
                </div>

                <div style="height: 25mm; width: 26mm; float: left; overflow: hidden;">

                    <div style="height: 80%; font-size: 4.778pt; padding: 3.63mm 0mm 0mm 1.11mm"><%=图标 %></div>


                    <div style="height: 20%; font-size: 4.778pt; overflow: hidden; padding: 0mm 0mm 0mm 1.11mm">批号:</div>

                </div>
            </div>
            <!-- 短裤内裤 END -->
            <% elseIf sxchdmkey = ("短裤内裤v2") Then %>
            <!-- 短裤内裤v2 -->
            <div style="height: 40mm; width: 35mm; float: left; border: 1px solid Black; overflow: hidden;">

                <div style=" padding: 5mm 0mm 0mm 0mm; text-align: center; white-space: nowrap; overflow: hidden;">
                    <div style="text-align: center;" class="bt">
                        <img style="width: 25mm" src="sxtb/lilanz-ku.png"></img></div>
                </div>
                <div style="height: 3.1mm;">
                    <div style="padding: 0mm 0mm 0mm 3.28mm; font-size: 5.426pt;">品名:<%=品名 %></div>
                </div>
                <%
                    if 样号<>货号 Then
                %>
                    <div style="height: 4.06mm; font-size: 7pt; overflow: hidden;">
                        <div style="padding: 0mm 0mm 0mm 3.59mm; height: 100%; overflow: hidden"><%=货号 %>-<%=样号 %></div>
                    </div>
                 <% End If %>
                <div style="height: 3.1mm;">
                    <div style="width: 70%; padding: 0mm 0mm 0mm 3.28mm; font-size: 6.5pt; float: left;">号型:<%=号型 %></div>
                    <div style="width: 30%; font-size: 6.5pt; float: left;">规格:<%=规格 %></div>
                </div>

                <div style="">
                    <div style="height: 4.5mm; width: 12mm; padding: 0mm 0mm 0mm 3.28mm; font-size: 5.426pt; float: left; white-space: nowrap; overflow: hidden;">纤维含量:</div>
                    <div style="width: 19mm; font-size: 5.426pt; float: left; white-space: nowrap; overflow: hidden;"><%=纤维含量 %></div>
                </div>
                
                <%
                    if 样号=货号 Then
                %>                
                    <div style="height: 6.88mm; font-size: 8pt; overflow: hidden;">
                        <div style="width: 70%; float: left; padding: 1mm 0mm 0mm 4.61mm; height: 100%; overflow: hidden"><%=样号 %></div>
                        <div style="width: 30%; float: left; height: 100%; padding: 1mm 0mm 0mm 0mm; overflow: hidden"></div>
                    </div>
                <% End If %>

            </div>
            <!--左右分隔 -->
            <div style="height: 40mm; width: 35mm; float: left; border: 1px solid Black; overflow: hidden;">
                <div style="text-align:center;padding-top: 15mm; font-size: 6.2pt; overflow: hidden;">
                    <img alt="" style="height:10mm;" src="../BB_apply/getCode128.aspx?code=<%=货号 %>" />
                </div>
                <div style="height: 6.8mm; overflow: hidden;">
                    <div style="padding: 0mm 0mm 0mm 3.28mm; font-size: 5.426pt;">洗涤方法:</div>
                    <div style="padding: 0mm 0mm 0mm 3.28mm; font-size: 4.778pt;"><%=洗涤方法 %></div>
                </div>
                <div style="height: 25mm; width: 26mm; overflow: hidden;">
                    <div style="height: 80%; font-size: 4.778pt; padding: 3.63mm 0mm 0mm 3.28mm"><%=图标 %></div>
                </div>
            </div>
            <!-- 短裤内裤v2 END -->
            <% elseIf sxchdmkey = ("休闲服时尚羽绒服") Then %>
            <!-- 休闲服时尚羽绒服 -->
            <div style="width: 50mm; height: 176mm; float: left; overflow: hidden; border: 1px solid Black;">

                <div style="height: 15.5mm; padding: 9mm 0mm 0mm 0mm; text-align: center; white-space: nowrap; overflow: hidden;">
                    <div style="text-align: center;" class="bt">
                        <img style="width: 30.187mm" src="sxtb/lilanz-shangyi.png"></img></div>
                </div>
                <div style="height: 3.44mm; font-size: 8.272pt; overflow: hidden;">
                    <div style="padding: 0mm 0mm 0mm 3.02mm; height: 100%; overflow: hidden">品名:<%=品名 %></div>
                </div>
                <div style="height: 3.44mm; font-size: 8.272pt; overflow: hidden;">
                    <div style="padding: 0mm 0mm 0mm 3.02mm; height: 100%; overflow: hidden">纤维含量:</div>
                </div>
                <div style=" padding: 0mm 0mm 0mm 5.78mm; font-size: 8.272pt; overflow: hidden;"><%=纤维含量%></div>

                <div style="height: 3.44mm; font-size: 8.272pt; overflow: hidden;">
                    <div style="width: 70%; float: left; padding: 0mm 0mm 0mm 5.78mm; height: 100%; overflow: hidden"><%=样号 %></div>
                    <div style="width: 30%; float: left; height: 100%; overflow: hidden"></div>
                </div>
                <div style="height: 29.90mm; font-size: 8.272pt; text-align: center; padding: 1mm 0mm 6mm 0mm;">

                    <table style="border-collapse: collapse; text-align: center; font-size: 8.272pt; table-layout: fixed;" border="1">
                        <tr>
                            <td style="width: 42.3mm" colspan="4">充绒量</td>
                        </tr>
                    </table>
                    <table style="border-collapse: collapse; text-align: center; font-size: 8.272pt; table-layout: fixed;" border="1">
                        <tr>
                            <td class="ylTableCol1Css">规格</td>
                            <td class="ylTableTdCss"><%=getArrayConter(crlhx, 0)%></td>
                            <td class="ylTableTdCss"><%=getArrayConter(crlhx, 1)%></td>
                            <td class="ylTableTdCss"><%=getArrayConter(crlhx, 2)%></td>
                        </tr>

                        <tr>
                            <td class="ylTableCol1Css">重量</td>
                            <td class="ylTableTdCss"><%=IIf(getArrayConter(crl, 0) = "g", "", getArrayConter(crl, 0))%></td>
                            <td class="ylTableTdCss"><%=IIf(getArrayConter(crl, 1) = "g", "", getArrayConter(crl, 1))%></td>
                            <td class="ylTableTdCss"><%=IIf(getArrayConter(crl, 2) = "g", "", getArrayConter(crl, 2))%></td>
                        </tr>
                    </table>
                    <table style="border-collapse: collapse; text-align: center; font-size: 8.272pt; table-layout: fixed;" border="1">
                        <tr>
                            <td class="ylTableCol1Css">规格</td>
                            <td class="ylTableTdCss"><%=getArrayConter(crlhx, 3)%></td>
                            <td class="ylTableTdCss"><%=getArrayConter(crlhx, 4)%></td>
                            <td class="ylTableTdCss"><%=getArrayConter(crlhx, 5)%></td>
                        </tr>
                        <tr>
                            <td class="ylTableCol1Css">重量</td>
                            <td class="ylTableTdCss"><%=IIf(getArrayConter(crl, 3) = "g", "", getArrayConter(crl, 3))%></td>
                            <td class="ylTableTdCss"><%=IIf(getArrayConter(crl, 4) = "g", "", getArrayConter(crl, 4))%></td>
                            <td class="ylTableTdCss"><%=IIf(getArrayConter(crl, 5) = "g", "", getArrayConter(crl, 5))%></td>
                        </tr>
                    </table>
                    <table style="border-collapse: collapse; text-align: center; font-size: 8.272pt; table-layout: fixed;" border="1">
                        <tr>
                            <td class="ylTableCol1Css">规格</td>
                            <td class="ylTableTdCss"><%=getArrayConter(crlhx, 6)%></td>
                            <td class="ylTableTdCss"><%=getArrayConter(crlhx, 7)%></td>
                            <td class="ylTableTdCss"><%=getArrayConter(crlhx, 8)%></td>
                        </tr>
                        <tr>
                            <td class="ylTableCol1Css">重量</td>
                            <td class="ylTableTdCss"><%=IIf(getArrayConter(crl, 6) = "g", "", getArrayConter(crl, 6))%></td>
                            <td class="ylTableTdCss"><%=IIf(getArrayConter(crl, 7) = "g", "", getArrayConter(crl, 7))%></td>
                            <td class="ylTableTdCss"><%=IIf(getArrayConter(crl, 8) = "g", "", getArrayConter(crl, 8))%></td>
                        </tr>
                    </table>
                </div>

                <div style="height: auto; font-size: 9pt; overflow: hidden;">
                    <div style="padding: 0mm 0mm 0mm 5.78mm; height: 100%; overflow: hidden">洗涤方法:</div>
                </div>

                <div style="height: 60mm; font-size: 9pt; overflow: hidden;">

                    <div style="padding: 0mm 0mm 0mm 4.78mm; overflow: hidden"><%=图标 %></div>
                    <div style="padding: 0mm 0mm 0mm 5.78mm; overflow: hidden">
                        <%=洗涤方法 %>
                    </div>
                </div>
            </div>
            <!-- 休闲服时尚羽绒服 END -->
            <% elseIf sxchdmkey = ("休闲服时尚羽绒服v2") Then %>
            <!-- 休闲服时尚羽绒服V2 -->
            <div style="width: 50mm; height: 95mm; float: left; overflow: hidden; border: 1px solid Black;">

                <div style="height: 15.5mm; padding: 9mm 0mm 0mm 0mm; text-align: center; white-space: nowrap; overflow: hidden;">
                    <div style="text-align: center;" class="bt">
                        <img style="width: 30.187mm" src="sxtb/lilanz-shangyi.png"></img></div>
                </div>
                <div style="height: 3.44mm; font-size: 8.272pt; overflow: hidden;">
                    <div style="padding: 0mm 0mm 0mm 3.02mm; height: 100%; overflow: hidden">品名:<%=品名 %></div>
                </div>
                <%
                    if 样号<>货号 Then
                %>
                    <div style="height: 4.06mm; font-size: 7pt; overflow: hidden;">
                        <div style="padding: 0mm 0mm 0mm 3.59mm; height: 100%; overflow: hidden"><%=货号 %>-<%=样号 %></div>
                    </div>
                 <% End If %>
                <div style="height: 3.44mm; font-size: 8.272pt; overflow: hidden;">
                    <div style="padding: 0mm 0mm 0mm 3.02mm; height: 100%; overflow: hidden">纤维含量:</div>
                </div>
                <div style="padding: 0mm 0mm 0mm 5.78mm; font-size: 8.272pt; overflow: hidden;"><%=纤维含量%></div>
                
                <%
                    If 样号 = 货号 Then
                %>                
                    <div style="height: 6.88mm; font-size: 8pt; overflow: hidden;">
                        <div style="width: 70%; float: left; padding: 1mm 0mm 0mm 4.61mm; height: 100%; overflow: hidden"><%=样号 %></div>
                        <div style="width: 30%; float: left; height: 100%; padding: 1mm 0mm 0mm 0mm; overflow: hidden"></div>
                    </div>
                <% End If %>
                <div style="height: 29.90mm; font-size: 8.272pt; text-align: center; padding: 1mm 0mm 6mm 0mm;">

                    <table style="border-collapse: collapse; text-align: center; font-size: 8.272pt; table-layout: fixed;" border="1">
                        <tr>
                            <td style="width: 42.3mm" colspan="4">充绒量</td>
                        </tr>
                    </table>
                    <table style="border-collapse: collapse; text-align: center; font-size: 8.272pt; table-layout: fixed;" border="1">
                        <tr>
                            <td class="ylTableCol1Css">规格</td>
                            <td class="ylTableTdCss"><%=getArrayConter(crlhx, 0)%></td>
                            <td class="ylTableTdCss"><%=getArrayConter(crlhx, 1)%></td>
                            <td class="ylTableTdCss"><%=getArrayConter(crlhx, 2)%></td>
                        </tr>

                        <tr>
                            <td class="ylTableCol1Css">重量</td>
                            <td class="ylTableTdCss"><%=IIf(getArrayConter(crl, 0) = "g", "", getArrayConter(crl, 0)) %></td>
                            <td class="ylTableTdCss"><%=IIf(getArrayConter(crl, 1) = "g", "", getArrayConter(crl, 1))%></td>
                            <td class="ylTableTdCss"><%=IIf(getArrayConter(crl, 2) = "g", "", getArrayConter(crl, 2))%></td>
                        </tr>
                    </table>
                    <table style="border-collapse: collapse; text-align: center; font-size: 8.272pt; table-layout: fixed;" border="1">
                        <tr>
                            <td class="ylTableCol1Css">规格</td>
                            <td class="ylTableTdCss"><%=getArrayConter(crlhx, 3)%></td>
                            <td class="ylTableTdCss"><%=getArrayConter(crlhx, 4)%></td>
                            <td class="ylTableTdCss"><%=getArrayConter(crlhx, 5)%></td>
                        </tr>
                        <tr>
                            <td class="ylTableCol1Css">重量</td>
                            <td class="ylTableTdCss"><%=IIf(getArrayConter(crl, 3) = "g", "", getArrayConter(crl, 3))%></td>
                            <td class="ylTableTdCss"><%=IIf(getArrayConter(crl, 4) = "g", "", getArrayConter(crl, 4))%></td>
                            <td class="ylTableTdCss"><%=IIf(getArrayConter(crl, 5) = "g", "", getArrayConter(crl, 5))%></td>
                        </tr>
                    </table>
                    <table style="border-collapse: collapse; text-align: center; font-size: 8.272pt; table-layout: fixed;" border="1">
                        <tr>
                            <td class="ylTableCol1Css">规格</td>
                            <td class="ylTableTdCss"><%=getArrayConter(crlhx, 6)%></td>
                            <td class="ylTableTdCss"><%=getArrayConter(crlhx, 7)%></td>
                            <td class="ylTableTdCss"><%=getArrayConter(crlhx, 8)%></td>
                        </tr>
                        <tr>
                            <td class="ylTableCol1Css">重量</td>
                            <td class="ylTableTdCss"><%=IIf(getArrayConter(crl, 6) = "g", "", getArrayConter(crl, 6))%></td>
                            <td class="ylTableTdCss"><%=IIf(getArrayConter(crl, 7) = "g", "", getArrayConter(crl, 7))%></td>
                            <td class="ylTableTdCss"><%=IIf(getArrayConter(crl, 8) = "g", "", getArrayConter(crl, 8))%></td>
                        </tr>
                    </table>
                </div>

            </div>
            <!--左右分隔 -->
            <div style="width: 50mm; height: 95mm; float: left; overflow: hidden; border: 1px solid Black;">
                <div style="text-align:center;padding-top: 15mm; font-size: 6.2pt; overflow: hidden;">
                    <img alt="" style="height:10mm;" src="../BB_apply/getCode128.aspx?code=<%=货号 %>" />
                </div>
                <div style="font-size: 6.2pt; overflow: hidden;">
                    <div style="padding: 0mm 0mm 0mm 3.24mm; height: 100%; overflow: hidden">洗涤方法:</div>
                </div>

                <div style="height: 60mm; font-size: 9pt; overflow: hidden;">

                    <div style="padding: 0mm 0mm 0mm 4.78mm; overflow: hidden"><%=图标 %></div>
                    <div style="padding: 0mm 0mm 0mm 5.78mm; overflow: hidden">
                        <%=洗涤方法 %>
                    </div>
                </div>
            </div>
            <!-- 休闲服时尚羽绒服 END -->
            <% elseIf sxchdmkey = ("时尚羽绒服l2") Then %>
            <!-- 时尚羽绒服l2 -->
            <div style="width: 50mm; height: 95mm; float: left; overflow: hidden; border: 1px solid Black;">

                <div style="height: 15.5mm; padding: 9mm 0mm 0mm 0mm; text-align: center; white-space: nowrap; overflow: hidden;">
                    <div style="text-align: center;" class="bt">
                        </div>
                </div>
                <div style="height: 3.44mm; font-size: 8.272pt; overflow: hidden;">
                    <div style="padding: 0mm 0mm 0mm 3.02mm; height: 100%; overflow: hidden">品名:<%=品名 %></div>
                </div>
              
                <div style="height: 3.44mm; font-size: 8.272pt; overflow: hidden;">
                    <div style="padding: 0mm 0mm 0mm 3.02mm; height: 100%; overflow: hidden">纤维含量:</div>
                </div>
                <div style="padding: 0mm 0mm 0mm 5.78mm; font-size: 8.272pt; overflow: hidden;"><%=纤维含量%></div>
                    <div style="height: 6.88mm; font-size: 8pt; overflow: hidden;">
                        <div style="width: 70%; float: left; padding: 1mm 0mm 0mm 4.61mm; height: 100%; overflow: hidden"><%=货号 %>-<%=样号 %></div>
                        <div style="width: 30%; float: left; height: 100%; padding: 1mm 0mm 0mm 0mm; overflow: hidden"></div>
                    </div>
              
                <div style="height: 29.90mm; font-size: 8.272pt; text-align: center; padding: 1mm 0mm 6mm 0mm;">

                    <table style="border-collapse: collapse; text-align: center; font-size: 8.272pt; table-layout: fixed;" border="1">
                        <tr>
                            <td style="width: 42.3mm" colspan="4">充绒量</td>
                        </tr>
                    </table>
                    <table style="border-collapse: collapse; text-align: center; font-size: 8.272pt; table-layout: fixed;" border="1">
                        <tr>
                            <td class="ylTableCol1Css">规格</td>
                            <td class="ylTableTdCss"><%=getArrayConter(crlhx, 0)%></td>
                            <td class="ylTableTdCss"><%=getArrayConter(crlhx, 1)%></td>
                            <td class="ylTableTdCss"><%=getArrayConter(crlhx, 2)%></td>
                        </tr>

                        <tr>
                            <td class="ylTableCol1Css">重量</td>
                            <td class="ylTableTdCss"><%=IIf(getArrayConter(crl, 0) = "g", "", getArrayConter(crl, 0)) %></td>
                            <td class="ylTableTdCss"><%=IIf(getArrayConter(crl, 1) = "g", "", getArrayConter(crl, 1))%></td>
                            <td class="ylTableTdCss"><%=IIf(getArrayConter(crl, 2) = "g", "", getArrayConter(crl, 2))%></td>
                        </tr>
                    </table>
                    <table style="border-collapse: collapse; text-align: center; font-size: 8.272pt; table-layout: fixed;" border="1">
                        <tr>
                            <td class="ylTableCol1Css">规格</td>
                            <td class="ylTableTdCss"><%=getArrayConter(crlhx, 3)%></td>
                            <td class="ylTableTdCss"><%=getArrayConter(crlhx, 4)%></td>
                            <td class="ylTableTdCss"><%=getArrayConter(crlhx, 5)%></td>
                        </tr>
                        <tr>
                            <td class="ylTableCol1Css">重量</td>
                            <td class="ylTableTdCss"><%=IIf(getArrayConter(crl, 3) = "g", "", getArrayConter(crl, 3))%></td>
                            <td class="ylTableTdCss"><%=IIf(getArrayConter(crl, 4) = "g", "", getArrayConter(crl, 4))%></td>
                            <td class="ylTableTdCss"><%=IIf(getArrayConter(crl, 5) = "g", "", getArrayConter(crl, 5))%></td>
                        </tr>
                    </table>
                    <table style="border-collapse: collapse; text-align: center; font-size: 8.272pt; table-layout: fixed;" border="1">
                        <tr>
                            <td class="ylTableCol1Css">规格</td>
                            <td class="ylTableTdCss"><%=getArrayConter(crlhx, 6)%></td>
                            <td class="ylTableTdCss"><%=getArrayConter(crlhx, 7)%></td>
                            <td class="ylTableTdCss"><%=getArrayConter(crlhx, 8)%></td>
                        </tr>
                        <tr>
                            <td class="ylTableCol1Css">重量</td>
                            <td class="ylTableTdCss"><%=IIf(getArrayConter(crl, 6) = "g", "", getArrayConter(crl, 6))%></td>
                            <td class="ylTableTdCss"><%=IIf(getArrayConter(crl, 7) = "g", "", getArrayConter(crl, 7))%></td>
                            <td class="ylTableTdCss"><%=IIf(getArrayConter(crl, 8) = "g", "", getArrayConter(crl, 8))%></td>
                        </tr>
                    </table>
                </div>

            </div>
            <!--左右分隔 -->
            <div style="width: 50mm; height: 95mm; float: left; overflow: hidden; border: 1px solid Black;">
                <div style="text-align:center;padding-top: 15mm; font-size: 6.2pt; overflow: hidden;">
                    
                </div>
                <div style="font-size: 6.2pt; overflow: hidden;">
                    <div style="padding: 0mm 0mm 0mm 3.24mm; height: 100%; overflow: hidden">洗涤方法:</div>
                </div>

                <div style="  font-size: 9pt; overflow: hidden;">

                    <div style="padding: 0mm 0mm 0mm 4.78mm; overflow: hidden"><%=图标 %></div>
                     <div style="padding: 0mm 0mm 0mm 5.78mm; overflow: hidden">
                        <%=洗涤方法 %>
                    </div>
                </div>
                 <div style=" padding: 9mm 0mm 0mm 0mm; text-align: center; white-space: nowrap; overflow: hidden;">
                    <div style="text-align: center;" class="bt">
                        <img style="" src="sxtb/lilanz-L2.png"></img></div>
                 </div>
            </div>
            <!-- 时尚羽绒服l2 END -->
            <% elseIf sxchdmkey = ("羽绒单衣") Then %>
            <!-- 羽绒单衣 -->
            <div style="width: 50mm; height: 95mm; float: left; overflow: hidden; border: 1px solid Black;">

                <div style="height: 15.5mm; padding: 9mm 0mm 0mm 0mm; text-align: center; white-space: nowrap; overflow: hidden;">
                    <div style="text-align: center;" class="bt">
                        <img style="width: 30.187mm" src="sxtb/lilanz-shangyi.png"></img></div>
                </div>
                <div style="height: 3.44mm; font-size: 8.272pt; overflow: hidden;">
                    <div style="padding: 0mm 0mm 0mm 3.02mm; height: 100%; overflow: hidden">品名:<%=品名 %></div>
                </div>
                <div style="height: 3.44mm; font-size: 8.272pt; overflow: hidden;">
                    <div style="padding: 0mm 0mm 0mm 3.02mm; height: 100%; overflow: hidden">号型:<%=号型%></div>
                </div>
                <div style="height: 3.44mm; font-size: 8.272pt; overflow: hidden;">
                    <div style="padding: 0mm 0mm 0mm 3.02mm; height: 100%; overflow: hidden">纤维含量:</div>
                </div>
                <div style=" padding: 0mm 0mm 0mm 5.78mm; font-size: 8.272pt; overflow: hidden;"><%=纤维含量%></div>

                <div style="height: 3.44mm; font-size: 8.272pt; overflow: hidden;">
                    <div style="width: 70%; float: left; padding: 0mm 0mm 0mm 5.78mm; height: 100%; overflow: hidden"><%=样号 %></div>
                    <div style="width: 30%; float: left; height: 100%; overflow: hidden"></div>
                </div>
                <div style="height: 29.90mm; font-size: 8.272pt; text-align: center; padding: 1mm 0mm 6mm 0mm;">

                    <table style="border-collapse: collapse; text-align: center; font-size: 8.272pt; table-layout: fixed; display: '<%= IIf(crlhx.Length = 0, "none", "block")%>'" border="1">
                        <tr>
                            <td style="width: 42.3mm" colspan="4">充绒量</td>
                        </tr>
                    </table>
                    <table style="border-collapse: collapse; text-align: center; font-size: 8.272pt; table-layout: fixed;" border="1">
                        <tr>
                            <td class="ylTableCol1Css">规格</td>
                            <td class="ylTableTdCss"><%=getArrayConter(crlhx, 0)%></td>
                            <td class="ylTableTdCss"><%=getArrayConter(crlhx, 1)%></td>
                            <td class="ylTableTdCss"><%=getArrayConter(crlhx, 2)%></td>
                        </tr>

                        <tr>
                            <td class="ylTableCol1Css">重量</td>
                            <td class="ylTableTdCss"><%=IIf(getArrayConter(crl, 0) = "g", "", getArrayConter(crl, 0))%></td>
                            <td class="ylTableTdCss"><%=IIf(getArrayConter(crl, 1) = "g", "", getArrayConter(crl, 1))%></td>
                            <td class="ylTableTdCss"><%=IIf(getArrayConter(crl, 2) = "g", "", getArrayConter(crl, 2))%></td>
                        </tr>
                    </table>
                    <table style="border-collapse: collapse; text-align: center; font-size: 8.272pt; table-layout: fixed;" border="1">
                        <tr>
                            <td class="ylTableCol1Css">规格</td>
                            <td class="ylTableTdCss"><%=getArrayConter(crlhx, 3)%></td>
                            <td class="ylTableTdCss"><%=getArrayConter(crlhx, 4)%></td>
                            <td class="ylTableTdCss"><%=getArrayConter(crlhx, 5)%></td>
                        </tr>
                        <tr>
                            <td class="ylTableCol1Css">重量</td>
                            <td class="ylTableTdCss"><%=IIf(getArrayConter(crl, 3) = "g", "", getArrayConter(crl, 3))%></td>
                            <td class="ylTableTdCss"><%=IIf(getArrayConter(crl, 4) = "g", "", getArrayConter(crl, 4))%></td>
                            <td class="ylTableTdCss"><%=IIf(getArrayConter(crl, 5) = "g", "", getArrayConter(crl, 5))%></td>
                        </tr>
                    </table>
                    <table style="border-collapse: collapse; text-align: center; font-size: 8.272pt; table-layout: fixed;" border="1">
                        <tr>
                            <td class="ylTableCol1Css">规格</td>
                            <td class="ylTableTdCss"><%=getArrayConter(crlhx, 6)%></td>
                            <td class="ylTableTdCss"><%=getArrayConter(crlhx, 7)%></td>
                            <td class="ylTableTdCss"><%=getArrayConter(crlhx, 8)%></td>
                        </tr>
                        <tr>
                            <td class="ylTableCol1Css">重量</td>
                            <td class="ylTableTdCss"><%=IIf(getArrayConter(crl, 6) = "g", "", getArrayConter(crl, 6))%></td>
                            <td class="ylTableTdCss"><%=IIf(getArrayConter(crl, 7) = "g", "", getArrayConter(crl, 7))%></td>
                            <td class="ylTableTdCss"><%=IIf(getArrayConter(crl, 8) = "g", "", getArrayConter(crl, 8))%></td>
                        </tr>
                    </table>
                </div>
            </div>
            <!--左右分隔 -->
            <div style="width: 50mm; height: 95mm; float: left; overflow: hidden; border: 1px solid Black;">

                <div style="padding-top: 15mm; font-size: 9pt; overflow: hidden;">
                    <div style="padding: 0mm 0mm 0mm 5.78mm; height: 100%; overflow: hidden">洗涤方法:</div>
                </div>

                <div style="height: 60mm; font-size: 9pt; overflow: hidden;">

                    <div style="padding: 0mm 0mm 0mm 4.78mm; overflow: hidden"><%=图标 %></div>
                    <div style="padding: 0mm 0mm 0mm 5.78mm; overflow: hidden">
                        <%=洗涤方法 %>
                    </div>
                </div>
            </div>
            <!-- 羽绒单衣 END -->
            <% elseIf sxchdmkey = ("茄克衫") Then %>
            <!-- 茄克衫 -->
            <div style="width: 50mm; height: 130mm; float: left; border: 1px solid Black; overflow: hidden;">

                <div style="height: 15.5mm; padding: 9mm 0mm 0mm 0mm; text-align: center; white-space: nowrap; overflow: hidden;">
                    <div style="text-align: center;" class="bt">
                        <img style="width: 30.187mm" src="sxtb/lilanz-shangyi.png"></img></div>
                </div>
                <div style="height: 3.44mm; font-size: 8.272pt; overflow: hidden;">
                    <div style="padding: 0mm 0mm 0mm 3.02mm; height: 100%; overflow: hidden">品名:<%=品名 %></div>
                </div>
                <div style="height: 3.44mm; font-size: 8.272pt; overflow: hidden;">
                    <div style="padding: 0mm 0mm 0mm 3.02mm; height: 100%; overflow: hidden">纤维含量:</div>
                </div>
                <div style=" padding: 0mm 0mm 0mm 5.78mm; font-size: 8.272pt; overflow: hidden;"><%=纤维含量%></div>
                <div style="height: 6.02mm; font-size: 8.272pt; overflow: hidden;">
                    <div style="width: 70%; float: left; padding: 0mm 0mm 0mm 5.78mm; height: 100%; overflow: hidden"><%=样号 %></div>
                    <div style="width: 30%; float: left; height: 100%; overflow: hidden"></div>
                </div>

                <div style="height: auto; font-size: 9pt; overflow: hidden;">
                    <div style="padding: 0mm 0mm 0mm 5.78mm; height: 100%; overflow: hidden">洗涤方法:</div>
                </div>

                <div style="height: 55mm; font-size: 9pt; overflow: hidden;">

                    <div style="padding: 0mm 0mm 0mm 4.78mm; overflow: hidden"><%=图标 %></div>
                    <div style="padding: 0mm 0mm 0mm 5.78mm; overflow: hidden">
                        <%=洗涤方法 %>
                    </div>

                </div>
            </div>
            <!-- 茄克衫END -->
            <% elseIf sxchdmkey = ("茄克衫v2") Then %>
            <!-- 茄克衫 V2-->
            <div style="width: 50mm; height: 70mm; float: left; border: 1px solid Black; overflow: hidden;">
                <div style="height: 15.5mm; padding: 9mm 0mm 0mm 0mm; text-align: center; white-space: nowrap; overflow: hidden;">
                    <div style="text-align: center;" class="bt">
                        <img style="width: 30.187mm" src="sxtb/lilanz-shangyi.png"></img></div>
                </div>
                <div style="height: 3.44mm; font-size: 8.272pt; overflow: hidden;">
                    <div style="padding: 0mm 0mm 0mm 3.02mm; height: 100%; overflow: hidden">品名:<%=品名 %></div>
                </div>
                <%
                    if 样号<>货号 Then
                %>
                    <div style="height: 4.06mm; font-size: 7pt; overflow: hidden;">
                        <div style="padding: 0mm 0mm 0mm 3.59mm; height: 100%; overflow: hidden"><%=货号 %>-<%=样号 %></div>
                    </div>
                 <% End If %>
                <div style="height: 3.44mm; font-size: 8.272pt; overflow: hidden;">
                    <div style="padding: 0mm 0mm 0mm 3.02mm; height: 100%; overflow: hidden">纤维含量:</div>
                </div>
                <div style="padding: 0mm 0mm 0mm 5.78mm; font-size: 8.272pt; overflow: hidden;"><%=纤维含量%></div>
                
                <%
                    If 样号 = 货号 Then
                %>                
                    <div style="height: 6.88mm; font-size: 8pt; overflow: hidden;">
                        <div style="width: 70%; float: left; padding: 1mm 0mm 0mm 4.61mm; height: 100%; overflow: hidden"><%=样号 %></div>
                        <div style="width: 30%; float: left; height: 100%; padding: 1mm 0mm 0mm 0mm; overflow: hidden"></div>
                    </div>
                <% End If %>
            </div>
            <!--左右分隔 -->
            <div style="width: 50mm; height: 70mm; float: left; border: 1px solid Black; overflow: hidden;">
                <div style="text-align:center;padding-top: 15mm; font-size: 6.2pt; overflow: hidden;">
                    <img alt="" style="height:10mm;" src="../BB_apply/getCode128.aspx?code=<%=货号 %>" />
                </div>
                <div style="font-size: 6.2pt; overflow: hidden;">
                    <div style="padding: 0mm 0mm 0mm 3.24mm; height: 100%; overflow: hidden">洗涤方法:</div>
                </div>
                <div style="height: 55mm; font-size: 9pt; overflow: hidden;">

                    <div style="padding: 0mm 0mm 0mm 4.78mm; overflow: hidden"><%=图标 %></div>
                    <div style="padding: 0mm 0mm 0mm 5.78mm; overflow: hidden">
                        <%=洗涤方法 %>
                    </div>

                </div>
            </div>
            <!-- 茄克衫 V2 END -->
            <% elseIf sxchdmkey = ("西服套装") Then %>
            <!-- 西服套装 -->
            <div style="width: 50mm; height: 130mm; float: left; border: 1px solid Black; overflow: hidden;">

                <div style="height: 15.5mm; padding: 9mm 0mm 3.28mm 0mm; text-align: center; white-space: nowrap; overflow: hidden;">
                    <div style="text-align: center;" class="bt">
                        <img style="width: 30.187mm" src="sxtb/lilanz-shangyi.png"></img></div>
                </div>
                <div style="height: 3.44mm; font-size: 8.272pt; overflow: hidden;">
                    <div style="padding: 0mm 0mm 0mm 3.02mm; height: 100%; overflow: hidden">品名:<%=品名 %></div>
                </div>
                <div style="height: 3.44mm; font-size: 8.272pt; overflow: hidden;">
                    <div style="padding: 0mm 0mm 0mm 3.02mm; height: 100%; overflow: hidden">号型:<%=号型 %></div>
                </div>
                <div style="height: 3.44mm; font-size: 8.272pt; overflow: hidden;">
                    <div style="padding: 0mm 0mm 0mm 3.02mm; height: 100%; overflow: hidden">纤维含量:</div>
                </div>
                <div style=" padding: 0mm 0mm 0mm 5.78mm; font-size: 8.272pt; overflow: hidden;"><%=纤维含量%></div>
                <div style="height: 6.02mm; font-size: 8.272pt; overflow: hidden;">
                    <div style="width: 70%; float: left; padding: 0mm 0mm 0mm 5.78mm; height: 100%; overflow: hidden"><%=样号 %></div>
                    <div style="width: 30%; float: left; height: 100%; overflow: hidden"></div>
                </div>

                <div style="height: auto; font-size: 9pt; overflow: hidden;">
                    <div style="padding: 0mm 0mm 0mm 5.78mm; height: 100%; overflow: hidden">洗涤方法:</div>
                </div>

                <div style="height: 54mm; font-size: 9pt; overflow: hidden;">

                    <div style="padding: 0mm 0mm 0mm 4.78mm;"><%=图标 %></div>
                    <div style="padding: 0mm 0mm 0mm 5.78mm; overflow: hidden">
                        <%=洗涤方法 %>
                    </div>
                </div>
            </div>
            <!-- 西服套装 END  -->
            <% elseIf sxchdmkey = ("西服套装v2") Then%>
            <!-- 西服套装 V2-->
            <div style="width: 50mm; height: 70mm; float: left; border: 1px solid Black; overflow: hidden;">

                <div style="height: 15.5mm; padding: 9mm 0mm 3.28mm 0mm; text-align: center; white-space: nowrap; overflow: hidden;">
                    <div style="text-align: center;" class="bt">
                        <img style="width: 30.187mm" src="sxtb/lilanz-shangyi.png"></img></div>
                </div>
                <div style="height: 3.44mm; font-size: 8.272pt; overflow: hidden;">
                    <div style="padding: 0mm 0mm 0mm 3.02mm; height: 100%; overflow: hidden">品名:<%=品名 %></div>
                </div>
                <%
                    if 样号<>货号 Then
                %>
                    <div style="height: 4.06mm; font-size: 7pt; overflow: hidden;">
                        <div style="padding: 0mm 0mm 0mm 3.59mm; height: 100%; overflow: hidden"><%=货号 %>-<%=样号 %></div>
                    </div>
                 <% End If %>
                <div style="height: 3.44mm; font-size: 8.272pt; overflow: hidden;">
                    <div style="padding: 0mm 0mm 0mm 3.02mm; height: 100%; overflow: hidden">号型:<%=号型 %></div>
                </div>
                <div style="height: 3.44mm; font-size: 8.272pt; overflow: hidden;">
                    <div style="padding: 0mm 0mm 0mm 3.02mm; height: 100%; overflow: hidden">纤维含量:</div>
                </div>
                <div style="height: 34mm; padding: 0mm 0mm 0mm 5.78mm; font-size: 8.272pt; overflow: hidden;"><%=纤维含量%></div>
                
                <%
                    If 样号 = 货号 Then
                %>                
                    <div style="height: 6.88mm; font-size: 8pt; overflow: hidden;">
                        <div style="width: 70%; float: left; padding: 1mm 0mm 0mm 4.61mm; height: 100%; overflow: hidden"><%=样号 %></div>
                        <div style="width: 30%; float: left; height: 100%; padding: 1mm 0mm 0mm 0mm; overflow: hidden"></div>
                    </div>
                <% End If %>

            </div>
            <!--左右分隔 -->
            <div style="width: 50mm; height: 70mm; float: left; border: 1px solid Black; ">
                <div style="text-align:center; padding-top: 15mm; font-size: 6.2pt; overflow: hidden;">
                    <img alt="" style="height:10mm;" src="../BB_apply/getCode128.aspx?code=<%=货号 %>" />
                </div>
                <div style="font-size: 6.2pt; overflow: hidden;">
                    <div style="padding: 0mm 0mm 0mm 3.24mm; height: 100%; overflow: hidden">洗涤方法:</div>
                </div>

                <div style=" font-size: 9pt;overflow: hidden;">
                    <div style="padding-left:5.78mm;height: 100%; overflow: hidden ">
                        
                        <%=图标 %>
                        <%=洗涤方法 %>
                    </div>
                    
                </div>
            </div>
            <!-- 西服套装 V2 END -->
            <% elseIf sxchdmkey = ("内衣内裤热转移印标") Then%>
            <!--热转印标 -->
            <div style="  float: left; border: 0px solid Black; overflow: hidden;">
                <div style="padding: 0mm 0mm 0mm 0mm; text-align: center; white-space: nowrap; overflow: hidden;">
                    <div style="text-align: center;">
                        <img style="width: 25mm" src="sxtb/lilanz-shangyi.png"></img></div>
                </div>
                <div style="">
                    <div style="padding: 1mm 0mm 0mm 0mm; font-size: 6.5pt;">品名:<%=品名 %></div>
                </div>
                <div style="">
                    <div style="width: 70%; padding: 0mm 0mm 0mm 0mm; font-size: 6.5pt; float: left;">号型:<%=号型 %></div>
                    <div style="width: 30%; font-size: 6.5pt; float: left;">规格:<%=规格 %></div>
                </div>
                <div style="">
                    <div style="padding: 0mm 0mm 0mm 0mm; font-size: 6.5pt;">纤维含量:<%=纤维含量%></div>
                </div>
                <div style="padding: 0mm 0mm 0mm 0mm">
                    <div style="padding: 0mm 0mm 0mm 0mm; font-size: 5.426pt;">洗涤方法:<%=洗涤方法 %></div>

                </div>
                <div style="width: 26mm; overflow: hidden;">
                    <div style="height: 80%; font-size: 4.778pt; padding: 1mm 0mm 0mm 3.28mm"><%=简化图标%></div>
                </div>
                <div style="font-size: 6.5pt; overflow: hidden;">
                    <div style="padding: 0mm 0mm 0mm 0mm; height: 100%; overflow: hidden"><%=货号 %>-<%=样号 %></div>
                </div>
            </div>
            <!--热转印标 end  -->
            <%elseIf sxchdmkey = ("儿童女士热转移印标") Then%>
            <!--儿童女士热转移印标 -->
            <div style="  float: left; border: 0px solid Black; overflow: hidden;">
                <div style="padding: 0mm 0mm 0mm 0mm; text-align: center; white-space: nowrap; overflow: hidden;">
                    <div style="text-align: center;">
                        <img style="width: 25mm" src="sxtb/lilanz-shangyi.png"></img></div>
                </div>
                <div style="">
                    <div style="padding: 1mm 0mm 0mm 0mm; font-size: 6.5pt;">品名:<%=品名 %>&nbsp;号型:<%=号型 %>&nbsp;规格:<%=规格 %></div>
                </div>
              
                <div style="">
                    <div style="padding: 0mm 0mm 0mm 0mm; font-size: 6.5pt;">纤维含量:<%=纤维含量%></div>
                </div>
                <div style="padding: 0mm 0mm 0mm 0mm">
                    <div style="padding: 0mm 0mm 0mm 0mm; font-size: 5.426pt;">洗涤方法:<%=简化图标%></div>
                </div>
              
                <div style="font-size: 6.5pt; overflow: hidden;">
                    <div style="padding: 0mm 0mm 0mm 0mm; height: 100%; overflow: hidden"><%=货号 %>-<%=样号 %></div>
                </div>
            </div>
            <!--儿童女士热转移印标 end  -->
            <%End If%>

            <%If 腰卡图片.Length > 0 Then %>
                <div><img style="width:300px;height:300px;" src=<%=腰卡图片 %> /></div>
            <% End if %>

            <%Next%>
        </div>

        <% Next
        Next%>
    </form>
</body>
</html>
