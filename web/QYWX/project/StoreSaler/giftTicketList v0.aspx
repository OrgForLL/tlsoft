﻿<%@ Page Language="C#" %>

<!DOCTYPE html>
<script runat="server">
    protected void Page_Load(object sender, EventArgs e)
    {
        
    }
</script>
<html lang="en">
<head>
    <meta charset="utf-8" />
    <meta name="viewport" content="width=device-width,initial-scale=1,user-scalable=0,maximum-scale=1" />
    <meta name="format-detection" content="telephone=no" />
    <meta name="apple-mobile-web-app-capable" content="yes" />
    <meta name="apple-mobile-web-app-status-bar-style" content="black" />
    <title></title>
    <link type="text/css" rel="stylesheet" href="../../res/css/LeePageSlider.css" />
    <link type="text/css" rel="stylesheet" href="../../res/css/font-awesome.min.css" />
    <style type="text/css">
        .page {
            padding: 10px;
            background-color: #f0f0f0;
            color: #565b62;
            bottom: 24px;
        }

        .header {
            border-bottom: 1px solid #ddd;
        }

            .header .title {
                line-height: 51px;
                font-size: 18px;
                font-weight: bold;
                letter-spacing: 1px;
            }

        .btnCreate {
            display: block;
            background-color: #00ad7c;
            color: #fff;
            line-height: 38px;
            text-align: center;
            border-radius: 2px;
            font-size: 16px;
            font-weight: 600;
            margin-bottom:-10px;
        }

        .footer {
            height: 24px;
            background-color: #f0f0f0;
            padding-top: 5px;
        }

            .footer > img {
                height: 14px;
            }

        .ticket_item {
            position: relative;
            margin-top: 20px;
            width: 100%;
            display: -webkit-box;
            display: -webkit-flex;
            display: -ms-flexbox;
            display: flex;
            border-radius: 8px;
        }

        .ticket.left {
            width: 25%;
            float: left;
        }

        .ticket.right {
            width: 75%;
            position: relative;
            overflow: hidden;
            -webkit-box-flex: 1;
            -webkit-flex: 1;
            -ms-flex: 1;
            flex: 1;
        }

        .left_top {
            width: 100%;
            height: 100px;
            border-radius: 8px 0 0 0;
            background-color: #FEAC00;
            border-right: 1px dashed #BE8307;
            position: relative;
            text-align: center;
        }

            .left_top .options {
                color: #fff;
            }

        .left_bot {
            width: 100%;
            height: 40px;
            background-color: #fff;
            border-radius: 0 0 0 8px;
            text-align: center;
            font-size: 20px;
            line-height: 41px;
            border-right: 1px dashed #BE8307;
        }

        .right_top {
            position: relative;
            height: 100px;
            border-radius: 0 8px 0 0;
            background-color: #FFC13E;
            color: #fff;
            padding: 10px 32px 10px 10px;
        }

        .right_bot {
            width: 100%;
            padding: 0 8px;
            height: 40px;
            font-size: 14px;
            background-color: #fff;
            border-radius: 0 0 8px 0;
            display: -webkit-box;
            display: -webkit-flex;
            display: -ms-flexbox;
            display: flex;
            -webkit-box-align: center;
            -webkit-align-items: center;
            -ms-flex-align: center;
            align-items: center;
            -webkit-box-pack: justify;
            -webkit-justify-content: space-between;
            -ms-flex-pack: justify;
            justify-content: space-between;
        }

        .right_circle {
            position: absolute;
            top: 40px;
            right: -10px;
            width: 20px;
            height: 20px;
            background-color: #f0f0f0;
            border-radius: 50%;
        }

        .right_top .name {
            display: -webkit-box;
            font-size: 18px;
            font-weight: 600;
            line-height: 25px;
            overflow: hidden;
            text-overflow: ellipsis;
            -webkit-line-clamp: 2;
            -webkit-box-orient: vertical;
        }

        .right_top .get_count {
            position: absolute;
            left: 10px;
            bottom: 10px;            
        }

        .left_top.bg2 {
            background-color: #1186D6;
        }

        .right_top.bg2 {
            background-color: #6AB7EC;
        }

        .bd2 {
            border-right: 1px dashed #75A0BD;
        }

        .left_top.bg3 {
            background-color: #7F7F7F;
        }

        .right_top.bg3 {
            background-color: #9E9E9E;
        }

        .bd3 {
            border-right: 1px dashed #A5A5A5;
        }

        .left_top.bg4 {
            background-color: #c9182b;
        }

        .right_top.bg4 {
            background-color: #f23a3a;
        }

        .bd4 {
            border-right: 1px dashed #c34615;
        }

        .more_option {
            background-color: #fff;
            margin-top: 5px;
            margin-bottom: 15px;
            padding: 10px 0;
            border-radius: 6px;
            font-size: 0;
            transition: all 0.5s;
            transform: translate(100%,0);
            -webkit-transform: translate(100%,0);
            display: none;
        }

            .more_option.show {
                transform: translate(0,0);
                -webkit-transform: translate(0,0);
            }

        .btn_option {
            display: inline-block;
            width: 25%;
            text-align: center;
            border-right: 1px solid #ddd;
        }

            .btn_option > img {
                width: 50%;
            }

        /*checkbox*/
        .switch-box .switch-box-slider {
            position: relative;
            display: inline-block;
            height: 8px;
            width: 32px;
            background: #d5d5d5;
            border-radius: 8px;
            cursor: pointer;
            -webkit-transition: all 0.2s ease;
            transition: all 0.2s ease;
        }

            .switch-box .switch-box-slider:after {
                position: absolute;
                left: -8px;
                top: -8px;
                display: block;
                width: 24px;
                height: 24px;
                border-radius: 40%;
                background: #eeeeee;
                box-shadow: 0px 2px 2px rgba(0, 0, 0, 0.2);
                content: '';
                -webkit-transition: all 0.2s ease;
                transition: all 0.2s ease;
            }

        .switch-box .switch-box-input ~ .switch-box-label {
            margin-left: 8px;
            color: #fff;
        }

        .switch-box .switch-box-input:checked ~ .switch-box-slider:after {
            left: 16px;
        }

        .switch-box input[type='checkbox'] {
            display: none;
        }
        .activeBtn {
            height:24px;
            position:absolute;
            bottom:5px;
            right:10px;
        }
    </style>
