import { LightningElement, api, track  } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { NavigationMixin } from 'lightning/navigation';
import initDataExamination from '@salesforce/apex/TrainingExaminationController.initDataExamination';
import saveDataExamination from '@salesforce/apex/TrainingExaminationController.saveDataExamination';
import Have from '@salesforce/label/c.Have';
import Question_No_Answer from '@salesforce/label/c.Question_No_Answer';
import Single_Choice_Question from '@salesforce/label/c.Single_Choice_Question';
import Multiple_Choice_Question from '@salesforce/label/c.Multiple_Choice_Question';
import Judgment_Question from '@salesforce/label/c.Judgment_Question';
import Subjective_Questions from '@salesforce/label/c.Subjective_Questions';
import Training_Task_Cancel from '@salesforce/label/c.Training_Task_Cancel';
import Training_Task_Submit from '@salesforce/label/c.Training_Task_Submit';

export default class ExaminationLwc extends NavigationMixin(LightningElement) {
    @api recordId;
    @api newTime; // 二维码生成时间
    @api loseDate; // 失效时间（秒）
    @track isExceedDate = false; // 二维码是否失效
    @track labelMsg = 'Qr code is invali'; //提示文本

    @track trainingTask;
    @track examination;
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
    
    @api styleWidth
    
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

    get modalHeight() {
        var height = 'height: 100%';
				
        try {
            if (this.root) {
                var doc = document.documentElement.clientHeight;
    
                var rooth = this.root.childNodes[0].offsetHeight
                height = doc<rooth ? 'height: '+rooth+'px;' : 'height: 100%;';
            }
        } catch (error) {
            
        }
				
        return height;
    }

    get containerStyle() {
        return this.styleWidth ? 'style="height: ' + this.styleWidth + ';max-height:' + this.styleWidth + '"' : '';
    }

    async handleAlertExceedDate() {
        await LightningAlert.open({
            message: 'Qr code is invalid',
            theme: 'warning', 
            label: 'Warning!', // this is the header text
        });
    }

    connectedCallback() {
        console.log('wwwwconnectedCallback recordId' + this.recordId);
        console.log('wwwwconnectedCallback newTime' + this.newTime);
        console.log('wwwwconnectedCallback loseDate' + this.loseDate);
        this.isShowSpinner = true;
        console.log('wwwwconnectedCallback');
        // 检测二维码是否失效
        // let endTime = Date.now();
        // let starTime = this.newTime;
        // if(endTime - starTime >= this.loseDate * 1000){;
        //     this.handleAlertExceedDate();
        //     this.isExceedDate = true;
        // }else {
            
        // }

        this.isExceedDate = false;
        initDataExamination({
            recordId : this.recordId,
        }).then(result => {
            if (result.isSuccess) {
                this.examination = result.examination;
                this.trainingTaskName = result.examination.Name;
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

            this.isShowSpinner = false;
            
        }).catch(error => {
            this.isShowSpinner = false;
            this.isShowQuestion = false;
            console.log('wwwwwconnectedCallback error' + JSON.stringify(error));
            // if (error.isSuccess) {
            //     this.dispatchEvent(new ShowToastEvent({);
            //     this.dispatchEvent(new ShowToastEvent({
            //         title: 'error',
            //         message: result.msg,
            //         variant: 'error',
            //         // mode: "sticky"
            // }));
            // const closeModal = new CustomEvent('closeModal');
            // this.dispatchEvent(closeModal);
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
        const closeModal = new CustomEvent('close');
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

        console.log('WWWWsubmit questionAnswerMap' + JSON.stringify(this.questionAnswerMap));
        console.log('WWWWsubmit examination' + JSON.stringify(this.examination));
        
        saveDataExamination({
            questionAnswerMap : this.questionAnswerMap,
            examination : this.examination,
        }).then(result => {
            console.log('WWWWsubmit result' + JSON.stringify(result));
            if (result.isSuccess) {
                this.dispatchEvent(new ShowToastEvent({
                    title: 'success',
                    message: result.msg,
                    variant: 'success',
                    // mode: "sticky"
                }));
                const closeModal = new CustomEvent('closeModal');
                this.dispatchEvent(closeModal);

                // 关闭页面
                this.labelMsg = 'Submitted successfully';
                this.isExceedDate = true;
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
            console.log('WWWWsubmit error' + JSON.stringify(error));
            this.isShowSpinner = false;
        });
        // 关闭页面
        // window.close();
        // window.location.href = 'lightning/page/home';
    }   
}