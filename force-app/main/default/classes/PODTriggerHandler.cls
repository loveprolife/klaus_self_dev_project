/*
 * @Author: WFC
 * @Date: 2024-12-17 09:32:57
 * @LastEditors: WFC
 * @LastEditTime: 2025-01-10 12:57:58
 * @Description: pod trigger handle
 * @FilePath: \hisense005\force-app\main\default\classes\PODTriggerHandler.cls
 */
public class PODTriggerHandler implements Triggers.Handler{
    public void handle(){

        if (Trigger.isAfter && (Trigger.isUpdate || Trigger.isInsert)){
            List<POD__C> podList = new List<POD__C>();
            Set<String> podIdSet = new Set<String>();
            for (POD__C po : (List<POD__C>)Trigger.new ){
                if (po.Status__c == 'C' || po.Status__c == 'c'){
                    podList.add(po);
                    podIdSet.add(po.Sample_Display__c);
                }
            }
            // 查询store details表，过滤掉拆分完的，排序勾选Priority__c,创建时间正序
            List<Store_Detail__c> sdList = [SELECT Id, Name, CreatedDate, Priority__c, Number__c, Sample_Display__c, Product_Model__c, Split_Up__c, Split_Number__c, Sample_Display__r.Customer__c, Store__c
                                            FROM Store_Detail__c
                                            WHERE Sample_Display__c IN:podIdSet AND Split_Up__c != true
                                            ORDER BY Priority__c DESC, CreatedDate];
            Map<String, List<Store_Detail__c>> sdMap = new Map<String, List<Store_Detail__c>>();
            for (Store_Detail__c sd : sdList){
                if (sdMap.containsKey(sd.Sample_Display__c)){
                    List<Store_Detail__c> sdListTemp = sdMap.get(sd.Sample_Display__c);
                    sdListTemp.add(sd);
                    sdMap.put(sd.Sample_Display__c, sdListTemp);
                } else{
                    List<Store_Detail__c> sdListTemp = new List<Store_Detail__c>();
                    sdListTemp.add(sd);
                    sdMap.put(sd.Sample_Display__c, sdListTemp);
                }
            }

            // 要修改的store details
            Map<String, Store_Detail__c> updateMap = new Map<String, Store_Detail__c>();
            // 要新增的Sample Display Confirm
            List<Sample_Display_Confirm__c> sdcAddList = new List<Sample_Display_Confirm__c>();
            // 循环拆分
            for (POD__C pd : podList){
                List<Store_Detail__c> sdListTemp = sdMap.get(pd.Sample_Display__c);
                if (sdListTemp == null){
                    pd.addError('Store detail has been split.');
                    return;
                }
                // pod的数量
                Decimal de = pd.Number__c;
                for (Store_Detail__c sd : sdListTemp){
                    if (sd.Split_Up__c){
                        continue;
                    }
                    // 拆分的数量，可能存在部分拆分
                    Decimal splitNumber = sd.Split_Number__c != null ? sd.Split_Number__c : 0;
                    Decimal deTemp = sd.Number__c - splitNumber;
                    if (de == deTemp){
                        sd.Split_Up__c = true;
                        sd.Split_Number__c = splitNumber + deTemp;
                        updateMap.put(sd.Id, sd);
                        // 创建sample display confirm
                        Sample_Display_Confirm__c sdc = new Sample_Display_Confirm__c();
                        sdc.Sample_Display__c = sd.Sample_Display__c;
                        sdc.Customer__c = sd.Sample_Display__r.Customer__c;
                        sdc.Number__c = deTemp;
                        sdc.Product_Model__c = sd.Product_Model__c;
                        sdc.Store__c = sd.Store__c;
                        sdc.Priority__c = sd.Priority__c;
                        sdcAddList.add(sdc);
                        break;
                    } else if (de < deTemp){
                        sd.Split_Number__c = splitNumber + de;
                        updateMap.put(sd.Id, sd);
                        // 创建sample display confirm
                        Sample_Display_Confirm__c sdc = new Sample_Display_Confirm__c();
                        sdc.Sample_Display__c = sd.Sample_Display__c;
                        sdc.Customer__c = sd.Sample_Display__r.Customer__c;
                        sdc.Number__c = de;
                        sdc.Product_Model__c = sd.Product_Model__c;
                        sdc.Store__c = sd.Store__c;
                        sdc.Priority__c = sd.Priority__c;
                        sdcAddList.add(sdc);
                        break;
                    } else{
                        sd.Split_Up__c = true;
                        sd.Split_Number__c = splitNumber + deTemp;
                        updateMap.put(sd.Id, sd);
                        de = de - deTemp;
                        // 创建sample display confirm
                        Sample_Display_Confirm__c sdc = new Sample_Display_Confirm__c();
                        sdc.Sample_Display__c = sd.Sample_Display__c;
                        sdc.Customer__c = sd.Sample_Display__r.Customer__c;
                        sdc.Number__c = deTemp;
                        sdc.Product_Model__c = sd.Product_Model__c;
                        sdc.Store__c = sd.Store__c;
                        sdc.Priority__c = sd.Priority__c;
                        sdcAddList.add(sdc);
                    }
                }
                sdMap.put(pd.Sample_Display__c, sdListTemp);
            }
            try{
                //忽略触发器更新
                GlobalSetting__c ignoreGs = Utility.IgnoreAction(true, true, true, 'PODTriggerHandler');
                Database.update (updateMap.values());
                //恢复触发器
                Utility.IgnoreAction(false, false, false, '');

                Database.insert (sdcAddList);
            } catch (Exception e){
                Utility.IgnoreAction(false, false, false, '');
            }
        }
    }

}