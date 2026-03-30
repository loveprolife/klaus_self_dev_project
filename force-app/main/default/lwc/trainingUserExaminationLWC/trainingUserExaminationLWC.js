/*
 * @Author: WFC
 * @Date: 2023-06-19 14:19:27
 * @LastEditors: WFC
 * @LastEditTime: 2023-06-21 16:02:20
 * @Description: 
 * @FilePath: \Hitest_2022\force-app\main\default\lwc\trainingUserExaminationLWC\trainingUserExaminationLWC.js
 */
import { LightningElement, api, track  } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { NavigationMixin } from 'lightning/navigation';
import initTrainingUserExamination from '@salesforce/apex/TrainingExaminationController.initTrainingUserExamination';
import markSubjectiveQuestions from '@salesforce/apex/TrainingExaminationController.markSubjectiveQuestions';

export default class TrainingUserExaminationLWC extends NavigationMixin(LightningElement) {
    @api recordId;
    @track trainingTask;
    @track trainingTaskUser;
    @track trainingTaskName;
    @track questionBankList;// 试卷集合
    // @track singleChoiceList;// 单选题
    // @track multipleChoiceList;// 多选题
    // @track judgmentQuestionList;// 判断题
    // @track subjectiveQuestionList;// 主观题
    // @track haveSingleChoiceList = false; 
    // @track haveMultipleChoiceList = false; 
    // @track haveJudgmentQuestionList = false;
    // @track haveSubjectiveQuestionList = false;
    // @track questionAnswerScoreMap = {};// 题目及答案集合
    @track isShowSpinner;// 遮罩
    @track isHaveAnswer = true;// 是否有答题

    label = {

    }

    connectedCallback() {
        this.isShowSpinner = false;
        initTrainingUserExamination({
            recordId : this.recordId,
        }).then(result => {
            if (result.isSuccess) {
                this.trainingTask = result.trainingTask;
                this.trainingTaskUser = result.trainingTaskUser;
                this.trainingTaskName = result.trainingTask.Training_Content__c;
                this.questionBankList = result.questionBankList;
                // this.singleChoiceList = result.questionBankList[0].singleChoiceList;
                // this.multipleChoiceList = result.questionBankList[0].multipleChoiceList;
                // this.judgmentQuestionList = result.questionBankList[0].judgmentQuestionList;
                // this.subjectiveQuestionList = result.questionBankList[0].subjectiveQuestionList;
                // this.questionAnswerScoreMap = result.questionBankList[0].questionAnswerScoreMap;
                // if(result.singleChoiceList != undefined && result.singleChoiceList != '' && result.singleChoiceList != null){
                //     this.haveSingleChoiceList = true;
                // }
                // if(result.multipleChoiceList != undefined && result.multipleChoiceList != '' && result.multipleChoiceList != null){
                //     this.haveMultipleChoiceList = true;
                // }
                // if(result.judgmentQuestionList != undefined && result.judgmentQuestionList != '' && result.judgmentQuestionList != null){
                //     this.haveJudgmentQuestionList = true;
                // }
                // if(result.subjectiveQuestionList != undefined && result.subjectiveQuestionList != '' && result.subjectiveQuestionList != null){
                //     this.haveSubjectiveQuestionList = true;
                // }
            }else {
                this.isHaveAnswer = false;
            }
            
        }).catch(error => {
            this.dispatchEvent(new ShowToastEvent({
                title: 'error',
                message: '初始化页面失败!',
                variant: 'error',
                // mode: "sticky"
            }));
        });
    }

    changeScore(event){
        let maxScore = Number(event.currentTarget.dataset.record);
        let score = Number(event.currentTarget.value);
        // 第几个答题的评分
        let indexList = Number(event.currentTarget.dataset.name);
        if(score > maxScore || score < 0){
            this.questionBankList[indexList].questionAnswerScoreMap[event.currentTarget.name] = 'false';
        }else {
            this.questionBankList[indexList].questionAnswerScoreMap[event.currentTarget.name] = score;
        }  
    }

    cancel(event){
        const closeModal = new CustomEvent('closeModal');
        this.dispatchEvent(closeModal);
    }

    submit(event){
        let indexList = Number(event.currentTarget.dataset.record);
        this.isShowSpinner = true;
        // 验证评分是否为空
        let num = 0;
        let errorNum = 0;
        let questionAnswerScoreMap = this.questionBankList[indexList].questionAnswerScoreMap;
        //验证是否全部作答
        for (var prop in questionAnswerScoreMap) { 
            if(questionAnswerScoreMap[prop] == undefined || questionAnswerScoreMap[prop] == '' || questionAnswerScoreMap[prop] == null){
                num += 1;
            }else if(questionAnswerScoreMap[prop] == 'false'){
                errorNum += 1;
            }
        }
        if(num > 0){
            this.dispatchEvent(new ShowToastEvent({
                title: 'error',
                message: '有' + num + '道主观题没有评分！',
                variant: 'error',
                // mode: "sticky"
            }));
            this.isShowSpinner = false;
            return;
        }
        if(errorNum > 0){
            this.dispatchEvent(new ShowToastEvent({
                title: 'error',
                message: '有' + errorNum + '道主观题评分不在规定范围内！',
                variant: 'error',
                // mode: "sticky"
            }));
            this.isShowSpinner = false;
            return;
        }
        markSubjectiveQuestions({
            questionAnswerScoreMap : questionAnswerScoreMap,
            trainingTaskUser : this.trainingTaskUser,
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
            }
            this.isShowSpinner = false;

        }).catch(error => {
            this.isShowSpinner = false;
            this.dispatchEvent(new ShowToastEvent({
                title: 'error',
                message: '评分失败！',
                variant: 'error',
                // mode: "sticky"
            }));
        });
          
    }
}