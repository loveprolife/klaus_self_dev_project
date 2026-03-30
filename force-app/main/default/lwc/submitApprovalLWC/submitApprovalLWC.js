import { LightningElement, api, track  } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import passSixty from '@salesforce/apex/ScoreSheetPast.passSixty';
import saveData from '@salesforce/apex/ScoreSheetPast.saveData';
import Submit_For_approval from '@salesforce/label/c.Common_Button_Submit_For_Approval';
import Eliminate_Customer_Comments from '@salesforce/label/c.Eliminate_Customer_Comments';
import Customer_Score_Pass_60 from '@salesforce/label/c.Customer_Score_Pass_60';



export default class SubmitApprovalLWC extends LightningElement {
    @api recordId;
    @track comments;
    @track isShowSpinner = false;
    @track isShowSubmit = true;
    @track isShowWarning;


    label = {
        Submit_For_approval,
        Eliminate_Customer_Comments,
        Customer_Score_Pass_60
    }

    connectedCallback() {
        passSixty({
            recordId : this.recordId,
        }).then(result => {
            this.isShowWarning = result;
            if (this.isShowWarning) {
                alert(this.label.Customer_Score_Pass_60);
            }
        }).catch(error => {
            //todo
            console.log("something went wrong");
        });
    }
    
    cancel(event){
        const closeModal = new CustomEvent('closemodal');
        this.dispatchEvent(closeModal);
    }

    submit(event){
        this.isShowSpinner = true;
        this.isShowSubmit = false;
        // if (!this.judgeFieldValueEmpty(this.comments)) {
            saveData({
                comments : this.comments,
                recordId : this.recordId,
                approvalName : 'SubmitForApproval'
            }).then(result => {
                if (result.isSucess) {
                    const closeModal = new CustomEvent('submitsuccess');
                    this.dispatchEvent(closeModal);
                    this.dispatchEvent(new ShowToastEvent({
                        title: 'Success',
                        message: this.label.Submit_For_approval,
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
        // }
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