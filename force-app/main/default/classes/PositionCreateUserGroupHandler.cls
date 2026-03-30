/**
 * @description       : 
 * @author            : chenpeng@deloitte.com.cn
 * @group             : 
 * @last modified on  : 02-08-2022
 * @last modified by  : chenpeng@deloitte.com.cn
**/
public withOut sharing class PositionCreateUserGroupHandler implements Triggers.Handler {
    public void handle() {
        if (Trigger.isBefore && Trigger.isInsert) {
            List<Position__c> posList = (List<Position__c>)Trigger.new;
            Map<String, String> groupIdMap = new Map<String, String>();
            Map<String, String> groupErrorMap = new Map<String, String>();
            List<Group> insertGroupList = new List<Group>();
            for(Position__c pos : (List<Position__c>)Trigger.new){
                Group gro = new Group();
                gro.Name = pos.Grouo_Name__c;
                gro.DeveloperName = pos.DeveloperName__c;
                gro.DoesIncludeBosses = pos.DoesIncludeBosses__c;
                insertGroupList.add(gro);
            }

            List<Database.SaveResult> groupSrList = Database.insert(insertGroupList,false);
            for (Integer i = 0; i < groupSrList.size(); i++ ) {
                Database.SaveResult sr = groupSrList.get(i);
                if (sr.isSuccess()) {
                    groupIdMap.put(insertGroupList[i].DeveloperName, sr.getId());
                } else {
                    for (Database.Error err : sr.getErrors()) {
                        groupErrorMap.put(insertGroupList[i].DeveloperName,err.getMessage());
                    }
                }
            }

            for(Position__c pos : (List<Position__c>)Trigger.new){
                if(groupIdMap.containsKey(pos.DeveloperName__c) && String.isNotBlank(groupIdMap.get(pos.DeveloperName__c))) {
                    pos.GroupId__c = groupIdMap.get(pos.DeveloperName__c);
                }else {
                    pos.addError(groupErrorMap.get(pos.DeveloperName__c));
                }
            }
        }

        if(Trigger.isAfter && Trigger.isDelete) {
            List<Group> deleteGroupList = new List<Group>();
            for (Position__c pos : (List<Position__c>)Trigger.old) {
                Group gro = new Group();
                gro.Id = pos.GroupId__c;
                deleteGroupList.add(gro);
            }

            if(!deleteGroupList.isEmpty()) {
                deleteGroup(JSON.serialize(deleteGroupList));
            }
        }

        if(Trigger.isBefore && Trigger.isUpdate) {
            if(!system.isBatch()){
                List<Group> updateGroupList = new List<Group>();
                for (Position__c pos : (List<Position__c>)Trigger.new) {
                    Group gro = new Group();
                    gro.Id = pos.GroupId__c;
                    gro.DoesIncludeBosses = pos.DoesIncludeBosses__c;
                    updateGroupList.add(gro);
                }

                if(!updateGroupList.isEmpty()) {
                    updateGroup(JSON.serialize(updateGroupList));
                }
            }
        }
    }

    @future
    private static void deleteGroup(String deleteGroupListJSON){
        DELETE (List<Group>)JSON.deserialize(deleteGroupListJSON, List<Group>.class);
    }

    @future
    private static void updateGroup(String updateGroupListJSON){
        UPDATE (List<Group>)JSON.deserialize(updateGroupListJSON, List<Group>.class);
    }
}