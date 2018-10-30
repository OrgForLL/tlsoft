<%@ Page Language="VB" %>
<%@ Import Namespace="System.IO"%>
<%@ Import Namespace="System.Data"%>
<%@ Import Namespace="System.Collections.Generic" %>
<%@ Import Namespace="System.Data.SqlClient"%>
<%@ Import Namespace="nrWebClass" %>
<!DOCTYPE HTML>
<html>
<head>
 <title>移动办公</title>
 <meta name="viewport" content="width=device-width,initial-scale=1" >  
 <link rel="stylesheet" href="css/jquery.mobile-1.4.3.min.css">
 <script src="js/jquery-1.11.1.min.js"></script>
 <script src="js/jquery.mobile-1.4.3.min.js"></script>
<style>   
    body
    {
	    font-family: 'Helvetica Neue',Helvetica,'microsoft yahei',Arial,sans-serif
    }    
    .MenuGrid
    {
      color:#555;
      font-size:0.75rem;
      background-color: #eeeeee;
      height: 50px;
      font-weight: bold;
      text-align: center;
      line-height:50px;
      border: 0px solid black;
      margin:2px;
    }
    a {
	    text-decoration: none;
	    background: 0 0;
	    -webkit-tap-highlight-color: transparent
    }
</style>
</head> 
<body>
   
    <div data-role="page" id="mainPage">
      <script>  $("#mainPage").live("pagecreate", function() { }); </script> 
      <input type="hidden" id="menuLb" value="<%=menuLb %>" />
      <input type="hidden" id="menuMb" value="<%=menuMb %>" />
      <div data-role="header" data-theme="b" id="mHeader">
        <h1   style="visibility:hidden">车间刷码</h1>
        <!--<a href="mShowTZ.aspx" target="_self" data-role="button"  data-corners="true" data-transition="slide">套帐</a>-->
      </div>        

      <div data-role="content" id="mMenu">  
      <%=bHtml%>        
      </div> 
      
    </div>
</body>
</html>
<script language="vb" runat="server">
    Dim menuLb, menuMb, MySql, bHtml, errinfo As String
    'Dim MyData As New kClass.BBSJ.mMyData()
    Dim OAConnStr As String = clsConfig.GetConfigValue("OAConnStr")
    Sub page_load(ByVal S As Object, ByVal E As EventArgs)
        '授权判断
        Try
            If clsWXHelper.CheckQYUserAuth(True) <> True Then
                Response.Write("授权失败...")
                Response.End()
            End If
        Catch ex As Exception
            Response.Write("授权异常...")
            Response.End()
        Finally            
        End Try
        
        'If Not IsPostBack Then
        menuLb = Trim(Request.Params("menuLb"))
        menuMb = Trim(Request.Params("menuMb"))
        'menuLb = "Z"
        'menuMb = "yycj"
        'End If
           
        '获取数据
        getData(menuLb, menuMb)
    End Sub
    '获取数据
    Sub getData(ByVal menulb As String, ByVal menumb As String)
        bHtml = ""
        Dim paramters As List(Of SqlParameter) = New List(Of SqlParameter)
        paramters.Add(New SqlParameter("@menulb", menulb))
        paramters.Add(New SqlParameter("@menumb", menumb))
        MySql = "declare @menuid int;select @menuid=a.id from t_menu a inner join t_menu b on a.ssid=b.id and b.m_asp=@menulb where a.m_dm like 'Z%' and a.jb=1 ;"
        MySql += " select b.id,b.m_name,b.m_asp,b.m_bz from t_menu a inner join t_menu b on a.id=b.ssid where a.ssid=@menuid and b.m_pass=@menumb and b.m_onoff=1;"
        
        Using dal As New LiLanzDALForXLM(OAConnStr)
            Dim dt As DataTable
            errinfo = dal.ExecuteQuerySecurity(MySql, paramters, dt)
            If String.IsNullOrEmpty(errinfo) Then
                bHtml = getHtml(dt)
            Else
                bHtml = "该菜单体系未启用手机功能！"
            End If
            dt.Dispose()            
        End Using
    End Sub
                     
    '解析数据生成html字符串
    Function getHtml(ByVal dt As DataTable) As String
        '获取模块菜单
        Dim tColor As String = "#ffffff ,#ffffff,#ffffff,#ffffff,#ffffff,#ffffff"
        Dim mrColor As String
        Dim i As Integer = 0
        Dim bHtml As String = ""
        For Each MyDr As DataRow In dt.Rows
            i += 1
            mrColor = tColor.Split(",")(i Mod 6)
            If Len(Trim(MyDr("m_bz").ToString())) > 0 Then
                mrColor = Trim(MyDr("m_bz").ToString())
            End If
            'url路径累加menuid,标题
            Dim m_asp As String = MyDr("m_asp").ToString()
            Dim tlbt As String = MyDr("m_name").ToString()
            If Left(m_asp, 4) = "http" Then
                '支持utf-8编码规则
                If (m_asp.IndexOf("?") > -1) Then
                    m_asp += "&"
                Else
                    m_asp += "?"
                End If
                m_asp += "menuid=" + MyDr("id").ToString()
            ElseIf m_asp.IndexOf("?") = -1 And Len(m_asp) > 0 Then
                m_asp += "?menuid=" + MyDr("id").ToString()
            ElseIf Len(m_asp) > 0 Then
                m_asp += "&menuid=" + MyDr("id").ToString()
            End If
 
            If i Mod 2 = 1 Then
                bHtml += "<div class=""ui-block-a""><a href=""" + m_asp + """  target=""_self""><div class=""MenuGrid"">" + MyDr("m_name").ToString() + "</div></a></div>"
            Else
                bHtml += "<div class=""ui-block-b""><a href=""" + m_asp + """  target=""_self""><div class=""MenuGrid"">" + MyDr("m_name").ToString() + "</div></a></div>"
            End If
        Next
        bHtml = "<div class=""ui-grid-a"">" + bHtml + "</div>"
        Return bHtml
    End Function
                
        
</script>