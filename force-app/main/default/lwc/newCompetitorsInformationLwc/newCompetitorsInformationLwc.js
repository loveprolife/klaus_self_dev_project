import { track, api, wire } from 'lwc';
import { LightningNavigationElement } from 'c/lwcUtils'

import PromoterDailyReport_AddNewItemSuccess from '@salesforce/label/c.PromoterDailyReport_AddNewItemSuccess';
import PromoterDailyReport_DeleteReminder from '@salesforce/label/c.PromoterDailyReport_DeleteReminder';
import INSPECTION_REPORT_Competitors_Information from '@salesforce/label/c.INSPECTION_REPORT_Competitors_Information';
import INSPECTION_REPORT_ATTACHMENT from '@salesforce/label/c.INSPECTION_REPORT_ATTACHMENT';

import getInitData from '@salesforce/apex/NewCompetitorsInformationController.getInitData';
import saveData from '@salesforce/apex/NewCompetitorsInformationController.saveData';

export default class newCompetitorsInformationLwc extends LightningNavigationElement {

    label = { PromoterDailyReport_DeleteReminder, INSPECTION_REPORT_Competitors_Information, INSPECTION_REPORT_ATTACHMENT};

    @api lwcName = this.label.INSPECTION_REPORT_Competitors_Information;

    isShowSpinner;
    @api hideAction;
    @api viewMode;
    @track recordList = [];

    deleteIds = [];
    fileMap = {};
    deletIndex;

    
    fieldList = ['Product_line__c', 'Demo_Video__c', 'Brand__c', 'Display_Status__c', 'Quantity_Of_Exhibits__c', 'Display_Stand__c', 'POP__c'];

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
                    item.isUpdated = false;
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

    handleFieldChange(event) {
        var fieldName = event.target.dataset.fieldName;
        if (fieldName == 'Display_Status__c' || fieldName == 'Display_Stand__c' || fieldName == 'POP__c' || fieldName == 'Demo_Video__c') {
            this.recordList[event.target.dataset.index][fieldName] = event.target.checked;
            if(fieldName == 'Display_Status__c'){
                if(!event.target.checked){
                    this.recordList[event.target.dataset.index]['Quantity_Of_Exhibits__c'] = null;
                }
            }
        }else{
            this.recordList[event.target.dataset.index][fieldName] = event.target.value;
        }
        this.recordList[event.target.dataset.index].isUpdated = true;
    }

    handleKeyDown(event) {
        if (event.keyCode === 13) {
            event.preventDefault();
        }
    }

    @api
    addCompetitorsInformation(event) {
        var len = this.recordList.length;
        let result = this.addCheck();
        if (result.alltrue) {
            this.recordList.push({
                Daily_Inspection_Report__c: this.recordId,
                index: len,
                isUpdated: false
            })
            this.showSuccess(PromoterDailyReport_AddNewItemSuccess);
        } else {
            this.showWarning(result.msg);
        }

    }

    async deleteCompetitorsInformation(event) {
        this.deletIndex = event.target.dataset.index;
        console.log('deletIndex：' + this.deletIndex);
        let modalEle = this.template.querySelector('c-modal-lwc');
        modalEle.showModal();
    }

    handleOk() {
        this.template.querySelector('c-modal-lwc').closeModal();
        let index = this.deletIndex;
        if (this.recordList[index].hasOwnProperty('Id')) {
            this.deleteIds.push(this.recordList[index].Id);
            console.log('itemRemoveHandler —> need delete');
        }
        this.recordList.splice(index, 1);
    }

    @api
    saveData(event) {
        this.isShowSpinner = true;
        let result = this.saveCheck();

        if (result.alltrue) {
            let items = this.recordList.filter(item => item.isUpdated);
            saveData({
                recordListJson: JSON.stringify(items),
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
        console.log('handleSelectFiles =======> index : ' + event.target.dataset.index);
        this.fileMap[event.target.dataset.index] = event.detail.records;
        this.recordList[event.target.dataset.index].isUpdated = true;
        this.recordList[event.target.dataset.index].isUpdatedFile = true;
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
                if (this.recordList[index].Display_Status__c == true && !this.isFilledOut(this.recordList[index].Quantity_Of_Exhibits__c)) {
                    result.alltrue = false;
                    missFields.add(this.fields.Quantity_Of_Exhibits__c);
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