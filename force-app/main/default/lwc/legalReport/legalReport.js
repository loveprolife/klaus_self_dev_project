/*
 * @Author: WFC
 * @Date: 2022-10-31 10:45:35
 * @LastEditors: WFC
 * @LastEditTime: 2024-06-04 16:37:44
 * @Description: 
 * @FilePath: \HisenseAll20240426\force-app\main\default\lwc\legalReport\legalReport.js
 */
import { LightningElement, api } from 'lwc';
import {ShowToastEvent} from 'lightning/platformShowToastEvent';
import Legal_Report_Template_Download from '@salesforce/label/c.Legal_Report_Template_Download';
import Legal_Report_Template_Download_Tips from '@salesforce/label/c.Legal_Report_Template_Download_Tips';
import 	Legal_Report_Template_Download_URL from '@salesforce/label/c.Legal_Report_Template_Download_URL';
export default class FileUploadSample extends LightningElement {
    @api recordId;

    label = {
        Legal_Report_Template_Download,
        Legal_Report_Template_Download_Tips,
        Legal_Report_Template_Download_URL,
    }

    get acceptedFormats() {
        return ['.csv','.png','.jpg','.jfif','.jpeg','.pjp','.pjpeg','.gif','.elsx','.xls','.pdf','.txt','.docx'];
    }

    // 手机端
    get isMobile() {
        var userAgent = navigator.userAgent;
        if (/iphone|iPhone|ipad|iPad|ipod|iPod|iOS|ios/.test(userAgent) || /android|Android/.test(userAgent)) {  
            return true;
        } else { 
            return false;
        }
    }

    handleUploadFinishedEvent(event) {
        const uploadedFiles = event.detail.files;
        let uploadedFilesName = uploadedFiles.map(element => element.name);
        let uploadedFileNamesStr = uploadedFilesName.join(',');

        this.dispatchEvent(
            new ShowToastEvent({
                title: '',
                message: uploadedFiles.length + ' Files uploaded Successfully: ' + uploadedFileNamesStr,
                variant: 'success',
            }),
        );

        const closeModal = new CustomEvent('closeModal');
        this.dispatchEvent(closeModal);
        
    }

    handleCancel(){
        const closeModal = new CustomEvent('closeModal');
        this.dispatchEvent(closeModal);
    }


}