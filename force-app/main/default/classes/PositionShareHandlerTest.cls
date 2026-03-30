/**
 * @description       : 
 * @author            : chenpeng@deloitte.com.cn
 * @group             : 
 * @last modified on  : 02-10-2022
 * @last modified by  : chenpeng@deloitte.com.cn
**/
@isTest
private class PositionShareHandlerTest {
    public static Share_Object__c shareObject;
	public static Sampling_Inspection__c si;
    public static Shop__c shop1;
    public static Shop__c shop2;
    public static User user1;
    private static void makeData(){
        Profile p = [SELECT Id,Name FROM Profile WHERE Name = 'System Administrator' OR Name = '系统管理员'][0];
        user1 = new User(
            Alias = 'admin', Email='systemadmin@hisensetest.com',
            EmailEncodingKey='UTF-8', LastName='sales representative', LanguageLocaleKey='en_US',
            LocaleSidKey='en_US', ProfileId = p.Id, TimeZoneSidKey='Asia/Kuala_Lumpur',
            UserName='systemadmin@hisensetest.com'
        );
        INSERT user1;

        shareObject = new Share_Object__c(Name = '出样检查',
                                        Object_API__c = 'Sampling_Inspection__c',
                                        Object_Share__c = 'Sampling_Inspection__Share',
                                        //Gridding_Filed_API__c = 'Gridding_Filed_API__c',
                                        Shop_Filed_API__c = 'Shop__c'
                                        
                                        
        );
        INSERT shareObject;
        
        Gridding__c gird = new Gridding__c();
        INSERT gird;
        Gridding__c gird2 = new Gridding__c();
        INSERT gird2;
        
        shop1 = new Shop__c();
        shop1.Name = 'test';
		shop1.Grid__c = gird.Id;        
        INSERT shop1;
        
        shop2 = new Shop__c();
        shop2.Name = '测试门店';
        shop2.Grid__c = gird2.Id;   
        INSERT shop2;
        
        si = new Sampling_Inspection__c();
        si.ExternalID__c = shop1.Id;
        si.Shop__c = shop1.Id;
        INSERT si;

    }
    
    static testMethod void testHandle1() {
        makeData();
        test.startTest();
        // System.runAs(user1){
            si.Shop__c = shop2.Id;
            UPDATE si;
        // }
        test.stopTest();
    }
}