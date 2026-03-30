/*
 * @Author: WFC
 * @Date: 2025-03-17 15:57:04
 * @LastEditors: WFC
 * @LastEditTime: 2025-03-17 16:33:38
 * @Description: 
 * @FilePath: \hisense005\force-app\main\default\classes\ChannelProductPriceTriggerHandler.cls
 */
public class ChannelProductPriceTriggerHandler implements Triggers.Handler{
    public void handle() {
        if(Trigger.isBefore && (Trigger.isInsert || Trigger.isUpdate)){
            for (Channel_Product_Price__c cpp : ((list<Channel_Product_Price__c>)Trigger.new)) {
                cpp.Key__c = cpp.Sales_Region__c + '-' + cpp.Channel_item__c + '-' + cpp.Product__c;
            }
        }
    }
}