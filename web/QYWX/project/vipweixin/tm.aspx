<%@ Page Language="C#" ContentType="text/html" ResponseEncoding="utf-8" %>
<%@ Import Namespace="System.IO" %>
<%@ Import Namespace="System.Data" %>
<%@ Import Namespace="System.Data.SqlClient" %>
<%@ Import Namespace="System.Net" %>
<%@ Import Namespace="Newtonsoft.Json" %>
<%@ Import Namespace="System.Collections.Generic" %>
<%@ Import Namespace="nrWebClass" %>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<script runat="server">
    public string picID = "0";
    public string maintain = "";
    protected void Page_Load(object sender, EventArgs e)
    {
        /*
         * 条码打错，错误条件直接执行网站,oa 审批单 4QJK0061A160100001 
         */
        /*if (nrWebClass.QueryString.Q("id") == "8777787V808V77N2YC")
        {
            Response.Redirect("http://www.lilanz.com");
            Response.End();
        }*/
        //DAL.SqlDbHelper dbHelper = new DAL.SqlDbHelper("1");
        //dbHelper.ConnectionString = "server=192.168.35.10;database=tlsoft;uid=ABEASD14AD;pwd=+AuDkDew;Connect Timeout=2;Pooling=true;Max Pool Size=5;";
        //    dbHelper.ConnectionString = clsConfig.GetConfigValue("OA_WebPath");

        DataTable dt = null;
        string ConOA = clsConfig.GetConfigValue("OAConnStr");
        string sphh = "";
        using (LiLanzDALForXLM zdal = new LiLanzDALForXLM(ConOA))
        {
            string sql = "EXEC wx_up_BarcodeCheck @id";
            List<SqlParameter> lstParams = new List<SqlParameter>();
            lstParams.Add(new SqlParameter("@id", nrWebClass.QueryString.Q("id")));
            string strInfo = zdal.ExecuteQuerySecurity(sql, lstParams, out dt);
            if (strInfo != "")
            {
                clsLocalLoger.WriteError("[商品扫码]获取商品信息出错！错误：" + strInfo);
                clsSharedHelper.WriteInfo("系统繁忙，暂时无法获取商品信息！请稍后重试！");
                return;
            }
            if (dt.Rows.Count == 0)
            {
                WriteLog("[商品扫码]无效码:" + Request.QueryString["id"].ToString());
                Info.Text = "商品信息库无此款号信息，请谨慎购买！";
                clsSharedHelper.DisponseDataTable(ref dt);
                return;
            }

            DataRow result = dt.Rows[0];
            sphh = result["sphh"].ToString();
            Info.Text = result["sphh"].ToString();
            itemName.Text = result["spmc"].ToString();
            LabelCode.Text = result["cmmc"].ToString();
            color.Text = result["color"].ToString();
            picID = result["id"].ToString();

            lstParams.Clear();
            lstParams.Add(new SqlParameter("@ip", Request.ServerVariables["REMOTE_ADDR"]));
            lstParams.Add(new SqlParameter("@barcode", result["barcode"]));

            Session["barcode"] = result["barcode"].ToString();

            zdal.ExecuteNonQuerySecurity(@"insert into [wx_t_barCodeRecord] (ipAddr,BarCode) values (@ip, @barcode)", lstParams);

            string spid = Convert.ToString(Request.Params["id"]);
            //2017-05-20 小朱反应说7Q的杯子吊牌上的二维码印错，有在错误表中的货号都直接跳转到利郎官网                
            if (!string.IsNullOrEmpty(spid))
            {
                if (isInErrorLabel(spid))
                {
                    Response.Redirect("http://www.lilanz.com");
                    Response.End();
                }
                else
                {
                    Response.Redirect("http://tm.lilanz.com/OA/project/StoreSaler/goodsListV7.aspx?sphh=" + sphh);
                    Response.End();
                }
            }
        }

        //if (sphh.Length > 0)
        //{
        //    sql = String.Format("select maintain_url,maintain from yx_t_cpinfo where sphh='{0}'", sphh);
        //    result = dbHelper.ExecuteReader(sql, CommandType.Text);
        //    if (result.Read())
        //    {
        //        maintain = String.Format("<div><li><a href=\"{0}\">{1}</a></li></div>", result[0], result[1]);
        //        WriteLog(maintain);
        //    }
        //    result.Close();
        //    result.Dispose();
        //}
    }
    ///
    /// 写日志(用于跟踪)
    ///
    private void WriteLog(string strMemo)
    {
        if (strMemo.Contains("错误")) clsLocalLoger.WriteError(string.Concat("[商品扫码]", strMemo));
        else clsLocalLoger.WriteInfo(string.Concat("[商品扫码]", strMemo));
        //string filename = Server.MapPath(@"./logs/log.txt");
        //if (!Directory.Exists(Server.MapPath(@"/logs/")))
        //    Directory.CreateDirectory(@"/logs/");
        //StreamWriter sr = null;
        //try
        //{
        //    if (!File.Exists(filename))
        //    {
        //        sr = File.CreateText(filename);
        //    }
        //    else
        //    {
        //        sr = File.AppendText(filename);
        //    }
        //    sr.WriteLine(DateTime.Now.ToString("[yyyy-MM-dd HH:mm:ss] "));
        //    sr.WriteLine(strMemo);
        //}
        //catch
        //{
        //}
        //finally
        //{
        //    if (sr != null)
        //        sr.Close();
        //}

    }
    private string HttpRequest(string url)
    {
        HttpWebRequest request = (HttpWebRequest)HttpWebRequest.Create(url);
        request.ContentType = "application/x-www-form-urlencoded";

        HttpWebResponse myResponse = (HttpWebResponse)request.GetResponse();
        StreamReader reader = new StreamReader(myResponse.GetResponseStream(), Encoding.UTF8);
        return reader.ReadToEnd();//得到结果
    }

    //将唯一码转成商品货号
    public bool isInErrorLabel(string code)
    {
        bool rt = false; 
        string ConOA = clsConfig.GetConfigValue("OAConnStr");
        using (LiLanzDALForXLM dal = new LiLanzDALForXLM(ConOA))
        {
            string str_sql = @"declare @strGood varchar(30); 
                                select @strGood=dbo.f_DBPwd(@code);
                                select @strGood = (CASE WHEN (LEN(@strGood) > 13) THEN SUBSTRING(@strGood, 1, LEN(@strGood) - 6) ELSE @strGood END);
                                select top 1 @strGood = a.sphh from yx_t_tmb a where tm=@strGood; 
                                select count(id) from yx_t_qrczh where sphh=@strGood and ty=0;";
            List<SqlParameter> para = new List<SqlParameter>();
            para.Add(new SqlParameter("@code", code));
            object scalar;
            string errinfo = dal.ExecuteQueryFastSecurity(str_sql, para, out scalar);
            if (errinfo == "" && Convert.ToInt32(scalar) > 0)
                rt = true;
        }//end using

        return rt;
    }
