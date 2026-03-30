/**
 * @description       : 
 * @author            : ryshen@deloitte.com.cn
 * @group             : 
 * @last modified on  : 03-10-2022
 * @last modified by  : ryshen@deloitte.com.cn
**/
@isTest
public class CreateNewMonthPlanControllerTest {
    static testMethod void testCreateNewMonthPlanController(){
        String profileName = '巡店员'; 
        Id profileId = [SELECT Id FROM profile WHERE Name = :profileName][0].Id;
        User user1 = new User(alias = '巡店员', email='test123@noemail.com',
        emailencodingkey='UTF-8', lastname='Testing123', languagelocalekey='en_US',
        localesidkey='en_US', profileid = profileId, country='United States',IsActive =true,
        timezonesidkey='America/Los_Angeles', username='test123@noemail.com');
        INSERT user1;
        
        String taskMapDataJSON = '{"a1c0T000000Oe1ZQAS2022-2-14NEW": {"Id": "a1s0T000000Y3P7QAK","Shop__c":"a1c0T000000Oe1ZQAS","Inspection_Date__c": "2022-02-14","Result__c": "在交涉","Inspection_Target__c": "1","Remark__c": "1","Inspection_Plan__c": "a1d0T000000ex1MQAQ","Status__c": "已到访","Daily_Inspection_Report__c": "a1y0T000000IzOxQAK"}}';

        Inspection_Shop_Plan__c isp = new Inspection_Shop_Plan__c();
        isp.Inspection_Year__c = String.valueOf(System.today().year());
        isp.Inspection_Month__c = String.valueOf(System.today().month());
        isp.OwnerId = user1.Id;
        INSERT isp;


        Account acc = new Account();
        acc.Name = 'test';
        INSERT acc;
                
        Shop__c shop1 = new Shop__c();
        shop1.Account__c = acc.Id;
        shop1.Shop_Level__c = 'A';
        shop1.Name = 'Homeplus本石町店';
        INSERT shop1;

        Responsible_Person__c rp = new Responsible_Person__c();
        rp.Principal__c = user1.Id;
        rp.RecordType__c = '巡店员';
        rp.Shop_Name__c = shop1.Id;
        INSERT rp; 

        Inspection_Shop_Task__c ist = new Inspection_Shop_Task__c();
        ist.Shop__c = shop1.Id;
        ist.ExternalId__c = acc.Id;
        ist.OwnerId = user1.Id;
        ist.Status__c = '已到访';
        INSERT ist;

        Sampling_Inspection__c si = new Sampling_Inspection__c();
        si.IsNew__c = true;
        si.ExternalID__c = acc.Id;
        si.Inspection_Shop_Task__c = ist.Id;
        INSERT si;
        
        test.startTest();
        system.runAs(user1){
        CreateNewMonthPlanController.getData(isp.Id);
        CreateNewMonthPlanController.getData('');
        CreateNewMonthPlanController.haveRepeatingData('2022','1',System.UserInfo.getUserId());
        CreateNewMonthPlanController.getResponsPerson(user1.Id);
        CreateNewMonthPlanController.getReport(ist.Id);
        CreateNewMonthPlanController.saveData(isp,taskMapDataJSON,'',true,isp.Inspection_Year__c,isp.Inspection_Month__c,System.UserInfo.getUserId());
        CreateNewMonthPlanController.saveData(isp,taskMapDataJSON,isp.Id,true,isp.Inspection_Year__c,isp.Inspection_Month__c,System.UserInfo.getUserId());
        }
        test.stopTest();
    }

    static testMethod void testCreateNewMonthPlanController02(){
        String profileName = '巡店员'; 
        Id profileId = [SELECT Id FROM profile WHERE Name = :profileName][0].Id;
        User user1 = new User(alias = '巡店员', email='test123@noemail.com',
        emailencodingkey='UTF-8', lastname='Testing123', languagelocalekey='en_US',
        localesidkey='en_US', profileid = profileId, country='United States',IsActive =true,
        timezonesidkey='America/Los_Angeles', username='test123@noemail.com');
        INSERT user1;
        
        String taskMapDataJSON = '{"a1c0T000000Oe1ZQAS2022-2-14NEW": {"Id": "a1s0T000000Y3P7QAK","Shop__c":"a1c0T000000Oe1ZQAS","Inspection_Date__c": "2022-02-14","Result__c": "在交涉","Inspection_Target__c": "1","Remark__c": "1","Inspection_Plan__c": "a1d0T000000ex1MQAQ","Status__c": "已到访","Daily_Inspection_Report__c": "a1y0T000000IzOxQAK"}}';

        Inspection_Shop_Plan__c isp = new Inspection_Shop_Plan__c();
        isp.Inspection_Year__c = '2022';
        isp.Inspection_Month__c = '3';
        isp.OwnerId = user1.Id;
        //INSERT isp;


        Account acc = new Account();
        acc.Name = 'test';
        INSERT acc;
                
        Shop__c shop1 = new Shop__c();
        shop1.Account__c = acc.Id;
        shop1.Shop_Level__c = 'A';
        shop1.Name = 'Homeplus本石町店';
        INSERT shop1;

        Responsible_Person__c rp = new Responsible_Person__c();
        rp.Principal__c = user1.Id;
        rp.RecordType__c = '巡店员';
        rp.Shop_Name__c = shop1.Id;
        INSERT rp; 

        Inspection_Shop_Task__c ist = new Inspection_Shop_Task__c();
        ist.Shop__c = shop1.Id;
        ist.ExternalId__c = acc.Id;
        ist.OwnerId = user1.Id;
        ist.Status__c = '已到访';
        INSERT ist;

        Sampling_Inspection__c si = new Sampling_Inspection__c();
        si.IsNew__c = true;
        si.ExternalID__c = acc.Id;
        si.Inspection_Shop_Task__c = ist.Id;
        INSERT si;
        
        test.startTest();
        system.runAs(user1){
        CreateNewMonthPlanController.getData(isp.Id);
        CreateNewMonthPlanController.getData('');
        CreateNewMonthPlanController.haveRepeatingData('2022','1',System.UserInfo.getUserId());
        CreateNewMonthPlanController.getResponsPerson(user1.Id);
        CreateNewMonthPlanController.getReport(ist.Id);
        CreateNewMonthPlanController.saveData(isp,taskMapDataJSON,'',true,isp.Inspection_Year__c,isp.Inspection_Month__c,System.UserInfo.getUserId());
        CreateNewMonthPlanController.saveData(isp,taskMapDataJSON,isp.Id,true,isp.Inspection_Year__c,isp.Inspection_Month__c,System.UserInfo.getUserId());
        }
        test.stopTest();
    }
}