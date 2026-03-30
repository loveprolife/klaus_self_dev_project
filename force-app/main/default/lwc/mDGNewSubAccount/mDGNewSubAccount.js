import { LightningElement, api, wire, track } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
import getRecordTypeIdByDeveloperName from '@salesforce/apex/MDGNewSubAccountController.getRecordTypeIdByDeveloperName';
import getParentCustomerInfo from '@salesforce/apex/CustomerDupliCheckController.getParentCustomerInfo';
import getParentFields from '@salesforce/apex/MDGNewSubAccountController.getParentFields';
import New_Sub_Account_Title from '@salesforce/label/c.New_Sub_Account_Title';
import MDGCustomerSqlField from '@salesforce/label/c.MDGCustomerSqlField';
import MDGCustomerExtendCompanyViewSqlField from '@salesforce/label/c.MDGCustomerExtendCompanyViewSqlField';
import MDGCustomerExtendSalesViewSqlField from '@salesforce/label/c.MDGCustomerExtendSalesViewSqlField';
import MDGSubCustomerCheckRequired from '@salesforce/label/c.MDGSubCustomerCheckRequired';
import Button_Back from '@salesforce/label/c.Button_Back';
import Button_Next from '@salesforce/label/c.Button_Next';
// import { ShowToastEvent } from 'lightning/platformShowToastEvent';

export default class MDGNewSubAccount extends NavigationMixin(LightningElement) {
    @api recordId; // 当前Account的ID
    parentAccount;

    @track recordTypeId;
    fieldValuesAdd = [];
    errorMsg = '';

    @track creditManagement = '';
    @track showSection = false;
    // @track isHaveCreditManagement = false;
    @track initSuccess = true;

     // ----------------------(wfc:2025-02-05)-------------------------
     @track isSubCustomerFlag = false; // 是否是分户创建标记
     @track parentCustomerOfSubAcc = '';
     @track subAccountType = '';
     @track reasonsCustomerSegmentation = '';
     @track creditManagement = '';
     @track isHaveCreditManagement = false;
     @track customerExtendCompanyView;
     @track customerExtendSalesView;
     @track errorMessage;
     @track isValid = false;
     @track account;
     // ---------------------------------------------------------------

    label = {
        New_Sub_Account_Title,
        Button_Back,
        Button_Next,
    }

    handleCreditManagementChange(event){
        this.creditManagement = event.target.value;
        if(this.creditManagement != '' && this.creditManagement != null && this.creditManagement != undefined){
            this.isHaveCreditManagement = true;
        }else{
            this.isHaveCreditManagement = false;
        }
    }
    
    connectedCallback(){
        getRecordTypeIdByDeveloperName({ developerName: 'Sub_Account' }).then(result => {
            console.log('wwwww----' + JSON.stringify(result));
            this.recordTypeId = result;
        });
    }

    handleShowSection(){
        // this.init();
        this.showSection = true;
        this.parentCustomerOfSubAcc = this.recordId;
        this.changeParentCustomer();
    }

    handleCloseSection(){
        this.showSection = false;
    }

