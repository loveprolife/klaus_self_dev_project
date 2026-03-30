/**************************************************************************************************
 * Name: ExhibitionRemindInternalFillArrSchedule
 * Object: Exhibition_Arrangement__c
 * Purpose: 每天定时提醒未填写行程信息的用户填写                行程信息-参展员工
 * ************************************************************************************************
 * History
 * --------
 * VERSION     AUTHOR              DATE            DETAIL             Description
 * 1.0          Ethan             2023-11-17         Created      
 
***************************************************************************************************/
global class ExhibitionRemindInternalFillArrSchedule implements Schedulable {
    global void execute(SchedulableContext sc) {
         ExhibitionRemindInternalFillArrBatch eb = new ExhibitionRemindInternalFillArrBatch();
        Database.executeBatch(eb, 80);
    }
}