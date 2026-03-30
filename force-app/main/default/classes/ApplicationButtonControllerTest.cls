@isTest
public class ApplicationButtonControllerTest {

    public static User promoter;
    public static User promoter2;
    public static User manager;
    public static UserRole managerRole = [SELECT Id, Name, DeveloperName FROM UserRole WHERE DeveloperName = 'Indonesia_Training_Manager'];
    public static UserRole promoterRole = [SELECT Id, Name, DeveloperName FROM UserRole WHERE DeveloperName = 'Indonesia_Promoter_1'];
    @IsTest
    static void testApplicationButtonController(){

        Account customer = new Account();
        customer.Name = 'Wal-mart';
        insert customer;
        
        Shop__c store = new Shop__c();
        store.Name = 'Hi Fi Corporation NEWCASTLE';
        store.Account__c = customer.Id;
        store.Sales_Region__c = 'Hisense Indonesia';
        insert store;

        promoter = new User();
        promoter.Username = 'testPromoterUser121382@test004.com';
        promoter.lastname = 'testPromoterUser121382';
        promoter.alias = 'Promoter';
        promoter.email ='Promoter@test.com';
        promoter.emailencodingkey = 'UTF-8';
        promoter.languagelocalekey = 'zh_CN';
        promoter.LocaleSidKey = 'zh_CN';
        promoter.IsActive = true;
        promoter.ProfileId = [SELECT Id FROM profile WHERE Name LIKE '%Indonesia Promoter%'][0].Id;
        promoter.timezonesidkey ='Asia/Shanghai';
        promoter.Sales_Region__c = 'Hisense Indonesia';
        promoter.ManagerId = UserInfo.getUserId();
        insert promoter;

        promoter2 = new User();
        promoter2.Username = 'testPromoterUser12138222@test004.com';
        promoter2.lastname = 'testPromoterUser12138222';
        promoter2.alias = 'Promo2';
        promoter2.email ='Promoter2@test.com';
        promoter2.emailencodingkey = 'UTF-8';
        promoter2.languagelocalekey = 'zh_CN';
        promoter2.LocaleSidKey = 'zh_CN';
        promoter2.IsActive = true;
        promoter2.ProfileId = [SELECT Id FROM profile WHERE Name LIKE '%Indonesia Promoter%'][0].Id;
        promoter2.timezonesidkey ='Asia/Shanghai';
        promoter2.Sales_Region__c = 'Hisense Indonesia';
        promoter2.ManagerId = UserInfo.getUserId();
        insert promoter2;

        Application__c application = new Application__c();
        application.RecordTypeId = Schema.SobjectType.Application__c.getRecordTypeInfosByDeveloperName().get('TransferStore').getRecordTypeId();
        application.TransferStore__c = store.Id;
        application.LastDay__c = date.today();
        application.Successor__c = promoter2.Id;
        String applicationJson = Json.serialize(new List<Application__c>{application});

        Test.startTest();

        updateRoles();

        System.runAs(promoter) {
            
            Map<string, object> mso = (Map<string, object>)ApplicationButtonController.saveData(applicationJson, '').data;
            System.debug('mso：' + mso);
            String recordId = String.valueOf(mso.get('applicationId'));
            ApplicationButtonController.getInitData(recordId);
            ApplicationButtonController.submitGetInitData(recordId);
            ApplicationButtonController.submitSaveData(recordId);
        }
        
        Test.stopTest();
    }

    @future
    public static void updateRoles() {
        promoter.UserRoleId = promoterRole.Id;
        update promoter;
    }
}