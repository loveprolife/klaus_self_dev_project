/**
 * @description       : 
 * @author            : chenpeng@deloitte.com.cn
 * @group             : 
 * @last modified on  : 03-29-2022
 * @last modified by  : chenpeng@deloitte.com.cn
**/
@isTest
public class PromoterDailyReportControllerTest {
    static testMethod void testPromoterDailyReportController(){
        String profileName = '促销员'; 
        Id profileId = [SELECT Id FROM profile WHERE Name = 'System Administrator' OR Name = '系统管理员'][0].Id;
        User user1 = new User(alias = '促销员', email='test123@noemail.com',
        emailencodingkey='UTF-8', lastname='Testing123', languagelocalekey='en_US',
        localesidkey='en_US', profileid = profileId, country='United States',IsActive =true,
        timezonesidkey='America/Los_Angeles', username='test123@noemail.com');
        INSERT user1;

        Account acc = new Account();
        acc.Name = 'test';
        INSERT acc;
            
        Shop__c shop = new Shop__c();
        shop.Account__c = acc.Id;
        shop.Shop_Level__c = 'A';
        shop.Name = 'Homeplus本石町店';
        shop.City__c = '北京市';
        shop.Shop_Center_Location__Latitude__s = 29.4545;
        shop.Shop_Center_Location__Longitude__s = 106.509;
        INSERT shop;

        Responsible_Person__c rp = new Responsible_Person__c();
        rp.Shop_Name__c = shop.Id;
        rp.Principal__c = user1.Id;
        rp.RecordType__c = '促销员';
        INSERT rp; 
        
        Week_Research__c wr = new Week_Research__c();
        wr.Promoter__c = user1.Id;
        wr.Shop__c = shop.Id;
        wr.IsActive__c = TRUE;
        INSERT wr;

        Week_Question_Item__c wqi = new Week_Question_Item__c();
        wqi.Shop_Research__c = wr.Id;
        wqi.Status__c ='有效';
        wqi.Question__c = 'test';
        INSERT wqi;

        test.startTest();
        system.runAs(user1){
        PromoterDailyReportController.initFunction();
        }
        PromoterDailyReportController.initFunction();
        test.stopTest();


    }
}