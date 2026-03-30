/*
 * @Author: WFC
 * @Date: 2025-04-24 14:43:42
 * @LastEditors: WFC
 * @LastEditTime: 2025-11-19 13:39:38
 * @Description: 
 * @FilePath: \testuat\force-app\main\default\lwc\newAccountPageLwc\newAccountPageLwc.js
 */
import { LightningElement, api, track, wire } from 'lwc';
import { LightningNavigationElement } from 'c/lwcUtils'
import LightningConfirm from 'lightning/confirm';
import LightningAlert from 'lightning/alert';
import { NavigationMixin } from 'lightning/navigation';
import { getRecord, getFieldValue, updateRecord } from 'lightning/uiRecordApi';
import { getObjectInfo } from 'lightning/uiObjectInfoApi';
import { getRecordNotifyChange, notifyRecordUpdateAvailable } from 'lightning/uiRecordApi';
import getCustomerExtendForCompany from '@salesforce/apex/NewAccountPageController.getCustomerExtendForCompany';
import getCustomerExtendForSales from '@salesforce/apex/NewAccountPageController.getCustomerExtendForSales';
import getCustomerBanks from '@salesforce/apex/NewAccountPageController.getCustomerBanks';
import getCustomerProductLine from '@salesforce/apex/NewAccountPageController.getCustomerProductLine';
import saveProductLineView from '@salesforce/apex/NewAccountPageController.saveProductLineView';
import saveCompanySalesView from '@salesforce/apex/NewAccountPageController.saveCompanySalesView';
import saveBankView from '@salesforce/apex/NewAccountPageController.saveBankView';
import saveCustomerManagementNameView from '@salesforce/apex/NewAccountPageController.saveCustomerManagementNameView';
import deleteRecord from '@salesforce/apex/NewAccountPageController.deleteRecord';
import saveAccountView from '@salesforce/apex/NewAccountPageController.saveAccountView';
import getAccountData from '@salesforce/apex/NewAccountPageController.getAccountData';
import getAccountRecordType from '@salesforce/apex/NewAccountPageController.getAccountRecordType';
import getTaxInfoBySalesId from '@salesforce/apex/NewAccountPageController.getTaxInfoBySalesId';
import saveTaxCategoryView from '@salesforce/apex/NewAccountPageController.saveTaxCategoryView';
import saveScoreSheetView from '@salesforce/apex/NewAccountPageController.saveScoreSheetView';
import undoChangesView from '@salesforce/apex/NewAccountPageController.undoChangesView';
import checkCreditApplicationLimit from '@salesforce/apex/NewAccountPageController.checkCreditApplicationLimit';
import checkSubAccountCreditManagement from '@salesforce/apex/NewAccountPageController.checkSubAccountCreditManagement';
import handleSyncToSAP from '@salesforce/apex/NewAccountPageController.handleSyncToSAP';
import handleVerification from '@salesforce/apex/NewAccountPageController.handleVerification';
import syncMDGAccount from '@salesforce/apex/NewAccountPageController.syncMDGAccount';
import getUserInfo from '@salesforce/apex/NewAccountPageController.getUserInfo';
//根据销售组织获取sold-to币种
import getCurrency from '@salesforce/apex/NewAccountPageController.getCurrency';

import Customer_Basic_Information from '@salesforce/label/c.Customer_Basic_Information';
import Customer_Registration_Information from '@salesforce/label/c.Customer_Registration_Information';
import Customer_Business_Information from '@salesforce/label/c.Customer_Business_Information';
import Customer_Address_Information_ShipTo from '@salesforce/label/c.Customer_Address_Information_ShipTo';
import Customer_Address_Information from '@salesforce/label/c.Customer_Address_Information';
import Customer_Tax_Have from '@salesforce/label/c.Customer_Tax_Have';
import Customer_Tax_No_Have from '@salesforce/label/c.Customer_Tax_No_Have';
import Navigation_Confirmation from '@salesforce/label/c.Navigation_Confirmation';
import Navigation_Confirmation_Body from '@salesforce/label/c.Navigation_Confirmation_Body';

import Approval_Status from '@salesforce/schema/Account.Approval_Status__c';
import Current_Modifier from '@salesforce/schema/Account.Current_Modifier__c';
import ID_FIELD from '@salesforce/schema/Account.Id';
import MDG_Customer_Code from '@salesforce/schema/Account.MDG_Customer_Code__c';
import USER_ID from '@salesforce/user/Id';

const actions = [
    { label: 'Edit', name: 'Edit' },
    { label: 'Delete', name: 'Delete' },
];

export default class NewAccountPageLwc extends LightningNavigationElement {
    label = {
        Customer_Basic_Information,
        Customer_Registration_Information,
        Customer_Business_Information,
        Customer_Address_Information,
        Customer_Address_Information_ShipTo,
        Customer_Tax_Have,
        Customer_Tax_No_Have,
    }

    @api recordTypeId;
    @api recordId;
    @api isNew;
    @track isShowSyncToSapButton = false;//是否显示同步SAP按钮
    @track isAdmin = false;
    @track isRequired = false;
    @track isCustomerAddress = false;
    @track isShowRegistrationInformation = false; // 非注册、地址类、分户不显示注册信息
    @track isSubAccount = false;
    @track isHaveCompanyView = false;
    @track isHaveSalesView = false;
    @track currentModifier;
    @track currentModifierEmail;
    @track isCurrentModifier = true;
    @track isApproved = false;// 审批状态是 Approved
    @track isSubmitted = false;// 审批状态是 Submitted
    @track isCanUndoChanges = false;// 审批状态是 Adjustment
    @track isCanSave = false;// 加载完才可保存
    @track isUpdate = false;// 数据是否修改过
    @track isShowUndoChanges = false;
    @track isHaveRecordId = false;
    @track isCssLoaded = false;
    @track isShowHelpText = false;
    @track isShowSubmitView = false;
    @track isShowChangesInfoView = false;
    @track isHaveCreditManagement = false;
    @track isShowLegalReportView = false;
    @track isShowChannelName = false;
    @track isShowEmailEditView = false;// 点击Emai修改页面
    @track editEmail = '';// 要修改的email
    @track editEmailIndex = '';// 要修改的email Index
    @track salesOfficeIsRequired = false;// 销售办公司、销售组是否必填
    @track customerGroup2IsRequired = false;// 销售组2是否必填
    @track storLocationIsRequired = false;// 库位是否必填
    @track salesCurrencyIsRequired = false;// 币种是否必填
    @track salesInternationalTradeTerms2IsRequired = false;// International Trade Terms 2是否必填

    // account信息
    @track accountRecord = {};
    // @track provinceStateLabel;
    // @track cityCNLabel;
    // @track districtCNLabel;
    // @track townshipCNLabel;
    @track accountTitle;
    @track accountIconName;

    @track isShowSpinner = false;
    @track showChinaAddressFlag = false;
    @track showOtherAddressFlag = false; // 用两个不同的flag展示不同地址信息，为了初始化时，回显数据
    @track activeSections = ['A','B','C','D','E','F'];
    @track companyViewColumns = [];
    @track companyViewData = [];
    @track salesViewColumns =[];
    @track salesViewData = [];
    @track customerBanksColumns = [];
    @track customerBanksData = [];
    // ------ email信息 -------
    @track isErrorEmailAddress = false;
    @track errorEmailMessage;
    @track emailAddress;
    @track addressItems = [];
    @track dragstart;
    @track dragend;
    // ------------------------
    @track salesOffice;
    @track salesGroup;
    @track storLocation;
    @track MDGBANK;
    
    @track isShowSpinnerDialog = false;
    @track isShowCompanyView = false;
    @track companyViewRecord = {};
    @track storLocationId;

    @track isShowSalesView = false;
    @track salesViewRecord = {};
    @track salesGroupId;
    @track salesOfficeValue = '';// sales group 与 sales office关联

    @track isShowBankView = false;
    @track bankViewRecord = {};
    @track MDGBANKId;

    @track isShowTaxView = false;
    @track taxViewRecordList = [];

    @track isShowCustomerManagementView = false;
    @track customerManagementName = {};

    @track isNotEdit = false;// 公司视图和销售视图entity 可修改标记

    // 客户产品线
    @track customerProductLineData=[];
    @track customerProductLineColumns=[];
    @track isShowProductLineList = true;
    @track isShowProductLineView = false;
    @track productLineViewRecord = {};
    @track isShowScoreSheetView = false; // score sheet页面显示标记
    @track scoreSheetViewRecord = {}; // score sheet数据
    @track scoreSheetPageAgency = false;
    @track scoreSheetPageOEM = false;
    @track scoreSheetPageOversea = false;

    @track viewType = 'New';// 弹出框是新建还是编辑
    @track verificationIconName = '';// Verification 按钮icon
    @track isVerification = false;// 已经验证
    @track accountFromMdgJson = '';// MDG存在的客户json

    @track isThailand = false;// 简档是否泰国用户
    @track isAustralia = false;// 简档是否澳洲用户
    @track isFinance = false;// 角色判断是否日本用户

    @track isJapanSalesField = false;// 销售视图日本字段
    @track isShowPOD = true;//是否显示POD
    
    
    lookupFilter = {
        'lookup': 'CustomLookupProvider.CountryStateFilter',
    }

    lookupTaxCategoryFilter = {
        'lookup': 'CustomLookupProvider.TaxCategoryFilter',
    }

    @wire(getRecord, { recordId: '$recordId', fields: [Approval_Status, Current_Modifier, MDG_Customer_Code] })
    wiredRecord({ data, error }) {
        if (data) {
            if(getFieldValue(data, Approval_Status) === 'Adjustment'){
                this.isCanUndoChanges = true;
            }else {
                this.isCanUndoChanges = false;
            }
            if(getFieldValue(data, Approval_Status) === 'Approved'){
                this.isApproved = true;
            }else {
                this.isApproved = false;
            }
            if(getFieldValue(data, Approval_Status) === 'Submitted'){
                this.isSubmitted = true;
            }else {
                this.isSubmitted = false;
            }
            if(getFieldValue(data, Current_Modifier) == USER_ID){
                this.isCurrentModifier = true;
            }else {
                this.isCurrentModifier = false;
            }
            if(this.judgeNotEmpty(getFieldValue(data, MDG_Customer_Code))){
                this.isVerification = true;
            }else {
                this.isVerification = false;
            }
            this.accountRecord.Approval_Status__c = getFieldValue(data, Approval_Status);
        } else if (error) {
            console.error('Error:', error);
        }
    }

    @track accountLabelInfo = {
        Guarantor_Country_Code__c: '',
        Company_Registration_Number__c: '',
        provinceStateLabel: '',
        cityCNLabel: '',
        districtCNLabel: '',
        townshipCNLabel: '',
        Unified_Customer_Group__c: '',
    };
    @wire(getObjectInfo, { objectApiName: 'Account' })
    wiredAccountInfo({ error, data }) {
        if (data) {
            // this.provinceStateLabel = data.fields.Province_State__c.label;
            // this.cityCNLabel = data.fields.City_CN__c.label;
            // this.districtCNLabel = data.fields.District_CN__c.label;
            // this.townshipCNLabel = data.fields.Township_CN__c.label;

            this.accountLabelInfo = {
                Guarantor_Country_Code__c: data.fields.Guarantor_Country_Code__c.label,
                Company_Registration_Number__c: data.fields.Company_Registration_Number__c.label,
                provinceStateLabel: data.fields.Province_State__c.label,
                cityCNLabel: data.fields.City_CN__c.label,
                districtCNLabel: data.fields.District_CN__c.label,    
                townshipCNLabel: data.fields.Township_CN__c.label,
                Unified_Customer_Group__c: data.fields.Unified_Customer_Group__c.label
            }
        } else if (error) {
            console.log(error);
            this.showError('Account getInformation error');
        }
    }

