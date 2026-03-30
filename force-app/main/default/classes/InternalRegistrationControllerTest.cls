@isTest
public with sharing class InternalRegistrationControllerTest {
    @isTest
    static void testInternalRegistrationController() {
        ExpoInfo__c exhibition = new ExpoInfo__c();
        exhibition.Name = '第xxx届展会';
        exhibition.TitleEN__c = 'Exhibition Informatino';
        exhibition.StartDate__c = Date.today().addDays(-10);
        exhibition.EndDate__c = Date.today().addDays(10);
        exhibition.LastRegistrationDate__c = Date.today().addDays(5);
        exhibition.DisplayInThePortal__c = true;
        insert exhibition;


        Test.startTest();

        Internal_Registration__c registration = new Internal_Registration__c();
        registration.Name_CN__c = '测试一';
        registration.Phone__c = '1213890';
        registration.Email__c = 'test1@email.com';
        registration.Exhibition_Id__c = exhibition.Id;
        registration.Position__c = 'test1 Position';
        registration.Deliverable__c = 'test1 Deliverable';
        insert registration;

        InternalRegistrationController.getInitData(registration.Id);

        List<Exhibition_Arrangement__c> arrangementList = [SELECT Id, Name, Exhibition_Management__r.Name, PresenceDate__c FROM Exhibition_Arrangement__c WHERE Internal_Registration__c = :registration.Id];
        if(arrangementList.size() > 0) {
            ExhibitionArrangementWithoutController.selExhibitionArrangementId(registration.Name_CN__c, 'test', arrangementList[0].Id);

            arrangementList[0].PresenceDate__c = System.now().format('MM-dd');
            ExhibitionArrangementWithoutController.saveExhibitionArrangement(Json.serialize(arrangementList[0]));

            ExhibitionArrangementWithoutController.sendEmail(arrangementList[0].Id);
        }
        

        Test.stopTest();
    }
}