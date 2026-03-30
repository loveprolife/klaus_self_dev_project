@isTest
private class LocationControllerTest {
    static testMethod void testMethod1() {
        String profileName = '促销员';
        Id profileId = [SELECT Id
                        FROM profile
                        WHERE Name = :'South Africa Store Manager'].get(0).Id;
        User user1 = new User(
            alias = '促销员', 
            email = 'TestCX@noemail.com', 

            emailencodingkey = 'UTF-8', 
            lastname = 'TestCX', 
            languagelocalekey = 'en_US', 
            Sales_Region__c = 'Hisense South Africa', 
            localesidkey = 'en_US', 
            profileid = profileId, 
            country = 'South Africa', 
            Country__c = 'South Africa', 
            IsActive = true, 
            timezonesidkey = 'America/Los_Angeles', 
            username = 'testCX120231@noemail.com'
        );
        INSERT user1;

        Account acc = new Account();
        acc.Name = 'test';
        INSERT acc;

        Gridding__c grid = new Gridding__c();
        grid.Gridding_Code__c = 'TEST GUID';
        insert grid;

        Shop__c shop1 = new Shop__c();
        shop1.Account__c = acc.id;
        shop1.Shop_Level__c = 'A';
        shop1.Name = '可乐店';
        shop1.City__c = '北京市';
        shop1.Shop_Code_Text__c = '90999';
        shop1.Grid__c = grid.id;
        shop1.Shop_Center_Location__Latitude__s = 29.4545;
        shop1.Shop_Center_Location__Longitude__s = 106.509;
        shop1.Country__c = 'CN';
        shop1.State_Province__c = '山东';
        Insert shop1;

        Country_State__c countryState = new Country_State__c(
            Name = '山东',
            Belong_To__c = 'CN',
            ex_id__c = 'test111111'
        );
        Insert countryState;

        LocationController.getShop(Double.valueOf('35.570'), Double.valueOf('139.362'), 100);
        LocationController.saveShop(JSON.serialize(shop1));
        LocationController.searchShop(shop1.Id);
        LocationController.getShopDetail(shop1.Id);
        LocationController.getAddress(acc.Id);
        LocationController.getCustomChannel();
        LocationController.getUserInfo();
        LocationController.getCountryStateId('CN', '山东');
    
    }
}