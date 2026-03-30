public with sharing class AnnualEventNotificationThreeMethod {
    public static void processMailCC(){
        
        // 查询出邮件发送人的邮箱地址
        List<Internal_Registration__c> registrationList = [SELECT Id,Name_CN__c, Email__c,Phone__c,OwnerId from  Internal_Registration__c where Exhibition_Id__r.Name like '%2025%' And Approval_Status__c = '审批通过' ];
        //List<Internal_Registration__c> registrationList = [SELECT Id,Name_CN__c, Email__c,Phone__c,OwnerId from  Internal_Registration__c where Exhibition_Id__r.Name like '%2025%' And Approval_Status__c = '高级权限' And Name like '%陶%' ];

        // Map<Id, Exhibition_Vehical_Booking__c> oldDataMap = new Map<Id, Exhibition_Vehical_Booking__c>(oldList);
		EmailTemplate emtemp = [SELECT Id, Name, Subject, HtmlValue, Body, BrandTemplateId, DeveloperName FROM EmailTemplate WHERE DeveloperName = 'Annual_Meeting_Event_Notice_Three' LIMIT 1];
		List<Messaging.SingleEmailMessage> sendEmailList = new List<Messaging.SingleEmailMessage>();
		Map<String, List<String>> personInfoMap = new Map<String, List<String>>();
        for (Internal_Registration__c item : registrationList) {

            Messaging.SingleEmailMessage singleEmail = new Messaging.SingleEmailMessage();
			String toEmail = item.Email__c;
			List<Messaging.RenderEmailTemplateBodyResult> renderEmailTemplateBodyRes = Messaging.renderEmailTemplate(item.OwnerId, item.Id, new List<String>{emtemp.HtmlValue});
			String body = renderEmailTemplateBodyRes[0].getMergedBody();
			System.debug('body=' + body);
			singleEmail.setHTMLBody(body);
			singleEmail.setSaveAsActivity(false);
			// singleEmail.setTemplateId(emtemp.Id);
			// singleEmail.setWhatId(item.Id);
			singleEmail.setSubject(emtemp.Subject + '');
			//设置发送人邮箱
			singleEmail.setOrgWideEmailAddressId(System.Label.Exhibition_Public_Mailbox);
			singleEmail.setToAddresses(new List<String>{toEmail});
			sendEmailList.add(singleEmail);

			// 短信
            // System.debug('' +tempOfSMS.Id +  item.Id + tempOfSMS.Body );
            renderEmailTemplateBodyRes = Messaging.renderEmailTemplate(item.OwnerId, item.Id, new List<String>{emtemp.Body});
			body = renderEmailTemplateBodyRes[0].getMergedBody();
			System.debug('body=' + body);
			if(personInfoMap.containsKey(item.Phone__c)) {
				personInfoMap.get(item.Phone__c).add(body);
			} else {
				personInfoMap.put(item.Phone__c, new List<String>{body});
			}
        }
    	
    	if (sendEmailList.size() > 0) {
			System.debug('------------>ready send ! ');
			try {
				Messaging.sendEmail(sendEmailList);
			}
			catch (Exception e) {
				System.debug('AnnualEventNotificationEmailAndSmsMethod.sendEmail->'+e.getLineNumber()+e.getMessage());
			}
		}
		if(personInfoMap.keyset().size() > 0) {
            // 发送短信通知
            sendMessage(Json.serialize(personInfoMap));
        }
    
    }
    


    @future (callout=true)
    public static void sendMessage(String personInfoMapJson) {
        Map<String, List<String>> personInfoMap = (Map<String, List<String>>)JSON.deserialize(personInfoMapJson, Map<String, List<String>>.class);
        for(String key : personInfoMap.keyset()) {
            for(String message : personInfoMap.get(key)) {
               HisenseSMSUtility.sendSMS(key, message); 
            }
        }
        HisenseSMSUtility.saveLog();
    }

}