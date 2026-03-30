/*
 * @Author: WFC
 * @Date: 2022-07-07 17:20:48
 * @LastEditors: WFC
 * @LastEditTime: 2022-09-09 11:03:25
 * @Description: 
 * @FilePath: \Hitest\force-app\main\default\lwc\restoreCustomerLWC\restoreCustomerLWC.js
 */
import { LightningElement, api, track  } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import saveData from '@salesforce/apex/EliminateCustomerController.saveData';
import Restore_Customer_Comments from '@salesforce/label/c.Restore_Customer_Comments';
import Restore_Customer from '@salesforce/label/c.Restore_Customer';
import Applicable_approval_process from '@salesforce/label/c.Applicable_approval_process';

export default class RestoreCustomerLWC extends LightningElement {
    @api recordId;
    @track comments;
    @track isShowSpinner = false;
    @track isShowSubmit = true;

    label = {
        Restore_Customer_Comments,
        Restore_Customer,
        Applicable_approval_process
    }

    cancel(event){
        const closeModal = new CustomEvent('closeModal');
        this.dispatchEvent(closeModal);
    }

    submit(event){
        this.isShowSpinner = true;
        this.isShowSubmit = false;
        if (!this.judgeFieldValueEmpty(this.comments)) {
            saveData({
                comments : this.comments,
                recordId : this.recordId,
                approvalName : 'RestoreCustomer'
            }).then(result => {
                if (result.isSucess) {
                    const closeModal = new CustomEvent('closeModal');
                    this.dispatchEvent(closeModal);
                    this.dispatchEvent(new ShowToastEvent({
                        title: 'Success',
                        message: this.label.Applicable_approval_process,
                        variant: 'Success',
                    }));
                }else {
                    this.dispatchEvent(new ShowToastEvent({
                        title: 'error',
                        message: result.errorMsg,
                        variant: 'error',
                    }));
                }
                this.isShowSpinner = false;
                this.isShowSubmit = true;
            }).catch(error => {
                this.isShowSpinner = false;
                this.isShowSubmit = true;
            }); 
        }
        
    }

    reportDataChange(event) {
        this.comments = event.target.value;
    }

    judgeFieldValueEmpty(fieldValue){
        if(fieldValue == undefined || fieldValue == null || fieldValue == "") {
            return true;
        }else{
            return false;
        }
    }
}