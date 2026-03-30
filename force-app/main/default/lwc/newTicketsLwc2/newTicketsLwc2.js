import { track, api, wire } from 'lwc';
import { LightningNavigationElement } from 'c/lwcUtils'

import LightningConfirm from 'lightning/confirm';

import PromoterDailyReport_RequiredCheck from '@salesforce/label/c.PromoterDailyReport_RequiredCheck';
import PromoterDailyReport_AddNewItemSuccess from '@salesforce/label/c.PromoterDailyReport_AddNewItemSuccess';
import PromoterDailyReport_DeleteReminder from '@salesforce/label/c.PromoterDailyReport_DeleteReminder';
import Ticket_Error_Assigned from '@salesforce/label/c.Ticket_Error_Assigned';
import Ticket_Fields_Check from '@salesforce/label/c.Ticket_Fields_Check';
import PromoterDailyReport_TICKET from '@salesforce/label/c.PromoterDailyReport_TICKET';
import INSPECTION_REPORT_MSG_DEPARTMENT_USER from '@salesforce/label/c.INSPECTION_REPORT_MSG_DEPARTMENT_USER';

import getInitData from '@salesforce/apex/NewTicketsController2.getInitData';
import saveData from '@salesforce/apex/NewTicketsController2.saveData';
import handlerRemove from '@salesforce/apex/NewTicketsController2.handlerRemove';

export default class NewTicketsLwc extends LightningNavigationElement {

    @api lwcName = PromoterDailyReport_TICKET;

    isShowSpinner;
    @api hideAction;
    @api viewMode;
    @track recordList = [];
    @track isShowDepartment = false;
    @track isSouthAfrica = false;

    deleteIds = [];
    fileMap = {};
    userId;
    deletIndex;

    // AfterSalesService = [];
    // Agency = [];
    // Marketing = [];
    // Sales = [];