    @wire(getObjectInfo, { objectApiName: 'Customer_Extend__c' })
    wiredCustomerExtendInfo({ error, data }) {
        if (data) {
            this.companyViewColumns = [
                // { label: data.fields.Name.label, fieldName: 'Name'},
                { label: data.fields.Hisense_Entity__c.label, fieldName: 'Hisense_Entity'},
                { label: data.fields.Extend_or_Not__c.label, fieldName: 'Extend_or_Not'},
                { label: data.fields.Reconciliation_Customer__c.label, fieldName: 'Reconciliation_Customer',
                    // type: 'picklistColumn',
                    // editable: true,
                    // typeAttributes: {
                    //     placeholder: 'Choose One',
                    //     options:  [
                    //         { label: 'Hot', value: 'Hot' },
                    //         { label: 'Warm', value: 'Warm' },
                    //         { label: 'Cold', value: 'Cold' },
                    //     ] ,
                    // }
                },
                { label: data.fields.EDI_ID__c.label, fieldName: 'EDI_ID'},
                { label: data.fields.Payment_Method_MDG__c.label, fieldName: 'Payment_Method_MDG'},
                { label: data.fields.Payment_Term__c.label, fieldName: 'Payment_Term_Url', type: 'url',
                    typeAttributes:{
                        label: { fieldName: 'Payment_Term'},
                        target: '_blank',
                        tooltip: {fieldName: 'Payment_Term'}   
                    },
                },
                { type: 'action',fixedWidth	 : 60, typeAttributes: { rowActions: this.getRowActions, menuAlignment: 'auto' } }
            ];
            this.salesViewColumns = [
                { label: data.fields.Hisense_Entity_Sales__c.label, fieldName: 'Hisense_Entity_Sales',
                    // cellAttributes: {
                    //     iconName: { fieldName: 'iconName' },
                    // },
                },
                { label: data.fields.Extend_or_Not__c.label, fieldName: 'Extend_or_Not'},
                { label: data.fields.Distribution_Channel__c.label, fieldName: 'Distribution_Channel'},
                { label: data.fields.Sales_Office__c.label, fieldName: 'Sales_Office_Url', type: 'url',
                    typeAttributes:{
                        label: { fieldName: 'Sales_Office'},
                        target: '_blank',
                        tooltip: {fieldName: 'Sales_Office'}   
                    },
                },
                { label: data.fields.Sales_Group__c.label, fieldName: 'Sales_Group_Url', type: 'url',
                    typeAttributes:{
                        label: { fieldName: 'Sales_Group'},
                        target: '_blank',
                        tooltip: {fieldName: 'Sales_Group'}   
                    },
                },
                { type: "button", label: "Tax Information", 
                    typeAttributes: {  
                        label: 'Tax Info',  
                        name: 'Tax Information',  
                        variant: { fieldName: 'buttonVariante' },
                    } 
                },
                { type: 'action',fixedWidth	 : 60, typeAttributes: { rowActions: this.getRowActions, menuAlignment: 'auto' } }
            ];
            this.salesOffice = data.fields.Sales_Office__c.label;
            this.salesGroup = data.fields.Sales_Group__c.label;
            this.storLocation = data.fields.Stor_Location__c.label;
        } else if (error) {
            console.log(error);
            this.showError('Customer_Extend__c getInformation error');
        }
    }

    @wire(getObjectInfo, { objectApiName: 'Customer_Banks__c' })
    wiredCustomerBanksInfo({ error, data }) {
        if (data) {
            this.customerBanksColumns = [
                { label: data.fields.Name.label, fieldName: 'Name'},
                { label: data.fields.Bank_Code__c.label, fieldName: 'Bank_Code'},
                { label: data.fields.Extend_or_Not__c.label, fieldName: 'Extend_or_Not'},
                { label: data.fields.Bank_Account__c.label, fieldName: 'Bank_Account'},
                { label: data.fields.Bank_name_local_language__c.label, fieldName: 'Bank_name_local_language'},
                { label: data.fields.Bank_Country__c.label, fieldName: 'Bank_Country'},
                // { label: data.fields.Bank_Control_Code__c.label, fieldName: 'Bank_Control_Code'},
                // { label: data.fields.Reference_Detail__c.label, fieldName: 'Reference_Detail'},
                // { label: data.fields.Swift_Code__c.label, fieldName: 'Swift_Code'},
                { type: 'action',fixedWidth	 : 60, typeAttributes: { rowActions: this.getRowActions, menuAlignment: 'auto' } }
            ];
            this.MDGBANK = data.fields.MDG_BANK__c.label;
        } else if (error) {
            console.log(error);
            this.showError('Customer_Banks__c getInformation error');
        }
    }

    @wire(getObjectInfo, { objectApiName: 'Customer_Product_Line__c' })
    wiredCustomerProductLineInfo({ error, data }) {
        if (data) {
            this.customerProductLineColumns= [
                { label: data.fields.Name.label, fieldName: 'Name'},
                { label: data.fields.Product_Line_Name__c.label, fieldName: 'Product_Line_Name'},
                { label: data.fields.Classification__c.label, fieldName: 'Classification'},
                { label: data.fields.Development_Stage__c.label, fieldName: 'Development_Stage'},
                { label: data.fields.Evaluated_Score__c.label, fieldName: 'evaluatedScore',
                    cellAttributes: {
                        class: { 
                            fieldName: 'valueColor' // 动态绑定 CSS 类
                        }
                    }
                },
                { type: "button", label: "Score Sheet", 
                    typeAttributes: {  
                        label: 'Score Sheet',  
                        name: 'Score Sheet',
                        variant: { fieldName: 'buttonVariante' },
                    } 
                },
                { type: 'action',fixedWidth	 : 60, typeAttributes: { rowActions: actions, menuAlignment: 'auto' } }
            ];
        } else if (error) {
            console.log(error);
            this.showError('Customer_Product_Line__c getInformation error');
        }
    }
    // 产品线数据处理
    formattedData() {
        return this.customerProductLineData.map(item => ({
            ...item,
            valueColor: item.evaluatedScore >= 60 ? 'slds-text-color_success' : 'slds-text-color_error'
        }));
    }

    getRowActions(row, doneCallback) {
        const actions = [];
        if(row.Extend_or_Not){
            actions.push(
                { label: 'Edit', name: 'Edit' },
            );
        }else {
            actions.push(
                { label: 'Edit', name: 'Edit' },
                { label: 'Delete', name: 'Delete' },
            );
        }
        // simulate a trip to the server
        doneCallback(actions);
    }

    //是否显示统一客户组
    get isShowUnifiedCustomerGroup() {
        if (!this.accountRecord || !this.accountRecord.Guarantor_Country_Code__c) {
            return false;
        }
        return this.accountRecord.Guarantor_Country_Code__c === 'AU'; // || this.accountRecord.Guarantor_Country_Code__c === 'NZ'
    }

    /**
     * 初始化 Customer_Extend_Tax_category__c 标签
     */
    @track taxInfo = {
        Name: '',
        CountryCodeAndCustomerIdF__c: '',
        Tax_category_code__c: '',
        Tax_category__c: '',
        National_tax_category__c: '',
    };
    @wire(getObjectInfo, { objectApiName: 'Customer_Extend_Tax_category__c' })
    wiredTaxInfo({ error, data }) {
        if (data) {
            this.taxInfo = {
                Name: data.fields.Name.label,
                CountryCodeAndCustomerIdF__c: data.fields.CountryCodeAndCustomerIdF__c.label,
                Tax_category_code__c: data.fields.Tax_category_code__c.label,
                Tax_category__c: data.fields.Tax_category__c.label,
                National_tax_category__c: data.fields.National_tax_category__c.label,
            }
        } else if (error) {
            console.log(error);
            this.showError('Customer_Extend_Tax_category__c getInformation error');
        }
    }

    // 初始化数据
    connectedCallback(){
        console.log('wwwwww---recordTypeId--' + this.recordTypeId);
        console.log('wwwwww---recordId--' + this.recordId);

        // this.recordId = '001A200000JmhqwIAB';

        if(this.judgeNotEmpty(this.recordId)){  
            this.getAccountData();
            this.getCustomerExtendForCompany();
            this.getCustomerExtendForSales();
            this.getCustomerBanks();
            this.getCustomerProductLine();
            this.isHaveRecordId = true;
        }else {
            this.isCanSave = true;
            this.accountTitle = 'New Customer';
            this.accountIconName = 'standard:account';
            this.updateLookup('.AccountProvince');
            // 获取Account数据类型
            this.getAccountRecordType();
        }
        
        if(this.isNew){
            console.log('wwwwww---标题冻结--');
            window.addEventListener('scroll', this.handleScroll);
        }

        if(this.judgeNotEmpty(this.recordTypeId)){
            this.accountRecord.RecordTypeId = this.recordTypeId;
        }

        this.getUserInfo();
    }

    disconnectedCallback() {
        window.removeEventListener('scroll', this.handleScroll); // 避免内存泄漏:ml-citation{ref="4" data="citationList"}
    }

    // 获取用户数据
    async getUserInfo(){
        await getUserInfo({})
        .then(result => {

            // 判断国家
            if(result.Profile.Name.indexOf('Thailand') > -1){
                this.isThailand = true;
            }else if(result.Profile.Name.indexOf('Australia') > -1){
                this.isAustralia = true;
            }

            // 是否财务
            if(result.Profile.Name.indexOf('Finance') > -1){
                this.isFinance = true;
            }

            // 判断是否是管理员
            if(result.Profile.Name == 'System Administrator' || result.Profile.Name == 'HQ Finance Team'){
                this.isAdmin = true;
                this.isShowSyncToSapButton = true;
            }else if(this.isAustralia && this.isSubAccount){
                if(this.isSubAccount){
                    this.isApproved = true;
                }
                this.isShowSyncToSapButton = true;
            }else if(this.isVerification && this.isFinance){
                this.isShowSyncToSapButton = true;
            }else {
                this.isAdmin = false;
                this.isShowSyncToSapButton = false;
            }
        })
        .catch(error => {});
    }

    async getAccountRecordType(){
        await getAccountRecordType({
            recordTypeId : this.recordTypeId,
        })
            .then(result => {
                // 判断是否是地址类客户
                if(result.DeveloperName == 'Customer_Address'){
                    this.isCustomerAddress = true;
                    this.isSubAccount = false;
                    this.isRequired = false;
                }else if(result.DeveloperName == 'Sub_Account'){
                    this.isCustomerAddress = false;
                    this.isSubAccount = true;
                    this.isRequired = true;
                }else {
                    this.isCustomerAddress = false;
                    this.isSubAccount = false;
                    this.isRequired = true;
                }
                // 是否显示客户信息中的注册信息
                if(result.DeveloperName == 'Customer_Address' || result.DeveloperName == 'Sub_Account' || 
                    result.DeveloperName == 'Hisense_International_Custoemr_Unconventional'){//25-11-12 员工类展示注册信息
                    this.isShowRegistrationInformation = false;
                }else {
                    this.isShowRegistrationInformation = true;
                }
                // 是否显示产品线列表
                if(result.DeveloperName == 'Customer_Address' || result.DeveloperName == 'Sub_Account' || result.DeveloperName == 'Staff'){
                    this.isShowProductLineList = false;
                }else {
                    this.isShowProductLineList = true;
                }
                // 给 ID_Type__c 赋值
                if(!this.judgeNotEmpty(this.accountRecord.ID_Type__c)){
                    if(result.DeveloperName == 'customer'){
                        this.accountRecord.ID_Type__c = 'Z25';
                    }else if(result.DeveloperName == 'Staff'){
                        this.accountRecord.ID_Type__c = 'Z35';
                    }
                }
            })
            .catch(error => {
                console.log('error:', error);
                this.showError(error);
            })
    }

