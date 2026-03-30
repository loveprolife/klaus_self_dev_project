@isTest
private class GetFreezerProductFromGSSTest {
    static testMethod void testMethod1() {
        Test.startTest();
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        String jsonStr='{"ProductList":[{"FactoryModel":"A","HighEnd":"","ExportModelName":"+AST-09UR4SVE10B(P)","DoorNumber":"","CoolingMethod":"","VolumeSegment":"","TemperatureControlMode":"美芝-ASM89D18UFZ","VoltageFrequency":"","EnergyEfficiencyRating":"","NominalEnergyConsumption":"","NominalCertification":"","ProductDimensions":"","PowerLineRequirements":"","Appearance":"","LightBoxLight":"","ClimateType":"","EnergyConsumption":"","RefrigeratingCapacity":"","LoadingPickup":"","Noise":"","InternalExternalCondenser":"","RefrigeratingFluid":"","ControlMode":"","HandleType":""}],"access_token":"Bearer SESSION_ID_REMOVED"}';
     
        req.httpMethod = 'POST';
        RestContext.request = req;
        RestContext.response = res;
        req.requestBody = Blob.valueOf(jsonStr);

        GetFreezerProductFromGSS.doPost() ; 
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
        GetFreezerProductFromGSS.doPost();
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
        GetFreezerProductFromGSS.doPost();
        Test.stopTest();
    }
}