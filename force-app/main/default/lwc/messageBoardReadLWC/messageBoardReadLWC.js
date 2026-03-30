import { LightningElement, track, api, wire } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { NavigationMixin , CurrentPageReference } from 'lightning/navigation';
import updateMessageBoardReadStatus from '@salesforce/apex/MessageBoardReadController.updateMessageBoardReadStatus';
export default class MessageBoardReadLWC extends NavigationMixin(LightningElement) {

    @api recordId;
    connectedCallback() {
        this.callUpdateMessageBoardReadStatus();
    }

    callUpdateMessageBoardReadStatus () {
        updateMessageBoardReadStatus({
            recordId : this.recordId
        }).then(result=>{
        }).catch(error => {
            console.log(error);
            this.showNotification("", error.message ,"error");
        });
    }
    /**
    Name : showNotification
    Purpose : 
    Params :  title, message,
    variant : error,warning,success,info
    Author : Chiara
    Date : 2021/07/26
    **/
    showNotification(title, message, variant) {
        const evt = new ShowToastEvent({
            //title: title,
            message: message,
            variant: variant,
        });
        this.dispatchEvent(evt);
    }
}