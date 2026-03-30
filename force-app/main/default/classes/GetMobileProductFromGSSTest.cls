@isTest
private class GetMobileProductFromGSSTest {
    static testMethod void testMethod1() {
        Test.startTest();
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        String jsonStr = '{"ProductList": [{"FactoryModel": "123Test","HighEnd": "1","ProjectType": "1","ProductManager": "1","BandGSM": "1","BandWCDMA": "1","BandCDMA": "1","BandLTE": "1","LCDTPSize": "1","LCDTPResolution": "1","CPUPlatform": "1","MemoryROM": "1","MemoryRAM": "1","MainPixel": "1","SubPixel": "1","Packaging BoxType": "1","AndroidVersion": "1","ProductionBase": "1","ExportModel": "A"},{"FactoryModel": "1dfs","HighEnd": "1","ProjectType": "1","ProductManager": "1","BandGSM": "1","BandWCDMA": "1","BandCDMA": "1","BandLTE": "1","LCDTPSize": "1","LCDTPResolution": "1","CPUPlatform": "1","MemoryROM": "1","MemoryRAM": "1","MainPixel": "1","SubPixel": "1","Packaging BoxType": "1","AndroidVersion": "1","ProductionBase": "1","ExportModel": "A"},{"FactoryModel": "1gdfgd","HighEnd": "1","ProjectType": "1","ProductManager": "1","BandGSM": "1","BandWCDMA": "1","BandCDMA": "1","BandLTE": "1","LCDTPSize": "1","LCDTPResolution": "1","CPUPlatform": "1","MemoryROM": "1","MemoryRAM": "1","MainPixel": "1","SubPixel": "1","Packaging BoxType": "1","AndroidVersion": "1","ProductionBase": "1","ExportModel": "B"},{"FactoryModel": "1dgds56y","HighEnd": "1","ProjectType": "1","ProductManager": "1","BandGSM": "1","BandWCDMA": "1","BandCDMA": "1","BandLTE": "1","LCDTPSize": "1","LCDTPResolution": "1","CPUPlatform": "1","MemoryROM": "1","MemoryRAM": "1","MainPixel": "1","SubPixel": "1","Packaging BoxType": "1","AndroidVersion": "1","ProductionBase": "1","ExportModel": ""}]}';

     
        req.httpMethod = 'POST';
        RestContext.request = req;
        RestContext.response = res;
        req.requestBody = Blob.valueOf(jsonStr);

        GetMobileProductFromGSS.doPost() ; 
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
        GetMobileProductFromGSS.doPost();
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
        GetMobileProductFromGSS.doPost();
        Test.stopTest();
    }
}