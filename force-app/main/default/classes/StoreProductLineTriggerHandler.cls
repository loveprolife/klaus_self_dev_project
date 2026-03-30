/**************************************************************************************************
 * StoreProductLineTriggerHandler
 * Purpose:StoreProductLineTriggerHandler处理逻辑
 * Author: lizunxing
 * Create Date: 2024-08-19 
***************************************************************************************************/
public class StoreProductLineTriggerHandler implements Triggers.Handler{
    public static User currentUser = [SELECT Id,Name,Username,Profile.name FROM User WHERE Id =:UserInfo.getUserId()]; 

    public void handle() {


        // List<Store_Product_Line__c> splList = [select id,Product_Line__c,Store__c from Store_Product_Line__c];
        // Set<String> keys = new Set<String>();
        // for(Store_Product_Line__c spl : splList){
        //     keys.add(spl.Product_Line__c + spl.Store__c);
        // }

        if (Trigger.isBefore && Trigger.isInsert) {
            
            System.debug('Account-----beforeInsert');
            for (Store_Product_Line__c acc : ((list<Store_Product_Line__c>)Trigger.new)) {
                acc.External_Key__c = acc.Product_Line__c + acc.Store__c;
                // if(keys.add(acc.Product_Line__c + acc.Store__c)){

                // }else{
                //     if(!Test.isRunningTest()){
                //         acc.addError('Product line already exists');
                //     } 
                //     return;
                // }
            }
        }

        if (Trigger.isBefore && Trigger.isUpdate) {
            
            System.debug('Account-----beforeUpdate');
            for (Store_Product_Line__c acc : ((list<Store_Product_Line__c>)Trigger.new)) {
                acc.External_Key__c = acc.Product_Line__c + acc.Store__c;
                // Store_Product_Line__c accOld = (Store_Product_Line__c)Trigger.oldMap.get(acc.Id);
                
                // if(keys.add(acc.Product_Line__c + acc.Store__c)){

                // }else{
                //     if(accOld.Product_Line__c != acc.Product_Line__c){
                //         if(!Test.isRunningTest()){
                //             acc.addError('Product line already exists');
                //         } 
                //         return;
                //     }
                // }
            }
        }

    }
}