<%@ Page Language="C#" %>

<%@ Import Namespace="nrWebClass" %>
<%@ Import Namespace="System.Data" %>
<%@ Import Namespace="System.Data.SqlClient" %>
<%@ Import Namespace="System.Collections.Generic" %>

<!DOCTYPE html>
<script runat="server">  
    private String ConfigKeyValue = "";
    public string openid = "", msg = "";
    private string DBConnStr = "server=192.168.35.10;uid=ABEASD14AD;pwd=+AuDkDew;database=tlsoft";
    protected void Page_Load(object sender, EventArgs e)
    {
        string mdid = Convert.ToString(Request.Params["mdid"]);
        if (mdid == "0" || mdid == "" || mdid == null)
        {
            msg = "Error:缺少必要参数！";
            return;
        } else {
            //20170302 liqf
            //由于利郎男装和轻商务的VIP会员需求是共用的，所以现在轻商务也有这个需求
            //更新思路，通过传入的MDID识别出是轻商务的店还是利郎男装的店，再根据对应的CONFIGKEY去鉴权，获取对应的身份
            //返回0-无效mdid -1-门店停用
            ConfigKeyValue = clsErpCommon.GetStoreSSKey(mdid);
            if (ConfigKeyValue == "0") {
                msg = "Error:MDID无效！";
                return;
            }
            else if (ConfigKeyValue == "-1") {
                msg = "Error:门店已停用！";
                return;
            }                
        }

        //微信公众号鉴权
        if (clsWXHelper.CheckUserAuth(ConfigKeyValue, "openid"))
        {
            openid = Convert.ToString(Session["openid"]);
            using (LiLanzDALForXLM dal10 = new LiLanzDALForXLM(DBConnStr))
            {
                string str_sql = @"select a.id,isnull(a.vipid,0) vipid,isnull(v.khid,0) khid,isnull(v.mdid,0) mdid,isnull(kh.khmc,'') khmc
                                    from wx_t_vipbinging a
                                    left join yx_t_vipkh v on a.vipid=v.id
                                    left join yx_t_khb kh on v.khid=kh.khid
                                    where a.wxopenid=@openid";
                List<SqlParameter> paras = new List<SqlParameter>();
                paras.Add(new SqlParameter("@openid", openid));
                DataTable dt;
                string errinfo = dal10.ExecuteQuerySecurity(str_sql, paras, out dt);
                if (errinfo == "")
                    if (dt.Rows.Count == 0)
                        //clsWXHelper.ShowError("对不起，找不到您的微信资料！");
                        msg = "Error:对不起，找不到您的微信资料！";
                    else
                    {
                        string vid = Convert.ToString(dt.Rows[0]["id"]);                        
                        string vipid = Convert.ToString(dt.Rows[0]["vipid"]);
                        //clsSharedHelper.WriteInfo(ConfigKeyValue + "|" + openid);
                        string vkhid = Convert.ToString(dt.Rows[0]["khid"]);
                        string vmdid = Convert.ToString(dt.Rows[0]["mdid"]);
                        string vkhmc = Convert.ToString(dt.Rows[0]["khmc"]);
                        object scalar;
                        if (vipid == "0" || vipid == "")
                        {
                            //还不是VIP会员则只更新vipbinging表
                            str_sql = @"declare @khid int;declare @mdmc varchar(400);
                                        select top 1 @khid=khid,@mdmc=mdmc from t_mdb where mdid=@mdid;
                                        update wx_t_vipbinging set khid=isnull(@khid,0),mdid=@mdid where id=@id;
                                        select isnull(@mdmc,'') mdmc";
                            paras.Clear();
                            paras.Add(new SqlParameter("@id", vid));
                            paras.Add(new SqlParameter("@mdid", mdid));
                            errinfo = dal10.ExecuteQueryFastSecurity(str_sql, paras, out scalar);
                            if (errinfo != "")
                                //clsWXHelper.ShowError("【0】更新数据时出错 " + errinfo);
                                msg = "Error:【0】更新数据时出错 " + errinfo;
                            else
                            {
                                string mdmc = Convert.ToString(scalar);
                                //clsSharedHelper.WriteSuccessedInfo("尊敬的用户，您已经成功绑定到【" + mdmc + "】！");
                                msg = "Successed:尊敬的用户，您已经成功绑定到【" + mdmc + "】！";
                            }
                        }
                        else
                        {
                            //已经是VIP会员 
                            //关联出yx_t_vipkh.khid =-1 两边都更新 >0 否则更新vipbinging并给出提示之前已经绑定到哪家门店
                            if (vkhid == "-1" || vkhid == "" || vkhid == "0")
                            {
                                str_sql = @"declare @khid int;declare @mdmc varchar(400);
                                            select top 1 @khid=khid,@mdmc=mdmc from t_mdb where mdid=@mdid;
                                            update yx_t_vipkh set khid=isnull(@khid,0),mdid=@mdid where id=@vipid;
                                            update wx_t_vipbinging set khid=isnull(@khid,0),mdid=@mdid where id=@id;                                            
                                            select isnull(@mdmc,'') mdmc;";
                                paras.Clear();
                                paras.Add(new SqlParameter("@id", vid));
                                paras.Add(new SqlParameter("@mdid", mdid));
                                paras.Add(new SqlParameter("@vipid", vipid));
                                errinfo = dal10.ExecuteQueryFastSecurity(str_sql, paras, out scalar);
                                if (errinfo != "")
                                    //clsWXHelper.ShowError("【1】更新数据时出错 " + errinfo);
                                    msg = "Error:【1】更新数据时出错 " + errinfo;
                                else
                                {
                                    string mdmc = Convert.ToString(scalar);
                                    //clsSharedHelper.WriteSuccessedInfo("尊敬的利郎会员，您已经成功绑定到【" + mdmc + "】！");
                                    msg = "Successed:尊敬的利郎会员，您已经成功关注【" + mdmc + "】！";
                                }
                            }
                            else
                            {
                                //之前已经成功关注某家店铺
                                str_sql = @"declare @khid int;declare @khmc varchar(400);declare @mdid int;
                                            select top 1 @khid=isnull(a.khid,0),@mdid=isnull(a.mdid,0),@khmc=kh.khmc 
                                            from yx_t_vipkh a inner join yx_t_khb kh on a.khid=kh.khid where a.id=@vipid;
                                            update wx_t_vipbinging set khid=@khid,mdid=@mdid where id=@id;
                                            select @mdid mdid,@khmc khmc;";
                                paras.Clear();
                                paras.Add(new SqlParameter("@id", vid)); 
                                paras.Add(new SqlParameter("@vipid", vipid));                                                               
                                DataTable _dt;
                                
                                errinfo = dal10.ExecuteQuerySecurity(str_sql, paras, out _dt);
                                if (errinfo != "")
                                    //clsWXHelper.ShowError("【2】更新数据时出错 " + errinfo);
                                    msg = "Error:【2】更新数据时出错 " + errinfo;
                                else
                                {
                                    string currentMdid = Convert.ToString(_dt.Rows[0]["mdid"]);
                                    string khmc = Convert.ToString(_dt.Rows[0]["khmc"]);
                                    _dt.Clear(); _dt.Dispose();
                                    if (currentMdid==mdid)
                                        //clsSharedHelper.WriteSuccessedInfo("尊敬的利郎会员，您已经成功绑定【" + khmc + "】，无需重复操作！");
                                        msg = "Successed:尊敬的利郎会员，您之前已经成功绑定【" + khmc + "】，无需重复操作！";
                                    else
                                        //clsSharedHelper.WriteSuccessedInfo("尊敬的利郎会员，您已经成功绑定【" + khmc + "】！");
                                        msg = "Warn:尊敬的利郎会员，您之前已经成功关注了【" + khmc + "】！";
                                }
                            }
                        }
                    }
                else
                    //clsWXHelper.ShowError("查询信息时出错 " + errinfo);
                    msg = "Error:查询信息时出错 " + errinfo;
            }//end using
            
            msg=msg.Replace("\"","");
        }
    }
