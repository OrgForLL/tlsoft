<%@ Page Language="C#" %>

<%@ Import Namespace="nrWebClass" %>
<%@ Import Namespace="System.Data" %>
<%@ Import Namespace="System.Web" %>
<%@ Import Namespace="System.IO" %>

<%@ Import Namespace="System.Text" %>
<%@ Import Namespace="System.Data.SqlClient" %>
<%@ Import Namespace="System.Collections.Generic" %>
<%@ Import Namespace="Newtonsoft.Json.Linq" %>
<%@ Import Namespace="System.Net" %>
<!DOCTYPE html>
<script runat="server">

    public string jSon = "";
    protected void Page_Load(object sender, EventArgs e) {
        string CONFIGKEY = "101";
        string code = Convert.ToString( Request.Params["code"]);
         //clsSharedHelper.WriteInfo(code);  
        string at = clsWXHelper.GetAT(CONFIGKEY);
         //clsSharedHelper.WriteInfo(at);  
        string url = "https://qyapi.weixin.qq.com/cgi-bin/crm/get_external_contact?access_token={0}&code={1}";
        url = string.Format(url, at, code);
        using (clsJsonHelper jh = clsNetExecute.HttpRequestToWX(url, ""))
        {
           //clsSharedHelper.WriteInfo(jh.jSon);  
            jSon = jh.jSon;
        }

    }

</script>
<html>
<head>
    <meta charset="utf-8" />
    <meta name="viewport" content="width=device-width,initial-scale=1,user-scalable=0,maximum-scale=1" />
    <meta name="format-detection" content="telephone=no" />
    <meta name="apple-mobile-web-app-capable" content="yes" />
    <meta name="apple-mobile-web-app-status-bar-style" content="black" />
    <title>联系人详情</title>
    <link type="text/css" rel="stylesheet" href="../../res/css/StoreSaler/contactDetail.css" />
</head>
<script type='text/javascript' src='../../res/js/jquery.js'></script>
<script type="text/javascript">
   
    $(function () {
                       var  date = <%=jSon %>;
                        url =  date["contact"]["avatar"];
                        $("#photoid").attr("src",url);
                        $("#xm1").text(date["contact"]["name"]);
                        if(date["contact"]["gender"]==1){
                          $("#xb1").text("男");
                        }else{
                          $("#xb1").text("女");
                        }
                        if(date["contact"]["remark"]==""){
                            $("#bz1").hide();
                        }else{
                            $("#bz1").text(date["contact"]["remark"]);
                        } 
                        if(date["contact"]["description"]==""){
                            $("#ms1").hide();
                        }else{
                            $("#ms1").text(date["contact"]["description"]);
                        } 
                        if(date["contact"]["name"]==""){
                            $("#nc1").hide();
                        }else{
                            $("#nc1").text(date["contact"]["name"]);
                        } 
                        //alert(date["contact"]["mobile"]);
                        if(date["contact"]["mobile"]==null){
                            $("#sj2").hide();
                        }else{
                            $("#sj1").text(date["contact"]["mobile"]);
                        } 
                        if(date["contact"]["position"]==null&&date["contact"]["corp_name"]==null){
                            $("#company_info").hide();
                        }
                        
                        if(date["contact"]["position"]==null){
                            $("#gw2").hide();
                        }else{
                            $("#gw1").text(date["contact"]["position"]);
                        } 

                        if(date["contact"]["corp_name"]==null){
                            $("#bm2").hide();
                        }else{
                            $("#bm1").text(date["contact"]["corp_name"]);
                        } 
                        
                        
                       
        
        
                       // $("#sj1").text(date["contact"]["mobile"]);
                       
                       // $("#gw1").text(date["contact"]["position"]);
                        
       })

</script>
<body>
    <div class="page_wrap">
        <div class="top_info">
            <div class="avatar"><img src="" class="avatar" id="photoid" /></div>
            <p class="name" id="xm1">联系人名称</p>
        </div>
        <div class="detail_info" id="basic_info">
            <p class="title">基本信息</p>
            <div class="item_wrap">
                <div class="item">
                    <p class="item_name">性别</p>
                    <div class="item_con">
                        <p  id="xb1"></p>
                        <i class="iconfont icon_arrow_right"></i>
                    </div>
                </div>
                <div class="item">
                    <p class="item_name">昵称</p>
                    <div class="item_con">
                        <p id="nc1">***</p>
                        <i class="iconfont icon_arrow_right"></i>
                    </div>
                </div>
                <div class="item">
                    <p class="item_name">备注</p>
                    <div class="item_con">
                        <p id="bz1">***</p>
                        <i class="iconfont icon_arrow_right"></i>
                    </div>
                </div>
                 <div class="item">
                    <p class="item_name">描述</p>
                    <div class="item_con">
                        <p id="ms1">***</p>
                        <i class="iconfont icon_arrow_right"></i>
                    </div>
                </div>
                <div id="sj2" class="item">
                    <p class="item_name">手机</p>
                    <div  class="item_con">
                        <p id="sj1">***</p>
                        <i class="iconfont icon_arrow_right"></i>
                    </div>
                </div>
            </div>
        </div>
        <div class="detail_info" id="company_info">
            <p class="title">企业信息</p>
            <div id="bm2" class="item_wrap">
                <div class="item">
                    <p class="item_name">部门</p>
                    <div  class="item_con">
                        <p id="bm1">***</p>
                        <i class="iconfont icon_arrow_right"></i>
                    </div>
                </div>
                <div id="gw2" class="item">
                    <p class="item_name">岗位</p>
                    <div  class="item_con">
                        <p id="gw1">***</p>
                        <i class="iconfont icon_arrow_right"></i>
                    </div>
                </div>
                
            </div>
        </div>
    </div>
</body>
</html>