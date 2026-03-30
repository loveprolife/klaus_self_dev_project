public without sharing class PromoterShareController {

    @AuraEnabled
    public static ConResponse saveRecord(String recordDataJson, List<String> deleteRecordIdList, String fileMapJson, String recordId, String recordTypeId){
    	
        System.debug('PromoterShareController ——> saveRecord：');
        System.debug('PromoterShareController ——> recordDataJson：' + recordDataJson);

        ConResponse resp = new ConResponse();
        Map<string, object> mso = new Map<string, object>();

        String objectApiName = Id.valueOf(recordId).getSObjectType().getDescribe().getName();
        if(!((objectApiName == 'Market__c') || (objectApiName == 'Research__c'))) {
            resp.message = 'error recordId type';
            resp.code = -1;
            return resp;
        }

        // SELECT Id, Name, Report_Date__c, Shop__c, Shop__r.Name FROM Market__c WHERE Id = :recordId
        String reportQueryString = 'SELECT Id, Name, Report_Date__c, Shop__c, Shop__r.Name FROM ' + objectApiName + ' WHERE Id = :recordId';
        List<SObject> reportList = Database.query(reportQueryString);
        if(reportList.size() == 0) {
            resp.message = 'error recordId';
            resp.code = -1;
            return resp;
        }

        Shop__c store = [SELECT Id, Account__c FROM Shop__c WHERE Id = :String.valueOf(reportList[0].get('Shop__c'))];
        
        List<Map<String, String>> dataList = (List<Map<String, String>>)JSON.deserialize(recordDataJson, List<Map<String, String>>.class);
        
        List<PromoterShare__c> insertPromoterShareList = new List<PromoterShare__c>();
        List<PromoterShare__c> updatePromoterShareList = new List<PromoterShare__c>();
        List<PromoterShare__c> deletePromoterShareList = [SELECT Id FROM PromoterShare__c WHERE Id IN :deleteRecordIdList];
        
        if(dataList.size() > 0) {
            for(Map<String, String> data : dataList) {
                String dataJson = Json.serialize(data);
                System.debug('dataJson ==> ' + dataJson);
                PromoterShare__c promoterShare = (PromoterShare__c)JSON.deserialize(dataJson, PromoterShare__c.class);
                System.debug('promoterShare ==> ' + promoterShare);
                if(data.containsKey('Id')) {
                    if(data.containsKey('fieldsEdit') && (data.get('fieldsEdit') == 'true')) {
                        // 修改已有记录
                        System.debug('PromoterShareController ——> saveRecord ——> edit rPecord！');
                        updatePromoterShareList.add(promoterShare);
                    }
                } else {
                    // 新建记录
                    System.debug('PromoterShareController ——> saveRecord ——> new record！');
                    promoterShare.Store__c = String.valueOf(reportList[0].get('Shop__c'));
                    promoterShare.put(objectApiName, recordId);
                    promoterShare.recordTypeId = recordTypeId;
                    promoterShare.Customer__c = store.Account__c;
                    insertPromoterShareList.add(promoterShare);
                }                   
            }
        }
        System.Savepoint sp = Database.setSavepoint();
        try{  
            if(insertPromoterShareList.size() > 0) {
                System.debug('PromoterShareController ——> insertPromoterShareList.size()：' + insertPromoterShareList.size());
                insert insertPromoterShareList;
                UploadFilesController.saveFiles(recordDataJson, fileMapJson, insertPromoterShareList, recordId);
            }
            
            if(updatePromoterShareList.size() > 0) {
                System.debug('PromoterShareController ——> updatePromoterShareList.size()：' + updatePromoterShareList.size());
                update updatePromoterShareList;
            }
            
            if(deletePromoterShareList.size() > 0) {
                delete deletePromoterShareList;
            }

            // List<PromoterShare__c> promoterShareList = [SELECT Id, Name, Market__c, Brands__c, Store__c, ProductLine__c, Stock__c, Shelf__c, HisenseFlag__c, Comment__c
            //                                                     FROM PromoterShare__c 
            //                                                     WHERE Market__c = :recordId AND recordTypeId =: recordTypeId ORDER BY CreatedDate ];
            String recordQueryString = 'SELECT Id, Name, Brands__c, Store__c, ProductLine__c, Stock__c, Shelf__c, HisenseFlag__c, Comment__c, ' + objectApiName;
            recordQueryString += ' FROM PromoterShare__c WHERE ' + objectApiName + ' = :recordId AND recordTypeId =: recordTypeId ORDER BY CreatedDate ';
            List<PromoterShare__c> promoterShareList = Database.query(recordQueryString);
            
            Map<String, List<PromoterShare__c>> promoterShareGroupByProductLine = new Map<String, List<PromoterShare__c>>();
            for(PromoterShare__c item : promoterShareList){
                system.debug('item :' + item);
                if(promoterShareGroupByProductLine.containsKey(item.ProductLine__c)) {
                    promoterShareGroupByProductLine.get(item.ProductLine__c).add(item);
                    system.debug('containsKey ——> promoterShareGroupByProductLine :' + promoterShareGroupByProductLine);
                } else {
                    promoterShareGroupByProductLine.put(item.ProductLine__c, new List<PromoterShare__c>{item});
                    system.debug('not containsKey ——> promoterShareGroupByProductLine :' + promoterShareGroupByProductLine);
                }
            }
            mso.put('promoterShareGroupByProductLine', promoterShareGroupByProductLine);

            mso.put('recordList', promoterShareList);
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
    public static ConResponse getInitData(String recordId, String recordTypeName){
        system.debug('recordTypeName：' + recordTypeName);
        ConResponse resp = new ConResponse();
        Map<string, object> mso = new Map<string, object>();

        String objectApiName = Id.valueOf(recordId).getSObjectType().getDescribe().getName();
        if(!((objectApiName == 'Market__c') || (objectApiName == 'Research__c'))) {
            resp.message = 'error recordId type';
            resp.code = -1;
            return resp;
        }

        List<Brand__c> hisense = [SELECT Id, Name FROM Brand__c WHERE Name = 'Hisense' ORDER BY CreatedDate];
        String hisenseId = hisense.size() > 0 ? String.valueOf(hisense[0].Id) : '';
        mso.put('hisenseId', hisenseId);

        List<RecordType> recordTypeList = [SELECT Id, DeveloperName, SobjectType FROM RecordType WHERE SobjectType= 'PromoterShare__c'];
        for(RecordType item : recordTypeList) {
            mso.put(item.DeveloperName, item.Id);
        }

        // List<PromoterShare__c> promoterShareList = [SELECT Id, Name, Market__c, Brands__c, Store__c, ProductLine__c, Stock__c, Shelf__c, HisenseFlag__c, Comment__c
        //                                                 FROM PromoterShare__c 
        //                                                 WHERE Market__c = :recordId AND RecordType.Name =: recordTypeName ORDER BY CreatedDate ];
        String recordQueryString = 'SELECT Id, Name, Brands__c, Store__c, ProductLine__c, Stock__c, Shelf__c, HisenseFlag__c, Comment__c, ' + objectApiName;
        recordQueryString += ' FROM PromoterShare__c WHERE ' + objectApiName + ' = :recordId AND RecordType.Name =: recordTypeName ORDER BY CreatedDate ';
        List<PromoterShare__c> promoterShareList = Database.query(recordQueryString);
        mso.put('promoterShareList', promoterShareList);
        mso.put('fields', SObjectHelper.getFieldLabelMap('PromoterShare__c'));
        if(promoterShareList.size() == 0) {
            system.debug('null');
            resp.data = mso; 
            return resp;
        }
        
        Map<String, List<PromoterShare__c>> promoterShareGroupByProductLine = new Map<String, List<PromoterShare__c>>();
        for(PromoterShare__c item : promoterShareList){
            system.debug('item :' + item);
            if(promoterShareGroupByProductLine.containsKey(item.ProductLine__c)) {
                promoterShareGroupByProductLine.get(item.ProductLine__c).add(item);
                system.debug('containsKey ——> promoterShareGroupByProductLine :' + promoterShareGroupByProductLine);
            } else {
                promoterShareGroupByProductLine.put(item.ProductLine__c, new List<PromoterShare__c>{item});
                system.debug('not containsKey ——> promoterShareGroupByProductLine :' + promoterShareGroupByProductLine);
            }
        }
        mso.put('promoterShareGroupByProductLine', promoterShareGroupByProductLine);
        system.debug('promoterShareGroupByProductLine：' + promoterShareGroupByProductLine);

		resp.data = mso;        
        return resp;
    }

}