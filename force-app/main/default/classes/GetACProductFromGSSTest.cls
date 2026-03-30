@isTest
private class GetACProductFromGSSTest {
    static testMethod void testMethod1() {
        Test.startTest();
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        String jsonStr = '{"ProductList": [{"FactoryModel": "A","HighEnd": "","OutdoorProductModel": "+AST-09UR4SVE10B(P)","IndoorEnclosure": "G1X","RemoteControlModel": "J1-01","OutdoorProductionModel": "+AST-09UR4SVE1(WLP)(D)","PressModel": "美芝-ASM89D18UFZ","WiFIModuleRequirements": "(按工厂)是","OutdoorEnclosure": "W1M","IDUSize": "","ODUSize": "","IDUPackageSize": "900×335×260","ODUPackageSize": "830×315×530"},{"FactoryModel": "B","HighEnd": "","OutdoorProductModel": "+AST-09UR4SVE10B(P)","IndoorEnclosure": "G1X","RemoteControlModel": "J1-01","OutdoorProductionModel": "+AST-09UR4SVE1(WLP)(D)","PressModel": "美芝-ASM89D18UFZ","WiFIModuleRequirements": "(按工厂)是","OutdoorEnclosure": "W1M","IDUSize": "","ODUSize": "","IDUPackageSize": "900×335×260","ODUPackageSize": "830×315×530"},{"FactoryModel": "A","HighEnd": "","OutdoorProductModel": "+AST-09UR4SVE10B(P)","IndoorEnclosure": "G1X","RemoteControlModel": "J1-01","OutdoorProductionModel": "+AST-09UR4SVE1(WLP)(D)","PressModel": "美芝-ASM89D18UFZ","WiFIModuleRequirements": "(按工厂)是","OutdoorEnclosure": "W1M","IDUSize": "","ODUSize": "","IDUPackageSize": "900×335×260","ODUPackageSize": "830×315×530"}],"access_token": "Bearer SESSION_ID_REMOVED"}';
     
        req.httpMethod = 'POST';
        RestContext.request = req;
        RestContext.response = res;
        req.requestBody = Blob.valueOf(jsonStr);

        GetACProductFromGSS.adoPost() ; 
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
        GetACProductFromGSS.adoPost();
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
        GetACProductFromGSS.adoPost();
        Test.stopTest();
    }
}