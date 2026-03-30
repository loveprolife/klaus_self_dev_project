/*
 * @Author: WFC
 * @Date: 2024-03-19 16:52:43
 * @LastEditors: WFC
 * @LastEditTime: 2024-05-09 14:15:06
 * @Description:
 * @FilePath: \HisenseAll20240426\force-app\main\default\classes\ReportCustomeController.cls
 */
public without sharing class ReportCustomeController{
    @AuraEnabled(cacheable = true)
    public static List<Report_Custom__c> getReportCustomData(){
        return [SELECT Id, Report_Name__c, Last_Update_Time__c, Report_Url__c, Report_Status__c, Batch_Class__c, Disabled__c, Text_Class__c, Parameter__c
                FROM Report_Custom__c
                ORDER BY CreatedDate];
    }

    @AuraEnabled
    public static Boolean updateReportCustom(Report_Custom__c row){
        Savepoint sp = Database.setSavepoint();
        try{
            row.Report_Status__c = 'Updating';
            update row;

            System.debug('wwww---' + row.Parameter__c);

            String batchClassName = row.Batch_Class__c;
            List<String> params = new List<String>();
            // 参数不为空
            if (String.isNotBlank(row.Parameter__c)){
                String parameter = row.Parameter__c;
                params = parameter.split(';');
            }
            if (batchClassName.equals('CustomerProductSalesReportDelBatch')){
                if(params.size() < 2){
                    return false;
                }
                CustomerProductSalesReportDelBatch ss = new CustomerProductSalesReportDelBatch(params[0], params[1]);
                Database.executeBatch(ss);
            } else{
                // 方法根据 Apex Batch 类的名称执行 Batch 方法
                Database.Batchable<Object> batchInstance = (Database.Batchable<Object>)Type.forName(batchClassName).newInstance();
                Database.executeBatch(batchInstance);
            }
            return true;
        } catch (Exception e){
            Database.rollback(sp);
            return false;
        }
    }

}