import { track, api, wire } from 'lwc';
import { LightningNavigationElement } from 'c/lwcUtils';
import { CloseActionScreenEvent } from 'lightning/actions';

import getInitData from '@salesforce/apex/NewSamplingDetailController.getInitData';
import saveData from '@salesforce/apex/NewSamplingDetailController.saveRecord';
import selectDisplayType from '@salesforce/apex/NewSamplingDetailController.selectDisplayType';

export default class NewSamplingDetailLwc extends LightningNavigationElement {
    @api recordId;
    @track store = {};
    @track detail = {};
    @track isShowDisplayType = false;
    @track displayTypeValue = '';
    @track displayTypeOptions = [];
    @track isShowSpinner = false;

    connectedCallback() {
       this.detail.Shop__c = this.recordId;
       console.log('recordId：' + this.recordId);
       this.getInitData();
    }

    filterCountry = ['Hisense USA', 'Hisense Canada', 'Hisense Mexico'];

    async getInitData(){
        await getInitData({
            recordId: this.recordId,
        }).then(resp => {
            if (resp.isSuccess) {
                this.store = resp.data.Store;
                if(this.filterCountry.includes(this.store.Sales_Region__c + '')){
                    this.isShowDisplayType = true;
                }else {
                    this.isShowDisplayType = false;
                }
            }
        }).catch(error => {
            this.catchError(error);
        })
    }

    handleFieldChange(event) {
        this.detail[event.target.dataset.fieldName] = event.target.value;
        this.detail.isUpdated = true;
        // 更改产品，查询Display Type的数据
        if(event.target.dataset.fieldName == 'Product__c' && this.isShowDisplayType){
            this.displayTypeOptions = [];
            this.displayTypeValue = '';
            if(event.target.value != null && event.target.value != '' && event.target.value != undefined){
                this.selectDisplayType();
            }
        }
    }

    selectDisplayType(){
        selectDisplayType({
            shopId: this.recordId,
            productId: this.detail['Product__c'],
        }).then(resp => {
            if (resp.isSuccess) {
                let displayTypeList = resp.data.DisplayType;
                let op = [];
                for (let key in displayTypeList) {
                    let dt = {};
                    dt['label'] = displayTypeList[key];
                    dt['value'] = displayTypeList[key];
                    op.push(dt);
                }
                this.displayTypeOptions = op;
            }else {
                this.showError(resp.message);
            }
        }).catch(error => {
            this.catchError(error);
        })
    }

    handleChange(event){
        this.displayTypeValue = event.target.value;
    }


    cancelHandleClick(event) {
        console.log("cancel:");
        this.dispatchEvent(new CloseActionScreenEvent());
        this.dispatchEvent(new CustomEvent('closemodal'));
    }


    saveHandleClick(event) {
        // 验证必填
        this.isShowSpinner = true;
        var canSaveRecord = true;
        this.template.querySelectorAll('lightning-input-field').forEach(element => {
            if(!element.reportValidity()) {
                canSaveRecord = false;
            }
        });
        if(!canSaveRecord) {
            this.showError('Required fields are not filled in');
            this.isShowSpinner = false;
            return;
        }
        if((this.displayTypeValue == '' || this.displayTypeValue == null || this.displayTypeValue == undefined) && this.isShowDisplayType){
            this.showError('Required fields are not filled in');
            this.isShowSpinner = false;
            return;
        }
        this.detail['Display_Type__c'] = this.displayTypeValue;
        saveData({
            recordId: this.recordId,
            recordListJson: JSON.stringify(this.detail),
        }).then(resp => {
            if (resp.isSuccess) {
                this.showSuccess(resp.message);
                window.location.reload();
            }else {
                this.showError(resp.message);
            }
        }).catch(error => {
            this.catchError(error);
        })
        this.isShowSpinner = false;
    }

    handleKeyDown(event) {
        if (event.keyCode === 13) {
            event.preventDefault();
        }
    }

}