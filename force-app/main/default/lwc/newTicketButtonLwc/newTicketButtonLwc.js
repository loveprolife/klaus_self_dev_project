import { LightningElement, track, api, wire } from 'lwc';
import CURRENTUSERID from '@salesforce/user/Id';
import { LightningNavigationElement } from 'c/lwcUtils';
import LightningModal from 'lightning/modal';

import PromoterDailyReport_ATTACHMENT from '@salesforce/label/c.PromoterDailyReport_ATTACHMENT';
import PromoterDailyReport_RequiredCheck from '@salesforce/label/c.PromoterDailyReport_RequiredCheck';
import Ticket_Fields_Check from '@salesforce/label/c.Ticket_Fields_Check';
import Ticket_Error_Assigned from '@salesforce/label/c.Ticket_Error_Assigned';
import INSPECTION_REPORT_MSG_DEPARTMENT_USER from '@salesforce/label/c.INSPECTION_REPORT_MSG_DEPARTMENT_USER';
import Product_Model_Help_Text from '@salesforce/label/c.Product_Model_Help_Text';

import newTicketGetInitData from '@salesforce/apex/NewTicketsController2.newTicketGetInitData';
import newTicketSaveData2 from '@salesforce/apex/NewTicketsController2.newTicketSaveData2';
import autoAssigned from '@salesforce/apex/NewTicketsController2.autoAssigned';

export default class NewTicketButtonLwc extends LightningNavigationElement {

    // @track ticket = {
    //     Subject__c: null,
    //     Description__c: null,
    //     DueDate__c: null,
    //     Department__c: null,
    //     AssignedTo__c: null,
    //     index: 0
    // };

    @track ticket = {
        index : 0
    };

    @track isShowDepartment = true;
    @track isShowSpinner = false;
    @track isShowProduct = false;
    @track isShowProductSearch = false;
    @track isSouthAfrica = false;
    @track isArgentina = false;
    @track isReadOnly = true;
    @track isFlag = false; // 产品变动，关联 Product_Category__c 和 Product_Line__c 变动

    @track fields = {};
    @track productInfo = [];
    @track productLineInfo = [];
    @track assignedToInfo = [];
    @track filesInfo = [];
    
    fileMap = {};
    label = { PromoterDailyReport_ATTACHMENT, INSPECTION_REPORT_MSG_DEPARTMENT_USER, Product_Model_Help_Text};

    // 初始化
    connectedCallback() {
        this.isShowSpinner = true;
        newTicketGetInitData(

        ).then(data => {
            if (data.isSuccess) {
                for (let key in data.data) {
                    this[key] = data.data[key];
                }
                // this.isShowDepartment = (data.data.userRegion == 'Hisense Chile') || (data.data.userRegion == 'Hisense South Africa');
                this.isSouthAfrica = data.data.userRegion == 'Hisense South Africa';
                this.isArgentina = data.data.userRegion == 'Hisense Argentina';
                this.ticket.SBU__c = data.data.userRegion;
                if(this.isFilledOut(data.data.userRegion)){
                    this.isReadOnly = false;
                    this.serchStore();
                    this.updateLookup('onProduct');
                }
                console.log('isShowDepartment：' + this.isShowDepartment);
            } else {
                this.showError(data.message);
            }
        }).catch(error => {
            this.catchError(error);
        })

        if (!this.isFilledOut(this.ticket.Status__c)) {
            this.ticket.Status__c = 'Open';
        }
        if (!this.isFilledOut(this.ticket.Priority__c)) {
            this.ticket.Priority__c = 'Normal';
        }
      
        this.isShowSpinner = false;
    }

    loaded = false
    renderedCallback() {
        if(!this.loaded) {
            let style = document.createElement('style');
            style.innerText = 'div[class=slds-form-element__help]{display:none;}';
            this.template.querySelector('.date-format-hide').appendChild(style);
            this.loaded = true;
        }
        this.isFlag = false;
    }

    // 门店选择
    serchStore(){
        var lookup = this.template.querySelector('c-account-look-up-lwc');
        lookup.updateOption({
            'lookup': 'CustomLookupProvider.StoreFilterTicket',
            'salesRegion': this.ticket.SBU__c
        });
    }

    // 取消按钮
    cancelHandleClick(event) {
        this.goToObject('Ticket__c');
    }

