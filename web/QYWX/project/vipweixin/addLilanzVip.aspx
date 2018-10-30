<%@ Page Language="C#" %>
<%@ Import Namespace="System.Data" %>
<%@ Import Namespace="Newtonsoft.Json" %>
<%@ Import Namespace="Newtonsoft.Json.Linq" %>
<%@ Import Namespace="nrWebClass" %>
<%@ Import Namespace="System.Drawing" %>
<%@ Import Namespace="System.Data.SqlClient" %>
<%@ Import Namespace="System.Collections.Generic" %>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<script runat="server">   
    public string cid = "";
    string DBConStr_tlsoft = "";
    string DBConStr = "";
    public string openid = "";
    private const string ConfigKeyValue = "5";
    public string msgCode = "0000";

    protected void Page_Load(object sender, EventArgs e)
    {

        System.Random Random = new System.Random();
        msgCode = Random.Next(1000, 9999).ToString();
       DBConStr = ConfigurationManager.ConnectionStrings["Conn_4"].ConnectionString;//62 wechattpromotion
        DBConStr_tlsoft = clsConfig.GetConfigValue("OAConnStr");                   //23

        //��Ȩ
        if (clsWXHelper.CheckUserAuth(ConfigKeyValue, "openid"))
        {
            openid = Convert.ToString(Session["openid"]);
            //��������ռ�
            clsWXHelper.WriteLog(string.Format("openid��{0} ��vipid��{1} �����ʹ���ҳ[{2}]", Convert.ToString(Session["openid"]), Convert.ToString(Session["vipid"])
                    , "VIPע��"));

        }
        
        if (openid == "")
        {
            clsSharedHelper.WriteErrorInfo("��Ȩ���������½���");
            return;
        }

        if (!IsPostBack)
        {
            DataTable dt;
            if (openid == null || openid == "")
            {
                clsSharedHelper.WriteInfo("�Ƿ����ʻ���ʳ�ʱ�����΢�Ź��ں�[������װ]���·��ʣ�");
                return;
            }
            else
            {
                //�ж��Ƿ��Ѿ�ע�����
                string strSQLExists = @"  IF EXISTS (SELECT TOP 1 ID FROM wx_t_vipBinging WHERE wxOpenid=@openid AND VipID>0)
                                    BEGIN
	                                    SELECT -1 as bs		--���Ѿ�ע����ˡ��������ظ�ע��
                                    END
                                    ELSE
                                    BEGIN 
	                                    SELECT 1 as bs		--ע��ɹ�
                                    END";
             
                List<SqlParameter> para = new List<SqlParameter>();
                para.Add(new SqlParameter("@openid", openid));

                using (LiLanzDALForXLM dal = new LiLanzDALForXLM(DBConStr_tlsoft))
                {
                    string eScalar = dal.ExecuteQuerySecurity(strSQLExists, para, out dt);

                    if (eScalar == "")
                    {
                        if (Convert.ToInt32(dt.Rows[0]["bs"]) == -1)
                        {
                            StringBuilder jsOutput = new StringBuilder();
                            //lblInfo.Text = "���Ѿ�ע����ˡ��������ظ�ע�ᣡ";
                            jsOutput.Append(@"swal({ title: ""������ܰ��ʾ"", text: ""-���Ѿ�ע�����-"", type: ""warning"", showCancelButton: false, confirmButtonColor: ""#59a714"", confirmButtonText: ""ȷ��"", closeOnConfirm: true }, function () { WeixinJSBridge.invoke('closeWindow', {}, function (res) {}); });");

                            ClientScript.RegisterClientScriptBlock(this.GetType(), "myAlert", jsOutput.ToString(), true);
                            return;
                        }
                    }
                    //�ж��Ƿ��Ѿ�ע����ˣ���������    
                }
            }
        }
        
    }

</script>
<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <title>��Աע��</title>
    <meta name="viewport" content="width=device-width, initial-scale=1.0, maximum-scale=1.0, user-scalable=no" />
    <style type="text/css">
        *{
            margin: 0;
            padding: 0;
        }
        body {
            font-family: Helvetica,Arial,STHeiTi,"Hiragino Sans GB","Microsoft Yahei","΢���ź�",STHeiti,"����ϸ��",sans-serif;
            font-size: 14px;
            color: #fff;
        }
        .content
        {
            background-image:url(../../res/img/vipweixin/loginbg.jpg); 
            width:100%;
            height:100%;
            position:absolute;
            top:0;
            bottom:0;
        }
        input
        {
            -webkit-appearance:none;
            }
        .header 
        {
            width:100%;
            text-align:center; 
            height:50%;
            display:flex;
            align-items:center;
            justify-content:center;
        }
        .lllogo
        {
            width: 55%;
        }
        .main
        {
          width:100%;   
          height:50%;
        }
       
        .phone_div, .code_div
        {
          width:80%;
          background:rgba(0,0,0,0.4);
          height:50px;
          margin:0 auto;
          border-radius:24px;
          position:relative;
        }
         .moblile_txt, .code_txt
        {
            height:40px;
            line-height:40px;
            border:0 ;
            font-size:14px;
            width:100%;
            display:inline;
            background: transparent;
            margin-left:15px;
            margin-top:5px;
            color:#fff;
        }
        .sendcode_btn
        {
          display:inline;
          height:35px;
          line-height:35px;
          vertical-align:middle;
          font-size:12px;
          margin-left:0;
          width:75px;
          background-color: transparent;
          border:1px solid #d6d6d6;
          color:#ddd;
          -webkit-border-radius:5px;
          border-radius��5px;
          position:absolute;
          top:7.5px;
          right:15px;
        }
        .code_div
        {
          margin-top:16px;
        }
        .submit_div
        {
            height:50px;
            width:80%;
            background:rgba(255,255,255,0.3);
            margin:0 auto;
            border-radius:24px;
            position:relative;
            margin-top:16px;
        }
        
      
        .submit_btn
        {
            width: 100%;
            height: 50px;
            margin: 0 auto;
            margin-bottom: 28px;
            font-size:16px;
            line-height: 50px;
            font-weight: bold;      
            background:transparent;
            color: #ededed;
            border:none;
        }
        .footer 
        {
            position:fixed;
            width:100%;
            text-align:center;
            bottom:8px;
        }
    </style>
