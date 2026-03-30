/*
 * @Author: WFC
 * @Date: 2023-07-27 11:04:34
 * @LastEditors: WFC
 * @LastEditTime: 2023-08-10 16:15:28
 * @Description: 
 * @FilePath: \Hitest_2022\force-app\main\default\lwc\trainingQuestionBanksUploadLWC\trainingQuestionBanksUploadLWC.js
 */
import { LightningElement, track, api } from 'lwc';
import saveQuestionBanksFile from '@salesforce/apex/TrainingExaminationController.saveQuestionBanksFile';
import {ShowToastEvent} from 'lightning/platformShowToastEvent';

export default class TrainingQuestionBanksUploadLWC extends LightningElement {
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

    connectedCallback(){
        
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

        }
        else {
            this.isHaveFile = false;
            this.fileName = '选择一个csv文件上传';
        }
    }


    saveToFile() {
        saveQuestionBanksFile({fileName: this.file.name, base64Data: encodeURIComponent(this.fileContents)})
        .then(result => {
            this.showLoadingSpinner = false;

            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Success!!',
                    message: this.fileName + ' - 上传成功',
                    variant: 'success',
                }),
            );
            this.filesUploaded = [];
            this.fileName = '';
            this.isHaveFile = false;
            window.history.go(-1);
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

    back(event){
        window.history.go(-1);
    }
}