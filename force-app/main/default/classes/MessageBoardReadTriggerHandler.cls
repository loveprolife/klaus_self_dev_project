/**
 * @description       : 
 * @author            : chenpeng@deloitte.com.cn
 * @group             : 
 * @last modified on  : 03-17-2022
 * @last modified by  : chenpeng@deloitte.com.cn
**/
public without sharing class MessageBoardReadTriggerHandler implements Triggers.Handler {
    public void handle() {
        List<profile> profileIds =[SELECT Id 
                                   FROM profile 
                                   WHERE Name = '促销员' 
                                      OR Name = '巡店员'];
        List<User> users = [SELECT Id 
                            FROM User
                            WHERE profileid IN :profileIds 
                            AND Id != :UserInfo.getUserId() 
                            AND IsActive = true];

        List<Message_Read_State__c> insertMrsList = new List<Message_Read_State__c>();
        for (Shop_Message_Board__c mrs :(List<Shop_Message_Board__c>)Trigger.new) {
            for (User u : users) {
                Message_Read_State__c mrsItem = new Message_Read_State__c();
                mrsItem.Target_User__c = u.Id;
                mrsItem.Shop_Message_Board__c = mrs.Id;
                mrsItem.Status__c = '未读';
                mrsItem.ExternalId__c = mrsItem.Target_User__c + '_' + mrsItem.Shop_Message_Board__c;
                insertMrsList.add(mrsItem);
            }
        }

        if (!insertMrsList.isEmpty()) {
            INSERT insertMrsList;
        }
    }

}