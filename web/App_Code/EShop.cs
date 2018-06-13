using System;
using System.Collections.Generic;
using System.Web;
using MySql.Data.MySqlClient;
/// <summary>
///EShop 的摘要说明
/// </summary>
public class EShop
{
	public EShop()
	{
		//
		//TODO: 在此处添加构造函数逻辑
		//
	}
    public static void BS2ErpSale(string constr ,int bsid, int erpdjid)
    {
        MySqlParameter[] para = new MySqlParameter[] { 
                    new MySqlParameter("?p_id", MySqlDbType.Int32) ,
                    new MySqlParameter("?erp_djid", MySqlDbType.Int32)
                };
        para[0].Value = bsid;
        para[1].Value = erpdjid;
        MySqlHelper.ExecuteNonQuery(constr, "insert into t_bs2erplsxhd (p_id, ERP_djid) values (?p_id, ?erp_djid)", para);
    }
    public static void BS2ErpSaleRuturn(string constr, int bsid, int erpdjid)
    {
        MySqlParameter[] para = new MySqlParameter[] { 
                    new MySqlParameter("?p_id", MySqlDbType.Int32) ,
                    new MySqlParameter("?erp_djid", MySqlDbType.Int32)
                };
        para[0].Value = bsid;
        para[1].Value = erpdjid;
        MySqlHelper.ExecuteNonQuery(constr, "insert into t_bs2erplsthd (p_id, ERP_djid) values (?p_id, ?erp_djid)", para);
    }
    public static void BS2ErpSaleDelete(string constr, int erpdjid)
    {
        MySqlParameter[] para = new MySqlParameter[] { 
                    new MySqlParameter("?erp_djid", MySqlDbType.Int32)
                };
        para[0].Value = erpdjid;
        MySqlHelper.ExecuteNonQuery(constr, "DELETE FROM t_bs2erplsxhd where ERP_djid=?erp_djid", para);
    }
    public static string getOrderInfo(string constr, string dealNum)
    {
        string return_value = "";
        MySqlParameter[] para = new MySqlParameter[] { 
                    new MySqlParameter("?deal_code", MySqlDbType.VarChar)
                };
        para[0].Value = dealNum;
        MySqlDataReader reader = MySqlHelper.ExecuteReader(constr, "select order_sn,alipay_no from order_info where deal_code like ?deal_code ", para);
        if (reader.Read())
        {
            return_value = reader[1].ToString();
        }
        return return_value;
    }
}