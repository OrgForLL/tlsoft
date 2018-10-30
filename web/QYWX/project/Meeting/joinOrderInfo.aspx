<%@ Page Language="C#" %>

<%@ Import Namespace="nrWebClass" %>
<%@ Import Namespace="System.Collections" %>
<%@ Import Namespace="System.Collections.Generic" %>
<%@ Import Namespace="System.Data.SqlClient" %>
<%@ Import Namespace="System.Data" %>
<!DOCTYPE html>
<script runat="server">
    private const string ConfigKeyValue = "1";	//利郎企业号
    private string DBConStr = clsConfig.GetConfigValue("OAConnStr");

    public string mdid = "", mdmc = "", AppSystemKey = "", CustomerID = "", CustomerName = "", dhbh = "", myLastdhbh = "", ParaMdid = "";
    private string strDhhCatpion = "订货自助参会登记";
    
    protected void Page_Load(object sender, EventArgs e)
    {
        ////设置为测试模式
        //SetIsTestMode();
        
        ParaMdid = Convert.ToString(Request.Params["mdid"]);//列表页传入的t_mdb.mdid
        //鉴权判断身份
        if (clsWXHelper.CheckQYUserAuth(true))
        {            
            string SystemID = "6";//订货会系统
            AppSystemKey = clsWXHelper.GetAuthorizedKey(Convert.ToInt32(SystemID));
            CustomerID = Convert.ToString(Session["qy_customersid"]);
            CustomerName = Convert.ToString(Session["qy_cname"]);            
            if (AppSystemKey == "")
                clsWXHelper.ShowError("对不起，您还未开通订货会系统权限！");
            else
            {
                dhbh = clsErpCommon.getDhbh();
                strDhhCatpion = clsErpCommon.getDhhCatpion(dhbh);    
                
                clsWXHelper.WriteLog(string.Format("AppSystemKey:{0},访问功能页[{1}]", AppSystemKey, "参会管理信息页[joinOrderInfo.aspx]"));
                using (LiLanzDALForXLM dal = new LiLanzDALForXLM(DBConStr))
                {
                    string sql = string.Format(@"select top 1 convert(varchar(20),a.mdid)+'|'+isnull(md.mdmc,'')+'|'+a.dhbh+'|'+kh.ccid
                                                from yx_t_dhryxx a
                                                inner join t_mdb md on a.mdid=md.mdid and md.ty=0
                                                inner join yx_t_khb kh on md.khid=kh.khid and kh.ty=0
                                                where id='{0}'", AppSystemKey);
                    object scalar;string ccid="";
                    string errinfo = dal.ExecuteQueryFast(sql, out scalar);
                    if (errinfo == "")
                    {
                        if (Convert.ToString(scalar) != "")
                        {                            
                            mdid = Convert.ToString(scalar).Split('|')[0];
                            mdmc = Convert.ToString(scalar).Split('|')[1];
                            myLastdhbh = Convert.ToString(scalar).Split('|')[2];    //获取最后的订货编号
                            ccid = Convert.ToString(scalar).Split('|')[3]+'-';
                            if (ParaMdid != "" && ParaMdid != "0" && ParaMdid != null) {
                                sql = @"select a.mdmc+'|'+b.ccid
                                        from t_mdb a
                                        inner join yx_t_khb b on a.khid=b.khid 
                                        where a.mdid=@mdid and b.ty=0 and a.ty=0";
                                List<SqlParameter> para = new List<SqlParameter>();
                                para.Add(new SqlParameter("@mdid", ParaMdid));
                                errinfo = dal.ExecuteQueryFastSecurity(sql, para, out scalar);
                                if (errinfo == "" && Convert.ToString(scalar) != "")
                                {
                                    mdmc = Convert.ToString(scalar).Split('|')[0];
                                    string _ccid = Convert.ToString(scalar).Split('|')[1] + '-';
                                    if (!(_ccid.Contains(ccid) || ccid.Contains(_ccid)))
                                    {
                                        clsLocalLoger.WriteError(string.Format("越权访问！mdid: _ccid:{0} ccid:{1}", _ccid, ccid));
                                        clsWXHelper.ShowError("对不起，您已越权访问！");
                                    }
                                }
                            }//END有传入MDID参数
                        }
                        else
                            clsSharedHelper.WriteInfo("对不起，未找到您的参会信息！！");
                    }
                    else
                        clsSharedHelper.WriteErrorInfo(errinfo);
                }                
            }//end else
        }
        else
            clsWXHelper.ShowError("鉴权失败！");
    }


    /// <summary>
    /// 设置为测试模式。即将测试参数写到此处，用于测试
    /// </summary>
    private void SetIsTestMode()
    {
        DBConStr = "Data Source=192.168.35.10;Initial Catalog=tlsoft;User ID=ABEASD14AD;password=+AuDkDew";
    }
</script>
<html>
<head>
    <meta charset="utf-8" />
    <meta name="viewport" content="width=device-width,initial-scale=1,user-scalable=0,maximum-scale=1" />
    <meta name="format-detection" content="telephone=no" />
    <meta name="apple-mobile-web-app-capable" content="yes" />
    <meta name="apple-mobile-web-app-title" content="订货会登记1.0">
    <meta name="apple-mobile-web-app-status-bar-style" content="default" />
    <title></title>
    <link type="text/css" rel="stylesheet" href="../../res/css/LeePageSlider.css" />
    <link type="text/css" rel="stylesheet" href="../../res/css/font-awesome.min.css" />
    <link type="text/css" rel="stylesheet" href="../../res/css/meeting/JoinOrderStyle.css" />
    <style type="text/css">
        #loading-center-absolute {
            position: absolute;
            left: 50%;
            top: 50%;
            height: 60px;
            width: 60px;
            margin-top: -30px;
            margin-left: -30px;
            -webkit-animation: loading-center-absolute 1s infinite;
            animation: loading-center-absolute 1s infinite;
        }

        .object {
            width: 20px;
            height: 20px;
            background-color: #444;
            float: left;
            -moz-border-radius: 50% 50% 50% 50%;
            -webkit-border-radius: 50% 50% 50% 50%;
            border-radius: 50% 50% 50% 50%;
            margin-right: 20px;
            margin-bottom: 20px;
        }

            .object:nth-child(2n+0) {
                margin-right: 0px;
            }

        #object_one {
            -webkit-animation: object_one 1s infinite;
            animation: object_one 1s infinite;
            background-color: #3498db;
        }

        #object_two {
            -webkit-animation: object_two 1s infinite;
            animation: object_two 1s infinite;
            background-color: #f1c40f;
        }

        #object_three {
            -webkit-animation: object_three 1s infinite;
            animation: object_three 1s infinite;
            background-color: #2ecc71;
        }

        #object_four {
            -webkit-animation: object_four 1s infinite;
            animation: object_four 1s infinite;
            background-color: #e74c3c;
        }

        @-webkit-keyframes loading-center-absolute {
            100% {
                -ms-transform: rotate(360deg);
                -webkit-transform: rotate(360deg);
                transform: rotate(360deg);
            }
        }

        @keyframes loading-center-absolute {
            100% {
                -ms-transform: rotate(360deg);
                -webkit-transform: rotate(360deg);
                transform: rotate(360deg);
            }
        }

        @-webkit-keyframes object_one {
            50% {
                -ms-transform: translate(20px,20px);
                -webkit-transform: translate(20px,20px);
                transform: translate(20px,20px);
            }
        }

        @keyframes object_one {
            50% {
                -ms-transform: translate(20px,20px);
                -webkit-transform: translate(20px,20px);
                transform: translate(20px,20px);
            }
        }

        @-webkit-keyframes object_two {
            50% {
                -ms-transform: translate(-20px,20px);
                -webkit-transform: translate(-20px,20px);
                transform: translate(-20px,20px);
            }
        }

        @keyframes object_two {
            50% {
                -ms-transform: translate(-20px,20px);
                -webkit-transform: translate(-20px,20px);
                transform: translate(-20px,20px);
            }
        }

        @-webkit-keyframes object_three {
            50% {
                -ms-transform: translate(20px,-20px);
                -webkit-transform: translate(20px,-20px);
                transform: translate(20px,-20px);
            }
        }

        @keyframes object_three {
            50% {
                -ms-transform: translate(20px,-20px);
                -webkit-transform: translate(20px,-20px);
                transform: translate(20px,-20px);
            }
        }

        @-webkit-keyframes object_four {
            50% {
                -ms-transform: translate(-20px,-20px);
                -webkit-transform: translate(-20px,-20px);
                transform: translate(-20px,-20px);
            }
        }

        @keyframes object_four {
            50% {
                -ms-transform: translate(-20px,-20px);
                -webkit-transform: translate(-20px,-20px);
                transform: translate(-20px,-20px);
            }
        }

        .animated {
            -webkit-animation-duration: 1s;
            animation-duration: 1s;
            -webkit-animation-fill-mode: both;
            animation-fill-mode: both;
        }

        @-webkit-keyframes shake {
            0%,100% {
                -webkit-transform: translate3d(0,0,0);
                transform: translate3d(0,0,0);
            }

            10%,30%,50%,70%,90% {
                -webkit-transform: translate3d(-10px,0,0);
                transform: translate3d(-10px,0,0);
            }

            20%,40%,60%,80% {
                -webkit-transform: translate3d(10px,0,0);
                transform: translate3d(10px,0,0);
            }
        }

        @keyframes shake {
            0%,100% {
                -webkit-transform: translate3d(0,0,0);
                -ms-transform: translate3d(0,0,0);
                transform: translate3d(0,0,0);
            }

            10%,30%,50%,70%,90% {
                -webkit-transform: translate3d(-10px,0,0);
                -ms-transform: translate3d(-10px,0,0);
                transform: translate3d(-10px,0,0);
            }

            20%,40%,60%,80% {
                -webkit-transform: translate3d(10px,0,0);
                -ms-transform: translate3d(10px,0,0);
                transform: translate3d(10px,0,0);
            }
        }

        .shake {
            -webkit-animation-name: shake;
            animation-name: shake;
        }

        #no-result {
            display: none;
            white-space: nowrap;
            color: #999;
            z-index: 998;
        }

        .form-item .sex-item {
            width: 50%;
            float: left;
            text-align: center;
            line-height: 34px;
            font-size: 16px;
            color: #999;
            position: relative;
        }

            .form-item .sex-item i {
                margin-right: 10px;
            }

            .form-item .sex-item.selected {
                color: #50bb8d;
            }

        .hidden {
            display: none;
        }

        .SearchOthers {
            position: absolute;
            top: 3px;
            right: 0;
            height: 28px;
            line-height: 26px;
            border: 1px solid #f0f0f0;
            border-radius: 2px;
            padding: 0 10px;
            color: #50bb8d;
            font-weight: bold;
            display: none;
        }

        #fixed-name p {
            display: none;
        }

        .store-name {
            margin-bottom: 30px;
            font-weight: bold;
            display: inline-block;
            background-color: #50bb8d;
            color: #fff;
            padding: 2px 8px;
            border-radius: 4px;
        }

        #other-rygxdiv {
            display: none;
        }
    </style>
