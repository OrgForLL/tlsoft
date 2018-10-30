<%@ Page Language="C#" %>
<%@ Import Namespace="System.Data" %>
<%@ Import Namespace="System.Data.SqlClient" %>
<%@ Import Namespace="System.Collections.Generic" %>
<%@ Import Namespace="nrWebClass" %>
<%@ Import Namespace="Newtonsoft.Json" %>
<%@ Import Namespace="Newtonsoft.Json.Linq" %>
<!DOCTYPE html>
<script runat="server"> 
    
    public static PayInfo p = new PayInfo();
    int outTime = 5;//超时时间
    string DBcon = clsConfig.GetConfigValue("OAConnStr");
    string DBcon_CFSF = clsConfig.GetConfigValue("CFSF");
    protected void Page_Load(object sender, EventArgs e)
    {
        clsLocalLoger.logDirectory = string.Concat(Server.MapPath("~"), "\\Logs");        
        Response.ContentEncoding = System.Text.Encoding.UTF8; 
        string ctrl = "";
        try
        {
            ctrl = Convert.ToString(Request.Params["ctrl"]);
        }
        catch
        {
            Response.Write(clsNetExecute.Error + "传入参数有误！");
            Response.End();
            return;
        }
    //    string t = "{\"AllPay\":\"67\",\"BillDetail\":[{\"Name\":\"百香绿茶\",\"sl\":\"1\",\"je\":\"12\"},{\"Name\":\"美式咖啡\",\"sl\":\"2\",\"je\":\"20\"},{\"Name\":\"芒果沙冰\",\"sl\":\"1\",\"je\":\"30\"}]}";
        string  customerID, rt = "";
        switch (ctrl)
        {
            case "NewBill":
              //  rt=CreateBill(t);// 测试都先创建单子
                string BillInfo = Convert.ToString(Request.Params["BillInfo"]);
                rt = CreateBill(BillInfo);
                break;
            case "GetInfo":
            //  CreateBill(t);// 测试都先创建单子
                customerID = Convert.ToString(Request.Params["customerID"]);

                if (Session["qy_customersid"] == null || Convert.ToString(Session["qy_customersid"]) == "")
                {
                    clsSharedHelper.WriteInfo(clsNetExecute.Error + "登录超时");
                    return;
                }
                else if (Convert.ToString(Session["qy_customersid"]) != customerID)
                {
                    clsSharedHelper.WriteInfo(clsNetExecute.Error + "非法访问");
                    return;
                }

                rt = GetBillInfo(customerID);
                break;
            case "GetBillStatus":
                rt = GetBillStatus();
                break;
            case "SurePay":
                customerID = Convert.ToString(Request.Params["customerID"]);
               
                if (Session["qy_customersid"] == null || Convert.ToString(Session["qy_customersid"]) == "")
                {
                    clsSharedHelper.WriteInfo(clsNetExecute.Error + "登录超时");
                    return;
                }
                else if (Convert.ToString(Session["qy_customersid"]) != customerID)
                {
                    clsSharedHelper.WriteInfo(clsNetExecute.Error + "非法访问");
                    return;
                }
                rt = SureToPay(customerID);
                break;
            default: rt="非法访问！";
                break;
        }
        clsSharedHelper.WriteInfo(rt);
    }

    /// <summary>
    /// 消费确认  confirmStatues置1
    /// </summary>
    /// <param name="userid"></param>
    /// <returns></returns>
    public string SureToPay(string userid)
    {
        string rt = "";

        if (p.Userid != userid || p.Userid == "" || userid == "")
        {
            rt = clsNetExecute.Error + "查不到单据，或您不能查看单据！";
        }else if(p.isLeave=="1"){
            rt = clsNetExecute.Error + "您的卡片已被停用！";
        }
        else if (p.Userid == userid)
        {
            if (DateTime.Compare(p.CreateTime.AddMinutes(outTime), DateTime.Now) < 0)
            {
                rt = clsNetExecute.Error + "访问超时！";
                p.confirmStatues = 2;
            }
            else
            {
                p.confirmStatues = 1;
                rt = clsNetExecute.Successed;
            }
        }
        return rt;
    }

    /// <summary>
    /// 获取微信关联的信息（个人信息，卡片信息）
    /// </summary>
    /// <param name="userid"></param>
    /// <returns></returns>
    public string GetBillInfo(string customerID)
    {
        string rt = "";
        Boolean flag = true;

        if (p.BillDetail == null || p.BillDetail == "")
        {
            rt = clsNetExecute.Error + "单据信息不存在!";
            flag = false;
        }
        else if (p.Userid != "")
        {
            if (p.Userid != customerID)
            {
                rt = clsNetExecute.Error + "无法查看此单据！";
                flag = false;
            }
            else if (p.Userid == customerID && p.confirmStatues == 1)
            {
                rt = clsNetExecute.Successed + "单据已支付！";
                flag = false;
            }
        }
        else
        {
            p.Userid = customerID;
            p.ScanTime = DateTime.Now;
        }

        if (flag == false)
        {
            clsLocalLoger.WriteInfo(Convert.ToString(Session["qy_cname"]) + rt);
            return rt;
        }
        string mySql = @"select b.SystemKey as AccountNo, dept.name as dept,case when c.Id IS null then 0 else 1 end as isLeave
                        from wx_t_customers a inner join  wx_t_AppAuthorized b on a.ID=b.UserID and b.SystemID=5 and b.IsActive=1
                        inner join wx_t_Deptment dept on a.department=dept.wxid 
                        left join cy_t_coffeeStopSign c on b.SystemKey=c.AccountNo
                        where a.id=@ID";
        List<SqlParameter> para = new List<SqlParameter>();
        para.Add(new SqlParameter("@ID", customerID));
        DataTable dt = new DataTable();
        string errInfo = "";
        using (LiLanzDALForXLM dal = new LiLanzDALForXLM(DBcon))
        {
            errInfo = dal.ExecuteQuerySecurity(mySql, para, out dt);
            if (errInfo != "")
            {
                rt = clsNetExecute.Error + errInfo;
                flag = false;
            }
            else if (dt.Rows.Count < 1)
            {
                rt = clsNetExecute.Error + "无法找到个人信息！";
                flag = false;
            }
            else
            {
                p.UserName = Convert.ToString(Session["qy_cname"]);
                p.AccountNo = dt.Rows[0]["AccountNo"].ToString();
                p.isLeave = dt.Rows[0]["isLeave"].ToString();
                p.Dept = dt.Rows[0]["Dept"].ToString();
            }
        }
        para.Clear();

        if (flag == false)
        {
            clsLocalLoger.WriteInfo(rt);
            return rt;
        }
        
        //获取卡片信息
        if (p.AccountNo != "0")
        {
            dt.Clear();
            mySql = @"select left('0'+cardNo,8) CardNo,customerNo as PersonSn,DeptNo,Sex from tb_Customer where AccountNo=@AccountNo and CardStat = 0 ";
            para.Add(new SqlParameter("@AccountNo", p.AccountNo));
            using (LiLanzDALForXLM dal = new LiLanzDALForXLM(DBcon_CFSF))
            {
                errInfo = dal.ExecuteQuerySecurity(mySql, para, out dt);
                if (errInfo != "")
                {
                    rt = clsNetExecute.Error + errInfo;
                    flag = false;
                }
                else if (dt.Rows.Count < 1)//未找到卡片信息则删除系统授权信息
                {
                    flag = false;
                    rt = clsNetExecute.Error + "未找到卡片信息或卡片已挂失";
                }
                else
                {
                    p.CardNo = dt.Rows[0]["CardNo"].ToString();
                    p.PersonSn = dt.Rows[0]["PersonSn"].ToString();
                    p.DeptNo = dt.Rows[0]["DeptNo"].ToString();
                    p.Sex = dt.Rows[0]["Sex"].ToString();

                    clsJsonHelper json = new clsJsonHelper();
                    json.AddJsonVar("BillDetail", p.BillDetail);
                    json.AddJsonVar("AllPay", Convert.ToString(p.AllPay));
                    json.AddJsonVar("UserName", p.UserName);
                    rt = json.jSon;
                    clsLocalLoger.WriteInfo(rt);
                    json.Dispose(); 
                }
            }
        }
        else
        {
            rt = clsNetExecute.Error + "您还没有咖啡系统权限！";
        }

        if (flag == false && rt.IndexOf("Type1") > 0)//未找到卡片信息则删除系统授权信息
        {
            errInfo = DelAppAuth(customerID);
            if (errInfo.IndexOf(clsSharedHelper.Successed) < 0)
            {
                rt = "删除授权信息是出错+"+errInfo;
            }
        }
        return rt;
    }
    private string DelAppAuth(string customerID)
    {
        string rt = "",errInfo;
        List<SqlParameter> para = new List<SqlParameter>();
        para.Add(new SqlParameter("@SystemKey", p.AccountNo));
        para.Add(new SqlParameter("@customerid", customerID));
        string mySql = @"delete wx_t_AppAuthorized where SystemID=5 and SystemKey=@SystemKey and UserID=@customerid";
        using (LiLanzDALForXLM dal = new LiLanzDALForXLM(DBcon))
        {
            errInfo = dal.ExecuteNonQuerySecurity(mySql, para);
        }
      
        if (errInfo != "")
        {
            rt = errInfo;
        }
        else
        {
            rt = clsSharedHelper.Successed;
        }
        return rt;
    }
    /// <summary>
    /// 获取单据状态
    /// </summary>
    /// <returns></returns>
    public string GetBillStatus()
    {
        string rt = "";
        if (DateTime.Compare(p.CreateTime.AddMinutes(outTime), DateTime.Now) < 0)
        {
            rt = clsNetExecute.Error + "单据已超时！"; //已超时
        }
        else if (p.Userid == "" || p.confirmStatues == 0)
        {
            rt = clsNetExecute.Successed + "type1"; //用户未扫描
        }
        else if (p.confirmStatues == 1)
        {
            rt = "成功数据";
            rt = clsNetExecute.Successed + "<?xml version=\"1.0\" encoding=\"gb2312\"?><CardInfo Dept=\"{0}\" CardNo=\"{1}\" Cname=\"{2}\" PersonSn=\"{3}\" DeptNo=\"{4}\" AccountNo=\"{5}\" Sex=\"{6}\" isLeave=\"{7}\"></CardInfo>";
            rt = string.Format(rt, p.Dept, p.CardNo, p.UserName, p.PersonSn, p.DeptNo, p.AccountNo, p.Sex, p.isLeave);
        }
        else
        {
            rt = "未知状态";
        }
        // "<?xml version=\"1.0\" encoding=\"gb2312\"?><CardInfo Dept=\"信息技术部\" CardNo=\"06507060\" Cname=\"薛灵敏\" PersonSn=\"6660\" DeptNo=\"001001001001\" AccountNo=\"10001772\" Sex=\"男\" isLeave=\"0\"></CardInfo>";
        return rt;
    }
    /// <summary>
    /// 创建消费单据
    /// </summary>
    /// <param name="BillInfo"></param>
    /// <returns></returns>
    public string CreateBill(string BillInfo)
    {
        string rt = "";
        p = null;
        p = new PayInfo();
        try
        {
            clsJsonHelper json = clsJsonHelper.CreateJsonHelper(BillInfo);
            p.CreateTime = DateTime.Now;
            p.Userid = "";
            p.UserName = "";
            p.Dept = "";
            p.confirmStatues = 0;
            p.AllPay = Convert.ToDecimal(json.GetJsonValue("AllPay"));
            p.BillDetail = json.GetJsonValue("BillDetail");
            rt = clsNetExecute.Successed;
        }
        catch (Exception e)
        {
            rt = clsNetExecute.Error + e.ToString();
        }
        return rt;
    }
   
    /// <summary>
    /// 内存单子、支付对象
    /// </summary>
    public class PayInfo
    {
        private DateTime _CreateTime;
        private DateTime _ScanTime;
        private string _UserID;
        private string _UserName;
        private string _Dept;
        private string _CardNo;
        private string _PersonSn;
        private string _DeptNo;
        private string _AccountNo;
        private string _Sex;
        private string _isLeave;
        private int _confirmStatues;
        private decimal _AllPay;
        private string _BillDetail;

        public DateTime CreateTime
        {
            set { _CreateTime = value; }
            get { return _CreateTime; }
        }
        public DateTime ScanTime
        {
            set { _ScanTime = value; }
            get { return _ScanTime; }
        }
        public string Userid
        {
            set { _UserID = value; }
            get { return _UserID; }
        }
        public string UserName
        {
            set { _UserName = value; }
            get { return _UserName; }
        }
        public string Dept
        {
            set { _Dept = value; }
            get { return _Dept; }
        }
        public string CardNo
        {
            set { _CardNo = value; }
            get { return _CardNo; }
        }
        public string PersonSn
        {
            set { _PersonSn = value; }
            get { return _PersonSn; }
        }
        public string DeptNo
        {
            set { _DeptNo = value; }
            get { return _DeptNo; }
        }
        public string AccountNo
        {
            set { _AccountNo = value; }
            get { return _AccountNo; }
        }
        public string Sex
        {
            set { _Sex = value; }
            get { return _Sex; }
        }
        public string isLeave
        {
            set { _isLeave = value; }
            get { return _isLeave; }
        }
        public int confirmStatues
        {
            set { _confirmStatues = value; }
            get { return _confirmStatues; }
        }
        public decimal AllPay
        {
            get { return _AllPay; }
            set { _AllPay = value; }
        }
        public string BillDetail
        {
            set { _BillDetail = value; }
            get { return _BillDetail; }
        }
    }
        

</script>
<html>
<head id="Head1" runat="server">
    <meta http-equiv="Content-Type" content="text/html; charset=utf-8" />
    <title></title>
</head>
<body>
    <form id="form1" runat="server">
    <div>
    </div>
    </form>
</body>
</html>
