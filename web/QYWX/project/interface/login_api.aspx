<%@ Page Language="C#" %>
<%@ Import Namespace="nrWebClass" %>
<%@ Import Namespace="System.Data" %>
<%@ Import Namespace="System.Data.SqlClient" %>
<%@ Import Namespace="System.Collections.Generic" %>


<script runat="server">
    //获取连接属性
    string dbConn = clsConfig.GetConfigValue("OAConnStr");
    DataTable dt, dt_rt;
    protected void Page_Load(object sender, EventArgs e)
    {
        Request.ContentEncoding = System.Text.Encoding.UTF8;
        Response.ContentEncoding = System.Text.Encoding.UTF8;
        // clsJsonHelper.CreateJsonHelper(string);
        // string username = "zhengsf";
        //string password = "123456";
        string username = Request.Params["username"];
        string password = Request.Params["password"];


        if (string.IsNullOrEmpty(username) || string.IsNullOrEmpty(password))
        {
            clsSharedHelper.WriteErrorInfo("缺少参数！");
            return;
        } 
        password = nrWebClass.Security.String2MD5(password); 
        
        //数据库连接    
        List<SqlParameter> param = new List<SqlParameter>();
        using (LiLanzDALForXLM dal = new LiLanzDALForXLM(dbConn)){
            string Str_sql = @"SELECT TOP 1 id,cname from t_user WHERE [name]= @name and [pass]=@pass";
            param.Add(new SqlParameter("@name", username));
            param.Add(new SqlParameter("@pass", password));
            string errInfo = dal.ExecuteQuerySecurity(Str_sql, param, out dt);
            if (errInfo != "")
            {
                clsLocalLoger.WriteError("【账号密码验证】执行失败！错误：" + errInfo);
                clsSharedHelper.WriteErrorInfo("系统繁忙！请稍后重试！");
                return;              
            }
            param.Clear();
            if (dt.Rows.Count == 0)
            {
                clsSharedHelper.WriteErrorInfo("账号或密码错误！");
                return;                              
            }  
            string rt = JsonHelp.dataset2json(dt);
            clsSharedHelper.DisponseDataTable(ref dt);
            clsSharedHelper.WriteInfo(rt); 
            
        } 
    } 
    </script>
