public without sharing class InventoryItemTriggerHandlerHelper {
    public static void updateInventory(List<StockItem__c> newList) {
        try {
            List<Inventory__c> inventoryList = new List<Inventory__c>();
            List<Inventory__c> updateinventoryList = new List<Inventory__c>();
            /*String productInRecordId = Schema.SobjectType.StockItem__c.getRecordTypeInfosByDeveloperName().get('ProductInventoryIn').getRecordTypeId();
            String productOutRecordId = Schema.SobjectType.StockItem__c.getRecordTypeInfosByDeveloperName().get('ProductInventoryOut').getRecordTypeId();
            String storeInRecordId = Schema.SobjectType.StockItem__c.getRecordTypeInfosByDeveloperName().get('StoreStockIn').getRecordTypeId();
            String storeOutRecordId = Schema.SobjectType.StockItem__c.getRecordTypeInfosByDeveloperName().get('StoreStockOut').getRecordTypeId();
            */
            String productRecordId = Schema.SobjectType.StockItem__c.getRecordTypeInfosByDeveloperName().get('ProductInventory').getRecordTypeId();
            String storeRecordId = Schema.SobjectType.StockItem__c.getRecordTypeInfosByDeveloperName().get('StoreStock').getRecordTypeId();
            String storeInventoryRecordId = Schema.SobjectType.Inventory__c.getRecordTypeInfosByDeveloperName().get('StoreStock').getRecordTypeId();
            String productInventoryRecordId = Schema.SobjectType.Inventory__c.getRecordTypeInfosByDeveloperName().get('ProductInventory').getRecordTypeId();
            String productGridRecordId = Schema.SobjectType.StockItem__c.getRecordTypeInfosByDeveloperName().get('GridInventory').getRecordTypeId();
            String productGridInventoryRecordId = Schema.SobjectType.Inventory__c.getRecordTypeInfosByDeveloperName().get('GridInventory').getRecordTypeId();
            Set<String> shopSet = new Set<String>();
            Set<String> accSet = new Set<String>();
            Map<String,String> stockMap = new Map<String,String>();
            List<Inventory__c> inventoryProdutDbList = new List<Inventory__c>();
            List<Inventory__c> inventoryShopDbList = new List<Inventory__c>();
            List<Inventory__c> inventoryGridDbList = new List<Inventory__c>();
            Map<String, Inventory__c> productInventoryMap = new Map<String, Inventory__c>();
            Map<String, Inventory__c> shopInventoryMap = new Map<String, Inventory__c>();
            /*for (StockItem__c stockItem : newList) {
                String key = stockItem.Customer__c + '' + stockItem.Shop__c + stockItem.Product__c;
                if (stockItem.RecordTypeId == productRecordId) {
                    accSet.add(key+'Channel');
                    stockMap.put(stockItem.Id,key+'Channel');
                }else if (stockItem.RecordTypeId == storeRecordId) {
                    shopSet.add(key+'Shop');
                    stockMap.put(stockItem.Id,key+'Shop');
                }
            }*/
            List<String> shopIdList = new LisqContainer(newList).WhereOne('RecordTypeId','=',storeRecordId).SelectField('Shop__c').ToS();
            //get shop inventory
            if (shopIdList.size()>0) {
                inventoryShopDbList = [SELECT Inventory_Number__c,Product__c,GiftGrid__c,Customer__c,UniqueKey__c,Shop__c, RecordType.DeveloperName, RecordTypeId FROM Inventory__c WHERE Shop__c =: shopIdList And RecordType.DeveloperName ='StoreStock'];
            }
            //get chanle inventory
            List<String> accIdList = new LisqContainer(newList).WhereOne('RecordTypeId','=',productRecordId).SelectField('Customer__c').ToS();
            if (accIdList.size()>0) {
                inventoryProdutDbList = [SELECT Inventory_Number__c,Product__c,Customer__c,UniqueKey__c,Shop__c, RecordType.DeveloperName, RecordTypeId FROM Inventory__c WHERE Customer__c =: accIdList And RecordType.DeveloperName ='ProductInventory'];
            }
            List<String> shopGridIdList = new LisqContainer(newList).WhereOne('RecordTypeId','=',productGridRecordId).SelectField('GiftGrid__c').ToS();
            //get shop inventory
            if (shopGridIdList.size()>0) {
                inventoryGridDbList = [SELECT Inventory_Number__c,Product__c,GiftGrid__c,UniqueKey__c,Shop__c, RecordType.DeveloperName, RecordTypeId FROM Inventory__c WHERE GiftGrid__c =: shopGridIdList And RecordType.DeveloperName ='GridInventory'];
            }
            List<StockItem__c> insertInventoryList = new List<StockItem__c>();
            for (StockItem__c stockItem : newList){
                Inventory__c inventory = new Inventory__c();
                if (stockItem.RecordTypeId == productRecordId){
                    List<Object> lp = new List<Object>(); lp= new LisqContainer(inventoryProdutDbList).WhereAnd(new object[]{'Product__c','=',stockItem.Product__c,
                            'Customer__c','=',stockItem.Customer__c}).ToSobjectList();
                    System.debug('lp--' + JSON.serialize(lp));
                    if (lp.Size()>0) {
                        inventory = (Inventory__c)lp[0];
                        stockItem.Inventory__c = inventory.Id;
                    }else {
                        insertInventoryList.add(stockItem);
                        inventory.Inventory_Number__c = 0;
                        inventory.Product__c = stockItem.Product__c;
                        inventory.Customer__c = stockItem.Customer__c;
                        inventory.RecordTypeId = productInventoryRecordId;
                    }
                    if(stockItem.Type__c.equals('In') ){
                        inventory.Inventory_Number__c = inventory.Inventory_Number__c + stockItem.Quantity__c;
                    }else if(stockItem.Type__c.equals('Out')){
                        inventory.Inventory_Number__c = inventory.Inventory_Number__c - stockItem.Quantity__c;
                    }
                    System.debug('渠道库存信息已经更新。');
                }else if(stockItem.RecordTypeId == storeRecordId ){
                    List<Object> lp =  new LisqContainer(inventoryShopDbList).WhereAnd(new object[]{'Product__c','=',stockItem.Product__c,
                                'Shop__c','=',stockItem.Shop__c}).ToSobjectList();
                    if (lp.Size()>0) {
                        inventory = (Inventory__c)lp[0];
                        stockItem.Inventory__c = inventory.Id;
                    }else {
                        insertInventoryList.add(stockItem);
                        inventory.Inventory_Number__c = 0;
                        inventory.Product__c = stockItem.Product__c;
                        inventory.Customer__c = stockItem.Customer__c;
                        if (stockItem.ProductType__c.contains('Gift')) {
                            inventory.GiftGrid__c = stockItem.GiftGrid__c;
                        }/*else {
                            inventory.Shop__c = stockItem.Shop__c;
                        }*/
                        inventory.Shop__c = stockItem.Shop__c;//add by tiger 20230808
                        inventory.RecordTypeId = storeInventoryRecordId;
                    }
                    if(stockItem.Type__c.equals('In') ){
                        inventory.Inventory_Number__c = inventory.Inventory_Number__c + stockItem.Quantity__c;
                    }else if(stockItem.Type__c.equals('Out')){
                        inventory.Inventory_Number__c = inventory.Inventory_Number__c - stockItem.Quantity__c;
                    }    
                    System.debug('门店库存信息已经更新。');
                }else if (stockItem.RecordTypeId == productGridRecordId ) {
                    //更新网格库存
                    System.debug('inventoryGridDbList--' + JSON.serialize(inventoryGridDbList));
                    List<Object> lp =  new LisqContainer(inventoryGridDbList).WhereAnd(new object[]{'Product__c','=',stockItem.Product__c,
                            'GiftGrid__c','=',stockItem.GiftGrid__c}).ToSobjectList();
                    System.debug(' 网格 lp---' + JSON.serialize(lp));
                    if (lp.Size()>0) {
                        inventory = (Inventory__c)lp[0];
                        stockItem.Inventory__c = inventory.Id;
                    }else {
                        insertInventoryList.add(stockItem);
                        inventory.Inventory_Number__c = 0;
                        inventory.Product__c = stockItem.Product__c;
                        inventory.GiftGrid__c = stockItem.GiftGrid__c;
                        inventory.RecordTypeId = productGridInventoryRecordId;
                    }
                    if(stockItem.Type__c.equals('In') ){
                        inventory.Inventory_Number__c = inventory.Inventory_Number__c + stockItem.Quantity__c;
                    }else if(stockItem.Type__c.equals('Out')){
                        inventory.Inventory_Number__c = inventory.Inventory_Number__c - stockItem.Quantity__c;
                    }    
                    System.debug('grid inventory---' + JSON.serialize(inventory));
                    System.debug('网格库存信息已经更新。');
                }
                if (String.isEmpty(inventory.UniqueKey__c) ) {
                    inventoryList.add(inventory);
                }else {
                    updateinventoryList.add(inventory);
                }               
            }
            if(inventoryList.size()>0){
                insert inventoryList;
                Map<String, String> inventoryMap = new Map<String, String>();
                for (Inventory__c inventory : inventoryList) {
                    if (inventory.RecordTypeId == storeInventoryRecordId) {
                        inventoryMap.put(inventory.Customer__c + ''+inventory.Shop__c + inventory.Product__c + 'Shop', inventory.Id);
                    }
                    if (inventory.RecordTypeId == productInventoryRecordId) {
                        inventoryMap.put(inventory.Customer__c + ''+inventory.Shop__c + inventory.Product__c + 'Channel', inventory.Id);
                    }
                    //网格库存
                    if (inventory.RecordTypeId == productGridInventoryRecordId) {
                        inventoryMap.put(inventory.GiftGrid__c + ''+inventory.Shop__c + inventory.Product__c + 'Grid', inventory.Id);
                    }
                }
                //关联库存
                for (StockItem__c stockItem : insertInventoryList) {
                    String key = stockItem.Customer__c + '' + stockItem.Shop__c + stockItem.Product__c;
                    if (stockItem.RecordTypeId == productRecordId) {
                        key += 'Channel';
                    }else if (stockItem.RecordTypeId == storeRecordId) {
                        key += 'Shop';
                    }else if (stockItem.RecordTypeId == productGridRecordId) {
                        key = stockItem.GiftGrid__c + '' + stockItem.Shop__c + stockItem.Product__c + 'Grid';
                    }
                    if (inventoryMap.containsKey(key) && inventoryMap.get(key)!=null) {
                        System.debug('inventoryMap Inventory__c ---' + inventoryMap.get(key));
                        stockItem.Inventory__c = inventoryMap.get(key);
                    }
                }
                System.debug('关联库存 newList---' + JSON.serialize(newList));
            }
            if (updateinventoryList.size()>0) {
                update updateinventoryList;
            }
        } catch (Exception e) {
            System.debug('updateInventory has a error--'+ e.getMessage() +e.getLineNumber());
            newList[0].addError('updateInventory has a error--'+ e.getMessage() +e.getLineNumber());
        }    
    }   
    
    public static void updateCustomerInfo(List<StockItem__c> newList) {
        LisqContainer lc = new LisqContainer(newList).WhereOne('Shop__c','NOTBLANK','');
        if (lc.Size()>0) {
            Map<Id,SHOP__C> shopMap = new Map<Id,SHOP__C>([
            SELECT 
            	Id,
            	Account__c
            FROM Shop__c
            WHERE Id IN :(lc.selectsField('Shop__c'))
        ]);
        List<String> storeIdList = new List<String>();
        for(Sobject item : lc.ToSobjectList()) {
            if(shopMap.containsKey(item.get('Shop__c')+'')) {
                item.put('Customer__c',shopMap.get(item.get('Shop__c')+'').ACCOUNT__C);
            }
        }
        }
        
    }

    public static void changeSubmitAfter(List<StockItem__c> oldList, List<StockItem__c> newList) {
        String productRecordId = Schema.SobjectType.StockItem__c.getRecordTypeInfosByDeveloperName().get('ProductInventory').getRecordTypeId();
        String storeRecordId = Schema.SobjectType.StockItem__c.getRecordTypeInfosByDeveloperName().get('StoreStock').getRecordTypeId();
        Map<Id, StockItem__c> oldMap = new Map<Id, StockItem__c>(oldList);
        Map<Id, StockItem__c> newMap = new Map<Id, StockItem__c>(newList);
        Map<Id, StockItem__c> changeMap = new Map<Id, StockItem__c>();
        Set<Id> inventoryIds = new Set<Id>();
        for (Id siId : newMap.keySet()) {
            StockItem__c newSi = newMap.get(siId);
            StockItem__c oldSi = oldMap.get(siId);
            if (newSi.Inventory__c != null && (newsi.RecordTypeId == productRecordId || newsi.RecordTypeId == storeRecordId) && (
                newSi.Quantity__c != oldSi.Quantity__c ||
                newSi.TotalPrice__c != oldSi.TotalPrice__c
            )) {
                changeMap.put(siId, newSi);
                inventoryIds.add(newSi.Inventory__c);
            }
        }
        if (changeMap.size()>0) {
            Map<Id, Inventory__c> inventoryMap = new Map<Id, Inventory__c>();
            for (Inventory__c inventory : [SELECT Inventory_Number__c,Product__c FROM Inventory__c WHERE Id IN : inventoryIds]) {
                inventoryMap.put(inventory.Id, inventory);
            }
            if (inventoryMap.size()>0) {
                List<Inventory__c> updateInventory = new List<Inventory__c>();
                for (Id siId : changeMap.keySet()) {
                    StockItem__c newSi = newMap.get(siId);
                    StockItem__c oldSi = oldMap.get(siId);
                    Inventory__c inventory = inventoryMap.get(newSi.Inventory__c);

                    if (oldSi.Type__c.equals('In')) {
                        inventory.Inventory_Number__c -= oldSi.Quantity__c;
                    } else if (oldSi.Type__c.equals('Out')) {
                        inventory.Inventory_Number__c += oldSi.Quantity__c;
                    }
                    updateInventory.add(inventory);
                }
                update updateInventory;
                updateInventory(changeMap.values());
            }
        }
    }
}