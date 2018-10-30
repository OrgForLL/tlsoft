 <%@ WebHandler Language="C#" Class="PosCore" %>
using System;
using System.Web;
using nrWebClass;
using Newtonsoft.Json;
using System.Reflection;
using System.Collections.Generic;
using System.Data.SqlClient;
using System.Data;
using Class_TLtools;
using Newtonsoft.Json.Linq;
using System.IO;
using System.Net;
using System.Text;
public class PosCore : IHttpHandler, System.Web.SessionState.IRequiresSessionState
{
    String wxconn = clsConfig.GetConfigValue("WXConnStr");

    public void ProcessRequest(HttpContext context)
    {
        wxconn = "server=192.168.35.23;database=tlsoft;uid=lllogin;pwd=rw1894tla";
        // create();
        context.Response.ContentEncoding = System.Text.Encoding.UTF8;
        context.Request.ContentEncoding = System.Text.Encoding.UTF8;
        string action = Convert.ToString(context.Request.Params["action"]);
        MethodInfo method = this.GetType().GetMethod(action);
        String rt = "";
        if (method == null)
            rt = rtjson(201, "", "未找到对应的action,请核对后再试！");
        else
        {
            try
            {
                method.Invoke(this, null);
                return;
            }
            catch (Exception ex)
            {
                rt = rtjson(201, "", "Server Error!!" + ex.Message);
            }
        }
        clsSharedHelper.WriteInfo(rt);
    }
    public void delCard()
    {
        String id = Convert.ToString(HttpContext.Current.Request.Params["id"]);
        String modifyType = Convert.ToString(HttpContext.Current.Request.Params["modifyType"]);
        int sl = Convert.ToInt32(HttpContext.Current.Request.Params["sl"]);
        String errInfo, mysql = string.Format("SELECT * FROM wx_T_vipCardInfo WHERE id={0}", id);
        DataTable dt;
        using (LiLanzDALForXLM dal = new LiLanzDALForXLM(wxconn))
        {
            errInfo = dal.ExecuteQuery(mysql, out dt);
        }

        if (errInfo != "")
        {
            errInfo = rtjson(102, "", errInfo);
            clsSharedHelper.WriteInfo(errInfo);
        }
        else if (dt.Rows.Count < 1)
        {
            errInfo = rtjson(102, "", "单据不存在");
            clsSharedHelper.WriteInfo(errInfo);
        }
        DataRow dr = dt.Rows[0];
        string card_id = dr["card_id"].ToString();
        string url = string.Format("https://api.weixin.qq.com/card/delete?access_token={0}", GetToken(Convert.ToString(dr["configkey"])));
        Dictionary<string, object> postDic = new Dictionary<string, object>();
        postDic.Add("card_id", dr["card_id"]);
        string rt = PostFunction(url, JsonConvert.SerializeObject(postDic));
        Dictionary<string, object> dresult = JsonConvert.DeserializeObject<Dictionary<string, object>>(rt);
        int errcode = Convert.ToInt32(dresult["errcode"]);
        if (errcode == 0)
        {
            using (LiLanzDALForXLM dal = new LiLanzDALForXLM(wxconn))
            {
                errInfo = dal.ExecuteNonQuery(string.Format("delete FROM wx_T_vipCardInfo WHERE id={0}", id));
                if (errInfo != "") errcode = 1;
            }
        }
        else
        {
            errInfo = dresult["errmsg"].ToString();
        }
        clsSharedHelper.WriteInfo(rtjson(errcode, "", errInfo));
    }
    public void modifyStock()
    {
        String id = Convert.ToString(HttpContext.Current.Request.Params["id"]);
        String modifyType = Convert.ToString(HttpContext.Current.Request.Params["modifyType"]);
        int sl = Convert.ToInt32(HttpContext.Current.Request.Params["sl"]);
        String errInfo, mysql = string.Format("SELECT * FROM wx_T_vipCardInfo WHERE id={0}", id);
        DataTable dt;
        using (LiLanzDALForXLM dal = new LiLanzDALForXLM(wxconn))
        {
            errInfo = dal.ExecuteQuery(mysql, out dt);
        }

        if (errInfo != "")
        {
            errInfo = rtjson(102, "", errInfo);
            clsSharedHelper.WriteInfo(errInfo);
        }
        else if (dt.Rows.Count < 1)
        {
            errInfo = rtjson(102, "", "单据不存在");
            clsSharedHelper.WriteInfo(errInfo);
        }
        DataRow dr = dt.Rows[0];
        string card_id = dr["card_id"].ToString();

        Dictionary<string, object> postDic = new Dictionary<string, object>();
        postDic.Add("card_id", card_id);
        if (modifyType.Equals("add"))
        {
            postDic.Add("increase_stock_value", sl);
            mysql = string.Format("update wx_T_vipCardInfo set quantity =quantity+{0} where id={1}", sl, id);
        }
        else
        {
            postDic.Add("reduce_stock_value", sl);
            mysql = string.Format("update wx_T_vipCardInfo set quantity =quantity-{0} where id={1}", sl, id);
        }
        string url = string.Format("https://api.weixin.qq.com/card/modifystock?access_token={0}", GetToken(Convert.ToString(dr["configkey"])));
        string rt = PostFunction(url, JsonConvert.SerializeObject(postDic));
        Dictionary<string, object> dresult = JsonConvert.DeserializeObject<Dictionary<string, object>>(rt);
        int errcode = Convert.ToInt32(dresult["errcode"]);
        if (errcode == 0)
        {
            using (LiLanzDALForXLM dal = new LiLanzDALForXLM(wxconn))
            {
                errInfo = dal.ExecuteNonQuery(mysql);
                if (errInfo != "") errcode = 1;
            }
        }
        else
        {
            errInfo = dresult["errmsg"].ToString();
        }
        clsSharedHelper.DisponseDataTable(ref dt);
        clsSharedHelper.WriteInfo(rtjson(errcode, "", errInfo));
    }
    /// <summary>
    /// 创建会员卡
    /// </summary>
    public void create()
    {
        String id = Convert.ToString(HttpContext.Current.Request.Params["id"]);
        if (string.IsNullOrEmpty(id))
        {
            clsSharedHelper.WriteInfo(rtjson(101, "", "缺少必要参数"));
            return;
        }
        String errInfo, mysql = string.Format("SELECT * FROM wx_T_vipCardInfo WHERE id={0}", id);
        DataTable dt;
        using (LiLanzDALForXLM dal = new LiLanzDALForXLM(wxconn))
        {
            errInfo = dal.ExecuteQuery(mysql, out dt);
        }

        if (errInfo != "")
        {
            errInfo = rtjson(102, "", errInfo);
            clsSharedHelper.WriteInfo(errInfo);
        }
        else if (dt.Rows.Count < 1)
        {
            errInfo = rtjson(102, "", "单据不存在");
            clsSharedHelper.WriteInfo(errInfo);
        }
        DataRow dr = dt.Rows[0];

        if (!string.IsNullOrEmpty(Convert.ToString(dr["card_id"])))
        {
            errInfo = rtjson(103, "", "微信卡券已存在,不需要再创建");
            clsSharedHelper.WriteInfo(errInfo);
        }

        Dictionary<string, object> postdate_dic = new Dictionary<string, object>();
        Dictionary<string, object> card_dic = new Dictionary<string, object>();
        Dictionary<string, object> member_card_dic = new Dictionary<string, object>();
        Dictionary<string, object> base_info_dic = new Dictionary<string, object>();
        postdate_dic.Add("card", card_dic);

        card_dic.Add("card_type", dr["card_type"]);
        card_dic.Add("member_card", member_card_dic);

        if (string.IsNullOrEmpty(dr["background_pic_url"].ToString()))
        {
            member_card_dic.Add("background_pic_url", dr["background_pic_url"]);
        }
        member_card_dic.Add("base_info", base_info_dic);
        base_info_dic.Add("logo_url", dr["logo_url"]);
        base_info_dic.Add("code_type", dr["code_type"]);
        Dictionary<string, object> pay_info = new Dictionary<string, object>();
        Dictionary<string, object> swipe_card = new Dictionary<string, object>();
        base_info_dic.Add("pay_info", pay_info);
        pay_info.Add("swipe_card", swipe_card);
        swipe_card.Add("is_swipe_card", Convert.ToBoolean(dr["is_swipe_card"]));

        base_info_dic.Add("brand_name", dr["brand_name"]);
        base_info_dic.Add("title", dr["title"]);
        base_info_dic.Add("color", dr["color"]);
        base_info_dic.Add("notice", dr["notice"]);
        base_info_dic.Add("description", dr["description"]);
        Dictionary<string, object> sku = new Dictionary<string, object>();
        sku.Add("quantity", dr["quantity"]);
        base_info_dic.Add("sku", sku);
        Dictionary<string, string> date_info = new Dictionary<string, string>();
        date_info.Add("type", "DATE_TYPE_PERMANENT");
        base_info_dic.Add("date_info", date_info);

        base_info_dic.Add("center_title", dr["center_title"]);
        base_info_dic.Add("center_sub_title", dr["center_sub_title"]);
        base_info_dic.Add("center_url", dr["center_url"]);


        base_info_dic.Add("get_limit", dr["get_limit"]);
        base_info_dic.Add("can_share", dr["can_share"]);
        base_info_dic.Add("can_give_friend", dr["can_give_friend"]);
        base_info_dic.Add("need_push_on_view", dr["need_push_on_view"]);

        member_card_dic.Add("prerogative", dr["prerogative"]);
        member_card_dic.Add("supply_bonus", dr["supply_bonus"]);
        member_card_dic.Add("wx_activate", dr["wx_activate"]);
        member_card_dic.Add("wx_activate_after_submit", dr["wx_activate_after_submit"]);
        member_card_dic.Add("wx_activate_after_submit_url", dr["wx_activate_after_submit_url"]);

        member_card_dic.Add("supply_balance", false);
        member_card_dic.Add("discount", dr["discount"]);

        for (int i = 1; i < 2; i++)
        {
            string custom_field = string.Format("custom_field{0}", i);
            if (!string.IsNullOrEmpty(Convert.ToString(dr[custom_field + "_url"])))
            {

                Dictionary<string, object> custom_field_did = new Dictionary<string, object>();
                custom_field_did.Add("name_type", dr[custom_field + "_name_type"]);
                custom_field_did.Add("url", dr[custom_field + "_url"]);
                member_card_dic.Add(custom_field, custom_field_did);
            }
            string custom_cell = string.Format("custom_cell{0}", i);

            if (!string.IsNullOrEmpty(Convert.ToString(dr[custom_cell + "_name"])))
            {
                Dictionary<string, object> custom_cell_dic = new Dictionary<string, object>();
                custom_cell_dic.Add("name", dr[custom_cell + "_name"]);
                custom_cell_dic.Add("tips", dr[custom_cell + "_tips"]);
                custom_cell_dic.Add("url", dr[custom_cell + "_url"]);
                member_card_dic.Add(custom_cell, custom_cell_dic);
            }
        }

        string url = string.Format("https://api.weixin.qq.com/card/create?access_token={0}", GetToken(Convert.ToString(dr["configkey"])));
        string rt = PostFunction(url, JsonConvert.SerializeObject(postdate_dic));
        Dictionary<string, object> dresult = JsonConvert.DeserializeObject<Dictionary<string, object>>(rt);
        int errcode = Convert.ToInt32(dresult["errcode"]);
        if (errcode == 0)
        {
            string card_id = dresult["card_id"].ToString();
            using (LiLanzDALForXLM dal = new LiLanzDALForXLM(wxconn))
            {
                errInfo = dal.ExecuteNonQuery(string.Format("update wx_T_vipCardInfo set card_id='{0}' where id={1}", card_id, id));
                if (errInfo != "")
                {
                    rt = rtjson(1, "", "卡片创建成功,更新本地数据出错：" + errInfo);
                }
                else
                {
                    //此卡为一键激活，还必须设置必填项
                    errcode = activateuserform(card_id, Convert.ToString(dr["configkey"]));
                    if (errcode == 0) rt = rtjson(0, "", "");
                    else rt = rtjson(2, "", "卡片创建成功,设定会员卡激活必填项出错");
                }
            }
        }
        else
        {
            rt = rtjson(errcode, "", Convert.ToString(dresult["errmsg"]));
        }
        clsSharedHelper.DisponseDataTable(ref dt);
        clsSharedHelper.WriteInfo(rt);
    }

