using nrWebClass;
using System;
using System.Collections.Generic;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;
using System.Data;
public partial class WebService_原料检测项目 : System.Web.UI.Page
{
    protected void Page_Load(object sender, EventArgs e)
    {
        string DBConnStr = "server='192.168.35.10';uid=abeasd14ad;pwd=+AuDkDew;database=tlsoft";
        using (LiLanzDALForXLM dal = new LiLanzDALForXLM(DBConnStr))
        {
            string str_sql = @"select name as xmmc FROM yf_t_wjxmb where djlx=2411 and ty=0  AND lx in (0,1);
SELECT a.sxfs, a.mxid ,a.sphh AS chdm,kh.khmc,b.zdr
FROM yx_t_jdxymxb a
INNER JOIN dbo.yx_t_jdxyb b ON a.id=b.id AND b.kfbh='201931'
INNER JOIN dbo.yx_t_khb kh ON kh.khid=b.khid
 WHERE  b.djlx=388
";
            string insertSql = "";
            DataSet ds = new DataSet();
            string errinfo = dal.ExecuteQuery(str_sql, out ds);
            if (errinfo != "")            
                return;
            DataTable xmmc = ds.Tables[0];
            List<string> xmList = new List<string>();
            foreach (DataRow dr in xmmc.Rows)
            {
                xmList.Add(dr["xmmc"].ToString());
            }
                DataTable sj = ds.Tables[1];
            foreach(DataRow dr in sj.Rows)
            {
                string[] sxfs = dr["sxfs"].ToString().Split('+');
                for(int i = 0; i < sxfs.Length; i++)
                {
                    if (sxfs[i] != "")
                    {
                        if (xmList.IndexOf(sxfs[i]) < 0)
                        {
                            insertSql += " insert tmp20190603 (mxid,chdm,sxfs,ghsmc,zdr) values('" + dr["mxid"].ToString()+"','"+dr["chdm"]+"','"+ dr["sxfs"].ToString() + "','" + dr["khmc"].ToString() + "','" + dr["zdr"].ToString() + "')  ";
                            break;
                        }
                    }
                }
            }
            if (!string.IsNullOrEmpty(insertSql))
            {
                DataSet ds2 = new DataSet();
                dal.ExecuteQuery(insertSql, out ds2);
            }

        }
    }
}