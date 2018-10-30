<%@ WebHandler Language="C#" Class="PDAScan" %>

using System;
using System.Web;
using System.Xml.Serialization;
using System.IO;
using System.Xml;
using System.Text;
using System.Data;
using nrWebClass;
using System.Collections.Generic;
using System.Data.SqlClient;

public class PDAScan : IHttpHandler
{
    public void ProcessRequest(HttpContext context)
    {

        String ctrl = Convert.ToString(context.Request.Params["ctrl"]);
        String errInfo = "";
        switch (ctrl)
        {
            case "viewMain":
                String tzid = Convert.ToString(context.Request.Params["tzid"]);
                String days = Convert.ToString(context.Request.Params["days"]);
                String djh = Convert.ToString(context.Request.Params["djh"]);
                if (tzid == "" || tzid == null)
                    errInfo = "缺少参数【tzid】！";
                else
                    viewMain(tzid, days, djh);
                break;
            case "viewDetail":
                tzid = Convert.ToString(context.Request.Params["tzid"]);
                String id = Convert.ToString(context.Request.Params["id"]);
                if (id == null || id == "")
                {
                    errInfo = "缺少参数【id】！";
                }
                else
                {
                    viewDetail(tzid,id);
                }
                break;
            case "saveData":
                tzid = Convert.ToString(context.Request.Params["tzid"]);
                String objStr = Convert.ToString(context.Request.Params["objStr"]);

                //clsLoger.WriteLog("0", "PADScan", "", objStr);
                //objStr = HttpUtility.UrlDecode(objStr);
                objStr = base64Decode(objStr);
//                objStr = @"
//<kcdjcmmx>
//  <ckid>1239</ckid>
//  <cmmxTable>
//    <xs:schema id=""NewDataSet"" xmlns="""" xmlns:xs=""http://www.w3.org/2001/XMLSchema"" xmlns:msdata=""urn:schemas-microsoft-com:xml-msdata"">
//      <xs:element name=""NewDataSet"" msdata:IsDataSet=""true"" msdata:MainDataTable=""yx_t_kcdjcmmx"" msdata:UseCurrentLocale=""true"">
//        <xs:complexType>
//          <xs:choice minOccurs=""0"" maxOccurs=""unbounded"">
//            <xs:element name=""yx_t_kcdjcmmx"">
//              <xs:complexType>
//                <xs:attribute name=""mxid"" type=""xs:int"" />
//                <xs:attribute name=""sphh"" type=""xs:string"" />
//                <xs:attribute name=""cmdm"" type=""xs:string"" />
//                <xs:attribute name=""sl0"" type=""xs:decimal"" />
//                <xs:attribute name=""jysl0"" type=""xs:decimal"" />
//                <xs:attribute name=""tml"" type=""xs:string"" />
//              </xs:complexType>
//            </xs:element>
//          </xs:choice>
//        </xs:complexType>
//      </xs:element>
//    </xs:schema>
//    <diffgr:diffgram xmlns:msdata=""urn:schemas-microsoft-com:xml-msdata"" xmlns:diffgr=""urn:schemas-microsoft-com:xml-diffgram-v1"">
//      <DocumentElement>
//        <yx_t_kcdjcmmx diffgr:id=""yx_t_kcdjcmmx1"" msdata:rowOrder=""0"" mxid=""114890125"" sphh=""0DNK0011Y"" cmdm=""cm18"" sl0=""5"" jysl0=""0"" tml=""3"" />
//        <yx_t_kcdjcmmx diffgr:id=""yx_t_kcdjcmmx2"" msdata:rowOrder=""1"" mxid=""114890125"" sphh=""0DNK0011Y"" cmdm=""cm21"" sl0=""3"" jysl0=""0"" tml=""3"" />
//        <yx_t_kcdjcmmx diffgr:id=""yx_t_kcdjcmmx3"" msdata:rowOrder=""2"" mxid=""114890126"" sphh=""0DNK0031Y"" cmdm=""cm18"" sl0=""2"" jysl0=""1"" tml=""3"" />
//        <yx_t_kcdjcmmx diffgr:id=""yx_t_kcdjcmmx4"" msdata:rowOrder=""3"" mxid=""114890126"" sphh=""0DNK0031Y"" cmdm=""cm21"" sl0=""3"" jysl0=""0"" tml=""3"" />
//      </DocumentElement>
//    </diffgr:diffgram>
//  </cmmxTable>
//  <codesTable>
//    <xs:schema id=""NewDataSet"" xmlns="""" xmlns:xs=""http://www.w3.org/2001/XMLSchema"" xmlns:msdata=""urn:schemas-microsoft-com:xml-msdata"">
//      <xs:element name=""NewDataSet"" msdata:IsDataSet=""true"" msdata:MainDataTable=""yx_t_kcdjspid"" msdata:UseCurrentLocale=""true"">
//        <xs:complexType>
//          <xs:choice minOccurs=""0"" maxOccurs=""unbounded"">
//            <xs:element name=""yx_t_kcdjspid"">
//              <xs:complexType>
//                <xs:attribute name=""mxid"" type=""xs:int"" />
//                <xs:attribute name=""spid"" type=""xs:string"" />
//                <xs:attribute name=""tm"" type=""xs:string"" />
//                <xs:attribute name=""zxxh"" type=""xs:string"" />
//                <xs:attribute name=""zxuser"" type=""xs:string"" />
//                <xs:attribute name=""edituser"" type=""xs:string"" />
//                <xs:attribute name=""editdate"" type=""xs:string"" />
//                <xs:attribute name=""bz"" type=""xs:string"" />
//              </xs:complexType>
//            </xs:element>
//          </xs:choice>
//        </xs:complexType>
//      </xs:element>
//    </xs:schema>
//    <diffgr:diffgram xmlns:msdata=""urn:schemas-microsoft-com:xml-msdata"" xmlns:diffgr=""urn:schemas-microsoft-com:xml-diffgram-v1"">
//      <DocumentElement>
//        <yx_t_kcdjspid diffgr:id=""yx_t_kcdjspid1"" msdata:rowOrder=""0"" diffgr:hasChanges=""inserted"" mxid=""114890126"" spid=""0DNK0031Y76012345"" tm="""" zxxh="""" zxuser=""薛灵敏"" editdate=""2015-07-21 19:11:27"" bz="""" />
//      </DocumentElement>
//    </diffgr:diffgram>
//  </codesTable>
//  <khmc>安徽合肥思晨商贸有限公司</khmc>
//  <id>7301404</id>
//  <djh>100005</djh>
//  <khid>85</khid>
//</kcdjcmmx>
//                ";
                
                 
                if (objStr == null || objStr == "")
                {
                    errInfo = "缺少参数【objStr】！";
                }
                else
                {
                    clsLoger.WriteLog("0","PADScan","",objStr);
                    saveData(tzid, objStr);                    
                }
                break;
            case "getTml":
                getTml();
                break;
            default:
                errInfo = "无CTRL对应操作！";
                break;
        }

        if (errInfo == "")
            clsSharedHelper.WriteSuccessedInfo("");
        else
            clsSharedHelper.WriteErrorInfo(errInfo);
    }

