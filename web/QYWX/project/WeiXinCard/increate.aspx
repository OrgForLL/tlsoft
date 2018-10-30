<%@ Page Language="C#" %>

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
            }else if(roleName.Equals("my")) {
                clsWXHelper.ShowError("您没有卡券创建权限！");
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
        <title>卡券基础信息</title>
        <meta http-equiv="content-type" content="text/html; charset=UTF-8" />
        <meta name="viewport" content="width=device-width, initial-scale=1,user-scalable=0,maximum-scale=1" />
        <link rel="stylesheet" href="../../res/css/LeePageSlider.css" />
        <link rel="stylesheet" href="../../res/css/WeiXinCard/iconfont.css" />
        <link rel="stylesheet" href="../../res/css/WeiXinCard/increate.css" />
    </head>
    <body>
        <div class="wrap=page coupon">
        </div>
        <div class="wrap-page increate">
            <div class="header nav">
                <div class="navbar navbar-on">限定门店</div>
                <div class="navbar">限定贸易公司</div>
            </div>
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
                <div class="entry-check entry-check-store">
                </div>
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
        
        <script id="discount-curr" type="text/html">
            <div class="page">
                <div class="title">通用折扣</div>
                <div class="entry">
                    <div class="entry-hd">
                        <label class="entry-label">卡券名</label>
                    </div>
                    <div class="entry-bd">
                        <input class="entry-input" id="cardname" type="text" placeholder="6个字以内，不含折扣券三个字" />
                    </div>
                </div>
                <div class="entry">
                    <div class="entry-hd">
                        <label class="entry-label">折扣</label>
                    </div>
                    <div class="entry-bd">
                        <input class="entry-input" id="localdiscount" type="number" />
                    </div>
                </div>
                <div class="entry">
                    <div class="entry-hd">
                        <label class="entry-label">投放数量</label>
                    </div>
                    <div class="entry-bd">
                        <input class="entry-input" id="total" type="number" />
                    </div>
                </div>
                <div class="entry">
                    <div class="entry-hd">
                        <label class="entry-label">生效日期</label>
                    </div>
                    <div class="entry-bd">
                        <input class="entry-input" id="begintime" type="date" />
                    </div>
                </div>
                <div class="entry">
                    <div class="entry-hd">
                        <label class="entry-label">过期日期</label>
                    </div>
                    <div class="entry-bd">
                        <input class="entry-input" id="endtime" type="date" />
                    </div>
                </div>
                <div class="title">使用说明</div>
                <div class="entry">
                    <div class="entry-bd">
                        <textarea class="entry-textarea" id="description">买单前请主动出示收银员，本券为一次性使用。</textarea>
                    </div>
                </div>
                <div class="title">适用门店</div>
                <div class="entry-check">
                    <a class="entry entry-link" href="javascript:void(0)">
                        <div class="entry-bd">添加门店</div>
                    </a>
                </div>
                <div class="entry-btn">
                    <div class="btn">
                        <a class="btn-primart" href="javascript:void(0)" id="submit">创建</a>
                    </div>
                </div>
            </div>
        </script>
        <script id="discount-class" type="text/html">
            <div class="page">
                <div class="title">品类折扣</div>
                <div class="entry">
                    <div class="entry-hd">
                        <label class="entry-label">卡券名</label>
                    </div>
                    <div class="entry-bd">
                        <input class="entry-input" id="cardname" type="text" placeholder="6个字以内，不含折扣券三个字" />
                    </div>
                </div>
                <div class="entry">
                    <div class="entry-hd">
                        <label class="entry-label">限定品类</label>
                    </div>
                    <div class="entry-bd">
                        <input class="entry-input" id="accept_category" type="text" />
                    </div>
                </div>
                <div class="entry">
                    <div class="entry-hd">
                        <label class="entry-label">折扣</label>
                    </div>
                    <div class="entry-bd">
                        <input class="entry-input" id="localdiscount" type="number" />
                    </div>
                </div>
                <div class="entry">
                    <div class="entry-hd">
                        <label class="entry-label">投放数量</label>
                    </div>
                    <div class="entry-bd">
                        <input class="entry-input" id="total" type="number" />
                    </div>
                </div>
                <div class="entry">
                    <div class="entry-hd">
                        <label class="entry-label">生效日期</label>
                    </div>
                    <div class="entry-bd">
                        <input class="entry-input" id="begintime" type="date" />
                    </div>
                </div>
                <div class="entry">
                    <div class="entry-hd">
                        <label class="entry-label">过期日期</label>
                    </div>
                    <div class="entry-bd">
                        <input class="entry-input" id="endtime" type="date" />
                    </div>
                </div>
                <div class="title">使用说明</div>
                <div class="entry">
                    <div class="entry-bd">
                        <textarea class="entry-textarea" id="description">买单前请主动出示收银员，本券为一次性使用。</textarea>
                    </div>
                </div>
                <div class="title">适用门店</div>
                <div class="entry-check">
                    <a class="entry entry-link" href="javascript:void(0)">
                        <div class="entry-bd">添加门店</div>
                    </a>
                </div>
                <div class="entry-btn">
                    <div class="btn">
                        <a class="btn-primart" href="javascript:void(0)" id="submit">创建</a>
                    </div>
                </div>
            </div>
        </script>
        <script id="voucher-curr" type="text/html">
            <div class="page">
                <div class="title">限额抵用</div>
                <div class="entry">
                    <div class="entry-hd">
                        <label class="entry-label">卡券名</label>
                    </div>
                    <div class="entry-bd">
                        <input class="entry-input" id="cardname" type="text" placeholder="6个字以内，不含抵用券三个字" />
                    </div>
                </div>
                <div class="entry">
                    <div class="entry-hd">
                        <label class="entry-label">最低消费金额</label>
                    </div>
                    <div class="entry-bd">
                        <input class="entry-input" id="leastcost" type="number" />
                    </div>
                </div>
                <div class="entry">
                    <div class="entry-hd">
                        <label class="entry-label">投放数量</label>
                    </div>
                    <div class="entry-bd">
                        <input class="entry-input" id="total" type="number" />
                    </div>
                </div>
                <div class="entry">
                    <div class="entry-hd">
                        <label class="entry-label">抵用金额</label>
                    </div>
                    <div class="entry-bd">
                        <input class="entry-input" id="reducecost" type="number" />
                    </div>
                </div>
                <div class="entry">
                    <div class="entry-hd">
                        <label class="entry-label">生效日期</label>
                    </div>
                    <div class="entry-bd">
                        <input class="entry-input" id="begintime" type="date" />
                    </div>
                </div>
                <div class="entry">
                    <div class="entry-hd">
                        <label class="entry-label">过期日期</label>
                    </div>
                    <div class="entry-bd">
                        <input class="entry-input" id="endtime" type="date" />
                    </div>
                </div>
                <div class="title">使用说明</div>
                <div class="entry">
                    <div class="entry-bd">
                        <textarea class="entry-textarea" id="description">买单前请主动出示收银员，本券为一次性使用。</textarea>
                    </div>
                </div>
                <div class="title">适用门店</div>
                <div class="entry-check">
                    <a class="entry entry-link" href="javascript:void(0)">
                        <div class="entry-bd">添加门店</div>
                    </a>
                </div>
                <div class="entry-btn">
                    <div class="btn">
                        <a class="btn-primart" href="javascript:void(0)" id="submit">创建</a>
                    </div>
                </div>
            </div>
        </script>
        <script id="voucher-class" type="text/html">
            <div class="page">
                <div class="title">品类抵用</div>
                <div class="entry">
                    <div class="entry-hd">
                        <label class="entry-label">卡券名</label>
                    </div>
                    <div class="entry-bd">
                        <input class="entry-input" id="cardname" type="text" placeholder="6个字以内，不含抵用券三个字" />
                    </div>
                </div>
                <div class="entry">
                    <div class="entry-hd">
                        <label class="entry-label">限定品类</label>
                    </div>
                    <div class="entry-bd">
                        <input class="entry-input" id="accept_category" type="text" />
                    </div>
                </div>
                <div class="entry">
                    <div class="entry-hd">
                        <label class="entry-label">投放数量</label>
                    </div>
                    <div class="entry-bd">
                        <input class="entry-input" id="total" type="number" />
                    </div>
                </div>
                <div class="entry">
                    <div class="entry-hd">
                        <label class="entry-label">抵用金额</label>
                    </div>
                    <div class="entry-bd">
                        <input class="entry-input" id="reducecost" type="number" />
                    </div>
                </div>
                <div class="entry">
                    <div class="entry-hd">
                        <label class="entry-label">生效日期</label>
                    </div>
                    <div class="entry-bd">
                        <input class="entry-input" id="begintime" type="date" />
                    </div>
                </div>
                <div class="entry">
                    <div class="entry-hd">
                        <label class="entry-label">过期日期</label>
                    </div>
                    <div class="entry-bd">
                        <input class="entry-input" id="endtime" type="date" />
                    </div>
                </div>
                <div class="title">使用说明</div>
                <div class="entry">
                    <div class="entry-bd">
                        <textarea class="entry-textarea" id="description">买单前请主动出示收银员，本券为一次性使用。</textarea>
                    </div>
                </div>
                <div class="title">适用门店</div>
                <div class="entry-check">
                    <a class="entry entry-link" href="javascript:void(0)">
                        <div class="entry-bd">添加门店</div>
                    </a>
                </div>
                <div class="entry-btn">
                    <div class="btn">
                        <a class="btn-primart" href="javascript:void(0)" id="submit">创建</a>
                    </div>
                </div>
            </div>
        </script>
        <script id="voucher-nocill" type="text/html">
            <div class="page">
                <div class="title">无门坎抵用</div>
                <div class="entry">
                    <div class="entry-hd">
                        <label class="entry-label">卡券名</label>
                    </div>
                    <div class="entry-bd">
                        <input class="entry-input" id="cardname" type="text" placeholder="6个字以内，不含抵用券三个字" />
                    </div>
                </div>
                <div class="entry">
                    <div class="entry-hd">
                        <label class="entry-label">投放数量</label>
                    </div>
                    <div class="entry-bd">
                        <input class="entry-input" id="total" type="number" />
                    </div>
                </div>
                <div class="entry">
                    <div class="entry-hd">
                        <label class="entry-label">抵用金额</label>
                    </div>
                    <div class="entry-bd">
                        <input class="entry-input" id="reducecost" type="number" />
                    </div>
                </div>
                <div class="entry">
                    <div class="entry-hd">
                        <label class="entry-label">生效日期</label>
                    </div>
                    <div class="entry-bd">
                        <input class="entry-input" id="begintime" type="date" />
                    </div>
                </div>
                <div class="entry">
                    <div class="entry-hd">
                        <label class="entry-label">过期日期</label>
                    </div>
                    <div class="entry-bd">
                        <input class="entry-input" id="endtime" type="date" />
                    </div>
                </div>
                <div class="title">使用说明</div>
                <div class="entry">
                    <div class="entry-bd">
                        <textarea class="entry-textarea" id="description">买单前请主动出示收银员，本券为一次性使用。</textarea>
                    </div>
                </div>
                <div class="title">适用门店</div>
                <div class="entry-check">
                    <a class="entry entry-link" href="javascript:void(0)">
                        <div class="entry-bd">添加门店</div>
                    </a>
                </div>
                <div class="entry-btn">
                    <div class="btn">
                        <a class="btn-primart" href="javascript:void(0)" id="submit">创建</a>
                    </div>
                </div>
            </div>
        </script>
        <script id="warn" type="text/html">
            <div class="entry-ft">
                <i class="iconfont">&#xe601;</i>
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
        <script type="text/javascript" src="../../res/js/WeiXinCard/increate.js"></script>
        <script type="text/javascript">
            $(function() {
                increate.init();
            });
        </script>
    </body>
</html>