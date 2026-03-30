public with sharing class EcssBankLimitApplicationInfoController {
    public class ResultData {
        public  String  ErrorMessage;
        public  String  Success;
        public  List<fsScanningResultDTO>  Data;
    }

    public class ResultDataObj {
        public  String  ErrorMessage;
        public  String  Success;
        public  fsScanningResultDTO  Data;
    }

    public Class fsScanningResultDTO {   
        public String ecssResult;   
        public String dataSupplierCode;
        public String dataSupplierName;
        public String type;
        public String referenceId;
        public String lawsAndRegulation;
        public String listType;
        public String name;
        public String country;
        public String city;
        public String street;
        public String zip;
        public String matchedResult;
    }

    public Class InitData{
        public List<Ecss_Customer_Info__c> ecssList;
    }

   
    @AuraEnabled 
    public static String initData(String recordId){
        Customer_Banks__c credit = [SELECT Id,Name,Bank_Name__c FROM Customer_Banks__c WHERE Id =: recordId];
        System.debug('通过recordId 参数获取 credit数据' + credit);
        //CreditLimitApplicationRRInfoController.syncAuditInfoFromRRNoFuture(credit.name);
        
        InitData initData = new InitData();        
        initData.ecssList = new List<Ecss_Customer_Info__c>(); 
        initData.ecssList = getEcssInfo(credit.Bank_Name__c);
       
        System.debug('initData==>>>' +initData);

        //getRRInfoIF('LA-00008256');
        return JSON.serialize(initData);
    }

    @AuraEnabled 
    public static String syncData(String recordId){

        Customer_Banks__c credit = [SELECT Id,Bank_Name__c FROM Customer_Banks__c WHERE Id =: recordId];
        System.debug('通过recordId 参数获取 credit数据' + credit);
        //CreditLimitApplicationRRInfoController.syncAuditInfoFromRRNoFuture(credit.name);
        
        InitData initData = new InitData();        
        initData.ecssList = new List<Ecss_Customer_Info__c>(); 
        initData.ecssList = getEcssInfo(credit.Bank_Name__c);
       
        System.debug('syncData==>>>' +initData);

        return JSON.serialize(initData);
    }  

    public static List<Ecss_Customer_Info__c> getEcssInfo(String recordId){
        //String nameParam = '%' + recordId + '%';
        List<Ecss_Customer_Info__c> ecssInfo = new List<Ecss_Customer_Info__c>();        
        ecssInfo = [select id, ecss_result__c,dataSupplierCode__c, dataSupplierName__c, type__c, referenceId__c, lawsAndRegulation__c, 
        listType__c, name__c, country__c, city__c, street__c, zip__c, matchedResult__c,LastModifiedDate from Ecss_Customer_Info__c 
        WHERE Req_Name__c  =: recordId];
        if (!ecssInfo.isEmpty()) {
            Ecss_Customer_Info__c ei = ecssInfo.get(0);
                        
           // 获取对象中的GMT时间字段
           Datetime gmtTime = (Datetime)ei.LastModifiedDate;
            // 获取当前时间
            Datetime currentTime = Datetime.now();
            // 计算时间差（以小时为单位）
            Integer hoursDifference = (Integer)(currentTime.getTime() - gmtTime.getTime()) / (1000 * 60 * 60);
            // 判断时间差是否大于24小时
            Boolean isGreaterThan24Hours = hoursDifference > 24;
            System.debug('Is greater than 24 hours: ' + isGreaterThan24Hours);
            if (isGreaterThan24Hours) {
                System.debug('24h==>刷新数据');
                GetCustomerInfoFromECSS.GetBankInfoFromECSS(recordId);
            }

        } else {
            System.debug('第一次获取数据');
            List<Ecss_Customer_Info__c> ecssInfoFromApi = GetCustomerInfoFromECSS.getBankInfoFromEcssApi(recordId);
            System.debug('实际数据的量SIZE' +  ecssInfoFromApi.size());
            if (ecssInfoFromApi.size() > 0) {            
                Database.upsert(ecssInfoFromApi,Ecss_Customer_Info__c.Fields.ExternalID__C,false);
                ecssInfo = ecssInfoFromApi;
            } else {
                Ecss_Customer_Info__c m = new Ecss_Customer_Info__c();
                m.Req_Name__c = recordId;
                m.ExternalID__c = recordId;
                m.ecss_result__c = 'ECSS Scan Result Passed';
                ecssInfo.add(m);    
                Database.upsert(ecssInfo, Ecss_Customer_Info__c.Fields.ExternalID__C,false);
            }
        }
        return ecssInfo;
    }

}