    public bool IsReusable
    {
        get
        {
            return false;
        }
    }

    //获得利郎条码类
    public void getTml()
    {
        using (LiLanzDALForXLM dal = new LiLanzDALForXLM())
        {
            String sql = "select id,spdlid,cmdm,cmdm1,tml1,tml2,tml4 tml3,tml3 tml4,tml5,[stop] from yx_t_cmdmb where tzid=1";//条码类3/4是反的
            String tmlXml = "";
            String errInfo = dal.ExecuteQueryForXML(sql, out tmlXml, "yx_t_cmdmb");

            if (errInfo == "")
                clsSharedHelper.WriteSuccessedInfo(tmlXml);
            else
                clsSharedHelper.WriteErrorInfo(errInfo);
        }
    }

    //查询列表数据
    public void viewMain(string tzid, string days, string djh)
    {
        String str_tj = "";
        if (days != "" && days != "0" && days != null)
        {
            str_tj += " and a.rq>=dateadd(day,-" + days + ",getdate()) ";
        }
        if (djh != "" && djh != null)
        {
            str_tj += " and a.djh = '" + djh + "'";
        }
        String sql = "select id, a.tzid,a.djh,kh.khdm+'.'+kh.khmc as kh,convert(varchar,a.rq,23) as rq,a.bz from yx_T_kcdjb a inner join yx_t_khb kh on a.khid=kh.khid  where a.tzid=@tzid " + str_tj + " and isnull(a.qrbs,0)<>1 and a.djlx=111 AND isnull(a.shbs,0)=1 order by a.rq ";

        using (LiLanzDALForXLM dal = new LiLanzDALForXLM(Convert.ToInt32(tzid)))
        {
            DataTable dt = new DataTable();
            string Info = "";
            List<SqlParameter> listPara = new List<SqlParameter>();
            listPara.Add(new SqlParameter("@tzid", tzid));
            Info = dal.ExecuteQuerySecurity(sql, listPara, out dt);
            if (Info != "")
            {
                clsSharedHelper.WriteErrorInfo(Info);
            }
            else
            {
                OrderBlank OB = new OrderBlank();
                dt.TableName = "yx_t_kcdjb";
                foreach (DataColumn dc in dt.Columns)
                {
                    dc.ColumnMapping = MappingType.Attribute;
                }
                OB.dt = dt;
                string rt = ObjToXml<OrderBlank>(OB);
                OB.Dispose();
                clsSharedHelper.WriteSuccessedInfo(rt);
            }
        }
    }

