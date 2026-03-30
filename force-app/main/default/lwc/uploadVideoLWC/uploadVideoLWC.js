/*
 * @Author: WFC
 * @Date: 2023-06-12 10:06:52
 * @LastEditors: WFC
 * @LastEditTime: 2023-07-10 14:08:14
 * @Description: 
 * @FilePath: \Hitest_2022\force-app\main\default\lwc\uploadVideoLWC\uploadVideoLWC.js
 */
import { LightningElement, api, track  } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { NavigationMixin } from 'lightning/navigation';
import saveData from '@salesforce/apex/UploadVideoController.saveData';
import verifyPublication from '@salesforce/apex/UploadVideoController.verifyPublication';

export default class UploadVideoLWC extends NavigationMixin(LightningElement){
    @api recordId;

    @track showPage = false;

    get acceptedFormats() {
        return ['.mp4','.webm','.mov','.m4v'];
    }

    connectedCallback() {
        // 验证是否培训是否发布
        verifyPublication({
            recordId : this.recordId,
        }).then(result => {
            if (result.isSuccess) {
                this.showPage = true;
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
            
        });

    }

    handleUploadFinishedEvent(event) {
        const uploadedFiles = event.detail.files;
        let uploadedFilesName = uploadedFiles.map(element => element.name);
        let uploadedFileNamesStr = uploadedFilesName.join(',');

        this.dispatchEvent(
            new ShowToastEvent({
                title: 'success',
                message: uploadedFiles.length + ' Files uploaded Successfully: ' + uploadedFileNamesStr,
                variant: 'success',
            }),
        );

        const closeModal = new CustomEvent('closeModal');
        this.dispatchEvent(closeModal);

        saveData({
            recordId : this.recordId,

        }).then(result => {
            // window.location.reload();

        }).catch(error => {
            
        });
    }

    cancel(event){
        const closeModal = new CustomEvent('closeModal');
        this.dispatchEvent(closeModal);
    }
}