    public void cardUpdate()
    {
        String id = Convert.ToString(HttpContext.Current.Request.Params["id"]);
        if (string.IsNullOrEmpty(id))
        {
            clsSharedHelper.WriteInfo(rtjson(101, "", "缺少必要参数"));
            return;
        }
        String errInfo, mysql = string.Format("SELECT * FROM wx_T_vipCardInfo WHERE id={0}", id);
        DataTable dt;
        using (LiLanzDALForXLM dal = new LiLanzDALForXLM(wxconn))
        {
            errInfo = dal.ExecuteQuery(mysql, out dt);
        }

        if (errInfo != "")
        {
            errInfo = rtjson(102, "", errInfo);
            clsSharedHelper.WriteInfo(errInfo);
        }
        else if (dt.Rows.Count < 1)
        {
            errInfo = rtjson(102, "", "单据不存在");
            clsSharedHelper.WriteInfo(errInfo);
        }
        DataRow dr = dt.Rows[0];

        Dictionary<string, object> postdate_dic = new Dictionary<string, object>();
        Dictionary<string, object> member_card_dic = new Dictionary<string, object>();
        Dictionary<string, object> base_info_dic = new Dictionary<string, object>();

        postdate_dic.Add("card_id", dr["card_id"]);
        postdate_dic.Add("member_card", member_card_dic);
        if (!string.IsNullOrEmpty(Convert.ToString(dr["background_pic_url"])))
        {
            member_card_dic.Add("background_pic_url", dr["background_pic_url"]);
        }
        member_card_dic.Add("base_info", base_info_dic);
        base_info_dic.Add("title", dr["title"]);
        base_info_dic.Add("logo_url", dr["logo_url"]);
        base_info_dic.Add("notice", dr["notice"]);
        base_info_dic.Add("description", dr["description"]);
        base_info_dic.Add("color", dr["color"]);
        base_info_dic.Add("center_title", dr["center_title"]);
        base_info_dic.Add("center_sub_title", dr["center_sub_title"]);
        base_info_dic.Add("center_url", dr["center_url"]);
        base_info_dic.Add("code_type", dr["code_type"]);

        Dictionary<string, object> pay_info = new Dictionary<string, object>();
        Dictionary<string, object> swipe_card = new Dictionary<string, object>();
        base_info_dic.Add("pay_info", pay_info);
        pay_info.Add("swipe_card", swipe_card);
        swipe_card.Add("is_swipe_card", Convert.ToBoolean(dr["is_swipe_card"]));

        Dictionary<string, string> date_info = new Dictionary<string, string>();
        date_info.Add("type", "DATE_TYPE_PERMANENT");
        base_info_dic.Add("date_info", date_info);

        base_info_dic.Add("get_limit", dr["get_limit"]);
        base_info_dic.Add("can_share", dr["can_share"]);
        base_info_dic.Add("can_give_friend", dr["can_give_friend"]);
        base_info_dic.Add("need_push_on_view", dr["need_push_on_view"]);

        member_card_dic.Add("prerogative", dr["prerogative"]);
        member_card_dic.Add("supply_bonus", dr["supply_bonus"]);
        member_card_dic.Add("wx_activate", dr["wx_activate"]);
        member_card_dic.Add("wx_activate_after_submit", dr["wx_activate_after_submit"]);
        member_card_dic.Add("wx_activate_after_submit_url", dr["wx_activate_after_submit_url"]);

        member_card_dic.Add("supply_balance", false);
        member_card_dic.Add("discount", dr["discount"]);

        for (int i = 1; i < 2; i++)
        {
            string custom_field = string.Format("custom_field{0}", i);
            if (!string.IsNullOrEmpty(Convert.ToString(dr[custom_field + "_url"])))
            {

                Dictionary<string, object> custom_field_did = new Dictionary<string, object>();
                custom_field_did.Add("name_type", dr[custom_field + "_name_type"]);
                custom_field_did.Add("url", dr[custom_field + "_url"]);
                member_card_dic.Add(custom_field, custom_field_did);
            }
            string custom_cell = string.Format("custom_cell{0}", i);

            if (!string.IsNullOrEmpty(Convert.ToString(dr[custom_cell + "_name"])))
            {
                Dictionary<string, object> custom_cell_dic = new Dictionary<string, object>();
                custom_cell_dic.Add("name", dr[custom_cell + "_name"]);
                custom_cell_dic.Add("tips", dr[custom_cell + "_tips"]);
                custom_cell_dic.Add("url", dr[custom_cell + "_url"]);
                member_card_dic.Add(custom_cell, custom_cell_dic);
            }
        }
      
        string url = string.Format("https://api.weixin.qq.com/card/update?access_token={0}", GetToken(Convert.ToString(dr["configkey"])));

        string rt = PostFunction(url, JsonConvert.SerializeObject(postdate_dic));

        Dictionary<string, object> dresult = JsonConvert.DeserializeObject<Dictionary<string, object>>(rt);
        int errcode = Convert.ToInt32(dresult["errcode"]);

        if (errcode == 0)
        {
            if (Convert.ToBoolean(dresult["send_check"]))//需要审核
            {
                using (LiLanzDALForXLM dal = new LiLanzDALForXLM(wxconn))
                {
                    dal.ExecuteNonQuery(string.Format("update wx_T_vipCardInfo set card_status='' where id={0}", id));
                }
            }
        }
        else
        {
            rt = rtjson(errcode, "", Convert.ToString(dresult["errmsg"]));
        }
        clsSharedHelper.DisponseDataTable(ref dt);
        clsSharedHelper.WriteInfo(rt);
    }

