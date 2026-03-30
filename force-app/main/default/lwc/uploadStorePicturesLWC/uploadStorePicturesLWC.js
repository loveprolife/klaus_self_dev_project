import { track, api, wire } from 'lwc';
import {LightningNavigationElement} from 'c/lwcUtils'
import { getObjectInfo } from 'lightning/uiObjectInfoApi';
import ACCOUNT_OBJECT from '@salesforce/schema/Task';
import FORM_FACTOR from '@salesforce/client/formFactor';
import spinner from '@salesforce/resourceUrl/spinner';
import LightningConfirm from 'lightning/confirm';
import saveObject from '@salesforce/apex/uploadStorePicturesController.saveObject';
import delObject from '@salesforce/apex/uploadStorePicturesController.delObject';
import getPicMsg from '@salesforce/apex/uploadStorePicturesController.getPicMsg';
import Store_Pic_Tip from '@salesforce/label/c.Store_Pic_Tip';
import Store_Pic_Head from '@salesforce/label/c.Store_Pic_Head';


export default class uploadStorePicturesLWC extends LightningNavigationElement {

	@api recordId;

	@api versionIdField;
	@api contentBodyIdField;
    // @api publicLinkField;
    @api fileTypeField;
    
	@api fileType;
    @api versionId;
	@api contentBodyId;
	@api isImgManagement;

	@track isDelShow = false;
	@track isShowEditViewCus = false;
	imageUrl = '';

	@track isShowSpinner = false;

	@track docment_id = '';
	isUpdate = false;
	Store_Pic_Tip = Store_Pic_Tip;
	Store_Pic_Head = Store_Pic_Head;
	get acceptedFormats() {
        return ['.jpg', '.png','.jpge','.bmp'];
    }



	connectedCallback() {
		if (this.versionId!='' && this.contentBodyId!='' && this.fileType!='') {
			this.imageUrl = "/sfc/servlet.shepherd/version/renditionDownload?rendition=thumb240by180&versionId=" + this.versionId + "&operationContext=CHATTER&contentId=" + this.contentBodyId;
			this.isDelShow = true;
		}
		if (this.isImgManagement != undefined) {this.isShowEditViewCus = true;}
		if (this.isImgManagement == undefined) { this.isShowEditViewCus = false; this.preview();}
	}

	deleteClick(){
		this.isShowSpinner = true
		if (this.versionId!='' && this.contentBodyId!='' && this.fileType!='') {
			delObject({
	            id : this.recordId,
	            versionIdField : this.versionIdField,
	            contentBodyIdField : this.contentBodyIdField,
	            fileTypeField : this.fileTypeField,
	            contentVersionId : this.versionId,
	        }).then(result => {
	            console.log('result:'+JSON.stringify(result));
	            if (result.isSuccess) {
	            	this.showSuccess('success');
	            	this.refreshRecords(this.recordId);
	            	this.goToRecord(this.recordId);
	            }else{
	            	this.showError(result.message);
	            	this.isShowSpinner = false
	            }
	            
	        }).catch(error => {
	            this.showError('系统发送错误：'+JSON.stringify(error));
	        });
		}
	}


	handleUploadFinished(event) {
        // Get the list of uploaded files
        const uploadedFiles = event.detail.files;
        this.docment_id = uploadedFiles[0].documentId;
        console.log('uploadedFiles:'+JSON.stringify(uploadedFiles));
        console.log('No. of files uploaded : ' + uploadedFiles.length);
        console.log('this.versionId==='+this.versionId)
        this.isUpdate = (this.versionId != '' && this.versionId != null && this.versionId != undefined) ? true : false;
        if (uploadedFiles.length==1) {
        	saveObject({
	            id : this.recordId,
	            versionIdField : this.versionIdField,
	            contentBodyIdField : this.contentBodyIdField,
	            fileTypeField : this.fileTypeField,
	            documentId : uploadedFiles[0].documentId,
	            contentVersionId : uploadedFiles[0].contentVersionId,
	            contentBodyId : uploadedFiles[0].contentBodyId,
	            name : uploadedFiles[0].name,
	            isUpdate : this.isUpdate
	        }).then(result => {
	            console.log('result:'+JSON.stringify(result));
	            if (result.isSuccess) {
	            	this.showSuccess('success');
	            	this.refreshRecords(this.recordId);
	            	this.goToRecord(this.recordId);
	            }else{
	            	this.showError(result.message);
	            }
	        }).catch(error => {
	            this.showError('系统发送错误：'+JSON.stringify(error));
	        });
        }else{
        	this.showError('只能上传一张图片！');
        }

        
        
    }

    cancelClick(event) {
        this.goToRecord(this.recordId);
    }

    preview() {
    	if (this.versionId == null || this.versionId == '' || this.versionId == undefined) return;
    	getPicMsg({contentVersionId : this.versionId }).then(res=>{
    		if (res.isSuccess) {
    			this.filePreview(res.data.documentId);
    		}else{
    			this.showError('系统发送错误：'+res.message);
    		}
    	}).catch(error=>{
    		this.showError('系统发送错误：'+JSON.stringify(error));
    	})
    }

}