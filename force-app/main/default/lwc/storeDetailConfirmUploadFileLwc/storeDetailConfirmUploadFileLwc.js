import { LightningElement, api, track, wire } from 'lwc';
import { LightningNavigationElement, FileHandle } from 'c/lwcUtils';
import getPictureList from '@salesforce/apex/TrainingController.getPictureList';
import storeDetailUploadFile from '@salesforce/apex/SampleDisplayController.storeDetailUploadFile';
import saveAdditionalInformation from '@salesforce/apex/SampleDisplayController.saveAdditionalInformation';
import { loadStyle, loadScript } from 'lightning/platformResourceLoader';
import {registerRefreshHandler, unregisterRefreshHandler } from "lightning/refresh";
import uploadFiles from '@salesforce/resourceUrl/uploadFiles';

export default class StoreDetailConfirmUploadFileLwc extends LightningNavigationElement {

    @api recordId;

    @track fileInfoListSize;
    @track pictureList = [];
    @track wiredAccountList = [];
    // 点击小图片，放大标记
    @track showPicture = false;
    // 大图片src地址
    @track shopPictureSrc = '';
    // 大图片ContentDocumentId
    @track shopPictureId = '';

    // 弹出新增或者替换选项
    @track showNewOrAdd = false;
    @track addOrReplace = '';
    @track replaceModel = '';
    @track showReplaceModel = false;
    
    get acceptedFormats() {
        return ['.jpg','.jpeg','.png','.bmp','.pjpeg'];
    }

    connectedCallback() {
        loadStyle(this, uploadFiles).then(()=>{
            this.showNewOrAdd = false;
            this.addOrReplace = '';
            this.replaceModel = '';
            this.showReplaceModel = false;
        }).catch((error) => {
            
        });
        this.getPictureList();
    }

    handleUploadFinished(event){
        // 上传成功后更改状态
        storeDetailUploadFile({
            recordId: this.recordId,
        }).then(data => {
            if(data.isSuccess){
                // 弹出新增或者替换选项
                if(data.objectName == 'Sample_Display_Confirm__c'){
                    this.showNewOrAdd = true;
                }else {
                    const closeModal = new CustomEvent('closeModal');
                    this.dispatchEvent(closeModal);
                }
                this.getPictureList();
            }else {
                this.showError('Save failure!');
            }
        }).catch(error => {
            this.showError('Save failure!');
        });
    }

    getPictureList(){
        this.pictureList = [];
        getPictureList({
            recordId: this.recordId,
        }).then(data => {
            if(data){
                // 处理数据
                data.forEach((d) => {
                    let picture = {};
                    picture['src'] = "/sfc/servlet.shepherd/version/renditionDownload?rendition=thumb240by180&versionId=" + d.Id + "&operationContext=CHATTER&contentId=" + d.ContentBodyId;
                    picture['show'] = "/sfc/servlet.shepherd/version/renditionDownload?rendition=ORIGINAL_" + d.FileType + "&versionId=" + d.Id + "&operationContext=CHATTER&contentId=" + d.ContentBodyId;
                    picture['id'] = d.ContentDocumentId;
                    this.pictureList.push(picture);
                });
                this.fileInfoListSize = data.length;
            }
        }).catch(error => {
             
        });
    }

    handleViewPhotoClick(ele) {
        this.showPicture = true;
        this.shopPictureSrc = ele.target.dataset.show;
        this.shopPictureId = ele.target.dataset.id;

        // this.filePreview(ele.target.dataset.id);

        // 绑定键盘ESC按键
        var parentThis = this;
        document.onkeyup = function (event) {
            var e = event || window.event;
            var keyCode = e.keyCode || e.which;
            switch (keyCode) {
                case 27:
                    parentThis.showPicture = false;
                    parentThis.shopPictureSrc = '';
                    parentThis.shopPictureId = '';
                    break;
                default:
                    break;
            }
        }
    }

    // 关闭放大的图片
    handleClosePicture(event){
        this.showPicture = false;
        this.shopPictureSrc = '';
        this.shopPictureId = '';
    }

    handleAddReplaceChange(event){
        this.addOrReplace = event.target.value;
        this.replaceModel = '';
        if( this.addOrReplace == 'Replace'){
            this.showReplaceModel = true;
        }else {
            this.showReplaceModel = false;
        }
    }

    handleReplaceModelChange(event){
        this.replaceModel = event.target.value;
    }

    handleAddReplaceSave(){
        // 验证必填
        if(this.judgeFieldValueEmpty(this.addOrReplace)){
            this.showError("Please fill in the required fields!");
            return;
        }
        if(this.addOrReplace == 'Replace' && this.judgeFieldValueEmpty(this.replaceModel)){
            this.showError("Please fill in the required fields!");
            return;
        }
        // 保存附加信息
        saveAdditionalInformation({
            recordId: this.recordId,
            addOrReplace: this.addOrReplace,
            replaceModel: this.replaceModel,
        }).then(data => {
            if(data){
                this.showSuccess('Save successfully!');
                this.showNewOrAdd = false;
                this.addOrReplace = '';
                this.replaceModel = '';
                this.showReplaceModel = false;
                const closeModal = new CustomEvent('closeModal');
                this.dispatchEvent(closeModal);
            }else {
                this.showError('Save failure!');
            }
            
        }).catch(error => {
            this.showError('Save failure!');
        });

    }

    // 为空验证
	judgeFieldValueEmpty(fieldValue){
        if(fieldValue == undefined || fieldValue == null || fieldValue == "") {
            return true;
        }else{
            return false;
        }
    }

}