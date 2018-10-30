<%@ Page Language="C#" %> 

<%@ Import Namespace="nrWebClass" %>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<%--
页面说明：这个页面用于VIP 注册、绑定 后进入会员中心之前的等待
开发人员：薛灵敏   开发时间：20160311
接口说明：页面将可能会调用 计算当前会员积分的接口
部署说明：页面只会部署到VIP使用的公众号 【利郎男装】 WEB应用程序下。
特别说明：
--%>
<script runat="server"> 
    public string gourl = "";
    public string title = "";
    private string VIP_resPath = clsConfig.GetConfigValue("VIP_resPath"); //资源目录
    protected void Page_Load(object sender, EventArgs e)
    {
        gourl = Convert.ToString(Request.Params["gourl"]);
        title = Convert.ToString(Request.Params["title"]);
        if (gourl == "")
        {
            gourl = "UserCenter.aspx";
            title = "个人中心";
        }
        else
        {
            gourl = HttpUtility.UrlDecode(gourl, System.Text.Encoding.UTF8);

            //clsLocalLoger.WriteInfo("vip跳转至：" + gourl);            
        }   
    }
      
</script>

<html xmlns="http://www.w3.org/1999/xhtml">

<head>
    <meta charset="utf-8" />
    <meta name="viewport" content="width=device-width,initial-scale=1,user-scalable=0;maximum-scale=1" />
    <meta name="format-detection" content="telephone=no" />
    <meta name="apple-mobile-web-app-capable" content="yes" /> 
    <title>前往<%= title %>...</title>
     
    <style> 
       body{
          margin:0;
          padding:0; 
          background-color:#272822;
        }

        canvas{
          position: absolute;
          top: calc(50% - 50px);
          top: 40%;
          left: calc(50% - 200px);
          left: -webkit-calc(50% - 200px); 
          margin-left:12.5%;
        }
    </style>
    
    
</head>
<body>     
    <div style=" width:400px; height:1000px;">                
        <canvas></canvas>
    </div>
    <form id="form1" runat="server">
        
    </form>
    <script src="<%= VIP_resPath %>/js/zepto.min.js"></script>
    <script type="text/javascript">
        var run = true;

        particle_no = 15;

        window.requestAnimFrame = (function () {
            return window.requestAnimationFrame ||
    window.webkitRequestAnimationFrame ||
    window.mozRequestAnimationFrame ||
    window.oRequestAnimationFrame ||
    window.msRequestAnimationFrame ||
    function (callback) {
        window.setTimeout(callback, 1000 / 60);
    };
        })();

        var canvas = document.getElementsByTagName("canvas")[0];
        var ctx = canvas.getContext("2d");

        var counter = 0;
        var particles = [];
        var w = 400, h = 200;
        canvas.width = w;
        canvas.height = h;

        function reset() {
            ctx.fillStyle = "#272822";
            ctx.fillRect(0, 0, w, h);

            ctx.fillStyle = "#171814";
            ctx.fillRect(25, 80, 350, 25);
        }

        function progressbar() {
            this.widths = 0;
            this.hue = 0;

            this.draw = function () {
                ctx.fillStyle = 'hsla(' + this.hue + ', 100%, 40%, 1)';
                ctx.fillRect(25, 80, this.widths, 25);
                var grad = ctx.createLinearGradient(0, 0, 0, 130);
                grad.addColorStop(0, "transparent");
                grad.addColorStop(1, "rgba(0,0,0,0.5)");
                ctx.fillStyle = grad;
                ctx.fillRect(25, 80, this.widths, 25);
            }
        }

        function particle() {
            this.x = 23 + bar.widths;
            this.y = 82;

            this.vx = 0.8 + Math.random() * 1;
            this.v = Math.random() * 5;
            this.g = 1 + Math.random() * 3;
            this.down = false;

            this.draw = function () {
                ctx.fillStyle = 'hsla(' + (bar.hue + 0.3) + ', 100%, 40%, 1)'; ;
                var size = Math.random() * 2;
                ctx.fillRect(this.x, this.y, size, size);
            }
        }

        bar = new progressbar();

        function draw() {
            if (run == false) return;

            reset();
            counter++;

            bar.hue += 0.8;

            bar.widths += 2;    //进度条增加的速度
            if (bar.widths > 350) {
                //跳转到目标页
                GotoPage();
                return;

                /*
                if (counter > 215) {
                    reset();
                    bar.hue = 0;
                    bar.widths = 0;
                    counter = 0;
                    particles = [];
                }
                else {
                    bar.hue = 126;
                    bar.widths = 351;
                    bar.draw();
                }
                */
            }
            else {
                bar.draw();
                for (var i = 0; i < particle_no; i += 10) {
                    particles.push(new particle());
                }
            }
            update();
        }

        function update() {
            for (var i = 0; i < particles.length; i++) {
                var p = particles[i];
                p.x -= p.vx;
                if (p.down == true) {
                    p.g += 0.1;
                    p.y += p.g;
                }
                else {
                    if (p.g < 0) {
                        p.down = true;
                        p.g += 0.1;
                        p.y += p.g;
                    }
                    else {
                        p.y -= p.g;
                        p.g -= 0.1;
                    }
                }
                p.draw();
            }
        }


        function animloop() {
            draw();
            requestAnimFrame(animloop); 
        }

        function GotoPage() {
            run = false;

            location.href = "<%= gourl %>";
        }

        animloop();
    </script>
</body>
</html>
