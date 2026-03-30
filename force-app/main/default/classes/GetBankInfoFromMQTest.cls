@isTest
public class GetBankInfoFromMQTest {
    
    @isTest
    static void testMqPost() {
        MDG_Bank__c testBank = new MDG_Bank__c(Name = 'Test Bank', ZYHDM__c = 'H0120235', ZYHBB__c = '02', External_key__c = 'H012023502');
        insert testBank;

        MDG_BANK_INVER__c testBank1 = new MDG_BANK_INVER__c(Name = 'Test Bank', External_key__c = 'H012023502');
        insert testBank1;

        MDG_Bank_VENDOR__c testBank2 = new MDG_Bank_VENDOR__c(Name = 'Test Bank', External_key__c = 'H012023502');
        insert testBank2;

        String jsonRequest = '[{"MSG": {"IV_OUTPUT": {"SENDER": "S0532","INSTID": "005056A9BC391EEFB4FC24D5B2F1649D","REQUESTTIME": "20250116160904","DATA": [{"BANKS": "CN","ZYHDM": "H0120235","ZYHBB": "02","BANKL": "H012023502","SPRAS": "ZH","BANKA": "海信集团财务有限公司","ZLYXT": "","ZLYBM": "","SWIFT": "","PROVZ": "370000000000","ORT01": "370200000000","ZCSBM": "370200000000","STRAS": "","ZYZBM": "","SORT1": "CNAPS","ZQSBM": "907452000024","ZYHFH": "","ZTJJG": "","LOEVM": "","ZQCSJ": "","ZYHLB": "BC-02014","CRDAT": "2025-01-16","CRTIM": "16:09:03","CRNAM": "SAP_WFRT","AEDAT": "","AETIM": "","AENAM": "","INVER": [],"VENDOR": [{"ZGYSLY": "","PARTNER": "0021015646"}]}]}},"MSG_ID": "7F00000100015387F9E050B69A0ED7D0"}]';
        // Set up the mock HTTP request and response
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.requestBody = Blob.valueOf(jsonRequest);
        req.httpMethod = 'POST';
        RestContext.request = req;
        RestContext.response = res;

        // Call the method
        Test.startTest();
        List<GetBankInfoFromMQ.MessageWrapper> messages = GetBankInfoFromMQ.mqPost();
        Test.stopTest();

        // Verify the results
        System.assertNotEquals(null, messages);
        System.assertEquals(1, messages.size());
        System.assertEquals('7F00000100015387F9E050B69A0ED7D0', messages[0].MSG_ID);

        // Verify the Account was updated
        //Account updatedAccount = [SELECT Name, MDG_Customer_Code__c, Trader_Type__c, CustomerDetailType__c, Customer_Name_Local_Language__c FROM Account WHERE Id = :testAccount.Id];
        //System.assertEquals('Group1', updatedAccount.Trader_Type__c);
        //System.assertEquals('Type1', updatedAccount.CustomerDetailType__c);
        //System.assertEquals('Local Name', updatedAccount.Customer_Name_Local_Language__c);
    }
}