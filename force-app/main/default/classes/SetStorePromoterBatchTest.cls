/******************************************************************************
 ************************
 * Name: SetStorePromoterBatchTest
 * Description: SetEuChannelNameBatch测试类
 * Version History: 0.01
 * Date: 2024-11-27
 * Author: lizunxing
 * Comments: 
 *******************************************************************************
 **************************/
@isTest
private class SetStorePromoterBatchTest {
    static testMethod void testMethod1() {

        //account
        Account acc = new Account();
        acc.Name = 'test';
        Insert acc;

        //shop
        Shop__c shop1 = new Shop__c();
        shop1.Account__c = acc.id;
        shop1.Shop_Level__c = 'A';
        shop1.Name = '可乐店';
        shop1.City__c = '北京市';    
        shop1.Shop_Center_Location__Latitude__s = 29.4545;
        shop1.Shop_Center_Location__Longitude__s = 106.509;
        shop1.Sales_Region__c = 'Hisense Vietnam';
        Insert shop1;

        //Promoter_Attendance_Rule__c
        Promoter_Attendance_Rule__c par = new Promoter_Attendance_Rule__c();
        par.Start_time__c = Time.newInstance(9,0,0,0);
        par.End_time__c = Time.newInstance(18,0,0,0);
        par.Time_buffer__c = 15;
        insert par;

        //Responsible_Person__c
        Responsible_Person__c rp = new Responsible_Person__c();
        rp.Principal__c = UserInfo.getUserId();
        rp.Shop_Name__c = shop1.Id;
        rp.RecordType__c = '促销员';
        rp.Promoter_Attendance_Rule__c = par.Id;
        insert rp;

        SetStorePromoterBatch ss = new SetStorePromoterBatch();
		Database.executeBatch(ss);
    }
}