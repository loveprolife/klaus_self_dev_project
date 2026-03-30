/**
 * @description       : 
 * @author            : ryshen@deloitte.com.cn
 * @group             : 
 * @last modified on  : 03-29-2022
 * @last modified by  : chenpeng@deloitte.com.cn
**/
@isTest
public class MessageBoardReadTriggerHandlerTest {
    @IsTest
    static void handleTest(){

        Id profileId = [SELECT Id FROM profile WHERE Name = '巡店员'][0].Id;
        User user1 = new User(alias = '巡店员', email='test123@noemail.com',
        emailencodingkey='UTF-8', lastname='Testing123', languagelocalekey='en_US',
        localesidkey='en_US', profileid = profileId, country='United States',IsActive =true,
        timezonesidkey='America/Los_Angeles', username='test123@noemail.com');
        INSERT user1;

        Shop_Message_Board__c smb = new Shop_Message_Board__c();
        INSERT smb;
        
    }
}