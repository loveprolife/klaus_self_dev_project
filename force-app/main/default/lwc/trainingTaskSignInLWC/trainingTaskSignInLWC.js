/*
 * @Author: WFC
 * @Date: 2023-06-14 13:33:18
 * @LastEditors: WFC
 * @LastEditTime: 2023-08-09 17:59:19
 * @Description: 
 * @FilePath: \Hitest_2022\force-app\main\default\lwc\trainingTaskSignInLWC\trainingTaskSignInLWC.js
 */
import { LightningElement, api, track, wire } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import checkTrainingTaskTime from '@salesforce/apex/TrainingExaminationController.checkTrainingTaskTime';
import setSignInTime from '@salesforce/apex/TrainingExaminationController.setSignInTime';
import Sign_In_Success from '@salesforce/label/c.Sign_In_Success';
import Sign_In_Failed from '@salesforce/label/c.Sign_In_Failed';
import Training_Date from '@salesforce/label/c.Training_Date';
import Current_Time from '@salesforce/label/c.Current_Time';
import Signed_In from '@salesforce/label/c.Signed_In';
import No_Sign_In from '@salesforce/label/c.No_Sign_In';

var timeIntervalInstance;
export default class TrainingTaskSignInLWC extends NavigationMixin(LightningElement) {
    label = {
        Sign_In_Success, // 签到成功！
        Sign_In_Failed, // 签到失败！
        Training_Date, // 培训日期
        Current_Time, // 当前时间
        Signed_In, // 已签到！
        No_Sign_In, // 当前时间未在培训签到范围内！
    }

    @api recordId;

    @track showPage = false;
    @track nowDate;
    @track isCanSignIn = true;
    @track isHaveSignIn = false;
    @track trainingTaskTime;
    @track trainingTaskTimeCheck;// 培训时间与签到规定时间
    @track trainingTaskTimeDate;// 培训时间年月日
    @track isShowSpinner;// 遮罩
    // @wire(checkTrainingTaskTime, { recordId: "$recordId" })
    // getDocuments({ error, data }) {
    //     if(data){
    //         this.isCanSignIn = data.isCanSignIn;
    //         this.isHaveSignIn = data.isHaveSignIn;
    //         this.trainingTaskTime = data.trainingTaskTime;
    //     }
        
    // }

    disconnectedCallback(){
        clearInterval(timeIntervalInstance);
    }

    connectedCallback(){
        this.isShowSpinner = false;
        checkTrainingTaskTime({
            recordId : this.recordId,
        }).then(result => {
            if (result.isSuccess) {
                this.showPage = true;
                this.isCanSignIn = result.isCanSignIn;
                this.isHaveSignIn = result.isHaveSignIn;
                this.trainingTaskTime = result.trainingTaskTime;
                this.trainingTaskTimeCheck = result.trainingTaskTimeCheck;
                this.trainingTaskTimeDate = result.trainingTaskTimeDate;
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
           // todo
        });

        var todayTime = new Date().toLocaleTimeString();
        this.nowDate = this.getNowFormatDate + ' ' + todayTime;
        var parentThis = this;
        timeIntervalInstance = setInterval(function() {
            var todayTime = new Date().toLocaleTimeString();
            parentThis.nowDate = parentThis.getNowFormatDate + ' ' + todayTime;
            if(parentThis.nowDate >= parentThis.trainingTaskTimeCheck && parentThis.getNowFormatDate == parentThis.trainingTaskTimeDate){
                parentThis.isCanSignIn = true;
            }
        }, 1000);
    }

    signIn(event){
        this.isShowSpinner = true;
        setSignInTime({
            recordId : this.recordId,
        }).then(result => {
            this.isShowSpinner = false;
            if (result.isSuccess) {
                this.dispatchEvent(new ShowToastEvent({
                    title: 'success',
                    message: this.label.Sign_In_Success, // '签到成功！',
                    variant: 'success',
                    // mode: "sticky"
                }));
                const closeModal = new CustomEvent('closeModal');
                this.dispatchEvent(closeModal);
            }else{
                this.dispatchEvent(new ShowToastEvent({
                    title: 'error',
                    message: this.label.Sign_In_Failed, // '签到失败！',
                    variant: 'error',
                    // mode: "sticky"
                })); 
            }
        }).catch(error => {
            this.isShowSpinner = false;
            this.dispatchEvent(new ShowToastEvent({
                title: 'error',
                message: this.label.Sign_In_Failed, // '签到失败！',
                variant: 'error',
                // mode: "sticky"
            }));
        });
    }

    cancel(event){
        clearInterval(timeIntervalInstance);
        const closeModal = new CustomEvent('closeModal');
        this.dispatchEvent(closeModal);  
    }

    //获取当前日期函数
    get getNowFormatDate(){
        let date = new Date(),
        year = date.getFullYear(), //获取完整的年份(4位)
        month = date.getMonth() + 1, //获取当前月份(0-11,0代表1月)
        strDate = date.getDate() // 获取当前日(1-31)
        if (month < 10) month = `0${month}` // 如果月份是个位数，在前面补0
        if (strDate < 10) strDate = `0${strDate}` // 如果日是个位数，在前面补0
        return `${year}-${month}-${strDate}`
    }
}