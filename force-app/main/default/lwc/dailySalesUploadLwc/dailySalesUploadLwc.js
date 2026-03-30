import { LightningElement, track, api, wire } from 'lwc';
import saveFile from '@salesforce/apex/DailySalesUploadController.saveFile';
import saveFileStoreInspectionManage from '@salesforce/apex/DailySalesUploadController.saveFileStoreInspectionManage';
import saveFileInventory from '@salesforce/apex/DailySalesUploadController.saveFileInventory';
import saveFileTargets from '@salesforce/apex/DailySalesUploadController.saveFileTargets';
import {ShowToastEvent} from 'lightning/platformShowToastEvent';
import saveFilesCustomerTargets from '@salesforce/apex/DailySalesUploadController.saveFilesCustomerTargets';
import saveFilesChannel from '@salesforce/apex/DailySalesUploadController.saveFilesChannel';
import saveFilesSamplingCondition from '@salesforce/apex/DailySalesUploadController.saveFilesSamplingCondition';
// import saveFilesSamplingConditionTemplate from '@salesforce/apex/DailySalesUploadController.saveFilesSamplingConditionTemplate';
import saveFilesSamplingTarget from '@salesforce/apex/DailySalesUploadController.saveFilesSamplingTarget';
import saveFilesTraining from '@salesforce/apex/DailySalesUploadController.saveFilesTraining';
import saveFilesPromoterCost from '@salesforce/apex/DailySalesUploadController.saveFilesPromoterCost';
import saveFilesPromoterRevenue from '@salesforce/apex/DailySalesUploadController.saveFilesPromoterRevenue';
import saveSampleDisplayFile from '@salesforce/apex/SampleDisplayController.saveSampleDisplayFile';
import saveSampleRemovalFile from '@salesforce/apex/SampleDisplayController.saveSampleRemovalFile';
import { NavigationMixin } from 'lightning/navigation';
import getLightningBaseUrl from "@salesforce/apex/VideoViewerController.getLightningBaseUrl";
import TrainingTemplete from '@salesforce/resourceUrl/TrainingTemplete';
import TrainingDownLoad from '@salesforce/label/c.Training_DownLoad';

export default class DailySalesUploadLwc extends NavigationMixin(LightningElement) {
    @api recordId;
    @api objectLoad;
    @api importDate;
    @api downLoadFlag;
    @track isdownLoad = false;
    @track isHaveFile = false;
    @track fileName = '';
    @track UploadFile = 'Upload File';
    @track showLoadingSpinner = false;
    TrainingTemplete = TrainingTemplete;
    filesUploaded = [];
    file;
    fileContents;
    fileReader;
    content;
    label = {
        TrainingDownLoad,
    }
    MAX_FILE_SIZE = 1500000;

    get acceptedType() {
        return ['.csv'];
    }

    connectedCallback(){
        console.log('objectLoad----' + this.objectLoad);
        console.log('recordId----' + this.recordId);

        // 如果为traing展示下载模版按钮 YYL 1227
        if(this.objectLoad == 'Training Upload'){
            this.isdownLoad = true;
        }
    }

    handleFilesClick(){
        // this.fileName = '';

    }

    @wire(getLightningBaseUrl)
    baseUrl;

    handleFilesDownLoad(){
        // 跳转下载模版 发布代码切换对应地址！！！！！
        // window.open('https://hisenseint--hisenseall.sandbox.lightning.force.com/apex/ExportPage');
        window.open(this.baseUrl.data + '/apex/ExportPage');
        // window.open('https://hisenseint.lightning.force.com/apex/ExportPage');

        // 返回上级页面
        window.location.reload();
    }

    handleFilesChange(event) {
        if(event.target.files.length > 0) {
            this.filesUploaded = event.target.files;
            this.fileName = event.target.files[0].name;
            this.isHaveFile = true;
        }
    }

    handleSave() {
        if(this.filesUploaded.length > 0) {
            this.file = this.filesUploaded[0];
            if (this.file.size > this.MAX_FILE_SIZE) {
                window.console.log('File is too large');
                return ;
            }
            this.showLoadingSpinner = true;
            this.fileReader= new FileReader();

            this.fileReader.onloadend = (() => {
                this.fileContents = this.fileReader.result;
                let base64 = 'base64,';
                this.content = this.fileContents.indexOf(base64) + base64.length;
                this.fileContents = this.fileContents.substring(this.content);
                this.saveToFile();
            });
            this.fileReader.readAsDataURL(this.file);

        }
        else {
            this.isHaveFile = false;
            this.fileName = 'Select a csv file to upload';
        }
    }

    // 下载training模版
    downLoadTemplete(){
        console.log('wwwww测试');
        // trainingDownloadTemplate().then(result => {
        //     this.uploadResult(result);
        // }).error(error => {
        //     this.uploadResultError(error);
        // })
        window.open(this.TrainingTemplete);
    }


