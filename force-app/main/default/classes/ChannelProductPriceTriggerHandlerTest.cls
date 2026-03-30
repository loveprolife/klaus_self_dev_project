@IsTest
public without sharing class ChannelProductPriceTriggerHandlerTest{
    @IsTest
    public static void test01(){
        Channel_Product_Price__c cpp = new Channel_Product_Price__c();
        cpp.Sales_Region__c = 'Hisense USA';
        cpp.Price__c = 1;
        insert cpp;
    }

}