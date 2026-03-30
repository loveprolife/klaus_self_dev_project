public without sharing class PromoterDailyReportHandler2Helper {
    public static void createInventoryItem(List<Promoter_Daily_Report__c> newList) {
        String outRecordId = Schema.SobjectType.StockItem__c.getRecordTypeInfosByDeveloperName().get('ProductInventory').getRecordTypeId();
        String outGridRecordId = Schema.SobjectType.StockItem__c.getRecordTypeInfosByDeveloperName().get('GridInventory').getRecordTypeId();
        String goodsOutRecordId = Schema.SobjectType.GoodsInOut__c.getRecordTypeInfosByDeveloperName().get('Out').getRecordTypeId();
        try {
            Set<String> idSet = new Set<String>();
            //System.debug('newList===================>'+newList);
            for (Promoter_Daily_Report__c pdr : newList) {
                if (pdr.Status__c != null && pdr.Status__c == 'Approved') {
                    idSet.add(pdr.Id);
                }
            }
            //System.debug('idSet===================>'+idSet);
            List<Retail_Number__c> rNList = new List<Retail_Number__c>();
            if (idSet.size()>0) {
                rNList = [select Id,StoreDelivery__c,Number__c,HasGift__c, Product__c,Gift__c, PromoterDailyReport__c,GiftQuantity__c, Shop__c,ReportDate__c,TotalPrice__c from Retail_Number__c WHERE PromoterDailyReport__c =: idSet ];
            }
            //System.debug('rNList>>>>>>>>>>>>>>>>>>>>'+rNList);
            List<GoodsInOut__c> inserList = new List<GoodsInOut__c>();
            List<GoodsInOut__c> insertGridList = new List<GoodsInOut__c>();
            List<StockItem__c> inserAccList = new List<StockItem__c>();
            List<StockItem__c> inserGridList = new List<StockItem__c>();
            Set<String> shopSet = new Set<String>();
            for (Retail_Number__c rN : rNList) {
                //根据发货数量创建门店的库存明细
                //创建渠道出入库明细
                if (rN.Number__c >0) {
                    StockItem__c productStockItem = new StockItem__c();
                    productStockItem.Shop__c = rN.Shop__c;
                    productStockItem.Product__c =rN.Product__c;
                    productStockItem.Quantity__c = rN.Number__c;
                    productStockItem.RecordTypeId = outRecordId;
                    //productStockItem.DailyReport__c = rN.PromoterDailyReport__c;
                    productStockItem.DailySales__c = rN.Id;
                    productStockItem.TotalPrice__c =rN.TotalPrice__c;
                    productStockItem.Type__c = 'Out';
                    shopSet.add(rN.Shop__c);
                    inserAccList.add(productStockItem);
                }

                if (rN.StoreDelivery__c >0) {
                    //创建收货中间件对象
                    GoodsInOut__c shopGoodsOut = new GoodsInOut__c();
                    shopGoodsOut.StroeCode__c = rN.Shop__c;
                    shopGoodsOut.ProductModel__c =rN.Product__c;
                    shopGoodsOut.Quantities__c = rN.StoreDelivery__c;
                    shopGoodsOut.RecordTypeId = goodsOutRecordId;
                    shopGoodsOut.DailySales__c = rN.id;
                    shopGoodsOut.ReportDate__c = rN.ReportDate__c;
                    shopGoodsOut.TotalPrice__c =rN.TotalPrice__c;
                    shopGoodsOut.Status__c = 'Submitted';//后期更改配置
                    inserList.add(shopGoodsOut);
                    shopSet.add(rN.Shop__c);
                }
                //创建礼品库存记录
                if (rN.HasGift__c) {
                    //创建门店礼品库存中间对象
                    GoodsInOut__c giftGoodsOut = new GoodsInOut__c();
                    giftGoodsOut.StroeCode__c = rN.Shop__c;
                    giftGoodsOut.ProductModel__c =rN.Gift__c;
                    giftGoodsOut.Quantities__c = rN.GiftQuantity__c;
                    giftGoodsOut.RecordTypeId = goodsOutRecordId;
                    giftGoodsOut.DailySales__c = rN.id;
                    giftGoodsOut.ReportDate__c = rN.ReportDate__c;
                    giftGoodsOut.Status__c = 'Submitted';
                    insertGridList.add(giftGoodsOut);
                    shopSet.add(rN.Shop__c);
                    //创建门店网格礼品库存对象
                    StockItem__c giftGridStockItem = new StockItem__c();
                    giftGridStockItem.Shop__c = rN.Shop__c;
                    giftGridStockItem.Product__c =rN.Gift__c;
                    giftGridStockItem.Quantity__c = rN.GiftQuantity__c;
                    giftGridStockItem.RecordTypeId = outGridRecordId;
                    //productStockItem.DailyReport__c = rN.PromoterDailyReport__c;
                    giftGridStockItem.DailySales__c = rN.Id;
                    giftGridStockItem.Type__c = 'Out';
                    shopSet.add(rN.Shop__c);
                    inserGridList.add(giftGridStockItem);
                }
            }
            Map<String, String> shopAccMap = new Map<String, String>();
            Map<String, String> shopGridMap = new Map<String, String>();
            for (Shop__c shop : [select Id,Account__c,GiftGrid__c, Name from Shop__c WHERE id=:shopSet]) {
                shopAccMap.put(shop.Id, shop.Account__c);
                shopGridMap.put(shop.Id, shop.GiftGrid__c);
            }
            for (StockItem__c accStockItem : inserAccList) {
                //关联渠道
                accStockItem.Customer__c = shopAccMap.get(accStockItem.Shop__c);
                accStockItem.Shop__c = null;
            }
            System.debug('渠道 accStockItem' + JSON.serialize(inserAccList));
            for (StockItem__c accStockItem : inserGridList) {
                //关联网格
                accStockItem.GiftGrid__c = shopGridMap.get(accStockItem.Shop__c);
                accStockItem.Shop__c = null;
            }
            System.debug('网格 inserGridList' + JSON.serialize(inserGridList));
            for (GoodsInOut__c goodOut : inserList) {
                //关联渠道
                goodOut.Customer__c = shopAccMap.get(goodOut.StroeCode__c);
            }
            for (GoodsInOut__c goodOut : insertGridList) {
                //关联网格
                goodOut.GiftGrid__c = shopGridMap.get(goodOut.StroeCode__c);
            }
            if (inserAccList.size()>0) {
                insert inserAccList;
            }
            System.debug('门店 goodOut 发货出库--' + JSON.serialize(inserList));
            if (inserList.size()>0) {
                insert inserList;
                System.debug('门店 goodOut 发货出库--' + JSON.serialize(inserList));
            }
            if (insertGridList.size()>0) {
                insert insertGridList;
                System.debug('门店 goodOut 礼品发货出库--' + JSON.serialize(insertGridList));
            }
            if (inserGridList.size()>0) {
                System.debug('网格 inserGridList' + JSON.serialize(inserGridList));
                insert inserGridList;
            }	 
        } catch (Exception e) {
            System.debug('CreateInventoryRecord has a error--'+ e.getMessage() +e.getLineNumber());
            Utility.insertLog('PromoterDailyReportHandler2Helper', '', JSON.serialize(newList), 'CreateInventoryRecord has a error--'+ e.getMessage() +e.getLineNumber());
        }
        
    }

    public static void requestAutoSubmit(List<Promoter_Daily_Report__c > newList){
        List<Approval.ProcessSubmitRequest> processList = new List<Approval.ProcessSubmitRequest>();
        for(Promoter_Daily_Report__c rq:newList){
            if (rq.Status__c != null && rq.Status__c.equals('Submitted')) {
                Approval.ProcessSubmitRequest req = new Approval.ProcessSubmitRequest();
                //req.setComments(approvalMap.get(appId));
                req.setObjectId(rq.Id);
                req.setSkipEntryCriteria(true);
                processList.add(req);
            }
        }
        if (processList.size()>0 && !Test.isRunningTest()) {
            List<Approval.ProcessResult> resultlist = Approval.process(processList);
        }
    }
}