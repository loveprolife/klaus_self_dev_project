public without sharing class ExhibitionCustomerAssignmentBatch implements Database.Batchable<sObject>, Database.AllowsCallouts {
    
    public Database.QueryLocator start(Database.BatchableContext bc) {
        Set<String> customerFieldSet = new Set<String>();
        for(Schema.SObjectField field : Schema.SObjectType.ExpoApplyInfo__c.fields.getMap().values()){
            customerFieldSet.add(field.getDescribe().getName());
        }
        String query = 'SELECT ' + String.join(customerFieldSet, ',') + ' ,ExpoId__r.StartDate__c' + ' FROM ExpoApplyInfo__c WHERE ';
        // 当天是内部报名截至时间的后一天
        Date conditionDate = Date.today().addDays(-1);
        query += 'ExpoId__r.LastRegistrationDate__c = :conditionDate AND ExhibitionArrangement1__c = null ';
        System.debug('ExhibitionCustomerAssignmentBatch -> query: ' + query);

        return Database.getQueryLocator(query);
    }

    public void execute(Database.BatchableContext bc, List<ExpoApplyInfo__c> scope) {
        try {
            Map<Date, List<ExpoApplyInfo__c>> exhibitDateAndCustomersMap = new Map<Date, List<ExpoApplyInfo__c>>();
            for (ExpoApplyInfo__c customer : scope) {
                Date exhibitDate = customer.ExpoId__r.StartDate__c;
                if (exhibitDateAndCustomersMap.containsKey(exhibitDate)) {
                    exhibitDateAndCustomersMap.get(exhibitDate).add(customer);
                } else {
                    exhibitDateAndCustomersMap.put(exhibitDate, new List<ExpoApplyInfo__c> { customer });
                }
            }

            List<ExpoApplyInfo__c> updateCustomerList = new List<ExpoApplyInfo__c>();
            for (Date exhibitDate : exhibitDateAndCustomersMap.keySet()) {
                updateCustomerList.addAll(ExpoApplyInfoTriggerHanderHelper.matchingOnSiteReceptionists(null, exhibitDateAndCustomersMap.get(exhibitDate), exhibitDate));
            }
            if (updateCustomerList.size() > 0) {
                System.enqueueJob(new updateCustomer(updateCustomerList));
            }
            
        }
        catch (Exception e) {
            System.debug('ExhibitionCustomerAssignmentBatch Error : '+ e.getMessage() + e.getLineNumber());
        } 
    }

    public void finish(Database.BatchableContext bc){

    }

    public class updateCustomer implements Queueable, Database.AllowsCallouts {
        public List<ExpoApplyInfo__c> updateList { get; set; }
        public updateCustomer(List<ExpoApplyInfo__c> updateCustomerList) {
            updateList = updateCustomerList;
        }
        public void execute(QueueableContext context) {
            Database.update(updateList);
        }
    }

}