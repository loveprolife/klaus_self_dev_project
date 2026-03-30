/*
 * @Author: YYL
 * @LastEditors: YYL
 */
import { LightningElement ,track, api} from 'lwc';
import { LightningNavigationElement, readFile } from 'c/lwcUtils'
import { getBarcodeScanner } from 'lightning/mobileCapabilities';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import Floor_Box from '@salesforce/label/c.Floor_Box';
import Boxes_on_Floor from '@salesforce/label/c.Boxes_on_Floor';
import Add_Boxed from '@salesforce/label/c.Add_Boxed';
import BOF_Photo from '@salesforce/label/c.BOF_Photo';
import Inventory_Today_Visit from '@salesforce/label/c.Inventory_Today_Visit';
import Boxed_Photo from '@salesforce/label/c.Boxed_Photo';
import INSPECTION_REPORT_SAVE from '@salesforce/label/c.INSPECTION_REPORT_SAVE';
import INSPECTION_REPORT_BACK from '@salesforce/label/c.INSPECTION_REPORT_BACK';
import getInventory from '@salesforce/apex/newInventory.getInventory';
import saveInventory from '@salesforce/apex/newInventory.saveInventory';
import upsertProductLineStatus from '@salesforce/apex/NewInspectionDailyReportPageController.upsertProductLineStatus';
import saveAttachment from '@salesforce/apex/InspectorDailyReportController.saveAttachment';

export default class NewInventoryPageLwc extends LightningNavigationElement {
    label = {
        Floor_Box,
        Boxes_on_Floor,
        Add_Boxed,
        BOF_Photo,
        Inventory_Today_Visit,
        Boxed_Photo,
        INSPECTION_REPORT_SAVE,
        INSPECTION_REPORT_BACK,
    }

    @api recordId;
    @api recordItemId;
    @api storeId;
    @api status;
    @api checkLabel;
    @api submit;
    
    // 表单详情
    @track inventoryInfo;
    @track spinnerFlag = false;
    @track showSave = true;
    @track scannedBarcodes;
    @track barcodeScanner;
    @track floorBoxTotal;
    @track addBoxedTotal;

    // 存放图片数据
    @track imgBof = false;
    @track imgBoxed = false;

    
    @track addBoxedFlag = false;
    @track boxedPhotoFlag = false;

    // 存放新增数据
    @track barcodeFloorBox;
    @track barcodeAddBoxed;

    // 存放删除数据
    @track barcodeFloorBoxDel = [];
    @track barcodeAddBoxedDel = [];

    // 是否可修改
    @track disabled = false;
    @track showPage = false;
    //是否可以操作-1
    @track delDisabled = true;
    @track delBoxedDisabled = true;

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

    // 取消下拉刷新
    disablePullToRefresh() {
        const disable_ptr_event = new CustomEvent("updateScrollSettings", {
            detail: {
                isPullToRefreshEnabled: false,
            },
            bubbles: true,
            composed: true,
        });
        this.dispatchEvent(disable_ptr_event);
    }

