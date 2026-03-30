import { LightningElement, track, api, wire } from 'lwc';
import { LightningNavigationElement } from 'c/lwcUtils';
import LightningConfirm from 'lightning/confirm';

import PromoterDailyReport_ATTACHMENT from '@salesforce/label/c.PromoterDailyReport_ATTACHMENT';
import PromoterDailyReport_ACTIONS from '@salesforce/label/c.PromoterDailyReport_ACTIONS';
import PromoterDailyReport_RequiredCheck from '@salesforce/label/c.PromoterDailyReport_RequiredCheck';
import PromoterDailyReport_DeleteReminder from '@salesforce/label/c.PromoterDailyReport_DeleteReminder';
import PromoterDailyReport_AddItemCheck from '@salesforce/label/c.PromoterDailyReport_AddItemCheck';

import PromoterDailyReport_FieldsCheck from '@salesforce/label/c.PromoterDailyReport_FieldsCheck';
import PromoterDailyReport_ShareCheck from '@salesforce/label/c.PromoterDailyReport_ShareCheck';

import PromoterDailyReport_AddNewItemSuccess from '@salesforce/label/c.PromoterDailyReport_AddNewItemSuccess';
import PromoterDailyReport_MARKET_INSGHT from '@salesforce/label/c.PromoterDailyReport_MARKET_INSGHT';

import getInitData from '@salesforce/apex/MarketInsightController.getInitData';
import saveRecord from '@salesforce/apex/MarketInsightController.saveRecord';

export default class MarketInsightLwc extends LightningNavigationElement {

    @api lwcName = PromoterDailyReport_MARKET_INSGHT;

    @api type;
    @api recordId;
    @api viewMode;
    @api isShowSpinner;
    @track recordList = [];
    @track deleteRecordList = [];
    @track isEmpty = false;
    @track fields = {};
    @track isChile = false;
    deletIndex;

    label = { PromoterDailyReport_ATTACHMENT, PromoterDailyReport_ACTIONS, PromoterDailyReport_RequiredCheck, PromoterDailyReport_DeleteReminder, PromoterDailyReport_AddItemCheck, PromoterDailyReport_FieldsCheck, PromoterDailyReport_ShareCheck };
    fieldList = ['Brands__c', 'ProductLine__c', 'Product__c', 'Share__c', 'Quantity__c', 'AveragePrice__c'];

    averagePrice(index) {
        let _this = this;
        console.log('averagePrice -> index：' + index);
        Object.defineProperties(this.recordList[index], {
            "averagePrice": {
                get() {
                    console.log('averagePrice -> this.Quantity__c：' + this.Quantity__c);
                    let result = 0;
                    let quantity = Number(this.Quantity__c);
                    let sale = Number(this.Sales);
                    console.log('averagePrice -> get：');
                    if ((!Number.isNaN(quantity) && (quantity != 0)) && (!Number.isNaN(sale) && (sale != 0))) {
                        result = (sale * 1000) / quantity;
                    }
                    console.log('averagePrice -> result：' + result);
                    return result;
                }
            }
        });
        Object.defineProperties(this.recordList[index], {
            "isShowProduct": {
                get() {
                    if (typeof this.Brands__c == "undefined") {
                        return false;
                    } else if (this.Brands__c == '' || this.Brands__c == null) {
                        return false;
                    } else if (typeof this.Brands__c == "number") {
                        return !isNaN(this.Brands__c);
                    }
                    return true;
                }
            }
        });
        Object.defineProperties(this.recordList[index], {
            "isShowAverage": {
                get() {
                    let result = (this.averagePrice == '0' ? false : true)
                    console.log('isShowAverage -> result：' + result);
                    return result;
                }
            }
        });
    }

    get viewStyle() {
        let viewStyleStr = 'background: unset; cursor: no-drop; border: 0; box-shadow: none;';
        return this.viewMode ? viewStyleStr : '';
    }

