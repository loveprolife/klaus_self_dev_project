/*
 * @Author: WFC
 * @Date: 2026-03-30 12:21:37
 * @LastEditors: WFC
 * @LastEditTime: 2026-03-30 18:16:01
 * @Description: 一个个查询coface未完成订单，获取最新状态和文件信息
 * @FilePath: \testuat\force-app\main\default\classes\CofaceQnqueueJobOneByOne.cls
 */
public with sharing class CofaceQnqueueJobOneByOne implements Queueable, Database.AllowsCallouts {
    // The list of records to upsert one-by-one (serialized across queue transactions)
    private List<Coface_Report__c> records;
    // Zero-based index of the next record to process in the list
    private Integer index;


    public CofaceQnqueueJobOneByOne(List<Coface_Report__c> records, Integer index) {
        this.records = records;
        this.index = (index == null || index < 0) ? 0 : index;
    }

    public void execute(QueueableContext qc) {
        if (records == null || records.isEmpty()) {
            Utility.insertLog('CofaceQnqueueJobOneByOne', '1', '', '订单数据为空');
            return;
        }
        if (index >= records.size()) {
            Utility.insertLog('CofaceQnqueueJobOneByOne', '1', '', 'QnqueueJob订单更新完成');
            return;
        }
        // 当前订单数据
        Coface_Report__c cofaceReport = records[index];
        String reportId = cofaceReport.Id + '';
        try {
            // 查询订单接口
            Map<String, Object> resultMap = CofaceModuleController.getOrderDataByReportId('', reportId);
            if((Boolean)resultMap.get('isSuccess')){
                Utility.insertLog('CofaceQnqueueJobOneByOne', '1', JSON.serialize(cofaceReport), '查询订单接口成功');
            }else {
                Utility.insertLog('CofaceQnqueueJobOneByOne', '0', JSON.serialize(cofaceReport), '查询订单接口失败成功');
            }
        } catch (Exception ex) {
            Utility.insertLog('CofaceQnqueueJobOneByOne', '0', JSON.serialize(cofaceReport), '查询订单接口或文件接口失败成功');
        }

        Integer nextIndex = index + 1;
        if (nextIndex < records.size()) {
            System.enqueueJob(new CofaceQnqueueJobOneByOne(records, nextIndex));
        }
    }
}