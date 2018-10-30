<%@ Page Language="C#" %>
<%@ Import Namespace="nrWebClass" %>
<%@ Import Namespace="System.Data" %>
<%@ Import Namespace="System.Data.SqlClient" %>
<%@ Import Namespace="System.Collections.Generic" %>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">

<script runat="server">

    protected void Page_Load(object sender, EventArgs e)
    {
        if (Request.QueryString["id"] != null)
            Data_Load();
    }
    private void Data_Load()
    {
        /*
        LiLanzDAL dal = new LiLanzDAL();
        {		
		
            using (IDataReader reader = dal.ExecuteReader(exeSQL, CommandType.Text, listSqlParameter))
            {
                if (reader.Read())
                {
                    LabelJobName.Text = reader["PositionName"].ToString();
                    LabelAddr.Text = reader["Address"].ToString();
                    LabelEx.Text = reader["WorkExperience"].ToString();
                    LabelRs.Text = HtmlReplace(reader["JobResponsibilities"].ToString());
                    LabelRq.Text = HtmlReplace(reader["JobRequirements"].ToString());
                }
            } 
			
			*/
        string OAConnStr = clsConfig.GetConfigValue("OAConnStr");
        using (LiLanzDALForXLM dal = new LiLanzDALForXLM(OAConnStr))
        {
            string exeSQL = "SELECT TOP 1 JobResponsibilities,PositionName,JobRequirements,Address,WorkExperience FROM rs_t_Position WHERE PositionID=@id";
            List<SqlParameter> listSqlParameter = new List<SqlParameter>();
            listSqlParameter.Add(new SqlParameter("@id",Request.QueryString["id"].ToString()));

            string errInfo = "";
            DataTable dtScalar;
            errInfo = dal.ExecuteQuerySecurity(exeSQL, listSqlParameter, out dtScalar);
            if (errInfo == "" && dtScalar.Rows.Count > 0){
                DataRow reader = dtScalar.Rows[0];
                LabelJobName.Text = reader["PositionName"].ToString();
                LabelAddr.Text = reader["Address"].ToString();
                if (reader["WorkExperience"].ToString() == "0") LabelEx.Text = "不限";
                else LabelEx.Text = reader["WorkExperience"].ToString() + "年以上";
                LabelRs.Text = HtmlReplace(reader["JobResponsibilities"].ToString());
                LabelRq.Text = HtmlReplace(reader["JobRequirements"].ToString());

                dtScalar.Clear(); dtScalar.Dispose();
            }else{
                clsSharedHelper.WriteInfo(errInfo);
            }
        }
    }
    private string HtmlReplace(string s)
    {
        s = s.Replace("\n", "<br/>");
        return s;
    }
</script>

<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <title>岗位要求</title>
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <style>
	.detailContent{
		margin-top:20px;
	}
	.detailTitle{
		margin-bottom:10px;
	}
	</style>
</head>
<body>
<div data-role="page" id="page1">
	<div data-role="header" >
		<h1>岗位要求</h1>
		<a href="JobList.aspx" data-icon="home" data-iconpos="notext" data-ajax="false">返回</a>
	</div>
    <div data-role="content">
        <div><h4><asp:Label ID="LabelJobName" runat="server" Text=""></asp:Label></h4></div>
        <div style="margin-top:20px">工作地点： <asp:Label ID="LabelAddr" runat="server" Text=""></asp:Label> | 工作经验：<asp:Label ID="LabelEx" runat="server" Text=""></asp:Label></div>
        <div class="detailContent">
            <div class="detailTitle">岗位职责：</div>
            <asp:Label ID="LabelRs" runat="server" Text=""></asp:Label>
        </div>

        <div class="detailContent">
            <div class="detailTitle">任职资格：</div>
            <asp:Label ID="LabelRq" runat="server" Text=""></asp:Label>
        </div>
    </div>
</div>
</body>
</html>
