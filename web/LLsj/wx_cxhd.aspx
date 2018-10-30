<%@Page Language="VB" Debug="true" %>
<%@Import Namespace="System.Data"%>
<%@Import Namespace="System.Data.SqlClient"%> 
<html>
<head>
    <title>图片上传</title>
    <LINK href="../mycss/my_style.css" type="text/css" rel="stylesheet">
    <script language="javascript">
        function bbimg(o) {         
         var zoom=parseInt(o.style.zoom,10)||100;
         zoom+=event.wheelDelta/12;
         if (zoom>0){o.style.zoom=zoom+"%"; }
         return false;
         }

        function TLBtn_tj() {
            var fileLen=document.getElementById("File").length; 
            var fileVal="";
            var typeBs=true;
            for(var i=0;i<fileLen;i++){
                fileVal=document.getElementById("File").item(i).value;
            }
            if(typeBs==true){
                MyForm.mytj.value="sc";
                MyForm.mycl.value="add";
                MyForm.btn_up.value="正在上传";
                MyForm.btn_up.disabled=true; 
                document.getElementById("div_bar").innerHTML="文件正在上传中,请耐心等待...";
                MyForm.submit();
                window.returnValue="ok";
            }
         }

         
         function TL_DelFile(fileID,filename){
            if(confirm("删除后将不能恢复，确认要删除该文件？")){
               MyForm.hi_fileID.value=fileID;
               MyForm.hi_filename.value=filename;
               MyForm.mycl.value="del";
               MyForm.mytj.value="cx";
               MyForm.submit();
               document.getElementById("div_bar").innerHTML="正在删除文件,请耐心等待...";
               window.returnValue="ok";

            }
         }

                 //按比例显示图片
         function AutoResizeImage(maxWidth, maxHeight, objImg) {
             var img = new Image();
             img.src = objImg.src;
             var hRatio;
             var wRatio;
             var Ratio = 1;
             var w = img.width;
             var h = img.height;
             wRatio = maxWidth / w;
             hRatio = maxHeight / h;
             if (maxWidth == 0 && maxHeight == 0) {
                 Ratio = 1;
             } else if (maxWidth == 0) { //
                 if (hRatio < 1) Ratio = hRatio;
             } else if (maxHeight == 0) {
                 if (wRatio < 1) Ratio = wRatio;
             } else if (wRatio < 1 || hRatio < 1) {
                 Ratio = (wRatio <= hRatio ? wRatio : hRatio);
             }
             if (Ratio < 1) {
                 w = w * Ratio;
                 h = h * Ratio;
             }
             objImg.height = h;
             objImg.width = w;
         }
	</script>
	<base target=_self />
</head>
<body>
<form method="POST" id="MyForm" name="MyForm" runat=server enctype="multipart/form-data">
<!--#include file="../mycss/incShareFile.aspx" -->
<!--#include file="../tl_Ghs/inc_Load_mr.aspx"-->
<%
    Dim mxid, t_name, c_name, tzid, shbs, user, zdr, lyjmbs, mytj, ghsdm, mlid, dqstep, str_sql, mycl, filePath, delFileName, zbid,tempName,rootname,id
    Dim i, MySql
    'tzid = Trim(Request.QueryString("tzid"))
    id = Trim(Request.QueryString("id"))
    'id = Trim(Request.QueryString("id"))
    t_name = Trim(Request.Form("t_name"))
    if len(t_name)<=0 then t_name = Trim(Request.QueryString("t_name"))
    c_name = Trim(Request.QueryString("c_name"))
    mytj = Trim(Request.QueryString("mytj"))
    shbs = Trim(Request.QueryString("shbs"))
    'user = Trim(Request.QueryString("user"))
    'zdr = Trim(Request.QueryString("zdr"))
    'lyjmbs = Trim(Request.QueryString("lyjmbs"))
    
    mycl = Trim(Request.Form("mycl"))
    filePath = Server.MapPath("../photo/cxhd/")
    If mytj = "sc" Then
        If mycl = "add" Then
           if id="" or id=0 then
           Response.Write("<script language='javascript'>alert('记录未保存，不能上传图片！');</script>")
           end if
            Dim files As System.Web.HttpFileCollection = System.Web.HttpContext.Current.Request.Files
            Dim iFile As System.Int32
            str_sql = ""
            Try
                '上传处理
                Dim postedFile As System.Web.HttpPostedFile = files(iFile)
                Dim fileName, fileExtension As System.String
                    
                fileName = System.IO.Path.GetFileName(postedFile.FileName)
                If Not (fileName = String.Empty) Then
                    fileExtension = System.IO.Path.GetExtension(fileName)
                    tempName = id + "_" + c_name + fileExtension
                    postedFile.SaveAs(filePath + tempName)
                    rootname=filePath + tempName
                 End If
            Catch Ex As System.Exception
                Response.Write("<script language='javascript'>alert('文件上传失败！请检查上传的文件！');</script>")
            End Try
            '数据库文件名处理
            MySql = ""
            MySql += "update wx_t_active set PicPath='" + tempName + "' where id=" + id + " ;"
                If MyData.MyDataTrans(MyConn, MySql) > 0 Then
                    MyData.mylog(myconn, user_ip, user_asp, Session("user"), "上传图片:" + tempName)
                    Response.Write("<script language='javascript'>alert('图片上传成功！');</script>")
                    t_name = tempName
                Else
                    Response.Write("<script language='javascript'>alert('文件未更新到库中,请检查是否超时！');</script>")
                End If
            End If
        End If
        If mytj = "cx" Then
            If mycl = "del" Then
                str_sql = ""
                delFileName = t_name   '删除
                Dim File As System.IO.FileInfo = New System.IO.FileInfo(filePath + delFileName)
                If File.Exists Then
                    File.Delete()
                End If
                'undoImpersonation()
                '数据库文件名删除

            str_sql += "update wx_t_active set PicPath='' where id=" + id + " ;"

            'str_sql+=" update yf_t_mlkfxqmxb set "+c_name+"='' where id="+id+" and tzid="+tzid+";"
            If Len(str_sql) > 0 Then
                If MyData.MyDataTrans(MyConn, str_sql) > 0 Then
                    Response.Write("<script language='javascript'>alert('删除成功');<")
                    Response.Write("/script>")
                    Response.Write("<script language='javascript'>window.close();<")
                    Response.Write("/script>")
                    MyData.mylog(MyConn, user_ip, user_asp, Session("user"), "删除图片:" + t_name)
                Else
                    Response.Write("<script language='javascript'>alert('文件删除失败,请检查是否超时！');</script>")
                End If
            End If
        End If
    End If
