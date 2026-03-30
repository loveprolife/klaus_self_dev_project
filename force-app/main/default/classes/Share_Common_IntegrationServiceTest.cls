/**
 * @description       : 
 * @author            : ryshen@deloitte.com.cn
 * @group             : 
 * @last modified on  : 03-15-2022
 * @last modified by  : ryshen@deloitte.com.cn
**/
@isTest
public class Share_Common_IntegrationServiceTest{
    @IsTest
    static void testShare_Common_IntegrationService(){
        
        Account acc = new Account();
        acc.Name = 'test';
        INSERT acc;

        Gridding__c gird1 = new Gridding__c();
        gird1.Name = 'test002';
        gird1.Gridding_Level__c = 'B';
        gird1.Gridding_Code__c  = 'J01-J001';
        INSERT gird1;
        
        Shop__c shop = new Shop__c();
        shop.Account__c = acc.Id;
        shop.Shop_Level__c = 'A';
        shop.Grid__c = gird1.id;
        shop.City__c = '北京市';
        INSERT shop;
        Share_Object__c shareObject = new Share_Object__c(Name = '巡店任务',
                                        Object_API__c = 'Inspection_Shop_Task__c',
                                        Object_Share__c = 'Inspection_Shop_Task__Share',
										Shop_Filed_API__c = shop.Id,
                                        Share_Type__c = 'ParentId',
                                        Share_Chunk__c = 'Inspection_Shop_Plan__Share,Inspection_Shop_Task__Share,Daily_Inspection_Report__Share' ,
                                        Gridding_Filed_API__c = 'test002',
                                        Account_API__c = 'C-62997', 
                                        Account_Product_Line__c = 'C-62997TV'              
                                        
        );
        INSERT shareObject;

        Share_Relation_Object__c sro = new Share_Relation_Object__c();
        sro.Name = '巡店员日报';
        sro.Relation_Object_API__c = 'Daily_Inspection_Report__c';
        sro.Object_Lookup_API__c = 'Daily_Inspection_Report__c';
        sro.Object_Share__c = 'Daily_Inspection_Report__Share';
        sro.Share_Type__c = 'ParentId';
        sro.Share_RowCause__c = 'Position_Share__c';
        sro.Share_Object__c = shareObject.Id;
        INSERT sro;
        
        Share_Object__c shareObject2 = new Share_Object__c(Name = '出样检查',
                                        Object_API__c = 'Sampling_Inspection__c',
                                        Object_Share__c = 'AccountShare',
                                        Gridding_Filed_API__c = 'Gridding_Filed_API__c',
                                        Shop_Filed_API__c = 'Shop_Filed_API__c',
                                        Share_Type__c = 'ParentId',
                                        Share_Chunk__c = 'Sampling_Inspection__Share' ,
                                        Account_API__c = 'Account_API__c', 
                                        Share_RowCause__c = 'Position_Share__c',
                                        Account_Product_Line__c = 'Account_Product_Line__c'
                                        
                                        
        );
        INSERT shareObject2;

        Daily_Inspection_Report__c dir = new Daily_Inspection_Report__c();
        dir.Report_Detail__c = 'test';
        dir.Report_Date__c = system.today();
        INSERT dir;

        Inspection_Shop_Task__c ist = new Inspection_Shop_Task__c();
        ist.Shop__c = shop.Id;
        //ist.ExternalId__c = pa.ExternalId__c;
        //ist.OwnerId = user1.Id;
        ist.Status__c = '计划外到访';
        ist.IsChange__c = true;
        ist.Daily_Inspection_Report__c = dir.Id;
        INSERT ist;
        
        Position__c pos = new Position__c();
        pos.DeveloperName__c = 'FU_GUAN_PATROLCLERKTEST';
        pos.Grouo_Name__c = '福关网格巡店员TEST';
        pos.Activity__c = true;
        pos.GroupId__c = '00G0T000002FoSYUA0';
        INSERT pos;

        Position_Permissions__c pp = new Position_Permissions__c();
        pp.Account__c = acc.Id;
        pp.Position__c = pos.Id;
        pp.Gridding__c = gird1.Id;
        pp.Shop__c = shop.Id;
        pp.Product_Line__c = 'TV';

        INSERT pp;

        List<Object> shareDataList = new List<Object>();
        shareDataList.add((Object)ist);
        //shareDataList.add(shareObject);
        String jsonData = JSON.serialize(shareDataList);
        system.debug(jsonData);


        Test.startTest();
        Share_Common_IntegrationService.shareData('Inspection_Shop_Task__c',jsonData,pos.Id, true);
        Share_Common_IntegrationService.shareData('Inspection_Shop_Task__c',jsonData,'', true);
        Share_Common_IntegrationService.shareData('Sampling_Inspection__c',jsonData,pos.Id, true);
        Test.stopTest();
    }
    @IsTest
    static void positionFiledChangeCommonTest(){
        Share_Object__c shareObject = new Share_Object__c(Name = '巡店任务',
                                Object_API__c = 'Inspection_Shop_Task__c',
                                Object_Share__c = 'Inspection_Shop_Task__Share',
                                Shop_Filed_API__c = 'Shop_Filed_API__c',
                                Share_Type__c = 'ParentId',
                                Share_Chunk__c = 'Inspection_Shop_Plan__Share,Inspection_Shop_Task__Share,Daily_Inspection_Report__Share' ,
                                Gridding_Filed_API__c = 'Gridding_Filed_API__c',
                                Account_API__c = 'Account_API__c',
                                Account_Product_Line__c = 'Account_Product_Line__c'       
                                
    );
        INSERT shareObject;
        // shareObject.Gridding_Filed_API__c = 'Gridding_Filed_API__c2';
        // UPDATE shareObject;
        Share_Relation_Object__c srObject = new Share_Relation_Object__c();
        srObject.Share_Object__c = shareObject.Id;
        srObject.Share_Type__c = 'ParentId';
        srObject.Object_Lookup_API__c = 'Daily_Inspection_Report__c';
        srObject.Object_Share__c = 'Inspection_Shop_Plan__Share';
        srObject.Share_RowCause__c = 'Position_Share__c';
        srObject.Relation_Object_API__c = 'Daily_Inspection_Report__c';
        INSERT srObject;
        
        Account acc = new Account();
        acc.Name = 'test';
        INSERT acc;

        Gridding__c gird1 = new Gridding__c();
        gird1.Name = 'test002';
        gird1.Gridding_Level__c = 'B';
        gird1.Gridding_Code__c  = 'J01-J001';
        INSERT gird1;
        
        Shop__c shop = new Shop__c();
        shop.Account__c = acc.Id;
        shop.Shop_Level__c = 'A';
        shop.Grid__c = gird1.id;
        shop.City__c = '北京市';
        INSERT shop;

       Inspection_Shop_Task__c ist = new Inspection_Shop_Task__c();
        ist.Shop__c = shop.Id;
        ist.Status__c = '计划外到访';
        ist.IsChange__c = true;
        INSERT ist; 

        List<SObject> shareList = new List<SObject>();
        shareList.add(shareObject);
        //shareList.add((SObject)ist);

        Map<Id,SObject> shareOldMap = new Map<Id,SObject>();
        shareOldMap.put(shareObject.Id,shareObject);
        Test.startTest();
        Share_Common_IntegrationService.positionFiledChangeCommon(shareList, shareOldMap, 'Inspection_Shop_Task__c');
        Test.stopTest();
        
    }

}