import { LightningElement,api } from 'lwc';
import {ShowToastEvent} from 'lightning/platformShowToastEvent';
import urgingSendEmail from '@salesforce/apex/UrgingButtonController.urgingSendEmail';
import Urging from '@salesforce/label/c.Urging';

export default class UrgingButton extends LightningElement {

    @api recordId;

    label = {
        Urging
    }

    urging(){
        urgingSendEmail({
            customerId:this.recordId,
        }).then(data => {
            this.urgingResult(data.code);
        }).catch(error => {
            this.urgingResultError(error);
        })
    }

    urgingResult(code){
        if(code == 200){
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Urging Success',
                    message: 'Urging Success',
                    variant: 'success',
                    mode : 'sticky'
                }),
            );
        }else{
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Urging failure',
                    message: 'There are currently no pending approval processes for the current customer',
                    variant: 'error',
                    mode : 'sticky'
                }),
            );
        }
        
    }

    urgingResultError(error){
        this.dispatchEvent(
            new ShowToastEvent({
                title: 'Urging failure',
                message: error.body.message,
                variant: 'error',
                mode : 'sticky'
            }),
        );
    }
}