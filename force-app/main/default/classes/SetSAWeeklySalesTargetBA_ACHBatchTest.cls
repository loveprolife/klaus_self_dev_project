@isTest
private class SetSAWeeklySalesTargetBA_ACHBatchTest {
    static testMethod void testMethod1() {

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

        Weekly_Sales_Target__c target = new Weekly_Sales_Target__c();
                target.Sales_Region__c = 'Hisense South Africa';
                target.Channel_Item__c = channelItem.id;
                target.From_Week__c = 3;
                target.To_Week__c = 6;
                target.Week__c = 3;
                target.Product_Line__c = 'TV';
                target.Model__c = pro.Id;
                target.Model_Name__c = pro.Name;
                target.RSP__c = 555;
                target.Plan_Target__c = 555;

                target.External_key__c = target.Sales_Region__c + '_' 
                                        + target.Week__c + '_'
                                        + target.Channel_Item__c + '_'
                                        + target.Product_Line__c + '_'
                                        + target.Model__c + '_'
                                        + System.now().year();
        Insert target;


        List<Weekly_Sales_Target__c> l = new List<Weekly_Sales_Target__c>();
        l.add(target);

        Test.startTest();
        SetSAWeeklySalesTargetBA_ACHBatch ss = new SetSAWeeklySalesTargetBA_ACHBatch(l);
        Database.executeBatch(ss, 99);
        SetSAWeeklySalesTargetBA_ACHBatch ss1 = new SetSAWeeklySalesTargetBA_ACHBatch(l,2022,2);
        Database.executeBatch(ss1, 99);
        SetSAWeeklySalesTargetBA_ACHBatch ss2 = new SetSAWeeklySalesTargetBA_ACHBatch(l, 'insert');
        Database.executeBatch(ss2, 99);
        Test.stopTest();

        
    }
}