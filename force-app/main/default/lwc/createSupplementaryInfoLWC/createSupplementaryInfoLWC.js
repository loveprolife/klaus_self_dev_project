/*
 * @Author: Rain
 * @Date: 2022-04-24 15:45:09
 * @LastEditors: WFC
 * @LastEditTime: 2022-08-03 15:10:00
 * @Description: 
 */
import { LightningElement, track, api } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { NavigationMixin } from 'lightning/navigation';
import { getRecordNotifyChange } from 'lightning/uiRecordApi';
import submitRecords from '@salesforce/apex/CreateSupplementaryInfoController.submitRecords';
import getAttendanceByDate from '@salesforce/apex/CreateSupplementaryInfoController.getAttendanceByDate';
import saveSucessful from '@salesforce/label/c.SaveSucessful';
import shopName from '@salesforce/label/c.ShopName';
import cancle from '@salesforce/label/c.Cancle';
import signIn from '@salesforce/label/c.SignIn';
import signOut from '@salesforce/label/c.SignOut';
import signApply from '@salesforce/label/c.SignApply';
import signDate from '@salesforce/label/c.SignDate';
import signType from '@salesforce/label/c.SignType';
import signInfoForm from '@salesforce/label/c.SignInfoForm';
import signTypeSelect from '@salesforce/label/c.SignTypeSelect';
import Retroactive_Date from '@salesforce/label/c.Retroactive_Date';

export default class CreateSupplementaryInfoLWC extends NavigationMixin(LightningElement) {
    @track data = [];
    @track signInShop;
    @track signInTime;
    @track checkInBoxFieldValue = false;
    @track checkOutBoxFieldValue = false;
    @track selectedDate;
    @track recordDetail = {};
    @track isSignInrequired = true;
    @track isSignOutrequired = false;

    label = {
        saveSucessful,
        shopName,
        cancle,
        signIn,
        signOut,
        signApply,
        signDate,
        signType,
        signInfoForm,
        signTypeSelect,
        Retroactive_Date // 补签限定日期
    }

    get dateOptions() {
        // var temp1 = new Date();
        // var temp2 = new Date(temp1);
        // var temp3 = new Date(temp1);
        // var temp4 = new Date(temp1);
        // var temp5 = new Date(temp1);
        // var temp6 = new Date(temp1);
        // var temp7 = new Date(temp1);
        // temp2.setDate(temp2.getDate() - 1);
        // temp3.setDate(temp3.getDate() - 2);
        // temp4.setDate(temp4.getDate() - 3);
        // temp5.setDate(temp5.getDate() - 4);
        // temp6.setDate(temp6.getDate() - 5);
        // temp7.setDate(temp7.getDate() - 6);

        // var reg = new RegExp('/', 'g');
        // var dateStr1 = temp1.toLocaleDateString().replace(reg,'-');
        // var dateStr2 = temp2.toLocaleDateString().replace(reg,'-');
        // var dateStr3 = temp3.toLocaleDateString().replace(reg,'-');
        // var dateStr4 = temp4.toLocaleDateString().replace(reg,'-');
        // var dateStr5 = temp5.toLocaleDateString().replace(reg,'-');
        // var dateStr6 = temp6.toLocaleDateString().replace(reg,'-');
        // var dateStr7 = temp7.toLocaleDateString().replace(reg,'-');
    
        // return [
        //     { label: dateStr1, value: dateStr1 },
        //     { label: dateStr2, value: dateStr2 },
        //     { label: dateStr3, value: dateStr3 },
        //     { label: dateStr4, value: dateStr4 },
        //     { label: dateStr5, value: dateStr5 },
        //     { label: dateStr6, value: dateStr6 },
        //     { label: dateStr7, value: dateStr7 }
        // ]
        
        var num = parseInt(this.label.Retroactive_Date);
        var reg = new RegExp('/', 'g');
        var temp = new Date();
        var timeDate = [];
        console.log(num);
        for (let i = 0; i < num; i++) {
            var option = {};
            var temp1 = new Date(temp);
            temp1.setDate(temp1.getDate() - i);
            var dateStr1 = temp1.toLocaleDateString().replace(reg,'-');
            option['label'] = dateStr1;
            option['value'] = dateStr1;
            timeDate.push(option);
        }

        return timeDate;
    }

    connectedCallback() {
        var reg = new RegExp('/', 'g');
        var today = new Date().toLocaleDateString();
        this.selectedDate = today.replace(reg,'-');
        this.recordDetail["selectedDate"] = this.selectedDate;
        console.log(this.today);
    }
    
    dateChange(event) {
        this.recordDetail["selectedDate"] = event.target.value;
        this.selectedDate = event.target.value;
        //todo check所选时间是否已经有补签
    }

    handleSignInCBChange(event) {
        this.recordDetail["checkInBoxFieldValue"] = event.target.checked;
        this.checkInBoxFieldValue = event.target.checked;
    }

    handleSignOutCBChange(event){
        this.recordDetail["checkOutBoxFieldValue"] = event.target.checked;
        this.checkOutBoxFieldValue = event.target.checked;
    }

    handleFiledChange(event) {
        var changeValue = event.target.value;
        var fieldName = event.target.name;
        this.recordDetail[fieldName] = changeValue;
    }

    handleSubmit() {
        console.log("this.recordDetail: " + JSON.stringify(this.recordDetail));
        var canSaveRecord = true;
        this.template.querySelectorAll('lightning-input-field').forEach(element => {
            if(!element.reportValidity()) {
                canSaveRecord = false;
            }
        });
        if(!canSaveRecord) {
            this.isShowSpinner = false;
            return;
        }
        if(this.recordDetail.checkInBoxFieldValue == true || this.recordDetail.checkOutBoxFieldValue == true) {
            submitRecords({reordJson : JSON.stringify(this.recordDetail)})
            .then(result => {
                console.log("result: " + JSON.stringify(result));
                if(result.errorMsg != undefined && result.errorMsg != null && result.errorMsg != "") {
                    this.showNotification("", result.errorMsg ,"error");
                } else {
                    getRecordNotifyChange([{recordId: result.attendanceId}]);
                    this[NavigationMixin.Navigate]({
                        type: 'standard__recordRelationshipPage',
                        attributes: {
                            recordId: result.attendanceId,
                            objectApiName: 'Promoter_Attendance__c',
                            relationshipApiName: 'AttendanceMBRS__r',
                            actionName: 'view'
                        },
                    });
                    this.showNotification("", this.label.saveSucessful, "success");
                }
            })
            .catch(error => {
                this.showNotification("", JSON.stringify(error) ,"error");
            });
        } else {
            this.showNotification("", this.label.signTypeSelect ,"error");
        }
        
    }

    handleClose() {
        var reg = new RegExp('/', 'g');
        var today = new Date().toLocaleDateString().replace(reg,'-');
        getAttendanceByDate({subjectDate : today})
            .then(result => {
                if(result) {
                    this[NavigationMixin.Navigate]({
                        type: 'standard__recordRelationshipPage',
                        attributes: {
                            recordId: result,
                            objectApiName: 'Promoter_Attendance__c',
                            relationshipApiName: 'AttendanceMBRS__r',
                            actionName: 'view'
                        },
                    });
                }
            })
            .catch(error => {
                this.showNotification("", JSON.stringify(error) ,"error");
            });
    }

    showNotification(title, message, variant) {
        const evt = new ShowToastEvent({
            title: title,
            message: message,
            variant: variant,
        });
        this.dispatchEvent(evt);
    }
    
}