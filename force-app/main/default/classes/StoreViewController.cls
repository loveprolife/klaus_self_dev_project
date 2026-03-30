public without sharing class StoreViewController {

    @AuraEnabled
    public static ConResponse saveRecord(String recordDataJson, List<String> deleteRecordIdList, String recordId, String fileMapJson){
    	
        System.debug('StoreViewController ——> saveRecord : ');
        System.debug('StoreViewController ——> recordDataJson : ' + recordDataJson);

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

        Shop__c store = [SELECT Id, Account__c FROM Shop__c WHERE Id = :String.valueOf(reportList[0].get('Shop__c'))];
        List<Map<String, String>> dataList = (List<Map<String, String>>)JSON.deserialize(recordDataJson, List<Map<String, String>>.class);

        List<StoreView__c> insertStoreViewList = new List<StoreView__c>();
        List<StoreView__c> updateStoreViewList = new List<StoreView__c>();
        List<StoreView__c> deleteStoreViewList = [SELECT Id FROM StoreView__c WHERE Id IN :deleteRecordIdList];

        if(dataList.size() > 0) {
            for(Map<String, String> data : dataList) {
                String dataJson = Json.serialize(data);
                System.debug('dataJson ==> ' + dataJson);
                StoreView__c storeView = (StoreView__c)JSON.deserialize(dataJson, StoreView__c.class);
                System.debug('storeView ==> ' + storeView);
                if(data.containsKey('Id')) {
                    if(data.containsKey('fieldsEdit') && (data.get('fieldsEdit') == 'true')) {
                        // 修改已有记录
                        updateStoreViewList.add(storeView);
                    }
                } else {
                    // 新建记录
                    // storeView.Store__c = market.Shop__c;
                    storeView.put(objectApiName, recordId);
                    storeView.Customer__c = store.Account__c;
                    insertStoreViewList.add(storeView);
                }
            }
        }
        
        System.Savepoint sp = Database.setSavepoint();
        try{  
            if(insertStoreViewList.size() > 0) {
                insert insertStoreViewList;
                UploadFilesController.saveFiles(recordDataJson, fileMapJson, insertStoreViewList, recordId);
            }
            
            if(updateStoreViewList.size() > 0) {
                update updateStoreViewList;
            }
            
            if(deleteStoreViewList.size() > 0) {
                delete deleteStoreViewList;
            }
            
            // SELECT Id, Name, Store__c, Comments__c, Market__c FROM StoreView__c WHERE Market__c = :recordId ORDER BY CreatedDate 
            String recordQueryString = 'SELECT Id, Name, Store__c, Comments__c, ' + objectApiName + ' FROM StoreView__c WHERE ' + objectApiName + ' = :recordId ORDER BY CreatedDate ';
            List<StoreView__c> returnList = Database.query(recordQueryString);
            mso.put('recordList', returnList);
            resp.data = mso;
            resp.message = 'Save successfully！';
                    
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
        
        // Market__c market = [SELECT Id, Name, Report_Date__c, Shop__c, Shop__r.Name, OwnerId FROM Market__c WHERE Id = :recordId];
        String objectApiName = Id.valueOf(recordId).getSObjectType().getDescribe().getName();
        if(!((objectApiName == 'Market__c') || (objectApiName == 'Research__c'))) {
            resp.message = 'error recordId type';
            resp.code = -1;
            return resp;
        }

        String reportQueryString = 'SELECT Id, Name, Report_Date__c, Shop__c, OwnerId FROM ' + objectApiName + ' WHERE Id = :recordId';
        List<Sobject> report = Database.query(reportQueryString);
        if(report.size() == 0) {
            resp.message = 'error recordId';
            resp.code = -1;
            return resp;
        }
        mso.put('storeId', report[0].get('Shop__c'));
        mso.put('reportDate', report[0].get('Report_Date__c'));

        mso.put('fields', SObjectHelper.getFieldLabelMap('StoreView__c'));

        // SELECT Id, Name, Store__c, Comments__c, Market__c FROM StoreView__c WHERE Market__c = :recordId ORDER BY CreatedDate
        String recordQueryString = 'SELECT Id, Name, Store__c, Comments__c, ' + objectApiName + ' FROM StoreView__c WHERE ' + objectApiName + ' = :recordId ORDER BY CreatedDate ';
        List<StoreView__c> storeViewList = Database.query(recordQueryString);
        mso.put('storeViewList', storeViewList);

        List<Map<String, String>> temp = new List<Map<String, String>>();
        Map<String, String> storeIdAndNameMap = new Map<String, String>();
        String promoterId = String.valueOf(report[0].get('OwnerId'));
        List<Responsible_Person__c> resList = [SELECT Principal__c, Shop_Name__c, Shop_Name__r.Name 
                                                FROM Responsible_Person__c 
                                                WHERE Principal__c = :promoterId AND RecordType__c = '促销员' ];

        for(Responsible_Person__c item : resList) {
            temp.add(new Map<String, String>{
                'label' => item.Shop_Name__r.Name,
                'value' => item.Shop_Name__c
            });
            storeIdAndNameMap.put(item.Shop_Name__c, item.Shop_Name__r.Name);
        }
        mso.put('storeOptions', temp);
        mso.put('storeIdAndNameMap', storeIdAndNameMap);

        if(storeViewList.size() == 0) {
            system.debug('null');
            resp.data = mso;
            return resp;
        }

		resp.data = mso;        
        return resp;
    }

}