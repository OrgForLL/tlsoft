<%@ Page Language="C#" ContentType="text/html" ResponseEncoding="utf-8" Debug="true"
    EnableViewState="false" %>

<%@ Import Namespace="System.Data" %>
<%@ Import Namespace="System.Data.SqlClient" %>
<%@ Import Namespace="System.IO" %>
<%@ Import Namespace="System.Xml" %>
<%@ Import Namespace="System.Data.Common" %>

<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">

<script runat="server">
    public int bs = 1;
    TLBaseData._MyData sqlHelp = new TLBaseData._MyData();
    public StringBuilder STR = new StringBuilder();
    public StringBuilder STRA = new StringBuilder();
    int i;
    string err = "";
    string randomCode = "";
    //Request.QueryString.Get("id").ToString();
    protected void Page_Load(object sender, EventArgs e)
    {
        string allChar = "0,1,2,3,4,5,6,7,8,9,A,B,C,D,E,F,G,H,I,J,K,L,M,N,O,P,Q,R,S,T,U,W,X,Y,Z,a,b,c,d,e,f,g,h,i,j,k,l,m,n,o,p,q,r,s,t,u,v,w,x,y,z";
        string[] allCharArray = allChar.Split(',');


        int temp = -1;
        Random rand = new Random();
        for (int i = 0; i < 4; i++)
        {
            if (temp != -1)
            {
                rand = new Random(i * temp * ((int)DateTime.Now.Ticks));
            }
            int t = rand.Next(61);
            if (temp == t)
            {
                //return 1; 
            }
            temp = t;
            randomCode += allCharArray[t];
        }
        //return randomCode;

        textinput5.Value = randomCode.ToString();
          
       // String type = Request.QueryString[""]
        IDataReader reader = (IDataReader)sqlHelp.MyDataRead(sqlHelp.GetConn(), "select wxid from wx_t_wxyhxx where wxid='123456'");
        while (reader.Read())
        {
            STR.AppendFormat("{0}", reader[0]);
        }
        if (!Page.IsPostBack)
        { //直接传wxid 直接用在微信账号
           
           
        }
        else 
        {
            if (bs == 1) { Response.Write(1); }
            
           /* if(radio.checked="checked"){
                  IDataReader reader1 = (IDataReader)sqlHelp.MyDataRead(sqlHelp.GetConn(), "select phone from wx_t_wxyhxx where wxid='123456'");
                      while (reader.Read())
                      {
                           STRA.AppendFormat("{0}", reader[0]);
                       }
                  IDataReader reader2 = (IDataReader)sqlHelp.MyDataRead(sqlHelp.GetConn(), "select count(1) from YX_T_Vipkh where yddh='"+STRA.ToString ()+"'");
               
                 if (reader2.Read() != null && textinput5.Value==textinput4.Value)
                  { 
                     err = "erro()";
                 }
            }
            else
           {
                 IDataReader reader1 = (IDataReader)sqlHelp.MyDataRead(sqlHelp.GetConn(), "select kh from wx_t_wxyhxx where wxid='123456'");
                      while (reader.Read())
                      {
                           STRA.AppendFormat("{0}", reader[0]);
                       }
                  IDataReader reader2 = (IDataReader)sqlHelp.MyDataRead(sqlHelp.GetConn(), "select count(1) from YX_T_Vipkh where kh='"+STRA.ToString ()+"'");
               
                 if (reader2.Read() != null && textinput5.Value==textinput4.Value)
                  { 
                     err = "erro()";
                 }
           }*/
        }
    }
</script>

<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
    <meta charset="utf-8">
    <!-- Need to get a proper redirect hooked up. Blech. -->
    <meta name="robots" content="noindex, follow">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title></title>
    <link rel="stylesheet" href="css/themes/default/jquery.mobile-1.3.1.min.css">
    <link rel="stylesheet" href="http://fonts.googleapis.com/css?family=Open+Sans:300,400,700">
    <script src="js/jquery.js"></script>
    <script src="js/jquery.mobile-1.3.1.min.js"></script>
    <style type="text/css">
         .table
    {
		table-layout:fixed;
		text-align:left;

		border:1 solid ;	
		border-collapse:collapse;
	
		

    }
    .div1
    {
       
		margin-left:auto;
		margin-right:auto;

    }
 
    .td1
    {
   
     border-right-style:none;
     background-color:#eeeeee;
    }
     .td2
    {
    
     border-left-style:none;
     background-color:#eeeeee;
    }
    </style>
</head>

  <script language="javascript">
      function button() {
          myform.submit();
      }
      $(document).ready(function () {

      });

      function button1() {

      }
      function erro() {
          alert("关联成功！");
      }

      $(function () {
          $(".type").change(function () {
              var type = $("input[name='s_type']:checked").val();
           //  alert(type)
              document.getElementById("bs").value = type;
//              alert(document.getElementById("bs").value)
          })

      })
 

</script>
<body>
   <form id="myform" runat="server">
<!-- Home -->
<div id="page1" data-role="page">
    <div data-role="header" data-theme="a">
        <h3>
            利郎微信平台
        </h3>
    </div>
    <div data-role="content">
    <table class="table"         
            style="border-radius:50px;-moz-border-radius:50px; height: 23px; width: 172px;" border="1" 
            background-color="#FDFDF0" >

               <tr><td class="style1">微信用户：</td><td class="td2"><%=STR.ToString()%></td></tr>              
     </table>
        <div data-role="fieldcontain">
           <td>
              <legend>关联方式</legend>
              <input type="radio" name="s_type" id="radio-choice-v-2a" value="1" class="type" {if $skillinfo['s_type']==1}checked{/if}>
              <label for="radio-choice-v-2a">手机号</label>
              <input type="radio" name="s_type" id="radio-choice-v-2b" value="2" class="type" {if $skillinfo['s_type']==2}checked{/if}>
              <label for="radio-choice-v-2b">卡号</label>
              
             </td>


            <label for="textinput3">
                手机号码
            </label>
            <input id="textinput3"  runat="server" type="text" placeholder="" value="">bs
       
        <a href="#page1" data-role="button" data-theme="b" >
            获得验证码
        </a>

            <label for="textinput4">
                验证码
            </label>
            <input id="textinput4"  runat="server" type="text" placeholder="" value=""> 
            <input id="textinput5"  runat="server" type="text" placeholder="" value="">   
           <a href="#page1" data-role="button" data-theme="b" id="A1" onclick="button()">
            提交
        </a>  
    </div>
                  <input type="text" value="<%=bs %>" name="bs" id="bs"/>
    <div data-role="footer" data-theme="a" data-position="fixed">
        <h5>
            触屏版|高清版
        </h5>
    </div>
</div>
</form>
</body> 
</html>

