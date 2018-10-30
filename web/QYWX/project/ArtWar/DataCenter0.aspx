<%@ Page Title="销售兵法" Language="C#" %>

<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">

<script runat="server">

</script>

<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <title>销售兵法</title>  
    <link type="text/css" rel="stylesheet" href="../../res/css/font-awesome.min.css" />
    <script type="text/javascript" src="../../res/js/jquery.js"></script>
    
    <style>
    
    body 
    {
        padding:0 1%;
        background:#191c21;
    }
    
    .pnl
    {
        position:relative; 
        width:100%;     
        vertical-align:middle;
        text-align:center;    
        -webkit-border-radius: 2em; 
        margin:1em 0;
    }
    .pnl>div
    { 
        position:relative;
        border:1px solid #000;
        width:100%;        
        font-size:3.6em;
        line-height:8rem;      
        font-weight:200;    
    }
     
        .pnl>div>div
        { 
            position:relative;       
            width:100%;  
            height:1em;  
            font-size:4rem; 
            line-height:1rem;    
            border-top:1px solid rgba(255,255,255,0.3); 
            background:#252932;
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
        background: #2d313d;     
        border-radius: 0.4em ;          
        color: #fff;
        font: bold 20px/1 "helvetica neue", helvetica, arial, sans-serif;
        margin-bottom: 10px;
        padding: 10px 0 12px 0;
        text-align: center;
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
    <div class="pnl" id="p3">        
        <div class="punch"><span><i class="fa fa-user"></i>VIP管理</span>
            <div> 
               <div class="div_50percent"><i class="fa fa-plus-square"></i> 本月新增：29</div>
               <div class="div_50percent"><i class="fa fa-pie-chart"></i> 消费占比：8%</div>                    
            </div>
        </div>  
    </div> 
         
    <div class="pnl" id="p4">        
        <div class="punch"><span><i class="fa fa-comments-o"></i>营销管理</span>
            <div> 
               <div class="div_50percent"><i class="fa fa-reply-all"></i> 本月发券：128</div>
               <div class="div_50percent"><i class="fa fa-retweet"></i> 本月回流：23</div>                    
            </div>
        </div>  
    </div> 
         
    <div class="pnl" id="p5">        
        <div class="punch"><span><i class="fa fa-child"></i>人员管理</span>
            <i class="fa fa-cog"></i>
            <div> 
               <div class="div_percent div_w15">№1</div>
               <div class="div_percent div_w35">青阳阳光店青阳阳光店</div>
               <div class="div_percent div_w25">张三丰</div>
               <div class="div_percent div_w25last">6万+</div>                   
            </div>
            <div> 
               <div class="div_percent div_w15">№2</div>
               <div class="div_percent div_w35">青阳阳光店2</div>
               <div class="div_percent div_w25">张三丰2</div>
               <div class="div_percent div_w25last">5万+</div>                   
            </div>
            <div> 
               <div class="div_percent div_w15">№3</div>
               <div class="div_percent div_w35">青阳阳光店青阳阳光店</div>
               <div class="div_percent div_w25">张三丰3</div>
               <div class="div_percent div_w25last">4万+</div>                   
            </div>
        </div>  
    </div> 
         
    <div class="pnl" id="p6">        
        <div class="punch"><span><i class="fa fa-cubes"></i>货品管理</span>
            <i class="fa fa-cog"></i>
            <div> 
               <div class="div_percent div_w15">№1</div>
               <div class="div_percent div_w35">正统长衬</div>
               <div class="div_percent div_w25">789件</div>
               <div class="div_percent div_w25last">22万+</div>                   
            </div>
            <div> 
               <div class="div_percent div_w15">№2</div>
               <div class="div_percent div_w35">休闲衬衫</div>
               <div class="div_percent div_w25">666件</div>
               <div class="div_percent div_w25last">21万+</div>                   
            </div>
            <div> 
               <div class="div_percent div_w15">№3</div>
               <div class="div_percent div_w35">长裤</div>
               <div class="div_percent div_w25">588件</div>
               <div class="div_percent div_w25last">19万+</div>                   
            </div>
            <div> 
               <div class="div_percent div_w15">№4</div>
               <div class="div_percent div_w35">西服</div>
               <div class="div_percent div_w25">120件</div>
               <div class="div_percent div_w25last">17万+</div>                   
            </div>
            <div> 
               <div class="div_percent div_w15">№5</div>
               <div class="div_percent div_w35">毛衫</div>
               <div class="div_percent div_w25">202件</div>
               <div class="div_percent div_w25last">15万+</div>                   
            </div>
        </div>  
    </div> 
         
    </form>

    <div class="about">
        <span>- 由利郎信息技术部开发并提供技术支持 -</span>
    </div>
</body>
</html>
