/*
 * @Author: WFC
 * @Date: 2024-04-30 15:53:12
 * @LastEditors: WFC
 * @LastEditTime: 2024-06-20 14:23:50
 * @Description: 
 * @FilePath: \HisenseAll20240426\force-app\main\default\lwc\fileViewLwc\fileViewLwc.js
 */
import { api, track, wire  } from 'lwc';
import { LightningNavigationElement } from 'c/lwcUtils'
import getTrainingTaskAttachedDocuments from '@salesforce/apex/UploadVideoController.getTrainingTaskAttachedDocuments';
import saveFileViewDetail from '@salesforce/apex/UploadVideoController.saveFileViewDetail';
import { refreshApex } from '@salesforce/apex';
import LightningConfirm from 'lightning/confirm';

export default class FileViewLwc extends LightningNavigationElement {
    @api recordId;
    @api saveObjectName;
    @api saveObjectNameTotal;
    @api allowDownload;
    @api saveLog;
    @track showDetail = false;

    @track wiredAccountList = [];
    @track fileInfoList;
    @track fileInfoListSize;
    @track showPicture = false;
    @track contentDocumentId = '';
    @track contentDocumentType = '';
    @track contentVersionId = '';
    
    @track isDoc = false;
    @track isEXCEL = false;
    @track isTEXT = false;
    @track isJPG = false;
    @track isPNG = false;
    @track isCSV = false;
    @track isPDF = false;
    @track isPPT = false;
    @track isMP4 = false;
    @track isUnkown = false;

    @wire(getTrainingTaskAttachedDocuments, { recordId: "$recordId"}) 
    getDocuments(result) {
        this.wiredAccountList = result;
        if (result.data) {
            this.fileInfoList = result.data.fileInfoList;
            this.fileInfoListSize = result.data.fileInfoList.length;
        }  
    }

    connectedCallback() {
        this.clearFileType();
        if(this.saveLog == undefined || this.saveLog == '' || this.saveLog == null){
            this.saveLog = true;
        }
    }

    clearFileType(){
        this.isDoc = false;
        this.isEXCEL = false;
        this.isTEXT = false;
        this.isJPG = false;
        this.isPNG = false;
        this.isCSV = false;
        this.isPDF = false;
        this.isPPT = false;
        this.isMP4 = false;
        this.isUnkown = false;
    }

    refreshFileBox(event){
        refreshApex(this.wiredAccountList);
    }

    showFileDetail(event){
        this.clearFileType();

        const contentDocumentId = event.currentTarget.dataset.id;
        const contentDocumentTitle = event.currentTarget.dataset.text;
        const contentDocumentType = event.currentTarget.dataset.type;
        const contentVersionId = event.currentTarget.dataset.versionId;
        
        console.log('wwwww-contentDocumentType--' + contentDocumentType);
        console.log('wwwww--contentVersionId-' + contentVersionId);
        if(contentDocumentType.indexOf('jpg') !== -1 || contentDocumentType.indexOf('png') !== -1 || contentDocumentType.indexOf('mp4') !== -1){
            this.isJPG = true;
        }else if(contentDocumentType.indexOf('doc') !== -1 
                    || contentDocumentType.indexOf('pdf') !== -1 
                    || contentDocumentType.indexOf('xls') !== -1 
                    || contentDocumentType.indexOf('ppt') !== -1
                    || contentDocumentType.indexOf('txt') !== -1){
            this.isDoc = true;
        }
        
        
        this.contentDocumentId = contentDocumentId;
        this.contentDocumentType = contentDocumentType;
        this.contentVersionId = contentVersionId;
        this.showPicture = true;
       
        // 保存查看详细信息
        if(this.saveLog){
            saveFileViewDetail({
                saveObjectName: this.saveObjectName,
                saveObjectNameTotal: this.saveObjectNameTotal,
                recordId : this.recordId,
                contentDocumentId : contentDocumentId,
                contentDocumentTitle : contentDocumentTitle,
            })
        }
        
    }

    // 关闭放大的图片
    closeView(event){
        let closeFlag = event.detail.closeFlag;
        if(closeFlag){
            this.showPicture = false;
        }
        
    }

    async handleDownload(event) {
        const contentVersionId = event.currentTarget.dataset.versionId;
        const downloadResult = await LightningConfirm.open({
            message: 'Are you sure you want to download this file?',
            variant: 'header',
            label: 'Download File',
            theme: 'green'
        });
        if (downloadResult) {
            this.handleOk(contentVersionId);
        }
    }

    handleOk(contentVersionId) {
        window.open('/sfc/servlet.shepherd/version/download/' + contentVersionId)
    }
}