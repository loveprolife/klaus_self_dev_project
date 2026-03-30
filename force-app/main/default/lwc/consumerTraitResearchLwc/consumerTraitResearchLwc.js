import { LightningElement, track, api, wire } from 'lwc';
import { LightningNavigationElement } from 'c/lwcUtils';
import LightningConfirm from 'lightning/confirm';

import PromoterDailyReport_ATTACHMENT from '@salesforce/label/c.PromoterDailyReport_ATTACHMENT';
import PromoterDailyReport_ACTIONS from '@salesforce/label/c.PromoterDailyReport_ACTIONS';
import PromoterDailyReport_DeleteReminder from '@salesforce/label/c.PromoterDailyReport_DeleteReminder';

import PromoterDailyReport_DateOfPurchase from '@salesforce/label/c.PromoterDailyReport_DateOfPurchase';
import PromoterDailyReport_SUMMARY from '@salesforce/label/c.PromoterDailyReport_SUMMARY';
import PromoterDailyReport_AddNewItemSuccess from '@salesforce/label/c.PromoterDailyReport_AddNewItemSuccess';

import PromoterDailyReport_Consumer_Trait_Research from '@salesforce/label/c.PromoterDailyReport_Consumer_Trait_Research';

import getInitData from '@salesforce/apex/ConsumerTraitResearchController.getInitData';
import saveRecord from '@salesforce/apex/ConsumerTraitResearchController.saveRecord';

export default class ConsumerTraitResearchLwc extends LightningNavigationElement {

    @api lwcName = PromoterDailyReport_Consumer_Trait_Research;

    @api recordId;
    @api viewMode;
    @api isShowSpinner;
    @track recordList = [];
    @track deleteRecordList = [];
    @track fields;

    deletType;
    deletIndex;
    deletProductIndex;
    label = { PromoterDailyReport_ATTACHMENT, PromoterDailyReport_ACTIONS, PromoterDailyReport_SUMMARY, PromoterDailyReport_DeleteReminder };
    reportDate;
    reportDateSplit;

    recordFieldList = ['Gender__c', 'Race__c', 'Age__c', 'Occupation__c', 'IncomeBracket__c', 'ReceiveNewsletter__c', 'eMailAddress__c'];
    productFieldList = ['Product__c', 'UnitPrice__c', 'Quantity__c'];
    allFieldList = ['Id', 'No__c', 'Gender__c', 'Race__c', 'Age__c', 'Occupation__c', 'IncomeBracket__c', 'DateOfPurchase__c', 'ReceiveNewsletter__c', 'eMailAddress__c', 'fieldsEdit', 'isUpdated', 'Product__c', 'UnitPrice__c', 'Quantity__c', 'Store__c', 'Research__c'];

    addSummaryAttribute(index) {
        console.log('addSummaryAttribute ——> ');
        let _this = this;
        Object.defineProperties(this.recordList[index], {
            "Summary": {
                get() {
                    let result = 0;
                    let productItemList = this.productItemList;
                    for (let i = 0; i < productItemList.length; i++) {
                        let quantity = Number(productItemList[i].Quantity__c);
                        let unitPrice = Number(productItemList[i].UnitPrice__c);
                        if ((!Number.isNaN(quantity) && (quantity != 0)) && (!Number.isNaN(unitPrice) && (unitPrice != 0))) {
                            result += quantity * unitPrice;
                        } else if (!Number.isNaN(unitPrice) && (unitPrice != 0)) {
                            result += unitPrice;
                        }
                    }
                    console.log('addSummaryAttribute ——> Summary：' + result);
                    return result;
                }
            }
        });
    }

