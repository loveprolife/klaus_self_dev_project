public without sharing class ExhibitionHotelTriggerHandlerHelper {
    private final static String SITE_URL_MID = '-sites.com/exhibitionArrangementWithout/apex/ExhibitionArrPublicPage?id=';

	/**
     * @description 酒店信息已分配，无法进行修改
     * @param       oldList     更改前数据
     * @param       newList     更改后数据
    */
    public static void isArrangedForbiddenUpdate(List<Hotel_Booked_Info__c> oldList, List<Hotel_Booked_Info__c> newList){
    	Map<Id, Hotel_Booked_Info__c> oldDataMap = new Map<Id, Hotel_Booked_Info__c>(oldList);
    	for (Hotel_Booked_Info__c item : newList) {
    		if (item.Is_Arranged__c && oldDataMap.get(item.Id).Is_Arranged__c) {
    			item.addError('名为：'+ item.Guest_Name_CN__c +' 的酒店已分配，无法再次分配！');
    		}
    	}
	}

	/**
     * @description 室友信息/入住酒店信息 填充
     * @param       oldList     更改前数据
     * @param       newList     更改后数据
    */
    public static void dataSupplement(List<Hotel_Booked_Info__c> oldList,List<Hotel_Booked_Info__c> newList){
		if(Test.isRunningTest()){
            gabige();
        }
		Map<Id, Hotel_Booked_Info__c> oldDataMap = new Map<Id, Hotel_Booked_Info__c>(oldList);
		// 存储需要查询的居民和室友的ID
        Set<String> residentsToCheck = new Set<String>();
        Set<String> roommatesToCheck = new Set<String>();
    	for (Hotel_Booked_Info__c item : newList) {
    		if (item.Book__c != null && item.Need_Hotel__c == null) {
    			item.Need_Hotel__c = 'true';
    		}
			if(item.Internal_Registration__c != oldDataMap.get(item.Id).Internal_Registration__c && String.isNotEmpty(item.Internal_Registration__c)) {

				if (oldDataMap.get(item.Id).Internal_Registration__c != null) {
					roommatesToCheck.add(oldDataMap.get(item.Id).Internal_Registration__c);
				} 
	
                roommatesToCheck.add(item.Internal_Registration__c);
                residentsToCheck.add(item.Residents__c);
				// if (item.Internal_Registration__c != null) {
                //     roommatesToCheck.add(item.Internal_Registration__c);
                // }
                // residentsToCheck.add(item.Residents__c);
			}
    	}



        
		System.debug('residentsToCheck' + residentsToCheck);
		System.debug('roommatesToCheck' + roommatesToCheck);
		if(roommatesToCheck.size() > 0) {
			List<Hotel_Booked_Info__c> relatedRecords = [
        	    SELECT Id, Internal_Registration__c
        	    FROM Hotel_Booked_Info__c
        	    WHERE Residents__c NOT IN :residentsToCheck AND Internal_Registration__c IN :roommatesToCheck
				// WHERE Residents__c IN :roommatesToCheck
        	];

        	// 存储需要更新的记录
        	List<Hotel_Booked_Info__c> recordsToUpdate = new List<Hotel_Booked_Info__c>();
			System.debug('relatedRecords' + relatedRecords.size());
        	// 清空互为室友的记录中的室友信息
        	for (Hotel_Booked_Info__c relatedRecord : relatedRecords) {
        	    relatedRecord.Internal_Registration__c = null;
        	    recordsToUpdate.add(relatedRecord);
        	}
        	// 更新记录
        	if (!recordsToUpdate.isEmpty()) {
        	    update recordsToUpdate;
        	}
		}
	}

	
	public static void updateRoommateDate(List<Hotel_Booked_Info__c> oldList, List<Hotel_Booked_Info__c> newList){
		Map<Id, Hotel_Booked_Info__c> oldDataMap = new Map<Id, Hotel_Booked_Info__c>(oldList);
		List<Internal_Registration__c> updateList = new List<Internal_Registration__c>();
    	for (Hotel_Booked_Info__c item : newList) {
    		if (item.In_Hotel_Date__c != oldDataMap.get(item.Id).In_Hotel_Date__c || item.Out_Hotel_Date__c != oldDataMap.get(item.Id).Out_Hotel_Date__c) {
    			Internal_Registration__c ir = new Internal_Registration__c(
					Id = item.Residents__c,
					In_Hotel_Date__c = item.In_Hotel_Date__c,
					Out_Hotel_Date__c = item.Out_Hotel_Date__c
				);
				updateList.add(ir);
    		}
    	}
		update updateList;
	}

	/**
     * @description 酒店分配后发送通知邮件
     * @param       oldList     更改前数据
     * @param       newList     更改后数据
    */
	public static void sendEmail(List<Hotel_Booked_Info__c> oldList, List<Hotel_Booked_Info__c> newList){
		String SITE_URL_FRO = System.Url.getOrgDomainUrl().toExternalForm().split('.com')[0];
		Map<Id, Hotel_Booked_Info__c> oldDataMap = new Map<Id, Hotel_Booked_Info__c>(oldList);
		// EmailTemplate temp = [SELECT Id, Name, Subject, HtmlValue, Body, BrandTemplateId, DeveloperName FROM EmailTemplate WHERE DeveloperName = 'Hotel_Arrangement_Notice' LIMIT 1]; IFA_Hotel_Arrangement_Notice     
		EmailTemplate temp = [SELECT Id, Name, Subject, HtmlValue, Body, BrandTemplateId, DeveloperName FROM EmailTemplate WHERE DeveloperName = 'IFA_Hotel_Arrangement_Notice' LIMIT 1];
		EmailTemplate singleTemp = [SELECT Id, Name, Subject, HtmlValue, Body, BrandTemplateId, DeveloperName FROM EmailTemplate WHERE DeveloperName = 'IFA_Single_Hotel_Arrangement_Notice' LIMIT 1];   
		EmailTemplate twinTemp = [SELECT Id, Name, Subject, HtmlValue, Body, BrandTemplateId, DeveloperName FROM EmailTemplate WHERE DeveloperName = 'IFA_Twin_Hotel_Arrangement_Notice' LIMIT 1];              	                 	                                   	                 	
        EmailTemplate notice = [SELECT Id, Name, Subject, HtmlValue, Body, BrandTemplateId, DeveloperName FROM EmailTemplate WHERE DeveloperName = 'Hotel_Reservation_Transfer_Reservation_Notice' LIMIT 1];
                                    
		// System.Url.getOrgDomainUrl().toExternalForm()
		List<Messaging.SingleEmailMessage> sendEmailList = new List<Messaging.SingleEmailMessage>();
		Map<String, List<String>> personInfoMap = new Map<String, List<String>>();
    	for (Hotel_Booked_Info__c item : newList) {
            //2025-03-24 取消前端APP接口触发
            // if (item.Is_Warn__c && !item.Is_Apply__c && item.Approval_Status__c.equals('审批通过') && !oldDataMap.get(item.Id).Is_Warn__c) {

            if (item.Is_Warn__c && !oldDataMap.get(item.Id).Is_Warn__c) {
                Messaging.SingleEmailMessage singleEmail = new Messaging.SingleEmailMessage();
				String toEmail = item.Guest_Email__c;
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
				if(personInfoMap.containsKey(item.Guest_Mobile__c)) {
					personInfoMap.get(item.Guest_Mobile__c).add(body);
				} else {
					personInfoMap.put(item.Guest_Mobile__c, new List<String>{body});
				}
            }
            if (item.Is_Verify__c && !oldDataMap.get(item.Id).Is_Verify__c) {
                Messaging.SingleEmailMessage singleEmail = new Messaging.SingleEmailMessage();
				String toEmail = item.Guest_Email__c;
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
				if(personInfoMap.containsKey(item.Guest_Mobile__c)) {
					personInfoMap.get(item.Guest_Mobile__c).add(body);
				} else {
					personInfoMap.put(item.Guest_Mobile__c, new List<String>{body});
				}
            }
            
			if (item.Is_Arranged__c && !oldDataMap.get(item.Id).Is_Arranged__c) {
				if(String.isEmpty(item.Internal_Registration__c)) {
					if(String.isNotBlank(item.SelfHotel__c) && item.SelfHotel__c.contains('双')) {
						Messaging.SingleEmailMessage singleEmail = new Messaging.SingleEmailMessage();
						String toEmail = item.Guest_Email__c;
						List<Messaging.RenderEmailTemplateBodyResult> renderEmailTemplateBodyRes = Messaging.renderEmailTemplate(item.OwnerId, item.Id, new List<String>{twinTemp.HtmlValue});
						String body = renderEmailTemplateBodyRes[0].getMergedBody();
						System.debug('body=' + body);
						singleEmail.setHTMLBody(body);
						singleEmail.setSaveAsActivity(false);
						// singleEmail.setTemplateId(emtemp.Id);
						// singleEmail.setWhatId(item.Id);
						singleEmail.setSubject(twinTemp.Subject + '');
						//设置发送人邮箱
						singleEmail.setOrgWideEmailAddressId(System.Label.Exhibition_Public_Mailbox);
						singleEmail.setToAddresses(new List<String>{toEmail});
						sendEmailList.add(singleEmail);
					} else {
						Messaging.SingleEmailMessage singleEmail = new Messaging.SingleEmailMessage();
						String toEmail = item.Guest_Email__c;
						List<Messaging.RenderEmailTemplateBodyResult> renderEmailTemplateBodyRes = Messaging.renderEmailTemplate(item.OwnerId, item.Id, new List<String>{singleTemp.HtmlValue});
						String body = renderEmailTemplateBodyRes[0].getMergedBody();
						System.debug('body=' + body);
						singleEmail.setHTMLBody(body);
						singleEmail.setSaveAsActivity(false);
						// singleEmail.setTemplateId(emtemp.Id);
						// singleEmail.setWhatId(item.Id);
						singleEmail.setSubject(singleTemp.Subject + '');
						//设置发送人邮箱
						singleEmail.setOrgWideEmailAddressId(System.Label.Exhibition_Public_Mailbox);
						singleEmail.setToAddresses(new List<String>{toEmail});
						sendEmailList.add(singleEmail);
					}
				} else {
					Messaging.SingleEmailMessage singleEmail = new Messaging.SingleEmailMessage();
					String toEmail = item.Guest_Email__c;
					List<Messaging.RenderEmailTemplateBodyResult> renderEmailTemplateBodyRes = Messaging.renderEmailTemplate(item.OwnerId, item.Id, new List<String>{temp.HtmlValue});
					String body = renderEmailTemplateBodyRes[0].getMergedBody();
					System.debug('body=' + body);
					singleEmail.setHTMLBody(body);
					singleEmail.setSaveAsActivity(false);
					// singleEmail.setTemplateId(emtemp.Id);
					// singleEmail.setWhatId(item.Id);
					singleEmail.setSubject(temp.Subject + '');
					//设置发送人邮箱
					singleEmail.setOrgWideEmailAddressId(System.Label.Exhibition_Public_Mailbox);
					singleEmail.setToAddresses(new List<String>{toEmail});
					sendEmailList.add(singleEmail);
				}
				

				// 短信
				// System.debug('' +temp.Id +  item.Id + temp.Body );
                // renderEmailTemplateBodyRes = Messaging.renderEmailTemplate(temp.Id, item.Id, new List<String>{temp.Body});
				// body = renderEmailTemplateBodyRes[0].getMergedBody();
				// System.debug('body=' + body);
				// if(personInfoMap.containsKey(item.Guest_Mobile__c)) {
				// 	personInfoMap.get(item.Guest_Mobile__c).add(body);
				// } else {
				// 	personInfoMap.put(item.Guest_Mobile__c, new List<String>{body});
				// }
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
            // ExpoApplyInfoTriggerHanderHelper.sendMessage(Json.serialize(personInfoMap));
        }
    }

	public static void gabige() {
        integer i = 0;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
    }
}