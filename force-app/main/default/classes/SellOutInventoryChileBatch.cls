/*
 * @Author: WFC
 * @Date: 2024-05-29 15:51:20
 * @LastEditors: WFC
 * @LastEditTime: 2024-06-03 17:12:42
 * @Description: Database.executeBatch(new SellOutInventoryChileBatch());
 * @FilePath: \HisenseAll20240426\force-app\main\default\classes\SellOutInventoryChileBatch.cls
 */
global class SellOutInventoryChileBatch implements Database.Batchable<sObject>{
    public String query;
    public Date checkDate;

    global SellOutInventoryChileBatch(){
        this.checkDate = Date.today() - 60;
    }

    global Database.QueryLocator start(Database.BatchableContext bc){
        query = 'SELECT Id, ch_store_name__c, ch_store_no__c, cust_model__c, tot_soh__c, create_dt__c, create_dt_date__c, act_price_lcc__c ' + 
                ' FROM BIPT_Chile_sell_out_Inventory__c WHERE create_dt_date__c >=:checkDate';
        return Database.getQueryLocator(query);
    }

    global void execute(Database.BatchableContext bc, List<BIPT_Chile_sell_out_Inventory__c> inventoryList){
        // BIPT 产品集合
        Set<String> productSet = new Set<String>();
        // BIPT 门店编码集合
        Set<String> shopCodeSet = new Set<String>();
        // BIPT key集合
        Set<String> keySet = new Set<String>();
        // 产品map
        Map<String, String> productMap = new Map<String, String>();
        // 门店map
        Map<String, String> shopCodeMap = new Map<String, String>();
        // Inventory_Chile map
        Map<String, Inventory_Chile__c> inventoryChileMap = new Map<String, Inventory_Chile__c>();
        // 要查询的产品门店数据
        for (BIPT_Chile_sell_out_Inventory__c inventory : inventoryList){
            productSet.add(inventory.cust_model__c);
            shopCodeSet.add(inventory.ch_store_no__c);
            keySet.add(inventory.ch_store_no__c + '-' + inventory.cust_model__c);
        }
        List<Product__c> productList = [SELECT Id, Name
                                        FROM Product__c
                                        WHERE sales_region__c = 'Hisense Chile' AND IsActive__c = TRUE AND Name IN:productSet];
        for (Product__c product : productList){
            productMap.put(product.Name, product.Id);
        }
        List<Shop__c> shopList = [SELECT Id, Shop_Code_Text__c
                                  FROM Shop__c
                                  WHERE Sales_Region__c = 'Hisense Chile' AND Shop_Code_Text__c IN:shopCodeSet];
        for (Shop__c shop : shopList){
            shopCodeMap.put(shop.Shop_Code_Text__c, shop.Id);
        }
        List<Inventory_Chile__c> inventoryChileList = [SELECT Id, Key__c, Last_Date__c
                                                       FROM Inventory_Chile__c
                                                       WHERE Key__c IN:keySet];
        for (Inventory_Chile__c ic : inventoryChileList){
            inventoryChileMap.put(ic.Key__c, ic);
        }
        // 门店和产品关联字段赋值
        for (BIPT_Chile_sell_out_Inventory__c inventory : inventoryList){
            if (inventory.act_price_lcc__c != '0'){
                inventory.Product__c = productMap.get(inventory.cust_model__c);
                inventory.Store__c = shopCodeMap.get(inventory.ch_store_no__c);
            }
            // 查询是否已经存在库存表里了
            String key = inventory.ch_store_no__c + '-' + inventory.cust_model__c;
            if (inventoryChileMap.containsKey(key)){
                Inventory_Chile__c ic = inventoryChileMap.get(key);
                if (ic.Last_Date__c < Date.valueOf(inventory.create_dt__c)){
                    ic.Last_Date__c = Date.valueOf(inventory.create_dt__c);
                    ic.BIPT_Chile_sell_out_Inventory__c = inventory.Id;
                    ic.Inventory_Number__c = Decimal.valueOf(inventory.tot_soh__c);
                    inventoryChileMap.put(key, ic);
                }
            } else{
                Inventory_Chile__c ic = new Inventory_Chile__c();
                ic.Store_Code__c = inventory.ch_store_no__c;
                ic.Store__c = shopCodeMap.get(inventory.ch_store_no__c);
                ic.Product_Model__c = inventory.cust_model__c;
                ic.Product__c = productMap.get(inventory.cust_model__c);
                ic.Last_Date__c = Date.valueOf(inventory.create_dt__c);
                ic.BIPT_Chile_sell_out_Inventory__c = inventory.Id;
                ic.Key__c = key;
                ic.Inventory_Number__c = Decimal.valueOf(inventory.tot_soh__c);
                inventoryChileMap.put(key, ic);
            }
        }
        update inventoryList;
        Database.upsert (inventoryChileMap.values(), Inventory_Chile__c.Fields.Key__c, false);
    }

    global void finish(Database.BatchableContext bc){
    }

}