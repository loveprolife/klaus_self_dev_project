@isTest
public class NewCompetitorsInformationControllerTest {
    @isTest
    public static void testNewCompetitorsInformationController() { 

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

        Competitors_Information__c ci = new Competitors_Information__c();
        ci.Daily_Inspection_Report__c = dir.id;
        insert ci;

        Competitors_Information__c ci1 = new Competitors_Information__c();
        ci1.Daily_Inspection_Report__c = dir.id;
        insert ci1;

        List<Competitors_Information__c> l = new List<Competitors_Information__c>();
        l.add(ci);
        l.add(ci1);
        String recordListJson = JSON.serialize(l);

        Map<String,Competitors_Information__c> mapStr = new Map<String,Competitors_Information__c>();
        mapStr.put('tik',ci1);
        String fileMapJson = JSON.serialize(mapStr);

        String[] arry = new String[]{};
        

        Test.startTest();

        NewCompetitorsInformationController.getInitData(dir.id);
        NewCompetitorsInformationController.saveData(recordListJson,dir.id,fileMapJson,arry);

        arry.add(ci.Id);
        NewCompetitorsInformationController.saveData(recordListJson,dir.id,fileMapJson,arry);

        Test.stopTest();
    }
}