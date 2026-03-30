/*
 * @Author: WFC
 * @Date: 2024-04-08 16:41:24
 * @LastEditors: WFC
 * @LastEditTime: 2024-05-10 13:22:48
 * @Description: 
 * @FilePath: \HisenseAll20240426\force-app\main\default\lwc\qrcodeLwc\qrcodeLwc.js
 */
import { LightningElement, api, track } from 'lwc';
import { loadScript } from 'lightning/platformResourceLoader';
import qrcodejs from '@salesforce/resourceUrl/qrcodejs';

import TrainingTaskEvaluateSiteUrl from '@salesforce/label/c.TrainingTaskEvaluateSiteUrl';
import Training_Tasks_Evaluate_Title from '@salesforce/label/c.Training_Tasks_Evaluate_Title';

var timeIntervalInstance;
export default class QrcodeLwc extends LightningElement {
    
    @api recordId // 主数据id
    @track qrcodeURL; // 二维码地址
    @track showDate;
    @track endDate;
    @track failureTime = 60 * 60 * 24;// 失效时间（秒）

    @track label = {
        TrainingTaskEvaluateSiteUrl, // 培训任务考评站点
        Training_Tasks_Evaluate_Title, // 扫码后进行评分
    };

    connectedCallback() {
        loadScript(this, qrcodejs)
        .then(() => {
           this.Refresh();      
        })
        .catch(error => {
            console.error('Error loading qrcodejs library', error);
        });
        
    }

    timeDifference(starTime, endTime){
        if(endTime < starTime){
            this.showDate = '二维码已过期';
            clearInterval(timeIntervalInstance);
            const showDate = this.template.querySelector('.showDate');
            showDate.classList.add('slds-text-color_error');
            return;
        }
        let secondTime = Math.round((endTime - starTime) / 1000);// 秒
        let minuteTime = 0; // 分
        let hourTime = 0; // 时
        if (secondTime > 60) {
            //如果秒数大于60，将秒数转换成整数
            //获取分钟，除以60取整，得到整数分钟
            minuteTime = parseInt(secondTime / 60);
            //获取秒数，秒数取余，得到整数秒数
            secondTime = parseInt(secondTime % 60);
            //如果分钟大于60，将分钟转换成小时
            if (minuteTime > 60) {
                //获取小时，获取分钟除以60，得到整数小时
                hourTime = parseInt(minuteTime / 60);
                //获取小时后取余的分，获取分钟除以60取余的分
                minuteTime = parseInt(minuteTime % 60);
            }
        }
        //若秒数是个位数，前面用0补齐
        secondTime = secondTime < 10 ? "0" + secondTime : secondTime;
        var result = "" + secondTime + "";
        if (minuteTime > 0) {
            //若分钟数是个位数，前面用0补齐
            minuteTime = minuteTime < 10 ? "0" + minuteTime : minuteTime;
            result = "" + minuteTime + ":" + result;
        } else {
            //若分钟数为0，用"00"表示
            result = "" + "00" + ":" + result;
        }
    
        if (hourTime > 0) {
            //若小时数是个位数，前面用0补齐
            hourTime = hourTime < 10 ? "0" + hourTime : hourTime;
            result = "" + hourTime + ":" + result;
        } else {
            //若小时数为0，用"00"表示
            result = "" + "00" + ":" + result;
        }
        this.showDate = result;
        return result;
    }
  

    // 生成二维码
    generateQRCode(width, height, divClass) {
        const qrcodeContainer = this.template.querySelector(divClass);
        this.qrcodeURL = this.label.TrainingTaskEvaluateSiteUrl + '?id=' + this.recordId + '&newTime=' + Date.now() + '&loseDate=' + this.failureTime;
        var qrCode = new QRCode(qrcodeContainer, {
            text: this.qrcodeURL,
            width: width,
            height: height
        });
    }

    Refresh(){
        const qrcodeContainer = this.template.querySelector('.qrcode-container');
        qrcodeContainer.innerHTML = ""
        this.generateQRCode(460, 460, '.qrcode-container');
        // 刷新时间
        clearInterval(timeIntervalInstance);
        const showDate = this.template.querySelector('.showDate');
        showDate.classList.remove('slds-text-color_error');

        this.endDate = new Date();
        this.endDate.setSeconds(this.endDate.getSeconds() + this.failureTime);
        var parentThis = this;
        timeIntervalInstance = setInterval(() => {
            let starDate = new Date();
            this.timeDifference(starDate ,parentThis.endDate);
        }, 1000);
    }

    handleClose(){
        const closeModal = new CustomEvent('closeModal');
        this.dispatchEvent(closeModal);
    }
}