    // 鼠标滚轮
    handleScroll = () => {
        clearTimeout(this.scrollTimer);
        this.scrollTimer = setTimeout(() => {
            const scrollTop = document.documentElement.scrollTop;
            
            if (scrollTop === 0) {
                const element = this.template.querySelector(".divView");
                const accordion = this.template.querySelector(".accordion");
                // 强制触发浏览器重绘（关键步骤）
                void element.offsetWidth; 
                element.classList.remove("sticky-header-card");
                accordion.style.paddingTop = '0rem'; // 支持 px/rem/% 等单位
            }else {
                const element = this.template.querySelector(".divView");
                const accordion = this.template.querySelector(".accordion");
                // 强制触发浏览器重绘（关键步骤）
                void element.offsetWidth; 
                element.classList.add("sticky-header-card");
                accordion.style.paddingTop = '9rem'; // 支持 px/rem/% 等单位
            }
        }, 100); // 设置 100ms 延迟
      };

    // 客户主信息
    async getAccountData() {
        await getAccountData({
            recordId : this.recordId,
        })
            .then(result => {
                this.accountRecord = result;
                this.recordTypeId = result.RecordTypeId;

                requestAnimationFrame(() => {
                    this.updateLookup('.AccountUnifiedCustomerGroup');
                });
                this.accountRecord.Unified_Customer_Group__c = result.Unified_Customer_Group__c;

                // 中国地址
                if(result && result.Guarantor_Country_Code__c === 'CN'){
                    this.showChinaAddressFlag = true;
                    this.showOtherAddressFlag = false;
                    this.accountRecord.Id = result.Id;
                    this.accountRecord.Guarantor_Country_Code__c = result.Guarantor_Country_Code__c;
                    this.accountRecord.Province_State__c = result.Province_State__c;
                    this.accountRecord.City_CN__c = result.City_CN__c;
                    this.accountRecord.District_CN__c = result.District_CN__c;
                    this.accountRecord.Township_CN__c = result.Township_CN__c;

                    requestAnimationFrame(() => {
                        this.updateLookup('.AccountProvince');
                        this.updateLookup('.AccountCity');
                        this.updateLookup('.AccountDistrict');
                        this.updateLookup('.AccountTownship');
                    });
                }else {
                    this.showOtherAddressFlag = false;
                    this.showOtherAddressFlag = true;
                    this.accountRecord.Id = result.Id;
                    this.accountRecord.Guarantor_Country_Code__c = result.Guarantor_Country_Code__c;
                    this.accountRecord.Province_State__c = result.Province_State__c;

                    requestAnimationFrame(() => {
                        this.updateLookup('.AccountProvince');
                    });
                }
                // Email Address
                if(this.judgeNotEmpty(result.Email_Multiple__c)){
                    // ; 拆分数据
                    result.Email_Multiple__c.split(";").forEach(item => {
                        let pill = {
                            type: 'avatar',
                            label: item,
                            name: item,
                            fallbackIconName: 'standard:email',
                            variant: 'circle',
                        };
                        this.addressItems.push(pill);
                    });
                }
                this.isCanSave = true;
                if(this.judgeNotEmpty(result.Current_Modifier__c)){
                    this.currentModifier = 'Current Modifier：' + result.Current_Modifier__r.Name;
                    this.currentModifierEmail = result.Current_Modifier__r.Email;
                }
                // 判断是否是地址类客户
                if(result.RecordType.DeveloperName == 'Customer_Address'){
                    this.isCustomerAddress = true;
                    this.isSubAccount = false;
                    this.isRequired = false;
                }else if(result.RecordType.DeveloperName == 'Sub_Account'){
                    this.isCustomerAddress = false;
                    this.isSubAccount = true;
                    this.isRequired = true;
                    this.checkSubAccountCreditManagement(result.ParentCustomerOfSubAcc__c);
                }else {
                    this.isCustomerAddress = false;
                    this.isSubAccount = false;
                    this.isRequired = true;
                }
                // 是否显示客户信息中的注册信息
                if(result.RecordType.DeveloperName == 'Customer_Address' || result.RecordType.DeveloperName == 'Sub_Account' || 
                    result.RecordType.DeveloperName == 'Hisense_International_Custoemr_Unconventional'){//25-11-12 员工类展示注册信息
                    this.isShowRegistrationInformation = false;
                }else {
                    this.isShowRegistrationInformation = true;
                }
                // 是否显示产品线列表
                if(result.RecordType.DeveloperName == 'Customer_Address' || result.RecordType.DeveloperName == 'Sub_Account' 
                    || result.RecordType.DeveloperName == 'Staff'){
                    this.isShowProductLineList = false;
                }else {
                    this.isShowProductLineList = true;
                }
                // 判断是否同步过SAP,显示 Undo Changes 按钮
                if(this.judgeNotEmpty(result.Latest_Version__c)){
                    this.isShowUndoChanges = true;
                }else {
                    this.isShowUndoChanges = false;
                }
                // 是否显示Channel Name
                if(result.Marketing_Model__c == '1' || result.Marketing_Model__c == '2'){
                    this.isShowChannelName = true;
                }else {
                    this.isShowChannelName = false;
                }
            })
            .catch(error => {
                console.log('error:', error);
                this.showError(error);
            })
    }

    // 公司视图
    async getCustomerExtendForCompany() {
        await getCustomerExtendForCompany({
            recordId : this.recordId,
        })
            .then(result => {
                if(this.judgeNotEmpty(result.companyViewData)){
                    this.companyViewData = JSON.parse(result.companyViewData);
                }
                this.isHaveCompanyView = result.isHaveCompanyView;
            })
            .catch(error => {
                console.log('error:', error);
                this.showError(error);
            })
    }

    // 销售视图
    async getCustomerExtendForSales() {
        await getCustomerExtendForSales({
            recordId : this.recordId, 
        })
            .then(result => {
                if(this.judgeNotEmpty(result.salesViewData)){
                    this.salesViewData = JSON.parse(result.salesViewData);
                }
                this.isHaveSalesView = result.isHaveSalesView;
            })
            .catch(error => {
                console.log('error:', error);
                this.showError(error);
            })
    }

    // 银行
    async getCustomerBanks() {
        await getCustomerBanks({
            recordId : this.recordId, 
        })
            .then(result => {
                if(this.judgeNotEmpty(result.customerBanksData)){
                    this.customerBanksData = JSON.parse(result.customerBanksData);
                }
            })
            .catch(error => {
                console.log('error:', error);
                this.showError(error);
            })
    }

    // 客户产品线
    async getCustomerProductLine() {
        await getCustomerProductLine({
            recordId : this.recordId, 
        })
            .then(result => {
                if(this.judgeNotEmpty(result.customerProductLineData)){
                    this.customerProductLineData = JSON.parse(result.customerProductLineData);
                    this.customerProductLineData = this.formattedData();
                }
            })
            .catch(error => {
                console.log('error:', error);
                this.showError(error);
            })
    }

    // 点击展开
    handleSectionToggle(event) {
        const openSections = event.detail.openSections;
    }

    // Address Information 中的 Country/Region 选择 china 时与其他国家不同
    handleAccountFieldChange(event){
        this.isUpdate = true;
        const targetName = event.currentTarget.fieldName;
        const targetValue = event.target.value;
        this.accountRecord[targetName] = targetValue;
        
        if(targetName === 'Guarantor_Country_Code__c'){
            if(targetValue === 'CN'){
                this.showChinaAddressFlag = true;
                this.showOtherAddressFlag = false;
                this.accountRecord.Province_State__c = '';
                this.accountRecord.City__c = '';
                this.accountRecord.District__c = '';
                this.accountRecord.Street_2__c = '';
            }else if(targetValue !== 'CN' && this.judgeNotEmpty(targetValue)){
                this.showOtherAddressFlag = true;
                this.showChinaAddressFlag = false;
                this.accountRecord.Province_State__c = '';
                this.accountRecord.District_CN__c = '';
                this.accountRecord.City_CN__c = '';
                this.accountRecord.Township_CN__c = '';
                this.accountRecord.Street_2__c = '';
            }else {
                this.showChinaAddressFlag = false;
                this.showOtherAddressFlag = false;
            }
            this.template.querySelectorAll('.AccountCountry c-account-look-up-lwc').forEach(element => {
                element.handleRemove();
            });
            requestAnimationFrame(() => {
                this.updateLookup('.AccountProvince');
                this.updateLookup('.AccountUnifiedCustomerGroup');
            });
        }
         
        // 分户选择 ParentCustomerOfSubAcc__c 时，验证 Credit_Management__c 的数据
        if(targetName === 'ParentCustomerOfSubAcc__c'){
            this.checkSubAccountCreditManagement(targetValue);
        }
        // 是否显示 Channel Name
        if(targetName === 'Marketing_Model__c'){
            if(targetValue == '1' || targetValue == '2'){
                this.isShowChannelName = true;
            }else {
                this.isShowChannelName = false;
                this.accountRecord.Channel_Name__c = '';
            }
        }
        // Verification 按钮icon更改
        if(targetName === 'Guarantor_Country_Code__c' || targetName === 'Company_Registration_Number__c'){
            this.verificationIconName = '';
        }
    }

    async checkSubAccountCreditManagement(parentCustomerId){
        await checkSubAccountCreditManagement({
            parentCustomerId : parentCustomerId,
            recordId: this.recordId
        })
        .then(result => {
            if(result.isSuccess){
                this.isHaveCreditManagement = result.data.isHaveCreditManagement;
                this.accountRecord.Credit_Management__c = result.data.creditManagement;
            }
        })
        .catch(error => {
        });
    }

    // 客户地址信息保存
    lookUpChangeProvinceStateHandler(event){
        this.isUpdate = true;
        let targetName = event.target.dataset.fieldName;
        console.log('wwwww-----' + targetName);
        if (event.detail.selectedRecord.Id === undefined) {
            this.accountRecord[targetName] = null;
        } else {
            this.accountRecord[targetName] = event.detail.selectedRecord.Id;
            if(targetName === 'Province_State__c'){
                requestAnimationFrame(() => {
                    this.updateLookup('.AccountCity');
                });
            }else if(targetName === 'City_CN__c'){
                requestAnimationFrame(() => {
                    this.updateLookup('.AccountDistrict');
                });
            }else if(targetName === 'District_CN__c'){
                requestAnimationFrame(() => {
                    this.updateLookup('.AccountTownship');
                });
            }

        }
        console.log('wwwwww---accountRecord--' + JSON.stringify(this.accountRecord));
    }

