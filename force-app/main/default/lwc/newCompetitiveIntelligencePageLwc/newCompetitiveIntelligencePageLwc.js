/*
 * @Author: YYL
 * @LastEditors: YYL
 */
import { LightningElement ,track,api} from 'lwc';
import { LightningNavigationElement, readFile } from 'c/lwcUtils'
import { getBarcodeScanner } from 'lightning/mobileCapabilities';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import Competitive_Brand from '@salesforce/label/c.Competitive_Brand';
import Total_Number_Of_Competitors from '@salesforce/label/c.Total_Number_Of_Competitors';
import Competitive_Brands_Total from '@salesforce/label/c.Competitive_Brands_Total';
import Based_On_The_Barcode from '@salesforce/label/c.Based_On_The_Barcode';
import Competitive_Brands from '@salesforce/label/c.Competitive_Brands';
import Competition_Something from '@salesforce/label/c.Competition_Something';
import Photos_Competitive from '@salesforce/label/c.Photos_Competitive';
import INSPECTION_REPORT_SAVE from '@salesforce/label/c.INSPECTION_REPORT_SAVE';
import INSPECTION_REPORT_BACK from '@salesforce/label/c.INSPECTION_REPORT_BACK';
import saveCompetitiveIntelligence from '@salesforce/apex/newCompetitiveIntelligenceController.saveCompetitiveIntelligence';
import getCompetitiveIntelligence from '@salesforce/apex/newCompetitiveIntelligenceController.getCompetitiveIntelligence';
import saveAttachment from '@salesforce/apex/InspectorDailyReportController.saveAttachment';
import upsertProductLineStatus from '@salesforce/apex/NewInspectionDailyReportPageController.upsertProductLineStatus';

export default class NewCompetitiveIntelligencePageLwc extends LightningNavigationElement {
    label = {
        Competitive_Brand,
        Total_Number_Of_Competitors,
        Competitive_Brands_Total,
        Based_On_The_Barcode,
        Competitive_Brands,
        Competition_Something,
        Photos_Competitive,
        INSPECTION_REPORT_SAVE,             // 保存
        INSPECTION_REPORT_BACK,             // BACK
    }

    @api recordId;
    @api recordItemId;
    @api storeId;
    @api status;
    @api checkLabel;
    @api submit;
    @api productLine;

    @track spinnerFlag = false;
    @track showSave = true;
    @track disabled = false;
    @track showPage = false;
    // 存放总数的箱子SN码
    @track scannedBarcodesTotal = [];
    // 存放品牌一的箱子SN码
    @track scannedBarcodesBrand1 = [];
    // 存放品牌二的箱子SN码
    @track scannedBarcodesBrand2 = [];

    @track barcodeScanner;
    // 竞品箱子总数
    @track totalNumber;
    // 存放对应品牌的盒子数量
    @track brandNameTotalOpenInfo;
    @track brandNameTotalFlag = false;
    // 存放大于500美元以上竞争品牌数量
    @track brandNamePriceOpenInfo;
    @track brandNamePriceFlag = false;
    
    @track brandNameTotalOpenDel = [];
    @track brandNamePriceOpenDel = [];

    @track photosCompetitive = false;

    @track competitionIntelligenceInfo;

    @track delDisabled = true;

    height;
    get styleContent() {
        return true ? 'max-height: ' + this.height + 'px;' : '';
    }
    start() {
        // if (this.isMobile) {
            let _this = this;
            setTimeout(()=>{
                let h = _this.height = document.documentElement.clientHeight;
                setTimeout(()=>{
                    _this.height = h - document.documentElement.scrollHeight + document.documentElement.clientHeight;
                }, 10);
            }, 1000);
        // }
    }

    connectedCallback() {

        console.log('recordId' + this.recordId);
        console.log('submit' + this.submit);
        console.log('productline' + this.productLine);

        this.spinnerFlag = true;
        this.barcodeScanner = getBarcodeScanner();
        
        this.getCompetitiveIntelligenceInfo();

        this.start();
    }

