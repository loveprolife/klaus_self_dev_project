/**
 * @description       : 
 * @author            : chenpeng@deloitte.com.cn
 * @group             : 
 * @last modified on  : 03-15-2022
 * @last modified by  : chenpeng@deloitte.com.cn
**/
public withOut sharing class PositionMemberDeleteHandler implements Triggers.Handler {
    public void handle() {

        if(Trigger.isAfter && Trigger.isDelete) {
            Set<String> groupIdSet = new Set<String>();
            Set<String> userIdSet = new Set<String>();
            Map<String, Set<String>> posMemberSetMap = new Map<String, Set<String>>();
            for (Position_Member__c pm : (List<Position_Member__c>)Trigger.old) {
                groupIdSet.add(pm.GroupId__c);
                userIdSet.add(pm.User__c);
                posMemberSetMap.put(pm.Position__c, new Set<String>());
            }

            List<GroupMember> deleteGmList = [SELECT Id 
                                              FROM GroupMember 
                                              WHERE UserOrGroupId IN :userIdSet 
                                              AND GroupId IN :groupIdSet];
            if(!deleteGmList.isEmpty()) {
                deleteMember(JSON.serialize(deleteGmList));
            }

            //如果删除的岗位人员中存在客户纬度,删除客户小组的数据
            for (Position_Permissions__c per : PositionPermissionsAccShopShareService.getPostionPermissionAcc(posMemberSetMap.keySet())) {
                posMemberSetMap.get(per.Position__c).add(per.Account__c);
            }
            if (posMemberSetMap.isEmpty()) {

                return;
            }
            Set<String> accTeamKeySet = new Set<String>();
            for (Position_Member__c pm : (List<Position_Member__c>)Trigger.old) {
                if (!posMemberSetMap.containsKey(pm.Position__c)) {
                    continue;
                }
    
                for (String strAccId : posMemberSetMap.get(pm.Position__c)) {
                    accTeamKeySet.add(pm.Position__c + '-' + pm.User__c + '-' + strAccId);
                }
            }

            if (accTeamKeySet.isEmpty()) {

                return;
            }
    
            List<AccountTeamMember> deleteAtmList = [SELECT Id FROM AccountTeamMember WHERE External_Key_ID__c IN :accTeamKeySet];
            if (!deleteAtmList.isEmpty()) {
                DELETE deleteAtmList;
            }
        }
    }

    @future
    public static void deleteMember(String deleteGmListJson){
        List<GroupMember> deleteGmList = (List<GroupMember>)JSON.deserialize(deleteGmListJson, List<GroupMember>.class);
        DELETE deleteGmList;
    }
}