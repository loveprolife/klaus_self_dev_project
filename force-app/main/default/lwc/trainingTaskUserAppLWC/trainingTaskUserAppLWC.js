/*
 * @Author: WFC
 * @Date: 2023-07-31 14:16:22
 * @LastEditors: WFC
 * @LastEditTime: 2023-07-31 16:06:58
 * @Description: 
 * @FilePath: \Hitest_2022\force-app\main\default\lwc\trainingTaskUserAppLWC\trainingTaskUserAppLWC.js
 */
import { LightningElement, api, track, wire } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import LightningConfirm from "lightning/confirm";
import additionalExamination from '@salesforce/apex/TrainingExaminationController.additionalExamination';

export default class TrainingTaskUserAppLWC extends LightningElement {
    @api trainingTaskUserIds;
    
    connectedCallback() {
        console.log('trainingTaskUserIds:' + this.trainingTaskUserIds);
        this.handleConfirm();
    }

    async handleConfirm() {
        const result = await LightningConfirm.open({
            message: "Additional Examination？",
            theme: "success",
            label: "Additional Examination",
        });
        if(result){
            additionalExamination({
                trainingTaskUserIds : this.trainingTaskUserIds,
            }).then(result => {
                window.history.go(-1);
            }).catch(error => {
                window.history.go(-1);
            });
            window.history.go(-1);
        }else{
            window.history.go(-1);
        }
    }
}