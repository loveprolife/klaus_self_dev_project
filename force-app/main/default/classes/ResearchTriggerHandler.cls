public class ResearchTriggerHandler extends BaseTriggerHandler {
    
    public override void beforeInsert(){
        upsertExternalId((List<Research__c >)Trigger.new);
    }

    public override void beforeUpdate(){
        upsertExternalId((List<Research__c >)Trigger.new);
    }

    public static void upsertExternalId(List<Research__c> newList) {
        Set<Id> ownerIds = new Set<Id>();
        for (Research__c rs : newList) {
            if(!String.isBlank(rs.Months__c)) {
                // added by Sunny about monthly report
                rs.ExternalId__c = rs.Shop__c + '_' + rs.OwnerId + '_' + rs.Months__c;
            } else {
                rs.ExternalId__c = rs.Shop__c + '_' + rs.OwnerId + '_' + rs.Report_Date__c;
            }
            ownerIds.add(rs.ownerId);
        }

        Map<String, String> ownername = new Map<String, String>();
        for (User ow : [SELECT ID, Name FROM User WHERE Id IN :ownerIds]) {
            ownername.put(ow.Id, ow.Name);
        }

        for (Research__c rs : newList) {
            if (ownername.containsKey(rs.Id)) {
                rs.Owner_text__c = ownername.get(rs.Id);
            }
        }
    }
}