/*
 * @Author: Rain
 * @Date: 2022-04-20 22:46:01
 * @LastEditors: Rain
 * @LastEditTime: 2022-05-12 09:18:00
 * @Description: 
 */
import { LightningElement,api, track, wire } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { NavigationMixin } from 'lightning/navigation';
import { getRecordNotifyChange } from 'lightning/uiRecordApi';
import initData from '@salesforce/apex/MessageBoardCreateAndEditController.initData';
import saveRecord from '@salesforce/apex/MessageBoardCreateAndEditController.saveRecord';
import LEAV_MESSAGE from '@salesforce/label/c.LEAV_MESSAGE';
import LEAV_Theme from '@salesforce/label/c.LEAV_Theme';
import LEAV_ATTRIBUTE from '@salesforce/label/c.LEAV_ATTRIBUTE';
import SaveSucessful from '@salesforce/label/c.SaveSucessful';
import Cancle from '@salesforce/label/c.Cancle';
import Save from '@salesforce/label/c.Save';
import Message_New from '@salesforce/label/c.Message_New';
import Message_Edit from '@salesforce/label/c.Message_Edit';

export default class MessageBoardCreateAndEditLWC extends NavigationMixin(LightningElement) {
    @track objectApiName = "Shop_Message_Board__c";
    @api recordId;
    @track isShowSpinner = false;
    @track title;
    @track recordDetail = {};
    @track isShowDetail = false;

    label = {
        LEAV_MESSAGE,
        LEAV_Theme,
        LEAV_ATTRIBUTE,
        SaveSucessful,
        Cancle,
        Save,
        Message_New,
        Message_Edit
    }

    connectedCallback() {
        this.isShowSpinner = true;
        initData({recordId : this.recordId})
            .then(result => {
                if(result){
                    this.recordDetail = result;
                    this.isShowDetail = true;
                    if(this.recordId != null) {
                        this.title = Message_Edit + this.recordDetail.name;
                    } else {
                        this.title = this.label.Message_New;
                        this.recordDetail.isActive = "有效";
                    }
                }else{
                    this.recordDetail = {};
                    this.recordDetail.isActive = "有效";
                }
            })
            .catch(error => {
                this.showNotification("", JSON.stringify(error) ,"error");
            });
        this.isShowSpinner = false;
	}

    save() {
        this.isShowSpinner = true;
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
        console.log("detail: " + JSON.stringify(this.recordDetail));
        saveRecord({recordStr : JSON.stringify(this.recordDetail), recordId : this.recordId})
            .then(result => {
                if(result.isSuccess == true) {
                    this.isShowSpinner = false;
                    this.showNotification("", this.label.SaveSucessful, "success");
                    this.dispatchEvent(new CustomEvent('onRefresh'));
                    getRecordNotifyChange([{recordId: result.recordId}]);
                    this.toDetailPage("standard__recordPage",this.objectApiName,"view",result.recordId);
                    // var url = '/lightning/r/Shop_Message_Board__c/' + result.recordId + '/view';
                    // window.open(url);
                }else {
                    this.isShowSpinner = false;
                    this.showNotification("", result.errorMsg,"error");
                }

            })
            .catch(error => {
                this.isShowSpinner = false;
                console.log(JSON.stringify(error));
                this.showNotification("", JSON.stringify(error) ,"error");
            });  
    }

    cancel() {
        if(this.recordId) {
            this.toDetailPage("standard__recordPage",this.objectApiName,"view",this.recordId);
        } else {
            this[NavigationMixin.Navigate]({
                type: 'standard__objectPage',
                attributes: {
                    objectApiName: this.objectApiName,
                    actionName: 'list'
                },
                state: {
                    filterName: 'Recent'
                }
            });
        }
    }

    toDetailPage(type,objApiName,action,recordId) {
        this[NavigationMixin.Navigate]({
            type: type,
            attributes: {
                recordId: recordId,
                objectApiName: objApiName,
                actionName: action
            }
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

    changeValue(event) { 
        var changeValue = event.target.value;
        var fieldName = event.target.name;
        this.recordDetail[fieldName] = changeValue;
        // this.handleChangeValue(this.paymentTableDataTrackList, event.target.name, event.target.value, index);
    }

    validation(event) {
        const allValid = [
            ...this.template.querySelectorAll('lightning-input-field'),
        ].reduce((validSoFar, inputCmp) => {
            console.log("validSoFar: " + validSoFar);
            console.log("inputCmp: " + inputCmp);
            inputCmp.reportValidity();
            this.isShowSpinner = false;
            return validSoFar && inputCmp.checkValidity();
        }, true);
    }
}