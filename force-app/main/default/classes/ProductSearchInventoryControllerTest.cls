@isTest
private class ProductSearchInventoryControllerTest {
    static testMethod void testMethod1() {
        TestDataUtility.createCustomSettings();
        Hisense_Entity_Relation__c heRelation = new Hisense_Entity_Relation__c();
        heRelation.Name = 'USA Relation';
        heRelation.Hisense_Entity_Code__c = '8110';
        heRelation.Hisense_Entity__c = '8110: Hisense US Sales Org';
        heRelation.Country__c = 'USA';
        insert heRelation;
        PickList__c newpicklist = new PickList__c();
        newpicklist.Name = 'G091 BB-LA-HA-FG';
        newpicklist.RecordTypeId = Utility.getRecordTypeMapBySobj('PickList__c').get('Master_Storage_Location');
        newpicklist.Label__c = 'BB-LA-HA-FG';
        newpicklist.Value__c = 'G091';
        newpicklist.belong_to_he__c = '8110';
        insert newpicklist;
        User currentUser = [SELECT Id,Name FROM User WHERE Id =:UserInfo.getUserId()];
        currentUser.Country__c = 'USA';
        update currentUser;
        ProductSearchInventoryController.initData();
        ProductSearchInventoryController.getProductInventory('HJ32N20012','8110','G091');
        ProductSearchInventoryController.getProductInventory('test00101','8110','');
    }
}