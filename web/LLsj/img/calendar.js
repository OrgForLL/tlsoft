  var ltoday = "";
  var stoday = "";
  var limday = "";
  function   GetToday()
  {   
      var   yy   =   new Date().getFullYear();   
      var   mm   =   new Date().getMonth()+1;
      var   rr   =   new Date().getDate();   
      if   (mm < 10){mm = "0" +mm}   
      if   (rr < 10){rr = "0" +rr}   
      ltoday = yy + '��' + mm + '��' + rr + '��';  
      stoday = yy + '-' + mm + '-' + rr;  
  }
  GetToday()
  document.writeln('<div id=meizzDateLayer style="position:absolute;width:188;height:166; z-index:9998;display:none;">');   
  document.writeln('<span id=tmpSelectYearLayer  style="z-index:   9999;position: absolute;top:2;left:31;display:none"></span>');   
  document.writeln('<span id=tmpSelectMonthLayer style="z-index:   9999;position: absolute;top:2;left:100;display:none"></span>');   
  document.writeln('<table border=0 cellspacing=1 cellpadding=0 width=188 height=160 bgcolor=#808080 onselectstart="return false">');   
  document.writeln('<tr><td width=188 height=21 bgcolor=#FFFFFF><table border=0 cellspacing=1 cellpadding=0 width=188 height=21>');   
  document.writeln('<tr align=center><td  width=30  align=center bgcolor=#808080 style="FONT-WEIGHT:bold;font-size:13px;cursor: hand;color:#FFD700"');   
  document.writeln('onclick="meizzPrevM()" title=" ���� " Author=meizz><b Author=meizz>&lt;&lt;</b>');   
  document.writeln('</td><td width=128 align=center style="font-size:12px;cursor:default" Author=meizz><span ');   
  document.writeln('onmouseover="style.backgroundColor=\'#FFD700\'"onmouseout="style.backgroundColor=\'white\'" title="���ѡ�����"');   
  document.writeln(' Author=meizz id=meizzYearHead onclick="tmpSelectYearInnerHTML(this.innerText)"></span>&nbsp;��&nbsp;<span');   
  document.writeln('onmouseover="style.backgroundColor=\'#FFD700\'" onmouseout="style.backgroundColor=\'white\'" title="���ѡ���·�"');   
  document.writeln('id=meizzMonthHead   Author=meizz onclick="tmpSelectMonthInnerHTML(this.innerText)"></span>&nbsp;��</td>');   
  document.writeln('<td width=30 bgcolor=#808080  align=center style="FONT-WEIGHT: bold;font-size:13px;cursor: hand;color:#FFD700"');   
  document.writeln('onclick="meizzNextM()" title=" ���� " Author=meizz><b Author=meizz>&gt;&gt;</b></td></tr>');   
  document.writeln('</table></td></tr>');
  document.writeln('<tr><td width=188 height=15 bgcolor=#808080>');   
  document.writeln('<table border=0 cellspacing=1 cellpadding=0 width=188 height=1 style="cursor:default">');   
  document.writeln('<tr align=center><td width=26 style="font-size:12px;color:#FFFFFF" Author=meizz>��</td>');   
  document.writeln('<td width=26 style="font-size:12px;color:#FFFFFF" Author=meizz>һ</td><td width=26 style="font-size:12px;color:#FFFFFF"   Author=meizz>��</td>');   
  document.writeln('<td width=26 style="font-size:12px;color:#FFFFFF" Author=meizz>��</td><td width=26 style="font-size:12px;color:#FFFFFF"   Author=meizz>��</td>');   
  document.writeln('<td width=26 style="font-size:12px;color:#FFFFFF" Author=meizz>��</td><td width=26 style="font-size:12px;color:#FFFFFF"   Author=meizz>��</td></tr>');   
  document.writeln('</table></td></tr>');   
  document.writeln('<tr><td width=188 height=120>');   
  document.writeln('<table border=0 cellspacing=1 cellpadding=0 width=188 height=108 bgcolor=#FFFFFF>');   
  var n=0; 
	for (j=0;j<6;j++){
		document.writeln   ('<tr align=center>');   
		for   (i=0;i<7;i++){   
			document.writeln('<td width=26 height=17 onmouseover=meizzSetCol(this,1) onmouseout=meizzSetCol(this,2) id=meizzDay'+n+' style="font-size:12px;color:#000000" Author=meizz onclick=meizzDayClick(this)></td>');
			n++;
		}   
			document.writeln('</tr>');
	}   
  document.writeln('<tr height=20 align=center>');   
  document.writeln('<td colspan=5 align=right Author=meizz><span onclick="meizzToday()" style="font-size:12px;cursor:hand" Author=meizz ><u>����:' + ltoday + '</u></span></td>');   
  document.writeln('<td colspan=2 align=cebter  Author=meizz><span onclick=closeLayer()  style="font-size:12px;cursor:hand" Author=meizz ><u>�ر�</u></span></td></tr>');   
  document.writeln('</table></td></tr></table><iframe style="position:absolute; visibility:inherit;top:0px; left:0px; width:188px; height:166px; z-index:-1; filter=progid:DXImageTransform.Microsoft.Alpha(style=0,opacity=0);"></iframe></div>');   

