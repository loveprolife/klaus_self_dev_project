public without sharing class MessageBoardReadController {
    @AuraEnabled
    public static void updateMessageBoardReadStatus(String recordId) {
        Message_Read_State__c mrsItem = new Message_Read_State__c();
        mrsItem.Target_User__c = UserInfo.getUserId();
        mrsItem.Shop_Message_Board__c = recordId;
        mrsItem.ExternalId__c = mrsItem.Target_User__c + '_' + mrsItem.Shop_Message_Board__c;
        mrsItem.Status__c = '已读';
        upsert mrsItem ExternalId__c;
    }   
}