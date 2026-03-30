@isTest
private class SendingEmailToHSParticipantTest {
	public static Map<String,Profile> profileMap;
    static{
        profileMap = new Map<String,Profile>();
        List<String> pNameList = new List<String>{'System Administrator','SD Cost Team'};
        for(Profile p : [SELECT Id,Name FROM Profile WHERE Name IN:pNameList]){
            profileMap.put(p.Name, p);      
        }
    }
    static testMethod void testMethod1() {
    	User user3 = new User(
            Alias = 'admin2', Email='systemadmin2@hisensetest2.com',
            EmailEncodingKey='UTF-8', LastName='sales representative2', LanguageLocaleKey='en_US',
            LocaleSidKey='en_US', ProfileId = profileMap.get('System Administrator').Id, TimeZoneSidKey='Asia/Kuala_Lumpur',
            UserName='systemadmin2@hisensetest2.com'
        );
        insert user3;
        Customer_Visit__c  newcustomvisit = new Customer_Visit__c(
    									Name = 'testcustomervisit');
		insert newcustomvisit;
        Id RecordTypeid1 = Schema.SObjectType.Visit_Participant__c.getRecordTypeInfosByDeveloperName().get('Hisense_Participant').getRecordTypeId();
        Visit_Participant__c newvisitrecord = new Visit_Participant__c(
        											Hisense_Participant_Email__c = 'test@test1.com',
        											Hisense_Participant__c = user3.id,
        											Customer_Visit__c = newcustomvisit.Id,
        											RecordTypeid = RecordTypeid1);
        Insert newvisitrecord;
        List<Id>  idlist= new List<Id>();
        idlist.add(newcustomvisit.Id);

        SendingEmailToHSParticipant.sendingEmail(idlist);

    }
}