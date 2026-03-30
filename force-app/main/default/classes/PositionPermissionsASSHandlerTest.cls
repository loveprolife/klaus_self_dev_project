/**
 * @description       : 
 * @author            : ryshen@deloitte.com.cn
 * @group             : 
 * @last modified on  : 03-21-2022
 * @last modified by  : chenpeng@deloitte.com.cn
**/
@isTest
public class PositionPermissionsASSHandlerTest {
    public static Position_Member__c pm;
    public static User user1;
    static testMethod void testPositionPermissionsAccShopShareHandler(){
        Id profileId = [SELECT Id FROM profile WHERE Name = 'System Administrator' OR Name = '系统管理员'][0].Id;
        user1 = new User(alias = 'test1234', email='test123@noemail.com',
        emailencodingkey='UTF-8', lastname='Testing123', languagelocalekey='en_US',
        localesidkey='en_US', profileid = profileId, country='United States',IsActive =true,
        timezonesidkey='America/Los_Angeles', username='test123@noemail.com');
        INSERT user1;

        Account acc = new Account();
        acc.Name = 'test001';
        INSERT acc;
	
        Position__c pos = new Position__c();
        pos.DeveloperName__c = 'FU_GUAN_PATROLCLERKTEST';
        pos.Grouo_Name__c = '福关网格巡店员TEST';
        pos.Activity__c = true;
        INSERT pos;
        
        Position_Permissions__c position = new Position_Permissions__c();
        position.Account__c = acc.Id;
        position.Position__c = pos.Id;
        position.Product_Line__c = 'Mobile';
        INSERT position;

        pm = new Position_Member__c();
        pm.User__c = user1.Id;
        pm.Position__c = pos.Id;
        INSERT pm;
		
		DELETE position;        
       
    }
}