<%@ Page Language="C#" debug="true"%>
<%@ Import Namespace = "System.Data.Common"%>
<%@ Import Namespace="System.Data" %>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">

<script runat="server">
    nrWebClass.LiLanzDAL sqlhelper = new nrWebClass.LiLanzDAL();
    protected void Page_Load(object sender, EventArgs e)
    {
        string tzid = Session["userssid"].ToString();
        string zbid = Session["zbid"].ToString();
        int flow_docID = int.Parse(Request.Form["docid"].ToString());
        string username = Session["username"].ToString();
        int userid = int.Parse(Session["userid"].ToString());
        string xtlb = Session["xtlb"].ToString();
       
        if (Request.Form["action"] != null)
        {
            if (Request.Form["action"].ToString() == "send")
            {
                int flow_nextNode = int.Parse(Request.Form["AduitNode"].ToString());
                int flow_nextNodeUser = int.Parse(Request.Form["Auditer"].ToString());
                string flow_opinion = Request.Form["textNote"].ToString(); //审批意见
                int flow_currentNode = int.Parse(Request.Form["nodeid"].ToString()); //申请审批节点id
                string flow_pldocid = "";//批量审批文档id
                string comm = "select currentNode from fl_t_flowRelation where docID={0}";
                comm = String.Format(comm, flow_docID);
                using (IDataReader dr = sqlhelper.ExecuteReader(comm))
                {
                    if (dr.Read())
                    {
                        if (flow_currentNode != int.Parse(dr[0].ToString()))
                        {
                            Response.Write("出错了!");
                            Response.StatusCode = 500;
                            Response.End();
                        }
                    }
                }
                if (Request.Form["IsEnd"] == null)
                {
                    comm = @"DECLARE @result int ; EXEC @result=flow_up_sendNextSingle '{0}', '{1}', '{2}', 
                         '{3}', '{4}', '{5}', '{6}', '{7}', '{8}', '{9}';SELECT @result ;";
                    comm = string.Format(comm, flow_docID, flow_nextNode, flow_nextNodeUser, flow_opinion,
                        username, userid, tzid, zbid, xtlb, flow_pldocid);
                }
                else
                {
                    comm = @"DECLARE @result int ; EXEC @result=flow_up_end {0},{1},'{2}',{3},{4},'{5}','{6}','{7}' ; SELECT @result ;";
                    comm = string.Format(comm, flow_docID, userid,
                        username, tzid, zbid, xtlb, flow_opinion, flow_pldocid);
                }
                if ((int)sqlhelper.ExecuteScalar(comm) == 1)
                    Label1.Text = "办理成功!请点击左上角关闭按钮退出.";
                else
                    Label1.Text = "办理失败!请点击左上角关闭按钮退出."; ; 
                //Page.ClientScript.RegisterClientScriptBlock(this.GetType(), "Test", "alert('Hi');", true);
            }
        }
    }
</script>

<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <title></title>
    <script>
        $(document).bind('mobileinit', function () {
			//$.mobile.ajaxEnabled = false;
        });
    </script>
</head>
<body>
	<form id="form1" runat="server">
	<!-- Home -->
	<div data-role="page" id="page1">
		<div data-theme="a" data-role="header" data-mini="true">
			<a data-role="button" href="approvalList.aspx" class="ui-btn-left" data-icon="delete" data-ajax="false" >
			   返回
			</a>
			<h3>
				单据审批
			</h3>
		</div>
		<div data-role="content">
            <p class="ui-body-d" style="padding:2em;">  <asp:Label ID="Label1" runat="server" Text="Label"></asp:Label><a href="#" data-rel="popup" data-role="button" class="ui-icon-alt" data-inline="true" data-transition="pop" data-icon="info" data-theme="e" data-iconpos="notext">Learn more</a></p>
            <div data-role="popup" id="popupInfo" class="ui-content" data-theme="e" style="max-width:350px;">
              <p>Here is a <strong>tiny popup</strong> being used like a tooltip. The text will wrap to multiple lines as needed.</p>
            </div>
	    </div>
	<div data-theme="a" data-role="footer" data-position="fixed" data-mini="true">
        <h5>
            协同移动办公
        </h5>
    </div>
	
	</div>
    </form>
</body>
</html>