var   outObject; 
var   MonHead   =   new   Array(12);               //����������ÿ���µ��������   
      MonHead[0] = 31;MonHead[1] = 28; MonHead[2] =  31; MonHead[3] = 30; MonHead[4] = 31; MonHead[5] = 30;   
      MonHead[6] = 31;MonHead[7] = 31;MonHead[8] = 30; MonHead[9] = 31; MonHead[10] = 30; MonHead[11] = 31;   
var   meizzTheYear = new   Date().getFullYear();   //������ı����ĳ�ʼֵ   
var   meizzTheMonth = new   Date().getMonth()+1;   //�����µı����ĳ�ʼֵ   
var   meizzTheDat = new   Date().getDate();   //�����µı����ĳ�ʼֵ   
var   meizzWDay = new   Array(42);                               //����д���ڵ�����
var   ymeizzTheYear = new   Date().getFullYear();   //������ı����ĳ�ʼֵ   
var   ymeizzTheMonth = new   Date().getMonth()+1;   //�����µı����ĳ�ʼֵ   
var   ymeizzTheDat = new   Date().getDate();   //�����µı����ĳ�ʼֵ   
  
function   checkday(tt,limstr)   //ֱ������   
{
    if   (arguments.length > 3){alert("�Բ��𣡴��뱾�ؼ��Ĳ���̫�࣡");return;}   
    if   (arguments.length   ==   0){alert("�Բ�����û�д��ر��ؼ��κβ�����");return;}
    var   str = tt.value;
    if (arguments.length == 1) {limday = '1901-01-01';} else {
	if (limstr == "") {limday = '1901-01-01';} else {limday = limstr;} }
	//2010-08-24 ke  ���ֵΪ����Ĭ��ȡ��������
    if(str.length==0){str=getToday();}
	if   (! checkDate(str)){alert("��������ڸ�ʽ�Ƿ���"); tt.focus(); return;} 
	var arrdate = str.split("-");
	str = arrdate[0] + "-"; str += ((Number(arrdate[1]) < 10) ? "0" : "") + Number(arrdate[1]).toString() + "-";
	str += ((Number(arrdate[2]) < 10) ? "0" : "") + Number(arrdate[2]).toString();
    if   (limday > str){tt.value = limday;}
}
function   setday(tt,limstr)   //��������   
{   
    if   (arguments.length > 3){alert("�Բ��𣡴��뱾�ؼ��Ĳ���̫�࣡");return;}   
    if   (arguments.length   ==   0){alert("�Բ�����û�д��ر��ؼ��κβ�����");return;}   
    var   dads =   document.all.meizzDateLayer.style; var th = tt;
    var   ttop =   tt.offsetTop;           //TT�ؼ��Ķ�λ���   
    var   thei   =   tt.clientHeight;     //TT�ؼ�����ĸ�   
    var   tleft   =   tt.offsetLeft;         //TT�ؼ��Ķ�λ���   
    var   ttyp   =   tt.type;                     //TT�ؼ�������
    var   str = tt.value;
    //2010-08-24 ke  ���ֵΪ����Ĭ��ȡ��������
    if(str.length==0){str=getToday();}
	if (! checkDate(str)){
		alert("��������ڸ�ʽ�Ƿ���");
		tt.focus(); 
		return;
	};
	var arrdate = str.split("-");
	str = arrdate[0] + "-"; str += ((Number(arrdate[1]) < 10) ? "0" : "") + Number(arrdate[1]).toString() + "-";
	str += ((Number(arrdate[2]) < 10) ? "0" : "") + Number(arrdate[2]).toString();
    while   (tt   =   tt.offsetParent){ttop+=tt.offsetTop;   tleft+=tt.offsetLeft;}   
    dads.top  =  (ttyp=="image")?   ttop+thei:ttop+thei+6;   
    dads.left  =   tleft;   
    dads.display   =   '';
    outObject =  th;   
    meizzTheYear = Number(str.substr(0,4));
    meizzTheMonth = Number(str.substr(5,2));
    meizzTheDay = Number(str.substr(8,2));
    ymeizzTheYear = Number(str.substr(0,4));
    ymeizzTheMonth = Number(str.substr(5,2));
    ymeizzTheDay = Number(str.substr(8,2));
    meizzSetDay(meizzTheYear,meizzTheMonth);
    if (arguments.length == 1) {limday = '1901-01-01';} else {
	if (limstr == "") {limday = '1901-01-01';} else {limday = limstr;}
	}
    event.returnValue=false;   
}

