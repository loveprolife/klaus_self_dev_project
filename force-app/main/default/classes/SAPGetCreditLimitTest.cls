@isTest
private class SAPGetCreditLimitTest {
    static testMethod void testMethod1() {
        Test.startTest();
        Contact con = new Contact();
        con.lastname = '111';
        con.Email = 'qinyanhao@hisense.com';
        Database.insert(con);
        TestDataUtility.createCustomSettings();
        List<Account> accList = TestDataUtility.createAccountList(true);
        SAPGetCreditLimit.syncCreditLimitOverdueFromSAP('1234567890');
        SAPGetCreditLimit.syncCreditLimitOverdueFromSAPSchedulable('1234567890', true, 'JP');
        SAPGetCreditLimit.syncCreditLimitOverdueFromSAPSchedulable('1234567890', true, 'SA');
        Test.stopTest();
    }
}