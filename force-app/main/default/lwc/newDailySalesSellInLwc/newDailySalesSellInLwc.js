import { track, api, wire } from 'lwc';
import { LightningNavigationElement } from 'c/lwcUtils'

import PromoterDailyReport_AddNewItemSuccess from '@salesforce/label/c.PromoterDailyReport_AddNewItemSuccess';
import INSPECTION_REPORT_ATTACHMENT from '@salesforce/label/c.INSPECTION_REPORT_ATTACHMENT';
import PromoterDailyReport_DAILY_SALES from '@salesforce/label/c.PromoterDailyReport_DAILY_SALES';
import PromoterDailyReport_NO from '@salesforce/label/c.PromoterDailyReport_NO';
import PromoterDailyReport_UNIT_PRICE from '@salesforce/label/c.PromoterDailyReport_UNIT_PRICE';
import PromoterDailyReport_QUANTITY from '@salesforce/label/c.PromoterDailyReport_QUANTITY';

import getInitData from '@salesforce/apex/NewDailySalesSellInController.getInitData';
import saveData from '@salesforce/apex/NewDailySalesSellInController.saveData';

export default class newDailySalesSellInLwc extends LightningNavigationElement {

    label = {INSPECTION_REPORT_ATTACHMENT, PromoterDailyReport_DAILY_SALES, PromoterDailyReport_NO, PromoterDailyReport_UNIT_PRICE, PromoterDailyReport_QUANTITY};

    @api lwcName = this.label.PromoterDailyReport_DAILY_SALES;

    isShowSpinner;

    @api recordId;
    @api hideAction;
    @api viewMode;
    @track recordList = [];

    deleteIds = [];
    fileMap = {};
    deletIndex;

    
    fieldList = ['Number__c', 'Price__c', 'Product__c', 'TotalPrice__c'];

    // 添加产品（自定义lookupFilter）
    lookupFilter = {
        'lookup' : 'CustomLookupProvider.ProductAllFilter'
    }

    connectedCallback() {
        this.isShowSpinner = true;
        getInitData({
            recordId: this.recordId
        }).then(resp => {
            if (resp.isSuccess) {
                for (let key in resp.data) {
                    this[key] = resp.data[key];
                }
                this.recordList.forEach((item, i) => {
                    item.index = i;
                });
                this.isShowSpinner = false;
            } else {
                this.showError(resp.message);
            }
        }).catch(error => {
            this.catchError(error);
            this.isShowSpinner = false;
        })
    }

    handleChangeProductOption(event) {
        let index = event.target.dataset.index;
        let fieldName = event.target.dataset.fieldName;
        let selectRecord = event.detail.selectedRecord;
        
        if (selectRecord) {
            let product = selectRecord.Id;
            this.recordList[index][fieldName] = product;
        } 
    }

    handleFieldChange(event) {
        let fieldName = event.target.dataset.fieldName;
        let index = event.target.dataset.index;
        this.recordList[index][fieldName] = event.target.value;
        

        var totalPrice = this.recordList[index].TotalPrice__c;
        var quantity = this.recordList[index].Number__c;

        if(fieldName == 'TotalPrice__c'){
            if(totalPrice == null || totalPrice=='' || quantity == null || quantity == ''){
                this.recordList[index].Price__c = '-';
            }else {
                this.recordList[index].Price__c = this.recordList[index].TotalPrice__c / this.recordList[index].Number__c;
            }
        }else if(fieldName == 'Number__c'){
            if(totalPrice == null || totalPrice=='' || quantity == null || quantity == ''){
                this.recordList[index].Price__c = '-';
            }else {
                this.recordList[index].Price__c = this.recordList[index].TotalPrice__c / this.recordList[index].Number__c;
            }
        }
    }

    handleKeyDown(event) {
        if (event.keyCode === 13) {
            event.preventDefault();
        }
    }

    @api
    addDssi(event) {
        var len = this.recordList.length;
        let result = this.addCheck();
        if (result.alltrue) {
            this.recordList.push({
                Daily_Inspection_Report__c: this.recordId,
                index: len
            })
            this.showSuccess(PromoterDailyReport_AddNewItemSuccess);
        } else {
            this.showWarning(result.msg);
        }

    }

