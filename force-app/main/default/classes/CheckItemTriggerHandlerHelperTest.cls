/**
 * @description       : 
 * @author            : fausfeng@deloitte.com.cn
 * @group             : 
 * @last modified on  : 12-07-2023
 * @last modified by  : fausfeng@deloitte.com.cn
**/
@isTest
public class CheckItemTriggerHandlerHelperTest {
	@isTest
    static void testMethod1(){
        
        Test.startTest();
        CheckItem__c checkItem = new CheckItem__c();
		checkItem.Description__c = 'old';
		checkItem.Active__c = true;
        checkItem.Sales_Region__c = 'Hisense Chile';
        checkItem.Product_Line__c = 'TV';
        checkItem.Project__c = 'Booth and image';
        checkItem.RecordTypeId = Schema.SObjectType.CheckItem__c.getRecordTypeInfosByName().get('Chile').getRecordTypeId();
        insert checkItem;
        
        checkItem.Description__c = 'new';
        checkItem.Project__c = 'Material';
        update checkItem;
        
        CheckItem__c checkItem2 = new CheckItem__c();
		checkItem2.Description__c = 'old';
		checkItem2.Active__c = true;
        checkItem2.Sales_Region__c = 'Hisense Chile';
        checkItem2.Product_Line__c = 'TV';
        checkItem2.Project__c = 'Booth and image';
        checkItem2.MaximumScore__c = '1';
        checkItem2.IsYesOrNo__c = true;
        checkItem2.HasFile__c = true;
        checkItem2.RequireFileOptions__c = 'No;Yes';
        checkItem2.HasComment__c = true;
        checkItem2.RequireCommentOptions__c = 'Yes;No';
        checkItem2.RecordTypeId = Schema.SObjectType.CheckItem__c.getRecordTypeInfosByName().get('Chile').getRecordTypeId();
        insert checkItem2;
        
        
        Test.stopTest();
    }
}