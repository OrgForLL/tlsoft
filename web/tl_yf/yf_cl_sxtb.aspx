<%@ Page Language="VB" %>
<%@ Import Namespace="System.Data" %>
<%@ Import Namespace="System.Data.SqlClient" %>
<%@ Import Namespace="System.io" %>
<html>
<head>
    <title>图片上传</title>
    <script language="javascript">
        function addFile() {
            //var str = '<INPUT type="file" size="50" NAME="File" onkeypress="event.returnValue=false;"><br>';
            var maxjls = Number(MyForm.maxjls.value) + 1;
            //var str = '<INPUT type="file" NAME="File" style="width:60%" onkeypress="event.returnValue=false;">&nbsp;说明：<INPUT type="text" class="tltext_u" style="width:25%" NAME="bz:'+maxjls.toString()+'">';
            var str = '<INPUT type="file" NAME="File" style="width:80%" onkeypress="event.returnValue=false;">';
            document.getElementById('MyFile').insertAdjacentHTML("beforeEnd", str)
            MyForm.maxjls.value = maxjls;
        }

        function TLBtn_tj() {
            var fileLen = document.getElementsByName("File").length;
            var fileVal = "";
            var typeBs = true;
            for (var i = 0; i < fileLen; i++) {
                fileVal = document.getElementsByName("File").item(i).value;
                if (fileVal != "") {
                    if (!Check_FileType(fileVal)) {
                        typeBs = false;
                    }
                }
            }
            if (typeBs == true) {
                MyForm.hi_mytj.value = "tj";
                MyForm.hi_mycl.value = "add";
                MyForm.btn_up.value = "正在上传";
                MyForm.btn_up.disabled = true;
                document.getElementById("div_bar").innerHTML = "文件正在上传中,请耐心等待...";
                MyForm.submit();
            }
        }


        function Check_FileType(str) {
            var pos = str.lastIndexOf(".");
            var lastname = str.substring(pos, str.length)
            var lowerName = lastname.toLowerCase();
            return true;
        }

        function TL_DownLoad(filename) {
            var MyURL = "cw_ht_download.aspx?fileName=" + filename;
            var win_wh = window.open(MyURL, "", "toolbar=no,location=no,directories=no,status=no,menubar=no,scrollbars=yes,resizable=yes,fullscreen=no,width=450,height=350,top=0,left=0");
            win_wh.focus();
            return false;
        }

        function TL_DelFile(fileID, filename) {
            if (confirm("删除后将不能恢复，确认要删除该文件？")) {
                MyForm.hi_fileID.value = fileID;
                MyForm.hi_filename.value = filename;
                MyForm.hi_mycl.value = "del";
                MyForm.hi_mytj.value = "tj";
                document.getElementById("div_bar").innerHTML = "正在删除文件,请耐心等待...";
                MyForm.submit();
            }
        }
        function open_pdf(value) {
            var MyURL = "../tl_Yf/openFile.aspx?wjpath=" + "/" + value + "&ljcs=../photo/sygzb_pdf";
            window.open(MyURL, "", "top=0, left=0, Height=720, Width=1015,resizable=yes");
        }
    </script>
    <base target="_self" />
    <script runat="server">
    Dim mylink0 As New mylink.mylink
    Dim mylink = mylink0.mylink1()
    Dim myconn As New SqlConnection(mylink)
    Dim TLConn As New SqlConnection(mylink)
    Dim lbdll As New lbclass.lbdll
    Dim lb_tldll As New lbclass.tldll
        </script>