    //查询单据明细数据
    public void viewDetail(string tzid, string id)
    {
        String errInfo = "", objStr = "";
        using (LiLanzDALForXLM dal = new LiLanzDALForXLM(Convert.ToInt32(tzid)))
        {
            String sql = "select a.id,a.djh,a.khid,a.ckid,kh.khmc from yx_t_kcdjb a inner join yx_t_khb kh on a.khid=kh.khid where a.id=@id";
            DataTable dt = null;
            kcdjcmmx obj = new kcdjcmmx();
            List<SqlParameter> p1 = new List<SqlParameter>();
            p1.Add(new SqlParameter("@id", id));
            errInfo = dal.ExecuteQuerySecurity(sql, p1, out dt);

            if (errInfo == "")
            {
                if (dt.Rows.Count > 0)
                {
                    //加载主表数据                
                    obj.id = Convert.ToInt32(id);
                    obj.djh = dt.Rows[0]["djh"].ToString();
                    obj.ckid = Convert.ToInt32(dt.Rows[0]["ckid"].ToString());
                    obj.khid = Convert.ToInt32(dt.Rows[0]["khid"].ToString());
                    obj.khmc = dt.Rows[0]["khmc"].ToString();
                    //加载尺码明细数据   
                    DataTable cmmxDt = null;
                    List<SqlParameter> p2 = new List<SqlParameter>();
                    p2.Add(new SqlParameter("@id", id));
                    sql = @"select a.mxid,b.sphh,a.cmdm,isnull(a.sl0,0) sl0,isnull(a.jysl0,0) jysl0,sp.tml from yx_t_kcdjcmmx a 
                        inner join yx_t_kcdjmx b on a.mxid=b.mxid and a.id=b.id 
                        inner join yx_t_spdmb sp on sp.sphh=b.sphh
                        where a.id=@id";
                    errInfo = dal.ExecuteQuerySecurity(sql, p2, out cmmxDt);
                    if (errInfo == "")
                    {
                        cmmxDt.TableName = "yx_t_kcdjcmmx";                        
                        foreach (DataColumn dc in cmmxDt.Columns)
                        {
                            dc.ColumnMapping = MappingType.Attribute;
                        }                        
                        obj.cmmxTable = cmmxDt;
                        
                        //加载唯一码表数据  
                        DataTable codesDt = null;                        
                        List<SqlParameter> p3 = new List<SqlParameter>();
                        p3.Add(new SqlParameter("@id", id));
                        sql = "select mxid,spid,'' tm,zxxh,'' zxuser,edituser,case when isnull(editdate,'')='' then '' else convert(varchar(10),editdate,23) end editdate,bz from yx_t_kcdjspid where id=@id";
                        errInfo = dal.ExecuteQuerySecurity(sql, p3, out codesDt);

                        if (errInfo == "")
                        {
                            codesDt.TableName = "yx_t_kcdjspid";
                            foreach (DataColumn dc in codesDt.Columns)
                            {
                                dc.ColumnMapping = MappingType.Attribute;
                            }
                            obj.codesTable = codesDt;
                        }//end if 唯一码
                    }//end if 尺码明细
                }
                else {
                    errInfo = "查询不到数据！";
                }
            }//end if 主表数据   

            try
            {
                objStr = ObjToXml<kcdjcmmx>(obj);
            }
            catch (Exception ex)
            {
                clsSharedHelper.WriteErrorInfo("捕获异常！" + ex.Message);
            }

            obj.Dispose();
            if (errInfo != "")
                clsSharedHelper.WriteErrorInfo(errInfo);
            else
                clsSharedHelper.WriteSuccessedInfo(objStr);            
        }
    }

