public without sharing class RetailNumberTriggerHandlerHelper {
    
    public static void updateTotalPrice(List<Retail_Number__c> newList) {
        //Modified By Ehtan 20230922 给District__c赋值 S
        List<Id> shopIdList = new LisqContainer(newList).SelectSField('Shop__c');
        Set<Id> shopIdSet = new Set<Id>(shopIdList);
        Map<Id, Shop__c> shopMap = new Map<Id, Shop__c>([SELECT Id, District__c FROM Shop__c WHERE Id IN: shopIdSet]);
        for (Retail_Number__c rn : newList) {
            //Modified By Ethan 为空判断 -20230927
            // rn.TotalPrice__c = rn.Price__c*rn.Number__c;
            rn.TotalPrice__c = (rn.Price__c == NULL ? 0:rn.Price__c) * (rn.Number__c == NULL ? 0:rn.Number__c); 
            //Add By Ethan 增加 赋值 Product Category 逻辑 -20230927
            // rn.ProductLine__c = rn.Product_Line__c;
            // rn.Product_Category__c = rn.ProductCategory__c;
            if (shopMap.get(rn.Shop__c) != NULL) 
                rn.District__c = shopMap.get(rn.Shop__c).District__c;
        }
        
        //Modified By Ehtan 20230922 给District__c赋值 E
    }
    
/*
    public static void updateSalesGoalInfoAfterDelete(List<Retail_Number__c> oldList, List<Retail_Number__c> newList){

        LisqContainer oldLc = new LisqContainer(oldList); 
        List<SalesGoal__c> goalList = [SELECT Id, Name, Year__c, Month__c, Day__c, EndingTime__c, CompletedSales__c, ResponsiblePerson__c, ResponsiblePerson__r.Principal__c, Product__c, ProductLine__c , Amounts__c, IsActive__c, StartTime__c, Store__c, RecordTypeId 
                                        FROM SalesGoal__c
                                        WHERE Id IN: oldLc.selectsField('SalesGoal__c')];
        Map<Id, SalesGoal__c> goalIdMaps = new Map<Id, SalesGoal__c>(goalList);                                  

        if(goalList.size() > 0) {
            List<SalesGoal__c> updateGoalList = new List<SalesGoal__c>();
            for(Retail_Number__c item : oldList) {
                if(goalIdMaps.containsKey(item.SalesGoal__c)) {
                    goalIdMaps.get(item.SalesGoal__c).CompletedSales__c -= item.TotalPrice__c;
                    updateGoalList.add(goalIdMaps.get(item.SalesGoal__c));
                }
            }

            if(updateGoalList.size() > 0) {
                update updateGoalList;
            }
        }
    }*/

    /*
    * Name: updateSamplingFlag
    * Purpose: update Sampling Flag
    * Timing : before insert or update
    * Author: yong
    * Create Date: 2023-07-31
    */
    public static void updateSamplingFlag(List<Retail_Number__c> oldList, List<Retail_Number__c> newList){
        Map<String,List<String>> shopIdSamplingDetailIdListMap = new Map<String,List<String>>();
        Set<String> shopIdSet = new Set<String>();
        for(Retail_Number__c rn : newList){
            shopIdSet.add(rn.Shop__c);
            
        }
        for(Shop__c sp : [SELECT Id,Name,(SELECT Id,Name,Product__c,Is_Add__c,Display_Status__c FROM Sampling_Detail_Shop__r) FROM Shop__c WHERE Id IN: shopIdSet]){
            if(sp.Sampling_Detail_Shop__r != null){
                if(shopIdSamplingDetailIdListMap.get(sp.id)==null){
                    List<String> samplingDetailIdList = new List<String>();
                    for(Sampling_Detail__c sd : sp.Sampling_Detail_Shop__r){
                        if(sd.Is_Add__c == '是' && sd.Display_Status__c == '展出'){
                            samplingDetailIdList.add(sd.Product__c);
                        }
                    }
                    if(samplingDetailIdList.size()>0){
                        shopIdSamplingDetailIdListMap.put(sp.Id,samplingDetailIdList);
                    }
                }
            }
        }
        for(Retail_Number__c rn : newList){

            if(shopIdSamplingDetailIdListMap.get(rn.Shop__c)!=null && shopIdSamplingDetailIdListMap.get(rn.Shop__c).contains(rn.Product__c)){
                rn.IsSampling__c = true;
            }else{
                rn.IsSampling__c = false;
            }
        }
    }
	
	/**
     *@description 提交时和target进行绑定
    */
    public static void bindDailySalesTarget(List<Retail_Number__c> oldList, List<Retail_Number__c> newList) {
        if (oldList == null) {
            oldList = new List<Retail_Number__c>();
        }
        
        LisqContainer lc = new LisqContainer(newList);
        LisqContainer productChangeLc = lc.whereAnd(new object[]{
            'Status__c', 'ISCHANGED', oldList,
            'Status__c', '=', 'Submitted'
        });
        List<Retail_Number__c> productChangeList = productChangeLc.ToSobjectList();
        Set<String> monthSet = new Set<String>();
        String year = '0';
        String month = '0';
        for (Retail_Number__c rn : productChangeList) {
            monthSet.add(rn.ReportDate__c.year() + '' + rn.ReportDate__c.month());
            year = rn.ReportDate__c.year() + '';
            month = rn.ReportDate__c.month() + '';
        }

        if (monthSet.size() > 1) {
            newList.get(0).addError('can not submit different month dailysales');
            return;
        }

        List<SalesGoal__c> targets = [
            SELECT
                ID,
                Store__c,
                Year__c,
                Month__c,
                IsActive__c,
                DataIndexF__c
            FROM SalesGoal__c
            WHERE Year__c = :year
                AND Month__c = :month
                AND IsActive__c = true
                AND Store__c IN :(productChangeLc.selectsField('Shop__c'))
        ];
        if (targets.size() > 0) {
            System.debug('targets(0)=' + targets.get(0));
        }
        Map<String, Sobject> targetMap = new LisqContainer(targets).toMapS('DataIndexF__c');
        
        for (Retail_Number__c rn : productChangeList) {
            // String key1 = String.join(new String[] { rn.Shop__c, rn.ResponsiblePerson__c, rn.Product_Line__c, rn.Product__c, year, month}, '_');
            // String key2 = String.join(new String[] { rn.Shop__c, rn.ResponsiblePerson__c, rn.Product_Line__c, year, month}, '_');
            // String key3 = String.join(new String[] { rn.Shop__c, rn.ResponsiblePerson__c, year, month}, '_');

            // String key4 = String.join(new String[] { rn.Shop__c, rn.Product_Line__c, rn.Product__c, year, month}, '_');
            // String key5 = String.join(new String[] { rn.Shop__c, rn.Product_Line__c, year, month}, '_');

            // String key6 = String.join(new String[] { rn.Shop__c, year, month}, '_');


            String key1 = String.join(new String[] { rn.Shop__c, rn.ResponsiblePerson__c, rn.Product_Line__c, rn.Product__c, year, month}, '_');

            String key2 = String.join(new String[] { rn.Shop__c, rn.ResponsiblePerson__c, rn.Product_Line__c, '', year, month}, '_');
            String key3 = String.join(new String[] { rn.Shop__c, rn.ResponsiblePerson__c, '', '', year, month}, '_');

            String key4 = String.join(new String[] { rn.Shop__c, '', rn.Product_Line__c, rn.Product__c, year, month}, '_');
            String key5 = String.join(new String[] { rn.Shop__c, '', rn.Product_Line__c, '', year, month}, '_');

            String key6 = String.join(new String[] { rn.Shop__c, '', '', '', year, month}, '_');

            
            if (targetMap.containsKey(key1)) {
                System.debug('key1=' + key1);
                rn.SalesGoal__c = targetMap.get(key1).Id;
            } else if (targetMap.containsKey(key2)) {
                System.debug('key2=' + key2);
                rn.SalesGoal__c = targetMap.get(key2).Id;
            } else if (targetMap.containsKey(key3)) {
                System.debug('key3=' + key3);
                rn.SalesGoal__c = targetMap.get(key3).Id;
            } else if (targetMap.containsKey(key4)) {
                System.debug('key4=' + key4);
                rn.SalesGoal__c = targetMap.get(key4).Id;
            } else if (targetMap.containsKey(key5)) {
                System.debug('key5=' + key5);
                rn.SalesGoal__c = targetMap.get(key5).Id;
            } else if (targetMap.containsKey(key6)) {
                System.debug('key6=' + key6);
                rn.SalesGoal__c = targetMap.get(key6).Id;
            } else {
                System.debug('key1=' + key1);
                System.debug('key2=' + key2);
                System.debug('key3=' + key3);
                System.debug('key4=' + key4);
                System.debug('key5=' + key5);
                System.debug('key6=' + key6);
            }
        }
    }


    /**
     *@description target更改时计算target的数量和金额
        *@param	param1	param1意义
        *@return	type	返回意义
    */
    public static void calculateDailySalesTargetChange(List<Retail_Number__c> oldList, List<Retail_Number__c> newList) {
        if (oldList == null) {
            oldList = new List<Retail_Number__c>();
        }
        
        if (newList == null) {
            newList = new List<Retail_Number__c>();
        }

        Map<Id, Retail_Number__c> oldMap = new Map<Id, Retail_Number__c>(oldList);
        Map<Id, Retail_Number__c> newMap = new Map<Id, Retail_Number__c>(newList);
        // LisqContainer lc = new LisqContainer(newList);
        // LisqContainer oldlc = new LisqContainer(newList);
        // LisqContainer productChangeOldLc = oldlc.whereAnd(new object[]{
        //     'SalesGoal__c', 'ISCHANGED', newList,
        //     'Status__c', '=', 'Submitted'
        // });
        // LisqContainer productChangeNewLc = lc.whereAnd(new object[]{
        //     'SalesGoal__c', 'ISCHANGED', oldList,
        //     'Status__c', '=', 'Submitted'
        // });
        
        Set<Id> allTargetIdSet = new Set<Id>();
        for (Retail_Number__c rn : oldList) {
            allTargetIdSet.add(rn.SalesGoal__c);
        }
        for (Retail_Number__c rn : newList) {
            allTargetIdSet.add(rn.SalesGoal__c);
        }

        Map<Id, SalesGoal__c> targetMap = new Map<Id, SalesGoal__c>();
        if(allTargetIdSet.size() > 0) {
            targetMap = new Map<Id, SalesGoal__c>([
                SELECT
                    ID,
                    CompletedSales__c,
                    CompletedQuantities__c,
                    CurrencyIsoCode
                FROM SalesGoal__c
                WHERE Id IN :allTargetIdSet
            ]);
        }
        

        List<SalesGoal__c> needUpdates = new List<SalesGoal__c>();
        Map<Id, SalesGoal__c> needUpdateMap = new Map<Id, SalesGoal__c>();
        
        // 计算target更改之前的
        for (Retail_Number__c rn : oldList) {
            if (rn.SalesGoal__c != null && rn.Status__c == 'Submitted' && (!newMap.containsKey(rn.Id) || rn.SalesGoal__c != newMap.get(rn.Id).SalesGoal__c)) {
                if (targetMap.containsKey(rn.SalesGoal__c)) {
                    SalesGoal__c sg = targetMap.get(rn.SalesGoal__c);
                    if (sg == null) {
                        System.debug('targetMap.get(rn.SalesGoal__c=' + rn.SalesGoal__c + ') == null');
                        continue;
                    }
                    System.debug('sg=' + sg);
                    System.debug('rn=' + rn);
                    if (sg.CompletedQuantities__c == null) {
                        sg.CompletedQuantities__c = 0;
                    }

                    if (sg.CompletedSales__c == null) {
                        sg.CompletedSales__c = 0;
                    }
                    sg.CompletedQuantities__c -= rn.Number__c;
                    sg.CompletedSales__c -= rn.TotalPrice__c * CurrencyRateHelper.getConversionRate(rn.CurrencyIsoCode, sg.CurrencyIsoCode);
                    // needUpdates.add(sg);
                    needUpdateMap.put(sg.Id, sg);
                } else {
                    System.debug('targetMap.containsKey(rn.SalesGoal__c[' + rn.SalesGoal__c + '])=false');
                }
            }
        }

        for (Retail_Number__c rn : newList) {
            if ( rn.Status__c == 'Submitted' && (
                    (!oldMap.containsKey(rn.Id) || rn.Status__c != oldMap.get(rn.Id).Status__c)         // 直接提交或从New状态变成提交时
                    || rn.SalesGoal__c != null && (!oldMap.containsKey(rn.Id) || rn.SalesGoal__c != oldMap.get(rn.Id).SalesGoal__c)         // 已提交的target发生更改
                )
            ) {
                if (targetMap.containsKey(rn.SalesGoal__c)) {
                    SalesGoal__c sg = targetMap.get(rn.SalesGoal__c);
                    if (sg == null) {
                        System.debug('targetMap.get(rn.SalesGoal__c=' + rn.SalesGoal__c + ') == null');
                        continue;
                    }
                    System.debug('sg=' + sg);
                    System.debug('rn=' + rn);
                    if (sg.CompletedQuantities__c == null) {
                        sg.CompletedQuantities__c = 0;
                    }

                    if (sg.CompletedSales__c == null) {
                        sg.CompletedSales__c = 0;
                    }
                    sg.CompletedQuantities__c += rn.Number__c;
                    sg.CompletedSales__c += rn.TotalPrice__c * CurrencyRateHelper.getConversionRate(rn.CurrencyIsoCode, sg.CurrencyIsoCode);
                    // needUpdates.add(sg);
                    needUpdateMap.put(sg.Id, sg);
                } else {
                    System.debug('targetMap.containsKey(rn.SalesGoal__c[' + rn.SalesGoal__c + '])=false');
                }
            }
        }

        needUpdates = needUpdateMap.values();
        System.debug('needUpdates.size=' + needUpdates.size());
        if (needUpdates.size() > 0) {
            System.debug(needUpdates.get(0));
            if (needUpdates.size() > 1) {
                System.debug(needUpdates.get(1));
            }
            
            if (SalesGoalTriggerHandlerHelper.activeChanged) {
                System.enqueueJob(new SyncTarget(needUpdates));
            } else {
                update needUpdates;
            }
        }
    }

    public class SyncTarget implements Queueable {
        List<SalesGoal__c> needUpdates;
        public SyncTarget(List<SalesGoal__c> needUpdates){
            this.needUpdates = needUpdates;
            system.debug('======needUpdates===='+ needUpdates);
        }
        public void execute(QueueableContext context) {
            update needUpdates;
        }
    }

    /*
    * Name: dailySalesfieldUpdateForAnayticsDashboard
    * Purpose: auto update daily sales field (only for anaytics dashboard)
    * Timing : before insert or update
    * Author: yong
    * Create Date: 2023-08-21
    */
    public static void dailySalesfieldUpdateForAnayticsDashboard(List<Retail_Number__c> oldList, List<Retail_Number__c> newList){
        for(Retail_Number__c rn : newList){
            if(rn.Brand__c == null){
                rn.Brand__c = rn.Customer_Name__c;
            }
            if(rn.Product_Category__c == null){
                rn.Product_Category__c = rn.ProductCategory__c;
            }
            if(rn.ProductLine__c == null){
                rn.ProductLine__c = rn.Product_Line__c;
            }
        }
    }
    
    public static void changeSubmitAfter(List<Retail_Number__c> oldList, List<Retail_Number__c> newList){
        String outRecordId = Schema.SobjectType.StockItem__c.getRecordTypeInfosByDeveloperName().get('ProductInventory').getRecordTypeId();
        Map<Id, Retail_Number__c> newMap = new Map<Id, Retail_Number__c>(newList);
        Map<Id, Retail_Number__c> oldMap = new Map<Id, Retail_Number__c>(oldList);
        Map<Id, Retail_Number__c> changeMap = new Map<Id, Retail_Number__c>();
        String history = ' '+ UserInfo.getUserId() + '_' + System.now() + '=';
        for (Id rnId : newMap.keySet()) {
            Retail_Number__c newRn = newMap.get(rnId);
            Retail_Number__c oldRn = oldMap.get(rnId);
            if (newRn.Status__c == 'Submitted' && oldRn.Status__c == 'Submitted' && (
                newRn.StoreDelivery__c != oldRn.StoreDelivery__c ||
                newRn.Number__c != oldRn.Number__c ||
                newRn.Price__c != oldRn.Price__c ||
                newRn.TotalPrice__c != oldRn.TotalPrice__c
            )) {
                changeMap.put(rnId, newRn);

                String oldHistory = ' Old StoreDelivery:'+oldRn.StoreDelivery__c + ' Number:'+oldRn.Number__c + ' Price:' + oldRn.Price__c + ' TotalPrice:' + oldRn.TotalPrice__c;
                String newHistory = ' Old StoreDelivery:'+newRn.StoreDelivery__c + ' Number:'+newRn.Number__c + ' Price:' + newRn.Price__c + ' TotalPrice:' + newRn.TotalPrice__c + +'\n';
                newRn.Change_Daily_Sales_History__c = newRn.Change_Daily_Sales_History__c==null?history+oldHistory+newHistory:newRn.Change_Daily_Sales_History__c+history+oldHistory+newHistory;
            }
        }
        if (changeMap.size()>0) {
            List<GoodsInOut__c> gioList = [SELECT Id,Name,Quantities__c,TotalPrice__c,DailySales__c,Change_Daily_Sales_History__c FROM GoodsInOut__c WHERE DailySales__c IN :changeMap.keySet()];
            for (GoodsInOut__c gio : gioList) {
                Retail_Number__c rn = changeMap.get(gio.DailySales__c);
                String oldHistory = ' Old Quantities:'+gio.Quantities__c + ' TotalPrice:'+gio.TotalPrice__c;
                String newHistory = ' New Quantities:'+rn.StoreDelivery__c + ' TotalPrice:'+rn.TotalPrice__c+'\n';
                gio.Change_Daily_Sales_History__c = gio.Change_Daily_Sales_History__c==null?history+oldHistory+newHistory:gio.Change_Daily_Sales_History__c+history+oldHistory+newHistory;
                gio.Quantities__c = rn.StoreDelivery__c;
                gio.TotalPrice__c = rn.TotalPrice__c;
            }
            update gioList;

            List<StockItem__c> siList = [SELECT Id,Name,Product__c,Quantity__c,TotalPrice__c,DailySales__c,Change_Daily_Sales_History__c FROM StockItem__c WHERE DailySales__c IN :changeMap.keySet() AND RecordTypeId = :outRecordId];
            for (StockItem__c si : siList) {
                Retail_Number__c rn = changeMap.get(si.DailySales__c);
                String oldHistory = ' Old Quantity:'+si.Quantity__c + ' TotalPrice:'+si.TotalPrice__c;
                String newHistory = ' New Quantity:'+rn.Number__c + ' TotalPrice:'+rn.TotalPrice__c+'\n';
                si.Change_Daily_Sales_History__c = si.Change_Daily_Sales_History__c==null?history+oldHistory+newHistory:si.Change_Daily_Sales_History__c+history+oldHistory+newHistory;
                si.Quantity__c = rn.Number__c;
                si.TotalPrice__c = rn.TotalPrice__c;
            }
            update siList;
        }

    }

    // public static void changeSAWeeklySalesTarget(List<Retail_Number__c> oldList, List<Retail_Number__c> newList){

    //     if (oldList == null) {
    //         oldList = new List<Retail_Number__c>();
    //     }
        
    //     if (newList == null) {
    //         newList = new List<Retail_Number__c>();
    //     }

    //     Map<Id, Retail_Number__c> oldMap = new Map<Id, Retail_Number__c>(oldList);
    //     Map<Id, Retail_Number__c> newMap = new Map<Id, Retail_Number__c>(newList);

    //     List<Retail_Number__c> updateChannelList = new List<Retail_Number__c>();
    //     List<Retail_Number__c> updateStoreList = new List<Retail_Number__c>();

    //     //List<Weekly_Sales_Target__c> updateList = new List<Weekly_Sales_Target__c>();
    //     Set<Id> objectAIds = new Set<Id>();
    //     for (Retail_Number__c rn : newList) {
    //         objectAIds.add(rn.Shop__c);
    //     }
    //     List<Shop__c> shopList = [Select Id, Channel_Item__c FROM Shop__c WHERE id IN :objectAIds];
    //     Map<String, String> channelMap = new Map<String, String>();
    //     for(Shop__c shop : shopList){
    //         channelMap.put(shop.Id, shop.Channel_Item__c);
    //     }

    //     for (Retail_Number__c rn : newList) {

    //         if(String.isNotBlank(rn.Store_Weekly_Sales_Target__c)){
    //             continue;
    //         }
    //         Retail_Number__c oldDS = oldMap.get(rn.Id);

    //         Boolean oldStatus = true;
    //         if(oldDS != null && oldDS.Status__c == 'Submitted'){
    //             oldStatus = false;
    //         } 

    //         if ( rn.Status__c == 'Submitted' && oldStatus && rn.Store_Sales_Region__c == 'Hisense South Africa'){

    //             Integer week = NewWeeklySalesTargetButtonController.getWeekOfYear(rn.ReportDate__c);
    //             String External_key = rn.Store_Sales_Region__c + '_' 
    //                                     + week + '_'
    //                                     + channelMap.get(rn.Shop__c) + '_'
    //                                     + rn.Product_Line__c + '_'
    //                                     + rn.Product__c + '_'
    //                                     + rn.Reportyear__c;

    //             String External_key_Store = rn.Store_Sales_Region__c + '_' 
    //                                     + week + '_'
    //                                     + channelMap.get(rn.Shop__c) + '_'
    //                                     + rn.Shop__c + '_'
    //                                     + rn.Product_Line__c + '_'
    //                                     + rn.Product__c + '_'
    //                                     + rn.Reportyear__c;

    //             String[] ekList = new String[]{External_key, External_key_Store};                        
    //             List<Weekly_Sales_Target__c> taskList = 
    //                                             [   select 
    //                                                     id,BA_ACH__c,Store__c,Week__c,Channel_Item__c,
    //                                                     Sales_Region__c,Product_Line__c,Model__c
    //                                                 from Weekly_Sales_Target__c
    //                                                 where External_key__c in:ekList
    //                                             ];
    //             NewWeeklySalesTargetButtonController.setBA_ACH(taskList);
    //             // for(Weekly_Sales_Target__c wst : taskList){
    //             //     if(wst.BA_ACH__c == null){
    //             //         wst.BA_ACH__c = rn.Number__c;
    //             //     }else{
    //             //         wst.BA_ACH__c = rn.Number__c + wst.BA_ACH__c;
    //             //     }
    //             //     if(String.isNotBlank(wst.Store__c)){
    //             //         Retail_Number__c rnc = new Retail_Number__c(Id = rn.Id, Store_Weekly_Sales_Target__c = wst.Id);
    //             //         updateStoreList.add(rnc);
    //             //     }else{
    //             //         Retail_Number__c rnc = new Retail_Number__c(Id = rn.Id, Weekly_Sales_Target__c = wst.Id);
    //             //         updateChannelList.add(rnc);
    //             //     }
                    
    //             //     //updateList.add(wst);
    //             // }     
    //             //update taskList;                          
    //         }
    //     }

       
    //     // try{
    //     //     //忽略触发器更新
    //     //     GlobalSetting__c ignoreGs = Utility.IgnoreAction(true, true, true, 'RetailNumberTriggerHandler');
    //     //     if(updateChannelList.size() > 0){
    //     //         Database.update(updateChannelList);
    //     //     }
    //     //     if(updateStoreList.size() > 0){
    //     //         Database.update(updateStoreList);
    //     //     }
    //     //     //恢复触发器
    //     //     Utility.IgnoreAction(false,false,false,'');
    //     // }catch(Exception e){
    //     //     //恢复触发器
    //     //     Utility.IgnoreAction(false,false,false,'');
    //     // }
            

        
        

    //     // if(updateList.size() > 0){
    //     //     update updateList;
    //     // }

    // }
}