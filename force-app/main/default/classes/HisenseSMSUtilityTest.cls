@isTest
public with sharing class HisenseSMSUtilityTest {
    @isTest
    static void test1(){
        HisenseSMSUtility.sendSMS('13800138000', '测试短信');

        HisenseSMSUtility.sendSMS('', '测试短信');

        HisenseSMSUtility.sendSMS(new List<String>(), '测试短信');
        
        HisenseSMSUtility.createLog('测试短信', '测试短信');
        HisenseSMSUtility.saveLog();
    }
}