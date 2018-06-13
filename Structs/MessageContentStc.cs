using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;

namespace Structs
{
    public class MessageContentStc
    {
        public MessageContentStc() { }

        // 消息代码
        public string MsgCode { get; set; }

        // 消息类型 E M
        public string MsgType { get; set; }

        // 消息内容
        public string MsgContent { get; set; }

        // 消息来源
        public string MsgSystem { get; set; }
    }
}
