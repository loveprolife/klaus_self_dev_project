@isTest
private class ForecastSchedulableTest {
    static testMethod void testMethod1() {

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
   
        Customer_Sales_Forecast__c csf1 = new Customer_Sales_Forecast__c();
        csf1.month__c = 'Nov';
        csf1.Amount__c = 99.99;
        csf1.Probability__c = 80;
        csf1.Customer__c = accId;
        csf1.External_Key__c = accId + 2023 + 11;
        Database.insert(csf1);

        Customer_Sales_Forecast__c csf2 = new Customer_Sales_Forecast__c();
        csf2.month__c = 'Dec';
        csf2.Amount__c = 99.99;
        csf2.Probability__c = 80;
        csf2.Customer__c = accId;
        csf2.External_Key__c = accId + 2023 + 12;
        Database.insert(csf2);

        Customer_Sales_Forecast__c csf3 = new Customer_Sales_Forecast__c();
        csf3.month__c = 'Jan';
        csf3.Amount__c = 99.99;
        csf3.Probability__c = 80;
        csf3.Customer__c = accId;
        csf3.External_Key__c = accId + 2024 + 1;
        Database.insert(csf3);

        String CRON_EXP = '0 0 0 1 * ?';
        ForecastSchedulable bulkApi= new ForecastSchedulable();
        String jobId = System.schedule('ScheduledApexTest',CRON_EXP,bulkApi); 
    }
}