    // 点击save保存客户信息
    handleSaveAccountView(viewType){
        if(this.VerifyCurrentModifier()) return;
        if(!this.isCanSave) return;
        this.isShowSpinner = true;
        // 验证必填项
        if (this.verifyField('.account_view_from lightning-input-field', '.AccountLookUp')) {
            // 验证地址信息
            if( this.verifyAddressField() && this.verifyEmailAddress() && this.verifyUnifiedCustomerGroup()){
                // 先校验注册码，非注册、地址类、分户和员工类客户不需要验证
                if(this.isShowRegistrationInformation && this.verificationIconName == '' && !this.isVerification){
                    handleVerification({ 
                        countryCode : this.accountRecord.Guarantor_Country_Code__c,
                        registrationNumber : this.accountRecord.Company_Registration_Number__c,
                        recordTypeId : this.recordTypeId,
                        recordId : this.recordId,
                    })
                    .then(result => {
                        if(result.isSuccess){
                            if(result.data.isHaveLocalAccount){
                                // 弹出框是否跳转已存在客户
                                this.gotoExistsAccount(result.data.account);
                                return;
                            }else if(result.data.isHaveMDGAccount){
                                let mergedObj = Object.assign({}, result.data.account, this.accountRecord);
                                // 弹出框是否同步数据
                                this.syncMDGAccount(mergedObj);
                                return;
                            }else {
                                this.verificationIconName = 'utility:success';
                                this.saveAccountView(viewType);
                            }
                        }else {
                            this.showError('Verification failure!' + JSON.stringify(result));
                            return;
                        }
                    })
                    .catch(error => {
                        this.isShowSpinner = false;
                        this.showError('Verification failure!' + JSON.stringify(error));
                        return;
                    });
                }else {
                    // 不满足注册码校验条件，直接保存
                    this.saveAccountView(viewType);
                }
            }else {
                this.isShowSpinner = false;
                this.showError('Required fields are not filled in');
                return;
            }
        }else {
            this.isShowSpinner = false;
            return;
        }
    }

    verifyUnifiedCustomerGroup(){
        if(this.isShowUnifiedCustomerGroup){
            if(this.judgeNotEmpty(this.accountRecord.Unified_Customer_Group__c)){
                return true;
            }else {
                this.template.querySelectorAll('.AccountUnifiedCustomerGroup c-account-look-up-lwc').forEach(element => {
                    element.setFocusToInput();
                });
                return false;
            }
        }else{
            return true;
        }
    }

    // 验证客户主数据地址信息
    verifyAddressField(){
        if(this.accountRecord.Guarantor_Country_Code__c === 'CN'){
            if(this.judgeNotEmpty(this.accountRecord.Province_State__c) && this.judgeNotEmpty(this.accountRecord.City_CN__c) 
                && this.judgeNotEmpty(this.accountRecord.District_CN__c) && this.judgeNotEmpty(this.accountRecord.Township_CN__c)){
                return true;
            }else {
                if(!this.judgeNotEmpty(this.accountRecord.Province_State__c)){ 
                    this.template.querySelectorAll('.AccountProvince c-account-look-up-lwc').forEach(element => {
                        element.setFocusToInput();
                    });
                }else if(!this.judgeNotEmpty(this.accountRecord.City_CN__c)){
                    this.template.querySelectorAll('.AccountCity c-account-look-up-lwc').forEach(element => {
                        element.setFocusToInput();
                    });
                }else if(!this.judgeNotEmpty(this.accountRecord.District_CN__c)){
                    this.template.querySelectorAll('.AccountDistrict c-account-look-up-lwc').forEach(element => {
                        element.setFocusToInput();
                    });
                }else if(!this.judgeNotEmpty(this.accountRecord.Township_CN__c)){
                    this.template.querySelectorAll('.AccountTownship c-account-look-up-lwc').forEach(element => {
                        element.setFocusToInput();
                    });
                }
                return false;
            }
        }else {
            if(this.judgeNotEmpty(this.accountRecord.Province_State__c)){
                return true;
            }else {
                // 其他国家校验Province必填
                this.template.querySelectorAll('.AccountProvince c-account-look-up-lwc').forEach(element => {
                    element.setFocusToInput();
                });
                return false;
            }
        }
    }

    // 验证客户主数据邮箱
    verifyEmailAddress(){
        if(this.addressItems.length != 0 || !this.isThailand){
            return true;
        }else{
            this.template.querySelectorAll('.emailAddress lightning-input').forEach(element => {
                    //element.setFocusToInput();
                    element.reportValidity(); // 显示验证错误
                    element.focus(); // 设置焦点到输入字段
            });
            return false;
        }
    }

    
    // 保存客户主信息
    saveAccountView(viewType){
        if(!this.isUpdate && viewType != '5' && viewType != '6'){
            this.showWarning('There is no data to update!');
            this.isShowSpinnerDialog = false;
            this.isShowSpinner = false;
            return;
        }
        // Email Address 处理 ";" 隔开
        if(this.addressItems.length > 0){
            let emailMultiple = [];
            this.addressItems.filter(obj => this.judgeNotEmpty(obj.name)).forEach(item => {
                emailMultiple.push(item.name);
            });
            if(emailMultiple.length > 0){
                this.accountRecord.Email_Multiple__c = emailMultiple.join(';');
            }
        }else {
            this.accountRecord.Email_Multiple__c = '';
        }
        console.log('wwwwww--save-' +  JSON.stringify(this.accountRecord));
        saveAccountView({ 
            viewRecord : JSON.stringify(this.accountRecord)
        })
        .then(result => {
            this.isShowSpinner = false;
            if(result.isSuccess){
                this.isHaveRecordId = true;
                this.recordId = result.data.account.Id;
                this.accountRecord.Id = result.data.account.Id;
                this.accountTitle = result.data.account.Customer_Name_Local_Language__c;
                // getRecordNotifyChange([{ recordId: result.data.account.Id }]); // 刷新 LDS 缓存
                notifyRecordUpdateAvailable([{ recordId: result.data.account.Id }]); // 刷新 LDS 缓存
                
                if(this.judgeNotEmpty(viewType)){
                    if(viewType === '1'){
                        this.addCompanyView();
                    }else if(viewType === '2'){
                        this.addSalesView();
                    }else if(viewType === '3'){
                        this.addBankView();
                    }else if(viewType === '4'){
                        this.addProductLineView();
                    }else if(viewType === '5'){
                        this.isShowSubmitView = true;
                    }else if(viewType === '6'){
                        this.syncToSAP();
                    }else {
                        this.showSuccess('Save successfully!');
                    }
                }else {
                    this.showSuccess('Save successfully!');
                }
            }else {
                this.showError(result.message);
            }
        })
        .catch(error => {
            this.isShowSpinner = false;
            this.showError('Save failure!' + JSON.stringify(error));
        });
    }

    // 列表action
    handleSalesViewRowAction(event) {
        const action = event.detail.action;  // 获取按钮动作类型
        const dataname = event.target.dataset.name;
        const row = event.detail.row;        // 获取当前行数据
        console.log('wwwww----' + JSON.stringify(dataname) );
        console.log('wwwww----' + JSON.stringify(row) );
        switch (action.name) {
            case 'Edit':
                console.log('wwwww----Edit');
                this.viewType = 'Edit';
                this.isUpdate = false;
                // 弹出编辑
                this.editRow(row, dataname);
                break;
            case 'Delete':
                console.log('wwwww----Delete');
                // 弹出删除信息框
                this.handleDeleteConfirmClick(row, dataname);
                break;
            case 'Tax Information':
                console.log('wwwww----Tax Information');
                this.isUpdate = false;
                this.showTaxView(row);
                break;
            case 'Score Sheet':
                console.log('wwwww----Score Sheet');
                this.showScoreSheetView(row);
                break;
        }
    }

    // 删除弹出框
    async handleDeleteConfirmClick(row, dataname) {
        // 已同步MDG的公司视图和销售视图，不可以删除
        if((dataname == 'Company View' || dataname == 'Sales View' || dataname == 'Customer Banks') && row.Extend_or_Not){
            this.showError('The synchronized data cannot be deleted!');
            return;
        }
        const result = await LightningConfirm.open({
            message: 'Are you sure you want to delete this ' + dataname + '?',
            theme: "warning",
            label: 'Delete ' + dataname,
            // setting theme would have no effect
        });
        if (result) {
            this.isShowSpinner = true;
            deleteRecord({
                recordId : row.Id, 
            })
            .then(result => {
                if(result){
                    this.deleteRow(row, dataname);
                    this.isShowSpinner = false;
                    this.showSuccess('Delete successfully!');
                }
            }).catch(error => {
                console.log('error:', error);
                this.isShowSpinner = false;
                this.showError('Delete failure!' + JSON.stringify(error));
            })
        }
    }

    editRow(row, dataname) {
        if(dataname == 'Company View'){
            this.companyViewRecord = {};
            this.isShowCompanyView = true;
            this.companyViewRecord.Id = row.Id;
            this.companyViewRecord.Hisense_Entity__c = row.Hisense_Entity_Api;
            this.storLocationId = row.Stor_Location;
            this.isNotEdit = (row.Extend_or_Not ? row.Extend_or_Not : false) && !this.isAdmin;// 同步过MDG的数据不能修改特殊字段
            console.log('wwwww---isNotEdit--' + this.isNotEdit);
            requestAnimationFrame(() => {
                this.updateLookup('.CompanyView');
            });
        }else if(dataname == 'Sales View'){
            this.salesViewRecord = {};
            this.isShowSalesView = true;
            this.salesViewRecord.Id = row.Id;
            this.salesViewRecord.Hisense_Entity_Sales__c = row.Hisense_Entity_Sales_Api;
            this.salesViewRecord.Sales_Office__c = row.Sales_Office_Id;
            this.salesViewRecord.Sales_Group__c = row.Sales_Group_Id;
            this.salesOfficeId = row.Sales_Office_Id;
            this.salesGroupId = row.Sales_Group_Id;
            this.salesOfficeValue = row.Sales_Office_Value;
            this.isNotEdit = (row.Extend_or_Not ? row.Extend_or_Not : false) && !this.isAdmin;// 同步过MDG的数据不能修改特殊字段
            requestAnimationFrame(() => {
                this.updateLookup('.SalesView');
                this.updateLookup('.SalesGroupView');
            });
        }else if(dataname == 'Customer Banks'){
            this.bankViewRecord = {};
            this.isShowBankView = true;
            this.bankViewRecord.Id = row.Id;
            this.bankViewRecord.Bank_Country__c = row.Bank_Country_Api;
            this.bankViewRecord.MDG_BANK__c = row.MDG_BANK;
            this.MDGBANKId = row.MDG_BANK;
            requestAnimationFrame(() => {
                this.updateLookup('.CustomerBanks');
            });
        }else if(dataname == 'Customer Product Line'){
            this.isShowProductLineView = true;
            this.productLineViewRecord.Id = row.Id;
        }
        
    }

    deleteRow(rowRecord, dataname) {
        const id = rowRecord.Id;
        if(dataname == 'Company View'){
            this.companyViewData = this.companyViewData.filter(obj => obj.Id !== id);
        }else if(dataname == 'Sales View'){
            this.salesViewData = this.salesViewData.filter(obj => obj.Id !== id);
        }else if(dataname == 'Customer Banks'){
            this.customerBanksData = this.customerBanksData.filter(obj => obj.Id !== id);
        }else if(dataname == 'Customer Product Line'){
            this.customerProductLineData = this.customerProductLineData.filter(obj => obj.Id !== id);
        }
    }

