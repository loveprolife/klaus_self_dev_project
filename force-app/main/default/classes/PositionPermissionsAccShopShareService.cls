/**
 * @description       : 
 * @author            : chenpeng@deloitte.com.cn
 * @group             : 
 * @last modified on  : 03-15-2022
 * @last modified by  : chenpeng@deloitte.com.cn
**/
public withOut sharing class PositionPermissionsAccShopShareService {
    public static void shareAccountTeam(Map<String, Set<String>> accPositionMap){
        List<AccountTeamMember> upsertAtmList = new List<AccountTeamMember>();
        for (Position_Member__c pm : getPositionMember(accPositionMap.keySet())) {
            if (accPositionMap.containsKey(pm.Position__c)) {
                for (String strKey : accPositionMap.get(pm.Position__c)) {
                    AccountTeamMember atm = new AccountTeamMember();
                    atm.AccountAccessLevel = 'Edit';
                    atm.AccountId = strKey;
                    atm.CaseAccessLevel = 'Read';
                    atm.ContactAccessLevel = 'Read';
                    atm.OpportunityAccessLevel = 'Read';
                    atm.UserId = pm.User__c;
                    atm.TeamMemberRole = 'Sales Rep';
                    atm.Position__c = pm.Position__c;
                    atm.External_Key_ID__c = pm.Position__c + '-' + pm.User__c + '-' + strKey;
                    upsertAtmList.add(atm);
                }
            }
        }
        if (!upsertAtmList.isEmpty()) {
            UPSERT upsertAtmList;
        }
    }

    public static void deleteShareAccountTeam(Map<String, Set<String>> accPositionMap){
        List<AccountTeamMember> deleteAtmList = new List<AccountTeamMember>();

        //可删除的岗位=>客户
        Map<String, Set<String>> deletePositionAccMap = new Map<String, Set<String>>();

        Map<String, Set<String>> currentPermissionAccountMap = new Map<String, Set<String>>();
        for (Position_Permissions__c per : getPostionPermissionAcc(accPositionMap.keySet())) {
            if (currentPermissionAccountMap.containsKey(per.Position__c)) {
                currentPermissionAccountMap.get(per.Position__c).add(per.Account__c);
            }else {
                currentPermissionAccountMap.put(per.Position__c, new Set<String>{per.Account__c});
            }
        }

        for (String deletePosId : accPositionMap.keySet()) {
            if (accPositionMap.get(deletePosId).isEmpty()) {
                continue;
            }

            for (String deleteAccId : accPositionMap.get(deletePosId)) {
                if (currentPermissionAccountMap.containsKey(deletePosId) 
                    && !currentPermissionAccountMap.get(deletePosId).isEmpty() 
                    && currentPermissionAccountMap.get(deletePosId).contains(deleteAccId)) {
                    continue;
                }else {
                    if (deletePositionAccMap.containsKey(deletePosId)) {
                        deletePositionAccMap.get(deletePosId).add(deleteAccId);
                    }else {
                        deletePositionAccMap.put(deletePosId, new Set<String>{deleteAccId});
                    }
                }
            }
        }

        if (deletePositionAccMap.isEmpty()) {
            return;
        }

        Set<String> accTeamMemberKeySet = new Set<String>();
        for (Position_Member__c pm : getPositionMember(deletePositionAccMap.keySet())) {
            for (String positionId : deletePositionAccMap.keySet()) {
                if (deletePositionAccMap.get(positionId).isEmpty()) {
                    continue;
                }

                for (String accId : deletePositionAccMap.get(positionId)) {
                    accTeamMemberKeySet.add(positionId + '-' + pm.User__c + '-' + accId);
                }
            }
        }

        if (accTeamMemberKeySet.isEmpty()) {
            return;
        }

        deleteAtmList = [SELECT Id FROM AccountTeamMember WHERE External_Key_ID__c IN :accTeamMemberKeySet];
        if (!deleteAtmList.isEmpty()) {
            DELETE deleteAtmList;
        }
    }

    public static void shareShopTeam(Map<String, List<String>> shopPositionMap){
        
    }

    public static List<Position_Member__c> getPositionMember(Set<String> positionId){
        return [SELECT Position__c,
                       User__c
                FROM Position_Member__c
                WHERE Position__c IN :positionId];
    }

    public static List<Position_Permissions__c> getPostionPermissionAcc(Set<String> positionId){
        return [SELECT Position__c,
                       Account__c
                FROM Position_Permissions__c
                WHERE Position__c IN :positionId
                AND Account__c != ''];
    }
}