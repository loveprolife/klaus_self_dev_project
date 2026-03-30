/**************************************************************************************************
 * SAPSalesActualTriggerHandler
 * Purpose:SAP Sales Actual Report创建
 * Author: wfc
 * Create Date: 2020-10-12
***************************************************************************************************/
public class SAPSalesActualTriggerHandler extends TriggerHandler{
    public override void afterInsert(){
        List<SAP_Sales_Actual_Report__c> sarList = new List<SAP_Sales_Actual_Report__c>();

        // 查询所有的SAP Sales Actual plan数据
        Map<String, SAP_Sales_Actual_plan__c> planMap = new Map<String,SAP_Sales_Actual_plan__c>();
        for(SAP_Sales_Actual_plan__c sap : [SELECT ID, Customer__c from SAP_Sales_Actual_plan__c order by LastModifiedDate desc]){
            if(!planMap.containsKey(sap.Customer__c)){
                planMap.put(sap.Customer__c,sap);
            }
        }
        //创建SAP Sales Actual Report表
        for(SAP_Sales_Actual__c sc : ((list<SAP_Sales_Actual__c>)Trigger.new)){
            if(String.isNotBlank(sc.Customer__c)){
                SAP_Sales_Actual_Report__c sar = new SAP_Sales_Actual_Report__c();
                sar.SAP_Sales_Actual__c = sc.id;
                sar.Customer__c = sc.Customer__c;
                // 判断Requested Delivery Date 是否是当月之后的
                if(sc.Required_Delivery_Date__c != null){
                    if(isCurrentMonth(sc.Required_Delivery_Date__c)){
                        sar.Flag__c = '1';
                    }
                }
                if(planMap.get(sc.Customer__c) != null){
                    sar.SAP_Sales_Actual_Plan__c = planMap.get(sc.Customer__c).id;
                }
                sarList.add(sar);
            }
        }
        Database.insert(sarList);
    }

    //判断传进来的日期是否为 当月之后 （传入为Date/time格式）,当月之后为false
    public Boolean isCurrentMonth(DateTime dataDateTime) {
        Boolean isCurrentMonthFlag  = false;
        // 下一个月一号
        Datetime addMonth = System.now().addMonths(1);
        Date nextMonth = Date.newinstance(addMonth.year(), addMonth.month(), 1);
        // 参数日期
        Date myDate = Date.newinstance(dataDateTime.year(), dataDateTime.month(), dataDateTime.day());
        if(myDate < nextMonth){
            isCurrentMonthFlag = true;
        }

        return isCurrentMonthFlag;
    }
    
}