    getCompetitiveIntelligenceInfo(){
        getCompetitiveIntelligence({
            recordId:this.recordId
        }).then(data => {
            console.log('wwww' + JSON.stringify(data.data.competitionIntelligenceInfo));
            this.competitionIntelligenceInfo = data.data.competitionIntelligenceInfo;
            this.brandNameTotalOpenInfo = data.data.brandNameTotalOpenInfo;

            // 判断brandNameTotal是否完成所有必填项
            if(this.brandNameTotalOpenInfo){
                // brandNameTotalFlag = true;
                let flag = true;
                this.brandNameTotalOpenInfo.forEach(item => {
                    if(!item.Brand__c || !item.Brand_Total__c){
                        flag = false;
                        return 
                    }
                });

                this.brandNameTotalFlag = flag;
            }else{
                this.brandNameTotalFlag = false;
            }

            this.brandNamePriceOpenInfo = data.data.brandNamePriceOpenInfo;

            // 判断brandNamePrice是否完成所有必填项
            if(this.brandNamePriceOpenInfo){
                let flag = true;
                this.brandNamePriceOpenInfo.forEach(item => {
                    if(!item.Brand__c || !item.Brand_Total__c){
                        flag = false;
                        return 
                    }
                });

                this.brandNamePriceFlag = flag;
            }else{
                this.brandNamePriceFlag = false;
            }

            this.totalNumber = this.competitionIntelligenceInfo.Total_Number_Of_Competitors__c;
            if(this.totalNumber > 0) {this.delDisabled = false;}
            
            // 设置照片
            this.photosCompetitive = data.data.photosCompetitive;

            this.spinnerFlag = false;
            this.showPage = true;

            // 每次刷新初始化删除内容
            this.brandNameTotalOpenDel = [];
            this.brandNamePriceOpenDel = [];


            // 根据是否提交判断展示状态
            if(this.status == 'Submitted'){
                this.showSave = false;
                this.disabled = true;
                this.delDisabled = true;
            }
            
            // 根据是否提交状态
            // if(this.submit){
            //     let competitiveBrand = this.competitionIntelligenceInfo.Competitive_Brand__c;
            //     if(competitiveBrand == null || competitiveBrand == ''){
            //         let Competitive_Brand = this.template.querySelector('Competitive_Brand');
            //         Competitive_Brand.style.color = 'red';
            //     }
            // }
        })
    }

    beginScanning(event) {
        let name = event.target.name;
        let index = event.target.dataset.index;
       
        const scanningOptions = {
            barcodeTypes: [this.barcodeScanner.barcodeTypes.QR,this.barcodeScanner.barcodeTypes.EAN_13],
            instructionText: 'Scan a QR Code or EAN',
            scannerSize: "FULLSCREEN",
            enableBulkScan: true,
            enableMultiScan: true,
            successText: 'Scanning complete.',
            
        };

        if (this.barcodeScanner != null && this.barcodeScanner.isAvailable()){
            // this.scannedBarcodes = [];
            this.barcodeScanner
            .scan(scanningOptions)
            .then((results)=>{
                let number = 0;
                if(name == 'totalNumber'){
                    // 过滤掉重复数据
                    number = results.length;
                    this.processScannedBarcodesTotal(results);
                    //获取此次箱子次数
                    if(this.totalNumber == '' || this.totalNumber == null){
                        this.totalNumber = 0;
                        this.competitionIntelligenceInfo.Total_Number_Of_Competitors__c = 0;
                    }
                    this.totalNumber = parseInt(this.totalNumber) + number;
                    this.competitionIntelligenceInfo.Total_Number_Of_Competitors__c = parseInt(this.competitionIntelligenceInfo.Total_Number_Of_Competitors__c) + number;
                }else if(name == 'brandName1'){
                    // 过滤掉重复数据
                    number = results.length;
                    this.processScannedBarcodesBrand1(results);
                    if(this.brandNameTotalOpenInfo[index].Brand_Total__c == ''){
                        this.brandNameTotalOpenInfo[index].Brand_Total__c = 0;
                    }
                    this.brandNameTotalOpenInfo[index].Brand_Total__c = parseInt(this.brandNameTotalOpenInfo[index].Brand_Total__c) + number;
                }else if(name == 'brandName2'){
                    // 过滤掉重复数据
                    number = results.length;
                    this.processScannedBarcodesBrand2(results);
                    if(this.brandNamePriceOpenInfo[index].Brand_Total__c == ''){
                        this.brandNamePriceOpenInfo[index].Brand_Total__c = 0;
                    }
                    this.brandNamePriceOpenInfo[index].Brand_Total__c = parseInt(this.brandNamePriceOpenInfo[index].Brand_Total__c) + number;
                }
                
                // this.dispatchEvent(
                //     new ShowToastEvent({
                //         title: 'Successful Scan',
                //         message: this.description,
                //         variant: 'success'
                //     })
                // );

                this.dispatchEvent(new CustomEvent(
                    "select", {
                        detail: {
                            hasEdit : true
                        }
                    })
                );
            })
            .catch((error)=>{
                console.error(error);
            })
            .finally(()=>{
                this.barcodeScanner.dismiss();
            });
        }
        else {
            console.log("BarcodeScanner unavailable. Non-mobile device?");
        }
    }