    /// <summary>
    /// 保存 插入yx_t_kcdjspid 更新yx_t_kcdjcmmx
    /// </summary>
    /// <returns></returns>
    public void saveData(string tzid,string xmlStr)
    {
        kcdjcmmx obj = null;
        try
        {
            //反序列化
            obj = XmlDeSerialize<kcdjcmmx>(xmlStr);
        }
        catch (Exception ex)
        {
            clsSharedHelper.WriteErrorInfo("捕获异常！" + ex.Message);
        }

        using (LiLanzDALForXLM dal = new LiLanzDALForXLM(Convert.ToInt32(tzid)))
        {
            //构造SQL语句
            int id = obj.id;
            int ckid = obj.ckid;
            DataTable dt = obj.codesTable;
            String str_sql = "", errInfo = "";
            StringBuilder sb = new StringBuilder();
			if(dt.Rows.Count > 0 && id > 0)
			{
				sb.AppendFormat("delete from yx_t_kcdjspid where id='{0}'", id);
			}
            for (int i = 0; i < dt.Rows.Count; i++)
            {
                str_sql = @"insert into yx_t_kcdjspid(id,ckid,spid,bz) values ('{1}','{2}','{3}','pda'); ";
                sb.AppendFormat(str_sql, dt.Rows[i]["spid"].ToString(), id, ckid, dt.Rows[i]["spid"].ToString());
            }

            dt = obj.cmmxTable;
            for (int i = 0; i < dt.Rows.Count; i++)
            {
                str_sql = @"update yx_t_kcdjcmmx set jysl0={0} where id='{1}' and mxid='{2}' and cmdm='{3}';";
                int jysl = dt.Rows[i]["jysl0"].ToString() == "" ? 0 : Convert.ToInt32(dt.Rows[i]["jysl0"].ToString());
                sb.AppendFormat(str_sql, jysl, id.ToString(), dt.Rows[i]["mxid"].ToString(), dt.Rows[i]["cmdm"].ToString());
            }

            str_sql = sb.ToString();
            errInfo = dal.ExecuteNonQuery(str_sql);
            if (errInfo == "")
            {
                obj.Dispose();
                clsSharedHelper.WriteSuccessedInfo("保存成功！");
            }
            else
            {
                clsSharedHelper.WriteErrorInfo("保存失败！ 【原因】：" + errInfo);
            }
        }
    }

