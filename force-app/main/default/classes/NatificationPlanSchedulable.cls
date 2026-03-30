/**
 * @description       : 
 * @author            : chenpeng@deloitte.com.cn
 * @group             : 
 * @last modified on  : 03-21-2022
 * @last modified by  : chenpeng@deloitte.com.cn
**/
global class NatificationPlanSchedulable implements Schedulable {
    global void execute(SchedulableContext sc) {
    	Map<Id,User> userMap = new Map<Id,User>();
    	for (User u : [SELECT Id,Email FROM User WHERE Profile.Name='巡店员']) {
    		userMap.put(u.Id,u);  	
    	} 
    	Date today = System.today();
    	Integer days = Date.daysInMonth(today.year(), today.month());
    	if (days-today.day()==3 || Test.isRunningTest()) {
    		today = today.addMonths(1);
	    	String year = String.valueOf(today.year());
	    	String month = String.valueOf(today.month());
	    	
	    	for (Inspection_Shop_Plan__c dir : [SELECT Id,OwnerId,Owner.Email FROM Inspection_Shop_Plan__c WHERE Inspection_Year__c =:year AND Inspection_Month__c =:month] ) {
	    		if (userMap.get(dir.OwnerId)!=null) {
	    			userMap.remove(dir.OwnerId);			
	    		}	
	    	}

	    	Set<String> emialSet = new Set<String>();
	    	for (String userId : userMap.keySet()) {
	    		emialSet.add(userMap.get(userId).Email);
	    	}

	    	if (emialSet.size()>0) {
	    		List<String> userEmialList = new List<String>();
		        userEmialList.addAll(emialSet);
		        Messaging.SingleEmailMessage dealerReopenEmail = new Messaging.SingleEmailMessage();
		        dealerReopenEmail.setPlainTextBody(year+'-'+month+'巡店员计划还未填写，请前往系统中填写。如已填写请忽略。');
		        dealerReopenEmail.setSubject('巡店员计划填写提醒');
		        dealerReopenEmail.setCharset('UTF-8');
		        dealerReopenEmail.setToAddresses(userEmialList);
                Email_Switch__mdt isActiveEmailMdt = [SELECT IsActive__c FROM Email_Switch__mdt WHERE DeveloperName = 'IsActive'];
                if (isActiveEmailMdt.IsActive__c) {
                    List<Messaging.SendEmailResult> SendResult = Messaging.sendEmail(new Messaging.SingleEmailMessage[] { dealerReopenEmail });	
                }
	    	}	
    	}
    }
}