/**********************************************************************
* Name: SyncCustomerInfoToSAP
* Object: Credit_Limit_Application__c 
* Purpose: When customer get approved from salesforce,customer information  ZSF_CUSTOMERINFO_CREATE
* send to SAP automatically
* Author: Roy
* Create Date: 2019-03-10
*************************************************************************/
public without sharing class SyncCustomerInfoToSAP {

    private static String url = Interface_Url__c.getValues('SAP').Basic_Url__c + 'CC_REST_CUSTOMERINFO_CREATE_SEND';
    private static String user = Interface_Url__c.getValues('SAP').User_Name__c;
    private static String password = Interface_Url__c.getValues('SAP').Password__c;

    //private static String url = 'https://crmxip.hisense.com:8443/RESTAdapter/'+ 'CC_REST_CUSTOMERINFO_CREATE_SEND';
    //private static String user = 'xiaxiaoyang';
    //private static String password = 'hs123456';

    private static List<String> strList = new List<String>();

    /* Cutomer Information */
    public class CustomerInfo {
        public String SFCode;
        public String SAPCustomerCode;
        public String CustomerGroup;
        public String CustomerLocalLanguage1;
        public String CustomerLocalLanguage2;
        public String CustomerEnglishLanguage1;
        public String CustomerEnglishLanguage2;
        public String Payer;
        public String Receiver;
        public String ShortName;
        public String Area;
        public String Street2;
        public String Street3;
        public String Street4;
        public String Street5;
        public String BuildingCode;
        public String CountryCode;
        public String ProvinceState;
        public String City;
        public String PostalCode;
        public String TelephoneNumber;
        public String Fax;
        public String Email;// 新加Email wfc
        public String SupplierorCreditorAccount;
        public String CreatedTime;
        public String CreatedBy;
        public String TaxNumber1;
        public String TaxNumber2;
        public String VATRegistrationNumber;
        public String BankCountryCode;
        public String NationalBank;
        public String CountryAccountNumber;
        public String BankControlCode;
        public String AccountHolderName;
        public String SWIFTCode;
        public String BankName;
        public String ReconciliatioCustomer;
        public String PaymentCondition;
        public String DistributioChannel;
        public String ProductGroup;
        public String OrderPossibility;
        public String SalesOffice;
        public String SalesGroup;
        public String SFCurrency;
        public String PriceGroup;
        public String CustomerPricingProcess;
        public String PriceList;
        public String CustomerStatisticsGroup;
        public String ShippingConditions;
        public String RelatedtoPOD;
        public String InternationalTradeTerms1;
        public String InternationalTradeTerms2;
        public String PaymentCondition1;
        public String AccountAllocationGroup;
        public String SendingtoCountry;
        //public String TaxCategory;
        //public String TaxClassification;
        public String InventoryLocation;
        public String SearchItem1;
        public String SearchItem2;
        public String CustomerEDIIDType;
        public String TVlicense;
        public String Validto;
        public String PackingType;
        public String AddVATRegNo;
        public String CustomerGroup1;
        public String CustomerGroup2;
        public String CustomerGroup3;
        public String CustomerGroup4;
        public String CustomerGroup5;
        public String DeliveryPriority;
        public String DeliveryingPlant;
        public String LocationNo1;
        public String LocationNo2;
        public String CheckDigit;
        public String StorLocation;
        public String UserLanguage;
        public List < String > HisenseEntityList;
        public List < String > Company;
        public List < BillingCertificate > BillingCertificateList;
        public List < BANK > Banks = new List < BANK >();

        public String EBusOrNot;
        public String Customer_Classification;

        public String VATTaxType;

        public String Attribute2;//SAP--KATR2 SF--Attribute2__c
        public String Payment_Methods;//SAP--ZWELS SF--Payment_methods__c
        public String Customer_Group;//  ----  SAP--KDGRP   SF--KDGRP__c

        //智利显示、必填
        public String NAME4;
        public String CITY2;
        public String ZZSH;//沙特显示、必填

        //泰国、越南显示、必填  lzx 20241220
        public String Name3;
    }

    public class BANK {
        public String Banks;
        public String Bankl;
        public String Bankn;
        public String Bkref;
        public String Bkont;
        public String Swift;
        public String Banka;
        public String Koinh;
    }

    public class BillingCertificate {
        public String TaxCategory;
        public String TaxClassification;
        public String TaxCountry;
        //CountryCodeAndCustomerIdF__c
    }

    public class ResDeta {
        public String FailReason;
        public String IsSuccess;
        public String SAPCustomerCode;
        public String SFCodeFromSAP;
    }

    public static String postCustomerInfomationToSAP(String customerId) {
        //根据id判断是客户Account还是Customer Extend表
        Id cid= Id.valueOf(customerId);
        String objectName = cid.getSObjectType().getDescribe().getName();

        CustomerInfo customerInfo = new CustomerInfo();
        Customer_Extend__c customerExtend  = new Customer_Extend__c();
        Customer_Banks__c customerBank = new Customer_Banks__c();
        List<Customer_Banks__c> customerBankList = new List<Customer_Banks__c>();
        
        if(objectName == 'Customer_Extend__c'){
            customerExtend = [SELECT Id,Name,Customer__c,Shipping_Conditions__c,Related_to_POD__c,
                                                  Customer_Pricing_Process__c,Customer_Statistics_Group__c,Hisense_Entity__c,Reconciliation_Customer__c,Payment_Term__c,VAT_Tax_type__c,
                                                  (Select Id,Name,Tax_category_code__c,Tax_category__r.Name,CountryCodeAndCustomerIdF__c from Customer_Extend_Tax_category__r)
                                                  FROM Customer_Extend__c
                                                  WHERE Id =: customerId];
            customerId = customerExtend.Customer__c;
        }else if(objectName == 'Customer_Banks__c'){
            customerBank = [SELECT Id,Name,Customer__c,Bank_Account__c,Bank_Account_Holder__c,Bank_Code__c,Bank_Control_Code__c,Bank_Country__c,Bank_Name__c,
                                                  Swift_Code__c, Reference_Detail__c
                                                  FROM Customer_Banks__c
                                                  WHERE Id =: customerId];

            customerId = customerBank.Customer__c;
        }

        customerBankList = [SELECT Id,Name,Customer__c,Bank_Account__c,Bank_Account_Holder__c,Bank_Code__c,Bank_Control_Code__c,Bank_Country__c,Bank_Name__c,
                                                  Swift_Code__c, Reference_Detail__c
                                                  FROM Customer_Banks__c
                                                  WHERE Customer__c =: customerId and Approval_Status__c = 'Approved'];

        // Query customer data from salesforce.
        Account account = [SELECT Id,SAP_Customer_Code__c, Customer_SF_Code__c, Customer_Group__c, Customer_Group2__c, Name, Customer_Name_Local_Language__c, 
        Payer__c, Receiver__c, Customer_Short_Name__c, Address__c, Guarantor_Country_Code__c, Province_State__c, City__c, 
        Postal_Code__c, Phone, Fax, Email__c, Tax_Number1__c, Tax_Number2__c, VAT_Registration_Number__c, Reconciliation_Customer__c, 
        Payment_Condition__c, Sales_Office__c, Sales_Group__c,CurrencyIsoCode, Price_List__c, Shipping_Conditions__c, Attribute2__c,Payment_methods__c,KDGRP__c,
        Related_to_POD__c,Tax_Classification__c,Delivery_Priority__c, Deliverying_Plant__c, Location_No_1__c, Location_No_2__c, 
        Check_Digit__c, Stor_Location__c, Hisense_Entity__c,Payment_Term__c,E_commerce_Customer_Label__c,Customer_Classification__c,VAT_Tax_type__c,
        Activity__c, District__c, Company_Registration_Number__c,Branch__c,
        (Select Id,Name,Tax_category_code__c,Tax_category__r.Name,CountryCodeAndCustomerIdF__c from Customer_Tax_category__r)
        FROM Account Where Id = :customerId];

        //账期的ID和Code的Map
        Map<String,String> paymentTermId2CodeMap = new Map<String,String>();
        for(Payment_Term__c ptc : [Select id,name from Payment_Term__c where id =: account.Payment_Term__c]){
            paymentTermId2CodeMap.put(ptc.Id, ptc.Name);
        }

        //国家省市map
        Map<String,String> countryStateMap = new Map<String,String>();
        for(Country_State__c psc : [Select id,Name__c from Country_State__c where Belong_To__c =: account.Guarantor_Country_Code__c]){
            countryStateMap.put(psc.Id,psc.Name__c);
        }
        System.debug('countryStateMap... '+countryStateMap);

        Map<String,String> picklistId2CodeMap = new Map<String,String>();
        for(PickList__c plc : [select id,name,Value__c from PickList__c]){
            picklistId2CodeMap.put(plc.Id,plc.Value__c);
        }


        Map<String,String> payerAndReceiverId2SAPCodeMap = new Map<String,String>();
        List<String>  payerAndReceiverIdList = new List<String>();
        payerAndReceiverIdList.add(account.Payer__c);
        payerAndReceiverIdList.add(account.Receiver__c);
        System.debug('payerAndReceiverIdList... '+payerAndReceiverIdList);
        if(payerAndReceiverIdList != null){
            for(Account acVar : [select Id,SAP_Customer_Code__c from Account where Id in: payerAndReceiverIdList]){
                payerAndReceiverId2SAPCodeMap.put(acVar.Id, acVar.SAP_Customer_Code__c);
            }

            System.debug('payerAndReceiverId2SAPCodeMap... '+payerAndReceiverId2SAPCodeMap);

        }

        System.debug('payerAndRecei1verId2SAPCodeMap... '+payerAndReceiverId2SAPCodeMap);
        System.debug('account.Payer__c... '+account.Payer__c);
        System.debug('account.Receiver__c... '+account.Receiver__c);
        if (account != null) {
            customerInfo.SFCode = account.Customer_SF_Code__c == null ? '': account.Customer_SF_Code__c;
            // customerInfo.CustomerGroup = 'Z006';
            customerInfo.CustomerGroup = account.Customer_Group__c;
            if (account.Name!=null) {
                //如果客户名超过40，需要拆分成几组，以40个字符为一组再出传给SAP。
                //因为SAP一个字段最多存40个字符
                splitString(account.Name,40);
                for (Integer i=0;i<strList.size();i++) {
                    if (i==0) {
                        customerInfo.CustomerEnglishLanguage1 = strList[i]; 
                    }
                    if (i==1) {
                        customerInfo.CustomerEnglishLanguage2 = strList[i];
                    }
                }
            }

            if(customerInfo.CustomerEnglishLanguage2 == null){
                customerInfo.CustomerEnglishLanguage2 = '';
            }

            If(account.Customer_Name_Local_Language__c == null){
                customerInfo.CustomerLocalLanguage1 = '';
                customerInfo.CustomerLocalLanguage2 = '';
            }Else{
                If(account.Customer_Name_Local_Language__c.length() <= 40){
                    customerInfo.CustomerLocalLanguage1 = account.Customer_Name_Local_Language__c;
                    customerInfo.CustomerLocalLanguage2 = '';
                }Else{
                    customerInfo.CustomerLocalLanguage1 = account.Customer_Name_Local_Language__c.substring(0,40);
                    customerInfo.CustomerLocalLanguage2 = account.Customer_Name_Local_Language__c.substring(40,account.Customer_Name_Local_Language__c.length());
                }
            }
            //客户名称超过40，切分成几组，再传递给sap
            if (account.Address__c!=null) {
                strList = new List<String>();
                splitString(account.Address__c.replaceAll('\\R', ' '),40);
                for (Integer i=0;i<strList.size();i++) {
                    if (i==0) {
                        customerInfo.Street2 = strList[i]; 
                    }
                    if (i==1) {
                        customerInfo.Street3 = strList[i];
                    }
                    if (i==2) {
                        customerInfo.Street4 = strList[i];
                    }
                    if (i==3) {
                        customerInfo.Street5 = strList[i];
                    }
                } 
            }
            if(customerInfo.Street2 == null){
                customerInfo.Street2 = '';
            }
            if(customerInfo.Street3 == null){
                customerInfo.Street3 = '';
            }
            if(customerInfo.Street4 == null){
                customerInfo.Street4 = '';
            }
            if(customerInfo.Street5 == null){
                customerInfo.Street5 = '';
            }
            customerInfo.Payer = account.Payer__c == null ? '': payerAndReceiverId2SAPCodeMap.get(account.Payer__c);
            customerInfo.Receiver = account.Receiver__c == null ? '': payerAndReceiverId2SAPCodeMap.get(account.Receiver__c);
            customerInfo.ShortName = account.Customer_Short_Name__c == null ? '': account.Customer_Short_Name__c;
            customerInfo.Area = '';
            customerInfo.BuildingCode = '';
            customerInfo.CountryCode = account.Guarantor_Country_Code__c == null ? '': account.Guarantor_Country_Code__c;
            customerInfo.ProvinceState = account.Province_State__c == null ? '': countryStateMap.get(account.Province_State__c);
            customerInfo.City = account.City__c == null ? '': account.City__c;
            customerInfo.PostalCode = account.Postal_Code__c == null ? '': account.Postal_Code__c;
            customerInfo.TelephoneNumber = account.Phone == null ? '': account.Phone;
            customerInfo.Fax = account.Fax == null ? '': account.Fax;
            customerInfo.Email = account.Email__c == null ? '': account.Email__c;// 新加Email wfc
            customerInfo.SupplierorCreditorAccount = '';
            customerInfo.CreatedTime = '';
            customerInfo.CreatedBy = '';
            customerInfo.TaxNumber1 = account.Tax_Number1__c == null ? '': account.Tax_Number1__c;
            customerInfo.TaxNumber2 = account.Tax_Number2__c == null ? '': account.Tax_Number2__c;
            customerInfo.VATRegistrationNumber = account.VAT_Registration_Number__c == null ? '': account.VAT_Registration_Number__c;
            customerInfo.BankCountryCode = '';
            customerInfo.NationalBank = '';
            customerInfo.CountryAccountNumber = '';
            customerInfo.BankControlCode = '';
            customerInfo.AccountHolderName = '';
            customerInfo.SWIFTCode = '';
            customerInfo.BankName = '';
            customerInfo.ReconciliatioCustomer = account.Reconciliation_Customer__c == null ? '': account.Reconciliation_Customer__c;
            customerInfo.PaymentCondition = account.Payment_Term__c == null ? '': paymentTermId2CodeMap.get(account.Payment_Term__c);
            customerInfo.DistributioChannel = '11';
            customerInfo.ProductGroup = '00';
            customerInfo.OrderPossibility = '100';
            customerInfo.SalesOffice = account.Sales_Office__c == null ? '': picklistId2CodeMap.get(account.Sales_Office__c);
            customerInfo.SalesGroup = account.Sales_Group__c == null ? '': picklistId2CodeMap.get(account.Sales_Group__c);
            customerInfo.SFCurrency = account.CurrencyIsoCode == null ? '' : account.CurrencyIsoCode;
            customerInfo.PriceGroup = '';
            customerInfo.CustomerPricingProcess = 'X';
            customerInfo.PriceList = account.Price_List__c == null ? '': account.Price_List__c;
            customerInfo.CustomerStatisticsGroup = '1';
            customerInfo.ShippingConditions = account.Shipping_Conditions__c == null ? '': account.Shipping_Conditions__c;
            if(account.Related_to_POD__c == True){
                customerInfo.RelatedtoPOD = 'X' ;
            }else{
                customerInfo.RelatedtoPOD = '' ;
            }
            customerInfo.InternationalTradeTerms1 = '';
            customerInfo.InternationalTradeTerms2 = '';
            customerInfo.PaymentCondition1 = account.Payment_Term__c == null ? '': paymentTermId2CodeMap.get(account.Payment_Term__c);
            customerInfo.AccountAllocationGroup = '';
            customerInfo.SendingtoCountry = '';
            //customerInfo.TaxCategory = '';
            //customerInfo.TaxClassification = account.Tax_Classification__c == null ? '': account.Tax_Classification__c;
            customerInfo.InventoryLocation = '';
            customerInfo.SearchItem1 = '';
            customerInfo.SearchItem2 = '';
            customerInfo.CustomerEDIIDType = '';
            customerInfo.TVlicense = '';
            customerInfo.Validto = '';
            customerInfo.PackingType = '';
            customerInfo.AddVATRegNo = '';
            customerInfo.CustomerGroup1 = '';
            customerInfo.CustomerGroup2 = account.Customer_Group2__c == null ? '': account.Customer_Group2__c;
            customerInfo.CustomerGroup3 = '';
            customerInfo.CustomerGroup4 = '';
            customerInfo.CustomerGroup5 = '';
            customerInfo.UserLanguage = 'E';
            customerInfo.DeliveryPriority = account.Delivery_Priority__c == null ? '': account.Delivery_Priority__c;
            customerInfo.DeliveryingPlant = account.Deliverying_Plant__c == null ? '': account.Deliverying_Plant__c;
            customerInfo.LocationNo1 = account.Location_No_1__c == null ? '': account.Location_No_1__c + '';
            customerInfo.LocationNo2 = account.Location_No_2__c == null ? '': account.Location_No_2__c + '';
            customerInfo.CheckDigit = account.Check_Digit__c == null ? '': account.Check_Digit__c + '';
            customerInfo.StorLocation = account.Stor_Location__c == null ? '' : picklistId2CodeMap.get(account.Stor_Location__c);
            customerInfo.EBusOrNot = account.E_commerce_Customer_Label__c;
            customerInfo.Customer_Classification = account.Customer_Classification__c == null ? '': account.Customer_Classification__c;
            customerInfo.VATTaxType = account.VAT_Tax_type__c == null ? '': account.VAT_Tax_type__c;
            customerInfo.Attribute2 = account.Attribute2__c == null ? '': account.Attribute2__c;
            customerInfo.Payment_Methods = account.Payment_methods__c == null ? '': account.Payment_methods__c;
            customerInfo.Customer_Group = account.KDGRP__c == null ? '': account.KDGRP__c;

            customerInfo.NAME4 = account.Activity__c == null ? '': account.Activity__c;
            customerInfo.CITY2 = account.District__c == null ? '': account.District__c;
            customerInfo.ZZSH = account.Company_Registration_Number__c == null ? '': account.Company_Registration_Number__c;

            customerInfo.name3 = account.Branch__c == null ? '': account.Branch__c;

            List < String > tmpHisenseEntityList = new List < String > ();
            If(account.Hisense_Entity__c != null){
                tmpHisenseEntityList.add(account.Hisense_Entity__c);
                customerInfo.HisenseEntityList = tmpHisenseEntityList;
                customerInfo.Company = tmpHisenseEntityList;
            }Else{
                customerInfo.HisenseEntityList = tmpHisenseEntityList;
                customerInfo.Company = tmpHisenseEntityList;
            }

            //Approval Line Information
            //获取税分类信息
            customerInfo.BillingCertificateList = new List<BillingCertificate>();
             //map CustomerSFCode to CustomerId
             Map<String,String> CustomerSFCode2IdMap = new Map<String,String>();

            // 扩展客户传递参数
            if(objectName == 'Customer_Extend__c'){
                customerInfo.SAPCustomerCode = account.SAP_Customer_Code__c;
                customerInfo.SFCode = customerExtend.Name == null ? '': customerExtend.Name;
                customerInfo.ShippingConditions = customerExtend.Shipping_Conditions__c == null ? '': customerExtend.Shipping_Conditions__c;
                customerInfo.CustomerPricingProcess = customerExtend.Customer_Pricing_Process__c;
                customerInfo.CustomerStatisticsGroup = customerExtend.Customer_Statistics_Group__c;
                customerInfo.SalesOffice = '';
                customerInfo.SalesGroup = '';
                if(customerExtend.Related_to_POD__c == True){
                    customerInfo.RelatedtoPOD = 'X' ;
                }else{
                    customerInfo.RelatedtoPOD = '' ;
                }
                List < String > ceHisenseEntityList = new List < String > ();
                if(customerExtend.Hisense_Entity__c != null){
                    ceHisenseEntityList.add(customerExtend.Hisense_Entity__c);
                    customerInfo.HisenseEntityList = ceHisenseEntityList;
                    customerInfo.Company = ceHisenseEntityList;
                    if('8640'.equals(customerExtend.Hisense_Entity__c)){
                        customerInfo.VATTaxType = customerExtend.VAT_Tax_type__c;
                    }
                }else{
                    customerInfo.HisenseEntityList = ceHisenseEntityList;
                    customerInfo.Company = ceHisenseEntityList;
                }
                customerInfo.ReconciliatioCustomer = customerExtend.Reconciliation_Customer__c == null ? '': customerExtend.Reconciliation_Customer__c;
                //账期的ID和Code的Map
                Map<String,String> paymentTermMap = new Map<String,String>();
                for(Payment_Term__c ptc : [Select id,name from Payment_Term__c where id =: customerExtend.Payment_Term__c]){
                    paymentTermMap.put(ptc.Id, ptc.Name);
                }
                customerInfo.PaymentCondition = customerExtend.Payment_Term__c == null ? '': paymentTermMap.get(customerExtend.Payment_Term__c);
                customerInfo.PaymentCondition1 = customerExtend.Payment_Term__c == null ? '': paymentTermMap.get(customerExtend.Payment_Term__c);
                if (!customerExtend.Customer_Extend_Tax_category__r.isEmpty() & customerExtend.Customer_Extend_Tax_category__r != null) {
                    for (Customer_Extend_Tax_category__c billingCertificateVar : customerExtend.Customer_Extend_Tax_category__r) {
                        BillingCertificate billingCertificateTmp = new  BillingCertificate();
                        billingCertificateTmp.TaxCategory = billingCertificateVar.Tax_category_code__c;
                        billingCertificateTmp.TaxClassification = billingCertificateVar.Tax_category__r.Name;
                        billingCertificateTmp.TaxCountry = billingCertificateVar.CountryCodeAndCustomerIdF__c;
                        customerInfo.BillingCertificateList.add(billingCertificateTmp);  
                    }
                }
                CustomerSFCode2IdMap.put(customerExtend.Name, customerExtend.Id);
                

            }else {
                if (!account.Customer_Tax_category__r.isEmpty() & account.Customer_Tax_category__r != null) {
                    for (Customer_Tax_category__c billingCertificateVar : account.Customer_Tax_category__r) {
                        BillingCertificate billingCertificateTmp = new  BillingCertificate();
                        billingCertificateTmp.TaxCategory = billingCertificateVar.Tax_category_code__c;
                        billingCertificateTmp.TaxClassification = billingCertificateVar.Tax_category__r.Name;
                        billingCertificateTmp.TaxCountry = billingCertificateVar.CountryCodeAndCustomerIdF__c;
                        customerInfo.BillingCertificateList.add(billingCertificateTmp);  
                    }
                }
                CustomerSFCode2IdMap.put(account.Customer_SF_Code__c, account.Id);
            }

            if(objectName == 'Customer_Banks__c'){
                customerInfo.SAPCustomerCode = account.SAP_Customer_Code__c;
            }

            for (Customer_Banks__c cbc : customerBankList) {
                BANK bank = new  BANK();
                bank.Banks = cbc.Bank_Country__c;
                bank.Bankl = cbc.Bank_Code__c;
                if(cbc.Bank_Account__c.length() > 18){
                    bank.Bkref = cbc.Bank_Account__c.substring(18) + (String.isBlank(cbc.Reference_Detail__c) ? '' : cbc.Reference_Detail__c);
                    bank.Bankn = cbc.Bank_Account__c.substring(0,18);
                }else{
                    bank.Bankn = cbc.Bank_Account__c;
                    bank.Bkref = cbc.Reference_Detail__c;
                }
                bank.Bkont = cbc.Bank_Control_Code__c;
                bank.Swift = cbc.Swift_Code__c;
                bank.Banka = cbc.Bank_Name__c;
                bank.Koinh = cbc.Bank_Account_Holder__c;

                customerInfo.Banks.add(bank);
            }

            String body = JSON.serialize(customerInfo);
            System.debug('body:: ' + body); 

            ResDeta input = new ResDeta();
            String bodyRes;
            try {
                Blob headerValue = Blob.valueOf(user + ':' + password);
                String authorizationHeader = 'Basic ' + EncodingUtil.base64Encode(headerValue);
                HttpRequest request = new HttpRequest();
                HttpResponse response = new HttpResponse();
                Http http_login = new Http();
                request.setEndpoint(url);
                request.setMethod('POST');
                request.setHeader('Content-Type', 'application/json');
                request.setHeader('Authorization', authorizationHeader);
                request.setBody(body);
                request.setTimeout(120000); // timeout in milliseconds
                System.debug('request::: '+request);
                response = http_login.send(request);
                System.debug('response '+response);
                bodyRes = response.getBody();
                System.debug('bodyRes:' + bodyRes);
                SyncCustomerInfoToSAP.ResDeta input_login = new SyncCustomerInfoToSAP.ResDeta();
                input_login = (SyncCustomerInfoToSAP.ResDeta) JSON.deserialize(bodyRes, SyncCustomerInfoToSAP.ResDeta.class);
                System.debug('~~~~~~~~~~~~~~');
                System.debug('input_login '+input_login);

                //handle log
                if (input_login.IsSuccess == 'True') {
                    
                    //同步成功，更改记录类型，解锁部分字段
                    List<RecordType> recordTypeIdList = [Select id from recordtype where name = 'customer synced sap']; 
                    System.debug('recordTypeIdList[0].Id ..  '+recordTypeIdList[0].Id);
                    if(objectName == 'Customer_Extend__c'){
                         //update Customer_Extend__c SAPCode information
                        Customer_Extend__c ceTmp = new Customer_Extend__c();
                        ceTmp.Id = CustomerSFCode2IdMap.get(input_login.SFCodeFromSAP);
                        ceTmp.Extend_or_Not__c = Boolean.valueOf(input_login.IsSuccess);
                        //忽略触发器更新
                        GlobalSetting__c ignoreGs = Utility.IgnoreAction(true, true, true, 'CustomerExtendTriggerHandler');
                        Database.update(ceTmp);

                        //恢复触发器
                        Utility.IgnoreAction(false,false,false,'');
                    }else {
                        //update account SAPCode information
                        Account accountTmp = new Account();
                        accountTmp.SAP_Customer_Code__c = input_login.SAPCustomerCode;
                        accountTmp.Id = CustomerSFCode2IdMap.get(input_login.SFCodeFromSAP);
                        accountTmp.RecordTypeId = recordTypeIdList[0].Id;
                        //忽略触发器更新
                        GlobalSetting__c ignoreGs = Utility.IgnoreAction(true, true, true, 'AccountTriggerHandler');
                        Database.update(accountTmp);

                        //恢复触发器
                        Utility.IgnoreAction(false,false,false,'');
                    }
                    
                    
                    Utility.insertLog('SyncCustomerInfoToSAP', '1', body, bodyRes);
                    // return 'SUCCESS';
                } else {
                    //log
                    Utility.insertLog('SyncCustomerInfoToSAP', '0', body, input_login.FailReason);
                    return input_login.FailReason;
                }
            } catch(Exception e) {
                Utility.IgnoreAction(false,false,false,'');
                //Integration Log
                Utility.insertLog('SyncCustomerInfoToSAP', '0', body, 'failure: SF Sync Customer Information to SAP Failed! ' + e.getMessage() + '-------' + bodyRes);
                return 'failure: SF Sync Customer Information to SAP Failed! ' + e.getMessage();
            }
        }
    return 'SUCCESS';
}
//如果客户名称超过40，需要切分成几组再给sap传过去
private static void splitString(String str,Integer length){
    if (str.length() <= length) {
        strList.add(str);
        return;
    }else{
        //test sss
        String subStr = str.substring(0,length);
        String nextStr = str.substring(length,length+1);
        String endStr = subStr.substring(subStr.length()-1);
        if (nextStr.equals(' ')||endStr.equals(' ')||subStr.lastIndexOf(' ')==-1) {
            strList.add(subStr);
            splitString(str.substring(length),length);
        }else{
            Integer index = subStr.lastIndexOf(' ');
            subStr = subStr.substring(0,index+1);
            strList.add(subStr);
            splitString(str.substring(index+1),length);
        }
    }
}
}