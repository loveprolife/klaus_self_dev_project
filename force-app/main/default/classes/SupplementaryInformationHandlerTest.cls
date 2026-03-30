@isTest
public class SupplementaryInformationHandlerTest {
    static testMethod void testSupplementaryInformationHandler1(){
        Id recordId = [SELECT Id FROM RecordType WHERE DeveloperName = 'CheckOutSupplementary'][0].Id;

        Shop__c shop = new Shop__c();
        shop.Shop_Level__c = 'A';
        shop.City__c = '北京市';
        INSERT shop;

        Promoter_Attendance__c pa = new Promoter_Attendance__c();
        pa.Shop__c = shop.Id;
        pa.CheckInStatus__c = '已签到';
        INSERT pa;

        Supplementary_Information__c supp = new Supplementary_Information__c();
        supp.Supplementary_SignIn_Time__c = Time.newInstance(18, 30, 00, 00);
        supp.Supplementary_SignOut_Time__c = Time.newInstance(20, 00, 00, 00);
        supp.Status__c='已提交补签申请';
        supp.Attendance__c = pa.Id;
        supp.Reson__c = 'test';
        supp.RecordTypeId = recordId;
        supp.Shop__c = shop.Id;
        INSERT supp;

        test.startTest();
        supp.Status__c='补签申请审批通过';
        UPDATE supp;
        test.stopTest();
    }
    static testMethod void testSupplementaryInformationHandler1_1(){
        Id recordId = [SELECT Id FROM RecordType WHERE DeveloperName = 'CheckOutSupplementary'][0].Id;

        Shop__c shop = new Shop__c();
        shop.Shop_Level__c = 'A';
        shop.City__c = '北京市';
        INSERT shop;

        Promoter_Attendance__c pa = new Promoter_Attendance__c();
        pa.Shop__c = shop.Id;
        INSERT pa;

        Supplementary_Information__c supp = new Supplementary_Information__c();
        supp.Supplementary_SignIn_Time__c = Time.newInstance(18, 30, 00, 00);
        supp.Supplementary_SignOut_Time__c = Time.newInstance(20, 00, 00, 00);
        supp.Status__c='已提交补签申请';
        supp.Attendance__c = pa.Id;
        supp.Reson__c = 'test';
        supp.RecordTypeId = recordId;
        supp.Shop__c = shop.Id;
        INSERT supp;

        test.startTest();
        supp.Status__c='补签申请审批通过';
        UPDATE supp;
        test.stopTest();
    }
    static testMethod void testSupplementaryInformationHandler2(){
        Id recordId = [SELECT Id FROM RecordType WHERE DeveloperName = 'CheckInSupplementary'][0].Id;

        Shop__c shop = new Shop__c();
        shop.Shop_Level__c = 'A';
        shop.City__c = '北京市';
        INSERT shop;

        Promoter_Attendance__c pa = new Promoter_Attendance__c();
        pa.Shop__c = shop.Id;
        pa.CheckInStatus__c = '已签退';
        INSERT pa;

        Supplementary_Information__c supp = new Supplementary_Information__c();
        supp.Supplementary_SignIn_Time__c = Time.newInstance(18, 30, 00, 00);
        supp.Supplementary_SignOut_Time__c = Time.newInstance(20, 00, 00, 00);
        supp.Status__c='已提交补签申请';
        supp.Attendance__c = pa.Id;
        supp.Reson__c = 'test';
        supp.RecordTypeId = recordId;
        supp.Shop__c = shop.Id;
        INSERT supp;

        test.startTest();
        supp.Status__c='补签申请审批通过';
        UPDATE supp;
        test.stopTest();
    }

    static testMethod void testSupplementaryInformationHandler2_1(){
        Id recordId = [SELECT Id FROM RecordType WHERE DeveloperName = 'CheckInSupplementary'][0].Id;

        Shop__c shop = new Shop__c();
        shop.Shop_Level__c = 'A';
        shop.City__c = '北京市';
        INSERT shop;

        Promoter_Attendance__c pa = new Promoter_Attendance__c();
        pa.Shop__c = shop.Id;
        INSERT pa;

        Supplementary_Information__c supp = new Supplementary_Information__c();
        supp.Supplementary_SignIn_Time__c = Time.newInstance(18, 30, 00, 00);
        supp.Supplementary_SignOut_Time__c = Time.newInstance(20, 00, 00, 00);
        supp.Status__c='已提交补签申请';
        supp.Attendance__c = pa.Id;
        supp.Reson__c = 'test';
        supp.RecordTypeId = recordId;
        supp.Shop__c = shop.Id;
        INSERT supp;

        test.startTest();
        supp.Status__c='补签申请审批通过';
        UPDATE supp;
        test.stopTest();
    }
}