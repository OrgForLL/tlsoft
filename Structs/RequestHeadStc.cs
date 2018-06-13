using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;

namespace Structs
{
    public class RequestHeadStc
    {
        public RequestHeadStc() { }
        // 请求方法名称
        public string Method { get; set; }

        // 用户编码 权限判断用
        public string AppKey { get; set; }

        // 用户口令 权限判断用
        public string SecretKey { get; set; }

        // 请求流水码
        public string AskSerialNo { get; set; }

        // 请求时间格式 YYYYMMDDHHMMSS
        public string SendTime { get; set; }
    }
}
