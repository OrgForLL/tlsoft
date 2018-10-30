<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
<meta http-equiv="Content-Type" content="text/html; charset=utf-8" />
<title>无标题文档</title>

    <link rel="stylesheet" href="http://fonts.googleapis.com/css?family=Open+Sans:300,400,700">
    <link rel="stylesheet" href="css/themes/default/jquery.ui.datepicker.mobile.css">
    <link rel="stylesheet" href="css/themes/default/jquery.mobile-1.3.1.min.css">
    <script src="js/jquery.js"></script>
    <script src="js/jquery.mobile-1.3.1.min.js"></script>

<script type="text/javascript">
    var checkType = 0;
    $(document).ready(function () {
        $("input[name='radioDemo']").change(function (e) {
            checkType = this.value;
            //$(this).attr("checked",true);
        });
        $("#goSubmitData").click(function () {
            SubmitData();
        });
        $("#datepicker").datepicker({
            inline: true,
            dayNamesMin: ['日', '一', '二', '三', '四', '五', '六'],
            monthNames: ['1月', '2月', '3月', '4月', '5月', '6月', '7月', '8月', '9月', '10月', '11月', '12月'],
            beforeShowDay: function (date) {
                ///if (date.getTime() == pickerDate.getTime()) {
                console.log(date.getDay());
                //if(date.getDay() == 2){
                return [true, 'noCourse', '没有课程'];
                //}
                //return [true, '', '没有课程'];  
                //}
            }
        }
	);
        $(".noCourse").css("border-bottom-color", "#F00");
    })
    function SubmitData() {
        var url = "wxvip后台处理.aspx.aspx?checkType=" + checkType + "&name=....";
        alert(url);
        /*$.ajax(url,{
        success: function(data){
        if(data == 1)
        【关联成功]
        else
        alert("adfafds") 
        }
        })*/
    }
</script>
<style type="text/css">

.noCourse{
	background-image: none !important;
	
     border-bottom:#F00 1px double !important;
}
.specialDate a { 
    background-image: none !important;
    background: #33CC66 !important;
}
</style>
</head>

<body>
<!-- Home -->

        Date: <div id="datepicker"></div>
</body>
</html>
