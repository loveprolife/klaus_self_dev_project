/*
 * @Author: WFC
 * @Date: 2025-06-11 16:13:10
 * @LastEditors: WFC
 * @LastEditTime: 2025-06-23 09:28:06
 * @Description: 地址类客户转换成客户
 CustomerAddressToAccountBatch ss  = new CustomerAddressToAccountBatch();
 Database.executeBatch(ss);
 * @FilePath: \HiTest20250422\force-app\main\default\classes\CustomerAddressToAccountBatch.cls
 */
public class CustomerAddressToAccountBatch implements Database.Batchable<sObject>{
    public String query;
    public List<String> entityList = Label.CustomerAddressToAccountEntity.split(',');
    List<String> sapCodeList;
    public CustomerAddressToAccountBatch(){
        this.query = 'SELECT Id, Customer__c, SAP_Customer_Code__c, MDG_Code__c, Global_Location_Number__c, Name, Customer_Name_Local_Language_1__c, VAT_Registration_Number__c, ' + 
                 ' Customer_Name_Local_Language_2__c, Customer_Name_EN_Language_1__c, Customer_Name_EN_Language_2__c, Tax_Number1__c,Tax_Number2__c, Tax_Number3__c, Tax_Number4__c, ' + 
                 ' Customer_Short_Name__c, Search_Term2__c, Transportation_area__c, CurrencyIsoCode, ' + 
                 ' Country__c,Province_State__c,City__c,District__c,City_CN__c, District_CN__c, Township_CN__c, ' + 
                 ' Postal_Code__c,Phone__c,Fax__c, Street_2__c,Street_3__c,Street_4__c,Street_5__c,(SELECT Email__c FROM Customer_Emails__r order by No__c), ' + 
                 ' Hisense_Entity__c,Reconciliation_Customer__c,Stor_Location__c,Payment_Method_MDG__c,VAT_Tax_type__c,Add_VAT_Reg_No__c,Customer_EDI_ID_Type__c, ' + 
                 ' EDI_ID__c,EDI_ID2__c,Packing_Type__c,TV_lisense__c,Valid_to__c, ' + 
                 ' Hisense_Entity_Sales__c,Sales_Office__c,Sales_Group__c,International_Trade_Terms__c,International_Trade_Terms_2__c,Distribution_Channel__c, ' + 
                 ' Shipping_Conditions__c,Related_to_POD__c, ' + 
                 ' (SELECT Id,Customer__c,National_tax_category__c,Tax_category_code__c,Tax_category__c FROM Customer_Address_Tax_category__r) ' + 
                 ' FROM Customer_Address__c WHERE (Hisense_Entity__c IN :entityList OR Hisense_Entity_Sales__c IN :entityList) AND SAP_Customer_Code__c != null ';
    }

