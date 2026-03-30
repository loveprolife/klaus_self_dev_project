/**********************************************************************
* Name: GetCustomerInfoFromSAP 
* Object: Account 
* Purpose: SAP system send customer information to Salesforce
* Author: Roy
* Create Date: 2019-03-11
*************************************************************************/
public with sharing class GetCustomerInfoFromSAP {

    private static String url = Interface_Url__c.getValues('SAP').Basic_Url__c + 'CC_REST_CUSTOMERINFO_GET_SEND';
    private static String user = Interface_Url__c.getValues('SAP').User_Name__c;
    private static String password = Interface_Url__c.getValues('SAP').Password__c;
    
    //private static String url = 'https://crmxip.hisense.com:8443/RESTAdapter/'+ 'CC_REST_CUSTOMERINFO_GET_SEND';
    //private static String user = 'xiaxiaoyang';
    //private static String password = 'hs123456';

    static List<GetCustomerInfoFromSAP.customerInfo> prSame2SelftList ;
    static List<GetCustomerInfoFromSAP.customerInfo> prNotSame2SelftList ;
    static List<GetCustomerInfoFromSAP.customerInfo> accountList2PayerAndReceiver ; 

    public class Output{
        List<String> CompanyCodeList;
        String SyncStartDate;
        String SyncEndDate;
        String AccountGroup;
    }
    public class Input{
        public List<customerInfo> CustomerList;
        public String isSuccess;
        public String failReason;
    }
    public class customerInfo{
        public String SFCode;
        public String SAPCustomerCode;
        public String SAPCustomerCode2;
        public String CustomerGroup;
        public String CustomerLocalLanguage1;
        public String CustomerLocalLanguage2;
        public String CustomerEnglishLanguage1;
        public String CustomerEnglishLanguage2;
        public String Billingto;
        public String Shppingto;
        public String ShortName;
        public String Street2;
        public String Street3;
        public String Street4;
        public String Street5;
        public String CountryCode;
        public String ProvinceState;
        public String City;
        public String PostalCode;
        public String TelephoneNumber;
        public String Fax;
        public String TaxNumber1;
        public String TaxNumber2;
        public String VATRegistrationNumber;
        public String ReconciliatioCustomer;
        public String DistributioChannel;
        public String ProductGroup;
        public String OrderPossibility;
        public String SalesOffice;
        public String SalesGroup;
        public String SFCurrency;
        public String CustomerPricingProcess;
        public String PriceList;
        public String CustomerStatisticsGroup;
        public String ShippingConditions;
        public String RelatedtoPOD;
        public String PaymentCondition;
        public String PaymentCondition1;
        public String CustomerGroup2;
        public String DeliveryPriority;
        public String DeliveryingPlant;
        public String LocationNo1;
        public String LocationNo2;
        public String CheckDigit;
        public String StorLocation;
        public List<String> CompanyList;
        public List<BillingCertificate> BillingCertificateList;

        //泰国、越南显示、必填  lzx 20241220
        public String Name3;
    }
    public class BillingCertificate{
        public String TaxCategory;
        public String TaxClassification;
    }

    @Future(callout=true)
    public static Void getCustomerInfo(List<String> companyCodeList,String syncStartDate,String syncEndDate){
    // public static void getCustomerInfo(){
        String interfaceType = '';
        Output out = new Output();
        out.CompanyCodeList = companyCodeList;
        out.SyncStartDate = syncStartDate;
        out.SyncEndDate = syncEndDate;
        String body;
        if (!companyCodeList.isEmpty() && companyCodeList[0] == '8410') {
            body = companyCodeList[1];
            System.debug(LoggingLevel.INFO, '*** body: ' + body);
            interfaceType = 'Shop__c';
        }else {
            body = JSON.serialize(out);
        }
        // String body = '{"CompanyCodeList": ["8110"],"SyncStartDate": "2019-04-01","SyncEndDate": "2019-04-10"}';
        GetCustomerInfoFromSAP.Input input = new GetCustomerInfoFromSAP.Input();
        String bodyRes;
        try {
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
            response = http_login.send(request);
            String bodyRes_login = response.getBody();
            // String bodyRes_login = '{"IsSuccess": "","FailReason": "","CustomerList": [{"SFCode": "","SAPCustomerCode": "0000500047","CustomerGroup": "C005","CustomerLocalLanguage1": "","CustomerLocalLanguage2": "","CustomerEnglishLanguage1": "TEST FOREIGN CUSTOMER","CustomerEnglishLanguage2": 2,"Billingto": "0000500047","Shppingto": "0000500047","ShortName": "TEST","Street2": "200 The Campus Maylands Avenue","Street3": "s2","Street4": "s3","Street5": "s4","CountryCode": "US","ProvinceState": "LA","City": "不详","PostalCode": 30000,"TelephoneNumber": "ZH","Fax": "0044-1727 204058","TaxNumber1": "","TaxNumber2": "","VATRegistrationNumber": "","ReconciliatioCustomer": 1122020110,"PaymentCondition": "G001","DistributioChannel": 11,"ProductGroup": "00","OrderPossibility": 100,"SalesOffice": "","SalesGroup": "","SFCurrency": "USD","CustomerPricingProcess": "X","PriceList": "","CustomerStatisticsGroup": 1,"ShippingConditions": "01","RelatedtoPOD": "","PaymentCondition1": "G001","CustomerGroup2": "","DeliveryPriority": "","DeliveryingPlant": "","LocationNo1": "0000000","LocationNo2": "00000","CheckDigit": 0,"StorLocation": "","HisenseEntityList": [8010],"CompanyList": [8010],"BillingCertificateList": [{"TaxCategory": "UTXJ","TaxClassification": 0}]}, {"SFCode": "","SAPCustomerCode": "0000500058","CustomerGroup": "Z006","CustomerLocalLanguage1": "","CustomerLocalLanguage2": "","CustomerEnglishLanguage1": "内贸客户测试","CustomerEnglishLanguage2": "","Billingto": "0000500058","Shppingto": "0000500058","ShortName": "","Street2": "NAME1111","Street3": "","Street4": "","Street5": "","CountryCode": "CN","ProvinceState": "","City": "","PostalCode": "","TelephoneNumber": "","Fax": "","TaxNumber1": "","TaxNumber2": "","VATRegistrationNumber": "","ReconciliatioCustomer": 1122010501,"PaymentCondition": "","DistributioChannel": 15,"ProductGroup": "00","OrderPossibility": 100,"SalesOffice": "","SalesGroup": "","SFCurrency": "CNY","CustomerPricingProcess": "X","PriceList": "","CustomerStatisticsGroup": 1,"ShippingConditions": "01","RelatedtoPOD": "","PaymentCondition1": "","CustomerGroup2": "","DeliveryPriority": "","DeliveryingPlant": "","LocationNo1": "0000000","LocationNo2": "00000","CheckDigit": 0,"StorLocation": "","HisenseEntityList": [8010],"CompanyList": [8010],"BillingCertificateList": [{"TaxCategory": "","TaxClassification": ""}]}, {"SFCode": "","SAPCustomerCode": "0000500129","CustomerGroup": "Z006","CustomerLocalLanguage1": "","CustomerLocalLanguage2": "","CustomerEnglishLanguage1": "MAKRO 测试数据","CustomerEnglishLanguage2": "","Billingto": "0000500129","Shppingto": "0000500129","ShortName": "MAKRO","Street2": 1234,"Street3": "","Street4": "","Street5": "","CountryCode": "ZA","ProvinceState": "GP","City": "","PostalCode": "","TelephoneNumber": "","Fax": "","TaxNumber1": "","TaxNumber2": "","VATRegistrationNumber": "","ReconciliatioCustomer": 1121020101,"PaymentCondition": "","DistributioChannel": 11,"ProductGroup": "00","OrderPossibility": 100,"SalesOffice": "","SalesGroup": "","SFCurrency": "CNY","CustomerPricingProcess": "X","PriceList": "","CustomerStatisticsGroup": 1,"ShippingConditions": "02","RelatedtoPOD": "X","PaymentCondition1": "","CustomerGroup2": "","DeliveryPriority": "01","DeliveryingPlant": "","LocationNo1": "0000000","LocationNo2": "00000","CheckDigit": 0,"StorLocation": "","HisenseEntityList": [8010],"CompanyList": [8010],"BillingCertificateList": [{"TaxCategory": "","TaxClassification": ""}]}]}';
            input =(GetCustomerInfoFromSAP.Input)JSON.deserialize(bodyRes_login,GetCustomerInfoFromSAP.Input.class );
            //if(bodyRes_login.length() < 50){
            if('No data'.equals(input.IsSuccess)){
                SFUtility.writeCallLogs('true', 'GetCustomerInfoFromSAP', body, bodyRes_login, 'Outbound', 'No data');
                return ;
            }

            if (interfaceType == 'Shop__c') {
                // 获取第五级网格 匹配市字段
                List<Gridding__c> griddingList = [SELECT Id,Name FROM Gridding__c WHERE DivisionUnit__c = '市'];

                List<Shop__c> upsertShopList = new List<Shop__c>();
                for (GetCustomerInfoFromSAP.customerInfo ci : input.CustomerList) {
                    Shop__c shop = new Shop__c();
                    if (String.isNotBlank(ci.SAPCustomerCode)) {
                        shop.Account__r = new Account(External_Key__c = ci.SAPCustomerCode);
                    }
                    shop.External_Key_ID__c = ci.SAPCustomerCode2;
                    shop.Name = ci.CustomerLocalLanguage1 + ci.CustomerLocalLanguage2;
                    shop.EN_Name__c = ci.CustomerEnglishLanguage1 + ci.CustomerEnglishLanguage2;
                    shop.Postal__c = String.valueOf(ci.PostalCode);
                    shop.City__c = ci.City;
                    // 是否包含网格名称, 包含网格名称赋值该网格
                    if(String.isNotBlank(ci.City)){
                        for(Gridding__c gr : griddingList){
                            if(ci.City.contains(gr.Name)){
                                shop.Grid__c = gr.id;
                                break;
                            }
                        }
                    }
                    shop.Address1__c = ci.Street2 + ci.Street3;
                    shop.Phone__c = ci.TelephoneNumber;
                    shop.Fax__c = ci.Fax;
                    shop.Sales_Region__c = 'Hisense Japan';
                    upsertShopList.add(shop);
                }
                String errorMessage = '';
                Boolean isSucceed = true;
                if (!upsertShopList.isEmpty()) {
                    List<Database.UpsertResult> srInfoList = Database.upsert(upsertShopList, Shop__c.External_Key_ID__c, true);
                    for (Database.UpsertResult sr : srInfoList) {
                        if (sr.isSuccess()) {

                        }else {
                            for(Database.Error err : sr.getErrors()) {
                                isSucceed = false;
                                errorMessage = errorMessage + err;
                                System.debug('error has occurred.' + err.getStatusCode() + ': ' + err.getMessage());                    
                                System.debug('fields that affected this error: ' + err.getFields());
                            }
                        }
                    }
                }
                SFUtility.writeCallLogs(String.valueOf(isSucceed), 'GetShop', body, bodyRes_login, 'Outbound', errorMessage);
                return;
            }

            //remove object which not belong to accounting mode from salesforce
            Set<String> sapCodeSet = new Set<String>();
            for(GetCustomerInfoFromSAP.customerInfo ccvar: input.CustomerList){
                sapCodeSet.add(ccvar.SAPCustomerCode);
            }

            Map<String,String> sapCode2CompanyCodeMap = new Map<String,String>();
            for(Account acco : [select id,name,SAP_Customer_Code__c,Hisense_Entity__c from Account where SAP_Customer_Code__c in: sapCodeSet]){
                sapCode2CompanyCodeMap.put(acco.SAP_Customer_Code__c, acco.Hisense_Entity__c);
            }

            //duplicate the value (sapcode same record) that the sapcode not exist insalesforce
            List<GetCustomerInfoFromSAP.customerInfo> notExistinSFObjectList = new List<GetCustomerInfoFromSAP.customerInfo>();
            List<GetCustomerInfoFromSAP.customerInfo> notExistinSFObjectListTemp = new List<GetCustomerInfoFromSAP.customerInfo>();
            System.debug('sapCode2CompanyCodeMapsapCode2CompanyCodeMap '+sapCode2CompanyCodeMap);
            System.debug('input.CustomerList.size();;; '+input.CustomerList.size());
            List<GetCustomerInfoFromSAP.customerInfo> CustomerListTmp = new List<GetCustomerInfoFromSAP.customerInfo>();
            //notExistinSFObject record picking up
            for(Integer i = 0 ; i < input.CustomerList.size() ; i++){
                //store non exist customer in salesforce
                if(sapCode2CompanyCodeMap.get(input.CustomerList[i].SAPCustomerCode) == null){
                    notExistinSFObjectList.add(input.CustomerList[i]);
                }else if(input.CustomerList[i].CompanyList[0] != sapCode2CompanyCodeMap.get(input.CustomerList[i].SAPCustomerCode)){
                    //do nothing
                }else{
                    //其他类别的客户存放在CustomerListTmp中
                    CustomerListTmp.add(input.CustomerList[i]);
                }
            }

            //清除CustomerList
            input.CustomerList.clear();
            //将值塞进CustomerList
            input.CustomerList.addAll(CustomerListTmp);

            System.debug('nput.CustomerList.remove(i);: '+input.CustomerList);
            System.debug('notExistinSFObjectListyyyyy: '+notExistinSFObjectList);
            //duplicate non exsit list
            //对于不存在的记录进行去重
            List<String> tempSAPcodeList = new List<String>();
            for(Integer i = 0 ; i < notExistinSFObjectList.size() ; i++){
                for(Integer j = 0 ; j < notExistinSFObjectListTemp.size() ; j++){
                    tempSAPcodeList.add(notExistinSFObjectListTemp[j].SAPCustomerCode);
                }
                if(!tempSAPcodeList.contains(notExistinSFObjectList[i].SAPCustomerCode)){
                    notExistinSFObjectListTemp.add(notExistinSFObjectList[i]);
                }
                tempSAPcodeList.clear();
            }
            system.debug('notExistinSFObjewwwctListTemp:: '+notExistinSFObjectListTemp);

            //if(notExistinSFObjectListTemp !=null & !notExistinSFObjectListTemp.isEmpty()){
                // sending notification to operation team once customer created in SAP
                //System.debug('111');
                //sendingEmail2OperationTeam(notExistinSFObjectListTemp);
            //}

            system.debug('input.CustomerListaaa:: '+input.CustomerList);
            
            system.debug('input.CustomerListaaa:: '+input.CustomerList);

            //add the notExistinSFObjectList to CustomerList
            for(Integer j = 0 ; j < notExistinSFObjectListTemp.size() ; j++){
                input.CustomerList.add(notExistinSFObjectListTemp[j]);
            }
            System.debug('notExistinSFObjectListTempKKKKK '+notExistinSFObjectListTemp);
            //input.CustomerList.addAll(notExistinSFObjectListTemp);
            system.debug('input.CustomerListLLLLLL:: '+input.CustomerList);
            System.debug('ANY oinputinput '+input);

        }
        catch (Exception e) {
            //日志内容
            InterfaceLog__c ic = new InterfaceLog__c();
            ic.Class__c = 'GetCustomerInfoFromSAP';
            ic.Time__c = System.Now();
            ic.ReturnCode__c = '0';
            ic.Req_Json__c = body;
            ic.Res_Json__c = bodyRes;
            ic.ErrorMsg__c = 'salesforce call SAP interface failed! Error Message: '+e.getMessage() + e.getLineNumber();
            insert ic;
            return; 
        }
        if (input.isSuccess == 'False') {
            //日志内容
            InterfaceLog__c ic = new InterfaceLog__c();
            ic.Class__c = 'GetCustomerInfoFromSAP';
            ic.Time__c = System.Now();
            ic.ReturnCode__c = '0';
            ic.Req_Json__c = body;
            ic.Res_Json__c = bodyRes;
            ic.ErrorMsg__c = input.failReason;
            insert ic;
            return; 
        }
        //送达方和售达方和自身相同的记录，插入操作
        List<GetCustomerInfoFromSAP.customerInfo> ciVarList = new List<GetCustomerInfoFromSAP.customerInfo>();
        if(input.CustomerList != null){
            for(GetCustomerInfoFromSAP.customerInfo ccvar: input.CustomerList){
                ciVarList.add(ccvar);
            }
            System.debug('input.CustomerListsqqa::: '+input.CustomerList);
            handleCustomerInfo(input.CustomerList,'1',body,bodyRes,ciVarList);
        }
        //送达方或售达方和自身不相同的记录，插入操作
        if(prNotSame2SelftList != null){
            for(Integer i = 0 ; i < ciVarList.size() ; i++){
                for(Integer j = 0 ; j < prNotSame2SelftList.size() ; j++){
                    if(ciVarList[i].SAPCustomerCode.equals(prNotSame2SelftList[j].SAPCustomerCode)){
                        ciVarList.remove(i);
                    }
                }
            }
            for(GetCustomerInfoFromSAP.customerInfo ccvar: prNotSame2SelftList){
                ciVarList.add(ccvar);
            }
            handleCustomerInfo(prNotSame2SelftList,'2',body,bodyRes,ciVarList);
        }

        //送达方和售达方和自身相同的记录，插入操作
        if(prSame2SelftList != null){
            for(GetCustomerInfoFromSAP.customerInfo ccvar: prSame2SelftList){
                if(ccvar.SAPCustomerCode.equals(ccvar.Billingto)){
                    ccvar.Billingto = null;
                }
                if(ccvar.SAPCustomerCode.equals(ccvar.Shppingto)){
                    ccvar.Shppingto = null;
                }
                ciVarList.add(ccvar);
            }
            handleCustomerInfo(prSame2SelftList,'3',body,bodyRes,ciVarList);
        }
    }
    
    private static void handleCustomerInfo(List<GetCustomerInfoFromSAP.customerInfo> inputList,String prFlag, String body, String bodyRes,List<GetCustomerInfoFromSAP.customerInfo> ciVarList){
        //inputList : partial input list
        //ciVarList : increased input list
        if (inputList != null & !inputList.isEmpty()) {
            Set<String> taxCategoeryExtIdList = new Set<String>();
            List<String> nationalCategoeryExtIdList = new List<String>();
            List<String> customerSAPALLCodeList = new List<String>();
            List<GetCustomerInfoFromSAP.customerInfo> judgeInputList = new List<GetCustomerInfoFromSAP.customerInfo>();
            Set<String> payerAndReceiverList = new Set<String>();
            Map<String,String> customerSAPCode2IdMap = new Map<String,String>();
            List<String> countryList = new List<String>();
            List<String> sapCodeUsedAllList = new List<String>();
            Map<String,String> countryCode2IdMap = new Map<String,String>();
            Map<String,String> sapCodeUsedAll2IdMap = new Map<String,String>();
            //sales office id list
            List<String> salesOfficeExtIdList = new List<String>();
            //sales group id list
            List<String> salesGroupExtIdList = new List<String>();
            //stor location id list
            List<String> storLocationExtIdList = new List<String>();

            List<String> paymentConditionList = new List<String>();
            Map<String,String> paymentConditionName2IdMap = new Map<String,String>();
            Map<String,String> HisenseEntity2SalesRegionMap = new Map<String,String>();
            
            //Set<String> HisenseEntitySet = new Set<String>();

            for (GetCustomerInfoFromSAP.customerInfo accountVar: ciVarList) {
                //HisenseEntitySet.add(accountVar);
                //处理销售办公室等lookup字段的值
                salesOfficeExtIdList.add(accountVar.CompanyList[0] + '_' + accountVar.SalesOffice);
                salesGroupExtIdList.add(accountVar.SalesOffice + '_' + accountVar.SalesGroup);
                storLocationExtIdList.add(accountVar.CompanyList[0] + '_' + accountVar.StorLocation + '_' + 'L');
                sapCodeUsedAllList.add(accountVar.SAPCustomerCode);
                if(accountVar.Billingto != null){
                    payerAndReceiverList.add(accountVar.Billingto);
                }
                if(accountVar.Shppingto != null){
                    payerAndReceiverList.add(accountVar.Shppingto);
                }
                countryList.add(accountVar.ProvinceState+accountVar.CountryCode);
                paymentConditionList.add(accountVar.PaymentCondition);
            }
            
            
            //map sales orgnization to sales region
            for(Mapping__c mpc : [SELECT Id, Mapping_Code__c, Mapping_Description__c FROM Mapping__c where recordType.developername = 'Business_Orgnization_and_Name_Mapping']){
                HisenseEntity2SalesRegionMap.put(mpc.Mapping_Code__c,mpc.Mapping_Description__c);
            }

            //Map sales office
            Map<String,String>  salesOfficeExtId2NameMap = new Map<String,String>();
            for(PickList__c salesOffice : [select id,name,ex_id__c from PickList__c where ex_id__c in: salesOfficeExtIdList]){
                salesOfficeExtId2NameMap.put(salesOffice.ex_id__c,salesOffice.id);
            }

            System.debug('salesOfficeExtId2NameMap   '+salesOfficeExtId2NameMap);

            //Map sales group
            Map<String,String>  salesGroupExtId2NameMap = new Map<String,String>();
            for(PickList__c salesGroup : [select id,name,ex_id__c from PickList__c where ex_id__c in: salesGroupExtIdList]){
                salesGroupExtId2NameMap.put(salesGroup.ex_id__c,salesGroup.id);
            }
            System.debug('salesGroupExtId2NameMap   '+salesGroupExtId2NameMap);

            //Map location
            Map<String,String>  locationExtId2NameMap = new Map<String,String>();
            for(PickList__c location : [select id,name,ex_id__c from PickList__c where ex_id__c in: storLocationExtIdList]){
                locationExtId2NameMap.put(location.ex_id__c,location.id);
            }
            
            System.debug('locationExtId2NameMaplll   '+locationExtId2NameMap);

            if(sapCodeUsedAllList != null){
                for(Account ac : [Select id,SAP_Customer_Code__c from account where SAP_Customer_Code__c in:sapCodeUsedAllList]){
                    sapCodeUsedAll2IdMap.put(ac.SAP_Customer_Code__c,ac.Id);
                }
            }
            if(payerAndReceiverList != null){
                for(Account ac : [Select id,SAP_Customer_Code__c from account where SAP_Customer_Code__c in:payerAndReceiverList]){
                    customerSAPCode2IdMap.put(ac.SAP_Customer_Code__c,ac.Id);
                }
            }
            if(countryList != null){
                for(Country_State__c cs : [Select id,Name__c,ex_id__c from Country_State__c where ex_id__c in:countryList and IsActive__c = true]){
                    countryCode2IdMap.put(cs.ex_id__c,cs.id);
                }
            }
            if(paymentConditionList != null){
                for(Payment_Term__c pt : [Select id,ex_id__c from Payment_Term__c where ex_id__c in:paymentConditionList and IsActive__c = true]){
                    paymentConditionName2IdMap.put(pt.ex_id__c,pt.Id);
                }
            }


            if(prFlag.equals('1')){
                accountList2PayerAndReceiver = new List<GetCustomerInfoFromSAP.customerInfo>();
            }
            Map<String,List<Customer_Tax_category__c>> tempBillingCertificateMap = new Map<String,List<Customer_Tax_category__c>>();
            List<Account> accountList = new List<Account>();
            List<Customer_Tax_category__c> billingCertificateList = new List<Customer_Tax_category__c>();
            //handle senerio 1 (prFlag.equals('1'))
            if(prFlag.equals('1')){
                for (GetCustomerInfoFromSAP.customerInfo account: inputList) {
                    //handle payer & receiver
                    if(customerSAPCode2IdMap.get(account.Billingto) == null || customerSAPCode2IdMap.get(account.Shppingto)== null ){
                        //if billingto or shippingto not existed in salesforce , set account into accountList2PayerAndReceiver
                        accountList2PayerAndReceiver.add(account);
                        continue;
                    }else{
                        judgeInputList.add(account);
                    }
                }
            }
            //handle senerio 1 (prFlag.equals('1'))
            if(prFlag.equals('1')){
                inputList = judgeInputList;
                System.debug('accountList2PayerAndReceiver::;  '+accountList2PayerAndReceiver);
                System.debug('judgeInputList11  '+ prFlag +' '+judgeInputList);
            }

            //handle senerio 2 (prFlag.equals('2'))
            if(prFlag.equals('2')){
                //inputList = ciVarList;
                inputList = prNotSame2SelftList;
                System.debug('prNotSame2SelftList  '+ prFlag +' '+prNotSame2SelftList);
            }

            //handle senerio 3 (prFlag.equals('3'))
            if(prFlag.equals('3')){
                inputList = prSame2SelftList;
                System.debug('prSame2SelftList  '+ prFlag +' '+prSame2SelftList);
            }

            //handle senerio 1 (prFlag.equals('1'))
            if(prFlag.equals('1')){
                if(accountList2PayerAndReceiver != null & !accountList2PayerAndReceiver.isEmpty()){
                    prSame2SelftList = new List<GetCustomerInfoFromSAP.customerInfo>();
                    prNotSame2SelftList = new List<GetCustomerInfoFromSAP.customerInfo>();
                    for(GetCustomerInfoFromSAP.customerInfo accPRVar : accountList2PayerAndReceiver){
                        //区分送达方或售达方相同与不同的情况
                        if(accPRVar.SAPCustomerCode.equals(accPRVar.Billingto) || accPRVar.SAPCustomerCode.equals(accPRVar.Shppingto)){
                            prSame2SelftList.add(accPRVar);
                        }else{
                            prNotSame2SelftList.add(accPRVar);
                        }
                    }
                    System.debug('prSame2SelftList::111  '+prSame2SelftList);
                    System.debug('prNotSame2SelftList::111  '+prNotSame2SelftList);
                    for(GetCustomerInfoFromSAP.customerInfo account : prSame2SelftList){
                        //重新构造送达方或售达方与本身不同的list
                        GetCustomerInfoFromSAP.customerInfo customer = new GetCustomerInfoFromSAP.customerInfo();
                        customer.SFCode = account.SFCode ;
                        customer.SAPCustomerCode = account.SAPCustomerCode ;
                        customer.CustomerGroup = account.CustomerGroup ;
                        customer.CustomerLocalLanguage1 = account.CustomerLocalLanguage1;
                        customer.CustomerLocalLanguage2 = account.CustomerLocalLanguage2;
                        customer.CustomerEnglishLanguage1 = account.CustomerEnglishLanguage1;
                        customer.CustomerEnglishLanguage2 = account.CustomerEnglishLanguage2;
                        customer.Street2 = account.Street2 ;
                        customer.Street3 = account.Street3 ;
                        customer.Street4 = account.Street4;
                        customer.Street5 = account.Street5;
                        customer.ShortName = account.ShortName ;
                        customer.CountryCode = account.CountryCode ;
                        customer.ProvinceState = account.ProvinceState ;
                        customer.City = account.City ;
                        customer.PostalCode = account.PostalCode ;
                        customer.TelephoneNumber = account.TelephoneNumber ;
                        customer.Fax = account.Fax ;
                        customer.TaxNumber1 = account.TaxNumber1 ;
                        customer.TaxNumber2 = account.TaxNumber2 ;
                        customer.VATRegistrationNumber = account.VATRegistrationNumber ;
                        customer.ReconciliatioCustomer = account.ReconciliatioCustomer ;
                        customer.PaymentCondition = account.PaymentCondition ;
                        customer.DistributioChannel = account.DistributioChannel ;
                        customer.SalesOffice = account.SalesOffice ;
                        customer.SalesGroup = account.SalesGroup ;
                        customer.SFCurrency = account.SFCurrency ;
                        customer.PriceList = account.PriceList ;
                        customer.ShippingConditions = account.ShippingConditions ;
                        customer.RelatedtoPOD = account.RelatedtoPOD ;
                        customer.DeliveryPriority = account.DeliveryPriority ;
                        customer.DeliveryingPlant = account.DeliveryingPlant ;
                        customer.LocationNo1 = account.LocationNo1 ;
                        customer.LocationNo2 = account.LocationNo2 ;
                        customer.CheckDigit = account.CheckDigit ;
                        customer.StorLocation = account.StorLocation ;
                        if(customer.SAPCustomerCode.equals(customer.Billingto)){
                            customer.Billingto = null ;
                        }else{
                            customer.Billingto = customer.Billingto ;
                        }
                        if(customer.SAPCustomerCode.equals(customer.Shppingto)){
                            customer.Shppingto = null ;
                        }else{
                            customer.Shppingto = customer.Shppingto ;
                        }
                        //instant customer.CompanyList
                        customer.CompanyList = new List<String>();
                        if(account.CompanyList != null & !account.CompanyList.isEmpty()){
                            for(String company : account.CompanyList){
                                customer.CompanyList.add(company);
                            }
                        }
                        customer.BillingCertificateList = account.BillingCertificateList ;
                        prNotSame2SelftList.add(customer);
                    }
                }

                //对于送达方或者售达方不同的记录，在inputList中remove出来
                if(prNotSame2SelftList != null){
                    for(Integer i = 0 ; i < prNotSame2SelftList.size() ; i++){
                        for(Integer j = 0 ; j < inputList.size() ; j++){
                            if(prNotSame2SelftList[i].SAPCustomerCode.equals(inputList[j].SAPCustomerCode)){
                                inputList.remove(j);
                            }
                        }
                    }
                }
            }
            try {
                if(inputList !=null & !inputList.isEmpty()){
                    //处理input list
                    for (GetCustomerInfoFromSAP.customerInfo account: inputList) {
                        Account customer = new Account();
                        if(sapCodeUsedAll2IdMap.get(account.SAPCustomerCode) == null){
                            //SAP同步过来的记录，都记成SAP
                            customer.AccountSource = 'SAP';
                        }
                        customer.SAP_Customer_Code__c = account.SAPCustomerCode == null ? '': account.SAPCustomerCode;
                        customer.Customer_Group__c = account.CustomerGroup == null ? '': account.CustomerGroup;
                        if(checkGroup2(account.CustomerGroup2)){
                            customer.Customer_Group2__c = account.CustomerGroup2 == null ? '': account.CustomerGroup2;
                        }else {
                            customer.Customer_Group2__c = '';
                            InterfaceLog__c ic = new InterfaceLog__c();
                            ic.Class__c = 'GetCustomerInfoFromSAPGroup';
                            ic.Time__c = System.Now();
                            ic.Req_Json__c = body;
                            ic.Res_Json__c = bodyRes;
                            insert ic;
                        }
                        
                        if(account.CustomerLocalLanguage1 == null){
                            account.CustomerLocalLanguage1 = '';
                        }
                        if(account.CustomerLocalLanguage2 == null){
                            account.CustomerLocalLanguage2 = '';
                        }
                        if(account.CustomerEnglishLanguage1 == null){
                            account.CustomerEnglishLanguage1 = '';
                        }
                        if(account.CustomerEnglishLanguage2 == null){
                            account.CustomerEnglishLanguage2 = '';
                        }
                        if(account.Street2 == null){
                            account.Street2 = '';
                        }
                        if(account.Street3 == null){
                            account.Street3 = '';
                        }
                        if(account.Street4 == null){
                            account.Street4 = '';
                        }
                        if(account.Street5 == null){
                            account.Street5 = '';
                        }

                        customer.Customer_Name_Local_Language__c = account.CustomerLocalLanguage1 + account.CustomerLocalLanguage2;
                        customer.Name = account.CustomerEnglishLanguage1 + account.CustomerEnglishLanguage2;
                        customer.Customer_Short_Name__c = account.ShortName == null ? '': account.ShortName;
                        //SAP过来的客户，在SF中的状态都应该是Approved
                        customer.Approval_Status__c = 'Approved';
                        customer.Address__c = account.Street2 + account.Street3 + account.Street4 + account.Street5;
                        customer.Guarantor_Country_Code__c = account.CountryCode == null ? '': account.CountryCode;
                        customer.Province_State__c = account.ProvinceState == null ? '': countryCode2IdMap.get(account.ProvinceState + account.CountryCode);
                        customer.City__c = account.City == null ? '': account.City;
                        customer.Postal_Code__c = account.PostalCode == null ? '': account.PostalCode;
                        customer.Phone = account.TelephoneNumber == null ? '': account.TelephoneNumber;
                        customer.Fax = account.Fax == null ? '': account.Fax;
                        customer.Tax_Number1__c = account.TaxNumber1 == null ? '': account.TaxNumber1;
                        customer.Tax_Number2__c = account.TaxNumber2 == null ? '': account.TaxNumber2;
                        customer.VAT_Registration_Number__c = account.VATRegistrationNumber == null ? '': account.VATRegistrationNumber;
                        customer.Reconciliation_Customer__c = account.ReconciliatioCustomer == null ? '': account.ReconciliatioCustomer;
                        customer.Payment_Term__c = account.PaymentCondition == null ? '': paymentConditionName2IdMap.get(account.PaymentCondition);
                        customer.Distribution_Channel__c = account.DistributioChannel == null ? '': account.DistributioChannel;
                        customer.Sales_Office__c = account.SalesOffice == null ? '': salesOfficeExtId2NameMap.get(account.CompanyList[0] + '_' + account.SalesOffice);
                        customer.Sales_Group__c = account.SalesGroup == null ? '': salesGroupExtId2NameMap.get(account.SalesOffice + '_' + account.SalesGroup);
                        customer.CurrencyIsoCode = account.SFCurrency == null ? '': account.SFCurrency;
                        customer.Price_List__c = account.PriceList == null ? '': account.PriceList;
                        customer.Shipping_Conditions__c = account.ShippingConditions == null ? '': account.ShippingConditions;
                        if(account.RelatedtoPOD == 'X'){
                            System.debug('aaaaaaa');
                            customer.Related_to_POD__c = True ;
                        }else{
                            customer.Related_to_POD__c = False ;
                        }
                        customer.Delivery_Priority__c = account.DeliveryPriority == null ?  '' : account.DeliveryPriority;
                        customer.Deliverying_Plant__c = account.DeliveryingPlant == null ? '': account.DeliveryingPlant;
                        customer.Location_No_1__c = account.LocationNo1 == null ?  '' : account.LocationNo1;
                        customer.Location_No_2__c = account.LocationNo2 == null ?  '' : account.LocationNo2;
                        customer.Check_Digit__c = Decimal.valueOf(account.CheckDigit) == null ? Decimal.valueOf('') : Decimal.valueOf(account.CheckDigit);
                        customer.Stor_Location__c = account.StorLocation == null ? '': locationExtId2NameMap.get(account.CompanyList[0] + '_' + account.StorLocation + '_' + 'L');
                        if(account.SAPCustomerCode.equals(account.Billingto)){
                            customer.Payer__c = null;
                        }else{
                            customer.Payer__c = account.Billingto == null ? null : customerSAPCode2IdMap.get(account.Billingto);                            
                        }

                        if(account.SAPCustomerCode.equals(account.Shppingto)){
                            customer.Receiver__c = null;
                        }else{
                            customer.Receiver__c = account.Shppingto == null ? null : customerSAPCode2IdMap.get(account.Shppingto);                            
                        }
                        customer.External_Key__c = account.SAPCustomerCode;
                        String companyCodeVar  = '';
                        String companyCodeVarTmp = '';
                        if(account.CompanyList != null){
                            for(String companyVar : account.CompanyList){
                                companyCodeVar = companyVar + ';';
                            }
                            Integer companyCodeVarLength = companyCodeVar.length();
                            String  companyCodeVar1 = companyCodeVar.substring(0,companyCodeVarLength - 1);
                            customer.Hisense_Entity__c = companyCodeVar1;
                            companyCodeVarTmp = companyCodeVar.substring(0,companyCodeVarLength - 1);
                        }else{
                            customer.Hisense_Entity__c = '';
                        }
                        customer.Sales_Region__c = HisenseEntity2SalesRegionMap.get(companyCodeVarTmp);
                        customer.Branch__c = account.name3 == null ? '': account.name3;
                        accountList.add(customer);
                    }
                    system.debug('accountListooiiii '+accountList);
                    Database.UpsertResult[] srList = Database.upsert(accountList , Account.Fields.External_Key__c,false);
                    String errorMessage = '';
                    for (Database.UpsertResult sr : srList) {
                        if (sr.isSuccess()) {
                            // Operation was successful
                        }
                        else {
                            // Operation failed, so get all errors                
                            for(Database.Error err : sr.getErrors()) {
                                errorMessage = errorMessage + err;
                                System.debug('error has occurred.' + err.getStatusCode() + ': ' + err.getMessage());                    
                                System.debug('fields that affected this error: ' + err.getFields());
                            }
                        }
                    }
                    //日志内容
                    InterfaceLog__c ic = new InterfaceLog__c();
                    ic.Class__c = 'GetCustomerInfoFromSAP';
                    ic.Time__c = System.Now();
                    ic.Req_Json__c = body;
                    ic.Res_Json__c = bodyRes;

                    if(errorMessage == ''){
                        ic.ReturnCode__c = '1';
                        ic.ErrorMsg__c = 'Excuted Successfully';
                    }else{
                        ic.ReturnCode__c = '0';
                        ic.ErrorMsg__c = 'Excuted Failed '+ errorMessage;
                    }

                    insert ic;
                    // return;
                                
                    /*
                    //handle tax category and tax classification
                    List<String> accountListSAPCodeList = new List<String>();
                    List<String> accountListIdList = new List<String>();
                    for(Account accnt : accountList){
                        accountListSAPCodeList.add(accnt.SAP_Customer_Code__c);
                    }
                    for(Account accnt : [select Id,SAP_Customer_Code__c from Account where SAP_Customer_Code__c in: accountListSAPCodeList]){
                        accountListIdList.add(accnt.Id);
                    }
                    for (GetCustomerInfoFromSAP.customerInfo account: ciVarList) {
                        if(account.BillingCertificateList[0].TaxCategory != '' &  account.BillingCertificateList[0].TaxClassification != ''){
                            customerSAPALLCodeList.add(account.SAPCustomerCode);
                            for(BillingCertificate billingCertificate : account.BillingCertificateList){
                                taxCategoeryExtIdList.add(billingCertificate.TaxCategory + billingCertificate.TaxClassification);
                            }
                        }
                    }
                    List<Tax_category__c> taxCategoeryList = [select id,Tax_Catagoery_External_Id__c from Tax_category__c where Tax_Catagoery_External_Id__c in: taxCategoeryExtIdList];
                    Map<String,String> taxCaEXTIdAndIdMap = new Map<String,String>();
                    for(Tax_category__c tc: taxCategoeryList){
                        taxCaEXTIdAndIdMap.put(tc.Tax_Catagoery_External_Id__c,tc.Id );
                    }
                    Map<String,String> customerSAPALLCode2IdMap = new Map<String,String>();
                    for(Account aVar : [select id,SAP_Customer_Code__c from Account where SAP_Customer_Code__c in: customerSAPALLCodeList]){
                        customerSAPALLCode2IdMap.put(aVar.SAP_Customer_Code__c,aVar.Id );
                    }
                    List<Customer_Tax_category__c> ctccList = [Select CountryCodeAndCustomerIdF__c,CustomerId__c,id,name,Customer_Tax_Category_External_Id__c,Tax_category_code__c from Customer_Tax_category__c where Customer__c in: accountListIdList ];
                    List<Customer_Tax_category__c> eccList = new List<Customer_Tax_category__c>();
                    for(Customer_Tax_category__c ctcc : ctccList){
                        String extIdFromSF  = ctcc.CountryCodeAndCustomerIdF__c + ctcc.Tax_category_code__c + ctcc.CustomerId__c;
                        for (GetCustomerInfoFromSAP.customerInfo accountVar : inputList) {
                                for(BillingCertificate billingCertificate : accountVar.BillingCertificateList){
                                    if(billingCertificate.TaxCategory != '' & billingCertificate.TaxClassification != ''){
                                    String extIdFromSAP = (accountVar.CountryCode + billingCertificate.TaxCategory +  customerSAPALLCode2IdMap.get(accountVar.SAPCustomerCode)).substring(0,21);
                                    if(extIdFromSF.equals(extIdFromSAP)){
                                        Customer_Tax_category__c ctxca = new Customer_Tax_category__c();
                                        ctxca.Tax_category__c = taxCaEXTIdAndIdMap.get(billingCertificate.TaxCategory + billingCertificate.TaxClassification);
                                        ctxca.Customer_Tax_Category_External_Id__c = extIdFromSF;
                                        eccList.add(ctxca);
                                    }
                                }
                            }
                        }
                    }
                    System.debug('eccList::; '+eccList);
                    Database.upsert(eccList,Customer_Tax_category__c.Fields.Customer_Tax_Category_External_Id__c); 
                    */

                    //handle tax category and tax classification
                    List<String> accountListSAPCodeList = new List<String>();
                    // SAP_Customer_Code__c为key的 客户map
                    Map<String, Account> accMap = new Map<String, Account>();
                    // 要添加的Customer_Tax_category__c集合
                    List<Customer_Tax_category__c> ctcList = new List<Customer_Tax_category__c>();
                    for(Account accnt : accountList){
                        accountListSAPCodeList.add(accnt.SAP_Customer_Code__c);
                    }
                    for(Account accnt : [select Id,SAP_Customer_Code__c from Account where SAP_Customer_Code__c in: accountListSAPCodeList]){
                        accMap.put(accnt.SAP_Customer_Code__c, accnt);
                    }
                    // 遍历input数据 获取Tax_category__c的key
                    for (GetCustomerInfoFromSAP.customerInfo account: inputList) {
                        // 判断Hisense_Entity__c是否有值
                        if(account.CompanyList != null){
                            for(BillingCertificate billingCertificate : account.BillingCertificateList){
                                taxCategoeryExtIdList.add(billingCertificate.TaxCategory + billingCertificate.TaxClassification);
                            }
                        }     
                    }
                    // 查询所有的 Tax_category__c数据
                    List<Tax_category__c> taxCategoeryList = [select id,name,Tax_category__c,Tax_Catagoery_External_Id__c from Tax_category__c where Tax_Catagoery_External_Id__c in: taxCategoeryExtIdList];
                    // 遍历Tax_category__c数据 拼接Tax_Catagoery_External_Id__c为key的map
                    Map<String, String> taxCaEXTIdAndIdMap = new Map<String, String>();
                    for(Tax_category__c tc: taxCategoeryList){
                        taxCaEXTIdAndIdMap.put(tc.Tax_Catagoery_External_Id__c,tc.id);
                    }
                     //获取税分类组织mapping
                    Map<String, TaxCountryMapping__c> countries = TaxCountryMapping__c.getAll();
                    //查询国家税分类
                    List<National_tax_category__c> ntcs= [select id,National_code__c,Tax_category__c,Nationnal_Tax_Catagoery_External_Id__c from National_tax_category__c];
                    Map<String, String> ntcsMap = new Map<String, String>();
                    for (National_tax_category__c ntc : ntcs) {
                        ntcsMap.put(ntc.Nationnal_Tax_Catagoery_External_Id__c,ntc.id);
                    }

                    // 遍历input数据 组合Customer_Tax_category__c
                    for (GetCustomerInfoFromSAP.customerInfo account: inputList) {
                        if(account.BillingCertificateList[0].TaxCategory != '' && account.BillingCertificateList[0].TaxClassification != ''){
                            String companyCodeVar  = '';
                            if(account.CompanyList != null){
                                for(String companyVar : account.CompanyList){
                                    companyCodeVar = companyVar + ';';
                                }
                                Integer companyCodeVarLength = companyCodeVar.length();
                                // Hisense_Entity__c的值
                                String hisenseEntity = companyCodeVar.substring(0,companyCodeVarLength - 1);
                                // 国家缩写
                                String cs = countries.get(hisenseEntity).Country__c;
                                String accId = accMap.get(account.SAPCustomerCode).id;
                                for(BillingCertificate billingCertificate : account.BillingCertificateList){
                                    Customer_Tax_category__c ctxca = new Customer_Tax_category__c();
                                    ctxca.Tax_category__c = taxCaEXTIdAndIdMap.get(billingCertificate.TaxCategory + billingCertificate.TaxClassification);
                                    ctxca.Customer__c = accId;
                                    ctxca.National_tax_category__c = ntcsMap.get(cs + billingCertificate.TaxCategory);
                                    ctxca.Tax_category_code__c = billingCertificate.TaxCategory;
                                    ctxca.Customer_Tax_Category_External_Id__c = accId + billingCertificate.TaxCategory;
                                    ctcList.add(ctxca);
                                }
                            }
                        }
                    }
                    System.debug('ctcList::; '+ctcList);
                    Database.upsert(ctcList,Customer_Tax_category__c.Fields.Customer_Tax_Category_External_Id__c, false); 
                }
            }
            catch (Exception e) {
               //日志内容
                InterfaceLog__c ic = new InterfaceLog__c();
                ic.Class__c = 'GetCustomerInfo';
                ic.Time__c = System.Now();
                ic.ReturnCode__c = '0';
                ic.Req_Json__c = body;
                ic.Res_Json__c = bodyRes;
                ic.ErrorMsg__c = '新建数据出错'+e.getMessage()+ 'Line:  ' +e.getLineNumber() + '    '+e;
                insert ic;
                return; 
            }
            //日志内容
            InterfaceLog__c ic = new InterfaceLog__c();
            ic.Class__c = 'GetCustomerInfo';
            ic.Time__c = System.Now();
            ic.ReturnCode__c = '1';
            ic.Req_Json__c = body;
            ic.Res_Json__c = bodyRes;
            ic.ErrorMsg__c = '';
            insert ic;
        }
    }

    // 验证Customer Group2 是否存在
    private static Boolean checkGroup2(String text){
        Boolean b = false;
        String strObjectName = 'Account';
        String strPicklistField = 'Customer_Group2__c';
        Map<String, String> mapPickListValues = new Map<String, String>();
        Schema.SObjectType objSobjectType = Schema.getGlobalDescribe().get(strObjectName);
        Schema.DescribeSObjectResult objDescribeSobject = objSobjectType.getDescribe();
        Map<String, Schema.SObjectField> mapFields = objDescribeSobject.fields.getMap();
        List<Schema.PicklistEntry> lstPickListValues = mapFields.get(strPicklistField).getDescribe().getPickListValues();
        for (Schema.PicklistEntry objPickList : lstPickListValues) {
            if(objPickList.getValue().equals(text)){
                b = true;
                break;
            }
            // System.debug('Value = ' +objPickList.getValue() +' , Label = ' +objPickList.getLabel());
        }
        return b;
    }

/*
    //sending email notification to operation team once customer created from SAP
    private static void sendingEmail2OperationTeam(List<GetCustomerInfoFromSAP.customerInfo> customerInfoList){
        System.debug('customerInfoListcustomerInfoList:: '+customerInfoList);
        String operationTeamProfileId = [select id,name from Profile where name = 'HQ Operation Team'][0].Id;
        List<User> operationTeamList = [select Id,Name,Email from User where ProfileId =: operationTeamProfileId];
        System.debug('operationTeamProfileId::;; '+operationTeamProfileId);
        System.debug('operationTeamList::;; '+operationTeamList);

        //Email list
        Messaging.SingleEmailMessage[] theEmails = new Messaging.SingleEmailMessage[]{};
        for(GetCustomerInfoFromSAP.customerInfo gcici : customerInfoList){
            for(User operationUser : operationTeamList ){
                Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
                //String emailBody = '<span style="display: inline-block; width:28px;"></span>Dear [' + operationUser.Name + ']，<br/> &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; Below Customer has already been created in SAP, [' + visitParticipant.Visit_Record_Name__c + ']&nbsp;&nbsp;(On &nbsp;&nbsp;&nbsp;[' + visitParticipant.Visit_Date__c + '] ) has already been reached, Please take action in time!';
                String emailBody = '<span style="display: inline-block; width:28px;"></span>Dear [' + operationUser.Name + ']，<br/> &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; CUSTOMER : [' + gcici.SAPCustomerCode + ']&nbsp;&nbsp;&nbsp;&nbsp; Company Code :  [' + gcici.CompanyList[0] + '] &nbsp;&nbsp;&nbsp;&nbsp; has already been created in SAP and synced into CRM, Please Take Notice!';
                mail.setToAddresses(new List<string> {operationUser.Email});
                mail.setSenderDisplayName(Label.Visit_Participant_Email_Display_Name);
                mail.setSubject(Label.Customer_Created_In_SAP_Notification);
                mail.setHtmlBody(emailBody);
                theEmails.add(mail);
            }
        }
        Messaging.Email[] allMails = new Messaging.Email[]{};
        for(Integer j = 0; j < theEmails.size(); j++) {
            allMails.add(theEmails.get(j));
        }

        System.debug('allMails:: '+allMails);
        // Print error information
        Messaging.SendEmailResult[] results = Messaging.sendEmail(allMails);
        Messaging.SendEmailError[] errors = new Messaging.SendEmailError[]{};
        String emailErrorReport = '';
        for(Messaging.SendEmailResult currentResult : results) {
            errors = currentResult.getErrors();
            if(null != errors) {
                for(Messaging.SendEmailError currentError : errors) {
                    emailErrorReport = emailErrorReport + ' (' + currentError.getStatusCode() + ') ' + currentError.getMessage();
                    System.debug(emailErrorReport);
                }
            }
        }
    }

    */
}