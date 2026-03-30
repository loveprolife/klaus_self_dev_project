import { track, api, wire } from 'lwc';
import { LightningNavigationElement } from 'c/lwcUtils';
import { CloseActionScreenEvent } from 'lightning/actions';

import New_Application from '@salesforce/label/c.New_Application';
import Application_Edit from '@salesforce/label/c.Application_Edit';
import New_Application_Leave from '@salesforce/label/c.New_Application_Leave';
import New_Application_Additional_Check_In_Out from '@salesforce/label/c.New_Application_Additional_Check_In_Out';
import New_Application_Resignation from '@salesforce/label/c.New_Application_Resignation';
import Application_Of_Check_In_Out_Limits from '@salesforce/label/c.Application_Of_Check_In_Out_Limits';
import Application_Of_Check_In_Out_Limits2 from '@salesforce/label/c.Application_Of_Check_In_Out_Limits2';
import Application_Of_Check_In_Out_Limits3 from '@salesforce/label/c.Application_Of_Check_In_Out_Limits3';
import Application_Of_Time_Rule from '@salesforce/label/c.Application_Of_Time_Rule';
import Application_Locked from '@salesforce/label/c.Application_Locked';
import PromoterDailyReport_ATTACHMENT from '@salesforce/label/c.PromoterDailyReport_ATTACHMENT';
import Application_Leave_Locked from '@salesforce/label/c.Application_Leave_Locked';


import Select_a_record_type from '@salesforce/label/c.Select_a_record_type';
import New_Application_Transfer_Store from '@salesforce/label/c.New_Application_Transfer_Store';
import Cancel from '@salesforce/label/c.Cancel';
import Application_Save from '@salesforce/label/c.Application_Save';
import Application_Next from '@salesforce/label/c.Application_Next';

import getInitData from '@salesforce/apex/ApplicationButtonController.getInitData';
import saveData from '@salesforce/apex/ApplicationButtonController.saveData';

export default class ApplicationButtonLwc extends LightningNavigationElement {

    @api recordTypeName;
    @api recordTypeId;
    @track isShowSpinner = false;
    @track isShow = false;
    @track isShowRecordTypes = true;
    // @track checkInOut = false;
    // @track leave = false;
    // @track resignation = false;
    // @track transferStore = false;
    // @track isEdit = false;
    // @track headingString = '';
    @track isLocked = false;

    @track application = {
        Status__c: 'New',
        TransferStore__c: null,
        LastDay__c: null,
        Successor__c: null,
        Comments__c: null
    };

    defaultRecordTypeId = null;
    fileMap = {};
    label = { New_Application, Select_a_record_type, New_Application_Transfer_Store, Cancel, Application_Save, Application_Next, New_Application_Leave, New_Application_Additional_Check_In_Out, New_Application_Resignation, Application_Locked, PromoterDailyReport_ATTACHMENT, Application_Leave_Locked };

    get isEdit() {
        return this.recordId ? true : false;
    }
    get checkInOut() {
        if (this.recordTypeMap && !this.isShowRecordTypes) {
            return this.recordTypeMap['AdditionalCheckInOut'] == this.recordTypeId ? true : false;
        } else {
            return false
        }
    }
    get leave() {
        if (this.recordTypeMap && !this.isShowRecordTypes) {
            return this.recordTypeMap['Leave'] == this.recordTypeId ? true : false;
        } else {
            return false;
        }
    }
    get resignation() {
        if (this.recordTypeMap && !this.isShowRecordTypes) {
            return this.recordTypeMap['Resignation'] == this.recordTypeId ? true : false;
        } else {
            return false;
        }
    }
    get transferStore() {
        if (this.recordTypeMap && !this.isShowRecordTypes) {
            return this.recordTypeMap['TransferStore'] == this.recordTypeId ? true : false;
        } else {
            return false;
        }
    }
    get headingString() {
        if (this.recordId) {
            // Edit R-000148
            return Application_Edit + '  ' + this.application.Name;
        } else {
            if (this.checkInOut) {
                return New_Application_Additional_Check_In_Out;
            }
            if (this.leave) {
                return New_Application_Leave;
            }
            if (this.resignation) {
                return New_Application_Resignation;
            }
            if (this.transferStore) {
                return New_Application_Transfer_Store;
            }
        }
        return '';
    }

    connectedCallback() {
        this.isShowSpinner = true;
        getInitData({
            recordId: this.recordId,
        }).then(resp => {
            if (resp.isSuccess) {
                for (let key in resp.data) {
                    this[key] = resp.data[key];
                }
                if (!this.recordTypeId) {
                    this.defaultRecordTypeId = resp.data.defaultRecordTypeId;
                    this.recordTypeId = resp.data.defaultRecordTypeId;
                }
                console.log('typesOptions：' + this.typesOptions);

                if (this.recordId) {
                    this.application = resp.data.application;
                    this.recordTypeId = this.application.RecordTypeId;
                    this.isShowRecordTypes = false;
                    this.isLocked = resp.data.isLocked;
                }
            } else {
                this.showError(resp.message);
            }
            this.isShowSpinner = false;
        }).catch(error => {
            this.catchError(error);
            this.isShowSpinner = false;
        })

    }

    handleChange(event) {
        let selectedOption = event.detail.value;
        this.recordTypeId = selectedOption;
        console.log('Option selected with value: ' + selectedOption);
    }

