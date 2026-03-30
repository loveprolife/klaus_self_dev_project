import { track, api, wire } from 'lwc';
import { LightningNavigationElement, FileHandle } from 'c/lwcUtils';
import getFiles from '@salesforce/apex/UploadFilesController.getFileOne';
import UPLOAD_FILE from '@salesforce/apex/UploadFilesController.uploadFile';
import deleteFiles from '@salesforce/apex/UploadFilesController.deleteFiles';
import deleteCaches from '@salesforce/apex/UploadFilesController.deleteCaches';
import FORM_FACTOR from '@salesforce/client/formFactor';
import { loadStyle, loadScript } from 'lightning/platformResourceLoader';
import uploadFiles from '@salesforce/resourceUrl/uploadFiles';
import compress from '@salesforce/resourceUrl/compress';
import spinner from '@salesforce/resourceUrl/spinner';
import { createRecord } from 'lightning/uiRecordApi';
import USER_ID from '@salesforce/user/Id';
import SpinnerAlt from '@salesforce/label/c.SpinnerAlt';
import FileSizeGreaterThan4M from '@salesforce/label/c.FileSizeGreaterThan4M';
import FileNoMoreThan5 from '@salesforce/label/c.FileNoMoreThan5';
import Loading from '@salesforce/label/c.Loading';
import Uploading from '@salesforce/label/c.Uploading';
import CompressLoadFailed from '@salesforce/label/c.CompressLoadFailed';

export default class UploadFiles4Lwc extends LightningNavigationElement {

    @api sizeOpen;
    lwcName = 'UploadFiles4Lwc';
    isShowSpinner;
    customLabel = {
        SpinnerAlt,
        FileSizeGreaterThan4M,
        FileNoMoreThan5,
        Loading,
        Uploading,
        CompressLoadFailed
    };
    isBigFile;
    showBigFileCheck;
    @track records = [];
    @track cacheItems = [];
    @track newBigFileIds = [];
    @api recordIds = [];
    @api parentId;
    @api col = 0;
    @api disabledDelete;
    @api disabledUpload;
    @api removeDeleteSpace;
    @api cssStyle;
    @api sampleId;
    @track inspectionId;

    fileHandler;
    intervalHandler;
    compressImage;

    get allItems () {
        console.log('WWW打印一下实际图片个数' + this.sampleId +':'+ this.records.length);
        let arr = [];
        for (let index = 0; index < this.records.length; index++) {
            let item = {...this.records[index]};
            delete item.base64;
            arr.push(item);
        }
        return arr;
    }

    get spinnerSrc() {
        return spinner;
    }

    get attachId() {
        return this.recordId ? this.recordId : USER_ID;
    }

    get acceptedFormats() {
        return ['.pdf','.xls','.xlsx','.doc','.docx','.ppt','.pptx','.ofd','.zip','.rar'];
    }

    get isMobile() {
        return FORM_FACTOR === 'Small';
    }

    get colClass() {
        if (this.col == 1) {
            return 'slds-grid slds-col slds-large-size_12-of-12 slds-medium-size_12-of-12 slds-size_12-of-12';
        } else if (this.col == 2) {
            return 'slds-grid slds-col slds-large-size_6-of-12 slds-medium-size_6-of-12 slds-size_6-of-12';
        } else if (this.col == 3) {
            return 'slds-grid slds-col slds-large-size_4-of-12 slds-medium-size_4-of-12 slds-size_4-of-12';
        } else if (this.col == 4) {
            return 'slds-grid slds-col slds-large-size_3-of-12 slds-medium-size_3-of-12 slds-size_3-of-12';
        } else if (this.col == 5) {
            return 'slds-grid slds-col slds-large-size_3-of-12 slds-medium-size_3-of-12 slds-size_3-of-12';
        }else {
            return 'slds-grid slds-col slds-large-size_12-of-12 slds-medium-size_12-of-12 slds-size_12-of-12';
        }
    }

    get imgContainerClass() {
        return this.removeDeleteSpace ? 'slds-col slds-large-size_12-of-12 slds-medium-size_12-of-12 slds-size_12-of-12' : 'slds-col slds-large-size_11-of-12 slds-medium-size_11-of-12 slds-size_11-of-12'
    }

    doInit() {
        this.autoRefreshCacheStatus();
    }

    connectedCallback() {
        loadStyle(this, uploadFiles).then(()=>{
            
        }).catch((error) => {
            // console.log('456')
        });

        loadScript(this, compress).then(()=>{
            // this.compressImage = true;
            this.compressImage = false;
        }).catch((error) => {
            this.showWarning(this.customLabel.CompressLoadFailed)
        });
        
        this.fileHandler = new FileHandle();
        this.refresh();
    }

