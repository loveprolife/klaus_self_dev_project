import { track, api, wire } from 'lwc';
import { LightningNavigationElement } from 'c/lwcUtils';
import { CloseActionScreenEvent } from 'lightning/actions';

import Submit_for_Approval from '@salesforce/label/c.Submit_for_Approval';
import Cancel from '@salesforce/label/c.Cancel';
import Application_Submit from '@salesforce/label/c.Application_Submit';

import getInitData from '@salesforce/apex/ApplicationButtonController.submitGetInitData';
import saveData from '@salesforce/apex/ApplicationButtonController.submitSaveData';

export default class ApplicationSubmitButtonLwc extends LightningNavigationElement {

    @api recordId;
    @track isShowSpinner = false;
    @track messages = '';

    label = { Submit_for_Approval, Cancel, Application_Submit };

    get canSubmit() {
        return this.messages == '' ? true : false;
    }

    connectedCallback() {
        this.isShowSpinner = true;

        getInitData({
            recordId: this.recordId
        }).then(resp => {
            if (resp.isSuccess) {
                this.messages = resp.data.messages;
                console.log('message：' + this.messages);
            } else {
                this.showError(resp.message);
            }
            this.isShowSpinner = false;
        }).catch(error => {
            this.catchError(error);
            this.isShowSpinner = false;
        })

    }

    saveRecord(event) {
        this.isShowSpinner = true;
        saveData({
            recordId: this.recordId
        }).then(resp => {
            this.isShowSpinner = false;
            if (resp.isSuccess) {
                this.messages = resp.data.message;
                if(resp.data.needFile) {
                    this.showError(this.messages);
                }
            } else {
                this.showError(resp.message);
            }
            this.dispatchEvent(new CustomEvent('refreshview'));
            this.dispatchEvent(new CloseActionScreenEvent());
            this.dispatchEvent(new CustomEvent('closemodal'));
        }).catch(error => {
            this.catchError(error);
            this.isShowSpinner = false;
        })
    }

    cancel(event) {
        this.dispatchEvent(new CloseActionScreenEvent());
        this.dispatchEvent(new CustomEvent('closemodal'));
    }
}