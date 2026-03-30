/**************************************************************************************************
 * CreditLimitApplicationTriggerHandler
 * Purpose:CreditLimitApplicationTrigger处理逻辑
 * Author: wfc
 * Create Date: 2022-04-01
***************************************************************************************************/
public without sharing class HopeAttendanceDayTriggerHandler implements Triggers.Handler{

    public void handle() {

        if (Trigger.isBefore && (Trigger.isInsert || Trigger.isUpdate)) {
            for (Hope_Attendance_Day__c had : (List<Hope_Attendance_Day__c>)Trigger.new) {
                // 希望出勤日 用户+年+月唯一值
                had.ExternalId__c = had.OwnerId + '_' + had.Year__c + '_' + had.Month__c;
            }   
        }
        
    }
}