    connectedCallback() {
        this.isShowSpinner = true;
        if (this.recordId) {
            getInitData({
                recordId: this.recordId,
            }).then(data => {
                this.isShowSpinner = false;
                this.isChile = data.data.isChile;
                this.fields = data.data.fields;
                if (data.isSuccess && data.data.marketInsightList.length > 0) {
                    this.recordList = data.data.marketInsightList;
                    console.log('getInitData ——> recordList：' + this.recordList);
                    for (let index = 0; index < this.recordList.length; index++) {
                        this.averagePrice(index);
                        this.recordList[index].index = index;
                        if (this.isFilledOut(this.recordList[index].Sales__c)) {
                            this.recordList[index].Sales = this.recordList[index].Sales__c / 1000;
                            // this.recordList[index].Share = Number(this.recordList[index].Share__c) / 100;
                        }

                    }
                } else {
                    this.isEmpty = true;
                }
            }).catch(error => {
                this.catchError(error);
                this.isShowSpinner = false;
            });
        }
    }

    inputChangeHandler(event) {
        let index = event.target.dataset.index;
        let targetName = event.target.dataset.fieldName;
        let targetValue = event.target.value;
        console.log('inputChangeHandler —> index：' + index);
        console.log('inputChangeHandler —> targetName：' + targetName);
        console.log('inputChangeHandler —> value：' + event.target.value);
        if (targetName == 'Sales') {
            this.recordList[index][targetName] = event.target.value;
            console.log('inputChangeHandler ——> is sales');
            targetName = 'Sales__c';
            targetValue *= 1000;
        }

        //Lay add限制share只能为100以内
        if (targetName == 'Share__c' && targetValue > 100) {
            this.showWarning(PromoterDailyReport_ShareCheck.format(this.fields.Share__c));
        }
        this.recordList[index][targetName] = targetValue;
        this.recordList[index].fieldsEdit = 'true';
        this.recordList[index].isUpdated = true;
        console.log('inputChangeHandler ——> averagePrice：' + this.recordList[index].averagePrice);
    }

    lookUpChangeHandler(event) {
        let index = event.target.dataset.index;
        let targetName = event.target.dataset.fieldName;
        console.log('lookUpChangeHandler ——> index：' + index);
        console.log('lookUpChangeHandler ——> targetName：' + targetName);

        if (event.detail.selectedRecord == undefined) {
            this.recordList[index][targetName] = null;
        } else {
            this.recordList[index][targetName] = event.detail.selectedRecord.Id;
        }
        this.recordList[index].fieldsEdit = 'true';
        this.recordList[index].isUpdated = true;
    }

    lookupBrandFilter = {
        'lookup': 'CustomLookupProvider.BrandContainsHisense'
    }


    handleKeyDown(event) {
        if (event.keyCode === 13) {
            event.preventDefault();
        }
    }


    async itemRemoveHandler(event) {
        this.deletIndex = event.target.dataset.index;
        console.log('deletIndex：' + this.deletIndex);
        // let modalEle = this.template.querySelector('c-modal-lwc');
        // modalEle.showModal();

        const deleteResult = await LightningConfirm.open({
            // message: 'Information will be deleted if you click "OK"; click "Cancel" to cancel.',
            message: PromoterDailyReport_DeleteReminder,
            variant: 'headerless',
            label: 'This is the aria-label value',
        });
        if (deleteResult) {
            this.handleOk();
        }
    }

    handleOk() {
        // this.template.querySelector('c-modal-lwc').closeModal();
        let index = this.deletIndex;
        if (this.recordList[index].hasOwnProperty('Id')) {
            this.deleteRecordList.push(this.recordList[index].Id);
        }
        if (this.recordList.length == 1) {
            this.recordList = [];
            this.isEmpty = true;
        } else {
            this.recordList.splice(index, 1);
        }
    }

    @api
    itemAddHandler(event) {
        let result = this.addCheck();
        console.log('itemAddHandler ——> result.flag：' + result.flag);
        let index = this.recordList.length;
        console.log("len：" + index);
        if (result.flag) {
            this.recordList.push({
                index: index,
                isUpdated: false
            })
            this.averagePrice(index);
            console.log('itemAddHandler ——> averagePrice：' + this.recordList[index].averagePrice);
            this.isEmpty = false;
            this.showSuccess(PromoterDailyReport_AddNewItemSuccess);
        } else {
            this.showWarning(result.message);
        }
    }

