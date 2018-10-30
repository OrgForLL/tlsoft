﻿<!DOCTYPE html>

<html>
<head>
    <meta charset="utf-8" />
    <title>编辑</title>
    <link type="text/css" rel="stylesheet" href="../../res/css/font-awesome.min.css" />
    <link type="text/css" rel="stylesheet" href="../../res/css/font-awesome-ie7.min.css" />
    <link type="text/css" rel="stylesheet" href="../../res/css/StoreSaler/OFBPC.css" />
    <style type="text/css">
        *
        {
            margin: 0px;
            padding: 0px;
        }

        ul li
        {
            list-style: none;
        }

        body
        {
            font-family: Helvetica,Arial,"Hiragino Sans GB","Microsoft Yahei","微软雅黑",STHeiti,"华文细黑",sans-serif;
            font-size: 14px;
            background-color: #eee;
        }

        .header
        {
            margin: 0 auto;
            /*width: 100%;*/
            height: 50px;
            background-color: #27A1C5;
            position: relative;
            z-index: 500;
        }

            .header .search
            {
                position: absolute;
                right: 250px;
                top: 20px;
                z-index: 5000;
            }

                .header .search span
                {
                    margin-right: 18px;
                    cursor: pointer;
                }

                .header .search i
                {
                    cursor: pointer;
                }








        .wrap-page
        {
        }

        .container
        {
            margin: 10px auto 10px auto;
            padding-bottom: 10px;
            width: 960px;
            height: auto;
            background-color: #fff;
        }

            .container .itemHead
            {
                position: relative;
                height: 80px;
            }

                .container .itemHead .save
                {
                    position: absolute;
                    right: 200px;
                    bottom: 30px;
                    color: #666699;
                }

                .container .itemHead .delete
                {
                    position: absolute;
                    right: 100px;
                    bottom: 30px;
                    color: #666699;
                }

                .container .itemHead .edit a
                {
                    text-decoration: none;
                    color: #666699;
                    font-size: 16px;
                }

                .container .itemHead .userimg
                {
                    position: absolute;
                    margin: 20px;
                    height: 60px;
                    width: 60px;
                    border-radius: 100px;
                }

                    .container .itemHead .userimg img
                    {
                        height: 100%;
                        width: 100%;
                        border-radius: 100px;
                    }

                .container .itemHead .userinfo
                {
                    position: absolute;
                    height: 60px;
                    width: 240px;
                    margin: 10px auto 10px 80px;
                }

                    .container .itemHead .userinfo .name
                    {
                        position: absolute;
                        height: 30px;
                        line-height: 30px;
                        width: 240px;
                        left: 10px;
                        top: 0;
                        font-weight: 600;
                    }

                    .container .itemHead .userinfo .time
                    {
                        position: absolute;
                        height: 30px;
                        line-height: 30px;
                        width: 240px;
                        left: 10px;
                        bottom: 0px;
                    }

            .container .itemBody
            {
                padding-top: 15px;
                padding-bottom: 15px;
                margin: auto 30px auto 30px;
            }

                .container .itemBody .itemContent
                {
                    margin: auto 30px auto 30px;
                    line-height: 20px;
                }

            .container .itemBody
            {
                margin: 10px 30px 10px 30px;
            }

        .itemPics
        {
            margin: auto 30px auto 30px;
            margin-top: 10px;
        }

            .itemPics img
            {
                position: relative;
                width: 260px;
                display: inline-block;
            }
            .itemPics .shanchu
            {
                width: 260px;
                
            }





        .container .itemNav
        {
            background-color: #f2f2f5;
            margin: auto 30px auto 30px;
        }

            .container .itemNav .thumbs
            {
                /*margin: auto 30px auto 30px;*/
                border-bottom: 1px solid #ddd;
                padding-bottom: 5px;
                padding-top: 5px;
            }

            .container .itemNav .comments
            {
                margin: auto 30px auto 30px;
                padding-bottom: 5px;
            }

                .container .itemNav .comments p
                {
                    margin-top: 5px;
                    margin-bottom: 5px;
                    font-size: 12px;
                }

                .container .itemNav .comments .thumbs
                {
                }

                .container .itemNav .comments .comuser
                {
                    margin-left: 20px;
                    color: #88a;
                }

                .container .itemNav .comments .comtime
                {
                    margin-left: 20px;
                    color: #88a;
                }

        #textArea
        {
            width: 840px;
            height: 200px;
            font-size: 18px;
            resize: none;
            
        }
    </style>