    saveToFile() {
        if(this.objectLoad == 'Daily Sales'){
            saveFile({fileName: this.file.name, base64Data: encodeURIComponent(this.fileContents)})
            .then(result => {
                this.uploadResult(result);
            })
            .catch(error => {
                this.uploadResultError(error);
            });
        }else if(this.objectLoad == 'Store Inspection Manage'){
            saveFileStoreInspectionManage({fileName: this.file.name, base64Data: encodeURIComponent(this.fileContents)})
            .then(result => {
                this.uploadResult(result);
            })
            .catch(error => {
                this.uploadResultError(error);
            });
        }else if(this.objectLoad == 'Inventory'){
            saveFileInventory({fileName: this.file.name, base64Data: encodeURIComponent(this.fileContents)})
            .then(result => {
                this.uploadResult(result);
            })
            .catch(error => {
                this.uploadResultError(error);
            });
        }else if(this.objectLoad == 'Targets'){
            saveFileTargets({fileName: this.file.name, base64Data: encodeURIComponent(this.fileContents)})
            .then(result => {
                this.uploadResult(result);
            })
            .catch(error => {
                this.uploadResultError(error);
            });
        }else if(this.objectLoad == 'Customer Targets'){
            saveFilesCustomerTargets({
                fileName:this.file.name,
                base64Data:encodeURIComponent(this.fileContents)
            }).then(result => {
                this.uploadResult(result);
            }).catch(error => {
                this.uploadResultError(error);
            })

        }else if(this.objectLoad == 'Channel'){
            saveFilesChannel({
                fileName:this.file.name,
                base64Data:encodeURIComponent(this.fileContents)
            }).then(result =>{
                this.uploadResult(result);
            }).catch(error =>{
                this.uploadResultError(error);
            })
        }else if(this.objectLoad == 'Sampling Condition'){
            saveFilesSamplingCondition({
                fileName:this.file.name,
                base64Data:encodeURIComponent(this.fileContents),
                importDate:this.importDate
            }).then(result => {
                this.uploadResult(result);
                const closeModal = new CustomEvent('refreshView');
                this.dispatchEvent(closeModal);
            }).catch(error => {
                this.uploadResultError(error);
            })
        }
        // else if(this.objectLoad == 'Sampling Condition Template'){
        //     saveFilesSamplingConditionTemplate({
        //         fileName:this.fileName,
        //         base64Data:encodeURIComponent(this.fileContents)
        //     }).then(result => {
        //         this.uploadResult(result);
        //     }).error(error => {
        //         this.uploadResultError(error);
        //     })
        // }
        else if(this.objectLoad == 'Sampling Target'){
            saveFilesSamplingTarget({
                fileName:this.fileName,
                base64Data:encodeURIComponent(this.fileContents)
            }).then(result => {
                this.uploadResult(result);
                console.log(JSON.stringify(result));
                // window.open(result.errorUrl);
            }).catch(error => {
                this.uploadResultError(error);
            })
        }else if(this.objectLoad == 'Training'){
            saveFilesTraining({
                fileName:this.fileName,
                base64Data:encodeURIComponent(this.fileContents)
            }).then(result => {
                this.uploadResult(result);
                console.log(JSON.stringify(result));
                // window.open(result.errorUrl);
            }).catch(error => {
                this.uploadResultError(error);
            })
        }else if(this.objectLoad == 'Store Product Line'){
            alert('StoreProductLine');
        }else if(this.objectLoad == 'Promoter Cost'){
            saveFilesPromoterCost({
                fileName:this.fileName,
                base64Data:encodeURIComponent(this.fileContents),
                importDate:this.importDate
            }).then(result => {
                this.uploadResult(result);
            }).catch(error => {
                this.uploadResultError(error);
            })
        }else if(this.objectLoad == 'Promoter Revenue'){
            saveFilesPromoterRevenue({
                fileName:this.fileName,
                base64Data:encodeURIComponent(this.fileContents)
            }).then(result => {
                this.uploadResult(result);
            }).catch(error => {
                this.uploadResultError(error);
            })
        }else if(this.objectLoad == 'Sample Display'){
            saveSampleDisplayFile({
                fileName:this.fileName,
                base64Data:encodeURIComponent(this.fileContents)
            }).then(result => {
                this.uploadResult(result);
            }).catch(error => {
                this.uploadResultError(error);
            })
        }else if(this.objectLoad == 'Sample Removal'){
            saveSampleRemovalFile({
                fileName:this.fileName,
                base64Data:encodeURIComponent(this.fileContents)
            }).then(result => {
                this.uploadResult(result);
            }).catch(error => {
                this.uploadResultError(error);
            })
        }
        
    }

    back(){
        window.history.go(-1);
        const closeModal = new CustomEvent('refreshView');
        this.dispatchEvent(closeModal);
    }

    uploadResult(result){
        this.showLoadingSpinner = false;

        if(result.isSuccess){
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Success!!',
                    message: this.fileName + ' - Upload successfully! ' + result.msg,
                    variant: 'success',
                    mode : 'sticky'
                }),
            );
            window.history.go(-1);
            // if(result.partFails){
            //     window.open(result.errorUrl);
            // }
        }else {
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'error',
                    message: result.msg,
                    variant: 'error',
                    mode : 'sticky'
                }),
            );
            window.open(result.errorUrl);
            // if(result.partFails){
            //     window.open(result.errorUrl);
            // }   
        }
    }

    uploadResultError(error){
        this.showLoadingSpinner = false;
        this.dispatchEvent(
            new ShowToastEvent({
                title: 'Upload failure',
                message: error.message,
                variant: 'error',
                mode : 'sticky'
            }),
        );
    }
}