/*
 * @Author: WFC
 * @Date: 2024-04-08 10:28:54
 * @LastEditors: WFC
 * @LastEditTime: 2024-05-10 13:27:30
 * @Description: 
 * @FilePath: \HisenseAll20240426\force-app\main\default\lwc\trainingTaskEvaluateLwc\trainingTaskEvaluateLwc.js
 */
import { LightningElement, api, track, wire } from 'lwc';
import saveEvaluate from '@salesforce/apex/TrainingController.saveEvaluate';
import LightningAlert from 'lightning/alert';
// import getQuestions from '@salesforce/apex/TrainingController.getQuestions';

export default class TrainingTaskEvaluateLwc  extends LightningElement {

    @api recordId;
    @api newTime; // 二维码生成时间
    @api loseDate; // 失效时间（秒）

    @track surveyList = []; // 问题集合
    @track ratingMap = {}; // 得分map
    @track isCanSave = false; // 是否可以保存
    @track isShowSpinner = false; 
    @track isSubmited = false; // 是否已经提交

    @track isExceedDate = false; // 二维码是否失效

    // @wire(getQuestions)
    // getDocuments({ error, data }) {
    //     if(data){
    //         this.surveyList = data;
    //         for (var i = 0; i < data.length; i++) {
    //             this.ratingMap[i] = '';
    //         }
    //     }
    // }

    async handleAlertClickSuccess(message) {
        await LightningAlert.open({
            message: 'Save successfully',
            theme: 'success', 
            label: 'Success', // this is the header text
        });
    }

    async handleAlertClickError() {
        await LightningAlert.open({
            message: 'Save failure',
            theme: 'error', 
            label: 'Error!', // this is the header text
        });
    }

    async handleAlertClickWarning() {
        await LightningAlert.open({
            message: 'Please answer all question',
            theme: 'warning', 
            label: 'Warning!', // this is the header text
        });
    }

    async handleAlertExceedDate() {
        await LightningAlert.open({
            message: 'Qr code is invalid',
            theme: 'warning', 
            label: 'Warning!', // this is the header text
        });
    }

    connectedCallback(){
        this.surveyList.push('1.The course content is clear and clear, and the combination of cases, discussions, etc., is easier to understand.');
        this.surveyList.push('2.The course content meets my needs and is practical, which improves my knowledge level.');
        this.surveyList.push('3.Teaching ideas clear, strong expression ability.');
        this.surveyList.push('4.Good teaching style, adjust the classroom atmosphere to ensure full participation.');
        this.ratingMap[0] = '';
        this.ratingMap[1] = '';
        this.ratingMap[2] = '';
        this.ratingMap[3] = '';

        // 检测二维码是否失效
        let endTime = Date.now();
        let starTime = this.newTime;
        if(endTime - starTime >= this.loseDate * 1000){;
            this.handleAlertExceedDate();
            this.isExceedDate = true;
        }else {
            this.isExceedDate = false;
        }
    }

    handleRating(event){
        let index = event.target.dataset.index;
        let rating = event.target.rating;
        this.ratingMap[index] = rating;
        
        if(!this.isSubmited){
            this.isCanSave = this.verifyRating();
        }
    }

    verifyRating(){
        let flag = true;
        Object.keys(this.ratingMap).forEach(key => {
            if(this.ratingMap[key] == ''){
                flag = false;
            }
        });
        return flag;
    }

    saveEvaluate(){
        if(this.verifyRating()){
            this.isShowSpinner = true;
            saveEvaluate({
                recordId : this.recordId,
                ratingDataJson : JSON.stringify(this.ratingMap)
            }).then(result => {
                this.isShowSpinner = false;
                if(result){
                    // alert('Save successfully');
                    this.handleAlertClickSuccess();
                    // 保存成功后不能提交了
                    this.isSubmited = true;
                    this.isCanSave = false;
                }
            }).catch(error => {
                this.isShowSpinner = false;
                // alert('Save failure');
                this.handleAlertClickError();
            });
        }else {
            // alert('Please answer all question');
            this.handleAlertClickWarning();
        }
    }

}