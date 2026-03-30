/**
 * @description       : 
 * @author            : chenpeng@deloitte.com.cn
 * @group             : 
 * @last modified on  : 02-11-2022
 * @last modified by  : chenpeng@deloitte.com.cn
**/
@isTest
private class SamplingDetailHandlerTest {
    static testMethod void testHandler() {
		Account acc = new Account();
        acc.Name = 'KS';
		INSERT acc;
        Sampling_Mapping__c sm = new Sampling_Mapping__c();
        sm.Account__c = acc.Id;
        sm.Level__c = 'A';
        sm.Shop_Level__c = 'A';
        INSERT sm;
		Sampling_Standard__c ss = new Sampling_Standard__c();
        ss.Sampling_Mapping__c = sm.Id;
        ss.Channel_Name__c = acc.Id;
        ss.Status__c = 'True';
        ss.Is_Add_ByReport__c = true;
        INSERT ss; 
		Sampling_Detail__c sd = new Sampling_Detail__c();
		sd.Sampling_Standard__c = ss.Id;
        sd.Is_Add__c = '是';
		test.startTest();
        INSERT sd;
        sd.Is_Add__c = '否';
        UPDATE sd;
        sd.Is_Add__c = '是';
        UPDATE sd;
		test.stopTest();
    }
}