function   document.onclick()   //������ʱ�رոÿؼ�   
{     
    with(window.event.srcElement)   
    {  
    if   (getAttribute("Author")==null   &&   tagName   !=   "INPUT")   
//       if  (getAttribute("Author")==null )   
        document.all.meizzDateLayer.style.display="none"; 
        if (typeof(MyFunc_RqChange) == 'function') {MyFunc_RqChange();}  
    }   
}   

function   meizzWriteHead(yy,mm)     //��   head   ��д�뵱ǰ��������   
    {   document.all.meizzYearHead.innerText     =   yy;   
        document.all.meizzMonthHead.innerText   =   mm;   
    }   

function   tmpSelectYearInnerHTML(strYear)   //��ݵ�������   
{   
    if   (strYear.match(/\D/)!=null){alert("�����������������֣�");return;}   
    var   m   =   (strYear) ? strYear : new  Date().getFullYear();   
    if   (m  < 1000 ||  m > 9999) {alert("���ֵ����1000��9999֮�䣡");return;}   
    var   n   =   m   -   10;   
    if   (n   <   1000)   n   =   1000;   
    if   (n   +   26   >   9999)   n   =   9974;   
    var   s  =   "<select Author=meizz   name=tmpSelectYear   style='font-size:12px;width:70'"   
        s +=   "onblur='document.all.tmpSelectYearLayer.style.display=\"none\"'   "   
        s +=   "onchange='document.all.tmpSelectYearLayer.style.display=\"none\";"   
        s +=   "meizzTheYear = this.value; meizzSetDay(meizzTheYear,meizzTheMonth)'>\r\n";   
    var   selectInnerHTML   =   s;   
    for   (var i = n; i < n + 26;i++)   
    {   
        if   (i   ==   m)   
            {selectInnerHTML +=  "<option  value='" + i + "'selected>" + i +  "��" + "</option>\r\n";}   
        else   {selectInnerHTML +=  "<option  value='" + i + "'>" + i + "��" + "</option>\r\n";}   
    }   
    selectInnerHTML += "</select>";   
    document.all.tmpSelectYearLayer.style.display="";   
    document.all.tmpSelectYearLayer.innerHTML   = selectInnerHTML;   
    document.all.tmpSelectYear.focus();   
}   

