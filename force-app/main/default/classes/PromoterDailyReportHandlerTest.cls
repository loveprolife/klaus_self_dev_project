@isTest
private class PromoterDailyReportHandlerTest{
  static testMethod void testHandler(){
    Account customer = new Account();
    customer.Name = 'Wal-mart';
    INSERT customer;

    Shop__c store = new Shop__c();
    store.Name = 'Hi Fi Corporation NEWCASTLE';
    store.Account__c = customer.Id;
    store.Sales_Region__c = 'Hisense Indonesia';
    INSERT store;

    Position__c pos = new Position__c();
    pos.DeveloperName__c = 'FU_GUAN_PATROLCLERKTEST';
    pos.Grouo_Name__c = 'FU_GUAN_PATROLCLERKTEST';
    pos.Activity__c = true;
    INSERT pos;
    Position_Permissions__c position = new Position_Permissions__c();
    position.Shop__c = store.Id;
    position.Position__c = pos.Id;
    INSERT position;

    Promoter_Daily_Report__c pdr = new Promoter_Daily_Report__c();
    pdr.Shop__c = store.Id;
    test.startTest();
    INSERT pdr;
    test.stopTest();
  }

}