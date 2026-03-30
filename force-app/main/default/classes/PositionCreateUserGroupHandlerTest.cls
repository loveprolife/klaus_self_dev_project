/**
 * @description       : 
 * @author            : chenpeng@deloitte.com.cn
 * @group             : 
 * @last modified on  : 03-21-2022
 * @last modified by  : chenpeng@deloitte.com.cn
**/
@isTest
private class PositionCreateUserGroupHandlerTest {
    public static Position_Member__c pm;
    public static User user1;
    public static Group gro;
    public static  Position__c pos;

    private static void makeData(){

        Id profileId = [SELECT Id FROM profile WHERE Name = 'System Administrator' OR Name = '系统管理员'][0].Id;
        user1 = new User(alias = 'test1234', email='test123888@noemail.com',
        emailencodingkey='UTF-8', lastname='Testing123', languagelocalekey='en_US',
        localesidkey='en_US', profileid = profileId, country='United States',IsActive =true,
        timezonesidkey='America/Los_Angeles', username='test123888@noemail.com');
        INSERT user1;
	
        pos = new Position__c();
        pos.DeveloperName__c = 'FU_GUAN_PATROLCLERKTEST';
        pos.Grouo_Name__c = '福关网格巡店员TEST';
        pos.Activity__c = true;
        pos.DoesIncludeBosses__c = false;
        INSERT pos;

        pos.DoesIncludeBosses__c = true;
        UPDATE pos; 
    }

    static testMethod void testHandle() {
        makeData();
        Test.startTest();
        DELETE pos;
        Test.stopTest();
    }

}