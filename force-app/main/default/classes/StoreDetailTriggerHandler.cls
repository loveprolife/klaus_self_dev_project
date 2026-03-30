/*
 * @Author: WFC
 * @Date: 2024-12-19 10:49:53
 * @LastEditors: WFC
 * @LastEditTime: 2024-12-24 09:09:50
 * @Description: Store Detail Trigger
 * @FilePath: \hisense005\force-app\main\default\classes\StoreDetailTriggerHandler.cls
 */
public class StoreDetailTriggerHandler implements Triggers.Handler{
    public void handle(){
        if (Trigger.isAfter && (Trigger.isInsert || Trigger.isUpdate)){
            for (Store_Detail__c sd : ((list<Store_Detail__c>)Trigger.new )){
                // customer类型
                if (sd.Sample_Display_Task_Level__c != 'Store'){
                    if (!(sd.Sample_Display_Approval_Status__c == 'Submitted' && (sd.Sample_Display_Path__c == 'Start' || sd.Sample_Display_Path__c == 'Sample Task' || sd.Sample_Display_Path__c == 'Split Task'))){
                        sd.addError(System.label.Store_Detail_Is_Locked); // 不在store detail节点不能处理store detail
                        return;
                    }
                }

            }
        }

        if (Trigger.isBefore && Trigger.isDelete){
            for (Store_Detail__c sd : ((list<Store_Detail__c>)Trigger.old)){
                // customer类型
                if (sd.Sample_Display_Task_Level__c != 'Store'){
                    if (!(sd.Sample_Display_Approval_Status__c == 'Submitted' && (sd.Sample_Display_Path__c == 'Start' || sd.Sample_Display_Path__c == 'Sample Task' || sd.Sample_Display_Path__c == 'Split Task'))){
                        sd.addError(System.label.Store_Detail_Is_Locked); // 不在store detail节点不能处理store detail
                        return;
                    }
                }
            }
        }
    }

}