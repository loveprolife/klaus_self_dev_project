/**
 * @description       : 
 * @author            : chenpeng@deloitte.com.cn
 * @group             : 
 * @last modified on  : 03-15-2022
 * @last modified by  : chenpeng@deloitte.com.cn
**/
public withOut sharing class PositionMemberCreateHandler implements Triggers.Handler {
    public void handle() {
        if(Trigger.isBefore && Trigger.isInsert) {
            List<GroupMember> insertGmList = new List<GroupMember>();
            Set<String> posIdSet = new Set<String>();

            List<Position_Member__c> newPosMemList = (List<Position_Member__c>)Trigger.new;
            for (Position_Member__c pm : newPosMemList) {
                posIdSet.add(pm.Position__c);
            }
            Map<Id, Position__c> positionGroupMap = new Map<Id, Position__c>();
            positionGroupMap = queryPosition(posIdSet);

            System.debug(LoggingLevel.INFO, '*** positionGroupMap: ' + positionGroupMap);
            for (Position_Member__c pm : newPosMemList) {
                if(positionGroupMap.get(pm.Position__c) != null) {
                    String ExternalKeyID = positionGroupMap.get(pm.Position__c).GroupId__c + '-' + pm.User__c;
                    System.debug(LoggingLevel.INFO, '*** ExternalKeyID: ' + ExternalKeyID);
                    pm.External_Key_ID__c = ExternalKeyID;
                    
                }
            }
        }

        if(Trigger.isAfter && Trigger.isInsert) {
            List<Position_Member__c> newPosMemList = (List<Position_Member__c>)Trigger.new;
            List<GroupMember> insertGmList = new List<GroupMember>();

            Map<String, Set<String>> posMemberSetMap = new Map<String, Set<String>>();
            for (Position_Member__c pm : newPosMemList) {
                posMemberSetMap.put(pm.Position__c, new Set<String>());
                GroupMember gm = new GroupMember();
                gm.UserOrGroupId = pm.User__c;
                gm.GroupId = pm.GroupId__c;
                insertGmList.add(gm);
            }

            if (!insertGmList.isEmpty()) {
                createMember(JSON.serialize(insertGmList));
            }

            // 新增客户小组成员
            for (Position_Permissions__c per : PositionPermissionsAccShopShareService.getPostionPermissionAcc(posMemberSetMap.keySet())) {
                posMemberSetMap.get(per.Position__c).add(per.Account__c);
            }

            if (posMemberSetMap.isEmpty()) {

                return;
            }

            List<AccountTeamMember> upsertAtmList = new List<AccountTeamMember>();
            for (Position_Member__c pm : newPosMemList) {
                if (!posMemberSetMap.containsKey(pm.Position__c)) {
                    continue;
                }

                for (String strAccId : posMemberSetMap.get(pm.Position__c)) {
                    AccountTeamMember atm = new AccountTeamMember();
                    atm.AccountAccessLevel = 'Edit';
                    atm.AccountId = strAccId;
                    atm.CaseAccessLevel = 'Read';
                    atm.ContactAccessLevel = 'Read';
                    atm.OpportunityAccessLevel = 'Read';
                    atm.UserId = pm.User__c;
                    atm.TeamMemberRole = 'Sales Rep';
                    atm.Position__c = pm.Position__c;
                    atm.External_Key_ID__c = pm.Position__c + '-' + pm.User__c + '-' + strAccId;
                    upsertAtmList.add(atm);
                }
            }

            if (!upsertAtmList.isEmpty()) {
                Database.upsert(upsertAtmList, AccountTeamMember.External_Key_ID__c);
            }
        }
    }

    @future
    public static void createMember(String insertGmListJson){
        Map<String, String> groupIdMap = new Map<String, String>();
        Map<String, String> groupErrorMap = new Map<String, String>();

        //更新的岗位成员
        List<Position_Member__c> updatePossitionMemList = new List<Position_Member__c>();
        List<GroupMember> insertGmList = (List<GroupMember>)JSON.deserialize(insertGmListJson, List<GroupMember>.class);
        List<Database.SaveResult> groupMemberSrList = Database.insert(insertGmList,false);
        System.debug(LoggingLevel.INFO, '*** groupMemberSrList: ' + groupMemberSrList);
    }

    public static Map<Id, Position__c> queryPosition(Set<String> posIdSet){
        return new Map<Id, Position__c>([SELECT GroupId__c,
                                                DeveloperName__c
                                        FROM Position__c 
                                        WHERE Id IN :posIdSet]);
    }
}