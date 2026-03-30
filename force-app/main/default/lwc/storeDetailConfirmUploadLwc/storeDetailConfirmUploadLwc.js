import { LightningElement, api, track } from 'lwc';
import { LightningNavigationElement } from 'c/lwcUtils'
import {ShowToastEvent} from 'lightning/platformShowToastEvent';
import saveStoreDetailConfirmFile from '@salesforce/apex/SampleDisplayController.saveStoreDetailConfirmFile';
import searchSampleDisplay from '@salesforce/apex/SampleDisplayDetailsController.searchSampleDisplay';
import saveStoreDetail from '@salesforce/apex/SampleDisplayDetailsController.saveStoreDetail';
import verifyStoreDetailsNumber from '@salesforce/apex/SampleDisplayDetailsController.verifyStoreDetailsNumber';
import storeDetailsSubmit from '@salesforce/apex/SampleDisplayDetailsController.storeDetailsSubmit';
import LightningConfirm from 'lightning/confirm';
import Store_Detail_Submit_Tips from '@salesforce/label/c.Store_Detail_Submit_Tips';
import Store_Details_Number_Verify from '@salesforce/label/c.Store_Details_Number_Verify';

export default class StoreDetailConfirmUploadLwc extends LightningNavigationElement {
    @api recordId;

    @track showImport = false;
    @track objectLoad = 'Store Detail';
    @track isHaveFile = false;
    @track fileName = '';
    @track showLoadingSpinner = false;
    @track filesUploaded = [];

    @track sampleDisplay;
    @track productModel;
    @track showNew = false;
    @track showSubmit = false;

    @track storeId;
    @track numberData = 1;
    @track priorityData = false;

    get acceptedType() {
        return ['.csv'];
    }

    label = {
        Store_Detail_Submit_Tips,       // 提交提示信息
        Store_Details_Number_Verify,    // 校验拆分数量与任务数量相等
    }

    clearData(){
        this.fileName = '';
        this.filesUploaded = [];
        this.storeId = '';
        this.numberData = 1;
        this.priorityData = false;
    }

    connectedCallback(){
        console.log('wwwwww-recordId--'  + this.recordId);
        this.clearData();

        // 查询父级基本信息
        searchSampleDisplay({ 
            recordId : this.recordId,
        })
        .then(result => {
            if(result){
                this.sampleDisplay = result.sampleDisplay;
                this.productModel = result.productModel;
                this.showSubmit = result.showSubmit;
            }
        })
        .catch(error => {
        });;
    }

    handleImport(){
        this.showImport = true;
        this.fileName = '';
        this.isHaveFile = false;
        this.filesUploaded = [];

        // 绑定键盘ESC按键
        var parentThis = this;
        document.onkeyup = function (event) {
            var e = event || window.event;
            var keyCode = e.keyCode || e.which;
            switch (keyCode) {
                case 27:
                    parentThis.showImport = false;
                    document.onkeyup = null;
                    break;
                default:
                    break;
            }
        }
    }

    // submit页面
    async handleConfirm() {
        const result = await LightningConfirm.open({
            message: "Are you sure to submit the task?",
            theme: "success",
            label: "Submit for Approval",
        });
        if(result){
            // 审批下一步
            storeDetailsSubmit({ 
                recordId : this.recordId,
            })
            .then(result => {
                if(result.isSuccess){
                    this.showSubmit = result.showSubmit;
                    this.showSuccess('Sample Display was approved.');
                    // 刷新页面
                    const closeModal = new CustomEvent('closeModal');
                    this.dispatchEvent(closeModal);
                }else {
                    this.showError('Approval failure.');
                }
            })
            .catch(error => {
                this.showError('Approval failure.');
            });;

        }
    }

    handleSubmit(){
        this.showLoadingSpinner = true;
        // 验证拆分数量是否与任务数量相等
        verifyStoreDetailsNumber({
            recordId: this.recordId,
        }).then(result => {
            if(result.isSuccess){
                this.handleConfirm();
                this.showLoadingSpinner = false;
            }else {
                this.showError(result.msg);
                this.showLoadingSpinner = false;
            }
            this.showSubmit = result.showSubmit;
        }).catch(error => {
            this.showLoadingSpinner = false;
            console.log('wwww---' + JSON.stringify(error));
        })
    }

    handleNew() {
        this.showNew = true;
        this.clearData();
        // 绑定键盘ESC按键
        var parentThis = this;
        document.onkeyup = function (event) {
            var e = event || window.event;
            var keyCode = e.keyCode || e.which;
            switch (keyCode) {
                case 27:
                    parentThis.showNew = false;
                    document.onkeyup = null;
                    break;
                default:
                    break;
            }
        }
    }

    closeNewModal() {
        this.showNew = false;
        this.clearData();
    }


