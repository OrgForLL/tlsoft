<%@ Page Language="C#" %>
<%@ Import Namespace="nrWebClass" %>
<%@ Import Namespace="System.Data" %>
<%@ Import Namespace="System.IO" %>
<%@ Import Namespace="System.Drawing" %>
<%@ Import Namespace="System.Data.SqlClient" %>
<%@ Import Namespace="System.Collections.Generic" %>
<%@ Import Namespace="wechat" %>
<%@ Import Namespace="System.Xml" %>
<%@ Import Namespace="System.Xml.Serialization" %>
<%@ Import Namespace="Newtonsoft.Json" %>

<!DOCTYPE html>
<script runat="server">  	   
    string sqlcomm = System.Web.Configuration.WebConfigurationManager.ConnectionStrings["conn"].ToString();

    protected void Page_Load(object sender, EventArgs e)
    {
        int roleID = Convert.ToInt32(Request.Params["roleid"]);
        List<WxModel.menu> menus = AppMenuByRole(roleID);
        
        string rt = JsonConvert.SerializeObject(menus);
        clsSharedHelper.WriteInfo(rt);
    }
   
    public List<WxModel.menu> AppMenuByRole(int roleid)
    {
        return AppMenuByRole(0, roleid);
    }

    public List<WxModel.menu> AppMenuByRole(int parentid, int roleid)
    {
        List<WxModel.menu> menus = new List<WxModel.menu>();
        string mysql = "";
        if (parentid == 0)
            mysql = "SELECT id,cname,icon,sort,url FROM wx_t_menu WHERE ParentID=32 AND IsActive=1 ORDER BY sort";
        else
            mysql = string.Format(@"SELECT a.id,a.cname,a.icon,a.url 
                                         FROM wx_t_menu a INNER JOIN wx_t_role_auth b ON a.id=b.MenuID AND IsActive=1
                                         WHERE  a.ParentID = {0} AND b.RoleID={1} ORDER BY sort", parentid, roleid);
        using (IDataReader reader = DBFactory.dbhelper().ExecuteReader(mysql))
        {
            while (reader.Read())
            {
                WxModel.menu menu = new WxModel.menu();
                menu.Cname = reader["cname"].ToString();
                menu.Icon = reader["icon"].ToString();
                menu.Url = reader["url"].ToString();
                menu.Id = Convert.ToInt32(reader["id"]);
                menu.Note = "";
                menu.SubMenus = AppMenuByRole(Convert.ToInt32(reader["id"]), roleid);
                menus.Add(menu);
            }
        }
        return menus;
    }
    
  /*  public string appMenu(int roleid)
    {
        string rt = @"{{""menus"":[{0}],""webpath"":""{1}""}}";
        string mainMenu = @"{{""Cname"":""{0}"",""rows"":[{1}]}}";
        List<string> mainMenuList = new List<string>();
        string mysql = "SELECT id,cname,icon,sort,url FROM wx_t_menu WHERE ParentID=32 AND IsActive=1 ORDER BY sort";
        using (DataTable dt = DBFactory.dbhelper().ExecuteDataTable(mysql))
        {
            if (dt.Rows.Count == 0) return string.Format(rt,""); ;
            List<WxModel.menu> menus = new List<WxModel.menu>();
            
            foreach (DataRow dr in dt.Rows)
            {
                menus = AppMenuByRole(Convert.ToInt32(dr["id"]), roleid);//获取子菜单列表
                List<string> subMenuList = new List<string>();
                foreach (WxModel.menu menu in menus)
                {
                  subMenuList.Add(Newtonsoft.Json.JsonConvert.SerializeObject(menu));
                }
                string t = string.Join(",", subMenuList.ToArray());
                mainMenuList.Add(string.Format(mainMenu, dr["cname"], t));
            }
        }
        rt = string.Format(rt, string.Join(",", mainMenuList.ToArray()), clsConfig.GetConfigValue("OA_WebPath")+"res/img");
        return rt;
    }
    public List<WxModel.menu> AppMenuByRole(int parentid, int roleid)
    {
        string sqlcomm = string.Format(@"SELECT a.cname,a.icon,a.url 
                                         FROM wx_t_menu a INNER JOIN wx_t_role_auth b ON a.id=b.MenuID
                                         WHERE a.ParentID = {0} AND b.RoleID={1}", parentid, roleid);
        List<WxModel.menu> menus = new List<WxModel.menu>();
        using (IDataReader reader = DBFactory.dbhelper().ExecuteReader(sqlcomm))
        {
            while (reader.Read())
            {
                WxModel.menu menu = new WxModel.menu();
                menu.Cname = reader["cname"].ToString();
                menu.Icon = reader["icon"].ToString();
                menu.Url = reader["url"].ToString();
                menu.Note = "";
                menus.Add(menu);
            }
        }
        return menus;
    }*/
   
</script>

<html lang="en" xmlns="http://www.w3.org/1999/xhtml">
<head id="Head1" runat="server">
    <meta charset="utf-8" />
    <title></title>
</head>
<body>
    <form id="form1" runat="server">
    </form>
</body>
</html>
