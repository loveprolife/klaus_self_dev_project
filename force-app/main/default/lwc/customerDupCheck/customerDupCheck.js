import { LightningElement, track, api } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import findAccount from '@salesforce/apex/CustomerDupliCheckController.findAccount';
import getCountryList from '@salesforce/apex/CustomerDupliCheckController.getCountryList';
import getIdTypeList from '@salesforce/apex/CustomerDupliCheckController.getIdTypeList';
import getRecordTypeDeveloperName from '@salesforce/apex/CustomerDupliCheckController.getRecordTypeDeveloperName';
import getParentCustomerInfo from '@salesforce/apex/CustomerDupliCheckController.getParentCustomerInfo';
import MDGSubCustomerCheckRequired from '@salesforce/label/c.MDGSubCustomerCheckRequired';
import MDGCustomerDupCheckRequired from '@salesforce/label/c.MDGCustomerDupCheckRequired';
import MDGCustomerFoundInMDG from '@salesforce/label/c.MDGCustomerFoundInMDG';
import MDGCustomerFoundInSF from '@salesforce/label/c.MDGCustomerFoundInSF';
import MDGCustomerNotFound from '@salesforce/label/c.MDGCustomerNotFound';
import MDGDupliCheckTitle from '@salesforce/label/c.MDGDupliCheckTitle';
import MDGCountryRegion from '@salesforce/label/c.MDGCountryRegion';
import MDGTypeID from '@salesforce/label/c.MDGTypeID';
import MDGRegNoStaffNo from '@salesforce/label/c.MDGRegNoStaffNo';
import MDGCustomerSqlField from '@salesforce/label/c.MDGCustomerSqlField';
import MDGCustomerExtendCompanyViewSqlField from '@salesforce/label/c.MDGCustomerExtendCompanyViewSqlField';
import MDGCustomerExtendSalesViewSqlField from '@salesforce/label/c.MDGCustomerExtendSalesViewSqlField';
import Button_Back from '@salesforce/label/c.Button_Back';
import Button_Next from '@salesforce/label/c.Button_Next';
import { NavigationMixin } from 'lightning/navigation';

export default class CustomerDupCheck extends NavigationMixin(LightningElement) {
    @api recordTypeId;
    @track country = '';
    @track idType = '';
    @track registrationNumber = '';
    @track account;
    @track errorMessage;
    // @track picklistOptions;
    @track isShowSpinner;
    @track isMDGAccount;
    @track recordTypeName;
    customerFoundInSF = MDGCustomerFoundInSF;
    customerFoundInMDG = MDGCustomerFoundInMDG;
    Label_DupliCheckTitle = MDGDupliCheckTitle;
    Label_CountryRegion = MDGCountryRegion;
    Label_TypeID = MDGTypeID;
    Label_RegNoStaffNo = MDGRegNoStaffNo;
    @track isValid = false;
    @track customerInfoMDG;
    @track idTypeList = [];
    @track isRegularCustomer = false; // 用于控制显示哪个块的布尔变量
    // ----------------------(wfc:2025-01-24)-------------------------
    @track isSubCustomerFlag = false; // 是否是分户创建标记
    @track parentCustomerOfSubAcc = '';
    @track subAccountType = '';
    @track reasonsCustomerSegmentation = '';
    @track creditManagement = '';
    @track isHaveCreditManagement = false;
    @track customerExtendCompanyView;
    @track customerExtendSalesView;

    label = {
        Button_Back,
        Button_Next
    }
    // ---------------------------------------------------------------

    @track searchValue = '';  // 用户输入的文字
    // @track selectedCountry = '';  // 选中的国家

    @track allCountries = [  // 示例数据：可以通过 Apex 动态加载数据
        // { label: 'United States', value: 'US' },
        // { label: 'Canada', value: 'CA' },
        // { label: 'Germany', value: 'DE' },
        // { label: 'France', value: 'FR' },
        // { label: 'Spain', value: 'ES' },
        // { label: 'United Kingdom', value: 'GB' },
        // { label: 'Australia', value: 'AU' },
        // { label: 'India', value: 'IN' }
    ];
    filteredCountries = [];  // 筛选后的候选国家

    // 处理输入框的变化
    handleSearchInput(event) {
        this.searchValue = event.target.value;
        this.filterCountries();
    }

    // 根据输入值过滤国家
    filterCountries() {
        if (this.searchValue) {
            this.filteredCountries = this.allCountries.filter(country =>
                country.label.toLowerCase().includes(this.searchValue.toLowerCase())
            );
        } else {
            this.filteredCountries = [];
        }
    }

