@isTest
private class SendLoginHistoryToBigDataTest {
    static testMethod void testMethod1() {

        String query = 'SELECT id,LoginType,SourceIp,LoginTime,UserId,Application, Browser, CipherSuite, status, CountryIso, Platform,LoginUrl ' +
            'from LoginHistory where loginTime >= YESTERDAY';

        List<LoginHistory> loginHistoryList = Database.query(query);
        List<Login_History__c> addList = new List<Login_History__c>();
        
        for(LoginHistory loginHistory : loginHistoryList){
            // LoginHistory loginHistory = (LoginHistory)so;
            Login_History__c lh = new Login_History__c();
            lh.UserId__c = loginHistory.UserId;
            lh.LoginId__c = loginHistory.id;
            lh.LoginTime__c = loginHistory.LoginTime;
            lh.LoginType__c = loginHistory.LoginType;
            lh.SourceIp__c = loginHistory.SourceIp;
            lh.Application__c = loginHistory.Application;
            lh.Browser__c = loginHistory.Browser;
            lh.CipherSuite__c = loginHistory.CipherSuite;
            lh.Status__c = loginHistory.Status;
            lh.CountryIso__c = loginHistory.CountryIso;
            lh.Platform__c = loginHistory.Platform;
            lh.LoginUrl__c = loginHistory.LoginUrl;
            addList.add(lh);
            
        }
           
        Database.insert(addList, false);
     

        Test.startTest();

        RestRequest req = new RestRequest();
		req.httpMethod = 'POST';
        RestContext.request = req;
        req.requestBody = Blob.valueOf('{"startTime":"2016-07-02 00:00:00","endTime":"2050-07-03 00:00:00"}');
		SendLoginHistoryToBigData.adoPost();
        req.requestBody = Blob.valueOf('{"startTime":"2023-12-01 00:00:00","en');
        SendLoginHistoryToBigData.adoPost();
        Test.stopTest();
    }
}