import { track, api, wire } from 'lwc';
import { LightningNavigationElement } from 'c/lwcUtils';
import LightningConfirm from 'lightning/confirm';
import getFiles from '@salesforce/apex/UploadFilesController.getFiles';
import deleteFiles from '@salesforce/apex/UploadFilesController.deleteFiles';
import FORM_FACTOR from '@salesforce/client/formFactor';
import { loadStyle } from 'lightning/platformResourceLoader';
import uploadFiles from '@salesforce/resourceUrl/uploadFiles';
import spinner from '@salesforce/resourceUrl/spinner';

export default class UploadFilesLwc extends LightningNavigationElement {

    lwcName = 'UploadFilesLwc';
    isShowSpinner;
    spinnerAlt = "the image's preview is generating, you can save the record";
    @track records = [];
    @api recordIds = [];
    @api parentId;
    @api col = 0;
    @api disabledDelete;
    @api disabledUpload;

    get spinnerSrc() {
        return spinner;
    }

    get attachId() {
        return this.recordId ? this.recordId : this.parentId;
    }

    get acceptedFormats() {
        return ['.jpg','.jpeg','.png','.bmp','.pjpeg'];
    }

    get isMobile() {
        return FORM_FACTOR === 'Small';
    }

    get colClass() {
        if (this.col == 1) {
            return 'slds-col slds-large-size_11-of-12 slds-medium-size_11-of-12 slds-size_11-of-12';
        } else if (this.col == 2) {
            return 'slds-col slds-large-size_5-of-12 slds-medium-size_5-of-12 slds-size_5-of-12';
        } else if (this.col == 3) {
            return 'slds-col slds-large-size_3-of-12 slds-medium-size_3-of-12 slds-size_3-of-12';
        } else if (this.col == 4) {
            return 'slds-col slds-large-size_2-of-12 slds-medium-size_2-of-12 slds-size_2-of-12';
        } else {
            return 'slds-col slds-large-size_5-of-12 slds-medium-size_5-of-12 slds-size_11-of-12';
        }
        
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
            // "src": {
            //     get() {
            //         // return '/sfc/servlet.shepherd/version/renditionDownload?rendition=thumb120by90&versionId='
            //         // return '/sfc/servlet.shepherd/version/renditionDownload?rendition=ORIGINAL_' + item.FileType + '&versionId='
            //         return '/sfc/servlet.shepherd/version/renditionDownload?rendition=' 
            //         + (_this.isMobile ? 'thumb120by90' : 'ORIGINAL_' + item.FileType ) 
            //         + '&versionId='
            //         + item.Id +'&operationContext=CHATTER&contentId=' + item.ContentBodyId
            //     }
            // },
            "src1": {
                get() {
                    return this.src + this.Description
                }
            },
            "isImage": {
                get() {
                    return _this.isImage(this.FileType)
                }
            }
        });
        this.refreshSrc(item,this.isMobile);
        return item;
    }

    refreshSrc(item, isMobile) {
        // item.src = '';
        item.src = '/sfc/servlet.shepherd/version/renditionDownload?rendition=' 
        + (isMobile ? 'thumb120by90' : 'ORIGINAL_' + item.FileType ) 
        + '&versionId='
        + item.Id +'&operationContext=CHATTER&contentId=' + item.ContentBodyId;
    }

    doInit() {
        this.refresh();
    }

    connectedCallback() {
        loadStyle(this, uploadFiles)
    }

    @api
    refresh() {
        this.isShowSpinner = true;
        getFiles({
            recordId : this.recordId,
            recordIds : this.recordIds
        }).then(result => {
            if (result.isSuccess) {
                for (let key in result.data) {
                    this[key] = result.data[key];
                }
                for (let index = 0; index < this.records.length; index++) {
                    this.attachProperty(this.records[index])
                    this.setItemStatus(this.records[index], true)
                }
                // this.showSuccess(result.message ? result.message :'success');
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
        return this.records;
    }

    handleUploadFinished(event) {
        this.showSuccess(this.spinnerAlt);
        // Get the list of uploaded files
        const uploadedFiles = event.detail.files;
        let _this = this
        uploadedFiles.forEach(item => {
            let arr = item.name.split('.');
            let name = arr[0];
            let type = (arr[arr.length - 1] + '').toUpperCase();
            _this.records.push(_this.setItemStatus( _this.attachProperty({
                iconName : _this.getIconName(type),
                Title : name,
                Id : item.contentVersionId,
                ContentDocumentId: item.documentId,
                ContentBodyId : item.contentBodyId,
                FileType : type.toUpperCase()
            })));
        });
        this.dispatchEvent(new CustomEvent('selectfiles',{
            detail: {
                records : this.records
            }
        }));
        console.log('No. of files uploaded : ' + uploadedFiles.length);
    }

    deleteObj
    handleDeleteFile(event) {
        this.deleteObj = {
            'recordId' : event.target.dataset.id,
            'index' : event.target.dataset.index
        }
        let ele = this.template.querySelector('c-modal-lwc');
        if (ele) {
            ele.showModal(this);
        }
    }

    handleOk(event) {
        let ele = this.template.querySelector('c-modal-lwc');
        if (ele) {
            ele.closeModal(this);
        }
        let recordId = this.deleteObj.recordId;
        let index = this.deleteObj.index;
        this.isShowSpinner = true;
        this.deleteFiles([recordId], true, ()=>{
            this.records.splice(index, 1);
            this.isShowSpinner = false;
            // 删除文件后返回给父页面id
            this.dispatchEvent(new CustomEvent('deletefiles',{
                detail: {
                    deleteId : recordId
                }
            }));
        });
        
        this.deleteObj = {}
    }

    handleClose(event) {
        this.deleteObj = {}
    }

    // async handleDeleteFile(event) {
    //     let recordId = event.target.dataset.id;
    //     let index = event.target.dataset.index;
    //     const result = await LightningConfirm.open({
    //         message: 'Are you sure delete the attachment?',
    //         variant: 'headerless',
    //         label: 'This is the aria-label value',
    //         // label value isn't visible in the headerless variant
    //     });
    //     console.log(result)
    //     // confirm modal has been closed
    //     if (result) {
    //         this.isShowSpinner = true;
    //         this.deleteFiles([recordId], true, ()=>{
    //             this.records.splice(index, 1);
    //         });
    //     }
    // }

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
        // Naviagation Service to the show preview
        this.filePreview(event.currentTarget.dataset.id);
    }

    isImage(type) {
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

    async handlephotoClick(event) {
        console.log('Photo click');
        
        var file = event.target.files[0];
        // 获取上传图片的base64
        var uploadBase64 = await new Promise(resolve => {
            // 文件读取
            var reader = new FileReader();
            reader.onload = () => {
                // const base64String = reader.result.split(',')[1];
                var uploadBase64 = reader.result;
                resolve(uploadBase64);
                // console.log('Name:', file.name, 'Base64 string:', uploadBase64);
            };
            reader.readAsDataURL(file);
        });
        console.log(uploadBase64);
        console.log(uploadBase64.length);
        
        // 转换后图片base64
        var convertBase64 = await new Promise(resolve => {
            // 使用base64方式创建一个Image对象
            var img = new Image();
            img.src = uploadBase64;
            // 当图片加载成功后执行
            img.onload = () => {
                // 创建canvas元素
                var canvas = document.createElement('canvas');

                // 设置canvas的宽高为图片的宽高
                canvas.width = img.width;
                canvas.height = img.height;

                // 在canvas上绘制图片
                var ctx = canvas.getContext('2d');
                ctx.drawImage(img, 0, 0);

                // 将canvas转换为目标大小的base64编码
                var quality = 0.7; // 图片压缩质量
                var maxFileSize = 2097152; // 文件大小限制为2MB
                let compressedDataUrl = canvas.toDataURL('image/jpeg', quality);
                while (compressedDataUrl.length > maxFileSize) {
                    // 文件超过限制，压缩质量
                    quality -= 0.1; // 每次降低压缩质量 0.1
                    compressedDataUrl = canvas.toDataURL('image/jpeg', quality);
                }
                // 压缩后的base64
                var convertBase64 = compressedDataUrl;
                resolve(convertBase64);
            };
        });
        console.log(convertBase64);
        console.log(convertBase64.length);
        this.records.push({
            src : convertBase64,
            Title : file.name,
            type: file.type,
            index : new Date().getTime() + '' + this.records.length
        })
        
        this.dispatchEvent(new CustomEvent('selectfiles',{
            detail: {
                records : this.records
            }
        }));
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
    handleError(event) {
        // if (this.retryTime > 3) {
        //     return ;
        // }

        // this.retryTime++;
        // this.refresh();
        // let src = this.records[event.currentTarget.dataset.index].src; 
        // this.records[event.currentTarget.dataset.index].src = '';
        // this.records[event.currentTarget.dataset.index].src = src;
        let index = event.currentTarget.dataset.index;
        let item = this.records[index];
        item.src = '';
        let _refreshSrc = this.refreshSrc;
        let isMobile = this.isMobile
        setTimeout(()=>{
            _refreshSrc(item, isMobile);
        },1000)
    }

    handleLoad(event) {
        let index = event.currentTarget.dataset.index;
        if (this.records[index].src) {
            this.setItemStatus(this.records[index], true)
        }
    }

    setItemStatus(item, isSuccess) {
        item.isSuccess = isSuccess;
        item.style = 'width:100%;min-width:100px;cursor:pointer;' + (isSuccess ? '' : 'display:none;');
        item.spinnerStyle = 'width:100%;min-width:100px;cursor:pointer;' + (isSuccess ? 'display:none;' : '');
        return item;
    }

    handleSpinner(event) {
        this.showSuccess(this.spinnerAlt);
    }
}