/*
 * @Author: WFC
 * @Date: 2025-05-26 13:57:49
 * @LastEditors: WFC
 * @LastEditTime: 2025-05-26 14:18:15
 * @Description: 
 * @FilePath: \HiTest20250422\force-app\main\default\lwc\legalReportAccount\legalReportAccount.js
 */
import { LightningElement, api } from 'lwc';
import { LightningNavigationElement } from 'c/lwcUtils'
import Legal_Report_Template_Download from '@salesforce/label/c.Legal_Report_Template_Download';
import Legal_Report_Template_Download_Tips from '@salesforce/label/c.Legal_Report_Template_Download_Tips';
import Legal_Report_Template_Download_URL from '@salesforce/label/c.Legal_Report_Template_Download_URL';

export default class LegalReportAccount extends LightningNavigationElement {
    @api recordId;

    label = {
        Legal_Report_Template_Download,
        Legal_Report_Template_Download_Tips,
        Legal_Report_Template_Download_URL,
    }

    get acceptedFormats() {
        return ['.csv','.png','.jpg','.jfif','.jpeg','.pjp','.pjpeg','.gif','.elsx','.xls','.pdf','.txt','.docx'];
    }

    handleUploadFinishedEvent(event) {
        const uploadedFiles = event.detail.files;
        let uploadedFilesName = uploadedFiles.map(element => element.name);
        let uploadedFileNamesStr = uploadedFilesName.join(',');

        this.showSuccess(uploadedFiles.length + ' Files uploaded Successfully: ' + uploadedFileNamesStr);

        const closemodal = new CustomEvent('closemodal');
        this.dispatchEvent(closemodal);   
    }

    handleCancel(){
        const closemodal = new CustomEvent('closemodal');
        this.dispatchEvent(closemodal);
    }
}