/**
 * @description       : 
 * @author            : ryshen@deloitte.com.cn
 * @group             : 
 * @last modified on  : 04-02-2022
 * @last modified by  : ryshen@deloitte.com.cn
**/
@isTest
public class FlowTest {
    @IsTest
    static void test01(){
        Test.startTest();
        Share_Relation_Object__c sro = new Share_Relation_Object__c();
        sro.Name = '巡店员日报';
        sro.Relation_Object_API__c = 'Daily_Inspection_Report__c';
        sro.Object_Lookup_API__c = 'Daily_Inspection_Report__c';
        sro.Object_Share__c = 'Daily_Inspection_Report__Share';
        sro.Share_Type__c = 'ParentId';
        sro.Share_RowCause__c = 'Position_Share__c';
        INSERT sro;
        Test.stopTest();
        
    }
    @IsTest
    static void test02(){
        Test.startTest();
        Daily_Inspection_Report__c dir = new Daily_Inspection_Report__c();
        dir.Report_Detail__c = 'test';
        dir.Report_Date__c = System.today();
        INSERT dir;
        Mileage__c mileage = new Mileage__c();
        mileage.Start__c = 1;
        mileage.End__c = 222;
        mileage.Amount_To__c = 50;
        mileage.Gas_Mileage__c = 888;
        mileage.Report__c = dir.Id;
        INSERT mileage;
        Test.stopTest();
        
    }
    @IsTest
    static void test03(){
    Test.startTest();
    Position__c pos = new Position__c();
    pos.DeveloperName__c = 'FU_GUAN_PATROLCLERKTEST';
    pos.Grouo_Name__c = '福关网格巡店员TEST';
    pos.Activity__c = true;
    INSERT pos;
    Position_Permissions__c position = new Position_Permissions__c();
    position.Product_Line__c = 'Mobile';
    position.Position__c = pos.Id;
    INSERT position;
    Test.stopTest();
        
    }
    @IsTest
    static void test04(){
    Test.startTest();
    Shop_Message_Board__c smb = new Shop_Message_Board__c();
    smb.priority__c = 'A(☆☆☆)';
    smb.Message__c = 'test';
    INSERT smb;
    Test.stopTest();
        
    }
    @IsTest
    static void test05(){
    Test.startTest();
    Shop__c shop = new Shop__c();
    shop.Shop_Level__c = 'A';
    shop.Name = 'Homeplus本石町店';
    INSERT shop;
            
    Week_Research__c wr = new Week_Research__c();
    wr.Shop__c = shop.Id;
    wr.IsActive__c = TRUE;
    INSERT wr;
    Test.stopTest();
        
    }
    @IsTest
    static void test06(){
    Profile p = [SELECT Id,Name FROM Profile WHERE Name = 'System Administrator' OR Name = '系统管理员'];

    User user1 = new User(
            Alias = 'admin', Email='systemadmin@hisensetest.com',
            EmailEncodingKey='UTF-8', LastName='sales representative', LanguageLocaleKey='en_US',
            LocaleSidKey='en_US', ProfileId = p.Id, TimeZoneSidKey='Asia/Kuala_Lumpur',
            UserName='systemadmin@hisensetest.com'
        );
    INSERT user1;

    Shop__c shop = new Shop__c();
    shop.Shop_Level__c = 'A';
    shop.Name = 'Homeplus本石町店';
    INSERT shop;
    
    Test.startTest();
    Responsible_Person__c person = new Responsible_Person__c();
    person.Principal__c =user1.Id;
    person.Shop_Name__c = shop.Id;
    INSERT person;
    Test.stopTest();
        
    }
}