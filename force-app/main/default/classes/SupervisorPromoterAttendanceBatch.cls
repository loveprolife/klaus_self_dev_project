/*
 * @Author: WFC
 * @Date: 2025-03-28 15:49:30
 * @LastEditors: WFC
 * @LastEditTime: 2025-04-01 10:37:04
 * @Description: Supervisor_Promoter_Attandance__c 关联考勤
 SupervisorPromoterAttendanceBatch ss  = new SupervisorPromoterAttendanceBatch('Hisense Mexico');
 Database.executeBatch(ss);
 * @FilePath: \hisense005\force-app\main\default\classes\SupervisorPromoterAttendanceBatch.cls
 */
global class SupervisorPromoterAttendanceBatch implements Database.Batchable<sObject>{
    public String query;
    public String salesRegion;
    global SupervisorPromoterAttendanceBatch(String salesRegion){
        this.salesRegion = salesRegion;
        this.query = 'SELECT Id, Statistical_Date__c, Promoter__c, Attendance__c, Supervisor_Store__r.Store__c FROM Supervisor_Promoter_Attendance__c WHERE Sales_Region__c =:salesRegion ';
    }

    global Database.QueryLocator start(Database.BatchableContext bc){
        return Database.getQueryLocator(query);
    }

    global void execute(Database.BatchableContext BC, List<Supervisor_Promoter_Attendance__c> spaList){
        // Attendance 外键set集合
        Set<String> attendanceKeySet = new Set<String>();
        // 促销员考勤 map
        Map<String, Promoter_Attendance__c> promoterAttendanceMap = new Map<String, Promoter_Attendance__c>();
        for (Supervisor_Promoter_Attendance__c spa : spaList){
            String key = spa.Promoter__c + '_' + String.valueOf(spa.Statistical_Date__c);
            attendanceKeySet.add(key);
        }
        // 查询促销员考勤表
        List<Promoter_Attendance__c> paList = [SELECT ID, ExternalId__c, OwnerId, Shop__c
                                               FROM Promoter_Attendance__c
                                               WHERE ExternalId__c IN:attendanceKeySet];
        for (Promoter_Attendance__c pa : paList){
            promoterAttendanceMap.put(pa.ExternalId__c, pa);
        }

        // Supervisor_Promoter_Attandance__c 关联 促销员考勤表
        for (Supervisor_Promoter_Attendance__c spa : spaList){
            String key = spa.Promoter__c + '_' + String.valueOf(spa.Statistical_Date__c);
            spa.Have_Attendance__c = false;
            if (promoterAttendanceMap.get(key) != null ){
                Promoter_Attendance__c pa = promoterAttendanceMap.get(key);
                spa.Attendance__c = pa.Id;
                spa.Have_Attendance__c = true;
            }
        }

        Database.update (spaList);
    }

    global void finish(Database.BatchableContext BC){
    }

}