/**
 * @description       : 
 * @author            : chenpeng@deloitte.com.cn
 * @group             : 
 * @last modified on  : 03-21-2022
 * @last modified by  : chenpeng@deloitte.com.cn
**/
@isTest
public class SFUtilityTest{
    public static User user1;

    private static void makeData(){
        Id profileId = [SELECT Id FROM profile WHERE Name = 'System Administrator' OR Name = '系统管理员'][0].Id;
        user1 = new User(alias = 'test1234', email='test123@noemail.com',
        emailencodingkey='UTF-8', lastname='Testing123', languagelocalekey='en_US',
        localesidkey='en_US', profileid = profileId, country='United States',IsActive =true,
        timezonesidkey='America/Los_Angeles', username='test123@noemail.com');
        INSERT user1;
    }

    @IsTest
    static void writeCallLogsTest(){
        String callParameter;
        for (Integer i = 0; i < 60000; i++) {
            callParameter += '1';
        }

        InterfaceLog__c ic = new InterfaceLog__c();
        ic.IsSuccess__c = true;
        ic.Class__c = 'test';
        ic.Call_Type__c = 'Inbound';
        ic.Res_Json__c = callParameter;
        Test.startTest();
        SFUtility.writeCallLogs(String.valueOf(ic.IsSuccess__c),ic.Class__c,ic.Res_Json__c,ic.Res_Json__c,ic.Call_Type__c,callParameter);
        SFUtility.writeCallLogs(String.valueOf(ic.IsSuccess__c),'test','test','test','test','test');
        Test.stopTest();
        
    }
}