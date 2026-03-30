import { LightningElement, api, track } from 'lwc';
import { LightningNavigationElement, FileHandle } from 'c/lwcUtils';
import saveCustomerDetail from '@salesforce/apex/SampleDisplayDetailsController.saveCustomerDetail';
import searchSampleDisplay from '@salesforce/apex/SampleDisplayDetailsController.searchSampleDisplay';

export default class SampleDisplayPONewLwc extends LightningNavigationElement {

    @api recordId;
    @track sampleDisplay; // 一级任务信息
    @track productModel; // 产品
    @track customerName; // 客户

    @track isModalOpen = false;
    @track showLoadingSpinner = false;
    @track isSaving = false;

    @track customerId;
    @track numberData;
    @track addressData;
    @track isHaveFile = false;
    @track fileName = '';
    @track filesUploaded;

    @track imageUrl;

    get acceptedType() {
        return ['.jpg','.jpeg','.png','.bmp','.pjpeg'];
    }

    clearData(){
        this.customerId = '';
        this.numberData = '';
        this.addressData = '';
        this.isHaveFile = false;
        this.fileName = '';
        this.filesUploaded = '';
        this.isSaving = false;
    }


    openModal() {
        this.isModalOpen = true;
        this.clearData();

        // 查询父级基本信息
        searchSampleDisplay({ 
            recordId : this.recordId,
        })
        .then(result => {
            if(result){
                this.sampleDisplay = result.sampleDisplay;
                this.productModel = result.productModel;
                this.customerName = result.customerName;
                this.customerId = result.customerId;
            }
            this.showLoadingSpinner = false;
        })
        .catch(error => {
            this.showLoadingSpinner = false;
        });;
    }

    closeModal() {
        this.isModalOpen = false;
        this.clearData();
    }

    handleNumberChange(event){
        console.log('wwwww-----' + event.target.value);
        this.numberData = event.target.value;
    }

    handleAddressChange(event){
        console.log('wwwww-----' + event.target.value);
        this.addressData = event.target.value;
    }

    connectedCallback(){
        console.log('wwwwww---recordId---'  + this.recordId);
        this.clearData();
    }

    handleFilesChange(event) {
        if(event.target.files.length > 0) {
            this.filesUploaded = event.target.files[0];
            this.fileName = event.target.files[0].name;
            this.isHaveFile = true;
            const file = event.target.files[0]; // 获取上传的文件
            if (file) {
                const reader = new FileReader(); // 创建文件读取器
                reader.onloadend = () => {
                    this.imageUrl = reader.result; // 将读取结果设置为 imageUrl
                };
                reader.readAsDataURL(file); // 将文件读取为数据 URL
            }
        }
    }

    handleSave(){
        //验证必填字段
        if(this.judgeFieldValueEmpty(this.addressData) || this.judgeFieldValueEmpty(this.numberData) || !this.isHaveFile){
            this.showError("Please fill in the required fields!");
            return;
        }

        if (this.filesUploaded && !this.isSaving) {
            this.showLoadingSpinner = true;
            this.isSaving = true;
            const reader = new FileReader();
            reader.readAsDataURL(this.filesUploaded); // 将文件读取为 Data URL

            reader.onloadend = async () => {
                const base64Data = reader.result.split(',')[1]; // 提取 Base64 数据
                
                const result = await saveCustomerDetail({ 
                    recordId : this.recordId,
                    productModel : this.sampleDisplay.Product_Model__c,
                    customerId : this.customerId,
                    numberData : this.numberData,
                    addressData : this.addressData,
                    fileName: this.fileName, 
                    base64Data 
                })
                .then(result => {
                    if(result.isSuccess){
                        setTimeout(() => {
                            this.showSuccess('Save successfully!');
                            this.isModalOpen = false;
                            this.showLoadingSpinner = false;
                            const closeModal = new CustomEvent('closeModal');
                            this.dispatchEvent(closeModal);
                        }, 1000);
                    }else {
                        this.showError(result.errorMsg);
                        this.showLoadingSpinner = false;
                    }
                    this.isSaving = false;
                })
                .catch(error => {
                    this.showLoadingSpinner = false;
                    this.isSaving = false;
                    this.showError('Save failure!');
                });;
            };
        }

    }

    handleSaveAndNew(){
        //验证必填字段
        if(this.judgeFieldValueEmpty(this.customerId) || this.judgeFieldValueEmpty(this.numberData) || !this.isHaveFile){
            this.showError("Please fill in the required fields!");
            return;
        }

        if (this.filesUploaded && !this.isSaving) {
            this.showLoadingSpinner = true;
            this.isSaving = true;
            const reader = new FileReader();
            reader.readAsDataURL(this.filesUploaded); // 将文件读取为 Data URL

            reader.onloadend = async () => {
                const base64Data = reader.result.split(',')[1]; // 提取 Base64 数据
                
                const result = await saveCustomerDetail({ 
                    recordId : this.recordId,
                    productModel : this.sampleDisplay.Product_Model__c,
                    customerId : this.customerId,
                    numberData : this.numberData,
                    fileName: this.fileName, 
                    base64Data 
                })
                .then(result => {
                    if(result.isSuccess){
                        setTimeout(() => {
                            this.showSuccess('Save successfully!');
                            this.clearData();
                            this.showLoadingSpinner = false;
                            const closeModal = new CustomEvent('closeModal');
                            this.dispatchEvent(closeModal);
                        }, 1000);
                    }else {
                        this.showError(result.errorMsg);
                        this.showLoadingSpinner = false;
                    }
                    this.isSaving = false;
                })
                .catch(error => {
                    this.showLoadingSpinner = false;
                    this.isSaving = false;
                    this.showError('Save failure!');
                });;
            };
        }

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