    public CustomerAddressToAccountBatch(String type){
        if(type.equals('NoEntity')){
            this.query = 'SELECT Id, Customer__c, SAP_Customer_Code__c, MDG_Code__c, Global_Location_Number__c, Name, Customer_Name_Local_Language_1__c, VAT_Registration_Number__c, ' + 
                 ' Customer_Name_Local_Language_2__c, Customer_Name_EN_Language_1__c, Customer_Name_EN_Language_2__c, Tax_Number1__c,Tax_Number2__c, Tax_Number3__c, Tax_Number4__c, ' + 
                 ' Customer_Short_Name__c, Search_Term2__c, Transportation_area__c, CurrencyIsoCode, ' + 
                 ' Country__c,Province_State__c,City__c,District__c,City_CN__c, District_CN__c, Township_CN__c, ' + 
                 ' Postal_Code__c,Phone__c,Fax__c, Street_2__c,Street_3__c,Street_4__c,Street_5__c,(SELECT Email__c FROM Customer_Emails__r order by No__c), ' + 
                 ' Hisense_Entity__c,Reconciliation_Customer__c,Stor_Location__c,Payment_Method_MDG__c,VAT_Tax_type__c,Add_VAT_Reg_No__c,Customer_EDI_ID_Type__c, ' + 
                 ' EDI_ID__c,EDI_ID2__c,Packing_Type__c,TV_lisense__c,Valid_to__c, ' + 
                 ' Hisense_Entity_Sales__c,Sales_Office__c,Sales_Group__c,International_Trade_Terms__c,International_Trade_Terms_2__c,Distribution_Channel__c, ' + 
                 ' Shipping_Conditions__c,Related_to_POD__c, ' + 
                 ' (SELECT Id,Customer__c,National_tax_category__c,Tax_category_code__c,Tax_category__c FROM Customer_Address_Tax_category__r) ' + 
                 ' FROM Customer_Address__c WHERE Hisense_Entity__c = null and Hisense_Entity_Sales__c = null AND SAP_Customer_Code__c != null ';
        }else if(type.equals('ALL')){
            this.query = 'SELECT Id, Customer__c, SAP_Customer_Code__c, MDG_Code__c, Global_Location_Number__c, Name, Customer_Name_Local_Language_1__c, VAT_Registration_Number__c, ' + 
                 ' Customer_Name_Local_Language_2__c, Customer_Name_EN_Language_1__c, Customer_Name_EN_Language_2__c, Tax_Number1__c,Tax_Number2__c, Tax_Number3__c, Tax_Number4__c, ' + 
                 ' Customer_Short_Name__c, Search_Term2__c, Transportation_area__c, CurrencyIsoCode, ' + 
                 ' Country__c,Province_State__c,City__c,District__c,City_CN__c, District_CN__c, Township_CN__c, ' + 
                 ' Postal_Code__c,Phone__c,Fax__c, Street_2__c,Street_3__c,Street_4__c,Street_5__c,(SELECT Email__c FROM Customer_Emails__r order by No__c), ' + 
                 ' Hisense_Entity__c,Reconciliation_Customer__c,Stor_Location__c,Payment_Method_MDG__c,VAT_Tax_type__c,Add_VAT_Reg_No__c,Customer_EDI_ID_Type__c, ' + 
                 ' EDI_ID__c,EDI_ID2__c,Packing_Type__c,TV_lisense__c,Valid_to__c, ' + 
                 ' Hisense_Entity_Sales__c,Sales_Office__c,Sales_Group__c,International_Trade_Terms__c,International_Trade_Terms_2__c,Distribution_Channel__c, ' + 
                 ' Shipping_Conditions__c,Related_to_POD__c, ' + 
                 ' (SELECT Id,Customer__c,National_tax_category__c,Tax_category_code__c,Tax_category__c FROM Customer_Address_Tax_category__r) ' + 
                 ' FROM Customer_Address__c ';
        }
    }

    public CustomerAddressToAccountBatch(List<String> sapCodeList){
        this.sapCodeList = sapCodeList;
        this.query = 'SELECT Id, Customer__c, SAP_Customer_Code__c, MDG_Code__c, Global_Location_Number__c, Name, Customer_Name_Local_Language_1__c, VAT_Registration_Number__c, ' + 
                 ' Customer_Name_Local_Language_2__c, Customer_Name_EN_Language_1__c, Customer_Name_EN_Language_2__c, Tax_Number1__c,Tax_Number2__c, Tax_Number3__c, Tax_Number4__c, ' + 
                 ' Customer_Short_Name__c, Search_Term2__c, Transportation_area__c, CurrencyIsoCode, ' + 
                 ' Country__c,Province_State__c,City__c,District__c,City_CN__c, District_CN__c, Township_CN__c, ' + 
                 ' Postal_Code__c,Phone__c,Fax__c, Street_2__c,Street_3__c,Street_4__c,Street_5__c,(SELECT Email__c FROM Customer_Emails__r order by No__c), ' + 
                 ' Hisense_Entity__c,Reconciliation_Customer__c,Stor_Location__c,Payment_Method_MDG__c,VAT_Tax_type__c,Add_VAT_Reg_No__c,Customer_EDI_ID_Type__c, ' + 
                 ' EDI_ID__c,EDI_ID2__c,Packing_Type__c,TV_lisense__c,Valid_to__c, ' + 
                 ' Hisense_Entity_Sales__c,Sales_Office__c,Sales_Group__c,International_Trade_Terms__c,International_Trade_Terms_2__c,Distribution_Channel__c, ' + 
                 ' Shipping_Conditions__c,Related_to_POD__c, ' + 
                 ' (SELECT Id,Customer__c,National_tax_category__c,Tax_category_code__c,Tax_category__c FROM Customer_Address_Tax_category__r) ' + 
                 ' FROM Customer_Address__c WHERE SAP_Customer_Code__c in:sapCodeList ';
    }

