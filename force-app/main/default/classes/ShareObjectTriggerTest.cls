@isTest
private class ShareObjectTriggerTest {
    public static Share_Object__c shareObject;
    public static Inspection_Shop_Task__c ist;
	
   	static testMethod void testHandler(){
        shareObject = new Share_Object__c(
            							Name = '巡店任务',
                                        Object_API__c = 'Inspection_Shop_Task__c',
                                        Object_Share__c = 'Inspection_Shop_Task__Share',
                                        Gridding_Filed_API__c = 'Gridding_Filed_API__c',
                                        Account_API__c = 'Account_API__c',
                                        Account_Product_Line__c = 'Account_Product_Line__c',
                                        Shop_Filed_API__c = 'Shop_Filed_API__c'
        );
        INSERT shareObject;
        
        
        Share_Relation_Object__c sro = new Share_Relation_Object__c();
        sro.Share_Object__c = shareObject.Id;
        INSERT sro;
		
        
    }
}