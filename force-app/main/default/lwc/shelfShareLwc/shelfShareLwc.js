import { LightningElement, track, api, wire } from 'lwc';
import { LightningNavigationElement } from 'c/lwcUtils';
import LightningConfirm from 'lightning/confirm';

import PromoterDailyReport_SHARE from '@salesforce/label/c.PromoterDailyReport_SHARE';
import PromoterDailyReport_ATTACHMENT from '@salesforce/label/c.PromoterDailyReport_ATTACHMENT';
import PromoterDailyReport_ACTIONS from '@salesforce/label/c.PromoterDailyReport_ACTIONS';
import PromoterDailyReport_RequiredCheck from '@salesforce/label/c.PromoterDailyReport_RequiredCheck';
import PromoterDailyReport_DeleteReminder from '@salesforce/label/c.PromoterDailyReport_DeleteReminder';
import PromoterDailyReport_DuplicateCheck from '@salesforce/label/c.PromoterDailyReport_DuplicateCheck';
import PromoterDailyReport_AddNewItemSuccess from '@salesforce/label/c.PromoterDailyReport_AddNewItemSuccess';

import PromoterDailyReport_SHELF_SHARE from '@salesforce/label/c.PromoterDailyReport_SHELF_SHARE';

import getInitData from '@salesforce/apex/PromoterShareController.getInitData';
import saveRecord from '@salesforce/apex/PromoterShareController.saveRecord';

export default class ShelfShareLwc extends LightningNavigationElement {

    @api lwcName = PromoterDailyReport_SHELF_SHARE;

    @api type;
    @api recordId;
    @api viewMode;
    @track recordList = [];
    @track deleteRecordList = [];

    @api isShowSpinner;

    recordTypeId;
    recordTypeName = 'Shelf Share';
    accountOfHisense;

    @track fields;

    deletIndex;
    label = {PromoterDailyReport_SHARE, PromoterDailyReport_ATTACHMENT, PromoterDailyReport_ACTIONS, PromoterDailyReport_DeleteReminder};

    addHisenseShare(index) {
        console.log('addHisenseShare：');
        let _this = this;
        Object.defineProperties(this.recordList[index], {
            "hisensShare": {
                get() {
                    let items = this.brandItemList;
                    let brandLen = items.length;
                    let total = 0;
                    let hisense = 0;
                    let percentage = 0;
                    for (let index = 0; index < brandLen; index++) {
                        let number = Number(items[index].Shelf__c);
                        if (!Number.isNaN(number) && (number != 0)) {
                            console.log('hisensShare -> number：' + number);
                            total += number;
                            if (items[index].HisenseFlag__c) {
                                hisense = number;
                            }
                        }

                    }
                    if (total == 0) {
                        if (hisense == 0) {
                            percentage = '-';
                        } else {
                            percentage = 100;
                        }
                    } else {
                        percentage = parseInt((hisense / total) * 100);
                        items[0].Share__c = percentage;
                        percentage += '%';
                    }
                    console.log('hisensShare -> percentage：' + percentage);
                    return percentage;
                }
            }
        });
    }

