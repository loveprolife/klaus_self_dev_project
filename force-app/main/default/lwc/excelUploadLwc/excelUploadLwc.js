import { LightningElement, track, api } from 'lwc';
import sheetJS from '@salesforce/resourceUrl/sheetJS';
import xlsx_js_style from '@salesforce/resourceUrl/xlsx_js_style';
import {loadScript} from 'lightning/platformResourceLoader';
import {ShowToastEvent} from 'lightning/platformShowToastEvent';
import { NavigationMixin } from 'lightning/navigation';
import Target_Template from '@salesforce/resourceUrl/Target_Template';
import Customer_Addresss_Template from '@salesforce/resourceUrl/Customer_Addresss_Template';
import Key_Model_Template from '@salesforce/resourceUrl/Key_Model_Template';
import Actual_Achievement_Customer from '@salesforce/resourceUrl/Actual_Achievement_Customer';
import Actual_Achievement_Store from '@salesforce/resourceUrl/Actual_Achievement_Store';
import Channel_Product_Price from '@salesforce/resourceUrl/Channel_Product_Price';

// import saveRSPUpload from '@salesforce/apex/ExcelUploadController.saveRSPUpload';
// import saveStoreProductLine from '@salesforce/apex/ExcelUploadController.saveStoreProductLine';
// import saveSamplingTarget from '@salesforce/apex/ExcelUploadController.saveSamplingTarget';
// import saveSamplingCondition from '@salesforce/apex/ExcelUploadController.saveSamplingCondition';
// import saveChannel from '@salesforce/apex/ExcelUploadController.saveChannel';
// import saveTargets from '@salesforce/apex/ExcelUploadController.saveTargets';
// import saveCustomerTargets from '@salesforce/apex/ExcelUploadController.saveCustomerTargets';
// import saveStoreInspectionManage from '@salesforce/apex/ExcelUploadController.saveStoreInspectionManage';
// import saveDailySales from '@salesforce/apex/ExcelUploadController.saveDailySales';
import saveWeeklySalesTarget from '@salesforce/apex/ExcelUploadController.saveWeeklySalesTarget';
import saveTargetOther from '@salesforce/apex/ExcelUploadController.saveTargetOther';
import saveActualAchievement from '@salesforce/apex/ExcelUploadController.saveActualAchievement';
import saveChannelProductPrice from '@salesforce/apex/ExcelUploadController.saveChannelProductPrice';
import saveKeyModel from '@salesforce/apex/ExcelUploadController.saveKeyModel';
import saveCustomerAddress from '@salesforce/apex/ExcelUploadController.saveCustomerAddress';

export default class ExcelUploadLwc extends NavigationMixin(LightningElement) {
    @api recordId;
    @api objectLoad;
    @api objectType;
    @api importDate;
    @track fileName = '';
    @track UploadFile = 'Upload File';
    @track isHaveFile = false;
    @track showLoadingSpinner = false;
    @track disableButton = true;
    @track isdownLoad = false;

    sheetJsLoaded = false;

    filesUploaded = [];
    dataList = [];
    
    MAX_FILE_SIZE = 1500000;

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

    renderedCallback(){
        if('Targets Other' == this.objectLoad || 'Actual Achievement' == this.objectLoad || 'Channel Product Price' == this.objectLoad
             || 'Key Model' == this.objectLoad || 'Customer Address' == this.objectLoad
        ){
            this.isdownLoad = true;
        }
    }

    handleFilesDownLoad(event) {
        let fileUrl = '';
        let fileDownloadName = '';
        if('Targets Other' == this.objectLoad){
            fileUrl = Target_Template;
            fileDownloadName = 'Target Template.xlsx';
        }else if('Actual Achievement' == this.objectLoad){
            if('Store' == this.objectType){
                fileUrl = Actual_Achievement_Store;
                fileDownloadName = '实际达成（门店&导购）.xlsx'
            }else if('Customer' == this.objectType){
                fileUrl = Actual_Achievement_Customer;
                fileDownloadName = '实际达成（渠道总门店数）.xlsx'
            }
        }else if('Channel Product Price' == this.objectLoad){
            fileUrl = Channel_Product_Price;
            fileDownloadName = 'Channel Product Price.xlsx';
        }else if('Key Model' == this.objectLoad){
            fileUrl = Key_Model_Template;
            fileDownloadName = 'Key Model Import Template.xlsx';
        }else if('Customer Address' == this.objectLoad){
            fileUrl = Customer_Addresss_Template;
            fileDownloadName = 'Ship To Import Template.xlsx';
        }
        

        // 创建隐藏的 <a> 标签
        const link = document.createElement('a');
        link.href = fileUrl;
        link.download = fileDownloadName;
        document.body.appendChild(link);
        link.click();
        document.body.removeChild(link);
    }

