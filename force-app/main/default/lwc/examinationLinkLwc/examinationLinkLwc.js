/*
 * @Author: YYL
 * @LastEditors: TJP
 */
import { LightningElement, track, api, wire } from 'lwc';
import { LightningNavigationElement } from 'c/lwcUtils'
import { getObjectInfo } from 'lightning/uiObjectInfoApi';

import getInitData from '@salesforce/apex/ExaminationLinkLwcController.getInitData';

import CheckInCheckOut_More from '@salesforce/label/c.CheckInCheckOut_More';
import Examination_Link_To_Do from '@salesforce/label/c.Examination_Link_To_Do';

export default class ExaminationLinkLwc extends LightningNavigationElement {

    label ={
        CheckInCheckOut_More,
        Examination_Link_To_Do,
    }

    @track isShowExamination = false;
    @track recordId;
		/**
     * 初始化 Ticket 标签
     */
    @track ExaminationInfo = {
		Label: '',
        Name: '',
        // DueDate__c: '',
    };
    @wire(getObjectInfo, {objectApiName : 'Examination__c'})
    wiredTicketInfo({ error, data }) {
        if (data) {
            this.ExaminationInfo = {
				Label: data.label,
                Name: data.fields.Name.label,
                // Subject__c: data.fields.Subject__c.label,
                // DueDate__c: data.fields.DueDate__c.label,
            };
        } else if (error) {
            console.log(error);
            // this.showError('Ticket__c getInformation error');
        }
    }
    examinationData = [];


    // 初始化
    connectedCallback() {
        this.getInit();
    }

    getInit(){
        getInitData().then(data => {
            if (data.isSuccess) {
                // this.examinationData = data.data.examinationUser;
                this.examinationData = data.data.examinationUser.filter(item => item.Examination__r);
                console.log('connectedCallbackFilter' + JSON.stringify(this.examinationData));
                // console.log('connectedCallback' + JSON.stringify(data.data));

            } else {
                // ele.showError(data.message);
            }
        }).catch(error => {
            // this.catchError(JSON.stringify(error));
        });
    }
    
    reportOnClick(event) {
        var id = event.currentTarget.dataset.id;
        console.log(id);
        this.recordId = id;
        this.isShowExamination = true;
        // this.goToRecord(id);
    }

    closeExamination(){
        this.getInit();
        this.isShowExamination = false;
    }

    // moreOnClick() {
    //     this.goToObject('Ticket__c');
    // }
}