    // 处理选中的国家
    handleCountrySelect(event) {
        this.country = event.target.dataset.value;
        this.searchValue = event.target.innerText;  // 更新输入框内容
        this.filteredCountries = [];  // 选择后隐藏候选项
    }

    get style() {
        var width;
        var userAgent = navigator.userAgent;
        if (/iphone|iPhone|ipad|iPad|ipod|iPod|iOS|ios/.test(userAgent) || /android|Android/.test(userAgent)) {  
            width = 'width: 100%;';
        } else { 
            width = 'width: 36%;';
        }
        return width;
    }

    async connectedCallback() {
        console.log('lwc loaded : ' + this.recordTypeId);
        this.isShowSpinner = true;
        
        // sub account不允许从New button直接创建，需要从详情页面创建
        // 后续考虑将详情页面的related list做成cmp，这样就可以从new button中隐藏sub account的record type
        await getRecordTypeDeveloperName({recordTypeId:this.recordTypeId}).then(result => {
            console.log('rtName : ' + result);
            this.recordTypeName = result;
            // 是否是分户创建标记 (wfc:2025-01-24)  
            if(result == 'Sub_Account'){
                console.log('wwwww----分户页面');
                this.isSubCustomerFlag = true;
                return;
            }else {
                this.isSubCustomerFlag = false;
            }

            // 非注册实体和分户隐藏注册号，不需要填写 2025.1.23
            if (result == 'Hisense_International_Custoemr_Unconventional' || result == 'Sub_Account' || result == 'Address') {

                console.log('无需填写注册号');
                this.isRegularCustomer = false;
                this.navigateToNewAccount();
                return;

            } else {
                this.isRegularCustomer = true;
            }
            
            // 放开业务创建分户的限制，可以直接创建分户，并且自由选择主户 桑老师提出优化 2025.1.23
            // if (result == 'Sub_Account') {
            //     this.showToast('Error', 'Sub-account customers can only be created from the customer details page', 'error');
                
            //     this.handleCancel();
            //     return;
            // }
        }).catch(error => {
            console.log('get developer Name error : ', JSON.stringify(error));
        });
        
        await this.loadPicklistValues();
        // 员工类客户默认选择身份证明类型 2025.1.23
        if (this.recordTypeName == 'Staff') {
            this.idType = 'Z35';
        }
        console.log('this.allCountries : ', this.allCountries);
        this.isShowSpinner = false;
    }

    handleCountryChange(event) {
        this.country = event.target.value;
    }

    handleRegistrationChange(event) {
        // this.registrationNumber = event.target.value;
        this.registrationNumber = event.target.value.replace(/\s+/g, ' ').trim(); // 去除空格 2024.12.27 桑弘优化需求
    }

    handleIdTypeChange(event) {
        this.idType = event.target.value;
    }

    handleCancel() {
        this[NavigationMixin.Navigate]({
            type: 'standard__objectPage',
            attributes: {
                objectApiName   :   'Account',
                actionName      :   'home'
            }
        });
    }

    async handleNext() {

        this.errorMessage = '';
        this.isShowSpinner = true;
        console.log('this.country', this.country);
        console.log('this.idType', this.idType);
        console.log('this.registrationNumber', this.registrationNumber);
        
        // 前端校验，国家与注册码/员工编码是否合法
        await this.validateInputValues();
        console.log('this.isValid : ' + this.isValid);
        if (this.isValid) {
            this.isShowSpinner = false;
            return;
        }

        // 分户保存
        if(this.recordTypeName == 'Sub_Account'){
            this.navigateToNewAccountSubCustomer();
        }else {
            this.account = null;
            // 本地查询有无重复主数据
            await findAccount({ country: this.country, registrationNumber: this.registrationNumber, recordTypeId: this.recordTypeId })
            .then(result => {
                if (result && this.recordTypeName != 'Hisense_International_Custoemr_Unconventional' && this.recordTypeName != 'Sub_Account' && this.recordTypeName != 'Address') {
                    console.log('account found: ', result);
                    this.isMDGAccount = false;

                    // 找到重复主数据
                    if (result.Id == '' || result.Id == undefined) {
                        // this.showToast('Warn', MDGCustomerFoundInMDG, 'warn');
                        // this.isMDGAccount = true;
                        // 导航到找到的 Account 记录
                        this.account = result;
                        this.navigateToNewAccount();
                    } else {
                        this.account = result;
                        this.isShowSpinner = false;
                        return;
                    }

                } else {
                    this.isShowSpinner = false;
                    this.showToast('Success', MDGCustomerNotFound , 'success');
                    // 导航到新建 Account 的 RecordType 选择页面
                    this.navigateToNewAccount();
                }
            })
            .catch(error => {
                this.isShowSpinner = false;
                this.showToast('Error', error.body.message, 'error');
            });
        }
    }