    disconnectedCallback() {
        this.intervalHandler = false;
    }

    base64toBlob(base64String, type) {
        const byteNumbers = new Array(base64String.length);
        for (let i = 0; i < base64String.length; i++) {
            byteNumbers[i] = base64String.charCodeAt(i);
        }
        const byteArray = new Uint8Array(byteNumbers);
        const blob = new Blob([byteArray], { type });
        return blob;
    }
    attachProperty(item) {
        let _this = this;
        Object.defineProperties(item, {
            "link": {
                get() {
                    return '/' + this.ContentDocumentId
                }
            },
            "iconName": {
                get() {
                    return _this.getIconName(this.FileType)
                }
            },
            "size": {
                get() {
                    return item.base64 ? item.base64.length * 0.75 : 0
                }
            },
            "src": {
                get() {
                    if (this.isImage && item.base64) {
                        return item.base64;
                    } else {
                        return this.imgSrc;
                    }
                    // return this.src + this.Description
                }
            },
            "imgSrc" : {
                get() {
                    return '/sfc/servlet.shepherd/version/renditionDownload?rendition=' 
                        + (_this.isMobile ? 'thumb120by90' : 'ORIGINAL_' + item.FileType ) 
                        + '&versionId=' + item.ContentVersionId
                        + '&operationContext=CHATTER&contentId=' + item.ContentBodyId;
                }
            },
            "style" : {
                get() {
                    // return 'width: 100%; min-width: 100px; min-height: 100px; cursor:pointer;';
                    return 'min-height: 100px; width: 20%; object-fit: cover;'
                    //return 'width:20px; height:20px; cursor:pointer;'; 
                }
            },
            "spinnerClass" : {
                get() {
                    return "spinnerClass_" + this.packageId + "_" + this.ContentVersionId;
                }
            },
            "spinnerStyle" : {
                get() {
                    let spinnerStyle = 'height: 100px; width: auto; cursor: pointer; position: absolute; z-index: 999; opacity: 0.8; background-position: center; background-repeat: no-repeat;';
                    // spinnerStyle += 'background-image: url(' + spinner + ');'
                    // spinnerStyle += (this.isSuccess ? 'display:none;' : '');
                    return spinnerStyle;
                }
            },
            "ShowSpinnerTips" : {
                get() {
                    return this.spinnerTips ? true : false;
                }
            },
            "isImage": {
                get() {
                    return _this.isImage(this.FileType)
                }
            }
        });

        return item;
    }

    autoRefreshCacheStatus() {
        let cacheFiles = this.fileHandler.getFiles();
        let noConversionPackageIds = [];
        for (let index = 0; cacheFiles && index < cacheFiles.length; index++) {
            if (cacheFiles[index] && cacheFiles[index].recordId === this.recordId && !cacheFiles[index].ContentVersionId) {
                let item = this.itemToContent(cacheFiles[index]);
                this.addToCaches(item);
                noConversionPackageIds.push(item.packageId);
            }
        }
        let e = this.template.querySelector('c-create-file-item-lwc');
        if (e) {
            e.newNeedUpload(noConversionPackageIds);
        }
        return;
        
    }

    handleCacheComplete(event) {

        let dataMap = event.detail.records;
        let packageIds = [];
        for (let index = 0; index < this.records.length; index++) {
            const element = this.records[index];
            if (dataMap[element.packageId] ) {
                element.isSuccess = true;
                if (dataMap[element.packageId].CompleteDateTime && !element.ContentVersionId) {
                    element.ContentBodyId = dataMap[element.packageId].ContentBodyId;
                    element.ContentDocumentId = dataMap[element.packageId].ContentDocumentId;
                    element.ContentVersionId = dataMap[element.packageId].ContentVersionId;
                }
                
                packageIds.push(element.packageId);
            }
        }

        if (packageIds.length > 0) {
            // this.showSuccess('complete items:' + packageIds);
        }
    }

    addToCaches(item) {
        // this.cacheItems.push(item);
        this.records.push(item);
        return this.records.length - 1;
    }
    @api
    refresh() {
        this.isShowSpinner = true;
        getFiles({
            recordId : this.recordId,
            recordIds : this.recordIds
        }).then(result => {
            if (result.isSuccess) {
                // for (let key in result.data) {
                //     this[key] = result.data[key];
                // }
                for (let index = 0;result.data && result.data.records && index < result.data.records.length; index++) {
                    result.data.records[index].ContentVersionId = result.data.records[index].Id;
                    result.data.records[index].isSuccess = true;
                    this.records.push(this.attachProperty(result.data.records[index]));
                }
                
            } else {
                this.showError(result.message);
            }
            this.isShowSpinner = false;
        }).catch(error => {
            this.isShowSpinner = false;
            this.catchError(error);
        })
        
    }

