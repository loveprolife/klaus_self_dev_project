import { LightningNavigationElement } from 'c/lwcUtils';
import { LightningElement, track, api, wire } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { CloseActionScreenEvent } from 'lightning/actions';

import saveRecord from '@salesforce/apex/TicketResolvedButtonController.saveRecord';
import getInitData from '@salesforce/apex/TicketResolvedButtonController.getInitData';

export default class TicketResolvedButtonLwc extends LightningElement {

    @api recordId;

    @track message = '';
    @track notResolved = false;

    connectedCallback() {
        console.log('connectedCallback ——> recordId：' + this.recordId);
        if (this.recordId) {
            getInitData({
                recordId: this.recordId,
            }).then(data => {
                this.message = data.data.message;
                this.notResolved = data.data.notResolved;
                console.log('message：' + this.message);
            })
        }
    }

    yes(event) {
        console.log('yes');
        saveRecord({
            recordId: this.recordId,
        }).then(rs => {
            console.log('rs：' + JSON.stringify(rs));
            console.log('rs.message：' + rs.message);
            const event = new ShowToastEvent({
                title: 'result',
                variant: 'success',
                message: rs.message
            });
            if (rs.code != 0) {
                evt.variant = 'error';
            }
            this.dispatchEvent(event);
            this.dispatchEvent(new CloseActionScreenEvent());
            this.dispatchEvent(new CustomEvent('closemodal'));
            window.location.reload();
        });
    }

    cancel(event) {
        console.log("cancel:");
        this.dispatchEvent(new CloseActionScreenEvent());
        this.dispatchEvent(new CustomEvent('closemodal'));
    }
}