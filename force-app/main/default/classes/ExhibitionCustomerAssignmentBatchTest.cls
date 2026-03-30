@isTest
public class ExhibitionCustomerAssignmentBatchTest {
    
    @TestSetup
    static void makeData() {
        ExpoInfo__c testExhibition = new ExpoInfo__c(
            Name = '测试展会',
            TitleEN__c = 'Test Exhibition',
            StartDate__c = Date.today().addDays(3),
            EndDate__c = Date.today().addDays(10),
            LastRegistrationDate__c = Date.today().addDays(1)
        );
        insert testExhibition;

        List<Internal_Registration__c> registrationList = new List<Internal_Registration__c>();
        for (Integer i=0; i<7; i++) {
            registrationList.add(new Internal_Registration__c(
                Approval_Status__c = '审批通过',
                Email__c  = 'test' + i + '@test.com',
                Exhibition_Id__c = testExhibition.Id,
                First_Name__c = 'test' + i,
                Last_Name__c = 'test' + i,
                Name = 'test' + i,
                Name_CN__c = '测试' + i,
                Is_Present__c = true,
                Phone__c = '11111111111',
                Product_Line__c = '电视;激光电视',
                Brand__c = 'Hisense',
                Region__c = '亚太地区 Asia-Pacific Region',
                Counry__c = '中国',
                Purpose_Of_Exhibition__c = '客户接待',
                Deliverable__c = 'word',
                Position__c = '销售'
            ));
        }
        registrationList[0].Brand__c = 'Gorenje;Hisense;OEM;Other Brands;Toshiba';
        registrationList[0].Product_Line__c = '电视;激光电视;其他';

        registrationList[1].Counry__c = '泰国';
        registrationList[1].Product_Line__c= '暖通空调;其他';

        registrationList[3].Region__c = '欧洲地区 Europe Region';
        registrationList[3].Counry__c= '比利时';
        registrationList[3].Product_Line__c= '电视;激光电视;小家电';
        insert registrationList;

        ExpoApplyInfo__c customer = new ExpoApplyInfo__c(
            ExpoId__c = testExhibition.Id,
            LastNameCN__c = '测试客户',
            FirstNameCN__c = '测',
            CompanyCN__c = '测试公司',
            Region__c = 'Asia-Pacific',
            CountryRegionCN__c = '中国台湾',
            ProductInterestCN__c = '电视;激光电视',
            BrandPreferenceCN__c= 'Hisense',
            Email__c = 'test@email.com',
            Telephone__c = '36789088'
        );

        ExpoApplyInfo__c customer2 = new ExpoApplyInfo__c(
            ExpoId__c = testExhibition.Id,
            LastNameCN__c = '测试客户2',
            FirstNameCN__c = '测2',
            CompanyCN__c = '测试公司2',
            Region__c = 'Asia-Pacific',
            CountryRegionCN__c = '中国台湾',
            ProductInterestCN__c = '电视;激光电视',
            BrandPreferenceCN__c= 'Hisense',
            Email__c = 'test2@email.com',
            Telephone__c = '36789087'
        );

        ExpoApplyInfo__c customer3 = new ExpoApplyInfo__c(
            ExpoId__c = testExhibition.Id,
            LastNameCN__c = '测试客户3',
            FirstNameCN__c = '测3',
            CompanyCN__c = '测试公司3',
            Region__c = 'Asia-Pacific',
            CountryRegionCN__c = '中国台湾',
            ProductInterestCN__c = '电视;激光电视',
            BrandPreferenceCN__c= 'Hisense',
            Email__c = 'test3@email.com',
            Telephone__c = '36789086',
            Reception_Email__c = 'test3@test.com'
        );
        insert new List<ExpoApplyInfo__c> { customer, customer2, customer3 };


    }

    @isTest
    static void testExhibitionCustomerAssignmentBatch() {

        ExpoInfo__c testExhibition = [SELECT Id, Name, TitleEN__c, StartDate__c, EndDate__c, LastRegistrationDate__c FROM ExpoInfo__c WHERE Name = '测试展会'];
        testExhibition.LastRegistrationDate__c = Date.today().addDays(-1);
        update testExhibition;

        Test.startTest();
        Database.executeBatch(new ExhibitionCustomerAssignmentBatch());
        Test.stopTest();
    }

    @isTest
    static void testExhibitionCustomerAssignmentSchedulable() {
        Test.startTest();
        System.schedule('ExhibitionCustomerAssignmentSchedulableTest', '0 0 9 * * ?', new ExhibitionCustomerAssignmentSchedulable());
        Test.stopTest();
    }
}