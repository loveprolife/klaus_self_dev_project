public class CustomerHistoryQueueable implements Queueable{

    public String accountId;
    
    public CustomerHistoryQueueable(String accountId) {
        this.accountId = accountId;
    }
    public void execute(QueueableContext context) {
        System.debug('wwwww----' + accountId);
        List<Customer_History__c> customerHistoryAddList = new List<Customer_History__c>();
        // 查询客户主信息
        List<Account> accountList = getAccountById(accountId);
        Account account = accountList[0];
        // 查询公司视图信息
        List<Customer_Extend__c> companyList = getCompanyByAccountId(accountId);
        // 查询销售视图信息
        List<Customer_Extend__c> salesList = getSalesByAccountId(accountId);
        // 查询销售视图的税信息
        List<Customer_Extend_Tax_category__c> taxList = getTaxByAccountId(accountId);
        // 查询银行信息
        List<Customer_Banks__c> banksList = getBanksByAccountId(accountId);
        // 保存在历史表中
        // 客户主数据
        Customer_History__c chAccount = new Customer_History__c();
        chAccount.Object_Name__c = 'Account';
        chAccount.Record_Id__c = account.Id;
        chAccount.Latest_Version__c = account.Latest_Version__c;
        chAccount.Record_Body__c = JSON.serialize(account, false);
        customerHistoryAddList.add(chAccount);
        // 公司视图
        if(companyList != null && companyList.size() > 0){
            for(Customer_Extend__c ce : companyList){
                Customer_History__c ch = new Customer_History__c();
                ch.Object_Name__c = 'Customer_Extend__c';
                ch.Record_Id__c = ce.Id;
                ch.Latest_Version__c = account.Latest_Version__c;
                ch.Record_Body__c = JSON.serialize(ce, false);
                customerHistoryAddList.add(ch);
            }
        }
        // 销售视图
        if(salesList != null && salesList.size() > 0){
            for(Customer_Extend__c ce : salesList){
                Customer_History__c ch = new Customer_History__c();
                ch.Object_Name__c = 'Customer_Extend__c';
                ch.Record_Id__c = ce.Id;
                ch.Latest_Version__c = account.Latest_Version__c;
                ch.Record_Body__c = JSON.serialize(ce, false);
                customerHistoryAddList.add(ch);
            }
        }
        // 税信息
        if(taxList != null && taxList.size() > 0){
            for(Customer_Extend_Tax_category__c tax : taxList){
                Customer_History__c ch = new Customer_History__c();
                ch.Object_Name__c = 'Customer_Extend_Tax_category__c';
                ch.Record_Id__c = tax.Id;
                ch.Latest_Version__c = account.Latest_Version__c;
                ch.Record_Body__c = JSON.serialize(tax, false);
                customerHistoryAddList.add(ch);
            }
        }
        // 银行信息
        if(banksList != null && banksList.size() > 0){
            for(Customer_Banks__c cb : banksList){
                Customer_History__c ch = new Customer_History__c();
                ch.Object_Name__c = 'Customer_Banks__c';
                ch.Record_Id__c = cb.Id;
                ch.Latest_Version__c = account.Latest_Version__c;
                ch.Record_Body__c = JSON.serialize(cb, false);
                customerHistoryAddList.add(ch);
            }
        }
        
        Database.insert(customerHistoryAddList);
    }

    // 获取客户信息
    public static List<Account> getAccountById(String accountId) {
        return  [SELECT Id,Latest_Version__c,MDG_Customer_Code__c,SAP_Customer_Code__c,Language__c,Approval_Status__c,Customer_Name_Local_Language__c, 
                    Customer_Name_Local_Language_2__c,Customer_Name_1__c,Customer_Name_2__c,ID_Type__c,Company_Registration_Number__c, 
                    VAT_Registration_Number__c,Client_Type__c,Overseas_customer_level__c,Channel_Customer_Categories__c,Channel_Customer_Subcategories__c, 
                    Supplier__c,credit_rating__c,Tax_Number1__c,Tax_Number2__c,Tax_Number3__c,Tax_Number4__c, 
                    Customer_Short_Name__c,Transportation_area__c,Search_Term2__c,Customer_Status__c,
                    Customer_Management_Name__c,E_commerce_Customer_Label__c,Global_Location_Number__c,
                    Guarantor_Country_Code__c,Postal_Code__c,Province_State__c,City_CN__c,District_CN__c,Township_CN__c,Street_2__c,Street_3__c,
                    Street_4__c,Street_5__c,Phone,City__c,District__c,Town__c,Email_Multiple__c,RecordTypeId,Current_Modifier__c,
                    Customer_Address_Type__c,Marketing_Model__c,Channel_Name__c
                FROM Account 
                WHERE Id =:accountId];
    }
    // 获取公司视图信息
    public static List<Customer_Extend__c> getCompanyByAccountId(String accountId) {
        return [SELECT Id,Hisense_Entity__c,Customer_EDI_ID_Type__c,Reconciliation_Customer__c,EDI_ID__c,
                    Payment_Method_MDG__c,EDI_ID2__c,Payment_Term__c,Packing_Type__c,Stor_Location__c,TV_lisense__c,
                    VAT_Tax_type__c,Valid_to__c,Add_VAT_Reg_No__c,Account_Remarks__c,Company_View_Freeze_markers__c
                FROM Customer_Extend__c 
                WHERE Customer__c =:accountId AND Show_Company__c = true];
    }
    // 获取销售视图信息
    public static List<Customer_Extend__c> getSalesByAccountId(String accountId) {
        return [SELECT Id,Hisense_Entity_Sales__c,Sales_Region__c,Deliverying_Plant__c,Distribution_Channel__c,
                    Sales_Office__c,Account_Assignment_Group__c,Sales_Group__c,Customer_pricing_process__c,Payment_Term_Sales__c,
                    Price_Group__c,Shipping_Conditions__c,CurrencyIsoCode,International_Trade_Terms__c,
                    KDGRP__c,International_Trade_Terms_2__c,Customer_Group_1__c,Receiver__c,Customer_Group2__c,
                    Payer__c,Customer_Group_3__c,Sale_View_Freezed_Reason__c,Customer_Group_4__c,Payback_Overdue_Number__c,
                    Customer_Group_5__c,Related_to_POD__c,Sales_View_Freeze_markers__c,Price_List__c
                FROM Customer_Extend__c 
                WHERE Customer__c =:accountId AND Show_Sales__c = true];
    }
    // 查询销售视图的税信息
    public static List<Customer_Extend_Tax_category__c> getTaxByAccountId(String accountId) {
        return  [SELECT Id, Tax_category__c, Customer_Extend__c
                FROM Customer_Extend_Tax_category__c
                WHERE Customer_Extend__r.Customer__c =:accountId];
    }
    // 查询银行信息
    public static List<Customer_Banks__c> getBanksByAccountId(String accountId) {
        return [SELECT Id,Name,Bank_Country__c,MDG_BANK__c,Bank_Code__c,Bank_name_local_language__c,Swift_Code__c,Bank_name_in_English__c,
                    Bank_Account__c,Bank_Control_Code__c,Bank_Account_Holder__c
                FROM Customer_Banks__c 
                WHERE Customer__c =:accountId];
    }

}