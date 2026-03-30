@isTest
public class TicketResolvedButtonControllerTest {
	@isTest
    static void testMethod1(){
        Id profileId = UserUtility.GetSystemAdminProfileId();
        User user1 = new User(alias = 'promoter', email='TestTiket@noemail.com',
        emailencodingkey='UTF-8', lastname='TestTiket', languagelocalekey='en_US',
        localesidkey='en_US',profileid = profileId, country='United States',IsActive =true,
        timezonesidkey='America/Los_Angeles', username='TestTiket@noemail.com');
        INSERT user1;
        
        Account acc = new Account();
        acc.Name = 'test';
        INSERT acc;
        
        Shop__c shop1 = new Shop__c();
        shop1.Account__c = acc.Id;
        shop1.Shop_Level__c = 'A';
        shop1.Name = 'CX签到测试店';
        INSERT shop1;
               
        Promoter_Daily_Report__c testPDR = new Promoter_Daily_Report__c();
        testPDR.Shop__c = shop1.Id;
        insert testPDR;
        
        Ticket__c tik = new Ticket__c();
        tik.AssignedTo__c = UserInfo.getUserId();
        tik.PromoterDailyReport__c = testPDR.id;
        tik.Status__c = 'Closed';
        Insert tik;
        
        Ticket__c tik2 = new Ticket__c();
        tik2.PromoterDailyReport__c = testPDR.id;
        tik2.AssignedTo__c = user1.id;
        tik2.Status__c = 'Open';
        insert tik2;
        
        Ticket__c tik3 = new Ticket__c();
        tik3.PromoterDailyReport__c = testPDR.id;
        tik3.AssignedTo__c = user1.id;
        tik3.Status__c = 'Resolved';
        insert tik3;
        
        Test.startTest();
        TicketResolvedButtonController.saveRecord(tik2.id);
        TicketResolvedButtonController.saveRecord(tik3.id);
        TicketResolvedButtonController.getInitData(tik2.id);
        TicketResolvedButtonController.getInitData(tik.id);
        TicketResolvedButtonController.editGetInitData(tik2.id);

        System.runAs(user1) {
           tik2.Newest_Feedback__c = 'test';
            String recordJson = Json.serialize(tik2);
            TicketResolvedButtonController.editSaveRecord(recordJson); 
        }
        Test.stopTest();
    }
    
    @isTest
    static void testMethod2(){
        Id profileId = UserUtility.GetSystemAdminProfileId();
        User user1 = new User(alias = 'promoter', email='TestTiket@noemail.com',
        emailencodingkey='UTF-8', lastname='TestTiket', languagelocalekey='en_US',
        localesidkey='en_US',profileid = profileId, country='United States',IsActive =true,
        timezonesidkey='America/Los_Angeles', username='TestTiket@noemail.com');
        INSERT user1; 
        
        User user2 = new User(alias = 'promoter', email='TestTiket2@noemail.com',
        emailencodingkey='UTF-8', lastname='TestTiket2', languagelocalekey='en_US',
        localesidkey='en_US',profileid = profileId, country='United States',IsActive =true,
        timezonesidkey='America/Los_Angeles', username='TestTiket2@noemail.com');
        INSERT user2; 

        User salesUser = new User(alias = 'promoter', email='TestTiket2@noemail.com',
        emailencodingkey='UTF-8', lastname='TestTiket2', languagelocalekey='en_US',
        localesidkey='en_US',profileid = profileId, country='United States',IsActive =true,
        timezonesidkey='America/Los_Angeles', username='TestSalesUser@noemail.com', Department__c='Sales');
        INSERT salesUser; 

        User marketingUser = new User(alias = 'promoter', email='TestTiket2@noemail.com',
        emailencodingkey='UTF-8', lastname='TestTiket2', languagelocalekey='en_US',
        localesidkey='en_US',profileid = profileId, country='United States',IsActive =true,
        timezonesidkey='America/Los_Angeles', username='TestMarketingUser@noemail.com', Department__c='Marketing');
        INSERT marketingUser; 
        
        Account acc = new Account();
        acc.Name = 'test';
        INSERT acc;
        
        Shop__c shop1 = new Shop__c();
        shop1.Account__c = acc.Id;
        shop1.Shop_Level__c = 'A';
        shop1.Name = 'CX签到测试店';
        INSERT shop1;
               
        Promoter_Daily_Report__c testPDR = new Promoter_Daily_Report__c();
        testPDR.Shop__c = shop1.Id;
        insert testPDR;
        
        Ticket__c tik = new Ticket__c();
        tik.PromoterDailyReport__c = testPDR.id;
        tik.Status__c = 'Open';
        tik.AssignedTo__c = user1.id;
        
        Ticket__c tik2 = new Ticket__c();
        tik2.PromoterDailyReport__c = testPDR.id;
        tik2.AssignedTo__c = user2.id;
        tik2.Status__c = 'Open';
        insert tik2;

        Ticket__c departmentTicket = new Ticket__c();
        departmentTicket.Department__c = 'Sales';
        departmentTicket.Status__c = 'Open';
        insert departmentTicket;
        
        Test.startTest();
        insert tik;
        tik.Status__c = 'Resolved';
        tik.AssignedTo__c = user2.id;
        update tik;

        departmentTicket.Department__c = 'Marketing';
        update departmentTicket;

        TicketResolvedButtonController.getInitData(tik2.Id);
        TicketResolvedButtonController.saveRecord(tik2.Id);
        System.runAs(user2) {
            TicketResolvedButtonController.getInitData(tik2.Id); 
            TicketResolvedButtonController.editGetInitData(tik2.Id);

           
            tik2.Newest_Feedback__c = 'test';
            String recordJson = Json.serialize(tik2);
            TicketResolvedButtonController.editSaveRecord(recordJson); 

        }

        delete tik2;
        Test.stopTest();
    }
}