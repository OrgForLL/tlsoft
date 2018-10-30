<%@ Page Language="C#" %>
<%@ Import Namespace="System.Data" %>
<%@ Import Namespace="System.IO" %>
<%@ Import Namespace="nrWebClass" %>
<%@ Import Namespace="System.Drawing" %>
<%@ Import Namespace="System.Data.SqlClient" %>
<%@ Import Namespace="System.Collections.Generic" %>



<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<script runat="server">
    public string picvip = "";
	public string cid="";
    public string ctrl = "";
    public string openid = "";
    string DBConStr_tlsoft = clsConfig.GetConfigValue("OAConnStr");
    string DBConStr;
    protected void Page_Load(object sender, EventArgs e)
    {
        DBConStr = ConfigurationManager.ConnectionStrings["Conn_4"].ConnectionString;



        try
        {
            cid = Convert.ToString(Request.Params["cid"]); // Request.QueryString["cid"].ToString();
            ctrl = Convert.ToString(Request.Params["ctrl"]);// Request.QueryString["ctrl"].ToString();
            openid = Convert.ToString(Request.Params["openid"]);
            //clsSharedHelper.WriteInfo(ctrl);            
        }
        catch(Exception ex)
        {
            clsSharedHelper.WriteErrorInfo(ex.Message);
        }
        //clsSharedHelper.WriteInfo(cid);
        string result = "";
        switch (ctrl){
            case "SaveInfo": 
                string name = Convert.ToString(Request.Params["name"]);
                string xb = Convert.ToString(Request.Params["xb"]);
                string phone = Convert.ToString(Request.Params["phone"]);
                DateTime birthday = Convert.ToDateTime(Request.Params["birthday"]);
                result = saveInfo(name,xb,  phone, birthday).ToString();
                Response.Write(result);
                Response.End();
                break;    

        }
      
    }

    public string saveInfo(string name, string xb, string phone, DateTime birthday){
        String result = "";
        String errInfo ="";
        List<SqlParameter> para = new List<SqlParameter>();
        string mysql = @"  DECLARE @NewVsbID INT, @VipID INT,@CreateName VARCHAR(50);
                            insert into yx_t_vipkh(khid,xm,kh,klb,yddh,csrq,isjf) values(0,@name,@phone,20,@phone,@birthday,0)
                            set @VipID = SCOPE_IDENTITY();  
                            set @CreateName='顾客' + CONVERT(VARCHAR(20),@vipid) + '自助'; 
                            INSERT INTO wx_t_VipSalerBind (VipID,SalerID,CreateID,CreateName) VALUES (@VipID,@sid,@sid,@CreateName) ;
                            SELECT @NewVsbID = SCOPE_IDENTITY();  
                            INSERT INTO wx_t_VipSalerHistory(BindID,VipID,SalerID,CreateID,CreateName,BeginType) 
                            VALUES (@NewVsbID,@VipID,@sid,@sid,@CreateName,0)
                            update wx_t_vipBinging set vipID=@VipID where openid=@openid ";


        using (LiLanzDALForXLM dal = new LiLanzDALForXLM(DBConStr_tlsoft))
        {
            para.Add(new SqlParameter("@name", name));
            para.Add(new SqlParameter("@phone", phone));
            para.Add(new SqlParameter("@birthday", birthday));
            para.Add(new SqlParameter("@sid", cid));
            para.Add(new SqlParameter("@openid", openid));
            errInfo = dal.ExecuteNonQuerySecurity(mysql, para);
            para = null;
            mysql = null;


            if (errInfo != "")
            {
                result = errInfo;
            }
            else
            {
                result = clsNetExecute.Successed + "|保存成功！";
            }
        }

        return result;
    }

</script>
<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <title></title>
</head>
<body>
    <form id="form1" runat="server">
    <div>
    
    </div>
    </form>
</body>
</html>
