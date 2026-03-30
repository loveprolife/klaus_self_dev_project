import { LightningElement, track, api, wire } from 'lwc';
import { LightningNavigationElement } from 'c/lwcUtils';
import LightningConfirm from 'lightning/confirm';

import PromoterDailyReport_ATTACHMENT from '@salesforce/label/c.PromoterDailyReport_ATTACHMENT';
import PromoterDailyReport_ACTIONS from '@salesforce/label/c.PromoterDailyReport_ACTIONS';
import PromoterDailyReport_DeleteReminder from '@salesforce/label/c.PromoterDailyReport_DeleteReminder';
import PromoterDailyReport_AddNewItemSuccess from '@salesforce/label/c.PromoterDailyReport_AddNewItemSuccess';

import PromoterDailyReport_Returns_And_Credit from '@salesforce/label/c.PromoterDailyReport_Returns_And_Credit';

import getInitData from '@salesforce/apex/ReturnsAndCreditController.getInitData';
import saveRecord from '@salesforce/apex/ReturnsAndCreditController.saveRecord';

export default class ReturnsAndCreditLwc extends LightningNavigationElement {

    @api lwcName = PromoterDailyReport_Returns_And_Credit;

    @api type;
    @api recordId;
    @api isShowSpinner;

    @track recordList = [];
    @track deleteRecordList = [];
    @track fields;

    label = {PromoterDailyReport_ATTACHMENT, PromoterDailyReport_ACTIONS};

    reportDate;

    addReturnedQuantity(index) {
        let _this = this;
        Object.defineProperties(this.recordList[index], {
            "returnedQuantity": {
                get() {
                    let totalReturnQuantity = 0;
                    let items = this.productItemList;
                    for (let index = 0; index < items.length; index++) {
                        if(typeof items[index].Quantity__c == "undefined") {
                            continue;
                        }
                        console.log('items[index].Quantity__c：' + items[index].Quantity__c);
                        if (!Number.isNaN(items[index].Quantity__c) && (items[index].Quantity__c != 0)) {
                            totalReturnQuantity += Number(items[index].Quantity__c);
                        }
                    }
                    console.log('totalReturnQuantity：' + totalReturnQuantity);
                    return (totalReturnQuantity == 0 ? '' : '' + totalReturnQuantity);
                }
            }
        });
    }