    connectedCallback() {
        if (this.recordId) {
            this.isShowSpinner = true;
            getInitData({
                recordId: this.recordId,
            }).then(data => {
                this.isShowSpinner = false;
                this.reportDate = data.data.reportDate;
                this.reportDateSplit = data.data.reportDate.split('-');
                this.fields = data.data.fields;
                console.log('reportDate：' + this.reportDate);
                if (data.isSuccess && data.data.consumerTraitResearchList.length > 0) {
                    let researchListGroupByNo = data.data.researchListGroupByNo;
                    for (let item in researchListGroupByNo) {
                        var recordListLen = this.recordList.length;
                        var productItemList = researchListGroupByNo[item];
                        this.recordList.push({
                            productItemList: productItemList,
                            No__c: item,
                            index: recordListLen,
                            Id: productItemList[0].Id,
                            Gender__c: productItemList[0].Gender__c,
                            Race__c: productItemList[0].Race__c,
                            Age__c: productItemList[0].Age__c,
                            Occupation__c: productItemList[0].Occupation__c,
                            IncomeBracket__c: productItemList[0].IncomeBracket__c,
                            DateOfPurchase__c: productItemList[0].DateOfPurchase__c,
                            ReceiveNewsletter__c: productItemList[0].ReceiveNewsletter__c,
                            eMailAddress__c: productItemList[0].eMailAddress__c,

                        });
                        for (let i = 0; i < productItemList.length; i++) {
                            if (!(this.isFilledOut(productItemList[i].Product__c) || this.isFilledOut(productItemList[i].Quantity__c) || this.isFilledOut(productItemList[i].UnitPrice__c))) {
                                productItemList.splice(i, 1);
                            }
                        }
                        this.addSummaryAttribute(recordListLen);
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
        console.log('inputChangeHandler —> index' + index);
        console.log('inputChangeHandler —> targetName' + targetName);
        console.log('inputChangeHandler —> value' + event.target.value);

        this.recordList[index][targetName] = event.target.value;
        this.recordList[index].fieldsEdit = 'true';
        this.recordList[index].isUpdated = true;
        console.log('inputChangeHandler ——> end');
    }

    lookUpChangeHandler(event) {
        let index = event.target.dataset.index;
        let productIndex = event.target.dataset.id;
        let targetName = event.target.dataset.fieldName;
        console.log('lookUpChangeHandler ——> index：' + index);
        console.log('lookUpChangeHandler ——> targetName：' + targetName);

        if (event.detail.selectedRecord == undefined) {
            this.recordList[index].productItemList[productIndex][targetName] = null;
        } else {
            this.recordList[index].productItemList[productIndex][targetName] = event.detail.selectedRecord.Id;
        }
        this.recordList[index].productItemList[productIndex].fieldsEdit = 'true';
        this.recordList[index].productItemList[productIndex].isUpdated = true;

    }

    lookupProductFilter = {
        'lookup': 'CustomLookupProvider.ProductAllFilter'
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
        this.recordList[index].productItemList[productIndex].isUpdated = true;

        console.log('productInputChangeHandler ——> end');
    }

    productItemAddHandler(event) {
        let index = event.target.dataset.index;

        console.log('consumerTraitResearch ——> productItemAddHandler ——> productItemIndex：' + this.recordList[index].productItemList.length);
        this.recordList[index].productItemList.push({
            index: this.recordList[index].productItemList.length,
            isUpdated: false
        });
        this.showSuccess(PromoterDailyReport_AddNewItemSuccess);

    }

    async productItemRemoveHandler(event) {
        this.deletType = 'product';
        this.deletIndex = event.target.dataset.index;
        this.deletProductIndex = event.target.dataset.id;
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

    async itemRemoveHandler(event) {
        this.deletType = 'item';
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
        let productIndex = this.deletProductIndex;
        if (this.deletType == 'product') {
            if (this.recordList[index].productItemList[productIndex].hasOwnProperty('Id')) {
                this.deleteRecordList.push(this.recordList[index].productItemList[productIndex].Id);
            }
            this.recordList[index].productItemList.splice(productIndex, 1);
        } else {
            let productListLen = this.recordList[index].productItemList.length;
            for (let i = 0; i < productListLen; i++) {
                if (this.recordList[index].productItemList[i].hasOwnProperty('Id')) {
                    this.deleteRecordList.push(this.recordList[index].productItemList[i].Id);
                }
            }
            this.recordList.splice(index, 1);
        }


    }


    @api
    itemAddHandler(event) {
        let result = this.saveCheckForDate();
        console.log('consumerTraitResearch ——> itemAddHandler ——> result.flag：' + result.flag);
        if (result.flag) {
            var len = this.recordList.length;
            console.log("itemAddHandler —> len：" + len);
            var productItemList = [];
            let today = new Date();
            let year = today.getFullYear();
            let month = new String(today.getMonth() + 1).padStart(2, '0');
            let day = new String(today.getDate()).padStart(2, '0');
            let lenString = new String(len).padStart(5, '0');

            this.recordList.push({
                index: len,
                No__c: 'CTR-SA-' + year + month + day + lenString,
                DateOfPurchase__c: today.getFullYear() + '-' + (today.getMonth() + 1) + '-' + today.getDate(),
                productItemList: productItemList,
                isUpdated: false
            })
            this.addSummaryAttribute(len);
            this.showSuccess(PromoterDailyReport_AddNewItemSuccess);
        } else {
            this.showWarning(result.message);
        }
        console.log('consumerTraitResearch ——> itemAddHandler ——> end！');

    }

    @api
    saveData() {
        this.isShowSpinner = true;

        // 校验最后一条记录是否为空
        // let lastItem = this.recordList[this.recordList.length - 1];
        // console.log('lastItem：' + lastItem);
        // let lastReocrdIsEmpty = true;
        // for (let key in lastItem) {
        //     console.log('lastItem[key]：' + lastItem[key]);
        //     if (this.isFilledOut(lastItem[key])) {
        //         lastReocrdIsEmpty = false;
        //         break;
        //     }
        // }
        // if (lastReocrdIsEmpty) {
        //     this.recordList.splice(this.recordList.length - 1, 1);
        // }

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
                        let recordItem = this.recordList[index].productItemList[i];
                        for (let key in this.recordList[index]) {
                            if (key == 'Id') {
                                console.log('Id---------：' + this.recordList[index][key]);
                                continue;
                            }
                            if (this.allFieldList.includes(key) && this.isFilledOut(this.recordList[index][key])) {
                                recordItem[key] = this.recordList[index][key];
                            }
                        }
                        console.log('recordItem： ——> ' + JSON.stringify(recordItem));
                        allRecordList.push(recordItem);
                        // if (!(this.isFilledOut(this.recordList[index].productItemList[i].Product__c) ||
                        //     this.isFilledOut(this.recordList[index].productItemList[i].Quantity__c) ||
                        //     this.isFilledOut(this.recordList[index].productItemList[i].UnitPrice__c))) {
                        //     continue;
                        // }
                        // this.recordList[index].productItemList[i].No__c = this.recordList[index].No__c;
                        // this.recordList[index].productItemList[i].Gender__c = this.recordList[index].Gender__c;
                        // this.recordList[index].productItemList[i].Race__c = this.recordList[index].Race__c;
                        // this.recordList[index].productItemList[i].Age__c = this.recordList[index].Age__c;
                        // this.recordList[index].productItemList[i].Occupation__c = this.recordList[index].Occupation__c;
                        // this.recordList[index].productItemList[i].IncomeBracket__c = this.recordList[index].IncomeBracket__c;
                        // this.recordList[index].productItemList[i].DateOfPurchase__c = this.recordList[index].DateOfPurchase__c;
                        // this.recordList[index].productItemList[i].ReceiveNewsletter__c = this.recordList[index].ReceiveNewsletter__c;
                        // this.recordList[index].productItemList[i].eMailAddress__c = this.recordList[index].eMailAddress__c;


                        // if (this.recordList[index].fieldsEdit == 'true') {
                        //     this.recordList[index].productItemList[i].fieldsEdit = 'true';
                        // }
                        // console.log('saveData ——> allRecordList ——> push ——> ');
                        // allRecordList.push(this.recordList[index].productItemList[i]);
                    }
                } else {
                    // delete this.recordList[index].productItemList;
                    // console.log('saveData ——> delete ——> recordList：' + this.recordList[index]);
                    // allRecordList.push(this.recordList[index]);
                    let recordItem = {};
                    for (let key in this.recordList[index]) {
                        if (this.allFieldList.includes(key) && this.isFilledOut(this.recordList[index][key])) {
                            recordItem[key] = this.recordList[index][key];
                        }
                    }
                    console.log('recordItem： ——> ' + JSON.stringify(recordItem));
                    allRecordList.push(recordItem);
                }
                // allRecordList.push.apply(allRecordList, this.recordList[i].productItemList);
            }
            console.log('saveData ——> allRecordList：' + allRecordList.length);
            saveRecord({
                recordDataJson: JSON.stringify(allRecordList),
                deleteRecordIdList: this.deleteRecordList,
                recordId: this.recordId,
            }).then(data => {
                this.isShowSpinner = false;
                if (data.isSuccess && data.data.consumerTraitResearchList.length > 0) {
                    this.recordList = [];
                    let researchListGroupByNo = data.data.researchListGroupByNo;
                    for (let item in researchListGroupByNo) {
                        var recordListLen = this.recordList.length;
                        var productItemList = researchListGroupByNo[item];
                        this.recordList.push({
                            productItemList: productItemList,
                            No__c: item,
                            index: recordListLen,
                            Id: productItemList[0].Id,
                            Gender__c: productItemList[0].Gender__c,
                            Race__c: productItemList[0].Race__c,
                            Age__c: productItemList[0].Age__c,
                            Occupation__c: productItemList[0].Occupation__c,
                            IncomeBracket__c: productItemList[0].IncomeBracket__c,
                            DateOfPurchase__c: productItemList[0].DateOfPurchase__c,
                            ReceiveNewsletter__c: productItemList[0].ReceiveNewsletter__c,
                            eMailAddress__c: productItemList[0].eMailAddress__c,

                        });
                        for (let i = 0; i < productItemList.length; i++) {
                            if (!(this.isFilledOut(productItemList[i].Product__c) || this.isFilledOut(productItemList[i].Quantity__c) || this.isFilledOut(productItemList[i].UnitPrice__c))) {
                                productItemList.splice(i, 1);
                            }
                        }
                        this.addSummaryAttribute(recordListLen);
                        for (let index = 0; index < this.recordList[recordListLen].productItemList.length; index++) {
                            this.recordList[recordListLen].productItemList[index].index = recordListLen + '' + index;
                            console.log('getInitData ——> productItemList ——> index：' + this.recordList[recordListLen].productItemList[index].index);
                        }
                    }

                    console.log('ConsumerTraitResearchLwc ——> save success');
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

    saveCheckForDate() {
        let result = {
            flag: true,
            message: '',
        }
        const missFields = new Set();
        if (this.recordList.length == 0) {
            return result;
        } else {
            for (let i = 0; i < this.recordList.length; i++) {
                if (this.isFilledOut(this.recordList[i].DateOfPurchase__c)) {
                    var filled = new Date(this.recordList[i].DateOfPurchase__c);
                    // var report = new Date(this.reportDate);
                    let today = new Date();
                    if (filled.getTime() > today.getTime()) {
                        missFields.add(PromoterDailyReport_DateOfPurchase);
                        result.flag = false;
                    }
                }

            }
        }

        let missFieldsList = Array.from(missFields.keys());
        console.log('missFieldsList：' + missFieldsList);
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

    @api
    checkData() {
        return this.saveCheck().message;
    }

    saveCheck() {
        console.log('Consumer Trait Research saveCheck ------：');
        if (this.recordList.length > 0) {
            let lastReocrdIsNotEmpty = true;
            let lastRecord = this.recordList[this.recordList.length - 1];
            for (let key in lastRecord) {
                if (this.recordFieldList.includes(key) && this.isFilledOut(lastRecord[key])) {
                    console.log('Key：' + key);
                    lastReocrdIsNotEmpty = false;
                    break;
                }
            }
            if (lastReocrdIsNotEmpty && lastRecord.productItemList.length > 0) {
                let lastRecordProduct = lastRecord.productItemList[lastRecord.productItemList.length - 1];
                for (let key in lastRecordProduct) {
                    if (this.productFieldList.includes(key) && this.isFilledOut(lastRecordProduct[key])) {
                        console.log('Key：' + key);
                        lastReocrdIsNotEmpty = false;
                        break;
                    }
                }
            }

            if (lastReocrdIsNotEmpty) {
                this.recordList.splice(this.recordList.length - 1, 1);
            }
        }
        console.log('Consumer Trait Research saveCheck ——> saveCheckForDate：');
        return this.saveCheckForDate();
    }
}