    @api
    files() {
        return this.allItems;
    }

    readFile(file) {
        // 获取上传图片的base64
        return new Promise(resolve => {
            // 文件读取
            var reader = new FileReader();
            reader.onload = (e) => {
                var base64 = e.target.result;
                resolve(base64);
            };
            reader.readAsDataURL(file);
        });
    }
    //handleBatchFileUpload
    handleBatchFileUpload(file){
        // var file = evnet.target.files[0];
        let arr = file.name.split('.');
        let type = (arr[arr.length - 1] + '').toUpperCase();
        if (!this.isImage(type) && file.size > 4 * 1024 * 1024 * 0.95) {
            this.showWarning(this.customLabel.FileSizeGreaterThan4M);
            this.isBigFile = this.showBigFileCheck = true;
            return;
        }
        let pack = {
            packageId : this.fileHandler.newPackageId(),
            recordId : this.recordId,
            userId : USER_ID,
            name : file.name,
            size : file.size,
            type : type,
            spinnerTips : this.customLabel.Loading
        };
        if (this.isImage(type)) {
            pack.base64 = spinner;
        }
        console.log('打印一下存储之前IDEX' + this.records.length);
        this.deleteIndex = 0;
        if(this.records.length > 0){this.handleDeleteFile(this.records[0]);  console.log('打印一下删除IDEX' + this.records.length);}
        let i = this.addToCaches(this.itemToContent(pack));
        console.log('打印一下存储IDEX' + i);
        console.log('打印一下存储之后IDEX' + this.records.length);
        (()=>{
            return this.compressImage ? handleFile(file, {
                callback : base64 => {
                    pack.base64 = this.records[i].base64 = base64;
                }
            }) :
            this.readFile(file)
        })().then(base64 => {
            //删除缓存
            // this.allItems.splice(i, 1);

            let mimeType = base64.substring(0, base64.indexOf('base64,')).replace('data:');
            pack.base64 = base64;
            let msg = this.fileHandler.split(pack);
            if (msg) {
                console.log('split error, ' + msg);
                this.records[i].spinnerTips = this.customLabel.Uploading
                // this.showWarning(msg);
                // 用js上传文件
                const recordInput = { 
                    apiName: 'ContentVersion', 
                    fields : {
                        "PathOnClient": file.name,
                        "Title": file.name.split('.')[0],
                        "VersionData": base64.substring(base64.indexOf('base64,') + 7),
                        "FirstPublishLocationId" : this.attachId
                    } 
                };
                
                createRecord(recordInput).then(newRecord => {
                    console.log(newRecord);
                    return getFiles({
                        recordIds: [newRecord.id]
                    })
                }).then(result => {
                    if (result.isSuccess && result.data && result.data.records && result.data.records[0]) {
                        this.handleCreateRecordFinished({
                            iconName : this.getIconName(type),
                            Title : file.name,
                            Id : result.data.records[0].Id,
                            packageId : pack.packageId,
                            ContentVersionId : result.data.records[0].Id,
                            ContentDocumentId: result.data.records[0].ContentDocumentId,
                            ContentBodyId : result.data.records[0].ContentBodyId,
                            FileType : type.toUpperCase(),
                            base64 : base64
                        });
                    }
                    
                }).catch(error => {
                    // Handle error
                    console.log(error);
                });
            } else {
                // this.showSuccess(this.customLabel.SpinnerAlt + '!');
                pack.spinnerTips = this.records[i].spinnerTips = this.customLabel.SpinnerAlt
                let e = this.template.querySelector('c-create-file-item-lwc');
                if (e) {
                    e.newNeedUpload([pack.packageId]);
                }
                this.handleSplitFileFinished({
                    ...pack,
                    "mimeType": this.fileHandler.getMimeType(base64)
                });
                
            }
        })
    }
    handleFileChanged(event) {
        let  files = event.target.files;
        if (files.length > 5) {
            this.showWarning(this.customLabel.FileNoMoreThan5);
            return;
        }
        console.log('上传.............');
        for (let i = 0; i < files.length; i++) {
            this.handleBatchFileUpload(files[i]);
        }
        
    }
  
  

