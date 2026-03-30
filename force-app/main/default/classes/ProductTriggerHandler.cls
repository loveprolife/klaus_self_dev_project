/*
 * @Author: lizunxing
 * @Date: 2023-12-22
 * @LastEditors: 
 * @LastEditTime: 
 * @Description: 
 * @FilePath: \Hitest_2022\force-app\main\default\classes\ProductTriggerHandler.cls
 */
public class ProductTriggerHandler implements Triggers.Handler{

    
    
    public void handle() {

        if (Trigger.isBefore && Trigger.isInsert) {        
            System.debug('ProductTriggerHandler-----beforeInsert');
            
            for (Product__c p : ((list<Product__c>)Trigger.new)) {
                if(String.isNotBlank(p.sales_region__c)){
                    p.External_key__c = p.name + p.sales_region__c;
                }
            }
        }


        if (Trigger.isBefore && Trigger.isUpdate) {

            System.debug('ProductTriggerHandler-----beforeUpdate');

            for (Product__c p : ((list<Product__c>)Trigger.new)) {
                if(String.isNotBlank(p.sales_region__c)){
                    p.External_key__c = p.name + p.sales_region__c;
                }
            }
        }

        if (Trigger.isBefore && (Trigger.isUpdate || Trigger.isInsert)) {

        }

    }
}