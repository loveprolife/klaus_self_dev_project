public without sharing class InventoryItemTriggerHandlerHelper2 {
    static String storeRecordId = Schema.SobjectType.StockItem__c.getRecordTypeInfosByDeveloperName().get('StoreStock').getRecordTypeId();
    static String productRecordId = Schema.SobjectType.StockItem__c.getRecordTypeInfosByDeveloperName().get('ProductInventory').getRecordTypeId();
    static String productGridRecordId = Schema.SobjectType.StockItem__c.getRecordTypeInfosByDeveloperName().get('GridInventory').getRecordTypeId();
    
    static String storeInventoryRecordId = Schema.SobjectType.Inventory__c.getRecordTypeInfosByDeveloperName().get('StoreStock').getRecordTypeId();
    static String productInventoryRecordId = Schema.SobjectType.Inventory__c.getRecordTypeInfosByDeveloperName().get('ProductInventory').getRecordTypeId();
    static String productGridInventoryRecordId = Schema.SobjectType.Inventory__c.getRecordTypeInfosByDeveloperName().get('GridInventory').getRecordTypeId();
    public static void copyFieldsFromInventory(List<StockItem__c> newList) {
        Map<Id, Inventory__c>  invMap= new Map<Id, Inventory__c>([
            SELECT 
                ID, 
                Customer__c,
                GiftGrid__c,
                Product__c, 
                Shop__c,
            	RecordTypeId
            from Inventory__c 
            WHERE ID IN :(new LisqContainer(newList)).selectsField('Inventory__c')
        ]);
        for (StockItem__c st : newList) {
            if (!invMap.containsKey(st.Inventory__c)) {
                continue;
            }
            System.debug('st=' + st);
            System.debug('invMap.get(st.Inventory__c)=' + invMap.get(st.Inventory__c));
            if (st.Customer__c == null) {
                st.Customer__c = invMap.get(st.Inventory__c).Customer__c;
            }

            if (st.GiftGrid__c == null) {
                st.GiftGrid__c = invMap.get(st.Inventory__c).GiftGrid__c;
            }

            if (st.Product__c == null) {
                st.Product__c = invMap.get(st.Inventory__c).Product__c;
            }

            if (st.Shop__c == null) {
                st.Shop__c = invMap.get(st.Inventory__c).Shop__c;
            }

            if (invMap.get(st.Inventory__c).Customer__c != st.Customer__c) {
                st.addError('Customer__c does not match Inventory Customer__c');
            }

            if (invMap.get(st.Inventory__c).GiftGrid__c != st.GiftGrid__c) {
                st.addError('GiftGrid__c does not match Inventory GiftGrid__c');
            }

            if (invMap.get(st.Inventory__c).Product__c != st.Product__c) {
                st.addError('Product__c does not match Inventory Product__c');
            }

            if (invMap.get(st.Inventory__c).Shop__c != st.Shop__c) {
                st.addError('Shop__c does not match Inventory Shop__c');
            }
            
            if(st.RecordTypeId == storeRecordId && invMap.get(st.Inventory__c).RecordTypeId != storeInventoryRecordId) {
                st.addError('Sell in RecordType does not match Inventory RecordType');
            }
            
            if(st.RecordTypeId == productRecordId && invMap.get(st.Inventory__c).RecordTypeId != productInventoryRecordId) {
                st.addError('Sell in RecordType does not match Inventory RecordType');
            }
            
            if(st.RecordTypeId == productGridRecordId && invMap.get(st.Inventory__c).RecordTypeId != productGridInventoryRecordId) {
                st.addError('Sell in RecordType does not match Inventory RecordType');
            }

            System.debug('st=' + st);
        }
    }
}