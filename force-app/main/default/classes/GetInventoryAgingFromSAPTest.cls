@isTest
private class GetInventoryAgingFromSAPTest {
    static testMethod void testMethod1() {
        Test.startTest();
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        String jsonStr = '{"InventoryAgingList": [{"AbnormalInventoryTotalQty" : "167","AbnormalInventoryTotalAmt" : "45460.46","AClassQtyOverPlannedTurnover" : "167","AClassAmtOverPlannedTurnover": "45460.46","DivisionText": "Appliances-WineCabi","LocationCategory" : "BB-LA-HA-COSTCOD","StorageLocation" : "G095", "CustomerMode": "HWS54049SS","Material" : "1J0138Z0009J", "CurrentQty" : "167", "CurrentAmt" : "45460.46", "X1monthQty" : "0", "X1monthAmt" : "0", "X2monthsQty" : "144", "X2monthsAmt" : "39199.44", "X3monthsQty" : "23", "X3monthsAmt" : "6261.02", "X4_6monthQty"   : "0", "X4_6monthAmt"   : "0", "X7mon_1YQty" : "0", "X7mon_1YAmt" : "0", "X1_2yearQty" : "0", "X1_2yearAmt" : "0", "Over2yearQty" : "0", "Over2yearAmt" : "0","SalesOrganization":"8110","FactoryMode":"www", "Division":"www", "Brand":"www", "BrandDescription":"www", "Vendor":"www", "VendorName":"www", "CurrentAmtAdjust":"22.22"},{"AbnormalInventoryTotalQty" : "167","AbnormalInventoryTotalAmt" : "45460.46","AClassQtyOverPlannedTurnover" : "167","AClassAmtOverPlannedTurnover": "45460.46","DivisionText": "Appliances-WineCabi","LocationCategory" : "BB-LA-HA-COSTCOD","StorageLocation" : "G095", "CustomerMode": "HWS54049SS","Material" : "1J0138Z0009J", "CurrentQty" : "167", "CurrentAmt" : "45460.46", "X1monthQty" : "0", "X1monthAmt" : "0", "X2monthsQty" : "144", "X2monthsAmt" : "39199.44", "X3monthsQty" : "23", "X3monthsAmt" : "6261.02", "X4_6monthQty"  : "0", "X4_6monthAmt"   : "0", "X7mon_1YQty" : "0", "X7mon_1YAmt" : "0", "X1_2yearQty" : "0", "X1_2yearAmt" : "0", "Over2yearQty" : "0", "Over2yearAmt" : "0","SalesOrganization":"8110","FactoryMode":"www", "Division":"www", "Brand":"www", "BrandDescription":"www", "Vendor":"www", "VendorName":"www", "CurrentAmtAdjust":"22.22"}],"access_token": "Bearer SESSION_ID_REMOVED"}';
     
        req.httpMethod = 'POST';
        RestContext.request = req;
        RestContext.response = res;
        req.requestBody = Blob.valueOf(jsonStr);

        GetInventoryAgingFromSAP.adoPost() ; 
        Test.stopTest();
    }
    //传空数据
    static testMethod void testMethod2() {
        Test.startTest();
        String jsonStr = '{"InventoryAgingList": []}';
        RestRequest resq = new RestRequest();
        RestResponse resp = new RestResponse();
        resq.requestBody = Blob.valueOf(jsonStr);
        resq.httpMethod = 'POST';
        RestContext.request = resq;
        RestContext.response = resp;
        GetInventoryAgingFromSAP.adoPost();
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
        GetInventoryAgingFromSAP.adoPost();
        Test.stopTest();
    }
}