<%@ Page Language="C#" Debug="true"%>
<%@ Import Namespace=" nrWebClass" %>
<%@ Import Namespace="System.Data" %>
<%@ Import Namespace="System.Data.SqlClient" %>
<%@ Import Namespace="System.Collections.Generic" %>

<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<script  runat="server">
    protected void Page_Load(object sender, EventArgs e)
    {
         string gourl = "http://sj.lilang.com:186/mhome/mShowTZ.aspx";
         string _type = "";
         string userid = "0";
         if (Request.Params["type"] != null)
         {
             //20151119����ʱ����Ҫ����sid=sessionID�����ܱ���sessionֵ��
             _type = Request.Params["type"].ToString();
             if (_type.ToLower() == "oa")
             {
                 gourl = "http://oa.lilang.com:8100/LoginRedirest.aspx?sid=sessionID";
             }
             else if (_type.ToLower() == "kaoqindaiban")
             {
                 gourl = "http://sj.lilang.com:186/llsj/approvalList.aspx";
             }
             else if (_type.ToLower() == "menu")
             {
                 gourl = "http://sj.lilang.com:186/llsj/menu.aspx";
             }
             else if (_type.ToLower() == "approvepage")
             {
                 gourl = "http://sj.lilang.com:186/llsj/approve/approvePage.aspx";
             }
         }

         if (clsWXHelper.CheckQYUserAuth(true))
         {
             userid = Convert.ToString(clsWXHelper.GetAuthorizedKey(1));
             if (getUserBaseInfoByLoginId(userid) == "")
             {
                 Response.Redirect(gourl); 
                 //Response.Write(gourl);                
             }
             else
             {
                 Response.Write("��Ȩʧ��");
             }
             
         }         
    }
    public string getUserBaseInfoByLoginId(string userid)
    {       
        using (LiLanzDALForXLM dal = new LiLanzDALForXLM())
        {
            string tsxx = "";
            DataTable dt = null;
            // String sql = "select top 1 isnull(qx,0) qx,id as userid,name as username,cname,unid from t_user where name='" + UID + "'";
            //���²�ѯ�����Ա�֧�ֺ����û��� By:xlm 20160727
            String sql = @"select a.qx,a.id as userid,a.name as username,a.unid,a.cname from t_user a where a.id='" + userid + "'";
 
            String err = dal.ExecuteQuery(sql, out dt);
            if (err == "")
            {
                if (dt.Rows.Count > 0)
                {
                    Session["qx"] = dt.Rows[0]["qx"].ToString().Trim();
                    Session["userid"] = dt.Rows[0]["userid"].ToString();
                    Session["username"] = dt.Rows[0]["cname"].ToString();
                    Session["unid"] = dt.Rows[0]["unid"].ToString();
                    Session["user"] = dt.Rows[0]["cname"].ToString();
                    Session["zbid"] = 1;
                }
                else
                {
                    //�û�������
                    tsxx = "�û�������";
                }
            }
            else
            {
                tsxx = "��ѯ�쳣";
            }
            return tsxx;
        }
    }
</script>
<html xmlns="http://www.w3.org/1999/xhtml">
<head id="Head1" runat="server">
    <title>��¼</title>

</head>
<body>

</body>
</html>
