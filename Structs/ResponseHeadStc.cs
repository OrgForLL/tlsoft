using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;

namespace Structs
{
    public class ResponseHeadStc
    {
        public ResponseHeadStc() { }
        // 请求原值返回
        public string Method { get; set; }

        // 操作状态 E失败  M成功
        public string ResponseCode { get; set; }

        // 返回操作信息 中文
        public string ResponseInfo { get; set; }

        // 返回时间
        public string ResponseTime { get; set; }

        // 请求流水码 原值返回
        public string AskSerialNo { get; set; }

        // 平台交易处理流水号
        public string AnswerSerialNo { get; set; }

        // 应用返回信息列表
        public List<MessageContentStc> MsgList
        {
            get;
            set;
        }
    }
}