    @api
    saveData() {
        this.isShowSpinner = true;
        let result = this.saveCheck();
        console.log('result.flag：' + result.flag);
        console.log('this.deleteRecordList：' + this.deleteRecordList);
        console.log('this.recordList：' + JSON.stringify(this.recordList));
        if (result.flag) {
            saveRecord({
                recordDataJson: JSON.stringify(this.recordList),
                deleteRecordIdList: this.deleteRecordList,
                fileMapJson: JSON.stringify(this.fileMap),
                recordId: this.recordId,
            }).then(data => {
                this.isShowSpinner = false;
                if (data.isSuccess) {
                    for (let key in data.data) {
                        this[key] = data.data[key];
                    }
                    this.recordList.forEach((item, i) => {
                        console.log('saveRecord ——> item.Id ：' + item.Id);
                        item.index = i;
                        item.Sales = item.Sales__c / 1000;
                        this.averagePrice(i);

                    });
                    let eles = this.template.querySelectorAll('c-upload-files-lwc');
                    for (let index = 0; eles && index < eles.length; index++) {
                        let ele = eles[index];
                        ele.refresh();
                    }
                    // this.showSuccess(data.message);
                } else {
                    // this.showError(data.message);
                }
                this.dispatchEvent(new CustomEvent('savedata', {
                    detail: {
                        result: data
                    }
                }));

            }).catch(error => {
                console.log('error' + JSON.stringify(error));
                this.catchError(error);
                this.isShowSpinner = false;
            });
        } else {
            this.showWarning(result.message);
            this.isShowSpinner = false;
        }

    }

    @api
    checkData() {
        return this.saveCheck().message;
    }

    saveCheck() {
        if (this.recordList.length > 0) {
            // 校验最后一条记录是否为空
            let lastItem = this.recordList[this.recordList.length - 1];
            let lastReocrdIsNotEmpty = true;
            if (typeof lastItem.isUpdatedFile != "undefined" && lastItem.isUpdatedFile) {
                lastReocrdIsNotEmpty = false;
            } else if (typeof lastItem.isUpdated == "undefined") {
                lastReocrdIsNotEmpty = false;
            } else {
                for (let key in lastItem) {
                    if (this.fieldList.includes(key) && this.isFilledOut(lastItem[key])) {
                        console.log('Key：' + key);
                        lastReocrdIsNotEmpty = false;
                        break;
                    }
                }
            }

            console.log('lastItem：' + JSON.stringify(lastItem));
            // if ((typeof lastItem.isUpdated != "undefined") && (!lastItem.isUpdated)) {
            if (lastReocrdIsNotEmpty) {
                this.recordList.splice(this.recordList.length - 1, 1);
            }
            console.log('this.recordList.length：' + this.recordList.length);
        }
        return this.addCheck();
    }


    addCheck() {
        let result = {
            flag: true,
            message: '',
        }
        const missFields = new Set();
        if (this.recordList.length == 0) {
            return result;
        }
        for (let index = 0; index < this.recordList.length; index++) {
            if (!this.isFilledOut(this.recordList[index].Brands__c) && !this.isFilledOut(this.recordList[index].ProductLine__c)) {
                result.flag = false;
                missFields.add(PromoterDailyReport_FieldsCheck.format(this.fields.Brands__c, this.fields.ProductLine__c));
            }
            if (!this.isFilledOut(this.recordList[index].Quantity__c) && !this.isFilledOut(this.recordList[index].Sales__c) && !this.isFilledOut(this.recordList[index].Share__c)) {
                result.flag = false;
                missFields.add(PromoterDailyReport_FieldsCheck.format(this.fields.Quantity__c + ' ,' + this.fields.Share__c, this.fields.Sales__c));
            }
            //Lay add 保存前校验share只能为100以内
            if (this.recordList[index].Share__c > 100) {
                result.flag = false;
                missFields.add(PromoterDailyReport_ShareCheck.format(this.fields.Share__c));
            }
        }

        let missFieldsList = Array.from(missFields.keys());
        if (missFieldsList.length > 0) {
            result.message += '[' + this.lwcName + ' — ';
            for (let index = 0; index < missFieldsList.length; index++) {
                if (index == missFieldsList.length - 1) {
                    result.message += missFieldsList[index] + ']';
                } else {
                    result.message += missFieldsList[index] + '/';
                }
            }
        }
        console.log('check message：' + result.message);
        return result;
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

    fileMap = {};
    handleSelectFiles(event) {
        this.fileMap[event.target.dataset.index] = event.detail.records;
        this.recordList[event.target.dataset.index].isUpdated = true;
        this.recordList[event.target.dataset.index].isUpdatedFile = true;
    }

}