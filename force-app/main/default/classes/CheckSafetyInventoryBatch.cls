/*
 * @Author: Su,Tiger Shanhu
 * @Date: 2023-07-03 17:12:21
 * @LastEditors: Su,Tiger Shanhu
 * @LastEditTime: 2023-07-05 15:07:55
 * @Description: Daily safety stock checks
 */

global class CheckSafetyInventoryBatch implements Schedulable,Database.Batchable<sObject>,Database.Stateful,Database.AllowsCallouts{
    public String query;
    static List<Messaging.SingleEmailMessage> emailList = new List<Messaging.SingleEmailMessage>();
    static List<Messaging.CustomNotification> notificationList = new List<Messaging.CustomNotification>();
    public CheckSafetyInventoryBatch() {
        query = 'select id,SafetyInventory__c, RealStock__c, RecordTypeId, RecordType.DeveloperName, Shop__c, Customer__c,Customer__r.Name, Shop__r.Name, Product__r.Name,Product__r.Product_Line__c from Inventory__c  where InventoryWarning__c = true and SendInventoryWarning__c = true';
        //String testId ='0010l00001cSG41AAG';
        //query = 'select id,SafetyInventory__c, RealStock__c, RecordTypeId, RecordType.DeveloperName, Shop__c, Customer__c,Customer__r.Name, Shop__r.Name, Product__r.Name,Product__r.Product_Line__c from Inventory__c  where InventoryWarning__c = true and Customer__c =\''+ testId + '\'';
       
    }
    global void execute(SchedulableContext sc) {
        Database.executeBatch(this,1);
    }

    global Database.QueryLocator start(Database.BatchableContext bc) {
        System.debug('query--- ' + query);
        return Database.getQueryLocator(query);
    }

    global void execute(Database.BatchableContext BC, list<Inventory__c> inventoryLists) {
        System.debug('inventoryLists---' + JSON.serialize(inventoryLists));
        Id productInventroy = Schema.SobjectType.Inventory__c.getRecordTypeInfosByDeveloperName().get('ProductInventory').getRecordTypeId();
        Id storeStock = Schema.SobjectType.Inventory__c.getRecordTypeInfosByDeveloperName().get('StoreStock').getRecordTypeId();
        
        //get StoreStock record
        list<Inventory__c> productInventoryList =new LisqContainer(inventoryLists).WhereOne('RecordTypeId','=',productInventroy).ToSobjectList();
        list<Inventory__c> storeStockInventoryList =new LisqContainer(inventoryLists).WhereOne('RecordTypeId','=',storeStock).ToSobjectList();
        List<String> shopIdList = new LisqContainer(storeStockInventoryList).SelectField('Shop__c').ToS();
        List<String> customerIdList = new LisqContainer(productInventoryList).SelectField('Customer__c').ToS();
 
        //查询关联关系
        Map<String, LisqContainer> responsibleMap = new Map<String, LisqContainer>();
        responsibleMap = new LisqContainer([select id ,Shop_Name__c, Principal__c, Principal__r.Name,Principal__r.Email, UserEmailF__c from Responsible_Person__c WHERE Shop_Name__c =:shopIdList]).GroupByS('Shop_Name__c');
        //门店网格关系
        Map<String, String> shopGridMap = new Map<String, String>();
        for (Shop__c shop : [select id,Grid__c,GiftGrid__c from Shop__c WHERE id= :shopIdList]) {
            shopGridMap.put(shop.Id, shop.GiftGrid__c);
        }
        Map<String, LisqContainer> responsibleGridMap = new Map<String, LisqContainer>();
        responsibleGridMap = new LisqContainer([select id,Gridding__c, ResponsiblePerson__c,ResponsiblePerson__r.Email,ResponsiblePersonEmail__c  from ResponsibleManager__c where RecordType.DeveloperName = 'Grid' and Gridding__c =:shopGridMap.values()]).GroupByS('Gridding__c');
        //渠道关联关系
        Map<String, LisqContainer> responsibleManaggerMap = new Map<String, LisqContainer>();
        responsibleManaggerMap = new LisqContainer([select id,Customer__c, ResponsiblePerson__c,ResponsiblePerson__r.Email,ResponsiblePersonEmail__c  from ResponsibleManager__c where RecordType.DeveloperName = 'Customer' and Customer__c =:customerIdList]).GroupByS('Customer__c');
        
        //组装email
        for (Inventory__c inventory : productInventoryList) {
            if (String.isNotEmpty(inventory.Customer__c) && responsibleManaggerMap.containsKey(inventory.Customer__c)) {
                String body = inventory.Customer__r.Name + ': Product :' + inventory.Product__r.Product_Line__c + inventory.Product__r.Name;
                LisqContainer lp = responsibleManaggerMap.get(inventory.Customer__c);
                System.debug('lp--' + JSON.serialize(lp)); 
                emailList.add(createMessage(lp.SelectField('ResponsiblePersonEmail__c').ToS(),body));
                Set<String> lStrings = new Set<String>(lp.SelectField('ResponsiblePerson__c').ToS());
                createNotification(lStrings,body,inventory.Id);
            }
        }

        for (Inventory__c inventory : storeStockInventoryList) {
            String body = inventory.Shop__r.Name + ': Product :' + inventory.Product__r.Product_Line__c + inventory.Product__r.Name;
            List<String> toList = new List<String>();
            List<String> toIdList = new List<String>();
            if (String.isNotEmpty(inventory.Shop__c) && responsibleMap.containsKey(inventory.Shop__c)) {
                LisqContainer lp = responsibleMap.get(inventory.Shop__c);
                System.debug('lp--' + JSON.serialize(lp));
                toList = lp.SelectField('UserEmailF__c').ToS();
                toIdList = lp.SelectField('Principal__c').ToS();
            }
            if (String.isNotEmpty(inventory.Shop__c) && shopGridMap.containsKey(inventory.Shop__c)) {
                LisqContainer lp = responsibleGridMap.get(shopGridMap.get(inventory.Shop__c));
                if (lp !=null) {
                    List<String> respList = lp.SelectField('ResponsiblePersonEmail__c').ToS();
                    System.debug('respList' + JSON.serialize(respList));
                    if (respList.size()>0) {
                        toList.addAll(respList);
                        toIdList.addAll(lp.SelectField('ResponsiblePerson__c').ToS());
                    }
                }
            }
            if (toList.size()>0) {
                emailList.add(createMessage(toList,body));
                Set<String> lStrings = new Set<String>(toIdList);
                createNotification(lStrings,body,inventory.Id);
            }
        }
        System.debug('emailList---' + JSON.serialize(emailList));
        try {
            System.debug('预警邮件发送1----');
            System.debug('emailList.size---' + emailList.size());
            if (emailList.size()>0) {
                System.debug('预警邮件发送2----');
                List<Messaging.SendEmailResult> resultList =   Messaging.sendEmail(emailList,true);
                System.debug( 'resultList' + JSON.serialize(resultList));
            } 
            System.debug('预警邮件发送成功----');
        } catch (Exception e) {
            System.debug('CheckSafetyInventoryBatch has a error:'+ e.getMessage() +'line:' +e.getLineNumber());
        }
    }
    global void finish(Database.BatchableContext BC) {

        
        
    }

    public static Messaging.SingleEmailMessage createMessage(List<String> toList,String body) {
        Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
        email.setToAddresses(tolist);
        email.setHtmlBody('Hello, <br/><br/>'+body + '. <br/>Inventory is already below safety stock, please restock<br/><br/>');
        email.setSubject('Out of stock warning alerts');
        email.setCharset('UTF-8');
        System.debug('email--' + JSON.serialize(email));
        return email;
    }

    public static void createNotification(Set<String> toList,String body,Id targtId) {
       try {
        CustomNotificationType safetyInventoryNotification = [SELECT Id, DeveloperName 
             								FROM CustomNotificationType 
             								WHERE DeveloperName='Custom_Notification' LIMIT 1];
        
        Messaging.CustomNotification newNoti = new Messaging.CustomNotification(
            safetyInventoryNotification.Id, null, 'Out of stock warning alerts', 'Hello, <br/><br/>'+body + '. <br/>Inventory is already below safety stock, please restock<br/><br/>', targtId, null
        );
        System.debug( 'safetyInventoryNotification---' + JSON.serialize(newNoti));
        System.debug('toList---' + JSON.serialize(toList));
        newNoti.send(toList);
       } catch (Exception e) {
         System.debug('send notification has a error' + e.getMessage() +e.getLineNumber());
       }
        
    }
    
}