    handleCompanyLineSave(event) {
        let saveDraftValues = event.detail.draftValues;
        console.log('wwww----' + saveDraftValues);
    }

    // -------------------------------------- email 信息处理 ---------------------------------------
    handleEmailAddressChange(event){
        this.emailAddress = event.target.value;
        this.isErrorEmailAddress = false;
    }

    handleAddAddressClick(){
        this.isUpdate = true;
        this.errorEmailMessage = '';
        if(this.judgeNotEmpty(this.emailAddress)){
             // 输入框 ";" 分隔
            const arr = this.emailAddress.split(/[;；]/).filter(item => item !== '');
            let errorEmail = '';
            arr.forEach(item => {
                // 检验输入框是否为Email格式
                if (!/^\w+([-+.]\w+)*@\w+([-.]\w+)*\.\w+([-.]\w+)*$/.test(item)) {
                    errorEmail += item + ";";
                }else {
                    let sameItem = this.addressItems.filter(obj => obj.name == item);
                    //if(sameItem == null || sameItem == '' || sameItem == undefined){
                        let pill = {
                            type: 'avatar',
                            label: item,
                            name: item,
                            fallbackIconName: 'standard:email',
                            variant: 'circle',
                        };
                        this.addressItems.push(pill);                      
                    //}
                }
            });
            if(errorEmail !== ''){
                this.isErrorEmailAddress = true;
                errorEmail = errorEmail.substring(0, errorEmail.length - 1);
                this.errorEmailMessage = 'It\'s not a correct email address! (' + errorEmail + ')';
            }else{
                this.emailAddress = '';
            }
        }else {
            this.isErrorEmailAddress = true;
            this.errorEmailMessage = 'Please enter your email address!';
            return; 
        }
    }
    // pill Email 删除元素
    handleItemRemove(event) {
        this.isUpdate = true;
        const index = event.target.dataset.index;
        this.addressItems.splice(index, 1);
    }
    // pill Email 点击弹出修改页面
    handleItemClick(event){
        const index = event.target.dataset.index;
        this.editEmailIndex = event.target.dataset.index;
        this.editEmail = this.addressItems[index].name;
        this.isShowEmailEditView = true;
    }
    // 关闭修改email页面
    handleCloseEmailEditView(){
        this.isShowEmailEditView = false;
        this.editEmail = '';
        this.editEmailIndex = '';
    }
    // 保存修改email页面
    handleSaveEmailEditView(){
        let input = this.template.querySelector(".editEmail");
        // email未修改，不需要处理
        if(input.value == this.editEmail){
            this.isShowEmailEditView = false;
            return;
        }
        // 校验数据
        if(!this.judgeNotEmpty(input.value)){
            this.showError('Please enter your email address!');
            return;
        }else {
            // 校验要保存的email是否跟之前的重复
            let sameItem = this.addressItems.filter(obj => obj.name == input.value);
            if(this.judgeNotEmpty(sameItem)){
                this.showError('Email already exists!');       
                return;    
            }
        }
        if(input.validity.valid){
            let pill = {
                type: 'avatar',
                label: input.value,
                name: input.value,
                fallbackIconName: 'standard:email',
                variant: 'circle',
            };
            const newItems = [...this.addressItems];
            newItems[this.editEmailIndex] = pill; 
            this.addressItems = newItems;

            this.isShowEmailEditView = false;
        }else {
            return;
        }
    }

    handleDragStart(event) {
        // 设置被拖动的元素的 ID
        this.dragstart = event.target.dataset.name;
    }

    handleDragOver(event) {
        this.dragend = event.target.dataset.name;

        // 防止默认事件，以便触发 drop 事件
        event.preventDefault();
    }

    handleDrop(event) {
        // 获取拖动的元素 name
        if(this.dragstart !== this.dragend){
            this.isUpdate = true;
            // 获取移动的元素
            let tempItemStart = this.addressItems.filter(obj => obj.name == this.dragstart)[0];

            const startIndex = this.addressItems.findIndex(item => item.name === this.dragstart);
            const endindex = this.addressItems.findIndex(item => item.name === this.dragend);

            this.addressItems.splice(startIndex, 1);
            this.addressItems.splice(endindex, 0, tempItemStart);
        }

        // 结束拖放事件
        event.preventDefault();
        
    }
    // ------------------------------------------end------------------------------------------

    // ----------------- 点击添加 Company View，Sales View和Customer Banks -----------------
    // ------客户管理名称新增逻辑------
    addCustomerManagementName(){
        this.closeCustomerManagementNameView();
        this.isShowCustomerManagementView = true;
        this.viewType = 'New';
    }
    handleCustomerManagementNameFieldChange(event){
        const targetName = event.target.dataset.fieldName;
        this.customerManagementName[targetName] = event.target.value;
    }
    closeCustomerManagementNameView(){
        this.customerManagementName = {};
        this.isShowCustomerManagementView = false;
    }
    handleSaveCustomerManagementNameView(){
        this.isShowSpinnerDialog = true;

        saveCustomerManagementNameView({ 
            viewRecord : JSON.stringify(this.customerManagementName)
        })
        .then(result => {
            this.isShowSpinnerDialog = false;
            if(result.isSuccess){

                this.closeCustomerManagementNameView();
                if(this.judgeNotEmpty(result.data.CustomerManagementNameId)){
                    this.accountRecord.Customer_Management_Name__c = result.data.CustomerManagementNameId;
                    this.template.querySelectorAll('.Customer_Management_Name lightning-input-field').forEach(element => {

                        if(!element.reportValidity()) {
                            // 延迟确保 DOM 更新
                            setTimeout(() => {
                                element.focus();
                            }, 0);
                        }

                    });
                }
                
                this.showSuccess('Save successfully!');
            }else {
                this.showError(result.message);
            }
        })
        .catch(error => {
            this.isShowSpinnerDialog = false;
            this.showError('Save failure!' + JSON.stringify(error));
        });

    }
    // ------公司视图新增逻辑------
    addCompanyView(){
        if(this.VerifyCurrentModifier()) return;
        // 判断客户信息是否已经保存，没有保存则先保存客户信息
        if(this.isHaveRecordId){
            this.closeCompanyView();
            this.isShowCompanyView = true;
            this.viewType = 'New';
            this.companyViewRecord.Customer__c = this.recordId;
            this.companyViewRecord.Create_View__c = '1';
            this.lookupFilter = {
                'lookup': 'CustomLookupProvider.PickListFilter',
            }
        }else {
            this.handleSaveAccountView('1');
        }
    }
    handleCompanyViewFieldChange(event){
        this.isUpdate = true;
        const targetName = event.target.dataset.fieldName;
        this.companyViewRecord[targetName] = event.target.value;
        console.log('wwww---targetName---' + JSON.stringify(targetName) );
        if(targetName === 'Hisense_Entity__c'){
            console.log('wwww---1111---');
            this.updateLookup('.CompanyView');
            this.removeLookup('.CompanyView');
            this.storLocationId = '';
            this.companyViewRecord.Stor_Location__c = null;

            if('8200,8210'.indexOf(event.target.value) > -1){
                this.storLocationIsRequired = true;
            }else{
                this.storLocationIsRequired = false;
            }
        }
        console.log('wwww---companyViewRecord---' + JSON.stringify(this.companyViewRecord) );
    }
    closeCompanyView(){
        this.isShowCompanyView = false;
        this.companyViewRecord = {};
        this.storLocationId = '';
        this.isNotEdit = false;
        this.isUpdate = false;
    }
    handleSaveAndNewCompanyView(){
        if(this.VerifyCurrentModifier()) return;
        this.isShowSpinnerDialog = true;
        // 验证必填项
        if (this.verifyField('.company_view_from lightning-input-field', '.CompanyViewLookUp')) {
            if(this.verifyCompanyView()){
                this.saveCompanySalesView(this.companyViewRecord ,true, 'Company');
            }else {
                this.isShowSpinnerDialog = false;
                this.showError('Required fields are not filled in');
                return;
            }
        }else {
            this.isShowSpinnerDialog = false;
            return;
        }
    }
    handleSaveCompanyView(){
        if(this.VerifyCurrentModifier()) return;
        this.isShowSpinnerDialog = true;
        // 验证必填项
        if (this.verifyField('.company_view_from lightning-input-field', '.CompanyViewLookUp')) {
            if(this.verifyCompanyView()){
                this.saveCompanySalesView(this.companyViewRecord ,false, 'Company');
            }else {
                this.isShowSpinnerDialog = false;
                this.showError('Required fields are not filled in');
                return;
            }
        }else {
            this.isShowSpinnerDialog = false;
            return;
        }
    }
    lookUpChangeStorLocationHandler(event){
        this.isUpdate = true;
        let targetName = event.target.dataset.fieldName;
        if (event.detail.selectedRecord.Id === undefined) {
            this.companyViewRecord[targetName] = null;
        } else {
            this.companyViewRecord[targetName] = event.detail.selectedRecord.Id;
        }
        console.log('wwwwww---companyViewRecord--' + JSON.stringify(this.companyViewRecord));
    }
    // -------------end---------------

