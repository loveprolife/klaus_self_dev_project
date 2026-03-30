@isTest
public with sharing class TrainingTriggerHandlerTest {

    @isTest
    static void Test1() {
        User u = new User();
        Profile p = [SELECT Id FROM profile WHERE name='System Administrator'];
        u.username = 'TrainingTriggerHandlerTest@salesforce.com';
        u.email = 'TrainingTriggerHandlerTest@salesforce.com';
        u.lastName = 'TrainingTriggerHandlerTest';
        String alias = 'aa';
        u.alias = alias;
        u.languagelocalekey = 'en_US';
        u.localesidkey = 'en_US';
        u.emailEncodingKey = 'UTF-8';
        u.timeZoneSidKey = 'America/Los_Angeles';
        u.profileId = p.Id;
        u.HisenseSSOName__c = 'testId';
        insert u;

        Training__c tr = new Training__c();
        tr.Year__c = '2024';    
        tr.Month__c = '10';    
        tr.Task_Number__c = 10;    
        tr.Email__c = 'TrainingTriggerHandlerTest@salesforce.com';
        insert tr;  
    }
}