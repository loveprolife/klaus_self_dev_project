@isTest
private class ExportControllerTest {
    static testMethod void getSAWeeklySalesTargetTemplateData() {

        Channel_item__c channelItem  = new Channel_item__c();
        channelItem.Channel_Name__c = 'Game';
        channelItem.SBU__c = 'Hisense South Africa';
        insert channelItem;

        Shop__c shop1 = new Shop__c();
        shop1.Channel_Item__c = channelItem.Id;
        shop1.Shop_Level__c = 'A';
        shop1.Name = '可乐店';
        shop1.City__c = '北京市';    
        shop1.Shop_Center_Location__Latitude__s = 29.4545;
        shop1.Shop_Center_Location__Longitude__s = 106.509;
        shop1.Sales_Region__c = 'Hisense South Africa';
        Insert shop1;

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

        Product__c pro = new Product__c();
        pro.Level__c = 'A';
        pro.Name = '100U7K';
        pro.Sales_Region__c = 'Hisense South Africa';
        INSERT pro;

        Test.startTest();
        ExportController.getSAWeeklySalesTargetTemplateData();
        Test.stopTest();

        
    }
    
    static testMethod void getSamplingTargetData() {
        
        Sampling_Target__c target = new Sampling_Target__c();
        target.Product_Line__c = 'TV';
        target.SBU__c = '日本';
        target.Region__c = '日本';
        target.Channel__c = 'YAMADA';
        target.Targeted_Sample_Numbers_Jan__c = 23;
        target.Actual_Sample_Qty__c = '23';
        Insert target;

        Test.startTest();
        ExportController.getSamplingTargetData();
        Test.stopTest();
    }
}