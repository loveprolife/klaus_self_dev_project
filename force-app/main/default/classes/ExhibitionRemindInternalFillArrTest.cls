@isTest
private class ExhibitionRemindInternalFillArrTest {
     static testMethod void testMethod1() {
        ExpoInfo__c e1 = new ExpoInfo__c(
        	LastRegistrationDate__c = Date.today()+15, 
        	StartDate__c = Date.today()+1, 
        	EndDate__c = Date.today()+10,
        	Name = '展会信息',
        	TitleEN__c = 'Exhibition Informatino',
        	DisplayInThePortal__c = true
        	);
        INSERT e1;

        Internal_Registration__c e2 = new Internal_Registration__c(
        	Exhibition_Id__c = e1.Id,
        	Email__c = 'etpeng@deloitte.com.cn',
        	Position__c = '经理',
        	Phone__c = '18712345678',
        	Name_CN__c = '张三',
        	// //Purpose_Of_Exhibition__c = '参展目的',
        	Deliverable__c = 'werytukjgfsdtrewertyuilkftgjdfrelgeoiagoewutoewutpewprwqoupwertyuiowytrertyuioiytryuoipiuuweoiriueygwritwerhitoewqhojhewfrihgoierjhotkohgjdslgjrojyore',
			Approval_Status__c = '审批通过'
			);
        INSERT e2;

        Exhibition_Hotel__c h1 = new Exhibition_Hotel__c(Name = 'hotel1',
        	Exhibition_Management__c = e1.Id);
        INSERT h1;
        Exhibition_Hotel__c h2 = new Exhibition_Hotel__c(Name = 'hotel2',
        	Exhibition_Management__c = e1.Id);
        INSERT h2;

        Exhibition_Arrangement__c e3 = new Exhibition_Arrangement__c(
        	Internal_Registration__c = e2.Id,
        	Roommate__c = 'shiyong');

        UPSERT e3;

        Exhibition_Vehical_Booking__c b1 = new Exhibition_Vehical_Booking__c(
            Vehicle_Type__c = '大巴',
            Date__c = Date.today(),
            Exhibition_Arrangement__c = e3.Id,
            Internal_Registration__c = e2.Id);
        INSERT b1;
        Exhibition_Vehical_Booking__c b2 = new Exhibition_Vehical_Booking__c(
            Vehicle_Type__c = '大巴',
            Date__c = Date.today(),
            Exhibition_Arrangement__c = e3.Id,
            Internal_Registration__c = e2.Id,
            Is_Arranged__c = TRUE);
        INSERT b2;

        



        ExhibitionRemindInternalFillArrSchedule sch = new ExhibitionRemindInternalFillArrSchedule();
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
        	StartDate__c = Date.today()+1, 
        	EndDate__c = Date.today()+10,
        	Name = '展会信息',
        	TitleEN__c = 'Exhibition Informatino',
        	DisplayInThePortal__c = true
        	);
        INSERT e1;

       	Internal_Registration__c e2 = new Internal_Registration__c(
        	Exhibition_Id__c = e1.Id,
        	Email__c = 'etpeng@deloitte.com.cn',
        	Position__c = '经理',
        	Phone__c = '18712345678',
        	Name_CN__c = '张三',
        	// //Purpose_Of_Exhibition__c = '参展目的',
        	Deliverable__c = 'werytukjgfsdtrewertyuilkftgjdfrelgeoiagoewutoewutpewprwqoupwertyuiowytrertyuioiytryuoipiuuweoiriueygwritwerhitoewqhojhewfrihgoierjhotkohgjdslgjrojyore',
			Approval_Status__c = '审批通过'
			);
        INSERT e2;

        Exhibition_Hotel__c h1 = new Exhibition_Hotel__c(Name = 'hotel1',
        	Exhibition_Management__c = e1.Id);
        INSERT h1;
        Exhibition_Hotel__c h2 = new Exhibition_Hotel__c(Name = 'hotel2',
        	Exhibition_Management__c = e1.Id);
        INSERT h2;

        Exhibition_Arrangement__c e3 = new Exhibition_Arrangement__c(
        	Internal_Registration__c = e2.Id,
        	Roommate__c = 'shiyong');

        UPSERT e3;

        Exhibition_Vehical_Booking__c b1 = new Exhibition_Vehical_Booking__c(
            Vehicle_Type__c = '大巴',
            Date__c = Date.today(),
            Exhibition_Arrangement__c = e3.Id,
            Internal_Registration__c = e2.Id);
        INSERT b1;
        Exhibition_Vehical_Booking__c b2 = new Exhibition_Vehical_Booking__c(
            Vehicle_Type__c = '大巴',
            Date__c = Date.today(),
            Exhibition_Arrangement__c = e3.Id,
            Internal_Registration__c = e2.Id,
            Is_Arranged__c = TRUE);
        INSERT b2;




		ExhibitionRemindInternalFillArrBatch eb = new ExhibitionRemindInternalFillArrBatch();
		Database.executeBatch(eb, 80);

    }
}