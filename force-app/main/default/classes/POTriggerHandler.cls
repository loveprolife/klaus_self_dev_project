/*
 * @Author: WFC
 * @Date: 2024-12-19 13:50:26
 * @LastEditors: WFC
 * @LastEditTime: 2024-12-19 13:58:22
 * @Description: PO trigger
 * @FilePath: \hisense005\force-app\main\default\classes\POTriggerHandler.cls
 */
public class POTriggerHandler implements Triggers.Handler{
    public void handle(){
        if (Trigger.isAfter && (Trigger.isInsert || Trigger.isUpdate)){
            for (PO__c sd : ((list<PO__c>)Trigger.new )){
                if (!(sd.Sample_Display_Approval_Status__c == 'Submitted' && sd.Sample_Display_Path__c == 'Retail Manager Approve')){
                    sd.addError(System.label.Store_Detail_Is_Locked); // 不在po节点不能处理po
                    return;
                }
            }


        }

        if (Trigger.isBefore && Trigger.isDelete){
            for (PO__c sd : ((list<PO__c>)Trigger.old)){
                if (!(sd.Sample_Display_Approval_Status__c == 'Submitted' && sd.Sample_Display_Path__c == 'Retail Manager Approve')){
                    sd.addError(System.label.Store_Detail_Is_Locked); // 不在po节点不能处理po
                    return;
                }
            }
        }
    }

}