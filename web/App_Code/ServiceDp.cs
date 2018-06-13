using System;
using System.Data;
using System.Data.SqlClient;
using System.Web;
using System.Web.Services;
using System.Web.Services.Protocols;

[WebService(Namespace = "http://tempuri.org/")]
[WebServiceBinding(ConformsTo = WsiProfiles.BasicProfile1_1)]
public class ServiceDp : System.Web.Services.WebService
{
    TLBaseData._MyData sqlHelp = new TLBaseData._MyData();
    public ServiceDp()
    {
        //如果使用设计的组件，请取消注释以下行 
        //InitializeComponent(); 
    }

    [WebMethod]
    public string HelloWorld() {
        return "Hello World";
    }
    [WebMethod]
    public string InsertOrder(string Cname, string IdCard, string addr, string tel, int num, string Checker, string Info, bool isGet, string companyName)
    {
        string SqlComm = "INSERT INTO yx_t_xsdp";
        SqlComm += " (dpxm,sfz,dz,dh,sl,djrq,djr,bz,companyName) values ('{0}','{1}','{2}','{3}',{4}, getdate(),'{5}','{6}','{7}');";
        SqlComm += "; declare @id int; set @id = @@IDENTITY;";
        SqlComm = string.Format(SqlComm, Cname, IdCard, addr, tel, num, Checker, Info, companyName);
        if (isGet) 
        {
            SqlComm += " update yx_t_xsdp set fp=1,fpsj=getdate() where id=@id;";
        }
        sqlHelp.MyDataTrans(sqlHelp.GetConn(), SqlComm);
        return "1";
    }
    [WebMethod]
    public DataSet GetOrders(string Cname, string IdCard, String tel, String CompanyName)
    {
        SqlConnection conn = (SqlConnection)sqlHelp.GetConn();
        String SelcComm = "select top 20 id,dpxm,sfz,dz,dh,sl,djrq,djr,isnull(bz,'') bz, fp, fpsj,companyName from yx_t_xsdp where (1=1) ";
        if (Cname.Length > 0) SelcComm += " and dpxm like '" +Cname + "%'";
        if (IdCard.Length > 0) SelcComm += " and sfz like '" + IdCard + "%'";
        if (tel.Length > 0) SelcComm += " and dh like '" + tel + "%'";
        if (CompanyName.Length > 0) SelcComm += " and companyName like '%" + CompanyName + "%'";

        SelcComm += " order by id desc;";
        SqlDataAdapter da = new SqlDataAdapter(SelcComm, conn);
        DataSet ds = new DataSet();
        da.Fill(ds);
        return ds;
    }
    [WebMethod]
    public bool CheckPoint(string Ids)
    {
        string UpdateComm = "update yx_t_xsdp set  fp=1,fpsj=getdate() where id in (" + Ids + ")";
        sqlHelp.MyDataTrans(sqlHelp.GetConn(), UpdateComm);
        return true;
    }
    [WebMethod]
    public string UserLogin(string Name, string pw)
    {
        SqlConnection conn = (SqlConnection) sqlHelp.GetConn();
        if (conn.State == ConnectionState.Open) conn.Close();
        conn.Open();
        SqlDataReader dr = (SqlDataReader)sqlHelp.MyDataRead(conn, string.Format("select cname from t_user where name='{0}' and pass='{1}'", Name, sqlHelp.GetMD5Code(pw).ToString()));
        string r = "";
        if (dr.Read())
        {
            r = dr[0].ToString();
        }
        conn.Close();
        return r;
    }
    [WebMethod]
    public string DelOrder(string id)
    {
        string SqlComm = "delete from yx_t_xsdp where id={0};";
        SqlComm = string.Format(SqlComm, id);
        sqlHelp.MyDataTrans(sqlHelp.GetConn(), SqlComm);
        return "1";
    }
    [WebMethod]
    public bool UnCheckPoint(string Ids)
    {
        string UpdateComm = "update yx_t_xsdp set  fp=0,fpsj=''  where id in (" + Ids + ")";
        sqlHelp.MyDataTrans(sqlHelp.GetConn(), UpdateComm);
        return true;
    }
}

