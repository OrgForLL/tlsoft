<%@ Page Title="" Language="C#" MasterPageFile="../../WebBLL/frmQQDBase.Master" AutoEventWireup="true" %>
<%@ MasterType VirtualPath="../../WebBLL/frmQQDBase.Master" %>

<%@ Import Namespace="nrWebClass" %>  


<script runat="server">
    /*子页面首先运行Page_Load，再运行主页面Page_Load；因此，只需要在子页面Page_Load事件中对Master.SystemID 进行赋值；
      主页面将会在其Page_Load事件中自动鉴权获取 AppSystemKey.之后请在子页面的Page_PreRender 或 JS中进行相关处理(比如：加载页面内容等)。
      请格外注意：万万不要在子页面的Load事件中直接使用用户的Session，因为Session是在主页面中获取的顺序在后，这将会导致异常！
    
         附：母版页和内容页的触发顺序    
         * 母版页控件 Init 事件。    
         * 内容控件 Init 事件。
         * 母版页 Init 事件。    
         * 内容页 Init 事件。    
         * 内容页 Load 事件。    
         * 母版页 Load 事件。    
         * 内容控件 Load 事件。    
         * 内容页 PreRender 事件。    
         * 母版页 PreRender 事件。    
         * 母版页控件 PreRender 事件。    
         * 内容控件 PreRender 事件。
     */

    protected void Page_PreRender(object sender, EventArgs e)
    {  
       Response.Write(string.Format("qy_customersid ={0} , SystemKey={1} , tzid={2} , mdid={3}",
                        Session["qy_customersid"], this.Master.AppSystemKey, Session["tzid"], Session["mdid"]));
    }

    //必须在内容页的Load中对Master.SystemID 进行赋值；
    protected void Page_Load(object sender, EventArgs e)
    {
        //this.Master.SystemID = "3";     //可设置SystemID,默认为3（全渠道系统）
        //this.Master.AppRootUrl = "../../../";     //可手动设置WEB程序的根目录,默认为 当前页面的向上两级
        
        //统一的后台错误输出方法
        //clsWXHelper.ShowError("错误提示内容121113456，自定义内容");
    }

</script>

<asp:Content ID="Content1" ContentPlaceHolderID="head" runat="server">
</asp:Content>      
<asp:Content ID="Content2" ContentPlaceHolderID="ContentPlaceHolder1" runat="server">
    <input id="Button1" type="button" class="weui_btn weui_btn_plain_default" value="弹出提示2s" onclick="ShowInfo('弹出提示2s');" />
    <input id="Button2" type="button" class="weui_btn weui_btn_plain_primary" value="跳转提示2" onclick="RedirectErr('跳转提示2');" />
    <input id="Button3" type="button" class="weui_btn weui_btn_mini weui_btn_primary" value="弹出等待15s" onclick="ShowLoading('弹出等待15s');" />
    <br/>
    
    <input id="Button4" type="button" value="打开page1" onclick="OpenPage('page1');" />
    <input id="Button5" type="button" value="打开page2" onclick="OpenPage('page2');" />
    
     <script type="text/html" id="page1">
         <div class="page">page1
         </div>
     </script>
     <script type="text/html" id="page2">
         <div class="page">page2
         </div>
     </script>

</asp:Content>