    async init() {
        this.recordTypeId = await getRecordTypeIdByDeveloperName({ developerName: 'Sub_Account' }); // 你需要替换为实际的Sub Account Record Type ID
        getParentFields({ recordId: this.recordId })
            .then(result => {
                console.log('parentAccount: ', JSON.stringify(result));
                let fieldValues = [];
                fieldValues.push('ParentCustomerOfSubAcc__c=' + this.recordId);
                fieldValues.push('ParentId=' + this.recordId);
                fieldValues.push('Guarantor_Country_Code__c=' + result.Guarantor_Country_Code__c);
                fieldValues.push('Province_State__c=' + result.Province_State__c);
                fieldValues.push('City__c=' + result.City__c);
                if (result.City_CN__c != null && result.City_CN__c != undefined) {
                    fieldValues.push('City_CN__c=' + result.City_CN__c);
                }
                if (result.District_CN__c != null && result.District_CN__c != undefined) {
                    fieldValues.push('District_CN__c=' + result.District_CN__c);
                }
                if (result.Township_CN__c != null && result.Township_CN__c != undefined) {
                    fieldValues.push('Township_CN__c=' + result.Township_CN__c);
                }
                if (result.Sales_Region__c != null && result.Sales_Region__c != undefined) {
                    fieldValues.push('Sales_Region__c=' + result.Sales_Region__c);
                }
                fieldValues.push('Address__c=' + result.Address__c);
                if (result.Hisense_Entity_Sales__c != null && result.Hisense_Entity_Sales__c != undefined) {
                    fieldValues.push('Hisense_Entity_Sales__c=' + result.Hisense_Entity_Sales__c);
                }
                if (result.Payment_Term_Sales__c != null && result.Payment_Term_Sales__c != undefined) {
                    fieldValues.push('Payment_Term_Sales__c=' + result.Payment_Term_Sales__c);
                }
                if (result.Hisense_Entity__c != null && result.Hisense_Entity__c != undefined) {
                    fieldValues.push('Hisense_Entity__c=' + result.Hisense_Entity__c);
                }
                if (result.Payment_Term__c != null && result.Payment_Term__c != undefined) {
                    fieldValues.push('Payment_Term__c=' + result.Payment_Term__c);
                }
                // fieldValues.push('Shipping_Conditions__c=' + result.Shipping_Conditions__c);
                fieldValues.push('Reconciliation_Customer__c=' + result.Reconciliation_Customer__c);
                fieldValues.push('Buyer_English_Name__c=' + result.Buyer_English_Name__c);
                if (result.Customer_Group2__c != null && result.Customer_Group2__c != undefined) {
                    fieldValues.push('Customer_Group2__c=' + result.Customer_Group2__c);
                }
                if (result.VAT_Tax_type__c != null && result.VAT_Tax_type__c != undefined) {
                    fieldValues.push('VAT_Tax_type__c=' + result.VAT_Tax_type__c);
                }
                // 主户Credit_Management__c有值，则取主户的值
                if (result.Credit_Management__c != null && result.Credit_Management__c != undefined) {
                    fieldValues.push('Credit_Management__c=' + result.Credit_Management__c);
                    try {
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
                    } catch (error) {
                        console.error('Error navigating to new record page:', JSON.stringify(error));
                    }
                }else {
                    this.showSection = true;
                }
                this.fieldValuesAdd = fieldValues;
                console.log('fieldValues: ', JSON.stringify(fieldValues));
                
            }).catch(error => {
                console.error('Error fetching parent account:', JSON.stringify(error));
                this.errorMsg = 'Error fetching parent account:', JSON.stringify(error);
                this.initSuccess = false;
            })
    }
    

