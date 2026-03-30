import { LightningElement, api, track } from 'lwc';
import { LightningNavigationElement } from 'c/lwcUtils';
import searchEventReceipt from '@salesforce/apex/EventSalesController.searchEventReceipt';
import searchProductInfo from '@salesforce/apex/EventSalesController.searchProductInfo';
import saveEventSalesDetail from '@salesforce/apex/EventSalesController.saveEventSalesDetail';
import New_Event_Sales_Title from '@salesforce/label/c.New_Event_Sales_Title';


export default class EventSalesNewLwc extends LightningNavigationElement {
    @api recordId;

    @track isModalOpen = false; // new 新建页面
    @track isShowSpinner = false;
    @track type = 'Product';

    @track isProductType = true;
    @track isDiscountType = false;
    @track isDiscountType = false;

    @track eventReceipt = {}; // 父级信息
    @track eventSales = {};
    @track eventSalesAccessories = {};
    // new data
    @track productInfo = {};
    // @track productCurrencyIsoCode = '';
    @track isHavePorduct = false;
    @track isShowWarranty = false;
    @track isShowAccessories = false;
    @track isHaveAccessories = false;
    @track accessoriesInfo = {};
    // @track accessoriesCurrencyIsoCode = '';
    @track warrantyOnchange = false;// 手动修改过Warranty price increase，默认为没有修改过


    label = {
        New_Event_Sales_Title,
    }

    // 手机端
    get isMobile() {
        var userAgent = navigator.userAgent;
        if (/iphone|iPhone|ipad|iPad|ipod|iPod|iOS|ios/.test(userAgent) || /android|Android/.test(userAgent)) {  
            return true;
        } else { 
            return false;
        }
    }

    connectedCallback(){
        // 查询基本信息
        // this.searchEventReceipt();
        this.clearData();
    }

    clearData(){
        console.log('wwwww---clearData');
        // this.eventReceipt = {};
        this.eventSales = {};
        this.eventSalesAccessories = {};

        this.isProductType = true;
        this.isDiscountType = false;
        this.type = 'Product';

        this.productInfo = {};
        this.isHavePorduct = false;

        this.accessoriesInfo = {};
        this.isHaveAccessories = false;

        this.isShowWarranty = false;
        this.isShowAccessories = false;

        // this.productCurrencyIsoCode = '';
        // this.accessoriesCurrencyIsoCode = '';

        this.warrantyOnchange = false;

        this.template.querySelectorAll('lightning-input').forEach(element => {
            element.checked = false;
        });
    }
    openModal() {
        this.isModalOpen = true;
        this.clearData();

        // 查询基本信息
        this.searchEventReceipt();
    }
    closeModal() {
        this.isModalOpen = false;
        this.clearData();
    }
    handleTypeChange(event){
        console.log('wwwww--type--' + event.target.value);
        this.type = event.target.value
        this.isProductType = false;
        this.isDiscountType = false;
        if(!this.judgeFieldValueEmpty(this.type)){
            if(this.type === 'Product'){
                this.isProductType = true;
            }else if(this.type === 'Discount'){
                this.isDiscountType = true;
            }
        }
    }
    // field赋值
    handleFieldChange(event){
        const fieldName = event.target.dataset.fieldName;
        const fieldValue = event.target.value;
        this.eventSales[fieldName] = fieldValue;
        if(fieldName == 'Product__c' && !this.judgeFieldValueEmpty(fieldValue)){
            // 查询产品详情
            this.searchProductInfo(event.target.value, 1);
        }
        // 关联Warranty,选择 Warranty_period_increase__c，自动生成 Warranty_price_increase__c 值，手动修改后不再联动，Warranty_price_increase__c为空必须联动
        if(fieldName == 'Warranty_period_increase__c' && !this.judgeFieldValueEmpty(fieldValue) && 
            (!this.warrantyOnchange || this.judgeFieldValueEmpty(this.eventSales.Warranty_price_increase__c))){
            const num = Number(fieldValue);
            //lzx 2025-04-10 
            //this.eventSales.Warranty_price_increase__c = num * 10;
        }
        if(fieldName == 'Warranty_price_increase__c'){
            this.warrantyOnchange = true;
        }
    }

