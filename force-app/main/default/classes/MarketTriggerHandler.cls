public class MarketTriggerHandler extends BaseTriggerHandler {
    
    public override void beforeInsert(){
        upsertExternalId((List<Market__c >)Trigger.new);
    }

    public override void beforeUpdate(){
        upsertExternalId((List<Market__c >)Trigger.new);
    }

    public static void upsertExternalId(List<Market__c> newList) {
        Set<Id> ownerIds = new Set<Id>();
        for (Market__c mk : newList) {
            if(!String.isBlank(mk.Weeks__c)) {
                // added by Sunny about weekly report
                mk.ExternalId__c = mk.Shop__c + '_' + mk.OwnerId + '_' + mk.Weeks__c;
            } else {
                mk.ExternalId__c = mk.Shop__c + '_' + mk.OwnerId + '_' + mk.Report_Date__c;
            }
            ownerIds.add(mk.ownerId);
        }

        Map<String, String> ownername = new Map<String, String>();
        for (User ow : [SELECT ID, Name FROM User WHERE Id IN :ownerIds]) {
            ownername.put(ow.Id, ow.Name);
        }

        for (Market__c mk : newList) {
            if (ownername.containsKey(mk.Id)) {
                mk.Owner_text__c = ownername.get(mk.Id);
            }
        }
    }
}