</head>
<body>
    <form method="POST" id="MyForm" name="MyForm" runat="server" enctype="multipart/form-data">
        
      
        <%
            Dim jcjg, tzid, mytj, strID, ghsdm, mlid, dqstep, str_sql, arrDocName, arrFileBz, doclist, namelist, mycl, filePath, delFileName, upFile, upBz, zbid, zd, lx
            Dim i, maxjls, pathname, filePathbak
            Dim ctrl_pathname = Trim(Request.Form("pathname"))
            lx = Trim(Request.QueryString("lx"))
            mytj = Trim(Request.Form("hi_mytj"))
            mycl = Trim(Request.Form("hi_mycl"))
            If mytj = "tj" Then
                If Len(lx) = 0 Then
                    Response.Write("参数有问题.....,请重新登陆！")
                    Response.End()
                ElseIf Trim(Request.Form("pathname")) = "" Then
                    Response.Write("pathname error")
                    Response.End()
                Else
                    'filePath = Server.MapPath("../" + Trim(Request.Form("pathname")) + "/")
                    filePath = Context.Server.MapPath("../../" + Trim(Request.Form("pathname")) + "/")
                    filePathbak = Context.Server.MapPath("../../" + Trim(Request.Form("pathname")) + "/bak/")
                    If mycl = "add" Then
                        Dim files As System.Web.HttpFileCollection = System.Web.HttpContext.Current.Request.Files
                        Dim iFile As System.Int32
                        Dim tempName As String

                        Dim strMsg As New System.Text.StringBuilder("上传的文件分别是：\n")
                        Try
                            For iFile = 0 To files.Count - 1       '上传处理
                                Dim postedFile As System.Web.HttpPostedFile = files(iFile)
                                Dim fileName, fileExtension As System.String
                                Try
                                    fileName = System.IO.Path.GetFileName(postedFile.FileName)
                                Catch Ex As System.Exception
                                    Response.Write("file" + Ex.Message)
                                End Try

                                If Not (fileName = String.Empty) Then
                                    fileExtension = System.IO.Path.GetExtension(fileName)
                                    strMsg.Append("文件名称：" + fileName + "\n")
                                    strMsg.Append("文件后缀：" + fileExtension + "\n\n")
                                    'tempName=ghsdm+"_"+cstr(iFile)+"@"+DateTime.Now.ToFileTime().ToString()+fileExtension
                                    tempName = fileName

                                    'postedFile.SaveAs(System.Web.HttpContext.Current.Request.MapPath("../UpLoadFile/") + tempName)
                                    Dim fi As System.IO.FileInfo = New FileInfo(filePath + tempName)
                                    If fi.Exists Then
                                        If System.IO.Directory.Exists(filePathbak) = False Then
                                            System.IO.Directory.CreateDirectory(filePathbak)
                                        End If
                                        Dim rd As Random = New Random

                                        Try
                                            'fi.MoveTo(filePathbak + tempName + System.DateTime.Now.ToString("yyyyMMddHHmmssff") + rd.Next(0, 999999).ToString())
                                            fi.Delete()
                                        Catch ex As System.Exception
                                            Response.Write("move" + ex.Message)
                                        End Try
                                        Try
                                            postedFile.SaveAs(filePath + tempName)
                                        Catch ex As System.Exception
                                            Response.Write("postsave" + ex.Message)
                                        End Try

                                    Else
                                        postedFile.SaveAs(filePath + tempName)
                                    End If

                                    Response.Write(filePath + tempName)
                                End If
                                'response.write(Left(fileName,InStr(fileName, ".")-1)+"   "+filename+"   "+tempName)
                            Next
                            'undoImpersonation() 
                        Catch Ex As System.Exception
                            Response.Write(Ex.Message + ";" + filePath + tempName)
                        End Try
                        '数据库文件名处理

                    ElseIf mycl = "del" Then
                        str_sql = ""
                        delFileName = Trim(Request.Form("hi_filename"))     '删除
                        'If loginFileServer() Then
                        '   Else
                        '       loginFileServer()
                        'End If
                        Dim File As System.IO.FileInfo = New System.IO.FileInfo(filePath + delFileName)
                        If File.Exists Then
                            File.Delete()
                        End If
                        'undoImpersonation()
                        '数据库文件名删除
                        If Len(Trim(Request.Form("hi_fileID"))) > 0 Then
                            str_sql = "" '"delete FROM ghs_t_zldamxb Where mxid=" + Trim(Request.Form("hi_fileID")) + " and zd='"+zd+"';"
                        End If

                    End If
                End If

            End If
        %>
        <center>
<input type=hidden name="hi_mytj" />
<input type=hidden name="hi_mycl" />
<input type=hidden name="hi_filename" />
<input type=hidden name="hi_ghsdm" value="<%=ghsdm%>" />
<input type=hidden name="hi_mlid" value="<%=mlid%>" />
<input type=hidden name="hi_zbid" value="<%=zbid%>" />
<input type=hidden name="hi_dqstep" value="<%=dqstep%>" />
<input type=hidden name="zd" value="<%=zd %>" />
<input type=hidden name="hi_fileID"/>
<input type=text width="200" name="pathname" value="<%=ctrl_pathname %>" />
<table width=100% border="0" height="520px">

<tr>
<% If jcjg <> "合格" And jcjg <> "不合格" Then%>
   <td width="50%" height="450px" style="BORDER-RIGHT: #000000 1px solid; BORDER-TOP: #000000 0px solid; BORDER-LEFT: #000000 0px solid; BORDER-BOTTOM: #000000 0px solid" valign="top">
        <table width=100%  border=0 >
            <tr>
                <td style="FONT-WEIGHT: bold; FONT-SIZE: 16pt; COLOR: #000080; FONT-FAMILY: 隶书; HEIGHT: 25px; TEXT-ALIGN: center; TEXT-DECORATION: underline"><%=iif(zd="sygzb_lxd","联系单","pdf上传")%></td>
            </tr>
        </table>
        <table width=100% border=0>
            <tr>
                <td><div id="div_bar" class=red14></div>&nbsp;</td>
                <td width=61px><input type=button value="增 加" class=blk style="width:60px;" onclick="addFile();"/></td>
                <td width=61px><input type=button value="开始上传" name="btn_up" class=blk style="width:60px;" onclick="TLBtn_tj();" /></td>
                <td width=61px><input type=button value="关 闭" class=blk style="width:60px;" onclick="window.close();"/></td>
            </tr>
        </table>
        <div style="overflow-x:hidden;overflow-y:auto;height:350px;">
        <P id="MyFile" class="blk"><INPUT type="file" NAME="File" style="width:80%" onkeypress="event.returnValue=false;"><!--&nbsp;说明：<INPUT type="text" class="tltext_u" style="width:25%" NAME="bz:0">--></P>
        <input type="hidden" name="maxjls" value="0" />
        </div>
     </td>
     <td width="50%"style="BORDER-RIGHT: #000000 0px solid; BORDER-TOP: #000000 0px solid; BORDER-LEFT: #000000 1px solid; BORDER-BOTTOM: #000000 0px solid" valign="top">
<% End If%>
         <table width=100%  border=0 >
            <tr>
                <td style="FONT-WEIGHT: bold; FONT-SIZE: 16pt; COLOR: #000080; FONT-FAMILY: 隶书; HEIGHT: 25px; TEXT-ALIGN: center; TEXT-DECORATION: underline">已传<%=iif(zd="sygzb_lxd","联系单","pdf")%>列表</td>
            </tr>
        </table>
        <div style="overflow-x:hidden;overflow-y:auto;height:350px;">

        </div>
     </td>
 </tr>
<% If jcjg <> "合格" And jcjg <> "不合格" Then%>
<tr>
    <td colspan="2" height="25"><span class=red>备注:文件只能上传:.<%=iif(zd="sygzb_lxd","pdf,jpg","pdf")%> 格式的文件！</span></td>
</tr>
<% End If%>
</table>
    </form>
    </center>
</body>
</html>