    get accountLink() {
        console.log('account link:', this.account.Id);
        return `/lightning/r/Account/${this.account.Id}/view`;
    }

    navigateToRecord(accountId) {
        // 导航到指定的 Account 记录
        this[NavigationMixin.Navigate]({
            type: 'standard__recordPage',
            attributes: {
                recordId: accountId,
                actionName: 'view'
            }
        });
    }

    navigateToNewAccount() {
        console.log('navigate to new record page : ' + this.recordTypeId);

        // 定义从第三方接口查询到的信息，自动匹配到新建 Account 的字段
        // 第三方接口未定
        let fieldValues = [];
        fieldValues.push('Guarantor_Country_Code__c=' + this.country);
        fieldValues.push('Company_Registration_Number__c=' + this.registrationNumber);
        fieldValues.push('VAT_Registration_Number__c=' + this.registrationNumber);
        fieldValues.push('ID_Type__c=' + this.idType);

        if (this.account != null && this.account != undefined) {
            fieldValues.push('Name=' + this.account.Name != undefined ? this.account.Name : '');
            // fieldValues.push('SAP_Customer_Code__c=' + this.account.SAP_Customer_Code__c);
            fieldValues.push('MDG_Customer_Code__c=' + this.account.MDG_Customer_Code__c);
            fieldValues.push('Customer_Name_Local_Language__c=' + this.account.Customer_Name_Local_Language__c);
            fieldValues.push('Customer_Short_Name__c=' + this.account.Customer_Short_Name__c);
            fieldValues.push('FormerName__c=' + this.account.FormerName__c);
            fieldValues.push('Company_Registration_Number__c=' + this.account.Company_Registration_Number__c);
            fieldValues.push('DUNS_Number__c=' + this.account.DUNS_Number__c);
            fieldValues.push('VAT_Registration_Number__c=' + this.account.VAT_Registration_Number__c);
            // fieldValues.push('License_Expiration_Date__c=' + this.account.License_Expiration_Date__c);
            //fieldValues.push('Registration_Date__c=' + this.account.Registration_Date__c);
            fieldValues.push('Registered_Capital__c=' + this.account.Registered_Capital__c);
            fieldValues.push('Paid_In_Funds__c=' + this.account.Paid_In_Funds__c);
            fieldValues.push('Corporate_Representative__c=' + this.account.Corporate_Representative__c);
            fieldValues.push('Unit_Nature__c=' + this.account.Unit_Nature__c);
            fieldValues.push('Annual_Revenue_Scale__c=' + this.account.Annual_Revenue_Scale__c);
            fieldValues.push('Listed_Company_Code__c=' + this.account.Listed_Company_Code__c);
            fieldValues.push('Language__c=' + this.account.Language__c);
            fieldValues.push('NumberOfEmployees=' + this.account.NumberOfEmployees);
            fieldValues.push('Website=' + this.account.Website);
            fieldValues.push('Main_Business_Scope__c=' + this.account.Main_Business_Scope__c);
            fieldValues.push('Email__c=' + this.account.Email__c);
            fieldValues.push('Fax=' + this.account.Fax);
            fieldValues.push('Phone=' + this.account.Phone);
            // fieldValues.push('Industry_Sector__c=' + this.account.Industry_Sector__c);
            // 解决Parent Customer问题 (wfc 2025-02-08)
            if(this.verifyIsNotNull(this.account.ParentId)){
                fieldValues.push('ParentId=' + this.account.ParentId);
            }
            fieldValues.push('Customer_Status_MDG__c=' + this.account.Customer_Status_MDG__c);
            fieldValues.push('Customer_Risk_Level__c=' + this.account.Customer_Risk_Level__c);
            fieldValues.push('Customer_Risk_Type__c=' + this.account.Customer_Risk_Type__c);
            fieldValues.push('Unified_customer_group_code__c=' + this.account.Unified_customer_group_code__c);
            fieldValues.push('Channel_Customer_Categories__c=' + this.account.Channel_Customer_Categories__c);
            fieldValues.push('Channel_Customer_Subcategories__c=' + this.account.Channel_Customer_Subcategories__c);
            fieldValues.push('credit_rating__c=' + this.account.credit_rating__c);
            fieldValues.push('Transportation_area__c=' + this.account.Transportation_area__c);
            fieldValues.push('Overseas_customer_level__c=' + this.account.Overseas_customer_level__c);
            fieldValues.push('Sub_account_type__c=' + this.account.Sub_account_type__c);
            fieldValues.push('Reasons_for_customer_segmentation__c=' + this.account.Reasons_for_customer_segmentation__c);
            fieldValues.push('Global_Location_Number__c=' + this.account.Global_Location_Number__c);
            fieldValues.push('E_commerce_Customer_Label__c=' + this.account.E_commerce_Customer_Label__c);
            fieldValues.push('Tax_Number1__c=' + this.account.Tax_Number1__c);
            fieldValues.push('Tax_Number1__c=' + this.account.Tax_Number1__c);

            // 客户新增字段 （wfc 2025-02-08）
            fieldValues.push('Search_Term2__c=' + this.account.Search_Term2__c);
            fieldValues.push('Tax_Number3__c=' + this.account.Tax_Number3__c);
            fieldValues.push('Tax_Number4__c=' + this.account.Tax_Number4__c);
            fieldValues.push('Supplier__c=' + this.account.Supplier__c);
        }

        // 导航到标准的 Account RecordType 选择页面
        this[NavigationMixin.Navigate]({
            type: 'standard__objectPage',
            attributes: {
                objectApiName: 'Account',
                actionName: 'new'
            },
            state: {
                defaultFieldValues : fieldValues.join(','),
                nooverride: '1',
                recordTypeId: this.recordTypeId,
            }
        });
    }

