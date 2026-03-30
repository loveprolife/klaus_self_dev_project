@isTest
public class SamplingDetailImgBatchTest{
    private static Date dateSelect;
    private static Account acc;
    private static Shop__c shop;
    private static Account acc2;
    private static Shop__c shop2;
    static testMethod void test01(){
        String profileName = 'System Admin';
        Id profileId = [SELECT Id
                        FROM profile
                        WHERE Name = :profileName][0].Id;

        User userManager = new User(
            alias = 'Admn44', 
            email = 'test1234123123@noemail.com', 
            emailencodingkey = 'UTF-8', 
            lastname = 'Testing123', 
            languagelocalekey = 'en_US', 
            localesidkey = 'en_US', 
            profileid = profileId, 
            country = 'United States', 
            IsActive = true, 
            timezonesidkey = 'America/Los_Angeles', 
            username = 'SamplingDetailImgBatchTest@noemail.com'
        );
        INSERT userManager;

        User user1 = new User(
            alias = 'Admin34', 
            email = 'test123423@noemail.com', 
            emailencodingkey = 'UTF-8', 
            lastname = 'Testing122323', 
            languagelocalekey = 'en_US', 
            localesidkey = 'en_US', 
            profileid = profileId, 
            country = 'United States', 
            IsActive = true, 
            timezonesidkey = 'America/Los_Angeles', 
            username = 'SamplingDetailImgBatchTest11@noemail.com', 
            ManagerId = userManager.Id
        );
        INSERT user1;
        acc = new Account(
            Name = 'testname'
        );
        insert acc;
        shop = new Shop__c();
        shop.Account__c = acc.Id;
        shop.Shop_Level__c = 'A';
        shop.Name = 'Homeplus本石町店';
        shop.City__c = '北京市';
        shop.Sales_Region__c = 'Hisense Japan';
        shop.Shop_Center_Location__Latitude__s = 29.4545;
        shop.Shop_Center_Location__Longitude__s = 106.509;
        INSERT shop;

        acc2 = new Account(
            Name = 'testname2', 
            External_Key__c = '999999'
        );
        insert acc2;
        shop2 = new Shop__c();
        shop2.Account__c = acc2.Id;
        INSERT shop2;
        system.runAs(user1){
            dateSelect = system.today();
            Daily_Inspection_Report__c dir = new Daily_Inspection_Report__c();
            dir.Report_Detail__c = 'test';
            dir.Report_Date__c = dateSelect - 1;
            dir.OwnerId = user1.Id;
            dir.Status__c = 'Submitted';
            INSERT dir;


            InspectorDailyReportController.getNewCreateData(dateSelect);

            Id recordId = [SELECT Id
                           FROM RecordType
                           WHERE DeveloperName = 'InspectorAttendace'][0].Id;
            Id recordId2 = [SELECT Id
                            FROM RecordType
                            WHERE DeveloperName = 'CheckInSupplementary'][0].Id;
            Promoter_Attendance__c pa = new Promoter_Attendance__c();
            pa.ApprovalStatus__c = '未创建';
            pa.AddCheckInReason__c = 'test AddCheckInReason';
            pa.Shop__c = shop.Id;
            pa.Add_Check_Shop__c = shop.Id;
            pa.CheckInStatus__c = '已签退';
            pa.CheckOutShop__c = shop.Id;
            pa.CheckIn_Date__c = dateSelect;
            pa.ExternalId__c = user1.Id + '_' + String.valueOf(pa.CheckIn_Date__c);
            pa.OwnerId = user1.Id;
            pa.RecordTypeId = recordId;
            pa.Daily_Inspection_Report__c = dir.Id;
            pa.AddCheckSignInTime__c = null;
            pa.SignInTime__c = Time.newInstance(18, 30, 00, 00);
            INSERT pa;


            Inspection_Shop_Task__c ist = new Inspection_Shop_Task__c();
            ist.Shop__c = shop.Id;
            ist.ExternalId__c = pa.ExternalId__c;
            ist.OwnerId = user1.Id;
            ist.Status__c = '计划外到访';
            ist.Inspection_Date__c = dateSelect;
            ist.Daily_Inspection_Report__c = dir.Id;
            ist.Is_Create_Report__c = true;
            INSERT ist;

            Inspection_Shop_Task__c ist2 = new Inspection_Shop_Task__c();
            ist2.Shop__c = shop.Id;
            ist2.ExternalId__c = pa.ExternalId__c;
            ist2.OwnerId = user1.Id;
            ist2.Status__c = '未到访';
            ist2.Inspection_Date__c = dateSelect + 1;
            ist2.Daily_Inspection_Report__c = dir.Id;
            ist2.Is_Create_Report__c = true;
            INSERT ist2;

            Supplementary_Information__c supp = new Supplementary_Information__c();
            supp.Supplementary_SignIn_Time__c = Time.newInstance(18, 30, 00, 00);
            supp.Shop__c = shop.Id;
            supp.Status__c = '已提交补签申请';
            supp.Attendance__c = pa.Id;
            supp.RecordTypeId = recordId2;
            supp.Reson__c = 'test';
            INSERT supp;

            Responsible_Person__c rp = new Responsible_Person__c();
            rp.Principal__c = user1.Id;
            rp.RecordType__c = '巡店员';
            rp.Shop_Name__c = shop2.Id;
            INSERT rp;

            Sampling_Mapping__c sm = new Sampling_Mapping__c();
            sm.Account__c = acc.Id;
            sm.Level__c = 'A';
            sm.Shop_Level__c = 'A';
            INSERT sm;
            Sampling_Standard__c ss = new Sampling_Standard__c();
            ss.Sampling_Mapping__c = sm.Id;
            ss.Channel_Name__c = acc.Id;
            ss.Status__c = 'True';
            ss.Is_Add_ByReport__c = true;
            ss.Is_Added__c = '是';
            ss.Level__c = 'A';
            INSERT ss;

            Id recordId3 = [SELECT Id
                            FROM RecordType
                            WHERE DeveloperName = 'ALL_Product_Japan'][0].Id;

            Product__c pro = new Product__c();
            pro.Level__c = 'A';
            pro.OwnerId = user1.Id;
            pro.RecordTypeId = recordId3;
            INSERT pro;

            Sampling_Detail__c sd = new Sampling_Detail__c();
            sd.Sampling_Standard__c = ss.Id;
            sd.Shop__c = shop.Id;
            sd.Is_Add__c = '是';
            sd.ExternalID__c = shop2.Id + '-' + pro.Id;
            INSERT sd;

            Sampling_Inspection__c si2 = new Sampling_Inspection__c();
            // si.IsNew__c = true;
            si2.ExternalID__c = user1.Id + '_' + String.valueOf(pa.CheckIn_Date__c);
            si2.Inspection_Shop_Task__c = ist.Id;
            si2.Shop__c = shop.Id;
            si2.Product__c = pro.Id;
            si2.Placement_Status__c = '展出';
            si2.Sample_Item__c = sd.Id;
            INSERT si2;

            Sampling_Inspection__c si3 = new Sampling_Inspection__c();
            // si.IsNew__c = true;
            si3.ExternalID__c = user1.Id + '_' + String.valueOf(pa.CheckIn_Date__c.addDays(-1));
            si3.Inspection_Shop_Task__c = ist.Id;
            si3.Shop__c = shop.Id;
            si3.Product__c = pro.Id;
            si3.Placement_Status__c = '展出';
            si3.Sample_Item__c = sd.Id;
            INSERT si3;

            ContentVersion contentVersion = new ContentVersion(
                Title = 'Penguins', 
                PathOnClient = 'Penguins.jpg', 
                VersionData = Blob.valueOf('Test Content'), 
                IsMajorVersion = true
            );
            insert contentVersion;
            List<ContentDocument> documents = [SELECT Id, Title, LatestPublishedVersionId
                                               FROM ContentDocument];

            ContentDocumentLink cdl = New ContentDocumentLink();
            cdl.LinkedEntityId = si2.id;
            cdl.ContentDocumentId = documents[0].Id;
            cdl.shareType = 'V';
            insert cdl;

            Database.executeBatch(new SamplingDetailImgBatch());
        }
    }

}