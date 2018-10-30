<%@ Control Language="C#" ClassName="ApprovalContent" %>
<%@ Import Namespace="System.Data" %>
<%@ Import Namespace="System.IO" %>
<%@ Import Namespace="System.Xml" %>
<%@ Import Namespace="LiLanzModel" %>
<%@ Import Namespace="System.Xml.Serialization" %>
<script runat="server">

    protected void Page_Load(object sender, EventArgs e)
    {
        nrWebClass.LiLanzDAL sqlhelper = new nrWebClass.LiLanzDAL();
        int viewid = int.Parse(Request.QueryString["tempid"].ToString());
        IDataReader dr = sqlhelper.ExecuteReader(
            String.Format(@"select [id],[FlowID],[ItemName],[MainView],[DetailView]
 FROM fl_t_MobileView where id={0}", viewid));
        MoblieView mv = new MoblieView();
        if (dr.Read())
        {
            using (StringReader rdr = new StringReader(dr[3].ToString()))
            {
                XmlSerializer serializer = new XmlSerializer(typeof(MoblieView));
                mv = (MoblieView)serializer.Deserialize(rdr);
            }
        }
        dr.Dispose();
        if (mv != null)
        {
            string[] fields = new string[mv.fields.Count];
            int i = 0;
            foreach (MobileField field in mv.fields)
            {
                fields[i] = field.Field;
                i++;
            }
            string sql = "select {0} from {1} where {2}={3}";
            sql = string.Format(sql, String.Join(",", fields), mv.EntityName, mv.mkey, 
                Request.QueryString["id"]);
            dr = sqlhelper.ExecuteReader(sql);
            if (dr.Read())
            {
                for (int j = 0; j < mv.fields.Count; j++)
                {
                    mv.fields[j].Val = dr[j].ToString();
                }
            }
            dr.Dispose();
            Repeater1.DataSource = mv.fields;
            Repeater1.DataBind();
        }
    }
</script>
<div data-role="content">
<ul data-role="listview" data-inset="true">      
<asp:Repeater ID="Repeater1" runat="server">
    <ItemTemplate>
    <li data-role="fieldcontain">
        <%#Eval("Name")%>:<%#Eval("Val")%>
    </li>
    </ItemTemplate>
</asp:Repeater>
 </ul>
</div>