public with sharing class ExhibitionBusTriggerHandlerHelper {
    private final static String SITE_URL_MID = '-sites.com/exhibitionArrangementWithout/apex/ExhibitionArrPublicPage?id=';

	/**
     * @description 班车信息已分配，无法进行修改
     * @param       oldList     更改前数据
     * @param       newList     更改后数据
    */
    public static void isArrangedForbiddenUpdate(List<Exhibition_Regular_Bus_Booking__c> oldList, List<Exhibition_Regular_Bus_Booking__c> newList){
    	Map<Id, Exhibition_Regular_Bus_Booking__c> oldDataMap = new Map<Id, Exhibition_Regular_Bus_Booking__c>(oldList);
    	for (Exhibition_Regular_Bus_Booking__c item : newList) {
			if (item.Date__c.equals('2025-04-15')) {
    			item.addError('2025-04-15日班车提报已截至！您可选择其他日期的班车进行提报');
    		}
    		if (item.Is_Arranged__c && oldDataMap.get(item.Id).Is_Arranged__c) {
    			item.addError('名为：'+ item.Guest_Name_CN__c +' 的车辆已分配，无法再次分配！');
    		}
    	}
	}

	/**
     * @description 车辆分配后发送通知邮件
     * @param       oldList     更改前数据
     * @param       newList     更改后数据
    */
	public static void sendEmail(List<Exhibition_Regular_Bus_Booking__c> oldList, List<Exhibition_Regular_Bus_Booking__c> newList){
		String SITE_URL_FRO = System.Url.getOrgDomainUrl().toExternalForm().split('.com')[0];
		Map<Id, Exhibition_Regular_Bus_Booking__c> oldDataMap = new Map<Id, Exhibition_Regular_Bus_Booking__c>(oldList);
		                               	
        EmailTemplate notice = [SELECT Id, Name, Subject, HtmlValue, Body, BrandTemplateId, DeveloperName FROM EmailTemplate WHERE DeveloperName = 'Exhibition_Shuttle_Bus' LIMIT 1];
                                    
		// System.Url.getOrgDomainUrl().toExternalForm()
		List<Messaging.SingleEmailMessage> sendEmailList = new List<Messaging.SingleEmailMessage>();
		Map<String, List<String>> personInfoMap = new Map<String, List<String>>();
    	for (Exhibition_Regular_Bus_Booking__c item : newList) {
			if (item.Is_Arranged__c && !oldDataMap.get(item.Id).Is_Arranged__c) {

				Messaging.SingleEmailMessage singleEmail = new Messaging.SingleEmailMessage();
				String toEmail = item.Guest_Email__c;
				List<Messaging.RenderEmailTemplateBodyResult> renderEmailTemplateBodyRes = Messaging.renderEmailTemplate(item.OwnerId, item.Id, new List<String>{notice.HtmlValue});
				String body = renderEmailTemplateBodyRes[0].getMergedBody();
				System.debug('body=' + body);
				singleEmail.setHTMLBody(body);
				singleEmail.setSaveAsActivity(false);
				singleEmail.setSubject(notice.Subject + '');
				//设置发送人邮箱
				singleEmail.setOrgWideEmailAddressId(System.Label.Exhibition_Public_Mailbox);
				singleEmail.setToAddresses(new List<String>{toEmail});
				sendEmailList.add(singleEmail);
				// 短信
				System.debug('' +notice.Id +  item.Id + notice.Body );
                renderEmailTemplateBodyRes = Messaging.renderEmailTemplate(notice.Id, item.Id, new List<String>{notice.Body});
				body = renderEmailTemplateBodyRes[0].getMergedBody();
				System.debug('body=' + body);
				if(personInfoMap.containsKey(item.Guest_Phone__c)) {
					personInfoMap.get(item.Guest_Phone__c).add(body);
				} else {
					personInfoMap.put(item.Guest_Phone__c, new List<String>{body});
				}
    		}
    	}
    	if (sendEmailList.size() > 0) {
			System.debug('------------>ready send ! ');
			try {
				Messaging.sendEmail(sendEmailList);
			}
			catch (Exception e) {
				System.debug('ExhibitionBusTriggerHandlerHelper.sendEmail->'+e.getLineNumber()+e.getMessage());
			}
		}
		if(personInfoMap.keyset().size() > 0) {
            // ExpoApplyInfoTriggerHanderHelper.sendMessage(Json.serialize(personInfoMap));
        }
    }
}