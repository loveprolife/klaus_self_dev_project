@isTest
private class ExhibitionRemindInternalTest {
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

        Internal_Registration__c e2 = new Internal_Registration__c(
        	Exhibition_Id__c = e1.Id,
        	Email__c = 'etpeng@deloitte.com.cn',
        	Position__c = '经理',
        	Phone__c = '18712345678',
        	Name_CN__c = '张三',
            Approval_Status__c = '审批通过',
            Company_Abbr__c = '国际营销',
        	// Purpose_Of_Exhibition__c = '参展目的',
        	Deliverable__c = 'werytukjgfsdtrewertyuilkftgjdfrelgeoiagoewutoewutpewprwqoupwertyuiowytrertyuioiytryuoipiuuweoiriueygwritwerhitoewqhojhewfrihgoierjhotkohgjdslgjrojyore'
			);
        INSERT e2;



        ExhibitionRemindInternalSchedule sch = new ExhibitionRemindInternalSchedule();
		String fmt = '0 0 0/1 * * ? *';
		System.schedule('ExhibitionRemindInternalSchedule for Test', fmt, sch);
    }

     static testMethod void testMethod2() {
        ExpoInfo__c e1 = new ExpoInfo__c(
        	LastRegistrationDate__c = Date.today()+15, 
        	StartDate__c = Date.today()-90, 
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
        	// Purpose_Of_Exhibition__c = '参展目的',
            Approval_Status__c = '审批通过',
            Company_Abbr__c = '国际营销',
        	Deliverable__c = 'werytukjgfsdtrewertyuilkftgjdfrelgeoiagoewutoewutpewprwqoupwertyuiowytrertyuioiytryuoipiuuweoiriueygwritwerhitoewqhojhewfrihgoierjhotkohgjdslgjrojyore'

			);
        INSERT e2;



        ExhibitionRemindInternalBatch ba = new ExhibitionRemindInternalBatch();
		Database.executeBatch(ba, 80);
    }
}