    // 加载国家列表
    async loadPicklistValues() {
        console.log('loadPicklistValues');
        await getCountryList()
            .then(result => {
                this.allCountries = result.map(value => {
                    // console.log(value);
                    return { label: value.Label, value: value.Value };
                });
            })
            .catch(error => {
                console.log('error:', error);
                this.showToast('Error', error, 'error');
            })

        await getIdTypeList()
            .then(result => {
                this.idTypeList = result.map(value => {
                    // console.log(value);
                    return { label: value.Label, value: value.Value };
                });
                this.idType = 'Z25'; // 初始化 idType默认值公司注册号（大陆外公司使用）	Z25 2024.12.27 桑弘优化需求
            })
            .catch(error => {
                console.log('error:', error);
                this.showToast('Error', error, 'error');
            })
    }
    
    // 输入校验
    async validateInputValues() {
        // 分户校验--------(wfc:2025-01-24)-----------
        if(this.recordTypeName == 'Sub_Account'){
            console.log('wwwwvalidate-----' + this.parentCustomerOfSubAcc)
            console.log('wwwwvalidate-----' + this.subAccountType)
            console.log('wwwwvalidate-----' + this.reasonsCustomerSegmentation)
            console.log('wwwwvalidate-----' + this.creditManagement)
            if (this.parentCustomerOfSubAcc === '' || this.subAccountType === '' || this.reasonsCustomerSegmentation === '' || this.creditManagement === '') {
                this.errorMessage = MDGSubCustomerCheckRequired;
                this.isValid = true;
                return;
            }
        }else {
            if (this.recordTypeName != 'Hisense_International_Custoemr_Unconventional' && this.recordTypeName != 'Sub_Account' && this.recordTypeName != 'Address') {
                if (this.country === '' || this.registrationNumber === '') {
                    this.errorMessage = MDGCustomerDupCheckRequired;
                    this.isValid = true;
                    return;
                }
            }
    
            if (this.country != '') {
                // 查找输入的值是否存在于 allCountries 中
                const isValidCty = this.allCountries.some(country =>
                    country.label.toLowerCase() === this.searchValue.toLowerCase()
                );
    
                if (!isValidCty) {
                    // 如果输入的国家不在列表中，可以显示错误提示
                    this.errorMessage = 'Please select a valid country';
                    this.isValid = true;
                    return; // 退出函数，不执行下面的代码
                } else {
                    // 如果输入的国家是有效的，清除错误提示
                    this.errorMessage = '';
                }
            }
    
    
            if (this.recordTypeName == 'Staff' && this.registrationNumber.length != 8) {
                this.errorMessage = '员工类客户，员工号必须为8位数字';
                this.isValid = true;
                return;
            } else {
                this.isValid = false;
                return;
            }
        }
        
    }

    showToast(title, message, variant) {
        const evt = new ShowToastEvent({
            title: title,
            message: message,
            variant: variant,
        });
        this.dispatchEvent(evt);
    }

