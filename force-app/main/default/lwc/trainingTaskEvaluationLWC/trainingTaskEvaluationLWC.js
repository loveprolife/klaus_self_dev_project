/*
 * @Author: WFC
 * @Date: 2023-06-15 09:18:29
 * @LastEditors: WFC
 * @LastEditTime: 2023-07-17 13:22:47
 * @Description: 
 * @FilePath: \Hitest_2022\force-app\main\default\lwc\trainingTaskEvaluationLWC\trainingTaskEvaluationLWC.js
 */
import { LightningElement, api, track} from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { NavigationMixin } from 'lightning/navigation';
import getTrainingTaskEvaluation from '@salesforce/apex/TrainingExaminationController.getTrainingTaskEvaluation';
import saveEvaluationReply from '@salesforce/apex/TrainingExaminationController.saveEvaluationReply';
import deleteEvaluationReply from '@salesforce/apex/TrainingExaminationController.deleteEvaluationReply';
import LightningConfirm from "lightning/confirm";
import Save_Success from '@salesforce/label/c.Save_Success';
import Save_Failed from '@salesforce/label/c.Save_Failed';
import Deleted_Success from '@salesforce/label/c.Deleted_Success';
import Deleted_Failed from '@salesforce/label/c.Deleted_Failed';
import Nothing_To_Evaluate from '@salesforce/label/c.Nothing_To_Evaluate';


export default class TrainingTaskEvaluationLWC extends NavigationMixin(LightningElement){
    label ={
        Save_Success, // 保存成功
        Save_Failed, // 保存失败
        Deleted_Success, // 删除成功
        Deleted_Failed, // 删除失败
        Nothing_To_Evaluate, // 培训任务没有需要评价的内容!
    }
    @api recordId;

    @track showPage = false;
    @track isHaveEvaluation = false;
    @track isHaveEvaluationReply = false;
    @track trainingTaskEvaluation;
    @track trainingTaskEvaluationId;
    @track trainingTaskEvaluationReply;
    @track trainingTaskEvaluationReplyId;
    @track comments;
    @track isShowSpinner = false;
    @track isCanSave = false;

    connectedCallback(){
        getTrainingTaskEvaluation({
            recordId : this.recordId,
        }).then(result => {
            if(result.isSuccess){
                this.showPage = true;
                if(result.isHaveEvaluation){
                    this.isHaveEvaluation = result.isHaveEvaluation;
                    this.trainingTaskEvaluation = result.trainingTaskEvaluation.Evaluation__c;
                    this.trainingTaskEvaluationId = result.trainingTaskEvaluation.Id;
                    if(result.isHaveEvaluationReply){
                        this.isHaveEvaluationReply = result.isHaveEvaluationReply;
                        this.trainingTaskEvaluationReply = result.trainingTaskEvaluationReply.Reply__c;
                        this.trainingTaskEvaluationReplyId = result.trainingTaskEvaluationReply.Id;
                        if (!this.judgeFieldValueEmpty(this.trainingTaskEvaluationReply)) {
                            this.isCanSave = true;
                            this.comments = result.trainingTaskEvaluationReply.Reply__c;
                        }
                    }
                }
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
            //todo
        });

    }

    saveEvaluationReply(event){
        this.isShowSpinner = true;
        if (!this.judgeFieldValueEmpty(this.comments)) {
            saveEvaluationReply({
                trainingTaskEvaluationId : this.trainingTaskEvaluationId,
                trainingTaskEvaluationReplyId : this.trainingTaskEvaluationReplyId,
                comments : this.comments,
            }).then(result => {
                this.isShowSpinner = false;
                if(result){
                    this.dispatchEvent(new ShowToastEvent({
                        title: 'success',
                        message: this.label.Save_Success,// '保存成功！',
                        variant: 'success',
                        // mode: "sticky"
                    }));
                    const closeModal = new CustomEvent('closeModal');
                    this.dispatchEvent(closeModal);
                }else {
                    this.dispatchEvent(new ShowToastEvent({
                        title: 'error',
                        message: this.label.Save_Failed,// '保存失败！',
                        variant: 'error',
                        // mode: "sticky"
                    })); 
                }
            }).catch(error => {
                this.isShowSpinner = false;
                this.dispatchEvent(new ShowToastEvent({
                    title: 'error',
                    message: this.label.Save_Failed, //'保存失败！',
                    variant: 'error',
                    // mode: "sticky"
                })); 
            });
        }
    }

    async handleConfirm() {
        const result = await LightningConfirm.open({
            message: "Make sure to delete the evaluation？",
            theme: "warning",
            label: "Delete reminder",
        });
        if(result){
            this.isShowSpinner = true;
            deleteEvaluationReply({
                trainingTaskEvaluationReplyId : this.trainingTaskEvaluationReplyId,
            }).then(result => {
                this.isShowSpinner = false;
                if(result){
                    this.dispatchEvent(new ShowToastEvent({
                        title: 'success',
                        message: this.label.Deleted_Success,//'删除成功！',
                        variant: 'success',
                        // mode: "sticky"
                    }));
                    const closeModal = new CustomEvent('closeModal');
                    this.dispatchEvent(closeModal);
                }else {
                    this.dispatchEvent(new ShowToastEvent({
                        title: 'error',
                        message: this.label.Deleted_Failed,//'删除失败！',
                        variant: 'error',
                        // mode: "sticky"
                    })); 
                }
            }).catch(error => {
                this.isShowSpinner = false;
                this.dispatchEvent(new ShowToastEvent({
                    title: 'error',
                    message: this.label.Deleted_Failed,//'删除失败！',
                    variant: 'error',
                    // mode: "sticky"
                })); 
            });
        }
    }

    reportDataChange(event) {
        this.comments = event.target.value;
        if (!this.judgeFieldValueEmpty(this.comments)) {
            this.isCanSave = true;
        }else {
            this.isCanSave = false;
        }
    }

    judgeFieldValueEmpty(fieldValue){
        if(fieldValue == undefined || fieldValue == null || fieldValue == "") {
            return true;
        }else{
            return false;
        }
    }
        
    cancel(event){
        const closeModal = new CustomEvent('closeModal');
        this.dispatchEvent(closeModal);
    }

}