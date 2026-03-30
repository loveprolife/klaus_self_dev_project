/**
 * @description       : 
 * @author            : chenpeng@deloitte.com.cn
 * @group             : 
 * @last modified on  : 03-05-2022
 * @last modified by  : chenpeng@deloitte.com.cn
**/
public withOut sharing class Share_Common_IntegrationFunction {
    public static Position__c getPositionObject(String recordId){
        return [SELECT  Name, 
                        Grouo_Name__c,
                        DeveloperName__c,
                        GroupId__c,
                        DoesIncludeBosses__c,
                        Is_Job__c,
                        (SELECT Account_External_Key__c, 
                                Account_Product_Line_Key__c, 
                                Gridding_External_Key__c, 
                                Shop_External_Key__c,
                                Owner_External_Key__c,// wfc
                                Gridding__c,
                                Shop__c,
                                Account__c,
                                Product_Line__c,
                                Position__c
                        FROM Position_Permissions__r)
                FROM Position__c
                WHERE Id = :recordId];
    }
}