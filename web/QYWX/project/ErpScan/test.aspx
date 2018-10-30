﻿<%@ Page Language="VB" Debug="true"%>
<%@ Import Namespace="System.Data" %>
<%@ Import Namespace="System.Data.SqlClient" %>
<%@ Import Namespace="nrWebClass" %>
<%@ Import Namespace="lbclass" %>
<!DOCTYPE html>
<html lang="en" xmlns="http://www.w3.org/1999/xhtml">
<head>
    <meta charset="utf-8" />
    <script type="text/javascript" src="../Scripts/jquery.js"></script>
    <title>产品制造单</title>
    <style type="text/css">
        * { margin:0; padding:0; }
        table{border-collapse: collapse;width:100%;}
        .table>thead>tr>td,.table>tbody>tr>td { border:1px solid #000; border-top:none;border-right:0px;}
        .table tr td:last-child{border-right:1px;}
        .bt{border-right:0px;}
        /*table tr:first-child td{border-top:1px;}*/
        .td-img {width: 100%; }
        .td-bzt { width: 100%;height: 100%; }
        .ggcss {border-collapse: collapse;border: 1px; }
        .ggcss td { border: 1px solid black;text-align: right;}
        .col4 {height: 32px;border-collapse: collapse;        }
      
        .tpcss {border-left-width: 0px;border-right-width: 0px;width: 100%;height: 100%;border-left-color: black;border-collapse: collapse; }
        .top3 {border-left-width: 0px;border-right-width: 0px;width: 100%;border-collapse: collapse;     }
        .col5 {border-left-color: black;width: 50%;}
        td.xdtd2 {text-align: left;width: 25%;border-bottom-width: 0px; border-left-color: black;        }
        td.xxktd2 {text-align: left;width: 16.667%;border-bottom-width: 0px;border-left-color: black;        }
        td.xxktd3 {border-bottom-width: 0px;font-size: 14pt;text-align: left;width: 50%;        }
        table.xdtb2 {width: 100%;height: 100%;border: solid;border-width: 1px;border-color: black;        }
        .gyt {border: solid;border-width: 1px;border-color: black;        }
        td.xftd {border: 1px solid #000;border-right-width: 0px;border-top-width: 0px;        }
        img {vertical-align: middle;        }
    </style>
    <%
        Dim lbdll As New lbclass.lbdll()
        'Dim mylink As String = lbdll.MyDataLink("1")
        Dim mylink As String = clsConfig.GetConfigValue("OAConnStr")
        Dim myconn As SqlConnection = New Data.SqlClient.SqlConnection(mylink)
        Dim sql, zoom, zlmxid, cjg, yphh, ggid, dqNum, hei_sql, gdjls, mblx, str_sql As String
        Dim bztg, fzyqg, bx, sxfs, yzyxg, all, ytg, zdr, ggbg, bzg, hzyqg, zysxg, bgbh As String
        Dim jls, csjls, h, xfjls, height As Integer
        Dim ds, zlds, csds, xfds As Data.DataSet
        Dim dt, zldt As DataTable
        Dim dr As DataRow

        zlmxid = Request.QueryString("zlmxid")
        yphh = Request.QueryString("yphh")
        zoom = Request.QueryString("zoom")
        If String.IsNullOrEmpty(zoom) Then
            zoom = 1
        End If
        ggid = Request.QueryString("ggid")
        dqNum = Request.QueryString("dqNum")
    %>
    <style type="text/css">
        body {
            zoom: <%=zoom%>;
        }
    </style>
</head>

<body>

    <%
        Dim mytype As String = Request.QueryString("mytype")
        If mytype = "word" Then
            Response.Clear()
            Response.Buffer = True
            Response.ContentType = "application/vnd.ms-word"
            Response.Charset = "utf-8"
            Response.AddHeader("Content-Disposition", "inline;filename=" + HttpUtility.UrlEncode("生产制造单.DOC", Encoding.UTF8))
        End If
        all = 100
        If String.IsNullOrEmpty(dqNum) Then
            dqNum = "1"
        End If
        If (Len(zlmxid) = 0) Then
            zlmxid = "0"
        End If
        If (Len(ggid) = 0) Then
            ggid = "0"
        End If
        '按样品货号查出 ke	20161024
        If zlmxid = "0" And Len(yphh) > 0 Then

            hei_sql = "select a.zlmxid,a.ypbh,ISNULL(gg.id,0) as ggid from yf_t_cpkfzlb a left outer join yf_T_ytfab gg on gg.lx='jsggb' and a.ypbh=gg.dm+gg.mc+isnull(gg.kfbx,'')  "
            hei_sql += " where a.ypbh='" + yphh + "';"
            Dim mydr As SqlDataReader = lbdll.CreateDataReader(myconn, hei_sql)
            If mydr.Read() Then
                zlmxid = mydr.Item("zlmxid").ToString()
                ggid = mydr.Item("ggid").ToString()
            End If
            myconn.Close()
        End If


        hei_sql = " select mx.dm,mx.csdj,max(b.dm) as mbdm from Yf_T_bjdbjzbcmb a inner join Yf_T_bjdbjzb b on a.zbid=b.id inner join YX_T_Splb lb on a.mxid=lb.id  "
        hei_sql += " inner join yf_t_cpkfjh jh on lb.id=jh.splbid inner join yf_t_cpkfzlb zl on jh.id=zl.id inner join Yf_T_bjdbjzb mx on b.id=mx.ssid "
        hei_sql += " where a.cmdm='916' and zl.zlmxid=" + zlmxid + " group by mx.dm,mx.csdj "
        ds = lbdll.CreateDataSet(myconn, hei_sql)
        dt = ds.Tables(0)
        gdjls = ds.Tables(0).Rows.Count
        Dim ii As Integer = 0
        If ds.Tables(0).Rows.Count > 0 Then

            mblx = dt.Rows(0).Item("mbdm").ToString()

            For ii = 0 To gdjls - 1
                dr = dt.Rows(ii)
                If dr.Item("dm").ToString() = "bztg" Then
                    bztg = dr.Item("csdj").ToString()
                End If
                If dr.Item("dm").ToString() = "cjg" Then
                    cjg = dr.Item("csdj").ToString()
                End If
                If dr.Item("dm").ToString() = "fzyqg" Then
                    fzyqg = dr.Item("csdj").ToString()
                End If
                If dr.Item("dm").ToString() = "ggbg" Then
                    ggbg = dr.Item("csdj").ToString()
                End If
                If dr.Item("dm").ToString() = "hzyqg" Then
                    hzyqg = dr.Item("csdj").ToString()
                End If
                If dr.Item("dm").ToString() = "zysxg" Then
                    zysxg = dr.Item("csdj").ToString()
                End If
                If dr.Item("dm").ToString() = "ytg" Then
                    ytg = dr.Item("csdj").ToString()
                End If
                If dr.Item("dm").ToString() = "yzyxg" Then
                    yzyxg = dr.Item("csdj").ToString()
                End If
                If dr.Item("dm").ToString() = "bzg" Then
                    bzg = dr.Item("csdj").ToString()
                End If
            Next
        Else
            bztg = "90"
            fzyqg = "50"
            cjg = "25"
            ggbg = "35"
            hzyqg = "25"
            zysxg = "65"
            ytg = "60"
            bzg = "25"
            yzyxg = "10"
        End If

        sql = "  Select top 1 f.dm+f.mc As splbmc,a.zlmxid,a.yphh,yp.sphh,a.mypic As sjtg,bb.mypic As sgtp,a.zdr,a.zdrq,cc.zysx,cc.cj,cc.hzyq,cc.yzyx,cc.fzyq,cc.bztxx "
        sql += " ,(Select top 1 a.URLAddress+'|' from t_uploadfile a inner join (select top 1 id from yf_t_cpkfsjtg where tplx='sgtp' and zlmxid='" + zlmxid + "')b on a.TableID=b.id "
        sql += "       where a.groupid=18 order by a.CreateDate desc for xml path('')"
        sql += "   ) as twosgtp "
        sql += " ,(select top 1 a.URLAddress+'' from t_uploadfile a where a.groupid=22388 and tableid=" + ggid + " order by a.CreateDate desc for xml path('')) as bzt "
        sql += " from yf_t_cpkfsjtg a  "
        sql += " left outer join yf_t_cpkfsjtg bb on a.zlmxid=bb.zlmxid and bb.tplx='sgtp' "
        sql += " left outer join yf_T_ytfab cc on a.yphh=cc.dm+cc.mc+isnull(cc.kfbx,'') and cc.lx='jsggb' and cc.id='" + ggid + "' "
        sql += " left outer join yx_T_ypdmb yp on a.yphh=yp.yphh "
        sql += " left outer join yf_t_cpkfzlb zl on a.zlmxid=zl.zlmxid "
        sql += " left outer join yf_t_cpkfjh_ghs b on zl.id=b.id and zl.mxid=b.mxid "
        sql += " left outer join yf_t_cpkfjh c on b.id=c.id  "
        sql += " left outer join yx_t_splb f on case zl.qybs when 1 then 6409 else c.splbid end=f.id "
        sql += " where a.zlmxid='" + zlmxid + "' and a.tplx='sjtg' "
        'Response.Write(sql)
        'Response.End()
        Dim splbmc, sphh, zdrq, sjtg, xh, sgtp, zysx, yzyx, fzyq, cj, hzyq, bztxx, twosgtp, bzt As String
        ds = lbdll.CreateDataSet(myconn, sql)
        dt = ds.Tables(0)
        If ds.Tables(0).Rows.Count > 0 Then
            dr = dt.Rows(0)
            splbmc = dr.Item("splbmc").ToString()
            sphh = dr.Item("sphh").ToString()
            zdr = ""
            zdrq = dr.Item("zdrq").ToString()
            sjtg = dr.Item("sjtg").ToString()
            sgtp = dr.Item("sgtp").ToString()
            zysx = dr.Item("zysx").ToString()
            yzyx = dr.Item("yzyx").ToString()
            fzyq = dr.Item("fzyq").ToString()
            cj = dr.Item("cj").ToString()
            hzyq = dr.Item("hzyq").ToString().Replace("@", "'")
            bztxx = dr.Item("bztxx").ToString()
            twosgtp = dr.Item("twosgtp").ToString()
            bzt = dr.Item("bzt").ToString()
        Else
            splbmc = ""
            sphh = ""
            zdr = ""
            zdrq = ""
            sjtg = ""
            sgtp = ""
            zysx = ""
            yzyx = ""
            fzyq = ""
            cj = ""
            hzyq = ""
            bztxx = ""
            twosgtp = ""
            bzt = ""
        End If
        If String.IsNullOrEmpty(mblx) Then
            mblx = "XD"
        End If
        dt.Dispose()
        myconn.Close()
    %>

    <input type="hidden" id="message" name="message" value="" />
    <input type="hidden" id="strNum" name="strNum" value="" />
    <input type="hidden" id="dqNum" name="dqNum" value="<%=dqNum %>" />
    <input type="hidden" id="twosgtp" name="twosgtp" value="<%=twosgtp %>" />

    <%If mblx = "XD" Then '休单（S版）%>

    <!--休单制造单1号-->
    <div id="xdzzd1" style="width: 1532px; height: 980px;">
        <div id="xddiv1" style="height: px; width: 100%;">
            <div style="height: 35px; width: 100%;font-size:26pt; text-align: center; font-family: 粗体;">
                <p>利郎（中国）有限公司产品制造单</p>
            </div>

            <table style="width: 100%; height: 32px; font-size: 14pt; text-align: left;" class="ggcss">
                <tr style="width:100%;">
                    <td class="xdtd2" style="width:25%;">
                        &nbsp;产品名称：<%= splbmc%>
                    </td>
                    <td class="xdtd2" style="width:25%;">
                        &nbsp;样衣号：<%= yphh%>
                    </td>
                    <td class="xdtd2" style="width:25%;">
                        &nbsp;货号：<%= sphh%>
                    </td>
                    <td class="xdtd2" style="border-right-width: 1px;width:25%;">
                        &nbsp;制表日期：<%= zdrq%>
                    </td>
                </tr>
            </table>
        </div>
        <div style="width: 100%; height: 880px;">
            <!--工艺图-->
            <div style="width: 1530px; height: <%=ytg%>%;border:1px solid #000;text-align:center;">
                <%Dim q As Integer
                q = 880 * ytg / 100.0
                %>
                <%
                If twosgtp.ToString() = "" Then
                %>
                &nbsp;
                <%
                ElseIf twosgtp.Split("|")(1).ToString = "" Then

                %>

                <img alt="" src="ScaleImage.aspx?MyPath=<%=twosgtp.Split(" |")(0) %>&Height=<%=q %>&Width=1530&scale=0" />

                <%

                Else
                %>
                <div style="width: 49.5%; height: 99%">
                    <img alt="" src="ScaleImage.aspx?MyPath=<%=twosgtp.Split(" |")(0) %>&Height=<%=q %>&Width=765&scale=0" />
                </div>
                <div style="width: 49.5%; height: 99%">
                    <img alt="" src="ScaleImage.aspx?MyPath=<%=twosgtp.Split(" |")(1) %>&Height=<%=q %>&Width=765&scale=0" />
                </div>
                <%
                End If
                %>

            </div>


            <!--注意事项-->
            <div id="xddiv3" style="height: <%=all-ytg%>%; width: 100%;">
                <table class="ggcss" style="height: 100%; width: 100%;">
                    <tr>
                        <td style="text-align: center; width: 2%;">
                            注<br />
                            意<br />
                            事<br />
                            项
                        </td>
                        <td style="text-align: left; width: 48%;">
                            <%= zysx%>
                        </td>
                        <td style="text-align: center; width: 2%;">
                            裁<br />
                            剪<br />
                            要<br />
                            求
                        </td>
                        <td style="text-align: left; width: 48%;">
                            <%= cj%>
                        </td>
                    </tr>
                </table>
            </div>
        </div>
        <!--页脚-->
        <div id="xddiv4" style="width: 100%; height: 32px;">
            <table border="1" style="width: 100%; height: 32px; border-right-width: 0px; border-top-width: 0px;
                border-collapse: collapse; border-color: black;">
                <tr style="font-size: 15px;width:100%;">
                    <td class="xdtd2" style="width:25%;">
                        &nbsp;制表：<%= zdr%>
                    </td>
                    <td class="xdtd2" style="width:25%;">
                        &nbsp;审核：
                    </td>
                    <td class="xdtd2" style="width:25%;">
                        &nbsp;样板审核：
                    </td>
                    <td class="xdtd2" style="border-right-width: 1px; width:25%;border-right-color: black;">
                        &nbsp;审批：
                    </td>
                </tr>
            </table>
        </div>
        <div style="page-break-after: always;">
        </div>
    </div>
    <!--休单制造单2号-->
    <div id="xdzzd2" style="width: 1532px; height: 980px;">
        <!--页头内容-->
        <div id="xddiv21" style="height: 35px; width: 100%;">
            <table border="0" style="height: 35px; width: 100%;">
                <tr>
                    <td style="font-size: 26pt; text-align: center; font-family: 粗体;">
                        利郎（中国）有限公司产品制造单
                    </td>
                </tr>
            </table>
        </div>
        <!--页面主体-->
        <div id="xddiv22" style="width: 100%; height: 909px; border-bottom-width: 1px;">
            <!--左侧内容-->
            <div style="width: 50%; height: 100%; float: left; border-bottom-width: 1px;">
                <!--标题内容-->
                <div>
                    <table style="width: 100%; height: 32px; font-size: 14pt; text-align: left;" class="ggcss">
                        <tr>
                            <td class="xdtd2">
                                &nbsp;产品名称：<%= splbmc%>
                            </td>
                            <td class="xdtd2">
                                &nbsp;样衣号：<%= yphh%>
                            </td>
                            <td class="xdtd2" style="border-right-width: 0px;">
                                &nbsp;货号：<%= sphh%>
                            </td>
                        </tr>
                    </table>
                </div>
                <!--尺码内容-->
                <div style="width: 100%; height: 877px; border-left: 1px solid #000;">
                    <%
                    str_sql = "  select top 3 a.ypbh yphh, a.zlmxid, cc.id As ggid from yf_t_cpkfzlb a  "
                    str_sql += " inner join (select ypkh from yf_t_cpkfzlb where ypbh='" + yphh + "') b on a.ypkh=b.ypkh "
                    str_sql += " INNER JOIN yf_T_ytfab cc On a.ypbh = cc.dm + cc.mc + isnull(cc.kfbx,'') group by a.ypbh, a.zlmxid, cc.id  "
                    'Response.Write(str_sql)
                    'Response.End()
                    ds = lbdll.CreateDataSet(myconn, str_sql)
                    dt = ds.Tables(0)
                    Dim hs As Integer
                    hs = ds.Tables(0).Rows.Count


                    Dim t, l As Integer
                    For t = 0 To hs - 1
                    dr = dt.Rows(t)
                    yphh = dr.Item("yphh").ToString()
                    zlmxid = dr.Item("zlmxid").ToString()
                    ggid = dr.Item("ggid").ToString()
                    l = 0
                    l = 877 - (3 - 1) * 20
                    l = (l / 3)

                    %>
                    <div style="width: 100%; height: <%=l%>px">
                        <table style="height: 100%; width: 100%; border-right-width: 0px; border-right-color: white;font-size:16px;
                            border-bottom-width: 0px;" class="ggcss">
                            <%
                            sql = " select cmdm,cm as cmmc from yx_t_cmzh where tml=( "
                            sql += "   select top 1 lb.tml from  yf_t_cpkfjh a inner join yf_t_cpkfzlb b on a.id=b.id "
                            sql += "   inner join yf_t_cpkfsjtg c on b.zlmxid=c.zlmxid  inner join YX_T_splb lb on a.splbid=lb.id and b.zlmxid=" + zlmxid + " "
                            sql += " ) and cmdm<>'' "
                            'Response.Write(sql)


                            ds = lbdll.CreateDataSet(myconn, sql)
                            jls = ds.Tables(0).Rows.Count
                            'Response.Write(jls)
                            'Response.End() '一共10列数据
                            Dim i As Integer

                            %>
                            <tr>
                                <td style="width:<%=100.00/(jls+2)%>%; text-align: center;">
                                    &nbsp;
                                </td>
                                <%
                                For i = 0 To (jls - 1)
                                %>
                                <td style="width: <%=100.00/(jls+2)%>%; text-align: center;">
                                    <%=ds.Tables(0).Rows(i).Item("cmmc").ToString()

                                    %>
                                </td>
                                <%
                                Next
                                %>
                                <td style="text-align: center; border-right-width: 0px;">
                                    允许误差
                                </td>
                            </tr>

                            <%   sql = " declare @cmzd nvarchar(2000);declare @sql nvarchar(2000); "
                            sql += "  select @cmzd=isnull((select ',sum(case when a.dm='''+cmdm+''' then a.sz else 0 end) '+cmdm  "
                            sql += "  from yx_t_cmzh where tml=( select top 1 lb.tml from yf_t_cpkfzlb a "
                            sql += "  inner join yf_t_cpkfsjtg bb on a.zlmxid=bb.zlmxid and bb.tplx='sjtg' "
                            sql += "  inner join yf_t_cpkfjh_ghs b on a.id=b.id and a.mxid=b.mxid  "
                            sql += "  inner join yf_t_cpkfjh c on b.id=c.id  "
                            sql += "  inner join yx_T_splb lb on c.splbid=lb.id where a.zlmxid=" + zlmxid
                            sql += " ) for xml path('')),'') "
                            sql += " select @sql = ' select a.mc '+@cmzd+',max(a.gc) gc from yf_T_ytfab b "
                            sql += " inner join yf_T_ytfamxb a on b.id=a.id where b.id=" + ggid + " and b.dm+b.mc+isnull(b.kfbx,'''')=''" + yphh + "'' and b.lx=''jsggb'' group by a.mc order by min(a.mxid);' "
                            sql += " exec (@sql) "


                            ds = lbdll.CreateDataSet(myconn, sql)
                            jls = ds.Tables(0).Rows.Count
                            Dim col_jls As Integer
                            col_jls = ds.Tables(0).Columns.Count
                            Dim j, k As Integer

                            For k = 0 To (jls - 1)
                            %>
                            <tr>
                                <%
                                For j = 0 To (col_jls - 1)

                                %>
                                <td style="text-align: center; border-right-width: 0px;">
                                    <%=String.Format("{0:0.##}", ds.Tables(0).Rows(k).Item(j)) %>
                                    <%-- &nbsp;<%= IIf(ds.Tables(0).Rows(k).Item(j).ToString() = "0.0", "", ds.Tables(0).Rows(k).Item(j).ToString()) %>--%>
                                </td>
                                <% Next%>
                            </tr>
                            <% Next%>
                        </table>
                    </div>
                    <div style="width: 100%; height: 20px;">
                    </div>
                    <% Next%>
                </div>
            </div>
            <!--右侧内容-->
            <div style="width: 50%; height: 100%; float: left; border-bottom-width: 0px;">
                <!--缝制要求-->
                <div style="width: 100%; height: <%=all-hzyqg-bztg%>%;">


                    <table style="height: 100%; width: 100%;" class="ggcss">
                        <tr id="xdfzyqid">
                            <td rowspan="2" style="text-align: center; width: 30px; border-bottom-width: 0px;">
                                缝制要求
                            </td>
                            <td style="text-align: center; width: 4%;">
                                用针有线
                            </td>
                            <td style="text-align: left; width: 736px; height: <%=yzyxg%>%;">
                                <%= yzyx%>
                            </td>
                        </tr>
                        <tr id="xdfzyqid2">
                            <td colspan="2" style="text-align: left; height: <%=all-yzyxg%>%; border-bottom-width: 0px;">
                                <%=fzyq%>
                            </td>
                        </tr>
                    </table>
                </div>
                <!--后整要求-->
                <div style="width: 100%; height: <%=hzyqg %>%;">
                    <table style="height: 100%; border-bottom-width: 0px;" class="ggcss">
                        <tr>
                            <td style="text-align: center; width: 4%; border-bottom-width: 0px;">
                                后整要求
                            </td>
                            <td style="text-align: left; width: 96%; border-bottom-width: 0px;">
                                <%=hzyq %>
                            </td>
                        </tr>
                    </table>
                </div>
                <!--包装图-->
                <div style="width: 100%; height: <%=bztg%>%;">
                    <%Dim a As Integer
                    a = 909 * bztg / 100.0
                    %>
                    <div style="text-align: center; float: left; height: 100%; width: 30px; border: 1px solid #000;border-bottom-width: 0px;">
                        <p>包装图</p>
                    </div>
                    <div style="padding: 0; overflow: hidden; text-align:center; width: 732px; height: 100%; border: 1px solid #000; border-bottom-width: 0px;">
                        <img alt="包装图" src="ScaleImage.aspx?MyPath=<%=bzt %>&Height=<%=a %>&Width=732&scale=0" />

                    </div>

                </div>
            </div>
        </div>
        <!--页脚内容-->
        <div id="xddiv23" style="width: 1530px; height: 32px; border: 1px solid #000;">
            <table style="border-width: 1px; border-color: black; height: 32px; width: 100%;">
                <tr>
                    <td>
                        <p>
                            注：工厂在产前工作中：样衣/样板/工艺单/配料/排版如有不详之处，请及时反馈至技术部解决，联系电话：0595--85618861
                        </p>
                    </td>
                </tr>
            </table>
        </div>
    </div>
    <%End If%>


    <% If mblx = "JK" Then '夹克%>
    <table cellspacing="0" bordercolor="black" border="0" style="border-left-width: 0.3cm;
        border-right-width: 0.3cm; font-size: 14pt; width: 1532px; height: 64px; border-left-color: black;
        border-bottom-color: black; border-top-color: black; border-collapse: collapse;
        border-right-color: black;">
        <tr align="right" style="font-size: 14px;">
            <td>
                &nbsp;&nbsp;表格编号:<%=bgbh %>&nbsp;
            </td>
        </tr>
        <tr align="center" style="font-size: 32px; font-family: 粗体;">
            <td>
                利郎产品制造单（一）
            </td>
        </tr>
        <tr align="right" style="font-size: 14px;">
            <td>
                &nbsp;&nbsp;序号:<%=xh %>&nbsp;
            </td>
        </tr>
    </table>
    <table cellspacing="0" bordercolor="black" border="1" style="border-left-width: 0cm;
        border-right-width:1px; font-size: 9pt; width: 1532px; height: 32px; border-left-color: black;
        border-bottom-color: black; border-top-color: black; border-collapse: collapse;
        border-right-color: black;">
        <tr style="font-size: 15px;">
            <td class="col4">
                &nbsp;产品名称：<%= splbmc%>
            </td>
            <td class="col4">
                &nbsp;样衣号：<%= yphh%>
            </td>
            <td class="col4">
                &nbsp;货号：<%= sphh%>
            </td>
            <td class="col4">
                &nbsp;制表日期：<%= zdrq%>
            </td>
        </tr>
        <tr>
            <td align="center" colspan="4" style="font-size: 15px;height:32px;">
                <p style="margin-top:2px;"> 款&nbsp;&nbsp;&nbsp;&nbsp;式&nbsp;&nbsp;&nbsp;&nbsp;平&nbsp;&nbsp;&nbsp;&nbsp;面&nbsp;&nbsp;&nbsp;&nbsp;图</p>
            </td>
        </tr>
    </table>

    <div style="width: 1530px; height: 788px;border:1px solid #000;float:left;text-align:center;">

        <%
        If twosgtp.ToString() = "" Then
        %>

        &nbsp;

        <%
        ElseIf twosgtp.Split("|")(1).ToString = "" Then

        %>

        <div class="tp-xgt" style="height:100%;width:99.5%;">
            <img alt="" src="ScaleImage.aspx?MyPath=<%=twosgtp.Split(" |")(0) %>&Height=787&Width=1530&scale=0" />
        </div>

        <%
        Else

        %>
        <div style="width: 49.5%; height: 99%">
            <img alt="" src="ScaleImage.aspx?MyPath=<%=twosgtp.Split(" |")(0) %>&Height=787&Width=765&scale=0" />
        </div>
        <div style="width: 49.5%; height: 99%">
            <img alt="" src="ScaleImage.aspx?MyPath=<%=twosgtp.Split(" |")(1) %>&Height=787&Width=765&scale=0" />
        </div>

        <%
        End If

        %>
    </div>

    <table cellspacing="0" bordercolor="black" border="1" style="border-left-width: 0cm;
        border-right-width:1px; font-size: 9pt; width: 1532px; height: 1cm; border-left-color: black;
        border-bottom-color: black; border-top-color: black; border-collapse: collapse;
        border-right-color: black;">
        <tr align="left" style="font-size: 14px;">
            <td>
                &nbsp;&nbsp;注：工厂在产前工作中：样衣/样板/工艺单/配料/排版如有不符之处，请及时反馈至技术部解决， 联系电话：0595－82893660;&nbsp;
            </td>
        </tr>
    </table>
    <table cellspacing="0" bordercolor="black" border="1" style="border-left-width: 0cm;
        border-right-width:1px;  width: 1532px; height: 32px; border-left-color: black;
        border-bottom-color: black; border-top-color: black; border-collapse: collapse;
        border-right-color: black;">
        <tr style="font-size: 16px;height:100%;width:100%; ">
            <td class="col4" style="width:25%;">
                &nbsp;制表：<%= zdr%>
            </td>
            <td class="col4" style="width:25%;">
                &nbsp;审核：
            </td>
            <td class="col4" style="width:25%;">
                &nbsp;样板审核：
            </td>
            <td class="col4" style="width:25%;">
                &nbsp;审批：
            </td>
        </tr>
    </table>
    <div style="page-break-after: always;">
    </div>
    <table cellspacing="0" bordercolor="black" border="0" style="border-left-width: 0cm;
        border-right-width: 0cm; font-size: 9pt; width: 40.5cm; height: 32px; border-left-color: black;
        border-bottom-color: black; border-top-color: black; border-collapse: collapse;
        border-right-color: black;">
        <tr align="center" style="font-size: 32px; font-family: 粗体;">
            <td>
                利郎产品制造单（二）
            </td>
        </tr>
    </table>
    <div style="width: 1532px; height: 948px;">
        <table style="width: 100%; height: 32px; font-size: 14pt; text-align: left;" class="ggcss">
            <tr>
                <td width="25%" style="text-align: left;">
                    &nbsp;产品名称：<%= splbmc%>
                </td>
                <td width="25%" style="text-align: left;">
                    &nbsp;样衣号：<%= yphh%>
                </td>
                <td width="25%" style="text-align: left;">
                    &nbsp;货号：<%= sphh%>
                </td>
                <td width="25%" style="text-align: left;">
                    &nbsp;制表日期：<%= zdrq%>
                </td>
            </tr>
        </table>
        <div style="width: 1532px; height: 916px;">
            <div style="width: 50%; float: left; height: 100%;">
                <!--规格表-->
                <div style="width: 100%; height: <%=ggbg %>%">
                    <table style="height: 100%; width:100%;border-right-width: 0px; border-right-color: white;"
                           class="ggcss">
                        <%
                        sql = " select cmdm,cm as cmmc from yx_t_cmzh where tml=( "
                        sql += "   select top 1 lb.tml from  yf_t_cpkfjh a inner join yf_t_cpkfzlb b on a.id=b.id "
                        sql += "   inner join yf_t_cpkfsjtg c on b.zlmxid=c.zlmxid  inner join YX_T_splb lb on a.splbid=lb.id and b.zlmxid=" + zlmxid + " "
                        sql += " ) and cmdm<>'' "
                        'Response.Write(sql)
                        ds = lbdll.CreateDataSet(myconn, sql)
                        jls = ds.Tables(0).Rows.Count
                        Dim i As Integer = 0

                        %>
                        <tr>
                            <td style="width: 18%; text-align: center;">
                                &nbsp;
                            </td>
                            <%
                            For i = 0 To jls - 1
                            %>
                            <td style="width: <%=82.00/(jls+1)%>%; text-align: center;">
                                <%=ds.Tables(0).Rows(i).Item("cmmc").ToString() %>
                            </td>
                            <%
                            Next
                            %>
                            <td style="width: <%=82.00/(jls+1)%>%; text-align: center; font-size: 12px; border-right-width: 0px;">
                                允许误差
                            </td>
                        </tr>
                        <%
                        sql = " declare @cmzd nvarchar(2000);declare @sql nvarchar(2000); "
                        sql += "  select @cmzd=isnull((select ',sum(case when a.dm='''+cmdm+''' then a.sz else 0 end) '+cmdm  "
                        sql += "  from yx_t_cmzh where tml=( select top 1 lb.tml from yf_t_cpkfzlb a "
                        sql += "  inner join yf_t_cpkfsjtg bb on a.zlmxid=bb.zlmxid and bb.tplx='sjtg' "
                        sql += "  inner join yf_t_cpkfjh_ghs b on a.id=b.id and a.mxid=b.mxid  "
                        sql += "  inner join yf_t_cpkfjh c on b.id=c.id  "
                        sql += "  inner join yx_T_splb lb on c.splbid=lb.id where a.zlmxid=" + zlmxid
                        sql += " ) for xml path('')),'') "
                        sql += " select @sql = ' select a.mc '+@cmzd+',max(a.gc) gc from yf_T_ytfab b "
                        sql += " inner join yf_T_ytfamxb a on b.id=a.id where b.id=" + ggid + " and b.dm+b.mc+isnull(b.kfbx,'''')=''" + yphh + "'' and b.lx=''jsggb'' group by a.mc order by min(a.mxid);' "
                        sql += " exec (@sql) "
                        ds = lbdll.CreateDataSet(myconn, sql)
                        jls = ds.Tables(0).Rows.Count
                        Dim col_jls, size As Integer
                        Dim w As Double
                        col_jls = ds.Tables(0).Columns.Count
                        Dim j, m As Integer

                        %>
                        <%
                        For m = 0 To jls - 1
                        %>
                        <tr>
                            <%
                            For j = 0 To col_jls - 1
                            If j = 0 Then
                            w = 18
                            size = 14
                            Else
                            w = 82.0 / (col_jls - 1)
                            size = 15

                            End If
                            %>
                            <td style="width: <%=w%>%; font-size: <%=size%>px; text-align: center; border-right-width: 0px;">
                                <%=String.Format("{0:0.##}", ds.Tables(0).Rows(m).Item(j)) %>
                                <%--&nbsp;<%= IIf(ds.Tables(0).Rows(i).Item(j).ToString() = "0.0", "", ds.Tables(0).Rows(i).Item(j).ToString()) %>--%>
                            </td>
                            <% Next%>
                        </tr>
                        <% Next%>
                    </table>
                </div>


                <!--注意事项-->
                <div style="width: 100%; height: <%=zysxg %>%">
                    <table style="height: 100%;" class="ggcss">
                        <tr>
                            <td width="4%" style="text-align: center;">
                                注意事项
                            </td>
                            <td width="96%" style="text-align: left;">
                                <%= zysx%>
                            </td>
                        </tr>
                    </table>
                </div>
                <!--裁剪-->
                <div style="width: 100%; height: <%=cjg %>%">
                    <table style="height: 100%;" class="ggcss">
                        <tr id="cjid">
                            <td width="4%" style="text-align: center;">
                                裁剪
                            </td>
                            <td width="96%" style="text-align: left;">
                                <%= cj%>
                            </td>
                        </tr>
                    </table>
                </div>
                <!--后整要求-->
                <div style="width: 100%; height: <%=hzyqg %>%">
                    <table style="height: 100%;" class="ggcss">
                        <tr>
                            <td width="4%" style="text-align: center;">
                                后整要求
                            </td>
                            <td width="96%" style="text-align: left;">
                                <%= hzyq%>
                            </td>
                        </tr>
                    </table>
                </div>
            </div>
            <div style="width: 50%; float: left; height: 913px;">
                <!--缝制要求-->
                <div style="width: 100%; height: <%=fzyqg %>%;">
                    <table style="height: 100%;" class="ggcss">
                        <tr id="fzyqid">
                            <td rowspan="2" style="text-align: center;width:30px;">
                                缝制要求
                            </td>
                            <td style="width:30px;text-align: center;height:<%=yzyxg%>%;">
                                用针有线
                            </td>
                            <td width="92%" style="width:706px;text-align: left;height:<%=yzyxg%>%;">
                                <%= yzyx%>
                            </td>
                        </tr>
                        <tr id="fzyqid2">
                            <td colspan="2" style="text-align: left;height:<%=all-yzyxg%>%">
                                <%= fzyq%>
                            </td>
                        </tr>
                    </table>
                </div>
                <!--包装图-->
                <div style="width: 100%; height: <%=bztg %>%;">
                    <%Dim q As Integer
                    q = 912 * bztg * 9 / 1000.0
                    %>
                    <div style="text-align: center;float:left;height:100%;width:30px;border:1px solid #000;">
                        <p>包装图</p>
                    </div>
                    <div style="padding: 0; overflow: hidden;text-align:center;width:732px;height:90%;border:1px solid #000;border-top-width:0px;">
                        <img alt="包装图" src="ScaleImage.aspx?MyPath=<%=bzt %>&Height=<%=q %>&Width=732&scale=0" />

                    </div>
                    <div style="text-align: left;height:10%;float:left;width:732px;float:left;border:1px solid #000;border-top-width:0px;">
                        <%= bztxx%>

                    </div>

                </div>
            </div>
        </div>
    </div>
    <%End If%>



    <% If mblx = "ZTCS" Then '正统衬衫%>
    <!--衬衫制造单1号-->
    <div id="ztcszzd1" style="width: 1532px; height: 980px;">
        <div style="width: 1532px; height: 96px;">
            <div style="height: 32px; width: 100%;font-size:32px; text-align: center; font-family: 粗体;">
                <p>利郎（中国）有限公司产品制造单</p>
            </div>

            <table border="1" style="border-left-width: 0px; border-bottom-width: 0px; border-right-width: 0px;
                width: 100%; height: 32px; border-left-color: black; border-top-color: black;
                border-collapse: collapse;">
                <tr style="font-size: 15px;">
                    <td class="col4" style="width: 25%">
                        &nbsp;产品名称：<%= splbmc%>
                    </td>
                    <td class="col4" style="width: 25%">
                        &nbsp;样衣号：<%= yphh%>
                    </td>
                    <td class="col4" style="width: 25%">
                        &nbsp;货号：<%= sphh%>
                    </td>
                    <td class="col4" style="width: 25%; border-right-color: black; border-right-width: 1px;">
                        &nbsp;制表日期：<%= zdrq%>
                    </td>
                </tr>
            </table>
            <table border="1" style=" border:1px solid #000; border-left-width 0px; border-bottom-width 0px;
                   width 100%; height 32px; border-collapse collapse;">
                <tr>
                    <td class="top2" colspan="2" style="text-align: center; font-size: 15px;">
                        效果图
                    </td>
                    <td class="top2" colspan="2" style="text-align: center; font-size: 15px;">
                        平面施工图
                    </td>
                </tr>
            </table>
        </div>
        <div style="width: 1532px; height: 884px;">
            <div style="width: 1530px; height: <%=ytg%>%;border:1px solid #000;text-align:center;float:left;">
                <%Dim q As Integer
                q = 852 * ytg / 100
                %>
                <%
                If twosgtp.ToString() = "" Then  %>

                <%
                ElseIf twosgtp.Split("|")(1).ToString = "" Then

                %>

                <img alt="" src="ScaleImage.aspx?MyPath=<%=twosgtp.Split(" |")(0) %>&Height=<%=q %>&Width=1530&scale=0" />

                <%

                Else
                %>

                <div style="width: 49.5%; height: 99%">
                    <img alt="" src="ScaleImage.aspx?MyPath=<%=twosgtp.Split(" |")(0) %>&Height=<%=q %>&Width=765&scale=0" />
                </div>
                <div style="width: 49.5%; height: 99%">
                    <img alt="" src="ScaleImage.aspx?MyPath=<%=twosgtp.Split(" |")(1) %>&Height=<%=q %>&Width=765&scale=0" />
                </div>


                <%
                End If

                %>

            </div>

            <div style="width: 1530px; height: <%=all-ytg%>%;border:1px solid #000; ">
                <table class="ggcss" border="1" style="border:0px solid #000;width: 100%; height: 100%;border-collapse: collapse;">
                    <tr>
                        <td style="text-align: center; width:4%;">
                            注<br />
                            意<br />
                            事<br />
                            项
                        </td>
                        <td style="text-align: left; width:96%;">
                            <p>
                                1.拉布前必须进行面料检验，并做松布处理（面布松布24小时以上）。
                            </p>
                            <p>
                                2.烫衬部位严格按照工艺及面料需求：粘衬要求牢固，不允许出现脱胶，透胶起泡等现象。
                            </p>
                            <p>
                                3.其他细节部位按样衣。
                            </p>
                        </td>
                    </tr>
                </table>
            </div>
        </div>
        <div style="page-break-after: always;">
        </div>
    </div>
    <!--衬衫制造单2号-->
    <div id="zzd2" style="width: 1532px; height: 980px;">
        <div id="top3" style="height: 128px;">
            <table border="0" style="height: 64px; border-left-width: 0px; border-right-width: 0px;
                width: 100%; border-left-color: black; border-top-color: black; border-collapse: collapse;
                border-right-color: black;">
                <tr style="font-size: 14px; text-align: right;">
                    <td>
                        &nbsp;&nbsp;表格编号：<%=bgbh %>&nbsp;&nbsp;&nbsp;&nbsp;
                    </td>
                </tr>
                <tr style="font-size: 32px; text-align: center; font-family: 粗体;">
                    <td>
                        利郎产品制造单（二）
                    </td>
                </tr>
            </table>
            <table style="width: 100%; height: 32px; font-size: 14pt; text-align: left;" class="ggcss">
                <tr>
                    <td class="col4" style="text-align: left; width: 25%; border-bottom-width: 0px; border-bottom-color: white;">
                        &nbsp;产品名称：<%= splbmc%>
                    </td>
                    <td class="col4" style="text-align: left; width: 25%; border-bottom-width: 0px; border-bottom-color: white;">
                        &nbsp;样衣号：<%= yphh%>
                    </td>
                    <td class="col4" style="text-align: left; width: 25%; border-bottom-width: 0px; border-bottom-color: white;">
                        &nbsp;货号：<%= sphh%>
                    </td>
                    <td class="col4" style="text-align: left; width: 25%; border-bottom-width: 0px; border-bottom-color: white;">
                        &nbsp;制表日期：<%= zdrq%>
                    </td>
                </tr>
            </table>
            <table style="width: 100%; height: 32px; font-size: 16pt; font-family: 粗体; text-align: center; border-top-width: 0px; border-left-width: 0px; border-top-color: black;"
                   class="ggcss">
                <tr>
                    <td class="col4" style="text-align: center; width: 50%; border-bottom-width: 0px; border-right-width: 0px;">
                        成衣规格尺寸
                    </td>
                    <td class="col4" style="text-align: center; width: 50%; border-bottom-width: 0px; border-bottom-color: white;">
                        包装图示
                    </td>
                </tr>
            </table>
        </div>
        <div style="width: 1532px; height: 820px;">
            <!--左侧栏目-->
            <div style="width: 50%; float: left; height: 820px;">
                <!--规格表-->
                <div style="width: 100%; height: <%=ggbg %>%;border:1px solid #000; border-top-width:0px;border-right-width:0px;">

                    <%
                    sql = " declare @cmzd nvarchar(2000);declare @sql nvarchar(2000); "
                    sql += "  select @cmzd=isnull((select ',sum(case when a.dm='''+cmdm+''' then a.sz else 0 end) '+cmdm  "
                    sql += "  from yx_t_cmzh where tml=( select top 1 lb.tml from yf_t_cpkfzlb a "
                    sql += "  inner join yf_t_cpkfsjtg bb on a.zlmxid=bb.zlmxid and bb.tplx='sjtg' "
                    sql += "  inner join yf_t_cpkfjh_ghs b on a.id=b.id and a.mxid=b.mxid  "
                    sql += "  inner join yf_t_cpkfjh c on b.id=c.id  "
                    sql += "  inner join yx_T_splb lb on c.splbid=lb.id where a.zlmxid=" + zlmxid
                    sql += "  )and cmdm<='cm39' for xml path('')),'') "
                    sql += " select @sql = ' select a.mc '+@cmzd+',max(a.gc) gc from yf_T_ytfab b "
                    sql += " inner join yf_T_ytfamxb a on b.id=a.id where b.id=" + ggid + " and b.dm+b.mc+isnull(b.kfbx,'''')=''" + yphh + "'' and b.lx=''jsggb'' group by a.mc order by min(a.mxid);' "
                    sql += " exec (@sql) "
                    Dim cscol_jls, size As Integer
                    Dim w As Double
                    csds = lbdll.CreateDataSet(myconn, sql)
                    csjls = csds.Tables(0).Rows.Count '行数
                    cscol_jls = csds.Tables(0).Columns.Count '列数
                    Dim j, m As Integer
                    'If (csjls + 1) * 5 > 100 Then
                    '    height = 100
                    'Else
                    '    height = (csjls + 1) * 5
                    'End If
                    %>
                    <table style="height:100%; width:100%;border-right-width: 0px; border-right-color: white;"
                           class="ggcss">
                        <%
                        sql = " select cmdm,cm as cmmc from yx_t_cmzh where tml=( "
                        sql += "   select top 1 lb.tml from  yf_t_cpkfjh a inner join yf_t_cpkfzlb b on a.id=b.id "
                        sql += "   inner join yf_t_cpkfsjtg c on b.zlmxid=c.zlmxid  inner join YX_T_splb lb on a.splbid=lb.id and b.zlmxid=" + zlmxid + " "
                        sql += " ) and cmdm<>'' and cm <'66'"
                        ds = lbdll.CreateDataSet(myconn, sql)
                        jls = ds.Tables(0).Rows.Count
                        Dim i As Integer = 0
                        'Response.Write(sql)
                        'Response.End()

                        %>
                        <tr>
                            <td style="width:18%; text-align: center;">
                                &nbsp;
                            </td>
                            <%
                            For i = 0 To jls - 1
                            %>
                            <td style="width: <%=82.00/(jls+1)%>%; text-align: center;">
                                <%=ds.Tables(0).Rows(i).Item("cmmc").ToString() %>
                            </td>
                            <%
                            Next
                            %>
                            <td style="width: <%=82.00/(jls+1)%>%;text-align: center;font-size:12px; border-right-width: 0px;">
                                允许误差
                            </td>
                        </tr>
                        <%



                        %>
                        <%
                        For m = 0 To csjls - 1
                        %>
                        <tr>
                            <%
                            For j = 0 To cscol_jls - 1
                            If j = 0 Then
                            w = 18
                            size = 14
                            Else
                            w = 82.0 / (cscol_jls - 1)
                            size = 15

                            End If
                            %>
                            <td style="width:<%=w%>%;font-size:<%=size%>px;text-align: center; border-right-width: 0px;">
                                <%=String.Format("{0:0.##}", csds.Tables(0).Rows(m).Item(j)) %> <!--显示尺寸的明细内容-->
                                <%-- &nbsp;<%= IIf(ds.Tables(0).Rows(i).Item(j).ToString() = "0.0", "", ds.Tables(0).Rows(i).Item(j).ToString()) %>--%>
                            </td>
                            <% Next%>
                        </tr>
                        <% Next%>
                    </table>
                </div>
                <!--注意事项-->
                <div style="width: 100%; float: left; height: <%=zysxg %>%;border:1px solid #000;border-top-width:0px;border-right-width:0px;border-bottom-width:0px;">
                    <div style="width:100%;text-align:left;">
                        <%If zysx <> "" Then  %>
                        注意事项：<%= zysx%><br />

                        <%end If %><%If fzyq <> "" Then  %>
                        缝制要求：<%=fzyq %>
                        <%end If %><%If hzyq <> "" Then  %>
                        后整要求：<%=hzyq %><br />
                        <%end If %><%If cj <> "" Then  %>
                        裁剪要求：<%=cj %><br />
                        <%end If %><%If yzyx <> "" Then  %>
                        用针用线：<%=yzyx %>
                        <%end if %>
                    </div>

                </div>
            </div>
            <!--右侧栏目-->
            <div style="width: 49.999%; float: left; height: 100%">
                <!--包装图示-->
                <div style="width: 100%; float: left; height: 100%;">
                    <!--包装图-->
                    <div style="width: 764px; height: <%=bztg%>%; border:1px solid #000;">
                        <%Dim a As Integer
                        a = 819 * bztg / 100.00 %>
                        <img alt="包装图" src="ScaleImage.aspx?MyPath=<%=bzt %>&Height=<%=a %>&Width=760&scale=0" />

                    </div>
                    <div style="width: 100%; height: <%=all-bztg%>%;">
                        <table style="table-layout: fixed; height: 100%;width:100%;" class="ggcss">
                            <tr style="width:100%;height:100%;">
                                <td style="width: 100%; padding: 0; text-align: left; overflow: hidden; border-bottom-width: 0px;
                                    border-top-width: 0px;">
                                    <%=bztxx %>
                                </td>
                            </tr>
                        </table>
                    </div>
                </div>
            </div>
        </div>
        <!--页脚-->
        <div style="height: 32px; width: 1532px;">
            <table style="width: 100%; height: 1cm; font-size: 20px; font-family: 粗体; text-align: left;"
                   class="ggcss">
                <tr style="width:100%;">
                    <td style="text-align: left;width:33.33%;">
                        制表：<%= zdr %>
                    </td>
                    <td style="text-align: left;width:33.33%;">
                        审核：
                    </td>
                    <td style="text-align: left;width:33.33%;">
                        审批：
                    </td>
                </tr>
            </table>
        </div>
    </div>
    <%  End If%>


    <%If mblx = "XXK" Then '休闲裤%>

    <!--休闲裤制造单1号-->
    <div style="width: 1532px; height: 980px;">
        <!--页头-->
        <div id="xxkdiv1" style="height: 96px; width: 100%;">
            <div style="height: 32px; width: 100%;font-size:32px; text-align: center; font-family: 粗体;">
                <p>利郎（中国）有限公司产品制造单</p>
            </div>
            <table style="width: 100%; height: 32px; font-size: 16px; text-align: left;" class="ggcss">
                <tr>
                    <td class="xxktd2">
                        &nbsp;产品名称：<%= splbmc%>
                    </td>
                    <td class="xxktd2">
                        &nbsp;样衣号：<%= yphh%>
                    </td>
                    <td class="xxktd2">
                        &nbsp;货号：<%= sphh%>
                    </td>
                    <td class="xxktd2">
                        &nbsp;版型：<%= bx%>
                    </td>
                    <td class="xxktd2">
                        &nbsp;水洗方式：<%= sxfs%>
                    </td>
                    <td class="xxktd2">
                        &nbsp;制表日期：<%= zdrq%>
                    </td>
                </tr>
            </table>
            <table style="width: 100%; height: 32px;" class="ggcss">
                <tr>
                    <td class="xxktd3">
                        &nbsp;82#前袋布规格：<%= splbmc%>
                    </td>
                    <td class="xxktd3" style="border-right-width: 1px;">
                        &nbsp;烫衬部位：<%= yphh%>
                    </td>
                </tr>
            </table>
        </div>
        <div style="width: 100%; height: 882px;">
            <!--工艺图-->
            <%'Response.Write(twosgtp)
            'Response.end
            %>
            <div id="xxkdiv2" class="gyt" style="height: <%=ytg%>%; width: 1530px; text-align:center; border-bottom-width: 1px;">
                <%Dim q As Integer
                q = 880 * ytg / 100
                %>
                <%
                If twosgtp.ToString() = "" Then
                %>
                &nbsp;
                <%
                ElseIf twosgtp.Split("|")(1).ToString = "" Then

                %>

                <img alt="工艺图" style="" src="ScaleImage.aspx?MyPath=<%=twosgtp.Split(" |")(0) %>&Height=<%=q %>&Width=1528&scale=0" />


                <%
                Else
                %>
                <div style="width: 49.5%; height: 99%">
                    <img alt="" src="ScaleImage.aspx?MyPath=<%=twosgtp.Split(" |")(0) %>&Height=<%=q %>&Width=764&scale=0" />
                </div>
                <div style="width: 49.5%; height: 99%">
                    <img alt="" src="ScaleImage.aspx?MyPath=<%=twosgtp.Split(" |")(1) %>&Height=<%=q %>&Width=764&scale=0" />

                </div>


                <%
                End If

                %>

            </div>
            <!--页脚-->
            <div style="width:1530px;height: <%=all-ytg%>%;">
                <!--左侧栏目-->
                <div id="xxkdiv4" style="height: 100%; width: 50%; float: left; font-size: 15px;">
                    <div id="xxkzysx" style="width: 100%; height: <%=zysxg%>%;">
                        <div style="text-align: center; width: 30px; height: 100%; float: left; border: 1px solid #000; border-bottom-width: 0px; border-right-width: 0px;">
                            <p style="margin-top: auto;">
                                注<br />
                                意<br />
                                事<br />
                                项
                            </p>
                        </div>
                        <div style="text-align: left; width: 733px; height: 100%; float: left; border: 1px solid #000; border-bottom-width: 0px; border-right-width: 0px;">
                            <p style="margin-top: 3px;"><%=zysx%></p>

                        </div>
                    </div>
                    <div id="xxkcjyq" style="width: 100%; height: <%=cjg%>%;">
                        <div style="text-align: center; width: 30px; height: 100%; float: left; border: 1px solid #000; border-bottom-width: 0px; border-right-width: 0px;">
                            <p style="margin-top: auto;">
                                裁<br />
                                剪<br />
                                要<br />
                                求
                            </p>
                        </div>
                        <div style="text-align: left; width: 733px; height: 100%; float: left; border: 1px solid #000; border-bottom-width: 0px; border-right-width: 0px;">
                            <p style="margin-top: 3px;"><%=cj%></p>
                        </div>
                    </div>
                    <div id="xxkhzyq" style="width: 100%; height: <%=hzyqg%>%;">
                        <div style="text-align: center; width: 30px; height: 100%; float: left; border: 1px solid #000; border-right-width: 0px;">
                            <p style="margin-top: auto;">
                                后<br />
                                整<br />
                                要<br />
                                求
                            </p>
                        </div>
                        <div style="text-align: left; width: 733px; height: 100%; float: left; border: 1px solid #000; border-right-width: 0px;">
                            <p style="margin-top: 3px;"><%=hzyq%></p>
                        </div>
                    </div>
                </div>

                <!--右侧栏目-->

                <div id="xxkdiv3" style="height: 100%; width: 50%; float: left;font-size:16px;">
                    <div id="xxkzysx" style="width: 100%; height: <%=yzyxg%>%;border:1px solid #000;border-bottom-width:0px;border-top-width:0px;">
                        <div style="text-align: center; width: 30px; height: 100%; float: left; border: 1px solid #000; border-bottom-width: 0px; border-right-width: 0px;">
                            <p style="margin-top: auto;">
                                用<br />
                                针<br />
                                用<br />
                                线
                            </p>
                        </div>
                        <div style="text-align: left; width: 732px; height: 100%; float: left; border: 1px solid #000; border-bottom-width: 0px;">
                            <p style="margin-top: 3px;"><%=yzyx%></p>

                        </div>
                    </div>
                    <div id="xxkcjyq" style="width: 100%; height: <%=fzyqg%>%;border:1px solid #000;border-bottom-width:0px;border-top-width:0px;">
                        <div style="text-align: center; width: 30px; height: 100%; float: left; border: 1px solid #000; border-bottom-width: 0px; border-right-width: 0px;">
                            <p style="margin-top: auto;">
                                缝<br />
                                制<br />
                                要<br />
                                求
                            </p>
                        </div>
                        <div style="text-align: left; width: 732px; height: 100%; float: left; border: 1px solid #000; border-bottom-width: 0px;">
                            <p style="margin-top: 3px;"><%=fzyq%></p>
                        </div>
                    </div>
                    <div id="xxkhzyq" style="width: 100%; height: <%=all-yzyxg-fzyqg%>%;">
                        <div style="text-align: center; width: 100%; height: 100%; float: left; border: 1px solid #000;">
                            <p style="margin-top: auto;">
                                如有不明之处，请与利郎技术部联系：18688062418
                            </p>
                        </div>

                    </div>


                </div>
            </div>
        </div>
        <div style="page-break-after: always;">
        </div>
    </div>
    <!--休闲裤制造单2号-->
    <div id="xxkzzd2" style="width: 1532px; height: 980px;">
        <!--页头内容-->
        <div id="xxkdiv21" style="height: 32px; width: 100%;">
            <table border="0" style="height: 32px; width: 100%;">
                <tr>
                    <td style="font-size: 32px; text-align: center; font-family: 粗体;">
                        利郎（中国）有限公司产品制造单
                    </td>
                </tr>
            </table>
        </div>
        <div id="xxkzzd22" style="width: 1530px; height: 948px; border: 1px solid #000">
            <!--左侧内容-->
            <div style="width: 50%; height: 100%; float: left; border-bottom-width: 1px;">
                <!--标题内容-->
                <div style="width: 100%; height: 32px;">
                    <table style="width: 100%; height: 32px; font-size: 14pt; text-align: left;" class="">
                        <tr>
                            <td class="xdtd2">
                                &nbsp;货号：<%= sphh%>
                            </td>
                            <td class="xdtd2">
                                &nbsp;版号：<%= yphh%>
                            </td>
                            <td class="xdtd2" style="border-right-width: 0px;">
                                &nbsp;单位：CM
                            </td>
                        </tr>
                    </table>
                </div>
                <!--尺码内容-->
                <div style="width: 765px; height: 884px;">
                    <%
                    str_sql = "  select top 1 a.ypbh yphh, a.zlmxid, cc.id As ggid from yf_t_cpkfzlb a  "
                    str_sql += " inner join (select ypbh from yf_t_cpkfzlb where ypbh='" + yphh + "') b on a.ypbh=b.ypbh "
                    str_sql += " INNER JOIN yf_T_ytfab cc On a.ypbh = cc.dm + cc.mc + isnull(cc.kfbx,'') group by a.ypbh, a.zlmxid, cc.id  "
                    'Response.Write(str_sql)
                    'Response.End()
                    zlds = lbdll.CreateDataSet(myconn, str_sql)
                    zldt = zlds.Tables(0)
                    Dim hs As String
                    hs = zlds.Tables(0).Rows.Count
                    Dim t, l As Integer
                    For t = 0 To hs - 1
                    dr = zldt.Rows(t)
                    yphh = dr.Item("yphh").ToString()
                    zlmxid = dr.Item("zlmxid").ToString()
                    ggid = dr.Item("ggid").ToString()
                    l = 0
                    l = 825 - (hs - 1) * 20
                    l = (l / hs)
                    %>
                    <div style="width: 100%; height: <%=l%>px">
                        <table style="height: 100%; width: 100%; border-right-width: 0px; border-bottom-width: 0px;"
                               class="ggcss">
                            <%
                            sql = "select '' as cmdm,'' as cmmc union all ( select cmdm,case when cm ='40' then '其他' else cm end cmmc from yx_t_cmzh where tml=( "
                            sql += "   select top 1 lb.tml from  yf_t_cpkfjh a inner join yf_t_cpkfzlb b on a.id=b.id "
                            sql += "   inner join yf_t_cpkfsjtg c on b.zlmxid=c.zlmxid  inner join YX_T_splb lb on a.splbid=lb.id and b.zlmxid=" + zlmxid + " "
                            sql += " ) and cmdm<>'') union all ( select '' as cmdm,'允许公差' as cmmc)     "
                            ' Response.Write(sql)
                            Dim dscm As Data.DataSet
                            dscm = lbdll.CreateDataSet(myconn, sql)
                            %>
                            <%
                            sql = " declare @cmzd nvarchar(2000);declare @sql nvarchar(2000); "
                            sql += "  select @cmzd=isnull((select ',sum(case when a.dm='''+cmdm+''' then a.sz else 0 end) '+cmdm  "
                            sql += "  from yx_t_cmzh where tml=( select top 1 lb.tml from yf_t_cpkfzlb a "
                            sql += "  inner join yf_t_cpkfsjtg bb on a.zlmxid=bb.zlmxid and bb.tplx='sjtg' "
                            sql += "  inner join yf_t_cpkfjh_ghs b on a.id=b.id and a.mxid=b.mxid  "
                            sql += "  inner join yf_t_cpkfjh c on b.id=c.id  "
                            sql += "  inner join yx_T_splb lb on c.splbid=lb.id where a.zlmxid=" + zlmxid
                            sql += " ) for xml path('')),'') "
                            sql += " select @sql = ' select a.mc '+@cmzd+',max(a.gc) gc from yf_T_ytfab b "
                            sql += " inner join yf_T_ytfamxb a on b.id=a.id where b.id=" + ggid + " and b.dm+b.mc+isnull(b.kfbx,'''')=''" + yphh + "'' and b.lx=''jsggb'' group by a.mc order by min(a.mxid);' "
                            sql += " exec (@sql) "
                            'Response.Write(sql)
                            ds = lbdll.CreateDataSet(myconn, sql)
                            jls = ds.Tables(0).Rows.Count
                            Dim col_jls As Integer
                            col_jls = ds.Tables(0).Columns.Count
                            Dim j, k As Integer
                            ' Response.Write(jls) 7
                            'Response.Write(col_jls) 22

                            %>
                            <%
                            For j = 0 To (col_jls - 1)
                            %>
                            <tr>
                                <td style="width: 10%; height: <%=100.00/(col_jls+2)%>%; text-align: center;">
                                    <%=dscm.Tables(0).Rows(j).Item("cmmc").ToString()   %>
                                </td>
                                <%   For k = 0 To (jls - 1)%>

                                <td style="text-align: center; width: <%=90.00/jls%>%; border-right-width: 0px;">
                                    <%=String.Format("{0:0.##}", ds.Tables(0).Rows(k).Item(j)) %>
                                    <%--&nbsp;<%= IIf(ds.Tables(0).Rows(k).Item(j).ToString() = "0.0", "", ds.Tables(0).Rows(k).Item(j).ToString()) %>--%>
                                </td>
                                <% Next%>
                            </tr>
                            <% Next%>
                        </table>
                    </div>
                    <% Next%>
                    <div style="width: 100%; height: 59px;">
                        <p style="font-size: 20px;">
                            注：横档尺寸浪底下3cm处横量，前浪、后浪、尺寸含腰头，臀围浪上（70-76码8.5cm，78-86码：9cm，89-96码：9.5cm， 99-104码：10cm，106-112码：10.5cm）“V”量，膝围浪上33cm平量，脚口以脚边向上4cm横量
                        </p>
                    </div>
                </div>
            </div>
            <!--右侧内容-->
            <div style="width: 50%; height: 100%; float: left;">
                <div style="width: 100%; height: 95%; border: 1px solid #000; text-align:center;border-bottom-color: white;">

                    <%Dim a As Integer
                    a = 947 * 95 / 100.00 %>

                    <img alt="包装图" src="ScaleImage.aspx?MyPath=<%=bzt %>&Height=<%=a %>&Width=764&scale=0" />

                </div>
                <div>
                    <table border="1" style="width: 100%; height: 5%; border: 1px solid #000; border-bottom-color: black; border-collapse: collapse;">
                        <tr style="text-align: left;width:100%;">
                            <td style="width:33.33%;">
                                &nbsp;制表人：<%=zdr %>
                            </td>
                            <td style="width:33.33%;">
                                &nbsp;审核人：
                            </td>
                            <td style="width:33.33%;">
                                &nbsp;审批人：
                            </td>
                        </tr>
                    </table>
                </div>

            </div>
        </div>
    </div>
    <%End If%>
    <%If mblx = "XF" Then '西服%>

    <!--西服制造单1号-->
    <div style="height: 980px; width: 1532px;">
        <!--页头-->

        <div style="height: 32px; width: 100%;font-size:32px; text-align: center; font-family: 粗体;">
            <p>利郎（中国）有限公司产品制造单</p>
        </div>

        <!--标题-->
        <div id="xfbt" style="width: 100%; height: 32px;">
            <table style="width: 100%; height: 100%; font-size: 16px; text-align: left;" class="ggcss">
                <tr style="">
                    <td class="xdtd2" style="border-right-width: 0px;">
                        &nbsp;产品名称：<%= splbmc%>
                    </td>
                    <td class="xdtd2" style="border-right-width: 0px;">
                        &nbsp;样衣号：<%= yphh%>
                    </td>
                    <td class="xdtd2" style="border-right-width: 0px;">
                        &nbsp;货号：<%= sphh%>
                    </td>
                    <td class="xdtd2" style="border-right-width: 1px;">
                        &nbsp;制表日期：<%= zdrq%>
                    </td>
                </tr>
            </table>
        </div>
        <!--页面主体-->
        <div id="xfdiv2" style="width: 1532px; height: 916px;">
            <!--工艺图-->
            <div id="xfgyt" style="width: 1530px; height: <%=all-fzyqg%>%; border: 1px solid #000;">
                <%Dim q As Integer
                q = 916 * (all - fzyqg) / 100
                %>
                <div style="width:976px; height: 100%;border:0px solid #000;float:left;text-align:center;">

                    <%
                    If twosgtp.ToString() = "" Then
                    %>

                    <%
                    ElseIf twosgtp.Split("|")(1).ToString = "" Then

                    %>

                    <img alt="" src="ScaleImage.aspx?MyPath=<%=twosgtp.Split(" |")(0) %>&Height=<%=q %>&Width=976&scale=0" />

                    <%

                    Else
                    %>
                    <div style="width: 49.5%; height: 99%;float:left;">
                        <img alt="" src="ScaleImage.aspx?MyPath=<%=twosgtp.Split(" |")(0) %>&Height=<%=q %>&Width=488&scale=0" />
                    </div>
                    <div style="width: 49.5%; height: 99%;float:left;">
                        <img alt="" src="ScaleImage.aspx?MyPath=<%=twosgtp.Split(" |")(1) %>&Height=<%=q %>&Width=488&scale=0" />
                    </div>



                    <%-- <img id="" alt="工艺图" style="float:left;width: 49.5%;height:99%;" src="<%= twosgtp.Split(" |")(0)%>" />

                    <img id="" alt="工艺图" style="float:left;width: 49.5%;height:99%;" src="<%= twosgtp.Split(" |")(1)%>" />--%>

                    <%
                    End If

                    %>

                </div>


                <div id="xfxx" style="float: left; width: 36%; height: 100%;">
                    <table style="width: 100%; height: 100%; font-size: 15px;" border="0" cellspacing="0">
                        <tr style="width: 100%; height: <%=zysxg%>%;">
                            <td class="xftd" style="text-align: center; width: 10%;">
                                注<br />
                                意<br />
                                事<br />
                                项
                            </td>
                            <td class="xftd" style="text-align: left; width: 90%;">
                                &nbsp;<%=zysx%>
                            </td>
                        </tr>
                        <tr style="width: 100%; height: <%=cjg%>%;">
                            <td class="xftd" style="text-align: center; width: 10%;">
                                裁<br />
                                剪<br />
                                要<br />
                                求
                            </td>
                            <td class="xftd" style="text-align: left; width: 90%;">
                                &nbsp;
                                <%= cj%>
                            </td>
                        </tr>
                        <tr style="width: 100%; height: <%=yzyxg%>%;">
                            <td class="xftd" style="text-align: center; width: 10%;border-bottom:none;">
                                用<br />
                                针<br />
                                用<br />
                                线
                            </td>
                            <td class="xftd" style="text-align: left; width: 90%;border-bottom:none;">
                                &nbsp;
                                <%= yzyx%>
                            </td>
                        </tr>
                    </table>
                </div>
            </div>
            <!--缝制要求-->
            <div id="xffz" style="width: 100%; height: <%=fzyqg%>%;">
                <table style="width: 100%; height: 100%;" border="0" cellspacing="0">
                    <tr style="width: 100%; height: 100%;">
                        <td class="xftd" style="text-align: center; width: 2%;">
                            缝<br />
                            制<br />
                            要<br />
                            求
                        </td>
                        <td class="xftd" style="text-align: left; font-size: 15px; width: 49%; height: 100%;">
                            <%If fzyq <> "" Then
                            h = InStr(fzyq, "9.")

                            End If %>
                            &nbsp; <%=IIf(h > 0, Mid(fzyq, 1, 511), "")  %>

                        </td>
                        <td class="xftd" style="text-align: left; font-size: 15px; width: 49%; height: 100%;
                            border-right-width: 1px;">
                            &nbsp;<%=IIf(h > 0, Mid(fzyq, 512), "")%>

                        </td>
                    </tr>
                </table>
            </div>
        </div>
        <div style="page-break-after: always;">
        </div>
    </div>
    <!--西服制造单2号-->
    <div id="xfzzd2" style="width: 1532px; height: 980px;">
        <div id="xftop3" style="height: 96px;">
            <table border="0" class="table" style="height: 96px; ">
                <thead>
                    <tr  style="font-size: 32px; text-align: center; font-family: 粗体;">
                        <td colspan="4" class="bt" style="border-left:0px;">利郎产品制造单（二）
                        </td>
                    </tr>
                </thead>
                <tbody>
                      <tr>
                    <td class="col4" style="text-align: left; width: 25%; ">
                        &nbsp;产品名称：<%= splbmc%>
                    </td>
                    <td class="col4" style="text-align: left; width: 25%;">
                        &nbsp;样衣号：<%= yphh%>
                    </td>
                    <td class="col4" style="text-align: left; width: 25%;  ">
                        &nbsp;货号：<%= sphh%>
                    </td>
                    <td class="col4" style="text-align: left; width: 25%; border-right:1px; ">
                        &nbsp;制表日期：<%= zdrq%>
                    </td>
                </tr>
                     <tr>
                    <td colspan="4" class="col4" style="text-align: center; width: 100%;border-right:1px; ">
                        成&nbsp;&nbsp;衣&nbsp;&nbsp;规&nbsp;&nbsp;格
                    </td>
                </tr>
                </tbody>
            </table>
           <%-- <table style="width: 100%; height: 32px; font-size: 14pt; text-align: left;" class="ggcss">
                <tr>
                    <td class="col4" style="text-align: left; width: 25%; border-bottom-width: 0px; border-bottom-color: white;">
                        &nbsp;产品名称：<%= splbmc%>
                    </td>
                    <td class="col4" style="text-align: left; width: 25%; border-bottom-width: 0px; border-bottom-color: white;">
                        &nbsp;样衣号：<%= yphh%>
                    </td>
                    <td class="col4" style="text-align: left; width: 25%; border-bottom-width: 0px; border-bottom-color: white;">
                        &nbsp;货号：<%= sphh%>
                    </td>
                    <td class="col4" style="text-align: left; width: 25%; border-bottom-width: 0px; border-bottom-color: white;">
                        &nbsp;制表日期：<%= zdrq%>
                    </td>
                </tr>
            </table>
            <table style="width: 100%; height: 32px; font-size: 16pt; font-family: 粗体; text-align: center;
                border-top-width: 0px; border-left-width: 0px; border-top-color: black;" class="ggcss">
                <tr>
                    <td class="col4" style="text-align: center; width: 100%;">
                        成&nbsp;&nbsp;衣&nbsp;&nbsp;规&nbsp;&nbsp;格
                    </td>
                </tr>
            </table>--%>
        </div>
        <div style="width: 1530px; height: 850px;margin-top:5px;">
            <!--上侧栏目-->
            <div style="width: 100%; height: <%=ggbg%>%; border: 0px solid #000; border-bottom-width: 0px;
                border-top-width: 0px;">
                <!--规格表-->
                <div style="width: 1530px; height: 99.99%; margin-top: 1px;border: 1px solid #000;">
                    <%
                    str_sql = "  select top 3 a.ypbh yphh, a.zlmxid, cc.id As ggid from yf_t_cpkfzlb a  "
                    str_sql += " inner join (select ypkh from yf_t_cpkfzlb where ypbh='" + yphh + "') b on a.ypkh=b.ypkh "
                    str_sql += " INNER JOIN yf_T_ytfab cc On a.ypbh = cc.dm + cc.mc + isnull(cc.kfbx,'') group by a.ypbh, a.zlmxid, cc.id  "
                    ' Response.Write(str_sql)
                    'Response.End()
                    zlds = lbdll.CreateDataSet(myconn, str_sql)
                    zldt = zlds.Tables(0)
                    Dim hs As String
                    hs = zlds.Tables(0).Rows.Count
                    Dim t, l, m As Integer
                    l = 0
                    m = 2

                    For t = 0 To hs - 1
                    dr = zldt.Rows(0)
                    yphh = dr.Item("yphh").ToString()
                    zlmxid = dr.Item("zlmxid").ToString()
                    ggid = dr.Item("ggid").ToString()
                    %>
                    <div style="float: left; width: <%=100.00/hs%>%; height: 100%; ">
                        <%
                        sql = " declare @cmzd nvarchar(2000);declare @sql nvarchar(2000); "
                        sql += "  select @cmzd=isnull((select ',sum(case when a.dm='''+cmdm+''' then a.sz else 0 end) '+cmdm  "
                        sql += "  from yx_t_cmzh where tml=( select top 1 lb.tml from yf_t_cpkfzlb a "
                        sql += "  inner join yf_t_cpkfsjtg bb on a.zlmxid=bb.zlmxid and bb.tplx='sjtg' "
                        sql += "  inner join yf_t_cpkfjh_ghs b on a.id=b.id and a.mxid=b.mxid  "
                        sql += "  inner join yf_t_cpkfjh c on b.id=c.id  "
                        sql += "  inner join yx_T_splb lb on c.splbid=lb.id where a.zlmxid=" + zlmxid
                        sql += " ) for xml path('')),'') "
                        sql += " select @sql = ' select a.mc '+@cmzd+',max(a.gc) gc from yf_T_ytfab b "
                        sql += " inner join yf_T_ytfamxb a on b.id=a.id where b.id=" + ggid + " and b.dm+b.mc+isnull(b.kfbx,'''')=''" + yphh + "'' and b.lx=''jsggb'' group by a.mc order by min(a.mxid);' "
                        sql += " exec (@sql) "
                        'Response.Write(sql)
                        'Response.End()
                        xfds = lbdll.CreateDataSet(myconn, sql)
                        xfjls = xfds.Tables(0).Rows.Count '行数

                        Dim xfcol_jls, a, k As Integer
                        a = 0
                        xfcol_jls = xfds.Tables(0).Columns.Count '列数
                        'Response.Write(xfjls)
                        ' Response.Write(xfcol_jls)
                        ' Response.End()
                        Dim j As Integer = 0

                        If (xfjls + 1) * 5 > 100 Then
                        height = 100
                        Else
                        height = (xfjls + 1) * 5
                        End If


                        %>

                        <table style="height: <%=height%>%; width: 100%;" class="ggcss">
                            <%
                            sql = " select cmdm,cm as cmmc from yx_t_cmzh where tml=( "
                            sql += "   select top 1 lb.tml from  yf_t_cpkfjh a inner join yf_t_cpkfzlb b on a.id=b.id "
                            sql += "   inner join yf_t_cpkfsjtg c on b.zlmxid=c.zlmxid  inner join YX_T_splb lb on a.splbid=lb.id and b.zlmxid=" + zlmxid + " "
                            sql += " ) and cmdm<>'' "
                            ds = lbdll.CreateDataSet(myconn, sql)
                            jls = ds.Tables(0).Rows.Count
                            Dim i As Integer = 0

                            %>
                            <tr style="height:4.9%;">
                                <%If t = 0 Then%>
                                <td style="width: <%=100.00/(jls-1)%>%; height: 4.9%; text-align: center;">
                                    &nbsp;&nbsp;
                                </td>
                                <%End If%>
                                <%
                                For i = 0 To jls - 1
                                %>
                                <td style="width: <%=100.00/(jls+2)%>%; height: 4.9%;font-size: 15px; text-align: center;">
                                    <%=ds.Tables(0).Rows(i).Item("cmmc").ToString() %>
                                </td>
                                <%
                                Next
                                %>
                                <%If t = hs - 1 Then%>
                                <td style="text-align: center;font-size: 11px; height: 4.9%; width: <%=100.00/(jls+2)%>%;">
                                    允许误差
                                </td>
                                <%End If%>
                            </tr>


                            <%
                            For k = 0 To xfjls - 1
                            %>

                            <tr style="height: 4.9%; ">
                                <%

                                If t <> 0 Then
                                l = 1
                                End If
                                If t = hs - 1 Then
                                m = 1
                                a = 1

                                End If

                                For j = l To xfcol_jls - m
                                Dim font As Integer
                                font = 13
                                If j = 0 And i = xfjls - 1 Then
                                font = 11
                                Else font = 13
                                End If
                                'If t = hs - 1 And j - l = xfcol_jls - m Then
                                '    font = 11
                                'End If

                                %>
                                <td style="height:4.9%;width:<%=100.00/(xfjls-1)%>%;text-align: center;font-size:<%=font%>px; border-right-width: <%=a%>px;">
                                    &nbsp;

                                    <%=String.Format("{0:0.##}", xfds.Tables(0).Rows(k).Item(j)) %>
                                    <%--<%=IIf(xfds.Tables(0).Rows(i).Item(j).ToString() = "0.00", "", xfds.Tables(0).Rows(i).Item(j).ToString()))%>--%>
                                </td>

                                <% Next%>
                            </tr>
                            <% Next%>
                        </table>
                    </div>
                    <%Next%>
                </div>
            </div>
            <!--下侧栏目-->
            <div style="width: 100%; height: <%=all-ggbg%>%; border: 1px solid #000; margin-top: 0px;
                 border-top-width: 0px; border-bottom-width: 0px;">
                <div style="width: 100%; height: 90%; float: left;">
                    <div style="width: 50%; height: 100%; float: left;">
                        <table style="height: 100%; width:100%;table-layout: fixed; border-bottom-width: 0px;" class="ggcss">
                            <tr>
                                <td style="text-align: center; width: 4%; height:100%;border-bottom-width: 1px;">
                                    后<br />
                                    整<br />
                                    要<br />
                                    求
                                </td>
                                <td style="text-align: left; width: 96%;height:100%; border-bottom-width: 1px; border-right-width: 0px;">
                                    <%= hzyq%>
                                </td>
                            </tr>
                        </table>
                    </div>
                    <div style="width: 50%; height: 100%; float: left;">
                        <%Dim p As Integer
                        p = 851 * (all - ggbg) * 9 / 1000.00 %>
                        <table style="table-layout: fixed; height: 100%;width:100%;" class="ggcss">
                            <tr id="">
                                <td style="text-align: center; width: 4%;height:100%;">
                                    包<br />
                                    装<br />
                                    图<br />
                                    示
                                </td>
                                <td style="width: 96%;height:100%; padding: 0; overflow: hidden;">
                                    <div style="width:100%;height:100%;text-align:center;">

                                        <img alt="包装图" src="ScaleImage.aspx?MyPath=<%=bzt %>&Height=<%=p %>&Width=765&scale=0" />

                                    </div>
                                </td>
                            </tr>
                        </table>
                    </div>

                </div>
                <div style="width: 100%; height: 10%; border: 1px solid #000; border-right-width: 0px;
                    border-bottom-width: 0px;float:left;">
                    <p style="margin-top:4px;">
                        &nbsp;
                        注：工厂在产前工作中：样衣/样板/工艺单/配料/排版如有不符之处，请及时反馈至技术部解决，联系电话：0595-85618797/7001
                    </p>
                </div>
            </div>
        </div>
        <!--页脚-->
        <div style="height: 32px; width: 1532px;">
            <table style="width: 100%; height: 1cm; font-size: 20px; font-family: 粗体; text-align: left;"
                   class="ggcss">
                <tr style="width: 100%;">
                    <td style="text-align: left;width:33.33%;">
                        制表：<%=zdr %>
                    </td>
                    <td style="text-align: left;width:33.33%;">
                        审核：
                    </td>
                    <td style="text-align: left;width:33.33%;">
                        审批：
                    </td>
                </tr>
            </table>
        </div>
    </div>
    <%End If%>
</body>
</html>