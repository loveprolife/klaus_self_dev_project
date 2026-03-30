@isTest
private class GetProductMappingFromGSSTest {
    static testMethod void testMethod1() {
    	TestDataUtility.createMappings();
    	TestDataUtility.createPriceBookList();
        Test.startTest();

        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        //String jsonStr = '{"ProductMappingList":[{"CustomerModel":"CustomerTestProductTV001","FactoryModel":"TestProductTV001","Country":"Test country","ProductLine":"TV","Brand":"Hisense","ExportModel":"Test export model001","GSSSalesRegion":"美国分公司"},{"CustomerModel":"CustomerTestProductTV003","FactoryModel":"TestProductTV001","Country":"Test country","ProductLine":"TV","Brand":"Hisense","ExportModel":"Test export model003","GSSSalesRegion":"美国分公司"},{"CustomerModel":"CustomerTestProductTV003","FactoryModel":"TestProductTV001231","Country":"Test country","ProductLine":"TV","Brand":"Hisense","ExportModel":"Test export model003","GSSSalesRegion":"美国分公司"},{"CustomerModel":"CustomerTestProductWM","FactoryModel":"TestProductWM","Country":"Test country","ProductLine":"TV","Brand":"Hisense","ExportModel":"TestProductWM","GSSSalesRegion":"美国分公司"},{"CustomerModel":"CustomerTestProductWM","FactoryModel":"TestProductWM","Country":"Test country","ProductLine":"TV","Brand":"Hisense","ExportModel":"Test export model003","GSSSalesRegion":"美国分公司"}]}';
        String jsonStr = '{"ProductMappingList":[{"CustomerModel":"CustomerTestProductTV001","FactoryModel":"TestProductTV001","Country":"Test country","ProductLine":"TV","Brand":"Hisense","ExportModel":"Test export model001","GSSSalesRegion":"美国分公司"},{"CustomerModel":"CustomerTestProductTV003","FactoryModel":"TestProductTV001","Country":"Test country","ProductLine":"TV","Brand":"Hisense","ExportModel":"Test export model003","GSSSalesRegion":"美国分公司"},{"CustomerModel":"CustomerTestProductTV001","FactoryModel":"TestProductTV001231","Country":"Test country","ProductLine":"TV","Brand":"Hisense","ExportModel":"Test export model003","GSSSalesRegion":"美国分公司"}]}';
        req.httpMethod = 'POST';
        RestContext.request = req;
        RestContext.response = res;
        req.requestBody = Blob.valueOf(jsonStr);

        GetProductMappingFromGSS.adoPost() ; 
        Test.stopTest();
    }
    //传空数据
    static testMethod void testMethod2() {
        Test.startTest();
        String jsonStr = '{"ProductMappingList": []}';
        RestRequest resq = new RestRequest();
        RestResponse resp = new RestResponse();
        resq.requestBody = Blob.valueOf(jsonStr);
        resq.httpMethod = 'POST';
        RestContext.request = resq;
        RestContext.response = resp;
        GetProductMappingFromGSS.adoPost();
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
        GetProductMappingFromGSS.adoPost();
        Test.stopTest();
    }
    static testMethod void testMethod4() {
    	Test.startTest();
        String jsonStr = '{ "ProductMappingList": [ { "CustomerModel": "客户型号", "ProductLine": "AC", "GSSSalesRegion": "JPProduct" } ] }';
        RestRequest resq = new RestRequest();
        RestResponse resp = new RestResponse();
        resq.requestBody = Blob.valueOf(jsonStr);
        resq.httpMethod = 'POST';
        RestContext.request = resq;
        RestContext.response = resp;
        GetProductMappingFromGSS.adoPost();
        Test.stopTest();
    }

}