    handleAccessoriesFieldChange(event){
        const fieldName = event.target.dataset.fieldName;
        const fieldValue = event.target.value;
        this.eventSalesAccessories[fieldName] = fieldValue;
        if(fieldName == 'Accessories__c' && !this.judgeFieldValueEmpty(fieldValue)){
            // 查询产品详情
            this.searchProductInfo(event.target.value, 2);
        }
    }
    // 保修期
    handleWarrantyChange(event){
        if(event.target.checked){
            this.isShowWarranty = true;
        }else {
            this.isShowWarranty = false;
        }
    }
    // 配件
    handleAccessoriesChange(event){
        if(event.target.checked){
            this.isShowAccessories = true;
        }else {
            this.isShowAccessories = false;
        }
    }
    // 保存
    handleSave(){
        console.log('wwwww--eventReceipt--' + JSON.stringify(this.eventReceipt));
        console.log('wwwww--eventSales--' + JSON.stringify(this.eventSales));
        console.log('wwwww--eventSalesAccessories--' + JSON.stringify(this.eventSalesAccessories));
        if (this.verifyField()) {
            this.saveDetail(false);
        }else {
            return;
        }
    }
    handleSaveAndNew(){
        if (this.verifyField()) {
            this.saveDetail(true);
        }else {
            return;
        }
    }
    // 验证必填字段
    verifyField(){
        this.isShowSpinner = true;
        let canSaveRecord = true;
        if(this.judgeFieldValueEmpty(this.type)){
            canSaveRecord = false;
        }

        this.template.querySelectorAll('lightning-input-field').forEach(element => {
            if(!element.reportValidity()) {
                canSaveRecord = false;
            }
        });
        if(!canSaveRecord) {
            this.showError('Required fields are not filled in');
            this.isShowSpinner = false;
        }
        return canSaveRecord;
    }
    // 保存数据
    saveDetail(flag){
        console.log('wwwwww--isShowWarranty---' + this.isShowWarranty);
        saveEventSalesDetail({ 
            eventReceiptJson : JSON.stringify(this.eventReceipt),
            eventSalesJson : JSON.stringify(this.eventSales),
            eventSalesAccessoriesJson : JSON.stringify(this.eventSalesAccessories),
            isShowWarranty : this.isShowWarranty,
            isShowAccessories : this.isShowAccessories,
            type : this.type,
        })
        .then(result => {
            if(result.isSuccess){
                this.showSuccess('Save successfully!');
                this.closeModal();
                this.isShowSpinner = false;
                if(flag){
                    setTimeout(() => {
                        const closeModal = new CustomEvent('closeModal');
                        this.dispatchEvent(closeModal);
                        this.isModalOpen = true;
                    }, 500);
                }else {
                    setTimeout(() => {
                        const closeModal = new CustomEvent('closeModal');
                        this.dispatchEvent(closeModal);
                    }, 100);
                }
            }else {
                this.showError(result.errorMsg);
                this.isShowSpinner = false;
            }
        })
        .catch(error => {
            this.isShowSpinner = false;
            this.showError('Save failure!' + JSON.stringify(error));
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

    // 查询父级基本信息
    async searchEventReceipt(){
        await searchEventReceipt({ 
            recordId : this.recordId,
        })
        .then(result => {
            if(result){
                this.eventReceipt = result;
                console.log('wwww----' + JSON.stringify(this.eventReceipt));
            }
            this.showLoadingSpinner = false;
        })
        .catch(error => {
            this.showLoadingSpinner = false;
        });;
    }

    // 查询产品详情
    async searchProductInfo(productId, index){
        await searchProductInfo({ 
            productId : productId,
            currencyIsoCode : this.eventReceipt.CurrencyIsoCode,
        })
        .then(result => {
            if(result){
                if(index == 1){
                    // this.productCurrencyIsoCode = eventReceipt.CurrencyIsoCode;
                    // this.eventSales.CurrencyIsoCode = eventReceipt.CurrencyIsoCode;
                    this.productInfo = result;
                    this.isHavePorduct = true;
                }else if(index == 2){
                    // this.accessoriesCurrencyIsoCode = eventReceipt.CurrencyIsoCode;
                    // this.eventSalesAccessories.CurrencyIsoCode = eventReceipt.CurrencyIsoCode;
                    this.accessoriesInfo = result;
                    this.isHaveAccessories = true;
                }
            }else {
                if(index == 1){
                    this.isHavePorduct = false;
                }else if(index == 2){
                    this.isHaveAccessories = true;
                }
                this.showWarning('There is no Suggested Price for the product');
            }
        })
        .catch(error => {
            this.showError('Product information error');
            if(index == 1){
                this.isHavePorduct = false;
            }else if(index == 2){
                this.isHaveAccessories = true;
            }
        });
    }

}