    processScannedBarcodesTotal(barcodes) {
        console.log(JSON.stringify(barcodes));
        // 剔除掉重复数据
        this.scannedBarcodesTotal = this.scannedBarcodesTotal.concat(barcodes);
        this.description = this.scannedBarcodesTotal.map((barcode) => barcode.value).join("\n");
    }

    processScannedBarcodesBrand1(barcodes) {
        console.log(JSON.stringify(barcodes));
        // 剔除掉重复数据
        this.scannedBarcodesBrand1 = this.scannedBarcodesBrand1.concat(barcodes);
        this.description = this.scannedBarcodesBrand1.map((barcode) => barcode.value).join("\n");
    }

    processScannedBarcodesBrand2(barcodes) {
        console.log(JSON.stringify(barcodes));
        // 剔除掉重复数据
        this.scannedBarcodesBrand2 = this.scannedBarcodesBrand2.concat(barcodes);
        this.description = this.scannedBarcodesBrand2.map((barcode) => barcode.value).join("\n");
    }

    // 获取当前扫码的sn码
    get scannedBarcodesAsString() {
        return this.scannedBarcodes.map((barcode) => barcode.value).join("\n");
    }

    // 更改竞品箱子数量
    handleTotalNumber(event){
        let value = event.target.value;
        // 根据正则表达式判断输入数据
        let pattern = /^[0-9]*[1-9][0-9]*$/;
        let flag = pattern.test(value);
        console.log(flag);
        if(flag){
            this.competitionIntelligenceInfo.Total_Number_Of_Competitors__c = parseInt(value);;
            this.totalNumber = parseInt(value);

            this.delDisabled = false;

            this.dispatchEvent(new CustomEvent(
                "select", {
                    detail: {
                        hasEdit : true
                    }
                })
            );
        }else if(value == ''){
            this.competitionIntelligenceInfo.Total_Number_Of_Competitors__c = value;
            this.totalNumber = value;
            this.delDisabled = true;

            // 返回父级元素页面
            this.dispatchEvent(new CustomEvent(
                "select", {
                    detail: {
                        hasEdit : true
                    }
                })
            );
        }
        // if(value != ''){
        //     if(flag){
        //         this.competitionIntelligenceInfo.Total_Number_Of_Competitors__c = parseInt(value);;
        //         this.totalNumber = parseInt(value);
        //     }
        // }else{
        //     this.competitionIntelligenceInfo.Total_Number_Of_Competitors__c = value;
        //     this.totalNumber = value;
        // }
    }

