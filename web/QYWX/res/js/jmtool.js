/*
 使用方法：1.引入js  document.write("<script src='../tltools/jmtool.js'><\/script>"); 
             注意：动态加载调用函数时：需要在window.onload=function(){}里面调用；反之不用；【动态加载的js内容是异步执行的】
           2.jmtool.DNC("7VP878Q87877ID1P"); //解密
             jmtool.ENC("7DNY00101M101760"); //加密
*/
var jmtool = (function () {
    var jmfun = {
        DNC: function (str) {
            var i, j;
            var keyIndex = "-~!@#$%'&*()_+={}[]\\|:;\",./<>? DEF01CG2LMN345JKOZ6US78HITW9ABVPQRXY";
            var keyVal = "-~!@#$%'&*()_+={}[]\\|:;\",./<>? NOGAD45JBCKL8VW9RSTUZ01XY23EFI67MHPQ";
            var tempCode, code;
            tempCode = str;
            code = "";
            for (var i = 0; i < str.length; i++) {
                tempCode = str.substr(i, 1);
                j = keyIndex.indexOf(tempCode);
                if (j > -1) {
                    code = keyVal.substr(j, 1) + code;
                } else {
                    code = tempCode + code;
                }
            }
            return code;
        },
        ENC: function (str) {
            var i, j;
            var keyIndex = "-~!@#$%'&*()_+={}[]\\|:;\",./<>? NOGAD45JBCKL8VW9RSTUZ01XY23EFI67MHPQ";
            var keyVal = "-~!@#$%'&*()_+={}[]\\|:;\",./<>? DEF01CG2LMN345JKOZ6US78HITW9ABVPQRXY";
            var tempCode, code;
            tempCode = str;
            code = "";
            for (var i = 0; i < str.length; i++) {
                tempCode = str.substr(i, 1);
                j = keyIndex.indexOf(tempCode);
                if (j > -1) {
                    code = keyVal.substr(j, 1) + code;
                } else {
                    code = tempCode + code;
                }
            }
            return code;
        }
    };

    return jmfun;
})();
