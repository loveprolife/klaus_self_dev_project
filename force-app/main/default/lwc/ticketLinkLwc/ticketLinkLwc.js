import { LightningElement, track, api, wire } from 'lwc';
import { LightningNavigationElement } from 'c/lwcUtils'
import { getObjectInfo } from 'lightning/uiObjectInfoApi';

import getInitData from '@salesforce/apex/TicketLinkLwcController.getInitData';

import CheckInCheckOut_More from '@salesforce/label/c.CheckInCheckOut_More';
export default class TicketLinkLwc extends LightningNavigationElement {

    label ={
        CheckInCheckOut_More,
    }
		/**
     * 初始化 Ticket 标签
     */
    @track TicketInfo = {
				Label: '',
        Name: '',
        Subject__c: '',
        DueDate__c: '',
    };
    @wire(getObjectInfo, {objectApiName : 'Ticket__c'})
    wiredTicketInfo({ error, data }) {
        if (data) {
            this.TicketInfo = {
								Label: data.label,
                Name: data.fields.Name.label,
                Subject__c: data.fields.Subject__c.label,
                DueDate__c: data.fields.DueDate__c.label,
            };
        } else if (error) {
            console.log(error);
            // this.showError('Ticket__c getInformation error');
        }
    }
    ticketData = [];
    
    // 初始化
    connectedCallback() {
        getInitData().then(data => {
            if (data.isSuccess) {
                this.ticketData = data.data.reports;
                console.log(JSON.stringify(data.data));

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
        this.goToRecord(id);
    }

    moreOnClick() {
        this.goToObject('Ticket__c');
    }
}