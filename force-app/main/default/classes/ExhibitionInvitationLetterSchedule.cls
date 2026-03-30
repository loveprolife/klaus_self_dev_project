/**************************************************************************************************
 * Name: ExhibitionInvitationLetterSchedule
 * Object: ExpoApplyInfo__c
 * Purpose: 展会开始前N天给展会下的所有参展客户发送邀请函 90天 只执行一次
 * ************************************************************************************************
 * History
 * --------
 * VERSION     AUTHOR              DATE            DETAIL             Description
 * 1.0          Ethan             2023-08-08         Created        
 
***************************************************************************************************/

global class ExhibitionInvitationLetterSchedule implements Schedulable {
    global void execute(SchedulableContext sc) {
        ExhibitionInvitationLetterBatch eb = new ExhibitionInvitationLetterBatch();
        Database.executeBatch(eb, 80);
    }
}