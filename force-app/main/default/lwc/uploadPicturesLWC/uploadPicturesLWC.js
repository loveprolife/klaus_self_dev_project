import { track, api, wire } from 'lwc';
import {LightningNavigationElement} from 'c/lwcUtils'
import { getObjectInfo } from 'lightning/uiObjectInfoApi';
import ACCOUNT_OBJECT from '@salesforce/schema/Task';
import FORM_FACTOR from '@salesforce/client/formFactor';
import spinner from '@salesforce/resourceUrl/spinner';
import LightningConfirm from 'lightning/confirm';
import saveObject from '@salesforce/apex/uploadPicturesController.saveObject';
import delObject from '@salesforce/apex/uploadPicturesController.delObject';

export default class uploadPicturesLWC extends LightningNavigationElement {

	@api recordId;

	@api versionIdField;
	@api contentBodyIdField;
    @api publicLinkField;
    @api fileTypeField;
    
	@api fileType;
    @api versionId;
	@api contentBodyId;

	@track isDelShow = false;
	imageUrl = '';

	@track isShowSpinner = false;

	get acceptedFormats() {
        return ['.jpg', '.png','.jpge','.bmp'];
    }



	connectedCallback() {
		if (this.versionId!='' && this.contentBodyId!='' && this.fileType!='') {
			this.imageUrl = "/sfc/servlet.shepherd/version/renditionDownload?rendition=thumb240by180&versionId=" + this.versionId + "&operationContext=CHATTER&contentId=" + this.contentBodyId;
			this.isDelShow = true;
		}
	}

	deleteClick(){
		this.isShowSpinner = true
		if (this.versionId!='' && this.contentBodyId!='' && this.fileType!='') {
			delObject({
	            id : this.recordId,
	            versionIdField : this.versionIdField,
	            publicLinkField : this.publicLinkField,
	            contentBodyIdField : this.contentBodyIdField,
	            fileTypeField : this.fileTypeField,
	            contentVersionId : this.versionId,
	        }).then(result => {
	            console.log('result:'+JSON.stringify(result));
	            if (result.isSuccess) {
	            	this.showSuccess('success');
	            	this.goToRecord(this.recordId);
	            }else{
	            	this.showError(result.message);
	            	this.isShowSpinner = false
	            }
	            
	        }).catch(error => {
	            this.dispatchEvent(new ShowToastEvent({
	                title: 'error',
	                message: '系统发送错误'+JSON.stringify(error),
	                variant: 'error',
	            }));
	        });
		}
	}


	handleUploadFinished(event) {
        // Get the list of uploaded files
        const uploadedFiles = event.detail.files;
        console.log('uploadedFiles:'+JSON.stringify(uploadedFiles));
        console.log('No. of files uploaded : ' + uploadedFiles.length);
        if (uploadedFiles.length==1) {
        	saveObject({
	            id : this.recordId,
	            versionIdField : this.versionIdField,
	            publicLinkField : this.publicLinkField,
	            contentBodyIdField : this.contentBodyIdField,
	            fileTypeField : this.fileTypeField,
	            documentId : uploadedFiles[0].documentId,
	            contentVersionId : uploadedFiles[0].contentVersionId,
	            contentBodyId : uploadedFiles[0].contentBodyId,
	            name : uploadedFiles[0].name,
	        }).then(result => {
	            console.log('result:'+JSON.stringify(result));
	            if (result.isSuccess) {
	            	this.showSuccess('success');
	            	this.goToRecord(this.recordId);
	            }else{
	            	this.showError(result.message);
	            }
	        }).catch(error => {
	            this.dispatchEvent(new ShowToastEvent({
	                title: 'error',
	                message: '系统发送错误'+JSON.stringify(error),
	                variant: 'error',
	            }));
	        });
        }else{
        	this.dispatchEvent(new ShowToastEvent({
	                title: 'error',
	                message: '只能上传一张图片',
	                variant: 'error',
	            }));
        }

        
        
    }

    cancelClick(event) {
        this.goToRecord(this.recordId);
    }

}