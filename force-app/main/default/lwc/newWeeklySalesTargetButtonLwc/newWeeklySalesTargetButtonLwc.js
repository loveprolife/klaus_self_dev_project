import { track, api, wire } from 'lwc';
import { LightningNavigationElement } from 'c/lwcUtils';

import NewWeeklySalesTarget from '@salesforce/label/c.NewWeeklySalesTarget';
import EditWeeklySalesTarget from '@salesforce/label/c.EditWeeklySalesTarget';
import PromoterDailyReport_RequiredCheck from '@salesforce/label/c.PromoterDailyReport_RequiredCheck';

import getInitData from '@salesforce/apex/NewWeeklySalesTargetButtonController.getInitData';
import saveData from '@salesforce/apex/NewWeeklySalesTargetButtonController.saveData';

export default class NewWeeklySalesTargetButtonLwc extends LightningNavigationElement {
    label = { 
        NewWeeklySalesTarget,
        EditWeeklySalesTarget,
    };

    @api recordId;

    @track isView = false;
    @track isEdit = false;
    @track channleEditFlg = false;

    @track weeklySalesTarger = {
        Store_Name__c: '',
        Channel_Name__c: ''
    };

    @track isShowDepartment = true;
    @track isShowSpinner = false;
    @track isShowProduct = false;
    @track isShowProductSearch = false;
    @track isSouthAfrica = false;
    @track isArgentina = false;

    @track fields = {};

    @track storeOptionAll = [];
    @track storeOptions = [];
    @track channelOptions = [];

    connectedCallback() {

        this.isShowSpinner = true;
        getInitData({
            recordId: this.recordId
        }).then(data => {
            if (data.isSuccess) {
                for (let key in data.data) {
                    this[key] = data.data[key];
                }

                // 手动刷新相关组件
                const element = this.template.querySelectorAll('c-combobox-autocomplete')[0];
                element.updateOption(this.channelOptions);

            } else {
                this.showError(data.message);
            }
            
            if(this.isFilledOut(this.recordId)){
                this.isEdit = true;
                this.channleEditFlg = (!this.isFilledOut(this.weeklySalesTarger.Store__c));
            //无recordId
            }else{
                this.weeklySalesTarger.Week__c = this.getYearWeek(new Date());
                this.weeklySalesTarger.Product_Line__c = 'TV';
                this.updateLookup('onProduct');
                this.weeklySalesTarger.Model_Name__c = '';
                this.isEdit = false;
            }
        }).catch(error => {
            this.catchError(error);
        })

        this.isShowSpinner = false;
    }

    cancelHandleClick(event) {
        this.goToObject('Weekly_Sales_Target__c');
    }

    saveHandleClick(event) {
        this.isShowSpinner = true;
        let result = this.saveCheck();
        if (result.flag) {

            delete this.weeklySalesTarger.Channel_Name__c;
            delete this.weeklySalesTarger.Store_Name__c;
            let recordList = [];
            recordList.push(this.weeklySalesTarger);
            saveData({
                recordListJson: JSON.stringify(recordList),
                isEdit: this.isEdit,
            }).then(resp => {
                if (resp.isSuccess) {
                    this.goToRecord(resp.data.recordId);
                } else {
                    this.showError(resp.message);
                }
            }).catch(error => {
                this.catchError(error);
            })
        } else {
            this.showError(result.message);
            this.isShowSpinner = false;
        }

        this.isShowSpinner = false;
    }

    handleFieldChange(event) {
        console.log('handleFieldChange ——> target value: ' + event.target.value);
        this.weeklySalesTarger[event.target.dataset.fieldName] = event.target.value;

        if(event.target.dataset.fieldName == 'Product_Line__c') {
            this.updateLookup('onProduct');
        }
    }