    // 更改箱子数量
    handleBrandNameNumber(event){
        let index = event.target.dataset.index;
        let name = event.target.name;
        let value = event.target.value;
        // 根据正则表达式判断输入数据
        let pattern = /^[0-9]*[1-9][0-9]*$/;
        let flag = pattern.test(value);

        if(flag){
            if(name == 'brandName1'){
                this.brandNameTotalOpenInfo[index].Brand_Total__c = parseInt(value);
            }else if(name == 'brandName2'){
                this.brandNamePriceOpenInfo[index].Brand_Total__c = parseInt(value);
            }

            this.dispatchEvent(new CustomEvent(
                "select", {
                    detail: {
                        hasEdit : true
                    }
                })
            );
        }else if(value == ''){
            if(name == 'brandName1'){
                this.brandNameTotalOpenInfo[index].Brand_Total__c = value;
            }else if(name == 'brandName2'){
                this.brandNamePriceOpenInfo[index].Brand_Total__c = value;
            }

            this.dispatchEvent(new CustomEvent(
                "select", {
                    detail: {
                        hasEdit : true
                    }
                })
            );
        }

        // if(value != ''){
            
        // }else{
        //     if(name == 'brandName1'){
        //         this.brandNameTotalOpenInfo[index].Brand_Total__c = '';
        //     }else if(name == 'brandName2'){
        //         this.brandNamePriceOpenInfo[index].Brand_Total__c = '';
        //     }
        // }
    }

    // 更改竞品箱子数量
    handleBrandName(event){
        let index = event.target.dataset.index;
        let name = event.target.name;
        let value = event.target.value;
        if(name == 'brandName1'){
            this.brandNameTotalOpenInfo[index].Brand__c = value;
        }else if(name == 'brandName2'){
            this.brandNamePriceOpenInfo[index].Brand__c = value;
        }

        console.log('brandNameOpenInfo1' + JSON.stringify(this.brandNameTotalOpenInfo));
        console.log('brandNameOpenInfo2' + JSON.stringify(this.brandNamePriceOpenInfo));

        this.dispatchEvent(new CustomEvent(
            "select", {
                detail: {
                    hasEdit : true
                }
            })
        );
    }

    // 添加盒子存放对应品牌
    handleAddBrandName(event){
        let name = event.target.name;
        let brandNameInfo = {
            Product_Line__c:'TV',
            Brand__c:'',
            Brand_Total__c:'',
        }

        if(name == 'brandName1'){
            if(this.brandNameTotalOpenInfo == null){
                this.brandNameTotalOpenInfo = [];
            }
            this.brandNameTotalOpenInfo.push(brandNameInfo);
        }else if(name == 'brandName2'){
            if(this.brandNamePriceOpenInfo == null){
                this.brandNamePriceOpenInfo = [];
            }
            this.brandNamePriceOpenInfo.push(brandNameInfo);
        }

        this.dispatchEvent(new CustomEvent(
            "select", {
                detail: {
                    hasEdit : true
                }
            })
        );
    }

    handleCompetitiveBrand(event){
        this.competitionIntelligenceInfo.Competitive_Brand__c = event.detail.value;

        this.dispatchEvent(new CustomEvent(
            "select", {
                detail: {
                    hasEdit : true
                }
            })
        );
    }

    handleCompetitionSomething(event){
        console.log(event.detail.value);
        this.competitionIntelligenceInfo.Competition_Something__c = event.detail.value;

        this.dispatchEvent(new CustomEvent(
            "select", {
                detail: {
                    hasEdit : true
                }
            })
        );
    }

    // Save click
    @api
    handleSave() {
        this.spinnerFlag = true;
        console.log('Data =' + JSON.stringify(this.competitionIntelligenceInfo));
        if(this.photosCompetitive.length > 0){
            this.competitionIntelligenceInfo.Photos_Competitive__c = this.photosCompetitive.join(',');
        }else{
            this.competitionIntelligenceInfo.Photos_Competitive__c = '';
        }
        saveCompetitiveIntelligence({
            competitionIntelligenceInfoJson:JSON.stringify(this.competitionIntelligenceInfo),
            brandNameTotalOpenInfoJson:JSON.stringify(this.brandNameTotalOpenInfo),
            brandNamePriceOpenInfoJson:JSON.stringify(this.brandNamePriceOpenInfo),
            brandNameTotalOpenDelJson:JSON.stringify(this.brandNameTotalOpenDel),
            brandNamePriceOpenDelJson:JSON.stringify(this.brandNamePriceOpenDel)
        }).then(data => {
            this.spinnerFlag = false;
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Success',
                    variant: 'success'
                })
            );

