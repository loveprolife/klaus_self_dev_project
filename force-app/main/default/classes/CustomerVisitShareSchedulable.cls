/**
 * @description       : 日本商谈报告共享
 * @author            : wfc
**/
global withOut sharing class CustomerVisitShareSchedulable implements Schedulable {
    global void execute(SchedulableContext sc) {

        Share_Common_IntegrationBatch promoterAttendanceBatch = new Share_Common_IntegrationBatch(
            'Customer_Visit__c', 
            false, 
            '',
            0,
            'SELECT IsNew__c,IsChange__c,Customer_Code__c FROM Customer_Visit__c WHERE (Customer__r.Sales_Region__c  = \'Hisense Japan\' OR Customer__r.Hisense_Entity__c = \'8410\')'
        );
        Database.executeBatch(promoterAttendanceBatch, 30);
    }
}