/******************************************************************************
 ************************
 * Name: Batch_CustomerAddressUpload
 * Description:  批量上传地址类客户
 * TestClassName:  Batch_CustomerAddressUploadTest
 * Version History: 0.01
 * Author: lizunxing
 * Comments: 
 *******************************************************************************
 **************************/
public with sharing class Batch_CustomerAddressUpload implements Database.Batchable<Account>, Database.AllowsCallouts, Database.Stateful{
    
    public List<Account> accountList;
    public List<String> idList = new List<String>();

    public Batch_CustomerAddressUpload(List<Account> accountList){
        this.accountList = accountList;
    }
    
    /**
     * @Param: 
     * @Return: void
     * @Author: lizunxing
     * @Description: 进入Batch前执行方法
     */
    public Iterable<Account> start(Database.BatchableContext BC) {
        return accountList;
    }

    /**
     * @Param: 
     * @Return: void
     * @Author: lizunxing
     * @Description: 
     */
    public void execute(Database.BatchableContext BC, list<Account> accountList) {
        for(Account account : accountList){
            List<Account> checkName = [SELECT Id, Name FROM Account 
                WHERE Name = :account.Name 
                AND   RecordTypeId = '012TL000007T1ntYAC'
                AND   Guarantor_Country_Code__c = :account.Guarantor_Country_Code__c
                AND   Province_State__c = :account.Province_State__c
                AND   Street_2__c = :account.Street_2__c];
            if(checkName != null && checkName.size() > 0){
                continue;
            }

            List<Account> soldTo = [SELECT Id, Name FROM Account WHERE SAP_Customer_Code__c = :account.SAP_Customer_Code__c];

            account.SAP_Customer_Code__c = null;
            account.Sold_to__c = soldTo.get(0).Id;
            account.RecordTypeId = '012TL000007T1ntYAC';
            account.Client_Type__c = '';
            account.Approval_Status__c = 'Approved';

            insert account;

            idList.add(account.Id);

            Customer_Extend__c customerExtendCompany = new Customer_Extend__c();
            customerExtendCompany.Customer__c = account.Id;
            customerExtendCompany.Extend_or_Not__c = true;
            customerExtendCompany.Show_Company__c = true;
            customerExtendCompany.Show_Sales__c = false;
            customerExtendCompany.Approval_Status__c = 'Approved';
            customerExtendCompany.Create_View__c = '1';
            customerExtendCompany.ExternalID__c = account.Id + '-' + account.Hisense_Entity__c + '-' + '' + '-' + '';
            // 公司视图
            customerExtendCompany.Hisense_Entity__c = account.Hisense_Entity__c;
            //customerExtendCompany.E_commerce_Customer_Label__c = account.E_commerce_Customer_Label__c;
            //customerExtendCompany.Reconciliation_Customer__c = account.Reconciliation_Customer__c;
            //customerExtendCompany.Customer_EDI_ID_Type__c = account.Customer_EDI_ID_Type__c;
            //customerExtendCompany.Payment_Method_MDG__c = account.Payment_Method_MDG__c;
            customerExtendCompany.EDI_ID__c = account.EDI_ID__c;
            //customerExtendCompany.EDI_ID2__c = account.EDI_ID2__c;
            //customerExtendCompany.VAT_Tax_type__c = account.VAT_Tax_type__c;
            //customerExtendCompany.Add_VAT_Reg_No__c = account.Add_VAT_Reg_No__c;
            //customerExtendCompany.Packing_Type__c = account.Packing_Type__c;
            //customerExtendCompany.Account_Remarks__c = account.Account_Remarks__c;
            //customerExtendCompany.TV_lisense__c = account.TV_lisense__c;
            //customerExtendCompany.Company_View_Freeze_markers__c = account.Company_View_Freeze_markers__c;
            //customerExtendCompany.Valid_to__c = account.Valid_to__c;
            //customerExtendCompany.Payment_Term__c = account.Payment_Term__c;
            //customerExtendCompany.Stor_Location__c = account.Stor_Location__c;


            Customer_Extend__c customerExtendSales = new Customer_Extend__c();
            customerExtendSales.Customer__c = account.Id;
            customerExtendSales.Extend_or_Not__c = true;
            customerExtendSales.Show_Company__c = false;
            customerExtendSales.Show_Sales__c = true;
            customerExtendSales.Approval_Status__c = 'Approved';
            customerExtendSales.Create_View__c = '2';
            customerExtendSales.ExternalID__c = account.Id + '-' + '' + '-' + account.Hisense_Entity_Sales__c + '-' + account.Distribution_Channel__c;
            // 销售视图
            customerExtendSales.Hisense_Entity_Sales__c = account.Hisense_Entity_Sales__c;
            //customerExtendSales.Distribution_Channel__c = account.Distribution_Channel__c;
            //customerExtendSales.Deliverying_Plant__c = account.Deliverying_Plant__c;
            //customerExtendSales.Account_Assignment_Group__c = account.Account_Assignment_Group__c;
            //customerExtendSales.Sales_Region__c = account.Sales_Region__c;
            //customerExtendSales.Customer_pricing_process__c = account.Customer_pricing_process__c;
            //customerExtendSales.Sales_Office__c = account.Sales_Office__c;
            //customerExtendSales.Payment_Term_Sales__c = account.Payment_Term_Sales__c;
            //customerExtendSales.Sales_Group__c = account.Sales_Group__c;
            //customerExtendSales.Price_Group__c = account.Price_Group__c;
            customerExtendSales.CurrencyIsoCode = account.CurrencyIsoCode;
            customerExtendSales.Shipping_Conditions__c = account.Shipping_Conditions__c;
            //customerExtendSales.KDGRP__c = account.KDGRP__c;
            //customerExtendSales.International_Trade_Terms__c = account.International_Trade_Terms__c;
            //customerExtendSales.International_Trade_Terms_2__c = account.International_Trade_Terms_2__c;
            //customerExtendSales.Customer_Group2__c = account.Customer_Group2__c;
            //customerExtendSales.Price_List__c = account.Price_List__c;
            //customerExtendSales.Payer__c = account.Payer__c;
            //customerExtendSales.Receiver__c = account.Receiver__c;
            //customerExtendSales.Payback_Overdue_Number__c = account.Payback_Overdue_Number__c;
            //customerExtendSales.Related_to_POD__c = account.Related_to_POD__c;
            //customerExtendSales.Sales_View_Freeze_markers__c = account.Sales_View_Freeze_markers__c;
            //customerExtendSales.Customer_Group_1__c = account.Customer_Group_1__c;
            //customerExtendSales.Customer_Group_3__c = account.Customer_Group_3__c;
            //customerExtendSales.Customer_Group_4__c = account.Customer_Group_4__c;
            //customerExtendSales.Customer_Group_5__c = account.Customer_Group_5__c;

            Database.upsert(customerExtendCompany, Customer_Extend__c.Fields.ExternalID__c, true);
            Database.upsert(customerExtendSales, Customer_Extend__c.Fields.ExternalID__c, true);

            // if(!Test.isRunningTest()){
            //     SyncCustomerInfoToMDGPro.postCustomerInfomationToMDG(account.Id);
            // }
        }
    }

    /**
     * @Param: 
     * @Return: void
     * @Author: lizunxing
     * @Description: 执行完Batch后进入，记录日志
     */
    public void finish(Database.BatchableContext BC) {
        Utility.insertLog('Batch_CustomerAddressUpload', '1', '', '');

        Batch_SyncCustomerToMDG ss = new Batch_SyncCustomerToMDG(idList,'SyncCustomerToMDG');
        Database.executeBatch(ss, 1);
    }

}