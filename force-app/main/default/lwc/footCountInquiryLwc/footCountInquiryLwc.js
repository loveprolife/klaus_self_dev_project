import { LightningElement, track, api, wire } from 'lwc';
import { LightningNavigationElement } from 'c/lwcUtils';
import LightningConfirm from 'lightning/confirm';

import question1 from '@salesforce/label/c.Foot_Count_Inquiry_Question1';
import question2 from '@salesforce/label/c.Foot_Count_Inquiry_Question2';
import question3 from '@salesforce/label/c.Foot_Count_Inquiry_Question3';
import question4 from '@salesforce/label/c.Foot_Count_Inquiry_Question4';
import question5 from '@salesforce/label/c.Foot_Count_Inquiry_Question5';
import question6 from '@salesforce/label/c.Foot_Count_Inquiry_Question6';

import PromoterDailyReport_AddNewItemSuccess from '@salesforce/label/c.PromoterDailyReport_AddNewItemSuccess';
import PromoterDailyReport_Foot_Count_Inquiry from '@salesforce/label/c.PromoterDailyReport_Foot_Count_Inquiry';

import getInitData from '@salesforce/apex/FootCountInquiryController.getInitData';
import saveRecord from '@salesforce/apex/FootCountInquiryController.saveRecord';

export default class FootCountInquiryLwc extends LightningNavigationElement {

    @api lwcName = PromoterDailyReport_Foot_Count_Inquiry;

    @api recordId;
    @api viewMode;
    @api isShowSpinner;

    @track recordList = [];
    @track isNew = true;

    @track label = {question1, question2, question3, question4, question5, question6};

    connectedCallback() {
        if (this.recordId) {
            this.isShowSpinner = true;
            getInitData({
                recordId: this.recordId,
            }).then(data => {
                this.isShowSpinner = false;
                this.fields = data.data.fields;
                if (data.isSuccess && data.data.footCountInquiryList.length > 0) {
                    this.recordList = data.data.footCountInquiryList;
                    for (let index = 0; index < this.recordList.length; index++) {
                        this.recordList[index].index = index;
                    }
                    this.isNew = false;
                } else {
                    this.recordList.push({
                        index: 0,
                        Question1__c: null,
                        Question2__c: null,
                        Question3__c: null,
                        Question4__c: null,
                        Question5__c: null,
                        Question6__c: null,
                    });
                    console.log('footCountInquiry ——> getInitData ——> isEmpty！');
                }

            }).catch(error => {
                this.catchError(error);
                this.isShowSpinner = false;
            });
        }
    }


    inputChangeHandler(event) {
        let index = event.target.dataset.index;
        let value = event.target.value;
        let targetName = event.target.dataset.fieldName;
        console.log('inputChangeHandler —> index：' + index);
        console.log('inputChangeHandler —> value：' + event.target.value);
        console.log('inputChangeHandler —> targetName：' + targetName);

        this.recordList[index][targetName] = value;
        this.recordList[index].fieldsEdit = 'true';
        if(value == '') {
            console.log('value is empty！');
            this.recordList[index][targetName] = null;
        }

        console.log('inputChangeHandler ——> end');
    }


    @api
    saveData() {
        this.isShowSpinner = true;
        let checkResult = this.saveCheck();
        console.log('saveData——> checkResult：' + checkResult);
        if (checkResult) {
            saveRecord({
                recordDataJson: JSON.stringify(this.recordList),
                recordId: this.recordId,
            }).then(data => {
                this.isShowSpinner = false;
                if (data.isSuccess) {

                } else {

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
            this.isShowSpinner = false;
        }

    }


    saveCheck() {
        let result = false;
        for (let i = 0; i < this.recordList.length; i++) {
            // Question1__c
            let quostionIndex = i + 1;
            let question = 'Question' + quostionIndex + '__c';
            result = this.isFilledOut(this.recordList[i][question]);
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
        return '';
    }
}