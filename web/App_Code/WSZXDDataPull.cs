using System;
using System.Collections.Generic;
using System.Data;
using System.Web;
using System.Web.Services;

/// <summary>
/// WSZXDDataPull 的摘要说明
/// </summary>
[WebService(Namespace = "http://tempuri.org/")]
[WebServiceBinding(ConformsTo = WsiProfiles.BasicProfile1_1)]
public class WSZXDDataPull : System.Web.Services.WebService
{

    private web231.WSZXDDataPull w;
    public WSZXDDataPull()
    {
        w = new web231.WSZXDDataPull();        
    }

    /// <summary>
    /// 获取物料卡id
    /// </summary>
    /// <param name="tzid">套账id</param>
    /// <param name="wlkbh">物料卡编号</param>
    [WebMethod(Description = "保存物料卡信息")]
    public string GetWlkInfo(string tzid, string wlkbh)
    {
        return w.GetWlkInfo(tzid, wlkbh);
    }

    [WebMethod(Description = "PDA版本号")]
    public web231.Result getPDAVer()
    {
        return w.getPDAVer();
    }
    /// <summary>
    /// 保存物料卡信息
    /// </summary>
    /// <param name="info">物料卡信息</param>
    /// <param name="username">当前用户名</param>
    /// <param name="dhtzdbh">到货通知单编号</param>
    /// <param name="tzid">当前套帐id</param>
    /// <param name="id">物料卡id</param>
    /// <param name="chdm">材料代码</param>
    [WebMethod(Description = "保存物料卡信息")]
    public string SaveWlkInfo(DataTable info, string username, string dhtzdbh, string tzid, string id, string chdm)
    {
        return w.SaveWlkInfo(info, username, dhtzdbh, tzid, id, chdm);
    }

    //获取某材料在某仓库的仓位
    [WebMethod(Description = "获取某材料在某仓库的仓位")]
    public string GetClZCkDCw(string tmcode, string ckid)
    {
        return w.GetClZCkDCw(tmcode, ckid);
    }

    //获取款号
    [WebMethod(Description = "获取款号")]
    public string getKHXX(string jhdTm)
    {
        return w.getKHXX(jhdTm);
    }

    //获取材料仓库信息
    [WebMethod(Description = "获取材料仓库信息")]
    public string getCHCKXX(string tzid)
    {
        return w.getCHCKXX(tzid);
    }



    //设置材料的仓位信息
    [WebMethod(Description = "设置材料的仓位信息")]
    public string setCLInfo(DataTable cwInfo, string userName, string tzid, string qwtm, string comdjlx, string chtm)
    {
        return w.setCLInfo(cwInfo, userName, tzid, qwtm, comdjlx, chtm);
    }

    //获取要维护仓位的材料信息
    [WebMethod(Description = "获取要维护仓位的材料信息")]
    public string getCLInfo(string djid, string djly, string tzid, string ckid)
    {
        return w.getCLInfo(djid, djly, tzid, ckid);
    }

    //加载主表数据 数据源是物料发货计划(cl_t_dddjb.djlx=605)
    [WebMethod(Description = "加载主表数据 数据源是物料发货计划")]
    public string getZXDList(string ksrq, string jsrq, string tzid, string khid)
    {
        return w.getZXDList(ksrq, jsrq, tzid, khid);
    }


    [WebMethod(Description = "五里陈佳发货出库单选择 加载主表数据 数据源是物料发货计划")]
    public web231.Result getZXDListWL(string tmid, string tzid, string exisIDS)
    {
        return w.getZXDListWL(tmid, tzid, exisIDS);
    }


    [WebMethod(Description = "五里陈佳发货出库单选择 入库保存数据")]
    public web231.Result saveDataWL(string username, string tzid, string data, string tmRecode, string cwtm)
    {
        return w.saveDataWL(username, tzid, data, tmRecode, cwtm);
    }


    [WebMethod(Description = "五里陈佳入库上架")]
    public web231.Result getCLTMWL(string tmid, string tzid)
    {
        return w.getCLTMWL(tmid, tzid);
    }

    [WebMethod(Description = "五里陈佳入库上架保存")]
    public web231.Result saveCLTMWL(string username, string tzid, string data, string cwtm)
    {
        return w.saveCLTMWL(username, tzid, data, cwtm);
         
    }


    //条码生成模块的条码生成函数    
    [WebMethod(Description = "五里条码折分")]
    public web231.Result GenerateTMWL(string zdr, string tzid, string txtTm, string txbsl, string txbbz)
    {
        return w.GenerateTMWL(zdr, tzid, txtTm, txbsl, txbbz);
    }


    //加载单据表明细 传入的是多张领用计划单
    [WebMethod(Description = "加载单据表明细 传入的是多张领用计划单")]
    public string getZXDMXList(string ids, string tzid)
    {
        return w.getZXDMXList(ids, tzid);
    }


    //检查箱码的有效性
    [WebMethod(Description = "检查箱码的有效性")]
    public string checkXM(string tzid, string tm, string ids)
    {
        return w.checkXM(tzid, tm, ids);
    }

    [WebMethod]
    public string checkTM(string tzid, string tm)
    {
        return w.checkTM(tzid, tm);
    }

    [WebMethod(Description = "保存数据")]
    public string saveData(string objStr, string username, string tzid, string[] tmArray, string[] xmArray, string tmDict)
    {
        return w.saveData(objStr, username, tzid, tmArray, xmArray, tmDict);
    }

    //获取'物料领用计划单'对应的所有款号
    [WebMethod(Description = "获取'物料领用计划单'对应的所有款号")]
    public string GetLyJhDKhInfo(string tzid, string id)
    {
        return w.GetLyJhDKhInfo(tzid, id);
    }

    //通过'物料领用计划单'生成条码
    [WebMethod(Description = "通过'物料领用计划单'生成条码")]
    public string GetLyJhDInfo(string tzid, string zdr, string ids, string chdm)
    {
        return w.GetLyJhDInfo(tzid, zdr, ids, chdm);
    }

  

    //条码生成模块的条码信息查询
    [WebMethod(Description = "条码生成模块的条码信息查询")]
    public String GetTMInfo(string tmcode)
    {
        return w.GetTMInfo(tmcode);
    }

    //条码生成模块的条码生成函数    
    [WebMethod(Description = "条码生成模块的条码生成函数")]
    public string GenerateTM(string SourceID, double sl, string zl, string kh, string bz, string zdr)
    {
        return w.GenerateTM(SourceID, sl, zl, kh, bz, zdr);
    }



    //查询单据是否有未保存的条码   
    [WebMethod(Description = "查询单据是否有未保存的条码")]
    public string checkDJInfo(DataTable datacldjh, string tzid)
    {
        return w.checkDJInfo(datacldjh, tzid);
    }



   

}
