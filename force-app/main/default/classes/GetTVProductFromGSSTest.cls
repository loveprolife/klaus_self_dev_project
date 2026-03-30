@isTest
private class GetTVProductFromGSSTest {
    static testMethod void testMethod1() {
        Test.startTest();
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        String jsonStr='{"ProductList":[{"FactoryModel":"A","HighEnd":"","Size":"","ScreenType":"","PanelType":"","MovementName":"","BatchTargetTime":"","EXWTarget":"","EXWActual":"","DRTime":"","IRTime":"","FrontCaseColor":"","BackCoverColor":"","PedestalColor":"","PanelManufacturers":"","CustomerModel":"","MajorFunction":"","EstimatedDRTime":"","EstimatedIRTime":"","SalesSeries":"","TVType1":"","TVType2":"","TVType3":"","TVType4":"","PlaneSurface":"","RefreshRate":""}],"access_token":"Bearer SESSION_ID_REMOVED"}';
     
        req.httpMethod = 'POST';
        RestContext.request = req;
        RestContext.response = res;
        req.requestBody = Blob.valueOf(jsonStr);

        GetTVProductFromGSS.doPost() ; 
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
        GetTVProductFromGSS.doPost();
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
        GetTVProductFromGSS.doPost();
        Test.stopTest();
    }
}