    nextHandler(event) {
        this.isShowRecordTypes = false;

        // this.checkInOut = this.recordTypeMap['AdditionalCheckInOut'] == this.recordTypeId ? true : false;
        // this.leave = this.recordTypeMap['Leave'] == this.recordTypeId ? true : false;
        // this.resignation = this.recordTypeMap['Resignation'] == this.recordTypeId ? true : false;
        // this.transferStore = this.recordTypeMap['TransferStore'] == this.recordTypeId ? true : false;

        // console.log('checkInOut：' + this.checkInOut);
        // console.log('leave：' + this.leave);
        // console.log('resignation：' + this.resignation);
        // console.log('transferStore：' + this.transferStore);

    }

    handleFieldChange(event) {
        let fieldName = event.target.dataset.fieldName;
        this.application[fieldName] = event.target.value;
        if( fieldName == 'RefillCheckInTime__c' || fieldName == 'RefillCheckOutTime__c') {
            this.application[fieldName] += 'Z';
        }
    }

    lookUpChangeHandler(event) {
        let targetName = event.target.dataset.fieldName;
        console.log('lookUpChangeHandler ——> targetName：' + targetName);

        if (event.detail.selectedRecord == undefined) {
            this.application[event.target.dataset.fieldName] = null;
        } else {
            this.application[event.target.dataset.fieldName] = event.detail.selectedRecord.Id;
        }
    }

    lookupAccountFilter = {
        'lookup': 'CustomLookupProvider.StoreFilter'
    }

    handleKeyDown(event) {
        if (event.keyCode === 13) {
            event.preventDefault();
        }
    }

    saveRecord() {
        this.isShowSpinner = true;
        this.application.RecordTypeId = this.recordTypeId;
        let checkResult = this.saveCheck();
        if (checkResult.message == '') {
            let recordList = [];
            this.application.index = 0;
            recordList.push(this.application);
            console.log('recordList：' + JSON.stringify(recordList));
            console.log('fileMap：' + JSON.stringify(this.fileMap));

            saveData({
                recordListJson: JSON.stringify(recordList),
                fileMapJson: JSON.stringify(this.fileMap),
            }).then(resp => {
                if (resp.isSuccess) {
                    let applicationId = resp.data.applicationId;
                    console.log('applicationId：' + applicationId);

                    if(this.recordId) {
                        this.goToRecord(this.recordId);
                        this.showSuccess('Save Success');
                    } else {
                        this.goToRecord(applicationId);
                        this.showSuccess('Create Success');
                    }
                    this.dispatchEvent(new CloseActionScreenEvent());
                    this.dispatchEvent(new CustomEvent('closemodal'));
                } else {
                    this.showError(resp.message);
                }
                this.isShowSpinner = false;
            }).catch(error => {
                this.catchError(error);
                this.isShowSpinner = false;
            })
        } else {
            this.showWarning(checkResult.message);
            this.isShowSpinner = false;
        }

    }

    cancel(event) {
        // this.dispatchEvent(new CloseActionScreenEvent());
        // this.dispatchEvent(new CustomEvent('closemodal'));
        this.goToObject('Application__c');
        // window.location.reload();
    }

    cancelNew(evnet) {
        this.isShowRecordTypes = true;
        // this.checkInOut = false;
        // this.leave = false;
        // this.resignation = false;
        // this.transferStore = false;
        this.recordTypeId = this.defaultRecordTypeId;
    }

    cancelEdit(event) {
        this.goToRecord(this.recordId);
        this.dispatchEvent(new CloseActionScreenEvent());
        this.dispatchEvent(new CustomEvent('closemodal'));
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

    saveCheck() {
        let result = {
            flag: true,
            message: '',
        }
        if (this.checkInOut) {
            if ((this.isFilledOut(this.application.CheckInStoreName__c) && !this.isFilledOut(this.application.RefillCheckInTime__c)) || (!this.isFilledOut(this.application.CheckInStoreName__c) && this.isFilledOut(this.application.RefillCheckInTime__c))) {
                //check in shop and check in time must exist simultaneously
                result.message += Application_Of_Check_In_Out_Limits;
            }
            if ((this.isFilledOut(this.application.CheckOutStoreName__c) && !this.isFilledOut(this.application.RefillCheckOutTime__c)) || (!this.isFilledOut(this.application.CheckOutStoreName__c) && this.isFilledOut(this.application.RefillCheckOutTime__c))) {
                //check in shop and check in time must exist simultaneously
                result.message += Application_Of_Check_In_Out_Limits2;
            }
            if (!this.isFilledOut(this.application.CheckInStoreName__c) && !this.isFilledOut(this.application.RefillCheckInTime__c) && !this.isFilledOut(this.application.CheckOutStoreName__c) && !this.isFilledOut(this.application.RefillCheckOutTime__c)) {
                //Please input check in/out infomation
                result.message += Application_Of_Check_In_Out_Limits3;
            }
            if (this.isFilledOut(this.application.RefillCheckInTime__c) && this.isFilledOut(this.application.RefillCheckOutTime__c) && (this.application.RefillCheckInTime__c > this.application.RefillCheckOutTime__c)) {
                //The start time must be less than the end time 
                result.message += Application_Of_Time_Rule;
            }
        }
        //Leave recordtype only
        if (this.leave) {
            if (this.isFilledOut(this.application.From__c) && this.isFilledOut(this.application.To__c) && (this.application.From__c > this.application.To__c)) {
                //The start time must be less than the end time
                result.message += Application_Of_Time_Rule;
            }
        }
        console.log('check message：' + result.message);
        return result;
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
}