            // 更新产品线状态为continue
            upsertProductLineStatus({
                recordId:this.recordId,
                status:'Continue',
                productLineChecked:''
            }).catch(error => {
                this.catchError(JSON.stringify(error));
            });

            // 刷新
            this.dispatchEvent(new CustomEvent('refreshdata'));
            this.dispatchEvent(new CustomEvent(
                "select", {
                    detail: {
                        hasEdit : false,
                        saveFlag : 'competitionIntelligence'
                    }
                })
            );
            // 刷新当前页面
            this.getCompetitiveIntelligenceInfo();
        })

    }


    get acceptedFormats() {
        return ['.png','.jpg','.jfif','.jpeg','.pjp','.pjpeg','.gif'];
    }

    changeUploadFinished(event){
        const uploadedFiles = event.detail.files;
        saveAttachment({
            contentDocumentId : uploadedFiles[0].documentId,
            contentVersionId : uploadedFiles[0].contentVersionId 
        }).then(result => {
            if (result.isSucess) { 
                this.photosCompetitive.push(result.imageUrl);
                this.dispatchEvent(new CustomEvent(
                    "select", {
                        detail: {
                            hasEdit : true
                        }
                    })
                );
            }else{
                this.dispatchEvent(new ShowToastEvent({
                    title: 'error',
                    message: result.errorMsg,
                    variant: 'error',
                }));    
            }
            this.isShowSpinner = false;
        }).catch(error => {
            this.isShowSpinner = false;
            this.dispatchEvent(new ShowToastEvent({
                title: 'error',
                message: this.label.Error,
                variant: 'error',
            }));
        });    
    }

    handleBack(){
        this.dispatchEvent(new CustomEvent('goback'));

        this.dispatchEvent(new CustomEvent('refreshdata'));
    }

    handleDeleteFile(event){
        let index = event.target.dataset.index;
        this.photosCompetitive.splice(index,1);
        // 返回父级元素页面
        this.dispatchEvent(new CustomEvent(
            "select", {
                detail: {
                    hasEdit : true
                }
            })
        );
    }

    handleDelTotal(evnet){
        let index = evnet.target.dataset.index;
        this.brandNameTotalOpenDel.push(this.brandNameTotalOpenInfo[index]);
        this.brandNameTotalOpenInfo.splice(index,1);

        // 返回父级元素页面
        this.dispatchEvent(new CustomEvent(
            "select", {
                detail: {
                    hasEdit : true
                }
            })
        );
    }

    handleDelPrice(evnet){
        let index = evnet.target.dataset.index;
        this.brandNamePriceOpenDel.push(this.brandNamePriceOpenInfo[index]);
        this.brandNamePriceOpenInfo.splice(index,1);

        // 返回父级元素页面
        this.dispatchEvent(new CustomEvent(
            "select", {
                detail: {
                    hasEdit : true
                }
            })
        );
    }

    handleIncrement() {
        console.log('XXXsss' + this.totalNumber);
        console.log('XXXzzz' + this.totalNumber == undefined);

        if(this.totalNumber == undefined) {
            this.totalNumber = parseInt(0);
            console.log('数值' + this.totalNumber);
        }
        this.totalNumber = parseInt(this.totalNumber)
        this.totalNumber += 1;
        this.delDisabled = false;

        this.competitionIntelligenceInfo.Total_Number_Of_Competitors__c = this.totalNumber;

        // 返回父级元素页面
        this.dispatchEvent(new CustomEvent(
            "select", {
                detail: {
                    hasEdit : true
                }
            })
        );

    }

    handleDecrement() {

        this.totalNumber = parseInt(this.totalNumber);
        if (this.totalNumber > 0) {
            this.delDisabled = false;
            this.totalNumber -= 1;
        }
        if(this.totalNumber == 0){
            this.delDisabled = true;
        }

        this.competitionIntelligenceInfo.Total_Number_Of_Competitors__c = this.totalNumber;

        // 返回父级元素页面
        this.dispatchEvent(new CustomEvent(
            "select", {
                detail: {
                    hasEdit : true
                }
            })
        );
    }

}