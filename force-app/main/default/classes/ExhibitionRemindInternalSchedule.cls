/**************************************************************************************************
 * Name: ExhibitionRemindInternalSchedule
 * Object: Internal_Registration__c
 * Purpose: 展会进行过程中每天9点发送邮件提醒所有参展员工，提交交付物
 * ************************************************************************************************
 * History
 * --------
 * VERSION     AUTHOR              DATE            DETAIL             Description
 * 1.0          Ethan             2023-08-08         Created        
 
***************************************************************************************************/
global class ExhibitionRemindInternalSchedule implements Schedulable {
    global void execute(SchedulableContext sc) {
        ExhibitionRemindInternalBatch eb = new ExhibitionRemindInternalBatch();
        Database.executeBatch(eb, 80);
    }
}