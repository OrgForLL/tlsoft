<%@ Page Language="C#" Debug="true" %>
<%@ Import Namespace = "nrWebClass"%>
<%@ Import Namespace = "System.Data.SqlClient"%>
<%@ Import Namespace = "System.Data"%>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">

<script runat="server">
    LiLanzDAL DB;
    protected void Page_Load(object sender, EventArgs e)
    {
        string tag = "";
        int id = 0;
        string url = "";
        int userid = 0;
        SqlParameter[] paramters;
        if (Request.QueryString["c"] != null && Request.QueryString["id"] != null)
        {
            tag = Request.QueryString["c"].ToString();
            id = int.Parse(Request.QueryString["id"].ToString());
            DB = new LiLanzDAL();
            paramters = new SqlParameter[]{
                new SqlParameter("@tag", tag),
                new SqlParameter("@id", id)
            };
            using (SqlDataReader read = DB.ExecuteReader(@"select tag,userid,url,id,docid from mobileLoginInfo where tag=@tag and id=@id",
                CommandType.Text, paramters))
            {
                if (read.Read())
                {
                    userid = int.Parse(read[1].ToString());
                    url = read[2].ToString();
                    Session["docid"] = read[4].ToString();
                }
            }
        }
        if (Request.Form["password"] != null)
        {
            if (userid != 0)
            {
                paramters = new SqlParameter[]{
                    new SqlParameter("@id", userid),
                    new SqlParameter("@pwd", Security.String2MD5(Request.Form["password"].ToString()))
                };
                using (SqlDataReader read = DB.ExecuteReader("select id,cname from t_user where id=@id and pass=@pwd",
                    CommandType.Text, paramters))
                {
                    if (read.Read())
                    {
                        Session["userid"] = read[0].ToString();
                        Session["username"] = read[1].ToString();
                        Response.Redirect(url);
                    }
                    else
                    {
                        Label1.Text = "密码有误!";
                    }
                }
            }
            else
            {
                Response.Write("there are something wrong!");
            }
        }
    }
</script>

<html>
<head runat="server">
    <meta charset="utf-8">
    <!-- Need to get a proper redirect hooked up. Blech. -->
    <meta name="robots" content="noindex, follow">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title>登录</title>
    <link rel="stylesheet"  href="css/themes/default/jquery.mobile-1.3.1.min.css">
    <link rel="stylesheet" href="http://fonts.googleapis.com/css?family=Open+Sans:300,400,700">
    <script src="js/jquery.js"></script>
    <script src="js/jquery.mobile-1.3.1.min.js"></script>
    <style type="text/css">
	p {
		font-size: 1.5em;
		font-weight: bold;
	}
	#submit{
		float:right; margin:10px; 
	}
	#toregist{
		float:left; margin:10px; 
	}
	</style>
    <script type="text/javascript">
        jQuery(document).ready(function () {
            //提交
            //$("#submit").bind("click", function () {
                //if (valid()) {
           //     alert("go");
            //    $("#loginform").submit();
                //}
            //});
        });
        function submitForm() {
            $("#loginform").submit();
        }
		//输入信息验证
		function valid(){
			if($("#password").attr("value")=='')
			{
				return false;			
			} 
			return true;         };
        function ColseWin() {
            var opened = window.open('about:blank', '_self');
            opened.opener = null;
            opened.close();
        }
        function send() {
            $("#action").val("send");
            $("#form1").submit();
        }
	</script>
</head>
<body>
<!-- begin first page -->
<section id="page1">
  <header data-role="header"  data-theme="b" ><h4>登录</h4></header>
  <div data-role="content" class="content">
    <p style="backg"><font color="#2EB1E8" >登录协同移动OA系统</font></p>
    <form method="post" id="loginform" action="#" data-ajax="false">
	    	<fieldset data-role="controlgroup" >
				<label for="password">请输入系统登录密码:</label>
	    	    <input type="password" name="password" id="password" value="" autocomplete="off"/>
            </fieldset>
		    <a data-role="button" id="submit" data-theme="b" href="javascript:submitForm()">登录</a>
    </form>
  </div>
   <div data-role="content">
      <p class="ui-body-d" style="padding:1.2em;">  <asp:Label ID="Label1" runat="server" Text=""></asp:Label></p>
   </div>
  <footer data-role="footer" ><h4>协同移动OA系统</h4></footer>
</section>
<!-- end first page -->
</body>
</html>
