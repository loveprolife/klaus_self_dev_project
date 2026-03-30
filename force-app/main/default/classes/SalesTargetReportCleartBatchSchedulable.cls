/*
 * @Author: WFC
 * @Date: 2024-04-11 16:28:44
 * @LastEditors: WFC
 * @LastEditTime: 2024-04-11 16:29:45
 * @Description: 东盟报表定时任务
 * @FilePath: \hisenseall-231026\force-app\main\default\classes\SalesTargetReportCleartBatchSchedulable.cls
 */
global class SalesTargetReportCleartBatchSchedulable implements Schedulable {
    global void execute(SchedulableContext sc) {
        SalesTargetReportClearBatch ss  = new SalesTargetReportClearBatch();
        Database.executeBatch(ss);
    }
}