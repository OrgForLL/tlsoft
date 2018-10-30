  document.writeln('<div id=meizzZWNYLayer style="position:absolute;width:188;height:86; z-index:9998;display:none;">');   
  document.writeln('<table border=0 cellspacing=1 cellpadding=0 width=188 height=80 bgcolor=#808080 onselectstart="return false" Author=meizz>');   
  document.writeln('<tr><td width=188 height=21 bgcolor=#FFFFFF Author=meizz><table border=0 cellspacing=1 cellpadding=0 width=188 height=21 Author=meizz><tr align=center>');   
  document.writeln('<td width=24 align=center bgcolor=#808080 style="FONT-WEIGHT:bold;font-size:13px;cursor: hand;color:#FFD700" Author=meizz>◆</td>');   
  document.writeln('<td align=center style="font-size:12px;cursor:default" Author=meizz>财务年度：<span id=tmpSelectNDLayer Author=meizz></span></td>');   
  document.writeln('<td width=24 bgcolor=#808080  align=center style="FONT-WEIGHT: bold;font-size:13px;cursor: hand;color:#FFD700" Author=meizz>◆</td>');   
  document.writeln('</tr></table></td></tr>');   
  document.writeln('<tr><td width=188 height=16 bgcolor=#808080 Author=meizz><table border=0 width=100% cellspacing=1 cellpadding=0 Author=meizz>');   
  document.writeln('<tr><td align=center style="FONT-WEIGHT: bold;font-size:12px;color:#FFFFFF" Author=meizz><b Author=meizz>会计期间</b></td></table></td></tr>');   
  document.writeln('<tr><td id=meizzNYLayer width=188 height=50 Author=meizz>');
  document.writeln('</td></tr><tr><td width=188 height=2 bgcolor=#808080 Author=meizz><table border=0 cellspacing=1 cellpadding=0 Author=meizz>');   
  document.writeln('<tr align=center><td Author=meizz></td></table></td></tr>');   
  document.writeln('<tr><td width=188 height=21 bgcolor=#FFFFFF Author=meizz>');   
  document.writeln('<table border=0 cellspacing=1 cellpadding=0 width=188 height=20 bgcolor=#FFFFFF Author=meizz>');   
  document.writeln('<tr height=20 align=center Author=meizz>');
  document.writeln('<td align=right style="font-size:12px;" id=meizzJZNYText Author=meizz></td>');   
  document.writeln('<td width=40 align=cebter><span onclick=closeZWNYLayer()  style="font-size:12px;cursor:hand" Author=meizz ><u>关闭</u></span></td></tr>');   
  document.writeln('</table></td></tr></table><iframe style="position:absolute; visibility:inherit;top:0px; left:0px; width:188px; height:166px; z-index:-1; filter=progid:DXImageTransform.Microsoft.Alpha(style=0,opacity=0);"></iframe></div>');   

var   outObject; 
var   meizzWDay = new   Array(12);    //定义写月份单元的数组
var   meizzDQcs = new   Array(17);     //帐务会计年度若干参数数组(会计年度，开始年月，会计期数)
var   meizzZWcs = new   Array(4);     //帐务会计年度若干参数数组(最小年度，最大年度，启用年月，结转年月)
var   meizzJSYF;					  //该年度结束月份
  
function   setkjny(tt,yy,limstr)   //主调函数   
{   
    if   (arguments.length > 3){alert("对不起！传入本控件的参数太多！");return;}   
    if   (arguments.length   ==   0){alert("对不起！您没有传回本控件任何参数！");return;}   
    var   dads  = document.all.meizzZWNYLayer.style;
    var th = tt; yh = yy;
    outObject = th;
    outObject_y = yh;
    var   ttop  = tt.offsetTop;           //TT控件的定位点高   
    var   thei  = tt.clientHeight;     //TT控件本身的高   
    var   tleft = tt.offsetLeft;       //TT控件的定位点宽   
    var   ttyp  = tt.type;                     //TT控件的类型
    var   str = tt.value;
    while   (tt = tt.offsetParent){ttop+=tt.offsetTop; tleft+=tt.offsetLeft;}   
    dads.top = (ttyp=="image")? ttop+thei:ttop+thei+6;   
    dads.left = tleft;   
    dads.display = '';
    meizzDQcs[0] = yy.value;
	var arrdate = str.split("年");
	meizzDQNY = arrdate[0] + arrdate[1].split("月")[0];
	meizzZWcs = limstr.split('|')
    document.all.meizzJZNYText.innerText = "帐务当前年月:" + meizzZWcs[3].substr(0,4) + "年" + meizzZWcs[3].substr(4,2) + "月";
    if (typeof(document.all.meizzZWRQLayer)=='object') document.all.meizzZWRQLayer.style.display="none";
    meizzWriteHead(Number(meizzZWcs[0]),Number(meizzZWcs[1]),Number(meizzDQcs[0]));
	meizzSetDay();
    event.returnValue=false;   
}

function   document.onclick()   //任意点击时关闭该控件   
{     
    with(window.event.srcElement)   
    {  
    //if   (getAttribute("Author")==null && tagName != "INPUT" && document.all.meizzZWNYLayer != null)
    if   (getAttribute("Author")==null)
        document.all.meizzZWNYLayer.style.display="none";
    }   
}   

