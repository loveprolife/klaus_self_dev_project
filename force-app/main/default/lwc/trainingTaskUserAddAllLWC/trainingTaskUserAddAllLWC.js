/*
 * @Author: WFC
 * @Date: 2023-08-01 13:26:25
 * @LastEditors: WFC
 * @LastEditTime: 2023-08-10 14:59:30
 * @Description: 
 * @FilePath: \Hitest_2022\force-app\main\default\lwc\trainingTaskUserAddAllLWC\trainingTaskUserAddAllLWC.js
 */
import { LightningElement, api, track } from 'lwc';
import LightningConfirm from "lightning/confirm";
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { NavigationMixin } from 'lightning/navigation';
import addAllTrainingTaskUser from '@salesforce/apex/TrainingExaminationController.addAllTrainingTaskUser';
import Save_Success from '@salesforce/label/c.Save_Success';
import Save_Failed from '@salesforce/label/c.Save_Failed';
import verifyAddAllUser from '@salesforce/apex/TrainingExaminationController.verifyAddAllUser';

export default class TrainingTaskUserAddAllLWC extends NavigationMixin(LightningElement) {

    label ={
        Save_Success, // 保存成功
        Save_Failed, // 保存失败
    }

    @api recordId;

    connectedCallback(){
        verifyAddAllUser({
            recordId : this.recordId,
        }).then(result => {
            if(result.isSuccess){
                this.handleConfirm();
            }           
        }).catch(error => {
            
        });
    }

    async handleConfirm() {
        const result = await LightningConfirm.open({
            message: "Are you sure you want to add all users？",
            theme: "success",
            label: "Add All",
        });
        if(result){
            // 选择ok 发布通知
            addAllTrainingTaskUser({
                recordId : this.recordId,
            }).then(result => {
                if(result){
                    this.dispatchEvent(new ShowToastEvent({
                        title: 'success',
                        message: this.label.Save_Success,
                        variant: 'success',
                        // mode: "sticky"
                    }));
                    const closeModal = new CustomEvent('closeModal');
                    this.dispatchEvent(closeModal);
                }           
            }).catch(error => {
                this.dispatchEvent(new ShowToastEvent({
                    title: 'error',
                    message: this.label.Save_Failed,
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