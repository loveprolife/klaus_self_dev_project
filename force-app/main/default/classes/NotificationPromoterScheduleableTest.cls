@isTest
public class NotificationPromoterScheduleableTest {
    public static String CRON_EXP = '0 0 0 3 8 ?';
    static testMethod void testNotificationPromoterScheduleable(){
        Account acc = new Account();
        acc.Name = 'test';
        INSERT acc;
                
        Shop__c shop = new Shop__c();
        shop.Account__c = acc.Id;
        shop.Shop_Level__c = 'A';
        shop.Name = 'Homeplus本石町店';
        INSERT shop;
                
		Week_Research__c wr = new Week_Research__c();
        //wr.Promoter__c = user1.Id;
        wr.Shop__c = shop.Id;
        wr.IsActive__c = TRUE;
        INSERT wr;
        
        WeekResearchResponse__c wrr = new WeekResearchResponse__c();
        wrr.WeekResearch__c = wr.Id;
		//wrr.Shop__c = shop.Id;
        INSERT wrr;
            
        Week_Question_Item__c wqi = new Week_Question_Item__c();
        wqi.Shop_Research__c = wr.Id;
        wqi.Status__c ='有效';
        wqi.Question__c = 'test';
        INSERT wqi;
        
		WeekResearchResponseItem__c wrri = new WeekResearchResponseItem__c();
        wrri.Response__c = 'test';
        wrri.Week_Question_Item__c = wqi.Id;
        wrri.WeekResearchResponse__c = wrr.Id;
        INSERT wrri;
        test.startTest();       
        System.schedule('Test my class',CRON_EXP,new NotificationPromoterScheduleable());
        test.stopTest();

    }
    
}