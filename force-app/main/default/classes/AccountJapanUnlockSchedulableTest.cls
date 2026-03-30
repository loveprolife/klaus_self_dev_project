/*
 * @Author: WFC
 * @Date: 2022-08-31 11:02:16
 * @LastEditors: WFC
 * @LastEditTime: 2022-08-31 11:07:57
 * @Description: 
 * @FilePath: \Hitest\force-app\main\default\classes\AccountJapanUnlockSchedulableTest.cls
 */
@isTest
private class AccountJapanUnlockSchedulableTest {
    
    static testmethod void test() {
        Account acc1 = new Account(
            Name = 'Test sap1000000',
            SAP_Customer_Code__c = 'sap1000000',
            External_Key__c = 'sap1000000',
            Sales_Region__c = 'salesRegion',
            Approval_Status__c = 'Approved',
            isGoFinApprove__c = 'fin_approved',
            Basic_Approval_Status__c = 'draft'
        );
        Database.insert(acc1);

        AccountJapanUnlockSchedulable cis = new AccountJapanUnlockSchedulable(new List<id>{acc1.id}, '测试---1--1--1', true);
        SchedulableContext sc;
        cis.execute(sc);

        AccountJapanUnlockSchedulable cis1 = new AccountJapanUnlockSchedulable(new List<id>{acc1.id}, '测试---1--1--1', false);
        SchedulableContext sc1;
        cis1.execute(sc1);
    }
 
}