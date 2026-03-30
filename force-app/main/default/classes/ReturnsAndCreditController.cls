public without sharing class ReturnsAndCreditController {
    @AuraEnabled
    public static ConResponse saveRecord(String recordDataJson, List<String> deleteRecordIdList, String fileMapJson, String recordId){
    	
        System.debug('ReturnsAndCreditController ——> saveRecord：');
        System.debug('ReturnsAndCreditController ——> recordDataJson：' + recordDataJson);
        ConResponse resp = new ConResponse();
        Map<string, object> mso = new Map<string, object>();
        Promoter_Daily_Report__c promoterReport = [SELECT Id, Name, Report_Date__c, Shop__c, Shop__r.Name FROM Promoter_Daily_Report__c WHERE Id = :recordId];
        Shop__c store = [SELECT Id, Account__c FROM Shop__c WHERE Id = :promoterReport.Shop__c];

        List<Map<String, String>> dataList = (List<Map<String, String>>)JSON.deserialize(recordDataJson, List<Map<String, String>>.class);
        
        List<ReturnsAndCredit__c> insertReturnsAndCreditList = new List<ReturnsAndCredit__c>();
        List<ReturnsAndCredit__c> updateReturnsAndCreditList = new List<ReturnsAndCredit__c>();
        List<ReturnsAndCredit__c> deleteReturnsAndCreditList = [SELECT Id FROM ReturnsAndCredit__c WHERE Id IN :deleteRecordIdList];
        
        if(dataList.size() > 0) {
            for(Map<String, String> data : dataList) {
                String dataJson = Json.serialize(data);
                System.debug('dataJson ==> ' + dataJson);
                ReturnsAndCredit__c returnsAndCredit = (ReturnsAndCredit__c)JSON.deserialize(dataJson, ReturnsAndCredit__c.class);
                System.debug('returnsAndCredit ==> ' + returnsAndCredit);
                if(data.containsKey('Id')) {
                	if(data.containsKey('fieldsEdit') && (data.get('fieldsEdit') == 'true')) {
                    	// 修改已有记录
                    	updateReturnsAndCreditList.add(returnsAndCredit);
                	}
                } else {
                	// 新建记录
                	returnsAndCredit.Store__c = promoterReport.Shop__c;
                	returnsAndCredit.PromoterDailyReport__c = recordId;
                    returnsAndCredit.Customer__c = store.Account__c;
                	insertReturnsAndCreditList.add(returnsAndCredit);
                }                 
            }
        }
        System.Savepoint sp = Database.setSavepoint();
        try{  

            if(insertReturnsAndCreditList.size() > 0) {
                insert insertReturnsAndCreditList;

                UploadFilesController.saveFiles(recordDataJson, fileMapJson, insertReturnsAndCreditList, recordId);
            }
            
            if(updateReturnsAndCreditList.size() > 0) {
                update updateReturnsAndCreditList;
            }
            
            if(deleteReturnsAndCreditList.size() > 0) {
                delete deleteReturnsAndCreditList;
            }

            List<ReturnsAndCredit__c> returnsAndCreditList = [SELECT Id, Name, UserFeedbackSources__c, Description__c, ReturnedQuantity__c, Product__c, 
                                                                        Quantity__c, Reason__c, Comments__c, ProvideJobNumber__c, Store__c, PromoterDailyReport__c, 
                                                                        ProvideCreditNumber__c, IsAllPaperworkInOrder__c, WhatPaperworkIsMissing__c 
                                                                    FROM ReturnsAndCredit__c
                                                                    WHERE PromoterDailyReport__c = :recordId ORDER BY CreatedDate ];
            Map<String, List<ReturnsAndCredit__c>> researchListGroupByNo = researchListGroupByNo(returnsAndCreditList);
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

        Promoter_Daily_Report__c promoterReport = [SELECT Id, Name, Report_Date__c, Shop__c, Shop__r.Name FROM Promoter_Daily_Report__c WHERE Id = :recordId];
        mso.put('reportDate', promoterReport.Report_Date__c);
        
        List<ReturnsAndCredit__c> returnsAndCreditList = [SELECT Id, Name, UserFeedbackSources__c, Description__c, ReturnedQuantity__c, Product__c, 
                                                                    Quantity__c, Reason__c, Comments__c, ProvideJobNumber__c, Store__c, PromoterDailyReport__c,
                                                                    ProvideCreditNumber__c, IsAllPaperworkInOrder__c, WhatPaperworkIsMissing__c 
                                                                FROM ReturnsAndCredit__c
                                                                WHERE PromoterDailyReport__c = :recordId ORDER BY CreatedDate ];
        mso.put('returnsAndCreditList', returnsAndCreditList);
        mso.put('fields', SObjectHelper.getFieldLabelMap('ReturnsAndCredit__c'));
        if(returnsAndCreditList.size() == 0) {
            system.debug('null');
            resp.data = mso; 
            return resp;
        }

        Map<String, List<ReturnsAndCredit__c>> researchListGroupByNo = researchListGroupByNo(returnsAndCreditList);
        mso.put('researchListGroupByNo', researchListGroupByNo);
        system.debug('researchListGroupByNo：' + researchListGroupByNo);
		resp.data = mso;        
        return resp;
    }

    static Map<String, List<ReturnsAndCredit__c>> researchListGroupByNo(List<ReturnsAndCredit__c> returnsAndCreditList) {
        Map<String, List<ReturnsAndCredit__c>> researchListGroupByNo = new Map<String, List<ReturnsAndCredit__c>>();
        for(ReturnsAndCredit__c item : returnsAndCreditList){
            system.debug('item :' + item);
            if(researchListGroupByNo.containsKey(item.Name)) {
                researchListGroupByNo.get(item.Name).add(item);
                system.debug('containsKey ——> researchListGroupByNo :' + researchListGroupByNo);
            } else {
                researchListGroupByNo.put(item.Name, new List<ReturnsAndCredit__c>{item});
                system.debug('not containsKey ——> researchListGroupByNo :' + researchListGroupByNo);
            }
        }
        return researchListGroupByNo;
    }
}