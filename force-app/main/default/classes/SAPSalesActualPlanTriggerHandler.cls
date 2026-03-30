/**************************************************************************************************
 * SAPSalesActualPlanTriggerHandler
 * Purpose:SAP Sales Actual Report添加 SAP Sales Actual Plan
 * Author: wfc
 * Create Date: 2020-10-13
***************************************************************************************************/
public class SAPSalesActualPlanTriggerHandler extends TriggerHandler{

    public override void afterInsert(){
        List<SAP_Sales_Actual_Report__c> reportList = new List<SAP_Sales_Actual_Report__c>();
        for(SAP_Sales_Actual_Plan__c sc : ((list<SAP_Sales_Actual_Plan__c>)Trigger.new)){
            if(String.isNotBlank(sc.Customer__c)){
                // 查询所有的SAP Sales Actual Report表赋值上新建的plan数据
                for(SAP_Sales_Actual_Report__c sar : [SELECT ID, Customer__c from SAP_Sales_Actual_Report__c where Customer__c =: sc.Customer__c]){
                    sar.SAP_Sales_Actual_Plan__c = sc.id;
                    reportList.add(sar);
                }
            }
        }
        update reportList;  
    }
    
}