    // 保存按钮
    saveHandleClick(event) {
        this.isShowSpinner = true;
        let result = this.saveCheck();
        if (result.flag) {
            newTicketSaveData2({
                ticketJson: JSON.stringify(this.ticket),
                filesInfo: this.filesInfo,
            }).then(resp => {
                if (resp.isSuccess) {
                    this.goToRecord(resp.data.ticketId);
                } else {
                    this.showError(resp.message);
                }
                this.isShowSpinner = false;
            }).catch(error => {
                this.catchError(error);
                this.isShowSpinner = false;
            })
        } else {
            this.showError(result.message);
            this.isShowSpinner = false;
        }
    }
    
    // 字段数据填写
    handleFieldChange(event) {
        console.log('wwwww ——> target value: ' + event.target.value);
        console.log('wwwww ——> target fieldName: ' + event.target.dataset.fieldName);
        this.ticket[event.target.dataset.fieldName] = event.target.value;
        this.ticket.isUpdated = true;

        if(event.target.dataset.fieldName == 'Department__c') {
            requestAnimationFrame(() => {
                this.updateLookup('userLookup');
                this.removeLookup('userLookup');
		    });
        }
        // 国家更改
        if(event.target.dataset.fieldName == 'SBU__c') {
            if(this.isFilledOut(event.target.value)){
                this.serchStore();
                this.isReadOnly = false;
            }else {
                this.isReadOnly = true;
            }
            this.isSouthAfrica = event.target.value == 'Hisense South Africa';
            this.isArgentina = event.target.value == 'Hisense Argentina';
            
            requestAnimationFrame(() => {
                this.updateLookup('onProduct');
		    });

            // 清空产品信息
            this.productInfo = [];
            this.formatProductInfo();
            // 清空指派人
            this.ticket.Department__c = '';
            this.ticket.AssignedTo__c = '';
            this.assignedToInfo = [];

            // 查询Ticket_Auto_Assigned__c表，自动指派
            if(this.isFilledOut(event.target.value) && this.isFilledOut(this.ticket.Category__c)){
                this.autoAssigned();
            }
        }
        // 大类更改
        if(event.target.dataset.fieldName == 'Category__c') {
            // 查询Ticket_Auto_Assigned__c表，自动指派
            if(this.isFilledOut(event.target.value) && this.isFilledOut(this.ticket.SBU__c)){
                this.autoAssigned();
            }
        }
        // Product_Category__c 修改
        if(event.target.dataset.fieldName == 'Product_Category__c') {
            if(!this.isFlag){
                this.ticket.Product_Line__c = '';
                this.productInfo = [];
                this.ticket.Product__c = '';
                this.ticket.Product_Id__c = '';
                this.ticket.Product_Line__c = '';
            }
            // 产品过滤
            requestAnimationFrame(() => {
                this.updateLookup('onProduct');
		    });
        }
        // Product_Line__c 修改
        if(event.target.dataset.fieldName == 'Product_Line__c') {
            if(!this.isFlag){
                this.productInfo = [];
                this.ticket.Product__c = '';
                this.ticket.Product_Id__c = '';
            }
            // 产品过滤
            requestAnimationFrame(() => {
                this.updateLookup('onProduct');
		    });
            // 产品线更改后，自动指派
            if(this.isFilledOut(this.ticket.SBU__c) && this.isFilledOut(this.ticket.Category__c)){
               this.autoAssigned(); 
            }
        }
    }

    // 门店选择
    lookUpChangeHandler(event) {
        let targetName = event.target.dataset.fieldName;
        console.log('lookUpChangeHandler ——> targetName: ' + targetName);

        if (event.detail.selectedRecord == undefined) {
            this.ticket[targetName] = null;
        } else {
            this.ticket[targetName] = event.detail.selectedRecord.Id;
        }
        this.ticket.isUpdated = true;
    }

    // 过滤条件
    updateLookup(name) {
        var cmps = this.template.querySelectorAll('c-account-look-up-lwc');
        for (let i = 0; i < cmps.length; i++) {
            var lookup = cmps[i];
            if (lookup.name == 'userLookup') {
                lookup.updateOption({
                    'lookup': 'CustomLookupProvider.DepartmentUserFilter',
                    'department': this.ticket.Department__c,
                    'salesRegion': this.ticket.SBU__c,
                });
            }else if(lookup.name == 'onProduct'){
                lookup.updateOption({
                    'lookup': 'CustomLookupProvider.productTicketFilter',
                    'salesRegion': this.ticket.SBU__c,
                    'productCategory': this.ticket.Product_Category__c,
                    'productLine': this.ticket.Product_Line__c,
                });
            }
        }
    }