    public static string ObjToXml<T>(T obj)
    {
        string retVal;
        using (MemoryStream ms = new MemoryStream())
        {
            XmlSerializer xs = new XmlSerializer(typeof(T));            
            xs.Serialize(ms, obj);
            ms.Flush();
            ms.Position = 0;
            StreamReader sr = new StreamReader(ms);
            retVal = sr.ReadToEnd();
        }
        return retVal;
    }
/*    
    //序列化函数
    public string XmlSerialize<T>(T obj)
    {
        XmlSerializer serializer = new XmlSerializer(typeof(T));
        MemoryStream ms = new MemoryStream();
        XmlWriterSettings xws = new XmlWriterSettings();
        xws.Indent = true;
        xws.OmitXmlDeclaration = true;
        XmlWriter textWriter = XmlWriter.Create(ms, xws);
        serializer.Serialize(textWriter, obj);
        byte[] mybyte = ms.ToArray();

        textWriter.Close();
        ms.Close();
        return Encoding.UTF8.GetString(mybyte, 0, mybyte.Length);
    }
*/
    public static string XmlSerialize<T>(T obj)
    {
        XmlSerializer serializer = new XmlSerializer(typeof(T));
        MemoryStream ms = new MemoryStream();
        XmlWriterSettings xws = new XmlWriterSettings();
        xws.Indent = true;
        xws.OmitXmlDeclaration = true;
        XmlWriter textWriter = XmlWriter.Create(ms, xws);
        XmlSerializerNamespaces _namespaces = new XmlSerializerNamespaces(
                    new XmlQualifiedName[] { 
                      new XmlQualifiedName(null, null)  
                 });
        serializer.Serialize(textWriter, obj,_namespaces);
        return Encoding.UTF8.GetString(ms.ToArray());
    }

    //反序列化函数
    public T XmlDeSerialize<T>(string objString)
    {
        XmlSerializer serializer = new XmlSerializer(typeof(T));
        MemoryStream ms = new MemoryStream(Encoding.UTF8.GetBytes(objString));
        ms.Position = 0;
        T _obj = (T)serializer.Deserialize(ms);
        ms.Close();
        return _obj;
    }

    public static string base64Encode(string s)
    {
        byte[] bytes = Encoding.UTF8.GetBytes(s);
        string str64 = Convert.ToBase64String(bytes);

        str64 = str64.Replace('=', '|'); //变化
        str64 = str64.Replace('+', '.'); //变化
        return str64;
    }

    public static string base64Decode(string s)
    {
        s = s.Replace('|', '='); //变化
        s = s.Replace('.', '+'); //变化
        byte[] outputb = Convert.FromBase64String(s);
        return Encoding.UTF8.GetString(outputb, 0, outputb.Length);
    }
}


//主表实体类
public class OrderBlank : IDisposable
{
    private DataTable _dt;
    public DataTable dt
    {
        get { return _dt; }
        set { _dt = value; }
    }
    public OrderBlank()
    {

    }

    public void Dispose()
    {
        _dt.Clear();
        _dt.Dispose();
    }
}

//明细实体类
public class kcdjcmmx : IDisposable
{
    //主表信息
    private int _id;
    private string _djh;
    private int _khid;
    private string _khmc;
    private int _ckid;

    private DataTable _cmmxTable;//明细数据
    private DataTable _codesTable;//唯一码数据

    public int id
    {
        get { return this._id; }
        set { this._id = value; }
    }

    public string djh
    {
        get { return this._djh; }
        set { this._djh = value; }
    }

    public int khid
    {
        get { return this._khid; }
        set { this._khid = value; }
    }

    public string khmc
    {
        get { return this._khmc; }
        set { this._khmc = value; }
    }

    public int ckid
    {
        get { return this._ckid; }
        set { this._ckid = value; }
    }

    public DataTable cmmxTable
    {
        get { return this._cmmxTable; }
        set { this._cmmxTable = value; }
    }

    public DataTable codesTable
    {
        get { return this._codesTable; }
        set { this._codesTable = value; }
    }

    //像DATATABLE这种大对象用完记得手动释放
    public void Dispose()
    {
        if (_cmmxTable != null) {
            _cmmxTable.Clear();
            _cmmxTable.Dispose();        
        }
        if (_codesTable != null) {
            _codesTable.Clear();
            _codesTable.Dispose();
        }        
    }
}