@isTest
public class RefreshShopGriddingBatchTest{
    @IsTest
    static void testRefreshShopGriddingBatch(){
        Shop__c shop = new Shop__c();
        shop.Shop_Level__c = 'A';
        shop.City__c = '北京市';
        INSERT shop;
        Test.startTest();
        RefreshShopGriddingBatch rsgb = new RefreshShopGriddingBatch();
        Database.executeBatch(rsgb);
        Test.stopTest();
        
    }

}