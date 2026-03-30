//当日到次日10点为止未填写日报通知巡店员的邮件
global class NatificationInspectionSchedulable implements Schedulable {
    global void execute(SchedulableContext sc) {
    	Map<Id,User> userMap = new Map<Id,User>();
    	for (User u : [SELECT Id,Email FROM User WHERE Profile.Name='巡店员']) {
    		userMap.put(u.Id,u);  	
    	} 
    	Date today = System.today();

    	
    	for (Daily_Inspection_Report__c dir : [SELECT Id,OwnerId,Owner.Email FROM Daily_Inspection_Report__c WHERE Report_Date__c =:today] ) {
    		if (userMap.get(dir.OwnerId)!=null) {
    			userMap.remove(dir.OwnerId);			
    		}	
    	} 

		List<EmailTemplate> etList = EmailNotificationUtility.getEmailTemplate('InspectorDailyReportNotification');
		if(etList.size() > 0) {
			Set<Id> userIdSet = userMap.keySet();
			EmailNotificationUtility.sendEmailNotificationReplaceTargetUser(etList[0],new List<Id>(userIdSet));
		}

		/*
    	Set<String> emialSet = new Set<String>();
    	for (String userId : userMap.keySet()) {
    		emialSet.add(userMap.get(userId).Email);
    	}

    	if (emialSet.size()>0) {
    		List<String> userEmialList = new List<String>();
	        userEmialList.addAll(emialSet);
	        Messaging.SingleEmailMessage dealerReopenEmail = new Messaging.SingleEmailMessage();
	        dealerReopenEmail.setPlainTextBody(String.valueOf(today)+'号巡店员日报未填写，请前往系统中填写。如已填写请忽略。');
	        dealerReopenEmail.setSubject('巡店员日报填写提醒');
	        dealerReopenEmail.setCharset('UTF-8');
	        dealerReopenEmail.setToAddresses(userEmialList);
	        List<Messaging.SendEmailResult> SendResult = Messaging.sendEmail(new Messaging.SingleEmailMessage[] { dealerReopenEmail });	
    	}
		*/
    }
}