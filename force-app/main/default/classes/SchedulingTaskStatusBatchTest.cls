@isTest
public with sharing class SchedulingTaskStatusBatchTest {
    
    @isTest
    static void test1() {
        SchedulingPlanControllerTest.method1();
        SchedulingPlanControllerTest.method2();
        User u = [SELECT Id,Name,Username,Sales_Region__c FROM User WHERE Id = :UserInfo.getUserId()];
        /*SchedulingPlan__c  sp = new SchedulingPlan__c(
            Responsible_person__c = [SELECT ID FROM Responsible_person__c limit 1].Id,
            Year__c = 2023,
            Month__c = 11
        );
        insert sp;*/
        SchedulingTask__c st = new SchedulingTask__c(
        	Scheduling_Date__c = Date.newInstance(2023,11,2),
            //SchedulingPlan__c = sp.Id,
            Responsible_person__c = [SELECT ID FROM Responsible_person__c limit 1].Id,
            User__c = UserInfo.getUserId()
        );
        insert st;
        LinkedListBatch.executeBatches(new LinkedListBatch[] {
            new SchedulingTaskStatusBatch(null, null),
                new SchedulingTaskStatusBatch(null)
        });
        new IDDailySchedulable().execute(null);
        new SADailySchedulable().execute(null);
        new CLDailySchedulable().execute(null);
    }
}