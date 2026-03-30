import { api, track } from 'lwc';
import { LightningNavigationElement } from 'c/lwcUtils'
import getFileDetail from '@salesforce/apex/UploadVideoController.getFileDetail';

export default class FileViewDocLwc extends LightningNavigationElement {
    @api contentDocumentId;
    @api contentDocumentType;
    @api contentVersionId;
    @api showFileDownload;
    @api showFileDetail;
   
    @track fileSrc;
    @track fileTitle;
    @track fileDownloadSrc;

    @track isDoc = false;
    @track isEXCEL = false;
    @track isTEXT = false;
    @track isPDF = false;
    @track isPPT = false;

    connectedCallback(){
        if(this.contentDocumentType.indexOf('doc') !== -1 ){
            this.isDoc = true;
        }else if(this.contentDocumentType.indexOf('pdf') !== -1 ){
            this.isPDF = true;
        }else if(this.contentDocumentType.indexOf('xls') !== -1 ){
            this.isEXCEL = true;
        }else if(this.contentDocumentType.indexOf('ppt') !== -1 ){
            this.isPPT = true;
        }else if(this.contentDocumentType.indexOf('txt') !== -1 ){
            this.isTEXT = true;
        }
        this.generateImgUrl();
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

    // List of all potential img urls
    @track imgUrls = [];
    // Page num used for tracking pages
    pageNum = 0;
    // Idicator when loading should be finished, because of failure
    loadFailed = false;

    handleImgLoadError(event) {
        // When onerror event is triggered on img element, then mark it and don't generate any new img urls
        this.loadFailed = true;
        this.imgUrls.pop();
    }

    handleImgLoadSuccess(event) {
        // When onload event is triggered on img element, then increase pageNum and try to render one more img
        this.pageNum++;
        this.generateImgUrl();
    }

    generateImgUrl() {

        // 查询文件
        getFileDetail({
            contentDocumentId : this.contentDocumentId,
        }).then(data => {
            if(data.flag){
                // this.fileSrc = "/sfc/servlet.shepherd/version/renditionDownload?versionId=" + data.contentVersion.Id + 
                // "&operationContext=CHATTER&contentId=" + data.contentVersion.ContentBodyId + 
                // "&rendition=SVGZ&page=0";

                this.fileTitle = data.contentVersion.Title
                this.fileDownloadSrc = data.contentVersion.VersionDataUrl

                let previewUrl = "/sfc/servlet.shepherd/version/renditionDownload?versionId=" + data.contentVersion.Id + 
                "&operationContext=CHATTER&contentId=" + data.contentVersion.ContentBodyId + 
                "&rendition=SVGZ&page=" + this.pageNum;

                this.imgUrls.push(previewUrl);
            }
        }).catch(error => {
             
        });
        
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