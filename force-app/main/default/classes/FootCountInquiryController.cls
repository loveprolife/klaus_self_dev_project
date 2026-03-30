public without sharing class FootCountInquiryController extends BaseActionController {
    @AuraEnabled
    public static ConResponse saveRecord(String recordDataJson, String recordId){
    	
        System.debug('FootCountInquiryController ——> saveRecord：');
        System.debug('FootCountInquiryController ——> recordDataJson：' + recordDataJson);

        ConResponse resp = new ConResponse();
        Map<string, object> mso = new Map<string, object>();
        
        Research__c research = (Research__c) first([SELECT Id, Name, Report_Date__c, Shop__c, Shop__r.Name FROM Research__c WHERE Id = :recordId]);
        if(research == null) {
            resp.message = 'error recordId';
            resp.code = -1;
            return resp;
        }
        
        Shop__c store = [SELECT Id, Account__c FROM Shop__c WHERE Id = :research.Shop__c];
        
        List<Map<String, String>> dataList = (List<Map<String, String>>)JSON.deserialize(recordDataJson, List<Map<String, String>>.class);

        List<FootCountInquiry__c> upsertFootCountInquiryList = new List<FootCountInquiry__c>();

        if(dataList.size() > 0) {
            for(Map<String, String> data : dataList) {
                String dataJson = Json.serialize(data);
                System.debug('dataJson ==> ' + dataJson);
                FootCountInquiry__c footCountInquiry = (FootCountInquiry__c)JSON.deserialize(dataJson, FootCountInquiry__c.class);
                System.debug('footCountInquiry ==> ' + footCountInquiry);
         
                if(data.containsKey('fieldsEdit') && (data.get('fieldsEdit') == 'true')) {
                    if(!data.containsKey('Id')){
                        footCountInquiry.Store__c = research.Shop__c;
                        footCountInquiry.Research__c = recordId;
                        footCountInquiry.Customer__c = store.Account__c;
                    }
                    upsertFootCountInquiryList.add(footCountInquiry);
                }
                
            }
        }
        
        System.Savepoint sp = Database.setSavepoint();
        try{  
            if(upsertFootCountInquiryList.size() > 0) {
                upsert upsertFootCountInquiryList;
            }
                    
        }catch (Exception e) {
        	System.debug(LoggingLevel.ERROR, e.getMessage());
        	System.debug(LoggingLevel.ERROR, e.getStackTraceString());
        	Database.rollback(sp);
        	//mso.put('message', e.getMessage());
        	resp.message = e.getMessage() + '\n' + e.getStackTraceString();
        	resp.code = -1;
        }
        return resp;
    }

    @AuraEnabled
    public static ConResponse getInitData(String recordId){
        ConResponse resp = new ConResponse();
        Map<string, object> mso = new Map<string, object>();

        List<FootCountInquiry__c> footCountInquiryList = [SELECT Id, Name, Store__c, Research__c, Question1__c, Question2__c, Question3__c, Question4__c, Question5__c, Question6__c
                                                            FROM FootCountInquiry__c
                                                            WHERE Research__c = :recordId];
        mso.put('footCountInquiryList', footCountInquiryList);
        mso.put('fields', SObjectHelper.getFieldLabelMap('FootCountInquiry__c'));
        if(footCountInquiryList.size() == 0) {
            system.debug('null');
            resp.data = mso;
            return resp;
        }
		resp.data = mso;        
        return resp;
    }
}