/*
 * @Author: WFC
 * @Date: 2023-06-28 14:35:11
 * @LastEditors: WFC
 * @LastEditTime: 2023-07-10 13:28:17
 * @Description: 
 * @FilePath: \Hitest_2022\force-app\main\default\lwc\trainingTaskUploadFilesViewListLWC\trainingTaskUploadFilesViewListLWC.js
 */
import { LightningElement, api, track, wire  } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { NavigationMixin } from 'lightning/navigation';
import getTrainingTaskAttachedDocuments from '@salesforce/apex/UploadVideoController.getTrainingTaskAttachedDocuments';
import saveCheckFileDetail from '@salesforce/apex/UploadVideoController.saveCheckFileDetail';
import { refreshApex } from '@salesforce/apex';

export default class TrainingTaskUploadFilesViewListLWC extends NavigationMixin(LightningElement) {
    @api recordId;

    @track wiredAccountList = [];
    @track fileInfoList;
    @track fileInfoListSize;



    @wire(getTrainingTaskAttachedDocuments, { recordId: "$recordId" }) 
    getDocuments(result) {
        this.wiredAccountList = result;
        if (result.data) {
            this.fileInfoList = result.data.fileInfoList;
            this.fileInfoListSize = result.data.fileInfoList.length;
        }  
    }

    connectedCallback() {
        // getAttachedDocuments({
        //     recordId : this.recordId,
        // }).then(result => {
        //     this.fileInfoList = result.fileInfoList;
        //     this.fileInfoListSize = result.fileInfoList.length;
        // }).catch(error => {
        //     //todo
        // });
    }

    @api
    refreshFileBox(event){
        refreshApex(this.wiredAccountList);
    }

    showFileDetail(event){
        const contentDocumentId = event.currentTarget.dataset.id;
        const title = event.currentTarget.dataset.text;
        const url = event.currentTarget.dataset.url;
        // 保存查看详细信息
        saveCheckFileDetail({
            recordId : this.recordId,
            contentDocumentId : contentDocumentId,
            contentDocumentTitle : title,
            contentDocumentUrl : url,
        }).then(result => {
            
        }).catch(error => {
            //todo
        })
    }
}