%>
<center>
<input type=hidden name="t_name" />
<input type=hidden name="mytj" />
<input type=hidden name="mycl" />
<input type=hidden name="hi_filename" />
<input type=hidden name="hi_mlid" />
<input type=hidden name="hi_zbid" value="<%=zbid%>" />
<input type=hidden name="hi_fileID"/>
<table width=100% border="0" height="520px">
<tr>
   <td width="100%" height="20%" style="BORDER-RIGHT: #000000 1px solid; BORDER-TOP: #000000 0px solid; BORDER-LEFT: #000000 0px solid; BORDER-BOTTOM: #000000 0px solid" valign="top">
        <table width=100% border=0>
            <tr>
                <td><div id="div_bar" class=red14></div>&nbsp;</td>
                <%if shbs=0  then %>
                <td width=61px><input type=button value="开始上传" name="btn_up" class=blk style="width:60px;" onclick="TLBtn_tj();" /></td>
                <%if len(Trim(Request.QueryString("t_name")))>0 then %>
                <td width=61px><input type=button value="删除图片" name="btn_del" class=blk style="width:60px;" onclick="TL_DelFile('<%=id%>','<%=t_name%>');" /></td>
                <%end if %>
                <%end if %>
                <td width=61px><input type=button value="关 闭" class=blk style="width:60px;" onclick="window.close();"/></td>
            </tr>
        </table>
        <div style="overflow-x:hidden;overflow-y:auto;height:50px;">
        <P id="MyFile" class="blk"><input type="file" name="file" id="File" style="width:80%" onkeypress="event.returnValue=false;"></P>
        
        <input type="hidden" name="maxjls" value="0" />
        </div>
     </td>
     </tr>
     <tr>   
     <td width="100%" height="80%" style="BORDER-RIGHT: #000000 1px solid; BORDER-TOP: #000000 0px solid; BORDER-LEFT: #000000 0px solid; BORDER-BOTTOM: #000000 0px solid" valign="top">   
     <table width=100% border=0>  
       <% if instr(1,t_name,".pdf")>0  then %> 
        <td>
            <div id="Tab_1" style="display:block; text-align: center; background-color:#eeeeee; width:1000px;height:650xp;"> 
             <!--上传后显示PDF-->
                <iframe id="frameDiaplay1" style="width:1000px;height:650px;border:solid 1px #z-000000;index:111;zoom:100%" src="file_Redirect_ml1.aspx?fileName=<%=t_name %>">
                </iframe>
            </div>
        </td>
        </table>
     </td>  
       <%
         else
       %>
        <td align=center><IMG SRC="../photo/cxhd/<%=t_name %>" onmousewheel="javascript:return bbimg(this); " onload="AutoResizeImage(650,510,this)" /></td>
        </table>
     </td>
       <%
         End If
       %>
    </tr>

</table>   
</form>
</center>
</body>
</html>




