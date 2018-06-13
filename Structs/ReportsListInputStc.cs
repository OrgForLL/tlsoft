using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;

namespace Structs
{
    public class ReportsListInputStc
    {
        public ReportsListInputStc() { }
        public string TrustDateFrom { get; set; }
        public string TrustDateTo { get; set; }
        public string AuditDateFrom { get; set; }
        public string AuditDateTo { get; set; }
        public string ProductName { get; set; }
        public string GoodsName { get; set; }
        public string EnterpriseNo { get; set; }
        public string TrustCustomerName { get; set; }
        public string MakeCustomerName { get; set; }
        public string TestItem { get; set; }
        public string FailItem { get; set; }
        public string ProductStandardNo { get; set; }
        public string MethodStandardNo { get; set; }
        public string F01 { get; set; }
        public string F02 { get; set; }
        public string F03 { get; set; }
    }
}
