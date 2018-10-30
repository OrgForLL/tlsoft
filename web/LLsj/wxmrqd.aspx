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
    <link rel="stylesheet" href="timepicker-Addon/jquery-ui-timepicker-addon.css"> 

 <%--<script type="text/javascript" src="${contextPath}/_js/jqezui/local/easyui-lang-zh_CN.js"></script>--%>


<script type="text/javascript">
    <script>  
    $(function() {  
        $( "#datepicker" ).datepicker({  
            changeMonth: true,  
            changeYear: true  
        });  
        $( "#datepicker" ).datepicker( "option",$.datepicker.regional[ 'zh-CN' ] );  
          
        $("#datetime").datetimepicker({  
                       //showOn: "button",  
                        //buttonImage: "./css/images/icon_calendar.gif",  
                        //buttonImageOnly: true,  
                        dateFormat:'yy-mm-dd',  
                        changeMonth: true,  
                        changeYear: true,  
                        showSecond: true,  
                       timeFormat: 'hh:mm:ss',  
                        stepHour: 1,  
                       stepMinute: 1,  
                        stepSecond: 1  
                    })  
    });  
   </script>  
</head>  
<body>  
  
Date: <input type="text" id="datepicker">  
  
<input type="text" id="datetime" name="datetime" value="" />  
  
<div class="demo-description">  
Show month and year dropdowns in place of the static month/year header to facilitate navigation through large timeframes.  Add the boolean <code>changeMonth</code> and <code>changeYear</code> options.  
  
</div>  
</body>  


</html>
