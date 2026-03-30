@isTest
private class ExhibitionSetCustomerOwnerTest {

    static testMethod void testMethod1() {
    	        String profileName  = '展会 展务组';
        Id profileId = [SELECT Id FROM profile WHERE Name = :profileName][0].Id; 
        User user1 = new User(alias = '区域经理', email='TestTom@noemail.com',
        emailencodingkey='UTF-8', lastname='TestTom', languagelocalekey='en_US',
        localesidkey='en_US',profileid = profileId, country='United States',IsActive =true,
        timezonesidkey='America/Los_Angeles', username='testTom@noemail.com');
        INSERT user1;

        User user2 = new User(alias = '区域经理', email='TestRTom@noemail.com',
        emailencodingkey='UTF-8', lastname='TestTom', languagelocalekey='en_US',
        localesidkey='en_US',profileid = profileId, country='United States',IsActive =true,
        timezonesidkey='America/Los_Angeles', username='testRTom@noemail.com');
        INSERT user2;

        User user3 = new User(alias = '区域经理', email='qTestRTom@noemail.com',
        emailencodingkey='UTF-8', lastname='TestTom', languagelocalekey='en_US',
        localesidkey='en_US',profileid = profileId, country='United States',IsActive =true,
        timezonesidkey='America/Los_Angeles', username='qtestRTom@noemail.com');
        INSERT user3;

        User user4 = new User(alias = '区域经理', email='wTestRTom@noemail.com',
        emailencodingkey='UTF-8', lastname='TestTom', languagelocalekey='en_US',
        localesidkey='en_US',profileid = profileId, country='United States',IsActive =true,
        timezonesidkey='America/Los_Angeles', username='wtestRTom@noemail.com');
        INSERT user4;

        User user5 = new User(alias = '区域经理', email='eTestRTom@noemail.com',
        emailencodingkey='UTF-8', lastname='TestTom', languagelocalekey='en_US',
        localesidkey='en_US',profileid = profileId, country='United States',IsActive =true,
        timezonesidkey='America/Los_Angeles', username='etestRTom@noemail.com');
        INSERT user5;

       

        Exhibition_Region_Owner__c e = new Exhibition_Region_Owner__c(Name = '测试用户', 
            Email__c = 'TestTom@noemail.com', 
            Primary_Department__c = 'America Region', 
            Secondary_Department__c = 'ChinaBrand');
        INSERT e;
        ExpoInfo__c e1 = new ExpoInfo__c(
            LastRegistrationDate__c = Date.today()+15, 
            StartDate__c = Date.today()-1, 
            EndDate__c = Date.today()+10,
            Name = '展会信息',
            TitleEN__c = 'Exhibition Informatino',
            DisplayInThePortal__c = true
            );
        INSERT e1;
        ExpoApplyInfo__c e2 = new ExpoApplyInfo__c(
            ExpoId__c = e1.Id,
            FirstNameEN__c = 'San',
            FirstNameCN__c = '三',
            LastNameCN__c = '张',
            LastNameEN__c = 'Zhang',
            Email__c = 'zs@zs.com',
            Telephone__c = '18712345678',
            WorkTel__c = '18712345678',
            CountryRegionEN__c = 'China',
            BrandPreferenceEN__c = 'Brand',
            Region__c = 'Asia-Pacific Region', CountryRegionCN__c='中国', ProductInterestCN__c = '小家电', BrandPreferenceCN__c = 'Hisense',           

            Is_Present__c = true,
            Owner_User1__c = user1.Id
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
            CountryRegionEN__c = 'China_',
            BrandPreferenceEN__c = 'Brand',
            Region__c = 'Asia-Pacific Region', CountryRegionCN__c='中国', ProductInterestCN__c = '小家电', BrandPreferenceCN__c = 'Hisense',           
            Is_Present__c = true,
            Owner_User2__c = user1.Id             
            );
        INSERT e3;

        ExpoApplyInfo__c e4 = new ExpoApplyInfo__c(
            ExpoId__c = e1.Id,
            FirstNameEN__c = 'SanSan',
            FirstNameCN__c = '三珊',
            LastNameCN__c = '李',
            LastNameEN__c = 'Li',
            Email__c = 'zestry@zs.com',
            Telephone__c = '187ewte123345678',
            WorkTel__c = '187treyr3te12345678',
            CountryRegionEN__c = 'China_',
            BrandPreferenceEN__c = 'Brand',
            Region__c = 'Asia-Pacific Region', CountryRegionCN__c='中国', ProductInterestCN__c = '小家电', BrandPreferenceCN__c = 'Hisense',           
            Is_Present__c = true,
            Owner_User3__c = user1.Id             
            );
        INSERT e4;

        ExpoApplyInfo__c e5 = new ExpoApplyInfo__c(
            ExpoId__c = e1.Id,
            FirstNameEN__c = 'SanSanw',
            FirstNameCN__c = '三珊w',
            LastNameCN__c = '张w',
            LastNameEN__c = 'Zhangw',
            Email__c = 'zswtry@zs.com',
            Telephone__c = '187ewwte12345678',
            WorkTel__c = '187trweyrte12345678',
            CountryRegionEN__c = 'China_',
            BrandPreferenceEN__c = 'Brand',
            Region__c = 'Asia-Pacific Region', CountryRegionCN__c='中国', ProductInterestCN__c = '小家电', BrandPreferenceCN__c = 'Hisense',           
            Is_Present__c = true,
            Owner_User4__c = user1.Id             
            );
        INSERT e5;

        ExpoApplyInfo__c e6 = new ExpoApplyInfo__c(
            ExpoId__c = e1.Id,
            FirstNameEN__c = 'SanSanr',
            FirstNameCN__c = '三珊r',
            LastNameCN__c = '张r',
            LastNameEN__c = 'Zhangr',
            Email__c = 'zstrry@zs.com',
            Telephone__c = '18r7ewte12345678',
            WorkTel__c = '187trreyrte12345678',
            CountryRegionEN__c = 'China_',
            BrandPreferenceEN__c = 'Brand',
            Region__c = 'Asia-Pacific Region', CountryRegionCN__c='中国', ProductInterestCN__c = '小家电', BrandPreferenceCN__c = 'Hisense',           
            Is_Present__c = true,
            Owner_User5__c = user1.Id             
            );
        INSERT e6;

        ExpoApplyInfo__c e7 = new ExpoApplyInfo__c(
            ExpoId__c = e1.Id,
            FirstNameEN__c = 'SanSant',
            FirstNameCN__c = '三珊t',
            LastNameCN__c = '张t',
            LastNameEN__c = 'Zhangt',
            Email__c = 'zstry@tzs.com',
            Telephone__c = '187ewtte12345678',
            WorkTel__c = '187treyrte1t2345678',
            CountryRegionEN__c = 'China_',
            BrandPreferenceEN__c = 'Brand',
            Region__c = 'Asia-Pacific Region', CountryRegionCN__c='中国', ProductInterestCN__c = '小家电', BrandPreferenceCN__c = 'Hisense',           
            Is_Present__c = true,
            Owner_User5__c = user2.Id             
            );
        INSERT e7;



        System.runAs(user1){
        	Test.startTest();

        	String currentUserId = UserInfo.getUserId();
   		    System.debug('TestcurrentUserId--->'+currentUserId);
   		    System.debug('runAs UserId--->'+user1.Id);

        	ExhibitionSetCustomerOwner.setCustomerOwner(e2.Id);
        	ExhibitionSetCustomerOwner.setCustomerOwner(e3.Id);
        	ExhibitionSetCustomerOwner.setCustomerOwner(e4.Id);
        	ExhibitionSetCustomerOwner.setCustomerOwner(e5.Id);
        	ExhibitionSetCustomerOwner.setCustomerOwner(e6.Id);
        	ExhibitionSetCustomerOwner.setCustomerOwner(e7.Id);
        	ExhibitionSetCustomerOwner.setCustomerOwner(e1.Id);
        	Test.stopTest();

        
        }        
    }

    static testMethod void testMethod2() {
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

        e3.BrandPreferenceEN__c = 'OEM';
        UPDATE e3;

        System.runAs(user4){

            Test.startTest();
            ExhibitionSetCustomerOwner.setCustomerOwner(e2.Id);
            ExhibitionSetCustomerOwner.setCustomerOwner(e3.Id);
            ExhibitionSetCustomerOwner.setCustomerOwner(e1.Id);
            Test.stopTest();
        }

      

       
        
    }
}