    connectedCallback() {
        this.isShowSpinner = true;
        if (this.recordId) {
            getInitData({
                recordId: this.recordId,
            }).then(data => {
                this.isShowSpinner = false;
                this.reportDate = data.data.reportDate.split('-');
                this.fields = data.data.fields;
                console.log('reportDate：' + this.reportDate);
                if (data.isSuccess && data.data.returnsAndCreditList.length > 0) {
                    let researchListGroupByNo = data.data.researchListGroupByNo;
                    for (let item in researchListGroupByNo) {
                        var recordListLen = this.recordList.length;
                        var productItemList = researchListGroupByNo[item];
                        this.recordList.push({
                            productItemList: productItemList,
                            Name: item,
                            index: recordListLen,
                            UserFeedbackSources__c: productItemList[0].UserFeedbackSources__c,
                            Description__c: productItemList[0].Description__c,
                            ProvideJobNumber__c: productItemList[0].ProvideJobNumber__c,
                            ProvideCreditNumber__c: productItemList[0].ProvideCreditNumber__c,
                            IsAllPaperworkInOrder__c: productItemList[0].IsAllPaperworkInOrder__c,
                            WhatPaperworkIsMissing__c: productItemList[0].WhatPaperworkIsMissing__c,
                        });
                        this.addReturnedQuantity(recordListLen);
                        for (let i = 0; i < productItemList.length; i++) {
                            if (!(this.isFilledOut(productItemList[i].Product__c) || this.isFilledOut(productItemList[i].Quantity__c) || this.isFilledOut(productItemList[i].UnitPrice__c))) {
                                productItemList.splice(i, 1);
                            }
                        }
                        for (let index = 0; index < this.recordList[recordListLen].productItemList.length; index++) {
                            this.recordList[recordListLen].productItemList[index].index = recordListLen + '' + index;
                            console.log('getInitData ——> productItemList ——> index：' + this.recordList[recordListLen].productItemList[index].index);
                        }
                    }
                    console.log('recordList ready');
                } else {
                    console.log('getInitData ——> isEmpty');
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
        console.log('inputChangeHandler —> index：' + index);
        console.log('inputChangeHandler —> targetName：' + targetName);

        this.recordList[index][targetName] = event.target.value;
        this.recordList[index].fieldsEdit = 'true';

        console.log('inputChangeHandler ——> end');
    }

    productInputChangeHandler(event) {
        let index = event.target.dataset.index;
        let productIndex = event.target.dataset.id;
        let targetName = event.target.dataset.fieldName;
        console.log('productInputChangeHandler —> index' + index);
        console.log('productInputChangeHandler —> productIndex' + productIndex);
        console.log('productInputChangeHandler —> targetName' + targetName);

        this.recordList[index].productItemList[productIndex][targetName] = event.target.value;
        this.recordList[index].productItemList[productIndex].fieldsEdit = 'true';

        console.log('productInputChangeHandler ——> end');
    }

    productItemAddHandler(event) {
        let index = event.target.dataset.index;
        let result = this.saveCheck();
        console.log('returnsAndCredit ——> productItemAddHandler ——> result.flag：' + result.flag);
        if (result.flag) {
            console.log('returnsAndCredit ——> productItemAddHandler ——> productItemIndex：' + this.recordList[index].productItemList.length);
            this.recordList[index].productItemList.push({
                index: this.recordList[index].length + '' + this.recordList[index].productItemList.length,
            });
            this.showSuccess(PromoterDailyReport_AddNewItemSuccess);
        }
    }

    async productItemRemoveHandler(event) {
        let index = event.target.dataset.index;
        let productIndex = event.target.dataset.id;
        const deleteResult = await LightningConfirm.open({
            // message: 'Information will be deleted if you click "OK"; click "Cancel" to cancel.',
            message: PromoterDailyReport_DeleteReminder,
            variant: 'headerless',
            label: 'This is the aria-label value',
        });
        console.log('productItemRemoveHandler ——> deleteResult：' + deleteResult);
        if (deleteResult) {
            console.log('productItemRemoveHandler');
            if (this.recordList[index].productItemList[productIndex].hasOwnProperty('Id')) {
                this.deleteRecordList.push(this.recordList[index].productItemList[productIndex].Id);
                console.log('productItemRemoveHandler —> need delete');
            }
            console.log('productItemRemoveHandler —> delete');
            this.recordList[index].productItemList.splice(productIndex, 1);

        }
    }

    async itemRemoveHandler(event) {
        let index = event.target.dataset.index;
        console.log('itemRemoveHandler ——> index：' + index);
        const deleteResult = await LightningConfirm.open({
            // message: 'Information will be deleted if you click "OK"; click "Cancel" to cancel.',
            message: PromoterDailyReport_DeleteReminder,
            variant: 'headerless',
            label: 'This is the aria-label value',
        });
        console.log('itemRemoveHandler ——> deleteResult：' + deleteResult);
        if (deleteResult) {
            console.log('itemRemoveHandler');
            let productListLen = this.recordList[index].productItemList.length;
            for (let i = 0; i < productListLen; i++) {
                if (this.recordList[index].productItemList[i].hasOwnProperty('Id')) {
                    this.deleteRecordList.push(this.recordList[index].productItemList[i].Id);
                    console.log('itemRemoveHandler —> need delete');
                }
            }
            console.log('itemRemoveHandler —> delete');
            this.recordList.splice(index, 1);
        }

    }

    @api
    itemAddHandler(event) {
        let result = this.saveCheck();
        console.log('returnsAndCredit ——> itemAddHandler ——> result.flag：' + result.flag);
        if (result.flag) {
            var len = this.recordList.length;
            console.log("itemAddHandler —> len：" + len);
            var productItemList = [];
            this.recordList.push({
                index: len,
                Name: 'RC-' + this.reportDate[0] + this.reportDate[1] + this.reportDate[2] + '0000' + len,
                productItemList: productItemList,
            });
            this.addReturnedQuantity(len);
            this.showSuccess(PromoterDailyReport_AddNewItemSuccess);
        } else {
            this.showWarning(result.message);
            this.isShowSpinner = false;
        }
        console.log('returnsAndCredit ——> itemAddHandler ——> end！');

    }

    @api
    saveData() {
        this.isShowSpinner = true;
        let result = this.saveCheck();
        console.log('result.flag：' + result.flag);
        console.log('this.deleteRecordList：' + this.deleteRecordList);
        console.log('this.recordList：' + JSON.stringify(this.recordList));
        if (result.flag) {
            let allRecordList = [];
            let len = this.recordList.length;
            console.log('saveData ——> recordListLen：' + len);
            for (let index = 0; index < len; index++) {
                let productLen = this.recordList[index].productItemList.length;
                console.log('saveData ——> productLen：' + productLen);
                if (productLen > 0) {
                    for (let i = 0; i < productLen; i++) {
                        if (!(this.isFilledOut(this.recordList[index].productItemList[i].Product__c) ||
                            this.isFilledOut(this.recordList[index].productItemList[i].Quantity__c) ||
                            this.isFilledOut(this.recordList[index].productItemList[i].UnitPrice__c))) {
                            continue;
                        }
                        this.recordList[index].productItemList[i].Name = this.recordList[index].Name;
                        this.recordList[index].productItemList[i].UserFeedbackSources__c = this.recordList[index].UserFeedbackSources__c;
                        this.recordList[index].productItemList[i].Description__c = this.recordList[index].Description__c;
                        this.recordList[index].productItemList[i].ProvideJobNumber__c = this.recordList[index].ProvideJobNumber__c;
                        this.recordList[index].productItemList[i].ProvideCreditNumber__c = this.recordList[index].ProvideCreditNumber__c;
                        this.recordList[index].productItemList[i].IsAllPaperworkInOrder__c = this.recordList[index].IsAllPaperworkInOrder__c;
                        this.recordList[index].productItemList[i].WhatPaperworkIsMissing__c = this.recordList[index].WhatPaperworkIsMissing__c;

                        if (this.recordList[index].fieldsEdit == 'true') {
                            this.recordList[index].productItemList[i].fieldsEdit = 'true';
                        }
                        console.log('saveData ——> allRecordList ——> push ——> ');
                        allRecordList.push(this.recordList[index].productItemList[i]);
                    }
                } else {
                    delete this.recordList[index].productItemList;
                    console.log('saveData ——> delete ——> recordList：' + this.recordList[index]);
                    allRecordList.push(this.recordList[index]);
                }
                // allRecordList.push.apply(allRecordList, this.recordList[i].productItemList);
            }
            console.log('saveData ——> allRecordList：' + allRecordList.length);
            saveRecord({
                recordDataJson: JSON.stringify(allRecordList),
                deleteRecordIdList: this.deleteRecordList,
                fileMapJson: JSON.stringify(this.fileMap),
                recordId: this.recordId,
            }).then(data => {
                this.isShowSpinner = false;
                if (data.isSuccess) {
                    this.recordList = [];
                    let researchListGroupByNo = data.data.researchListGroupByNo;
                    for (let item in researchListGroupByNo) {
                        var recordListLen = this.recordList.length;
                        var productItemList = researchListGroupByNo[item];
                        this.recordList.push({
                            productItemList: productItemList,
                            Name: item,
                            index: recordListLen,
                            UserFeedbackSources__c: productItemList[0].UserFeedbackSources__c,
                            Description__c: productItemList[0].Description__c,
                            ProvideJobNumber__c: productItemList[0].ProvideJobNumber__c,
                            ProvideCreditNumber__c: productItemList[0].ProvideCreditNumber__c,
                            IsAllPaperworkInOrder__c: productItemList[0].IsAllPaperworkInOrder__c,
                            WhatPaperworkIsMissing__c: productItemList[0].WhatPaperworkIsMissing__c,
                        });
                        this.addReturnedQuantity(recordListLen);
                        for (let i = 0; i < productItemList.length; i++) {
                            if (!(this.isFilledOut(productItemList[i].Product__c) || this.isFilledOut(productItemList[i].Quantity__c) || this.isFilledOut(productItemList[i].UnitPrice__c))) {
                                productItemList.splice(i, 1);
                            }
                        }
                        for (let index = 0; index < this.recordList[recordListLen].productItemList.length; index++) {
                            this.recordList[recordListLen].productItemList[index].index = recordListLen + '' + index;
                        }
                    }
                    let eles = this.template.querySelectorAll('c-upload-files-lwc');
                    for (let index = 0; eles && index < eles.length; index++) {
                        let ele = eles[index];
                        ele.refresh();
                    }
                } else {
                    // this.showError(data.message);
                }
                this.dispatchEvent(new CustomEvent('savedata', {
                    detail: {
                        result: data
                    }
                }));

            }).catch(error => {
                this.catchError(error);
                this.isShowSpinner = false;
            });
        } else {
            this.showWarning(result.message);
            this.isShowSpinner = false;
        }

    }

    saveCheck() {
        let result = {
            flag: true,
            message: '',
        }
        if (this.recordList.length == 0) {
            return result;
        }
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
    }

    @api
    checkData() {
        return this.saveCheck().message;
    }

    @api
    getlength() {
        return this.recordList.length;
    }
}