    // ------销售视图新增逻辑------
    addSalesView(){
        if(this.VerifyCurrentModifier()) return;
        if(this.isHaveRecordId){
            this.closeSalesView();
            this.isShowSalesView = true;
            this.viewType = 'New';
            this.salesViewRecord.Customer__c = this.recordId;
            this.salesViewRecord.Create_View__c = '2';
            if(this.isSubAccount){
                this.salesViewRecord['Payer__c'] = this.accountRecord['ParentCustomerOfSubAcc__c'];
            }
            this.lookupFilter = {
                'lookup': 'CustomLookupProvider.PickListFilter',
            }
        }else {
            this.handleSaveAccountView('2');
        }
    }
    handleSalesViewFieldChange(event){
        this.isUpdate = true;
        const targetName = event.target.dataset.fieldName;
        this.salesViewRecord[targetName] = event.target.value;

        //International_Trade_Terms__c不为空时International_Trade_Terms_2__c必填
        if(targetName === 'International_Trade_Terms__c'){
            if(this.judgeNotEmpty(event.target.value)){
                this.salesInternationalTradeTerms2IsRequired = true;
            }else{
                this.salesInternationalTradeTerms2IsRequired = false;
            }
            
        }

        if(targetName === 'Hisense_Entity_Sales__c' && event.target.value != null && event.target.value != '' && event.target.value != undefined){
            this.updateLookup('.SalesView');
            this.removeLookup('.SalesView');

            this.salesOfficeIsRequired = false;
            this.customerGroup2IsRequired = false;
            this.salesCurrencyIsRequired = false;

            //巴拿马、澳洲、新西兰和加拿大(非Ship to)销售办公室销售组必填 
            if('8430' == event.target.value){
                this.salesOfficeIsRequired = true;
                this.customerGroup2IsRequired = true;
            }else if('8640' == event.target.value){
                this.salesCurrencyIsRequired = true;
                this.salesViewRecord.CurrencyIsoCode = 'COP';
            }else if('8200'.indexOf(event.target.value) > -1){
                this.salesOfficeIsRequired = true;
                this.salesViewRecord.Deliverying_Plant__c = '8200';
                this.salesViewRecord.CurrencyIsoCode = 'AUD';
                this.salesViewRecord.Sales_Region__c = 'Hisense Australia';
            }else if('8210'.indexOf(event.target.value) > -1){
                this.salesOfficeIsRequired = true;
                this.salesViewRecord.Deliverying_Plant__c = '8210';
                this.salesViewRecord.CurrencyIsoCode = 'NZD';
                 this.salesViewRecord.Sales_Region__c = 'Hisense New Zealand';
            }else if('8650'.indexOf(event.target.value) > -1){
                this.salesOfficeIsRequired = true;
            }else if('8120' == event.target.value && !this.isCustomerAddress){
                this.salesOfficeIsRequired = true;
            }

            if(event.target.value.indexOf('80') === 0){
                this.isShowPOD = false;
                this.salesViewRecord['Related_to_POD__c'] = false;
            }else{
                this.isShowPOD = true;
                this.salesViewRecord['Related_to_POD__c'] = true;
            }

            if('8410' == event.target.value){
                this.isJapanSalesField = true;
            }else{
                this.isJapanSalesField = false;
            }

            

            if(this.isCustomerAddress && this.judgeNotEmpty(this.accountRecord.Sold_to__c)){
                 getCurrency({
                    customerId: this.accountRecord.Sold_to__c,
                    hisenseEntitySales: event.target.value
                }).then(result => {
                    if(this.judgeNotEmpty(result.CurrencyIsoCode)){
                        this.salesViewRecord.CurrencyIsoCode = result.CurrencyIsoCode;
                    }
                }).catch(error => {});
            }
        }
    }
    closeSalesView(){
        this.isShowSalesView = false;
        this.salesViewRecord = {};
        this.salesOfficeId = '';
        this.salesGroupId = '';
        this.isNotEdit = false;
        this.isUpdate = false;
    }
    handleSaveAndNewSalesView(){
        if(this.VerifyCurrentModifier()) return;
        this.isShowSpinnerDialog = true;
        // 验证必填项
        if (this.verifyField('.sales_view_from lightning-input-field', '.SalesViewLookUp')) {
            if(this.verifySalesView()){
                this.saveCompanySalesView(this.salesViewRecord, true, 'Sales');
            }else {
                this.isShowSpinnerDialog = false;
                this.showError('Required fields are not filled in');
                return;
            }
        }else {
            this.isShowSpinnerDialog = false;
            return;
        }
    }
    handleSaveSalesView(){
        if(this.VerifyCurrentModifier()) return;
        this.isShowSpinnerDialog = true;
        // 验证必填项
        if (this.verifyField('.sales_view_from lightning-input-field', '.SalesViewLookUp')) {
            if(this.verifySalesView()){
                this.saveCompanySalesView(this.salesViewRecord, false, 'Sales');
            }else {
                this.isShowSpinnerDialog = false;
                this.showError('Required fields are not filled in');
                return;
            }
        }else {
            this.isShowSpinnerDialog = false;
            return;
        }
    }
    // -------------end---------------

    // ------银行新增逻辑------
    addBankView(){
        if(this.VerifyCurrentModifier()) return;
        if(this.isHaveRecordId){
            this.closeBankView();
            this.isShowBankView = true;
            this.viewType = 'New';
            this.bankViewRecord.Customer__c = this.recordId;
            this.lookupFilter = {
                'lookup': 'CustomLookupProvider.BankFilter',
            }
        }else {
            this.handleSaveAccountView('3');
        }
    }
    handleBankViewFieldChange(event){
        this.isUpdate = true;
        const targetName = event.target.dataset.fieldName;
        this.bankViewRecord[targetName] = event.target.value;
        if(targetName === 'Bank_Country__c'){
            this.updateLookup('.CustomerBanks');
            this.removeLookup('.CustomerBanks');
            this.MDGBANKId = '';
            this.bankViewRecord.MDG_BANK__c = null;
        }
    }
    closeBankView(){
        this.isShowBankView = false;
        this.bankViewRecord = {};
        this.MDGBANKId = '';
        this.isNotEdit = false;
        this.isUpdate = false;
    }
    handleSaveAndNewBankView(){
        if(this.VerifyCurrentModifier()) return;
        this.isShowSpinnerDialog = true;
        // 验证必填项
        if (this.verifyField('.bank_view_from lightning-input-field', '.CustomerBanksLookUp')) {
            // 验证MDG_BANK__c
            if( this.judgeNotEmpty(this.bankViewRecord.MDG_BANK__c)){
                this.saveBankView(this.bankViewRecord, true);
            }else {
                this.isShowSpinnerDialog = false;
                this.showError('Required fields are not filled in');
                return;
            }
        }else {
            this.isShowSpinnerDialog = false;
            return;
        }
    }
    handleSaveBankView(){
        if(this.VerifyCurrentModifier()) return;
        this.isShowSpinnerDialog = true;
        // 验证必填项
        if (this.verifyField('.bank_view_from lightning-input-field', '.CustomerBanksLookUp')) {
            // 验证MDG_BANK__c
            if( this.judgeNotEmpty(this.bankViewRecord.MDG_BANK__c)){
                this.saveBankView(this.bankViewRecord, false);
            }else {
                this.isShowSpinnerDialog = false;
                this.showError('Required fields are not filled in');
                return;
            }
        }else {
            this.isShowSpinnerDialog = false;
            return;
        }
    }

    lookUpChangeSalesOfficeHandler(event) {
        this.isUpdate = true;
        let targetName = event.target.dataset.fieldName;
        // office更改，group设为空
        this.salesViewRecord.Sales_Group__c = null;
        this.removeLookup('.SalesGroupView')

        if (event.detail.selectedRecord.Id === undefined) {
            this.salesViewRecord[targetName] = null;
        } else {
            this.salesViewRecord[targetName] = event.detail.selectedRecord.Id;
            this.salesOfficeValue = event.detail.selectedRecord.Value__c;
            this.updateLookup('.SalesGroupView');
        }
        console.log('wwwwww---salesViewRecord--' + JSON.stringify(this.salesViewRecord));
    }

    lookUpChangeSalesGroupHandler(event){
        this.isUpdate = true;
        let targetName = event.target.dataset.fieldName;
        if (event.detail.selectedRecord.Id === undefined) {
            this.salesViewRecord[targetName] = null;
        } else {
            this.salesViewRecord[targetName] = event.detail.selectedRecord.Id;
        }
        console.log('wwwwww---salesViewRecord--' + JSON.stringify(this.salesViewRecord));
    }

    lookUpChangeUnifiedCustomerGroupHandler(event){
        this.isUpdate = true;
        let targetName = event.target.dataset.fieldName;
        if (event.detail.selectedRecord.Id === undefined) {
            this.accountRecord[targetName] = null;
        } else {
            this.accountRecord[targetName] = event.detail.selectedRecord.Id;
        }
    }

    lookUpChangeHandler(event) {
        this.isUpdate = true;
        let targetName = event.target.dataset.fieldName;
        if (event.detail.selectedRecord.Id === undefined) {
            this.bankViewRecord[targetName] = null;
        } else {
            this.bankViewRecord[targetName] = event.detail.selectedRecord.Id;
        }
        console.log('wwwwww--bankViewRecord---' + JSON.stringify(this.bankViewRecord));
    }

    updateLookup(name) {
        var cmps = this.template.querySelectorAll(name + ' c-account-look-up-lwc');
        for (let i = 0; i < cmps.length; i++) {
            var lookup = cmps[i];
            if(name === '.CustomerBanks'){
                lookup.updateOption({
                    'lookup': 'CustomLookupProvider.BankFilter',
                    'country': this.bankViewRecord.Bank_Country__c
                });
            }else if(name === '.SalesView'){
                lookup.updateOption({
                    'lookup': 'CustomLookupProvider.PickListFilter',
                    'entity': this.salesViewRecord.Hisense_Entity_Sales__c
                });
            }else if(name === '.AccountProvince'){
                lookup.updateOption({
                    'lookup': 'CustomLookupProvider.CountryStateFilter',
                    'belongTo': this.accountRecord.Guarantor_Country_Code__c,
                });
            }else if(name === '.AccountCity'){
                lookup.updateOption({
                    'lookup': 'CustomLookupProvider.CountryStateFilter',
                    'belongToProvince': this.accountRecord.Province_State__c,
                });
            }else if(name === '.AccountDistrict'){
                lookup.updateOption({
                    'lookup': 'CustomLookupProvider.CountryStateFilter',
                    'belongToCity': this.accountRecord.City_CN__c,
                });
            }else if(name === '.AccountTownship'){
                lookup.updateOption({
                    'lookup': 'CustomLookupProvider.CountryStateFilter',
                    'belongToDistrict': this.accountRecord.District_CN__c,
                });
            }else if(name === '.CompanyView'){
                lookup.updateOption({
                    'lookup': 'CustomLookupProvider.PickListFilter',
                    'belongToLocation': this.companyViewRecord.Hisense_Entity__c,
                });
            }else if(name === '.SalesGroupView'){
                lookup.updateOption({
                    'lookup': 'CustomLookupProvider.PickListFilter',
                    'belongToOffice': this.salesOfficeValue,
                });
            }else if(name === '.AccountUnifiedCustomerGroup'){
                lookup.updateOption({
                    'lookup': 'CustomLookupProvider.PickListFilter',
                    'belongToCountry': this.accountRecord.Guarantor_Country_Code__c,
                });
            }
            return;
        }
    }
    removeLookup(name) {
        var cmps = this.template.querySelectorAll(name + ' c-account-look-up-lwc');
        for (let i = 0; i < cmps.length; i++) {
            var lookup = cmps[i];
            lookup.handleRemove();
        }
    }
    // -------------end---------------

    //校验销售办公室和销售组
    verifyCompanyView(){
        if(this.storLocationIsRequired){
            if(this.judgeNotEmpty(this.companyViewRecord.Stor_Location__c)){
                return true;
            }else {
                if(!this.judgeNotEmpty(this.companyViewRecord.Stor_Location__c)){ 
                    this.template.querySelectorAll('.CompanyView c-account-look-up-lwc').forEach(element => {
                        element.setFocusToInput();
                    });
                }
                return false;
            }
        }else{
            return true;
        }
    }

    //校验销售办公室和销售组
    verifySalesView(){
        if(this.salesOfficeIsRequired){
            if(this.judgeNotEmpty(this.salesViewRecord.Sales_Office__c) && this.judgeNotEmpty(this.salesViewRecord.Sales_Group__c)){
                return true;
            }else {
                if(!this.judgeNotEmpty(this.salesViewRecord.Sales_Office__c)){ 
                    this.template.querySelectorAll('.SalesView c-account-look-up-lwc').forEach(element => {
                        element.setFocusToInput();
                    });
                }else if(!this.judgeNotEmpty(this.salesViewRecord.Sales_Group__c)){
                    this.template.querySelectorAll('.SalesGroupView c-account-look-up-lwc').forEach(element => {
                        element.setFocusToInput();
                    });
                }
                return false;
            }
        }else{
            return true;
        }
    }

