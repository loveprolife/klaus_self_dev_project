@isTest
private class CustomerSalesForecastTriggerHandlerTest {
    static testMethod void testMethod1() {
        Test.startTest();

        Account acc = new Account(
          Name = 'Test Account001',
          SAP_Customer_Code__c = '1234567890',
          External_Key__c = '1234567890',
          Sales_Region__c = 'Hisense USA',
          Type = 'Management',
          Guarantor_Country_Code__c = 'US'
        );

        Database.insert(acc);

        String accId = acc.id;

        Order__c order = new Order__c();
        order.Customer__c = accId;
        order.Order_Date__c = Date.today();
        order.Order_Amount__c = 99.99;
        Database.insert(order);
   
        Customer_Sales_Forecast__c csf = new Customer_Sales_Forecast__c();
        csf.month__c = 'Sept';
        csf.Amount__c = 99.99;
        csf.Probability__c = 80;
        csf.Customer__c = accId;
        Database.insert(csf);

        csf.Amount__c = 88.99;
        Database.update(csf);

        Test.stopTest();

    }

    static testMethod void testMethod2() {
      Test.startTest();

      Account acc = new Account(
        Name = 'Test Account001',
        SAP_Customer_Code__c = '1234567890',
        External_Key__c = '1234567890',
        Sales_Region__c = 'Hisense USA',
        Type = 'Management',
        Guarantor_Country_Code__c = 'US'
      );

      Database.insert(acc);

      String accId = acc.id;

      Order__c order = new Order__c();
      order.Customer__c = accId;
      order.Order_Date__c = Date.today();
      order.Order_Amount__c = 99.99;
      Database.insert(order);
 
      Customer_Sales_Forecast__c csf = new Customer_Sales_Forecast__c();
      csf.month__c = 'Oct';
      csf.Amount__c = 99.99;
      csf.Probability__c = 80;
      csf.Customer__c = accId;
      Database.insert(csf);

      csf.Amount__c = 88.99;
      Database.update(csf);

      Test.stopTest();

  }

  static testMethod void testMethod3() {
    Test.startTest();

    Account acc = new Account(
      Name = 'Test Account001',
      SAP_Customer_Code__c = '1234567890',
      External_Key__c = '1234567890',
      Sales_Region__c = 'Hisense USA',
      Type = 'Management',
      Guarantor_Country_Code__c = 'US'
    );

    Database.insert(acc);

    String accId = acc.id;

    Order__c order = new Order__c();
    order.Customer__c = accId;
    order.Order_Date__c = Date.today();
    order.Order_Amount__c = 99.99;
    Database.insert(order);

    Customer_Sales_Forecast__c csf = new Customer_Sales_Forecast__c();
    csf.month__c = 'Nov';
    csf.Amount__c = 99.99;
    csf.Probability__c = 80;
    csf.Customer__c = accId;
    Database.insert(csf);

    csf.Amount__c = 88.99;
    Database.update(csf);

    Test.stopTest();

 }
}