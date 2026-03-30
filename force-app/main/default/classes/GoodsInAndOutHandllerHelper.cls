public without sharing class GoodsInAndOutHandllerHelper {
    
    public static void createProductInventoryRecord(List<GoodsInOut__c > oldList, List<GoodsInOut__c > newList) {
        String storeRecordId = Schema.SobjectType.StockItem__c.getRecordTypeInfosByDeveloperName().get('StoreStock').getRecordTypeId();
        //String storeOutRecordId = Schema.SobjectType.StockItem__c.getRecordTypeInfosByDeveloperName().get('StoreStockOut').getRecordTypeId();
        String productRecordId = Schema.SobjectType.StockItem__c.getRecordTypeInfosByDeveloperName().get('ProductInventory').getRecordTypeId();
        //String productOutRecordId = Schema.SobjectType.StockItem__c.getRecordTypeInfosByDeveloperName().get('ProductInventoryOut').getRecordTypeId();
        String inGoodsRecordId = Schema.SobjectType.GoodsInOut__c.getRecordTypeInfosByDeveloperName().get('In').getRecordTypeId();
        String outGoodsRecordId = Schema.SobjectType.GoodsInOut__c.getRecordTypeInfosByDeveloperName().get('Out').getRecordTypeId();
        try {
            List<StockItem__c> inserList = new List<StockItem__c>();
            List<StockItem__c> inserGiftList = new List<StockItem__c>();
            Map<Id, GoodsInOut__c> oldMap = oldList==null ? null : new Map<Id, GoodsInOut__c>(oldList);
            Set<String> shopSet = new Set<String>();
            for (GoodsInOut__c  gR : newList) {
                if ((oldMap==null || (oldMap!=null && oldMap.containsKey(gR.Id) && !oldMap.get(gR.Id).Status__c.equals('Approved'))) && 
                    gR.Status__c.equals('Approved')&& gR.Quantities__c>0) {
                    //创建门店出入库明细
                    StockItem__c shopStockItem = new StockItem__c();
                    shopStockItem.Shop__c = gR.StroeCode__c;
                    shopStockItem.Product__c =gR.ProductModel__c;
                    shopStockItem.Quantity__c = gR.Quantities__c;
                    if (gR.DailySales__c != null) {
                        shopStockItem.DailySales__c = gR.DailySales__c;
                    }
                    if (gR.PromoterDailyReport__c != null) {
                        shopStockItem.DailyReport__c = gR.PromoterDailyReport__c;
                    }
                    shopStockItem.RecordTypeId = storeRecordId;
                    shopStockItem.GoodsInOut__c = gR.Id;
                    if (gR.RecordTypeId == inGoodsRecordId) {
                        shopStockItem.Type__c = 'In';
                        //shopStockItem.RecordTypeId = storeInRecordId;
                    }
                    if (gR.RecordTypeId == outGoodsRecordId) {
                        shopStockItem.Type__c = 'Out';
                        //shopStockItem.RecordTypeId = storeOutRecordId;
                    }
                    if (gR.TotalPrice__c !=null) {
                        shopStockItem.TotalPrice__c = gR.TotalPrice__c;
                    }
                    if (gR.ProductType__c.contains('Gift')) {
                        inserGiftList.add(shopStockItem);
                    }else {
                        inserList.add(shopStockItem); 
                    }
                    shopSet.add(gR.StroeCode__c);
                    
                }
            }
            Map<String, String> shopAccMap = new Map<String, String>();
            Map<String, String> shopGridMap = new Map<String, String>();
            for (Shop__c shop : [select Id,Account__c,GiftGrid__c, Name from Shop__c WHERE id=:shopSet]) {
                shopAccMap.put(shop.Id, shop.Account__c);
                shopGridMap.put(shop.Id, shop.GiftGrid__c);
            }
            for (StockItem__c accStockItem : inserList) {
                //关联渠道
                accStockItem.Customer__c = shopAccMap.get(accStockItem.Shop__c);
            }
            for (StockItem__c accStockItem : inserGiftList) {
                accStockItem.GiftGrid__c = shopGridMap.get(accStockItem.Shop__c);
            }
            if (inserList.size()>0) {
                insert inserList;
            }
            if(inserGiftList.size()>0){
                insert inserGiftList;
            }
        } catch (Exception e) {
            
            System.debug('createProductInventoryRecord has a error--'+ e.getMessage() +e.getLineNumber());
        }
    }

    public static void requestAutoSubmit(List<GoodsInOut__c > newList){
        List<Approval.ProcessSubmitRequest> processList = new List<Approval.ProcessSubmitRequest>();
        for(GoodsInOut__c rq:newList){
            if(rq.Status__c !=null && rq.Status__c == 'Submitted' ){
            Approval.ProcessSubmitRequest req = new Approval.ProcessSubmitRequest();
            //req.setComments(approvalMap.get(appId));
            req.setObjectId(rq.Id);
            req.setSkipEntryCriteria(true);
            processList.add(req);
            }
        }
        List<Approval.ProcessResult> resultlist = Approval.process(processList);
    }
    
    public static void changeSubmitAfter(List<GoodsInOut__c> oldList, List<GoodsInOut__c> newList) {
        String outGoodsRecordId = Schema.SobjectType.GoodsInOut__c.getRecordTypeInfosByDeveloperName().get('Out').getRecordTypeId();
        String storeRecordId = Schema.SobjectType.StockItem__c.getRecordTypeInfosByDeveloperName().get('StoreStock').getRecordTypeId();
        Map<Id, GoodsInOut__c> oldMap = new Map<Id, GoodsInOut__c>(oldList);
        Map<Id, GoodsInOut__c> newMap = new Map<Id, GoodsInOut__c>(newList);
        Map<Id, GoodsInOut__c> changeMap = new Map<Id, GoodsInOut__c>();
        for (Id gioId : newMap.keySet()) {
            GoodsInOut__c newGio = newMap.get(gioId);
            GoodsInOut__c oldGio = oldMap.get(gioId);
            if (newGio.Status__c.equals('Approved') && oldGio.Status__c.equals('Approved') && 
                newGio.RecordTypeId == outGoodsRecordId && oldGio.RecordTypeId == outGoodsRecordId && 
                (newGio.TotalPrice__c != oldGio.TotalPrice__c || 
                newGio.Quantities__c != oldGio.Quantities__c)
            ) {
                changeMap.put(newGio.Id, newGio);
            }
        }
        
        if (changeMap.size()>0) {
            String history = ' ' + UserInfo.getUserId() + '_' + System.now() + '=';
            List<StockItem__c> siList = [SELECT Id,Name,Shop__c,Product__c,Quantity__c,TotalPrice__c,DailySales__c,DailyReport__c,GoodsInOut__c,Change_Daily_Sales_History__c FROM StockItem__c WHERE GoodsInOut__c IN :changeMap.values() AND RecordTypeId = :storeRecordId];
            for (StockItem__c si : siList) {
                GoodsInOut__c gio = changeMap.get(si.GoodsInOut__c);
                String oldHistory = ' Old Quantity:'+si.Quantity__c + ' TotalPrice:'+si.TotalPrice__c;
                String newHistory = ' New Quantity:'+gio.Quantities__c + ' TotalPrice:'+gio.TotalPrice__c+'\n';
                si.Change_Daily_Sales_History__c = si.Change_Daily_Sales_History__c==null?history+oldHistory+newHistory:si.Change_Daily_Sales_History__c+history+oldHistory+newHistory;
                si.Quantity__c = gio.Quantities__c;
                si.TotalPrice__c = gio.TotalPrice__c;
            }
            update siList;
        }
    }
}