/*
 * @Author: WFC
 * @Date: 2023-06-25 15:48:58
 * @LastEditors: WFC
 * @LastEditTime: 2023-08-10 14:56:25
 * @Description: 
 * @FilePath: \Hitest_2022\force-app\main\default\lwc\trainingTaskUnpublishNoticeLWC\trainingTaskUnpublishNoticeLWC.js
 */
import { LightningElement, api, track } from 'lwc';
import LightningConfirm from "lightning/confirm";
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { NavigationMixin } from 'lightning/navigation';
import unpublishNotice from '@salesforce/apex/TrainingExaminationController.unpublishNotice';
import verifyPublishNotice from '@salesforce/apex/TrainingExaminationController.verifyPublishNotice';

export default class TrainingTaskUnpublishNoticeLWC extends NavigationMixin(LightningElement) {
    @api recordId;

    connectedCallback(){
        
    }

    renderedCallback(){
        verifyPublishNotice({
            recordId : this.recordId,
        }).then(result => {
            if(result.isSuccess){
                this.handleConfirm();
            }else {
                this.dispatchEvent(new ShowToastEvent({
                    title: 'error',
                    message: result.msg,
                    variant: 'error',
                    // mode: "sticky"
                }));
                const closeModal = new CustomEvent('closeModal');
                this.dispatchEvent(closeModal);
            }            
        }).catch(error => {
            
        });
    }

    async handleConfirm() {
        const result = await LightningConfirm.open({
            message: "Are you sure you want to unpublish a notification？",
            theme: "warning",
            label: "Unpublish Notice",
        });
        if(result){
            // 选择ok 发布通知
            unpublishNotice({
                recordId : this.recordId,
            }).then(result => {
                if(result.isSuccess){
                    this.dispatchEvent(new ShowToastEvent({
                        title: 'success',
                        message: result.msg,
                        variant: 'success',
                        // mode: "sticky"
                    }));
                    const closeModal = new CustomEvent('closeModal');
                    this.dispatchEvent(closeModal);
                }           
            }).catch(error => {
                this.dispatchEvent(new ShowToastEvent({
                    title: 'error',
                    message: result.msg,
                    variant: 'error',
                    // mode: "sticky"
                }));
                const closeModal = new CustomEvent('closeModal');
                this.dispatchEvent(closeModal);
            });
            
        }else{
            const closeModal = new CustomEvent('closeModal');
            this.dispatchEvent(closeModal);
        }
    }
}