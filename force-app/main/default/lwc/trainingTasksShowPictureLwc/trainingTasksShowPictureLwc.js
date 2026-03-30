/*
 * @Author: WFC
 * @Date: 2024-04-07 09:26:17
 * @LastEditors: WFC
 * @LastEditTime: 2024-04-16 17:04:30
 * @Description: 
 * @FilePath: \hisenseall-231026\force-app\main\default\lwc\trainingTasksShowPictureLwc\trainingTasksShowPictureLwc.js
 */
import { LightningElement, api, track, wire } from 'lwc';
import { LightningNavigationElement, readFile } from 'c/lwcUtils'
import { NavigationMixin } from 'lightning/navigation';

// import saveTrainingPicture from '@salesforce/apex/TrainingController.saveTrainingPicture';
import getPictureList from '@salesforce/apex/TrainingController.getPictureList';
import deletePicture from '@salesforce/apex/TrainingController.deletePicture';
import getStatus from '@salesforce/apex/TrainingController.getStatus';
import { loadStyle, loadScript } from 'lightning/platformResourceLoader';
import uploadFiles from '@salesforce/resourceUrl/uploadFiles';
import { refreshApex } from '@salesforce/apex';

export default class TrainingTasksShowPictureLwc extends LightningNavigationElement {

    // 主数据id
    @api recordId;
    // 上传照片流信息
    @track attendancePhotoStream;
    // 主数据关联图片集合
    @track pictureList = [];
    // 点击小图片，放大标记
    @track showPicture = false;
    // 点击删除图片提示框标记
    @track showDeletePicture = false;
    // 大图片src地址
    @track shopPictureSrc = '';
    // 大图片ContentDocumentId
    @track shopPictureId = '';
    // 删除图片加载……标记
    @track isShowSpinner = false;
    // 是否可以上传更改图片 true：可以 false：不可以
    @track status = true;

    get acceptedFormats() {
        return ['.jpg', '.jpeg', '.png'];
    }

    connectedCallback() {
        loadStyle(this, uploadFiles).then(()=>{
            
        }).catch((error) => {
            
        });
        this.getPictureList();
        setInterval(() => {
            refreshApex(this.wiredResult);
        }, 1000);
    }

    wiredResult
    @wire(getStatus, { recordId: "$recordId" })
    getStatus(result) {
        this.wiredResult = result;
        this.status = result.data;
    }

    // 点击小图片，放大
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

    handleUploadFinished(event){
        this.getPictureList();
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
            }
        }).catch(error => {
             
        });
    }

    // 关闭放大的图片
    handleClosePicture(event){
        this.showPicture = false;
        this.shopPictureSrc = '';
        this.shopPictureId = '';
    }

    // 点击放大图片里的删除按钮
    handleDeletePicture(event) {
        this.showDeletePicture = true;
    }

    // 点击放大图片里的详情页面
    handleViewPicture(event){
        // 新页面GenerateUrl
        this[NavigationMixin.GenerateUrl]({
            type: 'standard__recordPage',
            attributes: {
                recordId: this.shopPictureId,
                actionName: 'view'
            },          
        }).then(url => {
            window.open(url, "_blank");
        });
    }

    // 关闭放大图片删除页面
    handleCloseDeletePicture(){
        this.showDeletePicture = false;
    }

    // 关闭放大图片删除页面
    deleteCancel(){
        this.showDeletePicture = false;
    }

    // 删除图片
    deletePicture(){
        let ele = this.template.querySelector('c-modal-lwc');
        if (ele) {
            ele.closeModal(this);
        }
        this.isShowSpinner = true;
        deletePicture({
            contentDocumentId: this.shopPictureId,
        }).then(data => {
            if(data){
                this.isShowSpinner = false;
                this.showDeletePicture = false;
                this.showPicture = false;
                this.shopPictureSrc = '';
                this.shopPictureId = '';
                this.showSuccess("Image was deleted.");
                this.getPictureList();
            }else {
                this.isShowSpinner = false;
                this.showError("Image deletion failed");
            }
        }).catch(error => {
            this.isShowSpinner = false;
        });
    }

    // handleDeleteFile(event){
    //     // this.showDeletePicture = true;
    //     let ele = this.template.querySelector('c-modal-lwc');
    //     if (ele) {
    //         ele.showModal(this);
    //     }
    //     this.shopPictureId = event.target.dataset.id
    // }
}