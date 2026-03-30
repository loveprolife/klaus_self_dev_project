@isTest
public class UrgingButtonControllerTest {
    @isTest
    public static void testMethod1(){

        String profileName = '巡店员'; 
        Id profileId = [SELECT Id FROM profile WHERE Name = :profileName][0].Id; 
        User user1 = new User(alias = '区域经理', email='DailySalesUploadControllerTest@noemail.com',
        emailencodingkey='UTF-8', lastname='DailySalesUploadControllerTest', languagelocalekey='en_US',
        localesidkey='en_US',profileid = profileId,country='United States',IsActive =true,
        timezonesidkey='America/Los_Angeles', username='DailySalesUploadControllerTest@noemail.com',Sales_Region__c='Hisense South Africa');
        INSERT user1;

        //account
        Account acc = new Account();
        acc.Name = 'test';
        acc.SAP_Customer_Code__c = '0101010101';
        acc.Sales_Region__c = 'Hisense South Africa';
        Insert acc;

        // Id ProcessDefinitionId = '04a0o000000LcZjAAK';

        // ProcessInstance pi = new ProcessInstance();
        // pi.TargetObjectId = acc.Id;
        // pi.status = 'Pending';
        // pi.CurrentNodeId = '';
        // pi.ProcessDefinitionId = ProcessDefinitionId;
        // insert pi;

        // ProcessInstanceWorkitem pw = new ProcessInstanceWorkitem();
        // pw.ProcessInstanceId = ProcessDefinitionId;
        // insert pw;

        UrgingButtonController.urgingSendEmail(acc.Id);
    }
}