</script>
<html xmlns:wb="“http://open.weibo.com/wb”">
<head>
    <meta name="viewport" content="width=device-width, initial-scale=1" />
    <meta http-equiv="Content-Type" content="text/html; charset=utf-8" />
    <script src="http://tjs.sjs.sinajs.cn/open/api/js/wb.js" type="text/javascript" charset="utf-8"></script>
    <title></title>
    <style type="text/css">
        .submitDiv {
            padding-top: 10px;
        }

        .divContent {
            margin-top: 10px;
            border: 1px solid #DDD;
            border-radius: 2px;
            -moz-border-radius: 2px; /* Old Firefox */
            background-color: #000;
            color: #FFF;
        }

        #MobileNumber {
            width: 200px;
            height: 28px;
        }

        #submit {
            height: 32px;
            width: 68px;
        }

        body {
            background-color: #000;
        }

        .common {
            color: #FFF;
            margin-top: 1em;
            border-bottom: #999 dotted 1px;
        }

        .common-content {
            color: #FFF;
        }

        .button {
            display: inline-block;
            position: relative;
            margin: 10px;
            padding: 0 20px;
            text-align: center;
            text-decoration: none;
            text-shadow: 1px 1px 1px rgba(255,255,255,.22);
            font: bold 12px/25px Arial, sans-serif;
            -webkit-border-radius: 30px;
            -moz-border-radius: 30px;
            border-radius: 30px;
            -webkit-box-shadow: 1px 1px 1px rgba(0,0,0,.29), inset 1px 1px 1px rgba(255,255,255,.44);
            -moz-box-shadow: 1px 1px 1px rgba(0,0,0,.29), inset 1px 1px 1px rgba(255,255,255,.44);
            box-shadow: 1px 1px 1px rgba(0,0,0,.29), inset 1px 1px 1px rgba(255,255,255,.44);
            -webkit-transition: all 0.15s ease;
            -moz-transition: all 0.15s ease;
            -o-transition: all 0.15s ease;
            -ms-transition: all 0.15s ease;
            transition: all 0.15s ease;
        }

            .button:hover {
                -webkit-box-shadow: 1px 1px 1px rgba(0,0,0,.29), inset 0px 0px 2px rgba(0,0,0, .5);
                -moz-box-shadow: 1px 1px 1px rgba(0,0,0,.29), inset 0px 0px 2px rgba(0,0,0, .5);
                box-shadow: 1px 1px 1px rgba(0,0,0,.29), inset 0px 0px 2px rgba(0,0,0, .5);
            }

            .button:active {
                -webkit-box-shadow: inset 0px 0px 3px rgba(0,0,0, .8);
                -moz-box-shadow: inset 0px 0px 3px rgba(0,0,0, .8);
                box-shadow: inset 0px 0px 3px rgba(0,0,0, .8);
            }

        /* Big Button Style */

        .big {
            padding: 0 20px;
            padding-top: 10px;
            height: 20px;
            text-transform: uppercase;
            font: bold 14px/14px Arial, sans-serif;
        }

            .big span {
                display: block;
                text-transform: none;
                font: italic normal 12px/18px Georgia, sans-serif;
                text-shadow: 1px 1px 1px rgba(255,255,255, .12);
            }

        /* Green Color */

        .green {
            color: #3e5706;
            background: #a5cd4e; /* Old browsers */
            background: -moz-linear-gradient(top, #a5cd4e 0%, #6b8f1a 100%); /* FF3.6+ */
            background: -webkit-gradient(linear, left top, left bottom, color-stop(0%,#a5cd4e), color-stop(100%,#6b8f1a)); /* Chrome,Safari4+ */
            background: -webkit-linear-gradient(top, #a5cd4e 0%,#6b8f1a 100%); /* Chrome10+,Safari5.1+ */
            background: -o-linear-gradient(top, #a5cd4e 0%,#6b8f1a 100%); /* Opera 11.10+ */
            background: -ms-linear-gradient(top, #a5cd4e 0%,#6b8f1a 100%); /* IE10+ */
            background: linear-gradient(top, #a5cd4e 0%,#6b8f1a 100%); /* W3C */
        }

        /* Blue Color */

        .blue {
            color: #19667d;
            background: #70c9e3; /* Old browsers */
            background: -moz-linear-gradient(top, #70c9e3 0%, #39a0be 100%); /* FF3.6+ */
            background: -webkit-gradient(linear, left top, left bottom, color-stop(0%,#70c9e3), color-stop(100%,#39a0be)); /* Chrome,Safari4+ */
            background: -webkit-linear-gradient(top, #70c9e3 0%,#39a0be 100%); /* Chrome10+,Safari5.1+ */
            background: -o-linear-gradient(top, #70c9e3 0%,#39a0be 100%); /* Opera 11.10+ */
            background: -ms-linear-gradient(top, #70c9e3 0%,#39a0be 100%); /* IE10+ */
            background: linear-gradient(top, #70c9e3 0%,#39a0be 100%); /* W3C */
        }

        /* Gray Color */

        .gray {
            color: #515151;
            background: #d3d3d3; /* Old browsers */
            background: -moz-linear-gradient(top, #d3d3d3 0%, #8a8a8a 100%); /* FF3.6+ */
            background: -webkit-gradient(linear, left top, left bottom, color-stop(0%,#d3d3d3), color-stop(100%,#8a8a8a)); /* Chrome,Safari4+ */
            background: -webkit-linear-gradient(top, #d3d3d3 0%,#8a8a8a 100%); /* Chrome10+,Safari5.1+ */
            background: -o-linear-gradient(top, #d3d3d3 0%,#8a8a8a 100%); /* Opera 11.10+ */
            background: -ms-linear-gradient(top, #d3d3d3 0%,#8a8a8a 100%); /* IE10+ */
            background: linear-gradient(top, #d3d3d3 0%,#8a8a8a 100%); /* W3C */
        }

        .red {
            color: #515151;
            background: #F00; /* Old browsers */
            background: -moz-linear-gradient(top, #F00 0%, #8a8a8a 100%); /* FF3.6+ */
            background: -webkit-gradient(linear, left top, left bottom, color-stop(0%,#F00), color-stop(100%,#8a8a8a)); /* Chrome,Safari4+ */
            background: -webkit-linear-gradient(top, #F00 0%,#8a8a8a 100%); /* Chrome10+,Safari5.1+ */
            background: -o-linear-gradient(top, #F00 0%,#8a8a8a 100%); /* Opera 11.10+ */
            background: -ms-linear-gradient(top, #F00 0%,#8a8a8a 100%); /* IE10+ */
            background: linear-gradient(top, #F00 0%,#8a8a8a 100%); /* W3C */
        }

        .item-pic {
            margin-top: 10px;
        }

        a:link {
            color: #FFF;
        }
    </style>
    <script type="text/javascript">
        var GetQueryParams = function (name) {
            var reg = new RegExp("(^|&)" + name + "=([^&]*)(&|$)", "i");
            var r = window.location.search.substr(1).match(reg);
            if (r != null)
                return unescape(r[2]);
            else
                return "";
        };

        var cid = GetQueryParams("id");
        if (cid != "")
            window.location.href = "http://tm.lilanz.com/OA/project/StoreSaler/goodsListV7.aspx?codeType=qrCode&qrcodeid=" + cid;

        function hasClass(ele, cls) {
            return ele.className.match(new RegExp('(\\s|^)' + cls + '(\\s|$)'));
        }

        function addClass(ele, cls) {
            if (!this.hasClass(ele, cls)) ele.className += " " + cls;
        }

        function removeClass(ele, cls) {
            if (hasClass(ele, cls)) {
                var reg = new RegExp('(\\s|^)' + cls + '(\\s|$)');
                ele.className = ele.className.replace(reg, ' ');
            }
        }
        var BtnSelected = "";
        function BtnSelect(obj) {
            var Btns = ["big", "fit", "small"];
            for (var i = 0; i < Btns.length; i++) {
                removeClass(document.getElementById(Btns[i]), "big");
            }
            addClass(obj, "big");
            BtnSelected = obj.id;
        }
        function Submit() {
            var url = "CustomerReview.ashx?height=" + document.getElementById("txtHigh").value
            + "&weight=" + document.getElementById("txtWeight").value + "&fit=" + BtnSelected;
            ajax(url, {
                success: function (data) {
                    alert(data);
                }
            });
        }
        //定义变量，用来创建xmlhttprequest对象
        function ajax(url, option) {
            var req;
            if (window.XMLHttpRequest) {
                req = new XMLHttpRequest();
            } else if (window.ActiveXObject) {
                req = new ActiveXObject("Microsoft.XMLHttp");
            }

            if (req) {
                req.open("GET", url, true);
                req.onreadystatechange = function () {
                    if (req.readyState == 4) {
                        option.success(req.responseText);
                    }
                };
                req.send(null);
            }
        }
        function WeiXinAddContact() {
            if (typeof WeixinJSBridge == 'undefined') return false;
            WeixinJSBridge.invoke('addContact', {
                webtype: '1',
                username: 'gh_ab53bbf2054d'
            }, function (d) {
                // 返回d.err_msg取值，d还有一个属性是err_desc  
                // add_contact:cancel 用户取消  
                // add_contact:fail　关注失败  
                // add_contact:ok 关注成功  
                // add_contact:added 已经关注  
                //WeixinJSBridge.log(d.err_msg);  
                //alert(d.err_msg);
            });
        };
    </script>
</head>

<body>
    <div>
        <img src="img/logo.gif" width="209" height="26" /></div>
    <br />
    <wb:share-button appkey="LmPmb" addition="full" type="button" default_text="今天通过利郎分享了这件衣服" ralateuid="2009855834"></wb:share-button>
    <div class="divContent">
        <form id="form1" runat="server">
            <div style="border-bottom: #999 1px solid; padding: 5px">款号：<asp:Label ID="Info" runat="server" Text=""></asp:Label></div>
            <div style="border-bottom: #999 1px solid; padding: 5px">品名：<asp:Label ID="itemName" runat="server" Text=""></asp:Label></div>
            <div style="border-bottom: #999 1px solid; padding: 5px">颜色：<asp:Label ID="color" runat="server" Text=""></asp:Label></div>
            <div style="border-bottom: #999 1px solid; padding: 5px">商标：利郎</div>
            <div style="border-bottom: #999 1px solid; padding: 5px">尺码：<asp:Label ID="LabelCode" runat="server" Text=""></asp:Label></div>
            <div style="border-bottom: #999 1px solid; padding: 5px">查询次数：</div>
            <div>
            </div>
        </form>
    </div>
    <div align="center" class="item-pic">
        <img src="ItemPic.aspx?id=<%=picID%>" />
    </div>
    <%=maintain%>
    <div class="common">评价</div>
    <div class="common-content">
        是否合身:
        <a href="javascript:void(0)" onclick="BtnSelect(this)" id="big" class="button blue">偏大</a>
        <a href="javascript:void(0)" onclick="BtnSelect(this)" id="fit" class="button green">适中</a>
        <a href="javascript:void(0)" onclick="BtnSelect(this)" id="small" class="button gray">偏小</a>
        <br />
        您的身高:
        <input name="txtHigh" id="txtHigh" type="text" size="5" maxlength="5" />
        体重:
        <input name="txtWeight" id="txtWeight" type="text" size="5" maxlength="5" />
    </div>
    <a href="javascript:Submit()" class="button red">提交</a>
    <div class="divContent" style="padding: 5px">
        <img src="img/qrcode_for_vip.jpg" width="100" height="100" />
        利郎vip微信号： 利郎男装
        <p>长摁微信号可复制或扫描二维码关注</p>
    </div>    
</body>
</html>
