/**
 * @description       : 
 * @author            : chenpeng@deloitte.com.cn
 * @group             : 
 * @last modified on  : 03-15-2022
 * @last modified by  : chenpeng@deloitte.com.cn
**/
public withOut sharing class PositionPermissionsAccShopShareHandler implements Triggers.Handler {
    public void handle() {
        // if (System.isFuture() || System.isBatch()) {
        //     return;
        // }
        if (Trigger.isAfter && (Trigger.isInsert || Trigger.isUpdate)) {

            Map<String, Set<String>> accPositionMap = new Map<String, Set<String>>();

            Map<String, Set<String>> shopPositionMap = new Map<String, Set<String>>();
            for (Position_Permissions__c posPer : (List<Position_Permissions__c>)Trigger.new) {
                if (String.isNotBlank(posPer.Account__c)) {
                    if (accPositionMap.containsKey(posPer.Position__c)) {
                        accPositionMap.get(posPer.Position__c).add(posPer.Account__c);
                    }else {
                        accPositionMap.put(posPer.Position__c, new Set<String>{posPer.Account__c});
                    }
                }

                // if (String.isNotBlank(posPer.Shop__c)) {
                //     if (shopPositionMap.containsKey(posPer.Position__c)) {
                //         shopPositionMap.get(posPer.Position__c).add(posPer.Shop__c);
                //     }else {
                //         shopPositionMap.put(posPer.Position__c, new Set<String>{posPer.Shop__c});
                //     }
                // }
            }

            if (!accPositionMap.isEmpty()) {
                PositionPermissionsAccShopShareService.shareAccountTeam(accPositionMap);
            }
        }

        if (Trigger.isAfter && Trigger.isDelete) {
            Map<String, Set<String>> accdPositionMap = new Map<String, Set<String>>();
            for (Position_Permissions__c posPer : (List<Position_Permissions__c>)Trigger.old) {
                if (String.isNotBlank(posPer.Account__c)) {
                    if (accdPositionMap.containsKey(posPer.Position__c)) {
                        accdPositionMap.get(posPer.Position__c).add(posPer.Account__c);
                    }else {
                        accdPositionMap.put(posPer.Position__c, new Set<String>{posPer.Account__c});
                    }
                }
            }

            if (!accdPositionMap.isEmpty()) {
                PositionPermissionsAccShopShareService.deleteShareAccountTeam(accdPositionMap);
            }
        }
    }

    // private static void deleteGroup(String deleteGroupListJSON){
    //     DELETE (List<Group>)JSON.deserialize(deleteGroupListJSON, List<Group>.class);
    // }

    // public
}