    // ----------------------(wfc:2025-01-24)-------------------------
    handleParentCustomerOfSubAccChange(event){
        this.parentCustomerOfSubAcc = event.target.value;
        this.changeParentCustomer();
    }

    handleSubAccountTypeChange(event){
        this.subAccountType = event.target.value;
    }

    handleReasonsCustomerSegmentationChange(event){
        this.reasonsCustomerSegmentation = event.target.value;
    }

    handleCreditManagementChange(event){
        this.creditManagement = event.target.value;
    }

    async changeParentCustomer(){
        await getParentCustomerInfo({parentCustomerOfSubAcc:this.parentCustomerOfSubAcc}).then(result => {
            if(result){
                console.log('wwwwww-----' + JSON.stringify(result.data.Account));
                console.log('wwwwww-----' + JSON.stringify(result.data.CompanyView));
                console.log('wwwwww-----' + JSON.stringify(result.data.SalesView));
                this.account = result.data.Account;
                this.customerExtendCompanyView = result.data.CompanyView;
                this.customerExtendSalesView = result.data.SalesView;
                
                if(this.verifyIsNotNull(this.account.Credit_Management__c)){
                    this.isHaveCreditManagement = true;
                    this.creditManagement = this.account.Credit_Management__c;
                }else {
                    this.isHaveCreditManagement = false;
                    this.creditManagement = '';
                }
            }
        }).catch(error => {
            console.log('get Parent Customer error : ', JSON.stringify(error));
        });
    }

    navigateToNewAccountSubCustomer() {
        console.log('wwww--navigate to new record page : ' + this.recordTypeId);
        let fieldValues = [];
        fieldValues.push('ParentCustomerOfSubAcc__c=' + this.parentCustomerOfSubAcc);
        fieldValues.push('Sub_account_type__c=' + this.subAccountType);
        fieldValues.push('Reasons_for_customer_segmentation__c=' + this.reasonsCustomerSegmentation);
        fieldValues.push('Credit_Management__c=' + this.creditManagement);
        // 主信息
        if (this.verifyIsNotNull(this.account)) {
            let customerSqlFieldArr = MDGCustomerSqlField.split(","); // 将字符串以逗号为分隔符拆分
            for (var i = 0; i < customerSqlFieldArr.length; i++) {
                const customerSqlField = customerSqlFieldArr[i];
                if(this.verifyIsNotNull(this.account[customerSqlField])){
                    fieldValues.push(customerSqlField + '=' + this.account[customerSqlField]);
                }
            }          
        }
        // 公司视图
        if(this.verifyIsNotNull(this.customerExtendCompanyView)){
            let customerExtendCompanyViewSqlFieldArr = MDGCustomerExtendCompanyViewSqlField.split(","); // 将字符串以逗号为分隔符拆分
            for (var i = 0; i < customerExtendCompanyViewSqlFieldArr.length; i++) {
                const customerSqlField = customerExtendCompanyViewSqlFieldArr[i];
                if(this.verifyIsNotNull(this.customerExtendCompanyView[customerSqlField])){
                    fieldValues.push(customerSqlField + '=' + this.customerExtendCompanyView[customerSqlField]);
                }
            }
        }
        // 销售视图
        if(this.verifyIsNotNull(this.customerExtendSalesView)){
            let customerExtendSalesViewSqlFieldArr = MDGCustomerExtendSalesViewSqlField.split(","); // 将字符串以逗号为分隔符拆分
            for (var i = 0; i < customerExtendSalesViewSqlFieldArr.length; i++) {
                const customerSqlField = customerExtendSalesViewSqlFieldArr[i];
                if(this.verifyIsNotNull(this.customerExtendSalesView[customerSqlField])){
                    fieldValues.push(customerSqlField + '=' + this.customerExtendSalesView[customerSqlField]);
                }
            }
        }
        this.isShowSpinner = false;
        // 导航到标准的 Account RecordType 选择页面
        this[NavigationMixin.Navigate]({
            type: 'standard__objectPage',
            attributes: {
                objectApiName: 'Account',
                actionName: 'new'
            },
            state: {
                defaultFieldValues : fieldValues.join(','),
                nooverride: '1',
                recordTypeId: this.recordTypeId,
            }
        });
        
    }

    // 验验证选择列表行数据是否为空
    verifyIsNotNull(verifyData){
        if(verifyData != null && verifyData != '' && verifyData != undefined){
            return true;
        }else {
            return false;
        }
    }
    // -------------------------------end---------------------------------
}