    connectedCallback() {
        this.spinnerFlag = true;
        this.barcodeScanner = getBarcodeScanner();
        // 取消下拉刷新
        this.disablePullToRefresh();
        getInventory({
            recordId:this.recordId
        }).then(data => {
            console.log('inventoryInfo' + JSON.stringify(data.data.inventoryInfo));
            console.log('barcodeFloorBox' + JSON.stringify(data.data.barcodeFloorBox));
            console.log('barcodeAddBoxed' + JSON.stringify(data.data.barcodeAddBoxed));
            this.inventoryInfo = data.data.inventoryInfo;
            this.barcodeFloorBox = data.data.barcodeFloorBox;
            this.barcodeAddBoxed = data.data.barcodeAddBoxed;

            // 设置暂存的箱子数
            this.floorBoxTotal = this.inventoryInfo.FloorBoxTotal__c;
            this.addBoxedTotal = this.inventoryInfo.AddBoxedTotal__c;
            console.log('初始化数据' + this.floorBoxTotal + ':' + this.addBoxedTotal);
            if(this.floorBoxTotal > 0) {this.delDisabled = false;}
            if(this.addBoxedTotal > 0) {this.delBoxedDisabled = false;}


            if(this.inventoryInfo.BoxesFloor__c){
                if(this.inventoryInfo.BoxesFloor__c == 'Yes'){
                    this.addBoxedFlag = true;
                }
            }

            if(this.inventoryInfo.InventoryTodayVisit__c){
                if(this.inventoryInfo.InventoryTodayVisit__c == 'Yes'){
                    this.boxedPhotoFlag = true;
                }
            }

            // 设置照片
            this.imgBof = data.data.imgBof;
            this.imgBoxed = data.data.imgBoxed;

            console.log('wwwwinventoryInfo' + JSON.stringify(this.inventoryInfo));

            this.spinnerFlag = false;
            this.showPage = true;

            // 刷新删除数数据
            this.barcodeFloorBoxDel = [];
            this.barcodeAddBoxedDel = [];
            
            // 根据状态判断是否可修改
            if(this.status == 'Submitted'){
                this.disabled = true;
                this.showSave = false;
                this.delBoxedDisabled = true;
                this.delDisabled = true;
            }
        })
        this.start();
    }