    label = { PromoterDailyReport_DeleteReminder, INSPECTION_REPORT_MSG_DEPARTMENT_USER };
    fieldList = ['Subject__c', 'Description__c', 'DueDate__c', 'Department__c', 'AssignedTo__c'];

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
                    if(!this.isFilledOut(item.Category__c) || item.Category__c == 'Service'){
                        item.isShowProduct = false;
                    }else{
                        item.isShowProduct = true; 
                    }
                })
                this.isShowDepartment = (resp.data.userRegion == 'Hisense Chile') || (resp.data.userRegion == 'Hisense South Africa');
                this.isSouthAfrica = resp.data.userRegion == 'Hisense South Africa';
                console.log('isShowDepartment：' + this.isShowDepartment);
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
        console.log(1111111);
        this.recordList[event.target.dataset.index][event.target.dataset.fieldName] = event.target.value;
        this.recordList[event.target.dataset.index].isUpdated = true;

        if (event.target.dataset.fieldName == 'Department__c') {
            this.updateLookup('userLookup', event.target.dataset.index);
            this.removeLookup('userLookup', event.target.dataset.index);
        }

        if(event.target.dataset.fieldName == 'Category__c') {
            if(!this.isFilledOut(event.target.value) || event.target.value == 'Service'){
                this.recordList[event.target.dataset.index].isShowProduct = false;
                this.recordList[event.target.dataset.index].Product__c = '';
            }else{
                this.recordList[event.target.dataset.index].isShowProduct = true; 
            }
        }
    }

    lookUpChangeHandler(event) {
        let index = event.target.dataset.index;
        let targetName = event.target.dataset.fieldName;
        console.log('lookUpChangeHandler ——> index: ' + index);
        console.log('lookUpChangeHandler ——> targetName: ' + targetName);

        if (event.detail.selectedRecord == undefined) {
            this.recordList[index][targetName] = null;
        } else {
            this.recordList[index][targetName] = event.detail.selectedRecord.Id;
        }
        this.recordList[index].isUpdated = true;
    }

    updateLookup(name,index) {
        var cmps = this.template.querySelectorAll('c-lookup-lwc');
        for (let i = 0; i < cmps.length; i++) {
            var lookup = cmps[i];
            if (lookup.name==name && lookup.getAttribute('data-index')==index) {
                lookup.updateOption({
                    'lookup': 'CustomLookupProvider.DepartmentUserFilter',
                    'department': this.recordList[index].Department__c
                });
                return;
            }
        }
    }

    removeLookup(name, index) {
        var cmps = this.template.querySelectorAll('c-lookup-lwc');
        for (let i = 0; i < cmps.length; i++) {
            var lookup = cmps[i];
            if (lookup.name==name && lookup.getAttribute('data-index')==index) {
                lookup.handleRemove();
                return;
            }
        }
    }

    lookupUserFilter = {
        'lookup': 'CustomLookupProvider.UserFilter'
    }


    handleKeyDown(event) {
        if (event.keyCode === 13) {
            event.preventDefault();
        }
    }

    @api
    addTicket(event) {
        var len = this.recordList.length;
        let result = this.addCheck();
        if (result.flag) {
            this.recordList.push({
                OwnerId: this.userId,
                PromoterDailyReport__c: this.recordId,
                index: len,
                isUpdated: false
            })
            this.showSuccess(PromoterDailyReport_AddNewItemSuccess);
        } else {
            this.showWarning(result.message);
        }

    }

    async deleteTicket(event) {
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

        if (result.flag) {
            let items = this.recordList.filter(item => item.isUpdated);
            console.log('ticket Itme =======>' + JSON.stringify(items));
            console.log('JSON.stringify(this.fileMap)' + JSON.stringify(this.fileMap));
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
            this.showWarning(result.message);
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
            for (let index = 0; index < this.recordList.length; index++) {
                if (!this.isFilledOut(this.recordList[index].Subject__c)) {
                    result.flag = false;
                    missFields.add(this.fields.Subject__c);
                }
                if (!this.isFilledOut(this.recordList[index].Description__c)) {
                    result.flag = false;
                    missFields.add(this.fields.Description__c);
                }
                if(this.isFilledOut(this.recordList[index].Category__c) && this.recordList[index].Category__c != 'Service'){
                    if (!this.isFilledOut(this.recordList[index].Product__c)) {
                        result.flag = false;
                        missFields.add(this.fields.Product__c);
                    }
                }
                if (!this.isFilledOut(this.recordList[index].DueDate__c)) {
                    result.flag = false;
                    missFields.add(this.fields.DueDate__c);
                }
                if ((!this.isShowDepartment) && !this.isFilledOut(this.recordList[index].AssignedTo__c)) {
                    result.flag = false;
                    missFields.add(this.fields.AssignedTo__c);
                }
                if ((this.isShowDepartment) && (!this.isFilledOut(this.recordList[index].AssignedTo__c) && !this.isFilledOut(this.recordList[index].Department__c))) {
                    result.flag = false;
                    // result.message = Ticket_Fields_Check.format(this.fields.AssignedTo__c, this.fields.Department__c);
                    // return result;
                    missFields.add(Ticket_Fields_Check.format(this.fields.AssignedTo__c, this.fields.Department__c));
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



    // userAndDepartmentCheck() {
    //     let result = {
    //         flag: true,
    //         message: '',
    //     }
    //     if (this.recordList.length == 0) {
    //         return result;
    //     } else {
    //         for (let index = 0; index < this.recordList.length; index++) {
    //             if (!this.isFilledOut(this.recordList[index].Subject__c)) {
    //             }
    //             if (this.isFilledOut(this.recordList[index].Department__c) && this.isFilledOut(this.recordList[index].AssignedTo__c)) {
    //                 let userMatch = false;
    //                 console.log('Department User List: ' + this[this.recordList[index].Department__c]);
    //                 for (let index = 0; index < this[this.recordList[index].Department__c].length; index++ ) {
    //                     console.log('this[this.recordList[index].Department__c][index]: ' + this[this.recordList[index].Department__c][index]);
    //                     if (this[this.recordList[index].Department__c][index] == this.recordList[index].AssignedTo__c) {
    //                         userMatch = true;
    //                     }
    //                 }
    //                 if (!userMatch) {
    //                     result.flag = false;
    //                     result.message = Ticket_Error_Assigned;
    //                     return result;
    //                 }
    //             }
    //         }
    //     }
    //     return result;
    // }

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

    // 添加产品（自定义lookupFilter）
    lookupFilter = {
        'lookup' : 'CustomLookupProvider.ProductAllFilter'
    }

    deleteProductValue(event){
        let index = event.target.dataset.index;
        console.log('deleteProductValue ——> index: ' + index);

        if(this.isFilledOut(this.recordList[index].Product__c)){
            if(this.recordList[index].Product__c.lastIndexOf(',') != -1){
                this.recordList[index].Product__c = this.recordList[index].Product__c.substr(0, this.recordList[index].Product__c.lastIndexOf(','));
            }else{
                this.recordList[index].Product__c = '';
            }
        }
    }

    // 选择产品变更
    handleChangeProductOption(event) {

        let index = event.target.dataset.index;
        console.log('handleChangeProductOption ——> index: ' + index);

        if (event.detail.selectedRecord==undefined) {
            return;
        } 

        handlerRemove({
            
        }).then(data => {
            if (data.isSuccess) {
                this.removeLookup('onProduct',index);
            } else {
            }
        }).catch(error => {
            this.catchError(error);
        });

        
        if(this.recordList[index].Product__c && this.recordList[index].Product__c != ''){
            if(this.recordList[index].Product__c.indexOf(event.detail.selectedRecord.Name) == -1){
                this.recordList[index].Product__c = this.recordList[index].Product__c + ',' + event.detail.selectedRecord.Name;
            }
        }else{
            this.recordList[index].Product__c = event.detail.selectedRecord.Name;
        }
    }
}