</head>
<body>
    <input type="hidden" id="id" value="105" />
    <div class="wrap-page">
        <%--<div class="container">
            <div class="itemHead">
                <div class='userimg'>
                    <img src="../../res/img/storesaler/userimg.jpg" alt="头像" />
                </div>
                <div class="userinfo">
                    <div class="name">简约</div>
                    <div class="time">2月26号 8：10</div>
                </div>
            </div>
            <div class="itemBody">
                <div class="itemContent">
                    <textarea id="textArea" style="width: 840px; height: 200px; font-size: 18px; resize: none;">(或更少，如果你明白我的意思)就会开始一个新的设计。有趣的是，一段时间后，我发现了每个设计师的风格和喜好。一个例子就是连续做过的三个项目中，导航UI的设计都有类似的风格。这种特殊的元素对我来说十分显眼，不仅因为我之前见过两次，而且我发现它涉及了盒子模型的各个方面。</textarea>
                </div>
                <div class="itemPics">
                    <div class="img" style="background-image:url('../../upload/StoreSaler/201603/my/20160305174705.png');background-repeat:no-repeat;background-size:cover;width:260px;height:260px;">
                        <div class="delPics" onclick="delPic()"><i class="fa fa-times-circle" style="color: #f00; font-size: 30px;"></i></div>
                    </div>
                    <div class="img" style="background-image:url('../../upload/StoreSaler/201603/my/20160305174705.png');background-repeat:no-repeat;background-size:cover;width:260px;height:260px;">
                        <div class="delPics"><i class="fa fa-times-circle" style="color: #f00; font-size: 30px;"></i></div>
                    </div>
                    <div class="img" style="background-image:url('../../upload/StoreSaler/201603/my/20160305174705.png');background-repeat:no-repeat;background-size:cover;width:260px;height:260px;">
                        <div class="delPics"><i class="fa fa-times-circle" style="color: #f00; font-size: 30px;"></i></div>
                    </div>
                    <div class="img" style="background-image:url('../../upload/StoreSaler/201603/my/20160305174705.png');background-repeat:no-repeat;background-size:cover;width:260px;height:260px;">
                        <div class="delPics"><i class="fa fa-times-circle" style="color: #f00; font-size: 30px;"></i></div>
                    </div>
                    <div class="img" style="background-image:url('../../upload/StoreSaler/201603/my/20160305174705.png');background-repeat:no-repeat;background-size:cover;width:260px;height:260px;">
                        <div class="delPics"><i class="fa fa-times-circle" style="color: #f00; font-size: 30px;"></i></div>
                    </div>
                </div>
            </div>
            <div class="itemNav">
                <div class="thumbs"><i class="fa fa-heart-o" style="color: #f00; font-weight: 500;"></i>在一,个机,构工,作意,味着</div>
                <div class="comments">
                    <p>评论内容提要</p>
                    <span class="comuser">张三</span>
                    <span class="comtime">2016-02-26 18:00</span>
                </div>
            </div>
        </div>--%>
    </div>



    <script type="text/javascript" src="../../res/js/jquery.js"></script>

    <script type="text/javascript">
        
        
    






        var myContainer = "<div class='container'><div class='itemHead'><div class='userimg'> <img src='#UserImg#' alt='头像' /></div>";
        myContainer += " <div class='userinfo'><div class='name'>#Name#</div><div class='time'>#CreateTime#</div></div><div id='save' class='save'>" +
                        "<a><i class='fa fa-floppy-o'></i>保存</a></div><div class='delete'>" +
                        "<a href='OFBEdit.aspx?ctrl=delComment&id=#id#'><i class='fa fa-times'></i>删除</a></div></div><div class='itemBody'>";
        myContainer += "<div class='itemContent'><textarea id='textArea'>#Content#</textarea></div><div class='itemPics'>#itemPics#</div></div>";
        myContainer += "<div class='itemNav'>#thumbsName##Comments#</div></div>";
        var CommentDiv = "<div class='comments'><p>#commen#</p><span class='comuser'>#comuser#</span><span class='comtime'>#comtime#</span></div>";
        var itemPicsDiv = "<img src='#ImgSrc#' />";
        var thumbsPic = "<i class='fa fa-heart-o' style='color:#f00; font-weight:500;'></i>";

        function getUrlParam(name) {
            //构造一个含有目标参数的正则表达式对象  
            var reg = new RegExp("(^|&)" + name + "=([^&]*)(&|$)");
            //匹配目标参数  
            var r = window.location.search.substr(1).match(reg);
            //返回参数值  
            if (r != null) return unescape(r[2]);
            return null;
        }
        var id;
        $(document).ready(function () {
            id = getUrlParam("id");
            getComment();
        });

        function getComment() {

            $.ajax({
                url: "OfbEditcore.aspx?ctrl=getComment",
                type: "POST",
                data: { id: id },
                dataType: "HTML",
                timeout: 30000,
                error: function (XMLHttpRequest, textStatus, errorThrown) {
                    alert("网络出错");
                },
                success: function (result) {
                    var myJoson;
                    myJoson = stringToJson(result);
                    addToList(myJoson);
                }
            });
        }

        function addToList(myJoson) {

            var MyLenth = myJoson.length;
            if (typeof (MyLenth) == "undefined") {
                alert("无内容");
                return;
            }
            var ImgURL = "http://" + myJoson.BackURL;
            var ID, name, time, content, headimg, ProposalType, thumbsName;
            var ImgArray = new Array();
            var ComArray = new Array();
            var rows = myJoson.rows;
            var MyDiv, myPicsDiv, myCommentDiv;
            var ImgStr;
            for (var i = 0; i < myJoson.length; i++) {
                ID = rows[i].ID;
                name = rows[i].name;
                time = rows[i].time;
                content = rows[i].OFBContent;
                headimg = rows[i].headImg;
                thumbsName = rows[i].thumbsName;
                ImgArray = rows[i].PictureList;
                ComArray = rows[i].ComList;

                if ($("#OFBGroupID").val() == "2") {
                    ProposalType = "【" + rows[i].ProposalType + "】"
                } else {
                    ProposalType = "";
                }
                if (headimg.indexOf("http://") >= 0) {
                    headimg = headimg + "64";
                } else {
                    headimg = ImgURL + "/res/img/StoreSaler/" + "defaulticon.jpg";
                }
                MyDiv = myContainer.replace("#UserImg#", headimg);
                MyDiv = MyDiv.replace("#Name#", name);
                MyDiv = MyDiv.replace("#CreateTime#", time);
                MyDiv = MyDiv.replace("#Content#", ProposalType + content);
                MyDiv = MyDiv.replace("#id#", ID);
                myPicsDiv = "";
                for (var j = 0; j < ImgArray.length; j++) {
                    myPicsDiv += itemPicsDiv.replace("#ImgSrc#", ImgURL + ImgArray[j].URLAddress + ImgArray[j].FileName);
                }
                MyDiv = MyDiv.replace("#itemPics#", myPicsDiv);
                if (thumbsName.length > 0) {
                    MyDiv = MyDiv.replace("#thumbsName#", "<div class='thumbs'>" + thumbsPic + thumbsName + "</div>");
                }
                else {
                    MyDiv = MyDiv.replace("#thumbsName#", "");
                }
                myCommentDiv = "";
                for (var j = 0; j < ComArray.length; j++) {
                    myCommentDiv += CommentDiv.replace("#commen#", ComArray[j].Content).replace("#comuser#", ComArray[j].CreateName).replace("#comtime#", ComArray[j].CreateTime);
                }
                MyDiv = MyDiv.replace("#Comments#", myCommentDiv);
                $(".wrap-page").append(MyDiv);
                $(".save a").click(function () {
                    alert("test");                    
                });
                $(".itemPics img").hover(function () {
                    $(this).css("opacity", "0.5");
                    
                });
            }
        }

        function stringToJson(stringValue) {
            eval("var theJsonValue = " + stringValue);
            return theJsonValue;
        }





    

    </script>


</body>

</html>