    itemToContent(item) {
        let arr = item.name.split('.');
        let name = arr[0];
        let type = (arr[arr.length - 1] + '').toUpperCase();
        let content = {
            ...item,
            iconName : this.getIconName(type),
            Title : name,
            Id : item.contentVersionId ? item.contentVersionId : item.packageId,
            packageId : item.packageId,
            ContentDocumentId: item.documentId,
            ContentBodyId : item.contentBodyId,
            FileType : type.toUpperCase(),
            base64 : item.base64
        };
        this.attachProperty(content);
        // this.setItemStatus(content);
        return content
    }

    handleCreateRecordFinished(item) {
        // this.showSuccess(this.customLabel.SpinnerAlt);
        for (let index = 0; index < this.records.length; index++) {
            const element = this.records[index];
            if (element.packageId === item.packageId) {
                this.records[index] = this.attachProperty(item);
                this.records[index].isSuccess = true;
            }
        }
        // this.records.push(this.attachProperty(item));
        this.dispatchEvent(new CustomEvent('selectfiles',{
            detail: {
                records : this.allItems
            }
        }));
    }

    handleSplitFileFinished(item) {
        
        for (let index = 0; index < this.records.length; index++) {
            const element = this.records[index];
            if (element.packageId === item.packageId) {
                this.records[index] = this.itemToContent(item);
            }
        }
        // this.addToCaches(this.itemToContent(item));
        this.dispatchEvent(new CustomEvent('selectfiles',{
            detail: {
                records : this.allItems
            }
        }));
    }
    handleStandardUpload(file){
        const reader = new FileReader();
        reader.onloadend = () => {
            const base64String = reader.result;
            const fileBlob = this.base64toBlob(base64String, file.type);
            console.log('parentId',this.parentId);
            UPLOAD_FILE({ recordId: this.parentId, fileBlob, fileName: file.name, contentType: file.type })
                .then(() => {
                    this.showSuccessToast('File uploaded successfully');
                })
                .catch(error => {
                    this.showErrorToast('Error uploading file: ' + error);
                });
        };
        reader.readAsDataURL(file);
    }
    handleUploadFinished(event) {
        // this.showSuccess(this.customLabel.SpinnerAlt);
        // Get the list of uploaded files
        const uploadedFiles = event.detail.files;
        // let cvMap = {};
        let cvids = [];
        for (let index = 0; index < uploadedFiles.length; index++) {
            const element = uploadedFiles[index];
            let arr = element.name.split('.');
            let name = arr[0];
            let type = (arr[arr.length - 1] + '').toUpperCase();
            let item = this.attachProperty({
                iconName : this.getIconName(type),
                Title : name,
                Id : element.contentVersionId,
                ContentVersionId : element.contentVersionId,
                ContentDocumentId: element.documentId,
                ContentBodyId : element.contentBodyId,
                FileType : type.toUpperCase(),
                isSuccess : true
            });
            if (this.isImage(type)) {
                cvids.push(element.contentVersionId);
                item.base64 = spinner;
                
                this.setImage(item);
            }
            this.records.push(item);
        }
        
        this.dispatchEvent(new CustomEvent('selectfiles',{
            detail: {
                records : this.records
            }
        }));

        console.log('No. of files uploaded hahahaha: ' + uploadedFiles.length);
    }

    setImage(item) {
        let img = new Image();
        img.crossOrign="*"
        img.src = item.imgSrc;//获取编码后的值,也可以用this.result获取
        img.onload = () => {
            console.log(img);
            console.log('height:'+img.height+'----width:'+img.width);
            for (let index = 0; index < this.records.length; index++) {
                if (this.records[index].ContentVersionId == item.ContentVersionId) {
                    // this.records[index].base64 = canvas.toDataURL('image/' + item.FileType.toLowerCase());
                    delete this.records[index].base64;
                }
            }
        }
        img.onerror = () => {
            console.log(img);
            this.setImage(item);
        }
    }

    deleteIndex
    handleDeleteFile(event) {
        console.log('WWW开始删除before' + this.records.length);
        // this.deleteIndex = parseInt(event.target.dataset.index);
        let deleteObj = this.records[this.deleteIndex]
        let recordId = deleteObj.ContentDocumentId;
        let packageId = deleteObj.packageId;
        this.isShowSpinner = true;
        Promise.all([
            (()=>{
                if (packageId) {
                    return deleteCaches({packageId})
                } else {
                    return new Promise(resolve=>{
                        resolve(true);
                    })
                }
            })(),
            (()=>{
                if (recordId) {
                    return new Promise(resolve=>{
                        this.deleteFiles([recordId], true, ()=>{
                            resolve(true);
                        });
                    })
                } else {
                    return new Promise(resolve=>{
                        resolve(true);
                    })
                }
                
            })()
        ]).then(result => {
            this.fileHandler.delFiles(packageId);
            this.isShowSpinner = false;
            this.records.splice(this.deleteIndex, 1);
            console.log('WWW开始删除after' + this.sampleId + ':' + this.records.length);
            // if(this.records.length == 0) {
            //     console.log('WWW触发父类方法');
            //     this.dispatchEvent(new CustomEvent(
            //         "deletepicture", {
            //             detail: {
            //                 sampleId : this.sampleId
            //             }
            //         })
            //     );
            // }
            // for (let j = 0; j < this.cacheItems.length; j++) {
            //     if (this.cacheItems[j].packageId === packageId) {
            //         this.cacheItems.splice(j, 1);
            //         break;
            //     }
                
            // }
        })
        
        this.deleteObj = {}
        // this.dispatchEvent(new CustomEvent('deletePicture'));
    }
    