    async deleteCompetitorsInformation(event) {
        this.deletIndex = event.target.dataset.index;
        let modalEle = this.template.querySelector('c-modal-lwc');
        modalEle.showModal();
    }

    handleOk() {
        this.template.querySelector('c-modal-lwc').closeModal();
        let index = this.deletIndex;
        if (this.recordList[index].hasOwnProperty('Id')) {
            this.deleteIds.push(this.recordList[index].Id);
        }
        this.recordList.splice(index, 1);
    }

    @api
    saveData(event) {
        this.isShowSpinner = true;
        let result = this.saveCheck();
        if (result.alltrue) {
            //let items = this.recordList.filter(item => item.isUpdated);
            saveData({
                recordListJson: JSON.stringify(this.recordList),
                recordId: this.recordId,
                fileMapJson: JSON.stringify(this.fileMap),
                deleteIds: this.deleteIds
            }).then(resp => {
                this.isShowSpinner = false;
                if (resp.isSuccess) {
                    for (let key in resp.data) {
                        this[key] = resp.data[key];
                    }
                    this.recordList.forEach((item, i) => {
                        item.index = i;
                    })
                    let eles = this.template.querySelectorAll('c-upload-files-lwc');
                    for (let index = 0; eles && index < eles.length; index++) {
                        let ele = eles[index];
                        ele.refresh();
                    }
                    // this.showSuccess(resp.message ? resp.message :'success');
                } else {
                    // this.showError(resp.message);
                }
                this.dispatchEvent(new CustomEvent('savedata', {
                    detail: {
                        result: resp
                    }
                }));
            }).catch(error => {
                this.catchError(error);
                this.isShowSpinner = false;
            })
        } else {
            this.showWarning(result.msg);
            this.isShowSpinner = false;
        }
    }

    handleUploadFinished(event) {
        // Get the list of uploaded files
        const uploadedFiles = event.detail.files;
        alert('No. of files uploaded : ' + uploadedFiles.length);
    }

    handleSelectFiles(event) {
        this.fileMap[event.target.dataset.index] = event.detail.records;
    }

    openUpload(event) {
        this.template.querySelector('c-upload-files-lwc').openUpload();
    }

    @api
    checkData() {
        return this.saveCheck();
    }

    saveCheck() {
        if (this.recordList.length > 0) {
            // 校验最后一条记录是否为空
            let lastItem = this.recordList[this.recordList.length - 1];
            let lastReocrdIsNotEmpty = true;
            for (let key in lastItem) {
                if (this.fieldList.includes(key) && this.isFilledOut(lastItem[key])) {
                    console.log('Key：' + key);
                    lastReocrdIsNotEmpty = false;
                    break;
                }
            }
            if (lastReocrdIsNotEmpty) {
                this.recordList.splice(this.recordList.length - 1, 1);
            }
            console.log('this.recordList.length：' + this.recordList.length);
        }

        return this.addCheck();
    }

    addCheck() {
        let result = {
            alltrue: true,
            msg: '',
        }
        const missFields = new Set();
        if (this.recordList.length == 0) {
            return result;
        } else {
            for (let index = 0; index < this.recordList.length; index++) {
                if (!this.isFilledOut(this.recordList[index].Product__c)) {
                    result.alltrue = false;
                    missFields.add(this.fields.Product__c);
                }

                if (!this.isFilledOut(this.recordList[index].TotalPrice__c)) {
                    result.alltrue = false;
                    missFields.add(this.fields.TotalPrice__c);
                }

                if (!this.isFilledOut(this.recordList[index].Number__c)) {
                    result.alltrue = false;
                    missFields.add(PromoterDailyReport_QUANTITY);
                }
                // if (this.recordList[index].Display_Status__c == true && this.recordList[index].isUpdatedFile != true) {
                //     result.alltrue = false;
                //     missFields.add(this.label.INSPECTION_REPORT_ATTACHMENT);
                // }
            }
        }
        let missFieldsList = Array.from(missFields.keys());
        if (missFieldsList.length > 0) {
            result.msg += '[' + this.lwcName + ' — ';
            for (let index = 0; index < missFieldsList.length; index++) {
                if (index == missFieldsList.length - 1) {
                    result.msg += missFieldsList[index] + ']';
                } else {
                    result.msg += missFieldsList[index] + '/';
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

}