    connectedCallback() {
        this.isShowSpinner = true;
        if (this.recordId) {
            getInitData({
                recordId: this.recordId,
                recordTypeName: this.recordTypeName,
            }).then(data => {
                this.isShowSpinner = false;
                this.accountOfHisense = data.data.hisenseId;
                this.recordTypeId = data.data.ShelfShare;
                this.fields = data.data.fields;
                if (data.isSuccess) {
                    let promoterShareGroupByProductLine = data.data.promoterShareGroupByProductLine;
                    for (let item in promoterShareGroupByProductLine) {
                        var recordListLen = this.recordList.length;
                        var brandItemList = promoterShareGroupByProductLine[item];
                        this.recordList.push({
                            brandItemList: brandItemList,
                            ProductLine__c: item,
                            index: recordListLen,
                        });
                        this.addHisenseShare(recordListLen);
                        for (let index = 0; index < this.recordList[recordListLen].brandItemList.length; index++) {
                            this.recordList[recordListLen].brandItemList[index].index = recordListLen + '' + index;
                            if (this.recordList[recordListLen].brandItemList[index].HisenseFlag__c) {
                                this.recordList[recordListLen].Comment__c = this.recordList[recordListLen].brandItemList[index].Comment__c;
                                this.recordList[recordListLen].brandIndex = recordListLen + '' + index;
                                this.recordList[recordListLen].Id = this.recordList[recordListLen].brandItemList[index].Id;
                                console.log('getInitData ——> recordList ——> brandIndex：' + this.recordList[recordListLen].brandIndex);
                                console.log('getInitData ——> recordList ——> Id：' + this.recordList[recordListLen].Id);
                            }
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
        let brandIndex = event.target.dataset.id;
        let targetName = event.target.dataset.fieldName;
        console.log('inputChangeHandler —> index' + index);
        console.log('inputChangeHandler —> brandIndex' + brandIndex);
        console.log('inputChangeHandler —> targetName' + targetName);
        let canFillInFlag = true;
        if (targetName == 'Brands__c') {
            let brandItem = this.recordList[index].brandItemList;
            for (let i = 0; i < brandItem.length; i++) {
                let flag = this.isFilledOut(brandItem[i].Brands__c);
                if (flag && brandItem[i].Brands__c == event.target.value) {
                    // this.showError('Cannot choose duplicate brands！');
                    this.showWarning(PromoterDailyReport_DuplicateCheck.format(this.fields.Brands__c));
                    canFillInFlag = false;
                    break;
                }
            }
        }
        if (canFillInFlag) {
            this.recordList[index].brandItemList[brandIndex][targetName] = event.target.value;
            this.recordList[index].brandItemList[brandIndex].fieldsEdit = 'true';
            this.recordList[index].brandItemList[brandIndex].isUpdated = true;
        } else {
            this.recordList[index].brandItemList[brandIndex].Brands__c = null;
        }

        if(targetName == 'Shelf__c') {
            this.recordList[index].brandItemList[0].fieldsEdit = 'true';
            this.recordList[index].brandItemList[0].isUpdated = true;
        }
        console.log('inputChangeHandler ——> end');
    }

    lookUpChangeHandler(event) {
        let index = event.target.dataset.index;
        let brandIndex = event.target.dataset.id;
        let targetName = event.target.dataset.fieldName;
        console.log('lookUpChangeHandler ——> index：' + index);
        console.log('lookUpChangeHandler ——> brandIndex：' + brandIndex);
        console.log('lookUpChangeHandler ——> targetName：' + targetName);

        if (event.detail.selectedRecord == undefined) {
            this.recordList[index].brandItemList[brandIndex][targetName] = null;
        } else {
            this.recordList[index].brandItemList[brandIndex][targetName] = event.detail.selectedRecord.Id;
        }
        this.recordList[index].brandItemList[brandIndex].fieldsEdit = 'true';
        this.recordList[index].brandItemList[brandIndex].isUpdated = true;
    }

    lookupBrandFilter = {
        'lookup': 'CustomLookupProvider.BrandDoNotContainsHisense'
    }

    productLineChangeHandler(event) {
        let index = event.target.dataset.index;
        let value = event.target.value;
        let len = this.recordList[index].brandItemList.length;
        console.log('productLineChangeHandler ——> index：' + index);
        console.log('productLineChangeHandler ——> value：' + value);
        this.recordList[index].ProductLine__c = value;
        for (let i = 0; i < len; i++) {
            console.log('productLineChangeHandler ——> i:' + i);
            this.recordList[index].brandItemList[i].ProductLine__c = value;
            this.recordList[index].brandItemList[i].fieldsEdit = true;
            this.recordList[index].brandItemList[i].isUpdated = true;
            console.log('productLineChangeHandler ——> ProductLine__c:' + this.recordList[index].brandItemList[i].ProductLine__c);
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
        let brandIndex = this.recordList[index].brandItemList.length - 1;
            if (this.recordList[index].brandItemList[brandIndex].hasOwnProperty('Id')) {
                this.deleteRecordList.push(this.recordList[index].brandItemList[brandIndex].Id);
                console.log('itemRemoveHandler —> need delete');
            }
            if(this.recordList[index].brandItemList.length == 1) {
                this.recordList.splice(index, 1);
            } else {
                this.recordList[index].brandItemList.splice(brandIndex, 1);
            }

    }

    brandItemAdd(event) {
        console.log('brandItemAdd');
        let index = event.target.dataset.index;
        let recordLen = this.recordList[index].length;
        let brandLen = this.recordList[index].brandItemList.length;

        let result = this.addCheck();
        console.log('shelfShare ——> brandItemAdd ——> result.flag：' + result.flag);
        if (result.flag) {
            let productLine = '';
            if (this.isFilledOut(this.recordList[index].ProductLine__c)) {
                productLine = this.recordList[index].ProductLine__c;
            }
            this.recordList[index].brandItemList.push({
                index: recordLen + '' + brandLen,
                ProductLine__c: productLine,
                isUpdated: false
            });
            this.showSuccess(PromoterDailyReport_AddNewItemSuccess);
        } else {
            this.showWarning(result.message);
        }

    }

    @api
    itemAddHandler(event) {
        let result = this.addCheck();
        console.log('shelfShare ——> saveData ——> result.flag：' + result.flag);
        if (result.flag) {
            var len = this.recordList.length;
            console.log("itemAddHandler —> len：" + len);
            var brandItemList = [];
            this.recordList.push({
                index: len,
                brandItemList: brandItemList,
            })
            this.addHisenseShare(len);
            let brandLen = this.recordList[len].brandItemList.length;
            let recordLen = len + 1;
            console.log("itemAddHandler —> brandLen：" + brandLen);
            this.recordList[len].brandItemList.push({
                HisenseFlag__c: true,
                Brands__c: this.accountOfHisense,
                index: recordLen + '' + brandLen,
                isUpdated: false
            })
            console.log('itemAddHandler ——> brandItemList ——> index：' + this.recordList[len].brandItemList[brandLen].index);
            brandLen += 1;
            console.log("itemAddHandler —> brandLen：" + brandLen);
            this.recordList[len].brandItemList.push({
                index: recordLen + '' + brandLen,
                HisenseFlag__c: false,
                isUpdated: false
            })
            this.showSuccess(PromoterDailyReport_AddNewItemSuccess);
            console.log('itemAddHandler ——> brandItemList ——> index：' + this.recordList[len].brandItemList[brandLen].index);
        } else {
            this.showWarning(result.message);
            this.isShowSpinner = false;
        }

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
            for (let i = 0; i < len; i++) {
                allRecordList.push.apply(allRecordList, this.recordList[i].brandItemList);
            }
            saveRecord({
                recordDataJson: JSON.stringify(allRecordList),
                deleteRecordIdList: this.deleteRecordList,
                fileMapJson: JSON.stringify(this.fileMap),
                recordId: this.recordId,
                recordTypeId: this.recordTypeId,
            }).then(data => {
                this.isShowSpinner = false;
                if (data.isSuccess) {
                    this.recordList = [];
                    let promoterShareGroupByProductLine = data.data.promoterShareGroupByProductLine;
                    for (let item in promoterShareGroupByProductLine) {
                        var recordListLen = this.recordList.length;
                        var brandItemList = promoterShareGroupByProductLine[item];
                        this.recordList.push({
                            brandItemList: brandItemList,
                            ProductLine__c: item,
                            index: recordListLen,
                        });
                        this.addHisenseShare(recordListLen);
                        for (let index = 0; index < this.recordList[recordListLen].brandItemList.length; index++) {
                            this.recordList[recordListLen].brandItemList[index].index = recordListLen + '' + index;
                            if (this.recordList[recordListLen].brandItemList[index].HisenseFlag__c) {
                                this.recordList[recordListLen].Comment__c = this.recordList[recordListLen].brandItemList[index].Comment__c;
                                this.recordList[recordListLen].brandIndex = recordListLen + '' + index;
                                this.recordList[recordListLen].Id = this.recordList[recordListLen].brandItemList[index].Id;
                                console.log('saveRecord ——> recordList ——> brandIndex：' + this.recordList[recordListLen].brandIndex);
                                console.log('saveRecord ——> recordList ——> Id：' + this.recordList[recordListLen].Id);
                            }
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

    @api
    checkData() {
        return this.saveCheck().message;
    }

    deleteLastOne() {
        console.log('Shelf Share deleteLastOne ----：');
        let lastReocrdIsEmpty = true;
        if (this.recordList.length > 0) {
            let lastRecordItemList = this.recordList[this.recordList.length - 1].brandItemList;
            if (lastRecordItemList.length > 0) {
                // 校验最后一条记录是否为空
                let lastItem = lastRecordItemList[lastRecordItemList.length - 1];
                if (!lastItem.HisenseFlag__c) {
                    console.log('lastItem：' + JSON.stringify(lastItem));
                    if (typeof lastItem.isUpdatedFile != "undefined" && lastItem.isUpdatedFile) {
                        lastReocrdIsEmpty = false;
                    } else if (typeof lastItem.isUpdated == "undefined") {
                        lastReocrdIsEmpty = false;
                    } else if (this.isFilledOut(lastItem.Shelf__c)) {
                        lastReocrdIsEmpty = false;
                    } else if (this.isFilledOut(lastItem.Brands__c)) {
                        lastReocrdIsEmpty = false;
                    }
                    console.log('lastReocrdIsEmpty：' + lastReocrdIsEmpty);
                    if (lastReocrdIsEmpty) {
                        lastRecordItemList.splice(lastRecordItemList.length - 1, 1);
                    }
                    console.log('lastRecordItemList.length：' + lastRecordItemList.length);
                } else {
                    console.log('HisenseFlag__c ——> lastItem：' + JSON.stringify(lastItem));
                    if (typeof lastItem.isUpdatedFile != "undefined" && lastItem.isUpdatedFile) {
                        lastReocrdIsEmpty = false;
                    } else if (typeof lastItem.isUpdated == "undefined") {
                        lastReocrdIsEmpty = false;
                    } else if (this.isFilledOut(lastItem.Shelf__c)) {
                        lastReocrdIsEmpty = false;
                    } else if (this.isFilledOut(lastItem.Comment__c)) {
                        lastReocrdIsEmpty = false;
                    } else if (this.isFilledOut(lastItem.ProductLine__c)) {
                        lastReocrdIsEmpty = false;
                    }

                    if (lastReocrdIsEmpty) {
                        // lastRecordItemList.splice(lastRecordItemList.length - 1, 1);
                        this.recordList.splice(this.recordList.length -1, 1);
                    }
                    console.log('this.recordList.length：' + this.recordList.length);
                }
            }
        }
        return lastReocrdIsEmpty;

    }

    saveCheck() {

        console.log('Shelf Share saveCheck ----：');
        if (this.recordList.length > 0) {
            let lastRecord = this.recordList[this.recordList.length - 1];
            let lastReocrdIsEmpty = this.deleteLastOne();
            if (lastReocrdIsEmpty && lastRecord.brandItemList.length > 0) {
                if (lastRecord.brandItemList[lastRecord.brandItemList.length - 1].HisenseFlag__c) {
                    lastReocrdIsEmpty = this.deleteLastOne();
                }
            }
        }
        console.log('Shelf Share addCheck ----：');
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
            let item = this.recordList[index];
            if (!this.isFilledOut(item.ProductLine__c)) {
                result.flag = false;
                missFields.add(this.fields.ProductLine__c);
            }
            let brandLen = item.brandItemList.length;
            for (let i = 0; i < brandLen; i++) {
                let branItem = item.brandItemList[i];
                if (branItem.HisenseFlag__c) {
                    if (!this.isFilledOut(branItem.Shelf__c)) {
                        result.flag = false;
                        missFields.add(this.fields.Shelf__c);
                    }
                } else {
                    if (!this.isFilledOut(branItem.Brands__c)) {
                        result.flag = false;
                        missFields.add(this.fields.Brands__c);
                    }
                    if (!this.isFilledOut(branItem.Shelf__c)) {
                        result.flag = false;
                        missFields.add(this.fields.Shelf__c);
                    }
                }
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
        console.log('handleSelectFiles ——> event.target.dataset.index：' + event.target.dataset.index);
        console.log('handleSelectFiles ——> event.detail.records：' + event.detail.records);
        this.recordList[event.target.dataset.index].isUpdated = true;
        this.recordList[event.target.dataset.index].isUpdatedFile = true;
    }
}