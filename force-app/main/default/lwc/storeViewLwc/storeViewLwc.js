import { LightningElement, track, api, wire } from 'lwc';
import { LightningNavigationElement } from 'c/lwcUtils';
import LightningConfirm from 'lightning/confirm';

import PromoterDailyReport_STORE_VIEW from '@salesforce/label/c.PromoterDailyReport_STORE_VIEW';
import PromoterDailyReport_ATTACHMENT from '@salesforce/label/c.PromoterDailyReport_ATTACHMENT';
import PromoterDailyReport_ACTIONS from '@salesforce/label/c.PromoterDailyReport_ACTIONS';
import PromoterDailyReport_RequiredCheck from '@salesforce/label/c.PromoterDailyReport_RequiredCheck';
import PromoterDailyReport_DeleteReminder from '@salesforce/label/c.PromoterDailyReport_DeleteReminder';
import PromoterDailyReport_AddItemCheck from '@salesforce/label/c.PromoterDailyReport_AddItemCheck';
import PromoterDailyReport_AddNewItemSuccess from '@salesforce/label/c.PromoterDailyReport_AddNewItemSuccess';
import Weekly_Report_Store_Picture_Number_Check from '@salesforce/label/c.Weekly_Report_Store_Picture_Number_Check';

import getInitData from '@salesforce/apex/StoreViewController.getInitData';
import saveRecord from '@salesforce/apex/StoreViewController.saveRecord';



export default class StoreViewLwc extends LightningNavigationElement {

    @api lwcName = PromoterDailyReport_STORE_VIEW;

    @api type;
    @api recordId;
    @api viewMode;
    @api isShowSpinner;

    @track storeId;
    @track reportDate;
    @track recordList = [];
    @track deleteRecordList = [];
    @track storeOptions = [];
    @track fields = {};
    
    storeIdAndNameMap;
    deletIndex;

    label = { PromoterDailyReport_STORE_VIEW, PromoterDailyReport_ATTACHMENT, PromoterDailyReport_ACTIONS, PromoterDailyReport_DeleteReminder };
    fieldList = ['Comments__c'];

    connectedCallback() {
        if (this.recordId) {
            this.isShowSpinner = true;
            getInitData({
                recordId: this.recordId,
            }).then(data => {
                console.log('storeView ——> getInitData ——> start：');
                for (let key in data.data) {
                    this[key] = data.data[key];
                }
                console.log('storeId : ' + this.storeId);
                if (data.isSuccess && data.data.storeViewList.length > 0) {
                    this.recordList = data.data.storeViewList;
                    for (let index = 0; index < this.recordList.length; index++) {
                        this.recordList[index].index = index;
                        this.recordList[index].store = this.storeIdAndNameMap[this.recordList[index].Store__c];
                        console.log(this.recordList[index].store);
                    }
                } else {
                    console.log('storeView ——> getInitData ——> isEmpty！');
                }
                this.isShowSpinner = false;
            }).catch(error => {
                this.catchError(error);
                this.isShowSpinner = false;
            });
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
            console.log('itemRemoveHandler —> need delete');
        }
        if (this.recordList.length == 1) {
            this.recordList = [];
            this.isEmpty = true;
        } else {
            console.log('itemRemoveHandler —> delete');
            this.recordList.splice(index, 1);
        }

    }

    inputChangeHandler(event) {
        let index = event.target.dataset.index;
        let targetName = event.target.dataset.fieldName;
        console.log('inputChangeHandler —> index：' + index);
        console.log('inputChangeHandler —> targetName：' + targetName);
        console.log('inputChangeHandler —> value：' + event.target.value);

        this.recordList[index][targetName] = event.target.value;
        this.recordList[index].fieldsEdit = 'true';
        this.recordList[index].isUpdated = true;

        console.log('inputChangeHandler ——> end');
    }

    @api
    itemAddHandler() {
        this.addStoreViewItem();
    }

    @api
    addStoreViewItem(event) {
        console.log("addStoreViewItem");
        var len = this.recordList.length;
        console.log("len：" + len);
        let result = this.addCheck();
        console.log("addStoreViewItem ——> addCheck：" + result.flag);
        if (result.flag) {
            this.recordList.push({
                index: len,
                reportDate: this.reportDate,
                Store__c: this.storeId,
                store : this.storeIdAndNameMap[this.storeId],
                commentsEdit: 'false',
                isUpdated: false
            })
            this.showSuccess(PromoterDailyReport_AddNewItemSuccess);
        } else {
            this.showWarning(result.message);
        }
        console.log("addStoreViewItem ——> recordList：" + JSON.stringify(this.recordList));
    }

    @api
    saveData() {
        this.isShowSpinner = true;
        // let result = this.saveCheck();
        // console.log('result.flag：' + result.flag);
        // console.log('this.deleteRecordList：' + this.deleteRecordList);
        // if (result.flag) {
        saveRecord({
            recordDataJson: JSON.stringify(this.recordList),
            deleteRecordIdList: this.deleteRecordList,
            recordId: this.recordId,
            fileMapJson: JSON.stringify(this.fileMap)
        }).then(data => {
            this.isShowSpinner = false;
            if (data.isSuccess) {
                for (let key in data.data) {
                    this[key] = data.data[key];
                }
                this.recordList.forEach((item, i) => {
                    console.log('saveRecord ——> item.Id ：' + item.Id);
                    item.index = i;
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
        // } else {
        //     this.showWarning(result.message);
        //     this.isShowSpinner = false;
        // }

    }

    fileMap = {};
    handleSelectFiles(event) {
        this.fileMap[event.target.dataset.index] = event.detail.records;
        this.recordList[event.target.dataset.index].isUpdated = true;
        this.recordList[event.target.dataset.index].isUpdatedFile = true;
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
        } else {
            console.log('addCheck ——> ');
            let elements = this.template.querySelectorAll('c-upload-files-lwc');
            for (let fileIndex = 0; fileIndex < elements.length; fileIndex++) {
                console.log('addCheck ——> file：' + elements[fileIndex].files());

                let storePictures = 0;
                let picturesEle = this.template.querySelector('c-upload-store-pictures-view-l-w-c');
                if(picturesEle != null) {
                    storePictures = picturesEle.getImagesCount();
                }

                if (elements[fileIndex].files().length == 0) {
                    result.flag = false;
                    missFields.add(PromoterDailyReport_ATTACHMENT);
                } else if (storePictures > elements[fileIndex].files().length) {
                    result.flag = false;
                    missFields.add(Weekly_Report_Store_Picture_Number_Check);
                }
            }

            for (let index = 0; index < this.recordList.length; index++) {
                if (!this.isFilledOut(this.recordList[index].Store__c)) {
                    result.flag = false;
                    missFields.add(this.files.Store__c);
                }

            }
        }
        console.log('missFields：' + JSON.stringify(missFields));
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

    getStoreName(storeId) {
        let storeName = null;
        for (let [key, value] of Object.entries(this.storeOptions[0])) {
            console.log(typeof key);
            console.log(key, value);
            if (storeId == value.value) {
                storeName = key.label;
            }
        }
        return storeName;
    }

    @api
    getlength() {
        return this.recordList.length;
    }
}