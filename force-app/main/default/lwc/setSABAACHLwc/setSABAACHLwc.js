import { track, api, wire } from 'lwc';
import { LightningNavigationElement } from 'c/lwcUtils';
import { NavigationMixin } from 'lightning/navigation';
import List_Button_Calculate from '@salesforce/label/c.List_Button_Calculate';

import runBatch from '@salesforce/apex/NewWeeklySalesTargetButtonController.runBatch';

export default class SetSABAACHLwc extends LightningNavigationElement {

    label = { 
        List_Button_Calculate
    };
    
    @api objectLoad;
    @track week;
    connectedCallback() {
        this.week = this.getYearWeek(new Date()) + '';
    }

    runAll(){
        runBatch({
            recordId: '',
            week: this.week
        }).then(data => {
            if (data.isSuccess) {
                this.showWarning(data.msg);
            } 

            this.goBackToList();
        }).catch(error => {
            this.goBackToList();
        })
    }
    goBackToList() {
        // 导航到当前对象的列表视图
        this[NavigationMixin.Navigate]({
            type: 'standard__objectPage',
            attributes: {
                objectApiName: 'Weekly_Sales_Target__c',
                actionName: 'list'
            }
        });
    }

    handleFieldChange(event) {
        this.week = event.target.value;
    }

    // 周选项
    get getWeekOptions() {
        var optins = [];
        var week = this.getYearWeek(new Date(new Date().getFullYear()+'-12-31'));
        for(var i = week; i >= 1; i--){

            var weekScope = this.getWeekDates(new Date().getFullYear(), i);
            optins.push({label: 'WK' + i + ' (' + weekScope.start + '-' + weekScope.end + ')', value: i + ''});
        }
        return optins;
    }
    //计算本年的周数
    getYearWeek(endDate) {
        //本年的第一天
        var beginDate = new Date(endDate.getFullYear(), 0, 1);
        //星期从0-6,0代表星期天，6代表星期六
        var endWeek = endDate.getDay();
        if (endWeek == 0) endWeek = 7;
        var beginWeek = beginDate.getDay();
        if (beginWeek == 0) beginWeek = 7;
        //计算两个日期的天数差
        var millisDiff = endDate.getTime() - beginDate.getTime();
        var dayDiff = Math.floor(( millisDiff + (beginWeek - endWeek) * (24 * 60 * 60 * 1000)) / 86400000);
        return Math.ceil(dayDiff / 7) + 1;
    } 

    //计算周日期范围
    getWeekDates(year, week) {
        var d = new Date(year, 0, 1 + (week - 1) * 7); // 1st day of year + (week - 1) * 7
        var day = d.getDay();
        var diff = d.getDate() - day + (day === 0 ? -6 : 1); // Adjust when day is sunday

        var startDate = new Date(d.setDate(diff));
        var endDate = new Date(d.setDate(diff + 6));
        return {
        start: startDate.getMonth() + 1 + '/' + startDate.getDate(),
        end: endDate.getMonth() + 1 + '/' + endDate.getDate(),
        };
    }
}