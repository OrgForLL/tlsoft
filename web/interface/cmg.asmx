<%@ WebService Language="C#" Class="WebService1" %>

using System;
using System.Collections;
using System.ComponentModel;
using System.Data;
using System.Diagnostics;
using System.Web;
using System.Web.Services;
using nrWebClass;
using LiLanzModel;
using System.Xml;
using System.Xml.Serialization;
using System.Text;
[WebService(Namespace = "http://tempuri.org/")]
[WebServiceBinding(ConformsTo = WsiProfiles.BasicProfile1_1)]
//若要允许使用 ASP.NET AJAX 从脚本中调用此 Web 服务，请取消对下行的注释。 
// [System.Web.Script.Services.ScriptService]
public class WebService1 : System.Web.Services.WebService
{
    public WebService1()
    {
        //
        // TODO: 添加任何需要的构造函数代码
        //
    }

    // WEB 服务示例
    // HelloWorld() 服务示例返回字符串“Hello World”。

    [WebMethod]
    public string HelloWorld()
    {
        return "Hello World";
    }

    [WebMethod]
    public string aabcc()
    {
        return "test";
    }
    /// <remarks/>
    [WebMethod]
    [System.Web.Services.Protocols.SoapDocumentMethodAttribute("http://tempuri.org/InvioceList", RequestNamespace="http://tempuri.org/", ResponseNamespace="http://tempuri.org/", Use=System.Web.Services.Description.SoapBindingUse.Literal, ParameterStyle=System.Web.Services.Protocols.SoapParameterStyle.Wrapped)]
    public string InvioceList(System.DateTime dayStart, System.DateTime dayEnd, int companyId, string cat) {
        object[] results = this.Invoke("InvioceList", new object[] {
                        dayStart,
                        dayEnd,
                        companyId,
                        cat});
        return ((string)(results[0]));
    }
    protected object[] Invoke(string methodName, object[] parameters){
        using (LiLanzDALForXLM dal = new LiLanzDALForXLM("server=192.168.35.10;uid=ABEASD14AD;pwd=+AuDkDew;database=tlsoft"))
        {
            string sql = "select top 1 0 xzbs,a.shr,shbs=case when a.shbs=1 then '已审' else '未审' end,a.id,a.rq,a.djh,(select sum(je) from yx_t_fpxxmxb where id=a.id) as je, ";
            sql += " (select sum(round(je,2)-round(je/1.17,2) ) from yx_t_fpxxmxb where id=a.id) as se,(select sum(round(je/1.17,2)) from yx_t_fpxxmxb where id=a.id) as bhsje,";
            sql += " (select sum(sl) from yx_t_fpxxmxb where id=a.id) as sl,a.zdr,a.kprq,a.fph,a.fpzdr,d.mc as sskh,f.zhmc as khmc,h.dm+'.'+h.mc as fplx ";
            sql += " ,ly.rq as lyrq,ly.djh as lydjh,a.jsrq,a.kdh,a.kdgs,a.qsrq ,a.fpdm,k3.khdm+'.'+k3.khmc k3khmc ,xt.mc as khfl ";
            sql += "  from yx_t_fpxxb a inner join yx_t_khmx d on a.sskh=d.id    inner join zw_t_yhzlb  f on a.khid=f.id ";
            sql += "  left outer join  zw_t_k3khdy k3 on a.k3khid=k3.id         left outer join t_xtdm h on a.fplx=h.dm and h.ssid=7735 ";
            sql += " left join t_xtdm xt on k3.khfl=xt.dm and xt.ssid=8813  left outer join yx_t_hxdjb ly on a.lydjid=ly.id and a.lydjlx=ly.djlx and ly.tzid=1 ";
            sql += "  where a.tzid=1 and a.djbs=1 and a.djlx=137  and a.rq>='2016-09-01'  AND a.rq<dateadd(day,1,'2016-09-21') and a.sskh='7398'  ";
            DataTable dt;
            string errinfo = dal.ExecuteQuery(sql, out dt);
            dt.TableName = "Invioce";
            StringBuilder build = new StringBuilder();

            XmlWriter writer = XmlWriter.Create(build);
            XmlSerializer serializer = new XmlSerializer(typeof(DataTable));
            serializer.Serialize(writer, dt);
            writer.Close();
            string[] r = new string[1];
            r[0] = build.ToString();
            return r;
        }
    }
}
