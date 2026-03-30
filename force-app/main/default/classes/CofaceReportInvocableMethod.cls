/*
 * @Author: WFC
 * @Date: 2026-03-24 09:51:17
 * @LastEditors: WFC
 * @LastEditTime: 2026-03-27 15:21:58
 * @Description: 新建coface报告后，如果是即时订单则查询报告数据
 * @FilePath: \testuat\force-app\main\default\classes\CofaceReportInvocableMethod.cls
 */
public without sharing class CofaceReportInvocableMethod {
    @InvocableMethod
    public static void CofaceReportInvocableMethod(List<String> reportIdList){
        System.enqueueJob(new CofaceReportReadyJob(reportIdList[0]));
    }
}