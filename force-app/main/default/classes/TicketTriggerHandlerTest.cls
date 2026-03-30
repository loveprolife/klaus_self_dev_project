@isTest
public class TicketTriggerHandlerTest {
	@isTest
    static void testMethod1(){
        Account customer = new Account();
        customer.Name = 'Wal-mart';
        insert customer;
         
        Shop__c store = new Shop__c();
        store.Name = 'Hi Fi Corporation NEWCASTLE';
        store.Account__c = customer.Id;
        store.Sales_Region__c = 'Hisense Indonesia';
        insert store;

        User promoter = new User();
        promoter.Username = 'testPromoterUser1213823@test004.com';
        promoter.lastname = 'testPromoterUser1213823';
        promoter.alias = 'Promoter';
        promoter.email ='Promoter@test.com';
        promoter.emailencodingkey = 'UTF-8';
        promoter.languagelocalekey = 'zh_CN';
        promoter.LocaleSidKey = 'zh_CN';
        promoter.IsActive = true;
        promoter.ProfileId = [SELECT Id FROM profile WHERE Name LIKE '%Indonesia Promoter%'][0].Id;
        promoter.timezonesidkey ='Asia/Shanghai';
        promoter.Sales_Region__c = 'Hisense Indonesia';
        insert promoter;

        User salesUser = new User();
        salesUser.Username = 'salesUser12138@test004.com';
        salesUser.lastname = 'salesUser12138';
        salesUser.alias = 'Sales';
        salesUser.email ='SalesUser@test.com';
        salesUser.emailencodingkey = 'UTF-8';
        salesUser.languagelocalekey = 'zh_CN';
        salesUser.LocaleSidKey = 'zh_CN';
        salesUser.IsActive = true;
        salesUser.ProfileId = [SELECT Id FROM profile WHERE Name LIKE '%Indonesia store manager%'][0].Id;
        salesUser.timezonesidkey ='Asia/Shanghai';
        salesUser.Sales_Region__c = 'Hisense Indonesia';
        // salesUser.Department__c = 'Marketing';
        insert salesUser;

        User marketingUser = new User();
        marketingUser.Username = 'marketingUser12138@test004.com';
        marketingUser.lastname = 'marketingUser12138';
        marketingUser.alias = 'market';
        marketingUser.email ='marketingUser@test.com';
        marketingUser.emailencodingkey = 'UTF-8';
        marketingUser.languagelocalekey = 'zh_CN';
        marketingUser.LocaleSidKey = 'zh_CN';
        marketingUser.IsActive = true;
        marketingUser.ProfileId = [SELECT Id FROM profile WHERE Name LIKE '%Indonesia store manager%'][0].Id;
        marketingUser.timezonesidkey ='Asia/Shanghai';
        marketingUser.Sales_Region__c = 'Hisense Indonesia';
        // marketingUser.Department__c = 'Marketing';
        insert marketingUser;
        
        Test.startTest();
        
        System.runAs(promoter) {
            Ticket__c ticket = new Ticket__c();
            ticket.Subject__c = 'TicketTriggerHandlerTest Ticket';
            ticket.Description__c = 'TicketTriggerHandlerTest Ticket';
            ticket.Department__c = 'Marketing';
            insert ticket;

            ticket.Department__c = 'Sales';
            update ticket;

            Ticket__c ticket2 = new Ticket__c();
            ticket2.Subject__c = 'TicketTriggerHandlerTest Ticket2';
            ticket2.Description__c = 'TicketTriggerHandlerTest Ticket2';
            ticket2.Department__c = 'Marketing';
            ticket2.AssignedTo__c = marketingUser.Id;
            insert ticket2;

            ticket2.AssignedTo__c = salesUser.Id;
            update ticket2;

            // 多人员
            Ticket__c ticket3 = new Ticket__c();
            ticket3.Subject__c = 'TicketTriggerHandlerTest Ticket2';
            ticket3.Description__c = 'TicketTriggerHandlerTest Ticket2';
            ticket3.Department__c = 'Marketing';
            ticket3.Aassigners__c = marketingUser.Id;
            insert ticket3;

            ticket3.Aassigners__c = salesUser.Id;
            update ticket3;

            ticket3.Department__c = 'Sales';
            update ticket3;

            // 多人员
            Ticket__c ticket4 = new Ticket__c();
            ticket4.Subject__c = 'TicketTriggerHandlerTest Ticket2';
            ticket4.Description__c = 'TicketTriggerHandlerTest Ticket2';
            ticket4.Department__c = 'Marketing';
            insert ticket4;
        }

        
        
        Test.stopTest();
    }
}