    channelOptionChange(event){

        this.weeklySalesTarger['Channel_item__c'] = event.detail.value;
        this.weeklySalesTarger['Channel_Name__c'] = event.detail.label;

        this.weeklySalesTarger['Store__c'] = '';
        this.weeklySalesTarger['Store_Name__c'] = '';
        this.storeOptions = [];
        
        this.storeOptionAll.forEach(element => {
            if(element.Channel_Item__c == event.detail.value){
                let op = {
                    label: element.label,
                    value: element.value
                };
                this.storeOptions.push(op);
            }
        });
        // 手动刷新相关组件
        const element = this.template.querySelectorAll('c-combobox-autocomplete')[1];
        element.updateOption(this.storeOptions);
    }

    storeOptionChange(event){
        this.weeklySalesTarger['Store__c'] = event.detail.value;
        this.weeklySalesTarger['Store_Name__c'] = event.detail.label;
    }

    updateLookup(name) {
        var cmps = this.template.querySelectorAll('c-lookup-lwc');
        for (let i = 0; i < cmps.length; i++) {
            var lookup = cmps[i];
            if (lookup.name==name) {
                lookup.updateOption({
                    'lookup': 'CustomLookupProvider.ProductFilter',
                    'Product_Line__c': this.weeklySalesTarger.Product_Line__c
                });
                return;
            }
        }
    }

    handleKeyDown(event) {
        if (event.keyCode === 13) {
            event.preventDefault();
        }
    }

    saveCheck() {
        let result = {
            flag: true,
            message: '',
        }

        if (!this.isFilledOut(this.weeklySalesTarger.Sales_Region__c)) {
            result.flag = false;
            result.message = PromoterDailyReport_RequiredCheck + ' ' + this.fields.Sales_Region__c;
            return result;
        }
        if (!this.isFilledOut(this.weeklySalesTarger.Week__c)) {
            result.flag = false;
            result.message = PromoterDailyReport_RequiredCheck + ' ' + this.fields.Week__c;
            return result;
        }
        if (!this.isFilledOut(this.weeklySalesTarger.Channel_item__c)) {
            result.flag = false;
            result.message = PromoterDailyReport_RequiredCheck + ' ' + this.fields.Channel_item__c;
            return result;
        }
        if (!this.isFilledOut(this.weeklySalesTarger.Store__c) && !this.channleEditFlg) {
            result.flag = false;
            result.message = PromoterDailyReport_RequiredCheck + ' ' + this.fields.Store__c;
            return result;
        }
        if (!this.isFilledOut(this.weeklySalesTarger.Product_Line__c)) {
            result.flag = false;
            result.message = PromoterDailyReport_RequiredCheck + ' ' + this.fields.Product_Line__c;
            return result;
        }
        if (!this.isFilledOut(this.weeklySalesTarger.Model__c)) {
            result.flag = false;
            result.message = PromoterDailyReport_RequiredCheck + ' ' + this.fields.Model__c;
            return result;
        }

        return result;
    }

    // 添加产品（自定义lookupFilter）
    lookupFilter = {
        'lookup' : 'CustomLookupProvider.ProductAllFilter'
    }
    
    // 选择产品变更
    handleChangeProductOption(resp) {
        if (resp.detail.selectedRecord==undefined) {
            return;
        } 

        this.weeklySalesTarger.Model__c = resp.detail.selectedRecord.Id;
        this.weeklySalesTarger.Model_Name__c = resp.detail.selectedRecord.Name;
    }

    isFilledOut(content) {
        if (typeof content == "undefined") {
            return false;
        } else if (content == '' || content == null) {
            return false;
        } else if (typeof content == "number") {
            return !isNaN(content);
        }
        return true;
    }

    // 周选项
    get getWeekOptions() {
        var optins = [];
        var week = this.getYearWeek(new Date(new Date().getFullYear()+'-12-31'));
        for(var i = week; i >= 1; i--){

            var weekScope = this.getWeekDates(new Date().getFullYear(), i);
            optins.push({label: 'WK' + i + ' (' + weekScope.start + '-' + weekScope.end + ')', value: i});
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