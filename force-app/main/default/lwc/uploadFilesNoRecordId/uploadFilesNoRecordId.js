import { LightningElement, api, track } from 'lwc';
import { LightningNavigationElement, FileHandle } from 'c/lwcUtils';
import { loadStyle, loadScript } from 'lightning/platformResourceLoader';
import uploadFiles from '@salesforce/resourceUrl/uploadFiles';

export default class UploadFilesNoRecordId extends LightningNavigationElement {
    @track filesInfo = [];

    // 初始化数据
    connectedCallback() {
        loadStyle(this, uploadFiles);
    }

    @api
    selectFiles() {
        this.dispatchEvent(new CustomEvent('selectfiles',{
            detail: {
                filesInfo : this.filesInfo
            }
        }));
    }

    // 文件上传
    handleFilesChange(event){
        console.log('wwwwww-----文件上传');
        let files = event.target.files;

        for (const file of files) {
            let arr = file.name.split('.');
            let type = (arr[arr.length - 1] + '').toUpperCase();
            (()=>{
                return this.readFile(file)
            })().then(base64 => {
                this.filesInfo.push({
                    name: file.name,
                    size: file.size,
                    type: type,
                    base64: base64,
                    isImage: this.isImage(type),
                    iconName: this.getIconName(type),
                });
            })
        }
    }

    // 读取文件
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

    // 删除文件
    handleDeleteFile(event){
        const index = event.target.dataset.index;
        this.filesInfo.splice(index, 1);
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
        } else if (type === 'DOC' || type === 'DOCX') {
            iconName = 'doctype:word';
        } else if (type === 'XLSX' || type === 'XLS') {
            iconName = 'doctype:excel';
        } else if (type === 'CSV') {
            iconName = 'doctype:csv';
        } else if (type === 'TXT') {
            iconName = 'doctype:txt';
        } else if (type === 'PPTX' || type === 'PPT') {
            iconName = 'doctype:ppt';
        }else {
            iconName = 'doctype:attachment'
        }
        return iconName;
    }
}