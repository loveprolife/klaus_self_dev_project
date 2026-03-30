public with sharing class NewDailySalesSellInController {
    
    /**
     * @description 获取初始化数据
     * @param   recordId 记录id
     * @return  返回数据
     */
    @AuraEnabled
    public static ConResponse getInitData(String recordId){
        System.debug('recordId=' + recordId);
        ConResponse resp = new ConResponse();
        try {
            Map<String,Object> mso = new Map<String,Object>();
            List<Daily_Sales_Sell_In__c> recordList = [SELECT Id, Name, Number__c, Price__c, Product__c, Product__r.Name, TotalPrice__c
                                            FROM Daily_Sales_Sell_In__c 
                                            WHERE Daily_Inspection_Report__c = :recordId
                                            ORDER BY Name];
            mso.put('recordList', recordList);
            mso.put('fields', SObjectHelper.getFieldLabelMap('Daily_Sales_Sell_In__c'));
            resp.data = mso;
        } catch (Exception e) {
            System.debug(e.getMessage());
            System.debug(e.getStackTraceString());
            resp.code = -1;
            resp.message = 'error';
            resp.message = e.getMessage() + '\n' + e.getStackTraceString();
        }

        return resp;
    }

    /**
     * @description 保存数据
     * @param   recordListJson 数据json字符串 
     * @param   recordId        上级数据id
     * @param   fileMapJson     附件列表
     * @param   deleteIds       删除的id
     * @return  返回数据
     */
    @AuraEnabled
    public static ConResponse saveData(String recordListJson, String recordId, String fileMapJson, String[] deleteIds){
        System.debug('recordListJson=' + recordListJson);
        System.debug('recordId=' + recordId);
        System.debug('fileMapJson=' + fileMapJson.length());
        System.debug('deleteIds=' + deleteIds);
        ConResponse resp = new ConResponse();
        try {
            Database.delete(deleteIds, false);
            
            List<Daily_Sales_Sell_In__c> taskList = (List<Daily_Sales_Sell_In__c>)JSON.deserialize(recordListJson, List<Daily_Sales_Sell_In__c>.class);
            
            upsert taskList;
            System.debug('taskList=========>' + taskList);
            if(!Test.isRunningTest()){
                UploadFilesController.saveFiles(recordListJson, fileMapJson, taskList, recordId);
            }
            
            taskList = [SELECT Id, Name, Number__c, Price__c, Product__c, Product__r.Name, TotalPrice__c
                    FROM Daily_Sales_Sell_In__c 
                    WHERE Daily_Inspection_Report__c = :recordId
                    ORDER BY Name];
            Map<String, Object> mso = new Map<String, Object>();
            mso.put('recordList', taskList);
            System.debug('recordList=========>' + taskList);
            resp.data = mso;
        } catch (Exception e) {
            System.debug(e.getMessage());
            System.debug(e.getStackTraceString());
            resp.code = -1;
            resp.message = 'error';
            resp.message = e.getMessage() + '\n' + e.getStackTraceString();
        }

        return resp;
    }

}