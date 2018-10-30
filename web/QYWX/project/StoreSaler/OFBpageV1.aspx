<%@ Page Title="意见反馈" Language="C#" MasterPageFile="../../WebBLL/frmQQDBase.Master" AutoEventWireup="true" %>

<%@ MasterType VirtualPath="../../WebBLL/frmQQDBase.Master" %>
<%@ Import Namespace="nrWebClass" %>
<%@ Import Namespace="System.Data" %>
<%@ Import Namespace="System.Data.SqlClient" %>
<%@ Import Namespace="System.Collections.Generic" %>
<script runat="server">
    string DBConStr;
    string MyOFBList;
    private const string ConfigKeyValue = "5";	//微信配置信息索引值 
    public List<string> wxConfig;       //微信OPEN_JS 动态生成的调用参数
    protected void Page_PreRender(object sender, EventArgs e)
    {

    }

    //必须在内容页的Load中对Master.SystemID 进行赋值；
    protected void Page_Load(object sender, EventArgs e)
    {
        this.Master.SystemID = "3";
       // this.Master.IsTestMode = true;
    }

</script>
<asp:Content ID="Content1" ContentPlaceHolderID="head" runat="server">
    <link type="text/css" rel="stylesheet" href="../../res/css/font-awesome.min.css" />
    <link type="text/css" rel="stylesheet" href="../../res/css/LeePageSlider.css" />
    <link type="text/css" rel="stylesheet" href="../../res/css/StoreSaler/OFBPage.css" />