function   tmpSelectMonthInnerHTML(strMonth)   //�·ݵ�������   
{   
    if   (strMonth.match(/\D/)!=null){alert("�·���������������֣�");return;}   
    var   m   =   (strMonth)   ?   strMonth   :   new   Date().getMonth()   +   1;   
    var   s   =   "<select   Author=meizz   name=tmpSelectMonth   style='font-size:12px;width:60'"   
        s   +=   "onblur='document.all.tmpSelectMonthLayer.style.display=\"none\"'   "   
        s   +=   "onchange='document.all.tmpSelectMonthLayer.style.display=\"none\";"   
        s   +=   "meizzTheMonth   =   this.value;   meizzSetDay(meizzTheYear,meizzTheMonth)'>\r\n";   
    var   selectInnerHTML   =   s;   
    for   (var i = 1; i < 13; i++)   
    {   
        if   (i   ==   m)   
            {selectInnerHTML += "<option   value='"+i+"'selected>"+i+"��"+"</option>\r\n";}   
        else   {selectInnerHTML += "<option   value='"+i+"'>"+i+"��"+"</option>\r\n";}  

    }   
    selectInnerHTML   +=   "</select>";   
    document.all.tmpSelectMonthLayer.style.display="";   
    document.all.tmpSelectMonthLayer.innerHTML   =   selectInnerHTML;   
    document.all.tmpSelectMonth.focus();   
}   

function   closeLayer()                               //�����Ĺر�   
    {   
        document.all.meizzDateLayer.style.display="none";   
    }   

function   document.onkeydown()   
    {   
        if   (window.event.keyCode==27)document.all.meizzDateLayer.style.display="none";   
    }   

function   IsPinYear(year)                         //�ж��Ƿ���ƽ��   
    {   
        if   (0==year%4&&((year%100!=0)||(year%400==0)))   return   true;
        else   return false;   
    }   

function   GetMonthCount(year,month)     //�������Ϊ29��   
    {   
        var   c=MonHead[month-1];
        if((month==2)&&IsPinYear(year))   c++;
        return   c;   
    }   

function   GetDOW(day,month,year)           //��ĳ������ڼ�   
    {   
        var   dt=new   Date(year,month-1,day).getDay()/7;   return   dt;   
    }   

function   meizzPrevY()     //��ǰ��   Year   
    {   
        if(meizzTheYear   >   999   &&   meizzTheYear   <10000){meizzTheYear--;}   
        else{alert("��ݳ�����Χ��1000-9999����");}   
        meizzSetDay(meizzTheYear,meizzTheMonth);   
    }   
function   meizzNextY()     //����   Year   
    {   
        if(meizzTheYear   >   999   &&   meizzTheYear   <10000){meizzTheYear++;}   
        else{alert("��ݳ�����Χ��1000-9999����");}   
        meizzSetDay(meizzTheYear,meizzTheMonth);   
    }   
function   meizzToday()     //Today   Button   
    {   
        outObject.value= stoday
    }   
function   meizzPrevM()     //��ǰ���·�   
    {   
        if(meizzTheMonth>1){meizzTheMonth--}else{meizzTheYear--;meizzTheMonth=12;}   
        meizzSetDay(meizzTheYear,meizzTheMonth);   
    }   
function   meizzNextM()     //�����·�   
    {   
        if(meizzTheMonth==12){meizzTheYear++;meizzTheMonth=1}else{meizzTheMonth++}   
        meizzSetDay(meizzTheYear,meizzTheMonth);   
    }   

