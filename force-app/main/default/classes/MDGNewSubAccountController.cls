/**
 * 新建分户控制器
 * @author: Ardbert Wang
 * @date: 2024-11-14
 */
public without sharing class MDGNewSubAccountController {
    @AuraEnabled
    public static String getRecordTypeIdByDeveloperName(String developerName) {
        // 查询RecordTypeId
        RecordType rt = [SELECT Id FROM RecordType 
                         WHERE SObjectType = 'Account' 
                         AND DeveloperName = :developerName
                         LIMIT 1];
        return rt.Id;
    }
    
    /**
     * 获取默认值
     */
    @AuraEnabled
    public static Account getParentFields(String recordId) {
        // 查询RecordTypeId
        Account parentAccount = [SELECT Id, Guarantor_Country_Code__c, Hisense_Entity__c, Payment_Term__c, 
            Province_State__c, City__c, City_CN__c, District_CN__c, Township_CN__c, Address__c, Sales_Region__c,
            Shipping_Conditions__c,Reconciliation_Customer__c,Buyer_English_Name__c,Customer_Group2__c,
            VAT_Tax_type__c,Hisense_Entity_Sales__c, Payment_Term_Sales__c,
            Customer_Short_Name__c, Credit_Management__c FROM Account WHERE Id = :recordId LIMIT 1];
        return parentAccount;
    }
}