using BarCodeWebservice;
using System;
using System.Collections.Generic;
using System.Data;
using System.Data.SqlClient;

using System.Xml;
using TLBaseData;

public partial class 订货会打印测试 : System.Web.UI.Page
{
    protected void Page_Load(object sender, EventArgs e)
    {
        pd_PrintPage();
    }
    private TagBarCode _TagBarCode = new TagBarCode();
    private void pd_PrintPage()
    {
        XmlDocument xmlDocument = new XmlDocument();
        string xml = GetBarCode("17D05188");
        xmlDocument.LoadXml(xml);
        XmlNodeList childNodes = xmlDocument.SelectSingleNode("/FeedBack").ChildNodes;
        if (childNodes.Count > 0)
        {
            
            XmlNode xmlNode = childNodes[0];
            foreach (object obj in childNodes)
            {
                XmlNode xmlNode2 = (XmlNode)obj;
                string value = xmlNode2.Attributes["yphh"].Value;
                if (value.Substring(value.Length - 2, 2) == "61")
                {
                    xmlNode = xmlNode2;
                }
            }
         
            
        }
    }


    public string GetBarCode(string tag)
    {
        string text = "<?xml version=\"1.0\" encoding=\"gb2312\"?><FeedBack>";
        string cmdText = string.Format("select a.ypmc,a.yphh,ROUND(yfcbdj,2) as yfcbdj,a.mlcf,isnull(a.tydddj,0) tydddj,lsdj,cjyphh,bjid,a.bq, xl.mc xlmc, a.bhksid, a.bhks from  yx_t_ypdmb as  a    left join yf_T_kfbh AS  kf on a.kfbh=kf.dm and a.tzid=kf.tzid left join t_xtdm AS  xl on a.fg=xl.dm and xl.ssid=401 and xl.tzid=1 WHERE a.bq='{0}' OR a.yphh ='{0}' ", tag);
        SqlConnection sqlConnection = new SqlConnection() ;
        sqlConnection.ConnectionString = "server='192.168.35.10';uid=ABEASD14AD;pwd=+AuDkDew;database=tlsoft";
        if (sqlConnection.State == ConnectionState.Open)
        {
            sqlConnection.Close();
        }
        sqlConnection.Open();
        using (SqlCommand sqlCommand = new SqlCommand(cmdText, sqlConnection))
        {
            SqlDataReader sqlDataReader = sqlCommand.ExecuteReader();
            while (sqlDataReader.Read())
            {
                string bjid = sqlDataReader[7].ToString();
                clothing clothing = this.getClothing(bjid);
                string bx = this.getBx(sqlDataReader["bhksid"].ToString());
                if (bx == "")
                {
                    bx = this.getBx(sqlDataReader["bhks"].ToString());
                }
                text += string.Format("<tag ypmc=\"{0}\" yphh=\"{1}\" yfcbdj=\"{2}\" mlcf=\"{3}\" tydddj=\"{4}\" lsdj=\"{5}\" tagCode=\"{6}\" nd=\"{7}\" ml=\"{8}\" cjyphh=\"{9}\" xlmc=\"{10}\"  bx=\"{11}\" />", new object[]
                {
                        sqlDataReader["ypmc"],
                        sqlDataReader["yphh"],
                        sqlDataReader["yfcbdj"],
                        sqlDataReader["mlcf"],
                        sqlDataReader["tydddj"],
                        sqlDataReader["lsdj"],
                        sqlDataReader["bq"],
                        clothing.nd,
                        clothing.ml,
                        sqlDataReader["cjyphh"],
                        sqlDataReader["xlmc"],
                        bx
                });
            }
            sqlConnection.Close();
        }
        text += "</FeedBack>";
        return text;
    }

    // Token: 0x06000003 RID: 3 RVA: 0x00002218 File Offset: 0x00000418
    private clothing getClothing(string bjid)
    {
        clothing result;
        result.ml = "";
        result.nd = "";
        string cmdText = string.Format("SELECT zbid,sz FROM dbo.Yf_T_bjdmxb WHERE mxid={0} AND zbid IN (1772,1774)", bjid);
        SqlConnection sqlConnection = new SqlConnection();
        sqlConnection.ConnectionString = "server='192.168.35.10';uid=ABEASD14AD;pwd=+AuDkDew;database=tlsoft";
        if (sqlConnection.State == ConnectionState.Open)
        {
            sqlConnection.Close();
        }
        using (SqlCommand sqlCommand = new SqlCommand(cmdText, sqlConnection))
        {
            sqlConnection.Open();
            SqlDataReader sqlDataReader = sqlCommand.ExecuteReader();
            while (sqlDataReader.Read())
            {
                if (sqlDataReader[0].ToString() == "1772")
                {
                    result.nd = sqlDataReader[1].ToString();
                }
                else
                {
                    result.ml = sqlDataReader[1].ToString();
                }
            }
            sqlConnection.Close();
        }
        return result;
    }

    // Token: 0x06000004 RID: 4 RVA: 0x000022F0 File Offset: 0x000004F0
    private string getBx(string id)
    {
        if (id == "")
        {
            return "";
        }
        string cmdText = string.Format("select mc from Yf_T_bjdbjzb where id={0}", id);
        SqlConnection sqlConnection = new SqlConnection();
        sqlConnection.ConnectionString = "server='192.168.35.10';uid=ABEASD14AD;pwd=+AuDkDew;database=tlsoft";
        if (sqlConnection.State == ConnectionState.Open)
        {
            sqlConnection.Close();
        }
        object obj;
        using (SqlCommand sqlCommand = new SqlCommand(cmdText, sqlConnection))
        {
            sqlConnection.Open();
            obj = sqlCommand.ExecuteScalar();
            if (obj == null)
            {
                obj = "";
            }
            sqlConnection.Close();
        }
        return obj.ToString();
    }

    // Token: 0x04000001 RID: 1
    private _MyData sqlHelp = new _MyData();

    // Token: 0x02000003 RID: 3
    private struct clothing
    {
        // Token: 0x04000002 RID: 2
        public string nd;

        // Token: 0x04000003 RID: 3
        public string ml;
    }
 

}