</head>
<body >
    <div class="content">
        <div class="header">
            <img class="lllogo" src="../../res/img/vipweixin/lllogo.png">
        </div>
        <div class="main">
            <div class="phone_div">
                <input type="number" class="moblile_txt" placeholder="�������ֻ�����" pattern="[0-9]*" />
                <input type="button" class="sendcode_btn" value="������֤��" />
            </div>
            <div class="code_div"><input type="number" class="code_txt" placeholder="��������֤��" /></div>
            <div class="submit_div" ><input type="button"  class="submit_btn" value="�� �� �� ֤"/></div>
            <div class="footer">
                <p>&copy;2017 ������Ϣ������</p>
            </div>
        </div>
    </div>
    <script type="text/javascript" src="../../res/js/jquery.js"></script>
    <script type="text/javascript" src="../../res/js/LeeJSUtils.min.js"></script>
    <script type="text/javascript">
        $(document).ready(function (e) {
            LeeJSUtils.stopOutOfPage(".content", true);
            //            alert("<%=msgCode %>");
            $(".submit_div").click(function () {
                //�ύ����
                var codeVal = $(".code_txt").val();
                if (codeVal == "<%=msgCode %>") {
                    alert("�ύ����");
                    setTimeout(function () {
                        $.ajax({
                            type: "POST",
                            cache: false,
                            timeout: 10 * 1000,
                            data: { phone: $(".moblile_txt").val(), code: codeVal },
                            contentType: "application/x-www-form-urlencoded; charset=utf-8",
                            url: "vipBingingcoreV1.aspx?ctrl=registervip",
                            success: function (msg) {
                                console.log(msg);
                                var rt = JSON.parse(msg);
                                if (rt.code == "200") {
                                    LeeJSUtils.showMessage("successed", "ע��ɹ�!");
                                    window.location.href = "NewUserCenter.aspx";
                                } else {
                                    LeeJSUtils.showMessage("error", rt.errmsg);
                                }
                            },
                            error: function (XMLHttpRequest, textStatus, errorThrown) {
                                LeeJSUtils.showMessage("error", "���,���粻ͨ��...");
                            }
                        });
                    }, 50);
                } else {
                    LeeJSUtils.showMessage("error", "��֤�����!");
                }
            });

            $(".sendcode_btn").click(function () {
                if (sendSecond > 0) {
                    return false;
                }                         
                //���÷��Ͷ��Žӿ�
                var phone = $(".moblile_txt").val();
                if (phone.length != 11) {
                    LeeJSUtils.showMessage("error", "������11�ֻ�����");
                    return;
                }
                LeeJSUtils.showMessage("loading", "���ŷ�����..");
                setTimeout(function () {
                    $.ajax({
                        type: "POST",
                        cache: false,
                        timeout: 10 * 1000,
                        data: { phone: phone, code: "<%=msgCode %>" },
                        contentType: "application/x-www-form-urlencoded; charset=utf-8",
                        url: "vipBingingcoreV1.aspx?ctrl=sendSMS",
                        success: function (msg) {
                            console.log(msg);
                            var rt = JSON.parse(msg);
                            if (rt.code == "200") {
                                LeeJSUtils.showMessage("successed", "���ͳɹ�!");
                                sendSecond = 30;
                                countDown = setInterval(beginCount, 999);
                            } else {
                                LeeJSUtils.showMessage("error", rt.errmsg);
                                sendSecond = 30;
                            }
                        },
                        error: function (XMLHttpRequest, textStatus, errorThrown) {
                            LeeJSUtils.showMessage("error", "���,���粻ͨ��...");
                        }
                    });
                }, 50);
            });
        });
        var countDown = null;
        var sendSecond = 0;

        function beginCount(s) {
            if (sendSecond <= 0) {
                $(".sendcode_btn").val("������֤��");
                clearInterval(countDown);
            } else {
                sendSecond = sendSecond - 1;
                $(".sendcode_btn").val("("+sendSecond+")����ط�");
            }
        }

        function sendMSM(phoneNumber,code) {
          //  LeeJSUtils.showMessage("loading", "���ڼ��أ����Ժ�...");
            setTimeout(function () {
                $.ajax({
                    type: "POST",
                    cache: false,
                    timeout: 10 * 1000,
                    data: { phone: phoneNumber, code: code },
                    contentType: "application/x-www-form-urlencoded; charset=utf-8",
                    url: "vipBingingcoreV1.aspx?ctrl=sendSMS",
                    success: function (msg) {
                        console.log(msg);
                        
                    },
                    error: function (XMLHttpRequest, textStatus, errorThrown) {
                        LeeJSUtils.showMessage("error", "���,���粻ͨ��...");
                    }
                });
            }, 50);
        }
    </script>
</body>
</html>
