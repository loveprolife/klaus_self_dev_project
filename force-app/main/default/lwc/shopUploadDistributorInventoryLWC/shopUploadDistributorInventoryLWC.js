import { LightningElement, track, api } from 'lwc';
import saveFile from '@salesforce/apex/ShopDistributorInventoryController.saveFile';
import {ShowToastEvent} from 'lightning/platformShowToastEvent';
import Training_Task_Cancel from '@salesforce/label/c.Training_Task_Cancel';

export default class ShopUploadDistributorInventoryLWC extends LightningElement {
    label = {
        Training_Task_Cancel, // 取消
    }

    @api recordId;
    @track isHaveFile = false;
    @track fileName = '';
    @track UploadFile = 'Upload File';
    @track showLoadingSpinner = false;
    filesUploaded = [];
    file;
    fileContents;
    fileReader;
    content;
    MAX_FILE_SIZE = 1500000;

    get acceptedType() {
        return ['.csv'];
    }

    handleFilesClick(){
        this.fileName = '';
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
                window.console.log('文件过大');
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
            this.isHaveFile = false;
        }
        else {
            this.fileName = '选择一个csv文件上传';
        }
    }


    saveToFile() {
        saveFile({ recordId: this.recordId, fileName: this.file.name, base64Data: encodeURIComponent(this.fileContents)})
        .then(result => {
            this.showLoadingSpinner = false;

            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Success!!',
                    message: this.fileName + ' - 上传成功',
                    variant: 'success',
                }),
            );
            const closeModal = new CustomEvent('closeModal');
            this.dispatchEvent(closeModal);
        })
        .catch(error => {
            this.showLoadingSpinner = false;
            this.dispatchEvent(
                new ShowToastEvent({
                    title: '上传失败',
                    message: error.message,
                    variant: 'error',
                }),
            );
        });
    }

    cancel(event){
        const closeModal = new CustomEvent('closeModal');
        this.dispatchEvent(closeModal);
    }
    
}