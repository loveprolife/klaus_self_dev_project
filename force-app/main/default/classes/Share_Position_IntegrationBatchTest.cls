/**
 * @description       : 
 * @author            : ryshen@deloitte.com.cn
 * @group             : 
 * @last modified on  : 03-10-2022
 * @last modified by  : ryshen@deloitte.com.cn
**/
@isTest
public class Share_Position_IntegrationBatchTest {
    public static Map<String, String> soMap;
    public static Position__c pos;
    private static void makeData(){
        Gridding__c gird1 = new Gridding__c();
        gird1.Name = 'test002';
        gird1.Gridding_Level__c = 'B';
        gird1.Gridding_Code__c  = 'J01-J001';
        INSERT gird1;
        
        Account acc = new Account();
        acc.Name = 'test';
        INSERT acc;

        Shop__c shop = new Shop__c();
        shop.Account__c = acc.Id;
        shop.Shop_Level__c = 'A';
        shop.Grid__c = gird1.id;
        shop.City__c = '北京市';
        shop.External_Key_ID__c = gird1.Id;
        INSERT shop;

        Inspection_Shop_Task__c ist = new Inspection_Shop_Task__c();
        //ist.Share_Shop__c = shop.Id;
        ist.IsNew__c = true;
        ist.Shop__c = shop.Id;
        INSERT ist;

        Share_Object__c shareObject = new Share_Object__c(Name = '巡店任务',
                                        Object_API__c = 'Inspection_Shop_Task__c',
                                        Object_Share__c = 'Inspection_Shop_Task__Share',
                                        Shop_Filed_API__c = 'Share_Shop__c',
                                        Share_Type__c = 'ParentId',
                                        Refresh_Query_Statement__c = 'SELECT IsNew__c,IsChange__c,Share_Gridding_Code__c,Daily_Inspection_Report__c,Inspection_Plan__c FROM Inspection_Shop_Task__c'                             
		);    
		INSERT shareObject;  
        //SELECT IsNew__c,IsChange__c,Share_Shop__c FROM Inspection_Shop_Task__c WHERE  Share_Shop__c IN :shopSet

        
        pos = new Position__c();
        pos.DeveloperName__c = 'FU_GUAN_PATROLCLERKTEST';
        pos.Grouo_Name__c = '福关网格巡店员TEST';
        pos.Activity__c = true;
        pos.Is_Job__c = true;
        INSERT pos;
        
        Position_Permissions__c pp = new Position_Permissions__c();
        pp.Account__c = acc.Id;
        pp.Position__c = pos.Id;
        pp.Gridding__c = gird1.Id;
        pp.Shop__c = shop.Id;
        INSERT pp;
        
		soMap = new Map<String, String>();        
	    soMap.put(shareObject.Object_API__c, shareObject.Id);  
    }
    static testMethod void testShare_Position_Common_IntegrationBatch(){
        makeData();
        test.startTest();
        Share_Position_Common_IntegrationBatch batchable = new Share_Position_Common_IntegrationBatch(pos.Id,soMap);
        DataBase.executeBatch(batchable);
        test.stopTest();
        
    }
    
}