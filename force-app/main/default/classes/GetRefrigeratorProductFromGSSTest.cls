@isTest
private class GetRefrigeratorProductFromGSSTest {
    static testMethod void testMethod1() {
        Test.startTest();
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        String jsonStr='{"ProductList":[{"FactoryModel":"A090","HighEnd":"","BasicProduct":"+AST-09UR4SVE10B(P)","CustomerType":"","DoorNumber":"","IsFrequencyConversion":"","CoolingMethod":"","ColumeCegment":"","TemperatureControlMode":"","BottlingAmount":"","Refrigerant":"","VoltageFrequency":"","ClimateType":"","PowerConsumption":"","EnergyRequirements":"","FreezingAbility":"","PowerLineRequirements":"","VendorBrand":"","BoundaryDimensionW":"","TotalVolume":"","ColdStorageVolume":"","FrozenVolume":"","RefrigeratingDoorConfiguration":"","RefrigeratingShelf":"","RefrigeratingFruitBoxCover":"","FreezingDoorConfiguration":"","FreezingRoomConfiguration":"","PanelPattern":"","HandleAppearance":"","WaterFeatures":"","IRCompleteDate":"","RefrigeratorType":""}],"access_token":"Bearer SESSION_ID_REMOVED"}';
     
        req.httpMethod = 'POST';
        RestContext.request = req;
        RestContext.response = res;
        req.requestBody = Blob.valueOf(jsonStr);

        GetRefrigeratorProductFromGSS.adoPost() ; 
        Test.stopTest();
    }
    //传空数据
    static testMethod void testMethod2() {
        Test.startTest();
        String jsonStr = '{"ProductList": []}';
        RestRequest resq = new RestRequest();
        RestResponse resp = new RestResponse();
        resq.requestBody = Blob.valueOf(jsonStr);
        resq.httpMethod = 'POST';
        RestContext.request = resq;
        RestContext.response = resp;
        GetRefrigeratorProductFromGSS.adoPost();
        Test.stopTest();
    }
     //传错误数据
    static testMethod void testMethod3() {
    	Test.startTest();
        String jsonStr = '"fudgs"';
        RestRequest resq = new RestRequest();
        RestResponse resp = new RestResponse();
        resq.requestBody = Blob.valueOf(jsonStr);
        resq.httpMethod = 'POST';
        RestContext.request = resq;
        RestContext.response = resp;
        GetRefrigeratorProductFromGSS.adoPost();
        Test.stopTest();
    }
}