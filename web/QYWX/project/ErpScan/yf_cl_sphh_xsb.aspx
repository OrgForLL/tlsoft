<%@ Page Language="VB" Debug="true" %>

<%@ Import Namespace="nrWebClass" %>
<%@ Import Namespace="System.Data" %>
<%@ Import Namespace="System.Data.SqlClient" %>
<script runat="server">
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
    ''' <param name="hlinfo"></param>
    ''' <param name="strWhere"></param>
    ''' <returns></returns>
    ''' <remarks></remarks>
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
    Public Function getCF(ByVal hlinfo As DataTable, ByVal 充绒量 As String, ByVal ty As String, ByVal istzsy As Integer, ByVal istzxz As Integer) As String
        Dim result As String = ""
        Dim 需打印的成份 As DataTable = New DataTable
        Dim 裤子打印类别 As Integer = 0 '除了本身ty=1需要打类别的外的(ty=0),如果成份有二种以上,那么就需要打印类别
        If istzsy = 1 Then '套装上衣
            需打印的成份 = SreeenDataTable(hlinfo, "glz in (0,1)", "sytjid")
        ElseIf istzxz = 1 Then '套装裤
            需打印的成份 = SreeenDataTable(hlinfo, "glz in (0,2)", "sytjid")
        Else
            需打印的成份 = hlinfo
        End If

        If ty = 1 Then
            '纤维含量 适应用于标签要体现类别            
            For Each dr As DataRow In 需打印的成份.Rows
                result += dr("mxsz").ToString() + "|"
            Next
            result = result.Substring(0, result.Length - 1)
            '纤维含量 适应用于标签要体现类别 end 
        ElseIf ty = 0 Then
            If 需打印的成份.Rows.Count > 1 Then
                裤子打印类别 = 1
            Else
                裤子打印类别 = 0
            End If
            If 裤子打印类别 = 0 Then
                '纤维含量 适应于不体现类别,  
                For Each dr As DataRow In 需打印的成份.Rows
                    result += dr("mxsz").ToString() + "|"
                Next
                result = result.Substring(0, result.Length - 1)
                '纤维含量 适应于不体现类别 end  
            ElseIf 裤子打印类别 = 1 Then
                '纤维含量 适应用于标签要体现类别,成份要重新换一行           
                For Each dr As DataRow In 需打印的成份.Rows
                    result += dr("mxsz").ToString() + "|"
                Next
                result = result.Substring(0, result.Length - 1)
                '纤维含量 适应用于标签要体现类别 end 
            End If
        ElseIf ty = 3 Then

            For Each dr As DataRow In 需打印的成份.Rows
                result += dr("mxsz").ToString() + "|"
            Next
            result = result.Substring(0, result.Length - 1)

        End If

        If 充绒量 <> "" Then
            result += "充绒量:" + 充绒量
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
    Public Function getHX(ByVal htzinfodr As DataRow, ByVal istzsy As Integer, ByVal istzxz As Integer) As String
        Dim 号型 As String = ""
        If Integer.Parse(htzinfodr("hx2isExists").ToString()) = "0" Then
            '说明hx2没有内容
            号型 = htzinfodr("hx").ToString()
        Else
            If istzsy = 1 Then
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
        Public istzsy As Integer
        Public istzxz As Integer
        Public bz As String
        Public lx As String
        Public chdm As String
        Sub New(ByVal chdm As String, ByVal istzsy As Integer, ByVal istzxz As Integer, ByVal bz As String, ByVal lx As String)
            Me.chdm = chdm
            Me.istzsy = istzsy
            Me.istzxz = istzxz
            Me.bz = bz
            Me.lx = lx
        End Sub
    End Class

    ''' <summary>
    ''' 尺码信息
    ''' </summary>
    ''' <remarks></remarks>
    Class SphhCmInfo
        Public sphh As String
        Public cm As String
        Public 规格 As String '内裤打印时用到的
        Public 充绒量 As String
        Public 充绒量号型 As String
        Sub New(ByVal sphh As String, ByVal cm As String, _
                ByVal 规格 As String, ByVal 充绒量 As String, ByVal 充绒量号型 As String)
            Me.sphh = sphh
            Me.cm = cm
            Me.规格 = 规格
            Me.充绒量号型 = 充绒量号型
            Me.充绒量 = 充绒量
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


        Public sxChdmDic As Collections.Generic.Dictionary(Of String, SxChdmDataContent) '水洗标材料信息

        Public icoList As New Collections.Generic.List(Of Hashtable)
        Public SphhCmInfo As Collections.Generic.List(Of SphhCmInfo)
        Sub New(ByVal 货号 As String, ByVal 要显示的尺码 As String, ByVal 品名 As String, ByVal 品名上装 As String, ByVal 品名下装 As String, ByVal 样号 As String, ByVal 版型 As String, ByVal 等级 As String, ByVal 执行标准 As String, _
                ByVal 安全技术类别 As String, ByVal 洗涤方法 As String, ByVal 洗涤方法上装 As String, ByVal 洗涤方法下装 As String, ByVal 警告语 As String, ByVal 注意事项 As String, ByVal 使用和贮藏 As String, ByVal sx注意事项 As String, ByVal sx使用和贮藏 As String, ByVal kusx注意事项 As String, ByVal kusx使用和贮藏 As String, ByVal icoList As Collections.Generic.List(Of Hashtable), _
                ByVal sxChdmDic As Collections.Generic.Dictionary(Of String, SxChdmDataContent), ByVal SphhCmInfo As Collections.Generic.List(Of SphhCmInfo))
            Me.货号 = 货号
            Me.要显示的尺码 = 要显示的尺码
            Me.品名 = 品名
            Me.品名上装 = 品名上装
            Me.品名下装 = 品名下装

            Me.样号 = 样号
            Me.版型 = 版型
            Me.等级 = 等级
            Me.执行标准 = 执行标准
            Me.安全技术类别 = 安全技术类别
            Me.洗涤方法 = 洗涤方法
            Me.洗涤方法上装 = 洗涤方法上装
            Me.洗涤方法下装 = 洗涤方法下装

            Me.警告语 = 警告语
            Me.注意事项 = 注意事项
            Me.使用和贮藏 = 使用和贮藏
            Me.sx注意事项 = sx注意事项
            Me.sx使用和贮藏 = sx使用和贮藏
            Me.kusx注意事项 = kusx注意事项
            Me.kusx使用和贮藏 = kusx使用和贮藏

            Me.icoList = icoList

            Me.sxChdmDic = sxChdmDic
            Me.SphhCmInfo = SphhCmInfo
        End Sub
    End Class