</script>
<html lang="en" xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <meta charset="utf-8" />
    <meta name="viewport" content="width=device-width,initial-scale=1,user-scalable=0,maximum-scale=1" />
    <meta name="format-detection" content="telephone=no" />
    <meta name="apple-mobile-web-app-capable" content="yes" />
    <title>正在处理,请稍候..</title>
    <link rel="stylesheet" href="../../res/css/sweet-alert.css" />
</head>
<body>
    <script type="text/javascript" src="../../res/js/sweet-alert.min.js"></script>
    <script type="text/javascript">
        window.onload = function () {
            var msg = "<%=msg%>";
            var ConfigKey = "<%=ConfigKeyValue%>";
            var touchURL = "touchFollow.html";
            if (ConfigKey == "7") touchURL = "touchFollowQ.html";
            if (msg.indexOf("Warn:")>-1) {
                swal({
                    title: "",
                    text: msg.replace("Warn:",""),
                    type: "warning",
                    confirmButtonColor: "#DD6B55",
                    confirmButtonText: "知道了！"
                }, function (isConfirm) {
                    //WeixinJSBridge.call('closeWindow');
                    window.location.href = touchURL;
                });
            } else if (msg.indexOf("Successed:") > -1) {
                swal({
                    title: "关注成功！",
                    text: msg.replace("Successed:",""),
                    type: "success",
                    confirmButtonColor: "#59a714",
                    confirmButtonText: "确定"
                }, function (isConfirm) {
                    //WeixinJSBridge.call('closeWindow');
                    window.location.href = touchURL;
                });
            } else {
                swal({
                    title: "关注失败！",
                    text: msg.replace("error:",""),
                    type: "error",
                    confirmButtonColor: "#DD6B55",
                    confirmButtonText: "确定"
                }, function (isConfirm) {
                    //WeixinJSBridge.call('closeWindow');
                    window.location.href = touchURL;
                });
            }
        }
    </script>
</body>
</html>
