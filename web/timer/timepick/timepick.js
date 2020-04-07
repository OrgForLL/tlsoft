addEventListener('DOMContentLoaded', function () {
	
	var plus_5_days = new Date;
	plus_5_days.setDate(plus_5_days.getDate() + 5);
	//plus_5_days="2019-02-01"
	
	//var dt = new Date('2020-12-25')
	//plus_5_days = dt;
    //alert(plus_5_days)
	//var plus_6_days = new Date;
	//plus_6_days.setDate(plus_6_days.getDate() + 6);
	var dataList = new Array();
	//dataList.push(new Date);
//	dataList.push(plus_5_days)
//	dataList.push(plus_6_days)
	pickmeup('.multiple', {
	    flat: true,
	    date: dataList,
	    mode: 'multiple',
	    calendars: 12
	});
	
});
