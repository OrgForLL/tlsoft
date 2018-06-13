<%@ Page Language="C#" %>

<%@ Import Namespace="nrWebClass" %>
<%@ Import Namespace="System.Collections.Generic" %>
<%@ Import Namespace="System.Data.SqlClient" %>
<%@ Import Namespace="System.Data" %>
<%@ Import Namespace="System.IO" %>
<%@ Import Namespace="System.Net" %>

<script runat="server">
    private string _DBConnStr = "";
    Class_TLtools.MyData MDT = new Class_TLtools.MyData();

    protected void Page_Load(object sender, EventArgs e)
    {
        _DBConnStr = Convert.ToString(MDT.MyDataLink("1"));

        string serviceName = "service-stock", funName = "multiStock";
        int id = 0, djlx = 0;

        string url = serviceName + "/" + funName;
        string data = "";
        if (serviceName.Equals("service-stock"))
        {
            switch (funName)
            {
                case "multiStock":
                    data = multiStock(id, djlx);
                    break;
                case "getStockQtyDetail":
                    data = getStockQtyDetail(id, djlx);
                    break;
                default:
                    break;
            }
        }
        //Response.Write(url+"  "+data);
        Response.Write(HttpHelp.PostResponseData(url, data));
    }

    /// <summary>
    /// 多行库存数据增减
    /// </summary>
    /// <param name="id"></param>
    /// <param name="djlx"></param>
    /// <returns></returns>
    public string multiStock(int id, int djlx)
    {
        return "data={\"OrgID\":2,\"WarehouseID\":2,\"CodeList\":[{\"GoodsCode\":\"7DXC2013S\",\"GoodsSize\":\"cm41\",\"Qty\":21},{\"GoodsCode\":\"7DXC2013S\",\"GoodsSize\":\"cm42\",\"Qty\":10}]}";
    }

    /// <summary>
    /// 单货号尺码库存查询
    /// </summary>
    /// <param name="id"></param>
    /// <param name="djlx"></param>
    /// <returns></returns>
    public string getStockQtyDetail(int id, int djlx)
    {
        return "data={\"OrgID\":1,\"WarehouseID\":1,\"GoodsCode\":\"7DXC2013S\"}";
    }


    class HttpHelp
    {
        #region HttpWebRequest版本
        private static readonly string _baseAddress = "http://192.168.135.100:8900"; //配置BaseUrl 

        static HttpHelp()
        {
        }

        /// <summary>
        /// http Get请求
        /// </summary>
        /// <param name="url">请求的路径</param>
        /// <param name="data">请求的参数</param>
        /// <returns></returns>
        public static string GetResponseData(string url, string data)
        {
            try
            {
                HttpWebRequest request = (HttpWebRequest)HttpWebRequest.Create(_baseAddress + "/" + url);
                //也可以是post请求
                request.Method = WebRequestMethods.Http.Get;
                //设置参数
                byte[] param = Encoding.UTF8.GetBytes(data);
                request.ContentLength = param.Length;
                using (Stream reqStream = request.GetRequestStream())
                {
                    reqStream.Write(param, 0, param.Length);
                }
                //发送http请求及得到请求响应
                using (HttpWebResponse response = (HttpWebResponse)request.GetResponse())
                {
                    //使用读取流读取响应结果
                    using (StreamReader reader = new StreamReader(response.GetResponseStream()))
                    {
                        return reader.ReadToEnd();
                    }
                }
            }
            catch (Exception ex)
            {
                return "{\"errcode\":2999,\"errmsg\":\"商品接口执行失败（未知错误1）\",\"data\":\"\"}";
            }

        }

        /// <summary>
        /// http Post请求
        /// </summary>
        /// <param name="url">请求的路径</param>
        /// <param name="data">请求的参数</param>
        /// <returns></returns>
        public static string PostResponseData(string url, string data)
        {
            try
            {
                HttpWebRequest request = (HttpWebRequest)HttpWebRequest.Create(_baseAddress + "/" + url);
                //也可以是post请求
                request.Method = WebRequestMethods.Http.Post;
                request.ContentType = "application/x-www-form-urlencoded";

                #region 添加Post 参数  
                byte[] param = Encoding.UTF8.GetBytes(data);
                request.ContentLength = data.Length;
                using (Stream reqStream = request.GetRequestStream())
                {
                    reqStream.Write(param, 0, param.Length);
                    reqStream.Close();
                }
                #endregion

                //发送http请求及得到请求响应
                using (HttpWebResponse response = (HttpWebResponse)request.GetResponse())
                {
                    //使用读取流读取响应结果
                    using (StreamReader reader = new StreamReader(response.GetResponseStream()))
                    {
                        return reader.ReadToEnd();
                    }
                }
            }
            catch (Exception ex)
            {
                return "{\"errcode\":2999,\"errmsg\":\"商品接口执行失败（未知错误1）\",\"data\":\"\"}";
            }
        }

        #endregion
    }
</script>
