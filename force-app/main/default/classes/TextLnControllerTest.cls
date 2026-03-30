@isTest
private class TextLnControllerTest {
    static testMethod void testMethod1() {
    	Test.startTest();
        String profileName  = '展会 展务组';
        Id profileId = [SELECT Id FROM profile WHERE Name = :profileName][0].Id; 
        User user1 = new User(alias = '区域经理', email='TestTom@noemail.com',
        emailencodingkey='UTF-8', lastname='TestTom', languagelocalekey='en_US',
        localesidkey='en_US',profileid = profileId, country='United States',IsActive =true,
        timezonesidkey='America/Los_Angeles', username='testTom@noemail.com');
        INSERT user1;

        User user2 = new User(alias = '区域经理', email='QTestTom@noemail.com',
        emailencodingkey='UTF-8', lastname='TestTom', languagelocalekey='en_US',
        localesidkey='en_US',profileid = profileId, country='United States',IsActive =true,
        timezonesidkey='America/Los_Angeles', username='qtestTom@noemail.com');
        INSERT user2;

        User user3 = new User(alias = '区域经理', email='WTestTom@noemail.com',
        emailencodingkey='UTF-8', lastname='TestTom', languagelocalekey='en_US',
        localesidkey='en_US',profileid = profileId, country='United States',IsActive =true,
        timezonesidkey='America/Los_Angeles', username='wtestTom@noemail.com');
        INSERT user3;

        User user4 = new User(alias = '区域经理', email='ETestTom@noemail.com',
        emailencodingkey='UTF-8', lastname='TestTom', languagelocalekey='en_US',
        localesidkey='en_US',profileid = profileId, country='United States',IsActive =true,
        timezonesidkey='America/Los_Angeles', username='etestTom@noemail.com');
        INSERT user4;

        Exhibition_Region_Owner__c e = new Exhibition_Region_Owner__c(Name = '测试用户', 
            Email__c = 'TestTom@noemail.com', 
            Primary_Department__c = 'Asia-Pacific Region', 
            Secondary_Department__c = 'ChinaBrand',
            Counry__c = '中国', Brand__c = 'Hisense', Product_Line__c = '小家电');
        INSERT e;
        Exhibition_Region_Owner__c ee = new Exhibition_Region_Owner__c(Name = '测试用户', 
            Email__c = 'QTestTom@noemail.com', 
            Primary_Department__c = 'Asia-Pacific Region', 
            Secondary_Department__c = 'ChinaBrand',
            Counry__c = '中国', Brand__c = 'Hisense;OEM', Product_Line__c = '');
        INSERT ee;
        Exhibition_Region_Owner__c ee1 = new Exhibition_Region_Owner__c(Name = '测试用户', 
            Email__c = 'WTestTom@noemail.com', 
            Primary_Department__c = 'Asia-Pacific Region', 
            Secondary_Department__c = 'ChinaBrand',
            Counry__c = '中国', Brand__c = '', Product_Line__c = '');
        INSERT ee1;
        Exhibition_Region_Owner__c ee12 = new Exhibition_Region_Owner__c(Name = '测试用户', 
            Email__c = 'ETestTom@noemail.com', 
            Primary_Department__c = 'Asia-Pacific Region', 
            Secondary_Department__c = 'ChinaBrand',
            Counry__c = '', Brand__c = '', Product_Line__c = '');
        INSERT ee12;

        ExpoProductPreference__c pro = new ExpoProductPreference__c(Name = '小家电',ProductEN__c = ' Small Domestic Appliance（SDA）');
        INSERT pro;

        ExpoCountrysBazaar__c ctry = new ExpoCountrysBazaar__c(Name = '中国', NameEN__c = 'China');
        INSERT ctry;
        ExpoInfo__c e1 = new ExpoInfo__c(
        	LastRegistrationDate__c = Date.today()+15, 
        	StartDate__c = Date.today()-1, 
        	EndDate__c = Date.today()+10,
        	Name = '展会信息',
        	TitleEN__c = 'Exhibition Informatino',
        	DisplayInThePortal__c = true
        	);
        INSERT e1;

        // TextLnController textln = 

        TextLnController.createRecord(e1.Id, 'lastNameCN', 'lastNameEN', 'firstNameCN', 'firstNameEN', 
        	'28712345678', 'email@etret.com', '18712345432', '437694703', '40968457','duty', '部门','dshtoiewoa','rewot.com', 'jtoewer', 'oegwhgoiew', true, '');


       

        ExpoApplyInfo__c e2 = new ExpoApplyInfo__c(
            ExpoId__c = e1.Id,
            FirstNameEN__c = 'San',
            FirstNameCN__c = '三',
            LastNameCN__c = '张',
            LastNameEN__c = 'Zhang',
            Email__c = 'zs@zs.com',
            Telephone__c = '18712345678',
            WorkTel__c = '18712345678',
            Region__c = 'Asia-Pacific Region', CountryRegionCN__c='中国', ProductInterestCN__c = '小家电', BrandPreferenceCN__c = 'Hisense',
            Is_Present__c = true            
            );
        INSERT e2;

        ExpoApplyInfo__c e3 = new ExpoApplyInfo__c(
            ExpoId__c = e1.Id,
            FirstNameEN__c = 'SanSan',
            FirstNameCN__c = '三珊',
            LastNameCN__c = '张',
            LastNameEN__c = 'Zhang',
            Email__c = 'zstry@zs.com',
            Telephone__c = '187ewte12345678',
            WorkTel__c = '187treyrte12345678',
            Region__c = 'Asia-Pacific Region', CountryRegionEN__c='China', ProductInterestEN__c = '小家电', BrandPreferenceEN__c = 'Hisense',
            Is_Present__c = true            
            );
        INSERT e3;


        TextLnController.queryOwnerInfo(e2.Id);

        TextLnController.queryOwnerInfo(e3.Id);


        ExpoApplyInfo__c customer = new ExpoApplyInfo__c();
        customer.Country__c = '中国';
        customer.ProductInterestCN__c = '电视';
        TextLnController.createRecord(e1.Id, 'lastNameCN', 'lastNameEN', 'firstNameCN', 'firstNameEN', 
        	'28712345678', 'email@etret.com', '18712345432', '437694703', '40968457','duty', '部门','dshtoiewoa','rewot.com', 'jtoewer', 'oegwhgoiew', true, Json.serialize(customer));

        TextLnController.getExhibitionOptions();


        Test.stopTest();
    }
}