</head>
<body>
    <!--loading mask-->
    <div id="loadingmask" style="position: fixed; background-color: #f0f0f0; top: 0; height: 100%; left: 0; width: 100%; z-index: 2000;">
        <div id="loading-center-absolute">
            <div class="object" id="object_one"></div>
            <div class="object" id="object_two"></div>
            <div class="object" id="object_three"></div>
            <div class="object" id="object_four"></div>
        </div>
    </div>

    <div class="header">
        <div class="center-translate">
            <div class="title">利郎订货会参会人员信息管理</div>
            <div class="season"><%= strDhhCatpion%></div>
        </div>
    </div>
    <div class="wrap-page">
        <!--主页-->
        <div class="page page-not-header-footer" id="main">
            <div style="text-align: center;">
                <div class="store-name">当前门店:<%=mdmc %></div>
            </div>
            <div id="orders-container">
            </div>
        </div>
        <!--基础信息编辑页-->
        <div class="page page-right" id="info-form" wxid="">
            <div class="step-line">
                <div class="step-item" id="info-step1">
                    <p class="dot">1</p>
                    <p class="dot-bg"></p>
                    <p class="step-text">基础信息</p>
                </div>
                <div class="line unactive"></div>
                <div class="step-item" id="info-step2">
                    <p class="dot unactive">2</p>
                    <p class="dot-bg unactive"></p>
                    <p class="step-text unactive">航班信息</p>
                </div>
            </div>
            <!--基础信息表单-->
            <div class="form-page" id="step1">
            </div>
            <!--航班信息-->
            <div class="form-page right" id="step2">
            </div>
            <div class="form-footer" id="form-btns">
                <a class="form-btn" style="background-color: #ccc;" href="javascript:BackBtn()">返 回</a>
                <a class="form-btn" href="javascript:SaveFunc()">保 存</a>
            </div>
        </div>

        <div id="no-result" class="center-translate">对不起，暂时还没有维护记录！</div>
    </div>
    <div class="footer" id="footer-btns">
        <a id="others-btn" class="foot-btn" onclick="Register('others')">帮他人登记</a>
        <a id="myself-btn" class="foot-btn self" onclick="Register('myself')">登记我的信息</a>
    </div>
    <script type="text/javascript" src="../../res/js/jquery.js"></script>
    <script type="text/javascript" src="../../res/js/storesaler/fastclick.min.js"></script>
    <script type="text/javascript" src="../../res/js/template.js"></script>
    <script type="text/javascript" src="../../res/js/LeeJSUtils.min.js"></script>

    <!--模板区-->
    <script id="list-item" type="text/html">
        <div class="order-item" data-id="{{id}}">
            <div class="back-image headimg" style="background-image: url({{headImg}})"></div>
            <div class="top-item">
                <p class="name">
                    <span>{{cname}}</span>
                    <span class="back-image sex-icon" style="background-image: url({{sexicon}});"></span>
                    <span class="back-image sex-icon {{flyflag}}" style="background-image: url(../../res/img/meeting/fly-icon.png);"></span>
                </p>
                <p class="verify {{shbs}}">{{shzt}}</p>
            </div>
            <div class="mid-item" onclick="GetPersonInfos(this)">
                <div class="info-item">
                    <label>手机号码</label>
                    <div class="primary">{{phoneNumber}}</div>
                </div>
                <div class="info-item">
                    <label>身份证号</label>
                    <div class="primary">{{idCard}}</div>
                </div>
                <div class="info-item">
                    <label>参会身份</label>
                    <div class="primary">{{rygx}}</div>
                </div>
                <div class="info-item">
                    <label>酒店信息</label>
                    <div class="primary cut2">{{hotel}}</div>
                    <label style="text-align: right;">房间号</label>
                    <div class="primary" style="text-align: center;">{{hotelRoom}}</div>
                </div>
                <i class="fa fa-angle-right"></i>
            </div>
            <div class="more-info">
                <ul class="fly-info floatfix">
                    <li>
                        <div class="direction">往</div>
                        <div class="info-item">
                            <label>报到时间</label>
                            <div class="primary">{{goTime}}</div>
                        </div>
                        <div class="info-item">
                            <label>交通工具</label>
                            <div class="primary">{{goWayType}}</div>
                        </div>
                        <div class="info-item">
                            <label>航班车次</label>
                            <div class="primary">{{goWayNum}}</div>
                        </div>
                        <div class="info-item">
                            <label>起飞地点</label>
                            <div class="primary">{{goFromAddr}}</div>
                        </div>
                        <div class="info-item">
                            <label>起飞时间</label>
                            <div class="primary">{{goStartTime}}</div>
                        </div>
                        <div class="info-item">
                            <label>抵达地点</label>
                            <div class="primary">{{goToAddr}}</div>
                        </div>
                        <div class="info-item">
                            <label>抵达时间</label>
                            <div class="primary">{{goEndTime}}</div>
                        </div>
                    </li>
                    <div class="mid-line"></div>
                    <li>
                        <div class="direction">返</div>
                        <div class="info-item">
                            <label>返程时间</label>
                            <div class="primary">{{backTime}}</div>
                        </div>
                        <div class="info-item">
                            <label>交通工具</label>
                            <div class="primary">{{backWayType}}</div>
                        </div>
                        <div class="info-item">
                            <label>航班车次</label>
                            <div class="primary">{{backWayNum}}</div>
                        </div>
                        <div class="info-item">
                            <label>出发地点</label>
                            <div class="primary">{{backFromAddr}}</div>
                        </div>
                        <div class="info-item">
                            <label>出发时间</label>
                            <div class="primary">{{backStartTime}}</div>
                        </div>
                    </li>
                </ul>
            </div>
            <div class="bot-item" onclick="LookMore(this)">
                <i class="fa fa-angle-down"></i><span>查看行程</span>
            </div>
        </div>
    </script>

    <!--基础信息模板-->
    <script id="step1-temp" type="text/html">
        <div class="tips animated">
            <div class="center-translate" style="background-color: #e74c3c; padding: 4px 10px; border-radius: 2px; color: #fff; white-space: nowrap;">
                <i class="fa fa-exclamation-circle"></i>
                <span id="tip-text" style="color: #fff; line-height: 1;"></span>
            </div>
        </div>
        <div id="step1-container">
            <div class="back-image form-head" style="background-image: url({{headImg}})"></div>
            <div class="head-line"></div>
            <div class="step1-form">
                <ul>
                    <li>
                        <div class="form-item">
                            <label>真实姓名</label>
                            <div class="input-div">
                                <input id="f-name" type="text" placeholder="姓名.." value="{{cname}}" />
                            </div>
                            <a class="SearchOthers" id="form-search" href="javascript:SearchOthers()">查询</a>
                        </div>
                    </li>
                    <li>
                        <div class="form-item" id="f-sex">
                            <div sex="1" class="sex-item" onclick="SexSwitch(this)"><i class="fa fa-check-circle"></i>男</div>
                            <div sex="0" class="sex-item" onclick="SexSwitch(this)"><i class="fa fa-check-circle"></i>女</div>
                        </div>
                    </li>
                    <li>
                        <div class="form-item">
                            <label>手机号码</label>
                            <div class="input-div">
                                <input id="f-phone" type="number" placeholder="请填写11位手机号.." value="{{phoneNumber}}" />
                            </div>
                        </div>
                    </li>
                    <li>
                        <div class="form-item">
                            <label>身份证</label>
                            <div class="input-div">
                                <input id="f-idcard" type="text" placeholder="请输入有效身份证号.." value="{{idCard}}" />
                            </div>
                        </div>
                    </li>
                    <li>
                        <div class="form-item">
                            <label>参会身份</label>
                            <div class="input-div">
                                <select id="f-rygx">
                                    <option value="0" selected>-单击选择-</option>
                                    <option value="老板">老板</option>
                                    <option value="老板娘">老板娘</option>
                                    <option value="店长">店长</option>
                                    <option value="店助">店助</option>
                                    <option value="店员">店员</option>
                                    <option value="总代理">总代理</option>
                                    <option value="贸易公司总经理">贸易公司总经理</option>
                                    <option value="贸易公司副总经理">贸易公司副总经理</option>
                                    <option value="直营部经理">直营部经理</option>
                                    <option value="地级市办事处经理">地级市办事处经理</option>
                                    <option value="物流(商品综合部)经理">物流(商品综合部)经理</option>
                                    <option value="商品专员">商品专员</option>
                                    <option value="终端（运营部）经理">终端（运营部）经理</option>
                                    <option value="终端（运营）专员">终端（运营）专员</option>
                                    <option value="业务部经理">业务部经理</option>
                                    <option value="业务专员">业务专员</option>
                                    <option value="其他">其他</option>
                                </select>
                            </div>
                            <i class="fa fa-angle-down fa-2x"></i>
                        </div>
                    </li>
                    <li id="other-rygxdiv">
                        <div class="form-item">
                            <label>其它职务</label>
                            <div class="input-div">
                                <input id="other-rygx" placeholder="请填写列表中没有的参会身份.." value="{{otherRygx}}" />
                            </div>
                        </div>
                    </li>
                </ul>
            </div>
            <div id="fixed-name" style="color: #e74c3c; text-align: center; margin-top: 15px; line-height: 24px;">
                <p id="tip1"><i class="fa fa-exclamation-circle"></i>已锁定【<span></span>】的上季参会信息，姓名不能修改！</p>
                <p id="tip2">注意：此处只能填写<strong>【自己】</strong>的参会信息！</p>
                <p id="tip3">注意：此处只能填写<strong>【他人】</strong>的参会信息！</p>
            </div>
        </div>
    </script>

    <!--航班信息模板-->
    <script id="step2-temp" type="text/html">
        <div class="step2-form" id="step2-arrive">
            <p class="title">抵达信息</p>
            <div class="head-line"></div>
            <ul>
                <li>
                    <div class="form-item">
                        <label>报到时间</label>
                        <div class="input-div">
                            <input type="date" id="arrive-gotime" value="{{goTime}}" />
                        </div>
                    </div>
                </li>
                <li>
                    <div class="form-item">
                        <label>交通工具</label>
                        <div class="input-div">
                            <select id="arrive-tool">
                                <option selected value="0">-单击选择-</option>
                                <option value="1">飞机</option>
                                <option value="2">火车</option>
                                <option value="3">动车</option>
                                <option value="4">汽车</option>
                                <option value="5">其它</option>
                            </select>
                        </div>
                    </div>
                </li>
                <li>
                    <div class="form-item">
                        <label>航班/车次</label>
                        <div class="input-div">
                            <input id="arrive-num" type="text" placeholder="请输入有效航班号或车次号.." value="{{goWayNum}}" />
                        </div>
                    </div>
                </li>
                <li>
                    <div class="form-item">
                        <label>起飞起点</label>
                        <div class="input-div">
                            <input type="text" id="arrive-gofromaddr" value="{{goFromAddr}}" />
                        </div>
                    </div>
                </li>
                <li>
                    <div class="form-item">
                        <label>起飞时间</label>
                        <div class="input-div">
                            <input type="datetime-local" id="arrive-gostarttime" value="{{goStartTime}}" />
                        </div>
                    </div>
                </li>
                <li>
                    <div class="form-item">
                        <label>抵达地点</label>
                        <div class="input-div">
                            <!--<input id="arrive-addr" type="text" placeholder="请填写到达地点,方便工作人员安排接待.." value="{{goToAddr}}" />-->
                            <select id="arrive-addr-air" style="display: none;">
                                <option selected value="0">-单击选择-</option>
                                <option value="晋江机场">晋江机场</option>
                                <option value="厦门机场T3">厦门机场T3</option>
                                <option value="厦门机场T4">厦门机场T4</option>
                            </select>
                            <select id="arrive-addr-train" style="display: none;">
                                <option selected value="0">-单击选择-</option>
                                <option value="晋江站">晋江站</option>
                                <option value="泉州站">泉州站</option>
                                <option value="泉州东站">泉州东站</option>
                                <option value="厦门站">厦门站</option>
                                <option value="厦门北站">厦门北站</option>
                                <option value="厦门高崎站">厦门高崎站</option>
                                <option value="福州站">福州站</option>
                                <option value="福州南站">福州南站</option>
                            </select>
                            <input id="arrive-addr-other" style="display: none" type="text" placeholder="请填写抵达地点,方便工作人员安排接待.." value="{{goToAddr}}" />
                        </div>
                    </div>
                </li>
                <li>
                    <div class="form-item">
                        <label>抵达时间</label>
                        <div class="input-div">
                            <input type="datetime-local" id="arrive-time" value="{{goEndTime}}" />
                        </div>
                    </div>
                </li>
            </ul>
        </div>
        <div class="step2-form" id="step2-return">
            <p class="title">返程信息</p>
            <div class="head-line"></div>
            <ul>
                <li>
                    <div class="form-item">
                        <label>返程时间</label>
                        <div class="input-div">
                            <input type="date" id="return-backtime" value="{{backTime}}" />
                        </div>
                    </div>
                </li>
                <li>
                    <div class="form-item">
                        <label>交通工具</label>
                        <div class="input-div">
                            <select id="return-tool">
                                <option selected value="0">-单击选择-</option>
                                <option value="1">飞机</option>
                                <option value="2">火车</option>
                                <option value="3">动车</option>
                                <option value="4">汽车</option>
                                <option value="5">其它</option>
                            </select>
                        </div>
                    </div>
                </li>
                <li>
                    <div class="form-item">
                        <label>航班/车次</label>
                        <div class="input-div">
                            <input id="return-num" type="text" placeholder="请输入有效航班号或车次号.." value="{{backWayNum}}" />
                        </div>
                    </div>
                </li>
                <li>
                    <div class="form-item">
                        <label>出发地点</label>
                        <div class="input-div">
                            <!--<input id="return-addr" type="text" placeholder="请填写返程时的出发地点.." value="{{backFromAddr}}" />-->
                            <select id="return-addr-air" style="display: none;">
                                <option selected value="0">-单击选择-</option>
                                <option value="晋江机场">晋江机场</option>
                                <option value="厦门机场T3">厦门机场T3</option>
                                <option value="厦门机场T4">厦门机场T4</option>
                            </select>
                            <select id="return-addr-train" style="display: none;">
                                <option selected value="0">-单击选择-</option>
                                <option value="晋江站">晋江站</option>
                                <option value="泉州站">泉州站</option>
                                <option value="泉州东站">泉州东站</option>
                                <option value="厦门站">厦门站</option>
                                <option value="厦门北站">厦门北站</option>
                                <option value="厦门高崎站">厦门高崎站</option>
                                <option value="福州站">福州站</option>
                                <option value="福州南站">福州南站</option>
                            </select>
                            <input id="return-addr-other" type="text" placeholder="请填写返程时的出发地点.." value="{{backFromAddr}}" />
                        </div>
                    </div>
                </li>
                <li>
                    <div class="form-item">
                        <label>出发时间</label>
                        <div class="input-div">
                            <input type="datetime-local" id="return-time" value="{{backStartTime}}" />
                        </div>
                    </div>
                </li>
            </ul>
        </div>
    </script>
    <script type="text/javascript">
        var CurrentSite = "", mdid = "<%=mdid%>", CurrentID = "", LoadFlag = false, AppSystemKey = "<%=AppSystemKey%>", dhbh = "<%=dhbh%>", myLastdhbh = "<%= myLastdhbh%>", CustomersID = "<%=CustomerID%>";
        var mdmc = "<%=mdmc%>", formType = "", paraMdid = "<%=ParaMdid%>";        
    </script>
    <script type="text/javascript" src="../../res/js/meeting/JoinOrderJS.js?ver=20170117"></script>
</body>
</html>