    handleOk(event) {
        let ele = this.template.querySelector('c-modal-lwc');
        if (ele) {
            ele.closeModal(this);
        }
        let deleteObj = this.records[this.deleteIndex]
        let recordId = deleteObj.ContentDocumentId;
        let packageId = deleteObj.packageId;
        this.isShowSpinner = true;
        Promise.all([
            (()=>{
                if (packageId) {
                    return deleteCaches({packageId})
                } else {
                    return new Promise(resolve=>{
                        resolve(true);
                    })
                }
            })(),
            (()=>{
                if (recordId) {
                    return new Promise(resolve=>{
                        this.deleteFiles([recordId], true, ()=>{
                            resolve(true);
                        });
                    })
                } else {
                    return new Promise(resolve=>{
                        resolve(true);
                    })
                }
                
            })()
        ]).then(result => {
            this.fileHandler.delFiles(packageId);
            this.isShowSpinner = false;
            this.records.splice(this.deleteIndex, 1);
            // for (let j = 0; j < this.cacheItems.length; j++) {
            //     if (this.cacheItems[j].packageId === packageId) {
            //         this.cacheItems.splice(j, 1);
            //         break;
            //     }
                
            // }
        })
        
        this.deleteObj = {}
    }



    handleClose(event) {
        this.deleteObj = {}
    }

    @api
    deleteItem() {
        if (this.recordId) {
            this.deleteFiles(this.records.map(r=>r.ContentDocumentId))
        }
    }

    deleteFiles(ids, explicit, successCallback) {
        if (explicit) {
            this.isShowSpinner = true;
        }
        deleteFiles({
            recordIds : ids,
            dataId : this.recordId
        }).then(result => {
            if (result.isSuccess) {
                if (successCallback) {
                    successCallback();
                }
                if (explicit) {
                    this.showSuccess('success');
                }
            } else {
                if (explicit){
                    this.showError(result.message);
                }
                
            }
            // this.showSuccess(result.message ? result.message :'success');
            this.isShowSpinner = false;
        }).catch(error => {
            if (explicit){
                this.isShowSpinner = false;
                this.catchError(error);  
            } else {
                console.log(error);
            }
            
        })
    }

    handleRemoveFile(event) {
        this.records.splice(event.target.dataset.index, 1);
    }

    preview(event) {
        if (!event.currentTarget.dataset.id) {
            this.showSuccess(this.customLabel.SpinnerAlt);
            return;
        }
        // Naviagation Service to the show preview
        this.filePreview(event.currentTarget.dataset.id);
    }

    isImageFile(file) {
        let arr = file.name.split('.');
        return this.isImage(arr.length > 1 ? arr[1] : '');
    }

    isImage(type) {
        if (!type) {
            return false;
        }
        return ['PNG','JPG','JPEG','BMP'].indexOf(type.toUpperCase()) > -1;
    }

    getIconName(type) {
        let iconName = ''
        if (this.isImage(type)) {
            iconName = 'doctype:image';
        } else if (type === 'MP4') {
            iconName = 'doctype:mp4';
        } else if (type === 'AVI') {
            iconName = 'doctype:video';
        } else if (type === 'PDF') {
            iconName = 'doctype:pdf';
        } else {
            iconName = 'doctype:attachment'
        }

        return iconName;
    }

    handleButton(event) {
        this.template.querySelector('#fileInput').click();
    }

    @api
    openUpload() {
        if (this.recordId) {
            this.template.querySelector('lightning-file-upload').click();
        } else {
            this.template.querySelector('lightning-input').click();
        }
        
    }

    retryTime = 0;

    handleLoad(event) {
        if (event.target.src == spinner) {
            
        }
    }

    handleError(event) {
        console.log('handleError');
    }

    handleSpinner(event) {
        this.showSuccess(this.customLabel.SpinnerAlt);
    }

    handleCheck(event) {
        this.isBigFile = event.target.checked;
    }
    
}