</head>
<body>
    <div class="header">
        <p class="title">利郎礼品券</p>
    </div>
    <div class="wrap-page">
        <div class="page page-not-header-footer" id="index">
            <a class="btnCreate">立即创建</a>
            <div class="ticket_wrap">
                <div class="ticket_item floatfix">
                    <div class="ticket left">
                        <div class="left_top bg4 bd4">
                            <i class="fa fa-3x fa-gift options center-translate"></i>
                        </div>
                        <div class="left_bot bd4"><i class="fa fa-angle-double-down"></i></div>
                    </div>
                    <div class="ticket right">
                        <div class="right_top bg4">
                            <div class="right_circle"></div>
                            <p class="name">礼品券名称礼品券名称礼品券名称礼品券名称礼品券名称礼品券名称礼品券名称礼品券名称礼品券名称礼品券名称礼品券名称</p>
                            <p class="get_count">已领人数：<span class="count_num">1234</span></p>
                            <div class="activeBtn">
                                <!--停用单选-->
                                <div class="switch-box">
                                    <input id="cb_1" class="switch-box-input" type="checkbox" />
                                    <label for="cb_1" class="switch-box-slider"></label>
                                    <label for="cb_1" class="switch-box-label">停用</label>
                                </div>
                            </div>
                        </div>
                        <div class="right_bot"><span>使用有效期：<span class="activeTime">2016.12.1-2016.12.20</span></span></div>
                    </div>
                </div>
                <!--更多选项功能-->
                <div id="option_wrap">
                    <div class="more_option">
                        <a href="javascript:;" class="btn_option qrcode">
                            <img src="../../res/img/storesaler/gift_qrcode.png" />
                        </a>
                        <a href="javascript:;" class="btn_option edit">
                            <img src="../../res/img/storesaler/gift_edit.png" />
                        </a>
                        <a href="javascript:;" class="btn_option item">
                            <img src="../../res/img/storesaler/gift_items.png" />
                        </a>
                    </div>
                </div>

                <div class="ticket_item floatfix">
                    <div class="ticket left">
                        <div class="left_top">
                            <i class="fa fa-3x fa-gift options center-translate"></i>
                        </div>
                        <div class="left_bot"><i class="fa fa-angle-double-down"></i></div>
                    </div>
                    <div class="ticket right">
                        <div class="right_top">
                            <div class="right_circle"></div>
                            <p class="name">礼品券名称</p>
                            <p class="get_count">已领人数：<span class="count_num">1234</span></p>
                            <div class="activeBtn">
                                <!--停用单选-->
                                <div class="switch-box">
                                    <input id="cb_2" class="switch-box-input" type="checkbox" />
                                    <label for="cb_2" class="switch-box-slider"></label>
                                    <label for="cb_2" class="switch-box-label">停用</label>
                                </div>
                            </div>
                        </div>
                        <div class="right_bot"><span>使用有效期：<span class="activeTime">2016.12.1-2016.12.20</span></span></div>
                    </div>
                </div>

                <div class="ticket_item floatfix">
                    <div class="ticket left">
                        <div class="left_top bg2 bd2">
                            <i class="fa fa-3x fa-gift options center-translate"></i>
                        </div>
                        <div class="left_bot bd2"><i class="fa fa-angle-double-down"></i></div>
                    </div>
                    <div class="ticket right">
                        <div class="right_top bg2">
                            <div class="right_circle"></div>
                            <p class="name">礼品券名称礼品券名称礼品券名称礼品券名称礼品</p>
                            <p class="get_count">已领人数：<span class="count_num">1234</span></p>
                            <div class="activeBtn">
                                <!--停用单选-->
                                <div class="switch-box">
                                    <input id="cb_3" class="switch-box-input" type="checkbox" />
                                    <label for="cb_3" class="switch-box-slider"></label>
                                    <label for="cb_3" class="switch-box-label">停用</label>
                                </div>
                            </div>
                        </div>
                        <div class="right_bot"><span>使用有效期：<span class="activeTime">2016.12.1-2016.12.20</span></span></div>
                    </div>
                </div>

                <div class="ticket_item floatfix">
                    <div class="ticket left">
                        <div class="left_top bg3 bd3">
                            <i class="fa fa-3x fa-gift options center-translate"></i>
                        </div>
                        <div class="left_bot bd3"><i class="fa fa-angle-double-down"></i></div>
                    </div>
                    <div class="ticket right">
                        <div class="right_top bg3">
                            <div class="right_circle"></div>
                            <p class="name">礼品券名称礼品券名称礼品券名称</p>
                            <p class="get_count">已领人数：<span class="count_num">1234</span></p>
                            <div class="activeBtn">
                                <!--停用单选-->
                                <div class="switch-box">
                                    <input id="cb_4" class="switch-box-input" type="checkbox" />
                                    <label for="cb_4" class="switch-box-slider"></label>
                                    <label for="cb_4" class="switch-box-label">停用</label>
                                </div>
                            </div>
                        </div>
                        <div class="right_bot"><span>使用有效期：<span class="activeTime">2016.12.1-2016.12.20</span></span></div>
                    </div>
                </div>
            </div>
        </div>
    </div>
    <div class="footer">
        <img src="../../res/img/storesaler/lilanzlogo5.png" />
    </div>
    <script type="text/javascript" src="../../res/js/jquery.js"></script>
    <script type="text/javascript" src="../../res/js/storesaler/fastclick.min.js"></script>
    <script type="text/javascript" src="../../res/js/LeeJSUtils.min.js"></script>
    <script type="text/javascript">
        var optionHtml = $("#option_wrap").html();
        $(document).ready(function () {
            LeeJSUtils.LoadMaskInit();
            FastClick.attach(document.body);
            BindEvents();
        });

        function BindEvents() {
            $(".ticket_item").on("click", ".ticket.left", function () {
                var status = $(this).attr("data-op");
                $(".more_option").remove();
                if (status != "1") {
                    $(this).attr("data-op", "1");
                    $(this).parent().after(optionHtml);
                    $(".more_option").show();
                    setTimeout(function () {
                        $(".more_option").addClass("show");
                    }, 50);
                } else
                    $(this).attr("data-op", "0");
            });
        }
    </script>
</body>
</html>
