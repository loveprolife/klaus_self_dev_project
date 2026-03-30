/**
 * @description       : 促销员日报, 出样检查, 巡店任务, 考勤根据门店共享
 * @author            : chenpeng@deloitte.com.cn
 * @group             : 
 * @last modified on  : 05-11-2022
 * @last modified by  : chenpeng@deloitte.com.cn
**/
global withOut sharing class PositionShare_One_Hour_Schedulable implements Schedulable {
    global void execute(SchedulableContext sc) {

        //计划下次任务
        if (!Test.isRunningTest()) {
            Utility.setNextSchedulable('PositionShare_One_Hour_Schedulable', 60);
        }

        //促销员日报
        Share_Common_IntegrationBatch promoterDailyReportBatch = new Share_Common_IntegrationBatch(
            'Promoter_Daily_Report__c', 
            false, 
            '',
            0,
            ''
        );
        Database.executeBatch(promoterDailyReportBatch, 30);

        //出样检查
        Share_Common_IntegrationBatch samplingInspectionBatch = new Share_Common_IntegrationBatch(
            'Sampling_Inspection__c', 
            false, 
            '',
            0,
            ''
        );
        Database.executeBatch(samplingInspectionBatch, 30);
            
        //巡店任务(Inspection_Shop_Task__c)Batch, 此任务finish制定下一次运行时间, 将此任务放置最后一个
        Share_Common_IntegrationBatch inspectionShopTaskBatch = new Share_Common_IntegrationBatch(
            'Inspection_Shop_Task__c', 
            false, 
            '',
            60,
            ''
        );
        Database.executeBatch(inspectionShopTaskBatch, 30);

        //考勤
        Share_Common_IntegrationBatch promoterAttendanceBatch = new Share_Common_IntegrationBatch(
            'Promoter_Attendance__c', 
            false, 
            '',
            60,
            ''
        );
        Database.executeBatch(promoterAttendanceBatch, 30);
    }
}