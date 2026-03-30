public without sharing class NewSamplingDetailController{
    @AuraEnabled
    public static ConResponse saveRecord(String recordId, String recordListJson){

        System.debug('recordId：' + recordId);
        ConResponse resp = new ConResponse();
        Map<string, object> mso = new Map<string, object>();


        System.Savepoint sp = Database.setSavepoint();
        try{
            List<Shop__c> stores = [SELECT Account__c
                                    FROM Shop__c
                                    WHERE Id = :recordId];
            if (stores[0].Account__c == null){
                resp.message = 'error store';
                resp.code = -1;
                return resp;
            } else{
                // List<Sampling_Standard__c> standards = [SELECT Id
                //                                             FROM Sampling_Standard__c
                //                                             WHERE Channel_Name__c = : stores[0].Account__c AND Is_Add_ByReport__c = true];
                // String standardId = '';
                // if(standards.size() == 0) {
                //     Sampling_Standard__c newStandard = new Sampling_Standard__c();
                //     newStandard.Channel_Name__c = stores[0].Account__c;
                //     newStandard.Is_Add_ByReport__c = true;

                //     insert newStandard;
                //     standardId = newStandard.Id;
                // } else {
                //     standardId = standards[0].Id;
                // }
                Sampling_Detail__c detail = (Sampling_Detail__c) JSON.deserialize(recordListJson, Sampling_Detail__c.class);
                // detail.Sampling_Standard__c = standardId;
                detail.AutomaticallyGenerateSampleStandard__c = true;

                system.debug('....' + detail);

                insert detail;

                resp.message = 'Success';
            }

        } catch (Exception e){
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

        System.debug('recordId：' + recordId);
        ConResponse resp = new ConResponse();
        Map<string, object> mso = new Map<string, object>();
        Shop__c store = [SELECT Id, Sales_Region__c
                         FROM Shop__c
                         WHERE Id = :recordId
                         LIMIT 1];
        mso.put('Store', store);
        resp.data = mso;
        return resp;
    }

    @AuraEnabled
    public static ConResponse selectDisplayType(String shopId, String productId){
        ConResponse resp = new ConResponse();
        Map<string, object> mso = new Map<string, object>();
        try{
            // 查询产品信息
            Product__c product = [SELECT Id, Name, Product_Line__c
                                  FROM Product__c
                                  WHERE Id = :productId
                                  LIMIT 1];
            // 查询Store Product Line表
            List<Store_Product_Line__c> storeProductLineList = [SELECT Id, Display_Type__c
                                                                FROM Store_Product_Line__c
                                                                WHERE Store__c = :shopId AND Product_Line__c = :product.Product_Line__c];
            if (storeProductLineList != null && storeProductLineList.size() > 0){
                Store_Product_Line__c spl = storeProductLineList[0];
                mso.put('DisplayType', spl.Display_Type__c.split(';'));
            } else{
                mso.put('DisplayType', null);
                resp.code = -1;
                resp.message = 'No associated Display Type found!';
            }
        } catch (Exception e){
            System.debug(LoggingLevel.ERROR, e.getMessage());
            System.debug(LoggingLevel.ERROR, e.getStackTraceString());
            resp.message = e.getMessage() + '\n' + e.getStackTraceString();
            resp.code = -1;
        }
        resp.data = mso;
        return resp;
    }

}