</script>
<%

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
    If sphhSql.Length = 0 Then
        Response.Write("未传入货号")
        Response.End()
    Else
        sphhSql = "select a.sphh,a.cm into #sphh from (" + sphhSql.Substring(0, sphhSql.Length - 6) + ") a ;"
    End If
    '构造货号范围表 end '

    '合格证信息
    Dim MySql As String = sphhSql
    MySql += " select f.id,f.lydjid,f.dbhg,f.dbtg,f.ddh as '水洗材料',f.fk as '水洗材料下装',pm.mc '品名',isnull(bsz.mc,'') '品名上装',isnull(bxz.mc,'') '品名下装' ,"
    MySql += " gb.dm '版型',yp.yphh '样号',f.shqk '洗涤方法',f.desz '洗涤方法上装',f.ghsyj '洗涤方法下装',xt.mc '警告语',g.mc '执行标准',f.jpg '等级',h.mc '安全技术类别',sphh.sphh '货号', m.notice '注意事项',m.store '使用和贮藏',"
    MySql += " sx.notice 'sx注意事项',sx.store 'sx使用和贮藏',kusx.notice 'kusx注意事项',kusx.store 'kusx使用和贮藏' "
    MySql += " into #myzb  "
    MySql += " from yf_T_bjdlb f "
    MySql += " inner join yf_v_rinsing_sphh_all sphh on f.id=sphh.lydjid and sphh.djzt=0"
    MySql += " inner join (select distinct sphh from #sphh) hh on hh.sphh=sphh.sphh "
    'MySql += " inner join (select a.bz as dj,a.id as zbid,a.mc as pm,b.mc as zxbz from Yf_T_bjdbjzb a,Yf_T_bjdbjzb b where a.ssid=b.id and a.lx=903 ) g on f.tplx=g.zbid "
    MySql += " inner join Yf_T_bjdbjzb pm on pm.id=f.tplx"
    MySql += " left join Yf_T_bjdbjzb bsz on f.dycs=bsz.id  "
    MySql += " left join Yf_T_bjdbjzb bxz on f.wtlx=bxz.id  "

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
    MySql += " SELECT a.货号, hjyl=(mx.hsz+mx.bzsh),gg.hx crlhx,mx.cmdm "
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
    MySql += " select b.货号,b.lx, a.* from YF_v_SXBCHDM a inner join ( select 货号, 水洗材料 chdm,'上装' lx from #myzb union select 货号, 水洗材料下装 chdm,'下装' lx from #myzb) b on a.chdm=b.chdm ;"
    '5号型规格
    MySql += " select  a.货号, zh.cmdm,isnull(k.hx,case when lw.id is not  null then  '不打印' else '未维护' end )  as hx, "
    MySql += " isnull(k.hx2,case when lw.id is not  null then  '不打印' else '未维护' end)  as hx2,"
    MySql += " hx2isExists= case isnull(k.hx2,'') when '' then 0 else 1 end , "
    MySql += " isnull(k.gg,case when lw.id is not  null then  '不打印' else '未维护' end)  as gg "
    MySql += " from #myzb a"
    MySql += " inner join yx_T_spdmb sp on sp.sphh=a.货号"
    MySql += " inner join yx_v_ypdmb yp on yp.yphh=sp.yphh "
    MySql += " inner join yx_t_cmzh zh on zh.tml=yp.tml "
    MySql += " inner join #sphh kz on kz.sphh=a.货号  "
    MySql += " left join yx_V_sphxggb k on k.yphh=yp.yphh and zh.cmdm=k.cmdm"
    MySql += " left join yx_V_noneedhxgg lw on lw.id=yp.splbid "
    '6要显示哪些尺码
    MySql += " select * from #sphh;"
    '7获取材料信息及供货商名称
    MySql += " SELECT DISTINCT a.chdm,b.chmc,kh.khmc,sp.sphh "
    MySql += " from yf_t_cpkfplxx_ml  a "
    MySql += " INNER JOIN yf_v_plxxclfz zb ON zb.dm=a.zhmlid "
    MySql += " inner join cl_v_chdmb_all b ON  a.chdm=b.chdm "
    MySql += " INNER JOIN cl_T_chdmb ch ON a.chdm=ch.chdm "
    MySql += " INNER JOIN dbo.yx_t_khb kh ON ch.ghsid=kh.khid "
    MySql += " INNER JOIN yf_t_cpkfzlb zl ON zl.zlmxid=a.zlmxid "
    MySql += " INNER JOIN yx_T_spdmb sp ON sp.yphh=zl.ypbh "
    MySql += " INNER JOIN (select distinct sphh from #sphh) hh on hh.sphh=sp.sphh "
    MySql += " INNER JOIN [cl_v_chlbb] bb on bb.dm=zb.bommc "
    MySql += " where bb.mc IN ('面料','里布') "


    MySql += " drop table #myzb; drop table #sphh;"
    'htzinfoDs = lbdll.CreateDataSet(myconn, MySql)

    Dim OAConnStr As String = clsConfig.GetConfigValue("OAConnStr")
    Dim dal As LiLanzDALForXLM = New LiLanzDALForXLM(OAConnStr)
    dal.ExecuteQuery(MySql, htzinfoDs)

    Dim htzinfo As DataTable = htzinfoDs.Tables(0).Copy() '水洗信息
    Dim hlinfo As DataTable = htzinfoDs.Tables(1).Copy() '纤维成份'
    Dim icoinfo As DataTable = htzinfoDs.Tables(2).Copy() '图标'
    Dim crlinfo As DataTable = htzinfoDs.Tables(3).Copy() '各尺寸绒含量
    Dim chdminfo As DataTable = htzinfoDs.Tables(4).Copy() '水洗标材料
    Dim hxgginfo As DataTable = htzinfoDs.Tables(5).Copy() '尺码表
    Dim showinfo As DataTable = htzinfoDs.Tables(6).Copy() '要显示哪些尺码
    Dim chyghsInfo As DataTable = htzinfoDs.Tables(7).Copy() '材料信息及供货商名称
    Dim sphhInfoDic As New Collections.Generic.Dictionary(Of String, SphhInfo)

    For Each sphhdr As DataRow In htzinfo.Rows

        Dim tmpxdff As String
        If htzinfo.Rows(0)("洗涤方法").ToString() = "/" Then
            tmpxdff = ""
        Else
            tmpxdff = htzinfo.Rows(0)("洗涤方法").ToString()
        End If
        Dim tmpxdff_sz As String
        If htzinfo.Rows(0)("洗涤方法上装").ToString() = "/" Then
            tmpxdff_sz = ""
        Else
            tmpxdff_sz = htzinfo.Rows(0)("洗涤方法上装").ToString()
        End If
        Dim tmpxdff_xz As String
        If htzinfo.Rows(0)("洗涤方法下装").ToString() = "/" Then
            tmpxdff_xz = ""
        Else
            tmpxdff_xz = htzinfo.Rows(0)("洗涤方法下装").ToString()
        End If
        '图标   
        Dim icoList As New Collections.Generic.List(Of Hashtable)
        For Each dr As DataRow In icoinfo.Select("货号='" + sphhdr("货号").ToString() + "'   ")
            Dim hs As New Hashtable
            hs.Add("path", dr("path"))
            hs.Add("mc", dr("mc"))
            hs.Add("lx", dr("lx"))
            icoList.Add(hs)
        Next

        '水洗材料
        Dim sxChdmDic As New Collections.Generic.Dictionary(Of String, SxChdmDataContent)
        For Each dr As DataRow In chdminfo.Select("货号='" + sphhdr("货号").ToString() + "'")
            sxChdmDic.Add(dr("sm"), New SxChdmDataContent(dr("chdm").ToString(), Integer.Parse(dr("istzsy").ToString()), Integer.Parse(dr("istzxz").ToString()), dr("bz").ToString(), dr("lx").ToString()))
        Next

        Dim sphhCmInfoDic As New Collections.Generic.List(Of SphhCmInfo)
        For Each cmdr As DataRow In hxgginfo.Select("货号='" + sphhdr("货号").ToString() + "'")

            Dim cmclr, crlhx As String '充绒量
            Dim clrdr As DataRow() = crlinfo.Select("货号='" + sphhdr("货号").ToString() + "' and 'cm'+cmdm='" + cmdr("cmdm").ToString() + "'")
            If clrdr.Length = 1 Then
                cmclr = String.Format("{0:####.#}", Math.Round(Decimal.Parse(clrdr(0)("hjyl").ToString()) * 1000, 1)) + "g"
                crlhx = clrdr(0)("crlhx").ToString()
            Else
                cmclr = ""
                crlhx = ""
            End If
            sphhCmInfoDic.Add(New SphhCmInfo(sphhdr("货号").ToString(), cmdr("cmdm").ToString(), cmdr("gg").ToString(), cmclr, crlhx))
        Next

        sphhInfoDic.Add(sphhdr("货号").ToString(), _
                New SphhInfo(sphhdr("货号").ToString(), showinfo.Select("sphh='" + sphhdr("货号").ToString() + "'")(0).Item("cm").ToString(), _
                sphhdr("品名").ToString(), sphhdr("品名上装").ToString(), sphhdr("品名下装").ToString(), sphhdr("样号").ToString(), sphhdr("版型").ToString(), _
                sphhdr("等级").ToString(), sphhdr("执行标准").ToString(), _
                sphhdr("安全技术类别").ToString(), tmpxdff, tmpxdff_sz, tmpxdff_xz, sphhdr("警告语").ToString(), _
                sphhdr("注意事项").ToString(), sphhdr("使用和贮藏").ToString(), _
                sphhdr("sx注意事项").ToString(), sphhdr("sx使用和贮藏").ToString(), _
                sphhdr("kusx注意事项").ToString(), sphhdr("kusx使用和贮藏").ToString(), _
                icoList, sxChdmDic, sphhCmInfoDic))
    Next


    Dim 纤维含量, 充绒量, 号型, 品名, 版型, 样号, 洗涤方法, 图标, 简化图标, 警告语, 规格, 执行标准, 货号 As String
    'Response.Write(sphhInfoDic.Keys.Count)
    'Response.End()

    For Each eachSphh As String In sphhInfoDic.Keys

        货号 = eachSphh
        Dim sphhItem As SphhInfo = sphhInfoDic.Item(eachSphh)
        '处理充绒量表格使用到的数据
        Dim crlhx() As String
        Dim crl() As String
        Dim tmpi As Integer = 0
        For Each key As SphhCmInfo In sphhItem.SphhCmInfo
            If key.充绒量.Length > 0 Then
                ReDim Preserve crlhx(tmpi + 1)
                crlhx(tmpi) = key.充绒量号型
                ReDim Preserve crl(tmpi + 1)
                crl(tmpi) = key.充绒量
                tmpi = tmpi + 1
            End If
        Next
        '处理充绒量表格使用到的数据 end       


        版型 = sphhItem.版型
        样号 = sphhItem.样号

        警告语 = sphhItem.警告语
        执行标准 = sphhItem.执行标准

        Dim 材料与供货商信息 As String = ""
        For Each chyghsdr As DataRow In chyghsInfo.Select("sphh='" + 货号 + "'")
            材料与供货商信息 += "{"
            材料与供货商信息 += """chdm"":""" + chyghsdr("chdm").ToString() + """,""chmc"":""" + chyghsdr("chmc").ToString() + """,""khmc"":""" + chyghsdr("khmc").ToString() + """"
            材料与供货商信息 += "},"
        Next
        If 材料与供货商信息 <> "" Then
            材料与供货商信息 = "[" + 材料与供货商信息.Substring(0, 材料与供货商信息.Length - 1) + "]"
        Else
            材料与供货商信息 = """"""
        End If


        For Each sphhCm As SphhCmInfo In sphhInfoDic.Item(货号).SphhCmInfo

            If sphhCm.cm <> sphhItem.要显示的尺码 Then
                Continue For
            End If
            充绒量 = sphhCm.充绒量
            Dim 号型datarow As DataRow
            If hxgginfo.Select("货号='" + 货号 + "' and cmdm='" + sphhCm.cm + "' ").Length = 1 Then
                号型datarow = hxgginfo.Select("货号='" + 货号 + "' and cmdm='" + sphhCm.cm + "' ")(0)
            End If
            规格 = sphhCm.规格


            For Each sxchdmkey As String In sphhItem.sxChdmDic.Keys
                Dim istzsy, istzxz As Integer
                'istzsy = sphhItem.sxChdmDic.Item(sxchdmkey).istzsy
                'istzxz = sphhItem.sxChdmDic.Item(sxchdmkey).istzxz                    

                If sphhItem.sxChdmDic.Item(sxchdmkey).lx = "上装" Then
                    istzsy = 1
                    istzxz = 0
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

                Else
                    istzsy = 0
                    istzxz = 1
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
                End If

                If sxchdmkey = ("羽绒单衣") Or sxchdmkey = ("茄克衫v2") Or sxchdmkey = ("休闲服时尚羽绒服v2") Or sxchdmkey = ("休闲服时尚羽绒服") Then
                    充绒量 = ""
                End If
                纤维含量 = getCF(hlinfo, 充绒量, 0, istzsy, istzxz)
                号型 = getHX(号型datarow, istzsy, istzxz)

                Dim icolx As String = ""
                If sphhItem.sx注意事项.Length = 0 And sphhItem.kusx注意事项.Length = 0 Then
                    icolx = "主模版"
                Else
                    icolx = sphhItem.sxChdmDic.Item(sxchdmkey).lx
                End If

                图标 = ""
                简化图标 = ""
                For Each ico As Hashtable In sphhItem.icoList
                    If ico.Item("lx") = icolx Then
                        图标 += "<div>../" + ico.Item("path") + "&" + ico.Item("mc") + "</div>"
                        简化图标 += "<div>../" + ico.Item("path") + "</div>"
                    End If
                Next
                图标 += ""
                'If Session("userid") = 12742 Then
                '    Response.Write(sphhItem.sxChdmDic.Item(sxchdmkey).chdm)
                '    Response.Write("istzsy:" + istzsy.ToString() + ",")
                '    Response.Write("istzxz:" + istzxz.ToString() + ",")
                'End If  
                Dim jsonStr As String = ""

                If sxchdmkey = ("水洗牛仔裤") Or sxchdmkey = ("水洗牛仔裤v2") Or sxchdmkey = ("休闲裤") Or sxchdmkey = ("休闲裤v2") Then
                    Dim qwhl As String
                    qwhl = 纤维含量
                    jsonStr += "{""result"":""Successed"",""材料与供货商信息"":" + 材料与供货商信息 + ",""水洗名称"":""" + sxchdmkey + """,""品名"":""" + 品名 + """,""号型"":""" + 号型 + """,""版型"":""" + 版型 + """,""纤维含量"":""" + qwhl + """,""样号"":""" + 样号 + """,""洗涤方法"":""" + 图标.Replace("<div>", "").Replace("<div>", "").Replace("</div>", "|") + """,""洗涤方法1"":""" + 洗涤方法 + """,""警告语"":""" + 警告语 + """}&&&&"
                ElseIf sxchdmkey = ("男西裤") Or sxchdmkey = ("男西裤v2") Then
                    Dim qwhl As String
                    qwhl = 纤维含量
                    jsonStr += "{""result"":""Successed"",""材料与供货商信息"":" + 材料与供货商信息 + ",""水洗名称"":""" + sxchdmkey + """,""品名"":""" + 品名 + """,""号型"":""" + 号型 + """,""纤维含量"":""" + qwhl + """,""样号"":""" + 样号 + """,""洗涤方法"":""" + 图标.Replace("<div>", "").Replace("<div>", "").Replace("</div>", "|") + """,""洗涤方法1"":""" + 洗涤方法 + """,""警告语"":""" + 警告语 + """}&&&&"
                ElseIf sxchdmkey = ("休闲衬衫") Or sxchdmkey = ("休闲衬衫v2") Then

                    Dim qwhl As String
                    qwhl = 纤维含量
                    jsonStr += "{""result"":""Successed"",""材料与供货商信息"":" + 材料与供货商信息 + ",""水洗名称"":""" + sxchdmkey + """,""品名"":""" + 品名 + """,""纤维含量"":""" + qwhl + """,""样号"":""" + 样号 + """,""洗涤方法"":""" + 图标.Replace("<div>", "").Replace("<div>", "").Replace("</div>", "|") + """,""洗涤方法1"":""" + 洗涤方法 + """,""警告语"":""" + 警告语 + """}&&&&"

                ElseIf sxchdmkey = ("短裤内裤") Then

                    Dim qwhl As String
                    qwhl = 纤维含量

                    jsonStr += "{""result"":""Successed"",""材料与供货商信息"":" + 材料与供货商信息 + ",""水洗名称"":""" + sxchdmkey + """,""品名"":""" + 品名 + """,""号型"":""" + 号型 + """,""规格"":""" + 规格 + """,""纤维含量"":""" + qwhl + """,""执行标准"":""" + 执行标准 + """,""洗涤方法"":""" + 图标.Replace("<div>", "").Replace("<div>", "").Replace("</div>", "|") + """,""洗涤方法1"":""" + 洗涤方法 + """,""警告语"":""" + 警告语 + """}&&&&"

                ElseIf sxchdmkey = ("短裤内裤v2") Then

                    Dim qwhl As String
                    qwhl = 纤维含量

                    jsonStr += "{""result"":""Successed"",""材料与供货商信息"":" + 材料与供货商信息 + ",""水洗名称"":""" + sxchdmkey + """,""品名"":""" + 品名 + """,""号型"":""" + 号型 + """,""规格"":""" + 规格 + """,""纤维含量"":""" + qwhl + """,""样号"":""" + 样号 + """,""洗涤方法"":""" + 图标.Replace("<div>", "").Replace("<div>", "").Replace("</div>", "|") + """,""洗涤方法1"":""" + 洗涤方法 + """,""警告语"":""" + 警告语 + """}&&&&"

                ElseIf sxchdmkey = ("休闲服时尚羽绒服") Then

                    Dim qwhl, gg, zl As String
                    qwhl = 纤维含量

                    zl = "[{""value1"":""" + getArrayConter(crl, 0) + """,""value2"":""" + getArrayConter(crl, 1) + """,""value3"":""" + getArrayConter(crl, 2) + """},{""value1"":""" + getArrayConter(crl, 3) + """,""value2"":""" + getArrayConter(crl, 4) + """,""value3"":""" + getArrayConter(crl, 5) + """},{""value1"":""" + getArrayConter(crl, 6) + """,""value2"":""" + getArrayConter(crl, 7) + """,""value3"":""" + getArrayConter(crl, 8) + """}]"
                    gg = "{""规格"":[{""value1"":""" + getArrayConter(crlhx, 0) + """,""value2"":""" + getArrayConter(crlhx, 1) + """,""value3"":""" + getArrayConter(crlhx, 2) + """},{""value1"":""" + getArrayConter(crlhx, 3) + """,""value2"":""" + getArrayConter(crlhx, 4) + """,""value3"":""" + getArrayConter(crlhx, 5) + """},{""value1"":""" + getArrayConter(crlhx, 6) + """,""value2"":""" + getArrayConter(crlhx, 7) + """,""value3"":""" + getArrayConter(crlhx, 8) + """}],""重量"":" + zl + "}"

                    jsonStr += "{""result"":""Successed"",""材料与供货商信息"":" + 材料与供货商信息 + ",""水洗名称"":""" + sxchdmkey + """,""品名"":""" + 品名 + """,""纤维含量"":""" + qwhl + """,""洗涤方法"":""" + 图标.Replace("<div>", "").Replace("<div>", "").Replace("</div>", "|") + """,""洗涤方法1"":""" + 洗涤方法 + """,""充绒量"":" + gg + "}&&&&"

                ElseIf sxchdmkey = ("休闲服时尚羽绒服v2") Then

                    Dim qwhl, gg, zl As String
                    qwhl = 纤维含量

                    zl = "[{""value1"":""" + getArrayConter(crl, 0) + """,""value2"":""" + getArrayConter(crl, 1) + """,""value3"":""" + getArrayConter(crl, 2) + """},{""value1"":""" + getArrayConter(crl, 3) + """,""value2"":""" + getArrayConter(crl, 4) + """,""value3"":""" + getArrayConter(crl, 5) + """},{""value1"":""" + getArrayConter(crl, 6) + """,""value2"":""" + getArrayConter(crl, 7) + """,""value3"":""" + getArrayConter(crl, 8) + """}]"
                    gg = "{""规格"":[{""value1"":""" + getArrayConter(crlhx, 0) + """,""value2"":""" + getArrayConter(crlhx, 1) + """,""value3"":""" + getArrayConter(crlhx, 2) + """},{""value1"":""" + getArrayConter(crlhx, 3) + """,""value2"":""" + getArrayConter(crlhx, 4) + """,""value3"":""" + getArrayConter(crlhx, 5) + """},{""value1"":""" + getArrayConter(crlhx, 6) + """,""value2"":""" + getArrayConter(crlhx, 7) + """,""value3"":""" + getArrayConter(crlhx, 8) + """}],""重量"":" + zl + "}"

                    jsonStr += "{""result"":""Successed"",""材料与供货商信息"":" + 材料与供货商信息 + ",""水洗名称"":""" + sxchdmkey + """,""品名"":""" + 品名 + """,""纤维含量"":""" + qwhl + """,""样号"":""" + 样号 + """,""洗涤方法"":""" + 图标.Replace("<div>", "").Replace("<div>", "").Replace("</div>", "|") + """,""洗涤方法1"":""" + 洗涤方法 + """,""充绒量"":" + gg + "}&&&&"

                ElseIf sxchdmkey = ("羽绒单衣") Then

                    Dim qwhl, gg, zl As String
                    qwhl = 纤维含量

                    zl = "[{""value1"":""" + getArrayConter(crl, 0) + """,""value2"":""" + getArrayConter(crl, 1) + """,""value3"":""" + getArrayConter(crl, 2) + """},{""value1"":""" + getArrayConter(crl, 3) + """,""value2"":""" + getArrayConter(crl, 4) + """,""value3"":""" + getArrayConter(crl, 5) + """},{""value1"":""" + getArrayConter(crl, 6) + """,""value2"":""" + getArrayConter(crl, 7) + """,""value3"":""" + getArrayConter(crl, 8) + """}]"
                    gg = "{""规格"":[{""value1"":""" + getArrayConter(crlhx, 0) + """,""value2"":""" + getArrayConter(crlhx, 1) + """,""value3"":""" + getArrayConter(crlhx, 2) + """},{""value1"":""" + getArrayConter(crlhx, 3) + """,""value2"":""" + getArrayConter(crlhx, 4) + """,""value3"":""" + getArrayConter(crlhx, 5) + """},{""value1"":""" + getArrayConter(crlhx, 6) + """,""value2"":""" + getArrayConter(crlhx, 7) + """,""value3"":""" + getArrayConter(crlhx, 8) + """}],""重量"":" + zl + "}"

                    jsonStr += "{""result"":""Successed"",""材料与供货商信息"":" + 材料与供货商信息 + ",""水洗名称"":""" + sxchdmkey + """,""品名"":""" + 品名 + """,""纤维含量"":""" + qwhl + """,""样号"":""" + 样号 + """,""洗涤方法"":""" + 图标.Replace("<div>", "").Replace("<div>", "").Replace("</div>", "|") + """,""洗涤方法1"":""" + 洗涤方法 + """,""充绒量"":" + gg + "}&&&&"

                ElseIf sxchdmkey = ("茄克衫") Or sxchdmkey = ("茄克衫v2") Then

                    Dim qwhl As String
                    qwhl = 纤维含量
                    jsonStr += "{""result"":""Successed"",""材料与供货商信息"":" + 材料与供货商信息 + ",""水洗名称"":""" + sxchdmkey + """,""品名"":""" + 品名 + """,""纤维含量"":""" + qwhl + """,""样号"":""" + 样号 + """,""洗涤方法"":""" + 图标.Replace("<div>", "").Replace("<div>", "").Replace("</div>", "|") + """,""洗涤方法1"":""" + 洗涤方法 + """}&&&&"

                ElseIf sxchdmkey = ("西服套装") Then

                    Dim qwhl As String
                    qwhl = 纤维含量

                    jsonStr += "{""result"":""Successed"",""材料与供货商信息"":" + 材料与供货商信息 + ",""水洗名称"":""" + sxchdmkey + """,""品名"":""" + 品名 + """,""号型"":""" + 号型 + """,""纤维含量"":""" + qwhl + """,""样号"":""" + 样号 + """,""洗涤方法"":""" + 图标.Replace("<div>", "").Replace("<div>", "").Replace("</div>", "|") + """,""洗涤方法1"":""" + 洗涤方法 + """}&&&&"

                ElseIf sxchdmkey = ("西服套装v2") Then

                    Dim qwhl As String
                    qwhl = 纤维含量

                    jsonStr += "{""result"":""Successed"",""材料与供货商信息"":" + 材料与供货商信息 + ",""水洗名称"":""" + sxchdmkey + """,""品名"":""" + 品名 + """,""纤维含量"":""" + qwhl + """,""样号"":""" + 样号 + """,""号型"":""" + 号型 + """,""洗涤方法"":""" + 图标.Replace("<div>", "").Replace("<div>", "").Replace("</div>", "|") + """,""洗涤方法1"":""" + 洗涤方法 + """}&&&&"

                ElseIf sxchdmkey = ("内衣内裤热转移印标") Then

                    Dim qwhl As String
                    qwhl = 纤维含量
                    jsonStr += "{""result"":""Successed"",""材料与供货商信息"":" + 材料与供货商信息 + ",""水洗名称"":""" + sxchdmkey + """,""品名"":""" + 品名 + """,""规格"":""" + 规格 + """,""纤维含量"":""" + qwhl + """,""样号"":""" + 样号 + """,""号型"":""" + 号型 + """,""洗涤方法"":""" + 简化图标.Replace("/>", "/>|") + """,""洗涤方法1"":""" + 洗涤方法 + """}&&&&"

                End If
                Response.Write(jsonStr)
            Next
        Next
    Next
%>