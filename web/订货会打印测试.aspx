<%@ Page Language="C#" AutoEventWireup="true" CodeFile="订货会打印测试.aspx.cs" Inherits="订货会打印测试" %>

<!DOCTYPE html>

<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
<meta http-equiv="Content-Type" content="text/html; charset=utf-8"/>
    <title></title>
</head>
<body>
    <form id="form1" runat="server">
    <div>

        <table cellspacing="0" cellpadding="0" width="100%" border="0">
            <tbody>
                <tr height="30">
                    <td class="blue" width="60" align="right">季度: </td>
                    <td valign="middle" width="10" align="left">
                        <select id="Select1" class="kfs" style="width: 130px" name="cpjj">
                            <option selected value="19春季">19春季</option>
                            <option value="19夏季">19夏季</option>
                            <option value="19秋季">19秋季</option>
                            <option value="19冬季">19冬季</option>
                            <option value="18春季">18春季</option>
                            <option value="18夏季">18夏季</option>
                            <option value="18秋季">18秋季</option>
                            <option value="18冬季">18冬季</option>
                            <option value="17春季">17春季</option>
                            <option value="17夏季">17夏季</option>
                            <option value="17秋季">17秋季</option>
                            <option value="17冬季">17冬季</option>
                            <option value="16春季">16春季</option>
                            <option value="16夏季">16夏季</option>
                            <option value="16秋季">16秋季</option>
                            <option value="16冬季">16冬季</option>
                            <option value="15春季">15春季</option>
                            <option value="15夏季">15夏季</option>
                            <option value="15秋季">15秋季</option>
                            <option value="15冬季">15冬季</option>
                            <option value="14春季">14春季</option>
                            <option value="14夏季">14夏季</option>
                            <option value="14秋季">14秋季</option>
                            <option value="14冬季">14冬季</option>
                            <option value="13春季">13春季</option>
                            <option value="13夏季">13夏季</option>
                            <option value="13秋季">13秋季</option>
                            <option value="13冬季">13冬季</option>
                            <option value="12春季">12春季</option>
                            <option value="12夏季">12夏季</option>
                            <option value="12秋季">12秋季</option>
                            <option value="12冬季">12冬季</option>
                            <option value="11春季">11春季</option>
                            <option value="11夏季">11夏季</option>
                            <option value="11秋季">11秋季</option>
                            <option value="11冬季">11冬季</option>
                            <option value="10春季">10春季</option>
                            <option value="10夏季">10夏季</option>
                            <option value="10秋季">10秋季</option>
                            <option value="10冬季">10冬季</option>
                            <option value="09春季">09春季</option>
                            <option value="09夏季">09夏季</option>
                            <option value="09秋季">09秋季</option>
                            <option value="09冬季">09冬季</option>
                        </select>
                    </td>
                    
                        <td class="blue" width="80" align="right">确认开始日: </td>
                        <td valign="middle" width="10" align="left">
                            <input tabindex="2" onblur="checkday(this)" id="ksrq" class="blk" style="width: 67px" oncontextmenu="setday(this,'')" size="10" value="2018-05-01" name="ksrq">
                        </td>
                        <td class="blue" width="60" align="center">生产项目 </td>
                        <td valign="middle" width="10" align="left">
                            <select id="Select2" class="kfs" style="width: 100px" name="scxmlb">
                                <option selected value="7686">A8.面辅料采购部(v10)</option>
                                <option value="8051">C1.业务一部</option>
                                <option value="8052">C2.业务二部</option>
                                <option value="8053">C3.业务三部</option>
                                <option value="8054">C5.业务五部</option>
                                <option value="8055">C6.业务六部</option>
                                <option value="8056">C7.业务一部配饰类</option>
                                <option value="0">全部</option>
                            </select>
                        </td>
                        <td class="blue" valign="middle" width="80" align="left">按款下单
                            <input type="checkbox" name="iskh">
                        </td>
                        <td class="blue" width="60" align="center">预投 </td>
                        <td valign="middle" width="50" align="left">
                            <select id="ytbs" class="kfs" style="width: 50px" name="ytbs">
                                <option selected value="2">全部</option>
                                <option value="1">预投</option>
                                <option value="0">大货</option>
                            </select>
                        </td>
                    <td></td>
                        <td>&nbsp; </td>
                        <td class="blue" width="45" align="center">生成日 </td>
                        <td valign="middle" width="10" align="left">
                            <input tabindex="2" onblur="checkday(this)" id="ddrq" class="blk" style="width: 67px" oncontextmenu="setday(this,'')" size="10" value="2018-05-24" name="ddrq">
                        </td>
                        <!--物料采购订单  单据别  621-->
                        <td class="blue" width="120" nowrap>单据别<select id="Select2" class="kfs" style="width: 83px" name="djlb">
                            <option selected value="2144">02.加工</option>
                            <option value="2143">01.贴牌</option>
                        </select>
                        </td>
                        <td valign="middle" width="54">
                            <input onclick="vbscript: window.parent.close()" class="blk" style="width: 60px" type="button" value="关闭窗口">
                        </td>
                </tr>
                <tr height="24">
                    <td class="blue" width="62" align="right">物料编号: </td>
                    <td width="10" align="left">
                        <input id="chdm" class="blk" style="width: 70px" size="16" name="chdm">
                    </td>
                    <td class="blue" width="80" align="right">确认结束日: </td>
                    <td valign="middle" width="10" align="left">
                        <input tabindex="2" onblur="checkday(this)" id="jsrq" class="blk" style="width: 67px" oncontextmenu="setday(this,ksrq.value)" size="10" value="2018-05-24" name="jsrq">
                    </td>
                    <td class="blue" width="60" align="center">跟踪号 </td>
                    <td valign="middle" width="10" align="left">
                        <input tabindex="2" class="blk" style="width: 100px" name="cggzh">
                    </td>
                    <td class="blue" width="50" align="center">FOB
                        <input type="checkbox" name="fob">
                    </td>
                    <td class="blue" colspan="2"  align="center">不签订合同订单
                        <input type="checkbox" name="bqdhtdd">
                    </td>
                 
                    <td valign="middle" width="54">
                        <input onclick="javascript: TcRef()" class="blk" style="width: 54px" type="button" value="刷新">
                    </td>
                    <td>&nbsp; </td>
                    <td class="blue" width="45" align="center">采购员 </td>
                    <td valign="middle" width="10" align="left">
                        <input tabindex="2" id="cgry" class="blk" style="width: 67px" size="10" name="cgry">
                    </td>
                    <td class="blue" width="120" nowrap>分&nbsp;&nbsp;类<select id="Select2" class="kfs" style="width: 83px" name="djfl">
                        <option selected value="7567">01.辅料</option>
                        <option value="7568">05.面料合同</option>
                        <option value="7578">03.共用辅料</option>
                    </select>
                    </td>
                    <td valign="middle" width="54">
                        <input onclick="javascript: DDsc('ddsc')" class="blk" style="width: 60px" type="button" value="订单生成" name="Myddsc">
                    </td>
                </tr>
            </tbody>
        </table>        
    </div>
    </form>
</body>
</html>
