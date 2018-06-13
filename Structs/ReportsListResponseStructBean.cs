using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;

namespace Structs
{
    public class ReportsListResponseStructBean
    {
        public ReportsListResponseStructBean() { }
        // 返回头
        public ResponseHeadStc Head { get; set; }

        // 返回体
        public ReportsListOutStc Body { get; set; }
    }
}
