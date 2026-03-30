public without sharing class MarketInsightController{
    
    @AuraEnabled
    public static ConResponse saveRecord(String recordDataJson, List<String> deleteRecordIdList, String fileMapJson, String recordId){
    	
        System.debug('MarketInsightController ——> saveRecord：');
        System.debug('MarketInsightController ——> recordDataJson：' + recordDataJson);
        ConResponse resp = new ConResponse();
        Map<string, object> mso = new Map<string, object>();

        String objectApiName = Id.valueOf(recordId).getSObjectType().getDescribe().getName();
        if(!((objectApiName == 'Market__c') || (objectApiName == 'Research__c'))) {
            resp.message = 'error recordId type';
            resp.code = -1;
            return resp;
        }

        String reportQueryString = 'SELECT Id, Name, Report_Date__c, Shop__c, Shop__r.Name FROM ' + objectApiName + ' WHERE Id = :recordId';
        List<SObject> reportList = Database.query(reportQueryString);
        if(reportList.size() == 0) {
            resp.message = 'error recordId';
            resp.code = -1;
            return resp;
        }

        Shop__c store = [SELECT Id, Account__c FROM Shop__c WHERE id = :String.valueOf(reportList[0].get('Shop__c'))];
        List<Map<String, String>> dataList = (List<Map<String, String>>)JSON.deserialize(recordDataJson, List<Map<String, String>>.class);
        
        List<MarketInsight__c> insertMarketInsightList = new List<MarketInsight__c>();
        List<MarketInsight__c> updateMarketInsightList = new List<MarketInsight__c>();
        List<MarketInsight__c> deleteMarketInsightList = [SELECT Id FROM MarketInsight__c WHERE Id IN :deleteRecordIdList];
        if(dataList.size() > 0) {
            for(Map<String, String> data : dataList) {
                String dataJson = Json.serialize(data);
                System.debug('dataJson ==> ' + dataJson);
                MarketInsight__c marketInsight = (MarketInsight__c)JSON.deserialize(dataJson, MarketInsight__c.class);
                System.debug('marketInsight ==> ' + marketInsight);
                if(data.containsKey('Id')) {
                	if(data.containsKey('fieldsEdit') && (data.get('fieldsEdit') == 'true')) {
                    	// 修改已有记录
                    	updateMarketInsightList.add(marketInsight);
                	}
                } else {
                	// 新建记录
                	marketInsight.Store__c = String.valueOf(reportList[0].get('Shop__c'));
                	marketInsight.put(objectApiName, recordId);
                    marketInsight.Customer__c = store.Account__c;
                	insertMarketInsightList.add(marketInsight);
                }                 
            }
        }
        System.Savepoint sp = Database.setSavepoint();
        try{  

            if(insertMarketInsightList.size() > 0) {
                insert insertMarketInsightList;

                UploadFilesController.saveFiles(recordDataJson, fileMapJson, insertMarketInsightList, recordId);
            }
            
            if(updateMarketInsightList.size() > 0) {
                update updateMarketInsightList;
            }
            
            if(deleteMarketInsightList.size() > 0) {
                delete deleteMarketInsightList;
            }

            // SELECT Id, Product__c, Name, Brands__c, ProductLine__c, Quantity__c, Sales__c, AveragePrice__c, Store__c, Market__c, Share__c
            //                                             FROM MarketInsight__c 
            //                                             WHERE Market__c = :recordId ORDER BY CreatedDate 
            String recordQueryString = 'SELECT Id, Product__c, Name, Brands__c, ProductLine__c, Quantity__c, Sales__c, AveragePrice__c, Store__c, Share__c, ' + objectApiName;
            recordQueryString += ' FROM MarketInsight__c WHERE ' + objectApiName + ' = :recordId ORDER BY CreatedDate ';
            List<MarketInsight__c> returnList = Database.query(recordQueryString);
            mso.put('recordList', returnList);
            resp.data = mso;
            resp.message = 'Save successfully！';

        }catch (Exception e) {
        	System.debug(LoggingLevel.ERROR, e.getMessage());
        	System.debug(LoggingLevel.ERROR, e.getStackTraceString());
        	Database.rollback(sp);
        	resp.message = e.getMessage() + '\n' + e.getStackTraceString();
        	resp.code = -1;
        }

        return resp;
    }

    @AuraEnabled
    public static ConResponse getInitData(String recordId){
        ConResponse resp = new ConResponse();
        Map<string, object> mso = new Map<string, object>();
        // List<MarketInsight__c> marketInsightList = [SELECT Id, Product__c, Name, Brands__c, ProductLine__c, Share__c,
        //                                                     Quantity__c, Sales__c, AveragePrice__c, Store__c, Market__c
        //                                                 FROM MarketInsight__c 
        //                                                 WHERE Market__c = :recordId ORDER BY CreatedDate ];

        String objectApiName = Id.valueOf(recordId).getSObjectType().getDescribe().getName();
        if(!((objectApiName == 'Market__c') || (objectApiName == 'Research__c'))) {
            resp.message = 'error recordId type';
            resp.code = -1;
            return resp;
        }
        String recordQueryString = 'SELECT Id, Product__c, Name, Brands__c, ProductLine__c, Quantity__c, Sales__c, AveragePrice__c, Store__c, Share__c, ' + objectApiName;
        recordQueryString += ' FROM MarketInsight__c WHERE ' + objectApiName + ' = :recordId ORDER BY CreatedDate ';
        List<MarketInsight__c> marketInsightList = Database.query(recordQueryString);
        mso.put('marketInsightList', marketInsightList);
        mso.put('fields', SObjectHelper.getFieldLabelMap('MarketInsight__c'));

        String userId = UserInfo.getUserId();        
        List<User> currentUser = [SELECT Id, Name, Profile.Name, Email, Sales_Region__c FROM User WHERE Id = :userId ];
        Boolean isChile = (currentUser[0].Sales_Region__c == 'Hisense Chile');
        mso.put('isChile', isChile);
        
        if(marketInsightList.size() == 0) {
            system.debug('null');
            resp.data = mso; 
            return resp;
        }
		resp.data = mso;        
        return resp;
    }

}