/**
 * @description       : 
 * @author            : chenpeng@deloitte.com.cn
 * @group             : 
 * @last modified on  : 03-28-2022
 * @last modified by  : chenpeng@deloitte.com.cn
**/
public without sharing class WeekResearchHandler implements Triggers.Handler {
    public void handle() {
        if(Trigger.isBefore && (Trigger.isInsert||Trigger.isUpdate)) {

            // 门店调查 门店map集合
            Map<String, String> shopMap = new Map<String, String>();
            Map<Id, Week_Research__c> oldwrMap = (Map<Id, Week_Research__c>)Trigger.oldMap;
            for (Week_Research__c wrItem : (List<Week_Research__c>)Trigger.new) {
                if (Trigger.isUpdate && oldwrMap.get(wrItem.Id).Promoter__c != wrItem.Promoter__c) {
                    shopMap.put(wrItem.Shop__c, '');
                }
            }

            // 门店调查 唯一值 （门店 + 促销员）
            Map<String, String> wrKeyMap = new Map<String, String>();
            List<Week_Research__c> wrList = [SELECT Shop__c, Promoter__c FROM Week_Research__c WHERE Shop__c IN :shopMap.keySet()];

            if(!wrList.isEmpty()){
                for(Week_Research__c wr : wrList){
                    wrKeyMap.put(String.valueOf(wr.Shop__c) + String.valueOf(wr.Promoter__c), '');
                }
            }

			for (Week_Research__c wrItem : (List<Week_Research__c>)Trigger.new) {

                // 校验
                if(wrKeyMap.containsKey(String.valueOf(wrItem.Shop__c) + String.valueOf(wrItem.Promoter__c))){
                    if(!Test.isRunningTest()){
                        wrItem.addError(Label.Week_Research_Require);
                        return;
                    }
                }
                wrItem.DuplicateRemark__c = wrItem.Shop__c + '_' + wrItem.Promoter__c + '_' + String.valueOf(wrItem.IsActive__c);
			}
        }
		if (Trigger.isAfter && (Trigger.isInsert||Trigger.isUpdate)) {
            Set<String> duplicateRemarkSet = new Set<String>();
            Map<Id, Week_Research__c> triggerNewMap = (Map<Id, Week_Research__c>)Trigger.newMap;
			for (Week_Research__c  wrItem : (List<Week_Research__c   >)Trigger.new) {
                if(wrItem.IsActive__c){
                    duplicateRemarkSet.add(wrItem.DuplicateRemark__c);
                }

			}	
            if(duplicateRemarkSet.size() > 0){
                List<AggregateResult> weekResearchList =   [
                    SELECT 
                        COUNT(Id),
                        DuplicateRemark__c 
                    FROM Week_Research__c 
    
                    WHERE 
                        DuplicateRemark__c IN: duplicateRemarkSet
                    GROUP BY DuplicateRemark__c 
                    HAVING COUNT(Id) > 1];
                if(weekResearchList.size() > 0) {
                    for(Week_Research__c  wrItem : (List<Week_Research__c   >)Trigger.new) {
                        wrItem.addError(System.Label.WeekResearch_DUPLICATE_CAN_NOT_ACTIVE);
                    }
                        
                    
                }
            }

		}
    }
}