    private string cardInfoJson()
    {
        return "";
    }

    /// <summary>
    /// 设定必填字段
    /// </summary>
    /// <param name="card_id"></param>
    /// <param name="configkey"></param>
    /// <returns></returns>
    private int activateuserform(String card_id, String configkey)
    {
        string errInfo;
        int errcode;
        Dictionary<string, object> deuserform = new Dictionary<string, object>();
        Dictionary<string, object> required_form = new Dictionary<string, object>();
        deuserform.Add("card_id", card_id);
        deuserform.Add("required_form", required_form);

        required_form.Add("can_modify", true);
        List<String> common_field_id_list = new List<string>();
        common_field_id_list.Add("USER_FORM_INFO_FLAG_MOBILE");
        common_field_id_list.Add("USER_FORM_INFO_FLAG_SEX");
        common_field_id_list.Add("USER_FORM_INFO_FLAG_NAME");
        common_field_id_list.Add("USER_FORM_INFO_FLAG_BIRTHDAY");
        required_form.Add("common_field_id_list", common_field_id_list);
        string url = string.Format("https://api.weixin.qq.com/card/membercard/activateuserform/set?access_token={0}", GetToken(configkey));
        string rt = PostFunction(url, JsonConvert.SerializeObject(deuserform));
        Dictionary<string, object> dresult = JsonConvert.DeserializeObject<Dictionary<string, object>>(rt);
        errcode = Convert.ToInt32(dresult["errcode"]);
        if (errcode == 0)
        {
            using (LiLanzDALForXLM dal = new LiLanzDALForXLM(wxconn))
            {
                errInfo = dal.ExecuteNonQuery(string.Format("update wx_T_vipCardInfo set is_activateuserform=1 where card_id='{0}'", card_id));
            }
            if (errInfo != "") errcode = 1;
        }
        return errcode;
    }
    //统一返回格式
    public string rtjson(int errcode, object data, string errmeg)
    {
        Dictionary<string, object> drt = new Dictionary<string, object>();
        drt.Add("errcode", errcode);
        drt.Add("data", data);
        drt.Add("errmeg", errmeg);
        return JsonConvert.SerializeObject(drt);
    }
    //获取ACCESS_TOKEN
    public string GetToken(string configkey)
    {
        string _AT = "";
        using (LiLanzDALForXLM dal23 = new LiLanzDALForXLM( wxconn.Replace("tlsoft","weChatTest")))
        {
            string str_sql = "select top 1 accesstoken from wx_t_tokenconfiginfo where configkey='" + configkey + "'";
            object scaler = null;
            string errinfo = dal23.ExecuteQueryFast(str_sql, out scaler);
            if (errinfo == "")
            {
                _AT = Convert.ToString(scaler);
            }
            else
                clsLocalLoger.Log("查询ACCESS_TOKEN时出错 ConfigKey:" + configkey + " " + errinfo);
        }

        return _AT;
    }
    public string PostFunction(string url, string postJson)
    {
        string Result = "";
        string serviceAddress = url;
        HttpWebRequest request = (HttpWebRequest)WebRequest.Create(serviceAddress);

        request.Method = "POST";
        request.ContentType = "application/json";
        string strContent = postJson;
        using (StreamWriter dataStream = new StreamWriter(request.GetRequestStream()))
        {
            dataStream.Write(strContent);
            dataStream.Close();
        }
        HttpWebResponse response = (HttpWebResponse)request.GetResponse();
        string encoding = response.ContentEncoding;
        if (encoding == null || encoding.Length < 1)
        {
            encoding = "UTF-8"; //默认编码  
        }
        // Encoding.GetEncoding(encoding)
        StreamReader reader = new StreamReader(response.GetResponseStream());
        Result = reader.ReadToEnd();
        Console.WriteLine(Result);
        return Result;

    }

    public bool IsReusable
    {
        get
        {
            return false;
        }
    }
}
