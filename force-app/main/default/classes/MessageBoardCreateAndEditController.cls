/*
 * @Author: Rain
 * @Date: 2022-04-20 22:12:28
 * @LastEditors: Rain
 * @LastEditTime: 2022-04-21 18:07:36
 * @Description: MessageBoardCreateAndEditLWC controller
 */
public without sharing class MessageBoardCreateAndEditController {
    @AuraEnabled 
    public static ReturnData initData(String recordId) {
        ReturnData returnData = new ReturnData();
        if(String.isNotBlank(recordId)) {
            Shop_Message_Board__c message = getMessageBoard(recordId);
            returnData.isSuccess = true;
            if(message != null) {
                returnData.name = message.Name;
                returnData.message = message.Message__c;
                returnData.priority = message.priority__c;
                returnData.isActive = message.IsActive__c;
                returnData.accountText = message.Account_Text__c;
                returnData.department = message.Department__c;
            }
        }
        return returnData;
    }

    @AuraEnabled
    public static ResultData saveRecord(String recordStr,String recordId){
        ReturnData returnData = (ReturnData)JSON.deserialize(recordStr, ReturnData.class);
        ResultData resultData = new ResultData();
        Shop_Message_Board__c message = new Shop_Message_Board__c();
        message.Name = returnData.name;
        message.Message__c = returnData.message;
        message.priority__c = returnData.priority;
        message.IsActive__c = returnData.isActive;
        message.Account_Text__c = returnData.accountText;
        message.Department__c = returnData.department;

        try {
            Database.SaveResult result = null;
            if(String.isNotBlank(recordId)) {
                message.Id = recordId;
                result = Database.update(message);
            } else {
                result = Database.insert(message);
            }

            if(result.isSuccess()) {
                resultData.isSuccess = true;
                resultData.recordId = result.getId();
            } else {
                String error = '';
                for (Database.Error err : result.getErrors()) {
                    error += err.getMessage();
                }
                resultData.isSuccess = false;
                resultData.errorMsg = error;
            }
            
        } catch (Exception e) {
            resultData.isSuccess = false;
            resultData.errorMsg = e.getMessage();
        }
        return resultData;
    }

    /**
    Name : getMessageBoard
    Purpose : 获取留言板记录内容
    Params : recordId 留言板Id
    Return : 留言板记录
    Author : Rain
    Date : 2022-04-21
    **/ 
    public static Shop_Message_Board__c getMessageBoard(String recordId) {
        return [SELECT 
                    Id,
                    Name,
                    Message__c,
                    IsActive__c,
                    priority__c,
                    Department__c,
                    Account_Text__c
                FROM
                    Shop_Message_Board__c 
                WHERE 
                    Id = :recordId];
    }


    public class ReturnData {
        @AuraEnabled
        public Boolean isSuccess;
        @AuraEnabled
        public String errorMsg;
        @AuraEnabled
        public String name;
        @AuraEnabled
        public String message;
        @AuraEnabled
        public String isActive;
        @AuraEnabled
        public String priority;
        @AuraEnabled
        public String department;
        @AuraEnabled
        public String accountText;
    }

    public class ResultData {
        @AuraEnabled
        public Boolean isSuccess;
        @AuraEnabled
        public String errorMsg;
        @AuraEnabled
        public String recordId;
    }
}