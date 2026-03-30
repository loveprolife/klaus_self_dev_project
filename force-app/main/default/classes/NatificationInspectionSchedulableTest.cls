/**
 * @description       : 
 * @author            : chenpeng@deloitte.com.cn
 * @group             : 
 * @last modified on  : 04-02-2022
 * @last modified by  : chenpeng@deloitte.com.cn
**/
@isTest
public class NatificationInspectionSchedulableTest {
    public static String CRON_EXP = '0 0 1 * * ?';
    static testMethod void testNatificationPlanSchedulable(){ 
        Id profileId = [SELECT Id FROM profile WHERE Name = 'System Administrator' OR Name = '系统管理员'][0].Id;
        User user1 = new User(alias = '巡店员', email='test123@noemail.com',
        emailencodingkey='UTF-8', lastname='Testing123', languagelocalekey='en_US',
        localesidkey='en_US', profileid = profileId, country='United States',IsActive =true,
        timezonesidkey='America/Los_Angeles', username='test123@noemail.com');
        INSERT user1;
        
        Date today = System.today();
        Daily_Inspection_Report__c dir = new Daily_Inspection_Report__c();
        dir.OwnerId = user1.Id;
        dir.Report_Date__c = system.today();
        INSERT dir;
        Account acc1 = new Account(
            Name = 'Test sap1000000',
            SAP_Customer_Code__c = 'sap1000000',
            External_Key__c = 'sap1000000',
            Sales_Region__c = 'salesRegion',
            Approval_Status__c = 'Approved'
        );
        Database.insert(acc1);
        Customer_Visit__c cv = new Customer_Visit__c();
        cv.Name = 'test001';
        cv.Customer__c = acc1.id;
        cv.Visit_Category__c = '';
        cv.Visit_Date__c = Date.today();
        cv.Sales_Expected_Remind_Date__c = Date.today();
        cv.Place__c = '';
        cv.Visit_Purpose__c = '';
        cv.Status__c = '';
        cv.Achivement__c = '';
        cv.Visit_Matter__c = '';
        cv.Meeting_Minutes__c = '';
        Database.insert(cv);
        List<EmailTemplate> etList = EmailNotificationUtility.getEmailTemplate('CustomerVisitEmailTemplate');
        List<String> emailAddressList = new List<String>{'2872835113@qq.com'};
        List<Messaging.SingleEmailMessage> semList = new List<Messaging.SingleEmailMessage>();
        Messaging.SingleEmailMessage craMail = new Messaging.SingleEmailMessage();
        craMail.setWhatId(cv.Id);
        craMail.setToAddresses(emailAddressList);
        craMail.setSaveAsActivity(false);
        craMail.setUseSignature(false);
        craMail.setTreatTargetObjectAsRecipient(false); 
        semList.add(craMail);

        test.startTest();
        EmailNotificationUtility.sendEmailNotificationWithDummyContact(etList[0],semList);
        
        System.schedule('Test my class',CRON_EXP,new NatificationInspectionSchedulable());
        test.stopTest();

    }
    
}