    // 保存Customer Extend数据
    saveCompanySalesView(viewRecord, flag, view){
        if(!this.isUpdate){
            this.showWarning('There is no data to update!');
            this.isShowSpinnerDialog = false;
            this.isShowSpinner = false;
            return;
        }
        
        saveCompanySalesView({ 
            viewRecord : JSON.stringify(viewRecord)
        })
        .then(result => {
            this.isShowSpinnerDialog = false;
            if(result.isSuccess){
                if(view === 'Company'){
                    // 刷新公司视图数据
                    this.getCustomerExtendForCompany();
                    // 公司视图record为空
                    this.companyViewRecord = {};
                    if(!flag){
                        this.isShowCompanyView = false;
                    }
                }else if(view === 'Sales'){
                    // 刷新销售视图数据
                    this.getCustomerExtendForSales();
                    // 销售视图record为空
                    this.salesViewRecord = {};
                    if(!flag){
                        this.isShowSalesView = false;
                    }
                }
                // 更改客户状态和当前修改人
                if(this.isApproved){
                    this.updateAccount();
                }
                // getRecordNotifyChange([{ recordId: viewRecord.Id }]); // 刷新 LDS 缓存
                notifyRecordUpdateAvailable([{ recordId: viewRecord.Id }]); // 刷新 LDS 缓存
                this.showSuccess('Save successfully!');
            }else {
                this.showError(result.message);
            }
        })
        .catch(error => {
            this.isShowSpinnerDialog = false;
            this.showError('Save failure!' + JSON.stringify(error));
        });
    }

    // 保存Customer Banks数据
    saveBankView(viewRecord, flag){
        if(!this.isUpdate){
            this.showWarning('There is no data to update!');
            this.isShowSpinnerDialog = false;
            this.isShowSpinner = false;
            return;
        }
        saveBankView({ 
            viewRecord : JSON.stringify(viewRecord)
        })
        .then(result => {
            this.isShowSpinnerDialog = false;
            if(result.isSuccess){
                // 刷新Customer Banks数据
                this.getCustomerBanks();
                // Customer Banks record为空
                this.bankViewRecord = {};
                if(!flag){
                    this.isShowBankView = false;
                }
                // 更改客户状态和当前修改人
                if(this.isApproved){
                    this.updateAccount();
                }
                // getRecordNotifyChange([{ recordId: viewRecord.Id }]); // 刷新 LDS 缓存
                notifyRecordUpdateAvailable([{ recordId: viewRecord.Id }]); // 刷新 LDS 缓存
                this.showSuccess('Save successfully!');
            }else {
                this.showError(result.message);
            }
        })
        .catch(error => {
            this.isShowSpinnerDialog = false;
            this.showError('Save failure!' + JSON.stringify(error));
        });
    }

    // 验证必填字段
    verifyField(className, name){
        let canSaveRecord = true;
        let firstField = '';

        if(this.judgeNotEmpty(name)){
            this.template.querySelectorAll(name).forEach(element => {
                element.validateInput();
            });
            
        }

        this.template.querySelectorAll(className).forEach(element => {
            if(!element.reportValidity()) {
                if(!this.judgeNotEmpty(firstField)){
                    firstField = element.fieldName;
                    const rect = element.getBoundingClientRect();
                    const absoluteTop = Math.round(rect.top + window.scrollY);
                    const absoluteBottom = Math.round(rect.bottom + window.scrollY);
                    window.scrollTo({ top: absoluteTop - 500, behavior: 'auto' });
                    // 延迟确保 DOM 更新
                    setTimeout(() => {
                        element.blur();
                        element.focus();
                    }, 0);
                }
                canSaveRecord = false;
            }
        });

        if(!canSaveRecord) {
            this.showError('Required fields are not filled in');
        }
        return canSaveRecord;
    }

    // 更新客户 Approval_Status__c 和 Current_Modifier__c
    async updateAccount(){
        if(!this.isAdmin && !this.isFinance && this.isApproved && !this.isCustomerAddress && !(this.isAustralia && this.isSubAccount)){
            const fields = {};
            fields[ID_FIELD.fieldApiName] = this.recordId;
        
            fields[Approval_Status.fieldApiName] = 'Adjustment';
        
            fields[Current_Modifier.fieldApiName] = USER_ID;
            const recordInput = { fields };
            await updateRecord(recordInput);
            notifyRecordUpdateAvailable([{ recordId: this.recordId }]); // 刷新 LDS 缓存
        }
    }
    // --------------------------------------end----------------------------------------------

    // 销售视图税信息提示Tooltip
    hideTimeout;
    showHelpText(event){
        clearTimeout(this.hideTimeout);
        this.isShowHelpText = true;
    }
    hideHelpText(event){
        this.hideTimeout = setTimeout(() => {
            this.isShowHelpText = false;
        }, 200); // 延迟隐藏防止抖动
    }

    // --------------------------------------税信息----------------------------------------------
    showTaxView(row){
        this.isShowSpinner = true;
        this.taxViewRecordList = [];
        // 根据销售视图id查询税信息
        getTaxInfoBySalesId({ 
            customerExtendId : row.Id
        })
        .then(result => {
            if(result != null && result.length > 0){
                result.forEach(element => {
                    element.taxUrl = '/lightning/r/' + element.Id + '/view'
                });
                this.taxViewRecordList = result;
                this.isShowTaxView = true;
            }else {
                this.showWarning('There is no relevant tariff information. Please contact the administrator');
            }
            this.isShowSpinner = false;
        })
        .catch(error => {
            this.isShowSpinner = false;
            this.showError('Query failure!' + JSON.stringify(error));
        });
    }
    // 关闭按钮
    closeTaxView(event){
        this.isShowTaxView = false;
    }
    // lookup选择后赋值
    lookUpChangeTaxCategoryHandler(event){
        this.isUpdate = true;
        let parentId = event.target.dataset.parentId;
        let index = event.target.dataset.index;
        if(event.detail.selectedRecord.Id != undefined){
            let selectRecord = event.detail.selectedRecord;
            // 修改的数据
            this.taxViewRecordList.filter(obj => obj.Id == parentId).forEach(item => {
                if(selectRecord != null && selectRecord != ''){
                    item.Tax_category__c = selectRecord.Id;
                }else {
                    item.Tax_category__c = null;

                }
            });
        }else {
            // 修改的数据
            this.taxViewRecordList.filter(obj => obj.Id == parentId).forEach(item => {
                item.Tax_category__c = null;
            });
        }
    }
    // 保存税信息
    handleSaveTaxView(){
        if(this.VerifyCurrentModifier()) return;
        if(!this.isUpdate){
            this.showWarning('There is no data to update!');
            this.isShowSpinnerDialog = false;
            this.isShowSpinner = false;
            return;
        }
        this.isShowSpinnerDialog = true;
        console.log('wwwww----' + JSON.stringify(this.taxViewRecordList));
        // 根据销售视图id查询税信息
        saveTaxCategoryView({ 
            taxCategoryList : JSON.stringify(this.taxViewRecordList)
        })
        .then(result => {
            this.isShowSpinnerDialog = false;
            if(result.isSuccess){
                this.showSuccess('Save successfully!');
                this.isShowTaxView = false;
                // 刷新销售视图列表
                this.getCustomerExtendForSales();
                // 更改客户状态和当前修改人
                if(this.isApproved){
                    this.updateAccount();
                }
            }else {
                this.showError(result.message);
            }
        })
        .catch(error => {
            this.isShowSpinnerDialog = false;
            this.showError('Save Tax Category failure!' + JSON.stringify(error));
        });
    }
    // --------------------------------------end----------------------------------------------

    // cancel按钮
    handleCancelAccount(event){
        // 返回客户列表页
        this.goToObject('Account');
    }
    // submit按钮
    async handleSubmitAccountView(event){
        
        if(!this.isCanUndoChanges && this.recordTypeId == '0120o0000017UVuAAM' && (this.accountRecord.Guarantor_Country_Code__c == 'AU' || this.accountRecord.Guarantor_Country_Code__c == 'NZ')){
            let isCreditCheck = false;
            await checkCreditApplicationLimit({ 
                    recordId : this.recordId,
            }).then(result => {
                this.isShowSpinner = false;
                if(result.isSuccess){
                    
                }else {
                    isCreditCheck = true;
                }
            }).catch(error => {
                this.isShowSpinner = false;
                this.showError('failure!' + JSON.stringify(error));
            });

            if(isCreditCheck){
                const result = await LightningConfirm.open({
                    message: Navigation_Confirmation_Body,
                    theme: "info",
                    label: Navigation_Confirmation,
                });
                if (result) {
                    this[NavigationMixin.Navigate]({
                        type: 'standard__objectPage',
                        attributes: {
                            objectApiName: 'Credit_Limit_Application__c',
                            actionName: 'new'
                        },
                        state: {
                            useRecordTypeCheck: 'true',
                            defaultFieldValues: 'Customer__c=' + this.recordId
                        }
                    });
                    return;
                }
            }
        }

        // 校验公司视图和销售视图必填
        // 地址类客户和其他客户
        if(this.isCustomerAddress){
            if(!this.isHaveSalesView){
                this.showError('Please maintain the sales view!');
                return;
            }
        }else {
            if(!this.isHaveCompanyView && !this.isHaveSalesView){
                this.showError('Please maintain the company view and sales view!');
                return;
            }else if(!this.isHaveSalesView){
                this.showError('Please maintain the sales view!');
                return;
            }else if(!this.isHaveCompanyView){
                this.showError('Please maintain the company view!');
                return;
            }  
        }
        // 先保存数据再提交
        this.handleSaveAccountView('5');
    }
    // 关闭submit弹出框
    closeSubmitView(){
        this.isShowSubmitView = false;
    }
    // 提交审批成功
    submitSuccess(){
        this.isShowSubmitView = false;
        if(this.isNew){
            // 跳转到客户详情
            this.goToRecord(this.recordId);
        }else {
            notifyRecordUpdateAvailable([{ recordId: this.recordId}]); // 刷新 LDS 缓存
            this.dispatchEvent(new CustomEvent('closeModal')); 
        }
    }
    // -----------------------------------------Customer Product Line---------------------------------------------
    // 点击新建客户产品线
    addProductLineView(){
        // 判断客户信息是否已经保存，没有保存则先保存客户信息
        if(this.isHaveRecordId){
            this.viewType = 'New';
            this.isShowProductLineView = true;
            this.productLineViewRecord = {};
            this.productLineViewRecord.Customer__c = this.recordId;
        }else {
            this.handleSaveAccountView('4');
        }
    }
    // 关闭新建产品线
    closeProductLineView(){
        this.isShowProductLineView = false;
        this.productLineViewRecord = {};
    }
    // 产品线字段赋值
    handleProductLineViewFieldChange(event){
        const targetName = event.target.dataset.fieldName;
        this.productLineViewRecord[targetName] = event.target.value;
    }
    // 保存并新建
    handleSaveAndNewProductLineView(){
        this.saveProductLineView(true);
    }
    // 保存
    handleSaveProductLineView(){
        this.saveProductLineView(false);
    }
    saveProductLineView(flag){
        this.isShowSpinnerDialog = true;
        // 验证必填项
        if (this.verifyField('.product_line_view_from lightning-input-field', '')) {
            saveProductLineView({ 
                viewRecord : JSON.stringify(this.productLineViewRecord)
            })
            .then(result => {
                this.isShowSpinnerDialog = false;
                if(result.isSuccess){
                    // 刷新Customer Product Line数据
                    this.getCustomerProductLine();
                    this.productLineViewRecord = {};
                    if(!flag){
                        this.isShowProductLineView = false;
                    }
                    // getRecordNotifyChange([{ recordId: this.productLineViewRecord.Id }]); // 刷新 LDS 缓存
                    notifyRecordUpdateAvailable([{ recordId: this.productLineViewRecord.Id }]); // 刷新 LDS 缓存
                    this.showSuccess('Save successfully!');
                }else {
                    this.showError(result.message);
                }
            })
            .catch(error => {
                this.isShowSpinnerDialog = false;
                this.showError('Save failure!' + JSON.stringify(error));
            });
        }else {
            this.isShowSpinnerDialog = false;
            return;
        }
    }
    // 打开打分表信息
    showScoreSheetView(row){
        this.isShowScoreSheetView = true;
        this.scoreSheetViewRecord = {};
        if(row.buttonVariante === 'success'){
            console.log('wwwww---scoreSheet-' + row.scoreSheet.Id);
            this.scoreSheetViewRecord.Id = row.scoreSheet.Id;
            this.scoreSheetViewRecord.Product_Line__c = row.Product_Line_Name;
            this.scoreSheetViewRecord.recordTypeId = row.recordTypeId;
        }else if(row.buttonVariante === 'destructive'){
            this.scoreSheetViewRecord.Product_Line__c = row.Product_Line_Name;
            this.scoreSheetViewRecord.recordTypeId = row.recordTypeId;
            this.scoreSheetViewRecord.Customer__c = this.recordId; 
        }
        // 根据Classification__c 展示不同的字段
        this.scoreSheetPageAgency = true;
        this.scoreSheetPageOEM = false;
        this.scoreSheetPageOversea = false;
        if ('Agency Customer' === row.Classification){
            this.scoreSheetPageAgency = true;
            this.scoreSheetPageOEM = false;
            this.scoreSheetPageOversea = false;
        } else if ('OEM Customer' == row.Classification){   
            this.scoreSheetPageAgency = false;
            this.scoreSheetPageOEM = true;
            this.scoreSheetPageOversea = false;
        } else if ('Customer of Oversea Company' == row.Classification){
            this.scoreSheetPageAgency = false;
            this.scoreSheetPageOEM = false;
            this.scoreSheetPageOversea = true;
        }
    }
    // 关闭打分表信息
    closeScoreSheetView(){
        this.isShowScoreSheetView = false;
        this.scoreSheetViewRecord = {};
    }
    // 打分表字段赋值
    handleScoreSheetViewFieldChange(event){
        const targetName = event.target.dataset.fieldName;
        this.scoreSheetViewRecord[targetName] = event.target.value;
    }
    // 保存打分表
    handleSaveScoreSheetView(){
        this.isShowSpinnerDialog = true;
        if (this.verifyField('.score_view_from lightning-input-field', '')) {
            // 根据销售视图id查询税信息
            saveScoreSheetView({ 
                viewRecord : JSON.stringify(this.scoreSheetViewRecord)
            })
            .then(result => {
                this.isShowSpinnerDialog = false;
                if(result.isSuccess){
                    this.showSuccess('Save successfully!');
                    this.isShowScoreSheetView = false;
                    // 刷新产品线列表
                    this.getCustomerProductLine();
                    // getRecordNotifyChange([{ recordId: this.scoreSheetViewRecord.Id }]); // 刷新 LDS 缓存
                    notifyRecordUpdateAvailable([{ recordId: this.scoreSheetViewRecord.Id }]); // 刷新 LDS 缓存
                }else {
                    this.showError(result.message);
                }
            })
            .catch(error => {
                this.isShowSpinnerDialog = false;
                this.showError('Save Score Sheet failure!' + JSON.stringify(error));
            });
        }else {
            this.isShowSpinnerDialog = false;
            return;
        }
        
    }
    // -----------------------------------------Customer Product Line---------------------------------------------

