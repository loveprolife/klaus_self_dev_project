@isTest
public class StoreViewControllerTest {
    @IsTest
    static void testStoreViewController(){
        Account customerTest = new Account();
        customerTest.Name = '测试StoreView客户0621';
        Insert customerTest;
 
        Shop__c testShop = new Shop__c();
        testShop.name = '测试门店0621(lookup)';
        testShop.City__c = '重庆';
        testShop.Account__c = customerTest.id;
        testShop.Shop_Level__c = 'A';
        Insert testShop;

        Market__c testMarket = new Market__c();
        testMarket.Shop__c = testShop.id;
        testMarket.Status__c = 'new';
        Insert testMarket;

        StoreView__c testStoreView1 = new StoreView__c();
        testStoreView1.Name = 'StoreViewTest111';
        testStoreView1.Store__c = testShop.id;
        testStoreView1.Market__c = testMarket.id;
        testStoreView1.Comments__c = 'StoreView测试1';
        Insert testStoreView1;

        StoreView__c testStoreView2 = new StoreView__c();
        testStoreView2.Name = 'StoreViewTest222';
        testStoreView2.Store__c = testShop.id;
        testStoreView2.Market__c = testMarket.id;
        testStoreView2.Comments__c = 'StoreView测试2';
        Insert testStoreView2;

        List<StoreView__c> StoreViewList = new List<StoreView__c>();
        StoreViewList.add(testStoreView1);
        StoreViewList.add(testStoreView2);
        
        Map<String, String> tet = new Map<String, String>();
        tet.put('Id', testStoreView2.Id);

        //String recordDataJson = JSON.serialize(StoreViewList);
        String recordDataJson = '[{"Id":"a2M0l000001kGIzEAM","Name":"a2M0l000001kGIz","Store__c":"a260l0000016KtCAAU","Comments__c":"test","Market__c":"a1o0l000001E6kKAAS","ContentVersionId__c":"0680l000003MOWEAA4","index":0}]';
        String recordDataJson2 = '[{"Name":"a3M0l000001kGIz","Store__c":"a260l0000016KtCAAU","Comments__c":"test","Market__c":"a1o0l000001E6kKAAS","ContentVersionId__c":"0680l000003MOWEAA4","index":0}]';
        List<String> deleteRecordIdList = new List<String>();
        deleteRecordIdList.add(testStoreView2.id);
        String fileMap = 'fileMap';
        
        Test.startTest();
        StoreViewController.getInitData(testMarket.id);
        StoreViewController.saveRecord(recordDataJson,deleteRecordIdList,testMarket.id,fileMap);
        StoreViewController.saveRecord(recordDataJson2,deleteRecordIdList,testMarket.id,fileMap);
        testStoreView1.Comments__c = '修改';
        update testStoreView1;
        Test.stopTest();
    }
}