    removeLookup(name) {
        var cmps = this.template.querySelectorAll('c-account-look-up-lwc');
        for (let i = 0; i < cmps.length; i++) {
            var lookup = cmps[i];
            if (lookup.name==name) {
                lookup.handleRemove();
                return;
            }
        }
    }

    lookupUserFilter = {
        'lookup': 'CustomLookupProvider.UserFilter'
    }

    lookupStoreFilter = {
        'lookup': 'CustomLookupProvider.StoreFilterTicket'
    }

    handleKeyDown(event) {
        if (event.keyCode === 13) {
            event.preventDefault();
        }
    }

    // handleUploadFinished(event) {
    //     // Get the list of uploaded files
    //     const uploadedFiles = event.detail.files;
    //     alert('No. of files uploaded : ' + uploadedFiles.length);
    // }

    // handleSelectFiles(event) {
    //     console.log('wwwwww-----' + JSON.stringify(event.detail.records));
    //     this.fileMap[event.target.dataset.index] = event.detail.records;
    // }

    // openUpload(event) {
    //     this.template.querySelector('c-upload-files3-lwc').openUpload();
    // }

    handleSelectFiles(event){
        console.log('wwwwww-----' + JSON.stringify(event.detail.filesInfo));
        this.filesInfo = event.detail.filesInfo;
    }

    saveCheck() {
        let result = {
            flag: true,
            message: PromoterDailyReport_RequiredCheck,
        }

        // 校验必填
        this.template.querySelectorAll('lightning-input-field').forEach(element => {
            if(!element.reportValidity()) {
                result.flag = false;
                result.message += ' ' + element.fieldName + ',';
            }
        });

        // 校验其他必填，南非产品
        if(this.isSouthAfrica && !this.isFilledOut(this.ticket.Product__c)){
            result.flag = false;
            result.message += ' ' + this.fields.Product__c + ',';
        }
        if(!this.isFilledOut(this.ticket.Product__c)){
            this.template.querySelectorAll('.productLookup').forEach(element => {
                element.validateInput();
            });
        }

        // 校验部门和指派人最少一项必填
        if(!this.isFilledOut(this.ticket.Department__c) && this.assignedToInfo.length == 0){
            result.flag = false;
            result.message += ' ' + this.fields.Department__c + ' or ' + this.fields.AssignedTo__c;
        }else {
            let Aassigners = '';
            let AassignersName = '';
            this.assignedToInfo.forEach(element => {
                Aassigners += element.id + ',';
                AassignersName += element.label + ',';
            })
            this.ticket.Aassigners__c = Aassigners.substring(0, Aassigners.length - 1);
            this.ticket.Assigners_Name__c = AassignersName.substring(0, AassignersName.length - 1);
        }
        
        // 获取文件内容
        this.template.querySelector('c-upload-files-no-record-id').selectFiles();

        return result;
    }

    isFilledOut(content) {
        if (typeof content == "undefined") {
            return false;
        } else if (content == '' || content == null) {
            return false;
        } else if (typeof content == "number") {
            return !isNaN(content);
        }
        return true;
    }

    // 添加产品（自定义lookupFilter）
    lookupFilter = {
        'lookup' : 'CustomLookupProvider.productTicketFilter'
    }
    deleteProductValue(event){
        this.productInfo = this.productInfo.slice(0, -1);
        this.formatProductInfo();
    }
    // 选择产品变更
    handleChangeProductOption(resp) {
        if (!this.isFilledOut(resp.detail.selectedRecord)) {
            return;
        }
        // 产品变动
        this.isFlag = true;

        let product = {};
        product.Name = resp.detail.selectedRecord.Name;
        product.Line = resp.detail.selectedRecord.Product_Line__c;
        product.Id = resp.detail.selectedRecord.Id;
        product.ProductCategory = resp.detail.selectedRecord.Product__c;

        // 选择的产品是否已经存在
        if(this.productInfo.filter(obj => obj.Id == resp.detail.selectedRecord.Id).length == 0){
            this.productInfo.push(product);
        }
        this.formatProductInfo();
    }

