/*
 * @Author: WFC
 * @Date: 2026-03-30 11:15:14
 * @LastEditors: WFC
 * @LastEditTime: 2026-03-30 18:25:30
 * @Description: 查询coface所有未完成状态，更新数据
 * @FilePath: \testuat\force-app\main\default\classes\CofaceGetOrderStatusController.cls
 */
public without sharing class CofaceGetOrderStatusController{
    @InvocableMethod
    public static void CofaceGetOrderStatusController(){
        // 查询所有未完成的coface订单
        List<Coface_Report__c> cofaceReportList = [SELECT Id, Monitorable__c, Order_Report_Id__c, Status__c
                                                   FROM Coface_Report__c
                                                   WHERE Status__c NOT IN ('ready', 'monitoring_active') AND Status__c != 'cancelled'];
        // 一个个查询coface接口，查看订单是否完成，下载订单数据
        System.enqueueJob(new CofaceQnqueueJobOneByOne(cofaceReportList, 0));
    }

}