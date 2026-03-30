/**
 * @description       : 
 * @author            : ryshen@deloitte.com.cn
 * @group             : 
 * @last modified on  : 03-11-2022
 * @last modified by  : ryshen@deloitte.com.cn
**/
@isTest
private class AsyncGoogleMapTest {

    static testMethod void testHandler() {
        Test.startTest();

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
        
        String json = '{"results":[{"address_components":[{"long_name":"1600","short_name":"1600","types":["street_number"]},{"long_name":"AmphitheatreParkway","short_name":"AmphitheatrePkwy","types":["route"]},{"long_name":"MountainView","short_name":"MountainView","types":["locality","political"]},{"long_name":"SantaClaraCounty","short_name":"SantaClaraCounty","types":["administrative_area_level_2","political"]},{"long_name":"California","short_name":"CA","types":["administrative_area_level_1","political"]},{"long_name":"UnitedStates","short_name":"US","types":["country","political"]},{"long_name":"94043","short_name":"94043","types":["postal_code"]}],"formatted_address":"1600AmphitheatrePkwy,MountainView,CA94043,USA","geometry":{"location":{"lat":37.4267861,"lng":-122.0806032},"location_type":"OOFTOP","viewport":{"northeast":{"lat":37.4281350802915,"lng":-122.0792542197085},"southwest":{"lat":37.4254371197085,"lng":-122.0819521802915}}},"place_id":"ChIJtYuu0V25j4Awu5e4wwYgE","plus_code":{"compound_code":"CWC8+3MountainView,California,UnitedStates","global_code":"849VCWC8+3"},"types":["street_address"]}],"status":"OK"}';
        Test.setMock(HttpCalloutMock.class, new CalloutMock(json));
        Utility.geolocationGetLatLng('北京市');
        List<Shop__c> shopList = new List<Shop__c>();
        shopList.add(shop);

        Map<Integer, List<Shop__c>> shopJobListMap = new Map<Integer, List<Shop__c>>();
        shopJobListMap.put(1, shopList);
        AsyncGoogleMap asyncGoogleMap= new AsyncGoogleMap(shopJobListMap,1);
        ID jobID = System.enqueueJob(asyncGoogleMap);

        Test.stopTest();
    }
}