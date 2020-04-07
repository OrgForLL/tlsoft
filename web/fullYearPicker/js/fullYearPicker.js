(function () {
    var fullYearPicker_nowSelect = null; var fullYearPicker_last = null; var _viewer_ = this; function tdClass(i, disabledDay, sameMonth, values, dateStr) { var cls = i == 0 || i == 6 ? 'weekend' : ''; if (disabledDay && disabledDay.indexOf(i) != -1) cls += (cls ? ' ' : '') + 'disabled'; if (!sameMonth) cls += (cls ? ' ' : '') + 'empty'; if (sameMonth && values && cls.indexOf('disabled') == -1 && values.indexOf(',' + dateStr + ',') != -1) cls += (cls ? ' ' : '') + 'selected'; return cls == '' ? '' : ' class="' + cls + '"'; }
    function renderMonth(year, month, clear, disabledDay, values) {
        var d = new Date(year, month - 1, 1), s = '<table cellpadding="3" cellspacing="1" border="0"' + (clear ? ' class="right"' : '') + '>'
        + '<tr><th colspan="7" class="head">' + year + '年' + month + '月</th></tr>'
        + '<tr><th class="weekend">日</th><th>一</th><th>二</th><th>三</th><th>四</th><th>五</th><th class="weekend">六</th></tr>'; var dMonth = month - 1; var firstDay = d.getDay(), hit = false; s += '<tr>'; for (var i = 0; i < 7; i++)
            if (firstDay == i || hit) { s += '<td date="' + year + '-' + month + '-' + d.getDate() + '"' + tdClass(i, disabledDay, true, values, year + '-' + month + '-' + d.getDate()) + '>' + d.getDate() + '</td>'; d.setDate(d.getDate() + 1); hit = true; } else s += '<td date=""' + tdClass(i, disabledDay, false) + '>&nbsp;</td>'; s += '</tr>'; for (var i = 0; i < 5; i++) {
                s += '<tr>'; for (var j = 0; j < 7; j++) { var dateStr = d.getMonth() == dMonth ? year + '-' + month + '-' + d.getDate() : ""; s += '<td date="' + dateStr + '"' + tdClass(j, disabledDay, d.getMonth() == dMonth, values, year + '-' + month + '-' + d.getDate()) + '>' + (d.getMonth() == dMonth ? d.getDate() : '&nbsp;') + '</td>'; d.setDate(d.getDate() + 1); }
                s += '</tr>';
            }
        return s + '</table>' + (clear ? '<br>' : '');
    }
    function getDateStr(td) { return td.parentNode.parentNode.rows[0].cells[0].innerHTML.replace(/[年月]/g, '-') + td.innerHTML }
    function renderYear(year, el, disabledDay, value) { el.find('td').unbind(); var s = '', values = ',' + value.join(',') + ','; for (var i = 1; i <= 12; i++) s += renderMonth(year, i, i % 4 == 0, disabledDay, values); el.find('div.picker').html(s).find('td').click(function () { if (!/disabled|empty/g.test(this.className)) $(this).toggleClass('selected'); if (this.className.indexOf('empty') == -1 && typeof el.data('config').cellClick == 'function') { el.data('config').cellClick(getDateStr(this), this.className.indexOf('disabled') != -1); $(".fullYearPicker td").removeClass("arrow_box"); $(this).addClass("arrow_box"); fullYearPicker_nowSelect = getDateStr(this); _viewer_.data('config').choose(_viewer_.fullYearPicker('getSelected')); } }); }
    $.fn.selectDates = function (dateArray) { dateArray.forEach(function (item) { $("[date='" + item + "']").addClass("selected"); }); }
    $.fn.fullYearPicker = function (config, param) {
        if (config === 'setDisabledDay' || config === 'setYear' || config === 'getSelected' || config === 'acceptChange' || config === 'setColors' || config === 'initDate') {
            var me = $(this); if (config == 'setYear') { me.data('config').year = param; me.find('div.year a:first').trigger('click', true); }
            else if (config == 'getSelected') {
                return me.find('td.selected').map(function () {
                    var selectStr = getDateStr(this); if (_viewer_.data('config').format === 'YYYY-MM-DD') {
                        var selects = selectStr.split('-'); var yy = selects[0]; var mm = selects[1]; if (Number(mm) < 10) { mm = '0' + mm; }
                        var dd = selects[2]; if (Number(dd) < 10) { dd = '0' + dd; }
                        selectStr = yy + '-' + mm + '-' + dd;
                    }
                    return selectStr;
                }).get();
            }
            else if (config == 'acceptChange') { me.data('config').value = me.fullYearPicker('getSelected'); }
            else if (config == 'setColors') { return me.find('td').each(function () { var d = getDateStr(this); for (var i = 0; i < param.dc.length; i++) if (d == param.dc[i].d) this.style.backgroundColor = param.dc[i].c || param.defaultColor || '#f00'; }); }
            else {
                me.find('td.disabled').removeClass('disabled'); me.data('config').disabledDay = param; if (param) {
                    me.find('table tr:gt(1)').find('td').each(function () {
                        if (param.indexOf(this.cellIndex) != -1)
                            this.className = (this.className || '').replace('selected', '') + (this.className ? ' ' : '') + 'disabled';
                    });
                }
            }
            return this;
        }
        config = $.extend({ year: new Date().getFullYear(), disabledDay: '', value: [], initDate: [], format: "", disable: false }, config); return this.addClass('fullYearPicker').each(function () {
            _viewer_ = $(this); _viewer_.html(""); var me = $(this), year = config.year || new Date().getFullYear(); newConifg = { cellClick: config.cellClick, disabledDay: config.disabledDay, year: year, value: config.value, yearScale: config.yearScale, choose: config.choose, initDate: config.initDate, format: config.format, disable: config.disable }; me.data('config', newConifg); console.log(newConifg)
            var selYear = ''; if (newConifg.yearScale) { selYear = '<select>'; for (var i = newConifg.yearScale.min, j = newConifg.yearScale.max; i < j; i++) selYear += '<option value="' + i + '"' + (i == year ? ' selected' : '') + '>' + i + '</option>'; selYear += '</select>'; }
            selYear = selYear || year; me.append('<div class="year"><a href="#">上一年</a>' + selYear + '年<a href="#" class="next">下一年</a></div><div class="picker"></div>').find('a').click(function (e, setYear) { if (setYear) year = me.data('config').year; else this.innerHTML == '上一年' ? year-- : year++; me.find('select').val(year); renderYear(year, $(this).closest('div.fullYearPicker'), newConifg.disabledDay, newConifg.value); this.parentNode.firstChild.nextSibling.data = year + '年'; return false; }).end().find('select').change(function () { me.fullYearPicker('setYear', this.value); }); if (_viewer_.data('config').disable === true) { _viewer_.data('config').disabledDay = '0,1,2,3,4,5,6'; }
            renderYear(year, me, newConifg.disabledDay, newConifg.value); if (newConifg.initDate.length > 0) {
                newConifg.initDate.forEach(function (p1, p2, p3) {
                    if (newConifg.format === 'YYYY-MM-DD') {
                        var items = p1.split('-');
                        var mm = items[1];
                        if (mm.substr(0, 1) === '0') mm = mm.substr(1, 1);
                        /*if (mm[0] === '0') {
                            mm = mm[1];
                        }*/
                        var dd = items[2]; if (dd[0] === '0') { dd = dd[1]; }
                        var item = items[0] + '-' + mm + '-' + dd;
                    }
                    $("[date='" + item + "']").addClass("selected")
                })
            }
        });
    }; function getMaxDay(year, month) { var thisDate = new Date(year, month, 0); return thisDate.getDate(); }
    function selectDay(type, del) {
        var day = Number(fullYearPicker_nowSelect.split("-")[2]); var year = fullYearPicker_nowSelect.split("-")[0]; var month = fullYearPicker_nowSelect.split("-")[1]; var maxDay = Number(getMaxDay(year, month)) + 1; if (maxDay) {
            switch (type) {
                case 38: if (day < 7 || day === 7) { return }
                    day -= 7; break; case 37: if (day === 1) { return }
                        day -= 1; break; case 40: if ((day + 7) > Number(maxDay) || (day + 7) === Number(maxDay)) { return }
                            day += 7; break; case 39: if (day === Number(maxDay) - 1) { return }
                                day += 1; break; default: break;
            }
            fullYearPicker_nowSelect = year + '-' + month + '-' + day; var $td = $("[date='" + fullYearPicker_nowSelect + "']"); if (del) { if (!$td.hasClass("empty") && !$td.hasClass("selected")) { $(".fullYearPicker td").removeClass("arrow_box"); $td.addClass("selected").addClass("arrow_box"); _viewer_.data('config').choose(_viewer_.fullYearPicker('getSelected')); } else if (!$td.hasClass("empty") && $td.hasClass("selected")) { $(".fullYearPicker td").removeClass("arrow_box"); $td.removeClass("selected").addClass("arrow_box"); _viewer_.data('config').choose(_viewer_.fullYearPicker('getSelected')); } } else { if (!$td.hasClass("empty")) { $(".fullYearPicker td").removeClass("arrow_box"); $td.addClass("selected").addClass("arrow_box"); _viewer_.data('config').choose(_viewer_.fullYearPicker('getSelected')); } }
        }
    }
    document.onkeydown = function (event) {
        if (_viewer_.data('config').disabledDay !== "") { return; }
        if (fullYearPicker_nowSelect === null) { return }; var e = event || window.event || arguments.callee.caller.arguments[0]; if (e && e.keyCode === 38 || e && e.keyCode === 37) { if (e.keyCode === 38) { selectDay(38, true); } else if (e && e.keyCode === 37) { selectDay(37, true); } }
        if (e && e.keyCode === 40 || e && e.keyCode === 39) { if (e.keyCode === 40) { selectDay(40, true); } else if (e && e.keyCode === 39) { selectDay(39, true); } }
    };
})();