/**********************************************************************
* Name: InitAttendanceInformationBatch 
* Object: Promoter_Attendance__c
* Purpose: 系统每天自动生成每个巡店员/促销员的考勤空数
* Author: WFC
* Create Date: 2022-04-01
* 执行方法 Database.executeBatch(new InitAttendanceInformationBatch('2022-04-01'),200);
*************************************************************************/
public class InitAttendanceInformationBatch implements Database.Batchable<sObject> {

    public Date thisDay;
    // 巡店员简档
    public String inspectionProfile;
    // 促销员简档
    public String promoterProfile;

    public InitAttendanceInformationBatch (String thisDay) {
        this.inspectionProfile = Label.Inspection_Profile;
        this.promoterProfile = Label.Promoter_Profile;
        this.thisDay = Date.valueOf(thisDay);
    }
    public Database.QueryLocator start(Database.BatchableContext bc) {
        return Database.getQueryLocator('SELECT Id,Profile.name FROM User WHERE Profile.name =:inspectionProfile OR Profile.name =:promoterProfile');
    }
    public void execute(Database.BatchableContext BC, List<User> userList) {
        // 今天促销员和巡店员考勤类型
        Set<String> externalIdSet = new Set<String>();
        Map<String, Boolean> hadMap = new Map<String, Boolean>();
        String year1 =  thisDay.year() + '';
        String month1 =  thisDay.month() + '';
        // 当前日期api 例：X10__c
        String dayField =  'X' + thisDay.day() + '__c';
        for (User u : userList) {
            externalIdSet.add(u.id + '_' + year1 + '_' + month1);
        }
        String sql = 'SELECT OwnerId, '+ dayField +' FROM Hope_Attendance_Day__c WHERE ExternalId__c = :externalIdSet';
        List<Hope_Attendance_Day__c> hadList =  Database.query(sql);
        for(Hope_Attendance_Day__c had : hadList){
            hadMap.put(had.OwnerId, Boolean.valueOf(had.get(dayField)));
        }
        

        // 考勤初始化
        List<Promoter_Attendance__c> promoterAttendanceAddList = new List<Promoter_Attendance__c>();
        for (User u : userList) {
            Promoter_Attendance__c paItem = new Promoter_Attendance__c();
            if(String.isNotBlank(u.Profile.name) && u.Profile.name.equals(inspectionProfile)){
                paItem.RecordTypeId = Schema.SObjectType.Promoter_Attendance__c.getRecordTypeInfosByDeveloperName().get('InspectorAttendace').getRecordTypeId();
            }else {
                paItem.RecordTypeId = Schema.SObjectType.Promoter_Attendance__c.getRecordTypeInfosByDeveloperName().get('PromoterAttendance').getRecordTypeId();
            }
            
            paItem.OwnerId = u.id;
            paItem.CheckIn_Date__c = thisDay;
            paItem.ExternalId__c = u.id + '_' + String.valueOf(paItem.CheckIn_Date__c);
            if(hadMap.get(u.id) != null && hadMap.get(u.id)){
                paItem.Attendance_Type__c = '休息日';
            }else {
                paItem.Attendance_Type__c = '出勤日';
            }
           
            promoterAttendanceAddList.add(paItem);
        }

        Database.upsert(promoterAttendanceAddList, Promoter_Attendance__c.ExternalId__c, false);
    }
    public void finish(Database.BatchableContext BC) {

    }

}