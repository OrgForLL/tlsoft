<%@ Page Language="VB"%>
<%@ Import Namespace="nrWebClass" %>
<%@ Import Namespace="System.Data" %>
<%@ Import Namespace="System.Data.SqlClient" %>
<script runat="server">

</script>
	<%
		Dim sphh As String = "" 
		Dim mytype As String = "" 
		Dim wym As String = "" 
		Dim htzinfoDs As Data.DataSet
		sphh = Trim(System.Web.HttpUtility.UrlDecode(Request.QueryString("sphh"))).ToString()
		mytype = Trim(Request.QueryString("mytype"))' getwym:接收加密后的唯一码，save:保存数据
	
		If sphh.Length = 0 Then
			Response.Write("未传入信息")
			Response.End()
		End If
		
		Dim MySql As String = ""
		Dim OAConnStr As String = clsConfig.GetConfigValue("OAConnStr")
		Dim dal As LiLanzDALForXLM = New LiLanzDALForXLM(OAConnStr)
		
		if  mytype = "getwym" then 
			MySql = " select dbo.f_DBPwd('" + sphh + "') AS wym "
			dal.ExecuteQuery(MySql, htzinfoDs)
			Dim htzinfo As DataTable = htzinfoDs.Tables(0).Copy()
			wym = htzinfo.Rows(0)("wym").ToString()
		else if mytype = "save" then
			dim zrgs as string 
	        Dim zldj As String
	        Dim qxnr As String
			Dim sphhs() As String 
			sphhs = sphh.split(",")
			wym = sphhs(0)
			zrgs = sphhs(1)
	        zldj = sphhs(2)
	        qxnr = sphhs(3)
	        MySql = "declare @tsxx varchar(50);"
	        MySql += "  if not exists(select spid from yf_t_wqbhgpd where spid='" + wym + "') "
			MySql += " begin "
	        MySql += "   insert into yf_t_wqbhgpd(spid,zrgs,zldj,qxnr,zdr,zdrq) values ('" + wym + "','" + zrgs + "','" + zldj + "','" + qxnr + "','',getdate()); "
	        MySql += " select @tsxx='ISuccessed';"
			MySql += " end "
			MySql += " else "
			MySql += " begin"
	        MySql += "   update yf_t_wqbhgpd set zrgs='" + zrgs + "',zldj='" + zldj + "',zdrq=getdate() where spid='" + wym + "'; "
	        MySql += " select @tsxx='USuccessed';"
			MySql += " end "
	        MySql += " select @tsxx as value "
			dal.ExecuteQuery(MySql, htzinfoDs)
			Dim upinfo As DataTable = htzinfoDs.Tables(0)
			if upinfo.Rows(0)("value").ToString() = "ISuccessed" or upinfo.Rows(0)("value").ToString() = "USuccessed" then 
	            wym = upinfo.Rows(0)("value").ToString()
			else 
				wym = "Error"
			end if 
			'wym = "Successed"
		end if 

		Response.Write(wym)
	%>
	
	
	
	
	
	
	