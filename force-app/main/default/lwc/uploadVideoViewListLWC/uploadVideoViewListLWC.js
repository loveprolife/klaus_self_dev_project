/*
 * @Author: WFC
 * @Date: 2023-06-12 15:09:47
 * @LastEditors: WFC
 * @LastEditTime: 2023-06-28 16:43:58
 * @Description: 
 * @FilePath: \Hitest_2022\force-app\main\default\lwc\uploadVideoViewListLWC\uploadVideoViewListLWC.js
 */
import { LightningElement, api, track, wire  } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { NavigationMixin } from 'lightning/navigation';
import getAttachedDocuments from '@salesforce/apex/UploadVideoController.getAttachedDocuments';
import deleteFile from '@salesforce/apex/UploadVideoController.deleteFile';
import { refreshApex } from '@salesforce/apex';

export default class UploadVideoViewListLWC extends NavigationMixin(LightningElement) {
    @api recordId;

    @track show;
    @track deleteFileId;
    @track isShowSpinner = false;
    @track wiredAccountList = [];
    @track fileInfoList;
    @track fileInfoListSize;



    @wire(getAttachedDocuments, { recordId: "$recordId" }) 
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

    refreshFileBox(event){
        refreshApex(this.wiredAccountList);
    }

    showDeleteFileBox(event){
        var selectedItem = event.currentTarget;
        var index = selectedItem.dataset.record;
        this.deleteFileId = index;
        this.show = true;
    }

    cancel(event){
        this.show = false;
    }

    deleteFile(event){
        this.isShowSpinner = true;
        deleteFile({
            deleteFileId : this.deleteFileId,
        }).then(result => {
            this.isShowSpinner = false;
            if(result.isSuccess){
                this.show = false;
                refreshApex(this.wiredAccountList);
                this.dispatchEvent(new ShowToastEvent({
                    title: 'success',
                    message: 'File was deleted.',
                    variant: 'success',
                }));
                // window.location.reload();
                // getAttachedDocuments({
                //     recordId : this.recordId,
                // }).then(result => {
                //     this.fileInfoList = result.fileInfoList;
                //     this.fileInfoListSize = result.fileInfoList.length;
                // }).catch(error => {
                //     //todo
                // });
            }
        }).catch(error => {
            this.isShowSpinner = false;
        });

    }

}