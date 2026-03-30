public without sharing class PromoCourtController {
    
    @AuraEnabled
    public static ConResponse saveRecord(String recordDataJson, List<String> deleteRecordIdList, String fileMapJson, String recordId){

        System.debug('PromoCourtController ——> saveRecord : ');

    	ConResponse resp = new ConResponse();
        Map<string, object> mso = new Map<string, object>();

        String objectApiName = Id.valueOf(recordId).getSObjectType().getDescribe().getName();
        if(!((objectApiName == 'Market__c') || (objectApiName == 'Research__c'))) {
            resp.message = 'error recordId type';
            resp.code = -1;
            return resp;
        }

        // SELECT Id, Name, Report_Date__c, Shop__c, Shop__r.Name FROM Market__c WHERE Id = :recordId
        String reportQueryString = 'SELECT Id, Name, Report_Date__c, Shop__c FROM ' + objectApiName + ' WHERE Id = :recordId';
        List<SObject> reportList = Database.query(reportQueryString);
        if(reportList.size() == 0) {
            resp.message = 'error recordId';
            resp.code = -1;
            return resp;
        }
        
        Shop__c store = [SELECT Id, Account__c FROM Shop__c WHERE Id = :String.valueOf(reportList[0].get('Shop__c'))];

        List<Map<String, String>> dataList = (List<Map<String, String>>)JSON.deserialize(recordDataJson, List<Map<String, String>>.class);
        
        List<PromoCourt__c> insertPromoCourtList = new List<PromoCourt__c>();
        List<PromoCourt__c> updatePromoCourtList = new List<PromoCourt__c>();
        List<PromoCourt__c> deletePromoCourtList = [SELECT Id FROM PromoCourt__c WHERE Id IN :deleteRecordIdList];

        
        if(dataList.size() > 0) {
            for(Map<String, String> data : dataList) {
                String dataJson = Json.serialize(data);
                System.debug('dataJson ==> ' + dataJson);
                PromoCourt__c promoCourt = (PromoCourt__c)JSON.deserialize(dataJson, PromoCourt__c.class);
                System.debug('promoCourt ==> ' + promoCourt);
                if(data.containsKey('Id')) {
                    if(data.containsKey('fieldsEdit') && (data.get('fieldsEdit') == 'true')) {
                        // 修改已有记录
                        updatePromoCourtList.add(promoCourt);
                    }
                } else {
                    // 新建记录
                    promoCourt.Store__c = String.valueOf(reportList[0].get('Shop__c'));
                    promoCourt.put(objectApiName, recordId);
                    promoCourt.Customer__c = store.Account__c;
                    insertPromoCourtList.add(promoCourt);
                }                   
            }
        }
        
        System.Savepoint sp = Database.setSavepoint();
        try{  

            if(insertPromoCourtList.size() > 0) {
                System.debug('insertPromoCourtList.size() : ' + insertPromoCourtList.size());
                insert insertPromoCourtList;

                UploadFilesController.saveFiles(recordDataJson, fileMapJson, insertPromoCourtList, recordId);
            }
            
            if(updatePromoCourtList.size() > 0) {
                System.debug('updatePromoCourtList.size() : ' + updatePromoCourtList.size());
                update updatePromoCourtList;
            }

            if(deletePromoCourtList.size() > 0) {
                delete deletePromoCourtList;
            }

            // List<PromoCourt__c> returnList = [SELECT Id, Brands__c, PromoCourtBulk__c, Store__c, Market__c, HisenseFlag__c, Comment__c
            //                                             FROM PromoCourt__c 
            //                                             WHERE Market__c = :recordId ORDER BY CreatedDate ];
            String recordQueryString = 'SELECT Id, Brands__c, PromoCourtBulk__c, Store__c, HisenseFlag__c, Comment__c, ' + objectApiName;
            recordQueryString += ' FROM PromoCourt__c WHERE ' + objectApiName + ' = :recordId ORDER BY CreatedDate ';
            List<PromoCourt__c> returnList = Database.query(recordQueryString);
            
            mso.put('recordList', returnList);
            resp.data = mso;
            resp.message = 'Save successfully！';

        }catch (Exception e) {
        	System.debug(LoggingLevel.ERROR, e.getMessage());
        	System.debug(LoggingLevel.ERROR, e.getStackTraceString());
        	Database.rollback(sp);
        	// resp.message = 'Failed to save！';
            resp.message = e.getMessage() + '\n' + e.getStackTraceString();
        	resp.code = -1;
        }

        return resp;

    }

    @AuraEnabled
    public static ConResponse getInitData(String recordId){
        ConResponse resp = new ConResponse();
        Map<string, object> mso = new Map<string, object>();
        List<Brand__c> hisense = [SELECT Id, Name FROM Brand__c WHERE Name = 'Hisense' ORDER BY CreatedDate];
        String hisenseId = hisense.size() > 0 ? String.valueOf(hisense[0].Id) : '';
        mso.put('hisenseId', hisenseId);
        // List<PromoCourt__c> promoCourtList = [SELECT Id, Brands__c, PromoCourtBulk__c, Store__c, Market__c, HisenseFlag__c, Comment__c
        //                                                 FROM PromoCourt__c 
        //                                                 WHERE Market__c = :recordId ORDER BY CreatedDate ];
        
        String objectApiName = Id.valueOf(recordId).getSObjectType().getDescribe().getName();
        if(!((objectApiName == 'Market__c') || (objectApiName == 'Research__c'))) {
            resp.message = 'error recordId type';
            resp.code = -1;
            return resp;
        }
        String recordQueryString = 'SELECT Id, Brands__c, PromoCourtBulk__c, Store__c, HisenseFlag__c, Comment__c, ' + objectApiName;
        recordQueryString += ' FROM PromoCourt__c WHERE ' + objectApiName + ' = :recordId ORDER BY CreatedDate ';
        List<PromoCourt__c> promoCourtList = Database.query(recordQueryString);
        mso.put('promoCourtList', promoCourtList);

        mso.put('fields', SObjectHelper.getFieldLabelMap('PromoCourt__c'));
        if(promoCourtList.size() == 0) {
            system.debug('null');
            resp.data = mso; 
            return resp;
        }
		resp.data = mso; 
        system.debug('mso.keyset()：' + mso.keyset());       
        return resp;
    }    

}