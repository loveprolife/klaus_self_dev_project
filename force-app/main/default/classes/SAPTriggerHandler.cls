/*
 * @Author: WFC
 * @Date: 2024-12-23 15:38:09
 * @LastEditors: WFC
 * @LastEditTime: 2024-12-24 09:26:47
 * @Description: SAP trigger handler
 * @FilePath: \hisense005\force-app\main\default\classes\SAPTriggerHandler.cls
 */
public class SAPTriggerHandler implements Triggers.Handler{
    public void handle(){
        if (Trigger.isBefore && Trigger.isUpdate){
            for (SAP__c sap : ((list<SAP__c>)Trigger.new )){
                if (!sap.Edit_Flag__c){
                    sap.addError(System.label.Sample_Display_Is_Locked); // 任务锁定
                    return;
                }
                sap.Edit_Flag__c = false;
                sap.Edit_Flag__c = false;
                sap.Edit_Flag__c = false;
            }
        }

        // if (Trigger.isBefore && Trigger.isDelete){
        //     for (SAP__c sap : ((list<SAP__c>)Trigger.old)){
        //         if (!sap.Edit_Flag__c){
        //             sap.addError(System.label.Sample_Display_Is_Locked); // 任务锁定
        //             return;
        //         }
        //     }
        // }
    }

}