    async openNewRecordPage() {
        if(!this.initSuccess){  
            this.dispatchEvent(new ShowToastEvent({
                title: 'error',
                message: this.errorMsg,
                variant: 'error',
                // mode: "sticky"
            }));
            return;
        }
        this.showSection = false;
        this.fieldValuesAdd.push('Credit_Management__c=' + this.creditManagement);
        console.log('fieldValues: ', JSON.stringify(this.fieldValuesAdd));
        console.log('recordTypeId: ', JSON.stringify(this.recordTypeId));
        try {
            this[NavigationMixin.Navigate]({
                type: 'standard__objectPage',
                attributes: {
                    objectApiName: 'Account',
                    actionName: 'new'
                },
                state: {
                    defaultFieldValues : this.fieldValuesAdd.join(','),
                    nooverride: '1',
                    recordTypeId: this.recordTypeId,
                }
            });
        } catch (error) {
            console.error('Error navigating to new record page:', JSON.stringify(error));
        }

        // const recordTypeId = await getRecordTypeIdByDeveloperName({ developerName: 'Sub_Account' }); // 你需要替换为实际的Sub Account Record Type ID
        // // const parentRecord = getParentFields({ recordId: this.recordId });
        // getParentFields({ recordId: this.recordId })
        //     .then(result => {
        //         console.log('parentAccount: ', JSON.stringify(result));
        //         let fieldValues = [];
        //         fieldValues.push('ParentCustomerOfSubAcc__c=' + this.recordId);
        //         fieldValues.push('ParentId=' + this.recordId);
        //         fieldValues.push('Guarantor_Country_Code__c=' + result.Guarantor_Country_Code__c);
        //         fieldValues.push('Province_State__c=' + result.Province_State__c);
        //         fieldValues.push('City__c=' + result.City__c);
        //         if (result.City_CN__c != null && result.City_CN__c != undefined) {
        //             fieldValues.push('City_CN__c=' + result.City_CN__c);
        //         }
        //         if (result.District_CN__c != null && result.District_CN__c != undefined) {
        //             fieldValues.push('District_CN__c=' + result.District_CN__c);
        //         }
        //         if (result.Township_CN__c != null && result.Township_CN__c != undefined) {
        //             fieldValues.push('Township_CN__c=' + result.Township_CN__c);
        //         }
        //         if (result.Sales_Region__c != null && result.Sales_Region__c != undefined) {
        //             fieldValues.push('Sales_Region__c=' + result.Sales_Region__c);
        //         }
        //         fieldValues.push('Address__c=' + result.Address__c);
        //         if (result.Hisense_Entity_Sales__c != null && result.Hisense_Entity_Sales__c != undefined) {
        //             fieldValues.push('Hisense_Entity_Sales__c=' + result.Hisense_Entity_Sales__c);
        //         }
        //         if (result.Payment_Term_Sales__c != null && result.Payment_Term_Sales__c != undefined) {
        //             fieldValues.push('Payment_Term_Sales__c=' + result.Payment_Term_Sales__c);
        //         }
        //         if (result.Hisense_Entity__c != null && result.Hisense_Entity__c != undefined) {
        //             fieldValues.push('Hisense_Entity__c=' + result.Hisense_Entity__c);
        //         }
        //         if (result.Payment_Term__c != null && result.Payment_Term__c != undefined) {
        //             fieldValues.push('Payment_Term__c=' + result.Payment_Term__c);
        //         }
        //         // fieldValues.push('Shipping_Conditions__c=' + result.Shipping_Conditions__c);
        //         fieldValues.push('Reconciliation_Customer__c=' + result.Reconciliation_Customer__c);
        //         fieldValues.push('Buyer_English_Name__c=' + result.Buyer_English_Name__c);
        //         if (result.Customer_Group2__c != null && result.Customer_Group2__c != undefined) {
        //             fieldValues.push('Customer_Group2__c=' + result.Customer_Group2__c);
        //         }
        //         if (result.VAT_Tax_type__c != null && result.VAT_Tax_type__c != undefined) {
        //             fieldValues.push('VAT_Tax_type__c=' + result.VAT_Tax_type__c);
        //         }
        //         console.log('fieldValues: ', JSON.stringify(fieldValues));

        //         try {
        //             this[NavigationMixin.Navigate]({
        //                 type: 'standard__objectPage',
        //                 attributes: {
        //                     objectApiName: 'Account',
        //                     actionName: 'new'
        //                 },
        //                 state: {
        //                     defaultFieldValues : fieldValues.join(','),
        //                     nooverride: '1',
        //                     recordTypeId: recordTypeId,
        //                 }
        //             });
        //         } catch (error) {
        //             console.error('Error navigating to new record page:', JSON.stringify(error));
        //         }
        //     }).catch(error => {
        //         console.error('Error fetching parent account:', JSON.stringify(error));
        //     })
        // this[NavigationMixin.Navigate]({
        //     type: 'standard__recordPage',
        //     attributes: {
        //         objectApiName: 'Account',
        //         actionName: 'new'
        //     },
        //     state: {
        //         recordTypeId: recordTypeId,
        //         nooverride: '1',
        //         defaultFieldValues: fieldValues.join(','),
        //     }
        // });
    }


    handleParentCustomerOfSubAccChange(event){
        this.parentCustomerOfSubAcc = event.target.value;
        this.errorMessage = '';
        this.isValid = false;
        this.isShowSpinner = true;
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

    async handleNext(){
        this.errorMessage = '';
        this.isShowSpinner = true;

        // 前端校验，国家与注册码/员工编码是否合法
        await this.validateInputValues();
        console.log('this.isValid : ' + this.isValid);
        if (this.isValid) {
            this.isShowSpinner = false;
            return;
        }

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
        console.log('wwww--navigate to new record page : ' + JSON.stringify(this.recordTypeId));
        console.log('wwww--navigate to new record page : ' + JSON.stringify(fieldValues));
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

    // 输入校验
    async validateInputValues() {
        // 分户校验--------(wfc:2025-01-24)----------
        console.log('wwwwvalidate-----' + this.parentCustomerOfSubAcc)
        console.log('wwwwvalidate-----' + this.subAccountType)
        console.log('wwwwvalidate-----' + this.reasonsCustomerSegmentation)
        console.log('wwwwvalidate-----' + this.creditManagement)
        if (this.parentCustomerOfSubAcc === '' || this.subAccountType === '' || this.reasonsCustomerSegmentation === '' || this.creditManagement === '') {
            this.errorMessage = MDGSubCustomerCheckRequired;
            this.isValid = true;
            return;
        } else {
            this.isValid = false;
        }
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
            this.isShowSpinner = false;
        }).catch(error => {
            console.log('get Parent Customer error : ', JSON.stringify(error));
            this.isShowSpinner = false;
        });
    }
}