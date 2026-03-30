@isTest
public class LookupControllerTest {
	@IsTest
    static void testLookupController(){

        Account customerTest = new Account();
        customerTest.Name = '测试客户0621';
        Insert customerTest;

        Gridding__c grid = new Gridding__c();
        grid.Gridding_Code__c = 'TEST GUID';
        insert grid;

        Shop__c testShop1 = new Shop__c();
        testShop1.name = '测试门店0621';
        testShop1.City__c = '重庆';
        testShop1.Grid__c = grid.id;
        testShop1.Shop_Code_Text__c = '90999';
        testShop1.Shop_Center_Location__Latitude__s = 29.4545;
        testShop1.Shop_Center_Location__Longitude__s = 106.509;
        testShop1.Account__c = customerTest.id;
        testShop1.Shop_Level__c = 'A';
        Insert testShop1;

        Shop__c testShop2 = new Shop__c();
        testShop2.name = '测试门店0621(lookup)';
        testShop2.City__c = '重庆';
        testShop2.Grid__c = grid.id;
        testShop2.Shop_Code_Text__c = '90988';
        testShop2.Shop_Center_Location__Latitude__s = 29.4545;
        testShop2.Shop_Center_Location__Longitude__s = 106.509;
        testShop2.Account__c = customerTest.id;
        testShop2.Shop_Level__c = 'A';
        Insert testShop2;

        String searchKey = '测试门店0621(lookup)';
        String sObjectApiName = 'Shop__c';
        List<Schema.DescribeTabSetResult> tabSetDesc = Schema.describeTabs();
        List<Schema.DescribeTabResult> tabDesc = new List<Schema.DescribeTabResult>();
        
        for(Schema.DescribeTabSetResult tsr : tabSetDesc) { tabDesc.addAll(tsr.getTabs()); }
        String sObjectName = tabDesc.get(5).getSobjectName();

        Test.startTest();
        
        //LookupController.fetchDefaultRecord(testShop1.id,sObjectApiName);
        LookupController.getLookupData(searchKey,sObjectApiName,null);
        LookupController.getDefaultRecord(testShop2.id, '');
        //LookupController.getIconName(sObjectName);
        
        //{'lookup' : 'CustomLookupProvider.ProductAllFilter'}
        Map<String, String> optionMap = new Map<String, String>{'lookup' => 'CustomLookupProvider.ProductAllFilter'};
        String optionJson = JSON.serialize(optionMap);
        LookupController.getLookupData(searchKey, sObjectApiName, optionJson);

        Map<String, String> optionMap1 = new Map<String, String>{'lookup' => 'CustomLookupProvider.InternationalProductFilter'};
        String optionJson1 = JSON.serialize(optionMap1);
        LookupController.getOfficeLookupData('Hisense USA',searchKey, 'Product__c', optionJson1);
        /*
        // productLookup: {'lookup' : 'CustomLookupProvider.ProductFilter','Product_Line__c' : checkResultsInfoItem.Product__r.Product_Line__c}
        Map<String, String> optionMap2 = new Map<String, String>{'lookup' => 'CustomLookupProvider.ProductFilter',
            														'City__c' => '重庆'};
        String optionJson2 = JSON.serialize(optionMap2);
        LookupController.getLookupData(searchKey, sObjectApiName, optionJson2);
        
        Map<String, String> optionMap3 = new Map<String, String>{'lookup' => 'CustomLookupProvider.Test'};
        String optionJson3 = JSON.serialize(optionMap3);
        LookupController.getLookupData(searchKey, sObjectApiName, optionJson3);
        
        Map<String, String> optionMap4 = new Map<String, String>{'lookup' => 'CustomLookupProvider.UserFilter'};
        String optionJson4 = JSON.serialize(optionMap4);
        LookupController.getLookupData(searchKey, sObjectApiName, optionJson4);
        */
        LookupController.getOfficeLookupData('','', 'Product__c',JSON.serialize(new Map<String, String>{'lookup' => 'CustomLookupProvider.InternationalProductFilter'}));
        LookupController.getLookupData('', 'Product__c',JSON.serialize(new Map<String, String>{'lookup' => 'CustomLookupProvider.ProductAllFilter'}));
        LookupController.getLookupData('', 'Product__c',JSON.serialize(new Map<String, String>{'lookup' => 'CustomLookupProvider.ProductFilter'}));
        LookupController.getLookupData('', 'Product__c',JSON.serialize(new Map<String, String>{'lookup' => 'CustomLookupProvider.ProductGift'}));
        LookupController.getLookupData('', 'User',JSON.serialize(new Map<String, String>{'lookup' => 'CustomLookupProvider.UserFilter'}));
        LookupController.getLookupData('', 'Account',JSON.serialize(new Map<String, String>{'lookup' => 'CustomLookupProvider.BrandContainsHisense'}));
        LookupController.getLookupData('', 'Account',JSON.serialize(new Map<String, String>{'lookup' => 'CustomLookupProvider.BrandDoNotContainsHisense'}));
        Test.stopTest();
    }
}