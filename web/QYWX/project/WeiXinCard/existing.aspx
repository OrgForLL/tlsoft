﻿<%@ Page Language="C#" %>

<%@ Import Namespace="nrWebClass" %>
<%@ Import Namespace="System.Data.SqlClient" %>
<%@ Import Namespace="System.Data" %>
<%@ Import Namespace="System.Collections.Generic" %>
<!DOCTYPE html>
<script runat="server">
    public string roleName = "";
    public string tzid = "";
    
    protected void Page_Load(object sender, EventArgs e) {        
        if (clsWXHelper.CheckQYUserAuth(true))
        {            
            string strSystemKey = clsWXHelper.GetAuthorizedKey(3);    
            if (string.IsNullOrEmpty(strSystemKey)) {
                clsWXHelper.ShowError("超时 或 没有全渠道权限！");
                return;
            }

            roleName = Convert.ToString(Session["RoleName"]);
            tzid = Convert.ToString(Session["tzid"]);


            if( !roleName.Equals("dz") && !roleName.Equals("my") ) {
                clsWXHelper.ShowError("您没有使用权限！");
            }
        }
    }

    /// <summary>
    /// 获取缩略图路径
    /// </summary>
    /// <param name="imgUrlHead"></param>
    /// <param name="sourceImage"></param>
    /// <returns></returns>
</script>

