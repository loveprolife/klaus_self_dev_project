public with sharing class NewCompetitorsInformationController {
    
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
            List<Competitors_Information__c> recordList = [SELECT Product_line__c, Demo_Video__c, Brand__c, Display_Status__c, Quantity_Of_Exhibits__c, Display_Stand__c, POP__c, Id, Name, Daily_Inspection_Report__c
                                            FROM Competitors_Information__c 
                                            WHERE Daily_Inspection_Report__c = :recordId
                                            ORDER BY Name];
            mso.put('recordList', recordList);
            mso.put('fields', SObjectHelper.getFieldLabelMap('Competitors_Information__c'));
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
            
            List<Competitors_Information__c> taskList = (List<Competitors_Information__c>)JSON.deserialize(recordListJson, List<Competitors_Information__c>.class);
            
            upsert taskList;
            System.debug('taskList=========>' + taskList);
            // if(!Test.isRunningTest()){
            //     UploadFilesController.saveFiles(recordListJson, fileMapJson, taskList, recordId);
            // }
            
            taskList = [SELECT Product_line__c, Demo_Video__c,Brand__c, Display_Status__c, Quantity_Of_Exhibits__c, Display_Stand__c, POP__c, Id, Name, Daily_Inspection_Report__c
                            FROM Competitors_Information__c 
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