    // 处理产品数据
    formatProductInfo(){
        console.log('wwwww-----' + JSON.stringify(this.productInfo));
        // 处理产品和产品线信息
        let productStr = '';
        let productLineStr = '';
        let productSet = [];
        let productLineSet = [];
        let productIdStr = '';
        let oldProductLine = this.ticket.Product_Line__c;
        let ProductCategory = '';

        this.productLineInfo = [];

        this.productInfo.forEach(product => {
            if(this.isFilledOut(product['Line']) && !productLineSet.includes(product['Line'])){
                productLineStr += product['Line'] + ',';
                productLineSet.push(product['Line']);
                this.productLineInfo.push({
                    type: 'avatar',
                    label: product['Line'],
                    value: product['Line'],
                    fallbackIconName: 'standard:products',
                });
            }
            if(this.isFilledOut(product['Name']) && !productSet.includes(product['Name'])){
                productStr += product['Name'] + ',';
                productIdStr += product['Id'] + ',';
                productSet.push(product['Name']);
            }
            ProductCategory = product.ProductCategory;
        });
        // 产品线修改则，重新查询自动指派人
        console.log('wwwww-----' + this.ticket.Product_Line__c);
        console.log('wwwww-----' + productLineStr.substring(0, productLineStr.length - 1));

        this.ticket.Product__c = productStr.substring(0, productStr.length - 1);
        this.ticket.Product_Id__c = productIdStr.substring(0, productIdStr.length - 1);
        if(this.isFilledOut(productLineStr)){
            this.ticket.Product_Line__c = productLineStr.substring(0, productLineStr.length - 1);
        }else {
            this.ticket.Product_Line__c = '';
        }

        this.ticket.Product_Category__c = ProductCategory;

        if(oldProductLine != this.ticket.Product_Line__c && this.isFilledOut(this.ticket.SBU__c) && this.isFilledOut(this.ticket.Category__c)){
            this.autoAssigned();
        }

        // 给产品子页面传参数是否必填
        if(this.isFilledOut(this.ticket.Product__c)){
            this.template.querySelectorAll('.productLookup').forEach(element => {
                element.setIsRequired(false);
            });
        }else{
            this.template.querySelectorAll('.productLookup').forEach(element => {
                element.setIsRequired(this.isSouthAfrica);
            });
        }
    }

    // pill 删除元素
    handleItemRemove(event) {
        // 产品变动
        this.isFlag = true;

        const index = event.target.dataset.index;
        this.productInfo.splice(index, 1);
        this.formatProductInfo();
    }

    // 多选 指派人
    lookUpChangeAssignedToHandler(event){
        if (!this.isFilledOut(event.detail.selectedRecord)) {
            return;
        }
        this.ticket.AssignedTo__c = event.detail.selectedRecord.Id;
        // 选择的user是否已经存在
        if(this.assignedToInfo.filter(obj => obj.id == event.detail.selectedRecord.Id).length == 0){
            let pill = {
                type: 'avatar',
                href: '',
                id: event.detail.selectedRecord.Id,
                name: event.detail.selectedRecord.Username,
                label: event.detail.selectedRecord.Name,
                src: event.detail.selectedRecord.FullPhotoUrl,
                fallbackIconName: 'standard:user',
                variant: 'circle',
                isLink: true,
            };
            this.assignedToInfo.push(pill);
        }
    }

    // 指派人删除
    handleAssignedToRemove(event) {
        const index = event.detail.index;
        this.assignedToInfo.splice(index, 1);
    }

    // 自动指派
    autoAssigned(){
        console.log('wwwww-----查询自动指派人' );
        autoAssigned({
            sbu: this.ticket.SBU__c,
            category: this.ticket.Category__c,
            productLine: this.ticket.Product_Line__c
        }).then(resp => {
            if (resp.isSuccess) {
                this.assignedToInfo = [];
                let ticketAutoAssignedList = resp.data.ticketAutoAssignedList;
                ticketAutoAssignedList.forEach(element => {
                    // 配置了人员
                    if(this.isFilledOut(element.Assigned_To__c)){
                        // let pill = {
                        //     type: 'avatar',
                        //     href: '',
                        //     id: element.Assigned_To__c,
                        //     name: element.Assigned_To__r.Username,
                        //     label: element.Assigned_To__r.Name,
                        //     src: element.Assigned_To__r.FullPhotoUrl,
                        //     fallbackIconName: 'standard:user',
                        //     variant: 'circle',
                        //     isLink: true,
                        // };
                        // this.assignedToInfo.push(pill);
                        this.ticket.AssignedTo__c = element.Assigned_To__c;
                    }
                    if(this.isFilledOut(element.Department__c)){
                        this.ticket.Department__c = element.Department__c;
                    }
                });

                this.template.querySelectorAll('.userLookup').forEach(element => {
                    element.parentSelectedRecord(this.ticket.AssignedTo__c);
                });
                    
            } else {
                // 未配置自动指派人
                console.log('wwwww-----未配置自动指派人' );
            }
             
        }).catch(error => {

        })
    }
}