function   meizzSetDay(yy,mm)       //��Ҫ��д����**********  
{   
    meizzWriteHead(yy,mm);   
    for (var i = 0; i < 42; i++){meizzWDay[i]=""};     //����ʾ�������ȫ�����   
    var day1 = 1,firstday  =  new Date(yy,mm-1,1).getDay();     //ĳ�µ�һ������ڼ�   
    for (var i = firstday; day1 < GetMonthCount(yy,mm)+1; i++){meizzWDay[i]=day1;day1++;}   
    for (var i = 0; i < 42; i++)   
    {   var   da   =   eval("document.all.meizzDay"+i)           //��д�µ�һ���µ�������������   
        if   (meizzWDay[i]!="")   
            {   da.innerHTML =  "<b>" + meizzWDay[i]   + "</b>";   
                da.style.backgroundColor = "#DDDEEE";   
				da.style.color="#000000";
                da.style.cursor="hand"   
            }   
        else{da.innerHTML="";da.style.backgroundColor="#EEEEEE";da.style.cursor="hand"}
        if (new Date(yy,mm-1,meizzWDay[i]).getDay()==6 || new Date(yy,mm-1,meizzWDay[i]).getDay()==0) {da.style.color="red";}
        if (meizzWDay[i]==ymeizzTheDay && yy==ymeizzTheYear && mm==ymeizzTheMonth) {da.style.backgroundColor = "#EEEE00";}
    } 
    day1 = 1;
    for (var i = 26; i < 42; i++)
    {
	if (meizzWDay[i]=="")  {
	da   =   eval("document.all.meizzDay"+i);
	da.innerHTML="<b>" + day1 + "</b>";
	da.style.color="#666666";
	day1++}
	}
	if(mm==1){day1 = GetMonthCount(yy--,12)}else{day1 = GetMonthCount(yy,mm-1)} 
	i = 7
	while (i >= 0)
	{if (meizzWDay[i]=="")  {
	da  = eval("document.all.meizzDay"+i);
	da.innerHTML="<b>" + day1 + "</b>";
	da.style.color="#666666";
	day1--}
	i--;
	}
}
function   meizzSetCol(obj,dz)       //����ɫ�仯**********   
{   var	dads     =   obj.style
if (dz==1){
	if (dads.backgroundColor=="#eeee00") {dads.backgroundColor="#FFD705";} else {dads.backgroundColor="#FFD700";}
}
else {
	if (dads.backgroundColor=="#ffd705") {dads.backgroundColor="#EEEE00";} else {
		if (dads.color!="#666666")
			{dads.backgroundColor="#DDDEEE";} else {dads.backgroundColor="#EEEEEE";}}}
}

function   meizzDayClick(obj)     //�����ʾ��ѡȡ���ڣ������뺯��*************   
{   
    var   yy   =   meizzTheYear;   
    var   mm   =   meizzTheMonth;   
    var   rr   =   obj.innerText;
    if (obj.style.color=="#666666" && rr > 21) {
		if (mm==1) {mm=12;yy--;} else {mm--;}}
    if (obj.style.color=="#666666" && rr < 15) {
		if (mm==12) {mm=1;yy++;} else {mm++;}}
    if   (mm   <   10){mm   =   "0"   +   mm;}   
    if   (rr   <   10){rr   =   "0"   +   rr;}
    var	clickday = yy + "-" + mm + "-" + rr
    if   (outObject)   
    {   
        if   (!rr)   {outObject.value="";   return;}
        if  (limday <= clickday){
			outObject.value = clickday;}   //ע:���������������ĳ�����Ҫ�ĸ�ʽ 
		else {outObject.value = limday;}
        closeLayer();     
    }   
    else   {closeLayer();   alert("����Ҫ����Ŀؼ����󲢲����ڣ�");}   
}   
function checkDate(str)     //��������ַ�����ʽ�Ƿ�Ϸ�*************   
{
	var r = str.match(/^(\d{1,4})(-|\/)(\d{1,2})\2(\d{1,2})$/);
	if (r==null) {return false;}
	else {
		var d = new Date(r[1],r[3]-1,r[4]);
		return (d.getFullYear()==r[1] && (d.getMonth()+1)==r[3] && d.getDate()==r[4]);
	}
}
function getToday(){      //���ص��������  ��ʽΪ2010-01-05
    var date=new Date();
    var year=date.getYear();
    var month=date.getMonth()+1;
    return ""+year+"-"+month+"-01";
}
