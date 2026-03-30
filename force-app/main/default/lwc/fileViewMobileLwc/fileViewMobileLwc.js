/*
 * @Author: WFC
 * @Date: 2024-05-06 17:08:29
 * @LastEditors: WFC
 * @LastEditTime: 2024-06-20 14:38:19
 * @Description: 
 * @FilePath: \HisenseAll20240426\force-app\main\default\lwc\fileViewMobileLwc\fileViewMobileLwc.js
 */
import { api, track, wire  } from 'lwc';
import { LightningNavigationElement } from 'c/lwcUtils'
import getTrainingTaskAttachedDocuments from '@salesforce/apex/UploadVideoController.getTrainingTaskAttachedDocuments';
import saveFileViewDetail from '@salesforce/apex/UploadVideoController.saveFileViewDetail';
import { refreshApex } from '@salesforce/apex';

export default class FileViewMobileLwc extends LightningNavigationElement {
    @api recordId;
    @api saveObjectName;
    @api saveObjectNameTotal;
    @api allowDownload;
    @api saveLog;
    @track showDetail = false;

    @track wiredAccountList = [];
    @track fileInfoList;
    @track fileInfoListSize;

    @wire(getTrainingTaskAttachedDocuments, { recordId: "$recordId"}) 
    getDocuments(result) {
        this.wiredAccountList = result;
        if (result.data) {
            this.fileInfoList = result.data.fileInfoList;
            this.fileInfoListSize = result.data.fileInfoList.length;
        }  
    }

    connectedCallback() {
        if(this.saveLog == undefined || this.saveLog == '' || this.saveLog == null){
            this.saveLog = true;
        }
    }

    refreshFileBox(event){
        refreshApex(this.wiredAccountList);
    }

    showFileDetail(event){
        const contentDocumentId = event.currentTarget.dataset.id;
        const contentDocumentTitle = event.currentTarget.dataset.text;

        this.goToRecord(contentDocumentId);
        
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

    handleClickDownload(event){
        const contentVersionId = event.currentTarget.dataset.id;
        window.open('/sfc/servlet.shepherd/version/download/' + contentVersionId)
    }
}