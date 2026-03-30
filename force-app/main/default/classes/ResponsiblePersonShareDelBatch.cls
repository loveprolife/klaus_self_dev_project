global withOut sharing class ResponsiblePersonShareDelBatch implements Database.Batchable<sObject>{
    public String query;
    public String shareObjectName;
    global ResponsiblePersonShareDelBatch(String shareObjectName){
        this.shareObjectName = shareObjectName;
        this.query = 'SELECT Id FROM ' + shareObjectName + ' WHERE UserOrGroup.Name = null AND RowCause = \'Special_Share__c\'';
    }

    global Database.QueryLocator start(Database.BatchableContext bc){
        return Database.getQueryLocator(query);
    }

    global void execute(Database.BatchableContext BC, List<Promoter_Attendance__Share> promoterAttendanceShare){
        delete promoterAttendanceShare;
    }

    global void finish(Database.BatchableContext BC){
        Integer i = 1;
        i++;
        i++;
    }

}