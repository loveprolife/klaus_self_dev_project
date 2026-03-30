import { LightningElement, track, api, wire } from 'lwc';
import { LightningNavigationElement, formatPrice } from 'c/lwcUtils';
import LightningConfirm from 'lightning/confirm';

import PromoterDailyReport_SHARE from '@salesforce/label/c.PromoterDailyReport_SHARE';
import PromoterDailyReport_ATTACHMENT from '@salesforce/label/c.PromoterDailyReport_ATTACHMENT';
import PromoterDailyReport_ACTIONS from '@salesforce/label/c.PromoterDailyReport_ACTIONS';
import PromoterDailyReport_RequiredCheck from '@salesforce/label/c.PromoterDailyReport_RequiredCheck';
import PromoterDailyReport_DeleteReminder from '@salesforce/label/c.PromoterDailyReport_DeleteReminder';
import PromoterDailyReport_DuplicateCheck from '@salesforce/label/c.PromoterDailyReport_DuplicateCheck';
import PromoterDailyReport_AddNewItemSuccess from '@salesforce/label/c.PromoterDailyReport_AddNewItemSuccess';

import PromoterDailyReport_PROMO_COURT from '@salesforce/label/c.PromoterDailyReport_PROMO_COURT';
import getInitData from '@salesforce/apex/PromoCourtController.getInitData';
import saveRecord from '@salesforce/apex/PromoCourtController.saveRecord';

export default class PromoCourtLwc extends LightningNavigationElement {

    @api lwcName = PromoterDailyReport_PROMO_COURT;

    @api type;
    @api recordId;
    @api viewMode;
    @api isShowSpinner;
    @track recordList = [];
    @track deleteRecordList = [];
    @track fileId = '';
    @track fileIndex = 0;
    @track hisense;
    @track hisenseId;

    @track fields;
    deletIndex;

    label = { PromoterDailyReport_SHARE, PromoterDailyReport_ATTACHMENT, PromoterDailyReport_ACTIONS, PromoterDailyReport_DeleteReminder };
    fieldList = ['Brands__c', 'PromoCourtBulk__c'];
    // accountOfHisense;

    get isEmpty() {
        return this.recordList.length == 0 ? true : false;
    }

