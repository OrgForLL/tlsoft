<%@ Page Title="业绩管理" Language="C#" %>

<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">

<script runat="server">

</script>

<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <title>业绩管理</title>  
    <link type="text/css" rel="stylesheet" href="../../res/css/font-awesome.min.css" />
    <script type="text/javascript" src="../../res/js/jquery.js"></script>
    
    <style>
    
    body 
    {
        padding:0 1%;
    }
    
    .pnl
    {
        position:relative; 
        width:100%;     
        vertical-align:middle;
        text-align:center;    
        -webkit-border-radius: 1em 1em 0 0 ; 
        margin:1em 0;
    }
    .pnl>div
    { 
        position:relative;
        border:1px solid #000;
        width:100%;        
        font-size:6em;
        line-height:8rem;          
    }
     
        .pnl>div>div
        { 
            position:relative;       
            width:100%;  
            height:1em;  
            font-size:4rem; 
            line-height:1rem;    
            border-top:1px solid rgba(255,255,255,0.3);
            border-bottom:1px solid rgba(255,255,255,0.2); 
            padding:0;
            margin:0;
        } 
             .div_50percent
             {
                line-height:1.5em;       
                left:0;
                top:0; 
                margin:0;
                padding:0;
                position:relative;
                display:inline;
                width:49%;
                border-left:1px solid rgba(255,255,255,0.4);      
                float:left;   
                font-size:0.618em;     
                 
                overflow:hidden;
	            text-overflow:ellipsis;
	            -o-text-overflow:ellipsis;
	            -webkit-text-overflow:ellipsis;
	            -moz-text-overflow:ellipsis;
	            white-space:nowrap;     
             }
             
             .div_percent
             {
                line-height:1.5em;       
                left:0;
                top:0; 
                margin:0;
                padding:0;
                position:relative;
                display:inline;    
                float:left;   
                font-size:0.618em; 
                
                overflow:hidden;
	            text-overflow:ellipsis;
	            -o-text-overflow:ellipsis;
	            -webkit-text-overflow:ellipsis;
	            -moz-text-overflow:ellipsis;
	            white-space:nowrap;         
             }
             .div_w15{width:14.9%;}
             .div_w35{width:35%;}
             .div_w25{width:25%;} 
             .div_w25last{width:24.9%;} 
        
    .punch 
    {            
        background: #4162a8;     
        border-radius: 0.2em 0.2em 0 0 ;  
        box-shadow: inset 0 1px 10px 1px #5c8bee, 0 1px 0 #1d2c4d, 0 6px 0 #1f3053, 0 8px 4px 1px #111111;
        color: #fff;
        font: bold 20px/1 "helvetica neue", helvetica, arial, sans-serif;
        margin-bottom: 10px;
        padding: 10px 0 12px 0;
        text-align: center;
        text-shadow: 0 -1px 1px #1e2d4d; 
        display:inline-block;
        width:100%;
     }
          
    .punch:hover {
        -webkit-box-shadow: inset 0 0 20px 1px #87adff, 0 1px 0 #1d2c4d, 0 6px 0 #1f3053, 0 8px 4px 1px #111111;
        box-shadow: inset 0 0 20px 1px #87adff, 0 1px 0 #1d2c4d, 0 6px 0 #1f3053, 0 8px 4px 1px #111111;
        cursor: pointer; 
    }
    .punch:active {
        -webkit-box-shadow: inset 0 1px 10px 1px #5c8bee, 0 1px 0 #1d2c4d, 0 2px 0 #1f3053, 0 4px 3px 0 #111111;
        box-shadow: inset 0 1px 10px 1px #5c8bee, 0 1px 0 #1d2c4d, 0 2px 0 #1f3053, 0 4px 3px 0 #111111;    
        padding:5px;    
    }
     
    
    .punch>.fa-cog
    {
        position:absolute;
        font-size:4rem;
        top:1rem;
        right:1rem;
    }
    
    #p1>.punch{background:#55B9FF}  
        
    .about
    {
        color:#c0c0c0;
        text-align:center;
        vertical-align:middle;   
        font-size:2em;     
    }
    </style>

    <script>
        $(function () {
            $(".pnl").on("click", function () {
                var $pnl = $(this);
                alert("即将打开功能[" + $pnl.attr("id") + "]");
            });


            $(".fa-cog").on("click", function () {
                var $cog = $(this);
                alert("即将打开功能[" + $cog.parent().parent().attr("id") + "]的配置项");
                window.event.stopPropagation();
                //阻止事件冒泡 
            });
        });

    </script>

</head>
<body>
    <form id="form1" runat="server">
    <div class="pnl" id="p1">        
        <div class="punch"><span><i class="fa fa-home"></i>形象管理</span>
            <div> 
               <div class="div_50percent"><i class="fa fa-clock-o"></i> 待审核：32</div>
               <div class="div_50percent"><i class="fa fa-times-circle-o"></i> 未通过：18</div>                    
            </div>
        </div>  
    </div> 

    
    <div class="pnl" id="p2">        
        <div class="punch"><span><i class="fa fa-line-chart"></i>业绩管理</span>
            <div> 
               <div class="div_50percent"><i class="fa fa-rmb (alias)"></i> 今日业绩：0.6万+</div>
               <div class="div_50percent"><i class="fa fa-bar-chart"></i> 本月业绩：22万+</div>                    
            </div>
        </div>  
    </div>  
    </form>

    <div class="about">
        <span>- 由利郎信息技术部开发并提供技术支持 -</span>
    </div>
</body>
</html>
