@isTest
public class NewCustomerForEDIControllerTest{
 
    static testMethod void testMethod1() {
        Interface_Url__c ifUrl1 = new Interface_Url__c();
        ifUrl1.Name = 'EDI';
        ifUrl1.Basic_Url__c = 'https://open-apisix.hisense.com/sinosure-edi/ediserver/do?user_key=cbnykosifwb7futcywo4ljsgejbunwf9';
        insert ifUrl1;
         test.startTest();
        NewCustomerForEDIController.runTest();
        test.stopTest();
    }

   

}