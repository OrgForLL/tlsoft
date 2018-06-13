using nrWebClass;

/// <summary>
/// 异步调度任务
/// </summary>
public class AsynTask
{
    /// <summary>
    /// 异步调度任务
    /// </summary>
    /// <param name="sourceID"></param>
    /// <param name="khid"></param>
    /// <returns></returns>
    public string Run(int sourceID, int khid)
    {
        string TaskCode = "VipLsdjServer";
        string json = "{ \"khid\":\"" + khid.ToString() + "\" }";
        return  clsAsynTask.Submit(TaskCode, sourceID, json);
    }
}