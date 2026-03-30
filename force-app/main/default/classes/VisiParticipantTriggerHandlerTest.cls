@isTest
private class VisiParticipantTriggerHandlerTest {
	public static Map<String,Profile> profileMap;
    static{
        profileMap = new Map<String,Profile>();
        List<String> pNameList = new List<String>{'System Administrator','SD Cost Team'};
        for(Profile p : [SELECT Id,Name FROM Profile WHERE Name IN:pNameList]){
            profileMap.put(p.Name, p);      
        }
    }
    static testMethod void testMethod1() {
    	Test.startTest();
    	list<User> uselist = TestDataUtility.createUserList(true);
    	User user3 = new User(
            Alias = 'admin2', Email='systemadmin2@hisensetest2.com',
            EmailEncodingKey='UTF-8', LastName='sales representative2', LanguageLocaleKey='en_US',
            LocaleSidKey='en_US', ProfileId = profileMap.get('System Administrator').Id, TimeZoneSidKey='Asia/Kuala_Lumpur',
            UserName='systemadmin2@hisensetest2.com'
        );
        insert user3;
    	
    	System.runAs(uselist[0]){
    		Customer_Visit__c  newcustomvisit = new Customer_Visit__c(
    									Name = 'testcustomervisit');
    		insert newcustomvisit;
	        Visit_Participant__c newVisitp = new Visit_Participant__c(
	        								Hisense_Participant__c = user3.id,
	        								Customer_Visit__c = newcustomvisit.Id);
	        Insert newVisitp;
	        try{
		        Visit_Participant__c newVisitp2 = new Visit_Participant__c(
		        								Hisense_Participant__c = user3.id,
		        								Customer_Visit__c = newcustomvisit.Id);
		        Insert newVisitp2;
		    }catch(Exception e){
		    	System.debug(e.getMessage());
		    	System.assert(e.getMessage() == 'Insert failed. First exception on row 0; first error: FIELD_CUSTOM_VALIDATION_EXCEPTION, The Participant has Already been Added !: []');
		    }
	        delete newVisitp;
	    }
	    Test.stopTest();
    }
}