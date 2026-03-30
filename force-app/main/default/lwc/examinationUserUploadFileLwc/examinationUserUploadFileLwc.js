/*
 * @Author: YYL
 * @LastEditors: TJP
 */
import { LightningElement, track, api } from 'lwc';
import sheetJS from '@salesforce/resourceUrl/sheetJS';
import xlsx_js_style from '@salesforce/resourceUrl/xlsx_js_style';
import {loadScript} from 'lightning/platformResourceLoader';
import {ShowToastEvent} from 'lightning/platformShowToastEvent';
import { NavigationMixin } from 'lightning/navigation';
import saveFileExamination from '@salesforce/apex/TrainingExaminationController.saveFileExamination';
import Training_Task_Cancel from '@salesforce/label/c.Training_Task_Cancel';

export default class ExaminationUserUploadFileLwc extends NavigationMixin(LightningElement) {
    label = {
            Training_Task_Cancel, // 取消
        }
    
    @api recordId;
    @track isHaveFile = false;
    @track fileName = '';
    @track UploadFile = 'Upload File';
    @track showLoadingSpinner = false;
    filesUploaded = [];
    file;
    fileContents;
    fileReader;
    content;
    MAX_FILE_SIZE = 1500000;

    filesUploaded = [];
    dataList = [];

    get modalHeight() {
        var height = 'height: 100%';
				
        try {
            if (this.root) {
                var doc = document.documentElement.clientHeight;
    
                var rooth = this.root.childNodes[0].offsetHeight
                height = doc<rooth ? 'height: '+rooth+'px;' : 'height: 100%;';
            }
        } catch (error) {
            
        }
				
        return height;
    }
    
    get acceptedType() {
        return ['.xls','.xlsx'];
    }

    connectedCallback(){
        console.log('objectLoad----' + this.objectLoad);
        console.log('objectType----' + this.objectType);

        loadScript(this, sheetJS).then(() => {
            console.log('加载 sheetJS 完成');
            this.sheetJsLoaded = true;
            this.disableButton = false;
        });
        loadScript(this, xlsx_js_style + '/dist/cpexcel.js');
        loadScript(this, xlsx_js_style + '/dist/shim.min.js');
        loadScript(this, xlsx_js_style + '/dist/xlsx.bundle.js');
        loadScript(this, xlsx_js_style + '/dist/xlsx.min.js');

        this.clearFile();
    }

    clearFile(){
        this.fileName = '';
        this.filesUploaded = [];
        this.dataList = [];
    }

    handleFilesClick(){
        this.fileName = '';
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
            this.excelFileToJson();

        }else {
            this.isHaveFile = false;
            this.fileName = 'Select a file to upload';
        }
    }

    excelFileToJson(event) {
        let files = this.filesUploaded;

        const analysisExcel = (file) =>
        new Promise((resolve, reject) => {
            const reader = new FileReader();
            reader.readAsBinaryString(file);
            reader.onload = () => resolve(reader.result);
            reader.onerror = (error) => reject(error);
        });

        analysisExcel(files[0])
        .then((result) => {
            let datas = []; // 存储获取到的数据
            let XLSX = window.XLSX;
            let workbook = XLSX.read(result, {
                type: 'binary'
            });
            for (let sheet in workbook.Sheets) {
                if (workbook.Sheets.hasOwnProperty(sheet)) {
                    datas = datas.concat(XLSX.utils.sheet_to_json(workbook.Sheets[sheet], {header:1,defval:'',}));  //  空单元格默认值 ''
                    datas = datas.filter(row => row.some(cell => cell !== ''));
                }
                break;
            }

            this.dataList = datas;

            this.submit();

            console.log('ssssss' + JSON.stringify(datas));
        });
    }

    submit(){
        saveFileExamination({
            recordId:this.recordId,
            fileLines:this.dataList
        }).then(result =>{
            this.showLoadingSpinner = false;

            console.log('wwwwsaveFileExamination' + JSON.stringify(result));

            if(result.isSuccess){
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Success!!',
                        message: this.fileName + ' - 上传成功',
                        variant: 'success',
                    }),
                );
                const closeModal = new CustomEvent('close');
                this.dispatchEvent(closeModal);
            }else{
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'error',
                        message: result.msg,
                        variant: 'error',
                    }),
                );

                window.open(result.errorUrl);
            }
        }).catch(error =>{
            this.showLoadingSpinner = false;
            this.dispatchEvent(
                new ShowToastEvent({
                    title: '上传失败',
                    message: error.msg,
                    variant: 'error',
                }),
            );
        })
    }

    cancel(event){
        const closeModal = new CustomEvent('close');
        this.dispatchEvent(closeModal);
    }
 
}