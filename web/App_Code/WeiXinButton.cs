using System;
using System.Collections.Generic;
using System.Web;
using Newtonsoft.Json;
using System.Web;
/// <summary>
///WeiXinToken 的摘要说明
/// </summary>
[JsonObject(Newtonsoft.Json.MemberSerialization.OptIn)]
public class WeiXinButton
{
    [JsonProperty("type")]
    private String type;

    [JsonProperty("name")]
    private String name;

    [JsonProperty("key")]
    private String key;

    [JsonProperty("url")]
    private String url;

    [JsonProperty("sub_button")]
    private List<WeiXinButton> subButton ;
    //[JsonIgnore]
    public String Type
    {
        get
        {
            return type;
        }
        set { type = value; }
    }
    public String Name
    {
        get
        {
            return name;
        }
        set { name = value; }
    }

    public String Key
    {
        get
        {
            return key;
        }
        set { key = value; }
    }
    public String Url
    {
        get
        {
            return url;
        }
        set { url = value; }
    }
    public List<WeiXinButton> SubButton
    {
        get
        {
            return subButton;
        }
        set { subButton = value; }
    }
}