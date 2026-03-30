/*
 * @Author: WFC
 * @Date: 2023-06-16 13:35:57
 * @LastEditors: WFC
 * @LastEditTime: 2023-07-10 15:55:33
 * @Description: 
 * @FilePath: \Hitest_2022\force-app\main\default\lwc\trainingTaskPublishNoticeLWC\trainingTaskPublishNoticeLWC.js
 */
import { LightningElement, api, track } from 'lwc';
import LightningConfirm from "lightning/confirm";
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { NavigationMixin } from 'lightning/navigation';
import publishNotice from '@salesforce/apex/TrainingExaminationController.publishNotice';
import verifyPublishNotice from '@salesforce/apex/TrainingExaminationController.verifyPublishNotice';

export default class TrainingTaskPublishNoticeLWC extends NavigationMixin(LightningElement) {
    @api recordId;

    connectedCallback(){
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
            message: "Are you sure you want to publish a notification？",
            theme: "success",
            label: "Publish Notice",
        });
        if(result){
            // 选择ok 发布通知
            publishNotice({
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