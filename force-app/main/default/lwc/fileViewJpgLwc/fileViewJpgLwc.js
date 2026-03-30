/*
 * @Author: WFC
 * @Date: 2024-04-30 21:10:41
 * @LastEditors: WFC
 * @LastEditTime: 2024-05-15 09:28:41
 * @Description: 
 * @FilePath: \HisenseAll20240426\force-app\main\default\lwc\fileViewJpgLwc\fileViewJpgLwc.js
 */
import { api, track, wire } from 'lwc';
import { LightningNavigationElement } from 'c/lwcUtils'
import getFileDetail from '@salesforce/apex/UploadVideoController.getFileDetail';
import getBaseUrl from "@salesforce/apex/VideoViewerController.getBaseUrl";
import { getBaseVideoUrl } from "./utils";

export default class FileViewJpgLwc extends LightningNavigationElement {

    @api contentDocumentId;
    @api contentDocumentType;
    @api contentVersionId;
    @api showFileDownload;
    @api showFileDetail;
   
    @track fileSrc;
    @track fileTitle;
    @track fileDownloadSrc;

    @track currentVideoUrl = "";;

    @track isMP4 = false;
    @track muted = true;

    get width() {
        return window.screen.width * 0.8;
    }

    get height() {
        return window.screen.height * 0.8;
    }

    @wire(getBaseUrl)
    baseUrl;

    get baseVideoUrl() {
        return getBaseVideoUrl(this.baseUrl.data);
    }

    connectedCallback(){
        
        // 查询文件
        getFileDetail({
            contentDocumentId : this.contentDocumentId,
        }).then(data => {
            if(data.flag){
                this.fileSrc = "/sfc/servlet.shepherd/version/renditionDownload?versionId=" + data.contentVersion.Id + 
                "&operationContext=CHATTER&contentId=" + data.contentVersion.ContentBodyId + 
                "&rendition=ORIGINAL_" + data.contentVersion.FileType;

                this.fileTitle = data.contentVersion.Title
                this.fileDownloadSrc = data.contentVersion.VersionDataUrl

                if(this.contentDocumentType.indexOf('mp4') !== -1 ){
                    this.isMP4 = true;
                    this.currentVideoUrl = this.baseVideoUrl + this.contentDocumentId;
                }
            }
        }).catch(error => {
             
        });
    }

    get isShowDownload() {
        if(this.showFileDownload){
            return true;
        }else {
            return false;
        }

    }

    get isShowDetail() {
        if(this.showFileDetail){
            return true;
        }else {
            return false;
        } 
    }

    handleDownload(event){
        window.open(this.fileDownloadSrc)
    }

    handleDetails(event){
        this.goToRecord(this.contentDocumentId);
    }

    handleClose(event){
        const oEvent = new CustomEvent("closeview", {
			detail: {
				closeFlag: true
			}
		});
		this.dispatchEvent(oEvent);
    }

    handleMenu(event){
        if(!this.showFileDownload){
            this.showWarning('No permission to download');
            event.preventDefault();
        }
    }
}