@isTest
public with sharing class NewAccountPageControllerTest{
    @testSetup
    static void setup(){
        // 创建必要的自定义设置记录
        MDG_Interface__c mdgInterface = new MDG_Interface__c(
            Name = 'CustomerMaintain', 
            Url__c = 'https://test.url', 
            AppId__c = 'testAppId', 
            ClientId__c = '300', 
            If_Id__c = 'Customer_maintain', 
            SecretKey__c = 'testSecretKey', 
            Server__c = '123', 
            PCOMPANY__c = 'testCompany'
        );
        insert mdgInterface;

        MDG_Interface__c mdgInterface1 = new MDG_Interface__c(
            Name = 'CustomerQuery', 
            Url__c = 'https://test.url', 
            AppId__c = 'testAppId', 
            ClientId__c = 'testClientId', 
            If_Id__c = 'testIfId', 
            SecretKey__c = 'testSecretKey'
        );
        insert mdgInterface1;

        TaxCountryMapping__c tcm1 = new TaxCountryMapping__c();
        tcm1.name = '8110';
        tcm1.Country__c = 'US';
        insert tcm1;

        National_tax_category__c ntc = new National_tax_category__c();
        ntc.National_code__c = 'US';
        ntc.sort__c = 1;
        ntc.Tax_category__c = 'UTXJ';
        insert ntc;

        Tax_category__c tc = new Tax_category__c();
        tc.name = '1';
        tc.Tax_category__c = 'UTXJ';
        tc.Tax_Catagoery_External_Id__c = 'UTXJ1';
        insert tc;

        List<Account> accList = new List<Account>();
        Account acc = new Account(
            Name = 'Test Account001', 
            SAP_Customer_Code__c = '1234567890', 
            External_Key__c = '1234567890', 
            Sales_Region__c = 'Hisense USA', 
            Hisense_Entity__c = '8500', 
            Approval_Status__c = 'Approved',
            Type = 'Management', 
            Active_Flag__c = false, 
            Guarantor_Country_Code__c = 'CN', 
            Company_Registration_Number__c = '666', 
            Client_Type__c = '10', 
            Latest_Version__c = '1111'
        );

        Account acc2 = new Account(
            Name = 'Test Account002', 
            SAP_Customer_Code__c = '1234567899', 
            External_Key__c = '1234567899', 
            Sales_Region__c = 'Hisense USA', 
            Hisense_Entity__c = '8500',
            Approval_Status__c = 'Approved', 
            Type = 'Management', 
            Active_Flag__c = false, 
            Guarantor_Country_Code__c = 'CN', 
            Company_Registration_Number__c = '777', 
            Client_Type__c = '10', 
            Latest_Version__c = '2222'
        );

        accList.add(acc);
        accList.add(acc2);
        insert accList;

        List<Customer_Extend__c> ceList = new List<Customer_Extend__c>();
        Customer_Extend__c ce1 = new Customer_Extend__c();
        ce1.Customer__c = acc.id;
        ce1.Hisense_Entity__c = '8110';
        ce1.Show_Company__c = true;
        ce1.Show_Sales__c = false;

        Customer_Extend__c ce2 = new Customer_Extend__c();
        ce2.Customer__c = acc.id;
        ce2.Hisense_Entity_Sales__c = '8110';
        ce2.Show_Company__c = false;
        ce2.Show_Sales__c = true;

        ceList.add(ce1);
        ceList.add(ce2);
        insert ceList;

        Customer_Banks__c cb = new Customer_Banks__c();
        cb.Customer__c = acc.id;
        cb.Bank_Country__c = 'US';
        cb.Bank_Account__c = '123';
        cb.Approval_Status__c = 'Draft';
        cb.Bank_name_local_language__c = '123';
        insert cb;

        Customer_Extend_Tax_category__c teax = new Customer_Extend_Tax_category__c();
        teax.Customer_Extend__c = ce2.Id;
        insert teax;

        List<Customer_Product_Line__c> cpls = new List<Customer_Product_Line__c>();
        Customer_Product_Line__c cpl1 = new Customer_Product_Line__c();
        cpl1.Product_Line_Name__c = 'TV';
        cpl1.Customer__c = acc.Id;
        cpl1.Classification__c = 'Agency Customer';//
        cpl1.Development_Stage__c = 'Undeveloped';
        cpl1.Rank__c = 'Strategy Customer';
        cpls.add(cpl1);

        Customer_Product_Line__c cpl2 = new Customer_Product_Line__c();
        cpl2.Product_Line_Name__c = 'WM';
        cpl2.Customer__c = acc.Id;
        cpl2.Classification__c = 'OEM Customer';//OEM Customer
        cpl2.Development_Stage__c = 'Undeveloped';
        cpls.add(cpl2);

        Customer_Product_Line__c cpl3 = new Customer_Product_Line__c();
        cpl3.Product_Line_Name__c = 'Freezer';
        cpl3.Customer__c = acc.Id;
        cpl3.Classification__c = 'Customer of Oversea Company';
        cpl3.Development_Stage__c = 'Undeveloped';
        cpl3.Rank__c = 'Strategy Customer';
        cpls.add(cpl3);

        insert cpls;

        String plids = cpl1.id + ';' + cpl2.id + ';' + cpl3.id;
        Score_Sheet__c ss = new Score_Sheet__c();
        ss.Customer__c = acc.id;
        ss.Product_Line__c = 'TV';
        ss.PL_ID_List__c = plids;
        insert ss;

        Customer_History__c ch = new Customer_History__c();
        ch.Object_Name__c = 'Account';
        ch.Record_Id__c = acc.Id;
        ch.Latest_Version__c = acc.Latest_Version__c;
        ch.Record_Body__c = JSON.serialize(acc, false);
        insert ch;

        Customer_Extend__c extend1 = [SELECT Id, Hisense_Entity__c, Customer_EDI_ID_Type__c, Reconciliation_Customer__c, EDI_ID__c, Payment_Method_MDG__c, EDI_ID2__c, Payment_Term__c, Packing_Type__c, Stor_Location__c, TV_lisense__c, VAT_Tax_type__c, Valid_to__c, Add_VAT_Reg_No__c, Account_Remarks__c, Company_View_Freeze_markers__c
                                      FROM Customer_Extend__c
                                      WHERE Id = :ce1.Id];
        Customer_Extend__c extend2 = [SELECT Id, Hisense_Entity__c, Customer_EDI_ID_Type__c, Reconciliation_Customer__c, EDI_ID__c, Payment_Method_MDG__c, EDI_ID2__c, Payment_Term__c, Packing_Type__c, Stor_Location__c, TV_lisense__c, VAT_Tax_type__c, Valid_to__c, Add_VAT_Reg_No__c, Account_Remarks__c, Company_View_Freeze_markers__c
                                      FROM Customer_Extend__c
                                      WHERE Id = :ce2.Id];
        Customer_History__c ch1 = new Customer_History__c();
        ch1.Object_Name__c = 'Customer_Extend__c';
        ch1.Record_Id__c = extend1.Id;
        ch1.Latest_Version__c = acc.Latest_Version__c;
        ch1.Record_Body__c = JSON.serialize(extend1, false);
        insert ch1;

        Customer_History__c ch2 = new Customer_History__c();
        ch2.Object_Name__c = 'Customer_Extend__c';
        ch2.Record_Id__c = extend2.Id;
        ch2.Latest_Version__c = acc.Latest_Version__c;
        ch2.Record_Body__c = JSON.serialize(extend2, false);
        insert ch2;

        Customer_Banks__c banks = [SELECT Id, Name, Bank_Country__c, MDG_BANK__c, Bank_Code__c, Bank_name_local_language__c, Swift_Code__c, Bank_name_in_English__c, Bank_Account__c, Bank_Control_Code__c, Bank_Account_Holder__c
                                   FROM Customer_Banks__c
                                   WHERE Id = :cb.Id];
        Customer_History__c ch3 = new Customer_History__c();
        ch3.Object_Name__c = 'Customer_Banks__c';
        ch3.Record_Id__c = banks.Id;
        ch3.Latest_Version__c = acc.Latest_Version__c;
        ch3.Record_Body__c = JSON.serialize(banks, false);
        insert ch3;
    }

    @isTest
    static void test01(){
        // 获取测试账户
        Account testAccount = [SELECT Id
                               FROM Account
                               WHERE Name = 'Test Account001'
                               LIMIT 1];
        Account testAccount2 = [SELECT Id
                                FROM Account
                                WHERE Name = 'Test Account002'
                                LIMIT 1];
        Customer_Extend__c extend = [SELECT Id
                                     FROM Customer_Extend__c
                                     WHERE Show_Sales__c = true
                                     LIMIT 1];
        Tax_category__c tax = [SELECT Id
                               FROM Tax_category__c
                               LIMIT 1];
        Customer_Product_Line__c productLine = [SELECT Id
                                                FROM Customer_Product_Line__c
                                                LIMIT 1];

        NewAccountPageController.getCustomerExtendForCompany(testAccount.Id);
        NewAccountPageController.getCustomerExtendForCompany(testAccount2.Id);
        NewAccountPageController.getCustomerExtendForSales(testAccount.Id);
        NewAccountPageController.getCustomerExtendForSales(testAccount2.Id);
        NewAccountPageController.getCustomerBanks(testAccount.Id);
        NewAccountPageController.getCustomerBanks(testAccount2.Id);
        NewAccountPageController.getCustomerProductLine(testAccount.Id);
        NewAccountPageController.getCustomerProductLine(testAccount2.Id);
        NewAccountPageController.deleteRecord(productLine.Id);

        String accountView = '{"Id":"' + testAccount.Id + '","Name":"wfc-test-444","Guarantor_Country_Code__c":"US","Email_Multiple__c":"1111@163.com;2222@163.com;4444@163.com","Latest_Version__c":"a132472c0da732174342d53d9325ac52","Marketing_Model__c":"3","Company_Registration_Number__c":"6666","Customer_Name_Local_Language_2__c":"111"}';
        String companyView = '{"Customer__c":"' + testAccount.Id + '","Create_View__c":"1","Hisense_Entity__c":"8020","Stor_Location__c":null,"Reconciliation_Customer__c":"1122010101"}';
        String salesView = '{"Customer__c":"' + testAccount.Id + '","Create_View__c":"2","Hisense_Entity_Sales__c":"8060","Sales_Group__c":null,"Sales_Office__c":null,"Sales_Region__c":"Hisense USA","Shipping_Conditions__c":"04"}';
        String bankView = '{"Customer__c":"' + testAccount.Id + '","Bank_Country__c":"CN","Bank_name_local_language__c":"123","Bank_Account__c":"123"}';
        String productLineView = '{"Customer__c":"' + testAccount.Id + '","Product_Line_Name__c":"AC","Main_Brand_Share__c":"","Classification__c":"OEM Customer"}';
        String scoreView = '{"Product_Line__c":"Freezer","Customer_credit_rating_OEM__c":"20","Industry_ranking_OEM__c":"20","Petential_development_capacity__c":"20","Cooperation_product_lineup_OEM__c":"5"}';
        String taxView = '[{"Tax_category_code__c":"UTXJ","Tax_category__c":"' + tax.Id + '"}]';

        String accountViewError = '{"Customer__c":"111"}';
        String companyViewError = '{"Customer__c":"111"}';
        String bankViewError = '{"Customer__c":"111"}';
        String productLineViewError = '{"Customer__c":"111"}';
        String scoreViewError = '{"Customer__c":"111"}';

        NewAccountPageController.saveCompanySalesView(companyView);
        NewAccountPageController.saveBankView(bankView);
        NewAccountPageController.saveProductLineView(productLineView);
        NewAccountPageController.saveScoreSheetView(scoreView);
        NewAccountPageController.saveAccountView(accountView);

        NewAccountPageController.saveCompanySalesView(companyViewError);
        NewAccountPageController.saveBankView(bankViewError);
        NewAccountPageController.saveProductLineView(productLineViewError);
        NewAccountPageController.saveScoreSheetView(scoreViewError);
        NewAccountPageController.saveAccountView(accountViewError);

        NewAccountPageController.getAccountData(testAccount.Id);
        NewAccountPageController.getUserInfo();
        NewAccountPageController.getAccountRecordType(Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('customer').getRecordTypeId());
        NewAccountPageController.getTaxInfoBySalesId(extend.Id);
        NewAccountPageController.saveTaxCategoryView(taxView);
    }

    @isTest
    static void test02(){
        // 获取测试账户
        Account testAccount = [SELECT Id
                               FROM Account
                               WHERE Name = 'Test Account001'
                               LIMIT 1];
        Account testAccount2 = [SELECT Id
                                FROM Account
                                WHERE Name = 'Test Account002'
                                LIMIT 1];
        Customer_Extend__c extend = [SELECT Id, EDI_ID__c
                                     FROM Customer_Extend__c
                                     WHERE Show_Sales__c = true
                                     LIMIT 1];
        Customer_Extend__c extend1 = [SELECT Id, EDI_ID__c
                                      FROM Customer_Extend__c
                                      WHERE Show_Company__c = true
                                      LIMIT 1];
        Customer_Banks__c bank = [SELECT Id, Swift_Code__c
                                  FROM Customer_Banks__c
                                  LIMIT 1];
        Tax_category__c tax = [SELECT Id
                               FROM Tax_category__c
                               LIMIT 1];
        Customer_Product_Line__c productLine = [SELECT Id
                                                FROM Customer_Product_Line__c
                                                LIMIT 1];

        NewAccountPageController.saveTaxCategoryView(testAccount.Id);
        NewAccountPageController.undoChangesView(testAccount.Id);

        testAccount.Channel_Customer_Categories__c = '10';
        testAccount.Channel_Customer_Subcategories__c = '101';
        testAccount.Transportation_area__c = '0000000001';
        update testAccount;
        extend.Sale_View_Freezed_Reason__c = '111';
        update extend;
        extend1.EDI_ID__c = '111';
        update extend1;
        bank.Swift_Code__c = '111';
        update bank;

        NewAccountPageController.initAccountChangesInfo(testAccount.Id);
        NewAccountPageController.checkSubAccountCreditManagement(testAccount.Id, testAccount.Id);
        NewAccountPageController.handleVerification('US', '666', Schema.SobjectType.Account.getRecordTypeInfosByDeveloperName().get('customer').getRecordTypeId(), testAccount.Id);
    }

    @isTest
    static void test03(){
        String str = '{"ZZZJLX":"Z15","ZZVAT":"666","ZZRENO":"666","ZZREFD":"0.0000","ZZPDFD":"0.0000","ZZMXLX":"10","ZZLINE":"20","ZZLERE":null,"ZZIFCM":null,"ZZHWKHFJ":null,"ZZFONM":null,"ZZFHYY":null,"ZZFHLX":null,"ZZEMCN":null,"ZZDUNS":null,"ZZCVCO":null,"ZZCUSTA":"10","ZZCUSRITY":null,"ZZCUSRISL":null,"ZZCUSGR":null,"ZZCRERAT":null,"ZZCMCO":null,"ZZCMAT":null,"ZZCHCUSSU":"101","ZZCHCUSCA":"10","ZZBNAR":null,"ZZBLED":"99991231","ZZANRE":null,"ZTAX_JUR":null,"ZTAX_CODE4":"44","ZTAX_CODE3":null,"ZTAX_CODE2":null,"ZTAX_CODE1":"1111","ZSORT2":null,"ZLIFNR":"11111","URI_ADDR":null,"TEL_NUMBER":"33333","TAXKD":null,"SMTP_ADDR":"1111@163.com;2222@163.com;4444@163.com","SALES":[{"CLIENT":"810","ZTERM":null,"ZKVGR5":null,"ZKVGR4":null,"ZKVGR3":null,"ZKVGR1":null,"WAERS":"ZAR","VWERK":null,"VTWEG":"11","VSBED":"10","VKORG":"8110","VKGRP":null,"VKBUR":null,"TAXCODN":[{"TAXKD":"1","TATYP":"UTXJ","ALAND":"US"}],"TATYP":null,"SPART":"00","PYKUR":null,"PODKZ":null,"LOEVM":null,"KVGR2":null,"KTGRD":"Z1","KONDA":null,"KDGRP":null,"KALKS":"X","INCO3_L":null,"INCO2_L":null,"INCO1":null,"BZIRK":null,"BPKUR":null,"AUFSD":null}],"PARTNER":"22062504","NAME_ORG4":"22","NAME_ORG3":"3333334444","NAME_ORG2":"11","NAME_ORG1":"wfc-test-444","NAME_LO":"wfc-test-44411","NAME_EN":"333333444422","LZONE":null,"IND_SECTOR":null,"FOUND_DAT":"20250519","FAX_NUMBER":null,"CUTSOMER_TYPE":[{"ZZCUSTY":"10","PARTNER":"22062504"}],"COMPANY":[{"CLIENT":"810","ZZSORT2":"333333333","ZZSORT1":"444444","ZZSH":"123","ZZLINE":null,"ZZLGORT":null,"ZWELS":"C","ZVALID_TO":"20250603","ZTV":"888","ZTERM":null,"ZKHFL":"23","SREGL":null,"PACKAGING_TYPE":"5555","NODEL":null,"LOEVM":null,"KVERM":"7777","EDI_TYPE":"22222","BUKRS":"8110","AKONT":"1121010101"}],"BUBKZ":null,"BU_SORT1":"WFC-TEST-333","BU_LANGU":"EN","BU_GROUP":"H002","BBSNR":null,"BBBNR":null,"BANKDETAIL":[{"ZZWAERS":"ZAR","ZZACCNAME":"11111","PMODE":null,"IBAN":null,"BKONT":null,"BANKS":"CN","BANKN":"201000334562272","BANKL":"H009583301","ACCNAME":"wfc-test-44411"}],"AUFSD":null,"ADDR":[{"ZZTOWN":"TownTownTownTown","ZZADTY":"01","REGIO":"GA","POST_CODE1":"26600","ORT02":"DistrictDistrictDistrictDistrict","ORT01":"CityCityCityCityCity","LAND1":"US","FSTRAS":"StreetStreetStreetStreetStreet2224444"}]}';
        NewAccountPageController.syncMDGAccount(str, Schema.SobjectType.Account.getRecordTypeInfosByDeveloperName().get('customer').getRecordTypeId());

        String str1 = '{"ZZZJLX":"Z15","ZZVAT":"666","ZZRENO":"666","ZZREFD":"0.0000","ZZPDFD":"0.0000","ZZMXLX":"10","ZZLINE":"20","ZZLERE":null,"ZZIFCM":null,"ZZHWKHFJ":null,"ZZFONM":null,"ZZFHYY":null,"ZZFHLX":null,"ZZEMCN":null,"ZZDUNS":null,"ZZCVCO":null,"ZZCUSTA":"10","ZZCUSRITY":null,"ZZCUSRISL":null,"ZZCUSGR":null,"ZZCRERAT":null,"ZZCMCO":null,"ZZCMAT":null,"ZZCHCUSSU":"101","ZZCHCUSCA":"10","ZZBNAR":null,"ZZBLED":"99991231","ZZANRE":null,"ZTAX_JUR":null,"ZTAX_CODE4":"44","ZTAX_CODE3":null,"ZTAX_CODE2":null,"ZTAX_CODE1":"1111","ZSORT2":null,"ZLIFNR":"11111","URI_ADDR":null,"TEL_NUMBER":"33333","TAXKD":null,"SMTP_ADDR":"1111@163.com;2222@163.com;4444@163.com","SALES":null,"PARTNER":"22062504","NAME_ORG4":"22","NAME_ORG3":"3333334444","NAME_ORG2":"11","NAME_ORG1":"wfc-test-444","NAME_LO":"wfc-test-44411","NAME_EN":"333333444422","LZONE":null,"IND_SECTOR":null,"FOUND_DAT":"20250519","FAX_NUMBER":null,"CUTSOMER_TYPE":[{"ZZCUSTY":"10","PARTNER":"22062504"}],"COMPANY":[{"CLIENT":"810","ZZSORT2":"333333333","ZZSORT1":"444444","ZZSH":"123","ZZLINE":null,"ZZLGORT":null,"ZWELS":"C","ZVALID_TO":"20250603","ZTV":"888","ZTERM":null,"ZKHFL":"23","SREGL":null,"PACKAGING_TYPE":"5555","NODEL":null,"LOEVM":null,"KVERM":"7777","EDI_TYPE":"22222","BUKRS":"8110","AKONT":"1121010101"}],"BUBKZ":null,"BU_SORT1":"WFC-TEST-333","BU_LANGU":"EN","BU_GROUP":"H002","BBSNR":null,"BBBNR":null,"BANKDETAIL":[{"ZZWAERS":"ZAR","ZZACCNAME":"11111","PMODE":null,"IBAN":null,"BKONT":null,"BANKS":"CN","BANKN":"201000334562272","BANKL":"H009583301","ACCNAME":"wfc-test-44411"}],"AUFSD":null,"ADDR":[{"ZZTOWN":"TownTownTownTown","ZZADTY":"01","REGIO":"GA","POST_CODE1":"26600","ORT02":"DistrictDistrictDistrictDistrict","ORT01":"CityCityCityCityCity","LAND1":"US","FSTRAS":"StreetStreetStreetStreetStreet2224444"}]}';
        NewAccountPageController.syncMDGAccount(str1, Schema.SobjectType.Account.getRecordTypeInfosByDeveloperName().get('customer').getRecordTypeId());
    }

}