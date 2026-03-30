/*
 * @Author: WFC
 * @Date: 2023-05-26 14:06:44
 * @LastEditors: WFC
 * @LastEditTime: 2023-07-17 11:18:42
 * @Description: 
 * @FilePath: \Hitest_2022\force-app\main\default\lwc\trainingExaminationLWC\trainingExaminationLWC.js
 */
import { LightningElement, api, track  } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { NavigationMixin } from 'lightning/navigation';
import initData from '@salesforce/apex/TrainingExaminationController.initData';
import saveData from '@salesforce/apex/TrainingExaminationController.saveData';
import Have from '@salesforce/label/c.Have';
import Question_No_Answer from '@salesforce/label/c.Question_No_Answer';
import Single_Choice_Question from '@salesforce/label/c.Single_Choice_Question';
import Multiple_Choice_Question from '@salesforce/label/c.Multiple_Choice_Question';
import Judgment_Question from '@salesforce/label/c.Judgment_Question';
import Subjective_Questions from '@salesforce/label/c.Subjective_Questions';
import Training_Task_Cancel from '@salesforce/label/c.Training_Task_Cancel';
import Training_Task_Submit from '@salesforce/label/c.Training_Task_Submit';

export default class TrainingExaminationLWC extends NavigationMixin(LightningElement) {
    @api recordId;
    @track trainingTask;
    @track trainingTaskName;
    @track singleChoiceList;// 单选题
    @track multipleChoiceList;// 多选题
    @track judgmentQuestionList;// 判断题
    @track subjectiveQuestionList;// 主观题
    @track haveSingleChoiceList = false; 
    @track haveMultipleChoiceList = false; 
    @track haveJudgmentQuestionList = false;
    @track haveSubjectiveQuestionList = false;
    @track questionAnswerMap = {};// 题目及答案集合
    @track isCanAnswer = false; // 是否可作答题目
    @track isShowSpinner;// 遮罩
    @track isShowQuestion = true;// 展示题目

    label = {
        Have,// 有
        Question_No_Answer,// 道题没有作答！
        Single_Choice_Question, // 单选题
        Multiple_Choice_Question, // 多选题
        Judgment_Question, // 判断题
        Subjective_Questions, // 主观题
        Training_Task_Cancel, // 取消
        Training_Task_Submit, // 提交
    }

    connectedCallback() {
        this.isShowSpinner = false;
        initData({
            recordId : this.recordId,
        }).then(result => {
            if (result.isSuccess) {
                if(result.isPassExamination){
                    this.dispatchEvent(new ShowToastEvent({
                        title: 'success',
                        message: result.msg,
                        variant: 'success',
                        // mode: "sticky"
                    }));
                    const closeModal = new CustomEvent('closeModal');
                    this.dispatchEvent(closeModal);
                    return;

                }
                this.trainingTask = result.trainingTask;
                this.trainingTaskName = result.trainingTask.Training_Content__c;
                this.singleChoiceList = result.singleChoiceList;
                this.multipleChoiceList = result.multipleChoiceList;
                this.judgmentQuestionList = result.judgmentQuestionList;
                this.subjectiveQuestionList = result.subjectiveQuestionList;
                this.questionAnswerList = result.questionAnswerList;
                this.questionAnswerMap = result.questionAnswerMap;
                this.isCanAnswer = result.isCanAnswer;

                if(result.singleChoiceList != undefined && result.singleChoiceList != '' && result.singleChoiceList != null){
                    this.haveSingleChoiceList = true;
                }
                if(result.multipleChoiceList != undefined && result.multipleChoiceList != '' && result.multipleChoiceList != null){
                    this.haveMultipleChoiceList = true;
                }
                if(result.judgmentQuestionList != undefined && result.judgmentQuestionList != '' && result.judgmentQuestionList != null){
                    this.haveJudgmentQuestionList = true;
                }
                if(result.subjectiveQuestionList != undefined && result.subjectiveQuestionList != '' && result.subjectiveQuestionList != null){
                    this.haveSubjectiveQuestionList = true;
                }
            }else {
                this.isShowQuestion = false;
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
            this.isShowQuestion = false;
                this.dispatchEvent(new ShowToastEvent({
                    title: 'error',
                    message: result.msg,
                    variant: 'error',
                    // mode: "sticky"
            }));
            const closeModal = new CustomEvent('closeModal');
            this.dispatchEvent(closeModal);
        });
    }

    changeSubjectiveQuestion(event){
        this.questionAnswerMap[event.currentTarget.name] = event.target.value;
    }

    selectSingleChoice(event){
        this.questionAnswerMap[event.currentTarget.name] = event.target.value;
    }

    selectMultipleChoice(event){
        let currentId = event.currentTarget.name;
        let currentValue = event.target.value;
        let oldValue = this.questionAnswerMap[event.currentTarget.name];
        if(oldValue != undefined && oldValue != '' && oldValue != null){
            
            let oldValueList = oldValue.split(';');
            // 取消选择
            if(oldValue.indexOf(currentValue) != -1){
                oldValueList = oldValueList.filter(item => item !== currentValue);
            }else{
                oldValueList.push(currentValue);
                oldValueList.sort(); 
            }

            this.questionAnswerMap[currentId] = oldValueList.join(';');
            
        }else {
            this.questionAnswerMap[currentId] = currentValue;
        }
    }

    cancel(event){
        const closeModal = new CustomEvent('closeModal');
        this.dispatchEvent(closeModal);
    }

    submit(event){
        this.isShowSpinner = true;
        let num = 0;
        //验证是否全部作答
        for (var prop in this.questionAnswerMap) { 
            if(this.questionAnswerMap[prop] == undefined || this.questionAnswerMap[prop] == '' || this.questionAnswerMap[prop] == null){
                num += 1;
            }
        }
        if(num > 0){
            this.dispatchEvent(new ShowToastEvent({
                title: 'error',
                message: '有' + num + '道题没有作答！',
                variant: 'error',
                // mode: "sticky"
            }));
            this.isShowSpinner = false;
            return;
        }
        
        saveData({
            questionAnswerMap : this.questionAnswerMap,
            trainingTask : this.trainingTask,
        }).then(result => {
            if (result.isSuccess) {
                this.dispatchEvent(new ShowToastEvent({
                    title: 'success',
                    message: result.msg,
                    variant: 'success',
                    // mode: "sticky"
                }));
                const closeModal = new CustomEvent('closeModal');
                this.dispatchEvent(closeModal);
            }else{
                this.dispatchEvent(new ShowToastEvent({
                    title: 'error',
                    message: result.msg,
                    variant: 'error',
                    // mode: "sticky"
                })); 
            }
            this.isShowSpinner = false;

        }).catch(error => {
            this.isShowSpinner = false;
        });
          
    }

}