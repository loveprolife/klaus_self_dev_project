public without sharing class ConsumerTraitResearchController {
    @AuraEnabled
    public static ConResponse saveRecord(String recordDataJson, List<String> deleteRecordIdList, String recordId){
    	
        System.debug('ConsumerTraitResearchController ——> saveRecord：');
        System.debug('ConsumerTraitResearchController ——> recordDataJson：' + recordDataJson);
        ConResponse resp = new ConResponse();
        Map<string, object> mso = new Map<string, object>();

        String objectApiName = Id.valueOf(recordId).getSObjectType().getDescribe().getName();
        if(!((objectApiName == 'Market__c') || (objectApiName == 'Research__c'))) {
            resp.message = 'error recordId type';
            resp.code = -1;
            return resp;
        }

        // SELECT Id, Name, Report_Date__c, Shop__c, Shop__r.Name FROM Research__c WHERE Id = :recordId
        String reportQueryString = 'SELECT Id, Name, Report_Date__c, Shop__c, Shop__r.Name FROM ' + objectApiName + ' WHERE Id = :recordId';
        List<SObject> reportList = Database.query(reportQueryString);
        if(reportList.size() == 0) {
            resp.message = 'error recordId';
            resp.code = -1;
            return resp;
        }


        Shop__c store = [SELECT Id, Account__c FROM Shop__c WHERE Id = :String.valueOf(reportList[0].get('Shop__c'))];

        List<Map<String, String>> dataList = (List<Map<String, String>>)JSON.deserialize(recordDataJson, List<Map<String, String>>.class);
        
        List<ConsumerTraitResearch__c> insertConsumerTraitResearchList = new List<ConsumerTraitResearch__c>();
        List<ConsumerTraitResearch__c> updateConsumerTraitResearchList = new List<ConsumerTraitResearch__c>();
        List<ConsumerTraitResearch__c> deleteConsumerTraitResearchList = [SELECT Id FROM ConsumerTraitResearch__c WHERE Id IN :deleteRecordIdList];
        
        if(dataList.size() > 0) {
            for(Map<String, String> data : dataList) {
                String dataJson = Json.serialize(data);
                System.debug('dataJson ==> ' + dataJson);
                ConsumerTraitResearch__c consumerTraitResearch = (ConsumerTraitResearch__c)JSON.deserialize(dataJson, ConsumerTraitResearch__c.class);
                System.debug('consumerTraitResearch ==> ' + consumerTraitResearch);
                
                if(data.containsKey('Id')) {
                	if(data.containsKey('fieldsEdit') && (data.get('fieldsEdit') == 'true')) {
                    	// 修改已有记录
                    	updateConsumerTraitResearchList.add(consumerTraitResearch);
                	}
                } else {
                	// 新建记录
                	consumerTraitResearch.Store__c = String.valueOf(reportList[0].get('Shop__c'));
                	consumerTraitResearch.put(objectApiName, recordId);
                    consumerTraitResearch.Customer__c = store.Account__c;
                	insertConsumerTraitResearchList.add(consumerTraitResearch);
                }          
            }
        }
        System.Savepoint sp = Database.setSavepoint();
        try{  

            if(insertConsumerTraitResearchList.size() > 0) {
                insert insertConsumerTraitResearchList;
            }
            
            if(updateConsumerTraitResearchList.size() > 0) {
                update updateConsumerTraitResearchList;
            }
            
            if(deleteConsumerTraitResearchList.size() > 0) {
                delete deleteConsumerTraitResearchList;
            }

            // List<ConsumerTraitResearch__c> consumerTraitResearchList = [SELECT Id, Name,No__c, Gender__c, Race__c, Age__c, Occupation__c, Product__c, IncomeBracket__c, 
            //                                                                 DateOfPurchase__c, ReceiveNewsletter__c, eMailAddress__c, Store__c, Quantity__c, UnitPrice__c, Research__c
            //                                                             FROM ConsumerTraitResearch__c
            //                                                             WHERE Research__c = :recordId ORDER BY CreatedDate ];
            String recordQueryString = 'SELECT Id, Name,No__c, Gender__c, Race__c, Age__c, Occupation__c, Product__c, IncomeBracket__c, ';
            recordQueryString += 'DateOfPurchase__c, ReceiveNewsletter__c, eMailAddress__c, Store__c, Quantity__c, UnitPrice__c, ' + objectApiName;
            recordQueryString += ' FROM ConsumerTraitResearch__c WHERE ' + objectApiName + ' = :recordId ORDER BY CreatedDate ';
            List<ConsumerTraitResearch__c> consumerTraitResearchList = Database.query(recordQueryString);
                                                                        
            mso.put('consumerTraitResearchList', consumerTraitResearchList);
            Map<String, List<ConsumerTraitResearch__c>> researchListGroupByNo = researchListGroupByNo(consumerTraitResearchList);
            mso.put('researchListGroupByNo', researchListGroupByNo);
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
        mso.put('reportDate', Date.valueOf(reportList[0].get('Report_Date__c')));
        
        // List<ConsumerTraitResearch__c> consumerTraitResearchList = [SELECT Id, Name,No__c, Gender__c, Race__c, Age__c, Occupation__c, Product__c, IncomeBracket__c, 
        //                                                                     DateOfPurchase__c, ReceiveNewsletter__c, eMailAddress__c, Store__c, Quantity__c, UnitPrice__c, Research__c
        //                                                                 FROM ConsumerTraitResearch__c
        //                                                                 WHERE Research__c = :recordId ORDER BY CreatedDate ];
        String recordQueryString = 'SELECT Id, Name,No__c, Gender__c, Race__c, Age__c, Occupation__c, Product__c, IncomeBracket__c, ';
        recordQueryString += 'DateOfPurchase__c, ReceiveNewsletter__c, eMailAddress__c, Store__c, Quantity__c, UnitPrice__c, ' + objectApiName;
        recordQueryString += ' FROM ConsumerTraitResearch__c WHERE ' + objectApiName + ' = :recordId ORDER BY CreatedDate ';
        List<ConsumerTraitResearch__c> consumerTraitResearchList = Database.query(recordQueryString);

        mso.put('consumerTraitResearchList', consumerTraitResearchList);
        mso.put('fields', SObjectHelper.getFieldLabelMap('ConsumerTraitResearch__c'));
        if(consumerTraitResearchList.size() == 0) {
            system.debug('null');
            resp.data = mso; 
            return resp;
        }

        Map<String, List<ConsumerTraitResearch__c>> researchListGroupByNo = researchListGroupByNo(consumerTraitResearchList);
        mso.put('researchListGroupByNo', researchListGroupByNo);
        system.debug('researchListGroupByNo：' + researchListGroupByNo);
		resp.data = mso;        
        return resp;
    }

    static Map<String, List<ConsumerTraitResearch__c>> researchListGroupByNo(List<ConsumerTraitResearch__c> consumerTraitResearchList) {
        Map<String, List<ConsumerTraitResearch__c>> researchListGroupByNo = new Map<String, List<ConsumerTraitResearch__c>>();
        for(ConsumerTraitResearch__c item : consumerTraitResearchList){
            system.debug('item :' + item);
            if(researchListGroupByNo.containsKey(item.No__c)) {
                researchListGroupByNo.get(item.No__c).add(item);
                system.debug('containsKey ——> researchListGroupByNo :' + researchListGroupByNo);
            } else {
                researchListGroupByNo.put(item.No__c, new List<ConsumerTraitResearch__c>{item});
                system.debug('not containsKey ——> researchListGroupByNo :' + researchListGroupByNo);
            }
        }
        return researchListGroupByNo;
    }
}