    public Database.QueryLocator start(Database.BatchableContext bc){
        return Database.getQueryLocator(query);
    }

    public void execute(Database.BatchableContext BC, list<Customer_Address__c> customerAddressList){

        // 客户中的地址类客户 Record Type Id
        String customerAddressTypeId = Schema.SobjectType.Account.getRecordTypeInfosByDeveloperName().get('Customer_Address').getRecordTypeId();
        List<Account> accountAddList = new List<Account>();
        Map<String, Account> accountMap = new Map<String, Account>();
        List<Customer_Extend__c> customerExtendAddList = new List<Customer_Extend__c>();
        Map<String, Customer_Extend__c> customerExtendSalesMap = new Map<String, Customer_Extend__c>();
        List<Customer_Extend_Tax_category__c> extendTaxList = new List<Customer_Extend_Tax_category__c>();
        MDG_Client_Mapping__mdt client = MDG_Client_Mapping__mdt.getInstance('CustomerAddress');
        for (Customer_Address__c customerAddress : customerAddressList){

            List<Account> accountList = [select id,(select id,Hisense_Entity__c,Hisense_Entity_Sales__c from Customer_Extends__r) from Account where SAP_Customer_Code__c =: customerAddress.SAP_Customer_Code__c];
            Boolean accountFlg = true;
            Boolean companyFlg = true;
            Boolean salesFlg = true;
            if(accountList != null && accountList.size() > 0){ 
                accountFlg = false;
                if(accountList.get(0).Customer_Extends__r != null && accountList.get(0).Customer_Extends__r.size() > 0 ){
                    for(Customer_Extend__c ce : accountList.get(0).Customer_Extends__r){
                        if(ce.Hisense_Entity__c != null){
                            companyFlg = false;
                        }
                        if(ce.Hisense_Entity_Sales__c != null){
                            salesFlg = false;
                        }
                    }
                }
            }
            
            // 生成一个临时key值
            Blob b = Crypto.GenerateAESKey(128);
            String key = EncodingUtil.ConvertTohex(b);
            // 主数据
            Account acc = new Account();
            acc.External_Key__c = customerAddress.SAP_Customer_Code__c;

            if(accountFlg){
                acc.RecordTypeId = customerAddressTypeId;
                acc.Approval_Status__c = 'Approved';
                acc.Ecss_Flag__c = true;
                acc.Trader_Type__c = client != null ? client.MDG_Code__c : '';
                acc.CustomerDetailType__c = client != null ? client.MDG_Sub_Code__c : '';
                acc.Sold_to__c = customerAddress.Customer__c;
                acc.SAP_Customer_Code__c = customerAddress.SAP_Customer_Code__c;
                acc.MDG_Customer_Code__c = customerAddress.MDG_Code__c;
                acc.Global_Location_Number__c = customerAddress.Global_Location_Number__c;
                acc.Customer_Name_Local_Language__c = customerAddress.Customer_Name_Local_Language_1__c;
                acc.Name = customerAddress.Name;
                acc.VAT_Registration_Number__c = customerAddress.VAT_Registration_Number__c;
                acc.Customer_Name_Local_Language_2__c = customerAddress.Customer_Name_Local_Language_2__c;
                acc.Customer_Name_1__c = customerAddress.Customer_Name_EN_Language_1__c;
                acc.Customer_Name_2__c = customerAddress.Customer_Name_EN_Language_2__c;
                acc.Tax_Number1__c = customerAddress.Tax_Number1__c;
                acc.Tax_Number2__c = customerAddress.Tax_Number2__c;
                acc.Tax_Number3__c = customerAddress.Tax_Number3__c;
                acc.Tax_Number4__c = customerAddress.Tax_Number4__c;
                acc.Customer_Short_Name__c = customerAddress.Customer_Short_Name__c;
                acc.Search_Term2__c = customerAddress.Search_Term2__c;
                acc.Transportation_area__c = customerAddress.Transportation_area__c;
                acc.CurrencyIsoCode = customerAddress.CurrencyIsoCode;
                acc.Guarantor_Country_Code__c = customerAddress.Country__c;
                acc.Province_State__c = customerAddress.Province_State__c;
                acc.City__c = customerAddress.City__c;
                acc.District__c = customerAddress.District__c;
                acc.City_CN__c = customerAddress.City_CN__c;
                acc.District_CN__c = customerAddress.District_CN__c;
                acc.Township_CN__c = customerAddress.Township_CN__c;
                acc.Postal_Code__c = customerAddress.Postal_Code__c;
                acc.Phone = customerAddress.Phone__c;
                acc.Fax = customerAddress.Fax__c;
                acc.Street_2__c = customerAddress.Street_2__c;
                acc.Street_3__c = customerAddress.Street_3__c;
                acc.Street_4__c = customerAddress.Street_4__c;
                acc.Street_5__c = customerAddress.Street_5__c;
                if (!customerAddress.Customer_Emails__r.isEmpty() & customerAddress.Customer_Emails__r != null){
                    String emailString = '';
                    for (Customer_Email__c customerEmails : customerAddress.Customer_Emails__r){
                        emailString += customerEmails.Email__c + ';';
                    }
                    acc.Email_Multiple__c = emailString.substring(0, emailString.length() - 1);
                }
            }
            
            accountAddList.add(acc);
            accountMap.put(key, acc);

            // 公司视图
            if (customerAddress.Hisense_Entity__c != null){
                if(companyFlg){
                    Customer_Extend__c customerExtendCompany = new Customer_Extend__c();
                    customerExtendCompany.ExternalID__c = key;
                    customerExtendCompany.Customer__c = acc.Id;
                    customerExtendCompany.Extend_or_Not__c = true;
                    customerExtendCompany.Show_Company__c = true;
                    customerExtendCompany.Show_Sales__c = false;
                    customerExtendCompany.Approval_Status__c = 'Approved';
                    customerExtendCompany.Create_View__c = '1';
                    customerExtendCompany.Hisense_Entity__c = customerAddress.Hisense_Entity__c;
                    customerExtendCompany.Reconciliation_Customer__c = customerAddress.Reconciliation_Customer__c;
                    customerExtendCompany.Stor_Location__c = customerAddress.Stor_Location__c;
                    customerExtendCompany.Payment_Method_MDG__c = customerAddress.Payment_Method_MDG__c;
                    customerExtendCompany.VAT_Tax_type__c = customerAddress.VAT_Tax_type__c;
                    customerExtendCompany.Add_VAT_Reg_No__c = customerAddress.Add_VAT_Reg_No__c;
                    customerExtendCompany.Customer_EDI_ID_Type__c = customerAddress.Customer_EDI_ID_Type__c;
                    customerExtendCompany.EDI_ID__c = customerAddress.EDI_ID__c;
                    customerExtendCompany.EDI_ID2__c = customerAddress.EDI_ID2__c;
                    customerExtendCompany.Packing_Type__c = customerAddress.Packing_Type__c;
                    customerExtendCompany.TV_lisense__c = customerAddress.TV_lisense__c;
                    customerExtendCompany.Valid_to__c = customerAddress.Valid_to__c;
                    customerExtendAddList.add(customerExtendCompany);
                }
            }
            // 销售视图
            if (customerAddress.Hisense_Entity_Sales__c != null){
                if(salesFlg){
                    Customer_Extend__c customerExtendSales = new Customer_Extend__c();
                    customerExtendSales.ExternalID__c = key;
                    customerExtendSales.Customer__c = acc.Id;
                    customerExtendSales.Extend_or_Not__c = true;
                    customerExtendSales.Show_Company__c = false;
                    customerExtendSales.Show_Sales__c = true;
                    customerExtendSales.Approval_Status__c = 'Approved';
                    customerExtendSales.Create_View__c = '2';
                    customerExtendSales.Hisense_Entity_Sales__c = customerAddress.Hisense_Entity_Sales__c;
                    customerExtendSales.Sales_Office__c = customerAddress.Sales_Office__c;
                    customerExtendSales.Sales_Group__c = customerAddress.Sales_Group__c;
                    customerExtendSales.International_Trade_Terms__c = customerAddress.International_Trade_Terms__c;
                    customerExtendSales.International_Trade_Terms_2__c = customerAddress.International_Trade_Terms_2__c;
                    customerExtendSales.Distribution_Channel__c = customerAddress.Distribution_Channel__c;
                    customerExtendSales.Shipping_Conditions__c = customerAddress.Shipping_Conditions__c;
                    customerExtendSales.Related_to_POD__c = customerAddress.Related_to_POD__c;
                    customerExtendAddList.add(customerExtendSales);
                    customerExtendSalesMap.put(key, customerExtendSales);
                    // 税信息
                    if (!customerAddress.Customer_Address_Tax_category__r.isEmpty() & customerAddress.Customer_Address_Tax_category__r != null){
                        for (Customer_Address_Tax_category__c tax : customerAddress.Customer_Address_Tax_category__r){
                            Customer_Extend_Tax_category__c extendTax = new Customer_Extend_Tax_category__c();
                            extendTax.Customer_Extend__c = customerExtendSales.Id;
                            extendTax.National_tax_category__c = tax.National_tax_category__c;
                            extendTax.Tax_category_code__c = tax.Tax_category_code__c;
                            extendTax.Tax_category__c = tax.Tax_category__c;
                            extendTax.Customer_Tax_Category_External_Id__c = key;

                            extendTaxList.add(extendTax);
                        }
                    }
                }
            }
        }

        Utility.IgnoreAction(true, true, true, 'CustomerAddressToAccountBatch');

        // 保存客户主数据
        Database.upsert (accountAddList, Account.Fields.External_Key__c, true);

        if(customerExtendAddList.size() == 0){
            return;
        }
        // 处理公司视图和销售视图
        for (Customer_Extend__c customerExtend : customerExtendAddList){
            // 获取客户
            Account acc = accountMap.get(customerExtend.ExternalID__c);
            customerExtend.Customer__c = acc.Id;
            // 区分公司视图还是销售视图
            if (customerExtend.Show_Company__c){
                customerExtend.ExternalID__c = acc.Id + '-' + customerExtend.Hisense_Entity__c + '-' + '' + '-' + '';
            }
            if (customerExtend.Show_Sales__c){
                customerExtend.ExternalID__c = acc.Id + '-' + '' + '-' + customerExtend.Hisense_Entity_Sales__c + '-' + customerExtend.Distribution_Channel__c;
            }
        }
        Database.upsert (customerExtendAddList, Customer_Extend__c.Fields.ExternalID__c, false);
        // 处理销售视图税信息
        for (Customer_Extend_Tax_category__c tax : extendTaxList){
            // 获取销售视图
            Customer_Extend__c salesViewExtend = customerExtendSalesMap.get(tax.Customer_Tax_Category_External_Id__c);
            tax.Customer_Extend__c = salesViewExtend.Id;
            tax.Customer_Tax_Category_External_Id__c = salesViewExtend.Id + '' + tax.Tax_category_code__c;
        }
        Database.upsert (extendTaxList, Customer_Extend_Tax_category__c.Fields.Customer_Tax_Category_External_Id__c, false);

        Utility.IgnoreAction(false, false, false, '');
    }

    public void finish(Database.BatchableContext BC){
        Utility.IgnoreAction(false, false, false, '');
    }

}