<html>
    <head>
        <title>已有卡券</title>
        <meta http-equiv="content-type" content="text/html; charset=UTF-8" />
        <meta name="viewport" content="width=device-width, initial-scale=1,user-scalable=0,maximum-scale=1" />
        <link rel="stylesheet" href="../../res/css/LeePageSlider.css" />
        <link rel="stylesheet" href="../../res/css/font-awesome.min.css" />
        <link rel="stylesheet" href="../../res/css/WeiXinCard/iconfont.css" />
        <link rel="stylesheet" href="../../res/css/WeiXinCard/existing.css" />
    </head>
    <body>
        <div class="wrap-page coupon">
            <div class="header">
                <div class="navbar navbar-on">全部</div>
                <div class="navbar">待审</div>
                <div class="navbar">已审</div>
            </div>
            <div class="page page-not-header">
            </div>
        </div>
        <div class="wrap-page detail"></div>
        <div class="wrap-page store">
            <div class="page page-not-footer">
                <div class="search">
                    <div class="goback">
                        <i class="iconfont">&#xe633;</i>
                        <a id="back" href="javascript:void(0)">返回</a>
                    </div>
                    <div class="search-box">
                        <i class="iconfont search-icon">&#xe651;</i>
                        <input type="search" class="search-input" id="searchInput" placeholder="搜索" />
                    </div>
                    <a class="search-btn" href="javascript:void(0)" id="searchSubmit">搜索</a>
                </div>
                <div class="title title-select">切换贸易公司及下属门店</div>
                <div class="entry entry-select">
                    <div class="entry-bd">
                        <select class="select">
                        </select>
                    </div>
                </div>
                <div class="title">选择贸易公司</div>
                <div class="entry-check entry-check-company"></div>
                <div class="title">选择门店<span class="entry-allDelect">清空</span><span class="entry-allSelect">全选</span></div>
                <div class="entry-check entry-check-store"></div>
            </div>
            <div class="footer">
                <div class="btn">
                    <a class="btn-primart" href="javascript:void(0)" id="ensure">确定</a>
                </div>
            </div>
        </div>
        <!--加载提示-->
        <div class="load_toast" id="myLoading">
            <div class="load_toast_mask"></div>
            <div class="load_toast_container">
                <div class="lee_toast">
                    <div class="load_img">
                        <img src="../../res/img/my_loading.gif" />
                    </div>
                    <div class="load_text">加载中...</div>
                </div>
            </div>
        </div>
        <script id="card" type="text/html">
            <div class="card {{if shbs > 0}}card_examed{{else}}card_exam{{/if}}" id="{{id}}">
                <div class="card_top" >
                    <div class="store_name"><i class="fa fa-weixin"></i><span class="configname">利郎男装</span> 门店：{{khmc}}</div>
                    <div class="card_title">{{cardname}}</div>
                    <div class="card_subtitle">{{subtitle}}</div>
                    <div class="card_state">{{if shbs > 0}}已审核{{else}}待审核{{/if}}</div>
                    <div class="back-image card_icon" style="background-image: url(../../res/img/storesaler/card-icon.png);"></div>
                    <i class="fa fa-angle-right"></i>
                    <div class="card_type">{{localtype}}</div>
                </div>
                <div class="card_bot">
                    <p class="time">有效期: {{begintime}} 至 {{endtime}}</p>
                    <div class="counts">剩余数量:<span>{{total}}</span></div>
                </div>
            </div>
        </script>
        <script id="detail" type="text/html">
            <div class="page">
                <div class="title">
                    <div class="goback">
                        <i class="iconfont">&#xe633;</i>
                        <a id="back" href="javascript:void(0)">返回</a>
                    </div>
                    <p>{{localtype}}</p>
                </div>
                <div class="entry">
                    <div class="entry-hd">
                        <label class="entry-label">卡券名</label>
                    </div>
                    <div class="entry-bd">
                        <input class="entry-input" id="cardname" type="text" value="{{cardname}}" readonly />
                    </div>
                </div>
                {{if localdiscount > 0}}
                <div class="entry">
                    <div class="entry-hd">
                        <label class="entry-label">折扣</label>
                    </div>
                    <div class="entry-bd">
                        <input class="entry-input" id="localdiscount" type="text" value="{{localdiscount}}" readonly />
                    </div>
                </div>
                {{/if}}
                {{if leastcost > 0}}
                <div class="entry">
                    <div class="entry-hd">
                        <label class="entry-label">最低消费金额</label>
                    </div>
                    <div class="entry-bd">
                        <input class="entry-input" id="localdiscount" type="text" value="{{leastcost}}" readonly />
                    </div>
                </div>
                {{/if}}
                {{if reducecost > 0}}
                <div class="entry">
                    <div class="entry-hd">
                        <label class="entry-label">抵用金额</label>
                    </div>
                    <div class="entry-bd">
                        <input class="entry-input" id="localdiscount" type="text" value="{{reducecost}}" readonly />
                    </div>
                </div>
                {{/if}}
                <div class="entry">
                    <div class="entry-hd">
                        <label class="entry-label">投放数量</label>
                    </div>
                    <div class="entry-bd">
                        <input class="entry-input" id="total" type="number" value="{{total}}" readonly />
                    </div>
                </div>
                <div class="entry">
                    <div class="entry-hd">
                        <label class="entry-label">生效日期</label>
                    </div>
                    <div class="entry-bd">
                        <input class="entry-input" id="begintime" type="date" value="{{begintime}}" readonly />
                    </div>
                </div>
                <div class="entry">
                    <div class="entry-hd">
                        <label class="entry-label">过期日期</label>
                    </div>
                    <div class="entry-bd">
                        <input class="entry-input" id="endtime" type="date" value="{{endtime}}" readonly />
                    </div>
                </div>
                <div class="title">使用说明</div>
                <div class="entry">
                    <div class="entry-bd">
                        <textarea class="entry-textarea" id="description" readonly>{{accept_category}}</textarea>
                    </div>
                </div>
                <div class="title">新增适用门店</div>
                <div class="entry-check">
                    <a class="entry entry-link" href="javascript:void(0)">
                        <div class="entry-bd">添加门店</div>
                    </a>
                </div>
                <div class="entry-btn">
                    <div class="btn">
                        <a class="btn-primart" href="javascript:void(0)" id="submit" data-id="{{id}}" >返回</a>
                        <!-- {{if shbs > 0}}返回{{else}}审核{{/if}} -->
                    </div>
                </div>
            </div>
        </script>
        <script id="optionList" type="text/html">
            {{each storeList as value i}}
            <label class="entry entry-list">
                <div class="entry-bd">
                    <p data-khid="{{value.khid}}">{{value.khmc}}</p>
                </div>
                <div class="entry-ft">
                    <i class="iconfont entry-close">&#xe62e;</i>
                </div>
            </label>
            {{/each}}
            <a class="entry entry-link" href="javascript:void(0)">
                <div class="entry-bd">添加门店</div>
            </a>
        </script>
        <script id="storeList" type="text/html">
            <label class="entry entry-list">
                <div class="entry-hd">
                    <i class="iconfont icon-xuanze1 check-icon"></i>
                </div>
                <div class="entry-bd" id="{{khid}}" data-atype="{{atype}}">
                    <p {{if atype == "kh"}}class="entry-total"{{/if}}>{{khmc}}</p>
                </div>
            </label>
        </script>
        <script id="xjmdList" type="text/html">
            <label class="entry entry-list">
                <div class="entry-hd">
                    <i class="iconfont icon-xuanze1 check-icon"></i>
                </div>
                <div class="entry-bd" id="{{mdid}}" data-atype="md">
                    <p>{{mdmc}}</p>
                </div>
            </label>
        </script>
        <script id="selectOption" type="text/html">
            <option value="{{khid}}" data-type="{{atype}}">{{khmc}}</option>
        </script>
        <script type="text/javascript" src="../../res/js/jquery-3.2.1.min.js"></script>
        <script type="text/javascript" src="../../res/js/fastclick.min.js"></script>
        <script type="text/javascript" src="../../res/js/template.js"></script>
        <script type="text/javascript" src="../../res/js/WeiXinCard/existing.js"></script>
        <script type="text/javascript">
            var roleName = "<%=roleName %>";
            $(function() {
                existing.init();
            });
        </script>
    </body>
</html>