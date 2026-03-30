@isTest
public with sharing class CreatePromoterDailyReportCmpControllTest {
    static testMethod void testMethod1(){
        Account acnt = new Account(Name='sdf');
        insert acnt;
        //CreatePromoterDailyReportCmpController.getUserCountry();
        CreatePromoterDailyReportCmpController.isPhaseIIIUser(acnt.Id);
    }
}