    clearFile(){
        this.fileName = '';
        this.filesUploaded = [];
        this.dataList = [];
    }

    handleFilesClick(){
        // this.fileName = '';

    }

    handleFilesChange(event) {
        if(event.target.files.length > 0) {
            this.filesUploaded = event.target.files;
            this.fileName = event.target.files[0].name;
            this.isHaveFile = true;
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
                }
                break;
            }

            this.dataList = datas;

            this.submit();

            console.log('ssssss' + JSON.stringify(datas));

            // const toastEvent = new ShowToastEvent({
            //     variant: "success",
            //     message: '文件已经上传解析成功',
            // });
            // this.dispatchEvent(toastEvent);
        });
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


    submit() {
        
        // if(this.objectLoad == 'RRP&SPIV Tracking'){
        //     saveRSPUpload({
        //         fileName:this.fileName,
        //         fileLines:this.dataList
        //     }).then(result => {
        //         this.uploadResult(result);
        //     }).catch(error => {
        //         this.uploadResultError(error);
        //     })
        // }else 
        /*if(this.objectLoad == 'Store Product Line'){
            saveStoreProductLine({
                fileName:this.fileName,
                fileLines:this.dataList
            }).then(result => {
                this.uploadResult(result);
            }).catch(error => {
                this.uploadResultError(error);
            })
        }else if(this.objectLoad == 'Sampling Target'){
            saveSamplingTarget({
                fileName:this.fileName,
                fileLines:this.dataList
            }).then(result => {
                this.uploadResult(result);
            }).catch(error => {
                this.uploadResultError(error);
            })
        }else if(this.objectLoad == 'Sampling Condition'){
            saveSamplingCondition({
                fileName:this.fileName,
                fileLines:this.dataList,
                importDate:this.importDate
            }).then(result => {
                this.uploadResult(result);
            }).catch(error => {
                this.uploadResultError(error);
            })
        }else if(this.objectLoad == 'Channel'){
            saveChannel({
                fileName:this.fileName,
                fileLines:this.dataList
            }).then(result =>{
                this.uploadResult(result);
            }).catch(error =>{
                this.uploadResultError(error);
            })
        }else if(this.objectLoad == 'Targets'){
            saveTargets({
                fileName:this.fileName,
                fileLines:this.dataList
            }).then(result =>{
                this.uploadResult(result);
            }).catch(error =>{
                this.uploadResultError(error);
            })
        }else if(this.objectLoad == 'Customer Targets'){
            saveCustomerTargets({
                fileName:this.fileName,
                fileLines:this.dataList
            }).then(result =>{
                this.uploadResult(result);
            }).catch(error =>{
                this.uploadResultError(error);
            })
        }else if(this.objectLoad == 'Store Inspection Manage'){
            saveStoreInspectionManage({
                fileName:this.fileName,
                fileLines:this.dataList
            }).then(result =>{
                this.uploadResult(result);
            }).catch(error =>{
                this.uploadResultError(error);
            })
        }else if(this.objectLoad == 'Daily Sales'){
            saveDailySales({
                fileName:this.fileName,
                fileLines:this.dataList
            }).then(result =>{
                this.uploadResult(result);
            }).catch(error =>{
                this.uploadResultError(error);
            })
        }else*/ if(this.objectLoad == 'WeeklySalesTarget'){
            saveWeeklySalesTarget({
                fileName:this.fileName,
                fileLines:this.dataList
            }).then(result =>{
                this.uploadResult(result, 'Weekly_Sales_Target__c');
            }).catch(error =>{
                this.uploadResultError(error);
            })
        }else if(this.objectLoad == 'Targets Other'){
            saveTargetOther({
                fileName:this.fileName,
                fileLines:this.dataList
            }).then(result =>{
                this.uploadResult(result, 'SalesGoal__c');
            }).catch(error =>{
                this.uploadResultError(error);
            })
        }else if(this.objectLoad == 'Actual Achievement'){
            saveActualAchievement({
                fileName:this.fileName,
                fileLines:this.dataList,
                objectType:this.objectType
            }).then(result =>{
                this.uploadResult(result, 'Actual_Achievement__c');
            }).catch(error =>{
                this.uploadResultError(error);
            })
        }else if(this.objectLoad == 'Channel Product Price'){
            saveChannelProductPrice({
                fileName:this.fileName,
                fileLines:this.dataList,
            }).then(result =>{
                this.uploadResult(result, 'Channel_Product_Price__c');
            }).catch(error =>{
                this.uploadResultError(error);
            })
        }else if(this.objectLoad == 'Key Model'){
            saveKeyModel({
                fileName:this.fileName,
                fileLines:this.dataList,
            }).then(result =>{
                this.uploadResult(result, 'SalesGoal__c');
            }).catch(error =>{
                this.uploadResultError(error);
            })
        }else if(this.objectLoad == 'Customer Address'){
            saveCustomerAddress({
                fileName:this.fileName,
                fileLines:this.dataList,
            }).then(result =>{
                this.uploadResult(result, 'Account');
            }).catch(error =>{
                this.uploadResultError(error);
            })
        }
        
    }

    back(){
        this.clearFile();
        const closeModal = new CustomEvent('refreshView');
        this.dispatchEvent(closeModal);
        window.history.go(-1);
    }

    uploadResult(result, objectName){
        this.showLoadingSpinner = false;

        if(result.isSuccess){
            this.clearFile();
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Success!!',
                    message: this.fileName + ' - Upload successfully! ' + result.msg,
                    variant: 'success',
                    mode : 'sticky'
                }),
            )

            this[NavigationMixin.Navigate]({
                type: 'standard__objectPage',
                attributes: {
                    objectApiName: objectName,
                    actionName: 'list'
                },
            });

            // window.history.go(-1);

            // setTimeout(() => {
            //     location.reload();
            // }, 0);
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
            // window.open(result.errorUrl);
            // if(result.partFails){
            //     window.open(result.errorUrl);
            // }
            
            // 下载error excel文件
            this.handleDownloadExcel(result.errorMap);
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

    // 下载 Excel 文件的处理函数
    handleDownloadExcel(errorMap) {
        if (this.dataList && errorMap) {
            // Add dynamic data to the last column
            // const dynamicData = 'New Data'; // Replace this with your dynamic data
            const lastColumnIndex = this.dataList[0].length;

            this.dataList.forEach((row, index) => {
                if(index == 0){
                    row[lastColumnIndex] = '错误'; // Add data to the last column
                }else {
                    row[lastColumnIndex] = errorMap[(index + 1) + ''];
                }
            });

            // Recreate the worksheet
            const worksheet = XLSX.utils.aoa_to_sheet(this.dataList);
            // 遍历工作表中的所有单元格
            for (const cellRef in worksheet) {
                if (cellRef !== '!ref') {
                    const cell = worksheet[cellRef];
                    if (!cell.s) cell.s = {};
                    cell.s.font = { name: '微软雅黑', sz: 10 };
                }
            }

            // 获取工作表的最后一列索引
            const lastColIndex = this.dataList[0].length - 1;
            const columnLetter = XLSX.utils.encode_col(lastColIndex); // 获取列字母

            // 遍历每一行，修改最后一列的背景色
            for (let row = 1; row < this.dataList.length + 1; row++) {
                const cell = worksheet[`${columnLetter}${row}`];
                console.log('wwwww------' + `${columnLetter}${row}`);
                if(cell){
                    if (!cell.s) cell.s = {};
                    // cell.s.font = { color: { rgb: "FF0000" } }; // 设置红色字体
                    // cell.s.font = { name: 'Arial', sz: 10 };
                    console.log('wwwww1111------');
                    cell.s.fill = { fgColor: { rgb: "FF0000" } }; // 设置红色背景1
                    console.log('wwwww22222------');
                }
            }

            // Get the original styles (font, color) from the first sheet
            const workbook = XLSX.utils.book_new();
            XLSX.utils.book_append_sheet(workbook, worksheet, 'Sheet1');

            // Generate the new Excel file with the added data
            const newFile = XLSX.write(workbook, { bookType: 'xlsx', type: 'binary' });

            // Create a blob and trigger the download
            const blob = new Blob([this.s2ab(newFile)], { type: 'application/octet-stream' });
            const link = document.createElement('a');
            link.href = URL.createObjectURL(blob);
            link.download = 'Upload_File_Error.xlsx';
            link.click();
        }
    }

    // 辅助函数：将字符串转换为 ArrayBuffer
    s2ab(s) {
        const buf = new ArrayBuffer(s.length);
        const view = new Uint8Array(buf);
        for (let i = 0; i < s.length; i++) {
            view[i] = s.charCodeAt(i) & 0xFF;
        }
        return buf;
    }
}