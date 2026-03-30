public without sharing class ExhibitionVehicalTriggerHandlerHelper {
    private final static String SITE_URL_MID = '-sites.com/exhibitionArrangementWithout/apex/ExhibitionArrPublicPage?id=';

	/**
     * @description 车辆信息已分配，无法再次分配
     * @param       oldList     更改前数据
     * @param       newList     更改后数据
    */
    public static void isArrangedForbiddenUpdate(List<Exhibition_Vehical_Booking__c> oldList, List<Exhibition_Vehical_Booking__c> newList){
    	Map<Id, Exhibition_Vehical_Booking__c> oldDataMap = new Map<Id, Exhibition_Vehical_Booking__c>(oldList);
    	for (Exhibition_Vehical_Booking__c item : newList) {
    		if (item.Is_Arranged__c && oldDataMap.get(item.Id).Is_Arranged__c) {
				if(isFieldChangedOrEmpty(item.Vehicle_Run_Time__c, oldDataMap.get(item.Id).Vehicle_Run_Time__c) ||
					isFieldChangedOrEmpty(item.Date__c, oldDataMap.get(item.Id).Date__c) ||
					isFieldChangedOrEmpty(item.Departure_Time__c, oldDataMap.get(item.Id).Departure_Time__c) ||
					isFieldChangedOrEmpty(item.Pick_Up_Point__c, oldDataMap.get(item.Id).Pick_Up_Point__c) ||
					isFieldChangedOrEmpty(item.Vehicle_Allocation_Schedule__c, oldDataMap.get(item.Id).Vehicle_Allocation_Schedule__c)) {
						item.addError('名为：'+ item.Guest_Name_EN__c +' 的接机车辆信息已分配，无法修改并分配！');
				}
			}
			if (item.Return_Is_Arranged__c && oldDataMap.get(item.Id).Return_Is_Arranged__c) {
				if(isFieldChangedOrEmpty(item.Return_Vehicle_Run_Time__c,oldDataMap.get(item.Id).Return_Vehicle_Run_Time__c) ||
				isFieldChangedOrEmpty(item.Return_Date__c,oldDataMap.get(item.Id).Return_Date__c)||
				isFieldChangedOrEmpty(item.Return_Departure_Time__c,oldDataMap.get(item.Id).Return_Departure_Time__c)||
				isFieldChangedOrEmpty(item.Return_Pick_Up_Point__c,oldDataMap.get(item.Id).Return_Pick_Up_Point__c) || 
				isFieldChangedOrEmpty(item.Return_Vehicle_Schedule__c,oldDataMap.get(item.Id).Return_Vehicle_Schedule__c)){
					item.addError('名为：'+ item.Guest_Name_EN__c +' 的送机车辆信息已分配，无法修改并分配！');
				}
    		}
    	}
	}

	private static boolean isFieldChangedOrEmpty(Object newItemValue, Object oldItemValue) {
		if (newItemValue == null && oldItemValue == null) {
			return false;
		}
		return newItemValue == null || oldItemValue == null || !newItemValue.equals(oldItemValue);
	}

	/**
     * @description 车辆分配后发送通知邮件
     * @param       oldList     更改前数据
     * @param       newList     更改后数据
    */
	public static void sendEmail(List<Exhibition_Vehical_Booking__c> oldList, List<Exhibition_Vehical_Booking__c> newList){
		String SITE_URL_FRO = System.Url.getOrgDomainUrl().toExternalForm().split('.com')[0];
		Map<Id, Exhibition_Vehical_Booking__c> oldDataMap = new Map<Id, Exhibition_Vehical_Booking__c>(oldList);
		EmailTemplate emtemp = [SELECT Id, Name, Subject, HtmlValue, Body, BrandTemplateId, DeveloperName FROM EmailTemplate WHERE DeveloperName = 'Exhibition_Vehicle_Arrangements_Email' LIMIT 1];
		EmailTemplate tempOfSMS = [SELECT Id, Name, Subject, HtmlValue, Body, BrandTemplateId, DeveloperName 
                                            FROM EmailTemplate
                                            WHERE DeveloperName = 'Exhibition_Vehicle_Arrangements_SMS' LIMIT 1];
		// System.Url.getOrgDomainUrl().toExternalForm()
		EmailTemplate notice = [SELECT Id, Name, Subject, HtmlValue, Body, BrandTemplateId, DeveloperName FROM EmailTemplate WHERE DeveloperName = 'Exhibition_Transfer_Reservation_Notice' LIMIT 1];
		EmailTemplate dropOff = [SELECT Id, Name, Subject, HtmlValue, Body, BrandTemplateId, DeveloperName FROM EmailTemplate WHERE DeveloperName = 'Exhibition_Vehicle_DropOff' LIMIT 1];
		//无法派车
		EmailTemplate cancleArrange = [SELECT Id, Name, Subject,HtmlValue, Body, BrandTemplateId, DeveloperName FROM EmailTemplate WHERE DeveloperName = 'Vehicle_Cancle_Arrangement' LIMIT 1];


		// System.Url.getOrgDomainUrl().toExternalForm()
		List<Messaging.SingleEmailMessage> sendEmailList = new List<Messaging.SingleEmailMessage>();
		Map<String, List<String>> personInfoMap = new Map<String, List<String>>();
    	for (Exhibition_Vehical_Booking__c item : newList) {
    		// if (item.Is_Arranged__c && !oldDataMap.get(item.Id).Is_Arranged__c && String.isNotBlank(item.Plate_Number__c) && String.isNotBlank(item.Driver_Phone__c) && (item.Departure_Time__c != null) && String.isNotBlank(item.Vehical_Driver__c)) {
			//2025-01-14 TJP 修改原逻辑 出发判断条件需改
			if (item.Is_Warn__c && !item.Is_Apply__c && item.Approval_Status__c.equals('审批通过') && !oldDataMap.get(item.Id).Is_Warn__c) {
                Messaging.SingleEmailMessage singleEmail = new Messaging.SingleEmailMessage();
				String toEmail = item.Internal_Registration_Email__c;
				List<Messaging.RenderEmailTemplateBodyResult> renderEmailTemplateBodyRes = Messaging.renderEmailTemplate(item.OwnerId, item.Id, new List<String>{notice.HtmlValue});
				String body = renderEmailTemplateBodyRes[0].getMergedBody();
				System.debug('body=' + body);
				singleEmail.setHTMLBody(body);
				singleEmail.setSaveAsActivity(false);
				// singleEmail.setTemplateId(emtemp.Id);
				// singleEmail.setWhatId(item.Id);
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
				if(personInfoMap.containsKey(item.UserPhone__c)) {
					personInfoMap.get(item.UserPhone__c).add(body);
				} else {
					personInfoMap.put(item.UserPhone__c, new List<String>{body});
				}
            }
            if (item.Is_Verify__c && item.Is_Apply__c && item.Approval_Status__c.equals('审批通过') && !oldDataMap.get(item.Id).Is_Verify__c) {
                Messaging.SingleEmailMessage singleEmail = new Messaging.SingleEmailMessage();
				String toEmail = item.Internal_Registration_Email__c;
				List<Messaging.RenderEmailTemplateBodyResult> renderEmailTemplateBodyRes = Messaging.renderEmailTemplate(item.OwnerId, item.Id, new List<String>{notice.HtmlValue});
				String body = renderEmailTemplateBodyRes[0].getMergedBody();
				System.debug('body=' + body);
				singleEmail.setHTMLBody(body);
				singleEmail.setSaveAsActivity(false);
				// singleEmail.setTemplateId(emtemp.Id);
				// singleEmail.setWhatId(item.Id);
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
				if(personInfoMap.containsKey(item.UserPhone__c)) {
					personInfoMap.get(item.UserPhone__c).add(body);
				} else {
					personInfoMap.put(item.UserPhone__c, new List<String>{body});
				}
            }
			if (item.Is_Arranged__c && !oldDataMap.get(item.Id).Is_Arranged__c) {

				Messaging.SingleEmailMessage singleEmail = new Messaging.SingleEmailMessage();
				String toEmail = item.Internal_Registration_Email__c;
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
				System.debug('' +tempOfSMS.Id +  item.Id + tempOfSMS.Body );
                renderEmailTemplateBodyRes = Messaging.renderEmailTemplate(tempOfSMS.Id, item.Id, new List<String>{tempOfSMS.Body});
				body = renderEmailTemplateBodyRes[0].getMergedBody();
				System.debug('body=' + body);
				if(personInfoMap.containsKey(item.UserPhone__c)) {
					personInfoMap.get(item.UserPhone__c).add(body);
				} else {
					personInfoMap.put(item.UserPhone__c, new List<String>{body});
				}
    		}
			if (item.Return_Is_Arranged__c && !oldDataMap.get(item.Id).Return_Is_Arranged__c) {

				Messaging.SingleEmailMessage singleEmail = new Messaging.SingleEmailMessage();
				String toEmail = item.Internal_Registration_Email__c;
				List<Messaging.RenderEmailTemplateBodyResult> renderEmailTemplateBodyRes = Messaging.renderEmailTemplate(item.OwnerId, item.Id, new List<String>{dropOff.HtmlValue});
				String body = renderEmailTemplateBodyRes[0].getMergedBody();
				System.debug('body=' + body);
				singleEmail.setHTMLBody(body);
				singleEmail.setSaveAsActivity(false);
				// singleEmail.setTemplateId(emtemp.Id);
				// singleEmail.setWhatId(item.Id);
				singleEmail.setSubject(dropOff.Subject + '');
				//设置发送人邮箱
				singleEmail.setOrgWideEmailAddressId(System.Label.Exhibition_Public_Mailbox);
				singleEmail.setToAddresses(new List<String>{toEmail});
				sendEmailList.add(singleEmail);

				// 短信
				System.debug('' +dropOff.Id +  item.Id + dropOff.Body );
                renderEmailTemplateBodyRes = Messaging.renderEmailTemplate(dropOff.Id, item.Id, new List<String>{dropOff.Body});
				body = renderEmailTemplateBodyRes[0].getMergedBody();
				System.debug('body=' + body);
				if(personInfoMap.containsKey(item.UserPhone__c)) {
					personInfoMap.get(item.UserPhone__c).add(body);
				} else {
					personInfoMap.put(item.UserPhone__c, new List<String>{body});
				}
    		}
			//新增 无法派车的邮件推送
			if (item.Cancel_Arrangement__c && !oldDataMap.get(item.Id).Cancel_Arrangement__c) {

				Messaging.SingleEmailMessage singleEmail = new Messaging.SingleEmailMessage();
				String toEmail = item.Internal_Registration_Email__c;
				List<Messaging.RenderEmailTemplateBodyResult> renderEmailTemplateBodyRes = Messaging.renderEmailTemplate(item.OwnerId, item.Id, new List<String>{cancleArrange.HtmlValue});
				String body = renderEmailTemplateBodyRes[0].getMergedBody();
				System.debug('body=' + body);
				singleEmail.setHTMLBody(body);
				singleEmail.setSaveAsActivity(false);
				// singleEmail.setTemplateId(emtemp.Id);
				// singleEmail.setWhatId(item.Id);
				singleEmail.setSubject(dropOff.Subject + '');
				//设置发送人邮箱
				singleEmail.setOrgWideEmailAddressId(System.Label.Exhibition_Public_Mailbox);
				singleEmail.setToAddresses(new List<String>{toEmail});
				// sendEmailList.add(singleEmail);

				// 短信
				System.debug('' +cancleArrange.Id +  item.Id + cancleArrange.Body );
                renderEmailTemplateBodyRes = Messaging.renderEmailTemplate(cancleArrange.Id, item.Id, new List<String>{cancleArrange.Body});
				body = renderEmailTemplateBodyRes[0].getMergedBody();
				System.debug('body=' + body);
				if(personInfoMap.containsKey(item.UserPhone__c)) {
					personInfoMap.get(item.UserPhone__c).add(body);
				} else {
					personInfoMap.put(item.UserPhone__c, new List<String>{body});
				}
    		}
    	}
    	if (sendEmailList.size() > 0) {
			System.debug('------------>ready send ! ');
			try {
				Messaging.sendEmail(sendEmailList);
			}
			catch (Exception e) {
				System.debug('ExhibitionVehicalTriggerHandlerHelper.sendEmail->'+e.getLineNumber()+e.getMessage());
			}
		}
		if(personInfoMap.keyset().size() > 0) {
            ExpoApplyInfoTriggerHanderHelper.sendMessage(Json.serialize(personInfoMap));
        }
    }
}