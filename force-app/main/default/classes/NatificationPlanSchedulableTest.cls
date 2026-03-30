/**
 * @description       : 
 * @author            : chenpeng@deloitte.com.cn
 * @group             : 
 * @last modified on  : 03-29-2022
 * @last modified by  : chenpeng@deloitte.com.cn
**/
@isTest
public class NatificationPlanSchedulableTest {
    public static String CRON_EXP = '0 0 1 * * ?';
    static testMethod void stestNatificationPlanSchedulable(){
        String profileName = '巡店员'; 
        Id profileId = [SELECT Id FROM profile WHERE Name = :profileName][0].Id;
        User user1 = new User(alias = '巡店员', email='test123@noemail.com',
        emailencodingkey='UTF-8', lastname='Testing123', languagelocalekey='en_US',
        localesidkey='en_US', profileid = profileId, country='United States',IsActive =true,
        timezonesidkey='America/Los_Angeles', username='test123@noemail.com');
        INSERT user1;
        
        Date today = System.today();
        today = today.addMonths(1);
        Inspection_Shop_Plan__c isp = new Inspection_Shop_Plan__c();
        isp.Inspection_Year__c = String.valueOf(today.year());
        isp.Inspection_Month__c = String.valueOf(today.month());
        isp.OwnerId = user1.Id;
        // INSERT isp;
        test.startTest();
        
        System.schedule('Test my class',CRON_EXP,new NatificationPlanSchedulable());
        test.stopTest();

    }
    
}