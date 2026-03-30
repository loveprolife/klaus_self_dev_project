global without sharing class SchedulingTaskStatusBatch extends LinkedListBatch {
    
    String salesRegion;
    Date dt = null;
    global SchedulingTaskStatusBatch() {
        dt = System.today().addDays(-1);
    }
    
    global SchedulingTaskStatusBatch(String salesRegion) {
        this();
        this.salesRegion = salesRegion;
    }

    global SchedulingTaskStatusBatch(String salesRegion, Date dt) {
        this.salesRegion = salesRegion;
        if(dt != null) {
            this.dt = dt.addDays(-1);
        }
    }

    global Database.QueryLocator start(Database.BatchableContext bc) {
        System.debug('GeneratePersonalCommissionBatch ' + salesRegion + ' start');
        string query = 'SELECT Id,IsNormalF__c,IsDeleted,Name,CurrencyIsoCode,CreatedDate,CreatedById,LastModifiedDate,LastModifiedById,SystemModstamp,LastActivityDate,SchedulingPlan__c,Scheduling_Date__c,Promoter_Attendance_Rule__c,Responsible_person__c,Status__c,ExternalId__c,Application__c,Store__c,User__c,IsImport__c,Check_In_Attendance_Information__c,Check_Out_Attendance_Information__c,Check_In_Status__c,Check_In_Type__c,Check_In_Time__c,Check_In_Distance__c,Check_Out_Distance__c,Check_Out_Status__c,Check_Out_Time__c,Check_Out_Type__c';
        query += ' FROM SchedulingTask__c ';
        query += 'WHERE IsAbstained__c = false AND Application__c = NULL AND Check_In_Attendance_Information__c = NULL AND Check_Out_Attendance_Information__c = NULL';
        if(!String.isblank(salesRegion)) {
            query += ' AND Store__r.Sales_Region__c = :salesRegion ';
        }
        if (dt == null) {
            query += ' AND Scheduling_Date__c <= TODAY ';
        } else {
            query += ' AND Scheduling_Date__c = :dt ';
        }
        System.debug('query=' + query);
        return Database.getQueryLocator(query);
    }

    global void execute(Database.BatchableContext BC, List<SchedulingTask__c> sobjectList) {
        System.debug('SchedulingTaskStatusBatch ' + salesRegion + ' start');
        for (SchedulingTask__c task : sobjectList) {
            task.IsAbstained__c	= true;
        }

        update sobjectList;
    }
}