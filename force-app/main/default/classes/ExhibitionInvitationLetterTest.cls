@isTest
private class ExhibitionInvitationLetterTest {
    static testMethod void testMethod1() {
        ExpoInfo__c e1 = new ExpoInfo__c(
        	LastRegistrationDate__c = Date.today()+15, 
        	StartDate__c = Date.today()-90, 
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
			Is_Present__c = true        	
			);
        INSERT e2;



        ExhibitionInvitationLetterSchedule sch = new ExhibitionInvitationLetterSchedule();
		String fmt = '0 0 0/1 * * ? *';
		System.schedule('ExhibitionInvitationLetterSchedule for Test', fmt, sch);

    }

    static testMethod void testMethod2() {
        String profileName  = '展会 行政商务组';
        Id profileId = [SELECT Id FROM profile WHERE Name = :profileName][0].Id; 
        User user1 = new User(alias = '区域经理', email='TestTom@noemail.com',
        emailencodingkey='UTF-8', lastname='TestTom', languagelocalekey='en_US',
        localesidkey='en_US',profileid = profileId, country='United States',IsActive =true,
        timezonesidkey='America/Los_Angeles', username='testTom@noemail.com');
        INSERT user1;
        
        ExpoInfo__c e1 = new ExpoInfo__c(
        	LastRegistrationDate__c = Date.today()+15, 
        	StartDate__c = Date.today()-90, 
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
			Is_Present__c = true        	
			);
        INSERT e2;



		ExhibitionInvitationLetterBatch eb = new ExhibitionInvitationLetterBatch();
		Database.executeBatch(eb, 80);

    }
}