</asp:Content>
<asp:Content ID="Content2" ContentPlaceHolderID="ContentPlaceHolder1" runat="server">
    <script src="../../res/js/jquery.js" type="text/javascript"></script>
    <script src="../../res/js/StoreSaler/LocalResizeIMG.js" type="text/javascript"></script>
    <script src="../../res/js/StoreSaler/mobileBUGFix.mini.js" type="text/javascript"></script>
    <script src="../../res/js/StoreSaler/binaryajax.min.js" type="text/javascript"></script>
    <script src="../../res/js/StoreSaler/exif.min.js" type="text/javascript"></script>
    <script src="../../res/js/jweixin-1.0.0.js" type="text/javascript"></script>
    <script src="../../res/js/StoreSaler/fastclick.min.js" type="text/javascript"></script>
    <!--BEGIN dialog1-->
    
    <div class="weui_dialog_confirm" id="dialog1" style="display: none;">
        <div class="weui_mask">
        </div>
        <div class="weui_dialog">
            <div class="weui_dialog_hd">
                <strong class="weui_dialog_title">弹窗标题</strong></div>
            <div class="weui_dialog_bd">
                自定义弹窗内容<br>
                ...</div>
            <div class="weui_dialog_ft">
                <a href="javascript:;" id="dialog_default" class="weui_btn_dialog default">取消</a>
                <a href="javascript:;" id="dialog_primary" class="weui_btn_dialog primary">确定</a>
            </div>
        </div>
    </div>
    <!--END dialog1-->
    <!--BEGIN dialog2-->
    <div class="weui_dialog_alert" id="dialog2" style="display: none;">
        <div class="weui_mask">
        </div>
        <div class="weui_dialog">
            <div class="weui_dialog_hd">
                <strong class="weui_dialog_title">弹窗标题</strong></div>
            <div class="weui_dialog_bd">
                弹窗内容，告知当前页面信息等</div>
            <div class="weui_dialog_ft">
                <a href="javascript:dialog_default(2);" class="weui_btn_dialog primary">确定</a>
            </div>
        </div>
    </div>
    <!--END dialog2-->

    <!--BEGIN actionSheet-->
    <div id="actionSheet_wrap">
        <div class="weui_mask_transition" id="mask"></div>
        <div class="weui_actionsheet" id="weui_actionsheet">
            <div class="weui_actionsheet_menu">
                <div class="weui_actionsheet_cell" id="popularity">流行度</div>
                <div class="weui_actionsheet_cell" id="structure">结构与搭配</div>
                <div class="weui_actionsheet_cell" id="stereotype">版型</div>
                <div class="weui_actionsheet_cell" id="price">价格</div>
                <div class="weui_actionsheet_cell" id="quality">品质</div>
                <div class="weui_actionsheet_cell" id="other">其他</div>
            </div>
            <div class="weui_actionsheet_action">
                <div class="weui_actionsheet_cell" id="actionsheet_cancel">取消</div>
            </div>
        </div>
    </div>
    <!--END actionSheet-->

    <header class="header">
        <i class="fa fa-angle-left" id="backbtn" onclick="GoBack()"> </i><span id="GroupName"></span>
        <span id="rightBtn"> <i onclick="addItem()" class="fa fa-plus "></i></span>
    </header>
    <div id="main" class="wrap-page">
        <!--选择页-->
          <section class="page page" id="page-select">
           <div class="sel_bg">
                 <div class="sel_btn" onclick="selectOFB('1')">质量反馈</div>
                 <div class="sel_btn" onclick="selectOFB('2')">开发建议</div>
                 <div class="sel_btn" onclick="selectOFB('3')">顾客心声</div>
                 <div class="sel_btn" onclick="selectOFB('5')">系统反馈</div>
           </div>
          </section>

        <!--主页-->
        <section class="page page-not-header page-top" id="page-main">
            <div class="container">
              <div class="lmdiv">
                <a href="javascript:;" id="loadmore_btn">- 加载更多 -</a>
              </div>
            </div>
        </section>
        <!--详情页-->
        <section class="page page-not-header page-right" id="detail-page" style="z-index: 0;">
            <div class="detail_container">
                <div id="detail_head">
                
                </div>
                <ul class="picul">
                </ul>
                <div class="detail_content">
                </div>
                <div class="navs">
                    <a  href="javascript:ToComment()";> <i class="fa fa-comment-o" "></i>评论</a>
                    <a  href="javascript:ToThumbs()";> <i class="fa fa-thumbs-o-up"></i><span id="cancelThumbs">取消</span>点赞</a>
                </div>
                <div class="heartNames"><i class="fa fa-heart-o"></i><span id="heartNames"></span></div>
                <div class="comments">
                    <p class="comtitle"><span>评论列表 | </span><span id="commentsCount"> 0</span></p>
                    <div class="comms">
                    </div>
                </div>
            </div>
               <input type="hidden" id="comCountsVal" value="0" />
               <input type="hidden" id="likeNums" value="0" />
               <input type="hidden" id="IsThumbs" value="0" />
        </section>
        <!--编辑页-->
        <section class="page page-not-header page-top" id="edit-page" style="z-index: 0;">
          <div class="edit_container">
            <p class="title">
                添加关联商品</p>
            <div class="chopics">
                <ul class="pics">
                    <li onclick="ScanAddRelated()">扫码添加+</li>
                    <li onclick="InputAddRelated()">输入添加+</li>
                </ul>
            </div>

            <div class="DevelopCategory">
                    <div class="DCategoryBtn" onclick="showActionSheet()" >建议类型<i class="fa fa-chevron-down"> </i><i class="fa fa-chevron-up"> </i></div><div class="DCategory"></div>
                    <input type="hidden" id="DCategoryVal" value="" />
            </div>

            <div class="content">
                <textarea id="content" rows="12" placeholder="在这里写点东西吧....."></textarea>
                <ul class="pics2 floatfix">
                    <li class="chobtn" onclick="chooseFile()">
                        <img src="../../res/img/StoreSaler/cameraicon.jpg" />
                    </li>
                </ul>
            </div>
            <input type="file" id="choosefile" />
        </div>
        </section>
        <input type="hidden" id="minMyID" value="0" />
        <input type="hidden" id="OFBGroupID" value="" />
        <input type="hidden" id="MyDjID" value="0" />
    </div>
    <div class="cominput">
        <input id="comText" type="text" placeholder="我也说两句" />
        <div class="subbtn" onclick="submitCom()">
            提 交</div>
    </div>
    <div class="inputBackground" onclick="otherClick()">
        <div class="inputRelateDiv">
            <input type="text" class="inputRelateInput" id="MyText" />
            <div class="submitBtn" onclick="ToSearchRelate()">
                查 找</div>
        </div>
    </div>
     <div class="weui_toptips weui_warn js_tooltips">格式不对</div>
   <%-- <footer class="footer">
       <div class="copyright">
                &copy;2016 利郎信息技术部
            </div>
    </footer>--%>
    <script type="text/javascript">
        var i = 0;
        var shineLight;
        $(document).ready(function () {
            $(function () {
                FastClick.attach(document.body);
            });
            shineLight = setInterval("shine()", 500);
        });
        function shine() {
            if (i == 0) { $(".sel_btn").css("box-shadow", "0 0 6px #FFF");  i=1; }
            else { $(".sel_btn").css("box-shadow", "0 0 7.5px #FFF"); i=0 }
            if (i > 10) clearInterval(t);
        }
        function selectOFB(OFBGroupID) {
            clearInterval(shineLight);
            var GroupName = "";
            switch (OFBGroupID) {
                case "1": GroupName = "质量反馈"; break;
                case "2": GroupName = "开发建议"; break;
                case "3": GroupName = "顾客心声"; break;
                case "5": GroupName = "系统反馈"; break;
            }
            $("#OFBGroupID").val(OFBGroupID);
            $("#GroupName").html(GroupName);
            $("#page-select").addClass("page-bot");
            $("#page-main").removeClass("page-top");
        }
    </script>
</asp:Content>
