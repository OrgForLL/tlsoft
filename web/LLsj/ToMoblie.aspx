<%@ Page Language="C#" Debug="true" %>
<%@ Import Namespace = "nrWebClass"%>
<%@ Import Namespace = "System.Data.SqlClient"%>
<%@ Import Namespace = "System.Data"%>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">

<script runat="server">
    LiLanzDAL DB;
    protected void Page_Load(object sender, EventArgs e)
    {
        Random rnd = new Random();
        string tag = (rnd.Next(0, 999999) + 1000000).ToString().Substring(1,6); //随机数
        int docid = int.Parse(Request.QueryString["docid"].ToString());
        int userid = int.Parse(Request.QueryString["userid"].ToString());
        string url = Request.QueryString["url"].ToString();
        DB = new LiLanzDAL();
        SqlParameter[] paramters = new SqlParameter[]{
                new SqlParameter("@tag", tag),
                new SqlParameter("@docid", docid),
                new SqlParameter("@userid", userid),
                new SqlParameter("@url", url),
            };
        int id = 0;
        int.TryParse(DB.ExecuteScalar(@"INSERT INTO dbo.mobileLoginInfo
               ( tag, userid, url, docid ) VALUES  ( '@tag', @userid,  '@url',  @docid  );SELECT @@IDENTITY",
                    CommandType.Text, paramters).ToString() ,out id);
        if (id != 0)
        {
            //Response.StatusCode = 200;
            url = "http://webt.lilang.com:9001/llsj/m.aspx?c={0}&id={1}";
            url = string.Format(url, tag, id);
            string mess = "您有一笔待审单,请点击"+url+"进行审核!";
        }
        else
            Response.StatusCode = 500;

    }
</script>

<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <title></title>
</head>
<body>
    <form id="form1" runat="server">
    <div>
    
    </div>
    </form>
</body>
</html>