function   meizzWriteHead(ksnf,jsnf,m)     //往   head   中写入当前的年与月   ksnf=2007 ,jsnf=2010 ,m=2010
{
    var   s  =   "<select name='tmpSelectYear' Author=meizz style='font-size:12px;width:62;' "   
        s +=   "onchange='meizzSetDay()'>\r\n";   
    var   selectInnerHTML   =   s;
    if (m > jsnf) m = jsnf;   
    for   (var i = jsnf; i >= ksnf; i--)   
    {   
        if   (i   ==   m)   
            {selectInnerHTML +=  "<option  value='" + i + "'selected>" + i +  "年" + "</option>\r\n";}   
        else   {selectInnerHTML +=  "<option  value='" + i + "'>" + i + "年" + "</option>\r\n";}   
    }   
    selectInnerHTML += "</select>";   
    document.all.tmpSelectNDLayer.style.display="";   
    document.all.tmpSelectNDLayer.innerHTML   = selectInnerHTML;   
}   

function   closeZWNYLayer()                               //这个层的关闭   
    {   
        document.all.meizzZWNYLayer.style.display="none";   
    }   

function   document.onkeydown()   
    {   
        if   (window.event.keyCode==27) document.all.meizzZWNYLayer.style.display="none";   
    }   

function   meizzSetDay()       //主要的写程序**********  
{	
	var Myhttp = new ActiveXObject('Microsoft.XMLHTTP');
	var MyUrl = "BB_inc_getRqQj.aspx?nd=" + document.all.tmpSelectYear.value;
//	var MyUrl = "cw_getpar_kjqj.aspx?nd=2010" 
	Myhttp.open('GET',MyUrl, false);
	Myhttp.send();
	var rValue = Myhttp.responseText.split('|');
	if (rValue.length == 3) {meizzDQcs = rValue[1].split("^");} else {return;};
    var yfHTML = '<table border=0 cellspacing=1 cellpadding=0 width=188 height=100 bgcolor=#FFFFFF>';
    var n = 0; 
    for (var i = 1; i < (meizzDQcs[1]/2) + 1; i++) {
		n++;
		yfHTML += '<tr align=center><td bgcolor=#808080 width=24 align=center style="FONT-WEIGHT:bold;font-size:12px;color:#FFFFFF" Author=meizz>' + n + '</td>';
		yfHTML += '<td width=70 height=18 align=center '
		if (meizzDQcs[n + 1] < meizzZWcs[2]) {yfHTML += 'bgcolor=#EEEEEE style="font-size:12px;color:#666666" Author=meizz>'}
			else if (meizzDQcs[n + 1] == meizzDQNY) {yfHTML += 'bgcolor=#EEEE00 onmouseover=meizzSetCol(this,1) onmouseout=meizzSetCol(this,2) id=meizzZWNY' + n + ' style="font-size:12px;color:#000001" Author=meizz onclick=meizzNYClick(this)>'};
			else {yfHTML += 'bgcolor=#DDDEEE onmouseover=meizzSetCol(this,1) onmouseout=meizzSetCol(this,2) id=meizzZWNY' + n + ' style="font-size:12px;color:#000000" Author=meizz onclick=meizzNYClick(this)>'};
		yfHTML += '<b Author=meizz>' + meizzDQcs[n + 1]   + '</b></td>';
		n++; 
		yfHTML += '<td bgcolor=#808080 width=24 align=center style="FONT-WEIGHT:bold;font-size:12px;color:#FFFFFF" Author=meizz>' + n + '</td>';
		yfHTML += '<td width=70 height=18 align=center '
		if (meizzDQcs[n + 1] < meizzZWcs[2]) {yfHTML += 'bgcolor=#EEEEEE style="font-size:12px;color:#666666" Author=meizz>'}
			else if (meizzDQcs[n + 1] == meizzDQNY) {yfHTML += 'bgcolor=#EEEE00 onmouseover=meizzSetCol(this,1) onmouseout=meizzSetCol(this,2) id=meizzZWNY' + n + ' style="font-size:12px;color:#000001" Author=meizz onclick=meizzNYClick(this)>'};
			else {yfHTML += 'bgcolor=#DDDEEE onmouseover=meizzSetCol(this,1) onmouseout=meizzSetCol(this,2) id=meizzZWNY' + n + ' style="font-size:12px;color:#000000" Author=meizz onclick=meizzNYClick(this)>'};
		yfHTML += '<b Author=meizz>' + meizzDQcs[n + 1]   + '</b></td></tr>';
	};
	meizzJSYF = meizzDQcs[n + 1];
	document.all.meizzNYLayer.innerHTML = yfHTML + '</table>';
}
function   meizzSetCol(obj,dz)       //背景色变化**********   
{   var	dads = obj.style
if (dz==1){
	if (dads.color=="#000001") {dads.backgroundColor="#FFD705";} else {dads.backgroundColor="#FFD700";}
}
else {
	if (dads.color=="#000001") {dads.backgroundColor="#EEEE00";} else {dads.backgroundColor="#DDDEEE";}}
}

function   meizzNYClick(obj)     //点击显示框选取日期，主输入函数*************   
{   
    if (outObject) {
		outObject.value = obj.innerText.substr(0,4) + "年" + obj.innerText.substr(4,2) + "月";
		if (typeof(MyForm.ny0)!=='undefined'){MyForm.ny0.value=obj.innerText};
		if (outObject_y.value != document.all.tmpSelectYear.value) outObject_y.value = document.all.tmpSelectYear.value;
		if (typeof(TLZWny_change) == 'function') {TLZWny_change(outObject.name,meizzDQcs[2],meizzJSYF)};
        closeZWNYLayer();
    } else {
		closeZWNYLayer();   alert("您所要输出的控件对象并不存在！");
	}   
}   