    get hisensShare() {
        let total = 0;
        let hisense = 0;
        let percentage = 0;
        for (let index = 0; index < this.recordList.length; index++) {
            let number = Number(this.recordList[index].PromoCourtBulk__c);
            if (!Number.isNaN(number) && (number != 0)) {
                console.log('hisensShare -> number：' + number);
                total += number;
                if (this.recordList[index].HisenseFlag__c) {
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
            console.log('hisensShare -> hisense：' + hisense);
            console.log('hisensShare -> total：' + total);
            // percentage = formatPrice((hisense / total) * 100);
            percentage = parseInt((hisense / total) * 100);
            this.recordList[0].Share__c = percentage;
            percentage += '%';
        }
        return percentage;
    }

    connectedCallback() {
        if (this.recordId) {
            this.isShowSpinner = true;
            getInitData({
                recordId: this.recordId,
            }).then(data => {
                this.isShowSpinner = false;
                console.log('PromoCourtLwc ——> getInitData');
                // this.accountOfHisense = data.data.hisense;
                this.hisenseId = data.data.hisenseId;
                this.fields = data.data.fields;
                if (data.isSuccess && data.data.promoCourtList.length > 0) {
                    console.log('PromoCourtLwc ——> getInitData ——> start');
                    this.recordList = data.data.promoCourtList;
                    for (let index = 0; index < this.recordList.length; index++) {
                        this.recordList[index].index = index;
                        if (this.recordList[index].HisenseFlag__c) {
                            this.hisense = this.recordList[index];
                            this.fileId = this.recordList[index].Id;
                            console.log('getInitData ——> fileId：' + this.fileId);
                        }
                    }
                } else {
                    console.log('PromoCourtLwc ——> isEmpty');
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
        console.log('inputChangeHandler —> event.target.value：' + event.target.value);

        let canFillInFlag = true;
        if (targetName == 'Brands__c') {
            for (let i = 0; i < this.recordList.length; i++) {
                let flag = this.isFilledOut(this.recordList[i].Brands__c);
                if (flag && this.recordList[i].Brands__c == event.target.value) {
                    // this.showError('Cannot choose duplicate brands！');
                    this.showWarning(PromoterDailyReport_DuplicateCheck.format(this.fields.Brands__c));
                    this.recordList[index][targetName] = '';
                    canFillInFlag = false;
                    break;
                }
            }
        }
        if (targetName == 'Comment__c') {
            this.hisense.Comment__c = event.target.value;
            this.recordList[0].Comment__c = event.target.value;
            this.recordList[0].fieldsEdit = 'true';
            this.recordList[0].isUpdated = true;
            canFillInFlag = false;
        }
        if (targetName == 'PromoCourtBulk__c') {
            this.recordList[0].fieldsEdit = 'true';
            this.recordList[0].isUpdated = true;
        }
        if (canFillInFlag) {
            this.recordList[index][targetName] = event.target.value;
        }
        this.recordList[index].fieldsEdit = 'true';
        this.recordList[index].isUpdated = true;
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
        'lookup': 'CustomLookupProvider.BrandDoNotContainsHisense'
    }

    async itemRemoveHandler(event) {
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
        let index = this.recordList.length - 1;
        if (this.recordList[index].hasOwnProperty('Id')) {
            this.deleteRecordList.push(this.recordList[index].Id);
        }
        this.recordList.pop();
    }

    brandItemAdd(event) {
        console.log('brandItemAdd');
        let result = this.addCheck();
        console.log('promoCourt ——> brandItemAdd ——> result.flag：' + result.flag);
        if (result.flag) {
            let index = this.recordList.length;
            this.recordList.push({
                index: index,
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
        console.log('promoCourt ——> itemAddHandler ——> result.flag：' + result.flag);
        if (result.flag) {
            var len = this.recordList.length;
            console.log("itemAddHandler —> len：" + len);
            if (len == 0) {
                this.recordList.push({
                    // Brand__c: this.accountOfHisense,
                    Brands__c: this.hisenseId,
                    HisenseFlag__c: true,
                    index: len,
                    isUpdated: false
                })
                len += 1;
                this.hisense = this.recordList[0];
            }
            console.log("itemAddHandler —> len：" + len);
            this.recordList.push({
                HisenseFlag__c: false,
                index: len,
                isUpdated: false
            })
            this.showSuccess(PromoterDailyReport_AddNewItemSuccess);
        } else {
            this.showWarning(result.message);
        }
    }

    @api
    saveData() {
        this.isShowSpinner = true;
        let result = this.saveCheck();
        if (result.flag) {
            console.log('saveData：' + JSON.stringify(this.recordList));
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
                        if (item.HisenseFlag__c) {
                            this.fileId = item.Id;
                            console.log('saveRecord ——> fileId：' + this.fileId);
                        }
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
        console.log('Promo Court deleteLastOne ----：');
        let lastReocrdIsEmpty = true;
        if (this.recordList.length > 0) {
            // 校验最后一条记录是否为空
            let lastItem = this.recordList[this.recordList.length - 1];
            if (!lastItem.HisenseFlag__c) {
                console.log('lastItem：' + JSON.stringify(lastItem));
                if (typeof lastItem.isUpdatedFile != "undefined" && lastItem.isUpdatedFile) {
                    lastReocrdIsEmpty = false;
                } else if (typeof lastItem.isUpdated == "undefined") {
                    lastReocrdIsEmpty = false;
                } else if (this.isFilledOut(lastItem.PromoCourtBulk__c)) {
                    lastReocrdIsEmpty = false;
                } else if (this.isFilledOut(lastItem.Brands__c)) {
                    lastReocrdIsEmpty = false;
                }

                if (lastReocrdIsEmpty) {
                    this.recordList.splice(this.recordList.length - 1, 1);
                }
                console.log('this.recordList.length：' + this.recordList.length);
            } else {
                console.log('HisenseFlag__c ——> lastItem：' + JSON.stringify(lastItem));
                if (typeof lastItem.isUpdatedFile != "undefined" && lastItem.isUpdatedFile) {
                    lastReocrdIsEmpty = false;
                } else if (typeof lastItem.isUpdated == "undefined") {
                    lastReocrdIsEmpty = false;
                } else if (this.isFilledOut(lastItem.PromoCourtBulk__c)) {
                    lastReocrdIsEmpty = false;
                } else if (this.isFilledOut(lastItem.Comment__c)) {
                    lastReocrdIsEmpty = false;
                }

                if (lastReocrdIsEmpty) {
                    this.recordList.splice(this.recordList.length - 1, 1);
                }
                console.log('this.recordList.length：' + this.recordList.length);
            }
        }
        return lastReocrdIsEmpty;
    }

    saveCheck() {
        
        console.log('Promo Court saveCheck ----：');
        if (this.recordList.length > 0) {
            let lastReocrdIsEmpty = this.deleteLastOne();
            if (lastReocrdIsEmpty && this.recordList.length > 0) {
                if (this.recordList[this.recordList.length - 1].HisenseFlag__c) {
                    lastReocrdIsEmpty = this.deleteLastOne();
                }
            }
        }
        console.log('Promo Court addCheck ----：');
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
            if (item.HisenseFlag__c) {
                if (!this.isFilledOut(item.PromoCourtBulk__c)) {
                    result.flag = false;
                    missFields.add(this.fields.PromoCourtBulk__c);
                }
            } else {
                console.log('promoCourt ——> saveCheck ——> not Hisense!');

                if (!this.isFilledOut(item.Brands__c)) {
                    result.flag = false;
                    missFields.add(this.fields.Brands__c);
                }
                if (!this.isFilledOut(item.PromoCourtBulk__c)) {
                    result.flag = false;
                    missFields.add(this.fields.PromoCourtBulk__c);
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

    handleKeyDown(event) {
        if (event.keyCode === 13) {
            event.preventDefault();
        }
    }

}