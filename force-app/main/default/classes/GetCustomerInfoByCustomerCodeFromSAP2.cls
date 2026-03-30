/*
 * @Author: WFC
 * @Date: 2025-08-15 09:21:32
 * @LastEditors: WFC
 * @LastEditTime: 2025-08-25 14:21:50
 * @Description: 根据客户sap编码获取sap客户数据接口改造
 GetCustomerInfoByCustomerCodeFromSAP2.getCustomerInfo('0022062724','20250813','20250813');
 * @FilePath: \testuat\force-app\main\default\classes\GetCustomerInfoByCustomerCodeFromSAP2.cls
 */
public with sharing class GetCustomerInfoByCustomerCodeFromSAP2{
    private static String url = Interface_Url__c.getValues('SAP').Basic_Url__c + 'CC_REST_CUSTOMERINFO_GET_SEND';
    private static String user = Interface_Url__c.getValues('SAP').User_Name__c;
    private static String password = Interface_Url__c.getValues('SAP').Password__c;
    public class Output{
        String SyncStartDate;
        String SyncEndDate;
        String CustomerCode;
    }

    public class Input{
        public List<CustomerInfo> CustomerList;
        public String isSuccess;
        public String failReason;
    }

    public class CustomerInfo{
        public String SFCode;
        public String SAPID;
        public String SAPCustomerCode; // SAP_Customer_Code__c
        public String SAPCustomerCode2;
        public String CustomerGroup; // Customer_Group__c
        public String CustomerLocalLanguage1; // Customer_Name_Local_Language__c
        public String CustomerLocalLanguage2; // Customer_Name_Local_Language_2__c
        public String CustomerEnglishLanguage1; // Customer_Name_1__c
        public String CustomerEnglishLanguage2; // Customer_Name_2__c
        public String ShortName; // Customer_Short_Name__c
        public String Street2; // Street_2__c Address__c = STREET2 + STREET3 + STREET4 + STREET5
        public String Street3; // Street_3__c Address__c = STREET2 + STREET3 + STREET4 + STREET5
        public String Street4; // Street_4__c Address__c = STREET2 + STREET3 + STREET4 + STREET5
        public String Street5; // Street_5__c Address__c = STREET2 + STREET3 + STREET4 + STREET5
        public String CountryCode; // Guarantor_Country_Code__c
        public String ProvinceState; // Province_State__c
        public String City; // City__c
        public String PostalCode; // Postal_Code__c
        public String TelephoneNumber; // Phone
        public String Fax; // Fax
        public String TaxNumber1; // Tax_Number1__c
        public String TaxNumber2; // Tax_Number2__c
        public String VATRegistrationNumber; // VAT_Registration_Number__c
        public String KUKLA; // todo（未使用）
        public String LIFNR; // Supplier__c 供应商
        public String KATR6; // todo（未使用）
        public String KATR3; // Customer_Price_Level__c
        public String KATR2; // Attribute2__c
        public String KDGRP; // KDGRP__c
        public String NAME4; // todo（未使用）
        public String ZZSH; // Add_VAT_Reg_No__c
        public String PARTNER; // MDG_Customer_Code__c
        public String BU_GROUP; // Trader_Type__c 用来查询客户类型的 MDG_Client_Mapping__mdt
        public String ZZMXLX; // CustomerDetailType__c 用来查询客户类型的 MDG_Client_Mapping__mdt
        public String ZZFONM; // FormerName__c
        public String ZZZJLX; // ID_Type__c
        public String ZZRENO; // Company_Registration_Number__c
        public String BU_LANGU; // Language__c
        public String SMTP_ADDR; // Email_Multiple__c
        public String ZZCVCO; // Sold_to__r.MDG_Customer_Code__c
        public String ZZCHCUSCA; // Channel_Customer_Categories__c
        public String ZZCHCUSSU; // Channel_Customer_Subcategories__c
        public String ZZCRERAT; // credit_rating__c
        public String ZZHWKHFJ; // Overseas_customer_level__c
        public String LZONE; // Transportation_area__c
        public String ZSORT2; // Search_Term2__c
        public String ZTAX_CODE3; //Tax_Number3__c
        public String ZTAX_CODE4; //Tax_Number4__c
        public String ZZFHLX; // Sub_account_type__c
        public String ZZFHYY; // Reasons_for_customer_segmentation__c
        public String LocationNo1; // Location_No_1__c
        public String LocationNo2; // Location_No_2__c
        public String CheckDigit; // Check_Digit__c
        public String BBBNR; // Global_Location_Number__c（0-7）
        public String BBSNR; // Global_Location_Number__c（7-12）
        public String BUBKZ; // Global_Location_Number__c（12-13）
        public String ZZLINE; // E_commerce_Customer_Label__c
        public String ORT01; // City_CN__c/City__c
        public String ORT02; // District_CN__c/District__c
        public String ZZTOWN; // Township_CN__c/Town__c
        public String CUTSOMER_TYPE; // Client_Type__c
        public String EBusOrNot; // E_commerce_Customer_Label__c
        public String Name3; // Branch__c
        public List<Company> CompanyList;
        public List<Sales> SALES;
    }

    public class Company{
        public String BUKRS; // Hisense_Entity__c
        public String RECONCILIATIOCUSTOMER; // Reconciliation_Customer__c
        public String PAYMENTCONDITION; // Payment_Term__c
        public String STORLOCATION; // Stor_Location__c
        public String ZWELS; // Payment_Method_MDG__c
        public String KVERM; // Account_Remarks__c
        public String NODEL; // Company_View_Freeze_markers__c
        public String ZZSORT1; // EDI_ID__c
        public String ZZSORT2; // EDI_ID2__c
        public String EDI_TYPE; // Customer_EDI_ID_Type__c
        public String ZTV; // TV_lisense__c
        public String ZVALID_TO; // Valid_to__c
        public String PACKAGING_TYPE; // Packing_Type__c
        public String ZKHFL; // VAT_Tax_type__c
    }

    public class Sales{
        public String VKORG; // Hisense_Entity_Sales__c
        public String DISTRIBUTIOCHANNEL; // Distribution_Channel__c
        public String PRODUCTGROUP; // Product_Group__c
        public String ORDERPOSSIBILITY; // todo Order probab
        public String SALESOFFICE; // Sales_Office__c
        public String SALESGROUP; // Sales_Group__c
        public String SFCURRENCY; // CurrencyIsoCode
        public String CUSTOMERPRICINGPROCESS;  // Customer_pricing_process__c
        public String PRICELIST; // Price_List__c
        public String CUSTOMERSTATISTICSGROUP; // Customer_Statistics_Group__c
        public String SHIPPINGCONDITIONS; // Shipping_Conditions__c
        public String RELATEDTOPOD; // Related_to_POD__c
        public String PAYMENTCONDITION1; // Payment_Term_Sales__c
        public String DELIVERYPRIORITY; // Delivery_Priority__c
        public String DELIVERYINGPLANT; // Deliverying_Plant__c
        public String CUSTOMERGROUP2; // Customer_Group2__c
        public String KDGRP; // KDGRP__c
        public String AUFSD; // Sales_View_Freeze_markers__c
        public String KONDA; // Price_Group__c
        public String INCO1; // International_Trade_Terms__c
        public String INCO2; // International_Trade_Terms_2__c
        public String ZKVGR1; // Customer_Group_1__c
        public String ZKVGR3; // Customer_Group_3__c
        public String ZKVGR4; // Customer_Group_4__c
        public String ZKVGR5; // Customer_Group_5__c
        public String KTGRD; // Account_Assignment_Group__c
        public String PAYER; // Payer__c
        public String RECEIVER; // Receiver__c
        public String EIKTO; // Our_account_at_the_customer_s_place__c
        public List<Tax> TAX;
    }

    public class Tax{
        public String TAXCOUNTRY;
        public String TAXCATEGORY;
        public String TAXCLASSIFICATION;
    }

    public static void getCustomerInfo(String CustomerCode, String syncStartDate, String syncEndDate){
        Output out = new Output();
        out.CustomerCode = CustomerCode;
        out.SyncStartDate = syncStartDate;
        out.SyncEndDate = syncEndDate;
        String body = JSON.serialize(out);
        // String body = '{"CustomerCode": "0005000454","SyncStartDate": "2019-04-01","SyncEndDate": "2019-04-10"}';
        GetCustomerInfoByCustomerCodeFromSAP2.Input input = new GetCustomerInfoByCustomerCodeFromSAP2.Input();
        String bodyRes;
        try{
            Blob headerValue = Blob.valueOf(user + ':' + password);
            String authorizationHeader = 'Basic ' + EncodingUtil.base64Encode(headerValue);
            //登陆获取token
            HttpRequest request = new HttpRequest();
            HttpResponse response = new HttpResponse();
            Http http_login = new Http();
            request.setEndpoint(url);
            request.setMethod('POST');
            request.setHeader('Content-Type', 'application/json');
            request.setHeader('Authorization', authorizationHeader);
            request.setBody(body);
            request.setTimeout(120000); // timeout in milliseconds
            if(Test.isRunningTest()){
                bodyRes = '{"IsSuccess":"","FailReason":"True","CustomerList":[{"SFCode":"","SAPID":"","CustomerLocalLanguage2":"xx","CustomerEnglishLanguage2":"11","ShortName":"11","Street3":"11","Street4":"11","Street5":"11","ORT02":"11","ZZTOWN":"11","PostalCode":"11","TelephoneNumber":"11","Fax":"11","TaxNumber1":"11","TaxNumber2":"11","VATRegistrationNumber":"11","LIFNR":"11","KATR3":"","KATR2":"","KDGRP":"","ZZSH":"11","ZZFONM":"11","ZZRENO":"11","SMTP_ADDR":"11","ZZCVCO":"11","ZZCHCUSCA":"10","ZZCHCUSSU":"103","ZZCRERAT":"11","ZZHWKHFJ":"11","LZONE":"11","ZSORT2":"11","ZTAX_CODE3":"11","ZTAX_CODE4":"11","ZZFHLX":"","ZZFHYY":"11","SAPCustomerCode":"0000203914","SAPCustomerCode2":"","CustomerGroup":"Z003","CustomerLocalLanguage1":"USD客户reclassification","CustomerEnglishLanguage1":"USD客户reclassification","Street2":"USD客户reclassification","CountryCode":"IN","ProvinceState":"01","City":"USD客户reclassification","PARTNER":"0000203914","BU_GROUP":"Z003","BU_LANGU":"ZH","LocationNo1":"0000000","LocationNo2":"00000","CheckDigit":0,"BBBNR":"0000000","BBSNR":"00000","BUBKZ":0,"ZZLINE":10,"ORT01":"USD客户reclassification","CUTSOMER_TYPE":"","EBusOrNot":10,"Name3":"","CompanyList":[{"BUKRS":8440,"RECONCILIATIOCUSTOMER":1122010501,"PAYMENTCONDITION":"","STORLOCATION":"","ZWELS":"","KVERM":"","NODEL":"","ZZSORT1":"","ZZSORT2":"","EDI_TYPE":"","ZTV":"","ZVALID_TO":"00000000","PACKAGING_TYPE":""},{"BUKRS":8520,"RECONCILIATIOCUSTOMER":1122010201,"PAYMENTCONDITION":"","STORLOCATION":"","ZWELS":"","KVERM":"","NODEL":"","ZZSORT1":"","ZZSORT2":"","EDI_TYPE":"","ZTV":"","ZVALID_TO":"00000000","PACKAGING_TYPE":""}],"SALES":[{"VKORG":8440,"DISTRIBUTIOCHANNEL":11,"PRODUCTGROUP":"00","ORDERPOSSIBILITY":100,"SALESOFFICE":"","SALESGROUP":"","SFCURRENCY":"INR","CUSTOMERPRICINGPROCESS":"X","PRICELIST":"","CUSTOMERSTATISTICSGROUP":1,"SHIPPINGCONDITIONS":"02","RELATEDTOPOD":"X","PAYMENTCONDITION1":"OA60","DELIVERYPRIORITY":"","DELIVERYINGPLANT":"","CUSTOMERGROUP2":"","KDGRP":"","AUFSD":"","KONDA":"","INCO1":"","INCO2":"","ZKVGR1":"","ZKVGR3":"","ZKVGR4":"","ZKVGR5":"","KTGRD":"","PAYER":"0000203914","RECEIVER":"0000203914","TAX":[{"TAXCOUNTRY":"IN","TAXCATEGORY":"ZTCS","TAXCLASSIFICATION":0},{"TAXCOUNTRY":"IN","TAXCATEGORY":"ZWST","TAXCLASSIFICATION":0}]}]}]}';
            }else{
                response = http_login.send(request);
                bodyRes = response.getBody();
            }
            input = (GetCustomerInfoByCustomerCodeFromSAP2.Input)JSON.deserialize(bodyRes, GetCustomerInfoByCustomerCodeFromSAP2.Input.class);
            if ('No data'.equals(input.IsSuccess)){
                SFUtility.writeCallLogs('true', 'GetCustomerInfoByCustomerCodeFromSAP2', body, bodyRes, 'Outbound', 'No data');
                return;
            }

            // 解析数据
            List<GetCustomerInfoByCustomerCodeFromSAP2.CustomerInfo> customerInfoList = input.CustomerList;
            if (!customerInfoList.isEmpty()){
                // 获取客户的recordType Map集合
                Map<String, MDG_Client_Mapping__mdt> clientMappingMap = new Map<String, MDG_Client_Mapping__mdt>();
                Map<String, MDG_Client_Mapping__mdt> SFDCMap = new Map<String, MDG_Client_Mapping__mdt>();
                for (MDG_Client_Mapping__mdt mapping : [SELECT Id, MasterLabel, DeveloperName, MDG_SFDC_Name__c, MDG_Description__c, MDG_Code__c, MDG_Sub_Code__c
                                                        FROM MDG_Client_Mapping__mdt
                                                        WHERE IsDelete__c = false AND MDG_Code__c != NULL AND MDG_Sub_Code__c != NULL]){
                    clientMappingMap.put(mapping.MDG_Code__c + mapping.MDG_Sub_Code__c, mapping);
                    SFDCMap.put(mapping.MDG_SFDC_Name__c, mapping);
                }
                // 接口返回的客户数据
                GetCustomerInfoByCustomerCodeFromSAP2.CustomerInfo customerInfo = customerInfoList[0];
                // 查询客户数据是否存在SF系统中
                Account account = new Account();
                if (String.isNotEmpty(customerInfo.SAPCustomerCode)){
                    List<Account> accList = [SELECT Id, RecordTypeId
                                             FROM Account
                                             WHERE SAP_Customer_Code__c = :customerInfo.SAPCustomerCode];
                    if (!accList.isEmpty()){
                        account = accList[0];
                    }
                }
                // 1.根据 Trader_Type__c 和 CustomerDetailType__c 获取客户的 recordType
                // if (String.isNotEmpty(customerInfo.BU_GROUP) && Trader_Type__c.getValues(customerInfo.BU_GROUP) != null){
                //     // 根据客商类型Trader_Type__c，填充ID_Type__c
                //     account.ID_Type__c = Trader_Type__c.getValues(customerInfo.BU_GROUP).ID_Type__c;
                //     customerInfo.BU_GROUP = Trader_Type__c.getValues(customerInfo.BU_GROUP).Trader_Type__c;

                //     if(String.isBlank(customerInfo.ZZMXLX)){
                //         customerInfo.ZZMXLX = Trader_Type__c.getValues(customerInfo.BU_GROUP).CustomerDetailType__c;
                //     }
                // }

                // if (clientMappingMap.get(customerInfo.BU_GROUP + customerInfo.ZZMXLX) != null){
                //     String recordTypeName = clientMappingMap.get(customerInfo.BU_GROUP + customerInfo.ZZMXLX).MDG_SFDC_Name__c;
                //     account.RecordTypeId = Schema.SobjectType.Account.getRecordTypeInfosByDeveloperName().get(recordTypeName).getRecordTypeId();
                //     account.Trader_Type__c = SFDCMap.get(recordTypeName).MDG_Code__c;
                //     account.CustomerDetailType__c = SFDCMap.get(recordTypeName).MDG_Sub_Code__c;
                // } else{
                //     account.RecordTypeId = Schema.SobjectType.Account.getRecordTypeInfosByDeveloperName().get('customer').getRecordTypeId();
                //     account.Trader_Type__c = SFDCMap.get('customer').MDG_Code__c;
                //     account.CustomerDetailType__c = SFDCMap.get('customer').MDG_Sub_Code__c;
                // }
                

                // 2.客户主数据信息
                account.Approval_Status__c = 'Approved';
                if(String.isNotEmpty(customerInfo.SAPCustomerCode)){
                    account.SAP_Customer_Code__c = customerInfo.SAPCustomerCode;
                }
                if(String.isNotEmpty(customerInfo.SAPCustomerCode)){
                    account.External_Key__c = customerInfo.SAPCustomerCode;
                }
                if(String.isNotEmpty(customerInfo.CustomerGroup)){
                    account.Customer_Group__c = customerInfo.CustomerGroup;
                }
                if(String.isNotEmpty(customerInfo.CustomerLocalLanguage1)){
                    account.Name = customerInfo.CustomerLocalLanguage1;
                }
                if(String.isNotEmpty(customerInfo.CustomerLocalLanguage1)){
                    account.Customer_Name_Local_Language__c = customerInfo.CustomerLocalLanguage1;
                }
                if(String.isNotEmpty(customerInfo.CustomerLocalLanguage2)){
                    account.Customer_Name_Local_Language_2__c = customerInfo.CustomerLocalLanguage2;
                }
                if(String.isNotEmpty(customerInfo.CustomerEnglishLanguage1)){
                    account.Customer_Name_1__c = customerInfo.CustomerEnglishLanguage1;
                }
                if(String.isNotEmpty(customerInfo.CustomerEnglishLanguage2)){
                    account.Customer_Name_2__c = customerInfo.CustomerEnglishLanguage2;
                }
                if(String.isNotEmpty(customerInfo.ShortName)){
                    account.Customer_Short_Name__c = customerInfo.ShortName;
                }
                if(String.isNotEmpty(customerInfo.Street2)){
                    account.Street_2__c = customerInfo.Street2;
                }
                if(String.isNotEmpty(customerInfo.Street3)){
                    account.Street_3__c = customerInfo.Street3;
                }
                if(String.isNotEmpty(customerInfo.Street4)){
                    account.Street_4__c = customerInfo.Street4;
                }
                if(String.isNotEmpty(customerInfo.Street5)){
                    account.Street_5__c = customerInfo.Street5;
                }
                if(String.isNotEmpty(customerInfo.CountryCode)){
                    account.Guarantor_Country_Code__c = customerInfo.CountryCode;
                }
                // 地址信息
                // Province/State
                if (String.isNotEmpty(customerInfo.CountryCode) && String.isNotEmpty(customerInfo.ProvinceState)){
                    List<Country_State__c> provinceList = [SELECT Id
                                                           FROM Country_State__c
                                                           WHERE Belong_To__c = :customerInfo.CountryCode AND Name__c = :customerInfo.ProvinceState];
                    if (!provinceList.isEmpty()){
                        account.Province_State__c = provinceList[0].Id;
                    }
                }
                // 中国地址
                if (String.isNotEmpty(customerInfo.CountryCode) && 'CN' == customerInfo.CountryCode){
                    if (account.Province_State__c != null && String.isNotEmpty(customerInfo.ORT01)){
                        List<Country_State__c> cityList = [SELECT Id
                                                           FROM Country_State__c
                                                           WHERE BelongTo_CNProvince__c = :account.Province_State__c AND Name__c = :customerInfo.ORT01];
                        if (!cityList.isEmpty()){
                            account.City_CN__c = cityList[0].Id;
                            if (String.isNotEmpty(customerInfo.ORT02)){
                                List<Country_State__c> districtList = [SELECT Id
                                                                       FROM Country_State__c
                                                                       WHERE BelongTo_CNCity__c = :account.City__c AND Name__c = :customerInfo.ORT02];
                                if (!districtList.isEmpty()){
                                    account.District_CN__c = districtList[0].Id;
                                    if (String.isNotEmpty(customerInfo.ZZTOWN)){
                                        List<Country_State__c> townshipList = [SELECT Id
                                                                               FROM Country_State__c
                                                                               WHERE BelongTo_CNDistrict__c = :account.District__c AND Name__c = :customerInfo.ZZTOWN];
                                        if (!townshipList.isEmpty()){
                                            account.Township_CN__c = townshipList[0].Id;
                                        }
                                    }
                                }
                            }
                        }
                    }
                } else{
                    // 其他国家地址
                    if(String.isNotEmpty(customerInfo.ORT01)){
                        account.City__c = customerInfo.ORT01;
                    }
                    if(String.isNotEmpty(customerInfo.ORT02)){
                        account.District__c = customerInfo.ORT02;
                    }
                    if(String.isNotEmpty(customerInfo.ZZTOWN)){
                        account.Town__c = customerInfo.ZZTOWN;
                    }
                }
                if(String.isNotEmpty(customerInfo.PostalCode)){
                    account.Postal_Code__c = customerInfo.PostalCode;
                }
                if(String.isNotEmpty(customerInfo.TelephoneNumber)){
                    account.Phone = customerInfo.TelephoneNumber;
                }
                if(String.isNotEmpty(customerInfo.Fax)){
                    account.Fax = customerInfo.Fax;
                }
                if(String.isNotEmpty(customerInfo.TaxNumber1)){
                    account.Tax_Number1__c = customerInfo.TaxNumber1;
                }
                if(String.isNotEmpty(customerInfo.TaxNumber2)){
                    account.Tax_Number2__c = customerInfo.TaxNumber2;
                }
                if(String.isNotEmpty(customerInfo.VATRegistrationNumber)){
                    account.VAT_Registration_Number__c = customerInfo.VATRegistrationNumber;
                }
                if(String.isNotEmpty(customerInfo.LIFNR)){
                    account.Supplier__c = customerInfo.LIFNR;
                }
                if(String.isNotEmpty(customerInfo.KATR3)){
                    account.Customer_Price_Level__c = customerInfo.KATR3;
                }

                if(String.isNotEmpty(customerInfo.KATR2)){
                    account.Attribute2__c = customerInfo.KATR2;
                }
                if(String.isNotEmpty(customerInfo.KDGRP)){
                    account.KDGRP__c = customerInfo.KDGRP;
                }
                if(String.isNotEmpty(customerInfo.ZZSH)){
                    account.Add_VAT_Reg_No__c = customerInfo.ZZSH;
                }
                if(String.isNotEmpty(customerInfo.PARTNER)){
                    account.MDG_Customer_Code__c = customerInfo.PARTNER;
                }

                if(String.isNotEmpty(customerInfo.ZZFONM)){
                    account.FormerName__c = customerInfo.ZZFONM;
                }
                if(String.isNotEmpty(customerInfo.ZZRENO)){
                    account.Company_Registration_Number__c = customerInfo.ZZRENO;
                }
                if(String.isNotEmpty(customerInfo.BU_LANGU)){
                    account.Language__c = customerInfo.BU_LANGU;
                }
                if(String.isNotEmpty(customerInfo.SMTP_ADDR)){
                    account.Email_Multiple__c = customerInfo.SMTP_ADDR;
                }
                // 根据 Sold_to__r.MDG_Customer_Code__c 获取数据
                if (String.isNotBlank(customerInfo.ZZCVCO)){
                    List<Account> soldToList = [SELECT Id
                                                FROM Account
                                                WHERE MDG_Customer_Code__c = :customerInfo.ZZCVCO];
                    if (!soldToList.isEmpty()){
                        account.Sold_to__c = soldToList[0].Id;
                    }
                }
                if(String.isNotEmpty(customerInfo.ZZCHCUSCA)){
                    account.Channel_Customer_Categories__c = customerInfo.ZZCHCUSCA;
                }
                if(String.isNotEmpty(customerInfo.ZZCHCUSSU)){
                    account.Channel_Customer_Subcategories__c = customerInfo.ZZCHCUSSU;
                }
                if(String.isNotEmpty(customerInfo.ZZCRERAT)){
                    account.credit_rating__c = customerInfo.ZZCRERAT;
                }
                if(String.isNotEmpty(customerInfo.ZZHWKHFJ)){
                    account.Overseas_customer_level__c = customerInfo.ZZHWKHFJ;
                }
                if(String.isNotEmpty(customerInfo.LZONE)){
                    account.Transportation_area__c = customerInfo.LZONE;
                }
                if(String.isNotEmpty(customerInfo.ZSORT2)){
                    account.Search_Term2__c = customerInfo.ZSORT2;
                }
                if(String.isNotEmpty(customerInfo.ZTAX_CODE3)){
                    account.Tax_Number3__c = customerInfo.ZTAX_CODE3;
                }
                if(String.isNotEmpty(customerInfo.ZTAX_CODE4)){
                    account.Tax_Number4__c = customerInfo.ZTAX_CODE4;
                }
                if(String.isNotEmpty(customerInfo.ZZFHLX)){
                    account.Sub_account_type__c = customerInfo.ZZFHLX;
                }
                if(String.isNotEmpty(customerInfo.ZZFHYY)){
                    account.Reasons_for_customer_segmentation__c = customerInfo.ZZFHYY;
                }
                if(String.isNotEmpty(customerInfo.LocationNo1)){
                    account.Location_No_1__c = customerInfo.LocationNo1;
                }
                if(String.isNotEmpty(customerInfo.LocationNo2)){
                    account.Location_No_2__c = customerInfo.LocationNo2;
                }
                if(String.isNotEmpty(customerInfo.CheckDigit)){
                    account.Check_Digit__c = Decimal.valueOf(customerInfo.CheckDigit);
                }
                if(String.isNotEmpty(customerInfo.BBSNR) && String.isNotEmpty(customerInfo.BBBNR) && String.isNotEmpty(customerInfo.BUBKZ)){
                    account.Global_Location_Number__c = customerInfo.BBBNR + customerInfo.BBSNR + customerInfo.BUBKZ;
                }
                if(String.isNotEmpty(customerInfo.CUTSOMER_TYPE)){
                    account.Client_Type__c = customerInfo.CUTSOMER_TYPE;
                }
                if(String.isNotEmpty(customerInfo.EBusOrNot)){
                    account.E_commerce_Customer_Label__c = customerInfo.EBusOrNot;
                }
                if(String.isNotEmpty(customerInfo.Name3)){
                    account.Branch__c = customerInfo.Name3;
                }

                //忽略触发器更新
                GlobalSetting__c ignoreGs = Utility.IgnoreAction(true, true, true, 'GetCustomerInfoByCustomerCodeFromSAP2');
                upsert account;
                Utility.IgnoreAction(false, false, false, '');

                // 公司视图集合
                List<Customer_Extend__c> companyExtendList = new List<Customer_Extend__c>();
                // 销售视图集合
                List<Customer_Extend__c> salesExtendList = new List<Customer_Extend__c>();
                // 税信息TAXCLASSIFICATION和销售视图map
                Map<String, String> taxMap = new Map<String, String>();
                // Tax_category__c外键key集合
                Set<String> taxKeySet = new Set<String>();
                //获取税分类组织mapping
                Map<String, TaxCountryMapping__c> countries = TaxCountryMapping__c.getAll();
                // 3.公司视图信息
                if (customerInfo.CompanyList != null && !customerInfo.CompanyList.isEmpty()){

                    for (GetCustomerInfoByCustomerCodeFromSAP2.Company company : customerInfo.CompanyList){
                        Customer_Extend__c ce = new Customer_Extend__c();
                        ce.Customer__c = account.Id;
                        ce.Extend_or_Not__c = true;
                        ce.Show_Company__c = true;
                        ce.Show_Sales__c = false;
                        ce.Create_View__c = '1';
                        // Hisense_Entity__c 不能为空
                        if (String.isNotEmpty(company.BUKRS) && String.isNotBlank(Utility.getPicklistValueMap('Customer_Extend__c', 'Hisense_Entity__c').get(company.BUKRS))){
                            ce.Hisense_Entity__c = company.BUKRS;
                            if(String.isNotEmpty(company.RECONCILIATIOCUSTOMER)){
                                ce.Reconciliation_Customer__c = company.RECONCILIATIOCUSTOMER;
                            }
                            if (String.isNotEmpty(company.PAYMENTCONDITION)){
                                List<Payment_Term__c> paymentList = [SELECT Id
                                                                     FROM Payment_Term__c
                                                                     WHERE Name = :company.PAYMENTCONDITION];
                                if (!paymentList.isEmpty()){
                                    ce.Payment_Term__c = paymentList[0].Id;
                                }
                            }
                            if (String.isNotEmpty(company.STORLOCATION)){
                                List<PickList__c> plList = [SELECT Id
                                                            FROM PickList__c
                                                            WHERE RecordType.DeveloperName = 'Master_Location' AND Freeze__c = false AND belong_to_Loc__c = :ce.Hisense_Entity__c AND Value__c = :company.STORLOCATION];
                                if (!plList.isEmpty()){
                                    ce.Stor_Location__c = plList[0].Id;
                                }
                            }
                            if(String.isNotEmpty(company.KVERM)){
                                ce.Account_Remarks__c = company.KVERM;
                            }
                            if(String.isNotEmpty(company.NODEL)){
                                ce.Company_View_Freeze_markers__c = true;
                            } else {
                                ce.Company_View_Freeze_markers__c = false;
                            }
                            if(String.isNotEmpty(company.ZZSORT1)){
                                ce.EDI_ID__c = company.ZZSORT1;
                            }
                            if(String.isNotEmpty(company.ZZSORT2)){
                                ce.EDI_ID2__c = company.ZZSORT2;
                            }
                            if(String.isNotEmpty(company.EDI_TYPE)){
                                ce.Customer_EDI_ID_Type__c = company.EDI_TYPE;
                            }
                            if(String.isNotEmpty(company.ZTV)){
                                ce.TV_lisense__c = company.ZTV;
                            }
                            if(String.isNotEmpty(company.ZVALID_TO) && !'00000000'.equals(company.ZVALID_TO)){
                                ce.Valid_to__c = Date.newInstance(
                                    Integer.valueOf(company.ZVALID_TO.substring(0, 4)),
                                    Integer.valueOf(company.ZVALID_TO.substring(4, 6)),
                                    Integer.valueOf(company.ZVALID_TO.substring(6, 8))
                                );
                            }
                            if(String.isNotEmpty(company.PACKAGING_TYPE)){
                                ce.Packing_Type__c = company.PACKAGING_TYPE;
                            }
                            if(String.isNotEmpty(company.ZKHFL)){
                                ce.VAT_Tax_type__c = company.ZKHFL;
                            }
                            ce.ExternalID__c = account.Id + '-' + ce.Hisense_Entity__c + '--';
                            companyExtendList.add(ce);
                        }

                    }
                }
                // 4.销售视图信息
                if (customerInfo.SALES != null && !customerInfo.SALES.isEmpty()){
                    for (GetCustomerInfoByCustomerCodeFromSAP2.Sales sales : customerInfo.SALES){
                        Customer_Extend__c ce = new Customer_Extend__c();
                        ce.Customer__c = account.Id;
                        ce.Extend_or_Not__c = true;
                        ce.Show_Company__c = false;
                        ce.Show_Sales__c = true;
                        ce.Create_View__c = '2';
                        // Hisense_Entity_Sales__c 不能为空
                        if (String.isNotEmpty(sales.VKORG) && String.isNotBlank(Utility.getPicklistValueMap('Customer_Extend__c', 'Hisense_Entity__c').get(sales.VKORG))){
                            ce.Hisense_Entity_Sales__c = sales.VKORG;
                            if(String.isNotEmpty(sales.DISTRIBUTIOCHANNEL)){
                                ce.Distribution_Channel__c = sales.DISTRIBUTIOCHANNEL;
                            }
                            if (String.isNotEmpty(sales.SALESOFFICE)){
                                List<PickList__c> plList = [SELECT Id
                                                            FROM PickList__c
                                                            WHERE RecordType.DeveloperName = 'Master_Data_Office' AND Freeze__c = false AND belong_to_he__c = :ce.Hisense_Entity_Sales__c AND Value__c = :sales.SALESOFFICE];
                                if (!plList.isEmpty()){
                                    ce.Sales_Office__c = plList[0].Id;
                                }
                            }
                            if (String.isNotEmpty(sales.SALESGROUP)){
                                List<PickList__c> plList = [SELECT Id
                                                            FROM PickList__c
                                                            WHERE RecordType.DeveloperName = 'Master_Data_Team' AND Value__c = :sales.SALESGROUP];
                                if (!plList.isEmpty()){
                                    ce.Sales_Group__c = plList[0].Id;
                                }
                            }
                            if(String.isNotEmpty(sales.SFCURRENCY)){
                                ce.CurrencyIsoCode = sales.SFCURRENCY;
                            }
                            if(String.isNotEmpty(sales.CUSTOMERPRICINGPROCESS)){
                                ce.Customer_pricing_process__c = sales.CUSTOMERPRICINGPROCESS;
                            }
                            if(String.isNotEmpty(sales.PRICELIST)){
                                ce.Price_List__c = sales.PRICELIST;
                            }
                            if(String.isNotEmpty(sales.CUSTOMERSTATISTICSGROUP)){
                                ce.Customer_Statistics_Group__c = sales.CUSTOMERSTATISTICSGROUP;
                            }
                            if(String.isNotEmpty(sales.SHIPPINGCONDITIONS)){
                                ce.Shipping_Conditions__c = sales.SHIPPINGCONDITIONS;
                            }
                            if(String.isNotEmpty(sales.RELATEDTOPOD)){
                                ce.Related_to_POD__c = true;
                            } else {
                                ce.Related_to_POD__c = false;
                            }
                            if (String.isNotEmpty(sales.PAYMENTCONDITION1)){
                                List<Payment_Term__c> paymentList = [SELECT Id
                                                                     FROM Payment_Term__c
                                                                     WHERE Name = :sales.PAYMENTCONDITION1];
                                if (!paymentList.isEmpty()){
                                    ce.Payment_Term_Sales__c = paymentList[0].Id;
                                }
                            }
                            if(String.isNotEmpty(sales.DELIVERYINGPLANT)){
                                ce.Deliverying_Plant__c = sales.DELIVERYINGPLANT;
                            }
                            if(String.isNotEmpty(sales.CUSTOMERGROUP2)){
                                ce.Customer_Group2__c = sales.CUSTOMERGROUP2;
                            }
                            if(String.isNotEmpty(sales.KDGRP)){
                                ce.KDGRP__c = sales.KDGRP;
                            }
                            if(String.isNotEmpty(sales.AUFSD)){
                                ce.Sales_View_Freeze_markers__c = true;
                            }else{
                                ce.Sales_View_Freeze_markers__c = false;
                            }
                            if(String.isNotEmpty(sales.KONDA)){
                                ce.Price_Group__c = sales.KONDA;
                            }
                            if(String.isNotEmpty(sales.INCO1)){
                                ce.International_Trade_Terms__c = sales.INCO1;
                            }
                            if(String.isNotEmpty(sales.INCO2)){
                                ce.International_Trade_Terms_2__c = sales.INCO2;
                            }
                            if(String.isNotEmpty(sales.ZKVGR1)){
                                ce.Customer_Group_1__c = sales.ZKVGR1;
                            }
                            if(String.isNotEmpty(sales.ZKVGR3)){
                                ce.Customer_Group_3__c = sales.ZKVGR3;
                            }
                            if(String.isNotEmpty(sales.ZKVGR4)){
                                ce.Customer_Group_4__c = sales.ZKVGR4;
                            }
                            if(String.isNotEmpty(sales.ZKVGR5)){
                                ce.Customer_Group_5__c = sales.ZKVGR5;
                            }
                            if(String.isNotEmpty(sales.KTGRD)){
                                ce.Account_Assignment_Group__c = sales.KTGRD;
                            }
                            // 付款方 Payer__c
                            if (String.isNotEmpty(sales.PAYER)){
                                List<Account> accountList = [SELECT Id
                                                             FROM Account
                                                             WHERE MDG_Customer_Code__c = :sales.PAYER];
                                if (!accountList.isEmpty()){
                                    ce.Payer__c = accountList[0].Id;
                                }
                            }
                            // 开票方 Receiver__c
                            if (String.isNotEmpty(sales.RECEIVER)){
                                List<Account> accountList = [SELECT Id
                                                             FROM Account
                                                             WHERE MDG_Customer_Code__c = :sales.RECEIVER];
                                if (!accountList.isEmpty()){
                                    ce.Receiver__c = accountList[0].Id;
                                }
                            }
                            if(String.isNotEmpty(sales.EIKTO)){
                                ce.Our_account_at_the_customer_s_place__c = sales.EIKTO;
                            }
                            ce.ExternalID__c = account.Id + '--' + ce.Hisense_Entity_Sales__c + '-' + ce.Distribution_Channel__c;

                            salesExtendList.add(ce);
                            // 税信息
                            List<GetCustomerInfoByCustomerCodeFromSAP2.Tax> taxList = sales.TAX;
                            if (!taxList.isEmpty()){
                                for (GetCustomerInfoByCustomerCodeFromSAP2.Tax tax : taxList){
                                    taxKeySet.add(tax.TAXCATEGORY + tax.TAXCLASSIFICATION);
                                    taxMap.put(ce.ExternalID__c + tax.TAXCATEGORY, tax.TAXCLASSIFICATION);
                                }
                            }
                        }
                    }
                }

                //忽略触发器更新
                Database.upsert (companyExtendList, Customer_Extend__c.Fields.ExternalID__c, false);
                Database.upsert (salesExtendList, Customer_Extend__c.Fields.ExternalID__c, false);
                if (!salesExtendList.isEmpty()){
                    List<Customer_Extend_Tax_category__c> customerExtendTaxCategoryList = [SELECT Id, Tax_category__c, Tax_category_code__c, Customer_Extend__r.ExternalID__c
                                                                                           FROM Customer_Extend_Tax_category__c
                                                                                           WHERE Customer_Extend__r.Customer__c = :account.Id];
                    if (!customerExtendTaxCategoryList.isEmpty()){
                        // 查询Tax_category__c
                        Map<String, Tax_category__c> taxTempMap = new Map<String, Tax_category__c>();
                        List<Tax_category__c> taxCategoryList = [SELECT Id, Name, Tax_category__c, Tax_Catagoery_External_Id__c
                                                                 FROM Tax_category__c
                                                                 WHERE Tax_Catagoery_External_Id__c IN:taxKeySet];
                        for (Tax_category__c tax : taxCategoryList){
                            taxTempMap.put(tax.Tax_Catagoery_External_Id__c, tax);
                        }
                        for (Customer_Extend_Tax_category__c cetc : customerExtendTaxCategoryList){
                            // 根据接口税数据的map获取当前 Tax category 对应的 Tax classification 值
                            String taxClassification = taxMap.get(cetc.Customer_Extend__r.ExternalID__c + cetc.Tax_category_code__c);
                            // 根据 Tax_category__c 表的外键获取对应的 Tax_category__c 值
                            if (taxTempMap.get(cetc.Tax_category_code__c + taxClassification) != null){
                                cetc.Tax_category__c = taxTempMap.get(cetc.Tax_category_code__c + taxClassification).Id;
                            }
                        }
                        // 保存税信息数据
                        Database.update (customerExtendTaxCategoryList);
                    }
                }
            }
            Utility.insertLog('GetCustomerInfoByCustomerCodeFromSAP2', '1', body, bodyRes);

        } catch (Exception e){
            //恢复触发器
            Utility.IgnoreAction(false, false, false, '');
            //日志内容
            Utility.insertLog('GetCustomerInfoByCustomerCodeFromSAP2', '0', body, 'failure: SF Sync Customer Information to SAP Failed! ' + e.getMessage() + '-------' + bodyRes);
            return;
        }
    }

}