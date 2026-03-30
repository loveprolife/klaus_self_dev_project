/*
 * @Author: WFC
 * @Date: 2024-10-11 09:51:47
 * @LastEditors: WFC
 * @LastEditTime: 2024-12-19 13:56:05
 * @Description: Sample Display Confirm Trigger
 * @FilePath: \hisense005\force-app\main\default\classes\SampleDisplayConfirmTriggerHandler.cls
 */
public class SampleDisplayConfirmTriggerHandler implements Triggers.Handler{
    public void handle(){

        if (Trigger.isBefore && Trigger.isInsert){
            for (Sample_Display_Confirm__c storeDetailConfirm : ((list<Sample_Display_Confirm__c>)Trigger.new )){
                storeDetailConfirm.Upload_File_Flag__c = false;
            }
        }

        if (Trigger.isBefore && Trigger.isUpdate){
            for (Sample_Display_Confirm__c storeDetailConfirm : ((list<Sample_Display_Confirm__c>)Trigger.new )){
                if (!storeDetailConfirm.Upload_File_Flag__c){
                    storeDetailConfirm.addError(System.label.Store_Detail_Is_Locked);
                    return;  
                }
                storeDetailConfirm.Upload_File_Flag__c = false;
            }
        }

        if (Trigger.isAfter && Trigger.isInsert){
            // 创建或修改Sampling_Detail__c
            List<Sampling_Detail__c> samplingDetailList = new List<Sampling_Detail__c>();
            // Sampling_Detail__c重复验证
            Set<String> samplingDetailKeySet = new Set<String>();
            for (Sample_Display_Confirm__c storeDetailConfirm : ((list<Sample_Display_Confirm__c>)Trigger.new )){
                // Channel类型的任务，在创建三级任务时，同时创建sampling detail
                if (!samplingDetailKeySet.contains(storeDetailConfirm.Store__c + '-' + storeDetailConfirm.Product_Model__c)){
                    Sampling_Detail__c sd = new Sampling_Detail__c();
                    sd.Display_Status__c = '未展出';
                    sd.Is_Add__c = '是';
                    sd.Unplanned_Sample__c = '否';
                    sd.Product__c = storeDetailConfirm.Product_Model__c;
                    sd.Shop__c = storeDetailConfirm.Store__c;
                    sd.ExternalID__c = storeDetailConfirm.Store__c + '-' + storeDetailConfirm.Product_Model__c;
                    sd.AutomaticallyGenerateSampleStandard__c = true; // 自动生成SampleStandard
                    samplingDetailList.add(sd);
                    samplingDetailKeySet.add(storeDetailConfirm.Store__c + '-' + storeDetailConfirm.Product_Model__c);
                }
            }
            Database.upsert (samplingDetailList, Sampling_Detail__c.Fields.ExternalID__c, false);
        }
    }

}