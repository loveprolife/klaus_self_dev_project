/*
 * @Author: WFC
 * @Date: 2024-12-18 10:30:16
 * @LastEditors: WFC
 * @LastEditTime: 2024-12-18 13:42:53
 * @Description: sample display审批通过后拆分po，传递sap信息
 * @FilePath: \hisense005\force-app\main\default\classes\SampleDisplayPOApprovedController.cls
 */
public without sharing class SampleDisplayPOApprovedController{
    @InvocableMethod
    public static void splitPO(List<String> sampleDisplayIdList){
        String sdId = sampleDisplayIdList[0];
        // 查询store details表，排序勾选Priority__c,创建时间正序
        List<Store_Detail__c> sdList = [SELECT Id, Name, CreatedDate, Priority__c, Number__c, Sample_Display__c, Product_Model__c, Split_Up__c, Split_Number__c, Sample_Display__r.Customer__c, Store__c
                                        FROM Store_Detail__c
                                        WHERE Sample_Display__c = :sdId
                                        ORDER BY Priority__c DESC, CreatedDate];
        for (Store_Detail__c sd : sdList){
            sd.Split_Up__c = false;
            sd.Split_Number__c = 0;
        }
        // 查询po表
        List<PO__c> poList = [SELECT Id, Name, Number__c, Category_of_Delivery_Address__c
                              FROM PO__c
                              WHERE Sample_Display__c = :sdId
                              ORDER BY CreatedDate];
        // 拆分po，生成sap
        List<SAP__c> addSapList = new List<SAP__c>();
        for (PO__c po : poList){
            // po的数量
            Decimal poNumber = po.Number__c;
            // store类型生成多个sap信息，customer类型生成一个sap信息
            if (po.Category_of_Delivery_Address__c == 'store'){
                for (Store_Detail__c sd : sdList){
                    if (sd.Split_Up__c){
                        continue;
                    }
                    Decimal deTemp = sd.Number__c - sd.Split_Number__c;
                    // 拆分的数量，可能存在部分拆分
                    if (poNumber == deTemp){
                        sd.Split_Up__c = true;
                        // 生成sap
                        SAP__c sap = new SAP__c();
                        sap.Sample_Display__c = sdId;
                        sap.Number__c = deTemp;
                        addSapList.add(sap);
                        break;
                    } else if (poNumber < deTemp){
                        sd.Split_Number__c = sd.Split_Number__c + poNumber;
                        // 生成sap
                        SAP__c sap = new SAP__c();
                        sap.Sample_Display__c = sdId;
                        sap.Number__c = poNumber;
                        addSapList.add(sap);
                        break;
                    } else{
                        sd.Split_Up__c = true;
                        poNumber = poNumber - deTemp;
                        // 生成sap
                        SAP__c sap = new SAP__c();
                        sap.Sample_Display__c = sdId;
                        sap.Number__c = deTemp;
                        addSapList.add(sap);
                    }
                }
            } else{
                for (Store_Detail__c sd : sdList){
                    if (sd.Split_Up__c){
                        continue;
                    }
                    Decimal deTemp = sd.Number__c - sd.Split_Number__c;
                    // 拆分的数量，可能存在部分拆分
                    if (poNumber == deTemp){
                        sd.Split_Up__c = true;
                        break;
                    } else if (poNumber < deTemp){
                        sd.Split_Number__c = sd.Split_Number__c + poNumber;
                        break;
                    } else{
                        sd.Split_Up__c = true;
                        poNumber = poNumber - deTemp;
                    }
                }
                // 生成一个sap信息
                SAP__c sap = new SAP__c();
                sap.Sample_Display__c = sdId;
                sap.Number__c = po.Number__c;
                addSapList.add(sap);
            }
        }
        Database.insert (addSapList);
        // 传送sap数据
        for (SAP__c sap : addSapList){
            SyncSampleDisplayToSAP.syncSampleDisplayToSAP(sap.Id);
        }
    }

}