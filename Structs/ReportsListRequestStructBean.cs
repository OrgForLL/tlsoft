using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;

namespace Structs
{
    public class ReportsListRequestStructBean
    {
        public ReportsListRequestStructBean() { }
        // 请求头对象
        public RequestHeadStc Head { get; set; }

        // 请求体对象
        public ReportsListInputStc Body { get; set; }
    }
}