    // 客户状态在调整中时，修改人不是调整人，则不能修改数据，返回true，管理员排除
    VerifyCurrentModifier(){
        if(!this.isCurrentModifier && this.isCanUndoChanges && !this.isAdmin){
            LightningAlert.open({
                message: 'The current customer is being processed! Please contact ' + this.currentModifier,
                theme: 'warning', // a red theme intended for error states
                label: 'Warning', // this is the header text
            });
            return true;
        }else {
            return false;
        }
    }

    // 撤销修改操作
    async handleUndoChangesView(){
        if(this.VerifyCurrentModifier()) return;
        const result = await LightningConfirm.open({
            message: 'Determine to undo changes to the last approval completion state?',
            theme: "info",
            label: 'Undo changes',
            // setting theme would have no effect
        });
        if (result) {
            this.isShowSpinner = true;
            await undoChangesView({ 
                recordId : this.recordId,
            })
            .then(result => {
                this.isShowSpinner = false;
                if(result.isSuccess){
                    notifyRecordUpdateAvailable([{ recordId: this.recordId}]); // 刷新 LDS 缓存
                    this.goToRecord(this.recordId);
                    this.showSuccess('Undo Changes successfully!');
                }else {
                    this.showError(result.message);
                }
            })
            .catch(error => {
                this.isShowSpinner = false;
                this.showError('Undo Changes failure!' + JSON.stringify(error));
            });
        }
    }

    // 查看修改的内容信息
    handleChangesInfoView(){
        this.isShowChangesInfoView = true;
    }
    // 关闭修改的内容
    closeChangesInfoView(){
        this.isShowChangesInfoView = false;
    }
    // 子页面返回是否显示Undo Changes按钮
    handleCheckHistory(event){
        console.log('wwwww父类取数-----' + event.detail);
    }

    // 地址类客户同步SAP
    async handleSyncToSAP(){
        // 地址类客户和其他客户
        if(this.isCustomerAddress){
            if(!this.isHaveSalesView){
                this.showError('Please maintain the sales view!');
                return;
            }
        }else {
            if(!this.isHaveCompanyView && !this.isHaveSalesView){
                this.showError('Please maintain the company view and sales view!');
                return;
            }else if(!this.isHaveSalesView){
                this.showError('Please maintain the sales view!');
                return;
            }else if(!this.isHaveCompanyView){
                this.showError('Please maintain the company view!');
                return;
            }  
        }
        const result = await LightningConfirm.open({
            message: 'Are you sure you want to synchronize this data to sap?',
            theme: "info",
            label: 'Sync To SAP',
            // setting theme would have no effect
        });
        if (result) {
            // 先保存数据再提交
            this.handleSaveAccountView('6');
        }
    }
    async syncToSAP(){
        this.isShowSpinner = true;
        await handleSyncToSAP({ 
            recordId : this.recordId,
        })
        .then(result => {
            this.isShowSpinner = false;
            if(result == 'SUCCESS'){
                notifyRecordUpdateAvailable([{ recordId: this.recordId}]); // 刷新 LDS 缓存
                this.showSuccess('Sync To SAP successfully!');
            }else {
                this.showError('Sync To SAP failure!' + JSON.stringify(result));
            }
        })
        .catch(error => {
            this.isShowSpinner = false;
            this.showError('Sync To SAP failure!' + JSON.stringify(error));
        });
    }
    // 上传法务报告
    handleLegalReportView(){
        if(this.isHaveRecordId){
            this.isShowLegalReportView = true;
        }else {
            this.showError('Please save the customer data first!');
        }
    }
    // 关闭上传法务报告
    closeLegalReportView(){
        this.isShowLegalReportView = false;
        if(!this.isNew){
            this.dispatchEvent(new CustomEvent('closeModal')); 
        }else {
            // 刷新下方 file 模块
            var cmps = this.template.querySelectorAll('c-training-task-upload-files-view-list-l-w-c');
            for (let i = 0; i < cmps.length; i++) {
                var lookup = cmps[i];
                lookup.refreshFileBox();
            }
        }
    }
    // 校验注册信息是否已存在
    handleVerificationClick(event){
        let flag = true;
        let message = '';
        // 校验 Guarantor_Country_Code__c 字段
        if(!this.judgeNotEmpty(this.accountRecord.Guarantor_Country_Code__c)){
            flag = false;
            message += ',' + this.accountLabelInfo.Guarantor_Country_Code__c;
        }
        // 校验 Company_Registration_Number__c 字段
        if(!this.judgeNotEmpty(this.accountRecord.Company_Registration_Number__c)){
            flag = false;
            message += ',' + this.accountLabelInfo.Company_Registration_Number__c;
        }
        // 校验注册信息
        if(flag){
            this.isShowSpinner = true;
            handleVerification({ 
                countryCode : this.accountRecord.Guarantor_Country_Code__c,
                registrationNumber : this.accountRecord.Company_Registration_Number__c,
                recordTypeId : this.recordTypeId,
                recordId : this.recordId,
            })
            .then(result => {
                if(result.isSuccess){
                    if(result.data.isHaveLocalAccount){
                        // 弹出框是否跳转已存在客户
                        this.gotoExistsAccount(result.data.account);
                    }else if(result.data.isHaveMDGAccount){
                        let mergedObj = Object.assign({}, this.accountRecord, result.data.account);
                        this.accountFromMdgJson = result.data.accountJson;
                        console.log('wwwww-----' + result.data.accountJson);
                        // 弹出框是否同步数据
                        this.syncMDGAccount(mergedObj);
                    }else {
                        this.isShowSpinner = false;
                        this.showSuccess('Verification passed');
                        this.verificationIconName = 'utility:success';
                    }
                }else {
                    this.isShowSpinner = false;
                    this.showError('Verification failure!' + JSON.stringify(result));
                }
            })
            .catch(error => {
                this.isShowSpinner = false;
                this.showError('Verification failure!' + JSON.stringify(error));
            });
        }else {
            this.showError('Please fill in ' + message.substring(1));
        }
    }
    async syncMDGAccount(mergedObj){
        const resultConfirm = await LightningConfirm.open({
            message: 'The customer already exists in the MDG. MDG Customer Code is '+ mergedObj.MDG_Customer_Code__c + '. Clicking "OK" will synchronize the customer',
            theme: "success",
            label: mergedObj.Customer_Name_Local_Language__c,
            // setting theme would have no effect
        });
        if (resultConfirm) {
            // this.accountRecord = mergedObj;
            // // 同步后按钮添加对号
            // this.verificationIconName = 'utility:success';
            // // 同步后锁定Guarantor_Country_Code__c,Company_Registration_Number__c
            // this.isVerification = true;

            // 同步MDG客户数据后跳转到新增页面
            syncMDGAccount({ 
                accountFromMdgJson: this.accountFromMdgJson,
                recordTypeId : this.recordTypeId,
            })
            .then(result => {
                this.isShowSpinner = false;
                if(result.isSuccess){
                    // 跳转到同步客户
                    this.goToRecord(result.data.Account.Id);
                }else {
                    this.showError('Synchronize the customer failure!' + JSON.stringify(result));
                }
            })
            .catch(error => {
                this.isShowSpinner = false;
                this.showError('Synchronize the customer failure!' + JSON.stringify(error));
            });
        }else {
            this.isShowSpinner = false;
        }
    }
    async gotoExistsAccount(account){
        const resultConfirm = await LightningConfirm.open({
            message: 'The customer already exists in the system. MDG Customer Code is '+ account.MDG_Customer_Code__c + '. Clicking "OK" will redirect to this customer.',
            theme: "success",
            label: account.Name,
            // setting theme would have no effect
        });
        if (resultConfirm) {
            this.goToRecord(account.Id);
        }else {
            this.isShowSpinner = false;
        }
    }

    judgeNotEmpty(fieldValue){
        if(fieldValue != undefined && fieldValue != null && fieldValue != "") {
            return true;
        }else{
            return false;
        }
    }
}