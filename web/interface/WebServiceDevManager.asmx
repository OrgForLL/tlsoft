<%@ WebService Language="C#" Class="WebServiceDevManager" %>

using System;
using System.Collections.Generic;
using System.Web;
using System.Web.Services;
using nrWebClass;
using System.Data;
using System.Text;
using System.Xml;
using System.Xml.Serialization;
    /// <summary>
    /// Service1 的摘要说明
    /// </summary>
    [WebService(Namespace = "http://tempuri.org/")]
    [WebServiceBinding(ConformsTo = WsiProfiles.BasicProfile1_1)]
    [System.ComponentModel.ToolboxItem(false)]

    public class WebServiceDevManager : System.Web.Services.WebService
    {        
        string connStr=System.Configuration.ConfigurationManager.ConnectionStrings["devManage"].ConnectionString;
        /// <summary>
        /// 获取省份信息
        /// </summary>
        /// <param name="proBarCode">省份对应的条码信息</param>
        /// <returns>返回省份表对应的ID、省份代码、省份名称</returns>
        [WebMethod]
        public string getProvice(string proBarCode) {
            string rtMsg ="",errInfo="";
            if (proBarCode == "")
            {
                rtMsg = string.Format(@"{{""type"":""{0}"",""result"":""{1}""}}","Error","传入的参数不能为空！"); 
            }
            else {
                string sql = string.Format(@"select id,procode,proname,properson,propersontel from dh_t_province where probarcode='{0}';",proBarCode);
                DataTable dt = null;
                using (LiLanzDALForXLM dal = new LiLanzDALForXLM(connStr))
                {
                    errInfo = dal.ExecuteQuery(sql,out dt);
                    if (errInfo == "") {
                        if (dt.Rows.Count > 0) {
                            rtMsg = string.Format(@"{{""type"":""{0}"",""proID"":""{1}"",""proCode"":""{2}"",""proName"":""{3}"",""proPerson"":""{4}"",""proPersonTel"":""{5}""}}", "Succeed", dt.Rows[0]["id"].ToString(),dt.Rows[0]["procode"].ToString(),dt.Rows[0]["proname"].ToString(),dt.Rows[0]["proPerson"].ToString(),dt.Rows[0]["proPersonTel"].ToString());
                        }else
                            rtMsg = string.Format(@"{{""type"":""{0}"",""result"":""{1}""}}", "Error", "查不到对应的省份信息！");
                    }else
                        rtMsg = string.Format(@"{{""type"":""{0}"",""result"":""{1}""}}", "Error",errInfo);
                }
            }
            
            return rtMsg;
        }

        [WebMethod]
        public string othersSave(string type,string proID,int lines,int heads) {
            string rtMsg = "";
            string errInfo = "";
            string sql = string.Format(@"insert into dh_t_linesHeadsIO(proid,[linesno],headsno,[type],[time]) values ('{0}',{1},{2},'{3}',getdate())", proID, lines, heads, type);
            using (LiLanzDALForXLM dal = new LiLanzDALForXLM(connStr)) {
                errInfo = dal.ExecuteNonQuery(sql);
                if (errInfo == "")
                {
                    rtMsg = "保存成功！";
                }
                else {
                    rtMsg = errInfo;
                }
            }
            
            return rtMsg;
        }
        
        /// <summary>
        /// 查询设备的出入库信息
        /// </summary>
        /// <param name="devBarCode">设备的条码</param>
        /// <returns></returns>
        [WebMethod]
        public string getDevInfo(string devBarCode) {
            String rtMsg = "", errInfo = "", str_sql="";
            using (LiLanzDALForXLM dal = new LiLanzDALForXLM(connStr)) {
                if (devBarCode.Length >= 3 && devBarCode.Substring(0, 3) == "Pro")
                    str_sql = @"select b.id,b.proname,count(a.devbarcode) sl from dh_t_deviceio a
                                inner join dh_t_province b on a.outpro=b.id
                                where outmark=1 and inmark=0 and b.probarcode='{0}' group by b.id,b.proname ";
                else
                    str_sql = @"select top 1 a.id,a.outmark,isnull(c.proname,'') outpro,a.outtime,isnull(d.proname,'') inpro,a.inmark,a.intime,
                                isnull(c.properson,'') ope,isnull(c.propersontel,'') optel,isnull(d.properson,'') ipe,isnull(d.propersontel,'') iptel,
                                isnull(e.reasondes,'') outreason,isnull(f.reasondes,'') inreason from dh_t_deviceio a 
                                inner join (select max(id) mid,devbarcode from dh_t_deviceio group by devbarcode) b on a.id=b.mid
                                left join dh_t_province c on a.outpro=c.id left join dh_t_province d on a.inpro=d.id
                                left join dh_t_inoutReasons e on a.outreason=e.dm left join dh_t_inoutReasons f on a.inreason=f.dm
                                where a.devbarcode='{0}';"; 
                
                DataTable dt = null;
                str_sql = string.Format(str_sql,devBarCode);
                errInfo = dal.ExecuteQuery(str_sql,out dt);
                if (errInfo == "")
                {
                    if (dt.Rows.Count > 0)
                    {
                        if (devBarCode.Length >= 3 && devBarCode.Substring(0, 3) == "Pro")
                        {
                            rtMsg += "该省【" + dt.Rows[0]["proname"].ToString() + "】目前总共领取了" + dt.Rows[0]["sl"].ToString() + "台设备！";
                        }
                        else
                        {
                            if (dt.Rows[0]["outmark"].ToString() == "True")
                            {
                                rtMsg += "该设备【" + devBarCode + "】于 " + dt.Rows[0]["outtime"].ToString() + " 被【" + dt.Rows[0]["outpro"].ToString() + "】领取，领取原因【" + dt.Rows[0]["outreason"].ToString() + "】，对应负责人：" + dt.Rows[0]["ope"].ToString() + "负责人电话：" + dt.Rows[0]["optel"].ToString() + "，";
                            }

                            if (dt.Rows[0]["inmark"].ToString() == "True")
                                rtMsg += "于 " + dt.Rows[0]["intime"].ToString() + " 被【" + dt.Rows[0]["inpro"].ToString() + "】归还，归还原因【" + dt.Rows[0]["inreason"].ToString() + "】，对应负责人：" + dt.Rows[0]["ipe"].ToString() + "负责人电话：" + dt.Rows[0]["iptel"].ToString() + "。";
                            else
                                rtMsg += "但还未归还！";
                        }
                    }
                    else if (devBarCode.Length >= 3 && devBarCode.Substring(0, 3) == "Pro")
                        rtMsg = "查询不到该省份的出入库信息！";
                    else                    
                        rtMsg = "查询不到该设备的对应出入库信息！";
                }
                else
                    rtMsg = errInfo;
            }
            return rtMsg;        
        }
        
        /// <summary>
        /// 用于设备的归还、领取操作
        /// </summary>
        /// <param name="type">操作类型out领取 in归还</param>
        /// <param name="devBarCode">设备的条码信息</param>
        /// <param name="proID">省份ID</param>
        /// <returns></returns>
        [WebMethod]
        public string deviceDataIO(string type,string devBarCode,string proID,string proName,string reason) {
            string rtMsg = @"{{""type"":""{0}"",""result"":""{1}""}}";
            string errInfo = "";
            string sql = string.Format(@"select a.id,a.outpro,o.proname outname,a.inpro,i.proname inname 
                                         from dh_t_deviceio a  
                                         left join dh_t_province o on a.outpro=o.id
                                         left join dh_t_province i on a.inpro=i.id
                                         where a.outMark=1 and a.inMark=0 and a.devBarCode='{0}'", devBarCode);
            using (LiLanzDALForXLM dal = new LiLanzDALForXLM(connStr))
            {
                DataTable dt = null;
                errInfo = dal.ExecuteQuery(sql, out dt);
                if (errInfo == "")
                {                    
                    if (type == "out") {
                        if (dt.Rows.Count == 0)
                        {
                            sql = string.Format(@"insert into dh_t_deviceio(devbarcode,outmark,outpro,outtime,outreason,inreason) values ('{0}',1,'{1}',getdate(),'{2}','{3}');", devBarCode, proID, reason, "");
                            errInfo = dal.ExecuteNonQuery(sql);
                            if (errInfo == "")
                                rtMsg = string.Format(rtMsg, "Succeed", "【" + devBarCode + "】领取成功！");
                            else
                                rtMsg = string.Format(rtMsg, "Error", "设备领取失败：" + errInfo);
                        }
                        else
                            rtMsg = string.Format(rtMsg, "Error", "该设备已被【"+dt.Rows[0]["outname"].ToString()+"】领取但还未归还，请先归还后再领取！");
                    }
                    else if (type == "in") {
                        if (dt.Rows.Count > 0) {
                            sql = string.Format(@"update dh_t_deviceio set inmark=1,inpro='{0}',intime=getdate(),inreason='{3}' where id='{1}' and devbarcode='{2}';",proID,dt.Rows[0]["id"].ToString(),devBarCode,reason);
                            errInfo = dal.ExecuteNonQuery(sql);
                            if (errInfo == "") {
                                string tmp = dt.Rows[0]["outpro"].ToString() == proID ? "" : "但领取对象："+dt.Rows[0]["outname"].ToString()+" 与归还对象："+ proName +"不一致！";
                                rtMsg = string.Format(rtMsg, "Succeed", "【" + devBarCode + "】归还成功！"+tmp);
                            }
                            else
                                rtMsg = string.Format(rtMsg, "Error", "设备归还失败：" + errInfo);
                        }else
                            rtMsg = string.Format(rtMsg, "Error", "该设备尚未被领取，请先领取后再归还！");
                    }else
                        rtMsg = string.Format(rtMsg, "Error", "无对应的操作类型定义！");
                }
                else
                    rtMsg = string.Format(rtMsg, "Error", errInfo);
            }

            return rtMsg;
        }

        /// <summary>
        /// 加载出入库的原因数据
        /// </summary>        
        /// <returns>返回序列化的DATATABLE</returns>
        [WebMethod]
        public string getReasons()
        {
            string rtMsg = "", errInfo = "";
            using (LiLanzDALForXLM dal = new LiLanzDALForXLM(connStr)) {
                DataTable dt = null;
                string str_sql = "select dm,reasonDes from dh_t_inoutReasons where isdeleted=0";
                errInfo = dal.ExecuteQuery(str_sql,out dt);
                if (errInfo == "" && dt.Rows.Count>0) {
                    dt.TableName = "dh_t_inoutReasons";
                    foreach (DataColumn dc in dt.Columns)
                    {
                        dc.ColumnMapping = MappingType.Attribute;
                    }

                    rtMsg = SerializeDataTableXml(dt);
                }                
            }

            return rtMsg;
        }

        private string SerializeDataTableXml(DataTable pDt)
        {
            //序列化DataTable
            StringBuilder sb = new StringBuilder();
            XmlWriter writer = XmlWriter.Create(sb);
            XmlSerializer serializer = new XmlSerializer(typeof(DataTable));
            serializer.Serialize(writer, pDt);
            writer.Close();

            return sb.ToString();
        } 
    }    

