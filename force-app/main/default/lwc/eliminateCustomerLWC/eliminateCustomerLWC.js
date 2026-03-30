/*
 * @Author: WFC
 * @Date: 2022-07-06 09:45:46
 * @LastEditors: WFC
 * @LastEditTime: 2022-09-09 10:56:19
 * @Description: 
 * @FilePath: \Hitest\force-app\main\default\lwc\eliminateCustomerLWC\eliminateCustomerLWC.js
 */
import { LightningElement, api, track  } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import saveData from '@salesforce/apex/EliminateCustomerController.saveData';
import Eliminate_Customer_Comments from '@salesforce/label/c.Eliminate_Customer_Comments';
import Eliminate_Customer from '@salesforce/label/c.Eliminate_Customer';
import Applicable_approval_process from '@salesforce/label/c.Applicable_approval_process';


export default class EliminateCustomerLWC extends LightningElement {
    @api recordId;
    @track comments;
    @track isShowSpinner = false;
    @track isShowSubmit = true;

    label = {
        Eliminate_Customer_Comments,
        Eliminate_Customer,
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
            this.saveFlag = false;
            saveData({
                comments : this.comments,
                recordId : this.recordId,
                approvalName : 'EliminateCustomer'
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