    handleFilesChange(event) {
        if(event.target.files.length > 0) {
            this.filesUploaded = event.target.files;
            this.fileName = event.target.files[0].name;
            this.isHaveFile = true;
        }
    }

    handleSave() {
        if(this.filesUploaded.length > 0) {
            this.file = this.filesUploaded[0];
            if (this.file.size > this.MAX_FILE_SIZE) {
                window.console.log('File is too large');
                return ;
            }
            this.showLoadingSpinner = true;
            this.fileReader= new FileReader();

            this.fileReader.onloadend = (() => {
                this.fileContents = this.fileReader.result;
                let base64 = 'base64,';
                this.content = this.fileContents.indexOf(base64) + base64.length;
                this.fileContents = this.fileContents.substring(this.content);
                this.saveToFile();
            });
            this.fileReader.readAsDataURL(this.file);

        }
        else {
            this.isHaveFile = false;
            this.fileName = 'Select a csv file to import';
        }
    }

    saveToFile() {
        saveStoreDetailConfirmFile({
            recordId: this.recordId,
            productModel: this.sampleDisplay.Product_Model__c,
            fileName: this.fileName,
            base64Data: encodeURIComponent(this.fileContents)
        }).then(result => {
            this.uploadResult(result);
        }).catch(error => {
            this.uploadResultError(error);
        })
    }

    uploadResult(result){
        this.showLoadingSpinner = false;

        if(result.isSuccess){
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Success!!',
                    message: this.fileName + ' - Upload successfully! ' + result.msg,
                    variant: 'success',
                    mode : 'sticky'
                }),
            );
            this.showImport = false;
            const closeModal = new CustomEvent('closeModal');
            this.dispatchEvent(closeModal);
        }else {
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'error',
                    message: result.msg,
                    variant: 'error',
                    mode : 'sticky'
                }),
            );
            window.open(result.errorUrl); 
        }
    }

    uploadResultError(error){
        this.showLoadingSpinner = false;
        this.dispatchEvent(
            new ShowToastEvent({
                title: 'Upload failure',
                message: error.message,
                variant: 'error',
                mode : 'sticky'
            }),
        );
    }

    back(){
        this.showImport = false;
        const closeModal = new CustomEvent('closeModal');
        this.dispatchEvent(closeModal);
        document.onkeyup = null;
    }

    handleCloseDialog(){
        this.back();
    }

    handleStoreChange(event){
        console.log('wwwww-----' + event.target.value);
        this.storeId = event.target.value;
    }

    handleNumberChange(event){
        console.log('wwwww-----' + event.target.value);
        this.numberData = event.target.value;
    }

    handlePriorityChange(event){
        console.log('wwwww-----' + event.target.value);
        this.priorityData = event.target.value;
    }

    handleCustomerDetailChange(event){
        this.customerDetailId = event.target.value;
        if(!this.judgeFieldValueEmpty(this.customerDetailId)){
            this.podNumber = 0;
            let allNumber = this.judgeFieldValueEmpty(this.customerDetailMap[this.customerDetailId]) ? 0 : this.customerDetailMap[this.customerDetailId];
            let partNumber = this.judgeFieldValueEmpty(this.storeDetailMap[this.customerDetailId]) ? 0 : this.storeDetailMap[this.customerDetailId];
            this.podNumber = allNumber - partNumber;
        }
    }

    handleSaveStoreDetail(){
        this.handleSaveBefore(false);
    }

    handleSaveAndNew(){
        this.handleSaveBefore(true);
    }

    handleSaveBefore(flag){
        // 验证必填项
        if(this.judgeFieldValueEmpty(this.numberData) || this.judgeFieldValueEmpty(this.storeId)){
            this.showError("Please fill in the required fields!");
            return;
        }

        this.saveStoreDetail(flag);
    }

    saveStoreDetail(flag){
        this.showLoadingSpinner = true;
        saveStoreDetail({ 
            recordId : this.recordId,
            productModel : this.sampleDisplay.Product_Model__c,
            storeId : this.storeId,
            numberData : this.numberData,
            priorityData : this.priorityData,
        })
        .then(result => {
            if(result.isSuccess){
                this.showSuccess('Save successfully!');
                if(flag){
                    this.clearData();
                }else {
                    this.showNew = false;
                }
                const closeModal = new CustomEvent('closeModal');
                this.dispatchEvent(closeModal);
            }else {
                this.showError(result.errorMsg);
            }
            this.showLoadingSpinner = false;
        })
        .catch(error => {
            this.showNew = false;
            this.showLoadingSpinner = false;
            this.showError('Save failure!');
        });;
    }

    // 为空验证
	judgeFieldValueEmpty(fieldValue){
        if(fieldValue == undefined || fieldValue == null || fieldValue == "") {
            return true;
        }else{
            return false;
        }
    }
}