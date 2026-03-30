@isTest
public class Gridding_Shop_MapControllerTest {
    static testMethod void testGridding_Shop_MapController(){
        Account acc = new Account();
        acc.Name = 'KS';
		INSERT acc;
        Product__c pro = new Product__c();
        pro.Level__c = 'A';
        INSERT pro;
        Gridding__c gird1 = new Gridding__c();
        gird1.Name = 'test002';
        gird1.Gridding_Level__c = 'B';
        gird1.Gridding_Code__c  = 'J01-J001';
        INSERT gird1;
        Shop__c shop = new Shop__c();
        shop.Account__c = acc.Id;
        shop.Shop_Level__c = 'A';
        shop.Grid__c = gird1.id;
        shop.City__c = '北京市';
        INSERT shop;
        
        test.startTest();
        Gridding_Shop_MapController.getVisualforceOrigin();
        Gridding_Shop_MapController.searchShopData(gird1.Id);
        test.stopTest();
    } 
}