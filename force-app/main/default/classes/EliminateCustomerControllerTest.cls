@isTest
private class EliminateCustomerControllerTest {

    static testMethod void testMethod1() {

        String profileName = 'System Admin'; 
        Id profileId = [SELECT Id FROM profile WHERE Name = :profileName][0].Id;

        User user1 = new User(alias = 'Admn99', email='wfc99@noemail.com',
        emailencodingkey='UTF-8', lastname='wfc99', languagelocalekey='en_US',
        localesidkey='en_US', profileid = profileId, country='United States',IsActive =true,
        timezonesidkey='America/Los_Angeles', username='wfc99@noemail.com',country__c='USA');
        INSERT user1;

        Account acc1 = new Account(
                            Name = 'testname1');
        insert acc1;
        
        Account acc2 = new Account(
                            Name = 'testname2',
                            Approval_Status__c = 'Approved',
                            SAP_Customer_Code__c = '0000010001',
                            Eliminate_Approval_Status__c = 'Draft');
        insert acc2;  

        Account acc3 = new Account(
                            Name = 'testname3',
                            Approval_Status__c = 'Approved',
                            SAP_Customer_Code__c = '0000010002',
                            Eliminate_Approval_Status__c = 'Approved');
        insert acc3;  

        system.runAs(user1){
            EliminateCustomerController.saveData('测试', acc2.id, 'EliminateCustomer');
            EliminateCustomerController.saveData('测试', acc1.id, 'RestoreCustomer');
            EliminateCustomerController.saveData('测试', acc3.id, 'EliminateCustomer');
            EliminateCustomerController.saveData('测试', user1.id, 'EliminateCustomer');
        }
        

    }

}