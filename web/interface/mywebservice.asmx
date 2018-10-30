<%@ WebService Language="C#" Class="mywebservice" %>

using System;
using System.Collections;
using System.ComponentModel;
using System.Data;
using System.Diagnostics;
using System.Web;
using System.Web.Services;

[WebService(Namespace = "http://tempuri.org/")]
[WebServiceBinding(ConformsTo = WsiProfiles.BasicProfile1_1)]
//若要允许使用 ASP.NET AJAX 从脚本中调用此 Web 服务，请取消对下行的注释。 
// [System.Web.Script.Services.ScriptService]
public class mywebservice : System.Web.Services.WebService 
{
    public mywebservice()
    {
        //
        // TODO: 添加任何需要的构造函数代码
        //
    }

    // WEB 服务示例
    // HelloWorld() 服务示例返回字符串“Hello World”。

    [WebMethod]
    public string HelloWorld()
    {
        return "Hello World";
    }
}
