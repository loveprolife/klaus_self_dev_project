@isTest
public with sharing class TriggerHandlerTest {

    @isTest
    static void Test1() {
        Account acnt = new Account();
        acnt.Name = '123';
        insert acnt;
        acnt.Name = '456';
        update acnt;
        delete acnt;
        undelete acnt;
    }
}