    beginScanning(event) {
        let name = event.target.name;
        // let index = event.target.dataset.index;
       
        const scanningOptions = {
            barcodeTypes: [this.barcodeScanner.barcodeTypes.QR,this.barcodeScanner.barcodeTypes.EAN_13],
            instructionText: 'Scan a QR Code or EAN',
            scannerSize: "FULLSCREEN",
            enableBulkScan: true,
            enableMultiScan: true,
            successText: 'Scanning complete.',
        };

        if (this.barcodeScanner != null && this.barcodeScanner.isAvailable()){
            this.scannedBarcodes = [];
            this.barcodeScanner
            .scan(scanningOptions)
            .then((results)=>{
                console.log(results);
                let number = results.length;
                this.processScannedBarcodes(results);

                // 处理扫码返回数据为标准格式
                let boxed = [];
                for(var i in results){
                    let box = {
                        Type__c:results[i].type,
                        Value__c:results[i].value
                    }
                    boxed.push(box);
                }

                if(name == 'Floor_Box'){
                    if(this.barcodeFloorBox == null){
                        this.barcodeFloorBox = [];
                    }

                    if(this.floorBoxTotal == null || this.floorBoxTotal == ''){
                        this.floorBoxTotal = 0;
                    }

                    this.barcodeFloorBox = this.barcodeFloorBox.concat(boxed);
                    // 计算地上的箱子数量
                    this.floorBoxTotal = parseInt(this.floorBoxTotal) + number;
                    this.inventoryInfo.FloorBoxTotal__c = this.floorBoxTotal;
                    if(this.floorBoxTotal > 0) {this.delDisabled = false;}
                }else if(name == 'Add_Boxed'){

                    if(this.barcodeAddBoxed == null){
                        this.barcodeAddBoxed = [];
                    }

                    if(this.addBoxedTotal == null || this.addBoxedTotal == ''){
                        this.addBoxedTotal = 0;
                    }

                    // this.barcodeAddBoxed = this.barcodeAddBoxed.concat(boxed);
                    // 计算地上的箱子数量
                    this.addBoxedTotal = parseInt(this.addBoxedTotal) + number;
                    this.inventoryInfo.AddBoxedTotal__c = this.addBoxedTotal;
                    if(this.addBoxedTotal > 0) {this.delBoxedDisabled = false;}
                }
                
                // this.dispatchEvent(
                //     new ShowToastEvent({
                //         title: 'Successful Scan',
                //         message: this.description,
                //         variant: 'success'
                //     })
                // );

                // 返回父级元素页面
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

    processScannedBarcodes(barcodes) {
        console.log(JSON.stringify(barcodes));
        this.scannedBarcodes = this.scannedBarcodes.concat(barcodes);
        this.description = this.scannedBarcodes.map((barcode) => barcode.value).join("\n");
    }

    // 获取当前扫码的sn码
    // get scannedBarcodesAsString() {
    //     return this.scannedBarcodes.map((barcode) => barcode.value).join("\n");
    // }

    // delFloorBox(evnet){
    //     let index = evnet.target.dataset.index;
    //     // let items = this.barcodeFloorBox[index];
    //     this.barcodeFloorBoxDel.push(this.barcodeFloorBox[index]);
    //     this.barcodeFloorBox.splice(index,1);
    //     if(this.floorBoxTotal == null || this.floorBoxTotal == ''){
    //         this.floorBoxTotal = 0;
    //         this.delDisabled = true;
    //     }
    //     --this.floorBoxTotal; 

    //     // 返回父级元素页面
    //     this.dispatchEvent(new CustomEvent(
    //         "select", {
    //             detail: {
    //                 hasEdit : true
    //             }
    //         })
    //     );
    // }

    // delAddBoxed(evnet){
    //     let index = evnet.target.dataset.index;
    //     // let items = this.barcodeAddBoxed[index];
    //     this.barcodeAddBoxedDel.push(this.barcodeAddBoxed[index]);
    //     this.barcodeAddBoxed.splice(index,1);
    //     if(this.addBoxedTotal == null || this.addBoxedTotal == ''){
    //         this.addBoxedTotal = 0;
    //     }else{
    //         --this.addBoxedTotal;
    //     }

    //     this.inventoryInfo.AddBoxedTotal__c = this.addBoxedTotal;
    //     if(this.addBoxedTotal > 0) {this.addBoxedTotal = false;}
        
    //     // 返回父级元素页面
    //     this.dispatchEvent(new CustomEvent(
    //         "select", {
    //             detail: {
    //                 hasEdit : true
    //             }
    //         })
    //     );
    // }

    handleBoxesFloor(event){
        console.log('BoxesFloor__c='+event.detail.value);
        let value = event.detail.value;
        this.inventoryInfo.BoxesFloor__c = value;

        // 根据选项值判断是否展示下级问题
        if(value == 'Yes'){
            this.addBoxedFlag = true;
        }else if(value == 'No'){
            this.addBoxedFlag = false;
            // 如果关联数据不为空，则清楚掉
            this.addBoxedTotal = '';
            this.inventoryInfo.AddBoxedTotal__c = '';

            // if(this.barcodeAddBoxed){
            //     this.barcodeAddBoxedDel = this.barcodeAddBoxedDel.concat(this.barcodeAddBoxed);
            //     this.barcodeAddBoxed = [];
            // }
        }

        // 返回父级元素页面
        this.dispatchEvent(new CustomEvent(
            "select", {
                detail: {
                    hasEdit : true
                }
            })
        );
    }

    handleChangeFloorBoxTotal(event){
        let value = event.target.value;

        // 根据正则表达式判断输入数据
        let pattern = /^[0-9]*[1-9][0-9]*$/;
        let flag = pattern.test(value);

        if(flag){
            this.inventoryInfo.FloorBoxTotal__c = parseInt(value);
            this.floorBoxTotal = parseInt(value);
            this.delDisabled = false;
            // 返回父级元素页面
            this.dispatchEvent(new CustomEvent(
                "select", {
                    detail: {
                        hasEdit : true
                    }
                })
            );
        }else if(value == ''){
            this.inventoryInfo.FloorBoxTotal__c = value;
            this.floorBoxTotal = value;
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

        // if(value == ''){
            // this.inventoryInfo.FloorBoxTotal__c = value;
            // this.floorBoxTotal = value;
        // }else{
        //     
        // }
    }
    
    handleChangeAddBoxedTotal(event){
        let value = event.target.value;
        // 根据正则表达式判断输入数据
        let pattern = /^[0-9]*[1-9][0-9]*$/;
        let flag = pattern.test(value);

        if(flag){
            this.inventoryInfo.AddBoxedTotal__c = parseInt(value);
            this.addBoxedTotal = parseInt(value);
            this.delBoxedDisabled = false;
            // 返回父级元素页面
            this.dispatchEvent(new CustomEvent(
                "select", {
                    detail: {
                        hasEdit : true
                    }
                })
            );
        }else if(value == ''){
            this.inventoryInfo.AddBoxedTotal__c = value;
            this.addBoxedTotal = value;
            this.delBoxedDisabled = true;
            // 返回父级元素页面
            this.dispatchEvent(new CustomEvent(
                "select", {
                    detail: {
                        hasEdit : true
                    }
                })
            );
        }

        // if(value == ''){
            // this.inventoryInfo.AddBoxedTotal__c = value;
            // this.addBoxedTotal = value;
        // }else{
        //     
        // }
    }

    handleInventoryTodayVisit(event){
        console.log('InventoryTodayVisit__c='+event.detail.value);
        let value = event.detail.value;
        this.inventoryInfo.InventoryTodayVisit__c = value;

        // 根据选项值判断是否展示下级问题
        if(value == 'Yes'){
            this.boxedPhotoFlag = true;
        }else if(value == 'No'){
            this.boxedPhotoFlag = false;
        }

        // 返回父级元素页面
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
        console.log('data='+JSON.stringify(this.inventoryInfo));
        if(this.imgBof.length > 0){
            this.inventoryInfo.Img_Bof__c = this.imgBof.join(',');
        }else{
            this.inventoryInfo.Img_Bof__c = '';
        }

        if(this.imgBoxed.length > 0){
            this.inventoryInfo.Img_Boxed__c = this.imgBoxed.join(',');
        }else{
            this.inventoryInfo.Img_Boxed__c = '';
        }
        saveInventory({
            inventoryInfoJson:JSON.stringify(this.inventoryInfo),
            barcodeFloorBoxJson:JSON.stringify(this.barcodeFloorBox),
            barcodeAddBoxedJson:JSON.stringify(this.barcodeAddBoxed),
            barcodeFloorBoxDelJson:JSON.stringify(this.barcodeFloorBoxDel),
            barcodeAddBoxedDelJson:JSON.stringify(this.barcodeAddBoxedDel),
        }).then(data => {
            this.spinnerFlag = false;
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Success',
                    message: data.message,
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
            // 返回父级元素页面
            this.dispatchEvent(new CustomEvent(
                "select", {
                    detail: {
                        hasEdit : false,
                        saveFlag : 'inventory'
                    }
                })
            );
        })
    }

    get yesNo() {
        return [
            { label: 'Yes', value: 'Yes' },
            { label: 'No', value: 'No' },
        ];
    }

    get acceptedFormats() {
        return ['.png','.jpg','.jfif','.jpeg','.pjp','.pjpeg','.gif'];
    }

    // changeUploadFinishedBof(event){
    //     const uploadedFiles = event.detail.files;
    //     saveAttachment({
    //         contentDocumentId : uploadedFiles[0].documentId,
    //         contentVersionId : uploadedFiles[0].contentVersionId 
    //     }).then(result => {
    //         if (result.isSucess) {
    //             this.imgBof.push(result.imageUrl);
    //             // 返回父级元素页面
    //             this.dispatchEvent(new CustomEvent(
    //                 "select", {
    //                     detail: {
    //                         hasEdit : true
    //                     }
    //                 })
    //             );
    //         }else{
    //             this.dispatchEvent(new ShowToastEvent({
    //                 title: 'error',
    //                 message: result.errorMsg,
    //                 variant: 'error',
    //             }));    
    //         }
    //         this.isShowSpinner = false;
    //     }).catch(error => {
    //         this.isShowSpinner = false;
    //         this.dispatchEvent(new ShowToastEvent({
    //             title: 'error',
    //             message: this.label.Error,
    //             variant: 'error',
    //         }));
    //     });    
    // }

    // changeUploadFinishedBoxed(event){
    //     const uploadedFiles = event.detail.files;
    //     saveAttachment({
    //         contentDocumentId : uploadedFiles[0].documentId,
    //         contentVersionId : uploadedFiles[0].contentVersionId 
    //     }).then(result => {
    //         if (result.isSucess) { 
    //             this.imgBoxed.push(result.imageUrl);
    //             // 返回父级元素页面
    //             this.dispatchEvent(new CustomEvent(
    //                 "select", {
    //                     detail: {
    //                         hasEdit : true
    //                     }
    //                 })
    //             );
    //             // this.sampleImages[this.photoIndex].sampleImages.Sample_Images__c = result.imageUrl; 
    //             // this.sampleImages[this.photoIndex].sampleImages.ImageUrl__c = result.viewImageUrl;
    //             // this.showAddPhotoPage = false;
    //             // this.showPhotoPage = true;
    //             // this.photoIndex = '';
    //             // this.photo = null;
    //             // this.isChange = true;              
    //         }else{
    //             this.dispatchEvent(new ShowToastEvent({
    //                 title: 'error',
    //                 message: result.errorMsg,
    //                 variant: 'error',
    //             }));    
    //         }
    //         this.isShowSpinner = false;
    //     }).catch(error => {
    //         this.isShowSpinner = false;
    //         this.dispatchEvent(new ShowToastEvent({
    //             title: 'error',
    //             message: this.label.Error,
    //             variant: 'error',
    //         }));
    //     });    
    // }

    handleBack(){
        this.dispatchEvent(new CustomEvent('goback'));

        this.dispatchEvent(new CustomEvent('refreshdata'));
    }

    // handleDeleteFile(event){
    //     var id = event.target.dataset.id;
    //     var index = event.target.dataset.index;
    //     if(id == 'imgBof'){
    //         this.imgBof.splice(index,1);
    //     }else if(id == 'imgBoxed'){
    //         this.imgBoxed.splice(index,1);
    //     }

    //     // 返回父级元素页面
    //     this.dispatchEvent(new CustomEvent(
    //         "select", {
    //             detail: {
    //                 hasEdit : true
    //             }
    //         })
    //     );
        
    // }
    handleIncrement() {
        console.log('XXXsss' + this.floorBoxTotal);
        console.log('XXXzzz' + this.floorBoxTotal == undefined);

        if(this.floorBoxTotal == undefined) {
            this.floorBoxTotal = parseInt(0);
            console.log('数值' + this.floorBoxTotal);
        }
        this.floorBoxTotal = parseInt(this.floorBoxTotal);
        this.floorBoxTotal += 1;
        this.delDisabled = false;
        this.inventoryInfo.FloorBoxTotal__c = this.floorBoxTotal;
        console.log('----'+this.inventoryInfo.FloorBoxTotal__c);

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
        this.floorBoxTotal = parseInt(this.floorBoxTotal);
        if (this.floorBoxTotal > 0) {
            this.delDisabled = false;

            this.floorBoxTotal -= 1;
        }
        if(this.floorBoxTotal == 0){
            this.delDisabled = true;
        }

        this.inventoryInfo.FloorBoxTotal__c = this.floorBoxTotal;
        console.log('----'+this.inventoryInfo.FloorBoxTotal__c);
        // 返回父级元素页面
        this.dispatchEvent(new CustomEvent(
            "select", {
                detail: {
                    hasEdit : true
                }
            })
        );
    }

    handleBoxedIncrement() {
        console.log('XXXBoxedsss' + this.addBoxedTotal);
        console.log('XXXBoxedzzz' + this.addBoxedTotal == undefined);

        if(this.addBoxedTotal == undefined) {
            this.addBoxedTotal = parseInt(0);
            console.log('数值' + this.addBoxedTotal);
        }
        this.addBoxedTotal = parseInt(this.addBoxedTotal);
        this.addBoxedTotal += 1;
        this.delBoxedDisabled = false;
        this.inventoryInfo.AddBoxedTotal__c = this.addBoxedTotal;
        // 返回父级元素页面
        this.dispatchEvent(new CustomEvent(
            "select", {
                detail: {
                    hasEdit : true
                }
            })
        );

    }

    handleBoxedDecrement() {
        console.log('XXXBoxedsssDecrement' + this.addBoxedTotal);
        this.addBoxedTotal = parseInt(this.addBoxedTotal);
        if (this.addBoxedTotal > 0) {
            this.delBoxedDisabled = false;
            this.addBoxedTotal -= 1;
        }
        if(this.addBoxedTotal == 0){
            this.delBoxedDisabled = true;
        }
        this.inventoryInfo.AddBoxedTotal__c = this.addBoxedTotal;
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