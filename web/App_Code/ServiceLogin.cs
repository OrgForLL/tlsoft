using System;
using System.Web.Services;
using nrWebClass;
using System.Text;
using System.Configuration;
using System.Data;
using System.Data.SqlClient;
/// <summary>
/// ServiceLogin 的摘要说明
/// </summary>
[WebService(Namespace = "http://tempuri.org/")]
[WebServiceBinding(ConformsTo = WsiProfiles.BasicProfile1_1)]
public class ServiceLogin : System.Web.Services.WebService
{


    [WebMethod]
    public string HelloWorld()
    {
        return "Hello World";
    }
    [WebMethod(EnableSession = true)]
    public string LoginIn(string name, string pwd)
    {
        //return "123";
        web10.Service1 s = new web10.Service1();
        return s.LoginIn(name, pwd);        

    }
    [WebMethod]
    public string Customers(int userid)
    {
        web10.Service1 s = new web10.Service1();
        return s.Customers(userid);
    }
    [WebMethod]
    public string Stocks(string tzid)
    {
        web10.Service1 s = new web10.Service1();
        return s.Stocks(tzid);
         
    }
    [WebMethod]
    public string billUpload(string xml)
    {
        web10.Service1 s = new web10.Service1();
        return s.billUpload(xml);
         
    }
    /// <summary>
    /// 会员信息
    /// </summary>
    /// <param name="CardSn"></param>
    /// <returns></returns>
    [WebMethod]
    public string PersonerInfo(string CardSn)
    {
        web10.Service1 s = new web10.Service1();
        return s.PersonerInfo(CardSn);
    }
    /// <summary>
    /// 
    /// </summary>
    /// <param name="CardSn"></param>
    /// <returns></returns>
    [WebMethod]
    public string PersonerInfoNoEncrypt(string CardSn)
    {
        web10.Service1 s = new web10.Service1();
        return s.PersonerInfoNoEncrypt(CardSn);
    }

    /// <summary>
    /// 修改密码
    /// </summary>
    /// <param name="id"></param>
    /// <param name="opwd"></param>
    /// <param name="npwd"></param>
    /// <returns></returns>
    [WebMethod]
    public string ChangePassword(int id, string opwd, string npwd)
    {
        web10.Service1 s = new web10.Service1();
        return s.ChangePassword(id,opwd,npwd);
    }
     


}
