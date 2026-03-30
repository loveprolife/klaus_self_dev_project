@isTest
private class ExpoCallBackTest {
    static testMethod void testMethod1() {
    	ExpoProductPreference__c f1 = new ExpoProductPreference__c(Name =  '产品');
    	INSERT f1;
    	ExpoBrandPreference__c f2 = new ExpoBrandPreference__c(Name = '品牌');
    	INSERT f2;
    	ExpoCountrysBazaar__c f3 = new ExpoCountrysBazaar__c(Name = '中国', NameEN__c = 'China');
    	INSERT f3;

    	f1.Name = '产品1';
    	UPDATE f1;
    	f2.Name = 'Brand';
    	UPDATE f2;
    	f3.Name = '中 国';
    	UPDATE f3;

   		DELETE f1;


        ExpoInfo__c e1 = new ExpoInfo__c(
        	LastRegistrationDate__c = Date.today()+15, 
        	StartDate__c = Date.today()-1, 
        	EndDate__c = Date.today()+10,
        	Name = '展会信息',
        	TitleEN__c = 'Exhibition Informatino',
        	DisplayInThePortal__c = true
        	);
        INSERT e1;

        ExpoSchedule__c e2 = new ExpoSchedule__c(
        	ExpoId__c = e1.Id,
        	ExpoDay__c = Date.today()+1,
        	StartTime__c = Time.newInstance(7, 7, 7, 7),
        	EndTime__c = Time.newInstance(17, 7, 7, 7)
        	);
        INSERT e2;

        ExpoHisImage__c e3 = new ExpoHisImage__c(
        	ExpoId__c = e1.Id,
        	Name = '展会历史图片', 
        	TitleEN__c = 'His Image'
        	);
        INSERT e3;

        ExpoContact__c e4 = new ExpoContact__c(
        	ExpoId__c = e1.Id,
        	LastNameCN__c = '张', 
        	FirstNameCN__c = '三',
            LastNameEN__c = 'Zhang', 
            FirstNameEN__c = 'San',
        	Telephone__c = '18712345678',
        	TitilCN__c = '经理',
        	AreaCN__c = '亚太',
        	Email__c = 'reereewtwela@Hisense.com',
        	Type__c = '0'
        	);
        INSERT e4;

        ExpoAreaImage__c e5 = new ExpoAreaImage__c(
        	ExpoId__c = e1.Id,
        	Name = '区域图',
        	TitleEN__c = 'Area Image');
        INSERT e5;

        ExpoBannerImage__c e6 = new ExpoBannerImage__c(
        	ExpoId__c = e1.Id,
        	Name = 'test134.com');
        INSERT e6;









    }
}