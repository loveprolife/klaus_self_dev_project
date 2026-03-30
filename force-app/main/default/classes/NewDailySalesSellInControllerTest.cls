@isTest
public class NewDailySalesSellInControllerTest {
    @isTest
    public static void testNewDailySalesSellInController() { 

        User user = new User();
        user.Username = 'testPromoterUser1213823@test004.com';
        user.lastname = 'promoter';
        user.alias = 'Promoter';
        user.email ='Promoter@test.com';
        user.emailencodingkey = 'UTF-8';
        user.languagelocalekey = 'zh_CN';
        user.LocaleSidKey = 'zh_CN';
        user.IsActive = true;
        user.ProfileId = [SELECT Id FROM profile WHERE Name LIKE '%Chile Promoter%'][0].Id;
        user.timezonesidkey ='Asia/Shanghai';
        user.Sales_Region__c = 'Hisense Chile';
        insert user;

        Daily_Inspection_Report__c dir = new Daily_Inspection_Report__c();
        dir.Report_Detail__c = 'test';
        dir.Report_Date__c = system.today() - 1;
        dir.OwnerId = user.Id;
        INSERT dir;

        Product__c p = new Product__c();
        p.Name = '111';
        insert p;

        Daily_Sales_Sell_In__c ci = new Daily_Sales_Sell_In__c();
        ci.Daily_Inspection_Report__c = dir.id;
        insert ci;

        Daily_Sales_Sell_In__c ci1 = new Daily_Sales_Sell_In__c();
        ci1.Daily_Inspection_Report__c = dir.id;
        insert ci1;

        List<Daily_Sales_Sell_In__c> l = new List<Daily_Sales_Sell_In__c>();
        l.add(ci);
        l.add(ci1);
        String recordListJson = JSON.serialize(l);

        Map<String,Daily_Sales_Sell_In__c> mapStr = new Map<String,Daily_Sales_Sell_In__c>();
        mapStr.put('tik',ci1);
        String fileMapJson = JSON.serialize(mapStr);

        String[] arry = new String[]{};
        

        Test.startTest();

        NewDailySalesSellInController.getInitData(dir.id);
        NewDailySalesSellInController.saveData(recordListJson,dir.id,fileMapJson,arry);

        arry.add(ci.Id);
        NewDailySalesSellInController.saveData(recordListJson,dir.id,fileMapJson,arry);

        Test.stopTest();
    }
}